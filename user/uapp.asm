
uapp:     file format elf64-littleriscv


Disassembly of section .text:

00000000000100e8 <_start>:
   100e8:	0380006f          	j	10120 <main>

00000000000100ec <getpid>:
   100ec:	fe010113          	addi	sp,sp,-32
   100f0:	00813c23          	sd	s0,24(sp)
   100f4:	02010413          	addi	s0,sp,32
   100f8:	fe843783          	ld	a5,-24(s0)
   100fc:	0ac00893          	li	a7,172
   10100:	00000073          	ecall
   10104:	00050793          	mv	a5,a0
   10108:	fef43423          	sd	a5,-24(s0)
   1010c:	fe843783          	ld	a5,-24(s0)
   10110:	00078513          	mv	a0,a5
   10114:	01813403          	ld	s0,24(sp)
   10118:	02010113          	addi	sp,sp,32
   1011c:	00008067          	ret

0000000000010120 <main>:
   10120:	fe010113          	addi	sp,sp,-32
   10124:	00113c23          	sd	ra,24(sp)
   10128:	00813823          	sd	s0,16(sp)
   1012c:	02010413          	addi	s0,sp,32
   10130:	00000097          	auipc	ra,0x0
   10134:	fbc080e7          	jalr	-68(ra) # 100ec <getpid>
   10138:	00050593          	mv	a1,a0
   1013c:	00010613          	mv	a2,sp
   10140:	00002797          	auipc	a5,0x2
   10144:	ec078793          	addi	a5,a5,-320 # 12000 <counter>
   10148:	0007a783          	lw	a5,0(a5)
   1014c:	0017879b          	addiw	a5,a5,1
   10150:	0007871b          	sext.w	a4,a5
   10154:	00002797          	auipc	a5,0x2
   10158:	eac78793          	addi	a5,a5,-340 # 12000 <counter>
   1015c:	00e7a023          	sw	a4,0(a5)
   10160:	00002797          	auipc	a5,0x2
   10164:	ea078793          	addi	a5,a5,-352 # 12000 <counter>
   10168:	0007a783          	lw	a5,0(a5)
   1016c:	00078693          	mv	a3,a5
   10170:	00001517          	auipc	a0,0x1
   10174:	00850513          	addi	a0,a0,8 # 11178 <printf+0x100>
   10178:	00001097          	auipc	ra,0x1
   1017c:	f00080e7          	jalr	-256(ra) # 11078 <printf>
   10180:	fe042623          	sw	zero,-20(s0)
   10184:	0100006f          	j	10194 <main+0x74>
   10188:	fec42783          	lw	a5,-20(s0)
   1018c:	0017879b          	addiw	a5,a5,1
   10190:	fef42623          	sw	a5,-20(s0)
   10194:	fec42783          	lw	a5,-20(s0)
   10198:	0007871b          	sext.w	a4,a5
   1019c:	500007b7          	lui	a5,0x50000
   101a0:	ffe78793          	addi	a5,a5,-2 # 4ffffffe <__global_pointer$+0x4ffed7fe>
   101a4:	fee7f2e3          	bgeu	a5,a4,10188 <main+0x68>
   101a8:	f89ff06f          	j	10130 <main+0x10>

00000000000101ac <putc>:
   101ac:	fe010113          	addi	sp,sp,-32
   101b0:	00813c23          	sd	s0,24(sp)
   101b4:	02010413          	addi	s0,sp,32
   101b8:	00050793          	mv	a5,a0
   101bc:	fef42623          	sw	a5,-20(s0)
   101c0:	00002797          	auipc	a5,0x2
   101c4:	e4478793          	addi	a5,a5,-444 # 12004 <tail>
   101c8:	0007a783          	lw	a5,0(a5)
   101cc:	0017871b          	addiw	a4,a5,1
   101d0:	0007069b          	sext.w	a3,a4
   101d4:	00002717          	auipc	a4,0x2
   101d8:	e3070713          	addi	a4,a4,-464 # 12004 <tail>
   101dc:	00d72023          	sw	a3,0(a4)
   101e0:	fec42703          	lw	a4,-20(s0)
   101e4:	0ff77713          	zext.b	a4,a4
   101e8:	00002697          	auipc	a3,0x2
   101ec:	e2068693          	addi	a3,a3,-480 # 12008 <buffer>
   101f0:	00f687b3          	add	a5,a3,a5
   101f4:	00e78023          	sb	a4,0(a5)
   101f8:	fec42783          	lw	a5,-20(s0)
   101fc:	0ff7f793          	zext.b	a5,a5
   10200:	0007879b          	sext.w	a5,a5
   10204:	00078513          	mv	a0,a5
   10208:	01813403          	ld	s0,24(sp)
   1020c:	02010113          	addi	sp,sp,32
   10210:	00008067          	ret

0000000000010214 <isspace>:
   10214:	fe010113          	addi	sp,sp,-32
   10218:	00813c23          	sd	s0,24(sp)
   1021c:	02010413          	addi	s0,sp,32
   10220:	00050793          	mv	a5,a0
   10224:	fef42623          	sw	a5,-20(s0)
   10228:	fec42783          	lw	a5,-20(s0)
   1022c:	0007871b          	sext.w	a4,a5
   10230:	02000793          	li	a5,32
   10234:	02f70263          	beq	a4,a5,10258 <isspace+0x44>
   10238:	fec42783          	lw	a5,-20(s0)
   1023c:	0007871b          	sext.w	a4,a5
   10240:	00800793          	li	a5,8
   10244:	00e7de63          	bge	a5,a4,10260 <isspace+0x4c>
   10248:	fec42783          	lw	a5,-20(s0)
   1024c:	0007871b          	sext.w	a4,a5
   10250:	00d00793          	li	a5,13
   10254:	00e7c663          	blt	a5,a4,10260 <isspace+0x4c>
   10258:	00100793          	li	a5,1
   1025c:	0080006f          	j	10264 <isspace+0x50>
   10260:	00000793          	li	a5,0
   10264:	00078513          	mv	a0,a5
   10268:	01813403          	ld	s0,24(sp)
   1026c:	02010113          	addi	sp,sp,32
   10270:	00008067          	ret

0000000000010274 <strtol>:
   10274:	fb010113          	addi	sp,sp,-80
   10278:	04113423          	sd	ra,72(sp)
   1027c:	04813023          	sd	s0,64(sp)
   10280:	05010413          	addi	s0,sp,80
   10284:	fca43423          	sd	a0,-56(s0)
   10288:	fcb43023          	sd	a1,-64(s0)
   1028c:	00060793          	mv	a5,a2
   10290:	faf42e23          	sw	a5,-68(s0)
   10294:	fe043423          	sd	zero,-24(s0)
   10298:	fe0403a3          	sb	zero,-25(s0)
   1029c:	fc843783          	ld	a5,-56(s0)
   102a0:	fcf43c23          	sd	a5,-40(s0)
   102a4:	0100006f          	j	102b4 <strtol+0x40>
   102a8:	fd843783          	ld	a5,-40(s0)
   102ac:	00178793          	addi	a5,a5,1
   102b0:	fcf43c23          	sd	a5,-40(s0)
   102b4:	fd843783          	ld	a5,-40(s0)
   102b8:	0007c783          	lbu	a5,0(a5)
   102bc:	0007879b          	sext.w	a5,a5
   102c0:	00078513          	mv	a0,a5
   102c4:	00000097          	auipc	ra,0x0
   102c8:	f50080e7          	jalr	-176(ra) # 10214 <isspace>
   102cc:	00050793          	mv	a5,a0
   102d0:	fc079ce3          	bnez	a5,102a8 <strtol+0x34>
   102d4:	fd843783          	ld	a5,-40(s0)
   102d8:	0007c783          	lbu	a5,0(a5)
   102dc:	00078713          	mv	a4,a5
   102e0:	02d00793          	li	a5,45
   102e4:	00f71e63          	bne	a4,a5,10300 <strtol+0x8c>
   102e8:	00100793          	li	a5,1
   102ec:	fef403a3          	sb	a5,-25(s0)
   102f0:	fd843783          	ld	a5,-40(s0)
   102f4:	00178793          	addi	a5,a5,1
   102f8:	fcf43c23          	sd	a5,-40(s0)
   102fc:	0240006f          	j	10320 <strtol+0xac>
   10300:	fd843783          	ld	a5,-40(s0)
   10304:	0007c783          	lbu	a5,0(a5)
   10308:	00078713          	mv	a4,a5
   1030c:	02b00793          	li	a5,43
   10310:	00f71863          	bne	a4,a5,10320 <strtol+0xac>
   10314:	fd843783          	ld	a5,-40(s0)
   10318:	00178793          	addi	a5,a5,1
   1031c:	fcf43c23          	sd	a5,-40(s0)
   10320:	fbc42783          	lw	a5,-68(s0)
   10324:	0007879b          	sext.w	a5,a5
   10328:	06079c63          	bnez	a5,103a0 <strtol+0x12c>
   1032c:	fd843783          	ld	a5,-40(s0)
   10330:	0007c783          	lbu	a5,0(a5)
   10334:	00078713          	mv	a4,a5
   10338:	03000793          	li	a5,48
   1033c:	04f71e63          	bne	a4,a5,10398 <strtol+0x124>
   10340:	fd843783          	ld	a5,-40(s0)
   10344:	00178793          	addi	a5,a5,1
   10348:	fcf43c23          	sd	a5,-40(s0)
   1034c:	fd843783          	ld	a5,-40(s0)
   10350:	0007c783          	lbu	a5,0(a5)
   10354:	00078713          	mv	a4,a5
   10358:	07800793          	li	a5,120
   1035c:	00f70c63          	beq	a4,a5,10374 <strtol+0x100>
   10360:	fd843783          	ld	a5,-40(s0)
   10364:	0007c783          	lbu	a5,0(a5)
   10368:	00078713          	mv	a4,a5
   1036c:	05800793          	li	a5,88
   10370:	00f71e63          	bne	a4,a5,1038c <strtol+0x118>
   10374:	01000793          	li	a5,16
   10378:	faf42e23          	sw	a5,-68(s0)
   1037c:	fd843783          	ld	a5,-40(s0)
   10380:	00178793          	addi	a5,a5,1
   10384:	fcf43c23          	sd	a5,-40(s0)
   10388:	0180006f          	j	103a0 <strtol+0x12c>
   1038c:	00800793          	li	a5,8
   10390:	faf42e23          	sw	a5,-68(s0)
   10394:	00c0006f          	j	103a0 <strtol+0x12c>
   10398:	00a00793          	li	a5,10
   1039c:	faf42e23          	sw	a5,-68(s0)
   103a0:	fd843783          	ld	a5,-40(s0)
   103a4:	0007c783          	lbu	a5,0(a5)
   103a8:	00078713          	mv	a4,a5
   103ac:	02f00793          	li	a5,47
   103b0:	02e7f863          	bgeu	a5,a4,103e0 <strtol+0x16c>
   103b4:	fd843783          	ld	a5,-40(s0)
   103b8:	0007c783          	lbu	a5,0(a5)
   103bc:	00078713          	mv	a4,a5
   103c0:	03900793          	li	a5,57
   103c4:	00e7ee63          	bltu	a5,a4,103e0 <strtol+0x16c>
   103c8:	fd843783          	ld	a5,-40(s0)
   103cc:	0007c783          	lbu	a5,0(a5)
   103d0:	0007879b          	sext.w	a5,a5
   103d4:	fd07879b          	addiw	a5,a5,-48
   103d8:	fcf42a23          	sw	a5,-44(s0)
   103dc:	0800006f          	j	1045c <strtol+0x1e8>
   103e0:	fd843783          	ld	a5,-40(s0)
   103e4:	0007c783          	lbu	a5,0(a5)
   103e8:	00078713          	mv	a4,a5
   103ec:	06000793          	li	a5,96
   103f0:	02e7f863          	bgeu	a5,a4,10420 <strtol+0x1ac>
   103f4:	fd843783          	ld	a5,-40(s0)
   103f8:	0007c783          	lbu	a5,0(a5)
   103fc:	00078713          	mv	a4,a5
   10400:	07a00793          	li	a5,122
   10404:	00e7ee63          	bltu	a5,a4,10420 <strtol+0x1ac>
   10408:	fd843783          	ld	a5,-40(s0)
   1040c:	0007c783          	lbu	a5,0(a5)
   10410:	0007879b          	sext.w	a5,a5
   10414:	fa97879b          	addiw	a5,a5,-87
   10418:	fcf42a23          	sw	a5,-44(s0)
   1041c:	0400006f          	j	1045c <strtol+0x1e8>
   10420:	fd843783          	ld	a5,-40(s0)
   10424:	0007c783          	lbu	a5,0(a5)
   10428:	00078713          	mv	a4,a5
   1042c:	04000793          	li	a5,64
   10430:	06e7f863          	bgeu	a5,a4,104a0 <strtol+0x22c>
   10434:	fd843783          	ld	a5,-40(s0)
   10438:	0007c783          	lbu	a5,0(a5)
   1043c:	00078713          	mv	a4,a5
   10440:	05a00793          	li	a5,90
   10444:	04e7ee63          	bltu	a5,a4,104a0 <strtol+0x22c>
   10448:	fd843783          	ld	a5,-40(s0)
   1044c:	0007c783          	lbu	a5,0(a5)
   10450:	0007879b          	sext.w	a5,a5
   10454:	fc97879b          	addiw	a5,a5,-55
   10458:	fcf42a23          	sw	a5,-44(s0)
   1045c:	fd442783          	lw	a5,-44(s0)
   10460:	00078713          	mv	a4,a5
   10464:	fbc42783          	lw	a5,-68(s0)
   10468:	0007071b          	sext.w	a4,a4
   1046c:	0007879b          	sext.w	a5,a5
   10470:	02f75663          	bge	a4,a5,1049c <strtol+0x228>
   10474:	fbc42703          	lw	a4,-68(s0)
   10478:	fe843783          	ld	a5,-24(s0)
   1047c:	02f70733          	mul	a4,a4,a5
   10480:	fd442783          	lw	a5,-44(s0)
   10484:	00f707b3          	add	a5,a4,a5
   10488:	fef43423          	sd	a5,-24(s0)
   1048c:	fd843783          	ld	a5,-40(s0)
   10490:	00178793          	addi	a5,a5,1
   10494:	fcf43c23          	sd	a5,-40(s0)
   10498:	f09ff06f          	j	103a0 <strtol+0x12c>
   1049c:	00000013          	nop
   104a0:	fc043783          	ld	a5,-64(s0)
   104a4:	00078863          	beqz	a5,104b4 <strtol+0x240>
   104a8:	fc043783          	ld	a5,-64(s0)
   104ac:	fd843703          	ld	a4,-40(s0)
   104b0:	00e7b023          	sd	a4,0(a5)
   104b4:	fe744783          	lbu	a5,-25(s0)
   104b8:	0ff7f793          	zext.b	a5,a5
   104bc:	00078863          	beqz	a5,104cc <strtol+0x258>
   104c0:	fe843783          	ld	a5,-24(s0)
   104c4:	40f007b3          	neg	a5,a5
   104c8:	0080006f          	j	104d0 <strtol+0x25c>
   104cc:	fe843783          	ld	a5,-24(s0)
   104d0:	00078513          	mv	a0,a5
   104d4:	04813083          	ld	ra,72(sp)
   104d8:	04013403          	ld	s0,64(sp)
   104dc:	05010113          	addi	sp,sp,80
   104e0:	00008067          	ret

