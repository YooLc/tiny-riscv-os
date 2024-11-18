#ifndef __DEFS_H__
#define __DEFS_H__

#include "stdint.h"

#define csr_read(csr)                                   \
    ({                                                  \
        uint64_t __v;                                   \
        asm volatile("csrr %0, " #csr : "=r"(__v) : :); \
        __v;                                            \
    })

#define csr_write(csr, val)                               \
    ({                                                    \
        uint64_t __v = (uint64_t)(val);                   \
        asm volatile("csrw " #csr ", %0" : : "r"(__v) :); \
    })

void clock_set_next_event();

#define PHY_START         0x0000000080000000
#define PHY_SIZE          128 * 1024 * 1024  // 128 MiB，QEMU 默认内存大小
#define PHY_END           (PHY_START + PHY_SIZE)

#define PGSIZE            0x1000             // 4 KiB
#define PGROUNDUP(addr)   ((addr + PGSIZE - 1) & (~(PGSIZE - 1)))
#define PGROUNDDOWN(addr) (addr & (~(PGSIZE - 1)))

#define OPENSBI_SIZE      (0x200000)

#define VM_START          (0xffffffe000000000)
#define VM_END            (0xffffffff00000000)
#define VM_SIZE           (VM_END - VM_START)

#define PA2VA_OFFSET      (VM_START - PHY_START)

#define PERM_V            0b1L
#define PERM_R            0b10L
#define PERM_W            0b100L
#define PERM_X            0b1000L
#define PERM_U            0b10000L
#define PERM_G            0b100000L
#define PERM_A            0b1000000L
#define PERM_D            0b10000000L
#define PPN_MASK          0xfffffffffffL

#endif
