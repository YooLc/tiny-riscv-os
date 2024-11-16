#include "proc.h"

#include "defs.h"
#include "mm.h"
#include "printk.h"
#include "sbi.h"
#include "stdlib.h"

extern void __dummy();

struct task_struct* idle;            // idle process
struct task_struct* current;         // 指向当前运行线程的 task_struct
struct task_struct* task[NR_TASKS];  // 线程数组，所有的线程都保存在此

void task_init() {
    srand(2024);

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc(PGSIZE);

    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;

    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter  = 0;
    idle->priority = 0;

    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;

    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
    task[0] = idle;

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化

    // Well, i don't use reversed while-loop like Linus
    for (size_t i = 1; i < NR_TASKS; i++) {
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority
        // 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN,
        //     PRIORITY_MAX] 之间）
        task[i]           = (struct task_struct*)kalloc(PGSIZE);
        task[i]->state    = TASK_RUNNING;
        task[i]->counter  = 0;
        task[i]->priority = (rand() % (PRIORITY_MAX - PRIORITY_MIN + 1)) + PRIORITY_MIN;
        task[i]->pid      = i;

        // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址
        task[i]->thread.ra = (uint64_t)__dummy;
        task[i]->thread.sp = (uint64_t)((uint8_t*)task[i] + PGSIZE);
    }

    printk("...task_init done!\n");
}

#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    uint64_t MOD                = 1000000007;
    uint64_t auto_inc_local_var = 0;
    int last_counter            = -1;

    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
            if (current->counter == 1) {
                --(current->counter);  // forced the counter to be zero if this thread is
                                       // going to be scheduled
            }  // in case that the new counter is also 1, leading the information not
               // printed.
            last_counter       = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid,
                   auto_inc_local_var);

#if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
            if (tasks_output_index == MAX_OUTPUT) {
                for (int i = 0; i < MAX_OUTPUT; ++i) {
                    if (tasks_output[i] != expected_output[i]) {
                        printk("\033[31mTest failed!\033[0m\n");
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
                    }
                }
                printk(GREEN "Test passed!" CLEAR "\n");
                printk(GREEN "    Output: %s" CLEAR "\n", expected_output);
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
            }
#endif
        }
    }
}

extern void __switch_to(struct task_struct* prev, struct task_struct* next);

void switch_to(struct task_struct* next) {
    if (next == current) return;

    Log("Switching from %p (counter: %lld) to %p (counter: %lld)", current, current->counter, next,
        next->counter);
    // switch to next process
    struct task_struct* prev = current;
    current                  = next;
    __switch_to(prev, next);
}

void do_timer() {
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    if (current == idle || current->counter == 0) {
        Log("branch 0 switch to");
        schedule();
    } else {
        // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0
        // 则直接返回，否则进行调度
        current->counter--;
        Log("Thread running, reducing counter %lld", current->counter);
        if (current->counter == 0) {
            Log("branch 1 switch to");
            schedule();
        }
    }
}

void schedule() {
    Log("Scheduling threads");

    struct task_struct* next = idle;

    while (true) {
        // Find thread with largest counter
        for (size_t i = 1; i < NR_TASKS; i++) {
            if (task[i] == NULL || next == NULL) {
                Log(RED
                    "Kernel panic! You may be enabled timer interrupt before " "task_init!" CLEAR);
                Log(RED "task[%d] or next is NULL pointer" CLEAR, i);
                Log(RED "idle: %p" CLEAR, idle);
                sbi_system_reset(0, 0);
            }

            if (task[i]->counter <= next->counter) continue;
            next = task[i];
        }

        // If all running threads' counter are 0
        if (next == idle) {
            // Set their counter to their priority, and reschedule
            for (size_t i = 1; i < NR_TASKS; i++) {
                task[i]->counter = task[i]->priority;
                printk("SET [PID = %lld PRIORITY = %lld COUNTER = %lld]\n", i, task[i]->priority,
                       task[i]->counter);
            }
            continue;
        }
        break;
    }

    // Switch to next process
    Log(BLUE "switch to [PID = %lld PRIORITY = %lld COUNTER = %lld]" CLEAR, next->pid,
        next->priority, next->counter);
    switch_to(next);
}