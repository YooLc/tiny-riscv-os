
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .equ VM_START, 0xffffffe000000000
    .equ PHY_START, 0x0000000080000000
    .equ PA2VA_OFFSET, (VM_START - PHY_START)
_start:
    # Initialize stack, setup_vm uses stack
    la sp, boot_stack_top
ffffffe000200000:	00009117          	auipc	sp,0x9
ffffffe000200004:	00010113          	mv	sp,sp

    call setup_vm
ffffffe000200008:	0cd010ef          	jal	ffffffe0002018d4 <setup_vm>
    call relocate
ffffffe00020000c:	030000ef          	jal	ffffffe00020003c <relocate>

    # Init mm
    call mm_init
ffffffe000200010:	259000ef          	jal	ffffffe000200a68 <mm_init>

    call setup_vm_final
ffffffe000200014:	52d010ef          	jal	ffffffe000201d40 <setup_vm_final>

    # Init threads
    # Must init before timer interrupt is enabled
    # Otherwise might encounter null pointer dereference in schedule
    call task_init
ffffffe000200018:	285000ef          	jal	ffffffe000200a9c <task_init>

    # set stvec = _traps
    la t0, _traps
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	06c28293          	addi	t0,t0,108 # ffffffe000200088 <_traps>
    csrw stvec, t0
ffffffe000200024:	10529073          	csrw	stvec,t0

    # set sie[STIE] = 1
    li t0, 0b100000
ffffffe000200028:	02000293          	li	t0,32
    csrs sie, t0
ffffffe00020002c:	1042a073          	csrs	sie,t0

    # set first time interrupt
    call clock_set_next_event
ffffffe000200030:	288000ef          	jal	ffffffe0002002b8 <clock_set_next_event>

    # set sstatus[SIE] = 1, and enable interrupts
    csrs sstatus, 0b10
ffffffe000200034:	10016073          	csrsi	sstatus,2

    # Jump to start_kernel
    call start_kernel
ffffffe000200038:	6f5010ef          	jal	ffffffe000201f2c <start_kernel>

ffffffe00020003c <relocate>:

relocate:
    # set stvec
    la t0, tmp_stvec
ffffffe00020003c:	00000297          	auipc	t0,0x0
ffffffe000200040:	04828293          	addi	t0,t0,72 # ffffffe000200084 <tmp_stvec>
    li t1, PA2VA_OFFSET
ffffffe000200044:	fbf0031b          	addiw	t1,zero,-65
ffffffe000200048:	01f31313          	slli	t1,t1,0x1f
    add t0, t0, t1
ffffffe00020004c:	006282b3          	add	t0,t0,t1
    csrw stvec, t0
ffffffe000200050:	10529073          	csrw	stvec,t0

    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    li a0, PA2VA_OFFSET
ffffffe000200054:	fbf0051b          	addiw	a0,zero,-65
ffffffe000200058:	01f51513          	slli	a0,a0,0x1f
    add ra, ra, a0
ffffffe00020005c:	00a080b3          	add	ra,ra,a0
    add sp, sp, a0
ffffffe000200060:	00a10133          	add	sp,sp,a0

    # t0 = PPN of early_pgtbl
    la a0, early_pgtbl
ffffffe000200064:	0000a517          	auipc	a0,0xa
ffffffe000200068:	f9c50513          	addi	a0,a0,-100 # ffffffe00020a000 <early_pgtbl>
    srli a0, a0, 12
ffffffe00020006c:	00c55513          	srli	a0,a0,0xc
    la a1, 8 # SV39 mode
ffffffe000200070:	0080059b          	addiw	a1,zero,8
    slli a1, a1, 60
ffffffe000200074:	03c59593          	slli	a1,a1,0x3c
    or a0, a0, a1 # t0 ready for satp
ffffffe000200078:	00b56533          	or	a0,a0,a1


    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero
ffffffe00020007c:	12000073          	sfence.vma

    # set satp with early_pgtbl
    csrw satp, a0
ffffffe000200080:	18051073          	csrw	satp,a0

ffffffe000200084 <tmp_stvec>:
tmp_stvec:
    ret
ffffffe000200084:	00008067          	ret

ffffffe000200088 <_traps>:
1:
.endm

_traps:
    # 0. switch to kernel stack
    switch_stack
ffffffe000200088:	140022f3          	csrr	t0,sscratch
ffffffe00020008c:	00029663          	bnez	t0,ffffffe000200098 <_traps+0x10>
ffffffe000200090:	14011073          	csrw	sscratch,sp
ffffffe000200094:	00028113          	mv	sp,t0

    # 1. save 32 registers and sepc to stack
    addi sp, sp, -(32 + 1) * 8
ffffffe000200098:	ef810113          	addi	sp,sp,-264 # ffffffe000208ef8 <_sbss+0xef8>
    .altmacro
    .set i, 0
    .rept 32
        save_register %i
ffffffe00020009c:	00013023          	sd	zero,0(sp)
ffffffe0002000a0:	00113423          	sd	ra,8(sp)
ffffffe0002000a4:	00213823          	sd	sp,16(sp)
ffffffe0002000a8:	00313c23          	sd	gp,24(sp)
ffffffe0002000ac:	02413023          	sd	tp,32(sp)
ffffffe0002000b0:	02513423          	sd	t0,40(sp)
ffffffe0002000b4:	02613823          	sd	t1,48(sp)
ffffffe0002000b8:	02713c23          	sd	t2,56(sp)
ffffffe0002000bc:	04813023          	sd	s0,64(sp)
ffffffe0002000c0:	04913423          	sd	s1,72(sp)
ffffffe0002000c4:	04a13823          	sd	a0,80(sp)
ffffffe0002000c8:	04b13c23          	sd	a1,88(sp)
ffffffe0002000cc:	06c13023          	sd	a2,96(sp)
ffffffe0002000d0:	06d13423          	sd	a3,104(sp)
ffffffe0002000d4:	06e13823          	sd	a4,112(sp)
ffffffe0002000d8:	06f13c23          	sd	a5,120(sp)
ffffffe0002000dc:	09013023          	sd	a6,128(sp)
ffffffe0002000e0:	09113423          	sd	a7,136(sp)
ffffffe0002000e4:	09213823          	sd	s2,144(sp)
ffffffe0002000e8:	09313c23          	sd	s3,152(sp)
ffffffe0002000ec:	0b413023          	sd	s4,160(sp)
ffffffe0002000f0:	0b513423          	sd	s5,168(sp)
ffffffe0002000f4:	0b613823          	sd	s6,176(sp)
ffffffe0002000f8:	0b713c23          	sd	s7,184(sp)
ffffffe0002000fc:	0d813023          	sd	s8,192(sp)
ffffffe000200100:	0d913423          	sd	s9,200(sp)
ffffffe000200104:	0da13823          	sd	s10,208(sp)
ffffffe000200108:	0db13c23          	sd	s11,216(sp)
ffffffe00020010c:	0fc13023          	sd	t3,224(sp)
ffffffe000200110:	0fd13423          	sd	t4,232(sp)
ffffffe000200114:	0fe13823          	sd	t5,240(sp)
ffffffe000200118:	0ff13c23          	sd	t6,248(sp)
        .set i, i + 1
    .endr
    csrr t0, sepc
ffffffe00020011c:	141022f3          	csrr	t0,sepc
    sd t0, (32 * 8)(sp)
ffffffe000200120:	10513023          	sd	t0,256(sp)

    # 2. call trap_handler
    csrr a0, scause
ffffffe000200124:	14202573          	csrr	a0,scause
    csrr a1, sepc
ffffffe000200128:	141025f3          	csrr	a1,sepc
    call trap_handler
ffffffe00020012c:	638010ef          	jal	ffffffe000201764 <trap_handler>

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld t0, (32 * 8)(sp)
ffffffe000200130:	10013283          	ld	t0,256(sp)
    csrw sepc, t0
ffffffe000200134:	14129073          	csrw	sepc,t0
    load_register 1
ffffffe000200138:	00813083          	ld	ra,8(sp)
    .set i, 3
    .rept 29
        load_register %i
ffffffe00020013c:	01813183          	ld	gp,24(sp)
ffffffe000200140:	02013203          	ld	tp,32(sp)
ffffffe000200144:	02813283          	ld	t0,40(sp)
ffffffe000200148:	03013303          	ld	t1,48(sp)
ffffffe00020014c:	03813383          	ld	t2,56(sp)
ffffffe000200150:	04013403          	ld	s0,64(sp)
ffffffe000200154:	04813483          	ld	s1,72(sp)
ffffffe000200158:	05013503          	ld	a0,80(sp)
ffffffe00020015c:	05813583          	ld	a1,88(sp)
ffffffe000200160:	06013603          	ld	a2,96(sp)
ffffffe000200164:	06813683          	ld	a3,104(sp)
ffffffe000200168:	07013703          	ld	a4,112(sp)
ffffffe00020016c:	07813783          	ld	a5,120(sp)
ffffffe000200170:	08013803          	ld	a6,128(sp)
ffffffe000200174:	08813883          	ld	a7,136(sp)
ffffffe000200178:	09013903          	ld	s2,144(sp)
ffffffe00020017c:	09813983          	ld	s3,152(sp)
ffffffe000200180:	0a013a03          	ld	s4,160(sp)
ffffffe000200184:	0a813a83          	ld	s5,168(sp)
ffffffe000200188:	0b013b03          	ld	s6,176(sp)
ffffffe00020018c:	0b813b83          	ld	s7,184(sp)
ffffffe000200190:	0c013c03          	ld	s8,192(sp)
ffffffe000200194:	0c813c83          	ld	s9,200(sp)
ffffffe000200198:	0d013d03          	ld	s10,208(sp)
ffffffe00020019c:	0d813d83          	ld	s11,216(sp)
ffffffe0002001a0:	0e013e03          	ld	t3,224(sp)
ffffffe0002001a4:	0e813e83          	ld	t4,232(sp)
ffffffe0002001a8:	0f013f03          	ld	t5,240(sp)
ffffffe0002001ac:	0f813f83          	ld	t6,248(sp)
        .set i, i + 1
    .endr
    load_register 2 # restore sp(x2)
ffffffe0002001b0:	01013103          	ld	sp,16(sp)
    addi sp, sp, (32 + 1) * 8
ffffffe0002001b4:	10810113          	addi	sp,sp,264

    # 4. switch back to user stack
    switch_stack
ffffffe0002001b8:	140022f3          	csrr	t0,sscratch
ffffffe0002001bc:	00029663          	bnez	t0,ffffffe0002001c8 <_traps+0x140>
ffffffe0002001c0:	14011073          	csrw	sscratch,sp
ffffffe0002001c4:	00028113          	mv	sp,t0

    # 5. return from trap
    sret
ffffffe0002001c8:	10200073          	sret

ffffffe0002001cc <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:
    # 1. set sepc to dummy()
    la t0, dummy
ffffffe0002001cc:	00001297          	auipc	t0,0x1
ffffffe0002001d0:	c8828293          	addi	t0,t0,-888 # ffffffe000200e54 <dummy>
    csrw sepc, t0
ffffffe0002001d4:	14129073          	csrw	sepc,t0

    # 2. swap sp (kernel stack) and sscratch (user stack)
    switch_stack
ffffffe0002001d8:	140022f3          	csrr	t0,sscratch
ffffffe0002001dc:	00029663          	bnez	t0,ffffffe0002001e8 <__dummy+0x1c>
ffffffe0002001e0:	14011073          	csrw	sscratch,sp
ffffffe0002001e4:	00028113          	mv	sp,t0

    # 3. return fron s-mode
    sret
ffffffe0002001e8:	10200073          	sret

ffffffe0002001ec <__switch_to>:

    .globl __switch_to
__switch_to:
    # save state to prev process
    sd s0, (task_struct_offset_thread + 8 * 2)(a0) # store callee-saved registers
ffffffe0002001ec:	02853823          	sd	s0,48(a0)
    sd s1, (task_struct_offset_thread + 8 * 3)(a0)
ffffffe0002001f0:	02953c23          	sd	s1,56(a0)
    sd s2, (task_struct_offset_thread + 8 * 4)(a0)
ffffffe0002001f4:	05253023          	sd	s2,64(a0)
    sd s3, (task_struct_offset_thread + 8 * 5)(a0)
ffffffe0002001f8:	05353423          	sd	s3,72(a0)
    sd s4, (task_struct_offset_thread + 8 * 6)(a0)
ffffffe0002001fc:	05453823          	sd	s4,80(a0)
    sd s5, (task_struct_offset_thread + 8 * 7)(a0)
ffffffe000200200:	05553c23          	sd	s5,88(a0)
    sd s6, (task_struct_offset_thread + 8 * 8)(a0)
ffffffe000200204:	07653023          	sd	s6,96(a0)
    sd s7, (task_struct_offset_thread + 8 * 9)(a0)
ffffffe000200208:	07753423          	sd	s7,104(a0)
    sd s8, (task_struct_offset_thread + 8 * 10)(a0)
ffffffe00020020c:	07853823          	sd	s8,112(a0)
    sd s9, (task_struct_offset_thread + 8 * 11)(a0)
ffffffe000200210:	07953c23          	sd	s9,120(a0)
    sd s10, (task_struct_offset_thread + 8 * 12)(a0)
ffffffe000200214:	09a53023          	sd	s10,128(a0)
    sd s11, (task_struct_offset_thread + 8 * 13)(a0)
ffffffe000200218:	09b53423          	sd	s11,136(a0)

    sd ra, task_struct_offset_thread(a0)
ffffffe00020021c:	02153023          	sd	ra,32(a0)
    sd sp, (task_struct_offset_thread + 8)(a0)
ffffffe000200220:	02253423          	sd	sp,40(a0)

    # store sepc, sstatus and sscratch
    csrr t0, sepc
ffffffe000200224:	141022f3          	csrr	t0,sepc
    csrr t1, sstatus
ffffffe000200228:	10002373          	csrr	t1,sstatus
    csrr t2, sscratch
ffffffe00020022c:	140023f3          	csrr	t2,sscratch
    sd t0, (task_struct_offset_thread + 8 * 14)(a0)
ffffffe000200230:	08553823          	sd	t0,144(a0)
    sd t1, (task_struct_offset_thread + 8 * 15)(a0)
ffffffe000200234:	08653c23          	sd	t1,152(a0)
    sd t2, (task_struct_offset_thread + 8 * 16)(a0)
ffffffe000200238:	0a753023          	sd	t2,160(a0)

    # restore state from next process
    ld s0, (task_struct_offset_thread + 8 * 2)(a1) # restore callee-saved registers
ffffffe00020023c:	0305b403          	ld	s0,48(a1)
    ld s1, (task_struct_offset_thread + 8 * 3)(a1)
ffffffe000200240:	0385b483          	ld	s1,56(a1)
    ld s2, (task_struct_offset_thread + 8 * 4)(a1)
ffffffe000200244:	0405b903          	ld	s2,64(a1)
    ld s3, (task_struct_offset_thread + 8 * 5)(a1)
ffffffe000200248:	0485b983          	ld	s3,72(a1)
    ld s4, (task_struct_offset_thread + 8 * 6)(a1)
ffffffe00020024c:	0505ba03          	ld	s4,80(a1)
    ld s5, (task_struct_offset_thread + 8 * 7)(a1)
ffffffe000200250:	0585ba83          	ld	s5,88(a1)
    ld s6, (task_struct_offset_thread + 8 * 8)(a1)
ffffffe000200254:	0605bb03          	ld	s6,96(a1)
    ld s7, (task_struct_offset_thread + 8 * 9)(a1)
ffffffe000200258:	0685bb83          	ld	s7,104(a1)
    ld s8, (task_struct_offset_thread + 8 * 10)(a1)
ffffffe00020025c:	0705bc03          	ld	s8,112(a1)
    ld s9, (task_struct_offset_thread + 8 * 11)(a1)
ffffffe000200260:	0785bc83          	ld	s9,120(a1)
    ld s10, (task_struct_offset_thread + 8 * 12)(a1)
ffffffe000200264:	0805bd03          	ld	s10,128(a1)
    ld s11, (task_struct_offset_thread + 8 * 13)(a1)
ffffffe000200268:	0885bd83          	ld	s11,136(a1)

    # restore sepc, sstatus and sscratch
    ld t0, (task_struct_offset_thread + 8 * 14)(a1)
ffffffe00020026c:	0905b283          	ld	t0,144(a1)
    ld t1, (task_struct_offset_thread + 8 * 15)(a1)
ffffffe000200270:	0985b303          	ld	t1,152(a1)
    ld t2, (task_struct_offset_thread + 8 * 16)(a1)
ffffffe000200274:	0a05b383          	ld	t2,160(a1)
    csrw sepc, t0
ffffffe000200278:	14129073          	csrw	sepc,t0
    csrw sstatus, t1
ffffffe00020027c:	10031073          	csrw	sstatus,t1
    csrw sscratch, t2
ffffffe000200280:	14039073          	csrw	sscratch,t2

    ld ra, task_struct_offset_thread(a1)
ffffffe000200284:	0205b083          	ld	ra,32(a1)
    ld sp, (task_struct_offset_thread + 8)(a1)
ffffffe000200288:	0285b103          	ld	sp,40(a1)
ffffffe00020028c:	00008067          	ret

ffffffe000200290 <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 5000000;

uint64_t get_cycles() {
ffffffe000200290:	fe010113          	addi	sp,sp,-32
ffffffe000200294:	00813c23          	sd	s0,24(sp)
ffffffe000200298:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    asm volatile(
ffffffe00020029c:	c01027f3          	rdtime	a5
ffffffe0002002a0:	fef43423          	sd	a5,-24(s0)
        "rdtime %[cycles]\n"
        : [cycles] "=r" (cycles)
        : :);
    return cycles;
ffffffe0002002a4:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002002a8:	00078513          	mv	a0,a5
ffffffe0002002ac:	01813403          	ld	s0,24(sp)
ffffffe0002002b0:	02010113          	addi	sp,sp,32
ffffffe0002002b4:	00008067          	ret

ffffffe0002002b8 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe0002002b8:	fe010113          	addi	sp,sp,-32
ffffffe0002002bc:	00113c23          	sd	ra,24(sp)
ffffffe0002002c0:	00813823          	sd	s0,16(sp)
ffffffe0002002c4:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe0002002c8:	fc9ff0ef          	jal	ffffffe000200290 <get_cycles>
ffffffe0002002cc:	00050713          	mv	a4,a0
ffffffe0002002d0:	00005797          	auipc	a5,0x5
ffffffe0002002d4:	d3078793          	addi	a5,a5,-720 # ffffffe000205000 <TIMECLOCK>
ffffffe0002002d8:	0007b783          	ld	a5,0(a5)
ffffffe0002002dc:	00f707b3          	add	a5,a4,a5
ffffffe0002002e0:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe0002002e4:	fe843503          	ld	a0,-24(s0)
ffffffe0002002e8:	19c010ef          	jal	ffffffe000201484 <sbi_set_timer>
ffffffe0002002ec:	00000013          	nop
ffffffe0002002f0:	01813083          	ld	ra,24(sp)
ffffffe0002002f4:	01013403          	ld	s0,16(sp)
ffffffe0002002f8:	02010113          	addi	sp,sp,32
ffffffe0002002fc:	00008067          	ret

ffffffe000200300 <fixsize>:
#define MAX(a, b) ((a) > (b) ? (a) : (b))

void *free_page_start = &_ekernel;
struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
ffffffe000200300:	fe010113          	addi	sp,sp,-32
ffffffe000200304:	00813c23          	sd	s0,24(sp)
ffffffe000200308:	02010413          	addi	s0,sp,32
ffffffe00020030c:	fea43423          	sd	a0,-24(s0)
    size --;
ffffffe000200310:	fe843783          	ld	a5,-24(s0)
ffffffe000200314:	fff78793          	addi	a5,a5,-1
ffffffe000200318:	fef43423          	sd	a5,-24(s0)
    size |= size >> 1;
ffffffe00020031c:	fe843783          	ld	a5,-24(s0)
ffffffe000200320:	0017d793          	srli	a5,a5,0x1
ffffffe000200324:	fe843703          	ld	a4,-24(s0)
ffffffe000200328:	00f767b3          	or	a5,a4,a5
ffffffe00020032c:	fef43423          	sd	a5,-24(s0)
    size |= size >> 2;
ffffffe000200330:	fe843783          	ld	a5,-24(s0)
ffffffe000200334:	0027d793          	srli	a5,a5,0x2
ffffffe000200338:	fe843703          	ld	a4,-24(s0)
ffffffe00020033c:	00f767b3          	or	a5,a4,a5
ffffffe000200340:	fef43423          	sd	a5,-24(s0)
    size |= size >> 4;
ffffffe000200344:	fe843783          	ld	a5,-24(s0)
ffffffe000200348:	0047d793          	srli	a5,a5,0x4
ffffffe00020034c:	fe843703          	ld	a4,-24(s0)
ffffffe000200350:	00f767b3          	or	a5,a4,a5
ffffffe000200354:	fef43423          	sd	a5,-24(s0)
    size |= size >> 8;
ffffffe000200358:	fe843783          	ld	a5,-24(s0)
ffffffe00020035c:	0087d793          	srli	a5,a5,0x8
ffffffe000200360:	fe843703          	ld	a4,-24(s0)
ffffffe000200364:	00f767b3          	or	a5,a4,a5
ffffffe000200368:	fef43423          	sd	a5,-24(s0)
    size |= size >> 16;
ffffffe00020036c:	fe843783          	ld	a5,-24(s0)
ffffffe000200370:	0107d793          	srli	a5,a5,0x10
ffffffe000200374:	fe843703          	ld	a4,-24(s0)
ffffffe000200378:	00f767b3          	or	a5,a4,a5
ffffffe00020037c:	fef43423          	sd	a5,-24(s0)
    size |= size >> 32;
ffffffe000200380:	fe843783          	ld	a5,-24(s0)
ffffffe000200384:	0207d793          	srli	a5,a5,0x20
ffffffe000200388:	fe843703          	ld	a4,-24(s0)
ffffffe00020038c:	00f767b3          	or	a5,a4,a5
ffffffe000200390:	fef43423          	sd	a5,-24(s0)
    return size + 1;
ffffffe000200394:	fe843783          	ld	a5,-24(s0)
ffffffe000200398:	00178793          	addi	a5,a5,1
}
ffffffe00020039c:	00078513          	mv	a0,a5
ffffffe0002003a0:	01813403          	ld	s0,24(sp)
ffffffe0002003a4:	02010113          	addi	sp,sp,32
ffffffe0002003a8:	00008067          	ret

ffffffe0002003ac <buddy_init>:

void buddy_init() {
ffffffe0002003ac:	fd010113          	addi	sp,sp,-48
ffffffe0002003b0:	02113423          	sd	ra,40(sp)
ffffffe0002003b4:	02813023          	sd	s0,32(sp)
ffffffe0002003b8:	03010413          	addi	s0,sp,48
    uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;
ffffffe0002003bc:	000087b7          	lui	a5,0x8
ffffffe0002003c0:	fef43423          	sd	a5,-24(s0)

    if (!IS_POWER_OF_2(buddy_size))
ffffffe0002003c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002003c8:	fff78713          	addi	a4,a5,-1 # 7fff <PGSIZE+0x6fff>
ffffffe0002003cc:	fe843783          	ld	a5,-24(s0)
ffffffe0002003d0:	00f777b3          	and	a5,a4,a5
ffffffe0002003d4:	00078863          	beqz	a5,ffffffe0002003e4 <buddy_init+0x38>
        buddy_size = fixsize(buddy_size);
ffffffe0002003d8:	fe843503          	ld	a0,-24(s0)
ffffffe0002003dc:	f25ff0ef          	jal	ffffffe000200300 <fixsize>
ffffffe0002003e0:	fea43423          	sd	a0,-24(s0)

    buddy.size = buddy_size;
ffffffe0002003e4:	00009797          	auipc	a5,0x9
ffffffe0002003e8:	c3c78793          	addi	a5,a5,-964 # ffffffe000209020 <buddy>
ffffffe0002003ec:	fe843703          	ld	a4,-24(s0)
ffffffe0002003f0:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe0002003f4:	00005797          	auipc	a5,0x5
ffffffe0002003f8:	c1478793          	addi	a5,a5,-1004 # ffffffe000205008 <free_page_start>
ffffffe0002003fc:	0007b703          	ld	a4,0(a5)
ffffffe000200400:	00009797          	auipc	a5,0x9
ffffffe000200404:	c2078793          	addi	a5,a5,-992 # ffffffe000209020 <buddy>
ffffffe000200408:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe00020040c:	00005797          	auipc	a5,0x5
ffffffe000200410:	bfc78793          	addi	a5,a5,-1028 # ffffffe000205008 <free_page_start>
ffffffe000200414:	0007b703          	ld	a4,0(a5)
ffffffe000200418:	00009797          	auipc	a5,0x9
ffffffe00020041c:	c0878793          	addi	a5,a5,-1016 # ffffffe000209020 <buddy>
ffffffe000200420:	0007b783          	ld	a5,0(a5)
ffffffe000200424:	00479793          	slli	a5,a5,0x4
ffffffe000200428:	00f70733          	add	a4,a4,a5
ffffffe00020042c:	00005797          	auipc	a5,0x5
ffffffe000200430:	bdc78793          	addi	a5,a5,-1060 # ffffffe000205008 <free_page_start>
ffffffe000200434:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe000200438:	00009797          	auipc	a5,0x9
ffffffe00020043c:	be878793          	addi	a5,a5,-1048 # ffffffe000209020 <buddy>
ffffffe000200440:	0087b703          	ld	a4,8(a5)
ffffffe000200444:	00009797          	auipc	a5,0x9
ffffffe000200448:	bdc78793          	addi	a5,a5,-1060 # ffffffe000209020 <buddy>
ffffffe00020044c:	0007b783          	ld	a5,0(a5)
ffffffe000200450:	00479793          	slli	a5,a5,0x4
ffffffe000200454:	00078613          	mv	a2,a5
ffffffe000200458:	00000593          	li	a1,0
ffffffe00020045c:	00070513          	mv	a0,a4
ffffffe000200460:	2f1020ef          	jal	ffffffe000202f50 <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe000200464:	00009797          	auipc	a5,0x9
ffffffe000200468:	bbc78793          	addi	a5,a5,-1092 # ffffffe000209020 <buddy>
ffffffe00020046c:	0007b783          	ld	a5,0(a5)
ffffffe000200470:	00179793          	slli	a5,a5,0x1
ffffffe000200474:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200478:	fc043c23          	sd	zero,-40(s0)
ffffffe00020047c:	0500006f          	j	ffffffe0002004cc <buddy_init+0x120>
        if (IS_POWER_OF_2(i + 1))
ffffffe000200480:	fd843783          	ld	a5,-40(s0)
ffffffe000200484:	00178713          	addi	a4,a5,1
ffffffe000200488:	fd843783          	ld	a5,-40(s0)
ffffffe00020048c:	00f777b3          	and	a5,a4,a5
ffffffe000200490:	00079863          	bnez	a5,ffffffe0002004a0 <buddy_init+0xf4>
            node_size /= 2;
ffffffe000200494:	fe043783          	ld	a5,-32(s0)
ffffffe000200498:	0017d793          	srli	a5,a5,0x1
ffffffe00020049c:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe0002004a0:	00009797          	auipc	a5,0x9
ffffffe0002004a4:	b8078793          	addi	a5,a5,-1152 # ffffffe000209020 <buddy>
ffffffe0002004a8:	0087b703          	ld	a4,8(a5)
ffffffe0002004ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002004b0:	00379793          	slli	a5,a5,0x3
ffffffe0002004b4:	00f707b3          	add	a5,a4,a5
ffffffe0002004b8:	fe043703          	ld	a4,-32(s0)
ffffffe0002004bc:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe0002004c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002004c4:	00178793          	addi	a5,a5,1
ffffffe0002004c8:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002004cc:	00009797          	auipc	a5,0x9
ffffffe0002004d0:	b5478793          	addi	a5,a5,-1196 # ffffffe000209020 <buddy>
ffffffe0002004d4:	0007b783          	ld	a5,0(a5)
ffffffe0002004d8:	00179793          	slli	a5,a5,0x1
ffffffe0002004dc:	fff78793          	addi	a5,a5,-1
ffffffe0002004e0:	fd843703          	ld	a4,-40(s0)
ffffffe0002004e4:	f8f76ee3          	bltu	a4,a5,ffffffe000200480 <buddy_init+0xd4>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe0002004e8:	fc043823          	sd	zero,-48(s0)
ffffffe0002004ec:	0180006f          	j	ffffffe000200504 <buddy_init+0x158>
        buddy_alloc(1);
ffffffe0002004f0:	00100513          	li	a0,1
ffffffe0002004f4:	1fc000ef          	jal	ffffffe0002006f0 <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe0002004f8:	fd043783          	ld	a5,-48(s0)
ffffffe0002004fc:	00178793          	addi	a5,a5,1
ffffffe000200500:	fcf43823          	sd	a5,-48(s0)
ffffffe000200504:	fd043783          	ld	a5,-48(s0)
ffffffe000200508:	00c79713          	slli	a4,a5,0xc
ffffffe00020050c:	00100793          	li	a5,1
ffffffe000200510:	01f79793          	slli	a5,a5,0x1f
ffffffe000200514:	00f70733          	add	a4,a4,a5
ffffffe000200518:	00005797          	auipc	a5,0x5
ffffffe00020051c:	af078793          	addi	a5,a5,-1296 # ffffffe000205008 <free_page_start>
ffffffe000200520:	0007b783          	ld	a5,0(a5)
ffffffe000200524:	00078693          	mv	a3,a5
ffffffe000200528:	04100793          	li	a5,65
ffffffe00020052c:	01f79793          	slli	a5,a5,0x1f
ffffffe000200530:	00f687b3          	add	a5,a3,a5
ffffffe000200534:	faf76ee3          	bltu	a4,a5,ffffffe0002004f0 <buddy_init+0x144>
    }

    printk("...buddy_init done!\n");
ffffffe000200538:	00004517          	auipc	a0,0x4
ffffffe00020053c:	ac850513          	addi	a0,a0,-1336 # ffffffe000204000 <_srodata>
ffffffe000200540:	0f1020ef          	jal	ffffffe000202e30 <printk>
    return;
