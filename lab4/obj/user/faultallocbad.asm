
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80003a:	c7 04 24 5c 00 80 00 	movl   $0x80005c,(%esp)
  800041:	e8 be 0e 00 00       	call   800f04 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  800046:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80004d:	00 
  80004e:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  800055:	e8 f2 0b 00 00       	call   800c4c <sys_cputs>
}
  80005a:	c9                   	leave  
  80005b:	c3                   	ret    

0080005c <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	53                   	push   %ebx
  800060:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800063:	8b 45 08             	mov    0x8(%ebp),%eax
  800066:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800068:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80006c:	c7 04 24 20 12 80 00 	movl   $0x801220,(%esp)
  800073:	e8 99 01 00 00       	call   800211 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800078:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80007f:	00 
  800080:	89 d8                	mov    %ebx,%eax
  800082:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800092:	e8 b9 0c 00 00       	call   800d50 <sys_page_alloc>
  800097:	85 c0                	test   %eax,%eax
  800099:	79 24                	jns    8000bf <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a3:	c7 44 24 08 40 12 80 	movl   $0x801240,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 2a 12 80 00 	movl   $0x80122a,(%esp)
  8000ba:	e8 8d 00 00 00       	call   80014c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000c3:	c7 44 24 08 6c 12 80 	movl   $0x80126c,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000d2:	00 
  8000d3:	89 1c 24             	mov    %ebx,(%esp)
  8000d6:	e8 65 07 00 00       	call   800840 <snprintf>
}
  8000db:	83 c4 24             	add    $0x24,%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  8000f6:	e8 ed 0b 00 00       	call   800ce8 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	89 c2                	mov    %eax,%edx
  800102:	c1 e2 07             	shl    $0x7,%edx
  800105:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80010c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800111:	85 f6                	test   %esi,%esi
  800113:	7e 07                	jle    80011c <libmain+0x38>
		binaryname = argv[0];
  800115:	8b 03                	mov    (%ebx),%eax
  800117:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800120:	89 34 24             	mov    %esi,(%esp)
  800123:	e8 0c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800128:	e8 0b 00 00 00       	call   800138 <exit>
}
  80012d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800130:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800133:	89 ec                	mov    %ebp,%esp
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    
	...

