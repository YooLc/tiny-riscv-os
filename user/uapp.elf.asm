
uapp.elf:     file format elf64-littleriscv


Disassembly of section .text.init:

0000000000000000 <_start>:
   0:	0380006f          	j	38 <main>

Disassembly of section .text.getpid:

0000000000000004 <getpid>:
   4:	fe010113          	addi	sp,sp,-32
   8:	00813c23          	sd	s0,24(sp)
   c:	02010413          	addi	s0,sp,32
  10:	fe843783          	ld	a5,-24(s0)
  14:	0ac00893          	li	a7,172
  18:	00000073          	ecall
  1c:	00050793          	mv	a5,a0
  20:	fef43423          	sd	a5,-24(s0)
  24:	fe843783          	ld	a5,-24(s0)
  28:	00078513          	mv	a0,a5
  2c:	01813403          	ld	s0,24(sp)
  30:	02010113          	addi	sp,sp,32
  34:	00008067          	ret

Disassembly of section .text.main:

0000000000000038 <main>:
  38:	fe010113          	addi	sp,sp,-32
  3c:	00113c23          	sd	ra,24(sp)
  40:	00813823          	sd	s0,16(sp)
  44:	02010413          	addi	s0,sp,32
  48:	00000097          	auipc	ra,0x0
  4c:	fbc080e7          	jalr	-68(ra) # 4 <getpid>
  50:	00050593          	mv	a1,a0
  54:	00010613          	mv	a2,sp
  58:	00001797          	auipc	a5,0x1
  5c:	23478793          	addi	a5,a5,564 # 128c <counter>
  60:	0007a783          	lw	a5,0(a5)
  64:	0017879b          	addiw	a5,a5,1
  68:	0007871b          	sext.w	a4,a5
  6c:	00001797          	auipc	a5,0x1
  70:	22078793          	addi	a5,a5,544 # 128c <counter>
  74:	00e7a023          	sw	a4,0(a5)
  78:	00001797          	auipc	a5,0x1
  7c:	21478793          	addi	a5,a5,532 # 128c <counter>
  80:	0007a783          	lw	a5,0(a5)
  84:	00078693          	mv	a3,a5
  88:	00001517          	auipc	a0,0x1
  8c:	18050513          	addi	a0,a0,384 # 1208 <printf+0x278>
  90:	00001097          	auipc	ra,0x1
  94:	f00080e7          	jalr	-256(ra) # f90 <printf>
  98:	fe042623          	sw	zero,-20(s0)
  9c:	0100006f          	j	ac <main+0x74>
  a0:	fec42783          	lw	a5,-20(s0)
  a4:	0017879b          	addiw	a5,a5,1
  a8:	fef42623          	sw	a5,-20(s0)
  ac:	fec42783          	lw	a5,-20(s0)
  b0:	0007871b          	sext.w	a4,a5
  b4:	500007b7          	lui	a5,0x50000
  b8:	ffe78793          	addi	a5,a5,-2 # 4ffffffe <buffer+0x4fffed66>
  bc:	fee7f2e3          	bgeu	a5,a4,a0 <main+0x68>
  c0:	f89ff06f          	j	48 <main+0x10>

Disassembly of section .text.putc:

00000000000000c4 <putc>:
  c4:	fe010113          	addi	sp,sp,-32
  c8:	00813c23          	sd	s0,24(sp)
  cc:	02010413          	addi	s0,sp,32
  d0:	00050793          	mv	a5,a0
  d4:	fef42623          	sw	a5,-20(s0)
  d8:	00001797          	auipc	a5,0x1
  dc:	1b878793          	addi	a5,a5,440 # 1290 <tail>
  e0:	0007a783          	lw	a5,0(a5)
  e4:	0017871b          	addiw	a4,a5,1
  e8:	0007069b          	sext.w	a3,a4
  ec:	00001717          	auipc	a4,0x1
  f0:	1a470713          	addi	a4,a4,420 # 1290 <tail>
  f4:	00d72023          	sw	a3,0(a4)
  f8:	fec42703          	lw	a4,-20(s0)
  fc:	0ff77713          	zext.b	a4,a4
 100:	00001697          	auipc	a3,0x1
 104:	19868693          	addi	a3,a3,408 # 1298 <buffer>
 108:	00f687b3          	add	a5,a3,a5
 10c:	00e78023          	sb	a4,0(a5)
 110:	fec42783          	lw	a5,-20(s0)
 114:	0ff7f793          	zext.b	a5,a5
 118:	0007879b          	sext.w	a5,a5
 11c:	00078513          	mv	a0,a5
 120:	01813403          	ld	s0,24(sp)
 124:	02010113          	addi	sp,sp,32
 128:	00008067          	ret

Disassembly of section .text.isspace:

000000000000012c <isspace>:
 12c:	fe010113          	addi	sp,sp,-32
 130:	00813c23          	sd	s0,24(sp)
 134:	02010413          	addi	s0,sp,32
 138:	00050793          	mv	a5,a0
 13c:	fef42623          	sw	a5,-20(s0)
 140:	fec42783          	lw	a5,-20(s0)
 144:	0007871b          	sext.w	a4,a5
 148:	02000793          	li	a5,32
 14c:	02f70263          	beq	a4,a5,170 <isspace+0x44>
 150:	fec42783          	lw	a5,-20(s0)
 154:	0007871b          	sext.w	a4,a5
 158:	00800793          	li	a5,8
 15c:	00e7de63          	bge	a5,a4,178 <isspace+0x4c>
 160:	fec42783          	lw	a5,-20(s0)
 164:	0007871b          	sext.w	a4,a5
 168:	00d00793          	li	a5,13
 16c:	00e7c663          	blt	a5,a4,178 <isspace+0x4c>
 170:	00100793          	li	a5,1
 174:	0080006f          	j	17c <isspace+0x50>
 178:	00000793          	li	a5,0
 17c:	00078513          	mv	a0,a5
 180:	01813403          	ld	s0,24(sp)
 184:	02010113          	addi	sp,sp,32
 188:	00008067          	ret

Disassembly of section .text.strtol:

