
obj/user/primes:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 13 01 00 00       	call   800144 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 13 13 00 00       	call   80136b <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("%d ", p);
  80005a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005e:	c7 04 24 00 17 80 00 	movl   $0x801700,(%esp)
  800065:	e8 07 02 00 00       	call   800271 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  80006a:	e8 16 10 00 00       	call   801085 <fork>
  80006f:	89 c7                	mov    %eax,%edi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 20                	jns    800095 <primeproc+0x61>
		panic("fork: %e", id);
  800075:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800079:	c7 44 24 08 cc 19 80 	movl   $0x8019cc,0x8(%esp)
  800080:	00 
  800081:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800088:	00 
  800089:	c7 04 24 04 17 80 00 	movl   $0x801704,(%esp)
  800090:	e8 17 01 00 00       	call   8001ac <_panic>
	if (id == 0)
  800095:	85 c0                	test   %eax,%eax
  800097:	74 a7                	je     800040 <primeproc+0xc>
		goto top;
	
	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800099:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80009c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ab:	00 
  8000ac:	89 34 24             	mov    %esi,(%esp)
  8000af:	e8 b7 12 00 00       	call   80136b <ipc_recv>
  8000b4:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000b6:	89 c2                	mov    %eax,%edx
  8000b8:	c1 fa 1f             	sar    $0x1f,%edx
  8000bb:	f7 fb                	idiv   %ebx
  8000bd:	85 d2                	test   %edx,%edx
  8000bf:	74 db                	je     80009c <primeproc+0x68>
			ipc_send(id, i, 0, 0);
  8000c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000c8:	00 
  8000c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d0:	00 
  8000d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000d5:	89 3c 24             	mov    %edi,(%esp)
  8000d8:	e8 23 12 00 00       	call   801300 <ipc_send>
  8000dd:	eb bd                	jmp    80009c <primeproc+0x68>

008000df <umain>:
	}
}

void
umain(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000e7:	e8 99 0f 00 00       	call   801085 <fork>
  8000ec:	89 c6                	mov    %eax,%esi
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <umain+0x33>
		panic("fork: %e", id);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 cc 19 80 	movl   $0x8019cc,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 04 17 80 00 	movl   $0x801704,(%esp)
  80010d:	e8 9a 00 00 00       	call   8001ac <_panic>
	if (id == 0)
  800112:	bb 02 00 00 00       	mov    $0x2,%ebx
  800117:	85 c0                	test   %eax,%eax
  800119:	75 05                	jne    800120 <umain+0x41>
		primeproc();
  80011b:	e8 14 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800120:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800127:	00 
  800128:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80012f:	00 
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 c4 11 00 00       	call   801300 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  80013c:	83 c3 01             	add    $0x1,%ebx
  80013f:	eb df                	jmp    800120 <umain+0x41>
  800141:	00 00                	add    %al,(%eax)
	...

00800144 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 18             	sub    $0x18,%esp
  80014a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80014d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  800156:	e8 ed 0b 00 00       	call   800d48 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	89 c2                	mov    %eax,%edx
  800162:	c1 e2 07             	shl    $0x7,%edx
  800165:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80016c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800171:	85 f6                	test   %esi,%esi
  800173:	7e 07                	jle    80017c <libmain+0x38>
		binaryname = argv[0];
  800175:	8b 03                	mov    (%ebx),%eax
  800177:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80017c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800180:	89 34 24             	mov    %esi,(%esp)
  800183:	e8 57 ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  800188:	e8 0b 00 00 00       	call   800198 <exit>
}
  80018d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800190:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800193:	89 ec                	mov    %ebp,%esp
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    
	...

00800198 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80019e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a5:	e8 69 0b 00 00       	call   800d13 <sys_env_destroy>
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8001b2:	a1 08 20 80 00       	mov    0x802008,%eax
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	74 10                	je     8001cb <_panic+0x1f>
		cprintf("%s: ", argv0);
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 29 17 80 00 	movl   $0x801729,(%esp)
  8001c6:	e8 a6 00 00 00       	call   800271 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	a1 00 20 80 00       	mov    0x802000,%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	c7 04 24 2e 17 80 00 	movl   $0x80172e,(%esp)
  8001e9:	e8 83 00 00 00       	call   800271 <cprintf>
	vcprintf(fmt, ap);
  8001ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 10 00 00 00       	call   800210 <vcprintf>
	cprintf("\n");
  800200:	c7 04 24 4a 17 80 00 	movl   $0x80174a,(%esp)
  800207:	e8 65 00 00 00       	call   800271 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020c:	cc                   	int3   
  80020d:	eb fd                	jmp    80020c <_panic+0x60>
	...

