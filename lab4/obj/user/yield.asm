
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", env->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 4c             	mov    0x4c(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 e0 10 80 00 	movl   $0x8010e0,(%esp)
  80004e:	e8 16 01 00 00       	call   800169 <cprintf>
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 5; i++) {
		sys_yield();
  800058:	e8 1f 0c 00 00       	call   800c7c <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			env->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", env->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 4c             	mov    0x4c(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 00 11 80 00 	movl   $0x801100,(%esp)
  800074:	e8 f0 00 00 00       	call   800169 <cprintf>
umain(void)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", env->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			env->env_id, i);
	}
	cprintf("All done in environment %08x.\n", env->env_id);
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 40 4c             	mov    0x4c(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 2c 11 80 00 	movl   $0x80112c,(%esp)
  800094:	e8 d0 00 00 00       	call   800169 <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  8000b2:	e8 91 0b 00 00       	call   800c48 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	89 c2                	mov    %eax,%edx
  8000be:	c1 e2 07             	shl    $0x7,%edx
  8000c1:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000c8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cd:	85 f6                	test   %esi,%esi
  8000cf:	7e 07                	jle    8000d8 <libmain+0x38>
		binaryname = argv[0];
  8000d1:	8b 03                	mov    (%ebx),%eax
  8000d3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000dc:	89 34 24             	mov    %esi,(%esp)
  8000df:	e8 50 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e4:	e8 0b 00 00 00       	call   8000f4 <exit>
}
  8000e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ec:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ef:	89 ec                	mov    %ebp,%esp
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    
	...

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800101:	e8 0d 0b 00 00       	call   800c13 <sys_env_destroy>
}
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800111:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800118:	00 00 00 
	b.cnt = 0;
  80011b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800122:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012c:	8b 45 08             	mov    0x8(%ebp),%eax
  80012f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800133:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013d:	c7 04 24 83 01 80 00 	movl   $0x800183,(%esp)
  800144:	e8 d7 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800149:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800159:	89 04 24             	mov    %eax,(%esp)
  80015c:	e8 4b 0a 00 00       	call   800bac <sys_cputs>

	return b.cnt;
}
  800161:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80016f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 87 ff ff ff       	call   800108 <vcprintf>
	va_end(ap);

	return cnt;
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	53                   	push   %ebx
  800187:	83 ec 14             	sub    $0x14,%esp
  80018a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018d:	8b 03                	mov    (%ebx),%eax
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800196:	83 c0 01             	add    $0x1,%eax
  800199:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a0:	75 19                	jne    8001bb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001a2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a9:	00 
  8001aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 f7 09 00 00       	call   800bac <sys_cputs>
		b->idx = 0;
  8001b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	83 c4 14             	add    $0x14,%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001fb:	39 d1                	cmp    %edx,%ecx
  8001fd:	72 15                	jb     800214 <printnum+0x44>
  8001ff:	77 07                	ja     800208 <printnum+0x38>
  800201:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800204:	39 d0                	cmp    %edx,%eax
  800206:	76 0c                	jbe    800214 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	85 db                	test   %ebx,%ebx
  80020d:	8d 76 00             	lea    0x0(%esi),%esi
  800210:	7f 61                	jg     800273 <printnum+0xa3>
  800212:	eb 70                	jmp    800284 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800227:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80022b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80022e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800231:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800234:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800249:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024d:	e8 1e 0c 00 00       	call   800e70 <__udivdi3>
  800252:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800255:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	89 54 24 04          	mov    %edx,0x4(%esp)
  800267:	89 f2                	mov    %esi,%edx
  800269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026c:	e8 5f ff ff ff       	call   8001d0 <printnum>
  800271:	eb 11                	jmp    800284 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	89 74 24 04          	mov    %esi,0x4(%esp)
  800277:	89 3c 24             	mov    %edi,(%esp)
  80027a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f ef                	jg     800273 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	89 74 24 04          	mov    %esi,0x4(%esp)
  800288:	8b 74 24 04          	mov    0x4(%esp),%esi
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029a:	00 
  80029b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80029e:	89 14 24             	mov    %edx,(%esp)
  8002a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002a8:	e8 f3 0c 00 00       	call   800fa0 <__umoddi3>
  8002ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b1:	0f be 80 63 11 80 00 	movsbl 0x801163(%eax),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002be:	83 c4 4c             	add    $0x4c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0f                	jle    8002dd <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	83 c2 08             	add    $0x8,%edx
  8002d3:	89 10                	mov    %edx,(%eax)
  8002d5:	8b 42 f8             	mov    -0x8(%edx),%eax
  8002d8:	8b 52 fc             	mov    -0x4(%edx),%edx
  8002db:	eb 24                	jmp    800301 <getuint+0x3b>
	else if (lflag)
  8002dd:	85 d2                	test   %edx,%edx
  8002df:	74 11                	je     8002f2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	83 c2 04             	add    $0x4,%edx
  8002e6:	89 10                	mov    %edx,(%eax)
  8002e8:	8b 42 fc             	mov    -0x4(%edx),%eax
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f0:	eb 0f                	jmp    800301 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	83 c2 04             	add    $0x4,%edx
  8002f7:	89 10                	mov    %edx,(%eax)
  8002f9:	8b 42 fc             	mov    -0x4(%edx),%eax
  8002fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800309:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	3b 50 04             	cmp    0x4(%eax),%edx
  800312:	73 0a                	jae    80031e <sprintputch+0x1b>
		*b->buf++ = ch;
  800314:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800317:	88 0a                	mov    %cl,(%edx)
  800319:	83 c2 01             	add    $0x1,%edx
  80031c:	89 10                	mov    %edx,(%eax)
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 5c             	sub    $0x5c,%esp
  800329:	8b 7d 08             	mov    0x8(%ebp),%edi
  80032c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80032f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800332:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800339:	eb 11                	jmp    80034c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033b:	85 c0                	test   %eax,%eax
  80033d:	0f 84 fd 03 00 00    	je     800740 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800343:	89 74 24 04          	mov    %esi,0x4(%esp)
  800347:	89 04 24             	mov    %eax,(%esp)
  80034a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034c:	0f b6 03             	movzbl (%ebx),%eax
  80034f:	83 c3 01             	add    $0x1,%ebx
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e4                	jne    80033b <vprintfmt+0x1b>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800370:	b9 00 00 00 00       	mov    $0x0,%ecx
  800375:	eb 06                	jmp    80037d <vprintfmt+0x5d>
  800377:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80037b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	0f b6 13             	movzbl (%ebx),%edx
  800380:	0f b6 c2             	movzbl %dl,%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	8d 43 01             	lea    0x1(%ebx),%eax
  800389:	83 ea 23             	sub    $0x23,%edx
  80038c:	80 fa 55             	cmp    $0x55,%dl
  80038f:	0f 87 8e 03 00 00    	ja     800723 <vprintfmt+0x403>
  800395:	0f b6 d2             	movzbl %dl,%edx
  800398:	ff 24 95 20 12 80 00 	jmp    *0x801220(,%edx,4)
  80039f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a3:	eb d6                	jmp    80037b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a8:	83 ea 30             	sub    $0x30,%edx
  8003ab:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8003ae:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003b1:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003b4:	83 fb 09             	cmp    $0x9,%ebx
  8003b7:	77 55                	ja     80040e <vprintfmt+0xee>
  8003b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003bc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bf:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003c2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003c5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003c9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003cc:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003cf:	83 fb 09             	cmp    $0x9,%ebx
  8003d2:	76 eb                	jbe    8003bf <vprintfmt+0x9f>
  8003d4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003d7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003da:	eb 32                	jmp    80040e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dc:	8b 55 14             	mov    0x14(%ebp),%edx
  8003df:	83 c2 04             	add    $0x4,%edx
  8003e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e5:	8b 52 fc             	mov    -0x4(%edx),%edx
  8003e8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8003eb:	eb 21                	jmp    80040e <vprintfmt+0xee>

		case '.':
			if (width < 0)
  8003ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8003fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003fd:	e9 79 ff ff ff       	jmp    80037b <vprintfmt+0x5b>
  800402:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800409:	e9 6d ff ff ff       	jmp    80037b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80040e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800412:	0f 89 63 ff ff ff    	jns    80037b <vprintfmt+0x5b>
  800418:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80041b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80041e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800421:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800424:	e9 52 ff ff ff       	jmp    80037b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800429:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80042c:	e9 4a ff ff ff       	jmp    80037b <vprintfmt+0x5b>
  800431:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	83 c0 04             	add    $0x4,%eax
  80043a:	89 45 14             	mov    %eax,0x14(%ebp)
  80043d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800441:	8b 40 fc             	mov    -0x4(%eax),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	ff d7                	call   *%edi
  800449:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80044c:	e9 fb fe ff ff       	jmp    80034c <vprintfmt+0x2c>
  800451:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	83 c0 04             	add    $0x4,%eax
  80045a:	89 45 14             	mov    %eax,0x14(%ebp)
  80045d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800460:	89 c2                	mov    %eax,%edx
  800462:	c1 fa 1f             	sar    $0x1f,%edx
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 08             	cmp    $0x8,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x159>
  80046e:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 20                	jne    800499 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800479:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047d:	c7 44 24 08 74 11 80 	movl   $0x801174,0x8(%esp)
  800484:	00 
  800485:	89 74 24 04          	mov    %esi,0x4(%esp)
  800489:	89 3c 24             	mov    %edi,(%esp)
  80048c:	e8 37 03 00 00       	call   8007c8 <printfmt>
  800491:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800494:	e9 b3 fe ff ff       	jmp    80034c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800499:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049d:	c7 44 24 08 7d 11 80 	movl   $0x80117d,0x8(%esp)
  8004a4:	00 
  8004a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a9:	89 3c 24             	mov    %edi,(%esp)
  8004ac:	e8 17 03 00 00       	call   8007c8 <printfmt>
  8004b1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8004b4:	e9 93 fe ff ff       	jmp    80034c <vprintfmt+0x2c>
  8004b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004bc:	89 c3                	mov    %eax,%ebx
  8004be:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004c4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	83 c0 04             	add    $0x4,%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d0:	8b 40 fc             	mov    -0x4(%eax),%eax
  8004d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	b8 80 11 80 00       	mov    $0x801180,%eax
  8004dd:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004e4:	85 c9                	test   %ecx,%ecx
  8004e6:	7e 06                	jle    8004ee <vprintfmt+0x1ce>
  8004e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ec:	75 13                	jne    800501 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f1:	0f be 02             	movsbl (%edx),%eax
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	0f 85 99 00 00 00    	jne    800595 <vprintfmt+0x275>
  8004fc:	e9 86 00 00 00       	jmp    800587 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	89 54 24 04          	mov    %edx,0x4(%esp)
  800505:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800508:	89 0c 24             	mov    %ecx,(%esp)
  80050b:	e8 fb 02 00 00       	call   80080b <strnlen>
  800510:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800513:	29 c2                	sub    %eax,%edx
  800515:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800518:	85 d2                	test   %edx,%edx
  80051a:	7e d2                	jle    8004ee <vprintfmt+0x1ce>
					putch(padc, putdat);
  80051c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800520:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800523:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800526:	89 d3                	mov    %edx,%ebx
  800528:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	83 eb 01             	sub    $0x1,%ebx
  800537:	85 db                	test   %ebx,%ebx
  800539:	7f ed                	jg     800528 <vprintfmt+0x208>
  80053b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80053e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800545:	eb a7                	jmp    8004ee <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800547:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054b:	74 18                	je     800565 <vprintfmt+0x245>
  80054d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800550:	83 fa 5e             	cmp    $0x5e,%edx
  800553:	76 10                	jbe    800565 <vprintfmt+0x245>
					putch('?', putdat);
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800560:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800563:	eb 0a                	jmp    80056f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800565:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800573:	0f be 03             	movsbl (%ebx),%eax
  800576:	85 c0                	test   %eax,%eax
  800578:	74 05                	je     80057f <vprintfmt+0x25f>
  80057a:	83 c3 01             	add    $0x1,%ebx
  80057d:	eb 29                	jmp    8005a8 <vprintfmt+0x288>
  80057f:	89 fe                	mov    %edi,%esi
  800581:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800584:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800587:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80058b:	7f 2e                	jg     8005bb <vprintfmt+0x29b>
  80058d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800590:	e9 b7 fd ff ff       	jmp    80034c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800595:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800598:	83 c2 01             	add    $0x1,%edx
  80059b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80059e:	89 f7                	mov    %esi,%edi
  8005a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005a6:	89 d3                	mov    %edx,%ebx
  8005a8:	85 f6                	test   %esi,%esi
  8005aa:	78 9b                	js     800547 <vprintfmt+0x227>
  8005ac:	83 ee 01             	sub    $0x1,%esi
  8005af:	79 96                	jns    800547 <vprintfmt+0x227>
  8005b1:	89 fe                	mov    %edi,%esi
  8005b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005b6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b9:	eb cc                	jmp    800587 <vprintfmt+0x267>
  8005bb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005be:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005cc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ce:	83 eb 01             	sub    $0x1,%ebx
  8005d1:	85 db                	test   %ebx,%ebx
  8005d3:	7f ec                	jg     8005c1 <vprintfmt+0x2a1>
  8005d5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005d8:	e9 6f fd ff ff       	jmp    80034c <vprintfmt+0x2c>
  8005dd:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e0:	83 f9 01             	cmp    $0x1,%ecx
  8005e3:	7e 17                	jle    8005fc <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	83 c0 08             	add    $0x8,%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ee:	8b 50 f8             	mov    -0x8(%eax),%edx
  8005f1:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8005f4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fa:	eb 34                	jmp    800630 <vprintfmt+0x310>
	else if (lflag)
  8005fc:	85 c9                	test   %ecx,%ecx
  8005fe:	74 19                	je     800619 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	83 c0 04             	add    $0x4,%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
  800609:	8b 40 fc             	mov    -0x4(%eax),%eax
  80060c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060f:	89 c1                	mov    %eax,%ecx
  800611:	c1 f9 1f             	sar    $0x1f,%ecx
  800614:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800617:	eb 17                	jmp    800630 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	83 c0 04             	add    $0x4,%eax
  80061f:	89 45 14             	mov    %eax,0x14(%ebp)
  800622:	8b 40 fc             	mov    -0x4(%eax),%eax
  800625:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800628:	89 c2                	mov    %eax,%edx
  80062a:	c1 fa 1f             	sar    $0x1f,%edx
  80062d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800630:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800633:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80063b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063f:	0f 89 9c 00 00 00    	jns    8006e1 <vprintfmt+0x3c1>
				putch('-', putdat);
  800645:	89 74 24 04          	mov    %esi,0x4(%esp)
  800649:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800650:	ff d7                	call   *%edi
				num = -(long long) num;
  800652:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800655:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800658:	f7 d9                	neg    %ecx
  80065a:	83 d3 00             	adc    $0x0,%ebx
  80065d:	f7 db                	neg    %ebx
  80065f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800664:	eb 7b                	jmp    8006e1 <vprintfmt+0x3c1>
  800666:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800669:	89 ca                	mov    %ecx,%edx
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 53 fc ff ff       	call   8002c6 <getuint>
  800673:	89 c1                	mov    %eax,%ecx
  800675:	89 d3                	mov    %edx,%ebx
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80067c:	eb 63                	jmp    8006e1 <vprintfmt+0x3c1>
  80067e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 3b fc ff ff       	call   8002c6 <getuint>
  80068b:	89 c1                	mov    %eax,%ecx
  80068d:	89 d3                	mov    %edx,%ebx
  80068f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800694:	eb 4b                	jmp    8006e1 <vprintfmt+0x3c1>
  800696:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800699:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a4:	ff d7                	call   *%edi
			putch('x', putdat);
  8006a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006aa:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	83 c0 04             	add    $0x4,%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bc:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8006bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c4:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c9:	eb 16                	jmp    8006e1 <vprintfmt+0x3c1>
  8006cb:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ce:	89 ca                	mov    %ecx,%edx
  8006d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d3:	e8 ee fb ff ff       	call   8002c6 <getuint>
  8006d8:	89 c1                	mov    %eax,%ecx
  8006da:	89 d3                	mov    %edx,%ebx
  8006dc:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f4:	89 0c 24             	mov    %ecx,(%esp)
  8006f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fb:	89 f2                	mov    %esi,%edx
  8006fd:	89 f8                	mov    %edi,%eax
  8006ff:	e8 cc fa ff ff       	call   8001d0 <printnum>
  800704:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800707:	e9 40 fc ff ff       	jmp    80034c <vprintfmt+0x2c>
  80070c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80070f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800712:	89 74 24 04          	mov    %esi,0x4(%esp)
  800716:	89 14 24             	mov    %edx,(%esp)
  800719:	ff d7                	call   *%edi
  80071b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80071e:	e9 29 fc ff ff       	jmp    80034c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800723:	89 74 24 04          	mov    %esi,0x4(%esp)
  800727:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80072e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800730:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800733:	80 38 25             	cmpb   $0x25,(%eax)
  800736:	0f 84 10 fc ff ff    	je     80034c <vprintfmt+0x2c>
  80073c:	89 c3                	mov    %eax,%ebx
  80073e:	eb f0                	jmp    800730 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800740:	83 c4 5c             	add    $0x5c,%esp
  800743:	5b                   	pop    %ebx
  800744:	5e                   	pop    %esi
  800745:	5f                   	pop    %edi
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	83 ec 28             	sub    $0x28,%esp
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800754:	85 c0                	test   %eax,%eax
  800756:	74 04                	je     80075c <vsnprintf+0x14>
  800758:	85 d2                	test   %edx,%edx
  80075a:	7f 07                	jg     800763 <vsnprintf+0x1b>
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800761:	eb 3b                	jmp    80079e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800763:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800766:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80076a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80076d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077b:	8b 45 10             	mov    0x10(%ebp),%eax
  80077e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800782:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800785:	89 44 24 04          	mov    %eax,0x4(%esp)
  800789:	c7 04 24 03 03 80 00 	movl   $0x800303,(%esp)
  800790:	e8 8b fb ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800795:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800798:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	e8 82 ff ff ff       	call   800748 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	89 04 24             	mov    %eax,(%esp)
  8007e9:	e8 32 fb ff ff       	call   800320 <vprintfmt>
	va_end(ap);
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007fe:	74 09                	je     800809 <strlen+0x19>
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800807:	75 f7                	jne    800800 <strlen+0x10>
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800815:	85 c9                	test   %ecx,%ecx
  800817:	74 19                	je     800832 <strnlen+0x27>
  800819:	80 3b 00             	cmpb   $0x0,(%ebx)
  80081c:	74 14                	je     800832 <strnlen+0x27>
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800823:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	39 c8                	cmp    %ecx,%eax
  800828:	74 0d                	je     800837 <strnlen+0x2c>
  80082a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80082e:	75 f3                	jne    800823 <strnlen+0x18>
  800830:	eb 05                	jmp    800837 <strnlen+0x2c>
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800844:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800849:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80084d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	84 c9                	test   %cl,%cl
  800855:	75 f2                	jne    800849 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800868:	85 f6                	test   %esi,%esi
  80086a:	74 18                	je     800884 <strncpy+0x2a>
  80086c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800871:	0f b6 1a             	movzbl (%edx),%ebx
  800874:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800877:	80 3a 01             	cmpb   $0x1,(%edx)
  80087a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087d:	83 c1 01             	add    $0x1,%ecx
  800880:	39 ce                	cmp    %ecx,%esi
  800882:	77 ed                	ja     800871 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	8b 75 08             	mov    0x8(%ebp),%esi
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800896:	89 f0                	mov    %esi,%eax
  800898:	85 c9                	test   %ecx,%ecx
  80089a:	74 27                	je     8008c3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80089c:	83 e9 01             	sub    $0x1,%ecx
  80089f:	74 1d                	je     8008be <strlcpy+0x36>
  8008a1:	0f b6 1a             	movzbl (%edx),%ebx
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	74 16                	je     8008be <strlcpy+0x36>
			*dst++ = *src++;
  8008a8:	88 18                	mov    %bl,(%eax)
  8008aa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ad:	83 e9 01             	sub    $0x1,%ecx
  8008b0:	74 0e                	je     8008c0 <strlcpy+0x38>
			*dst++ = *src++;
  8008b2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b5:	0f b6 1a             	movzbl (%edx),%ebx
  8008b8:	84 db                	test   %bl,%bl
  8008ba:	75 ec                	jne    8008a8 <strlcpy+0x20>
  8008bc:	eb 02                	jmp    8008c0 <strlcpy+0x38>
  8008be:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c0:	c6 00 00             	movb   $0x0,(%eax)
  8008c3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d2:	0f b6 01             	movzbl (%ecx),%eax
  8008d5:	84 c0                	test   %al,%al
  8008d7:	74 15                	je     8008ee <strcmp+0x25>
  8008d9:	3a 02                	cmp    (%edx),%al
  8008db:	75 11                	jne    8008ee <strcmp+0x25>
		p++, q++;
  8008dd:	83 c1 01             	add    $0x1,%ecx
  8008e0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e3:	0f b6 01             	movzbl (%ecx),%eax
  8008e6:	84 c0                	test   %al,%al
  8008e8:	74 04                	je     8008ee <strcmp+0x25>
  8008ea:	3a 02                	cmp    (%edx),%al
  8008ec:	74 ef                	je     8008dd <strcmp+0x14>
  8008ee:	0f b6 c0             	movzbl %al,%eax
  8008f1:	0f b6 12             	movzbl (%edx),%edx
  8008f4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	53                   	push   %ebx
  8008fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800902:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800905:	85 c0                	test   %eax,%eax
  800907:	74 23                	je     80092c <strncmp+0x34>
  800909:	0f b6 1a             	movzbl (%edx),%ebx
  80090c:	84 db                	test   %bl,%bl
  80090e:	74 24                	je     800934 <strncmp+0x3c>
  800910:	3a 19                	cmp    (%ecx),%bl
  800912:	75 20                	jne    800934 <strncmp+0x3c>
  800914:	83 e8 01             	sub    $0x1,%eax
  800917:	74 13                	je     80092c <strncmp+0x34>
		n--, p++, q++;
  800919:	83 c2 01             	add    $0x1,%edx
  80091c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091f:	0f b6 1a             	movzbl (%edx),%ebx
  800922:	84 db                	test   %bl,%bl
  800924:	74 0e                	je     800934 <strncmp+0x3c>
  800926:	3a 19                	cmp    (%ecx),%bl
  800928:	74 ea                	je     800914 <strncmp+0x1c>
  80092a:	eb 08                	jmp    800934 <strncmp+0x3c>
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800931:	5b                   	pop    %ebx
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800934:	0f b6 02             	movzbl (%edx),%eax
  800937:	0f b6 11             	movzbl (%ecx),%edx
  80093a:	29 d0                	sub    %edx,%eax
  80093c:	eb f3                	jmp    800931 <strncmp+0x39>