000000000000018c <strtol>:
 18c:	fb010113          	addi	sp,sp,-80
 190:	04113423          	sd	ra,72(sp)
 194:	04813023          	sd	s0,64(sp)
 198:	05010413          	addi	s0,sp,80
 19c:	fca43423          	sd	a0,-56(s0)
 1a0:	fcb43023          	sd	a1,-64(s0)
 1a4:	00060793          	mv	a5,a2
 1a8:	faf42e23          	sw	a5,-68(s0)
 1ac:	fe043423          	sd	zero,-24(s0)
 1b0:	fe0403a3          	sb	zero,-25(s0)
 1b4:	fc843783          	ld	a5,-56(s0)
 1b8:	fcf43c23          	sd	a5,-40(s0)
 1bc:	0100006f          	j	1cc <strtol+0x40>
 1c0:	fd843783          	ld	a5,-40(s0)
 1c4:	00178793          	addi	a5,a5,1
 1c8:	fcf43c23          	sd	a5,-40(s0)
 1cc:	fd843783          	ld	a5,-40(s0)
 1d0:	0007c783          	lbu	a5,0(a5)
 1d4:	0007879b          	sext.w	a5,a5
 1d8:	00078513          	mv	a0,a5
 1dc:	00000097          	auipc	ra,0x0
 1e0:	f50080e7          	jalr	-176(ra) # 12c <isspace>
 1e4:	00050793          	mv	a5,a0
 1e8:	fc079ce3          	bnez	a5,1c0 <strtol+0x34>
 1ec:	fd843783          	ld	a5,-40(s0)
 1f0:	0007c783          	lbu	a5,0(a5)
 1f4:	00078713          	mv	a4,a5
 1f8:	02d00793          	li	a5,45
 1fc:	00f71e63          	bne	a4,a5,218 <strtol+0x8c>
 200:	00100793          	li	a5,1
 204:	fef403a3          	sb	a5,-25(s0)
 208:	fd843783          	ld	a5,-40(s0)
 20c:	00178793          	addi	a5,a5,1
 210:	fcf43c23          	sd	a5,-40(s0)
 214:	0240006f          	j	238 <strtol+0xac>
 218:	fd843783          	ld	a5,-40(s0)
 21c:	0007c783          	lbu	a5,0(a5)
 220:	00078713          	mv	a4,a5
 224:	02b00793          	li	a5,43
 228:	00f71863          	bne	a4,a5,238 <strtol+0xac>
 22c:	fd843783          	ld	a5,-40(s0)
 230:	00178793          	addi	a5,a5,1
 234:	fcf43c23          	sd	a5,-40(s0)
 238:	fbc42783          	lw	a5,-68(s0)
 23c:	0007879b          	sext.w	a5,a5
 240:	06079c63          	bnez	a5,2b8 <strtol+0x12c>
 244:	fd843783          	ld	a5,-40(s0)
 248:	0007c783          	lbu	a5,0(a5)
 24c:	00078713          	mv	a4,a5
 250:	03000793          	li	a5,48
 254:	04f71e63          	bne	a4,a5,2b0 <strtol+0x124>
 258:	fd843783          	ld	a5,-40(s0)
 25c:	00178793          	addi	a5,a5,1
 260:	fcf43c23          	sd	a5,-40(s0)
 264:	fd843783          	ld	a5,-40(s0)
 268:	0007c783          	lbu	a5,0(a5)
 26c:	00078713          	mv	a4,a5
 270:	07800793          	li	a5,120
 274:	00f70c63          	beq	a4,a5,28c <strtol+0x100>
 278:	fd843783          	ld	a5,-40(s0)
 27c:	0007c783          	lbu	a5,0(a5)
 280:	00078713          	mv	a4,a5
 284:	05800793          	li	a5,88
 288:	00f71e63          	bne	a4,a5,2a4 <strtol+0x118>
 28c:	01000793          	li	a5,16
 290:	faf42e23          	sw	a5,-68(s0)
 294:	fd843783          	ld	a5,-40(s0)
 298:	00178793          	addi	a5,a5,1
 29c:	fcf43c23          	sd	a5,-40(s0)
 2a0:	0180006f          	j	2b8 <strtol+0x12c>
 2a4:	00800793          	li	a5,8
 2a8:	faf42e23          	sw	a5,-68(s0)
 2ac:	00c0006f          	j	2b8 <strtol+0x12c>
 2b0:	00a00793          	li	a5,10
 2b4:	faf42e23          	sw	a5,-68(s0)
 2b8:	fd843783          	ld	a5,-40(s0)
 2bc:	0007c783          	lbu	a5,0(a5)
 2c0:	00078713          	mv	a4,a5
 2c4:	02f00793          	li	a5,47
 2c8:	02e7f863          	bgeu	a5,a4,2f8 <strtol+0x16c>
 2cc:	fd843783          	ld	a5,-40(s0)
 2d0:	0007c783          	lbu	a5,0(a5)
 2d4:	00078713          	mv	a4,a5
 2d8:	03900793          	li	a5,57
 2dc:	00e7ee63          	bltu	a5,a4,2f8 <strtol+0x16c>
 2e0:	fd843783          	ld	a5,-40(s0)
 2e4:	0007c783          	lbu	a5,0(a5)
 2e8:	0007879b          	sext.w	a5,a5
 2ec:	fd07879b          	addiw	a5,a5,-48
 2f0:	fcf42a23          	sw	a5,-44(s0)
 2f4:	0800006f          	j	374 <strtol+0x1e8>
 2f8:	fd843783          	ld	a5,-40(s0)
 2fc:	0007c783          	lbu	a5,0(a5)
 300:	00078713          	mv	a4,a5
 304:	06000793          	li	a5,96
 308:	02e7f863          	bgeu	a5,a4,338 <strtol+0x1ac>
 30c:	fd843783          	ld	a5,-40(s0)
 310:	0007c783          	lbu	a5,0(a5)
 314:	00078713          	mv	a4,a5
 318:	07a00793          	li	a5,122
 31c:	00e7ee63          	bltu	a5,a4,338 <strtol+0x1ac>
 320:	fd843783          	ld	a5,-40(s0)
 324:	0007c783          	lbu	a5,0(a5)
 328:	0007879b          	sext.w	a5,a5
 32c:	fa97879b          	addiw	a5,a5,-87
 330:	fcf42a23          	sw	a5,-44(s0)
 334:	0400006f          	j	374 <strtol+0x1e8>
 338:	fd843783          	ld	a5,-40(s0)
 33c:	0007c783          	lbu	a5,0(a5)
 340:	00078713          	mv	a4,a5
 344:	04000793          	li	a5,64
 348:	06e7f863          	bgeu	a5,a4,3b8 <strtol+0x22c>
 34c:	fd843783          	ld	a5,-40(s0)
 350:	0007c783          	lbu	a5,0(a5)
 354:	00078713          	mv	a4,a5
 358:	05a00793          	li	a5,90
 35c:	04e7ee63          	bltu	a5,a4,3b8 <strtol+0x22c>
 360:	fd843783          	ld	a5,-40(s0)
 364:	0007c783          	lbu	a5,0(a5)
 368:	0007879b          	sext.w	a5,a5
 36c:	fc97879b          	addiw	a5,a5,-55
 370:	fcf42a23          	sw	a5,-44(s0)
 374:	fd442783          	lw	a5,-44(s0)
 378:	00078713          	mv	a4,a5
 37c:	fbc42783          	lw	a5,-68(s0)
 380:	0007071b          	sext.w	a4,a4
 384:	0007879b          	sext.w	a5,a5
 388:	02f75663          	bge	a4,a5,3b4 <strtol+0x228>
 38c:	fbc42703          	lw	a4,-68(s0)
 390:	fe843783          	ld	a5,-24(s0)
 394:	02f70733          	mul	a4,a4,a5
 398:	fd442783          	lw	a5,-44(s0)
 39c:	00f707b3          	add	a5,a4,a5
 3a0:	fef43423          	sd	a5,-24(s0)
 3a4:	fd843783          	ld	a5,-40(s0)
 3a8:	00178793          	addi	a5,a5,1
 3ac:	fcf43c23          	sd	a5,-40(s0)
 3b0:	f09ff06f          	j	2b8 <strtol+0x12c>
 3b4:	00000013          	nop
 3b8:	fc043783          	ld	a5,-64(s0)
 3bc:	00078863          	beqz	a5,3cc <strtol+0x240>
 3c0:	fc043783          	ld	a5,-64(s0)
 3c4:	fd843703          	ld	a4,-40(s0)
 3c8:	00e7b023          	sd	a4,0(a5)
 3cc:	fe744783          	lbu	a5,-25(s0)
 3d0:	0ff7f793          	zext.b	a5,a5
 3d4:	00078863          	beqz	a5,3e4 <strtol+0x258>
 3d8:	fe843783          	ld	a5,-24(s0)
 3dc:	40f007b3          	neg	a5,a5
 3e0:	0080006f          	j	3e8 <strtol+0x25c>
 3e4:	fe843783          	ld	a5,-24(s0)
 3e8:	00078513          	mv	a0,a5
 3ec:	04813083          	ld	ra,72(sp)
 3f0:	04013403          	ld	s0,64(sp)
 3f4:	05010113          	addi	sp,sp,80
 3f8:	00008067          	ret

Disassembly of section .text.puts_wo_nl:

00000000000003fc <puts_wo_nl>:
 3fc:	fd010113          	addi	sp,sp,-48
 400:	02113423          	sd	ra,40(sp)
 404:	02813023          	sd	s0,32(sp)
 408:	03010413          	addi	s0,sp,48
 40c:	fca43c23          	sd	a0,-40(s0)
 410:	fcb43823          	sd	a1,-48(s0)
 414:	fd043783          	ld	a5,-48(s0)
 418:	00079863          	bnez	a5,428 <puts_wo_nl+0x2c>
 41c:	00001797          	auipc	a5,0x1
 420:	e2478793          	addi	a5,a5,-476 # 1240 <printf+0x2b0>
 424:	fcf43823          	sd	a5,-48(s0)
 428:	fd043783          	ld	a5,-48(s0)
 42c:	fef43423          	sd	a5,-24(s0)
 430:	0240006f          	j	454 <puts_wo_nl+0x58>
 434:	fe843783          	ld	a5,-24(s0)
 438:	00178713          	addi	a4,a5,1
 43c:	fee43423          	sd	a4,-24(s0)
 440:	0007c783          	lbu	a5,0(a5)
 444:	0007871b          	sext.w	a4,a5
 448:	fd843783          	ld	a5,-40(s0)
 44c:	00070513          	mv	a0,a4
 450:	000780e7          	jalr	a5
 454:	fe843783          	ld	a5,-24(s0)
 458:	0007c783          	lbu	a5,0(a5)
 45c:	fc079ce3          	bnez	a5,434 <puts_wo_nl+0x38>
 460:	fe843703          	ld	a4,-24(s0)
 464:	fd043783          	ld	a5,-48(s0)
 468:	40f707b3          	sub	a5,a4,a5
 46c:	0007879b          	sext.w	a5,a5
 470:	00078513          	mv	a0,a5
 474:	02813083          	ld	ra,40(sp)
 478:	02013403          	ld	s0,32(sp)
 47c:	03010113          	addi	sp,sp,48
 480:	00008067          	ret

Disassembly of section .text.print_dec_int:

0000000000000484 <print_dec_int>:
 484:	f9010113          	addi	sp,sp,-112
 488:	06113423          	sd	ra,104(sp)
 48c:	06813023          	sd	s0,96(sp)
 490:	07010413          	addi	s0,sp,112
 494:	faa43423          	sd	a0,-88(s0)
 498:	fab43023          	sd	a1,-96(s0)
 49c:	00060793          	mv	a5,a2
 4a0:	f8d43823          	sd	a3,-112(s0)
 4a4:	f8f40fa3          	sb	a5,-97(s0)
 4a8:	f9f44783          	lbu	a5,-97(s0)
 4ac:	0ff7f793          	zext.b	a5,a5
 4b0:	02078863          	beqz	a5,4e0 <print_dec_int+0x5c>
 4b4:	fa043703          	ld	a4,-96(s0)
 4b8:	fff00793          	li	a5,-1
 4bc:	03f79793          	slli	a5,a5,0x3f
 4c0:	02f71063          	bne	a4,a5,4e0 <print_dec_int+0x5c>
 4c4:	00001597          	auipc	a1,0x1
 4c8:	d8458593          	addi	a1,a1,-636 # 1248 <printf+0x2b8>
 4cc:	fa843503          	ld	a0,-88(s0)
 4d0:	00000097          	auipc	ra,0x0
 4d4:	f2c080e7          	jalr	-212(ra) # 3fc <puts_wo_nl>
 4d8:	00050793          	mv	a5,a0
 4dc:	2a00006f          	j	77c <print_dec_int+0x2f8>
 4e0:	f9043783          	ld	a5,-112(s0)
 4e4:	00c7a783          	lw	a5,12(a5)
 4e8:	00079a63          	bnez	a5,4fc <print_dec_int+0x78>
 4ec:	fa043783          	ld	a5,-96(s0)
 4f0:	00079663          	bnez	a5,4fc <print_dec_int+0x78>
 4f4:	00000793          	li	a5,0
 4f8:	2840006f          	j	77c <print_dec_int+0x2f8>
 4fc:	fe0407a3          	sb	zero,-17(s0)
 500:	f9f44783          	lbu	a5,-97(s0)
 504:	0ff7f793          	zext.b	a5,a5
 508:	02078063          	beqz	a5,528 <print_dec_int+0xa4>
 50c:	fa043783          	ld	a5,-96(s0)
 510:	0007dc63          	bgez	a5,528 <print_dec_int+0xa4>
 514:	00100793          	li	a5,1
 518:	fef407a3          	sb	a5,-17(s0)
 51c:	fa043783          	ld	a5,-96(s0)
 520:	40f007b3          	neg	a5,a5
 524:	faf43023          	sd	a5,-96(s0)
 528:	fe042423          	sw	zero,-24(s0)
 52c:	f9f44783          	lbu	a5,-97(s0)
 530:	0ff7f793          	zext.b	a5,a5
 534:	02078863          	beqz	a5,564 <print_dec_int+0xe0>
 538:	fef44783          	lbu	a5,-17(s0)
 53c:	0ff7f793          	zext.b	a5,a5
 540:	00079e63          	bnez	a5,55c <print_dec_int+0xd8>
 544:	f9043783          	ld	a5,-112(s0)
 548:	0057c783          	lbu	a5,5(a5)
 54c:	00079863          	bnez	a5,55c <print_dec_int+0xd8>
 550:	f9043783          	ld	a5,-112(s0)
 554:	0047c783          	lbu	a5,4(a5)
 558:	00078663          	beqz	a5,564 <print_dec_int+0xe0>
 55c:	00100793          	li	a5,1
 560:	0080006f          	j	568 <print_dec_int+0xe4>
 564:	00000793          	li	a5,0
 568:	fcf40ba3          	sb	a5,-41(s0)
 56c:	fd744783          	lbu	a5,-41(s0)
 570:	0017f793          	andi	a5,a5,1
 574:	fcf40ba3          	sb	a5,-41(s0)
 578:	fa043703          	ld	a4,-96(s0)
 57c:	00a00793          	li	a5,10
 580:	02f777b3          	remu	a5,a4,a5
 584:	0ff7f713          	zext.b	a4,a5
 588:	fe842783          	lw	a5,-24(s0)
 58c:	0017869b          	addiw	a3,a5,1
 590:	fed42423          	sw	a3,-24(s0)
 594:	0307071b          	addiw	a4,a4,48
 598:	0ff77713          	zext.b	a4,a4
 59c:	ff078793          	addi	a5,a5,-16
 5a0:	008787b3          	add	a5,a5,s0
 5a4:	fce78423          	sb	a4,-56(a5)
 5a8:	fa043703          	ld	a4,-96(s0)
 5ac:	00a00793          	li	a5,10
 5b0:	02f757b3          	divu	a5,a4,a5
 5b4:	faf43023          	sd	a5,-96(s0)
 5b8:	fa043783          	ld	a5,-96(s0)
 5bc:	fa079ee3          	bnez	a5,578 <print_dec_int+0xf4>
 5c0:	f9043783          	ld	a5,-112(s0)
 5c4:	00c7a783          	lw	a5,12(a5)
 5c8:	00078713          	mv	a4,a5
 5cc:	fff00793          	li	a5,-1
 5d0:	02f71063          	bne	a4,a5,5f0 <print_dec_int+0x16c>
 5d4:	f9043783          	ld	a5,-112(s0)
 5d8:	0037c783          	lbu	a5,3(a5)
 5dc:	00078a63          	beqz	a5,5f0 <print_dec_int+0x16c>
 5e0:	f9043783          	ld	a5,-112(s0)
 5e4:	0087a703          	lw	a4,8(a5)
 5e8:	f9043783          	ld	a5,-112(s0)
 5ec:	00e7a623          	sw	a4,12(a5)
 5f0:	fe042223          	sw	zero,-28(s0)
 5f4:	f9043783          	ld	a5,-112(s0)
 5f8:	0087a703          	lw	a4,8(a5)
 5fc:	fe842783          	lw	a5,-24(s0)
 600:	fcf42823          	sw	a5,-48(s0)
 604:	f9043783          	ld	a5,-112(s0)
 608:	00c7a783          	lw	a5,12(a5)
 60c:	fcf42623          	sw	a5,-52(s0)
 610:	fd042783          	lw	a5,-48(s0)
 614:	00078593          	mv	a1,a5
 618:	fcc42783          	lw	a5,-52(s0)
 61c:	00078613          	mv	a2,a5
 620:	0006069b          	sext.w	a3,a2
 624:	0005879b          	sext.w	a5,a1
 628:	00f6d463          	bge	a3,a5,630 <print_dec_int+0x1ac>
 62c:	00058613          	mv	a2,a1
 630:	0006079b          	sext.w	a5,a2
 634:	40f707bb          	subw	a5,a4,a5
 638:	0007871b          	sext.w	a4,a5
 63c:	fd744783          	lbu	a5,-41(s0)
 640:	0007879b          	sext.w	a5,a5
 644:	40f707bb          	subw	a5,a4,a5
 648:	fef42023          	sw	a5,-32(s0)
 64c:	0280006f          	j	674 <print_dec_int+0x1f0>
 650:	fa843783          	ld	a5,-88(s0)
 654:	02000513          	li	a0,32
 658:	000780e7          	jalr	a5
 65c:	fe442783          	lw	a5,-28(s0)
 660:	0017879b          	addiw	a5,a5,1
 664:	fef42223          	sw	a5,-28(s0)
 668:	fe042783          	lw	a5,-32(s0)
 66c:	fff7879b          	addiw	a5,a5,-1
 670:	fef42023          	sw	a5,-32(s0)
 674:	fe042783          	lw	a5,-32(s0)
 678:	0007879b          	sext.w	a5,a5
 67c:	fcf04ae3          	bgtz	a5,650 <print_dec_int+0x1cc>
 680:	fd744783          	lbu	a5,-41(s0)
 684:	0ff7f793          	zext.b	a5,a5
 688:	04078463          	beqz	a5,6d0 <print_dec_int+0x24c>
 68c:	fef44783          	lbu	a5,-17(s0)
 690:	0ff7f793          	zext.b	a5,a5
 694:	00078663          	beqz	a5,6a0 <print_dec_int+0x21c>
 698:	02d00793          	li	a5,45
 69c:	01c0006f          	j	6b8 <print_dec_int+0x234>
 6a0:	f9043783          	ld	a5,-112(s0)
 6a4:	0057c783          	lbu	a5,5(a5)
 6a8:	00078663          	beqz	a5,6b4 <print_dec_int+0x230>
 6ac:	02b00793          	li	a5,43
 6b0:	0080006f          	j	6b8 <print_dec_int+0x234>
 6b4:	02000793          	li	a5,32
 6b8:	fa843703          	ld	a4,-88(s0)
 6bc:	00078513          	mv	a0,a5
 6c0:	000700e7          	jalr	a4
 6c4:	fe442783          	lw	a5,-28(s0)
 6c8:	0017879b          	addiw	a5,a5,1
 6cc:	fef42223          	sw	a5,-28(s0)
 6d0:	fe842783          	lw	a5,-24(s0)
 6d4:	fcf42e23          	sw	a5,-36(s0)
 6d8:	0280006f          	j	700 <print_dec_int+0x27c>
 6dc:	fa843783          	ld	a5,-88(s0)
 6e0:	03000513          	li	a0,48
 6e4:	000780e7          	jalr	a5
 6e8:	fe442783          	lw	a5,-28(s0)
 6ec:	0017879b          	addiw	a5,a5,1
 6f0:	fef42223          	sw	a5,-28(s0)
 6f4:	fdc42783          	lw	a5,-36(s0)
 6f8:	0017879b          	addiw	a5,a5,1
 6fc:	fcf42e23          	sw	a5,-36(s0)
 700:	f9043783          	ld	a5,-112(s0)
 704:	00c7a703          	lw	a4,12(a5)
 708:	fd744783          	lbu	a5,-41(s0)
 70c:	0007879b          	sext.w	a5,a5
 710:	40f707bb          	subw	a5,a4,a5
 714:	0007871b          	sext.w	a4,a5
 718:	fdc42783          	lw	a5,-36(s0)
 71c:	0007879b          	sext.w	a5,a5
 720:	fae7cee3          	blt	a5,a4,6dc <print_dec_int+0x258>
 724:	fe842783          	lw	a5,-24(s0)
 728:	fff7879b          	addiw	a5,a5,-1
 72c:	fcf42c23          	sw	a5,-40(s0)
 730:	03c0006f          	j	76c <print_dec_int+0x2e8>
 734:	fd842783          	lw	a5,-40(s0)
 738:	ff078793          	addi	a5,a5,-16
 73c:	008787b3          	add	a5,a5,s0
 740:	fc87c783          	lbu	a5,-56(a5)
 744:	0007871b          	sext.w	a4,a5
 748:	fa843783          	ld	a5,-88(s0)
 74c:	00070513          	mv	a0,a4
 750:	000780e7          	jalr	a5
 754:	fe442783          	lw	a5,-28(s0)
 758:	0017879b          	addiw	a5,a5,1
 75c:	fef42223          	sw	a5,-28(s0)
 760:	fd842783          	lw	a5,-40(s0)
 764:	fff7879b          	addiw	a5,a5,-1
 768:	fcf42c23          	sw	a5,-40(s0)
 76c:	fd842783          	lw	a5,-40(s0)
 770:	0007879b          	sext.w	a5,a5
 774:	fc07d0e3          	bgez	a5,734 <print_dec_int+0x2b0>
 778:	fe442783          	lw	a5,-28(s0)
 77c:	00078513          	mv	a0,a5
 780:	06813083          	ld	ra,104(sp)
 784:	06013403          	ld	s0,96(sp)
 788:	07010113          	addi	sp,sp,112
 78c:	00008067          	ret