00800210 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800219:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800220:	00 00 00 
	b.cnt = 0;
  800223:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800230:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800241:	89 44 24 04          	mov    %eax,0x4(%esp)
  800245:	c7 04 24 8b 02 80 00 	movl   $0x80028b,(%esp)
  80024c:	e8 cf 01 00 00       	call   800420 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800251:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 43 0a 00 00       	call   800cac <sys_cputs>

	return b.cnt;
}
  800269:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800277:	8d 45 0c             	lea    0xc(%ebp),%eax
  80027a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 04 24             	mov    %eax,(%esp)
  800284:	e8 87 ff ff ff       	call   800210 <vcprintf>
	va_end(ap);

	return cnt;
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	53                   	push   %ebx
  80028f:	83 ec 14             	sub    $0x14,%esp
  800292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800295:	8b 03                	mov    (%ebx),%eax
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029e:	83 c0 01             	add    $0x1,%eax
  8002a1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a8:	75 19                	jne    8002c3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002aa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002b1:	00 
  8002b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	e8 ef 09 00 00       	call   800cac <sys_cputs>
		b->idx = 0;
  8002bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	83 c4 14             	add    $0x14,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    
  8002cd:	00 00                	add    %al,(%eax)
	...

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 4c             	sub    $0x4c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d6                	mov    %edx,%esi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fb:	39 d1                	cmp    %edx,%ecx
  8002fd:	72 15                	jb     800314 <printnum+0x44>
  8002ff:	77 07                	ja     800308 <printnum+0x38>
  800301:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800304:	39 d0                	cmp    %edx,%eax
  800306:	76 0c                	jbe    800314 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800308:	83 eb 01             	sub    $0x1,%ebx
  80030b:	85 db                	test   %ebx,%ebx
  80030d:	8d 76 00             	lea    0x0(%esi),%esi
  800310:	7f 61                	jg     800373 <printnum+0xa3>
  800312:	eb 70                	jmp    800384 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800327:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80032b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80032e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800331:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800334:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800338:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033f:	00 
  800340:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800349:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034d:	e8 3e 11 00 00       	call   801490 <__udivdi3>
  800352:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800355:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	89 54 24 04          	mov    %edx,0x4(%esp)
  800367:	89 f2                	mov    %esi,%edx
  800369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036c:	e8 5f ff ff ff       	call   8002d0 <printnum>
  800371:	eb 11                	jmp    800384 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800373:	89 74 24 04          	mov    %esi,0x4(%esp)
  800377:	89 3c 24             	mov    %edi,(%esp)
  80037a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f ef                	jg     800373 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	89 74 24 04          	mov    %esi,0x4(%esp)
  800388:	8b 74 24 04          	mov    0x4(%esp),%esi
  80038c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039a:	00 
  80039b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80039e:	89 14 24             	mov    %edx,(%esp)
  8003a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003a8:	e8 13 12 00 00       	call   8015c0 <__umoddi3>
  8003ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b1:	0f be 80 4c 17 80 00 	movsbl 0x80174c(%eax),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003be:	83 c4 4c             	add    $0x4c,%esp
  8003c1:	5b                   	pop    %ebx
  8003c2:	5e                   	pop    %esi
  8003c3:	5f                   	pop    %edi
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c9:	83 fa 01             	cmp    $0x1,%edx
  8003cc:	7e 0f                	jle    8003dd <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	83 c2 08             	add    $0x8,%edx
  8003d3:	89 10                	mov    %edx,(%eax)
  8003d5:	8b 42 f8             	mov    -0x8(%edx),%eax
  8003d8:	8b 52 fc             	mov    -0x4(%edx),%edx
  8003db:	eb 24                	jmp    800401 <getuint+0x3b>
	else if (lflag)
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	74 11                	je     8003f2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003e1:	8b 10                	mov    (%eax),%edx
  8003e3:	83 c2 04             	add    $0x4,%edx
  8003e6:	89 10                	mov    %edx,(%eax)
  8003e8:	8b 42 fc             	mov    -0x4(%edx),%eax
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	eb 0f                	jmp    800401 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	83 c2 04             	add    $0x4,%edx
  8003f7:	89 10                	mov    %edx,(%eax)
  8003f9:	8b 42 fc             	mov    -0x4(%edx),%eax
  8003fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800409:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040d:	8b 10                	mov    (%eax),%edx
  80040f:	3b 50 04             	cmp    0x4(%eax),%edx
  800412:	73 0a                	jae    80041e <sprintputch+0x1b>
		*b->buf++ = ch;
  800414:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800417:	88 0a                	mov    %cl,(%edx)
  800419:	83 c2 01             	add    $0x1,%edx
  80041c:	89 10                	mov    %edx,(%eax)
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
  800426:	83 ec 5c             	sub    $0x5c,%esp
  800429:	8b 7d 08             	mov    0x8(%ebp),%edi
  80042c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80042f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800432:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800439:	eb 11                	jmp    80044c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043b:	85 c0                	test   %eax,%eax
  80043d:	0f 84 fd 03 00 00    	je     800840 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800443:	89 74 24 04          	mov    %esi,0x4(%esp)
  800447:	89 04 24             	mov    %eax,(%esp)
  80044a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044c:	0f b6 03             	movzbl (%ebx),%eax
  80044f:	83 c3 01             	add    $0x1,%ebx
  800452:	83 f8 25             	cmp    $0x25,%eax
  800455:	75 e4                	jne    80043b <vprintfmt+0x1b>
  800457:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800462:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800469:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800470:	b9 00 00 00 00       	mov    $0x0,%ecx
  800475:	eb 06                	jmp    80047d <vprintfmt+0x5d>
  800477:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80047b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	0f b6 13             	movzbl (%ebx),%edx
  800480:	0f b6 c2             	movzbl %dl,%eax
  800483:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800486:	8d 43 01             	lea    0x1(%ebx),%eax
  800489:	83 ea 23             	sub    $0x23,%edx
  80048c:	80 fa 55             	cmp    $0x55,%dl
  80048f:	0f 87 8e 03 00 00    	ja     800823 <vprintfmt+0x403>
  800495:	0f b6 d2             	movzbl %dl,%edx
  800498:	ff 24 95 20 18 80 00 	jmp    *0x801820(,%edx,4)
  80049f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a3:	eb d6                	jmp    80047b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a8:	83 ea 30             	sub    $0x30,%edx
  8004ab:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8004ae:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004b1:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004b4:	83 fb 09             	cmp    $0x9,%ebx
  8004b7:	77 55                	ja     80050e <vprintfmt+0xee>
  8004b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004bc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bf:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004c2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004c5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004c9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004cc:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004cf:	83 fb 09             	cmp    $0x9,%ebx
  8004d2:	76 eb                	jbe    8004bf <vprintfmt+0x9f>
  8004d4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004da:	eb 32                	jmp    80050e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004dc:	8b 55 14             	mov    0x14(%ebp),%edx
  8004df:	83 c2 04             	add    $0x4,%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	8b 52 fc             	mov    -0x4(%edx),%edx
  8004e8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8004eb:	eb 21                	jmp    80050e <vprintfmt+0xee>

		case '.':
			if (width < 0)
  8004ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8004fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004fd:	e9 79 ff ff ff       	jmp    80047b <vprintfmt+0x5b>
  800502:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800509:	e9 6d ff ff ff       	jmp    80047b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80050e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800512:	0f 89 63 ff ff ff    	jns    80047b <vprintfmt+0x5b>
  800518:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80051b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800521:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800524:	e9 52 ff ff ff       	jmp    80047b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800529:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80052c:	e9 4a ff ff ff       	jmp    80047b <vprintfmt+0x5b>
  800531:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	83 c0 04             	add    $0x4,%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800541:	8b 40 fc             	mov    -0x4(%eax),%eax
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff d7                	call   *%edi
  800549:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80054c:	e9 fb fe ff ff       	jmp    80044c <vprintfmt+0x2c>
  800551:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	83 c0 04             	add    $0x4,%eax
  80055a:	89 45 14             	mov    %eax,0x14(%ebp)
  80055d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800560:	89 c2                	mov    %eax,%edx
  800562:	c1 fa 1f             	sar    $0x1f,%edx
  800565:	31 d0                	xor    %edx,%eax
  800567:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800569:	83 f8 08             	cmp    $0x8,%eax
  80056c:	7f 0b                	jg     800579 <vprintfmt+0x159>
  80056e:	8b 14 85 80 19 80 00 	mov    0x801980(,%eax,4),%edx
  800575:	85 d2                	test   %edx,%edx
  800577:	75 20                	jne    800599 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800579:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057d:	c7 44 24 08 5d 17 80 	movl   $0x80175d,0x8(%esp)
  800584:	00 
  800585:	89 74 24 04          	mov    %esi,0x4(%esp)
  800589:	89 3c 24             	mov    %edi,(%esp)
  80058c:	e8 37 03 00 00       	call   8008c8 <printfmt>
  800591:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800594:	e9 b3 fe ff ff       	jmp    80044c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800599:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059d:	c7 44 24 08 66 17 80 	movl   $0x801766,0x8(%esp)
  8005a4:	00 
  8005a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a9:	89 3c 24             	mov    %edi,(%esp)
  8005ac:	e8 17 03 00 00       	call   8008c8 <printfmt>
  8005b1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005b4:	e9 93 fe ff ff       	jmp    80044c <vprintfmt+0x2c>
  8005b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005bc:	89 c3                	mov    %eax,%ebx
  8005be:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	83 c0 04             	add    $0x4,%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d0:	8b 40 fc             	mov    -0x4(%eax),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	b8 69 17 80 00       	mov    $0x801769,%eax
  8005dd:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  8005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005e4:	85 c9                	test   %ecx,%ecx
  8005e6:	7e 06                	jle    8005ee <vprintfmt+0x1ce>
  8005e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ec:	75 13                	jne    800601 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005f1:	0f be 02             	movsbl (%edx),%eax
  8005f4:	85 c0                	test   %eax,%eax
  8005f6:	0f 85 99 00 00 00    	jne    800695 <vprintfmt+0x275>
  8005fc:	e9 86 00 00 00       	jmp    800687 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	89 54 24 04          	mov    %edx,0x4(%esp)
  800605:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800608:	89 0c 24             	mov    %ecx,(%esp)
  80060b:	e8 fb 02 00 00       	call   80090b <strnlen>
  800610:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800613:	29 c2                	sub    %eax,%edx
  800615:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800618:	85 d2                	test   %edx,%edx
  80061a:	7e d2                	jle    8005ee <vprintfmt+0x1ce>
					putch(padc, putdat);
  80061c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800620:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800623:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800626:	89 d3                	mov    %edx,%ebx
  800628:	89 74 24 04          	mov    %esi,0x4(%esp)
  80062c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800634:	83 eb 01             	sub    $0x1,%ebx
  800637:	85 db                	test   %ebx,%ebx
  800639:	7f ed                	jg     800628 <vprintfmt+0x208>
  80063b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80063e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800645:	eb a7                	jmp    8005ee <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800647:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064b:	74 18                	je     800665 <vprintfmt+0x245>
  80064d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800650:	83 fa 5e             	cmp    $0x5e,%edx
  800653:	76 10                	jbe    800665 <vprintfmt+0x245>
					putch('?', putdat);
  800655:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800659:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800660:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800663:	eb 0a                	jmp    80066f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800665:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800669:	89 04 24             	mov    %eax,(%esp)
  80066c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800673:	0f be 03             	movsbl (%ebx),%eax
  800676:	85 c0                	test   %eax,%eax
  800678:	74 05                	je     80067f <vprintfmt+0x25f>
  80067a:	83 c3 01             	add    $0x1,%ebx
  80067d:	eb 29                	jmp    8006a8 <vprintfmt+0x288>
  80067f:	89 fe                	mov    %edi,%esi
  800681:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800684:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800687:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80068b:	7f 2e                	jg     8006bb <vprintfmt+0x29b>
  80068d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800690:	e9 b7 fd ff ff       	jmp    80044c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800695:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800698:	83 c2 01             	add    $0x1,%edx
  80069b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80069e:	89 f7                	mov    %esi,%edi
  8006a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006a6:	89 d3                	mov    %edx,%ebx
  8006a8:	85 f6                	test   %esi,%esi
  8006aa:	78 9b                	js     800647 <vprintfmt+0x227>
  8006ac:	83 ee 01             	sub    $0x1,%esi
  8006af:	79 96                	jns    800647 <vprintfmt+0x227>
  8006b1:	89 fe                	mov    %edi,%esi
  8006b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006b6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b9:	eb cc                	jmp    800687 <vprintfmt+0x267>
  8006bb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006be:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006cc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ce:	83 eb 01             	sub    $0x1,%ebx
  8006d1:	85 db                	test   %ebx,%ebx
  8006d3:	7f ec                	jg     8006c1 <vprintfmt+0x2a1>
  8006d5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006d8:	e9 6f fd ff ff       	jmp    80044c <vprintfmt+0x2c>
  8006dd:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e0:	83 f9 01             	cmp    $0x1,%ecx
  8006e3:	7e 17                	jle    8006fc <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	83 c0 08             	add    $0x8,%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ee:	8b 50 f8             	mov    -0x8(%eax),%edx
  8006f1:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8006f4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fa:	eb 34                	jmp    800730 <vprintfmt+0x310>
	else if (lflag)
  8006fc:	85 c9                	test   %ecx,%ecx
  8006fe:	74 19                	je     800719 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	83 c0 04             	add    $0x4,%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
  800709:	8b 40 fc             	mov    -0x4(%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800717:	eb 17                	jmp    800730 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	83 c0 04             	add    $0x4,%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
  800722:	8b 40 fc             	mov    -0x4(%eax),%eax
  800725:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800728:	89 c2                	mov    %eax,%edx
  80072a:	c1 fa 1f             	sar    $0x1f,%edx
  80072d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800730:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800733:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800736:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80073b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80073f:	0f 89 9c 00 00 00    	jns    8007e1 <vprintfmt+0x3c1>
				putch('-', putdat);
  800745:	89 74 24 04          	mov    %esi,0x4(%esp)
  800749:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800750:	ff d7                	call   *%edi
				num = -(long long) num;
  800752:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800755:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800758:	f7 d9                	neg    %ecx
  80075a:	83 d3 00             	adc    $0x0,%ebx
  80075d:	f7 db                	neg    %ebx
  80075f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800764:	eb 7b                	jmp    8007e1 <vprintfmt+0x3c1>
  800766:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800769:	89 ca                	mov    %ecx,%edx
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	e8 53 fc ff ff       	call   8003c6 <getuint>
  800773:	89 c1                	mov    %eax,%ecx
  800775:	89 d3                	mov    %edx,%ebx
  800777:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80077c:	eb 63                	jmp    8007e1 <vprintfmt+0x3c1>
  80077e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800781:	89 ca                	mov    %ecx,%edx
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	e8 3b fc ff ff       	call   8003c6 <getuint>
  80078b:	89 c1                	mov    %eax,%ecx
  80078d:	89 d3                	mov    %edx,%ebx
  80078f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800794:	eb 4b                	jmp    8007e1 <vprintfmt+0x3c1>
  800796:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800799:	89 74 24 04          	mov    %esi,0x4(%esp)
  80079d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a4:	ff d7                	call   *%edi
			putch('x', putdat);
  8007a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007aa:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007b1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	83 c0 04             	add    $0x4,%eax
  8007b9:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007bc:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8007bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007c4:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c9:	eb 16                	jmp    8007e1 <vprintfmt+0x3c1>
  8007cb:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ce:	89 ca                	mov    %ecx,%edx
  8007d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d3:	e8 ee fb ff ff       	call   8003c6 <getuint>
  8007d8:	89 c1                	mov    %eax,%ecx
  8007da:	89 d3                	mov    %edx,%ebx
  8007dc:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8007e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f4:	89 0c 24             	mov    %ecx,(%esp)
  8007f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fb:	89 f2                	mov    %esi,%edx
  8007fd:	89 f8                	mov    %edi,%eax
  8007ff:	e8 cc fa ff ff       	call   8002d0 <printnum>
  800804:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800807:	e9 40 fc ff ff       	jmp    80044c <vprintfmt+0x2c>
  80080c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80080f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800812:	89 74 24 04          	mov    %esi,0x4(%esp)
  800816:	89 14 24             	mov    %edx,(%esp)
  800819:	ff d7                	call   *%edi
  80081b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80081e:	e9 29 fc ff ff       	jmp    80044c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800823:	89 74 24 04          	mov    %esi,0x4(%esp)
  800827:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80082e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800830:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800833:	80 38 25             	cmpb   $0x25,(%eax)
  800836:	0f 84 10 fc ff ff    	je     80044c <vprintfmt+0x2c>
  80083c:	89 c3                	mov    %eax,%ebx
  80083e:	eb f0                	jmp    800830 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800840:	83 c4 5c             	add    $0x5c,%esp
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5f                   	pop    %edi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 28             	sub    $0x28,%esp
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800854:	85 c0                	test   %eax,%eax
  800856:	74 04                	je     80085c <vsnprintf+0x14>
  800858:	85 d2                	test   %edx,%edx
  80085a:	7f 07                	jg     800863 <vsnprintf+0x1b>
  80085c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800861:	eb 3b                	jmp    80089e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800863:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800866:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80086a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80086d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087b:	8b 45 10             	mov    0x10(%ebp),%eax
  80087e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800882:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800885:	89 44 24 04          	mov    %eax,0x4(%esp)
  800889:	c7 04 24 03 04 80 00 	movl   $0x800403,(%esp)
  800890:	e8 8b fb ff ff       	call   800420 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800895:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800898:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	89 04 24             	mov    %eax,(%esp)
  8008c1:	e8 82 ff ff ff       	call   800848 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 32 fb ff ff       	call   800420 <vprintfmt>
	va_end(ap);
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008fe:	74 09                	je     800909 <strlen+0x19>
		n++;
  800900:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800903:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800907:	75 f7                	jne    800900 <strlen+0x10>
		n++;
	return n;
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
  80090f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800912:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800915:	85 c9                	test   %ecx,%ecx
  800917:	74 19                	je     800932 <strnlen+0x27>
  800919:	80 3b 00             	cmpb   $0x0,(%ebx)
  80091c:	74 14                	je     800932 <strnlen+0x27>
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800923:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800926:	39 c8                	cmp    %ecx,%eax
  800928:	74 0d                	je     800937 <strnlen+0x2c>
  80092a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80092e:	75 f3                	jne    800923 <strnlen+0x18>
  800930:	eb 05                	jmp    800937 <strnlen+0x2c>
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800944:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800949:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80094d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800950:	83 c2 01             	add    $0x1,%edx
  800953:	84 c9                	test   %cl,%cl
  800955:	75 f2                	jne    800949 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800957:	5b                   	pop    %ebx
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
  800965:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800968:	85 f6                	test   %esi,%esi
  80096a:	74 18                	je     800984 <strncpy+0x2a>
  80096c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800971:	0f b6 1a             	movzbl (%edx),%ebx
  800974:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800977:	80 3a 01             	cmpb   $0x1,(%edx)
  80097a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097d:	83 c1 01             	add    $0x1,%ecx
  800980:	39 ce                	cmp    %ecx,%esi
  800982:	77 ed                	ja     800971 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 75 08             	mov    0x8(%ebp),%esi
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800996:	89 f0                	mov    %esi,%eax
  800998:	85 c9                	test   %ecx,%ecx
  80099a:	74 27                	je     8009c3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80099c:	83 e9 01             	sub    $0x1,%ecx
  80099f:	74 1d                	je     8009be <strlcpy+0x36>
  8009a1:	0f b6 1a             	movzbl (%edx),%ebx
  8009a4:	84 db                	test   %bl,%bl
  8009a6:	74 16                	je     8009be <strlcpy+0x36>
			*dst++ = *src++;
  8009a8:	88 18                	mov    %bl,(%eax)
  8009aa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ad:	83 e9 01             	sub    $0x1,%ecx
  8009b0:	74 0e                	je     8009c0 <strlcpy+0x38>
			*dst++ = *src++;
  8009b2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b5:	0f b6 1a             	movzbl (%edx),%ebx
  8009b8:	84 db                	test   %bl,%bl
  8009ba:	75 ec                	jne    8009a8 <strlcpy+0x20>
  8009bc:	eb 02                	jmp    8009c0 <strlcpy+0x38>
  8009be:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009c0:	c6 00 00             	movb   $0x0,(%eax)
  8009c3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d2:	0f b6 01             	movzbl (%ecx),%eax
  8009d5:	84 c0                	test   %al,%al
  8009d7:	74 15                	je     8009ee <strcmp+0x25>
  8009d9:	3a 02                	cmp    (%edx),%al
  8009db:	75 11                	jne    8009ee <strcmp+0x25>
		p++, q++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e3:	0f b6 01             	movzbl (%ecx),%eax
  8009e6:	84 c0                	test   %al,%al
  8009e8:	74 04                	je     8009ee <strcmp+0x25>
  8009ea:	3a 02                	cmp    (%edx),%al
  8009ec:	74 ef                	je     8009dd <strcmp+0x14>
  8009ee:	0f b6 c0             	movzbl %al,%eax
  8009f1:	0f b6 12             	movzbl (%edx),%edx
  8009f4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	53                   	push   %ebx
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a02:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a05:	85 c0                	test   %eax,%eax
  800a07:	74 23                	je     800a2c <strncmp+0x34>
  800a09:	0f b6 1a             	movzbl (%edx),%ebx
  800a0c:	84 db                	test   %bl,%bl
  800a0e:	74 24                	je     800a34 <strncmp+0x3c>
  800a10:	3a 19                	cmp    (%ecx),%bl
  800a12:	75 20                	jne    800a34 <strncmp+0x3c>
  800a14:	83 e8 01             	sub    $0x1,%eax
  800a17:	74 13                	je     800a2c <strncmp+0x34>
		n--, p++, q++;
  800a19:	83 c2 01             	add    $0x1,%edx
  800a1c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a1f:	0f b6 1a             	movzbl (%edx),%ebx
  800a22:	84 db                	test   %bl,%bl
  800a24:	74 0e                	je     800a34 <strncmp+0x3c>
  800a26:	3a 19                	cmp    (%ecx),%bl
  800a28:	74 ea                	je     800a14 <strncmp+0x1c>
  800a2a:	eb 08                	jmp    800a34 <strncmp+0x3c>
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a31:	5b                   	pop    %ebx
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a34:	0f b6 02             	movzbl (%edx),%eax
  800a37:	0f b6 11             	movzbl (%ecx),%edx
  800a3a:	29 d0                	sub    %edx,%eax
  800a3c:	eb f3                	jmp    800a31 <strncmp+0x39>

00800a3e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a48:	0f b6 10             	movzbl (%eax),%edx
  800a4b:	84 d2                	test   %dl,%dl
  800a4d:	74 15                	je     800a64 <strchr+0x26>
		if (*s == c)
  800a4f:	38 ca                	cmp    %cl,%dl
  800a51:	75 07                	jne    800a5a <strchr+0x1c>
  800a53:	eb 14                	jmp    800a69 <strchr+0x2b>
  800a55:	38 ca                	cmp    %cl,%dl
  800a57:	90                   	nop
  800a58:	74 0f                	je     800a69 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 f1                	jne    800a55 <strchr+0x17>
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	74 18                	je     800a94 <strfind+0x29>
		if (*s == c)
  800a7c:	38 ca                	cmp    %cl,%dl
  800a7e:	75 0a                	jne    800a8a <strfind+0x1f>
  800a80:	eb 12                	jmp    800a94 <strfind+0x29>
  800a82:	38 ca                	cmp    %cl,%dl
  800a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a88:	74 0a                	je     800a94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 ee                	jne    800a82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	53                   	push   %ebx
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800aa3:	89 da                	mov    %ebx,%edx
  800aa5:	83 ea 01             	sub    $0x1,%edx
  800aa8:	78 0d                	js     800ab7 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  800aaa:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800aac:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  800aae:	88 0a                	mov    %cl,(%edx)
  800ab0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800ab3:	39 da                	cmp    %ebx,%edx
  800ab5:	75 f7                	jne    800aae <memset+0x18>
		*p++ = c;

	return v;
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	74 13                	je     800adf <memcpy+0x25>
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800ad1:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ad5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ad8:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800adb:	39 da                	cmp    %ebx,%edx
  800add:	75 f2                	jne    800ad1 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800af2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800af4:	39 c6                	cmp    %eax,%esi
  800af6:	72 0b                	jb     800b03 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800afd:	85 db                	test   %ebx,%ebx
  800aff:	75 2e                	jne    800b2f <memmove+0x4c>
  800b01:	eb 3a                	jmp    800b3d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b03:	01 df                	add    %ebx,%edi
  800b05:	39 f8                	cmp    %edi,%eax
  800b07:	73 ef                	jae    800af8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	90                   	nop
  800b0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b10:	74 2b                	je     800b3d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800b12:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800b1a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800b1f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800b23:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800b26:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800b29:	85 c9                	test   %ecx,%ecx
  800b2b:	75 ed                	jne    800b1a <memmove+0x37>
  800b2d:	eb 0e                	jmp    800b3d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800b2f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b33:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b36:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800b39:	39 d3                	cmp    %edx,%ebx
  800b3b:	75 f2                	jne    800b2f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	8b 75 08             	mov    0x8(%ebp),%esi
  800b4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b51:	85 c9                	test   %ecx,%ecx
  800b53:	74 36                	je     800b8b <memcmp+0x49>
		if (*s1 != *s2)
  800b55:	0f b6 06             	movzbl (%esi),%eax
  800b58:	0f b6 1f             	movzbl (%edi),%ebx
  800b5b:	38 d8                	cmp    %bl,%al
  800b5d:	74 20                	je     800b7f <memcmp+0x3d>
  800b5f:	eb 14                	jmp    800b75 <memcmp+0x33>
  800b61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b6b:	83 c2 01             	add    $0x1,%edx
  800b6e:	83 e9 01             	sub    $0x1,%ecx
  800b71:	38 d8                	cmp    %bl,%al
  800b73:	74 12                	je     800b87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b75:	0f b6 c0             	movzbl %al,%eax
  800b78:	0f b6 db             	movzbl %bl,%ebx
  800b7b:	29 d8                	sub    %ebx,%eax
  800b7d:	eb 11                	jmp    800b90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7f:	83 e9 01             	sub    $0x1,%ecx
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	85 c9                	test   %ecx,%ecx
  800b89:	75 d6                	jne    800b61 <memcmp+0x1f>
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b9b:	89 c2                	mov    %eax,%edx
  800b9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba0:	39 d0                	cmp    %edx,%eax
  800ba2:	73 15                	jae    800bb9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ba8:	38 08                	cmp    %cl,(%eax)
  800baa:	75 06                	jne    800bb2 <memfind+0x1d>
  800bac:	eb 0b                	jmp    800bb9 <memfind+0x24>
  800bae:	38 08                	cmp    %cl,(%eax)
  800bb0:	74 07                	je     800bb9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	39 c2                	cmp    %eax,%edx
  800bb7:	77 f5                	ja     800bae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 04             	sub    $0x4,%esp
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bca:	0f b6 02             	movzbl (%edx),%eax
  800bcd:	3c 20                	cmp    $0x20,%al
  800bcf:	74 04                	je     800bd5 <strtol+0x1a>
  800bd1:	3c 09                	cmp    $0x9,%al
  800bd3:	75 0e                	jne    800be3 <strtol+0x28>
		s++;
  800bd5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd8:	0f b6 02             	movzbl (%edx),%eax
  800bdb:	3c 20                	cmp    $0x20,%al
  800bdd:	74 f6                	je     800bd5 <strtol+0x1a>
  800bdf:	3c 09                	cmp    $0x9,%al
  800be1:	74 f2                	je     800bd5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be3:	3c 2b                	cmp    $0x2b,%al
  800be5:	75 0c                	jne    800bf3 <strtol+0x38>
		s++;
  800be7:	83 c2 01             	add    $0x1,%edx
  800bea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bf1:	eb 15                	jmp    800c08 <strtol+0x4d>
	else if (*s == '-')
  800bf3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bfa:	3c 2d                	cmp    $0x2d,%al
  800bfc:	75 0a                	jne    800c08 <strtol+0x4d>
		s++, neg = 1;
  800bfe:	83 c2 01             	add    $0x1,%edx
  800c01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c08:	85 db                	test   %ebx,%ebx
  800c0a:	0f 94 c0             	sete   %al
  800c0d:	74 05                	je     800c14 <strtol+0x59>
  800c0f:	83 fb 10             	cmp    $0x10,%ebx
  800c12:	75 18                	jne    800c2c <strtol+0x71>
  800c14:	80 3a 30             	cmpb   $0x30,(%edx)
  800c17:	75 13                	jne    800c2c <strtol+0x71>
  800c19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c1d:	8d 76 00             	lea    0x0(%esi),%esi
  800c20:	75 0a                	jne    800c2c <strtol+0x71>
		s += 2, base = 16;
  800c22:	83 c2 02             	add    $0x2,%edx
  800c25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2a:	eb 15                	jmp    800c41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c2c:	84 c0                	test   %al,%al
  800c2e:	66 90                	xchg   %ax,%ax
  800c30:	74 0f                	je     800c41 <strtol+0x86>
  800c32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c37:	80 3a 30             	cmpb   $0x30,(%edx)
  800c3a:	75 05                	jne    800c41 <strtol+0x86>
		s++, base = 8;
  800c3c:	83 c2 01             	add    $0x1,%edx
  800c3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c41:	b8 00 00 00 00       	mov    $0x0,%eax
  800c46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c48:	0f b6 0a             	movzbl (%edx),%ecx
  800c4b:	89 cf                	mov    %ecx,%edi
  800c4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c50:	80 fb 09             	cmp    $0x9,%bl
  800c53:	77 08                	ja     800c5d <strtol+0xa2>
			dig = *s - '0';
  800c55:	0f be c9             	movsbl %cl,%ecx
  800c58:	83 e9 30             	sub    $0x30,%ecx
  800c5b:	eb 1e                	jmp    800c7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c60:	80 fb 19             	cmp    $0x19,%bl
  800c63:	77 08                	ja     800c6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c65:	0f be c9             	movsbl %cl,%ecx
  800c68:	83 e9 57             	sub    $0x57,%ecx
  800c6b:	eb 0e                	jmp    800c7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c70:	80 fb 19             	cmp    $0x19,%bl
  800c73:	77 15                	ja     800c8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c75:	0f be c9             	movsbl %cl,%ecx
  800c78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c7b:	39 f1                	cmp    %esi,%ecx
  800c7d:	7d 0b                	jge    800c8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c7f:	83 c2 01             	add    $0x1,%edx
  800c82:	0f af c6             	imul   %esi,%eax
  800c85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c88:	eb be                	jmp    800c48 <strtol+0x8d>
  800c8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c90:	74 05                	je     800c97 <strtol+0xdc>
		*endptr = (char *) s;
  800c92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c97:	89 ca                	mov    %ecx,%edx
  800c99:	f7 da                	neg    %edx
  800c9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c9f:	0f 45 c2             	cmovne %edx,%eax
}
  800ca2:	83 c4 04             	add    $0x4,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
	...

