
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	00090913          	mv	s2,s2
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	39c080e7          	jalr	924(ra) # 3bc <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	390080e7          	jalr	912(ra) # 3c4 <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	8c058593          	addi	a1,a1,-1856 # 900 <malloc+0xf2>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	6de080e7          	jalr	1758(ra) # 728 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	350080e7          	jalr	848(ra) # 3a4 <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	8aa58593          	addi	a1,a1,-1878 # 918 <malloc+0x10a>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	6b0080e7          	jalr	1712(ra) # 728 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	322080e7          	jalr	802(ra) # 3a4 <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	e052                	sd	s4,0(sp)
  98:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9a:	4785                	li	a5,1
  9c:	04a7d763          	bge	a5,a0,ea <main+0x60>
  a0:	00858913          	addi	s2,a1,8
  a4:	ffe5099b          	addiw	s3,a0,-2
  a8:	02099793          	slli	a5,s3,0x20
  ac:	01d7d993          	srli	s3,a5,0x1d
  b0:	05c1                	addi	a1,a1,16
  b2:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b4:	4581                	li	a1,0
  b6:	00093503          	ld	a0,0(s2) # 1010 <buf>
  ba:	00000097          	auipc	ra,0x0
  be:	32a080e7          	jalr	810(ra) # 3e4 <open>
  c2:	84aa                	mv	s1,a0
  c4:	02054d63          	bltz	a0,fe <main+0x74>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c8:	00000097          	auipc	ra,0x0
  cc:	f38080e7          	jalr	-200(ra) # 0 <cat>
    close(fd);
  d0:	8526                	mv	a0,s1
  d2:	00000097          	auipc	ra,0x0
  d6:	2fa080e7          	jalr	762(ra) # 3cc <close>
  for(i = 1; i < argc; i++){
  da:	0921                	addi	s2,s2,8
  dc:	fd391ce3          	bne	s2,s3,b4 <main+0x2a>
  }
  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2c2080e7          	jalr	706(ra) # 3a4 <exit>
    cat(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <cat>
    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	2ae080e7          	jalr	686(ra) # 3a4 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fe:	00093603          	ld	a2,0(s2)
 102:	00001597          	auipc	a1,0x1
 106:	82e58593          	addi	a1,a1,-2002 # 930 <malloc+0x122>
 10a:	4509                	li	a0,2
 10c:	00000097          	auipc	ra,0x0
 110:	61c080e7          	jalr	1564(ra) # 728 <fprintf>
      exit(1);
 114:	4505                	li	a0,1
 116:	00000097          	auipc	ra,0x0
 11a:	28e080e7          	jalr	654(ra) # 3a4 <exit>

000000000000011e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  extern int main();
  main();
 126:	00000097          	auipc	ra,0x0
 12a:	f64080e7          	jalr	-156(ra) # 8a <main>
  exit(0);
 12e:	4501                	li	a0,0
 130:	00000097          	auipc	ra,0x0
 134:	274080e7          	jalr	628(ra) # 3a4 <exit>

0000000000000138 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e422                	sd	s0,8(sp)
 13c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13e:	87aa                	mv	a5,a0
 140:	0585                	addi	a1,a1,1
 142:	0785                	addi	a5,a5,1
 144:	fff5c703          	lbu	a4,-1(a1)
 148:	fee78fa3          	sb	a4,-1(a5)
 14c:	fb75                	bnez	a4,140 <strcpy+0x8>
    ;
  return os;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cb91                	beqz	a5,172 <strcmp+0x1e>
 160:	0005c703          	lbu	a4,0(a1)
 164:	00f71763          	bne	a4,a5,172 <strcmp+0x1e>
    p++, q++;
 168:	0505                	addi	a0,a0,1
 16a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	fbe5                	bnez	a5,160 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 172:	0005c503          	lbu	a0,0(a1)
}
 176:	40a7853b          	subw	a0,a5,a0
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strlen>:

uint
strlen(const char *s)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf91                	beqz	a5,1a6 <strlen+0x26>
 18c:	0505                	addi	a0,a0,1
 18e:	87aa                	mv	a5,a0
 190:	4685                	li	a3,1
 192:	9e89                	subw	a3,a3,a0
 194:	00f6853b          	addw	a0,a3,a5
 198:	0785                	addi	a5,a5,1
 19a:	fff7c703          	lbu	a4,-1(a5)
 19e:	fb7d                	bnez	a4,194 <strlen+0x14>
    ;
  return n;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  for(n = 0; s[n]; n++)
 1a6:	4501                	li	a0,0
 1a8:	bfe5                	j	1a0 <strlen+0x20>