0080093e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	0f b6 10             	movzbl (%eax),%edx
  80094b:	84 d2                	test   %dl,%dl
  80094d:	74 15                	je     800964 <strchr+0x26>
		if (*s == c)
  80094f:	38 ca                	cmp    %cl,%dl
  800951:	75 07                	jne    80095a <strchr+0x1c>
  800953:	eb 14                	jmp    800969 <strchr+0x2b>
  800955:	38 ca                	cmp    %cl,%dl
  800957:	90                   	nop
  800958:	74 0f                	je     800969 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 10             	movzbl (%eax),%edx
  800960:	84 d2                	test   %dl,%dl
  800962:	75 f1                	jne    800955 <strchr+0x17>
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	74 18                	je     800994 <strfind+0x29>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	75 0a                	jne    80098a <strfind+0x1f>
  800980:	eb 12                	jmp    800994 <strfind+0x29>
  800982:	38 ca                	cmp    %cl,%dl
  800984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800988:	74 0a                	je     800994 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 ee                	jne    800982 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009a3:	89 da                	mov    %ebx,%edx
  8009a5:	83 ea 01             	sub    $0x1,%edx
  8009a8:	78 0d                	js     8009b7 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  8009aa:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  8009ac:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  8009ae:	88 0a                	mov    %cl,(%edx)
  8009b0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009b3:	39 da                	cmp    %ebx,%edx
  8009b5:	75 f7                	jne    8009ae <memset+0x18>
		*p++ = c;

	return v;
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8009c8:	85 db                	test   %ebx,%ebx
  8009ca:	74 13                	je     8009df <memcpy+0x25>
  8009cc:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  8009d1:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009d5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009d8:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8009db:	39 da                	cmp    %ebx,%edx
  8009dd:	75 f2                	jne    8009d1 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  8009f2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  8009f4:	39 c6                	cmp    %eax,%esi
  8009f6:	72 0b                	jb     800a03 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  8009f8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  8009fd:	85 db                	test   %ebx,%ebx
  8009ff:	75 2e                	jne    800a2f <memmove+0x4c>
  800a01:	eb 3a                	jmp    800a3d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a03:	01 df                	add    %ebx,%edi
  800a05:	39 f8                	cmp    %edi,%eax
  800a07:	73 ef                	jae    8009f8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800a09:	85 db                	test   %ebx,%ebx
  800a0b:	90                   	nop
  800a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a10:	74 2b                	je     800a3d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a12:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800a1a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800a1f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800a23:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a26:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800a29:	85 c9                	test   %ecx,%ecx
  800a2b:	75 ed                	jne    800a1a <memmove+0x37>
  800a2d:	eb 0e                	jmp    800a3d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a2f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a33:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a36:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a39:	39 d3                	cmp    %edx,%ebx
  800a3b:	75 f2                	jne    800a2f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a51:	85 c9                	test   %ecx,%ecx
  800a53:	74 36                	je     800a8b <memcmp+0x49>
		if (*s1 != *s2)
  800a55:	0f b6 06             	movzbl (%esi),%eax
  800a58:	0f b6 1f             	movzbl (%edi),%ebx
  800a5b:	38 d8                	cmp    %bl,%al
  800a5d:	74 20                	je     800a7f <memcmp+0x3d>
  800a5f:	eb 14                	jmp    800a75 <memcmp+0x33>
  800a61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800a66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800a6b:	83 c2 01             	add    $0x1,%edx
  800a6e:	83 e9 01             	sub    $0x1,%ecx
  800a71:	38 d8                	cmp    %bl,%al
  800a73:	74 12                	je     800a87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800a75:	0f b6 c0             	movzbl %al,%eax
  800a78:	0f b6 db             	movzbl %bl,%ebx
  800a7b:	29 d8                	sub    %ebx,%eax
  800a7d:	eb 11                	jmp    800a90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7f:	83 e9 01             	sub    $0x1,%ecx
  800a82:	ba 00 00 00 00       	mov    $0x0,%edx
  800a87:	85 c9                	test   %ecx,%ecx
  800a89:	75 d6                	jne    800a61 <memcmp+0x1f>
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a9b:	89 c2                	mov    %eax,%edx
  800a9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa0:	39 d0                	cmp    %edx,%eax
  800aa2:	73 15                	jae    800ab9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800aa8:	38 08                	cmp    %cl,(%eax)
  800aaa:	75 06                	jne    800ab2 <memfind+0x1d>
  800aac:	eb 0b                	jmp    800ab9 <memfind+0x24>
  800aae:	38 08                	cmp    %cl,(%eax)
  800ab0:	74 07                	je     800ab9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab2:	83 c0 01             	add    $0x1,%eax
  800ab5:	39 c2                	cmp    %eax,%edx
  800ab7:	77 f5                	ja     800aae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 04             	sub    $0x4,%esp
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aca:	0f b6 02             	movzbl (%edx),%eax
  800acd:	3c 20                	cmp    $0x20,%al
  800acf:	74 04                	je     800ad5 <strtol+0x1a>
  800ad1:	3c 09                	cmp    $0x9,%al
  800ad3:	75 0e                	jne    800ae3 <strtol+0x28>
		s++;
  800ad5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad8:	0f b6 02             	movzbl (%edx),%eax
  800adb:	3c 20                	cmp    $0x20,%al
  800add:	74 f6                	je     800ad5 <strtol+0x1a>
  800adf:	3c 09                	cmp    $0x9,%al
  800ae1:	74 f2                	je     800ad5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae3:	3c 2b                	cmp    $0x2b,%al
  800ae5:	75 0c                	jne    800af3 <strtol+0x38>
		s++;
  800ae7:	83 c2 01             	add    $0x1,%edx
  800aea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800af1:	eb 15                	jmp    800b08 <strtol+0x4d>
	else if (*s == '-')
  800af3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800afa:	3c 2d                	cmp    $0x2d,%al
  800afc:	75 0a                	jne    800b08 <strtol+0x4d>
		s++, neg = 1;
  800afe:	83 c2 01             	add    $0x1,%edx
  800b01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b08:	85 db                	test   %ebx,%ebx
  800b0a:	0f 94 c0             	sete   %al
  800b0d:	74 05                	je     800b14 <strtol+0x59>
  800b0f:	83 fb 10             	cmp    $0x10,%ebx
  800b12:	75 18                	jne    800b2c <strtol+0x71>
  800b14:	80 3a 30             	cmpb   $0x30,(%edx)
  800b17:	75 13                	jne    800b2c <strtol+0x71>
  800b19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b1d:	8d 76 00             	lea    0x0(%esi),%esi
  800b20:	75 0a                	jne    800b2c <strtol+0x71>
		s += 2, base = 16;
  800b22:	83 c2 02             	add    $0x2,%edx
  800b25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2a:	eb 15                	jmp    800b41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2c:	84 c0                	test   %al,%al
  800b2e:	66 90                	xchg   %ax,%ax
  800b30:	74 0f                	je     800b41 <strtol+0x86>
  800b32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b37:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3a:	75 05                	jne    800b41 <strtol+0x86>
		s++, base = 8;
  800b3c:	83 c2 01             	add    $0x1,%edx
  800b3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b48:	0f b6 0a             	movzbl (%edx),%ecx
  800b4b:	89 cf                	mov    %ecx,%edi
  800b4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b50:	80 fb 09             	cmp    $0x9,%bl
  800b53:	77 08                	ja     800b5d <strtol+0xa2>
			dig = *s - '0';
  800b55:	0f be c9             	movsbl %cl,%ecx
  800b58:	83 e9 30             	sub    $0x30,%ecx
  800b5b:	eb 1e                	jmp    800b7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800b5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b60:	80 fb 19             	cmp    $0x19,%bl
  800b63:	77 08                	ja     800b6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800b65:	0f be c9             	movsbl %cl,%ecx
  800b68:	83 e9 57             	sub    $0x57,%ecx
  800b6b:	eb 0e                	jmp    800b7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800b6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b70:	80 fb 19             	cmp    $0x19,%bl
  800b73:	77 15                	ja     800b8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800b75:	0f be c9             	movsbl %cl,%ecx
  800b78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b7b:	39 f1                	cmp    %esi,%ecx
  800b7d:	7d 0b                	jge    800b8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800b7f:	83 c2 01             	add    $0x1,%edx
  800b82:	0f af c6             	imul   %esi,%eax
  800b85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b88:	eb be                	jmp    800b48 <strtol+0x8d>
  800b8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b90:	74 05                	je     800b97 <strtol+0xdc>
		*endptr = (char *) s;
  800b92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b97:	89 ca                	mov    %ecx,%edx
  800b99:	f7 da                	neg    %edx
  800b9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b9f:	0f 45 c2             	cmovne %edx,%eax
}
  800ba2:	83 c4 04             	add    $0x4,%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    
	...