00800138 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800145:	e8 69 0b 00 00       	call   800cb3 <sys_env_destroy>
}
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800152:	a1 08 20 80 00       	mov    0x802008,%eax
  800157:	85 c0                	test   %eax,%eax
  800159:	74 10                	je     80016b <_panic+0x1f>
		cprintf("%s: ", argv0);
  80015b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015f:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800166:	e8 a6 00 00 00       	call   800211 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80016b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	89 44 24 08          	mov    %eax,0x8(%esp)
  800179:	a1 00 20 80 00       	mov    0x802000,%eax
  80017e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800182:	c7 04 24 ac 12 80 00 	movl   $0x8012ac,(%esp)
  800189:	e8 83 00 00 00       	call   800211 <cprintf>
	vcprintf(fmt, ap);
  80018e:	8d 45 14             	lea    0x14(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	8b 45 10             	mov    0x10(%ebp),%eax
  800198:	89 04 24             	mov    %eax,(%esp)
  80019b:	e8 10 00 00 00       	call   8001b0 <vcprintf>
	cprintf("\n");
  8001a0:	c7 04 24 28 12 80 00 	movl   $0x801228,(%esp)
  8001a7:	e8 65 00 00 00       	call   800211 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ac:	cc                   	int3   
  8001ad:	eb fd                	jmp    8001ac <_panic+0x60>
	...

008001b0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c0:	00 00 00 
	b.cnt = 0;
  8001c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	c7 04 24 2b 02 80 00 	movl   $0x80022b,(%esp)
  8001ec:	e8 cf 01 00 00       	call   8003c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	e8 43 0a 00 00       	call   800c4c <sys_cputs>

	return b.cnt;
}
  800209:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800217:	8d 45 0c             	lea    0xc(%ebp),%eax
  80021a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	e8 87 ff ff ff       	call   8001b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 14             	sub    $0x14,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 03                	mov    (%ebx),%eax
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80023e:	83 c0 01             	add    $0x1,%eax
  800241:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 19                	jne    800263 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80024a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800251:	00 
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	e8 ef 09 00 00       	call   800c4c <sys_cputs>
		b->idx = 0;
  80025d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800263:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 4c             	sub    $0x4c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d6                	mov    %edx,%esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800284:	8b 55 0c             	mov    0xc(%ebp),%edx
  800287:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
  80028d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800290:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800293:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800296:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029b:	39 d1                	cmp    %edx,%ecx
  80029d:	72 15                	jb     8002b4 <printnum+0x44>
  80029f:	77 07                	ja     8002a8 <printnum+0x38>
  8002a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a4:	39 d0                	cmp    %edx,%eax
  8002a6:	76 0c                	jbe    8002b4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a8:	83 eb 01             	sub    $0x1,%ebx
  8002ab:	85 db                	test   %ebx,%ebx
  8002ad:	8d 76 00             	lea    0x0(%esi),%esi
  8002b0:	7f 61                	jg     800313 <printnum+0xa3>
  8002b2:	eb 70                	jmp    800324 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002c7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002cb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002ce:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002d1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002df:	00 
  8002e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	e8 ae 0c 00 00       	call   800fa0 <__udivdi3>
  8002f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	89 54 24 04          	mov    %edx,0x4(%esp)
  800307:	89 f2                	mov    %esi,%edx
  800309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030c:	e8 5f ff ff ff       	call   800270 <printnum>
  800311:	eb 11                	jmp    800324 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800313:	89 74 24 04          	mov    %esi,0x4(%esp)
  800317:	89 3c 24             	mov    %edi,(%esp)
  80031a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031d:	83 eb 01             	sub    $0x1,%ebx
  800320:	85 db                	test   %ebx,%ebx
  800322:	7f ef                	jg     800313 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800324:	89 74 24 04          	mov    %esi,0x4(%esp)
  800328:	8b 74 24 04          	mov    0x4(%esp),%esi
  80032c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033a:	00 
  80033b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80033e:	89 14 24             	mov    %edx,(%esp)
  800341:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800344:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800348:	e8 83 0d 00 00       	call   8010d0 <__umoddi3>
  80034d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800351:	0f be 80 c8 12 80 00 	movsbl 0x8012c8(%eax),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80035e:	83 c4 4c             	add    $0x4c,%esp
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800369:	83 fa 01             	cmp    $0x1,%edx
  80036c:	7e 0f                	jle    80037d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	83 c2 08             	add    $0x8,%edx
  800373:	89 10                	mov    %edx,(%eax)
  800375:	8b 42 f8             	mov    -0x8(%edx),%eax
  800378:	8b 52 fc             	mov    -0x4(%edx),%edx
  80037b:	eb 24                	jmp    8003a1 <getuint+0x3b>
	else if (lflag)
  80037d:	85 d2                	test   %edx,%edx
  80037f:	74 11                	je     800392 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800381:	8b 10                	mov    (%eax),%edx
  800383:	83 c2 04             	add    $0x4,%edx
  800386:	89 10                	mov    %edx,(%eax)
  800388:	8b 42 fc             	mov    -0x4(%edx),%eax
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	eb 0f                	jmp    8003a1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	83 c2 04             	add    $0x4,%edx
  800397:	89 10                	mov    %edx,(%eax)
  800399:	8b 42 fc             	mov    -0x4(%edx),%eax
  80039c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b2:	73 0a                	jae    8003be <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b7:	88 0a                	mov    %cl,(%edx)
  8003b9:	83 c2 01             	add    $0x1,%edx
  8003bc:	89 10                	mov    %edx,(%eax)
}
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	57                   	push   %edi
  8003c4:	56                   	push   %esi
  8003c5:	53                   	push   %ebx
  8003c6:	83 ec 5c             	sub    $0x5c,%esp
  8003c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003d2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003d9:	eb 11                	jmp    8003ec <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 fd 03 00 00    	je     8007e0 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  8003e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ec:	0f b6 03             	movzbl (%ebx),%eax
  8003ef:	83 c3 01             	add    $0x1,%ebx
  8003f2:	83 f8 25             	cmp    $0x25,%eax
  8003f5:	75 e4                	jne    8003db <vprintfmt+0x1b>
  8003f7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003fb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800402:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800409:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800410:	b9 00 00 00 00       	mov    $0x0,%ecx
  800415:	eb 06                	jmp    80041d <vprintfmt+0x5d>
  800417:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80041b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	0f b6 13             	movzbl (%ebx),%edx
  800420:	0f b6 c2             	movzbl %dl,%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	8d 43 01             	lea    0x1(%ebx),%eax
  800429:	83 ea 23             	sub    $0x23,%edx
  80042c:	80 fa 55             	cmp    $0x55,%dl
  80042f:	0f 87 8e 03 00 00    	ja     8007c3 <vprintfmt+0x403>
  800435:	0f b6 d2             	movzbl %dl,%edx
  800438:	ff 24 95 80 13 80 00 	jmp    *0x801380(,%edx,4)
  80043f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800443:	eb d6                	jmp    80041b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800445:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800448:	83 ea 30             	sub    $0x30,%edx
  80044b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80044e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800451:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800454:	83 fb 09             	cmp    $0x9,%ebx
  800457:	77 55                	ja     8004ae <vprintfmt+0xee>
  800459:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80045c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800462:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800465:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800469:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80046c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80046f:	83 fb 09             	cmp    $0x9,%ebx
  800472:	76 eb                	jbe    80045f <vprintfmt+0x9f>
  800474:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800477:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047a:	eb 32                	jmp    8004ae <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80047c:	8b 55 14             	mov    0x14(%ebp),%edx
  80047f:	83 c2 04             	add    $0x4,%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	8b 52 fc             	mov    -0x4(%edx),%edx
  800488:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80048b:	eb 21                	jmp    8004ae <vprintfmt+0xee>

		case '.':
			if (width < 0)
  80048d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  80049a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80049d:	e9 79 ff ff ff       	jmp    80041b <vprintfmt+0x5b>
  8004a2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004a9:	e9 6d ff ff ff       	jmp    80041b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b2:	0f 89 63 ff ff ff    	jns    80041b <vprintfmt+0x5b>
  8004b8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004be:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004c1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004c4:	e9 52 ff ff ff       	jmp    80041b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c9:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004cc:	e9 4a ff ff ff       	jmp    80041b <vprintfmt+0x5b>
  8004d1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	83 c0 04             	add    $0x4,%eax
  8004da:	89 45 14             	mov    %eax,0x14(%ebp)
  8004dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e1:	8b 40 fc             	mov    -0x4(%eax),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	ff d7                	call   *%edi
  8004e9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8004ec:	e9 fb fe ff ff       	jmp    8003ec <vprintfmt+0x2c>
  8004f1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	83 c0 04             	add    $0x4,%eax
  8004fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fd:	8b 40 fc             	mov    -0x4(%eax),%eax
  800500:	89 c2                	mov    %eax,%edx
  800502:	c1 fa 1f             	sar    $0x1f,%edx
  800505:	31 d0                	xor    %edx,%eax
  800507:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800509:	83 f8 08             	cmp    $0x8,%eax
  80050c:	7f 0b                	jg     800519 <vprintfmt+0x159>
  80050e:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  800515:	85 d2                	test   %edx,%edx
  800517:	75 20                	jne    800539 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051d:	c7 44 24 08 d9 12 80 	movl   $0x8012d9,0x8(%esp)
  800524:	00 
  800525:	89 74 24 04          	mov    %esi,0x4(%esp)
  800529:	89 3c 24             	mov    %edi,(%esp)
  80052c:	e8 37 03 00 00       	call   800868 <printfmt>
  800531:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800534:	e9 b3 fe ff ff       	jmp    8003ec <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800539:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053d:	c7 44 24 08 e2 12 80 	movl   $0x8012e2,0x8(%esp)
  800544:	00 
  800545:	89 74 24 04          	mov    %esi,0x4(%esp)
  800549:	89 3c 24             	mov    %edi,(%esp)
  80054c:	e8 17 03 00 00       	call   800868 <printfmt>
  800551:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800554:	e9 93 fe ff ff       	jmp    8003ec <vprintfmt+0x2c>
  800559:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80055c:	89 c3                	mov    %eax,%ebx
  80055e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800561:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800564:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	83 c0 04             	add    $0x4,%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
  800570:	8b 40 fc             	mov    -0x4(%eax),%eax
  800573:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800576:	85 c0                	test   %eax,%eax
  800578:	b8 e5 12 80 00       	mov    $0x8012e5,%eax
  80057d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  800581:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800584:	85 c9                	test   %ecx,%ecx
  800586:	7e 06                	jle    80058e <vprintfmt+0x1ce>
  800588:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058c:	75 13                	jne    8005a1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800591:	0f be 02             	movsbl (%edx),%eax
  800594:	85 c0                	test   %eax,%eax
  800596:	0f 85 99 00 00 00    	jne    800635 <vprintfmt+0x275>
  80059c:	e9 86 00 00 00       	jmp    800627 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a8:	89 0c 24             	mov    %ecx,(%esp)
  8005ab:	e8 fb 02 00 00       	call   8008ab <strnlen>
  8005b0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005b3:	29 c2                	sub    %eax,%edx
  8005b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	7e d2                	jle    80058e <vprintfmt+0x1ce>
					putch(padc, putdat);
  8005bc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005c0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005c3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005c6:	89 d3                	mov    %edx,%ebx
  8005c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	83 eb 01             	sub    $0x1,%ebx
  8005d7:	85 db                	test   %ebx,%ebx
  8005d9:	7f ed                	jg     8005c8 <vprintfmt+0x208>
  8005db:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005e5:	eb a7                	jmp    80058e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005eb:	74 18                	je     800605 <vprintfmt+0x245>
  8005ed:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005f0:	83 fa 5e             	cmp    $0x5e,%edx
  8005f3:	76 10                	jbe    800605 <vprintfmt+0x245>
					putch('?', putdat);
  8005f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800600:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800603:	eb 0a                	jmp    80060f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	89 04 24             	mov    %eax,(%esp)
  80060c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800613:	0f be 03             	movsbl (%ebx),%eax
  800616:	85 c0                	test   %eax,%eax
  800618:	74 05                	je     80061f <vprintfmt+0x25f>
  80061a:	83 c3 01             	add    $0x1,%ebx
  80061d:	eb 29                	jmp    800648 <vprintfmt+0x288>
  80061f:	89 fe                	mov    %edi,%esi
  800621:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800624:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800627:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062b:	7f 2e                	jg     80065b <vprintfmt+0x29b>
  80062d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800630:	e9 b7 fd ff ff       	jmp    8003ec <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800635:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800638:	83 c2 01             	add    $0x1,%edx
  80063b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80063e:	89 f7                	mov    %esi,%edi
  800640:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800643:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800646:	89 d3                	mov    %edx,%ebx
  800648:	85 f6                	test   %esi,%esi
  80064a:	78 9b                	js     8005e7 <vprintfmt+0x227>
  80064c:	83 ee 01             	sub    $0x1,%esi
  80064f:	79 96                	jns    8005e7 <vprintfmt+0x227>
  800651:	89 fe                	mov    %edi,%esi
  800653:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800656:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800659:	eb cc                	jmp    800627 <vprintfmt+0x267>
  80065b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80065e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800661:	89 74 24 04          	mov    %esi,0x4(%esp)
  800665:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80066c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066e:	83 eb 01             	sub    $0x1,%ebx
  800671:	85 db                	test   %ebx,%ebx
  800673:	7f ec                	jg     800661 <vprintfmt+0x2a1>
  800675:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800678:	e9 6f fd ff ff       	jmp    8003ec <vprintfmt+0x2c>
  80067d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800680:	83 f9 01             	cmp    $0x1,%ecx
  800683:	7e 17                	jle    80069c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	83 c0 08             	add    $0x8,%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
  80068e:	8b 50 f8             	mov    -0x8(%eax),%edx
  800691:	8b 48 fc             	mov    -0x4(%eax),%ecx
  800694:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800697:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80069a:	eb 34                	jmp    8006d0 <vprintfmt+0x310>
	else if (lflag)
  80069c:	85 c9                	test   %ecx,%ecx
  80069e:	74 19                	je     8006b9 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	83 c0 04             	add    $0x4,%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a9:	8b 40 fc             	mov    -0x4(%eax),%eax
  8006ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006af:	89 c1                	mov    %eax,%ecx
  8006b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b7:	eb 17                	jmp    8006d0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	83 c0 04             	add    $0x4,%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c2:	8b 40 fc             	mov    -0x4(%eax),%eax
  8006c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	c1 fa 1f             	sar    $0x1f,%edx
  8006cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006d6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006db:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006df:	0f 89 9c 00 00 00    	jns    800781 <vprintfmt+0x3c1>
				putch('-', putdat);
  8006e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f0:	ff d7                	call   *%edi
				num = -(long long) num;
  8006f2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006f5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006f8:	f7 d9                	neg    %ecx
  8006fa:	83 d3 00             	adc    $0x0,%ebx
  8006fd:	f7 db                	neg    %ebx
  8006ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800704:	eb 7b                	jmp    800781 <vprintfmt+0x3c1>
  800706:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800709:	89 ca                	mov    %ecx,%edx
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	e8 53 fc ff ff       	call   800366 <getuint>
  800713:	89 c1                	mov    %eax,%ecx
  800715:	89 d3                	mov    %edx,%ebx
  800717:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80071c:	eb 63                	jmp    800781 <vprintfmt+0x3c1>
  80071e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800721:	89 ca                	mov    %ecx,%edx
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	e8 3b fc ff ff       	call   800366 <getuint>
  80072b:	89 c1                	mov    %eax,%ecx
  80072d:	89 d3                	mov    %edx,%ebx
  80072f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800734:	eb 4b                	jmp    800781 <vprintfmt+0x3c1>
  800736:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800739:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800744:	ff d7                	call   *%edi
			putch('x', putdat);
  800746:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800751:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	83 c0 04             	add    $0x4,%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  80075f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800764:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800769:	eb 16                	jmp    800781 <vprintfmt+0x3c1>
  80076b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076e:	89 ca                	mov    %ecx,%edx
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
  800773:	e8 ee fb ff ff       	call   800366 <getuint>
  800778:	89 c1                	mov    %eax,%ecx
  80077a:	89 d3                	mov    %edx,%ebx
  80077c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800781:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800785:	89 54 24 10          	mov    %edx,0x10(%esp)
  800789:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80078c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800790:	89 44 24 08          	mov    %eax,0x8(%esp)
  800794:	89 0c 24             	mov    %ecx,(%esp)
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	89 f2                	mov    %esi,%edx
  80079d:	89 f8                	mov    %edi,%eax
  80079f:	e8 cc fa ff ff       	call   800270 <printnum>
  8007a4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007a7:	e9 40 fc ff ff       	jmp    8003ec <vprintfmt+0x2c>
  8007ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007af:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b6:	89 14 24             	mov    %edx,(%esp)
  8007b9:	ff d7                	call   *%edi
  8007bb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007be:	e9 29 fc ff ff       	jmp    8003ec <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ce:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007d3:	80 38 25             	cmpb   $0x25,(%eax)
  8007d6:	0f 84 10 fc ff ff    	je     8003ec <vprintfmt+0x2c>
  8007dc:	89 c3                	mov    %eax,%ebx
  8007de:	eb f0                	jmp    8007d0 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  8007e0:	83 c4 5c             	add    $0x5c,%esp
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5f                   	pop    %edi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	83 ec 28             	sub    $0x28,%esp
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	74 04                	je     8007fc <vsnprintf+0x14>
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	7f 07                	jg     800803 <vsnprintf+0x1b>
  8007fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800801:	eb 3b                	jmp    80083e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800803:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800806:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80080a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80080d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081b:	8b 45 10             	mov    0x10(%ebp),%eax
  80081e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800822:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800825:	89 44 24 04          	mov    %eax,0x4(%esp)
  800829:	c7 04 24 a3 03 80 00 	movl   $0x8003a3,(%esp)
  800830:	e8 8b fb ff ff       	call   8003c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800835:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800838:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084d:	8b 45 10             	mov    0x10(%ebp),%eax
  800850:	89 44 24 08          	mov    %eax,0x8(%esp)
  800854:	8b 45 0c             	mov    0xc(%ebp),%eax
  800857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	89 04 24             	mov    %eax,(%esp)
  800861:	e8 82 ff ff ff       	call   8007e8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80086e:	8d 45 14             	lea    0x14(%ebp),%eax
  800871:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800875:	8b 45 10             	mov    0x10(%ebp),%eax
  800878:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 32 fb ff ff       	call   8003c0 <vprintfmt>
	va_end(ap);
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	80 3a 00             	cmpb   $0x0,(%edx)
  80089e:	74 09                	je     8008a9 <strlen+0x19>
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	75 f7                	jne    8008a0 <strlen+0x10>
		n++;
	return n;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	74 19                	je     8008d2 <strnlen+0x27>
  8008b9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008bc:	74 14                	je     8008d2 <strnlen+0x27>
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008c3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c6:	39 c8                	cmp    %ecx,%eax
  8008c8:	74 0d                	je     8008d7 <strnlen+0x2c>
  8008ca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008ce:	75 f3                	jne    8008c3 <strnlen+0x18>
  8008d0:	eb 05                	jmp    8008d7 <strnlen+0x2c>
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	53                   	push   %ebx
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	84 c9                	test   %cl,%cl
  8008f5:	75 f2                	jne    8008e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800908:	85 f6                	test   %esi,%esi
  80090a:	74 18                	je     800924 <strncpy+0x2a>
  80090c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800911:	0f b6 1a             	movzbl (%edx),%ebx
  800914:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800917:	80 3a 01             	cmpb   $0x1,(%edx)
  80091a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091d:	83 c1 01             	add    $0x1,%ecx
  800920:	39 ce                	cmp    %ecx,%esi
  800922:	77 ed                	ja     800911 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 75 08             	mov    0x8(%ebp),%esi
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800936:	89 f0                	mov    %esi,%eax
  800938:	85 c9                	test   %ecx,%ecx
  80093a:	74 27                	je     800963 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80093c:	83 e9 01             	sub    $0x1,%ecx
  80093f:	74 1d                	je     80095e <strlcpy+0x36>
  800941:	0f b6 1a             	movzbl (%edx),%ebx
  800944:	84 db                	test   %bl,%bl
  800946:	74 16                	je     80095e <strlcpy+0x36>
			*dst++ = *src++;
  800948:	88 18                	mov    %bl,(%eax)
  80094a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094d:	83 e9 01             	sub    $0x1,%ecx
  800950:	74 0e                	je     800960 <strlcpy+0x38>
			*dst++ = *src++;
  800952:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800955:	0f b6 1a             	movzbl (%edx),%ebx
  800958:	84 db                	test   %bl,%bl
  80095a:	75 ec                	jne    800948 <strlcpy+0x20>
  80095c:	eb 02                	jmp    800960 <strlcpy+0x38>
  80095e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800960:	c6 00 00             	movb   $0x0,(%eax)
  800963:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	84 c0                	test   %al,%al
  800977:	74 15                	je     80098e <strcmp+0x25>
  800979:	3a 02                	cmp    (%edx),%al
  80097b:	75 11                	jne    80098e <strcmp+0x25>
		p++, q++;
  80097d:	83 c1 01             	add    $0x1,%ecx
  800980:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800983:	0f b6 01             	movzbl (%ecx),%eax
  800986:	84 c0                	test   %al,%al
  800988:	74 04                	je     80098e <strcmp+0x25>
  80098a:	3a 02                	cmp    (%edx),%al
  80098c:	74 ef                	je     80097d <strcmp+0x14>
  80098e:	0f b6 c0             	movzbl %al,%eax
  800991:	0f b6 12             	movzbl (%edx),%edx
  800994:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	53                   	push   %ebx
  80099c:	8b 55 08             	mov    0x8(%ebp),%edx
  80099f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009a5:	85 c0                	test   %eax,%eax
  8009a7:	74 23                	je     8009cc <strncmp+0x34>
  8009a9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ac:	84 db                	test   %bl,%bl
  8009ae:	74 24                	je     8009d4 <strncmp+0x3c>
  8009b0:	3a 19                	cmp    (%ecx),%bl
  8009b2:	75 20                	jne    8009d4 <strncmp+0x3c>
  8009b4:	83 e8 01             	sub    $0x1,%eax
  8009b7:	74 13                	je     8009cc <strncmp+0x34>
		n--, p++, q++;
  8009b9:	83 c2 01             	add    $0x1,%edx
  8009bc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009bf:	0f b6 1a             	movzbl (%edx),%ebx
  8009c2:	84 db                	test   %bl,%bl
  8009c4:	74 0e                	je     8009d4 <strncmp+0x3c>
  8009c6:	3a 19                	cmp    (%ecx),%bl
  8009c8:	74 ea                	je     8009b4 <strncmp+0x1c>
  8009ca:	eb 08                	jmp    8009d4 <strncmp+0x3c>
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d4:	0f b6 02             	movzbl (%edx),%eax
  8009d7:	0f b6 11             	movzbl (%ecx),%edx
  8009da:	29 d0                	sub    %edx,%eax
  8009dc:	eb f3                	jmp    8009d1 <strncmp+0x39>