00800cac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	89 1c 24             	mov    %ebx,(%esp)
  800cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 c3                	mov    %eax,%ebx
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	89 c6                	mov    %eax,%esi
  800cce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800cd0:	8b 1c 24             	mov    (%esp),%ebx
  800cd3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cdb:	89 ec                	mov    %ebp,%esp
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_cgetc>:

int
sys_cgetc(void)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	89 1c 24             	mov    %ebx,(%esp)
  800ce8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cec:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800d04:	8b 1c 24             	mov    (%esp),%ebx
  800d07:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d0b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d0f:	89 ec                	mov    %ebp,%esp
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	89 1c 24             	mov    %ebx,(%esp)
  800d1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d20:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d29:	b8 03 00 00 00       	mov    $0x3,%eax
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	89 cb                	mov    %ecx,%ebx
  800d33:	89 cf                	mov    %ecx,%edi
  800d35:	89 ce                	mov    %ecx,%esi
  800d37:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800d39:	8b 1c 24             	mov    (%esp),%ebx
  800d3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d40:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d44:	89 ec                	mov    %ebp,%esp
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	89 1c 24             	mov    %ebx,(%esp)
  800d51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d55:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d63:	89 d1                	mov    %edx,%ecx
  800d65:	89 d3                	mov    %edx,%ebx
  800d67:	89 d7                	mov    %edx,%edi
  800d69:	89 d6                	mov    %edx,%esi
  800d6b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800d6d:	8b 1c 24             	mov    (%esp),%ebx
  800d70:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_yield>:

void
sys_yield(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	89 1c 24             	mov    %ebx,(%esp)
  800d85:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d89:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d92:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d97:	89 d1                	mov    %edx,%ecx
  800d99:	89 d3                	mov    %edx,%ebx
  800d9b:	89 d7                	mov    %edx,%edi
  800d9d:	89 d6                	mov    %edx,%esi
  800d9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800da1:	8b 1c 24             	mov    (%esp),%ebx
  800da4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dac:	89 ec                	mov    %ebp,%esp
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	89 1c 24             	mov    %ebx,(%esp)
  800db9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dbd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc1:	be 00 00 00 00       	mov    $0x0,%esi
  800dc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 f7                	mov    %esi,%edi
  800dd6:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800dd8:	8b 1c 24             	mov    (%esp),%ebx
  800ddb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ddf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800de3:	89 ec                	mov    %ebp,%esp
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	89 1c 24             	mov    %ebx,(%esp)
  800df0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800df4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df8:	b8 05 00 00 00       	mov    $0x5,%eax
  800dfd:	8b 75 18             	mov    0x18(%ebp),%esi
  800e00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e0e:	8b 1c 24             	mov    (%esp),%ebx
  800e11:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e15:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e19:	89 ec                	mov    %ebp,%esp
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	89 1c 24             	mov    %ebx,(%esp)
  800e26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e2a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e33:	b8 06 00 00 00       	mov    $0x6,%eax
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	89 de                	mov    %ebx,%esi
  800e42:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800e44:	8b 1c 24             	mov    (%esp),%ebx
  800e47:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e4b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e4f:	89 ec                	mov    %ebp,%esp
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 0c             	sub    $0xc,%esp
  800e59:	89 1c 24             	mov    %ebx,(%esp)
  800e5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e60:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e69:	b8 08 00 00 00       	mov    $0x8,%eax
  800e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	89 df                	mov    %ebx,%edi
  800e76:	89 de                	mov    %ebx,%esi
  800e78:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800e7a:	8b 1c 24             	mov    (%esp),%ebx
  800e7d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e81:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e85:	89 ec                	mov    %ebp,%esp
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	89 1c 24             	mov    %ebx,(%esp)
  800e92:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e96:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9f:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	89 df                	mov    %ebx,%edi
  800eac:	89 de                	mov    %ebx,%esi
  800eae:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb0:	8b 1c 24             	mov    (%esp),%ebx
  800eb3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ebb:	89 ec                	mov    %ebp,%esp
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	83 ec 0c             	sub    $0xc,%esp
  800ec5:	89 1c 24             	mov    %ebx,(%esp)
  800ec8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ecc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 df                	mov    %ebx,%edi
  800ee2:	89 de                	mov    %ebx,%esi
  800ee4:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ee6:	8b 1c 24             	mov    (%esp),%ebx
  800ee9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ef1:	89 ec                	mov    %ebp,%esp
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	89 1c 24             	mov    %ebx,(%esp)
  800efe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f02:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	be 00 00 00 00       	mov    $0x0,%esi
  800f0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1e:	8b 1c 24             	mov    (%esp),%ebx
  800f21:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f25:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f29:	89 ec                	mov    %ebp,%esp
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	89 1c 24             	mov    %ebx,(%esp)
  800f36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	89 cb                	mov    %ecx,%ebx
  800f4d:	89 cf                	mov    %ecx,%edi
  800f4f:	89 ce                	mov    %ecx,%esi
  800f51:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800f53:	8b 1c 24             	mov    (%esp),%ebx
  800f56:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f5a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f5e:	89 ec                	mov    %ebp,%esp
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
	...

00800f64 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f6a:	c7 44 24 08 a4 19 80 	movl   $0x8019a4,0x8(%esp)
  800f71:	00 
  800f72:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  800f79:	00 
  800f7a:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  800f81:	e8 26 f2 ff ff       	call   8001ac <_panic>

00800f86 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	53                   	push   %ebx
  800f8a:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr;
	pte_t pte;

	// LAB 4: Your code here.
	addr = (void *) ((uint32_t) pn * PGSIZE);
  800f8d:	89 d3                	mov    %edx,%ebx
  800f8f:	c1 e3 0c             	shl    $0xc,%ebx
	pte = vpt[VPN(addr)];
  800f92:	89 da                	mov    %ebx,%edx
  800f94:	c1 ea 0c             	shr    $0xc,%edx
  800f97:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((pte & PTE_W) > 0 || (pte & PTE_COW) > 0) 
  800f9e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800fa4:	0f 84 8c 00 00 00    	je     801036 <duppage+0xb0>
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800faa:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fb1:	00 
  800fb2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fb6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc5:	e8 1d fe ff ff       	call   800de7 <sys_page_map>
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	79 20                	jns    800fee <duppage+0x68>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  800fce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd2:	c7 44 24 08 1c 1a 80 	movl   $0x801a1c,0x8(%esp)
  800fd9:	00 
  800fda:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  800fe1:	00 
  800fe2:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  800fe9:	e8 be f1 ff ff       	call   8001ac <_panic>
	
		if ((r = sys_page_map (0, addr, 0, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800fee:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800ff5:	00 
  800ff6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ffa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801001:	00 
  801002:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801006:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100d:	e8 d5 fd ff ff       	call   800de7 <sys_page_map>
  801012:	85 c0                	test   %eax,%eax
  801014:	79 64                	jns    80107a <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  801016:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80101a:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801021:	00 
  801022:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801029:	00 
  80102a:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  801031:	e8 76 f1 ff ff       	call   8001ac <_panic>
	} 
	else 
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801036:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80103d:	00 
  80103e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801042:	89 44 24 08          	mov    %eax,0x8(%esp)
  801046:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80104a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801051:	e8 91 fd ff ff       	call   800de7 <sys_page_map>
  801056:	85 c0                	test   %eax,%eax
  801058:	79 20                	jns    80107a <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  80105a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80105e:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  801065:	00 
  801066:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  80106d:	00 
  80106e:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  801075:	e8 32 f1 ff ff       	call   8001ac <_panic>
	}	
	//panic("duppage not implemented");
	return 0;
}
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
  80107f:	83 c4 24             	add    $0x24,%esp
  801082:	5b                   	pop    %ebx
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	53                   	push   %ebx
  801089:	83 ec 24             	sub    $0x24,%esp
	// LAB 4: Your code here.
	envid_t envid;  
	uint8_t *addr;  
	int r;  
	extern unsigned char end[];  
	set_pgfault_handler(pgfault);  
  80108c:	c7 04 24 ba 11 80 00 	movl   $0x8011ba,(%esp)
  801093:	e8 5c 03 00 00       	call   8013f4 <set_pgfault_handler>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801098:	bb 07 00 00 00       	mov    $0x7,%ebx
  80109d:	89 d8                	mov    %ebx,%eax
  80109f:	cd 30                	int    $0x30
  8010a1:	89 c3                	mov    %eax,%ebx
	envid = sys_exofork();  
	if (envid < 0)  
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	79 20                	jns    8010c7 <fork+0x42>
		panic("sys_exofork: %e", envid);  
  8010a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ab:	c7 44 24 08 c5 19 80 	movl   $0x8019c5,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  8010c2:	e8 e5 f0 ff ff       	call   8001ac <_panic>
	//child  
	if (envid == 0) {  
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	75 20                	jne    8010eb <fork+0x66>
		//can't set pgh here ,must before child run  
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
  8010cb:	e8 78 fc ff ff       	call   800d48 <sys_getenvid>
  8010d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010d5:	89 c2                	mov    %eax,%edx
  8010d7:	c1 e2 07             	shl    $0x7,%edx
  8010da:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8010e1:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;  
  8010e6:	e9 c7 00 00 00       	jmp    8011b2 <fork+0x12d>
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  8010eb:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8010f2:	b8 10 20 80 00       	mov    $0x802010,%eax
  8010f7:	3d 00 00 80 00       	cmp    $0x800000,%eax
  8010fc:	76 23                	jbe    801121 <fork+0x9c>
  8010fe:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, VPN(addr));  
  801103:	c1 ea 0c             	shr    $0xc,%edx
  801106:	89 d8                	mov    %ebx,%eax
  801108:	e8 79 fe ff ff       	call   800f86 <duppage>
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
		return 0;  
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  80110d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801110:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801116:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801119:	81 fa 10 20 80 00    	cmp    $0x802010,%edx
  80111f:	72 e2                	jb     801103 <fork+0x7e>
		duppage(envid, VPN(addr));  
	duppage(envid, VPN(&addr));  
  801121:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801124:	c1 ea 0c             	shr    $0xc,%edx
  801127:	89 d8                	mov    %ebx,%eax
  801129:	e8 58 fe ff ff       	call   800f86 <duppage>
	//copy user exception stack  

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)  
  80112e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801135:	00 
  801136:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80113d:	ee 
  80113e:	89 1c 24             	mov    %ebx,(%esp)
  801141:	e8 6a fc ff ff       	call   800db0 <sys_page_alloc>
  801146:	85 c0                	test   %eax,%eax
  801148:	79 20                	jns    80116a <fork+0xe5>
		panic("sys_page_alloc: %e", r);  
  80114a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114e:	c7 44 24 08 d5 19 80 	movl   $0x8019d5,0x8(%esp)
  801155:	00 
  801156:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  80115d:	00 
  80115e:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  801165:	e8 42 f0 ff ff       	call   8001ac <_panic>
	r = sys_env_set_pgfault_upcall(envid, env->env_pgfault_upcall);  
  80116a:	a1 04 20 80 00       	mov    0x802004,%eax
  80116f:	8b 40 64             	mov    0x64(%eax),%eax
  801172:	89 44 24 04          	mov    %eax,0x4(%esp)
  801176:	89 1c 24             	mov    %ebx,(%esp)
  801179:	e8 41 fd ff ff       	call   800ebf <sys_env_set_pgfault_upcall>

	//set child status  

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)  
  80117e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801185:	00 
  801186:	89 1c 24             	mov    %ebx,(%esp)
  801189:	e8 c5 fc ff ff       	call   800e53 <sys_env_set_status>
  80118e:	85 c0                	test   %eax,%eax
  801190:	79 20                	jns    8011b2 <fork+0x12d>
		panic("sys_env_set_status: %e", r);  
  801192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801196:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  8011ad:	e8 fa ef ff ff       	call   8001ac <_panic>
	return envid;  
	//panic("fork not implemented");
}
  8011b2:	89 d8                	mov    %ebx,%eax
  8011b4:	83 c4 24             	add    $0x24,%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 24             	sub    $0x24,%esp
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011c4:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8011c6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011ca:	75 1c                	jne    8011e8 <pgfault+0x2e>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!(err&FEC_WR))   
		panic("Page fault: not a write access.");  
  8011cc:	c7 44 24 08 a0 1a 80 	movl   $0x801aa0,0x8(%esp)
  8011d3:	00 
  8011d4:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8011db:	00 
  8011dc:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  8011e3:	e8 c4 ef ff ff       	call   8001ac <_panic>
	
	if ( !(vpt[VPN(addr)]&PTE_COW) )  
  8011e8:	89 d8                	mov    %ebx,%eax
  8011ea:	c1 e8 0c             	shr    $0xc,%eax
  8011ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f4:	f6 c4 08             	test   $0x8,%ah
  8011f7:	75 1c                	jne    801215 <pgfault+0x5b>
		panic("Page fualt: not a COW page.");  
  8011f9:	c7 44 24 08 ff 19 80 	movl   $0x8019ff,0x8(%esp)
  801200:	00 
  801201:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801208:	00 
  801209:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  801210:	e8 97 ef ff ff       	call   8001ac <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	
	// LAB 4: Your code here.
	
	if ((r=sys_page_alloc(0, PFTEMP, PTE_U|PTE_W|PTE_P)) <0)  
  801215:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80121c:	00 
  80121d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801224:	00 
  801225:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122c:	e8 7f fb ff ff       	call   800db0 <sys_page_alloc>
  801231:	85 c0                	test   %eax,%eax
  801233:	79 20                	jns    801255 <pgfault+0x9b>
		panic("Page fault: sys_page_alloc err %e.", r);  
  801235:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801239:	c7 44 24 08 c0 1a 80 	movl   $0x801ac0,0x8(%esp)
  801240:	00 
  801241:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801248:	00 
  801249:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  801250:	e8 57 ef ff ff       	call   8001ac <_panic>
	
	memmove(PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);  
  801255:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80125b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801262:	00 
  801263:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801267:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80126e:	e8 70 f8 ff ff       	call   800ae3 <memmove>
	
	
	if ((r=sys_page_map(0, PFTEMP, 0, (void *)PTE_ADDR(addr), PTE_U|PTE_W|PTE_P))<0)  
  801273:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80127a:	00 
  80127b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80127f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801286:	00 
  801287:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80128e:	00 
  80128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801296:	e8 4c fb ff ff       	call   800de7 <sys_page_map>
  80129b:	85 c0                	test   %eax,%eax
  80129d:	79 20                	jns    8012bf <pgfault+0x105>
		panic("Page fault: sys_page_map err %e.", r);  
  80129f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a3:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  8012aa:	00 
  8012ab:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8012b2:	00 
  8012b3:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  8012ba:	e8 ed ee ff ff       	call   8001ac <_panic>
	if ((r=sys_page_unmap(0, PFTEMP))<0)  
  8012bf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012c6:	00 
  8012c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ce:	e8 4a fb ff ff       	call   800e1d <sys_page_unmap>
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	79 20                	jns    8012f7 <pgfault+0x13d>
		panic("Page fault: sys_page_unmap err %e.", r);  
  8012d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012db:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8012e2:	00 
  8012e3:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  8012ea:	00 
  8012eb:	c7 04 24 ba 19 80 00 	movl   $0x8019ba,(%esp)
  8012f2:	e8 b5 ee ff ff       	call   8001ac <_panic>
	
	//panic("pgfault not implemented");
}
  8012f7:	83 c4 24             	add    $0x24,%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    
  8012fd:	00 00                	add    %al,(%eax)
	...