00800bac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	89 1c 24             	mov    %ebx,(%esp)
  800bb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	89 c3                	mov    %eax,%ebx
  800bca:	89 c7                	mov    %eax,%edi
  800bcc:	89 c6                	mov    %eax,%esi
  800bce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800bd0:	8b 1c 24             	mov    (%esp),%ebx
  800bd3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bd7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bdb:	89 ec                	mov    %ebp,%esp
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	89 1c 24             	mov    %ebx,(%esp)
  800be8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bec:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfa:	89 d1                	mov    %edx,%ecx
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800c04:	8b 1c 24             	mov    (%esp),%ebx
  800c07:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c0b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c0f:	89 ec                	mov    %ebp,%esp
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	89 1c 24             	mov    %ebx,(%esp)
  800c1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c20:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c29:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	89 cb                	mov    %ecx,%ebx
  800c33:	89 cf                	mov    %ecx,%edi
  800c35:	89 ce                	mov    %ecx,%esi
  800c37:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800c39:	8b 1c 24             	mov    (%esp),%ebx
  800c3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c40:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c44:	89 ec                	mov    %ebp,%esp
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	89 1c 24             	mov    %ebx,(%esp)
  800c51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c55:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c59:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c63:	89 d1                	mov    %edx,%ecx
  800c65:	89 d3                	mov    %edx,%ebx
  800c67:	89 d7                	mov    %edx,%edi
  800c69:	89 d6                	mov    %edx,%esi
  800c6b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800c6d:	8b 1c 24             	mov    (%esp),%ebx
  800c70:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c78:	89 ec                	mov    %ebp,%esp
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_yield>:

void
sys_yield(void)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	89 1c 24             	mov    %ebx,(%esp)
  800c85:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c89:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800ca1:	8b 1c 24             	mov    (%esp),%ebx
  800ca4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cac:	89 ec                	mov    %ebp,%esp
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	89 1c 24             	mov    %ebx,(%esp)
  800cb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cbd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	be 00 00 00 00       	mov    $0x0,%esi
  800cc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	89 f7                	mov    %esi,%edi
  800cd6:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800cd8:	8b 1c 24             	mov    (%esp),%ebx
  800cdb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cdf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce3:	89 ec                	mov    %ebp,%esp
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	89 1c 24             	mov    %ebx,(%esp)
  800cf0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfd:	8b 75 18             	mov    0x18(%ebp),%esi
  800d00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0e:	8b 1c 24             	mov    (%esp),%ebx
  800d11:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d15:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d19:	89 ec                	mov    %ebp,%esp
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	89 1c 24             	mov    %ebx,(%esp)
  800d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d2a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 06 00 00 00       	mov    $0x6,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800d44:	8b 1c 24             	mov    (%esp),%ebx
  800d47:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d4b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d4f:	89 ec                	mov    %ebp,%esp
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	89 1c 24             	mov    %ebx,(%esp)
  800d5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d60:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800d7a:	8b 1c 24             	mov    (%esp),%ebx
  800d7d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d81:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d85:	89 ec                	mov    %ebp,%esp
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	89 1c 24             	mov    %ebx,(%esp)
  800d92:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d96:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9f:	b8 09 00 00 00       	mov    $0x9,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	89 df                	mov    %ebx,%edi
  800dac:	89 de                	mov    %ebx,%esi
  800dae:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800db0:	8b 1c 24             	mov    (%esp),%ebx
  800db3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800db7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dbb:	89 ec                	mov    %ebp,%esp
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	89 1c 24             	mov    %ebx,(%esp)
  800dc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dcc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	89 df                	mov    %ebx,%edi
  800de2:	89 de                	mov    %ebx,%esi
  800de4:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de6:	8b 1c 24             	mov    (%esp),%ebx
  800de9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ded:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800df1:	89 ec                	mov    %ebp,%esp
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	89 1c 24             	mov    %ebx,(%esp)
  800dfe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e02:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	be 00 00 00 00       	mov    $0x0,%esi
  800e0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1e:	8b 1c 24             	mov    (%esp),%ebx
  800e21:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e25:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e29:	89 ec                	mov    %ebp,%esp
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	83 ec 0c             	sub    $0xc,%esp
  800e33:	89 1c 24             	mov    %ebx,(%esp)
  800e36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	89 cb                	mov    %ecx,%ebx
  800e4d:	89 cf                	mov    %ecx,%edi
  800e4f:	89 ce                	mov    %ecx,%esi
  800e51:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800e53:	8b 1c 24             	mov    (%esp),%ebx
  800e56:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e5a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e5e:	89 ec                	mov    %ebp,%esp
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
	...

