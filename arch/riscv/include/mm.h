#ifndef __MM_H__
#define __MM_H__

#include "stdint.h"

struct run {
    struct run* next;
};

void mm_init();

void* kalloc();
void kfree(void*);

struct buddy {
    uint64_t size;
    uint64_t* bitmap;
    uint64_t* ref_cnt;
};

uint64_t get_page(void*);         // 增加计数
void put_page(void*);             // 减少计数
uint64_t get_page_refcnt(void*);  // 获取计数

void buddy_init();
uint64_t buddy_alloc(uint64_t);
void buddy_free(uint64_t);

void* alloc_pages(uint64_t);
void* alloc_page();
void free_pages(void*);

#endif