00801300 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	57                   	push   %edi
  801304:	56                   	push   %esi
  801305:	53                   	push   %ebx
  801306:	83 ec 1c             	sub    $0x1c,%esp
  801309:	8b 75 08             	mov    0x8(%ebp),%esi
  80130c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80130f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");

	int r;
	while ((r = sys_ipc_try_send (to_env, val, pg != NULL ? pg : (void *) UTOP, perm)) < 0) 
  801312:	eb 2a                	jmp    80133e <ipc_send+0x3e>
	{
		//cprintf("bug is not in sys_ipc_try_send\n");		//for debug
		if (r != -E_IPC_NOT_RECV)
  801314:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801317:	74 20                	je     801339 <ipc_send+0x39>
			panic ("ipc_send: send message error %e", r);
  801319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80131d:	c7 44 24 08 2c 1b 80 	movl   $0x801b2c,0x8(%esp)
  801324:	00 
  801325:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80132c:	00 
  80132d:	c7 04 24 4c 1b 80 00 	movl   $0x801b4c,(%esp)
  801334:	e8 73 ee ff ff       	call   8001ac <_panic>
		sys_yield ();
  801339:	e8 3e fa ff ff       	call   800d7c <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");

	int r;
	while ((r = sys_ipc_try_send (to_env, val, pg != NULL ? pg : (void *) UTOP, perm)) < 0) 
  80133e:	85 db                	test   %ebx,%ebx
  801340:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801345:	0f 45 c3             	cmovne %ebx,%eax
  801348:	8b 55 14             	mov    0x14(%ebp),%edx
  80134b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80134f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801353:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801357:	89 34 24             	mov    %esi,(%esp)
  80135a:	e8 96 fb ff ff       	call   800ef5 <sys_ipc_try_send>
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 b1                	js     801314 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic ("ipc_send: send message error %e", r);
		sys_yield ();
	}

}
  801363:	83 c4 1c             	add    $0x1c,%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
