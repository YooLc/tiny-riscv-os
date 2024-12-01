#include "string.h"

#include "stdint.h"

void* memset(void* dest, int c, uint64_t n) {
    char* s = (char*)dest;
    for (uint64_t i = 0; i < n; ++i) {
        s[i] = c;
    }
    return dest;
}

void* memcpy(void* dst, const void* src, uint64_t n) {
    uint8_t* d       = (uint8_t*)dst;
    const uint8_t* s = (const uint8_t*)src;
    for (uint64_t i = 0; i < n; ++i) {
        d[i] = s[i];
    }
    return dst;
}

void* memmove(void* dst, const void* src, uint64_t n) {
    uint8_t* d       = (uint8_t*)dst;
    const uint8_t* s = (const uint8_t*)src;
    if (d < s) {
        memcpy(dst, src, n);
    } else {
        for (uint64_t i = n; i > 0; --i) {
            d[i - 1] = s[i - 1];
        }
    }
    return dst;
}