008009de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e8:	0f b6 10             	movzbl (%eax),%edx
  8009eb:	84 d2                	test   %dl,%dl
  8009ed:	74 15                	je     800a04 <strchr+0x26>
		if (*s == c)
  8009ef:	38 ca                	cmp    %cl,%dl
  8009f1:	75 07                	jne    8009fa <strchr+0x1c>
  8009f3:	eb 14                	jmp    800a09 <strchr+0x2b>
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	90                   	nop
  8009f8:	74 0f                	je     800a09 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 f1                	jne    8009f5 <strchr+0x17>
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	0f b6 10             	movzbl (%eax),%edx
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	74 18                	je     800a34 <strfind+0x29>
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	75 0a                	jne    800a2a <strfind+0x1f>
  800a20:	eb 12                	jmp    800a34 <strfind+0x29>
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a28:	74 0a                	je     800a34 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 ee                	jne    800a22 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	53                   	push   %ebx
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a43:	89 da                	mov    %ebx,%edx
  800a45:	83 ea 01             	sub    $0x1,%edx
  800a48:	78 0d                	js     800a57 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  800a4a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a4c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a4e:	88 0a                	mov    %cl,(%edx)
  800a50:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a53:	39 da                	cmp    %ebx,%edx
  800a55:	75 f7                	jne    800a4e <memset+0x18>
		*p++ = c;

	return v;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a68:	85 db                	test   %ebx,%ebx
  800a6a:	74 13                	je     800a7f <memcpy+0x25>
  800a6c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800a71:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a75:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a78:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a7b:	39 da                	cmp    %ebx,%edx
  800a7d:	75 f2                	jne    800a71 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800a92:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800a94:	39 c6                	cmp    %eax,%esi
  800a96:	72 0b                	jb     800aa3 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800a9d:	85 db                	test   %ebx,%ebx
  800a9f:	75 2e                	jne    800acf <memmove+0x4c>
  800aa1:	eb 3a                	jmp    800add <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa3:	01 df                	add    %ebx,%edi
  800aa5:	39 f8                	cmp    %edi,%eax
  800aa7:	73 ef                	jae    800a98 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	90                   	nop
  800aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ab0:	74 2b                	je     800add <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800ab2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800ab5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800aba:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800abf:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800ac3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800ac6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800ac9:	85 c9                	test   %ecx,%ecx
  800acb:	75 ed                	jne    800aba <memmove+0x37>
  800acd:	eb 0e                	jmp    800add <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800acf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ad3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ad6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800ad9:	39 d3                	cmp    %edx,%ebx
  800adb:	75 f2                	jne    800acf <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 75 08             	mov    0x8(%ebp),%esi
  800aeb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800aee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af1:	85 c9                	test   %ecx,%ecx
  800af3:	74 36                	je     800b2b <memcmp+0x49>
		if (*s1 != *s2)
  800af5:	0f b6 06             	movzbl (%esi),%eax
  800af8:	0f b6 1f             	movzbl (%edi),%ebx
  800afb:	38 d8                	cmp    %bl,%al
  800afd:	74 20                	je     800b1f <memcmp+0x3d>
  800aff:	eb 14                	jmp    800b15 <memcmp+0x33>
  800b01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b0b:	83 c2 01             	add    $0x1,%edx
  800b0e:	83 e9 01             	sub    $0x1,%ecx
  800b11:	38 d8                	cmp    %bl,%al
  800b13:	74 12                	je     800b27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b15:	0f b6 c0             	movzbl %al,%eax
  800b18:	0f b6 db             	movzbl %bl,%ebx
  800b1b:	29 d8                	sub    %ebx,%eax
  800b1d:	eb 11                	jmp    800b30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1f:	83 e9 01             	sub    $0x1,%ecx
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	85 c9                	test   %ecx,%ecx
  800b29:	75 d6                	jne    800b01 <memcmp+0x1f>
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b40:	39 d0                	cmp    %edx,%eax
  800b42:	73 15                	jae    800b59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b48:	38 08                	cmp    %cl,(%eax)
  800b4a:	75 06                	jne    800b52 <memfind+0x1d>
  800b4c:	eb 0b                	jmp    800b59 <memfind+0x24>
  800b4e:	38 08                	cmp    %cl,(%eax)
  800b50:	74 07                	je     800b59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	39 c2                	cmp    %eax,%edx
  800b57:	77 f5                	ja     800b4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 04             	sub    $0x4,%esp
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6a:	0f b6 02             	movzbl (%edx),%eax
  800b6d:	3c 20                	cmp    $0x20,%al
  800b6f:	74 04                	je     800b75 <strtol+0x1a>
  800b71:	3c 09                	cmp    $0x9,%al
  800b73:	75 0e                	jne    800b83 <strtol+0x28>
		s++;
  800b75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b78:	0f b6 02             	movzbl (%edx),%eax
  800b7b:	3c 20                	cmp    $0x20,%al
  800b7d:	74 f6                	je     800b75 <strtol+0x1a>
  800b7f:	3c 09                	cmp    $0x9,%al
  800b81:	74 f2                	je     800b75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b83:	3c 2b                	cmp    $0x2b,%al
  800b85:	75 0c                	jne    800b93 <strtol+0x38>
		s++;
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b91:	eb 15                	jmp    800ba8 <strtol+0x4d>
	else if (*s == '-')
  800b93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b9a:	3c 2d                	cmp    $0x2d,%al
  800b9c:	75 0a                	jne    800ba8 <strtol+0x4d>
		s++, neg = 1;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba8:	85 db                	test   %ebx,%ebx
  800baa:	0f 94 c0             	sete   %al
  800bad:	74 05                	je     800bb4 <strtol+0x59>
  800baf:	83 fb 10             	cmp    $0x10,%ebx
  800bb2:	75 18                	jne    800bcc <strtol+0x71>
  800bb4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb7:	75 13                	jne    800bcc <strtol+0x71>
  800bb9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bbd:	8d 76 00             	lea    0x0(%esi),%esi
  800bc0:	75 0a                	jne    800bcc <strtol+0x71>
		s += 2, base = 16;
  800bc2:	83 c2 02             	add    $0x2,%edx
  800bc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bca:	eb 15                	jmp    800be1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcc:	84 c0                	test   %al,%al
  800bce:	66 90                	xchg   %ax,%ax
  800bd0:	74 0f                	je     800be1 <strtol+0x86>
  800bd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bda:	75 05                	jne    800be1 <strtol+0x86>
		s++, base = 8;
  800bdc:	83 c2 01             	add    $0x1,%edx
  800bdf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be8:	0f b6 0a             	movzbl (%edx),%ecx
  800beb:	89 cf                	mov    %ecx,%edi
  800bed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bf0:	80 fb 09             	cmp    $0x9,%bl
  800bf3:	77 08                	ja     800bfd <strtol+0xa2>
			dig = *s - '0';
  800bf5:	0f be c9             	movsbl %cl,%ecx
  800bf8:	83 e9 30             	sub    $0x30,%ecx
  800bfb:	eb 1e                	jmp    800c1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 57             	sub    $0x57,%ecx
  800c0b:	eb 0e                	jmp    800c1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 15                	ja     800c2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c1b:	39 f1                	cmp    %esi,%ecx
  800c1d:	7d 0b                	jge    800c2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c1f:	83 c2 01             	add    $0x1,%edx
  800c22:	0f af c6             	imul   %esi,%eax
  800c25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c28:	eb be                	jmp    800be8 <strtol+0x8d>
  800c2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c30:	74 05                	je     800c37 <strtol+0xdc>
		*endptr = (char *) s;
  800c32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c37:	89 ca                	mov    %ecx,%edx
  800c39:	f7 da                	neg    %edx
  800c3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c3f:	0f 45 c2             	cmovne %edx,%eax
}
  800c42:	83 c4 04             	add    $0x4,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
	...

