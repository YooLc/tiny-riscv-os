#ifndef __STRING_H__
#define __STRING_H__

#include <stddef.h>

#include "stdint.h"

void memset(void*, int, uint64_t);
void memcpy(void*, const void*, uint64_t);
void memmove(void*, const void*, uint64_t);
int memcmp(const void*, const void*, uint64_t);
size_t strlen(const char*);

#endif
