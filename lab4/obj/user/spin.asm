
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

#include <inc/lib.h>

void
umain(void)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 a0 15 80 00 	movl   $0x8015a0,(%esp)
  80004e:	e8 36 01 00 00       	call   800189 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 4d 0f 00 00       	call   800fa5 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 18 16 80 00 	movl   $0x801618,(%esp)
  800065:	e8 1f 01 00 00       	call   800189 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  800073:	e8 11 01 00 00       	call   800189 <cprintf>
	sys_yield();
  800078:	e8 1f 0c 00 00       	call   800c9c <sys_yield>
	sys_yield();
  80007d:	e8 1a 0c 00 00       	call   800c9c <sys_yield>
	sys_yield();
  800082:	e8 15 0c 00 00       	call   800c9c <sys_yield>
	sys_yield();
  800087:	e8 10 0c 00 00       	call   800c9c <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 07 0c 00 00       	call   800c9c <sys_yield>
	sys_yield();
  800095:	e8 02 0c 00 00       	call   800c9c <sys_yield>
	sys_yield();
  80009a:	e8 fd 0b 00 00       	call   800c9c <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 f7 0b 00 00       	call   800c9c <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  8000ac:	e8 d8 00 00 00       	call   800189 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 7a 0b 00 00       	call   800c33 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
	...

008000c0 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
  8000c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  8000d2:	e8 91 0b 00 00       	call   800c68 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	89 c2                	mov    %eax,%edx
  8000de:	c1 e2 07             	shl    $0x7,%edx
  8000e1:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000e8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 f6                	test   %esi,%esi
  8000ef:	7e 07                	jle    8000f8 <libmain+0x38>
		binaryname = argv[0];
  8000f1:	8b 03                	mov    (%ebx),%eax
  8000f3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000fc:	89 34 24             	mov    %esi,(%esp)
  8000ff:	e8 3c ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800104:	e8 0b 00 00 00       	call   800114 <exit>
}
  800109:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80010c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800121:	e8 0d 0b 00 00       	call   800c33 <sys_env_destroy>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800131:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800138:	00 00 00 
	b.cnt = 0;
  80013b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800142:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800145:	8b 45 0c             	mov    0xc(%ebp),%eax
  800148:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014c:	8b 45 08             	mov    0x8(%ebp),%eax
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800159:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015d:	c7 04 24 a3 01 80 00 	movl   $0x8001a3,(%esp)
  800164:	e8 d7 01 00 00       	call   800340 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800169:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80016f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800173:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 4b 0a 00 00       	call   800bcc <sys_cputs>

	return b.cnt;
}
  800181:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80018f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800192:	89 44 24 04          	mov    %eax,0x4(%esp)
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	89 04 24             	mov    %eax,(%esp)
  80019c:	e8 87 ff ff ff       	call   800128 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 14             	sub    $0x14,%esp
  8001aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ad:	8b 03                	mov    (%ebx),%eax
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b6:	83 c0 01             	add    $0x1,%eax
  8001b9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c0:	75 19                	jne    8001db <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c9:	00 
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 f7 09 00 00       	call   800bcc <sys_cputs>
		b->idx = 0;
  8001d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001df:	83 c4 14             	add    $0x14,%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	8b 55 0c             	mov    0xc(%ebp),%edx
  800207:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800216:	b9 00 00 00 00       	mov    $0x0,%ecx
  80021b:	39 d1                	cmp    %edx,%ecx
  80021d:	72 15                	jb     800234 <printnum+0x44>
  80021f:	77 07                	ja     800228 <printnum+0x38>
  800221:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800224:	39 d0                	cmp    %edx,%eax
  800226:	76 0c                	jbe    800234 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	85 db                	test   %ebx,%ebx
  80022d:	8d 76 00             	lea    0x0(%esi),%esi
  800230:	7f 61                	jg     800293 <printnum+0xa3>
  800232:	eb 70                	jmp    8002a4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800234:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800247:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80024b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80024e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800251:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025f:	00 
  800260:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800269:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026d:	e8 ae 10 00 00       	call   801320 <__udivdi3>
  800272:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800275:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80027c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	89 54 24 04          	mov    %edx,0x4(%esp)
  800287:	89 f2                	mov    %esi,%edx
  800289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028c:	e8 5f ff ff ff       	call   8001f0 <printnum>
  800291:	eb 11                	jmp    8002a4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	89 74 24 04          	mov    %esi,0x4(%esp)
  800297:	89 3c 24             	mov    %edi,(%esp)
  80029a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029d:	83 eb 01             	sub    $0x1,%ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f ef                	jg     800293 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ba:	00 
  8002bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002be:	89 14 24             	mov    %edx,(%esp)
  8002c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002c8:	e8 83 11 00 00       	call   801450 <__umoddi3>
  8002cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d1:	0f be 80 4d 16 80 00 	movsbl 0x80164d(%eax),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002de:	83 c4 4c             	add    $0x4c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0f                	jle    8002fd <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	83 c2 08             	add    $0x8,%edx
  8002f3:	89 10                	mov    %edx,(%eax)
  8002f5:	8b 42 f8             	mov    -0x8(%edx),%eax
  8002f8:	8b 52 fc             	mov    -0x4(%edx),%edx
  8002fb:	eb 24                	jmp    800321 <getuint+0x3b>
	else if (lflag)
  8002fd:	85 d2                	test   %edx,%edx
  8002ff:	74 11                	je     800312 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	83 c2 04             	add    $0x4,%edx
  800306:	89 10                	mov    %edx,(%eax)
  800308:	8b 42 fc             	mov    -0x4(%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
  800310:	eb 0f                	jmp    800321 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  800312:	8b 10                	mov    (%eax),%edx
  800314:	83 c2 04             	add    $0x4,%edx
  800317:	89 10                	mov    %edx,(%eax)
  800319:	8b 42 fc             	mov    -0x4(%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800337:	88 0a                	mov    %cl,(%edx)
  800339:	83 c2 01             	add    $0x1,%edx
  80033c:	89 10                	mov    %edx,(%eax)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 5c             	sub    $0x5c,%esp
  800349:	8b 7d 08             	mov    0x8(%ebp),%edi
  80034c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80034f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800352:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800359:	eb 11                	jmp    80036c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035b:	85 c0                	test   %eax,%eax
  80035d:	0f 84 fd 03 00 00    	je     800760 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800363:	89 74 24 04          	mov    %esi,0x4(%esp)
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036c:	0f b6 03             	movzbl (%ebx),%eax
  80036f:	83 c3 01             	add    $0x1,%ebx
  800372:	83 f8 25             	cmp    $0x25,%eax
  800375:	75 e4                	jne    80035b <vprintfmt+0x1b>
  800377:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80037b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800382:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800389:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800390:	b9 00 00 00 00       	mov    $0x0,%ecx
  800395:	eb 06                	jmp    80039d <vprintfmt+0x5d>
  800397:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80039b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	0f b6 13             	movzbl (%ebx),%edx
  8003a0:	0f b6 c2             	movzbl %dl,%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	8d 43 01             	lea    0x1(%ebx),%eax
  8003a9:	83 ea 23             	sub    $0x23,%edx
  8003ac:	80 fa 55             	cmp    $0x55,%dl
  8003af:	0f 87 8e 03 00 00    	ja     800743 <vprintfmt+0x403>
  8003b5:	0f b6 d2             	movzbl %dl,%edx
  8003b8:	ff 24 95 20 17 80 00 	jmp    *0x801720(,%edx,4)
  8003bf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c3:	eb d6                	jmp    80039b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c8:	83 ea 30             	sub    $0x30,%edx
  8003cb:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8003ce:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003d1:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003d4:	83 fb 09             	cmp    $0x9,%ebx
  8003d7:	77 55                	ja     80042e <vprintfmt+0xee>
  8003d9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003df:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003e2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003e5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003e9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ec:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003ef:	83 fb 09             	cmp    $0x9,%ebx
  8003f2:	76 eb                	jbe    8003df <vprintfmt+0x9f>
  8003f4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003fa:	eb 32                	jmp    80042e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fc:	8b 55 14             	mov    0x14(%ebp),%edx
  8003ff:	83 c2 04             	add    $0x4,%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 52 fc             	mov    -0x4(%edx),%edx
  800408:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80040b:	eb 21                	jmp    80042e <vprintfmt+0xee>

		case '.':
			if (width < 0)
  80040d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800411:	ba 00 00 00 00       	mov    $0x0,%edx
  800416:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  80041a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80041d:	e9 79 ff ff ff       	jmp    80039b <vprintfmt+0x5b>
  800422:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800429:	e9 6d ff ff ff       	jmp    80039b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80042e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800432:	0f 89 63 ff ff ff    	jns    80039b <vprintfmt+0x5b>
  800438:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80043b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80043e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800441:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800444:	e9 52 ff ff ff       	jmp    80039b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800449:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80044c:	e9 4a ff ff ff       	jmp    80039b <vprintfmt+0x5b>
  800451:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	83 c0 04             	add    $0x4,%eax
  80045a:	89 45 14             	mov    %eax,0x14(%ebp)
  80045d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800461:	8b 40 fc             	mov    -0x4(%eax),%eax
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	ff d7                	call   *%edi
  800469:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80046c:	e9 fb fe ff ff       	jmp    80036c <vprintfmt+0x2c>
  800471:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	83 c0 04             	add    $0x4,%eax
  80047a:	89 45 14             	mov    %eax,0x14(%ebp)
  80047d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800480:	89 c2                	mov    %eax,%edx
  800482:	c1 fa 1f             	sar    $0x1f,%edx
  800485:	31 d0                	xor    %edx,%eax
  800487:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800489:	83 f8 08             	cmp    $0x8,%eax
  80048c:	7f 0b                	jg     800499 <vprintfmt+0x159>
  80048e:	8b 14 85 80 18 80 00 	mov    0x801880(,%eax,4),%edx
  800495:	85 d2                	test   %edx,%edx
  800497:	75 20                	jne    8004b9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049d:	c7 44 24 08 5e 16 80 	movl   $0x80165e,0x8(%esp)
  8004a4:	00 
  8004a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a9:	89 3c 24             	mov    %edi,(%esp)
  8004ac:	e8 37 03 00 00       	call   8007e8 <printfmt>
  8004b1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004b4:	e9 b3 fe ff ff       	jmp    80036c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bd:	c7 44 24 08 67 16 80 	movl   $0x801667,0x8(%esp)
  8004c4:	00 
  8004c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c9:	89 3c 24             	mov    %edi,(%esp)
  8004cc:	e8 17 03 00 00       	call   8007e8 <printfmt>
  8004d1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8004d4:	e9 93 fe ff ff       	jmp    80036c <vprintfmt+0x2c>
  8004d9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004dc:	89 c3                	mov    %eax,%ebx
  8004de:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	83 c0 04             	add    $0x4,%eax
  8004ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f0:	8b 40 fc             	mov    -0x4(%eax),%eax
  8004f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	b8 6a 16 80 00       	mov    $0x80166a,%eax
  8004fd:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800504:	85 c9                	test   %ecx,%ecx
  800506:	7e 06                	jle    80050e <vprintfmt+0x1ce>
  800508:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050c:	75 13                	jne    800521 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800511:	0f be 02             	movsbl (%edx),%eax
  800514:	85 c0                	test   %eax,%eax
  800516:	0f 85 99 00 00 00    	jne    8005b5 <vprintfmt+0x275>
  80051c:	e9 86 00 00 00       	jmp    8005a7 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	89 54 24 04          	mov    %edx,0x4(%esp)
  800525:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800528:	89 0c 24             	mov    %ecx,(%esp)
  80052b:	e8 fb 02 00 00       	call   80082b <strnlen>
  800530:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800533:	29 c2                	sub    %eax,%edx
  800535:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800538:	85 d2                	test   %edx,%edx
  80053a:	7e d2                	jle    80050e <vprintfmt+0x1ce>
					putch(padc, putdat);
  80053c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800540:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800543:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800546:	89 d3                	mov    %edx,%ebx
  800548:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800554:	83 eb 01             	sub    $0x1,%ebx
  800557:	85 db                	test   %ebx,%ebx
  800559:	7f ed                	jg     800548 <vprintfmt+0x208>
  80055b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80055e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800565:	eb a7                	jmp    80050e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800567:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056b:	74 18                	je     800585 <vprintfmt+0x245>
  80056d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800570:	83 fa 5e             	cmp    $0x5e,%edx
  800573:	76 10                	jbe    800585 <vprintfmt+0x245>
					putch('?', putdat);
  800575:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800579:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800580:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800583:	eb 0a                	jmp    80058f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800585:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800589:	89 04 24             	mov    %eax,(%esp)
  80058c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800593:	0f be 03             	movsbl (%ebx),%eax
  800596:	85 c0                	test   %eax,%eax
  800598:	74 05                	je     80059f <vprintfmt+0x25f>
  80059a:	83 c3 01             	add    $0x1,%ebx
  80059d:	eb 29                	jmp    8005c8 <vprintfmt+0x288>
  80059f:	89 fe                	mov    %edi,%esi
  8005a1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005a4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ab:	7f 2e                	jg     8005db <vprintfmt+0x29b>
  8005ad:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005b0:	e9 b7 fd ff ff       	jmp    80036c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b8:	83 c2 01             	add    $0x1,%edx
  8005bb:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005be:	89 f7                	mov    %esi,%edi
  8005c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005c6:	89 d3                	mov    %edx,%ebx
  8005c8:	85 f6                	test   %esi,%esi
  8005ca:	78 9b                	js     800567 <vprintfmt+0x227>
  8005cc:	83 ee 01             	sub    $0x1,%esi
  8005cf:	79 96                	jns    800567 <vprintfmt+0x227>
  8005d1:	89 fe                	mov    %edi,%esi
  8005d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005d6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005d9:	eb cc                	jmp    8005a7 <vprintfmt+0x267>
  8005db:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005de:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ec:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ee:	83 eb 01             	sub    $0x1,%ebx
  8005f1:	85 db                	test   %ebx,%ebx
  8005f3:	7f ec                	jg     8005e1 <vprintfmt+0x2a1>
  8005f5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005f8:	e9 6f fd ff ff       	jmp    80036c <vprintfmt+0x2c>
  8005fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800600:	83 f9 01             	cmp    $0x1,%ecx
  800603:	7e 17                	jle    80061c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	83 c0 08             	add    $0x8,%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
  80060e:	8b 50 f8             	mov    -0x8(%eax),%edx
  800611:	8b 48 fc             	mov    -0x4(%eax),%ecx
  800614:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800617:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061a:	eb 34                	jmp    800650 <vprintfmt+0x310>
	else if (lflag)
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	74 19                	je     800639 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	83 c0 04             	add    $0x4,%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
  800629:	8b 40 fc             	mov    -0x4(%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 c1                	mov    %eax,%ecx
  800631:	c1 f9 1f             	sar    $0x1f,%ecx
  800634:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800637:	eb 17                	jmp    800650 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	83 c0 04             	add    $0x4,%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
  800642:	8b 40 fc             	mov    -0x4(%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	89 c2                	mov    %eax,%edx
  80064a:	c1 fa 1f             	sar    $0x1f,%edx
  80064d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800650:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800653:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80065b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80065f:	0f 89 9c 00 00 00    	jns    800701 <vprintfmt+0x3c1>
				putch('-', putdat);
  800665:	89 74 24 04          	mov    %esi,0x4(%esp)
  800669:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800670:	ff d7                	call   *%edi
				num = -(long long) num;
  800672:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800675:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800678:	f7 d9                	neg    %ecx
  80067a:	83 d3 00             	adc    $0x0,%ebx
  80067d:	f7 db                	neg    %ebx
  80067f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800684:	eb 7b                	jmp    800701 <vprintfmt+0x3c1>
  800686:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 53 fc ff ff       	call   8002e6 <getuint>
  800693:	89 c1                	mov    %eax,%ecx
  800695:	89 d3                	mov    %edx,%ebx
  800697:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80069c:	eb 63                	jmp    800701 <vprintfmt+0x3c1>
  80069e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 3b fc ff ff       	call   8002e6 <getuint>
  8006ab:	89 c1                	mov    %eax,%ecx
  8006ad:	89 d3                	mov    %edx,%ebx
  8006af:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8006b4:	eb 4b                	jmp    800701 <vprintfmt+0x3c1>
  8006b6:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006bd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c4:	ff d7                	call   *%edi
			putch('x', putdat);
  8006c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ca:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	83 c0 04             	add    $0x4,%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006dc:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8006df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e9:	eb 16                	jmp    800701 <vprintfmt+0x3c1>
  8006eb:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ee:	89 ca                	mov    %ecx,%edx
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f3:	e8 ee fb ff ff       	call   8002e6 <getuint>
  8006f8:	89 c1                	mov    %eax,%ecx
  8006fa:	89 d3                	mov    %edx,%ebx
  8006fc:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800701:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800705:	89 54 24 10          	mov    %edx,0x10(%esp)
  800709:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800710:	89 44 24 08          	mov    %eax,0x8(%esp)
  800714:	89 0c 24             	mov    %ecx,(%esp)
  800717:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071b:	89 f2                	mov    %esi,%edx
  80071d:	89 f8                	mov    %edi,%eax
  80071f:	e8 cc fa ff ff       	call   8001f0 <printnum>
  800724:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800727:	e9 40 fc ff ff       	jmp    80036c <vprintfmt+0x2c>
  80072c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80072f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800732:	89 74 24 04          	mov    %esi,0x4(%esp)
  800736:	89 14 24             	mov    %edx,(%esp)
  800739:	ff d7                	call   *%edi
  80073b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80073e:	e9 29 fc ff ff       	jmp    80036c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800743:	89 74 24 04          	mov    %esi,0x4(%esp)
  800747:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80074e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800750:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800753:	80 38 25             	cmpb   $0x25,(%eax)
  800756:	0f 84 10 fc ff ff    	je     80036c <vprintfmt+0x2c>
  80075c:	89 c3                	mov    %eax,%ebx
  80075e:	eb f0                	jmp    800750 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800760:	83 c4 5c             	add    $0x5c,%esp
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5f                   	pop    %edi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 28             	sub    $0x28,%esp
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800774:	85 c0                	test   %eax,%eax
  800776:	74 04                	je     80077c <vsnprintf+0x14>
  800778:	85 d2                	test   %edx,%edx
  80077a:	7f 07                	jg     800783 <vsnprintf+0x1b>
  80077c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800781:	eb 3b                	jmp    8007be <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800783:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800786:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80078a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80078d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079b:	8b 45 10             	mov    0x10(%ebp),%eax
  80079e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a9:	c7 04 24 23 03 80 00 	movl   $0x800323,(%esp)
  8007b0:	e8 8b fb ff ff       	call   800340 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	89 04 24             	mov    %eax,(%esp)
  8007e1:	e8 82 ff ff ff       	call   800768 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	89 04 24             	mov    %eax,(%esp)
  800809:	e8 32 fb ff ff       	call   800340 <vprintfmt>
	va_end(ap);
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	80 3a 00             	cmpb   $0x0,(%edx)
  80081e:	74 09                	je     800829 <strlen+0x19>
		n++;
  800820:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800823:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800827:	75 f7                	jne    800820 <strlen+0x10>
		n++;
	return n;
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800835:	85 c9                	test   %ecx,%ecx
  800837:	74 19                	je     800852 <strnlen+0x27>
  800839:	80 3b 00             	cmpb   $0x0,(%ebx)
  80083c:	74 14                	je     800852 <strnlen+0x27>
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800843:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800846:	39 c8                	cmp    %ecx,%eax
  800848:	74 0d                	je     800857 <strnlen+0x2c>
  80084a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80084e:	75 f3                	jne    800843 <strnlen+0x18>
  800850:	eb 05                	jmp    800857 <strnlen+0x2c>
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800864:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800869:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80086d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	84 c9                	test   %cl,%cl
  800875:	75 f2                	jne    800869 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	85 f6                	test   %esi,%esi
  80088a:	74 18                	je     8008a4 <strncpy+0x2a>
  80088c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800891:	0f b6 1a             	movzbl (%edx),%ebx
  800894:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800897:	80 3a 01             	cmpb   $0x1,(%edx)
  80089a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089d:	83 c1 01             	add    $0x1,%ecx
  8008a0:	39 ce                	cmp    %ecx,%esi
  8008a2:	77 ed                	ja     800891 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	56                   	push   %esi
  8008ac:	53                   	push   %ebx
  8008ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b6:	89 f0                	mov    %esi,%eax
  8008b8:	85 c9                	test   %ecx,%ecx
  8008ba:	74 27                	je     8008e3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008bc:	83 e9 01             	sub    $0x1,%ecx
  8008bf:	74 1d                	je     8008de <strlcpy+0x36>
  8008c1:	0f b6 1a             	movzbl (%edx),%ebx
  8008c4:	84 db                	test   %bl,%bl
  8008c6:	74 16                	je     8008de <strlcpy+0x36>
			*dst++ = *src++;
  8008c8:	88 18                	mov    %bl,(%eax)
  8008ca:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cd:	83 e9 01             	sub    $0x1,%ecx
  8008d0:	74 0e                	je     8008e0 <strlcpy+0x38>
			*dst++ = *src++;
  8008d2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d5:	0f b6 1a             	movzbl (%edx),%ebx
  8008d8:	84 db                	test   %bl,%bl
  8008da:	75 ec                	jne    8008c8 <strlcpy+0x20>
  8008dc:	eb 02                	jmp    8008e0 <strlcpy+0x38>
  8008de:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e0:	c6 00 00             	movb   $0x0,(%eax)
  8008e3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	84 c0                	test   %al,%al
  8008f7:	74 15                	je     80090e <strcmp+0x25>
  8008f9:	3a 02                	cmp    (%edx),%al
  8008fb:	75 11                	jne    80090e <strcmp+0x25>
		p++, q++;
  8008fd:	83 c1 01             	add    $0x1,%ecx
  800900:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800903:	0f b6 01             	movzbl (%ecx),%eax
  800906:	84 c0                	test   %al,%al
  800908:	74 04                	je     80090e <strcmp+0x25>
  80090a:	3a 02                	cmp    (%edx),%al
  80090c:	74 ef                	je     8008fd <strcmp+0x14>
  80090e:	0f b6 c0             	movzbl %al,%eax
  800911:	0f b6 12             	movzbl (%edx),%edx
  800914:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 55 08             	mov    0x8(%ebp),%edx
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800922:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800925:	85 c0                	test   %eax,%eax
  800927:	74 23                	je     80094c <strncmp+0x34>
  800929:	0f b6 1a             	movzbl (%edx),%ebx
  80092c:	84 db                	test   %bl,%bl
  80092e:	74 24                	je     800954 <strncmp+0x3c>
  800930:	3a 19                	cmp    (%ecx),%bl
  800932:	75 20                	jne    800954 <strncmp+0x3c>
  800934:	83 e8 01             	sub    $0x1,%eax
  800937:	74 13                	je     80094c <strncmp+0x34>
		n--, p++, q++;
  800939:	83 c2 01             	add    $0x1,%edx
  80093c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093f:	0f b6 1a             	movzbl (%edx),%ebx
  800942:	84 db                	test   %bl,%bl
  800944:	74 0e                	je     800954 <strncmp+0x3c>
  800946:	3a 19                	cmp    (%ecx),%bl
  800948:	74 ea                	je     800934 <strncmp+0x1c>
  80094a:	eb 08                	jmp    800954 <strncmp+0x3c>
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800951:	5b                   	pop    %ebx
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800954:	0f b6 02             	movzbl (%edx),%eax
  800957:	0f b6 11             	movzbl (%ecx),%edx
  80095a:	29 d0                	sub    %edx,%eax
  80095c:	eb f3                	jmp    800951 <strncmp+0x39>

0080095e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800968:	0f b6 10             	movzbl (%eax),%edx
  80096b:	84 d2                	test   %dl,%dl
  80096d:	74 15                	je     800984 <strchr+0x26>
		if (*s == c)
  80096f:	38 ca                	cmp    %cl,%dl
  800971:	75 07                	jne    80097a <strchr+0x1c>
  800973:	eb 14                	jmp    800989 <strchr+0x2b>
  800975:	38 ca                	cmp    %cl,%dl
  800977:	90                   	nop
  800978:	74 0f                	je     800989 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	84 d2                	test   %dl,%dl
  800982:	75 f1                	jne    800975 <strchr+0x17>
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	84 d2                	test   %dl,%dl
  80099a:	74 18                	je     8009b4 <strfind+0x29>
		if (*s == c)
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	75 0a                	jne    8009aa <strfind+0x1f>
  8009a0:	eb 12                	jmp    8009b4 <strfind+0x29>
  8009a2:	38 ca                	cmp    %cl,%dl
  8009a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009a8:	74 0a                	je     8009b4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 ee                	jne    8009a2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memset>:


void *
memset(void *v, int c, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	53                   	push   %ebx
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009c3:	89 da                	mov    %ebx,%edx
  8009c5:	83 ea 01             	sub    $0x1,%edx
  8009c8:	78 0d                	js     8009d7 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  8009ca:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  8009cc:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  8009ce:	88 0a                	mov    %cl,(%edx)
  8009d0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009d3:	39 da                	cmp    %ebx,%edx
  8009d5:	75 f7                	jne    8009ce <memset+0x18>
		*p++ = c;

	return v;
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8009e8:	85 db                	test   %ebx,%ebx
  8009ea:	74 13                	je     8009ff <memcpy+0x25>
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  8009f1:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009f5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f8:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8009fb:	39 da                	cmp    %ebx,%edx
  8009fd:	75 f2                	jne    8009f1 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800a12:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800a14:	39 c6                	cmp    %eax,%esi
  800a16:	72 0b                	jb     800a23 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800a18:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800a1d:	85 db                	test   %ebx,%ebx
  800a1f:	75 2e                	jne    800a4f <memmove+0x4c>
  800a21:	eb 3a                	jmp    800a5d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a23:	01 df                	add    %ebx,%edi
  800a25:	39 f8                	cmp    %edi,%eax
  800a27:	73 ef                	jae    800a18 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	90                   	nop
  800a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a30:	74 2b                	je     800a5d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a32:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800a3a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800a3f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800a43:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a46:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	75 ed                	jne    800a3a <memmove+0x37>
  800a4d:	eb 0e                	jmp    800a5d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a4f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a53:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a56:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a59:	39 d3                	cmp    %edx,%ebx
  800a5b:	75 f2                	jne    800a4f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	74 36                	je     800aab <memcmp+0x49>
		if (*s1 != *s2)
  800a75:	0f b6 06             	movzbl (%esi),%eax
  800a78:	0f b6 1f             	movzbl (%edi),%ebx
  800a7b:	38 d8                	cmp    %bl,%al
  800a7d:	74 20                	je     800a9f <memcmp+0x3d>
  800a7f:	eb 14                	jmp    800a95 <memcmp+0x33>
  800a81:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800a86:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800a8b:	83 c2 01             	add    $0x1,%edx
  800a8e:	83 e9 01             	sub    $0x1,%ecx
  800a91:	38 d8                	cmp    %bl,%al
  800a93:	74 12                	je     800aa7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800a95:	0f b6 c0             	movzbl %al,%eax
  800a98:	0f b6 db             	movzbl %bl,%ebx
  800a9b:	29 d8                	sub    %ebx,%eax
  800a9d:	eb 11                	jmp    800ab0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9f:	83 e9 01             	sub    $0x1,%ecx
  800aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa7:	85 c9                	test   %ecx,%ecx
  800aa9:	75 d6                	jne    800a81 <memcmp+0x1f>
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800abb:	89 c2                	mov    %eax,%edx
  800abd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac0:	39 d0                	cmp    %edx,%eax
  800ac2:	73 15                	jae    800ad9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ac8:	38 08                	cmp    %cl,(%eax)
  800aca:	75 06                	jne    800ad2 <memfind+0x1d>
  800acc:	eb 0b                	jmp    800ad9 <memfind+0x24>
  800ace:	38 08                	cmp    %cl,(%eax)
  800ad0:	74 07                	je     800ad9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	39 c2                	cmp    %eax,%edx
  800ad7:	77 f5                	ja     800ace <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aea:	0f b6 02             	movzbl (%edx),%eax
  800aed:	3c 20                	cmp    $0x20,%al
  800aef:	74 04                	je     800af5 <strtol+0x1a>
  800af1:	3c 09                	cmp    $0x9,%al
  800af3:	75 0e                	jne    800b03 <strtol+0x28>
		s++;
  800af5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af8:	0f b6 02             	movzbl (%edx),%eax
  800afb:	3c 20                	cmp    $0x20,%al
  800afd:	74 f6                	je     800af5 <strtol+0x1a>
  800aff:	3c 09                	cmp    $0x9,%al
  800b01:	74 f2                	je     800af5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b03:	3c 2b                	cmp    $0x2b,%al
  800b05:	75 0c                	jne    800b13 <strtol+0x38>
		s++;
  800b07:	83 c2 01             	add    $0x1,%edx
  800b0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b11:	eb 15                	jmp    800b28 <strtol+0x4d>
	else if (*s == '-')
  800b13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b1a:	3c 2d                	cmp    $0x2d,%al
  800b1c:	75 0a                	jne    800b28 <strtol+0x4d>
		s++, neg = 1;
  800b1e:	83 c2 01             	add    $0x1,%edx
  800b21:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	0f 94 c0             	sete   %al
  800b2d:	74 05                	je     800b34 <strtol+0x59>
  800b2f:	83 fb 10             	cmp    $0x10,%ebx
  800b32:	75 18                	jne    800b4c <strtol+0x71>
  800b34:	80 3a 30             	cmpb   $0x30,(%edx)
  800b37:	75 13                	jne    800b4c <strtol+0x71>
  800b39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b3d:	8d 76 00             	lea    0x0(%esi),%esi
  800b40:	75 0a                	jne    800b4c <strtol+0x71>
		s += 2, base = 16;
  800b42:	83 c2 02             	add    $0x2,%edx
  800b45:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4a:	eb 15                	jmp    800b61 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4c:	84 c0                	test   %al,%al
  800b4e:	66 90                	xchg   %ax,%ax
  800b50:	74 0f                	je     800b61 <strtol+0x86>
  800b52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b57:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5a:	75 05                	jne    800b61 <strtol+0x86>
		s++, base = 8;
  800b5c:	83 c2 01             	add    $0x1,%edx
  800b5f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b68:	0f b6 0a             	movzbl (%edx),%ecx
  800b6b:	89 cf                	mov    %ecx,%edi
  800b6d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b70:	80 fb 09             	cmp    $0x9,%bl
  800b73:	77 08                	ja     800b7d <strtol+0xa2>
			dig = *s - '0';
  800b75:	0f be c9             	movsbl %cl,%ecx
  800b78:	83 e9 30             	sub    $0x30,%ecx
  800b7b:	eb 1e                	jmp    800b9b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b7d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b80:	80 fb 19             	cmp    $0x19,%bl
  800b83:	77 08                	ja     800b8d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800b85:	0f be c9             	movsbl %cl,%ecx
  800b88:	83 e9 57             	sub    $0x57,%ecx
  800b8b:	eb 0e                	jmp    800b9b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800b8d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b90:	80 fb 19             	cmp    $0x19,%bl
  800b93:	77 15                	ja     800baa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800b95:	0f be c9             	movsbl %cl,%ecx
  800b98:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b9b:	39 f1                	cmp    %esi,%ecx
  800b9d:	7d 0b                	jge    800baa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800b9f:	83 c2 01             	add    $0x1,%edx
  800ba2:	0f af c6             	imul   %esi,%eax
  800ba5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ba8:	eb be                	jmp    800b68 <strtol+0x8d>
  800baa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb0:	74 05                	je     800bb7 <strtol+0xdc>
		*endptr = (char *) s;
  800bb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bb7:	89 ca                	mov    %ecx,%edx
  800bb9:	f7 da                	neg    %edx
  800bbb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bbf:	0f 45 c2             	cmovne %edx,%eax
}
  800bc2:	83 c4 04             	add    $0x4,%esp
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    
	...

00800bcc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	89 1c 24             	mov    %ebx,(%esp)
  800bd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	89 c3                	mov    %eax,%ebx
  800bea:	89 c7                	mov    %eax,%edi
  800bec:	89 c6                	mov    %eax,%esi
  800bee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800bf0:	8b 1c 24             	mov    (%esp),%ebx
  800bf3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bf7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bfb:	89 ec                	mov    %ebp,%esp
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_cgetc>:

int
sys_cgetc(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	89 1c 24             	mov    %ebx,(%esp)
  800c08:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c0c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	ba 00 00 00 00       	mov    $0x0,%edx
  800c15:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1a:	89 d1                	mov    %edx,%ecx
  800c1c:	89 d3                	mov    %edx,%ebx
  800c1e:	89 d7                	mov    %edx,%edi
  800c20:	89 d6                	mov    %edx,%esi
  800c22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800c24:	8b 1c 24             	mov    (%esp),%ebx
  800c27:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c2b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c2f:	89 ec                	mov    %ebp,%esp
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	89 1c 24             	mov    %ebx,(%esp)
  800c3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c40:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c49:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 cb                	mov    %ecx,%ebx
  800c53:	89 cf                	mov    %ecx,%edi
  800c55:	89 ce                	mov    %ecx,%esi
  800c57:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800c59:	8b 1c 24             	mov    (%esp),%ebx
  800c5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c60:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c64:	89 ec                	mov    %ebp,%esp
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	89 1c 24             	mov    %ebx,(%esp)
  800c71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c75:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c83:	89 d1                	mov    %edx,%ecx
  800c85:	89 d3                	mov    %edx,%ebx
  800c87:	89 d7                	mov    %edx,%edi
  800c89:	89 d6                	mov    %edx,%esi
  800c8b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800c8d:	8b 1c 24             	mov    (%esp),%ebx
  800c90:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c98:	89 ec                	mov    %ebp,%esp
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_yield>:

void
sys_yield(void)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	89 1c 24             	mov    %ebx,(%esp)
  800ca5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb7:	89 d1                	mov    %edx,%ecx
  800cb9:	89 d3                	mov    %edx,%ebx
  800cbb:	89 d7                	mov    %edx,%edi
  800cbd:	89 d6                	mov    %edx,%esi
  800cbf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800cc1:	8b 1c 24             	mov    (%esp),%ebx
  800cc4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ccc:	89 ec                	mov    %ebp,%esp
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	89 1c 24             	mov    %ebx,(%esp)
  800cd9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cdd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	be 00 00 00 00       	mov    $0x0,%esi
  800ce6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 f7                	mov    %esi,%edi
  800cf6:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800cf8:	8b 1c 24             	mov    (%esp),%ebx
  800cfb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cff:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d03:	89 ec                	mov    %ebp,%esp
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	89 1c 24             	mov    %ebx,(%esp)
  800d10:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d14:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	b8 05 00 00 00       	mov    $0x5,%eax
  800d1d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2e:	8b 1c 24             	mov    (%esp),%ebx
  800d31:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d35:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d39:	89 ec                	mov    %ebp,%esp
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	89 1c 24             	mov    %ebx,(%esp)
  800d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d4a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	b8 06 00 00 00       	mov    $0x6,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800d64:	8b 1c 24             	mov    (%esp),%ebx
  800d67:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d6b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d6f:	89 ec                	mov    %ebp,%esp
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	89 1c 24             	mov    %ebx,(%esp)
  800d7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d80:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d89:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 df                	mov    %ebx,%edi
  800d96:	89 de                	mov    %ebx,%esi
  800d98:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800d9a:	8b 1c 24             	mov    (%esp),%ebx
  800d9d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da5:	89 ec                	mov    %ebp,%esp
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	89 1c 24             	mov    %ebx,(%esp)
  800db2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbf:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	89 df                	mov    %ebx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd0:	8b 1c 24             	mov    (%esp),%ebx
  800dd3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ddb:	89 ec                	mov    %ebp,%esp
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	89 1c 24             	mov    %ebx,(%esp)
  800de8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dec:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e06:	8b 1c 24             	mov    (%esp),%ebx
  800e09:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e0d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e11:	89 ec                	mov    %ebp,%esp
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	89 1c 24             	mov    %ebx,(%esp)
  800e1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e22:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	be 00 00 00 00       	mov    $0x0,%esi
  800e2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3e:	8b 1c 24             	mov    (%esp),%ebx
  800e41:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e45:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e49:	89 ec                	mov    %ebp,%esp
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	89 1c 24             	mov    %ebx,(%esp)
  800e56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800e73:	8b 1c 24             	mov    (%esp),%ebx
  800e76:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e7a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e7e:	89 ec                	mov    %ebp,%esp
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
	...

00800e84 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800e8a:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800e91:	00 
  800e92:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  800e99:	00 
  800e9a:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  800ea1:	e8 7a 03 00 00       	call   801220 <_panic>

00800ea6 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr;
	pte_t pte;

	// LAB 4: Your code here.
	addr = (void *) ((uint32_t) pn * PGSIZE);
  800ead:	89 d3                	mov    %edx,%ebx
  800eaf:	c1 e3 0c             	shl    $0xc,%ebx
	pte = vpt[VPN(addr)];
  800eb2:	89 da                	mov    %ebx,%edx
  800eb4:	c1 ea 0c             	shr    $0xc,%edx
  800eb7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((pte & PTE_W) > 0 || (pte & PTE_COW) > 0) 
  800ebe:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ec4:	0f 84 8c 00 00 00    	je     800f56 <duppage+0xb0>
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800eca:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800ed1:	00 
  800ed2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ed6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ede:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ee5:	e8 1d fe ff ff       	call   800d07 <sys_page_map>
  800eea:	85 c0                	test   %eax,%eax
  800eec:	79 20                	jns    800f0e <duppage+0x68>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  800eee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ef2:	c7 44 24 08 1c 19 80 	movl   $0x80191c,0x8(%esp)
  800ef9:	00 
  800efa:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  800f01:	00 
  800f02:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  800f09:	e8 12 03 00 00       	call   801220 <_panic>
	
		if ((r = sys_page_map (0, addr, 0, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800f0e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800f15:	00 
  800f16:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f21:	00 
  800f22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2d:	e8 d5 fd ff ff       	call   800d07 <sys_page_map>
  800f32:	85 c0                	test   %eax,%eax
  800f34:	79 64                	jns    800f9a <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  800f36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f3a:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800f41:	00 
  800f42:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  800f49:	00 
  800f4a:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  800f51:	e8 ca 02 00 00       	call   801220 <_panic>
	} 
	else 
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800f56:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  800f5d:	00 
  800f5e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f62:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f71:	e8 91 fd ff ff       	call   800d07 <sys_page_map>
  800f76:	85 c0                	test   %eax,%eax
  800f78:	79 20                	jns    800f9a <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  800f7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7e:	c7 44 24 08 74 19 80 	movl   $0x801974,0x8(%esp)
  800f85:	00 
  800f86:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800f8d:	00 
  800f8e:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  800f95:	e8 86 02 00 00       	call   801220 <_panic>
	}	
	//panic("duppage not implemented");
	return 0;
}
  800f9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9f:	83 c4 24             	add    $0x24,%esp
  800fa2:	5b                   	pop    %ebx
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 24             	sub    $0x24,%esp
	// LAB 4: Your code here.
	envid_t envid;  
	uint8_t *addr;  
	int r;  
	extern unsigned char end[];  
	set_pgfault_handler(pgfault);  
  800fac:	c7 04 24 da 10 80 00 	movl   $0x8010da,(%esp)
  800fb3:	e8 cc 02 00 00       	call   801284 <set_pgfault_handler>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fb8:	bb 07 00 00 00       	mov    $0x7,%ebx
  800fbd:	89 d8                	mov    %ebx,%eax
  800fbf:	cd 30                	int    $0x30
  800fc1:	89 c3                	mov    %eax,%ebx
	envid = sys_exofork();  
	if (envid < 0)  
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	79 20                	jns    800fe7 <fork+0x42>
		panic("sys_exofork: %e", envid);  
  800fc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fcb:	c7 44 24 08 c5 18 80 	movl   $0x8018c5,0x8(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800fda:	00 
  800fdb:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  800fe2:	e8 39 02 00 00       	call   801220 <_panic>
	//child  
	if (envid == 0) {  
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	75 20                	jne    80100b <fork+0x66>
		//can't set pgh here ,must before child run  
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
  800feb:	e8 78 fc ff ff       	call   800c68 <sys_getenvid>
  800ff0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff5:	89 c2                	mov    %eax,%edx
  800ff7:	c1 e2 07             	shl    $0x7,%edx
  800ffa:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801001:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;  
  801006:	e9 c7 00 00 00       	jmp    8010d2 <fork+0x12d>
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  80100b:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  801012:	b8 10 20 80 00       	mov    $0x802010,%eax
  801017:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80101c:	76 23                	jbe    801041 <fork+0x9c>
  80101e:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, VPN(addr));  
  801023:	c1 ea 0c             	shr    $0xc,%edx
  801026:	89 d8                	mov    %ebx,%eax
  801028:	e8 79 fe ff ff       	call   800ea6 <duppage>
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
		return 0;  
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  80102d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801030:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801036:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801039:	81 fa 10 20 80 00    	cmp    $0x802010,%edx
  80103f:	72 e2                	jb     801023 <fork+0x7e>
		duppage(envid, VPN(addr));  
	duppage(envid, VPN(&addr));  
  801041:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801044:	c1 ea 0c             	shr    $0xc,%edx
  801047:	89 d8                	mov    %ebx,%eax
  801049:	e8 58 fe ff ff       	call   800ea6 <duppage>
	//copy user exception stack  

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)  
  80104e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801055:	00 
  801056:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80105d:	ee 
  80105e:	89 1c 24             	mov    %ebx,(%esp)
  801061:	e8 6a fc ff ff       	call   800cd0 <sys_page_alloc>
  801066:	85 c0                	test   %eax,%eax
  801068:	79 20                	jns    80108a <fork+0xe5>
		panic("sys_page_alloc: %e", r);  
  80106a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80106e:	c7 44 24 08 d5 18 80 	movl   $0x8018d5,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  801085:	e8 96 01 00 00       	call   801220 <_panic>
	r = sys_env_set_pgfault_upcall(envid, env->env_pgfault_upcall);  
  80108a:	a1 04 20 80 00       	mov    0x802004,%eax
  80108f:	8b 40 64             	mov    0x64(%eax),%eax
  801092:	89 44 24 04          	mov    %eax,0x4(%esp)
  801096:	89 1c 24             	mov    %ebx,(%esp)
  801099:	e8 41 fd ff ff       	call   800ddf <sys_env_set_pgfault_upcall>

	//set child status  

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)  
  80109e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a5:	00 
  8010a6:	89 1c 24             	mov    %ebx,(%esp)
  8010a9:	e8 c5 fc ff ff       	call   800d73 <sys_env_set_status>
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	79 20                	jns    8010d2 <fork+0x12d>
		panic("sys_env_set_status: %e", r);  
  8010b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b6:	c7 44 24 08 e8 18 80 	movl   $0x8018e8,0x8(%esp)
  8010bd:	00 
  8010be:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8010c5:	00 
  8010c6:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  8010cd:	e8 4e 01 00 00       	call   801220 <_panic>
	return envid;  
	//panic("fork not implemented");
}
  8010d2:	89 d8                	mov    %ebx,%eax
  8010d4:	83 c4 24             	add    $0x24,%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 24             	sub    $0x24,%esp
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010e4:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8010e6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010ea:	75 1c                	jne    801108 <pgfault+0x2e>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!(err&FEC_WR))   
		panic("Page fault: not a write access.");  
  8010ec:	c7 44 24 08 a0 19 80 	movl   $0x8019a0,0x8(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8010fb:	00 
  8010fc:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  801103:	e8 18 01 00 00       	call   801220 <_panic>
	
	if ( !(vpt[VPN(addr)]&PTE_COW) )  
  801108:	89 d8                	mov    %ebx,%eax
  80110a:	c1 e8 0c             	shr    $0xc,%eax
  80110d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801114:	f6 c4 08             	test   $0x8,%ah
  801117:	75 1c                	jne    801135 <pgfault+0x5b>
		panic("Page fualt: not a COW page.");  
  801119:	c7 44 24 08 ff 18 80 	movl   $0x8018ff,0x8(%esp)
  801120:	00 
  801121:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801128:	00 
  801129:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  801130:	e8 eb 00 00 00       	call   801220 <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	
	// LAB 4: Your code here.
	
	if ((r=sys_page_alloc(0, PFTEMP, PTE_U|PTE_W|PTE_P)) <0)  
  801135:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80113c:	00 
  80113d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801144:	00 
  801145:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80114c:	e8 7f fb ff ff       	call   800cd0 <sys_page_alloc>
  801151:	85 c0                	test   %eax,%eax
  801153:	79 20                	jns    801175 <pgfault+0x9b>
		panic("Page fault: sys_page_alloc err %e.", r);  
  801155:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801159:	c7 44 24 08 c0 19 80 	movl   $0x8019c0,0x8(%esp)
  801160:	00 
  801161:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801168:	00 
  801169:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  801170:	e8 ab 00 00 00       	call   801220 <_panic>
	
	memmove(PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);  
  801175:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80117b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801182:	00 
  801183:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801187:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80118e:	e8 70 f8 ff ff       	call   800a03 <memmove>
	
	
	if ((r=sys_page_map(0, PFTEMP, 0, (void *)PTE_ADDR(addr), PTE_U|PTE_W|PTE_P))<0)  
  801193:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80119a:	00 
  80119b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80119f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011ae:	00 
  8011af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b6:	e8 4c fb ff ff       	call   800d07 <sys_page_map>
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	79 20                	jns    8011df <pgfault+0x105>
		panic("Page fault: sys_page_map err %e.", r);  
  8011bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c3:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  8011da:	e8 41 00 00 00       	call   801220 <_panic>
	if ((r=sys_page_unmap(0, PFTEMP))<0)  
  8011df:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011e6:	00 
  8011e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ee:	e8 4a fb ff ff       	call   800d3d <sys_page_unmap>
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	79 20                	jns    801217 <pgfault+0x13d>
		panic("Page fault: sys_page_unmap err %e.", r);  
  8011f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011fb:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801202:	00 
  801203:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 ba 18 80 00 	movl   $0x8018ba,(%esp)
  801212:	e8 09 00 00 00       	call   801220 <_panic>
	
	//panic("pgfault not implemented");
}
  801217:	83 c4 24             	add    $0x24,%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    
  80121d:	00 00                	add    %al,(%eax)
	...

00801220 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801226:	a1 08 20 80 00       	mov    0x802008,%eax
  80122b:	85 c0                	test   %eax,%eax
  80122d:	74 10                	je     80123f <_panic+0x1f>
		cprintf("%s: ", argv0);
  80122f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801233:	c7 04 24 2c 1a 80 00 	movl   $0x801a2c,(%esp)
  80123a:	e8 4a ef ff ff       	call   800189 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80123f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801242:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
  801249:	89 44 24 08          	mov    %eax,0x8(%esp)
  80124d:	a1 00 20 80 00       	mov    0x802000,%eax
  801252:	89 44 24 04          	mov    %eax,0x4(%esp)
  801256:	c7 04 24 31 1a 80 00 	movl   $0x801a31,(%esp)
  80125d:	e8 27 ef ff ff       	call   800189 <cprintf>
	vcprintf(fmt, ap);
  801262:	8d 45 14             	lea    0x14(%ebp),%eax
  801265:	89 44 24 04          	mov    %eax,0x4(%esp)
  801269:	8b 45 10             	mov    0x10(%ebp),%eax
  80126c:	89 04 24             	mov    %eax,(%esp)
  80126f:	e8 b4 ee ff ff       	call   800128 <vcprintf>
	cprintf("\n");
  801274:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  80127b:	e8 09 ef ff ff       	call   800189 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801280:	cc                   	int3   
  801281:	eb fd                	jmp    801280 <_panic+0x60>
	...

00801284 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80128a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801291:	75 54                	jne    8012e7 <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801293:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80129a:	00 
  80129b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012a2:	ee 
  8012a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012aa:	e8 21 fa ff ff       	call   800cd0 <sys_page_alloc>
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	79 20                	jns    8012d3 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8012b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b7:	c7 44 24 08 4d 1a 80 	movl   $0x801a4d,0x8(%esp)
  8012be:	00 
  8012bf:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8012c6:	00 
  8012c7:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  8012ce:	e8 4d ff ff ff       	call   801220 <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8012d3:	c7 44 24 04 f4 12 80 	movl   $0x8012f4,0x4(%esp)
  8012da:	00 
  8012db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e2:	e8 f8 fa ff ff       	call   800ddf <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ea:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    
  8012f1:	00 00                	add    %al,(%eax)
	...

008012f4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012f4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012f5:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8012fa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012fc:	83 c4 04             	add    $0x4,%esp
	// Hints:
	//   What registers are available for intermediate calculations?
	//
	// LAB 4: Your code here.
	
	movl	0x30(%esp), %eax
  8012ff:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl	$0x4, %eax
  801303:	83 e8 04             	sub    $0x4,%eax
	movl	%eax, 0x30(%esp)
  801306:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl	0x28(%esp), %ebx
  80130a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl	%ebx, (%eax)
  80130e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.
	// LAB 4: Your code here.

	addl	$0x8, %esp
  801310:	83 c4 08             	add    $0x8,%esp
	popal
  801313:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.

	addl	$0x4, %esp
  801314:	83 c4 04             	add    $0x4,%esp
	popfl
  801317:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	pop	%esp
  801318:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801319:	c3                   	ret    
  80131a:	00 00                	add    %al,(%eax)
  80131c:	00 00                	add    %al,(%eax)
	...

00801320 <__udivdi3>:
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	57                   	push   %edi
  801324:	56                   	push   %esi
  801325:	83 ec 10             	sub    $0x10,%esp
  801328:	8b 45 14             	mov    0x14(%ebp),%eax
  80132b:	8b 55 08             	mov    0x8(%ebp),%edx
  80132e:	8b 75 10             	mov    0x10(%ebp),%esi
  801331:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801334:	85 c0                	test   %eax,%eax
  801336:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801339:	75 35                	jne    801370 <__udivdi3+0x50>
  80133b:	39 fe                	cmp    %edi,%esi
  80133d:	77 61                	ja     8013a0 <__udivdi3+0x80>
  80133f:	85 f6                	test   %esi,%esi
  801341:	75 0b                	jne    80134e <__udivdi3+0x2e>
  801343:	b8 01 00 00 00       	mov    $0x1,%eax
  801348:	31 d2                	xor    %edx,%edx
  80134a:	f7 f6                	div    %esi
  80134c:	89 c6                	mov    %eax,%esi
  80134e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801351:	31 d2                	xor    %edx,%edx
  801353:	89 f8                	mov    %edi,%eax
  801355:	f7 f6                	div    %esi
  801357:	89 c7                	mov    %eax,%edi
  801359:	89 c8                	mov    %ecx,%eax
  80135b:	f7 f6                	div    %esi
  80135d:	89 c1                	mov    %eax,%ecx
  80135f:	89 fa                	mov    %edi,%edx
  801361:	89 c8                	mov    %ecx,%eax
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    
  80136a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801370:	39 f8                	cmp    %edi,%eax
  801372:	77 1c                	ja     801390 <__udivdi3+0x70>
  801374:	0f bd d0             	bsr    %eax,%edx
  801377:	83 f2 1f             	xor    $0x1f,%edx
  80137a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80137d:	75 39                	jne    8013b8 <__udivdi3+0x98>
  80137f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801382:	0f 86 a0 00 00 00    	jbe    801428 <__udivdi3+0x108>
  801388:	39 f8                	cmp    %edi,%eax
  80138a:	0f 82 98 00 00 00    	jb     801428 <__udivdi3+0x108>
  801390:	31 ff                	xor    %edi,%edi
  801392:	31 c9                	xor    %ecx,%ecx
  801394:	89 c8                	mov    %ecx,%eax
  801396:	89 fa                	mov    %edi,%edx
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	5e                   	pop    %esi
  80139c:	5f                   	pop    %edi
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    
  80139f:	90                   	nop
  8013a0:	89 d1                	mov    %edx,%ecx
  8013a2:	89 fa                	mov    %edi,%edx
  8013a4:	89 c8                	mov    %ecx,%eax
  8013a6:	31 ff                	xor    %edi,%edi
  8013a8:	f7 f6                	div    %esi
  8013aa:	89 c1                	mov    %eax,%ecx
  8013ac:	89 fa                	mov    %edi,%edx
  8013ae:	89 c8                	mov    %ecx,%eax
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	5e                   	pop    %esi
  8013b4:	5f                   	pop    %edi
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    
  8013b7:	90                   	nop
  8013b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013bc:	89 f2                	mov    %esi,%edx
  8013be:	d3 e0                	shl    %cl,%eax
  8013c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8013c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8013cb:	89 c1                	mov    %eax,%ecx
  8013cd:	d3 ea                	shr    %cl,%edx
  8013cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013d3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8013d6:	d3 e6                	shl    %cl,%esi
  8013d8:	89 c1                	mov    %eax,%ecx
  8013da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8013dd:	89 fe                	mov    %edi,%esi
  8013df:	d3 ee                	shr    %cl,%esi
  8013e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013eb:	d3 e7                	shl    %cl,%edi
  8013ed:	89 c1                	mov    %eax,%ecx
  8013ef:	d3 ea                	shr    %cl,%edx
  8013f1:	09 d7                	or     %edx,%edi
  8013f3:	89 f2                	mov    %esi,%edx
  8013f5:	89 f8                	mov    %edi,%eax
  8013f7:	f7 75 ec             	divl   -0x14(%ebp)
  8013fa:	89 d6                	mov    %edx,%esi
  8013fc:	89 c7                	mov    %eax,%edi
  8013fe:	f7 65 e8             	mull   -0x18(%ebp)
  801401:	39 d6                	cmp    %edx,%esi
  801403:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801406:	72 30                	jb     801438 <__udivdi3+0x118>
  801408:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80140f:	d3 e2                	shl    %cl,%edx
  801411:	39 c2                	cmp    %eax,%edx
  801413:	73 05                	jae    80141a <__udivdi3+0xfa>
  801415:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801418:	74 1e                	je     801438 <__udivdi3+0x118>
  80141a:	89 f9                	mov    %edi,%ecx
  80141c:	31 ff                	xor    %edi,%edi
  80141e:	e9 71 ff ff ff       	jmp    801394 <__udivdi3+0x74>
  801423:	90                   	nop
  801424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801428:	31 ff                	xor    %edi,%edi
  80142a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80142f:	e9 60 ff ff ff       	jmp    801394 <__udivdi3+0x74>
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80143b:	31 ff                	xor    %edi,%edi
  80143d:	89 c8                	mov    %ecx,%eax
  80143f:	89 fa                	mov    %edi,%edx
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	5e                   	pop    %esi
  801445:	5f                   	pop    %edi
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    
	...

00801450 <__umoddi3>:
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	57                   	push   %edi
  801454:	56                   	push   %esi
  801455:	83 ec 20             	sub    $0x20,%esp
  801458:	8b 55 14             	mov    0x14(%ebp),%edx
  80145b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801461:	8b 75 0c             	mov    0xc(%ebp),%esi
  801464:	85 d2                	test   %edx,%edx
  801466:	89 c8                	mov    %ecx,%eax
  801468:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80146b:	75 13                	jne    801480 <__umoddi3+0x30>
  80146d:	39 f7                	cmp    %esi,%edi
  80146f:	76 3f                	jbe    8014b0 <__umoddi3+0x60>
  801471:	89 f2                	mov    %esi,%edx
  801473:	f7 f7                	div    %edi
  801475:	89 d0                	mov    %edx,%eax
  801477:	31 d2                	xor    %edx,%edx
  801479:	83 c4 20             	add    $0x20,%esp
  80147c:	5e                   	pop    %esi
  80147d:	5f                   	pop    %edi
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    
  801480:	39 f2                	cmp    %esi,%edx
  801482:	77 4c                	ja     8014d0 <__umoddi3+0x80>
  801484:	0f bd ca             	bsr    %edx,%ecx
  801487:	83 f1 1f             	xor    $0x1f,%ecx
  80148a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80148d:	75 51                	jne    8014e0 <__umoddi3+0x90>
  80148f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801492:	0f 87 e0 00 00 00    	ja     801578 <__umoddi3+0x128>
  801498:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149b:	29 f8                	sub    %edi,%eax
  80149d:	19 d6                	sbb    %edx,%esi
  80149f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a5:	89 f2                	mov    %esi,%edx
  8014a7:	83 c4 20             	add    $0x20,%esp
  8014aa:	5e                   	pop    %esi
  8014ab:	5f                   	pop    %edi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    
  8014ae:	66 90                	xchg   %ax,%ax
  8014b0:	85 ff                	test   %edi,%edi
  8014b2:	75 0b                	jne    8014bf <__umoddi3+0x6f>
  8014b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b9:	31 d2                	xor    %edx,%edx
  8014bb:	f7 f7                	div    %edi
  8014bd:	89 c7                	mov    %eax,%edi
  8014bf:	89 f0                	mov    %esi,%eax
  8014c1:	31 d2                	xor    %edx,%edx
  8014c3:	f7 f7                	div    %edi
  8014c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c8:	f7 f7                	div    %edi
  8014ca:	eb a9                	jmp    801475 <__umoddi3+0x25>
  8014cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d0:	89 c8                	mov    %ecx,%eax
  8014d2:	89 f2                	mov    %esi,%edx
  8014d4:	83 c4 20             	add    $0x20,%esp
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    
  8014db:	90                   	nop
  8014dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8014e4:	d3 e2                	shl    %cl,%edx
  8014e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8014ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8014f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8014f8:	89 fa                	mov    %edi,%edx
  8014fa:	d3 ea                	shr    %cl,%edx
  8014fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801500:	0b 55 f4             	or     -0xc(%ebp),%edx
  801503:	d3 e7                	shl    %cl,%edi
  801505:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801509:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80150c:	89 f2                	mov    %esi,%edx
  80150e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801511:	89 c7                	mov    %eax,%edi
  801513:	d3 ea                	shr    %cl,%edx
  801515:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801519:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80151c:	89 c2                	mov    %eax,%edx
  80151e:	d3 e6                	shl    %cl,%esi
  801520:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801524:	d3 ea                	shr    %cl,%edx
  801526:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80152a:	09 d6                	or     %edx,%esi
  80152c:	89 f0                	mov    %esi,%eax
  80152e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801531:	d3 e7                	shl    %cl,%edi
  801533:	89 f2                	mov    %esi,%edx
  801535:	f7 75 f4             	divl   -0xc(%ebp)
  801538:	89 d6                	mov    %edx,%esi
  80153a:	f7 65 e8             	mull   -0x18(%ebp)
  80153d:	39 d6                	cmp    %edx,%esi
  80153f:	72 2b                	jb     80156c <__umoddi3+0x11c>
  801541:	39 c7                	cmp    %eax,%edi
  801543:	72 23                	jb     801568 <__umoddi3+0x118>
  801545:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801549:	29 c7                	sub    %eax,%edi
  80154b:	19 d6                	sbb    %edx,%esi
  80154d:	89 f0                	mov    %esi,%eax
  80154f:	89 f2                	mov    %esi,%edx
  801551:	d3 ef                	shr    %cl,%edi
  801553:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801557:	d3 e0                	shl    %cl,%eax
  801559:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80155d:	09 f8                	or     %edi,%eax
  80155f:	d3 ea                	shr    %cl,%edx
  801561:	83 c4 20             	add    $0x20,%esp
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    
  801568:	39 d6                	cmp    %edx,%esi
  80156a:	75 d9                	jne    801545 <__umoddi3+0xf5>
  80156c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80156f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801572:	eb d1                	jmp    801545 <__umoddi3+0xf5>
  801574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801578:	39 f2                	cmp    %esi,%edx
  80157a:	0f 82 18 ff ff ff    	jb     801498 <__umoddi3+0x48>
  801580:	e9 1d ff ff ff       	jmp    8014a2 <__umoddi3+0x52>
