
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 97 00 00 00       	call   8000c8 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 27 0c 00 00       	call   800c68 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (env == &envs[1]) {
  800043:	81 3d 04 20 80 00 88 	cmpl   $0xeec00088,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 85 0e 00 00       	call   800eef <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  80007c:	e8 10 01 00 00       	call   800191 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 d4 00 c0 ee       	mov    0xeec000d4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 71 12 80 00 	movl   $0x801271,(%esp)
  800097:	e8 f5 00 00 00       	call   800191 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	bb d4 00 c0 ee       	mov    $0xeec000d4,%ebx
  8000a1:	8b 03                	mov    (%ebx),%eax
  8000a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b2:	00 
  8000b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ba:	00 
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 c1 0d 00 00       	call   800e84 <ipc_send>
  8000c3:	eb dc                	jmp    8000a1 <umain+0x6d>
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
  8000ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000d1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  8000da:	e8 89 0b 00 00       	call   800c68 <sys_getenvid>
  8000df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e4:	89 c2                	mov    %eax,%edx
  8000e6:	c1 e2 07             	shl    $0x7,%edx
  8000e9:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000f0:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f5:	85 f6                	test   %esi,%esi
  8000f7:	7e 07                	jle    800100 <libmain+0x38>
		binaryname = argv[0];
  8000f9:	8b 03                	mov    (%ebx),%eax
  8000fb:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800100:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800104:	89 34 24             	mov    %esi,(%esp)
  800107:	e8 28 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80010c:	e8 0b 00 00 00       	call   80011c <exit>
}
  800111:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800114:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800117:	89 ec                	mov    %ebp,%esp
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    
	...

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800122:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800129:	e8 05 0b 00 00       	call   800c33 <sys_env_destroy>
}
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800139:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800140:	00 00 00 
	b.cnt = 0;
  800143:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800150:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800154:	8b 45 08             	mov    0x8(%ebp),%eax
  800157:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800161:	89 44 24 04          	mov    %eax,0x4(%esp)
  800165:	c7 04 24 ab 01 80 00 	movl   $0x8001ab,(%esp)
  80016c:	e8 cf 01 00 00       	call   800340 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800181:	89 04 24             	mov    %eax,(%esp)
  800184:	e8 43 0a 00 00       	call   800bcc <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 87 ff ff ff       	call   800130 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 14             	sub    $0x14,%esp
  8001b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b5:	8b 03                	mov    (%ebx),%eax
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001be:	83 c0 01             	add    $0x1,%eax
  8001c1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c8:	75 19                	jne    8001e3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ca:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d1:	00 
  8001d2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 ef 09 00 00       	call   800bcc <sys_cputs>
		b->idx = 0;
  8001dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    
  8001ed:	00 00                	add    %al,(%eax)
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
  80026d:	e8 6e 0d 00 00       	call   800fe0 <__udivdi3>
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
  8002c8:	e8 43 0e 00 00       	call   801110 <__umoddi3>
  8002cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d1:	0f be 80 9f 12 80 00 	movsbl 0x80129f(%eax),%eax
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
  8003b8:	ff 24 95 60 13 80 00 	jmp    *0x801360(,%edx,4)
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
  80048e:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  800495:	85 d2                	test   %edx,%edx
  800497:	75 20                	jne    8004b9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049d:	c7 44 24 08 b0 12 80 	movl   $0x8012b0,0x8(%esp)
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
  8004bd:	c7 44 24 08 b9 12 80 	movl   $0x8012b9,0x8(%esp)
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
  8004f8:	b8 bc 12 80 00       	mov    $0x8012bc,%eax
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

