#include "printk.h"
#include "sbi.h"
#include "defs.h"

extern void test();

int start_kernel() {
    printk("2024");
    printk(" ZJU Operating System\n");

    // printk("sstatus: 0x%x\n", csr_read(sstatus));

    // printk("sscratch before: 0x%x\n", csr_read(sscratch));
    // csr_write(sscratch, 0x19268017);
    // printk("sscratch after:  0x%x\n", csr_read(sscratch));

    test();
    return 0;
}