00000000000001aa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b0:	ca19                	beqz	a2,1c6 <memset+0x1c>
 1b2:	87aa                	mv	a5,a0
 1b4:	1602                	slli	a2,a2,0x20
 1b6:	9201                	srli	a2,a2,0x20
 1b8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1bc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c0:	0785                	addi	a5,a5,1
 1c2:	fee79de3          	bne	a5,a4,1bc <memset+0x12>
  }
  return dst;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strchr>:

char*
strchr(const char *s, char c)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb99                	beqz	a5,1ec <strchr+0x20>
    if(*s == c)
 1d8:	00f58763          	beq	a1,a5,1e6 <strchr+0x1a>
  for(; *s; s++)
 1dc:	0505                	addi	a0,a0,1
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	fbfd                	bnez	a5,1d8 <strchr+0xc>
      return (char*)s;
  return 0;
 1e4:	4501                	li	a0,0
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  return 0;
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <strchr+0x1a>

00000000000001f0 <gets>:

char*
gets(char *buf, int max)
{
 1f0:	711d                	addi	sp,sp,-96
 1f2:	ec86                	sd	ra,88(sp)
 1f4:	e8a2                	sd	s0,80(sp)
 1f6:	e4a6                	sd	s1,72(sp)
 1f8:	e0ca                	sd	s2,64(sp)
 1fa:	fc4e                	sd	s3,56(sp)
 1fc:	f852                	sd	s4,48(sp)
 1fe:	f456                	sd	s5,40(sp)
 200:	f05a                	sd	s6,32(sp)
 202:	ec5e                	sd	s7,24(sp)
 204:	1080                	addi	s0,sp,96
 206:	8baa                	mv	s7,a0
 208:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20a:	892a                	mv	s2,a0
 20c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 20e:	4aa9                	li	s5,10
 210:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 212:	89a6                	mv	s3,s1
 214:	2485                	addiw	s1,s1,1
 216:	0344d863          	bge	s1,s4,246 <gets+0x56>
    cc = read(0, &c, 1);
 21a:	4605                	li	a2,1
 21c:	faf40593          	addi	a1,s0,-81
 220:	4501                	li	a0,0
 222:	00000097          	auipc	ra,0x0
 226:	19a080e7          	jalr	410(ra) # 3bc <read>
    if(cc < 1)
 22a:	00a05e63          	blez	a0,246 <gets+0x56>
    buf[i++] = c;
 22e:	faf44783          	lbu	a5,-81(s0)
 232:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 236:	01578763          	beq	a5,s5,244 <gets+0x54>
 23a:	0905                	addi	s2,s2,1
 23c:	fd679be3          	bne	a5,s6,212 <gets+0x22>
  for(i=0; i+1 < max; ){
 240:	89a6                	mv	s3,s1
 242:	a011                	j	246 <gets+0x56>
 244:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 246:	99de                	add	s3,s3,s7
 248:	00098023          	sb	zero,0(s3)
  return buf;
}
 24c:	855e                	mv	a0,s7
 24e:	60e6                	ld	ra,88(sp)
 250:	6446                	ld	s0,80(sp)
 252:	64a6                	ld	s1,72(sp)
 254:	6906                	ld	s2,64(sp)
 256:	79e2                	ld	s3,56(sp)
 258:	7a42                	ld	s4,48(sp)
 25a:	7aa2                	ld	s5,40(sp)
 25c:	7b02                	ld	s6,32(sp)
 25e:	6be2                	ld	s7,24(sp)
 260:	6125                	addi	sp,sp,96
 262:	8082                	ret

0000000000000264 <stat>:

int
stat(const char *n, struct stat *st)
{
 264:	1101                	addi	sp,sp,-32
 266:	ec06                	sd	ra,24(sp)
 268:	e822                	sd	s0,16(sp)
 26a:	e426                	sd	s1,8(sp)
 26c:	e04a                	sd	s2,0(sp)
 26e:	1000                	addi	s0,sp,32
 270:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 272:	4581                	li	a1,0
 274:	00000097          	auipc	ra,0x0
 278:	170080e7          	jalr	368(ra) # 3e4 <open>
  if(fd < 0)
 27c:	02054563          	bltz	a0,2a6 <stat+0x42>
 280:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 282:	85ca                	mv	a1,s2
 284:	00000097          	auipc	ra,0x0
 288:	178080e7          	jalr	376(ra) # 3fc <fstat>
 28c:	892a                	mv	s2,a0
  close(fd);
 28e:	8526                	mv	a0,s1
 290:	00000097          	auipc	ra,0x0
 294:	13c080e7          	jalr	316(ra) # 3cc <close>
  return r;
}
 298:	854a                	mv	a0,s2
 29a:	60e2                	ld	ra,24(sp)
 29c:	6442                	ld	s0,16(sp)
 29e:	64a2                	ld	s1,8(sp)
 2a0:	6902                	ld	s2,0(sp)
 2a2:	6105                	addi	sp,sp,32
 2a4:	8082                	ret
    return -1;
 2a6:	597d                	li	s2,-1
 2a8:	bfc5                	j	298 <stat+0x34>

00000000000002aa <atoi>:

int
atoi(const char *s)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b0:	00054683          	lbu	a3,0(a0)
 2b4:	fd06879b          	addiw	a5,a3,-48
 2b8:	0ff7f793          	zext.b	a5,a5
 2bc:	4625                	li	a2,9
 2be:	02f66863          	bltu	a2,a5,2ee <atoi+0x44>
 2c2:	872a                	mv	a4,a0
  n = 0;
 2c4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2c6:	0705                	addi	a4,a4,1
 2c8:	0025179b          	slliw	a5,a0,0x2
 2cc:	9fa9                	addw	a5,a5,a0
 2ce:	0017979b          	slliw	a5,a5,0x1
 2d2:	9fb5                	addw	a5,a5,a3
 2d4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d8:	00074683          	lbu	a3,0(a4)
 2dc:	fd06879b          	addiw	a5,a3,-48
 2e0:	0ff7f793          	zext.b	a5,a5
 2e4:	fef671e3          	bgeu	a2,a5,2c6 <atoi+0x1c>
  return n;
}
 2e8:	6422                	ld	s0,8(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret
  n = 0;
 2ee:	4501                	li	a0,0
 2f0:	bfe5                	j	2e8 <atoi+0x3e>

00000000000002f2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2f8:	02b57463          	bgeu	a0,a1,320 <memmove+0x2e>
    while(n-- > 0)
 2fc:	00c05f63          	blez	a2,31a <memmove+0x28>
 300:	1602                	slli	a2,a2,0x20
 302:	9201                	srli	a2,a2,0x20
 304:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 308:	872a                	mv	a4,a0
      *dst++ = *src++;
 30a:	0585                	addi	a1,a1,1
 30c:	0705                	addi	a4,a4,1
 30e:	fff5c683          	lbu	a3,-1(a1)
 312:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 316:	fee79ae3          	bne	a5,a4,30a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
    dst += n;
 320:	00c50733          	add	a4,a0,a2
    src += n;
 324:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 326:	fec05ae3          	blez	a2,31a <memmove+0x28>
 32a:	fff6079b          	addiw	a5,a2,-1
 32e:	1782                	slli	a5,a5,0x20
 330:	9381                	srli	a5,a5,0x20
 332:	fff7c793          	not	a5,a5
 336:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 338:	15fd                	addi	a1,a1,-1
 33a:	177d                	addi	a4,a4,-1
 33c:	0005c683          	lbu	a3,0(a1)
 340:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 344:	fee79ae3          	bne	a5,a4,338 <memmove+0x46>
 348:	bfc9                	j	31a <memmove+0x28>

000000000000034a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 350:	ca05                	beqz	a2,380 <memcmp+0x36>
 352:	fff6069b          	addiw	a3,a2,-1
 356:	1682                	slli	a3,a3,0x20
 358:	9281                	srli	a3,a3,0x20
 35a:	0685                	addi	a3,a3,1
 35c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 35e:	00054783          	lbu	a5,0(a0)
 362:	0005c703          	lbu	a4,0(a1)
 366:	00e79863          	bne	a5,a4,376 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36a:	0505                	addi	a0,a0,1
    p2++;
 36c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 36e:	fed518e3          	bne	a0,a3,35e <memcmp+0x14>
  }
  return 0;
 372:	4501                	li	a0,0
 374:	a019                	j	37a <memcmp+0x30>
      return *p1 - *p2;
 376:	40e7853b          	subw	a0,a5,a4
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
  return 0;
 380:	4501                	li	a0,0
 382:	bfe5                	j	37a <memcmp+0x30>

