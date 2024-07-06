
user/_setpriority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    if (argc != 3)
   c:	478d                	li	a5,3
   e:	02f50063          	beq	a0,a5,2e <main+0x2e>
    {
        fprintf(2, "Usage: setpriority priority pid\n");
  12:	00001597          	auipc	a1,0x1
  16:	82e58593          	addi	a1,a1,-2002 # 840 <malloc+0xf4>
  1a:	4509                	li	a0,2
  1c:	00000097          	auipc	ra,0x0
  20:	64a080e7          	jalr	1610(ra) # 666 <fprintf>
        exit(1);
  24:	4505                	li	a0,1
  26:	00000097          	auipc	ra,0x0
  2a:	2bc080e7          	jalr	700(ra) # 2e2 <exit>
  2e:	84ae                	mv	s1,a1
    }
    set_priority(atoi(argv[1]), atoi(argv[2]));
  30:	6588                	ld	a0,8(a1)
  32:	00000097          	auipc	ra,0x0
  36:	1b6080e7          	jalr	438(ra) # 1e8 <atoi>
  3a:	892a                	mv	s2,a0
  3c:	6888                	ld	a0,16(s1)
  3e:	00000097          	auipc	ra,0x0
  42:	1aa080e7          	jalr	426(ra) # 1e8 <atoi>
  46:	85aa                	mv	a1,a0
  48:	854a                	mv	a0,s2
  4a:	00000097          	auipc	ra,0x0
  4e:	360080e7          	jalr	864(ra) # 3aa <set_priority>
    exit(0);
  52:	4501                	li	a0,0
  54:	00000097          	auipc	ra,0x0
  58:	28e080e7          	jalr	654(ra) # 2e2 <exit>

000000000000005c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e406                	sd	ra,8(sp)
  60:	e022                	sd	s0,0(sp)
  62:	0800                	addi	s0,sp,16
  extern int main();
  main();
  64:	00000097          	auipc	ra,0x0
  68:	f9c080e7          	jalr	-100(ra) # 0 <main>
  exit(0);
  6c:	4501                	li	a0,0
  6e:	00000097          	auipc	ra,0x0
  72:	274080e7          	jalr	628(ra) # 2e2 <exit>

0000000000000076 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7c:	87aa                	mv	a5,a0
  7e:	0585                	addi	a1,a1,1
  80:	0785                	addi	a5,a5,1
  82:	fff5c703          	lbu	a4,-1(a1)
  86:	fee78fa3          	sb	a4,-1(a5)
  8a:	fb75                	bnez	a4,7e <strcpy+0x8>
    ;
  return os;
}
  8c:	6422                	ld	s0,8(sp)
  8e:	0141                	addi	sp,sp,16
  90:	8082                	ret

0000000000000092 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	cb91                	beqz	a5,b0 <strcmp+0x1e>
  9e:	0005c703          	lbu	a4,0(a1)
  a2:	00f71763          	bne	a4,a5,b0 <strcmp+0x1e>
    p++, q++;
  a6:	0505                	addi	a0,a0,1
  a8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	fbe5                	bnez	a5,9e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b0:	0005c503          	lbu	a0,0(a1)
}
  b4:	40a7853b          	subw	a0,a5,a0
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret

00000000000000be <strlen>:

uint
strlen(const char *s)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	cf91                	beqz	a5,e4 <strlen+0x26>
  ca:	0505                	addi	a0,a0,1
  cc:	87aa                	mv	a5,a0
  ce:	4685                	li	a3,1
  d0:	9e89                	subw	a3,a3,a0
  d2:	00f6853b          	addw	a0,a3,a5
  d6:	0785                	addi	a5,a5,1
  d8:	fff7c703          	lbu	a4,-1(a5)
  dc:	fb7d                	bnez	a4,d2 <strlen+0x14>
    ;
  return n;
}
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret
  for(n = 0; s[n]; n++)
  e4:	4501                	li	a0,0
  e6:	bfe5                	j	de <strlen+0x20>

00000000000000e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ee:	ca19                	beqz	a2,104 <memset+0x1c>
  f0:	87aa                	mv	a5,a0
  f2:	1602                	slli	a2,a2,0x20
  f4:	9201                	srli	a2,a2,0x20
  f6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  fa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  fe:	0785                	addi	a5,a5,1
 100:	fee79de3          	bne	a5,a4,fa <memset+0x12>
  }
  return dst;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strchr>:

char*
strchr(const char *s, char c)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 110:	00054783          	lbu	a5,0(a0)
 114:	cb99                	beqz	a5,12a <strchr+0x20>
    if(*s == c)
 116:	00f58763          	beq	a1,a5,124 <strchr+0x1a>
  for(; *s; s++)
 11a:	0505                	addi	a0,a0,1
 11c:	00054783          	lbu	a5,0(a0)
 120:	fbfd                	bnez	a5,116 <strchr+0xc>
      return (char*)s;
  return 0;
 122:	4501                	li	a0,0
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
  return 0;
 12a:	4501                	li	a0,0
 12c:	bfe5                	j	124 <strchr+0x1a>

000000000000012e <gets>:

char*
gets(char *buf, int max)
{
 12e:	711d                	addi	sp,sp,-96
 130:	ec86                	sd	ra,88(sp)
 132:	e8a2                	sd	s0,80(sp)
 134:	e4a6                	sd	s1,72(sp)
 136:	e0ca                	sd	s2,64(sp)
 138:	fc4e                	sd	s3,56(sp)
 13a:	f852                	sd	s4,48(sp)
 13c:	f456                	sd	s5,40(sp)
 13e:	f05a                	sd	s6,32(sp)
 140:	ec5e                	sd	s7,24(sp)
 142:	1080                	addi	s0,sp,96
 144:	8baa                	mv	s7,a0
 146:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 148:	892a                	mv	s2,a0
 14a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 14c:	4aa9                	li	s5,10
 14e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 150:	89a6                	mv	s3,s1
 152:	2485                	addiw	s1,s1,1
 154:	0344d863          	bge	s1,s4,184 <gets+0x56>
    cc = read(0, &c, 1);
 158:	4605                	li	a2,1
 15a:	faf40593          	addi	a1,s0,-81
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	19a080e7          	jalr	410(ra) # 2fa <read>
    if(cc < 1)
 168:	00a05e63          	blez	a0,184 <gets+0x56>
    buf[i++] = c;
 16c:	faf44783          	lbu	a5,-81(s0)
 170:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 174:	01578763          	beq	a5,s5,182 <gets+0x54>
 178:	0905                	addi	s2,s2,1
 17a:	fd679be3          	bne	a5,s6,150 <gets+0x22>
  for(i=0; i+1 < max; ){
 17e:	89a6                	mv	s3,s1
 180:	a011                	j	184 <gets+0x56>
 182:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 184:	99de                	add	s3,s3,s7
 186:	00098023          	sb	zero,0(s3)
  return buf;
}
 18a:	855e                	mv	a0,s7
 18c:	60e6                	ld	ra,88(sp)
 18e:	6446                	ld	s0,80(sp)
 190:	64a6                	ld	s1,72(sp)
 192:	6906                	ld	s2,64(sp)
 194:	79e2                	ld	s3,56(sp)
 196:	7a42                	ld	s4,48(sp)
 198:	7aa2                	ld	s5,40(sp)
 19a:	7b02                	ld	s6,32(sp)
 19c:	6be2                	ld	s7,24(sp)
 19e:	6125                	addi	sp,sp,96
 1a0:	8082                	ret

00000000000001a2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a2:	1101                	addi	sp,sp,-32
 1a4:	ec06                	sd	ra,24(sp)
 1a6:	e822                	sd	s0,16(sp)
 1a8:	e426                	sd	s1,8(sp)
 1aa:	e04a                	sd	s2,0(sp)
 1ac:	1000                	addi	s0,sp,32
 1ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b0:	4581                	li	a1,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	170080e7          	jalr	368(ra) # 322 <open>
  if(fd < 0)
 1ba:	02054563          	bltz	a0,1e4 <stat+0x42>
 1be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c0:	85ca                	mv	a1,s2
 1c2:	00000097          	auipc	ra,0x0
 1c6:	178080e7          	jalr	376(ra) # 33a <fstat>
 1ca:	892a                	mv	s2,a0
  close(fd);
 1cc:	8526                	mv	a0,s1
 1ce:	00000097          	auipc	ra,0x0
 1d2:	13c080e7          	jalr	316(ra) # 30a <close>
  return r;
}
 1d6:	854a                	mv	a0,s2
 1d8:	60e2                	ld	ra,24(sp)
 1da:	6442                	ld	s0,16(sp)
 1dc:	64a2                	ld	s1,8(sp)
 1de:	6902                	ld	s2,0(sp)
 1e0:	6105                	addi	sp,sp,32
 1e2:	8082                	ret
    return -1;
 1e4:	597d                	li	s2,-1
 1e6:	bfc5                	j	1d6 <stat+0x34>

