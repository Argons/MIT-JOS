
obj/user/faultalloc:     file format elf32-i386


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
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80003a:	c7 04 24 70 00 80 00 	movl   $0x800070,(%esp)
  800041:	e8 de 0e 00 00       	call   800f24 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  800046:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80004d:	de 
  80004e:	c7 04 24 40 12 80 00 	movl   $0x801240,(%esp)
  800055:	e8 cb 01 00 00       	call   800225 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  80005a:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  800061:	ca 
  800062:	c7 04 24 40 12 80 00 	movl   $0x801240,(%esp)
  800069:	e8 b7 01 00 00       	call   800225 <cprintf>
}
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	53                   	push   %ebx
  800074:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800077:	8b 45 08             	mov    0x8(%ebp),%eax
  80007a:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	c7 04 24 44 12 80 00 	movl   $0x801244,(%esp)
  800087:	e8 99 01 00 00       	call   800225 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80008c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800093:	00 
  800094:	89 d8                	mov    %ebx,%eax
  800096:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 c5 0c 00 00       	call   800d70 <sys_page_alloc>
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 24                	jns    8000d3 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  8000af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b7:	c7 44 24 08 60 12 80 	movl   $0x801260,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 4e 12 80 00 	movl   $0x80124e,(%esp)
  8000ce:	e8 8d 00 00 00       	call   800160 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d7:	c7 44 24 08 8c 12 80 	movl   $0x80128c,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000e6:	00 
  8000e7:	89 1c 24             	mov    %ebx,(%esp)
  8000ea:	e8 71 07 00 00       	call   800860 <snprintf>
}
  8000ef:	83 c4 24             	add    $0x24,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

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
  80010a:	e8 f9 0b 00 00       	call   800d08 <sys_getenvid>
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
  800159:	e8 75 0b 00 00       	call   800cd3 <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800166:	a1 08 20 80 00       	mov    0x802008,%eax
  80016b:	85 c0                	test   %eax,%eax
  80016d:	74 10                	je     80017f <_panic+0x1f>
		cprintf("%s: ", argv0);
  80016f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800173:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  80017a:	e8 a6 00 00 00       	call   800225 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80017f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800182:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018d:	a1 00 20 80 00       	mov    0x802000,%eax
  800192:	89 44 24 04          	mov    %eax,0x4(%esp)
  800196:	c7 04 24 cc 12 80 00 	movl   $0x8012cc,(%esp)
  80019d:	e8 83 00 00 00       	call   800225 <cprintf>
	vcprintf(fmt, ap);
  8001a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8001a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 10 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  8001b4:	c7 04 24 42 12 80 00 	movl   $0x801242,(%esp)
  8001bb:	e8 65 00 00 00       	call   800225 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c0:	cc                   	int3   
  8001c1:	eb fd                	jmp    8001c0 <_panic+0x60>
	...

008001c4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f9:	c7 04 24 3f 02 80 00 	movl   $0x80023f,(%esp)
  800200:	e8 db 01 00 00       	call   8003e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800205:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80020b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	e8 4f 0a 00 00       	call   800c6c <sys_cputs>

	return b.cnt;
}
  80021d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80022b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80022e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	e8 87 ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	53                   	push   %ebx
  800243:	83 ec 14             	sub    $0x14,%esp
  800246:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800249:	8b 03                	mov    (%ebx),%eax
  80024b:	8b 55 08             	mov    0x8(%ebp),%edx
  80024e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800252:	83 c0 01             	add    $0x1,%eax
  800255:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800257:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025c:	75 19                	jne    800277 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80025e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800265:	00 
  800266:	8d 43 08             	lea    0x8(%ebx),%eax
  800269:	89 04 24             	mov    %eax,(%esp)
  80026c:	e8 fb 09 00 00       	call   800c6c <sys_cputs>
		b->idx = 0;
  800271:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800277:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027b:	83 c4 14             	add    $0x14,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
	...

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 4c             	sub    $0x4c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d6                	mov    %edx,%esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002bb:	39 d1                	cmp    %edx,%ecx
  8002bd:	72 15                	jb     8002d4 <printnum+0x44>
  8002bf:	77 07                	ja     8002c8 <printnum+0x38>
  8002c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c4:	39 d0                	cmp    %edx,%eax
  8002c6:	76 0c                	jbe    8002d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c8:	83 eb 01             	sub    $0x1,%ebx
  8002cb:	85 db                	test   %ebx,%ebx
  8002cd:	8d 76 00             	lea    0x0(%esi),%esi
  8002d0:	7f 61                	jg     800333 <printnum+0xa3>
  8002d2:	eb 70                	jmp    800344 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002d8:	83 eb 01             	sub    $0x1,%ebx
  8002db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ff:	00 
  800300:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800309:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030d:	e8 ae 0c 00 00       	call   800fc0 <__udivdi3>
  800312:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800315:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	89 54 24 04          	mov    %edx,0x4(%esp)
  800327:	89 f2                	mov    %esi,%edx
  800329:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032c:	e8 5f ff ff ff       	call   800290 <printnum>
  800331:	eb 11                	jmp    800344 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800333:	89 74 24 04          	mov    %esi,0x4(%esp)
  800337:	89 3c 24             	mov    %edi,(%esp)
  80033a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f ef                	jg     800333 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	89 74 24 04          	mov    %esi,0x4(%esp)
  800348:	8b 74 24 04          	mov    0x4(%esp),%esi
  80034c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800353:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035a:	00 
  80035b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80035e:	89 14 24             	mov    %edx,(%esp)
  800361:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800364:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800368:	e8 83 0d 00 00       	call   8010f0 <__umoddi3>
  80036d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800371:	0f be 80 e8 12 80 00 	movsbl 0x8012e8(%eax),%eax
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80037e:	83 c4 4c             	add    $0x4c,%esp
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800389:	83 fa 01             	cmp    $0x1,%edx
  80038c:	7e 0f                	jle    80039d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	83 c2 08             	add    $0x8,%edx
  800393:	89 10                	mov    %edx,(%eax)
  800395:	8b 42 f8             	mov    -0x8(%edx),%eax
  800398:	8b 52 fc             	mov    -0x4(%edx),%edx
  80039b:	eb 24                	jmp    8003c1 <getuint+0x3b>
	else if (lflag)
  80039d:	85 d2                	test   %edx,%edx
  80039f:	74 11                	je     8003b2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003a1:	8b 10                	mov    (%eax),%edx
  8003a3:	83 c2 04             	add    $0x4,%edx
  8003a6:	89 10                	mov    %edx,(%eax)
  8003a8:	8b 42 fc             	mov    -0x4(%edx),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 0f                	jmp    8003c1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	83 c2 04             	add    $0x4,%edx
  8003b7:	89 10                	mov    %edx,(%eax)
  8003b9:	8b 42 fc             	mov    -0x4(%edx),%eax
  8003bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d2:	73 0a                	jae    8003de <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d7:	88 0a                	mov    %cl,(%edx)
  8003d9:	83 c2 01             	add    $0x1,%edx
  8003dc:	89 10                	mov    %edx,(%eax)
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 5c             	sub    $0x5c,%esp
  8003e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003f2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003f9:	eb 11                	jmp    80040c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	0f 84 fd 03 00 00    	je     800800 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800403:	89 74 24 04          	mov    %esi,0x4(%esp)
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040c:	0f b6 03             	movzbl (%ebx),%eax
  80040f:	83 c3 01             	add    $0x1,%ebx
  800412:	83 f8 25             	cmp    $0x25,%eax
  800415:	75 e4                	jne    8003fb <vprintfmt+0x1b>
  800417:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800422:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800429:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800430:	b9 00 00 00 00       	mov    $0x0,%ecx
  800435:	eb 06                	jmp    80043d <vprintfmt+0x5d>
  800437:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80043b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	0f b6 13             	movzbl (%ebx),%edx
  800440:	0f b6 c2             	movzbl %dl,%eax
  800443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800446:	8d 43 01             	lea    0x1(%ebx),%eax
  800449:	83 ea 23             	sub    $0x23,%edx
  80044c:	80 fa 55             	cmp    $0x55,%dl
  80044f:	0f 87 8e 03 00 00    	ja     8007e3 <vprintfmt+0x403>
  800455:	0f b6 d2             	movzbl %dl,%edx
  800458:	ff 24 95 a0 13 80 00 	jmp    *0x8013a0(,%edx,4)
  80045f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800463:	eb d6                	jmp    80043b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800465:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800468:	83 ea 30             	sub    $0x30,%edx
  80046b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80046e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800471:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800474:	83 fb 09             	cmp    $0x9,%ebx
  800477:	77 55                	ja     8004ce <vprintfmt+0xee>
  800479:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80047c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800482:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800485:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800489:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80048c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80048f:	83 fb 09             	cmp    $0x9,%ebx
  800492:	76 eb                	jbe    80047f <vprintfmt+0x9f>
  800494:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800497:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049a:	eb 32                	jmp    8004ce <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049c:	8b 55 14             	mov    0x14(%ebp),%edx
  80049f:	83 c2 04             	add    $0x4,%edx
  8004a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a5:	8b 52 fc             	mov    -0x4(%edx),%edx
  8004a8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8004ab:	eb 21                	jmp    8004ce <vprintfmt+0xee>

		case '.':
			if (width < 0)
  8004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8004ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004bd:	e9 79 ff ff ff       	jmp    80043b <vprintfmt+0x5b>
  8004c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004c9:	e9 6d ff ff ff       	jmp    80043b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d2:	0f 89 63 ff ff ff    	jns    80043b <vprintfmt+0x5b>
  8004d8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004de:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004e1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004e4:	e9 52 ff ff ff       	jmp    80043b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e9:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004ec:	e9 4a ff ff ff       	jmp    80043b <vprintfmt+0x5b>
  8004f1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	83 c0 04             	add    $0x4,%eax
  8004fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800501:	8b 40 fc             	mov    -0x4(%eax),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff d7                	call   *%edi
  800509:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80050c:	e9 fb fe ff ff       	jmp    80040c <vprintfmt+0x2c>
  800511:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	83 c0 04             	add    $0x4,%eax
  80051a:	89 45 14             	mov    %eax,0x14(%ebp)
  80051d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800520:	89 c2                	mov    %eax,%edx
  800522:	c1 fa 1f             	sar    $0x1f,%edx
  800525:	31 d0                	xor    %edx,%eax
  800527:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800529:	83 f8 08             	cmp    $0x8,%eax
  80052c:	7f 0b                	jg     800539 <vprintfmt+0x159>
  80052e:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  800535:	85 d2                	test   %edx,%edx
  800537:	75 20                	jne    800559 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053d:	c7 44 24 08 f9 12 80 	movl   $0x8012f9,0x8(%esp)
  800544:	00 
  800545:	89 74 24 04          	mov    %esi,0x4(%esp)
  800549:	89 3c 24             	mov    %edi,(%esp)
  80054c:	e8 37 03 00 00       	call   800888 <printfmt>
  800551:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800554:	e9 b3 fe ff ff       	jmp    80040c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800559:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055d:	c7 44 24 08 02 13 80 	movl   $0x801302,0x8(%esp)
  800564:	00 
  800565:	89 74 24 04          	mov    %esi,0x4(%esp)
  800569:	89 3c 24             	mov    %edi,(%esp)
  80056c:	e8 17 03 00 00       	call   800888 <printfmt>
  800571:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800574:	e9 93 fe ff ff       	jmp    80040c <vprintfmt+0x2c>
  800579:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80057c:	89 c3                	mov    %eax,%ebx
  80057e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800581:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800584:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	83 c0 04             	add    $0x4,%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
  800590:	8b 40 fc             	mov    -0x4(%eax),%eax
  800593:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800596:	85 c0                	test   %eax,%eax
  800598:	b8 05 13 80 00       	mov    $0x801305,%eax
  80059d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  8005a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005a4:	85 c9                	test   %ecx,%ecx
  8005a6:	7e 06                	jle    8005ae <vprintfmt+0x1ce>
  8005a8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ac:	75 13                	jne    8005c1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b1:	0f be 02             	movsbl (%edx),%eax
  8005b4:	85 c0                	test   %eax,%eax
  8005b6:	0f 85 99 00 00 00    	jne    800655 <vprintfmt+0x275>
  8005bc:	e9 86 00 00 00       	jmp    800647 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c8:	89 0c 24             	mov    %ecx,(%esp)
  8005cb:	e8 fb 02 00 00       	call   8008cb <strnlen>
  8005d0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005d3:	29 c2                	sub    %eax,%edx
  8005d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	7e d2                	jle    8005ae <vprintfmt+0x1ce>
					putch(padc, putdat);
  8005dc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005e0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005e3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005e6:	89 d3                	mov    %edx,%ebx
  8005e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f4:	83 eb 01             	sub    $0x1,%ebx
  8005f7:	85 db                	test   %ebx,%ebx
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x208>
  8005fb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800605:	eb a7                	jmp    8005ae <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800607:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060b:	74 18                	je     800625 <vprintfmt+0x245>
  80060d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800610:	83 fa 5e             	cmp    $0x5e,%edx
  800613:	76 10                	jbe    800625 <vprintfmt+0x245>
					putch('?', putdat);
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800620:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800623:	eb 0a                	jmp    80062f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800625:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800629:	89 04 24             	mov    %eax,(%esp)
  80062c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800633:	0f be 03             	movsbl (%ebx),%eax
  800636:	85 c0                	test   %eax,%eax
  800638:	74 05                	je     80063f <vprintfmt+0x25f>
  80063a:	83 c3 01             	add    $0x1,%ebx
  80063d:	eb 29                	jmp    800668 <vprintfmt+0x288>
  80063f:	89 fe                	mov    %edi,%esi
  800641:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800644:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800647:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80064b:	7f 2e                	jg     80067b <vprintfmt+0x29b>
  80064d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800650:	e9 b7 fd ff ff       	jmp    80040c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800655:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800658:	83 c2 01             	add    $0x1,%edx
  80065b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80065e:	89 f7                	mov    %esi,%edi
  800660:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800663:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800666:	89 d3                	mov    %edx,%ebx
  800668:	85 f6                	test   %esi,%esi
  80066a:	78 9b                	js     800607 <vprintfmt+0x227>
  80066c:	83 ee 01             	sub    $0x1,%esi
  80066f:	79 96                	jns    800607 <vprintfmt+0x227>
  800671:	89 fe                	mov    %edi,%esi
  800673:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800676:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800679:	eb cc                	jmp    800647 <vprintfmt+0x267>
  80067b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80067e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800681:	89 74 24 04          	mov    %esi,0x4(%esp)
  800685:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80068c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068e:	83 eb 01             	sub    $0x1,%ebx
  800691:	85 db                	test   %ebx,%ebx
  800693:	7f ec                	jg     800681 <vprintfmt+0x2a1>
  800695:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800698:	e9 6f fd ff ff       	jmp    80040c <vprintfmt+0x2c>
  80069d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a0:	83 f9 01             	cmp    $0x1,%ecx
  8006a3:	7e 17                	jle    8006bc <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	83 c0 08             	add    $0x8,%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ae:	8b 50 f8             	mov    -0x8(%eax),%edx
  8006b1:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8006b4:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ba:	eb 34                	jmp    8006f0 <vprintfmt+0x310>
	else if (lflag)
  8006bc:	85 c9                	test   %ecx,%ecx
  8006be:	74 19                	je     8006d9 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	83 c0 04             	add    $0x4,%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c9:	8b 40 fc             	mov    -0x4(%eax),%eax
  8006cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cf:	89 c1                	mov    %eax,%ecx
  8006d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d7:	eb 17                	jmp    8006f0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	83 c0 04             	add    $0x4,%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e2:	8b 40 fc             	mov    -0x4(%eax),%eax
  8006e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	c1 fa 1f             	sar    $0x1f,%edx
  8006ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006f6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ff:	0f 89 9c 00 00 00    	jns    8007a1 <vprintfmt+0x3c1>
				putch('-', putdat);
  800705:	89 74 24 04          	mov    %esi,0x4(%esp)
  800709:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800710:	ff d7                	call   *%edi
				num = -(long long) num;
  800712:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800715:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800718:	f7 d9                	neg    %ecx
  80071a:	83 d3 00             	adc    $0x0,%ebx
  80071d:	f7 db                	neg    %ebx
  80071f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800724:	eb 7b                	jmp    8007a1 <vprintfmt+0x3c1>
  800726:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	89 ca                	mov    %ecx,%edx
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 53 fc ff ff       	call   800386 <getuint>
  800733:	89 c1                	mov    %eax,%ecx
  800735:	89 d3                	mov    %edx,%ebx
  800737:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80073c:	eb 63                	jmp    8007a1 <vprintfmt+0x3c1>
  80073e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800741:	89 ca                	mov    %ecx,%edx
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
  800746:	e8 3b fc ff ff       	call   800386 <getuint>
  80074b:	89 c1                	mov    %eax,%ecx
  80074d:	89 d3                	mov    %edx,%ebx
  80074f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800754:	eb 4b                	jmp    8007a1 <vprintfmt+0x3c1>
  800756:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800759:	89 74 24 04          	mov    %esi,0x4(%esp)
  80075d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800764:	ff d7                	call   *%edi
			putch('x', putdat);
  800766:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800771:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	83 c0 04             	add    $0x4,%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  80077f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800784:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800789:	eb 16                	jmp    8007a1 <vprintfmt+0x3c1>
  80078b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078e:	89 ca                	mov    %ecx,%edx
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
  800793:	e8 ee fb ff ff       	call   800386 <getuint>
  800798:	89 c1                	mov    %eax,%ecx
  80079a:	89 d3                	mov    %edx,%ebx
  80079c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8007a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b4:	89 0c 24             	mov    %ecx,(%esp)
  8007b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bb:	89 f2                	mov    %esi,%edx
  8007bd:	89 f8                	mov    %edi,%eax
  8007bf:	e8 cc fa ff ff       	call   800290 <printnum>
  8007c4:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007c7:	e9 40 fc ff ff       	jmp    80040c <vprintfmt+0x2c>
  8007cc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007cf:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d6:	89 14 24             	mov    %edx,(%esp)
  8007d9:	ff d7                	call   *%edi
  8007db:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007de:	e9 29 fc ff ff       	jmp    80040c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ee:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007f3:	80 38 25             	cmpb   $0x25,(%eax)
  8007f6:	0f 84 10 fc ff ff    	je     80040c <vprintfmt+0x2c>
  8007fc:	89 c3                	mov    %eax,%ebx
  8007fe:	eb f0                	jmp    8007f0 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800800:	83 c4 5c             	add    $0x5c,%esp
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5f                   	pop    %edi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 28             	sub    $0x28,%esp
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800814:	85 c0                	test   %eax,%eax
  800816:	74 04                	je     80081c <vsnprintf+0x14>
  800818:	85 d2                	test   %edx,%edx
  80081a:	7f 07                	jg     800823 <vsnprintf+0x1b>
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800821:	eb 3b                	jmp    80085e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800823:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800826:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80082a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80082d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083b:	8b 45 10             	mov    0x10(%ebp),%eax
  80083e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800842:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800845:	89 44 24 04          	mov    %eax,0x4(%esp)
  800849:	c7 04 24 c3 03 80 00 	movl   $0x8003c3,(%esp)
  800850:	e8 8b fb ff ff       	call   8003e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800855:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800858:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800866:	8d 45 14             	lea    0x14(%ebp),%eax
  800869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086d:	8b 45 10             	mov    0x10(%ebp),%eax
  800870:	89 44 24 08          	mov    %eax,0x8(%esp)
  800874:	8b 45 0c             	mov    0xc(%ebp),%eax
  800877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	e8 82 ff ff ff       	call   800808 <vsnprintf>
	va_end(ap);

	return rc;
}
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
  800891:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800895:	8b 45 10             	mov    0x10(%ebp),%eax
  800898:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 32 fb ff ff       	call   8003e0 <vprintfmt>
	va_end(ap);
}
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008be:	74 09                	je     8008c9 <strlen+0x19>
		n++;
  8008c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c7:	75 f7                	jne    8008c0 <strlen+0x10>
		n++;
	return n;
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d5:	85 c9                	test   %ecx,%ecx
  8008d7:	74 19                	je     8008f2 <strnlen+0x27>
  8008d9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008dc:	74 14                	je     8008f2 <strnlen+0x27>
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e6:	39 c8                	cmp    %ecx,%eax
  8008e8:	74 0d                	je     8008f7 <strnlen+0x2c>
  8008ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008ee:	75 f3                	jne    8008e3 <strnlen+0x18>
  8008f0:	eb 05                	jmp    8008f7 <strnlen+0x2c>
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800904:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800909:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80090d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800910:	83 c2 01             	add    $0x1,%edx
  800913:	84 c9                	test   %cl,%cl
  800915:	75 f2                	jne    800909 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800917:	5b                   	pop    %ebx
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800928:	85 f6                	test   %esi,%esi
  80092a:	74 18                	je     800944 <strncpy+0x2a>
  80092c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800931:	0f b6 1a             	movzbl (%edx),%ebx
  800934:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800937:	80 3a 01             	cmpb   $0x1,(%edx)
  80093a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093d:	83 c1 01             	add    $0x1,%ecx
  800940:	39 ce                	cmp    %ecx,%esi
  800942:	77 ed                	ja     800931 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 75 08             	mov    0x8(%ebp),%esi
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800956:	89 f0                	mov    %esi,%eax
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 27                	je     800983 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  80095c:	83 e9 01             	sub    $0x1,%ecx
  80095f:	74 1d                	je     80097e <strlcpy+0x36>
  800961:	0f b6 1a             	movzbl (%edx),%ebx
  800964:	84 db                	test   %bl,%bl
  800966:	74 16                	je     80097e <strlcpy+0x36>
			*dst++ = *src++;
  800968:	88 18                	mov    %bl,(%eax)
  80096a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80096d:	83 e9 01             	sub    $0x1,%ecx
  800970:	74 0e                	je     800980 <strlcpy+0x38>
			*dst++ = *src++;
  800972:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800975:	0f b6 1a             	movzbl (%edx),%ebx
  800978:	84 db                	test   %bl,%bl
  80097a:	75 ec                	jne    800968 <strlcpy+0x20>
  80097c:	eb 02                	jmp    800980 <strlcpy+0x38>
  80097e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800980:	c6 00 00             	movb   $0x0,(%eax)
  800983:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800992:	0f b6 01             	movzbl (%ecx),%eax
  800995:	84 c0                	test   %al,%al
  800997:	74 15                	je     8009ae <strcmp+0x25>
  800999:	3a 02                	cmp    (%edx),%al
  80099b:	75 11                	jne    8009ae <strcmp+0x25>
		p++, q++;
  80099d:	83 c1 01             	add    $0x1,%ecx
  8009a0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	84 c0                	test   %al,%al
  8009a8:	74 04                	je     8009ae <strcmp+0x25>
  8009aa:	3a 02                	cmp    (%edx),%al
  8009ac:	74 ef                	je     80099d <strcmp+0x14>
  8009ae:	0f b6 c0             	movzbl %al,%eax
  8009b1:	0f b6 12             	movzbl (%edx),%edx
  8009b4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	74 23                	je     8009ec <strncmp+0x34>
  8009c9:	0f b6 1a             	movzbl (%edx),%ebx
  8009cc:	84 db                	test   %bl,%bl
  8009ce:	74 24                	je     8009f4 <strncmp+0x3c>
  8009d0:	3a 19                	cmp    (%ecx),%bl
  8009d2:	75 20                	jne    8009f4 <strncmp+0x3c>
  8009d4:	83 e8 01             	sub    $0x1,%eax
  8009d7:	74 13                	je     8009ec <strncmp+0x34>
		n--, p++, q++;
  8009d9:	83 c2 01             	add    $0x1,%edx
  8009dc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009df:	0f b6 1a             	movzbl (%edx),%ebx
  8009e2:	84 db                	test   %bl,%bl
  8009e4:	74 0e                	je     8009f4 <strncmp+0x3c>
  8009e6:	3a 19                	cmp    (%ecx),%bl
  8009e8:	74 ea                	je     8009d4 <strncmp+0x1c>
  8009ea:	eb 08                	jmp    8009f4 <strncmp+0x3c>
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f1:	5b                   	pop    %ebx
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f4:	0f b6 02             	movzbl (%edx),%eax
  8009f7:	0f b6 11             	movzbl (%ecx),%edx
  8009fa:	29 d0                	sub    %edx,%eax
  8009fc:	eb f3                	jmp    8009f1 <strncmp+0x39>

008009fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a08:	0f b6 10             	movzbl (%eax),%edx
  800a0b:	84 d2                	test   %dl,%dl
  800a0d:	74 15                	je     800a24 <strchr+0x26>
		if (*s == c)
  800a0f:	38 ca                	cmp    %cl,%dl
  800a11:	75 07                	jne    800a1a <strchr+0x1c>
  800a13:	eb 14                	jmp    800a29 <strchr+0x2b>
  800a15:	38 ca                	cmp    %cl,%dl
  800a17:	90                   	nop
  800a18:	74 0f                	je     800a29 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 f1                	jne    800a15 <strchr+0x17>
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	74 18                	je     800a54 <strfind+0x29>
		if (*s == c)
  800a3c:	38 ca                	cmp    %cl,%dl
  800a3e:	75 0a                	jne    800a4a <strfind+0x1f>
  800a40:	eb 12                	jmp    800a54 <strfind+0x29>
  800a42:	38 ca                	cmp    %cl,%dl
  800a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a48:	74 0a                	je     800a54 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	84 d2                	test   %dl,%dl
  800a52:	75 ee                	jne    800a42 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a63:	89 da                	mov    %ebx,%edx
  800a65:	83 ea 01             	sub    $0x1,%edx
  800a68:	78 0d                	js     800a77 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  800a6a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a6c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a6e:	88 0a                	mov    %cl,(%edx)
  800a70:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a73:	39 da                	cmp    %ebx,%edx
  800a75:	75 f7                	jne    800a6e <memset+0x18>
		*p++ = c;

	return v;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a88:	85 db                	test   %ebx,%ebx
  800a8a:	74 13                	je     800a9f <memcpy+0x25>
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800a91:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a95:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a98:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a9b:	39 da                	cmp    %ebx,%edx
  800a9d:	75 f2                	jne    800a91 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800ab2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800ab4:	39 c6                	cmp    %eax,%esi
  800ab6:	72 0b                	jb     800ac3 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800abd:	85 db                	test   %ebx,%ebx
  800abf:	75 2e                	jne    800aef <memmove+0x4c>
  800ac1:	eb 3a                	jmp    800afd <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac3:	01 df                	add    %ebx,%edi
  800ac5:	39 f8                	cmp    %edi,%eax
  800ac7:	73 ef                	jae    800ab8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	90                   	nop
  800acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ad0:	74 2b                	je     800afd <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800ad2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800ada:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800adf:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800ae3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800ae6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800ae9:	85 c9                	test   %ecx,%ecx
  800aeb:	75 ed                	jne    800ada <memmove+0x37>
  800aed:	eb 0e                	jmp    800afd <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800aef:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800af3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800af6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800af9:	39 d3                	cmp    %edx,%ebx
  800afb:	75 f2                	jne    800aef <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b11:	85 c9                	test   %ecx,%ecx
  800b13:	74 36                	je     800b4b <memcmp+0x49>
		if (*s1 != *s2)
  800b15:	0f b6 06             	movzbl (%esi),%eax
  800b18:	0f b6 1f             	movzbl (%edi),%ebx
  800b1b:	38 d8                	cmp    %bl,%al
  800b1d:	74 20                	je     800b3f <memcmp+0x3d>
  800b1f:	eb 14                	jmp    800b35 <memcmp+0x33>
  800b21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b2b:	83 c2 01             	add    $0x1,%edx
  800b2e:	83 e9 01             	sub    $0x1,%ecx
  800b31:	38 d8                	cmp    %bl,%al
  800b33:	74 12                	je     800b47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b35:	0f b6 c0             	movzbl %al,%eax
  800b38:	0f b6 db             	movzbl %bl,%ebx
  800b3b:	29 d8                	sub    %ebx,%eax
  800b3d:	eb 11                	jmp    800b50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	83 e9 01             	sub    $0x1,%ecx
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	85 c9                	test   %ecx,%ecx
  800b49:	75 d6                	jne    800b21 <memcmp+0x1f>
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b60:	39 d0                	cmp    %edx,%eax
  800b62:	73 15                	jae    800b79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b68:	38 08                	cmp    %cl,(%eax)
  800b6a:	75 06                	jne    800b72 <memfind+0x1d>
  800b6c:	eb 0b                	jmp    800b79 <memfind+0x24>
  800b6e:	38 08                	cmp    %cl,(%eax)
  800b70:	74 07                	je     800b79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	39 c2                	cmp    %eax,%edx
  800b77:	77 f5                	ja     800b6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 04             	sub    $0x4,%esp
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8a:	0f b6 02             	movzbl (%edx),%eax
  800b8d:	3c 20                	cmp    $0x20,%al
  800b8f:	74 04                	je     800b95 <strtol+0x1a>
  800b91:	3c 09                	cmp    $0x9,%al
  800b93:	75 0e                	jne    800ba3 <strtol+0x28>
		s++;
  800b95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b98:	0f b6 02             	movzbl (%edx),%eax
  800b9b:	3c 20                	cmp    $0x20,%al
  800b9d:	74 f6                	je     800b95 <strtol+0x1a>
  800b9f:	3c 09                	cmp    $0x9,%al
  800ba1:	74 f2                	je     800b95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba3:	3c 2b                	cmp    $0x2b,%al
  800ba5:	75 0c                	jne    800bb3 <strtol+0x38>
		s++;
  800ba7:	83 c2 01             	add    $0x1,%edx
  800baa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bb1:	eb 15                	jmp    800bc8 <strtol+0x4d>
	else if (*s == '-')
  800bb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bba:	3c 2d                	cmp    $0x2d,%al
  800bbc:	75 0a                	jne    800bc8 <strtol+0x4d>
		s++, neg = 1;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc8:	85 db                	test   %ebx,%ebx
  800bca:	0f 94 c0             	sete   %al
  800bcd:	74 05                	je     800bd4 <strtol+0x59>
  800bcf:	83 fb 10             	cmp    $0x10,%ebx
  800bd2:	75 18                	jne    800bec <strtol+0x71>
  800bd4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd7:	75 13                	jne    800bec <strtol+0x71>
  800bd9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
  800be0:	75 0a                	jne    800bec <strtol+0x71>
		s += 2, base = 16;
  800be2:	83 c2 02             	add    $0x2,%edx
  800be5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bea:	eb 15                	jmp    800c01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bec:	84 c0                	test   %al,%al
  800bee:	66 90                	xchg   %ax,%ax
  800bf0:	74 0f                	je     800c01 <strtol+0x86>
  800bf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bf7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfa:	75 05                	jne    800c01 <strtol+0x86>
		s++, base = 8;
  800bfc:	83 c2 01             	add    $0x1,%edx
  800bff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
  800c06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c08:	0f b6 0a             	movzbl (%edx),%ecx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c10:	80 fb 09             	cmp    $0x9,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xa2>
			dig = *s - '0';
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 30             	sub    $0x30,%ecx
  800c1b:	eb 1e                	jmp    800c3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 08                	ja     800c2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 57             	sub    $0x57,%ecx
  800c2b:	eb 0e                	jmp    800c3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c30:	80 fb 19             	cmp    $0x19,%bl
  800c33:	77 15                	ja     800c4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c35:	0f be c9             	movsbl %cl,%ecx
  800c38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c3b:	39 f1                	cmp    %esi,%ecx
  800c3d:	7d 0b                	jge    800c4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c3f:	83 c2 01             	add    $0x1,%edx
  800c42:	0f af c6             	imul   %esi,%eax
  800c45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c48:	eb be                	jmp    800c08 <strtol+0x8d>
  800c4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c50:	74 05                	je     800c57 <strtol+0xdc>
		*endptr = (char *) s;
  800c52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c57:	89 ca                	mov    %ecx,%edx
  800c59:	f7 da                	neg    %edx
  800c5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c5f:	0f 45 c2             	cmovne %edx,%eax
}
  800c62:	83 c4 04             	add    $0x4,%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
	...

00800c6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 c3                	mov    %eax,%ebx
  800c8a:	89 c7                	mov    %eax,%edi
  800c8c:	89 c6                	mov    %eax,%esi
  800c8e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800c90:	8b 1c 24             	mov    (%esp),%ebx
  800c93:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c97:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c9b:	89 ec                	mov    %ebp,%esp
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	89 1c 24             	mov    %ebx,(%esp)
  800ca8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cac:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	89 d3                	mov    %edx,%ebx
  800cbe:	89 d7                	mov    %edx,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800cc4:	8b 1c 24             	mov    (%esp),%ebx
  800cc7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ccb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ccf:	89 ec                	mov    %ebp,%esp
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 0c             	sub    $0xc,%esp
  800cd9:	89 1c 24             	mov    %ebx,(%esp)
  800cdc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	89 cb                	mov    %ecx,%ebx
  800cf3:	89 cf                	mov    %ecx,%edi
  800cf5:	89 ce                	mov    %ecx,%esi
  800cf7:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800cf9:	8b 1c 24             	mov    (%esp),%ebx
  800cfc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d00:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d04:	89 ec                	mov    %ebp,%esp
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	89 1c 24             	mov    %ebx,(%esp)
  800d11:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d15:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	89 d3                	mov    %edx,%ebx
  800d27:	89 d7                	mov    %edx,%edi
  800d29:	89 d6                	mov    %edx,%esi
  800d2b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800d2d:	8b 1c 24             	mov    (%esp),%ebx
  800d30:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d38:	89 ec                	mov    %ebp,%esp
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_yield>:

void
sys_yield(void)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	89 1c 24             	mov    %ebx,(%esp)
  800d45:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d49:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800d61:	8b 1c 24             	mov    (%esp),%ebx
  800d64:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d68:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d6c:	89 ec                	mov    %ebp,%esp
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	89 1c 24             	mov    %ebx,(%esp)
  800d79:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	be 00 00 00 00       	mov    $0x0,%esi
  800d86:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 f7                	mov    %esi,%edi
  800d96:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800d98:	8b 1c 24             	mov    (%esp),%ebx
  800d9b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d9f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da3:	89 ec                	mov    %ebp,%esp
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	89 1c 24             	mov    %ebx,(%esp)
  800db0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	b8 05 00 00 00       	mov    $0x5,%eax
  800dbd:	8b 75 18             	mov    0x18(%ebp),%esi
  800dc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dce:	8b 1c 24             	mov    (%esp),%ebx
  800dd1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dd9:	89 ec                	mov    %ebp,%esp
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	89 1c 24             	mov    %ebx,(%esp)
  800de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dea:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df3:	b8 06 00 00 00       	mov    $0x6,%eax
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 df                	mov    %ebx,%edi
  800e00:	89 de                	mov    %ebx,%esi
  800e02:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800e04:	8b 1c 24             	mov    (%esp),%ebx
  800e07:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e0b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e0f:	89 ec                	mov    %ebp,%esp
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	89 1c 24             	mov    %ebx,(%esp)
  800e1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e20:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e29:	b8 08 00 00 00       	mov    $0x8,%eax
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	89 df                	mov    %ebx,%edi
  800e36:	89 de                	mov    %ebx,%esi
  800e38:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800e3a:	8b 1c 24             	mov    (%esp),%ebx
  800e3d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e41:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e45:	89 ec                	mov    %ebp,%esp
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	89 1c 24             	mov    %ebx,(%esp)
  800e52:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e56:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800e70:	8b 1c 24             	mov    (%esp),%ebx
  800e73:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e77:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e7b:	89 ec                	mov    %ebp,%esp
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 0c             	sub    $0xc,%esp
  800e85:	89 1c 24             	mov    %ebx,(%esp)
  800e88:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	89 df                	mov    %ebx,%edi
  800ea2:	89 de                	mov    %ebx,%esi
  800ea4:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea6:	8b 1c 24             	mov    (%esp),%ebx
  800ea9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ead:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800eb1:	89 ec                	mov    %ebp,%esp
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	89 1c 24             	mov    %ebx,(%esp)
  800ebe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ec2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec6:	be 00 00 00 00       	mov    $0x0,%esi
  800ecb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ed0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800ede:	8b 1c 24             	mov    (%esp),%ebx
  800ee1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ee5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ee9:	89 ec                	mov    %ebp,%esp
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	83 ec 0c             	sub    $0xc,%esp
  800ef3:	89 1c 24             	mov    %ebx,(%esp)
  800ef6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efa:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f03:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	89 cb                	mov    %ecx,%ebx
  800f0d:	89 cf                	mov    %ecx,%edi
  800f0f:	89 ce                	mov    %ecx,%esi
  800f11:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800f13:	8b 1c 24             	mov    (%esp),%ebx
  800f16:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f1a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f1e:	89 ec                	mov    %ebp,%esp
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
	...

00800f24 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f2a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800f31:	75 54                	jne    800f87 <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  800f33:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f42:	ee 
  800f43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f4a:	e8 21 fe ff ff       	call   800d70 <sys_page_alloc>
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 20                	jns    800f73 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  800f53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f57:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800f66:	00 
  800f67:	c7 04 24 3c 15 80 00 	movl   $0x80153c,(%esp)
  800f6e:	e8 ed f1 ff ff       	call   800160 <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  800f73:	c7 44 24 04 94 0f 80 	movl   $0x800f94,0x4(%esp)
  800f7a:	00 
  800f7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f82:	e8 f8 fe ff ff       	call   800e7f <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    
  800f91:	00 00                	add    %al,(%eax)
	...

00800f94 <_pgfault_upcall>:
  800f94:	54                   	push   %esp
  800f95:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800f9a:	ff d0                	call   *%eax
  800f9c:	83 c4 04             	add    $0x4,%esp
  800f9f:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fa3:	83 e8 04             	sub    $0x4,%eax
  800fa6:	89 44 24 30          	mov    %eax,0x30(%esp)
  800faa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  800fae:	89 18                	mov    %ebx,(%eax)
  800fb0:	83 c4 08             	add    $0x8,%esp
  800fb3:	61                   	popa   
  800fb4:	83 c4 04             	add    $0x4,%esp
  800fb7:	9d                   	popf   
  800fb8:	5c                   	pop    %esp
  800fb9:	c3                   	ret    
  800fba:	00 00                	add    %al,(%eax)
  800fbc:	00 00                	add    %al,(%eax)
	...

00800fc0 <__udivdi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	83 ec 10             	sub    $0x10,%esp
  800fc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fce:	8b 75 10             	mov    0x10(%ebp),%esi
  800fd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800fd9:	75 35                	jne    801010 <__udivdi3+0x50>
  800fdb:	39 fe                	cmp    %edi,%esi
  800fdd:	77 61                	ja     801040 <__udivdi3+0x80>
  800fdf:	85 f6                	test   %esi,%esi
  800fe1:	75 0b                	jne    800fee <__udivdi3+0x2e>
  800fe3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe8:	31 d2                	xor    %edx,%edx
  800fea:	f7 f6                	div    %esi
  800fec:	89 c6                	mov    %eax,%esi
  800fee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800ff1:	31 d2                	xor    %edx,%edx
  800ff3:	89 f8                	mov    %edi,%eax
  800ff5:	f7 f6                	div    %esi
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	89 c8                	mov    %ecx,%eax
  800ffb:	f7 f6                	div    %esi
  800ffd:	89 c1                	mov    %eax,%ecx
  800fff:	89 fa                	mov    %edi,%edx
  801001:	89 c8                	mov    %ecx,%eax
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    
  80100a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801010:	39 f8                	cmp    %edi,%eax
  801012:	77 1c                	ja     801030 <__udivdi3+0x70>
  801014:	0f bd d0             	bsr    %eax,%edx
  801017:	83 f2 1f             	xor    $0x1f,%edx
  80101a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80101d:	75 39                	jne    801058 <__udivdi3+0x98>
  80101f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801022:	0f 86 a0 00 00 00    	jbe    8010c8 <__udivdi3+0x108>
  801028:	39 f8                	cmp    %edi,%eax
  80102a:	0f 82 98 00 00 00    	jb     8010c8 <__udivdi3+0x108>
  801030:	31 ff                	xor    %edi,%edi
  801032:	31 c9                	xor    %ecx,%ecx
  801034:	89 c8                	mov    %ecx,%eax
  801036:	89 fa                	mov    %edi,%edx
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    
  80103f:	90                   	nop
  801040:	89 d1                	mov    %edx,%ecx
  801042:	89 fa                	mov    %edi,%edx
  801044:	89 c8                	mov    %ecx,%eax
  801046:	31 ff                	xor    %edi,%edi
  801048:	f7 f6                	div    %esi
  80104a:	89 c1                	mov    %eax,%ecx
  80104c:	89 fa                	mov    %edi,%edx
  80104e:	89 c8                	mov    %ecx,%eax
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
  801057:	90                   	nop
  801058:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80105c:	89 f2                	mov    %esi,%edx
  80105e:	d3 e0                	shl    %cl,%eax
  801060:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801063:	b8 20 00 00 00       	mov    $0x20,%eax
  801068:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80106b:	89 c1                	mov    %eax,%ecx
  80106d:	d3 ea                	shr    %cl,%edx
  80106f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801073:	0b 55 ec             	or     -0x14(%ebp),%edx
  801076:	d3 e6                	shl    %cl,%esi
  801078:	89 c1                	mov    %eax,%ecx
  80107a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80107d:	89 fe                	mov    %edi,%esi
  80107f:	d3 ee                	shr    %cl,%esi
  801081:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801085:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801088:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108b:	d3 e7                	shl    %cl,%edi
  80108d:	89 c1                	mov    %eax,%ecx
  80108f:	d3 ea                	shr    %cl,%edx
  801091:	09 d7                	or     %edx,%edi
  801093:	89 f2                	mov    %esi,%edx
  801095:	89 f8                	mov    %edi,%eax
  801097:	f7 75 ec             	divl   -0x14(%ebp)
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	89 c7                	mov    %eax,%edi
  80109e:	f7 65 e8             	mull   -0x18(%ebp)
  8010a1:	39 d6                	cmp    %edx,%esi
  8010a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010a6:	72 30                	jb     8010d8 <__udivdi3+0x118>
  8010a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010af:	d3 e2                	shl    %cl,%edx
  8010b1:	39 c2                	cmp    %eax,%edx
  8010b3:	73 05                	jae    8010ba <__udivdi3+0xfa>
  8010b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010b8:	74 1e                	je     8010d8 <__udivdi3+0x118>
  8010ba:	89 f9                	mov    %edi,%ecx
  8010bc:	31 ff                	xor    %edi,%edi
  8010be:	e9 71 ff ff ff       	jmp    801034 <__udivdi3+0x74>
  8010c3:	90                   	nop
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	31 ff                	xor    %edi,%edi
  8010ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010cf:	e9 60 ff ff ff       	jmp    801034 <__udivdi3+0x74>
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010db:	31 ff                	xor    %edi,%edi
  8010dd:	89 c8                	mov    %ecx,%eax
  8010df:	89 fa                	mov    %edi,%edx
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    
	...

008010f0 <__umoddi3>:
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	83 ec 20             	sub    $0x20,%esp
  8010f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801101:	8b 75 0c             	mov    0xc(%ebp),%esi
  801104:	85 d2                	test   %edx,%edx
  801106:	89 c8                	mov    %ecx,%eax
  801108:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80110b:	75 13                	jne    801120 <__umoddi3+0x30>
  80110d:	39 f7                	cmp    %esi,%edi
  80110f:	76 3f                	jbe    801150 <__umoddi3+0x60>
  801111:	89 f2                	mov    %esi,%edx
  801113:	f7 f7                	div    %edi
  801115:	89 d0                	mov    %edx,%eax
  801117:	31 d2                	xor    %edx,%edx
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    
  801120:	39 f2                	cmp    %esi,%edx
  801122:	77 4c                	ja     801170 <__umoddi3+0x80>
  801124:	0f bd ca             	bsr    %edx,%ecx
  801127:	83 f1 1f             	xor    $0x1f,%ecx
  80112a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80112d:	75 51                	jne    801180 <__umoddi3+0x90>
  80112f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801132:	0f 87 e0 00 00 00    	ja     801218 <__umoddi3+0x128>
  801138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113b:	29 f8                	sub    %edi,%eax
  80113d:	19 d6                	sbb    %edx,%esi
  80113f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801145:	89 f2                	mov    %esi,%edx
  801147:	83 c4 20             	add    $0x20,%esp
  80114a:	5e                   	pop    %esi
  80114b:	5f                   	pop    %edi
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    
  80114e:	66 90                	xchg   %ax,%ax
  801150:	85 ff                	test   %edi,%edi
  801152:	75 0b                	jne    80115f <__umoddi3+0x6f>
  801154:	b8 01 00 00 00       	mov    $0x1,%eax
  801159:	31 d2                	xor    %edx,%edx
  80115b:	f7 f7                	div    %edi
  80115d:	89 c7                	mov    %eax,%edi
  80115f:	89 f0                	mov    %esi,%eax
  801161:	31 d2                	xor    %edx,%edx
  801163:	f7 f7                	div    %edi
  801165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801168:	f7 f7                	div    %edi
  80116a:	eb a9                	jmp    801115 <__umoddi3+0x25>
  80116c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801170:	89 c8                	mov    %ecx,%eax
  801172:	89 f2                	mov    %esi,%edx
  801174:	83 c4 20             	add    $0x20,%esp
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    
  80117b:	90                   	nop
  80117c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801180:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801184:	d3 e2                	shl    %cl,%edx
  801186:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801189:	ba 20 00 00 00       	mov    $0x20,%edx
  80118e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801191:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801194:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801198:	89 fa                	mov    %edi,%edx
  80119a:	d3 ea                	shr    %cl,%edx
  80119c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011a3:	d3 e7                	shl    %cl,%edi
  8011a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011ac:	89 f2                	mov    %esi,%edx
  8011ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011b1:	89 c7                	mov    %eax,%edi
  8011b3:	d3 ea                	shr    %cl,%edx
  8011b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	d3 e6                	shl    %cl,%esi
  8011c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c4:	d3 ea                	shr    %cl,%edx
  8011c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ca:	09 d6                	or     %edx,%esi
  8011cc:	89 f0                	mov    %esi,%eax
  8011ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011d1:	d3 e7                	shl    %cl,%edi
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	f7 75 f4             	divl   -0xc(%ebp)
  8011d8:	89 d6                	mov    %edx,%esi
  8011da:	f7 65 e8             	mull   -0x18(%ebp)
  8011dd:	39 d6                	cmp    %edx,%esi
  8011df:	72 2b                	jb     80120c <__umoddi3+0x11c>
  8011e1:	39 c7                	cmp    %eax,%edi
  8011e3:	72 23                	jb     801208 <__umoddi3+0x118>
  8011e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e9:	29 c7                	sub    %eax,%edi
  8011eb:	19 d6                	sbb    %edx,%esi
  8011ed:	89 f0                	mov    %esi,%eax
  8011ef:	89 f2                	mov    %esi,%edx
  8011f1:	d3 ef                	shr    %cl,%edi
  8011f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f7:	d3 e0                	shl    %cl,%eax
  8011f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011fd:	09 f8                	or     %edi,%eax
  8011ff:	d3 ea                	shr    %cl,%edx
  801201:	83 c4 20             	add    $0x20,%esp
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    
  801208:	39 d6                	cmp    %edx,%esi
  80120a:	75 d9                	jne    8011e5 <__umoddi3+0xf5>
  80120c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80120f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801212:	eb d1                	jmp    8011e5 <__umoddi3+0xf5>
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	39 f2                	cmp    %esi,%edx
  80121a:	0f 82 18 ff ff ff    	jb     801138 <__umoddi3+0x48>
  801220:	e9 1d ff ff ff       	jmp    801142 <__umoddi3+0x52>