00000000000104e4 <puts_wo_nl>:
   104e4:	fd010113          	addi	sp,sp,-48
   104e8:	02113423          	sd	ra,40(sp)
   104ec:	02813023          	sd	s0,32(sp)
   104f0:	03010413          	addi	s0,sp,48
   104f4:	fca43c23          	sd	a0,-40(s0)
   104f8:	fcb43823          	sd	a1,-48(s0)
   104fc:	fd043783          	ld	a5,-48(s0)
   10500:	00079863          	bnez	a5,10510 <puts_wo_nl+0x2c>
   10504:	00001797          	auipc	a5,0x1
   10508:	cac78793          	addi	a5,a5,-852 # 111b0 <printf+0x138>
   1050c:	fcf43823          	sd	a5,-48(s0)
   10510:	fd043783          	ld	a5,-48(s0)
   10514:	fef43423          	sd	a5,-24(s0)
   10518:	0240006f          	j	1053c <puts_wo_nl+0x58>
   1051c:	fe843783          	ld	a5,-24(s0)
   10520:	00178713          	addi	a4,a5,1
   10524:	fee43423          	sd	a4,-24(s0)
   10528:	0007c783          	lbu	a5,0(a5)
   1052c:	0007871b          	sext.w	a4,a5
   10530:	fd843783          	ld	a5,-40(s0)
   10534:	00070513          	mv	a0,a4
   10538:	000780e7          	jalr	a5
   1053c:	fe843783          	ld	a5,-24(s0)
   10540:	0007c783          	lbu	a5,0(a5)
   10544:	fc079ce3          	bnez	a5,1051c <puts_wo_nl+0x38>
   10548:	fe843703          	ld	a4,-24(s0)
   1054c:	fd043783          	ld	a5,-48(s0)
   10550:	40f707b3          	sub	a5,a4,a5
   10554:	0007879b          	sext.w	a5,a5
   10558:	00078513          	mv	a0,a5
   1055c:	02813083          	ld	ra,40(sp)
   10560:	02013403          	ld	s0,32(sp)
   10564:	03010113          	addi	sp,sp,48
   10568:	00008067          	ret

000000000001056c <print_dec_int>:
   1056c:	f9010113          	addi	sp,sp,-112
   10570:	06113423          	sd	ra,104(sp)
   10574:	06813023          	sd	s0,96(sp)
   10578:	07010413          	addi	s0,sp,112
   1057c:	faa43423          	sd	a0,-88(s0)
   10580:	fab43023          	sd	a1,-96(s0)
   10584:	00060793          	mv	a5,a2
   10588:	f8d43823          	sd	a3,-112(s0)
   1058c:	f8f40fa3          	sb	a5,-97(s0)
   10590:	f9f44783          	lbu	a5,-97(s0)
   10594:	0ff7f793          	zext.b	a5,a5
   10598:	02078863          	beqz	a5,105c8 <print_dec_int+0x5c>
   1059c:	fa043703          	ld	a4,-96(s0)
   105a0:	fff00793          	li	a5,-1
   105a4:	03f79793          	slli	a5,a5,0x3f
   105a8:	02f71063          	bne	a4,a5,105c8 <print_dec_int+0x5c>
   105ac:	00001597          	auipc	a1,0x1
   105b0:	c0c58593          	addi	a1,a1,-1012 # 111b8 <printf+0x140>
   105b4:	fa843503          	ld	a0,-88(s0)
   105b8:	00000097          	auipc	ra,0x0
   105bc:	f2c080e7          	jalr	-212(ra) # 104e4 <puts_wo_nl>
   105c0:	00050793          	mv	a5,a0
   105c4:	2a00006f          	j	10864 <print_dec_int+0x2f8>
   105c8:	f9043783          	ld	a5,-112(s0)
   105cc:	00c7a783          	lw	a5,12(a5)
   105d0:	00079a63          	bnez	a5,105e4 <print_dec_int+0x78>
   105d4:	fa043783          	ld	a5,-96(s0)
   105d8:	00079663          	bnez	a5,105e4 <print_dec_int+0x78>
   105dc:	00000793          	li	a5,0
   105e0:	2840006f          	j	10864 <print_dec_int+0x2f8>
   105e4:	fe0407a3          	sb	zero,-17(s0)
   105e8:	f9f44783          	lbu	a5,-97(s0)
   105ec:	0ff7f793          	zext.b	a5,a5
   105f0:	02078063          	beqz	a5,10610 <print_dec_int+0xa4>
   105f4:	fa043783          	ld	a5,-96(s0)
   105f8:	0007dc63          	bgez	a5,10610 <print_dec_int+0xa4>
   105fc:	00100793          	li	a5,1
   10600:	fef407a3          	sb	a5,-17(s0)
   10604:	fa043783          	ld	a5,-96(s0)
   10608:	40f007b3          	neg	a5,a5
   1060c:	faf43023          	sd	a5,-96(s0)
   10610:	fe042423          	sw	zero,-24(s0)
   10614:	f9f44783          	lbu	a5,-97(s0)
   10618:	0ff7f793          	zext.b	a5,a5
   1061c:	02078863          	beqz	a5,1064c <print_dec_int+0xe0>
   10620:	fef44783          	lbu	a5,-17(s0)
   10624:	0ff7f793          	zext.b	a5,a5
   10628:	00079e63          	bnez	a5,10644 <print_dec_int+0xd8>
   1062c:	f9043783          	ld	a5,-112(s0)
   10630:	0057c783          	lbu	a5,5(a5)
   10634:	00079863          	bnez	a5,10644 <print_dec_int+0xd8>
   10638:	f9043783          	ld	a5,-112(s0)
   1063c:	0047c783          	lbu	a5,4(a5)
   10640:	00078663          	beqz	a5,1064c <print_dec_int+0xe0>
   10644:	00100793          	li	a5,1
   10648:	0080006f          	j	10650 <print_dec_int+0xe4>
   1064c:	00000793          	li	a5,0
   10650:	fcf40ba3          	sb	a5,-41(s0)
   10654:	fd744783          	lbu	a5,-41(s0)
   10658:	0017f793          	andi	a5,a5,1
   1065c:	fcf40ba3          	sb	a5,-41(s0)
   10660:	fa043703          	ld	a4,-96(s0)
   10664:	00a00793          	li	a5,10
   10668:	02f777b3          	remu	a5,a4,a5
   1066c:	0ff7f713          	zext.b	a4,a5
   10670:	fe842783          	lw	a5,-24(s0)
   10674:	0017869b          	addiw	a3,a5,1
   10678:	fed42423          	sw	a3,-24(s0)
   1067c:	0307071b          	addiw	a4,a4,48
   10680:	0ff77713          	zext.b	a4,a4
   10684:	ff078793          	addi	a5,a5,-16
   10688:	008787b3          	add	a5,a5,s0
   1068c:	fce78423          	sb	a4,-56(a5)
   10690:	fa043703          	ld	a4,-96(s0)
   10694:	00a00793          	li	a5,10
   10698:	02f757b3          	divu	a5,a4,a5
   1069c:	faf43023          	sd	a5,-96(s0)
   106a0:	fa043783          	ld	a5,-96(s0)
   106a4:	fa079ee3          	bnez	a5,10660 <print_dec_int+0xf4>
   106a8:	f9043783          	ld	a5,-112(s0)
   106ac:	00c7a783          	lw	a5,12(a5)
   106b0:	00078713          	mv	a4,a5
   106b4:	fff00793          	li	a5,-1
   106b8:	02f71063          	bne	a4,a5,106d8 <print_dec_int+0x16c>
   106bc:	f9043783          	ld	a5,-112(s0)
   106c0:	0037c783          	lbu	a5,3(a5)
   106c4:	00078a63          	beqz	a5,106d8 <print_dec_int+0x16c>
   106c8:	f9043783          	ld	a5,-112(s0)
   106cc:	0087a703          	lw	a4,8(a5)
   106d0:	f9043783          	ld	a5,-112(s0)
   106d4:	00e7a623          	sw	a4,12(a5)
   106d8:	fe042223          	sw	zero,-28(s0)
   106dc:	f9043783          	ld	a5,-112(s0)
   106e0:	0087a703          	lw	a4,8(a5)
   106e4:	fe842783          	lw	a5,-24(s0)
   106e8:	fcf42823          	sw	a5,-48(s0)
   106ec:	f9043783          	ld	a5,-112(s0)
   106f0:	00c7a783          	lw	a5,12(a5)
   106f4:	fcf42623          	sw	a5,-52(s0)
   106f8:	fd042783          	lw	a5,-48(s0)
   106fc:	00078593          	mv	a1,a5
   10700:	fcc42783          	lw	a5,-52(s0)
   10704:	00078613          	mv	a2,a5
   10708:	0006069b          	sext.w	a3,a2
   1070c:	0005879b          	sext.w	a5,a1
   10710:	00f6d463          	bge	a3,a5,10718 <print_dec_int+0x1ac>
   10714:	00058613          	mv	a2,a1
   10718:	0006079b          	sext.w	a5,a2
   1071c:	40f707bb          	subw	a5,a4,a5
   10720:	0007871b          	sext.w	a4,a5
   10724:	fd744783          	lbu	a5,-41(s0)
   10728:	0007879b          	sext.w	a5,a5
   1072c:	40f707bb          	subw	a5,a4,a5
   10730:	fef42023          	sw	a5,-32(s0)
   10734:	0280006f          	j	1075c <print_dec_int+0x1f0>
   10738:	fa843783          	ld	a5,-88(s0)
   1073c:	02000513          	li	a0,32
   10740:	000780e7          	jalr	a5
   10744:	fe442783          	lw	a5,-28(s0)
   10748:	0017879b          	addiw	a5,a5,1
   1074c:	fef42223          	sw	a5,-28(s0)
   10750:	fe042783          	lw	a5,-32(s0)
   10754:	fff7879b          	addiw	a5,a5,-1
   10758:	fef42023          	sw	a5,-32(s0)
   1075c:	fe042783          	lw	a5,-32(s0)
   10760:	0007879b          	sext.w	a5,a5
   10764:	fcf04ae3          	bgtz	a5,10738 <print_dec_int+0x1cc>
   10768:	fd744783          	lbu	a5,-41(s0)
   1076c:	0ff7f793          	zext.b	a5,a5
   10770:	04078463          	beqz	a5,107b8 <print_dec_int+0x24c>
   10774:	fef44783          	lbu	a5,-17(s0)
   10778:	0ff7f793          	zext.b	a5,a5
   1077c:	00078663          	beqz	a5,10788 <print_dec_int+0x21c>
   10780:	02d00793          	li	a5,45
   10784:	01c0006f          	j	107a0 <print_dec_int+0x234>
   10788:	f9043783          	ld	a5,-112(s0)
   1078c:	0057c783          	lbu	a5,5(a5)
   10790:	00078663          	beqz	a5,1079c <print_dec_int+0x230>
   10794:	02b00793          	li	a5,43
   10798:	0080006f          	j	107a0 <print_dec_int+0x234>
   1079c:	02000793          	li	a5,32
   107a0:	fa843703          	ld	a4,-88(s0)
   107a4:	00078513          	mv	a0,a5
   107a8:	000700e7          	jalr	a4
   107ac:	fe442783          	lw	a5,-28(s0)
   107b0:	0017879b          	addiw	a5,a5,1
   107b4:	fef42223          	sw	a5,-28(s0)
   107b8:	fe842783          	lw	a5,-24(s0)
   107bc:	fcf42e23          	sw	a5,-36(s0)
   107c0:	0280006f          	j	107e8 <print_dec_int+0x27c>
   107c4:	fa843783          	ld	a5,-88(s0)
   107c8:	03000513          	li	a0,48
   107cc:	000780e7          	jalr	a5
   107d0:	fe442783          	lw	a5,-28(s0)
   107d4:	0017879b          	addiw	a5,a5,1
   107d8:	fef42223          	sw	a5,-28(s0)
   107dc:	fdc42783          	lw	a5,-36(s0)
   107e0:	0017879b          	addiw	a5,a5,1
   107e4:	fcf42e23          	sw	a5,-36(s0)
   107e8:	f9043783          	ld	a5,-112(s0)
   107ec:	00c7a703          	lw	a4,12(a5)
   107f0:	fd744783          	lbu	a5,-41(s0)
   107f4:	0007879b          	sext.w	a5,a5
   107f8:	40f707bb          	subw	a5,a4,a5
   107fc:	0007871b          	sext.w	a4,a5
   10800:	fdc42783          	lw	a5,-36(s0)
   10804:	0007879b          	sext.w	a5,a5
   10808:	fae7cee3          	blt	a5,a4,107c4 <print_dec_int+0x258>
   1080c:	fe842783          	lw	a5,-24(s0)
   10810:	fff7879b          	addiw	a5,a5,-1
   10814:	fcf42c23          	sw	a5,-40(s0)
   10818:	03c0006f          	j	10854 <print_dec_int+0x2e8>
   1081c:	fd842783          	lw	a5,-40(s0)
   10820:	ff078793          	addi	a5,a5,-16
   10824:	008787b3          	add	a5,a5,s0
   10828:	fc87c783          	lbu	a5,-56(a5)
   1082c:	0007871b          	sext.w	a4,a5
   10830:	fa843783          	ld	a5,-88(s0)
   10834:	00070513          	mv	a0,a4
   10838:	000780e7          	jalr	a5
   1083c:	fe442783          	lw	a5,-28(s0)
   10840:	0017879b          	addiw	a5,a5,1
   10844:	fef42223          	sw	a5,-28(s0)
   10848:	fd842783          	lw	a5,-40(s0)
   1084c:	fff7879b          	addiw	a5,a5,-1
   10850:	fcf42c23          	sw	a5,-40(s0)
   10854:	fd842783          	lw	a5,-40(s0)
   10858:	0007879b          	sext.w	a5,a5
   1085c:	fc07d0e3          	bgez	a5,1081c <print_dec_int+0x2b0>
   10860:	fe442783          	lw	a5,-28(s0)
   10864:	00078513          	mv	a0,a5
   10868:	06813083          	ld	ra,104(sp)
   1086c:	06013403          	ld	s0,96(sp)
   10870:	07010113          	addi	sp,sp,112
   10874:	00008067          	ret

