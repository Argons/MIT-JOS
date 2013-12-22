
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 c8 0f 80 00 	movl   $0x800fc8,(%esp)
  800041:	e8 ff 01 00 00       	call   800245 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	b8 01 00 00 00       	mov    $0x1,%eax
  80004b:	ba 20 20 80 00       	mov    $0x802020,%edx
  800050:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  800057:	74 04                	je     80005d <umain+0x29>
  800059:	b0 00                	mov    $0x0,%al
  80005b:	eb 06                	jmp    800063 <umain+0x2f>
  80005d:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800061:	74 20                	je     800083 <umain+0x4f>
			panic("bigarray[%d] isn't cleared!\n", i);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 44 10 80 	movl   $0x801044,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 61 10 80 00 	movl   $0x801061,(%esp)
  80007e:	e8 fd 00 00 00       	call   800180 <_panic>
umain(void)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 d0                	jne    80005d <umain+0x29>
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800092:	ba 20 20 80 00       	mov    $0x802020,%edx
  800097:	89 04 82             	mov    %eax,(%edx,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009a:	83 c0 01             	add    $0x1,%eax
  80009d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a2:	75 f3                	jne    800097 <umain+0x63>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a9:	ba 20 20 80 00       	mov    $0x802020,%edx
  8000ae:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000b5:	74 04                	je     8000bb <umain+0x87>
  8000b7:	b0 00                	mov    $0x0,%al
  8000b9:	eb 05                	jmp    8000c0 <umain+0x8c>
  8000bb:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  8000be:	74 20                	je     8000e0 <umain+0xac>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 e8 0f 80 	movl   $0x800fe8,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 61 10 80 00 	movl   $0x801061,(%esp)
  8000db:	e8 a0 00 00 00       	call   800180 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e0:	83 c0 01             	add    $0x1,%eax
  8000e3:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000e8:	75 d1                	jne    8000bb <umain+0x87>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ea:	c7 04 24 10 10 80 00 	movl   $0x801010,(%esp)
  8000f1:	e8 4f 01 00 00       	call   800245 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f6:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000fd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800100:	c7 44 24 08 70 10 80 	movl   $0x801070,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 61 10 80 00 	movl   $0x801061,(%esp)
  800117:	e8 64 00 00 00       	call   800180 <_panic>

0080011c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
  800122:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800125:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800128:	8b 75 08             	mov    0x8(%ebp),%esi
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
//	env = &envs[ENVX(sys_getenvid())];
        env = envs + ENVX(sys_getenvid ());
  80012e:	e8 f5 0b 00 00       	call   800d28 <sys_getenvid>
  800133:	25 ff 03 00 00       	and    $0x3ff,%eax
  800138:	6b c0 64             	imul   $0x64,%eax,%eax
  80013b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800140:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800145:	85 f6                	test   %esi,%esi
  800147:	7e 07                	jle    800150 <libmain+0x34>
		binaryname = argv[0];
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800154:	89 34 24             	mov    %esi,(%esp)
  800157:	e8 d8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80015c:	e8 0b 00 00 00       	call   80016c <exit>
}
  800161:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800164:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800167:	89 ec                	mov    %ebp,%esp
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    
	...

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800179:	e8 75 0b 00 00       	call   800cf3 <sys_env_destroy>
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800186:	a1 24 20 c0 00       	mov    0xc02024,%eax
  80018b:	85 c0                	test   %eax,%eax
  80018d:	74 10                	je     80019f <_panic+0x1f>
		cprintf("%s: ", argv0);
  80018f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800193:	c7 04 24 9e 10 80 00 	movl   $0x80109e,(%esp)
  80019a:	e8 a6 00 00 00       	call   800245 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80019f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ad:	a1 00 20 80 00       	mov    0x802000,%eax
  8001b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b6:	c7 04 24 a3 10 80 00 	movl   $0x8010a3,(%esp)
  8001bd:	e8 83 00 00 00       	call   800245 <cprintf>
	vcprintf(fmt, ap);
  8001c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8001c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 10 00 00 00       	call   8001e4 <vcprintf>
	cprintf("\n");
  8001d4:	c7 04 24 5f 10 80 00 	movl   $0x80105f,(%esp)
  8001db:	e8 65 00 00 00       	call   800245 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e0:	cc                   	int3   
  8001e1:	eb fd                	jmp    8001e0 <_panic+0x60>
	...

008001e4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f4:	00 00 00 
	b.cnt = 0;
  8001f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800201:	8b 45 0c             	mov    0xc(%ebp),%eax
  800204:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800208:	8b 45 08             	mov    0x8(%ebp),%eax
  80020b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800215:	89 44 24 04          	mov    %eax,0x4(%esp)
  800219:	c7 04 24 5f 02 80 00 	movl   $0x80025f,(%esp)
  800220:	e8 db 01 00 00       	call   800400 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800225:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	e8 4f 0a 00 00       	call   800c8c <sys_cputs>

	return b.cnt;
}
  80023d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80024b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	e8 87 ff ff ff       	call   8001e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	53                   	push   %ebx
  800263:	83 ec 14             	sub    $0x14,%esp
  800266:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800269:	8b 03                	mov    (%ebx),%eax
  80026b:	8b 55 08             	mov    0x8(%ebp),%edx
  80026e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800272:	83 c0 01             	add    $0x1,%eax
  800275:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800277:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027c:	75 19                	jne    800297 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80027e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800285:	00 
  800286:	8d 43 08             	lea    0x8(%ebx),%eax
  800289:	89 04 24             	mov    %eax,(%esp)
  80028c:	e8 fb 09 00 00       	call   800c8c <sys_cputs>
		b->idx = 0;
  800291:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	83 c4 14             	add    $0x14,%esp
  80029e:	5b                   	pop    %ebx
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    
	...

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002db:	39 d1                	cmp    %edx,%ecx
  8002dd:	72 15                	jb     8002f4 <printnum+0x44>
  8002df:	77 07                	ja     8002e8 <printnum+0x38>
  8002e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e4:	39 d0                	cmp    %edx,%eax
  8002e6:	76 0c                	jbe    8002f4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e8:	83 eb 01             	sub    $0x1,%ebx
  8002eb:	85 db                	test   %ebx,%ebx
  8002ed:	8d 76 00             	lea    0x0(%esi),%esi
  8002f0:	7f 61                	jg     800353 <printnum+0xa3>
  8002f2:	eb 70                	jmp    800364 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800307:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80030b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80030e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800311:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800314:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800329:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032d:	e8 2e 0a 00 00       	call   800d60 <__udivdi3>
  800332:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800335:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	89 54 24 04          	mov    %edx,0x4(%esp)
  800347:	89 f2                	mov    %esi,%edx
  800349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034c:	e8 5f ff ff ff       	call   8002b0 <printnum>
  800351:	eb 11                	jmp    800364 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800353:	89 74 24 04          	mov    %esi,0x4(%esp)
  800357:	89 3c 24             	mov    %edi,(%esp)
  80035a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035d:	83 eb 01             	sub    $0x1,%ebx
  800360:	85 db                	test   %ebx,%ebx
  800362:	7f ef                	jg     800353 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800364:	89 74 24 04          	mov    %esi,0x4(%esp)
  800368:	8b 74 24 04          	mov    0x4(%esp),%esi
  80036c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800373:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037a:	00 
  80037b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80037e:	89 14 24             	mov    %edx,(%esp)
  800381:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800384:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800388:	e8 03 0b 00 00       	call   800e90 <__umoddi3>
  80038d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800391:	0f be 80 bf 10 80 00 	movsbl 0x8010bf(%eax),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039e:	83 c4 4c             	add    $0x4c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a9:	83 fa 01             	cmp    $0x1,%edx
  8003ac:	7e 0f                	jle    8003bd <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  8003ae:	8b 10                	mov    (%eax),%edx
  8003b0:	83 c2 08             	add    $0x8,%edx
  8003b3:	89 10                	mov    %edx,(%eax)
  8003b5:	8b 42 f8             	mov    -0x8(%edx),%eax
  8003b8:	8b 52 fc             	mov    -0x4(%edx),%edx
  8003bb:	eb 24                	jmp    8003e1 <getuint+0x3b>
	else if (lflag)
  8003bd:	85 d2                	test   %edx,%edx
  8003bf:	74 11                	je     8003d2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003c1:	8b 10                	mov    (%eax),%edx
  8003c3:	83 c2 04             	add    $0x4,%edx
  8003c6:	89 10                	mov    %edx,(%eax)
  8003c8:	8b 42 fc             	mov    -0x4(%edx),%eax
  8003cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d0:	eb 0f                	jmp    8003e1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	83 c2 04             	add    $0x4,%edx
  8003d7:	89 10                	mov    %edx,(%eax)
  8003d9:	8b 42 fc             	mov    -0x4(%edx),%eax
  8003dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f2:	73 0a                	jae    8003fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f7:	88 0a                	mov    %cl,(%edx)
  8003f9:	83 c2 01             	add    $0x1,%edx
  8003fc:	89 10                	mov    %edx,(%eax)
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	83 ec 5c             	sub    $0x5c,%esp
  800409:	8b 7d 08             	mov    0x8(%ebp),%edi
  80040c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80040f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800412:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800419:	eb 11                	jmp    80042c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80041b:	85 c0                	test   %eax,%eax
  80041d:	0f 84 fd 03 00 00    	je     800820 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800423:	89 74 24 04          	mov    %esi,0x4(%esp)
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042c:	0f b6 03             	movzbl (%ebx),%eax
  80042f:	83 c3 01             	add    $0x1,%ebx
  800432:	83 f8 25             	cmp    $0x25,%eax
  800435:	75 e4                	jne    80041b <vprintfmt+0x1b>
  800437:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80043b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800442:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800449:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800450:	b9 00 00 00 00       	mov    $0x0,%ecx
  800455:	eb 06                	jmp    80045d <vprintfmt+0x5d>
  800457:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80045b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	0f b6 13             	movzbl (%ebx),%edx
  800460:	0f b6 c2             	movzbl %dl,%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	8d 43 01             	lea    0x1(%ebx),%eax
  800469:	83 ea 23             	sub    $0x23,%edx
  80046c:	80 fa 55             	cmp    $0x55,%dl
  80046f:	0f 87 8e 03 00 00    	ja     800803 <vprintfmt+0x403>
  800475:	0f b6 d2             	movzbl %dl,%edx
  800478:	ff 24 95 4c 11 80 00 	jmp    *0x80114c(,%edx,4)
  80047f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800483:	eb d6                	jmp    80045b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800485:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800488:	83 ea 30             	sub    $0x30,%edx
  80048b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80048e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800491:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800494:	83 fb 09             	cmp    $0x9,%ebx
  800497:	77 55                	ja     8004ee <vprintfmt+0xee>
  800499:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80049c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004a2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004a5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004a9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ac:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004af:	83 fb 09             	cmp    $0x9,%ebx
  8004b2:	76 eb                	jbe    80049f <vprintfmt+0x9f>
  8004b4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ba:	eb 32                	jmp    8004ee <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004bc:	8b 55 14             	mov    0x14(%ebp),%edx
  8004bf:	83 c2 04             	add    $0x4,%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 52 fc             	mov    -0x4(%edx),%edx
  8004c8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8004cb:	eb 21                	jmp    8004ee <vprintfmt+0xee>

		case '.':
			if (width < 0)
  8004cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8004da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004dd:	e9 79 ff ff ff       	jmp    80045b <vprintfmt+0x5b>
  8004e2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004e9:	e9 6d ff ff ff       	jmp    80045b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f2:	0f 89 63 ff ff ff    	jns    80045b <vprintfmt+0x5b>
  8004f8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004fe:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800501:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800504:	e9 52 ff ff ff       	jmp    80045b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800509:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80050c:	e9 4a ff ff ff       	jmp    80045b <vprintfmt+0x5b>
  800511:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	83 c0 04             	add    $0x4,%eax
  80051a:	89 45 14             	mov    %eax,0x14(%ebp)
  80051d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800521:	8b 40 fc             	mov    -0x4(%eax),%eax
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff d7                	call   *%edi
  800529:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80052c:	e9 fb fe ff ff       	jmp    80042c <vprintfmt+0x2c>
  800531:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	83 c0 04             	add    $0x4,%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800540:	89 c2                	mov    %eax,%edx
  800542:	c1 fa 1f             	sar    $0x1f,%edx
  800545:	31 d0                	xor    %edx,%eax
  800547:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800549:	83 f8 06             	cmp    $0x6,%eax
  80054c:	7f 0b                	jg     800559 <vprintfmt+0x159>
  80054e:	8b 14 85 a4 12 80 00 	mov    0x8012a4(,%eax,4),%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	75 20                	jne    800579 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800559:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055d:	c7 44 24 08 d0 10 80 	movl   $0x8010d0,0x8(%esp)
  800564:	00 
  800565:	89 74 24 04          	mov    %esi,0x4(%esp)
  800569:	89 3c 24             	mov    %edi,(%esp)
  80056c:	e8 37 03 00 00       	call   8008a8 <printfmt>
  800571:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800574:	e9 b3 fe ff ff       	jmp    80042c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800579:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057d:	c7 44 24 08 d9 10 80 	movl   $0x8010d9,0x8(%esp)
  800584:	00 
  800585:	89 74 24 04          	mov    %esi,0x4(%esp)
  800589:	89 3c 24             	mov    %edi,(%esp)
  80058c:	e8 17 03 00 00       	call   8008a8 <printfmt>
  800591:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800594:	e9 93 fe ff ff       	jmp    80042c <vprintfmt+0x2c>
  800599:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80059c:	89 c3                	mov    %eax,%ebx
  80059e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005a4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	83 c0 04             	add    $0x4,%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b0:	8b 40 fc             	mov    -0x4(%eax),%eax
  8005b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	b8 dc 10 80 00       	mov    $0x8010dc,%eax
  8005bd:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  8005c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	7e 06                	jle    8005ce <vprintfmt+0x1ce>
  8005c8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005cc:	75 13                	jne    8005e1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d1:	0f be 02             	movsbl (%edx),%eax
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	0f 85 99 00 00 00    	jne    800675 <vprintfmt+0x275>
  8005dc:	e9 86 00 00 00       	jmp    800667 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e8:	89 0c 24             	mov    %ecx,(%esp)
  8005eb:	e8 fb 02 00 00       	call   8008eb <strnlen>
  8005f0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	7e d2                	jle    8005ce <vprintfmt+0x1ce>
					putch(padc, putdat);
  8005fc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800600:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800603:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800606:	89 d3                	mov    %edx,%ebx
  800608:	89 74 24 04          	mov    %esi,0x4(%esp)
  80060c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	83 eb 01             	sub    $0x1,%ebx
  800617:	85 db                	test   %ebx,%ebx
  800619:	7f ed                	jg     800608 <vprintfmt+0x208>
  80061b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80061e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800625:	eb a7                	jmp    8005ce <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800627:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80062b:	74 18                	je     800645 <vprintfmt+0x245>
  80062d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800630:	83 fa 5e             	cmp    $0x5e,%edx
  800633:	76 10                	jbe    800645 <vprintfmt+0x245>
					putch('?', putdat);
  800635:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800639:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800640:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800643:	eb 0a                	jmp    80064f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800645:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800649:	89 04 24             	mov    %eax,(%esp)
  80064c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800653:	0f be 03             	movsbl (%ebx),%eax
  800656:	85 c0                	test   %eax,%eax
  800658:	74 05                	je     80065f <vprintfmt+0x25f>
  80065a:	83 c3 01             	add    $0x1,%ebx
  80065d:	eb 29                	jmp    800688 <vprintfmt+0x288>
  80065f:	89 fe                	mov    %edi,%esi
  800661:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800664:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066b:	7f 2e                	jg     80069b <vprintfmt+0x29b>
  80066d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800670:	e9 b7 fd ff ff       	jmp    80042c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800678:	83 c2 01             	add    $0x1,%edx
  80067b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80067e:	89 f7                	mov    %esi,%edi
  800680:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800683:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800686:	89 d3                	mov    %edx,%ebx
  800688:	85 f6                	test   %esi,%esi
  80068a:	78 9b                	js     800627 <vprintfmt+0x227>
  80068c:	83 ee 01             	sub    $0x1,%esi
  80068f:	79 96                	jns    800627 <vprintfmt+0x227>
  800691:	89 fe                	mov    %edi,%esi
  800693:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800696:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800699:	eb cc                	jmp    800667 <vprintfmt+0x267>
  80069b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80069e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ac:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 eb 01             	sub    $0x1,%ebx
  8006b1:	85 db                	test   %ebx,%ebx
  8006b3:	7f ec                	jg     8006a1 <vprintfmt+0x2a1>
  8006b5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006b8:	e9 6f fd ff ff       	jmp    80042c <vprintfmt+0x2c>
  8006bd:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c0:	83 f9 01             	cmp    $0x1,%ecx
  8006c3:	7e 17                	jle    8006dc <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	83 c0 08             	add    $0x8,%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ce:	8b 50 f8             	mov    -0x8(%eax),%edx
  8006d1:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8006d4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006da:	eb 34                	jmp    800710 <vprintfmt+0x310>
	else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 19                	je     8006f9 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	83 c0 04             	add    $0x4,%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e9:	8b 40 fc             	mov    -0x4(%eax),%eax
  8006ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ef:	89 c1                	mov    %eax,%ecx
  8006f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f7:	eb 17                	jmp    800710 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	83 c0 04             	add    $0x4,%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800702:	8b 40 fc             	mov    -0x4(%eax),%eax
  800705:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800708:	89 c2                	mov    %eax,%edx
  80070a:	c1 fa 1f             	sar    $0x1f,%edx
  80070d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800710:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800713:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800716:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80071b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071f:	0f 89 9c 00 00 00    	jns    8007c1 <vprintfmt+0x3c1>
				putch('-', putdat);
  800725:	89 74 24 04          	mov    %esi,0x4(%esp)
  800729:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800730:	ff d7                	call   *%edi
				num = -(long long) num;
  800732:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800735:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800738:	f7 d9                	neg    %ecx
  80073a:	83 d3 00             	adc    $0x0,%ebx
  80073d:	f7 db                	neg    %ebx
  80073f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800744:	eb 7b                	jmp    8007c1 <vprintfmt+0x3c1>
  800746:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800749:	89 ca                	mov    %ecx,%edx
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	e8 53 fc ff ff       	call   8003a6 <getuint>
  800753:	89 c1                	mov    %eax,%ecx
  800755:	89 d3                	mov    %edx,%ebx
  800757:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80075c:	eb 63                	jmp    8007c1 <vprintfmt+0x3c1>
  80075e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800761:	89 ca                	mov    %ecx,%edx
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	e8 3b fc ff ff       	call   8003a6 <getuint>
  80076b:	89 c1                	mov    %eax,%ecx
  80076d:	89 d3                	mov    %edx,%ebx
  80076f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800774:	eb 4b                	jmp    8007c1 <vprintfmt+0x3c1>
  800776:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800779:	89 74 24 04          	mov    %esi,0x4(%esp)
  80077d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800784:	ff d7                	call   *%edi
			putch('x', putdat);
  800786:	89 74 24 04          	mov    %esi,0x4(%esp)
  80078a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800791:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	83 c0 04             	add    $0x4,%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  80079f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a4:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a9:	eb 16                	jmp    8007c1 <vprintfmt+0x3c1>
  8007ab:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ae:	89 ca                	mov    %ecx,%edx
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b3:	e8 ee fb ff ff       	call   8003a6 <getuint>
  8007b8:	89 c1                	mov    %eax,%ecx
  8007ba:	89 d3                	mov    %edx,%ebx
  8007bc:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8007c5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d4:	89 0c 24             	mov    %ecx,(%esp)
  8007d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007db:	89 f2                	mov    %esi,%edx
  8007dd:	89 f8                	mov    %edi,%eax
  8007df:	e8 cc fa ff ff       	call   8002b0 <printnum>
  8007e4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007e7:	e9 40 fc ff ff       	jmp    80042c <vprintfmt+0x2c>
  8007ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007ef:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f6:	89 14 24             	mov    %edx,(%esp)
  8007f9:	ff d7                	call   *%edi
  8007fb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007fe:	e9 29 fc ff ff       	jmp    80042c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800803:	89 74 24 04          	mov    %esi,0x4(%esp)
  800807:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80080e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800810:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800813:	80 38 25             	cmpb   $0x25,(%eax)
  800816:	0f 84 10 fc ff ff    	je     80042c <vprintfmt+0x2c>
  80081c:	89 c3                	mov    %eax,%ebx
  80081e:	eb f0                	jmp    800810 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800820:	83 c4 5c             	add    $0x5c,%esp
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5f                   	pop    %edi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	83 ec 28             	sub    $0x28,%esp
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800834:	85 c0                	test   %eax,%eax
  800836:	74 04                	je     80083c <vsnprintf+0x14>
  800838:	85 d2                	test   %edx,%edx
  80083a:	7f 07                	jg     800843 <vsnprintf+0x1b>
  80083c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800841:	eb 3b                	jmp    80087e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800843:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800846:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80084a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80084d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085b:	8b 45 10             	mov    0x10(%ebp),%eax
  80085e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800862:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800865:	89 44 24 04          	mov    %eax,0x4(%esp)
  800869:	c7 04 24 e3 03 80 00 	movl   $0x8003e3,(%esp)
  800870:	e8 8b fb ff ff       	call   800400 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800875:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800878:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800886:	8d 45 14             	lea    0x14(%ebp),%eax
  800889:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80088d:	8b 45 10             	mov    0x10(%ebp),%eax
  800890:	89 44 24 08          	mov    %eax,0x8(%esp)
  800894:	8b 45 0c             	mov    0xc(%ebp),%eax
  800897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	89 04 24             	mov    %eax,(%esp)
  8008a1:	e8 82 ff ff ff       	call   800828 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	e8 32 fb ff ff       	call   800400 <vprintfmt>
	va_end(ap);
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	80 3a 00             	cmpb   $0x0,(%edx)
  8008de:	74 09                	je     8008e9 <strlen+0x19>
		n++;
  8008e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e7:	75 f7                	jne    8008e0 <strlen+0x10>
		n++;
	return n;
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f5:	85 c9                	test   %ecx,%ecx
  8008f7:	74 19                	je     800912 <strnlen+0x27>
  8008f9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008fc:	74 14                	je     800912 <strnlen+0x27>
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800903:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800906:	39 c8                	cmp    %ecx,%eax
  800908:	74 0d                	je     800917 <strnlen+0x2c>
  80090a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80090e:	75 f3                	jne    800903 <strnlen+0x18>
  800910:	eb 05                	jmp    800917 <strnlen+0x2c>
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800917:	5b                   	pop    %ebx
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	53                   	push   %ebx
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800924:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800929:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80092d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800930:	83 c2 01             	add    $0x1,%edx
  800933:	84 c9                	test   %cl,%cl
  800935:	75 f2                	jne    800929 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	85 f6                	test   %esi,%esi
  80094a:	74 18                	je     800964 <strncpy+0x2a>
  80094c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800951:	0f b6 1a             	movzbl (%edx),%ebx
  800954:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800957:	80 3a 01             	cmpb   $0x1,(%edx)
  80095a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095d:	83 c1 01             	add    $0x1,%ecx
  800960:	39 ce                	cmp    %ecx,%esi
  800962:	77 ed                	ja     800951 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 75 08             	mov    0x8(%ebp),%esi
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800976:	89 f0                	mov    %esi,%eax
  800978:	85 c9                	test   %ecx,%ecx
  80097a:	74 27                	je     8009a3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80097c:	83 e9 01             	sub    $0x1,%ecx
  80097f:	74 1d                	je     80099e <strlcpy+0x36>
  800981:	0f b6 1a             	movzbl (%edx),%ebx
  800984:	84 db                	test   %bl,%bl
  800986:	74 16                	je     80099e <strlcpy+0x36>
			*dst++ = *src++;
  800988:	88 18                	mov    %bl,(%eax)
  80098a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098d:	83 e9 01             	sub    $0x1,%ecx
  800990:	74 0e                	je     8009a0 <strlcpy+0x38>
			*dst++ = *src++;
  800992:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	84 db                	test   %bl,%bl
  80099a:	75 ec                	jne    800988 <strlcpy+0x20>
  80099c:	eb 02                	jmp    8009a0 <strlcpy+0x38>
  80099e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009a0:	c6 00 00             	movb   $0x0,(%eax)
  8009a3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b2:	0f b6 01             	movzbl (%ecx),%eax
  8009b5:	84 c0                	test   %al,%al
  8009b7:	74 15                	je     8009ce <strcmp+0x25>
  8009b9:	3a 02                	cmp    (%edx),%al
  8009bb:	75 11                	jne    8009ce <strcmp+0x25>
		p++, q++;
  8009bd:	83 c1 01             	add    $0x1,%ecx
  8009c0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009c3:	0f b6 01             	movzbl (%ecx),%eax
  8009c6:	84 c0                	test   %al,%al
  8009c8:	74 04                	je     8009ce <strcmp+0x25>
  8009ca:	3a 02                	cmp    (%edx),%al
  8009cc:	74 ef                	je     8009bd <strcmp+0x14>
  8009ce:	0f b6 c0             	movzbl %al,%eax
  8009d1:	0f b6 12             	movzbl (%edx),%edx
  8009d4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	53                   	push   %ebx
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009e5:	85 c0                	test   %eax,%eax
  8009e7:	74 23                	je     800a0c <strncmp+0x34>
  8009e9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ec:	84 db                	test   %bl,%bl
  8009ee:	74 24                	je     800a14 <strncmp+0x3c>
  8009f0:	3a 19                	cmp    (%ecx),%bl
  8009f2:	75 20                	jne    800a14 <strncmp+0x3c>
  8009f4:	83 e8 01             	sub    $0x1,%eax
  8009f7:	74 13                	je     800a0c <strncmp+0x34>
		n--, p++, q++;
  8009f9:	83 c2 01             	add    $0x1,%edx
  8009fc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ff:	0f b6 1a             	movzbl (%edx),%ebx
  800a02:	84 db                	test   %bl,%bl
  800a04:	74 0e                	je     800a14 <strncmp+0x3c>
  800a06:	3a 19                	cmp    (%ecx),%bl
  800a08:	74 ea                	je     8009f4 <strncmp+0x1c>
  800a0a:	eb 08                	jmp    800a14 <strncmp+0x3c>
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a14:	0f b6 02             	movzbl (%edx),%eax
  800a17:	0f b6 11             	movzbl (%ecx),%edx
  800a1a:	29 d0                	sub    %edx,%eax
  800a1c:	eb f3                	jmp    800a11 <strncmp+0x39>

00800a1e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a28:	0f b6 10             	movzbl (%eax),%edx
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	74 15                	je     800a44 <strchr+0x26>
		if (*s == c)
  800a2f:	38 ca                	cmp    %cl,%dl
  800a31:	75 07                	jne    800a3a <strchr+0x1c>
  800a33:	eb 14                	jmp    800a49 <strchr+0x2b>
  800a35:	38 ca                	cmp    %cl,%dl
  800a37:	90                   	nop
  800a38:	74 0f                	je     800a49 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	84 d2                	test   %dl,%dl
  800a42:	75 f1                	jne    800a35 <strchr+0x17>
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	0f b6 10             	movzbl (%eax),%edx
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	74 18                	je     800a74 <strfind+0x29>
		if (*s == c)
  800a5c:	38 ca                	cmp    %cl,%dl
  800a5e:	75 0a                	jne    800a6a <strfind+0x1f>
  800a60:	eb 12                	jmp    800a74 <strfind+0x29>
  800a62:	38 ca                	cmp    %cl,%dl
  800a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a68:	74 0a                	je     800a74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 ee                	jne    800a62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	53                   	push   %ebx
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a83:	89 da                	mov    %ebx,%edx
  800a85:	83 ea 01             	sub    $0x1,%edx
  800a88:	78 0d                	js     800a97 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  800a8a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a8c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a8e:	88 0a                	mov    %cl,(%edx)
  800a90:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a93:	39 da                	cmp    %ebx,%edx
  800a95:	75 f7                	jne    800a8e <memset+0x18>
		*p++ = c;

	return v;
}
  800a97:	5b                   	pop    %ebx
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	74 13                	je     800abf <memcpy+0x25>
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800ab1:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ab5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ab8:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800abb:	39 da                	cmp    %ebx,%edx
  800abd:	75 f2                	jne    800ab1 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800ad2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800ad4:	39 c6                	cmp    %eax,%esi
  800ad6:	72 0b                	jb     800ae3 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800ad8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800add:	85 db                	test   %ebx,%ebx
  800adf:	75 2e                	jne    800b0f <memmove+0x4c>
  800ae1:	eb 3a                	jmp    800b1d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae3:	01 df                	add    %ebx,%edi
  800ae5:	39 f8                	cmp    %edi,%eax
  800ae7:	73 ef                	jae    800ad8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	90                   	nop
  800aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800af0:	74 2b                	je     800b1d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800af2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800af5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800afa:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800aff:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800b03:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800b06:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800b09:	85 c9                	test   %ecx,%ecx
  800b0b:	75 ed                	jne    800afa <memmove+0x37>
  800b0d:	eb 0e                	jmp    800b1d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800b0f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b13:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b16:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800b19:	39 d3                	cmp    %edx,%ebx
  800b1b:	75 f2                	jne    800b0f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	8b 75 08             	mov    0x8(%ebp),%esi
  800b2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b31:	85 c9                	test   %ecx,%ecx
  800b33:	74 36                	je     800b6b <memcmp+0x49>
		if (*s1 != *s2)
  800b35:	0f b6 06             	movzbl (%esi),%eax
  800b38:	0f b6 1f             	movzbl (%edi),%ebx
  800b3b:	38 d8                	cmp    %bl,%al
  800b3d:	74 20                	je     800b5f <memcmp+0x3d>
  800b3f:	eb 14                	jmp    800b55 <memcmp+0x33>
  800b41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	83 e9 01             	sub    $0x1,%ecx
  800b51:	38 d8                	cmp    %bl,%al
  800b53:	74 12                	je     800b67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 db             	movzbl %bl,%ebx
  800b5b:	29 d8                	sub    %ebx,%eax
  800b5d:	eb 11                	jmp    800b70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5f:	83 e9 01             	sub    $0x1,%ecx
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	85 c9                	test   %ecx,%ecx
  800b69:	75 d6                	jne    800b41 <memcmp+0x1f>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b80:	39 d0                	cmp    %edx,%eax
  800b82:	73 15                	jae    800b99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b88:	38 08                	cmp    %cl,(%eax)
  800b8a:	75 06                	jne    800b92 <memfind+0x1d>
  800b8c:	eb 0b                	jmp    800b99 <memfind+0x24>
  800b8e:	38 08                	cmp    %cl,(%eax)
  800b90:	74 07                	je     800b99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	39 c2                	cmp    %eax,%edx
  800b97:	77 f5                	ja     800b8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 04             	sub    $0x4,%esp
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baa:	0f b6 02             	movzbl (%edx),%eax
  800bad:	3c 20                	cmp    $0x20,%al
  800baf:	74 04                	je     800bb5 <strtol+0x1a>
  800bb1:	3c 09                	cmp    $0x9,%al
  800bb3:	75 0e                	jne    800bc3 <strtol+0x28>
		s++;
  800bb5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	0f b6 02             	movzbl (%edx),%eax
  800bbb:	3c 20                	cmp    $0x20,%al
  800bbd:	74 f6                	je     800bb5 <strtol+0x1a>
  800bbf:	3c 09                	cmp    $0x9,%al
  800bc1:	74 f2                	je     800bb5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc3:	3c 2b                	cmp    $0x2b,%al
  800bc5:	75 0c                	jne    800bd3 <strtol+0x38>
		s++;
  800bc7:	83 c2 01             	add    $0x1,%edx
  800bca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bd1:	eb 15                	jmp    800be8 <strtol+0x4d>
	else if (*s == '-')
  800bd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bda:	3c 2d                	cmp    $0x2d,%al
  800bdc:	75 0a                	jne    800be8 <strtol+0x4d>
		s++, neg = 1;
  800bde:	83 c2 01             	add    $0x1,%edx
  800be1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	0f 94 c0             	sete   %al
  800bed:	74 05                	je     800bf4 <strtol+0x59>
  800bef:	83 fb 10             	cmp    $0x10,%ebx
  800bf2:	75 18                	jne    800c0c <strtol+0x71>
  800bf4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf7:	75 13                	jne    800c0c <strtol+0x71>
  800bf9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bfd:	8d 76 00             	lea    0x0(%esi),%esi
  800c00:	75 0a                	jne    800c0c <strtol+0x71>
		s += 2, base = 16;
  800c02:	83 c2 02             	add    $0x2,%edx
  800c05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0a:	eb 15                	jmp    800c21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0c:	84 c0                	test   %al,%al
  800c0e:	66 90                	xchg   %ax,%ax
  800c10:	74 0f                	je     800c21 <strtol+0x86>
  800c12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c17:	80 3a 30             	cmpb   $0x30,(%edx)
  800c1a:	75 05                	jne    800c21 <strtol+0x86>
		s++, base = 8;
  800c1c:	83 c2 01             	add    $0x1,%edx
  800c1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c28:	0f b6 0a             	movzbl (%edx),%ecx
  800c2b:	89 cf                	mov    %ecx,%edi
  800c2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c30:	80 fb 09             	cmp    $0x9,%bl
  800c33:	77 08                	ja     800c3d <strtol+0xa2>
			dig = *s - '0';
  800c35:	0f be c9             	movsbl %cl,%ecx
  800c38:	83 e9 30             	sub    $0x30,%ecx
  800c3b:	eb 1e                	jmp    800c5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c40:	80 fb 19             	cmp    $0x19,%bl
  800c43:	77 08                	ja     800c4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c45:	0f be c9             	movsbl %cl,%ecx
  800c48:	83 e9 57             	sub    $0x57,%ecx
  800c4b:	eb 0e                	jmp    800c5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c50:	80 fb 19             	cmp    $0x19,%bl
  800c53:	77 15                	ja     800c6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c55:	0f be c9             	movsbl %cl,%ecx
  800c58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5b:	39 f1                	cmp    %esi,%ecx
  800c5d:	7d 0b                	jge    800c6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c5f:	83 c2 01             	add    $0x1,%edx
  800c62:	0f af c6             	imul   %esi,%eax
  800c65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c68:	eb be                	jmp    800c28 <strtol+0x8d>
  800c6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c70:	74 05                	je     800c77 <strtol+0xdc>
		*endptr = (char *) s;
  800c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c77:	89 ca                	mov    %ecx,%edx
  800c79:	f7 da                	neg    %edx
  800c7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c7f:	0f 45 c2             	cmovne %edx,%eax
}
  800c82:	83 c4 04             	add    $0x4,%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    
	...

00800c8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	89 1c 24             	mov    %ebx,(%esp)
  800c95:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c99:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 c3                	mov    %eax,%ebx
  800caa:	89 c7                	mov    %eax,%edi
  800cac:	89 c6                	mov    %eax,%esi
  800cae:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800cb0:	8b 1c 24             	mov    (%esp),%ebx
  800cb3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cb7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cbb:	89 ec                	mov    %ebp,%esp
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	89 1c 24             	mov    %ebx,(%esp)
  800cc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ccc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cda:	89 d1                	mov    %edx,%ecx
  800cdc:	89 d3                	mov    %edx,%ebx
  800cde:	89 d7                	mov    %edx,%edi
  800ce0:	89 d6                	mov    %edx,%esi
  800ce2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800ce4:	8b 1c 24             	mov    (%esp),%ebx
  800ce7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ceb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cef:	89 ec                	mov    %ebp,%esp
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	89 1c 24             	mov    %ebx,(%esp)
  800cfc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d00:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d09:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	89 cb                	mov    %ecx,%ebx
  800d13:	89 cf                	mov    %ecx,%edi
  800d15:	89 ce                	mov    %ecx,%esi
  800d17:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800d19:	8b 1c 24             	mov    (%esp),%ebx
  800d1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d20:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d24:	89 ec                	mov    %ebp,%esp
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	89 1c 24             	mov    %ebx,(%esp)
  800d31:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d35:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d43:	89 d1                	mov    %edx,%ecx
  800d45:	89 d3                	mov    %edx,%ebx
  800d47:	89 d7                	mov    %edx,%edi
  800d49:	89 d6                	mov    %edx,%esi
  800d4b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800d4d:	8b 1c 24             	mov    (%esp),%ebx
  800d50:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d54:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d58:	89 ec                	mov    %ebp,%esp
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    
  800d5c:	00 00                	add    %al,(%eax)
	...

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	83 ec 10             	sub    $0x10,%esp
  800d68:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	8b 75 10             	mov    0x10(%ebp),%esi
  800d71:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d74:	85 c0                	test   %eax,%eax
  800d76:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d79:	75 35                	jne    800db0 <__udivdi3+0x50>
  800d7b:	39 fe                	cmp    %edi,%esi
  800d7d:	77 61                	ja     800de0 <__udivdi3+0x80>
  800d7f:	85 f6                	test   %esi,%esi
  800d81:	75 0b                	jne    800d8e <__udivdi3+0x2e>
  800d83:	b8 01 00 00 00       	mov    $0x1,%eax
  800d88:	31 d2                	xor    %edx,%edx
  800d8a:	f7 f6                	div    %esi
  800d8c:	89 c6                	mov    %eax,%esi
  800d8e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800d91:	31 d2                	xor    %edx,%edx
  800d93:	89 f8                	mov    %edi,%eax
  800d95:	f7 f6                	div    %esi
  800d97:	89 c7                	mov    %eax,%edi
  800d99:	89 c8                	mov    %ecx,%eax
  800d9b:	f7 f6                	div    %esi
  800d9d:	89 c1                	mov    %eax,%ecx
  800d9f:	89 fa                	mov    %edi,%edx
  800da1:	89 c8                	mov    %ecx,%eax
  800da3:	83 c4 10             	add    $0x10,%esp
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    
  800daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800db0:	39 f8                	cmp    %edi,%eax
  800db2:	77 1c                	ja     800dd0 <__udivdi3+0x70>
  800db4:	0f bd d0             	bsr    %eax,%edx
  800db7:	83 f2 1f             	xor    $0x1f,%edx
  800dba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800dbd:	75 39                	jne    800df8 <__udivdi3+0x98>
  800dbf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800dc2:	0f 86 a0 00 00 00    	jbe    800e68 <__udivdi3+0x108>
  800dc8:	39 f8                	cmp    %edi,%eax
  800dca:	0f 82 98 00 00 00    	jb     800e68 <__udivdi3+0x108>
  800dd0:	31 ff                	xor    %edi,%edi
  800dd2:	31 c9                	xor    %ecx,%ecx
  800dd4:	89 c8                	mov    %ecx,%eax
  800dd6:	89 fa                	mov    %edi,%edx
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
  800de0:	89 d1                	mov    %edx,%ecx
  800de2:	89 fa                	mov    %edi,%edx
  800de4:	89 c8                	mov    %ecx,%eax
  800de6:	31 ff                	xor    %edi,%edi
  800de8:	f7 f6                	div    %esi
  800dea:	89 c1                	mov    %eax,%ecx
  800dec:	89 fa                	mov    %edi,%edx
  800dee:	89 c8                	mov    %ecx,%eax
  800df0:	83 c4 10             	add    $0x10,%esp
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    
  800df7:	90                   	nop
  800df8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800dfc:	89 f2                	mov    %esi,%edx
  800dfe:	d3 e0                	shl    %cl,%eax
  800e00:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e03:	b8 20 00 00 00       	mov    $0x20,%eax
  800e08:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800e0b:	89 c1                	mov    %eax,%ecx
  800e0d:	d3 ea                	shr    %cl,%edx
  800e0f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e13:	0b 55 ec             	or     -0x14(%ebp),%edx
  800e16:	d3 e6                	shl    %cl,%esi
  800e18:	89 c1                	mov    %eax,%ecx
  800e1a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800e1d:	89 fe                	mov    %edi,%esi
  800e1f:	d3 ee                	shr    %cl,%esi
  800e21:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e25:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800e28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e2b:	d3 e7                	shl    %cl,%edi
  800e2d:	89 c1                	mov    %eax,%ecx
  800e2f:	d3 ea                	shr    %cl,%edx
  800e31:	09 d7                	or     %edx,%edi
  800e33:	89 f2                	mov    %esi,%edx
  800e35:	89 f8                	mov    %edi,%eax
  800e37:	f7 75 ec             	divl   -0x14(%ebp)
  800e3a:	89 d6                	mov    %edx,%esi
  800e3c:	89 c7                	mov    %eax,%edi
  800e3e:	f7 65 e8             	mull   -0x18(%ebp)
  800e41:	39 d6                	cmp    %edx,%esi
  800e43:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800e46:	72 30                	jb     800e78 <__udivdi3+0x118>
  800e48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e4b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e4f:	d3 e2                	shl    %cl,%edx
  800e51:	39 c2                	cmp    %eax,%edx
  800e53:	73 05                	jae    800e5a <__udivdi3+0xfa>
  800e55:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800e58:	74 1e                	je     800e78 <__udivdi3+0x118>
  800e5a:	89 f9                	mov    %edi,%ecx
  800e5c:	31 ff                	xor    %edi,%edi
  800e5e:	e9 71 ff ff ff       	jmp    800dd4 <__udivdi3+0x74>
  800e63:	90                   	nop
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	31 ff                	xor    %edi,%edi
  800e6a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800e6f:	e9 60 ff ff ff       	jmp    800dd4 <__udivdi3+0x74>
  800e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e78:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800e7b:	31 ff                	xor    %edi,%edi
  800e7d:	89 c8                	mov    %ecx,%eax
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
	...

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	83 ec 20             	sub    $0x20,%esp
  800e98:	8b 55 14             	mov    0x14(%ebp),%edx
  800e9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ea1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ea4:	85 d2                	test   %edx,%edx
  800ea6:	89 c8                	mov    %ecx,%eax
  800ea8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800eab:	75 13                	jne    800ec0 <__umoddi3+0x30>
  800ead:	39 f7                	cmp    %esi,%edi
  800eaf:	76 3f                	jbe    800ef0 <__umoddi3+0x60>
  800eb1:	89 f2                	mov    %esi,%edx
  800eb3:	f7 f7                	div    %edi
  800eb5:	89 d0                	mov    %edx,%eax
  800eb7:	31 d2                	xor    %edx,%edx
  800eb9:	83 c4 20             	add    $0x20,%esp
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    
  800ec0:	39 f2                	cmp    %esi,%edx
  800ec2:	77 4c                	ja     800f10 <__umoddi3+0x80>
  800ec4:	0f bd ca             	bsr    %edx,%ecx
  800ec7:	83 f1 1f             	xor    $0x1f,%ecx
  800eca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ecd:	75 51                	jne    800f20 <__umoddi3+0x90>
  800ecf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  800ed2:	0f 87 e0 00 00 00    	ja     800fb8 <__umoddi3+0x128>
  800ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edb:	29 f8                	sub    %edi,%eax
  800edd:	19 d6                	sbb    %edx,%esi
  800edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee5:	89 f2                	mov    %esi,%edx
  800ee7:	83 c4 20             	add    $0x20,%esp
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    
  800eee:	66 90                	xchg   %ax,%ax
  800ef0:	85 ff                	test   %edi,%edi
  800ef2:	75 0b                	jne    800eff <__umoddi3+0x6f>
  800ef4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef9:	31 d2                	xor    %edx,%edx
  800efb:	f7 f7                	div    %edi
  800efd:	89 c7                	mov    %eax,%edi
  800eff:	89 f0                	mov    %esi,%eax
  800f01:	31 d2                	xor    %edx,%edx
  800f03:	f7 f7                	div    %edi
  800f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f08:	f7 f7                	div    %edi
  800f0a:	eb a9                	jmp    800eb5 <__umoddi3+0x25>
  800f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f10:	89 c8                	mov    %ecx,%eax
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	83 c4 20             	add    $0x20,%esp
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    
  800f1b:	90                   	nop
  800f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f20:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f24:	d3 e2                	shl    %cl,%edx
  800f26:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f29:	ba 20 00 00 00       	mov    $0x20,%edx
  800f2e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  800f31:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f34:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f38:	89 fa                	mov    %edi,%edx
  800f3a:	d3 ea                	shr    %cl,%edx
  800f3c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f40:	0b 55 f4             	or     -0xc(%ebp),%edx
  800f43:	d3 e7                	shl    %cl,%edi
  800f45:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f49:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f4c:	89 f2                	mov    %esi,%edx
  800f4e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  800f51:	89 c7                	mov    %eax,%edi
  800f53:	d3 ea                	shr    %cl,%edx
  800f55:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f5c:	89 c2                	mov    %eax,%edx
  800f5e:	d3 e6                	shl    %cl,%esi
  800f60:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f64:	d3 ea                	shr    %cl,%edx
  800f66:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f6a:	09 d6                	or     %edx,%esi
  800f6c:	89 f0                	mov    %esi,%eax
  800f6e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800f71:	d3 e7                	shl    %cl,%edi
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	f7 75 f4             	divl   -0xc(%ebp)
  800f78:	89 d6                	mov    %edx,%esi
  800f7a:	f7 65 e8             	mull   -0x18(%ebp)
  800f7d:	39 d6                	cmp    %edx,%esi
  800f7f:	72 2b                	jb     800fac <__umoddi3+0x11c>
  800f81:	39 c7                	cmp    %eax,%edi
  800f83:	72 23                	jb     800fa8 <__umoddi3+0x118>
  800f85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f89:	29 c7                	sub    %eax,%edi
  800f8b:	19 d6                	sbb    %edx,%esi
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	89 f2                	mov    %esi,%edx
  800f91:	d3 ef                	shr    %cl,%edi
  800f93:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f97:	d3 e0                	shl    %cl,%eax
  800f99:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f9d:	09 f8                	or     %edi,%eax
  800f9f:	d3 ea                	shr    %cl,%edx
  800fa1:	83 c4 20             	add    $0x20,%esp
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    
  800fa8:	39 d6                	cmp    %edx,%esi
  800faa:	75 d9                	jne    800f85 <__umoddi3+0xf5>
  800fac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  800faf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  800fb2:	eb d1                	jmp    800f85 <__umoddi3+0xf5>
  800fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	39 f2                	cmp    %esi,%edx
  800fba:	0f 82 18 ff ff ff    	jb     800ed8 <__umoddi3+0x48>
  800fc0:	e9 1d ff ff ff       	jmp    800ee2 <__umoddi3+0x52>