ffffffe000200544:	00000013          	nop
}
ffffffe000200548:	02813083          	ld	ra,40(sp)
ffffffe00020054c:	02013403          	ld	s0,32(sp)
ffffffe000200550:	03010113          	addi	sp,sp,48
ffffffe000200554:	00008067          	ret

ffffffe000200558 <buddy_free>:

void buddy_free(uint64_t pfn) {
ffffffe000200558:	fc010113          	addi	sp,sp,-64
ffffffe00020055c:	02813c23          	sd	s0,56(sp)
ffffffe000200560:	04010413          	addi	s0,sp,64
ffffffe000200564:	fca43423          	sd	a0,-56(s0)
    uint64_t node_size, index = 0;
ffffffe000200568:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe00020056c:	00100793          	li	a5,1
ffffffe000200570:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe000200574:	00009797          	auipc	a5,0x9
ffffffe000200578:	aac78793          	addi	a5,a5,-1364 # ffffffe000209020 <buddy>
ffffffe00020057c:	0007b703          	ld	a4,0(a5)
ffffffe000200580:	fc843783          	ld	a5,-56(s0)
ffffffe000200584:	00f707b3          	add	a5,a4,a5
ffffffe000200588:	fff78793          	addi	a5,a5,-1
ffffffe00020058c:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200590:	02c0006f          	j	ffffffe0002005bc <buddy_free+0x64>
        node_size *= 2;
ffffffe000200594:	fe843783          	ld	a5,-24(s0)
ffffffe000200598:	00179793          	slli	a5,a5,0x1
ffffffe00020059c:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe0002005a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002005a4:	02078e63          	beqz	a5,ffffffe0002005e0 <buddy_free+0x88>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe0002005a8:	fe043783          	ld	a5,-32(s0)
ffffffe0002005ac:	00178793          	addi	a5,a5,1
ffffffe0002005b0:	0017d793          	srli	a5,a5,0x1
ffffffe0002005b4:	fff78793          	addi	a5,a5,-1
ffffffe0002005b8:	fef43023          	sd	a5,-32(s0)
ffffffe0002005bc:	00009797          	auipc	a5,0x9
ffffffe0002005c0:	a6478793          	addi	a5,a5,-1436 # ffffffe000209020 <buddy>
ffffffe0002005c4:	0087b703          	ld	a4,8(a5)
ffffffe0002005c8:	fe043783          	ld	a5,-32(s0)
ffffffe0002005cc:	00379793          	slli	a5,a5,0x3
ffffffe0002005d0:	00f707b3          	add	a5,a4,a5
ffffffe0002005d4:	0007b783          	ld	a5,0(a5)
ffffffe0002005d8:	fa079ee3          	bnez	a5,ffffffe000200594 <buddy_free+0x3c>
ffffffe0002005dc:	0080006f          	j	ffffffe0002005e4 <buddy_free+0x8c>
            break;
ffffffe0002005e0:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe0002005e4:	00009797          	auipc	a5,0x9
ffffffe0002005e8:	a3c78793          	addi	a5,a5,-1476 # ffffffe000209020 <buddy>
ffffffe0002005ec:	0087b703          	ld	a4,8(a5)
ffffffe0002005f0:	fe043783          	ld	a5,-32(s0)
ffffffe0002005f4:	00379793          	slli	a5,a5,0x3
ffffffe0002005f8:	00f707b3          	add	a5,a4,a5
ffffffe0002005fc:	fe843703          	ld	a4,-24(s0)
ffffffe000200600:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe000200604:	0d00006f          	j	ffffffe0002006d4 <buddy_free+0x17c>
        index = PARENT(index);
ffffffe000200608:	fe043783          	ld	a5,-32(s0)
ffffffe00020060c:	00178793          	addi	a5,a5,1
ffffffe000200610:	0017d793          	srli	a5,a5,0x1
ffffffe000200614:	fff78793          	addi	a5,a5,-1
ffffffe000200618:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe00020061c:	fe843783          	ld	a5,-24(s0)
ffffffe000200620:	00179793          	slli	a5,a5,0x1
ffffffe000200624:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe000200628:	00009797          	auipc	a5,0x9
ffffffe00020062c:	9f878793          	addi	a5,a5,-1544 # ffffffe000209020 <buddy>
ffffffe000200630:	0087b703          	ld	a4,8(a5)
ffffffe000200634:	fe043783          	ld	a5,-32(s0)
ffffffe000200638:	00479793          	slli	a5,a5,0x4
ffffffe00020063c:	00878793          	addi	a5,a5,8
ffffffe000200640:	00f707b3          	add	a5,a4,a5
ffffffe000200644:	0007b783          	ld	a5,0(a5)
ffffffe000200648:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe00020064c:	00009797          	auipc	a5,0x9
ffffffe000200650:	9d478793          	addi	a5,a5,-1580 # ffffffe000209020 <buddy>
ffffffe000200654:	0087b703          	ld	a4,8(a5)
ffffffe000200658:	fe043783          	ld	a5,-32(s0)
ffffffe00020065c:	00178793          	addi	a5,a5,1
ffffffe000200660:	00479793          	slli	a5,a5,0x4
ffffffe000200664:	00f707b3          	add	a5,a4,a5
ffffffe000200668:	0007b783          	ld	a5,0(a5)
ffffffe00020066c:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe000200670:	fd843703          	ld	a4,-40(s0)
ffffffe000200674:	fd043783          	ld	a5,-48(s0)
ffffffe000200678:	00f707b3          	add	a5,a4,a5
ffffffe00020067c:	fe843703          	ld	a4,-24(s0)
ffffffe000200680:	02f71463          	bne	a4,a5,ffffffe0002006a8 <buddy_free+0x150>
            buddy.bitmap[index] = node_size;
ffffffe000200684:	00009797          	auipc	a5,0x9
ffffffe000200688:	99c78793          	addi	a5,a5,-1636 # ffffffe000209020 <buddy>
ffffffe00020068c:	0087b703          	ld	a4,8(a5)
ffffffe000200690:	fe043783          	ld	a5,-32(s0)
ffffffe000200694:	00379793          	slli	a5,a5,0x3
ffffffe000200698:	00f707b3          	add	a5,a4,a5
ffffffe00020069c:	fe843703          	ld	a4,-24(s0)
ffffffe0002006a0:	00e7b023          	sd	a4,0(a5)
ffffffe0002006a4:	0300006f          	j	ffffffe0002006d4 <buddy_free+0x17c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe0002006a8:	00009797          	auipc	a5,0x9
ffffffe0002006ac:	97878793          	addi	a5,a5,-1672 # ffffffe000209020 <buddy>
ffffffe0002006b0:	0087b703          	ld	a4,8(a5)
ffffffe0002006b4:	fe043783          	ld	a5,-32(s0)
ffffffe0002006b8:	00379793          	slli	a5,a5,0x3
ffffffe0002006bc:	00f706b3          	add	a3,a4,a5
ffffffe0002006c0:	fd843703          	ld	a4,-40(s0)
ffffffe0002006c4:	fd043783          	ld	a5,-48(s0)
ffffffe0002006c8:	00e7f463          	bgeu	a5,a4,ffffffe0002006d0 <buddy_free+0x178>
ffffffe0002006cc:	00070793          	mv	a5,a4
ffffffe0002006d0:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe0002006d4:	fe043783          	ld	a5,-32(s0)
ffffffe0002006d8:	f20798e3          	bnez	a5,ffffffe000200608 <buddy_free+0xb0>
    }
}
ffffffe0002006dc:	00000013          	nop
ffffffe0002006e0:	00000013          	nop
ffffffe0002006e4:	03813403          	ld	s0,56(sp)
ffffffe0002006e8:	04010113          	addi	sp,sp,64
ffffffe0002006ec:	00008067          	ret

ffffffe0002006f0 <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe0002006f0:	fc010113          	addi	sp,sp,-64
ffffffe0002006f4:	02113c23          	sd	ra,56(sp)
ffffffe0002006f8:	02813823          	sd	s0,48(sp)
ffffffe0002006fc:	04010413          	addi	s0,sp,64
ffffffe000200700:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe000200704:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe000200708:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe00020070c:	fc843783          	ld	a5,-56(s0)
ffffffe000200710:	00079863          	bnez	a5,ffffffe000200720 <buddy_alloc+0x30>
        nrpages = 1;
ffffffe000200714:	00100793          	li	a5,1
ffffffe000200718:	fcf43423          	sd	a5,-56(s0)
ffffffe00020071c:	0240006f          	j	ffffffe000200740 <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe000200720:	fc843783          	ld	a5,-56(s0)
ffffffe000200724:	fff78713          	addi	a4,a5,-1
ffffffe000200728:	fc843783          	ld	a5,-56(s0)
ffffffe00020072c:	00f777b3          	and	a5,a4,a5
ffffffe000200730:	00078863          	beqz	a5,ffffffe000200740 <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe000200734:	fc843503          	ld	a0,-56(s0)
ffffffe000200738:	bc9ff0ef          	jal	ffffffe000200300 <fixsize>
ffffffe00020073c:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe000200740:	00009797          	auipc	a5,0x9
ffffffe000200744:	8e078793          	addi	a5,a5,-1824 # ffffffe000209020 <buddy>
ffffffe000200748:	0087b703          	ld	a4,8(a5)
ffffffe00020074c:	fe843783          	ld	a5,-24(s0)
ffffffe000200750:	00379793          	slli	a5,a5,0x3
ffffffe000200754:	00f707b3          	add	a5,a4,a5
ffffffe000200758:	0007b783          	ld	a5,0(a5)
ffffffe00020075c:	fc843703          	ld	a4,-56(s0)
ffffffe000200760:	00e7f663          	bgeu	a5,a4,ffffffe00020076c <buddy_alloc+0x7c>
        return 0;
ffffffe000200764:	00000793          	li	a5,0
ffffffe000200768:	1480006f          	j	ffffffe0002008b0 <buddy_alloc+0x1c0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe00020076c:	00009797          	auipc	a5,0x9
ffffffe000200770:	8b478793          	addi	a5,a5,-1868 # ffffffe000209020 <buddy>
ffffffe000200774:	0007b783          	ld	a5,0(a5)
ffffffe000200778:	fef43023          	sd	a5,-32(s0)
ffffffe00020077c:	05c0006f          	j	ffffffe0002007d8 <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe000200780:	00009797          	auipc	a5,0x9
ffffffe000200784:	8a078793          	addi	a5,a5,-1888 # ffffffe000209020 <buddy>
ffffffe000200788:	0087b703          	ld	a4,8(a5)
ffffffe00020078c:	fe843783          	ld	a5,-24(s0)
ffffffe000200790:	00479793          	slli	a5,a5,0x4
ffffffe000200794:	00878793          	addi	a5,a5,8
ffffffe000200798:	00f707b3          	add	a5,a4,a5
ffffffe00020079c:	0007b783          	ld	a5,0(a5)
ffffffe0002007a0:	fc843703          	ld	a4,-56(s0)
ffffffe0002007a4:	00e7ec63          	bltu	a5,a4,ffffffe0002007bc <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe0002007a8:	fe843783          	ld	a5,-24(s0)
ffffffe0002007ac:	00179793          	slli	a5,a5,0x1
ffffffe0002007b0:	00178793          	addi	a5,a5,1
ffffffe0002007b4:	fef43423          	sd	a5,-24(s0)
ffffffe0002007b8:	0140006f          	j	ffffffe0002007cc <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe0002007bc:	fe843783          	ld	a5,-24(s0)
ffffffe0002007c0:	00178793          	addi	a5,a5,1
ffffffe0002007c4:	00179793          	slli	a5,a5,0x1
ffffffe0002007c8:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe0002007cc:	fe043783          	ld	a5,-32(s0)
ffffffe0002007d0:	0017d793          	srli	a5,a5,0x1
ffffffe0002007d4:	fef43023          	sd	a5,-32(s0)
ffffffe0002007d8:	fe043703          	ld	a4,-32(s0)
ffffffe0002007dc:	fc843783          	ld	a5,-56(s0)
ffffffe0002007e0:	faf710e3          	bne	a4,a5,ffffffe000200780 <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe0002007e4:	00009797          	auipc	a5,0x9
ffffffe0002007e8:	83c78793          	addi	a5,a5,-1988 # ffffffe000209020 <buddy>
ffffffe0002007ec:	0087b703          	ld	a4,8(a5)
ffffffe0002007f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002007f4:	00379793          	slli	a5,a5,0x3
ffffffe0002007f8:	00f707b3          	add	a5,a4,a5
ffffffe0002007fc:	0007b023          	sd	zero,0(a5)
    pfn = (index + 1) * node_size - buddy.size;
ffffffe000200800:	fe843783          	ld	a5,-24(s0)
ffffffe000200804:	00178713          	addi	a4,a5,1
ffffffe000200808:	fe043783          	ld	a5,-32(s0)
ffffffe00020080c:	02f70733          	mul	a4,a4,a5
ffffffe000200810:	00009797          	auipc	a5,0x9
ffffffe000200814:	81078793          	addi	a5,a5,-2032 # ffffffe000209020 <buddy>
ffffffe000200818:	0007b783          	ld	a5,0(a5)
ffffffe00020081c:	40f707b3          	sub	a5,a4,a5
ffffffe000200820:	fcf43c23          	sd	a5,-40(s0)

    while (index) {
ffffffe000200824:	0800006f          	j	ffffffe0002008a4 <buddy_alloc+0x1b4>
        index = PARENT(index);
ffffffe000200828:	fe843783          	ld	a5,-24(s0)
ffffffe00020082c:	00178793          	addi	a5,a5,1
ffffffe000200830:	0017d793          	srli	a5,a5,0x1
ffffffe000200834:	fff78793          	addi	a5,a5,-1
ffffffe000200838:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe00020083c:	00008797          	auipc	a5,0x8
ffffffe000200840:	7e478793          	addi	a5,a5,2020 # ffffffe000209020 <buddy>
ffffffe000200844:	0087b703          	ld	a4,8(a5)
ffffffe000200848:	fe843783          	ld	a5,-24(s0)
ffffffe00020084c:	00178793          	addi	a5,a5,1
ffffffe000200850:	00479793          	slli	a5,a5,0x4
ffffffe000200854:	00f707b3          	add	a5,a4,a5
ffffffe000200858:	0007b603          	ld	a2,0(a5)
ffffffe00020085c:	00008797          	auipc	a5,0x8
ffffffe000200860:	7c478793          	addi	a5,a5,1988 # ffffffe000209020 <buddy>
ffffffe000200864:	0087b703          	ld	a4,8(a5)
ffffffe000200868:	fe843783          	ld	a5,-24(s0)
ffffffe00020086c:	00479793          	slli	a5,a5,0x4
ffffffe000200870:	00878793          	addi	a5,a5,8
ffffffe000200874:	00f707b3          	add	a5,a4,a5
ffffffe000200878:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe00020087c:	00008797          	auipc	a5,0x8
ffffffe000200880:	7a478793          	addi	a5,a5,1956 # ffffffe000209020 <buddy>
ffffffe000200884:	0087b683          	ld	a3,8(a5)
ffffffe000200888:	fe843783          	ld	a5,-24(s0)
ffffffe00020088c:	00379793          	slli	a5,a5,0x3
ffffffe000200890:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe000200894:	00060793          	mv	a5,a2
ffffffe000200898:	00e7f463          	bgeu	a5,a4,ffffffe0002008a0 <buddy_alloc+0x1b0>
ffffffe00020089c:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe0002008a0:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe0002008a4:	fe843783          	ld	a5,-24(s0)
ffffffe0002008a8:	f80790e3          	bnez	a5,ffffffe000200828 <buddy_alloc+0x138>
    }
    
    return pfn;
ffffffe0002008ac:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002008b0:	00078513          	mv	a0,a5
ffffffe0002008b4:	03813083          	ld	ra,56(sp)
ffffffe0002008b8:	03013403          	ld	s0,48(sp)
ffffffe0002008bc:	04010113          	addi	sp,sp,64
ffffffe0002008c0:	00008067          	ret

ffffffe0002008c4 <alloc_pages>:


void *alloc_pages(uint64_t nrpages) {
ffffffe0002008c4:	fd010113          	addi	sp,sp,-48
ffffffe0002008c8:	02113423          	sd	ra,40(sp)
ffffffe0002008cc:	02813023          	sd	s0,32(sp)
ffffffe0002008d0:	03010413          	addi	s0,sp,48
ffffffe0002008d4:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe0002008d8:	fd843503          	ld	a0,-40(s0)
ffffffe0002008dc:	e15ff0ef          	jal	ffffffe0002006f0 <buddy_alloc>
ffffffe0002008e0:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe0002008e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002008e8:	00079663          	bnez	a5,ffffffe0002008f4 <alloc_pages+0x30>
        return 0;
ffffffe0002008ec:	00000793          	li	a5,0
ffffffe0002008f0:	0180006f          	j	ffffffe000200908 <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe0002008f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002008f8:	00c79713          	slli	a4,a5,0xc
ffffffe0002008fc:	fff00793          	li	a5,-1
ffffffe000200900:	02579793          	slli	a5,a5,0x25
ffffffe000200904:	00f707b3          	add	a5,a4,a5
}
ffffffe000200908:	00078513          	mv	a0,a5
ffffffe00020090c:	02813083          	ld	ra,40(sp)
ffffffe000200910:	02013403          	ld	s0,32(sp)
ffffffe000200914:	03010113          	addi	sp,sp,48
ffffffe000200918:	00008067          	ret

ffffffe00020091c <alloc_page>:

void *alloc_page() {
ffffffe00020091c:	ff010113          	addi	sp,sp,-16
ffffffe000200920:	00113423          	sd	ra,8(sp)
ffffffe000200924:	00813023          	sd	s0,0(sp)
ffffffe000200928:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe00020092c:	00100513          	li	a0,1
ffffffe000200930:	f95ff0ef          	jal	ffffffe0002008c4 <alloc_pages>
ffffffe000200934:	00050793          	mv	a5,a0
}
ffffffe000200938:	00078513          	mv	a0,a5
ffffffe00020093c:	00813083          	ld	ra,8(sp)
ffffffe000200940:	00013403          	ld	s0,0(sp)
ffffffe000200944:	01010113          	addi	sp,sp,16
ffffffe000200948:	00008067          	ret

ffffffe00020094c <free_pages>:

void free_pages(void *va) {
ffffffe00020094c:	fe010113          	addi	sp,sp,-32
ffffffe000200950:	00113c23          	sd	ra,24(sp)
ffffffe000200954:	00813823          	sd	s0,16(sp)
ffffffe000200958:	02010413          	addi	s0,sp,32
ffffffe00020095c:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe000200960:	fe843703          	ld	a4,-24(s0)
ffffffe000200964:	00100793          	li	a5,1
ffffffe000200968:	02579793          	slli	a5,a5,0x25
ffffffe00020096c:	00f707b3          	add	a5,a4,a5
ffffffe000200970:	00c7d793          	srli	a5,a5,0xc
ffffffe000200974:	00078513          	mv	a0,a5
ffffffe000200978:	be1ff0ef          	jal	ffffffe000200558 <buddy_free>
}
ffffffe00020097c:	00000013          	nop
ffffffe000200980:	01813083          	ld	ra,24(sp)
ffffffe000200984:	01013403          	ld	s0,16(sp)
ffffffe000200988:	02010113          	addi	sp,sp,32
ffffffe00020098c:	00008067          	ret

ffffffe000200990 <kalloc>:

void *kalloc() {
ffffffe000200990:	ff010113          	addi	sp,sp,-16
ffffffe000200994:	00113423          	sd	ra,8(sp)
ffffffe000200998:	00813023          	sd	s0,0(sp)
ffffffe00020099c:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe0002009a0:	f7dff0ef          	jal	ffffffe00020091c <alloc_page>
ffffffe0002009a4:	00050793          	mv	a5,a0
}
ffffffe0002009a8:	00078513          	mv	a0,a5
ffffffe0002009ac:	00813083          	ld	ra,8(sp)
ffffffe0002009b0:	00013403          	ld	s0,0(sp)
ffffffe0002009b4:	01010113          	addi	sp,sp,16
ffffffe0002009b8:	00008067          	ret

ffffffe0002009bc <kfree>:

void kfree(void *addr) {
ffffffe0002009bc:	fe010113          	addi	sp,sp,-32
ffffffe0002009c0:	00113c23          	sd	ra,24(sp)
ffffffe0002009c4:	00813823          	sd	s0,16(sp)
ffffffe0002009c8:	02010413          	addi	s0,sp,32
ffffffe0002009cc:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe0002009d0:	fe843503          	ld	a0,-24(s0)
ffffffe0002009d4:	f79ff0ef          	jal	ffffffe00020094c <free_pages>

    return;
ffffffe0002009d8:	00000013          	nop
}
ffffffe0002009dc:	01813083          	ld	ra,24(sp)
ffffffe0002009e0:	01013403          	ld	s0,16(sp)
ffffffe0002009e4:	02010113          	addi	sp,sp,32
ffffffe0002009e8:	00008067          	ret

ffffffe0002009ec <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe0002009ec:	fd010113          	addi	sp,sp,-48
ffffffe0002009f0:	02113423          	sd	ra,40(sp)
ffffffe0002009f4:	02813023          	sd	s0,32(sp)
ffffffe0002009f8:	03010413          	addi	s0,sp,48
ffffffe0002009fc:	fca43c23          	sd	a0,-40(s0)
ffffffe000200a00:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200a04:	fd843703          	ld	a4,-40(s0)
ffffffe000200a08:	000017b7          	lui	a5,0x1
ffffffe000200a0c:	fff78793          	addi	a5,a5,-1 # fff <i+0xfdf>
ffffffe000200a10:	00f70733          	add	a4,a4,a5
ffffffe000200a14:	fffff7b7          	lui	a5,0xfffff
ffffffe000200a18:	00f777b3          	and	a5,a4,a5
ffffffe000200a1c:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200a20:	01c0006f          	j	ffffffe000200a3c <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200a24:	fe843503          	ld	a0,-24(s0)
ffffffe000200a28:	f95ff0ef          	jal	ffffffe0002009bc <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200a2c:	fe843703          	ld	a4,-24(s0)
ffffffe000200a30:	000017b7          	lui	a5,0x1
ffffffe000200a34:	00f707b3          	add	a5,a4,a5
ffffffe000200a38:	fef43423          	sd	a5,-24(s0)
ffffffe000200a3c:	fe843703          	ld	a4,-24(s0)
ffffffe000200a40:	000017b7          	lui	a5,0x1
ffffffe000200a44:	00f70733          	add	a4,a4,a5
ffffffe000200a48:	fd043783          	ld	a5,-48(s0)
ffffffe000200a4c:	fce7fce3          	bgeu	a5,a4,ffffffe000200a24 <kfreerange+0x38>
    }
}
ffffffe000200a50:	00000013          	nop
ffffffe000200a54:	00000013          	nop
ffffffe000200a58:	02813083          	ld	ra,40(sp)
ffffffe000200a5c:	02013403          	ld	s0,32(sp)
ffffffe000200a60:	03010113          	addi	sp,sp,48
ffffffe000200a64:	00008067          	ret

ffffffe000200a68 <mm_init>:

void mm_init(void) {
ffffffe000200a68:	ff010113          	addi	sp,sp,-16
ffffffe000200a6c:	00113423          	sd	ra,8(sp)
ffffffe000200a70:	00813023          	sd	s0,0(sp)
ffffffe000200a74:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200a78:	935ff0ef          	jal	ffffffe0002003ac <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200a7c:	00003517          	auipc	a0,0x3
ffffffe000200a80:	59c50513          	addi	a0,a0,1436 # ffffffe000204018 <_srodata+0x18>
ffffffe000200a84:	3ac020ef          	jal	ffffffe000202e30 <printk>
}
ffffffe000200a88:	00000013          	nop
ffffffe000200a8c:	00813083          	ld	ra,8(sp)
ffffffe000200a90:	00013403          	ld	s0,0(sp)
ffffffe000200a94:	01010113          	addi	sp,sp,16
ffffffe000200a98:	00008067          	ret

ffffffe000200a9c <task_init>:

struct task_struct* idle;            // idle process
struct task_struct* current;         // 指向当前运行线程的 task_struct
struct task_struct* task[NR_TASKS];  // 线程数组，所有的线程都保存在此

