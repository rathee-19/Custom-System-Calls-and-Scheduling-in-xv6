
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	bc813103          	ld	sp,-1080(sp) # 80008bc8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	bd070713          	addi	a4,a4,-1072 # 80008c20 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	77e78793          	addi	a5,a5,1918 # 800067e0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdba71f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	f0c78793          	addi	a5,a5,-244 # 80000fb8 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
  {
    char c;
    if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	9b4080e7          	jalr	-1612(ra) # 80002ade <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	bd650513          	addi	a0,a0,-1066 # 80010d60 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	b84080e7          	jalr	-1148(ra) # 80000d16 <acquire>
  while (n > 0)
  {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	bc648493          	addi	s1,s1,-1082 # 80010d60 <cons>
      if (killed(myproc()))
      {
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	c5690913          	addi	s2,s2,-938 # 80010df8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if (c == C('D'))
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if (c == '\n')
    800001ae:	4ca9                	li	s9,10
  while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	9a0080e7          	jalr	-1632(ra) # 80001b60 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	760080e7          	jalr	1888(ra) # 80002928 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	2c0080e7          	jalr	704(ra) # 80002496 <sleep>
    while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00003097          	auipc	ra,0x3
    80000216:	876080e7          	jalr	-1930(ra) # 80002a88 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	b3a50513          	addi	a0,a0,-1222 # 80010d60 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	b9c080e7          	jalr	-1124(ra) # 80000dca <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	b2450513          	addi	a0,a0,-1244 # 80010d60 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	b86080e7          	jalr	-1146(ra) # 80000dca <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	b8f72323          	sw	a5,-1146(a4) # 80010df8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	a9450513          	addi	a0,a0,-1388 # 80010d60 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	a42080e7          	jalr	-1470(ra) # 80000d16 <acquire>

  switch (c)
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  {
  case C('P'): // Print process list.
    procdump();
    800002f2:	00003097          	auipc	ra,0x3
    800002f6:	842080e7          	jalr	-1982(ra) # 80002b34 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	a6650513          	addi	a0,a0,-1434 # 80010d60 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	ac8080e7          	jalr	-1336(ra) # 80000dca <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch (c)
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	a4270713          	addi	a4,a4,-1470 # 80010d60 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	a1878793          	addi	a5,a5,-1512 # 80010d60 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	a827a783          	lw	a5,-1406(a5) # 80010df8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	9d670713          	addi	a4,a4,-1578 # 80010d60 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	9c648493          	addi	s1,s1,-1594 # 80010d60 <cons>
    while (cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while (cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if (cons.e != cons.w)
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	98a70713          	addi	a4,a4,-1654 # 80010d60 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	a0f72a23          	sw	a5,-1516(a4) # 80010e00 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	94e78793          	addi	a5,a5,-1714 # 80010d60 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	9cc7a323          	sw	a2,-1594(a5) # 80010dfc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	9ba50513          	addi	a0,a0,-1606 # 80010df8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	204080e7          	jalr	516(ra) # 8000264a <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	90050513          	addi	a0,a0,-1792 # 80010d60 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	81e080e7          	jalr	-2018(ra) # 80000c86 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00243797          	auipc	a5,0x243
    8000047c:	ad078793          	addi	a5,a5,-1328 # 80242f48 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00011797          	auipc	a5,0x11
    80000550:	8c07aa23          	sw	zero,-1836(a5) # 80010e20 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b9a50513          	addi	a0,a0,-1126 # 80008108 <digits+0xc8>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	66f72023          	sw	a5,1632(a4) # 80008be0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00011d97          	auipc	s11,0x11
    800005c0:	864dad83          	lw	s11,-1948(s11) # 80010e20 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00011517          	auipc	a0,0x11
    800005fe:	80e50513          	addi	a0,a0,-2034 # 80010e08 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	714080e7          	jalr	1812(ra) # 80000d16 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	6b050513          	addi	a0,a0,1712 # 80010e08 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	66a080e7          	jalr	1642(ra) # 80000dca <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	69448493          	addi	s1,s1,1684 # 80010e08 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	500080e7          	jalr	1280(ra) # 80000c86 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	65450513          	addi	a0,a0,1620 # 80010e28 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	4aa080e7          	jalr	1194(ra) # 80000c86 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	4d2080e7          	jalr	1234(ra) # 80000cca <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	3e07a783          	lw	a5,992(a5) # 80008be0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	544080e7          	jalr	1348(ra) # 80000d6a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	3b07b783          	ld	a5,944(a5) # 80008be8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	3b073703          	ld	a4,944(a4) # 80008bf0 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	5c6a0a13          	addi	s4,s4,1478 # 80010e28 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	37e48493          	addi	s1,s1,894 # 80008be8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	37e98993          	addi	s3,s3,894 # 80008bf0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	db6080e7          	jalr	-586(ra) # 8000264a <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	55850513          	addi	a0,a0,1368 # 80010e28 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	43e080e7          	jalr	1086(ra) # 80000d16 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	3007a783          	lw	a5,768(a5) # 80008be0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	30673703          	ld	a4,774(a4) # 80008bf0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	2f67b783          	ld	a5,758(a5) # 80008be8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	52a98993          	addi	s3,s3,1322 # 80010e28 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	2e248493          	addi	s1,s1,738 # 80008be8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	2e290913          	addi	s2,s2,738 # 80008bf0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	b78080e7          	jalr	-1160(ra) # 80002496 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	4f448493          	addi	s1,s1,1268 # 80010e28 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	2ae7b423          	sd	a4,680(a5) # 80008bf0 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	470080e7          	jalr	1136(ra) # 80000dca <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	46e48493          	addi	s1,s1,1134 # 80010e28 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	352080e7          	jalr	850(ra) # 80000d16 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	3f4080e7          	jalr	1012(ra) # 80000dca <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <incref>:
    refcount[(uint64)p/4096]=1;
    kfree(p);
  }
}

void incref(uint64 pa){
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
    800009f4:	892a                	mv	s2,a0
  int pagenumber=pa/PGSIZE;
    800009f6:	00c55493          	srli	s1,a0,0xc
  acquire(&kmem.lock);
    800009fa:	00010517          	auipc	a0,0x10
    800009fe:	46650513          	addi	a0,a0,1126 # 80010e60 <kmem>
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	314080e7          	jalr	788(ra) # 80000d16 <acquire>
  if(pa>=PHYSTOP || refcount[pagenumber]<1)
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f97363          	bgeu	s2,a5,80000a54 <incref+0x6c>
    80000a12:	2481                	sext.w	s1,s1
    80000a14:	00249713          	slli	a4,s1,0x2
    80000a18:	00010797          	auipc	a5,0x10
    80000a1c:	46878793          	addi	a5,a5,1128 # 80010e80 <refcount>
    80000a20:	97ba                	add	a5,a5,a4
    80000a22:	439c                	lw	a5,0(a5)
    80000a24:	02f05863          	blez	a5,80000a54 <incref+0x6c>
    panic("incref");
  refcount[pagenumber]+=1; 
    80000a28:	048a                	slli	s1,s1,0x2
    80000a2a:	00010717          	auipc	a4,0x10
    80000a2e:	45670713          	addi	a4,a4,1110 # 80010e80 <refcount>
    80000a32:	9726                	add	a4,a4,s1
    80000a34:	2785                	addiw	a5,a5,1
    80000a36:	c31c                	sw	a5,0(a4)
  release(&kmem.lock);
    80000a38:	00010517          	auipc	a0,0x10
    80000a3c:	42850513          	addi	a0,a0,1064 # 80010e60 <kmem>
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	38a080e7          	jalr	906(ra) # 80000dca <release>
}
    80000a48:	60e2                	ld	ra,24(sp)
    80000a4a:	6442                	ld	s0,16(sp)
    80000a4c:	64a2                	ld	s1,8(sp)
    80000a4e:	6902                	ld	s2,0(sp)
    80000a50:	6105                	addi	sp,sp,32
    80000a52:	8082                	ret
    panic("incref");
    80000a54:	00007517          	auipc	a0,0x7
    80000a58:	60c50513          	addi	a0,a0,1548 # 80008060 <digits+0x20>
    80000a5c:	00000097          	auipc	ra,0x0
    80000a60:	ae4080e7          	jalr	-1308(ra) # 80000540 <panic>

0000000080000a64 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a64:	1101                	addi	sp,sp,-32
    80000a66:	ec06                	sd	ra,24(sp)
    80000a68:	e822                	sd	s0,16(sp)
    80000a6a:	e426                	sd	s1,8(sp)
    80000a6c:	e04a                	sd	s2,0(sp)
    80000a6e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a70:	03451793          	slli	a5,a0,0x34
    80000a74:	ebbd                	bnez	a5,80000aea <kfree+0x86>
    80000a76:	84aa                	mv	s1,a0
    80000a78:	00243797          	auipc	a5,0x243
    80000a7c:	66878793          	addi	a5,a5,1640 # 802440e0 <end>
    80000a80:	06f56563          	bltu	a0,a5,80000aea <kfree+0x86>
    80000a84:	47c5                	li	a5,17
    80000a86:	07ee                	slli	a5,a5,0x1b
    80000a88:	06f57163          	bgeu	a0,a5,80000aea <kfree+0x86>
    panic("kfree");

  // Need to acquire lock for decrementing refs
  acquire(&kmem.lock);
    80000a8c:	00010517          	auipc	a0,0x10
    80000a90:	3d450513          	addi	a0,a0,980 # 80010e60 <kmem>
    80000a94:	00000097          	auipc	ra,0x0
    80000a98:	282080e7          	jalr	642(ra) # 80000d16 <acquire>
  int pagenumber=(uint64)pa/PGSIZE;
    80000a9c:	00c4d793          	srli	a5,s1,0xc
    80000aa0:	2781                	sext.w	a5,a5
  if(refcount[pagenumber]<1)
    80000aa2:	00279693          	slli	a3,a5,0x2
    80000aa6:	00010717          	auipc	a4,0x10
    80000aaa:	3da70713          	addi	a4,a4,986 # 80010e80 <refcount>
    80000aae:	9736                	add	a4,a4,a3
    80000ab0:	4318                	lw	a4,0(a4)
    80000ab2:	04e05463          	blez	a4,80000afa <kfree+0x96>
    panic("Kfree ref");
  refcount[pagenumber]-=1;
    80000ab6:	377d                	addiw	a4,a4,-1
    80000ab8:	0007091b          	sext.w	s2,a4
    80000abc:	078a                	slli	a5,a5,0x2
    80000abe:	00010697          	auipc	a3,0x10
    80000ac2:	3c268693          	addi	a3,a3,962 # 80010e80 <refcount>
    80000ac6:	97b6                	add	a5,a5,a3
    80000ac8:	c398                	sw	a4,0(a5)
  int tmp=refcount[pagenumber];
  release(&kmem.lock);
    80000aca:	00010517          	auipc	a0,0x10
    80000ace:	39650513          	addi	a0,a0,918 # 80010e60 <kmem>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	2f8080e7          	jalr	760(ra) # 80000dca <release>

  if(tmp>0) // NO need to free the page
    80000ada:	03205863          	blez	s2,80000b0a <kfree+0xa6>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000ade:	60e2                	ld	ra,24(sp)
    80000ae0:	6442                	ld	s0,16(sp)
    80000ae2:	64a2                	ld	s1,8(sp)
    80000ae4:	6902                	ld	s2,0(sp)
    80000ae6:	6105                	addi	sp,sp,32
    80000ae8:	8082                	ret
    panic("kfree");
    80000aea:	00007517          	auipc	a0,0x7
    80000aee:	57e50513          	addi	a0,a0,1406 # 80008068 <digits+0x28>
    80000af2:	00000097          	auipc	ra,0x0
    80000af6:	a4e080e7          	jalr	-1458(ra) # 80000540 <panic>
    panic("Kfree ref");
    80000afa:	00007517          	auipc	a0,0x7
    80000afe:	57650513          	addi	a0,a0,1398 # 80008070 <digits+0x30>
    80000b02:	00000097          	auipc	ra,0x0
    80000b06:	a3e080e7          	jalr	-1474(ra) # 80000540 <panic>
  memset(pa, 1, PGSIZE);
    80000b0a:	6605                	lui	a2,0x1
    80000b0c:	4585                	li	a1,1
    80000b0e:	8526                	mv	a0,s1
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	302080e7          	jalr	770(ra) # 80000e12 <memset>
  acquire(&kmem.lock);
    80000b18:	00010917          	auipc	s2,0x10
    80000b1c:	34890913          	addi	s2,s2,840 # 80010e60 <kmem>
    80000b20:	854a                	mv	a0,s2
    80000b22:	00000097          	auipc	ra,0x0
    80000b26:	1f4080e7          	jalr	500(ra) # 80000d16 <acquire>
  r->next = kmem.freelist;
    80000b2a:	01893783          	ld	a5,24(s2)
    80000b2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000b30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000b34:	854a                	mv	a0,s2
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	294080e7          	jalr	660(ra) # 80000dca <release>
    80000b3e:	b745                	j	80000ade <kfree+0x7a>

0000000080000b40 <freerange>:
{
    80000b40:	7139                	addi	sp,sp,-64
    80000b42:	fc06                	sd	ra,56(sp)
    80000b44:	f822                	sd	s0,48(sp)
    80000b46:	f426                	sd	s1,40(sp)
    80000b48:	f04a                	sd	s2,32(sp)
    80000b4a:	ec4e                	sd	s3,24(sp)
    80000b4c:	e852                	sd	s4,16(sp)
    80000b4e:	e456                	sd	s5,8(sp)
    80000b50:	e05a                	sd	s6,0(sp)
    80000b52:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b54:	6785                	lui	a5,0x1
    80000b56:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b5a:	953a                	add	a0,a0,a4
    80000b5c:	777d                	lui	a4,0xfffff
    80000b5e:	00e574b3          	and	s1,a0,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b62:	97a6                	add	a5,a5,s1
    80000b64:	02f5ea63          	bltu	a1,a5,80000b98 <freerange+0x58>
    80000b68:	892e                	mv	s2,a1
    refcount[(uint64)p/4096]=1;
    80000b6a:	00010b17          	auipc	s6,0x10
    80000b6e:	316b0b13          	addi	s6,s6,790 # 80010e80 <refcount>
    80000b72:	4a85                	li	s5,1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b74:	6a05                	lui	s4,0x1
    80000b76:	6989                	lui	s3,0x2
    refcount[(uint64)p/4096]=1;
    80000b78:	00c4d793          	srli	a5,s1,0xc
    80000b7c:	078a                	slli	a5,a5,0x2
    80000b7e:	97da                	add	a5,a5,s6
    80000b80:	0157a023          	sw	s5,0(a5)
    kfree(p);
    80000b84:	8526                	mv	a0,s1
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	ede080e7          	jalr	-290(ra) # 80000a64 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b8e:	87a6                	mv	a5,s1
    80000b90:	94d2                	add	s1,s1,s4
    80000b92:	97ce                	add	a5,a5,s3
    80000b94:	fef972e3          	bgeu	s2,a5,80000b78 <freerange+0x38>
}
    80000b98:	70e2                	ld	ra,56(sp)
    80000b9a:	7442                	ld	s0,48(sp)
    80000b9c:	74a2                	ld	s1,40(sp)
    80000b9e:	7902                	ld	s2,32(sp)
    80000ba0:	69e2                	ld	s3,24(sp)
    80000ba2:	6a42                	ld	s4,16(sp)
    80000ba4:	6aa2                	ld	s5,8(sp)
    80000ba6:	6b02                	ld	s6,0(sp)
    80000ba8:	6121                	addi	sp,sp,64
    80000baa:	8082                	ret

0000000080000bac <kinit>:
{
    80000bac:	1141                	addi	sp,sp,-16
    80000bae:	e406                	sd	ra,8(sp)
    80000bb0:	e022                	sd	s0,0(sp)
    80000bb2:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000bb4:	00007597          	auipc	a1,0x7
    80000bb8:	4cc58593          	addi	a1,a1,1228 # 80008080 <digits+0x40>
    80000bbc:	00010517          	auipc	a0,0x10
    80000bc0:	2a450513          	addi	a0,a0,676 # 80010e60 <kmem>
    80000bc4:	00000097          	auipc	ra,0x0
    80000bc8:	0c2080e7          	jalr	194(ra) # 80000c86 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bcc:	45c5                	li	a1,17
    80000bce:	05ee                	slli	a1,a1,0x1b
    80000bd0:	00243517          	auipc	a0,0x243
    80000bd4:	51050513          	addi	a0,a0,1296 # 802440e0 <end>
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f68080e7          	jalr	-152(ra) # 80000b40 <freerange>
}
    80000be0:	60a2                	ld	ra,8(sp)
    80000be2:	6402                	ld	s0,0(sp)
    80000be4:	0141                	addi	sp,sp,16
    80000be6:	8082                	ret

0000000080000be8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000be8:	1101                	addi	sp,sp,-32
    80000bea:	ec06                	sd	ra,24(sp)
    80000bec:	e822                	sd	s0,16(sp)
    80000bee:	e426                	sd	s1,8(sp)
    80000bf0:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000bf2:	00010497          	auipc	s1,0x10
    80000bf6:	26e48493          	addi	s1,s1,622 # 80010e60 <kmem>
    80000bfa:	8526                	mv	a0,s1
    80000bfc:	00000097          	auipc	ra,0x0
    80000c00:	11a080e7          	jalr	282(ra) # 80000d16 <acquire>
  r = kmem.freelist;
    80000c04:	6c84                	ld	s1,24(s1)
  if(r){
    80000c06:	c4bd                	beqz	s1,80000c74 <kalloc+0x8c>
    kmem.freelist = r->next;
    80000c08:	609c                	ld	a5,0(s1)
    80000c0a:	00010717          	auipc	a4,0x10
    80000c0e:	26f73723          	sd	a5,622(a4) # 80010e78 <kmem+0x18>
    int pagenumber = (uint64)r/PGSIZE; // finding page number
    80000c12:	00c4d793          	srli	a5,s1,0xc
    80000c16:	2781                	sext.w	a5,a5
    if(refcount[pagenumber]!=0)
    80000c18:	00279693          	slli	a3,a5,0x2
    80000c1c:	00010717          	auipc	a4,0x10
    80000c20:	26470713          	addi	a4,a4,612 # 80010e80 <refcount>
    80000c24:	9736                	add	a4,a4,a3
    80000c26:	4318                	lw	a4,0(a4)
    80000c28:	ef15                	bnez	a4,80000c64 <kalloc+0x7c>
      panic("HOW is a new page already referenced");
    refcount[pagenumber]=1; // initialising ref to 1
    80000c2a:	078a                	slli	a5,a5,0x2
    80000c2c:	00010717          	auipc	a4,0x10
    80000c30:	25470713          	addi	a4,a4,596 # 80010e80 <refcount>
    80000c34:	97ba                	add	a5,a5,a4
    80000c36:	4705                	li	a4,1
    80000c38:	c398                	sw	a4,0(a5)
  }
  release(&kmem.lock);
    80000c3a:	00010517          	auipc	a0,0x10
    80000c3e:	22650513          	addi	a0,a0,550 # 80010e60 <kmem>
    80000c42:	00000097          	auipc	ra,0x0
    80000c46:	188080e7          	jalr	392(ra) # 80000dca <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c4a:	6605                	lui	a2,0x1
    80000c4c:	4595                	li	a1,5
    80000c4e:	8526                	mv	a0,s1
    80000c50:	00000097          	auipc	ra,0x0
    80000c54:	1c2080e7          	jalr	450(ra) # 80000e12 <memset>
  return (void*)r;
}
    80000c58:	8526                	mv	a0,s1
    80000c5a:	60e2                	ld	ra,24(sp)
    80000c5c:	6442                	ld	s0,16(sp)
    80000c5e:	64a2                	ld	s1,8(sp)
    80000c60:	6105                	addi	sp,sp,32
    80000c62:	8082                	ret
      panic("HOW is a new page already referenced");
    80000c64:	00007517          	auipc	a0,0x7
    80000c68:	42450513          	addi	a0,a0,1060 # 80008088 <digits+0x48>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	8d4080e7          	jalr	-1836(ra) # 80000540 <panic>
  release(&kmem.lock);
    80000c74:	00010517          	auipc	a0,0x10
    80000c78:	1ec50513          	addi	a0,a0,492 # 80010e60 <kmem>
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	14e080e7          	jalr	334(ra) # 80000dca <release>
  if(r)
    80000c84:	bfd1                	j	80000c58 <kalloc+0x70>

0000000080000c86 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c86:	1141                	addi	sp,sp,-16
    80000c88:	e422                	sd	s0,8(sp)
    80000c8a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c8c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c8e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c92:	00053823          	sd	zero,16(a0)
}
    80000c96:	6422                	ld	s0,8(sp)
    80000c98:	0141                	addi	sp,sp,16
    80000c9a:	8082                	ret

0000000080000c9c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c9c:	411c                	lw	a5,0(a0)
    80000c9e:	e399                	bnez	a5,80000ca4 <holding+0x8>
    80000ca0:	4501                	li	a0,0
  return r;
}
    80000ca2:	8082                	ret
{
    80000ca4:	1101                	addi	sp,sp,-32
    80000ca6:	ec06                	sd	ra,24(sp)
    80000ca8:	e822                	sd	s0,16(sp)
    80000caa:	e426                	sd	s1,8(sp)
    80000cac:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000cae:	6904                	ld	s1,16(a0)
    80000cb0:	00001097          	auipc	ra,0x1
    80000cb4:	e94080e7          	jalr	-364(ra) # 80001b44 <mycpu>
    80000cb8:	40a48533          	sub	a0,s1,a0
    80000cbc:	00153513          	seqz	a0,a0
}
    80000cc0:	60e2                	ld	ra,24(sp)
    80000cc2:	6442                	ld	s0,16(sp)
    80000cc4:	64a2                	ld	s1,8(sp)
    80000cc6:	6105                	addi	sp,sp,32
    80000cc8:	8082                	ret

0000000080000cca <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cca:	1101                	addi	sp,sp,-32
    80000ccc:	ec06                	sd	ra,24(sp)
    80000cce:	e822                	sd	s0,16(sp)
    80000cd0:	e426                	sd	s1,8(sp)
    80000cd2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd4:	100024f3          	csrr	s1,sstatus
    80000cd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cdc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cde:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ce2:	00001097          	auipc	ra,0x1
    80000ce6:	e62080e7          	jalr	-414(ra) # 80001b44 <mycpu>
    80000cea:	5d3c                	lw	a5,120(a0)
    80000cec:	cf89                	beqz	a5,80000d06 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cee:	00001097          	auipc	ra,0x1
    80000cf2:	e56080e7          	jalr	-426(ra) # 80001b44 <mycpu>
    80000cf6:	5d3c                	lw	a5,120(a0)
    80000cf8:	2785                	addiw	a5,a5,1
    80000cfa:	dd3c                	sw	a5,120(a0)
}
    80000cfc:	60e2                	ld	ra,24(sp)
    80000cfe:	6442                	ld	s0,16(sp)
    80000d00:	64a2                	ld	s1,8(sp)
    80000d02:	6105                	addi	sp,sp,32
    80000d04:	8082                	ret
    mycpu()->intena = old;
    80000d06:	00001097          	auipc	ra,0x1
    80000d0a:	e3e080e7          	jalr	-450(ra) # 80001b44 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d0e:	8085                	srli	s1,s1,0x1
    80000d10:	8885                	andi	s1,s1,1
    80000d12:	dd64                	sw	s1,124(a0)
    80000d14:	bfe9                	j	80000cee <push_off+0x24>

0000000080000d16 <acquire>:
{
    80000d16:	1101                	addi	sp,sp,-32
    80000d18:	ec06                	sd	ra,24(sp)
    80000d1a:	e822                	sd	s0,16(sp)
    80000d1c:	e426                	sd	s1,8(sp)
    80000d1e:	1000                	addi	s0,sp,32
    80000d20:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	fa8080e7          	jalr	-88(ra) # 80000cca <push_off>
  if(holding(lk))
    80000d2a:	8526                	mv	a0,s1
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	f70080e7          	jalr	-144(ra) # 80000c9c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d34:	4705                	li	a4,1
  if(holding(lk))
    80000d36:	e115                	bnez	a0,80000d5a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d38:	87ba                	mv	a5,a4
    80000d3a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d3e:	2781                	sext.w	a5,a5
    80000d40:	ffe5                	bnez	a5,80000d38 <acquire+0x22>
  __sync_synchronize();
    80000d42:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d46:	00001097          	auipc	ra,0x1
    80000d4a:	dfe080e7          	jalr	-514(ra) # 80001b44 <mycpu>
    80000d4e:	e888                	sd	a0,16(s1)
}
    80000d50:	60e2                	ld	ra,24(sp)
    80000d52:	6442                	ld	s0,16(sp)
    80000d54:	64a2                	ld	s1,8(sp)
    80000d56:	6105                	addi	sp,sp,32
    80000d58:	8082                	ret
    panic("acquire");
    80000d5a:	00007517          	auipc	a0,0x7
    80000d5e:	35650513          	addi	a0,a0,854 # 800080b0 <digits+0x70>
    80000d62:	fffff097          	auipc	ra,0xfffff
    80000d66:	7de080e7          	jalr	2014(ra) # 80000540 <panic>

0000000080000d6a <pop_off>:

void
pop_off(void)
{
    80000d6a:	1141                	addi	sp,sp,-16
    80000d6c:	e406                	sd	ra,8(sp)
    80000d6e:	e022                	sd	s0,0(sp)
    80000d70:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d72:	00001097          	auipc	ra,0x1
    80000d76:	dd2080e7          	jalr	-558(ra) # 80001b44 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d7a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d7e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d80:	e78d                	bnez	a5,80000daa <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d82:	5d3c                	lw	a5,120(a0)
    80000d84:	02f05b63          	blez	a5,80000dba <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d88:	37fd                	addiw	a5,a5,-1
    80000d8a:	0007871b          	sext.w	a4,a5
    80000d8e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d90:	eb09                	bnez	a4,80000da2 <pop_off+0x38>
    80000d92:	5d7c                	lw	a5,124(a0)
    80000d94:	c799                	beqz	a5,80000da2 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d9a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d9e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000da2:	60a2                	ld	ra,8(sp)
    80000da4:	6402                	ld	s0,0(sp)
    80000da6:	0141                	addi	sp,sp,16
    80000da8:	8082                	ret
    panic("pop_off - interruptible");
    80000daa:	00007517          	auipc	a0,0x7
    80000dae:	30e50513          	addi	a0,a0,782 # 800080b8 <digits+0x78>
    80000db2:	fffff097          	auipc	ra,0xfffff
    80000db6:	78e080e7          	jalr	1934(ra) # 80000540 <panic>
    panic("pop_off");
    80000dba:	00007517          	auipc	a0,0x7
    80000dbe:	31650513          	addi	a0,a0,790 # 800080d0 <digits+0x90>
    80000dc2:	fffff097          	auipc	ra,0xfffff
    80000dc6:	77e080e7          	jalr	1918(ra) # 80000540 <panic>

0000000080000dca <release>:
{
    80000dca:	1101                	addi	sp,sp,-32
    80000dcc:	ec06                	sd	ra,24(sp)
    80000dce:	e822                	sd	s0,16(sp)
    80000dd0:	e426                	sd	s1,8(sp)
    80000dd2:	1000                	addi	s0,sp,32
    80000dd4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dd6:	00000097          	auipc	ra,0x0
    80000dda:	ec6080e7          	jalr	-314(ra) # 80000c9c <holding>
    80000dde:	c115                	beqz	a0,80000e02 <release+0x38>
  lk->cpu = 0;
    80000de0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000de4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000de8:	0f50000f          	fence	iorw,ow
    80000dec:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000df0:	00000097          	auipc	ra,0x0
    80000df4:	f7a080e7          	jalr	-134(ra) # 80000d6a <pop_off>
}
    80000df8:	60e2                	ld	ra,24(sp)
    80000dfa:	6442                	ld	s0,16(sp)
    80000dfc:	64a2                	ld	s1,8(sp)
    80000dfe:	6105                	addi	sp,sp,32
    80000e00:	8082                	ret
    panic("release");
    80000e02:	00007517          	auipc	a0,0x7
    80000e06:	2d650513          	addi	a0,a0,726 # 800080d8 <digits+0x98>
    80000e0a:	fffff097          	auipc	ra,0xfffff
    80000e0e:	736080e7          	jalr	1846(ra) # 80000540 <panic>

0000000080000e12 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e18:	ca19                	beqz	a2,80000e2e <memset+0x1c>
    80000e1a:	87aa                	mv	a5,a0
    80000e1c:	1602                	slli	a2,a2,0x20
    80000e1e:	9201                	srli	a2,a2,0x20
    80000e20:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e24:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e28:	0785                	addi	a5,a5,1
    80000e2a:	fee79de3          	bne	a5,a4,80000e24 <memset+0x12>
  }
  return dst;
}
    80000e2e:	6422                	ld	s0,8(sp)
    80000e30:	0141                	addi	sp,sp,16
    80000e32:	8082                	ret

0000000080000e34 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e34:	1141                	addi	sp,sp,-16
    80000e36:	e422                	sd	s0,8(sp)
    80000e38:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e3a:	ca05                	beqz	a2,80000e6a <memcmp+0x36>
    80000e3c:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000e40:	1682                	slli	a3,a3,0x20
    80000e42:	9281                	srli	a3,a3,0x20
    80000e44:	0685                	addi	a3,a3,1
    80000e46:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	00e79863          	bne	a5,a4,80000e60 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e58:	fed518e3          	bne	a0,a3,80000e48 <memcmp+0x14>
  }

  return 0;
    80000e5c:	4501                	li	a0,0
    80000e5e:	a019                	j	80000e64 <memcmp+0x30>
      return *s1 - *s2;
    80000e60:	40e7853b          	subw	a0,a5,a4
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret
  return 0;
    80000e6a:	4501                	li	a0,0
    80000e6c:	bfe5                	j	80000e64 <memcmp+0x30>

0000000080000e6e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e6e:	1141                	addi	sp,sp,-16
    80000e70:	e422                	sd	s0,8(sp)
    80000e72:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e74:	c205                	beqz	a2,80000e94 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e76:	02a5e263          	bltu	a1,a0,80000e9a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e7a:	1602                	slli	a2,a2,0x20
    80000e7c:	9201                	srli	a2,a2,0x20
    80000e7e:	00c587b3          	add	a5,a1,a2
{
    80000e82:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e84:	0585                	addi	a1,a1,1
    80000e86:	0705                	addi	a4,a4,1
    80000e88:	fff5c683          	lbu	a3,-1(a1)
    80000e8c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e90:	fef59ae3          	bne	a1,a5,80000e84 <memmove+0x16>

  return dst;
}
    80000e94:	6422                	ld	s0,8(sp)
    80000e96:	0141                	addi	sp,sp,16
    80000e98:	8082                	ret
  if(s < d && s + n > d){
    80000e9a:	02061693          	slli	a3,a2,0x20
    80000e9e:	9281                	srli	a3,a3,0x20
    80000ea0:	00d58733          	add	a4,a1,a3
    80000ea4:	fce57be3          	bgeu	a0,a4,80000e7a <memmove+0xc>
    d += n;
    80000ea8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000eaa:	fff6079b          	addiw	a5,a2,-1
    80000eae:	1782                	slli	a5,a5,0x20
    80000eb0:	9381                	srli	a5,a5,0x20
    80000eb2:	fff7c793          	not	a5,a5
    80000eb6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000eb8:	177d                	addi	a4,a4,-1
    80000eba:	16fd                	addi	a3,a3,-1
    80000ebc:	00074603          	lbu	a2,0(a4)
    80000ec0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000ec4:	fee79ae3          	bne	a5,a4,80000eb8 <memmove+0x4a>
    80000ec8:	b7f1                	j	80000e94 <memmove+0x26>

0000000080000eca <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e406                	sd	ra,8(sp)
    80000ece:	e022                	sd	s0,0(sp)
    80000ed0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	f9c080e7          	jalr	-100(ra) # 80000e6e <memmove>
}
    80000eda:	60a2                	ld	ra,8(sp)
    80000edc:	6402                	ld	s0,0(sp)
    80000ede:	0141                	addi	sp,sp,16
    80000ee0:	8082                	ret

0000000080000ee2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ee2:	1141                	addi	sp,sp,-16
    80000ee4:	e422                	sd	s0,8(sp)
    80000ee6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ee8:	ce11                	beqz	a2,80000f04 <strncmp+0x22>
    80000eea:	00054783          	lbu	a5,0(a0)
    80000eee:	cf89                	beqz	a5,80000f08 <strncmp+0x26>
    80000ef0:	0005c703          	lbu	a4,0(a1)
    80000ef4:	00f71a63          	bne	a4,a5,80000f08 <strncmp+0x26>
    n--, p++, q++;
    80000ef8:	367d                	addiw	a2,a2,-1
    80000efa:	0505                	addi	a0,a0,1
    80000efc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000efe:	f675                	bnez	a2,80000eea <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f00:	4501                	li	a0,0
    80000f02:	a809                	j	80000f14 <strncmp+0x32>
    80000f04:	4501                	li	a0,0
    80000f06:	a039                	j	80000f14 <strncmp+0x32>
  if(n == 0)
    80000f08:	ca09                	beqz	a2,80000f1a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f0a:	00054503          	lbu	a0,0(a0)
    80000f0e:	0005c783          	lbu	a5,0(a1)
    80000f12:	9d1d                	subw	a0,a0,a5
}
    80000f14:	6422                	ld	s0,8(sp)
    80000f16:	0141                	addi	sp,sp,16
    80000f18:	8082                	ret
    return 0;
    80000f1a:	4501                	li	a0,0
    80000f1c:	bfe5                	j	80000f14 <strncmp+0x32>

0000000080000f1e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f1e:	1141                	addi	sp,sp,-16
    80000f20:	e422                	sd	s0,8(sp)
    80000f22:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f24:	872a                	mv	a4,a0
    80000f26:	8832                	mv	a6,a2
    80000f28:	367d                	addiw	a2,a2,-1
    80000f2a:	01005963          	blez	a6,80000f3c <strncpy+0x1e>
    80000f2e:	0705                	addi	a4,a4,1
    80000f30:	0005c783          	lbu	a5,0(a1)
    80000f34:	fef70fa3          	sb	a5,-1(a4)
    80000f38:	0585                	addi	a1,a1,1
    80000f3a:	f7f5                	bnez	a5,80000f26 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f3c:	86ba                	mv	a3,a4
    80000f3e:	00c05c63          	blez	a2,80000f56 <strncpy+0x38>
    *s++ = 0;
    80000f42:	0685                	addi	a3,a3,1
    80000f44:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f48:	40d707bb          	subw	a5,a4,a3
    80000f4c:	37fd                	addiw	a5,a5,-1
    80000f4e:	010787bb          	addw	a5,a5,a6
    80000f52:	fef048e3          	bgtz	a5,80000f42 <strncpy+0x24>
  return os;
}
    80000f56:	6422                	ld	s0,8(sp)
    80000f58:	0141                	addi	sp,sp,16
    80000f5a:	8082                	ret

0000000080000f5c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f5c:	1141                	addi	sp,sp,-16
    80000f5e:	e422                	sd	s0,8(sp)
    80000f60:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f62:	02c05363          	blez	a2,80000f88 <safestrcpy+0x2c>
    80000f66:	fff6069b          	addiw	a3,a2,-1
    80000f6a:	1682                	slli	a3,a3,0x20
    80000f6c:	9281                	srli	a3,a3,0x20
    80000f6e:	96ae                	add	a3,a3,a1
    80000f70:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f72:	00d58963          	beq	a1,a3,80000f84 <safestrcpy+0x28>
    80000f76:	0585                	addi	a1,a1,1
    80000f78:	0785                	addi	a5,a5,1
    80000f7a:	fff5c703          	lbu	a4,-1(a1)
    80000f7e:	fee78fa3          	sb	a4,-1(a5)
    80000f82:	fb65                	bnez	a4,80000f72 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f84:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f88:	6422                	ld	s0,8(sp)
    80000f8a:	0141                	addi	sp,sp,16
    80000f8c:	8082                	ret

0000000080000f8e <strlen>:

int
strlen(const char *s)
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f94:	00054783          	lbu	a5,0(a0)
    80000f98:	cf91                	beqz	a5,80000fb4 <strlen+0x26>
    80000f9a:	0505                	addi	a0,a0,1
    80000f9c:	87aa                	mv	a5,a0
    80000f9e:	4685                	li	a3,1
    80000fa0:	9e89                	subw	a3,a3,a0
    80000fa2:	00f6853b          	addw	a0,a3,a5
    80000fa6:	0785                	addi	a5,a5,1
    80000fa8:	fff7c703          	lbu	a4,-1(a5)
    80000fac:	fb7d                	bnez	a4,80000fa2 <strlen+0x14>
    ;
  return n;
}
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000fb4:	4501                	li	a0,0
    80000fb6:	bfe5                	j	80000fae <strlen+0x20>

0000000080000fb8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000fb8:	1141                	addi	sp,sp,-16
    80000fba:	e406                	sd	ra,8(sp)
    80000fbc:	e022                	sd	s0,0(sp)
    80000fbe:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fc0:	00001097          	auipc	ra,0x1
    80000fc4:	b74080e7          	jalr	-1164(ra) # 80001b34 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fc8:	00008717          	auipc	a4,0x8
    80000fcc:	c3070713          	addi	a4,a4,-976 # 80008bf8 <started>
  if(cpuid() == 0){
    80000fd0:	c139                	beqz	a0,80001016 <main+0x5e>
    while(started == 0)
    80000fd2:	431c                	lw	a5,0(a4)
    80000fd4:	2781                	sext.w	a5,a5
    80000fd6:	dff5                	beqz	a5,80000fd2 <main+0x1a>
      ;
    __sync_synchronize();
    80000fd8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fdc:	00001097          	auipc	ra,0x1
    80000fe0:	b58080e7          	jalr	-1192(ra) # 80001b34 <cpuid>
    80000fe4:	85aa                	mv	a1,a0
    80000fe6:	00007517          	auipc	a0,0x7
    80000fea:	11250513          	addi	a0,a0,274 # 800080f8 <digits+0xb8>
    80000fee:	fffff097          	auipc	ra,0xfffff
    80000ff2:	59c080e7          	jalr	1436(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	0d8080e7          	jalr	216(ra) # 800010ce <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ffe:	00002097          	auipc	ra,0x2
    80001002:	c78080e7          	jalr	-904(ra) # 80002c76 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001006:	00006097          	auipc	ra,0x6
    8000100a:	81a080e7          	jalr	-2022(ra) # 80006820 <plicinithart>
  }

  scheduler();        
    8000100e:	00001097          	auipc	ra,0x1
    80001012:	18e080e7          	jalr	398(ra) # 8000219c <scheduler>
    consoleinit();
    80001016:	fffff097          	auipc	ra,0xfffff
    8000101a:	43a080e7          	jalr	1082(ra) # 80000450 <consoleinit>
    printfinit();
    8000101e:	fffff097          	auipc	ra,0xfffff
    80001022:	74c080e7          	jalr	1868(ra) # 8000076a <printfinit>
    printf("\n");
    80001026:	00007517          	auipc	a0,0x7
    8000102a:	0e250513          	addi	a0,a0,226 # 80008108 <digits+0xc8>
    8000102e:	fffff097          	auipc	ra,0xfffff
    80001032:	55c080e7          	jalr	1372(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	0aa50513          	addi	a0,a0,170 # 800080e0 <digits+0xa0>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	54c080e7          	jalr	1356(ra) # 8000058a <printf>
    printf("\n");
    80001046:	00007517          	auipc	a0,0x7
    8000104a:	0c250513          	addi	a0,a0,194 # 80008108 <digits+0xc8>
    8000104e:	fffff097          	auipc	ra,0xfffff
    80001052:	53c080e7          	jalr	1340(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80001056:	00000097          	auipc	ra,0x0
    8000105a:	b56080e7          	jalr	-1194(ra) # 80000bac <kinit>
    kvminit();       // create kernel page table
    8000105e:	00000097          	auipc	ra,0x0
    80001062:	326080e7          	jalr	806(ra) # 80001384 <kvminit>
    kvminithart();   // turn on paging
    80001066:	00000097          	auipc	ra,0x0
    8000106a:	068080e7          	jalr	104(ra) # 800010ce <kvminithart>
    procinit();      // process table
    8000106e:	00001097          	auipc	ra,0x1
    80001072:	9d8080e7          	jalr	-1576(ra) # 80001a46 <procinit>
    trapinit();      // trap vectors
    80001076:	00002097          	auipc	ra,0x2
    8000107a:	bd8080e7          	jalr	-1064(ra) # 80002c4e <trapinit>
    trapinithart();  // install kernel trap vector
    8000107e:	00002097          	auipc	ra,0x2
    80001082:	bf8080e7          	jalr	-1032(ra) # 80002c76 <trapinithart>
    plicinit();      // set up interrupt controller
    80001086:	00005097          	auipc	ra,0x5
    8000108a:	784080e7          	jalr	1924(ra) # 8000680a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000108e:	00005097          	auipc	ra,0x5
    80001092:	792080e7          	jalr	1938(ra) # 80006820 <plicinithart>
    binit();         // buffer cache
    80001096:	00003097          	auipc	ra,0x3
    8000109a:	908080e7          	jalr	-1784(ra) # 8000399e <binit>
    iinit();         // inode table
    8000109e:	00003097          	auipc	ra,0x3
    800010a2:	fa8080e7          	jalr	-88(ra) # 80004046 <iinit>
    fileinit();      // file table
    800010a6:	00004097          	auipc	ra,0x4
    800010aa:	f4e080e7          	jalr	-178(ra) # 80004ff4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010ae:	00006097          	auipc	ra,0x6
    800010b2:	87a080e7          	jalr	-1926(ra) # 80006928 <virtio_disk_init>
    userinit();      // first user process
    800010b6:	00001097          	auipc	ra,0x1
    800010ba:	eb8080e7          	jalr	-328(ra) # 80001f6e <userinit>
    __sync_synchronize();
    800010be:	0ff0000f          	fence
    started = 1;
    800010c2:	4785                	li	a5,1
    800010c4:	00008717          	auipc	a4,0x8
    800010c8:	b2f72a23          	sw	a5,-1228(a4) # 80008bf8 <started>
    800010cc:	b789                	j	8000100e <main+0x56>

00000000800010ce <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010ce:	1141                	addi	sp,sp,-16
    800010d0:	e422                	sd	s0,8(sp)
    800010d2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010d4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800010d8:	00008797          	auipc	a5,0x8
    800010dc:	b287b783          	ld	a5,-1240(a5) # 80008c00 <kernel_pagetable>
    800010e0:	83b1                	srli	a5,a5,0xc
    800010e2:	577d                	li	a4,-1
    800010e4:	177e                	slli	a4,a4,0x3f
    800010e6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010e8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800010ec:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800010f0:	6422                	ld	s0,8(sp)
    800010f2:	0141                	addi	sp,sp,16
    800010f4:	8082                	ret

00000000800010f6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010f6:	7139                	addi	sp,sp,-64
    800010f8:	fc06                	sd	ra,56(sp)
    800010fa:	f822                	sd	s0,48(sp)
    800010fc:	f426                	sd	s1,40(sp)
    800010fe:	f04a                	sd	s2,32(sp)
    80001100:	ec4e                	sd	s3,24(sp)
    80001102:	e852                	sd	s4,16(sp)
    80001104:	e456                	sd	s5,8(sp)
    80001106:	e05a                	sd	s6,0(sp)
    80001108:	0080                	addi	s0,sp,64
    8000110a:	84aa                	mv	s1,a0
    8000110c:	89ae                	mv	s3,a1
    8000110e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001110:	57fd                	li	a5,-1
    80001112:	83e9                	srli	a5,a5,0x1a
    80001114:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001116:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001118:	04b7f263          	bgeu	a5,a1,8000115c <walk+0x66>
    panic("walk");
    8000111c:	00007517          	auipc	a0,0x7
    80001120:	ff450513          	addi	a0,a0,-12 # 80008110 <digits+0xd0>
    80001124:	fffff097          	auipc	ra,0xfffff
    80001128:	41c080e7          	jalr	1052(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000112c:	060a8663          	beqz	s5,80001198 <walk+0xa2>
    80001130:	00000097          	auipc	ra,0x0
    80001134:	ab8080e7          	jalr	-1352(ra) # 80000be8 <kalloc>
    80001138:	84aa                	mv	s1,a0
    8000113a:	c529                	beqz	a0,80001184 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000113c:	6605                	lui	a2,0x1
    8000113e:	4581                	li	a1,0
    80001140:	00000097          	auipc	ra,0x0
    80001144:	cd2080e7          	jalr	-814(ra) # 80000e12 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001148:	00c4d793          	srli	a5,s1,0xc
    8000114c:	07aa                	slli	a5,a5,0xa
    8000114e:	0017e793          	ori	a5,a5,1
    80001152:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001156:	3a5d                	addiw	s4,s4,-9 # ff7 <_entry-0x7ffff009>
    80001158:	036a0063          	beq	s4,s6,80001178 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000115c:	0149d933          	srl	s2,s3,s4
    80001160:	1ff97913          	andi	s2,s2,511
    80001164:	090e                	slli	s2,s2,0x3
    80001166:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001168:	00093483          	ld	s1,0(s2)
    8000116c:	0014f793          	andi	a5,s1,1
    80001170:	dfd5                	beqz	a5,8000112c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001172:	80a9                	srli	s1,s1,0xa
    80001174:	04b2                	slli	s1,s1,0xc
    80001176:	b7c5                	j	80001156 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001178:	00c9d513          	srli	a0,s3,0xc
    8000117c:	1ff57513          	andi	a0,a0,511
    80001180:	050e                	slli	a0,a0,0x3
    80001182:	9526                	add	a0,a0,s1
}
    80001184:	70e2                	ld	ra,56(sp)
    80001186:	7442                	ld	s0,48(sp)
    80001188:	74a2                	ld	s1,40(sp)
    8000118a:	7902                	ld	s2,32(sp)
    8000118c:	69e2                	ld	s3,24(sp)
    8000118e:	6a42                	ld	s4,16(sp)
    80001190:	6aa2                	ld	s5,8(sp)
    80001192:	6b02                	ld	s6,0(sp)
    80001194:	6121                	addi	sp,sp,64
    80001196:	8082                	ret
        return 0;
    80001198:	4501                	li	a0,0
    8000119a:	b7ed                	j	80001184 <walk+0x8e>

000000008000119c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000119c:	57fd                	li	a5,-1
    8000119e:	83e9                	srli	a5,a5,0x1a
    800011a0:	00b7f463          	bgeu	a5,a1,800011a8 <walkaddr+0xc>
    return 0;
    800011a4:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800011a6:	8082                	ret
{
    800011a8:	1141                	addi	sp,sp,-16
    800011aa:	e406                	sd	ra,8(sp)
    800011ac:	e022                	sd	s0,0(sp)
    800011ae:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011b0:	4601                	li	a2,0
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	f44080e7          	jalr	-188(ra) # 800010f6 <walk>
  if(pte == 0)
    800011ba:	c105                	beqz	a0,800011da <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011bc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011be:	0117f693          	andi	a3,a5,17
    800011c2:	4745                	li	a4,17
    return 0;
    800011c4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011c6:	00e68663          	beq	a3,a4,800011d2 <walkaddr+0x36>
}
    800011ca:	60a2                	ld	ra,8(sp)
    800011cc:	6402                	ld	s0,0(sp)
    800011ce:	0141                	addi	sp,sp,16
    800011d0:	8082                	ret
  pa = PTE2PA(*pte);
    800011d2:	83a9                	srli	a5,a5,0xa
    800011d4:	00c79513          	slli	a0,a5,0xc
  return pa;
    800011d8:	bfcd                	j	800011ca <walkaddr+0x2e>
    return 0;
    800011da:	4501                	li	a0,0
    800011dc:	b7fd                	j	800011ca <walkaddr+0x2e>

00000000800011de <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011de:	715d                	addi	sp,sp,-80
    800011e0:	e486                	sd	ra,72(sp)
    800011e2:	e0a2                	sd	s0,64(sp)
    800011e4:	fc26                	sd	s1,56(sp)
    800011e6:	f84a                	sd	s2,48(sp)
    800011e8:	f44e                	sd	s3,40(sp)
    800011ea:	f052                	sd	s4,32(sp)
    800011ec:	ec56                	sd	s5,24(sp)
    800011ee:	e85a                	sd	s6,16(sp)
    800011f0:	e45e                	sd	s7,8(sp)
    800011f2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800011f4:	c639                	beqz	a2,80001242 <mappages+0x64>
    800011f6:	8aaa                	mv	s5,a0
    800011f8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800011fa:	777d                	lui	a4,0xfffff
    800011fc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001200:	fff58993          	addi	s3,a1,-1
    80001204:	99b2                	add	s3,s3,a2
    80001206:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000120a:	893e                	mv	s2,a5
    8000120c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001210:	6b85                	lui	s7,0x1
    80001212:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001216:	4605                	li	a2,1
    80001218:	85ca                	mv	a1,s2
    8000121a:	8556                	mv	a0,s5
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	eda080e7          	jalr	-294(ra) # 800010f6 <walk>
    80001224:	cd1d                	beqz	a0,80001262 <mappages+0x84>
    if(*pte & PTE_V)
    80001226:	611c                	ld	a5,0(a0)
    80001228:	8b85                	andi	a5,a5,1
    8000122a:	e785                	bnez	a5,80001252 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000122c:	80b1                	srli	s1,s1,0xc
    8000122e:	04aa                	slli	s1,s1,0xa
    80001230:	0164e4b3          	or	s1,s1,s6
    80001234:	0014e493          	ori	s1,s1,1
    80001238:	e104                	sd	s1,0(a0)
    if(a == last)
    8000123a:	05390063          	beq	s2,s3,8000127a <mappages+0x9c>
    a += PGSIZE;
    8000123e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001240:	bfc9                	j	80001212 <mappages+0x34>
    panic("mappages: size");
    80001242:	00007517          	auipc	a0,0x7
    80001246:	ed650513          	addi	a0,a0,-298 # 80008118 <digits+0xd8>
    8000124a:	fffff097          	auipc	ra,0xfffff
    8000124e:	2f6080e7          	jalr	758(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001252:	00007517          	auipc	a0,0x7
    80001256:	ed650513          	addi	a0,a0,-298 # 80008128 <digits+0xe8>
    8000125a:	fffff097          	auipc	ra,0xfffff
    8000125e:	2e6080e7          	jalr	742(ra) # 80000540 <panic>
      return -1;
    80001262:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001264:	60a6                	ld	ra,72(sp)
    80001266:	6406                	ld	s0,64(sp)
    80001268:	74e2                	ld	s1,56(sp)
    8000126a:	7942                	ld	s2,48(sp)
    8000126c:	79a2                	ld	s3,40(sp)
    8000126e:	7a02                	ld	s4,32(sp)
    80001270:	6ae2                	ld	s5,24(sp)
    80001272:	6b42                	ld	s6,16(sp)
    80001274:	6ba2                	ld	s7,8(sp)
    80001276:	6161                	addi	sp,sp,80
    80001278:	8082                	ret
  return 0;
    8000127a:	4501                	li	a0,0
    8000127c:	b7e5                	j	80001264 <mappages+0x86>

000000008000127e <kvmmap>:
{
    8000127e:	1141                	addi	sp,sp,-16
    80001280:	e406                	sd	ra,8(sp)
    80001282:	e022                	sd	s0,0(sp)
    80001284:	0800                	addi	s0,sp,16
    80001286:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001288:	86b2                	mv	a3,a2
    8000128a:	863e                	mv	a2,a5
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	f52080e7          	jalr	-174(ra) # 800011de <mappages>
    80001294:	e509                	bnez	a0,8000129e <kvmmap+0x20>
}
    80001296:	60a2                	ld	ra,8(sp)
    80001298:	6402                	ld	s0,0(sp)
    8000129a:	0141                	addi	sp,sp,16
    8000129c:	8082                	ret
    panic("kvmmap");
    8000129e:	00007517          	auipc	a0,0x7
    800012a2:	e9a50513          	addi	a0,a0,-358 # 80008138 <digits+0xf8>
    800012a6:	fffff097          	auipc	ra,0xfffff
    800012aa:	29a080e7          	jalr	666(ra) # 80000540 <panic>

00000000800012ae <kvmmake>:
{
    800012ae:	1101                	addi	sp,sp,-32
    800012b0:	ec06                	sd	ra,24(sp)
    800012b2:	e822                	sd	s0,16(sp)
    800012b4:	e426                	sd	s1,8(sp)
    800012b6:	e04a                	sd	s2,0(sp)
    800012b8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800012ba:	00000097          	auipc	ra,0x0
    800012be:	92e080e7          	jalr	-1746(ra) # 80000be8 <kalloc>
    800012c2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012c4:	6605                	lui	a2,0x1
    800012c6:	4581                	li	a1,0
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	b4a080e7          	jalr	-1206(ra) # 80000e12 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012d0:	4719                	li	a4,6
    800012d2:	6685                	lui	a3,0x1
    800012d4:	10000637          	lui	a2,0x10000
    800012d8:	100005b7          	lui	a1,0x10000
    800012dc:	8526                	mv	a0,s1
    800012de:	00000097          	auipc	ra,0x0
    800012e2:	fa0080e7          	jalr	-96(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012e6:	4719                	li	a4,6
    800012e8:	6685                	lui	a3,0x1
    800012ea:	10001637          	lui	a2,0x10001
    800012ee:	100015b7          	lui	a1,0x10001
    800012f2:	8526                	mv	a0,s1
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	f8a080e7          	jalr	-118(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012fc:	4719                	li	a4,6
    800012fe:	004006b7          	lui	a3,0x400
    80001302:	0c000637          	lui	a2,0xc000
    80001306:	0c0005b7          	lui	a1,0xc000
    8000130a:	8526                	mv	a0,s1
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	f72080e7          	jalr	-142(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001314:	00007917          	auipc	s2,0x7
    80001318:	cec90913          	addi	s2,s2,-788 # 80008000 <etext>
    8000131c:	4729                	li	a4,10
    8000131e:	80007697          	auipc	a3,0x80007
    80001322:	ce268693          	addi	a3,a3,-798 # 8000 <_entry-0x7fff8000>
    80001326:	4605                	li	a2,1
    80001328:	067e                	slli	a2,a2,0x1f
    8000132a:	85b2                	mv	a1,a2
    8000132c:	8526                	mv	a0,s1
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	f50080e7          	jalr	-176(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001336:	4719                	li	a4,6
    80001338:	46c5                	li	a3,17
    8000133a:	06ee                	slli	a3,a3,0x1b
    8000133c:	412686b3          	sub	a3,a3,s2
    80001340:	864a                	mv	a2,s2
    80001342:	85ca                	mv	a1,s2
    80001344:	8526                	mv	a0,s1
    80001346:	00000097          	auipc	ra,0x0
    8000134a:	f38080e7          	jalr	-200(ra) # 8000127e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000134e:	4729                	li	a4,10
    80001350:	6685                	lui	a3,0x1
    80001352:	00006617          	auipc	a2,0x6
    80001356:	cae60613          	addi	a2,a2,-850 # 80007000 <_trampoline>
    8000135a:	040005b7          	lui	a1,0x4000
    8000135e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001360:	05b2                	slli	a1,a1,0xc
    80001362:	8526                	mv	a0,s1
    80001364:	00000097          	auipc	ra,0x0
    80001368:	f1a080e7          	jalr	-230(ra) # 8000127e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000136c:	8526                	mv	a0,s1
    8000136e:	00000097          	auipc	ra,0x0
    80001372:	642080e7          	jalr	1602(ra) # 800019b0 <proc_mapstacks>
}
    80001376:	8526                	mv	a0,s1
    80001378:	60e2                	ld	ra,24(sp)
    8000137a:	6442                	ld	s0,16(sp)
    8000137c:	64a2                	ld	s1,8(sp)
    8000137e:	6902                	ld	s2,0(sp)
    80001380:	6105                	addi	sp,sp,32
    80001382:	8082                	ret

0000000080001384 <kvminit>:
{
    80001384:	1141                	addi	sp,sp,-16
    80001386:	e406                	sd	ra,8(sp)
    80001388:	e022                	sd	s0,0(sp)
    8000138a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	f22080e7          	jalr	-222(ra) # 800012ae <kvmmake>
    80001394:	00008797          	auipc	a5,0x8
    80001398:	86a7b623          	sd	a0,-1940(a5) # 80008c00 <kernel_pagetable>
}
    8000139c:	60a2                	ld	ra,8(sp)
    8000139e:	6402                	ld	s0,0(sp)
    800013a0:	0141                	addi	sp,sp,16
    800013a2:	8082                	ret

00000000800013a4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013a4:	715d                	addi	sp,sp,-80
    800013a6:	e486                	sd	ra,72(sp)
    800013a8:	e0a2                	sd	s0,64(sp)
    800013aa:	fc26                	sd	s1,56(sp)
    800013ac:	f84a                	sd	s2,48(sp)
    800013ae:	f44e                	sd	s3,40(sp)
    800013b0:	f052                	sd	s4,32(sp)
    800013b2:	ec56                	sd	s5,24(sp)
    800013b4:	e85a                	sd	s6,16(sp)
    800013b6:	e45e                	sd	s7,8(sp)
    800013b8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013ba:	03459793          	slli	a5,a1,0x34
    800013be:	e795                	bnez	a5,800013ea <uvmunmap+0x46>
    800013c0:	8a2a                	mv	s4,a0
    800013c2:	892e                	mv	s2,a1
    800013c4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013c6:	0632                	slli	a2,a2,0xc
    800013c8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013cc:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013ce:	6b05                	lui	s6,0x1
    800013d0:	0735e263          	bltu	a1,s3,80001434 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013d4:	60a6                	ld	ra,72(sp)
    800013d6:	6406                	ld	s0,64(sp)
    800013d8:	74e2                	ld	s1,56(sp)
    800013da:	7942                	ld	s2,48(sp)
    800013dc:	79a2                	ld	s3,40(sp)
    800013de:	7a02                	ld	s4,32(sp)
    800013e0:	6ae2                	ld	s5,24(sp)
    800013e2:	6b42                	ld	s6,16(sp)
    800013e4:	6ba2                	ld	s7,8(sp)
    800013e6:	6161                	addi	sp,sp,80
    800013e8:	8082                	ret
    panic("uvmunmap: not aligned");
    800013ea:	00007517          	auipc	a0,0x7
    800013ee:	d5650513          	addi	a0,a0,-682 # 80008140 <digits+0x100>
    800013f2:	fffff097          	auipc	ra,0xfffff
    800013f6:	14e080e7          	jalr	334(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800013fa:	00007517          	auipc	a0,0x7
    800013fe:	d5e50513          	addi	a0,a0,-674 # 80008158 <digits+0x118>
    80001402:	fffff097          	auipc	ra,0xfffff
    80001406:	13e080e7          	jalr	318(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    8000140a:	00007517          	auipc	a0,0x7
    8000140e:	d5e50513          	addi	a0,a0,-674 # 80008168 <digits+0x128>
    80001412:	fffff097          	auipc	ra,0xfffff
    80001416:	12e080e7          	jalr	302(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    8000141a:	00007517          	auipc	a0,0x7
    8000141e:	d6650513          	addi	a0,a0,-666 # 80008180 <digits+0x140>
    80001422:	fffff097          	auipc	ra,0xfffff
    80001426:	11e080e7          	jalr	286(ra) # 80000540 <panic>
    *pte = 0;
    8000142a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000142e:	995a                	add	s2,s2,s6
    80001430:	fb3972e3          	bgeu	s2,s3,800013d4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001434:	4601                	li	a2,0
    80001436:	85ca                	mv	a1,s2
    80001438:	8552                	mv	a0,s4
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	cbc080e7          	jalr	-836(ra) # 800010f6 <walk>
    80001442:	84aa                	mv	s1,a0
    80001444:	d95d                	beqz	a0,800013fa <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001446:	6108                	ld	a0,0(a0)
    80001448:	00157793          	andi	a5,a0,1
    8000144c:	dfdd                	beqz	a5,8000140a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000144e:	3ff57793          	andi	a5,a0,1023
    80001452:	fd7784e3          	beq	a5,s7,8000141a <uvmunmap+0x76>
    if(do_free){
    80001456:	fc0a8ae3          	beqz	s5,8000142a <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000145a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000145c:	0532                	slli	a0,a0,0xc
    8000145e:	fffff097          	auipc	ra,0xfffff
    80001462:	606080e7          	jalr	1542(ra) # 80000a64 <kfree>
    80001466:	b7d1                	j	8000142a <uvmunmap+0x86>

0000000080001468 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001468:	1101                	addi	sp,sp,-32
    8000146a:	ec06                	sd	ra,24(sp)
    8000146c:	e822                	sd	s0,16(sp)
    8000146e:	e426                	sd	s1,8(sp)
    80001470:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001472:	fffff097          	auipc	ra,0xfffff
    80001476:	776080e7          	jalr	1910(ra) # 80000be8 <kalloc>
    8000147a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000147c:	c519                	beqz	a0,8000148a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000147e:	6605                	lui	a2,0x1
    80001480:	4581                	li	a1,0
    80001482:	00000097          	auipc	ra,0x0
    80001486:	990080e7          	jalr	-1648(ra) # 80000e12 <memset>
  return pagetable;
}
    8000148a:	8526                	mv	a0,s1
    8000148c:	60e2                	ld	ra,24(sp)
    8000148e:	6442                	ld	s0,16(sp)
    80001490:	64a2                	ld	s1,8(sp)
    80001492:	6105                	addi	sp,sp,32
    80001494:	8082                	ret

0000000080001496 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001496:	7179                	addi	sp,sp,-48
    80001498:	f406                	sd	ra,40(sp)
    8000149a:	f022                	sd	s0,32(sp)
    8000149c:	ec26                	sd	s1,24(sp)
    8000149e:	e84a                	sd	s2,16(sp)
    800014a0:	e44e                	sd	s3,8(sp)
    800014a2:	e052                	sd	s4,0(sp)
    800014a4:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800014a6:	6785                	lui	a5,0x1
    800014a8:	04f67863          	bgeu	a2,a5,800014f8 <uvmfirst+0x62>
    800014ac:	8a2a                	mv	s4,a0
    800014ae:	89ae                	mv	s3,a1
    800014b0:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800014b2:	fffff097          	auipc	ra,0xfffff
    800014b6:	736080e7          	jalr	1846(ra) # 80000be8 <kalloc>
    800014ba:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014bc:	6605                	lui	a2,0x1
    800014be:	4581                	li	a1,0
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	952080e7          	jalr	-1710(ra) # 80000e12 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014c8:	4779                	li	a4,30
    800014ca:	86ca                	mv	a3,s2
    800014cc:	6605                	lui	a2,0x1
    800014ce:	4581                	li	a1,0
    800014d0:	8552                	mv	a0,s4
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	d0c080e7          	jalr	-756(ra) # 800011de <mappages>
  memmove(mem, src, sz);
    800014da:	8626                	mv	a2,s1
    800014dc:	85ce                	mv	a1,s3
    800014de:	854a                	mv	a0,s2
    800014e0:	00000097          	auipc	ra,0x0
    800014e4:	98e080e7          	jalr	-1650(ra) # 80000e6e <memmove>
}
    800014e8:	70a2                	ld	ra,40(sp)
    800014ea:	7402                	ld	s0,32(sp)
    800014ec:	64e2                	ld	s1,24(sp)
    800014ee:	6942                	ld	s2,16(sp)
    800014f0:	69a2                	ld	s3,8(sp)
    800014f2:	6a02                	ld	s4,0(sp)
    800014f4:	6145                	addi	sp,sp,48
    800014f6:	8082                	ret
    panic("uvmfirst: more than a page");
    800014f8:	00007517          	auipc	a0,0x7
    800014fc:	ca050513          	addi	a0,a0,-864 # 80008198 <digits+0x158>
    80001500:	fffff097          	auipc	ra,0xfffff
    80001504:	040080e7          	jalr	64(ra) # 80000540 <panic>

0000000080001508 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001508:	1101                	addi	sp,sp,-32
    8000150a:	ec06                	sd	ra,24(sp)
    8000150c:	e822                	sd	s0,16(sp)
    8000150e:	e426                	sd	s1,8(sp)
    80001510:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001512:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001514:	00b67d63          	bgeu	a2,a1,8000152e <uvmdealloc+0x26>
    80001518:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000151a:	6785                	lui	a5,0x1
    8000151c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000151e:	00f60733          	add	a4,a2,a5
    80001522:	76fd                	lui	a3,0xfffff
    80001524:	8f75                	and	a4,a4,a3
    80001526:	97ae                	add	a5,a5,a1
    80001528:	8ff5                	and	a5,a5,a3
    8000152a:	00f76863          	bltu	a4,a5,8000153a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000152e:	8526                	mv	a0,s1
    80001530:	60e2                	ld	ra,24(sp)
    80001532:	6442                	ld	s0,16(sp)
    80001534:	64a2                	ld	s1,8(sp)
    80001536:	6105                	addi	sp,sp,32
    80001538:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000153a:	8f99                	sub	a5,a5,a4
    8000153c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000153e:	4685                	li	a3,1
    80001540:	0007861b          	sext.w	a2,a5
    80001544:	85ba                	mv	a1,a4
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	e5e080e7          	jalr	-418(ra) # 800013a4 <uvmunmap>
    8000154e:	b7c5                	j	8000152e <uvmdealloc+0x26>

0000000080001550 <uvmalloc>:
  if(newsz < oldsz)
    80001550:	0ab66563          	bltu	a2,a1,800015fa <uvmalloc+0xaa>
{
    80001554:	7139                	addi	sp,sp,-64
    80001556:	fc06                	sd	ra,56(sp)
    80001558:	f822                	sd	s0,48(sp)
    8000155a:	f426                	sd	s1,40(sp)
    8000155c:	f04a                	sd	s2,32(sp)
    8000155e:	ec4e                	sd	s3,24(sp)
    80001560:	e852                	sd	s4,16(sp)
    80001562:	e456                	sd	s5,8(sp)
    80001564:	e05a                	sd	s6,0(sp)
    80001566:	0080                	addi	s0,sp,64
    80001568:	8aaa                	mv	s5,a0
    8000156a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000156c:	6785                	lui	a5,0x1
    8000156e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001570:	95be                	add	a1,a1,a5
    80001572:	77fd                	lui	a5,0xfffff
    80001574:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001578:	08c9f363          	bgeu	s3,a2,800015fe <uvmalloc+0xae>
    8000157c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000157e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	666080e7          	jalr	1638(ra) # 80000be8 <kalloc>
    8000158a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000158c:	c51d                	beqz	a0,800015ba <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000158e:	6605                	lui	a2,0x1
    80001590:	4581                	li	a1,0
    80001592:	00000097          	auipc	ra,0x0
    80001596:	880080e7          	jalr	-1920(ra) # 80000e12 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000159a:	875a                	mv	a4,s6
    8000159c:	86a6                	mv	a3,s1
    8000159e:	6605                	lui	a2,0x1
    800015a0:	85ca                	mv	a1,s2
    800015a2:	8556                	mv	a0,s5
    800015a4:	00000097          	auipc	ra,0x0
    800015a8:	c3a080e7          	jalr	-966(ra) # 800011de <mappages>
    800015ac:	e90d                	bnez	a0,800015de <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015ae:	6785                	lui	a5,0x1
    800015b0:	993e                	add	s2,s2,a5
    800015b2:	fd4968e3          	bltu	s2,s4,80001582 <uvmalloc+0x32>
  return newsz;
    800015b6:	8552                	mv	a0,s4
    800015b8:	a809                	j	800015ca <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800015ba:	864e                	mv	a2,s3
    800015bc:	85ca                	mv	a1,s2
    800015be:	8556                	mv	a0,s5
    800015c0:	00000097          	auipc	ra,0x0
    800015c4:	f48080e7          	jalr	-184(ra) # 80001508 <uvmdealloc>
      return 0;
    800015c8:	4501                	li	a0,0
}
    800015ca:	70e2                	ld	ra,56(sp)
    800015cc:	7442                	ld	s0,48(sp)
    800015ce:	74a2                	ld	s1,40(sp)
    800015d0:	7902                	ld	s2,32(sp)
    800015d2:	69e2                	ld	s3,24(sp)
    800015d4:	6a42                	ld	s4,16(sp)
    800015d6:	6aa2                	ld	s5,8(sp)
    800015d8:	6b02                	ld	s6,0(sp)
    800015da:	6121                	addi	sp,sp,64
    800015dc:	8082                	ret
      kfree(mem);
    800015de:	8526                	mv	a0,s1
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	484080e7          	jalr	1156(ra) # 80000a64 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015e8:	864e                	mv	a2,s3
    800015ea:	85ca                	mv	a1,s2
    800015ec:	8556                	mv	a0,s5
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	f1a080e7          	jalr	-230(ra) # 80001508 <uvmdealloc>
      return 0;
    800015f6:	4501                	li	a0,0
    800015f8:	bfc9                	j	800015ca <uvmalloc+0x7a>
    return oldsz;
    800015fa:	852e                	mv	a0,a1
}
    800015fc:	8082                	ret
  return newsz;
    800015fe:	8532                	mv	a0,a2
    80001600:	b7e9                	j	800015ca <uvmalloc+0x7a>

0000000080001602 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001602:	7179                	addi	sp,sp,-48
    80001604:	f406                	sd	ra,40(sp)
    80001606:	f022                	sd	s0,32(sp)
    80001608:	ec26                	sd	s1,24(sp)
    8000160a:	e84a                	sd	s2,16(sp)
    8000160c:	e44e                	sd	s3,8(sp)
    8000160e:	e052                	sd	s4,0(sp)
    80001610:	1800                	addi	s0,sp,48
    80001612:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001614:	84aa                	mv	s1,a0
    80001616:	6905                	lui	s2,0x1
    80001618:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000161a:	4985                	li	s3,1
    8000161c:	a829                	j	80001636 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000161e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001620:	00c79513          	slli	a0,a5,0xc
    80001624:	00000097          	auipc	ra,0x0
    80001628:	fde080e7          	jalr	-34(ra) # 80001602 <freewalk>
      pagetable[i] = 0;
    8000162c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001630:	04a1                	addi	s1,s1,8
    80001632:	03248163          	beq	s1,s2,80001654 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001636:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001638:	00f7f713          	andi	a4,a5,15
    8000163c:	ff3701e3          	beq	a4,s3,8000161e <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001640:	8b85                	andi	a5,a5,1
    80001642:	d7fd                	beqz	a5,80001630 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001644:	00007517          	auipc	a0,0x7
    80001648:	b7450513          	addi	a0,a0,-1164 # 800081b8 <digits+0x178>
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	ef4080e7          	jalr	-268(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001654:	8552                	mv	a0,s4
    80001656:	fffff097          	auipc	ra,0xfffff
    8000165a:	40e080e7          	jalr	1038(ra) # 80000a64 <kfree>
}
    8000165e:	70a2                	ld	ra,40(sp)
    80001660:	7402                	ld	s0,32(sp)
    80001662:	64e2                	ld	s1,24(sp)
    80001664:	6942                	ld	s2,16(sp)
    80001666:	69a2                	ld	s3,8(sp)
    80001668:	6a02                	ld	s4,0(sp)
    8000166a:	6145                	addi	sp,sp,48
    8000166c:	8082                	ret

000000008000166e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000166e:	1101                	addi	sp,sp,-32
    80001670:	ec06                	sd	ra,24(sp)
    80001672:	e822                	sd	s0,16(sp)
    80001674:	e426                	sd	s1,8(sp)
    80001676:	1000                	addi	s0,sp,32
    80001678:	84aa                	mv	s1,a0
  if(sz > 0)
    8000167a:	e999                	bnez	a1,80001690 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000167c:	8526                	mv	a0,s1
    8000167e:	00000097          	auipc	ra,0x0
    80001682:	f84080e7          	jalr	-124(ra) # 80001602 <freewalk>
}
    80001686:	60e2                	ld	ra,24(sp)
    80001688:	6442                	ld	s0,16(sp)
    8000168a:	64a2                	ld	s1,8(sp)
    8000168c:	6105                	addi	sp,sp,32
    8000168e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001690:	6785                	lui	a5,0x1
    80001692:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001694:	95be                	add	a1,a1,a5
    80001696:	4685                	li	a3,1
    80001698:	00c5d613          	srli	a2,a1,0xc
    8000169c:	4581                	li	a1,0
    8000169e:	00000097          	auipc	ra,0x0
    800016a2:	d06080e7          	jalr	-762(ra) # 800013a4 <uvmunmap>
    800016a6:	bfd9                	j	8000167c <uvmfree+0xe>

00000000800016a8 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016a8:	ce4d                	beqz	a2,80001762 <uvmcopy+0xba>
{
    800016aa:	7139                	addi	sp,sp,-64
    800016ac:	fc06                	sd	ra,56(sp)
    800016ae:	f822                	sd	s0,48(sp)
    800016b0:	f426                	sd	s1,40(sp)
    800016b2:	f04a                	sd	s2,32(sp)
    800016b4:	ec4e                	sd	s3,24(sp)
    800016b6:	e852                	sd	s4,16(sp)
    800016b8:	e456                	sd	s5,8(sp)
    800016ba:	e05a                	sd	s6,0(sp)
    800016bc:	0080                	addi	s0,sp,64
    800016be:	8aaa                	mv	s5,a0
    800016c0:	8a2e                	mv	s4,a1
    800016c2:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016c4:	4481                	li	s1,0
    if((pte = walk(old, i, 0)) == 0)
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	8556                	mv	a0,s5
    800016cc:	00000097          	auipc	ra,0x0
    800016d0:	a2a080e7          	jalr	-1494(ra) # 800010f6 <walk>
    800016d4:	c139                	beqz	a0,8000171a <uvmcopy+0x72>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016d6:	611c                	ld	a5,0(a0)
    800016d8:	0017f713          	andi	a4,a5,1
    800016dc:	c739                	beqz	a4,8000172a <uvmcopy+0x82>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016de:	00a7d913          	srli	s2,a5,0xa
    800016e2:	0932                	slli	s2,s2,0xc

    // if((mem = kalloc()) == 0)
    //   goto err;
    // memmove(mem, (char*)pa, PGSIZE);

    flags &= ~PTE_W; // disabling writting for child
    800016e4:	3fb7fb13          	andi	s6,a5,1019
    flags = flags | PTE_C; // enabling COW flag

    *pte &= ~PTE_W; // disabling writting for parent
    800016e8:	9bed                	andi	a5,a5,-5
    *pte = *pte | PTE_C; // enabling COW flag
    800016ea:	0207e793          	ori	a5,a5,32
    800016ee:	e11c                	sd	a5,0(a0)

    incref(pa);
    800016f0:	854a                	mv	a0,s2
    800016f2:	fffff097          	auipc	ra,0xfffff
    800016f6:	2f6080e7          	jalr	758(ra) # 800009e8 <incref>
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){ // only map the page table and not memory
    800016fa:	020b6713          	ori	a4,s6,32
    800016fe:	86ca                	mv	a3,s2
    80001700:	6605                	lui	a2,0x1
    80001702:	85a6                	mv	a1,s1
    80001704:	8552                	mv	a0,s4
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	ad8080e7          	jalr	-1320(ra) # 800011de <mappages>
    8000170e:	e515                	bnez	a0,8000173a <uvmcopy+0x92>
  for(i = 0; i < sz; i += PGSIZE){
    80001710:	6785                	lui	a5,0x1
    80001712:	94be                	add	s1,s1,a5
    80001714:	fb34e9e3          	bltu	s1,s3,800016c6 <uvmcopy+0x1e>
    80001718:	a81d                	j	8000174e <uvmcopy+0xa6>
      panic("uvmcopy: pte should exist");
    8000171a:	00007517          	auipc	a0,0x7
    8000171e:	aae50513          	addi	a0,a0,-1362 # 800081c8 <digits+0x188>
    80001722:	fffff097          	auipc	ra,0xfffff
    80001726:	e1e080e7          	jalr	-482(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    8000172a:	00007517          	auipc	a0,0x7
    8000172e:	abe50513          	addi	a0,a0,-1346 # 800081e8 <digits+0x1a8>
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	e0e080e7          	jalr	-498(ra) # 80000540 <panic>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000173a:	4685                	li	a3,1
    8000173c:	00c4d613          	srli	a2,s1,0xc
    80001740:	4581                	li	a1,0
    80001742:	8552                	mv	a0,s4
    80001744:	00000097          	auipc	ra,0x0
    80001748:	c60080e7          	jalr	-928(ra) # 800013a4 <uvmunmap>
  return -1;
    8000174c:	557d                	li	a0,-1
}
    8000174e:	70e2                	ld	ra,56(sp)
    80001750:	7442                	ld	s0,48(sp)
    80001752:	74a2                	ld	s1,40(sp)
    80001754:	7902                	ld	s2,32(sp)
    80001756:	69e2                	ld	s3,24(sp)
    80001758:	6a42                	ld	s4,16(sp)
    8000175a:	6aa2                	ld	s5,8(sp)
    8000175c:	6b02                	ld	s6,0(sp)
    8000175e:	6121                	addi	sp,sp,64
    80001760:	8082                	ret
  return 0;
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret

0000000080001766 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001766:	1141                	addi	sp,sp,-16
    80001768:	e406                	sd	ra,8(sp)
    8000176a:	e022                	sd	s0,0(sp)
    8000176c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000176e:	4601                	li	a2,0
    80001770:	00000097          	auipc	ra,0x0
    80001774:	986080e7          	jalr	-1658(ra) # 800010f6 <walk>
  if(pte == 0)
    80001778:	c901                	beqz	a0,80001788 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000177a:	611c                	ld	a5,0(a0)
    8000177c:	9bbd                	andi	a5,a5,-17
    8000177e:	e11c                	sd	a5,0(a0)
}
    80001780:	60a2                	ld	ra,8(sp)
    80001782:	6402                	ld	s0,0(sp)
    80001784:	0141                	addi	sp,sp,16
    80001786:	8082                	ret
    panic("uvmclear");
    80001788:	00007517          	auipc	a0,0x7
    8000178c:	a8050513          	addi	a0,a0,-1408 # 80008208 <digits+0x1c8>
    80001790:	fffff097          	auipc	ra,0xfffff
    80001794:	db0080e7          	jalr	-592(ra) # 80000540 <panic>

0000000080001798 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001798:	cac5                	beqz	a3,80001848 <copyout+0xb0>
{
    8000179a:	711d                	addi	sp,sp,-96
    8000179c:	ec86                	sd	ra,88(sp)
    8000179e:	e8a2                	sd	s0,80(sp)
    800017a0:	e4a6                	sd	s1,72(sp)
    800017a2:	e0ca                	sd	s2,64(sp)
    800017a4:	fc4e                	sd	s3,56(sp)
    800017a6:	f852                	sd	s4,48(sp)
    800017a8:	f456                	sd	s5,40(sp)
    800017aa:	f05a                	sd	s6,32(sp)
    800017ac:	ec5e                	sd	s7,24(sp)
    800017ae:	e862                	sd	s8,16(sp)
    800017b0:	e466                	sd	s9,8(sp)
    800017b2:	e06a                	sd	s10,0(sp)
    800017b4:	1080                	addi	s0,sp,96
    800017b6:	8baa                	mv	s7,a0
    800017b8:	89ae                	mv	s3,a1
    800017ba:	8b32                	mv	s6,a2
    800017bc:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800017be:	7cfd                	lui	s9,0xfffff

    pa0=walkaddr(pagetable,va0);
    if(pa0==0)
      return -1;
    pte_t *pte=walk(pagetable,va0,0);
    if(pte==0 || (*pte & PTE_V)==0 || (*pte & PTE_U)==0)
    800017c0:	4d45                	li	s10,17
        return -1;
    }

    pa0=PTE2PA(*pte); // pull the pagetable entry out in case it is changed
  
    n = PGSIZE - (dstva - va0);
    800017c2:	6c05                	lui	s8,0x1
    800017c4:	a825                	j	800017fc <copyout+0x64>
    800017c6:	413904b3          	sub	s1,s2,s3
    800017ca:	94e2                	add	s1,s1,s8
    800017cc:	009af363          	bgeu	s5,s1,800017d2 <copyout+0x3a>
    800017d0:	84d6                	mv	s1,s5
    pa0=PTE2PA(*pte); // pull the pagetable entry out in case it is changed
    800017d2:	000a3783          	ld	a5,0(s4)
    800017d6:	83a9                	srli	a5,a5,0xa
    800017d8:	07b2                	slli	a5,a5,0xc
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017da:	41298533          	sub	a0,s3,s2
    800017de:	0004861b          	sext.w	a2,s1
    800017e2:	85da                	mv	a1,s6
    800017e4:	953e                	add	a0,a0,a5
    800017e6:	fffff097          	auipc	ra,0xfffff
    800017ea:	688080e7          	jalr	1672(ra) # 80000e6e <memmove>

    len -= n;
    800017ee:	409a8ab3          	sub	s5,s5,s1
    src += n;
    800017f2:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    800017f4:	018909b3          	add	s3,s2,s8
  while(len > 0){
    800017f8:	040a8663          	beqz	s5,80001844 <copyout+0xac>
    va0 = PGROUNDDOWN(dstva);
    800017fc:	0199f933          	and	s2,s3,s9
    pa0=walkaddr(pagetable,va0);
    80001800:	85ca                	mv	a1,s2
    80001802:	855e                	mv	a0,s7
    80001804:	00000097          	auipc	ra,0x0
    80001808:	998080e7          	jalr	-1640(ra) # 8000119c <walkaddr>
    if(pa0==0)
    8000180c:	c121                	beqz	a0,8000184c <copyout+0xb4>
    pte_t *pte=walk(pagetable,va0,0);
    8000180e:	4601                	li	a2,0
    80001810:	85ca                	mv	a1,s2
    80001812:	855e                	mv	a0,s7
    80001814:	00000097          	auipc	ra,0x0
    80001818:	8e2080e7          	jalr	-1822(ra) # 800010f6 <walk>
    8000181c:	8a2a                	mv	s4,a0
    if(pte==0 || (*pte & PTE_V)==0 || (*pte & PTE_U)==0)
    8000181e:	c531                	beqz	a0,8000186a <copyout+0xd2>
    80001820:	611c                	ld	a5,0(a0)
    80001822:	0117f713          	andi	a4,a5,17
    80001826:	05a71463          	bne	a4,s10,8000186e <copyout+0xd6>
    if((*pte & PTE_C)==0){ // this is a cow page
    8000182a:	0207f793          	andi	a5,a5,32
    8000182e:	ffc1                	bnez	a5,800017c6 <copyout+0x2e>
      if(cow_handler(pagetable,va0)<0)
    80001830:	85ca                	mv	a1,s2
    80001832:	855e                	mv	a0,s7
    80001834:	00001097          	auipc	ra,0x1
    80001838:	45a080e7          	jalr	1114(ra) # 80002c8e <cow_handler>
    8000183c:	f80555e3          	bgez	a0,800017c6 <copyout+0x2e>
        return -1;
    80001840:	557d                	li	a0,-1
    80001842:	a031                	j	8000184e <copyout+0xb6>
  }
  return 0;
    80001844:	4501                	li	a0,0
    80001846:	a021                	j	8000184e <copyout+0xb6>
    80001848:	4501                	li	a0,0
}
    8000184a:	8082                	ret
      return -1;
    8000184c:	557d                	li	a0,-1
}
    8000184e:	60e6                	ld	ra,88(sp)
    80001850:	6446                	ld	s0,80(sp)
    80001852:	64a6                	ld	s1,72(sp)
    80001854:	6906                	ld	s2,64(sp)
    80001856:	79e2                	ld	s3,56(sp)
    80001858:	7a42                	ld	s4,48(sp)
    8000185a:	7aa2                	ld	s5,40(sp)
    8000185c:	7b02                	ld	s6,32(sp)
    8000185e:	6be2                	ld	s7,24(sp)
    80001860:	6c42                	ld	s8,16(sp)
    80001862:	6ca2                	ld	s9,8(sp)
    80001864:	6d02                	ld	s10,0(sp)
    80001866:	6125                	addi	sp,sp,96
    80001868:	8082                	ret
      return -1;
    8000186a:	557d                	li	a0,-1
    8000186c:	b7cd                	j	8000184e <copyout+0xb6>
    8000186e:	557d                	li	a0,-1
    80001870:	bff9                	j	8000184e <copyout+0xb6>

0000000080001872 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001872:	caa5                	beqz	a3,800018e2 <copyin+0x70>
{
    80001874:	715d                	addi	sp,sp,-80
    80001876:	e486                	sd	ra,72(sp)
    80001878:	e0a2                	sd	s0,64(sp)
    8000187a:	fc26                	sd	s1,56(sp)
    8000187c:	f84a                	sd	s2,48(sp)
    8000187e:	f44e                	sd	s3,40(sp)
    80001880:	f052                	sd	s4,32(sp)
    80001882:	ec56                	sd	s5,24(sp)
    80001884:	e85a                	sd	s6,16(sp)
    80001886:	e45e                	sd	s7,8(sp)
    80001888:	e062                	sd	s8,0(sp)
    8000188a:	0880                	addi	s0,sp,80
    8000188c:	8b2a                	mv	s6,a0
    8000188e:	8a2e                	mv	s4,a1
    80001890:	8c32                	mv	s8,a2
    80001892:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001894:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001896:	6a85                	lui	s5,0x1
    80001898:	a01d                	j	800018be <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000189a:	018505b3          	add	a1,a0,s8
    8000189e:	0004861b          	sext.w	a2,s1
    800018a2:	412585b3          	sub	a1,a1,s2
    800018a6:	8552                	mv	a0,s4
    800018a8:	fffff097          	auipc	ra,0xfffff
    800018ac:	5c6080e7          	jalr	1478(ra) # 80000e6e <memmove>

    len -= n;
    800018b0:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018b4:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018b6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018ba:	02098263          	beqz	s3,800018de <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018be:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018c2:	85ca                	mv	a1,s2
    800018c4:	855a                	mv	a0,s6
    800018c6:	00000097          	auipc	ra,0x0
    800018ca:	8d6080e7          	jalr	-1834(ra) # 8000119c <walkaddr>
    if(pa0 == 0)
    800018ce:	cd01                	beqz	a0,800018e6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018d0:	418904b3          	sub	s1,s2,s8
    800018d4:	94d6                	add	s1,s1,s5
    800018d6:	fc99f2e3          	bgeu	s3,s1,8000189a <copyin+0x28>
    800018da:	84ce                	mv	s1,s3
    800018dc:	bf7d                	j	8000189a <copyin+0x28>
  }
  return 0;
    800018de:	4501                	li	a0,0
    800018e0:	a021                	j	800018e8 <copyin+0x76>
    800018e2:	4501                	li	a0,0
}
    800018e4:	8082                	ret
      return -1;
    800018e6:	557d                	li	a0,-1
}
    800018e8:	60a6                	ld	ra,72(sp)
    800018ea:	6406                	ld	s0,64(sp)
    800018ec:	74e2                	ld	s1,56(sp)
    800018ee:	7942                	ld	s2,48(sp)
    800018f0:	79a2                	ld	s3,40(sp)
    800018f2:	7a02                	ld	s4,32(sp)
    800018f4:	6ae2                	ld	s5,24(sp)
    800018f6:	6b42                	ld	s6,16(sp)
    800018f8:	6ba2                	ld	s7,8(sp)
    800018fa:	6c02                	ld	s8,0(sp)
    800018fc:	6161                	addi	sp,sp,80
    800018fe:	8082                	ret

0000000080001900 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001900:	c2dd                	beqz	a3,800019a6 <copyinstr+0xa6>
{
    80001902:	715d                	addi	sp,sp,-80
    80001904:	e486                	sd	ra,72(sp)
    80001906:	e0a2                	sd	s0,64(sp)
    80001908:	fc26                	sd	s1,56(sp)
    8000190a:	f84a                	sd	s2,48(sp)
    8000190c:	f44e                	sd	s3,40(sp)
    8000190e:	f052                	sd	s4,32(sp)
    80001910:	ec56                	sd	s5,24(sp)
    80001912:	e85a                	sd	s6,16(sp)
    80001914:	e45e                	sd	s7,8(sp)
    80001916:	0880                	addi	s0,sp,80
    80001918:	8a2a                	mv	s4,a0
    8000191a:	8b2e                	mv	s6,a1
    8000191c:	8bb2                	mv	s7,a2
    8000191e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001920:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001922:	6985                	lui	s3,0x1
    80001924:	a02d                	j	8000194e <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001926:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000192a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000192c:	37fd                	addiw	a5,a5,-1
    8000192e:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001932:	60a6                	ld	ra,72(sp)
    80001934:	6406                	ld	s0,64(sp)
    80001936:	74e2                	ld	s1,56(sp)
    80001938:	7942                	ld	s2,48(sp)
    8000193a:	79a2                	ld	s3,40(sp)
    8000193c:	7a02                	ld	s4,32(sp)
    8000193e:	6ae2                	ld	s5,24(sp)
    80001940:	6b42                	ld	s6,16(sp)
    80001942:	6ba2                	ld	s7,8(sp)
    80001944:	6161                	addi	sp,sp,80
    80001946:	8082                	ret
    srcva = va0 + PGSIZE;
    80001948:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000194c:	c8a9                	beqz	s1,8000199e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000194e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001952:	85ca                	mv	a1,s2
    80001954:	8552                	mv	a0,s4
    80001956:	00000097          	auipc	ra,0x0
    8000195a:	846080e7          	jalr	-1978(ra) # 8000119c <walkaddr>
    if(pa0 == 0)
    8000195e:	c131                	beqz	a0,800019a2 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001960:	417906b3          	sub	a3,s2,s7
    80001964:	96ce                	add	a3,a3,s3
    80001966:	00d4f363          	bgeu	s1,a3,8000196c <copyinstr+0x6c>
    8000196a:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000196c:	955e                	add	a0,a0,s7
    8000196e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001972:	daf9                	beqz	a3,80001948 <copyinstr+0x48>
    80001974:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001976:	41650633          	sub	a2,a0,s6
    8000197a:	fff48593          	addi	a1,s1,-1
    8000197e:	95da                	add	a1,a1,s6
    while(n > 0){
    80001980:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001982:	00f60733          	add	a4,a2,a5
    80001986:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdbaf20>
    8000198a:	df51                	beqz	a4,80001926 <copyinstr+0x26>
        *dst = *p;
    8000198c:	00e78023          	sb	a4,0(a5)
      --max;
    80001990:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001994:	0785                	addi	a5,a5,1
    while(n > 0){
    80001996:	fed796e3          	bne	a5,a3,80001982 <copyinstr+0x82>
      dst++;
    8000199a:	8b3e                	mv	s6,a5
    8000199c:	b775                	j	80001948 <copyinstr+0x48>
    8000199e:	4781                	li	a5,0
    800019a0:	b771                	j	8000192c <copyinstr+0x2c>
      return -1;
    800019a2:	557d                	li	a0,-1
    800019a4:	b779                	j	80001932 <copyinstr+0x32>
  int got_null = 0;
    800019a6:	4781                	li	a5,0
  if(got_null){
    800019a8:	37fd                	addiw	a5,a5,-1
    800019aa:	0007851b          	sext.w	a0,a5
}
    800019ae:	8082                	ret

00000000800019b0 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800019b0:	7139                	addi	sp,sp,-64
    800019b2:	fc06                	sd	ra,56(sp)
    800019b4:	f822                	sd	s0,48(sp)
    800019b6:	f426                	sd	s1,40(sp)
    800019b8:	f04a                	sd	s2,32(sp)
    800019ba:	ec4e                	sd	s3,24(sp)
    800019bc:	e852                	sd	s4,16(sp)
    800019be:	e456                	sd	s5,8(sp)
    800019c0:	e05a                	sd	s6,0(sp)
    800019c2:	0080                	addi	s0,sp,64
    800019c4:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800019c6:	00230497          	auipc	s1,0x230
    800019ca:	d3a48493          	addi	s1,s1,-710 # 80231700 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800019ce:	8b26                	mv	s6,s1
    800019d0:	00006a97          	auipc	s5,0x6
    800019d4:	630a8a93          	addi	s5,s5,1584 # 80008000 <etext>
    800019d8:	04000937          	lui	s2,0x4000
    800019dc:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019de:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800019e0:	00237a17          	auipc	s4,0x237
    800019e4:	320a0a13          	addi	s4,s4,800 # 80238d00 <tickslock>
    char *pa = kalloc();
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	200080e7          	jalr	512(ra) # 80000be8 <kalloc>
    800019f0:	862a                	mv	a2,a0
    if (pa == 0)
    800019f2:	c131                	beqz	a0,80001a36 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    800019f4:	416485b3          	sub	a1,s1,s6
    800019f8:	858d                	srai	a1,a1,0x3
    800019fa:	000ab783          	ld	a5,0(s5)
    800019fe:	02f585b3          	mul	a1,a1,a5
    80001a02:	2585                	addiw	a1,a1,1
    80001a04:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a08:	4719                	li	a4,6
    80001a0a:	6685                	lui	a3,0x1
    80001a0c:	40b905b3          	sub	a1,s2,a1
    80001a10:	854e                	mv	a0,s3
    80001a12:	00000097          	auipc	ra,0x0
    80001a16:	86c080e7          	jalr	-1940(ra) # 8000127e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a1a:	1d848493          	addi	s1,s1,472
    80001a1e:	fd4495e3          	bne	s1,s4,800019e8 <proc_mapstacks+0x38>
  }
}
    80001a22:	70e2                	ld	ra,56(sp)
    80001a24:	7442                	ld	s0,48(sp)
    80001a26:	74a2                	ld	s1,40(sp)
    80001a28:	7902                	ld	s2,32(sp)
    80001a2a:	69e2                	ld	s3,24(sp)
    80001a2c:	6a42                	ld	s4,16(sp)
    80001a2e:	6aa2                	ld	s5,8(sp)
    80001a30:	6b02                	ld	s6,0(sp)
    80001a32:	6121                	addi	sp,sp,64
    80001a34:	8082                	ret
      panic("kalloc");
    80001a36:	00006517          	auipc	a0,0x6
    80001a3a:	7e250513          	addi	a0,a0,2018 # 80008218 <digits+0x1d8>
    80001a3e:	fffff097          	auipc	ra,0xfffff
    80001a42:	b02080e7          	jalr	-1278(ra) # 80000540 <panic>

0000000080001a46 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a46:	715d                	addi	sp,sp,-80
    80001a48:	e486                	sd	ra,72(sp)
    80001a4a:	e0a2                	sd	s0,64(sp)
    80001a4c:	fc26                	sd	s1,56(sp)
    80001a4e:	f84a                	sd	s2,48(sp)
    80001a50:	f44e                	sd	s3,40(sp)
    80001a52:	f052                	sd	s4,32(sp)
    80001a54:	ec56                	sd	s5,24(sp)
    80001a56:	e85a                	sd	s6,16(sp)
    80001a58:	e45e                	sd	s7,8(sp)
    80001a5a:	0880                	addi	s0,sp,80

  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a5c:	00006597          	auipc	a1,0x6
    80001a60:	7c458593          	addi	a1,a1,1988 # 80008220 <digits+0x1e0>
    80001a64:	0022f517          	auipc	a0,0x22f
    80001a68:	41c50513          	addi	a0,a0,1052 # 80230e80 <pid_lock>
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	21a080e7          	jalr	538(ra) # 80000c86 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a74:	00006597          	auipc	a1,0x6
    80001a78:	7b458593          	addi	a1,a1,1972 # 80008228 <digits+0x1e8>
    80001a7c:	0022f517          	auipc	a0,0x22f
    80001a80:	41c50513          	addi	a0,a0,1052 # 80230e98 <wait_lock>
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	202080e7          	jalr	514(ra) # 80000c86 <initlock>

  for (p = proc; p < &proc[NPROC]; p++)
    80001a8c:	00230497          	auipc	s1,0x230
    80001a90:	c7448493          	addi	s1,s1,-908 # 80231700 <proc>
  {
    initlock(&p->lock, "proc");
    80001a94:	00006b97          	auipc	s7,0x6
    80001a98:	7a4b8b93          	addi	s7,s7,1956 # 80008238 <digits+0x1f8>
    p->state = UNUSED;
    p->mask = -1;
    80001a9c:	5b7d                	li	s6,-1
    p->kstack = KSTACK((int)(p - proc));
    80001a9e:	8aa6                	mv	s5,s1
    80001aa0:	00006a17          	auipc	s4,0x6
    80001aa4:	560a0a13          	addi	s4,s4,1376 # 80008000 <etext>
    80001aa8:	04000937          	lui	s2,0x4000
    80001aac:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001aae:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001ab0:	00237997          	auipc	s3,0x237
    80001ab4:	25098993          	addi	s3,s3,592 # 80238d00 <tickslock>
    initlock(&p->lock, "proc");
    80001ab8:	85de                	mv	a1,s7
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	1ca080e7          	jalr	458(ra) # 80000c86 <initlock>
    p->state = UNUSED;
    80001ac4:	0004ac23          	sw	zero,24(s1)
    p->mask = -1;
    80001ac8:	1764a423          	sw	s6,360(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001acc:	415487b3          	sub	a5,s1,s5
    80001ad0:	878d                	srai	a5,a5,0x3
    80001ad2:	000a3703          	ld	a4,0(s4)
    80001ad6:	02e787b3          	mul	a5,a5,a4
    80001ada:	2785                	addiw	a5,a5,1
    80001adc:	00d7979b          	slliw	a5,a5,0xd
    80001ae0:	40f907b3          	sub	a5,s2,a5
    80001ae4:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001ae6:	1d848493          	addi	s1,s1,472
    80001aea:	fd3497e3          	bne	s1,s3,80001ab8 <procinit+0x72>
  }
#ifdef MLFQ
  for (int i = 0; i < 5; i++)
  {
    queues[i].head = 0;
    80001aee:	0022f797          	auipc	a5,0x22f
    80001af2:	39278793          	addi	a5,a5,914 # 80230e80 <pid_lock>
    80001af6:	0207b823          	sd	zero,48(a5)
    queues[i].size = 0;
    80001afa:	0207ac23          	sw	zero,56(a5)
    queues[i].head = 0;
    80001afe:	0407b023          	sd	zero,64(a5)
    queues[i].size = 0;
    80001b02:	0407a423          	sw	zero,72(a5)
    queues[i].head = 0;
    80001b06:	0407b823          	sd	zero,80(a5)
    queues[i].size = 0;
    80001b0a:	0407ac23          	sw	zero,88(a5)
    queues[i].head = 0;
    80001b0e:	0607b023          	sd	zero,96(a5)
    queues[i].size = 0;
    80001b12:	0607a423          	sw	zero,104(a5)
    queues[i].head = 0;
    80001b16:	0607b823          	sd	zero,112(a5)
    queues[i].size = 0;
    80001b1a:	0607ac23          	sw	zero,120(a5)
  }
#endif
}
    80001b1e:	60a6                	ld	ra,72(sp)
    80001b20:	6406                	ld	s0,64(sp)
    80001b22:	74e2                	ld	s1,56(sp)
    80001b24:	7942                	ld	s2,48(sp)
    80001b26:	79a2                	ld	s3,40(sp)
    80001b28:	7a02                	ld	s4,32(sp)
    80001b2a:	6ae2                	ld	s5,24(sp)
    80001b2c:	6b42                	ld	s6,16(sp)
    80001b2e:	6ba2                	ld	s7,8(sp)
    80001b30:	6161                	addi	sp,sp,80
    80001b32:	8082                	ret

0000000080001b34 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001b34:	1141                	addi	sp,sp,-16
    80001b36:	e422                	sd	s0,8(sp)
    80001b38:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b3a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b3c:	2501                	sext.w	a0,a0
    80001b3e:	6422                	ld	s0,8(sp)
    80001b40:	0141                	addi	sp,sp,16
    80001b42:	8082                	ret

0000000080001b44 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001b44:	1141                	addi	sp,sp,-16
    80001b46:	e422                	sd	s0,8(sp)
    80001b48:	0800                	addi	s0,sp,16
    80001b4a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b4c:	2781                	sext.w	a5,a5
    80001b4e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b50:	0022f517          	auipc	a0,0x22f
    80001b54:	3b050513          	addi	a0,a0,944 # 80230f00 <cpus>
    80001b58:	953e                	add	a0,a0,a5
    80001b5a:	6422                	ld	s0,8(sp)
    80001b5c:	0141                	addi	sp,sp,16
    80001b5e:	8082                	ret

0000000080001b60 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b60:	1101                	addi	sp,sp,-32
    80001b62:	ec06                	sd	ra,24(sp)
    80001b64:	e822                	sd	s0,16(sp)
    80001b66:	e426                	sd	s1,8(sp)
    80001b68:	1000                	addi	s0,sp,32
  push_off();
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	160080e7          	jalr	352(ra) # 80000cca <push_off>
    80001b72:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b74:	2781                	sext.w	a5,a5
    80001b76:	079e                	slli	a5,a5,0x7
    80001b78:	0022f717          	auipc	a4,0x22f
    80001b7c:	30870713          	addi	a4,a4,776 # 80230e80 <pid_lock>
    80001b80:	97ba                	add	a5,a5,a4
    80001b82:	63c4                	ld	s1,128(a5)
  pop_off();
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	1e6080e7          	jalr	486(ra) # 80000d6a <pop_off>
  return p;
}
    80001b8c:	8526                	mv	a0,s1
    80001b8e:	60e2                	ld	ra,24(sp)
    80001b90:	6442                	ld	s0,16(sp)
    80001b92:	64a2                	ld	s1,8(sp)
    80001b94:	6105                	addi	sp,sp,32
    80001b96:	8082                	ret

0000000080001b98 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b98:	1141                	addi	sp,sp,-16
    80001b9a:	e406                	sd	ra,8(sp)
    80001b9c:	e022                	sd	s0,0(sp)
    80001b9e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001ba0:	00000097          	auipc	ra,0x0
    80001ba4:	fc0080e7          	jalr	-64(ra) # 80001b60 <myproc>
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	222080e7          	jalr	546(ra) # 80000dca <release>

  if (first)
    80001bb0:	00007797          	auipc	a5,0x7
    80001bb4:	f507a783          	lw	a5,-176(a5) # 80008b00 <first.1>
    80001bb8:	eb89                	bnez	a5,80001bca <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001bba:	00001097          	auipc	ra,0x1
    80001bbe:	168080e7          	jalr	360(ra) # 80002d22 <usertrapret>
}
    80001bc2:	60a2                	ld	ra,8(sp)
    80001bc4:	6402                	ld	s0,0(sp)
    80001bc6:	0141                	addi	sp,sp,16
    80001bc8:	8082                	ret
    first = 0;
    80001bca:	00007797          	auipc	a5,0x7
    80001bce:	f207ab23          	sw	zero,-202(a5) # 80008b00 <first.1>
    fsinit(ROOTDEV);
    80001bd2:	4505                	li	a0,1
    80001bd4:	00002097          	auipc	ra,0x2
    80001bd8:	3f2080e7          	jalr	1010(ra) # 80003fc6 <fsinit>
    80001bdc:	bff9                	j	80001bba <forkret+0x22>

0000000080001bde <allocpid>:
{
    80001bde:	1101                	addi	sp,sp,-32
    80001be0:	ec06                	sd	ra,24(sp)
    80001be2:	e822                	sd	s0,16(sp)
    80001be4:	e426                	sd	s1,8(sp)
    80001be6:	e04a                	sd	s2,0(sp)
    80001be8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bea:	0022f917          	auipc	s2,0x22f
    80001bee:	29690913          	addi	s2,s2,662 # 80230e80 <pid_lock>
    80001bf2:	854a                	mv	a0,s2
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	122080e7          	jalr	290(ra) # 80000d16 <acquire>
  pid = nextpid;
    80001bfc:	00007797          	auipc	a5,0x7
    80001c00:	f0878793          	addi	a5,a5,-248 # 80008b04 <nextpid>
    80001c04:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c06:	0014871b          	addiw	a4,s1,1
    80001c0a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c0c:	854a                	mv	a0,s2
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	1bc080e7          	jalr	444(ra) # 80000dca <release>
}
    80001c16:	8526                	mv	a0,s1
    80001c18:	60e2                	ld	ra,24(sp)
    80001c1a:	6442                	ld	s0,16(sp)
    80001c1c:	64a2                	ld	s1,8(sp)
    80001c1e:	6902                	ld	s2,0(sp)
    80001c20:	6105                	addi	sp,sp,32
    80001c22:	8082                	ret

0000000080001c24 <push>:
{
    80001c24:	1141                	addi	sp,sp,-16
    80001c26:	e422                	sd	s0,8(sp)
    80001c28:	0800                	addi	s0,sp,16
  for (int i = 0; i < NPROC; i++)
    80001c2a:	0022f717          	auipc	a4,0x22f
    80001c2e:	6d670713          	addi	a4,a4,1750 # 80231300 <nodes>
    80001c32:	4781                	li	a5,0
    80001c34:	04000613          	li	a2,64
    if (!(nodes[i].p))
    80001c38:	6314                	ld	a3,0(a4)
    80001c3a:	c699                	beqz	a3,80001c48 <push+0x24>
  for (int i = 0; i < NPROC; i++)
    80001c3c:	2785                	addiw	a5,a5,1
    80001c3e:	0741                	addi	a4,a4,16
    80001c40:	fec79ce3          	bne	a5,a2,80001c38 <push+0x14>
  struct node *newNode = 0;
    80001c44:	4681                	li	a3,0
    80001c46:	a039                	j	80001c54 <push+0x30>
      newNode = &(nodes[i]);
    80001c48:	0792                	slli	a5,a5,0x4
    80001c4a:	0022f697          	auipc	a3,0x22f
    80001c4e:	6b668693          	addi	a3,a3,1718 # 80231300 <nodes>
    80001c52:	96be                	add	a3,a3,a5
  newNode->next = 0;
    80001c54:	0006b423          	sd	zero,8(a3)
  newNode->p = p;
    80001c58:	e28c                	sd	a1,0(a3)
  if (!(*head))
    80001c5a:	611c                	ld	a5,0(a0)
    80001c5c:	cb81                	beqz	a5,80001c6c <push+0x48>
    while (cur->next)
    80001c5e:	873e                	mv	a4,a5
    80001c60:	679c                	ld	a5,8(a5)
    80001c62:	fff5                	bnez	a5,80001c5e <push+0x3a>
    cur->next = newNode;
    80001c64:	e714                	sd	a3,8(a4)
}
    80001c66:	6422                	ld	s0,8(sp)
    80001c68:	0141                	addi	sp,sp,16
    80001c6a:	8082                	ret
    *head = newNode;
    80001c6c:	e114                	sd	a3,0(a0)
    80001c6e:	bfe5                	j	80001c66 <push+0x42>

0000000080001c70 <pop>:
{
    80001c70:	1141                	addi	sp,sp,-16
    80001c72:	e422                	sd	s0,8(sp)
    80001c74:	0800                	addi	s0,sp,16
  if (!(*head))
    80001c76:	611c                	ld	a5,0(a0)
    80001c78:	cb89                	beqz	a5,80001c8a <pop+0x1a>
  *head = (*head)->next;
    80001c7a:	6798                	ld	a4,8(a5)
    80001c7c:	e118                	sd	a4,0(a0)
  struct proc *ret = del->p;
    80001c7e:	6388                	ld	a0,0(a5)
  del->p = 0;
    80001c80:	0007b023          	sd	zero,0(a5)
}
    80001c84:	6422                	ld	s0,8(sp)
    80001c86:	0141                	addi	sp,sp,16
    80001c88:	8082                	ret
    return 0;
    80001c8a:	853e                	mv	a0,a5
    80001c8c:	bfe5                	j	80001c84 <pop+0x14>

0000000080001c8e <remove>:
{
    80001c8e:	1141                	addi	sp,sp,-16
    80001c90:	e422                	sd	s0,8(sp)
    80001c92:	0800                	addi	s0,sp,16
  if ((*head)->p->pid == pid)
    80001c94:	611c                	ld	a5,0(a0)
    80001c96:	6398                	ld	a4,0(a5)
    80001c98:	5b18                	lw	a4,48(a4)
    80001c9a:	02b70063          	beq	a4,a1,80001cba <remove+0x2c>
    80001c9e:	86be                	mv	a3,a5
  while (cur && cur->next)
    80001ca0:	679c                	ld	a5,8(a5)
    80001ca2:	cb89                	beqz	a5,80001cb4 <remove+0x26>
    if (cur->next->p->pid == pid)
    80001ca4:	6398                	ld	a4,0(a5)
    80001ca6:	5b18                	lw	a4,48(a4)
    80001ca8:	feb71be3          	bne	a4,a1,80001c9e <remove+0x10>
      cur->next = del->next;
    80001cac:	6798                	ld	a4,8(a5)
    80001cae:	e698                	sd	a4,8(a3)
      del->p = 0;
    80001cb0:	0007b023          	sd	zero,0(a5)
}
    80001cb4:	6422                	ld	s0,8(sp)
    80001cb6:	0141                	addi	sp,sp,16
    80001cb8:	8082                	ret
    (*head)->p = 0;
    80001cba:	0007b023          	sd	zero,0(a5)
    *head = (*head)->next;
    80001cbe:	611c                	ld	a5,0(a0)
    80001cc0:	679c                	ld	a5,8(a5)
    80001cc2:	e11c                	sd	a5,0(a0)
    return;
    80001cc4:	bfc5                	j	80001cb4 <remove+0x26>

0000000080001cc6 <proc_pagetable>:
{
    80001cc6:	1101                	addi	sp,sp,-32
    80001cc8:	ec06                	sd	ra,24(sp)
    80001cca:	e822                	sd	s0,16(sp)
    80001ccc:	e426                	sd	s1,8(sp)
    80001cce:	e04a                	sd	s2,0(sp)
    80001cd0:	1000                	addi	s0,sp,32
    80001cd2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	794080e7          	jalr	1940(ra) # 80001468 <uvmcreate>
    80001cdc:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001cde:	c121                	beqz	a0,80001d1e <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ce0:	4729                	li	a4,10
    80001ce2:	00005697          	auipc	a3,0x5
    80001ce6:	31e68693          	addi	a3,a3,798 # 80007000 <_trampoline>
    80001cea:	6605                	lui	a2,0x1
    80001cec:	040005b7          	lui	a1,0x4000
    80001cf0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cf2:	05b2                	slli	a1,a1,0xc
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	4ea080e7          	jalr	1258(ra) # 800011de <mappages>
    80001cfc:	02054863          	bltz	a0,80001d2c <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d00:	4719                	li	a4,6
    80001d02:	05893683          	ld	a3,88(s2)
    80001d06:	6605                	lui	a2,0x1
    80001d08:	020005b7          	lui	a1,0x2000
    80001d0c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d0e:	05b6                	slli	a1,a1,0xd
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	4cc080e7          	jalr	1228(ra) # 800011de <mappages>
    80001d1a:	02054163          	bltz	a0,80001d3c <proc_pagetable+0x76>
}
    80001d1e:	8526                	mv	a0,s1
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6902                	ld	s2,0(sp)
    80001d28:	6105                	addi	sp,sp,32
    80001d2a:	8082                	ret
    uvmfree(pagetable, 0);
    80001d2c:	4581                	li	a1,0
    80001d2e:	8526                	mv	a0,s1
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	93e080e7          	jalr	-1730(ra) # 8000166e <uvmfree>
    return 0;
    80001d38:	4481                	li	s1,0
    80001d3a:	b7d5                	j	80001d1e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d3c:	4681                	li	a3,0
    80001d3e:	4605                	li	a2,1
    80001d40:	040005b7          	lui	a1,0x4000
    80001d44:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d46:	05b2                	slli	a1,a1,0xc
    80001d48:	8526                	mv	a0,s1
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	65a080e7          	jalr	1626(ra) # 800013a4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d52:	4581                	li	a1,0
    80001d54:	8526                	mv	a0,s1
    80001d56:	00000097          	auipc	ra,0x0
    80001d5a:	918080e7          	jalr	-1768(ra) # 8000166e <uvmfree>
    return 0;
    80001d5e:	4481                	li	s1,0
    80001d60:	bf7d                	j	80001d1e <proc_pagetable+0x58>

0000000080001d62 <proc_freepagetable>:
{
    80001d62:	1101                	addi	sp,sp,-32
    80001d64:	ec06                	sd	ra,24(sp)
    80001d66:	e822                	sd	s0,16(sp)
    80001d68:	e426                	sd	s1,8(sp)
    80001d6a:	e04a                	sd	s2,0(sp)
    80001d6c:	1000                	addi	s0,sp,32
    80001d6e:	84aa                	mv	s1,a0
    80001d70:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d72:	4681                	li	a3,0
    80001d74:	4605                	li	a2,1
    80001d76:	040005b7          	lui	a1,0x4000
    80001d7a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d7c:	05b2                	slli	a1,a1,0xc
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	626080e7          	jalr	1574(ra) # 800013a4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d86:	4681                	li	a3,0
    80001d88:	4605                	li	a2,1
    80001d8a:	020005b7          	lui	a1,0x2000
    80001d8e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d90:	05b6                	slli	a1,a1,0xd
    80001d92:	8526                	mv	a0,s1
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	610080e7          	jalr	1552(ra) # 800013a4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d9c:	85ca                	mv	a1,s2
    80001d9e:	8526                	mv	a0,s1
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	8ce080e7          	jalr	-1842(ra) # 8000166e <uvmfree>
}
    80001da8:	60e2                	ld	ra,24(sp)
    80001daa:	6442                	ld	s0,16(sp)
    80001dac:	64a2                	ld	s1,8(sp)
    80001dae:	6902                	ld	s2,0(sp)
    80001db0:	6105                	addi	sp,sp,32
    80001db2:	8082                	ret

0000000080001db4 <freeproc>:
{
    80001db4:	1101                	addi	sp,sp,-32
    80001db6:	ec06                	sd	ra,24(sp)
    80001db8:	e822                	sd	s0,16(sp)
    80001dba:	e426                	sd	s1,8(sp)
    80001dbc:	1000                	addi	s0,sp,32
    80001dbe:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001dc0:	6d28                	ld	a0,88(a0)
    80001dc2:	c509                	beqz	a0,80001dcc <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	ca0080e7          	jalr	-864(ra) # 80000a64 <kfree>
  if (p->tf_copy)
    80001dcc:	1c84b503          	ld	a0,456(s1)
    80001dd0:	c509                	beqz	a0,80001dda <freeproc+0x26>
    kfree((void *)p->tf_copy);
    80001dd2:	fffff097          	auipc	ra,0xfffff
    80001dd6:	c92080e7          	jalr	-878(ra) # 80000a64 <kfree>
  p->trapframe = 0;
    80001dda:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001dde:	68a8                	ld	a0,80(s1)
    80001de0:	c511                	beqz	a0,80001dec <freeproc+0x38>
    proc_freepagetable(p->pagetable, p->sz);
    80001de2:	64ac                	ld	a1,72(s1)
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	f7e080e7          	jalr	-130(ra) # 80001d62 <proc_freepagetable>
  p->pagetable = 0;
    80001dec:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001df0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001df4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001df8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001dfc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e00:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e04:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e08:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001e0c:	0004ac23          	sw	zero,24(s1)
}
    80001e10:	60e2                	ld	ra,24(sp)
    80001e12:	6442                	ld	s0,16(sp)
    80001e14:	64a2                	ld	s1,8(sp)
    80001e16:	6105                	addi	sp,sp,32
    80001e18:	8082                	ret

0000000080001e1a <allocproc>:
{
    80001e1a:	1101                	addi	sp,sp,-32
    80001e1c:	ec06                	sd	ra,24(sp)
    80001e1e:	e822                	sd	s0,16(sp)
    80001e20:	e426                	sd	s1,8(sp)
    80001e22:	e04a                	sd	s2,0(sp)
    80001e24:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001e26:	00230497          	auipc	s1,0x230
    80001e2a:	8da48493          	addi	s1,s1,-1830 # 80231700 <proc>
    80001e2e:	00237917          	auipc	s2,0x237
    80001e32:	ed290913          	addi	s2,s2,-302 # 80238d00 <tickslock>
    acquire(&p->lock);
    80001e36:	8526                	mv	a0,s1
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	ede080e7          	jalr	-290(ra) # 80000d16 <acquire>
    if (p->state == UNUSED)
    80001e40:	4c9c                	lw	a5,24(s1)
    80001e42:	cf81                	beqz	a5,80001e5a <allocproc+0x40>
      release(&p->lock);
    80001e44:	8526                	mv	a0,s1
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	f84080e7          	jalr	-124(ra) # 80000dca <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001e4e:	1d848493          	addi	s1,s1,472
    80001e52:	ff2492e3          	bne	s1,s2,80001e36 <allocproc+0x1c>
  return 0;
    80001e56:	4481                	li	s1,0
    80001e58:	a0e9                	j	80001f22 <allocproc+0x108>
  p->pid = allocpid();
    80001e5a:	00000097          	auipc	ra,0x0
    80001e5e:	d84080e7          	jalr	-636(ra) # 80001bde <allocpid>
    80001e62:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e64:	4785                	li	a5,1
    80001e66:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	d80080e7          	jalr	-640(ra) # 80000be8 <kalloc>
    80001e70:	892a                	mv	s2,a0
    80001e72:	eca8                	sd	a0,88(s1)
    80001e74:	cd55                	beqz	a0,80001f30 <allocproc+0x116>
  p->pagetable = proc_pagetable(p);
    80001e76:	8526                	mv	a0,s1
    80001e78:	00000097          	auipc	ra,0x0
    80001e7c:	e4e080e7          	jalr	-434(ra) # 80001cc6 <proc_pagetable>
    80001e80:	892a                	mv	s2,a0
    80001e82:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001e84:	c171                	beqz	a0,80001f48 <allocproc+0x12e>
  memset(&p->context, 0, sizeof(p->context));
    80001e86:	07000613          	li	a2,112
    80001e8a:	4581                	li	a1,0
    80001e8c:	06048513          	addi	a0,s1,96
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	f82080e7          	jalr	-126(ra) # 80000e12 <memset>
  p->context.ra = (uint64)forkret;
    80001e98:	00000797          	auipc	a5,0x0
    80001e9c:	d0078793          	addi	a5,a5,-768 # 80001b98 <forkret>
    80001ea0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ea2:	60bc                	ld	a5,64(s1)
    80001ea4:	6705                	lui	a4,0x1
    80001ea6:	97ba                	add	a5,a5,a4
    80001ea8:	f4bc                	sd	a5,104(s1)
  if ((p->tf_copy = (struct trapframe *)kalloc()) == 0)
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	d3e080e7          	jalr	-706(ra) # 80000be8 <kalloc>
    80001eb2:	892a                	mv	s2,a0
    80001eb4:	1ca4b423          	sd	a0,456(s1)
    80001eb8:	c545                	beqz	a0,80001f60 <allocproc+0x146>
  p->readid = 0;
    80001eba:	1c04a823          	sw	zero,464(s1)
  p->starttime = ticks; // initialise starting time of process
    80001ebe:	00007797          	auipc	a5,0x7
    80001ec2:	d527a783          	lw	a5,-686(a5) # 80008c10 <ticks>
    80001ec6:	16f4a623          	sw	a5,364(s1)
  p->runtime = 0;
    80001eca:	1604aa23          	sw	zero,372(s1)
  p->sleeptime = 0;
    80001ece:	1604ac23          	sw	zero,376(s1)
  p->is_sigalarm = 0;
    80001ed2:	1a04a623          	sw	zero,428(s1)
  p->alarmhandler = 0; // function
    80001ed6:	1a04bc23          	sd	zero,440(s1)
  p->alarmint = 0;     // alarm interval
    80001eda:	1a04a823          	sw	zero,432(s1)
  p->tslalarm = 0;     // time since last alarm
    80001ede:	1c04a023          	sw	zero,448(s1)
  p->tickets = 1; // by default each process has 1 ticket
    80001ee2:	4705                	li	a4,1
    80001ee4:	16e4a823          	sw	a4,368(s1)
  p->niceness = 5;    // default
    80001ee8:	4695                	li	a3,5
    80001eea:	16d4ae23          	sw	a3,380(s1)
  p->stpriority = 60; // static priority
    80001eee:	03c00693          	li	a3,60
    80001ef2:	18d4a023          	sw	a3,384(s1)
  p->numpicked = 0;   // number of times picked by scheduler
    80001ef6:	1804a223          	sw	zero,388(s1)
  p->queueno = 0;
    80001efa:	1804a423          	sw	zero,392(s1)
  p->inqueue = 0;
    80001efe:	1804a623          	sw	zero,396(s1)
  p->timeslice = 1;
    80001f02:	18e4a823          	sw	a4,400(s1)
  p->qitime = ticks;
    80001f06:	18f4aa23          	sw	a5,404(s1)
    p->qrtime[i] = 0;
    80001f0a:	1804ac23          	sw	zero,408(s1)
    80001f0e:	1804ae23          	sw	zero,412(s1)
    80001f12:	1a04a023          	sw	zero,416(s1)
    80001f16:	1a04a223          	sw	zero,420(s1)
    80001f1a:	1a04a423          	sw	zero,424(s1)
  p->etime = 0;
    80001f1e:	1c04aa23          	sw	zero,468(s1)
}
    80001f22:	8526                	mv	a0,s1
    80001f24:	60e2                	ld	ra,24(sp)
    80001f26:	6442                	ld	s0,16(sp)
    80001f28:	64a2                	ld	s1,8(sp)
    80001f2a:	6902                	ld	s2,0(sp)
    80001f2c:	6105                	addi	sp,sp,32
    80001f2e:	8082                	ret
    freeproc(p);
    80001f30:	8526                	mv	a0,s1
    80001f32:	00000097          	auipc	ra,0x0
    80001f36:	e82080e7          	jalr	-382(ra) # 80001db4 <freeproc>
    release(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	e8e080e7          	jalr	-370(ra) # 80000dca <release>
    return 0;
    80001f44:	84ca                	mv	s1,s2
    80001f46:	bff1                	j	80001f22 <allocproc+0x108>
    freeproc(p);
    80001f48:	8526                	mv	a0,s1
    80001f4a:	00000097          	auipc	ra,0x0
    80001f4e:	e6a080e7          	jalr	-406(ra) # 80001db4 <freeproc>
    release(&p->lock);
    80001f52:	8526                	mv	a0,s1
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	e76080e7          	jalr	-394(ra) # 80000dca <release>
    return 0;
    80001f5c:	84ca                	mv	s1,s2
    80001f5e:	b7d1                	j	80001f22 <allocproc+0x108>
    release(&p->lock);
    80001f60:	8526                	mv	a0,s1
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	e68080e7          	jalr	-408(ra) # 80000dca <release>
    return 0;
    80001f6a:	84ca                	mv	s1,s2
    80001f6c:	bf5d                	j	80001f22 <allocproc+0x108>

0000000080001f6e <userinit>:
{
    80001f6e:	1101                	addi	sp,sp,-32
    80001f70:	ec06                	sd	ra,24(sp)
    80001f72:	e822                	sd	s0,16(sp)
    80001f74:	e426                	sd	s1,8(sp)
    80001f76:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f78:	00000097          	auipc	ra,0x0
    80001f7c:	ea2080e7          	jalr	-350(ra) # 80001e1a <allocproc>
    80001f80:	84aa                	mv	s1,a0
  initproc = p;
    80001f82:	00007797          	auipc	a5,0x7
    80001f86:	c8a7b323          	sd	a0,-890(a5) # 80008c08 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f8a:	03400613          	li	a2,52
    80001f8e:	00007597          	auipc	a1,0x7
    80001f92:	b8258593          	addi	a1,a1,-1150 # 80008b10 <initcode>
    80001f96:	6928                	ld	a0,80(a0)
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	4fe080e7          	jalr	1278(ra) # 80001496 <uvmfirst>
  p->sz = PGSIZE;
    80001fa0:	6785                	lui	a5,0x1
    80001fa2:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001fa4:	6cb8                	ld	a4,88(s1)
    80001fa6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001faa:	6cb8                	ld	a4,88(s1)
    80001fac:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001fae:	4641                	li	a2,16
    80001fb0:	00006597          	auipc	a1,0x6
    80001fb4:	29058593          	addi	a1,a1,656 # 80008240 <digits+0x200>
    80001fb8:	15848513          	addi	a0,s1,344
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	fa0080e7          	jalr	-96(ra) # 80000f5c <safestrcpy>
  p->cwd = namei("/");
    80001fc4:	00006517          	auipc	a0,0x6
    80001fc8:	28c50513          	addi	a0,a0,652 # 80008250 <digits+0x210>
    80001fcc:	00003097          	auipc	ra,0x3
    80001fd0:	a24080e7          	jalr	-1500(ra) # 800049f0 <namei>
    80001fd4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001fd8:	478d                	li	a5,3
    80001fda:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	dec080e7          	jalr	-532(ra) # 80000dca <release>
}
    80001fe6:	60e2                	ld	ra,24(sp)
    80001fe8:	6442                	ld	s0,16(sp)
    80001fea:	64a2                	ld	s1,8(sp)
    80001fec:	6105                	addi	sp,sp,32
    80001fee:	8082                	ret

0000000080001ff0 <growproc>:
{
    80001ff0:	1101                	addi	sp,sp,-32
    80001ff2:	ec06                	sd	ra,24(sp)
    80001ff4:	e822                	sd	s0,16(sp)
    80001ff6:	e426                	sd	s1,8(sp)
    80001ff8:	e04a                	sd	s2,0(sp)
    80001ffa:	1000                	addi	s0,sp,32
    80001ffc:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	b62080e7          	jalr	-1182(ra) # 80001b60 <myproc>
    80002006:	84aa                	mv	s1,a0
  sz = p->sz;
    80002008:	652c                	ld	a1,72(a0)
  if (n > 0)
    8000200a:	01204c63          	bgtz	s2,80002022 <growproc+0x32>
  else if (n < 0)
    8000200e:	02094663          	bltz	s2,8000203a <growproc+0x4a>
  p->sz = sz;
    80002012:	e4ac                	sd	a1,72(s1)
  return 0;
    80002014:	4501                	li	a0,0
}
    80002016:	60e2                	ld	ra,24(sp)
    80002018:	6442                	ld	s0,16(sp)
    8000201a:	64a2                	ld	s1,8(sp)
    8000201c:	6902                	ld	s2,0(sp)
    8000201e:	6105                	addi	sp,sp,32
    80002020:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002022:	4691                	li	a3,4
    80002024:	00b90633          	add	a2,s2,a1
    80002028:	6928                	ld	a0,80(a0)
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	526080e7          	jalr	1318(ra) # 80001550 <uvmalloc>
    80002032:	85aa                	mv	a1,a0
    80002034:	fd79                	bnez	a0,80002012 <growproc+0x22>
      return -1;
    80002036:	557d                	li	a0,-1
    80002038:	bff9                	j	80002016 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000203a:	00b90633          	add	a2,s2,a1
    8000203e:	6928                	ld	a0,80(a0)
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	4c8080e7          	jalr	1224(ra) # 80001508 <uvmdealloc>
    80002048:	85aa                	mv	a1,a0
    8000204a:	b7e1                	j	80002012 <growproc+0x22>

000000008000204c <fork>:
{
    8000204c:	7139                	addi	sp,sp,-64
    8000204e:	fc06                	sd	ra,56(sp)
    80002050:	f822                	sd	s0,48(sp)
    80002052:	f426                	sd	s1,40(sp)
    80002054:	f04a                	sd	s2,32(sp)
    80002056:	ec4e                	sd	s3,24(sp)
    80002058:	e852                	sd	s4,16(sp)
    8000205a:	e456                	sd	s5,8(sp)
    8000205c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000205e:	00000097          	auipc	ra,0x0
    80002062:	b02080e7          	jalr	-1278(ra) # 80001b60 <myproc>
    80002066:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	db2080e7          	jalr	-590(ra) # 80001e1a <allocproc>
    80002070:	12050463          	beqz	a0,80002198 <fork+0x14c>
    80002074:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002076:	048ab603          	ld	a2,72(s5)
    8000207a:	692c                	ld	a1,80(a0)
    8000207c:	050ab503          	ld	a0,80(s5)
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	628080e7          	jalr	1576(ra) # 800016a8 <uvmcopy>
    80002088:	06054063          	bltz	a0,800020e8 <fork+0x9c>
  np->sz = p->sz;
    8000208c:	048ab783          	ld	a5,72(s5)
    80002090:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002094:	058ab683          	ld	a3,88(s5)
    80002098:	87b6                	mv	a5,a3
    8000209a:	0589b703          	ld	a4,88(s3)
    8000209e:	12068693          	addi	a3,a3,288
    800020a2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800020a6:	6788                	ld	a0,8(a5)
    800020a8:	6b8c                	ld	a1,16(a5)
    800020aa:	6f90                	ld	a2,24(a5)
    800020ac:	01073023          	sd	a6,0(a4)
    800020b0:	e708                	sd	a0,8(a4)
    800020b2:	eb0c                	sd	a1,16(a4)
    800020b4:	ef10                	sd	a2,24(a4)
    800020b6:	02078793          	addi	a5,a5,32
    800020ba:	02070713          	addi	a4,a4,32
    800020be:	fed792e3          	bne	a5,a3,800020a2 <fork+0x56>
  np->mask = p->mask;       // copy mask
    800020c2:	168aa783          	lw	a5,360(s5)
    800020c6:	16f9a423          	sw	a5,360(s3)
  np->tickets = p->tickets; // child should have same number of tickets
    800020ca:	170aa783          	lw	a5,368(s5)
    800020ce:	16f9a823          	sw	a5,368(s3)
  np->trapframe->a0 = 0;
    800020d2:	0589b783          	ld	a5,88(s3)
    800020d6:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    800020da:	0d0a8493          	addi	s1,s5,208
    800020de:	0d098913          	addi	s2,s3,208
    800020e2:	150a8a13          	addi	s4,s5,336
    800020e6:	a00d                	j	80002108 <fork+0xbc>
    freeproc(np);
    800020e8:	854e                	mv	a0,s3
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	cca080e7          	jalr	-822(ra) # 80001db4 <freeproc>
    release(&np->lock);
    800020f2:	854e                	mv	a0,s3
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	cd6080e7          	jalr	-810(ra) # 80000dca <release>
    return -1;
    800020fc:	597d                	li	s2,-1
    800020fe:	a059                	j	80002184 <fork+0x138>
  for (i = 0; i < NOFILE; i++)
    80002100:	04a1                	addi	s1,s1,8
    80002102:	0921                	addi	s2,s2,8
    80002104:	01448b63          	beq	s1,s4,8000211a <fork+0xce>
    if (p->ofile[i])
    80002108:	6088                	ld	a0,0(s1)
    8000210a:	d97d                	beqz	a0,80002100 <fork+0xb4>
      np->ofile[i] = filedup(p->ofile[i]);
    8000210c:	00003097          	auipc	ra,0x3
    80002110:	f7a080e7          	jalr	-134(ra) # 80005086 <filedup>
    80002114:	00a93023          	sd	a0,0(s2)
    80002118:	b7e5                	j	80002100 <fork+0xb4>
  np->cwd = idup(p->cwd);
    8000211a:	150ab503          	ld	a0,336(s5)
    8000211e:	00002097          	auipc	ra,0x2
    80002122:	0e8080e7          	jalr	232(ra) # 80004206 <idup>
    80002126:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000212a:	4641                	li	a2,16
    8000212c:	158a8593          	addi	a1,s5,344
    80002130:	15898513          	addi	a0,s3,344
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	e28080e7          	jalr	-472(ra) # 80000f5c <safestrcpy>
  pid = np->pid;
    8000213c:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002140:	854e                	mv	a0,s3
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	c88080e7          	jalr	-888(ra) # 80000dca <release>
  acquire(&wait_lock);
    8000214a:	0022f497          	auipc	s1,0x22f
    8000214e:	d4e48493          	addi	s1,s1,-690 # 80230e98 <wait_lock>
    80002152:	8526                	mv	a0,s1
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	bc2080e7          	jalr	-1086(ra) # 80000d16 <acquire>
  np->parent = p;
    8000215c:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002160:	8526                	mv	a0,s1
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	c68080e7          	jalr	-920(ra) # 80000dca <release>
  acquire(&np->lock);
    8000216a:	854e                	mv	a0,s3
    8000216c:	fffff097          	auipc	ra,0xfffff
    80002170:	baa080e7          	jalr	-1110(ra) # 80000d16 <acquire>
  np->state = RUNNABLE;
    80002174:	478d                	li	a5,3
    80002176:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000217a:	854e                	mv	a0,s3
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	c4e080e7          	jalr	-946(ra) # 80000dca <release>
}
    80002184:	854a                	mv	a0,s2
    80002186:	70e2                	ld	ra,56(sp)
    80002188:	7442                	ld	s0,48(sp)
    8000218a:	74a2                	ld	s1,40(sp)
    8000218c:	7902                	ld	s2,32(sp)
    8000218e:	69e2                	ld	s3,24(sp)
    80002190:	6a42                	ld	s4,16(sp)
    80002192:	6aa2                	ld	s5,8(sp)
    80002194:	6121                	addi	sp,sp,64
    80002196:	8082                	ret
    return -1;
    80002198:	597d                	li	s2,-1
    8000219a:	b7ed                	j	80002184 <fork+0x138>

000000008000219c <scheduler>:
{
    8000219c:	7159                	addi	sp,sp,-112
    8000219e:	f486                	sd	ra,104(sp)
    800021a0:	f0a2                	sd	s0,96(sp)
    800021a2:	eca6                	sd	s1,88(sp)
    800021a4:	e8ca                	sd	s2,80(sp)
    800021a6:	e4ce                	sd	s3,72(sp)
    800021a8:	e0d2                	sd	s4,64(sp)
    800021aa:	fc56                	sd	s5,56(sp)
    800021ac:	f85a                	sd	s6,48(sp)
    800021ae:	f45e                	sd	s7,40(sp)
    800021b0:	f062                	sd	s8,32(sp)
    800021b2:	ec66                	sd	s9,24(sp)
    800021b4:	e86a                	sd	s10,16(sp)
    800021b6:	e46e                	sd	s11,8(sp)
    800021b8:	1880                	addi	s0,sp,112
    800021ba:	8492                	mv	s1,tp
  int id = r_tp();
    800021bc:	2481                	sext.w	s1,s1
  c->proc = 0;
    800021be:	00749c93          	slli	s9,s1,0x7
    800021c2:	0022f797          	auipc	a5,0x22f
    800021c6:	cbe78793          	addi	a5,a5,-834 # 80230e80 <pid_lock>
    800021ca:	97e6                	add	a5,a5,s9
    800021cc:	0807b023          	sd	zero,128(a5)
  printf("Scheduler : MLFQ jvghjvjhvhjvghjvhgbnc \n");
    800021d0:	00006517          	auipc	a0,0x6
    800021d4:	08850513          	addi	a0,a0,136 # 80008258 <digits+0x218>
    800021d8:	ffffe097          	auipc	ra,0xffffe
    800021dc:	3b2080e7          	jalr	946(ra) # 8000058a <printf>
    swtch(&c->context, &chosenproc->context);
    800021e0:	0022f797          	auipc	a5,0x22f
    800021e4:	d2878793          	addi	a5,a5,-728 # 80230f08 <cpus+0x8>
    800021e8:	9cbe                	add	s9,s9,a5
      if ((p->state == RUNNABLE) && (ticks - p->qitime >= 128))
    800021ea:	00007a97          	auipc	s5,0x7
    800021ee:	a26a8a93          	addi	s5,s5,-1498 # 80008c10 <ticks>
          remove(&(queues[p->queueno].head), p->pid);
    800021f2:	0022fb17          	auipc	s6,0x22f
    800021f6:	c8eb0b13          	addi	s6,s6,-882 # 80230e80 <pid_lock>
    800021fa:	0022fb97          	auipc	s7,0x22f
    800021fe:	cb6b8b93          	addi	s7,s7,-842 # 80230eb0 <queues>
    c->proc = chosenproc;
    80002202:	049e                	slli	s1,s1,0x7
    80002204:	009b0c33          	add	s8,s6,s1
    80002208:	a231                	j	80002314 <scheduler+0x178>
          remove(&(queues[p->queueno].head), p->pid);
    8000220a:	1884a503          	lw	a0,392(s1)
    8000220e:	0512                	slli	a0,a0,0x4
    80002210:	588c                	lw	a1,48(s1)
    80002212:	955e                	add	a0,a0,s7
    80002214:	00000097          	auipc	ra,0x0
    80002218:	a7a080e7          	jalr	-1414(ra) # 80001c8e <remove>
          queues[p->queueno].size--;
    8000221c:	1884a783          	lw	a5,392(s1)
    80002220:	0792                	slli	a5,a5,0x4
    80002222:	97da                	add	a5,a5,s6
    80002224:	5f98                	lw	a4,56(a5)
    80002226:	377d                	addiw	a4,a4,-1
    80002228:	df98                	sw	a4,56(a5)
          p->inqueue = 0;
    8000222a:	1804a623          	sw	zero,396(s1)
    8000222e:	a02d                	j	80002258 <scheduler+0xbc>
    for (p = proc; p < &proc[NPROC]; p++)
    80002230:	1d848493          	addi	s1,s1,472
    80002234:	03448963          	beq	s1,s4,80002266 <scheduler+0xca>
      if ((p->state == RUNNABLE) && (ticks - p->qitime >= 128))
    80002238:	4c9c                	lw	a5,24(s1)
    8000223a:	ff379be3          	bne	a5,s3,80002230 <scheduler+0x94>
    8000223e:	000aa703          	lw	a4,0(s5)
    80002242:	1944a783          	lw	a5,404(s1)
    80002246:	40f707bb          	subw	a5,a4,a5
    8000224a:	fef973e3          	bgeu	s2,a5,80002230 <scheduler+0x94>
        p->qitime = ticks;
    8000224e:	18e4aa23          	sw	a4,404(s1)
        if (p->inqueue)
    80002252:	18c4a783          	lw	a5,396(s1)
    80002256:	fbd5                	bnez	a5,8000220a <scheduler+0x6e>
        if (p->queueno != 0)
    80002258:	1884a783          	lw	a5,392(s1)
    8000225c:	dbf1                	beqz	a5,80002230 <scheduler+0x94>
          p->queueno--;
    8000225e:	37fd                	addiw	a5,a5,-1
    80002260:	18f4a423          	sw	a5,392(s1)
    80002264:	b7f1                	j	80002230 <scheduler+0x94>
    for (p = proc; p < &proc[NPROC]; p++)
    80002266:	0022f497          	auipc	s1,0x22f
    8000226a:	49a48493          	addi	s1,s1,1178 # 80231700 <proc>
        p->inqueue = 1;
    8000226e:	4905                	li	s2,1
    80002270:	a811                	j	80002284 <scheduler+0xe8>
      release(&p->lock);
    80002272:	8526                	mv	a0,s1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	b56080e7          	jalr	-1194(ra) # 80000dca <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000227c:	1d848493          	addi	s1,s1,472
    80002280:	05448063          	beq	s1,s4,800022c0 <scheduler+0x124>
      acquire(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	a90080e7          	jalr	-1392(ra) # 80000d16 <acquire>
      if ((p->state == RUNNABLE) && (p->inqueue == 0))
    8000228e:	4c9c                	lw	a5,24(s1)
    80002290:	ff3791e3          	bne	a5,s3,80002272 <scheduler+0xd6>
    80002294:	18c4a783          	lw	a5,396(s1)
    80002298:	ffe9                	bnez	a5,80002272 <scheduler+0xd6>
        push(&(queues[p->queueno].head), p);
    8000229a:	1884a503          	lw	a0,392(s1)
    8000229e:	0512                	slli	a0,a0,0x4
    800022a0:	85a6                	mv	a1,s1
    800022a2:	955e                	add	a0,a0,s7
    800022a4:	00000097          	auipc	ra,0x0
    800022a8:	980080e7          	jalr	-1664(ra) # 80001c24 <push>
        queues[p->queueno].size++;
    800022ac:	1884a783          	lw	a5,392(s1)
    800022b0:	0792                	slli	a5,a5,0x4
    800022b2:	97da                	add	a5,a5,s6
    800022b4:	5f98                	lw	a4,56(a5)
    800022b6:	2705                	addiw	a4,a4,1
    800022b8:	df98                	sw	a4,56(a5)
        p->inqueue = 1;
    800022ba:	1924a623          	sw	s2,396(s1)
    800022be:	bf55                	j	80002272 <scheduler+0xd6>
    800022c0:	0022fd17          	auipc	s10,0x22f
    800022c4:	bf0d0d13          	addi	s10,s10,-1040 # 80230eb0 <queues>
    800022c8:	0022fd97          	auipc	s11,0x22f
    800022cc:	c38d8d93          	addi	s11,s11,-968 # 80230f00 <cpus>
    800022d0:	a0bd                	j	8000233e <scheduler+0x1a2>
          p->qitime = ticks;
    800022d2:	000aa783          	lw	a5,0(s5)
    800022d6:	18f52a23          	sw	a5,404(a0)
    chosenproc->timeslice = 1 << (chosenproc->queueno);
    800022da:	18852703          	lw	a4,392(a0)
    800022de:	4785                	li	a5,1
    800022e0:	00e797bb          	sllw	a5,a5,a4
    800022e4:	18f52823          	sw	a5,400(a0)
    chosenproc->state = RUNNING;
    800022e8:	4791                	li	a5,4
    800022ea:	cd1c                	sw	a5,24(a0)
    c->proc = chosenproc;
    800022ec:	08ac3023          	sd	a0,128(s8) # 1080 <_entry-0x7fffef80>
    swtch(&c->context, &chosenproc->context);
    800022f0:	06050593          	addi	a1,a0,96
    800022f4:	8566                	mv	a0,s9
    800022f6:	00001097          	auipc	ra,0x1
    800022fa:	8ee080e7          	jalr	-1810(ra) # 80002be4 <swtch>
    c->proc = 0;
    800022fe:	080c3023          	sd	zero,128(s8)
    chosenproc->qitime = ticks;
    80002302:	000aa783          	lw	a5,0(s5)
    80002306:	18f4aa23          	sw	a5,404(s1)
    release(&chosenproc->lock);
    8000230a:	8526                	mv	a0,s1
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	abe080e7          	jalr	-1346(ra) # 80000dca <release>
      if ((p->state == RUNNABLE) && (ticks - p->qitime >= 128))
    80002314:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002316:	00237a17          	auipc	s4,0x237
    8000231a:	9eaa0a13          	addi	s4,s4,-1558 # 80238d00 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000231e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002322:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002326:	10079073          	csrw	sstatus,a5
    8000232a:	0022f497          	auipc	s1,0x22f
    8000232e:	3d648493          	addi	s1,s1,982 # 80231700 <proc>
      if ((p->state == RUNNABLE) && (ticks - p->qitime >= 128))
    80002332:	07f00913          	li	s2,127
    80002336:	b709                	j	80002238 <scheduler+0x9c>
    for (int qno = 0; qno < 5; qno++)
    80002338:	0d41                	addi	s10,s10,16
    8000233a:	ffad82e3          	beq	s11,s10,8000231e <scheduler+0x182>
      while (queues[qno].size)
    8000233e:	896a                	mv	s2,s10
    80002340:	008d2783          	lw	a5,8(s10)
    80002344:	dbf5                	beqz	a5,80002338 <scheduler+0x19c>
        p = (queues[qno].head)->p;
    80002346:	00093783          	ld	a5,0(s2)
        acquire(&p->lock);
    8000234a:	6388                	ld	a0,0(a5)
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	9ca080e7          	jalr	-1590(ra) # 80000d16 <acquire>
        p = pop(&(queues[qno].head)); // POPPPING THE PROCESS
    80002354:	854a                	mv	a0,s2
    80002356:	00000097          	auipc	ra,0x0
    8000235a:	91a080e7          	jalr	-1766(ra) # 80001c70 <pop>
    8000235e:	84aa                	mv	s1,a0
        queues[qno].size--;
    80002360:	00892783          	lw	a5,8(s2)
    80002364:	37fd                	addiw	a5,a5,-1
    80002366:	00f92423          	sw	a5,8(s2)
        p->inqueue = 0;
    8000236a:	18052623          	sw	zero,396(a0)
        if (p->state == RUNNABLE)
    8000236e:	4d1c                	lw	a5,24(a0)
    80002370:	f73781e3          	beq	a5,s3,800022d2 <scheduler+0x136>
        release(&p->lock);
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	a56080e7          	jalr	-1450(ra) # 80000dca <release>
      while (queues[qno].size)
    8000237c:	00892783          	lw	a5,8(s2)
    80002380:	f3f9                	bnez	a5,80002346 <scheduler+0x1aa>
    80002382:	bf5d                	j	80002338 <scheduler+0x19c>

0000000080002384 <sched>:
{
    80002384:	7179                	addi	sp,sp,-48
    80002386:	f406                	sd	ra,40(sp)
    80002388:	f022                	sd	s0,32(sp)
    8000238a:	ec26                	sd	s1,24(sp)
    8000238c:	e84a                	sd	s2,16(sp)
    8000238e:	e44e                	sd	s3,8(sp)
    80002390:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	7ce080e7          	jalr	1998(ra) # 80001b60 <myproc>
    8000239a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000239c:	fffff097          	auipc	ra,0xfffff
    800023a0:	900080e7          	jalr	-1792(ra) # 80000c9c <holding>
    800023a4:	c93d                	beqz	a0,8000241a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023a6:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800023a8:	2781                	sext.w	a5,a5
    800023aa:	079e                	slli	a5,a5,0x7
    800023ac:	0022f717          	auipc	a4,0x22f
    800023b0:	ad470713          	addi	a4,a4,-1324 # 80230e80 <pid_lock>
    800023b4:	97ba                	add	a5,a5,a4
    800023b6:	0f87a703          	lw	a4,248(a5)
    800023ba:	4785                	li	a5,1
    800023bc:	06f71763          	bne	a4,a5,8000242a <sched+0xa6>
  if (p->state == RUNNING)
    800023c0:	4c98                	lw	a4,24(s1)
    800023c2:	4791                	li	a5,4
    800023c4:	06f70b63          	beq	a4,a5,8000243a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023c8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023cc:	8b89                	andi	a5,a5,2
  if (intr_get())
    800023ce:	efb5                	bnez	a5,8000244a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023d0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023d2:	0022f917          	auipc	s2,0x22f
    800023d6:	aae90913          	addi	s2,s2,-1362 # 80230e80 <pid_lock>
    800023da:	2781                	sext.w	a5,a5
    800023dc:	079e                	slli	a5,a5,0x7
    800023de:	97ca                	add	a5,a5,s2
    800023e0:	0fc7a983          	lw	s3,252(a5)
    800023e4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023e6:	2781                	sext.w	a5,a5
    800023e8:	079e                	slli	a5,a5,0x7
    800023ea:	0022f597          	auipc	a1,0x22f
    800023ee:	b1e58593          	addi	a1,a1,-1250 # 80230f08 <cpus+0x8>
    800023f2:	95be                	add	a1,a1,a5
    800023f4:	06048513          	addi	a0,s1,96
    800023f8:	00000097          	auipc	ra,0x0
    800023fc:	7ec080e7          	jalr	2028(ra) # 80002be4 <swtch>
    80002400:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002402:	2781                	sext.w	a5,a5
    80002404:	079e                	slli	a5,a5,0x7
    80002406:	993e                	add	s2,s2,a5
    80002408:	0f392e23          	sw	s3,252(s2)
}
    8000240c:	70a2                	ld	ra,40(sp)
    8000240e:	7402                	ld	s0,32(sp)
    80002410:	64e2                	ld	s1,24(sp)
    80002412:	6942                	ld	s2,16(sp)
    80002414:	69a2                	ld	s3,8(sp)
    80002416:	6145                	addi	sp,sp,48
    80002418:	8082                	ret
    panic("sched p->lock");
    8000241a:	00006517          	auipc	a0,0x6
    8000241e:	e6e50513          	addi	a0,a0,-402 # 80008288 <digits+0x248>
    80002422:	ffffe097          	auipc	ra,0xffffe
    80002426:	11e080e7          	jalr	286(ra) # 80000540 <panic>
    panic("sched locks");
    8000242a:	00006517          	auipc	a0,0x6
    8000242e:	e6e50513          	addi	a0,a0,-402 # 80008298 <digits+0x258>
    80002432:	ffffe097          	auipc	ra,0xffffe
    80002436:	10e080e7          	jalr	270(ra) # 80000540 <panic>
    panic("sched running");
    8000243a:	00006517          	auipc	a0,0x6
    8000243e:	e6e50513          	addi	a0,a0,-402 # 800082a8 <digits+0x268>
    80002442:	ffffe097          	auipc	ra,0xffffe
    80002446:	0fe080e7          	jalr	254(ra) # 80000540 <panic>
    panic("sched interruptible");
    8000244a:	00006517          	auipc	a0,0x6
    8000244e:	e6e50513          	addi	a0,a0,-402 # 800082b8 <digits+0x278>
    80002452:	ffffe097          	auipc	ra,0xffffe
    80002456:	0ee080e7          	jalr	238(ra) # 80000540 <panic>

000000008000245a <yield>:
{
    8000245a:	1101                	addi	sp,sp,-32
    8000245c:	ec06                	sd	ra,24(sp)
    8000245e:	e822                	sd	s0,16(sp)
    80002460:	e426                	sd	s1,8(sp)
    80002462:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	6fc080e7          	jalr	1788(ra) # 80001b60 <myproc>
    8000246c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	8a8080e7          	jalr	-1880(ra) # 80000d16 <acquire>
  p->state = RUNNABLE;
    80002476:	478d                	li	a5,3
    80002478:	cc9c                	sw	a5,24(s1)
  sched();
    8000247a:	00000097          	auipc	ra,0x0
    8000247e:	f0a080e7          	jalr	-246(ra) # 80002384 <sched>
  release(&p->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	946080e7          	jalr	-1722(ra) # 80000dca <release>
}
    8000248c:	60e2                	ld	ra,24(sp)
    8000248e:	6442                	ld	s0,16(sp)
    80002490:	64a2                	ld	s1,8(sp)
    80002492:	6105                	addi	sp,sp,32
    80002494:	8082                	ret

0000000080002496 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002496:	7179                	addi	sp,sp,-48
    80002498:	f406                	sd	ra,40(sp)
    8000249a:	f022                	sd	s0,32(sp)
    8000249c:	ec26                	sd	s1,24(sp)
    8000249e:	e84a                	sd	s2,16(sp)
    800024a0:	e44e                	sd	s3,8(sp)
    800024a2:	1800                	addi	s0,sp,48
    800024a4:	89aa                	mv	s3,a0
    800024a6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	6b8080e7          	jalr	1720(ra) # 80001b60 <myproc>
    800024b0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	864080e7          	jalr	-1948(ra) # 80000d16 <acquire>
  release(lk);
    800024ba:	854a                	mv	a0,s2
    800024bc:	fffff097          	auipc	ra,0xfffff
    800024c0:	90e080e7          	jalr	-1778(ra) # 80000dca <release>

  // Go to sleep.
  p->chan = chan;
    800024c4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024c8:	4789                	li	a5,2
    800024ca:	cc9c                	sw	a5,24(s1)

  sched();
    800024cc:	00000097          	auipc	ra,0x0
    800024d0:	eb8080e7          	jalr	-328(ra) # 80002384 <sched>

  // Tidy up.
  p->chan = 0;
    800024d4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024d8:	8526                	mv	a0,s1
    800024da:	fffff097          	auipc	ra,0xfffff
    800024de:	8f0080e7          	jalr	-1808(ra) # 80000dca <release>
  acquire(lk);
    800024e2:	854a                	mv	a0,s2
    800024e4:	fffff097          	auipc	ra,0xfffff
    800024e8:	832080e7          	jalr	-1998(ra) # 80000d16 <acquire>
}
    800024ec:	70a2                	ld	ra,40(sp)
    800024ee:	7402                	ld	s0,32(sp)
    800024f0:	64e2                	ld	s1,24(sp)
    800024f2:	6942                	ld	s2,16(sp)
    800024f4:	69a2                	ld	s3,8(sp)
    800024f6:	6145                	addi	sp,sp,48
    800024f8:	8082                	ret

00000000800024fa <waitx>:
{
    800024fa:	711d                	addi	sp,sp,-96
    800024fc:	ec86                	sd	ra,88(sp)
    800024fe:	e8a2                	sd	s0,80(sp)
    80002500:	e4a6                	sd	s1,72(sp)
    80002502:	e0ca                	sd	s2,64(sp)
    80002504:	fc4e                	sd	s3,56(sp)
    80002506:	f852                	sd	s4,48(sp)
    80002508:	f456                	sd	s5,40(sp)
    8000250a:	f05a                	sd	s6,32(sp)
    8000250c:	ec5e                	sd	s7,24(sp)
    8000250e:	e862                	sd	s8,16(sp)
    80002510:	e466                	sd	s9,8(sp)
    80002512:	e06a                	sd	s10,0(sp)
    80002514:	1080                	addi	s0,sp,96
    80002516:	8b2a                	mv	s6,a0
    80002518:	8c2e                	mv	s8,a1
    8000251a:	8bb2                	mv	s7,a2
  struct proc *p = myproc();
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	644080e7          	jalr	1604(ra) # 80001b60 <myproc>
    80002524:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002526:	0022f517          	auipc	a0,0x22f
    8000252a:	97250513          	addi	a0,a0,-1678 # 80230e98 <wait_lock>
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	7e8080e7          	jalr	2024(ra) # 80000d16 <acquire>
    havekids = 0;
    80002536:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    80002538:	4a15                	li	s4,5
        havekids = 1;
    8000253a:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000253c:	00236997          	auipc	s3,0x236
    80002540:	7c498993          	addi	s3,s3,1988 # 80238d00 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002544:	0022fd17          	auipc	s10,0x22f
    80002548:	954d0d13          	addi	s10,s10,-1708 # 80230e98 <wait_lock>
    havekids = 0;
    8000254c:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000254e:	0022f497          	auipc	s1,0x22f
    80002552:	1b248493          	addi	s1,s1,434 # 80231700 <proc>
    80002556:	a069                	j	800025e0 <waitx+0xe6>
          pid = np->pid;
    80002558:	0304a983          	lw	s3,48(s1)
          *rtime = np->runtime;
    8000255c:	1744a783          	lw	a5,372(s1)
    80002560:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->starttime - np->runtime;
    80002564:	1d44a783          	lw	a5,468(s1)
    80002568:	16c4a703          	lw	a4,364(s1)
    8000256c:	9f99                	subw	a5,a5,a4
    8000256e:	1744a703          	lw	a4,372(s1)
    80002572:	9f99                	subw	a5,a5,a4
    80002574:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002578:	000b0e63          	beqz	s6,80002594 <waitx+0x9a>
    8000257c:	4691                	li	a3,4
    8000257e:	02c48613          	addi	a2,s1,44
    80002582:	85da                	mv	a1,s6
    80002584:	05093503          	ld	a0,80(s2)
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	210080e7          	jalr	528(ra) # 80001798 <copyout>
    80002590:	02054563          	bltz	a0,800025ba <waitx+0xc0>
          freeproc(np);
    80002594:	8526                	mv	a0,s1
    80002596:	00000097          	auipc	ra,0x0
    8000259a:	81e080e7          	jalr	-2018(ra) # 80001db4 <freeproc>
          release(&np->lock);
    8000259e:	8526                	mv	a0,s1
    800025a0:	fffff097          	auipc	ra,0xfffff
    800025a4:	82a080e7          	jalr	-2006(ra) # 80000dca <release>
          release(&wait_lock);
    800025a8:	0022f517          	auipc	a0,0x22f
    800025ac:	8f050513          	addi	a0,a0,-1808 # 80230e98 <wait_lock>
    800025b0:	fffff097          	auipc	ra,0xfffff
    800025b4:	81a080e7          	jalr	-2022(ra) # 80000dca <release>
          return pid;
    800025b8:	a09d                	j	8000261e <waitx+0x124>
            release(&np->lock);
    800025ba:	8526                	mv	a0,s1
    800025bc:	fffff097          	auipc	ra,0xfffff
    800025c0:	80e080e7          	jalr	-2034(ra) # 80000dca <release>
            release(&wait_lock);
    800025c4:	0022f517          	auipc	a0,0x22f
    800025c8:	8d450513          	addi	a0,a0,-1836 # 80230e98 <wait_lock>
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	7fe080e7          	jalr	2046(ra) # 80000dca <release>
            return -1;
    800025d4:	59fd                	li	s3,-1
    800025d6:	a0a1                	j	8000261e <waitx+0x124>
    for (np = proc; np < &proc[NPROC]; np++)
    800025d8:	1d848493          	addi	s1,s1,472
    800025dc:	03348463          	beq	s1,s3,80002604 <waitx+0x10a>
      if (np->parent == p)
    800025e0:	7c9c                	ld	a5,56(s1)
    800025e2:	ff279be3          	bne	a5,s2,800025d8 <waitx+0xde>
        acquire(&np->lock);
    800025e6:	8526                	mv	a0,s1
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	72e080e7          	jalr	1838(ra) # 80000d16 <acquire>
        if (np->state == ZOMBIE)
    800025f0:	4c9c                	lw	a5,24(s1)
    800025f2:	f74783e3          	beq	a5,s4,80002558 <waitx+0x5e>
        release(&np->lock);
    800025f6:	8526                	mv	a0,s1
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	7d2080e7          	jalr	2002(ra) # 80000dca <release>
        havekids = 1;
    80002600:	8756                	mv	a4,s5
    80002602:	bfd9                	j	800025d8 <waitx+0xde>
    if (!havekids || p->killed)
    80002604:	c701                	beqz	a4,8000260c <waitx+0x112>
    80002606:	02892783          	lw	a5,40(s2)
    8000260a:	cb8d                	beqz	a5,8000263c <waitx+0x142>
      release(&wait_lock);
    8000260c:	0022f517          	auipc	a0,0x22f
    80002610:	88c50513          	addi	a0,a0,-1908 # 80230e98 <wait_lock>
    80002614:	ffffe097          	auipc	ra,0xffffe
    80002618:	7b6080e7          	jalr	1974(ra) # 80000dca <release>
      return -1;
    8000261c:	59fd                	li	s3,-1
}
    8000261e:	854e                	mv	a0,s3
    80002620:	60e6                	ld	ra,88(sp)
    80002622:	6446                	ld	s0,80(sp)
    80002624:	64a6                	ld	s1,72(sp)
    80002626:	6906                	ld	s2,64(sp)
    80002628:	79e2                	ld	s3,56(sp)
    8000262a:	7a42                	ld	s4,48(sp)
    8000262c:	7aa2                	ld	s5,40(sp)
    8000262e:	7b02                	ld	s6,32(sp)
    80002630:	6be2                	ld	s7,24(sp)
    80002632:	6c42                	ld	s8,16(sp)
    80002634:	6ca2                	ld	s9,8(sp)
    80002636:	6d02                	ld	s10,0(sp)
    80002638:	6125                	addi	sp,sp,96
    8000263a:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000263c:	85ea                	mv	a1,s10
    8000263e:	854a                	mv	a0,s2
    80002640:	00000097          	auipc	ra,0x0
    80002644:	e56080e7          	jalr	-426(ra) # 80002496 <sleep>
    havekids = 0;
    80002648:	b711                	j	8000254c <waitx+0x52>

000000008000264a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000264a:	7139                	addi	sp,sp,-64
    8000264c:	fc06                	sd	ra,56(sp)
    8000264e:	f822                	sd	s0,48(sp)
    80002650:	f426                	sd	s1,40(sp)
    80002652:	f04a                	sd	s2,32(sp)
    80002654:	ec4e                	sd	s3,24(sp)
    80002656:	e852                	sd	s4,16(sp)
    80002658:	e456                	sd	s5,8(sp)
    8000265a:	0080                	addi	s0,sp,64
    8000265c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000265e:	0022f497          	auipc	s1,0x22f
    80002662:	0a248493          	addi	s1,s1,162 # 80231700 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002666:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002668:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000266a:	00236917          	auipc	s2,0x236
    8000266e:	69690913          	addi	s2,s2,1686 # 80238d00 <tickslock>
    80002672:	a811                	j	80002686 <wakeup+0x3c>
      }
      release(&p->lock);
    80002674:	8526                	mv	a0,s1
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	754080e7          	jalr	1876(ra) # 80000dca <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000267e:	1d848493          	addi	s1,s1,472
    80002682:	03248663          	beq	s1,s2,800026ae <wakeup+0x64>
    if (p != myproc())
    80002686:	fffff097          	auipc	ra,0xfffff
    8000268a:	4da080e7          	jalr	1242(ra) # 80001b60 <myproc>
    8000268e:	fea488e3          	beq	s1,a0,8000267e <wakeup+0x34>
      acquire(&p->lock);
    80002692:	8526                	mv	a0,s1
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	682080e7          	jalr	1666(ra) # 80000d16 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000269c:	4c9c                	lw	a5,24(s1)
    8000269e:	fd379be3          	bne	a5,s3,80002674 <wakeup+0x2a>
    800026a2:	709c                	ld	a5,32(s1)
    800026a4:	fd4798e3          	bne	a5,s4,80002674 <wakeup+0x2a>
        p->state = RUNNABLE;
    800026a8:	0154ac23          	sw	s5,24(s1)
    800026ac:	b7e1                	j	80002674 <wakeup+0x2a>
    }
  }
}
    800026ae:	70e2                	ld	ra,56(sp)
    800026b0:	7442                	ld	s0,48(sp)
    800026b2:	74a2                	ld	s1,40(sp)
    800026b4:	7902                	ld	s2,32(sp)
    800026b6:	69e2                	ld	s3,24(sp)
    800026b8:	6a42                	ld	s4,16(sp)
    800026ba:	6aa2                	ld	s5,8(sp)
    800026bc:	6121                	addi	sp,sp,64
    800026be:	8082                	ret

00000000800026c0 <reparent>:
{
    800026c0:	7179                	addi	sp,sp,-48
    800026c2:	f406                	sd	ra,40(sp)
    800026c4:	f022                	sd	s0,32(sp)
    800026c6:	ec26                	sd	s1,24(sp)
    800026c8:	e84a                	sd	s2,16(sp)
    800026ca:	e44e                	sd	s3,8(sp)
    800026cc:	e052                	sd	s4,0(sp)
    800026ce:	1800                	addi	s0,sp,48
    800026d0:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800026d2:	0022f497          	auipc	s1,0x22f
    800026d6:	02e48493          	addi	s1,s1,46 # 80231700 <proc>
      pp->parent = initproc;
    800026da:	00006a17          	auipc	s4,0x6
    800026de:	52ea0a13          	addi	s4,s4,1326 # 80008c08 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800026e2:	00236997          	auipc	s3,0x236
    800026e6:	61e98993          	addi	s3,s3,1566 # 80238d00 <tickslock>
    800026ea:	a029                	j	800026f4 <reparent+0x34>
    800026ec:	1d848493          	addi	s1,s1,472
    800026f0:	01348d63          	beq	s1,s3,8000270a <reparent+0x4a>
    if (pp->parent == p)
    800026f4:	7c9c                	ld	a5,56(s1)
    800026f6:	ff279be3          	bne	a5,s2,800026ec <reparent+0x2c>
      pp->parent = initproc;
    800026fa:	000a3503          	ld	a0,0(s4)
    800026fe:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002700:	00000097          	auipc	ra,0x0
    80002704:	f4a080e7          	jalr	-182(ra) # 8000264a <wakeup>
    80002708:	b7d5                	j	800026ec <reparent+0x2c>
}
    8000270a:	70a2                	ld	ra,40(sp)
    8000270c:	7402                	ld	s0,32(sp)
    8000270e:	64e2                	ld	s1,24(sp)
    80002710:	6942                	ld	s2,16(sp)
    80002712:	69a2                	ld	s3,8(sp)
    80002714:	6a02                	ld	s4,0(sp)
    80002716:	6145                	addi	sp,sp,48
    80002718:	8082                	ret

000000008000271a <exit>:
{
    8000271a:	7179                	addi	sp,sp,-48
    8000271c:	f406                	sd	ra,40(sp)
    8000271e:	f022                	sd	s0,32(sp)
    80002720:	ec26                	sd	s1,24(sp)
    80002722:	e84a                	sd	s2,16(sp)
    80002724:	e44e                	sd	s3,8(sp)
    80002726:	e052                	sd	s4,0(sp)
    80002728:	1800                	addi	s0,sp,48
    8000272a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000272c:	fffff097          	auipc	ra,0xfffff
    80002730:	434080e7          	jalr	1076(ra) # 80001b60 <myproc>
    80002734:	89aa                	mv	s3,a0
  if (p == initproc)
    80002736:	00006797          	auipc	a5,0x6
    8000273a:	4d27b783          	ld	a5,1234(a5) # 80008c08 <initproc>
    8000273e:	0d050493          	addi	s1,a0,208
    80002742:	15050913          	addi	s2,a0,336
    80002746:	02a79363          	bne	a5,a0,8000276c <exit+0x52>
    panic("init exiting");
    8000274a:	00006517          	auipc	a0,0x6
    8000274e:	b8650513          	addi	a0,a0,-1146 # 800082d0 <digits+0x290>
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	dee080e7          	jalr	-530(ra) # 80000540 <panic>
      fileclose(f);
    8000275a:	00003097          	auipc	ra,0x3
    8000275e:	97e080e7          	jalr	-1666(ra) # 800050d8 <fileclose>
      p->ofile[fd] = 0;
    80002762:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002766:	04a1                	addi	s1,s1,8
    80002768:	01248563          	beq	s1,s2,80002772 <exit+0x58>
    if (p->ofile[fd])
    8000276c:	6088                	ld	a0,0(s1)
    8000276e:	f575                	bnez	a0,8000275a <exit+0x40>
    80002770:	bfdd                	j	80002766 <exit+0x4c>
  begin_op();
    80002772:	00002097          	auipc	ra,0x2
    80002776:	49e080e7          	jalr	1182(ra) # 80004c10 <begin_op>
  iput(p->cwd);
    8000277a:	1509b503          	ld	a0,336(s3)
    8000277e:	00002097          	auipc	ra,0x2
    80002782:	c80080e7          	jalr	-896(ra) # 800043fe <iput>
  end_op();
    80002786:	00002097          	auipc	ra,0x2
    8000278a:	508080e7          	jalr	1288(ra) # 80004c8e <end_op>
  p->cwd = 0;
    8000278e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002792:	0022e497          	auipc	s1,0x22e
    80002796:	70648493          	addi	s1,s1,1798 # 80230e98 <wait_lock>
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	57a080e7          	jalr	1402(ra) # 80000d16 <acquire>
  reparent(p);
    800027a4:	854e                	mv	a0,s3
    800027a6:	00000097          	auipc	ra,0x0
    800027aa:	f1a080e7          	jalr	-230(ra) # 800026c0 <reparent>
  wakeup(p->parent);
    800027ae:	0389b503          	ld	a0,56(s3)
    800027b2:	00000097          	auipc	ra,0x0
    800027b6:	e98080e7          	jalr	-360(ra) # 8000264a <wakeup>
  acquire(&p->lock);
    800027ba:	854e                	mv	a0,s3
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	55a080e7          	jalr	1370(ra) # 80000d16 <acquire>
  p->xstate = status;
    800027c4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800027c8:	4795                	li	a5,5
    800027ca:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800027ce:	00006797          	auipc	a5,0x6
    800027d2:	4427a783          	lw	a5,1090(a5) # 80008c10 <ticks>
    800027d6:	1cf9aa23          	sw	a5,468(s3)
  release(&wait_lock);
    800027da:	8526                	mv	a0,s1
    800027dc:	ffffe097          	auipc	ra,0xffffe
    800027e0:	5ee080e7          	jalr	1518(ra) # 80000dca <release>
  sched();
    800027e4:	00000097          	auipc	ra,0x0
    800027e8:	ba0080e7          	jalr	-1120(ra) # 80002384 <sched>
  panic("zombie exit");
    800027ec:	00006517          	auipc	a0,0x6
    800027f0:	af450513          	addi	a0,a0,-1292 # 800082e0 <digits+0x2a0>
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	d4c080e7          	jalr	-692(ra) # 80000540 <panic>

00000000800027fc <update_times>:

// update times of all process
void update_times() // called in clockintr when incrementing ticks
{
    800027fc:	7179                	addi	sp,sp,-48
    800027fe:	f406                	sd	ra,40(sp)
    80002800:	f022                	sd	s0,32(sp)
    80002802:	ec26                	sd	s1,24(sp)
    80002804:	e84a                	sd	s2,16(sp)
    80002806:	e44e                	sd	s3,8(sp)
    80002808:	e052                	sd	s4,0(sp)
    8000280a:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    8000280c:	0022f497          	auipc	s1,0x22f
    80002810:	ef448493          	addi	s1,s1,-268 # 80231700 <proc>
  {
    acquire(&p->lock);

    if (p->state == SLEEPING)
    80002814:	4989                	li	s3,2
      p->sleeptime++;

    if (p->state == RUNNING)
    80002816:	4a11                	li	s4,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002818:	00236917          	auipc	s2,0x236
    8000281c:	4e890913          	addi	s2,s2,1256 # 80238d00 <tickslock>
    80002820:	a839                	j	8000283e <update_times+0x42>
      p->sleeptime++;
    80002822:	1784a783          	lw	a5,376(s1)
    80002826:	2785                	addiw	a5,a5,1
    80002828:	16f4ac23          	sw	a5,376(s1)
      p->qrtime[p->queueno]++;
      p->timeslice--;
#endif
    }

    release(&p->lock);
    8000282c:	8526                	mv	a0,s1
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	59c080e7          	jalr	1436(ra) # 80000dca <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002836:	1d848493          	addi	s1,s1,472
    8000283a:	05248063          	beq	s1,s2,8000287a <update_times+0x7e>
    acquire(&p->lock);
    8000283e:	8526                	mv	a0,s1
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	4d6080e7          	jalr	1238(ra) # 80000d16 <acquire>
    if (p->state == SLEEPING)
    80002848:	4c9c                	lw	a5,24(s1)
    8000284a:	fd378ce3          	beq	a5,s3,80002822 <update_times+0x26>
    if (p->state == RUNNING)
    8000284e:	fd479fe3          	bne	a5,s4,8000282c <update_times+0x30>
      p->runtime++;
    80002852:	1744a783          	lw	a5,372(s1)
    80002856:	2785                	addiw	a5,a5,1
    80002858:	16f4aa23          	sw	a5,372(s1)
      p->qrtime[p->queueno]++;
    8000285c:	1884a783          	lw	a5,392(s1)
    80002860:	078a                	slli	a5,a5,0x2
    80002862:	97a6                	add	a5,a5,s1
    80002864:	1987a703          	lw	a4,408(a5)
    80002868:	2705                	addiw	a4,a4,1
    8000286a:	18e7ac23          	sw	a4,408(a5)
      p->timeslice--;
    8000286e:	1904a783          	lw	a5,400(s1)
    80002872:	37fd                	addiw	a5,a5,-1
    80002874:	18f4a823          	sw	a5,400(s1)
    80002878:	bf55                	j	8000282c <update_times+0x30>
  }
}
    8000287a:	70a2                	ld	ra,40(sp)
    8000287c:	7402                	ld	s0,32(sp)
    8000287e:	64e2                	ld	s1,24(sp)
    80002880:	6942                	ld	s2,16(sp)
    80002882:	69a2                	ld	s3,8(sp)
    80002884:	6a02                	ld	s4,0(sp)
    80002886:	6145                	addi	sp,sp,48
    80002888:	8082                	ret

000000008000288a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000288a:	7179                	addi	sp,sp,-48
    8000288c:	f406                	sd	ra,40(sp)
    8000288e:	f022                	sd	s0,32(sp)
    80002890:	ec26                	sd	s1,24(sp)
    80002892:	e84a                	sd	s2,16(sp)
    80002894:	e44e                	sd	s3,8(sp)
    80002896:	1800                	addi	s0,sp,48
    80002898:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000289a:	0022f497          	auipc	s1,0x22f
    8000289e:	e6648493          	addi	s1,s1,-410 # 80231700 <proc>
    800028a2:	00236997          	auipc	s3,0x236
    800028a6:	45e98993          	addi	s3,s3,1118 # 80238d00 <tickslock>
  {
    acquire(&p->lock);
    800028aa:	8526                	mv	a0,s1
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	46a080e7          	jalr	1130(ra) # 80000d16 <acquire>
    if (p->pid == pid)
    800028b4:	589c                	lw	a5,48(s1)
    800028b6:	01278d63          	beq	a5,s2,800028d0 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800028ba:	8526                	mv	a0,s1
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	50e080e7          	jalr	1294(ra) # 80000dca <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800028c4:	1d848493          	addi	s1,s1,472
    800028c8:	ff3491e3          	bne	s1,s3,800028aa <kill+0x20>
  }
  return -1;
    800028cc:	557d                	li	a0,-1
    800028ce:	a829                	j	800028e8 <kill+0x5e>
      p->killed = 1;
    800028d0:	4785                	li	a5,1
    800028d2:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800028d4:	4c98                	lw	a4,24(s1)
    800028d6:	4789                	li	a5,2
    800028d8:	00f70f63          	beq	a4,a5,800028f6 <kill+0x6c>
      release(&p->lock);
    800028dc:	8526                	mv	a0,s1
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	4ec080e7          	jalr	1260(ra) # 80000dca <release>
      return 0;
    800028e6:	4501                	li	a0,0
}
    800028e8:	70a2                	ld	ra,40(sp)
    800028ea:	7402                	ld	s0,32(sp)
    800028ec:	64e2                	ld	s1,24(sp)
    800028ee:	6942                	ld	s2,16(sp)
    800028f0:	69a2                	ld	s3,8(sp)
    800028f2:	6145                	addi	sp,sp,48
    800028f4:	8082                	ret
        p->state = RUNNABLE;
    800028f6:	478d                	li	a5,3
    800028f8:	cc9c                	sw	a5,24(s1)
    800028fa:	b7cd                	j	800028dc <kill+0x52>

00000000800028fc <setkilled>:

void setkilled(struct proc *p)
{
    800028fc:	1101                	addi	sp,sp,-32
    800028fe:	ec06                	sd	ra,24(sp)
    80002900:	e822                	sd	s0,16(sp)
    80002902:	e426                	sd	s1,8(sp)
    80002904:	1000                	addi	s0,sp,32
    80002906:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002908:	ffffe097          	auipc	ra,0xffffe
    8000290c:	40e080e7          	jalr	1038(ra) # 80000d16 <acquire>
  p->killed = 1;
    80002910:	4785                	li	a5,1
    80002912:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002914:	8526                	mv	a0,s1
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	4b4080e7          	jalr	1204(ra) # 80000dca <release>
}
    8000291e:	60e2                	ld	ra,24(sp)
    80002920:	6442                	ld	s0,16(sp)
    80002922:	64a2                	ld	s1,8(sp)
    80002924:	6105                	addi	sp,sp,32
    80002926:	8082                	ret

0000000080002928 <killed>:

int killed(struct proc *p)
{
    80002928:	1101                	addi	sp,sp,-32
    8000292a:	ec06                	sd	ra,24(sp)
    8000292c:	e822                	sd	s0,16(sp)
    8000292e:	e426                	sd	s1,8(sp)
    80002930:	e04a                	sd	s2,0(sp)
    80002932:	1000                	addi	s0,sp,32
    80002934:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	3e0080e7          	jalr	992(ra) # 80000d16 <acquire>
  k = p->killed;
    8000293e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002942:	8526                	mv	a0,s1
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	486080e7          	jalr	1158(ra) # 80000dca <release>
  return k;
}
    8000294c:	854a                	mv	a0,s2
    8000294e:	60e2                	ld	ra,24(sp)
    80002950:	6442                	ld	s0,16(sp)
    80002952:	64a2                	ld	s1,8(sp)
    80002954:	6902                	ld	s2,0(sp)
    80002956:	6105                	addi	sp,sp,32
    80002958:	8082                	ret

000000008000295a <wait>:
{
    8000295a:	715d                	addi	sp,sp,-80
    8000295c:	e486                	sd	ra,72(sp)
    8000295e:	e0a2                	sd	s0,64(sp)
    80002960:	fc26                	sd	s1,56(sp)
    80002962:	f84a                	sd	s2,48(sp)
    80002964:	f44e                	sd	s3,40(sp)
    80002966:	f052                	sd	s4,32(sp)
    80002968:	ec56                	sd	s5,24(sp)
    8000296a:	e85a                	sd	s6,16(sp)
    8000296c:	e45e                	sd	s7,8(sp)
    8000296e:	e062                	sd	s8,0(sp)
    80002970:	0880                	addi	s0,sp,80
    80002972:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002974:	fffff097          	auipc	ra,0xfffff
    80002978:	1ec080e7          	jalr	492(ra) # 80001b60 <myproc>
    8000297c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000297e:	0022e517          	auipc	a0,0x22e
    80002982:	51a50513          	addi	a0,a0,1306 # 80230e98 <wait_lock>
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	390080e7          	jalr	912(ra) # 80000d16 <acquire>
    havekids = 0;
    8000298e:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002990:	4a15                	li	s4,5
        havekids = 1;
    80002992:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002994:	00236997          	auipc	s3,0x236
    80002998:	36c98993          	addi	s3,s3,876 # 80238d00 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000299c:	0022ec17          	auipc	s8,0x22e
    800029a0:	4fcc0c13          	addi	s8,s8,1276 # 80230e98 <wait_lock>
    havekids = 0;
    800029a4:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800029a6:	0022f497          	auipc	s1,0x22f
    800029aa:	d5a48493          	addi	s1,s1,-678 # 80231700 <proc>
    800029ae:	a0bd                	j	80002a1c <wait+0xc2>
          pid = pp->pid;
    800029b0:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800029b4:	000b0e63          	beqz	s6,800029d0 <wait+0x76>
    800029b8:	4691                	li	a3,4
    800029ba:	02c48613          	addi	a2,s1,44
    800029be:	85da                	mv	a1,s6
    800029c0:	05093503          	ld	a0,80(s2)
    800029c4:	fffff097          	auipc	ra,0xfffff
    800029c8:	dd4080e7          	jalr	-556(ra) # 80001798 <copyout>
    800029cc:	02054563          	bltz	a0,800029f6 <wait+0x9c>
          freeproc(pp);
    800029d0:	8526                	mv	a0,s1
    800029d2:	fffff097          	auipc	ra,0xfffff
    800029d6:	3e2080e7          	jalr	994(ra) # 80001db4 <freeproc>
          release(&pp->lock);
    800029da:	8526                	mv	a0,s1
    800029dc:	ffffe097          	auipc	ra,0xffffe
    800029e0:	3ee080e7          	jalr	1006(ra) # 80000dca <release>
          release(&wait_lock);
    800029e4:	0022e517          	auipc	a0,0x22e
    800029e8:	4b450513          	addi	a0,a0,1204 # 80230e98 <wait_lock>
    800029ec:	ffffe097          	auipc	ra,0xffffe
    800029f0:	3de080e7          	jalr	990(ra) # 80000dca <release>
          return pid;
    800029f4:	a0b5                	j	80002a60 <wait+0x106>
            release(&pp->lock);
    800029f6:	8526                	mv	a0,s1
    800029f8:	ffffe097          	auipc	ra,0xffffe
    800029fc:	3d2080e7          	jalr	978(ra) # 80000dca <release>
            release(&wait_lock);
    80002a00:	0022e517          	auipc	a0,0x22e
    80002a04:	49850513          	addi	a0,a0,1176 # 80230e98 <wait_lock>
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	3c2080e7          	jalr	962(ra) # 80000dca <release>
            return -1;
    80002a10:	59fd                	li	s3,-1
    80002a12:	a0b9                	j	80002a60 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a14:	1d848493          	addi	s1,s1,472
    80002a18:	03348463          	beq	s1,s3,80002a40 <wait+0xe6>
      if (pp->parent == p)
    80002a1c:	7c9c                	ld	a5,56(s1)
    80002a1e:	ff279be3          	bne	a5,s2,80002a14 <wait+0xba>
        acquire(&pp->lock);
    80002a22:	8526                	mv	a0,s1
    80002a24:	ffffe097          	auipc	ra,0xffffe
    80002a28:	2f2080e7          	jalr	754(ra) # 80000d16 <acquire>
        if (pp->state == ZOMBIE)
    80002a2c:	4c9c                	lw	a5,24(s1)
    80002a2e:	f94781e3          	beq	a5,s4,800029b0 <wait+0x56>
        release(&pp->lock);
    80002a32:	8526                	mv	a0,s1
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	396080e7          	jalr	918(ra) # 80000dca <release>
        havekids = 1;
    80002a3c:	8756                	mv	a4,s5
    80002a3e:	bfd9                	j	80002a14 <wait+0xba>
    if (!havekids || killed(p))
    80002a40:	c719                	beqz	a4,80002a4e <wait+0xf4>
    80002a42:	854a                	mv	a0,s2
    80002a44:	00000097          	auipc	ra,0x0
    80002a48:	ee4080e7          	jalr	-284(ra) # 80002928 <killed>
    80002a4c:	c51d                	beqz	a0,80002a7a <wait+0x120>
      release(&wait_lock);
    80002a4e:	0022e517          	auipc	a0,0x22e
    80002a52:	44a50513          	addi	a0,a0,1098 # 80230e98 <wait_lock>
    80002a56:	ffffe097          	auipc	ra,0xffffe
    80002a5a:	374080e7          	jalr	884(ra) # 80000dca <release>
      return -1;
    80002a5e:	59fd                	li	s3,-1
}
    80002a60:	854e                	mv	a0,s3
    80002a62:	60a6                	ld	ra,72(sp)
    80002a64:	6406                	ld	s0,64(sp)
    80002a66:	74e2                	ld	s1,56(sp)
    80002a68:	7942                	ld	s2,48(sp)
    80002a6a:	79a2                	ld	s3,40(sp)
    80002a6c:	7a02                	ld	s4,32(sp)
    80002a6e:	6ae2                	ld	s5,24(sp)
    80002a70:	6b42                	ld	s6,16(sp)
    80002a72:	6ba2                	ld	s7,8(sp)
    80002a74:	6c02                	ld	s8,0(sp)
    80002a76:	6161                	addi	sp,sp,80
    80002a78:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002a7a:	85e2                	mv	a1,s8
    80002a7c:	854a                	mv	a0,s2
    80002a7e:	00000097          	auipc	ra,0x0
    80002a82:	a18080e7          	jalr	-1512(ra) # 80002496 <sleep>
    havekids = 0;
    80002a86:	bf39                	j	800029a4 <wait+0x4a>

0000000080002a88 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a88:	7179                	addi	sp,sp,-48
    80002a8a:	f406                	sd	ra,40(sp)
    80002a8c:	f022                	sd	s0,32(sp)
    80002a8e:	ec26                	sd	s1,24(sp)
    80002a90:	e84a                	sd	s2,16(sp)
    80002a92:	e44e                	sd	s3,8(sp)
    80002a94:	e052                	sd	s4,0(sp)
    80002a96:	1800                	addi	s0,sp,48
    80002a98:	84aa                	mv	s1,a0
    80002a9a:	892e                	mv	s2,a1
    80002a9c:	89b2                	mv	s3,a2
    80002a9e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	0c0080e7          	jalr	192(ra) # 80001b60 <myproc>
  if (user_dst)
    80002aa8:	c08d                	beqz	s1,80002aca <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002aaa:	86d2                	mv	a3,s4
    80002aac:	864e                	mv	a2,s3
    80002aae:	85ca                	mv	a1,s2
    80002ab0:	6928                	ld	a0,80(a0)
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	ce6080e7          	jalr	-794(ra) # 80001798 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002aba:	70a2                	ld	ra,40(sp)
    80002abc:	7402                	ld	s0,32(sp)
    80002abe:	64e2                	ld	s1,24(sp)
    80002ac0:	6942                	ld	s2,16(sp)
    80002ac2:	69a2                	ld	s3,8(sp)
    80002ac4:	6a02                	ld	s4,0(sp)
    80002ac6:	6145                	addi	sp,sp,48
    80002ac8:	8082                	ret
    memmove((char *)dst, src, len);
    80002aca:	000a061b          	sext.w	a2,s4
    80002ace:	85ce                	mv	a1,s3
    80002ad0:	854a                	mv	a0,s2
    80002ad2:	ffffe097          	auipc	ra,0xffffe
    80002ad6:	39c080e7          	jalr	924(ra) # 80000e6e <memmove>
    return 0;
    80002ada:	8526                	mv	a0,s1
    80002adc:	bff9                	j	80002aba <either_copyout+0x32>

0000000080002ade <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002ade:	7179                	addi	sp,sp,-48
    80002ae0:	f406                	sd	ra,40(sp)
    80002ae2:	f022                	sd	s0,32(sp)
    80002ae4:	ec26                	sd	s1,24(sp)
    80002ae6:	e84a                	sd	s2,16(sp)
    80002ae8:	e44e                	sd	s3,8(sp)
    80002aea:	e052                	sd	s4,0(sp)
    80002aec:	1800                	addi	s0,sp,48
    80002aee:	892a                	mv	s2,a0
    80002af0:	84ae                	mv	s1,a1
    80002af2:	89b2                	mv	s3,a2
    80002af4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	06a080e7          	jalr	106(ra) # 80001b60 <myproc>
  if (user_src)
    80002afe:	c08d                	beqz	s1,80002b20 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002b00:	86d2                	mv	a3,s4
    80002b02:	864e                	mv	a2,s3
    80002b04:	85ca                	mv	a1,s2
    80002b06:	6928                	ld	a0,80(a0)
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	d6a080e7          	jalr	-662(ra) # 80001872 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002b10:	70a2                	ld	ra,40(sp)
    80002b12:	7402                	ld	s0,32(sp)
    80002b14:	64e2                	ld	s1,24(sp)
    80002b16:	6942                	ld	s2,16(sp)
    80002b18:	69a2                	ld	s3,8(sp)
    80002b1a:	6a02                	ld	s4,0(sp)
    80002b1c:	6145                	addi	sp,sp,48
    80002b1e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002b20:	000a061b          	sext.w	a2,s4
    80002b24:	85ce                	mv	a1,s3
    80002b26:	854a                	mv	a0,s2
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	346080e7          	jalr	838(ra) # 80000e6e <memmove>
    return 0;
    80002b30:	8526                	mv	a0,s1
    80002b32:	bff9                	j	80002b10 <either_copyin+0x32>

0000000080002b34 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002b34:	715d                	addi	sp,sp,-80
    80002b36:	e486                	sd	ra,72(sp)
    80002b38:	e0a2                	sd	s0,64(sp)
    80002b3a:	fc26                	sd	s1,56(sp)
    80002b3c:	f84a                	sd	s2,48(sp)
    80002b3e:	f44e                	sd	s3,40(sp)
    80002b40:	f052                	sd	s4,32(sp)
    80002b42:	ec56                	sd	s5,24(sp)
    80002b44:	e85a                	sd	s6,16(sp)
    80002b46:	e45e                	sd	s7,8(sp)
    80002b48:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002b4a:	00005517          	auipc	a0,0x5
    80002b4e:	5be50513          	addi	a0,a0,1470 # 80008108 <digits+0xc8>
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	a38080e7          	jalr	-1480(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002b5a:	0022f497          	auipc	s1,0x22f
    80002b5e:	cfe48493          	addi	s1,s1,-770 # 80231858 <proc+0x158>
    80002b62:	00236917          	auipc	s2,0x236
    80002b66:	2f690913          	addi	s2,s2,758 # 80238e58 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b6a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002b6c:	00005997          	auipc	s3,0x5
    80002b70:	78498993          	addi	s3,s3,1924 # 800082f0 <digits+0x2b0>
    printf("%d %s %s", p->pid, state, p->name);
    80002b74:	00005a97          	auipc	s5,0x5
    80002b78:	784a8a93          	addi	s5,s5,1924 # 800082f8 <digits+0x2b8>
    printf("\n");
    80002b7c:	00005a17          	auipc	s4,0x5
    80002b80:	58ca0a13          	addi	s4,s4,1420 # 80008108 <digits+0xc8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b84:	00005b97          	auipc	s7,0x5
    80002b88:	7b4b8b93          	addi	s7,s7,1972 # 80008338 <states.0>
    80002b8c:	a00d                	j	80002bae <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002b8e:	ed86a583          	lw	a1,-296(a3)
    80002b92:	8556                	mv	a0,s5
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	9f6080e7          	jalr	-1546(ra) # 8000058a <printf>
    printf("\n");
    80002b9c:	8552                	mv	a0,s4
    80002b9e:	ffffe097          	auipc	ra,0xffffe
    80002ba2:	9ec080e7          	jalr	-1556(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002ba6:	1d848493          	addi	s1,s1,472
    80002baa:	03248263          	beq	s1,s2,80002bce <procdump+0x9a>
    if (p->state == UNUSED)
    80002bae:	86a6                	mv	a3,s1
    80002bb0:	ec04a783          	lw	a5,-320(s1)
    80002bb4:	dbed                	beqz	a5,80002ba6 <procdump+0x72>
      state = "???";
    80002bb6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bb8:	fcfb6be3          	bltu	s6,a5,80002b8e <procdump+0x5a>
    80002bbc:	02079713          	slli	a4,a5,0x20
    80002bc0:	01d75793          	srli	a5,a4,0x1d
    80002bc4:	97de                	add	a5,a5,s7
    80002bc6:	6390                	ld	a2,0(a5)
    80002bc8:	f279                	bnez	a2,80002b8e <procdump+0x5a>
      state = "???";
    80002bca:	864e                	mv	a2,s3
    80002bcc:	b7c9                	j	80002b8e <procdump+0x5a>
  }
}
    80002bce:	60a6                	ld	ra,72(sp)
    80002bd0:	6406                	ld	s0,64(sp)
    80002bd2:	74e2                	ld	s1,56(sp)
    80002bd4:	7942                	ld	s2,48(sp)
    80002bd6:	79a2                	ld	s3,40(sp)
    80002bd8:	7a02                	ld	s4,32(sp)
    80002bda:	6ae2                	ld	s5,24(sp)
    80002bdc:	6b42                	ld	s6,16(sp)
    80002bde:	6ba2                	ld	s7,8(sp)
    80002be0:	6161                	addi	sp,sp,80
    80002be2:	8082                	ret

0000000080002be4 <swtch>:
    80002be4:	00153023          	sd	ra,0(a0)
    80002be8:	00253423          	sd	sp,8(a0)
    80002bec:	e900                	sd	s0,16(a0)
    80002bee:	ed04                	sd	s1,24(a0)
    80002bf0:	03253023          	sd	s2,32(a0)
    80002bf4:	03353423          	sd	s3,40(a0)
    80002bf8:	03453823          	sd	s4,48(a0)
    80002bfc:	03553c23          	sd	s5,56(a0)
    80002c00:	05653023          	sd	s6,64(a0)
    80002c04:	05753423          	sd	s7,72(a0)
    80002c08:	05853823          	sd	s8,80(a0)
    80002c0c:	05953c23          	sd	s9,88(a0)
    80002c10:	07a53023          	sd	s10,96(a0)
    80002c14:	07b53423          	sd	s11,104(a0)
    80002c18:	0005b083          	ld	ra,0(a1)
    80002c1c:	0085b103          	ld	sp,8(a1)
    80002c20:	6980                	ld	s0,16(a1)
    80002c22:	6d84                	ld	s1,24(a1)
    80002c24:	0205b903          	ld	s2,32(a1)
    80002c28:	0285b983          	ld	s3,40(a1)
    80002c2c:	0305ba03          	ld	s4,48(a1)
    80002c30:	0385ba83          	ld	s5,56(a1)
    80002c34:	0405bb03          	ld	s6,64(a1)
    80002c38:	0485bb83          	ld	s7,72(a1)
    80002c3c:	0505bc03          	ld	s8,80(a1)
    80002c40:	0585bc83          	ld	s9,88(a1)
    80002c44:	0605bd03          	ld	s10,96(a1)
    80002c48:	0685bd83          	ld	s11,104(a1)
    80002c4c:	8082                	ret

0000000080002c4e <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002c4e:	1141                	addi	sp,sp,-16
    80002c50:	e406                	sd	ra,8(sp)
    80002c52:	e022                	sd	s0,0(sp)
    80002c54:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c56:	00005597          	auipc	a1,0x5
    80002c5a:	71258593          	addi	a1,a1,1810 # 80008368 <states.0+0x30>
    80002c5e:	00236517          	auipc	a0,0x236
    80002c62:	0a250513          	addi	a0,a0,162 # 80238d00 <tickslock>
    80002c66:	ffffe097          	auipc	ra,0xffffe
    80002c6a:	020080e7          	jalr	32(ra) # 80000c86 <initlock>
}
    80002c6e:	60a2                	ld	ra,8(sp)
    80002c70:	6402                	ld	s0,0(sp)
    80002c72:	0141                	addi	sp,sp,16
    80002c74:	8082                	ret

0000000080002c76 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002c76:	1141                	addi	sp,sp,-16
    80002c78:	e422                	sd	s0,8(sp)
    80002c7a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c7c:	00004797          	auipc	a5,0x4
    80002c80:	ad478793          	addi	a5,a5,-1324 # 80006750 <kernelvec>
    80002c84:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c88:	6422                	ld	s0,8(sp)
    80002c8a:	0141                	addi	sp,sp,16
    80002c8c:	8082                	ret

0000000080002c8e <cow_handler>:

// in case of page fault
int cow_handler(pagetable_t pagetable, uint64 va)
{
  if (va >= MAXVA) // so that walk doesn't panic
    80002c8e:	57fd                	li	a5,-1
    80002c90:	83e9                	srli	a5,a5,0x1a
    80002c92:	08b7e263          	bltu	a5,a1,80002d16 <cow_handler+0x88>
{
    80002c96:	7179                	addi	sp,sp,-48
    80002c98:	f406                	sd	ra,40(sp)
    80002c9a:	f022                	sd	s0,32(sp)
    80002c9c:	ec26                	sd	s1,24(sp)
    80002c9e:	e84a                	sd	s2,16(sp)
    80002ca0:	e44e                	sd	s3,8(sp)
    80002ca2:	1800                	addi	s0,sp,48
    return -1;

  pte_t *pte = walk(pagetable, va, 0);
    80002ca4:	4601                	li	a2,0
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	450080e7          	jalr	1104(ra) # 800010f6 <walk>
    80002cae:	89aa                	mv	s3,a0
  if (pte == 0)
    80002cb0:	c52d                	beqz	a0,80002d1a <cow_handler+0x8c>
    return -1; // if pagetable not found

  if ((*pte & PTE_U) == 0 || (*pte & PTE_V) == 0)
    80002cb2:	610c                	ld	a1,0(a0)
    80002cb4:	0115f713          	andi	a4,a1,17
    80002cb8:	47c5                	li	a5,17
    80002cba:	06f71263          	bne	a4,a5,80002d1e <cow_handler+0x90>
    return -1; // crazy addresses

  uint64 pa1 = PTE2PA(*pte);
    80002cbe:	81a9                	srli	a1,a1,0xa
    80002cc0:	00c59913          	slli	s2,a1,0xc

  uint64 pa2 = (uint64)kalloc();
    80002cc4:	ffffe097          	auipc	ra,0xffffe
    80002cc8:	f24080e7          	jalr	-220(ra) # 80000be8 <kalloc>
    80002ccc:	84aa                	mv	s1,a0
  if (pa2 == 0)
    80002cce:	c915                	beqz	a0,80002d02 <cow_handler+0x74>
  {
    printf("Cow KAlloc failed\n");
    return -1;
  }

  memmove((void *)pa2, (void *)pa1, 4096);
    80002cd0:	6605                	lui	a2,0x1
    80002cd2:	85ca                	mv	a1,s2
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	19a080e7          	jalr	410(ra) # 80000e6e <memmove>

  kfree((void *)pa1); // it now means decrementing the pageref
    80002cdc:	854a                	mv	a0,s2
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	d86080e7          	jalr	-634(ra) # 80000a64 <kfree>

  *pte = PA2PTE(pa2) | PTE_V | PTE_U | PTE_R | PTE_W | PTE_X; // other process creates a copy and goes on
    80002ce6:	80b1                	srli	s1,s1,0xc
    80002ce8:	04aa                	slli	s1,s1,0xa
    80002cea:	01f4e493          	ori	s1,s1,31
    80002cee:	0099b023          	sd	s1,0(s3)
  *pte &= ~PTE_C;
  return 0;
    80002cf2:	4501                	li	a0,0
}
    80002cf4:	70a2                	ld	ra,40(sp)
    80002cf6:	7402                	ld	s0,32(sp)
    80002cf8:	64e2                	ld	s1,24(sp)
    80002cfa:	6942                	ld	s2,16(sp)
    80002cfc:	69a2                	ld	s3,8(sp)
    80002cfe:	6145                	addi	sp,sp,48
    80002d00:	8082                	ret
    printf("Cow KAlloc failed\n");
    80002d02:	00005517          	auipc	a0,0x5
    80002d06:	66e50513          	addi	a0,a0,1646 # 80008370 <states.0+0x38>
    80002d0a:	ffffe097          	auipc	ra,0xffffe
    80002d0e:	880080e7          	jalr	-1920(ra) # 8000058a <printf>
    return -1;
    80002d12:	557d                	li	a0,-1
    80002d14:	b7c5                	j	80002cf4 <cow_handler+0x66>
    return -1;
    80002d16:	557d                	li	a0,-1
}
    80002d18:	8082                	ret
    return -1; // if pagetable not found
    80002d1a:	557d                	li	a0,-1
    80002d1c:	bfe1                	j	80002cf4 <cow_handler+0x66>
    return -1; // crazy addresses
    80002d1e:	557d                	li	a0,-1
    80002d20:	bfd1                	j	80002cf4 <cow_handler+0x66>

0000000080002d22 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002d22:	1141                	addi	sp,sp,-16
    80002d24:	e406                	sd	ra,8(sp)
    80002d26:	e022                	sd	s0,0(sp)
    80002d28:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002d2a:	fffff097          	auipc	ra,0xfffff
    80002d2e:	e36080e7          	jalr	-458(ra) # 80001b60 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d32:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d36:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d38:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002d3c:	00004697          	auipc	a3,0x4
    80002d40:	2c468693          	addi	a3,a3,708 # 80007000 <_trampoline>
    80002d44:	00004717          	auipc	a4,0x4
    80002d48:	2bc70713          	addi	a4,a4,700 # 80007000 <_trampoline>
    80002d4c:	8f15                	sub	a4,a4,a3
    80002d4e:	040007b7          	lui	a5,0x4000
    80002d52:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002d54:	07b2                	slli	a5,a5,0xc
    80002d56:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d58:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d5c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d5e:	18002673          	csrr	a2,satp
    80002d62:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d64:	6d30                	ld	a2,88(a0)
    80002d66:	6138                	ld	a4,64(a0)
    80002d68:	6585                	lui	a1,0x1
    80002d6a:	972e                	add	a4,a4,a1
    80002d6c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d6e:	6d38                	ld	a4,88(a0)
    80002d70:	00000617          	auipc	a2,0x0
    80002d74:	13e60613          	addi	a2,a2,318 # 80002eae <usertrap>
    80002d78:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002d7a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d7c:	8612                	mv	a2,tp
    80002d7e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d80:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d84:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d88:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d8c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002d90:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d92:	6f18                	ld	a4,24(a4)
    80002d94:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002d98:	6928                	ld	a0,80(a0)
    80002d9a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002d9c:	00004717          	auipc	a4,0x4
    80002da0:	30070713          	addi	a4,a4,768 # 8000709c <userret>
    80002da4:	8f15                	sub	a4,a4,a3
    80002da6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002da8:	577d                	li	a4,-1
    80002daa:	177e                	slli	a4,a4,0x3f
    80002dac:	8d59                	or	a0,a0,a4
    80002dae:	9782                	jalr	a5
}
    80002db0:	60a2                	ld	ra,8(sp)
    80002db2:	6402                	ld	s0,0(sp)
    80002db4:	0141                	addi	sp,sp,16
    80002db6:	8082                	ret

0000000080002db8 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002db8:	1101                	addi	sp,sp,-32
    80002dba:	ec06                	sd	ra,24(sp)
    80002dbc:	e822                	sd	s0,16(sp)
    80002dbe:	e426                	sd	s1,8(sp)
    80002dc0:	e04a                	sd	s2,0(sp)
    80002dc2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002dc4:	00236917          	auipc	s2,0x236
    80002dc8:	f3c90913          	addi	s2,s2,-196 # 80238d00 <tickslock>
    80002dcc:	854a                	mv	a0,s2
    80002dce:	ffffe097          	auipc	ra,0xffffe
    80002dd2:	f48080e7          	jalr	-184(ra) # 80000d16 <acquire>
  ticks++;
    80002dd6:	00006497          	auipc	s1,0x6
    80002dda:	e3a48493          	addi	s1,s1,-454 # 80008c10 <ticks>
    80002dde:	409c                	lw	a5,0(s1)
    80002de0:	2785                	addiw	a5,a5,1
    80002de2:	c09c                	sw	a5,0(s1)

  update_times(); // update certain time units of processes
    80002de4:	00000097          	auipc	ra,0x0
    80002de8:	a18080e7          	jalr	-1512(ra) # 800027fc <update_times>

  wakeup(&ticks);
    80002dec:	8526                	mv	a0,s1
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	85c080e7          	jalr	-1956(ra) # 8000264a <wakeup>
  release(&tickslock);
    80002df6:	854a                	mv	a0,s2
    80002df8:	ffffe097          	auipc	ra,0xffffe
    80002dfc:	fd2080e7          	jalr	-46(ra) # 80000dca <release>
}
    80002e00:	60e2                	ld	ra,24(sp)
    80002e02:	6442                	ld	s0,16(sp)
    80002e04:	64a2                	ld	s1,8(sp)
    80002e06:	6902                	ld	s2,0(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret

0000000080002e0c <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr() // CAN BE CALLED FROM BOTH USER SPACE AND KERNEL SPACE
{
    80002e0c:	1101                	addi	sp,sp,-32
    80002e0e:	ec06                	sd	ra,24(sp)
    80002e10:	e822                	sd	s0,16(sp)
    80002e12:	e426                	sd	s1,8(sp)
    80002e14:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e16:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002e1a:	00074d63          	bltz	a4,80002e34 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002e1e:	57fd                	li	a5,-1
    80002e20:	17fe                	slli	a5,a5,0x3f
    80002e22:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002e24:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002e26:	06f70363          	beq	a4,a5,80002e8c <devintr+0x80>
  }
}
    80002e2a:	60e2                	ld	ra,24(sp)
    80002e2c:	6442                	ld	s0,16(sp)
    80002e2e:	64a2                	ld	s1,8(sp)
    80002e30:	6105                	addi	sp,sp,32
    80002e32:	8082                	ret
      (scause & 0xff) == 9)
    80002e34:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002e38:	46a5                	li	a3,9
    80002e3a:	fed792e3          	bne	a5,a3,80002e1e <devintr+0x12>
    int irq = plic_claim();
    80002e3e:	00004097          	auipc	ra,0x4
    80002e42:	a1a080e7          	jalr	-1510(ra) # 80006858 <plic_claim>
    80002e46:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002e48:	47a9                	li	a5,10
    80002e4a:	02f50763          	beq	a0,a5,80002e78 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002e4e:	4785                	li	a5,1
    80002e50:	02f50963          	beq	a0,a5,80002e82 <devintr+0x76>
    return 1;
    80002e54:	4505                	li	a0,1
    else if (irq)
    80002e56:	d8f1                	beqz	s1,80002e2a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002e58:	85a6                	mv	a1,s1
    80002e5a:	00005517          	auipc	a0,0x5
    80002e5e:	52e50513          	addi	a0,a0,1326 # 80008388 <states.0+0x50>
    80002e62:	ffffd097          	auipc	ra,0xffffd
    80002e66:	728080e7          	jalr	1832(ra) # 8000058a <printf>
      plic_complete(irq);
    80002e6a:	8526                	mv	a0,s1
    80002e6c:	00004097          	auipc	ra,0x4
    80002e70:	a10080e7          	jalr	-1520(ra) # 8000687c <plic_complete>
    return 1;
    80002e74:	4505                	li	a0,1
    80002e76:	bf55                	j	80002e2a <devintr+0x1e>
      uartintr();
    80002e78:	ffffe097          	auipc	ra,0xffffe
    80002e7c:	b20080e7          	jalr	-1248(ra) # 80000998 <uartintr>
    80002e80:	b7ed                	j	80002e6a <devintr+0x5e>
      virtio_disk_intr();
    80002e82:	00004097          	auipc	ra,0x4
    80002e86:	ec2080e7          	jalr	-318(ra) # 80006d44 <virtio_disk_intr>
    80002e8a:	b7c5                	j	80002e6a <devintr+0x5e>
    if (cpuid() == 0)
    80002e8c:	fffff097          	auipc	ra,0xfffff
    80002e90:	ca8080e7          	jalr	-856(ra) # 80001b34 <cpuid>
    80002e94:	c901                	beqz	a0,80002ea4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e96:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002e9a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e9c:	14479073          	csrw	sip,a5
    return 2;
    80002ea0:	4509                	li	a0,2
    80002ea2:	b761                	j	80002e2a <devintr+0x1e>
      clockintr();
    80002ea4:	00000097          	auipc	ra,0x0
    80002ea8:	f14080e7          	jalr	-236(ra) # 80002db8 <clockintr>
    80002eac:	b7ed                	j	80002e96 <devintr+0x8a>

0000000080002eae <usertrap>:
{
    80002eae:	7179                	addi	sp,sp,-48
    80002eb0:	f406                	sd	ra,40(sp)
    80002eb2:	f022                	sd	s0,32(sp)
    80002eb4:	ec26                	sd	s1,24(sp)
    80002eb6:	e84a                	sd	s2,16(sp)
    80002eb8:	e44e                	sd	s3,8(sp)
    80002eba:	e052                	sd	s4,0(sp)
    80002ebc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ebe:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002ec2:	1007f793          	andi	a5,a5,256
    80002ec6:	e7b9                	bnez	a5,80002f14 <usertrap+0x66>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ec8:	00004797          	auipc	a5,0x4
    80002ecc:	88878793          	addi	a5,a5,-1912 # 80006750 <kernelvec>
    80002ed0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ed4:	fffff097          	auipc	ra,0xfffff
    80002ed8:	c8c080e7          	jalr	-884(ra) # 80001b60 <myproc>
    80002edc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ede:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ee0:	14102773          	csrr	a4,sepc
    80002ee4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ee6:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002eea:	47a1                	li	a5,8
    80002eec:	02f70c63          	beq	a4,a5,80002f24 <usertrap+0x76>
    80002ef0:	14202773          	csrr	a4,scause
  else if (r_scause() == 0xf)
    80002ef4:	47bd                	li	a5,15
    80002ef6:	08f70263          	beq	a4,a5,80002f7a <usertrap+0xcc>
  else if ((which_dev = devintr()) != 0)
    80002efa:	00000097          	auipc	ra,0x0
    80002efe:	f12080e7          	jalr	-238(ra) # 80002e0c <devintr>
    80002f02:	892a                	mv	s2,a0
    80002f04:	c559                	beqz	a0,80002f92 <usertrap+0xe4>
  if (killed(p))
    80002f06:	8526                	mv	a0,s1
    80002f08:	00000097          	auipc	ra,0x0
    80002f0c:	a20080e7          	jalr	-1504(ra) # 80002928 <killed>
    80002f10:	c561                	beqz	a0,80002fd8 <usertrap+0x12a>
    80002f12:	a875                	j	80002fce <usertrap+0x120>
    panic("usertrap: not from user mode");
    80002f14:	00005517          	auipc	a0,0x5
    80002f18:	49450513          	addi	a0,a0,1172 # 800083a8 <states.0+0x70>
    80002f1c:	ffffd097          	auipc	ra,0xffffd
    80002f20:	624080e7          	jalr	1572(ra) # 80000540 <panic>
    if (killed(p))
    80002f24:	00000097          	auipc	ra,0x0
    80002f28:	a04080e7          	jalr	-1532(ra) # 80002928 <killed>
    80002f2c:	e129                	bnez	a0,80002f6e <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002f2e:	6cb8                	ld	a4,88(s1)
    80002f30:	6f1c                	ld	a5,24(a4)
    80002f32:	0791                	addi	a5,a5,4
    80002f34:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f36:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f3a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f3e:	10079073          	csrw	sstatus,a5
    syscall();
    80002f42:	00000097          	auipc	ra,0x0
    80002f46:	424080e7          	jalr	1060(ra) # 80003366 <syscall>
  if (killed(p))
    80002f4a:	8526                	mv	a0,s1
    80002f4c:	00000097          	auipc	ra,0x0
    80002f50:	9dc080e7          	jalr	-1572(ra) # 80002928 <killed>
    80002f54:	ed25                	bnez	a0,80002fcc <usertrap+0x11e>
  usertrapret();
    80002f56:	00000097          	auipc	ra,0x0
    80002f5a:	dcc080e7          	jalr	-564(ra) # 80002d22 <usertrapret>
}
    80002f5e:	70a2                	ld	ra,40(sp)
    80002f60:	7402                	ld	s0,32(sp)
    80002f62:	64e2                	ld	s1,24(sp)
    80002f64:	6942                	ld	s2,16(sp)
    80002f66:	69a2                	ld	s3,8(sp)
    80002f68:	6a02                	ld	s4,0(sp)
    80002f6a:	6145                	addi	sp,sp,48
    80002f6c:	8082                	ret
      exit(-1);
    80002f6e:	557d                	li	a0,-1
    80002f70:	fffff097          	auipc	ra,0xfffff
    80002f74:	7aa080e7          	jalr	1962(ra) # 8000271a <exit>
    80002f78:	bf5d                	j	80002f2e <usertrap+0x80>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f7a:	143025f3          	csrr	a1,stval
    if (cow_handler(p->pagetable, r_stval()) < 0)
    80002f7e:	6928                	ld	a0,80(a0)
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	d0e080e7          	jalr	-754(ra) # 80002c8e <cow_handler>
    80002f88:	fc0551e3          	bgez	a0,80002f4a <usertrap+0x9c>
      p->killed = 1;
    80002f8c:	4785                	li	a5,1
    80002f8e:	d49c                	sw	a5,40(s1)
    80002f90:	bf6d                	j	80002f4a <usertrap+0x9c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f92:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f96:	5890                	lw	a2,48(s1)
    80002f98:	00005517          	auipc	a0,0x5
    80002f9c:	43050513          	addi	a0,a0,1072 # 800083c8 <states.0+0x90>
    80002fa0:	ffffd097          	auipc	ra,0xffffd
    80002fa4:	5ea080e7          	jalr	1514(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fa8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fac:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fb0:	00005517          	auipc	a0,0x5
    80002fb4:	44850513          	addi	a0,a0,1096 # 800083f8 <states.0+0xc0>
    80002fb8:	ffffd097          	auipc	ra,0xffffd
    80002fbc:	5d2080e7          	jalr	1490(ra) # 8000058a <printf>
    setkilled(p);
    80002fc0:	8526                	mv	a0,s1
    80002fc2:	00000097          	auipc	ra,0x0
    80002fc6:	93a080e7          	jalr	-1734(ra) # 800028fc <setkilled>
    80002fca:	b741                	j	80002f4a <usertrap+0x9c>
  if (killed(p))
    80002fcc:	4901                	li	s2,0
    exit(-1);
    80002fce:	557d                	li	a0,-1
    80002fd0:	fffff097          	auipc	ra,0xfffff
    80002fd4:	74a080e7          	jalr	1866(ra) # 8000271a <exit>
  if (which_dev == 2 && myproc() && myproc()->state == RUNNING)
    80002fd8:	4789                	li	a5,2
    80002fda:	f6f91ee3          	bne	s2,a5,80002f56 <usertrap+0xa8>
    80002fde:	fffff097          	auipc	ra,0xfffff
    80002fe2:	b82080e7          	jalr	-1150(ra) # 80001b60 <myproc>
    80002fe6:	c909                	beqz	a0,80002ff8 <usertrap+0x14a>
    80002fe8:	fffff097          	auipc	ra,0xfffff
    80002fec:	b78080e7          	jalr	-1160(ra) # 80001b60 <myproc>
    80002ff0:	4d18                	lw	a4,24(a0)
    80002ff2:	4791                	li	a5,4
    80002ff4:	06f70963          	beq	a4,a5,80003066 <usertrap+0x1b8>
  if ((which_dev == 2) && (p != 0) && (p->state == RUNNING) && (p->alarmint != 0)) // TIMER INTERRUPT FROM USER SPACE WHEN PROCESS IS RUNNING
    80002ff8:	4c98                	lw	a4,24(s1)
    80002ffa:	4791                	li	a5,4
    80002ffc:	f4f71de3          	bne	a4,a5,80002f56 <usertrap+0xa8>
    80003000:	1b04a783          	lw	a5,432(s1)
    80003004:	dba9                	beqz	a5,80002f56 <usertrap+0xa8>
    p->tslalarm += 1;                                      // incrementing time since last alarm
    80003006:	1c04a703          	lw	a4,448(s1)
    8000300a:	2705                	addiw	a4,a4,1
    8000300c:	0007069b          	sext.w	a3,a4
    80003010:	1ce4a023          	sw	a4,448(s1)
    if ((p->tslalarm >= p->alarmint) && (!p->is_sigalarm)) // Ohh !! we have to call the handler now
    80003014:	04f6c463          	blt	a3,a5,8000305c <usertrap+0x1ae>
    80003018:	1ac4a783          	lw	a5,428(s1)
    8000301c:	e3a1                	bnez	a5,8000305c <usertrap+0x1ae>
      p->tslalarm = 0;                     // resetting value of tslalarm
    8000301e:	1c04a023          	sw	zero,448(s1)
      p->is_sigalarm = 1;                  // enabling alarm
    80003022:	4785                	li	a5,1
    80003024:	1af4a623          	sw	a5,428(s1)
      *(p->tf_copy) = *(p->trapframe);     // storing the current state in copy
    80003028:	6cb4                	ld	a3,88(s1)
    8000302a:	87b6                	mv	a5,a3
    8000302c:	1c84b703          	ld	a4,456(s1)
    80003030:	12068693          	addi	a3,a3,288
    80003034:	0007b803          	ld	a6,0(a5)
    80003038:	6788                	ld	a0,8(a5)
    8000303a:	6b8c                	ld	a1,16(a5)
    8000303c:	6f90                	ld	a2,24(a5)
    8000303e:	01073023          	sd	a6,0(a4)
    80003042:	e708                	sd	a0,8(a4)
    80003044:	eb0c                	sd	a1,16(a4)
    80003046:	ef10                	sd	a2,24(a4)
    80003048:	02078793          	addi	a5,a5,32
    8000304c:	02070713          	addi	a4,a4,32
    80003050:	fed792e3          	bne	a5,a3,80003034 <usertrap+0x186>
      p->trapframe->epc = p->alarmhandler; // calling handler function
    80003054:	6cbc                	ld	a5,88(s1)
    80003056:	1b84b703          	ld	a4,440(s1)
    8000305a:	ef98                	sd	a4,24(a5)
    yield();
    8000305c:	fffff097          	auipc	ra,0xfffff
    80003060:	3fe080e7          	jalr	1022(ra) # 8000245a <yield>
    80003064:	bdcd                	j	80002f56 <usertrap+0xa8>
    struct proc *p = myproc();
    80003066:	fffff097          	auipc	ra,0xfffff
    8000306a:	afa080e7          	jalr	-1286(ra) # 80001b60 <myproc>
    8000306e:	8a2a                	mv	s4,a0
    if (p->timeslice <= 0)
    80003070:	19052783          	lw	a5,400(a0)
    80003074:	00f05c63          	blez	a5,8000308c <usertrap+0x1de>
    for (int i = 0; i < p->queueno; i++)
    80003078:	188a2783          	lw	a5,392(s4)
    8000307c:	f6f05ee3          	blez	a5,80002ff8 <usertrap+0x14a>
    80003080:	0022e997          	auipc	s3,0x22e
    80003084:	e3098993          	addi	s3,s3,-464 # 80230eb0 <queues>
    80003088:	4901                	li	s2,0
    8000308a:	a025                	j	800030b2 <usertrap+0x204>
      if (p->queueno < 4)
    8000308c:	18852783          	lw	a5,392(a0)
    80003090:	470d                	li	a4,3
    80003092:	00f74563          	blt	a4,a5,8000309c <usertrap+0x1ee>
        p->queueno += 1;
    80003096:	2785                	addiw	a5,a5,1
    80003098:	18f52423          	sw	a5,392(a0)
      yield();
    8000309c:	fffff097          	auipc	ra,0xfffff
    800030a0:	3be080e7          	jalr	958(ra) # 8000245a <yield>
    800030a4:	bfd1                	j	80003078 <usertrap+0x1ca>
    for (int i = 0; i < p->queueno; i++)
    800030a6:	2905                	addiw	s2,s2,1
    800030a8:	09a1                	addi	s3,s3,8
    800030aa:	188a2783          	lw	a5,392(s4)
    800030ae:	f4f955e3          	bge	s2,a5,80002ff8 <usertrap+0x14a>
      if (queues[i])
    800030b2:	0009b783          	ld	a5,0(s3)
    800030b6:	dbe5                	beqz	a5,800030a6 <usertrap+0x1f8>
        yield();
    800030b8:	fffff097          	auipc	ra,0xfffff
    800030bc:	3a2080e7          	jalr	930(ra) # 8000245a <yield>
    800030c0:	b7dd                	j	800030a6 <usertrap+0x1f8>

00000000800030c2 <kerneltrap>:
{
    800030c2:	7139                	addi	sp,sp,-64
    800030c4:	fc06                	sd	ra,56(sp)
    800030c6:	f822                	sd	s0,48(sp)
    800030c8:	f426                	sd	s1,40(sp)
    800030ca:	f04a                	sd	s2,32(sp)
    800030cc:	ec4e                	sd	s3,24(sp)
    800030ce:	e852                	sd	s4,16(sp)
    800030d0:	e456                	sd	s5,8(sp)
    800030d2:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030d4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030d8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030dc:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    800030e0:	1004f793          	andi	a5,s1,256
    800030e4:	cb95                	beqz	a5,80003118 <kerneltrap+0x56>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030e6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800030ea:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800030ec:	ef95                	bnez	a5,80003128 <kerneltrap+0x66>
  if ((which_dev = devintr()) == 0)
    800030ee:	00000097          	auipc	ra,0x0
    800030f2:	d1e080e7          	jalr	-738(ra) # 80002e0c <devintr>
    800030f6:	c129                	beqz	a0,80003138 <kerneltrap+0x76>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030f8:	4789                	li	a5,2
    800030fa:	06f50c63          	beq	a0,a5,80003172 <kerneltrap+0xb0>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030fe:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003102:	10049073          	csrw	sstatus,s1
}
    80003106:	70e2                	ld	ra,56(sp)
    80003108:	7442                	ld	s0,48(sp)
    8000310a:	74a2                	ld	s1,40(sp)
    8000310c:	7902                	ld	s2,32(sp)
    8000310e:	69e2                	ld	s3,24(sp)
    80003110:	6a42                	ld	s4,16(sp)
    80003112:	6aa2                	ld	s5,8(sp)
    80003114:	6121                	addi	sp,sp,64
    80003116:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003118:	00005517          	auipc	a0,0x5
    8000311c:	30050513          	addi	a0,a0,768 # 80008418 <states.0+0xe0>
    80003120:	ffffd097          	auipc	ra,0xffffd
    80003124:	420080e7          	jalr	1056(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80003128:	00005517          	auipc	a0,0x5
    8000312c:	31850513          	addi	a0,a0,792 # 80008440 <states.0+0x108>
    80003130:	ffffd097          	auipc	ra,0xffffd
    80003134:	410080e7          	jalr	1040(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80003138:	85ce                	mv	a1,s3
    8000313a:	00005517          	auipc	a0,0x5
    8000313e:	32650513          	addi	a0,a0,806 # 80008460 <states.0+0x128>
    80003142:	ffffd097          	auipc	ra,0xffffd
    80003146:	448080e7          	jalr	1096(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000314a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000314e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003152:	00005517          	auipc	a0,0x5
    80003156:	31e50513          	addi	a0,a0,798 # 80008470 <states.0+0x138>
    8000315a:	ffffd097          	auipc	ra,0xffffd
    8000315e:	430080e7          	jalr	1072(ra) # 8000058a <printf>
    panic("kerneltrap");
    80003162:	00005517          	auipc	a0,0x5
    80003166:	32650513          	addi	a0,a0,806 # 80008488 <states.0+0x150>
    8000316a:	ffffd097          	auipc	ra,0xffffd
    8000316e:	3d6080e7          	jalr	982(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003172:	fffff097          	auipc	ra,0xfffff
    80003176:	9ee080e7          	jalr	-1554(ra) # 80001b60 <myproc>
    8000317a:	d151                	beqz	a0,800030fe <kerneltrap+0x3c>
    8000317c:	fffff097          	auipc	ra,0xfffff
    80003180:	9e4080e7          	jalr	-1564(ra) # 80001b60 <myproc>
    80003184:	4d18                	lw	a4,24(a0)
    80003186:	4791                	li	a5,4
    80003188:	f6f71be3          	bne	a4,a5,800030fe <kerneltrap+0x3c>
    struct proc *p = myproc();
    8000318c:	fffff097          	auipc	ra,0xfffff
    80003190:	9d4080e7          	jalr	-1580(ra) # 80001b60 <myproc>
    80003194:	8aaa                	mv	s5,a0
    if (p->timeslice <= 0)
    80003196:	19052783          	lw	a5,400(a0)
    8000319a:	00f05c63          	blez	a5,800031b2 <kerneltrap+0xf0>
    for (int i = 0; i < p->queueno; i++)
    8000319e:	188aa783          	lw	a5,392(s5)
    800031a2:	f4f05ee3          	blez	a5,800030fe <kerneltrap+0x3c>
    800031a6:	0022ea17          	auipc	s4,0x22e
    800031aa:	d0aa0a13          	addi	s4,s4,-758 # 80230eb0 <queues>
    800031ae:	4981                	li	s3,0
    800031b0:	a025                	j	800031d8 <kerneltrap+0x116>
      if (p->queueno < 4)
    800031b2:	18852783          	lw	a5,392(a0)
    800031b6:	470d                	li	a4,3
    800031b8:	00f74563          	blt	a4,a5,800031c2 <kerneltrap+0x100>
        p->queueno += 1;
    800031bc:	2785                	addiw	a5,a5,1
    800031be:	18f52423          	sw	a5,392(a0)
      yield();
    800031c2:	fffff097          	auipc	ra,0xfffff
    800031c6:	298080e7          	jalr	664(ra) # 8000245a <yield>
    800031ca:	bfd1                	j	8000319e <kerneltrap+0xdc>
    for (int i = 0; i < p->queueno; i++)
    800031cc:	2985                	addiw	s3,s3,1
    800031ce:	0a21                	addi	s4,s4,8
    800031d0:	188aa783          	lw	a5,392(s5)
    800031d4:	f2f9d5e3          	bge	s3,a5,800030fe <kerneltrap+0x3c>
      if (queues[i])
    800031d8:	000a3783          	ld	a5,0(s4)
    800031dc:	dbe5                	beqz	a5,800031cc <kerneltrap+0x10a>
        yield();
    800031de:	fffff097          	auipc	ra,0xfffff
    800031e2:	27c080e7          	jalr	636(ra) # 8000245a <yield>
    800031e6:	b7dd                	j	800031cc <kerneltrap+0x10a>

00000000800031e8 <argraw>:
//   return 0;
// }

static uint64
argraw(int n)
{
    800031e8:	1101                	addi	sp,sp,-32
    800031ea:	ec06                	sd	ra,24(sp)
    800031ec:	e822                	sd	s0,16(sp)
    800031ee:	e426                	sd	s1,8(sp)
    800031f0:	1000                	addi	s0,sp,32
    800031f2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	96c080e7          	jalr	-1684(ra) # 80001b60 <myproc>
  switch (n)
    800031fc:	4795                	li	a5,5
    800031fe:	0497e163          	bltu	a5,s1,80003240 <argraw+0x58>
    80003202:	048a                	slli	s1,s1,0x2
    80003204:	00005717          	auipc	a4,0x5
    80003208:	3dc70713          	addi	a4,a4,988 # 800085e0 <states.0+0x2a8>
    8000320c:	94ba                	add	s1,s1,a4
    8000320e:	409c                	lw	a5,0(s1)
    80003210:	97ba                	add	a5,a5,a4
    80003212:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80003214:	6d3c                	ld	a5,88(a0)
    80003216:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003218:	60e2                	ld	ra,24(sp)
    8000321a:	6442                	ld	s0,16(sp)
    8000321c:	64a2                	ld	s1,8(sp)
    8000321e:	6105                	addi	sp,sp,32
    80003220:	8082                	ret
    return p->trapframe->a1;
    80003222:	6d3c                	ld	a5,88(a0)
    80003224:	7fa8                	ld	a0,120(a5)
    80003226:	bfcd                	j	80003218 <argraw+0x30>
    return p->trapframe->a2;
    80003228:	6d3c                	ld	a5,88(a0)
    8000322a:	63c8                	ld	a0,128(a5)
    8000322c:	b7f5                	j	80003218 <argraw+0x30>
    return p->trapframe->a3;
    8000322e:	6d3c                	ld	a5,88(a0)
    80003230:	67c8                	ld	a0,136(a5)
    80003232:	b7dd                	j	80003218 <argraw+0x30>
    return p->trapframe->a4;
    80003234:	6d3c                	ld	a5,88(a0)
    80003236:	6bc8                	ld	a0,144(a5)
    80003238:	b7c5                	j	80003218 <argraw+0x30>
    return p->trapframe->a5;
    8000323a:	6d3c                	ld	a5,88(a0)
    8000323c:	6fc8                	ld	a0,152(a5)
    8000323e:	bfe9                	j	80003218 <argraw+0x30>
  panic("argraw");
    80003240:	00005517          	auipc	a0,0x5
    80003244:	25850513          	addi	a0,a0,600 # 80008498 <states.0+0x160>
    80003248:	ffffd097          	auipc	ra,0xffffd
    8000324c:	2f8080e7          	jalr	760(ra) # 80000540 <panic>

0000000080003250 <fetchaddr>:
{
    80003250:	1101                	addi	sp,sp,-32
    80003252:	ec06                	sd	ra,24(sp)
    80003254:	e822                	sd	s0,16(sp)
    80003256:	e426                	sd	s1,8(sp)
    80003258:	e04a                	sd	s2,0(sp)
    8000325a:	1000                	addi	s0,sp,32
    8000325c:	84aa                	mv	s1,a0
    8000325e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003260:	fffff097          	auipc	ra,0xfffff
    80003264:	900080e7          	jalr	-1792(ra) # 80001b60 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003268:	653c                	ld	a5,72(a0)
    8000326a:	02f4f863          	bgeu	s1,a5,8000329a <fetchaddr+0x4a>
    8000326e:	00848713          	addi	a4,s1,8
    80003272:	02e7e663          	bltu	a5,a4,8000329e <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003276:	46a1                	li	a3,8
    80003278:	8626                	mv	a2,s1
    8000327a:	85ca                	mv	a1,s2
    8000327c:	6928                	ld	a0,80(a0)
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	5f4080e7          	jalr	1524(ra) # 80001872 <copyin>
    80003286:	00a03533          	snez	a0,a0
    8000328a:	40a00533          	neg	a0,a0
}
    8000328e:	60e2                	ld	ra,24(sp)
    80003290:	6442                	ld	s0,16(sp)
    80003292:	64a2                	ld	s1,8(sp)
    80003294:	6902                	ld	s2,0(sp)
    80003296:	6105                	addi	sp,sp,32
    80003298:	8082                	ret
    return -1;
    8000329a:	557d                	li	a0,-1
    8000329c:	bfcd                	j	8000328e <fetchaddr+0x3e>
    8000329e:	557d                	li	a0,-1
    800032a0:	b7fd                	j	8000328e <fetchaddr+0x3e>

00000000800032a2 <fetchstr>:
{
    800032a2:	7179                	addi	sp,sp,-48
    800032a4:	f406                	sd	ra,40(sp)
    800032a6:	f022                	sd	s0,32(sp)
    800032a8:	ec26                	sd	s1,24(sp)
    800032aa:	e84a                	sd	s2,16(sp)
    800032ac:	e44e                	sd	s3,8(sp)
    800032ae:	1800                	addi	s0,sp,48
    800032b0:	892a                	mv	s2,a0
    800032b2:	84ae                	mv	s1,a1
    800032b4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800032b6:	fffff097          	auipc	ra,0xfffff
    800032ba:	8aa080e7          	jalr	-1878(ra) # 80001b60 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800032be:	86ce                	mv	a3,s3
    800032c0:	864a                	mv	a2,s2
    800032c2:	85a6                	mv	a1,s1
    800032c4:	6928                	ld	a0,80(a0)
    800032c6:	ffffe097          	auipc	ra,0xffffe
    800032ca:	63a080e7          	jalr	1594(ra) # 80001900 <copyinstr>
    800032ce:	00054e63          	bltz	a0,800032ea <fetchstr+0x48>
  return strlen(buf);
    800032d2:	8526                	mv	a0,s1
    800032d4:	ffffe097          	auipc	ra,0xffffe
    800032d8:	cba080e7          	jalr	-838(ra) # 80000f8e <strlen>
}
    800032dc:	70a2                	ld	ra,40(sp)
    800032de:	7402                	ld	s0,32(sp)
    800032e0:	64e2                	ld	s1,24(sp)
    800032e2:	6942                	ld	s2,16(sp)
    800032e4:	69a2                	ld	s3,8(sp)
    800032e6:	6145                	addi	sp,sp,48
    800032e8:	8082                	ret
    return -1;
    800032ea:	557d                	li	a0,-1
    800032ec:	bfc5                	j	800032dc <fetchstr+0x3a>

00000000800032ee <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    800032ee:	1101                	addi	sp,sp,-32
    800032f0:	ec06                	sd	ra,24(sp)
    800032f2:	e822                	sd	s0,16(sp)
    800032f4:	e426                	sd	s1,8(sp)
    800032f6:	1000                	addi	s0,sp,32
    800032f8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	eee080e7          	jalr	-274(ra) # 800031e8 <argraw>
    80003302:	c088                	sw	a0,0(s1)
}
    80003304:	60e2                	ld	ra,24(sp)
    80003306:	6442                	ld	s0,16(sp)
    80003308:	64a2                	ld	s1,8(sp)
    8000330a:	6105                	addi	sp,sp,32
    8000330c:	8082                	ret

000000008000330e <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip) // copies
{
    8000330e:	1101                	addi	sp,sp,-32
    80003310:	ec06                	sd	ra,24(sp)
    80003312:	e822                	sd	s0,16(sp)
    80003314:	e426                	sd	s1,8(sp)
    80003316:	1000                	addi	s0,sp,32
    80003318:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000331a:	00000097          	auipc	ra,0x0
    8000331e:	ece080e7          	jalr	-306(ra) # 800031e8 <argraw>
    80003322:	e088                	sd	a0,0(s1)
}
    80003324:	60e2                	ld	ra,24(sp)
    80003326:	6442                	ld	s0,16(sp)
    80003328:	64a2                	ld	s1,8(sp)
    8000332a:	6105                	addi	sp,sp,32
    8000332c:	8082                	ret

000000008000332e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.

int argstr(int n, char *buf, int max)
{
    8000332e:	7179                	addi	sp,sp,-48
    80003330:	f406                	sd	ra,40(sp)
    80003332:	f022                	sd	s0,32(sp)
    80003334:	ec26                	sd	s1,24(sp)
    80003336:	e84a                	sd	s2,16(sp)
    80003338:	1800                	addi	s0,sp,48
    8000333a:	84ae                	mv	s1,a1
    8000333c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000333e:	fd840593          	addi	a1,s0,-40
    80003342:	00000097          	auipc	ra,0x0
    80003346:	fcc080e7          	jalr	-52(ra) # 8000330e <argaddr>
  return fetchstr(addr, buf, max);
    8000334a:	864a                	mv	a2,s2
    8000334c:	85a6                	mv	a1,s1
    8000334e:	fd843503          	ld	a0,-40(s0)
    80003352:	00000097          	auipc	ra,0x0
    80003356:	f50080e7          	jalr	-176(ra) # 800032a2 <fetchstr>
}
    8000335a:	70a2                	ld	ra,40(sp)
    8000335c:	7402                	ld	s0,32(sp)
    8000335e:	64e2                	ld	s1,24(sp)
    80003360:	6942                	ld	s2,16(sp)
    80003362:	6145                	addi	sp,sp,48
    80003364:	8082                	ret

0000000080003366 <syscall>:

// sys_ps
// sys_set_priority
// sys_waitx
void syscall(void) // IS CALLED WHEN A SYSTEM CALL IS DONE
{
    80003366:	7139                	addi	sp,sp,-64
    80003368:	fc06                	sd	ra,56(sp)
    8000336a:	f822                	sd	s0,48(sp)
    8000336c:	f426                	sd	s1,40(sp)
    8000336e:	f04a                	sd	s2,32(sp)
    80003370:	ec4e                	sd	s3,24(sp)
    80003372:	e852                	sd	s4,16(sp)
    80003374:	e456                	sd	s5,8(sp)
    80003376:	e05a                	sd	s6,0(sp)
    80003378:	0080                	addi	s0,sp,64
  int num, mask;
  struct proc *p = myproc(); // PROCESS
    8000337a:	ffffe097          	auipc	ra,0xffffe
    8000337e:	7e6080e7          	jalr	2022(ra) # 80001b60 <myproc>
    80003382:	84aa                	mv	s1,a0

  num = p->trapframe->a7; // syscall number
    80003384:	05853983          	ld	s3,88(a0)
    80003388:	0a89b783          	ld	a5,168(s3)
    8000338c:	00078a1b          	sext.w	s4,a5
  mask = p->mask;         // getting maskgetrea
    80003390:	16852903          	lw	s2,360(a0)
  if (num == SYS_read)
    80003394:	4715                	li	a4,5
    80003396:	0aea0a63          	beq	s4,a4,8000344a <syscall+0xe4>
  {
    // p->readid = p->readid + 1; // my change
    readcount++; // my change
  }
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    8000339a:	37fd                	addiw	a5,a5,-1
    8000339c:	476d                	li	a4,27
    8000339e:	0cf76563          	bltu	a4,a5,80003468 <syscall+0x102>
    800033a2:	003a1713          	slli	a4,s4,0x3
    800033a6:	00005797          	auipc	a5,0x5
    800033aa:	25278793          	addi	a5,a5,594 # 800085f8 <syscalls>
    800033ae:	97ba                	add	a5,a5,a4
    800033b0:	6398                	ld	a4,0(a5)
    800033b2:	cb5d                	beqz	a4,80003468 <syscall+0x102>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    int argc = syscall_argc[num];
    800033b4:	002a1693          	slli	a3,s4,0x2
    800033b8:	00005797          	auipc	a5,0x5
    800033bc:	79078793          	addi	a5,a5,1936 # 80008b48 <syscall_argc>
    800033c0:	97b6                	add	a5,a5,a3
    800033c2:	0007aa83          	lw	s5,0(a5)
    int arg_0 = p->trapframe->a0;
    800033c6:	0709bb03          	ld	s6,112(s3)
    p->trapframe->a0 = syscalls[num](); // return value of syscall
    800033ca:	9702                	jalr	a4
    800033cc:	06a9b823          	sd	a0,112(s3)

    // ADD CODE HERE TO CHECK FOR MASK AND IF SYSCALL NUMBER IS SET OR NOT

    if ((mask != -1) && (mask & (1 << num)))
    800033d0:	57fd                	li	a5,-1
    800033d2:	0af90a63          	beq	s2,a5,80003486 <syscall+0x120>
    800033d6:	4149593b          	sraw	s2,s2,s4
    800033da:	00197913          	andi	s2,s2,1
    800033de:	0a090463          	beqz	s2,80003486 <syscall+0x120>
    {
      // PRINT THE LINE
      printf("%d: ", p->pid);                    // pid
    800033e2:	588c                	lw	a1,48(s1)
    800033e4:	00005517          	auipc	a0,0x5
    800033e8:	0bc50513          	addi	a0,a0,188 # 800084a0 <states.0+0x168>
    800033ec:	ffffd097          	auipc	ra,0xffffd
    800033f0:	19e080e7          	jalr	414(ra) # 8000058a <printf>
      printf("syscall %s (", syscallnames[num]); // syscall name
    800033f4:	0a0e                	slli	s4,s4,0x3
    800033f6:	00005797          	auipc	a5,0x5
    800033fa:	20278793          	addi	a5,a5,514 # 800085f8 <syscalls>
    800033fe:	97d2                	add	a5,a5,s4
    80003400:	77ec                	ld	a1,232(a5)
    80003402:	00005517          	auipc	a0,0x5
    80003406:	0a650513          	addi	a0,a0,166 # 800084a8 <states.0+0x170>
    8000340a:	ffffd097          	auipc	ra,0xffffd
    8000340e:	180080e7          	jalr	384(ra) # 8000058a <printf>
      if (argc >= 1)
    80003412:	09504463          	bgtz	s5,8000349a <syscall+0x134>
        printf("%d", arg_0);
      if (argc >= 2)
    80003416:	4785                	li	a5,1
    80003418:	0957cc63          	blt	a5,s5,800034b0 <syscall+0x14a>
        printf(" %d", p->trapframe->a1);
      if (argc >= 3)
    8000341c:	4789                	li	a5,2
    8000341e:	0b57c463          	blt	a5,s5,800034c6 <syscall+0x160>
        printf(" %d", p->trapframe->a2);
      if (argc >= 4)
    80003422:	478d                	li	a5,3
    80003424:	0b57cc63          	blt	a5,s5,800034dc <syscall+0x176>
        printf(" %d", p->trapframe->a3);
      if (argc >= 5)
    80003428:	4791                	li	a5,4
    8000342a:	0d57c463          	blt	a5,s5,800034f2 <syscall+0x18c>
        printf(" %d", p->trapframe->a4);
      if (argc >= 6)
    8000342e:	4795                	li	a5,5
    80003430:	0d57cc63          	blt	a5,s5,80003508 <syscall+0x1a2>
        printf(" %d", p->trapframe->a5);
      printf(") -> %d\n", p->trapframe->a0); // return value
    80003434:	6cbc                	ld	a5,88(s1)
    80003436:	7bac                	ld	a1,112(a5)
    80003438:	00005517          	auipc	a0,0x5
    8000343c:	09050513          	addi	a0,a0,144 # 800084c8 <states.0+0x190>
    80003440:	ffffd097          	auipc	ra,0xffffd
    80003444:	14a080e7          	jalr	330(ra) # 8000058a <printf>
    80003448:	a83d                	j	80003486 <syscall+0x120>
    readcount++; // my change
    8000344a:	00005697          	auipc	a3,0x5
    8000344e:	7ca68693          	addi	a3,a3,1994 # 80008c14 <readcount>
    80003452:	4298                	lw	a4,0(a3)
    80003454:	2705                	addiw	a4,a4,1
    80003456:	c298                	sw	a4,0(a3)
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003458:	37fd                	addiw	a5,a5,-1
    8000345a:	46ed                	li	a3,27
    8000345c:	00003717          	auipc	a4,0x3
    80003460:	93270713          	addi	a4,a4,-1742 # 80005d8e <sys_read>
    80003464:	f4f6f8e3          	bgeu	a3,a5,800033b4 <syscall+0x4e>
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80003468:	86d2                	mv	a3,s4
    8000346a:	15848613          	addi	a2,s1,344
    8000346e:	588c                	lw	a1,48(s1)
    80003470:	00005517          	auipc	a0,0x5
    80003474:	06850513          	addi	a0,a0,104 # 800084d8 <states.0+0x1a0>
    80003478:	ffffd097          	auipc	ra,0xffffd
    8000347c:	112080e7          	jalr	274(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003480:	6cbc                	ld	a5,88(s1)
    80003482:	577d                	li	a4,-1
    80003484:	fbb8                	sd	a4,112(a5)
  }
}
    80003486:	70e2                	ld	ra,56(sp)
    80003488:	7442                	ld	s0,48(sp)
    8000348a:	74a2                	ld	s1,40(sp)
    8000348c:	7902                	ld	s2,32(sp)
    8000348e:	69e2                	ld	s3,24(sp)
    80003490:	6a42                	ld	s4,16(sp)
    80003492:	6aa2                	ld	s5,8(sp)
    80003494:	6b02                	ld	s6,0(sp)
    80003496:	6121                	addi	sp,sp,64
    80003498:	8082                	ret
        printf("%d", arg_0);
    8000349a:	000b059b          	sext.w	a1,s6
    8000349e:	00005517          	auipc	a0,0x5
    800034a2:	01a50513          	addi	a0,a0,26 # 800084b8 <states.0+0x180>
    800034a6:	ffffd097          	auipc	ra,0xffffd
    800034aa:	0e4080e7          	jalr	228(ra) # 8000058a <printf>
    800034ae:	b7a5                	j	80003416 <syscall+0xb0>
        printf(" %d", p->trapframe->a1);
    800034b0:	6cbc                	ld	a5,88(s1)
    800034b2:	7fac                	ld	a1,120(a5)
    800034b4:	00005517          	auipc	a0,0x5
    800034b8:	00c50513          	addi	a0,a0,12 # 800084c0 <states.0+0x188>
    800034bc:	ffffd097          	auipc	ra,0xffffd
    800034c0:	0ce080e7          	jalr	206(ra) # 8000058a <printf>
    800034c4:	bfa1                	j	8000341c <syscall+0xb6>
        printf(" %d", p->trapframe->a2);
    800034c6:	6cbc                	ld	a5,88(s1)
    800034c8:	63cc                	ld	a1,128(a5)
    800034ca:	00005517          	auipc	a0,0x5
    800034ce:	ff650513          	addi	a0,a0,-10 # 800084c0 <states.0+0x188>
    800034d2:	ffffd097          	auipc	ra,0xffffd
    800034d6:	0b8080e7          	jalr	184(ra) # 8000058a <printf>
    800034da:	b7a1                	j	80003422 <syscall+0xbc>
        printf(" %d", p->trapframe->a3);
    800034dc:	6cbc                	ld	a5,88(s1)
    800034de:	67cc                	ld	a1,136(a5)
    800034e0:	00005517          	auipc	a0,0x5
    800034e4:	fe050513          	addi	a0,a0,-32 # 800084c0 <states.0+0x188>
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	0a2080e7          	jalr	162(ra) # 8000058a <printf>
    800034f0:	bf25                	j	80003428 <syscall+0xc2>
        printf(" %d", p->trapframe->a4);
    800034f2:	6cbc                	ld	a5,88(s1)
    800034f4:	6bcc                	ld	a1,144(a5)
    800034f6:	00005517          	auipc	a0,0x5
    800034fa:	fca50513          	addi	a0,a0,-54 # 800084c0 <states.0+0x188>
    800034fe:	ffffd097          	auipc	ra,0xffffd
    80003502:	08c080e7          	jalr	140(ra) # 8000058a <printf>
    80003506:	b725                	j	8000342e <syscall+0xc8>
        printf(" %d", p->trapframe->a5);
    80003508:	6cbc                	ld	a5,88(s1)
    8000350a:	6fcc                	ld	a1,152(a5)
    8000350c:	00005517          	auipc	a0,0x5
    80003510:	fb450513          	addi	a0,a0,-76 # 800084c0 <states.0+0x188>
    80003514:	ffffd097          	auipc	ra,0xffffd
    80003518:	076080e7          	jalr	118(ra) # 8000058a <printf>
    8000351c:	bf21                	j	80003434 <syscall+0xce>

000000008000351e <sys_exit>:
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

uint64
sys_exit(void)
{
    8000351e:	1101                	addi	sp,sp,-32
    80003520:	ec06                	sd	ra,24(sp)
    80003522:	e822                	sd	s0,16(sp)
    80003524:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003526:	fec40593          	addi	a1,s0,-20
    8000352a:	4501                	li	a0,0
    8000352c:	00000097          	auipc	ra,0x0
    80003530:	dc2080e7          	jalr	-574(ra) # 800032ee <argint>
  exit(n);
    80003534:	fec42503          	lw	a0,-20(s0)
    80003538:	fffff097          	auipc	ra,0xfffff
    8000353c:	1e2080e7          	jalr	482(ra) # 8000271a <exit>
  return 0;  // not reached
}
    80003540:	4501                	li	a0,0
    80003542:	60e2                	ld	ra,24(sp)
    80003544:	6442                	ld	s0,16(sp)
    80003546:	6105                	addi	sp,sp,32
    80003548:	8082                	ret

000000008000354a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000354a:	1141                	addi	sp,sp,-16
    8000354c:	e406                	sd	ra,8(sp)
    8000354e:	e022                	sd	s0,0(sp)
    80003550:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003552:	ffffe097          	auipc	ra,0xffffe
    80003556:	60e080e7          	jalr	1550(ra) # 80001b60 <myproc>
}
    8000355a:	5908                	lw	a0,48(a0)
    8000355c:	60a2                	ld	ra,8(sp)
    8000355e:	6402                	ld	s0,0(sp)
    80003560:	0141                	addi	sp,sp,16
    80003562:	8082                	ret

0000000080003564 <sys_fork>:

uint64
sys_fork(void)
{
    80003564:	1141                	addi	sp,sp,-16
    80003566:	e406                	sd	ra,8(sp)
    80003568:	e022                	sd	s0,0(sp)
    8000356a:	0800                	addi	s0,sp,16
  return fork();
    8000356c:	fffff097          	auipc	ra,0xfffff
    80003570:	ae0080e7          	jalr	-1312(ra) # 8000204c <fork>
}
    80003574:	60a2                	ld	ra,8(sp)
    80003576:	6402                	ld	s0,0(sp)
    80003578:	0141                	addi	sp,sp,16
    8000357a:	8082                	ret

000000008000357c <sys_wait>:

uint64
sys_wait(void)
{
    8000357c:	1101                	addi	sp,sp,-32
    8000357e:	ec06                	sd	ra,24(sp)
    80003580:	e822                	sd	s0,16(sp)
    80003582:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003584:	fe840593          	addi	a1,s0,-24
    80003588:	4501                	li	a0,0
    8000358a:	00000097          	auipc	ra,0x0
    8000358e:	d84080e7          	jalr	-636(ra) # 8000330e <argaddr>
  return wait(p);
    80003592:	fe843503          	ld	a0,-24(s0)
    80003596:	fffff097          	auipc	ra,0xfffff
    8000359a:	3c4080e7          	jalr	964(ra) # 8000295a <wait>
}
    8000359e:	60e2                	ld	ra,24(sp)
    800035a0:	6442                	ld	s0,16(sp)
    800035a2:	6105                	addi	sp,sp,32
    800035a4:	8082                	ret

00000000800035a6 <sys_waitx>:

uint64
sys_waitx(void)
{
    800035a6:	7139                	addi	sp,sp,-64
    800035a8:	fc06                	sd	ra,56(sp)
    800035aa:	f822                	sd	s0,48(sp)
    800035ac:	f426                	sd	s1,40(sp)
    800035ae:	f04a                	sd	s2,32(sp)
    800035b0:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  
  argaddr(0, &addr);
    800035b2:	fd840593          	addi	a1,s0,-40
    800035b6:	4501                	li	a0,0
    800035b8:	00000097          	auipc	ra,0x0
    800035bc:	d56080e7          	jalr	-682(ra) # 8000330e <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800035c0:	fd040593          	addi	a1,s0,-48
    800035c4:	4505                	li	a0,1
    800035c6:	00000097          	auipc	ra,0x0
    800035ca:	d48080e7          	jalr	-696(ra) # 8000330e <argaddr>
  argaddr(2, &addr2);
    800035ce:	fc840593          	addi	a1,s0,-56
    800035d2:	4509                	li	a0,2
    800035d4:	00000097          	auipc	ra,0x0
    800035d8:	d3a080e7          	jalr	-710(ra) # 8000330e <argaddr>

  int ret = waitx(addr, &wtime, &rtime);
    800035dc:	fc040613          	addi	a2,s0,-64
    800035e0:	fc440593          	addi	a1,s0,-60
    800035e4:	fd843503          	ld	a0,-40(s0)
    800035e8:	fffff097          	auipc	ra,0xfffff
    800035ec:	f12080e7          	jalr	-238(ra) # 800024fa <waitx>
    800035f0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800035f2:	ffffe097          	auipc	ra,0xffffe
    800035f6:	56e080e7          	jalr	1390(ra) # 80001b60 <myproc>
    800035fa:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800035fc:	4691                	li	a3,4
    800035fe:	fc440613          	addi	a2,s0,-60
    80003602:	fd043583          	ld	a1,-48(s0)
    80003606:	6928                	ld	a0,80(a0)
    80003608:	ffffe097          	auipc	ra,0xffffe
    8000360c:	190080e7          	jalr	400(ra) # 80001798 <copyout>
    return -1;
    80003610:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003612:	00054f63          	bltz	a0,80003630 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003616:	4691                	li	a3,4
    80003618:	fc040613          	addi	a2,s0,-64
    8000361c:	fc843583          	ld	a1,-56(s0)
    80003620:	68a8                	ld	a0,80(s1)
    80003622:	ffffe097          	auipc	ra,0xffffe
    80003626:	176080e7          	jalr	374(ra) # 80001798 <copyout>
    8000362a:	00054a63          	bltz	a0,8000363e <sys_waitx+0x98>
    return -1;
  return ret;
    8000362e:	87ca                	mv	a5,s2
}
    80003630:	853e                	mv	a0,a5
    80003632:	70e2                	ld	ra,56(sp)
    80003634:	7442                	ld	s0,48(sp)
    80003636:	74a2                	ld	s1,40(sp)
    80003638:	7902                	ld	s2,32(sp)
    8000363a:	6121                	addi	sp,sp,64
    8000363c:	8082                	ret
    return -1;
    8000363e:	57fd                	li	a5,-1
    80003640:	bfc5                	j	80003630 <sys_waitx+0x8a>

0000000080003642 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003642:	7179                	addi	sp,sp,-48
    80003644:	f406                	sd	ra,40(sp)
    80003646:	f022                	sd	s0,32(sp)
    80003648:	ec26                	sd	s1,24(sp)
    8000364a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000364c:	fdc40593          	addi	a1,s0,-36
    80003650:	4501                	li	a0,0
    80003652:	00000097          	auipc	ra,0x0
    80003656:	c9c080e7          	jalr	-868(ra) # 800032ee <argint>
  addr = myproc()->sz;
    8000365a:	ffffe097          	auipc	ra,0xffffe
    8000365e:	506080e7          	jalr	1286(ra) # 80001b60 <myproc>
    80003662:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80003664:	fdc42503          	lw	a0,-36(s0)
    80003668:	fffff097          	auipc	ra,0xfffff
    8000366c:	988080e7          	jalr	-1656(ra) # 80001ff0 <growproc>
    80003670:	00054863          	bltz	a0,80003680 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003674:	8526                	mv	a0,s1
    80003676:	70a2                	ld	ra,40(sp)
    80003678:	7402                	ld	s0,32(sp)
    8000367a:	64e2                	ld	s1,24(sp)
    8000367c:	6145                	addi	sp,sp,48
    8000367e:	8082                	ret
    return -1;
    80003680:	54fd                	li	s1,-1
    80003682:	bfcd                	j	80003674 <sys_sbrk+0x32>

0000000080003684 <sys_trace>:

uint64
sys_trace(void) // JUST FOR CALLING SOME SYSTEM CALL IN PROC.C 
{
    80003684:	1101                	addi	sp,sp,-32
    80003686:	ec06                	sd	ra,24(sp)
    80003688:	e822                	sd	s0,16(sp)
    8000368a:	1000                	addi	s0,sp,32
  // The functions in sysproc.c can access the process structure of a given process by calling myproc()
  int mask;
  argint(0, &mask);
    8000368c:	fec40593          	addi	a1,s0,-20
    80003690:	4501                	li	a0,0
    80003692:	00000097          	auipc	ra,0x0
    80003696:	c5c080e7          	jalr	-932(ra) # 800032ee <argint>
  myproc()->mask=mask;
    8000369a:	ffffe097          	auipc	ra,0xffffe
    8000369e:	4c6080e7          	jalr	1222(ra) # 80001b60 <myproc>
    800036a2:	fec42783          	lw	a5,-20(s0)
    800036a6:	16f52423          	sw	a5,360(a0)
  return 1; // during process initialisation only , we updated value of mask
}
    800036aa:	4505                	li	a0,1
    800036ac:	60e2                	ld	ra,24(sp)
    800036ae:	6442                	ld	s0,16(sp)
    800036b0:	6105                	addi	sp,sp,32
    800036b2:	8082                	ret

00000000800036b4 <sys_sigalarm>:

uint64
sys_sigalarm(void) // JUST FOR CALLING SOME SYSTEM CALL IN PROC.C 
{
    800036b4:	1101                	addi	sp,sp,-32
    800036b6:	ec06                	sd	ra,24(sp)
    800036b8:	e822                	sd	s0,16(sp)
    800036ba:	1000                	addi	s0,sp,32
  // The functions in sysproc.c can access the process structure of a given process by calling myproc()
  int n;
  uint64 handler;

  argint(0,&n);
    800036bc:	fec40593          	addi	a1,s0,-20
    800036c0:	4501                	li	a0,0
    800036c2:	00000097          	auipc	ra,0x0
    800036c6:	c2c080e7          	jalr	-980(ra) # 800032ee <argint>
  argaddr(1,&handler);
    800036ca:	fe040593          	addi	a1,s0,-32
    800036ce:	4505                	li	a0,1
    800036d0:	00000097          	auipc	ra,0x0
    800036d4:	c3e080e7          	jalr	-962(ra) # 8000330e <argaddr>

  myproc()->is_sigalarm=0;
    800036d8:	ffffe097          	auipc	ra,0xffffe
    800036dc:	488080e7          	jalr	1160(ra) # 80001b60 <myproc>
    800036e0:	1a052623          	sw	zero,428(a0)
  myproc()->tslalarm=0;
    800036e4:	ffffe097          	auipc	ra,0xffffe
    800036e8:	47c080e7          	jalr	1148(ra) # 80001b60 <myproc>
    800036ec:	1c052023          	sw	zero,448(a0)
  myproc()->alarmint=n;
    800036f0:	ffffe097          	auipc	ra,0xffffe
    800036f4:	470080e7          	jalr	1136(ra) # 80001b60 <myproc>
    800036f8:	fec42783          	lw	a5,-20(s0)
    800036fc:	1af52823          	sw	a5,432(a0)
  myproc()->alarmhandler=handler;
    80003700:	ffffe097          	auipc	ra,0xffffe
    80003704:	460080e7          	jalr	1120(ra) # 80001b60 <myproc>
    80003708:	fe043783          	ld	a5,-32(s0)
    8000370c:	1af53c23          	sd	a5,440(a0)

  // just alert the user every n ticks 
  return 1; // during process initialisation only , we updated value of mask
}
    80003710:	4505                	li	a0,1
    80003712:	60e2                	ld	ra,24(sp)
    80003714:	6442                	ld	s0,16(sp)
    80003716:	6105                	addi	sp,sp,32
    80003718:	8082                	ret

000000008000371a <sys_settickets>:

uint64
sys_settickets(void) // JUST FOR CALLING SOME SYSTEM CALL IN PROC.C 
{
    8000371a:	1101                	addi	sp,sp,-32
    8000371c:	ec06                	sd	ra,24(sp)
    8000371e:	e822                	sd	s0,16(sp)
    80003720:	1000                	addi	s0,sp,32
  // The functions in sysproc.c can access the process structure of a given process by calling myproc()
  int tickets;
  argint(0,&tickets);
    80003722:	fec40593          	addi	a1,s0,-20
    80003726:	4501                	li	a0,0
    80003728:	00000097          	auipc	ra,0x0
    8000372c:	bc6080e7          	jalr	-1082(ra) # 800032ee <argint>

  myproc()->tickets=tickets;
    80003730:	ffffe097          	auipc	ra,0xffffe
    80003734:	430080e7          	jalr	1072(ra) # 80001b60 <myproc>
    80003738:	fec42783          	lw	a5,-20(s0)
    8000373c:	16f52823          	sw	a5,368(a0)

  return 1; 
}
    80003740:	4505                	li	a0,1
    80003742:	60e2                	ld	ra,24(sp)
    80003744:	6442                	ld	s0,16(sp)
    80003746:	6105                	addi	sp,sp,32
    80003748:	8082                	ret

000000008000374a <sys_set_priority>:

uint64
sys_set_priority(void)
{
    8000374a:	1101                	addi	sp,sp,-32
    8000374c:	ec06                	sd	ra,24(sp)
    8000374e:	e822                	sd	s0,16(sp)
    80003750:	1000                	addi	s0,sp,32
  int np, pid, ret = 0;
  struct proc *p;
  extern struct proc proc[];

  argint(0, &np);
    80003752:	fec40593          	addi	a1,s0,-20
    80003756:	4501                	li	a0,0
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	b96080e7          	jalr	-1130(ra) # 800032ee <argint>
  argint(1, &pid);
    80003760:	fe840593          	addi	a1,s0,-24
    80003764:	4505                	li	a0,1
    80003766:	00000097          	auipc	ra,0x0
    8000376a:	b88080e7          	jalr	-1144(ra) # 800032ee <argint>

  for (p = proc; p < &proc[NPROC]; p++)
  {
    if (p->pid == pid)
    8000376e:	fe842603          	lw	a2,-24(s0)
      int olddp= max(0,min(p->stpriority-p->niceness+5,100)); // old priority

      ret = p->stpriority; // storing old static priority

      p->niceness = 5; // updating niceness
      p->stpriority = np; // updating static priority
    80003772:	fec42303          	lw	t1,-20(s0)
    80003776:	ffb3089b          	addiw	a7,t1,-5
  for (p = proc; p < &proc[NPROC]; p++)
    8000377a:	0022e797          	auipc	a5,0x22e
    8000377e:	f8678793          	addi	a5,a5,-122 # 80231700 <proc>
  int np, pid, ret = 0;
    80003782:	4501                	li	a0,0
      int olddp= max(0,min(p->stpriority-p->niceness+5,100)); // old priority
    80003784:	586d                	li	a6,-5
      p->niceness = 5; // updating niceness
    80003786:	4e95                	li	t4,5
      int olddp= max(0,min(p->stpriority-p->niceness+5,100)); // old priority
    80003788:	4f01                	li	t5,0

      int newdp= max(0,min(p->stpriority-p->niceness+5,100)); // new priority
    8000378a:	82c6                	mv	t0,a7
    8000378c:	8fc6                	mv	t6,a7
    8000378e:	05f00e13          	li	t3,95
    80003792:	05f00393          	li	t2,95
  for (p = proc; p < &proc[NPROC]; p++)
    80003796:	00235697          	auipc	a3,0x235
    8000379a:	56a68693          	addi	a3,a3,1386 # 80238d00 <tickslock>
    8000379e:	a811                	j	800037b2 <sys_set_priority+0x68>
      int newdp= max(0,min(p->stpriority-p->niceness+5,100)); // new priority
    800037a0:	2715                	addiw	a4,a4,5

      if(newdp<olddp) // if priority increases i.e dp value decreases , then reschedule
    800037a2:	00b75463          	bge	a4,a1,800037aa <sys_set_priority+0x60>
        p->numpicked = 0;
    800037a6:	1807a223          	sw	zero,388(a5)
  for (p = proc; p < &proc[NPROC]; p++)
    800037aa:	1d878793          	addi	a5,a5,472
    800037ae:	04d78963          	beq	a5,a3,80003800 <sys_set_priority+0xb6>
    if (p->pid == pid)
    800037b2:	5b98                	lw	a4,48(a5)
    800037b4:	fec71be3          	bne	a4,a2,800037aa <sys_set_priority+0x60>
      int olddp= max(0,min(p->stpriority-p->niceness+5,100)); // old priority
    800037b8:	1807a503          	lw	a0,384(a5)
    800037bc:	17c7a703          	lw	a4,380(a5)
    800037c0:	40e5073b          	subw	a4,a0,a4
    800037c4:	0007059b          	sext.w	a1,a4
    800037c8:	0305c463          	blt	a1,a6,800037f0 <sys_set_priority+0xa6>
    800037cc:	85ba                	mv	a1,a4
    800037ce:	2701                	sext.w	a4,a4
    800037d0:	00ee5363          	bge	t3,a4,800037d6 <sys_set_priority+0x8c>
    800037d4:	859e                	mv	a1,t2
    800037d6:	2595                	addiw	a1,a1,5 # 1005 <_entry-0x7fffeffb>
      p->niceness = 5; // updating niceness
    800037d8:	17d7ae23          	sw	t4,380(a5)
      p->stpriority = np; // updating static priority
    800037dc:	1867a023          	sw	t1,384(a5)
      int newdp= max(0,min(p->stpriority-p->niceness+5,100)); // new priority
    800037e0:	877a                	mv	a4,t5
    800037e2:	fd08c0e3          	blt	a7,a6,800037a2 <sys_set_priority+0x58>
    800037e6:	8716                	mv	a4,t0
    800037e8:	fbfe5ce3          	bge	t3,t6,800037a0 <sys_set_priority+0x56>
    800037ec:	871e                	mv	a4,t2
    800037ee:	bf4d                	j	800037a0 <sys_set_priority+0x56>
      p->niceness = 5; // updating niceness
    800037f0:	17d7ae23          	sw	t4,380(a5)
      p->stpriority = np; // updating static priority
    800037f4:	1867a023          	sw	t1,384(a5)
      int newdp= max(0,min(p->stpriority-p->niceness+5,100)); // new priority
    800037f8:	fb08c9e3          	blt	a7,a6,800037aa <sys_set_priority+0x60>
      int olddp= max(0,min(p->stpriority-p->niceness+5,100)); // old priority
    800037fc:	85fa                	mv	a1,t5
    800037fe:	b7e5                	j	800037e6 <sys_set_priority+0x9c>
    }
  }

  return ret;
}
    80003800:	60e2                	ld	ra,24(sp)
    80003802:	6442                	ld	s0,16(sp)
    80003804:	6105                	addi	sp,sp,32
    80003806:	8082                	ret

0000000080003808 <sys_sigreturn>:

uint64 sys_sigreturn(void){
    80003808:	1141                	addi	sp,sp,-16
    8000380a:	e406                	sd	ra,8(sp)
    8000380c:	e022                	sd	s0,0(sp)
    8000380e:	0800                	addi	s0,sp,16
  struct proc* p=myproc();
    80003810:	ffffe097          	auipc	ra,0xffffe
    80003814:	350080e7          	jalr	848(ra) # 80001b60 <myproc>

  // Restoring kernel stack for trapframe
  p->tf_copy->kernel_satp=p->trapframe->kernel_satp;
    80003818:	1c853783          	ld	a5,456(a0)
    8000381c:	6d38                	ld	a4,88(a0)
    8000381e:	6318                	ld	a4,0(a4)
    80003820:	e398                	sd	a4,0(a5)
  p->tf_copy->kernel_sp=p->trapframe->kernel_sp;
    80003822:	1c853783          	ld	a5,456(a0)
    80003826:	6d38                	ld	a4,88(a0)
    80003828:	6718                	ld	a4,8(a4)
    8000382a:	e798                	sd	a4,8(a5)
  p->tf_copy->kernel_trap=p->trapframe->kernel_trap;
    8000382c:	1c853783          	ld	a5,456(a0)
    80003830:	6d38                	ld	a4,88(a0)
    80003832:	6b18                	ld	a4,16(a4)
    80003834:	eb98                	sd	a4,16(a5)
  p->tf_copy->kernel_hartid=p->trapframe->kernel_hartid;
    80003836:	1c853783          	ld	a5,456(a0)
    8000383a:	6d38                	ld	a4,88(a0)
    8000383c:	7318                	ld	a4,32(a4)
    8000383e:	f398                	sd	a4,32(a5)

  // restoring previous things of trapframe
  *(p->trapframe)=*(p->tf_copy); 
    80003840:	1c853683          	ld	a3,456(a0)
    80003844:	87b6                	mv	a5,a3
    80003846:	6d38                	ld	a4,88(a0)
    80003848:	12068693          	addi	a3,a3,288
    8000384c:	0007b883          	ld	a7,0(a5)
    80003850:	0087b803          	ld	a6,8(a5)
    80003854:	6b8c                	ld	a1,16(a5)
    80003856:	6f90                	ld	a2,24(a5)
    80003858:	01173023          	sd	a7,0(a4)
    8000385c:	01073423          	sd	a6,8(a4)
    80003860:	eb0c                	sd	a1,16(a4)
    80003862:	ef10                	sd	a2,24(a4)
    80003864:	02078793          	addi	a5,a5,32
    80003868:	02070713          	addi	a4,a4,32
    8000386c:	fed790e3          	bne	a5,a3,8000384c <sys_sigreturn+0x44>
  p->is_sigalarm=0; // disabling alarm
    80003870:	1a052623          	sw	zero,428(a0)
  return myproc()->trapframe->a0;
    80003874:	ffffe097          	auipc	ra,0xffffe
    80003878:	2ec080e7          	jalr	748(ra) # 80001b60 <myproc>
    8000387c:	6d3c                	ld	a5,88(a0)
}
    8000387e:	7ba8                	ld	a0,112(a5)
    80003880:	60a2                	ld	ra,8(sp)
    80003882:	6402                	ld	s0,0(sp)
    80003884:	0141                	addi	sp,sp,16
    80003886:	8082                	ret

0000000080003888 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003888:	7139                	addi	sp,sp,-64
    8000388a:	fc06                	sd	ra,56(sp)
    8000388c:	f822                	sd	s0,48(sp)
    8000388e:	f426                	sd	s1,40(sp)
    80003890:	f04a                	sd	s2,32(sp)
    80003892:	ec4e                	sd	s3,24(sp)
    80003894:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003896:	fcc40593          	addi	a1,s0,-52
    8000389a:	4501                	li	a0,0
    8000389c:	00000097          	auipc	ra,0x0
    800038a0:	a52080e7          	jalr	-1454(ra) # 800032ee <argint>
  acquire(&tickslock);
    800038a4:	00235517          	auipc	a0,0x235
    800038a8:	45c50513          	addi	a0,a0,1116 # 80238d00 <tickslock>
    800038ac:	ffffd097          	auipc	ra,0xffffd
    800038b0:	46a080e7          	jalr	1130(ra) # 80000d16 <acquire>
  ticks0 = ticks;
    800038b4:	00005917          	auipc	s2,0x5
    800038b8:	35c92903          	lw	s2,860(s2) # 80008c10 <ticks>
  while(ticks - ticks0 < n){
    800038bc:	fcc42783          	lw	a5,-52(s0)
    800038c0:	cf9d                	beqz	a5,800038fe <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800038c2:	00235997          	auipc	s3,0x235
    800038c6:	43e98993          	addi	s3,s3,1086 # 80238d00 <tickslock>
    800038ca:	00005497          	auipc	s1,0x5
    800038ce:	34648493          	addi	s1,s1,838 # 80008c10 <ticks>
    if(killed(myproc())){
    800038d2:	ffffe097          	auipc	ra,0xffffe
    800038d6:	28e080e7          	jalr	654(ra) # 80001b60 <myproc>
    800038da:	fffff097          	auipc	ra,0xfffff
    800038de:	04e080e7          	jalr	78(ra) # 80002928 <killed>
    800038e2:	ed15                	bnez	a0,8000391e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800038e4:	85ce                	mv	a1,s3
    800038e6:	8526                	mv	a0,s1
    800038e8:	fffff097          	auipc	ra,0xfffff
    800038ec:	bae080e7          	jalr	-1106(ra) # 80002496 <sleep>
  while(ticks - ticks0 < n){
    800038f0:	409c                	lw	a5,0(s1)
    800038f2:	412787bb          	subw	a5,a5,s2
    800038f6:	fcc42703          	lw	a4,-52(s0)
    800038fa:	fce7ece3          	bltu	a5,a4,800038d2 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800038fe:	00235517          	auipc	a0,0x235
    80003902:	40250513          	addi	a0,a0,1026 # 80238d00 <tickslock>
    80003906:	ffffd097          	auipc	ra,0xffffd
    8000390a:	4c4080e7          	jalr	1220(ra) # 80000dca <release>
  return 0;
    8000390e:	4501                	li	a0,0
}
    80003910:	70e2                	ld	ra,56(sp)
    80003912:	7442                	ld	s0,48(sp)
    80003914:	74a2                	ld	s1,40(sp)
    80003916:	7902                	ld	s2,32(sp)
    80003918:	69e2                	ld	s3,24(sp)
    8000391a:	6121                	addi	sp,sp,64
    8000391c:	8082                	ret
      release(&tickslock);
    8000391e:	00235517          	auipc	a0,0x235
    80003922:	3e250513          	addi	a0,a0,994 # 80238d00 <tickslock>
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	4a4080e7          	jalr	1188(ra) # 80000dca <release>
      return -1;
    8000392e:	557d                	li	a0,-1
    80003930:	b7c5                	j	80003910 <sys_sleep+0x88>

0000000080003932 <sys_kill>:

uint64
sys_kill(void)
{
    80003932:	1101                	addi	sp,sp,-32
    80003934:	ec06                	sd	ra,24(sp)
    80003936:	e822                	sd	s0,16(sp)
    80003938:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000393a:	fec40593          	addi	a1,s0,-20
    8000393e:	4501                	li	a0,0
    80003940:	00000097          	auipc	ra,0x0
    80003944:	9ae080e7          	jalr	-1618(ra) # 800032ee <argint>
  return kill(pid);
    80003948:	fec42503          	lw	a0,-20(s0)
    8000394c:	fffff097          	auipc	ra,0xfffff
    80003950:	f3e080e7          	jalr	-194(ra) # 8000288a <kill>
}
    80003954:	60e2                	ld	ra,24(sp)
    80003956:	6442                	ld	s0,16(sp)
    80003958:	6105                	addi	sp,sp,32
    8000395a:	8082                	ret

000000008000395c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000395c:	1101                	addi	sp,sp,-32
    8000395e:	ec06                	sd	ra,24(sp)
    80003960:	e822                	sd	s0,16(sp)
    80003962:	e426                	sd	s1,8(sp)
    80003964:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003966:	00235517          	auipc	a0,0x235
    8000396a:	39a50513          	addi	a0,a0,922 # 80238d00 <tickslock>
    8000396e:	ffffd097          	auipc	ra,0xffffd
    80003972:	3a8080e7          	jalr	936(ra) # 80000d16 <acquire>
  xticks = ticks;
    80003976:	00005497          	auipc	s1,0x5
    8000397a:	29a4a483          	lw	s1,666(s1) # 80008c10 <ticks>
  release(&tickslock);
    8000397e:	00235517          	auipc	a0,0x235
    80003982:	38250513          	addi	a0,a0,898 # 80238d00 <tickslock>
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	444080e7          	jalr	1092(ra) # 80000dca <release>
  return xticks;
}
    8000398e:	02049513          	slli	a0,s1,0x20
    80003992:	9101                	srli	a0,a0,0x20
    80003994:	60e2                	ld	ra,24(sp)
    80003996:	6442                	ld	s0,16(sp)
    80003998:	64a2                	ld	s1,8(sp)
    8000399a:	6105                	addi	sp,sp,32
    8000399c:	8082                	ret

000000008000399e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000399e:	7179                	addi	sp,sp,-48
    800039a0:	f406                	sd	ra,40(sp)
    800039a2:	f022                	sd	s0,32(sp)
    800039a4:	ec26                	sd	s1,24(sp)
    800039a6:	e84a                	sd	s2,16(sp)
    800039a8:	e44e                	sd	s3,8(sp)
    800039aa:	e052                	sd	s4,0(sp)
    800039ac:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800039ae:	00005597          	auipc	a1,0x5
    800039b2:	e1a58593          	addi	a1,a1,-486 # 800087c8 <syscallnames+0xe8>
    800039b6:	00235517          	auipc	a0,0x235
    800039ba:	36250513          	addi	a0,a0,866 # 80238d18 <bcache>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	2c8080e7          	jalr	712(ra) # 80000c86 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800039c6:	0023d797          	auipc	a5,0x23d
    800039ca:	35278793          	addi	a5,a5,850 # 80240d18 <bcache+0x8000>
    800039ce:	0023d717          	auipc	a4,0x23d
    800039d2:	5b270713          	addi	a4,a4,1458 # 80240f80 <bcache+0x8268>
    800039d6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800039da:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800039de:	00235497          	auipc	s1,0x235
    800039e2:	35248493          	addi	s1,s1,850 # 80238d30 <bcache+0x18>
    b->next = bcache.head.next;
    800039e6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800039e8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800039ea:	00005a17          	auipc	s4,0x5
    800039ee:	de6a0a13          	addi	s4,s4,-538 # 800087d0 <syscallnames+0xf0>
    b->next = bcache.head.next;
    800039f2:	2b893783          	ld	a5,696(s2)
    800039f6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800039f8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800039fc:	85d2                	mv	a1,s4
    800039fe:	01048513          	addi	a0,s1,16
    80003a02:	00001097          	auipc	ra,0x1
    80003a06:	4c8080e7          	jalr	1224(ra) # 80004eca <initsleeplock>
    bcache.head.next->prev = b;
    80003a0a:	2b893783          	ld	a5,696(s2)
    80003a0e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003a10:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003a14:	45848493          	addi	s1,s1,1112
    80003a18:	fd349de3          	bne	s1,s3,800039f2 <binit+0x54>
  }
}
    80003a1c:	70a2                	ld	ra,40(sp)
    80003a1e:	7402                	ld	s0,32(sp)
    80003a20:	64e2                	ld	s1,24(sp)
    80003a22:	6942                	ld	s2,16(sp)
    80003a24:	69a2                	ld	s3,8(sp)
    80003a26:	6a02                	ld	s4,0(sp)
    80003a28:	6145                	addi	sp,sp,48
    80003a2a:	8082                	ret

0000000080003a2c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003a2c:	7179                	addi	sp,sp,-48
    80003a2e:	f406                	sd	ra,40(sp)
    80003a30:	f022                	sd	s0,32(sp)
    80003a32:	ec26                	sd	s1,24(sp)
    80003a34:	e84a                	sd	s2,16(sp)
    80003a36:	e44e                	sd	s3,8(sp)
    80003a38:	1800                	addi	s0,sp,48
    80003a3a:	892a                	mv	s2,a0
    80003a3c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003a3e:	00235517          	auipc	a0,0x235
    80003a42:	2da50513          	addi	a0,a0,730 # 80238d18 <bcache>
    80003a46:	ffffd097          	auipc	ra,0xffffd
    80003a4a:	2d0080e7          	jalr	720(ra) # 80000d16 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003a4e:	0023d497          	auipc	s1,0x23d
    80003a52:	5824b483          	ld	s1,1410(s1) # 80240fd0 <bcache+0x82b8>
    80003a56:	0023d797          	auipc	a5,0x23d
    80003a5a:	52a78793          	addi	a5,a5,1322 # 80240f80 <bcache+0x8268>
    80003a5e:	02f48f63          	beq	s1,a5,80003a9c <bread+0x70>
    80003a62:	873e                	mv	a4,a5
    80003a64:	a021                	j	80003a6c <bread+0x40>
    80003a66:	68a4                	ld	s1,80(s1)
    80003a68:	02e48a63          	beq	s1,a4,80003a9c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003a6c:	449c                	lw	a5,8(s1)
    80003a6e:	ff279ce3          	bne	a5,s2,80003a66 <bread+0x3a>
    80003a72:	44dc                	lw	a5,12(s1)
    80003a74:	ff3799e3          	bne	a5,s3,80003a66 <bread+0x3a>
      b->refcnt++;
    80003a78:	40bc                	lw	a5,64(s1)
    80003a7a:	2785                	addiw	a5,a5,1
    80003a7c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a7e:	00235517          	auipc	a0,0x235
    80003a82:	29a50513          	addi	a0,a0,666 # 80238d18 <bcache>
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	344080e7          	jalr	836(ra) # 80000dca <release>
      acquiresleep(&b->lock);
    80003a8e:	01048513          	addi	a0,s1,16
    80003a92:	00001097          	auipc	ra,0x1
    80003a96:	472080e7          	jalr	1138(ra) # 80004f04 <acquiresleep>
      return b;
    80003a9a:	a8b9                	j	80003af8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a9c:	0023d497          	auipc	s1,0x23d
    80003aa0:	52c4b483          	ld	s1,1324(s1) # 80240fc8 <bcache+0x82b0>
    80003aa4:	0023d797          	auipc	a5,0x23d
    80003aa8:	4dc78793          	addi	a5,a5,1244 # 80240f80 <bcache+0x8268>
    80003aac:	00f48863          	beq	s1,a5,80003abc <bread+0x90>
    80003ab0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003ab2:	40bc                	lw	a5,64(s1)
    80003ab4:	cf81                	beqz	a5,80003acc <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003ab6:	64a4                	ld	s1,72(s1)
    80003ab8:	fee49de3          	bne	s1,a4,80003ab2 <bread+0x86>
  panic("bget: no buffers");
    80003abc:	00005517          	auipc	a0,0x5
    80003ac0:	d1c50513          	addi	a0,a0,-740 # 800087d8 <syscallnames+0xf8>
    80003ac4:	ffffd097          	auipc	ra,0xffffd
    80003ac8:	a7c080e7          	jalr	-1412(ra) # 80000540 <panic>
      b->dev = dev;
    80003acc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003ad0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003ad4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003ad8:	4785                	li	a5,1
    80003ada:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003adc:	00235517          	auipc	a0,0x235
    80003ae0:	23c50513          	addi	a0,a0,572 # 80238d18 <bcache>
    80003ae4:	ffffd097          	auipc	ra,0xffffd
    80003ae8:	2e6080e7          	jalr	742(ra) # 80000dca <release>
      acquiresleep(&b->lock);
    80003aec:	01048513          	addi	a0,s1,16
    80003af0:	00001097          	auipc	ra,0x1
    80003af4:	414080e7          	jalr	1044(ra) # 80004f04 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003af8:	409c                	lw	a5,0(s1)
    80003afa:	cb89                	beqz	a5,80003b0c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003afc:	8526                	mv	a0,s1
    80003afe:	70a2                	ld	ra,40(sp)
    80003b00:	7402                	ld	s0,32(sp)
    80003b02:	64e2                	ld	s1,24(sp)
    80003b04:	6942                	ld	s2,16(sp)
    80003b06:	69a2                	ld	s3,8(sp)
    80003b08:	6145                	addi	sp,sp,48
    80003b0a:	8082                	ret
    virtio_disk_rw(b, 0);
    80003b0c:	4581                	li	a1,0
    80003b0e:	8526                	mv	a0,s1
    80003b10:	00003097          	auipc	ra,0x3
    80003b14:	002080e7          	jalr	2(ra) # 80006b12 <virtio_disk_rw>
    b->valid = 1;
    80003b18:	4785                	li	a5,1
    80003b1a:	c09c                	sw	a5,0(s1)
  return b;
    80003b1c:	b7c5                	j	80003afc <bread+0xd0>

0000000080003b1e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003b1e:	1101                	addi	sp,sp,-32
    80003b20:	ec06                	sd	ra,24(sp)
    80003b22:	e822                	sd	s0,16(sp)
    80003b24:	e426                	sd	s1,8(sp)
    80003b26:	1000                	addi	s0,sp,32
    80003b28:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003b2a:	0541                	addi	a0,a0,16
    80003b2c:	00001097          	auipc	ra,0x1
    80003b30:	472080e7          	jalr	1138(ra) # 80004f9e <holdingsleep>
    80003b34:	cd01                	beqz	a0,80003b4c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003b36:	4585                	li	a1,1
    80003b38:	8526                	mv	a0,s1
    80003b3a:	00003097          	auipc	ra,0x3
    80003b3e:	fd8080e7          	jalr	-40(ra) # 80006b12 <virtio_disk_rw>
}
    80003b42:	60e2                	ld	ra,24(sp)
    80003b44:	6442                	ld	s0,16(sp)
    80003b46:	64a2                	ld	s1,8(sp)
    80003b48:	6105                	addi	sp,sp,32
    80003b4a:	8082                	ret
    panic("bwrite");
    80003b4c:	00005517          	auipc	a0,0x5
    80003b50:	ca450513          	addi	a0,a0,-860 # 800087f0 <syscallnames+0x110>
    80003b54:	ffffd097          	auipc	ra,0xffffd
    80003b58:	9ec080e7          	jalr	-1556(ra) # 80000540 <panic>

0000000080003b5c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003b5c:	1101                	addi	sp,sp,-32
    80003b5e:	ec06                	sd	ra,24(sp)
    80003b60:	e822                	sd	s0,16(sp)
    80003b62:	e426                	sd	s1,8(sp)
    80003b64:	e04a                	sd	s2,0(sp)
    80003b66:	1000                	addi	s0,sp,32
    80003b68:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003b6a:	01050913          	addi	s2,a0,16
    80003b6e:	854a                	mv	a0,s2
    80003b70:	00001097          	auipc	ra,0x1
    80003b74:	42e080e7          	jalr	1070(ra) # 80004f9e <holdingsleep>
    80003b78:	c92d                	beqz	a0,80003bea <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003b7a:	854a                	mv	a0,s2
    80003b7c:	00001097          	auipc	ra,0x1
    80003b80:	3de080e7          	jalr	990(ra) # 80004f5a <releasesleep>

  acquire(&bcache.lock);
    80003b84:	00235517          	auipc	a0,0x235
    80003b88:	19450513          	addi	a0,a0,404 # 80238d18 <bcache>
    80003b8c:	ffffd097          	auipc	ra,0xffffd
    80003b90:	18a080e7          	jalr	394(ra) # 80000d16 <acquire>
  b->refcnt--;
    80003b94:	40bc                	lw	a5,64(s1)
    80003b96:	37fd                	addiw	a5,a5,-1
    80003b98:	0007871b          	sext.w	a4,a5
    80003b9c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003b9e:	eb05                	bnez	a4,80003bce <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003ba0:	68bc                	ld	a5,80(s1)
    80003ba2:	64b8                	ld	a4,72(s1)
    80003ba4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003ba6:	64bc                	ld	a5,72(s1)
    80003ba8:	68b8                	ld	a4,80(s1)
    80003baa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003bac:	0023d797          	auipc	a5,0x23d
    80003bb0:	16c78793          	addi	a5,a5,364 # 80240d18 <bcache+0x8000>
    80003bb4:	2b87b703          	ld	a4,696(a5)
    80003bb8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003bba:	0023d717          	auipc	a4,0x23d
    80003bbe:	3c670713          	addi	a4,a4,966 # 80240f80 <bcache+0x8268>
    80003bc2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003bc4:	2b87b703          	ld	a4,696(a5)
    80003bc8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003bca:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003bce:	00235517          	auipc	a0,0x235
    80003bd2:	14a50513          	addi	a0,a0,330 # 80238d18 <bcache>
    80003bd6:	ffffd097          	auipc	ra,0xffffd
    80003bda:	1f4080e7          	jalr	500(ra) # 80000dca <release>
}
    80003bde:	60e2                	ld	ra,24(sp)
    80003be0:	6442                	ld	s0,16(sp)
    80003be2:	64a2                	ld	s1,8(sp)
    80003be4:	6902                	ld	s2,0(sp)
    80003be6:	6105                	addi	sp,sp,32
    80003be8:	8082                	ret
    panic("brelse");
    80003bea:	00005517          	auipc	a0,0x5
    80003bee:	c0e50513          	addi	a0,a0,-1010 # 800087f8 <syscallnames+0x118>
    80003bf2:	ffffd097          	auipc	ra,0xffffd
    80003bf6:	94e080e7          	jalr	-1714(ra) # 80000540 <panic>

0000000080003bfa <bpin>:

void
bpin(struct buf *b) {
    80003bfa:	1101                	addi	sp,sp,-32
    80003bfc:	ec06                	sd	ra,24(sp)
    80003bfe:	e822                	sd	s0,16(sp)
    80003c00:	e426                	sd	s1,8(sp)
    80003c02:	1000                	addi	s0,sp,32
    80003c04:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003c06:	00235517          	auipc	a0,0x235
    80003c0a:	11250513          	addi	a0,a0,274 # 80238d18 <bcache>
    80003c0e:	ffffd097          	auipc	ra,0xffffd
    80003c12:	108080e7          	jalr	264(ra) # 80000d16 <acquire>
  b->refcnt++;
    80003c16:	40bc                	lw	a5,64(s1)
    80003c18:	2785                	addiw	a5,a5,1
    80003c1a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003c1c:	00235517          	auipc	a0,0x235
    80003c20:	0fc50513          	addi	a0,a0,252 # 80238d18 <bcache>
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	1a6080e7          	jalr	422(ra) # 80000dca <release>
}
    80003c2c:	60e2                	ld	ra,24(sp)
    80003c2e:	6442                	ld	s0,16(sp)
    80003c30:	64a2                	ld	s1,8(sp)
    80003c32:	6105                	addi	sp,sp,32
    80003c34:	8082                	ret

0000000080003c36 <bunpin>:

void
bunpin(struct buf *b) {
    80003c36:	1101                	addi	sp,sp,-32
    80003c38:	ec06                	sd	ra,24(sp)
    80003c3a:	e822                	sd	s0,16(sp)
    80003c3c:	e426                	sd	s1,8(sp)
    80003c3e:	1000                	addi	s0,sp,32
    80003c40:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003c42:	00235517          	auipc	a0,0x235
    80003c46:	0d650513          	addi	a0,a0,214 # 80238d18 <bcache>
    80003c4a:	ffffd097          	auipc	ra,0xffffd
    80003c4e:	0cc080e7          	jalr	204(ra) # 80000d16 <acquire>
  b->refcnt--;
    80003c52:	40bc                	lw	a5,64(s1)
    80003c54:	37fd                	addiw	a5,a5,-1
    80003c56:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003c58:	00235517          	auipc	a0,0x235
    80003c5c:	0c050513          	addi	a0,a0,192 # 80238d18 <bcache>
    80003c60:	ffffd097          	auipc	ra,0xffffd
    80003c64:	16a080e7          	jalr	362(ra) # 80000dca <release>
}
    80003c68:	60e2                	ld	ra,24(sp)
    80003c6a:	6442                	ld	s0,16(sp)
    80003c6c:	64a2                	ld	s1,8(sp)
    80003c6e:	6105                	addi	sp,sp,32
    80003c70:	8082                	ret

0000000080003c72 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003c72:	1101                	addi	sp,sp,-32
    80003c74:	ec06                	sd	ra,24(sp)
    80003c76:	e822                	sd	s0,16(sp)
    80003c78:	e426                	sd	s1,8(sp)
    80003c7a:	e04a                	sd	s2,0(sp)
    80003c7c:	1000                	addi	s0,sp,32
    80003c7e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003c80:	00d5d59b          	srliw	a1,a1,0xd
    80003c84:	0023d797          	auipc	a5,0x23d
    80003c88:	7707a783          	lw	a5,1904(a5) # 802413f4 <sb+0x1c>
    80003c8c:	9dbd                	addw	a1,a1,a5
    80003c8e:	00000097          	auipc	ra,0x0
    80003c92:	d9e080e7          	jalr	-610(ra) # 80003a2c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003c96:	0074f713          	andi	a4,s1,7
    80003c9a:	4785                	li	a5,1
    80003c9c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003ca0:	14ce                	slli	s1,s1,0x33
    80003ca2:	90d9                	srli	s1,s1,0x36
    80003ca4:	00950733          	add	a4,a0,s1
    80003ca8:	05874703          	lbu	a4,88(a4)
    80003cac:	00e7f6b3          	and	a3,a5,a4
    80003cb0:	c69d                	beqz	a3,80003cde <bfree+0x6c>
    80003cb2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003cb4:	94aa                	add	s1,s1,a0
    80003cb6:	fff7c793          	not	a5,a5
    80003cba:	8f7d                	and	a4,a4,a5
    80003cbc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003cc0:	00001097          	auipc	ra,0x1
    80003cc4:	126080e7          	jalr	294(ra) # 80004de6 <log_write>
  brelse(bp);
    80003cc8:	854a                	mv	a0,s2
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	e92080e7          	jalr	-366(ra) # 80003b5c <brelse>
}
    80003cd2:	60e2                	ld	ra,24(sp)
    80003cd4:	6442                	ld	s0,16(sp)
    80003cd6:	64a2                	ld	s1,8(sp)
    80003cd8:	6902                	ld	s2,0(sp)
    80003cda:	6105                	addi	sp,sp,32
    80003cdc:	8082                	ret
    panic("freeing free block");
    80003cde:	00005517          	auipc	a0,0x5
    80003ce2:	b2250513          	addi	a0,a0,-1246 # 80008800 <syscallnames+0x120>
    80003ce6:	ffffd097          	auipc	ra,0xffffd
    80003cea:	85a080e7          	jalr	-1958(ra) # 80000540 <panic>

0000000080003cee <balloc>:
{
    80003cee:	711d                	addi	sp,sp,-96
    80003cf0:	ec86                	sd	ra,88(sp)
    80003cf2:	e8a2                	sd	s0,80(sp)
    80003cf4:	e4a6                	sd	s1,72(sp)
    80003cf6:	e0ca                	sd	s2,64(sp)
    80003cf8:	fc4e                	sd	s3,56(sp)
    80003cfa:	f852                	sd	s4,48(sp)
    80003cfc:	f456                	sd	s5,40(sp)
    80003cfe:	f05a                	sd	s6,32(sp)
    80003d00:	ec5e                	sd	s7,24(sp)
    80003d02:	e862                	sd	s8,16(sp)
    80003d04:	e466                	sd	s9,8(sp)
    80003d06:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003d08:	0023d797          	auipc	a5,0x23d
    80003d0c:	6d47a783          	lw	a5,1748(a5) # 802413dc <sb+0x4>
    80003d10:	cff5                	beqz	a5,80003e0c <balloc+0x11e>
    80003d12:	8baa                	mv	s7,a0
    80003d14:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003d16:	0023db17          	auipc	s6,0x23d
    80003d1a:	6c2b0b13          	addi	s6,s6,1730 # 802413d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d1e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003d20:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d22:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003d24:	6c89                	lui	s9,0x2
    80003d26:	a061                	j	80003dae <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003d28:	97ca                	add	a5,a5,s2
    80003d2a:	8e55                	or	a2,a2,a3
    80003d2c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003d30:	854a                	mv	a0,s2
    80003d32:	00001097          	auipc	ra,0x1
    80003d36:	0b4080e7          	jalr	180(ra) # 80004de6 <log_write>
        brelse(bp);
    80003d3a:	854a                	mv	a0,s2
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	e20080e7          	jalr	-480(ra) # 80003b5c <brelse>
  bp = bread(dev, bno);
    80003d44:	85a6                	mv	a1,s1
    80003d46:	855e                	mv	a0,s7
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	ce4080e7          	jalr	-796(ra) # 80003a2c <bread>
    80003d50:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003d52:	40000613          	li	a2,1024
    80003d56:	4581                	li	a1,0
    80003d58:	05850513          	addi	a0,a0,88
    80003d5c:	ffffd097          	auipc	ra,0xffffd
    80003d60:	0b6080e7          	jalr	182(ra) # 80000e12 <memset>
  log_write(bp);
    80003d64:	854a                	mv	a0,s2
    80003d66:	00001097          	auipc	ra,0x1
    80003d6a:	080080e7          	jalr	128(ra) # 80004de6 <log_write>
  brelse(bp);
    80003d6e:	854a                	mv	a0,s2
    80003d70:	00000097          	auipc	ra,0x0
    80003d74:	dec080e7          	jalr	-532(ra) # 80003b5c <brelse>
}
    80003d78:	8526                	mv	a0,s1
    80003d7a:	60e6                	ld	ra,88(sp)
    80003d7c:	6446                	ld	s0,80(sp)
    80003d7e:	64a6                	ld	s1,72(sp)
    80003d80:	6906                	ld	s2,64(sp)
    80003d82:	79e2                	ld	s3,56(sp)
    80003d84:	7a42                	ld	s4,48(sp)
    80003d86:	7aa2                	ld	s5,40(sp)
    80003d88:	7b02                	ld	s6,32(sp)
    80003d8a:	6be2                	ld	s7,24(sp)
    80003d8c:	6c42                	ld	s8,16(sp)
    80003d8e:	6ca2                	ld	s9,8(sp)
    80003d90:	6125                	addi	sp,sp,96
    80003d92:	8082                	ret
    brelse(bp);
    80003d94:	854a                	mv	a0,s2
    80003d96:	00000097          	auipc	ra,0x0
    80003d9a:	dc6080e7          	jalr	-570(ra) # 80003b5c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003d9e:	015c87bb          	addw	a5,s9,s5
    80003da2:	00078a9b          	sext.w	s5,a5
    80003da6:	004b2703          	lw	a4,4(s6)
    80003daa:	06eaf163          	bgeu	s5,a4,80003e0c <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003dae:	41fad79b          	sraiw	a5,s5,0x1f
    80003db2:	0137d79b          	srliw	a5,a5,0x13
    80003db6:	015787bb          	addw	a5,a5,s5
    80003dba:	40d7d79b          	sraiw	a5,a5,0xd
    80003dbe:	01cb2583          	lw	a1,28(s6)
    80003dc2:	9dbd                	addw	a1,a1,a5
    80003dc4:	855e                	mv	a0,s7
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	c66080e7          	jalr	-922(ra) # 80003a2c <bread>
    80003dce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003dd0:	004b2503          	lw	a0,4(s6)
    80003dd4:	000a849b          	sext.w	s1,s5
    80003dd8:	8762                	mv	a4,s8
    80003dda:	faa4fde3          	bgeu	s1,a0,80003d94 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003dde:	00777693          	andi	a3,a4,7
    80003de2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003de6:	41f7579b          	sraiw	a5,a4,0x1f
    80003dea:	01d7d79b          	srliw	a5,a5,0x1d
    80003dee:	9fb9                	addw	a5,a5,a4
    80003df0:	4037d79b          	sraiw	a5,a5,0x3
    80003df4:	00f90633          	add	a2,s2,a5
    80003df8:	05864603          	lbu	a2,88(a2)
    80003dfc:	00c6f5b3          	and	a1,a3,a2
    80003e00:	d585                	beqz	a1,80003d28 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003e02:	2705                	addiw	a4,a4,1
    80003e04:	2485                	addiw	s1,s1,1
    80003e06:	fd471ae3          	bne	a4,s4,80003dda <balloc+0xec>
    80003e0a:	b769                	j	80003d94 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003e0c:	00005517          	auipc	a0,0x5
    80003e10:	a0c50513          	addi	a0,a0,-1524 # 80008818 <syscallnames+0x138>
    80003e14:	ffffc097          	auipc	ra,0xffffc
    80003e18:	776080e7          	jalr	1910(ra) # 8000058a <printf>
  return 0;
    80003e1c:	4481                	li	s1,0
    80003e1e:	bfa9                	j	80003d78 <balloc+0x8a>

0000000080003e20 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003e20:	7179                	addi	sp,sp,-48
    80003e22:	f406                	sd	ra,40(sp)
    80003e24:	f022                	sd	s0,32(sp)
    80003e26:	ec26                	sd	s1,24(sp)
    80003e28:	e84a                	sd	s2,16(sp)
    80003e2a:	e44e                	sd	s3,8(sp)
    80003e2c:	e052                	sd	s4,0(sp)
    80003e2e:	1800                	addi	s0,sp,48
    80003e30:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003e32:	47ad                	li	a5,11
    80003e34:	02b7e863          	bltu	a5,a1,80003e64 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003e38:	02059793          	slli	a5,a1,0x20
    80003e3c:	01e7d593          	srli	a1,a5,0x1e
    80003e40:	00b504b3          	add	s1,a0,a1
    80003e44:	0504a903          	lw	s2,80(s1)
    80003e48:	06091e63          	bnez	s2,80003ec4 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003e4c:	4108                	lw	a0,0(a0)
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	ea0080e7          	jalr	-352(ra) # 80003cee <balloc>
    80003e56:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003e5a:	06090563          	beqz	s2,80003ec4 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003e5e:	0524a823          	sw	s2,80(s1)
    80003e62:	a08d                	j	80003ec4 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003e64:	ff45849b          	addiw	s1,a1,-12
    80003e68:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003e6c:	0ff00793          	li	a5,255
    80003e70:	08e7e563          	bltu	a5,a4,80003efa <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003e74:	08052903          	lw	s2,128(a0)
    80003e78:	00091d63          	bnez	s2,80003e92 <bmap+0x72>
      addr = balloc(ip->dev);
    80003e7c:	4108                	lw	a0,0(a0)
    80003e7e:	00000097          	auipc	ra,0x0
    80003e82:	e70080e7          	jalr	-400(ra) # 80003cee <balloc>
    80003e86:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003e8a:	02090d63          	beqz	s2,80003ec4 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003e8e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003e92:	85ca                	mv	a1,s2
    80003e94:	0009a503          	lw	a0,0(s3)
    80003e98:	00000097          	auipc	ra,0x0
    80003e9c:	b94080e7          	jalr	-1132(ra) # 80003a2c <bread>
    80003ea0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003ea2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003ea6:	02049713          	slli	a4,s1,0x20
    80003eaa:	01e75593          	srli	a1,a4,0x1e
    80003eae:	00b784b3          	add	s1,a5,a1
    80003eb2:	0004a903          	lw	s2,0(s1)
    80003eb6:	02090063          	beqz	s2,80003ed6 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003eba:	8552                	mv	a0,s4
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	ca0080e7          	jalr	-864(ra) # 80003b5c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003ec4:	854a                	mv	a0,s2
    80003ec6:	70a2                	ld	ra,40(sp)
    80003ec8:	7402                	ld	s0,32(sp)
    80003eca:	64e2                	ld	s1,24(sp)
    80003ecc:	6942                	ld	s2,16(sp)
    80003ece:	69a2                	ld	s3,8(sp)
    80003ed0:	6a02                	ld	s4,0(sp)
    80003ed2:	6145                	addi	sp,sp,48
    80003ed4:	8082                	ret
      addr = balloc(ip->dev);
    80003ed6:	0009a503          	lw	a0,0(s3)
    80003eda:	00000097          	auipc	ra,0x0
    80003ede:	e14080e7          	jalr	-492(ra) # 80003cee <balloc>
    80003ee2:	0005091b          	sext.w	s2,a0
      if(addr){
    80003ee6:	fc090ae3          	beqz	s2,80003eba <bmap+0x9a>
        a[bn] = addr;
    80003eea:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003eee:	8552                	mv	a0,s4
    80003ef0:	00001097          	auipc	ra,0x1
    80003ef4:	ef6080e7          	jalr	-266(ra) # 80004de6 <log_write>
    80003ef8:	b7c9                	j	80003eba <bmap+0x9a>
  panic("bmap: out of range");
    80003efa:	00005517          	auipc	a0,0x5
    80003efe:	93650513          	addi	a0,a0,-1738 # 80008830 <syscallnames+0x150>
    80003f02:	ffffc097          	auipc	ra,0xffffc
    80003f06:	63e080e7          	jalr	1598(ra) # 80000540 <panic>

0000000080003f0a <iget>:
{
    80003f0a:	7179                	addi	sp,sp,-48
    80003f0c:	f406                	sd	ra,40(sp)
    80003f0e:	f022                	sd	s0,32(sp)
    80003f10:	ec26                	sd	s1,24(sp)
    80003f12:	e84a                	sd	s2,16(sp)
    80003f14:	e44e                	sd	s3,8(sp)
    80003f16:	e052                	sd	s4,0(sp)
    80003f18:	1800                	addi	s0,sp,48
    80003f1a:	89aa                	mv	s3,a0
    80003f1c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003f1e:	0023d517          	auipc	a0,0x23d
    80003f22:	4da50513          	addi	a0,a0,1242 # 802413f8 <itable>
    80003f26:	ffffd097          	auipc	ra,0xffffd
    80003f2a:	df0080e7          	jalr	-528(ra) # 80000d16 <acquire>
  empty = 0;
    80003f2e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003f30:	0023d497          	auipc	s1,0x23d
    80003f34:	4e048493          	addi	s1,s1,1248 # 80241410 <itable+0x18>
    80003f38:	0023f697          	auipc	a3,0x23f
    80003f3c:	f6868693          	addi	a3,a3,-152 # 80242ea0 <log>
    80003f40:	a039                	j	80003f4e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003f42:	02090b63          	beqz	s2,80003f78 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003f46:	08848493          	addi	s1,s1,136
    80003f4a:	02d48a63          	beq	s1,a3,80003f7e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003f4e:	449c                	lw	a5,8(s1)
    80003f50:	fef059e3          	blez	a5,80003f42 <iget+0x38>
    80003f54:	4098                	lw	a4,0(s1)
    80003f56:	ff3716e3          	bne	a4,s3,80003f42 <iget+0x38>
    80003f5a:	40d8                	lw	a4,4(s1)
    80003f5c:	ff4713e3          	bne	a4,s4,80003f42 <iget+0x38>
      ip->ref++;
    80003f60:	2785                	addiw	a5,a5,1
    80003f62:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003f64:	0023d517          	auipc	a0,0x23d
    80003f68:	49450513          	addi	a0,a0,1172 # 802413f8 <itable>
    80003f6c:	ffffd097          	auipc	ra,0xffffd
    80003f70:	e5e080e7          	jalr	-418(ra) # 80000dca <release>
      return ip;
    80003f74:	8926                	mv	s2,s1
    80003f76:	a03d                	j	80003fa4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003f78:	f7f9                	bnez	a5,80003f46 <iget+0x3c>
    80003f7a:	8926                	mv	s2,s1
    80003f7c:	b7e9                	j	80003f46 <iget+0x3c>
  if(empty == 0)
    80003f7e:	02090c63          	beqz	s2,80003fb6 <iget+0xac>
  ip->dev = dev;
    80003f82:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003f86:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003f8a:	4785                	li	a5,1
    80003f8c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003f90:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003f94:	0023d517          	auipc	a0,0x23d
    80003f98:	46450513          	addi	a0,a0,1124 # 802413f8 <itable>
    80003f9c:	ffffd097          	auipc	ra,0xffffd
    80003fa0:	e2e080e7          	jalr	-466(ra) # 80000dca <release>
}
    80003fa4:	854a                	mv	a0,s2
    80003fa6:	70a2                	ld	ra,40(sp)
    80003fa8:	7402                	ld	s0,32(sp)
    80003faa:	64e2                	ld	s1,24(sp)
    80003fac:	6942                	ld	s2,16(sp)
    80003fae:	69a2                	ld	s3,8(sp)
    80003fb0:	6a02                	ld	s4,0(sp)
    80003fb2:	6145                	addi	sp,sp,48
    80003fb4:	8082                	ret
    panic("iget: no inodes");
    80003fb6:	00005517          	auipc	a0,0x5
    80003fba:	89250513          	addi	a0,a0,-1902 # 80008848 <syscallnames+0x168>
    80003fbe:	ffffc097          	auipc	ra,0xffffc
    80003fc2:	582080e7          	jalr	1410(ra) # 80000540 <panic>

0000000080003fc6 <fsinit>:
fsinit(int dev) {
    80003fc6:	7179                	addi	sp,sp,-48
    80003fc8:	f406                	sd	ra,40(sp)
    80003fca:	f022                	sd	s0,32(sp)
    80003fcc:	ec26                	sd	s1,24(sp)
    80003fce:	e84a                	sd	s2,16(sp)
    80003fd0:	e44e                	sd	s3,8(sp)
    80003fd2:	1800                	addi	s0,sp,48
    80003fd4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003fd6:	4585                	li	a1,1
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	a54080e7          	jalr	-1452(ra) # 80003a2c <bread>
    80003fe0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003fe2:	0023d997          	auipc	s3,0x23d
    80003fe6:	3f698993          	addi	s3,s3,1014 # 802413d8 <sb>
    80003fea:	02000613          	li	a2,32
    80003fee:	05850593          	addi	a1,a0,88
    80003ff2:	854e                	mv	a0,s3
    80003ff4:	ffffd097          	auipc	ra,0xffffd
    80003ff8:	e7a080e7          	jalr	-390(ra) # 80000e6e <memmove>
  brelse(bp);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	b5e080e7          	jalr	-1186(ra) # 80003b5c <brelse>
  if(sb.magic != FSMAGIC)
    80004006:	0009a703          	lw	a4,0(s3)
    8000400a:	102037b7          	lui	a5,0x10203
    8000400e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004012:	02f71263          	bne	a4,a5,80004036 <fsinit+0x70>
  initlog(dev, &sb);
    80004016:	0023d597          	auipc	a1,0x23d
    8000401a:	3c258593          	addi	a1,a1,962 # 802413d8 <sb>
    8000401e:	854a                	mv	a0,s2
    80004020:	00001097          	auipc	ra,0x1
    80004024:	b4a080e7          	jalr	-1206(ra) # 80004b6a <initlog>
}
    80004028:	70a2                	ld	ra,40(sp)
    8000402a:	7402                	ld	s0,32(sp)
    8000402c:	64e2                	ld	s1,24(sp)
    8000402e:	6942                	ld	s2,16(sp)
    80004030:	69a2                	ld	s3,8(sp)
    80004032:	6145                	addi	sp,sp,48
    80004034:	8082                	ret
    panic("invalid file system");
    80004036:	00005517          	auipc	a0,0x5
    8000403a:	82250513          	addi	a0,a0,-2014 # 80008858 <syscallnames+0x178>
    8000403e:	ffffc097          	auipc	ra,0xffffc
    80004042:	502080e7          	jalr	1282(ra) # 80000540 <panic>

0000000080004046 <iinit>:
{
    80004046:	7179                	addi	sp,sp,-48
    80004048:	f406                	sd	ra,40(sp)
    8000404a:	f022                	sd	s0,32(sp)
    8000404c:	ec26                	sd	s1,24(sp)
    8000404e:	e84a                	sd	s2,16(sp)
    80004050:	e44e                	sd	s3,8(sp)
    80004052:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004054:	00005597          	auipc	a1,0x5
    80004058:	81c58593          	addi	a1,a1,-2020 # 80008870 <syscallnames+0x190>
    8000405c:	0023d517          	auipc	a0,0x23d
    80004060:	39c50513          	addi	a0,a0,924 # 802413f8 <itable>
    80004064:	ffffd097          	auipc	ra,0xffffd
    80004068:	c22080e7          	jalr	-990(ra) # 80000c86 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000406c:	0023d497          	auipc	s1,0x23d
    80004070:	3b448493          	addi	s1,s1,948 # 80241420 <itable+0x28>
    80004074:	0023f997          	auipc	s3,0x23f
    80004078:	e3c98993          	addi	s3,s3,-452 # 80242eb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000407c:	00004917          	auipc	s2,0x4
    80004080:	7fc90913          	addi	s2,s2,2044 # 80008878 <syscallnames+0x198>
    80004084:	85ca                	mv	a1,s2
    80004086:	8526                	mv	a0,s1
    80004088:	00001097          	auipc	ra,0x1
    8000408c:	e42080e7          	jalr	-446(ra) # 80004eca <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004090:	08848493          	addi	s1,s1,136
    80004094:	ff3498e3          	bne	s1,s3,80004084 <iinit+0x3e>
}
    80004098:	70a2                	ld	ra,40(sp)
    8000409a:	7402                	ld	s0,32(sp)
    8000409c:	64e2                	ld	s1,24(sp)
    8000409e:	6942                	ld	s2,16(sp)
    800040a0:	69a2                	ld	s3,8(sp)
    800040a2:	6145                	addi	sp,sp,48
    800040a4:	8082                	ret

00000000800040a6 <ialloc>:
{
    800040a6:	715d                	addi	sp,sp,-80
    800040a8:	e486                	sd	ra,72(sp)
    800040aa:	e0a2                	sd	s0,64(sp)
    800040ac:	fc26                	sd	s1,56(sp)
    800040ae:	f84a                	sd	s2,48(sp)
    800040b0:	f44e                	sd	s3,40(sp)
    800040b2:	f052                	sd	s4,32(sp)
    800040b4:	ec56                	sd	s5,24(sp)
    800040b6:	e85a                	sd	s6,16(sp)
    800040b8:	e45e                	sd	s7,8(sp)
    800040ba:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800040bc:	0023d717          	auipc	a4,0x23d
    800040c0:	32872703          	lw	a4,808(a4) # 802413e4 <sb+0xc>
    800040c4:	4785                	li	a5,1
    800040c6:	04e7fa63          	bgeu	a5,a4,8000411a <ialloc+0x74>
    800040ca:	8aaa                	mv	s5,a0
    800040cc:	8bae                	mv	s7,a1
    800040ce:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800040d0:	0023da17          	auipc	s4,0x23d
    800040d4:	308a0a13          	addi	s4,s4,776 # 802413d8 <sb>
    800040d8:	00048b1b          	sext.w	s6,s1
    800040dc:	0044d593          	srli	a1,s1,0x4
    800040e0:	018a2783          	lw	a5,24(s4)
    800040e4:	9dbd                	addw	a1,a1,a5
    800040e6:	8556                	mv	a0,s5
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	944080e7          	jalr	-1724(ra) # 80003a2c <bread>
    800040f0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800040f2:	05850993          	addi	s3,a0,88
    800040f6:	00f4f793          	andi	a5,s1,15
    800040fa:	079a                	slli	a5,a5,0x6
    800040fc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800040fe:	00099783          	lh	a5,0(s3)
    80004102:	c3a1                	beqz	a5,80004142 <ialloc+0x9c>
    brelse(bp);
    80004104:	00000097          	auipc	ra,0x0
    80004108:	a58080e7          	jalr	-1448(ra) # 80003b5c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000410c:	0485                	addi	s1,s1,1
    8000410e:	00ca2703          	lw	a4,12(s4)
    80004112:	0004879b          	sext.w	a5,s1
    80004116:	fce7e1e3          	bltu	a5,a4,800040d8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000411a:	00004517          	auipc	a0,0x4
    8000411e:	76650513          	addi	a0,a0,1894 # 80008880 <syscallnames+0x1a0>
    80004122:	ffffc097          	auipc	ra,0xffffc
    80004126:	468080e7          	jalr	1128(ra) # 8000058a <printf>
  return 0;
    8000412a:	4501                	li	a0,0
}
    8000412c:	60a6                	ld	ra,72(sp)
    8000412e:	6406                	ld	s0,64(sp)
    80004130:	74e2                	ld	s1,56(sp)
    80004132:	7942                	ld	s2,48(sp)
    80004134:	79a2                	ld	s3,40(sp)
    80004136:	7a02                	ld	s4,32(sp)
    80004138:	6ae2                	ld	s5,24(sp)
    8000413a:	6b42                	ld	s6,16(sp)
    8000413c:	6ba2                	ld	s7,8(sp)
    8000413e:	6161                	addi	sp,sp,80
    80004140:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80004142:	04000613          	li	a2,64
    80004146:	4581                	li	a1,0
    80004148:	854e                	mv	a0,s3
    8000414a:	ffffd097          	auipc	ra,0xffffd
    8000414e:	cc8080e7          	jalr	-824(ra) # 80000e12 <memset>
      dip->type = type;
    80004152:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004156:	854a                	mv	a0,s2
    80004158:	00001097          	auipc	ra,0x1
    8000415c:	c8e080e7          	jalr	-882(ra) # 80004de6 <log_write>
      brelse(bp);
    80004160:	854a                	mv	a0,s2
    80004162:	00000097          	auipc	ra,0x0
    80004166:	9fa080e7          	jalr	-1542(ra) # 80003b5c <brelse>
      return iget(dev, inum);
    8000416a:	85da                	mv	a1,s6
    8000416c:	8556                	mv	a0,s5
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	d9c080e7          	jalr	-612(ra) # 80003f0a <iget>
    80004176:	bf5d                	j	8000412c <ialloc+0x86>

0000000080004178 <iupdate>:
{
    80004178:	1101                	addi	sp,sp,-32
    8000417a:	ec06                	sd	ra,24(sp)
    8000417c:	e822                	sd	s0,16(sp)
    8000417e:	e426                	sd	s1,8(sp)
    80004180:	e04a                	sd	s2,0(sp)
    80004182:	1000                	addi	s0,sp,32
    80004184:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004186:	415c                	lw	a5,4(a0)
    80004188:	0047d79b          	srliw	a5,a5,0x4
    8000418c:	0023d597          	auipc	a1,0x23d
    80004190:	2645a583          	lw	a1,612(a1) # 802413f0 <sb+0x18>
    80004194:	9dbd                	addw	a1,a1,a5
    80004196:	4108                	lw	a0,0(a0)
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	894080e7          	jalr	-1900(ra) # 80003a2c <bread>
    800041a0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800041a2:	05850793          	addi	a5,a0,88
    800041a6:	40d8                	lw	a4,4(s1)
    800041a8:	8b3d                	andi	a4,a4,15
    800041aa:	071a                	slli	a4,a4,0x6
    800041ac:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800041ae:	04449703          	lh	a4,68(s1)
    800041b2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800041b6:	04649703          	lh	a4,70(s1)
    800041ba:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800041be:	04849703          	lh	a4,72(s1)
    800041c2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800041c6:	04a49703          	lh	a4,74(s1)
    800041ca:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800041ce:	44f8                	lw	a4,76(s1)
    800041d0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800041d2:	03400613          	li	a2,52
    800041d6:	05048593          	addi	a1,s1,80
    800041da:	00c78513          	addi	a0,a5,12
    800041de:	ffffd097          	auipc	ra,0xffffd
    800041e2:	c90080e7          	jalr	-880(ra) # 80000e6e <memmove>
  log_write(bp);
    800041e6:	854a                	mv	a0,s2
    800041e8:	00001097          	auipc	ra,0x1
    800041ec:	bfe080e7          	jalr	-1026(ra) # 80004de6 <log_write>
  brelse(bp);
    800041f0:	854a                	mv	a0,s2
    800041f2:	00000097          	auipc	ra,0x0
    800041f6:	96a080e7          	jalr	-1686(ra) # 80003b5c <brelse>
}
    800041fa:	60e2                	ld	ra,24(sp)
    800041fc:	6442                	ld	s0,16(sp)
    800041fe:	64a2                	ld	s1,8(sp)
    80004200:	6902                	ld	s2,0(sp)
    80004202:	6105                	addi	sp,sp,32
    80004204:	8082                	ret

0000000080004206 <idup>:
{
    80004206:	1101                	addi	sp,sp,-32
    80004208:	ec06                	sd	ra,24(sp)
    8000420a:	e822                	sd	s0,16(sp)
    8000420c:	e426                	sd	s1,8(sp)
    8000420e:	1000                	addi	s0,sp,32
    80004210:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004212:	0023d517          	auipc	a0,0x23d
    80004216:	1e650513          	addi	a0,a0,486 # 802413f8 <itable>
    8000421a:	ffffd097          	auipc	ra,0xffffd
    8000421e:	afc080e7          	jalr	-1284(ra) # 80000d16 <acquire>
  ip->ref++;
    80004222:	449c                	lw	a5,8(s1)
    80004224:	2785                	addiw	a5,a5,1
    80004226:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004228:	0023d517          	auipc	a0,0x23d
    8000422c:	1d050513          	addi	a0,a0,464 # 802413f8 <itable>
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	b9a080e7          	jalr	-1126(ra) # 80000dca <release>
}
    80004238:	8526                	mv	a0,s1
    8000423a:	60e2                	ld	ra,24(sp)
    8000423c:	6442                	ld	s0,16(sp)
    8000423e:	64a2                	ld	s1,8(sp)
    80004240:	6105                	addi	sp,sp,32
    80004242:	8082                	ret

0000000080004244 <ilock>:
{
    80004244:	1101                	addi	sp,sp,-32
    80004246:	ec06                	sd	ra,24(sp)
    80004248:	e822                	sd	s0,16(sp)
    8000424a:	e426                	sd	s1,8(sp)
    8000424c:	e04a                	sd	s2,0(sp)
    8000424e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004250:	c115                	beqz	a0,80004274 <ilock+0x30>
    80004252:	84aa                	mv	s1,a0
    80004254:	451c                	lw	a5,8(a0)
    80004256:	00f05f63          	blez	a5,80004274 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000425a:	0541                	addi	a0,a0,16
    8000425c:	00001097          	auipc	ra,0x1
    80004260:	ca8080e7          	jalr	-856(ra) # 80004f04 <acquiresleep>
  if(ip->valid == 0){
    80004264:	40bc                	lw	a5,64(s1)
    80004266:	cf99                	beqz	a5,80004284 <ilock+0x40>
}
    80004268:	60e2                	ld	ra,24(sp)
    8000426a:	6442                	ld	s0,16(sp)
    8000426c:	64a2                	ld	s1,8(sp)
    8000426e:	6902                	ld	s2,0(sp)
    80004270:	6105                	addi	sp,sp,32
    80004272:	8082                	ret
    panic("ilock");
    80004274:	00004517          	auipc	a0,0x4
    80004278:	62450513          	addi	a0,a0,1572 # 80008898 <syscallnames+0x1b8>
    8000427c:	ffffc097          	auipc	ra,0xffffc
    80004280:	2c4080e7          	jalr	708(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004284:	40dc                	lw	a5,4(s1)
    80004286:	0047d79b          	srliw	a5,a5,0x4
    8000428a:	0023d597          	auipc	a1,0x23d
    8000428e:	1665a583          	lw	a1,358(a1) # 802413f0 <sb+0x18>
    80004292:	9dbd                	addw	a1,a1,a5
    80004294:	4088                	lw	a0,0(s1)
    80004296:	fffff097          	auipc	ra,0xfffff
    8000429a:	796080e7          	jalr	1942(ra) # 80003a2c <bread>
    8000429e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800042a0:	05850593          	addi	a1,a0,88
    800042a4:	40dc                	lw	a5,4(s1)
    800042a6:	8bbd                	andi	a5,a5,15
    800042a8:	079a                	slli	a5,a5,0x6
    800042aa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800042ac:	00059783          	lh	a5,0(a1)
    800042b0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800042b4:	00259783          	lh	a5,2(a1)
    800042b8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800042bc:	00459783          	lh	a5,4(a1)
    800042c0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800042c4:	00659783          	lh	a5,6(a1)
    800042c8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800042cc:	459c                	lw	a5,8(a1)
    800042ce:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800042d0:	03400613          	li	a2,52
    800042d4:	05b1                	addi	a1,a1,12
    800042d6:	05048513          	addi	a0,s1,80
    800042da:	ffffd097          	auipc	ra,0xffffd
    800042de:	b94080e7          	jalr	-1132(ra) # 80000e6e <memmove>
    brelse(bp);
    800042e2:	854a                	mv	a0,s2
    800042e4:	00000097          	auipc	ra,0x0
    800042e8:	878080e7          	jalr	-1928(ra) # 80003b5c <brelse>
    ip->valid = 1;
    800042ec:	4785                	li	a5,1
    800042ee:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800042f0:	04449783          	lh	a5,68(s1)
    800042f4:	fbb5                	bnez	a5,80004268 <ilock+0x24>
      panic("ilock: no type");
    800042f6:	00004517          	auipc	a0,0x4
    800042fa:	5aa50513          	addi	a0,a0,1450 # 800088a0 <syscallnames+0x1c0>
    800042fe:	ffffc097          	auipc	ra,0xffffc
    80004302:	242080e7          	jalr	578(ra) # 80000540 <panic>

0000000080004306 <iunlock>:
{
    80004306:	1101                	addi	sp,sp,-32
    80004308:	ec06                	sd	ra,24(sp)
    8000430a:	e822                	sd	s0,16(sp)
    8000430c:	e426                	sd	s1,8(sp)
    8000430e:	e04a                	sd	s2,0(sp)
    80004310:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004312:	c905                	beqz	a0,80004342 <iunlock+0x3c>
    80004314:	84aa                	mv	s1,a0
    80004316:	01050913          	addi	s2,a0,16
    8000431a:	854a                	mv	a0,s2
    8000431c:	00001097          	auipc	ra,0x1
    80004320:	c82080e7          	jalr	-894(ra) # 80004f9e <holdingsleep>
    80004324:	cd19                	beqz	a0,80004342 <iunlock+0x3c>
    80004326:	449c                	lw	a5,8(s1)
    80004328:	00f05d63          	blez	a5,80004342 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000432c:	854a                	mv	a0,s2
    8000432e:	00001097          	auipc	ra,0x1
    80004332:	c2c080e7          	jalr	-980(ra) # 80004f5a <releasesleep>
}
    80004336:	60e2                	ld	ra,24(sp)
    80004338:	6442                	ld	s0,16(sp)
    8000433a:	64a2                	ld	s1,8(sp)
    8000433c:	6902                	ld	s2,0(sp)
    8000433e:	6105                	addi	sp,sp,32
    80004340:	8082                	ret
    panic("iunlock");
    80004342:	00004517          	auipc	a0,0x4
    80004346:	56e50513          	addi	a0,a0,1390 # 800088b0 <syscallnames+0x1d0>
    8000434a:	ffffc097          	auipc	ra,0xffffc
    8000434e:	1f6080e7          	jalr	502(ra) # 80000540 <panic>

0000000080004352 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004352:	7179                	addi	sp,sp,-48
    80004354:	f406                	sd	ra,40(sp)
    80004356:	f022                	sd	s0,32(sp)
    80004358:	ec26                	sd	s1,24(sp)
    8000435a:	e84a                	sd	s2,16(sp)
    8000435c:	e44e                	sd	s3,8(sp)
    8000435e:	e052                	sd	s4,0(sp)
    80004360:	1800                	addi	s0,sp,48
    80004362:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004364:	05050493          	addi	s1,a0,80
    80004368:	08050913          	addi	s2,a0,128
    8000436c:	a021                	j	80004374 <itrunc+0x22>
    8000436e:	0491                	addi	s1,s1,4
    80004370:	01248d63          	beq	s1,s2,8000438a <itrunc+0x38>
    if(ip->addrs[i]){
    80004374:	408c                	lw	a1,0(s1)
    80004376:	dde5                	beqz	a1,8000436e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004378:	0009a503          	lw	a0,0(s3)
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	8f6080e7          	jalr	-1802(ra) # 80003c72 <bfree>
      ip->addrs[i] = 0;
    80004384:	0004a023          	sw	zero,0(s1)
    80004388:	b7dd                	j	8000436e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000438a:	0809a583          	lw	a1,128(s3)
    8000438e:	e185                	bnez	a1,800043ae <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004390:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004394:	854e                	mv	a0,s3
    80004396:	00000097          	auipc	ra,0x0
    8000439a:	de2080e7          	jalr	-542(ra) # 80004178 <iupdate>
}
    8000439e:	70a2                	ld	ra,40(sp)
    800043a0:	7402                	ld	s0,32(sp)
    800043a2:	64e2                	ld	s1,24(sp)
    800043a4:	6942                	ld	s2,16(sp)
    800043a6:	69a2                	ld	s3,8(sp)
    800043a8:	6a02                	ld	s4,0(sp)
    800043aa:	6145                	addi	sp,sp,48
    800043ac:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800043ae:	0009a503          	lw	a0,0(s3)
    800043b2:	fffff097          	auipc	ra,0xfffff
    800043b6:	67a080e7          	jalr	1658(ra) # 80003a2c <bread>
    800043ba:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800043bc:	05850493          	addi	s1,a0,88
    800043c0:	45850913          	addi	s2,a0,1112
    800043c4:	a021                	j	800043cc <itrunc+0x7a>
    800043c6:	0491                	addi	s1,s1,4
    800043c8:	01248b63          	beq	s1,s2,800043de <itrunc+0x8c>
      if(a[j])
    800043cc:	408c                	lw	a1,0(s1)
    800043ce:	dde5                	beqz	a1,800043c6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800043d0:	0009a503          	lw	a0,0(s3)
    800043d4:	00000097          	auipc	ra,0x0
    800043d8:	89e080e7          	jalr	-1890(ra) # 80003c72 <bfree>
    800043dc:	b7ed                	j	800043c6 <itrunc+0x74>
    brelse(bp);
    800043de:	8552                	mv	a0,s4
    800043e0:	fffff097          	auipc	ra,0xfffff
    800043e4:	77c080e7          	jalr	1916(ra) # 80003b5c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800043e8:	0809a583          	lw	a1,128(s3)
    800043ec:	0009a503          	lw	a0,0(s3)
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	882080e7          	jalr	-1918(ra) # 80003c72 <bfree>
    ip->addrs[NDIRECT] = 0;
    800043f8:	0809a023          	sw	zero,128(s3)
    800043fc:	bf51                	j	80004390 <itrunc+0x3e>

00000000800043fe <iput>:
{
    800043fe:	1101                	addi	sp,sp,-32
    80004400:	ec06                	sd	ra,24(sp)
    80004402:	e822                	sd	s0,16(sp)
    80004404:	e426                	sd	s1,8(sp)
    80004406:	e04a                	sd	s2,0(sp)
    80004408:	1000                	addi	s0,sp,32
    8000440a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000440c:	0023d517          	auipc	a0,0x23d
    80004410:	fec50513          	addi	a0,a0,-20 # 802413f8 <itable>
    80004414:	ffffd097          	auipc	ra,0xffffd
    80004418:	902080e7          	jalr	-1790(ra) # 80000d16 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000441c:	4498                	lw	a4,8(s1)
    8000441e:	4785                	li	a5,1
    80004420:	02f70363          	beq	a4,a5,80004446 <iput+0x48>
  ip->ref--;
    80004424:	449c                	lw	a5,8(s1)
    80004426:	37fd                	addiw	a5,a5,-1
    80004428:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000442a:	0023d517          	auipc	a0,0x23d
    8000442e:	fce50513          	addi	a0,a0,-50 # 802413f8 <itable>
    80004432:	ffffd097          	auipc	ra,0xffffd
    80004436:	998080e7          	jalr	-1640(ra) # 80000dca <release>
}
    8000443a:	60e2                	ld	ra,24(sp)
    8000443c:	6442                	ld	s0,16(sp)
    8000443e:	64a2                	ld	s1,8(sp)
    80004440:	6902                	ld	s2,0(sp)
    80004442:	6105                	addi	sp,sp,32
    80004444:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004446:	40bc                	lw	a5,64(s1)
    80004448:	dff1                	beqz	a5,80004424 <iput+0x26>
    8000444a:	04a49783          	lh	a5,74(s1)
    8000444e:	fbf9                	bnez	a5,80004424 <iput+0x26>
    acquiresleep(&ip->lock);
    80004450:	01048913          	addi	s2,s1,16
    80004454:	854a                	mv	a0,s2
    80004456:	00001097          	auipc	ra,0x1
    8000445a:	aae080e7          	jalr	-1362(ra) # 80004f04 <acquiresleep>
    release(&itable.lock);
    8000445e:	0023d517          	auipc	a0,0x23d
    80004462:	f9a50513          	addi	a0,a0,-102 # 802413f8 <itable>
    80004466:	ffffd097          	auipc	ra,0xffffd
    8000446a:	964080e7          	jalr	-1692(ra) # 80000dca <release>
    itrunc(ip);
    8000446e:	8526                	mv	a0,s1
    80004470:	00000097          	auipc	ra,0x0
    80004474:	ee2080e7          	jalr	-286(ra) # 80004352 <itrunc>
    ip->type = 0;
    80004478:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000447c:	8526                	mv	a0,s1
    8000447e:	00000097          	auipc	ra,0x0
    80004482:	cfa080e7          	jalr	-774(ra) # 80004178 <iupdate>
    ip->valid = 0;
    80004486:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000448a:	854a                	mv	a0,s2
    8000448c:	00001097          	auipc	ra,0x1
    80004490:	ace080e7          	jalr	-1330(ra) # 80004f5a <releasesleep>
    acquire(&itable.lock);
    80004494:	0023d517          	auipc	a0,0x23d
    80004498:	f6450513          	addi	a0,a0,-156 # 802413f8 <itable>
    8000449c:	ffffd097          	auipc	ra,0xffffd
    800044a0:	87a080e7          	jalr	-1926(ra) # 80000d16 <acquire>
    800044a4:	b741                	j	80004424 <iput+0x26>

00000000800044a6 <iunlockput>:
{
    800044a6:	1101                	addi	sp,sp,-32
    800044a8:	ec06                	sd	ra,24(sp)
    800044aa:	e822                	sd	s0,16(sp)
    800044ac:	e426                	sd	s1,8(sp)
    800044ae:	1000                	addi	s0,sp,32
    800044b0:	84aa                	mv	s1,a0
  iunlock(ip);
    800044b2:	00000097          	auipc	ra,0x0
    800044b6:	e54080e7          	jalr	-428(ra) # 80004306 <iunlock>
  iput(ip);
    800044ba:	8526                	mv	a0,s1
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	f42080e7          	jalr	-190(ra) # 800043fe <iput>
}
    800044c4:	60e2                	ld	ra,24(sp)
    800044c6:	6442                	ld	s0,16(sp)
    800044c8:	64a2                	ld	s1,8(sp)
    800044ca:	6105                	addi	sp,sp,32
    800044cc:	8082                	ret

00000000800044ce <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800044ce:	1141                	addi	sp,sp,-16
    800044d0:	e422                	sd	s0,8(sp)
    800044d2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800044d4:	411c                	lw	a5,0(a0)
    800044d6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800044d8:	415c                	lw	a5,4(a0)
    800044da:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800044dc:	04451783          	lh	a5,68(a0)
    800044e0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800044e4:	04a51783          	lh	a5,74(a0)
    800044e8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800044ec:	04c56783          	lwu	a5,76(a0)
    800044f0:	e99c                	sd	a5,16(a1)
}
    800044f2:	6422                	ld	s0,8(sp)
    800044f4:	0141                	addi	sp,sp,16
    800044f6:	8082                	ret

00000000800044f8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800044f8:	457c                	lw	a5,76(a0)
    800044fa:	0ed7e963          	bltu	a5,a3,800045ec <readi+0xf4>
{
    800044fe:	7159                	addi	sp,sp,-112
    80004500:	f486                	sd	ra,104(sp)
    80004502:	f0a2                	sd	s0,96(sp)
    80004504:	eca6                	sd	s1,88(sp)
    80004506:	e8ca                	sd	s2,80(sp)
    80004508:	e4ce                	sd	s3,72(sp)
    8000450a:	e0d2                	sd	s4,64(sp)
    8000450c:	fc56                	sd	s5,56(sp)
    8000450e:	f85a                	sd	s6,48(sp)
    80004510:	f45e                	sd	s7,40(sp)
    80004512:	f062                	sd	s8,32(sp)
    80004514:	ec66                	sd	s9,24(sp)
    80004516:	e86a                	sd	s10,16(sp)
    80004518:	e46e                	sd	s11,8(sp)
    8000451a:	1880                	addi	s0,sp,112
    8000451c:	8b2a                	mv	s6,a0
    8000451e:	8bae                	mv	s7,a1
    80004520:	8a32                	mv	s4,a2
    80004522:	84b6                	mv	s1,a3
    80004524:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004526:	9f35                	addw	a4,a4,a3
    return 0;
    80004528:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000452a:	0ad76063          	bltu	a4,a3,800045ca <readi+0xd2>
  if(off + n > ip->size)
    8000452e:	00e7f463          	bgeu	a5,a4,80004536 <readi+0x3e>
    n = ip->size - off;
    80004532:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004536:	0a0a8963          	beqz	s5,800045e8 <readi+0xf0>
    8000453a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000453c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004540:	5c7d                	li	s8,-1
    80004542:	a82d                	j	8000457c <readi+0x84>
    80004544:	020d1d93          	slli	s11,s10,0x20
    80004548:	020ddd93          	srli	s11,s11,0x20
    8000454c:	05890613          	addi	a2,s2,88
    80004550:	86ee                	mv	a3,s11
    80004552:	963a                	add	a2,a2,a4
    80004554:	85d2                	mv	a1,s4
    80004556:	855e                	mv	a0,s7
    80004558:	ffffe097          	auipc	ra,0xffffe
    8000455c:	530080e7          	jalr	1328(ra) # 80002a88 <either_copyout>
    80004560:	05850d63          	beq	a0,s8,800045ba <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004564:	854a                	mv	a0,s2
    80004566:	fffff097          	auipc	ra,0xfffff
    8000456a:	5f6080e7          	jalr	1526(ra) # 80003b5c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000456e:	013d09bb          	addw	s3,s10,s3
    80004572:	009d04bb          	addw	s1,s10,s1
    80004576:	9a6e                	add	s4,s4,s11
    80004578:	0559f763          	bgeu	s3,s5,800045c6 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000457c:	00a4d59b          	srliw	a1,s1,0xa
    80004580:	855a                	mv	a0,s6
    80004582:	00000097          	auipc	ra,0x0
    80004586:	89e080e7          	jalr	-1890(ra) # 80003e20 <bmap>
    8000458a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000458e:	cd85                	beqz	a1,800045c6 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004590:	000b2503          	lw	a0,0(s6)
    80004594:	fffff097          	auipc	ra,0xfffff
    80004598:	498080e7          	jalr	1176(ra) # 80003a2c <bread>
    8000459c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000459e:	3ff4f713          	andi	a4,s1,1023
    800045a2:	40ec87bb          	subw	a5,s9,a4
    800045a6:	413a86bb          	subw	a3,s5,s3
    800045aa:	8d3e                	mv	s10,a5
    800045ac:	2781                	sext.w	a5,a5
    800045ae:	0006861b          	sext.w	a2,a3
    800045b2:	f8f679e3          	bgeu	a2,a5,80004544 <readi+0x4c>
    800045b6:	8d36                	mv	s10,a3
    800045b8:	b771                	j	80004544 <readi+0x4c>
      brelse(bp);
    800045ba:	854a                	mv	a0,s2
    800045bc:	fffff097          	auipc	ra,0xfffff
    800045c0:	5a0080e7          	jalr	1440(ra) # 80003b5c <brelse>
      tot = -1;
    800045c4:	59fd                	li	s3,-1
  }
  return tot;
    800045c6:	0009851b          	sext.w	a0,s3
}
    800045ca:	70a6                	ld	ra,104(sp)
    800045cc:	7406                	ld	s0,96(sp)
    800045ce:	64e6                	ld	s1,88(sp)
    800045d0:	6946                	ld	s2,80(sp)
    800045d2:	69a6                	ld	s3,72(sp)
    800045d4:	6a06                	ld	s4,64(sp)
    800045d6:	7ae2                	ld	s5,56(sp)
    800045d8:	7b42                	ld	s6,48(sp)
    800045da:	7ba2                	ld	s7,40(sp)
    800045dc:	7c02                	ld	s8,32(sp)
    800045de:	6ce2                	ld	s9,24(sp)
    800045e0:	6d42                	ld	s10,16(sp)
    800045e2:	6da2                	ld	s11,8(sp)
    800045e4:	6165                	addi	sp,sp,112
    800045e6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800045e8:	89d6                	mv	s3,s5
    800045ea:	bff1                	j	800045c6 <readi+0xce>
    return 0;
    800045ec:	4501                	li	a0,0
}
    800045ee:	8082                	ret

00000000800045f0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800045f0:	457c                	lw	a5,76(a0)
    800045f2:	10d7e863          	bltu	a5,a3,80004702 <writei+0x112>
{
    800045f6:	7159                	addi	sp,sp,-112
    800045f8:	f486                	sd	ra,104(sp)
    800045fa:	f0a2                	sd	s0,96(sp)
    800045fc:	eca6                	sd	s1,88(sp)
    800045fe:	e8ca                	sd	s2,80(sp)
    80004600:	e4ce                	sd	s3,72(sp)
    80004602:	e0d2                	sd	s4,64(sp)
    80004604:	fc56                	sd	s5,56(sp)
    80004606:	f85a                	sd	s6,48(sp)
    80004608:	f45e                	sd	s7,40(sp)
    8000460a:	f062                	sd	s8,32(sp)
    8000460c:	ec66                	sd	s9,24(sp)
    8000460e:	e86a                	sd	s10,16(sp)
    80004610:	e46e                	sd	s11,8(sp)
    80004612:	1880                	addi	s0,sp,112
    80004614:	8aaa                	mv	s5,a0
    80004616:	8bae                	mv	s7,a1
    80004618:	8a32                	mv	s4,a2
    8000461a:	8936                	mv	s2,a3
    8000461c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000461e:	00e687bb          	addw	a5,a3,a4
    80004622:	0ed7e263          	bltu	a5,a3,80004706 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004626:	00043737          	lui	a4,0x43
    8000462a:	0ef76063          	bltu	a4,a5,8000470a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000462e:	0c0b0863          	beqz	s6,800046fe <writei+0x10e>
    80004632:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004634:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004638:	5c7d                	li	s8,-1
    8000463a:	a091                	j	8000467e <writei+0x8e>
    8000463c:	020d1d93          	slli	s11,s10,0x20
    80004640:	020ddd93          	srli	s11,s11,0x20
    80004644:	05848513          	addi	a0,s1,88
    80004648:	86ee                	mv	a3,s11
    8000464a:	8652                	mv	a2,s4
    8000464c:	85de                	mv	a1,s7
    8000464e:	953a                	add	a0,a0,a4
    80004650:	ffffe097          	auipc	ra,0xffffe
    80004654:	48e080e7          	jalr	1166(ra) # 80002ade <either_copyin>
    80004658:	07850263          	beq	a0,s8,800046bc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000465c:	8526                	mv	a0,s1
    8000465e:	00000097          	auipc	ra,0x0
    80004662:	788080e7          	jalr	1928(ra) # 80004de6 <log_write>
    brelse(bp);
    80004666:	8526                	mv	a0,s1
    80004668:	fffff097          	auipc	ra,0xfffff
    8000466c:	4f4080e7          	jalr	1268(ra) # 80003b5c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004670:	013d09bb          	addw	s3,s10,s3
    80004674:	012d093b          	addw	s2,s10,s2
    80004678:	9a6e                	add	s4,s4,s11
    8000467a:	0569f663          	bgeu	s3,s6,800046c6 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000467e:	00a9559b          	srliw	a1,s2,0xa
    80004682:	8556                	mv	a0,s5
    80004684:	fffff097          	auipc	ra,0xfffff
    80004688:	79c080e7          	jalr	1948(ra) # 80003e20 <bmap>
    8000468c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004690:	c99d                	beqz	a1,800046c6 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004692:	000aa503          	lw	a0,0(s5)
    80004696:	fffff097          	auipc	ra,0xfffff
    8000469a:	396080e7          	jalr	918(ra) # 80003a2c <bread>
    8000469e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800046a0:	3ff97713          	andi	a4,s2,1023
    800046a4:	40ec87bb          	subw	a5,s9,a4
    800046a8:	413b06bb          	subw	a3,s6,s3
    800046ac:	8d3e                	mv	s10,a5
    800046ae:	2781                	sext.w	a5,a5
    800046b0:	0006861b          	sext.w	a2,a3
    800046b4:	f8f674e3          	bgeu	a2,a5,8000463c <writei+0x4c>
    800046b8:	8d36                	mv	s10,a3
    800046ba:	b749                	j	8000463c <writei+0x4c>
      brelse(bp);
    800046bc:	8526                	mv	a0,s1
    800046be:	fffff097          	auipc	ra,0xfffff
    800046c2:	49e080e7          	jalr	1182(ra) # 80003b5c <brelse>
  }

  if(off > ip->size)
    800046c6:	04caa783          	lw	a5,76(s5)
    800046ca:	0127f463          	bgeu	a5,s2,800046d2 <writei+0xe2>
    ip->size = off;
    800046ce:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800046d2:	8556                	mv	a0,s5
    800046d4:	00000097          	auipc	ra,0x0
    800046d8:	aa4080e7          	jalr	-1372(ra) # 80004178 <iupdate>

  return tot;
    800046dc:	0009851b          	sext.w	a0,s3
}
    800046e0:	70a6                	ld	ra,104(sp)
    800046e2:	7406                	ld	s0,96(sp)
    800046e4:	64e6                	ld	s1,88(sp)
    800046e6:	6946                	ld	s2,80(sp)
    800046e8:	69a6                	ld	s3,72(sp)
    800046ea:	6a06                	ld	s4,64(sp)
    800046ec:	7ae2                	ld	s5,56(sp)
    800046ee:	7b42                	ld	s6,48(sp)
    800046f0:	7ba2                	ld	s7,40(sp)
    800046f2:	7c02                	ld	s8,32(sp)
    800046f4:	6ce2                	ld	s9,24(sp)
    800046f6:	6d42                	ld	s10,16(sp)
    800046f8:	6da2                	ld	s11,8(sp)
    800046fa:	6165                	addi	sp,sp,112
    800046fc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800046fe:	89da                	mv	s3,s6
    80004700:	bfc9                	j	800046d2 <writei+0xe2>
    return -1;
    80004702:	557d                	li	a0,-1
}
    80004704:	8082                	ret
    return -1;
    80004706:	557d                	li	a0,-1
    80004708:	bfe1                	j	800046e0 <writei+0xf0>
    return -1;
    8000470a:	557d                	li	a0,-1
    8000470c:	bfd1                	j	800046e0 <writei+0xf0>

000000008000470e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000470e:	1141                	addi	sp,sp,-16
    80004710:	e406                	sd	ra,8(sp)
    80004712:	e022                	sd	s0,0(sp)
    80004714:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004716:	4639                	li	a2,14
    80004718:	ffffc097          	auipc	ra,0xffffc
    8000471c:	7ca080e7          	jalr	1994(ra) # 80000ee2 <strncmp>
}
    80004720:	60a2                	ld	ra,8(sp)
    80004722:	6402                	ld	s0,0(sp)
    80004724:	0141                	addi	sp,sp,16
    80004726:	8082                	ret

0000000080004728 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004728:	7139                	addi	sp,sp,-64
    8000472a:	fc06                	sd	ra,56(sp)
    8000472c:	f822                	sd	s0,48(sp)
    8000472e:	f426                	sd	s1,40(sp)
    80004730:	f04a                	sd	s2,32(sp)
    80004732:	ec4e                	sd	s3,24(sp)
    80004734:	e852                	sd	s4,16(sp)
    80004736:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004738:	04451703          	lh	a4,68(a0)
    8000473c:	4785                	li	a5,1
    8000473e:	00f71a63          	bne	a4,a5,80004752 <dirlookup+0x2a>
    80004742:	892a                	mv	s2,a0
    80004744:	89ae                	mv	s3,a1
    80004746:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004748:	457c                	lw	a5,76(a0)
    8000474a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000474c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000474e:	e79d                	bnez	a5,8000477c <dirlookup+0x54>
    80004750:	a8a5                	j	800047c8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004752:	00004517          	auipc	a0,0x4
    80004756:	16650513          	addi	a0,a0,358 # 800088b8 <syscallnames+0x1d8>
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	de6080e7          	jalr	-538(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004762:	00004517          	auipc	a0,0x4
    80004766:	16e50513          	addi	a0,a0,366 # 800088d0 <syscallnames+0x1f0>
    8000476a:	ffffc097          	auipc	ra,0xffffc
    8000476e:	dd6080e7          	jalr	-554(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004772:	24c1                	addiw	s1,s1,16
    80004774:	04c92783          	lw	a5,76(s2)
    80004778:	04f4f763          	bgeu	s1,a5,800047c6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000477c:	4741                	li	a4,16
    8000477e:	86a6                	mv	a3,s1
    80004780:	fc040613          	addi	a2,s0,-64
    80004784:	4581                	li	a1,0
    80004786:	854a                	mv	a0,s2
    80004788:	00000097          	auipc	ra,0x0
    8000478c:	d70080e7          	jalr	-656(ra) # 800044f8 <readi>
    80004790:	47c1                	li	a5,16
    80004792:	fcf518e3          	bne	a0,a5,80004762 <dirlookup+0x3a>
    if(de.inum == 0)
    80004796:	fc045783          	lhu	a5,-64(s0)
    8000479a:	dfe1                	beqz	a5,80004772 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000479c:	fc240593          	addi	a1,s0,-62
    800047a0:	854e                	mv	a0,s3
    800047a2:	00000097          	auipc	ra,0x0
    800047a6:	f6c080e7          	jalr	-148(ra) # 8000470e <namecmp>
    800047aa:	f561                	bnez	a0,80004772 <dirlookup+0x4a>
      if(poff)
    800047ac:	000a0463          	beqz	s4,800047b4 <dirlookup+0x8c>
        *poff = off;
    800047b0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800047b4:	fc045583          	lhu	a1,-64(s0)
    800047b8:	00092503          	lw	a0,0(s2)
    800047bc:	fffff097          	auipc	ra,0xfffff
    800047c0:	74e080e7          	jalr	1870(ra) # 80003f0a <iget>
    800047c4:	a011                	j	800047c8 <dirlookup+0xa0>
  return 0;
    800047c6:	4501                	li	a0,0
}
    800047c8:	70e2                	ld	ra,56(sp)
    800047ca:	7442                	ld	s0,48(sp)
    800047cc:	74a2                	ld	s1,40(sp)
    800047ce:	7902                	ld	s2,32(sp)
    800047d0:	69e2                	ld	s3,24(sp)
    800047d2:	6a42                	ld	s4,16(sp)
    800047d4:	6121                	addi	sp,sp,64
    800047d6:	8082                	ret

00000000800047d8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800047d8:	711d                	addi	sp,sp,-96
    800047da:	ec86                	sd	ra,88(sp)
    800047dc:	e8a2                	sd	s0,80(sp)
    800047de:	e4a6                	sd	s1,72(sp)
    800047e0:	e0ca                	sd	s2,64(sp)
    800047e2:	fc4e                	sd	s3,56(sp)
    800047e4:	f852                	sd	s4,48(sp)
    800047e6:	f456                	sd	s5,40(sp)
    800047e8:	f05a                	sd	s6,32(sp)
    800047ea:	ec5e                	sd	s7,24(sp)
    800047ec:	e862                	sd	s8,16(sp)
    800047ee:	e466                	sd	s9,8(sp)
    800047f0:	e06a                	sd	s10,0(sp)
    800047f2:	1080                	addi	s0,sp,96
    800047f4:	84aa                	mv	s1,a0
    800047f6:	8b2e                	mv	s6,a1
    800047f8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800047fa:	00054703          	lbu	a4,0(a0)
    800047fe:	02f00793          	li	a5,47
    80004802:	02f70363          	beq	a4,a5,80004828 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004806:	ffffd097          	auipc	ra,0xffffd
    8000480a:	35a080e7          	jalr	858(ra) # 80001b60 <myproc>
    8000480e:	15053503          	ld	a0,336(a0)
    80004812:	00000097          	auipc	ra,0x0
    80004816:	9f4080e7          	jalr	-1548(ra) # 80004206 <idup>
    8000481a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000481c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004820:	4cb5                	li	s9,13
  len = path - s;
    80004822:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004824:	4c05                	li	s8,1
    80004826:	a87d                	j	800048e4 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004828:	4585                	li	a1,1
    8000482a:	4505                	li	a0,1
    8000482c:	fffff097          	auipc	ra,0xfffff
    80004830:	6de080e7          	jalr	1758(ra) # 80003f0a <iget>
    80004834:	8a2a                	mv	s4,a0
    80004836:	b7dd                	j	8000481c <namex+0x44>
      iunlockput(ip);
    80004838:	8552                	mv	a0,s4
    8000483a:	00000097          	auipc	ra,0x0
    8000483e:	c6c080e7          	jalr	-916(ra) # 800044a6 <iunlockput>
      return 0;
    80004842:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004844:	8552                	mv	a0,s4
    80004846:	60e6                	ld	ra,88(sp)
    80004848:	6446                	ld	s0,80(sp)
    8000484a:	64a6                	ld	s1,72(sp)
    8000484c:	6906                	ld	s2,64(sp)
    8000484e:	79e2                	ld	s3,56(sp)
    80004850:	7a42                	ld	s4,48(sp)
    80004852:	7aa2                	ld	s5,40(sp)
    80004854:	7b02                	ld	s6,32(sp)
    80004856:	6be2                	ld	s7,24(sp)
    80004858:	6c42                	ld	s8,16(sp)
    8000485a:	6ca2                	ld	s9,8(sp)
    8000485c:	6d02                	ld	s10,0(sp)
    8000485e:	6125                	addi	sp,sp,96
    80004860:	8082                	ret
      iunlock(ip);
    80004862:	8552                	mv	a0,s4
    80004864:	00000097          	auipc	ra,0x0
    80004868:	aa2080e7          	jalr	-1374(ra) # 80004306 <iunlock>
      return ip;
    8000486c:	bfe1                	j	80004844 <namex+0x6c>
      iunlockput(ip);
    8000486e:	8552                	mv	a0,s4
    80004870:	00000097          	auipc	ra,0x0
    80004874:	c36080e7          	jalr	-970(ra) # 800044a6 <iunlockput>
      return 0;
    80004878:	8a4e                	mv	s4,s3
    8000487a:	b7e9                	j	80004844 <namex+0x6c>
  len = path - s;
    8000487c:	40998633          	sub	a2,s3,s1
    80004880:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004884:	09acd863          	bge	s9,s10,80004914 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004888:	4639                	li	a2,14
    8000488a:	85a6                	mv	a1,s1
    8000488c:	8556                	mv	a0,s5
    8000488e:	ffffc097          	auipc	ra,0xffffc
    80004892:	5e0080e7          	jalr	1504(ra) # 80000e6e <memmove>
    80004896:	84ce                	mv	s1,s3
  while(*path == '/')
    80004898:	0004c783          	lbu	a5,0(s1)
    8000489c:	01279763          	bne	a5,s2,800048aa <namex+0xd2>
    path++;
    800048a0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800048a2:	0004c783          	lbu	a5,0(s1)
    800048a6:	ff278de3          	beq	a5,s2,800048a0 <namex+0xc8>
    ilock(ip);
    800048aa:	8552                	mv	a0,s4
    800048ac:	00000097          	auipc	ra,0x0
    800048b0:	998080e7          	jalr	-1640(ra) # 80004244 <ilock>
    if(ip->type != T_DIR){
    800048b4:	044a1783          	lh	a5,68(s4)
    800048b8:	f98790e3          	bne	a5,s8,80004838 <namex+0x60>
    if(nameiparent && *path == '\0'){
    800048bc:	000b0563          	beqz	s6,800048c6 <namex+0xee>
    800048c0:	0004c783          	lbu	a5,0(s1)
    800048c4:	dfd9                	beqz	a5,80004862 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800048c6:	865e                	mv	a2,s7
    800048c8:	85d6                	mv	a1,s5
    800048ca:	8552                	mv	a0,s4
    800048cc:	00000097          	auipc	ra,0x0
    800048d0:	e5c080e7          	jalr	-420(ra) # 80004728 <dirlookup>
    800048d4:	89aa                	mv	s3,a0
    800048d6:	dd41                	beqz	a0,8000486e <namex+0x96>
    iunlockput(ip);
    800048d8:	8552                	mv	a0,s4
    800048da:	00000097          	auipc	ra,0x0
    800048de:	bcc080e7          	jalr	-1076(ra) # 800044a6 <iunlockput>
    ip = next;
    800048e2:	8a4e                	mv	s4,s3
  while(*path == '/')
    800048e4:	0004c783          	lbu	a5,0(s1)
    800048e8:	01279763          	bne	a5,s2,800048f6 <namex+0x11e>
    path++;
    800048ec:	0485                	addi	s1,s1,1
  while(*path == '/')
    800048ee:	0004c783          	lbu	a5,0(s1)
    800048f2:	ff278de3          	beq	a5,s2,800048ec <namex+0x114>
  if(*path == 0)
    800048f6:	cb9d                	beqz	a5,8000492c <namex+0x154>
  while(*path != '/' && *path != 0)
    800048f8:	0004c783          	lbu	a5,0(s1)
    800048fc:	89a6                	mv	s3,s1
  len = path - s;
    800048fe:	8d5e                	mv	s10,s7
    80004900:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004902:	01278963          	beq	a5,s2,80004914 <namex+0x13c>
    80004906:	dbbd                	beqz	a5,8000487c <namex+0xa4>
    path++;
    80004908:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000490a:	0009c783          	lbu	a5,0(s3)
    8000490e:	ff279ce3          	bne	a5,s2,80004906 <namex+0x12e>
    80004912:	b7ad                	j	8000487c <namex+0xa4>
    memmove(name, s, len);
    80004914:	2601                	sext.w	a2,a2
    80004916:	85a6                	mv	a1,s1
    80004918:	8556                	mv	a0,s5
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	554080e7          	jalr	1364(ra) # 80000e6e <memmove>
    name[len] = 0;
    80004922:	9d56                	add	s10,s10,s5
    80004924:	000d0023          	sb	zero,0(s10)
    80004928:	84ce                	mv	s1,s3
    8000492a:	b7bd                	j	80004898 <namex+0xc0>
  if(nameiparent){
    8000492c:	f00b0ce3          	beqz	s6,80004844 <namex+0x6c>
    iput(ip);
    80004930:	8552                	mv	a0,s4
    80004932:	00000097          	auipc	ra,0x0
    80004936:	acc080e7          	jalr	-1332(ra) # 800043fe <iput>
    return 0;
    8000493a:	4a01                	li	s4,0
    8000493c:	b721                	j	80004844 <namex+0x6c>

000000008000493e <dirlink>:
{
    8000493e:	7139                	addi	sp,sp,-64
    80004940:	fc06                	sd	ra,56(sp)
    80004942:	f822                	sd	s0,48(sp)
    80004944:	f426                	sd	s1,40(sp)
    80004946:	f04a                	sd	s2,32(sp)
    80004948:	ec4e                	sd	s3,24(sp)
    8000494a:	e852                	sd	s4,16(sp)
    8000494c:	0080                	addi	s0,sp,64
    8000494e:	892a                	mv	s2,a0
    80004950:	8a2e                	mv	s4,a1
    80004952:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004954:	4601                	li	a2,0
    80004956:	00000097          	auipc	ra,0x0
    8000495a:	dd2080e7          	jalr	-558(ra) # 80004728 <dirlookup>
    8000495e:	e93d                	bnez	a0,800049d4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004960:	04c92483          	lw	s1,76(s2)
    80004964:	c49d                	beqz	s1,80004992 <dirlink+0x54>
    80004966:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004968:	4741                	li	a4,16
    8000496a:	86a6                	mv	a3,s1
    8000496c:	fc040613          	addi	a2,s0,-64
    80004970:	4581                	li	a1,0
    80004972:	854a                	mv	a0,s2
    80004974:	00000097          	auipc	ra,0x0
    80004978:	b84080e7          	jalr	-1148(ra) # 800044f8 <readi>
    8000497c:	47c1                	li	a5,16
    8000497e:	06f51163          	bne	a0,a5,800049e0 <dirlink+0xa2>
    if(de.inum == 0)
    80004982:	fc045783          	lhu	a5,-64(s0)
    80004986:	c791                	beqz	a5,80004992 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004988:	24c1                	addiw	s1,s1,16
    8000498a:	04c92783          	lw	a5,76(s2)
    8000498e:	fcf4ede3          	bltu	s1,a5,80004968 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004992:	4639                	li	a2,14
    80004994:	85d2                	mv	a1,s4
    80004996:	fc240513          	addi	a0,s0,-62
    8000499a:	ffffc097          	auipc	ra,0xffffc
    8000499e:	584080e7          	jalr	1412(ra) # 80000f1e <strncpy>
  de.inum = inum;
    800049a2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800049a6:	4741                	li	a4,16
    800049a8:	86a6                	mv	a3,s1
    800049aa:	fc040613          	addi	a2,s0,-64
    800049ae:	4581                	li	a1,0
    800049b0:	854a                	mv	a0,s2
    800049b2:	00000097          	auipc	ra,0x0
    800049b6:	c3e080e7          	jalr	-962(ra) # 800045f0 <writei>
    800049ba:	1541                	addi	a0,a0,-16
    800049bc:	00a03533          	snez	a0,a0
    800049c0:	40a00533          	neg	a0,a0
}
    800049c4:	70e2                	ld	ra,56(sp)
    800049c6:	7442                	ld	s0,48(sp)
    800049c8:	74a2                	ld	s1,40(sp)
    800049ca:	7902                	ld	s2,32(sp)
    800049cc:	69e2                	ld	s3,24(sp)
    800049ce:	6a42                	ld	s4,16(sp)
    800049d0:	6121                	addi	sp,sp,64
    800049d2:	8082                	ret
    iput(ip);
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	a2a080e7          	jalr	-1494(ra) # 800043fe <iput>
    return -1;
    800049dc:	557d                	li	a0,-1
    800049de:	b7dd                	j	800049c4 <dirlink+0x86>
      panic("dirlink read");
    800049e0:	00004517          	auipc	a0,0x4
    800049e4:	f0050513          	addi	a0,a0,-256 # 800088e0 <syscallnames+0x200>
    800049e8:	ffffc097          	auipc	ra,0xffffc
    800049ec:	b58080e7          	jalr	-1192(ra) # 80000540 <panic>

00000000800049f0 <namei>:

struct inode*
namei(char *path)
{
    800049f0:	1101                	addi	sp,sp,-32
    800049f2:	ec06                	sd	ra,24(sp)
    800049f4:	e822                	sd	s0,16(sp)
    800049f6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800049f8:	fe040613          	addi	a2,s0,-32
    800049fc:	4581                	li	a1,0
    800049fe:	00000097          	auipc	ra,0x0
    80004a02:	dda080e7          	jalr	-550(ra) # 800047d8 <namex>
}
    80004a06:	60e2                	ld	ra,24(sp)
    80004a08:	6442                	ld	s0,16(sp)
    80004a0a:	6105                	addi	sp,sp,32
    80004a0c:	8082                	ret

0000000080004a0e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004a0e:	1141                	addi	sp,sp,-16
    80004a10:	e406                	sd	ra,8(sp)
    80004a12:	e022                	sd	s0,0(sp)
    80004a14:	0800                	addi	s0,sp,16
    80004a16:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004a18:	4585                	li	a1,1
    80004a1a:	00000097          	auipc	ra,0x0
    80004a1e:	dbe080e7          	jalr	-578(ra) # 800047d8 <namex>
}
    80004a22:	60a2                	ld	ra,8(sp)
    80004a24:	6402                	ld	s0,0(sp)
    80004a26:	0141                	addi	sp,sp,16
    80004a28:	8082                	ret

0000000080004a2a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004a2a:	1101                	addi	sp,sp,-32
    80004a2c:	ec06                	sd	ra,24(sp)
    80004a2e:	e822                	sd	s0,16(sp)
    80004a30:	e426                	sd	s1,8(sp)
    80004a32:	e04a                	sd	s2,0(sp)
    80004a34:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004a36:	0023e917          	auipc	s2,0x23e
    80004a3a:	46a90913          	addi	s2,s2,1130 # 80242ea0 <log>
    80004a3e:	01892583          	lw	a1,24(s2)
    80004a42:	02892503          	lw	a0,40(s2)
    80004a46:	fffff097          	auipc	ra,0xfffff
    80004a4a:	fe6080e7          	jalr	-26(ra) # 80003a2c <bread>
    80004a4e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004a50:	02c92683          	lw	a3,44(s2)
    80004a54:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004a56:	02d05863          	blez	a3,80004a86 <write_head+0x5c>
    80004a5a:	0023e797          	auipc	a5,0x23e
    80004a5e:	47678793          	addi	a5,a5,1142 # 80242ed0 <log+0x30>
    80004a62:	05c50713          	addi	a4,a0,92
    80004a66:	36fd                	addiw	a3,a3,-1
    80004a68:	02069613          	slli	a2,a3,0x20
    80004a6c:	01e65693          	srli	a3,a2,0x1e
    80004a70:	0023e617          	auipc	a2,0x23e
    80004a74:	46460613          	addi	a2,a2,1124 # 80242ed4 <log+0x34>
    80004a78:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004a7a:	4390                	lw	a2,0(a5)
    80004a7c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004a7e:	0791                	addi	a5,a5,4
    80004a80:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004a82:	fed79ce3          	bne	a5,a3,80004a7a <write_head+0x50>
  }
  bwrite(buf);
    80004a86:	8526                	mv	a0,s1
    80004a88:	fffff097          	auipc	ra,0xfffff
    80004a8c:	096080e7          	jalr	150(ra) # 80003b1e <bwrite>
  brelse(buf);
    80004a90:	8526                	mv	a0,s1
    80004a92:	fffff097          	auipc	ra,0xfffff
    80004a96:	0ca080e7          	jalr	202(ra) # 80003b5c <brelse>
}
    80004a9a:	60e2                	ld	ra,24(sp)
    80004a9c:	6442                	ld	s0,16(sp)
    80004a9e:	64a2                	ld	s1,8(sp)
    80004aa0:	6902                	ld	s2,0(sp)
    80004aa2:	6105                	addi	sp,sp,32
    80004aa4:	8082                	ret

0000000080004aa6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004aa6:	0023e797          	auipc	a5,0x23e
    80004aaa:	4267a783          	lw	a5,1062(a5) # 80242ecc <log+0x2c>
    80004aae:	0af05d63          	blez	a5,80004b68 <install_trans+0xc2>
{
    80004ab2:	7139                	addi	sp,sp,-64
    80004ab4:	fc06                	sd	ra,56(sp)
    80004ab6:	f822                	sd	s0,48(sp)
    80004ab8:	f426                	sd	s1,40(sp)
    80004aba:	f04a                	sd	s2,32(sp)
    80004abc:	ec4e                	sd	s3,24(sp)
    80004abe:	e852                	sd	s4,16(sp)
    80004ac0:	e456                	sd	s5,8(sp)
    80004ac2:	e05a                	sd	s6,0(sp)
    80004ac4:	0080                	addi	s0,sp,64
    80004ac6:	8b2a                	mv	s6,a0
    80004ac8:	0023ea97          	auipc	s5,0x23e
    80004acc:	408a8a93          	addi	s5,s5,1032 # 80242ed0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ad0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004ad2:	0023e997          	auipc	s3,0x23e
    80004ad6:	3ce98993          	addi	s3,s3,974 # 80242ea0 <log>
    80004ada:	a00d                	j	80004afc <install_trans+0x56>
    brelse(lbuf);
    80004adc:	854a                	mv	a0,s2
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	07e080e7          	jalr	126(ra) # 80003b5c <brelse>
    brelse(dbuf);
    80004ae6:	8526                	mv	a0,s1
    80004ae8:	fffff097          	auipc	ra,0xfffff
    80004aec:	074080e7          	jalr	116(ra) # 80003b5c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004af0:	2a05                	addiw	s4,s4,1
    80004af2:	0a91                	addi	s5,s5,4
    80004af4:	02c9a783          	lw	a5,44(s3)
    80004af8:	04fa5e63          	bge	s4,a5,80004b54 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004afc:	0189a583          	lw	a1,24(s3)
    80004b00:	014585bb          	addw	a1,a1,s4
    80004b04:	2585                	addiw	a1,a1,1
    80004b06:	0289a503          	lw	a0,40(s3)
    80004b0a:	fffff097          	auipc	ra,0xfffff
    80004b0e:	f22080e7          	jalr	-222(ra) # 80003a2c <bread>
    80004b12:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004b14:	000aa583          	lw	a1,0(s5)
    80004b18:	0289a503          	lw	a0,40(s3)
    80004b1c:	fffff097          	auipc	ra,0xfffff
    80004b20:	f10080e7          	jalr	-240(ra) # 80003a2c <bread>
    80004b24:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004b26:	40000613          	li	a2,1024
    80004b2a:	05890593          	addi	a1,s2,88
    80004b2e:	05850513          	addi	a0,a0,88
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	33c080e7          	jalr	828(ra) # 80000e6e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	fffff097          	auipc	ra,0xfffff
    80004b40:	fe2080e7          	jalr	-30(ra) # 80003b1e <bwrite>
    if(recovering == 0)
    80004b44:	f80b1ce3          	bnez	s6,80004adc <install_trans+0x36>
      bunpin(dbuf);
    80004b48:	8526                	mv	a0,s1
    80004b4a:	fffff097          	auipc	ra,0xfffff
    80004b4e:	0ec080e7          	jalr	236(ra) # 80003c36 <bunpin>
    80004b52:	b769                	j	80004adc <install_trans+0x36>
}
    80004b54:	70e2                	ld	ra,56(sp)
    80004b56:	7442                	ld	s0,48(sp)
    80004b58:	74a2                	ld	s1,40(sp)
    80004b5a:	7902                	ld	s2,32(sp)
    80004b5c:	69e2                	ld	s3,24(sp)
    80004b5e:	6a42                	ld	s4,16(sp)
    80004b60:	6aa2                	ld	s5,8(sp)
    80004b62:	6b02                	ld	s6,0(sp)
    80004b64:	6121                	addi	sp,sp,64
    80004b66:	8082                	ret
    80004b68:	8082                	ret

0000000080004b6a <initlog>:
{
    80004b6a:	7179                	addi	sp,sp,-48
    80004b6c:	f406                	sd	ra,40(sp)
    80004b6e:	f022                	sd	s0,32(sp)
    80004b70:	ec26                	sd	s1,24(sp)
    80004b72:	e84a                	sd	s2,16(sp)
    80004b74:	e44e                	sd	s3,8(sp)
    80004b76:	1800                	addi	s0,sp,48
    80004b78:	892a                	mv	s2,a0
    80004b7a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004b7c:	0023e497          	auipc	s1,0x23e
    80004b80:	32448493          	addi	s1,s1,804 # 80242ea0 <log>
    80004b84:	00004597          	auipc	a1,0x4
    80004b88:	d6c58593          	addi	a1,a1,-660 # 800088f0 <syscallnames+0x210>
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	0f8080e7          	jalr	248(ra) # 80000c86 <initlock>
  log.start = sb->logstart;
    80004b96:	0149a583          	lw	a1,20(s3)
    80004b9a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004b9c:	0109a783          	lw	a5,16(s3)
    80004ba0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004ba2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004ba6:	854a                	mv	a0,s2
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	e84080e7          	jalr	-380(ra) # 80003a2c <bread>
  log.lh.n = lh->n;
    80004bb0:	4d34                	lw	a3,88(a0)
    80004bb2:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004bb4:	02d05663          	blez	a3,80004be0 <initlog+0x76>
    80004bb8:	05c50793          	addi	a5,a0,92
    80004bbc:	0023e717          	auipc	a4,0x23e
    80004bc0:	31470713          	addi	a4,a4,788 # 80242ed0 <log+0x30>
    80004bc4:	36fd                	addiw	a3,a3,-1
    80004bc6:	02069613          	slli	a2,a3,0x20
    80004bca:	01e65693          	srli	a3,a2,0x1e
    80004bce:	06050613          	addi	a2,a0,96
    80004bd2:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004bd4:	4390                	lw	a2,0(a5)
    80004bd6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004bd8:	0791                	addi	a5,a5,4
    80004bda:	0711                	addi	a4,a4,4
    80004bdc:	fed79ce3          	bne	a5,a3,80004bd4 <initlog+0x6a>
  brelse(buf);
    80004be0:	fffff097          	auipc	ra,0xfffff
    80004be4:	f7c080e7          	jalr	-132(ra) # 80003b5c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004be8:	4505                	li	a0,1
    80004bea:	00000097          	auipc	ra,0x0
    80004bee:	ebc080e7          	jalr	-324(ra) # 80004aa6 <install_trans>
  log.lh.n = 0;
    80004bf2:	0023e797          	auipc	a5,0x23e
    80004bf6:	2c07ad23          	sw	zero,730(a5) # 80242ecc <log+0x2c>
  write_head(); // clear the log
    80004bfa:	00000097          	auipc	ra,0x0
    80004bfe:	e30080e7          	jalr	-464(ra) # 80004a2a <write_head>
}
    80004c02:	70a2                	ld	ra,40(sp)
    80004c04:	7402                	ld	s0,32(sp)
    80004c06:	64e2                	ld	s1,24(sp)
    80004c08:	6942                	ld	s2,16(sp)
    80004c0a:	69a2                	ld	s3,8(sp)
    80004c0c:	6145                	addi	sp,sp,48
    80004c0e:	8082                	ret

0000000080004c10 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004c10:	1101                	addi	sp,sp,-32
    80004c12:	ec06                	sd	ra,24(sp)
    80004c14:	e822                	sd	s0,16(sp)
    80004c16:	e426                	sd	s1,8(sp)
    80004c18:	e04a                	sd	s2,0(sp)
    80004c1a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004c1c:	0023e517          	auipc	a0,0x23e
    80004c20:	28450513          	addi	a0,a0,644 # 80242ea0 <log>
    80004c24:	ffffc097          	auipc	ra,0xffffc
    80004c28:	0f2080e7          	jalr	242(ra) # 80000d16 <acquire>
  while(1){
    if(log.committing){
    80004c2c:	0023e497          	auipc	s1,0x23e
    80004c30:	27448493          	addi	s1,s1,628 # 80242ea0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004c34:	4979                	li	s2,30
    80004c36:	a039                	j	80004c44 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004c38:	85a6                	mv	a1,s1
    80004c3a:	8526                	mv	a0,s1
    80004c3c:	ffffe097          	auipc	ra,0xffffe
    80004c40:	85a080e7          	jalr	-1958(ra) # 80002496 <sleep>
    if(log.committing){
    80004c44:	50dc                	lw	a5,36(s1)
    80004c46:	fbed                	bnez	a5,80004c38 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004c48:	5098                	lw	a4,32(s1)
    80004c4a:	2705                	addiw	a4,a4,1
    80004c4c:	0007069b          	sext.w	a3,a4
    80004c50:	0027179b          	slliw	a5,a4,0x2
    80004c54:	9fb9                	addw	a5,a5,a4
    80004c56:	0017979b          	slliw	a5,a5,0x1
    80004c5a:	54d8                	lw	a4,44(s1)
    80004c5c:	9fb9                	addw	a5,a5,a4
    80004c5e:	00f95963          	bge	s2,a5,80004c70 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004c62:	85a6                	mv	a1,s1
    80004c64:	8526                	mv	a0,s1
    80004c66:	ffffe097          	auipc	ra,0xffffe
    80004c6a:	830080e7          	jalr	-2000(ra) # 80002496 <sleep>
    80004c6e:	bfd9                	j	80004c44 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004c70:	0023e517          	auipc	a0,0x23e
    80004c74:	23050513          	addi	a0,a0,560 # 80242ea0 <log>
    80004c78:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	150080e7          	jalr	336(ra) # 80000dca <release>
      break;
    }
  }
}
    80004c82:	60e2                	ld	ra,24(sp)
    80004c84:	6442                	ld	s0,16(sp)
    80004c86:	64a2                	ld	s1,8(sp)
    80004c88:	6902                	ld	s2,0(sp)
    80004c8a:	6105                	addi	sp,sp,32
    80004c8c:	8082                	ret

0000000080004c8e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004c8e:	7139                	addi	sp,sp,-64
    80004c90:	fc06                	sd	ra,56(sp)
    80004c92:	f822                	sd	s0,48(sp)
    80004c94:	f426                	sd	s1,40(sp)
    80004c96:	f04a                	sd	s2,32(sp)
    80004c98:	ec4e                	sd	s3,24(sp)
    80004c9a:	e852                	sd	s4,16(sp)
    80004c9c:	e456                	sd	s5,8(sp)
    80004c9e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004ca0:	0023e497          	auipc	s1,0x23e
    80004ca4:	20048493          	addi	s1,s1,512 # 80242ea0 <log>
    80004ca8:	8526                	mv	a0,s1
    80004caa:	ffffc097          	auipc	ra,0xffffc
    80004cae:	06c080e7          	jalr	108(ra) # 80000d16 <acquire>
  log.outstanding -= 1;
    80004cb2:	509c                	lw	a5,32(s1)
    80004cb4:	37fd                	addiw	a5,a5,-1
    80004cb6:	0007891b          	sext.w	s2,a5
    80004cba:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004cbc:	50dc                	lw	a5,36(s1)
    80004cbe:	e7b9                	bnez	a5,80004d0c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004cc0:	04091e63          	bnez	s2,80004d1c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004cc4:	0023e497          	auipc	s1,0x23e
    80004cc8:	1dc48493          	addi	s1,s1,476 # 80242ea0 <log>
    80004ccc:	4785                	li	a5,1
    80004cce:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004cd0:	8526                	mv	a0,s1
    80004cd2:	ffffc097          	auipc	ra,0xffffc
    80004cd6:	0f8080e7          	jalr	248(ra) # 80000dca <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004cda:	54dc                	lw	a5,44(s1)
    80004cdc:	06f04763          	bgtz	a5,80004d4a <end_op+0xbc>
    acquire(&log.lock);
    80004ce0:	0023e497          	auipc	s1,0x23e
    80004ce4:	1c048493          	addi	s1,s1,448 # 80242ea0 <log>
    80004ce8:	8526                	mv	a0,s1
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	02c080e7          	jalr	44(ra) # 80000d16 <acquire>
    log.committing = 0;
    80004cf2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004cf6:	8526                	mv	a0,s1
    80004cf8:	ffffe097          	auipc	ra,0xffffe
    80004cfc:	952080e7          	jalr	-1710(ra) # 8000264a <wakeup>
    release(&log.lock);
    80004d00:	8526                	mv	a0,s1
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	0c8080e7          	jalr	200(ra) # 80000dca <release>
}
    80004d0a:	a03d                	j	80004d38 <end_op+0xaa>
    panic("log.committing");
    80004d0c:	00004517          	auipc	a0,0x4
    80004d10:	bec50513          	addi	a0,a0,-1044 # 800088f8 <syscallnames+0x218>
    80004d14:	ffffc097          	auipc	ra,0xffffc
    80004d18:	82c080e7          	jalr	-2004(ra) # 80000540 <panic>
    wakeup(&log);
    80004d1c:	0023e497          	auipc	s1,0x23e
    80004d20:	18448493          	addi	s1,s1,388 # 80242ea0 <log>
    80004d24:	8526                	mv	a0,s1
    80004d26:	ffffe097          	auipc	ra,0xffffe
    80004d2a:	924080e7          	jalr	-1756(ra) # 8000264a <wakeup>
  release(&log.lock);
    80004d2e:	8526                	mv	a0,s1
    80004d30:	ffffc097          	auipc	ra,0xffffc
    80004d34:	09a080e7          	jalr	154(ra) # 80000dca <release>
}
    80004d38:	70e2                	ld	ra,56(sp)
    80004d3a:	7442                	ld	s0,48(sp)
    80004d3c:	74a2                	ld	s1,40(sp)
    80004d3e:	7902                	ld	s2,32(sp)
    80004d40:	69e2                	ld	s3,24(sp)
    80004d42:	6a42                	ld	s4,16(sp)
    80004d44:	6aa2                	ld	s5,8(sp)
    80004d46:	6121                	addi	sp,sp,64
    80004d48:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d4a:	0023ea97          	auipc	s5,0x23e
    80004d4e:	186a8a93          	addi	s5,s5,390 # 80242ed0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004d52:	0023ea17          	auipc	s4,0x23e
    80004d56:	14ea0a13          	addi	s4,s4,334 # 80242ea0 <log>
    80004d5a:	018a2583          	lw	a1,24(s4)
    80004d5e:	012585bb          	addw	a1,a1,s2
    80004d62:	2585                	addiw	a1,a1,1
    80004d64:	028a2503          	lw	a0,40(s4)
    80004d68:	fffff097          	auipc	ra,0xfffff
    80004d6c:	cc4080e7          	jalr	-828(ra) # 80003a2c <bread>
    80004d70:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004d72:	000aa583          	lw	a1,0(s5)
    80004d76:	028a2503          	lw	a0,40(s4)
    80004d7a:	fffff097          	auipc	ra,0xfffff
    80004d7e:	cb2080e7          	jalr	-846(ra) # 80003a2c <bread>
    80004d82:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004d84:	40000613          	li	a2,1024
    80004d88:	05850593          	addi	a1,a0,88
    80004d8c:	05848513          	addi	a0,s1,88
    80004d90:	ffffc097          	auipc	ra,0xffffc
    80004d94:	0de080e7          	jalr	222(ra) # 80000e6e <memmove>
    bwrite(to);  // write the log
    80004d98:	8526                	mv	a0,s1
    80004d9a:	fffff097          	auipc	ra,0xfffff
    80004d9e:	d84080e7          	jalr	-636(ra) # 80003b1e <bwrite>
    brelse(from);
    80004da2:	854e                	mv	a0,s3
    80004da4:	fffff097          	auipc	ra,0xfffff
    80004da8:	db8080e7          	jalr	-584(ra) # 80003b5c <brelse>
    brelse(to);
    80004dac:	8526                	mv	a0,s1
    80004dae:	fffff097          	auipc	ra,0xfffff
    80004db2:	dae080e7          	jalr	-594(ra) # 80003b5c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004db6:	2905                	addiw	s2,s2,1
    80004db8:	0a91                	addi	s5,s5,4
    80004dba:	02ca2783          	lw	a5,44(s4)
    80004dbe:	f8f94ee3          	blt	s2,a5,80004d5a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004dc2:	00000097          	auipc	ra,0x0
    80004dc6:	c68080e7          	jalr	-920(ra) # 80004a2a <write_head>
    install_trans(0); // Now install writes to home locations
    80004dca:	4501                	li	a0,0
    80004dcc:	00000097          	auipc	ra,0x0
    80004dd0:	cda080e7          	jalr	-806(ra) # 80004aa6 <install_trans>
    log.lh.n = 0;
    80004dd4:	0023e797          	auipc	a5,0x23e
    80004dd8:	0e07ac23          	sw	zero,248(a5) # 80242ecc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004ddc:	00000097          	auipc	ra,0x0
    80004de0:	c4e080e7          	jalr	-946(ra) # 80004a2a <write_head>
    80004de4:	bdf5                	j	80004ce0 <end_op+0x52>

0000000080004de6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004de6:	1101                	addi	sp,sp,-32
    80004de8:	ec06                	sd	ra,24(sp)
    80004dea:	e822                	sd	s0,16(sp)
    80004dec:	e426                	sd	s1,8(sp)
    80004dee:	e04a                	sd	s2,0(sp)
    80004df0:	1000                	addi	s0,sp,32
    80004df2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004df4:	0023e917          	auipc	s2,0x23e
    80004df8:	0ac90913          	addi	s2,s2,172 # 80242ea0 <log>
    80004dfc:	854a                	mv	a0,s2
    80004dfe:	ffffc097          	auipc	ra,0xffffc
    80004e02:	f18080e7          	jalr	-232(ra) # 80000d16 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004e06:	02c92603          	lw	a2,44(s2)
    80004e0a:	47f5                	li	a5,29
    80004e0c:	06c7c563          	blt	a5,a2,80004e76 <log_write+0x90>
    80004e10:	0023e797          	auipc	a5,0x23e
    80004e14:	0ac7a783          	lw	a5,172(a5) # 80242ebc <log+0x1c>
    80004e18:	37fd                	addiw	a5,a5,-1
    80004e1a:	04f65e63          	bge	a2,a5,80004e76 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004e1e:	0023e797          	auipc	a5,0x23e
    80004e22:	0a27a783          	lw	a5,162(a5) # 80242ec0 <log+0x20>
    80004e26:	06f05063          	blez	a5,80004e86 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004e2a:	4781                	li	a5,0
    80004e2c:	06c05563          	blez	a2,80004e96 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004e30:	44cc                	lw	a1,12(s1)
    80004e32:	0023e717          	auipc	a4,0x23e
    80004e36:	09e70713          	addi	a4,a4,158 # 80242ed0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004e3a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004e3c:	4314                	lw	a3,0(a4)
    80004e3e:	04b68c63          	beq	a3,a1,80004e96 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004e42:	2785                	addiw	a5,a5,1
    80004e44:	0711                	addi	a4,a4,4
    80004e46:	fef61be3          	bne	a2,a5,80004e3c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004e4a:	0621                	addi	a2,a2,8
    80004e4c:	060a                	slli	a2,a2,0x2
    80004e4e:	0023e797          	auipc	a5,0x23e
    80004e52:	05278793          	addi	a5,a5,82 # 80242ea0 <log>
    80004e56:	97b2                	add	a5,a5,a2
    80004e58:	44d8                	lw	a4,12(s1)
    80004e5a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004e5c:	8526                	mv	a0,s1
    80004e5e:	fffff097          	auipc	ra,0xfffff
    80004e62:	d9c080e7          	jalr	-612(ra) # 80003bfa <bpin>
    log.lh.n++;
    80004e66:	0023e717          	auipc	a4,0x23e
    80004e6a:	03a70713          	addi	a4,a4,58 # 80242ea0 <log>
    80004e6e:	575c                	lw	a5,44(a4)
    80004e70:	2785                	addiw	a5,a5,1
    80004e72:	d75c                	sw	a5,44(a4)
    80004e74:	a82d                	j	80004eae <log_write+0xc8>
    panic("too big a transaction");
    80004e76:	00004517          	auipc	a0,0x4
    80004e7a:	a9250513          	addi	a0,a0,-1390 # 80008908 <syscallnames+0x228>
    80004e7e:	ffffb097          	auipc	ra,0xffffb
    80004e82:	6c2080e7          	jalr	1730(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004e86:	00004517          	auipc	a0,0x4
    80004e8a:	a9a50513          	addi	a0,a0,-1382 # 80008920 <syscallnames+0x240>
    80004e8e:	ffffb097          	auipc	ra,0xffffb
    80004e92:	6b2080e7          	jalr	1714(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004e96:	00878693          	addi	a3,a5,8
    80004e9a:	068a                	slli	a3,a3,0x2
    80004e9c:	0023e717          	auipc	a4,0x23e
    80004ea0:	00470713          	addi	a4,a4,4 # 80242ea0 <log>
    80004ea4:	9736                	add	a4,a4,a3
    80004ea6:	44d4                	lw	a3,12(s1)
    80004ea8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004eaa:	faf609e3          	beq	a2,a5,80004e5c <log_write+0x76>
  }
  release(&log.lock);
    80004eae:	0023e517          	auipc	a0,0x23e
    80004eb2:	ff250513          	addi	a0,a0,-14 # 80242ea0 <log>
    80004eb6:	ffffc097          	auipc	ra,0xffffc
    80004eba:	f14080e7          	jalr	-236(ra) # 80000dca <release>
}
    80004ebe:	60e2                	ld	ra,24(sp)
    80004ec0:	6442                	ld	s0,16(sp)
    80004ec2:	64a2                	ld	s1,8(sp)
    80004ec4:	6902                	ld	s2,0(sp)
    80004ec6:	6105                	addi	sp,sp,32
    80004ec8:	8082                	ret

0000000080004eca <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004eca:	1101                	addi	sp,sp,-32
    80004ecc:	ec06                	sd	ra,24(sp)
    80004ece:	e822                	sd	s0,16(sp)
    80004ed0:	e426                	sd	s1,8(sp)
    80004ed2:	e04a                	sd	s2,0(sp)
    80004ed4:	1000                	addi	s0,sp,32
    80004ed6:	84aa                	mv	s1,a0
    80004ed8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004eda:	00004597          	auipc	a1,0x4
    80004ede:	a6658593          	addi	a1,a1,-1434 # 80008940 <syscallnames+0x260>
    80004ee2:	0521                	addi	a0,a0,8
    80004ee4:	ffffc097          	auipc	ra,0xffffc
    80004ee8:	da2080e7          	jalr	-606(ra) # 80000c86 <initlock>
  lk->name = name;
    80004eec:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004ef0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ef4:	0204a423          	sw	zero,40(s1)
}
    80004ef8:	60e2                	ld	ra,24(sp)
    80004efa:	6442                	ld	s0,16(sp)
    80004efc:	64a2                	ld	s1,8(sp)
    80004efe:	6902                	ld	s2,0(sp)
    80004f00:	6105                	addi	sp,sp,32
    80004f02:	8082                	ret

0000000080004f04 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004f04:	1101                	addi	sp,sp,-32
    80004f06:	ec06                	sd	ra,24(sp)
    80004f08:	e822                	sd	s0,16(sp)
    80004f0a:	e426                	sd	s1,8(sp)
    80004f0c:	e04a                	sd	s2,0(sp)
    80004f0e:	1000                	addi	s0,sp,32
    80004f10:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004f12:	00850913          	addi	s2,a0,8
    80004f16:	854a                	mv	a0,s2
    80004f18:	ffffc097          	auipc	ra,0xffffc
    80004f1c:	dfe080e7          	jalr	-514(ra) # 80000d16 <acquire>
  while (lk->locked) {
    80004f20:	409c                	lw	a5,0(s1)
    80004f22:	cb89                	beqz	a5,80004f34 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004f24:	85ca                	mv	a1,s2
    80004f26:	8526                	mv	a0,s1
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	56e080e7          	jalr	1390(ra) # 80002496 <sleep>
  while (lk->locked) {
    80004f30:	409c                	lw	a5,0(s1)
    80004f32:	fbed                	bnez	a5,80004f24 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004f34:	4785                	li	a5,1
    80004f36:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004f38:	ffffd097          	auipc	ra,0xffffd
    80004f3c:	c28080e7          	jalr	-984(ra) # 80001b60 <myproc>
    80004f40:	591c                	lw	a5,48(a0)
    80004f42:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004f44:	854a                	mv	a0,s2
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	e84080e7          	jalr	-380(ra) # 80000dca <release>
}
    80004f4e:	60e2                	ld	ra,24(sp)
    80004f50:	6442                	ld	s0,16(sp)
    80004f52:	64a2                	ld	s1,8(sp)
    80004f54:	6902                	ld	s2,0(sp)
    80004f56:	6105                	addi	sp,sp,32
    80004f58:	8082                	ret

0000000080004f5a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004f5a:	1101                	addi	sp,sp,-32
    80004f5c:	ec06                	sd	ra,24(sp)
    80004f5e:	e822                	sd	s0,16(sp)
    80004f60:	e426                	sd	s1,8(sp)
    80004f62:	e04a                	sd	s2,0(sp)
    80004f64:	1000                	addi	s0,sp,32
    80004f66:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004f68:	00850913          	addi	s2,a0,8
    80004f6c:	854a                	mv	a0,s2
    80004f6e:	ffffc097          	auipc	ra,0xffffc
    80004f72:	da8080e7          	jalr	-600(ra) # 80000d16 <acquire>
  lk->locked = 0;
    80004f76:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004f7a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004f7e:	8526                	mv	a0,s1
    80004f80:	ffffd097          	auipc	ra,0xffffd
    80004f84:	6ca080e7          	jalr	1738(ra) # 8000264a <wakeup>
  release(&lk->lk);
    80004f88:	854a                	mv	a0,s2
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	e40080e7          	jalr	-448(ra) # 80000dca <release>
}
    80004f92:	60e2                	ld	ra,24(sp)
    80004f94:	6442                	ld	s0,16(sp)
    80004f96:	64a2                	ld	s1,8(sp)
    80004f98:	6902                	ld	s2,0(sp)
    80004f9a:	6105                	addi	sp,sp,32
    80004f9c:	8082                	ret

0000000080004f9e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004f9e:	7179                	addi	sp,sp,-48
    80004fa0:	f406                	sd	ra,40(sp)
    80004fa2:	f022                	sd	s0,32(sp)
    80004fa4:	ec26                	sd	s1,24(sp)
    80004fa6:	e84a                	sd	s2,16(sp)
    80004fa8:	e44e                	sd	s3,8(sp)
    80004faa:	1800                	addi	s0,sp,48
    80004fac:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004fae:	00850913          	addi	s2,a0,8
    80004fb2:	854a                	mv	a0,s2
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	d62080e7          	jalr	-670(ra) # 80000d16 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004fbc:	409c                	lw	a5,0(s1)
    80004fbe:	ef99                	bnez	a5,80004fdc <holdingsleep+0x3e>
    80004fc0:	4481                	li	s1,0
  release(&lk->lk);
    80004fc2:	854a                	mv	a0,s2
    80004fc4:	ffffc097          	auipc	ra,0xffffc
    80004fc8:	e06080e7          	jalr	-506(ra) # 80000dca <release>
  return r;
}
    80004fcc:	8526                	mv	a0,s1
    80004fce:	70a2                	ld	ra,40(sp)
    80004fd0:	7402                	ld	s0,32(sp)
    80004fd2:	64e2                	ld	s1,24(sp)
    80004fd4:	6942                	ld	s2,16(sp)
    80004fd6:	69a2                	ld	s3,8(sp)
    80004fd8:	6145                	addi	sp,sp,48
    80004fda:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004fdc:	0284a983          	lw	s3,40(s1)
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	b80080e7          	jalr	-1152(ra) # 80001b60 <myproc>
    80004fe8:	5904                	lw	s1,48(a0)
    80004fea:	413484b3          	sub	s1,s1,s3
    80004fee:	0014b493          	seqz	s1,s1
    80004ff2:	bfc1                	j	80004fc2 <holdingsleep+0x24>

0000000080004ff4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ff4:	1141                	addi	sp,sp,-16
    80004ff6:	e406                	sd	ra,8(sp)
    80004ff8:	e022                	sd	s0,0(sp)
    80004ffa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ffc:	00004597          	auipc	a1,0x4
    80005000:	95458593          	addi	a1,a1,-1708 # 80008950 <syscallnames+0x270>
    80005004:	0023e517          	auipc	a0,0x23e
    80005008:	fe450513          	addi	a0,a0,-28 # 80242fe8 <ftable>
    8000500c:	ffffc097          	auipc	ra,0xffffc
    80005010:	c7a080e7          	jalr	-902(ra) # 80000c86 <initlock>
}
    80005014:	60a2                	ld	ra,8(sp)
    80005016:	6402                	ld	s0,0(sp)
    80005018:	0141                	addi	sp,sp,16
    8000501a:	8082                	ret

000000008000501c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000501c:	1101                	addi	sp,sp,-32
    8000501e:	ec06                	sd	ra,24(sp)
    80005020:	e822                	sd	s0,16(sp)
    80005022:	e426                	sd	s1,8(sp)
    80005024:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005026:	0023e517          	auipc	a0,0x23e
    8000502a:	fc250513          	addi	a0,a0,-62 # 80242fe8 <ftable>
    8000502e:	ffffc097          	auipc	ra,0xffffc
    80005032:	ce8080e7          	jalr	-792(ra) # 80000d16 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005036:	0023e497          	auipc	s1,0x23e
    8000503a:	fca48493          	addi	s1,s1,-54 # 80243000 <ftable+0x18>
    8000503e:	0023f717          	auipc	a4,0x23f
    80005042:	f6270713          	addi	a4,a4,-158 # 80243fa0 <disk>
    if(f->ref == 0){
    80005046:	40dc                	lw	a5,4(s1)
    80005048:	cf99                	beqz	a5,80005066 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000504a:	02848493          	addi	s1,s1,40
    8000504e:	fee49ce3          	bne	s1,a4,80005046 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005052:	0023e517          	auipc	a0,0x23e
    80005056:	f9650513          	addi	a0,a0,-106 # 80242fe8 <ftable>
    8000505a:	ffffc097          	auipc	ra,0xffffc
    8000505e:	d70080e7          	jalr	-656(ra) # 80000dca <release>
  return 0;
    80005062:	4481                	li	s1,0
    80005064:	a819                	j	8000507a <filealloc+0x5e>
      f->ref = 1;
    80005066:	4785                	li	a5,1
    80005068:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000506a:	0023e517          	auipc	a0,0x23e
    8000506e:	f7e50513          	addi	a0,a0,-130 # 80242fe8 <ftable>
    80005072:	ffffc097          	auipc	ra,0xffffc
    80005076:	d58080e7          	jalr	-680(ra) # 80000dca <release>
}
    8000507a:	8526                	mv	a0,s1
    8000507c:	60e2                	ld	ra,24(sp)
    8000507e:	6442                	ld	s0,16(sp)
    80005080:	64a2                	ld	s1,8(sp)
    80005082:	6105                	addi	sp,sp,32
    80005084:	8082                	ret

0000000080005086 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005086:	1101                	addi	sp,sp,-32
    80005088:	ec06                	sd	ra,24(sp)
    8000508a:	e822                	sd	s0,16(sp)
    8000508c:	e426                	sd	s1,8(sp)
    8000508e:	1000                	addi	s0,sp,32
    80005090:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005092:	0023e517          	auipc	a0,0x23e
    80005096:	f5650513          	addi	a0,a0,-170 # 80242fe8 <ftable>
    8000509a:	ffffc097          	auipc	ra,0xffffc
    8000509e:	c7c080e7          	jalr	-900(ra) # 80000d16 <acquire>
  if(f->ref < 1)
    800050a2:	40dc                	lw	a5,4(s1)
    800050a4:	02f05263          	blez	a5,800050c8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800050a8:	2785                	addiw	a5,a5,1
    800050aa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800050ac:	0023e517          	auipc	a0,0x23e
    800050b0:	f3c50513          	addi	a0,a0,-196 # 80242fe8 <ftable>
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	d16080e7          	jalr	-746(ra) # 80000dca <release>
  return f;
}
    800050bc:	8526                	mv	a0,s1
    800050be:	60e2                	ld	ra,24(sp)
    800050c0:	6442                	ld	s0,16(sp)
    800050c2:	64a2                	ld	s1,8(sp)
    800050c4:	6105                	addi	sp,sp,32
    800050c6:	8082                	ret
    panic("filedup");
    800050c8:	00004517          	auipc	a0,0x4
    800050cc:	89050513          	addi	a0,a0,-1904 # 80008958 <syscallnames+0x278>
    800050d0:	ffffb097          	auipc	ra,0xffffb
    800050d4:	470080e7          	jalr	1136(ra) # 80000540 <panic>

00000000800050d8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800050d8:	7139                	addi	sp,sp,-64
    800050da:	fc06                	sd	ra,56(sp)
    800050dc:	f822                	sd	s0,48(sp)
    800050de:	f426                	sd	s1,40(sp)
    800050e0:	f04a                	sd	s2,32(sp)
    800050e2:	ec4e                	sd	s3,24(sp)
    800050e4:	e852                	sd	s4,16(sp)
    800050e6:	e456                	sd	s5,8(sp)
    800050e8:	0080                	addi	s0,sp,64
    800050ea:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800050ec:	0023e517          	auipc	a0,0x23e
    800050f0:	efc50513          	addi	a0,a0,-260 # 80242fe8 <ftable>
    800050f4:	ffffc097          	auipc	ra,0xffffc
    800050f8:	c22080e7          	jalr	-990(ra) # 80000d16 <acquire>
  if(f->ref < 1)
    800050fc:	40dc                	lw	a5,4(s1)
    800050fe:	06f05163          	blez	a5,80005160 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005102:	37fd                	addiw	a5,a5,-1
    80005104:	0007871b          	sext.w	a4,a5
    80005108:	c0dc                	sw	a5,4(s1)
    8000510a:	06e04363          	bgtz	a4,80005170 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000510e:	0004a903          	lw	s2,0(s1)
    80005112:	0094ca83          	lbu	s5,9(s1)
    80005116:	0104ba03          	ld	s4,16(s1)
    8000511a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000511e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005122:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005126:	0023e517          	auipc	a0,0x23e
    8000512a:	ec250513          	addi	a0,a0,-318 # 80242fe8 <ftable>
    8000512e:	ffffc097          	auipc	ra,0xffffc
    80005132:	c9c080e7          	jalr	-868(ra) # 80000dca <release>

  if(ff.type == FD_PIPE){
    80005136:	4785                	li	a5,1
    80005138:	04f90d63          	beq	s2,a5,80005192 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000513c:	3979                	addiw	s2,s2,-2
    8000513e:	4785                	li	a5,1
    80005140:	0527e063          	bltu	a5,s2,80005180 <fileclose+0xa8>
    begin_op();
    80005144:	00000097          	auipc	ra,0x0
    80005148:	acc080e7          	jalr	-1332(ra) # 80004c10 <begin_op>
    iput(ff.ip);
    8000514c:	854e                	mv	a0,s3
    8000514e:	fffff097          	auipc	ra,0xfffff
    80005152:	2b0080e7          	jalr	688(ra) # 800043fe <iput>
    end_op();
    80005156:	00000097          	auipc	ra,0x0
    8000515a:	b38080e7          	jalr	-1224(ra) # 80004c8e <end_op>
    8000515e:	a00d                	j	80005180 <fileclose+0xa8>
    panic("fileclose");
    80005160:	00004517          	auipc	a0,0x4
    80005164:	80050513          	addi	a0,a0,-2048 # 80008960 <syscallnames+0x280>
    80005168:	ffffb097          	auipc	ra,0xffffb
    8000516c:	3d8080e7          	jalr	984(ra) # 80000540 <panic>
    release(&ftable.lock);
    80005170:	0023e517          	auipc	a0,0x23e
    80005174:	e7850513          	addi	a0,a0,-392 # 80242fe8 <ftable>
    80005178:	ffffc097          	auipc	ra,0xffffc
    8000517c:	c52080e7          	jalr	-942(ra) # 80000dca <release>
  }
}
    80005180:	70e2                	ld	ra,56(sp)
    80005182:	7442                	ld	s0,48(sp)
    80005184:	74a2                	ld	s1,40(sp)
    80005186:	7902                	ld	s2,32(sp)
    80005188:	69e2                	ld	s3,24(sp)
    8000518a:	6a42                	ld	s4,16(sp)
    8000518c:	6aa2                	ld	s5,8(sp)
    8000518e:	6121                	addi	sp,sp,64
    80005190:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005192:	85d6                	mv	a1,s5
    80005194:	8552                	mv	a0,s4
    80005196:	00000097          	auipc	ra,0x0
    8000519a:	34c080e7          	jalr	844(ra) # 800054e2 <pipeclose>
    8000519e:	b7cd                	j	80005180 <fileclose+0xa8>

00000000800051a0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800051a0:	715d                	addi	sp,sp,-80
    800051a2:	e486                	sd	ra,72(sp)
    800051a4:	e0a2                	sd	s0,64(sp)
    800051a6:	fc26                	sd	s1,56(sp)
    800051a8:	f84a                	sd	s2,48(sp)
    800051aa:	f44e                	sd	s3,40(sp)
    800051ac:	0880                	addi	s0,sp,80
    800051ae:	84aa                	mv	s1,a0
    800051b0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800051b2:	ffffd097          	auipc	ra,0xffffd
    800051b6:	9ae080e7          	jalr	-1618(ra) # 80001b60 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800051ba:	409c                	lw	a5,0(s1)
    800051bc:	37f9                	addiw	a5,a5,-2
    800051be:	4705                	li	a4,1
    800051c0:	04f76763          	bltu	a4,a5,8000520e <filestat+0x6e>
    800051c4:	892a                	mv	s2,a0
    ilock(f->ip);
    800051c6:	6c88                	ld	a0,24(s1)
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	07c080e7          	jalr	124(ra) # 80004244 <ilock>
    stati(f->ip, &st);
    800051d0:	fb840593          	addi	a1,s0,-72
    800051d4:	6c88                	ld	a0,24(s1)
    800051d6:	fffff097          	auipc	ra,0xfffff
    800051da:	2f8080e7          	jalr	760(ra) # 800044ce <stati>
    iunlock(f->ip);
    800051de:	6c88                	ld	a0,24(s1)
    800051e0:	fffff097          	auipc	ra,0xfffff
    800051e4:	126080e7          	jalr	294(ra) # 80004306 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800051e8:	46e1                	li	a3,24
    800051ea:	fb840613          	addi	a2,s0,-72
    800051ee:	85ce                	mv	a1,s3
    800051f0:	05093503          	ld	a0,80(s2)
    800051f4:	ffffc097          	auipc	ra,0xffffc
    800051f8:	5a4080e7          	jalr	1444(ra) # 80001798 <copyout>
    800051fc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005200:	60a6                	ld	ra,72(sp)
    80005202:	6406                	ld	s0,64(sp)
    80005204:	74e2                	ld	s1,56(sp)
    80005206:	7942                	ld	s2,48(sp)
    80005208:	79a2                	ld	s3,40(sp)
    8000520a:	6161                	addi	sp,sp,80
    8000520c:	8082                	ret
  return -1;
    8000520e:	557d                	li	a0,-1
    80005210:	bfc5                	j	80005200 <filestat+0x60>

0000000080005212 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005212:	7179                	addi	sp,sp,-48
    80005214:	f406                	sd	ra,40(sp)
    80005216:	f022                	sd	s0,32(sp)
    80005218:	ec26                	sd	s1,24(sp)
    8000521a:	e84a                	sd	s2,16(sp)
    8000521c:	e44e                	sd	s3,8(sp)
    8000521e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005220:	00854783          	lbu	a5,8(a0)
    80005224:	c3d5                	beqz	a5,800052c8 <fileread+0xb6>
    80005226:	84aa                	mv	s1,a0
    80005228:	89ae                	mv	s3,a1
    8000522a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000522c:	411c                	lw	a5,0(a0)
    8000522e:	4705                	li	a4,1
    80005230:	04e78963          	beq	a5,a4,80005282 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005234:	470d                	li	a4,3
    80005236:	04e78d63          	beq	a5,a4,80005290 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000523a:	4709                	li	a4,2
    8000523c:	06e79e63          	bne	a5,a4,800052b8 <fileread+0xa6>
    ilock(f->ip);
    80005240:	6d08                	ld	a0,24(a0)
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	002080e7          	jalr	2(ra) # 80004244 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000524a:	874a                	mv	a4,s2
    8000524c:	5094                	lw	a3,32(s1)
    8000524e:	864e                	mv	a2,s3
    80005250:	4585                	li	a1,1
    80005252:	6c88                	ld	a0,24(s1)
    80005254:	fffff097          	auipc	ra,0xfffff
    80005258:	2a4080e7          	jalr	676(ra) # 800044f8 <readi>
    8000525c:	892a                	mv	s2,a0
    8000525e:	00a05563          	blez	a0,80005268 <fileread+0x56>
      f->off += r;
    80005262:	509c                	lw	a5,32(s1)
    80005264:	9fa9                	addw	a5,a5,a0
    80005266:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005268:	6c88                	ld	a0,24(s1)
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	09c080e7          	jalr	156(ra) # 80004306 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005272:	854a                	mv	a0,s2
    80005274:	70a2                	ld	ra,40(sp)
    80005276:	7402                	ld	s0,32(sp)
    80005278:	64e2                	ld	s1,24(sp)
    8000527a:	6942                	ld	s2,16(sp)
    8000527c:	69a2                	ld	s3,8(sp)
    8000527e:	6145                	addi	sp,sp,48
    80005280:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005282:	6908                	ld	a0,16(a0)
    80005284:	00000097          	auipc	ra,0x0
    80005288:	3c6080e7          	jalr	966(ra) # 8000564a <piperead>
    8000528c:	892a                	mv	s2,a0
    8000528e:	b7d5                	j	80005272 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005290:	02451783          	lh	a5,36(a0)
    80005294:	03079693          	slli	a3,a5,0x30
    80005298:	92c1                	srli	a3,a3,0x30
    8000529a:	4725                	li	a4,9
    8000529c:	02d76863          	bltu	a4,a3,800052cc <fileread+0xba>
    800052a0:	0792                	slli	a5,a5,0x4
    800052a2:	0023e717          	auipc	a4,0x23e
    800052a6:	ca670713          	addi	a4,a4,-858 # 80242f48 <devsw>
    800052aa:	97ba                	add	a5,a5,a4
    800052ac:	639c                	ld	a5,0(a5)
    800052ae:	c38d                	beqz	a5,800052d0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800052b0:	4505                	li	a0,1
    800052b2:	9782                	jalr	a5
    800052b4:	892a                	mv	s2,a0
    800052b6:	bf75                	j	80005272 <fileread+0x60>
    panic("fileread");
    800052b8:	00003517          	auipc	a0,0x3
    800052bc:	6b850513          	addi	a0,a0,1720 # 80008970 <syscallnames+0x290>
    800052c0:	ffffb097          	auipc	ra,0xffffb
    800052c4:	280080e7          	jalr	640(ra) # 80000540 <panic>
    return -1;
    800052c8:	597d                	li	s2,-1
    800052ca:	b765                	j	80005272 <fileread+0x60>
      return -1;
    800052cc:	597d                	li	s2,-1
    800052ce:	b755                	j	80005272 <fileread+0x60>
    800052d0:	597d                	li	s2,-1
    800052d2:	b745                	j	80005272 <fileread+0x60>

00000000800052d4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800052d4:	715d                	addi	sp,sp,-80
    800052d6:	e486                	sd	ra,72(sp)
    800052d8:	e0a2                	sd	s0,64(sp)
    800052da:	fc26                	sd	s1,56(sp)
    800052dc:	f84a                	sd	s2,48(sp)
    800052de:	f44e                	sd	s3,40(sp)
    800052e0:	f052                	sd	s4,32(sp)
    800052e2:	ec56                	sd	s5,24(sp)
    800052e4:	e85a                	sd	s6,16(sp)
    800052e6:	e45e                	sd	s7,8(sp)
    800052e8:	e062                	sd	s8,0(sp)
    800052ea:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800052ec:	00954783          	lbu	a5,9(a0)
    800052f0:	10078663          	beqz	a5,800053fc <filewrite+0x128>
    800052f4:	892a                	mv	s2,a0
    800052f6:	8b2e                	mv	s6,a1
    800052f8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800052fa:	411c                	lw	a5,0(a0)
    800052fc:	4705                	li	a4,1
    800052fe:	02e78263          	beq	a5,a4,80005322 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005302:	470d                	li	a4,3
    80005304:	02e78663          	beq	a5,a4,80005330 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005308:	4709                	li	a4,2
    8000530a:	0ee79163          	bne	a5,a4,800053ec <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000530e:	0ac05d63          	blez	a2,800053c8 <filewrite+0xf4>
    int i = 0;
    80005312:	4981                	li	s3,0
    80005314:	6b85                	lui	s7,0x1
    80005316:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000531a:	6c05                	lui	s8,0x1
    8000531c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005320:	a861                	j	800053b8 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005322:	6908                	ld	a0,16(a0)
    80005324:	00000097          	auipc	ra,0x0
    80005328:	22e080e7          	jalr	558(ra) # 80005552 <pipewrite>
    8000532c:	8a2a                	mv	s4,a0
    8000532e:	a045                	j	800053ce <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005330:	02451783          	lh	a5,36(a0)
    80005334:	03079693          	slli	a3,a5,0x30
    80005338:	92c1                	srli	a3,a3,0x30
    8000533a:	4725                	li	a4,9
    8000533c:	0cd76263          	bltu	a4,a3,80005400 <filewrite+0x12c>
    80005340:	0792                	slli	a5,a5,0x4
    80005342:	0023e717          	auipc	a4,0x23e
    80005346:	c0670713          	addi	a4,a4,-1018 # 80242f48 <devsw>
    8000534a:	97ba                	add	a5,a5,a4
    8000534c:	679c                	ld	a5,8(a5)
    8000534e:	cbdd                	beqz	a5,80005404 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005350:	4505                	li	a0,1
    80005352:	9782                	jalr	a5
    80005354:	8a2a                	mv	s4,a0
    80005356:	a8a5                	j	800053ce <filewrite+0xfa>
    80005358:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000535c:	00000097          	auipc	ra,0x0
    80005360:	8b4080e7          	jalr	-1868(ra) # 80004c10 <begin_op>
      ilock(f->ip);
    80005364:	01893503          	ld	a0,24(s2)
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	edc080e7          	jalr	-292(ra) # 80004244 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005370:	8756                	mv	a4,s5
    80005372:	02092683          	lw	a3,32(s2)
    80005376:	01698633          	add	a2,s3,s6
    8000537a:	4585                	li	a1,1
    8000537c:	01893503          	ld	a0,24(s2)
    80005380:	fffff097          	auipc	ra,0xfffff
    80005384:	270080e7          	jalr	624(ra) # 800045f0 <writei>
    80005388:	84aa                	mv	s1,a0
    8000538a:	00a05763          	blez	a0,80005398 <filewrite+0xc4>
        f->off += r;
    8000538e:	02092783          	lw	a5,32(s2)
    80005392:	9fa9                	addw	a5,a5,a0
    80005394:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005398:	01893503          	ld	a0,24(s2)
    8000539c:	fffff097          	auipc	ra,0xfffff
    800053a0:	f6a080e7          	jalr	-150(ra) # 80004306 <iunlock>
      end_op();
    800053a4:	00000097          	auipc	ra,0x0
    800053a8:	8ea080e7          	jalr	-1814(ra) # 80004c8e <end_op>

      if(r != n1){
    800053ac:	009a9f63          	bne	s5,s1,800053ca <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800053b0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800053b4:	0149db63          	bge	s3,s4,800053ca <filewrite+0xf6>
      int n1 = n - i;
    800053b8:	413a04bb          	subw	s1,s4,s3
    800053bc:	0004879b          	sext.w	a5,s1
    800053c0:	f8fbdce3          	bge	s7,a5,80005358 <filewrite+0x84>
    800053c4:	84e2                	mv	s1,s8
    800053c6:	bf49                	j	80005358 <filewrite+0x84>
    int i = 0;
    800053c8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800053ca:	013a1f63          	bne	s4,s3,800053e8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800053ce:	8552                	mv	a0,s4
    800053d0:	60a6                	ld	ra,72(sp)
    800053d2:	6406                	ld	s0,64(sp)
    800053d4:	74e2                	ld	s1,56(sp)
    800053d6:	7942                	ld	s2,48(sp)
    800053d8:	79a2                	ld	s3,40(sp)
    800053da:	7a02                	ld	s4,32(sp)
    800053dc:	6ae2                	ld	s5,24(sp)
    800053de:	6b42                	ld	s6,16(sp)
    800053e0:	6ba2                	ld	s7,8(sp)
    800053e2:	6c02                	ld	s8,0(sp)
    800053e4:	6161                	addi	sp,sp,80
    800053e6:	8082                	ret
    ret = (i == n ? n : -1);
    800053e8:	5a7d                	li	s4,-1
    800053ea:	b7d5                	j	800053ce <filewrite+0xfa>
    panic("filewrite");
    800053ec:	00003517          	auipc	a0,0x3
    800053f0:	59450513          	addi	a0,a0,1428 # 80008980 <syscallnames+0x2a0>
    800053f4:	ffffb097          	auipc	ra,0xffffb
    800053f8:	14c080e7          	jalr	332(ra) # 80000540 <panic>
    return -1;
    800053fc:	5a7d                	li	s4,-1
    800053fe:	bfc1                	j	800053ce <filewrite+0xfa>
      return -1;
    80005400:	5a7d                	li	s4,-1
    80005402:	b7f1                	j	800053ce <filewrite+0xfa>
    80005404:	5a7d                	li	s4,-1
    80005406:	b7e1                	j	800053ce <filewrite+0xfa>

0000000080005408 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005408:	7179                	addi	sp,sp,-48
    8000540a:	f406                	sd	ra,40(sp)
    8000540c:	f022                	sd	s0,32(sp)
    8000540e:	ec26                	sd	s1,24(sp)
    80005410:	e84a                	sd	s2,16(sp)
    80005412:	e44e                	sd	s3,8(sp)
    80005414:	e052                	sd	s4,0(sp)
    80005416:	1800                	addi	s0,sp,48
    80005418:	84aa                	mv	s1,a0
    8000541a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000541c:	0005b023          	sd	zero,0(a1)
    80005420:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005424:	00000097          	auipc	ra,0x0
    80005428:	bf8080e7          	jalr	-1032(ra) # 8000501c <filealloc>
    8000542c:	e088                	sd	a0,0(s1)
    8000542e:	c551                	beqz	a0,800054ba <pipealloc+0xb2>
    80005430:	00000097          	auipc	ra,0x0
    80005434:	bec080e7          	jalr	-1044(ra) # 8000501c <filealloc>
    80005438:	00aa3023          	sd	a0,0(s4)
    8000543c:	c92d                	beqz	a0,800054ae <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000543e:	ffffb097          	auipc	ra,0xffffb
    80005442:	7aa080e7          	jalr	1962(ra) # 80000be8 <kalloc>
    80005446:	892a                	mv	s2,a0
    80005448:	c125                	beqz	a0,800054a8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000544a:	4985                	li	s3,1
    8000544c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005450:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005454:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005458:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000545c:	00003597          	auipc	a1,0x3
    80005460:	0b458593          	addi	a1,a1,180 # 80008510 <states.0+0x1d8>
    80005464:	ffffc097          	auipc	ra,0xffffc
    80005468:	822080e7          	jalr	-2014(ra) # 80000c86 <initlock>
  (*f0)->type = FD_PIPE;
    8000546c:	609c                	ld	a5,0(s1)
    8000546e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005472:	609c                	ld	a5,0(s1)
    80005474:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005478:	609c                	ld	a5,0(s1)
    8000547a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000547e:	609c                	ld	a5,0(s1)
    80005480:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005484:	000a3783          	ld	a5,0(s4)
    80005488:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000548c:	000a3783          	ld	a5,0(s4)
    80005490:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005494:	000a3783          	ld	a5,0(s4)
    80005498:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000549c:	000a3783          	ld	a5,0(s4)
    800054a0:	0127b823          	sd	s2,16(a5)
  return 0;
    800054a4:	4501                	li	a0,0
    800054a6:	a025                	j	800054ce <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800054a8:	6088                	ld	a0,0(s1)
    800054aa:	e501                	bnez	a0,800054b2 <pipealloc+0xaa>
    800054ac:	a039                	j	800054ba <pipealloc+0xb2>
    800054ae:	6088                	ld	a0,0(s1)
    800054b0:	c51d                	beqz	a0,800054de <pipealloc+0xd6>
    fileclose(*f0);
    800054b2:	00000097          	auipc	ra,0x0
    800054b6:	c26080e7          	jalr	-986(ra) # 800050d8 <fileclose>
  if(*f1)
    800054ba:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800054be:	557d                	li	a0,-1
  if(*f1)
    800054c0:	c799                	beqz	a5,800054ce <pipealloc+0xc6>
    fileclose(*f1);
    800054c2:	853e                	mv	a0,a5
    800054c4:	00000097          	auipc	ra,0x0
    800054c8:	c14080e7          	jalr	-1004(ra) # 800050d8 <fileclose>
  return -1;
    800054cc:	557d                	li	a0,-1
}
    800054ce:	70a2                	ld	ra,40(sp)
    800054d0:	7402                	ld	s0,32(sp)
    800054d2:	64e2                	ld	s1,24(sp)
    800054d4:	6942                	ld	s2,16(sp)
    800054d6:	69a2                	ld	s3,8(sp)
    800054d8:	6a02                	ld	s4,0(sp)
    800054da:	6145                	addi	sp,sp,48
    800054dc:	8082                	ret
  return -1;
    800054de:	557d                	li	a0,-1
    800054e0:	b7fd                	j	800054ce <pipealloc+0xc6>

00000000800054e2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800054e2:	1101                	addi	sp,sp,-32
    800054e4:	ec06                	sd	ra,24(sp)
    800054e6:	e822                	sd	s0,16(sp)
    800054e8:	e426                	sd	s1,8(sp)
    800054ea:	e04a                	sd	s2,0(sp)
    800054ec:	1000                	addi	s0,sp,32
    800054ee:	84aa                	mv	s1,a0
    800054f0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800054f2:	ffffc097          	auipc	ra,0xffffc
    800054f6:	824080e7          	jalr	-2012(ra) # 80000d16 <acquire>
  if(writable){
    800054fa:	02090d63          	beqz	s2,80005534 <pipeclose+0x52>
    pi->writeopen = 0;
    800054fe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005502:	21848513          	addi	a0,s1,536
    80005506:	ffffd097          	auipc	ra,0xffffd
    8000550a:	144080e7          	jalr	324(ra) # 8000264a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000550e:	2204b783          	ld	a5,544(s1)
    80005512:	eb95                	bnez	a5,80005546 <pipeclose+0x64>
    release(&pi->lock);
    80005514:	8526                	mv	a0,s1
    80005516:	ffffc097          	auipc	ra,0xffffc
    8000551a:	8b4080e7          	jalr	-1868(ra) # 80000dca <release>
    kfree((char*)pi);
    8000551e:	8526                	mv	a0,s1
    80005520:	ffffb097          	auipc	ra,0xffffb
    80005524:	544080e7          	jalr	1348(ra) # 80000a64 <kfree>
  } else
    release(&pi->lock);
}
    80005528:	60e2                	ld	ra,24(sp)
    8000552a:	6442                	ld	s0,16(sp)
    8000552c:	64a2                	ld	s1,8(sp)
    8000552e:	6902                	ld	s2,0(sp)
    80005530:	6105                	addi	sp,sp,32
    80005532:	8082                	ret
    pi->readopen = 0;
    80005534:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005538:	21c48513          	addi	a0,s1,540
    8000553c:	ffffd097          	auipc	ra,0xffffd
    80005540:	10e080e7          	jalr	270(ra) # 8000264a <wakeup>
    80005544:	b7e9                	j	8000550e <pipeclose+0x2c>
    release(&pi->lock);
    80005546:	8526                	mv	a0,s1
    80005548:	ffffc097          	auipc	ra,0xffffc
    8000554c:	882080e7          	jalr	-1918(ra) # 80000dca <release>
}
    80005550:	bfe1                	j	80005528 <pipeclose+0x46>

0000000080005552 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005552:	711d                	addi	sp,sp,-96
    80005554:	ec86                	sd	ra,88(sp)
    80005556:	e8a2                	sd	s0,80(sp)
    80005558:	e4a6                	sd	s1,72(sp)
    8000555a:	e0ca                	sd	s2,64(sp)
    8000555c:	fc4e                	sd	s3,56(sp)
    8000555e:	f852                	sd	s4,48(sp)
    80005560:	f456                	sd	s5,40(sp)
    80005562:	f05a                	sd	s6,32(sp)
    80005564:	ec5e                	sd	s7,24(sp)
    80005566:	e862                	sd	s8,16(sp)
    80005568:	1080                	addi	s0,sp,96
    8000556a:	84aa                	mv	s1,a0
    8000556c:	8aae                	mv	s5,a1
    8000556e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005570:	ffffc097          	auipc	ra,0xffffc
    80005574:	5f0080e7          	jalr	1520(ra) # 80001b60 <myproc>
    80005578:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000557a:	8526                	mv	a0,s1
    8000557c:	ffffb097          	auipc	ra,0xffffb
    80005580:	79a080e7          	jalr	1946(ra) # 80000d16 <acquire>
  while(i < n){
    80005584:	0b405663          	blez	s4,80005630 <pipewrite+0xde>
  int i = 0;
    80005588:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000558a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000558c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005590:	21c48b93          	addi	s7,s1,540
    80005594:	a089                	j	800055d6 <pipewrite+0x84>
      release(&pi->lock);
    80005596:	8526                	mv	a0,s1
    80005598:	ffffc097          	auipc	ra,0xffffc
    8000559c:	832080e7          	jalr	-1998(ra) # 80000dca <release>
      return -1;
    800055a0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800055a2:	854a                	mv	a0,s2
    800055a4:	60e6                	ld	ra,88(sp)
    800055a6:	6446                	ld	s0,80(sp)
    800055a8:	64a6                	ld	s1,72(sp)
    800055aa:	6906                	ld	s2,64(sp)
    800055ac:	79e2                	ld	s3,56(sp)
    800055ae:	7a42                	ld	s4,48(sp)
    800055b0:	7aa2                	ld	s5,40(sp)
    800055b2:	7b02                	ld	s6,32(sp)
    800055b4:	6be2                	ld	s7,24(sp)
    800055b6:	6c42                	ld	s8,16(sp)
    800055b8:	6125                	addi	sp,sp,96
    800055ba:	8082                	ret
      wakeup(&pi->nread);
    800055bc:	8562                	mv	a0,s8
    800055be:	ffffd097          	auipc	ra,0xffffd
    800055c2:	08c080e7          	jalr	140(ra) # 8000264a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800055c6:	85a6                	mv	a1,s1
    800055c8:	855e                	mv	a0,s7
    800055ca:	ffffd097          	auipc	ra,0xffffd
    800055ce:	ecc080e7          	jalr	-308(ra) # 80002496 <sleep>
  while(i < n){
    800055d2:	07495063          	bge	s2,s4,80005632 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800055d6:	2204a783          	lw	a5,544(s1)
    800055da:	dfd5                	beqz	a5,80005596 <pipewrite+0x44>
    800055dc:	854e                	mv	a0,s3
    800055de:	ffffd097          	auipc	ra,0xffffd
    800055e2:	34a080e7          	jalr	842(ra) # 80002928 <killed>
    800055e6:	f945                	bnez	a0,80005596 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800055e8:	2184a783          	lw	a5,536(s1)
    800055ec:	21c4a703          	lw	a4,540(s1)
    800055f0:	2007879b          	addiw	a5,a5,512
    800055f4:	fcf704e3          	beq	a4,a5,800055bc <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800055f8:	4685                	li	a3,1
    800055fa:	01590633          	add	a2,s2,s5
    800055fe:	faf40593          	addi	a1,s0,-81
    80005602:	0509b503          	ld	a0,80(s3)
    80005606:	ffffc097          	auipc	ra,0xffffc
    8000560a:	26c080e7          	jalr	620(ra) # 80001872 <copyin>
    8000560e:	03650263          	beq	a0,s6,80005632 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005612:	21c4a783          	lw	a5,540(s1)
    80005616:	0017871b          	addiw	a4,a5,1
    8000561a:	20e4ae23          	sw	a4,540(s1)
    8000561e:	1ff7f793          	andi	a5,a5,511
    80005622:	97a6                	add	a5,a5,s1
    80005624:	faf44703          	lbu	a4,-81(s0)
    80005628:	00e78c23          	sb	a4,24(a5)
      i++;
    8000562c:	2905                	addiw	s2,s2,1
    8000562e:	b755                	j	800055d2 <pipewrite+0x80>
  int i = 0;
    80005630:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005632:	21848513          	addi	a0,s1,536
    80005636:	ffffd097          	auipc	ra,0xffffd
    8000563a:	014080e7          	jalr	20(ra) # 8000264a <wakeup>
  release(&pi->lock);
    8000563e:	8526                	mv	a0,s1
    80005640:	ffffb097          	auipc	ra,0xffffb
    80005644:	78a080e7          	jalr	1930(ra) # 80000dca <release>
  return i;
    80005648:	bfa9                	j	800055a2 <pipewrite+0x50>

000000008000564a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000564a:	715d                	addi	sp,sp,-80
    8000564c:	e486                	sd	ra,72(sp)
    8000564e:	e0a2                	sd	s0,64(sp)
    80005650:	fc26                	sd	s1,56(sp)
    80005652:	f84a                	sd	s2,48(sp)
    80005654:	f44e                	sd	s3,40(sp)
    80005656:	f052                	sd	s4,32(sp)
    80005658:	ec56                	sd	s5,24(sp)
    8000565a:	e85a                	sd	s6,16(sp)
    8000565c:	0880                	addi	s0,sp,80
    8000565e:	84aa                	mv	s1,a0
    80005660:	892e                	mv	s2,a1
    80005662:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005664:	ffffc097          	auipc	ra,0xffffc
    80005668:	4fc080e7          	jalr	1276(ra) # 80001b60 <myproc>
    8000566c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000566e:	8526                	mv	a0,s1
    80005670:	ffffb097          	auipc	ra,0xffffb
    80005674:	6a6080e7          	jalr	1702(ra) # 80000d16 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005678:	2184a703          	lw	a4,536(s1)
    8000567c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005680:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005684:	02f71763          	bne	a4,a5,800056b2 <piperead+0x68>
    80005688:	2244a783          	lw	a5,548(s1)
    8000568c:	c39d                	beqz	a5,800056b2 <piperead+0x68>
    if(killed(pr)){
    8000568e:	8552                	mv	a0,s4
    80005690:	ffffd097          	auipc	ra,0xffffd
    80005694:	298080e7          	jalr	664(ra) # 80002928 <killed>
    80005698:	e949                	bnez	a0,8000572a <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000569a:	85a6                	mv	a1,s1
    8000569c:	854e                	mv	a0,s3
    8000569e:	ffffd097          	auipc	ra,0xffffd
    800056a2:	df8080e7          	jalr	-520(ra) # 80002496 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800056a6:	2184a703          	lw	a4,536(s1)
    800056aa:	21c4a783          	lw	a5,540(s1)
    800056ae:	fcf70de3          	beq	a4,a5,80005688 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800056b2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800056b4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800056b6:	05505463          	blez	s5,800056fe <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800056ba:	2184a783          	lw	a5,536(s1)
    800056be:	21c4a703          	lw	a4,540(s1)
    800056c2:	02f70e63          	beq	a4,a5,800056fe <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800056c6:	0017871b          	addiw	a4,a5,1
    800056ca:	20e4ac23          	sw	a4,536(s1)
    800056ce:	1ff7f793          	andi	a5,a5,511
    800056d2:	97a6                	add	a5,a5,s1
    800056d4:	0187c783          	lbu	a5,24(a5)
    800056d8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800056dc:	4685                	li	a3,1
    800056de:	fbf40613          	addi	a2,s0,-65
    800056e2:	85ca                	mv	a1,s2
    800056e4:	050a3503          	ld	a0,80(s4)
    800056e8:	ffffc097          	auipc	ra,0xffffc
    800056ec:	0b0080e7          	jalr	176(ra) # 80001798 <copyout>
    800056f0:	01650763          	beq	a0,s6,800056fe <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800056f4:	2985                	addiw	s3,s3,1
    800056f6:	0905                	addi	s2,s2,1
    800056f8:	fd3a91e3          	bne	s5,s3,800056ba <piperead+0x70>
    800056fc:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800056fe:	21c48513          	addi	a0,s1,540
    80005702:	ffffd097          	auipc	ra,0xffffd
    80005706:	f48080e7          	jalr	-184(ra) # 8000264a <wakeup>
  release(&pi->lock);
    8000570a:	8526                	mv	a0,s1
    8000570c:	ffffb097          	auipc	ra,0xffffb
    80005710:	6be080e7          	jalr	1726(ra) # 80000dca <release>
  return i;
}
    80005714:	854e                	mv	a0,s3
    80005716:	60a6                	ld	ra,72(sp)
    80005718:	6406                	ld	s0,64(sp)
    8000571a:	74e2                	ld	s1,56(sp)
    8000571c:	7942                	ld	s2,48(sp)
    8000571e:	79a2                	ld	s3,40(sp)
    80005720:	7a02                	ld	s4,32(sp)
    80005722:	6ae2                	ld	s5,24(sp)
    80005724:	6b42                	ld	s6,16(sp)
    80005726:	6161                	addi	sp,sp,80
    80005728:	8082                	ret
      release(&pi->lock);
    8000572a:	8526                	mv	a0,s1
    8000572c:	ffffb097          	auipc	ra,0xffffb
    80005730:	69e080e7          	jalr	1694(ra) # 80000dca <release>
      return -1;
    80005734:	59fd                	li	s3,-1
    80005736:	bff9                	j	80005714 <piperead+0xca>

0000000080005738 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005738:	1141                	addi	sp,sp,-16
    8000573a:	e422                	sd	s0,8(sp)
    8000573c:	0800                	addi	s0,sp,16
    8000573e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005740:	8905                	andi	a0,a0,1
    80005742:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005744:	8b89                	andi	a5,a5,2
    80005746:	c399                	beqz	a5,8000574c <flags2perm+0x14>
      perm |= PTE_W;
    80005748:	00456513          	ori	a0,a0,4
    return perm;
}
    8000574c:	6422                	ld	s0,8(sp)
    8000574e:	0141                	addi	sp,sp,16
    80005750:	8082                	ret

0000000080005752 <exec>:

int
exec(char *path, char **argv)
{
    80005752:	de010113          	addi	sp,sp,-544
    80005756:	20113c23          	sd	ra,536(sp)
    8000575a:	20813823          	sd	s0,528(sp)
    8000575e:	20913423          	sd	s1,520(sp)
    80005762:	21213023          	sd	s2,512(sp)
    80005766:	ffce                	sd	s3,504(sp)
    80005768:	fbd2                	sd	s4,496(sp)
    8000576a:	f7d6                	sd	s5,488(sp)
    8000576c:	f3da                	sd	s6,480(sp)
    8000576e:	efde                	sd	s7,472(sp)
    80005770:	ebe2                	sd	s8,464(sp)
    80005772:	e7e6                	sd	s9,456(sp)
    80005774:	e3ea                	sd	s10,448(sp)
    80005776:	ff6e                	sd	s11,440(sp)
    80005778:	1400                	addi	s0,sp,544
    8000577a:	892a                	mv	s2,a0
    8000577c:	dea43423          	sd	a0,-536(s0)
    80005780:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005784:	ffffc097          	auipc	ra,0xffffc
    80005788:	3dc080e7          	jalr	988(ra) # 80001b60 <myproc>
    8000578c:	84aa                	mv	s1,a0

  begin_op();
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	482080e7          	jalr	1154(ra) # 80004c10 <begin_op>

  if((ip = namei(path)) == 0){
    80005796:	854a                	mv	a0,s2
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	258080e7          	jalr	600(ra) # 800049f0 <namei>
    800057a0:	c93d                	beqz	a0,80005816 <exec+0xc4>
    800057a2:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800057a4:	fffff097          	auipc	ra,0xfffff
    800057a8:	aa0080e7          	jalr	-1376(ra) # 80004244 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800057ac:	04000713          	li	a4,64
    800057b0:	4681                	li	a3,0
    800057b2:	e5040613          	addi	a2,s0,-432
    800057b6:	4581                	li	a1,0
    800057b8:	8556                	mv	a0,s5
    800057ba:	fffff097          	auipc	ra,0xfffff
    800057be:	d3e080e7          	jalr	-706(ra) # 800044f8 <readi>
    800057c2:	04000793          	li	a5,64
    800057c6:	00f51a63          	bne	a0,a5,800057da <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800057ca:	e5042703          	lw	a4,-432(s0)
    800057ce:	464c47b7          	lui	a5,0x464c4
    800057d2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800057d6:	04f70663          	beq	a4,a5,80005822 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800057da:	8556                	mv	a0,s5
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	cca080e7          	jalr	-822(ra) # 800044a6 <iunlockput>
    end_op();
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	4aa080e7          	jalr	1194(ra) # 80004c8e <end_op>
  }
  return -1;
    800057ec:	557d                	li	a0,-1
}
    800057ee:	21813083          	ld	ra,536(sp)
    800057f2:	21013403          	ld	s0,528(sp)
    800057f6:	20813483          	ld	s1,520(sp)
    800057fa:	20013903          	ld	s2,512(sp)
    800057fe:	79fe                	ld	s3,504(sp)
    80005800:	7a5e                	ld	s4,496(sp)
    80005802:	7abe                	ld	s5,488(sp)
    80005804:	7b1e                	ld	s6,480(sp)
    80005806:	6bfe                	ld	s7,472(sp)
    80005808:	6c5e                	ld	s8,464(sp)
    8000580a:	6cbe                	ld	s9,456(sp)
    8000580c:	6d1e                	ld	s10,448(sp)
    8000580e:	7dfa                	ld	s11,440(sp)
    80005810:	22010113          	addi	sp,sp,544
    80005814:	8082                	ret
    end_op();
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	478080e7          	jalr	1144(ra) # 80004c8e <end_op>
    return -1;
    8000581e:	557d                	li	a0,-1
    80005820:	b7f9                	j	800057ee <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005822:	8526                	mv	a0,s1
    80005824:	ffffc097          	auipc	ra,0xffffc
    80005828:	4a2080e7          	jalr	1186(ra) # 80001cc6 <proc_pagetable>
    8000582c:	8b2a                	mv	s6,a0
    8000582e:	d555                	beqz	a0,800057da <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005830:	e7042783          	lw	a5,-400(s0)
    80005834:	e8845703          	lhu	a4,-376(s0)
    80005838:	c735                	beqz	a4,800058a4 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000583a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000583c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005840:	6a05                	lui	s4,0x1
    80005842:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005846:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000584a:	6d85                	lui	s11,0x1
    8000584c:	7d7d                	lui	s10,0xfffff
    8000584e:	ac3d                	j	80005a8c <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005850:	00003517          	auipc	a0,0x3
    80005854:	14050513          	addi	a0,a0,320 # 80008990 <syscallnames+0x2b0>
    80005858:	ffffb097          	auipc	ra,0xffffb
    8000585c:	ce8080e7          	jalr	-792(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005860:	874a                	mv	a4,s2
    80005862:	009c86bb          	addw	a3,s9,s1
    80005866:	4581                	li	a1,0
    80005868:	8556                	mv	a0,s5
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	c8e080e7          	jalr	-882(ra) # 800044f8 <readi>
    80005872:	2501                	sext.w	a0,a0
    80005874:	1aa91963          	bne	s2,a0,80005a26 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005878:	009d84bb          	addw	s1,s11,s1
    8000587c:	013d09bb          	addw	s3,s10,s3
    80005880:	1f74f663          	bgeu	s1,s7,80005a6c <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005884:	02049593          	slli	a1,s1,0x20
    80005888:	9181                	srli	a1,a1,0x20
    8000588a:	95e2                	add	a1,a1,s8
    8000588c:	855a                	mv	a0,s6
    8000588e:	ffffc097          	auipc	ra,0xffffc
    80005892:	90e080e7          	jalr	-1778(ra) # 8000119c <walkaddr>
    80005896:	862a                	mv	a2,a0
    if(pa == 0)
    80005898:	dd45                	beqz	a0,80005850 <exec+0xfe>
      n = PGSIZE;
    8000589a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000589c:	fd49f2e3          	bgeu	s3,s4,80005860 <exec+0x10e>
      n = sz - i;
    800058a0:	894e                	mv	s2,s3
    800058a2:	bf7d                	j	80005860 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800058a4:	4901                	li	s2,0
  iunlockput(ip);
    800058a6:	8556                	mv	a0,s5
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	bfe080e7          	jalr	-1026(ra) # 800044a6 <iunlockput>
  end_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	3de080e7          	jalr	990(ra) # 80004c8e <end_op>
  p = myproc();
    800058b8:	ffffc097          	auipc	ra,0xffffc
    800058bc:	2a8080e7          	jalr	680(ra) # 80001b60 <myproc>
    800058c0:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800058c2:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800058c6:	6785                	lui	a5,0x1
    800058c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800058ca:	97ca                	add	a5,a5,s2
    800058cc:	777d                	lui	a4,0xfffff
    800058ce:	8ff9                	and	a5,a5,a4
    800058d0:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800058d4:	4691                	li	a3,4
    800058d6:	6609                	lui	a2,0x2
    800058d8:	963e                	add	a2,a2,a5
    800058da:	85be                	mv	a1,a5
    800058dc:	855a                	mv	a0,s6
    800058de:	ffffc097          	auipc	ra,0xffffc
    800058e2:	c72080e7          	jalr	-910(ra) # 80001550 <uvmalloc>
    800058e6:	8c2a                	mv	s8,a0
  ip = 0;
    800058e8:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800058ea:	12050e63          	beqz	a0,80005a26 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800058ee:	75f9                	lui	a1,0xffffe
    800058f0:	95aa                	add	a1,a1,a0
    800058f2:	855a                	mv	a0,s6
    800058f4:	ffffc097          	auipc	ra,0xffffc
    800058f8:	e72080e7          	jalr	-398(ra) # 80001766 <uvmclear>
  stackbase = sp - PGSIZE;
    800058fc:	7afd                	lui	s5,0xfffff
    800058fe:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005900:	df043783          	ld	a5,-528(s0)
    80005904:	6388                	ld	a0,0(a5)
    80005906:	c925                	beqz	a0,80005976 <exec+0x224>
    80005908:	e9040993          	addi	s3,s0,-368
    8000590c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005910:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005912:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005914:	ffffb097          	auipc	ra,0xffffb
    80005918:	67a080e7          	jalr	1658(ra) # 80000f8e <strlen>
    8000591c:	0015079b          	addiw	a5,a0,1
    80005920:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005924:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005928:	13596663          	bltu	s2,s5,80005a54 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000592c:	df043d83          	ld	s11,-528(s0)
    80005930:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005934:	8552                	mv	a0,s4
    80005936:	ffffb097          	auipc	ra,0xffffb
    8000593a:	658080e7          	jalr	1624(ra) # 80000f8e <strlen>
    8000593e:	0015069b          	addiw	a3,a0,1
    80005942:	8652                	mv	a2,s4
    80005944:	85ca                	mv	a1,s2
    80005946:	855a                	mv	a0,s6
    80005948:	ffffc097          	auipc	ra,0xffffc
    8000594c:	e50080e7          	jalr	-432(ra) # 80001798 <copyout>
    80005950:	10054663          	bltz	a0,80005a5c <exec+0x30a>
    ustack[argc] = sp;
    80005954:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005958:	0485                	addi	s1,s1,1
    8000595a:	008d8793          	addi	a5,s11,8
    8000595e:	def43823          	sd	a5,-528(s0)
    80005962:	008db503          	ld	a0,8(s11)
    80005966:	c911                	beqz	a0,8000597a <exec+0x228>
    if(argc >= MAXARG)
    80005968:	09a1                	addi	s3,s3,8
    8000596a:	fb3c95e3          	bne	s9,s3,80005914 <exec+0x1c2>
  sz = sz1;
    8000596e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005972:	4a81                	li	s5,0
    80005974:	a84d                	j	80005a26 <exec+0x2d4>
  sp = sz;
    80005976:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005978:	4481                	li	s1,0
  ustack[argc] = 0;
    8000597a:	00349793          	slli	a5,s1,0x3
    8000597e:	f9078793          	addi	a5,a5,-112
    80005982:	97a2                	add	a5,a5,s0
    80005984:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005988:	00148693          	addi	a3,s1,1
    8000598c:	068e                	slli	a3,a3,0x3
    8000598e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005992:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005996:	01597663          	bgeu	s2,s5,800059a2 <exec+0x250>
  sz = sz1;
    8000599a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000599e:	4a81                	li	s5,0
    800059a0:	a059                	j	80005a26 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800059a2:	e9040613          	addi	a2,s0,-368
    800059a6:	85ca                	mv	a1,s2
    800059a8:	855a                	mv	a0,s6
    800059aa:	ffffc097          	auipc	ra,0xffffc
    800059ae:	dee080e7          	jalr	-530(ra) # 80001798 <copyout>
    800059b2:	0a054963          	bltz	a0,80005a64 <exec+0x312>
  p->trapframe->a1 = sp;
    800059b6:	058bb783          	ld	a5,88(s7)
    800059ba:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800059be:	de843783          	ld	a5,-536(s0)
    800059c2:	0007c703          	lbu	a4,0(a5)
    800059c6:	cf11                	beqz	a4,800059e2 <exec+0x290>
    800059c8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800059ca:	02f00693          	li	a3,47
    800059ce:	a039                	j	800059dc <exec+0x28a>
      last = s+1;
    800059d0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800059d4:	0785                	addi	a5,a5,1
    800059d6:	fff7c703          	lbu	a4,-1(a5)
    800059da:	c701                	beqz	a4,800059e2 <exec+0x290>
    if(*s == '/')
    800059dc:	fed71ce3          	bne	a4,a3,800059d4 <exec+0x282>
    800059e0:	bfc5                	j	800059d0 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800059e2:	4641                	li	a2,16
    800059e4:	de843583          	ld	a1,-536(s0)
    800059e8:	158b8513          	addi	a0,s7,344
    800059ec:	ffffb097          	auipc	ra,0xffffb
    800059f0:	570080e7          	jalr	1392(ra) # 80000f5c <safestrcpy>
  oldpagetable = p->pagetable;
    800059f4:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800059f8:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800059fc:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005a00:	058bb783          	ld	a5,88(s7)
    80005a04:	e6843703          	ld	a4,-408(s0)
    80005a08:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005a0a:	058bb783          	ld	a5,88(s7)
    80005a0e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005a12:	85ea                	mv	a1,s10
    80005a14:	ffffc097          	auipc	ra,0xffffc
    80005a18:	34e080e7          	jalr	846(ra) # 80001d62 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005a1c:	0004851b          	sext.w	a0,s1
    80005a20:	b3f9                	j	800057ee <exec+0x9c>
    80005a22:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005a26:	df843583          	ld	a1,-520(s0)
    80005a2a:	855a                	mv	a0,s6
    80005a2c:	ffffc097          	auipc	ra,0xffffc
    80005a30:	336080e7          	jalr	822(ra) # 80001d62 <proc_freepagetable>
  if(ip){
    80005a34:	da0a93e3          	bnez	s5,800057da <exec+0x88>
  return -1;
    80005a38:	557d                	li	a0,-1
    80005a3a:	bb55                	j	800057ee <exec+0x9c>
    80005a3c:	df243c23          	sd	s2,-520(s0)
    80005a40:	b7dd                	j	80005a26 <exec+0x2d4>
    80005a42:	df243c23          	sd	s2,-520(s0)
    80005a46:	b7c5                	j	80005a26 <exec+0x2d4>
    80005a48:	df243c23          	sd	s2,-520(s0)
    80005a4c:	bfe9                	j	80005a26 <exec+0x2d4>
    80005a4e:	df243c23          	sd	s2,-520(s0)
    80005a52:	bfd1                	j	80005a26 <exec+0x2d4>
  sz = sz1;
    80005a54:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005a58:	4a81                	li	s5,0
    80005a5a:	b7f1                	j	80005a26 <exec+0x2d4>
  sz = sz1;
    80005a5c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005a60:	4a81                	li	s5,0
    80005a62:	b7d1                	j	80005a26 <exec+0x2d4>
  sz = sz1;
    80005a64:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005a68:	4a81                	li	s5,0
    80005a6a:	bf75                	j	80005a26 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005a6c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005a70:	e0843783          	ld	a5,-504(s0)
    80005a74:	0017869b          	addiw	a3,a5,1
    80005a78:	e0d43423          	sd	a3,-504(s0)
    80005a7c:	e0043783          	ld	a5,-512(s0)
    80005a80:	0387879b          	addiw	a5,a5,56
    80005a84:	e8845703          	lhu	a4,-376(s0)
    80005a88:	e0e6dfe3          	bge	a3,a4,800058a6 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005a8c:	2781                	sext.w	a5,a5
    80005a8e:	e0f43023          	sd	a5,-512(s0)
    80005a92:	03800713          	li	a4,56
    80005a96:	86be                	mv	a3,a5
    80005a98:	e1840613          	addi	a2,s0,-488
    80005a9c:	4581                	li	a1,0
    80005a9e:	8556                	mv	a0,s5
    80005aa0:	fffff097          	auipc	ra,0xfffff
    80005aa4:	a58080e7          	jalr	-1448(ra) # 800044f8 <readi>
    80005aa8:	03800793          	li	a5,56
    80005aac:	f6f51be3          	bne	a0,a5,80005a22 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80005ab0:	e1842783          	lw	a5,-488(s0)
    80005ab4:	4705                	li	a4,1
    80005ab6:	fae79de3          	bne	a5,a4,80005a70 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005aba:	e4043483          	ld	s1,-448(s0)
    80005abe:	e3843783          	ld	a5,-456(s0)
    80005ac2:	f6f4ede3          	bltu	s1,a5,80005a3c <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005ac6:	e2843783          	ld	a5,-472(s0)
    80005aca:	94be                	add	s1,s1,a5
    80005acc:	f6f4ebe3          	bltu	s1,a5,80005a42 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80005ad0:	de043703          	ld	a4,-544(s0)
    80005ad4:	8ff9                	and	a5,a5,a4
    80005ad6:	fbad                	bnez	a5,80005a48 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005ad8:	e1c42503          	lw	a0,-484(s0)
    80005adc:	00000097          	auipc	ra,0x0
    80005ae0:	c5c080e7          	jalr	-932(ra) # 80005738 <flags2perm>
    80005ae4:	86aa                	mv	a3,a0
    80005ae6:	8626                	mv	a2,s1
    80005ae8:	85ca                	mv	a1,s2
    80005aea:	855a                	mv	a0,s6
    80005aec:	ffffc097          	auipc	ra,0xffffc
    80005af0:	a64080e7          	jalr	-1436(ra) # 80001550 <uvmalloc>
    80005af4:	dea43c23          	sd	a0,-520(s0)
    80005af8:	d939                	beqz	a0,80005a4e <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005afa:	e2843c03          	ld	s8,-472(s0)
    80005afe:	e2042c83          	lw	s9,-480(s0)
    80005b02:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005b06:	f60b83e3          	beqz	s7,80005a6c <exec+0x31a>
    80005b0a:	89de                	mv	s3,s7
    80005b0c:	4481                	li	s1,0
    80005b0e:	bb9d                	j	80005884 <exec+0x132>

0000000080005b10 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005b10:	7179                	addi	sp,sp,-48
    80005b12:	f406                	sd	ra,40(sp)
    80005b14:	f022                	sd	s0,32(sp)
    80005b16:	ec26                	sd	s1,24(sp)
    80005b18:	e84a                	sd	s2,16(sp)
    80005b1a:	1800                	addi	s0,sp,48
    80005b1c:	892e                	mv	s2,a1
    80005b1e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005b20:	fdc40593          	addi	a1,s0,-36
    80005b24:	ffffd097          	auipc	ra,0xffffd
    80005b28:	7ca080e7          	jalr	1994(ra) # 800032ee <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005b2c:	fdc42703          	lw	a4,-36(s0)
    80005b30:	47bd                	li	a5,15
    80005b32:	02e7eb63          	bltu	a5,a4,80005b68 <argfd+0x58>
    80005b36:	ffffc097          	auipc	ra,0xffffc
    80005b3a:	02a080e7          	jalr	42(ra) # 80001b60 <myproc>
    80005b3e:	fdc42703          	lw	a4,-36(s0)
    80005b42:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7fdbaf3a>
    80005b46:	078e                	slli	a5,a5,0x3
    80005b48:	953e                	add	a0,a0,a5
    80005b4a:	611c                	ld	a5,0(a0)
    80005b4c:	c385                	beqz	a5,80005b6c <argfd+0x5c>
    return -1;
  if(pfd)
    80005b4e:	00090463          	beqz	s2,80005b56 <argfd+0x46>
    *pfd = fd;
    80005b52:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005b56:	4501                	li	a0,0
  if(pf)
    80005b58:	c091                	beqz	s1,80005b5c <argfd+0x4c>
    *pf = f;
    80005b5a:	e09c                	sd	a5,0(s1)
}
    80005b5c:	70a2                	ld	ra,40(sp)
    80005b5e:	7402                	ld	s0,32(sp)
    80005b60:	64e2                	ld	s1,24(sp)
    80005b62:	6942                	ld	s2,16(sp)
    80005b64:	6145                	addi	sp,sp,48
    80005b66:	8082                	ret
    return -1;
    80005b68:	557d                	li	a0,-1
    80005b6a:	bfcd                	j	80005b5c <argfd+0x4c>
    80005b6c:	557d                	li	a0,-1
    80005b6e:	b7fd                	j	80005b5c <argfd+0x4c>

0000000080005b70 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005b70:	1101                	addi	sp,sp,-32
    80005b72:	ec06                	sd	ra,24(sp)
    80005b74:	e822                	sd	s0,16(sp)
    80005b76:	e426                	sd	s1,8(sp)
    80005b78:	1000                	addi	s0,sp,32
    80005b7a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005b7c:	ffffc097          	auipc	ra,0xffffc
    80005b80:	fe4080e7          	jalr	-28(ra) # 80001b60 <myproc>
    80005b84:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005b86:	0d050793          	addi	a5,a0,208
    80005b8a:	4501                	li	a0,0
    80005b8c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005b8e:	6398                	ld	a4,0(a5)
    80005b90:	cb19                	beqz	a4,80005ba6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005b92:	2505                	addiw	a0,a0,1
    80005b94:	07a1                	addi	a5,a5,8
    80005b96:	fed51ce3          	bne	a0,a3,80005b8e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005b9a:	557d                	li	a0,-1
}
    80005b9c:	60e2                	ld	ra,24(sp)
    80005b9e:	6442                	ld	s0,16(sp)
    80005ba0:	64a2                	ld	s1,8(sp)
    80005ba2:	6105                	addi	sp,sp,32
    80005ba4:	8082                	ret
      p->ofile[fd] = f;
    80005ba6:	01a50793          	addi	a5,a0,26
    80005baa:	078e                	slli	a5,a5,0x3
    80005bac:	963e                	add	a2,a2,a5
    80005bae:	e204                	sd	s1,0(a2)
      return fd;
    80005bb0:	b7f5                	j	80005b9c <fdalloc+0x2c>

0000000080005bb2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005bb2:	715d                	addi	sp,sp,-80
    80005bb4:	e486                	sd	ra,72(sp)
    80005bb6:	e0a2                	sd	s0,64(sp)
    80005bb8:	fc26                	sd	s1,56(sp)
    80005bba:	f84a                	sd	s2,48(sp)
    80005bbc:	f44e                	sd	s3,40(sp)
    80005bbe:	f052                	sd	s4,32(sp)
    80005bc0:	ec56                	sd	s5,24(sp)
    80005bc2:	e85a                	sd	s6,16(sp)
    80005bc4:	0880                	addi	s0,sp,80
    80005bc6:	8b2e                	mv	s6,a1
    80005bc8:	89b2                	mv	s3,a2
    80005bca:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005bcc:	fb040593          	addi	a1,s0,-80
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	e3e080e7          	jalr	-450(ra) # 80004a0e <nameiparent>
    80005bd8:	84aa                	mv	s1,a0
    80005bda:	14050f63          	beqz	a0,80005d38 <create+0x186>
    return 0;

  ilock(dp);
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	666080e7          	jalr	1638(ra) # 80004244 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005be6:	4601                	li	a2,0
    80005be8:	fb040593          	addi	a1,s0,-80
    80005bec:	8526                	mv	a0,s1
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	b3a080e7          	jalr	-1222(ra) # 80004728 <dirlookup>
    80005bf6:	8aaa                	mv	s5,a0
    80005bf8:	c931                	beqz	a0,80005c4c <create+0x9a>
    iunlockput(dp);
    80005bfa:	8526                	mv	a0,s1
    80005bfc:	fffff097          	auipc	ra,0xfffff
    80005c00:	8aa080e7          	jalr	-1878(ra) # 800044a6 <iunlockput>
    ilock(ip);
    80005c04:	8556                	mv	a0,s5
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	63e080e7          	jalr	1598(ra) # 80004244 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005c0e:	000b059b          	sext.w	a1,s6
    80005c12:	4789                	li	a5,2
    80005c14:	02f59563          	bne	a1,a5,80005c3e <create+0x8c>
    80005c18:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7fdbaf64>
    80005c1c:	37f9                	addiw	a5,a5,-2
    80005c1e:	17c2                	slli	a5,a5,0x30
    80005c20:	93c1                	srli	a5,a5,0x30
    80005c22:	4705                	li	a4,1
    80005c24:	00f76d63          	bltu	a4,a5,80005c3e <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005c28:	8556                	mv	a0,s5
    80005c2a:	60a6                	ld	ra,72(sp)
    80005c2c:	6406                	ld	s0,64(sp)
    80005c2e:	74e2                	ld	s1,56(sp)
    80005c30:	7942                	ld	s2,48(sp)
    80005c32:	79a2                	ld	s3,40(sp)
    80005c34:	7a02                	ld	s4,32(sp)
    80005c36:	6ae2                	ld	s5,24(sp)
    80005c38:	6b42                	ld	s6,16(sp)
    80005c3a:	6161                	addi	sp,sp,80
    80005c3c:	8082                	ret
    iunlockput(ip);
    80005c3e:	8556                	mv	a0,s5
    80005c40:	fffff097          	auipc	ra,0xfffff
    80005c44:	866080e7          	jalr	-1946(ra) # 800044a6 <iunlockput>
    return 0;
    80005c48:	4a81                	li	s5,0
    80005c4a:	bff9                	j	80005c28 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005c4c:	85da                	mv	a1,s6
    80005c4e:	4088                	lw	a0,0(s1)
    80005c50:	ffffe097          	auipc	ra,0xffffe
    80005c54:	456080e7          	jalr	1110(ra) # 800040a6 <ialloc>
    80005c58:	8a2a                	mv	s4,a0
    80005c5a:	c539                	beqz	a0,80005ca8 <create+0xf6>
  ilock(ip);
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	5e8080e7          	jalr	1512(ra) # 80004244 <ilock>
  ip->major = major;
    80005c64:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005c68:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005c6c:	4905                	li	s2,1
    80005c6e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005c72:	8552                	mv	a0,s4
    80005c74:	ffffe097          	auipc	ra,0xffffe
    80005c78:	504080e7          	jalr	1284(ra) # 80004178 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005c7c:	000b059b          	sext.w	a1,s6
    80005c80:	03258b63          	beq	a1,s2,80005cb6 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005c84:	004a2603          	lw	a2,4(s4)
    80005c88:	fb040593          	addi	a1,s0,-80
    80005c8c:	8526                	mv	a0,s1
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	cb0080e7          	jalr	-848(ra) # 8000493e <dirlink>
    80005c96:	06054f63          	bltz	a0,80005d14 <create+0x162>
  iunlockput(dp);
    80005c9a:	8526                	mv	a0,s1
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	80a080e7          	jalr	-2038(ra) # 800044a6 <iunlockput>
  return ip;
    80005ca4:	8ad2                	mv	s5,s4
    80005ca6:	b749                	j	80005c28 <create+0x76>
    iunlockput(dp);
    80005ca8:	8526                	mv	a0,s1
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	7fc080e7          	jalr	2044(ra) # 800044a6 <iunlockput>
    return 0;
    80005cb2:	8ad2                	mv	s5,s4
    80005cb4:	bf95                	j	80005c28 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005cb6:	004a2603          	lw	a2,4(s4)
    80005cba:	00003597          	auipc	a1,0x3
    80005cbe:	cf658593          	addi	a1,a1,-778 # 800089b0 <syscallnames+0x2d0>
    80005cc2:	8552                	mv	a0,s4
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	c7a080e7          	jalr	-902(ra) # 8000493e <dirlink>
    80005ccc:	04054463          	bltz	a0,80005d14 <create+0x162>
    80005cd0:	40d0                	lw	a2,4(s1)
    80005cd2:	00003597          	auipc	a1,0x3
    80005cd6:	ce658593          	addi	a1,a1,-794 # 800089b8 <syscallnames+0x2d8>
    80005cda:	8552                	mv	a0,s4
    80005cdc:	fffff097          	auipc	ra,0xfffff
    80005ce0:	c62080e7          	jalr	-926(ra) # 8000493e <dirlink>
    80005ce4:	02054863          	bltz	a0,80005d14 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005ce8:	004a2603          	lw	a2,4(s4)
    80005cec:	fb040593          	addi	a1,s0,-80
    80005cf0:	8526                	mv	a0,s1
    80005cf2:	fffff097          	auipc	ra,0xfffff
    80005cf6:	c4c080e7          	jalr	-948(ra) # 8000493e <dirlink>
    80005cfa:	00054d63          	bltz	a0,80005d14 <create+0x162>
    dp->nlink++;  // for ".."
    80005cfe:	04a4d783          	lhu	a5,74(s1)
    80005d02:	2785                	addiw	a5,a5,1
    80005d04:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005d08:	8526                	mv	a0,s1
    80005d0a:	ffffe097          	auipc	ra,0xffffe
    80005d0e:	46e080e7          	jalr	1134(ra) # 80004178 <iupdate>
    80005d12:	b761                	j	80005c9a <create+0xe8>
  ip->nlink = 0;
    80005d14:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005d18:	8552                	mv	a0,s4
    80005d1a:	ffffe097          	auipc	ra,0xffffe
    80005d1e:	45e080e7          	jalr	1118(ra) # 80004178 <iupdate>
  iunlockput(ip);
    80005d22:	8552                	mv	a0,s4
    80005d24:	ffffe097          	auipc	ra,0xffffe
    80005d28:	782080e7          	jalr	1922(ra) # 800044a6 <iunlockput>
  iunlockput(dp);
    80005d2c:	8526                	mv	a0,s1
    80005d2e:	ffffe097          	auipc	ra,0xffffe
    80005d32:	778080e7          	jalr	1912(ra) # 800044a6 <iunlockput>
  return 0;
    80005d36:	bdcd                	j	80005c28 <create+0x76>
    return 0;
    80005d38:	8aaa                	mv	s5,a0
    80005d3a:	b5fd                	j	80005c28 <create+0x76>

0000000080005d3c <sys_dup>:
{
    80005d3c:	7179                	addi	sp,sp,-48
    80005d3e:	f406                	sd	ra,40(sp)
    80005d40:	f022                	sd	s0,32(sp)
    80005d42:	ec26                	sd	s1,24(sp)
    80005d44:	e84a                	sd	s2,16(sp)
    80005d46:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005d48:	fd840613          	addi	a2,s0,-40
    80005d4c:	4581                	li	a1,0
    80005d4e:	4501                	li	a0,0
    80005d50:	00000097          	auipc	ra,0x0
    80005d54:	dc0080e7          	jalr	-576(ra) # 80005b10 <argfd>
    return -1;
    80005d58:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005d5a:	02054363          	bltz	a0,80005d80 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005d5e:	fd843903          	ld	s2,-40(s0)
    80005d62:	854a                	mv	a0,s2
    80005d64:	00000097          	auipc	ra,0x0
    80005d68:	e0c080e7          	jalr	-500(ra) # 80005b70 <fdalloc>
    80005d6c:	84aa                	mv	s1,a0
    return -1;
    80005d6e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005d70:	00054863          	bltz	a0,80005d80 <sys_dup+0x44>
  filedup(f);
    80005d74:	854a                	mv	a0,s2
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	310080e7          	jalr	784(ra) # 80005086 <filedup>
  return fd;
    80005d7e:	87a6                	mv	a5,s1
}
    80005d80:	853e                	mv	a0,a5
    80005d82:	70a2                	ld	ra,40(sp)
    80005d84:	7402                	ld	s0,32(sp)
    80005d86:	64e2                	ld	s1,24(sp)
    80005d88:	6942                	ld	s2,16(sp)
    80005d8a:	6145                	addi	sp,sp,48
    80005d8c:	8082                	ret

0000000080005d8e <sys_read>:
{
    80005d8e:	7179                	addi	sp,sp,-48
    80005d90:	f406                	sd	ra,40(sp)
    80005d92:	f022                	sd	s0,32(sp)
    80005d94:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005d96:	fd840593          	addi	a1,s0,-40
    80005d9a:	4505                	li	a0,1
    80005d9c:	ffffd097          	auipc	ra,0xffffd
    80005da0:	572080e7          	jalr	1394(ra) # 8000330e <argaddr>
  argint(2, &n);
    80005da4:	fe440593          	addi	a1,s0,-28
    80005da8:	4509                	li	a0,2
    80005daa:	ffffd097          	auipc	ra,0xffffd
    80005dae:	544080e7          	jalr	1348(ra) # 800032ee <argint>
  count++;
    80005db2:	00003717          	auipc	a4,0x3
    80005db6:	e6670713          	addi	a4,a4,-410 # 80008c18 <count>
    80005dba:	431c                	lw	a5,0(a4)
    80005dbc:	2785                	addiw	a5,a5,1
    80005dbe:	c31c                	sw	a5,0(a4)
  if(argfd(0, 0, &f) < 0)
    80005dc0:	fe840613          	addi	a2,s0,-24
    80005dc4:	4581                	li	a1,0
    80005dc6:	4501                	li	a0,0
    80005dc8:	00000097          	auipc	ra,0x0
    80005dcc:	d48080e7          	jalr	-696(ra) # 80005b10 <argfd>
    80005dd0:	87aa                	mv	a5,a0
    return -1;
    80005dd2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005dd4:	0007cc63          	bltz	a5,80005dec <sys_read+0x5e>
  return fileread(f, p, n);
    80005dd8:	fe442603          	lw	a2,-28(s0)
    80005ddc:	fd843583          	ld	a1,-40(s0)
    80005de0:	fe843503          	ld	a0,-24(s0)
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	42e080e7          	jalr	1070(ra) # 80005212 <fileread>
}
    80005dec:	70a2                	ld	ra,40(sp)
    80005dee:	7402                	ld	s0,32(sp)
    80005df0:	6145                	addi	sp,sp,48
    80005df2:	8082                	ret

0000000080005df4 <sys_write>:
{
    80005df4:	7179                	addi	sp,sp,-48
    80005df6:	f406                	sd	ra,40(sp)
    80005df8:	f022                	sd	s0,32(sp)
    80005dfa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005dfc:	fd840593          	addi	a1,s0,-40
    80005e00:	4505                	li	a0,1
    80005e02:	ffffd097          	auipc	ra,0xffffd
    80005e06:	50c080e7          	jalr	1292(ra) # 8000330e <argaddr>
  argint(2, &n);
    80005e0a:	fe440593          	addi	a1,s0,-28
    80005e0e:	4509                	li	a0,2
    80005e10:	ffffd097          	auipc	ra,0xffffd
    80005e14:	4de080e7          	jalr	1246(ra) # 800032ee <argint>
  if(argfd(0, 0, &f) < 0)
    80005e18:	fe840613          	addi	a2,s0,-24
    80005e1c:	4581                	li	a1,0
    80005e1e:	4501                	li	a0,0
    80005e20:	00000097          	auipc	ra,0x0
    80005e24:	cf0080e7          	jalr	-784(ra) # 80005b10 <argfd>
    80005e28:	87aa                	mv	a5,a0
    return -1;
    80005e2a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005e2c:	0007cc63          	bltz	a5,80005e44 <sys_write+0x50>
  return filewrite(f, p, n);
    80005e30:	fe442603          	lw	a2,-28(s0)
    80005e34:	fd843583          	ld	a1,-40(s0)
    80005e38:	fe843503          	ld	a0,-24(s0)
    80005e3c:	fffff097          	auipc	ra,0xfffff
    80005e40:	498080e7          	jalr	1176(ra) # 800052d4 <filewrite>
}
    80005e44:	70a2                	ld	ra,40(sp)
    80005e46:	7402                	ld	s0,32(sp)
    80005e48:	6145                	addi	sp,sp,48
    80005e4a:	8082                	ret

0000000080005e4c <sys_close>:
{
    80005e4c:	1101                	addi	sp,sp,-32
    80005e4e:	ec06                	sd	ra,24(sp)
    80005e50:	e822                	sd	s0,16(sp)
    80005e52:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005e54:	fe040613          	addi	a2,s0,-32
    80005e58:	fec40593          	addi	a1,s0,-20
    80005e5c:	4501                	li	a0,0
    80005e5e:	00000097          	auipc	ra,0x0
    80005e62:	cb2080e7          	jalr	-846(ra) # 80005b10 <argfd>
    return -1;
    80005e66:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005e68:	02054463          	bltz	a0,80005e90 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005e6c:	ffffc097          	auipc	ra,0xffffc
    80005e70:	cf4080e7          	jalr	-780(ra) # 80001b60 <myproc>
    80005e74:	fec42783          	lw	a5,-20(s0)
    80005e78:	07e9                	addi	a5,a5,26
    80005e7a:	078e                	slli	a5,a5,0x3
    80005e7c:	953e                	add	a0,a0,a5
    80005e7e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005e82:	fe043503          	ld	a0,-32(s0)
    80005e86:	fffff097          	auipc	ra,0xfffff
    80005e8a:	252080e7          	jalr	594(ra) # 800050d8 <fileclose>
  return 0;
    80005e8e:	4781                	li	a5,0
}
    80005e90:	853e                	mv	a0,a5
    80005e92:	60e2                	ld	ra,24(sp)
    80005e94:	6442                	ld	s0,16(sp)
    80005e96:	6105                	addi	sp,sp,32
    80005e98:	8082                	ret

0000000080005e9a <sys_fstat>:
{
    80005e9a:	1101                	addi	sp,sp,-32
    80005e9c:	ec06                	sd	ra,24(sp)
    80005e9e:	e822                	sd	s0,16(sp)
    80005ea0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005ea2:	fe040593          	addi	a1,s0,-32
    80005ea6:	4505                	li	a0,1
    80005ea8:	ffffd097          	auipc	ra,0xffffd
    80005eac:	466080e7          	jalr	1126(ra) # 8000330e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005eb0:	fe840613          	addi	a2,s0,-24
    80005eb4:	4581                	li	a1,0
    80005eb6:	4501                	li	a0,0
    80005eb8:	00000097          	auipc	ra,0x0
    80005ebc:	c58080e7          	jalr	-936(ra) # 80005b10 <argfd>
    80005ec0:	87aa                	mv	a5,a0
    return -1;
    80005ec2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005ec4:	0007ca63          	bltz	a5,80005ed8 <sys_fstat+0x3e>
  return filestat(f, st);
    80005ec8:	fe043583          	ld	a1,-32(s0)
    80005ecc:	fe843503          	ld	a0,-24(s0)
    80005ed0:	fffff097          	auipc	ra,0xfffff
    80005ed4:	2d0080e7          	jalr	720(ra) # 800051a0 <filestat>
}
    80005ed8:	60e2                	ld	ra,24(sp)
    80005eda:	6442                	ld	s0,16(sp)
    80005edc:	6105                	addi	sp,sp,32
    80005ede:	8082                	ret

0000000080005ee0 <sys_link>:
{
    80005ee0:	7169                	addi	sp,sp,-304
    80005ee2:	f606                	sd	ra,296(sp)
    80005ee4:	f222                	sd	s0,288(sp)
    80005ee6:	ee26                	sd	s1,280(sp)
    80005ee8:	ea4a                	sd	s2,272(sp)
    80005eea:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005eec:	08000613          	li	a2,128
    80005ef0:	ed040593          	addi	a1,s0,-304
    80005ef4:	4501                	li	a0,0
    80005ef6:	ffffd097          	auipc	ra,0xffffd
    80005efa:	438080e7          	jalr	1080(ra) # 8000332e <argstr>
    return -1;
    80005efe:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f00:	10054e63          	bltz	a0,8000601c <sys_link+0x13c>
    80005f04:	08000613          	li	a2,128
    80005f08:	f5040593          	addi	a1,s0,-176
    80005f0c:	4505                	li	a0,1
    80005f0e:	ffffd097          	auipc	ra,0xffffd
    80005f12:	420080e7          	jalr	1056(ra) # 8000332e <argstr>
    return -1;
    80005f16:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f18:	10054263          	bltz	a0,8000601c <sys_link+0x13c>
  begin_op();
    80005f1c:	fffff097          	auipc	ra,0xfffff
    80005f20:	cf4080e7          	jalr	-780(ra) # 80004c10 <begin_op>
  if((ip = namei(old)) == 0){
    80005f24:	ed040513          	addi	a0,s0,-304
    80005f28:	fffff097          	auipc	ra,0xfffff
    80005f2c:	ac8080e7          	jalr	-1336(ra) # 800049f0 <namei>
    80005f30:	84aa                	mv	s1,a0
    80005f32:	c551                	beqz	a0,80005fbe <sys_link+0xde>
  ilock(ip);
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	310080e7          	jalr	784(ra) # 80004244 <ilock>
  if(ip->type == T_DIR){
    80005f3c:	04449703          	lh	a4,68(s1)
    80005f40:	4785                	li	a5,1
    80005f42:	08f70463          	beq	a4,a5,80005fca <sys_link+0xea>
  ip->nlink++;
    80005f46:	04a4d783          	lhu	a5,74(s1)
    80005f4a:	2785                	addiw	a5,a5,1
    80005f4c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005f50:	8526                	mv	a0,s1
    80005f52:	ffffe097          	auipc	ra,0xffffe
    80005f56:	226080e7          	jalr	550(ra) # 80004178 <iupdate>
  iunlock(ip);
    80005f5a:	8526                	mv	a0,s1
    80005f5c:	ffffe097          	auipc	ra,0xffffe
    80005f60:	3aa080e7          	jalr	938(ra) # 80004306 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005f64:	fd040593          	addi	a1,s0,-48
    80005f68:	f5040513          	addi	a0,s0,-176
    80005f6c:	fffff097          	auipc	ra,0xfffff
    80005f70:	aa2080e7          	jalr	-1374(ra) # 80004a0e <nameiparent>
    80005f74:	892a                	mv	s2,a0
    80005f76:	c935                	beqz	a0,80005fea <sys_link+0x10a>
  ilock(dp);
    80005f78:	ffffe097          	auipc	ra,0xffffe
    80005f7c:	2cc080e7          	jalr	716(ra) # 80004244 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005f80:	00092703          	lw	a4,0(s2)
    80005f84:	409c                	lw	a5,0(s1)
    80005f86:	04f71d63          	bne	a4,a5,80005fe0 <sys_link+0x100>
    80005f8a:	40d0                	lw	a2,4(s1)
    80005f8c:	fd040593          	addi	a1,s0,-48
    80005f90:	854a                	mv	a0,s2
    80005f92:	fffff097          	auipc	ra,0xfffff
    80005f96:	9ac080e7          	jalr	-1620(ra) # 8000493e <dirlink>
    80005f9a:	04054363          	bltz	a0,80005fe0 <sys_link+0x100>
  iunlockput(dp);
    80005f9e:	854a                	mv	a0,s2
    80005fa0:	ffffe097          	auipc	ra,0xffffe
    80005fa4:	506080e7          	jalr	1286(ra) # 800044a6 <iunlockput>
  iput(ip);
    80005fa8:	8526                	mv	a0,s1
    80005faa:	ffffe097          	auipc	ra,0xffffe
    80005fae:	454080e7          	jalr	1108(ra) # 800043fe <iput>
  end_op();
    80005fb2:	fffff097          	auipc	ra,0xfffff
    80005fb6:	cdc080e7          	jalr	-804(ra) # 80004c8e <end_op>
  return 0;
    80005fba:	4781                	li	a5,0
    80005fbc:	a085                	j	8000601c <sys_link+0x13c>
    end_op();
    80005fbe:	fffff097          	auipc	ra,0xfffff
    80005fc2:	cd0080e7          	jalr	-816(ra) # 80004c8e <end_op>
    return -1;
    80005fc6:	57fd                	li	a5,-1
    80005fc8:	a891                	j	8000601c <sys_link+0x13c>
    iunlockput(ip);
    80005fca:	8526                	mv	a0,s1
    80005fcc:	ffffe097          	auipc	ra,0xffffe
    80005fd0:	4da080e7          	jalr	1242(ra) # 800044a6 <iunlockput>
    end_op();
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	cba080e7          	jalr	-838(ra) # 80004c8e <end_op>
    return -1;
    80005fdc:	57fd                	li	a5,-1
    80005fde:	a83d                	j	8000601c <sys_link+0x13c>
    iunlockput(dp);
    80005fe0:	854a                	mv	a0,s2
    80005fe2:	ffffe097          	auipc	ra,0xffffe
    80005fe6:	4c4080e7          	jalr	1220(ra) # 800044a6 <iunlockput>
  ilock(ip);
    80005fea:	8526                	mv	a0,s1
    80005fec:	ffffe097          	auipc	ra,0xffffe
    80005ff0:	258080e7          	jalr	600(ra) # 80004244 <ilock>
  ip->nlink--;
    80005ff4:	04a4d783          	lhu	a5,74(s1)
    80005ff8:	37fd                	addiw	a5,a5,-1
    80005ffa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ffe:	8526                	mv	a0,s1
    80006000:	ffffe097          	auipc	ra,0xffffe
    80006004:	178080e7          	jalr	376(ra) # 80004178 <iupdate>
  iunlockput(ip);
    80006008:	8526                	mv	a0,s1
    8000600a:	ffffe097          	auipc	ra,0xffffe
    8000600e:	49c080e7          	jalr	1180(ra) # 800044a6 <iunlockput>
  end_op();
    80006012:	fffff097          	auipc	ra,0xfffff
    80006016:	c7c080e7          	jalr	-900(ra) # 80004c8e <end_op>
  return -1;
    8000601a:	57fd                	li	a5,-1
}
    8000601c:	853e                	mv	a0,a5
    8000601e:	70b2                	ld	ra,296(sp)
    80006020:	7412                	ld	s0,288(sp)
    80006022:	64f2                	ld	s1,280(sp)
    80006024:	6952                	ld	s2,272(sp)
    80006026:	6155                	addi	sp,sp,304
    80006028:	8082                	ret

000000008000602a <sys_unlink>:
{
    8000602a:	7151                	addi	sp,sp,-240
    8000602c:	f586                	sd	ra,232(sp)
    8000602e:	f1a2                	sd	s0,224(sp)
    80006030:	eda6                	sd	s1,216(sp)
    80006032:	e9ca                	sd	s2,208(sp)
    80006034:	e5ce                	sd	s3,200(sp)
    80006036:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006038:	08000613          	li	a2,128
    8000603c:	f3040593          	addi	a1,s0,-208
    80006040:	4501                	li	a0,0
    80006042:	ffffd097          	auipc	ra,0xffffd
    80006046:	2ec080e7          	jalr	748(ra) # 8000332e <argstr>
    8000604a:	18054163          	bltz	a0,800061cc <sys_unlink+0x1a2>
  begin_op();
    8000604e:	fffff097          	auipc	ra,0xfffff
    80006052:	bc2080e7          	jalr	-1086(ra) # 80004c10 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006056:	fb040593          	addi	a1,s0,-80
    8000605a:	f3040513          	addi	a0,s0,-208
    8000605e:	fffff097          	auipc	ra,0xfffff
    80006062:	9b0080e7          	jalr	-1616(ra) # 80004a0e <nameiparent>
    80006066:	84aa                	mv	s1,a0
    80006068:	c979                	beqz	a0,8000613e <sys_unlink+0x114>
  ilock(dp);
    8000606a:	ffffe097          	auipc	ra,0xffffe
    8000606e:	1da080e7          	jalr	474(ra) # 80004244 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006072:	00003597          	auipc	a1,0x3
    80006076:	93e58593          	addi	a1,a1,-1730 # 800089b0 <syscallnames+0x2d0>
    8000607a:	fb040513          	addi	a0,s0,-80
    8000607e:	ffffe097          	auipc	ra,0xffffe
    80006082:	690080e7          	jalr	1680(ra) # 8000470e <namecmp>
    80006086:	14050a63          	beqz	a0,800061da <sys_unlink+0x1b0>
    8000608a:	00003597          	auipc	a1,0x3
    8000608e:	92e58593          	addi	a1,a1,-1746 # 800089b8 <syscallnames+0x2d8>
    80006092:	fb040513          	addi	a0,s0,-80
    80006096:	ffffe097          	auipc	ra,0xffffe
    8000609a:	678080e7          	jalr	1656(ra) # 8000470e <namecmp>
    8000609e:	12050e63          	beqz	a0,800061da <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800060a2:	f2c40613          	addi	a2,s0,-212
    800060a6:	fb040593          	addi	a1,s0,-80
    800060aa:	8526                	mv	a0,s1
    800060ac:	ffffe097          	auipc	ra,0xffffe
    800060b0:	67c080e7          	jalr	1660(ra) # 80004728 <dirlookup>
    800060b4:	892a                	mv	s2,a0
    800060b6:	12050263          	beqz	a0,800061da <sys_unlink+0x1b0>
  ilock(ip);
    800060ba:	ffffe097          	auipc	ra,0xffffe
    800060be:	18a080e7          	jalr	394(ra) # 80004244 <ilock>
  if(ip->nlink < 1)
    800060c2:	04a91783          	lh	a5,74(s2)
    800060c6:	08f05263          	blez	a5,8000614a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800060ca:	04491703          	lh	a4,68(s2)
    800060ce:	4785                	li	a5,1
    800060d0:	08f70563          	beq	a4,a5,8000615a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800060d4:	4641                	li	a2,16
    800060d6:	4581                	li	a1,0
    800060d8:	fc040513          	addi	a0,s0,-64
    800060dc:	ffffb097          	auipc	ra,0xffffb
    800060e0:	d36080e7          	jalr	-714(ra) # 80000e12 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800060e4:	4741                	li	a4,16
    800060e6:	f2c42683          	lw	a3,-212(s0)
    800060ea:	fc040613          	addi	a2,s0,-64
    800060ee:	4581                	li	a1,0
    800060f0:	8526                	mv	a0,s1
    800060f2:	ffffe097          	auipc	ra,0xffffe
    800060f6:	4fe080e7          	jalr	1278(ra) # 800045f0 <writei>
    800060fa:	47c1                	li	a5,16
    800060fc:	0af51563          	bne	a0,a5,800061a6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006100:	04491703          	lh	a4,68(s2)
    80006104:	4785                	li	a5,1
    80006106:	0af70863          	beq	a4,a5,800061b6 <sys_unlink+0x18c>
  iunlockput(dp);
    8000610a:	8526                	mv	a0,s1
    8000610c:	ffffe097          	auipc	ra,0xffffe
    80006110:	39a080e7          	jalr	922(ra) # 800044a6 <iunlockput>
  ip->nlink--;
    80006114:	04a95783          	lhu	a5,74(s2)
    80006118:	37fd                	addiw	a5,a5,-1
    8000611a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000611e:	854a                	mv	a0,s2
    80006120:	ffffe097          	auipc	ra,0xffffe
    80006124:	058080e7          	jalr	88(ra) # 80004178 <iupdate>
  iunlockput(ip);
    80006128:	854a                	mv	a0,s2
    8000612a:	ffffe097          	auipc	ra,0xffffe
    8000612e:	37c080e7          	jalr	892(ra) # 800044a6 <iunlockput>
  end_op();
    80006132:	fffff097          	auipc	ra,0xfffff
    80006136:	b5c080e7          	jalr	-1188(ra) # 80004c8e <end_op>
  return 0;
    8000613a:	4501                	li	a0,0
    8000613c:	a84d                	j	800061ee <sys_unlink+0x1c4>
    end_op();
    8000613e:	fffff097          	auipc	ra,0xfffff
    80006142:	b50080e7          	jalr	-1200(ra) # 80004c8e <end_op>
    return -1;
    80006146:	557d                	li	a0,-1
    80006148:	a05d                	j	800061ee <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000614a:	00003517          	auipc	a0,0x3
    8000614e:	87650513          	addi	a0,a0,-1930 # 800089c0 <syscallnames+0x2e0>
    80006152:	ffffa097          	auipc	ra,0xffffa
    80006156:	3ee080e7          	jalr	1006(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000615a:	04c92703          	lw	a4,76(s2)
    8000615e:	02000793          	li	a5,32
    80006162:	f6e7f9e3          	bgeu	a5,a4,800060d4 <sys_unlink+0xaa>
    80006166:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000616a:	4741                	li	a4,16
    8000616c:	86ce                	mv	a3,s3
    8000616e:	f1840613          	addi	a2,s0,-232
    80006172:	4581                	li	a1,0
    80006174:	854a                	mv	a0,s2
    80006176:	ffffe097          	auipc	ra,0xffffe
    8000617a:	382080e7          	jalr	898(ra) # 800044f8 <readi>
    8000617e:	47c1                	li	a5,16
    80006180:	00f51b63          	bne	a0,a5,80006196 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006184:	f1845783          	lhu	a5,-232(s0)
    80006188:	e7a1                	bnez	a5,800061d0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000618a:	29c1                	addiw	s3,s3,16
    8000618c:	04c92783          	lw	a5,76(s2)
    80006190:	fcf9ede3          	bltu	s3,a5,8000616a <sys_unlink+0x140>
    80006194:	b781                	j	800060d4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006196:	00003517          	auipc	a0,0x3
    8000619a:	84250513          	addi	a0,a0,-1982 # 800089d8 <syscallnames+0x2f8>
    8000619e:	ffffa097          	auipc	ra,0xffffa
    800061a2:	3a2080e7          	jalr	930(ra) # 80000540 <panic>
    panic("unlink: writei");
    800061a6:	00003517          	auipc	a0,0x3
    800061aa:	84a50513          	addi	a0,a0,-1974 # 800089f0 <syscallnames+0x310>
    800061ae:	ffffa097          	auipc	ra,0xffffa
    800061b2:	392080e7          	jalr	914(ra) # 80000540 <panic>
    dp->nlink--;
    800061b6:	04a4d783          	lhu	a5,74(s1)
    800061ba:	37fd                	addiw	a5,a5,-1
    800061bc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800061c0:	8526                	mv	a0,s1
    800061c2:	ffffe097          	auipc	ra,0xffffe
    800061c6:	fb6080e7          	jalr	-74(ra) # 80004178 <iupdate>
    800061ca:	b781                	j	8000610a <sys_unlink+0xe0>
    return -1;
    800061cc:	557d                	li	a0,-1
    800061ce:	a005                	j	800061ee <sys_unlink+0x1c4>
    iunlockput(ip);
    800061d0:	854a                	mv	a0,s2
    800061d2:	ffffe097          	auipc	ra,0xffffe
    800061d6:	2d4080e7          	jalr	724(ra) # 800044a6 <iunlockput>
  iunlockput(dp);
    800061da:	8526                	mv	a0,s1
    800061dc:	ffffe097          	auipc	ra,0xffffe
    800061e0:	2ca080e7          	jalr	714(ra) # 800044a6 <iunlockput>
  end_op();
    800061e4:	fffff097          	auipc	ra,0xfffff
    800061e8:	aaa080e7          	jalr	-1366(ra) # 80004c8e <end_op>
  return -1;
    800061ec:	557d                	li	a0,-1
}
    800061ee:	70ae                	ld	ra,232(sp)
    800061f0:	740e                	ld	s0,224(sp)
    800061f2:	64ee                	ld	s1,216(sp)
    800061f4:	694e                	ld	s2,208(sp)
    800061f6:	69ae                	ld	s3,200(sp)
    800061f8:	616d                	addi	sp,sp,240
    800061fa:	8082                	ret

00000000800061fc <sys_open>:

uint64
sys_open(void)
{
    800061fc:	7131                	addi	sp,sp,-192
    800061fe:	fd06                	sd	ra,184(sp)
    80006200:	f922                	sd	s0,176(sp)
    80006202:	f526                	sd	s1,168(sp)
    80006204:	f14a                	sd	s2,160(sp)
    80006206:	ed4e                	sd	s3,152(sp)
    80006208:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000620a:	f4c40593          	addi	a1,s0,-180
    8000620e:	4505                	li	a0,1
    80006210:	ffffd097          	auipc	ra,0xffffd
    80006214:	0de080e7          	jalr	222(ra) # 800032ee <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006218:	08000613          	li	a2,128
    8000621c:	f5040593          	addi	a1,s0,-176
    80006220:	4501                	li	a0,0
    80006222:	ffffd097          	auipc	ra,0xffffd
    80006226:	10c080e7          	jalr	268(ra) # 8000332e <argstr>
    8000622a:	87aa                	mv	a5,a0
    return -1;
    8000622c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000622e:	0a07c963          	bltz	a5,800062e0 <sys_open+0xe4>

  begin_op();
    80006232:	fffff097          	auipc	ra,0xfffff
    80006236:	9de080e7          	jalr	-1570(ra) # 80004c10 <begin_op>

  if(omode & O_CREATE){
    8000623a:	f4c42783          	lw	a5,-180(s0)
    8000623e:	2007f793          	andi	a5,a5,512
    80006242:	cfc5                	beqz	a5,800062fa <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006244:	4681                	li	a3,0
    80006246:	4601                	li	a2,0
    80006248:	4589                	li	a1,2
    8000624a:	f5040513          	addi	a0,s0,-176
    8000624e:	00000097          	auipc	ra,0x0
    80006252:	964080e7          	jalr	-1692(ra) # 80005bb2 <create>
    80006256:	84aa                	mv	s1,a0
    if(ip == 0){
    80006258:	c959                	beqz	a0,800062ee <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000625a:	04449703          	lh	a4,68(s1)
    8000625e:	478d                	li	a5,3
    80006260:	00f71763          	bne	a4,a5,8000626e <sys_open+0x72>
    80006264:	0464d703          	lhu	a4,70(s1)
    80006268:	47a5                	li	a5,9
    8000626a:	0ce7ed63          	bltu	a5,a4,80006344 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000626e:	fffff097          	auipc	ra,0xfffff
    80006272:	dae080e7          	jalr	-594(ra) # 8000501c <filealloc>
    80006276:	89aa                	mv	s3,a0
    80006278:	10050363          	beqz	a0,8000637e <sys_open+0x182>
    8000627c:	00000097          	auipc	ra,0x0
    80006280:	8f4080e7          	jalr	-1804(ra) # 80005b70 <fdalloc>
    80006284:	892a                	mv	s2,a0
    80006286:	0e054763          	bltz	a0,80006374 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000628a:	04449703          	lh	a4,68(s1)
    8000628e:	478d                	li	a5,3
    80006290:	0cf70563          	beq	a4,a5,8000635a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006294:	4789                	li	a5,2
    80006296:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000629a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000629e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800062a2:	f4c42783          	lw	a5,-180(s0)
    800062a6:	0017c713          	xori	a4,a5,1
    800062aa:	8b05                	andi	a4,a4,1
    800062ac:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800062b0:	0037f713          	andi	a4,a5,3
    800062b4:	00e03733          	snez	a4,a4
    800062b8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800062bc:	4007f793          	andi	a5,a5,1024
    800062c0:	c791                	beqz	a5,800062cc <sys_open+0xd0>
    800062c2:	04449703          	lh	a4,68(s1)
    800062c6:	4789                	li	a5,2
    800062c8:	0af70063          	beq	a4,a5,80006368 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800062cc:	8526                	mv	a0,s1
    800062ce:	ffffe097          	auipc	ra,0xffffe
    800062d2:	038080e7          	jalr	56(ra) # 80004306 <iunlock>
  end_op();
    800062d6:	fffff097          	auipc	ra,0xfffff
    800062da:	9b8080e7          	jalr	-1608(ra) # 80004c8e <end_op>

  return fd;
    800062de:	854a                	mv	a0,s2
}
    800062e0:	70ea                	ld	ra,184(sp)
    800062e2:	744a                	ld	s0,176(sp)
    800062e4:	74aa                	ld	s1,168(sp)
    800062e6:	790a                	ld	s2,160(sp)
    800062e8:	69ea                	ld	s3,152(sp)
    800062ea:	6129                	addi	sp,sp,192
    800062ec:	8082                	ret
      end_op();
    800062ee:	fffff097          	auipc	ra,0xfffff
    800062f2:	9a0080e7          	jalr	-1632(ra) # 80004c8e <end_op>
      return -1;
    800062f6:	557d                	li	a0,-1
    800062f8:	b7e5                	j	800062e0 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800062fa:	f5040513          	addi	a0,s0,-176
    800062fe:	ffffe097          	auipc	ra,0xffffe
    80006302:	6f2080e7          	jalr	1778(ra) # 800049f0 <namei>
    80006306:	84aa                	mv	s1,a0
    80006308:	c905                	beqz	a0,80006338 <sys_open+0x13c>
    ilock(ip);
    8000630a:	ffffe097          	auipc	ra,0xffffe
    8000630e:	f3a080e7          	jalr	-198(ra) # 80004244 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006312:	04449703          	lh	a4,68(s1)
    80006316:	4785                	li	a5,1
    80006318:	f4f711e3          	bne	a4,a5,8000625a <sys_open+0x5e>
    8000631c:	f4c42783          	lw	a5,-180(s0)
    80006320:	d7b9                	beqz	a5,8000626e <sys_open+0x72>
      iunlockput(ip);
    80006322:	8526                	mv	a0,s1
    80006324:	ffffe097          	auipc	ra,0xffffe
    80006328:	182080e7          	jalr	386(ra) # 800044a6 <iunlockput>
      end_op();
    8000632c:	fffff097          	auipc	ra,0xfffff
    80006330:	962080e7          	jalr	-1694(ra) # 80004c8e <end_op>
      return -1;
    80006334:	557d                	li	a0,-1
    80006336:	b76d                	j	800062e0 <sys_open+0xe4>
      end_op();
    80006338:	fffff097          	auipc	ra,0xfffff
    8000633c:	956080e7          	jalr	-1706(ra) # 80004c8e <end_op>
      return -1;
    80006340:	557d                	li	a0,-1
    80006342:	bf79                	j	800062e0 <sys_open+0xe4>
    iunlockput(ip);
    80006344:	8526                	mv	a0,s1
    80006346:	ffffe097          	auipc	ra,0xffffe
    8000634a:	160080e7          	jalr	352(ra) # 800044a6 <iunlockput>
    end_op();
    8000634e:	fffff097          	auipc	ra,0xfffff
    80006352:	940080e7          	jalr	-1728(ra) # 80004c8e <end_op>
    return -1;
    80006356:	557d                	li	a0,-1
    80006358:	b761                	j	800062e0 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000635a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000635e:	04649783          	lh	a5,70(s1)
    80006362:	02f99223          	sh	a5,36(s3)
    80006366:	bf25                	j	8000629e <sys_open+0xa2>
    itrunc(ip);
    80006368:	8526                	mv	a0,s1
    8000636a:	ffffe097          	auipc	ra,0xffffe
    8000636e:	fe8080e7          	jalr	-24(ra) # 80004352 <itrunc>
    80006372:	bfa9                	j	800062cc <sys_open+0xd0>
      fileclose(f);
    80006374:	854e                	mv	a0,s3
    80006376:	fffff097          	auipc	ra,0xfffff
    8000637a:	d62080e7          	jalr	-670(ra) # 800050d8 <fileclose>
    iunlockput(ip);
    8000637e:	8526                	mv	a0,s1
    80006380:	ffffe097          	auipc	ra,0xffffe
    80006384:	126080e7          	jalr	294(ra) # 800044a6 <iunlockput>
    end_op();
    80006388:	fffff097          	auipc	ra,0xfffff
    8000638c:	906080e7          	jalr	-1786(ra) # 80004c8e <end_op>
    return -1;
    80006390:	557d                	li	a0,-1
    80006392:	b7b9                	j	800062e0 <sys_open+0xe4>

0000000080006394 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006394:	7175                	addi	sp,sp,-144
    80006396:	e506                	sd	ra,136(sp)
    80006398:	e122                	sd	s0,128(sp)
    8000639a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000639c:	fffff097          	auipc	ra,0xfffff
    800063a0:	874080e7          	jalr	-1932(ra) # 80004c10 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800063a4:	08000613          	li	a2,128
    800063a8:	f7040593          	addi	a1,s0,-144
    800063ac:	4501                	li	a0,0
    800063ae:	ffffd097          	auipc	ra,0xffffd
    800063b2:	f80080e7          	jalr	-128(ra) # 8000332e <argstr>
    800063b6:	02054963          	bltz	a0,800063e8 <sys_mkdir+0x54>
    800063ba:	4681                	li	a3,0
    800063bc:	4601                	li	a2,0
    800063be:	4585                	li	a1,1
    800063c0:	f7040513          	addi	a0,s0,-144
    800063c4:	fffff097          	auipc	ra,0xfffff
    800063c8:	7ee080e7          	jalr	2030(ra) # 80005bb2 <create>
    800063cc:	cd11                	beqz	a0,800063e8 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800063ce:	ffffe097          	auipc	ra,0xffffe
    800063d2:	0d8080e7          	jalr	216(ra) # 800044a6 <iunlockput>
  end_op();
    800063d6:	fffff097          	auipc	ra,0xfffff
    800063da:	8b8080e7          	jalr	-1864(ra) # 80004c8e <end_op>
  return 0;
    800063de:	4501                	li	a0,0
}
    800063e0:	60aa                	ld	ra,136(sp)
    800063e2:	640a                	ld	s0,128(sp)
    800063e4:	6149                	addi	sp,sp,144
    800063e6:	8082                	ret
    end_op();
    800063e8:	fffff097          	auipc	ra,0xfffff
    800063ec:	8a6080e7          	jalr	-1882(ra) # 80004c8e <end_op>
    return -1;
    800063f0:	557d                	li	a0,-1
    800063f2:	b7fd                	j	800063e0 <sys_mkdir+0x4c>

00000000800063f4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800063f4:	7135                	addi	sp,sp,-160
    800063f6:	ed06                	sd	ra,152(sp)
    800063f8:	e922                	sd	s0,144(sp)
    800063fa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800063fc:	fffff097          	auipc	ra,0xfffff
    80006400:	814080e7          	jalr	-2028(ra) # 80004c10 <begin_op>
  argint(1, &major);
    80006404:	f6c40593          	addi	a1,s0,-148
    80006408:	4505                	li	a0,1
    8000640a:	ffffd097          	auipc	ra,0xffffd
    8000640e:	ee4080e7          	jalr	-284(ra) # 800032ee <argint>
  argint(2, &minor);
    80006412:	f6840593          	addi	a1,s0,-152
    80006416:	4509                	li	a0,2
    80006418:	ffffd097          	auipc	ra,0xffffd
    8000641c:	ed6080e7          	jalr	-298(ra) # 800032ee <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006420:	08000613          	li	a2,128
    80006424:	f7040593          	addi	a1,s0,-144
    80006428:	4501                	li	a0,0
    8000642a:	ffffd097          	auipc	ra,0xffffd
    8000642e:	f04080e7          	jalr	-252(ra) # 8000332e <argstr>
    80006432:	02054b63          	bltz	a0,80006468 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006436:	f6841683          	lh	a3,-152(s0)
    8000643a:	f6c41603          	lh	a2,-148(s0)
    8000643e:	458d                	li	a1,3
    80006440:	f7040513          	addi	a0,s0,-144
    80006444:	fffff097          	auipc	ra,0xfffff
    80006448:	76e080e7          	jalr	1902(ra) # 80005bb2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000644c:	cd11                	beqz	a0,80006468 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000644e:	ffffe097          	auipc	ra,0xffffe
    80006452:	058080e7          	jalr	88(ra) # 800044a6 <iunlockput>
  end_op();
    80006456:	fffff097          	auipc	ra,0xfffff
    8000645a:	838080e7          	jalr	-1992(ra) # 80004c8e <end_op>
  return 0;
    8000645e:	4501                	li	a0,0
}
    80006460:	60ea                	ld	ra,152(sp)
    80006462:	644a                	ld	s0,144(sp)
    80006464:	610d                	addi	sp,sp,160
    80006466:	8082                	ret
    end_op();
    80006468:	fffff097          	auipc	ra,0xfffff
    8000646c:	826080e7          	jalr	-2010(ra) # 80004c8e <end_op>
    return -1;
    80006470:	557d                	li	a0,-1
    80006472:	b7fd                	j	80006460 <sys_mknod+0x6c>

0000000080006474 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006474:	7135                	addi	sp,sp,-160
    80006476:	ed06                	sd	ra,152(sp)
    80006478:	e922                	sd	s0,144(sp)
    8000647a:	e526                	sd	s1,136(sp)
    8000647c:	e14a                	sd	s2,128(sp)
    8000647e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006480:	ffffb097          	auipc	ra,0xffffb
    80006484:	6e0080e7          	jalr	1760(ra) # 80001b60 <myproc>
    80006488:	892a                	mv	s2,a0
  
  begin_op();
    8000648a:	ffffe097          	auipc	ra,0xffffe
    8000648e:	786080e7          	jalr	1926(ra) # 80004c10 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006492:	08000613          	li	a2,128
    80006496:	f6040593          	addi	a1,s0,-160
    8000649a:	4501                	li	a0,0
    8000649c:	ffffd097          	auipc	ra,0xffffd
    800064a0:	e92080e7          	jalr	-366(ra) # 8000332e <argstr>
    800064a4:	04054b63          	bltz	a0,800064fa <sys_chdir+0x86>
    800064a8:	f6040513          	addi	a0,s0,-160
    800064ac:	ffffe097          	auipc	ra,0xffffe
    800064b0:	544080e7          	jalr	1348(ra) # 800049f0 <namei>
    800064b4:	84aa                	mv	s1,a0
    800064b6:	c131                	beqz	a0,800064fa <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800064b8:	ffffe097          	auipc	ra,0xffffe
    800064bc:	d8c080e7          	jalr	-628(ra) # 80004244 <ilock>
  if(ip->type != T_DIR){
    800064c0:	04449703          	lh	a4,68(s1)
    800064c4:	4785                	li	a5,1
    800064c6:	04f71063          	bne	a4,a5,80006506 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800064ca:	8526                	mv	a0,s1
    800064cc:	ffffe097          	auipc	ra,0xffffe
    800064d0:	e3a080e7          	jalr	-454(ra) # 80004306 <iunlock>
  iput(p->cwd);
    800064d4:	15093503          	ld	a0,336(s2)
    800064d8:	ffffe097          	auipc	ra,0xffffe
    800064dc:	f26080e7          	jalr	-218(ra) # 800043fe <iput>
  end_op();
    800064e0:	ffffe097          	auipc	ra,0xffffe
    800064e4:	7ae080e7          	jalr	1966(ra) # 80004c8e <end_op>
  p->cwd = ip;
    800064e8:	14993823          	sd	s1,336(s2)
  return 0;
    800064ec:	4501                	li	a0,0
}
    800064ee:	60ea                	ld	ra,152(sp)
    800064f0:	644a                	ld	s0,144(sp)
    800064f2:	64aa                	ld	s1,136(sp)
    800064f4:	690a                	ld	s2,128(sp)
    800064f6:	610d                	addi	sp,sp,160
    800064f8:	8082                	ret
    end_op();
    800064fa:	ffffe097          	auipc	ra,0xffffe
    800064fe:	794080e7          	jalr	1940(ra) # 80004c8e <end_op>
    return -1;
    80006502:	557d                	li	a0,-1
    80006504:	b7ed                	j	800064ee <sys_chdir+0x7a>
    iunlockput(ip);
    80006506:	8526                	mv	a0,s1
    80006508:	ffffe097          	auipc	ra,0xffffe
    8000650c:	f9e080e7          	jalr	-98(ra) # 800044a6 <iunlockput>
    end_op();
    80006510:	ffffe097          	auipc	ra,0xffffe
    80006514:	77e080e7          	jalr	1918(ra) # 80004c8e <end_op>
    return -1;
    80006518:	557d                	li	a0,-1
    8000651a:	bfd1                	j	800064ee <sys_chdir+0x7a>

000000008000651c <sys_exec>:

uint64
sys_exec(void)
{
    8000651c:	7145                	addi	sp,sp,-464
    8000651e:	e786                	sd	ra,456(sp)
    80006520:	e3a2                	sd	s0,448(sp)
    80006522:	ff26                	sd	s1,440(sp)
    80006524:	fb4a                	sd	s2,432(sp)
    80006526:	f74e                	sd	s3,424(sp)
    80006528:	f352                	sd	s4,416(sp)
    8000652a:	ef56                	sd	s5,408(sp)
    8000652c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000652e:	e3840593          	addi	a1,s0,-456
    80006532:	4505                	li	a0,1
    80006534:	ffffd097          	auipc	ra,0xffffd
    80006538:	dda080e7          	jalr	-550(ra) # 8000330e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000653c:	08000613          	li	a2,128
    80006540:	f4040593          	addi	a1,s0,-192
    80006544:	4501                	li	a0,0
    80006546:	ffffd097          	auipc	ra,0xffffd
    8000654a:	de8080e7          	jalr	-536(ra) # 8000332e <argstr>
    8000654e:	87aa                	mv	a5,a0
    return -1;
    80006550:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006552:	0c07c363          	bltz	a5,80006618 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80006556:	10000613          	li	a2,256
    8000655a:	4581                	li	a1,0
    8000655c:	e4040513          	addi	a0,s0,-448
    80006560:	ffffb097          	auipc	ra,0xffffb
    80006564:	8b2080e7          	jalr	-1870(ra) # 80000e12 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006568:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000656c:	89a6                	mv	s3,s1
    8000656e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006570:	02000a13          	li	s4,32
    80006574:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006578:	00391513          	slli	a0,s2,0x3
    8000657c:	e3040593          	addi	a1,s0,-464
    80006580:	e3843783          	ld	a5,-456(s0)
    80006584:	953e                	add	a0,a0,a5
    80006586:	ffffd097          	auipc	ra,0xffffd
    8000658a:	cca080e7          	jalr	-822(ra) # 80003250 <fetchaddr>
    8000658e:	02054a63          	bltz	a0,800065c2 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006592:	e3043783          	ld	a5,-464(s0)
    80006596:	c3b9                	beqz	a5,800065dc <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006598:	ffffa097          	auipc	ra,0xffffa
    8000659c:	650080e7          	jalr	1616(ra) # 80000be8 <kalloc>
    800065a0:	85aa                	mv	a1,a0
    800065a2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800065a6:	cd11                	beqz	a0,800065c2 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800065a8:	6605                	lui	a2,0x1
    800065aa:	e3043503          	ld	a0,-464(s0)
    800065ae:	ffffd097          	auipc	ra,0xffffd
    800065b2:	cf4080e7          	jalr	-780(ra) # 800032a2 <fetchstr>
    800065b6:	00054663          	bltz	a0,800065c2 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800065ba:	0905                	addi	s2,s2,1
    800065bc:	09a1                	addi	s3,s3,8
    800065be:	fb491be3          	bne	s2,s4,80006574 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800065c2:	f4040913          	addi	s2,s0,-192
    800065c6:	6088                	ld	a0,0(s1)
    800065c8:	c539                	beqz	a0,80006616 <sys_exec+0xfa>
    kfree(argv[i]);
    800065ca:	ffffa097          	auipc	ra,0xffffa
    800065ce:	49a080e7          	jalr	1178(ra) # 80000a64 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800065d2:	04a1                	addi	s1,s1,8
    800065d4:	ff2499e3          	bne	s1,s2,800065c6 <sys_exec+0xaa>
  return -1;
    800065d8:	557d                	li	a0,-1
    800065da:	a83d                	j	80006618 <sys_exec+0xfc>
      argv[i] = 0;
    800065dc:	0a8e                	slli	s5,s5,0x3
    800065de:	fc0a8793          	addi	a5,s5,-64
    800065e2:	00878ab3          	add	s5,a5,s0
    800065e6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800065ea:	e4040593          	addi	a1,s0,-448
    800065ee:	f4040513          	addi	a0,s0,-192
    800065f2:	fffff097          	auipc	ra,0xfffff
    800065f6:	160080e7          	jalr	352(ra) # 80005752 <exec>
    800065fa:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800065fc:	f4040993          	addi	s3,s0,-192
    80006600:	6088                	ld	a0,0(s1)
    80006602:	c901                	beqz	a0,80006612 <sys_exec+0xf6>
    kfree(argv[i]);
    80006604:	ffffa097          	auipc	ra,0xffffa
    80006608:	460080e7          	jalr	1120(ra) # 80000a64 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000660c:	04a1                	addi	s1,s1,8
    8000660e:	ff3499e3          	bne	s1,s3,80006600 <sys_exec+0xe4>
  return ret;
    80006612:	854a                	mv	a0,s2
    80006614:	a011                	j	80006618 <sys_exec+0xfc>
  return -1;
    80006616:	557d                	li	a0,-1
}
    80006618:	60be                	ld	ra,456(sp)
    8000661a:	641e                	ld	s0,448(sp)
    8000661c:	74fa                	ld	s1,440(sp)
    8000661e:	795a                	ld	s2,432(sp)
    80006620:	79ba                	ld	s3,424(sp)
    80006622:	7a1a                	ld	s4,416(sp)
    80006624:	6afa                	ld	s5,408(sp)
    80006626:	6179                	addi	sp,sp,464
    80006628:	8082                	ret

000000008000662a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000662a:	7139                	addi	sp,sp,-64
    8000662c:	fc06                	sd	ra,56(sp)
    8000662e:	f822                	sd	s0,48(sp)
    80006630:	f426                	sd	s1,40(sp)
    80006632:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006634:	ffffb097          	auipc	ra,0xffffb
    80006638:	52c080e7          	jalr	1324(ra) # 80001b60 <myproc>
    8000663c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000663e:	fd840593          	addi	a1,s0,-40
    80006642:	4501                	li	a0,0
    80006644:	ffffd097          	auipc	ra,0xffffd
    80006648:	cca080e7          	jalr	-822(ra) # 8000330e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000664c:	fc840593          	addi	a1,s0,-56
    80006650:	fd040513          	addi	a0,s0,-48
    80006654:	fffff097          	auipc	ra,0xfffff
    80006658:	db4080e7          	jalr	-588(ra) # 80005408 <pipealloc>
    return -1;
    8000665c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000665e:	0c054463          	bltz	a0,80006726 <sys_pipe+0xfc>
  fd0 = -1;
    80006662:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006666:	fd043503          	ld	a0,-48(s0)
    8000666a:	fffff097          	auipc	ra,0xfffff
    8000666e:	506080e7          	jalr	1286(ra) # 80005b70 <fdalloc>
    80006672:	fca42223          	sw	a0,-60(s0)
    80006676:	08054b63          	bltz	a0,8000670c <sys_pipe+0xe2>
    8000667a:	fc843503          	ld	a0,-56(s0)
    8000667e:	fffff097          	auipc	ra,0xfffff
    80006682:	4f2080e7          	jalr	1266(ra) # 80005b70 <fdalloc>
    80006686:	fca42023          	sw	a0,-64(s0)
    8000668a:	06054863          	bltz	a0,800066fa <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000668e:	4691                	li	a3,4
    80006690:	fc440613          	addi	a2,s0,-60
    80006694:	fd843583          	ld	a1,-40(s0)
    80006698:	68a8                	ld	a0,80(s1)
    8000669a:	ffffb097          	auipc	ra,0xffffb
    8000669e:	0fe080e7          	jalr	254(ra) # 80001798 <copyout>
    800066a2:	02054063          	bltz	a0,800066c2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800066a6:	4691                	li	a3,4
    800066a8:	fc040613          	addi	a2,s0,-64
    800066ac:	fd843583          	ld	a1,-40(s0)
    800066b0:	0591                	addi	a1,a1,4
    800066b2:	68a8                	ld	a0,80(s1)
    800066b4:	ffffb097          	auipc	ra,0xffffb
    800066b8:	0e4080e7          	jalr	228(ra) # 80001798 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800066bc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800066be:	06055463          	bgez	a0,80006726 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800066c2:	fc442783          	lw	a5,-60(s0)
    800066c6:	07e9                	addi	a5,a5,26
    800066c8:	078e                	slli	a5,a5,0x3
    800066ca:	97a6                	add	a5,a5,s1
    800066cc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800066d0:	fc042783          	lw	a5,-64(s0)
    800066d4:	07e9                	addi	a5,a5,26
    800066d6:	078e                	slli	a5,a5,0x3
    800066d8:	94be                	add	s1,s1,a5
    800066da:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800066de:	fd043503          	ld	a0,-48(s0)
    800066e2:	fffff097          	auipc	ra,0xfffff
    800066e6:	9f6080e7          	jalr	-1546(ra) # 800050d8 <fileclose>
    fileclose(wf);
    800066ea:	fc843503          	ld	a0,-56(s0)
    800066ee:	fffff097          	auipc	ra,0xfffff
    800066f2:	9ea080e7          	jalr	-1558(ra) # 800050d8 <fileclose>
    return -1;
    800066f6:	57fd                	li	a5,-1
    800066f8:	a03d                	j	80006726 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800066fa:	fc442783          	lw	a5,-60(s0)
    800066fe:	0007c763          	bltz	a5,8000670c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006702:	07e9                	addi	a5,a5,26
    80006704:	078e                	slli	a5,a5,0x3
    80006706:	97a6                	add	a5,a5,s1
    80006708:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000670c:	fd043503          	ld	a0,-48(s0)
    80006710:	fffff097          	auipc	ra,0xfffff
    80006714:	9c8080e7          	jalr	-1592(ra) # 800050d8 <fileclose>
    fileclose(wf);
    80006718:	fc843503          	ld	a0,-56(s0)
    8000671c:	fffff097          	auipc	ra,0xfffff
    80006720:	9bc080e7          	jalr	-1604(ra) # 800050d8 <fileclose>
    return -1;
    80006724:	57fd                	li	a5,-1
}
    80006726:	853e                	mv	a0,a5
    80006728:	70e2                	ld	ra,56(sp)
    8000672a:	7442                	ld	s0,48(sp)
    8000672c:	74a2                	ld	s1,40(sp)
    8000672e:	6121                	addi	sp,sp,64
    80006730:	8082                	ret

0000000080006732 <sys_getreadcount>:


uint64
sys_getreadcount(void)
{
    80006732:	1141                	addi	sp,sp,-16
    80006734:	e422                	sd	s0,8(sp)
    80006736:	0800                	addi	s0,sp,16
  // return myproc()->readid;
  return count;
    80006738:	00002517          	auipc	a0,0x2
    8000673c:	4e052503          	lw	a0,1248(a0) # 80008c18 <count>
    80006740:	6422                	ld	s0,8(sp)
    80006742:	0141                	addi	sp,sp,16
    80006744:	8082                	ret
	...

0000000080006750 <kernelvec>:
    80006750:	7111                	addi	sp,sp,-256
    80006752:	e006                	sd	ra,0(sp)
    80006754:	e40a                	sd	sp,8(sp)
    80006756:	e80e                	sd	gp,16(sp)
    80006758:	ec12                	sd	tp,24(sp)
    8000675a:	f016                	sd	t0,32(sp)
    8000675c:	f41a                	sd	t1,40(sp)
    8000675e:	f81e                	sd	t2,48(sp)
    80006760:	fc22                	sd	s0,56(sp)
    80006762:	e0a6                	sd	s1,64(sp)
    80006764:	e4aa                	sd	a0,72(sp)
    80006766:	e8ae                	sd	a1,80(sp)
    80006768:	ecb2                	sd	a2,88(sp)
    8000676a:	f0b6                	sd	a3,96(sp)
    8000676c:	f4ba                	sd	a4,104(sp)
    8000676e:	f8be                	sd	a5,112(sp)
    80006770:	fcc2                	sd	a6,120(sp)
    80006772:	e146                	sd	a7,128(sp)
    80006774:	e54a                	sd	s2,136(sp)
    80006776:	e94e                	sd	s3,144(sp)
    80006778:	ed52                	sd	s4,152(sp)
    8000677a:	f156                	sd	s5,160(sp)
    8000677c:	f55a                	sd	s6,168(sp)
    8000677e:	f95e                	sd	s7,176(sp)
    80006780:	fd62                	sd	s8,184(sp)
    80006782:	e1e6                	sd	s9,192(sp)
    80006784:	e5ea                	sd	s10,200(sp)
    80006786:	e9ee                	sd	s11,208(sp)
    80006788:	edf2                	sd	t3,216(sp)
    8000678a:	f1f6                	sd	t4,224(sp)
    8000678c:	f5fa                	sd	t5,232(sp)
    8000678e:	f9fe                	sd	t6,240(sp)
    80006790:	933fc0ef          	jal	ra,800030c2 <kerneltrap>
    80006794:	6082                	ld	ra,0(sp)
    80006796:	6122                	ld	sp,8(sp)
    80006798:	61c2                	ld	gp,16(sp)
    8000679a:	7282                	ld	t0,32(sp)
    8000679c:	7322                	ld	t1,40(sp)
    8000679e:	73c2                	ld	t2,48(sp)
    800067a0:	7462                	ld	s0,56(sp)
    800067a2:	6486                	ld	s1,64(sp)
    800067a4:	6526                	ld	a0,72(sp)
    800067a6:	65c6                	ld	a1,80(sp)
    800067a8:	6666                	ld	a2,88(sp)
    800067aa:	7686                	ld	a3,96(sp)
    800067ac:	7726                	ld	a4,104(sp)
    800067ae:	77c6                	ld	a5,112(sp)
    800067b0:	7866                	ld	a6,120(sp)
    800067b2:	688a                	ld	a7,128(sp)
    800067b4:	692a                	ld	s2,136(sp)
    800067b6:	69ca                	ld	s3,144(sp)
    800067b8:	6a6a                	ld	s4,152(sp)
    800067ba:	7a8a                	ld	s5,160(sp)
    800067bc:	7b2a                	ld	s6,168(sp)
    800067be:	7bca                	ld	s7,176(sp)
    800067c0:	7c6a                	ld	s8,184(sp)
    800067c2:	6c8e                	ld	s9,192(sp)
    800067c4:	6d2e                	ld	s10,200(sp)
    800067c6:	6dce                	ld	s11,208(sp)
    800067c8:	6e6e                	ld	t3,216(sp)
    800067ca:	7e8e                	ld	t4,224(sp)
    800067cc:	7f2e                	ld	t5,232(sp)
    800067ce:	7fce                	ld	t6,240(sp)
    800067d0:	6111                	addi	sp,sp,256
    800067d2:	10200073          	sret
    800067d6:	00000013          	nop
    800067da:	00000013          	nop
    800067de:	0001                	nop

00000000800067e0 <timervec>:
    800067e0:	34051573          	csrrw	a0,mscratch,a0
    800067e4:	e10c                	sd	a1,0(a0)
    800067e6:	e510                	sd	a2,8(a0)
    800067e8:	e914                	sd	a3,16(a0)
    800067ea:	6d0c                	ld	a1,24(a0)
    800067ec:	7110                	ld	a2,32(a0)
    800067ee:	6194                	ld	a3,0(a1)
    800067f0:	96b2                	add	a3,a3,a2
    800067f2:	e194                	sd	a3,0(a1)
    800067f4:	4589                	li	a1,2
    800067f6:	14459073          	csrw	sip,a1
    800067fa:	6914                	ld	a3,16(a0)
    800067fc:	6510                	ld	a2,8(a0)
    800067fe:	610c                	ld	a1,0(a0)
    80006800:	34051573          	csrrw	a0,mscratch,a0
    80006804:	30200073          	mret
	...

000000008000680a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000680a:	1141                	addi	sp,sp,-16
    8000680c:	e422                	sd	s0,8(sp)
    8000680e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006810:	0c0007b7          	lui	a5,0xc000
    80006814:	4705                	li	a4,1
    80006816:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006818:	c3d8                	sw	a4,4(a5)
}
    8000681a:	6422                	ld	s0,8(sp)
    8000681c:	0141                	addi	sp,sp,16
    8000681e:	8082                	ret

0000000080006820 <plicinithart>:

void
plicinithart(void)
{
    80006820:	1141                	addi	sp,sp,-16
    80006822:	e406                	sd	ra,8(sp)
    80006824:	e022                	sd	s0,0(sp)
    80006826:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006828:	ffffb097          	auipc	ra,0xffffb
    8000682c:	30c080e7          	jalr	780(ra) # 80001b34 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006830:	0085171b          	slliw	a4,a0,0x8
    80006834:	0c0027b7          	lui	a5,0xc002
    80006838:	97ba                	add	a5,a5,a4
    8000683a:	40200713          	li	a4,1026
    8000683e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006842:	00d5151b          	slliw	a0,a0,0xd
    80006846:	0c2017b7          	lui	a5,0xc201
    8000684a:	97aa                	add	a5,a5,a0
    8000684c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006850:	60a2                	ld	ra,8(sp)
    80006852:	6402                	ld	s0,0(sp)
    80006854:	0141                	addi	sp,sp,16
    80006856:	8082                	ret

0000000080006858 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006858:	1141                	addi	sp,sp,-16
    8000685a:	e406                	sd	ra,8(sp)
    8000685c:	e022                	sd	s0,0(sp)
    8000685e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006860:	ffffb097          	auipc	ra,0xffffb
    80006864:	2d4080e7          	jalr	724(ra) # 80001b34 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006868:	00d5151b          	slliw	a0,a0,0xd
    8000686c:	0c2017b7          	lui	a5,0xc201
    80006870:	97aa                	add	a5,a5,a0
  return irq;
}
    80006872:	43c8                	lw	a0,4(a5)
    80006874:	60a2                	ld	ra,8(sp)
    80006876:	6402                	ld	s0,0(sp)
    80006878:	0141                	addi	sp,sp,16
    8000687a:	8082                	ret

000000008000687c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000687c:	1101                	addi	sp,sp,-32
    8000687e:	ec06                	sd	ra,24(sp)
    80006880:	e822                	sd	s0,16(sp)
    80006882:	e426                	sd	s1,8(sp)
    80006884:	1000                	addi	s0,sp,32
    80006886:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006888:	ffffb097          	auipc	ra,0xffffb
    8000688c:	2ac080e7          	jalr	684(ra) # 80001b34 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006890:	00d5151b          	slliw	a0,a0,0xd
    80006894:	0c2017b7          	lui	a5,0xc201
    80006898:	97aa                	add	a5,a5,a0
    8000689a:	c3c4                	sw	s1,4(a5)
}
    8000689c:	60e2                	ld	ra,24(sp)
    8000689e:	6442                	ld	s0,16(sp)
    800068a0:	64a2                	ld	s1,8(sp)
    800068a2:	6105                	addi	sp,sp,32
    800068a4:	8082                	ret

00000000800068a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800068a6:	1141                	addi	sp,sp,-16
    800068a8:	e406                	sd	ra,8(sp)
    800068aa:	e022                	sd	s0,0(sp)
    800068ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800068ae:	479d                	li	a5,7
    800068b0:	04a7cc63          	blt	a5,a0,80006908 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800068b4:	0023d797          	auipc	a5,0x23d
    800068b8:	6ec78793          	addi	a5,a5,1772 # 80243fa0 <disk>
    800068bc:	97aa                	add	a5,a5,a0
    800068be:	0187c783          	lbu	a5,24(a5)
    800068c2:	ebb9                	bnez	a5,80006918 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800068c4:	00451693          	slli	a3,a0,0x4
    800068c8:	0023d797          	auipc	a5,0x23d
    800068cc:	6d878793          	addi	a5,a5,1752 # 80243fa0 <disk>
    800068d0:	6398                	ld	a4,0(a5)
    800068d2:	9736                	add	a4,a4,a3
    800068d4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800068d8:	6398                	ld	a4,0(a5)
    800068da:	9736                	add	a4,a4,a3
    800068dc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800068e0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800068e4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800068e8:	97aa                	add	a5,a5,a0
    800068ea:	4705                	li	a4,1
    800068ec:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800068f0:	0023d517          	auipc	a0,0x23d
    800068f4:	6c850513          	addi	a0,a0,1736 # 80243fb8 <disk+0x18>
    800068f8:	ffffc097          	auipc	ra,0xffffc
    800068fc:	d52080e7          	jalr	-686(ra) # 8000264a <wakeup>
}
    80006900:	60a2                	ld	ra,8(sp)
    80006902:	6402                	ld	s0,0(sp)
    80006904:	0141                	addi	sp,sp,16
    80006906:	8082                	ret
    panic("free_desc 1");
    80006908:	00002517          	auipc	a0,0x2
    8000690c:	0f850513          	addi	a0,a0,248 # 80008a00 <syscallnames+0x320>
    80006910:	ffffa097          	auipc	ra,0xffffa
    80006914:	c30080e7          	jalr	-976(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006918:	00002517          	auipc	a0,0x2
    8000691c:	0f850513          	addi	a0,a0,248 # 80008a10 <syscallnames+0x330>
    80006920:	ffffa097          	auipc	ra,0xffffa
    80006924:	c20080e7          	jalr	-992(ra) # 80000540 <panic>

0000000080006928 <virtio_disk_init>:
{
    80006928:	1101                	addi	sp,sp,-32
    8000692a:	ec06                	sd	ra,24(sp)
    8000692c:	e822                	sd	s0,16(sp)
    8000692e:	e426                	sd	s1,8(sp)
    80006930:	e04a                	sd	s2,0(sp)
    80006932:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006934:	00002597          	auipc	a1,0x2
    80006938:	0ec58593          	addi	a1,a1,236 # 80008a20 <syscallnames+0x340>
    8000693c:	0023d517          	auipc	a0,0x23d
    80006940:	78c50513          	addi	a0,a0,1932 # 802440c8 <disk+0x128>
    80006944:	ffffa097          	auipc	ra,0xffffa
    80006948:	342080e7          	jalr	834(ra) # 80000c86 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000694c:	100017b7          	lui	a5,0x10001
    80006950:	4398                	lw	a4,0(a5)
    80006952:	2701                	sext.w	a4,a4
    80006954:	747277b7          	lui	a5,0x74727
    80006958:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000695c:	14f71b63          	bne	a4,a5,80006ab2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006960:	100017b7          	lui	a5,0x10001
    80006964:	43dc                	lw	a5,4(a5)
    80006966:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006968:	4709                	li	a4,2
    8000696a:	14e79463          	bne	a5,a4,80006ab2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000696e:	100017b7          	lui	a5,0x10001
    80006972:	479c                	lw	a5,8(a5)
    80006974:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006976:	12e79e63          	bne	a5,a4,80006ab2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000697a:	100017b7          	lui	a5,0x10001
    8000697e:	47d8                	lw	a4,12(a5)
    80006980:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006982:	554d47b7          	lui	a5,0x554d4
    80006986:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000698a:	12f71463          	bne	a4,a5,80006ab2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000698e:	100017b7          	lui	a5,0x10001
    80006992:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006996:	4705                	li	a4,1
    80006998:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000699a:	470d                	li	a4,3
    8000699c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000699e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800069a0:	c7ffe6b7          	lui	a3,0xc7ffe
    800069a4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47dba67f>
    800069a8:	8f75                	and	a4,a4,a3
    800069aa:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800069ac:	472d                	li	a4,11
    800069ae:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800069b0:	5bbc                	lw	a5,112(a5)
    800069b2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800069b6:	8ba1                	andi	a5,a5,8
    800069b8:	10078563          	beqz	a5,80006ac2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800069bc:	100017b7          	lui	a5,0x10001
    800069c0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800069c4:	43fc                	lw	a5,68(a5)
    800069c6:	2781                	sext.w	a5,a5
    800069c8:	10079563          	bnez	a5,80006ad2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800069cc:	100017b7          	lui	a5,0x10001
    800069d0:	5bdc                	lw	a5,52(a5)
    800069d2:	2781                	sext.w	a5,a5
  if(max == 0)
    800069d4:	10078763          	beqz	a5,80006ae2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800069d8:	471d                	li	a4,7
    800069da:	10f77c63          	bgeu	a4,a5,80006af2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800069de:	ffffa097          	auipc	ra,0xffffa
    800069e2:	20a080e7          	jalr	522(ra) # 80000be8 <kalloc>
    800069e6:	0023d497          	auipc	s1,0x23d
    800069ea:	5ba48493          	addi	s1,s1,1466 # 80243fa0 <disk>
    800069ee:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800069f0:	ffffa097          	auipc	ra,0xffffa
    800069f4:	1f8080e7          	jalr	504(ra) # 80000be8 <kalloc>
    800069f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800069fa:	ffffa097          	auipc	ra,0xffffa
    800069fe:	1ee080e7          	jalr	494(ra) # 80000be8 <kalloc>
    80006a02:	87aa                	mv	a5,a0
    80006a04:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006a06:	6088                	ld	a0,0(s1)
    80006a08:	cd6d                	beqz	a0,80006b02 <virtio_disk_init+0x1da>
    80006a0a:	0023d717          	auipc	a4,0x23d
    80006a0e:	59e73703          	ld	a4,1438(a4) # 80243fa8 <disk+0x8>
    80006a12:	cb65                	beqz	a4,80006b02 <virtio_disk_init+0x1da>
    80006a14:	c7fd                	beqz	a5,80006b02 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006a16:	6605                	lui	a2,0x1
    80006a18:	4581                	li	a1,0
    80006a1a:	ffffa097          	auipc	ra,0xffffa
    80006a1e:	3f8080e7          	jalr	1016(ra) # 80000e12 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006a22:	0023d497          	auipc	s1,0x23d
    80006a26:	57e48493          	addi	s1,s1,1406 # 80243fa0 <disk>
    80006a2a:	6605                	lui	a2,0x1
    80006a2c:	4581                	li	a1,0
    80006a2e:	6488                	ld	a0,8(s1)
    80006a30:	ffffa097          	auipc	ra,0xffffa
    80006a34:	3e2080e7          	jalr	994(ra) # 80000e12 <memset>
  memset(disk.used, 0, PGSIZE);
    80006a38:	6605                	lui	a2,0x1
    80006a3a:	4581                	li	a1,0
    80006a3c:	6888                	ld	a0,16(s1)
    80006a3e:	ffffa097          	auipc	ra,0xffffa
    80006a42:	3d4080e7          	jalr	980(ra) # 80000e12 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006a46:	100017b7          	lui	a5,0x10001
    80006a4a:	4721                	li	a4,8
    80006a4c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006a4e:	4098                	lw	a4,0(s1)
    80006a50:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006a54:	40d8                	lw	a4,4(s1)
    80006a56:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006a5a:	6498                	ld	a4,8(s1)
    80006a5c:	0007069b          	sext.w	a3,a4
    80006a60:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006a64:	9701                	srai	a4,a4,0x20
    80006a66:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006a6a:	6898                	ld	a4,16(s1)
    80006a6c:	0007069b          	sext.w	a3,a4
    80006a70:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006a74:	9701                	srai	a4,a4,0x20
    80006a76:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006a7a:	4705                	li	a4,1
    80006a7c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006a7e:	00e48c23          	sb	a4,24(s1)
    80006a82:	00e48ca3          	sb	a4,25(s1)
    80006a86:	00e48d23          	sb	a4,26(s1)
    80006a8a:	00e48da3          	sb	a4,27(s1)
    80006a8e:	00e48e23          	sb	a4,28(s1)
    80006a92:	00e48ea3          	sb	a4,29(s1)
    80006a96:	00e48f23          	sb	a4,30(s1)
    80006a9a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006a9e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006aa2:	0727a823          	sw	s2,112(a5)
}
    80006aa6:	60e2                	ld	ra,24(sp)
    80006aa8:	6442                	ld	s0,16(sp)
    80006aaa:	64a2                	ld	s1,8(sp)
    80006aac:	6902                	ld	s2,0(sp)
    80006aae:	6105                	addi	sp,sp,32
    80006ab0:	8082                	ret
    panic("could not find virtio disk");
    80006ab2:	00002517          	auipc	a0,0x2
    80006ab6:	f7e50513          	addi	a0,a0,-130 # 80008a30 <syscallnames+0x350>
    80006aba:	ffffa097          	auipc	ra,0xffffa
    80006abe:	a86080e7          	jalr	-1402(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006ac2:	00002517          	auipc	a0,0x2
    80006ac6:	f8e50513          	addi	a0,a0,-114 # 80008a50 <syscallnames+0x370>
    80006aca:	ffffa097          	auipc	ra,0xffffa
    80006ace:	a76080e7          	jalr	-1418(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006ad2:	00002517          	auipc	a0,0x2
    80006ad6:	f9e50513          	addi	a0,a0,-98 # 80008a70 <syscallnames+0x390>
    80006ada:	ffffa097          	auipc	ra,0xffffa
    80006ade:	a66080e7          	jalr	-1434(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006ae2:	00002517          	auipc	a0,0x2
    80006ae6:	fae50513          	addi	a0,a0,-82 # 80008a90 <syscallnames+0x3b0>
    80006aea:	ffffa097          	auipc	ra,0xffffa
    80006aee:	a56080e7          	jalr	-1450(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006af2:	00002517          	auipc	a0,0x2
    80006af6:	fbe50513          	addi	a0,a0,-66 # 80008ab0 <syscallnames+0x3d0>
    80006afa:	ffffa097          	auipc	ra,0xffffa
    80006afe:	a46080e7          	jalr	-1466(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006b02:	00002517          	auipc	a0,0x2
    80006b06:	fce50513          	addi	a0,a0,-50 # 80008ad0 <syscallnames+0x3f0>
    80006b0a:	ffffa097          	auipc	ra,0xffffa
    80006b0e:	a36080e7          	jalr	-1482(ra) # 80000540 <panic>

0000000080006b12 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006b12:	7119                	addi	sp,sp,-128
    80006b14:	fc86                	sd	ra,120(sp)
    80006b16:	f8a2                	sd	s0,112(sp)
    80006b18:	f4a6                	sd	s1,104(sp)
    80006b1a:	f0ca                	sd	s2,96(sp)
    80006b1c:	ecce                	sd	s3,88(sp)
    80006b1e:	e8d2                	sd	s4,80(sp)
    80006b20:	e4d6                	sd	s5,72(sp)
    80006b22:	e0da                	sd	s6,64(sp)
    80006b24:	fc5e                	sd	s7,56(sp)
    80006b26:	f862                	sd	s8,48(sp)
    80006b28:	f466                	sd	s9,40(sp)
    80006b2a:	f06a                	sd	s10,32(sp)
    80006b2c:	ec6e                	sd	s11,24(sp)
    80006b2e:	0100                	addi	s0,sp,128
    80006b30:	8aaa                	mv	s5,a0
    80006b32:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006b34:	00c52d03          	lw	s10,12(a0)
    80006b38:	001d1d1b          	slliw	s10,s10,0x1
    80006b3c:	1d02                	slli	s10,s10,0x20
    80006b3e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006b42:	0023d517          	auipc	a0,0x23d
    80006b46:	58650513          	addi	a0,a0,1414 # 802440c8 <disk+0x128>
    80006b4a:	ffffa097          	auipc	ra,0xffffa
    80006b4e:	1cc080e7          	jalr	460(ra) # 80000d16 <acquire>
  for(int i = 0; i < 3; i++){
    80006b52:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006b54:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006b56:	0023db97          	auipc	s7,0x23d
    80006b5a:	44ab8b93          	addi	s7,s7,1098 # 80243fa0 <disk>
  for(int i = 0; i < 3; i++){
    80006b5e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b60:	0023dc97          	auipc	s9,0x23d
    80006b64:	568c8c93          	addi	s9,s9,1384 # 802440c8 <disk+0x128>
    80006b68:	a08d                	j	80006bca <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006b6a:	00fb8733          	add	a4,s7,a5
    80006b6e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006b72:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006b74:	0207c563          	bltz	a5,80006b9e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006b78:	2905                	addiw	s2,s2,1
    80006b7a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006b7c:	05690c63          	beq	s2,s6,80006bd4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006b80:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006b82:	0023d717          	auipc	a4,0x23d
    80006b86:	41e70713          	addi	a4,a4,1054 # 80243fa0 <disk>
    80006b8a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006b8c:	01874683          	lbu	a3,24(a4)
    80006b90:	fee9                	bnez	a3,80006b6a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006b92:	2785                	addiw	a5,a5,1
    80006b94:	0705                	addi	a4,a4,1
    80006b96:	fe979be3          	bne	a5,s1,80006b8c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006b9a:	57fd                	li	a5,-1
    80006b9c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006b9e:	01205d63          	blez	s2,80006bb8 <virtio_disk_rw+0xa6>
    80006ba2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006ba4:	000a2503          	lw	a0,0(s4)
    80006ba8:	00000097          	auipc	ra,0x0
    80006bac:	cfe080e7          	jalr	-770(ra) # 800068a6 <free_desc>
      for(int j = 0; j < i; j++)
    80006bb0:	2d85                	addiw	s11,s11,1
    80006bb2:	0a11                	addi	s4,s4,4
    80006bb4:	ff2d98e3          	bne	s11,s2,80006ba4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006bb8:	85e6                	mv	a1,s9
    80006bba:	0023d517          	auipc	a0,0x23d
    80006bbe:	3fe50513          	addi	a0,a0,1022 # 80243fb8 <disk+0x18>
    80006bc2:	ffffc097          	auipc	ra,0xffffc
    80006bc6:	8d4080e7          	jalr	-1836(ra) # 80002496 <sleep>
  for(int i = 0; i < 3; i++){
    80006bca:	f8040a13          	addi	s4,s0,-128
{
    80006bce:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006bd0:	894e                	mv	s2,s3
    80006bd2:	b77d                	j	80006b80 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006bd4:	f8042503          	lw	a0,-128(s0)
    80006bd8:	00a50713          	addi	a4,a0,10
    80006bdc:	0712                	slli	a4,a4,0x4

  if(write)
    80006bde:	0023d797          	auipc	a5,0x23d
    80006be2:	3c278793          	addi	a5,a5,962 # 80243fa0 <disk>
    80006be6:	00e786b3          	add	a3,a5,a4
    80006bea:	01803633          	snez	a2,s8
    80006bee:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006bf0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006bf4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006bf8:	f6070613          	addi	a2,a4,-160
    80006bfc:	6394                	ld	a3,0(a5)
    80006bfe:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006c00:	00870593          	addi	a1,a4,8
    80006c04:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006c06:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006c08:	0007b803          	ld	a6,0(a5)
    80006c0c:	9642                	add	a2,a2,a6
    80006c0e:	46c1                	li	a3,16
    80006c10:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006c12:	4585                	li	a1,1
    80006c14:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006c18:	f8442683          	lw	a3,-124(s0)
    80006c1c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006c20:	0692                	slli	a3,a3,0x4
    80006c22:	9836                	add	a6,a6,a3
    80006c24:	058a8613          	addi	a2,s5,88
    80006c28:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006c2c:	0007b803          	ld	a6,0(a5)
    80006c30:	96c2                	add	a3,a3,a6
    80006c32:	40000613          	li	a2,1024
    80006c36:	c690                	sw	a2,8(a3)
  if(write)
    80006c38:	001c3613          	seqz	a2,s8
    80006c3c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006c40:	00166613          	ori	a2,a2,1
    80006c44:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006c48:	f8842603          	lw	a2,-120(s0)
    80006c4c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006c50:	00250693          	addi	a3,a0,2
    80006c54:	0692                	slli	a3,a3,0x4
    80006c56:	96be                	add	a3,a3,a5
    80006c58:	58fd                	li	a7,-1
    80006c5a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006c5e:	0612                	slli	a2,a2,0x4
    80006c60:	9832                	add	a6,a6,a2
    80006c62:	f9070713          	addi	a4,a4,-112
    80006c66:	973e                	add	a4,a4,a5
    80006c68:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006c6c:	6398                	ld	a4,0(a5)
    80006c6e:	9732                	add	a4,a4,a2
    80006c70:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006c72:	4609                	li	a2,2
    80006c74:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006c78:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006c7c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006c80:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006c84:	6794                	ld	a3,8(a5)
    80006c86:	0026d703          	lhu	a4,2(a3)
    80006c8a:	8b1d                	andi	a4,a4,7
    80006c8c:	0706                	slli	a4,a4,0x1
    80006c8e:	96ba                	add	a3,a3,a4
    80006c90:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006c94:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006c98:	6798                	ld	a4,8(a5)
    80006c9a:	00275783          	lhu	a5,2(a4)
    80006c9e:	2785                	addiw	a5,a5,1
    80006ca0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006ca4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006ca8:	100017b7          	lui	a5,0x10001
    80006cac:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006cb0:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006cb4:	0023d917          	auipc	s2,0x23d
    80006cb8:	41490913          	addi	s2,s2,1044 # 802440c8 <disk+0x128>
  while(b->disk == 1) {
    80006cbc:	4485                	li	s1,1
    80006cbe:	00b79c63          	bne	a5,a1,80006cd6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006cc2:	85ca                	mv	a1,s2
    80006cc4:	8556                	mv	a0,s5
    80006cc6:	ffffb097          	auipc	ra,0xffffb
    80006cca:	7d0080e7          	jalr	2000(ra) # 80002496 <sleep>
  while(b->disk == 1) {
    80006cce:	004aa783          	lw	a5,4(s5)
    80006cd2:	fe9788e3          	beq	a5,s1,80006cc2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006cd6:	f8042903          	lw	s2,-128(s0)
    80006cda:	00290713          	addi	a4,s2,2
    80006cde:	0712                	slli	a4,a4,0x4
    80006ce0:	0023d797          	auipc	a5,0x23d
    80006ce4:	2c078793          	addi	a5,a5,704 # 80243fa0 <disk>
    80006ce8:	97ba                	add	a5,a5,a4
    80006cea:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006cee:	0023d997          	auipc	s3,0x23d
    80006cf2:	2b298993          	addi	s3,s3,690 # 80243fa0 <disk>
    80006cf6:	00491713          	slli	a4,s2,0x4
    80006cfa:	0009b783          	ld	a5,0(s3)
    80006cfe:	97ba                	add	a5,a5,a4
    80006d00:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006d04:	854a                	mv	a0,s2
    80006d06:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006d0a:	00000097          	auipc	ra,0x0
    80006d0e:	b9c080e7          	jalr	-1124(ra) # 800068a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006d12:	8885                	andi	s1,s1,1
    80006d14:	f0ed                	bnez	s1,80006cf6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006d16:	0023d517          	auipc	a0,0x23d
    80006d1a:	3b250513          	addi	a0,a0,946 # 802440c8 <disk+0x128>
    80006d1e:	ffffa097          	auipc	ra,0xffffa
    80006d22:	0ac080e7          	jalr	172(ra) # 80000dca <release>
}
    80006d26:	70e6                	ld	ra,120(sp)
    80006d28:	7446                	ld	s0,112(sp)
    80006d2a:	74a6                	ld	s1,104(sp)
    80006d2c:	7906                	ld	s2,96(sp)
    80006d2e:	69e6                	ld	s3,88(sp)
    80006d30:	6a46                	ld	s4,80(sp)
    80006d32:	6aa6                	ld	s5,72(sp)
    80006d34:	6b06                	ld	s6,64(sp)
    80006d36:	7be2                	ld	s7,56(sp)
    80006d38:	7c42                	ld	s8,48(sp)
    80006d3a:	7ca2                	ld	s9,40(sp)
    80006d3c:	7d02                	ld	s10,32(sp)
    80006d3e:	6de2                	ld	s11,24(sp)
    80006d40:	6109                	addi	sp,sp,128
    80006d42:	8082                	ret

0000000080006d44 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006d44:	1101                	addi	sp,sp,-32
    80006d46:	ec06                	sd	ra,24(sp)
    80006d48:	e822                	sd	s0,16(sp)
    80006d4a:	e426                	sd	s1,8(sp)
    80006d4c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006d4e:	0023d497          	auipc	s1,0x23d
    80006d52:	25248493          	addi	s1,s1,594 # 80243fa0 <disk>
    80006d56:	0023d517          	auipc	a0,0x23d
    80006d5a:	37250513          	addi	a0,a0,882 # 802440c8 <disk+0x128>
    80006d5e:	ffffa097          	auipc	ra,0xffffa
    80006d62:	fb8080e7          	jalr	-72(ra) # 80000d16 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006d66:	10001737          	lui	a4,0x10001
    80006d6a:	533c                	lw	a5,96(a4)
    80006d6c:	8b8d                	andi	a5,a5,3
    80006d6e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006d70:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006d74:	689c                	ld	a5,16(s1)
    80006d76:	0204d703          	lhu	a4,32(s1)
    80006d7a:	0027d783          	lhu	a5,2(a5)
    80006d7e:	04f70863          	beq	a4,a5,80006dce <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006d82:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006d86:	6898                	ld	a4,16(s1)
    80006d88:	0204d783          	lhu	a5,32(s1)
    80006d8c:	8b9d                	andi	a5,a5,7
    80006d8e:	078e                	slli	a5,a5,0x3
    80006d90:	97ba                	add	a5,a5,a4
    80006d92:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006d94:	00278713          	addi	a4,a5,2
    80006d98:	0712                	slli	a4,a4,0x4
    80006d9a:	9726                	add	a4,a4,s1
    80006d9c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006da0:	e721                	bnez	a4,80006de8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006da2:	0789                	addi	a5,a5,2
    80006da4:	0792                	slli	a5,a5,0x4
    80006da6:	97a6                	add	a5,a5,s1
    80006da8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006daa:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006dae:	ffffc097          	auipc	ra,0xffffc
    80006db2:	89c080e7          	jalr	-1892(ra) # 8000264a <wakeup>

    disk.used_idx += 1;
    80006db6:	0204d783          	lhu	a5,32(s1)
    80006dba:	2785                	addiw	a5,a5,1
    80006dbc:	17c2                	slli	a5,a5,0x30
    80006dbe:	93c1                	srli	a5,a5,0x30
    80006dc0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006dc4:	6898                	ld	a4,16(s1)
    80006dc6:	00275703          	lhu	a4,2(a4)
    80006dca:	faf71ce3          	bne	a4,a5,80006d82 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006dce:	0023d517          	auipc	a0,0x23d
    80006dd2:	2fa50513          	addi	a0,a0,762 # 802440c8 <disk+0x128>
    80006dd6:	ffffa097          	auipc	ra,0xffffa
    80006dda:	ff4080e7          	jalr	-12(ra) # 80000dca <release>
}
    80006dde:	60e2                	ld	ra,24(sp)
    80006de0:	6442                	ld	s0,16(sp)
    80006de2:	64a2                	ld	s1,8(sp)
    80006de4:	6105                	addi	sp,sp,32
    80006de6:	8082                	ret
      panic("virtio_disk_intr status");
    80006de8:	00002517          	auipc	a0,0x2
    80006dec:	d0050513          	addi	a0,a0,-768 # 80008ae8 <syscallnames+0x408>
    80006df0:	ffff9097          	auipc	ra,0xffff9
    80006df4:	750080e7          	jalr	1872(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