0000000000000384 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e406                	sd	ra,8(sp)
 388:	e022                	sd	s0,0(sp)
 38a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38c:	00000097          	auipc	ra,0x0
 390:	f66080e7          	jalr	-154(ra) # 2f2 <memmove>
}
 394:	60a2                	ld	ra,8(sp)
 396:	6402                	ld	s0,0(sp)
 398:	0141                	addi	sp,sp,16
 39a:	8082                	ret

000000000000039c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39c:	4885                	li	a7,1
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a4:	4889                	li	a7,2
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ac:	488d                	li	a7,3
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b4:	4891                	li	a7,4
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <read>:
.global read
read:
 li a7, SYS_read
 3bc:	4895                	li	a7,5
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <write>:
.global write
write:
 li a7, SYS_write
 3c4:	48c1                	li	a7,16
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <close>:
.global close
close:
 li a7, SYS_close
 3cc:	48d5                	li	a7,21
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d4:	4899                	li	a7,6
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3dc:	489d                	li	a7,7
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <open>:
.global open
open:
 li a7, SYS_open
 3e4:	48bd                	li	a7,15
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ec:	48c5                	li	a7,17
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f4:	48c9                	li	a7,18
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fc:	48a1                	li	a7,8
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <link>:
.global link
link:
 li a7, SYS_link
 404:	48cd                	li	a7,19
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40c:	48d1                	li	a7,20
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 414:	48a5                	li	a7,9
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <dup>:
.global dup
dup:
 li a7, SYS_dup
 41c:	48a9                	li	a7,10
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 424:	48ad                	li	a7,11
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 42c:	48b1                	li	a7,12
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 434:	48b5                	li	a7,13
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43c:	48b9                	li	a7,14
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <trace>:
.global trace
trace:
 li a7, SYS_trace
 444:	48d9                	li	a7,22
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 44c:	48dd                	li	a7,23
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 454:	48e1                	li	a7,24
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 45c:	48e5                	li	a7,25
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 464:	48e9                	li	a7,26
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 46c:	48ed                	li	a7,27
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 474:	48f1                	li	a7,28
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47c:	1101                	addi	sp,sp,-32
 47e:	ec06                	sd	ra,24(sp)
 480:	e822                	sd	s0,16(sp)
 482:	1000                	addi	s0,sp,32
 484:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 488:	4605                	li	a2,1
 48a:	fef40593          	addi	a1,s0,-17
 48e:	00000097          	auipc	ra,0x0
 492:	f36080e7          	jalr	-202(ra) # 3c4 <write>
}
 496:	60e2                	ld	ra,24(sp)
 498:	6442                	ld	s0,16(sp)
 49a:	6105                	addi	sp,sp,32
 49c:	8082                	ret

