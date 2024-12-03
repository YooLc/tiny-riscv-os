#include "syscall.h"

#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "stddef.h"
#include "stdint.h"

extern struct task_struct* current;

syscall_t syscall_table[] = {
    [64]  = sys_write,
    [172] = sys_getpid,
};

void syscall_handler(struct pt_regs* regs) {
    // Calling convention: https://man7.org/linux/man-pages/man2/syscall.2.html
    uint64_t syscall_id = regs->x[REG_IDX_A7];
    uint64_t ret        = 0;

    syscall_t handler = syscall_table[syscall_id];
    if (handler == NULL) {
        Log("[Fatal] Unimplemented syscall: %lld", syscall_id);
        return;
    }
    handler(regs);
    regs->sepc += 4;
}

// sys_write(unsigned int fd, const char* buf, size_t count)
void sys_write(struct pt_regs* regs) {
    uint64_t fd     = regs->x[REG_IDX_A0];
    const char* buf = (const char*)regs->x[REG_IDX_A1];
    size_t count    = regs->x[REG_IDX_A2];

    for (size_t i = 0; i < count; i++) {
        printk("%c", buf[i]);
    }

    regs->x[REG_IDX_A0] = count;
}

// uint64_t sys_getpid()
void sys_getpid(struct pt_regs* regs) {
    regs->x[REG_IDX_A0] = current->pid;
    return;
}