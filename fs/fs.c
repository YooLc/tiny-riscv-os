#include "fs.h"

#include "fat32.h"
#include "mm.h"
#include "printk.h"
#include "string.h"
#include "syscall.h"
#include "vfs.h"

struct files_struct* file_init() {
    // todo: alloc pages for files_struct, and initialize stdin, stdout, stderr
    struct files_struct* ret = alloc_pages((sizeof(struct files_struct) + PGSIZE - 1) / PGSIZE);
    memset(ret, 0, sizeof(struct files_struct));

    // Initialize stdin, stdout, stderr
    ret->fd_array[0] = (struct file){
        .opened  = 1,
        .perms   = FILE_READABLE,
        .cfo     = SEEK_SET,
        .fs_type = 0,
        .lseek   = NULL,
        .write   = NULL,
        .read    = stdin_read,
        .path    = "stdin",
    };

    ret->fd_array[1] = (struct file){
        .opened  = 1,
        .perms   = FILE_WRITABLE,
        .cfo     = SEEK_SET,
        .fs_type = 0,
        .lseek   = NULL,
        .write   = stdout_write,
        .read    = NULL,
        .path    = "stdout",
    };

    ret->fd_array[2] = (struct file){
        .opened  = 1,
        .perms   = FILE_WRITABLE,
        .cfo     = SEEK_SET,
        .fs_type = 0,
        .lseek   = NULL,
        .write   = stderr_write,
        .read    = NULL,
        .path    = "stderr",
    };

    return ret;
}

uint32_t get_fs_type(const char* filename) {
    uint32_t ret;
    if (memcmp(filename, "/fat32/", 7) == 0) {
        ret = FS_TYPE_FAT32;
    } else if (memcmp(filename, "/ext2/", 6) == 0) {
        ret = FS_TYPE_EXT2;
    } else {
        ret = -1;
    }
    return ret;
}

int32_t file_open(struct file* file, const char* path, int flags) {
    file->opened  = 1;
    file->perms   = flags;
    file->cfo     = 0;
    file->fs_type = get_fs_type(path);
    memcpy(file->path, path, strlen(path) + 1);

    if (file->fs_type == FS_TYPE_FAT32) {
        file->lseek      = fat32_lseek;
        file->write      = fat32_write;
        file->read       = fat32_read;
        file->fat32_file = fat32_open_file(path);
        // todo: check if fat32_file is valid (i.e. successfully opened) and return
    } else if (file->fs_type == FS_TYPE_EXT2) {
        printk(RED "Unsupport ext2\n" CLEAR);
        return -1;
    } else {
        printk(RED "Unknown fs type: %s\n" CLEAR, path);
        return -1;
    }
}