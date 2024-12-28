#include "string.h"

#include "stdint.h"

void memset(void* dest, int c, uint64_t n) {
    char* s = (char*)dest;
    for (uint64_t i = 0; i < n; ++i) {
        s[i] = c;
    }
}

void memcpy(void* dst, const void* src, uint64_t n) {
    uint8_t* d       = (uint8_t*)dst;
    const uint8_t* s = (const uint8_t*)src;
    for (uint64_t i = 0; i < n; ++i) {
        d[i] = s[i];
    }
}

void memmove(void* dst, const void* src, uint64_t n) {
    uint8_t* d       = (uint8_t*)dst;
    const uint8_t* s = (const uint8_t*)src;
    if (d < s) {
        memcpy(dst, src, n);
    } else {
        for (uint64_t i = n; i > 0; --i) {
            d[i - 1] = s[i - 1];
        }
    }
}

int memcmp(const void* s1, const void* s2, uint64_t n) {
    const uint8_t* u1 = (const uint8_t*)s1;
    const uint8_t* u2 = (const uint8_t*)s2;
    for (uint64_t i = 0; i < n; ++i) {
        if (u1[i] != u2[i]) {
            return u1[i] < u2[i] ? -1 : 1;
        }
    }
    return 0;
}

size_t strlen(const char* s) {
    size_t len = 0;
    while (s[len]) {
        len++;
    }
    return len;
}