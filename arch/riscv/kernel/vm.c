#include "vm.h"

#include "defs.h"
#include "mm.h"
#include "printk.h"
#include "proc.h"
#include "stddef.h"
#include "stdint.h"
#include "string.h"

extern uint8_t _stext[];
extern uint8_t _etext[];
extern uint8_t _srodata[];
extern uint8_t _erodata[];
extern uint8_t _sdata[];
extern uint8_t _edata[];
extern uint8_t _sbss[];
extern uint8_t _ebss[];
extern uint8_t _ekernel[];
extern uint8_t _sramdisk[];
extern uint8_t _eramdisk[];

extern struct task_struct* current;

#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

uint64_t create_pte(uint64_t pa) {
    uint64_t ppn = (pa >> 12) & PPN_MASK;
    // Accessed and dirty for 0x80000000 page
    uint64_t pte = (ppn << 10) | PERM_A | PERM_D | PERM_X | PERM_R | PERM_W | PERM_V;
    return pte;
}

void setup_vm() {
    /*
     * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表
     * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个
     *     entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
     **/
    Log("setup_vm: start");
    const uint64_t huge_page = 0x40000000;  // 1 GiB
    for (uint64_t i = 0; i < PHY_SIZE; i += huge_page) {
        // 9 bit vpn
        uint64_t identity_vpn   = ((PHY_START + i) >> 30) & 0x1ff;
        uint64_t direct_map_vpn = ((VM_START + i) >> 30) & 0x1ff;

        printk("id vpn: %lx, %ld, dm vpn: %lx, %ld, pte: %lx\n", identity_vpn, identity_vpn,
               direct_map_vpn, direct_map_vpn, create_pte(PHY_START + i));

        // Create page table entry
        // early_pgtbl[identity_vpn]   = create_pte(PHY_START + i);
        early_pgtbl[direct_map_vpn] = create_pte(PHY_START + i);
        Log("early_pgtbl[%lx] = %lx", identity_vpn, early_pgtbl[identity_vpn]);
    }
    Log("setup early page table at %p", early_pgtbl);
}

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t* pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
    /*
     * pgtbl 为根页表的基地址
     * va, pa 为需要映射的虚拟地址、物理地址
     * sz 为映射的大小，单位为字节
     * perm 为映射的权限（即页表项的低 8 位）
     *
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
     **/
    uint64_t ppn[3], vpn[3];
    Log("Creating mapping [%p, %p) -> [%p, %p), size: %lx, perm: %lx, pgtbl: %p", pa, pa + sz, va,
        va + sz, sz, perm, pgtbl);
    // Page table walk: PGD -> PMD -> PTE
    for (uint64_t offset = 0; offset < sz; offset += PGSIZE) {
        uint64_t cur_pa  = pa + offset;
        uint64_t cur_va  = va + offset;
        uint64_t cur_ppn = (cur_pa >> 12) & PPN_MASK;
        // Calculate PPN and VPN
        ppn[0] = (cur_pa >> 12) & 0x1ff;
        ppn[1] = (cur_pa >> 21) & 0x1ff;
        ppn[2] = (cur_pa >> 30) & 0x3ffffff;
        vpn[0] = (cur_va >> 12) & 0x1ff;
        vpn[1] = (cur_va >> 21) & 0x1ff;
        vpn[2] = (cur_va >> 30) & 0x1ff;

        uint64_t *pmd = NULL, *pte = NULL;
        // Check if PGD entry valid
        if ((pgtbl[vpn[2]] & PERM_V) == 0) {  // If not, allocate a new PMD page
            pmd = kalloc();
            // memset(pmd, 0x0, PGSIZE); // kalloc() will do this
            uint64_t pmd_pa  = (uint64_t)pmd - PA2VA_OFFSET;
            uint64_t pmd_ppn = (pmd_pa >> 12) & PPN_MASK;  // High 44 bits of pmd_pa
            pgtbl[vpn[2]]    = (pmd_ppn << 10) | PERM_V;   // Non-leaf node
        } else {
            uint64_t pmd_ppn = (pgtbl[vpn[2]] >> 10) & PPN_MASK;
            uint64_t pmd_pa  = (pmd_ppn << 12);

            pmd = (uint64_t*)(pmd_pa + PA2VA_OFFSET);
        }

        if (pmd == NULL) {
            Log("Fatal Error: unable to allocate or find PMD\n");
            return;
        }

        // Check if PMD entry valid
        if ((pmd[vpn[1]] & PERM_V) == 0) {  // If not, allocate a new PTE page
            pte = kalloc();
            // memset(pte, 0x0, PGSIZE); // kalloc() will do this
            uint64_t pte_pa  = (uint64_t)pte - PA2VA_OFFSET;
            uint64_t pte_ppn = (pte_pa >> 12) & PPN_MASK;  // High 44 bits of pte_pa
            pmd[vpn[1]]      = (pte_ppn << 10) | PERM_V;   // Non-leaf node
        } else {
            uint64_t pte_ppn = (pmd[vpn[1]] >> 10) & PPN_MASK;
            uint64_t pte_pa  = (pte_ppn << 12);

            pte = (uint64_t*)(pte_pa + PA2VA_OFFSET);
        }

        // Update pte
        if (pte == NULL) {
            Log("Fatal Error: unable to allocate or find PTE\n");
            return;
        }

        // Log("pgd: %p, pgd[%x] = %x", pgtbl, vpn[2], pgtbl[vpn[2]]);
        pte[vpn[0]] = (cur_ppn << 10) | perm;
        // Log("Created mapping %lx -> %lx, perm: %lx", cur_va, cur_pa, perm);
    }
}

