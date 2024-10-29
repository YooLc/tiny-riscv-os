#include "printk.h"
#include "sbi.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk("2024 ZJU Operating System\n");

    while (true);
    return 0;
}
