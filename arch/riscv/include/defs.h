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

#endif
