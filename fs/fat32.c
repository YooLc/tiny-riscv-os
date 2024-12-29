#include "fat32.h"

#include "mbr.h"
#include "mm.h"
#include "printk.h"
#include "string.h"
#include "virtio.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

struct fat32_bpb fat32_header;
struct fat32_volume fat32_volume;

uint8_t fat32_buf[VIRTIO_BLK_SECTOR_SIZE];
uint8_t fat32_table_buf[VIRTIO_BLK_SECTOR_SIZE];

uint64_t cluster_to_sector(uint64_t cluster) {
    return (cluster - 2) * fat32_volume.sec_per_cluster + fat32_volume.first_data_sec;
}

uint32_t next_cluster(uint64_t cluster) {
    uint64_t fat_offset = cluster * 4;
    uint64_t fat_sector = fat32_volume.first_fat_sec + fat_offset / VIRTIO_BLK_SECTOR_SIZE;
    virtio_blk_read_sector(fat_sector, fat32_table_buf);
    int index_in_sector = fat_offset % (VIRTIO_BLK_SECTOR_SIZE / sizeof(uint32_t));
    return *(uint32_t*)(fat32_table_buf + index_in_sector);
}

void fat32_init(uint64_t lba, uint64_t size) {
    virtio_blk_read_sector(lba, (void*)&fat32_header);  // 从第 lba 个扇区读取 FAT32 BPB

    fat32_volume.first_fat_sec = lba + fat32_header.rsvd_sec_cnt;  // 记录第一个 FAT 表所在的扇区号
    fat32_volume.sec_per_cluster = fat32_header.sec_per_clus;  // 每个簇的扇区数

    // For FAT32, fat_sz32 is used, and fat_sz16 is 0.
    fat32_volume.first_data_sec
        = fat32_volume.first_fat_sec
          + (fat32_header.num_fats * fat32_header.fat_sz32);  // 记录第一个数据簇所在的扇区号
    fat32_volume.fat_sz = fat32_header.fat_sz32;  // 记录每个 FAT 表占的扇区数（并未用到）

    Log(YELLOW "FAT32:" BLUE
               " first_fat_sec = %x, sec_per_cluster = %x, first_data_sec = %x, fat_sz = %x",
        fat32_volume.first_fat_sec, fat32_volume.sec_per_cluster, fat32_volume.first_data_sec,
        fat32_volume.fat_sz);
}

int is_fat32(uint64_t lba) {
    virtio_blk_read_sector(lba, (void*)&fat32_header);
    if (fat32_header.boot_sector_signature != 0xaa55) {
        return 0;
    }
    return 1;
}

int next_slash(const char* path) {  // util function to be used in fat32_open_file
    int i = 0;
    while (path[i] != '\0' && path[i] != '/') {
        i++;
    }
    if (path[i] == '\0') {
        return -1;
    }
    return i;
}

void to_upper_case(char* str) {  // util function to be used in fat32_open_file
    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] >= 'a' && str[i] <= 'z') {
            str[i] -= 32;
        }
    }
}

#define FAT_DIRENT_NEVER_USED 0x00
#define FAT_DIRENT_DELETED    0xe5
#define FAT_DIRENT_DIRECTORY  0x2e  // Not used in this lab

struct fat32_file fat32_open_file(const char* path) {
    struct fat32_file file;
    /* todo: open the file according to path */
    to_upper_case(path);
    char filename[9] = "        ";
    for (size_t i = 0; i < 8; i++) {
        if (path[i + 7] == '\0') break;
        filename[i] = path[i + 7];  // "/fat32/"
    }

    virtio_blk_read_sector(fat32_volume.first_data_sec, fat32_buf);

    size_t entry = 0;
    for (struct fat32_dir_entry* entry_ptr = (struct fat32_dir_entry*)fat32_buf;
         *(uint8_t*)entry_ptr != FAT_DIRENT_NEVER_USED; entry++, entry_ptr++) {
        if (*(uint8_t*)entry_ptr == FAT_DIRENT_DELETED) continue;
        if (memcmp(entry_ptr->name, filename, 8) == 0) {
            file.cluster     = entry_ptr->starthi << 16 | entry_ptr->startlow;
            file.dir.cluster = 2;  // Root directory
            file.dir.index   = entry;
            break;
        }
    }
    Log("file: %s, cluster: %x, dir.cluster: %x, dir.index: %x", filename, file.cluster,
        file.dir.cluster, file.dir.index);
    return file;
}

int64_t fat32_lseek(struct file* file, int64_t offset, uint64_t whence) {
    /* Calculate file length */
    size_t sector = cluster_to_sector(file->fat32_file.dir.cluster);
    virtio_blk_read_sector(sector, fat32_buf);

    struct fat32_dir_entry* dentry
        = (struct fat32_dir_entry*)fat32_buf + file->fat32_file.dir.index;
    uint32_t size = dentry->size;

    if (whence == SEEK_SET) {
        file->cfo = offset;
    } else if (whence == SEEK_CUR) {
        file->cfo = file->cfo + offset;
    } else if (whence == SEEK_END) {
        // Set cfo to the end of the file
        file->cfo = size + offset;
    } else {
        Err("fat32_lseek: whence not implemented\n");
    }

    file->cfo = max(0, file->cfo);
    file->cfo = min(size, file->cfo);
    return file->cfo;
}

