#include "mm.h"

#include "defs.h"
#include "printk.h"
#include "string.h"

extern char _ekernel[];
extern uint64_t early_pgtbl[512];

struct {
    struct run* freelist;
} kmem;

void* kalloc() {
    struct run* r;

    r             = kmem.freelist;
    kmem.freelist = r->next;

    memset((void*)r, 0x0, PGSIZE);
    return (void*)r;
}

void kfree(void* addr) {
    struct run* r;

    // PGSIZE align
    *(uintptr_t*)&addr = (uintptr_t)addr & ~(PGSIZE - 1);

    memset(addr, 0x0, (uint64_t)PGSIZE);

    r             = (struct run*)addr;
    r->next       = kmem.freelist;
    kmem.freelist = r;

    return;
}

void kfreerange(char* start, char* end) {
    char* addr = (char*)PGROUNDUP((uintptr_t)start);
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
        // Log("kfree: addr = %p, next page: %p, end: %p", addr, (uintptr_t)(addr) +
        // (uint64_t)PGSIZE, (uintptr_t)end);
        uint64_t direct_map_vpn = ((uintptr_t)addr >> 30) & 0x1ff;
        uint64_t pte            = early_pgtbl[direct_map_vpn];

        uint64_t tmp = ((uintptr_t)addr & 0x3fffffff);
        // Log("VPN: %lx, Page table entry: %lx, pa: %lx", direct_map_vpn, pte,
        // (((pte >> 10) << 12) + tmp));
        kfree((void*)addr);
    }
}

void mm_init(void) {
    kfreerange(_ekernel, (char*)(PHY_END + PA2VA_OFFSET));
    printk("...mm_init done!\n");
}
