
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1c8080e7          	jalr	456(ra) # 1f0 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2ea080e7          	jalr	746(ra) # 31a <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2aa080e7          	jalr	682(ra) # 2ea <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00000597          	auipc	a1,0x0
  4c:	7f858593          	addi	a1,a1,2040 # 840 <malloc+0xec>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	61c080e7          	jalr	1564(ra) # 66e <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	28e080e7          	jalr	654(ra) # 2ea <exit>

0000000000000064 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <main>
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	274080e7          	jalr	628(ra) # 2ea <exit>

000000000000007e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7e:	1141                	addi	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  84:	87aa                	mv	a5,a0
  86:	0585                	addi	a1,a1,1
  88:	0785                	addi	a5,a5,1
  8a:	fff5c703          	lbu	a4,-1(a1)
  8e:	fee78fa3          	sb	a4,-1(a5)
  92:	fb75                	bnez	a4,86 <strcpy+0x8>
    ;
  return os;
}
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cb91                	beqz	a5,b8 <strcmp+0x1e>
  a6:	0005c703          	lbu	a4,0(a1)
  aa:	00f71763          	bne	a4,a5,b8 <strcmp+0x1e>
    p++, q++;
  ae:	0505                	addi	a0,a0,1
  b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	fbe5                	bnez	a5,a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b8:	0005c503          	lbu	a0,0(a1)
}
  bc:	40a7853b          	subw	a0,a5,a0
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strlen>:

uint
strlen(const char *s)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cf91                	beqz	a5,ec <strlen+0x26>
  d2:	0505                	addi	a0,a0,1
  d4:	87aa                	mv	a5,a0
  d6:	4685                	li	a3,1
  d8:	9e89                	subw	a3,a3,a0
  da:	00f6853b          	addw	a0,a3,a5
  de:	0785                	addi	a5,a5,1
  e0:	fff7c703          	lbu	a4,-1(a5)
  e4:	fb7d                	bnez	a4,da <strlen+0x14>
    ;
  return n;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret
  for(n = 0; s[n]; n++)
  ec:	4501                	li	a0,0
  ee:	bfe5                	j	e6 <strlen+0x20>

00000000000000f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f6:	ca19                	beqz	a2,10c <memset+0x1c>
  f8:	87aa                	mv	a5,a0
  fa:	1602                	slli	a2,a2,0x20
  fc:	9201                	srli	a2,a2,0x20
  fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 102:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 106:	0785                	addi	a5,a5,1
 108:	fee79de3          	bne	a5,a4,102 <memset+0x12>
  }
  return dst;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strchr>:

char*
strchr(const char *s, char c)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  for(; *s; s++)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb99                	beqz	a5,132 <strchr+0x20>
    if(*s == c)
 11e:	00f58763          	beq	a1,a5,12c <strchr+0x1a>
  for(; *s; s++)
 122:	0505                	addi	a0,a0,1
 124:	00054783          	lbu	a5,0(a0)
 128:	fbfd                	bnez	a5,11e <strchr+0xc>
      return (char*)s;
  return 0;
 12a:	4501                	li	a0,0
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret
  return 0;
 132:	4501                	li	a0,0
 134:	bfe5                	j	12c <strchr+0x1a>

0000000000000136 <gets>:

