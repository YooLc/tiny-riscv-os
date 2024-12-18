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
#define PGSHIFT           12
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

#define USER_START        (0x0000000000000000)  // user space start virtual address
#define USER_END          (0x0000004000000000)  // user space end virtual address

// When an SRET instruction (see Section 3.3.2) is executed to return from the trap handler, the
// privilege level is set to user mode if the SPP bit is 0, or supervisor mode if the SPP bit is 1;
// SPP is then set to 0.
#define SSTATUS_SPP  (1L << 8)
#define SSTATUS_SPIE (1L << 5)
#define SSTATUS_SIE  (1L << 1)
#define SSTATUS_SUM  (1L << 18)

#define REG_IDX_RA   1
#define REG_IDX_SP   2
#define REG_IDX_A0   10
#define REG_IDX_A1   11
#define REG_IDX_A2   12
#define REG_IDX_A3   13
#define REG_IDX_A4   14
#define REG_IDX_A5   15
#define REG_IDX_A6   16
#define REG_IDX_A7   17
struct pt_regs {
    uint64_t x[32];
    uint64_t sepc;
    uint64_t sstatus;
};

// Supervisor Traps
#define SUPERVISOR_TIMER_INTERRUPT  5
#define SUPERVISOR_ECALL_FROM_USER  8
#define SUPERVISOR_INST_PAGE_FAULT  12
#define SUPERVISOR_LOAD_PAGE_FAULT  13
#define SUPERVISOR_STORE_PAGE_FAULT 15

#endif