uint32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 28             	sub    $0x28,%esp
  801371:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801374:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801377:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80137a:	8b 75 08             	mov    0x8(%ebp),%esi
  80137d:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	
	int r;
	if (pg != NULL)
  801380:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801384:	74 10                	je     801396 <ipc_recv+0x2b>
	    r = sys_ipc_recv ((void *) UTOP);
  801386:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80138d:	e8 9b fb ff ff       	call   800f2d <sys_ipc_recv>
  801392:	89 c3                	mov    %eax,%ebx
  801394:	eb 0e                	jmp    8013a4 <ipc_recv+0x39>
	else
	    r = sys_ipc_recv (pg);
  801396:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80139d:	e8 8b fb ff ff       	call   800f2d <sys_ipc_recv>
  8013a2:	89 c3                	mov    %eax,%ebx
	struct Env *curenv = (struct Env *) envs + ENVX (sys_getenvid ());
  8013a4:	e8 9f f9 ff ff       	call   800d48 <sys_getenvid>
  8013a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	c1 e2 07             	shl    $0x7,%edx
  8013b3:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
	if (from_env_store != NULL)
  8013ba:	85 f6                	test   %esi,%esi
  8013bc:	74 0e                	je     8013cc <ipc_recv+0x61>
		*from_env_store = r < 0 ? 0 : curenv->env_ipc_from;
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c3:	85 db                	test   %ebx,%ebx
  8013c5:	78 03                	js     8013ca <ipc_recv+0x5f>
  8013c7:	8b 42 74             	mov    0x74(%edx),%eax
  8013ca:	89 06                	mov    %eax,(%esi)
	if (perm_store != NULL)
  8013cc:	85 ff                	test   %edi,%edi
  8013ce:	74 0e                	je     8013de <ipc_recv+0x73>
		*perm_store = r < 0 ? 0 : curenv->env_ipc_perm;
  8013d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d5:	85 db                	test   %ebx,%ebx
  8013d7:	78 03                	js     8013dc <ipc_recv+0x71>
  8013d9:	8b 42 78             	mov    0x78(%edx),%eax
  8013dc:	89 07                	mov    %eax,(%edi)
	if (r < 0)
		return r;
  8013de:	89 d8                	mov    %ebx,%eax
	struct Env *curenv = (struct Env *) envs + ENVX (sys_getenvid ());
	if (from_env_store != NULL)
		*from_env_store = r < 0 ? 0 : curenv->env_ipc_from;
	if (perm_store != NULL)
		*perm_store = r < 0 ? 0 : curenv->env_ipc_perm;
	if (r < 0)
  8013e0:	85 db                	test   %ebx,%ebx
  8013e2:	78 03                	js     8013e7 <ipc_recv+0x7c>
		return r;
	return curenv->env_ipc_value;
  8013e4:	8b 42 70             	mov    0x70(%edx),%eax
}
  8013e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013f0:	89 ec                	mov    %ebp,%esp
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013fa:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801401:	75 54                	jne    801457 <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801403:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80140a:	00 
  80140b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801412:	ee 
  801413:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80141a:	e8 91 f9 ff ff       	call   800db0 <sys_page_alloc>
  80141f:	85 c0                	test   %eax,%eax
  801421:	79 20                	jns    801443 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  801423:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801427:	c7 44 24 08 56 1b 80 	movl   $0x801b56,0x8(%esp)
  80142e:	00 
  80142f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801436:	00 
  801437:	c7 04 24 6e 1b 80 00 	movl   $0x801b6e,(%esp)
  80143e:	e8 69 ed ff ff       	call   8001ac <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  801443:	c7 44 24 04 64 14 80 	movl   $0x801464,0x4(%esp)
  80144a:	00 
  80144b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801452:	e8 68 fa ff ff       	call   800ebf <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    
  801461:	00 00                	add    %al,(%eax)
	...