char*
gets(char *buf, int max)
{
 136:	711d                	addi	sp,sp,-96
 138:	ec86                	sd	ra,88(sp)
 13a:	e8a2                	sd	s0,80(sp)
 13c:	e4a6                	sd	s1,72(sp)
 13e:	e0ca                	sd	s2,64(sp)
 140:	fc4e                	sd	s3,56(sp)
 142:	f852                	sd	s4,48(sp)
 144:	f456                	sd	s5,40(sp)
 146:	f05a                	sd	s6,32(sp)
 148:	ec5e                	sd	s7,24(sp)
 14a:	1080                	addi	s0,sp,96
 14c:	8baa                	mv	s7,a0
 14e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 150:	892a                	mv	s2,a0
 152:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 154:	4aa9                	li	s5,10
 156:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 158:	89a6                	mv	s3,s1
 15a:	2485                	addiw	s1,s1,1
 15c:	0344d863          	bge	s1,s4,18c <gets+0x56>
    cc = read(0, &c, 1);
 160:	4605                	li	a2,1
 162:	faf40593          	addi	a1,s0,-81
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	19a080e7          	jalr	410(ra) # 302 <read>
    if(cc < 1)
 170:	00a05e63          	blez	a0,18c <gets+0x56>
    buf[i++] = c;
 174:	faf44783          	lbu	a5,-81(s0)
 178:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17c:	01578763          	beq	a5,s5,18a <gets+0x54>
 180:	0905                	addi	s2,s2,1
 182:	fd679be3          	bne	a5,s6,158 <gets+0x22>
  for(i=0; i+1 < max; ){
 186:	89a6                	mv	s3,s1
 188:	a011                	j	18c <gets+0x56>
 18a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18c:	99de                	add	s3,s3,s7
 18e:	00098023          	sb	zero,0(s3)
  return buf;
}
 192:	855e                	mv	a0,s7
 194:	60e6                	ld	ra,88(sp)
 196:	6446                	ld	s0,80(sp)
 198:	64a6                	ld	s1,72(sp)
 19a:	6906                	ld	s2,64(sp)
 19c:	79e2                	ld	s3,56(sp)
 19e:	7a42                	ld	s4,48(sp)
 1a0:	7aa2                	ld	s5,40(sp)
 1a2:	7b02                	ld	s6,32(sp)
 1a4:	6be2                	ld	s7,24(sp)
 1a6:	6125                	addi	sp,sp,96
 1a8:	8082                	ret

00000000000001aa <stat>:

int
stat(const char *n, struct stat *st)
{
 1aa:	1101                	addi	sp,sp,-32
 1ac:	ec06                	sd	ra,24(sp)
 1ae:	e822                	sd	s0,16(sp)
 1b0:	e426                	sd	s1,8(sp)
 1b2:	e04a                	sd	s2,0(sp)
 1b4:	1000                	addi	s0,sp,32
 1b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	4581                	li	a1,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	170080e7          	jalr	368(ra) # 32a <open>
  if(fd < 0)
 1c2:	02054563          	bltz	a0,1ec <stat+0x42>
 1c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	178080e7          	jalr	376(ra) # 342 <fstat>
 1d2:	892a                	mv	s2,a0
  close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	13c080e7          	jalr	316(ra) # 312 <close>
  return r;
}
 1de:	854a                	mv	a0,s2
 1e0:	60e2                	ld	ra,24(sp)
 1e2:	6442                	ld	s0,16(sp)
 1e4:	64a2                	ld	s1,8(sp)
 1e6:	6902                	ld	s2,0(sp)
 1e8:	6105                	addi	sp,sp,32
 1ea:	8082                	ret
    return -1;
 1ec:	597d                	li	s2,-1
 1ee:	bfc5                	j	1de <stat+0x34>

00000000000001f0 <atoi>:

int
atoi(const char *s)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f6:	00054683          	lbu	a3,0(a0)
 1fa:	fd06879b          	addiw	a5,a3,-48
 1fe:	0ff7f793          	zext.b	a5,a5
 202:	4625                	li	a2,9
 204:	02f66863          	bltu	a2,a5,234 <atoi+0x44>
 208:	872a                	mv	a4,a0
  n = 0;
 20a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 20c:	0705                	addi	a4,a4,1
 20e:	0025179b          	slliw	a5,a0,0x2
 212:	9fa9                	addw	a5,a5,a0
 214:	0017979b          	slliw	a5,a5,0x1
 218:	9fb5                	addw	a5,a5,a3
 21a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21e:	00074683          	lbu	a3,0(a4)
 222:	fd06879b          	addiw	a5,a3,-48
 226:	0ff7f793          	zext.b	a5,a5
 22a:	fef671e3          	bgeu	a2,a5,20c <atoi+0x1c>
  return n;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  n = 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <atoi+0x3e>

0000000000000238 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23e:	02b57463          	bgeu	a0,a1,266 <memmove+0x2e>
    while(n-- > 0)
 242:	00c05f63          	blez	a2,260 <memmove+0x28>
 246:	1602                	slli	a2,a2,0x20
 248:	9201                	srli	a2,a2,0x20
 24a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24e:	872a                	mv	a4,a0
      *dst++ = *src++;
 250:	0585                	addi	a1,a1,1
 252:	0705                	addi	a4,a4,1
 254:	fff5c683          	lbu	a3,-1(a1)
 258:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25c:	fee79ae3          	bne	a5,a4,250 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
    dst += n;
 266:	00c50733          	add	a4,a0,a2
    src += n;
 26a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26c:	fec05ae3          	blez	a2,260 <memmove+0x28>
 270:	fff6079b          	addiw	a5,a2,-1
 274:	1782                	slli	a5,a5,0x20
 276:	9381                	srli	a5,a5,0x20
 278:	fff7c793          	not	a5,a5
 27c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27e:	15fd                	addi	a1,a1,-1
 280:	177d                	addi	a4,a4,-1
 282:	0005c683          	lbu	a3,0(a1)
 286:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28a:	fee79ae3          	bne	a5,a4,27e <memmove+0x46>
 28e:	bfc9                	j	260 <memmove+0x28>

0000000000000290 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e422                	sd	s0,8(sp)
 294:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 296:	ca05                	beqz	a2,2c6 <memcmp+0x36>
 298:	fff6069b          	addiw	a3,a2,-1
 29c:	1682                	slli	a3,a3,0x20
 29e:	9281                	srli	a3,a3,0x20
 2a0:	0685                	addi	a3,a3,1
 2a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	0005c703          	lbu	a4,0(a1)
 2ac:	00e79863          	bne	a5,a4,2bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b0:	0505                	addi	a0,a0,1
    p2++;
 2b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b4:	fed518e3          	bne	a0,a3,2a4 <memcmp+0x14>
  }
  return 0;
 2b8:	4501                	li	a0,0
 2ba:	a019                	j	2c0 <memcmp+0x30>
      return *p1 - *p2;
 2bc:	40e7853b          	subw	a0,a5,a4
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  return 0;
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <memcmp+0x30>