00800c4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	89 1c 24             	mov    %ebx,(%esp)
  800c55:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c59:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 c3                	mov    %eax,%ebx
  800c6a:	89 c7                	mov    %eax,%edi
  800c6c:	89 c6                	mov    %eax,%esi
  800c6e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800c70:	8b 1c 24             	mov    (%esp),%ebx
  800c73:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c77:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c7b:	89 ec                	mov    %ebp,%esp
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	89 1c 24             	mov    %ebx,(%esp)
  800c88:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c8c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	ba 00 00 00 00       	mov    $0x0,%edx
  800c95:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9a:	89 d1                	mov    %edx,%ecx
  800c9c:	89 d3                	mov    %edx,%ebx
  800c9e:	89 d7                	mov    %edx,%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800ca4:	8b 1c 24             	mov    (%esp),%ebx
  800ca7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cab:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800caf:	89 ec                	mov    %ebp,%esp
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	89 1c 24             	mov    %ebx,(%esp)
  800cbc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cc0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 cb                	mov    %ecx,%ebx
  800cd3:	89 cf                	mov    %ecx,%edi
  800cd5:	89 ce                	mov    %ecx,%esi
  800cd7:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800cd9:	8b 1c 24             	mov    (%esp),%ebx
  800cdc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ce0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce4:	89 ec                	mov    %ebp,%esp
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	89 1c 24             	mov    %ebx,(%esp)
  800cf1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfe:	b8 02 00 00 00       	mov    $0x2,%eax
  800d03:	89 d1                	mov    %edx,%ecx
  800d05:	89 d3                	mov    %edx,%ebx
  800d07:	89 d7                	mov    %edx,%edi
  800d09:	89 d6                	mov    %edx,%esi
  800d0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800d0d:	8b 1c 24             	mov    (%esp),%ebx
  800d10:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d14:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d18:	89 ec                	mov    %ebp,%esp
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_yield>:

void
sys_yield(void)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	89 1c 24             	mov    %ebx,(%esp)
  800d25:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d29:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d32:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d37:	89 d1                	mov    %edx,%ecx
  800d39:	89 d3                	mov    %edx,%ebx
  800d3b:	89 d7                	mov    %edx,%edi
  800d3d:	89 d6                	mov    %edx,%esi
  800d3f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800d41:	8b 1c 24             	mov    (%esp),%ebx
  800d44:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d48:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d4c:	89 ec                	mov    %ebp,%esp
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	89 1c 24             	mov    %ebx,(%esp)
  800d59:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d5d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d61:	be 00 00 00 00       	mov    $0x0,%esi
  800d66:	b8 04 00 00 00       	mov    $0x4,%eax
  800d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 f7                	mov    %esi,%edi
  800d76:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800d78:	8b 1c 24             	mov    (%esp),%ebx
  800d7b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d7f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d83:	89 ec                	mov    %ebp,%esp
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	89 1c 24             	mov    %ebx,(%esp)
  800d90:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d94:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d98:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9d:	8b 75 18             	mov    0x18(%ebp),%esi
  800da0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dae:	8b 1c 24             	mov    (%esp),%ebx
  800db1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800db5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800db9:	89 ec                	mov    %ebp,%esp
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	89 1c 24             	mov    %ebx,(%esp)
  800dc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dca:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd3:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 df                	mov    %ebx,%edi
  800de0:	89 de                	mov    %ebx,%esi
  800de2:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800de4:	8b 1c 24             	mov    (%esp),%ebx
  800de7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800deb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800def:	89 ec                	mov    %ebp,%esp
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	89 1c 24             	mov    %ebx,(%esp)
  800dfc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e00:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e09:	b8 08 00 00 00       	mov    $0x8,%eax
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	89 df                	mov    %ebx,%edi
  800e16:	89 de                	mov    %ebx,%esi
  800e18:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800e1a:	8b 1c 24             	mov    (%esp),%ebx
  800e1d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e21:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e25:	89 ec                	mov    %ebp,%esp
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	89 1c 24             	mov    %ebx,(%esp)
  800e32:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e36:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e47:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4a:	89 df                	mov    %ebx,%edi
  800e4c:	89 de                	mov    %ebx,%esi
  800e4e:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800e50:	8b 1c 24             	mov    (%esp),%ebx
  800e53:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e57:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e5b:	89 ec                	mov    %ebp,%esp
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 0c             	sub    $0xc,%esp
  800e65:	89 1c 24             	mov    %ebx,(%esp)
  800e68:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	89 df                	mov    %ebx,%edi
  800e82:	89 de                	mov    %ebx,%esi
  800e84:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e86:	8b 1c 24             	mov    (%esp),%ebx
  800e89:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e91:	89 ec                	mov    %ebp,%esp
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 0c             	sub    $0xc,%esp
  800e9b:	89 1c 24             	mov    %ebx,(%esp)
  800e9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	be 00 00 00 00       	mov    $0x0,%esi
  800eab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800ebe:	8b 1c 24             	mov    (%esp),%ebx
  800ec1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ec5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ec9:	89 ec                	mov    %ebp,%esp
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	89 1c 24             	mov    %ebx,(%esp)
  800ed6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eda:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eeb:	89 cb                	mov    %ecx,%ebx
  800eed:	89 cf                	mov    %ecx,%edi
  800eef:	89 ce                	mov    %ecx,%esi
  800ef1:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800ef3:	8b 1c 24             	mov    (%esp),%ebx
  800ef6:	8b 74 24 04          	mov    0x4(%esp),%esi
  800efa:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800efe:	89 ec                	mov    %ebp,%esp
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
	...

