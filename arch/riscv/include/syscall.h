#ifndef _SYSCALL_H_
#define _SYSCALL_H_

#include "defs.h"
#include "stddef.h"
#include "stdint.h"

#define SYS_WRITE 64
#define SYS_GETPID 172
#define SYS_CLONE 220

void sys_write(struct pt_regs*);
void sys_getpid(struct pt_regs*);
void sys_clone(struct pt_regs*);

typedef void (*syscall_t)(struct pt_regs*);

void syscall_handler(struct pt_regs*);

#endif