00801464 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801464:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801465:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80146a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80146c:	83 c4 04             	add    $0x4,%esp
	// Hints:
	//   What registers are available for intermediate calculations?
	//
	// LAB 4: Your code here.
	
	movl	0x30(%esp), %eax
  80146f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl	$0x4, %eax
  801473:	83 e8 04             	sub    $0x4,%eax
	movl	%eax, 0x30(%esp)
  801476:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl	0x28(%esp), %ebx
  80147a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl	%ebx, (%eax)
  80147e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.
	// LAB 4: Your code here.

	addl	$0x8, %esp
  801480:	83 c4 08             	add    $0x8,%esp
	popal
  801483:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.

	addl	$0x4, %esp
  801484:	83 c4 04             	add    $0x4,%esp
	popfl
  801487:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	pop	%esp
  801488:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801489:	c3                   	ret    
  80148a:	00 00                	add    %al,(%eax)
  80148c:	00 00                	add    %al,(%eax)
	...

00801490 <__udivdi3>:
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	57                   	push   %edi
  801494:	56                   	push   %esi
  801495:	83 ec 10             	sub    $0x10,%esp
  801498:	8b 45 14             	mov    0x14(%ebp),%eax
  80149b:	8b 55 08             	mov    0x8(%ebp),%edx
  80149e:	8b 75 10             	mov    0x10(%ebp),%esi
  8014a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8014a9:	75 35                	jne    8014e0 <__udivdi3+0x50>
  8014ab:	39 fe                	cmp    %edi,%esi
  8014ad:	77 61                	ja     801510 <__udivdi3+0x80>
  8014af:	85 f6                	test   %esi,%esi
  8014b1:	75 0b                	jne    8014be <__udivdi3+0x2e>
  8014b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b8:	31 d2                	xor    %edx,%edx
  8014ba:	f7 f6                	div    %esi
  8014bc:	89 c6                	mov    %eax,%esi
  8014be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8014c1:	31 d2                	xor    %edx,%edx
  8014c3:	89 f8                	mov    %edi,%eax
  8014c5:	f7 f6                	div    %esi
  8014c7:	89 c7                	mov    %eax,%edi
  8014c9:	89 c8                	mov    %ecx,%eax
  8014cb:	f7 f6                	div    %esi
  8014cd:	89 c1                	mov    %eax,%ecx
  8014cf:	89 fa                	mov    %edi,%edx
  8014d1:	89 c8                	mov    %ecx,%eax
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	5e                   	pop    %esi
  8014d7:	5f                   	pop    %edi
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    
  8014da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014e0:	39 f8                	cmp    %edi,%eax
  8014e2:	77 1c                	ja     801500 <__udivdi3+0x70>
  8014e4:	0f bd d0             	bsr    %eax,%edx
  8014e7:	83 f2 1f             	xor    $0x1f,%edx
  8014ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014ed:	75 39                	jne    801528 <__udivdi3+0x98>
  8014ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8014f2:	0f 86 a0 00 00 00    	jbe    801598 <__udivdi3+0x108>
  8014f8:	39 f8                	cmp    %edi,%eax
  8014fa:	0f 82 98 00 00 00    	jb     801598 <__udivdi3+0x108>
  801500:	31 ff                	xor    %edi,%edi
  801502:	31 c9                	xor    %ecx,%ecx
  801504:	89 c8                	mov    %ecx,%eax
  801506:	89 fa                	mov    %edi,%edx
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	5e                   	pop    %esi
  80150c:	5f                   	pop    %edi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    
  80150f:	90                   	nop
  801510:	89 d1                	mov    %edx,%ecx
  801512:	89 fa                	mov    %edi,%edx
  801514:	89 c8                	mov    %ecx,%eax
  801516:	31 ff                	xor    %edi,%edi
  801518:	f7 f6                	div    %esi
  80151a:	89 c1                	mov    %eax,%ecx
  80151c:	89 fa                	mov    %edi,%edx
  80151e:	89 c8                	mov    %ecx,%eax
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	5e                   	pop    %esi
  801524:	5f                   	pop    %edi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    
  801527:	90                   	nop
  801528:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80152c:	89 f2                	mov    %esi,%edx
  80152e:	d3 e0                	shl    %cl,%eax
  801530:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801533:	b8 20 00 00 00       	mov    $0x20,%eax
  801538:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80153b:	89 c1                	mov    %eax,%ecx
  80153d:	d3 ea                	shr    %cl,%edx
  80153f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801543:	0b 55 ec             	or     -0x14(%ebp),%edx
  801546:	d3 e6                	shl    %cl,%esi
  801548:	89 c1                	mov    %eax,%ecx
  80154a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80154d:	89 fe                	mov    %edi,%esi
  80154f:	d3 ee                	shr    %cl,%esi
  801551:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801555:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801558:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80155b:	d3 e7                	shl    %cl,%edi
  80155d:	89 c1                	mov    %eax,%ecx
  80155f:	d3 ea                	shr    %cl,%edx
  801561:	09 d7                	or     %edx,%edi
  801563:	89 f2                	mov    %esi,%edx
  801565:	89 f8                	mov    %edi,%eax
  801567:	f7 75 ec             	divl   -0x14(%ebp)
  80156a:	89 d6                	mov    %edx,%esi
  80156c:	89 c7                	mov    %eax,%edi
  80156e:	f7 65 e8             	mull   -0x18(%ebp)
  801571:	39 d6                	cmp    %edx,%esi
  801573:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801576:	72 30                	jb     8015a8 <__udivdi3+0x118>
  801578:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80157b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80157f:	d3 e2                	shl    %cl,%edx
  801581:	39 c2                	cmp    %eax,%edx
  801583:	73 05                	jae    80158a <__udivdi3+0xfa>
  801585:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801588:	74 1e                	je     8015a8 <__udivdi3+0x118>
  80158a:	89 f9                	mov    %edi,%ecx
  80158c:	31 ff                	xor    %edi,%edi
  80158e:	e9 71 ff ff ff       	jmp    801504 <__udivdi3+0x74>
  801593:	90                   	nop
  801594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801598:	31 ff                	xor    %edi,%edi
  80159a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80159f:	e9 60 ff ff ff       	jmp    801504 <__udivdi3+0x74>
  8015a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8015ab:	31 ff                	xor    %edi,%edi
  8015ad:	89 c8                	mov    %ecx,%eax
  8015af:	89 fa                	mov    %edi,%edx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	5e                   	pop    %esi
  8015b5:	5f                   	pop    %edi
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    
	...

