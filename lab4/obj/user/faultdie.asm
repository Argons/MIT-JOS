
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	sys_env_destroy(sys_getenvid());
}

void
umain(void)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  800046:	c7 04 24 5e 00 80 00 	movl   $0x80005e,(%esp)
  80004d:	e8 02 0e 00 00       	call   800e54 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800052:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800059:	00 00 00 
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 18             	sub    $0x18,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800067:	8b 50 04             	mov    0x4(%eax),%edx
  80006a:	83 e2 07             	and    $0x7,%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	8b 00                	mov    (%eax),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  80007e:	e8 da 00 00 00       	call   80015d <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 b0 0b 00 00       	call   800c38 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 73 0b 00 00       	call   800c03 <sys_env_destroy>
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  8000a6:	e8 8d 0b 00 00       	call   800c38 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	89 c2                	mov    %eax,%edx
  8000b2:	c1 e2 07             	shl    $0x7,%edx
  8000b5:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000bc:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c1:	85 f6                	test   %esi,%esi
  8000c3:	7e 07                	jle    8000cc <libmain+0x38>
		binaryname = argv[0];
  8000c5:	8b 03                	mov    (%ebx),%eax
  8000c7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 68 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0b 00 00 00       	call   8000e8 <exit>
}
  8000dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    
	...

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 09 0b 00 00       	call   800c03 <sys_env_destroy>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800105:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010c:	00 00 00 
	b.cnt = 0;
  80010f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800116:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800120:	8b 45 08             	mov    0x8(%ebp),%eax
  800123:	89 44 24 08          	mov    %eax,0x8(%esp)
  800127:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800131:	c7 04 24 77 01 80 00 	movl   $0x800177,(%esp)
  800138:	e8 d3 01 00 00       	call   800310 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800143:	89 44 24 04          	mov    %eax,0x4(%esp)
  800147:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 47 0a 00 00       	call   800b9c <sys_cputs>

	return b.cnt;
}
  800155:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800163:	8d 45 0c             	lea    0xc(%ebp),%eax
  800166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 04 24             	mov    %eax,(%esp)
  800170:	e8 87 ff ff ff       	call   8000fc <vcprintf>
	va_end(ap);

	return cnt;
}
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	83 ec 14             	sub    $0x14,%esp
  80017e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800181:	8b 03                	mov    (%ebx),%eax
  800183:	8b 55 08             	mov    0x8(%ebp),%edx
  800186:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018a:	83 c0 01             	add    $0x1,%eax
  80018d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800194:	75 19                	jne    8001af <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800196:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80019d:	00 
  80019e:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 f3 09 00 00       	call   800b9c <sys_cputs>
		b->idx = 0;
  8001a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b3:	83 c4 14             	add    $0x14,%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5d                   	pop    %ebp
  8001b8:	c3                   	ret    
  8001b9:	00 00                	add    %al,(%eax)
  8001bb:	00 00                	add    %al,(%eax)
  8001bd:	00 00                	add    %al,(%eax)
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001eb:	39 d1                	cmp    %edx,%ecx
  8001ed:	72 15                	jb     800204 <printnum+0x44>
  8001ef:	77 07                	ja     8001f8 <printnum+0x38>
  8001f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001f4:	39 d0                	cmp    %edx,%eax
  8001f6:	76 0c                	jbe    800204 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	85 db                	test   %ebx,%ebx
  8001fd:	8d 76 00             	lea    0x0(%esi),%esi
  800200:	7f 61                	jg     800263 <printnum+0xa3>
  800202:	eb 70                	jmp    800274 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800204:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800217:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80021b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80021e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800221:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800224:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022f:	00 
  800230:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800239:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023d:	e8 0e 0d 00 00       	call   800f50 <__udivdi3>
  800242:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800245:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	89 54 24 04          	mov    %edx,0x4(%esp)
  800257:	89 f2                	mov    %esi,%edx
  800259:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025c:	e8 5f ff ff ff       	call   8001c0 <printnum>
  800261:	eb 11                	jmp    800274 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800263:	89 74 24 04          	mov    %esi,0x4(%esp)
  800267:	89 3c 24             	mov    %edi,(%esp)
  80026a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026d:	83 eb 01             	sub    $0x1,%ebx
  800270:	85 db                	test   %ebx,%ebx
  800272:	7f ef                	jg     800263 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800274:	89 74 24 04          	mov    %esi,0x4(%esp)
  800278:	8b 74 24 04          	mov    0x4(%esp),%esi
  80027c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028a:	00 
  80028b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80028e:	89 14 24             	mov    %edx,(%esp)
  800291:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800294:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800298:	e8 e3 0d 00 00       	call   801080 <__umoddi3>
  80029d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a1:	0f be 80 f3 11 80 00 	movsbl 0x8011f3(%eax),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ae:	83 c4 4c             	add    $0x4c,%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b9:	83 fa 01             	cmp    $0x1,%edx
  8002bc:	7e 0f                	jle    8002cd <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	83 c2 08             	add    $0x8,%edx
  8002c3:	89 10                	mov    %edx,(%eax)
  8002c5:	8b 42 f8             	mov    -0x8(%edx),%eax
  8002c8:	8b 52 fc             	mov    -0x4(%edx),%edx
  8002cb:	eb 24                	jmp    8002f1 <getuint+0x3b>
	else if (lflag)
  8002cd:	85 d2                	test   %edx,%edx
  8002cf:	74 11                	je     8002e2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	83 c2 04             	add    $0x4,%edx
  8002d6:	89 10                	mov    %edx,(%eax)
  8002d8:	8b 42 fc             	mov    -0x4(%edx),%eax
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e0:	eb 0f                	jmp    8002f1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	83 c2 04             	add    $0x4,%edx
  8002e7:	89 10                	mov    %edx,(%eax)
  8002e9:	8b 42 fc             	mov    -0x4(%edx),%eax
  8002ec:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 0a                	jae    80030e <sprintputch+0x1b>
		*b->buf++ = ch;
  800304:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800307:	88 0a                	mov    %cl,(%edx)
  800309:	83 c2 01             	add    $0x1,%edx
  80030c:	89 10                	mov    %edx,(%eax)
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 5c             	sub    $0x5c,%esp
  800319:	8b 7d 08             	mov    0x8(%ebp),%edi
  80031c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800322:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800329:	eb 11                	jmp    80033c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032b:	85 c0                	test   %eax,%eax
  80032d:	0f 84 fd 03 00 00    	je     800730 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800333:	89 74 24 04          	mov    %esi,0x4(%esp)
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033c:	0f b6 03             	movzbl (%ebx),%eax
  80033f:	83 c3 01             	add    $0x1,%ebx
  800342:	83 f8 25             	cmp    $0x25,%eax
  800345:	75 e4                	jne    80032b <vprintfmt+0x1b>
  800347:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80034b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800359:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800360:	b9 00 00 00 00       	mov    $0x0,%ecx
  800365:	eb 06                	jmp    80036d <vprintfmt+0x5d>
  800367:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80036b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	0f b6 13             	movzbl (%ebx),%edx
  800370:	0f b6 c2             	movzbl %dl,%eax
  800373:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800376:	8d 43 01             	lea    0x1(%ebx),%eax
  800379:	83 ea 23             	sub    $0x23,%edx
  80037c:	80 fa 55             	cmp    $0x55,%dl
  80037f:	0f 87 8e 03 00 00    	ja     800713 <vprintfmt+0x403>
  800385:	0f b6 d2             	movzbl %dl,%edx
  800388:	ff 24 95 c0 12 80 00 	jmp    *0x8012c0(,%edx,4)
  80038f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800393:	eb d6                	jmp    80036b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800395:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800398:	83 ea 30             	sub    $0x30,%edx
  80039b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80039e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003a1:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003a4:	83 fb 09             	cmp    $0x9,%ebx
  8003a7:	77 55                	ja     8003fe <vprintfmt+0xee>
  8003a9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003ac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003af:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003b2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003b5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003b9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003bc:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003bf:	83 fb 09             	cmp    $0x9,%ebx
  8003c2:	76 eb                	jbe    8003af <vprintfmt+0x9f>
  8003c4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ca:	eb 32                	jmp    8003fe <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cc:	8b 55 14             	mov    0x14(%ebp),%edx
  8003cf:	83 c2 04             	add    $0x4,%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 52 fc             	mov    -0x4(%edx),%edx
  8003d8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8003db:	eb 21                	jmp    8003fe <vprintfmt+0xee>

		case '.':
			if (width < 0)
  8003dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8003ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003ed:	e9 79 ff ff ff       	jmp    80036b <vprintfmt+0x5b>
  8003f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003f9:	e9 6d ff ff ff       	jmp    80036b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800402:	0f 89 63 ff ff ff    	jns    80036b <vprintfmt+0x5b>
  800408:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80040b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80040e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800411:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800414:	e9 52 ff ff ff       	jmp    80036b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800419:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80041c:	e9 4a ff ff ff       	jmp    80036b <vprintfmt+0x5b>
  800421:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	83 c0 04             	add    $0x4,%eax
  80042a:	89 45 14             	mov    %eax,0x14(%ebp)
  80042d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800431:	8b 40 fc             	mov    -0x4(%eax),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	ff d7                	call   *%edi
  800439:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80043c:	e9 fb fe ff ff       	jmp    80033c <vprintfmt+0x2c>
  800441:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	83 c0 04             	add    $0x4,%eax
  80044a:	89 45 14             	mov    %eax,0x14(%ebp)
  80044d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800450:	89 c2                	mov    %eax,%edx
  800452:	c1 fa 1f             	sar    $0x1f,%edx
  800455:	31 d0                	xor    %edx,%eax
  800457:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800459:	83 f8 08             	cmp    $0x8,%eax
  80045c:	7f 0b                	jg     800469 <vprintfmt+0x159>
  80045e:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  800465:	85 d2                	test   %edx,%edx
  800467:	75 20                	jne    800489 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800469:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046d:	c7 44 24 08 04 12 80 	movl   $0x801204,0x8(%esp)
  800474:	00 
  800475:	89 74 24 04          	mov    %esi,0x4(%esp)
  800479:	89 3c 24             	mov    %edi,(%esp)
  80047c:	e8 37 03 00 00       	call   8007b8 <printfmt>
  800481:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800484:	e9 b3 fe ff ff       	jmp    80033c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800489:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048d:	c7 44 24 08 0d 12 80 	movl   $0x80120d,0x8(%esp)
  800494:	00 
  800495:	89 74 24 04          	mov    %esi,0x4(%esp)
  800499:	89 3c 24             	mov    %edi,(%esp)
  80049c:	e8 17 03 00 00       	call   8007b8 <printfmt>
  8004a1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8004a4:	e9 93 fe ff ff       	jmp    80033c <vprintfmt+0x2c>
  8004a9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004b4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	83 c0 04             	add    $0x4,%eax
  8004bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c0:	8b 40 fc             	mov    -0x4(%eax),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	b8 10 12 80 00       	mov    $0x801210,%eax
  8004cd:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  8004d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004d4:	85 c9                	test   %ecx,%ecx
  8004d6:	7e 06                	jle    8004de <vprintfmt+0x1ce>
  8004d8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004dc:	75 13                	jne    8004f1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e1:	0f be 02             	movsbl (%edx),%eax
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	0f 85 99 00 00 00    	jne    800585 <vprintfmt+0x275>
  8004ec:	e9 86 00 00 00       	jmp    800577 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f8:	89 0c 24             	mov    %ecx,(%esp)
  8004fb:	e8 fb 02 00 00       	call   8007fb <strnlen>
  800500:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800508:	85 d2                	test   %edx,%edx
  80050a:	7e d2                	jle    8004de <vprintfmt+0x1ce>
					putch(padc, putdat);
  80050c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800510:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800513:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800516:	89 d3                	mov    %edx,%ebx
  800518:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 eb 01             	sub    $0x1,%ebx
  800527:	85 db                	test   %ebx,%ebx
  800529:	7f ed                	jg     800518 <vprintfmt+0x208>
  80052b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80052e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800535:	eb a7                	jmp    8004de <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053b:	74 18                	je     800555 <vprintfmt+0x245>
  80053d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800540:	83 fa 5e             	cmp    $0x5e,%edx
  800543:	76 10                	jbe    800555 <vprintfmt+0x245>
					putch('?', putdat);
  800545:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800549:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800550:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800553:	eb 0a                	jmp    80055f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	89 04 24             	mov    %eax,(%esp)
  80055c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800563:	0f be 03             	movsbl (%ebx),%eax
  800566:	85 c0                	test   %eax,%eax
  800568:	74 05                	je     80056f <vprintfmt+0x25f>
  80056a:	83 c3 01             	add    $0x1,%ebx
  80056d:	eb 29                	jmp    800598 <vprintfmt+0x288>
  80056f:	89 fe                	mov    %edi,%esi
  800571:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800574:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800577:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057b:	7f 2e                	jg     8005ab <vprintfmt+0x29b>
  80057d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800580:	e9 b7 fd ff ff       	jmp    80033c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800585:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800588:	83 c2 01             	add    $0x1,%edx
  80058b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80058e:	89 f7                	mov    %esi,%edi
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800596:	89 d3                	mov    %edx,%ebx
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 9b                	js     800537 <vprintfmt+0x227>
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	79 96                	jns    800537 <vprintfmt+0x227>
  8005a1:	89 fe                	mov    %edi,%esi
  8005a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005a6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a9:	eb cc                	jmp    800577 <vprintfmt+0x267>
  8005ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005ae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005bc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005be:	83 eb 01             	sub    $0x1,%ebx
  8005c1:	85 db                	test   %ebx,%ebx
  8005c3:	7f ec                	jg     8005b1 <vprintfmt+0x2a1>
  8005c5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005c8:	e9 6f fd ff ff       	jmp    80033c <vprintfmt+0x2c>
  8005cd:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 f9 01             	cmp    $0x1,%ecx
  8005d3:	7e 17                	jle    8005ec <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	83 c0 08             	add    $0x8,%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
  8005de:	8b 50 f8             	mov    -0x8(%eax),%edx
  8005e1:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8005e4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ea:	eb 34                	jmp    800620 <vprintfmt+0x310>
	else if (lflag)
  8005ec:	85 c9                	test   %ecx,%ecx
  8005ee:	74 19                	je     800609 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	83 c0 04             	add    $0x4,%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f9:	8b 40 fc             	mov    -0x4(%eax),%eax
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	89 c1                	mov    %eax,%ecx
  800601:	c1 f9 1f             	sar    $0x1f,%ecx
  800604:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800607:	eb 17                	jmp    800620 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	83 c0 04             	add    $0x4,%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
  800612:	8b 40 fc             	mov    -0x4(%eax),%eax
  800615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800618:	89 c2                	mov    %eax,%edx
  80061a:	c1 fa 1f             	sar    $0x1f,%edx
  80061d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800620:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800623:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80062b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062f:	0f 89 9c 00 00 00    	jns    8006d1 <vprintfmt+0x3c1>
				putch('-', putdat);
  800635:	89 74 24 04          	mov    %esi,0x4(%esp)
  800639:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800640:	ff d7                	call   *%edi
				num = -(long long) num;
  800642:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800645:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800648:	f7 d9                	neg    %ecx
  80064a:	83 d3 00             	adc    $0x0,%ebx
  80064d:	f7 db                	neg    %ebx
  80064f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800654:	eb 7b                	jmp    8006d1 <vprintfmt+0x3c1>
  800656:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800659:	89 ca                	mov    %ecx,%edx
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 53 fc ff ff       	call   8002b6 <getuint>
  800663:	89 c1                	mov    %eax,%ecx
  800665:	89 d3                	mov    %edx,%ebx
  800667:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80066c:	eb 63                	jmp    8006d1 <vprintfmt+0x3c1>
  80066e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800671:	89 ca                	mov    %ecx,%edx
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 3b fc ff ff       	call   8002b6 <getuint>
  80067b:	89 c1                	mov    %eax,%ecx
  80067d:	89 d3                	mov    %edx,%ebx
  80067f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800684:	eb 4b                	jmp    8006d1 <vprintfmt+0x3c1>
  800686:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800689:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800694:	ff d7                	call   *%edi
			putch('x', putdat);
  800696:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	83 c0 04             	add    $0x4,%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ac:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8006af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b4:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b9:	eb 16                	jmp    8006d1 <vprintfmt+0x3c1>
  8006bb:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006be:	89 ca                	mov    %ecx,%edx
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c3:	e8 ee fb ff ff       	call   8002b6 <getuint>
  8006c8:	89 c1                	mov    %eax,%ecx
  8006ca:	89 d3                	mov    %edx,%ebx
  8006cc:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e4:	89 0c 24             	mov    %ecx,(%esp)
  8006e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006eb:	89 f2                	mov    %esi,%edx
  8006ed:	89 f8                	mov    %edi,%eax
  8006ef:	e8 cc fa ff ff       	call   8001c0 <printnum>
  8006f4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006f7:	e9 40 fc ff ff       	jmp    80033c <vprintfmt+0x2c>
  8006fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006ff:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800702:	89 74 24 04          	mov    %esi,0x4(%esp)
  800706:	89 14 24             	mov    %edx,(%esp)
  800709:	ff d7                	call   *%edi
  80070b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80070e:	e9 29 fc ff ff       	jmp    80033c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800713:	89 74 24 04          	mov    %esi,0x4(%esp)
  800717:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800720:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800723:	80 38 25             	cmpb   $0x25,(%eax)
  800726:	0f 84 10 fc ff ff    	je     80033c <vprintfmt+0x2c>
  80072c:	89 c3                	mov    %eax,%ebx
  80072e:	eb f0                	jmp    800720 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800730:	83 c4 5c             	add    $0x5c,%esp
  800733:	5b                   	pop    %ebx
  800734:	5e                   	pop    %esi
  800735:	5f                   	pop    %edi
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	83 ec 28             	sub    $0x28,%esp
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800744:	85 c0                	test   %eax,%eax
  800746:	74 04                	je     80074c <vsnprintf+0x14>
  800748:	85 d2                	test   %edx,%edx
  80074a:	7f 07                	jg     800753 <vsnprintf+0x1b>
  80074c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800751:	eb 3b                	jmp    80078e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800753:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800756:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80075a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80075d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076b:	8b 45 10             	mov    0x10(%ebp),%eax
  80076e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800772:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800775:	89 44 24 04          	mov    %eax,0x4(%esp)
  800779:	c7 04 24 f3 02 80 00 	movl   $0x8002f3,(%esp)
  800780:	e8 8b fb ff ff       	call   800310 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800785:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800788:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
  800799:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079d:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	e8 82 ff ff ff       	call   800738 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	e8 32 fb ff ff       	call   800310 <vprintfmt>
	va_end(ap);
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ee:	74 09                	je     8007f9 <strlen+0x19>
		n++;
  8007f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f7:	75 f7                	jne    8007f0 <strlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	85 c9                	test   %ecx,%ecx
  800807:	74 19                	je     800822 <strnlen+0x27>
  800809:	80 3b 00             	cmpb   $0x0,(%ebx)
  80080c:	74 14                	je     800822 <strnlen+0x27>
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800813:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800816:	39 c8                	cmp    %ecx,%eax
  800818:	74 0d                	je     800827 <strnlen+0x2c>
  80081a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80081e:	75 f3                	jne    800813 <strnlen+0x18>
  800820:	eb 05                	jmp    800827 <strnlen+0x2c>
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800834:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80083d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	84 c9                	test   %cl,%cl
  800845:	75 f2                	jne    800839 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	85 f6                	test   %esi,%esi
  80085a:	74 18                	je     800874 <strncpy+0x2a>
  80085c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800861:	0f b6 1a             	movzbl (%edx),%ebx
  800864:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 3a 01             	cmpb   $0x1,(%edx)
  80086a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	83 c1 01             	add    $0x1,%ecx
  800870:	39 ce                	cmp    %ecx,%esi
  800872:	77 ed                	ja     800861 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	89 f0                	mov    %esi,%eax
  800888:	85 c9                	test   %ecx,%ecx
  80088a:	74 27                	je     8008b3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80088c:	83 e9 01             	sub    $0x1,%ecx
  80088f:	74 1d                	je     8008ae <strlcpy+0x36>
  800891:	0f b6 1a             	movzbl (%edx),%ebx
  800894:	84 db                	test   %bl,%bl
  800896:	74 16                	je     8008ae <strlcpy+0x36>
			*dst++ = *src++;
  800898:	88 18                	mov    %bl,(%eax)
  80089a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089d:	83 e9 01             	sub    $0x1,%ecx
  8008a0:	74 0e                	je     8008b0 <strlcpy+0x38>
			*dst++ = *src++;
  8008a2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a5:	0f b6 1a             	movzbl (%edx),%ebx
  8008a8:	84 db                	test   %bl,%bl
  8008aa:	75 ec                	jne    800898 <strlcpy+0x20>
  8008ac:	eb 02                	jmp    8008b0 <strlcpy+0x38>
  8008ae:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b0:	c6 00 00             	movb   $0x0,(%eax)
  8008b3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c2:	0f b6 01             	movzbl (%ecx),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 15                	je     8008de <strcmp+0x25>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	75 11                	jne    8008de <strcmp+0x25>
		p++, q++;
  8008cd:	83 c1 01             	add    $0x1,%ecx
  8008d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d3:	0f b6 01             	movzbl (%ecx),%eax
  8008d6:	84 c0                	test   %al,%al
  8008d8:	74 04                	je     8008de <strcmp+0x25>
  8008da:	3a 02                	cmp    (%edx),%al
  8008dc:	74 ef                	je     8008cd <strcmp+0x14>
  8008de:	0f b6 c0             	movzbl %al,%eax
  8008e1:	0f b6 12             	movzbl (%edx),%edx
  8008e4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	53                   	push   %ebx
  8008ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	74 23                	je     80091c <strncmp+0x34>
  8008f9:	0f b6 1a             	movzbl (%edx),%ebx
  8008fc:	84 db                	test   %bl,%bl
  8008fe:	74 24                	je     800924 <strncmp+0x3c>
  800900:	3a 19                	cmp    (%ecx),%bl
  800902:	75 20                	jne    800924 <strncmp+0x3c>
  800904:	83 e8 01             	sub    $0x1,%eax
  800907:	74 13                	je     80091c <strncmp+0x34>
		n--, p++, q++;
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80090f:	0f b6 1a             	movzbl (%edx),%ebx
  800912:	84 db                	test   %bl,%bl
  800914:	74 0e                	je     800924 <strncmp+0x3c>
  800916:	3a 19                	cmp    (%ecx),%bl
  800918:	74 ea                	je     800904 <strncmp+0x1c>
  80091a:	eb 08                	jmp    800924 <strncmp+0x3c>
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800921:	5b                   	pop    %ebx
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800924:	0f b6 02             	movzbl (%edx),%eax
  800927:	0f b6 11             	movzbl (%ecx),%edx
  80092a:	29 d0                	sub    %edx,%eax
  80092c:	eb f3                	jmp    800921 <strncmp+0x39>

0080092e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800938:	0f b6 10             	movzbl (%eax),%edx
  80093b:	84 d2                	test   %dl,%dl
  80093d:	74 15                	je     800954 <strchr+0x26>
		if (*s == c)
  80093f:	38 ca                	cmp    %cl,%dl
  800941:	75 07                	jne    80094a <strchr+0x1c>
  800943:	eb 14                	jmp    800959 <strchr+0x2b>
  800945:	38 ca                	cmp    %cl,%dl
  800947:	90                   	nop
  800948:	74 0f                	je     800959 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f1                	jne    800945 <strchr+0x17>
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	0f b6 10             	movzbl (%eax),%edx
  800968:	84 d2                	test   %dl,%dl
  80096a:	74 18                	je     800984 <strfind+0x29>
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	75 0a                	jne    80097a <strfind+0x1f>
  800970:	eb 12                	jmp    800984 <strfind+0x29>
  800972:	38 ca                	cmp    %cl,%dl
  800974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800978:	74 0a                	je     800984 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	84 d2                	test   %dl,%dl
  800982:	75 ee                	jne    800972 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800990:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800993:	89 da                	mov    %ebx,%edx
  800995:	83 ea 01             	sub    $0x1,%edx
  800998:	78 0d                	js     8009a7 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  80099a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80099c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  80099e:	88 0a                	mov    %cl,(%edx)
  8009a0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009a3:	39 da                	cmp    %ebx,%edx
  8009a5:	75 f7                	jne    80099e <memset+0x18>
		*p++ = c;

	return v;
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8009b8:	85 db                	test   %ebx,%ebx
  8009ba:	74 13                	je     8009cf <memcpy+0x25>
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  8009c1:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009c5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009c8:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8009cb:	39 da                	cmp    %ebx,%edx
  8009cd:	75 f2                	jne    8009c1 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  8009e2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  8009e4:	39 c6                	cmp    %eax,%esi
  8009e6:	72 0b                	jb     8009f3 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  8009e8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  8009ed:	85 db                	test   %ebx,%ebx
  8009ef:	75 2e                	jne    800a1f <memmove+0x4c>
  8009f1:	eb 3a                	jmp    800a2d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f3:	01 df                	add    %ebx,%edi
  8009f5:	39 f8                	cmp    %edi,%eax
  8009f7:	73 ef                	jae    8009e8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	90                   	nop
  8009fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a00:	74 2b                	je     800a2d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a02:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800a0a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800a0f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800a13:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a16:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800a19:	85 c9                	test   %ecx,%ecx
  800a1b:	75 ed                	jne    800a0a <memmove+0x37>
  800a1d:	eb 0e                	jmp    800a2d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a1f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a23:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a26:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a29:	39 d3                	cmp    %edx,%ebx
  800a2b:	75 f2                	jne    800a1f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	57                   	push   %edi
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a41:	85 c9                	test   %ecx,%ecx
  800a43:	74 36                	je     800a7b <memcmp+0x49>
		if (*s1 != *s2)
  800a45:	0f b6 06             	movzbl (%esi),%eax
  800a48:	0f b6 1f             	movzbl (%edi),%ebx
  800a4b:	38 d8                	cmp    %bl,%al
  800a4d:	74 20                	je     800a6f <memcmp+0x3d>
  800a4f:	eb 14                	jmp    800a65 <memcmp+0x33>
  800a51:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800a56:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	83 e9 01             	sub    $0x1,%ecx
  800a61:	38 d8                	cmp    %bl,%al
  800a63:	74 12                	je     800a77 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800a65:	0f b6 c0             	movzbl %al,%eax
  800a68:	0f b6 db             	movzbl %bl,%ebx
  800a6b:	29 d8                	sub    %ebx,%eax
  800a6d:	eb 11                	jmp    800a80 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	83 e9 01             	sub    $0x1,%ecx
  800a72:	ba 00 00 00 00       	mov    $0x0,%edx
  800a77:	85 c9                	test   %ecx,%ecx
  800a79:	75 d6                	jne    800a51 <memcmp+0x1f>
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a8b:	89 c2                	mov    %eax,%edx
  800a8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a90:	39 d0                	cmp    %edx,%eax
  800a92:	73 15                	jae    800aa9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a98:	38 08                	cmp    %cl,(%eax)
  800a9a:	75 06                	jne    800aa2 <memfind+0x1d>
  800a9c:	eb 0b                	jmp    800aa9 <memfind+0x24>
  800a9e:	38 08                	cmp    %cl,(%eax)
  800aa0:	74 07                	je     800aa9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	39 c2                	cmp    %eax,%edx
  800aa7:	77 f5                	ja     800a9e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 04             	sub    $0x4,%esp
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aba:	0f b6 02             	movzbl (%edx),%eax
  800abd:	3c 20                	cmp    $0x20,%al
  800abf:	74 04                	je     800ac5 <strtol+0x1a>
  800ac1:	3c 09                	cmp    $0x9,%al
  800ac3:	75 0e                	jne    800ad3 <strtol+0x28>
		s++;
  800ac5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac8:	0f b6 02             	movzbl (%edx),%eax
  800acb:	3c 20                	cmp    $0x20,%al
  800acd:	74 f6                	je     800ac5 <strtol+0x1a>
  800acf:	3c 09                	cmp    $0x9,%al
  800ad1:	74 f2                	je     800ac5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad3:	3c 2b                	cmp    $0x2b,%al
  800ad5:	75 0c                	jne    800ae3 <strtol+0x38>
		s++;
  800ad7:	83 c2 01             	add    $0x1,%edx
  800ada:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ae1:	eb 15                	jmp    800af8 <strtol+0x4d>
	else if (*s == '-')
  800ae3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800aea:	3c 2d                	cmp    $0x2d,%al
  800aec:	75 0a                	jne    800af8 <strtol+0x4d>
		s++, neg = 1;
  800aee:	83 c2 01             	add    $0x1,%edx
  800af1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af8:	85 db                	test   %ebx,%ebx
  800afa:	0f 94 c0             	sete   %al
  800afd:	74 05                	je     800b04 <strtol+0x59>
  800aff:	83 fb 10             	cmp    $0x10,%ebx
  800b02:	75 18                	jne    800b1c <strtol+0x71>
  800b04:	80 3a 30             	cmpb   $0x30,(%edx)
  800b07:	75 13                	jne    800b1c <strtol+0x71>
  800b09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b0d:	8d 76 00             	lea    0x0(%esi),%esi
  800b10:	75 0a                	jne    800b1c <strtol+0x71>
		s += 2, base = 16;
  800b12:	83 c2 02             	add    $0x2,%edx
  800b15:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	eb 15                	jmp    800b31 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1c:	84 c0                	test   %al,%al
  800b1e:	66 90                	xchg   %ax,%ax
  800b20:	74 0f                	je     800b31 <strtol+0x86>
  800b22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b27:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2a:	75 05                	jne    800b31 <strtol+0x86>
		s++, base = 8;
  800b2c:	83 c2 01             	add    $0x1,%edx
  800b2f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b38:	0f b6 0a             	movzbl (%edx),%ecx
  800b3b:	89 cf                	mov    %ecx,%edi
  800b3d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b40:	80 fb 09             	cmp    $0x9,%bl
  800b43:	77 08                	ja     800b4d <strtol+0xa2>
			dig = *s - '0';
  800b45:	0f be c9             	movsbl %cl,%ecx
  800b48:	83 e9 30             	sub    $0x30,%ecx
  800b4b:	eb 1e                	jmp    800b6b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b4d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b50:	80 fb 19             	cmp    $0x19,%bl
  800b53:	77 08                	ja     800b5d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800b55:	0f be c9             	movsbl %cl,%ecx
  800b58:	83 e9 57             	sub    $0x57,%ecx
  800b5b:	eb 0e                	jmp    800b6b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800b5d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b60:	80 fb 19             	cmp    $0x19,%bl
  800b63:	77 15                	ja     800b7a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800b65:	0f be c9             	movsbl %cl,%ecx
  800b68:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b6b:	39 f1                	cmp    %esi,%ecx
  800b6d:	7d 0b                	jge    800b7a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800b6f:	83 c2 01             	add    $0x1,%edx
  800b72:	0f af c6             	imul   %esi,%eax
  800b75:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b78:	eb be                	jmp    800b38 <strtol+0x8d>
  800b7a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b80:	74 05                	je     800b87 <strtol+0xdc>
		*endptr = (char *) s;
  800b82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b85:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b87:	89 ca                	mov    %ecx,%edx
  800b89:	f7 da                	neg    %edx
  800b8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b8f:	0f 45 c2             	cmovne %edx,%eax
}
  800b92:	83 c4 04             	add    $0x4,%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
	...

00800b9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	89 1c 24             	mov    %ebx,(%esp)
  800ba5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	89 c3                	mov    %eax,%ebx
  800bba:	89 c7                	mov    %eax,%edi
  800bbc:	89 c6                	mov    %eax,%esi
  800bbe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800bc0:	8b 1c 24             	mov    (%esp),%ebx
  800bc3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bc7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bcb:	89 ec                	mov    %ebp,%esp
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_cgetc>:

int
sys_cgetc(void)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	89 1c 24             	mov    %ebx,(%esp)
  800bd8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bdc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bea:	89 d1                	mov    %edx,%ecx
  800bec:	89 d3                	mov    %edx,%ebx
  800bee:	89 d7                	mov    %edx,%edi
  800bf0:	89 d6                	mov    %edx,%esi
  800bf2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800bf4:	8b 1c 24             	mov    (%esp),%ebx
  800bf7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bfb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bff:	89 ec                	mov    %ebp,%esp
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	89 1c 24             	mov    %ebx,(%esp)
  800c0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c10:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c19:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 cb                	mov    %ecx,%ebx
  800c23:	89 cf                	mov    %ecx,%edi
  800c25:	89 ce                	mov    %ecx,%esi
  800c27:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800c29:	8b 1c 24             	mov    (%esp),%ebx
  800c2c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c30:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c34:	89 ec                	mov    %ebp,%esp
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	89 1c 24             	mov    %ebx,(%esp)
  800c41:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c45:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800c5d:	8b 1c 24             	mov    (%esp),%ebx
  800c60:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c68:	89 ec                	mov    %ebp,%esp
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_yield>:

void
sys_yield(void)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	89 1c 24             	mov    %ebx,(%esp)
  800c75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c79:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c82:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c87:	89 d1                	mov    %edx,%ecx
  800c89:	89 d3                	mov    %edx,%ebx
  800c8b:	89 d7                	mov    %edx,%edi
  800c8d:	89 d6                	mov    %edx,%esi
  800c8f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800c91:	8b 1c 24             	mov    (%esp),%ebx
  800c94:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c98:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c9c:	89 ec                	mov    %ebp,%esp
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	89 1c 24             	mov    %ebx,(%esp)
  800ca9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cad:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	be 00 00 00 00       	mov    $0x0,%esi
  800cb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800cbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	89 f7                	mov    %esi,%edi
  800cc6:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800cc8:	8b 1c 24             	mov    (%esp),%ebx
  800ccb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ccf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cd3:	89 ec                	mov    %ebp,%esp
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	89 1c 24             	mov    %ebx,(%esp)
  800ce0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ced:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cfe:	8b 1c 24             	mov    (%esp),%ebx
  800d01:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d05:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d09:	89 ec                	mov    %ebp,%esp
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	89 1c 24             	mov    %ebx,(%esp)
  800d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d1a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	b8 06 00 00 00       	mov    $0x6,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800d34:	8b 1c 24             	mov    (%esp),%ebx
  800d37:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d3b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d3f:	89 ec                	mov    %ebp,%esp
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	89 1c 24             	mov    %ebx,(%esp)
  800d4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d50:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d59:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 df                	mov    %ebx,%edi
  800d66:	89 de                	mov    %ebx,%esi
  800d68:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800d6a:	8b 1c 24             	mov    (%esp),%ebx
  800d6d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d71:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d75:	89 ec                	mov    %ebp,%esp
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	89 1c 24             	mov    %ebx,(%esp)
  800d82:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d86:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 df                	mov    %ebx,%edi
  800d9c:	89 de                	mov    %ebx,%esi
  800d9e:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800da0:	8b 1c 24             	mov    (%esp),%ebx
  800da3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dab:	89 ec                	mov    %ebp,%esp
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	89 1c 24             	mov    %ebx,(%esp)
  800db8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dbc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 df                	mov    %ebx,%edi
  800dd2:	89 de                	mov    %ebx,%esi
  800dd4:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd6:	8b 1c 24             	mov    (%esp),%ebx
  800dd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ddd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800de1:	89 ec                	mov    %ebp,%esp
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	89 1c 24             	mov    %ebx,(%esp)
  800dee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800df2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	be 00 00 00 00       	mov    $0x0,%esi
  800dfb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0e:	8b 1c 24             	mov    (%esp),%ebx
  800e11:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e15:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e19:	89 ec                	mov    %ebp,%esp
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800e2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e33:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	89 cb                	mov    %ecx,%ebx
  800e3d:	89 cf                	mov    %ecx,%edi
  800e3f:	89 ce                	mov    %ecx,%esi
  800e41:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800e43:	8b 1c 24             	mov    (%esp),%ebx
  800e46:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e4a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e4e:	89 ec                	mov    %ebp,%esp
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
	...

00800e54 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e5a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e61:	75 54                	jne    800eb7 <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  800e63:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e6a:	00 
  800e6b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e72:	ee 
  800e73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e7a:	e8 21 fe ff ff       	call   800ca0 <sys_page_alloc>
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	79 20                	jns    800ea3 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  800e83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e87:	c7 44 24 08 44 14 80 	movl   $0x801444,0x8(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800e96:	00 
  800e97:	c7 04 24 5c 14 80 00 	movl   $0x80145c,(%esp)
  800e9e:	e8 49 00 00 00       	call   800eec <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  800ea3:	c7 44 24 04 c4 0e 80 	movl   $0x800ec4,0x4(%esp)
  800eaa:	00 
  800eab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb2:	e8 f8 fe ff ff       	call   800daf <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    
  800ec1:	00 00                	add    %al,(%eax)
	...

00800ec4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ec4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ec5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800eca:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ecc:	83 c4 04             	add    $0x4,%esp
	// Hints:
	//   What registers are available for intermediate calculations?
	//
	// LAB 4: Your code here.
	
	movl	0x30(%esp), %eax
  800ecf:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl	$0x4, %eax
  800ed3:	83 e8 04             	sub    $0x4,%eax
	movl	%eax, 0x30(%esp)
  800ed6:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl	0x28(%esp), %ebx
  800eda:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl	%ebx, (%eax)
  800ede:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.
	// LAB 4: Your code here.

	addl	$0x8, %esp
  800ee0:	83 c4 08             	add    $0x8,%esp
	popal
  800ee3:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.

	addl	$0x4, %esp
  800ee4:	83 c4 04             	add    $0x4,%esp
	popfl
  800ee7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	pop	%esp
  800ee8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800ee9:	c3                   	ret    
	...

00800eec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800ef2:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	74 10                	je     800f0b <_panic+0x1f>
		cprintf("%s: ", argv0);
  800efb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eff:	c7 04 24 6a 14 80 00 	movl   $0x80146a,(%esp)
  800f06:	e8 52 f2 ff ff       	call   80015d <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f19:	a1 00 20 80 00       	mov    0x802000,%eax
  800f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f22:	c7 04 24 6f 14 80 00 	movl   $0x80146f,(%esp)
  800f29:	e8 2f f2 ff ff       	call   80015d <cprintf>
	vcprintf(fmt, ap);
  800f2e:	8d 45 14             	lea    0x14(%ebp),%eax
  800f31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f35:	8b 45 10             	mov    0x10(%ebp),%eax
  800f38:	89 04 24             	mov    %eax,(%esp)
  800f3b:	e8 bc f1 ff ff       	call   8000fc <vcprintf>
	cprintf("\n");
  800f40:	c7 04 24 da 11 80 00 	movl   $0x8011da,(%esp)
  800f47:	e8 11 f2 ff ff       	call   80015d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f4c:	cc                   	int3   
  800f4d:	eb fd                	jmp    800f4c <_panic+0x60>
	...

00800f50 <__udivdi3>:
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	83 ec 10             	sub    $0x10,%esp
  800f58:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f61:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f64:	85 c0                	test   %eax,%eax
  800f66:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f69:	75 35                	jne    800fa0 <__udivdi3+0x50>
  800f6b:	39 fe                	cmp    %edi,%esi
  800f6d:	77 61                	ja     800fd0 <__udivdi3+0x80>
  800f6f:	85 f6                	test   %esi,%esi
  800f71:	75 0b                	jne    800f7e <__udivdi3+0x2e>
  800f73:	b8 01 00 00 00       	mov    $0x1,%eax
  800f78:	31 d2                	xor    %edx,%edx
  800f7a:	f7 f6                	div    %esi
  800f7c:	89 c6                	mov    %eax,%esi
  800f7e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800f81:	31 d2                	xor    %edx,%edx
  800f83:	89 f8                	mov    %edi,%eax
  800f85:	f7 f6                	div    %esi
  800f87:	89 c7                	mov    %eax,%edi
  800f89:	89 c8                	mov    %ecx,%eax
  800f8b:	f7 f6                	div    %esi
  800f8d:	89 c1                	mov    %eax,%ecx
  800f8f:	89 fa                	mov    %edi,%edx
  800f91:	89 c8                	mov    %ecx,%eax
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	39 f8                	cmp    %edi,%eax
  800fa2:	77 1c                	ja     800fc0 <__udivdi3+0x70>
  800fa4:	0f bd d0             	bsr    %eax,%edx
  800fa7:	83 f2 1f             	xor    $0x1f,%edx
  800faa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fad:	75 39                	jne    800fe8 <__udivdi3+0x98>
  800faf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800fb2:	0f 86 a0 00 00 00    	jbe    801058 <__udivdi3+0x108>
  800fb8:	39 f8                	cmp    %edi,%eax
  800fba:	0f 82 98 00 00 00    	jb     801058 <__udivdi3+0x108>
  800fc0:	31 ff                	xor    %edi,%edi
  800fc2:	31 c9                	xor    %ecx,%ecx
  800fc4:	89 c8                	mov    %ecx,%eax
  800fc6:	89 fa                	mov    %edi,%edx
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    
  800fcf:	90                   	nop
  800fd0:	89 d1                	mov    %edx,%ecx
  800fd2:	89 fa                	mov    %edi,%edx
  800fd4:	89 c8                	mov    %ecx,%eax
  800fd6:	31 ff                	xor    %edi,%edi
  800fd8:	f7 f6                	div    %esi
  800fda:	89 c1                	mov    %eax,%ecx
  800fdc:	89 fa                	mov    %edi,%edx
  800fde:	89 c8                	mov    %ecx,%eax
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    
  800fe7:	90                   	nop
  800fe8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fec:	89 f2                	mov    %esi,%edx
  800fee:	d3 e0                	shl    %cl,%eax
  800ff0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ff3:	b8 20 00 00 00       	mov    $0x20,%eax
  800ff8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800ffb:	89 c1                	mov    %eax,%ecx
  800ffd:	d3 ea                	shr    %cl,%edx
  800fff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801003:	0b 55 ec             	or     -0x14(%ebp),%edx
  801006:	d3 e6                	shl    %cl,%esi
  801008:	89 c1                	mov    %eax,%ecx
  80100a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80100d:	89 fe                	mov    %edi,%esi
  80100f:	d3 ee                	shr    %cl,%esi
  801011:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801015:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801018:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80101b:	d3 e7                	shl    %cl,%edi
  80101d:	89 c1                	mov    %eax,%ecx
  80101f:	d3 ea                	shr    %cl,%edx
  801021:	09 d7                	or     %edx,%edi
  801023:	89 f2                	mov    %esi,%edx
  801025:	89 f8                	mov    %edi,%eax
  801027:	f7 75 ec             	divl   -0x14(%ebp)
  80102a:	89 d6                	mov    %edx,%esi
  80102c:	89 c7                	mov    %eax,%edi
  80102e:	f7 65 e8             	mull   -0x18(%ebp)
  801031:	39 d6                	cmp    %edx,%esi
  801033:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801036:	72 30                	jb     801068 <__udivdi3+0x118>
  801038:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80103b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80103f:	d3 e2                	shl    %cl,%edx
  801041:	39 c2                	cmp    %eax,%edx
  801043:	73 05                	jae    80104a <__udivdi3+0xfa>
  801045:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801048:	74 1e                	je     801068 <__udivdi3+0x118>
  80104a:	89 f9                	mov    %edi,%ecx
  80104c:	31 ff                	xor    %edi,%edi
  80104e:	e9 71 ff ff ff       	jmp    800fc4 <__udivdi3+0x74>
  801053:	90                   	nop
  801054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801058:	31 ff                	xor    %edi,%edi
  80105a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80105f:	e9 60 ff ff ff       	jmp    800fc4 <__udivdi3+0x74>
  801064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801068:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80106b:	31 ff                	xor    %edi,%edi
  80106d:	89 c8                	mov    %ecx,%eax
  80106f:	89 fa                	mov    %edi,%edx
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    
	...

00801080 <__umoddi3>:
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	83 ec 20             	sub    $0x20,%esp
  801088:	8b 55 14             	mov    0x14(%ebp),%edx
  80108b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801091:	8b 75 0c             	mov    0xc(%ebp),%esi
  801094:	85 d2                	test   %edx,%edx
  801096:	89 c8                	mov    %ecx,%eax
  801098:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80109b:	75 13                	jne    8010b0 <__umoddi3+0x30>
  80109d:	39 f7                	cmp    %esi,%edi
  80109f:	76 3f                	jbe    8010e0 <__umoddi3+0x60>
  8010a1:	89 f2                	mov    %esi,%edx
  8010a3:	f7 f7                	div    %edi
  8010a5:	89 d0                	mov    %edx,%eax
  8010a7:	31 d2                	xor    %edx,%edx
  8010a9:	83 c4 20             	add    $0x20,%esp
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    
  8010b0:	39 f2                	cmp    %esi,%edx
  8010b2:	77 4c                	ja     801100 <__umoddi3+0x80>
  8010b4:	0f bd ca             	bsr    %edx,%ecx
  8010b7:	83 f1 1f             	xor    $0x1f,%ecx
  8010ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010bd:	75 51                	jne    801110 <__umoddi3+0x90>
  8010bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8010c2:	0f 87 e0 00 00 00    	ja     8011a8 <__umoddi3+0x128>
  8010c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010cb:	29 f8                	sub    %edi,%eax
  8010cd:	19 d6                	sbb    %edx,%esi
  8010cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d5:	89 f2                	mov    %esi,%edx
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	5e                   	pop    %esi
  8010db:	5f                   	pop    %edi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    
  8010de:	66 90                	xchg   %ax,%ax
  8010e0:	85 ff                	test   %edi,%edi
  8010e2:	75 0b                	jne    8010ef <__umoddi3+0x6f>
  8010e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e9:	31 d2                	xor    %edx,%edx
  8010eb:	f7 f7                	div    %edi
  8010ed:	89 c7                	mov    %eax,%edi
  8010ef:	89 f0                	mov    %esi,%eax
  8010f1:	31 d2                	xor    %edx,%edx
  8010f3:	f7 f7                	div    %edi
  8010f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f8:	f7 f7                	div    %edi
  8010fa:	eb a9                	jmp    8010a5 <__umoddi3+0x25>
  8010fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801100:	89 c8                	mov    %ecx,%eax
  801102:	89 f2                	mov    %esi,%edx
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    
  80110b:	90                   	nop
  80110c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801110:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801114:	d3 e2                	shl    %cl,%edx
  801116:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801119:	ba 20 00 00 00       	mov    $0x20,%edx
  80111e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801121:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801124:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801128:	89 fa                	mov    %edi,%edx
  80112a:	d3 ea                	shr    %cl,%edx
  80112c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801130:	0b 55 f4             	or     -0xc(%ebp),%edx
  801133:	d3 e7                	shl    %cl,%edi
  801135:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801139:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80113c:	89 f2                	mov    %esi,%edx
  80113e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801141:	89 c7                	mov    %eax,%edi
  801143:	d3 ea                	shr    %cl,%edx
  801145:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801149:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80114c:	89 c2                	mov    %eax,%edx
  80114e:	d3 e6                	shl    %cl,%esi
  801150:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801154:	d3 ea                	shr    %cl,%edx
  801156:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80115a:	09 d6                	or     %edx,%esi
  80115c:	89 f0                	mov    %esi,%eax
  80115e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801161:	d3 e7                	shl    %cl,%edi
  801163:	89 f2                	mov    %esi,%edx
  801165:	f7 75 f4             	divl   -0xc(%ebp)
  801168:	89 d6                	mov    %edx,%esi
  80116a:	f7 65 e8             	mull   -0x18(%ebp)
  80116d:	39 d6                	cmp    %edx,%esi
  80116f:	72 2b                	jb     80119c <__umoddi3+0x11c>
  801171:	39 c7                	cmp    %eax,%edi
  801173:	72 23                	jb     801198 <__umoddi3+0x118>
  801175:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801179:	29 c7                	sub    %eax,%edi
  80117b:	19 d6                	sbb    %edx,%esi
  80117d:	89 f0                	mov    %esi,%eax
  80117f:	89 f2                	mov    %esi,%edx
  801181:	d3 ef                	shr    %cl,%edi
  801183:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801187:	d3 e0                	shl    %cl,%eax
  801189:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80118d:	09 f8                	or     %edi,%eax
  80118f:	d3 ea                	shr    %cl,%edx
  801191:	83 c4 20             	add    $0x20,%esp
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    
  801198:	39 d6                	cmp    %edx,%esi
  80119a:	75 d9                	jne    801175 <__umoddi3+0xf5>
  80119c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80119f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8011a2:	eb d1                	jmp    801175 <__umoddi3+0xf5>
  8011a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a8:	39 f2                	cmp    %esi,%edx
  8011aa:	0f 82 18 ff ff ff    	jb     8010c8 <__umoddi3+0x48>
  8011b0:	e9 1d ff ff ff       	jmp    8010d2 <__umoddi3+0x52>
