#ifndef __FS_H__
#define __FS_H__

#include "defs.h"

#define MAX_PATH_LENGTH     80
#define MAX_FILE_NUMBER     16

#define SEEK_SET            0
#define SEEK_CUR            1
#define SEEK_END            2

#define ERROR_FILE_NOT_OPEN 255

#define FILE_READABLE       0x1
#define FILE_WRITABLE       0x2

#define FS_TYPE_FAT32       0x1
#define FS_TYPE_EXT2        0x2

struct fat32_dir {
    uint32_t cluster;
    uint32_t index;  // entry index in the cluster
};

struct fat32_file {
    uint32_t cluster;
    struct fat32_dir dir;
};

struct file {                          // Opened file in a thread.
    uint32_t opened;                   // 文件是否打开
    uint32_t perms;                    // 文件的读写权限
    int64_t cfo;                       // 当前文件指针偏移量
    uint32_t fs_type;                  // 文件系统类型

    union {
        struct fat32_file fat32_file;  // 后续 FAT32 文件系统的文件需要的额外信息
    };

    int64_t (*lseek)(struct file* file, int64_t offset, uint64_t whence);  // 文件指针操作
    int64_t (*write)(struct file* file, const void* buf, uint64_t len);    // 写文件
    int64_t (*read)(struct file* file, void* buf, uint64_t len);           // 读文件

    char path[MAX_PATH_LENGTH];                                            // 文件路径
};

struct files_struct {
    struct file fd_array[MAX_FILE_NUMBER];
};
struct files_struct* file_init();
int32_t file_open(struct file* file, const char* path, int flags);
uint32_t get_fs_type(const char* filename);

#endif