00800e70 <__udivdi3>:
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	83 ec 10             	sub    $0x10,%esp
  800e78:	8b 45 14             	mov    0x14(%ebp),%eax
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	8b 75 10             	mov    0x10(%ebp),%esi
  800e81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e84:	85 c0                	test   %eax,%eax
  800e86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e89:	75 35                	jne    800ec0 <__udivdi3+0x50>
  800e8b:	39 fe                	cmp    %edi,%esi
  800e8d:	77 61                	ja     800ef0 <__udivdi3+0x80>
  800e8f:	85 f6                	test   %esi,%esi
  800e91:	75 0b                	jne    800e9e <__udivdi3+0x2e>
  800e93:	b8 01 00 00 00       	mov    $0x1,%eax
  800e98:	31 d2                	xor    %edx,%edx
  800e9a:	f7 f6                	div    %esi
  800e9c:	89 c6                	mov    %eax,%esi
  800e9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800ea1:	31 d2                	xor    %edx,%edx
  800ea3:	89 f8                	mov    %edi,%eax
  800ea5:	f7 f6                	div    %esi
  800ea7:	89 c7                	mov    %eax,%edi
  800ea9:	89 c8                	mov    %ecx,%eax
  800eab:	f7 f6                	div    %esi
  800ead:	89 c1                	mov    %eax,%ecx
  800eaf:	89 fa                	mov    %edi,%edx
  800eb1:	89 c8                	mov    %ecx,%eax
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    
  800eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ec0:	39 f8                	cmp    %edi,%eax
  800ec2:	77 1c                	ja     800ee0 <__udivdi3+0x70>
  800ec4:	0f bd d0             	bsr    %eax,%edx
  800ec7:	83 f2 1f             	xor    $0x1f,%edx
  800eca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800ecd:	75 39                	jne    800f08 <__udivdi3+0x98>
  800ecf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800ed2:	0f 86 a0 00 00 00    	jbe    800f78 <__udivdi3+0x108>
  800ed8:	39 f8                	cmp    %edi,%eax
  800eda:	0f 82 98 00 00 00    	jb     800f78 <__udivdi3+0x108>
  800ee0:	31 ff                	xor    %edi,%edi
  800ee2:	31 c9                	xor    %ecx,%ecx
  800ee4:	89 c8                	mov    %ecx,%eax
  800ee6:	89 fa                	mov    %edi,%edx
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    
  800eef:	90                   	nop
  800ef0:	89 d1                	mov    %edx,%ecx
  800ef2:	89 fa                	mov    %edi,%edx
  800ef4:	89 c8                	mov    %ecx,%eax
  800ef6:	31 ff                	xor    %edi,%edi
  800ef8:	f7 f6                	div    %esi
  800efa:	89 c1                	mov    %eax,%ecx
  800efc:	89 fa                	mov    %edi,%edx
  800efe:	89 c8                	mov    %ecx,%eax
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    
  800f07:	90                   	nop
  800f08:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f0c:	89 f2                	mov    %esi,%edx
  800f0e:	d3 e0                	shl    %cl,%eax
  800f10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f13:	b8 20 00 00 00       	mov    $0x20,%eax
  800f18:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800f1b:	89 c1                	mov    %eax,%ecx
  800f1d:	d3 ea                	shr    %cl,%edx
  800f1f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f23:	0b 55 ec             	or     -0x14(%ebp),%edx
  800f26:	d3 e6                	shl    %cl,%esi
  800f28:	89 c1                	mov    %eax,%ecx
  800f2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800f2d:	89 fe                	mov    %edi,%esi
  800f2f:	d3 ee                	shr    %cl,%esi
  800f31:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f35:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3b:	d3 e7                	shl    %cl,%edi
  800f3d:	89 c1                	mov    %eax,%ecx
  800f3f:	d3 ea                	shr    %cl,%edx
  800f41:	09 d7                	or     %edx,%edi
  800f43:	89 f2                	mov    %esi,%edx
  800f45:	89 f8                	mov    %edi,%eax
  800f47:	f7 75 ec             	divl   -0x14(%ebp)
  800f4a:	89 d6                	mov    %edx,%esi
  800f4c:	89 c7                	mov    %eax,%edi
  800f4e:	f7 65 e8             	mull   -0x18(%ebp)
  800f51:	39 d6                	cmp    %edx,%esi
  800f53:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f56:	72 30                	jb     800f88 <__udivdi3+0x118>
  800f58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f5b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f5f:	d3 e2                	shl    %cl,%edx
  800f61:	39 c2                	cmp    %eax,%edx
  800f63:	73 05                	jae    800f6a <__udivdi3+0xfa>
  800f65:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800f68:	74 1e                	je     800f88 <__udivdi3+0x118>
  800f6a:	89 f9                	mov    %edi,%ecx
  800f6c:	31 ff                	xor    %edi,%edi
  800f6e:	e9 71 ff ff ff       	jmp    800ee4 <__udivdi3+0x74>
  800f73:	90                   	nop
  800f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f78:	31 ff                	xor    %edi,%edi
  800f7a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f7f:	e9 60 ff ff ff       	jmp    800ee4 <__udivdi3+0x74>
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800f8b:	31 ff                	xor    %edi,%edi
  800f8d:	89 c8                	mov    %ecx,%eax
  800f8f:	89 fa                	mov    %edi,%edx
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	5e                   	pop    %esi
  800f95:	5f                   	pop    %edi
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    
	...

