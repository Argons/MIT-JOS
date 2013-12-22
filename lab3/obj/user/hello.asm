
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 a8 0e 80 00 	movl   $0x800ea8,(%esp)
  800041:	e8 df 00 00 00       	call   800125 <cprintf>
	cprintf("i am environment %08x\n", env->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 4c             	mov    0x4c(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 b6 0e 80 00 	movl   $0x800eb6,(%esp)
  800059:	e8 c7 00 00 00       	call   800125 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
//	env = &envs[ENVX(sys_getenvid())];
        env = envs + ENVX(sys_getenvid ());
  800072:	e8 91 0b 00 00       	call   800c08 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	6b c0 64             	imul   $0x64,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 11 0b 00 00       	call   800bd3 <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000d4:	00 00 00 
	b.cnt = 0;
  8000d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f9:	c7 04 24 3f 01 80 00 	movl   $0x80013f,(%esp)
  800100:	e8 db 01 00 00       	call   8002e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800105:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80010b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800115:	89 04 24             	mov    %eax,(%esp)
  800118:	e8 4f 0a 00 00       	call   800b6c <sys_cputs>

	return b.cnt;
}
  80011d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80012b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 04 24             	mov    %eax,(%esp)
  800138:	e8 87 ff ff ff       	call   8000c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	53                   	push   %ebx
  800143:	83 ec 14             	sub    $0x14,%esp
  800146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	8b 55 08             	mov    0x8(%ebp),%edx
  80014e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800152:	83 c0 01             	add    $0x1,%eax
  800155:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800157:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015c:	75 19                	jne    800177 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80015e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800165:	00 
  800166:	8d 43 08             	lea    0x8(%ebx),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 fb 09 00 00       	call   800b6c <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800177:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017b:	83 c4 14             	add    $0x14,%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 15                	jb     8001d4 <printnum+0x44>
  8001bf:	77 07                	ja     8001c8 <printnum+0x38>
  8001c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c4:	39 d0                	cmp    %edx,%eax
  8001c6:	76 0c                	jbe    8001d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	8d 76 00             	lea    0x0(%esi),%esi
  8001d0:	7f 61                	jg     800233 <printnum+0xa3>
  8001d2:	eb 70                	jmp    800244 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	e8 2e 0a 00 00       	call   800c40 <__udivdi3>
  800212:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	89 54 24 04          	mov    %edx,0x4(%esp)
  800227:	89 f2                	mov    %esi,%edx
  800229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022c:	e8 5f ff ff ff       	call   800190 <printnum>
  800231:	eb 11                	jmp    800244 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	89 74 24 04          	mov    %esi,0x4(%esp)
  800237:	89 3c 24             	mov    %edi,(%esp)
  80023a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ef                	jg     800233 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	89 74 24 04          	mov    %esi,0x4(%esp)
  800248:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025a:	00 
  80025b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025e:	89 14 24             	mov    %edx,(%esp)
  800261:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800264:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800268:	e8 03 0b 00 00       	call   800d70 <__umoddi3>
  80026d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800271:	0f be 80 e4 0e 80 00 	movsbl 0x800ee4(%eax),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027e:	83 c4 4c             	add    $0x4c,%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800289:	83 fa 01             	cmp    $0x1,%edx
  80028c:	7e 0f                	jle    80029d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	83 c2 08             	add    $0x8,%edx
  800293:	89 10                	mov    %edx,(%eax)
  800295:	8b 42 f8             	mov    -0x8(%edx),%eax
  800298:	8b 52 fc             	mov    -0x4(%edx),%edx
  80029b:	eb 24                	jmp    8002c1 <getuint+0x3b>
	else if (lflag)
  80029d:	85 d2                	test   %edx,%edx
  80029f:	74 11                	je     8002b2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	83 c2 04             	add    $0x4,%edx
  8002a6:	89 10                	mov    %edx,(%eax)
  8002a8:	8b 42 fc             	mov    -0x4(%edx),%eax
  8002ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b0:	eb 0f                	jmp    8002c1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  8002b2:	8b 10                	mov    (%eax),%edx
  8002b4:	83 c2 04             	add    $0x4,%edx
  8002b7:	89 10                	mov    %edx,(%eax)
  8002b9:	8b 42 fc             	mov    -0x4(%edx),%eax
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d2:	73 0a                	jae    8002de <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d7:	88 0a                	mov    %cl,(%edx)
  8002d9:	83 c2 01             	add    $0x1,%edx
  8002dc:	89 10                	mov    %edx,(%eax)
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 5c             	sub    $0x5c,%esp
  8002e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002f2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f9:	eb 11                	jmp    80030c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fb:	85 c0                	test   %eax,%eax
  8002fd:	0f 84 fd 03 00 00    	je     800700 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800303:	89 74 24 04          	mov    %esi,0x4(%esp)
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030c:	0f b6 03             	movzbl (%ebx),%eax
  80030f:	83 c3 01             	add    $0x1,%ebx
  800312:	83 f8 25             	cmp    $0x25,%eax
  800315:	75 e4                	jne    8002fb <vprintfmt+0x1b>
  800317:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800322:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800329:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800330:	b9 00 00 00 00       	mov    $0x0,%ecx
  800335:	eb 06                	jmp    80033d <vprintfmt+0x5d>
  800337:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80033b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	0f b6 13             	movzbl (%ebx),%edx
  800340:	0f b6 c2             	movzbl %dl,%eax
  800343:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800346:	8d 43 01             	lea    0x1(%ebx),%eax
  800349:	83 ea 23             	sub    $0x23,%edx
  80034c:	80 fa 55             	cmp    $0x55,%dl
  80034f:	0f 87 8e 03 00 00    	ja     8006e3 <vprintfmt+0x403>
  800355:	0f b6 d2             	movzbl %dl,%edx
  800358:	ff 24 95 74 0f 80 00 	jmp    *0x800f74(,%edx,4)
  80035f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800363:	eb d6                	jmp    80033b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800365:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800368:	83 ea 30             	sub    $0x30,%edx
  80036b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80036e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800371:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800374:	83 fb 09             	cmp    $0x9,%ebx
  800377:	77 55                	ja     8003ce <vprintfmt+0xee>
  800379:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80037c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800382:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800385:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800389:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80038c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80038f:	83 fb 09             	cmp    $0x9,%ebx
  800392:	76 eb                	jbe    80037f <vprintfmt+0x9f>
  800394:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800397:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80039a:	eb 32                	jmp    8003ce <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039c:	8b 55 14             	mov    0x14(%ebp),%edx
  80039f:	83 c2 04             	add    $0x4,%edx
  8003a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a5:	8b 52 fc             	mov    -0x4(%edx),%edx
  8003a8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8003ab:	eb 21                	jmp    8003ce <vprintfmt+0xee>

		case '.':
			if (width < 0)
  8003ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8003ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003bd:	e9 79 ff ff ff       	jmp    80033b <vprintfmt+0x5b>
  8003c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003c9:	e9 6d ff ff ff       	jmp    80033b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d2:	0f 89 63 ff ff ff    	jns    80033b <vprintfmt+0x5b>
  8003d8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003de:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003e1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8003e4:	e9 52 ff ff ff       	jmp    80033b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e9:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003ec:	e9 4a ff ff ff       	jmp    80033b <vprintfmt+0x5b>
  8003f1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	83 c0 04             	add    $0x4,%eax
  8003fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8003fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800401:	8b 40 fc             	mov    -0x4(%eax),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	ff d7                	call   *%edi
  800409:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80040c:	e9 fb fe ff ff       	jmp    80030c <vprintfmt+0x2c>
  800411:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	83 c0 04             	add    $0x4,%eax
  80041a:	89 45 14             	mov    %eax,0x14(%ebp)
  80041d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800420:	89 c2                	mov    %eax,%edx
  800422:	c1 fa 1f             	sar    $0x1f,%edx
  800425:	31 d0                	xor    %edx,%eax
  800427:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800429:	83 f8 06             	cmp    $0x6,%eax
  80042c:	7f 0b                	jg     800439 <vprintfmt+0x159>
  80042e:	8b 14 85 cc 10 80 00 	mov    0x8010cc(,%eax,4),%edx
  800435:	85 d2                	test   %edx,%edx
  800437:	75 20                	jne    800459 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800439:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043d:	c7 44 24 08 f5 0e 80 	movl   $0x800ef5,0x8(%esp)
  800444:	00 
  800445:	89 74 24 04          	mov    %esi,0x4(%esp)
  800449:	89 3c 24             	mov    %edi,(%esp)
  80044c:	e8 37 03 00 00       	call   800788 <printfmt>
  800451:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800454:	e9 b3 fe ff ff       	jmp    80030c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800459:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045d:	c7 44 24 08 fe 0e 80 	movl   $0x800efe,0x8(%esp)
  800464:	00 
  800465:	89 74 24 04          	mov    %esi,0x4(%esp)
  800469:	89 3c 24             	mov    %edi,(%esp)
  80046c:	e8 17 03 00 00       	call   800788 <printfmt>
  800471:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800474:	e9 93 fe ff ff       	jmp    80030c <vprintfmt+0x2c>
  800479:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047c:	89 c3                	mov    %eax,%ebx
  80047e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800481:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800484:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	83 c0 04             	add    $0x4,%eax
  80048d:	89 45 14             	mov    %eax,0x14(%ebp)
  800490:	8b 40 fc             	mov    -0x4(%eax),%eax
  800493:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800496:	85 c0                	test   %eax,%eax
  800498:	b8 01 0f 80 00       	mov    $0x800f01,%eax
  80049d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	7e 06                	jle    8004ae <vprintfmt+0x1ce>
  8004a8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ac:	75 13                	jne    8004c1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b1:	0f be 02             	movsbl (%edx),%eax
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	0f 85 99 00 00 00    	jne    800555 <vprintfmt+0x275>
  8004bc:	e9 86 00 00 00       	jmp    800547 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c8:	89 0c 24             	mov    %ecx,(%esp)
  8004cb:	e8 fb 02 00 00       	call   8007cb <strnlen>
  8004d0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d3:	29 c2                	sub    %eax,%edx
  8004d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	7e d2                	jle    8004ae <vprintfmt+0x1ce>
					putch(padc, putdat);
  8004dc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8004e0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004e3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004e6:	89 d3                	mov    %edx,%ebx
  8004e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	83 eb 01             	sub    $0x1,%ebx
  8004f7:	85 db                	test   %ebx,%ebx
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x208>
  8004fb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800505:	eb a7                	jmp    8004ae <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800507:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050b:	74 18                	je     800525 <vprintfmt+0x245>
  80050d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800510:	83 fa 5e             	cmp    $0x5e,%edx
  800513:	76 10                	jbe    800525 <vprintfmt+0x245>
					putch('?', putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800520:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800523:	eb 0a                	jmp    80052f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800533:	0f be 03             	movsbl (%ebx),%eax
  800536:	85 c0                	test   %eax,%eax
  800538:	74 05                	je     80053f <vprintfmt+0x25f>
  80053a:	83 c3 01             	add    $0x1,%ebx
  80053d:	eb 29                	jmp    800568 <vprintfmt+0x288>
  80053f:	89 fe                	mov    %edi,%esi
  800541:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800544:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054b:	7f 2e                	jg     80057b <vprintfmt+0x29b>
  80054d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800550:	e9 b7 fd ff ff       	jmp    80030c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800555:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800558:	83 c2 01             	add    $0x1,%edx
  80055b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80055e:	89 f7                	mov    %esi,%edi
  800560:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800563:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800566:	89 d3                	mov    %edx,%ebx
  800568:	85 f6                	test   %esi,%esi
  80056a:	78 9b                	js     800507 <vprintfmt+0x227>
  80056c:	83 ee 01             	sub    $0x1,%esi
  80056f:	79 96                	jns    800507 <vprintfmt+0x227>
  800571:	89 fe                	mov    %edi,%esi
  800573:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800576:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800579:	eb cc                	jmp    800547 <vprintfmt+0x267>
  80057b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80057e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80058c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058e:	83 eb 01             	sub    $0x1,%ebx
  800591:	85 db                	test   %ebx,%ebx
  800593:	7f ec                	jg     800581 <vprintfmt+0x2a1>
  800595:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800598:	e9 6f fd ff ff       	jmp    80030c <vprintfmt+0x2c>
  80059d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a0:	83 f9 01             	cmp    $0x1,%ecx
  8005a3:	7e 17                	jle    8005bc <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	83 c0 08             	add    $0x8,%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ae:	8b 50 f8             	mov    -0x8(%eax),%edx
  8005b1:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8005b4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ba:	eb 34                	jmp    8005f0 <vprintfmt+0x310>
	else if (lflag)
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	74 19                	je     8005d9 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	83 c0 04             	add    $0x4,%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c9:	8b 40 fc             	mov    -0x4(%eax),%eax
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	89 c1                	mov    %eax,%ecx
  8005d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d7:	eb 17                	jmp    8005f0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	83 c0 04             	add    $0x4,%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e2:	8b 40 fc             	mov    -0x4(%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 c2                	mov    %eax,%edx
  8005ea:	c1 fa 1f             	sar    $0x1f,%edx
  8005ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005f6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ff:	0f 89 9c 00 00 00    	jns    8006a1 <vprintfmt+0x3c1>
				putch('-', putdat);
  800605:	89 74 24 04          	mov    %esi,0x4(%esp)
  800609:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800610:	ff d7                	call   *%edi
				num = -(long long) num;
  800612:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800615:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800618:	f7 d9                	neg    %ecx
  80061a:	83 d3 00             	adc    $0x0,%ebx
  80061d:	f7 db                	neg    %ebx
  80061f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800624:	eb 7b                	jmp    8006a1 <vprintfmt+0x3c1>
  800626:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800629:	89 ca                	mov    %ecx,%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 53 fc ff ff       	call   800286 <getuint>
  800633:	89 c1                	mov    %eax,%ecx
  800635:	89 d3                	mov    %edx,%ebx
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80063c:	eb 63                	jmp    8006a1 <vprintfmt+0x3c1>
  80063e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800641:	89 ca                	mov    %ecx,%edx
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
  800646:	e8 3b fc ff ff       	call   800286 <getuint>
  80064b:	89 c1                	mov    %eax,%ecx
  80064d:	89 d3                	mov    %edx,%ebx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800654:	eb 4b                	jmp    8006a1 <vprintfmt+0x3c1>
  800656:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800659:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800664:	ff d7                	call   *%edi
			putch('x', putdat);
  800666:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800671:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	83 c0 04             	add    $0x4,%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  80067f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800684:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800689:	eb 16                	jmp    8006a1 <vprintfmt+0x3c1>
  80068b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068e:	89 ca                	mov    %ecx,%edx
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
  800693:	e8 ee fb ff ff       	call   800286 <getuint>
  800698:	89 c1                	mov    %eax,%ecx
  80069a:	89 d3                	mov    %edx,%ebx
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b4:	89 0c 24             	mov    %ecx,(%esp)
  8006b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bb:	89 f2                	mov    %esi,%edx
  8006bd:	89 f8                	mov    %edi,%eax
  8006bf:	e8 cc fa ff ff       	call   800190 <printnum>
  8006c4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006c7:	e9 40 fc ff ff       	jmp    80030c <vprintfmt+0x2c>
  8006cc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006cf:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d6:	89 14 24             	mov    %edx,(%esp)
  8006d9:	ff d7                	call   *%edi
  8006db:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8006de:	e9 29 fc ff ff       	jmp    80030c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ee:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006f3:	80 38 25             	cmpb   $0x25,(%eax)
  8006f6:	0f 84 10 fc ff ff    	je     80030c <vprintfmt+0x2c>
  8006fc:	89 c3                	mov    %eax,%ebx
  8006fe:	eb f0                	jmp    8006f0 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800700:	83 c4 5c             	add    $0x5c,%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 28             	sub    $0x28,%esp
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 04                	je     80071c <vsnprintf+0x14>
  800718:	85 d2                	test   %edx,%edx
  80071a:	7f 07                	jg     800723 <vsnprintf+0x1b>
  80071c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800721:	eb 3b                	jmp    80075e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800726:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80072a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80072d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073b:	8b 45 10             	mov    0x10(%ebp),%eax
  80073e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800745:	89 44 24 04          	mov    %eax,0x4(%esp)
  800749:	c7 04 24 c3 02 80 00 	movl   $0x8002c3,(%esp)
  800750:	e8 8b fb ff ff       	call   8002e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800755:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800758:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	89 44 24 08          	mov    %eax,0x8(%esp)
  800774:	8b 45 0c             	mov    0xc(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	e8 82 ff ff ff       	call   800708 <vsnprintf>
	va_end(ap);

	return rc;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800795:	8b 45 10             	mov    0x10(%ebp),%eax
  800798:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	89 04 24             	mov    %eax,(%esp)
  8007a9:	e8 32 fb ff ff       	call   8002e0 <vprintfmt>
	va_end(ap);
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007be:	74 09                	je     8007c9 <strlen+0x19>
		n++;
  8007c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c7:	75 f7                	jne    8007c0 <strlen+0x10>
		n++;
	return n;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d5:	85 c9                	test   %ecx,%ecx
  8007d7:	74 19                	je     8007f2 <strnlen+0x27>
  8007d9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007dc:	74 14                	je     8007f2 <strnlen+0x27>
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e6:	39 c8                	cmp    %ecx,%eax
  8007e8:	74 0d                	je     8007f7 <strnlen+0x2c>
  8007ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007ee:	75 f3                	jne    8007e3 <strnlen+0x18>
  8007f0:	eb 05                	jmp    8007f7 <strnlen+0x2c>
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800804:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800809:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80080d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	84 c9                	test   %cl,%cl
  800815:	75 f2                	jne    800809 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	85 f6                	test   %esi,%esi
  80082a:	74 18                	je     800844 <strncpy+0x2a>
  80082c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800831:	0f b6 1a             	movzbl (%edx),%ebx
  800834:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800837:	80 3a 01             	cmpb   $0x1,(%edx)
  80083a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083d:	83 c1 01             	add    $0x1,%ecx
  800840:	39 ce                	cmp    %ecx,%esi
  800842:	77 ed                	ja     800831 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
  80084d:	8b 75 08             	mov    0x8(%ebp),%esi
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800856:	89 f0                	mov    %esi,%eax
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	74 27                	je     800883 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80085c:	83 e9 01             	sub    $0x1,%ecx
  80085f:	74 1d                	je     80087e <strlcpy+0x36>
  800861:	0f b6 1a             	movzbl (%edx),%ebx
  800864:	84 db                	test   %bl,%bl
  800866:	74 16                	je     80087e <strlcpy+0x36>
			*dst++ = *src++;
  800868:	88 18                	mov    %bl,(%eax)
  80086a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086d:	83 e9 01             	sub    $0x1,%ecx
  800870:	74 0e                	je     800880 <strlcpy+0x38>
			*dst++ = *src++;
  800872:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800875:	0f b6 1a             	movzbl (%edx),%ebx
  800878:	84 db                	test   %bl,%bl
  80087a:	75 ec                	jne    800868 <strlcpy+0x20>
  80087c:	eb 02                	jmp    800880 <strlcpy+0x38>
  80087e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800880:	c6 00 00             	movb   $0x0,(%eax)
  800883:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800892:	0f b6 01             	movzbl (%ecx),%eax
  800895:	84 c0                	test   %al,%al
  800897:	74 15                	je     8008ae <strcmp+0x25>
  800899:	3a 02                	cmp    (%edx),%al
  80089b:	75 11                	jne    8008ae <strcmp+0x25>
		p++, q++;
  80089d:	83 c1 01             	add    $0x1,%ecx
  8008a0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a3:	0f b6 01             	movzbl (%ecx),%eax
  8008a6:	84 c0                	test   %al,%al
  8008a8:	74 04                	je     8008ae <strcmp+0x25>
  8008aa:	3a 02                	cmp    (%edx),%al
  8008ac:	74 ef                	je     80089d <strcmp+0x14>
  8008ae:	0f b6 c0             	movzbl %al,%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 23                	je     8008ec <strncmp+0x34>
  8008c9:	0f b6 1a             	movzbl (%edx),%ebx
  8008cc:	84 db                	test   %bl,%bl
  8008ce:	74 24                	je     8008f4 <strncmp+0x3c>
  8008d0:	3a 19                	cmp    (%ecx),%bl
  8008d2:	75 20                	jne    8008f4 <strncmp+0x3c>
  8008d4:	83 e8 01             	sub    $0x1,%eax
  8008d7:	74 13                	je     8008ec <strncmp+0x34>
		n--, p++, q++;
  8008d9:	83 c2 01             	add    $0x1,%edx
  8008dc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008df:	0f b6 1a             	movzbl (%edx),%ebx
  8008e2:	84 db                	test   %bl,%bl
  8008e4:	74 0e                	je     8008f4 <strncmp+0x3c>
  8008e6:	3a 19                	cmp    (%ecx),%bl
  8008e8:	74 ea                	je     8008d4 <strncmp+0x1c>
  8008ea:	eb 08                	jmp    8008f4 <strncmp+0x3c>
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f4:	0f b6 02             	movzbl (%edx),%eax
  8008f7:	0f b6 11             	movzbl (%ecx),%edx
  8008fa:	29 d0                	sub    %edx,%eax
  8008fc:	eb f3                	jmp    8008f1 <strncmp+0x39>

008008fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800908:	0f b6 10             	movzbl (%eax),%edx
  80090b:	84 d2                	test   %dl,%dl
  80090d:	74 15                	je     800924 <strchr+0x26>
		if (*s == c)
  80090f:	38 ca                	cmp    %cl,%dl
  800911:	75 07                	jne    80091a <strchr+0x1c>
  800913:	eb 14                	jmp    800929 <strchr+0x2b>
  800915:	38 ca                	cmp    %cl,%dl
  800917:	90                   	nop
  800918:	74 0f                	je     800929 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	0f b6 10             	movzbl (%eax),%edx
  800920:	84 d2                	test   %dl,%dl
  800922:	75 f1                	jne    800915 <strchr+0x17>
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800935:	0f b6 10             	movzbl (%eax),%edx
  800938:	84 d2                	test   %dl,%dl
  80093a:	74 18                	je     800954 <strfind+0x29>
		if (*s == c)
  80093c:	38 ca                	cmp    %cl,%dl
  80093e:	75 0a                	jne    80094a <strfind+0x1f>
  800940:	eb 12                	jmp    800954 <strfind+0x29>
  800942:	38 ca                	cmp    %cl,%dl
  800944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800948:	74 0a                	je     800954 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
  800950:	84 d2                	test   %dl,%dl
  800952:	75 ee                	jne    800942 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	53                   	push   %ebx
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800960:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800963:	89 da                	mov    %ebx,%edx
  800965:	83 ea 01             	sub    $0x1,%edx
  800968:	78 0d                	js     800977 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  80096a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80096c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  80096e:	88 0a                	mov    %cl,(%edx)
  800970:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800973:	39 da                	cmp    %ebx,%edx
  800975:	75 f7                	jne    80096e <memset+0x18>
		*p++ = c;

	return v;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 75 0c             	mov    0xc(%ebp),%esi
  800985:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800988:	85 db                	test   %ebx,%ebx
  80098a:	74 13                	je     80099f <memcpy+0x25>
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800991:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800995:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800998:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  80099b:	39 da                	cmp    %ebx,%edx
  80099d:	75 f2                	jne    800991 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  8009b2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  8009b4:	39 c6                	cmp    %eax,%esi
  8009b6:	72 0b                	jb     8009c3 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  8009bd:	85 db                	test   %ebx,%ebx
  8009bf:	75 2e                	jne    8009ef <memmove+0x4c>
  8009c1:	eb 3a                	jmp    8009fd <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c3:	01 df                	add    %ebx,%edi
  8009c5:	39 f8                	cmp    %edi,%eax
  8009c7:	73 ef                	jae    8009b8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  8009c9:	85 db                	test   %ebx,%ebx
  8009cb:	90                   	nop
  8009cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009d0:	74 2b                	je     8009fd <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  8009d2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  8009da:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  8009df:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  8009e3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  8009e6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  8009e9:	85 c9                	test   %ecx,%ecx
  8009eb:	75 ed                	jne    8009da <memmove+0x37>
  8009ed:	eb 0e                	jmp    8009fd <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  8009ef:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009f3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  8009f9:	39 d3                	cmp    %edx,%ebx
  8009fb:	75 f2                	jne    8009ef <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 36                	je     800a4b <memcmp+0x49>
		if (*s1 != *s2)
  800a15:	0f b6 06             	movzbl (%esi),%eax
  800a18:	0f b6 1f             	movzbl (%edi),%ebx
  800a1b:	38 d8                	cmp    %bl,%al
  800a1d:	74 20                	je     800a3f <memcmp+0x3d>
  800a1f:	eb 14                	jmp    800a35 <memcmp+0x33>
  800a21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800a26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	83 e9 01             	sub    $0x1,%ecx
  800a31:	38 d8                	cmp    %bl,%al
  800a33:	74 12                	je     800a47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 db             	movzbl %bl,%ebx
  800a3b:	29 d8                	sub    %ebx,%eax
  800a3d:	eb 11                	jmp    800a50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	83 e9 01             	sub    $0x1,%ecx
  800a42:	ba 00 00 00 00       	mov    $0x0,%edx
  800a47:	85 c9                	test   %ecx,%ecx
  800a49:	75 d6                	jne    800a21 <memcmp+0x1f>
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a60:	39 d0                	cmp    %edx,%eax
  800a62:	73 15                	jae    800a79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a68:	38 08                	cmp    %cl,(%eax)
  800a6a:	75 06                	jne    800a72 <memfind+0x1d>
  800a6c:	eb 0b                	jmp    800a79 <memfind+0x24>
  800a6e:	38 08                	cmp    %cl,(%eax)
  800a70:	74 07                	je     800a79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	39 c2                	cmp    %eax,%edx
  800a77:	77 f5                	ja     800a6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	83 ec 04             	sub    $0x4,%esp
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8a:	0f b6 02             	movzbl (%edx),%eax
  800a8d:	3c 20                	cmp    $0x20,%al
  800a8f:	74 04                	je     800a95 <strtol+0x1a>
  800a91:	3c 09                	cmp    $0x9,%al
  800a93:	75 0e                	jne    800aa3 <strtol+0x28>
		s++;
  800a95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a98:	0f b6 02             	movzbl (%edx),%eax
  800a9b:	3c 20                	cmp    $0x20,%al
  800a9d:	74 f6                	je     800a95 <strtol+0x1a>
  800a9f:	3c 09                	cmp    $0x9,%al
  800aa1:	74 f2                	je     800a95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa3:	3c 2b                	cmp    $0x2b,%al
  800aa5:	75 0c                	jne    800ab3 <strtol+0x38>
		s++;
  800aa7:	83 c2 01             	add    $0x1,%edx
  800aaa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ab1:	eb 15                	jmp    800ac8 <strtol+0x4d>
	else if (*s == '-')
  800ab3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800aba:	3c 2d                	cmp    $0x2d,%al
  800abc:	75 0a                	jne    800ac8 <strtol+0x4d>
		s++, neg = 1;
  800abe:	83 c2 01             	add    $0x1,%edx
  800ac1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	0f 94 c0             	sete   %al
  800acd:	74 05                	je     800ad4 <strtol+0x59>
  800acf:	83 fb 10             	cmp    $0x10,%ebx
  800ad2:	75 18                	jne    800aec <strtol+0x71>
  800ad4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ad7:	75 13                	jne    800aec <strtol+0x71>
  800ad9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800add:	8d 76 00             	lea    0x0(%esi),%esi
  800ae0:	75 0a                	jne    800aec <strtol+0x71>
		s += 2, base = 16;
  800ae2:	83 c2 02             	add    $0x2,%edx
  800ae5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aea:	eb 15                	jmp    800b01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aec:	84 c0                	test   %al,%al
  800aee:	66 90                	xchg   %ax,%ax
  800af0:	74 0f                	je     800b01 <strtol+0x86>
  800af2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800af7:	80 3a 30             	cmpb   $0x30,(%edx)
  800afa:	75 05                	jne    800b01 <strtol+0x86>
		s++, base = 8;
  800afc:	83 c2 01             	add    $0x1,%edx
  800aff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b08:	0f b6 0a             	movzbl (%edx),%ecx
  800b0b:	89 cf                	mov    %ecx,%edi
  800b0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b10:	80 fb 09             	cmp    $0x9,%bl
  800b13:	77 08                	ja     800b1d <strtol+0xa2>
			dig = *s - '0';
  800b15:	0f be c9             	movsbl %cl,%ecx
  800b18:	83 e9 30             	sub    $0x30,%ecx
  800b1b:	eb 1e                	jmp    800b3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b20:	80 fb 19             	cmp    $0x19,%bl
  800b23:	77 08                	ja     800b2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800b25:	0f be c9             	movsbl %cl,%ecx
  800b28:	83 e9 57             	sub    $0x57,%ecx
  800b2b:	eb 0e                	jmp    800b3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800b2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b30:	80 fb 19             	cmp    $0x19,%bl
  800b33:	77 15                	ja     800b4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800b35:	0f be c9             	movsbl %cl,%ecx
  800b38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b3b:	39 f1                	cmp    %esi,%ecx
  800b3d:	7d 0b                	jge    800b4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800b3f:	83 c2 01             	add    $0x1,%edx
  800b42:	0f af c6             	imul   %esi,%eax
  800b45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b48:	eb be                	jmp    800b08 <strtol+0x8d>
  800b4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b50:	74 05                	je     800b57 <strtol+0xdc>
		*endptr = (char *) s;
  800b52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b57:	89 ca                	mov    %ecx,%edx
  800b59:	f7 da                	neg    %edx
  800b5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b5f:	0f 45 c2             	cmovne %edx,%eax
}
  800b62:	83 c4 04             	add    $0x4,%esp
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    
	...

00800b6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	89 1c 24             	mov    %ebx,(%esp)
  800b75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b79:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
  800b88:	89 c3                	mov    %eax,%ebx
  800b8a:	89 c7                	mov    %eax,%edi
  800b8c:	89 c6                	mov    %eax,%esi
  800b8e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800b90:	8b 1c 24             	mov    (%esp),%ebx
  800b93:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b97:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b9b:	89 ec                	mov    %ebp,%esp
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	89 1c 24             	mov    %ebx,(%esp)
  800ba8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bac:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800bc4:	8b 1c 24             	mov    (%esp),%ebx
  800bc7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bcb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bcf:	89 ec                	mov    %ebp,%esp
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	83 ec 0c             	sub    $0xc,%esp
  800bd9:	89 1c 24             	mov    %ebx,(%esp)
  800bdc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 cb                	mov    %ecx,%ebx
  800bf3:	89 cf                	mov    %ecx,%edi
  800bf5:	89 ce                	mov    %ecx,%esi
  800bf7:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800bf9:	8b 1c 24             	mov    (%esp),%ebx
  800bfc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c00:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c04:	89 ec                	mov    %ebp,%esp
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	89 1c 24             	mov    %ebx,(%esp)
  800c11:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c15:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c23:	89 d1                	mov    %edx,%ecx
  800c25:	89 d3                	mov    %edx,%ebx
  800c27:	89 d7                	mov    %edx,%edi
  800c29:	89 d6                	mov    %edx,%esi
  800c2b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800c2d:	8b 1c 24             	mov    (%esp),%ebx
  800c30:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c38:	89 ec                	mov    %ebp,%esp
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
  800c3c:	00 00                	add    %al,(%eax)
	...

00800c40 <__udivdi3>:
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	83 ec 10             	sub    $0x10,%esp
  800c48:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	8b 75 10             	mov    0x10(%ebp),%esi
  800c51:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c54:	85 c0                	test   %eax,%eax
  800c56:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800c59:	75 35                	jne    800c90 <__udivdi3+0x50>
  800c5b:	39 fe                	cmp    %edi,%esi
  800c5d:	77 61                	ja     800cc0 <__udivdi3+0x80>
  800c5f:	85 f6                	test   %esi,%esi
  800c61:	75 0b                	jne    800c6e <__udivdi3+0x2e>
  800c63:	b8 01 00 00 00       	mov    $0x1,%eax
  800c68:	31 d2                	xor    %edx,%edx
  800c6a:	f7 f6                	div    %esi
  800c6c:	89 c6                	mov    %eax,%esi
  800c6e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800c71:	31 d2                	xor    %edx,%edx
  800c73:	89 f8                	mov    %edi,%eax
  800c75:	f7 f6                	div    %esi
  800c77:	89 c7                	mov    %eax,%edi
  800c79:	89 c8                	mov    %ecx,%eax
  800c7b:	f7 f6                	div    %esi
  800c7d:	89 c1                	mov    %eax,%ecx
  800c7f:	89 fa                	mov    %edi,%edx
  800c81:	89 c8                	mov    %ecx,%eax
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    
  800c8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c90:	39 f8                	cmp    %edi,%eax
  800c92:	77 1c                	ja     800cb0 <__udivdi3+0x70>
  800c94:	0f bd d0             	bsr    %eax,%edx
  800c97:	83 f2 1f             	xor    $0x1f,%edx
  800c9a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800c9d:	75 39                	jne    800cd8 <__udivdi3+0x98>
  800c9f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800ca2:	0f 86 a0 00 00 00    	jbe    800d48 <__udivdi3+0x108>
  800ca8:	39 f8                	cmp    %edi,%eax
  800caa:	0f 82 98 00 00 00    	jb     800d48 <__udivdi3+0x108>
  800cb0:	31 ff                	xor    %edi,%edi
  800cb2:	31 c9                	xor    %ecx,%ecx
  800cb4:	89 c8                	mov    %ecx,%eax
  800cb6:	89 fa                	mov    %edi,%edx
  800cb8:	83 c4 10             	add    $0x10,%esp
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    
  800cbf:	90                   	nop
  800cc0:	89 d1                	mov    %edx,%ecx
  800cc2:	89 fa                	mov    %edi,%edx
  800cc4:	89 c8                	mov    %ecx,%eax
  800cc6:	31 ff                	xor    %edi,%edi
  800cc8:	f7 f6                	div    %esi
  800cca:	89 c1                	mov    %eax,%ecx
  800ccc:	89 fa                	mov    %edi,%edx
  800cce:	89 c8                	mov    %ecx,%eax
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    
  800cd7:	90                   	nop
  800cd8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800cdc:	89 f2                	mov    %esi,%edx
  800cde:	d3 e0                	shl    %cl,%eax
  800ce0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ce3:	b8 20 00 00 00       	mov    $0x20,%eax
  800ce8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800ceb:	89 c1                	mov    %eax,%ecx
  800ced:	d3 ea                	shr    %cl,%edx
  800cef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800cf3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800cf6:	d3 e6                	shl    %cl,%esi
  800cf8:	89 c1                	mov    %eax,%ecx
  800cfa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800cfd:	89 fe                	mov    %edi,%esi
  800cff:	d3 ee                	shr    %cl,%esi
  800d01:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d05:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800d08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d0b:	d3 e7                	shl    %cl,%edi
  800d0d:	89 c1                	mov    %eax,%ecx
  800d0f:	d3 ea                	shr    %cl,%edx
  800d11:	09 d7                	or     %edx,%edi
  800d13:	89 f2                	mov    %esi,%edx
  800d15:	89 f8                	mov    %edi,%eax
  800d17:	f7 75 ec             	divl   -0x14(%ebp)
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	89 c7                	mov    %eax,%edi
  800d1e:	f7 65 e8             	mull   -0x18(%ebp)
  800d21:	39 d6                	cmp    %edx,%esi
  800d23:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800d26:	72 30                	jb     800d58 <__udivdi3+0x118>
  800d28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d2b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d2f:	d3 e2                	shl    %cl,%edx
  800d31:	39 c2                	cmp    %eax,%edx
  800d33:	73 05                	jae    800d3a <__udivdi3+0xfa>
  800d35:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800d38:	74 1e                	je     800d58 <__udivdi3+0x118>
  800d3a:	89 f9                	mov    %edi,%ecx
  800d3c:	31 ff                	xor    %edi,%edi
  800d3e:	e9 71 ff ff ff       	jmp    800cb4 <__udivdi3+0x74>
  800d43:	90                   	nop
  800d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d48:	31 ff                	xor    %edi,%edi
  800d4a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d4f:	e9 60 ff ff ff       	jmp    800cb4 <__udivdi3+0x74>
  800d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d58:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800d5b:	31 ff                	xor    %edi,%edi
  800d5d:	89 c8                	mov    %ecx,%eax
  800d5f:	89 fa                	mov    %edi,%edx
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
	...

00800d70 <__umoddi3>:
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	83 ec 20             	sub    $0x20,%esp
  800d78:	8b 55 14             	mov    0x14(%ebp),%edx
  800d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d84:	85 d2                	test   %edx,%edx
  800d86:	89 c8                	mov    %ecx,%eax
  800d88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d8b:	75 13                	jne    800da0 <__umoddi3+0x30>
  800d8d:	39 f7                	cmp    %esi,%edi
  800d8f:	76 3f                	jbe    800dd0 <__umoddi3+0x60>
  800d91:	89 f2                	mov    %esi,%edx
  800d93:	f7 f7                	div    %edi
  800d95:	89 d0                	mov    %edx,%eax
  800d97:	31 d2                	xor    %edx,%edx
  800d99:	83 c4 20             	add    $0x20,%esp
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    
  800da0:	39 f2                	cmp    %esi,%edx
  800da2:	77 4c                	ja     800df0 <__umoddi3+0x80>
  800da4:	0f bd ca             	bsr    %edx,%ecx
  800da7:	83 f1 1f             	xor    $0x1f,%ecx
  800daa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800dad:	75 51                	jne    800e00 <__umoddi3+0x90>
  800daf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  800db2:	0f 87 e0 00 00 00    	ja     800e98 <__umoddi3+0x128>
  800db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dbb:	29 f8                	sub    %edi,%eax
  800dbd:	19 d6                	sbb    %edx,%esi
  800dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dc5:	89 f2                	mov    %esi,%edx
  800dc7:	83 c4 20             	add    $0x20,%esp
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
  800dce:	66 90                	xchg   %ax,%ax
  800dd0:	85 ff                	test   %edi,%edi
  800dd2:	75 0b                	jne    800ddf <__umoddi3+0x6f>
  800dd4:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd9:	31 d2                	xor    %edx,%edx
  800ddb:	f7 f7                	div    %edi
  800ddd:	89 c7                	mov    %eax,%edi
  800ddf:	89 f0                	mov    %esi,%eax
  800de1:	31 d2                	xor    %edx,%edx
  800de3:	f7 f7                	div    %edi
  800de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de8:	f7 f7                	div    %edi
  800dea:	eb a9                	jmp    800d95 <__umoddi3+0x25>
  800dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df0:	89 c8                	mov    %ecx,%eax
  800df2:	89 f2                	mov    %esi,%edx
  800df4:	83 c4 20             	add    $0x20,%esp
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    
  800dfb:	90                   	nop
  800dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e00:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e04:	d3 e2                	shl    %cl,%edx
  800e06:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800e09:	ba 20 00 00 00       	mov    $0x20,%edx
  800e0e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  800e11:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800e14:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e18:	89 fa                	mov    %edi,%edx
  800e1a:	d3 ea                	shr    %cl,%edx
  800e1c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e20:	0b 55 f4             	or     -0xc(%ebp),%edx
  800e23:	d3 e7                	shl    %cl,%edi
  800e25:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e29:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800e2c:	89 f2                	mov    %esi,%edx
  800e2e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  800e31:	89 c7                	mov    %eax,%edi
  800e33:	d3 ea                	shr    %cl,%edx
  800e35:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	d3 e6                	shl    %cl,%esi
  800e40:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e44:	d3 ea                	shr    %cl,%edx
  800e46:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e4a:	09 d6                	or     %edx,%esi
  800e4c:	89 f0                	mov    %esi,%eax
  800e4e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800e51:	d3 e7                	shl    %cl,%edi
  800e53:	89 f2                	mov    %esi,%edx
  800e55:	f7 75 f4             	divl   -0xc(%ebp)
  800e58:	89 d6                	mov    %edx,%esi
  800e5a:	f7 65 e8             	mull   -0x18(%ebp)
  800e5d:	39 d6                	cmp    %edx,%esi
  800e5f:	72 2b                	jb     800e8c <__umoddi3+0x11c>
  800e61:	39 c7                	cmp    %eax,%edi
  800e63:	72 23                	jb     800e88 <__umoddi3+0x118>
  800e65:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e69:	29 c7                	sub    %eax,%edi
  800e6b:	19 d6                	sbb    %edx,%esi
  800e6d:	89 f0                	mov    %esi,%eax
  800e6f:	89 f2                	mov    %esi,%edx
  800e71:	d3 ef                	shr    %cl,%edi
  800e73:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e77:	d3 e0                	shl    %cl,%eax
  800e79:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e7d:	09 f8                	or     %edi,%eax
  800e7f:	d3 ea                	shr    %cl,%edx
  800e81:	83 c4 20             	add    $0x20,%esp
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	39 d6                	cmp    %edx,%esi
  800e8a:	75 d9                	jne    800e65 <__umoddi3+0xf5>
  800e8c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  800e8f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  800e92:	eb d1                	jmp    800e65 <__umoddi3+0xf5>
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	0f 82 18 ff ff ff    	jb     800db8 <__umoddi3+0x48>
  800ea0:	e9 1d ff ff ff       	jmp    800dc2 <__umoddi3+0x52>