00800f04 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f0a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800f11:	75 54                	jne    800f67 <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  800f13:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f22:	ee 
  800f23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2a:	e8 21 fe ff ff       	call   800d50 <sys_page_alloc>
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	79 20                	jns    800f53 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  800f33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f37:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 1c 15 80 00 	movl   $0x80151c,(%esp)
  800f4e:	e8 f9 f1 ff ff       	call   80014c <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  800f53:	c7 44 24 04 74 0f 80 	movl   $0x800f74,0x4(%esp)
  800f5a:	00 
  800f5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f62:	e8 f8 fe ff ff       	call   800e5f <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    
  800f71:	00 00                	add    %al,(%eax)
	...

00800f74 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f74:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f75:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  800f7a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f7c:	83 c4 04             	add    $0x4,%esp
	// Hints:
	//   What registers are available for intermediate calculations?
	//
	// LAB 4: Your code here.
	
	movl	0x30(%esp), %eax
  800f7f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl	$0x4, %eax
  800f83:	83 e8 04             	sub    $0x4,%eax
	movl	%eax, 0x30(%esp)
  800f86:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl	0x28(%esp), %ebx
  800f8a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl	%ebx, (%eax)
  800f8e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.
	// LAB 4: Your code here.

	addl	$0x8, %esp
  800f90:	83 c4 08             	add    $0x8,%esp
	popal
  800f93:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.

	addl	$0x4, %esp
  800f94:	83 c4 04             	add    $0x4,%esp
	popfl
  800f97:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	pop	%esp
  800f98:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800f99:	c3                   	ret    
  800f9a:	00 00                	add    %al,(%eax)
  800f9c:	00 00                	add    %al,(%eax)
	...