00000000000002ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d2:	00000097          	auipc	ra,0x0
 2d6:	f66080e7          	jalr	-154(ra) # 238 <memmove>
}
 2da:	60a2                	ld	ra,8(sp)
 2dc:	6402                	ld	s0,0(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret

00000000000002e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e2:	4885                	li	a7,1
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ea:	4889                	li	a7,2
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f2:	488d                	li	a7,3
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fa:	4891                	li	a7,4
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <read>:
.global read
read:
 li a7, SYS_read
 302:	4895                	li	a7,5
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <write>:
.global write
write:
 li a7, SYS_write
 30a:	48c1                	li	a7,16
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <close>:
.global close
close:
 li a7, SYS_close
 312:	48d5                	li	a7,21
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <kill>:
.global kill
kill:
 li a7, SYS_kill
 31a:	4899                	li	a7,6
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <exec>:
.global exec
exec:
 li a7, SYS_exec
 322:	489d                	li	a7,7
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <open>:
.global open
open:
 li a7, SYS_open
 32a:	48bd                	li	a7,15
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 332:	48c5                	li	a7,17
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33a:	48c9                	li	a7,18
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 342:	48a1                	li	a7,8
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <link>:
.global link
link:
 li a7, SYS_link
 34a:	48cd                	li	a7,19
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 352:	48d1                	li	a7,20
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35a:	48a5                	li	a7,9
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <dup>:
.global dup
dup:
 li a7, SYS_dup
 362:	48a9                	li	a7,10
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36a:	48ad                	li	a7,11
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 372:	48b1                	li	a7,12
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37a:	48b5                	li	a7,13
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 382:	48b9                	li	a7,14
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <trace>:
.global trace
trace:
 li a7, SYS_trace
 38a:	48d9                	li	a7,22
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 392:	48dd                	li	a7,23
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 39a:	48e1                	li	a7,24
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3a2:	48e5                	li	a7,25
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3aa:	48e9                	li	a7,26
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 3b2:	48ed                	li	a7,27
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3ba:	48f1                	li	a7,28
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c2:	1101                	addi	sp,sp,-32
 3c4:	ec06                	sd	ra,24(sp)
 3c6:	e822                	sd	s0,16(sp)
 3c8:	1000                	addi	s0,sp,32
 3ca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ce:	4605                	li	a2,1
 3d0:	fef40593          	addi	a1,s0,-17
 3d4:	00000097          	auipc	ra,0x0
 3d8:	f36080e7          	jalr	-202(ra) # 30a <write>
}
 3dc:	60e2                	ld	ra,24(sp)
 3de:	6442                	ld	s0,16(sp)
 3e0:	6105                	addi	sp,sp,32
 3e2:	8082                	ret

