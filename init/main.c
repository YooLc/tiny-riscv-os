#include "printk.h"
#include "sbi.h"
#include "defs.h"

int start_kernel() {
    printk("2024 ZJU Operating System\n");

    while (true);
    return 0;
}