void task_init() {
ffffffe000200a9c:	fc010113          	addi	sp,sp,-64
ffffffe000200aa0:	02113c23          	sd	ra,56(sp)
ffffffe000200aa4:	02813823          	sd	s0,48(sp)
ffffffe000200aa8:	02913423          	sd	s1,40(sp)
ffffffe000200aac:	04010413          	addi	s0,sp,64
    srand(2024);
ffffffe000200ab0:	7e800513          	li	a0,2024
ffffffe000200ab4:	3fc020ef          	jal	ffffffe000202eb0 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc(PGSIZE);
ffffffe000200ab8:	00001537          	lui	a0,0x1
ffffffe000200abc:	ed5ff0ef          	jal	ffffffe000200990 <kalloc>
ffffffe000200ac0:	00050713          	mv	a4,a0
ffffffe000200ac4:	00008797          	auipc	a5,0x8
ffffffe000200ac8:	54478793          	addi	a5,a5,1348 # ffffffe000209008 <idle>
ffffffe000200acc:	00e7b023          	sd	a4,0(a5)

    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe000200ad0:	00008797          	auipc	a5,0x8
ffffffe000200ad4:	53878793          	addi	a5,a5,1336 # ffffffe000209008 <idle>
ffffffe000200ad8:	0007b783          	ld	a5,0(a5)
ffffffe000200adc:	0007b023          	sd	zero,0(a5)

    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter  = 0;
ffffffe000200ae0:	00008797          	auipc	a5,0x8
ffffffe000200ae4:	52878793          	addi	a5,a5,1320 # ffffffe000209008 <idle>
ffffffe000200ae8:	0007b783          	ld	a5,0(a5)
ffffffe000200aec:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe000200af0:	00008797          	auipc	a5,0x8
ffffffe000200af4:	51878793          	addi	a5,a5,1304 # ffffffe000209008 <idle>
ffffffe000200af8:	0007b783          	ld	a5,0(a5)
ffffffe000200afc:	0007b823          	sd	zero,16(a5)

    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe000200b00:	00008797          	auipc	a5,0x8
ffffffe000200b04:	50878793          	addi	a5,a5,1288 # ffffffe000209008 <idle>
ffffffe000200b08:	0007b783          	ld	a5,0(a5)
ffffffe000200b0c:	0007bc23          	sd	zero,24(a5)

    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe000200b10:	00008797          	auipc	a5,0x8
ffffffe000200b14:	4f878793          	addi	a5,a5,1272 # ffffffe000209008 <idle>
ffffffe000200b18:	0007b703          	ld	a4,0(a5)
ffffffe000200b1c:	00008797          	auipc	a5,0x8
ffffffe000200b20:	4f478793          	addi	a5,a5,1268 # ffffffe000209010 <current>
ffffffe000200b24:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000200b28:	00008797          	auipc	a5,0x8
ffffffe000200b2c:	4e078793          	addi	a5,a5,1248 # ffffffe000209008 <idle>
ffffffe000200b30:	0007b703          	ld	a4,0(a5)
ffffffe000200b34:	00008797          	auipc	a5,0x8
ffffffe000200b38:	4fc78793          	addi	a5,a5,1276 # ffffffe000209030 <task>
ffffffe000200b3c:	00e7b023          	sd	a4,0(a5)

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化

    // Well, i don't use reversed while-loop like Linus
    for (size_t i = 1; i < NR_TASKS; i++) {
ffffffe000200b40:	00100793          	li	a5,1
ffffffe000200b44:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200b48:	2dc0006f          	j	ffffffe000200e24 <task_init+0x388>
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority
        // 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN,
        //     PRIORITY_MAX] 之间）
        task[i]           = (struct task_struct*)kalloc(PGSIZE);
ffffffe000200b4c:	00001537          	lui	a0,0x1
ffffffe000200b50:	e41ff0ef          	jal	ffffffe000200990 <kalloc>
ffffffe000200b54:	00050693          	mv	a3,a0
ffffffe000200b58:	00008717          	auipc	a4,0x8
ffffffe000200b5c:	4d870713          	addi	a4,a4,1240 # ffffffe000209030 <task>
ffffffe000200b60:	fd843783          	ld	a5,-40(s0)
ffffffe000200b64:	00379793          	slli	a5,a5,0x3
ffffffe000200b68:	00f707b3          	add	a5,a4,a5
ffffffe000200b6c:	00d7b023          	sd	a3,0(a5)
        task[i]->state    = TASK_RUNNING;
ffffffe000200b70:	00008717          	auipc	a4,0x8
ffffffe000200b74:	4c070713          	addi	a4,a4,1216 # ffffffe000209030 <task>
ffffffe000200b78:	fd843783          	ld	a5,-40(s0)
ffffffe000200b7c:	00379793          	slli	a5,a5,0x3
ffffffe000200b80:	00f707b3          	add	a5,a4,a5
ffffffe000200b84:	0007b783          	ld	a5,0(a5)
ffffffe000200b88:	0007b023          	sd	zero,0(a5)
        task[i]->counter  = 0;
ffffffe000200b8c:	00008717          	auipc	a4,0x8
ffffffe000200b90:	4a470713          	addi	a4,a4,1188 # ffffffe000209030 <task>
ffffffe000200b94:	fd843783          	ld	a5,-40(s0)
ffffffe000200b98:	00379793          	slli	a5,a5,0x3
ffffffe000200b9c:	00f707b3          	add	a5,a4,a5
ffffffe000200ba0:	0007b783          	ld	a5,0(a5)
ffffffe000200ba4:	0007b423          	sd	zero,8(a5)
        task[i]->priority = (rand() % (PRIORITY_MAX - PRIORITY_MIN + 1)) + PRIORITY_MIN;
ffffffe000200ba8:	34c020ef          	jal	ffffffe000202ef4 <rand>
ffffffe000200bac:	00050793          	mv	a5,a0
ffffffe000200bb0:	00078713          	mv	a4,a5
ffffffe000200bb4:	00a00793          	li	a5,10
ffffffe000200bb8:	02f767bb          	remw	a5,a4,a5
ffffffe000200bbc:	0007879b          	sext.w	a5,a5
ffffffe000200bc0:	0017879b          	addiw	a5,a5,1
ffffffe000200bc4:	0007869b          	sext.w	a3,a5
ffffffe000200bc8:	00008717          	auipc	a4,0x8
ffffffe000200bcc:	46870713          	addi	a4,a4,1128 # ffffffe000209030 <task>
ffffffe000200bd0:	fd843783          	ld	a5,-40(s0)
ffffffe000200bd4:	00379793          	slli	a5,a5,0x3
ffffffe000200bd8:	00f707b3          	add	a5,a4,a5
ffffffe000200bdc:	0007b783          	ld	a5,0(a5)
ffffffe000200be0:	00068713          	mv	a4,a3
ffffffe000200be4:	00e7b823          	sd	a4,16(a5)
        task[i]->pid      = i;
ffffffe000200be8:	00008717          	auipc	a4,0x8
ffffffe000200bec:	44870713          	addi	a4,a4,1096 # ffffffe000209030 <task>
ffffffe000200bf0:	fd843783          	ld	a5,-40(s0)
ffffffe000200bf4:	00379793          	slli	a5,a5,0x3
ffffffe000200bf8:	00f707b3          	add	a5,a4,a5
ffffffe000200bfc:	0007b783          	ld	a5,0(a5)
ffffffe000200c00:	fd843703          	ld	a4,-40(s0)
ffffffe000200c04:	00e7bc23          	sd	a4,24(a5)
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址
        //     - sepc: USER_START
        //     - sstatus: SPP = 0, SUM = 1
        //     - sscratch: U-Mode sp = USER_END
        task[i]->thread.ra       = (uint64_t)__dummy;
ffffffe000200c08:	00008717          	auipc	a4,0x8
ffffffe000200c0c:	42870713          	addi	a4,a4,1064 # ffffffe000209030 <task>
ffffffe000200c10:	fd843783          	ld	a5,-40(s0)
ffffffe000200c14:	00379793          	slli	a5,a5,0x3
ffffffe000200c18:	00f707b3          	add	a5,a4,a5
ffffffe000200c1c:	0007b783          	ld	a5,0(a5)
ffffffe000200c20:	fffff717          	auipc	a4,0xfffff
ffffffe000200c24:	5ac70713          	addi	a4,a4,1452 # ffffffe0002001cc <__dummy>
ffffffe000200c28:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp       = (uint64_t)((uint8_t*)task[i] + PGSIZE);
ffffffe000200c2c:	00008717          	auipc	a4,0x8
ffffffe000200c30:	40470713          	addi	a4,a4,1028 # ffffffe000209030 <task>
ffffffe000200c34:	fd843783          	ld	a5,-40(s0)
ffffffe000200c38:	00379793          	slli	a5,a5,0x3
ffffffe000200c3c:	00f707b3          	add	a5,a4,a5
ffffffe000200c40:	0007b703          	ld	a4,0(a5)
ffffffe000200c44:	000017b7          	lui	a5,0x1
ffffffe000200c48:	00f706b3          	add	a3,a4,a5
ffffffe000200c4c:	00008717          	auipc	a4,0x8
ffffffe000200c50:	3e470713          	addi	a4,a4,996 # ffffffe000209030 <task>
ffffffe000200c54:	fd843783          	ld	a5,-40(s0)
ffffffe000200c58:	00379793          	slli	a5,a5,0x3
ffffffe000200c5c:	00f707b3          	add	a5,a4,a5
ffffffe000200c60:	0007b783          	ld	a5,0(a5) # 1000 <PGSIZE>
ffffffe000200c64:	00068713          	mv	a4,a3
ffffffe000200c68:	02e7b423          	sd	a4,40(a5)
        task[i]->thread.sepc     = USER_START;
ffffffe000200c6c:	00008717          	auipc	a4,0x8
ffffffe000200c70:	3c470713          	addi	a4,a4,964 # ffffffe000209030 <task>
ffffffe000200c74:	fd843783          	ld	a5,-40(s0)
ffffffe000200c78:	00379793          	slli	a5,a5,0x3
ffffffe000200c7c:	00f707b3          	add	a5,a4,a5
ffffffe000200c80:	0007b783          	ld	a5,0(a5)
ffffffe000200c84:	0807b823          	sd	zero,144(a5)
        task[i]->thread.sstatus  = SSTATUS_SUM | SSTATUS_SIE;
ffffffe000200c88:	00008717          	auipc	a4,0x8
ffffffe000200c8c:	3a870713          	addi	a4,a4,936 # ffffffe000209030 <task>
ffffffe000200c90:	fd843783          	ld	a5,-40(s0)
ffffffe000200c94:	00379793          	slli	a5,a5,0x3
ffffffe000200c98:	00f707b3          	add	a5,a4,a5
ffffffe000200c9c:	0007b783          	ld	a5,0(a5)
ffffffe000200ca0:	00040737          	lui	a4,0x40
ffffffe000200ca4:	00270713          	addi	a4,a4,2 # 40002 <PGSIZE+0x3f002>
ffffffe000200ca8:	08e7bc23          	sd	a4,152(a5)
        task[i]->thread.sscratch = USER_END;
ffffffe000200cac:	00008717          	auipc	a4,0x8
ffffffe000200cb0:	38470713          	addi	a4,a4,900 # ffffffe000209030 <task>
ffffffe000200cb4:	fd843783          	ld	a5,-40(s0)
ffffffe000200cb8:	00379793          	slli	a5,a5,0x3
ffffffe000200cbc:	00f707b3          	add	a5,a4,a5
ffffffe000200cc0:	0007b783          	ld	a5,0(a5)
ffffffe000200cc4:	00100713          	li	a4,1
ffffffe000200cc8:	02671713          	slli	a4,a4,0x26
ffffffe000200ccc:	0ae7b023          	sd	a4,160(a5)

        // User Space Page Table
        task[i]->pgd = alloc_page();
ffffffe000200cd0:	00008717          	auipc	a4,0x8
ffffffe000200cd4:	36070713          	addi	a4,a4,864 # ffffffe000209030 <task>
ffffffe000200cd8:	fd843783          	ld	a5,-40(s0)
ffffffe000200cdc:	00379793          	slli	a5,a5,0x3
ffffffe000200ce0:	00f707b3          	add	a5,a4,a5
ffffffe000200ce4:	0007b483          	ld	s1,0(a5)
ffffffe000200ce8:	c35ff0ef          	jal	ffffffe00020091c <alloc_page>
ffffffe000200cec:	00050793          	mv	a5,a0
ffffffe000200cf0:	0af4b423          	sd	a5,168(s1)
        memcpy((void*)task[i]->pgd, (const void*)swapper_pg_dir, PGSIZE);
ffffffe000200cf4:	00008717          	auipc	a4,0x8
ffffffe000200cf8:	33c70713          	addi	a4,a4,828 # ffffffe000209030 <task>
ffffffe000200cfc:	fd843783          	ld	a5,-40(s0)
ffffffe000200d00:	00379793          	slli	a5,a5,0x3
ffffffe000200d04:	00f707b3          	add	a5,a4,a5
ffffffe000200d08:	0007b783          	ld	a5,0(a5)
ffffffe000200d0c:	0a87b703          	ld	a4,168(a5)
ffffffe000200d10:	0000a797          	auipc	a5,0xa
ffffffe000200d14:	2f078793          	addi	a5,a5,752 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000200d18:	0007b783          	ld	a5,0(a5)
ffffffe000200d1c:	00001637          	lui	a2,0x1
ffffffe000200d20:	00078593          	mv	a1,a5
ffffffe000200d24:	00070513          	mv	a0,a4
ffffffe000200d28:	298020ef          	jal	ffffffe000202fc0 <memcpy>
        // Copy uapp binary, init user space stack
        uint64_t need_pages  = (_eramdisk - _sramdisk + PGSIZE - 1) / PGSIZE;
ffffffe000200d2c:	00007717          	auipc	a4,0x7
ffffffe000200d30:	95470713          	addi	a4,a4,-1708 # ffffffe000207680 <_eramdisk>
ffffffe000200d34:	00005797          	auipc	a5,0x5
ffffffe000200d38:	2cc78793          	addi	a5,a5,716 # ffffffe000206000 <_sramdisk>
ffffffe000200d3c:	40f70733          	sub	a4,a4,a5
ffffffe000200d40:	000017b7          	lui	a5,0x1
ffffffe000200d44:	fff78793          	addi	a5,a5,-1 # fff <i+0xfdf>
ffffffe000200d48:	00f707b3          	add	a5,a4,a5
ffffffe000200d4c:	43f7d693          	srai	a3,a5,0x3f
ffffffe000200d50:	00001737          	lui	a4,0x1
ffffffe000200d54:	fff70713          	addi	a4,a4,-1 # fff <i+0xfdf>
ffffffe000200d58:	00e6f733          	and	a4,a3,a4
ffffffe000200d5c:	00f707b3          	add	a5,a4,a5
ffffffe000200d60:	40c7d793          	srai	a5,a5,0xc
ffffffe000200d64:	fcf43823          	sd	a5,-48(s0)
        uint64_t* user_space = (uint64_t*)alloc_pages(need_pages);
ffffffe000200d68:	fd043503          	ld	a0,-48(s0)
ffffffe000200d6c:	b59ff0ef          	jal	ffffffe0002008c4 <alloc_pages>
ffffffe000200d70:	fca43423          	sd	a0,-56(s0)
        uint64_t* user_stack = (uint64_t*)alloc_page();
ffffffe000200d74:	ba9ff0ef          	jal	ffffffe00020091c <alloc_page>
ffffffe000200d78:	fca43023          	sd	a0,-64(s0)
        memcpy((void*)user_space, (const void*)_sramdisk, (_eramdisk - _sramdisk));
ffffffe000200d7c:	00007717          	auipc	a4,0x7
ffffffe000200d80:	90470713          	addi	a4,a4,-1788 # ffffffe000207680 <_eramdisk>
ffffffe000200d84:	00005797          	auipc	a5,0x5
ffffffe000200d88:	27c78793          	addi	a5,a5,636 # ffffffe000206000 <_sramdisk>
ffffffe000200d8c:	40f707b3          	sub	a5,a4,a5
ffffffe000200d90:	00078613          	mv	a2,a5
ffffffe000200d94:	00005597          	auipc	a1,0x5
ffffffe000200d98:	26c58593          	addi	a1,a1,620 # ffffffe000206000 <_sramdisk>
ffffffe000200d9c:	fc843503          	ld	a0,-56(s0)
ffffffe000200da0:	220020ef          	jal	ffffffe000202fc0 <memcpy>
        create_mapping(task[i]->pgd, USER_START, (uint64_t)user_space, need_pages * PGSIZE,
ffffffe000200da4:	00008717          	auipc	a4,0x8
ffffffe000200da8:	28c70713          	addi	a4,a4,652 # ffffffe000209030 <task>
ffffffe000200dac:	fd843783          	ld	a5,-40(s0)
ffffffe000200db0:	00379793          	slli	a5,a5,0x3
ffffffe000200db4:	00f707b3          	add	a5,a4,a5
ffffffe000200db8:	0007b783          	ld	a5,0(a5)
ffffffe000200dbc:	0a87b503          	ld	a0,168(a5)
ffffffe000200dc0:	fc843603          	ld	a2,-56(s0)
ffffffe000200dc4:	fd043783          	ld	a5,-48(s0)
ffffffe000200dc8:	00c79793          	slli	a5,a5,0xc
ffffffe000200dcc:	05f00713          	li	a4,95
ffffffe000200dd0:	00078693          	mv	a3,a5
ffffffe000200dd4:	00000593          	li	a1,0
ffffffe000200dd8:	475000ef          	jal	ffffffe000201a4c <create_mapping>
                       PERM_A | PERM_U | PERM_R | PERM_W | PERM_X | PERM_V);
        create_mapping(task[i]->pgd, USER_END - PGSIZE, (uint64_t)user_stack, PGSIZE,
ffffffe000200ddc:	00008717          	auipc	a4,0x8
ffffffe000200de0:	25470713          	addi	a4,a4,596 # ffffffe000209030 <task>
ffffffe000200de4:	fd843783          	ld	a5,-40(s0)
ffffffe000200de8:	00379793          	slli	a5,a5,0x3
ffffffe000200dec:	00f707b3          	add	a5,a4,a5
ffffffe000200df0:	0007b783          	ld	a5,0(a5)
ffffffe000200df4:	0a87b503          	ld	a0,168(a5)
ffffffe000200df8:	fc043783          	ld	a5,-64(s0)
ffffffe000200dfc:	05700713          	li	a4,87
ffffffe000200e00:	000016b7          	lui	a3,0x1
ffffffe000200e04:	00078613          	mv	a2,a5
ffffffe000200e08:	040007b7          	lui	a5,0x4000
ffffffe000200e0c:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000200e10:	00c79593          	slli	a1,a5,0xc
ffffffe000200e14:	439000ef          	jal	ffffffe000201a4c <create_mapping>
    for (size_t i = 1; i < NR_TASKS; i++) {
ffffffe000200e18:	fd843783          	ld	a5,-40(s0)
ffffffe000200e1c:	00178793          	addi	a5,a5,1
ffffffe000200e20:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200e24:	fd843703          	ld	a4,-40(s0)
ffffffe000200e28:	00400793          	li	a5,4
ffffffe000200e2c:	d2e7f0e3          	bgeu	a5,a4,ffffffe000200b4c <task_init+0xb0>
                       PERM_A | PERM_U | PERM_R | PERM_W | PERM_V);
    }

    printk("...task_init done!\n");
ffffffe000200e30:	00003517          	auipc	a0,0x3
ffffffe000200e34:	20050513          	addi	a0,a0,512 # ffffffe000204030 <_srodata+0x30>
ffffffe000200e38:	7f9010ef          	jal	ffffffe000202e30 <printk>
}
ffffffe000200e3c:	00000013          	nop
ffffffe000200e40:	03813083          	ld	ra,56(sp)
ffffffe000200e44:	03013403          	ld	s0,48(sp)
ffffffe000200e48:	02813483          	ld	s1,40(sp)
ffffffe000200e4c:	04010113          	addi	sp,sp,64
ffffffe000200e50:	00008067          	ret

ffffffe000200e54 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe000200e54:	fd010113          	addi	sp,sp,-48
ffffffe000200e58:	02113423          	sd	ra,40(sp)
ffffffe000200e5c:	02813023          	sd	s0,32(sp)
ffffffe000200e60:	03010413          	addi	s0,sp,48
    uint64_t MOD                = 1000000007;
ffffffe000200e64:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000200e68:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe000200e6c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000200e70:	fe043423          	sd	zero,-24(s0)
    int last_counter            = -1;
ffffffe000200e74:	fff00793          	li	a5,-1
ffffffe000200e78:	fef42223          	sw	a5,-28(s0)

    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200e7c:	fe442783          	lw	a5,-28(s0)
ffffffe000200e80:	0007871b          	sext.w	a4,a5
ffffffe000200e84:	fff00793          	li	a5,-1
ffffffe000200e88:	00f70e63          	beq	a4,a5,ffffffe000200ea4 <dummy+0x50>
ffffffe000200e8c:	00008797          	auipc	a5,0x8
ffffffe000200e90:	18478793          	addi	a5,a5,388 # ffffffe000209010 <current>
ffffffe000200e94:	0007b783          	ld	a5,0(a5)
ffffffe000200e98:	0087b703          	ld	a4,8(a5)
ffffffe000200e9c:	fe442783          	lw	a5,-28(s0)
ffffffe000200ea0:	fcf70ee3          	beq	a4,a5,ffffffe000200e7c <dummy+0x28>
ffffffe000200ea4:	00008797          	auipc	a5,0x8
ffffffe000200ea8:	16c78793          	addi	a5,a5,364 # ffffffe000209010 <current>
ffffffe000200eac:	0007b783          	ld	a5,0(a5)
ffffffe000200eb0:	0087b783          	ld	a5,8(a5)
ffffffe000200eb4:	fc0784e3          	beqz	a5,ffffffe000200e7c <dummy+0x28>
            if (current->counter == 1) {
ffffffe000200eb8:	00008797          	auipc	a5,0x8
ffffffe000200ebc:	15878793          	addi	a5,a5,344 # ffffffe000209010 <current>
ffffffe000200ec0:	0007b783          	ld	a5,0(a5)
ffffffe000200ec4:	0087b703          	ld	a4,8(a5)
ffffffe000200ec8:	00100793          	li	a5,1
ffffffe000200ecc:	00f71e63          	bne	a4,a5,ffffffe000200ee8 <dummy+0x94>
                --(current->counter);  // forced the counter to be zero if this thread is
ffffffe000200ed0:	00008797          	auipc	a5,0x8
ffffffe000200ed4:	14078793          	addi	a5,a5,320 # ffffffe000209010 <current>
ffffffe000200ed8:	0007b783          	ld	a5,0(a5)
ffffffe000200edc:	0087b703          	ld	a4,8(a5)
ffffffe000200ee0:	fff70713          	addi	a4,a4,-1
ffffffe000200ee4:	00e7b423          	sd	a4,8(a5)
                                       // going to be scheduled
            }  // in case that the new counter is also 1, leading the information not
               // printed.
            last_counter       = current->counter;
ffffffe000200ee8:	00008797          	auipc	a5,0x8
ffffffe000200eec:	12878793          	addi	a5,a5,296 # ffffffe000209010 <current>
ffffffe000200ef0:	0007b783          	ld	a5,0(a5)
ffffffe000200ef4:	0087b783          	ld	a5,8(a5)
ffffffe000200ef8:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe000200efc:	fe843783          	ld	a5,-24(s0)
ffffffe000200f00:	00178713          	addi	a4,a5,1
ffffffe000200f04:	fd843783          	ld	a5,-40(s0)
ffffffe000200f08:	02f777b3          	remu	a5,a4,a5
ffffffe000200f0c:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid,
ffffffe000200f10:	00008797          	auipc	a5,0x8
ffffffe000200f14:	10078793          	addi	a5,a5,256 # ffffffe000209010 <current>
ffffffe000200f18:	0007b783          	ld	a5,0(a5)
ffffffe000200f1c:	0187b783          	ld	a5,24(a5)
ffffffe000200f20:	fe843603          	ld	a2,-24(s0)
ffffffe000200f24:	00078593          	mv	a1,a5
ffffffe000200f28:	00003517          	auipc	a0,0x3
ffffffe000200f2c:	12050513          	addi	a0,a0,288 # ffffffe000204048 <_srodata+0x48>
ffffffe000200f30:	701010ef          	jal	ffffffe000202e30 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200f34:	f49ff06f          	j	ffffffe000200e7c <dummy+0x28>

ffffffe000200f38 <switch_mm>:
#endif
        }
    }
}

void switch_mm(struct task_struct* next) {
ffffffe000200f38:	fd010113          	addi	sp,sp,-48
ffffffe000200f3c:	02813423          	sd	s0,40(sp)
ffffffe000200f40:	03010413          	addi	s0,sp,48
ffffffe000200f44:	fca43c23          	sd	a0,-40(s0)
    // Prepare satp
    uint64_t satp;
    satp = (((uint64_t)next->pgd >> PGSHIFT) & PPN_MASK) | (0x8L << 60);
ffffffe000200f48:	fd843783          	ld	a5,-40(s0)
ffffffe000200f4c:	0a87b783          	ld	a5,168(a5)
ffffffe000200f50:	00c7d713          	srli	a4,a5,0xc
ffffffe000200f54:	fff00793          	li	a5,-1
ffffffe000200f58:	0147d793          	srli	a5,a5,0x14
ffffffe000200f5c:	00f77733          	and	a4,a4,a5
ffffffe000200f60:	fff00793          	li	a5,-1
ffffffe000200f64:	03f79793          	slli	a5,a5,0x3f
ffffffe000200f68:	00f767b3          	or	a5,a4,a5
ffffffe000200f6c:	fef43423          	sd	a5,-24(s0)
    asm volatile("csrw satp, %0" : : "r"(satp));
ffffffe000200f70:	fe843783          	ld	a5,-24(s0)
ffffffe000200f74:	18079073          	csrw	satp,a5
    // flush tlb and icache
    asm volatile("sfence.vma");
ffffffe000200f78:	12000073          	sfence.vma
}
ffffffe000200f7c:	00000013          	nop
ffffffe000200f80:	02813403          	ld	s0,40(sp)
ffffffe000200f84:	03010113          	addi	sp,sp,48
ffffffe000200f88:	00008067          	ret

ffffffe000200f8c <switch_to>:

void switch_to(struct task_struct* next) {
ffffffe000200f8c:	fd010113          	addi	sp,sp,-48
ffffffe000200f90:	02113423          	sd	ra,40(sp)
ffffffe000200f94:	02813023          	sd	s0,32(sp)
ffffffe000200f98:	03010413          	addi	s0,sp,48
ffffffe000200f9c:	fca43c23          	sd	a0,-40(s0)
    if (next == current) return;
ffffffe000200fa0:	00008797          	auipc	a5,0x8
ffffffe000200fa4:	07078793          	addi	a5,a5,112 # ffffffe000209010 <current>
ffffffe000200fa8:	0007b783          	ld	a5,0(a5)
ffffffe000200fac:	fd843703          	ld	a4,-40(s0)
ffffffe000200fb0:	08f70663          	beq	a4,a5,ffffffe00020103c <switch_to+0xb0>

    Log("Switching from %p (counter: %lld) to %p (counter: %lld)", current, current->counter, next,
ffffffe000200fb4:	00008797          	auipc	a5,0x8
ffffffe000200fb8:	05c78793          	addi	a5,a5,92 # ffffffe000209010 <current>
ffffffe000200fbc:	0007b703          	ld	a4,0(a5)
ffffffe000200fc0:	00008797          	auipc	a5,0x8
ffffffe000200fc4:	05078793          	addi	a5,a5,80 # ffffffe000209010 <current>
ffffffe000200fc8:	0007b783          	ld	a5,0(a5)
ffffffe000200fcc:	0087b683          	ld	a3,8(a5)
ffffffe000200fd0:	fd843783          	ld	a5,-40(s0)
ffffffe000200fd4:	0087b783          	ld	a5,8(a5)
ffffffe000200fd8:	00078893          	mv	a7,a5
ffffffe000200fdc:	fd843803          	ld	a6,-40(s0)
ffffffe000200fe0:	00068793          	mv	a5,a3
ffffffe000200fe4:	08f00693          	li	a3,143
ffffffe000200fe8:	00003617          	auipc	a2,0x3
ffffffe000200fec:	09060613          	addi	a2,a2,144 # ffffffe000204078 <_srodata+0x78>
ffffffe000200ff0:	00003597          	auipc	a1,0x3
ffffffe000200ff4:	3c058593          	addi	a1,a1,960 # ffffffe0002043b0 <__func__.2>
ffffffe000200ff8:	00003517          	auipc	a0,0x3
ffffffe000200ffc:	08850513          	addi	a0,a0,136 # ffffffe000204080 <_srodata+0x80>
ffffffe000201000:	631010ef          	jal	ffffffe000202e30 <printk>
        next->counter);
    // switch to next process
    struct task_struct* prev = current;
ffffffe000201004:	00008797          	auipc	a5,0x8
ffffffe000201008:	00c78793          	addi	a5,a5,12 # ffffffe000209010 <current>
ffffffe00020100c:	0007b783          	ld	a5,0(a5)
ffffffe000201010:	fef43423          	sd	a5,-24(s0)
    current                  = next;
ffffffe000201014:	00008797          	auipc	a5,0x8
ffffffe000201018:	ffc78793          	addi	a5,a5,-4 # ffffffe000209010 <current>
ffffffe00020101c:	fd843703          	ld	a4,-40(s0)
ffffffe000201020:	00e7b023          	sd	a4,0(a5)
    switch_mm(next);
ffffffe000201024:	fd843503          	ld	a0,-40(s0)
ffffffe000201028:	f11ff0ef          	jal	ffffffe000200f38 <switch_mm>
    __switch_to(prev, next);
ffffffe00020102c:	fd843583          	ld	a1,-40(s0)
ffffffe000201030:	fe843503          	ld	a0,-24(s0)
ffffffe000201034:	9b8ff0ef          	jal	ffffffe0002001ec <__switch_to>
ffffffe000201038:	0080006f          	j	ffffffe000201040 <switch_to+0xb4>
    if (next == current) return;
ffffffe00020103c:	00000013          	nop
}
ffffffe000201040:	02813083          	ld	ra,40(sp)
ffffffe000201044:	02013403          	ld	s0,32(sp)
ffffffe000201048:	03010113          	addi	sp,sp,48
ffffffe00020104c:	00008067          	ret

ffffffe000201050 <do_timer>:

void do_timer() {
ffffffe000201050:	ff010113          	addi	sp,sp,-16
ffffffe000201054:	00113423          	sd	ra,8(sp)
ffffffe000201058:	00813023          	sd	s0,0(sp)
ffffffe00020105c:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    if (current == idle || current->counter == 0) {
ffffffe000201060:	00008797          	auipc	a5,0x8
ffffffe000201064:	fb078793          	addi	a5,a5,-80 # ffffffe000209010 <current>
ffffffe000201068:	0007b703          	ld	a4,0(a5)
ffffffe00020106c:	00008797          	auipc	a5,0x8
ffffffe000201070:	f9c78793          	addi	a5,a5,-100 # ffffffe000209008 <idle>
ffffffe000201074:	0007b783          	ld	a5,0(a5)
ffffffe000201078:	00f70c63          	beq	a4,a5,ffffffe000201090 <do_timer+0x40>
ffffffe00020107c:	00008797          	auipc	a5,0x8
ffffffe000201080:	f9478793          	addi	a5,a5,-108 # ffffffe000209010 <current>
ffffffe000201084:	0007b783          	ld	a5,0(a5)
ffffffe000201088:	0087b783          	ld	a5,8(a5)
ffffffe00020108c:	02079663          	bnez	a5,ffffffe0002010b8 <do_timer+0x68>
        Log("branch 0 switch to");
ffffffe000201090:	09b00693          	li	a3,155
ffffffe000201094:	00003617          	auipc	a2,0x3
ffffffe000201098:	fe460613          	addi	a2,a2,-28 # ffffffe000204078 <_srodata+0x78>
ffffffe00020109c:	00003597          	auipc	a1,0x3
ffffffe0002010a0:	32458593          	addi	a1,a1,804 # ffffffe0002043c0 <__func__.1>
ffffffe0002010a4:	00003517          	auipc	a0,0x3
ffffffe0002010a8:	03c50513          	addi	a0,a0,60 # ffffffe0002040e0 <_srodata+0xe0>
ffffffe0002010ac:	585010ef          	jal	ffffffe000202e30 <printk>
        schedule();
ffffffe0002010b0:	0a0000ef          	jal	ffffffe000201150 <schedule>
        if (current->counter == 0) {
            Log("branch 1 switch to");
            schedule();
        }
    }
}
ffffffe0002010b4:	0880006f          	j	ffffffe00020113c <do_timer+0xec>
        current->counter--;
ffffffe0002010b8:	00008797          	auipc	a5,0x8
ffffffe0002010bc:	f5878793          	addi	a5,a5,-168 # ffffffe000209010 <current>
ffffffe0002010c0:	0007b783          	ld	a5,0(a5)
ffffffe0002010c4:	0087b703          	ld	a4,8(a5)
ffffffe0002010c8:	fff70713          	addi	a4,a4,-1
ffffffe0002010cc:	00e7b423          	sd	a4,8(a5)
        Log("Thread running, reducing counter %lld", current->counter);
ffffffe0002010d0:	00008797          	auipc	a5,0x8
ffffffe0002010d4:	f4078793          	addi	a5,a5,-192 # ffffffe000209010 <current>
ffffffe0002010d8:	0007b783          	ld	a5,0(a5)
ffffffe0002010dc:	0087b783          	ld	a5,8(a5)
ffffffe0002010e0:	00078713          	mv	a4,a5
ffffffe0002010e4:	0a100693          	li	a3,161
ffffffe0002010e8:	00003617          	auipc	a2,0x3
ffffffe0002010ec:	f9060613          	addi	a2,a2,-112 # ffffffe000204078 <_srodata+0x78>
ffffffe0002010f0:	00003597          	auipc	a1,0x3
ffffffe0002010f4:	2d058593          	addi	a1,a1,720 # ffffffe0002043c0 <__func__.1>
ffffffe0002010f8:	00003517          	auipc	a0,0x3
ffffffe0002010fc:	02850513          	addi	a0,a0,40 # ffffffe000204120 <_srodata+0x120>
ffffffe000201100:	531010ef          	jal	ffffffe000202e30 <printk>
        if (current->counter == 0) {
ffffffe000201104:	00008797          	auipc	a5,0x8
ffffffe000201108:	f0c78793          	addi	a5,a5,-244 # ffffffe000209010 <current>
ffffffe00020110c:	0007b783          	ld	a5,0(a5)
ffffffe000201110:	0087b783          	ld	a5,8(a5)
ffffffe000201114:	02079463          	bnez	a5,ffffffe00020113c <do_timer+0xec>
            Log("branch 1 switch to");
ffffffe000201118:	0a300693          	li	a3,163
ffffffe00020111c:	00003617          	auipc	a2,0x3
ffffffe000201120:	f5c60613          	addi	a2,a2,-164 # ffffffe000204078 <_srodata+0x78>
ffffffe000201124:	00003597          	auipc	a1,0x3
ffffffe000201128:	29c58593          	addi	a1,a1,668 # ffffffe0002043c0 <__func__.1>
ffffffe00020112c:	00003517          	auipc	a0,0x3
ffffffe000201130:	04450513          	addi	a0,a0,68 # ffffffe000204170 <_srodata+0x170>
ffffffe000201134:	4fd010ef          	jal	ffffffe000202e30 <printk>
            schedule();
ffffffe000201138:	018000ef          	jal	ffffffe000201150 <schedule>
}
ffffffe00020113c:	00000013          	nop
ffffffe000201140:	00813083          	ld	ra,8(sp)
ffffffe000201144:	00013403          	ld	s0,0(sp)
ffffffe000201148:	01010113          	addi	sp,sp,16
ffffffe00020114c:	00008067          	ret

ffffffe000201150 <schedule>:

void schedule() {
ffffffe000201150:	fd010113          	addi	sp,sp,-48
ffffffe000201154:	02113423          	sd	ra,40(sp)
ffffffe000201158:	02813023          	sd	s0,32(sp)
ffffffe00020115c:	03010413          	addi	s0,sp,48
    Log("Scheduling threads");
ffffffe000201160:	0aa00693          	li	a3,170
ffffffe000201164:	00003617          	auipc	a2,0x3
ffffffe000201168:	f1460613          	addi	a2,a2,-236 # ffffffe000204078 <_srodata+0x78>
ffffffe00020116c:	00003597          	auipc	a1,0x3
ffffffe000201170:	26458593          	addi	a1,a1,612 # ffffffe0002043d0 <__func__.0>
ffffffe000201174:	00003517          	auipc	a0,0x3
ffffffe000201178:	03c50513          	addi	a0,a0,60 # ffffffe0002041b0 <_srodata+0x1b0>
ffffffe00020117c:	4b5010ef          	jal	ffffffe000202e30 <printk>

    struct task_struct* next = idle;
ffffffe000201180:	00008797          	auipc	a5,0x8
ffffffe000201184:	e8878793          	addi	a5,a5,-376 # ffffffe000209008 <idle>
ffffffe000201188:	0007b783          	ld	a5,0(a5)
ffffffe00020118c:	fef43423          	sd	a5,-24(s0)

    while (true) {
        // Find thread with largest counter
        for (size_t i = 1; i < NR_TASKS; i++) {
ffffffe000201190:	00100793          	li	a5,1
ffffffe000201194:	fef43023          	sd	a5,-32(s0)
ffffffe000201198:	1000006f          	j	ffffffe000201298 <schedule+0x148>
            if (task[i] == NULL || next == NULL) {
ffffffe00020119c:	00008717          	auipc	a4,0x8
ffffffe0002011a0:	e9470713          	addi	a4,a4,-364 # ffffffe000209030 <task>
ffffffe0002011a4:	fe043783          	ld	a5,-32(s0)
ffffffe0002011a8:	00379793          	slli	a5,a5,0x3
ffffffe0002011ac:	00f707b3          	add	a5,a4,a5
ffffffe0002011b0:	0007b783          	ld	a5,0(a5)
ffffffe0002011b4:	00078663          	beqz	a5,ffffffe0002011c0 <schedule+0x70>
ffffffe0002011b8:	fe843783          	ld	a5,-24(s0)
ffffffe0002011bc:	08079263          	bnez	a5,ffffffe000201240 <schedule+0xf0>
                Log(RED
ffffffe0002011c0:	0b200693          	li	a3,178
ffffffe0002011c4:	00003617          	auipc	a2,0x3
ffffffe0002011c8:	eb460613          	addi	a2,a2,-332 # ffffffe000204078 <_srodata+0x78>
ffffffe0002011cc:	00003597          	auipc	a1,0x3
ffffffe0002011d0:	20458593          	addi	a1,a1,516 # ffffffe0002043d0 <__func__.0>
ffffffe0002011d4:	00003517          	auipc	a0,0x3
ffffffe0002011d8:	01c50513          	addi	a0,a0,28 # ffffffe0002041f0 <_srodata+0x1f0>
ffffffe0002011dc:	455010ef          	jal	ffffffe000202e30 <printk>
                    "Kernel panic! You may be enabled timer interrupt before " "task_init!" CLEAR);
                Log(RED "task[%d] or next is NULL pointer" CLEAR, i);
ffffffe0002011e0:	fe043703          	ld	a4,-32(s0)
ffffffe0002011e4:	0b400693          	li	a3,180
ffffffe0002011e8:	00003617          	auipc	a2,0x3
ffffffe0002011ec:	e9060613          	addi	a2,a2,-368 # ffffffe000204078 <_srodata+0x78>
ffffffe0002011f0:	00003597          	auipc	a1,0x3
ffffffe0002011f4:	1e058593          	addi	a1,a1,480 # ffffffe0002043d0 <__func__.0>
ffffffe0002011f8:	00003517          	auipc	a0,0x3
ffffffe0002011fc:	07050513          	addi	a0,a0,112 # ffffffe000204268 <_srodata+0x268>
ffffffe000201200:	431010ef          	jal	ffffffe000202e30 <printk>
                Log(RED "idle: %p" CLEAR, idle);
ffffffe000201204:	00008797          	auipc	a5,0x8
ffffffe000201208:	e0478793          	addi	a5,a5,-508 # ffffffe000209008 <idle>
ffffffe00020120c:	0007b783          	ld	a5,0(a5)
ffffffe000201210:	00078713          	mv	a4,a5
ffffffe000201214:	0b500693          	li	a3,181
ffffffe000201218:	00003617          	auipc	a2,0x3
ffffffe00020121c:	e6060613          	addi	a2,a2,-416 # ffffffe000204078 <_srodata+0x78>
ffffffe000201220:	00003597          	auipc	a1,0x3
ffffffe000201224:	1b058593          	addi	a1,a1,432 # ffffffe0002043d0 <__func__.0>
ffffffe000201228:	00003517          	auipc	a0,0x3
ffffffe00020122c:	09850513          	addi	a0,a0,152 # ffffffe0002042c0 <_srodata+0x2c0>
ffffffe000201230:	401010ef          	jal	ffffffe000202e30 <printk>
                sbi_system_reset(0, 0);
ffffffe000201234:	00000593          	li	a1,0
ffffffe000201238:	00000513          	li	a0,0
ffffffe00020123c:	48c000ef          	jal	ffffffe0002016c8 <sbi_system_reset>
            }

            if (task[i]->counter <= next->counter) continue;
ffffffe000201240:	00008717          	auipc	a4,0x8
ffffffe000201244:	df070713          	addi	a4,a4,-528 # ffffffe000209030 <task>
ffffffe000201248:	fe043783          	ld	a5,-32(s0)
ffffffe00020124c:	00379793          	slli	a5,a5,0x3
ffffffe000201250:	00f707b3          	add	a5,a4,a5
ffffffe000201254:	0007b783          	ld	a5,0(a5)
ffffffe000201258:	0087b703          	ld	a4,8(a5)
ffffffe00020125c:	fe843783          	ld	a5,-24(s0)
ffffffe000201260:	0087b783          	ld	a5,8(a5)
ffffffe000201264:	02e7f263          	bgeu	a5,a4,ffffffe000201288 <schedule+0x138>
            next = task[i];
ffffffe000201268:	00008717          	auipc	a4,0x8
ffffffe00020126c:	dc870713          	addi	a4,a4,-568 # ffffffe000209030 <task>
ffffffe000201270:	fe043783          	ld	a5,-32(s0)
ffffffe000201274:	00379793          	slli	a5,a5,0x3
ffffffe000201278:	00f707b3          	add	a5,a4,a5
ffffffe00020127c:	0007b783          	ld	a5,0(a5)
ffffffe000201280:	fef43423          	sd	a5,-24(s0)
ffffffe000201284:	0080006f          	j	ffffffe00020128c <schedule+0x13c>
            if (task[i]->counter <= next->counter) continue;
ffffffe000201288:	00000013          	nop
        for (size_t i = 1; i < NR_TASKS; i++) {
ffffffe00020128c:	fe043783          	ld	a5,-32(s0)
ffffffe000201290:	00178793          	addi	a5,a5,1
ffffffe000201294:	fef43023          	sd	a5,-32(s0)
ffffffe000201298:	fe043703          	ld	a4,-32(s0)
ffffffe00020129c:	00400793          	li	a5,4
ffffffe0002012a0:	eee7fee3          	bgeu	a5,a4,ffffffe00020119c <schedule+0x4c>
        }

        // If all running threads' counter are 0
        if (next == idle) {
ffffffe0002012a4:	00008797          	auipc	a5,0x8
ffffffe0002012a8:	d6478793          	addi	a5,a5,-668 # ffffffe000209008 <idle>
ffffffe0002012ac:	0007b783          	ld	a5,0(a5)
ffffffe0002012b0:	fe843703          	ld	a4,-24(s0)
ffffffe0002012b4:	0af71a63          	bne	a4,a5,ffffffe000201368 <schedule+0x218>
            // Set their counter to their priority, and reschedule
            for (size_t i = 1; i < NR_TASKS; i++) {
ffffffe0002012b8:	00100793          	li	a5,1
ffffffe0002012bc:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002012c0:	0940006f          	j	ffffffe000201354 <schedule+0x204>
                task[i]->counter = task[i]->priority;
ffffffe0002012c4:	00008717          	auipc	a4,0x8
ffffffe0002012c8:	d6c70713          	addi	a4,a4,-660 # ffffffe000209030 <task>
ffffffe0002012cc:	fd843783          	ld	a5,-40(s0)
ffffffe0002012d0:	00379793          	slli	a5,a5,0x3
ffffffe0002012d4:	00f707b3          	add	a5,a4,a5
ffffffe0002012d8:	0007b703          	ld	a4,0(a5)
ffffffe0002012dc:	00008697          	auipc	a3,0x8
ffffffe0002012e0:	d5468693          	addi	a3,a3,-684 # ffffffe000209030 <task>
ffffffe0002012e4:	fd843783          	ld	a5,-40(s0)
ffffffe0002012e8:	00379793          	slli	a5,a5,0x3
ffffffe0002012ec:	00f687b3          	add	a5,a3,a5
ffffffe0002012f0:	0007b783          	ld	a5,0(a5)
ffffffe0002012f4:	01073703          	ld	a4,16(a4)
ffffffe0002012f8:	00e7b423          	sd	a4,8(a5)
                printk("SET [PID = %lld PRIORITY = %lld COUNTER = %lld]\n", i, task[i]->priority,
ffffffe0002012fc:	00008717          	auipc	a4,0x8
ffffffe000201300:	d3470713          	addi	a4,a4,-716 # ffffffe000209030 <task>
ffffffe000201304:	fd843783          	ld	a5,-40(s0)
ffffffe000201308:	00379793          	slli	a5,a5,0x3
ffffffe00020130c:	00f707b3          	add	a5,a4,a5
ffffffe000201310:	0007b783          	ld	a5,0(a5)
ffffffe000201314:	0107b603          	ld	a2,16(a5)
                       task[i]->counter);
ffffffe000201318:	00008717          	auipc	a4,0x8
ffffffe00020131c:	d1870713          	addi	a4,a4,-744 # ffffffe000209030 <task>
ffffffe000201320:	fd843783          	ld	a5,-40(s0)
ffffffe000201324:	00379793          	slli	a5,a5,0x3
ffffffe000201328:	00f707b3          	add	a5,a4,a5
ffffffe00020132c:	0007b783          	ld	a5,0(a5)
                printk("SET [PID = %lld PRIORITY = %lld COUNTER = %lld]\n", i, task[i]->priority,
ffffffe000201330:	0087b783          	ld	a5,8(a5)
ffffffe000201334:	00078693          	mv	a3,a5
ffffffe000201338:	fd843583          	ld	a1,-40(s0)
ffffffe00020133c:	00003517          	auipc	a0,0x3
ffffffe000201340:	fc450513          	addi	a0,a0,-60 # ffffffe000204300 <_srodata+0x300>
ffffffe000201344:	2ed010ef          	jal	ffffffe000202e30 <printk>
            for (size_t i = 1; i < NR_TASKS; i++) {
ffffffe000201348:	fd843783          	ld	a5,-40(s0)
ffffffe00020134c:	00178793          	addi	a5,a5,1
ffffffe000201350:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201354:	fd843703          	ld	a4,-40(s0)
ffffffe000201358:	00400793          	li	a5,4
ffffffe00020135c:	f6e7f4e3          	bgeu	a5,a4,ffffffe0002012c4 <schedule+0x174>
            }
            continue;
ffffffe000201360:	00000013          	nop
        for (size_t i = 1; i < NR_TASKS; i++) {
ffffffe000201364:	e2dff06f          	j	ffffffe000201190 <schedule+0x40>
        }
        break;
ffffffe000201368:	00000013          	nop
    }

    // Switch to next process
    Log(BLUE "switch to [PID = %lld PRIORITY = %lld COUNTER = %lld]" CLEAR, next->pid,
ffffffe00020136c:	fe843783          	ld	a5,-24(s0)
ffffffe000201370:	0187b703          	ld	a4,24(a5)
ffffffe000201374:	fe843783          	ld	a5,-24(s0)
ffffffe000201378:	0107b683          	ld	a3,16(a5)
ffffffe00020137c:	fe843783          	ld	a5,-24(s0)
ffffffe000201380:	0087b783          	ld	a5,8(a5)
ffffffe000201384:	00078813          	mv	a6,a5
ffffffe000201388:	00068793          	mv	a5,a3
ffffffe00020138c:	0cb00693          	li	a3,203
ffffffe000201390:	00003617          	auipc	a2,0x3
ffffffe000201394:	ce860613          	addi	a2,a2,-792 # ffffffe000204078 <_srodata+0x78>
ffffffe000201398:	00003597          	auipc	a1,0x3
ffffffe00020139c:	03858593          	addi	a1,a1,56 # ffffffe0002043d0 <__func__.0>
ffffffe0002013a0:	00003517          	auipc	a0,0x3
ffffffe0002013a4:	f9850513          	addi	a0,a0,-104 # ffffffe000204338 <_srodata+0x338>
ffffffe0002013a8:	289010ef          	jal	ffffffe000202e30 <printk>
        next->priority, next->counter);
    switch_to(next);
ffffffe0002013ac:	fe843503          	ld	a0,-24(s0)
ffffffe0002013b0:	bddff0ef          	jal	ffffffe000200f8c <switch_to>
ffffffe0002013b4:	00000013          	nop
ffffffe0002013b8:	02813083          	ld	ra,40(sp)
ffffffe0002013bc:	02013403          	ld	s0,32(sp)
ffffffe0002013c0:	03010113          	addi	sp,sp,48
ffffffe0002013c4:	00008067          	ret

ffffffe0002013c8 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe0002013c8:	f9010113          	addi	sp,sp,-112
ffffffe0002013cc:	06813423          	sd	s0,104(sp)
ffffffe0002013d0:	07010413          	addi	s0,sp,112
ffffffe0002013d4:	fca43423          	sd	a0,-56(s0)
ffffffe0002013d8:	fcb43023          	sd	a1,-64(s0)
ffffffe0002013dc:	fac43c23          	sd	a2,-72(s0)
ffffffe0002013e0:	fad43823          	sd	a3,-80(s0)
ffffffe0002013e4:	fae43423          	sd	a4,-88(s0)
ffffffe0002013e8:	faf43023          	sd	a5,-96(s0)
ffffffe0002013ec:	f9043c23          	sd	a6,-104(s0)
ffffffe0002013f0:	f9143823          	sd	a7,-112(s0)
    asm volatile(
ffffffe0002013f4:	fc843783          	ld	a5,-56(s0)
ffffffe0002013f8:	fc043703          	ld	a4,-64(s0)
ffffffe0002013fc:	fb843683          	ld	a3,-72(s0)
ffffffe000201400:	fb043603          	ld	a2,-80(s0)
ffffffe000201404:	fa843583          	ld	a1,-88(s0)
ffffffe000201408:	fa043503          	ld	a0,-96(s0)
ffffffe00020140c:	f9843803          	ld	a6,-104(s0)
ffffffe000201410:	f9043883          	ld	a7,-112(s0)
ffffffe000201414:	00078893          	mv	a7,a5
ffffffe000201418:	00070813          	mv	a6,a4
ffffffe00020141c:	00068513          	mv	a0,a3
ffffffe000201420:	00060593          	mv	a1,a2
ffffffe000201424:	00058613          	mv	a2,a1
ffffffe000201428:	00050693          	mv	a3,a0
ffffffe00020142c:	00080713          	mv	a4,a6
ffffffe000201430:	00088793          	mv	a5,a7
        : [eid] "r" (eid), [fid] "r" (fid),
          [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2),
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
    );

    asm volatile("ecall");
ffffffe000201434:	00000073          	ecall

    struct sbiret ret_val;
    asm volatile(
ffffffe000201438:	00050713          	mv	a4,a0
ffffffe00020143c:	00058793          	mv	a5,a1
ffffffe000201440:	fce43823          	sd	a4,-48(s0)
ffffffe000201444:	fcf43c23          	sd	a5,-40(s0)
        "mv %[value], a1\n"
        : [error] "=r" (ret_val.error),
          [value] "=r" (ret_val.value)
    );

    return ret_val;
ffffffe000201448:	fd043783          	ld	a5,-48(s0)
ffffffe00020144c:	fef43023          	sd	a5,-32(s0)
ffffffe000201450:	fd843783          	ld	a5,-40(s0)
ffffffe000201454:	fef43423          	sd	a5,-24(s0)
ffffffe000201458:	fe043703          	ld	a4,-32(s0)
ffffffe00020145c:	fe843783          	ld	a5,-24(s0)
ffffffe000201460:	00070313          	mv	t1,a4
ffffffe000201464:	00078393          	mv	t2,a5
ffffffe000201468:	00030713          	mv	a4,t1
ffffffe00020146c:	00038793          	mv	a5,t2
}
ffffffe000201470:	00070513          	mv	a0,a4
ffffffe000201474:	00078593          	mv	a1,a5
ffffffe000201478:	06813403          	ld	s0,104(sp)
ffffffe00020147c:	07010113          	addi	sp,sp,112
ffffffe000201480:	00008067          	ret

ffffffe000201484 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
ffffffe000201484:	fc010113          	addi	sp,sp,-64
ffffffe000201488:	02113c23          	sd	ra,56(sp)
ffffffe00020148c:	02813823          	sd	s0,48(sp)
ffffffe000201490:	03213423          	sd	s2,40(sp)
ffffffe000201494:	03313023          	sd	s3,32(sp)
ffffffe000201498:	04010413          	addi	s0,sp,64
ffffffe00020149c:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
ffffffe0002014a0:	00000893          	li	a7,0
ffffffe0002014a4:	00000813          	li	a6,0
ffffffe0002014a8:	00000793          	li	a5,0
ffffffe0002014ac:	00000713          	li	a4,0
ffffffe0002014b0:	00000693          	li	a3,0
ffffffe0002014b4:	fc843603          	ld	a2,-56(s0)
ffffffe0002014b8:	00000593          	li	a1,0
ffffffe0002014bc:	54495537          	lui	a0,0x54495
ffffffe0002014c0:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe0002014c4:	f05ff0ef          	jal	ffffffe0002013c8 <sbi_ecall>
ffffffe0002014c8:	00050713          	mv	a4,a0
ffffffe0002014cc:	00058793          	mv	a5,a1
ffffffe0002014d0:	fce43823          	sd	a4,-48(s0)
ffffffe0002014d4:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002014d8:	fd043703          	ld	a4,-48(s0)
ffffffe0002014dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002014e0:	00070913          	mv	s2,a4
ffffffe0002014e4:	00078993          	mv	s3,a5
ffffffe0002014e8:	00090713          	mv	a4,s2
ffffffe0002014ec:	00098793          	mv	a5,s3
}
ffffffe0002014f0:	00070513          	mv	a0,a4
ffffffe0002014f4:	00078593          	mv	a1,a5
ffffffe0002014f8:	03813083          	ld	ra,56(sp)
ffffffe0002014fc:	03013403          	ld	s0,48(sp)
ffffffe000201500:	02813903          	ld	s2,40(sp)
ffffffe000201504:	02013983          	ld	s3,32(sp)
ffffffe000201508:	04010113          	addi	sp,sp,64
ffffffe00020150c:	00008067          	ret

ffffffe000201510 <sbi_debug_console_write>:

struct sbiret sbi_debug_console_write(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi) {
ffffffe000201510:	fb010113          	addi	sp,sp,-80
ffffffe000201514:	04113423          	sd	ra,72(sp)
ffffffe000201518:	04813023          	sd	s0,64(sp)
ffffffe00020151c:	03213c23          	sd	s2,56(sp)
ffffffe000201520:	03313823          	sd	s3,48(sp)
ffffffe000201524:	05010413          	addi	s0,sp,80
ffffffe000201528:	fca43423          	sd	a0,-56(s0)
ffffffe00020152c:	fcb43023          	sd	a1,-64(s0)
ffffffe000201530:	fac43c23          	sd	a2,-72(s0)
    return sbi_ecall(0x4442434E, 0x0, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
ffffffe000201534:	00000893          	li	a7,0
ffffffe000201538:	00000813          	li	a6,0
ffffffe00020153c:	00000793          	li	a5,0
ffffffe000201540:	fb843703          	ld	a4,-72(s0)
ffffffe000201544:	fc043683          	ld	a3,-64(s0)
ffffffe000201548:	fc843603          	ld	a2,-56(s0)
ffffffe00020154c:	00000593          	li	a1,0
ffffffe000201550:	44424537          	lui	a0,0x44424
ffffffe000201554:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201558:	e71ff0ef          	jal	ffffffe0002013c8 <sbi_ecall>
ffffffe00020155c:	00050713          	mv	a4,a0
ffffffe000201560:	00058793          	mv	a5,a1
ffffffe000201564:	fce43823          	sd	a4,-48(s0)
ffffffe000201568:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020156c:	fd043703          	ld	a4,-48(s0)
ffffffe000201570:	fd843783          	ld	a5,-40(s0)
ffffffe000201574:	00070913          	mv	s2,a4
ffffffe000201578:	00078993          	mv	s3,a5
ffffffe00020157c:	00090713          	mv	a4,s2
ffffffe000201580:	00098793          	mv	a5,s3
}
ffffffe000201584:	00070513          	mv	a0,a4
ffffffe000201588:	00078593          	mv	a1,a5
ffffffe00020158c:	04813083          	ld	ra,72(sp)
ffffffe000201590:	04013403          	ld	s0,64(sp)
ffffffe000201594:	03813903          	ld	s2,56(sp)
ffffffe000201598:	03013983          	ld	s3,48(sp)
ffffffe00020159c:	05010113          	addi	sp,sp,80
ffffffe0002015a0:	00008067          	ret

ffffffe0002015a4 <sbi_debug_console_read>:

struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi) {
ffffffe0002015a4:	fb010113          	addi	sp,sp,-80
ffffffe0002015a8:	04113423          	sd	ra,72(sp)
ffffffe0002015ac:	04813023          	sd	s0,64(sp)
ffffffe0002015b0:	03213c23          	sd	s2,56(sp)
ffffffe0002015b4:	03313823          	sd	s3,48(sp)
ffffffe0002015b8:	05010413          	addi	s0,sp,80
ffffffe0002015bc:	fca43423          	sd	a0,-56(s0)
ffffffe0002015c0:	fcb43023          	sd	a1,-64(s0)
ffffffe0002015c4:	fac43c23          	sd	a2,-72(s0)
    return sbi_ecall(0x4442434E, 0x1, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
ffffffe0002015c8:	00000893          	li	a7,0
ffffffe0002015cc:	00000813          	li	a6,0
ffffffe0002015d0:	00000793          	li	a5,0
ffffffe0002015d4:	fb843703          	ld	a4,-72(s0)
ffffffe0002015d8:	fc043683          	ld	a3,-64(s0)
ffffffe0002015dc:	fc843603          	ld	a2,-56(s0)
ffffffe0002015e0:	00100593          	li	a1,1
ffffffe0002015e4:	44424537          	lui	a0,0x44424
ffffffe0002015e8:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe0002015ec:	dddff0ef          	jal	ffffffe0002013c8 <sbi_ecall>
ffffffe0002015f0:	00050713          	mv	a4,a0
ffffffe0002015f4:	00058793          	mv	a5,a1
ffffffe0002015f8:	fce43823          	sd	a4,-48(s0)
ffffffe0002015fc:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201600:	fd043703          	ld	a4,-48(s0)
ffffffe000201604:	fd843783          	ld	a5,-40(s0)
ffffffe000201608:	00070913          	mv	s2,a4
ffffffe00020160c:	00078993          	mv	s3,a5
ffffffe000201610:	00090713          	mv	a4,s2
ffffffe000201614:	00098793          	mv	a5,s3
}
ffffffe000201618:	00070513          	mv	a0,a4
ffffffe00020161c:	00078593          	mv	a1,a5
ffffffe000201620:	04813083          	ld	ra,72(sp)
ffffffe000201624:	04013403          	ld	s0,64(sp)
ffffffe000201628:	03813903          	ld	s2,56(sp)
ffffffe00020162c:	03013983          	ld	s3,48(sp)
ffffffe000201630:	05010113          	addi	sp,sp,80
ffffffe000201634:	00008067          	ret

ffffffe000201638 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000201638:	fc010113          	addi	sp,sp,-64
ffffffe00020163c:	02113c23          	sd	ra,56(sp)
ffffffe000201640:	02813823          	sd	s0,48(sp)
ffffffe000201644:	03213423          	sd	s2,40(sp)
ffffffe000201648:	03313023          	sd	s3,32(sp)
ffffffe00020164c:	04010413          	addi	s0,sp,64
ffffffe000201650:	00050793          	mv	a5,a0
ffffffe000201654:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
ffffffe000201658:	fcf44603          	lbu	a2,-49(s0)
ffffffe00020165c:	00000893          	li	a7,0
ffffffe000201660:	00000813          	li	a6,0
ffffffe000201664:	00000793          	li	a5,0
ffffffe000201668:	00000713          	li	a4,0
ffffffe00020166c:	00000693          	li	a3,0
ffffffe000201670:	00200593          	li	a1,2
ffffffe000201674:	44424537          	lui	a0,0x44424
ffffffe000201678:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe00020167c:	d4dff0ef          	jal	ffffffe0002013c8 <sbi_ecall>
ffffffe000201680:	00050713          	mv	a4,a0
ffffffe000201684:	00058793          	mv	a5,a1
ffffffe000201688:	fce43823          	sd	a4,-48(s0)
ffffffe00020168c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201690:	fd043703          	ld	a4,-48(s0)
ffffffe000201694:	fd843783          	ld	a5,-40(s0)
ffffffe000201698:	00070913          	mv	s2,a4
ffffffe00020169c:	00078993          	mv	s3,a5
ffffffe0002016a0:	00090713          	mv	a4,s2
ffffffe0002016a4:	00098793          	mv	a5,s3
}
ffffffe0002016a8:	00070513          	mv	a0,a4
ffffffe0002016ac:	00078593          	mv	a1,a5
ffffffe0002016b0:	03813083          	ld	ra,56(sp)
ffffffe0002016b4:	03013403          	ld	s0,48(sp)
ffffffe0002016b8:	02813903          	ld	s2,40(sp)
ffffffe0002016bc:	02013983          	ld	s3,32(sp)
ffffffe0002016c0:	04010113          	addi	sp,sp,64
ffffffe0002016c4:	00008067          	ret

ffffffe0002016c8 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe0002016c8:	fc010113          	addi	sp,sp,-64
ffffffe0002016cc:	02113c23          	sd	ra,56(sp)
ffffffe0002016d0:	02813823          	sd	s0,48(sp)
ffffffe0002016d4:	03213423          	sd	s2,40(sp)
ffffffe0002016d8:	03313023          	sd	s3,32(sp)
ffffffe0002016dc:	04010413          	addi	s0,sp,64
ffffffe0002016e0:	00050793          	mv	a5,a0
ffffffe0002016e4:	00058713          	mv	a4,a1
ffffffe0002016e8:	fcf42623          	sw	a5,-52(s0)
ffffffe0002016ec:	00070793          	mv	a5,a4
ffffffe0002016f0:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe0002016f4:	fcc46603          	lwu	a2,-52(s0)
ffffffe0002016f8:	fc846683          	lwu	a3,-56(s0)
ffffffe0002016fc:	00000893          	li	a7,0
ffffffe000201700:	00000813          	li	a6,0
ffffffe000201704:	00000793          	li	a5,0
ffffffe000201708:	00000713          	li	a4,0
ffffffe00020170c:	00000593          	li	a1,0
ffffffe000201710:	53525537          	lui	a0,0x53525
ffffffe000201714:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe000201718:	cb1ff0ef          	jal	ffffffe0002013c8 <sbi_ecall>
ffffffe00020171c:	00050713          	mv	a4,a0
ffffffe000201720:	00058793          	mv	a5,a1
ffffffe000201724:	fce43823          	sd	a4,-48(s0)
ffffffe000201728:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020172c:	fd043703          	ld	a4,-48(s0)
ffffffe000201730:	fd843783          	ld	a5,-40(s0)
ffffffe000201734:	00070913          	mv	s2,a4
ffffffe000201738:	00078993          	mv	s3,a5
ffffffe00020173c:	00090713          	mv	a4,s2
ffffffe000201740:	00098793          	mv	a5,s3
}
ffffffe000201744:	00070513          	mv	a0,a4
ffffffe000201748:	00078593          	mv	a1,a5
ffffffe00020174c:	03813083          	ld	ra,56(sp)
ffffffe000201750:	03013403          	ld	s0,48(sp)
ffffffe000201754:	02813903          	ld	s2,40(sp)
ffffffe000201758:	02013983          	ld	s3,32(sp)
ffffffe00020175c:	04010113          	addi	sp,sp,64
ffffffe000201760:	00008067          	ret

ffffffe000201764 <trap_handler>:
#define SUPERVISOR_TIMER_INTERRUPT 5
#define SUPERVISOR_INST_PAGE_FAULT 12
#define SUPERVISOR_LOAD_PAGE_FAULT 13
#define SUPERVISOR_STORE_PAGE_FAULT 15

void trap_handler(uint64_t scause, uint64_t sepc) {
ffffffe000201764:	fd010113          	addi	sp,sp,-48
ffffffe000201768:	02113423          	sd	ra,40(sp)
ffffffe00020176c:	02813023          	sd	s0,32(sp)
ffffffe000201770:	03010413          	addi	s0,sp,48
ffffffe000201774:	fca43c23          	sd	a0,-40(s0)
ffffffe000201778:	fcb43823          	sd	a1,-48(s0)
    // 通过 `scause` 判断 trap 类型
    uint64_t interrupt      = (scause >> 63) & 0b1;
ffffffe00020177c:	fd843783          	ld	a5,-40(s0)
ffffffe000201780:	03f7d793          	srli	a5,a5,0x3f
ffffffe000201784:	fef43423          	sd	a5,-24(s0)
    uint64_t exception_code = (scause & 0x7FFFFFFF);
ffffffe000201788:	fd843703          	ld	a4,-40(s0)
ffffffe00020178c:	800007b7          	lui	a5,0x80000
ffffffe000201790:	fff7c793          	not	a5,a5
ffffffe000201794:	00f777b3          	and	a5,a4,a5
ffffffe000201798:	fef43023          	sd	a5,-32(s0)

    printk("Trap exception code: %llx, sepc: %llx\n", scause, sepc);
ffffffe00020179c:	fd043603          	ld	a2,-48(s0)
ffffffe0002017a0:	fd843583          	ld	a1,-40(s0)
ffffffe0002017a4:	00003517          	auipc	a0,0x3
ffffffe0002017a8:	c3c50513          	addi	a0,a0,-964 # ffffffe0002043e0 <__func__.0+0x10>
ffffffe0002017ac:	684010ef          	jal	ffffffe000202e30 <printk>

    // 如果是 interrupt 判断是否是 timer interrupt
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
    if (interrupt && exception_code == SUPERVISOR_TIMER_INTERRUPT) {
ffffffe0002017b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002017b4:	02078863          	beqz	a5,ffffffe0002017e4 <trap_handler+0x80>
ffffffe0002017b8:	fe043703          	ld	a4,-32(s0)
ffffffe0002017bc:	00500793          	li	a5,5
ffffffe0002017c0:	02f71263          	bne	a4,a5,ffffffe0002017e4 <trap_handler+0x80>
        printk("Timer Interrupt %llx, %llx\n", interrupt, exception_code);
ffffffe0002017c4:	fe043603          	ld	a2,-32(s0)
ffffffe0002017c8:	fe843583          	ld	a1,-24(s0)
ffffffe0002017cc:	00003517          	auipc	a0,0x3
ffffffe0002017d0:	c3c50513          	addi	a0,a0,-964 # ffffffe000204408 <__func__.0+0x38>
ffffffe0002017d4:	65c010ef          	jal	ffffffe000202e30 <printk>
        clock_set_next_event();
ffffffe0002017d8:	ae1fe0ef          	jal	ffffffe0002002b8 <clock_set_next_event>
        do_timer();
ffffffe0002017dc:	875ff0ef          	jal	ffffffe000201050 <do_timer>
ffffffe0002017e0:	0940006f          	j	ffffffe000201874 <trap_handler+0x110>
    } else {
        switch (exception_code) {
ffffffe0002017e4:	fe043703          	ld	a4,-32(s0)
ffffffe0002017e8:	00f00793          	li	a5,15
ffffffe0002017ec:	04f70063          	beq	a4,a5,ffffffe00020182c <trap_handler+0xc8>
ffffffe0002017f0:	fe043703          	ld	a4,-32(s0)
ffffffe0002017f4:	00f00793          	li	a5,15
ffffffe0002017f8:	06e7e263          	bltu	a5,a4,ffffffe00020185c <trap_handler+0xf8>
ffffffe0002017fc:	fe043703          	ld	a4,-32(s0)
ffffffe000201800:	00c00793          	li	a5,12
ffffffe000201804:	04f70063          	beq	a4,a5,ffffffe000201844 <trap_handler+0xe0>
ffffffe000201808:	fe043703          	ld	a4,-32(s0)
ffffffe00020180c:	00d00793          	li	a5,13
ffffffe000201810:	04f71663          	bne	a4,a5,ffffffe00020185c <trap_handler+0xf8>
            case SUPERVISOR_LOAD_PAGE_FAULT:
                printk("Load Page Fault %llx, %llx\n", interrupt, exception_code);
ffffffe000201814:	fe043603          	ld	a2,-32(s0)
ffffffe000201818:	fe843583          	ld	a1,-24(s0)
ffffffe00020181c:	00003517          	auipc	a0,0x3
ffffffe000201820:	c0c50513          	addi	a0,a0,-1012 # ffffffe000204428 <__func__.0+0x58>
ffffffe000201824:	60c010ef          	jal	ffffffe000202e30 <printk>
                break;
ffffffe000201828:	04c0006f          	j	ffffffe000201874 <trap_handler+0x110>
            case SUPERVISOR_STORE_PAGE_FAULT:
                printk("Store/AMO Page Fault %llx, %llx\n", interrupt, exception_code);
ffffffe00020182c:	fe043603          	ld	a2,-32(s0)
ffffffe000201830:	fe843583          	ld	a1,-24(s0)
ffffffe000201834:	00003517          	auipc	a0,0x3
ffffffe000201838:	c1450513          	addi	a0,a0,-1004 # ffffffe000204448 <__func__.0+0x78>
ffffffe00020183c:	5f4010ef          	jal	ffffffe000202e30 <printk>
                break;
ffffffe000201840:	0340006f          	j	ffffffe000201874 <trap_handler+0x110>
            case SUPERVISOR_INST_PAGE_FAULT:
                printk("Instruction Page Fault %llx, %llx\n", interrupt, exception_code);
ffffffe000201844:	fe043603          	ld	a2,-32(s0)
ffffffe000201848:	fe843583          	ld	a1,-24(s0)
ffffffe00020184c:	00003517          	auipc	a0,0x3
ffffffe000201850:	c2450513          	addi	a0,a0,-988 # ffffffe000204470 <__func__.0+0xa0>
ffffffe000201854:	5dc010ef          	jal	ffffffe000202e30 <printk>
                break;
ffffffe000201858:	01c0006f          	j	ffffffe000201874 <trap_handler+0x110>
            default:
                printk("Unknown interrupt/exception %llx, %llx\n", interrupt, exception_code);
ffffffe00020185c:	fe043603          	ld	a2,-32(s0)
ffffffe000201860:	fe843583          	ld	a1,-24(s0)
ffffffe000201864:	00003517          	auipc	a0,0x3
ffffffe000201868:	c3450513          	addi	a0,a0,-972 # ffffffe000204498 <__func__.0+0xc8>
ffffffe00020186c:	5c4010ef          	jal	ffffffe000202e30 <printk>
                break;
ffffffe000201870:	00000013          	nop
        }
    }
ffffffe000201874:	00000013          	nop
ffffffe000201878:	02813083          	ld	ra,40(sp)
ffffffe00020187c:	02013403          	ld	s0,32(sp)
ffffffe000201880:	03010113          	addi	sp,sp,48
ffffffe000201884:	00008067          	ret

ffffffe000201888 <create_pte>:
extern uint8_t _ekernel[];

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

uint64_t create_pte(uint64_t pa) {
ffffffe000201888:	fd010113          	addi	sp,sp,-48
ffffffe00020188c:	02813423          	sd	s0,40(sp)
ffffffe000201890:	03010413          	addi	s0,sp,48
ffffffe000201894:	fca43c23          	sd	a0,-40(s0)
    uint64_t ppn = (pa >> 12) & PPN_MASK;
ffffffe000201898:	fd843783          	ld	a5,-40(s0)
ffffffe00020189c:	00c7d713          	srli	a4,a5,0xc
ffffffe0002018a0:	fff00793          	li	a5,-1
ffffffe0002018a4:	0147d793          	srli	a5,a5,0x14
ffffffe0002018a8:	00f777b3          	and	a5,a4,a5
ffffffe0002018ac:	fef43423          	sd	a5,-24(s0)
    // Accessed and dirty for 0x80000000 page
    uint64_t pte = (ppn << 10) | PERM_A | PERM_D | PERM_X | PERM_R | PERM_W | PERM_V;
ffffffe0002018b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002018b4:	00a79793          	slli	a5,a5,0xa
ffffffe0002018b8:	0cf7e793          	ori	a5,a5,207
ffffffe0002018bc:	fef43023          	sd	a5,-32(s0)
    return pte;
ffffffe0002018c0:	fe043783          	ld	a5,-32(s0)
}
ffffffe0002018c4:	00078513          	mv	a0,a5
ffffffe0002018c8:	02813403          	ld	s0,40(sp)
ffffffe0002018cc:	03010113          	addi	sp,sp,48
ffffffe0002018d0:	00008067          	ret

ffffffe0002018d4 <setup_vm>:

void setup_vm() {
ffffffe0002018d4:	fd010113          	addi	sp,sp,-48
ffffffe0002018d8:	02113423          	sd	ra,40(sp)
ffffffe0002018dc:	02813023          	sd	s0,32(sp)
ffffffe0002018e0:	03010413          	addi	s0,sp,48
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个
     *     entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
     **/
    Log("setup_vm: start");
ffffffe0002018e4:	02600693          	li	a3,38
ffffffe0002018e8:	00003617          	auipc	a2,0x3
ffffffe0002018ec:	bd860613          	addi	a2,a2,-1064 # ffffffe0002044c0 <__func__.0+0xf0>
ffffffe0002018f0:	00003597          	auipc	a1,0x3
ffffffe0002018f4:	d7858593          	addi	a1,a1,-648 # ffffffe000204668 <__func__.1>
ffffffe0002018f8:	00003517          	auipc	a0,0x3
ffffffe0002018fc:	bd050513          	addi	a0,a0,-1072 # ffffffe0002044c8 <__func__.0+0xf8>
ffffffe000201900:	530010ef          	jal	ffffffe000202e30 <printk>
    const uint64_t huge_page = 0x40000000;  // 1 GiB
ffffffe000201904:	400007b7          	lui	a5,0x40000
ffffffe000201908:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < PHY_SIZE; i += huge_page) {
ffffffe00020190c:	fe043423          	sd	zero,-24(s0)
ffffffe000201910:	0f40006f          	j	ffffffe000201a04 <setup_vm+0x130>
        // 9 bit vpn
        uint64_t identity_vpn   = ((PHY_START + i) >> 30) & 0x1ff;
ffffffe000201914:	fe843703          	ld	a4,-24(s0)
ffffffe000201918:	00100793          	li	a5,1
ffffffe00020191c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201920:	00f707b3          	add	a5,a4,a5
ffffffe000201924:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201928:	1ff7f793          	andi	a5,a5,511
ffffffe00020192c:	fcf43c23          	sd	a5,-40(s0)
        uint64_t direct_map_vpn = ((VM_START + i) >> 30) & 0x1ff;
ffffffe000201930:	fe843703          	ld	a4,-24(s0)
ffffffe000201934:	fff00793          	li	a5,-1
ffffffe000201938:	02579793          	slli	a5,a5,0x25
ffffffe00020193c:	00f707b3          	add	a5,a4,a5
ffffffe000201940:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201944:	1ff7f793          	andi	a5,a5,511
ffffffe000201948:	fcf43823          	sd	a5,-48(s0)

        printk("id vpn: %lx, %ld, dm vpn: %lx, %ld, pte: %lx\n", identity_vpn, identity_vpn,
ffffffe00020194c:	fe843703          	ld	a4,-24(s0)
ffffffe000201950:	00100793          	li	a5,1
ffffffe000201954:	01f79793          	slli	a5,a5,0x1f
ffffffe000201958:	00f707b3          	add	a5,a4,a5
ffffffe00020195c:	00078513          	mv	a0,a5
ffffffe000201960:	f29ff0ef          	jal	ffffffe000201888 <create_pte>
ffffffe000201964:	00050793          	mv	a5,a0
ffffffe000201968:	fd043703          	ld	a4,-48(s0)
ffffffe00020196c:	fd043683          	ld	a3,-48(s0)
ffffffe000201970:	fd843603          	ld	a2,-40(s0)
ffffffe000201974:	fd843583          	ld	a1,-40(s0)
ffffffe000201978:	00003517          	auipc	a0,0x3
ffffffe00020197c:	b8850513          	addi	a0,a0,-1144 # ffffffe000204500 <__func__.0+0x130>
ffffffe000201980:	4b0010ef          	jal	ffffffe000202e30 <printk>
               direct_map_vpn, direct_map_vpn, create_pte(PHY_START + i));

        // Create page table entry
        // early_pgtbl[identity_vpn]   = create_pte(PHY_START + i);
        early_pgtbl[direct_map_vpn] = create_pte(PHY_START + i);
ffffffe000201984:	fe843703          	ld	a4,-24(s0)
ffffffe000201988:	00100793          	li	a5,1
ffffffe00020198c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201990:	00f707b3          	add	a5,a4,a5
ffffffe000201994:	00078513          	mv	a0,a5
ffffffe000201998:	ef1ff0ef          	jal	ffffffe000201888 <create_pte>
ffffffe00020199c:	00050693          	mv	a3,a0
ffffffe0002019a0:	00008717          	auipc	a4,0x8
ffffffe0002019a4:	66070713          	addi	a4,a4,1632 # ffffffe00020a000 <early_pgtbl>
ffffffe0002019a8:	fd043783          	ld	a5,-48(s0)
ffffffe0002019ac:	00379793          	slli	a5,a5,0x3
ffffffe0002019b0:	00f707b3          	add	a5,a4,a5
ffffffe0002019b4:	00d7b023          	sd	a3,0(a5) # 40000000 <PHY_SIZE+0x38000000>
        Log("early_pgtbl[%lx] = %lx", identity_vpn, early_pgtbl[identity_vpn]);
ffffffe0002019b8:	00008717          	auipc	a4,0x8
ffffffe0002019bc:	64870713          	addi	a4,a4,1608 # ffffffe00020a000 <early_pgtbl>
ffffffe0002019c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002019c4:	00379793          	slli	a5,a5,0x3
ffffffe0002019c8:	00f707b3          	add	a5,a4,a5
ffffffe0002019cc:	0007b783          	ld	a5,0(a5)
ffffffe0002019d0:	fd843703          	ld	a4,-40(s0)
ffffffe0002019d4:	03300693          	li	a3,51
ffffffe0002019d8:	00003617          	auipc	a2,0x3
ffffffe0002019dc:	ae860613          	addi	a2,a2,-1304 # ffffffe0002044c0 <__func__.0+0xf0>
ffffffe0002019e0:	00003597          	auipc	a1,0x3
ffffffe0002019e4:	c8858593          	addi	a1,a1,-888 # ffffffe000204668 <__func__.1>
ffffffe0002019e8:	00003517          	auipc	a0,0x3
ffffffe0002019ec:	b4850513          	addi	a0,a0,-1208 # ffffffe000204530 <__func__.0+0x160>
ffffffe0002019f0:	440010ef          	jal	ffffffe000202e30 <printk>
    for (uint64_t i = 0; i < PHY_SIZE; i += huge_page) {
ffffffe0002019f4:	fe843703          	ld	a4,-24(s0)
ffffffe0002019f8:	fe043783          	ld	a5,-32(s0)
ffffffe0002019fc:	00f707b3          	add	a5,a4,a5
ffffffe000201a00:	fef43423          	sd	a5,-24(s0)
ffffffe000201a04:	fe843703          	ld	a4,-24(s0)
ffffffe000201a08:	080007b7          	lui	a5,0x8000
ffffffe000201a0c:	f0f764e3          	bltu	a4,a5,ffffffe000201914 <setup_vm+0x40>
    }
    Log("setup early page table at %p", early_pgtbl);
ffffffe000201a10:	00008717          	auipc	a4,0x8
ffffffe000201a14:	5f070713          	addi	a4,a4,1520 # ffffffe00020a000 <early_pgtbl>
ffffffe000201a18:	03500693          	li	a3,53
ffffffe000201a1c:	00003617          	auipc	a2,0x3
ffffffe000201a20:	aa460613          	addi	a2,a2,-1372 # ffffffe0002044c0 <__func__.0+0xf0>
ffffffe000201a24:	00003597          	auipc	a1,0x3
ffffffe000201a28:	c4458593          	addi	a1,a1,-956 # ffffffe000204668 <__func__.1>
ffffffe000201a2c:	00003517          	auipc	a0,0x3
ffffffe000201a30:	b4450513          	addi	a0,a0,-1212 # ffffffe000204570 <__func__.0+0x1a0>
ffffffe000201a34:	3fc010ef          	jal	ffffffe000202e30 <printk>
}
ffffffe000201a38:	00000013          	nop
ffffffe000201a3c:	02813083          	ld	ra,40(sp)
ffffffe000201a40:	02013403          	ld	s0,32(sp)
ffffffe000201a44:	03010113          	addi	sp,sp,48
ffffffe000201a48:	00008067          	ret

ffffffe000201a4c <create_mapping>:
/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t* pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000201a4c:	f2010113          	addi	sp,sp,-224
ffffffe000201a50:	0c113c23          	sd	ra,216(sp)
ffffffe000201a54:	0c813823          	sd	s0,208(sp)
ffffffe000201a58:	0e010413          	addi	s0,sp,224
ffffffe000201a5c:	f4a43423          	sd	a0,-184(s0)
ffffffe000201a60:	f4b43023          	sd	a1,-192(s0)
ffffffe000201a64:	f2c43c23          	sd	a2,-200(s0)
ffffffe000201a68:	f2d43823          	sd	a3,-208(s0)
ffffffe000201a6c:	f2e43423          	sd	a4,-216(s0)
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
     **/
    uint64_t ppn[3], vpn[3];
    // Page table walk: PGD -> PMD -> PTE
    for (uint64_t offset = 0; offset < sz; offset += PGSIZE) {
ffffffe000201a70:	fe043423          	sd	zero,-24(s0)
ffffffe000201a74:	2b00006f          	j	ffffffe000201d24 <create_mapping+0x2d8>
        uint64_t cur_pa  = pa + offset;
ffffffe000201a78:	f3843703          	ld	a4,-200(s0)
ffffffe000201a7c:	fe843783          	ld	a5,-24(s0)
ffffffe000201a80:	00f707b3          	add	a5,a4,a5
ffffffe000201a84:	fcf43823          	sd	a5,-48(s0)
        uint64_t cur_va  = va + offset;
ffffffe000201a88:	f4043703          	ld	a4,-192(s0)
ffffffe000201a8c:	fe843783          	ld	a5,-24(s0)
ffffffe000201a90:	00f707b3          	add	a5,a4,a5
ffffffe000201a94:	fcf43423          	sd	a5,-56(s0)
        uint64_t cur_ppn = (cur_pa >> 12) & PPN_MASK;
ffffffe000201a98:	fd043783          	ld	a5,-48(s0)
ffffffe000201a9c:	00c7d713          	srli	a4,a5,0xc
ffffffe000201aa0:	fff00793          	li	a5,-1
ffffffe000201aa4:	0147d793          	srli	a5,a5,0x14
ffffffe000201aa8:	00f777b3          	and	a5,a4,a5
ffffffe000201aac:	fcf43023          	sd	a5,-64(s0)
        // Calculate PPN and VPN
        ppn[0] = (cur_pa >> 12) & 0x1ff;
ffffffe000201ab0:	fd043783          	ld	a5,-48(s0)
ffffffe000201ab4:	00c7d793          	srli	a5,a5,0xc
ffffffe000201ab8:	1ff7f793          	andi	a5,a5,511
ffffffe000201abc:	f6f43423          	sd	a5,-152(s0)
        ppn[1] = (cur_pa >> 21) & 0x1ff;
ffffffe000201ac0:	fd043783          	ld	a5,-48(s0)
ffffffe000201ac4:	0157d793          	srli	a5,a5,0x15
ffffffe000201ac8:	1ff7f793          	andi	a5,a5,511
ffffffe000201acc:	f6f43823          	sd	a5,-144(s0)
        ppn[2] = (cur_pa >> 30) & 0x3ffffff;
ffffffe000201ad0:	fd043783          	ld	a5,-48(s0)
ffffffe000201ad4:	01e7d713          	srli	a4,a5,0x1e
ffffffe000201ad8:	040007b7          	lui	a5,0x4000
ffffffe000201adc:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000201ae0:	00f777b3          	and	a5,a4,a5
ffffffe000201ae4:	f6f43c23          	sd	a5,-136(s0)
        vpn[0] = (cur_va >> 12) & 0x1ff;
ffffffe000201ae8:	fc843783          	ld	a5,-56(s0)
ffffffe000201aec:	00c7d793          	srli	a5,a5,0xc
ffffffe000201af0:	1ff7f793          	andi	a5,a5,511
ffffffe000201af4:	f4f43823          	sd	a5,-176(s0)
        vpn[1] = (cur_va >> 21) & 0x1ff;
ffffffe000201af8:	fc843783          	ld	a5,-56(s0)
ffffffe000201afc:	0157d793          	srli	a5,a5,0x15
ffffffe000201b00:	1ff7f793          	andi	a5,a5,511
ffffffe000201b04:	f4f43c23          	sd	a5,-168(s0)
        vpn[2] = (cur_va >> 30) & 0x1ff;
ffffffe000201b08:	fc843783          	ld	a5,-56(s0)
ffffffe000201b0c:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201b10:	1ff7f793          	andi	a5,a5,511
ffffffe000201b14:	f6f43023          	sd	a5,-160(s0)

        uint64_t *pmd = NULL, *pte = NULL;
ffffffe000201b18:	fe043023          	sd	zero,-32(s0)
ffffffe000201b1c:	fc043c23          	sd	zero,-40(s0)
        // Check if PGD entry valid
        if ((pgtbl[vpn[2]] & PERM_V) == 0) {  // If not, allocate a new PMD page
ffffffe000201b20:	f6043783          	ld	a5,-160(s0)
ffffffe000201b24:	00379793          	slli	a5,a5,0x3
ffffffe000201b28:	f4843703          	ld	a4,-184(s0)
ffffffe000201b2c:	00f707b3          	add	a5,a4,a5
ffffffe000201b30:	0007b783          	ld	a5,0(a5)
ffffffe000201b34:	0017f793          	andi	a5,a5,1
ffffffe000201b38:	04079e63          	bnez	a5,ffffffe000201b94 <create_mapping+0x148>
            pmd = kalloc();
ffffffe000201b3c:	e55fe0ef          	jal	ffffffe000200990 <kalloc>
ffffffe000201b40:	fea43023          	sd	a0,-32(s0)
            // memset(pmd, 0x0, PGSIZE); // kalloc() will do this
            uint64_t pmd_pa  = (uint64_t)pmd - PA2VA_OFFSET;
ffffffe000201b44:	fe043703          	ld	a4,-32(s0)
ffffffe000201b48:	04100793          	li	a5,65
ffffffe000201b4c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201b50:	00f707b3          	add	a5,a4,a5
ffffffe000201b54:	faf43423          	sd	a5,-88(s0)
            uint64_t pmd_ppn = (pmd_pa >> 12) & PPN_MASK;  // High 44 bits of pmd_pa
ffffffe000201b58:	fa843783          	ld	a5,-88(s0)
ffffffe000201b5c:	00c7d713          	srli	a4,a5,0xc
ffffffe000201b60:	fff00793          	li	a5,-1
ffffffe000201b64:	0147d793          	srli	a5,a5,0x14
ffffffe000201b68:	00f777b3          	and	a5,a4,a5
ffffffe000201b6c:	faf43023          	sd	a5,-96(s0)
            pgtbl[vpn[2]]    = (pmd_ppn << 10) | PERM_V;   // Non-leaf node
ffffffe000201b70:	fa043783          	ld	a5,-96(s0)
ffffffe000201b74:	00a79713          	slli	a4,a5,0xa
ffffffe000201b78:	f6043783          	ld	a5,-160(s0)
ffffffe000201b7c:	00379793          	slli	a5,a5,0x3
ffffffe000201b80:	f4843683          	ld	a3,-184(s0)
ffffffe000201b84:	00f687b3          	add	a5,a3,a5
ffffffe000201b88:	00176713          	ori	a4,a4,1
ffffffe000201b8c:	00e7b023          	sd	a4,0(a5)
ffffffe000201b90:	04c0006f          	j	ffffffe000201bdc <create_mapping+0x190>
        } else {
            uint64_t pmd_ppn = (pgtbl[vpn[2]] >> 10) & PPN_MASK;
ffffffe000201b94:	f6043783          	ld	a5,-160(s0)
ffffffe000201b98:	00379793          	slli	a5,a5,0x3
ffffffe000201b9c:	f4843703          	ld	a4,-184(s0)
ffffffe000201ba0:	00f707b3          	add	a5,a4,a5
ffffffe000201ba4:	0007b783          	ld	a5,0(a5)
ffffffe000201ba8:	00a7d713          	srli	a4,a5,0xa
ffffffe000201bac:	fff00793          	li	a5,-1
ffffffe000201bb0:	0147d793          	srli	a5,a5,0x14
ffffffe000201bb4:	00f777b3          	and	a5,a4,a5
ffffffe000201bb8:	faf43c23          	sd	a5,-72(s0)
            uint64_t pmd_pa  = (pmd_ppn << 12);
ffffffe000201bbc:	fb843783          	ld	a5,-72(s0)
ffffffe000201bc0:	00c79793          	slli	a5,a5,0xc
ffffffe000201bc4:	faf43823          	sd	a5,-80(s0)

            pmd = (uint64_t*)(pmd_pa + PA2VA_OFFSET);
ffffffe000201bc8:	fb043703          	ld	a4,-80(s0)
ffffffe000201bcc:	fbf00793          	li	a5,-65
ffffffe000201bd0:	01f79793          	slli	a5,a5,0x1f
ffffffe000201bd4:	00f707b3          	add	a5,a4,a5
ffffffe000201bd8:	fef43023          	sd	a5,-32(s0)
        }

        if (pmd == NULL) {
ffffffe000201bdc:	fe043783          	ld	a5,-32(s0)
ffffffe000201be0:	02079463          	bnez	a5,ffffffe000201c08 <create_mapping+0x1bc>
            Log("Fatal Error: unable to allocate or find PMD\n");
ffffffe000201be4:	06500693          	li	a3,101
ffffffe000201be8:	00003617          	auipc	a2,0x3
ffffffe000201bec:	8d860613          	addi	a2,a2,-1832 # ffffffe0002044c0 <__func__.0+0xf0>
ffffffe000201bf0:	00003597          	auipc	a1,0x3
ffffffe000201bf4:	a8858593          	addi	a1,a1,-1400 # ffffffe000204678 <__func__.0>
ffffffe000201bf8:	00003517          	auipc	a0,0x3
ffffffe000201bfc:	9c050513          	addi	a0,a0,-1600 # ffffffe0002045b8 <__func__.0+0x1e8>
ffffffe000201c00:	230010ef          	jal	ffffffe000202e30 <printk>
            return;
ffffffe000201c04:	12c0006f          	j	ffffffe000201d30 <create_mapping+0x2e4>
        }

        // Check if PMD entry valid
        if ((pmd[vpn[1]] & PERM_V) == 0) {  // If not, allocate a new PTE page
ffffffe000201c08:	f5843783          	ld	a5,-168(s0)
ffffffe000201c0c:	00379793          	slli	a5,a5,0x3
ffffffe000201c10:	fe043703          	ld	a4,-32(s0)
ffffffe000201c14:	00f707b3          	add	a5,a4,a5
ffffffe000201c18:	0007b783          	ld	a5,0(a5)
ffffffe000201c1c:	0017f793          	andi	a5,a5,1
ffffffe000201c20:	04079e63          	bnez	a5,ffffffe000201c7c <create_mapping+0x230>
            pte = kalloc();
ffffffe000201c24:	d6dfe0ef          	jal	ffffffe000200990 <kalloc>
ffffffe000201c28:	fca43c23          	sd	a0,-40(s0)
            // memset(pte, 0x0, PGSIZE); // kalloc() will do this
            uint64_t pte_pa  = (uint64_t)pte - PA2VA_OFFSET;
ffffffe000201c2c:	fd843703          	ld	a4,-40(s0)
ffffffe000201c30:	04100793          	li	a5,65
ffffffe000201c34:	01f79793          	slli	a5,a5,0x1f
ffffffe000201c38:	00f707b3          	add	a5,a4,a5
ffffffe000201c3c:	f8f43423          	sd	a5,-120(s0)
            uint64_t pte_ppn = (pte_pa >> 12) & PPN_MASK;  // High 44 bits of pte_pa
ffffffe000201c40:	f8843783          	ld	a5,-120(s0)
ffffffe000201c44:	00c7d713          	srli	a4,a5,0xc
ffffffe000201c48:	fff00793          	li	a5,-1
ffffffe000201c4c:	0147d793          	srli	a5,a5,0x14
ffffffe000201c50:	00f777b3          	and	a5,a4,a5
ffffffe000201c54:	f8f43023          	sd	a5,-128(s0)
            pmd[vpn[1]]      = (pte_ppn << 10) | PERM_V;   // Non-leaf node
ffffffe000201c58:	f8043783          	ld	a5,-128(s0)
ffffffe000201c5c:	00a79713          	slli	a4,a5,0xa
ffffffe000201c60:	f5843783          	ld	a5,-168(s0)
ffffffe000201c64:	00379793          	slli	a5,a5,0x3
ffffffe000201c68:	fe043683          	ld	a3,-32(s0)
ffffffe000201c6c:	00f687b3          	add	a5,a3,a5
ffffffe000201c70:	00176713          	ori	a4,a4,1
ffffffe000201c74:	00e7b023          	sd	a4,0(a5)
ffffffe000201c78:	04c0006f          	j	ffffffe000201cc4 <create_mapping+0x278>
        } else {
            uint64_t pte_ppn = (pmd[vpn[1]] >> 10) & PPN_MASK;
ffffffe000201c7c:	f5843783          	ld	a5,-168(s0)
ffffffe000201c80:	00379793          	slli	a5,a5,0x3
ffffffe000201c84:	fe043703          	ld	a4,-32(s0)
ffffffe000201c88:	00f707b3          	add	a5,a4,a5
ffffffe000201c8c:	0007b783          	ld	a5,0(a5)
ffffffe000201c90:	00a7d713          	srli	a4,a5,0xa
ffffffe000201c94:	fff00793          	li	a5,-1
ffffffe000201c98:	0147d793          	srli	a5,a5,0x14
ffffffe000201c9c:	00f777b3          	and	a5,a4,a5
ffffffe000201ca0:	f8f43c23          	sd	a5,-104(s0)
            uint64_t pte_pa  = (pte_ppn << 12);
ffffffe000201ca4:	f9843783          	ld	a5,-104(s0)
ffffffe000201ca8:	00c79793          	slli	a5,a5,0xc
ffffffe000201cac:	f8f43823          	sd	a5,-112(s0)

            pte = (uint64_t*)(pte_pa + PA2VA_OFFSET);
ffffffe000201cb0:	f9043703          	ld	a4,-112(s0)
ffffffe000201cb4:	fbf00793          	li	a5,-65
ffffffe000201cb8:	01f79793          	slli	a5,a5,0x1f
ffffffe000201cbc:	00f707b3          	add	a5,a4,a5
ffffffe000201cc0:	fcf43c23          	sd	a5,-40(s0)
        }

        // Update pte
        if (pte == NULL) {
ffffffe000201cc4:	fd843783          	ld	a5,-40(s0)
ffffffe000201cc8:	02079463          	bnez	a5,ffffffe000201cf0 <create_mapping+0x2a4>
            Log("Fatal Error: unable to allocate or find PTE\n");
ffffffe000201ccc:	07900693          	li	a3,121
ffffffe000201cd0:	00002617          	auipc	a2,0x2
ffffffe000201cd4:	7f060613          	addi	a2,a2,2032 # ffffffe0002044c0 <__func__.0+0xf0>
ffffffe000201cd8:	00003597          	auipc	a1,0x3
ffffffe000201cdc:	9a058593          	addi	a1,a1,-1632 # ffffffe000204678 <__func__.0>
ffffffe000201ce0:	00003517          	auipc	a0,0x3
ffffffe000201ce4:	93050513          	addi	a0,a0,-1744 # ffffffe000204610 <__func__.0+0x240>
ffffffe000201ce8:	148010ef          	jal	ffffffe000202e30 <printk>
            return;
ffffffe000201cec:	0440006f          	j	ffffffe000201d30 <create_mapping+0x2e4>
        }

        pte[vpn[0]] = (cur_ppn << 10) | perm;
ffffffe000201cf0:	fc043783          	ld	a5,-64(s0)
ffffffe000201cf4:	00a79693          	slli	a3,a5,0xa
ffffffe000201cf8:	f5043783          	ld	a5,-176(s0)
ffffffe000201cfc:	00379793          	slli	a5,a5,0x3
ffffffe000201d00:	fd843703          	ld	a4,-40(s0)
ffffffe000201d04:	00f707b3          	add	a5,a4,a5
ffffffe000201d08:	f2843703          	ld	a4,-216(s0)
ffffffe000201d0c:	00e6e733          	or	a4,a3,a4
ffffffe000201d10:	00e7b023          	sd	a4,0(a5)
    for (uint64_t offset = 0; offset < sz; offset += PGSIZE) {
ffffffe000201d14:	fe843703          	ld	a4,-24(s0)
ffffffe000201d18:	000017b7          	lui	a5,0x1
ffffffe000201d1c:	00f707b3          	add	a5,a4,a5
ffffffe000201d20:	fef43423          	sd	a5,-24(s0)
ffffffe000201d24:	fe843703          	ld	a4,-24(s0)
ffffffe000201d28:	f3043783          	ld	a5,-208(s0)
ffffffe000201d2c:	d4f766e3          	bltu	a4,a5,ffffffe000201a78 <create_mapping+0x2c>
    }
}
ffffffe000201d30:	0d813083          	ld	ra,216(sp)
ffffffe000201d34:	0d013403          	ld	s0,208(sp)
ffffffe000201d38:	0e010113          	addi	sp,sp,224
ffffffe000201d3c:	00008067          	ret

ffffffe000201d40 <setup_vm_final>:

void setup_vm_final() {
ffffffe000201d40:	fe010113          	addi	sp,sp,-32
ffffffe000201d44:	00113c23          	sd	ra,24(sp)
ffffffe000201d48:	00813823          	sd	s0,16(sp)
ffffffe000201d4c:	02010413          	addi	s0,sp,32
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000201d50:	00001637          	lui	a2,0x1
ffffffe000201d54:	00000593          	li	a1,0
ffffffe000201d58:	00009517          	auipc	a0,0x9
ffffffe000201d5c:	2a850513          	addi	a0,a0,680 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201d60:	1f0010ef          	jal	ffffffe000202f50 <memset>

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)(_stext - PA2VA_OFFSET),
ffffffe000201d64:	ffffe597          	auipc	a1,0xffffe
ffffffe000201d68:	29c58593          	addi	a1,a1,668 # ffffffe000200000 <_skernel>
ffffffe000201d6c:	ffffe717          	auipc	a4,0xffffe
ffffffe000201d70:	29470713          	addi	a4,a4,660 # ffffffe000200000 <_skernel>
ffffffe000201d74:	04100793          	li	a5,65
ffffffe000201d78:	01f79793          	slli	a5,a5,0x1f
ffffffe000201d7c:	00f707b3          	add	a5,a4,a5
ffffffe000201d80:	00078613          	mv	a2,a5
                   (_etext - _stext), PERM_A | PERM_X | PERM_R | PERM_V);
ffffffe000201d84:	00001717          	auipc	a4,0x1
ffffffe000201d88:	36470713          	addi	a4,a4,868 # ffffffe0002030e8 <_etext>
ffffffe000201d8c:	ffffe797          	auipc	a5,0xffffe
ffffffe000201d90:	27478793          	addi	a5,a5,628 # ffffffe000200000 <_skernel>
ffffffe000201d94:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)(_stext - PA2VA_OFFSET),
ffffffe000201d98:	04b00713          	li	a4,75
ffffffe000201d9c:	00078693          	mv	a3,a5
ffffffe000201da0:	00009517          	auipc	a0,0x9
ffffffe000201da4:	26050513          	addi	a0,a0,608 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201da8:	ca5ff0ef          	jal	ffffffe000201a4c <create_mapping>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)(_srodata - PA2VA_OFFSET),
ffffffe000201dac:	00002597          	auipc	a1,0x2
ffffffe000201db0:	25458593          	addi	a1,a1,596 # ffffffe000204000 <_srodata>
ffffffe000201db4:	00002717          	auipc	a4,0x2
ffffffe000201db8:	24c70713          	addi	a4,a4,588 # ffffffe000204000 <_srodata>
ffffffe000201dbc:	04100793          	li	a5,65
ffffffe000201dc0:	01f79793          	slli	a5,a5,0x1f
ffffffe000201dc4:	00f707b3          	add	a5,a4,a5
ffffffe000201dc8:	00078613          	mv	a2,a5
                   (_erodata - _srodata), PERM_A | PERM_R | PERM_V);