void setup_vm_final() {
    memset(swapper_pg_dir, 0x0, PGSIZE);

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)(_stext - PA2VA_OFFSET),
                   (_etext - _stext), PERM_A | PERM_X | PERM_R | PERM_V);

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)(_srodata - PA2VA_OFFSET),
                   (_erodata - _srodata), PERM_A | PERM_R | PERM_V);

    // mapping other memory -|W|R|V
    // Set dirty bit for modified pages
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)(_sdata - PA2VA_OFFSET),
                   (_edata - _sdata), PERM_A | PERM_W | PERM_R | PERM_V);
    create_mapping(swapper_pg_dir, (uint64_t)_sbss, (uint64_t)(_sbss - PA2VA_OFFSET),
                   (_ebss - _sbss), PERM_A | PERM_D | PERM_W | PERM_R | PERM_V);
    create_mapping(swapper_pg_dir, (uint64_t)_ekernel, (uint64_t)(_ekernel - PA2VA_OFFSET),
                   (PHY_SIZE - (uint64_t)(_ekernel - PA2VA_OFFSET - PHY_START)),
                   PERM_A | PERM_D | PERM_W | PERM_R | PERM_V);

    // Set up ramdisk
    create_mapping(swapper_pg_dir, (uint64_t)_sramdisk, (uint64_t)(_sramdisk - PA2VA_OFFSET),
                   (_eramdisk - _sramdisk), PERM_A | PERM_R | PERM_W | PERM_X | PERM_V);

    // set satp with swapper_pg_dir
    uint64_t swapper_pg_dir_pa = (uint64_t)swapper_pg_dir - PA2VA_OFFSET;
    uint64_t satp              = (0x8L << 60) | ((swapper_pg_dir_pa >> 12) & PPN_MASK);
    asm volatile("mv t0, %0\n" "csrw satp, t0" : : "r"(satp) : "t0");

    // flush TLB
    asm volatile("sfence.vma zero, zero");

    printk("...setup_vm_final: done\n");
    return;
}

/*
 * @mm       : current thread's mm_struct
 * @addr     : the va to look up
 *
 * @return   : the VMA if found or NULL if not found
 */
struct vm_area_struct* find_vma(struct mm_struct* mm, uint64_t addr) {
    struct vm_area_struct* cur_vma = mm->mmap;
    while (cur_vma != NULL) {
        if (cur_vma->vm_start <= addr && addr < cur_vma->vm_end) {
            return cur_vma;
        }
        cur_vma = cur_vma->vm_next;
    }
    return NULL;
}

/*
 * @mm       : current thread's mm_struct
 * @addr     : the va to map
 * @len      : memory size to map
 * @vm_pgoff : phdr->p_offset
 * @vm_filesz: phdr->p_filesz
 * @flags    : flags for the new VMA
 *
 * @return   : start va
 */
uint64_t do_mmap(struct mm_struct* mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff,
                 uint64_t vm_filesz, uint64_t flags) {
    Log("[S] Doing mmap: %p %p %x %x %x %x", mm, addr, len, vm_pgoff, vm_filesz, flags);
    struct vm_area_struct* cur_vma = (struct vm_area_struct*)kalloc(sizeof(struct vm_area_struct));

    if (cur_vma == NULL) {
        Err("[S] failed to do mmap because of memory shortage, can't allocate vma");
    }

    // Initialize vm_area_struct
    *cur_vma = (struct vm_area_struct){
        .vm_mm     = mm,
        .vm_start  = addr,
        .vm_end    = addr + len,
        .vm_pgoff  = vm_pgoff,
        .vm_filesz = vm_filesz,
        .vm_flags  = flags,
    };

    // Insert to Linked List
    cur_vma->vm_next = mm->mmap;
    cur_vma->vm_prev = NULL;
    if (mm->mmap != NULL) mm->mmap->vm_prev = cur_vma;
    mm->mmap = cur_vma;

    // Log("[S] ...do_mmap done");
    return addr;
}