uint64_t fat32_table_sector_of_cluster(uint32_t cluster) {
    return fat32_volume.first_fat_sec + cluster / (VIRTIO_BLK_SECTOR_SIZE / sizeof(uint32_t));
}

int64_t fat32_read(struct file* file, void* buf, uint64_t len) {
    // Read dir entry
    size_t sector = cluster_to_sector(file->fat32_file.dir.cluster);
    virtio_blk_read_sector(sector, fat32_buf);

    struct fat32_dir_entry* dentry
        = (struct fat32_dir_entry*)fat32_buf + file->fat32_file.dir.index;
    uint32_t size = dentry->size;
    uint64_t cfo  = file->cfo;

    if (file->cfo >= size) return 0;

    // Prepare to read
    uint64_t read_cfo = 0, read_len = 0;
    uint64_t max_cfo = cfo + min(len, size - cfo);

    virtio_blk_read_sector(fat32_volume.first_fat_sec, fat32_table_buf);
    for (uint32_t cluster = file->fat32_file.cluster;
         cluster < 0x0ffffff8;                                 // 0x0ffffff8: end of cluster chain
         cluster = *((uint32_t*)fat32_table_buf + cluster)) {  // Next cluster
        // Iterate through sectors in the cluster
        for (uint32_t sector = 0; sector < fat32_volume.sec_per_cluster; sector++) {
            Log("reading cluster: %x, sector: %x", cluster, sector);
            if (read_cfo + VIRTIO_BLK_SECTOR_SIZE <= cfo) {
                read_cfo += VIRTIO_BLK_SECTOR_SIZE;
                continue;
            } else if (read_cfo >= max_cfo) {
                break;
            }

            read_cfo += cfo - read_cfo;  // keep track with file->cfo
            uint64_t sec_offset        = (read_cfo % VIRTIO_BLK_SECTOR_SIZE);
            uint64_t content_left_sec  = VIRTIO_BLK_SECTOR_SIZE - sec_offset;
            uint64_t content_left_read = max_cfo - read_cfo;

            uint64_t copy_len = min(content_left_sec, content_left_read);
            virtio_blk_read_sector(cluster_to_sector(cluster) + sector, fat32_buf);
            memcpy(buf + read_len, fat32_buf + sec_offset, copy_len);
            read_len += copy_len;
            read_cfo += copy_len;
            cfo = read_cfo;
        }

        if (read_cfo >= max_cfo) break;
    }

    file->cfo = cfo;
    return read_len;
}

int64_t fat32_write(struct file* file, const void* buf, uint64_t len) {
    // Read dir entry
    size_t sector = cluster_to_sector(file->fat32_file.dir.cluster);
    virtio_blk_read_sector(sector, fat32_buf);

    struct fat32_dir_entry* dentry
        = (struct fat32_dir_entry*)fat32_buf + file->fat32_file.dir.index;
    uint32_t size = dentry->size;
    uint64_t cfo  = file->cfo;

    if (file->cfo >= size) return 0;

    // Prepare to write
    uint64_t write_cfo = 0, write_len = 0;
    uint64_t max_cfo = cfo + min(len, size - cfo);

    virtio_blk_read_sector(fat32_volume.first_fat_sec, fat32_table_buf);
    for (uint32_t cluster = file->fat32_file.cluster;
         cluster < 0x0ffffff8;                                 // 0x0ffffff8: end of cluster chain
         cluster = *((uint32_t*)fat32_table_buf + cluster)) {  // Next cluster
        // Iterate through sectors in the cluster
        for (uint32_t sector = 0; sector < fat32_volume.sec_per_cluster; sector++) {
            Log("reading cluster: %x, sector: %x", cluster, sector);
            if (write_cfo + VIRTIO_BLK_SECTOR_SIZE <= cfo) {
                write_cfo += VIRTIO_BLK_SECTOR_SIZE;
                continue;
            } else if (write_cfo >= max_cfo) {
                break;
            }

            write_cfo += cfo - write_cfo;  // keep track with file->cfo
            uint64_t sec_offset         = (write_cfo % VIRTIO_BLK_SECTOR_SIZE);
            uint64_t content_left_sec   = VIRTIO_BLK_SECTOR_SIZE - sec_offset;
            uint64_t content_left_write = max_cfo - write_cfo;

            uint64_t copy_len = min(content_left_sec, content_left_write);
            virtio_blk_read_sector(cluster_to_sector(cluster) + sector, fat32_buf);
            memcpy(fat32_buf + sec_offset, buf + write_len, copy_len);
            virtio_blk_write_sector(cluster_to_sector(cluster) + sector, fat32_buf);
            write_len += copy_len;
            write_cfo += copy_len;
            cfo = write_cfo;
        }

        if (write_cfo >= max_cfo) break;
    }

    file->cfo = cfo;
    return write_len;
}