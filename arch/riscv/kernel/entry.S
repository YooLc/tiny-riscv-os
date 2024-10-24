    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps

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