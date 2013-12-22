
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 d2 0e 00 00       	call   800f14 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; env is %p\n", sys_getenvid(), env);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 a4 0c 00 00       	call   800cf8 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 20 17 80 00 	movl   $0x801720,(%esp)
  800063:	e8 ad 01 00 00       	call   800215 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 88 0c 00 00       	call   800cf8 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 36 17 80 00 	movl   $0x801736,(%esp)
  80007f:	e8 91 01 00 00       	call   800215 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 09 12 00 00       	call   8012b0 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 59 12 00 00       	call   80131b <ipc_recv>
		cprintf("%x got %d from %x (env is %p %x)\n", sys_getenvid(), val, who, env, env->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 4c             	mov    0x4c(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 1c 0c 00 00       	call   800cf8 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 4c 17 80 00 	movl   $0x80174c,(%esp)
  8000fa:	e8 16 01 00 00       	call   800215 <cprintf>
		if (val == 10)
  8000ff:	a1 04 20 80 00       	mov    0x802004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 7c 11 00 00       	call   8012b0 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}
		
}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  80015e:	e8 95 0b 00 00       	call   800cf8 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	89 c2                	mov    %eax,%edx
  80016a:	c1 e2 07             	shl    $0x7,%edx
  80016d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800174:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x38>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	89 34 24             	mov    %esi,(%esp)
  80018b:	e8 a4 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 11 0b 00 00       	call   800cc3 <sys_env_destroy>
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	c7 04 24 2f 02 80 00 	movl   $0x80022f,(%esp)
  8001f0:	e8 db 01 00 00       	call   8003d0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 4f 0a 00 00       	call   800c5c <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	8b 45 08             	mov    0x8(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	e8 87 ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	53                   	push   %ebx
  800233:	83 ec 14             	sub    $0x14,%esp
  800236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800239:	8b 03                	mov    (%ebx),%eax
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800242:	83 c0 01             	add    $0x1,%eax
  800245:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800247:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024c:	75 19                	jne    800267 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80024e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800255:	00 
  800256:	8d 43 08             	lea    0x8(%ebx),%eax
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	e8 fb 09 00 00       	call   800c5c <sys_cputs>
		b->idx = 0;
  800261:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800267:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80026b:	83 c4 14             	add    $0x14,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ab:	39 d1                	cmp    %edx,%ecx
  8002ad:	72 15                	jb     8002c4 <printnum+0x44>
  8002af:	77 07                	ja     8002b8 <printnum+0x38>
  8002b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b4:	39 d0                	cmp    %edx,%eax
  8002b6:	76 0c                	jbe    8002c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	8d 76 00             	lea    0x0(%esi),%esi
  8002c0:	7f 61                	jg     800323 <printnum+0xa3>
  8002c2:	eb 70                	jmp    800334 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002c8:	83 eb 01             	sub    $0x1,%ebx
  8002cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ef:	00 
  8002f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fd:	e8 9e 11 00 00       	call   8014a0 <__udivdi3>
  800302:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800305:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	89 54 24 04          	mov    %edx,0x4(%esp)
  800317:	89 f2                	mov    %esi,%edx
  800319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031c:	e8 5f ff ff ff       	call   800280 <printnum>
  800321:	eb 11                	jmp    800334 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	89 74 24 04          	mov    %esi,0x4(%esp)
  800327:	89 3c 24             	mov    %edi,(%esp)
  80032a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032d:	83 eb 01             	sub    $0x1,%ebx
  800330:	85 db                	test   %ebx,%ebx
  800332:	7f ef                	jg     800323 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800334:	89 74 24 04          	mov    %esi,0x4(%esp)
  800338:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034a:	00 
  80034b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80034e:	89 14 24             	mov    %edx,(%esp)
  800351:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800354:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800358:	e8 73 12 00 00       	call   8015d0 <__umoddi3>
  80035d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800361:	0f be 80 85 17 80 00 	movsbl 0x801785(%eax),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80036e:	83 c4 4c             	add    $0x4c,%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800379:	83 fa 01             	cmp    $0x1,%edx
  80037c:	7e 0f                	jle    80038d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	83 c2 08             	add    $0x8,%edx
  800383:	89 10                	mov    %edx,(%eax)
  800385:	8b 42 f8             	mov    -0x8(%edx),%eax
  800388:	8b 52 fc             	mov    -0x4(%edx),%edx
  80038b:	eb 24                	jmp    8003b1 <getuint+0x3b>
	else if (lflag)
  80038d:	85 d2                	test   %edx,%edx
  80038f:	74 11                	je     8003a2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800391:	8b 10                	mov    (%eax),%edx
  800393:	83 c2 04             	add    $0x4,%edx
  800396:	89 10                	mov    %edx,(%eax)
  800398:	8b 42 fc             	mov    -0x4(%edx),%eax
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a0:	eb 0f                	jmp    8003b1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	83 c2 04             	add    $0x4,%edx
  8003a7:	89 10                	mov    %edx,(%eax)
  8003a9:	8b 42 fc             	mov    -0x4(%edx),%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003bd:	8b 10                	mov    (%eax),%edx
  8003bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c2:	73 0a                	jae    8003ce <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c7:	88 0a                	mov    %cl,(%edx)
  8003c9:	83 c2 01             	add    $0x1,%edx
  8003cc:	89 10                	mov    %edx,(%eax)
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 5c             	sub    $0x5c,%esp
  8003d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003df:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003e2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e9:	eb 11                	jmp    8003fc <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	0f 84 fd 03 00 00    	je     8007f0 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  8003f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f7:	89 04 24             	mov    %eax,(%esp)
  8003fa:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003fc:	0f b6 03             	movzbl (%ebx),%eax
  8003ff:	83 c3 01             	add    $0x1,%ebx
  800402:	83 f8 25             	cmp    $0x25,%eax
  800405:	75 e4                	jne    8003eb <vprintfmt+0x1b>
  800407:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80040b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800412:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800419:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800420:	b9 00 00 00 00       	mov    $0x0,%ecx
  800425:	eb 06                	jmp    80042d <vprintfmt+0x5d>
  800427:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80042b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	0f b6 13             	movzbl (%ebx),%edx
  800430:	0f b6 c2             	movzbl %dl,%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800436:	8d 43 01             	lea    0x1(%ebx),%eax
  800439:	83 ea 23             	sub    $0x23,%edx
  80043c:	80 fa 55             	cmp    $0x55,%dl
  80043f:	0f 87 8e 03 00 00    	ja     8007d3 <vprintfmt+0x403>
  800445:	0f b6 d2             	movzbl %dl,%edx
  800448:	ff 24 95 40 18 80 00 	jmp    *0x801840(,%edx,4)
  80044f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800453:	eb d6                	jmp    80042b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800455:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800458:	83 ea 30             	sub    $0x30,%edx
  80045b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80045e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800461:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800464:	83 fb 09             	cmp    $0x9,%ebx
  800467:	77 55                	ja     8004be <vprintfmt+0xee>
  800469:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80046c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800472:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800475:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800479:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80047c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80047f:	83 fb 09             	cmp    $0x9,%ebx
  800482:	76 eb                	jbe    80046f <vprintfmt+0x9f>
  800484:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800487:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048a:	eb 32                	jmp    8004be <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048c:	8b 55 14             	mov    0x14(%ebp),%edx
  80048f:	83 c2 04             	add    $0x4,%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	8b 52 fc             	mov    -0x4(%edx),%edx
  800498:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80049b:	eb 21                	jmp    8004be <vprintfmt+0xee>

		case '.':
			if (width < 0)
  80049d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8004aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ad:	e9 79 ff ff ff       	jmp    80042b <vprintfmt+0x5b>
  8004b2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004b9:	e9 6d ff ff ff       	jmp    80042b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c2:	0f 89 63 ff ff ff    	jns    80042b <vprintfmt+0x5b>
  8004c8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ce:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004d1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004d4:	e9 52 ff ff ff       	jmp    80042b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d9:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004dc:	e9 4a ff ff ff       	jmp    80042b <vprintfmt+0x5b>
  8004e1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	83 c0 04             	add    $0x4,%eax
  8004ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f1:	8b 40 fc             	mov    -0x4(%eax),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	ff d7                	call   *%edi
  8004f9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8004fc:	e9 fb fe ff ff       	jmp    8003fc <vprintfmt+0x2c>
  800501:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	83 c0 04             	add    $0x4,%eax
  80050a:	89 45 14             	mov    %eax,0x14(%ebp)
  80050d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800510:	89 c2                	mov    %eax,%edx
  800512:	c1 fa 1f             	sar    $0x1f,%edx
  800515:	31 d0                	xor    %edx,%eax
  800517:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800519:	83 f8 08             	cmp    $0x8,%eax
  80051c:	7f 0b                	jg     800529 <vprintfmt+0x159>
  80051e:	8b 14 85 a0 19 80 00 	mov    0x8019a0(,%eax,4),%edx
  800525:	85 d2                	test   %edx,%edx
  800527:	75 20                	jne    800549 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800529:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052d:	c7 44 24 08 96 17 80 	movl   $0x801796,0x8(%esp)
  800534:	00 
  800535:	89 74 24 04          	mov    %esi,0x4(%esp)
  800539:	89 3c 24             	mov    %edi,(%esp)
  80053c:	e8 37 03 00 00       	call   800878 <printfmt>
  800541:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800544:	e9 b3 fe ff ff       	jmp    8003fc <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800549:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054d:	c7 44 24 08 9f 17 80 	movl   $0x80179f,0x8(%esp)
  800554:	00 
  800555:	89 74 24 04          	mov    %esi,0x4(%esp)
  800559:	89 3c 24             	mov    %edi,(%esp)
  80055c:	e8 17 03 00 00       	call   800878 <printfmt>
  800561:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800564:	e9 93 fe ff ff       	jmp    8003fc <vprintfmt+0x2c>
  800569:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80056c:	89 c3                	mov    %eax,%ebx
  80056e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800571:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800574:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	83 c0 04             	add    $0x4,%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
  800580:	8b 40 fc             	mov    -0x4(%eax),%eax
  800583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800586:	85 c0                	test   %eax,%eax
  800588:	b8 a2 17 80 00       	mov    $0x8017a2,%eax
  80058d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  800591:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800594:	85 c9                	test   %ecx,%ecx
  800596:	7e 06                	jle    80059e <vprintfmt+0x1ce>
  800598:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80059c:	75 13                	jne    8005b1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005a1:	0f be 02             	movsbl (%edx),%eax
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	0f 85 99 00 00 00    	jne    800645 <vprintfmt+0x275>
  8005ac:	e9 86 00 00 00       	jmp    800637 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b8:	89 0c 24             	mov    %ecx,(%esp)
  8005bb:	e8 fb 02 00 00       	call   8008bb <strnlen>
  8005c0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005c3:	29 c2                	sub    %eax,%edx
  8005c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005c8:	85 d2                	test   %edx,%edx
  8005ca:	7e d2                	jle    80059e <vprintfmt+0x1ce>
					putch(padc, putdat);
  8005cc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005d0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005d3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005d6:	89 d3                	mov    %edx,%ebx
  8005d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	83 eb 01             	sub    $0x1,%ebx
  8005e7:	85 db                	test   %ebx,%ebx
  8005e9:	7f ed                	jg     8005d8 <vprintfmt+0x208>
  8005eb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f5:	eb a7                	jmp    80059e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005fb:	74 18                	je     800615 <vprintfmt+0x245>
  8005fd:	8d 50 e0             	lea    -0x20(%eax),%edx
  800600:	83 fa 5e             	cmp    $0x5e,%edx
  800603:	76 10                	jbe    800615 <vprintfmt+0x245>
					putch('?', putdat);
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800610:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800613:	eb 0a                	jmp    80061f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800623:	0f be 03             	movsbl (%ebx),%eax
  800626:	85 c0                	test   %eax,%eax
  800628:	74 05                	je     80062f <vprintfmt+0x25f>
  80062a:	83 c3 01             	add    $0x1,%ebx
  80062d:	eb 29                	jmp    800658 <vprintfmt+0x288>
  80062f:	89 fe                	mov    %edi,%esi
  800631:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800634:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800637:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063b:	7f 2e                	jg     80066b <vprintfmt+0x29b>
  80063d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800640:	e9 b7 fd ff ff       	jmp    8003fc <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800645:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800648:	83 c2 01             	add    $0x1,%edx
  80064b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80064e:	89 f7                	mov    %esi,%edi
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800656:	89 d3                	mov    %edx,%ebx
  800658:	85 f6                	test   %esi,%esi
  80065a:	78 9b                	js     8005f7 <vprintfmt+0x227>
  80065c:	83 ee 01             	sub    $0x1,%esi
  80065f:	79 96                	jns    8005f7 <vprintfmt+0x227>
  800661:	89 fe                	mov    %edi,%esi
  800663:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800666:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800669:	eb cc                	jmp    800637 <vprintfmt+0x267>
  80066b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80066e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800671:	89 74 24 04          	mov    %esi,0x4(%esp)
  800675:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80067c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067e:	83 eb 01             	sub    $0x1,%ebx
  800681:	85 db                	test   %ebx,%ebx
  800683:	7f ec                	jg     800671 <vprintfmt+0x2a1>
  800685:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800688:	e9 6f fd ff ff       	jmp    8003fc <vprintfmt+0x2c>
  80068d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800690:	83 f9 01             	cmp    $0x1,%ecx
  800693:	7e 17                	jle    8006ac <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	83 c0 08             	add    $0x8,%eax
  80069b:	89 45 14             	mov    %eax,0x14(%ebp)
  80069e:	8b 50 f8             	mov    -0x8(%eax),%edx
  8006a1:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8006a4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006aa:	eb 34                	jmp    8006e0 <vprintfmt+0x310>
	else if (lflag)
  8006ac:	85 c9                	test   %ecx,%ecx
  8006ae:	74 19                	je     8006c9 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	83 c0 04             	add    $0x4,%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b9:	8b 40 fc             	mov    -0x4(%eax),%eax
  8006bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bf:	89 c1                	mov    %eax,%ecx
  8006c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c7:	eb 17                	jmp    8006e0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	83 c0 04             	add    $0x4,%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d2:	8b 40 fc             	mov    -0x4(%eax),%eax
  8006d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d8:	89 c2                	mov    %eax,%edx
  8006da:	c1 fa 1f             	sar    $0x1f,%edx
  8006dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006e3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006e6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ef:	0f 89 9c 00 00 00    	jns    800791 <vprintfmt+0x3c1>
				putch('-', putdat);
  8006f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800700:	ff d7                	call   *%edi
				num = -(long long) num;
  800702:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800705:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800708:	f7 d9                	neg    %ecx
  80070a:	83 d3 00             	adc    $0x0,%ebx
  80070d:	f7 db                	neg    %ebx
  80070f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800714:	eb 7b                	jmp    800791 <vprintfmt+0x3c1>
  800716:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800719:	89 ca                	mov    %ecx,%edx
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 53 fc ff ff       	call   800376 <getuint>
  800723:	89 c1                	mov    %eax,%ecx
  800725:	89 d3                	mov    %edx,%ebx
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80072c:	eb 63                	jmp    800791 <vprintfmt+0x3c1>
  80072e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800731:	89 ca                	mov    %ecx,%edx
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 3b fc ff ff       	call   800376 <getuint>
  80073b:	89 c1                	mov    %eax,%ecx
  80073d:	89 d3                	mov    %edx,%ebx
  80073f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800744:	eb 4b                	jmp    800791 <vprintfmt+0x3c1>
  800746:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800749:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800754:	ff d7                	call   *%edi
			putch('x', putdat);
  800756:	89 74 24 04          	mov    %esi,0x4(%esp)
  80075a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800761:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	83 c0 04             	add    $0x4,%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  80076f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800774:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800779:	eb 16                	jmp    800791 <vprintfmt+0x3c1>
  80077b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80077e:	89 ca                	mov    %ecx,%edx
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
  800783:	e8 ee fb ff ff       	call   800376 <getuint>
  800788:	89 c1                	mov    %eax,%ecx
  80078a:	89 d3                	mov    %edx,%ebx
  80078c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800791:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800795:	89 54 24 10          	mov    %edx,0x10(%esp)
  800799:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a4:	89 0c 24             	mov    %ecx,(%esp)
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	89 f2                	mov    %esi,%edx
  8007ad:	89 f8                	mov    %edi,%eax
  8007af:	e8 cc fa ff ff       	call   800280 <printnum>
  8007b4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007b7:	e9 40 fc ff ff       	jmp    8003fc <vprintfmt+0x2c>
  8007bc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007bf:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c6:	89 14 24             	mov    %edx,(%esp)
  8007c9:	ff d7                	call   *%edi
  8007cb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007ce:	e9 29 fc ff ff       	jmp    8003fc <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007de:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007e3:	80 38 25             	cmpb   $0x25,(%eax)
  8007e6:	0f 84 10 fc ff ff    	je     8003fc <vprintfmt+0x2c>
  8007ec:	89 c3                	mov    %eax,%ebx
  8007ee:	eb f0                	jmp    8007e0 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  8007f0:	83 c4 5c             	add    $0x5c,%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 28             	sub    $0x28,%esp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800804:	85 c0                	test   %eax,%eax
  800806:	74 04                	je     80080c <vsnprintf+0x14>
  800808:	85 d2                	test   %edx,%edx
  80080a:	7f 07                	jg     800813 <vsnprintf+0x1b>
  80080c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800811:	eb 3b                	jmp    80084e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800813:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800816:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80081a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80081d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082b:	8b 45 10             	mov    0x10(%ebp),%eax
  80082e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800832:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800835:	89 44 24 04          	mov    %eax,0x4(%esp)
  800839:	c7 04 24 b3 03 80 00 	movl   $0x8003b3,(%esp)
  800840:	e8 8b fb ff ff       	call   8003d0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800845:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800848:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
  800859:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085d:	8b 45 10             	mov    0x10(%ebp),%eax
  800860:	89 44 24 08          	mov    %eax,0x8(%esp)
  800864:	8b 45 0c             	mov    0xc(%ebp),%eax
  800867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	89 04 24             	mov    %eax,(%esp)
  800871:	e8 82 ff ff ff       	call   8007f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80087e:	8d 45 14             	lea    0x14(%ebp),%eax
  800881:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800885:	8b 45 10             	mov    0x10(%ebp),%eax
  800888:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 32 fb ff ff       	call   8003d0 <vprintfmt>
	va_end(ap);
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ae:	74 09                	je     8008b9 <strlen+0x19>
		n++;
  8008b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b7:	75 f7                	jne    8008b0 <strlen+0x10>
		n++;
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	74 19                	je     8008e2 <strnlen+0x27>
  8008c9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008cc:	74 14                	je     8008e2 <strnlen+0x27>
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008d3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d6:	39 c8                	cmp    %ecx,%eax
  8008d8:	74 0d                	je     8008e7 <strnlen+0x2c>
  8008da:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008de:	75 f3                	jne    8008d3 <strnlen+0x18>
  8008e0:	eb 05                	jmp    8008e7 <strnlen+0x2c>
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	53                   	push   %ebx
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	84 c9                	test   %cl,%cl
  800905:	75 f2                	jne    8008f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
  800915:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800918:	85 f6                	test   %esi,%esi
  80091a:	74 18                	je     800934 <strncpy+0x2a>
  80091c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800921:	0f b6 1a             	movzbl (%edx),%ebx
  800924:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800927:	80 3a 01             	cmpb   $0x1,(%edx)
  80092a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092d:	83 c1 01             	add    $0x1,%ecx
  800930:	39 ce                	cmp    %ecx,%esi
  800932:	77 ed                	ja     800921 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 75 08             	mov    0x8(%ebp),%esi
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800946:	89 f0                	mov    %esi,%eax
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 27                	je     800973 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80094c:	83 e9 01             	sub    $0x1,%ecx
  80094f:	74 1d                	je     80096e <strlcpy+0x36>
  800951:	0f b6 1a             	movzbl (%edx),%ebx
  800954:	84 db                	test   %bl,%bl
  800956:	74 16                	je     80096e <strlcpy+0x36>
			*dst++ = *src++;
  800958:	88 18                	mov    %bl,(%eax)
  80095a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80095d:	83 e9 01             	sub    $0x1,%ecx
  800960:	74 0e                	je     800970 <strlcpy+0x38>
			*dst++ = *src++;
  800962:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800965:	0f b6 1a             	movzbl (%edx),%ebx
  800968:	84 db                	test   %bl,%bl
  80096a:	75 ec                	jne    800958 <strlcpy+0x20>
  80096c:	eb 02                	jmp    800970 <strlcpy+0x38>
  80096e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800970:	c6 00 00             	movb   $0x0,(%eax)
  800973:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800982:	0f b6 01             	movzbl (%ecx),%eax
  800985:	84 c0                	test   %al,%al
  800987:	74 15                	je     80099e <strcmp+0x25>
  800989:	3a 02                	cmp    (%edx),%al
  80098b:	75 11                	jne    80099e <strcmp+0x25>
		p++, q++;
  80098d:	83 c1 01             	add    $0x1,%ecx
  800990:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	84 c0                	test   %al,%al
  800998:	74 04                	je     80099e <strcmp+0x25>
  80099a:	3a 02                	cmp    (%edx),%al
  80099c:	74 ef                	je     80098d <strcmp+0x14>
  80099e:	0f b6 c0             	movzbl %al,%eax
  8009a1:	0f b6 12             	movzbl (%edx),%edx
  8009a4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	53                   	push   %ebx
  8009ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	74 23                	je     8009dc <strncmp+0x34>
  8009b9:	0f b6 1a             	movzbl (%edx),%ebx
  8009bc:	84 db                	test   %bl,%bl
  8009be:	74 24                	je     8009e4 <strncmp+0x3c>
  8009c0:	3a 19                	cmp    (%ecx),%bl
  8009c2:	75 20                	jne    8009e4 <strncmp+0x3c>
  8009c4:	83 e8 01             	sub    $0x1,%eax
  8009c7:	74 13                	je     8009dc <strncmp+0x34>
		n--, p++, q++;
  8009c9:	83 c2 01             	add    $0x1,%edx
  8009cc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009cf:	0f b6 1a             	movzbl (%edx),%ebx
  8009d2:	84 db                	test   %bl,%bl
  8009d4:	74 0e                	je     8009e4 <strncmp+0x3c>
  8009d6:	3a 19                	cmp    (%ecx),%bl
  8009d8:	74 ea                	je     8009c4 <strncmp+0x1c>
  8009da:	eb 08                	jmp    8009e4 <strncmp+0x3c>
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e4:	0f b6 02             	movzbl (%edx),%eax
  8009e7:	0f b6 11             	movzbl (%ecx),%edx
  8009ea:	29 d0                	sub    %edx,%eax
  8009ec:	eb f3                	jmp    8009e1 <strncmp+0x39>

008009ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f8:	0f b6 10             	movzbl (%eax),%edx
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	74 15                	je     800a14 <strchr+0x26>
		if (*s == c)
  8009ff:	38 ca                	cmp    %cl,%dl
  800a01:	75 07                	jne    800a0a <strchr+0x1c>
  800a03:	eb 14                	jmp    800a19 <strchr+0x2b>
  800a05:	38 ca                	cmp    %cl,%dl
  800a07:	90                   	nop
  800a08:	74 0f                	je     800a19 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 f1                	jne    800a05 <strchr+0x17>
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	0f b6 10             	movzbl (%eax),%edx
  800a28:	84 d2                	test   %dl,%dl
  800a2a:	74 18                	je     800a44 <strfind+0x29>
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	75 0a                	jne    800a3a <strfind+0x1f>
  800a30:	eb 12                	jmp    800a44 <strfind+0x29>
  800a32:	38 ca                	cmp    %cl,%dl
  800a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a38:	74 0a                	je     800a44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	84 d2                	test   %dl,%dl
  800a42:	75 ee                	jne    800a32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	53                   	push   %ebx
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a53:	89 da                	mov    %ebx,%edx
  800a55:	83 ea 01             	sub    $0x1,%edx
  800a58:	78 0d                	js     800a67 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  800a5a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a5c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a5e:	88 0a                	mov    %cl,(%edx)
  800a60:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a63:	39 da                	cmp    %ebx,%edx
  800a65:	75 f7                	jne    800a5e <memset+0x18>
		*p++ = c;

	return v;
}
  800a67:	5b                   	pop    %ebx
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	74 13                	je     800a8f <memcpy+0x25>
  800a7c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800a81:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a85:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a88:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a8b:	39 da                	cmp    %ebx,%edx
  800a8d:	75 f2                	jne    800a81 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800aa2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800aa4:	39 c6                	cmp    %eax,%esi
  800aa6:	72 0b                	jb     800ab3 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800aa8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800aad:	85 db                	test   %ebx,%ebx
  800aaf:	75 2e                	jne    800adf <memmove+0x4c>
  800ab1:	eb 3a                	jmp    800aed <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab3:	01 df                	add    %ebx,%edi
  800ab5:	39 f8                	cmp    %edi,%eax
  800ab7:	73 ef                	jae    800aa8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	90                   	nop
  800abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ac0:	74 2b                	je     800aed <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800ac2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800aca:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800acf:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800ad3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800ad6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800ad9:	85 c9                	test   %ecx,%ecx
  800adb:	75 ed                	jne    800aca <memmove+0x37>
  800add:	eb 0e                	jmp    800aed <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800adf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ae3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ae6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800ae9:	39 d3                	cmp    %edx,%ebx
  800aeb:	75 f2                	jne    800adf <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 75 08             	mov    0x8(%ebp),%esi
  800afb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b01:	85 c9                	test   %ecx,%ecx
  800b03:	74 36                	je     800b3b <memcmp+0x49>
		if (*s1 != *s2)
  800b05:	0f b6 06             	movzbl (%esi),%eax
  800b08:	0f b6 1f             	movzbl (%edi),%ebx
  800b0b:	38 d8                	cmp    %bl,%al
  800b0d:	74 20                	je     800b2f <memcmp+0x3d>
  800b0f:	eb 14                	jmp    800b25 <memcmp+0x33>
  800b11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b1b:	83 c2 01             	add    $0x1,%edx
  800b1e:	83 e9 01             	sub    $0x1,%ecx
  800b21:	38 d8                	cmp    %bl,%al
  800b23:	74 12                	je     800b37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b25:	0f b6 c0             	movzbl %al,%eax
  800b28:	0f b6 db             	movzbl %bl,%ebx
  800b2b:	29 d8                	sub    %ebx,%eax
  800b2d:	eb 11                	jmp    800b40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	83 e9 01             	sub    $0x1,%ecx
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	85 c9                	test   %ecx,%ecx
  800b39:	75 d6                	jne    800b11 <memcmp+0x1f>
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 15                	jae    800b69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b58:	38 08                	cmp    %cl,(%eax)
  800b5a:	75 06                	jne    800b62 <memfind+0x1d>
  800b5c:	eb 0b                	jmp    800b69 <memfind+0x24>
  800b5e:	38 08                	cmp    %cl,(%eax)
  800b60:	74 07                	je     800b69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	39 c2                	cmp    %eax,%edx
  800b67:	77 f5                	ja     800b5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 04             	sub    $0x4,%esp
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 02             	movzbl (%edx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 04                	je     800b85 <strtol+0x1a>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	75 0e                	jne    800b93 <strtol+0x28>
		s++;
  800b85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b88:	0f b6 02             	movzbl (%edx),%eax
  800b8b:	3c 20                	cmp    $0x20,%al
  800b8d:	74 f6                	je     800b85 <strtol+0x1a>
  800b8f:	3c 09                	cmp    $0x9,%al
  800b91:	74 f2                	je     800b85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b93:	3c 2b                	cmp    $0x2b,%al
  800b95:	75 0c                	jne    800ba3 <strtol+0x38>
		s++;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ba1:	eb 15                	jmp    800bb8 <strtol+0x4d>
	else if (*s == '-')
  800ba3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	75 0a                	jne    800bb8 <strtol+0x4d>
		s++, neg = 1;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb8:	85 db                	test   %ebx,%ebx
  800bba:	0f 94 c0             	sete   %al
  800bbd:	74 05                	je     800bc4 <strtol+0x59>
  800bbf:	83 fb 10             	cmp    $0x10,%ebx
  800bc2:	75 18                	jne    800bdc <strtol+0x71>
  800bc4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc7:	75 13                	jne    800bdc <strtol+0x71>
  800bc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	75 0a                	jne    800bdc <strtol+0x71>
		s += 2, base = 16;
  800bd2:	83 c2 02             	add    $0x2,%edx
  800bd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bda:	eb 15                	jmp    800bf1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdc:	84 c0                	test   %al,%al
  800bde:	66 90                	xchg   %ax,%ax
  800be0:	74 0f                	je     800bf1 <strtol+0x86>
  800be2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800be7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bea:	75 05                	jne    800bf1 <strtol+0x86>
		s++, base = 8;
  800bec:	83 c2 01             	add    $0x1,%edx
  800bef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf8:	0f b6 0a             	movzbl (%edx),%ecx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c00:	80 fb 09             	cmp    $0x9,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xa2>
			dig = *s - '0';
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 30             	sub    $0x30,%ecx
  800c0b:	eb 1e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 57             	sub    $0x57,%ecx
  800c1b:	eb 0e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 15                	ja     800c3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2b:	39 f1                	cmp    %esi,%ecx
  800c2d:	7d 0b                	jge    800c3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c2f:	83 c2 01             	add    $0x1,%edx
  800c32:	0f af c6             	imul   %esi,%eax
  800c35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c38:	eb be                	jmp    800bf8 <strtol+0x8d>
  800c3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c40:	74 05                	je     800c47 <strtol+0xdc>
		*endptr = (char *) s;
  800c42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c47:	89 ca                	mov    %ecx,%edx
  800c49:	f7 da                	neg    %edx
  800c4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c4f:	0f 45 c2             	cmovne %edx,%eax
}
  800c52:	83 c4 04             	add    $0x4,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
	...

