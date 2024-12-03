#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "stdint.h"
#include "syscall.h"

#define SUPERVISOR_TIMER_INTERRUPT  5
#define SUPERVISOR_ECALL_FROM_USER  8
#define SUPERVISOR_INST_PAGE_FAULT  12
#define SUPERVISOR_LOAD_PAGE_FAULT  13
#define SUPERVISOR_STORE_PAGE_FAULT 15

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs* regs) {
    // 通过 `scause` 判断 trap 类型
    uint64_t interrupt      = (scause >> 63) & 0b1;
    uint64_t exception_code = (scause & 0x7FFFFFFF);

    // 如果是 interrupt 判断是否是 timer interrupt
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
    if (interrupt) {
        switch (exception_code) {
            case SUPERVISOR_TIMER_INTERRUPT:
            default:
                // Log("Timer Interrupt %llx, %llx", interrupt, exception_code);
                clock_set_next_event();
                do_timer();
                break;
        }
    } else {  // Exception
        switch (exception_code) {
            case SUPERVISOR_LOAD_PAGE_FAULT:
                Log("Load Page Fault %llx, %llx", interrupt, exception_code);
                break;
            case SUPERVISOR_STORE_PAGE_FAULT:
                Log("Store/AMO Page Fault %llx, %llx", interrupt, exception_code);
                break;
            case SUPERVISOR_INST_PAGE_FAULT:
                Log("Instruction Page Fault %llx, %llx", interrupt, exception_code);
                break;
            case SUPERVISOR_ECALL_FROM_USER:
                // Log("System Call from U-Mode %llx, %llx", interrupt, exception_code);
                syscall_handler(regs);
                break;
            default:
                Log("Unknown interrupt/exception %llx, %llx", interrupt, exception_code);
                break;
        }
    }
}