00000000000003e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e4:	7139                	addi	sp,sp,-64
 3e6:	fc06                	sd	ra,56(sp)
 3e8:	f822                	sd	s0,48(sp)
 3ea:	f426                	sd	s1,40(sp)
 3ec:	f04a                	sd	s2,32(sp)
 3ee:	ec4e                	sd	s3,24(sp)
 3f0:	0080                	addi	s0,sp,64
 3f2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f4:	c299                	beqz	a3,3fa <printint+0x16>
 3f6:	0805c963          	bltz	a1,488 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3fa:	2581                	sext.w	a1,a1
  neg = 0;
 3fc:	4881                	li	a7,0
 3fe:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 402:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 404:	2601                	sext.w	a2,a2
 406:	00000517          	auipc	a0,0x0
 40a:	4b250513          	addi	a0,a0,1202 # 8b8 <digits>
 40e:	883a                	mv	a6,a4
 410:	2705                	addiw	a4,a4,1
 412:	02c5f7bb          	remuw	a5,a1,a2
 416:	1782                	slli	a5,a5,0x20
 418:	9381                	srli	a5,a5,0x20
 41a:	97aa                	add	a5,a5,a0
 41c:	0007c783          	lbu	a5,0(a5)
 420:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 424:	0005879b          	sext.w	a5,a1
 428:	02c5d5bb          	divuw	a1,a1,a2
 42c:	0685                	addi	a3,a3,1
 42e:	fec7f0e3          	bgeu	a5,a2,40e <printint+0x2a>
  if(neg)
 432:	00088c63          	beqz	a7,44a <printint+0x66>
    buf[i++] = '-';
 436:	fd070793          	addi	a5,a4,-48
 43a:	00878733          	add	a4,a5,s0
 43e:	02d00793          	li	a5,45
 442:	fef70823          	sb	a5,-16(a4)
 446:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 44a:	02e05863          	blez	a4,47a <printint+0x96>
 44e:	fc040793          	addi	a5,s0,-64
 452:	00e78933          	add	s2,a5,a4
 456:	fff78993          	addi	s3,a5,-1
 45a:	99ba                	add	s3,s3,a4
 45c:	377d                	addiw	a4,a4,-1
 45e:	1702                	slli	a4,a4,0x20
 460:	9301                	srli	a4,a4,0x20
 462:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 466:	fff94583          	lbu	a1,-1(s2)
 46a:	8526                	mv	a0,s1
 46c:	00000097          	auipc	ra,0x0
 470:	f56080e7          	jalr	-170(ra) # 3c2 <putc>
  while(--i >= 0)
 474:	197d                	addi	s2,s2,-1
 476:	ff3918e3          	bne	s2,s3,466 <printint+0x82>
}
 47a:	70e2                	ld	ra,56(sp)
 47c:	7442                	ld	s0,48(sp)
 47e:	74a2                	ld	s1,40(sp)
 480:	7902                	ld	s2,32(sp)
 482:	69e2                	ld	s3,24(sp)
 484:	6121                	addi	sp,sp,64
 486:	8082                	ret
    x = -xx;
 488:	40b005bb          	negw	a1,a1
    neg = 1;
 48c:	4885                	li	a7,1
    x = -xx;
 48e:	bf85                	j	3fe <printint+0x1a>