void do_page_fault(struct pt_regs* regs) {
    Log("[S] Handling Page Fault, sepc = %p, stval = %p, scause = %p", regs->sepc, csr_read(stval),
        csr_read(scause));

    uint64_t bad_addr          = csr_read(stval);
    struct vm_area_struct* vma = find_vma(&current->mm, bad_addr);
    if (vma == NULL) {
        Err("[S] Panic: address %p not found in VMA", bad_addr);
    }

    uint64_t exception_code = (csr_read(scause) & 0x7FFFFFFF);

    // Check for permission
    int is_cow    = 0;
    uint64_t* pte = NULL;
    switch (exception_code) {
        case SUPERVISOR_INST_PAGE_FAULT:
            if (vma->vm_flags & VM_EXEC) break;
            Err("[S] Panic: Executing instructions on pages without VM_EXEC permission");
            break;
        case SUPERVISOR_STORE_PAGE_FAULT:
            if (vma->vm_flags & VM_WRITE) {
                /* Check for Copy On Write */
                pte = find_pte((uint64_t*)(current->pgd + PA2VA_OFFSET), PGROUNDDOWN(bad_addr));
                // CoW: pte available, not writable but VM_WRITE is set
                if (pte) is_cow = ((*pte & PERM_V) && ((*pte & PERM_W) == 0));
                break;
            }
            Err("[S] Panic: Writing to pages without VM_WRITE permission");
            break;
        case SUPERVISOR_LOAD_PAGE_FAULT:
            if (vma->vm_flags & VM_READ) break;
            Err("[S] Panic: Reading pages without VM_READ permission");
            break;
    };

    Log("[S] Valid page fault for vma: [%p, %p)", vma->vm_start, vma->vm_end);

    uint8_t* page        = (uint8_t*)alloc_page();
    uint64_t vpage_start = PGROUNDDOWN(bad_addr);
    uint64_t vpage_end   = PGROUNDUP(bad_addr + 1);
    uint64_t page_perm   = vma->vm_flags & ~VM_ANON;

    if (is_cow) {
        uint64_t src = (((*pte >> 10) & PPN_MASK) << 12) + PA2VA_OFFSET;

        Log("[S] " YELLOW "Cow: " BLUE "copying frame [%p, %p) to [%p, %p)", src - PA2VA_OFFSET,
            src + PGSIZE - PA2VA_OFFSET, page - PA2VA_OFFSET, page + PGSIZE - PA2VA_OFFSET);
        memcpy((void*)page, (void*)src, PGSIZE);
        put_page((void*)src);
        create_mapping((uint64_t*)(current->pgd + PA2VA_OFFSET), vpage_start,
                       (uint64_t)(page - PA2VA_OFFSET), PGSIZE,
                       PERM_A | PERM_D | PERM_U | page_perm | PERM_V);
    } else {
        // Allocate one page;
        uint64_t vaddr_start   = MAX(vpage_start, vma->vm_start);
        uint64_t vaddr_end     = MIN(vpage_end, vma->vm_end);
        int64_t in_page_offset = vaddr_start - vpage_start;

        if ((vma->vm_flags & VM_ANON) == 0) {  // Segment from file
            // Copy from file
            uint64_t seg_offset = vaddr_start - vma->vm_start;
            uint64_t seg_copysz = vaddr_end - vaddr_start;
            uint8_t* page_start = page;
            if (in_page_offset > 0) page_start += in_page_offset;
            uint8_t* file_start = _sramdisk + vma->vm_pgoff + seg_offset;

            Log("[S] Copying file: [%p, %p) -> [%p, %p), page_start: %p, in_page_offset: %p",
                file_start, file_start + seg_copysz, page_start, page_start + seg_copysz,
                page + seg_offset, in_page_offset);
            memcpy((void*)page_start, (void*)file_start, seg_copysz);
        }

        // Must set PERM_U! otherwise would stuck at page fault in s-mode
        create_mapping((uint64_t*)(current->pgd + PA2VA_OFFSET), (uint64_t)vpage_start,
                       (uint64_t)(page - PA2VA_OFFSET), PGSIZE,
                       PERM_A | PERM_D | PERM_U | page_perm | PERM_V);
    }
    // Flush TLB to make new mapping take effect
    asm volatile("sfence.vma");
    return;
}

/**
 * @pgtbl: page table base address
 * @va: virtual address
 *
 * Return 0 if page table entry not found
 */
uint64_t* find_pte(uint64_t* pgtbl, uint64_t va) {
    uint64_t vpn[3];

    // Page table walk: PGD -> PMD -> PTE
    // Calculate VPN
    vpn[0] = (va >> 12) & 0x1ff;
    vpn[1] = (va >> 21) & 0x1ff;
    vpn[2] = (va >> 30) & 0x1ff;

    uint64_t *pmd = NULL, *pte = NULL;
    // Check if PGD entry valid
    if (pgtbl[vpn[2]] & PERM_V) {
        uint64_t pmd_ppn = (pgtbl[vpn[2]] >> 10) & PPN_MASK;
        uint64_t pmd_pa  = (pmd_ppn << 12);

        pmd = (uint64_t*)(pmd_pa + PA2VA_OFFSET);
    } else {
        return 0;
    }

    // Check if PMD entry valid
    if (pmd[vpn[1]] & PERM_V) {
        uint64_t pte_ppn = (pmd[vpn[1]] >> 10) & PPN_MASK;
        uint64_t pte_pa  = (pte_ppn << 12);

        pte = (uint64_t*)(pte_pa + PA2VA_OFFSET);
    } else {
        return 0;
    }

    return &pte[vpn[0]];
}