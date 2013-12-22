
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 38             	sub    $0x38,%esp
  80003a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80003d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800043:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800047:	89 1c 24             	mov    %ebx,(%esp)
  80004a:	e8 01 08 00 00       	call   800850 <strlen>
  80004f:	83 f8 02             	cmp    $0x2,%eax
  800052:	7f 41                	jg     800095 <forkchild+0x61>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800054:	89 f0                	mov    %esi,%eax
  800056:	0f be f0             	movsbl %al,%esi
  800059:	89 74 24 10          	mov    %esi,0x10(%esp)
  80005d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800061:	c7 44 24 08 e0 15 80 	movl   $0x8015e0,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  800070:	00 
  800071:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800074:	89 04 24             	mov    %eax,(%esp)
  800077:	e8 84 07 00 00       	call   800800 <snprintf>
	if (fork() == 0) {
  80007c:	e8 64 0f 00 00       	call   800fe5 <fork>
  800081:	85 c0                	test   %eax,%eax
  800083:	75 10                	jne    800095 <forkchild+0x61>
		forktree(nxt);
  800085:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 0f 00 00 00       	call   80009f <forktree>
		exit();
  800090:	e8 bb 00 00 00       	call   800150 <exit>
	}
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <forktree>:

void
forktree(const char *cur)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 14             	sub    $0x14,%esp
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  8000a9:	e8 fa 0b 00 00       	call   800ca8 <sys_getenvid>
  8000ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b6:	c7 04 24 e5 15 80 00 	movl   $0x8015e5,(%esp)
  8000bd:	e8 03 01 00 00       	call   8001c5 <cprintf>

	forkchild(cur, '0');
  8000c2:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8000c9:	00 
  8000ca:	89 1c 24             	mov    %ebx,(%esp)
  8000cd:	e8 62 ff ff ff       	call   800034 <forkchild>
	forkchild(cur, '1');
  8000d2:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8000d9:	00 
  8000da:	89 1c 24             	mov    %ebx,(%esp)
  8000dd:	e8 52 ff ff ff       	call   800034 <forkchild>
}
  8000e2:	83 c4 14             	add    $0x14,%esp
  8000e5:	5b                   	pop    %ebx
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <umain>:

void
umain(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000ee:	c7 04 24 f5 15 80 00 	movl   $0x8015f5,(%esp)
  8000f5:	e8 a5 ff ff ff       	call   80009f <forktree>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800105:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800108:	8b 75 08             	mov    0x8(%ebp),%esi
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  80010e:	e8 95 0b 00 00       	call   800ca8 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	89 c2                	mov    %eax,%edx
  80011a:	c1 e2 07             	shl    $0x7,%edx
  80011d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800124:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800129:	85 f6                	test   %esi,%esi
  80012b:	7e 07                	jle    800134 <libmain+0x38>
		binaryname = argv[0];
  80012d:	8b 03                	mov    (%ebx),%eax
  80012f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800138:	89 34 24             	mov    %esi,(%esp)
  80013b:	e8 a8 ff ff ff       	call   8000e8 <umain>

	// exit gracefully
	exit();
  800140:	e8 0b 00 00 00       	call   800150 <exit>
}
  800145:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800148:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80014b:	89 ec                	mov    %ebp,%esp
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800156:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015d:	e8 11 0b 00 00       	call   800c73 <sys_env_destroy>
}
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	8b 45 0c             	mov    0xc(%ebp),%eax
  800184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 df 01 80 00 	movl   $0x8001df,(%esp)
  8001a0:	e8 db 01 00 00       	call   800380 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 4f 0a 00 00       	call   800c0c <sys_cputs>

	return b.cnt;
}
  8001bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 87 ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 14             	sub    $0x14,%esp
  8001e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e9:	8b 03                	mov    (%ebx),%eax
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001f2:	83 c0 01             	add    $0x1,%eax
  8001f5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fc:	75 19                	jne    800217 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fe:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800205:	00 
  800206:	8d 43 08             	lea    0x8(%ebx),%eax
  800209:	89 04 24             	mov    %eax,(%esp)
  80020c:	e8 fb 09 00 00       	call   800c0c <sys_cputs>
		b->idx = 0;
  800211:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800217:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021b:	83 c4 14             	add    $0x14,%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    
	...

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 4c             	sub    $0x4c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80024a:	8b 45 10             	mov    0x10(%ebp),%eax
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800250:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800256:	b9 00 00 00 00       	mov    $0x0,%ecx
  80025b:	39 d1                	cmp    %edx,%ecx
  80025d:	72 15                	jb     800274 <printnum+0x44>
  80025f:	77 07                	ja     800268 <printnum+0x38>
  800261:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800264:	39 d0                	cmp    %edx,%eax
  800266:	76 0c                	jbe    800274 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	85 db                	test   %ebx,%ebx
  80026d:	8d 76 00             	lea    0x0(%esi),%esi
  800270:	7f 61                	jg     8002d3 <printnum+0xa3>
  800272:	eb 70                	jmp    8002e4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800274:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800278:	83 eb 01             	sub    $0x1,%ebx
  80027b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800287:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80028b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80028e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800291:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800294:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800298:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029f:	00 
  8002a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ad:	e8 ae 10 00 00       	call   801360 <__udivdi3>
  8002b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c7:	89 f2                	mov    %esi,%edx
  8002c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cc:	e8 5f ff ff ff       	call   800230 <printnum>
  8002d1:	eb 11                	jmp    8002e4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d7:	89 3c 24             	mov    %edi,(%esp)
  8002da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	85 db                	test   %ebx,%ebx
  8002e2:	7f ef                	jg     8002d3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fa:	00 
  8002fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002fe:	89 14 24             	mov    %edx,(%esp)
  800301:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800304:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800308:	e8 83 11 00 00       	call   801490 <__umoddi3>
  80030d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800311:	0f be 80 0d 16 80 00 	movsbl 0x80160d(%eax),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80031e:	83 c4 4c             	add    $0x4c,%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800329:	83 fa 01             	cmp    $0x1,%edx
  80032c:	7e 0f                	jle    80033d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	83 c2 08             	add    $0x8,%edx
  800333:	89 10                	mov    %edx,(%eax)
  800335:	8b 42 f8             	mov    -0x8(%edx),%eax
  800338:	8b 52 fc             	mov    -0x4(%edx),%edx
  80033b:	eb 24                	jmp    800361 <getuint+0x3b>
	else if (lflag)
  80033d:	85 d2                	test   %edx,%edx
  80033f:	74 11                	je     800352 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800341:	8b 10                	mov    (%eax),%edx
  800343:	83 c2 04             	add    $0x4,%edx
  800346:	89 10                	mov    %edx,(%eax)
  800348:	8b 42 fc             	mov    -0x4(%edx),%eax
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	eb 0f                	jmp    800361 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	83 c2 04             	add    $0x4,%edx
  800357:	89 10                	mov    %edx,(%eax)
  800359:	8b 42 fc             	mov    -0x4(%edx),%eax
  80035c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800369:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	3b 50 04             	cmp    0x4(%eax),%edx
  800372:	73 0a                	jae    80037e <sprintputch+0x1b>
		*b->buf++ = ch;
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	88 0a                	mov    %cl,(%edx)
  800379:	83 c2 01             	add    $0x1,%edx
  80037c:	89 10                	mov    %edx,(%eax)
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
  800386:	83 ec 5c             	sub    $0x5c,%esp
  800389:	8b 7d 08             	mov    0x8(%ebp),%edi
  80038c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80038f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800392:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800399:	eb 11                	jmp    8003ac <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039b:	85 c0                	test   %eax,%eax
  80039d:	0f 84 fd 03 00 00    	je     8007a0 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  8003a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a7:	89 04 24             	mov    %eax,(%esp)
  8003aa:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ac:	0f b6 03             	movzbl (%ebx),%eax
  8003af:	83 c3 01             	add    $0x1,%ebx
  8003b2:	83 f8 25             	cmp    $0x25,%eax
  8003b5:	75 e4                	jne    80039b <vprintfmt+0x1b>
  8003b7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d5:	eb 06                	jmp    8003dd <vprintfmt+0x5d>
  8003d7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003db:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	0f b6 13             	movzbl (%ebx),%edx
  8003e0:	0f b6 c2             	movzbl %dl,%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e9:	83 ea 23             	sub    $0x23,%edx
  8003ec:	80 fa 55             	cmp    $0x55,%dl
  8003ef:	0f 87 8e 03 00 00    	ja     800783 <vprintfmt+0x403>
  8003f5:	0f b6 d2             	movzbl %dl,%edx
  8003f8:	ff 24 95 e0 16 80 00 	jmp    *0x8016e0(,%edx,4)
  8003ff:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800403:	eb d6                	jmp    8003db <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800405:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800408:	83 ea 30             	sub    $0x30,%edx
  80040b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80040e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800411:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800414:	83 fb 09             	cmp    $0x9,%ebx
  800417:	77 55                	ja     80046e <vprintfmt+0xee>
  800419:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800422:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800425:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800429:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80042c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80042f:	83 fb 09             	cmp    $0x9,%ebx
  800432:	76 eb                	jbe    80041f <vprintfmt+0x9f>
  800434:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800437:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043a:	eb 32                	jmp    80046e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043c:	8b 55 14             	mov    0x14(%ebp),%edx
  80043f:	83 c2 04             	add    $0x4,%edx
  800442:	89 55 14             	mov    %edx,0x14(%ebp)
  800445:	8b 52 fc             	mov    -0x4(%edx),%edx
  800448:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80044b:	eb 21                	jmp    80046e <vprintfmt+0xee>

		case '.':
			if (width < 0)
  80044d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800451:	ba 00 00 00 00       	mov    $0x0,%edx
  800456:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  80045a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80045d:	e9 79 ff ff ff       	jmp    8003db <vprintfmt+0x5b>
  800462:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800469:	e9 6d ff ff ff       	jmp    8003db <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80046e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800472:	0f 89 63 ff ff ff    	jns    8003db <vprintfmt+0x5b>
  800478:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80047b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80047e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800481:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800484:	e9 52 ff ff ff       	jmp    8003db <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800489:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80048c:	e9 4a ff ff ff       	jmp    8003db <vprintfmt+0x5b>
  800491:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	83 c0 04             	add    $0x4,%eax
  80049a:	89 45 14             	mov    %eax,0x14(%ebp)
  80049d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a1:	8b 40 fc             	mov    -0x4(%eax),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	ff d7                	call   *%edi
  8004a9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8004ac:	e9 fb fe ff ff       	jmp    8003ac <vprintfmt+0x2c>
  8004b1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	83 c0 04             	add    $0x4,%eax
  8004ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8004bd:	8b 40 fc             	mov    -0x4(%eax),%eax
  8004c0:	89 c2                	mov    %eax,%edx
  8004c2:	c1 fa 1f             	sar    $0x1f,%edx
  8004c5:	31 d0                	xor    %edx,%eax
  8004c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004c9:	83 f8 08             	cmp    $0x8,%eax
  8004cc:	7f 0b                	jg     8004d9 <vprintfmt+0x159>
  8004ce:	8b 14 85 40 18 80 00 	mov    0x801840(,%eax,4),%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	75 20                	jne    8004f9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8004d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004dd:	c7 44 24 08 1e 16 80 	movl   $0x80161e,0x8(%esp)
  8004e4:	00 
  8004e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e9:	89 3c 24             	mov    %edi,(%esp)
  8004ec:	e8 37 03 00 00       	call   800828 <printfmt>
  8004f1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004f4:	e9 b3 fe ff ff       	jmp    8003ac <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fd:	c7 44 24 08 27 16 80 	movl   $0x801627,0x8(%esp)
  800504:	00 
  800505:	89 74 24 04          	mov    %esi,0x4(%esp)
  800509:	89 3c 24             	mov    %edi,(%esp)
  80050c:	e8 17 03 00 00       	call   800828 <printfmt>
  800511:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800514:	e9 93 fe ff ff       	jmp    8003ac <vprintfmt+0x2c>
  800519:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80051c:	89 c3                	mov    %eax,%ebx
  80051e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800521:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800524:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	83 c0 04             	add    $0x4,%eax
  80052d:	89 45 14             	mov    %eax,0x14(%ebp)
  800530:	8b 40 fc             	mov    -0x4(%eax),%eax
  800533:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800536:	85 c0                	test   %eax,%eax
  800538:	b8 2a 16 80 00       	mov    $0x80162a,%eax
  80053d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  800541:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800544:	85 c9                	test   %ecx,%ecx
  800546:	7e 06                	jle    80054e <vprintfmt+0x1ce>
  800548:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054c:	75 13                	jne    800561 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800551:	0f be 02             	movsbl (%edx),%eax
  800554:	85 c0                	test   %eax,%eax
  800556:	0f 85 99 00 00 00    	jne    8005f5 <vprintfmt+0x275>
  80055c:	e9 86 00 00 00       	jmp    8005e7 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	89 54 24 04          	mov    %edx,0x4(%esp)
  800565:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800568:	89 0c 24             	mov    %ecx,(%esp)
  80056b:	e8 fb 02 00 00       	call   80086b <strnlen>
  800570:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800573:	29 c2                	sub    %eax,%edx
  800575:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800578:	85 d2                	test   %edx,%edx
  80057a:	7e d2                	jle    80054e <vprintfmt+0x1ce>
					putch(padc, putdat);
  80057c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800580:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800583:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800586:	89 d3                	mov    %edx,%ebx
  800588:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800594:	83 eb 01             	sub    $0x1,%ebx
  800597:	85 db                	test   %ebx,%ebx
  800599:	7f ed                	jg     800588 <vprintfmt+0x208>
  80059b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80059e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005a5:	eb a7                	jmp    80054e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ab:	74 18                	je     8005c5 <vprintfmt+0x245>
  8005ad:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b0:	83 fa 5e             	cmp    $0x5e,%edx
  8005b3:	76 10                	jbe    8005c5 <vprintfmt+0x245>
					putch('?', putdat);
  8005b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c0:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c3:	eb 0a                	jmp    8005cf <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c9:	89 04 24             	mov    %eax,(%esp)
  8005cc:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005d3:	0f be 03             	movsbl (%ebx),%eax
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	74 05                	je     8005df <vprintfmt+0x25f>
  8005da:	83 c3 01             	add    $0x1,%ebx
  8005dd:	eb 29                	jmp    800608 <vprintfmt+0x288>
  8005df:	89 fe                	mov    %edi,%esi
  8005e1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005eb:	7f 2e                	jg     80061b <vprintfmt+0x29b>
  8005ed:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005f0:	e9 b7 fd ff ff       	jmp    8003ac <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005f8:	83 c2 01             	add    $0x1,%edx
  8005fb:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005fe:	89 f7                	mov    %esi,%edi
  800600:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800603:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800606:	89 d3                	mov    %edx,%ebx
  800608:	85 f6                	test   %esi,%esi
  80060a:	78 9b                	js     8005a7 <vprintfmt+0x227>
  80060c:	83 ee 01             	sub    $0x1,%esi
  80060f:	79 96                	jns    8005a7 <vprintfmt+0x227>
  800611:	89 fe                	mov    %edi,%esi
  800613:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800616:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800619:	eb cc                	jmp    8005e7 <vprintfmt+0x267>
  80061b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80061e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800621:	89 74 24 04          	mov    %esi,0x4(%esp)
  800625:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80062c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062e:	83 eb 01             	sub    $0x1,%ebx
  800631:	85 db                	test   %ebx,%ebx
  800633:	7f ec                	jg     800621 <vprintfmt+0x2a1>
  800635:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800638:	e9 6f fd ff ff       	jmp    8003ac <vprintfmt+0x2c>
  80063d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800640:	83 f9 01             	cmp    $0x1,%ecx
  800643:	7e 17                	jle    80065c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	83 c0 08             	add    $0x8,%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
  80064e:	8b 50 f8             	mov    -0x8(%eax),%edx
  800651:	8b 48 fc             	mov    -0x4(%eax),%ecx
  800654:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800657:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065a:	eb 34                	jmp    800690 <vprintfmt+0x310>
	else if (lflag)
  80065c:	85 c9                	test   %ecx,%ecx
  80065e:	74 19                	je     800679 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	83 c0 04             	add    $0x4,%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
  800669:	8b 40 fc             	mov    -0x4(%eax),%eax
  80066c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066f:	89 c1                	mov    %eax,%ecx
  800671:	c1 f9 1f             	sar    $0x1f,%ecx
  800674:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800677:	eb 17                	jmp    800690 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	83 c0 04             	add    $0x4,%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
  800682:	8b 40 fc             	mov    -0x4(%eax),%eax
  800685:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800688:	89 c2                	mov    %eax,%edx
  80068a:	c1 fa 1f             	sar    $0x1f,%edx
  80068d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800690:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800693:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800696:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80069b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069f:	0f 89 9c 00 00 00    	jns    800741 <vprintfmt+0x3c1>
				putch('-', putdat);
  8006a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b0:	ff d7                	call   *%edi
				num = -(long long) num;
  8006b2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006b5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006b8:	f7 d9                	neg    %ecx
  8006ba:	83 d3 00             	adc    $0x0,%ebx
  8006bd:	f7 db                	neg    %ebx
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	eb 7b                	jmp    800741 <vprintfmt+0x3c1>
  8006c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 53 fc ff ff       	call   800326 <getuint>
  8006d3:	89 c1                	mov    %eax,%ecx
  8006d5:	89 d3                	mov    %edx,%ebx
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006dc:	eb 63                	jmp    800741 <vprintfmt+0x3c1>
  8006de:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 3b fc ff ff       	call   800326 <getuint>
  8006eb:	89 c1                	mov    %eax,%ecx
  8006ed:	89 d3                	mov    %edx,%ebx
  8006ef:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8006f4:	eb 4b                	jmp    800741 <vprintfmt+0x3c1>
  8006f6:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006fd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800704:	ff d7                	call   *%edi
			putch('x', putdat);
  800706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80070a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800711:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	83 c0 04             	add    $0x4,%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  80071f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800724:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800729:	eb 16                	jmp    800741 <vprintfmt+0x3c1>
  80072b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072e:	89 ca                	mov    %ecx,%edx
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
  800733:	e8 ee fb ff ff       	call   800326 <getuint>
  800738:	89 c1                	mov    %eax,%ecx
  80073a:	89 d3                	mov    %edx,%ebx
  80073c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800741:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800745:	89 54 24 10          	mov    %edx,0x10(%esp)
  800749:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80074c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800750:	89 44 24 08          	mov    %eax,0x8(%esp)
  800754:	89 0c 24             	mov    %ecx,(%esp)
  800757:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075b:	89 f2                	mov    %esi,%edx
  80075d:	89 f8                	mov    %edi,%eax
  80075f:	e8 cc fa ff ff       	call   800230 <printnum>
  800764:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800767:	e9 40 fc ff ff       	jmp    8003ac <vprintfmt+0x2c>
  80076c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80076f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800772:	89 74 24 04          	mov    %esi,0x4(%esp)
  800776:	89 14 24             	mov    %edx,(%esp)
  800779:	ff d7                	call   *%edi
  80077b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80077e:	e9 29 fc ff ff       	jmp    8003ac <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800783:	89 74 24 04          	mov    %esi,0x4(%esp)
  800787:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80078e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800790:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800793:	80 38 25             	cmpb   $0x25,(%eax)
  800796:	0f 84 10 fc ff ff    	je     8003ac <vprintfmt+0x2c>
  80079c:	89 c3                	mov    %eax,%ebx
  80079e:	eb f0                	jmp    800790 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  8007a0:	83 c4 5c             	add    $0x5c,%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5f                   	pop    %edi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 28             	sub    $0x28,%esp
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007b4:	85 c0                	test   %eax,%eax
  8007b6:	74 04                	je     8007bc <vsnprintf+0x14>
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	7f 07                	jg     8007c3 <vsnprintf+0x1b>
  8007bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c1:	eb 3b                	jmp    8007fe <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c6:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007db:	8b 45 10             	mov    0x10(%ebp),%eax
  8007de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e9:	c7 04 24 63 03 80 00 	movl   $0x800363,(%esp)
  8007f0:	e8 8b fb ff ff       	call   800380 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
  800809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080d:	8b 45 10             	mov    0x10(%ebp),%eax
  800810:	89 44 24 08          	mov    %eax,0x8(%esp)
  800814:	8b 45 0c             	mov    0xc(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	e8 82 ff ff ff       	call   8007a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80082e:	8d 45 14             	lea    0x14(%ebp),%eax
  800831:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800835:	8b 45 10             	mov    0x10(%ebp),%eax
  800838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	e8 32 fb ff ff       	call   800380 <vprintfmt>
	va_end(ap);
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	80 3a 00             	cmpb   $0x0,(%edx)
  80085e:	74 09                	je     800869 <strlen+0x19>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0x10>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 19                	je     800892 <strnlen+0x27>
  800879:	80 3b 00             	cmpb   $0x0,(%ebx)
  80087c:	74 14                	je     800892 <strnlen+0x27>
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c8                	cmp    %ecx,%eax
  800888:	74 0d                	je     800897 <strnlen+0x2c>
  80088a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x18>
  800890:	eb 05                	jmp    800897 <strnlen+0x2c>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	75 f2                	jne    8008a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	85 f6                	test   %esi,%esi
  8008ca:	74 18                	je     8008e4 <strncpy+0x2a>
  8008cc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008d1:	0f b6 1a             	movzbl (%edx),%ebx
  8008d4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d7:	80 3a 01             	cmpb   $0x1,(%edx)
  8008da:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dd:	83 c1 01             	add    $0x1,%ecx
  8008e0:	39 ce                	cmp    %ecx,%esi
  8008e2:	77 ed                	ja     8008d1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f6:	89 f0                	mov    %esi,%eax
  8008f8:	85 c9                	test   %ecx,%ecx
  8008fa:	74 27                	je     800923 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008fc:	83 e9 01             	sub    $0x1,%ecx
  8008ff:	74 1d                	je     80091e <strlcpy+0x36>
  800901:	0f b6 1a             	movzbl (%edx),%ebx
  800904:	84 db                	test   %bl,%bl
  800906:	74 16                	je     80091e <strlcpy+0x36>
			*dst++ = *src++;
  800908:	88 18                	mov    %bl,(%eax)
  80090a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090d:	83 e9 01             	sub    $0x1,%ecx
  800910:	74 0e                	je     800920 <strlcpy+0x38>
			*dst++ = *src++;
  800912:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800915:	0f b6 1a             	movzbl (%edx),%ebx
  800918:	84 db                	test   %bl,%bl
  80091a:	75 ec                	jne    800908 <strlcpy+0x20>
  80091c:	eb 02                	jmp    800920 <strlcpy+0x38>
  80091e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800920:	c6 00 00             	movb   $0x0,(%eax)
  800923:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800932:	0f b6 01             	movzbl (%ecx),%eax
  800935:	84 c0                	test   %al,%al
  800937:	74 15                	je     80094e <strcmp+0x25>
  800939:	3a 02                	cmp    (%edx),%al
  80093b:	75 11                	jne    80094e <strcmp+0x25>
		p++, q++;
  80093d:	83 c1 01             	add    $0x1,%ecx
  800940:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800943:	0f b6 01             	movzbl (%ecx),%eax
  800946:	84 c0                	test   %al,%al
  800948:	74 04                	je     80094e <strcmp+0x25>
  80094a:	3a 02                	cmp    (%edx),%al
  80094c:	74 ef                	je     80093d <strcmp+0x14>
  80094e:	0f b6 c0             	movzbl %al,%eax
  800951:	0f b6 12             	movzbl (%edx),%edx
  800954:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	8b 55 08             	mov    0x8(%ebp),%edx
  80095f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800962:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800965:	85 c0                	test   %eax,%eax
  800967:	74 23                	je     80098c <strncmp+0x34>
  800969:	0f b6 1a             	movzbl (%edx),%ebx
  80096c:	84 db                	test   %bl,%bl
  80096e:	74 24                	je     800994 <strncmp+0x3c>
  800970:	3a 19                	cmp    (%ecx),%bl
  800972:	75 20                	jne    800994 <strncmp+0x3c>
  800974:	83 e8 01             	sub    $0x1,%eax
  800977:	74 13                	je     80098c <strncmp+0x34>
		n--, p++, q++;
  800979:	83 c2 01             	add    $0x1,%edx
  80097c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097f:	0f b6 1a             	movzbl (%edx),%ebx
  800982:	84 db                	test   %bl,%bl
  800984:	74 0e                	je     800994 <strncmp+0x3c>
  800986:	3a 19                	cmp    (%ecx),%bl
  800988:	74 ea                	je     800974 <strncmp+0x1c>
  80098a:	eb 08                	jmp    800994 <strncmp+0x3c>
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800991:	5b                   	pop    %ebx
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800994:	0f b6 02             	movzbl (%edx),%eax
  800997:	0f b6 11             	movzbl (%ecx),%edx
  80099a:	29 d0                	sub    %edx,%eax
  80099c:	eb f3                	jmp    800991 <strncmp+0x39>

0080099e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a8:	0f b6 10             	movzbl (%eax),%edx
  8009ab:	84 d2                	test   %dl,%dl
  8009ad:	74 15                	je     8009c4 <strchr+0x26>
		if (*s == c)
  8009af:	38 ca                	cmp    %cl,%dl
  8009b1:	75 07                	jne    8009ba <strchr+0x1c>
  8009b3:	eb 14                	jmp    8009c9 <strchr+0x2b>
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	90                   	nop
  8009b8:	74 0f                	je     8009c9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f1                	jne    8009b5 <strchr+0x17>
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 18                	je     8009f4 <strfind+0x29>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	75 0a                	jne    8009ea <strfind+0x1f>
  8009e0:	eb 12                	jmp    8009f4 <strfind+0x29>
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009e8:	74 0a                	je     8009f4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 ee                	jne    8009e2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memset>:


void *
memset(void *v, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a03:	89 da                	mov    %ebx,%edx
  800a05:	83 ea 01             	sub    $0x1,%edx
  800a08:	78 0d                	js     800a17 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  800a0a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a0c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a0e:	88 0a                	mov    %cl,(%edx)
  800a10:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	75 f7                	jne    800a0e <memset+0x18>
		*p++ = c;

	return v;
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a28:	85 db                	test   %ebx,%ebx
  800a2a:	74 13                	je     800a3f <memcpy+0x25>
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800a31:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a35:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a38:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a3b:	39 da                	cmp    %ebx,%edx
  800a3d:	75 f2                	jne    800a31 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800a52:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800a54:	39 c6                	cmp    %eax,%esi
  800a56:	72 0b                	jb     800a63 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800a5d:	85 db                	test   %ebx,%ebx
  800a5f:	75 2e                	jne    800a8f <memmove+0x4c>
  800a61:	eb 3a                	jmp    800a9d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a63:	01 df                	add    %ebx,%edi
  800a65:	39 f8                	cmp    %edi,%eax
  800a67:	73 ef                	jae    800a58 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	90                   	nop
  800a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a70:	74 2b                	je     800a9d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a72:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800a7a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800a7f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800a83:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a86:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800a89:	85 c9                	test   %ecx,%ecx
  800a8b:	75 ed                	jne    800a7a <memmove+0x37>
  800a8d:	eb 0e                	jmp    800a9d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a8f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a93:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a96:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a99:	39 d3                	cmp    %edx,%ebx
  800a9b:	75 f2                	jne    800a8f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 75 08             	mov    0x8(%ebp),%esi
  800aab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800aae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	85 c9                	test   %ecx,%ecx
  800ab3:	74 36                	je     800aeb <memcmp+0x49>
		if (*s1 != *s2)
  800ab5:	0f b6 06             	movzbl (%esi),%eax
  800ab8:	0f b6 1f             	movzbl (%edi),%ebx
  800abb:	38 d8                	cmp    %bl,%al
  800abd:	74 20                	je     800adf <memcmp+0x3d>
  800abf:	eb 14                	jmp    800ad5 <memcmp+0x33>
  800ac1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ac6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	83 e9 01             	sub    $0x1,%ecx
  800ad1:	38 d8                	cmp    %bl,%al
  800ad3:	74 12                	je     800ae7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ad5:	0f b6 c0             	movzbl %al,%eax
  800ad8:	0f b6 db             	movzbl %bl,%ebx
  800adb:	29 d8                	sub    %ebx,%eax
  800add:	eb 11                	jmp    800af0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adf:	83 e9 01             	sub    $0x1,%ecx
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	85 c9                	test   %ecx,%ecx
  800ae9:	75 d6                	jne    800ac1 <memcmp+0x1f>
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b00:	39 d0                	cmp    %edx,%eax
  800b02:	73 15                	jae    800b19 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b08:	38 08                	cmp    %cl,(%eax)
  800b0a:	75 06                	jne    800b12 <memfind+0x1d>
  800b0c:	eb 0b                	jmp    800b19 <memfind+0x24>
  800b0e:	38 08                	cmp    %cl,(%eax)
  800b10:	74 07                	je     800b19 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b12:	83 c0 01             	add    $0x1,%eax
  800b15:	39 c2                	cmp    %eax,%edx
  800b17:	77 f5                	ja     800b0e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 04             	sub    $0x4,%esp
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2a:	0f b6 02             	movzbl (%edx),%eax
  800b2d:	3c 20                	cmp    $0x20,%al
  800b2f:	74 04                	je     800b35 <strtol+0x1a>
  800b31:	3c 09                	cmp    $0x9,%al
  800b33:	75 0e                	jne    800b43 <strtol+0x28>
		s++;
  800b35:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b38:	0f b6 02             	movzbl (%edx),%eax
  800b3b:	3c 20                	cmp    $0x20,%al
  800b3d:	74 f6                	je     800b35 <strtol+0x1a>
  800b3f:	3c 09                	cmp    $0x9,%al
  800b41:	74 f2                	je     800b35 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b43:	3c 2b                	cmp    $0x2b,%al
  800b45:	75 0c                	jne    800b53 <strtol+0x38>
		s++;
  800b47:	83 c2 01             	add    $0x1,%edx
  800b4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b51:	eb 15                	jmp    800b68 <strtol+0x4d>
	else if (*s == '-')
  800b53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b5a:	3c 2d                	cmp    $0x2d,%al
  800b5c:	75 0a                	jne    800b68 <strtol+0x4d>
		s++, neg = 1;
  800b5e:	83 c2 01             	add    $0x1,%edx
  800b61:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b68:	85 db                	test   %ebx,%ebx
  800b6a:	0f 94 c0             	sete   %al
  800b6d:	74 05                	je     800b74 <strtol+0x59>
  800b6f:	83 fb 10             	cmp    $0x10,%ebx
  800b72:	75 18                	jne    800b8c <strtol+0x71>
  800b74:	80 3a 30             	cmpb   $0x30,(%edx)
  800b77:	75 13                	jne    800b8c <strtol+0x71>
  800b79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7d:	8d 76 00             	lea    0x0(%esi),%esi
  800b80:	75 0a                	jne    800b8c <strtol+0x71>
		s += 2, base = 16;
  800b82:	83 c2 02             	add    $0x2,%edx
  800b85:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8a:	eb 15                	jmp    800ba1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8c:	84 c0                	test   %al,%al
  800b8e:	66 90                	xchg   %ax,%ax
  800b90:	74 0f                	je     800ba1 <strtol+0x86>
  800b92:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b97:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9a:	75 05                	jne    800ba1 <strtol+0x86>
		s++, base = 8;
  800b9c:	83 c2 01             	add    $0x1,%edx
  800b9f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba8:	0f b6 0a             	movzbl (%edx),%ecx
  800bab:	89 cf                	mov    %ecx,%edi
  800bad:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bb0:	80 fb 09             	cmp    $0x9,%bl
  800bb3:	77 08                	ja     800bbd <strtol+0xa2>
			dig = *s - '0';
  800bb5:	0f be c9             	movsbl %cl,%ecx
  800bb8:	83 e9 30             	sub    $0x30,%ecx
  800bbb:	eb 1e                	jmp    800bdb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bbd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 08                	ja     800bcd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bc5:	0f be c9             	movsbl %cl,%ecx
  800bc8:	83 e9 57             	sub    $0x57,%ecx
  800bcb:	eb 0e                	jmp    800bdb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bcd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bd0:	80 fb 19             	cmp    $0x19,%bl
  800bd3:	77 15                	ja     800bea <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bd5:	0f be c9             	movsbl %cl,%ecx
  800bd8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bdb:	39 f1                	cmp    %esi,%ecx
  800bdd:	7d 0b                	jge    800bea <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bdf:	83 c2 01             	add    $0x1,%edx
  800be2:	0f af c6             	imul   %esi,%eax
  800be5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800be8:	eb be                	jmp    800ba8 <strtol+0x8d>
  800bea:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf0:	74 05                	je     800bf7 <strtol+0xdc>
		*endptr = (char *) s;
  800bf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bf7:	89 ca                	mov    %ecx,%edx
  800bf9:	f7 da                	neg    %edx
  800bfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bff:	0f 45 c2             	cmovne %edx,%eax
}
  800c02:	83 c4 04             	add    $0x4,%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    
	...

00800c0c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	89 1c 24             	mov    %ebx,(%esp)
  800c15:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c19:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	89 c3                	mov    %eax,%ebx
  800c2a:	89 c7                	mov    %eax,%edi
  800c2c:	89 c6                	mov    %eax,%esi
  800c2e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800c30:	8b 1c 24             	mov    (%esp),%ebx
  800c33:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c37:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c3b:	89 ec                	mov    %ebp,%esp
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	89 1c 24             	mov    %ebx,(%esp)
  800c48:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c4c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800c64:	8b 1c 24             	mov    (%esp),%ebx
  800c67:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c6b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c6f:	89 ec                	mov    %ebp,%esp
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	89 1c 24             	mov    %ebx,(%esp)
  800c7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c80:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c89:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	89 cb                	mov    %ecx,%ebx
  800c93:	89 cf                	mov    %ecx,%edi
  800c95:	89 ce                	mov    %ecx,%esi
  800c97:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800c99:	8b 1c 24             	mov    (%esp),%ebx
  800c9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ca4:	89 ec                	mov    %ebp,%esp
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	89 1c 24             	mov    %ebx,(%esp)
  800cb1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbe:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc3:	89 d1                	mov    %edx,%ecx
  800cc5:	89 d3                	mov    %edx,%ebx
  800cc7:	89 d7                	mov    %edx,%edi
  800cc9:	89 d6                	mov    %edx,%esi
  800ccb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800ccd:	8b 1c 24             	mov    (%esp),%ebx
  800cd0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cd8:	89 ec                	mov    %ebp,%esp
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_yield>:

void
sys_yield(void)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	89 1c 24             	mov    %ebx,(%esp)
  800ce5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800d01:	8b 1c 24             	mov    (%esp),%ebx
  800d04:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d08:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d0c:	89 ec                	mov    %ebp,%esp
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	89 1c 24             	mov    %ebx,(%esp)
  800d19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d1d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	be 00 00 00 00       	mov    $0x0,%esi
  800d26:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 f7                	mov    %esi,%edi
  800d36:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800d38:	8b 1c 24             	mov    (%esp),%ebx
  800d3b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d3f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d43:	89 ec                	mov    %ebp,%esp
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	89 1c 24             	mov    %ebx,(%esp)
  800d50:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d54:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d6e:	8b 1c 24             	mov    (%esp),%ebx
  800d71:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d75:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d79:	89 ec                	mov    %ebp,%esp
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	89 1c 24             	mov    %ebx,(%esp)
  800d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d93:	b8 06 00 00 00       	mov    $0x6,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	89 df                	mov    %ebx,%edi
  800da0:	89 de                	mov    %ebx,%esi
  800da2:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800da4:	8b 1c 24             	mov    (%esp),%ebx
  800da7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dab:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800daf:	89 ec                	mov    %ebp,%esp
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	89 1c 24             	mov    %ebx,(%esp)
  800dbc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 df                	mov    %ebx,%edi
  800dd6:	89 de                	mov    %ebx,%esi
  800dd8:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800dda:	8b 1c 24             	mov    (%esp),%ebx
  800ddd:	8b 74 24 04          	mov    0x4(%esp),%esi
  800de1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800de5:	89 ec                	mov    %ebp,%esp
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	89 1c 24             	mov    %ebx,(%esp)
  800df2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800df6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dff:	b8 09 00 00 00       	mov    $0x9,%eax
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	89 df                	mov    %ebx,%edi
  800e0c:	89 de                	mov    %ebx,%esi
  800e0e:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800e10:	8b 1c 24             	mov    (%esp),%ebx
  800e13:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e17:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e1b:	89 ec                	mov    %ebp,%esp
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	89 1c 24             	mov    %ebx,(%esp)
  800e28:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e2c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	89 df                	mov    %ebx,%edi
  800e42:	89 de                	mov    %ebx,%esi
  800e44:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e46:	8b 1c 24             	mov    (%esp),%ebx
  800e49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e51:	89 ec                	mov    %ebp,%esp
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	89 1c 24             	mov    %ebx,(%esp)
  800e5e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e62:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	be 00 00 00 00       	mov    $0x0,%esi
  800e6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7e:	8b 1c 24             	mov    (%esp),%ebx
  800e81:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e85:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e89:	89 ec                	mov    %ebp,%esp
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	89 1c 24             	mov    %ebx,(%esp)
  800e96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e9a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	89 cb                	mov    %ecx,%ebx
  800ead:	89 cf                	mov    %ecx,%edi
  800eaf:	89 ce                	mov    %ecx,%esi
  800eb1:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800eb3:	8b 1c 24             	mov    (%esp),%ebx
  800eb6:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eba:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ebe:	89 ec                	mov    %ebp,%esp
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    
	...

00800ec4 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800eca:	c7 44 24 08 64 18 80 	movl   $0x801864,0x8(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  800ed9:	00 
  800eda:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  800ee1:	e8 7a 03 00 00       	call   801260 <_panic>

00800ee6 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	53                   	push   %ebx
  800eea:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr;
	pte_t pte;

	// LAB 4: Your code here.
	addr = (void *) ((uint32_t) pn * PGSIZE);
  800eed:	89 d3                	mov    %edx,%ebx
  800eef:	c1 e3 0c             	shl    $0xc,%ebx
	pte = vpt[VPN(addr)];
  800ef2:	89 da                	mov    %ebx,%edx
  800ef4:	c1 ea 0c             	shr    $0xc,%edx
  800ef7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((pte & PTE_W) > 0 || (pte & PTE_COW) > 0) 
  800efe:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f04:	0f 84 8c 00 00 00    	je     800f96 <duppage+0xb0>
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800f0a:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800f11:	00 
  800f12:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f25:	e8 1d fe ff ff       	call   800d47 <sys_page_map>
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	79 20                	jns    800f4e <duppage+0x68>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  800f2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f32:	c7 44 24 08 dc 18 80 	movl   $0x8018dc,0x8(%esp)
  800f39:	00 
  800f3a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  800f41:	00 
  800f42:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  800f49:	e8 12 03 00 00       	call   801260 <_panic>
	
		if ((r = sys_page_map (0, addr, 0, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800f4e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800f55:	00 
  800f56:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f61:	00 
  800f62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6d:	e8 d5 fd ff ff       	call   800d47 <sys_page_map>
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 64                	jns    800fda <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  800f76:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7a:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  800f89:	00 
  800f8a:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  800f91:	e8 ca 02 00 00       	call   801260 <_panic>
	} 
	else 
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800f96:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  800f9d:	00 
  800f9e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fa2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800faa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fb1:	e8 91 fd ff ff       	call   800d47 <sys_page_map>
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	79 20                	jns    800fda <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  800fba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fbe:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800fcd:	00 
  800fce:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  800fd5:	e8 86 02 00 00       	call   801260 <_panic>
	}	
	//panic("duppage not implemented");
	return 0;
}
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdf:	83 c4 24             	add    $0x24,%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 24             	sub    $0x24,%esp
	// LAB 4: Your code here.
	envid_t envid;  
	uint8_t *addr;  
	int r;  
	extern unsigned char end[];  
	set_pgfault_handler(pgfault);  
  800fec:	c7 04 24 1a 11 80 00 	movl   $0x80111a,(%esp)
  800ff3:	e8 cc 02 00 00       	call   8012c4 <set_pgfault_handler>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ff8:	bb 07 00 00 00       	mov    $0x7,%ebx
  800ffd:	89 d8                	mov    %ebx,%eax
  800fff:	cd 30                	int    $0x30
  801001:	89 c3                	mov    %eax,%ebx
	envid = sys_exofork();  
	if (envid < 0)  
  801003:	85 c0                	test   %eax,%eax
  801005:	79 20                	jns    801027 <fork+0x42>
		panic("sys_exofork: %e", envid);  
  801007:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80100b:	c7 44 24 08 85 18 80 	movl   $0x801885,0x8(%esp)
  801012:	00 
  801013:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  80101a:	00 
  80101b:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  801022:	e8 39 02 00 00       	call   801260 <_panic>
	//child  
	if (envid == 0) {  
  801027:	85 c0                	test   %eax,%eax
  801029:	75 20                	jne    80104b <fork+0x66>
		//can't set pgh here ,must before child run  
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
  80102b:	e8 78 fc ff ff       	call   800ca8 <sys_getenvid>
  801030:	25 ff 03 00 00       	and    $0x3ff,%eax
  801035:	89 c2                	mov    %eax,%edx
  801037:	c1 e2 07             	shl    $0x7,%edx
  80103a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801041:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;  
  801046:	e9 c7 00 00 00       	jmp    801112 <fork+0x12d>
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  80104b:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  801052:	b8 10 20 80 00       	mov    $0x802010,%eax
  801057:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80105c:	76 23                	jbe    801081 <fork+0x9c>
  80105e:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, VPN(addr));  
  801063:	c1 ea 0c             	shr    $0xc,%edx
  801066:	89 d8                	mov    %ebx,%eax
  801068:	e8 79 fe ff ff       	call   800ee6 <duppage>
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
		return 0;  
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  80106d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801070:	81 c2 00 10 00 00    	add    $0x1000,%edx
  801076:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801079:	81 fa 10 20 80 00    	cmp    $0x802010,%edx
  80107f:	72 e2                	jb     801063 <fork+0x7e>
		duppage(envid, VPN(addr));  
	duppage(envid, VPN(&addr));  
  801081:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801084:	c1 ea 0c             	shr    $0xc,%edx
  801087:	89 d8                	mov    %ebx,%eax
  801089:	e8 58 fe ff ff       	call   800ee6 <duppage>
	//copy user exception stack  

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)  
  80108e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801095:	00 
  801096:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80109d:	ee 
  80109e:	89 1c 24             	mov    %ebx,(%esp)
  8010a1:	e8 6a fc ff ff       	call   800d10 <sys_page_alloc>
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 20                	jns    8010ca <fork+0xe5>
		panic("sys_page_alloc: %e", r);  
  8010aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ae:	c7 44 24 08 95 18 80 	movl   $0x801895,0x8(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8010bd:	00 
  8010be:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  8010c5:	e8 96 01 00 00       	call   801260 <_panic>
	r = sys_env_set_pgfault_upcall(envid, env->env_pgfault_upcall);  
  8010ca:	a1 04 20 80 00       	mov    0x802004,%eax
  8010cf:	8b 40 64             	mov    0x64(%eax),%eax
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d6:	89 1c 24             	mov    %ebx,(%esp)
  8010d9:	e8 41 fd ff ff       	call   800e1f <sys_env_set_pgfault_upcall>

	//set child status  

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)  
  8010de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010e5:	00 
  8010e6:	89 1c 24             	mov    %ebx,(%esp)
  8010e9:	e8 c5 fc ff ff       	call   800db3 <sys_env_set_status>
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	79 20                	jns    801112 <fork+0x12d>
		panic("sys_env_set_status: %e", r);  
  8010f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010f6:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801105:	00 
  801106:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  80110d:	e8 4e 01 00 00       	call   801260 <_panic>
	return envid;  
	//panic("fork not implemented");
}
  801112:	89 d8                	mov    %ebx,%eax
  801114:	83 c4 24             	add    $0x24,%esp
  801117:	5b                   	pop    %ebx
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	53                   	push   %ebx
  80111e:	83 ec 24             	sub    $0x24,%esp
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801124:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801126:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80112a:	75 1c                	jne    801148 <pgfault+0x2e>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!(err&FEC_WR))   
		panic("Page fault: not a write access.");  
  80112c:	c7 44 24 08 60 19 80 	movl   $0x801960,0x8(%esp)
  801133:	00 
  801134:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80113b:	00 
  80113c:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  801143:	e8 18 01 00 00       	call   801260 <_panic>
	
	if ( !(vpt[VPN(addr)]&PTE_COW) )  
  801148:	89 d8                	mov    %ebx,%eax
  80114a:	c1 e8 0c             	shr    $0xc,%eax
  80114d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801154:	f6 c4 08             	test   $0x8,%ah
  801157:	75 1c                	jne    801175 <pgfault+0x5b>
		panic("Page fualt: not a COW page.");  
  801159:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  801160:	00 
  801161:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801168:	00 
  801169:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  801170:	e8 eb 00 00 00       	call   801260 <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	
	// LAB 4: Your code here.
	
	if ((r=sys_page_alloc(0, PFTEMP, PTE_U|PTE_W|PTE_P)) <0)  
  801175:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80117c:	00 
  80117d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801184:	00 
  801185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80118c:	e8 7f fb ff ff       	call   800d10 <sys_page_alloc>
  801191:	85 c0                	test   %eax,%eax
  801193:	79 20                	jns    8011b5 <pgfault+0x9b>
		panic("Page fault: sys_page_alloc err %e.", r);  
  801195:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801199:	c7 44 24 08 80 19 80 	movl   $0x801980,0x8(%esp)
  8011a0:	00 
  8011a1:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8011a8:	00 
  8011a9:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  8011b0:	e8 ab 00 00 00       	call   801260 <_panic>
	
	memmove(PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);  
  8011b5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8011bb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011c2:	00 
  8011c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c7:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011ce:	e8 70 f8 ff ff       	call   800a43 <memmove>
	
	
	if ((r=sys_page_map(0, PFTEMP, 0, (void *)PTE_ADDR(addr), PTE_U|PTE_W|PTE_P))<0)  
  8011d3:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011da:	00 
  8011db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011ee:	00 
  8011ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f6:	e8 4c fb ff ff       	call   800d47 <sys_page_map>
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	79 20                	jns    80121f <pgfault+0x105>
		panic("Page fault: sys_page_map err %e.", r);  
  8011ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801203:	c7 44 24 08 a4 19 80 	movl   $0x8019a4,0x8(%esp)
  80120a:	00 
  80120b:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801212:	00 
  801213:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  80121a:	e8 41 00 00 00       	call   801260 <_panic>
	if ((r=sys_page_unmap(0, PFTEMP))<0)  
  80121f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801226:	00 
  801227:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122e:	e8 4a fb ff ff       	call   800d7d <sys_page_unmap>
  801233:	85 c0                	test   %eax,%eax
  801235:	79 20                	jns    801257 <pgfault+0x13d>
		panic("Page fault: sys_page_unmap err %e.", r);  
  801237:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123b:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  801242:	00 
  801243:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  80124a:	00 
  80124b:	c7 04 24 7a 18 80 00 	movl   $0x80187a,(%esp)
  801252:	e8 09 00 00 00       	call   801260 <_panic>
	
	//panic("pgfault not implemented");
}
  801257:	83 c4 24             	add    $0x24,%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    
  80125d:	00 00                	add    %al,(%eax)
	...

00801260 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801266:	a1 08 20 80 00       	mov    0x802008,%eax
  80126b:	85 c0                	test   %eax,%eax
  80126d:	74 10                	je     80127f <_panic+0x1f>
		cprintf("%s: ", argv0);
  80126f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801273:	c7 04 24 ec 19 80 00 	movl   $0x8019ec,(%esp)
  80127a:	e8 46 ef ff ff       	call   8001c5 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80127f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801282:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
  801289:	89 44 24 08          	mov    %eax,0x8(%esp)
  80128d:	a1 00 20 80 00       	mov    0x802000,%eax
  801292:	89 44 24 04          	mov    %eax,0x4(%esp)
  801296:	c7 04 24 f1 19 80 00 	movl   $0x8019f1,(%esp)
  80129d:	e8 23 ef ff ff       	call   8001c5 <cprintf>
	vcprintf(fmt, ap);
  8012a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8012a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ac:	89 04 24             	mov    %eax,(%esp)
  8012af:	e8 b0 ee ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  8012b4:	c7 04 24 f4 15 80 00 	movl   $0x8015f4,(%esp)
  8012bb:	e8 05 ef ff ff       	call   8001c5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012c0:	cc                   	int3   
  8012c1:	eb fd                	jmp    8012c0 <_panic+0x60>
	...

008012c4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012ca:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8012d1:	75 54                	jne    801327 <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8012d3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012da:	00 
  8012db:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012e2:	ee 
  8012e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ea:	e8 21 fa ff ff       	call   800d10 <sys_page_alloc>
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	79 20                	jns    801313 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8012f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f7:	c7 44 24 08 0d 1a 80 	movl   $0x801a0d,0x8(%esp)
  8012fe:	00 
  8012ff:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801306:	00 
  801307:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  80130e:	e8 4d ff ff ff       	call   801260 <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  801313:	c7 44 24 04 34 13 80 	movl   $0x801334,0x4(%esp)
  80131a:	00 
  80131b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801322:	e8 f8 fa ff ff       	call   800e1f <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801327:	8b 45 08             	mov    0x8(%ebp),%eax
  80132a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80132f:	c9                   	leave  
  801330:	c3                   	ret    
  801331:	00 00                	add    %al,(%eax)
	...

00801334 <_pgfault_upcall>:
  801334:	54                   	push   %esp
  801335:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80133a:	ff d0                	call   *%eax
  80133c:	83 c4 04             	add    $0x4,%esp
  80133f:	8b 44 24 30          	mov    0x30(%esp),%eax
  801343:	83 e8 04             	sub    $0x4,%eax
  801346:	89 44 24 30          	mov    %eax,0x30(%esp)
  80134a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  80134e:	89 18                	mov    %ebx,(%eax)
  801350:	83 c4 08             	add    $0x8,%esp
  801353:	61                   	popa   
  801354:	83 c4 04             	add    $0x4,%esp
  801357:	9d                   	popf   
  801358:	5c                   	pop    %esp
  801359:	c3                   	ret    
  80135a:	00 00                	add    %al,(%eax)
  80135c:	00 00                	add    %al,(%eax)
	...

00801360 <__udivdi3>:
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	57                   	push   %edi
  801364:	56                   	push   %esi
  801365:	83 ec 10             	sub    $0x10,%esp
  801368:	8b 45 14             	mov    0x14(%ebp),%eax
  80136b:	8b 55 08             	mov    0x8(%ebp),%edx
  80136e:	8b 75 10             	mov    0x10(%ebp),%esi
  801371:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801374:	85 c0                	test   %eax,%eax
  801376:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801379:	75 35                	jne    8013b0 <__udivdi3+0x50>
  80137b:	39 fe                	cmp    %edi,%esi
  80137d:	77 61                	ja     8013e0 <__udivdi3+0x80>
  80137f:	85 f6                	test   %esi,%esi
  801381:	75 0b                	jne    80138e <__udivdi3+0x2e>
  801383:	b8 01 00 00 00       	mov    $0x1,%eax
  801388:	31 d2                	xor    %edx,%edx
  80138a:	f7 f6                	div    %esi
  80138c:	89 c6                	mov    %eax,%esi
  80138e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801391:	31 d2                	xor    %edx,%edx
  801393:	89 f8                	mov    %edi,%eax
  801395:	f7 f6                	div    %esi
  801397:	89 c7                	mov    %eax,%edi
  801399:	89 c8                	mov    %ecx,%eax
  80139b:	f7 f6                	div    %esi
  80139d:	89 c1                	mov    %eax,%ecx
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	89 c8                	mov    %ecx,%eax
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	5e                   	pop    %esi
  8013a7:	5f                   	pop    %edi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    
  8013aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013b0:	39 f8                	cmp    %edi,%eax
  8013b2:	77 1c                	ja     8013d0 <__udivdi3+0x70>
  8013b4:	0f bd d0             	bsr    %eax,%edx
  8013b7:	83 f2 1f             	xor    $0x1f,%edx
  8013ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013bd:	75 39                	jne    8013f8 <__udivdi3+0x98>
  8013bf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8013c2:	0f 86 a0 00 00 00    	jbe    801468 <__udivdi3+0x108>
  8013c8:	39 f8                	cmp    %edi,%eax
  8013ca:	0f 82 98 00 00 00    	jb     801468 <__udivdi3+0x108>
  8013d0:	31 ff                	xor    %edi,%edi
  8013d2:	31 c9                	xor    %ecx,%ecx
  8013d4:	89 c8                	mov    %ecx,%eax
  8013d6:	89 fa                	mov    %edi,%edx
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	5e                   	pop    %esi
  8013dc:	5f                   	pop    %edi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    
  8013df:	90                   	nop
  8013e0:	89 d1                	mov    %edx,%ecx
  8013e2:	89 fa                	mov    %edi,%edx
  8013e4:	89 c8                	mov    %ecx,%eax
  8013e6:	31 ff                	xor    %edi,%edi
  8013e8:	f7 f6                	div    %esi
  8013ea:	89 c1                	mov    %eax,%ecx
  8013ec:	89 fa                	mov    %edi,%edx
  8013ee:	89 c8                	mov    %ecx,%eax
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	5e                   	pop    %esi
  8013f4:	5f                   	pop    %edi
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    
  8013f7:	90                   	nop
  8013f8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8013fc:	89 f2                	mov    %esi,%edx
  8013fe:	d3 e0                	shl    %cl,%eax
  801400:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801403:	b8 20 00 00 00       	mov    $0x20,%eax
  801408:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80140b:	89 c1                	mov    %eax,%ecx
  80140d:	d3 ea                	shr    %cl,%edx
  80140f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801413:	0b 55 ec             	or     -0x14(%ebp),%edx
  801416:	d3 e6                	shl    %cl,%esi
  801418:	89 c1                	mov    %eax,%ecx
  80141a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80141d:	89 fe                	mov    %edi,%esi
  80141f:	d3 ee                	shr    %cl,%esi
  801421:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801425:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801428:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80142b:	d3 e7                	shl    %cl,%edi
  80142d:	89 c1                	mov    %eax,%ecx
  80142f:	d3 ea                	shr    %cl,%edx
  801431:	09 d7                	or     %edx,%edi
  801433:	89 f2                	mov    %esi,%edx
  801435:	89 f8                	mov    %edi,%eax
  801437:	f7 75 ec             	divl   -0x14(%ebp)
  80143a:	89 d6                	mov    %edx,%esi
  80143c:	89 c7                	mov    %eax,%edi
  80143e:	f7 65 e8             	mull   -0x18(%ebp)
  801441:	39 d6                	cmp    %edx,%esi
  801443:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801446:	72 30                	jb     801478 <__udivdi3+0x118>
  801448:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80144f:	d3 e2                	shl    %cl,%edx
  801451:	39 c2                	cmp    %eax,%edx
  801453:	73 05                	jae    80145a <__udivdi3+0xfa>
  801455:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801458:	74 1e                	je     801478 <__udivdi3+0x118>
  80145a:	89 f9                	mov    %edi,%ecx
  80145c:	31 ff                	xor    %edi,%edi
  80145e:	e9 71 ff ff ff       	jmp    8013d4 <__udivdi3+0x74>
  801463:	90                   	nop
  801464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801468:	31 ff                	xor    %edi,%edi
  80146a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80146f:	e9 60 ff ff ff       	jmp    8013d4 <__udivdi3+0x74>
  801474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801478:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80147b:	31 ff                	xor    %edi,%edi
  80147d:	89 c8                	mov    %ecx,%eax
  80147f:	89 fa                	mov    %edi,%edx
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    
	...

00801490 <__umoddi3>:
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	57                   	push   %edi
  801494:	56                   	push   %esi
  801495:	83 ec 20             	sub    $0x20,%esp
  801498:	8b 55 14             	mov    0x14(%ebp),%edx
  80149b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80149e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8014a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014a4:	85 d2                	test   %edx,%edx
  8014a6:	89 c8                	mov    %ecx,%eax
  8014a8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8014ab:	75 13                	jne    8014c0 <__umoddi3+0x30>
  8014ad:	39 f7                	cmp    %esi,%edi
  8014af:	76 3f                	jbe    8014f0 <__umoddi3+0x60>
  8014b1:	89 f2                	mov    %esi,%edx
  8014b3:	f7 f7                	div    %edi
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	31 d2                	xor    %edx,%edx
  8014b9:	83 c4 20             	add    $0x20,%esp
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    
  8014c0:	39 f2                	cmp    %esi,%edx
  8014c2:	77 4c                	ja     801510 <__umoddi3+0x80>
  8014c4:	0f bd ca             	bsr    %edx,%ecx
  8014c7:	83 f1 1f             	xor    $0x1f,%ecx
  8014ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8014cd:	75 51                	jne    801520 <__umoddi3+0x90>
  8014cf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8014d2:	0f 87 e0 00 00 00    	ja     8015b8 <__umoddi3+0x128>
  8014d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014db:	29 f8                	sub    %edi,%eax
  8014dd:	19 d6                	sbb    %edx,%esi
  8014df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8014e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e5:	89 f2                	mov    %esi,%edx
  8014e7:	83 c4 20             	add    $0x20,%esp
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    
  8014ee:	66 90                	xchg   %ax,%ax
  8014f0:	85 ff                	test   %edi,%edi
  8014f2:	75 0b                	jne    8014ff <__umoddi3+0x6f>
  8014f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f9:	31 d2                	xor    %edx,%edx
  8014fb:	f7 f7                	div    %edi
  8014fd:	89 c7                	mov    %eax,%edi
  8014ff:	89 f0                	mov    %esi,%eax
  801501:	31 d2                	xor    %edx,%edx
  801503:	f7 f7                	div    %edi
  801505:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801508:	f7 f7                	div    %edi
  80150a:	eb a9                	jmp    8014b5 <__umoddi3+0x25>
  80150c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801510:	89 c8                	mov    %ecx,%eax
  801512:	89 f2                	mov    %esi,%edx
  801514:	83 c4 20             	add    $0x20,%esp
  801517:	5e                   	pop    %esi
  801518:	5f                   	pop    %edi
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    
  80151b:	90                   	nop
  80151c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801520:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801524:	d3 e2                	shl    %cl,%edx
  801526:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801529:	ba 20 00 00 00       	mov    $0x20,%edx
  80152e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801531:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801534:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801538:	89 fa                	mov    %edi,%edx
  80153a:	d3 ea                	shr    %cl,%edx
  80153c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801540:	0b 55 f4             	or     -0xc(%ebp),%edx
  801543:	d3 e7                	shl    %cl,%edi
  801545:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801549:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80154c:	89 f2                	mov    %esi,%edx
  80154e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801551:	89 c7                	mov    %eax,%edi
  801553:	d3 ea                	shr    %cl,%edx
  801555:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801559:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	d3 e6                	shl    %cl,%esi
  801560:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801564:	d3 ea                	shr    %cl,%edx
  801566:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80156a:	09 d6                	or     %edx,%esi
  80156c:	89 f0                	mov    %esi,%eax
  80156e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801571:	d3 e7                	shl    %cl,%edi
  801573:	89 f2                	mov    %esi,%edx
  801575:	f7 75 f4             	divl   -0xc(%ebp)
  801578:	89 d6                	mov    %edx,%esi
  80157a:	f7 65 e8             	mull   -0x18(%ebp)
  80157d:	39 d6                	cmp    %edx,%esi
  80157f:	72 2b                	jb     8015ac <__umoddi3+0x11c>
  801581:	39 c7                	cmp    %eax,%edi
  801583:	72 23                	jb     8015a8 <__umoddi3+0x118>
  801585:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801589:	29 c7                	sub    %eax,%edi
  80158b:	19 d6                	sbb    %edx,%esi
  80158d:	89 f0                	mov    %esi,%eax
  80158f:	89 f2                	mov    %esi,%edx
  801591:	d3 ef                	shr    %cl,%edi
  801593:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801597:	d3 e0                	shl    %cl,%eax
  801599:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80159d:	09 f8                	or     %edi,%eax
  80159f:	d3 ea                	shr    %cl,%edx
  8015a1:	83 c4 20             	add    $0x20,%esp
  8015a4:	5e                   	pop    %esi
  8015a5:	5f                   	pop    %edi
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    
  8015a8:	39 d6                	cmp    %edx,%esi
  8015aa:	75 d9                	jne    801585 <__umoddi3+0xf5>
  8015ac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8015af:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8015b2:	eb d1                	jmp    801585 <__umoddi3+0xf5>
  8015b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015b8:	39 f2                	cmp    %esi,%edx
  8015ba:	0f 82 18 ff ff ff    	jb     8014d8 <__umoddi3+0x48>
  8015c0:	e9 1d ff ff ff       	jmp    8014e2 <__umoddi3+0x52>