000000000000049e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 49e:	7139                	addi	sp,sp,-64
 4a0:	fc06                	sd	ra,56(sp)
 4a2:	f822                	sd	s0,48(sp)
 4a4:	f426                	sd	s1,40(sp)
 4a6:	f04a                	sd	s2,32(sp)
 4a8:	ec4e                	sd	s3,24(sp)
 4aa:	0080                	addi	s0,sp,64
 4ac:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ae:	c299                	beqz	a3,4b4 <printint+0x16>
 4b0:	0805c963          	bltz	a1,542 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b4:	2581                	sext.w	a1,a1
  neg = 0;
 4b6:	4881                	li	a7,0
 4b8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4bc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4be:	2601                	sext.w	a2,a2
 4c0:	00000517          	auipc	a0,0x0
 4c4:	4e850513          	addi	a0,a0,1256 # 9a8 <digits>
 4c8:	883a                	mv	a6,a4
 4ca:	2705                	addiw	a4,a4,1
 4cc:	02c5f7bb          	remuw	a5,a1,a2
 4d0:	1782                	slli	a5,a5,0x20
 4d2:	9381                	srli	a5,a5,0x20
 4d4:	97aa                	add	a5,a5,a0
 4d6:	0007c783          	lbu	a5,0(a5)
 4da:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4de:	0005879b          	sext.w	a5,a1
 4e2:	02c5d5bb          	divuw	a1,a1,a2
 4e6:	0685                	addi	a3,a3,1
 4e8:	fec7f0e3          	bgeu	a5,a2,4c8 <printint+0x2a>
  if(neg)
 4ec:	00088c63          	beqz	a7,504 <printint+0x66>
    buf[i++] = '-';
 4f0:	fd070793          	addi	a5,a4,-48
 4f4:	00878733          	add	a4,a5,s0
 4f8:	02d00793          	li	a5,45
 4fc:	fef70823          	sb	a5,-16(a4)
 500:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 504:	02e05863          	blez	a4,534 <printint+0x96>
 508:	fc040793          	addi	a5,s0,-64
 50c:	00e78933          	add	s2,a5,a4
 510:	fff78993          	addi	s3,a5,-1
 514:	99ba                	add	s3,s3,a4
 516:	377d                	addiw	a4,a4,-1
 518:	1702                	slli	a4,a4,0x20
 51a:	9301                	srli	a4,a4,0x20
 51c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 520:	fff94583          	lbu	a1,-1(s2)
 524:	8526                	mv	a0,s1
 526:	00000097          	auipc	ra,0x0
 52a:	f56080e7          	jalr	-170(ra) # 47c <putc>
  while(--i >= 0)
 52e:	197d                	addi	s2,s2,-1
 530:	ff3918e3          	bne	s2,s3,520 <printint+0x82>
}
 534:	70e2                	ld	ra,56(sp)
 536:	7442                	ld	s0,48(sp)
 538:	74a2                	ld	s1,40(sp)
 53a:	7902                	ld	s2,32(sp)
 53c:	69e2                	ld	s3,24(sp)
 53e:	6121                	addi	sp,sp,64
 540:	8082                	ret
    x = -xx;
 542:	40b005bb          	negw	a1,a1
    neg = 1;
 546:	4885                	li	a7,1
    x = -xx;
 548:	bf85                	j	4b8 <printint+0x1a>