00000000000001e8 <atoi>:

int
atoi(const char *s)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ee:	00054683          	lbu	a3,0(a0)
 1f2:	fd06879b          	addiw	a5,a3,-48
 1f6:	0ff7f793          	zext.b	a5,a5
 1fa:	4625                	li	a2,9
 1fc:	02f66863          	bltu	a2,a5,22c <atoi+0x44>
 200:	872a                	mv	a4,a0
  n = 0;
 202:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 204:	0705                	addi	a4,a4,1
 206:	0025179b          	slliw	a5,a0,0x2
 20a:	9fa9                	addw	a5,a5,a0
 20c:	0017979b          	slliw	a5,a5,0x1
 210:	9fb5                	addw	a5,a5,a3
 212:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 216:	00074683          	lbu	a3,0(a4)
 21a:	fd06879b          	addiw	a5,a3,-48
 21e:	0ff7f793          	zext.b	a5,a5
 222:	fef671e3          	bgeu	a2,a5,204 <atoi+0x1c>
  return n;
}
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret
  n = 0;
 22c:	4501                	li	a0,0
 22e:	bfe5                	j	226 <atoi+0x3e>

0000000000000230 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 236:	02b57463          	bgeu	a0,a1,25e <memmove+0x2e>
    while(n-- > 0)
 23a:	00c05f63          	blez	a2,258 <memmove+0x28>
 23e:	1602                	slli	a2,a2,0x20
 240:	9201                	srli	a2,a2,0x20
 242:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 246:	872a                	mv	a4,a0
      *dst++ = *src++;
 248:	0585                	addi	a1,a1,1
 24a:	0705                	addi	a4,a4,1
 24c:	fff5c683          	lbu	a3,-1(a1)
 250:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 254:	fee79ae3          	bne	a5,a4,248 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
    dst += n;
 25e:	00c50733          	add	a4,a0,a2
    src += n;
 262:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 264:	fec05ae3          	blez	a2,258 <memmove+0x28>
 268:	fff6079b          	addiw	a5,a2,-1
 26c:	1782                	slli	a5,a5,0x20
 26e:	9381                	srli	a5,a5,0x20
 270:	fff7c793          	not	a5,a5
 274:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 276:	15fd                	addi	a1,a1,-1
 278:	177d                	addi	a4,a4,-1
 27a:	0005c683          	lbu	a3,0(a1)
 27e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 282:	fee79ae3          	bne	a5,a4,276 <memmove+0x46>
 286:	bfc9                	j	258 <memmove+0x28>

0000000000000288 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 28e:	ca05                	beqz	a2,2be <memcmp+0x36>
 290:	fff6069b          	addiw	a3,a2,-1
 294:	1682                	slli	a3,a3,0x20
 296:	9281                	srli	a3,a3,0x20
 298:	0685                	addi	a3,a3,1
 29a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 29c:	00054783          	lbu	a5,0(a0)
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00e79863          	bne	a5,a4,2b4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2a8:	0505                	addi	a0,a0,1
    p2++;
 2aa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ac:	fed518e3          	bne	a0,a3,29c <memcmp+0x14>
  }
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	a019                	j	2b8 <memcmp+0x30>
      return *p1 - *p2;
 2b4:	40e7853b          	subw	a0,a5,a4
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
  return 0;
 2be:	4501                	li	a0,0
 2c0:	bfe5                	j	2b8 <memcmp+0x30>

