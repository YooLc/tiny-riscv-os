#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "sbi.h"

int start_kernel() {
    printk("2024 ZJU Operating System\n");

    schedule();

    while (true);
    return 0;
}
