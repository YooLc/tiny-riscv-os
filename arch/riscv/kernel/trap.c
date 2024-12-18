#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "stdint.h"
#include "syscall.h"
#include "vm.h"

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
                clock_set_next_event();
                do_timer();
                break;
        }
    } else {  // Exception
        switch (exception_code) {
            case SUPERVISOR_LOAD_PAGE_FAULT:
            case SUPERVISOR_STORE_PAGE_FAULT:
            case SUPERVISOR_INST_PAGE_FAULT:
                // Err("[S] Page Fault %llx, %llx at %p", interrupt, exception_code, sepc);
                do_page_fault(regs);
                break;
            case SUPERVISOR_ECALL_FROM_USER: syscall_handler(regs); break;
            default:
                Err("[S] Unknown interrupt/exception %llx, %llx at %p, stval=%llx", interrupt,
                    exception_code, sepc, csr_read(stval));
                break;
        }
    }
}