00000000000002c2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e406                	sd	ra,8(sp)
 2c6:	e022                	sd	s0,0(sp)
 2c8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ca:	00000097          	auipc	ra,0x0
 2ce:	f66080e7          	jalr	-154(ra) # 230 <memmove>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2da:	4885                	li	a7,1
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e2:	4889                	li	a7,2
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ea:	488d                	li	a7,3
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f2:	4891                	li	a7,4
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <read>:
.global read
read:
 li a7, SYS_read
 2fa:	4895                	li	a7,5
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <write>:
.global write
write:
 li a7, SYS_write
 302:	48c1                	li	a7,16
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <close>:
.global close
close:
 li a7, SYS_close
 30a:	48d5                	li	a7,21
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <kill>:
.global kill
kill:
 li a7, SYS_kill
 312:	4899                	li	a7,6
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <exec>:
.global exec
exec:
 li a7, SYS_exec
 31a:	489d                	li	a7,7
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <open>:
.global open
open:
 li a7, SYS_open
 322:	48bd                	li	a7,15
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32a:	48c5                	li	a7,17
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 332:	48c9                	li	a7,18
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33a:	48a1                	li	a7,8
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <link>:
.global link
link:
 li a7, SYS_link
 342:	48cd                	li	a7,19
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34a:	48d1                	li	a7,20
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 352:	48a5                	li	a7,9
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <dup>:
.global dup
dup:
 li a7, SYS_dup
 35a:	48a9                	li	a7,10
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 362:	48ad                	li	a7,11
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 36a:	48b1                	li	a7,12
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 372:	48b5                	li	a7,13
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37a:	48b9                	li	a7,14
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <trace>:
.global trace
trace:
 li a7, SYS_trace
 382:	48d9                	li	a7,22
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 38a:	48dd                	li	a7,23
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 392:	48e1                	li	a7,24
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 39a:	48e5                	li	a7,25
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3a2:	48e9                	li	a7,26
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 3aa:	48ed                	li	a7,27
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3b2:	48f1                	li	a7,28
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ba:	1101                	addi	sp,sp,-32
 3bc:	ec06                	sd	ra,24(sp)
 3be:	e822                	sd	s0,16(sp)
 3c0:	1000                	addi	s0,sp,32
 3c2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c6:	4605                	li	a2,1
 3c8:	fef40593          	addi	a1,s0,-17
 3cc:	00000097          	auipc	ra,0x0
 3d0:	f36080e7          	jalr	-202(ra) # 302 <write>
}
 3d4:	60e2                	ld	ra,24(sp)
 3d6:	6442                	ld	s0,16(sp)
 3d8:	6105                	addi	sp,sp,32
 3da:	8082                	ret

00000000000003dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3dc:	7139                	addi	sp,sp,-64
 3de:	fc06                	sd	ra,56(sp)
 3e0:	f822                	sd	s0,48(sp)
 3e2:	f426                	sd	s1,40(sp)
 3e4:	f04a                	sd	s2,32(sp)
 3e6:	ec4e                	sd	s3,24(sp)
 3e8:	0080                	addi	s0,sp,64
 3ea:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ec:	c299                	beqz	a3,3f2 <printint+0x16>
 3ee:	0805c963          	bltz	a1,480 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f2:	2581                	sext.w	a1,a1
  neg = 0;
 3f4:	4881                	li	a7,0
 3f6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3fa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3fc:	2601                	sext.w	a2,a2
 3fe:	00000517          	auipc	a0,0x0
 402:	4ca50513          	addi	a0,a0,1226 # 8c8 <digits>
 406:	883a                	mv	a6,a4
 408:	2705                	addiw	a4,a4,1
 40a:	02c5f7bb          	remuw	a5,a1,a2
 40e:	1782                	slli	a5,a5,0x20
 410:	9381                	srli	a5,a5,0x20
 412:	97aa                	add	a5,a5,a0
 414:	0007c783          	lbu	a5,0(a5)
 418:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 41c:	0005879b          	sext.w	a5,a1
 420:	02c5d5bb          	divuw	a1,a1,a2
 424:	0685                	addi	a3,a3,1
 426:	fec7f0e3          	bgeu	a5,a2,406 <printint+0x2a>
  if(neg)
 42a:	00088c63          	beqz	a7,442 <printint+0x66>
    buf[i++] = '-';
 42e:	fd070793          	addi	a5,a4,-48
 432:	00878733          	add	a4,a5,s0
 436:	02d00793          	li	a5,45
 43a:	fef70823          	sb	a5,-16(a4)
 43e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 442:	02e05863          	blez	a4,472 <printint+0x96>
 446:	fc040793          	addi	a5,s0,-64
 44a:	00e78933          	add	s2,a5,a4
 44e:	fff78993          	addi	s3,a5,-1
 452:	99ba                	add	s3,s3,a4
 454:	377d                	addiw	a4,a4,-1
 456:	1702                	slli	a4,a4,0x20
 458:	9301                	srli	a4,a4,0x20
 45a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 45e:	fff94583          	lbu	a1,-1(s2)
 462:	8526                	mv	a0,s1
 464:	00000097          	auipc	ra,0x0
 468:	f56080e7          	jalr	-170(ra) # 3ba <putc>
  while(--i >= 0)
 46c:	197d                	addi	s2,s2,-1
 46e:	ff3918e3          	bne	s2,s3,45e <printint+0x82>
}
 472:	70e2                	ld	ra,56(sp)
 474:	7442                	ld	s0,48(sp)
 476:	74a2                	ld	s1,40(sp)
 478:	7902                	ld	s2,32(sp)
 47a:	69e2                	ld	s3,24(sp)
 47c:	6121                	addi	sp,sp,64
 47e:	8082                	ret
    x = -xx;
 480:	40b005bb          	negw	a1,a1
    neg = 1;
 484:	4885                	li	a7,1
    x = -xx;
 486:	bf85                	j	3f6 <printint+0x1a>