ffffffe000201dcc:	00003717          	auipc	a4,0x3
ffffffe000201dd0:	94c70713          	addi	a4,a4,-1716 # ffffffe000204718 <_erodata>
ffffffe000201dd4:	00002797          	auipc	a5,0x2
ffffffe000201dd8:	22c78793          	addi	a5,a5,556 # ffffffe000204000 <_srodata>
ffffffe000201ddc:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)(_srodata - PA2VA_OFFSET),
ffffffe000201de0:	04300713          	li	a4,67
ffffffe000201de4:	00078693          	mv	a3,a5
ffffffe000201de8:	00009517          	auipc	a0,0x9
ffffffe000201dec:	21850513          	addi	a0,a0,536 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201df0:	c5dff0ef          	jal	ffffffe000201a4c <create_mapping>

    // mapping other memory -|W|R|V
    // Set dirty bit for modified pages
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)(_sdata - PA2VA_OFFSET),
ffffffe000201df4:	00003597          	auipc	a1,0x3
ffffffe000201df8:	20c58593          	addi	a1,a1,524 # ffffffe000205000 <TIMECLOCK>
ffffffe000201dfc:	00003717          	auipc	a4,0x3
ffffffe000201e00:	20470713          	addi	a4,a4,516 # ffffffe000205000 <TIMECLOCK>
ffffffe000201e04:	04100793          	li	a5,65
ffffffe000201e08:	01f79793          	slli	a5,a5,0x1f
ffffffe000201e0c:	00f707b3          	add	a5,a4,a5
ffffffe000201e10:	00078613          	mv	a2,a5
                   (_edata - _sdata), PERM_A | PERM_W | PERM_R | PERM_V);
