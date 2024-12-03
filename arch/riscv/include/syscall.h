#ifndef _SYSCALL_H_
#define _SYSCALL_H_

#include "defs.h"
#include "stddef.h"
#include "stdint.h"

void sys_write(struct pt_regs*);
void sys_getpid(struct pt_regs*);

typedef void (*syscall_t)(struct pt_regs*);

void syscall_handler(struct pt_regs*);

#endif