0000000000000488 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 488:	7119                	addi	sp,sp,-128
 48a:	fc86                	sd	ra,120(sp)
 48c:	f8a2                	sd	s0,112(sp)
 48e:	f4a6                	sd	s1,104(sp)
 490:	f0ca                	sd	s2,96(sp)
 492:	ecce                	sd	s3,88(sp)
 494:	e8d2                	sd	s4,80(sp)
 496:	e4d6                	sd	s5,72(sp)
 498:	e0da                	sd	s6,64(sp)
 49a:	fc5e                	sd	s7,56(sp)
 49c:	f862                	sd	s8,48(sp)
 49e:	f466                	sd	s9,40(sp)
 4a0:	f06a                	sd	s10,32(sp)
 4a2:	ec6e                	sd	s11,24(sp)
 4a4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a6:	0005c903          	lbu	s2,0(a1)
 4aa:	18090f63          	beqz	s2,648 <vprintf+0x1c0>
 4ae:	8aaa                	mv	s5,a0
 4b0:	8b32                	mv	s6,a2
 4b2:	00158493          	addi	s1,a1,1
  state = 0;
 4b6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b8:	02500a13          	li	s4,37
 4bc:	4c55                	li	s8,21
 4be:	00000c97          	auipc	s9,0x0
 4c2:	3b2c8c93          	addi	s9,s9,946 # 870 <malloc+0x124>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4c6:	02800d93          	li	s11,40
  putc(fd, 'x');
 4ca:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4cc:	00000b97          	auipc	s7,0x0
 4d0:	3fcb8b93          	addi	s7,s7,1020 # 8c8 <digits>
 4d4:	a839                	j	4f2 <vprintf+0x6a>
        putc(fd, c);
 4d6:	85ca                	mv	a1,s2
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	ee0080e7          	jalr	-288(ra) # 3ba <putc>
 4e2:	a019                	j	4e8 <vprintf+0x60>
    } else if(state == '%'){
 4e4:	01498d63          	beq	s3,s4,4fe <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 4e8:	0485                	addi	s1,s1,1
 4ea:	fff4c903          	lbu	s2,-1(s1)
 4ee:	14090d63          	beqz	s2,648 <vprintf+0x1c0>
    if(state == 0){
 4f2:	fe0999e3          	bnez	s3,4e4 <vprintf+0x5c>
      if(c == '%'){
 4f6:	ff4910e3          	bne	s2,s4,4d6 <vprintf+0x4e>
        state = '%';
 4fa:	89d2                	mv	s3,s4
 4fc:	b7f5                	j	4e8 <vprintf+0x60>
      if(c == 'd'){
 4fe:	11490c63          	beq	s2,s4,616 <vprintf+0x18e>
 502:	f9d9079b          	addiw	a5,s2,-99
 506:	0ff7f793          	zext.b	a5,a5
 50a:	10fc6e63          	bltu	s8,a5,626 <vprintf+0x19e>
 50e:	f9d9079b          	addiw	a5,s2,-99
 512:	0ff7f713          	zext.b	a4,a5
 516:	10ec6863          	bltu	s8,a4,626 <vprintf+0x19e>
 51a:	00271793          	slli	a5,a4,0x2
 51e:	97e6                	add	a5,a5,s9
 520:	439c                	lw	a5,0(a5)
 522:	97e6                	add	a5,a5,s9
 524:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 526:	008b0913          	addi	s2,s6,8
 52a:	4685                	li	a3,1
 52c:	4629                	li	a2,10
 52e:	000b2583          	lw	a1,0(s6)
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	ea8080e7          	jalr	-344(ra) # 3dc <printint>
 53c:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 53e:	4981                	li	s3,0
 540:	b765                	j	4e8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 542:	008b0913          	addi	s2,s6,8
 546:	4681                	li	a3,0
 548:	4629                	li	a2,10
 54a:	000b2583          	lw	a1,0(s6)
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	e8c080e7          	jalr	-372(ra) # 3dc <printint>
 558:	8b4a                	mv	s6,s2
      state = 0;
 55a:	4981                	li	s3,0
 55c:	b771                	j	4e8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 55e:	008b0913          	addi	s2,s6,8
 562:	4681                	li	a3,0
 564:	866a                	mv	a2,s10
 566:	000b2583          	lw	a1,0(s6)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e70080e7          	jalr	-400(ra) # 3dc <printint>
 574:	8b4a                	mv	s6,s2
      state = 0;
 576:	4981                	li	s3,0
 578:	bf85                	j	4e8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 57a:	008b0793          	addi	a5,s6,8
 57e:	f8f43423          	sd	a5,-120(s0)
 582:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 586:	03000593          	li	a1,48
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	e2e080e7          	jalr	-466(ra) # 3ba <putc>
  putc(fd, 'x');
 594:	07800593          	li	a1,120
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e20080e7          	jalr	-480(ra) # 3ba <putc>
 5a2:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a4:	03c9d793          	srli	a5,s3,0x3c
 5a8:	97de                	add	a5,a5,s7
 5aa:	0007c583          	lbu	a1,0(a5)
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	e0a080e7          	jalr	-502(ra) # 3ba <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5b8:	0992                	slli	s3,s3,0x4
 5ba:	397d                	addiw	s2,s2,-1
 5bc:	fe0914e3          	bnez	s2,5a4 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 5c0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b70d                	j	4e8 <vprintf+0x60>
        s = va_arg(ap, char*);
 5c8:	008b0913          	addi	s2,s6,8
 5cc:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 5d0:	02098163          	beqz	s3,5f2 <vprintf+0x16a>
        while(*s != 0){
 5d4:	0009c583          	lbu	a1,0(s3)
 5d8:	c5ad                	beqz	a1,642 <vprintf+0x1ba>
          putc(fd, *s);
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	dde080e7          	jalr	-546(ra) # 3ba <putc>
          s++;
 5e4:	0985                	addi	s3,s3,1
        while(*s != 0){
 5e6:	0009c583          	lbu	a1,0(s3)
 5ea:	f9e5                	bnez	a1,5da <vprintf+0x152>
        s = va_arg(ap, char*);
 5ec:	8b4a                	mv	s6,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bde5                	j	4e8 <vprintf+0x60>
          s = "(null)";
 5f2:	00000997          	auipc	s3,0x0
 5f6:	27698993          	addi	s3,s3,630 # 868 <malloc+0x11c>
        while(*s != 0){
 5fa:	85ee                	mv	a1,s11
 5fc:	bff9                	j	5da <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 5fe:	008b0913          	addi	s2,s6,8
 602:	000b4583          	lbu	a1,0(s6)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	db2080e7          	jalr	-590(ra) # 3ba <putc>
 610:	8b4a                	mv	s6,s2
      state = 0;
 612:	4981                	li	s3,0
 614:	bdd1                	j	4e8 <vprintf+0x60>
        putc(fd, c);
 616:	85d2                	mv	a1,s4
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	da0080e7          	jalr	-608(ra) # 3ba <putc>
      state = 0;
 622:	4981                	li	s3,0
 624:	b5d1                	j	4e8 <vprintf+0x60>
        putc(fd, '%');
 626:	85d2                	mv	a1,s4
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	d90080e7          	jalr	-624(ra) # 3ba <putc>
        putc(fd, c);
 632:	85ca                	mv	a1,s2
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	d84080e7          	jalr	-636(ra) # 3ba <putc>
      state = 0;
 63e:	4981                	li	s3,0
 640:	b565                	j	4e8 <vprintf+0x60>
        s = va_arg(ap, char*);
 642:	8b4a                	mv	s6,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	b54d                	j	4e8 <vprintf+0x60>
    }
  }
}
 648:	70e6                	ld	ra,120(sp)
 64a:	7446                	ld	s0,112(sp)
 64c:	74a6                	ld	s1,104(sp)
 64e:	7906                	ld	s2,96(sp)
 650:	69e6                	ld	s3,88(sp)
 652:	6a46                	ld	s4,80(sp)
 654:	6aa6                	ld	s5,72(sp)
 656:	6b06                	ld	s6,64(sp)
 658:	7be2                	ld	s7,56(sp)
 65a:	7c42                	ld	s8,48(sp)
 65c:	7ca2                	ld	s9,40(sp)
 65e:	7d02                	ld	s10,32(sp)
 660:	6de2                	ld	s11,24(sp)
 662:	6109                	addi	sp,sp,128
 664:	8082                	ret

0000000000000666 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 666:	715d                	addi	sp,sp,-80
 668:	ec06                	sd	ra,24(sp)
 66a:	e822                	sd	s0,16(sp)
 66c:	1000                	addi	s0,sp,32
 66e:	e010                	sd	a2,0(s0)
 670:	e414                	sd	a3,8(s0)
 672:	e818                	sd	a4,16(s0)
 674:	ec1c                	sd	a5,24(s0)
 676:	03043023          	sd	a6,32(s0)
 67a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 67e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 682:	8622                	mv	a2,s0
 684:	00000097          	auipc	ra,0x0
 688:	e04080e7          	jalr	-508(ra) # 488 <vprintf>
}
 68c:	60e2                	ld	ra,24(sp)
 68e:	6442                	ld	s0,16(sp)
 690:	6161                	addi	sp,sp,80
 692:	8082                	ret

0000000000000694 <printf>:

void
printf(const char *fmt, ...)
{
 694:	711d                	addi	sp,sp,-96
 696:	ec06                	sd	ra,24(sp)
 698:	e822                	sd	s0,16(sp)
 69a:	1000                	addi	s0,sp,32
 69c:	e40c                	sd	a1,8(s0)
 69e:	e810                	sd	a2,16(s0)
 6a0:	ec14                	sd	a3,24(s0)
 6a2:	f018                	sd	a4,32(s0)
 6a4:	f41c                	sd	a5,40(s0)
 6a6:	03043823          	sd	a6,48(s0)
 6aa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ae:	00840613          	addi	a2,s0,8
 6b2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b6:	85aa                	mv	a1,a0
 6b8:	4505                	li	a0,1
 6ba:	00000097          	auipc	ra,0x0
 6be:	dce080e7          	jalr	-562(ra) # 488 <vprintf>
}
 6c2:	60e2                	ld	ra,24(sp)
 6c4:	6442                	ld	s0,16(sp)
 6c6:	6125                	addi	sp,sp,96
 6c8:	8082                	ret

00000000000006ca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ca:	1141                	addi	sp,sp,-16
 6cc:	e422                	sd	s0,8(sp)
 6ce:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d4:	00001797          	auipc	a5,0x1
 6d8:	92c7b783          	ld	a5,-1748(a5) # 1000 <freep>
 6dc:	a02d                	j	706 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6de:	4618                	lw	a4,8(a2)
 6e0:	9f2d                	addw	a4,a4,a1
 6e2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e6:	6398                	ld	a4,0(a5)
 6e8:	6310                	ld	a2,0(a4)
 6ea:	a83d                	j	728 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ec:	ff852703          	lw	a4,-8(a0)
 6f0:	9f31                	addw	a4,a4,a2
 6f2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6f4:	ff053683          	ld	a3,-16(a0)
 6f8:	a091                	j	73c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fa:	6398                	ld	a4,0(a5)
 6fc:	00e7e463          	bltu	a5,a4,704 <free+0x3a>
 700:	00e6ea63          	bltu	a3,a4,714 <free+0x4a>
{
 704:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 706:	fed7fae3          	bgeu	a5,a3,6fa <free+0x30>
 70a:	6398                	ld	a4,0(a5)
 70c:	00e6e463          	bltu	a3,a4,714 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 710:	fee7eae3          	bltu	a5,a4,704 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 714:	ff852583          	lw	a1,-8(a0)
 718:	6390                	ld	a2,0(a5)
 71a:	02059813          	slli	a6,a1,0x20
 71e:	01c85713          	srli	a4,a6,0x1c
 722:	9736                	add	a4,a4,a3
 724:	fae60de3          	beq	a2,a4,6de <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 728:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 72c:	4790                	lw	a2,8(a5)
 72e:	02061593          	slli	a1,a2,0x20
 732:	01c5d713          	srli	a4,a1,0x1c
 736:	973e                	add	a4,a4,a5
 738:	fae68ae3          	beq	a3,a4,6ec <free+0x22>
    p->s.ptr = bp->s.ptr;
 73c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 73e:	00001717          	auipc	a4,0x1
 742:	8cf73123          	sd	a5,-1854(a4) # 1000 <freep>
}
 746:	6422                	ld	s0,8(sp)
 748:	0141                	addi	sp,sp,16
 74a:	8082                	ret

000000000000074c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 74c:	7139                	addi	sp,sp,-64
 74e:	fc06                	sd	ra,56(sp)
 750:	f822                	sd	s0,48(sp)
 752:	f426                	sd	s1,40(sp)
 754:	f04a                	sd	s2,32(sp)
 756:	ec4e                	sd	s3,24(sp)
 758:	e852                	sd	s4,16(sp)
 75a:	e456                	sd	s5,8(sp)
 75c:	e05a                	sd	s6,0(sp)
 75e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 760:	02051493          	slli	s1,a0,0x20
 764:	9081                	srli	s1,s1,0x20
 766:	04bd                	addi	s1,s1,15
 768:	8091                	srli	s1,s1,0x4
 76a:	0014899b          	addiw	s3,s1,1
 76e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 770:	00001517          	auipc	a0,0x1
 774:	89053503          	ld	a0,-1904(a0) # 1000 <freep>
 778:	c515                	beqz	a0,7a4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 77c:	4798                	lw	a4,8(a5)
 77e:	02977f63          	bgeu	a4,s1,7bc <malloc+0x70>
 782:	8a4e                	mv	s4,s3
 784:	0009871b          	sext.w	a4,s3
 788:	6685                	lui	a3,0x1
 78a:	00d77363          	bgeu	a4,a3,790 <malloc+0x44>
 78e:	6a05                	lui	s4,0x1
 790:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 794:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 798:	00001917          	auipc	s2,0x1
 79c:	86890913          	addi	s2,s2,-1944 # 1000 <freep>
  if(p == (char*)-1)
 7a0:	5afd                	li	s5,-1
 7a2:	a895                	j	816 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7a4:	00001797          	auipc	a5,0x1
 7a8:	86c78793          	addi	a5,a5,-1940 # 1010 <base>
 7ac:	00001717          	auipc	a4,0x1
 7b0:	84f73a23          	sd	a5,-1964(a4) # 1000 <freep>
 7b4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7b6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ba:	b7e1                	j	782 <malloc+0x36>
      if(p->s.size == nunits)
 7bc:	02e48c63          	beq	s1,a4,7f4 <malloc+0xa8>
        p->s.size -= nunits;
 7c0:	4137073b          	subw	a4,a4,s3
 7c4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7c6:	02071693          	slli	a3,a4,0x20
 7ca:	01c6d713          	srli	a4,a3,0x1c
 7ce:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82a73623          	sd	a0,-2004(a4) # 1000 <freep>
      return (void*)(p + 1);
 7dc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7e0:	70e2                	ld	ra,56(sp)
 7e2:	7442                	ld	s0,48(sp)
 7e4:	74a2                	ld	s1,40(sp)
 7e6:	7902                	ld	s2,32(sp)
 7e8:	69e2                	ld	s3,24(sp)
 7ea:	6a42                	ld	s4,16(sp)
 7ec:	6aa2                	ld	s5,8(sp)
 7ee:	6b02                	ld	s6,0(sp)
 7f0:	6121                	addi	sp,sp,64
 7f2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7f4:	6398                	ld	a4,0(a5)
 7f6:	e118                	sd	a4,0(a0)
 7f8:	bff1                	j	7d4 <malloc+0x88>
  hp->s.size = nu;
 7fa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7fe:	0541                	addi	a0,a0,16
 800:	00000097          	auipc	ra,0x0
 804:	eca080e7          	jalr	-310(ra) # 6ca <free>
  return freep;
 808:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 80c:	d971                	beqz	a0,7e0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 810:	4798                	lw	a4,8(a5)
 812:	fa9775e3          	bgeu	a4,s1,7bc <malloc+0x70>
    if(p == freep)
 816:	00093703          	ld	a4,0(s2)
 81a:	853e                	mv	a0,a5
 81c:	fef719e3          	bne	a4,a5,80e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 820:	8552                	mv	a0,s4
 822:	00000097          	auipc	ra,0x0
 826:	b48080e7          	jalr	-1208(ra) # 36a <sbrk>
  if(p == (char*)-1)
 82a:	fd5518e3          	bne	a0,s5,7fa <malloc+0xae>
        return 0;
 82e:	4501                	li	a0,0
 830:	bf45                	j	7e0 <malloc+0x94>