ffffffe000201e14:	00003717          	auipc	a4,0x3
ffffffe000201e18:	1fc70713          	addi	a4,a4,508 # ffffffe000205010 <_edata>
ffffffe000201e1c:	00003797          	auipc	a5,0x3
ffffffe000201e20:	1e478793          	addi	a5,a5,484 # ffffffe000205000 <TIMECLOCK>
ffffffe000201e24:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)(_sdata - PA2VA_OFFSET),
ffffffe000201e28:	04700713          	li	a4,71
ffffffe000201e2c:	00078693          	mv	a3,a5
ffffffe000201e30:	00009517          	auipc	a0,0x9
ffffffe000201e34:	1d050513          	addi	a0,a0,464 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201e38:	c15ff0ef          	jal	ffffffe000201a4c <create_mapping>
    create_mapping(swapper_pg_dir, (uint64_t)_sbss, (uint64_t)(_sbss - PA2VA_OFFSET),
ffffffe000201e3c:	00006597          	auipc	a1,0x6
ffffffe000201e40:	1c458593          	addi	a1,a1,452 # ffffffe000208000 <_sbss>
ffffffe000201e44:	00006717          	auipc	a4,0x6
ffffffe000201e48:	1bc70713          	addi	a4,a4,444 # ffffffe000208000 <_sbss>
ffffffe000201e4c:	04100793          	li	a5,65
ffffffe000201e50:	01f79793          	slli	a5,a5,0x1f
ffffffe000201e54:	00f707b3          	add	a5,a4,a5
ffffffe000201e58:	00078613          	mv	a2,a5
                   (_ebss - _sbss), PERM_A | PERM_D | PERM_W | PERM_R | PERM_V);
ffffffe000201e5c:	0000a717          	auipc	a4,0xa
ffffffe000201e60:	1a470713          	addi	a4,a4,420 # ffffffe00020c000 <_ebss>
ffffffe000201e64:	00006797          	auipc	a5,0x6
ffffffe000201e68:	19c78793          	addi	a5,a5,412 # ffffffe000208000 <_sbss>
ffffffe000201e6c:	40f707b3          	sub	a5,a4,a5
    create_mapping(swapper_pg_dir, (uint64_t)_sbss, (uint64_t)(_sbss - PA2VA_OFFSET),
ffffffe000201e70:	0c700713          	li	a4,199
ffffffe000201e74:	00078693          	mv	a3,a5
ffffffe000201e78:	00009517          	auipc	a0,0x9
ffffffe000201e7c:	18850513          	addi	a0,a0,392 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201e80:	bcdff0ef          	jal	ffffffe000201a4c <create_mapping>
    create_mapping(swapper_pg_dir, (uint64_t)_ekernel, (uint64_t)(_ekernel - PA2VA_OFFSET),
ffffffe000201e84:	0000a597          	auipc	a1,0xa
ffffffe000201e88:	17c58593          	addi	a1,a1,380 # ffffffe00020c000 <_ebss>
ffffffe000201e8c:	0000a717          	auipc	a4,0xa
ffffffe000201e90:	17470713          	addi	a4,a4,372 # ffffffe00020c000 <_ebss>
ffffffe000201e94:	04100793          	li	a5,65
ffffffe000201e98:	01f79793          	slli	a5,a5,0x1f
ffffffe000201e9c:	00f707b3          	add	a5,a4,a5
ffffffe000201ea0:	00078613          	mv	a2,a5
                   (PHY_SIZE - (uint64_t)(_ekernel - PA2VA_OFFSET - PHY_START)),
ffffffe000201ea4:	0000a797          	auipc	a5,0xa
ffffffe000201ea8:	15c78793          	addi	a5,a5,348 # ffffffe00020c000 <_ebss>
    create_mapping(swapper_pg_dir, (uint64_t)_ekernel, (uint64_t)(_ekernel - PA2VA_OFFSET),
ffffffe000201eac:	c0100713          	li	a4,-1023
ffffffe000201eb0:	01b71713          	slli	a4,a4,0x1b
ffffffe000201eb4:	40f707b3          	sub	a5,a4,a5
ffffffe000201eb8:	0c700713          	li	a4,199
ffffffe000201ebc:	00078693          	mv	a3,a5
ffffffe000201ec0:	00009517          	auipc	a0,0x9
ffffffe000201ec4:	14050513          	addi	a0,a0,320 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201ec8:	b85ff0ef          	jal	ffffffe000201a4c <create_mapping>
                   PERM_A | PERM_D | PERM_W | PERM_R | PERM_V);

    // set satp with swapper_pg_dir
    uint64_t swapper_pg_dir_pa = (uint64_t)swapper_pg_dir - PA2VA_OFFSET;
ffffffe000201ecc:	00009717          	auipc	a4,0x9
ffffffe000201ed0:	13470713          	addi	a4,a4,308 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201ed4:	04100793          	li	a5,65
ffffffe000201ed8:	01f79793          	slli	a5,a5,0x1f
ffffffe000201edc:	00f707b3          	add	a5,a4,a5
ffffffe000201ee0:	fef43423          	sd	a5,-24(s0)
    uint64_t satp              = (0x8L << 60) | ((swapper_pg_dir_pa >> 12) & PPN_MASK);
ffffffe000201ee4:	fe843783          	ld	a5,-24(s0)
ffffffe000201ee8:	00c7d713          	srli	a4,a5,0xc
ffffffe000201eec:	fff00793          	li	a5,-1
ffffffe000201ef0:	0147d793          	srli	a5,a5,0x14
ffffffe000201ef4:	00f77733          	and	a4,a4,a5
ffffffe000201ef8:	fff00793          	li	a5,-1
ffffffe000201efc:	03f79793          	slli	a5,a5,0x3f
ffffffe000201f00:	00f767b3          	or	a5,a4,a5
ffffffe000201f04:	fef43023          	sd	a5,-32(s0)
    asm volatile("mv t0, %0\n" "csrw satp, t0" : : "r"(satp) : "t0");
ffffffe000201f08:	fe043783          	ld	a5,-32(s0)
ffffffe000201f0c:	00078293          	mv	t0,a5
ffffffe000201f10:	18029073          	csrw	satp,t0

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000201f14:	12000073          	sfence.vma
    return;
ffffffe000201f18:	00000013          	nop
}
ffffffe000201f1c:	01813083          	ld	ra,24(sp)
ffffffe000201f20:	01013403          	ld	s0,16(sp)
ffffffe000201f24:	02010113          	addi	sp,sp,32
ffffffe000201f28:	00008067          	ret

ffffffe000201f2c <start_kernel>:
#include "printk.h"
#include "sbi.h"
#include "defs.h"

int start_kernel() {
ffffffe000201f2c:	ff010113          	addi	sp,sp,-16
ffffffe000201f30:	00113423          	sd	ra,8(sp)
ffffffe000201f34:	00813023          	sd	s0,0(sp)
ffffffe000201f38:	01010413          	addi	s0,sp,16
    printk("2024 ZJU Operating System\n");
ffffffe000201f3c:	00002517          	auipc	a0,0x2
ffffffe000201f40:	74c50513          	addi	a0,a0,1868 # ffffffe000204688 <__func__.0+0x10>
ffffffe000201f44:	6ed000ef          	jal	ffffffe000202e30 <printk>

    while (true);
ffffffe000201f48:	0000006f          	j	ffffffe000201f48 <start_kernel+0x1c>

ffffffe000201f4c <test>:
#include "printk.h"
#include "sbi.h"

void test() {
ffffffe000201f4c:	fe010113          	addi	sp,sp,-32
ffffffe000201f50:	00113c23          	sd	ra,24(sp)
ffffffe000201f54:	00813823          	sd	s0,16(sp)
ffffffe000201f58:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe000201f5c:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000201f60:	fec42783          	lw	a5,-20(s0)
ffffffe000201f64:	0017879b          	addiw	a5,a5,1
ffffffe000201f68:	fef42623          	sw	a5,-20(s0)
ffffffe000201f6c:	fec42783          	lw	a5,-20(s0)
ffffffe000201f70:	00078713          	mv	a4,a5
ffffffe000201f74:	05f5e7b7          	lui	a5,0x5f5e
ffffffe000201f78:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe000201f7c:	02f767bb          	remw	a5,a4,a5
ffffffe000201f80:	0007879b          	sext.w	a5,a5
ffffffe000201f84:	fc079ee3          	bnez	a5,ffffffe000201f60 <test+0x14>
            printk("kernel is running!\n");
ffffffe000201f88:	00002517          	auipc	a0,0x2
ffffffe000201f8c:	72050513          	addi	a0,a0,1824 # ffffffe0002046a8 <__func__.0+0x30>
ffffffe000201f90:	6a1000ef          	jal	ffffffe000202e30 <printk>
            i = 0;
ffffffe000201f94:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000201f98:	fc9ff06f          	j	ffffffe000201f60 <test+0x14>

ffffffe000201f9c <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe000201f9c:	fe010113          	addi	sp,sp,-32
ffffffe000201fa0:	00113c23          	sd	ra,24(sp)
ffffffe000201fa4:	00813823          	sd	s0,16(sp)
ffffffe000201fa8:	02010413          	addi	s0,sp,32
ffffffe000201fac:	00050793          	mv	a5,a0
ffffffe000201fb0:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000201fb4:	fec42783          	lw	a5,-20(s0)
ffffffe000201fb8:	0ff7f793          	zext.b	a5,a5
ffffffe000201fbc:	00078513          	mv	a0,a5
ffffffe000201fc0:	e78ff0ef          	jal	ffffffe000201638 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000201fc4:	fec42783          	lw	a5,-20(s0)
ffffffe000201fc8:	0ff7f793          	zext.b	a5,a5
ffffffe000201fcc:	0007879b          	sext.w	a5,a5
}
ffffffe000201fd0:	00078513          	mv	a0,a5
ffffffe000201fd4:	01813083          	ld	ra,24(sp)
ffffffe000201fd8:	01013403          	ld	s0,16(sp)
ffffffe000201fdc:	02010113          	addi	sp,sp,32
ffffffe000201fe0:	00008067          	ret

ffffffe000201fe4 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000201fe4:	fe010113          	addi	sp,sp,-32
ffffffe000201fe8:	00813c23          	sd	s0,24(sp)
ffffffe000201fec:	02010413          	addi	s0,sp,32
ffffffe000201ff0:	00050793          	mv	a5,a0
ffffffe000201ff4:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000201ff8:	fec42783          	lw	a5,-20(s0)
ffffffe000201ffc:	0007871b          	sext.w	a4,a5
ffffffe000202000:	02000793          	li	a5,32
ffffffe000202004:	02f70263          	beq	a4,a5,ffffffe000202028 <isspace+0x44>
ffffffe000202008:	fec42783          	lw	a5,-20(s0)
ffffffe00020200c:	0007871b          	sext.w	a4,a5
ffffffe000202010:	00800793          	li	a5,8
ffffffe000202014:	00e7de63          	bge	a5,a4,ffffffe000202030 <isspace+0x4c>
ffffffe000202018:	fec42783          	lw	a5,-20(s0)
ffffffe00020201c:	0007871b          	sext.w	a4,a5
ffffffe000202020:	00d00793          	li	a5,13
ffffffe000202024:	00e7c663          	blt	a5,a4,ffffffe000202030 <isspace+0x4c>
ffffffe000202028:	00100793          	li	a5,1
ffffffe00020202c:	0080006f          	j	ffffffe000202034 <isspace+0x50>
ffffffe000202030:	00000793          	li	a5,0
}
ffffffe000202034:	00078513          	mv	a0,a5
ffffffe000202038:	01813403          	ld	s0,24(sp)
ffffffe00020203c:	02010113          	addi	sp,sp,32
ffffffe000202040:	00008067          	ret

ffffffe000202044 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000202044:	fb010113          	addi	sp,sp,-80
ffffffe000202048:	04113423          	sd	ra,72(sp)
ffffffe00020204c:	04813023          	sd	s0,64(sp)
ffffffe000202050:	05010413          	addi	s0,sp,80
ffffffe000202054:	fca43423          	sd	a0,-56(s0)
ffffffe000202058:	fcb43023          	sd	a1,-64(s0)
ffffffe00020205c:	00060793          	mv	a5,a2
ffffffe000202060:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000202064:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000202068:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe00020206c:	fc843783          	ld	a5,-56(s0)
ffffffe000202070:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000202074:	0100006f          	j	ffffffe000202084 <strtol+0x40>
        p++;
ffffffe000202078:	fd843783          	ld	a5,-40(s0)
ffffffe00020207c:	00178793          	addi	a5,a5,1
ffffffe000202080:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000202084:	fd843783          	ld	a5,-40(s0)
ffffffe000202088:	0007c783          	lbu	a5,0(a5)
ffffffe00020208c:	0007879b          	sext.w	a5,a5
ffffffe000202090:	00078513          	mv	a0,a5
ffffffe000202094:	f51ff0ef          	jal	ffffffe000201fe4 <isspace>
ffffffe000202098:	00050793          	mv	a5,a0
ffffffe00020209c:	fc079ee3          	bnez	a5,ffffffe000202078 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe0002020a0:	fd843783          	ld	a5,-40(s0)
ffffffe0002020a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002020a8:	00078713          	mv	a4,a5
ffffffe0002020ac:	02d00793          	li	a5,45
ffffffe0002020b0:	00f71e63          	bne	a4,a5,ffffffe0002020cc <strtol+0x88>
        neg = true;
ffffffe0002020b4:	00100793          	li	a5,1
ffffffe0002020b8:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe0002020bc:	fd843783          	ld	a5,-40(s0)
ffffffe0002020c0:	00178793          	addi	a5,a5,1
ffffffe0002020c4:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002020c8:	0240006f          	j	ffffffe0002020ec <strtol+0xa8>
    } else if (*p == '+') {
ffffffe0002020cc:	fd843783          	ld	a5,-40(s0)
ffffffe0002020d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002020d4:	00078713          	mv	a4,a5
ffffffe0002020d8:	02b00793          	li	a5,43
ffffffe0002020dc:	00f71863          	bne	a4,a5,ffffffe0002020ec <strtol+0xa8>
        p++;
ffffffe0002020e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002020e4:	00178793          	addi	a5,a5,1
ffffffe0002020e8:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe0002020ec:	fbc42783          	lw	a5,-68(s0)
ffffffe0002020f0:	0007879b          	sext.w	a5,a5
ffffffe0002020f4:	06079c63          	bnez	a5,ffffffe00020216c <strtol+0x128>
        if (*p == '0') {
ffffffe0002020f8:	fd843783          	ld	a5,-40(s0)
ffffffe0002020fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202100:	00078713          	mv	a4,a5
ffffffe000202104:	03000793          	li	a5,48
ffffffe000202108:	04f71e63          	bne	a4,a5,ffffffe000202164 <strtol+0x120>
            p++;
ffffffe00020210c:	fd843783          	ld	a5,-40(s0)
ffffffe000202110:	00178793          	addi	a5,a5,1
ffffffe000202114:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000202118:	fd843783          	ld	a5,-40(s0)
ffffffe00020211c:	0007c783          	lbu	a5,0(a5)
ffffffe000202120:	00078713          	mv	a4,a5
ffffffe000202124:	07800793          	li	a5,120
ffffffe000202128:	00f70c63          	beq	a4,a5,ffffffe000202140 <strtol+0xfc>
ffffffe00020212c:	fd843783          	ld	a5,-40(s0)
ffffffe000202130:	0007c783          	lbu	a5,0(a5)
ffffffe000202134:	00078713          	mv	a4,a5
ffffffe000202138:	05800793          	li	a5,88
ffffffe00020213c:	00f71e63          	bne	a4,a5,ffffffe000202158 <strtol+0x114>
                base = 16;
ffffffe000202140:	01000793          	li	a5,16
ffffffe000202144:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000202148:	fd843783          	ld	a5,-40(s0)
ffffffe00020214c:	00178793          	addi	a5,a5,1
ffffffe000202150:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202154:	0180006f          	j	ffffffe00020216c <strtol+0x128>
            } else {
                base = 8;
ffffffe000202158:	00800793          	li	a5,8
ffffffe00020215c:	faf42e23          	sw	a5,-68(s0)
ffffffe000202160:	00c0006f          	j	ffffffe00020216c <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000202164:	00a00793          	li	a5,10
ffffffe000202168:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe00020216c:	fd843783          	ld	a5,-40(s0)
ffffffe000202170:	0007c783          	lbu	a5,0(a5)
ffffffe000202174:	00078713          	mv	a4,a5
ffffffe000202178:	02f00793          	li	a5,47
ffffffe00020217c:	02e7f863          	bgeu	a5,a4,ffffffe0002021ac <strtol+0x168>
ffffffe000202180:	fd843783          	ld	a5,-40(s0)
ffffffe000202184:	0007c783          	lbu	a5,0(a5)
ffffffe000202188:	00078713          	mv	a4,a5
ffffffe00020218c:	03900793          	li	a5,57
ffffffe000202190:	00e7ee63          	bltu	a5,a4,ffffffe0002021ac <strtol+0x168>
            digit = *p - '0';
ffffffe000202194:	fd843783          	ld	a5,-40(s0)
ffffffe000202198:	0007c783          	lbu	a5,0(a5)
ffffffe00020219c:	0007879b          	sext.w	a5,a5
ffffffe0002021a0:	fd07879b          	addiw	a5,a5,-48
ffffffe0002021a4:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002021a8:	0800006f          	j	ffffffe000202228 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe0002021ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002021b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002021b4:	00078713          	mv	a4,a5
ffffffe0002021b8:	06000793          	li	a5,96
ffffffe0002021bc:	02e7f863          	bgeu	a5,a4,ffffffe0002021ec <strtol+0x1a8>
ffffffe0002021c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002021c4:	0007c783          	lbu	a5,0(a5)
ffffffe0002021c8:	00078713          	mv	a4,a5
ffffffe0002021cc:	07a00793          	li	a5,122
ffffffe0002021d0:	00e7ee63          	bltu	a5,a4,ffffffe0002021ec <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe0002021d4:	fd843783          	ld	a5,-40(s0)
ffffffe0002021d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002021dc:	0007879b          	sext.w	a5,a5
ffffffe0002021e0:	fa97879b          	addiw	a5,a5,-87
ffffffe0002021e4:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002021e8:	0400006f          	j	ffffffe000202228 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe0002021ec:	fd843783          	ld	a5,-40(s0)
ffffffe0002021f0:	0007c783          	lbu	a5,0(a5)
ffffffe0002021f4:	00078713          	mv	a4,a5
ffffffe0002021f8:	04000793          	li	a5,64
ffffffe0002021fc:	06e7f863          	bgeu	a5,a4,ffffffe00020226c <strtol+0x228>
ffffffe000202200:	fd843783          	ld	a5,-40(s0)
ffffffe000202204:	0007c783          	lbu	a5,0(a5)
ffffffe000202208:	00078713          	mv	a4,a5
ffffffe00020220c:	05a00793          	li	a5,90
ffffffe000202210:	04e7ee63          	bltu	a5,a4,ffffffe00020226c <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000202214:	fd843783          	ld	a5,-40(s0)
ffffffe000202218:	0007c783          	lbu	a5,0(a5)
ffffffe00020221c:	0007879b          	sext.w	a5,a5
ffffffe000202220:	fc97879b          	addiw	a5,a5,-55
ffffffe000202224:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000202228:	fd442783          	lw	a5,-44(s0)
ffffffe00020222c:	00078713          	mv	a4,a5
ffffffe000202230:	fbc42783          	lw	a5,-68(s0)
ffffffe000202234:	0007071b          	sext.w	a4,a4
ffffffe000202238:	0007879b          	sext.w	a5,a5
ffffffe00020223c:	02f75663          	bge	a4,a5,ffffffe000202268 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe000202240:	fbc42703          	lw	a4,-68(s0)
ffffffe000202244:	fe843783          	ld	a5,-24(s0)
ffffffe000202248:	02f70733          	mul	a4,a4,a5
ffffffe00020224c:	fd442783          	lw	a5,-44(s0)
ffffffe000202250:	00f707b3          	add	a5,a4,a5
ffffffe000202254:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000202258:	fd843783          	ld	a5,-40(s0)
ffffffe00020225c:	00178793          	addi	a5,a5,1
ffffffe000202260:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000202264:	f09ff06f          	j	ffffffe00020216c <strtol+0x128>
            break;
ffffffe000202268:	00000013          	nop
    }

    if (endptr) {
ffffffe00020226c:	fc043783          	ld	a5,-64(s0)
ffffffe000202270:	00078863          	beqz	a5,ffffffe000202280 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe000202274:	fc043783          	ld	a5,-64(s0)
ffffffe000202278:	fd843703          	ld	a4,-40(s0)
ffffffe00020227c:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000202280:	fe744783          	lbu	a5,-25(s0)
ffffffe000202284:	0ff7f793          	zext.b	a5,a5
ffffffe000202288:	00078863          	beqz	a5,ffffffe000202298 <strtol+0x254>
ffffffe00020228c:	fe843783          	ld	a5,-24(s0)
ffffffe000202290:	40f007b3          	neg	a5,a5
ffffffe000202294:	0080006f          	j	ffffffe00020229c <strtol+0x258>
ffffffe000202298:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020229c:	00078513          	mv	a0,a5
ffffffe0002022a0:	04813083          	ld	ra,72(sp)
ffffffe0002022a4:	04013403          	ld	s0,64(sp)
ffffffe0002022a8:	05010113          	addi	sp,sp,80
ffffffe0002022ac:	00008067          	ret

ffffffe0002022b0 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe0002022b0:	fd010113          	addi	sp,sp,-48
ffffffe0002022b4:	02113423          	sd	ra,40(sp)
ffffffe0002022b8:	02813023          	sd	s0,32(sp)
ffffffe0002022bc:	03010413          	addi	s0,sp,48
ffffffe0002022c0:	fca43c23          	sd	a0,-40(s0)
ffffffe0002022c4:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe0002022c8:	fd043783          	ld	a5,-48(s0)
ffffffe0002022cc:	00079863          	bnez	a5,ffffffe0002022dc <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe0002022d0:	00002797          	auipc	a5,0x2
ffffffe0002022d4:	3f078793          	addi	a5,a5,1008 # ffffffe0002046c0 <__func__.0+0x48>
ffffffe0002022d8:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe0002022dc:	fd043783          	ld	a5,-48(s0)
ffffffe0002022e0:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe0002022e4:	0240006f          	j	ffffffe000202308 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe0002022e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002022ec:	00178713          	addi	a4,a5,1
ffffffe0002022f0:	fee43423          	sd	a4,-24(s0)
ffffffe0002022f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002022f8:	0007871b          	sext.w	a4,a5
ffffffe0002022fc:	fd843783          	ld	a5,-40(s0)
ffffffe000202300:	00070513          	mv	a0,a4
ffffffe000202304:	000780e7          	jalr	a5
    while (*p) {
ffffffe000202308:	fe843783          	ld	a5,-24(s0)
ffffffe00020230c:	0007c783          	lbu	a5,0(a5)
ffffffe000202310:	fc079ce3          	bnez	a5,ffffffe0002022e8 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000202314:	fe843703          	ld	a4,-24(s0)
ffffffe000202318:	fd043783          	ld	a5,-48(s0)
ffffffe00020231c:	40f707b3          	sub	a5,a4,a5
ffffffe000202320:	0007879b          	sext.w	a5,a5
}
ffffffe000202324:	00078513          	mv	a0,a5
ffffffe000202328:	02813083          	ld	ra,40(sp)
ffffffe00020232c:	02013403          	ld	s0,32(sp)
ffffffe000202330:	03010113          	addi	sp,sp,48
ffffffe000202334:	00008067          	ret

ffffffe000202338 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000202338:	f9010113          	addi	sp,sp,-112
ffffffe00020233c:	06113423          	sd	ra,104(sp)
ffffffe000202340:	06813023          	sd	s0,96(sp)
ffffffe000202344:	07010413          	addi	s0,sp,112
ffffffe000202348:	faa43423          	sd	a0,-88(s0)
ffffffe00020234c:	fab43023          	sd	a1,-96(s0)
ffffffe000202350:	00060793          	mv	a5,a2
ffffffe000202354:	f8d43823          	sd	a3,-112(s0)
ffffffe000202358:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe00020235c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202360:	0ff7f793          	zext.b	a5,a5
ffffffe000202364:	02078663          	beqz	a5,ffffffe000202390 <print_dec_int+0x58>
ffffffe000202368:	fa043703          	ld	a4,-96(s0)
ffffffe00020236c:	fff00793          	li	a5,-1
ffffffe000202370:	03f79793          	slli	a5,a5,0x3f
ffffffe000202374:	00f71e63          	bne	a4,a5,ffffffe000202390 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000202378:	00002597          	auipc	a1,0x2
ffffffe00020237c:	35058593          	addi	a1,a1,848 # ffffffe0002046c8 <__func__.0+0x50>
ffffffe000202380:	fa843503          	ld	a0,-88(s0)
ffffffe000202384:	f2dff0ef          	jal	ffffffe0002022b0 <puts_wo_nl>
ffffffe000202388:	00050793          	mv	a5,a0
ffffffe00020238c:	2a00006f          	j	ffffffe00020262c <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000202390:	f9043783          	ld	a5,-112(s0)
ffffffe000202394:	00c7a783          	lw	a5,12(a5)
ffffffe000202398:	00079a63          	bnez	a5,ffffffe0002023ac <print_dec_int+0x74>
ffffffe00020239c:	fa043783          	ld	a5,-96(s0)
ffffffe0002023a0:	00079663          	bnez	a5,ffffffe0002023ac <print_dec_int+0x74>
        return 0;
ffffffe0002023a4:	00000793          	li	a5,0
ffffffe0002023a8:	2840006f          	j	ffffffe00020262c <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe0002023ac:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe0002023b0:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002023b4:	0ff7f793          	zext.b	a5,a5
ffffffe0002023b8:	02078063          	beqz	a5,ffffffe0002023d8 <print_dec_int+0xa0>
ffffffe0002023bc:	fa043783          	ld	a5,-96(s0)
ffffffe0002023c0:	0007dc63          	bgez	a5,ffffffe0002023d8 <print_dec_int+0xa0>
        neg = true;
ffffffe0002023c4:	00100793          	li	a5,1
ffffffe0002023c8:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe0002023cc:	fa043783          	ld	a5,-96(s0)
ffffffe0002023d0:	40f007b3          	neg	a5,a5
ffffffe0002023d4:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe0002023d8:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe0002023dc:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002023e0:	0ff7f793          	zext.b	a5,a5
ffffffe0002023e4:	02078863          	beqz	a5,ffffffe000202414 <print_dec_int+0xdc>
ffffffe0002023e8:	fef44783          	lbu	a5,-17(s0)
ffffffe0002023ec:	0ff7f793          	zext.b	a5,a5
ffffffe0002023f0:	00079e63          	bnez	a5,ffffffe00020240c <print_dec_int+0xd4>
ffffffe0002023f4:	f9043783          	ld	a5,-112(s0)
ffffffe0002023f8:	0057c783          	lbu	a5,5(a5)
ffffffe0002023fc:	00079863          	bnez	a5,ffffffe00020240c <print_dec_int+0xd4>
ffffffe000202400:	f9043783          	ld	a5,-112(s0)
ffffffe000202404:	0047c783          	lbu	a5,4(a5)
ffffffe000202408:	00078663          	beqz	a5,ffffffe000202414 <print_dec_int+0xdc>
ffffffe00020240c:	00100793          	li	a5,1
ffffffe000202410:	0080006f          	j	ffffffe000202418 <print_dec_int+0xe0>
ffffffe000202414:	00000793          	li	a5,0
ffffffe000202418:	fcf40ba3          	sb	a5,-41(s0)
ffffffe00020241c:	fd744783          	lbu	a5,-41(s0)
ffffffe000202420:	0017f793          	andi	a5,a5,1
ffffffe000202424:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000202428:	fa043703          	ld	a4,-96(s0)
ffffffe00020242c:	00a00793          	li	a5,10
ffffffe000202430:	02f777b3          	remu	a5,a4,a5
ffffffe000202434:	0ff7f713          	zext.b	a4,a5
ffffffe000202438:	fe842783          	lw	a5,-24(s0)
ffffffe00020243c:	0017869b          	addiw	a3,a5,1
ffffffe000202440:	fed42423          	sw	a3,-24(s0)
ffffffe000202444:	0307071b          	addiw	a4,a4,48
ffffffe000202448:	0ff77713          	zext.b	a4,a4
ffffffe00020244c:	ff078793          	addi	a5,a5,-16
ffffffe000202450:	008787b3          	add	a5,a5,s0
ffffffe000202454:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000202458:	fa043703          	ld	a4,-96(s0)
ffffffe00020245c:	00a00793          	li	a5,10
ffffffe000202460:	02f757b3          	divu	a5,a4,a5
ffffffe000202464:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000202468:	fa043783          	ld	a5,-96(s0)
ffffffe00020246c:	fa079ee3          	bnez	a5,ffffffe000202428 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000202470:	f9043783          	ld	a5,-112(s0)
ffffffe000202474:	00c7a783          	lw	a5,12(a5)
ffffffe000202478:	00078713          	mv	a4,a5
ffffffe00020247c:	fff00793          	li	a5,-1
ffffffe000202480:	02f71063          	bne	a4,a5,ffffffe0002024a0 <print_dec_int+0x168>
ffffffe000202484:	f9043783          	ld	a5,-112(s0)
ffffffe000202488:	0037c783          	lbu	a5,3(a5)
ffffffe00020248c:	00078a63          	beqz	a5,ffffffe0002024a0 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000202490:	f9043783          	ld	a5,-112(s0)
ffffffe000202494:	0087a703          	lw	a4,8(a5)
ffffffe000202498:	f9043783          	ld	a5,-112(s0)
ffffffe00020249c:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe0002024a0:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002024a4:	f9043783          	ld	a5,-112(s0)
ffffffe0002024a8:	0087a703          	lw	a4,8(a5)
ffffffe0002024ac:	fe842783          	lw	a5,-24(s0)
ffffffe0002024b0:	fcf42823          	sw	a5,-48(s0)
ffffffe0002024b4:	f9043783          	ld	a5,-112(s0)
ffffffe0002024b8:	00c7a783          	lw	a5,12(a5)
ffffffe0002024bc:	fcf42623          	sw	a5,-52(s0)
ffffffe0002024c0:	fd042783          	lw	a5,-48(s0)
ffffffe0002024c4:	00078593          	mv	a1,a5
ffffffe0002024c8:	fcc42783          	lw	a5,-52(s0)
ffffffe0002024cc:	00078613          	mv	a2,a5
ffffffe0002024d0:	0006069b          	sext.w	a3,a2
ffffffe0002024d4:	0005879b          	sext.w	a5,a1
ffffffe0002024d8:	00f6d463          	bge	a3,a5,ffffffe0002024e0 <print_dec_int+0x1a8>
ffffffe0002024dc:	00058613          	mv	a2,a1
ffffffe0002024e0:	0006079b          	sext.w	a5,a2
ffffffe0002024e4:	40f707bb          	subw	a5,a4,a5
ffffffe0002024e8:	0007871b          	sext.w	a4,a5
ffffffe0002024ec:	fd744783          	lbu	a5,-41(s0)
ffffffe0002024f0:	0007879b          	sext.w	a5,a5
ffffffe0002024f4:	40f707bb          	subw	a5,a4,a5
ffffffe0002024f8:	fef42023          	sw	a5,-32(s0)
ffffffe0002024fc:	0280006f          	j	ffffffe000202524 <print_dec_int+0x1ec>
        putch(' ');
ffffffe000202500:	fa843783          	ld	a5,-88(s0)
ffffffe000202504:	02000513          	li	a0,32
ffffffe000202508:	000780e7          	jalr	a5
        ++written;
ffffffe00020250c:	fe442783          	lw	a5,-28(s0)
ffffffe000202510:	0017879b          	addiw	a5,a5,1
ffffffe000202514:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000202518:	fe042783          	lw	a5,-32(s0)
ffffffe00020251c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202520:	fef42023          	sw	a5,-32(s0)
ffffffe000202524:	fe042783          	lw	a5,-32(s0)
ffffffe000202528:	0007879b          	sext.w	a5,a5
ffffffe00020252c:	fcf04ae3          	bgtz	a5,ffffffe000202500 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000202530:	fd744783          	lbu	a5,-41(s0)
ffffffe000202534:	0ff7f793          	zext.b	a5,a5
ffffffe000202538:	04078463          	beqz	a5,ffffffe000202580 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe00020253c:	fef44783          	lbu	a5,-17(s0)
ffffffe000202540:	0ff7f793          	zext.b	a5,a5
ffffffe000202544:	00078663          	beqz	a5,ffffffe000202550 <print_dec_int+0x218>
ffffffe000202548:	02d00793          	li	a5,45
ffffffe00020254c:	01c0006f          	j	ffffffe000202568 <print_dec_int+0x230>
ffffffe000202550:	f9043783          	ld	a5,-112(s0)
ffffffe000202554:	0057c783          	lbu	a5,5(a5)
ffffffe000202558:	00078663          	beqz	a5,ffffffe000202564 <print_dec_int+0x22c>
ffffffe00020255c:	02b00793          	li	a5,43
ffffffe000202560:	0080006f          	j	ffffffe000202568 <print_dec_int+0x230>
ffffffe000202564:	02000793          	li	a5,32
ffffffe000202568:	fa843703          	ld	a4,-88(s0)
ffffffe00020256c:	00078513          	mv	a0,a5
ffffffe000202570:	000700e7          	jalr	a4
        ++written;
ffffffe000202574:	fe442783          	lw	a5,-28(s0)
ffffffe000202578:	0017879b          	addiw	a5,a5,1
ffffffe00020257c:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000202580:	fe842783          	lw	a5,-24(s0)
ffffffe000202584:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202588:	0280006f          	j	ffffffe0002025b0 <print_dec_int+0x278>
        putch('0');
ffffffe00020258c:	fa843783          	ld	a5,-88(s0)
ffffffe000202590:	03000513          	li	a0,48
ffffffe000202594:	000780e7          	jalr	a5
        ++written;
ffffffe000202598:	fe442783          	lw	a5,-28(s0)
ffffffe00020259c:	0017879b          	addiw	a5,a5,1
ffffffe0002025a0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002025a4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002025a8:	0017879b          	addiw	a5,a5,1
ffffffe0002025ac:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002025b0:	f9043783          	ld	a5,-112(s0)
ffffffe0002025b4:	00c7a703          	lw	a4,12(a5)
ffffffe0002025b8:	fd744783          	lbu	a5,-41(s0)
ffffffe0002025bc:	0007879b          	sext.w	a5,a5
ffffffe0002025c0:	40f707bb          	subw	a5,a4,a5
ffffffe0002025c4:	0007871b          	sext.w	a4,a5
ffffffe0002025c8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002025cc:	0007879b          	sext.w	a5,a5
ffffffe0002025d0:	fae7cee3          	blt	a5,a4,ffffffe00020258c <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002025d4:	fe842783          	lw	a5,-24(s0)
ffffffe0002025d8:	fff7879b          	addiw	a5,a5,-1
ffffffe0002025dc:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002025e0:	03c0006f          	j	ffffffe00020261c <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe0002025e4:	fd842783          	lw	a5,-40(s0)
ffffffe0002025e8:	ff078793          	addi	a5,a5,-16
ffffffe0002025ec:	008787b3          	add	a5,a5,s0
ffffffe0002025f0:	fc87c783          	lbu	a5,-56(a5)
ffffffe0002025f4:	0007871b          	sext.w	a4,a5
ffffffe0002025f8:	fa843783          	ld	a5,-88(s0)
ffffffe0002025fc:	00070513          	mv	a0,a4
ffffffe000202600:	000780e7          	jalr	a5
        ++written;
ffffffe000202604:	fe442783          	lw	a5,-28(s0)
ffffffe000202608:	0017879b          	addiw	a5,a5,1
ffffffe00020260c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000202610:	fd842783          	lw	a5,-40(s0)
ffffffe000202614:	fff7879b          	addiw	a5,a5,-1
ffffffe000202618:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020261c:	fd842783          	lw	a5,-40(s0)
ffffffe000202620:	0007879b          	sext.w	a5,a5
ffffffe000202624:	fc07d0e3          	bgez	a5,ffffffe0002025e4 <print_dec_int+0x2ac>
    }

    return written;
ffffffe000202628:	fe442783          	lw	a5,-28(s0)
}
ffffffe00020262c:	00078513          	mv	a0,a5
ffffffe000202630:	06813083          	ld	ra,104(sp)
ffffffe000202634:	06013403          	ld	s0,96(sp)
ffffffe000202638:	07010113          	addi	sp,sp,112
ffffffe00020263c:	00008067          	ret

