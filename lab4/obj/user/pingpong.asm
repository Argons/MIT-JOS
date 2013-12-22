
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 93 0f 00 00       	call   800fd5 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 48 0c 00 00       	call   800c98 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  80005f:	e8 5d 01 00 00       	call   8001c1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 c9 11 00 00       	call   801250 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 19 12 00 00       	call   8012bb <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 ec 0b 00 00       	call   800c98 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 d6 16 80 00 	movl   $0x8016d6,(%esp)
  8000bf:	e8 fd 00 00 00       	call   8001c1 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 65 11 00 00       	call   801250 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}
		
}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  80010a:	e8 89 0b 00 00       	call   800c98 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	89 c2                	mov    %eax,%edx
  800116:	c1 e2 07             	shl    $0x7,%edx
  800119:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800120:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x38>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 f8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0b 00 00 00       	call   80014c <exit>
}
  800141:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800144:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 05 0b 00 00       	call   800c63 <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	c7 04 24 db 01 80 00 	movl   $0x8001db,(%esp)
  80019c:	e8 cf 01 00 00       	call   800370 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 43 0a 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  8001b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001c7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 87 ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	53                   	push   %ebx
  8001df:	83 ec 14             	sub    $0x14,%esp
  8001e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e5:	8b 03                	mov    (%ebx),%eax
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ee:	83 c0 01             	add    $0x1,%eax
  8001f1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f8:	75 19                	jne    800213 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800201:	00 
  800202:	8d 43 08             	lea    0x8(%ebx),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 ef 09 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  80020d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	83 c4 14             	add    $0x14,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 4c             	sub    $0x4c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800240:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800243:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800246:	b9 00 00 00 00       	mov    $0x0,%ecx
  80024b:	39 d1                	cmp    %edx,%ecx
  80024d:	72 15                	jb     800264 <printnum+0x44>
  80024f:	77 07                	ja     800258 <printnum+0x38>
  800251:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800254:	39 d0                	cmp    %edx,%eax
  800256:	76 0c                	jbe    800264 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	8d 76 00             	lea    0x0(%esi),%esi
  800260:	7f 61                	jg     8002c3 <printnum+0xa3>
  800262:	eb 70                	jmp    8002d4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800264:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800277:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80027b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80027e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800281:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800284:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800288:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028f:	00 
  800290:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800293:	89 04 24             	mov    %eax,(%esp)
  800296:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800299:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029d:	e8 9e 11 00 00       	call   801440 <__udivdi3>
  8002a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b7:	89 f2                	mov    %esi,%edx
  8002b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002bc:	e8 5f ff ff ff       	call   800220 <printnum>
  8002c1:	eb 11                	jmp    8002d4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c7:	89 3c 24             	mov    %edi,(%esp)
  8002ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cd:	83 eb 01             	sub    $0x1,%ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f ef                	jg     8002c3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ea:	00 
  8002eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002ee:	89 14 24             	mov    %edx,(%esp)
  8002f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002f8:	e8 73 12 00 00       	call   801570 <__umoddi3>
  8002fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800301:	0f be 80 00 17 80 00 	movsbl 0x801700(%eax),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80030e:	83 c4 4c             	add    $0x4c,%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800319:	83 fa 01             	cmp    $0x1,%edx
  80031c:	7e 0f                	jle    80032d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	83 c2 08             	add    $0x8,%edx
  800323:	89 10                	mov    %edx,(%eax)
  800325:	8b 42 f8             	mov    -0x8(%edx),%eax
  800328:	8b 52 fc             	mov    -0x4(%edx),%edx
  80032b:	eb 24                	jmp    800351 <getuint+0x3b>
	else if (lflag)
  80032d:	85 d2                	test   %edx,%edx
  80032f:	74 11                	je     800342 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800331:	8b 10                	mov    (%eax),%edx
  800333:	83 c2 04             	add    $0x4,%edx
  800336:	89 10                	mov    %edx,(%eax)
  800338:	8b 42 fc             	mov    -0x4(%edx),%eax
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
  800340:	eb 0f                	jmp    800351 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	83 c2 04             	add    $0x4,%edx
  800347:	89 10                	mov    %edx,(%eax)
  800349:	8b 42 fc             	mov    -0x4(%edx),%eax
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800359:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	3b 50 04             	cmp    0x4(%eax),%edx
  800362:	73 0a                	jae    80036e <sprintputch+0x1b>
		*b->buf++ = ch;
  800364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800367:	88 0a                	mov    %cl,(%edx)
  800369:	83 c2 01             	add    $0x1,%edx
  80036c:	89 10                	mov    %edx,(%eax)
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
  800376:	83 ec 5c             	sub    $0x5c,%esp
  800379:	8b 7d 08             	mov    0x8(%ebp),%edi
  80037c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80037f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800382:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800389:	eb 11                	jmp    80039c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80038b:	85 c0                	test   %eax,%eax
  80038d:	0f 84 fd 03 00 00    	je     800790 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800393:	89 74 24 04          	mov    %esi,0x4(%esp)
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039c:	0f b6 03             	movzbl (%ebx),%eax
  80039f:	83 c3 01             	add    $0x1,%ebx
  8003a2:	83 f8 25             	cmp    $0x25,%eax
  8003a5:	75 e4                	jne    80038b <vprintfmt+0x1b>
  8003a7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003ab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c5:	eb 06                	jmp    8003cd <vprintfmt+0x5d>
  8003c7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003cb:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	0f b6 13             	movzbl (%ebx),%edx
  8003d0:	0f b6 c2             	movzbl %dl,%eax
  8003d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d6:	8d 43 01             	lea    0x1(%ebx),%eax
  8003d9:	83 ea 23             	sub    $0x23,%edx
  8003dc:	80 fa 55             	cmp    $0x55,%dl
  8003df:	0f 87 8e 03 00 00    	ja     800773 <vprintfmt+0x403>
  8003e5:	0f b6 d2             	movzbl %dl,%edx
  8003e8:	ff 24 95 c0 17 80 00 	jmp    *0x8017c0(,%edx,4)
  8003ef:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f3:	eb d6                	jmp    8003cb <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f8:	83 ea 30             	sub    $0x30,%edx
  8003fb:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8003fe:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800401:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800404:	83 fb 09             	cmp    $0x9,%ebx
  800407:	77 55                	ja     80045e <vprintfmt+0xee>
  800409:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800412:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800415:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800419:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80041c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80041f:	83 fb 09             	cmp    $0x9,%ebx
  800422:	76 eb                	jbe    80040f <vprintfmt+0x9f>
  800424:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800427:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042a:	eb 32                	jmp    80045e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042c:	8b 55 14             	mov    0x14(%ebp),%edx
  80042f:	83 c2 04             	add    $0x4,%edx
  800432:	89 55 14             	mov    %edx,0x14(%ebp)
  800435:	8b 52 fc             	mov    -0x4(%edx),%edx
  800438:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80043b:	eb 21                	jmp    80045e <vprintfmt+0xee>

		case '.':
			if (width < 0)
  80043d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800441:	ba 00 00 00 00       	mov    $0x0,%edx
  800446:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  80044a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80044d:	e9 79 ff ff ff       	jmp    8003cb <vprintfmt+0x5b>
  800452:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800459:	e9 6d ff ff ff       	jmp    8003cb <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80045e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800462:	0f 89 63 ff ff ff    	jns    8003cb <vprintfmt+0x5b>
  800468:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80046b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80046e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800471:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800474:	e9 52 ff ff ff       	jmp    8003cb <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800479:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80047c:	e9 4a ff ff ff       	jmp    8003cb <vprintfmt+0x5b>
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	83 c0 04             	add    $0x4,%eax
  80048a:	89 45 14             	mov    %eax,0x14(%ebp)
  80048d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800491:	8b 40 fc             	mov    -0x4(%eax),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	ff d7                	call   *%edi
  800499:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80049c:	e9 fb fe ff ff       	jmp    80039c <vprintfmt+0x2c>
  8004a1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	83 c0 04             	add    $0x4,%eax
  8004aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ad:	8b 40 fc             	mov    -0x4(%eax),%eax
  8004b0:	89 c2                	mov    %eax,%edx
  8004b2:	c1 fa 1f             	sar    $0x1f,%edx
  8004b5:	31 d0                	xor    %edx,%eax
  8004b7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 08             	cmp    $0x8,%eax
  8004bc:	7f 0b                	jg     8004c9 <vprintfmt+0x159>
  8004be:	8b 14 85 20 19 80 00 	mov    0x801920(,%eax,4),%edx
  8004c5:	85 d2                	test   %edx,%edx
  8004c7:	75 20                	jne    8004e9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004cd:	c7 44 24 08 11 17 80 	movl   $0x801711,0x8(%esp)
  8004d4:	00 
  8004d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d9:	89 3c 24             	mov    %edi,(%esp)
  8004dc:	e8 37 03 00 00       	call   800818 <printfmt>
  8004e1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004e4:	e9 b3 fe ff ff       	jmp    80039c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ed:	c7 44 24 08 1a 17 80 	movl   $0x80171a,0x8(%esp)
  8004f4:	00 
  8004f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f9:	89 3c 24             	mov    %edi,(%esp)
  8004fc:	e8 17 03 00 00       	call   800818 <printfmt>
  800501:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800504:	e9 93 fe ff ff       	jmp    80039c <vprintfmt+0x2c>
  800509:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80050c:	89 c3                	mov    %eax,%ebx
  80050e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800511:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800514:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	83 c0 04             	add    $0x4,%eax
  80051d:	89 45 14             	mov    %eax,0x14(%ebp)
  800520:	8b 40 fc             	mov    -0x4(%eax),%eax
  800523:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800526:	85 c0                	test   %eax,%eax
  800528:	b8 1d 17 80 00       	mov    $0x80171d,%eax
  80052d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  800531:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800534:	85 c9                	test   %ecx,%ecx
  800536:	7e 06                	jle    80053e <vprintfmt+0x1ce>
  800538:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80053c:	75 13                	jne    800551 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800541:	0f be 02             	movsbl (%edx),%eax
  800544:	85 c0                	test   %eax,%eax
  800546:	0f 85 99 00 00 00    	jne    8005e5 <vprintfmt+0x275>
  80054c:	e9 86 00 00 00       	jmp    8005d7 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800551:	89 54 24 04          	mov    %edx,0x4(%esp)
  800555:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800558:	89 0c 24             	mov    %ecx,(%esp)
  80055b:	e8 fb 02 00 00       	call   80085b <strnlen>
  800560:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800563:	29 c2                	sub    %eax,%edx
  800565:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800568:	85 d2                	test   %edx,%edx
  80056a:	7e d2                	jle    80053e <vprintfmt+0x1ce>
					putch(padc, putdat);
  80056c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800570:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800573:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800576:	89 d3                	mov    %edx,%ebx
  800578:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	83 eb 01             	sub    $0x1,%ebx
  800587:	85 db                	test   %ebx,%ebx
  800589:	7f ed                	jg     800578 <vprintfmt+0x208>
  80058b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80058e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800595:	eb a7                	jmp    80053e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800597:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059b:	74 18                	je     8005b5 <vprintfmt+0x245>
  80059d:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a0:	83 fa 5e             	cmp    $0x5e,%edx
  8005a3:	76 10                	jbe    8005b5 <vprintfmt+0x245>
					putch('?', putdat);
  8005a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b0:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b3:	eb 0a                	jmp    8005bf <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005c3:	0f be 03             	movsbl (%ebx),%eax
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	74 05                	je     8005cf <vprintfmt+0x25f>
  8005ca:	83 c3 01             	add    $0x1,%ebx
  8005cd:	eb 29                	jmp    8005f8 <vprintfmt+0x288>
  8005cf:	89 fe                	mov    %edi,%esi
  8005d1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005d4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005db:	7f 2e                	jg     80060b <vprintfmt+0x29b>
  8005dd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005e0:	e9 b7 fd ff ff       	jmp    80039c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e8:	83 c2 01             	add    $0x1,%edx
  8005eb:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005ee:	89 f7                	mov    %esi,%edi
  8005f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005f6:	89 d3                	mov    %edx,%ebx
  8005f8:	85 f6                	test   %esi,%esi
  8005fa:	78 9b                	js     800597 <vprintfmt+0x227>
  8005fc:	83 ee 01             	sub    $0x1,%esi
  8005ff:	79 96                	jns    800597 <vprintfmt+0x227>
  800601:	89 fe                	mov    %edi,%esi
  800603:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800606:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800609:	eb cc                	jmp    8005d7 <vprintfmt+0x267>
  80060b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80060e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800611:	89 74 24 04          	mov    %esi,0x4(%esp)
  800615:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80061c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061e:	83 eb 01             	sub    $0x1,%ebx
  800621:	85 db                	test   %ebx,%ebx
  800623:	7f ec                	jg     800611 <vprintfmt+0x2a1>
  800625:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800628:	e9 6f fd ff ff       	jmp    80039c <vprintfmt+0x2c>
  80062d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800630:	83 f9 01             	cmp    $0x1,%ecx
  800633:	7e 17                	jle    80064c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	83 c0 08             	add    $0x8,%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
  80063e:	8b 50 f8             	mov    -0x8(%eax),%edx
  800641:	8b 48 fc             	mov    -0x4(%eax),%ecx
  800644:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800647:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80064a:	eb 34                	jmp    800680 <vprintfmt+0x310>
	else if (lflag)
  80064c:	85 c9                	test   %ecx,%ecx
  80064e:	74 19                	je     800669 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	83 c0 04             	add    $0x4,%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
  800659:	8b 40 fc             	mov    -0x4(%eax),%eax
  80065c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065f:	89 c1                	mov    %eax,%ecx
  800661:	c1 f9 1f             	sar    $0x1f,%ecx
  800664:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800667:	eb 17                	jmp    800680 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	83 c0 04             	add    $0x4,%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
  800672:	8b 40 fc             	mov    -0x4(%eax),%eax
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	89 c2                	mov    %eax,%edx
  80067a:	c1 fa 1f             	sar    $0x1f,%edx
  80067d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800680:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800683:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800686:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80068b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068f:	0f 89 9c 00 00 00    	jns    800731 <vprintfmt+0x3c1>
				putch('-', putdat);
  800695:	89 74 24 04          	mov    %esi,0x4(%esp)
  800699:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a0:	ff d7                	call   *%edi
				num = -(long long) num;
  8006a2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006a5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006a8:	f7 d9                	neg    %ecx
  8006aa:	83 d3 00             	adc    $0x0,%ebx
  8006ad:	f7 db                	neg    %ebx
  8006af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b4:	eb 7b                	jmp    800731 <vprintfmt+0x3c1>
  8006b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006b9:	89 ca                	mov    %ecx,%edx
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 53 fc ff ff       	call   800316 <getuint>
  8006c3:	89 c1                	mov    %eax,%ecx
  8006c5:	89 d3                	mov    %edx,%ebx
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006cc:	eb 63                	jmp    800731 <vprintfmt+0x3c1>
  8006ce:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d1:	89 ca                	mov    %ecx,%edx
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 3b fc ff ff       	call   800316 <getuint>
  8006db:	89 c1                	mov    %eax,%ecx
  8006dd:	89 d3                	mov    %edx,%ebx
  8006df:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8006e4:	eb 4b                	jmp    800731 <vprintfmt+0x3c1>
  8006e6:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ed:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f4:	ff d7                	call   *%edi
			putch('x', putdat);
  8006f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006fa:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800701:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	83 c0 04             	add    $0x4,%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80070c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  80070f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800714:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800719:	eb 16                	jmp    800731 <vprintfmt+0x3c1>
  80071b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80071e:	89 ca                	mov    %ecx,%edx
  800720:	8d 45 14             	lea    0x14(%ebp),%eax
  800723:	e8 ee fb ff ff       	call   800316 <getuint>
  800728:	89 c1                	mov    %eax,%ecx
  80072a:	89 d3                	mov    %edx,%ebx
  80072c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800731:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800735:	89 54 24 10          	mov    %edx,0x10(%esp)
  800739:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80073c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800740:	89 44 24 08          	mov    %eax,0x8(%esp)
  800744:	89 0c 24             	mov    %ecx,(%esp)
  800747:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074b:	89 f2                	mov    %esi,%edx
  80074d:	89 f8                	mov    %edi,%eax
  80074f:	e8 cc fa ff ff       	call   800220 <printnum>
  800754:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800757:	e9 40 fc ff ff       	jmp    80039c <vprintfmt+0x2c>
  80075c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80075f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800762:	89 74 24 04          	mov    %esi,0x4(%esp)
  800766:	89 14 24             	mov    %edx,(%esp)
  800769:	ff d7                	call   *%edi
  80076b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80076e:	e9 29 fc ff ff       	jmp    80039c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800773:	89 74 24 04          	mov    %esi,0x4(%esp)
  800777:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80077e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800780:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800783:	80 38 25             	cmpb   $0x25,(%eax)
  800786:	0f 84 10 fc ff ff    	je     80039c <vprintfmt+0x2c>
  80078c:	89 c3                	mov    %eax,%ebx
  80078e:	eb f0                	jmp    800780 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800790:	83 c4 5c             	add    $0x5c,%esp
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5f                   	pop    %edi
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 28             	sub    $0x28,%esp
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007a4:	85 c0                	test   %eax,%eax
  8007a6:	74 04                	je     8007ac <vsnprintf+0x14>
  8007a8:	85 d2                	test   %edx,%edx
  8007aa:	7f 07                	jg     8007b3 <vsnprintf+0x1b>
  8007ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b1:	eb 3b                	jmp    8007ee <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b6:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d9:	c7 04 24 53 03 80 00 	movl   $0x800353,(%esp)
  8007e0:	e8 8b fb ff ff       	call   800370 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800800:	89 44 24 08          	mov    %eax,0x8(%esp)
  800804:	8b 45 0c             	mov    0xc(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	e8 82 ff ff ff       	call   800798 <vsnprintf>
	va_end(ap);

	return rc;
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80081e:	8d 45 14             	lea    0x14(%ebp),%eax
  800821:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800825:	8b 45 10             	mov    0x10(%ebp),%eax
  800828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	e8 32 fb ff ff       	call   800370 <vprintfmt>
	va_end(ap);
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	80 3a 00             	cmpb   $0x0,(%edx)
  80084e:	74 09                	je     800859 <strlen+0x19>
		n++;
  800850:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800853:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800857:	75 f7                	jne    800850 <strlen+0x10>
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800865:	85 c9                	test   %ecx,%ecx
  800867:	74 19                	je     800882 <strnlen+0x27>
  800869:	80 3b 00             	cmpb   $0x0,(%ebx)
  80086c:	74 14                	je     800882 <strnlen+0x27>
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800873:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800876:	39 c8                	cmp    %ecx,%eax
  800878:	74 0d                	je     800887 <strnlen+0x2c>
  80087a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80087e:	75 f3                	jne    800873 <strnlen+0x18>
  800880:	eb 05                	jmp    800887 <strnlen+0x2c>
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800894:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800899:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	75 f2                	jne    800899 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b8:	85 f6                	test   %esi,%esi
  8008ba:	74 18                	je     8008d4 <strncpy+0x2a>
  8008bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008c1:	0f b6 1a             	movzbl (%edx),%ebx
  8008c4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c7:	80 3a 01             	cmpb   $0x1,(%edx)
  8008ca:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cd:	83 c1 01             	add    $0x1,%ecx
  8008d0:	39 ce                	cmp    %ecx,%esi
  8008d2:	77 ed                	ja     8008c1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e6:	89 f0                	mov    %esi,%eax
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 27                	je     800913 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008ec:	83 e9 01             	sub    $0x1,%ecx
  8008ef:	74 1d                	je     80090e <strlcpy+0x36>
  8008f1:	0f b6 1a             	movzbl (%edx),%ebx
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	74 16                	je     80090e <strlcpy+0x36>
			*dst++ = *src++;
  8008f8:	88 18                	mov    %bl,(%eax)
  8008fa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008fd:	83 e9 01             	sub    $0x1,%ecx
  800900:	74 0e                	je     800910 <strlcpy+0x38>
			*dst++ = *src++;
  800902:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800905:	0f b6 1a             	movzbl (%edx),%ebx
  800908:	84 db                	test   %bl,%bl
  80090a:	75 ec                	jne    8008f8 <strlcpy+0x20>
  80090c:	eb 02                	jmp    800910 <strlcpy+0x38>
  80090e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800910:	c6 00 00             	movb   $0x0,(%eax)
  800913:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800922:	0f b6 01             	movzbl (%ecx),%eax
  800925:	84 c0                	test   %al,%al
  800927:	74 15                	je     80093e <strcmp+0x25>
  800929:	3a 02                	cmp    (%edx),%al
  80092b:	75 11                	jne    80093e <strcmp+0x25>
		p++, q++;
  80092d:	83 c1 01             	add    $0x1,%ecx
  800930:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800933:	0f b6 01             	movzbl (%ecx),%eax
  800936:	84 c0                	test   %al,%al
  800938:	74 04                	je     80093e <strcmp+0x25>
  80093a:	3a 02                	cmp    (%edx),%al
  80093c:	74 ef                	je     80092d <strcmp+0x14>
  80093e:	0f b6 c0             	movzbl %al,%eax
  800941:	0f b6 12             	movzbl (%edx),%edx
  800944:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	53                   	push   %ebx
  80094c:	8b 55 08             	mov    0x8(%ebp),%edx
  80094f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800952:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800955:	85 c0                	test   %eax,%eax
  800957:	74 23                	je     80097c <strncmp+0x34>
  800959:	0f b6 1a             	movzbl (%edx),%ebx
  80095c:	84 db                	test   %bl,%bl
  80095e:	74 24                	je     800984 <strncmp+0x3c>
  800960:	3a 19                	cmp    (%ecx),%bl
  800962:	75 20                	jne    800984 <strncmp+0x3c>
  800964:	83 e8 01             	sub    $0x1,%eax
  800967:	74 13                	je     80097c <strncmp+0x34>
		n--, p++, q++;
  800969:	83 c2 01             	add    $0x1,%edx
  80096c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096f:	0f b6 1a             	movzbl (%edx),%ebx
  800972:	84 db                	test   %bl,%bl
  800974:	74 0e                	je     800984 <strncmp+0x3c>
  800976:	3a 19                	cmp    (%ecx),%bl
  800978:	74 ea                	je     800964 <strncmp+0x1c>
  80097a:	eb 08                	jmp    800984 <strncmp+0x3c>
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800981:	5b                   	pop    %ebx
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800984:	0f b6 02             	movzbl (%edx),%eax
  800987:	0f b6 11             	movzbl (%ecx),%edx
  80098a:	29 d0                	sub    %edx,%eax
  80098c:	eb f3                	jmp    800981 <strncmp+0x39>

0080098e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800998:	0f b6 10             	movzbl (%eax),%edx
  80099b:	84 d2                	test   %dl,%dl
  80099d:	74 15                	je     8009b4 <strchr+0x26>
		if (*s == c)
  80099f:	38 ca                	cmp    %cl,%dl
  8009a1:	75 07                	jne    8009aa <strchr+0x1c>
  8009a3:	eb 14                	jmp    8009b9 <strchr+0x2b>
  8009a5:	38 ca                	cmp    %cl,%dl
  8009a7:	90                   	nop
  8009a8:	74 0f                	je     8009b9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f1                	jne    8009a5 <strchr+0x17>
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c5:	0f b6 10             	movzbl (%eax),%edx
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	74 18                	je     8009e4 <strfind+0x29>
		if (*s == c)
  8009cc:	38 ca                	cmp    %cl,%dl
  8009ce:	75 0a                	jne    8009da <strfind+0x1f>
  8009d0:	eb 12                	jmp    8009e4 <strfind+0x29>
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009d8:	74 0a                	je     8009e4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	75 ee                	jne    8009d2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memset>:


void *
memset(void *v, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009f3:	89 da                	mov    %ebx,%edx
  8009f5:	83 ea 01             	sub    $0x1,%edx
  8009f8:	78 0d                	js     800a07 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  8009fa:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  8009fc:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  8009fe:	88 0a                	mov    %cl,(%edx)
  800a00:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a03:	39 da                	cmp    %ebx,%edx
  800a05:	75 f7                	jne    8009fe <memset+0x18>
		*p++ = c;

	return v;
}
  800a07:	5b                   	pop    %ebx
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	74 13                	je     800a2f <memcpy+0x25>
  800a1c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800a21:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a25:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a28:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a2b:	39 da                	cmp    %ebx,%edx
  800a2d:	75 f2                	jne    800a21 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800a42:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800a44:	39 c6                	cmp    %eax,%esi
  800a46:	72 0b                	jb     800a53 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800a4d:	85 db                	test   %ebx,%ebx
  800a4f:	75 2e                	jne    800a7f <memmove+0x4c>
  800a51:	eb 3a                	jmp    800a8d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a53:	01 df                	add    %ebx,%edi
  800a55:	39 f8                	cmp    %edi,%eax
  800a57:	73 ef                	jae    800a48 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	90                   	nop
  800a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a60:	74 2b                	je     800a8d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a62:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800a6a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800a6f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800a73:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a76:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	75 ed                	jne    800a6a <memmove+0x37>
  800a7d:	eb 0e                	jmp    800a8d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a7f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a83:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a86:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a89:	39 d3                	cmp    %edx,%ebx
  800a8b:	75 f2                	jne    800a7f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa1:	85 c9                	test   %ecx,%ecx
  800aa3:	74 36                	je     800adb <memcmp+0x49>
		if (*s1 != *s2)
  800aa5:	0f b6 06             	movzbl (%esi),%eax
  800aa8:	0f b6 1f             	movzbl (%edi),%ebx
  800aab:	38 d8                	cmp    %bl,%al
  800aad:	74 20                	je     800acf <memcmp+0x3d>
  800aaf:	eb 14                	jmp    800ac5 <memcmp+0x33>
  800ab1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ab6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800abb:	83 c2 01             	add    $0x1,%edx
  800abe:	83 e9 01             	sub    $0x1,%ecx
  800ac1:	38 d8                	cmp    %bl,%al
  800ac3:	74 12                	je     800ad7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ac5:	0f b6 c0             	movzbl %al,%eax
  800ac8:	0f b6 db             	movzbl %bl,%ebx
  800acb:	29 d8                	sub    %ebx,%eax
  800acd:	eb 11                	jmp    800ae0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	83 e9 01             	sub    $0x1,%ecx
  800ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad7:	85 c9                	test   %ecx,%ecx
  800ad9:	75 d6                	jne    800ab1 <memcmp+0x1f>
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aeb:	89 c2                	mov    %eax,%edx
  800aed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af0:	39 d0                	cmp    %edx,%eax
  800af2:	73 15                	jae    800b09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800af8:	38 08                	cmp    %cl,(%eax)
  800afa:	75 06                	jne    800b02 <memfind+0x1d>
  800afc:	eb 0b                	jmp    800b09 <memfind+0x24>
  800afe:	38 08                	cmp    %cl,(%eax)
  800b00:	74 07                	je     800b09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	39 c2                	cmp    %eax,%edx
  800b07:	77 f5                	ja     800afe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	83 ec 04             	sub    $0x4,%esp
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1a:	0f b6 02             	movzbl (%edx),%eax
  800b1d:	3c 20                	cmp    $0x20,%al
  800b1f:	74 04                	je     800b25 <strtol+0x1a>
  800b21:	3c 09                	cmp    $0x9,%al
  800b23:	75 0e                	jne    800b33 <strtol+0x28>
		s++;
  800b25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b28:	0f b6 02             	movzbl (%edx),%eax
  800b2b:	3c 20                	cmp    $0x20,%al
  800b2d:	74 f6                	je     800b25 <strtol+0x1a>
  800b2f:	3c 09                	cmp    $0x9,%al
  800b31:	74 f2                	je     800b25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b33:	3c 2b                	cmp    $0x2b,%al
  800b35:	75 0c                	jne    800b43 <strtol+0x38>
		s++;
  800b37:	83 c2 01             	add    $0x1,%edx
  800b3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b41:	eb 15                	jmp    800b58 <strtol+0x4d>
	else if (*s == '-')
  800b43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b4a:	3c 2d                	cmp    $0x2d,%al
  800b4c:	75 0a                	jne    800b58 <strtol+0x4d>
		s++, neg = 1;
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	85 db                	test   %ebx,%ebx
  800b5a:	0f 94 c0             	sete   %al
  800b5d:	74 05                	je     800b64 <strtol+0x59>
  800b5f:	83 fb 10             	cmp    $0x10,%ebx
  800b62:	75 18                	jne    800b7c <strtol+0x71>
  800b64:	80 3a 30             	cmpb   $0x30,(%edx)
  800b67:	75 13                	jne    800b7c <strtol+0x71>
  800b69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6d:	8d 76 00             	lea    0x0(%esi),%esi
  800b70:	75 0a                	jne    800b7c <strtol+0x71>
		s += 2, base = 16;
  800b72:	83 c2 02             	add    $0x2,%edx
  800b75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7a:	eb 15                	jmp    800b91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7c:	84 c0                	test   %al,%al
  800b7e:	66 90                	xchg   %ax,%ax
  800b80:	74 0f                	je     800b91 <strtol+0x86>
  800b82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b87:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8a:	75 05                	jne    800b91 <strtol+0x86>
		s++, base = 8;
  800b8c:	83 c2 01             	add    $0x1,%edx
  800b8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b98:	0f b6 0a             	movzbl (%edx),%ecx
  800b9b:	89 cf                	mov    %ecx,%edi
  800b9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba0:	80 fb 09             	cmp    $0x9,%bl
  800ba3:	77 08                	ja     800bad <strtol+0xa2>
			dig = *s - '0';
  800ba5:	0f be c9             	movsbl %cl,%ecx
  800ba8:	83 e9 30             	sub    $0x30,%ecx
  800bab:	eb 1e                	jmp    800bcb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bb0:	80 fb 19             	cmp    $0x19,%bl
  800bb3:	77 08                	ja     800bbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bb5:	0f be c9             	movsbl %cl,%ecx
  800bb8:	83 e9 57             	sub    $0x57,%ecx
  800bbb:	eb 0e                	jmp    800bcb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 15                	ja     800bda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bc5:	0f be c9             	movsbl %cl,%ecx
  800bc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcb:	39 f1                	cmp    %esi,%ecx
  800bcd:	7d 0b                	jge    800bda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	0f af c6             	imul   %esi,%eax
  800bd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bd8:	eb be                	jmp    800b98 <strtol+0x8d>
  800bda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be0:	74 05                	je     800be7 <strtol+0xdc>
		*endptr = (char *) s;
  800be2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be7:	89 ca                	mov    %ecx,%edx
  800be9:	f7 da                	neg    %edx
  800beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bef:	0f 45 c2             	cmovne %edx,%eax
}
  800bf2:	83 c4 04             	add    $0x4,%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
	...

00800bfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	89 1c 24             	mov    %ebx,(%esp)
  800c05:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c09:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 c3                	mov    %eax,%ebx
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	89 c6                	mov    %eax,%esi
  800c1e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800c20:	8b 1c 24             	mov    (%esp),%ebx
  800c23:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c27:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c2b:	89 ec                	mov    %ebp,%esp
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	89 1c 24             	mov    %ebx,(%esp)
  800c38:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c3c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
  800c45:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4a:	89 d1                	mov    %edx,%ecx
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800c54:	8b 1c 24             	mov    (%esp),%ebx
  800c57:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c5b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c5f:	89 ec                	mov    %ebp,%esp
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	89 1c 24             	mov    %ebx,(%esp)
  800c6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c70:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c79:	b8 03 00 00 00       	mov    $0x3,%eax
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 cb                	mov    %ecx,%ebx
  800c83:	89 cf                	mov    %ecx,%edi
  800c85:	89 ce                	mov    %ecx,%esi
  800c87:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800c89:	8b 1c 24             	mov    (%esp),%ebx
  800c8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c90:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c94:	89 ec                	mov    %ebp,%esp
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	89 1c 24             	mov    %ebx,(%esp)
  800ca1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800cbd:	8b 1c 24             	mov    (%esp),%ebx
  800cc0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_yield>:

void
sys_yield(void)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	89 1c 24             	mov    %ebx,(%esp)
  800cd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce7:	89 d1                	mov    %edx,%ecx
  800ce9:	89 d3                	mov    %edx,%ebx
  800ceb:	89 d7                	mov    %edx,%edi
  800ced:	89 d6                	mov    %edx,%esi
  800cef:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800cf1:	8b 1c 24             	mov    (%esp),%ebx
  800cf4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cf8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cfc:	89 ec                	mov    %ebp,%esp
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	89 1c 24             	mov    %ebx,(%esp)
  800d09:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d0d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	be 00 00 00 00       	mov    $0x0,%esi
  800d16:	b8 04 00 00 00       	mov    $0x4,%eax
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 f7                	mov    %esi,%edi
  800d26:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800d28:	8b 1c 24             	mov    (%esp),%ebx
  800d2b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d2f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d33:	89 ec                	mov    %ebp,%esp
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	89 1c 24             	mov    %ebx,(%esp)
  800d40:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d44:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	b8 05 00 00 00       	mov    $0x5,%eax
  800d4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5e:	8b 1c 24             	mov    (%esp),%ebx
  800d61:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d65:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d69:	89 ec                	mov    %ebp,%esp
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	89 1c 24             	mov    %ebx,(%esp)
  800d76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d83:	b8 06 00 00 00       	mov    $0x6,%eax
  800d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8e:	89 df                	mov    %ebx,%edi
  800d90:	89 de                	mov    %ebx,%esi
  800d92:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800d94:	8b 1c 24             	mov    (%esp),%ebx
  800d97:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d9b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d9f:	89 ec                	mov    %ebp,%esp
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	89 1c 24             	mov    %ebx,(%esp)
  800dac:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 df                	mov    %ebx,%edi
  800dc6:	89 de                	mov    %ebx,%esi
  800dc8:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800dca:	8b 1c 24             	mov    (%esp),%ebx
  800dcd:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dd5:	89 ec                	mov    %ebp,%esp
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	89 1c 24             	mov    %ebx,(%esp)
  800de2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800de6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800def:	b8 09 00 00 00       	mov    $0x9,%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 df                	mov    %ebx,%edi
  800dfc:	89 de                	mov    %ebx,%esi
  800dfe:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800e00:	8b 1c 24             	mov    (%esp),%ebx
  800e03:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e07:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e0b:	89 ec                	mov    %ebp,%esp
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 0c             	sub    $0xc,%esp
  800e15:	89 1c 24             	mov    %ebx,(%esp)
  800e18:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e1c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	89 df                	mov    %ebx,%edi
  800e32:	89 de                	mov    %ebx,%esi
  800e34:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e36:	8b 1c 24             	mov    (%esp),%ebx
  800e39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e41:	89 ec                	mov    %ebp,%esp
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	89 1c 24             	mov    %ebx,(%esp)
  800e4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e52:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	be 00 00 00 00       	mov    $0x0,%esi
  800e5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6e:	8b 1c 24             	mov    (%esp),%ebx
  800e71:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e75:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e79:	89 ec                	mov    %ebp,%esp
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	89 1c 24             	mov    %ebx,(%esp)
  800e86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e93:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	89 cb                	mov    %ecx,%ebx
  800e9d:	89 cf                	mov    %ecx,%edi
  800e9f:	89 ce                	mov    %ecx,%esi
  800ea1:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800ea3:	8b 1c 24             	mov    (%esp),%ebx
  800ea6:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eaa:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800eae:	89 ec                	mov    %ebp,%esp
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
	...

00800eb4 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800eba:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  800ec9:	00 
  800eca:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  800ed1:	e8 6e 04 00 00       	call   801344 <_panic>

00800ed6 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr;
	pte_t pte;

	// LAB 4: Your code here.
	addr = (void *) ((uint32_t) pn * PGSIZE);
  800edd:	89 d3                	mov    %edx,%ebx
  800edf:	c1 e3 0c             	shl    $0xc,%ebx
	pte = vpt[VPN(addr)];
  800ee2:	89 da                	mov    %ebx,%edx
  800ee4:	c1 ea 0c             	shr    $0xc,%edx
  800ee7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((pte & PTE_W) > 0 || (pte & PTE_COW) > 0) 
  800eee:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ef4:	0f 84 8c 00 00 00    	je     800f86 <duppage+0xb0>
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800efa:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800f01:	00 
  800f02:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f06:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f15:	e8 1d fe ff ff       	call   800d37 <sys_page_map>
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	79 20                	jns    800f3e <duppage+0x68>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  800f1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f22:	c7 44 24 08 bc 19 80 	movl   $0x8019bc,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  800f39:	e8 06 04 00 00       	call   801344 <_panic>
	
		if ((r = sys_page_map (0, addr, 0, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800f3e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800f45:	00 
  800f46:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f51:	00 
  800f52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5d:	e8 d5 fd ff ff       	call   800d37 <sys_page_map>
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 64                	jns    800fca <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  800f66:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6a:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  800f71:	00 
  800f72:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  800f79:	00 
  800f7a:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  800f81:	e8 be 03 00 00       	call   801344 <_panic>
	} 
	else 
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800f86:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  800f8d:	00 
  800f8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa1:	e8 91 fd ff ff       	call   800d37 <sys_page_map>
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 20                	jns    800fca <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  800faa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fae:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800fb5:	00 
  800fb6:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800fbd:	00 
  800fbe:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  800fc5:	e8 7a 03 00 00       	call   801344 <_panic>
	}	
	//panic("duppage not implemented");
	return 0;
}
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcf:	83 c4 24             	add    $0x24,%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 24             	sub    $0x24,%esp
	// LAB 4: Your code here.
	envid_t envid;  
	uint8_t *addr;  
	int r;  
	extern unsigned char end[];  
	set_pgfault_handler(pgfault);  
  800fdc:	c7 04 24 0a 11 80 00 	movl   $0x80110a,(%esp)
  800fe3:	e8 c0 03 00 00       	call   8013a8 <set_pgfault_handler>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fe8:	bb 07 00 00 00       	mov    $0x7,%ebx
  800fed:	89 d8                	mov    %ebx,%eax
  800fef:	cd 30                	int    $0x30
  800ff1:	89 c3                	mov    %eax,%ebx
	envid = sys_exofork();  
	if (envid < 0)  
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	79 20                	jns    801017 <fork+0x42>
		panic("sys_exofork: %e", envid);  
  800ff7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ffb:	c7 44 24 08 65 19 80 	movl   $0x801965,0x8(%esp)
  801002:	00 
  801003:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  80100a:	00 
  80100b:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  801012:	e8 2d 03 00 00       	call   801344 <_panic>
	//child  
	if (envid == 0) {  
  801017:	85 c0                	test   %eax,%eax
  801019:	75 20                	jne    80103b <fork+0x66>
		//can't set pgh here ,must before child run  
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
  80101b:	e8 78 fc ff ff       	call   800c98 <sys_getenvid>
  801020:	25 ff 03 00 00       	and    $0x3ff,%eax
  801025:	89 c2                	mov    %eax,%edx
  801027:	c1 e2 07             	shl    $0x7,%edx
  80102a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801031:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;  
  801036:	e9 c7 00 00 00       	jmp    801102 <fork+0x12d>
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  80103b:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  801042:	b8 10 20 80 00       	mov    $0x802010,%eax
  801047:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80104c:	76 23                	jbe    801071 <fork+0x9c>
  80104e:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, VPN(addr));  
  801053:	c1 ea 0c             	shr    $0xc,%edx
  801056:	89 d8                	mov    %ebx,%eax
  801058:	e8 79 fe ff ff       	call   800ed6 <duppage>
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
		return 0;  
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  80105d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801060:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801066:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801069:	81 fa 10 20 80 00    	cmp    $0x802010,%edx
  80106f:	72 e2                	jb     801053 <fork+0x7e>
		duppage(envid, VPN(addr));  
	duppage(envid, VPN(&addr));  
  801071:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801074:	c1 ea 0c             	shr    $0xc,%edx
  801077:	89 d8                	mov    %ebx,%eax
  801079:	e8 58 fe ff ff       	call   800ed6 <duppage>
	//copy user exception stack  

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)  
  80107e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801085:	00 
  801086:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80108d:	ee 
  80108e:	89 1c 24             	mov    %ebx,(%esp)
  801091:	e8 6a fc ff ff       	call   800d00 <sys_page_alloc>
  801096:	85 c0                	test   %eax,%eax
  801098:	79 20                	jns    8010ba <fork+0xe5>
		panic("sys_page_alloc: %e", r);  
  80109a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109e:	c7 44 24 08 75 19 80 	movl   $0x801975,0x8(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8010ad:	00 
  8010ae:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  8010b5:	e8 8a 02 00 00       	call   801344 <_panic>
	r = sys_env_set_pgfault_upcall(envid, env->env_pgfault_upcall);  
  8010ba:	a1 04 20 80 00       	mov    0x802004,%eax
  8010bf:	8b 40 64             	mov    0x64(%eax),%eax
  8010c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c6:	89 1c 24             	mov    %ebx,(%esp)
  8010c9:	e8 41 fd ff ff       	call   800e0f <sys_env_set_pgfault_upcall>

	//set child status  

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)  
  8010ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d5:	00 
  8010d6:	89 1c 24             	mov    %ebx,(%esp)
  8010d9:	e8 c5 fc ff ff       	call   800da3 <sys_env_set_status>
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 20                	jns    801102 <fork+0x12d>
		panic("sys_env_set_status: %e", r);  
  8010e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e6:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  8010ed:	00 
  8010ee:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8010f5:	00 
  8010f6:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  8010fd:	e8 42 02 00 00       	call   801344 <_panic>
	return envid;  
	//panic("fork not implemented");
}
  801102:	89 d8                	mov    %ebx,%eax
  801104:	83 c4 24             	add    $0x24,%esp
  801107:	5b                   	pop    %ebx
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	53                   	push   %ebx
  80110e:	83 ec 24             	sub    $0x24,%esp
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801114:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801116:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80111a:	75 1c                	jne    801138 <pgfault+0x2e>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!(err&FEC_WR))   
		panic("Page fault: not a write access.");  
  80111c:	c7 44 24 08 40 1a 80 	movl   $0x801a40,0x8(%esp)
  801123:	00 
  801124:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80112b:	00 
  80112c:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  801133:	e8 0c 02 00 00       	call   801344 <_panic>
	
	if ( !(vpt[VPN(addr)]&PTE_COW) )  
  801138:	89 d8                	mov    %ebx,%eax
  80113a:	c1 e8 0c             	shr    $0xc,%eax
  80113d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801144:	f6 c4 08             	test   $0x8,%ah
  801147:	75 1c                	jne    801165 <pgfault+0x5b>
		panic("Page fualt: not a COW page.");  
  801149:	c7 44 24 08 9f 19 80 	movl   $0x80199f,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  801160:	e8 df 01 00 00       	call   801344 <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	
	// LAB 4: Your code here.
	
	if ((r=sys_page_alloc(0, PFTEMP, PTE_U|PTE_W|PTE_P)) <0)  
  801165:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80116c:	00 
  80116d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801174:	00 
  801175:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117c:	e8 7f fb ff ff       	call   800d00 <sys_page_alloc>
  801181:	85 c0                	test   %eax,%eax
  801183:	79 20                	jns    8011a5 <pgfault+0x9b>
		panic("Page fault: sys_page_alloc err %e.", r);  
  801185:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801189:	c7 44 24 08 60 1a 80 	movl   $0x801a60,0x8(%esp)
  801190:	00 
  801191:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  8011a0:	e8 9f 01 00 00       	call   801344 <_panic>
	
	memmove(PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);  
  8011a5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8011ab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011b2:	00 
  8011b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b7:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011be:	e8 70 f8 ff ff       	call   800a33 <memmove>
	
	
	if ((r=sys_page_map(0, PFTEMP, 0, (void *)PTE_ADDR(addr), PTE_U|PTE_W|PTE_P))<0)  
  8011c3:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011ca:	00 
  8011cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d6:	00 
  8011d7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011de:	00 
  8011df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e6:	e8 4c fb ff ff       	call   800d37 <sys_page_map>
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	79 20                	jns    80120f <pgfault+0x105>
		panic("Page fault: sys_page_map err %e.", r);  
  8011ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f3:	c7 44 24 08 84 1a 80 	movl   $0x801a84,0x8(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801202:	00 
  801203:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  80120a:	e8 35 01 00 00       	call   801344 <_panic>
	if ((r=sys_page_unmap(0, PFTEMP))<0)  
  80120f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801216:	00 
  801217:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121e:	e8 4a fb ff ff       	call   800d6d <sys_page_unmap>
  801223:	85 c0                	test   %eax,%eax
  801225:	79 20                	jns    801247 <pgfault+0x13d>
		panic("Page fault: sys_page_unmap err %e.", r);  
  801227:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122b:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  801232:	00 
  801233:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  80123a:	00 
  80123b:	c7 04 24 5a 19 80 00 	movl   $0x80195a,(%esp)
  801242:	e8 fd 00 00 00       	call   801344 <_panic>
	
	//panic("pgfault not implemented");
}
  801247:	83 c4 24             	add    $0x24,%esp
  80124a:	5b                   	pop    %ebx
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    
  80124d:	00 00                	add    %al,(%eax)
	...

00801250 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 1c             	sub    $0x1c,%esp
  801259:	8b 75 08             	mov    0x8(%ebp),%esi
  80125c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80125f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");

	int r;
	while ((r = sys_ipc_try_send (to_env, val, pg != NULL ? pg : (void *) UTOP, perm)) < 0) 
  801262:	eb 2a                	jmp    80128e <ipc_send+0x3e>
	{
		//cprintf("bug is not in sys_ipc_try_send\n");		//for debug
		if (r != -E_IPC_NOT_RECV)
  801264:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801267:	74 20                	je     801289 <ipc_send+0x39>
			panic ("ipc_send: send message error %e", r);
  801269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80126d:	c7 44 24 08 cc 1a 80 	movl   $0x801acc,0x8(%esp)
  801274:	00 
  801275:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80127c:	00 
  80127d:	c7 04 24 ec 1a 80 00 	movl   $0x801aec,(%esp)
  801284:	e8 bb 00 00 00       	call   801344 <_panic>
		sys_yield ();
  801289:	e8 3e fa ff ff       	call   800ccc <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");

	int r;
	while ((r = sys_ipc_try_send (to_env, val, pg != NULL ? pg : (void *) UTOP, perm)) < 0) 
  80128e:	85 db                	test   %ebx,%ebx
  801290:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801295:	0f 45 c3             	cmovne %ebx,%eax
  801298:	8b 55 14             	mov    0x14(%ebp),%edx
  80129b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80129f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012a7:	89 34 24             	mov    %esi,(%esp)
  8012aa:	e8 96 fb ff ff       	call   800e45 <sys_ipc_try_send>
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 b1                	js     801264 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic ("ipc_send: send message error %e", r);
		sys_yield ();
	}

}
  8012b3:	83 c4 1c             	add    $0x1c,%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
uint32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	83 ec 28             	sub    $0x28,%esp
  8012c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8012cd:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	
	int r;
	if (pg != NULL)
  8012d0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012d4:	74 10                	je     8012e6 <ipc_recv+0x2b>
	    r = sys_ipc_recv ((void *) UTOP);
  8012d6:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8012dd:	e8 9b fb ff ff       	call   800e7d <sys_ipc_recv>
  8012e2:	89 c3                	mov    %eax,%ebx
  8012e4:	eb 0e                	jmp    8012f4 <ipc_recv+0x39>
	else
	    r = sys_ipc_recv (pg);
  8012e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ed:	e8 8b fb ff ff       	call   800e7d <sys_ipc_recv>
  8012f2:	89 c3                	mov    %eax,%ebx
	struct Env *curenv = (struct Env *) envs + ENVX (sys_getenvid ());
  8012f4:	e8 9f f9 ff ff       	call   800c98 <sys_getenvid>
  8012f9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	c1 e2 07             	shl    $0x7,%edx
  801303:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
	if (from_env_store != NULL)
  80130a:	85 f6                	test   %esi,%esi
  80130c:	74 0e                	je     80131c <ipc_recv+0x61>
		*from_env_store = r < 0 ? 0 : curenv->env_ipc_from;
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
  801313:	85 db                	test   %ebx,%ebx
  801315:	78 03                	js     80131a <ipc_recv+0x5f>
  801317:	8b 42 74             	mov    0x74(%edx),%eax
  80131a:	89 06                	mov    %eax,(%esi)
	if (perm_store != NULL)
  80131c:	85 ff                	test   %edi,%edi
  80131e:	74 0e                	je     80132e <ipc_recv+0x73>
		*perm_store = r < 0 ? 0 : curenv->env_ipc_perm;
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
  801325:	85 db                	test   %ebx,%ebx
  801327:	78 03                	js     80132c <ipc_recv+0x71>
  801329:	8b 42 78             	mov    0x78(%edx),%eax
  80132c:	89 07                	mov    %eax,(%edi)
	if (r < 0)
		return r;
  80132e:	89 d8                	mov    %ebx,%eax
	struct Env *curenv = (struct Env *) envs + ENVX (sys_getenvid ());
	if (from_env_store != NULL)
		*from_env_store = r < 0 ? 0 : curenv->env_ipc_from;
	if (perm_store != NULL)
		*perm_store = r < 0 ? 0 : curenv->env_ipc_perm;
	if (r < 0)
  801330:	85 db                	test   %ebx,%ebx
  801332:	78 03                	js     801337 <ipc_recv+0x7c>
		return r;
	return curenv->env_ipc_value;
  801334:	8b 42 70             	mov    0x70(%edx),%eax
}
  801337:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80133a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80133d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801340:	89 ec                	mov    %ebp,%esp
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80134a:	a1 08 20 80 00       	mov    0x802008,%eax
  80134f:	85 c0                	test   %eax,%eax
  801351:	74 10                	je     801363 <_panic+0x1f>
		cprintf("%s: ", argv0);
  801353:	89 44 24 04          	mov    %eax,0x4(%esp)
  801357:	c7 04 24 f6 1a 80 00 	movl   $0x801af6,(%esp)
  80135e:	e8 5e ee ff ff       	call   8001c1 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  801363:	8b 45 0c             	mov    0xc(%ebp),%eax
  801366:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80136a:	8b 45 08             	mov    0x8(%ebp),%eax
  80136d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801371:	a1 00 20 80 00       	mov    0x802000,%eax
  801376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137a:	c7 04 24 fb 1a 80 00 	movl   $0x801afb,(%esp)
  801381:	e8 3b ee ff ff       	call   8001c1 <cprintf>
	vcprintf(fmt, ap);
  801386:	8d 45 14             	lea    0x14(%ebp),%eax
  801389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138d:	8b 45 10             	mov    0x10(%ebp),%eax
  801390:	89 04 24             	mov    %eax,(%esp)
  801393:	e8 c8 ed ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801398:	c7 04 24 e7 16 80 00 	movl   $0x8016e7,(%esp)
  80139f:	e8 1d ee ff ff       	call   8001c1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013a4:	cc                   	int3   
  8013a5:	eb fd                	jmp    8013a4 <_panic+0x60>
	...

008013a8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013ae:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8013b5:	75 54                	jne    80140b <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8013b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013be:	00 
  8013bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013c6:	ee 
  8013c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ce:	e8 2d f9 ff ff       	call   800d00 <sys_page_alloc>
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	79 20                	jns    8013f7 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8013d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013db:	c7 44 24 08 17 1b 80 	movl   $0x801b17,0x8(%esp)
  8013e2:	00 
  8013e3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8013ea:	00 
  8013eb:	c7 04 24 2f 1b 80 00 	movl   $0x801b2f,(%esp)
  8013f2:	e8 4d ff ff ff       	call   801344 <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8013f7:	c7 44 24 04 18 14 80 	movl   $0x801418,0x4(%esp)
  8013fe:	00 
  8013ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801406:	e8 04 fa ff ff       	call   800e0f <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80140b:	8b 45 08             	mov    0x8(%ebp),%eax
  80140e:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801413:	c9                   	leave  
  801414:	c3                   	ret    
  801415:	00 00                	add    %al,(%eax)
	...

00801418 <_pgfault_upcall>:
  801418:	54                   	push   %esp
  801419:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80141e:	ff d0                	call   *%eax
  801420:	83 c4 04             	add    $0x4,%esp
  801423:	8b 44 24 30          	mov    0x30(%esp),%eax
  801427:	83 e8 04             	sub    $0x4,%eax
  80142a:	89 44 24 30          	mov    %eax,0x30(%esp)
  80142e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  801432:	89 18                	mov    %ebx,(%eax)
  801434:	83 c4 08             	add    $0x8,%esp
  801437:	61                   	popa   
  801438:	83 c4 04             	add    $0x4,%esp
  80143b:	9d                   	popf   
  80143c:	5c                   	pop    %esp
  80143d:	c3                   	ret    
	...

00801440 <__udivdi3>:
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	83 ec 10             	sub    $0x10,%esp
  801448:	8b 45 14             	mov    0x14(%ebp),%eax
  80144b:	8b 55 08             	mov    0x8(%ebp),%edx
  80144e:	8b 75 10             	mov    0x10(%ebp),%esi
  801451:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801454:	85 c0                	test   %eax,%eax
  801456:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801459:	75 35                	jne    801490 <__udivdi3+0x50>
  80145b:	39 fe                	cmp    %edi,%esi
  80145d:	77 61                	ja     8014c0 <__udivdi3+0x80>
  80145f:	85 f6                	test   %esi,%esi
  801461:	75 0b                	jne    80146e <__udivdi3+0x2e>
  801463:	b8 01 00 00 00       	mov    $0x1,%eax
  801468:	31 d2                	xor    %edx,%edx
  80146a:	f7 f6                	div    %esi
  80146c:	89 c6                	mov    %eax,%esi
  80146e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801471:	31 d2                	xor    %edx,%edx
  801473:	89 f8                	mov    %edi,%eax
  801475:	f7 f6                	div    %esi
  801477:	89 c7                	mov    %eax,%edi
  801479:	89 c8                	mov    %ecx,%eax
  80147b:	f7 f6                	div    %esi
  80147d:	89 c1                	mov    %eax,%ecx
  80147f:	89 fa                	mov    %edi,%edx
  801481:	89 c8                	mov    %ecx,%eax
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	5e                   	pop    %esi
  801487:	5f                   	pop    %edi
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    
  80148a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801490:	39 f8                	cmp    %edi,%eax
  801492:	77 1c                	ja     8014b0 <__udivdi3+0x70>
  801494:	0f bd d0             	bsr    %eax,%edx
  801497:	83 f2 1f             	xor    $0x1f,%edx
  80149a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80149d:	75 39                	jne    8014d8 <__udivdi3+0x98>
  80149f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8014a2:	0f 86 a0 00 00 00    	jbe    801548 <__udivdi3+0x108>
  8014a8:	39 f8                	cmp    %edi,%eax
  8014aa:	0f 82 98 00 00 00    	jb     801548 <__udivdi3+0x108>
  8014b0:	31 ff                	xor    %edi,%edi
  8014b2:	31 c9                	xor    %ecx,%ecx
  8014b4:	89 c8                	mov    %ecx,%eax
  8014b6:	89 fa                	mov    %edi,%edx
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    
  8014bf:	90                   	nop
  8014c0:	89 d1                	mov    %edx,%ecx
  8014c2:	89 fa                	mov    %edi,%edx
  8014c4:	89 c8                	mov    %ecx,%eax
  8014c6:	31 ff                	xor    %edi,%edi
  8014c8:	f7 f6                	div    %esi
  8014ca:	89 c1                	mov    %eax,%ecx
  8014cc:	89 fa                	mov    %edi,%edx
  8014ce:	89 c8                	mov    %ecx,%eax
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	5e                   	pop    %esi
  8014d4:	5f                   	pop    %edi
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    
  8014d7:	90                   	nop
  8014d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014dc:	89 f2                	mov    %esi,%edx
  8014de:	d3 e0                	shl    %cl,%eax
  8014e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8014e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8014e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8014eb:	89 c1                	mov    %eax,%ecx
  8014ed:	d3 ea                	shr    %cl,%edx
  8014ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8014f6:	d3 e6                	shl    %cl,%esi
  8014f8:	89 c1                	mov    %eax,%ecx
  8014fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8014fd:	89 fe                	mov    %edi,%esi
  8014ff:	d3 ee                	shr    %cl,%esi
  801501:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801505:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801508:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80150b:	d3 e7                	shl    %cl,%edi
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	d3 ea                	shr    %cl,%edx
  801511:	09 d7                	or     %edx,%edi
  801513:	89 f2                	mov    %esi,%edx
  801515:	89 f8                	mov    %edi,%eax
  801517:	f7 75 ec             	divl   -0x14(%ebp)
  80151a:	89 d6                	mov    %edx,%esi
  80151c:	89 c7                	mov    %eax,%edi
  80151e:	f7 65 e8             	mull   -0x18(%ebp)
  801521:	39 d6                	cmp    %edx,%esi
  801523:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801526:	72 30                	jb     801558 <__udivdi3+0x118>
  801528:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80152f:	d3 e2                	shl    %cl,%edx
  801531:	39 c2                	cmp    %eax,%edx
  801533:	73 05                	jae    80153a <__udivdi3+0xfa>
  801535:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801538:	74 1e                	je     801558 <__udivdi3+0x118>
  80153a:	89 f9                	mov    %edi,%ecx
  80153c:	31 ff                	xor    %edi,%edi
  80153e:	e9 71 ff ff ff       	jmp    8014b4 <__udivdi3+0x74>
  801543:	90                   	nop
  801544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801548:	31 ff                	xor    %edi,%edi
  80154a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80154f:	e9 60 ff ff ff       	jmp    8014b4 <__udivdi3+0x74>
  801554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801558:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80155b:	31 ff                	xor    %edi,%edi
  80155d:	89 c8                	mov    %ecx,%eax
  80155f:	89 fa                	mov    %edi,%edx
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    
	...

00801570 <__umoddi3>:
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	57                   	push   %edi
  801574:	56                   	push   %esi
  801575:	83 ec 20             	sub    $0x20,%esp
  801578:	8b 55 14             	mov    0x14(%ebp),%edx
  80157b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80157e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801581:	8b 75 0c             	mov    0xc(%ebp),%esi
  801584:	85 d2                	test   %edx,%edx
  801586:	89 c8                	mov    %ecx,%eax
  801588:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80158b:	75 13                	jne    8015a0 <__umoddi3+0x30>
  80158d:	39 f7                	cmp    %esi,%edi
  80158f:	76 3f                	jbe    8015d0 <__umoddi3+0x60>
  801591:	89 f2                	mov    %esi,%edx
  801593:	f7 f7                	div    %edi
  801595:	89 d0                	mov    %edx,%eax
  801597:	31 d2                	xor    %edx,%edx
  801599:	83 c4 20             	add    $0x20,%esp
  80159c:	5e                   	pop    %esi
  80159d:	5f                   	pop    %edi
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    
  8015a0:	39 f2                	cmp    %esi,%edx
  8015a2:	77 4c                	ja     8015f0 <__umoddi3+0x80>
  8015a4:	0f bd ca             	bsr    %edx,%ecx
  8015a7:	83 f1 1f             	xor    $0x1f,%ecx
  8015aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015ad:	75 51                	jne    801600 <__umoddi3+0x90>
  8015af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8015b2:	0f 87 e0 00 00 00    	ja     801698 <__umoddi3+0x128>
  8015b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bb:	29 f8                	sub    %edi,%eax
  8015bd:	19 d6                	sbb    %edx,%esi
  8015bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c5:	89 f2                	mov    %esi,%edx
  8015c7:	83 c4 20             	add    $0x20,%esp
  8015ca:	5e                   	pop    %esi
  8015cb:	5f                   	pop    %edi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    
  8015ce:	66 90                	xchg   %ax,%ax
  8015d0:	85 ff                	test   %edi,%edi
  8015d2:	75 0b                	jne    8015df <__umoddi3+0x6f>
  8015d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d9:	31 d2                	xor    %edx,%edx
  8015db:	f7 f7                	div    %edi
  8015dd:	89 c7                	mov    %eax,%edi
  8015df:	89 f0                	mov    %esi,%eax
  8015e1:	31 d2                	xor    %edx,%edx
  8015e3:	f7 f7                	div    %edi
  8015e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e8:	f7 f7                	div    %edi
  8015ea:	eb a9                	jmp    801595 <__umoddi3+0x25>
  8015ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015f0:	89 c8                	mov    %ecx,%eax
  8015f2:	89 f2                	mov    %esi,%edx
  8015f4:	83 c4 20             	add    $0x20,%esp
  8015f7:	5e                   	pop    %esi
  8015f8:	5f                   	pop    %edi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    
  8015fb:	90                   	nop
  8015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801600:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801604:	d3 e2                	shl    %cl,%edx
  801606:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801609:	ba 20 00 00 00       	mov    $0x20,%edx
  80160e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801611:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801614:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801618:	89 fa                	mov    %edi,%edx
  80161a:	d3 ea                	shr    %cl,%edx
  80161c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801620:	0b 55 f4             	or     -0xc(%ebp),%edx
  801623:	d3 e7                	shl    %cl,%edi
  801625:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801629:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80162c:	89 f2                	mov    %esi,%edx
  80162e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801631:	89 c7                	mov    %eax,%edi
  801633:	d3 ea                	shr    %cl,%edx
  801635:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801639:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	d3 e6                	shl    %cl,%esi
  801640:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801644:	d3 ea                	shr    %cl,%edx
  801646:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80164a:	09 d6                	or     %edx,%esi
  80164c:	89 f0                	mov    %esi,%eax
  80164e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801651:	d3 e7                	shl    %cl,%edi
  801653:	89 f2                	mov    %esi,%edx
  801655:	f7 75 f4             	divl   -0xc(%ebp)
  801658:	89 d6                	mov    %edx,%esi
  80165a:	f7 65 e8             	mull   -0x18(%ebp)
  80165d:	39 d6                	cmp    %edx,%esi
  80165f:	72 2b                	jb     80168c <__umoddi3+0x11c>
  801661:	39 c7                	cmp    %eax,%edi
  801663:	72 23                	jb     801688 <__umoddi3+0x118>
  801665:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801669:	29 c7                	sub    %eax,%edi
  80166b:	19 d6                	sbb    %edx,%esi
  80166d:	89 f0                	mov    %esi,%eax
  80166f:	89 f2                	mov    %esi,%edx
  801671:	d3 ef                	shr    %cl,%edi
  801673:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801677:	d3 e0                	shl    %cl,%eax
  801679:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80167d:	09 f8                	or     %edi,%eax
  80167f:	d3 ea                	shr    %cl,%edx
  801681:	83 c4 20             	add    $0x20,%esp
  801684:	5e                   	pop    %esi
  801685:	5f                   	pop    %edi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    
  801688:	39 d6                	cmp    %edx,%esi
  80168a:	75 d9                	jne    801665 <__umoddi3+0xf5>
  80168c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80168f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801692:	eb d1                	jmp    801665 <__umoddi3+0xf5>
  801694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801698:	39 f2                	cmp    %esi,%edx
  80169a:	0f 82 18 ff ff ff    	jb     8015b8 <__umoddi3+0x48>
  8016a0:	e9 1d ff ff ff       	jmp    8015c2 <__umoddi3+0x52>
