#include "syscall.h"

#include "defs.h"
#include "fs.h"
#include "printk.h"
#include "proc.h"
#include "stddef.h"
#include "stdint.h"

extern struct task_struct* current;

syscall_t syscall_table[] = {
    [SYS_OPENAT] = sys_openat, [SYS_CLOSE] = sys_close, [SYS_SEEK] = sys_seek,
    [SYS_READ] = sys_read,     [SYS_WRITE] = sys_write, [SYS_GETPID] = sys_getpid,
    [SYS_CLONE] = sys_clone,
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

// sys_seek(unsigned int fd, int64_t offset, unsigned int whence)
void sys_seek(struct pt_regs* regs) {
    unsigned int fd     = regs->x[REG_IDX_A0];
    int64_t offset      = regs->x[REG_IDX_A1];
    unsigned int whence = regs->x[REG_IDX_A2];

    if (current->files == NULL) {
        Err("panic: a task without files_struct is trying to seek");
        return;
    }

    struct file* file = &(current->files->fd_array[fd]);
    if (file->opened == 0) {
        Log(RED "[Error]" BLUE " Trying to seek a closed file");
        return;
    }

    regs->x[REG_IDX_A0] = file->lseek(file, offset, whence);
    return;
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

// sys_openat(int dfd, const char* pathname, int flags)
void sys_openat(struct pt_regs* regs) {
    int dfd   = regs->x[REG_IDX_A0];
    int flags = regs->x[REG_IDX_A2];

    const char* pathname = (const char*)regs->x[REG_IDX_A1];

    if (current->files == NULL) {
        Err("panic: a task without files_struct is trying to open a file");
        return;
    }

    // Find an empty file descriptor
    for (size_t i = 3; i < MAX_FILE_NUMBER; i++) {
        if (current->files->fd_array[i].opened == 0) {
            regs->x[REG_IDX_A0] = file_open(&(current->files->fd_array[i]), pathname, flags);
            return;
        }
    }

    regs->x[REG_IDX_A0] = -1;
    return;
}

// sys_close(unsigned int fd)
void sys_close(struct pt_regs* regs) {
    unsigned int fd = regs->x[REG_IDX_A0];

    if (current->files == NULL) {
        Err("panic: a task without files_struct is trying to close a file");
        return;
    }

    struct file* file = &(current->files->fd_array[fd]);
    if (file->opened == 0) {
        Log(RED "[Error]" BLUE " Trying to close a closed file");
        return;
    }

    file->opened = 0;
    return;
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