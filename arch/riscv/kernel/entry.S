    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps

.equ task_struct_offset_thread, 32

.macro save_register id
    sd x\id, (\id * 8)(sp)
.endm

.macro load_register id
    ld x\id, (\id * 8)(sp)
.endm

_traps:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -(32 + 1) * 8
    .altmacro
    .set i, 0
    .rept 32
        save_register %i
        .set i, i + 1
    .endr
    csrr t0, sepc
    sd t0, (32 * 8)(sp)

    # 2. call trap_handler
    csrr a0, scause
    csrr a1, sepc
    call trap_handler

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld t0, (32 * 8)(sp)
    csrw sepc, t0
    load_register 1
    .set i, 3
    .rept 29
        load_register %i
        .set i, i + 1
    .endr
    load_register 2 # restore sp(x2)
    addi sp, sp, (32 + 1) * 8

    # 4. return from trap
    sret

    .extern dummy
    .globl __dummy
__dummy:
    # 1. set sepc to dummy()
    la t0, dummy
    csrw sepc, t0

    # 2. return fron s-mode
    sret

    .globl __switch_to
__switch_to:
    # save state to prev process
    sd s0, (task_struct_offset_thread + 8 * 2)(a0) # store callee-saved registers
    sd s1, (task_struct_offset_thread + 8 * 3)(a0)
    sd s2, (task_struct_offset_thread + 8 * 4)(a0)
    sd s3, (task_struct_offset_thread + 8 * 5)(a0)
    sd s4, (task_struct_offset_thread + 8 * 6)(a0)
    sd s5, (task_struct_offset_thread + 8 * 7)(a0)
    sd s6, (task_struct_offset_thread + 8 * 8)(a0)
    sd s7, (task_struct_offset_thread + 8 * 9)(a0)
    sd s8, (task_struct_offset_thread + 8 * 10)(a0)
    sd s9, (task_struct_offset_thread + 8 * 11)(a0)
    sd s10, (task_struct_offset_thread + 8 * 12)(a0)
    sd s11, (task_struct_offset_thread + 8 * 13)(a0)

    sd ra, task_struct_offset_thread(a0)
    sd sp, (task_struct_offset_thread + 8)(a0)

    # restore state from next process
    ld s0, (task_struct_offset_thread + 8 * 2)(a1) # restore callee-saved registers
    ld s1, (task_struct_offset_thread + 8 * 3)(a1)
    ld s2, (task_struct_offset_thread + 8 * 4)(a1)
    ld s3, (task_struct_offset_thread + 8 * 5)(a1)
    ld s4, (task_struct_offset_thread + 8 * 6)(a1)
    ld s5, (task_struct_offset_thread + 8 * 7)(a1)
    ld s6, (task_struct_offset_thread + 8 * 8)(a1)
    ld s7, (task_struct_offset_thread + 8 * 9)(a1)
    ld s8, (task_struct_offset_thread + 8 * 10)(a1)
    ld s9, (task_struct_offset_thread + 8 * 11)(a1)
    ld s10, (task_struct_offset_thread + 8 * 12)(a1)
    ld s11, (task_struct_offset_thread + 8 * 13)(a1)

    ld ra, task_struct_offset_thread(a1)
    ld sp, (task_struct_offset_thread + 8)(a1)
    ret