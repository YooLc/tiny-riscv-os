#include "syscall.h"

#include "defs.h"
#include "fs.h"
#include "printk.h"
#include "proc.h"
#include "stddef.h"
#include "stdint.h"

extern struct task_struct* current;

syscall_t syscall_table[] = {
    [SYS_READ]   = sys_read,
    [SYS_WRITE]  = sys_write,
    [SYS_GETPID] = sys_getpid,
    [SYS_CLONE]  = sys_clone,
};

void syscall_handler(struct pt_regs* regs) {
    // Calling convention: https://man7.org/linux/man-pages/man2/syscall.2.html
    uint64_t syscall_id = regs->x[REG_IDX_A7];
    uint64_t ret        = 0;

    syscall_t handler = syscall_table[syscall_id];
    if (handler == NULL) {
        Err("panic: unimplemented syscall: %lld", syscall_id);
        return;
    }
    handler(regs);
    regs->sepc += 4;
}

// sys_read(unsigned int fd, char* buf, size_t count)
void sys_read(struct pt_regs* regs) {
    uint64_t fd     = regs->x[REG_IDX_A0];
    const char* buf = (const char*)regs->x[REG_IDX_A1];
    size_t count    = regs->x[REG_IDX_A2];

    if (current->files == NULL) {
        Err("panic: a task without files_struct is trying to read");
        return;
    }

    struct file* file = &(current->files->fd_array[fd]);
    if (file->opened == 0) {
        Log(RED "[Error]" BLUE " Trying to read from a closed file");
        regs->x[REG_IDX_A0] = ERROR_FILE_NOT_OPEN;
        return;
    } else if ((file->perms & FILE_READABLE) == 0) {
        Log(RED "[Error]" BLUE " Trying to read from file without read permission");
        regs->x[REG_IDX_A0] = ERROR_FILE_NOT_OPEN;
        return;
    }

    // Call read function
    regs->x[REG_IDX_A0] = file->read(file, (void*)buf, count);
    return;
}

// sys_write(unsigned int fd, const char* buf, size_t count)
void sys_write(struct pt_regs* regs) {
    uint64_t fd     = regs->x[REG_IDX_A0];
    const char* buf = (const char*)regs->x[REG_IDX_A1];
    size_t count    = regs->x[REG_IDX_A2];

    if (current->files == NULL) {
        Err("panic: a task without files_struct is trying to write");
        return;
    }

    struct file* file = &(current->files->fd_array[fd]);
    if (file->opened == 0) {
        Log(RED "[Error]" BLUE " Trying to write to a closed file");
        regs->x[REG_IDX_A0] = ERROR_FILE_NOT_OPEN;
        return;
    } else if ((file->perms & FILE_WRITABLE) == 0) {
        Log(RED "[Error]" BLUE " Trying to write to a read-only file");
        regs->x[REG_IDX_A0] = ERROR_FILE_NOT_OPEN;
        return;
    }

    // Call write function
    regs->x[REG_IDX_A0] = file->write(file, buf, count);
}

// uint64_t sys_getpid()
void sys_getpid(struct pt_regs* regs) {
    regs->x[REG_IDX_A0] = current->pid;
    return;
}

void sys_clone(struct pt_regs* regs) {
    regs->x[REG_IDX_A0] = do_fork(regs);
    return;
}