#ifndef _SYSCALL_H_
#define _SYSCALL_H_

#include "defs.h"
#include "stddef.h"
#include "stdint.h"

#define SYS_OPENAT 56
#define SYS_CLOSE  57
#define SYS_SEEK   62
#define SYS_READ   63
#define SYS_WRITE  64
#define SYS_GETPID 172
#define SYS_CLONE  220

void sys_seek(struct pt_regs*);
void sys_read(struct pt_regs* regs);
void sys_write(struct pt_regs*);
void sys_getpid(struct pt_regs*);
void sys_clone(struct pt_regs*);
void sys_openat(struct pt_regs*);
void sys_close(struct pt_regs*);

typedef void (*syscall_t)(struct pt_regs*);

void syscall_handler(struct pt_regs*);

#endif