00800c5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	89 1c 24             	mov    %ebx,(%esp)
  800c65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c69:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	89 c3                	mov    %eax,%ebx
  800c7a:	89 c7                	mov    %eax,%edi
  800c7c:	89 c6                	mov    %eax,%esi
  800c7e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800c80:	8b 1c 24             	mov    (%esp),%ebx
  800c83:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c87:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c8b:	89 ec                	mov    %ebp,%esp
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	89 1c 24             	mov    %ebx,(%esp)
  800c98:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c9c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 01 00 00 00       	mov    $0x1,%eax
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	89 d3                	mov    %edx,%ebx
  800cae:	89 d7                	mov    %edx,%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800cb4:	8b 1c 24             	mov    (%esp),%ebx
  800cb7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cbb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cbf:	89 ec                	mov    %ebp,%esp
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	89 1c 24             	mov    %ebx,(%esp)
  800ccc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 cb                	mov    %ecx,%ebx
  800ce3:	89 cf                	mov    %ecx,%edi
  800ce5:	89 ce                	mov    %ecx,%esi
  800ce7:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800ce9:	8b 1c 24             	mov    (%esp),%ebx
  800cec:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cf0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf4:	89 ec                	mov    %ebp,%esp
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	89 1c 24             	mov    %ebx,(%esp)
  800d01:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d05:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	89 d3                	mov    %edx,%ebx
  800d17:	89 d7                	mov    %edx,%edi
  800d19:	89 d6                	mov    %edx,%esi
  800d1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800d1d:	8b 1c 24             	mov    (%esp),%ebx
  800d20:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d24:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d28:	89 ec                	mov    %ebp,%esp
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_yield>:

void
sys_yield(void)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	89 1c 24             	mov    %ebx,(%esp)
  800d35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d39:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d42:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d47:	89 d1                	mov    %edx,%ecx
  800d49:	89 d3                	mov    %edx,%ebx
  800d4b:	89 d7                	mov    %edx,%edi
  800d4d:	89 d6                	mov    %edx,%esi
  800d4f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800d51:	8b 1c 24             	mov    (%esp),%ebx
  800d54:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d58:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d5c:	89 ec                	mov    %ebp,%esp
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	89 1c 24             	mov    %ebx,(%esp)
  800d69:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	be 00 00 00 00       	mov    $0x0,%esi
  800d76:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 f7                	mov    %esi,%edi
  800d86:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800d88:	8b 1c 24             	mov    (%esp),%ebx
  800d8b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d8f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d93:	89 ec                	mov    %ebp,%esp
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	89 1c 24             	mov    %ebx,(%esp)
  800da0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800da4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da8:	b8 05 00 00 00       	mov    $0x5,%eax
  800dad:	8b 75 18             	mov    0x18(%ebp),%esi
  800db0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dbe:	8b 1c 24             	mov    (%esp),%ebx
  800dc1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dc5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dc9:	89 ec                	mov    %ebp,%esp
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	89 1c 24             	mov    %ebx,(%esp)
  800dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dda:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de3:	b8 06 00 00 00       	mov    $0x6,%eax
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 df                	mov    %ebx,%edi
  800df0:	89 de                	mov    %ebx,%esi
  800df2:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800df4:	8b 1c 24             	mov    (%esp),%ebx
  800df7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dfb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dff:	89 ec                	mov    %ebp,%esp
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	89 1c 24             	mov    %ebx,(%esp)
  800e0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e10:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e19:	b8 08 00 00 00       	mov    $0x8,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	89 df                	mov    %ebx,%edi
  800e26:	89 de                	mov    %ebx,%esi
  800e28:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800e2a:	8b 1c 24             	mov    (%esp),%ebx
  800e2d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e31:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e35:	89 ec                	mov    %ebp,%esp
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	89 1c 24             	mov    %ebx,(%esp)
  800e42:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e46:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e57:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5a:	89 df                	mov    %ebx,%edi
  800e5c:	89 de                	mov    %ebx,%esi
  800e5e:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800e60:	8b 1c 24             	mov    (%esp),%ebx
  800e63:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e67:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e6b:	89 ec                	mov    %ebp,%esp
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 0c             	sub    $0xc,%esp
  800e75:	89 1c 24             	mov    %ebx,(%esp)
  800e78:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 df                	mov    %ebx,%edi
  800e92:	89 de                	mov    %ebx,%esi
  800e94:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e96:	8b 1c 24             	mov    (%esp),%ebx
  800e99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ea1:	89 ec                	mov    %ebp,%esp
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	89 1c 24             	mov    %ebx,(%esp)
  800eae:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eb2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	be 00 00 00 00       	mov    $0x0,%esi
  800ebb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800ece:	8b 1c 24             	mov    (%esp),%ebx
  800ed1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ed5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ed9:	89 ec                	mov    %ebp,%esp
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	89 1c 24             	mov    %ebx,(%esp)
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ef8:	8b 55 08             	mov    0x8(%ebp),%edx
  800efb:	89 cb                	mov    %ecx,%ebx
  800efd:	89 cf                	mov    %ecx,%edi
  800eff:	89 ce                	mov    %ecx,%esi
  800f01:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800f03:	8b 1c 24             	mov    (%esp),%ebx
  800f06:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f0a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f0e:	89 ec                	mov    %ebp,%esp
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    
	...

00800f14 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f1a:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800f21:	00 
  800f22:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  800f29:	00 
  800f2a:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  800f31:	e8 6e 04 00 00       	call   8013a4 <_panic>

00800f36 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	53                   	push   %ebx
  800f3a:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr;
	pte_t pte;

	// LAB 4: Your code here.
	addr = (void *) ((uint32_t) pn * PGSIZE);
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	c1 e3 0c             	shl    $0xc,%ebx
	pte = vpt[VPN(addr)];
  800f42:	89 da                	mov    %ebx,%edx
  800f44:	c1 ea 0c             	shr    $0xc,%edx
  800f47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((pte & PTE_W) > 0 || (pte & PTE_COW) > 0) 
  800f4e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f54:	0f 84 8c 00 00 00    	je     800fe6 <duppage+0xb0>
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800f5a:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800f61:	00 
  800f62:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f66:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f75:	e8 1d fe ff ff       	call   800d97 <sys_page_map>
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	79 20                	jns    800f9e <duppage+0x68>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  800f7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f82:	c7 44 24 08 3c 1a 80 	movl   $0x801a3c,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  800f99:	e8 06 04 00 00       	call   8013a4 <_panic>
	
		if ((r = sys_page_map (0, addr, 0, addr, PTE_U|PTE_P|PTE_COW)) < 0)
  800f9e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fa5:	00 
  800fa6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800faa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb1:	00 
  800fb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fb6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fbd:	e8 d5 fd ff ff       	call   800d97 <sys_page_map>
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	79 64                	jns    80102a <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  800fc6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fca:	c7 44 24 08 68 1a 80 	movl   $0x801a68,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  800fe1:	e8 be 03 00 00       	call   8013a4 <_panic>
	} 
	else 
	{
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800fe6:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  800fed:	00 
  800fee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ff2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ffa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801001:	e8 91 fd ff ff       	call   800d97 <sys_page_map>
  801006:	85 c0                	test   %eax,%eax
  801008:	79 20                	jns    80102a <duppage+0xf4>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  80100a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80100e:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  801015:	00 
  801016:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  80101d:	00 
  80101e:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  801025:	e8 7a 03 00 00       	call   8013a4 <_panic>
	}	
	//panic("duppage not implemented");
	return 0;
}
  80102a:	b8 00 00 00 00       	mov    $0x0,%eax
  80102f:	83 c4 24             	add    $0x24,%esp
  801032:	5b                   	pop    %ebx
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	53                   	push   %ebx
  801039:	83 ec 24             	sub    $0x24,%esp
	// LAB 4: Your code here.
	envid_t envid;  
	uint8_t *addr;  
	int r;  
	extern unsigned char end[];  
	set_pgfault_handler(pgfault);  
  80103c:	c7 04 24 6a 11 80 00 	movl   $0x80116a,(%esp)
  801043:	e8 c0 03 00 00       	call   801408 <set_pgfault_handler>
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801048:	bb 07 00 00 00       	mov    $0x7,%ebx
  80104d:	89 d8                	mov    %ebx,%eax
  80104f:	cd 30                	int    $0x30
  801051:	89 c3                	mov    %eax,%ebx
	envid = sys_exofork();  
	if (envid < 0)  
  801053:	85 c0                	test   %eax,%eax
  801055:	79 20                	jns    801077 <fork+0x42>
		panic("sys_exofork: %e", envid);  
  801057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80105b:	c7 44 24 08 e5 19 80 	movl   $0x8019e5,0x8(%esp)
  801062:	00 
  801063:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  80106a:	00 
  80106b:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  801072:	e8 2d 03 00 00       	call   8013a4 <_panic>
	//child  
	if (envid == 0) {  
  801077:	85 c0                	test   %eax,%eax
  801079:	75 20                	jne    80109b <fork+0x66>
		//can't set pgh here ,must before child run  
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
  80107b:	e8 78 fc ff ff       	call   800cf8 <sys_getenvid>
  801080:	25 ff 03 00 00       	and    $0x3ff,%eax
  801085:	89 c2                	mov    %eax,%edx
  801087:	c1 e2 07             	shl    $0x7,%edx
  80108a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801091:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;  
  801096:	e9 c7 00 00 00       	jmp    801162 <fork+0x12d>
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  80109b:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8010a2:	b8 14 20 80 00       	mov    $0x802014,%eax
  8010a7:	3d 00 00 80 00       	cmp    $0x800000,%eax
  8010ac:	76 23                	jbe    8010d1 <fork+0x9c>
  8010ae:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, VPN(addr));  
  8010b3:	c1 ea 0c             	shr    $0xc,%edx
  8010b6:	89 d8                	mov    %ebx,%eax
  8010b8:	e8 79 fe ff ff       	call   800f36 <duppage>
		//because when child run ,it will make a page fault  
		env = &envs[ENVX(sys_getenvid())];  
		return 0;  
	}  
	//parent  
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)  
  8010bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010c0:	81 c2 00 10 00 00    	add    $0x1000,%edx
  8010c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010c9:	81 fa 14 20 80 00    	cmp    $0x802014,%edx
  8010cf:	72 e2                	jb     8010b3 <fork+0x7e>
		duppage(envid, VPN(addr));  
	duppage(envid, VPN(&addr));  
  8010d1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010d4:	c1 ea 0c             	shr    $0xc,%edx
  8010d7:	89 d8                	mov    %ebx,%eax
  8010d9:	e8 58 fe ff ff       	call   800f36 <duppage>
	//copy user exception stack  

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)  
  8010de:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010e5:	00 
  8010e6:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010ed:	ee 
  8010ee:	89 1c 24             	mov    %ebx,(%esp)
  8010f1:	e8 6a fc ff ff       	call   800d60 <sys_page_alloc>
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	79 20                	jns    80111a <fork+0xe5>
		panic("sys_page_alloc: %e", r);  
  8010fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010fe:	c7 44 24 08 f5 19 80 	movl   $0x8019f5,0x8(%esp)
  801105:	00 
  801106:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  80110d:	00 
  80110e:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  801115:	e8 8a 02 00 00       	call   8013a4 <_panic>
	r = sys_env_set_pgfault_upcall(envid, env->env_pgfault_upcall);  
  80111a:	a1 08 20 80 00       	mov    0x802008,%eax
  80111f:	8b 40 64             	mov    0x64(%eax),%eax
  801122:	89 44 24 04          	mov    %eax,0x4(%esp)
  801126:	89 1c 24             	mov    %ebx,(%esp)
  801129:	e8 41 fd ff ff       	call   800e6f <sys_env_set_pgfault_upcall>

	//set child status  

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)  
  80112e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801135:	00 
  801136:	89 1c 24             	mov    %ebx,(%esp)
  801139:	e8 c5 fc ff ff       	call   800e03 <sys_env_set_status>
  80113e:	85 c0                	test   %eax,%eax
  801140:	79 20                	jns    801162 <fork+0x12d>
		panic("sys_env_set_status: %e", r);  
  801142:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801146:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  80114d:	00 
  80114e:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801155:	00 
  801156:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  80115d:	e8 42 02 00 00       	call   8013a4 <_panic>
	return envid;  
	//panic("fork not implemented");
}
  801162:	89 d8                	mov    %ebx,%eax
  801164:	83 c4 24             	add    $0x24,%esp
  801167:	5b                   	pop    %ebx
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	53                   	push   %ebx
  80116e:	83 ec 24             	sub    $0x24,%esp
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801174:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801176:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80117a:	75 1c                	jne    801198 <pgfault+0x2e>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if (!(err&FEC_WR))   
		panic("Page fault: not a write access.");  
  80117c:	c7 44 24 08 c0 1a 80 	movl   $0x801ac0,0x8(%esp)
  801183:	00 
  801184:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80118b:	00 
  80118c:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  801193:	e8 0c 02 00 00       	call   8013a4 <_panic>
	
	if ( !(vpt[VPN(addr)]&PTE_COW) )  
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	c1 e8 0c             	shr    $0xc,%eax
  80119d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a4:	f6 c4 08             	test   $0x8,%ah
  8011a7:	75 1c                	jne    8011c5 <pgfault+0x5b>
		panic("Page fualt: not a COW page.");  
  8011a9:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  8011b0:	00 
  8011b1:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8011b8:	00 
  8011b9:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  8011c0:	e8 df 01 00 00       	call   8013a4 <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	
	// LAB 4: Your code here.
	
	if ((r=sys_page_alloc(0, PFTEMP, PTE_U|PTE_W|PTE_P)) <0)  
  8011c5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011dc:	e8 7f fb ff ff       	call   800d60 <sys_page_alloc>
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	79 20                	jns    801205 <pgfault+0x9b>
		panic("Page fault: sys_page_alloc err %e.", r);  
  8011e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e9:	c7 44 24 08 e0 1a 80 	movl   $0x801ae0,0x8(%esp)
  8011f0:	00 
  8011f1:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8011f8:	00 
  8011f9:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  801200:	e8 9f 01 00 00       	call   8013a4 <_panic>
	
	memmove(PFTEMP, (void *)PTE_ADDR(addr), PGSIZE);  
  801205:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80120b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801212:	00 
  801213:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801217:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80121e:	e8 70 f8 ff ff       	call   800a93 <memmove>
	
	
	if ((r=sys_page_map(0, PFTEMP, 0, (void *)PTE_ADDR(addr), PTE_U|PTE_W|PTE_P))<0)  
  801223:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80122a:	00 
  80122b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80122f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801236:	00 
  801237:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80123e:	00 
  80123f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801246:	e8 4c fb ff ff       	call   800d97 <sys_page_map>
  80124b:	85 c0                	test   %eax,%eax
  80124d:	79 20                	jns    80126f <pgfault+0x105>
		panic("Page fault: sys_page_map err %e.", r);  
  80124f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801253:	c7 44 24 08 04 1b 80 	movl   $0x801b04,0x8(%esp)
  80125a:	00 
  80125b:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801262:	00 
  801263:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  80126a:	e8 35 01 00 00       	call   8013a4 <_panic>
	if ((r=sys_page_unmap(0, PFTEMP))<0)  
  80126f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801276:	00 
  801277:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80127e:	e8 4a fb ff ff       	call   800dcd <sys_page_unmap>
  801283:	85 c0                	test   %eax,%eax
  801285:	79 20                	jns    8012a7 <pgfault+0x13d>
		panic("Page fault: sys_page_unmap err %e.", r);  
  801287:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128b:	c7 44 24 08 28 1b 80 	movl   $0x801b28,0x8(%esp)
  801292:	00 
  801293:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  80129a:	00 
  80129b:	c7 04 24 da 19 80 00 	movl   $0x8019da,(%esp)
  8012a2:	e8 fd 00 00 00       	call   8013a4 <_panic>
	
	//panic("pgfault not implemented");
}
  8012a7:	83 c4 24             	add    $0x24,%esp
  8012aa:	5b                   	pop    %ebx
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    
  8012ad:	00 00                	add    %al,(%eax)
	...

008012b0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	57                   	push   %edi
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
  8012b6:	83 ec 1c             	sub    $0x1c,%esp
  8012b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");

	int r;
	while ((r = sys_ipc_try_send (to_env, val, pg != NULL ? pg : (void *) UTOP, perm)) < 0) 
  8012c2:	eb 2a                	jmp    8012ee <ipc_send+0x3e>
	{
		//cprintf("bug is not in sys_ipc_try_send\n");		//for debug
		if (r != -E_IPC_NOT_RECV)
  8012c4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012c7:	74 20                	je     8012e9 <ipc_send+0x39>
			panic ("ipc_send: send message error %e", r);
  8012c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012cd:	c7 44 24 08 4c 1b 80 	movl   $0x801b4c,0x8(%esp)
  8012d4:	00 
  8012d5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8012dc:	00 
  8012dd:	c7 04 24 6c 1b 80 00 	movl   $0x801b6c,(%esp)
  8012e4:	e8 bb 00 00 00       	call   8013a4 <_panic>
		sys_yield ();
  8012e9:	e8 3e fa ff ff       	call   800d2c <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");

	int r;
	while ((r = sys_ipc_try_send (to_env, val, pg != NULL ? pg : (void *) UTOP, perm)) < 0) 
  8012ee:	85 db                	test   %ebx,%ebx
  8012f0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8012f5:	0f 45 c3             	cmovne %ebx,%eax
  8012f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801303:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801307:	89 34 24             	mov    %esi,(%esp)
  80130a:	e8 96 fb ff ff       	call   800ea5 <sys_ipc_try_send>
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 b1                	js     8012c4 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic ("ipc_send: send message error %e", r);
		sys_yield ();
	}

}
  801313:	83 c4 1c             	add    $0x1c,%esp
  801316:	5b                   	pop    %ebx
  801317:	5e                   	pop    %esi
  801318:	5f                   	pop    %edi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    

0080131b <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
uint32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	83 ec 28             	sub    $0x28,%esp
  801321:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801324:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801327:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80132a:	8b 75 08             	mov    0x8(%ebp),%esi
  80132d:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	
	int r;
	if (pg != NULL)
  801330:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801334:	74 10                	je     801346 <ipc_recv+0x2b>
	    r = sys_ipc_recv ((void *) UTOP);
  801336:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80133d:	e8 9b fb ff ff       	call   800edd <sys_ipc_recv>
  801342:	89 c3                	mov    %eax,%ebx
  801344:	eb 0e                	jmp    801354 <ipc_recv+0x39>
	else
	    r = sys_ipc_recv (pg);
  801346:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80134d:	e8 8b fb ff ff       	call   800edd <sys_ipc_recv>
  801352:	89 c3                	mov    %eax,%ebx
	struct Env *curenv = (struct Env *) envs + ENVX (sys_getenvid ());
  801354:	e8 9f f9 ff ff       	call   800cf8 <sys_getenvid>
  801359:	25 ff 03 00 00       	and    $0x3ff,%eax
  80135e:	89 c2                	mov    %eax,%edx
  801360:	c1 e2 07             	shl    $0x7,%edx
  801363:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
	if (from_env_store != NULL)
  80136a:	85 f6                	test   %esi,%esi
  80136c:	74 0e                	je     80137c <ipc_recv+0x61>
		*from_env_store = r < 0 ? 0 : curenv->env_ipc_from;
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
  801373:	85 db                	test   %ebx,%ebx
  801375:	78 03                	js     80137a <ipc_recv+0x5f>
  801377:	8b 42 74             	mov    0x74(%edx),%eax
  80137a:	89 06                	mov    %eax,(%esi)
	if (perm_store != NULL)
  80137c:	85 ff                	test   %edi,%edi
  80137e:	74 0e                	je     80138e <ipc_recv+0x73>
		*perm_store = r < 0 ? 0 : curenv->env_ipc_perm;
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
  801385:	85 db                	test   %ebx,%ebx
  801387:	78 03                	js     80138c <ipc_recv+0x71>
  801389:	8b 42 78             	mov    0x78(%edx),%eax
  80138c:	89 07                	mov    %eax,(%edi)
	if (r < 0)
		return r;
  80138e:	89 d8                	mov    %ebx,%eax
	struct Env *curenv = (struct Env *) envs + ENVX (sys_getenvid ());
	if (from_env_store != NULL)
		*from_env_store = r < 0 ? 0 : curenv->env_ipc_from;
	if (perm_store != NULL)
		*perm_store = r < 0 ? 0 : curenv->env_ipc_perm;
	if (r < 0)
  801390:	85 db                	test   %ebx,%ebx
  801392:	78 03                	js     801397 <ipc_recv+0x7c>
		return r;
	return curenv->env_ipc_value;
  801394:	8b 42 70             	mov    0x70(%edx),%eax
}
  801397:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80139a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80139d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013a0:	89 ec                	mov    %ebp,%esp
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8013aa:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	74 10                	je     8013c3 <_panic+0x1f>
		cprintf("%s: ", argv0);
  8013b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b7:	c7 04 24 76 1b 80 00 	movl   $0x801b76,(%esp)
  8013be:	e8 52 ee ff ff       	call   800215 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d1:	a1 00 20 80 00       	mov    0x802000,%eax
  8013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013da:	c7 04 24 7b 1b 80 00 	movl   $0x801b7b,(%esp)
  8013e1:	e8 2f ee ff ff       	call   800215 <cprintf>
	vcprintf(fmt, ap);
  8013e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8013e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8013f0:	89 04 24             	mov    %eax,(%esp)
  8013f3:	e8 bc ed ff ff       	call   8001b4 <vcprintf>
	cprintf("\n");
  8013f8:	c7 04 24 34 17 80 00 	movl   $0x801734,(%esp)
  8013ff:	e8 11 ee ff ff       	call   800215 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801404:	cc                   	int3   
  801405:	eb fd                	jmp    801404 <_panic+0x60>
	...

00801408 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80140e:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801415:	75 54                	jne    80146b <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801417:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80141e:	00 
  80141f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801426:	ee 
  801427:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80142e:	e8 2d f9 ff ff       	call   800d60 <sys_page_alloc>
  801433:	85 c0                	test   %eax,%eax
  801435:	79 20                	jns    801457 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  801437:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143b:	c7 44 24 08 97 1b 80 	movl   $0x801b97,0x8(%esp)
  801442:	00 
  801443:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80144a:	00 
  80144b:	c7 04 24 af 1b 80 00 	movl   $0x801baf,(%esp)
  801452:	e8 4d ff ff ff       	call   8013a4 <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  801457:	c7 44 24 04 78 14 80 	movl   $0x801478,0x4(%esp)
  80145e:	00 
  80145f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801466:	e8 04 fa ff ff       	call   800e6f <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	a3 10 20 80 00       	mov    %eax,0x802010
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    
  801475:	00 00                	add    %al,(%eax)
	...

00801478 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801478:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801479:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  80147e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801480:	83 c4 04             	add    $0x4,%esp
	// Hints:
	//   What registers are available for intermediate calculations?
	//
	// LAB 4: Your code here.
	
	movl	0x30(%esp), %eax
  801483:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl	$0x4, %eax
  801487:	83 e8 04             	sub    $0x4,%eax
	movl	%eax, 0x30(%esp)
  80148a:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl	0x28(%esp), %ebx
  80148e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl	%ebx, (%eax)
  801492:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.
	// LAB 4: Your code here.

	addl	$0x8, %esp
  801494:	83 c4 08             	add    $0x8,%esp
	popal
  801497:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.

	addl	$0x4, %esp
  801498:	83 c4 04             	add    $0x4,%esp
	popfl
  80149b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	pop	%esp
  80149c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80149d:	c3                   	ret    
	...

008014a0 <__udivdi3>:
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	57                   	push   %edi
  8014a4:	56                   	push   %esi
  8014a5:	83 ec 10             	sub    $0x10,%esp
  8014a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8014b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8014b9:	75 35                	jne    8014f0 <__udivdi3+0x50>
  8014bb:	39 fe                	cmp    %edi,%esi
  8014bd:	77 61                	ja     801520 <__udivdi3+0x80>
  8014bf:	85 f6                	test   %esi,%esi
  8014c1:	75 0b                	jne    8014ce <__udivdi3+0x2e>
  8014c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014c8:	31 d2                	xor    %edx,%edx
  8014ca:	f7 f6                	div    %esi
  8014cc:	89 c6                	mov    %eax,%esi
  8014ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8014d1:	31 d2                	xor    %edx,%edx
  8014d3:	89 f8                	mov    %edi,%eax
  8014d5:	f7 f6                	div    %esi
  8014d7:	89 c7                	mov    %eax,%edi
  8014d9:	89 c8                	mov    %ecx,%eax
  8014db:	f7 f6                	div    %esi
  8014dd:	89 c1                	mov    %eax,%ecx
  8014df:	89 fa                	mov    %edi,%edx
  8014e1:	89 c8                	mov    %ecx,%eax
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	5e                   	pop    %esi
  8014e7:	5f                   	pop    %edi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    
  8014ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014f0:	39 f8                	cmp    %edi,%eax
  8014f2:	77 1c                	ja     801510 <__udivdi3+0x70>
  8014f4:	0f bd d0             	bsr    %eax,%edx
  8014f7:	83 f2 1f             	xor    $0x1f,%edx
  8014fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014fd:	75 39                	jne    801538 <__udivdi3+0x98>
  8014ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801502:	0f 86 a0 00 00 00    	jbe    8015a8 <__udivdi3+0x108>
  801508:	39 f8                	cmp    %edi,%eax
  80150a:	0f 82 98 00 00 00    	jb     8015a8 <__udivdi3+0x108>
  801510:	31 ff                	xor    %edi,%edi
  801512:	31 c9                	xor    %ecx,%ecx
  801514:	89 c8                	mov    %ecx,%eax
  801516:	89 fa                	mov    %edi,%edx
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	5e                   	pop    %esi
  80151c:	5f                   	pop    %edi
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    
  80151f:	90                   	nop
  801520:	89 d1                	mov    %edx,%ecx
  801522:	89 fa                	mov    %edi,%edx
  801524:	89 c8                	mov    %ecx,%eax
  801526:	31 ff                	xor    %edi,%edi
  801528:	f7 f6                	div    %esi
  80152a:	89 c1                	mov    %eax,%ecx
  80152c:	89 fa                	mov    %edi,%edx
  80152e:	89 c8                	mov    %ecx,%eax
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	5e                   	pop    %esi
  801534:	5f                   	pop    %edi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    
  801537:	90                   	nop
  801538:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80153c:	89 f2                	mov    %esi,%edx
  80153e:	d3 e0                	shl    %cl,%eax
  801540:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801543:	b8 20 00 00 00       	mov    $0x20,%eax
  801548:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80154b:	89 c1                	mov    %eax,%ecx
  80154d:	d3 ea                	shr    %cl,%edx
  80154f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801553:	0b 55 ec             	or     -0x14(%ebp),%edx
  801556:	d3 e6                	shl    %cl,%esi
  801558:	89 c1                	mov    %eax,%ecx
  80155a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80155d:	89 fe                	mov    %edi,%esi
  80155f:	d3 ee                	shr    %cl,%esi
  801561:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801565:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801568:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80156b:	d3 e7                	shl    %cl,%edi
  80156d:	89 c1                	mov    %eax,%ecx
  80156f:	d3 ea                	shr    %cl,%edx
  801571:	09 d7                	or     %edx,%edi
  801573:	89 f2                	mov    %esi,%edx
  801575:	89 f8                	mov    %edi,%eax
  801577:	f7 75 ec             	divl   -0x14(%ebp)
  80157a:	89 d6                	mov    %edx,%esi
  80157c:	89 c7                	mov    %eax,%edi
  80157e:	f7 65 e8             	mull   -0x18(%ebp)
  801581:	39 d6                	cmp    %edx,%esi
  801583:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801586:	72 30                	jb     8015b8 <__udivdi3+0x118>
  801588:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80158b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80158f:	d3 e2                	shl    %cl,%edx
  801591:	39 c2                	cmp    %eax,%edx
  801593:	73 05                	jae    80159a <__udivdi3+0xfa>
  801595:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801598:	74 1e                	je     8015b8 <__udivdi3+0x118>
  80159a:	89 f9                	mov    %edi,%ecx
  80159c:	31 ff                	xor    %edi,%edi
  80159e:	e9 71 ff ff ff       	jmp    801514 <__udivdi3+0x74>
  8015a3:	90                   	nop
  8015a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	31 ff                	xor    %edi,%edi
  8015aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8015af:	e9 60 ff ff ff       	jmp    801514 <__udivdi3+0x74>
  8015b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8015bb:	31 ff                	xor    %edi,%edi
  8015bd:	89 c8                	mov    %ecx,%eax
  8015bf:	89 fa                	mov    %edi,%edx
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	5e                   	pop    %esi
  8015c5:	5f                   	pop    %edi
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    
	...

008015d0 <__umoddi3>:
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	57                   	push   %edi
  8015d4:	56                   	push   %esi
  8015d5:	83 ec 20             	sub    $0x20,%esp
  8015d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8015db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015e4:	85 d2                	test   %edx,%edx
  8015e6:	89 c8                	mov    %ecx,%eax
  8015e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8015eb:	75 13                	jne    801600 <__umoddi3+0x30>
  8015ed:	39 f7                	cmp    %esi,%edi
  8015ef:	76 3f                	jbe    801630 <__umoddi3+0x60>
  8015f1:	89 f2                	mov    %esi,%edx
  8015f3:	f7 f7                	div    %edi
  8015f5:	89 d0                	mov    %edx,%eax
  8015f7:	31 d2                	xor    %edx,%edx
  8015f9:	83 c4 20             	add    $0x20,%esp
  8015fc:	5e                   	pop    %esi
  8015fd:	5f                   	pop    %edi
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    
  801600:	39 f2                	cmp    %esi,%edx
  801602:	77 4c                	ja     801650 <__umoddi3+0x80>
  801604:	0f bd ca             	bsr    %edx,%ecx
  801607:	83 f1 1f             	xor    $0x1f,%ecx
  80160a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80160d:	75 51                	jne    801660 <__umoddi3+0x90>
  80160f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801612:	0f 87 e0 00 00 00    	ja     8016f8 <__umoddi3+0x128>
  801618:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161b:	29 f8                	sub    %edi,%eax
  80161d:	19 d6                	sbb    %edx,%esi
  80161f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801622:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801625:	89 f2                	mov    %esi,%edx
  801627:	83 c4 20             	add    $0x20,%esp
  80162a:	5e                   	pop    %esi
  80162b:	5f                   	pop    %edi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    
  80162e:	66 90                	xchg   %ax,%ax
  801630:	85 ff                	test   %edi,%edi
  801632:	75 0b                	jne    80163f <__umoddi3+0x6f>
  801634:	b8 01 00 00 00       	mov    $0x1,%eax
  801639:	31 d2                	xor    %edx,%edx
  80163b:	f7 f7                	div    %edi
  80163d:	89 c7                	mov    %eax,%edi
  80163f:	89 f0                	mov    %esi,%eax
  801641:	31 d2                	xor    %edx,%edx
  801643:	f7 f7                	div    %edi
  801645:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801648:	f7 f7                	div    %edi
  80164a:	eb a9                	jmp    8015f5 <__umoddi3+0x25>
  80164c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801650:	89 c8                	mov    %ecx,%eax
  801652:	89 f2                	mov    %esi,%edx
  801654:	83 c4 20             	add    $0x20,%esp
  801657:	5e                   	pop    %esi
  801658:	5f                   	pop    %edi
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    
  80165b:	90                   	nop
  80165c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801660:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801664:	d3 e2                	shl    %cl,%edx
  801666:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801669:	ba 20 00 00 00       	mov    $0x20,%edx
  80166e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801671:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801674:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801678:	89 fa                	mov    %edi,%edx
  80167a:	d3 ea                	shr    %cl,%edx
  80167c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801680:	0b 55 f4             	or     -0xc(%ebp),%edx
  801683:	d3 e7                	shl    %cl,%edi
  801685:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801689:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80168c:	89 f2                	mov    %esi,%edx
  80168e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801691:	89 c7                	mov    %eax,%edi
  801693:	d3 ea                	shr    %cl,%edx
  801695:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801699:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	d3 e6                	shl    %cl,%esi
  8016a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016a4:	d3 ea                	shr    %cl,%edx
  8016a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016aa:	09 d6                	or     %edx,%esi
  8016ac:	89 f0                	mov    %esi,%eax
  8016ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8016b1:	d3 e7                	shl    %cl,%edi
  8016b3:	89 f2                	mov    %esi,%edx
  8016b5:	f7 75 f4             	divl   -0xc(%ebp)
  8016b8:	89 d6                	mov    %edx,%esi
  8016ba:	f7 65 e8             	mull   -0x18(%ebp)
  8016bd:	39 d6                	cmp    %edx,%esi
  8016bf:	72 2b                	jb     8016ec <__umoddi3+0x11c>
  8016c1:	39 c7                	cmp    %eax,%edi
  8016c3:	72 23                	jb     8016e8 <__umoddi3+0x118>
  8016c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016c9:	29 c7                	sub    %eax,%edi
  8016cb:	19 d6                	sbb    %edx,%esi
  8016cd:	89 f0                	mov    %esi,%eax
  8016cf:	89 f2                	mov    %esi,%edx
  8016d1:	d3 ef                	shr    %cl,%edi
  8016d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016d7:	d3 e0                	shl    %cl,%eax
  8016d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016dd:	09 f8                	or     %edi,%eax
  8016df:	d3 ea                	shr    %cl,%edx
  8016e1:	83 c4 20             	add    $0x20,%esp
  8016e4:	5e                   	pop    %esi
  8016e5:	5f                   	pop    %edi
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    
  8016e8:	39 d6                	cmp    %edx,%esi
  8016ea:	75 d9                	jne    8016c5 <__umoddi3+0xf5>
  8016ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8016ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8016f2:	eb d1                	jmp    8016c5 <__umoddi3+0xf5>
  8016f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016f8:	39 f2                	cmp    %esi,%edx
  8016fa:	0f 82 18 ff ff ff    	jb     801618 <__umoddi3+0x48>
  801700:	e9 1d ff ff ff       	jmp    801622 <__umoddi3+0x52>