0000000000010878 <vprintfmt>:
   10878:	f4010113          	addi	sp,sp,-192
   1087c:	0a113c23          	sd	ra,184(sp)
   10880:	0a813823          	sd	s0,176(sp)
   10884:	0c010413          	addi	s0,sp,192
   10888:	f4a43c23          	sd	a0,-168(s0)
   1088c:	f4b43823          	sd	a1,-176(s0)
   10890:	f4c43423          	sd	a2,-184(s0)
   10894:	f8043023          	sd	zero,-128(s0)
   10898:	f8043423          	sd	zero,-120(s0)
   1089c:	fe042623          	sw	zero,-20(s0)
   108a0:	7b40006f          	j	11054 <vprintfmt+0x7dc>
   108a4:	f8044783          	lbu	a5,-128(s0)
   108a8:	74078663          	beqz	a5,10ff4 <vprintfmt+0x77c>
   108ac:	f5043783          	ld	a5,-176(s0)
   108b0:	0007c783          	lbu	a5,0(a5)
   108b4:	00078713          	mv	a4,a5
   108b8:	02300793          	li	a5,35
   108bc:	00f71863          	bne	a4,a5,108cc <vprintfmt+0x54>
   108c0:	00100793          	li	a5,1
   108c4:	f8f40123          	sb	a5,-126(s0)
   108c8:	7800006f          	j	11048 <vprintfmt+0x7d0>
   108cc:	f5043783          	ld	a5,-176(s0)
   108d0:	0007c783          	lbu	a5,0(a5)
   108d4:	00078713          	mv	a4,a5
   108d8:	03000793          	li	a5,48
   108dc:	00f71863          	bne	a4,a5,108ec <vprintfmt+0x74>
   108e0:	00100793          	li	a5,1
   108e4:	f8f401a3          	sb	a5,-125(s0)
   108e8:	7600006f          	j	11048 <vprintfmt+0x7d0>
   108ec:	f5043783          	ld	a5,-176(s0)
   108f0:	0007c783          	lbu	a5,0(a5)
   108f4:	00078713          	mv	a4,a5
   108f8:	06c00793          	li	a5,108
   108fc:	04f70063          	beq	a4,a5,1093c <vprintfmt+0xc4>
   10900:	f5043783          	ld	a5,-176(s0)
   10904:	0007c783          	lbu	a5,0(a5)
   10908:	00078713          	mv	a4,a5
   1090c:	07a00793          	li	a5,122
   10910:	02f70663          	beq	a4,a5,1093c <vprintfmt+0xc4>
   10914:	f5043783          	ld	a5,-176(s0)
   10918:	0007c783          	lbu	a5,0(a5)
   1091c:	00078713          	mv	a4,a5
   10920:	07400793          	li	a5,116
   10924:	00f70c63          	beq	a4,a5,1093c <vprintfmt+0xc4>
   10928:	f5043783          	ld	a5,-176(s0)
   1092c:	0007c783          	lbu	a5,0(a5)
   10930:	00078713          	mv	a4,a5
   10934:	06a00793          	li	a5,106
   10938:	00f71863          	bne	a4,a5,10948 <vprintfmt+0xd0>
   1093c:	00100793          	li	a5,1
   10940:	f8f400a3          	sb	a5,-127(s0)
   10944:	7040006f          	j	11048 <vprintfmt+0x7d0>
   10948:	f5043783          	ld	a5,-176(s0)
   1094c:	0007c783          	lbu	a5,0(a5)
   10950:	00078713          	mv	a4,a5
   10954:	02b00793          	li	a5,43
   10958:	00f71863          	bne	a4,a5,10968 <vprintfmt+0xf0>
   1095c:	00100793          	li	a5,1
   10960:	f8f402a3          	sb	a5,-123(s0)
   10964:	6e40006f          	j	11048 <vprintfmt+0x7d0>
   10968:	f5043783          	ld	a5,-176(s0)
   1096c:	0007c783          	lbu	a5,0(a5)
   10970:	00078713          	mv	a4,a5
   10974:	02000793          	li	a5,32
   10978:	00f71863          	bne	a4,a5,10988 <vprintfmt+0x110>
   1097c:	00100793          	li	a5,1
   10980:	f8f40223          	sb	a5,-124(s0)
   10984:	6c40006f          	j	11048 <vprintfmt+0x7d0>
   10988:	f5043783          	ld	a5,-176(s0)
   1098c:	0007c783          	lbu	a5,0(a5)
   10990:	00078713          	mv	a4,a5
   10994:	02a00793          	li	a5,42
   10998:	00f71e63          	bne	a4,a5,109b4 <vprintfmt+0x13c>
   1099c:	f4843783          	ld	a5,-184(s0)
   109a0:	00878713          	addi	a4,a5,8
   109a4:	f4e43423          	sd	a4,-184(s0)
   109a8:	0007a783          	lw	a5,0(a5)
   109ac:	f8f42423          	sw	a5,-120(s0)
   109b0:	6980006f          	j	11048 <vprintfmt+0x7d0>
   109b4:	f5043783          	ld	a5,-176(s0)
   109b8:	0007c783          	lbu	a5,0(a5)
   109bc:	00078713          	mv	a4,a5
   109c0:	03000793          	li	a5,48
   109c4:	04e7f863          	bgeu	a5,a4,10a14 <vprintfmt+0x19c>
   109c8:	f5043783          	ld	a5,-176(s0)
   109cc:	0007c783          	lbu	a5,0(a5)
   109d0:	00078713          	mv	a4,a5
   109d4:	03900793          	li	a5,57
   109d8:	02e7ee63          	bltu	a5,a4,10a14 <vprintfmt+0x19c>
   109dc:	f5043783          	ld	a5,-176(s0)
   109e0:	f5040713          	addi	a4,s0,-176
   109e4:	00a00613          	li	a2,10
   109e8:	00070593          	mv	a1,a4
   109ec:	00078513          	mv	a0,a5
   109f0:	00000097          	auipc	ra,0x0
   109f4:	884080e7          	jalr	-1916(ra) # 10274 <strtol>
   109f8:	00050793          	mv	a5,a0
   109fc:	0007879b          	sext.w	a5,a5
   10a00:	f8f42423          	sw	a5,-120(s0)
   10a04:	f5043783          	ld	a5,-176(s0)
   10a08:	fff78793          	addi	a5,a5,-1
   10a0c:	f4f43823          	sd	a5,-176(s0)
   10a10:	6380006f          	j	11048 <vprintfmt+0x7d0>
   10a14:	f5043783          	ld	a5,-176(s0)
   10a18:	0007c783          	lbu	a5,0(a5)
   10a1c:	00078713          	mv	a4,a5
   10a20:	02e00793          	li	a5,46
   10a24:	06f71a63          	bne	a4,a5,10a98 <vprintfmt+0x220>
   10a28:	f5043783          	ld	a5,-176(s0)
   10a2c:	00178793          	addi	a5,a5,1
   10a30:	f4f43823          	sd	a5,-176(s0)
   10a34:	f5043783          	ld	a5,-176(s0)
   10a38:	0007c783          	lbu	a5,0(a5)
   10a3c:	00078713          	mv	a4,a5
   10a40:	02a00793          	li	a5,42
   10a44:	00f71e63          	bne	a4,a5,10a60 <vprintfmt+0x1e8>
   10a48:	f4843783          	ld	a5,-184(s0)
   10a4c:	00878713          	addi	a4,a5,8
   10a50:	f4e43423          	sd	a4,-184(s0)
   10a54:	0007a783          	lw	a5,0(a5)
   10a58:	f8f42623          	sw	a5,-116(s0)
   10a5c:	5ec0006f          	j	11048 <vprintfmt+0x7d0>
   10a60:	f5043783          	ld	a5,-176(s0)
   10a64:	f5040713          	addi	a4,s0,-176
   10a68:	00a00613          	li	a2,10
   10a6c:	00070593          	mv	a1,a4
   10a70:	00078513          	mv	a0,a5
   10a74:	00000097          	auipc	ra,0x0
   10a78:	800080e7          	jalr	-2048(ra) # 10274 <strtol>
   10a7c:	00050793          	mv	a5,a0
   10a80:	0007879b          	sext.w	a5,a5
   10a84:	f8f42623          	sw	a5,-116(s0)
   10a88:	f5043783          	ld	a5,-176(s0)
   10a8c:	fff78793          	addi	a5,a5,-1
   10a90:	f4f43823          	sd	a5,-176(s0)
   10a94:	5b40006f          	j	11048 <vprintfmt+0x7d0>
   10a98:	f5043783          	ld	a5,-176(s0)
   10a9c:	0007c783          	lbu	a5,0(a5)
   10aa0:	00078713          	mv	a4,a5
   10aa4:	07800793          	li	a5,120
   10aa8:	02f70663          	beq	a4,a5,10ad4 <vprintfmt+0x25c>
   10aac:	f5043783          	ld	a5,-176(s0)
   10ab0:	0007c783          	lbu	a5,0(a5)
   10ab4:	00078713          	mv	a4,a5
   10ab8:	05800793          	li	a5,88
   10abc:	00f70c63          	beq	a4,a5,10ad4 <vprintfmt+0x25c>
   10ac0:	f5043783          	ld	a5,-176(s0)
   10ac4:	0007c783          	lbu	a5,0(a5)
   10ac8:	00078713          	mv	a4,a5
   10acc:	07000793          	li	a5,112
   10ad0:	30f71263          	bne	a4,a5,10dd4 <vprintfmt+0x55c>
   10ad4:	f5043783          	ld	a5,-176(s0)
   10ad8:	0007c783          	lbu	a5,0(a5)
   10adc:	00078713          	mv	a4,a5
   10ae0:	07000793          	li	a5,112
   10ae4:	00f70663          	beq	a4,a5,10af0 <vprintfmt+0x278>
   10ae8:	f8144783          	lbu	a5,-127(s0)
   10aec:	00078663          	beqz	a5,10af8 <vprintfmt+0x280>
   10af0:	00100793          	li	a5,1
   10af4:	0080006f          	j	10afc <vprintfmt+0x284>
   10af8:	00000793          	li	a5,0
   10afc:	faf403a3          	sb	a5,-89(s0)
   10b00:	fa744783          	lbu	a5,-89(s0)
   10b04:	0017f793          	andi	a5,a5,1
   10b08:	faf403a3          	sb	a5,-89(s0)
   10b0c:	fa744783          	lbu	a5,-89(s0)
   10b10:	0ff7f793          	zext.b	a5,a5
   10b14:	00078c63          	beqz	a5,10b2c <vprintfmt+0x2b4>
   10b18:	f4843783          	ld	a5,-184(s0)
   10b1c:	00878713          	addi	a4,a5,8
   10b20:	f4e43423          	sd	a4,-184(s0)
   10b24:	0007b783          	ld	a5,0(a5)
   10b28:	01c0006f          	j	10b44 <vprintfmt+0x2cc>
   10b2c:	f4843783          	ld	a5,-184(s0)
   10b30:	00878713          	addi	a4,a5,8
   10b34:	f4e43423          	sd	a4,-184(s0)
   10b38:	0007a783          	lw	a5,0(a5)
   10b3c:	02079793          	slli	a5,a5,0x20
   10b40:	0207d793          	srli	a5,a5,0x20
   10b44:	fef43023          	sd	a5,-32(s0)
   10b48:	f8c42783          	lw	a5,-116(s0)
   10b4c:	02079463          	bnez	a5,10b74 <vprintfmt+0x2fc>
   10b50:	fe043783          	ld	a5,-32(s0)
   10b54:	02079063          	bnez	a5,10b74 <vprintfmt+0x2fc>
   10b58:	f5043783          	ld	a5,-176(s0)
   10b5c:	0007c783          	lbu	a5,0(a5)
   10b60:	00078713          	mv	a4,a5
   10b64:	07000793          	li	a5,112
   10b68:	00f70663          	beq	a4,a5,10b74 <vprintfmt+0x2fc>
   10b6c:	f8040023          	sb	zero,-128(s0)
   10b70:	4d80006f          	j	11048 <vprintfmt+0x7d0>
   10b74:	f5043783          	ld	a5,-176(s0)
   10b78:	0007c783          	lbu	a5,0(a5)
   10b7c:	00078713          	mv	a4,a5
   10b80:	07000793          	li	a5,112
   10b84:	00f70a63          	beq	a4,a5,10b98 <vprintfmt+0x320>
   10b88:	f8244783          	lbu	a5,-126(s0)
   10b8c:	00078a63          	beqz	a5,10ba0 <vprintfmt+0x328>
   10b90:	fe043783          	ld	a5,-32(s0)
   10b94:	00078663          	beqz	a5,10ba0 <vprintfmt+0x328>
   10b98:	00100793          	li	a5,1
   10b9c:	0080006f          	j	10ba4 <vprintfmt+0x32c>
   10ba0:	00000793          	li	a5,0
   10ba4:	faf40323          	sb	a5,-90(s0)
   10ba8:	fa644783          	lbu	a5,-90(s0)
   10bac:	0017f793          	andi	a5,a5,1
   10bb0:	faf40323          	sb	a5,-90(s0)
   10bb4:	fc042e23          	sw	zero,-36(s0)
   10bb8:	f5043783          	ld	a5,-176(s0)
   10bbc:	0007c783          	lbu	a5,0(a5)
   10bc0:	00078713          	mv	a4,a5
   10bc4:	05800793          	li	a5,88
   10bc8:	00f71863          	bne	a4,a5,10bd8 <vprintfmt+0x360>
   10bcc:	00000797          	auipc	a5,0x0
   10bd0:	60478793          	addi	a5,a5,1540 # 111d0 <upperxdigits.1>
   10bd4:	00c0006f          	j	10be0 <vprintfmt+0x368>
   10bd8:	00000797          	auipc	a5,0x0
   10bdc:	61078793          	addi	a5,a5,1552 # 111e8 <lowerxdigits.0>
   10be0:	f8f43c23          	sd	a5,-104(s0)
   10be4:	fe043783          	ld	a5,-32(s0)
   10be8:	00f7f793          	andi	a5,a5,15
   10bec:	f9843703          	ld	a4,-104(s0)
   10bf0:	00f70733          	add	a4,a4,a5
   10bf4:	fdc42783          	lw	a5,-36(s0)
   10bf8:	0017869b          	addiw	a3,a5,1
   10bfc:	fcd42e23          	sw	a3,-36(s0)
   10c00:	00074703          	lbu	a4,0(a4)
   10c04:	ff078793          	addi	a5,a5,-16
   10c08:	008787b3          	add	a5,a5,s0
   10c0c:	f8e78023          	sb	a4,-128(a5)
   10c10:	fe043783          	ld	a5,-32(s0)
   10c14:	0047d793          	srli	a5,a5,0x4
   10c18:	fef43023          	sd	a5,-32(s0)
   10c1c:	fe043783          	ld	a5,-32(s0)
   10c20:	fc0792e3          	bnez	a5,10be4 <vprintfmt+0x36c>
   10c24:	f8c42783          	lw	a5,-116(s0)
   10c28:	00078713          	mv	a4,a5
   10c2c:	fff00793          	li	a5,-1
   10c30:	02f71663          	bne	a4,a5,10c5c <vprintfmt+0x3e4>
   10c34:	f8344783          	lbu	a5,-125(s0)
   10c38:	02078263          	beqz	a5,10c5c <vprintfmt+0x3e4>
   10c3c:	f8842703          	lw	a4,-120(s0)
   10c40:	fa644783          	lbu	a5,-90(s0)
   10c44:	0007879b          	sext.w	a5,a5
   10c48:	0017979b          	slliw	a5,a5,0x1
   10c4c:	0007879b          	sext.w	a5,a5
   10c50:	40f707bb          	subw	a5,a4,a5
   10c54:	0007879b          	sext.w	a5,a5
   10c58:	f8f42623          	sw	a5,-116(s0)
   10c5c:	f8842703          	lw	a4,-120(s0)
   10c60:	fa644783          	lbu	a5,-90(s0)
   10c64:	0007879b          	sext.w	a5,a5
   10c68:	0017979b          	slliw	a5,a5,0x1
   10c6c:	0007879b          	sext.w	a5,a5
   10c70:	40f707bb          	subw	a5,a4,a5
   10c74:	0007871b          	sext.w	a4,a5
   10c78:	fdc42783          	lw	a5,-36(s0)
   10c7c:	f8f42a23          	sw	a5,-108(s0)
   10c80:	f8c42783          	lw	a5,-116(s0)
   10c84:	f8f42823          	sw	a5,-112(s0)
   10c88:	f9442783          	lw	a5,-108(s0)
   10c8c:	00078593          	mv	a1,a5
   10c90:	f9042783          	lw	a5,-112(s0)
   10c94:	00078613          	mv	a2,a5
   10c98:	0006069b          	sext.w	a3,a2
   10c9c:	0005879b          	sext.w	a5,a1
   10ca0:	00f6d463          	bge	a3,a5,10ca8 <vprintfmt+0x430>
   10ca4:	00058613          	mv	a2,a1
   10ca8:	0006079b          	sext.w	a5,a2
   10cac:	40f707bb          	subw	a5,a4,a5
   10cb0:	fcf42c23          	sw	a5,-40(s0)
   10cb4:	0280006f          	j	10cdc <vprintfmt+0x464>
   10cb8:	f5843783          	ld	a5,-168(s0)
   10cbc:	02000513          	li	a0,32
   10cc0:	000780e7          	jalr	a5
   10cc4:	fec42783          	lw	a5,-20(s0)
   10cc8:	0017879b          	addiw	a5,a5,1
   10ccc:	fef42623          	sw	a5,-20(s0)
   10cd0:	fd842783          	lw	a5,-40(s0)
   10cd4:	fff7879b          	addiw	a5,a5,-1
   10cd8:	fcf42c23          	sw	a5,-40(s0)
   10cdc:	fd842783          	lw	a5,-40(s0)
   10ce0:	0007879b          	sext.w	a5,a5
   10ce4:	fcf04ae3          	bgtz	a5,10cb8 <vprintfmt+0x440>
   10ce8:	fa644783          	lbu	a5,-90(s0)
   10cec:	0ff7f793          	zext.b	a5,a5
   10cf0:	04078463          	beqz	a5,10d38 <vprintfmt+0x4c0>
   10cf4:	f5843783          	ld	a5,-168(s0)
   10cf8:	03000513          	li	a0,48
   10cfc:	000780e7          	jalr	a5
   10d00:	f5043783          	ld	a5,-176(s0)
   10d04:	0007c783          	lbu	a5,0(a5)
   10d08:	00078713          	mv	a4,a5
   10d0c:	05800793          	li	a5,88
   10d10:	00f71663          	bne	a4,a5,10d1c <vprintfmt+0x4a4>
   10d14:	05800793          	li	a5,88
   10d18:	0080006f          	j	10d20 <vprintfmt+0x4a8>
   10d1c:	07800793          	li	a5,120
   10d20:	f5843703          	ld	a4,-168(s0)
   10d24:	00078513          	mv	a0,a5
   10d28:	000700e7          	jalr	a4
   10d2c:	fec42783          	lw	a5,-20(s0)
   10d30:	0027879b          	addiw	a5,a5,2
   10d34:	fef42623          	sw	a5,-20(s0)
   10d38:	fdc42783          	lw	a5,-36(s0)
   10d3c:	fcf42a23          	sw	a5,-44(s0)
   10d40:	0280006f          	j	10d68 <vprintfmt+0x4f0>
   10d44:	f5843783          	ld	a5,-168(s0)
   10d48:	03000513          	li	a0,48
   10d4c:	000780e7          	jalr	a5
   10d50:	fec42783          	lw	a5,-20(s0)
   10d54:	0017879b          	addiw	a5,a5,1
   10d58:	fef42623          	sw	a5,-20(s0)
   10d5c:	fd442783          	lw	a5,-44(s0)
   10d60:	0017879b          	addiw	a5,a5,1
   10d64:	fcf42a23          	sw	a5,-44(s0)
   10d68:	f8c42703          	lw	a4,-116(s0)
   10d6c:	fd442783          	lw	a5,-44(s0)
   10d70:	0007879b          	sext.w	a5,a5
   10d74:	fce7c8e3          	blt	a5,a4,10d44 <vprintfmt+0x4cc>
   10d78:	fdc42783          	lw	a5,-36(s0)
   10d7c:	fff7879b          	addiw	a5,a5,-1
   10d80:	fcf42823          	sw	a5,-48(s0)
   10d84:	03c0006f          	j	10dc0 <vprintfmt+0x548>
   10d88:	fd042783          	lw	a5,-48(s0)
   10d8c:	ff078793          	addi	a5,a5,-16
   10d90:	008787b3          	add	a5,a5,s0
   10d94:	f807c783          	lbu	a5,-128(a5)
   10d98:	0007871b          	sext.w	a4,a5
   10d9c:	f5843783          	ld	a5,-168(s0)
   10da0:	00070513          	mv	a0,a4
   10da4:	000780e7          	jalr	a5
   10da8:	fec42783          	lw	a5,-20(s0)
   10dac:	0017879b          	addiw	a5,a5,1
   10db0:	fef42623          	sw	a5,-20(s0)
   10db4:	fd042783          	lw	a5,-48(s0)
   10db8:	fff7879b          	addiw	a5,a5,-1
   10dbc:	fcf42823          	sw	a5,-48(s0)
   10dc0:	fd042783          	lw	a5,-48(s0)
   10dc4:	0007879b          	sext.w	a5,a5
   10dc8:	fc07d0e3          	bgez	a5,10d88 <vprintfmt+0x510>
   10dcc:	f8040023          	sb	zero,-128(s0)
   10dd0:	2780006f          	j	11048 <vprintfmt+0x7d0>
   10dd4:	f5043783          	ld	a5,-176(s0)
   10dd8:	0007c783          	lbu	a5,0(a5)
   10ddc:	00078713          	mv	a4,a5
   10de0:	06400793          	li	a5,100
   10de4:	02f70663          	beq	a4,a5,10e10 <vprintfmt+0x598>
   10de8:	f5043783          	ld	a5,-176(s0)
   10dec:	0007c783          	lbu	a5,0(a5)
   10df0:	00078713          	mv	a4,a5
   10df4:	06900793          	li	a5,105
   10df8:	00f70c63          	beq	a4,a5,10e10 <vprintfmt+0x598>
   10dfc:	f5043783          	ld	a5,-176(s0)
   10e00:	0007c783          	lbu	a5,0(a5)
   10e04:	00078713          	mv	a4,a5
   10e08:	07500793          	li	a5,117
   10e0c:	08f71263          	bne	a4,a5,10e90 <vprintfmt+0x618>
   10e10:	f8144783          	lbu	a5,-127(s0)
   10e14:	00078c63          	beqz	a5,10e2c <vprintfmt+0x5b4>
   10e18:	f4843783          	ld	a5,-184(s0)
   10e1c:	00878713          	addi	a4,a5,8
   10e20:	f4e43423          	sd	a4,-184(s0)
   10e24:	0007b783          	ld	a5,0(a5)
   10e28:	0140006f          	j	10e3c <vprintfmt+0x5c4>
   10e2c:	f4843783          	ld	a5,-184(s0)
   10e30:	00878713          	addi	a4,a5,8
   10e34:	f4e43423          	sd	a4,-184(s0)
   10e38:	0007a783          	lw	a5,0(a5)
   10e3c:	faf43423          	sd	a5,-88(s0)
   10e40:	fa843583          	ld	a1,-88(s0)
   10e44:	f5043783          	ld	a5,-176(s0)
   10e48:	0007c783          	lbu	a5,0(a5)
   10e4c:	0007871b          	sext.w	a4,a5
   10e50:	07500793          	li	a5,117
   10e54:	40f707b3          	sub	a5,a4,a5
   10e58:	00f037b3          	snez	a5,a5
   10e5c:	0ff7f793          	zext.b	a5,a5
   10e60:	f8040713          	addi	a4,s0,-128
   10e64:	00070693          	mv	a3,a4
   10e68:	00078613          	mv	a2,a5
   10e6c:	f5843503          	ld	a0,-168(s0)
   10e70:	fffff097          	auipc	ra,0xfffff
   10e74:	6fc080e7          	jalr	1788(ra) # 1056c <print_dec_int>
   10e78:	00050793          	mv	a5,a0
   10e7c:	fec42703          	lw	a4,-20(s0)
   10e80:	00f707bb          	addw	a5,a4,a5
   10e84:	fef42623          	sw	a5,-20(s0)
   10e88:	f8040023          	sb	zero,-128(s0)
   10e8c:	1bc0006f          	j	11048 <vprintfmt+0x7d0>
   10e90:	f5043783          	ld	a5,-176(s0)
   10e94:	0007c783          	lbu	a5,0(a5)
   10e98:	00078713          	mv	a4,a5
   10e9c:	06e00793          	li	a5,110
   10ea0:	04f71c63          	bne	a4,a5,10ef8 <vprintfmt+0x680>
   10ea4:	f8144783          	lbu	a5,-127(s0)
   10ea8:	02078463          	beqz	a5,10ed0 <vprintfmt+0x658>
   10eac:	f4843783          	ld	a5,-184(s0)
   10eb0:	00878713          	addi	a4,a5,8
   10eb4:	f4e43423          	sd	a4,-184(s0)
   10eb8:	0007b783          	ld	a5,0(a5)
   10ebc:	faf43823          	sd	a5,-80(s0)
   10ec0:	fec42703          	lw	a4,-20(s0)
   10ec4:	fb043783          	ld	a5,-80(s0)
   10ec8:	00e7b023          	sd	a4,0(a5)
   10ecc:	0240006f          	j	10ef0 <vprintfmt+0x678>
   10ed0:	f4843783          	ld	a5,-184(s0)
   10ed4:	00878713          	addi	a4,a5,8
   10ed8:	f4e43423          	sd	a4,-184(s0)
   10edc:	0007b783          	ld	a5,0(a5)
   10ee0:	faf43c23          	sd	a5,-72(s0)
   10ee4:	fb843783          	ld	a5,-72(s0)
   10ee8:	fec42703          	lw	a4,-20(s0)
   10eec:	00e7a023          	sw	a4,0(a5)
   10ef0:	f8040023          	sb	zero,-128(s0)
   10ef4:	1540006f          	j	11048 <vprintfmt+0x7d0>
   10ef8:	f5043783          	ld	a5,-176(s0)
   10efc:	0007c783          	lbu	a5,0(a5)
   10f00:	00078713          	mv	a4,a5
   10f04:	07300793          	li	a5,115
   10f08:	04f71063          	bne	a4,a5,10f48 <vprintfmt+0x6d0>
   10f0c:	f4843783          	ld	a5,-184(s0)
   10f10:	00878713          	addi	a4,a5,8
   10f14:	f4e43423          	sd	a4,-184(s0)
   10f18:	0007b783          	ld	a5,0(a5)
   10f1c:	fcf43023          	sd	a5,-64(s0)
   10f20:	fc043583          	ld	a1,-64(s0)
   10f24:	f5843503          	ld	a0,-168(s0)
   10f28:	fffff097          	auipc	ra,0xfffff
   10f2c:	5bc080e7          	jalr	1468(ra) # 104e4 <puts_wo_nl>
   10f30:	00050793          	mv	a5,a0
   10f34:	fec42703          	lw	a4,-20(s0)
   10f38:	00f707bb          	addw	a5,a4,a5
   10f3c:	fef42623          	sw	a5,-20(s0)
   10f40:	f8040023          	sb	zero,-128(s0)
   10f44:	1040006f          	j	11048 <vprintfmt+0x7d0>
   10f48:	f5043783          	ld	a5,-176(s0)
   10f4c:	0007c783          	lbu	a5,0(a5)
   10f50:	00078713          	mv	a4,a5
   10f54:	06300793          	li	a5,99
   10f58:	02f71e63          	bne	a4,a5,10f94 <vprintfmt+0x71c>
   10f5c:	f4843783          	ld	a5,-184(s0)
   10f60:	00878713          	addi	a4,a5,8
   10f64:	f4e43423          	sd	a4,-184(s0)
   10f68:	0007a783          	lw	a5,0(a5)
   10f6c:	fcf42623          	sw	a5,-52(s0)
   10f70:	fcc42703          	lw	a4,-52(s0)
   10f74:	f5843783          	ld	a5,-168(s0)
   10f78:	00070513          	mv	a0,a4
   10f7c:	000780e7          	jalr	a5
   10f80:	fec42783          	lw	a5,-20(s0)
   10f84:	0017879b          	addiw	a5,a5,1
   10f88:	fef42623          	sw	a5,-20(s0)
   10f8c:	f8040023          	sb	zero,-128(s0)
   10f90:	0b80006f          	j	11048 <vprintfmt+0x7d0>
   10f94:	f5043783          	ld	a5,-176(s0)
   10f98:	0007c783          	lbu	a5,0(a5)
   10f9c:	00078713          	mv	a4,a5
   10fa0:	02500793          	li	a5,37
   10fa4:	02f71263          	bne	a4,a5,10fc8 <vprintfmt+0x750>
   10fa8:	f5843783          	ld	a5,-168(s0)
   10fac:	02500513          	li	a0,37
   10fb0:	000780e7          	jalr	a5
   10fb4:	fec42783          	lw	a5,-20(s0)
   10fb8:	0017879b          	addiw	a5,a5,1
   10fbc:	fef42623          	sw	a5,-20(s0)
   10fc0:	f8040023          	sb	zero,-128(s0)
   10fc4:	0840006f          	j	11048 <vprintfmt+0x7d0>
   10fc8:	f5043783          	ld	a5,-176(s0)
   10fcc:	0007c783          	lbu	a5,0(a5)
   10fd0:	0007871b          	sext.w	a4,a5
   10fd4:	f5843783          	ld	a5,-168(s0)
   10fd8:	00070513          	mv	a0,a4
   10fdc:	000780e7          	jalr	a5
   10fe0:	fec42783          	lw	a5,-20(s0)
   10fe4:	0017879b          	addiw	a5,a5,1
   10fe8:	fef42623          	sw	a5,-20(s0)
   10fec:	f8040023          	sb	zero,-128(s0)
   10ff0:	0580006f          	j	11048 <vprintfmt+0x7d0>
   10ff4:	f5043783          	ld	a5,-176(s0)
   10ff8:	0007c783          	lbu	a5,0(a5)
   10ffc:	00078713          	mv	a4,a5
   11000:	02500793          	li	a5,37
   11004:	02f71063          	bne	a4,a5,11024 <vprintfmt+0x7ac>
   11008:	f8043023          	sd	zero,-128(s0)
   1100c:	f8043423          	sd	zero,-120(s0)
   11010:	00100793          	li	a5,1
   11014:	f8f40023          	sb	a5,-128(s0)
   11018:	fff00793          	li	a5,-1
   1101c:	f8f42623          	sw	a5,-116(s0)
   11020:	0280006f          	j	11048 <vprintfmt+0x7d0>
   11024:	f5043783          	ld	a5,-176(s0)
   11028:	0007c783          	lbu	a5,0(a5)
   1102c:	0007871b          	sext.w	a4,a5
   11030:	f5843783          	ld	a5,-168(s0)
   11034:	00070513          	mv	a0,a4
   11038:	000780e7          	jalr	a5
   1103c:	fec42783          	lw	a5,-20(s0)
   11040:	0017879b          	addiw	a5,a5,1
   11044:	fef42623          	sw	a5,-20(s0)
   11048:	f5043783          	ld	a5,-176(s0)
   1104c:	00178793          	addi	a5,a5,1
   11050:	f4f43823          	sd	a5,-176(s0)
   11054:	f5043783          	ld	a5,-176(s0)
   11058:	0007c783          	lbu	a5,0(a5)
   1105c:	840794e3          	bnez	a5,108a4 <vprintfmt+0x2c>
   11060:	fec42783          	lw	a5,-20(s0)
   11064:	00078513          	mv	a0,a5
   11068:	0b813083          	ld	ra,184(sp)
   1106c:	0b013403          	ld	s0,176(sp)
   11070:	0c010113          	addi	sp,sp,192
   11074:	00008067          	ret