Disassembly of section .text.vprintfmt:

0000000000000790 <vprintfmt>:
 790:	f4010113          	addi	sp,sp,-192
 794:	0a113c23          	sd	ra,184(sp)
 798:	0a813823          	sd	s0,176(sp)
 79c:	0c010413          	addi	s0,sp,192
 7a0:	f4a43c23          	sd	a0,-168(s0)
 7a4:	f4b43823          	sd	a1,-176(s0)
 7a8:	f4c43423          	sd	a2,-184(s0)
 7ac:	f8043023          	sd	zero,-128(s0)
 7b0:	f8043423          	sd	zero,-120(s0)
 7b4:	fe042623          	sw	zero,-20(s0)
 7b8:	7b40006f          	j	f6c <vprintfmt+0x7dc>
 7bc:	f8044783          	lbu	a5,-128(s0)
 7c0:	74078663          	beqz	a5,f0c <vprintfmt+0x77c>
 7c4:	f5043783          	ld	a5,-176(s0)
 7c8:	0007c783          	lbu	a5,0(a5)
 7cc:	00078713          	mv	a4,a5
 7d0:	02300793          	li	a5,35
 7d4:	00f71863          	bne	a4,a5,7e4 <vprintfmt+0x54>
 7d8:	00100793          	li	a5,1
 7dc:	f8f40123          	sb	a5,-126(s0)
 7e0:	7800006f          	j	f60 <vprintfmt+0x7d0>
 7e4:	f5043783          	ld	a5,-176(s0)
 7e8:	0007c783          	lbu	a5,0(a5)
 7ec:	00078713          	mv	a4,a5
 7f0:	03000793          	li	a5,48
 7f4:	00f71863          	bne	a4,a5,804 <vprintfmt+0x74>
 7f8:	00100793          	li	a5,1
 7fc:	f8f401a3          	sb	a5,-125(s0)
 800:	7600006f          	j	f60 <vprintfmt+0x7d0>
 804:	f5043783          	ld	a5,-176(s0)
 808:	0007c783          	lbu	a5,0(a5)
 80c:	00078713          	mv	a4,a5
 810:	06c00793          	li	a5,108
 814:	04f70063          	beq	a4,a5,854 <vprintfmt+0xc4>
 818:	f5043783          	ld	a5,-176(s0)
 81c:	0007c783          	lbu	a5,0(a5)
 820:	00078713          	mv	a4,a5
 824:	07a00793          	li	a5,122
 828:	02f70663          	beq	a4,a5,854 <vprintfmt+0xc4>
 82c:	f5043783          	ld	a5,-176(s0)
 830:	0007c783          	lbu	a5,0(a5)
 834:	00078713          	mv	a4,a5
 838:	07400793          	li	a5,116
 83c:	00f70c63          	beq	a4,a5,854 <vprintfmt+0xc4>
 840:	f5043783          	ld	a5,-176(s0)
 844:	0007c783          	lbu	a5,0(a5)
 848:	00078713          	mv	a4,a5
 84c:	06a00793          	li	a5,106
 850:	00f71863          	bne	a4,a5,860 <vprintfmt+0xd0>
 854:	00100793          	li	a5,1
 858:	f8f400a3          	sb	a5,-127(s0)
 85c:	7040006f          	j	f60 <vprintfmt+0x7d0>
 860:	f5043783          	ld	a5,-176(s0)
 864:	0007c783          	lbu	a5,0(a5)
 868:	00078713          	mv	a4,a5
 86c:	02b00793          	li	a5,43
 870:	00f71863          	bne	a4,a5,880 <vprintfmt+0xf0>
 874:	00100793          	li	a5,1
 878:	f8f402a3          	sb	a5,-123(s0)
 87c:	6e40006f          	j	f60 <vprintfmt+0x7d0>
 880:	f5043783          	ld	a5,-176(s0)
 884:	0007c783          	lbu	a5,0(a5)
 888:	00078713          	mv	a4,a5
 88c:	02000793          	li	a5,32
 890:	00f71863          	bne	a4,a5,8a0 <vprintfmt+0x110>
 894:	00100793          	li	a5,1
 898:	f8f40223          	sb	a5,-124(s0)
 89c:	6c40006f          	j	f60 <vprintfmt+0x7d0>
 8a0:	f5043783          	ld	a5,-176(s0)
 8a4:	0007c783          	lbu	a5,0(a5)
 8a8:	00078713          	mv	a4,a5
 8ac:	02a00793          	li	a5,42
 8b0:	00f71e63          	bne	a4,a5,8cc <vprintfmt+0x13c>
 8b4:	f4843783          	ld	a5,-184(s0)
 8b8:	00878713          	addi	a4,a5,8
 8bc:	f4e43423          	sd	a4,-184(s0)
 8c0:	0007a783          	lw	a5,0(a5)
 8c4:	f8f42423          	sw	a5,-120(s0)
 8c8:	6980006f          	j	f60 <vprintfmt+0x7d0>
 8cc:	f5043783          	ld	a5,-176(s0)
 8d0:	0007c783          	lbu	a5,0(a5)
 8d4:	00078713          	mv	a4,a5
 8d8:	03000793          	li	a5,48
 8dc:	04e7f863          	bgeu	a5,a4,92c <vprintfmt+0x19c>
 8e0:	f5043783          	ld	a5,-176(s0)
 8e4:	0007c783          	lbu	a5,0(a5)
 8e8:	00078713          	mv	a4,a5
 8ec:	03900793          	li	a5,57
 8f0:	02e7ee63          	bltu	a5,a4,92c <vprintfmt+0x19c>
 8f4:	f5043783          	ld	a5,-176(s0)
 8f8:	f5040713          	addi	a4,s0,-176
 8fc:	00a00613          	li	a2,10
 900:	00070593          	mv	a1,a4
 904:	00078513          	mv	a0,a5
 908:	00000097          	auipc	ra,0x0
 90c:	884080e7          	jalr	-1916(ra) # 18c <strtol>
 910:	00050793          	mv	a5,a0
 914:	0007879b          	sext.w	a5,a5
 918:	f8f42423          	sw	a5,-120(s0)
 91c:	f5043783          	ld	a5,-176(s0)
 920:	fff78793          	addi	a5,a5,-1
 924:	f4f43823          	sd	a5,-176(s0)
 928:	6380006f          	j	f60 <vprintfmt+0x7d0>
 92c:	f5043783          	ld	a5,-176(s0)
 930:	0007c783          	lbu	a5,0(a5)
 934:	00078713          	mv	a4,a5
 938:	02e00793          	li	a5,46
 93c:	06f71a63          	bne	a4,a5,9b0 <vprintfmt+0x220>
 940:	f5043783          	ld	a5,-176(s0)
 944:	00178793          	addi	a5,a5,1
 948:	f4f43823          	sd	a5,-176(s0)
 94c:	f5043783          	ld	a5,-176(s0)
 950:	0007c783          	lbu	a5,0(a5)
 954:	00078713          	mv	a4,a5
 958:	02a00793          	li	a5,42
 95c:	00f71e63          	bne	a4,a5,978 <vprintfmt+0x1e8>
 960:	f4843783          	ld	a5,-184(s0)
 964:	00878713          	addi	a4,a5,8
 968:	f4e43423          	sd	a4,-184(s0)
 96c:	0007a783          	lw	a5,0(a5)
 970:	f8f42623          	sw	a5,-116(s0)
 974:	5ec0006f          	j	f60 <vprintfmt+0x7d0>
 978:	f5043783          	ld	a5,-176(s0)
 97c:	f5040713          	addi	a4,s0,-176
 980:	00a00613          	li	a2,10
 984:	00070593          	mv	a1,a4
 988:	00078513          	mv	a0,a5
 98c:	00000097          	auipc	ra,0x0
 990:	800080e7          	jalr	-2048(ra) # 18c <strtol>
 994:	00050793          	mv	a5,a0
 998:	0007879b          	sext.w	a5,a5
 99c:	f8f42623          	sw	a5,-116(s0)
 9a0:	f5043783          	ld	a5,-176(s0)
 9a4:	fff78793          	addi	a5,a5,-1
 9a8:	f4f43823          	sd	a5,-176(s0)
 9ac:	5b40006f          	j	f60 <vprintfmt+0x7d0>
 9b0:	f5043783          	ld	a5,-176(s0)
 9b4:	0007c783          	lbu	a5,0(a5)
 9b8:	00078713          	mv	a4,a5
 9bc:	07800793          	li	a5,120
 9c0:	02f70663          	beq	a4,a5,9ec <vprintfmt+0x25c>
 9c4:	f5043783          	ld	a5,-176(s0)
 9c8:	0007c783          	lbu	a5,0(a5)
 9cc:	00078713          	mv	a4,a5
 9d0:	05800793          	li	a5,88
 9d4:	00f70c63          	beq	a4,a5,9ec <vprintfmt+0x25c>
 9d8:	f5043783          	ld	a5,-176(s0)
 9dc:	0007c783          	lbu	a5,0(a5)
 9e0:	00078713          	mv	a4,a5
 9e4:	07000793          	li	a5,112
 9e8:	30f71263          	bne	a4,a5,cec <vprintfmt+0x55c>
 9ec:	f5043783          	ld	a5,-176(s0)
 9f0:	0007c783          	lbu	a5,0(a5)
 9f4:	00078713          	mv	a4,a5
 9f8:	07000793          	li	a5,112
 9fc:	00f70663          	beq	a4,a5,a08 <vprintfmt+0x278>
 a00:	f8144783          	lbu	a5,-127(s0)
 a04:	00078663          	beqz	a5,a10 <vprintfmt+0x280>
 a08:	00100793          	li	a5,1
 a0c:	0080006f          	j	a14 <vprintfmt+0x284>
 a10:	00000793          	li	a5,0
 a14:	faf403a3          	sb	a5,-89(s0)
 a18:	fa744783          	lbu	a5,-89(s0)
 a1c:	0017f793          	andi	a5,a5,1
 a20:	faf403a3          	sb	a5,-89(s0)
 a24:	fa744783          	lbu	a5,-89(s0)
 a28:	0ff7f793          	zext.b	a5,a5
 a2c:	00078c63          	beqz	a5,a44 <vprintfmt+0x2b4>
 a30:	f4843783          	ld	a5,-184(s0)
 a34:	00878713          	addi	a4,a5,8
 a38:	f4e43423          	sd	a4,-184(s0)
 a3c:	0007b783          	ld	a5,0(a5)
 a40:	01c0006f          	j	a5c <vprintfmt+0x2cc>
 a44:	f4843783          	ld	a5,-184(s0)
 a48:	00878713          	addi	a4,a5,8
 a4c:	f4e43423          	sd	a4,-184(s0)
 a50:	0007a783          	lw	a5,0(a5)
 a54:	02079793          	slli	a5,a5,0x20
 a58:	0207d793          	srli	a5,a5,0x20
 a5c:	fef43023          	sd	a5,-32(s0)
 a60:	f8c42783          	lw	a5,-116(s0)
 a64:	02079463          	bnez	a5,a8c <vprintfmt+0x2fc>
 a68:	fe043783          	ld	a5,-32(s0)
 a6c:	02079063          	bnez	a5,a8c <vprintfmt+0x2fc>
 a70:	f5043783          	ld	a5,-176(s0)
 a74:	0007c783          	lbu	a5,0(a5)
 a78:	00078713          	mv	a4,a5
 a7c:	07000793          	li	a5,112
 a80:	00f70663          	beq	a4,a5,a8c <vprintfmt+0x2fc>
 a84:	f8040023          	sb	zero,-128(s0)
 a88:	4d80006f          	j	f60 <vprintfmt+0x7d0>
 a8c:	f5043783          	ld	a5,-176(s0)
 a90:	0007c783          	lbu	a5,0(a5)
 a94:	00078713          	mv	a4,a5
 a98:	07000793          	li	a5,112
 a9c:	00f70a63          	beq	a4,a5,ab0 <vprintfmt+0x320>
 aa0:	f8244783          	lbu	a5,-126(s0)
 aa4:	00078a63          	beqz	a5,ab8 <vprintfmt+0x328>
 aa8:	fe043783          	ld	a5,-32(s0)
 aac:	00078663          	beqz	a5,ab8 <vprintfmt+0x328>
 ab0:	00100793          	li	a5,1
 ab4:	0080006f          	j	abc <vprintfmt+0x32c>
 ab8:	00000793          	li	a5,0
 abc:	faf40323          	sb	a5,-90(s0)
 ac0:	fa644783          	lbu	a5,-90(s0)
 ac4:	0017f793          	andi	a5,a5,1
 ac8:	faf40323          	sb	a5,-90(s0)
 acc:	fc042e23          	sw	zero,-36(s0)
 ad0:	f5043783          	ld	a5,-176(s0)
 ad4:	0007c783          	lbu	a5,0(a5)
 ad8:	00078713          	mv	a4,a5
 adc:	05800793          	li	a5,88
 ae0:	00f71863          	bne	a4,a5,af0 <vprintfmt+0x360>
 ae4:	00000797          	auipc	a5,0x0
 ae8:	77c78793          	addi	a5,a5,1916 # 1260 <upperxdigits.1>
 aec:	00c0006f          	j	af8 <vprintfmt+0x368>
 af0:	00000797          	auipc	a5,0x0
 af4:	78878793          	addi	a5,a5,1928 # 1278 <lowerxdigits.0>
 af8:	f8f43c23          	sd	a5,-104(s0)
 afc:	fe043783          	ld	a5,-32(s0)
 b00:	00f7f793          	andi	a5,a5,15
 b04:	f9843703          	ld	a4,-104(s0)
 b08:	00f70733          	add	a4,a4,a5
 b0c:	fdc42783          	lw	a5,-36(s0)
 b10:	0017869b          	addiw	a3,a5,1
 b14:	fcd42e23          	sw	a3,-36(s0)
 b18:	00074703          	lbu	a4,0(a4)
 b1c:	ff078793          	addi	a5,a5,-16
 b20:	008787b3          	add	a5,a5,s0
 b24:	f8e78023          	sb	a4,-128(a5)
 b28:	fe043783          	ld	a5,-32(s0)
 b2c:	0047d793          	srli	a5,a5,0x4
 b30:	fef43023          	sd	a5,-32(s0)
 b34:	fe043783          	ld	a5,-32(s0)
 b38:	fc0792e3          	bnez	a5,afc <vprintfmt+0x36c>
 b3c:	f8c42783          	lw	a5,-116(s0)
 b40:	00078713          	mv	a4,a5
 b44:	fff00793          	li	a5,-1
 b48:	02f71663          	bne	a4,a5,b74 <vprintfmt+0x3e4>
 b4c:	f8344783          	lbu	a5,-125(s0)
 b50:	02078263          	beqz	a5,b74 <vprintfmt+0x3e4>
 b54:	f8842703          	lw	a4,-120(s0)
 b58:	fa644783          	lbu	a5,-90(s0)
 b5c:	0007879b          	sext.w	a5,a5
 b60:	0017979b          	slliw	a5,a5,0x1
 b64:	0007879b          	sext.w	a5,a5
 b68:	40f707bb          	subw	a5,a4,a5
 b6c:	0007879b          	sext.w	a5,a5
 b70:	f8f42623          	sw	a5,-116(s0)
 b74:	f8842703          	lw	a4,-120(s0)
 b78:	fa644783          	lbu	a5,-90(s0)
 b7c:	0007879b          	sext.w	a5,a5
 b80:	0017979b          	slliw	a5,a5,0x1
 b84:	0007879b          	sext.w	a5,a5
 b88:	40f707bb          	subw	a5,a4,a5
 b8c:	0007871b          	sext.w	a4,a5
 b90:	fdc42783          	lw	a5,-36(s0)
 b94:	f8f42a23          	sw	a5,-108(s0)
 b98:	f8c42783          	lw	a5,-116(s0)
 b9c:	f8f42823          	sw	a5,-112(s0)
 ba0:	f9442783          	lw	a5,-108(s0)
 ba4:	00078593          	mv	a1,a5
 ba8:	f9042783          	lw	a5,-112(s0)
 bac:	00078613          	mv	a2,a5
 bb0:	0006069b          	sext.w	a3,a2
 bb4:	0005879b          	sext.w	a5,a1
 bb8:	00f6d463          	bge	a3,a5,bc0 <vprintfmt+0x430>
 bbc:	00058613          	mv	a2,a1
 bc0:	0006079b          	sext.w	a5,a2
 bc4:	40f707bb          	subw	a5,a4,a5
 bc8:	fcf42c23          	sw	a5,-40(s0)
 bcc:	0280006f          	j	bf4 <vprintfmt+0x464>
 bd0:	f5843783          	ld	a5,-168(s0)
 bd4:	02000513          	li	a0,32
 bd8:	000780e7          	jalr	a5
 bdc:	fec42783          	lw	a5,-20(s0)
 be0:	0017879b          	addiw	a5,a5,1
 be4:	fef42623          	sw	a5,-20(s0)
 be8:	fd842783          	lw	a5,-40(s0)
 bec:	fff7879b          	addiw	a5,a5,-1
 bf0:	fcf42c23          	sw	a5,-40(s0)
 bf4:	fd842783          	lw	a5,-40(s0)
 bf8:	0007879b          	sext.w	a5,a5
 bfc:	fcf04ae3          	bgtz	a5,bd0 <vprintfmt+0x440>
 c00:	fa644783          	lbu	a5,-90(s0)
 c04:	0ff7f793          	zext.b	a5,a5
 c08:	04078463          	beqz	a5,c50 <vprintfmt+0x4c0>
 c0c:	f5843783          	ld	a5,-168(s0)
 c10:	03000513          	li	a0,48
 c14:	000780e7          	jalr	a5
 c18:	f5043783          	ld	a5,-176(s0)
 c1c:	0007c783          	lbu	a5,0(a5)
 c20:	00078713          	mv	a4,a5
 c24:	05800793          	li	a5,88
 c28:	00f71663          	bne	a4,a5,c34 <vprintfmt+0x4a4>
 c2c:	05800793          	li	a5,88
 c30:	0080006f          	j	c38 <vprintfmt+0x4a8>
 c34:	07800793          	li	a5,120
 c38:	f5843703          	ld	a4,-168(s0)
 c3c:	00078513          	mv	a0,a5
 c40:	000700e7          	jalr	a4
 c44:	fec42783          	lw	a5,-20(s0)
 c48:	0027879b          	addiw	a5,a5,2
 c4c:	fef42623          	sw	a5,-20(s0)
 c50:	fdc42783          	lw	a5,-36(s0)
 c54:	fcf42a23          	sw	a5,-44(s0)
 c58:	0280006f          	j	c80 <vprintfmt+0x4f0>
 c5c:	f5843783          	ld	a5,-168(s0)
 c60:	03000513          	li	a0,48
 c64:	000780e7          	jalr	a5
 c68:	fec42783          	lw	a5,-20(s0)
 c6c:	0017879b          	addiw	a5,a5,1
 c70:	fef42623          	sw	a5,-20(s0)
 c74:	fd442783          	lw	a5,-44(s0)
 c78:	0017879b          	addiw	a5,a5,1
 c7c:	fcf42a23          	sw	a5,-44(s0)
 c80:	f8c42703          	lw	a4,-116(s0)
 c84:	fd442783          	lw	a5,-44(s0)
 c88:	0007879b          	sext.w	a5,a5
 c8c:	fce7c8e3          	blt	a5,a4,c5c <vprintfmt+0x4cc>
 c90:	fdc42783          	lw	a5,-36(s0)
 c94:	fff7879b          	addiw	a5,a5,-1
 c98:	fcf42823          	sw	a5,-48(s0)
 c9c:	03c0006f          	j	cd8 <vprintfmt+0x548>
 ca0:	fd042783          	lw	a5,-48(s0)
 ca4:	ff078793          	addi	a5,a5,-16
 ca8:	008787b3          	add	a5,a5,s0
 cac:	f807c783          	lbu	a5,-128(a5)
 cb0:	0007871b          	sext.w	a4,a5
 cb4:	f5843783          	ld	a5,-168(s0)
 cb8:	00070513          	mv	a0,a4
 cbc:	000780e7          	jalr	a5
 cc0:	fec42783          	lw	a5,-20(s0)
 cc4:	0017879b          	addiw	a5,a5,1
 cc8:	fef42623          	sw	a5,-20(s0)
 ccc:	fd042783          	lw	a5,-48(s0)
 cd0:	fff7879b          	addiw	a5,a5,-1
 cd4:	fcf42823          	sw	a5,-48(s0)
 cd8:	fd042783          	lw	a5,-48(s0)
 cdc:	0007879b          	sext.w	a5,a5
 ce0:	fc07d0e3          	bgez	a5,ca0 <vprintfmt+0x510>
 ce4:	f8040023          	sb	zero,-128(s0)
 ce8:	2780006f          	j	f60 <vprintfmt+0x7d0>
 cec:	f5043783          	ld	a5,-176(s0)
 cf0:	0007c783          	lbu	a5,0(a5)
 cf4:	00078713          	mv	a4,a5
 cf8:	06400793          	li	a5,100
 cfc:	02f70663          	beq	a4,a5,d28 <vprintfmt+0x598>
 d00:	f5043783          	ld	a5,-176(s0)
 d04:	0007c783          	lbu	a5,0(a5)
 d08:	00078713          	mv	a4,a5
 d0c:	06900793          	li	a5,105
 d10:	00f70c63          	beq	a4,a5,d28 <vprintfmt+0x598>
 d14:	f5043783          	ld	a5,-176(s0)
 d18:	0007c783          	lbu	a5,0(a5)
 d1c:	00078713          	mv	a4,a5
 d20:	07500793          	li	a5,117
 d24:	08f71263          	bne	a4,a5,da8 <vprintfmt+0x618>
 d28:	f8144783          	lbu	a5,-127(s0)
 d2c:	00078c63          	beqz	a5,d44 <vprintfmt+0x5b4>
 d30:	f4843783          	ld	a5,-184(s0)
 d34:	00878713          	addi	a4,a5,8
 d38:	f4e43423          	sd	a4,-184(s0)
 d3c:	0007b783          	ld	a5,0(a5)
 d40:	0140006f          	j	d54 <vprintfmt+0x5c4>
 d44:	f4843783          	ld	a5,-184(s0)
 d48:	00878713          	addi	a4,a5,8
 d4c:	f4e43423          	sd	a4,-184(s0)
 d50:	0007a783          	lw	a5,0(a5)
 d54:	faf43423          	sd	a5,-88(s0)
 d58:	fa843583          	ld	a1,-88(s0)
 d5c:	f5043783          	ld	a5,-176(s0)
 d60:	0007c783          	lbu	a5,0(a5)
 d64:	0007871b          	sext.w	a4,a5
 d68:	07500793          	li	a5,117
 d6c:	40f707b3          	sub	a5,a4,a5
 d70:	00f037b3          	snez	a5,a5
 d74:	0ff7f793          	zext.b	a5,a5
 d78:	f8040713          	addi	a4,s0,-128
 d7c:	00070693          	mv	a3,a4
 d80:	00078613          	mv	a2,a5
 d84:	f5843503          	ld	a0,-168(s0)
 d88:	fffff097          	auipc	ra,0xfffff
 d8c:	6fc080e7          	jalr	1788(ra) # 484 <print_dec_int>
 d90:	00050793          	mv	a5,a0
 d94:	fec42703          	lw	a4,-20(s0)
 d98:	00f707bb          	addw	a5,a4,a5
 d9c:	fef42623          	sw	a5,-20(s0)
 da0:	f8040023          	sb	zero,-128(s0)
 da4:	1bc0006f          	j	f60 <vprintfmt+0x7d0>
 da8:	f5043783          	ld	a5,-176(s0)
 dac:	0007c783          	lbu	a5,0(a5)
 db0:	00078713          	mv	a4,a5
 db4:	06e00793          	li	a5,110
 db8:	04f71c63          	bne	a4,a5,e10 <vprintfmt+0x680>
 dbc:	f8144783          	lbu	a5,-127(s0)
 dc0:	02078463          	beqz	a5,de8 <vprintfmt+0x658>
 dc4:	f4843783          	ld	a5,-184(s0)
 dc8:	00878713          	addi	a4,a5,8
 dcc:	f4e43423          	sd	a4,-184(s0)
 dd0:	0007b783          	ld	a5,0(a5)
 dd4:	faf43823          	sd	a5,-80(s0)
 dd8:	fec42703          	lw	a4,-20(s0)
 ddc:	fb043783          	ld	a5,-80(s0)
 de0:	00e7b023          	sd	a4,0(a5)
 de4:	0240006f          	j	e08 <vprintfmt+0x678>
 de8:	f4843783          	ld	a5,-184(s0)
 dec:	00878713          	addi	a4,a5,8
 df0:	f4e43423          	sd	a4,-184(s0)
 df4:	0007b783          	ld	a5,0(a5)
 df8:	faf43c23          	sd	a5,-72(s0)
 dfc:	fb843783          	ld	a5,-72(s0)
 e00:	fec42703          	lw	a4,-20(s0)
 e04:	00e7a023          	sw	a4,0(a5)
 e08:	f8040023          	sb	zero,-128(s0)
 e0c:	1540006f          	j	f60 <vprintfmt+0x7d0>
 e10:	f5043783          	ld	a5,-176(s0)
 e14:	0007c783          	lbu	a5,0(a5)
 e18:	00078713          	mv	a4,a5
 e1c:	07300793          	li	a5,115
 e20:	04f71063          	bne	a4,a5,e60 <vprintfmt+0x6d0>
 e24:	f4843783          	ld	a5,-184(s0)
 e28:	00878713          	addi	a4,a5,8
 e2c:	f4e43423          	sd	a4,-184(s0)
 e30:	0007b783          	ld	a5,0(a5)
 e34:	fcf43023          	sd	a5,-64(s0)
 e38:	fc043583          	ld	a1,-64(s0)
 e3c:	f5843503          	ld	a0,-168(s0)
 e40:	fffff097          	auipc	ra,0xfffff
 e44:	5bc080e7          	jalr	1468(ra) # 3fc <puts_wo_nl>
 e48:	00050793          	mv	a5,a0
 e4c:	fec42703          	lw	a4,-20(s0)
 e50:	00f707bb          	addw	a5,a4,a5
 e54:	fef42623          	sw	a5,-20(s0)
 e58:	f8040023          	sb	zero,-128(s0)
 e5c:	1040006f          	j	f60 <vprintfmt+0x7d0>
 e60:	f5043783          	ld	a5,-176(s0)
 e64:	0007c783          	lbu	a5,0(a5)
 e68:	00078713          	mv	a4,a5
 e6c:	06300793          	li	a5,99
 e70:	02f71e63          	bne	a4,a5,eac <vprintfmt+0x71c>
 e74:	f4843783          	ld	a5,-184(s0)
 e78:	00878713          	addi	a4,a5,8
 e7c:	f4e43423          	sd	a4,-184(s0)
 e80:	0007a783          	lw	a5,0(a5)
 e84:	fcf42623          	sw	a5,-52(s0)
 e88:	fcc42703          	lw	a4,-52(s0)
 e8c:	f5843783          	ld	a5,-168(s0)
 e90:	00070513          	mv	a0,a4
 e94:	000780e7          	jalr	a5
 e98:	fec42783          	lw	a5,-20(s0)
 e9c:	0017879b          	addiw	a5,a5,1
 ea0:	fef42623          	sw	a5,-20(s0)
 ea4:	f8040023          	sb	zero,-128(s0)
 ea8:	0b80006f          	j	f60 <vprintfmt+0x7d0>
 eac:	f5043783          	ld	a5,-176(s0)
 eb0:	0007c783          	lbu	a5,0(a5)
 eb4:	00078713          	mv	a4,a5
 eb8:	02500793          	li	a5,37
 ebc:	02f71263          	bne	a4,a5,ee0 <vprintfmt+0x750>
 ec0:	f5843783          	ld	a5,-168(s0)
 ec4:	02500513          	li	a0,37
 ec8:	000780e7          	jalr	a5
 ecc:	fec42783          	lw	a5,-20(s0)
 ed0:	0017879b          	addiw	a5,a5,1
 ed4:	fef42623          	sw	a5,-20(s0)
 ed8:	f8040023          	sb	zero,-128(s0)
 edc:	0840006f          	j	f60 <vprintfmt+0x7d0>
 ee0:	f5043783          	ld	a5,-176(s0)
 ee4:	0007c783          	lbu	a5,0(a5)
 ee8:	0007871b          	sext.w	a4,a5
 eec:	f5843783          	ld	a5,-168(s0)
 ef0:	00070513          	mv	a0,a4
 ef4:	000780e7          	jalr	a5
 ef8:	fec42783          	lw	a5,-20(s0)
 efc:	0017879b          	addiw	a5,a5,1
 f00:	fef42623          	sw	a5,-20(s0)
 f04:	f8040023          	sb	zero,-128(s0)
 f08:	0580006f          	j	f60 <vprintfmt+0x7d0>
 f0c:	f5043783          	ld	a5,-176(s0)
 f10:	0007c783          	lbu	a5,0(a5)
 f14:	00078713          	mv	a4,a5
 f18:	02500793          	li	a5,37
 f1c:	02f71063          	bne	a4,a5,f3c <vprintfmt+0x7ac>
 f20:	f8043023          	sd	zero,-128(s0)
 f24:	f8043423          	sd	zero,-120(s0)
 f28:	00100793          	li	a5,1
 f2c:	f8f40023          	sb	a5,-128(s0)
 f30:	fff00793          	li	a5,-1
 f34:	f8f42623          	sw	a5,-116(s0)
 f38:	0280006f          	j	f60 <vprintfmt+0x7d0>
 f3c:	f5043783          	ld	a5,-176(s0)
 f40:	0007c783          	lbu	a5,0(a5)
 f44:	0007871b          	sext.w	a4,a5
 f48:	f5843783          	ld	a5,-168(s0)
 f4c:	00070513          	mv	a0,a4
 f50:	000780e7          	jalr	a5
 f54:	fec42783          	lw	a5,-20(s0)
 f58:	0017879b          	addiw	a5,a5,1
 f5c:	fef42623          	sw	a5,-20(s0)
 f60:	f5043783          	ld	a5,-176(s0)
 f64:	00178793          	addi	a5,a5,1
 f68:	f4f43823          	sd	a5,-176(s0)
 f6c:	f5043783          	ld	a5,-176(s0)
 f70:	0007c783          	lbu	a5,0(a5)
 f74:	840794e3          	bnez	a5,7bc <vprintfmt+0x2c>
 f78:	fec42783          	lw	a5,-20(s0)
 f7c:	00078513          	mv	a0,a5
 f80:	0b813083          	ld	ra,184(sp)
 f84:	0b013403          	ld	s0,176(sp)
 f88:	0c010113          	addi	sp,sp,192
 f8c:	00008067          	ret