ffffffe000202640 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000202640:	f4010113          	addi	sp,sp,-192
ffffffe000202644:	0a113c23          	sd	ra,184(sp)
ffffffe000202648:	0a813823          	sd	s0,176(sp)
ffffffe00020264c:	0c010413          	addi	s0,sp,192
ffffffe000202650:	f4a43c23          	sd	a0,-168(s0)
ffffffe000202654:	f4b43823          	sd	a1,-176(s0)
ffffffe000202658:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe00020265c:	f8043023          	sd	zero,-128(s0)
ffffffe000202660:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000202664:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000202668:	7a40006f          	j	ffffffe000202e0c <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe00020266c:	f8044783          	lbu	a5,-128(s0)
ffffffe000202670:	72078e63          	beqz	a5,ffffffe000202dac <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000202674:	f5043783          	ld	a5,-176(s0)
ffffffe000202678:	0007c783          	lbu	a5,0(a5)
ffffffe00020267c:	00078713          	mv	a4,a5
ffffffe000202680:	02300793          	li	a5,35
ffffffe000202684:	00f71863          	bne	a4,a5,ffffffe000202694 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000202688:	00100793          	li	a5,1
ffffffe00020268c:	f8f40123          	sb	a5,-126(s0)
ffffffe000202690:	7700006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe000202694:	f5043783          	ld	a5,-176(s0)
ffffffe000202698:	0007c783          	lbu	a5,0(a5)
ffffffe00020269c:	00078713          	mv	a4,a5
ffffffe0002026a0:	03000793          	li	a5,48
ffffffe0002026a4:	00f71863          	bne	a4,a5,ffffffe0002026b4 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe0002026a8:	00100793          	li	a5,1
ffffffe0002026ac:	f8f401a3          	sb	a5,-125(s0)
ffffffe0002026b0:	7500006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe0002026b4:	f5043783          	ld	a5,-176(s0)
ffffffe0002026b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002026bc:	00078713          	mv	a4,a5
ffffffe0002026c0:	06c00793          	li	a5,108
ffffffe0002026c4:	04f70063          	beq	a4,a5,ffffffe000202704 <vprintfmt+0xc4>
ffffffe0002026c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002026cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002026d0:	00078713          	mv	a4,a5
ffffffe0002026d4:	07a00793          	li	a5,122
ffffffe0002026d8:	02f70663          	beq	a4,a5,ffffffe000202704 <vprintfmt+0xc4>
ffffffe0002026dc:	f5043783          	ld	a5,-176(s0)
ffffffe0002026e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002026e4:	00078713          	mv	a4,a5
ffffffe0002026e8:	07400793          	li	a5,116
ffffffe0002026ec:	00f70c63          	beq	a4,a5,ffffffe000202704 <vprintfmt+0xc4>
ffffffe0002026f0:	f5043783          	ld	a5,-176(s0)
ffffffe0002026f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002026f8:	00078713          	mv	a4,a5
ffffffe0002026fc:	06a00793          	li	a5,106
ffffffe000202700:	00f71863          	bne	a4,a5,ffffffe000202710 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000202704:	00100793          	li	a5,1
ffffffe000202708:	f8f400a3          	sb	a5,-127(s0)
ffffffe00020270c:	6f40006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000202710:	f5043783          	ld	a5,-176(s0)
ffffffe000202714:	0007c783          	lbu	a5,0(a5)
ffffffe000202718:	00078713          	mv	a4,a5
ffffffe00020271c:	02b00793          	li	a5,43
ffffffe000202720:	00f71863          	bne	a4,a5,ffffffe000202730 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000202724:	00100793          	li	a5,1
ffffffe000202728:	f8f402a3          	sb	a5,-123(s0)
ffffffe00020272c:	6d40006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000202730:	f5043783          	ld	a5,-176(s0)
ffffffe000202734:	0007c783          	lbu	a5,0(a5)
ffffffe000202738:	00078713          	mv	a4,a5
ffffffe00020273c:	02000793          	li	a5,32
ffffffe000202740:	00f71863          	bne	a4,a5,ffffffe000202750 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000202744:	00100793          	li	a5,1
ffffffe000202748:	f8f40223          	sb	a5,-124(s0)
ffffffe00020274c:	6b40006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000202750:	f5043783          	ld	a5,-176(s0)
ffffffe000202754:	0007c783          	lbu	a5,0(a5)
ffffffe000202758:	00078713          	mv	a4,a5
ffffffe00020275c:	02a00793          	li	a5,42
ffffffe000202760:	00f71e63          	bne	a4,a5,ffffffe00020277c <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe000202764:	f4843783          	ld	a5,-184(s0)
ffffffe000202768:	00878713          	addi	a4,a5,8
ffffffe00020276c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202770:	0007a783          	lw	a5,0(a5)
ffffffe000202774:	f8f42423          	sw	a5,-120(s0)
ffffffe000202778:	6880006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe00020277c:	f5043783          	ld	a5,-176(s0)
ffffffe000202780:	0007c783          	lbu	a5,0(a5)
ffffffe000202784:	00078713          	mv	a4,a5
ffffffe000202788:	03000793          	li	a5,48
ffffffe00020278c:	04e7f663          	bgeu	a5,a4,ffffffe0002027d8 <vprintfmt+0x198>
ffffffe000202790:	f5043783          	ld	a5,-176(s0)
ffffffe000202794:	0007c783          	lbu	a5,0(a5)
ffffffe000202798:	00078713          	mv	a4,a5
ffffffe00020279c:	03900793          	li	a5,57
ffffffe0002027a0:	02e7ec63          	bltu	a5,a4,ffffffe0002027d8 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe0002027a4:	f5043783          	ld	a5,-176(s0)
ffffffe0002027a8:	f5040713          	addi	a4,s0,-176
ffffffe0002027ac:	00a00613          	li	a2,10
ffffffe0002027b0:	00070593          	mv	a1,a4
ffffffe0002027b4:	00078513          	mv	a0,a5
ffffffe0002027b8:	88dff0ef          	jal	ffffffe000202044 <strtol>
ffffffe0002027bc:	00050793          	mv	a5,a0
ffffffe0002027c0:	0007879b          	sext.w	a5,a5
ffffffe0002027c4:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe0002027c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002027cc:	fff78793          	addi	a5,a5,-1
ffffffe0002027d0:	f4f43823          	sd	a5,-176(s0)
ffffffe0002027d4:	62c0006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe0002027d8:	f5043783          	ld	a5,-176(s0)
ffffffe0002027dc:	0007c783          	lbu	a5,0(a5)
ffffffe0002027e0:	00078713          	mv	a4,a5
ffffffe0002027e4:	02e00793          	li	a5,46
ffffffe0002027e8:	06f71863          	bne	a4,a5,ffffffe000202858 <vprintfmt+0x218>
                fmt++;
ffffffe0002027ec:	f5043783          	ld	a5,-176(s0)
ffffffe0002027f0:	00178793          	addi	a5,a5,1
ffffffe0002027f4:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe0002027f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002027fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202800:	00078713          	mv	a4,a5
ffffffe000202804:	02a00793          	li	a5,42
ffffffe000202808:	00f71e63          	bne	a4,a5,ffffffe000202824 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe00020280c:	f4843783          	ld	a5,-184(s0)
ffffffe000202810:	00878713          	addi	a4,a5,8
ffffffe000202814:	f4e43423          	sd	a4,-184(s0)
ffffffe000202818:	0007a783          	lw	a5,0(a5)
ffffffe00020281c:	f8f42623          	sw	a5,-116(s0)
ffffffe000202820:	5e00006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000202824:	f5043783          	ld	a5,-176(s0)
ffffffe000202828:	f5040713          	addi	a4,s0,-176
ffffffe00020282c:	00a00613          	li	a2,10
ffffffe000202830:	00070593          	mv	a1,a4
ffffffe000202834:	00078513          	mv	a0,a5
ffffffe000202838:	80dff0ef          	jal	ffffffe000202044 <strtol>
ffffffe00020283c:	00050793          	mv	a5,a0
ffffffe000202840:	0007879b          	sext.w	a5,a5
ffffffe000202844:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000202848:	f5043783          	ld	a5,-176(s0)
ffffffe00020284c:	fff78793          	addi	a5,a5,-1
ffffffe000202850:	f4f43823          	sd	a5,-176(s0)
ffffffe000202854:	5ac0006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202858:	f5043783          	ld	a5,-176(s0)
ffffffe00020285c:	0007c783          	lbu	a5,0(a5)
ffffffe000202860:	00078713          	mv	a4,a5
ffffffe000202864:	07800793          	li	a5,120
ffffffe000202868:	02f70663          	beq	a4,a5,ffffffe000202894 <vprintfmt+0x254>
ffffffe00020286c:	f5043783          	ld	a5,-176(s0)
ffffffe000202870:	0007c783          	lbu	a5,0(a5)
ffffffe000202874:	00078713          	mv	a4,a5
ffffffe000202878:	05800793          	li	a5,88
ffffffe00020287c:	00f70c63          	beq	a4,a5,ffffffe000202894 <vprintfmt+0x254>
ffffffe000202880:	f5043783          	ld	a5,-176(s0)
ffffffe000202884:	0007c783          	lbu	a5,0(a5)
ffffffe000202888:	00078713          	mv	a4,a5
ffffffe00020288c:	07000793          	li	a5,112
ffffffe000202890:	30f71263          	bne	a4,a5,ffffffe000202b94 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000202894:	f5043783          	ld	a5,-176(s0)
ffffffe000202898:	0007c783          	lbu	a5,0(a5)
ffffffe00020289c:	00078713          	mv	a4,a5
ffffffe0002028a0:	07000793          	li	a5,112
ffffffe0002028a4:	00f70663          	beq	a4,a5,ffffffe0002028b0 <vprintfmt+0x270>
ffffffe0002028a8:	f8144783          	lbu	a5,-127(s0)
ffffffe0002028ac:	00078663          	beqz	a5,ffffffe0002028b8 <vprintfmt+0x278>
ffffffe0002028b0:	00100793          	li	a5,1
ffffffe0002028b4:	0080006f          	j	ffffffe0002028bc <vprintfmt+0x27c>
ffffffe0002028b8:	00000793          	li	a5,0
ffffffe0002028bc:	faf403a3          	sb	a5,-89(s0)
ffffffe0002028c0:	fa744783          	lbu	a5,-89(s0)
ffffffe0002028c4:	0017f793          	andi	a5,a5,1
ffffffe0002028c8:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe0002028cc:	fa744783          	lbu	a5,-89(s0)
ffffffe0002028d0:	0ff7f793          	zext.b	a5,a5
ffffffe0002028d4:	00078c63          	beqz	a5,ffffffe0002028ec <vprintfmt+0x2ac>
ffffffe0002028d8:	f4843783          	ld	a5,-184(s0)
ffffffe0002028dc:	00878713          	addi	a4,a5,8
ffffffe0002028e0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002028e4:	0007b783          	ld	a5,0(a5)
ffffffe0002028e8:	01c0006f          	j	ffffffe000202904 <vprintfmt+0x2c4>
ffffffe0002028ec:	f4843783          	ld	a5,-184(s0)
ffffffe0002028f0:	00878713          	addi	a4,a5,8
ffffffe0002028f4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002028f8:	0007a783          	lw	a5,0(a5)
ffffffe0002028fc:	02079793          	slli	a5,a5,0x20
ffffffe000202900:	0207d793          	srli	a5,a5,0x20
ffffffe000202904:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000202908:	f8c42783          	lw	a5,-116(s0)
ffffffe00020290c:	02079463          	bnez	a5,ffffffe000202934 <vprintfmt+0x2f4>
ffffffe000202910:	fe043783          	ld	a5,-32(s0)
ffffffe000202914:	02079063          	bnez	a5,ffffffe000202934 <vprintfmt+0x2f4>
ffffffe000202918:	f5043783          	ld	a5,-176(s0)
ffffffe00020291c:	0007c783          	lbu	a5,0(a5)
ffffffe000202920:	00078713          	mv	a4,a5
ffffffe000202924:	07000793          	li	a5,112
ffffffe000202928:	00f70663          	beq	a4,a5,ffffffe000202934 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe00020292c:	f8040023          	sb	zero,-128(s0)
ffffffe000202930:	4d00006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000202934:	f5043783          	ld	a5,-176(s0)
ffffffe000202938:	0007c783          	lbu	a5,0(a5)
ffffffe00020293c:	00078713          	mv	a4,a5
ffffffe000202940:	07000793          	li	a5,112
ffffffe000202944:	00f70a63          	beq	a4,a5,ffffffe000202958 <vprintfmt+0x318>
ffffffe000202948:	f8244783          	lbu	a5,-126(s0)
ffffffe00020294c:	00078a63          	beqz	a5,ffffffe000202960 <vprintfmt+0x320>
ffffffe000202950:	fe043783          	ld	a5,-32(s0)
ffffffe000202954:	00078663          	beqz	a5,ffffffe000202960 <vprintfmt+0x320>
ffffffe000202958:	00100793          	li	a5,1
ffffffe00020295c:	0080006f          	j	ffffffe000202964 <vprintfmt+0x324>
ffffffe000202960:	00000793          	li	a5,0
ffffffe000202964:	faf40323          	sb	a5,-90(s0)
ffffffe000202968:	fa644783          	lbu	a5,-90(s0)
ffffffe00020296c:	0017f793          	andi	a5,a5,1
ffffffe000202970:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000202974:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000202978:	f5043783          	ld	a5,-176(s0)
ffffffe00020297c:	0007c783          	lbu	a5,0(a5)
ffffffe000202980:	00078713          	mv	a4,a5
ffffffe000202984:	05800793          	li	a5,88
ffffffe000202988:	00f71863          	bne	a4,a5,ffffffe000202998 <vprintfmt+0x358>
ffffffe00020298c:	00002797          	auipc	a5,0x2
ffffffe000202990:	d5478793          	addi	a5,a5,-684 # ffffffe0002046e0 <upperxdigits.1>
ffffffe000202994:	00c0006f          	j	ffffffe0002029a0 <vprintfmt+0x360>
ffffffe000202998:	00002797          	auipc	a5,0x2
ffffffe00020299c:	d6078793          	addi	a5,a5,-672 # ffffffe0002046f8 <lowerxdigits.0>
ffffffe0002029a0:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe0002029a4:	fe043783          	ld	a5,-32(s0)
ffffffe0002029a8:	00f7f793          	andi	a5,a5,15
ffffffe0002029ac:	f9843703          	ld	a4,-104(s0)
ffffffe0002029b0:	00f70733          	add	a4,a4,a5
ffffffe0002029b4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002029b8:	0017869b          	addiw	a3,a5,1
ffffffe0002029bc:	fcd42e23          	sw	a3,-36(s0)
ffffffe0002029c0:	00074703          	lbu	a4,0(a4)
ffffffe0002029c4:	ff078793          	addi	a5,a5,-16
ffffffe0002029c8:	008787b3          	add	a5,a5,s0
ffffffe0002029cc:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe0002029d0:	fe043783          	ld	a5,-32(s0)
ffffffe0002029d4:	0047d793          	srli	a5,a5,0x4
ffffffe0002029d8:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe0002029dc:	fe043783          	ld	a5,-32(s0)
ffffffe0002029e0:	fc0792e3          	bnez	a5,ffffffe0002029a4 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe0002029e4:	f8c42783          	lw	a5,-116(s0)
ffffffe0002029e8:	00078713          	mv	a4,a5
ffffffe0002029ec:	fff00793          	li	a5,-1
ffffffe0002029f0:	02f71663          	bne	a4,a5,ffffffe000202a1c <vprintfmt+0x3dc>
ffffffe0002029f4:	f8344783          	lbu	a5,-125(s0)
ffffffe0002029f8:	02078263          	beqz	a5,ffffffe000202a1c <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe0002029fc:	f8842703          	lw	a4,-120(s0)
ffffffe000202a00:	fa644783          	lbu	a5,-90(s0)
ffffffe000202a04:	0007879b          	sext.w	a5,a5
ffffffe000202a08:	0017979b          	slliw	a5,a5,0x1
ffffffe000202a0c:	0007879b          	sext.w	a5,a5
ffffffe000202a10:	40f707bb          	subw	a5,a4,a5
ffffffe000202a14:	0007879b          	sext.w	a5,a5
ffffffe000202a18:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202a1c:	f8842703          	lw	a4,-120(s0)
ffffffe000202a20:	fa644783          	lbu	a5,-90(s0)
ffffffe000202a24:	0007879b          	sext.w	a5,a5
ffffffe000202a28:	0017979b          	slliw	a5,a5,0x1
ffffffe000202a2c:	0007879b          	sext.w	a5,a5
ffffffe000202a30:	40f707bb          	subw	a5,a4,a5
ffffffe000202a34:	0007871b          	sext.w	a4,a5
ffffffe000202a38:	fdc42783          	lw	a5,-36(s0)
ffffffe000202a3c:	f8f42a23          	sw	a5,-108(s0)
ffffffe000202a40:	f8c42783          	lw	a5,-116(s0)
ffffffe000202a44:	f8f42823          	sw	a5,-112(s0)
ffffffe000202a48:	f9442783          	lw	a5,-108(s0)
ffffffe000202a4c:	00078593          	mv	a1,a5
ffffffe000202a50:	f9042783          	lw	a5,-112(s0)
ffffffe000202a54:	00078613          	mv	a2,a5
ffffffe000202a58:	0006069b          	sext.w	a3,a2
ffffffe000202a5c:	0005879b          	sext.w	a5,a1
ffffffe000202a60:	00f6d463          	bge	a3,a5,ffffffe000202a68 <vprintfmt+0x428>
ffffffe000202a64:	00058613          	mv	a2,a1
ffffffe000202a68:	0006079b          	sext.w	a5,a2
ffffffe000202a6c:	40f707bb          	subw	a5,a4,a5
ffffffe000202a70:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202a74:	0280006f          	j	ffffffe000202a9c <vprintfmt+0x45c>
                    putch(' ');