00800fa0 <__udivdi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	83 ec 10             	sub    $0x10,%esp
  800fa8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fab:	8b 55 08             	mov    0x8(%ebp),%edx
  800fae:	8b 75 10             	mov    0x10(%ebp),%esi
  800fb1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800fb9:	75 35                	jne    800ff0 <__udivdi3+0x50>
  800fbb:	39 fe                	cmp    %edi,%esi
  800fbd:	77 61                	ja     801020 <__udivdi3+0x80>
  800fbf:	85 f6                	test   %esi,%esi
  800fc1:	75 0b                	jne    800fce <__udivdi3+0x2e>
  800fc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc8:	31 d2                	xor    %edx,%edx
  800fca:	f7 f6                	div    %esi
  800fcc:	89 c6                	mov    %eax,%esi
  800fce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	89 f8                	mov    %edi,%eax
  800fd5:	f7 f6                	div    %esi
  800fd7:	89 c7                	mov    %eax,%edi
  800fd9:	89 c8                	mov    %ecx,%eax
  800fdb:	f7 f6                	div    %esi
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	89 fa                	mov    %edi,%edx
  800fe1:	89 c8                	mov    %ecx,%eax
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    
  800fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ff0:	39 f8                	cmp    %edi,%eax
  800ff2:	77 1c                	ja     801010 <__udivdi3+0x70>
  800ff4:	0f bd d0             	bsr    %eax,%edx
  800ff7:	83 f2 1f             	xor    $0x1f,%edx
  800ffa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800ffd:	75 39                	jne    801038 <__udivdi3+0x98>
  800fff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801002:	0f 86 a0 00 00 00    	jbe    8010a8 <__udivdi3+0x108>
  801008:	39 f8                	cmp    %edi,%eax
  80100a:	0f 82 98 00 00 00    	jb     8010a8 <__udivdi3+0x108>
  801010:	31 ff                	xor    %edi,%edi
  801012:	31 c9                	xor    %ecx,%ecx
  801014:	89 c8                	mov    %ecx,%eax
  801016:	89 fa                	mov    %edi,%edx
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    
  80101f:	90                   	nop
  801020:	89 d1                	mov    %edx,%ecx
  801022:	89 fa                	mov    %edi,%edx
  801024:	89 c8                	mov    %ecx,%eax
  801026:	31 ff                	xor    %edi,%edi
  801028:	f7 f6                	div    %esi
  80102a:	89 c1                	mov    %eax,%ecx
  80102c:	89 fa                	mov    %edi,%edx
  80102e:	89 c8                	mov    %ecx,%eax
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	5e                   	pop    %esi
  801034:	5f                   	pop    %edi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    
  801037:	90                   	nop
  801038:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80103c:	89 f2                	mov    %esi,%edx
  80103e:	d3 e0                	shl    %cl,%eax
  801040:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801043:	b8 20 00 00 00       	mov    $0x20,%eax
  801048:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80104b:	89 c1                	mov    %eax,%ecx
  80104d:	d3 ea                	shr    %cl,%edx
  80104f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801053:	0b 55 ec             	or     -0x14(%ebp),%edx
  801056:	d3 e6                	shl    %cl,%esi
  801058:	89 c1                	mov    %eax,%ecx
  80105a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80105d:	89 fe                	mov    %edi,%esi
  80105f:	d3 ee                	shr    %cl,%esi
  801061:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801065:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801068:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80106b:	d3 e7                	shl    %cl,%edi
  80106d:	89 c1                	mov    %eax,%ecx
  80106f:	d3 ea                	shr    %cl,%edx
  801071:	09 d7                	or     %edx,%edi
  801073:	89 f2                	mov    %esi,%edx
  801075:	89 f8                	mov    %edi,%eax
  801077:	f7 75 ec             	divl   -0x14(%ebp)
  80107a:	89 d6                	mov    %edx,%esi
  80107c:	89 c7                	mov    %eax,%edi
  80107e:	f7 65 e8             	mull   -0x18(%ebp)
  801081:	39 d6                	cmp    %edx,%esi
  801083:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801086:	72 30                	jb     8010b8 <__udivdi3+0x118>
  801088:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80108f:	d3 e2                	shl    %cl,%edx
  801091:	39 c2                	cmp    %eax,%edx
  801093:	73 05                	jae    80109a <__udivdi3+0xfa>
  801095:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801098:	74 1e                	je     8010b8 <__udivdi3+0x118>
  80109a:	89 f9                	mov    %edi,%ecx
  80109c:	31 ff                	xor    %edi,%edi
  80109e:	e9 71 ff ff ff       	jmp    801014 <__udivdi3+0x74>
  8010a3:	90                   	nop
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	31 ff                	xor    %edi,%edi
  8010aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010af:	e9 60 ff ff ff       	jmp    801014 <__udivdi3+0x74>
  8010b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010bb:	31 ff                	xor    %edi,%edi
  8010bd:	89 c8                	mov    %ecx,%eax
  8010bf:	89 fa                	mov    %edi,%edx
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    
	...

008010d0 <__umoddi3>:
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	57                   	push   %edi
  8010d4:	56                   	push   %esi
  8010d5:	83 ec 20             	sub    $0x20,%esp
  8010d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8010db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8010e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e4:	85 d2                	test   %edx,%edx
  8010e6:	89 c8                	mov    %ecx,%eax
  8010e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010eb:	75 13                	jne    801100 <__umoddi3+0x30>
  8010ed:	39 f7                	cmp    %esi,%edi
  8010ef:	76 3f                	jbe    801130 <__umoddi3+0x60>
  8010f1:	89 f2                	mov    %esi,%edx
  8010f3:	f7 f7                	div    %edi
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	31 d2                	xor    %edx,%edx
  8010f9:	83 c4 20             	add    $0x20,%esp
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    
  801100:	39 f2                	cmp    %esi,%edx
  801102:	77 4c                	ja     801150 <__umoddi3+0x80>
  801104:	0f bd ca             	bsr    %edx,%ecx
  801107:	83 f1 1f             	xor    $0x1f,%ecx
  80110a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80110d:	75 51                	jne    801160 <__umoddi3+0x90>
  80110f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801112:	0f 87 e0 00 00 00    	ja     8011f8 <__umoddi3+0x128>
  801118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111b:	29 f8                	sub    %edi,%eax
  80111d:	19 d6                	sbb    %edx,%esi
  80111f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801122:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801125:	89 f2                	mov    %esi,%edx
  801127:	83 c4 20             	add    $0x20,%esp
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    
  80112e:	66 90                	xchg   %ax,%ax
  801130:	85 ff                	test   %edi,%edi
  801132:	75 0b                	jne    80113f <__umoddi3+0x6f>
  801134:	b8 01 00 00 00       	mov    $0x1,%eax
  801139:	31 d2                	xor    %edx,%edx
  80113b:	f7 f7                	div    %edi
  80113d:	89 c7                	mov    %eax,%edi
  80113f:	89 f0                	mov    %esi,%eax
  801141:	31 d2                	xor    %edx,%edx
  801143:	f7 f7                	div    %edi
  801145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801148:	f7 f7                	div    %edi
  80114a:	eb a9                	jmp    8010f5 <__umoddi3+0x25>
  80114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801150:	89 c8                	mov    %ecx,%eax
  801152:	89 f2                	mov    %esi,%edx
  801154:	83 c4 20             	add    $0x20,%esp
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    
  80115b:	90                   	nop
  80115c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801160:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801164:	d3 e2                	shl    %cl,%edx
  801166:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801169:	ba 20 00 00 00       	mov    $0x20,%edx
  80116e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801171:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801174:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801178:	89 fa                	mov    %edi,%edx
  80117a:	d3 ea                	shr    %cl,%edx
  80117c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801180:	0b 55 f4             	or     -0xc(%ebp),%edx
  801183:	d3 e7                	shl    %cl,%edi
  801185:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801189:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80118c:	89 f2                	mov    %esi,%edx
  80118e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801191:	89 c7                	mov    %eax,%edi
  801193:	d3 ea                	shr    %cl,%edx
  801195:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801199:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80119c:	89 c2                	mov    %eax,%edx
  80119e:	d3 e6                	shl    %cl,%esi
  8011a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011a4:	d3 ea                	shr    %cl,%edx
  8011a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011aa:	09 d6                	or     %edx,%esi
  8011ac:	89 f0                	mov    %esi,%eax
  8011ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011b1:	d3 e7                	shl    %cl,%edi
  8011b3:	89 f2                	mov    %esi,%edx
  8011b5:	f7 75 f4             	divl   -0xc(%ebp)
  8011b8:	89 d6                	mov    %edx,%esi
  8011ba:	f7 65 e8             	mull   -0x18(%ebp)
  8011bd:	39 d6                	cmp    %edx,%esi
  8011bf:	72 2b                	jb     8011ec <__umoddi3+0x11c>
  8011c1:	39 c7                	cmp    %eax,%edi
  8011c3:	72 23                	jb     8011e8 <__umoddi3+0x118>
  8011c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011c9:	29 c7                	sub    %eax,%edi
  8011cb:	19 d6                	sbb    %edx,%esi
  8011cd:	89 f0                	mov    %esi,%eax
  8011cf:	89 f2                	mov    %esi,%edx
  8011d1:	d3 ef                	shr    %cl,%edi
  8011d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011d7:	d3 e0                	shl    %cl,%eax
  8011d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011dd:	09 f8                	or     %edi,%eax
  8011df:	d3 ea                	shr    %cl,%edx
  8011e1:	83 c4 20             	add    $0x20,%esp
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    
  8011e8:	39 d6                	cmp    %edx,%esi
  8011ea:	75 d9                	jne    8011c5 <__umoddi3+0xf5>
  8011ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8011ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8011f2:	eb d1                	jmp    8011c5 <__umoddi3+0xf5>
  8011f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	39 f2                	cmp    %esi,%edx
  8011fa:	0f 82 18 ff ff ff    	jb     801118 <__umoddi3+0x48>
  801200:	e9 1d ff ff ff       	jmp    801122 <__umoddi3+0x52>
