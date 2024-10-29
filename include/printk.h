#ifndef __PRINTK_H__
#define __PRINTK_H__

#include "stddef.h"

#define bool _Bool
#define true 1
#define false 0

#define RED "\033[31m"
#define GREEN "\033[1;38;2;119;221;119m"
#define YELLOW "\033[1;38;2;255;221;136m"
#define BLUE "\033[1;38;2;119;187;221m"
#define PINK "\033[1;38;2;255;136;153m"
#define DEEPGREEN "\033[36m"
#define CLEAR "\033[0m"

#define Log(format, ...) \
    printk(BLUE "[%s, %s, %d] " format CLEAR "\n", \
        __func__, __FILE__, __LINE__, ## __VA_ARGS__)

int printk(const char *, ...);

#endif