000000000000054a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54a:	7119                	addi	sp,sp,-128
 54c:	fc86                	sd	ra,120(sp)
 54e:	f8a2                	sd	s0,112(sp)
 550:	f4a6                	sd	s1,104(sp)
 552:	f0ca                	sd	s2,96(sp)
 554:	ecce                	sd	s3,88(sp)
 556:	e8d2                	sd	s4,80(sp)
 558:	e4d6                	sd	s5,72(sp)
 55a:	e0da                	sd	s6,64(sp)
 55c:	fc5e                	sd	s7,56(sp)
 55e:	f862                	sd	s8,48(sp)
 560:	f466                	sd	s9,40(sp)
 562:	f06a                	sd	s10,32(sp)
 564:	ec6e                	sd	s11,24(sp)
 566:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 568:	0005c903          	lbu	s2,0(a1)
 56c:	18090f63          	beqz	s2,70a <vprintf+0x1c0>
 570:	8aaa                	mv	s5,a0
 572:	8b32                	mv	s6,a2
 574:	00158493          	addi	s1,a1,1
  state = 0;
 578:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 57a:	02500a13          	li	s4,37
 57e:	4c55                	li	s8,21
 580:	00000c97          	auipc	s9,0x0
 584:	3d0c8c93          	addi	s9,s9,976 # 950 <malloc+0x142>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 588:	02800d93          	li	s11,40
  putc(fd, 'x');
 58c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58e:	00000b97          	auipc	s7,0x0
 592:	41ab8b93          	addi	s7,s7,1050 # 9a8 <digits>
 596:	a839                	j	5b4 <vprintf+0x6a>
        putc(fd, c);
 598:	85ca                	mv	a1,s2
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	ee0080e7          	jalr	-288(ra) # 47c <putc>
 5a4:	a019                	j	5aa <vprintf+0x60>
    } else if(state == '%'){
 5a6:	01498d63          	beq	s3,s4,5c0 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5aa:	0485                	addi	s1,s1,1
 5ac:	fff4c903          	lbu	s2,-1(s1)
 5b0:	14090d63          	beqz	s2,70a <vprintf+0x1c0>
    if(state == 0){
 5b4:	fe0999e3          	bnez	s3,5a6 <vprintf+0x5c>
      if(c == '%'){
 5b8:	ff4910e3          	bne	s2,s4,598 <vprintf+0x4e>
        state = '%';
 5bc:	89d2                	mv	s3,s4
 5be:	b7f5                	j	5aa <vprintf+0x60>
      if(c == 'd'){
 5c0:	11490c63          	beq	s2,s4,6d8 <vprintf+0x18e>
 5c4:	f9d9079b          	addiw	a5,s2,-99
 5c8:	0ff7f793          	zext.b	a5,a5
 5cc:	10fc6e63          	bltu	s8,a5,6e8 <vprintf+0x19e>
 5d0:	f9d9079b          	addiw	a5,s2,-99
 5d4:	0ff7f713          	zext.b	a4,a5
 5d8:	10ec6863          	bltu	s8,a4,6e8 <vprintf+0x19e>
 5dc:	00271793          	slli	a5,a4,0x2
 5e0:	97e6                	add	a5,a5,s9
 5e2:	439c                	lw	a5,0(a5)
 5e4:	97e6                	add	a5,a5,s9
 5e6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5e8:	008b0913          	addi	s2,s6,8
 5ec:	4685                	li	a3,1
 5ee:	4629                	li	a2,10
 5f0:	000b2583          	lw	a1,0(s6)
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	ea8080e7          	jalr	-344(ra) # 49e <printint>
 5fe:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 600:	4981                	li	s3,0
 602:	b765                	j	5aa <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 604:	008b0913          	addi	s2,s6,8
 608:	4681                	li	a3,0
 60a:	4629                	li	a2,10
 60c:	000b2583          	lw	a1,0(s6)
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	e8c080e7          	jalr	-372(ra) # 49e <printint>
 61a:	8b4a                	mv	s6,s2
      state = 0;
 61c:	4981                	li	s3,0
 61e:	b771                	j	5aa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 620:	008b0913          	addi	s2,s6,8
 624:	4681                	li	a3,0
 626:	866a                	mv	a2,s10
 628:	000b2583          	lw	a1,0(s6)
 62c:	8556                	mv	a0,s5
 62e:	00000097          	auipc	ra,0x0
 632:	e70080e7          	jalr	-400(ra) # 49e <printint>
 636:	8b4a                	mv	s6,s2
      state = 0;
 638:	4981                	li	s3,0
 63a:	bf85                	j	5aa <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 63c:	008b0793          	addi	a5,s6,8
 640:	f8f43423          	sd	a5,-120(s0)
 644:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 648:	03000593          	li	a1,48
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	e2e080e7          	jalr	-466(ra) # 47c <putc>
  putc(fd, 'x');
 656:	07800593          	li	a1,120
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	e20080e7          	jalr	-480(ra) # 47c <putc>
 664:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 666:	03c9d793          	srli	a5,s3,0x3c
 66a:	97de                	add	a5,a5,s7
 66c:	0007c583          	lbu	a1,0(a5)
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e0a080e7          	jalr	-502(ra) # 47c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 67a:	0992                	slli	s3,s3,0x4
 67c:	397d                	addiw	s2,s2,-1
 67e:	fe0914e3          	bnez	s2,666 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 682:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 686:	4981                	li	s3,0
 688:	b70d                	j	5aa <vprintf+0x60>
        s = va_arg(ap, char*);
 68a:	008b0913          	addi	s2,s6,8
 68e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 692:	02098163          	beqz	s3,6b4 <vprintf+0x16a>
        while(*s != 0){
 696:	0009c583          	lbu	a1,0(s3)
 69a:	c5ad                	beqz	a1,704 <vprintf+0x1ba>
          putc(fd, *s);
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	dde080e7          	jalr	-546(ra) # 47c <putc>
          s++;
 6a6:	0985                	addi	s3,s3,1
        while(*s != 0){
 6a8:	0009c583          	lbu	a1,0(s3)
 6ac:	f9e5                	bnez	a1,69c <vprintf+0x152>
        s = va_arg(ap, char*);
 6ae:	8b4a                	mv	s6,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bde5                	j	5aa <vprintf+0x60>
          s = "(null)";
 6b4:	00000997          	auipc	s3,0x0
 6b8:	29498993          	addi	s3,s3,660 # 948 <malloc+0x13a>
        while(*s != 0){
 6bc:	85ee                	mv	a1,s11
 6be:	bff9                	j	69c <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6c0:	008b0913          	addi	s2,s6,8
 6c4:	000b4583          	lbu	a1,0(s6)
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	db2080e7          	jalr	-590(ra) # 47c <putc>
 6d2:	8b4a                	mv	s6,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	bdd1                	j	5aa <vprintf+0x60>
        putc(fd, c);
 6d8:	85d2                	mv	a1,s4
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	da0080e7          	jalr	-608(ra) # 47c <putc>
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b5d1                	j	5aa <vprintf+0x60>
        putc(fd, '%');
 6e8:	85d2                	mv	a1,s4
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	d90080e7          	jalr	-624(ra) # 47c <putc>
        putc(fd, c);
 6f4:	85ca                	mv	a1,s2
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	d84080e7          	jalr	-636(ra) # 47c <putc>
      state = 0;
 700:	4981                	li	s3,0
 702:	b565                	j	5aa <vprintf+0x60>
        s = va_arg(ap, char*);
 704:	8b4a                	mv	s6,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	b54d                	j	5aa <vprintf+0x60>
    }
  }
}
 70a:	70e6                	ld	ra,120(sp)
 70c:	7446                	ld	s0,112(sp)
 70e:	74a6                	ld	s1,104(sp)
 710:	7906                	ld	s2,96(sp)
 712:	69e6                	ld	s3,88(sp)
 714:	6a46                	ld	s4,80(sp)
 716:	6aa6                	ld	s5,72(sp)
 718:	6b06                	ld	s6,64(sp)
 71a:	7be2                	ld	s7,56(sp)
 71c:	7c42                	ld	s8,48(sp)
 71e:	7ca2                	ld	s9,40(sp)
 720:	7d02                	ld	s10,32(sp)
 722:	6de2                	ld	s11,24(sp)
 724:	6109                	addi	sp,sp,128
 726:	8082                	ret

0000000000000728 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 728:	715d                	addi	sp,sp,-80
 72a:	ec06                	sd	ra,24(sp)
 72c:	e822                	sd	s0,16(sp)
 72e:	1000                	addi	s0,sp,32
 730:	e010                	sd	a2,0(s0)
 732:	e414                	sd	a3,8(s0)
 734:	e818                	sd	a4,16(s0)
 736:	ec1c                	sd	a5,24(s0)
 738:	03043023          	sd	a6,32(s0)
 73c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 740:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 744:	8622                	mv	a2,s0
 746:	00000097          	auipc	ra,0x0
 74a:	e04080e7          	jalr	-508(ra) # 54a <vprintf>
}
 74e:	60e2                	ld	ra,24(sp)
 750:	6442                	ld	s0,16(sp)
 752:	6161                	addi	sp,sp,80
 754:	8082                	ret

0000000000000756 <printf>:

void
printf(const char *fmt, ...)
{
 756:	711d                	addi	sp,sp,-96
 758:	ec06                	sd	ra,24(sp)
 75a:	e822                	sd	s0,16(sp)
 75c:	1000                	addi	s0,sp,32
 75e:	e40c                	sd	a1,8(s0)
 760:	e810                	sd	a2,16(s0)
 762:	ec14                	sd	a3,24(s0)
 764:	f018                	sd	a4,32(s0)
 766:	f41c                	sd	a5,40(s0)
 768:	03043823          	sd	a6,48(s0)
 76c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 770:	00840613          	addi	a2,s0,8
 774:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 778:	85aa                	mv	a1,a0
 77a:	4505                	li	a0,1
 77c:	00000097          	auipc	ra,0x0
 780:	dce080e7          	jalr	-562(ra) # 54a <vprintf>
}
 784:	60e2                	ld	ra,24(sp)
 786:	6442                	ld	s0,16(sp)
 788:	6125                	addi	sp,sp,96
 78a:	8082                	ret

000000000000078c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78c:	1141                	addi	sp,sp,-16
 78e:	e422                	sd	s0,8(sp)
 790:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 792:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 796:	00001797          	auipc	a5,0x1
 79a:	86a7b783          	ld	a5,-1942(a5) # 1000 <freep>
 79e:	a02d                	j	7c8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a0:	4618                	lw	a4,8(a2)
 7a2:	9f2d                	addw	a4,a4,a1
 7a4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a8:	6398                	ld	a4,0(a5)
 7aa:	6310                	ld	a2,0(a4)
 7ac:	a83d                	j	7ea <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ae:	ff852703          	lw	a4,-8(a0)
 7b2:	9f31                	addw	a4,a4,a2
 7b4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b6:	ff053683          	ld	a3,-16(a0)
 7ba:	a091                	j	7fe <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7bc:	6398                	ld	a4,0(a5)
 7be:	00e7e463          	bltu	a5,a4,7c6 <free+0x3a>
 7c2:	00e6ea63          	bltu	a3,a4,7d6 <free+0x4a>
{
 7c6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c8:	fed7fae3          	bgeu	a5,a3,7bc <free+0x30>
 7cc:	6398                	ld	a4,0(a5)
 7ce:	00e6e463          	bltu	a3,a4,7d6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d2:	fee7eae3          	bltu	a5,a4,7c6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7d6:	ff852583          	lw	a1,-8(a0)
 7da:	6390                	ld	a2,0(a5)
 7dc:	02059813          	slli	a6,a1,0x20
 7e0:	01c85713          	srli	a4,a6,0x1c
 7e4:	9736                	add	a4,a4,a3
 7e6:	fae60de3          	beq	a2,a4,7a0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7ea:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ee:	4790                	lw	a2,8(a5)
 7f0:	02061593          	slli	a1,a2,0x20
 7f4:	01c5d713          	srli	a4,a1,0x1c
 7f8:	973e                	add	a4,a4,a5
 7fa:	fae68ae3          	beq	a3,a4,7ae <free+0x22>
    p->s.ptr = bp->s.ptr;
 7fe:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 800:	00001717          	auipc	a4,0x1
 804:	80f73023          	sd	a5,-2048(a4) # 1000 <freep>
}
 808:	6422                	ld	s0,8(sp)
 80a:	0141                	addi	sp,sp,16
 80c:	8082                	ret

000000000000080e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 80e:	7139                	addi	sp,sp,-64
 810:	fc06                	sd	ra,56(sp)
 812:	f822                	sd	s0,48(sp)
 814:	f426                	sd	s1,40(sp)
 816:	f04a                	sd	s2,32(sp)
 818:	ec4e                	sd	s3,24(sp)
 81a:	e852                	sd	s4,16(sp)
 81c:	e456                	sd	s5,8(sp)
 81e:	e05a                	sd	s6,0(sp)
 820:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 822:	02051493          	slli	s1,a0,0x20
 826:	9081                	srli	s1,s1,0x20
 828:	04bd                	addi	s1,s1,15
 82a:	8091                	srli	s1,s1,0x4
 82c:	0014899b          	addiw	s3,s1,1
 830:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 832:	00000517          	auipc	a0,0x0
 836:	7ce53503          	ld	a0,1998(a0) # 1000 <freep>
 83a:	c515                	beqz	a0,866 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83e:	4798                	lw	a4,8(a5)
 840:	02977f63          	bgeu	a4,s1,87e <malloc+0x70>
 844:	8a4e                	mv	s4,s3
 846:	0009871b          	sext.w	a4,s3
 84a:	6685                	lui	a3,0x1
 84c:	00d77363          	bgeu	a4,a3,852 <malloc+0x44>
 850:	6a05                	lui	s4,0x1
 852:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 856:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85a:	00000917          	auipc	s2,0x0
 85e:	7a690913          	addi	s2,s2,1958 # 1000 <freep>
  if(p == (char*)-1)
 862:	5afd                	li	s5,-1
 864:	a895                	j	8d8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 866:	00001797          	auipc	a5,0x1
 86a:	9aa78793          	addi	a5,a5,-1622 # 1210 <base>
 86e:	00000717          	auipc	a4,0x0
 872:	78f73923          	sd	a5,1938(a4) # 1000 <freep>
 876:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 878:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87c:	b7e1                	j	844 <malloc+0x36>
      if(p->s.size == nunits)
 87e:	02e48c63          	beq	s1,a4,8b6 <malloc+0xa8>
        p->s.size -= nunits;
 882:	4137073b          	subw	a4,a4,s3
 886:	c798                	sw	a4,8(a5)
        p += p->s.size;
 888:	02071693          	slli	a3,a4,0x20
 88c:	01c6d713          	srli	a4,a3,0x1c
 890:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 892:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 896:	00000717          	auipc	a4,0x0
 89a:	76a73523          	sd	a0,1898(a4) # 1000 <freep>
      return (void*)(p + 1);
 89e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a2:	70e2                	ld	ra,56(sp)
 8a4:	7442                	ld	s0,48(sp)
 8a6:	74a2                	ld	s1,40(sp)
 8a8:	7902                	ld	s2,32(sp)
 8aa:	69e2                	ld	s3,24(sp)
 8ac:	6a42                	ld	s4,16(sp)
 8ae:	6aa2                	ld	s5,8(sp)
 8b0:	6b02                	ld	s6,0(sp)
 8b2:	6121                	addi	sp,sp,64
 8b4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b6:	6398                	ld	a4,0(a5)
 8b8:	e118                	sd	a4,0(a0)
 8ba:	bff1                	j	896 <malloc+0x88>
  hp->s.size = nu;
 8bc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c0:	0541                	addi	a0,a0,16
 8c2:	00000097          	auipc	ra,0x0
 8c6:	eca080e7          	jalr	-310(ra) # 78c <free>
  return freep;
 8ca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ce:	d971                	beqz	a0,8a2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	fa9775e3          	bgeu	a4,s1,87e <malloc+0x70>
    if(p == freep)
 8d8:	00093703          	ld	a4,0(s2)
 8dc:	853e                	mv	a0,a5
 8de:	fef719e3          	bne	a4,a5,8d0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8e2:	8552                	mv	a0,s4
 8e4:	00000097          	auipc	ra,0x0
 8e8:	b48080e7          	jalr	-1208(ra) # 42c <sbrk>
  if(p == (char*)-1)
 8ec:	fd5518e3          	bne	a0,s5,8bc <malloc+0xae>
        return 0;
 8f0:	4501                	li	a0,0
 8f2:	bf45                	j	8a2 <malloc+0x94>