0000000000011078 <printf>:
   11078:	f8010113          	addi	sp,sp,-128
   1107c:	02113c23          	sd	ra,56(sp)
   11080:	02813823          	sd	s0,48(sp)
   11084:	04010413          	addi	s0,sp,64
   11088:	fca43423          	sd	a0,-56(s0)
   1108c:	00b43423          	sd	a1,8(s0)
   11090:	00c43823          	sd	a2,16(s0)
   11094:	00d43c23          	sd	a3,24(s0)
   11098:	02e43023          	sd	a4,32(s0)
   1109c:	02f43423          	sd	a5,40(s0)
   110a0:	03043823          	sd	a6,48(s0)
   110a4:	03143c23          	sd	a7,56(s0)
   110a8:	fe042623          	sw	zero,-20(s0)
   110ac:	04040793          	addi	a5,s0,64
   110b0:	fcf43023          	sd	a5,-64(s0)
   110b4:	fc043783          	ld	a5,-64(s0)
   110b8:	fc878793          	addi	a5,a5,-56
   110bc:	fcf43823          	sd	a5,-48(s0)
   110c0:	fd043783          	ld	a5,-48(s0)
   110c4:	00078613          	mv	a2,a5
   110c8:	fc843583          	ld	a1,-56(s0)
   110cc:	fffff517          	auipc	a0,0xfffff
   110d0:	0e050513          	addi	a0,a0,224 # 101ac <putc>
   110d4:	fffff097          	auipc	ra,0xfffff
   110d8:	7a4080e7          	jalr	1956(ra) # 10878 <vprintfmt>
   110dc:	00050793          	mv	a5,a0
   110e0:	fef42623          	sw	a5,-20(s0)
   110e4:	00100793          	li	a5,1
   110e8:	fef43023          	sd	a5,-32(s0)
   110ec:	00001797          	auipc	a5,0x1
   110f0:	f1878793          	addi	a5,a5,-232 # 12004 <tail>
   110f4:	0007a783          	lw	a5,0(a5)
   110f8:	0017871b          	addiw	a4,a5,1
   110fc:	0007069b          	sext.w	a3,a4
   11100:	00001717          	auipc	a4,0x1
   11104:	f0470713          	addi	a4,a4,-252 # 12004 <tail>
   11108:	00d72023          	sw	a3,0(a4)
   1110c:	00001717          	auipc	a4,0x1
   11110:	efc70713          	addi	a4,a4,-260 # 12008 <buffer>
   11114:	00f707b3          	add	a5,a4,a5
   11118:	00078023          	sb	zero,0(a5)
   1111c:	00001797          	auipc	a5,0x1
   11120:	ee878793          	addi	a5,a5,-280 # 12004 <tail>
   11124:	0007a603          	lw	a2,0(a5)
   11128:	fe043703          	ld	a4,-32(s0)
   1112c:	00001697          	auipc	a3,0x1
   11130:	edc68693          	addi	a3,a3,-292 # 12008 <buffer>
   11134:	fd843783          	ld	a5,-40(s0)
   11138:	04000893          	li	a7,64
   1113c:	00070513          	mv	a0,a4
   11140:	00068593          	mv	a1,a3
   11144:	00060613          	mv	a2,a2
   11148:	00000073          	ecall
   1114c:	00050793          	mv	a5,a0
   11150:	fcf43c23          	sd	a5,-40(s0)
   11154:	00001797          	auipc	a5,0x1
   11158:	eb078793          	addi	a5,a5,-336 # 12004 <tail>
   1115c:	0007a023          	sw	zero,0(a5)
   11160:	fec42783          	lw	a5,-20(s0)
   11164:	00078513          	mv	a0,a5
   11168:	03813083          	ld	ra,56(sp)
   1116c:	03013403          	ld	s0,48(sp)
   11170:	08010113          	addi	sp,sp,128
   11174:	00008067          	ret