008015c0 <__umoddi3>:
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	57                   	push   %edi
  8015c4:	56                   	push   %esi
  8015c5:	83 ec 20             	sub    $0x20,%esp
  8015c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8015cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015d4:	85 d2                	test   %edx,%edx
  8015d6:	89 c8                	mov    %ecx,%eax
  8015d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8015db:	75 13                	jne    8015f0 <__umoddi3+0x30>
  8015dd:	39 f7                	cmp    %esi,%edi
  8015df:	76 3f                	jbe    801620 <__umoddi3+0x60>
  8015e1:	89 f2                	mov    %esi,%edx
  8015e3:	f7 f7                	div    %edi
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	31 d2                	xor    %edx,%edx
  8015e9:	83 c4 20             	add    $0x20,%esp
  8015ec:	5e                   	pop    %esi
  8015ed:	5f                   	pop    %edi
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    
  8015f0:	39 f2                	cmp    %esi,%edx
  8015f2:	77 4c                	ja     801640 <__umoddi3+0x80>
  8015f4:	0f bd ca             	bsr    %edx,%ecx
  8015f7:	83 f1 1f             	xor    $0x1f,%ecx
  8015fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015fd:	75 51                	jne    801650 <__umoddi3+0x90>
  8015ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801602:	0f 87 e0 00 00 00    	ja     8016e8 <__umoddi3+0x128>
  801608:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160b:	29 f8                	sub    %edi,%eax
  80160d:	19 d6                	sbb    %edx,%esi
  80160f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801615:	89 f2                	mov    %esi,%edx
  801617:	83 c4 20             	add    $0x20,%esp
  80161a:	5e                   	pop    %esi
  80161b:	5f                   	pop    %edi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    
  80161e:	66 90                	xchg   %ax,%ax
  801620:	85 ff                	test   %edi,%edi
  801622:	75 0b                	jne    80162f <__umoddi3+0x6f>
  801624:	b8 01 00 00 00       	mov    $0x1,%eax
  801629:	31 d2                	xor    %edx,%edx
  80162b:	f7 f7                	div    %edi
  80162d:	89 c7                	mov    %eax,%edi
  80162f:	89 f0                	mov    %esi,%eax
  801631:	31 d2                	xor    %edx,%edx
  801633:	f7 f7                	div    %edi
  801635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801638:	f7 f7                	div    %edi
  80163a:	eb a9                	jmp    8015e5 <__umoddi3+0x25>
  80163c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801640:	89 c8                	mov    %ecx,%eax
  801642:	89 f2                	mov    %esi,%edx
  801644:	83 c4 20             	add    $0x20,%esp
  801647:	5e                   	pop    %esi
  801648:	5f                   	pop    %edi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    
  80164b:	90                   	nop
  80164c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801650:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801654:	d3 e2                	shl    %cl,%edx
  801656:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801659:	ba 20 00 00 00       	mov    $0x20,%edx
  80165e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801661:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801664:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801668:	89 fa                	mov    %edi,%edx
  80166a:	d3 ea                	shr    %cl,%edx
  80166c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801670:	0b 55 f4             	or     -0xc(%ebp),%edx
  801673:	d3 e7                	shl    %cl,%edi
  801675:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801679:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80167c:	89 f2                	mov    %esi,%edx
  80167e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801681:	89 c7                	mov    %eax,%edi
  801683:	d3 ea                	shr    %cl,%edx
  801685:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801689:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80168c:	89 c2                	mov    %eax,%edx
  80168e:	d3 e6                	shl    %cl,%esi
  801690:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801694:	d3 ea                	shr    %cl,%edx
  801696:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80169a:	09 d6                	or     %edx,%esi
  80169c:	89 f0                	mov    %esi,%eax
  80169e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8016a1:	d3 e7                	shl    %cl,%edi
  8016a3:	89 f2                	mov    %esi,%edx
  8016a5:	f7 75 f4             	divl   -0xc(%ebp)
  8016a8:	89 d6                	mov    %edx,%esi
  8016aa:	f7 65 e8             	mull   -0x18(%ebp)
  8016ad:	39 d6                	cmp    %edx,%esi
  8016af:	72 2b                	jb     8016dc <__umoddi3+0x11c>
  8016b1:	39 c7                	cmp    %eax,%edi
  8016b3:	72 23                	jb     8016d8 <__umoddi3+0x118>
  8016b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016b9:	29 c7                	sub    %eax,%edi
  8016bb:	19 d6                	sbb    %edx,%esi
  8016bd:	89 f0                	mov    %esi,%eax
  8016bf:	89 f2                	mov    %esi,%edx
  8016c1:	d3 ef                	shr    %cl,%edi
  8016c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016c7:	d3 e0                	shl    %cl,%eax
  8016c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016cd:	09 f8                	or     %edi,%eax
  8016cf:	d3 ea                	shr    %cl,%edx
  8016d1:	83 c4 20             	add    $0x20,%esp
  8016d4:	5e                   	pop    %esi
  8016d5:	5f                   	pop    %edi
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    
  8016d8:	39 d6                	cmp    %edx,%esi
  8016da:	75 d9                	jne    8016b5 <__umoddi3+0xf5>
  8016dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8016df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8016e2:	eb d1                	jmp    8016b5 <__umoddi3+0xf5>
  8016e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016e8:	39 f2                	cmp    %esi,%edx
  8016ea:	0f 82 18 ff ff ff    	jb     801608 <__umoddi3+0x48>
  8016f0:	e9 1d ff ff ff       	jmp    801612 <__umoddi3+0x52>