ffffffe000202a78:	f5843783          	ld	a5,-168(s0)
ffffffe000202a7c:	02000513          	li	a0,32
ffffffe000202a80:	000780e7          	jalr	a5
                    ++written;
ffffffe000202a84:	fec42783          	lw	a5,-20(s0)
ffffffe000202a88:	0017879b          	addiw	a5,a5,1
ffffffe000202a8c:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202a90:	fd842783          	lw	a5,-40(s0)
ffffffe000202a94:	fff7879b          	addiw	a5,a5,-1
ffffffe000202a98:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202a9c:	fd842783          	lw	a5,-40(s0)
ffffffe000202aa0:	0007879b          	sext.w	a5,a5
ffffffe000202aa4:	fcf04ae3          	bgtz	a5,ffffffe000202a78 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe000202aa8:	fa644783          	lbu	a5,-90(s0)
ffffffe000202aac:	0ff7f793          	zext.b	a5,a5
ffffffe000202ab0:	04078463          	beqz	a5,ffffffe000202af8 <vprintfmt+0x4b8>
                    putch('0');
ffffffe000202ab4:	f5843783          	ld	a5,-168(s0)
ffffffe000202ab8:	03000513          	li	a0,48
ffffffe000202abc:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000202ac0:	f5043783          	ld	a5,-176(s0)
ffffffe000202ac4:	0007c783          	lbu	a5,0(a5)
ffffffe000202ac8:	00078713          	mv	a4,a5
ffffffe000202acc:	05800793          	li	a5,88
ffffffe000202ad0:	00f71663          	bne	a4,a5,ffffffe000202adc <vprintfmt+0x49c>
ffffffe000202ad4:	05800793          	li	a5,88
ffffffe000202ad8:	0080006f          	j	ffffffe000202ae0 <vprintfmt+0x4a0>
ffffffe000202adc:	07800793          	li	a5,120
ffffffe000202ae0:	f5843703          	ld	a4,-168(s0)
ffffffe000202ae4:	00078513          	mv	a0,a5
ffffffe000202ae8:	000700e7          	jalr	a4
                    written += 2;
ffffffe000202aec:	fec42783          	lw	a5,-20(s0)
ffffffe000202af0:	0027879b          	addiw	a5,a5,2
ffffffe000202af4:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202af8:	fdc42783          	lw	a5,-36(s0)
ffffffe000202afc:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202b00:	0280006f          	j	ffffffe000202b28 <vprintfmt+0x4e8>
                    putch('0');
ffffffe000202b04:	f5843783          	ld	a5,-168(s0)
ffffffe000202b08:	03000513          	li	a0,48
ffffffe000202b0c:	000780e7          	jalr	a5
                    ++written;
ffffffe000202b10:	fec42783          	lw	a5,-20(s0)
ffffffe000202b14:	0017879b          	addiw	a5,a5,1
ffffffe000202b18:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202b1c:	fd442783          	lw	a5,-44(s0)
ffffffe000202b20:	0017879b          	addiw	a5,a5,1
ffffffe000202b24:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202b28:	f8c42703          	lw	a4,-116(s0)
ffffffe000202b2c:	fd442783          	lw	a5,-44(s0)
ffffffe000202b30:	0007879b          	sext.w	a5,a5
ffffffe000202b34:	fce7c8e3          	blt	a5,a4,ffffffe000202b04 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202b38:	fdc42783          	lw	a5,-36(s0)
ffffffe000202b3c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202b40:	fcf42823          	sw	a5,-48(s0)
ffffffe000202b44:	03c0006f          	j	ffffffe000202b80 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000202b48:	fd042783          	lw	a5,-48(s0)
ffffffe000202b4c:	ff078793          	addi	a5,a5,-16
ffffffe000202b50:	008787b3          	add	a5,a5,s0
ffffffe000202b54:	f807c783          	lbu	a5,-128(a5)
ffffffe000202b58:	0007871b          	sext.w	a4,a5
ffffffe000202b5c:	f5843783          	ld	a5,-168(s0)
ffffffe000202b60:	00070513          	mv	a0,a4
ffffffe000202b64:	000780e7          	jalr	a5
                    ++written;
ffffffe000202b68:	fec42783          	lw	a5,-20(s0)
ffffffe000202b6c:	0017879b          	addiw	a5,a5,1
ffffffe000202b70:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202b74:	fd042783          	lw	a5,-48(s0)
ffffffe000202b78:	fff7879b          	addiw	a5,a5,-1
ffffffe000202b7c:	fcf42823          	sw	a5,-48(s0)
ffffffe000202b80:	fd042783          	lw	a5,-48(s0)
ffffffe000202b84:	0007879b          	sext.w	a5,a5
ffffffe000202b88:	fc07d0e3          	bgez	a5,ffffffe000202b48 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe000202b8c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202b90:	2700006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202b94:	f5043783          	ld	a5,-176(s0)
ffffffe000202b98:	0007c783          	lbu	a5,0(a5)
ffffffe000202b9c:	00078713          	mv	a4,a5
ffffffe000202ba0:	06400793          	li	a5,100
ffffffe000202ba4:	02f70663          	beq	a4,a5,ffffffe000202bd0 <vprintfmt+0x590>
ffffffe000202ba8:	f5043783          	ld	a5,-176(s0)
ffffffe000202bac:	0007c783          	lbu	a5,0(a5)
ffffffe000202bb0:	00078713          	mv	a4,a5
ffffffe000202bb4:	06900793          	li	a5,105
ffffffe000202bb8:	00f70c63          	beq	a4,a5,ffffffe000202bd0 <vprintfmt+0x590>
ffffffe000202bbc:	f5043783          	ld	a5,-176(s0)
ffffffe000202bc0:	0007c783          	lbu	a5,0(a5)
ffffffe000202bc4:	00078713          	mv	a4,a5
ffffffe000202bc8:	07500793          	li	a5,117
ffffffe000202bcc:	08f71063          	bne	a4,a5,ffffffe000202c4c <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000202bd0:	f8144783          	lbu	a5,-127(s0)
ffffffe000202bd4:	00078c63          	beqz	a5,ffffffe000202bec <vprintfmt+0x5ac>
ffffffe000202bd8:	f4843783          	ld	a5,-184(s0)
ffffffe000202bdc:	00878713          	addi	a4,a5,8
ffffffe000202be0:	f4e43423          	sd	a4,-184(s0)
ffffffe000202be4:	0007b783          	ld	a5,0(a5)
ffffffe000202be8:	0140006f          	j	ffffffe000202bfc <vprintfmt+0x5bc>
ffffffe000202bec:	f4843783          	ld	a5,-184(s0)
ffffffe000202bf0:	00878713          	addi	a4,a5,8
ffffffe000202bf4:	f4e43423          	sd	a4,-184(s0)
ffffffe000202bf8:	0007a783          	lw	a5,0(a5)
ffffffe000202bfc:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000202c00:	fa843583          	ld	a1,-88(s0)
ffffffe000202c04:	f5043783          	ld	a5,-176(s0)
ffffffe000202c08:	0007c783          	lbu	a5,0(a5)
ffffffe000202c0c:	0007871b          	sext.w	a4,a5
ffffffe000202c10:	07500793          	li	a5,117
ffffffe000202c14:	40f707b3          	sub	a5,a4,a5
ffffffe000202c18:	00f037b3          	snez	a5,a5
ffffffe000202c1c:	0ff7f793          	zext.b	a5,a5
ffffffe000202c20:	f8040713          	addi	a4,s0,-128
ffffffe000202c24:	00070693          	mv	a3,a4
ffffffe000202c28:	00078613          	mv	a2,a5
ffffffe000202c2c:	f5843503          	ld	a0,-168(s0)
ffffffe000202c30:	f08ff0ef          	jal	ffffffe000202338 <print_dec_int>
ffffffe000202c34:	00050793          	mv	a5,a0
ffffffe000202c38:	fec42703          	lw	a4,-20(s0)
ffffffe000202c3c:	00f707bb          	addw	a5,a4,a5
ffffffe000202c40:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202c44:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202c48:	1b80006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000202c4c:	f5043783          	ld	a5,-176(s0)
ffffffe000202c50:	0007c783          	lbu	a5,0(a5)
ffffffe000202c54:	00078713          	mv	a4,a5
ffffffe000202c58:	06e00793          	li	a5,110
ffffffe000202c5c:	04f71c63          	bne	a4,a5,ffffffe000202cb4 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe000202c60:	f8144783          	lbu	a5,-127(s0)
ffffffe000202c64:	02078463          	beqz	a5,ffffffe000202c8c <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe000202c68:	f4843783          	ld	a5,-184(s0)
ffffffe000202c6c:	00878713          	addi	a4,a5,8
ffffffe000202c70:	f4e43423          	sd	a4,-184(s0)
ffffffe000202c74:	0007b783          	ld	a5,0(a5)
ffffffe000202c78:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000202c7c:	fec42703          	lw	a4,-20(s0)
ffffffe000202c80:	fb043783          	ld	a5,-80(s0)
ffffffe000202c84:	00e7b023          	sd	a4,0(a5)
ffffffe000202c88:	0240006f          	j	ffffffe000202cac <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000202c8c:	f4843783          	ld	a5,-184(s0)
ffffffe000202c90:	00878713          	addi	a4,a5,8
ffffffe000202c94:	f4e43423          	sd	a4,-184(s0)
ffffffe000202c98:	0007b783          	ld	a5,0(a5)
ffffffe000202c9c:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000202ca0:	fb843783          	ld	a5,-72(s0)
ffffffe000202ca4:	fec42703          	lw	a4,-20(s0)
ffffffe000202ca8:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000202cac:	f8040023          	sb	zero,-128(s0)
ffffffe000202cb0:	1500006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000202cb4:	f5043783          	ld	a5,-176(s0)
ffffffe000202cb8:	0007c783          	lbu	a5,0(a5)
ffffffe000202cbc:	00078713          	mv	a4,a5
ffffffe000202cc0:	07300793          	li	a5,115
ffffffe000202cc4:	02f71e63          	bne	a4,a5,ffffffe000202d00 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000202cc8:	f4843783          	ld	a5,-184(s0)
ffffffe000202ccc:	00878713          	addi	a4,a5,8
ffffffe000202cd0:	f4e43423          	sd	a4,-184(s0)
ffffffe000202cd4:	0007b783          	ld	a5,0(a5)
ffffffe000202cd8:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000202cdc:	fc043583          	ld	a1,-64(s0)
ffffffe000202ce0:	f5843503          	ld	a0,-168(s0)
ffffffe000202ce4:	dccff0ef          	jal	ffffffe0002022b0 <puts_wo_nl>
ffffffe000202ce8:	00050793          	mv	a5,a0
ffffffe000202cec:	fec42703          	lw	a4,-20(s0)
ffffffe000202cf0:	00f707bb          	addw	a5,a4,a5
ffffffe000202cf4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202cf8:	f8040023          	sb	zero,-128(s0)
ffffffe000202cfc:	1040006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000202d00:	f5043783          	ld	a5,-176(s0)
ffffffe000202d04:	0007c783          	lbu	a5,0(a5)
ffffffe000202d08:	00078713          	mv	a4,a5
ffffffe000202d0c:	06300793          	li	a5,99
ffffffe000202d10:	02f71e63          	bne	a4,a5,ffffffe000202d4c <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000202d14:	f4843783          	ld	a5,-184(s0)
ffffffe000202d18:	00878713          	addi	a4,a5,8
ffffffe000202d1c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202d20:	0007a783          	lw	a5,0(a5)
ffffffe000202d24:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000202d28:	fcc42703          	lw	a4,-52(s0)
ffffffe000202d2c:	f5843783          	ld	a5,-168(s0)
ffffffe000202d30:	00070513          	mv	a0,a4
ffffffe000202d34:	000780e7          	jalr	a5
                ++written;
ffffffe000202d38:	fec42783          	lw	a5,-20(s0)
ffffffe000202d3c:	0017879b          	addiw	a5,a5,1
ffffffe000202d40:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202d44:	f8040023          	sb	zero,-128(s0)
ffffffe000202d48:	0b80006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000202d4c:	f5043783          	ld	a5,-176(s0)
ffffffe000202d50:	0007c783          	lbu	a5,0(a5)
ffffffe000202d54:	00078713          	mv	a4,a5
ffffffe000202d58:	02500793          	li	a5,37
ffffffe000202d5c:	02f71263          	bne	a4,a5,ffffffe000202d80 <vprintfmt+0x740>
                putch('%');
ffffffe000202d60:	f5843783          	ld	a5,-168(s0)
ffffffe000202d64:	02500513          	li	a0,37
ffffffe000202d68:	000780e7          	jalr	a5
                ++written;
ffffffe000202d6c:	fec42783          	lw	a5,-20(s0)
ffffffe000202d70:	0017879b          	addiw	a5,a5,1
ffffffe000202d74:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202d78:	f8040023          	sb	zero,-128(s0)
ffffffe000202d7c:	0840006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000202d80:	f5043783          	ld	a5,-176(s0)
ffffffe000202d84:	0007c783          	lbu	a5,0(a5)
ffffffe000202d88:	0007871b          	sext.w	a4,a5
ffffffe000202d8c:	f5843783          	ld	a5,-168(s0)
ffffffe000202d90:	00070513          	mv	a0,a4
ffffffe000202d94:	000780e7          	jalr	a5
                ++written;
ffffffe000202d98:	fec42783          	lw	a5,-20(s0)
ffffffe000202d9c:	0017879b          	addiw	a5,a5,1
ffffffe000202da0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202da4:	f8040023          	sb	zero,-128(s0)
ffffffe000202da8:	0580006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000202dac:	f5043783          	ld	a5,-176(s0)
ffffffe000202db0:	0007c783          	lbu	a5,0(a5)
ffffffe000202db4:	00078713          	mv	a4,a5
ffffffe000202db8:	02500793          	li	a5,37
ffffffe000202dbc:	02f71063          	bne	a4,a5,ffffffe000202ddc <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202dc0:	f8043023          	sd	zero,-128(s0)
ffffffe000202dc4:	f8043423          	sd	zero,-120(s0)
ffffffe000202dc8:	00100793          	li	a5,1
ffffffe000202dcc:	f8f40023          	sb	a5,-128(s0)
ffffffe000202dd0:	fff00793          	li	a5,-1
ffffffe000202dd4:	f8f42623          	sw	a5,-116(s0)
ffffffe000202dd8:	0280006f          	j	ffffffe000202e00 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000202ddc:	f5043783          	ld	a5,-176(s0)
ffffffe000202de0:	0007c783          	lbu	a5,0(a5)
ffffffe000202de4:	0007871b          	sext.w	a4,a5
ffffffe000202de8:	f5843783          	ld	a5,-168(s0)
ffffffe000202dec:	00070513          	mv	a0,a4
ffffffe000202df0:	000780e7          	jalr	a5
            ++written;
ffffffe000202df4:	fec42783          	lw	a5,-20(s0)
ffffffe000202df8:	0017879b          	addiw	a5,a5,1
ffffffe000202dfc:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000202e00:	f5043783          	ld	a5,-176(s0)
ffffffe000202e04:	00178793          	addi	a5,a5,1
ffffffe000202e08:	f4f43823          	sd	a5,-176(s0)
ffffffe000202e0c:	f5043783          	ld	a5,-176(s0)
ffffffe000202e10:	0007c783          	lbu	a5,0(a5)
ffffffe000202e14:	84079ce3          	bnez	a5,ffffffe00020266c <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202e18:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202e1c:	00078513          	mv	a0,a5
ffffffe000202e20:	0b813083          	ld	ra,184(sp)
ffffffe000202e24:	0b013403          	ld	s0,176(sp)
ffffffe000202e28:	0c010113          	addi	sp,sp,192
ffffffe000202e2c:	00008067          	ret

ffffffe000202e30 <printk>:

int printk(const char* s, ...) {
ffffffe000202e30:	f9010113          	addi	sp,sp,-112
ffffffe000202e34:	02113423          	sd	ra,40(sp)
ffffffe000202e38:	02813023          	sd	s0,32(sp)
ffffffe000202e3c:	03010413          	addi	s0,sp,48
ffffffe000202e40:	fca43c23          	sd	a0,-40(s0)
ffffffe000202e44:	00b43423          	sd	a1,8(s0)
ffffffe000202e48:	00c43823          	sd	a2,16(s0)
ffffffe000202e4c:	00d43c23          	sd	a3,24(s0)
ffffffe000202e50:	02e43023          	sd	a4,32(s0)
ffffffe000202e54:	02f43423          	sd	a5,40(s0)
ffffffe000202e58:	03043823          	sd	a6,48(s0)
ffffffe000202e5c:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000202e60:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000202e64:	04040793          	addi	a5,s0,64
ffffffe000202e68:	fcf43823          	sd	a5,-48(s0)
ffffffe000202e6c:	fd043783          	ld	a5,-48(s0)
ffffffe000202e70:	fc878793          	addi	a5,a5,-56
ffffffe000202e74:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000202e78:	fe043783          	ld	a5,-32(s0)
ffffffe000202e7c:	00078613          	mv	a2,a5
ffffffe000202e80:	fd843583          	ld	a1,-40(s0)
ffffffe000202e84:	fffff517          	auipc	a0,0xfffff
ffffffe000202e88:	11850513          	addi	a0,a0,280 # ffffffe000201f9c <putc>
ffffffe000202e8c:	fb4ff0ef          	jal	ffffffe000202640 <vprintfmt>
ffffffe000202e90:	00050793          	mv	a5,a0
ffffffe000202e94:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000202e98:	fec42783          	lw	a5,-20(s0)
}
ffffffe000202e9c:	00078513          	mv	a0,a5
ffffffe000202ea0:	02813083          	ld	ra,40(sp)
ffffffe000202ea4:	02013403          	ld	s0,32(sp)
ffffffe000202ea8:	07010113          	addi	sp,sp,112
ffffffe000202eac:	00008067          	ret

ffffffe000202eb0 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000202eb0:	fe010113          	addi	sp,sp,-32
ffffffe000202eb4:	00813c23          	sd	s0,24(sp)
ffffffe000202eb8:	02010413          	addi	s0,sp,32
ffffffe000202ebc:	00050793          	mv	a5,a0
ffffffe000202ec0:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000202ec4:	fec42783          	lw	a5,-20(s0)
ffffffe000202ec8:	fff7879b          	addiw	a5,a5,-1
ffffffe000202ecc:	0007879b          	sext.w	a5,a5
ffffffe000202ed0:	02079713          	slli	a4,a5,0x20
ffffffe000202ed4:	02075713          	srli	a4,a4,0x20
ffffffe000202ed8:	00006797          	auipc	a5,0x6
ffffffe000202edc:	14078793          	addi	a5,a5,320 # ffffffe000209018 <seed>
ffffffe000202ee0:	00e7b023          	sd	a4,0(a5)
}
ffffffe000202ee4:	00000013          	nop
ffffffe000202ee8:	01813403          	ld	s0,24(sp)
ffffffe000202eec:	02010113          	addi	sp,sp,32
ffffffe000202ef0:	00008067          	ret

ffffffe000202ef4 <rand>:

int rand(void) {
ffffffe000202ef4:	ff010113          	addi	sp,sp,-16
ffffffe000202ef8:	00813423          	sd	s0,8(sp)
ffffffe000202efc:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000202f00:	00006797          	auipc	a5,0x6
ffffffe000202f04:	11878793          	addi	a5,a5,280 # ffffffe000209018 <seed>
ffffffe000202f08:	0007b703          	ld	a4,0(a5)
ffffffe000202f0c:	00002797          	auipc	a5,0x2
ffffffe000202f10:	80478793          	addi	a5,a5,-2044 # ffffffe000204710 <lowerxdigits.0+0x18>
ffffffe000202f14:	0007b783          	ld	a5,0(a5)
ffffffe000202f18:	02f707b3          	mul	a5,a4,a5
ffffffe000202f1c:	00178713          	addi	a4,a5,1
ffffffe000202f20:	00006797          	auipc	a5,0x6
ffffffe000202f24:	0f878793          	addi	a5,a5,248 # ffffffe000209018 <seed>
ffffffe000202f28:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000202f2c:	00006797          	auipc	a5,0x6
ffffffe000202f30:	0ec78793          	addi	a5,a5,236 # ffffffe000209018 <seed>
ffffffe000202f34:	0007b783          	ld	a5,0(a5)
ffffffe000202f38:	0217d793          	srli	a5,a5,0x21
ffffffe000202f3c:	0007879b          	sext.w	a5,a5
}
ffffffe000202f40:	00078513          	mv	a0,a5
ffffffe000202f44:	00813403          	ld	s0,8(sp)
ffffffe000202f48:	01010113          	addi	sp,sp,16
ffffffe000202f4c:	00008067          	ret

ffffffe000202f50 <memset>:
#include "string.h"

#include "stdint.h"

void* memset(void* dest, int c, uint64_t n) {
ffffffe000202f50:	fc010113          	addi	sp,sp,-64
ffffffe000202f54:	02813c23          	sd	s0,56(sp)
ffffffe000202f58:	04010413          	addi	s0,sp,64
ffffffe000202f5c:	fca43c23          	sd	a0,-40(s0)
ffffffe000202f60:	00058793          	mv	a5,a1
ffffffe000202f64:	fcc43423          	sd	a2,-56(s0)
ffffffe000202f68:	fcf42a23          	sw	a5,-44(s0)
    char* s = (char*)dest;
ffffffe000202f6c:	fd843783          	ld	a5,-40(s0)
ffffffe000202f70:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202f74:	fe043423          	sd	zero,-24(s0)
ffffffe000202f78:	0280006f          	j	ffffffe000202fa0 <memset+0x50>
        s[i] = c;
ffffffe000202f7c:	fe043703          	ld	a4,-32(s0)
ffffffe000202f80:	fe843783          	ld	a5,-24(s0)
ffffffe000202f84:	00f707b3          	add	a5,a4,a5
ffffffe000202f88:	fd442703          	lw	a4,-44(s0)
ffffffe000202f8c:	0ff77713          	zext.b	a4,a4
ffffffe000202f90:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202f94:	fe843783          	ld	a5,-24(s0)
ffffffe000202f98:	00178793          	addi	a5,a5,1
ffffffe000202f9c:	fef43423          	sd	a5,-24(s0)
ffffffe000202fa0:	fe843703          	ld	a4,-24(s0)
ffffffe000202fa4:	fc843783          	ld	a5,-56(s0)
ffffffe000202fa8:	fcf76ae3          	bltu	a4,a5,ffffffe000202f7c <memset+0x2c>
    }
    return dest;
ffffffe000202fac:	fd843783          	ld	a5,-40(s0)
}
ffffffe000202fb0:	00078513          	mv	a0,a5
ffffffe000202fb4:	03813403          	ld	s0,56(sp)
ffffffe000202fb8:	04010113          	addi	sp,sp,64
ffffffe000202fbc:	00008067          	ret

ffffffe000202fc0 <memcpy>:

void* memcpy(void* dst, const void* src, uint64_t n) {
ffffffe000202fc0:	fb010113          	addi	sp,sp,-80
ffffffe000202fc4:	04813423          	sd	s0,72(sp)
ffffffe000202fc8:	05010413          	addi	s0,sp,80
ffffffe000202fcc:	fca43423          	sd	a0,-56(s0)
ffffffe000202fd0:	fcb43023          	sd	a1,-64(s0)
ffffffe000202fd4:	fac43c23          	sd	a2,-72(s0)
    uint8_t* d       = (uint8_t*)dst;
ffffffe000202fd8:	fc843783          	ld	a5,-56(s0)
ffffffe000202fdc:	fef43023          	sd	a5,-32(s0)
    const uint8_t* s = (const uint8_t*)src;
ffffffe000202fe0:	fc043783          	ld	a5,-64(s0)
ffffffe000202fe4:	fcf43c23          	sd	a5,-40(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202fe8:	fe043423          	sd	zero,-24(s0)
ffffffe000202fec:	0300006f          	j	ffffffe00020301c <memcpy+0x5c>
        d[i] = s[i];
ffffffe000202ff0:	fd843703          	ld	a4,-40(s0)
ffffffe000202ff4:	fe843783          	ld	a5,-24(s0)
ffffffe000202ff8:	00f70733          	add	a4,a4,a5
ffffffe000202ffc:	fe043683          	ld	a3,-32(s0)
ffffffe000203000:	fe843783          	ld	a5,-24(s0)
ffffffe000203004:	00f687b3          	add	a5,a3,a5
ffffffe000203008:	00074703          	lbu	a4,0(a4)
ffffffe00020300c:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203010:	fe843783          	ld	a5,-24(s0)
ffffffe000203014:	00178793          	addi	a5,a5,1
ffffffe000203018:	fef43423          	sd	a5,-24(s0)
ffffffe00020301c:	fe843703          	ld	a4,-24(s0)
ffffffe000203020:	fb843783          	ld	a5,-72(s0)
ffffffe000203024:	fcf766e3          	bltu	a4,a5,ffffffe000202ff0 <memcpy+0x30>
    }
    return dst;
ffffffe000203028:	fc843783          	ld	a5,-56(s0)
}
ffffffe00020302c:	00078513          	mv	a0,a5
ffffffe000203030:	04813403          	ld	s0,72(sp)
ffffffe000203034:	05010113          	addi	sp,sp,80
ffffffe000203038:	00008067          	ret

ffffffe00020303c <memmove>:

void* memmove(void* dst, const void* src, uint64_t n) {
ffffffe00020303c:	fb010113          	addi	sp,sp,-80
ffffffe000203040:	04113423          	sd	ra,72(sp)
ffffffe000203044:	04813023          	sd	s0,64(sp)
ffffffe000203048:	05010413          	addi	s0,sp,80
ffffffe00020304c:	fca43423          	sd	a0,-56(s0)
ffffffe000203050:	fcb43023          	sd	a1,-64(s0)
ffffffe000203054:	fac43c23          	sd	a2,-72(s0)
    uint8_t* d       = (uint8_t*)dst;
ffffffe000203058:	fc843783          	ld	a5,-56(s0)
ffffffe00020305c:	fef43023          	sd	a5,-32(s0)
    const uint8_t* s = (const uint8_t*)src;
ffffffe000203060:	fc043783          	ld	a5,-64(s0)
ffffffe000203064:	fcf43c23          	sd	a5,-40(s0)
    if (d < s) {
ffffffe000203068:	fe043703          	ld	a4,-32(s0)
ffffffe00020306c:	fd843783          	ld	a5,-40(s0)
ffffffe000203070:	00f77c63          	bgeu	a4,a5,ffffffe000203088 <memmove+0x4c>
        memcpy(dst, src, n);
ffffffe000203074:	fb843603          	ld	a2,-72(s0)
ffffffe000203078:	fc043583          	ld	a1,-64(s0)
ffffffe00020307c:	fc843503          	ld	a0,-56(s0)
ffffffe000203080:	f41ff0ef          	jal	ffffffe000202fc0 <memcpy>
ffffffe000203084:	04c0006f          	j	ffffffe0002030d0 <memmove+0x94>
    } else {
        for (uint64_t i = n; i > 0; --i) {
ffffffe000203088:	fb843783          	ld	a5,-72(s0)
ffffffe00020308c:	fef43423          	sd	a5,-24(s0)
ffffffe000203090:	0380006f          	j	ffffffe0002030c8 <memmove+0x8c>
            d[i - 1] = s[i - 1];
ffffffe000203094:	fe843783          	ld	a5,-24(s0)
ffffffe000203098:	fff78793          	addi	a5,a5,-1
ffffffe00020309c:	fd843703          	ld	a4,-40(s0)
ffffffe0002030a0:	00f70733          	add	a4,a4,a5
ffffffe0002030a4:	fe843783          	ld	a5,-24(s0)
ffffffe0002030a8:	fff78793          	addi	a5,a5,-1
ffffffe0002030ac:	fe043683          	ld	a3,-32(s0)
ffffffe0002030b0:	00f687b3          	add	a5,a3,a5
ffffffe0002030b4:	00074703          	lbu	a4,0(a4)
ffffffe0002030b8:	00e78023          	sb	a4,0(a5)
        for (uint64_t i = n; i > 0; --i) {
ffffffe0002030bc:	fe843783          	ld	a5,-24(s0)
ffffffe0002030c0:	fff78793          	addi	a5,a5,-1
ffffffe0002030c4:	fef43423          	sd	a5,-24(s0)
ffffffe0002030c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002030cc:	fc0794e3          	bnez	a5,ffffffe000203094 <memmove+0x58>
        }
    }
    return dst;
ffffffe0002030d0:	fc843783          	ld	a5,-56(s0)
ffffffe0002030d4:	00078513          	mv	a0,a5
ffffffe0002030d8:	04813083          	ld	ra,72(sp)
ffffffe0002030dc:	04013403          	ld	s0,64(sp)
ffffffe0002030e0:	05010113          	addi	sp,sp,80
ffffffe0002030e4:	00008067          	ret
