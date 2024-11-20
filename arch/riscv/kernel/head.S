    .extern start_kernel
    .section .text.init
    .globl _start
    .extern _traps

    .extern test_vm

    .equ VM_START, 0xffffffe000000000
    .equ PHY_START, 0x0000000080000000
    .equ PA2VA_OFFSET, (VM_START - PHY_START)
_start:
    # Initialize stack, setup_vm uses stack
    la sp, boot_stack_top

    call setup_vm
    call relocate

    # Init mm
    call mm_init

    call setup_vm_final

    # Init threads
    # Must init before timer interrupt is enabled
    # Otherwise might encounter null pointer dereference in schedule
    call task_init

    # set stvec = _traps
    la t0, _traps
    csrw stvec, t0

    # set sie[STIE] = 1
    li t0, 0b100000
    csrs sie, t0

    # set first time interrupt
    call clock_set_next_event

    # set sstatus[SIE] = 1, and enable interrupts
    csrs sstatus, 0b10

    # Jump to start_kernel
    call start_kernel

relocate:
    # set stvec
    la t0, tmp_stvec
    li t1, PA2VA_OFFSET
    add t0, t0, t1
    csrw stvec, t0

    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    li a0, PA2VA_OFFSET
    add ra, ra, a0
    add sp, sp, a0

    # t0 = PPN of early_pgtbl
    la a0, early_pgtbl
    srli a0, a0, 12
    la a1, 8 # SV39 mode
    slli a1, a1, 60
    or a0, a0, a1 # t0 ready for satp


    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    # set satp with early_pgtbl
    csrw satp, a0
tmp_stvec:
    ret

    .section .bss.stack
    .globl boot_stack

boot_stack:
    # Reserve 4 KiB stack
    .space 0x1000

    .globl boot_stack_top
boot_stack_top: