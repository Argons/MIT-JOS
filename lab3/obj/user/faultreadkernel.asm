
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 98 0e 80 00 	movl   $0x800e98,(%esp)
  80004a:	e8 ca 00 00 00       	call   800119 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
//	env = &envs[ENVX(sys_getenvid())];
        env = envs + ENVX(sys_getenvid ());
  800066:	e8 8d 0b 00 00       	call   800bf8 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 64             	imul   $0x64,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 0d 0b 00 00       	call   800bc3 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000c8:	00 00 00 
	b.cnt = 0;
  8000cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ed:	c7 04 24 33 01 80 00 	movl   $0x800133,(%esp)
  8000f4:	e8 d7 01 00 00       	call   8002d0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000f9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8000ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800103:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 4b 0a 00 00       	call   800b5c <sys_cputs>

	return b.cnt;
}
  800111:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80011f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800122:	89 44 24 04          	mov    %eax,0x4(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 87 ff ff ff       	call   8000b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	53                   	push   %ebx
  800137:	83 ec 14             	sub    $0x14,%esp
  80013a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013d:	8b 03                	mov    (%ebx),%eax
  80013f:	8b 55 08             	mov    0x8(%ebp),%edx
  800142:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800146:	83 c0 01             	add    $0x1,%eax
  800149:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800150:	75 19                	jne    80016b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800152:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800159:	00 
  80015a:	8d 43 08             	lea    0x8(%ebx),%eax
  80015d:	89 04 24             	mov    %eax,(%esp)
  800160:	e8 f7 09 00 00       	call   800b5c <sys_cputs>
		b->idx = 0;
  800165:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80016f:	83 c4 14             	add    $0x14,%esp
  800172:	5b                   	pop    %ebx
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ab:	39 d1                	cmp    %edx,%ecx
  8001ad:	72 15                	jb     8001c4 <printnum+0x44>
  8001af:	77 07                	ja     8001b8 <printnum+0x38>
  8001b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001b4:	39 d0                	cmp    %edx,%eax
  8001b6:	76 0c                	jbe    8001c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b8:	83 eb 01             	sub    $0x1,%ebx
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	8d 76 00             	lea    0x0(%esi),%esi
  8001c0:	7f 61                	jg     800223 <printnum+0xa3>
  8001c2:	eb 70                	jmp    800234 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ef:	00 
  8001f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fd:	e8 2e 0a 00 00       	call   800c30 <__udivdi3>
  800202:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800205:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	89 54 24 04          	mov    %edx,0x4(%esp)
  800217:	89 f2                	mov    %esi,%edx
  800219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021c:	e8 5f ff ff ff       	call   800180 <printnum>
  800221:	eb 11                	jmp    800234 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	89 74 24 04          	mov    %esi,0x4(%esp)
  800227:	89 3c 24             	mov    %edi,(%esp)
  80022a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ef                	jg     800223 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	89 74 24 04          	mov    %esi,0x4(%esp)
  800238:	8b 74 24 04          	mov    0x4(%esp),%esi
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024a:	00 
  80024b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80024e:	89 14 24             	mov    %edx,(%esp)
  800251:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800254:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800258:	e8 03 0b 00 00       	call   800d60 <__umoddi3>
  80025d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800261:	0f be 80 d7 0e 80 00 	movsbl 0x800ed7(%eax),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026e:	83 c4 4c             	add    $0x4c,%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0f                	jle    80028d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	83 c2 08             	add    $0x8,%edx
  800283:	89 10                	mov    %edx,(%eax)
  800285:	8b 42 f8             	mov    -0x8(%edx),%eax
  800288:	8b 52 fc             	mov    -0x4(%edx),%edx
  80028b:	eb 24                	jmp    8002b1 <getuint+0x3b>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 11                	je     8002a2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	83 c2 04             	add    $0x4,%edx
  800296:	89 10                	mov    %edx,(%eax)
  800298:	8b 42 fc             	mov    -0x4(%edx),%eax
  80029b:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a0:	eb 0f                	jmp    8002b1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	83 c2 04             	add    $0x4,%edx
  8002a7:	89 10                	mov    %edx,(%eax)
  8002a9:	8b 42 fc             	mov    -0x4(%edx),%eax
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c2:	73 0a                	jae    8002ce <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c7:	88 0a                	mov    %cl,(%edx)
  8002c9:	83 c2 01             	add    $0x1,%edx
  8002cc:	89 10                	mov    %edx,(%eax)
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 5c             	sub    $0x5c,%esp
  8002d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002df:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002e2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002e9:	eb 11                	jmp    8002fc <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	0f 84 fd 03 00 00    	je     8006f0 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  8002f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fc:	0f b6 03             	movzbl (%ebx),%eax
  8002ff:	83 c3 01             	add    $0x1,%ebx
  800302:	83 f8 25             	cmp    $0x25,%eax
  800305:	75 e4                	jne    8002eb <vprintfmt+0x1b>
  800307:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800312:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800319:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800320:	b9 00 00 00 00       	mov    $0x0,%ecx
  800325:	eb 06                	jmp    80032d <vprintfmt+0x5d>
  800327:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80032b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	0f b6 13             	movzbl (%ebx),%edx
  800330:	0f b6 c2             	movzbl %dl,%eax
  800333:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800336:	8d 43 01             	lea    0x1(%ebx),%eax
  800339:	83 ea 23             	sub    $0x23,%edx
  80033c:	80 fa 55             	cmp    $0x55,%dl
  80033f:	0f 87 8e 03 00 00    	ja     8006d3 <vprintfmt+0x403>
  800345:	0f b6 d2             	movzbl %dl,%edx
  800348:	ff 24 95 64 0f 80 00 	jmp    *0x800f64(,%edx,4)
  80034f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800353:	eb d6                	jmp    80032b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800355:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800358:	83 ea 30             	sub    $0x30,%edx
  80035b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80035e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800361:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800364:	83 fb 09             	cmp    $0x9,%ebx
  800367:	77 55                	ja     8003be <vprintfmt+0xee>
  800369:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80036c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800372:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800375:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800379:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80037c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80037f:	83 fb 09             	cmp    $0x9,%ebx
  800382:	76 eb                	jbe    80036f <vprintfmt+0x9f>
  800384:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800387:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80038a:	eb 32                	jmp    8003be <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038c:	8b 55 14             	mov    0x14(%ebp),%edx
  80038f:	83 c2 04             	add    $0x4,%edx
  800392:	89 55 14             	mov    %edx,0x14(%ebp)
  800395:	8b 52 fc             	mov    -0x4(%edx),%edx
  800398:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80039b:	eb 21                	jmp    8003be <vprintfmt+0xee>

		case '.':
			if (width < 0)
  80039d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8003aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003ad:	e9 79 ff ff ff       	jmp    80032b <vprintfmt+0x5b>
  8003b2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003b9:	e9 6d ff ff ff       	jmp    80032b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c2:	0f 89 63 ff ff ff    	jns    80032b <vprintfmt+0x5b>
  8003c8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003ce:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003d1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8003d4:	e9 52 ff ff ff       	jmp    80032b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d9:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003dc:	e9 4a ff ff ff       	jmp    80032b <vprintfmt+0x5b>
  8003e1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	83 c0 04             	add    $0x4,%eax
  8003ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8003ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f1:	8b 40 fc             	mov    -0x4(%eax),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	ff d7                	call   *%edi
  8003f9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8003fc:	e9 fb fe ff ff       	jmp    8002fc <vprintfmt+0x2c>
  800401:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	83 c0 04             	add    $0x4,%eax
  80040a:	89 45 14             	mov    %eax,0x14(%ebp)
  80040d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 fa 1f             	sar    $0x1f,%edx
  800415:	31 d0                	xor    %edx,%eax
  800417:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800419:	83 f8 06             	cmp    $0x6,%eax
  80041c:	7f 0b                	jg     800429 <vprintfmt+0x159>
  80041e:	8b 14 85 bc 10 80 00 	mov    0x8010bc(,%eax,4),%edx
  800425:	85 d2                	test   %edx,%edx
  800427:	75 20                	jne    800449 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800429:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042d:	c7 44 24 08 e8 0e 80 	movl   $0x800ee8,0x8(%esp)
  800434:	00 
  800435:	89 74 24 04          	mov    %esi,0x4(%esp)
  800439:	89 3c 24             	mov    %edi,(%esp)
  80043c:	e8 37 03 00 00       	call   800778 <printfmt>
  800441:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800444:	e9 b3 fe ff ff       	jmp    8002fc <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800449:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044d:	c7 44 24 08 f1 0e 80 	movl   $0x800ef1,0x8(%esp)
  800454:	00 
  800455:	89 74 24 04          	mov    %esi,0x4(%esp)
  800459:	89 3c 24             	mov    %edi,(%esp)
  80045c:	e8 17 03 00 00       	call   800778 <printfmt>
  800461:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800464:	e9 93 fe ff ff       	jmp    8002fc <vprintfmt+0x2c>
  800469:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046c:	89 c3                	mov    %eax,%ebx
  80046e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800471:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800474:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	83 c0 04             	add    $0x4,%eax
  80047d:	89 45 14             	mov    %eax,0x14(%ebp)
  800480:	8b 40 fc             	mov    -0x4(%eax),%eax
  800483:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800486:	85 c0                	test   %eax,%eax
  800488:	b8 f4 0e 80 00       	mov    $0x800ef4,%eax
  80048d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  800491:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800494:	85 c9                	test   %ecx,%ecx
  800496:	7e 06                	jle    80049e <vprintfmt+0x1ce>
  800498:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049c:	75 13                	jne    8004b1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a1:	0f be 02             	movsbl (%edx),%eax
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	0f 85 99 00 00 00    	jne    800545 <vprintfmt+0x275>
  8004ac:	e9 86 00 00 00       	jmp    800537 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	89 0c 24             	mov    %ecx,(%esp)
  8004bb:	e8 fb 02 00 00       	call   8007bb <strnlen>
  8004c0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c3:	29 c2                	sub    %eax,%edx
  8004c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c8:	85 d2                	test   %edx,%edx
  8004ca:	7e d2                	jle    80049e <vprintfmt+0x1ce>
					putch(padc, putdat);
  8004cc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8004d0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004d3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004d6:	89 d3                	mov    %edx,%ebx
  8004d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004df:	89 04 24             	mov    %eax,(%esp)
  8004e2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	85 db                	test   %ebx,%ebx
  8004e9:	7f ed                	jg     8004d8 <vprintfmt+0x208>
  8004eb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f5:	eb a7                	jmp    80049e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fb:	74 18                	je     800515 <vprintfmt+0x245>
  8004fd:	8d 50 e0             	lea    -0x20(%eax),%edx
  800500:	83 fa 5e             	cmp    $0x5e,%edx
  800503:	76 10                	jbe    800515 <vprintfmt+0x245>
					putch('?', putdat);
  800505:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800509:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800510:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800513:	eb 0a                	jmp    80051f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800523:	0f be 03             	movsbl (%ebx),%eax
  800526:	85 c0                	test   %eax,%eax
  800528:	74 05                	je     80052f <vprintfmt+0x25f>
  80052a:	83 c3 01             	add    $0x1,%ebx
  80052d:	eb 29                	jmp    800558 <vprintfmt+0x288>
  80052f:	89 fe                	mov    %edi,%esi
  800531:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800534:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053b:	7f 2e                	jg     80056b <vprintfmt+0x29b>
  80053d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800540:	e9 b7 fd ff ff       	jmp    8002fc <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800548:	83 c2 01             	add    $0x1,%edx
  80054b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80054e:	89 f7                	mov    %esi,%edi
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800556:	89 d3                	mov    %edx,%ebx
  800558:	85 f6                	test   %esi,%esi
  80055a:	78 9b                	js     8004f7 <vprintfmt+0x227>
  80055c:	83 ee 01             	sub    $0x1,%esi
  80055f:	79 96                	jns    8004f7 <vprintfmt+0x227>
  800561:	89 fe                	mov    %edi,%esi
  800563:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800566:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800569:	eb cc                	jmp    800537 <vprintfmt+0x267>
  80056b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80056e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800571:	89 74 24 04          	mov    %esi,0x4(%esp)
  800575:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057e:	83 eb 01             	sub    $0x1,%ebx
  800581:	85 db                	test   %ebx,%ebx
  800583:	7f ec                	jg     800571 <vprintfmt+0x2a1>
  800585:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800588:	e9 6f fd ff ff       	jmp    8002fc <vprintfmt+0x2c>
  80058d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800590:	83 f9 01             	cmp    $0x1,%ecx
  800593:	7e 17                	jle    8005ac <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	83 c0 08             	add    $0x8,%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
  80059e:	8b 50 f8             	mov    -0x8(%eax),%edx
  8005a1:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8005a4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005aa:	eb 34                	jmp    8005e0 <vprintfmt+0x310>
	else if (lflag)
  8005ac:	85 c9                	test   %ecx,%ecx
  8005ae:	74 19                	je     8005c9 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	83 c0 04             	add    $0x4,%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b9:	8b 40 fc             	mov    -0x4(%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 c1                	mov    %eax,%ecx
  8005c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c7:	eb 17                	jmp    8005e0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	83 c0 04             	add    $0x4,%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d2:	8b 40 fc             	mov    -0x4(%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c2                	mov    %eax,%edx
  8005da:	c1 fa 1f             	sar    $0x1f,%edx
  8005dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005e3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ef:	0f 89 9c 00 00 00    	jns    800691 <vprintfmt+0x3c1>
				putch('-', putdat);
  8005f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800600:	ff d7                	call   *%edi
				num = -(long long) num;
  800602:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800605:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800608:	f7 d9                	neg    %ecx
  80060a:	83 d3 00             	adc    $0x0,%ebx
  80060d:	f7 db                	neg    %ebx
  80060f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800614:	eb 7b                	jmp    800691 <vprintfmt+0x3c1>
  800616:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800619:	89 ca                	mov    %ecx,%edx
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 53 fc ff ff       	call   800276 <getuint>
  800623:	89 c1                	mov    %eax,%ecx
  800625:	89 d3                	mov    %edx,%ebx
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80062c:	eb 63                	jmp    800691 <vprintfmt+0x3c1>
  80062e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800631:	89 ca                	mov    %ecx,%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 3b fc ff ff       	call   800276 <getuint>
  80063b:	89 c1                	mov    %eax,%ecx
  80063d:	89 d3                	mov    %edx,%ebx
  80063f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800644:	eb 4b                	jmp    800691 <vprintfmt+0x3c1>
  800646:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800654:	ff d7                	call   *%edi
			putch('x', putdat);
  800656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800661:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	83 c0 04             	add    $0x4,%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  80066f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800674:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800679:	eb 16                	jmp    800691 <vprintfmt+0x3c1>
  80067b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067e:	89 ca                	mov    %ecx,%edx
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 ee fb ff ff       	call   800276 <getuint>
  800688:	89 c1                	mov    %eax,%ecx
  80068a:	89 d3                	mov    %edx,%ebx
  80068c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800691:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800695:	89 54 24 10          	mov    %edx,0x10(%esp)
  800699:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a4:	89 0c 24             	mov    %ecx,(%esp)
  8006a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ab:	89 f2                	mov    %esi,%edx
  8006ad:	89 f8                	mov    %edi,%eax
  8006af:	e8 cc fa ff ff       	call   800180 <printnum>
  8006b4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006b7:	e9 40 fc ff ff       	jmp    8002fc <vprintfmt+0x2c>
  8006bc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006bf:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c6:	89 14 24             	mov    %edx,(%esp)
  8006c9:	ff d7                	call   *%edi
  8006cb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006ce:	e9 29 fc ff ff       	jmp    8002fc <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006de:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006e3:	80 38 25             	cmpb   $0x25,(%eax)
  8006e6:	0f 84 10 fc ff ff    	je     8002fc <vprintfmt+0x2c>
  8006ec:	89 c3                	mov    %eax,%ebx
  8006ee:	eb f0                	jmp    8006e0 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  8006f0:	83 c4 5c             	add    $0x5c,%esp
  8006f3:	5b                   	pop    %ebx
  8006f4:	5e                   	pop    %esi
  8006f5:	5f                   	pop    %edi
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 28             	sub    $0x28,%esp
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800704:	85 c0                	test   %eax,%eax
  800706:	74 04                	je     80070c <vsnprintf+0x14>
  800708:	85 d2                	test   %edx,%edx
  80070a:	7f 07                	jg     800713 <vsnprintf+0x1b>
  80070c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800711:	eb 3b                	jmp    80074e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800716:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80071a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072b:	8b 45 10             	mov    0x10(%ebp),%eax
  80072e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800732:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800735:	89 44 24 04          	mov    %eax,0x4(%esp)
  800739:	c7 04 24 b3 02 80 00 	movl   $0x8002b3,(%esp)
  800740:	e8 8b fb ff ff       	call   8002d0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800745:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800748:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075d:	8b 45 10             	mov    0x10(%ebp),%eax
  800760:	89 44 24 08          	mov    %eax,0x8(%esp)
  800764:	8b 45 0c             	mov    0xc(%ebp),%eax
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	89 04 24             	mov    %eax,(%esp)
  800771:	e8 82 ff ff ff       	call   8006f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
  800781:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800785:	8b 45 10             	mov    0x10(%ebp),%eax
  800788:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	89 04 24             	mov    %eax,(%esp)
  800799:	e8 32 fb ff ff       	call   8002d0 <vprintfmt>
	va_end(ap);
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ae:	74 09                	je     8007b9 <strlen+0x19>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0x10>
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	85 c9                	test   %ecx,%ecx
  8007c7:	74 19                	je     8007e2 <strnlen+0x27>
  8007c9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007cc:	74 14                	je     8007e2 <strnlen+0x27>
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d6:	39 c8                	cmp    %ecx,%eax
  8007d8:	74 0d                	je     8007e7 <strnlen+0x2c>
  8007da:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007de:	75 f3                	jne    8007d3 <strnlen+0x18>
  8007e0:	eb 05                	jmp    8007e7 <strnlen+0x2c>
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e7:	5b                   	pop    %ebx
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	84 c9                	test   %cl,%cl
  800805:	75 f2                	jne    8007f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	56                   	push   %esi
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800818:	85 f6                	test   %esi,%esi
  80081a:	74 18                	je     800834 <strncpy+0x2a>
  80081c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800821:	0f b6 1a             	movzbl (%edx),%ebx
  800824:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800827:	80 3a 01             	cmpb   $0x1,(%edx)
  80082a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082d:	83 c1 01             	add    $0x1,%ecx
  800830:	39 ce                	cmp    %ecx,%esi
  800832:	77 ed                	ja     800821 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
  800843:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800846:	89 f0                	mov    %esi,%eax
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	74 27                	je     800873 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80084c:	83 e9 01             	sub    $0x1,%ecx
  80084f:	74 1d                	je     80086e <strlcpy+0x36>
  800851:	0f b6 1a             	movzbl (%edx),%ebx
  800854:	84 db                	test   %bl,%bl
  800856:	74 16                	je     80086e <strlcpy+0x36>
			*dst++ = *src++;
  800858:	88 18                	mov    %bl,(%eax)
  80085a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085d:	83 e9 01             	sub    $0x1,%ecx
  800860:	74 0e                	je     800870 <strlcpy+0x38>
			*dst++ = *src++;
  800862:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800865:	0f b6 1a             	movzbl (%edx),%ebx
  800868:	84 db                	test   %bl,%bl
  80086a:	75 ec                	jne    800858 <strlcpy+0x20>
  80086c:	eb 02                	jmp    800870 <strlcpy+0x38>
  80086e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800870:	c6 00 00             	movb   $0x0,(%eax)
  800873:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800875:	5b                   	pop    %ebx
  800876:	5e                   	pop    %esi
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800882:	0f b6 01             	movzbl (%ecx),%eax
  800885:	84 c0                	test   %al,%al
  800887:	74 15                	je     80089e <strcmp+0x25>
  800889:	3a 02                	cmp    (%edx),%al
  80088b:	75 11                	jne    80089e <strcmp+0x25>
		p++, q++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	84 c0                	test   %al,%al
  800898:	74 04                	je     80089e <strcmp+0x25>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	74 ef                	je     80088d <strcmp+0x14>
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8008af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	74 23                	je     8008dc <strncmp+0x34>
  8008b9:	0f b6 1a             	movzbl (%edx),%ebx
  8008bc:	84 db                	test   %bl,%bl
  8008be:	74 24                	je     8008e4 <strncmp+0x3c>
  8008c0:	3a 19                	cmp    (%ecx),%bl
  8008c2:	75 20                	jne    8008e4 <strncmp+0x3c>
  8008c4:	83 e8 01             	sub    $0x1,%eax
  8008c7:	74 13                	je     8008dc <strncmp+0x34>
		n--, p++, q++;
  8008c9:	83 c2 01             	add    $0x1,%edx
  8008cc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cf:	0f b6 1a             	movzbl (%edx),%ebx
  8008d2:	84 db                	test   %bl,%bl
  8008d4:	74 0e                	je     8008e4 <strncmp+0x3c>
  8008d6:	3a 19                	cmp    (%ecx),%bl
  8008d8:	74 ea                	je     8008c4 <strncmp+0x1c>
  8008da:	eb 08                	jmp    8008e4 <strncmp+0x3c>
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e4:	0f b6 02             	movzbl (%edx),%eax
  8008e7:	0f b6 11             	movzbl (%ecx),%edx
  8008ea:	29 d0                	sub    %edx,%eax
  8008ec:	eb f3                	jmp    8008e1 <strncmp+0x39>

008008ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f8:	0f b6 10             	movzbl (%eax),%edx
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	74 15                	je     800914 <strchr+0x26>
		if (*s == c)
  8008ff:	38 ca                	cmp    %cl,%dl
  800901:	75 07                	jne    80090a <strchr+0x1c>
  800903:	eb 14                	jmp    800919 <strchr+0x2b>
  800905:	38 ca                	cmp    %cl,%dl
  800907:	90                   	nop
  800908:	74 0f                	je     800919 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f1                	jne    800905 <strchr+0x17>
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	0f b6 10             	movzbl (%eax),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 18                	je     800944 <strfind+0x29>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	75 0a                	jne    80093a <strfind+0x1f>
  800930:	eb 12                	jmp    800944 <strfind+0x29>
  800932:	38 ca                	cmp    %cl,%dl
  800934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800938:	74 0a                	je     800944 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	84 d2                	test   %dl,%dl
  800942:	75 ee                	jne    800932 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800950:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800953:	89 da                	mov    %ebx,%edx
  800955:	83 ea 01             	sub    $0x1,%edx
  800958:	78 0d                	js     800967 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  80095a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80095c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  80095e:	88 0a                	mov    %cl,(%edx)
  800960:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800963:	39 da                	cmp    %ebx,%edx
  800965:	75 f7                	jne    80095e <memset+0x18>
		*p++ = c;

	return v;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 75 0c             	mov    0xc(%ebp),%esi
  800975:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800978:	85 db                	test   %ebx,%ebx
  80097a:	74 13                	je     80098f <memcpy+0x25>
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800981:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800985:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800988:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	75 f2                	jne    800981 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  8009a2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  8009a4:	39 c6                	cmp    %eax,%esi
  8009a6:	72 0b                	jb     8009b3 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  8009a8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  8009ad:	85 db                	test   %ebx,%ebx
  8009af:	75 2e                	jne    8009df <memmove+0x4c>
  8009b1:	eb 3a                	jmp    8009ed <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b3:	01 df                	add    %ebx,%edi
  8009b5:	39 f8                	cmp    %edi,%eax
  8009b7:	73 ef                	jae    8009a8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  8009b9:	85 db                	test   %ebx,%ebx
  8009bb:	90                   	nop
  8009bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009c0:	74 2b                	je     8009ed <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  8009c2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  8009ca:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  8009cf:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  8009d3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  8009d6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  8009d9:	85 c9                	test   %ecx,%ecx
  8009db:	75 ed                	jne    8009ca <memmove+0x37>
  8009dd:	eb 0e                	jmp    8009ed <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  8009df:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009e3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009e6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  8009e9:	39 d3                	cmp    %edx,%ebx
  8009eb:	75 f2                	jne    8009df <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	57                   	push   %edi
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8009fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a01:	85 c9                	test   %ecx,%ecx
  800a03:	74 36                	je     800a3b <memcmp+0x49>
		if (*s1 != *s2)
  800a05:	0f b6 06             	movzbl (%esi),%eax
  800a08:	0f b6 1f             	movzbl (%edi),%ebx
  800a0b:	38 d8                	cmp    %bl,%al
  800a0d:	74 20                	je     800a2f <memcmp+0x3d>
  800a0f:	eb 14                	jmp    800a25 <memcmp+0x33>
  800a11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800a16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800a1b:	83 c2 01             	add    $0x1,%edx
  800a1e:	83 e9 01             	sub    $0x1,%ecx
  800a21:	38 d8                	cmp    %bl,%al
  800a23:	74 12                	je     800a37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800a25:	0f b6 c0             	movzbl %al,%eax
  800a28:	0f b6 db             	movzbl %bl,%ebx
  800a2b:	29 d8                	sub    %ebx,%eax
  800a2d:	eb 11                	jmp    800a40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2f:	83 e9 01             	sub    $0x1,%ecx
  800a32:	ba 00 00 00 00       	mov    $0x0,%edx
  800a37:	85 c9                	test   %ecx,%ecx
  800a39:	75 d6                	jne    800a11 <memcmp+0x1f>
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a50:	39 d0                	cmp    %edx,%eax
  800a52:	73 15                	jae    800a69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a58:	38 08                	cmp    %cl,(%eax)
  800a5a:	75 06                	jne    800a62 <memfind+0x1d>
  800a5c:	eb 0b                	jmp    800a69 <memfind+0x24>
  800a5e:	38 08                	cmp    %cl,(%eax)
  800a60:	74 07                	je     800a69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	39 c2                	cmp    %eax,%edx
  800a67:	77 f5                	ja     800a5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	83 ec 04             	sub    $0x4,%esp
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	0f b6 02             	movzbl (%edx),%eax
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 04                	je     800a85 <strtol+0x1a>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	75 0e                	jne    800a93 <strtol+0x28>
		s++;
  800a85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a88:	0f b6 02             	movzbl (%edx),%eax
  800a8b:	3c 20                	cmp    $0x20,%al
  800a8d:	74 f6                	je     800a85 <strtol+0x1a>
  800a8f:	3c 09                	cmp    $0x9,%al
  800a91:	74 f2                	je     800a85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a93:	3c 2b                	cmp    $0x2b,%al
  800a95:	75 0c                	jne    800aa3 <strtol+0x38>
		s++;
  800a97:	83 c2 01             	add    $0x1,%edx
  800a9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800aa1:	eb 15                	jmp    800ab8 <strtol+0x4d>
	else if (*s == '-')
  800aa3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800aaa:	3c 2d                	cmp    $0x2d,%al
  800aac:	75 0a                	jne    800ab8 <strtol+0x4d>
		s++, neg = 1;
  800aae:	83 c2 01             	add    $0x1,%edx
  800ab1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	0f 94 c0             	sete   %al
  800abd:	74 05                	je     800ac4 <strtol+0x59>
  800abf:	83 fb 10             	cmp    $0x10,%ebx
  800ac2:	75 18                	jne    800adc <strtol+0x71>
  800ac4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ac7:	75 13                	jne    800adc <strtol+0x71>
  800ac9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acd:	8d 76 00             	lea    0x0(%esi),%esi
  800ad0:	75 0a                	jne    800adc <strtol+0x71>
		s += 2, base = 16;
  800ad2:	83 c2 02             	add    $0x2,%edx
  800ad5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	eb 15                	jmp    800af1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adc:	84 c0                	test   %al,%al
  800ade:	66 90                	xchg   %ax,%ax
  800ae0:	74 0f                	je     800af1 <strtol+0x86>
  800ae2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ae7:	80 3a 30             	cmpb   $0x30,(%edx)
  800aea:	75 05                	jne    800af1 <strtol+0x86>
		s++, base = 8;
  800aec:	83 c2 01             	add    $0x1,%edx
  800aef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af8:	0f b6 0a             	movzbl (%edx),%ecx
  800afb:	89 cf                	mov    %ecx,%edi
  800afd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b00:	80 fb 09             	cmp    $0x9,%bl
  800b03:	77 08                	ja     800b0d <strtol+0xa2>
			dig = *s - '0';
  800b05:	0f be c9             	movsbl %cl,%ecx
  800b08:	83 e9 30             	sub    $0x30,%ecx
  800b0b:	eb 1e                	jmp    800b2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b10:	80 fb 19             	cmp    $0x19,%bl
  800b13:	77 08                	ja     800b1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800b15:	0f be c9             	movsbl %cl,%ecx
  800b18:	83 e9 57             	sub    $0x57,%ecx
  800b1b:	eb 0e                	jmp    800b2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800b1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b20:	80 fb 19             	cmp    $0x19,%bl
  800b23:	77 15                	ja     800b3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800b25:	0f be c9             	movsbl %cl,%ecx
  800b28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b2b:	39 f1                	cmp    %esi,%ecx
  800b2d:	7d 0b                	jge    800b3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800b2f:	83 c2 01             	add    $0x1,%edx
  800b32:	0f af c6             	imul   %esi,%eax
  800b35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b38:	eb be                	jmp    800af8 <strtol+0x8d>
  800b3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b40:	74 05                	je     800b47 <strtol+0xdc>
		*endptr = (char *) s;
  800b42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b47:	89 ca                	mov    %ecx,%edx
  800b49:	f7 da                	neg    %edx
  800b4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b4f:	0f 45 c2             	cmovne %edx,%eax
}
  800b52:	83 c4 04             	add    $0x4,%esp
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    
	...

00800b5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	89 1c 24             	mov    %ebx,(%esp)
  800b65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b69:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	89 c3                	mov    %eax,%ebx
  800b7a:	89 c7                	mov    %eax,%edi
  800b7c:	89 c6                	mov    %eax,%esi
  800b7e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800b80:	8b 1c 24             	mov    (%esp),%ebx
  800b83:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b87:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b8b:	89 ec                	mov    %ebp,%esp
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	89 1c 24             	mov    %ebx,(%esp)
  800b98:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b9c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 01 00 00 00       	mov    $0x1,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800bb4:	8b 1c 24             	mov    (%esp),%ebx
  800bb7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bbb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bbf:	89 ec                	mov    %ebp,%esp
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	89 1c 24             	mov    %ebx,(%esp)
  800bcc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	89 cb                	mov    %ecx,%ebx
  800be3:	89 cf                	mov    %ecx,%edi
  800be5:	89 ce                	mov    %ecx,%esi
  800be7:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800be9:	8b 1c 24             	mov    (%esp),%ebx
  800bec:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bf0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bf4:	89 ec                	mov    %ebp,%esp
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	89 1c 24             	mov    %ebx,(%esp)
  800c01:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c05:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c13:	89 d1                	mov    %edx,%ecx
  800c15:	89 d3                	mov    %edx,%ebx
  800c17:	89 d7                	mov    %edx,%edi
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800c1d:	8b 1c 24             	mov    (%esp),%ebx
  800c20:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c24:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c28:	89 ec                	mov    %ebp,%esp
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
  800c2c:	00 00                	add    %al,(%eax)
	...

00800c30 <__udivdi3>:
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	83 ec 10             	sub    $0x10,%esp
  800c38:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	8b 75 10             	mov    0x10(%ebp),%esi
  800c41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c44:	85 c0                	test   %eax,%eax
  800c46:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800c49:	75 35                	jne    800c80 <__udivdi3+0x50>
  800c4b:	39 fe                	cmp    %edi,%esi
  800c4d:	77 61                	ja     800cb0 <__udivdi3+0x80>
  800c4f:	85 f6                	test   %esi,%esi
  800c51:	75 0b                	jne    800c5e <__udivdi3+0x2e>
  800c53:	b8 01 00 00 00       	mov    $0x1,%eax
  800c58:	31 d2                	xor    %edx,%edx
  800c5a:	f7 f6                	div    %esi
  800c5c:	89 c6                	mov    %eax,%esi
  800c5e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800c61:	31 d2                	xor    %edx,%edx
  800c63:	89 f8                	mov    %edi,%eax
  800c65:	f7 f6                	div    %esi
  800c67:	89 c7                	mov    %eax,%edi
  800c69:	89 c8                	mov    %ecx,%eax
  800c6b:	f7 f6                	div    %esi
  800c6d:	89 c1                	mov    %eax,%ecx
  800c6f:	89 fa                	mov    %edi,%edx
  800c71:	89 c8                	mov    %ecx,%eax
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    
  800c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c80:	39 f8                	cmp    %edi,%eax
  800c82:	77 1c                	ja     800ca0 <__udivdi3+0x70>
  800c84:	0f bd d0             	bsr    %eax,%edx
  800c87:	83 f2 1f             	xor    $0x1f,%edx
  800c8a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800c8d:	75 39                	jne    800cc8 <__udivdi3+0x98>
  800c8f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800c92:	0f 86 a0 00 00 00    	jbe    800d38 <__udivdi3+0x108>
  800c98:	39 f8                	cmp    %edi,%eax
  800c9a:	0f 82 98 00 00 00    	jb     800d38 <__udivdi3+0x108>
  800ca0:	31 ff                	xor    %edi,%edi
  800ca2:	31 c9                	xor    %ecx,%ecx
  800ca4:	89 c8                	mov    %ecx,%eax
  800ca6:	89 fa                	mov    %edi,%edx
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    
  800caf:	90                   	nop
  800cb0:	89 d1                	mov    %edx,%ecx
  800cb2:	89 fa                	mov    %edi,%edx
  800cb4:	89 c8                	mov    %ecx,%eax
  800cb6:	31 ff                	xor    %edi,%edi
  800cb8:	f7 f6                	div    %esi
  800cba:	89 c1                	mov    %eax,%ecx
  800cbc:	89 fa                	mov    %edi,%edx
  800cbe:	89 c8                	mov    %ecx,%eax
  800cc0:	83 c4 10             	add    $0x10,%esp
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    
  800cc7:	90                   	nop
  800cc8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ccc:	89 f2                	mov    %esi,%edx
  800cce:	d3 e0                	shl    %cl,%eax
  800cd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cd3:	b8 20 00 00 00       	mov    $0x20,%eax
  800cd8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800cdb:	89 c1                	mov    %eax,%ecx
  800cdd:	d3 ea                	shr    %cl,%edx
  800cdf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ce3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800ce6:	d3 e6                	shl    %cl,%esi
  800ce8:	89 c1                	mov    %eax,%ecx
  800cea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800ced:	89 fe                	mov    %edi,%esi
  800cef:	d3 ee                	shr    %cl,%esi
  800cf1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800cf5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800cf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cfb:	d3 e7                	shl    %cl,%edi
  800cfd:	89 c1                	mov    %eax,%ecx
  800cff:	d3 ea                	shr    %cl,%edx
  800d01:	09 d7                	or     %edx,%edi
  800d03:	89 f2                	mov    %esi,%edx
  800d05:	89 f8                	mov    %edi,%eax
  800d07:	f7 75 ec             	divl   -0x14(%ebp)
  800d0a:	89 d6                	mov    %edx,%esi
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	f7 65 e8             	mull   -0x18(%ebp)
  800d11:	39 d6                	cmp    %edx,%esi
  800d13:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800d16:	72 30                	jb     800d48 <__udivdi3+0x118>
  800d18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d1b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d1f:	d3 e2                	shl    %cl,%edx
  800d21:	39 c2                	cmp    %eax,%edx
  800d23:	73 05                	jae    800d2a <__udivdi3+0xfa>
  800d25:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800d28:	74 1e                	je     800d48 <__udivdi3+0x118>
  800d2a:	89 f9                	mov    %edi,%ecx
  800d2c:	31 ff                	xor    %edi,%edi
  800d2e:	e9 71 ff ff ff       	jmp    800ca4 <__udivdi3+0x74>
  800d33:	90                   	nop
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	31 ff                	xor    %edi,%edi
  800d3a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d3f:	e9 60 ff ff ff       	jmp    800ca4 <__udivdi3+0x74>
  800d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d48:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800d4b:	31 ff                	xor    %edi,%edi
  800d4d:	89 c8                	mov    %ecx,%eax
  800d4f:	89 fa                	mov    %edi,%edx
  800d51:	83 c4 10             	add    $0x10,%esp
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
	...

00800d60 <__umoddi3>:
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	83 ec 20             	sub    $0x20,%esp
  800d68:	8b 55 14             	mov    0x14(%ebp),%edx
  800d6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d74:	85 d2                	test   %edx,%edx
  800d76:	89 c8                	mov    %ecx,%eax
  800d78:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d7b:	75 13                	jne    800d90 <__umoddi3+0x30>
  800d7d:	39 f7                	cmp    %esi,%edi
  800d7f:	76 3f                	jbe    800dc0 <__umoddi3+0x60>
  800d81:	89 f2                	mov    %esi,%edx
  800d83:	f7 f7                	div    %edi
  800d85:	89 d0                	mov    %edx,%eax
  800d87:	31 d2                	xor    %edx,%edx
  800d89:	83 c4 20             	add    $0x20,%esp
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    
  800d90:	39 f2                	cmp    %esi,%edx
  800d92:	77 4c                	ja     800de0 <__umoddi3+0x80>
  800d94:	0f bd ca             	bsr    %edx,%ecx
  800d97:	83 f1 1f             	xor    $0x1f,%ecx
  800d9a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d9d:	75 51                	jne    800df0 <__umoddi3+0x90>
  800d9f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  800da2:	0f 87 e0 00 00 00    	ja     800e88 <__umoddi3+0x128>
  800da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dab:	29 f8                	sub    %edi,%eax
  800dad:	19 d6                	sbb    %edx,%esi
  800daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db5:	89 f2                	mov    %esi,%edx
  800db7:	83 c4 20             	add    $0x20,%esp
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    
  800dbe:	66 90                	xchg   %ax,%ax
  800dc0:	85 ff                	test   %edi,%edi
  800dc2:	75 0b                	jne    800dcf <__umoddi3+0x6f>
  800dc4:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc9:	31 d2                	xor    %edx,%edx
  800dcb:	f7 f7                	div    %edi
  800dcd:	89 c7                	mov    %eax,%edi
  800dcf:	89 f0                	mov    %esi,%eax
  800dd1:	31 d2                	xor    %edx,%edx
  800dd3:	f7 f7                	div    %edi
  800dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd8:	f7 f7                	div    %edi
  800dda:	eb a9                	jmp    800d85 <__umoddi3+0x25>
  800ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de0:	89 c8                	mov    %ecx,%eax
  800de2:	89 f2                	mov    %esi,%edx
  800de4:	83 c4 20             	add    $0x20,%esp
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    
  800deb:	90                   	nop
  800dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800df4:	d3 e2                	shl    %cl,%edx
  800df6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800df9:	ba 20 00 00 00       	mov    $0x20,%edx
  800dfe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  800e01:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800e04:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e08:	89 fa                	mov    %edi,%edx
  800e0a:	d3 ea                	shr    %cl,%edx
  800e0c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e10:	0b 55 f4             	or     -0xc(%ebp),%edx
  800e13:	d3 e7                	shl    %cl,%edi
  800e15:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e19:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800e1c:	89 f2                	mov    %esi,%edx
  800e1e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  800e21:	89 c7                	mov    %eax,%edi
  800e23:	d3 ea                	shr    %cl,%edx
  800e25:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e29:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e2c:	89 c2                	mov    %eax,%edx
  800e2e:	d3 e6                	shl    %cl,%esi
  800e30:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e34:	d3 ea                	shr    %cl,%edx
  800e36:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e3a:	09 d6                	or     %edx,%esi
  800e3c:	89 f0                	mov    %esi,%eax
  800e3e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e41:	d3 e7                	shl    %cl,%edi
  800e43:	89 f2                	mov    %esi,%edx
  800e45:	f7 75 f4             	divl   -0xc(%ebp)
  800e48:	89 d6                	mov    %edx,%esi
  800e4a:	f7 65 e8             	mull   -0x18(%ebp)
  800e4d:	39 d6                	cmp    %edx,%esi
  800e4f:	72 2b                	jb     800e7c <__umoddi3+0x11c>
  800e51:	39 c7                	cmp    %eax,%edi
  800e53:	72 23                	jb     800e78 <__umoddi3+0x118>
  800e55:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e59:	29 c7                	sub    %eax,%edi
  800e5b:	19 d6                	sbb    %edx,%esi
  800e5d:	89 f0                	mov    %esi,%eax
  800e5f:	89 f2                	mov    %esi,%edx
  800e61:	d3 ef                	shr    %cl,%edi
  800e63:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e67:	d3 e0                	shl    %cl,%eax
  800e69:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e6d:	09 f8                	or     %edi,%eax
  800e6f:	d3 ea                	shr    %cl,%edx
  800e71:	83 c4 20             	add    $0x20,%esp
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
  800e78:	39 d6                	cmp    %edx,%esi
  800e7a:	75 d9                	jne    800e55 <__umoddi3+0xf5>
  800e7c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  800e7f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  800e82:	eb d1                	jmp    800e55 <__umoddi3+0xf5>
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	0f 82 18 ff ff ff    	jb     800da8 <__umoddi3+0x48>
  800e90:	e9 1d ff ff ff       	jmp    800db2 <__umoddi3+0x52>