Disassembly of section .text.printf:

0000000000000f90 <printf>:
     f90:	f8010113          	addi	sp,sp,-128
     f94:	02113c23          	sd	ra,56(sp)
     f98:	02813823          	sd	s0,48(sp)
     f9c:	04010413          	addi	s0,sp,64
     fa0:	fca43423          	sd	a0,-56(s0)
     fa4:	00b43423          	sd	a1,8(s0)
     fa8:	00c43823          	sd	a2,16(s0)
     fac:	00d43c23          	sd	a3,24(s0)
     fb0:	02e43023          	sd	a4,32(s0)
     fb4:	02f43423          	sd	a5,40(s0)
     fb8:	03043823          	sd	a6,48(s0)
     fbc:	03143c23          	sd	a7,56(s0)
     fc0:	fe042623          	sw	zero,-20(s0)
     fc4:	04040793          	addi	a5,s0,64
     fc8:	fcf43023          	sd	a5,-64(s0)
     fcc:	fc043783          	ld	a5,-64(s0)
     fd0:	fc878793          	addi	a5,a5,-56
     fd4:	fcf43823          	sd	a5,-48(s0)
     fd8:	fd043783          	ld	a5,-48(s0)
     fdc:	00078613          	mv	a2,a5
     fe0:	fc843583          	ld	a1,-56(s0)
     fe4:	fffff517          	auipc	a0,0xfffff
     fe8:	0e050513          	addi	a0,a0,224 # c4 <putc>
     fec:	fffff097          	auipc	ra,0xfffff
     ff0:	7a4080e7          	jalr	1956(ra) # 790 <vprintfmt>
     ff4:	00050793          	mv	a5,a0
     ff8:	fef42623          	sw	a5,-20(s0)
     ffc:	00100793          	li	a5,1
    1000:	fef43023          	sd	a5,-32(s0)
    1004:	00000797          	auipc	a5,0x0
    1008:	28c78793          	addi	a5,a5,652 # 1290 <tail>
    100c:	0007a783          	lw	a5,0(a5)
    1010:	0017871b          	addiw	a4,a5,1
    1014:	0007069b          	sext.w	a3,a4
    1018:	00000717          	auipc	a4,0x0
    101c:	27870713          	addi	a4,a4,632 # 1290 <tail>
    1020:	00d72023          	sw	a3,0(a4)
    1024:	00000717          	auipc	a4,0x0
    1028:	27470713          	addi	a4,a4,628 # 1298 <buffer>
    102c:	00f707b3          	add	a5,a4,a5
    1030:	00078023          	sb	zero,0(a5)
    1034:	00000797          	auipc	a5,0x0
    1038:	25c78793          	addi	a5,a5,604 # 1290 <tail>
    103c:	0007a603          	lw	a2,0(a5)
    1040:	fe043703          	ld	a4,-32(s0)
    1044:	00000697          	auipc	a3,0x0
    1048:	25468693          	addi	a3,a3,596 # 1298 <buffer>
    104c:	fd843783          	ld	a5,-40(s0)
    1050:	04000893          	li	a7,64
    1054:	00070513          	mv	a0,a4
    1058:	00068593          	mv	a1,a3
    105c:	00060613          	mv	a2,a2
    1060:	00000073          	ecall
    1064:	00050793          	mv	a5,a0
    1068:	fcf43c23          	sd	a5,-40(s0)
    106c:	00000797          	auipc	a5,0x0
    1070:	22478793          	addi	a5,a5,548 # 1290 <tail>
    1074:	0007a023          	sw	zero,0(a5)
    1078:	fec42783          	lw	a5,-20(s0)
    107c:	00078513          	mv	a0,a5
    1080:	03813083          	ld	ra,56(sp)
    1084:	03013403          	ld	s0,48(sp)
    1088:	08010113          	addi	sp,sp,128
    108c:	00008067          	ret