00800e84 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 1c             	sub    $0x1c,%esp
  800e8d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e90:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");

	int r;
	while ((r = sys_ipc_try_send (to_env, val, pg != NULL ? pg : (void *) UTOP, perm)) < 0) 
  800e96:	eb 2a                	jmp    800ec2 <ipc_send+0x3e>
	{
		//cprintf("bug is not in sys_ipc_try_send\n");		//for debug
		if (r != -E_IPC_NOT_RECV)
  800e98:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e9b:	74 20                	je     800ebd <ipc_send+0x39>
			panic ("ipc_send: send message error %e", r);
  800e9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ea1:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800eb0:	00 
  800eb1:	c7 04 24 04 15 80 00 	movl   $0x801504,(%esp)
  800eb8:	e8 bb 00 00 00       	call   800f78 <_panic>
		sys_yield ();
  800ebd:	e8 da fd ff ff       	call   800c9c <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");

	int r;
	while ((r = sys_ipc_try_send (to_env, val, pg != NULL ? pg : (void *) UTOP, perm)) < 0) 
  800ec2:	85 db                	test   %ebx,%ebx
  800ec4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800ec9:	0f 45 c3             	cmovne %ebx,%eax
  800ecc:	8b 55 14             	mov    0x14(%ebp),%edx
  800ecf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ed3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800edb:	89 34 24             	mov    %esi,(%esp)
  800ede:	e8 32 ff ff ff       	call   800e15 <sys_ipc_try_send>
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	78 b1                	js     800e98 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic ("ipc_send: send message error %e", r);
		sys_yield ();
	}

}
  800ee7:	83 c4 1c             	add    $0x1c,%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
uint32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 28             	sub    $0x28,%esp
  800ef5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800efe:	8b 75 08             	mov    0x8(%ebp),%esi
  800f01:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	
	int r;
	if (pg != NULL)
  800f04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f08:	74 10                	je     800f1a <ipc_recv+0x2b>
	    r = sys_ipc_recv ((void *) UTOP);
  800f0a:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  800f11:	e8 37 ff ff ff       	call   800e4d <sys_ipc_recv>
  800f16:	89 c3                	mov    %eax,%ebx
  800f18:	eb 0e                	jmp    800f28 <ipc_recv+0x39>
	else
	    r = sys_ipc_recv (pg);
  800f1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f21:	e8 27 ff ff ff       	call   800e4d <sys_ipc_recv>
  800f26:	89 c3                	mov    %eax,%ebx
	struct Env *curenv = (struct Env *) envs + ENVX (sys_getenvid ());
  800f28:	e8 3b fd ff ff       	call   800c68 <sys_getenvid>
  800f2d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f32:	89 c2                	mov    %eax,%edx
  800f34:	c1 e2 07             	shl    $0x7,%edx
  800f37:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
	if (from_env_store != NULL)
  800f3e:	85 f6                	test   %esi,%esi
  800f40:	74 0e                	je     800f50 <ipc_recv+0x61>
		*from_env_store = r < 0 ? 0 : curenv->env_ipc_from;
  800f42:	b8 00 00 00 00       	mov    $0x0,%eax
  800f47:	85 db                	test   %ebx,%ebx
  800f49:	78 03                	js     800f4e <ipc_recv+0x5f>
  800f4b:	8b 42 74             	mov    0x74(%edx),%eax
  800f4e:	89 06                	mov    %eax,(%esi)
	if (perm_store != NULL)
  800f50:	85 ff                	test   %edi,%edi
  800f52:	74 0e                	je     800f62 <ipc_recv+0x73>
		*perm_store = r < 0 ? 0 : curenv->env_ipc_perm;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
  800f59:	85 db                	test   %ebx,%ebx
  800f5b:	78 03                	js     800f60 <ipc_recv+0x71>
  800f5d:	8b 42 78             	mov    0x78(%edx),%eax
  800f60:	89 07                	mov    %eax,(%edi)
	if (r < 0)
		return r;
  800f62:	89 d8                	mov    %ebx,%eax
	struct Env *curenv = (struct Env *) envs + ENVX (sys_getenvid ());
	if (from_env_store != NULL)
		*from_env_store = r < 0 ? 0 : curenv->env_ipc_from;
	if (perm_store != NULL)
		*perm_store = r < 0 ? 0 : curenv->env_ipc_perm;
	if (r < 0)
  800f64:	85 db                	test   %ebx,%ebx
  800f66:	78 03                	js     800f6b <ipc_recv+0x7c>
		return r;
	return curenv->env_ipc_value;
  800f68:	8b 42 70             	mov    0x70(%edx),%eax
}
  800f6b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f71:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f74:	89 ec                	mov    %ebp,%esp
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800f7e:	a1 08 20 80 00       	mov    0x802008,%eax
  800f83:	85 c0                	test   %eax,%eax
  800f85:	74 10                	je     800f97 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8b:	c7 04 24 0e 15 80 00 	movl   $0x80150e,(%esp)
  800f92:	e8 fa f1 ff ff       	call   800191 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800f97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa5:	a1 00 20 80 00       	mov    0x802000,%eax
  800faa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fae:	c7 04 24 13 15 80 00 	movl   $0x801513,(%esp)
  800fb5:	e8 d7 f1 ff ff       	call   800191 <cprintf>
	vcprintf(fmt, ap);
  800fba:	8d 45 14             	lea    0x14(%ebp),%eax
  800fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc4:	89 04 24             	mov    %eax,(%esp)
  800fc7:	e8 64 f1 ff ff       	call   800130 <vcprintf>
	cprintf("\n");
  800fcc:	c7 04 24 6f 12 80 00 	movl   $0x80126f,(%esp)
  800fd3:	e8 b9 f1 ff ff       	call   800191 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fd8:	cc                   	int3   
  800fd9:	eb fd                	jmp    800fd8 <_panic+0x60>
  800fdb:	00 00                	add    %al,(%eax)
  800fdd:	00 00                	add    %al,(%eax)
	...

00800fe0 <__udivdi3>:
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	83 ec 10             	sub    $0x10,%esp
  800fe8:	8b 45 14             	mov    0x14(%ebp),%eax
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	8b 75 10             	mov    0x10(%ebp),%esi
  800ff1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800ff9:	75 35                	jne    801030 <__udivdi3+0x50>
  800ffb:	39 fe                	cmp    %edi,%esi
  800ffd:	77 61                	ja     801060 <__udivdi3+0x80>
  800fff:	85 f6                	test   %esi,%esi
  801001:	75 0b                	jne    80100e <__udivdi3+0x2e>
  801003:	b8 01 00 00 00       	mov    $0x1,%eax
  801008:	31 d2                	xor    %edx,%edx
  80100a:	f7 f6                	div    %esi
  80100c:	89 c6                	mov    %eax,%esi
  80100e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801011:	31 d2                	xor    %edx,%edx
  801013:	89 f8                	mov    %edi,%eax
  801015:	f7 f6                	div    %esi
  801017:	89 c7                	mov    %eax,%edi
  801019:	89 c8                	mov    %ecx,%eax
  80101b:	f7 f6                	div    %esi
  80101d:	89 c1                	mov    %eax,%ecx
  80101f:	89 fa                	mov    %edi,%edx
  801021:	89 c8                	mov    %ecx,%eax
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    
  80102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801030:	39 f8                	cmp    %edi,%eax
  801032:	77 1c                	ja     801050 <__udivdi3+0x70>
  801034:	0f bd d0             	bsr    %eax,%edx
  801037:	83 f2 1f             	xor    $0x1f,%edx
  80103a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80103d:	75 39                	jne    801078 <__udivdi3+0x98>
  80103f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801042:	0f 86 a0 00 00 00    	jbe    8010e8 <__udivdi3+0x108>
  801048:	39 f8                	cmp    %edi,%eax
  80104a:	0f 82 98 00 00 00    	jb     8010e8 <__udivdi3+0x108>
  801050:	31 ff                	xor    %edi,%edi
  801052:	31 c9                	xor    %ecx,%ecx
  801054:	89 c8                	mov    %ecx,%eax
  801056:	89 fa                	mov    %edi,%edx
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	5e                   	pop    %esi
  80105c:	5f                   	pop    %edi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    
  80105f:	90                   	nop
  801060:	89 d1                	mov    %edx,%ecx
  801062:	89 fa                	mov    %edi,%edx
  801064:	89 c8                	mov    %ecx,%eax
  801066:	31 ff                	xor    %edi,%edi
  801068:	f7 f6                	div    %esi
  80106a:	89 c1                	mov    %eax,%ecx
  80106c:	89 fa                	mov    %edi,%edx
  80106e:	89 c8                	mov    %ecx,%eax
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    
  801077:	90                   	nop
  801078:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80107c:	89 f2                	mov    %esi,%edx
  80107e:	d3 e0                	shl    %cl,%eax
  801080:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801083:	b8 20 00 00 00       	mov    $0x20,%eax
  801088:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80108b:	89 c1                	mov    %eax,%ecx
  80108d:	d3 ea                	shr    %cl,%edx
  80108f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801093:	0b 55 ec             	or     -0x14(%ebp),%edx
  801096:	d3 e6                	shl    %cl,%esi
  801098:	89 c1                	mov    %eax,%ecx
  80109a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80109d:	89 fe                	mov    %edi,%esi
  80109f:	d3 ee                	shr    %cl,%esi
  8010a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ab:	d3 e7                	shl    %cl,%edi
  8010ad:	89 c1                	mov    %eax,%ecx
  8010af:	d3 ea                	shr    %cl,%edx
  8010b1:	09 d7                	or     %edx,%edi
  8010b3:	89 f2                	mov    %esi,%edx
  8010b5:	89 f8                	mov    %edi,%eax
  8010b7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ba:	89 d6                	mov    %edx,%esi
  8010bc:	89 c7                	mov    %eax,%edi
  8010be:	f7 65 e8             	mull   -0x18(%ebp)
  8010c1:	39 d6                	cmp    %edx,%esi
  8010c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010c6:	72 30                	jb     8010f8 <__udivdi3+0x118>
  8010c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010cf:	d3 e2                	shl    %cl,%edx
  8010d1:	39 c2                	cmp    %eax,%edx
  8010d3:	73 05                	jae    8010da <__udivdi3+0xfa>
  8010d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010d8:	74 1e                	je     8010f8 <__udivdi3+0x118>
  8010da:	89 f9                	mov    %edi,%ecx
  8010dc:	31 ff                	xor    %edi,%edi
  8010de:	e9 71 ff ff ff       	jmp    801054 <__udivdi3+0x74>
  8010e3:	90                   	nop
  8010e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	31 ff                	xor    %edi,%edi
  8010ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010ef:	e9 60 ff ff ff       	jmp    801054 <__udivdi3+0x74>
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010fb:	31 ff                	xor    %edi,%edi
  8010fd:	89 c8                	mov    %ecx,%eax
  8010ff:	89 fa                	mov    %edi,%edx
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	5e                   	pop    %esi
  801105:	5f                   	pop    %edi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    
	...

00801110 <__umoddi3>:
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	57                   	push   %edi
  801114:	56                   	push   %esi
  801115:	83 ec 20             	sub    $0x20,%esp
  801118:	8b 55 14             	mov    0x14(%ebp),%edx
  80111b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801121:	8b 75 0c             	mov    0xc(%ebp),%esi
  801124:	85 d2                	test   %edx,%edx
  801126:	89 c8                	mov    %ecx,%eax
  801128:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80112b:	75 13                	jne    801140 <__umoddi3+0x30>
  80112d:	39 f7                	cmp    %esi,%edi
  80112f:	76 3f                	jbe    801170 <__umoddi3+0x60>
  801131:	89 f2                	mov    %esi,%edx
  801133:	f7 f7                	div    %edi
  801135:	89 d0                	mov    %edx,%eax
  801137:	31 d2                	xor    %edx,%edx
  801139:	83 c4 20             	add    $0x20,%esp
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    
  801140:	39 f2                	cmp    %esi,%edx
  801142:	77 4c                	ja     801190 <__umoddi3+0x80>
  801144:	0f bd ca             	bsr    %edx,%ecx
  801147:	83 f1 1f             	xor    $0x1f,%ecx
  80114a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80114d:	75 51                	jne    8011a0 <__umoddi3+0x90>
  80114f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801152:	0f 87 e0 00 00 00    	ja     801238 <__umoddi3+0x128>
  801158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115b:	29 f8                	sub    %edi,%eax
  80115d:	19 d6                	sbb    %edx,%esi
  80115f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801165:	89 f2                	mov    %esi,%edx
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    
  80116e:	66 90                	xchg   %ax,%ax
  801170:	85 ff                	test   %edi,%edi
  801172:	75 0b                	jne    80117f <__umoddi3+0x6f>
  801174:	b8 01 00 00 00       	mov    $0x1,%eax
  801179:	31 d2                	xor    %edx,%edx
  80117b:	f7 f7                	div    %edi
  80117d:	89 c7                	mov    %eax,%edi
  80117f:	89 f0                	mov    %esi,%eax
  801181:	31 d2                	xor    %edx,%edx
  801183:	f7 f7                	div    %edi
  801185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801188:	f7 f7                	div    %edi
  80118a:	eb a9                	jmp    801135 <__umoddi3+0x25>
  80118c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801190:	89 c8                	mov    %ecx,%eax
  801192:	89 f2                	mov    %esi,%edx
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
  80119b:	90                   	nop
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a4:	d3 e2                	shl    %cl,%edx
  8011a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011b8:	89 fa                	mov    %edi,%edx
  8011ba:	d3 ea                	shr    %cl,%edx
  8011bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011c3:	d3 e7                	shl    %cl,%edi
  8011c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011d1:	89 c7                	mov    %eax,%edi
  8011d3:	d3 ea                	shr    %cl,%edx
  8011d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	d3 e6                	shl    %cl,%esi
  8011e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011e4:	d3 ea                	shr    %cl,%edx
  8011e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ea:	09 d6                	or     %edx,%esi
  8011ec:	89 f0                	mov    %esi,%eax
  8011ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011f1:	d3 e7                	shl    %cl,%edi
  8011f3:	89 f2                	mov    %esi,%edx
  8011f5:	f7 75 f4             	divl   -0xc(%ebp)
  8011f8:	89 d6                	mov    %edx,%esi
  8011fa:	f7 65 e8             	mull   -0x18(%ebp)
  8011fd:	39 d6                	cmp    %edx,%esi
  8011ff:	72 2b                	jb     80122c <__umoddi3+0x11c>
  801201:	39 c7                	cmp    %eax,%edi
  801203:	72 23                	jb     801228 <__umoddi3+0x118>
  801205:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801209:	29 c7                	sub    %eax,%edi
  80120b:	19 d6                	sbb    %edx,%esi
  80120d:	89 f0                	mov    %esi,%eax
  80120f:	89 f2                	mov    %esi,%edx
  801211:	d3 ef                	shr    %cl,%edi
  801213:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801217:	d3 e0                	shl    %cl,%eax
  801219:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80121d:	09 f8                	or     %edi,%eax
  80121f:	d3 ea                	shr    %cl,%edx
  801221:	83 c4 20             	add    $0x20,%esp
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
  801228:	39 d6                	cmp    %edx,%esi
  80122a:	75 d9                	jne    801205 <__umoddi3+0xf5>
  80122c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80122f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801232:	eb d1                	jmp    801205 <__umoddi3+0xf5>
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	39 f2                	cmp    %esi,%edx
  80123a:	0f 82 18 ff ff ff    	jb     801158 <__umoddi3+0x48>
  801240:	e9 1d ff ff ff       	jmp    801162 <__umoddi3+0x52>