00800fa0 <__umoddi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	83 ec 20             	sub    $0x20,%esp
  800fa8:	8b 55 14             	mov    0x14(%ebp),%edx
  800fab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fae:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fb4:	85 d2                	test   %edx,%edx
  800fb6:	89 c8                	mov    %ecx,%eax
  800fb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800fbb:	75 13                	jne    800fd0 <__umoddi3+0x30>
  800fbd:	39 f7                	cmp    %esi,%edi
  800fbf:	76 3f                	jbe    801000 <__umoddi3+0x60>
  800fc1:	89 f2                	mov    %esi,%edx
  800fc3:	f7 f7                	div    %edi
  800fc5:	89 d0                	mov    %edx,%eax
  800fc7:	31 d2                	xor    %edx,%edx
  800fc9:	83 c4 20             	add    $0x20,%esp
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    
  800fd0:	39 f2                	cmp    %esi,%edx
  800fd2:	77 4c                	ja     801020 <__umoddi3+0x80>
  800fd4:	0f bd ca             	bsr    %edx,%ecx
  800fd7:	83 f1 1f             	xor    $0x1f,%ecx
  800fda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fdd:	75 51                	jne    801030 <__umoddi3+0x90>
  800fdf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  800fe2:	0f 87 e0 00 00 00    	ja     8010c8 <__umoddi3+0x128>
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	29 f8                	sub    %edi,%eax
  800fed:	19 d6                	sbb    %edx,%esi
  800fef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff5:	89 f2                	mov    %esi,%edx
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	5e                   	pop    %esi
  800ffb:	5f                   	pop    %edi
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    
  800ffe:	66 90                	xchg   %ax,%ax
  801000:	85 ff                	test   %edi,%edi
  801002:	75 0b                	jne    80100f <__umoddi3+0x6f>
  801004:	b8 01 00 00 00       	mov    $0x1,%eax
  801009:	31 d2                	xor    %edx,%edx
  80100b:	f7 f7                	div    %edi
  80100d:	89 c7                	mov    %eax,%edi
  80100f:	89 f0                	mov    %esi,%eax
  801011:	31 d2                	xor    %edx,%edx
  801013:	f7 f7                	div    %edi
  801015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801018:	f7 f7                	div    %edi
  80101a:	eb a9                	jmp    800fc5 <__umoddi3+0x25>
  80101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801020:	89 c8                	mov    %ecx,%eax
  801022:	89 f2                	mov    %esi,%edx
  801024:	83 c4 20             	add    $0x20,%esp
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    
  80102b:	90                   	nop
  80102c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801030:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801034:	d3 e2                	shl    %cl,%edx
  801036:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801039:	ba 20 00 00 00       	mov    $0x20,%edx
  80103e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801041:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801044:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801048:	89 fa                	mov    %edi,%edx
  80104a:	d3 ea                	shr    %cl,%edx
  80104c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801050:	0b 55 f4             	or     -0xc(%ebp),%edx
  801053:	d3 e7                	shl    %cl,%edi
  801055:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801059:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80105c:	89 f2                	mov    %esi,%edx
  80105e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801061:	89 c7                	mov    %eax,%edi
  801063:	d3 ea                	shr    %cl,%edx
  801065:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801069:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80106c:	89 c2                	mov    %eax,%edx
  80106e:	d3 e6                	shl    %cl,%esi
  801070:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801074:	d3 ea                	shr    %cl,%edx
  801076:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80107a:	09 d6                	or     %edx,%esi
  80107c:	89 f0                	mov    %esi,%eax
  80107e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801081:	d3 e7                	shl    %cl,%edi
  801083:	89 f2                	mov    %esi,%edx
  801085:	f7 75 f4             	divl   -0xc(%ebp)
  801088:	89 d6                	mov    %edx,%esi
  80108a:	f7 65 e8             	mull   -0x18(%ebp)
  80108d:	39 d6                	cmp    %edx,%esi
  80108f:	72 2b                	jb     8010bc <__umoddi3+0x11c>
  801091:	39 c7                	cmp    %eax,%edi
  801093:	72 23                	jb     8010b8 <__umoddi3+0x118>
  801095:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801099:	29 c7                	sub    %eax,%edi
  80109b:	19 d6                	sbb    %edx,%esi
  80109d:	89 f0                	mov    %esi,%eax
  80109f:	89 f2                	mov    %esi,%edx
  8010a1:	d3 ef                	shr    %cl,%edi
  8010a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010a7:	d3 e0                	shl    %cl,%eax
  8010a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010ad:	09 f8                	or     %edi,%eax
  8010af:	d3 ea                	shr    %cl,%edx
  8010b1:	83 c4 20             	add    $0x20,%esp
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    
  8010b8:	39 d6                	cmp    %edx,%esi
  8010ba:	75 d9                	jne    801095 <__umoddi3+0xf5>
  8010bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8010bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8010c2:	eb d1                	jmp    801095 <__umoddi3+0xf5>
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	39 f2                	cmp    %esi,%edx
  8010ca:	0f 82 18 ff ff ff    	jb     800fe8 <__umoddi3+0x48>
  8010d0:	e9 1d ff ff ff       	jmp    800ff2 <__umoddi3+0x52>