0000000000000490 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 490:	7119                	addi	sp,sp,-128
 492:	fc86                	sd	ra,120(sp)
 494:	f8a2                	sd	s0,112(sp)
 496:	f4a6                	sd	s1,104(sp)
 498:	f0ca                	sd	s2,96(sp)
 49a:	ecce                	sd	s3,88(sp)
 49c:	e8d2                	sd	s4,80(sp)
 49e:	e4d6                	sd	s5,72(sp)
 4a0:	e0da                	sd	s6,64(sp)
 4a2:	fc5e                	sd	s7,56(sp)
 4a4:	f862                	sd	s8,48(sp)
 4a6:	f466                	sd	s9,40(sp)
 4a8:	f06a                	sd	s10,32(sp)
 4aa:	ec6e                	sd	s11,24(sp)
 4ac:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ae:	0005c903          	lbu	s2,0(a1)
 4b2:	18090f63          	beqz	s2,650 <vprintf+0x1c0>
 4b6:	8aaa                	mv	s5,a0
 4b8:	8b32                	mv	s6,a2
 4ba:	00158493          	addi	s1,a1,1
  state = 0;
 4be:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4c0:	02500a13          	li	s4,37
 4c4:	4c55                	li	s8,21
 4c6:	00000c97          	auipc	s9,0x0
 4ca:	39ac8c93          	addi	s9,s9,922 # 860 <malloc+0x10c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4ce:	02800d93          	li	s11,40
  putc(fd, 'x');
 4d2:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4d4:	00000b97          	auipc	s7,0x0
 4d8:	3e4b8b93          	addi	s7,s7,996 # 8b8 <digits>
 4dc:	a839                	j	4fa <vprintf+0x6a>
        putc(fd, c);
 4de:	85ca                	mv	a1,s2
 4e0:	8556                	mv	a0,s5
 4e2:	00000097          	auipc	ra,0x0
 4e6:	ee0080e7          	jalr	-288(ra) # 3c2 <putc>
 4ea:	a019                	j	4f0 <vprintf+0x60>
    } else if(state == '%'){
 4ec:	01498d63          	beq	s3,s4,506 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 4f0:	0485                	addi	s1,s1,1
 4f2:	fff4c903          	lbu	s2,-1(s1)
 4f6:	14090d63          	beqz	s2,650 <vprintf+0x1c0>
    if(state == 0){
 4fa:	fe0999e3          	bnez	s3,4ec <vprintf+0x5c>
      if(c == '%'){
 4fe:	ff4910e3          	bne	s2,s4,4de <vprintf+0x4e>
        state = '%';
 502:	89d2                	mv	s3,s4
 504:	b7f5                	j	4f0 <vprintf+0x60>
      if(c == 'd'){
 506:	11490c63          	beq	s2,s4,61e <vprintf+0x18e>
 50a:	f9d9079b          	addiw	a5,s2,-99
 50e:	0ff7f793          	zext.b	a5,a5
 512:	10fc6e63          	bltu	s8,a5,62e <vprintf+0x19e>
 516:	f9d9079b          	addiw	a5,s2,-99
 51a:	0ff7f713          	zext.b	a4,a5
 51e:	10ec6863          	bltu	s8,a4,62e <vprintf+0x19e>
 522:	00271793          	slli	a5,a4,0x2
 526:	97e6                	add	a5,a5,s9
 528:	439c                	lw	a5,0(a5)
 52a:	97e6                	add	a5,a5,s9
 52c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 52e:	008b0913          	addi	s2,s6,8
 532:	4685                	li	a3,1
 534:	4629                	li	a2,10
 536:	000b2583          	lw	a1,0(s6)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	ea8080e7          	jalr	-344(ra) # 3e4 <printint>
 544:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 546:	4981                	li	s3,0
 548:	b765                	j	4f0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54a:	008b0913          	addi	s2,s6,8
 54e:	4681                	li	a3,0
 550:	4629                	li	a2,10
 552:	000b2583          	lw	a1,0(s6)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e8c080e7          	jalr	-372(ra) # 3e4 <printint>
 560:	8b4a                	mv	s6,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	b771                	j	4f0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 566:	008b0913          	addi	s2,s6,8
 56a:	4681                	li	a3,0
 56c:	866a                	mv	a2,s10
 56e:	000b2583          	lw	a1,0(s6)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e70080e7          	jalr	-400(ra) # 3e4 <printint>
 57c:	8b4a                	mv	s6,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	bf85                	j	4f0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 582:	008b0793          	addi	a5,s6,8
 586:	f8f43423          	sd	a5,-120(s0)
 58a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 58e:	03000593          	li	a1,48
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	e2e080e7          	jalr	-466(ra) # 3c2 <putc>
  putc(fd, 'x');
 59c:	07800593          	li	a1,120
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e20080e7          	jalr	-480(ra) # 3c2 <putc>
 5aa:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ac:	03c9d793          	srli	a5,s3,0x3c
 5b0:	97de                	add	a5,a5,s7
 5b2:	0007c583          	lbu	a1,0(a5)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	e0a080e7          	jalr	-502(ra) # 3c2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c0:	0992                	slli	s3,s3,0x4
 5c2:	397d                	addiw	s2,s2,-1
 5c4:	fe0914e3          	bnez	s2,5ac <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 5c8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5cc:	4981                	li	s3,0
 5ce:	b70d                	j	4f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 5d0:	008b0913          	addi	s2,s6,8
 5d4:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 5d8:	02098163          	beqz	s3,5fa <vprintf+0x16a>
        while(*s != 0){
 5dc:	0009c583          	lbu	a1,0(s3)
 5e0:	c5ad                	beqz	a1,64a <vprintf+0x1ba>
          putc(fd, *s);
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	dde080e7          	jalr	-546(ra) # 3c2 <putc>
          s++;
 5ec:	0985                	addi	s3,s3,1
        while(*s != 0){
 5ee:	0009c583          	lbu	a1,0(s3)
 5f2:	f9e5                	bnez	a1,5e2 <vprintf+0x152>
        s = va_arg(ap, char*);
 5f4:	8b4a                	mv	s6,s2
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bde5                	j	4f0 <vprintf+0x60>
          s = "(null)";
 5fa:	00000997          	auipc	s3,0x0
 5fe:	25e98993          	addi	s3,s3,606 # 858 <malloc+0x104>
        while(*s != 0){
 602:	85ee                	mv	a1,s11
 604:	bff9                	j	5e2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 606:	008b0913          	addi	s2,s6,8
 60a:	000b4583          	lbu	a1,0(s6)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	db2080e7          	jalr	-590(ra) # 3c2 <putc>
 618:	8b4a                	mv	s6,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bdd1                	j	4f0 <vprintf+0x60>
        putc(fd, c);
 61e:	85d2                	mv	a1,s4
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	da0080e7          	jalr	-608(ra) # 3c2 <putc>
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b5d1                	j	4f0 <vprintf+0x60>
        putc(fd, '%');
 62e:	85d2                	mv	a1,s4
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	d90080e7          	jalr	-624(ra) # 3c2 <putc>
        putc(fd, c);
 63a:	85ca                	mv	a1,s2
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	d84080e7          	jalr	-636(ra) # 3c2 <putc>
      state = 0;
 646:	4981                	li	s3,0
 648:	b565                	j	4f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 64a:	8b4a                	mv	s6,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b54d                	j	4f0 <vprintf+0x60>
    }
  }
}
 650:	70e6                	ld	ra,120(sp)
 652:	7446                	ld	s0,112(sp)
 654:	74a6                	ld	s1,104(sp)
 656:	7906                	ld	s2,96(sp)
 658:	69e6                	ld	s3,88(sp)
 65a:	6a46                	ld	s4,80(sp)
 65c:	6aa6                	ld	s5,72(sp)
 65e:	6b06                	ld	s6,64(sp)
 660:	7be2                	ld	s7,56(sp)
 662:	7c42                	ld	s8,48(sp)
 664:	7ca2                	ld	s9,40(sp)
 666:	7d02                	ld	s10,32(sp)
 668:	6de2                	ld	s11,24(sp)
 66a:	6109                	addi	sp,sp,128
 66c:	8082                	ret

000000000000066e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 66e:	715d                	addi	sp,sp,-80
 670:	ec06                	sd	ra,24(sp)
 672:	e822                	sd	s0,16(sp)
 674:	1000                	addi	s0,sp,32
 676:	e010                	sd	a2,0(s0)
 678:	e414                	sd	a3,8(s0)
 67a:	e818                	sd	a4,16(s0)
 67c:	ec1c                	sd	a5,24(s0)
 67e:	03043023          	sd	a6,32(s0)
 682:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 686:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 68a:	8622                	mv	a2,s0
 68c:	00000097          	auipc	ra,0x0
 690:	e04080e7          	jalr	-508(ra) # 490 <vprintf>
}
 694:	60e2                	ld	ra,24(sp)
 696:	6442                	ld	s0,16(sp)
 698:	6161                	addi	sp,sp,80
 69a:	8082                	ret

000000000000069c <printf>:

void
printf(const char *fmt, ...)
{
 69c:	711d                	addi	sp,sp,-96
 69e:	ec06                	sd	ra,24(sp)
 6a0:	e822                	sd	s0,16(sp)
 6a2:	1000                	addi	s0,sp,32
 6a4:	e40c                	sd	a1,8(s0)
 6a6:	e810                	sd	a2,16(s0)
 6a8:	ec14                	sd	a3,24(s0)
 6aa:	f018                	sd	a4,32(s0)
 6ac:	f41c                	sd	a5,40(s0)
 6ae:	03043823          	sd	a6,48(s0)
 6b2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6b6:	00840613          	addi	a2,s0,8
 6ba:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6be:	85aa                	mv	a1,a0
 6c0:	4505                	li	a0,1
 6c2:	00000097          	auipc	ra,0x0
 6c6:	dce080e7          	jalr	-562(ra) # 490 <vprintf>
}
 6ca:	60e2                	ld	ra,24(sp)
 6cc:	6442                	ld	s0,16(sp)
 6ce:	6125                	addi	sp,sp,96
 6d0:	8082                	ret

00000000000006d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d2:	1141                	addi	sp,sp,-16
 6d4:	e422                	sd	s0,8(sp)
 6d6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6dc:	00001797          	auipc	a5,0x1
 6e0:	9247b783          	ld	a5,-1756(a5) # 1000 <freep>
 6e4:	a02d                	j	70e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6e6:	4618                	lw	a4,8(a2)
 6e8:	9f2d                	addw	a4,a4,a1
 6ea:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ee:	6398                	ld	a4,0(a5)
 6f0:	6310                	ld	a2,0(a4)
 6f2:	a83d                	j	730 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6f4:	ff852703          	lw	a4,-8(a0)
 6f8:	9f31                	addw	a4,a4,a2
 6fa:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6fc:	ff053683          	ld	a3,-16(a0)
 700:	a091                	j	744 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 702:	6398                	ld	a4,0(a5)
 704:	00e7e463          	bltu	a5,a4,70c <free+0x3a>
 708:	00e6ea63          	bltu	a3,a4,71c <free+0x4a>
{
 70c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70e:	fed7fae3          	bgeu	a5,a3,702 <free+0x30>
 712:	6398                	ld	a4,0(a5)
 714:	00e6e463          	bltu	a3,a4,71c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 718:	fee7eae3          	bltu	a5,a4,70c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 71c:	ff852583          	lw	a1,-8(a0)
 720:	6390                	ld	a2,0(a5)
 722:	02059813          	slli	a6,a1,0x20
 726:	01c85713          	srli	a4,a6,0x1c
 72a:	9736                	add	a4,a4,a3
 72c:	fae60de3          	beq	a2,a4,6e6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 730:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 734:	4790                	lw	a2,8(a5)
 736:	02061593          	slli	a1,a2,0x20
 73a:	01c5d713          	srli	a4,a1,0x1c
 73e:	973e                	add	a4,a4,a5
 740:	fae68ae3          	beq	a3,a4,6f4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 744:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 746:	00001717          	auipc	a4,0x1
 74a:	8af73d23          	sd	a5,-1862(a4) # 1000 <freep>
}
 74e:	6422                	ld	s0,8(sp)
 750:	0141                	addi	sp,sp,16
 752:	8082                	ret

0000000000000754 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 754:	7139                	addi	sp,sp,-64
 756:	fc06                	sd	ra,56(sp)
 758:	f822                	sd	s0,48(sp)
 75a:	f426                	sd	s1,40(sp)
 75c:	f04a                	sd	s2,32(sp)
 75e:	ec4e                	sd	s3,24(sp)
 760:	e852                	sd	s4,16(sp)
 762:	e456                	sd	s5,8(sp)
 764:	e05a                	sd	s6,0(sp)
 766:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 768:	02051493          	slli	s1,a0,0x20
 76c:	9081                	srli	s1,s1,0x20
 76e:	04bd                	addi	s1,s1,15
 770:	8091                	srli	s1,s1,0x4
 772:	0014899b          	addiw	s3,s1,1
 776:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 778:	00001517          	auipc	a0,0x1
 77c:	88853503          	ld	a0,-1912(a0) # 1000 <freep>
 780:	c515                	beqz	a0,7ac <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 782:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 784:	4798                	lw	a4,8(a5)
 786:	02977f63          	bgeu	a4,s1,7c4 <malloc+0x70>
 78a:	8a4e                	mv	s4,s3
 78c:	0009871b          	sext.w	a4,s3
 790:	6685                	lui	a3,0x1
 792:	00d77363          	bgeu	a4,a3,798 <malloc+0x44>
 796:	6a05                	lui	s4,0x1
 798:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 79c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7a0:	00001917          	auipc	s2,0x1
 7a4:	86090913          	addi	s2,s2,-1952 # 1000 <freep>
  if(p == (char*)-1)
 7a8:	5afd                	li	s5,-1
 7aa:	a895                	j	81e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7ac:	00001797          	auipc	a5,0x1
 7b0:	86478793          	addi	a5,a5,-1948 # 1010 <base>
 7b4:	00001717          	auipc	a4,0x1
 7b8:	84f73623          	sd	a5,-1972(a4) # 1000 <freep>
 7bc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7be:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7c2:	b7e1                	j	78a <malloc+0x36>
      if(p->s.size == nunits)
 7c4:	02e48c63          	beq	s1,a4,7fc <malloc+0xa8>
        p->s.size -= nunits;
 7c8:	4137073b          	subw	a4,a4,s3
 7cc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ce:	02071693          	slli	a3,a4,0x20
 7d2:	01c6d713          	srli	a4,a3,0x1c
 7d6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7dc:	00001717          	auipc	a4,0x1
 7e0:	82a73223          	sd	a0,-2012(a4) # 1000 <freep>
      return (void*)(p + 1);
 7e4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7e8:	70e2                	ld	ra,56(sp)
 7ea:	7442                	ld	s0,48(sp)
 7ec:	74a2                	ld	s1,40(sp)
 7ee:	7902                	ld	s2,32(sp)
 7f0:	69e2                	ld	s3,24(sp)
 7f2:	6a42                	ld	s4,16(sp)
 7f4:	6aa2                	ld	s5,8(sp)
 7f6:	6b02                	ld	s6,0(sp)
 7f8:	6121                	addi	sp,sp,64
 7fa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7fc:	6398                	ld	a4,0(a5)
 7fe:	e118                	sd	a4,0(a0)
 800:	bff1                	j	7dc <malloc+0x88>
  hp->s.size = nu;
 802:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 806:	0541                	addi	a0,a0,16
 808:	00000097          	auipc	ra,0x0
 80c:	eca080e7          	jalr	-310(ra) # 6d2 <free>
  return freep;
 810:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 814:	d971                	beqz	a0,7e8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 816:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 818:	4798                	lw	a4,8(a5)
 81a:	fa9775e3          	bgeu	a4,s1,7c4 <malloc+0x70>
    if(p == freep)
 81e:	00093703          	ld	a4,0(s2)
 822:	853e                	mv	a0,a5
 824:	fef719e3          	bne	a4,a5,816 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 828:	8552                	mv	a0,s4
 82a:	00000097          	auipc	ra,0x0
 82e:	b48080e7          	jalr	-1208(ra) # 372 <sbrk>
  if(p == (char*)-1)
 832:	fd5518e3          	bne	a0,s5,802 <malloc+0xae>
        return 0;
 836:	4501                	li	a0,0
 838:	bf45                	j	7e8 <malloc+0x94>
