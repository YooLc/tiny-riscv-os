#include "defs.h"
#include "mm.h"
#include "printk.h"
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
