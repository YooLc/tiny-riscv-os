#ifndef __DEFS_H__
#define __DEFS_H__

#include "stdint.h"

#define csr_read(csr)                                  \
  ({                                                   \
    uint64_t __v;                                      \
    asm volatile("csrr %0, " #csr : "=r"(__v) : : );   \
    __v;                                               \
  })

#define csr_write(csr, val)                            \
  ({                                                   \
    uint64_t __v = (uint64_t)(val);                    \
    asm volatile("csrw " #csr ", %0" : : "r"(__v) : ); \
  })

void clock_set_next_event();

#define PHY_START 0x0000000080000000
#define PHY_SIZE 128 * 1024 * 1024 // 128 MiB，QEMU 默认内存大小
#define PHY_END (PHY_START + PHY_SIZE)

#define PGSIZE 0x1000 // 4 KiB
#define PGROUNDUP(addr) ((addr + PGSIZE - 1) & (~(PGSIZE - 1)))
#define PGROUNDDOWN(addr) (addr & (~(PGSIZE - 1)))

#endif
