    .extern start_kernel
    .section .text.init
    .globl _start
    .extern _traps
_start:
    # Initialize stack
    la sp, boot_stack_top

    # set stvec = _traps
    la t0, _traps
    csrw stvec, t0

    # set sie[STIE] = 1
    li t0, 0b100000
    csrs sie, t0

    # set first time interrupt
    call clock_set_next_event

    # set sstatus[SIE] = 1
    csrs sstatus, 0b10

    # Jump to start_kernel
    call start_kernel

    .section .bss.stack
    .globl boot_stack
boot_stack:
    # Reserve 4 KiB stack
    .space 0x1000

    .globl boot_stack_top
boot_stack_top: