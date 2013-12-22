
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 1f 02 00 00       	call   800250 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 6a 0e 00 00       	call   800ec0 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 00 13 80 	movl   $0x801300,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  800075:	e8 3e 02 00 00       	call   8002b8 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 59 0e 00 00       	call   800ef7 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 23 13 80 	movl   $0x801323,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  8000bd:	e8 f6 01 00 00       	call   8002b8 <_panic>
	memcpy(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 f0 0a 00 00       	call   800bca <memcpy>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 3f 0e 00 00       	call   800f2d <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 34 13 80 	movl   $0x801334,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  80010d:	e8 a6 01 00 00       	call   8002b8 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	53                   	push   %ebx
  80011d:	83 ec 24             	sub    $0x24,%esp
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800120:	bb 07 00 00 00       	mov    $0x7,%ebx
  800125:	89 d8                	mov    %ebx,%eax
  800127:	cd 30                	int    $0x30
  800129:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();//调用一次却返回两次
	if (envid < 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	79 20                	jns    80014f <dumbfork+0x36>
		panic("sys_exofork: %e", envid);
  80012f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800133:	c7 44 24 08 47 13 80 	movl   $0x801347,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  80014a:	e8 69 01 00 00       	call   8002b8 <_panic>
	if (envid == 0) {//返回值为0的是子进程
  80014f:	85 c0                	test   %eax,%eax
  800151:	75 1d                	jne    800170 <dumbfork+0x57>
		// We're the child.
		// The copied value of the global variable 'env'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		env = &envs[ENVX(sys_getenvid())];
  800153:	e8 00 0d 00 00       	call   800e58 <sys_getenvid>
  800158:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015d:	89 c2                	mov    %eax,%edx
  80015f:	c1 e2 07             	shl    $0x7,%edx
  800162:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800169:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80016e:	eb 7e                	jmp    8001ee <dumbfork+0xd5>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)//否则为父进程
  800170:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800177:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80017c:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800181:	76 23                	jbe    8001a6 <dumbfork+0x8d>
  800183:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	89 1c 24             	mov    %ebx,(%esp)
  80018f:	e8 a0 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)//否则为父进程
  800194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800197:	05 00 10 00 00       	add    $0x1000,%eax
  80019c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019f:	3d 0c 20 80 00       	cmp    $0x80200c,%eax
  8001a4:	72 e2                	jb     800188 <dumbfork+0x6f>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b2:	89 1c 24             	mov    %ebx,(%esp)
  8001b5:	e8 7a fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c1:	00 
  8001c2:	89 1c 24             	mov    %ebx,(%esp)
  8001c5:	e8 99 0d 00 00       	call   800f63 <sys_env_set_status>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <dumbfork+0xd5>
		panic("sys_env_set_status: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 57 13 80 	movl   $0x801357,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  8001e9:	e8 ca 00 00 00       	call   8002b8 <_panic>

	return envid;
}
  8001ee:	89 d8                	mov    %ebx,%eax
  8001f0:	83 c4 24             	add    $0x24,%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:

envid_t dumbfork(void);

void
umain(void)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	57                   	push   %edi
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
  8001fc:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();//  fork函数调用一次 却返回两次
  8001ff:	e8 15 ff ff ff       	call   800119 <dumbfork>
  800204:	89 c6                	mov    %eax,%esi
  800206:	bb 00 00 00 00       	mov    $0x0,%ebx

	//若who==0，则为子进程，且i<20，所以子进程存活20次，因为在who<0的情况已经panic了，所以若who>0，则为父进程，且i<10,所以父进程存活10次
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020b:	bf 74 13 80 00       	mov    $0x801374,%edi
	// fork a child process
	who = dumbfork();//  fork函数调用一次 却返回两次

	//若who==0，则为子进程，且i<20，所以子进程存活20次，因为在who<0的情况已经panic了，所以若who>0，则为父进程，且i<10,所以父进程存活10次
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800210:	eb 26                	jmp    800238 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800212:	85 f6                	test   %esi,%esi
  800214:	b8 6e 13 80 00       	mov    $0x80136e,%eax
  800219:	0f 45 c7             	cmovne %edi,%eax
  80021c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	c7 04 24 7b 13 80 00 	movl   $0x80137b,(%esp)
  80022b:	e8 4d 01 00 00       	call   80037d <cprintf>
		sys_yield();
  800230:	e8 57 0c 00 00       	call   800e8c <sys_yield>
	// fork a child process
	who = dumbfork();//  fork函数调用一次 却返回两次

	//若who==0，则为子进程，且i<20，所以子进程存活20次，因为在who<0的情况已经panic了，所以若who>0，则为父进程，且i<10,所以父进程存活10次
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800235:	83 c3 01             	add    $0x1,%ebx
  800238:	83 fe 01             	cmp    $0x1,%esi
  80023b:	19 c0                	sbb    %eax,%eax
  80023d:	83 e0 0a             	and    $0xa,%eax
  800240:	83 c0 0a             	add    $0xa,%eax
  800243:	39 c3                	cmp    %eax,%ebx
  800245:	7c cb                	jl     800212 <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800247:	83 c4 1c             	add    $0x1c,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    
	...

00800250 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
  800256:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800259:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80025c:	8b 75 08             	mov    0x8(%ebp),%esi
  80025f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  800262:	e8 f1 0b 00 00       	call   800e58 <sys_getenvid>
  800267:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026c:	89 c2                	mov    %eax,%edx
  80026e:	c1 e2 07             	shl    $0x7,%edx
  800271:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800278:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80027d:	85 f6                	test   %esi,%esi
  80027f:	7e 07                	jle    800288 <libmain+0x38>
		binaryname = argv[0];
  800281:	8b 03                	mov    (%ebx),%eax
  800283:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800288:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80028c:	89 34 24             	mov    %esi,(%esp)
  80028f:	e8 62 ff ff ff       	call   8001f6 <umain>

	// exit gracefully
	exit();
  800294:	e8 0b 00 00 00       	call   8002a4 <exit>
}
  800299:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80029c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80029f:	89 ec                	mov    %ebp,%esp
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    
	...

008002a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b1:	e8 6d 0b 00 00       	call   800e23 <sys_env_destroy>
}
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8002be:	a1 08 20 80 00       	mov    0x802008,%eax
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	74 10                	je     8002d7 <_panic+0x1f>
		cprintf("%s: ", argv0);
  8002c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cb:	c7 04 24 a4 13 80 00 	movl   $0x8013a4,(%esp)
  8002d2:	e8 a6 00 00 00       	call   80037d <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8002d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e5:	a1 00 20 80 00       	mov    0x802000,%eax
  8002ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ee:	c7 04 24 a9 13 80 00 	movl   $0x8013a9,(%esp)
  8002f5:	e8 83 00 00 00       	call   80037d <cprintf>
	vcprintf(fmt, ap);
  8002fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8002fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800301:	8b 45 10             	mov    0x10(%ebp),%eax
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	e8 10 00 00 00       	call   80031c <vcprintf>
	cprintf("\n");
  80030c:	c7 04 24 8b 13 80 00 	movl   $0x80138b,(%esp)
  800313:	e8 65 00 00 00       	call   80037d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800318:	cc                   	int3   
  800319:	eb fd                	jmp    800318 <_panic+0x60>
	...

0080031c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800325:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032c:	00 00 00 
	b.cnt = 0;
  80032f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800336:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800339:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800340:	8b 45 08             	mov    0x8(%ebp),%eax
  800343:	89 44 24 08          	mov    %eax,0x8(%esp)
  800347:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	c7 04 24 97 03 80 00 	movl   $0x800397,(%esp)
  800358:	e8 d3 01 00 00       	call   800530 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800363:	89 44 24 04          	mov    %eax,0x4(%esp)
  800367:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036d:	89 04 24             	mov    %eax,(%esp)
  800370:	e8 47 0a 00 00       	call   800dbc <sys_cputs>

	return b.cnt;
}
  800375:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037b:	c9                   	leave  
  80037c:	c3                   	ret    

0080037d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800383:	8d 45 0c             	lea    0xc(%ebp),%eax
  800386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	89 04 24             	mov    %eax,(%esp)
  800390:	e8 87 ff ff ff       	call   80031c <vcprintf>
	va_end(ap);

	return cnt;
}
  800395:	c9                   	leave  
  800396:	c3                   	ret    

00800397 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	53                   	push   %ebx
  80039b:	83 ec 14             	sub    $0x14,%esp
  80039e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a1:	8b 03                	mov    (%ebx),%eax
  8003a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b4:	75 19                	jne    8003cf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003b6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003bd:	00 
  8003be:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c1:	89 04 24             	mov    %eax,(%esp)
  8003c4:	e8 f3 09 00 00       	call   800dbc <sys_cputs>
		b->idx = 0;
  8003c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d3:	83 c4 14             	add    $0x14,%esp
  8003d6:	5b                   	pop    %ebx
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    
  8003d9:	00 00                	add    %al,(%eax)
  8003db:	00 00                	add    %al,(%eax)
  8003dd:	00 00                	add    %al,(%eax)
	...

008003e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 4c             	sub    $0x4c,%esp
  8003e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ec:	89 d6                	mov    %edx,%esi
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800400:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800403:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800406:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040b:	39 d1                	cmp    %edx,%ecx
  80040d:	72 15                	jb     800424 <printnum+0x44>
  80040f:	77 07                	ja     800418 <printnum+0x38>
  800411:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800414:	39 d0                	cmp    %edx,%eax
  800416:	76 0c                	jbe    800424 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800418:	83 eb 01             	sub    $0x1,%ebx
  80041b:	85 db                	test   %ebx,%ebx
  80041d:	8d 76 00             	lea    0x0(%esi),%esi
  800420:	7f 61                	jg     800483 <printnum+0xa3>
  800422:	eb 70                	jmp    800494 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800424:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800428:	83 eb 01             	sub    $0x1,%ebx
  80042b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80042f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800433:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800437:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80043b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80043e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800441:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800444:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800448:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044f:	00 
  800450:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800453:	89 04 24             	mov    %eax,(%esp)
  800456:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800459:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045d:	e8 1e 0c 00 00       	call   801080 <__udivdi3>
  800462:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800465:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80046c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	89 54 24 04          	mov    %edx,0x4(%esp)
  800477:	89 f2                	mov    %esi,%edx
  800479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80047c:	e8 5f ff ff ff       	call   8003e0 <printnum>
  800481:	eb 11                	jmp    800494 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800483:	89 74 24 04          	mov    %esi,0x4(%esp)
  800487:	89 3c 24             	mov    %edi,(%esp)
  80048a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80048d:	83 eb 01             	sub    $0x1,%ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	7f ef                	jg     800483 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800494:	89 74 24 04          	mov    %esi,0x4(%esp)
  800498:	8b 74 24 04          	mov    0x4(%esp),%esi
  80049c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80049f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004aa:	00 
  8004ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ae:	89 14 24             	mov    %edx,(%esp)
  8004b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b8:	e8 f3 0c 00 00       	call   8011b0 <__umoddi3>
  8004bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c1:	0f be 80 c5 13 80 00 	movsbl 0x8013c5(%eax),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004ce:	83 c4 4c             	add    $0x4c,%esp
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d9:	83 fa 01             	cmp    $0x1,%edx
  8004dc:	7e 0f                	jle    8004ed <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	83 c2 08             	add    $0x8,%edx
  8004e3:	89 10                	mov    %edx,(%eax)
  8004e5:	8b 42 f8             	mov    -0x8(%edx),%eax
  8004e8:	8b 52 fc             	mov    -0x4(%edx),%edx
  8004eb:	eb 24                	jmp    800511 <getuint+0x3b>
	else if (lflag)
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	74 11                	je     800502 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	83 c2 04             	add    $0x4,%edx
  8004f6:	89 10                	mov    %edx,(%eax)
  8004f8:	8b 42 fc             	mov    -0x4(%edx),%eax
  8004fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800500:	eb 0f                	jmp    800511 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  800502:	8b 10                	mov    (%eax),%edx
  800504:	83 c2 04             	add    $0x4,%edx
  800507:	89 10                	mov    %edx,(%eax)
  800509:	8b 42 fc             	mov    -0x4(%edx),%eax
  80050c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    

00800513 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800519:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051d:	8b 10                	mov    (%eax),%edx
  80051f:	3b 50 04             	cmp    0x4(%eax),%edx
  800522:	73 0a                	jae    80052e <sprintputch+0x1b>
		*b->buf++ = ch;
  800524:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800527:	88 0a                	mov    %cl,(%edx)
  800529:	83 c2 01             	add    $0x1,%edx
  80052c:	89 10                	mov    %edx,(%eax)
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	57                   	push   %edi
  800534:	56                   	push   %esi
  800535:	53                   	push   %ebx
  800536:	83 ec 5c             	sub    $0x5c,%esp
  800539:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80053f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800542:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800549:	eb 11                	jmp    80055c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80054b:	85 c0                	test   %eax,%eax
  80054d:	0f 84 fd 03 00 00    	je     800950 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  800553:	89 74 24 04          	mov    %esi,0x4(%esp)
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055c:	0f b6 03             	movzbl (%ebx),%eax
  80055f:	83 c3 01             	add    $0x1,%ebx
  800562:	83 f8 25             	cmp    $0x25,%eax
  800565:	75 e4                	jne    80054b <vprintfmt+0x1b>
  800567:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800572:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800579:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800580:	b9 00 00 00 00       	mov    $0x0,%ecx
  800585:	eb 06                	jmp    80058d <vprintfmt+0x5d>
  800587:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80058b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	0f b6 13             	movzbl (%ebx),%edx
  800590:	0f b6 c2             	movzbl %dl,%eax
  800593:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800596:	8d 43 01             	lea    0x1(%ebx),%eax
  800599:	83 ea 23             	sub    $0x23,%edx
  80059c:	80 fa 55             	cmp    $0x55,%dl
  80059f:	0f 87 8e 03 00 00    	ja     800933 <vprintfmt+0x403>
  8005a5:	0f b6 d2             	movzbl %dl,%edx
  8005a8:	ff 24 95 80 14 80 00 	jmp    *0x801480(,%edx,4)
  8005af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b3:	eb d6                	jmp    80058b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b8:	83 ea 30             	sub    $0x30,%edx
  8005bb:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  8005be:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005c1:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005c4:	83 fb 09             	cmp    $0x9,%ebx
  8005c7:	77 55                	ja     80061e <vprintfmt+0xee>
  8005c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005cc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cf:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005d2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005d5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8005d9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005dc:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005df:	83 fb 09             	cmp    $0x9,%ebx
  8005e2:	76 eb                	jbe    8005cf <vprintfmt+0x9f>
  8005e4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ea:	eb 32                	jmp    80061e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ef:	83 c2 04             	add    $0x4,%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 52 fc             	mov    -0x4(%edx),%edx
  8005f8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8005fb:	eb 21                	jmp    80061e <vprintfmt+0xee>

		case '.':
			if (width < 0)
  8005fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800601:	ba 00 00 00 00       	mov    $0x0,%edx
  800606:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  80060a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80060d:	e9 79 ff ff ff       	jmp    80058b <vprintfmt+0x5b>
  800612:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800619:	e9 6d ff ff ff       	jmp    80058b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80061e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800622:	0f 89 63 ff ff ff    	jns    80058b <vprintfmt+0x5b>
  800628:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80062b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80062e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800631:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800634:	e9 52 ff ff ff       	jmp    80058b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800639:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80063c:	e9 4a ff ff ff       	jmp    80058b <vprintfmt+0x5b>
  800641:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	83 c0 04             	add    $0x4,%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
  80064d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800651:	8b 40 fc             	mov    -0x4(%eax),%eax
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff d7                	call   *%edi
  800659:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80065c:	e9 fb fe ff ff       	jmp    80055c <vprintfmt+0x2c>
  800661:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	83 c0 04             	add    $0x4,%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
  80066d:	8b 40 fc             	mov    -0x4(%eax),%eax
  800670:	89 c2                	mov    %eax,%edx
  800672:	c1 fa 1f             	sar    $0x1f,%edx
  800675:	31 d0                	xor    %edx,%eax
  800677:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800679:	83 f8 08             	cmp    $0x8,%eax
  80067c:	7f 0b                	jg     800689 <vprintfmt+0x159>
  80067e:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800685:	85 d2                	test   %edx,%edx
  800687:	75 20                	jne    8006a9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800689:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068d:	c7 44 24 08 d6 13 80 	movl   $0x8013d6,0x8(%esp)
  800694:	00 
  800695:	89 74 24 04          	mov    %esi,0x4(%esp)
  800699:	89 3c 24             	mov    %edi,(%esp)
  80069c:	e8 37 03 00 00       	call   8009d8 <printfmt>
  8006a1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8006a4:	e9 b3 fe ff ff       	jmp    80055c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8006a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ad:	c7 44 24 08 df 13 80 	movl   $0x8013df,0x8(%esp)
  8006b4:	00 
  8006b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b9:	89 3c 24             	mov    %edi,(%esp)
  8006bc:	e8 17 03 00 00       	call   8009d8 <printfmt>
  8006c1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006c4:	e9 93 fe ff ff       	jmp    80055c <vprintfmt+0x2c>
  8006c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006cc:	89 c3                	mov    %eax,%ebx
  8006ce:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006d1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006d4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	83 c0 04             	add    $0x4,%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e0:	8b 40 fc             	mov    -0x4(%eax),%eax
  8006e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	b8 e2 13 80 00       	mov    $0x8013e2,%eax
  8006ed:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  8006f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	7e 06                	jle    8006fe <vprintfmt+0x1ce>
  8006f8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006fc:	75 13                	jne    800711 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800701:	0f be 02             	movsbl (%edx),%eax
  800704:	85 c0                	test   %eax,%eax
  800706:	0f 85 99 00 00 00    	jne    8007a5 <vprintfmt+0x275>
  80070c:	e9 86 00 00 00       	jmp    800797 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	89 54 24 04          	mov    %edx,0x4(%esp)
  800715:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800718:	89 0c 24             	mov    %ecx,(%esp)
  80071b:	e8 fb 02 00 00       	call   800a1b <strnlen>
  800720:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800723:	29 c2                	sub    %eax,%edx
  800725:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e d2                	jle    8006fe <vprintfmt+0x1ce>
					putch(padc, putdat);
  80072c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800730:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800733:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800736:	89 d3                	mov    %edx,%ebx
  800738:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800744:	83 eb 01             	sub    $0x1,%ebx
  800747:	85 db                	test   %ebx,%ebx
  800749:	7f ed                	jg     800738 <vprintfmt+0x208>
  80074b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80074e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800755:	eb a7                	jmp    8006fe <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800757:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075b:	74 18                	je     800775 <vprintfmt+0x245>
  80075d:	8d 50 e0             	lea    -0x20(%eax),%edx
  800760:	83 fa 5e             	cmp    $0x5e,%edx
  800763:	76 10                	jbe    800775 <vprintfmt+0x245>
					putch('?', putdat);
  800765:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800769:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800770:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800773:	eb 0a                	jmp    80077f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800775:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800779:	89 04 24             	mov    %eax,(%esp)
  80077c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80077f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800783:	0f be 03             	movsbl (%ebx),%eax
  800786:	85 c0                	test   %eax,%eax
  800788:	74 05                	je     80078f <vprintfmt+0x25f>
  80078a:	83 c3 01             	add    $0x1,%ebx
  80078d:	eb 29                	jmp    8007b8 <vprintfmt+0x288>
  80078f:	89 fe                	mov    %edi,%esi
  800791:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800794:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800797:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80079b:	7f 2e                	jg     8007cb <vprintfmt+0x29b>
  80079d:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8007a0:	e9 b7 fd ff ff       	jmp    80055c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a8:	83 c2 01             	add    $0x1,%edx
  8007ab:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8007ae:	89 f7                	mov    %esi,%edi
  8007b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007b6:	89 d3                	mov    %edx,%ebx
  8007b8:	85 f6                	test   %esi,%esi
  8007ba:	78 9b                	js     800757 <vprintfmt+0x227>
  8007bc:	83 ee 01             	sub    $0x1,%esi
  8007bf:	79 96                	jns    800757 <vprintfmt+0x227>
  8007c1:	89 fe                	mov    %edi,%esi
  8007c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007c6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007c9:	eb cc                	jmp    800797 <vprintfmt+0x267>
  8007cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007dc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007de:	83 eb 01             	sub    $0x1,%ebx
  8007e1:	85 db                	test   %ebx,%ebx
  8007e3:	7f ec                	jg     8007d1 <vprintfmt+0x2a1>
  8007e5:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007e8:	e9 6f fd ff ff       	jmp    80055c <vprintfmt+0x2c>
  8007ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f0:	83 f9 01             	cmp    $0x1,%ecx
  8007f3:	7e 17                	jle    80080c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	83 c0 08             	add    $0x8,%eax
  8007fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8007fe:	8b 50 f8             	mov    -0x8(%eax),%edx
  800801:	8b 48 fc             	mov    -0x4(%eax),%ecx
  800804:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800807:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80080a:	eb 34                	jmp    800840 <vprintfmt+0x310>
	else if (lflag)
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	74 19                	je     800829 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	83 c0 04             	add    $0x4,%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
  800819:	8b 40 fc             	mov    -0x4(%eax),%eax
  80081c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081f:	89 c1                	mov    %eax,%ecx
  800821:	c1 f9 1f             	sar    $0x1f,%ecx
  800824:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800827:	eb 17                	jmp    800840 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	83 c0 04             	add    $0x4,%eax
  80082f:	89 45 14             	mov    %eax,0x14(%ebp)
  800832:	8b 40 fc             	mov    -0x4(%eax),%eax
  800835:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	c1 fa 1f             	sar    $0x1f,%edx
  80083d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800840:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800843:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800846:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80084b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80084f:	0f 89 9c 00 00 00    	jns    8008f1 <vprintfmt+0x3c1>
				putch('-', putdat);
  800855:	89 74 24 04          	mov    %esi,0x4(%esp)
  800859:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800860:	ff d7                	call   *%edi
				num = -(long long) num;
  800862:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800865:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800868:	f7 d9                	neg    %ecx
  80086a:	83 d3 00             	adc    $0x0,%ebx
  80086d:	f7 db                	neg    %ebx
  80086f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800874:	eb 7b                	jmp    8008f1 <vprintfmt+0x3c1>
  800876:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800879:	89 ca                	mov    %ecx,%edx
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
  80087e:	e8 53 fc ff ff       	call   8004d6 <getuint>
  800883:	89 c1                	mov    %eax,%ecx
  800885:	89 d3                	mov    %edx,%ebx
  800887:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80088c:	eb 63                	jmp    8008f1 <vprintfmt+0x3c1>
  80088e:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800891:	89 ca                	mov    %ecx,%edx
  800893:	8d 45 14             	lea    0x14(%ebp),%eax
  800896:	e8 3b fc ff ff       	call   8004d6 <getuint>
  80089b:	89 c1                	mov    %eax,%ecx
  80089d:	89 d3                	mov    %edx,%ebx
  80089f:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8008a4:	eb 4b                	jmp    8008f1 <vprintfmt+0x3c1>
  8008a6:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8008a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ad:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008b4:	ff d7                	call   *%edi
			putch('x', putdat);
  8008b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ba:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008c1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	83 c0 04             	add    $0x4,%eax
  8008c9:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008cc:	8b 48 fc             	mov    -0x4(%eax),%ecx
  8008cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008d4:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008d9:	eb 16                	jmp    8008f1 <vprintfmt+0x3c1>
  8008db:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008de:	89 ca                	mov    %ecx,%edx
  8008e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e3:	e8 ee fb ff ff       	call   8004d6 <getuint>
  8008e8:	89 c1                	mov    %eax,%ecx
  8008ea:	89 d3                	mov    %edx,%ebx
  8008ec:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800900:	89 44 24 08          	mov    %eax,0x8(%esp)
  800904:	89 0c 24             	mov    %ecx,(%esp)
  800907:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090b:	89 f2                	mov    %esi,%edx
  80090d:	89 f8                	mov    %edi,%eax
  80090f:	e8 cc fa ff ff       	call   8003e0 <printnum>
  800914:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800917:	e9 40 fc ff ff       	jmp    80055c <vprintfmt+0x2c>
  80091c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80091f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800922:	89 74 24 04          	mov    %esi,0x4(%esp)
  800926:	89 14 24             	mov    %edx,(%esp)
  800929:	ff d7                	call   *%edi
  80092b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  80092e:	e9 29 fc ff ff       	jmp    80055c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800933:	89 74 24 04          	mov    %esi,0x4(%esp)
  800937:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80093e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800940:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800943:	80 38 25             	cmpb   $0x25,(%eax)
  800946:	0f 84 10 fc ff ff    	je     80055c <vprintfmt+0x2c>
  80094c:	89 c3                	mov    %eax,%ebx
  80094e:	eb f0                	jmp    800940 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800950:	83 c4 5c             	add    $0x5c,%esp
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5f                   	pop    %edi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 28             	sub    $0x28,%esp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800964:	85 c0                	test   %eax,%eax
  800966:	74 04                	je     80096c <vsnprintf+0x14>
  800968:	85 d2                	test   %edx,%edx
  80096a:	7f 07                	jg     800973 <vsnprintf+0x1b>
  80096c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800971:	eb 3b                	jmp    8009ae <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800973:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800976:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80097a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80097d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800984:	8b 45 14             	mov    0x14(%ebp),%eax
  800987:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098b:	8b 45 10             	mov    0x10(%ebp),%eax
  80098e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800992:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800995:	89 44 24 04          	mov    %eax,0x4(%esp)
  800999:	c7 04 24 13 05 80 00 	movl   $0x800513,(%esp)
  8009a0:	e8 8b fb ff ff       	call   800530 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 82 ff ff ff       	call   800958 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009de:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	89 04 24             	mov    %eax,(%esp)
  8009f9:	e8 32 fb ff ff       	call   800530 <vprintfmt>
	va_end(ap);
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a0e:	74 09                	je     800a19 <strlen+0x19>
		n++;
  800a10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a17:	75 f7                	jne    800a10 <strlen+0x10>
		n++;
	return n;
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a25:	85 c9                	test   %ecx,%ecx
  800a27:	74 19                	je     800a42 <strnlen+0x27>
  800a29:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a2c:	74 14                	je     800a42 <strnlen+0x27>
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a33:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a36:	39 c8                	cmp    %ecx,%eax
  800a38:	74 0d                	je     800a47 <strnlen+0x2c>
  800a3a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a3e:	75 f3                	jne    800a33 <strnlen+0x18>
  800a40:	eb 05                	jmp    800a47 <strnlen+0x2c>
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a47:	5b                   	pop    %ebx
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	53                   	push   %ebx
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a54:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a59:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a5d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a60:	83 c2 01             	add    $0x1,%edx
  800a63:	84 c9                	test   %cl,%cl
  800a65:	75 f2                	jne    800a59 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a67:	5b                   	pop    %ebx
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a75:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a78:	85 f6                	test   %esi,%esi
  800a7a:	74 18                	je     800a94 <strncpy+0x2a>
  800a7c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a81:	0f b6 1a             	movzbl (%edx),%ebx
  800a84:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a87:	80 3a 01             	cmpb   $0x1,(%edx)
  800a8a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	39 ce                	cmp    %ecx,%esi
  800a92:	77 ed                	ja     800a81 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa6:	89 f0                	mov    %esi,%eax
  800aa8:	85 c9                	test   %ecx,%ecx
  800aaa:	74 27                	je     800ad3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800aac:	83 e9 01             	sub    $0x1,%ecx
  800aaf:	74 1d                	je     800ace <strlcpy+0x36>
  800ab1:	0f b6 1a             	movzbl (%edx),%ebx
  800ab4:	84 db                	test   %bl,%bl
  800ab6:	74 16                	je     800ace <strlcpy+0x36>
			*dst++ = *src++;
  800ab8:	88 18                	mov    %bl,(%eax)
  800aba:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800abd:	83 e9 01             	sub    $0x1,%ecx
  800ac0:	74 0e                	je     800ad0 <strlcpy+0x38>
			*dst++ = *src++;
  800ac2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac5:	0f b6 1a             	movzbl (%edx),%ebx
  800ac8:	84 db                	test   %bl,%bl
  800aca:	75 ec                	jne    800ab8 <strlcpy+0x20>
  800acc:	eb 02                	jmp    800ad0 <strlcpy+0x38>
  800ace:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ad0:	c6 00 00             	movb   $0x0,(%eax)
  800ad3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae2:	0f b6 01             	movzbl (%ecx),%eax
  800ae5:	84 c0                	test   %al,%al
  800ae7:	74 15                	je     800afe <strcmp+0x25>
  800ae9:	3a 02                	cmp    (%edx),%al
  800aeb:	75 11                	jne    800afe <strcmp+0x25>
		p++, q++;
  800aed:	83 c1 01             	add    $0x1,%ecx
  800af0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af3:	0f b6 01             	movzbl (%ecx),%eax
  800af6:	84 c0                	test   %al,%al
  800af8:	74 04                	je     800afe <strcmp+0x25>
  800afa:	3a 02                	cmp    (%edx),%al
  800afc:	74 ef                	je     800aed <strcmp+0x14>
  800afe:	0f b6 c0             	movzbl %al,%eax
  800b01:	0f b6 12             	movzbl (%edx),%edx
  800b04:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	53                   	push   %ebx
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b12:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	74 23                	je     800b3c <strncmp+0x34>
  800b19:	0f b6 1a             	movzbl (%edx),%ebx
  800b1c:	84 db                	test   %bl,%bl
  800b1e:	74 24                	je     800b44 <strncmp+0x3c>
  800b20:	3a 19                	cmp    (%ecx),%bl
  800b22:	75 20                	jne    800b44 <strncmp+0x3c>
  800b24:	83 e8 01             	sub    $0x1,%eax
  800b27:	74 13                	je     800b3c <strncmp+0x34>
		n--, p++, q++;
  800b29:	83 c2 01             	add    $0x1,%edx
  800b2c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b2f:	0f b6 1a             	movzbl (%edx),%ebx
  800b32:	84 db                	test   %bl,%bl
  800b34:	74 0e                	je     800b44 <strncmp+0x3c>
  800b36:	3a 19                	cmp    (%ecx),%bl
  800b38:	74 ea                	je     800b24 <strncmp+0x1c>
  800b3a:	eb 08                	jmp    800b44 <strncmp+0x3c>
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b44:	0f b6 02             	movzbl (%edx),%eax
  800b47:	0f b6 11             	movzbl (%ecx),%edx
  800b4a:	29 d0                	sub    %edx,%eax
  800b4c:	eb f3                	jmp    800b41 <strncmp+0x39>

00800b4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b58:	0f b6 10             	movzbl (%eax),%edx
  800b5b:	84 d2                	test   %dl,%dl
  800b5d:	74 15                	je     800b74 <strchr+0x26>
		if (*s == c)
  800b5f:	38 ca                	cmp    %cl,%dl
  800b61:	75 07                	jne    800b6a <strchr+0x1c>
  800b63:	eb 14                	jmp    800b79 <strchr+0x2b>
  800b65:	38 ca                	cmp    %cl,%dl
  800b67:	90                   	nop
  800b68:	74 0f                	je     800b79 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	84 d2                	test   %dl,%dl
  800b72:	75 f1                	jne    800b65 <strchr+0x17>
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b85:	0f b6 10             	movzbl (%eax),%edx
  800b88:	84 d2                	test   %dl,%dl
  800b8a:	74 18                	je     800ba4 <strfind+0x29>
		if (*s == c)
  800b8c:	38 ca                	cmp    %cl,%dl
  800b8e:	75 0a                	jne    800b9a <strfind+0x1f>
  800b90:	eb 12                	jmp    800ba4 <strfind+0x29>
  800b92:	38 ca                	cmp    %cl,%dl
  800b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b98:	74 0a                	je     800ba4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	0f b6 10             	movzbl (%eax),%edx
  800ba0:	84 d2                	test   %dl,%dl
  800ba2:	75 ee                	jne    800b92 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	53                   	push   %ebx
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800bb3:	89 da                	mov    %ebx,%edx
  800bb5:	83 ea 01             	sub    $0x1,%edx
  800bb8:	78 0d                	js     800bc7 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  800bba:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800bbc:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  800bbe:	88 0a                	mov    %cl,(%edx)
  800bc0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800bc3:	39 da                	cmp    %ebx,%edx
  800bc5:	75 f7                	jne    800bbe <memset+0x18>
		*p++ = c;

	return v;
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800bd8:	85 db                	test   %ebx,%ebx
  800bda:	74 13                	je     800bef <memcpy+0x25>
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800be1:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800be5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800be8:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800beb:	39 da                	cmp    %ebx,%edx
  800bed:	75 f2                	jne    800be1 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800c02:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800c04:	39 c6                	cmp    %eax,%esi
  800c06:	72 0b                	jb     800c13 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800c0d:	85 db                	test   %ebx,%ebx
  800c0f:	75 2e                	jne    800c3f <memmove+0x4c>
  800c11:	eb 3a                	jmp    800c4d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c13:	01 df                	add    %ebx,%edi
  800c15:	39 f8                	cmp    %edi,%eax
  800c17:	73 ef                	jae    800c08 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800c19:	85 db                	test   %ebx,%ebx
  800c1b:	90                   	nop
  800c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c20:	74 2b                	je     800c4d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800c22:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800c2a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800c2f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800c33:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800c36:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800c39:	85 c9                	test   %ecx,%ecx
  800c3b:	75 ed                	jne    800c2a <memmove+0x37>
  800c3d:	eb 0e                	jmp    800c4d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800c3f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c43:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c46:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800c49:	39 d3                	cmp    %edx,%ebx
  800c4b:	75 f2                	jne    800c3f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	8b 75 08             	mov    0x8(%ebp),%esi
  800c5b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c61:	85 c9                	test   %ecx,%ecx
  800c63:	74 36                	je     800c9b <memcmp+0x49>
		if (*s1 != *s2)
  800c65:	0f b6 06             	movzbl (%esi),%eax
  800c68:	0f b6 1f             	movzbl (%edi),%ebx
  800c6b:	38 d8                	cmp    %bl,%al
  800c6d:	74 20                	je     800c8f <memcmp+0x3d>
  800c6f:	eb 14                	jmp    800c85 <memcmp+0x33>
  800c71:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c76:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c7b:	83 c2 01             	add    $0x1,%edx
  800c7e:	83 e9 01             	sub    $0x1,%ecx
  800c81:	38 d8                	cmp    %bl,%al
  800c83:	74 12                	je     800c97 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c85:	0f b6 c0             	movzbl %al,%eax
  800c88:	0f b6 db             	movzbl %bl,%ebx
  800c8b:	29 d8                	sub    %ebx,%eax
  800c8d:	eb 11                	jmp    800ca0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8f:	83 e9 01             	sub    $0x1,%ecx
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	85 c9                	test   %ecx,%ecx
  800c99:	75 d6                	jne    800c71 <memcmp+0x1f>
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cab:	89 c2                	mov    %eax,%edx
  800cad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb0:	39 d0                	cmp    %edx,%eax
  800cb2:	73 15                	jae    800cc9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cb8:	38 08                	cmp    %cl,(%eax)
  800cba:	75 06                	jne    800cc2 <memfind+0x1d>
  800cbc:	eb 0b                	jmp    800cc9 <memfind+0x24>
  800cbe:	38 08                	cmp    %cl,(%eax)
  800cc0:	74 07                	je     800cc9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc2:	83 c0 01             	add    $0x1,%eax
  800cc5:	39 c2                	cmp    %eax,%edx
  800cc7:	77 f5                	ja     800cbe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 04             	sub    $0x4,%esp
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cda:	0f b6 02             	movzbl (%edx),%eax
  800cdd:	3c 20                	cmp    $0x20,%al
  800cdf:	74 04                	je     800ce5 <strtol+0x1a>
  800ce1:	3c 09                	cmp    $0x9,%al
  800ce3:	75 0e                	jne    800cf3 <strtol+0x28>
		s++;
  800ce5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce8:	0f b6 02             	movzbl (%edx),%eax
  800ceb:	3c 20                	cmp    $0x20,%al
  800ced:	74 f6                	je     800ce5 <strtol+0x1a>
  800cef:	3c 09                	cmp    $0x9,%al
  800cf1:	74 f2                	je     800ce5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf3:	3c 2b                	cmp    $0x2b,%al
  800cf5:	75 0c                	jne    800d03 <strtol+0x38>
		s++;
  800cf7:	83 c2 01             	add    $0x1,%edx
  800cfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d01:	eb 15                	jmp    800d18 <strtol+0x4d>
	else if (*s == '-')
  800d03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d0a:	3c 2d                	cmp    $0x2d,%al
  800d0c:	75 0a                	jne    800d18 <strtol+0x4d>
		s++, neg = 1;
  800d0e:	83 c2 01             	add    $0x1,%edx
  800d11:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d18:	85 db                	test   %ebx,%ebx
  800d1a:	0f 94 c0             	sete   %al
  800d1d:	74 05                	je     800d24 <strtol+0x59>
  800d1f:	83 fb 10             	cmp    $0x10,%ebx
  800d22:	75 18                	jne    800d3c <strtol+0x71>
  800d24:	80 3a 30             	cmpb   $0x30,(%edx)
  800d27:	75 13                	jne    800d3c <strtol+0x71>
  800d29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d2d:	8d 76 00             	lea    0x0(%esi),%esi
  800d30:	75 0a                	jne    800d3c <strtol+0x71>
		s += 2, base = 16;
  800d32:	83 c2 02             	add    $0x2,%edx
  800d35:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3a:	eb 15                	jmp    800d51 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d3c:	84 c0                	test   %al,%al
  800d3e:	66 90                	xchg   %ax,%ax
  800d40:	74 0f                	je     800d51 <strtol+0x86>
  800d42:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d47:	80 3a 30             	cmpb   $0x30,(%edx)
  800d4a:	75 05                	jne    800d51 <strtol+0x86>
		s++, base = 8;
  800d4c:	83 c2 01             	add    $0x1,%edx
  800d4f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d58:	0f b6 0a             	movzbl (%edx),%ecx
  800d5b:	89 cf                	mov    %ecx,%edi
  800d5d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d60:	80 fb 09             	cmp    $0x9,%bl
  800d63:	77 08                	ja     800d6d <strtol+0xa2>
			dig = *s - '0';
  800d65:	0f be c9             	movsbl %cl,%ecx
  800d68:	83 e9 30             	sub    $0x30,%ecx
  800d6b:	eb 1e                	jmp    800d8b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d6d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d70:	80 fb 19             	cmp    $0x19,%bl
  800d73:	77 08                	ja     800d7d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d75:	0f be c9             	movsbl %cl,%ecx
  800d78:	83 e9 57             	sub    $0x57,%ecx
  800d7b:	eb 0e                	jmp    800d8b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d7d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d80:	80 fb 19             	cmp    $0x19,%bl
  800d83:	77 15                	ja     800d9a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d85:	0f be c9             	movsbl %cl,%ecx
  800d88:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d8b:	39 f1                	cmp    %esi,%ecx
  800d8d:	7d 0b                	jge    800d9a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d8f:	83 c2 01             	add    $0x1,%edx
  800d92:	0f af c6             	imul   %esi,%eax
  800d95:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d98:	eb be                	jmp    800d58 <strtol+0x8d>
  800d9a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da0:	74 05                	je     800da7 <strtol+0xdc>
		*endptr = (char *) s;
  800da2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800da7:	89 ca                	mov    %ecx,%edx
  800da9:	f7 da                	neg    %edx
  800dab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800daf:	0f 45 c2             	cmovne %edx,%eax
}
  800db2:	83 c4 04             	add    $0x4,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    
	...

00800dbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	89 1c 24             	mov    %ebx,(%esp)
  800dc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	89 c7                	mov    %eax,%edi
  800ddc:	89 c6                	mov    %eax,%esi
  800dde:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800de0:	8b 1c 24             	mov    (%esp),%ebx
  800de3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800de7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_cgetc>:

int
sys_cgetc(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	89 1c 24             	mov    %ebx,(%esp)
  800df8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dfc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e00:	ba 00 00 00 00       	mov    $0x0,%edx
  800e05:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0a:	89 d1                	mov    %edx,%ecx
  800e0c:	89 d3                	mov    %edx,%ebx
  800e0e:	89 d7                	mov    %edx,%edi
  800e10:	89 d6                	mov    %edx,%esi
  800e12:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800e14:	8b 1c 24             	mov    (%esp),%ebx
  800e17:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e1b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e1f:	89 ec                	mov    %ebp,%esp
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	89 1c 24             	mov    %ebx,(%esp)
  800e2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e30:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e39:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	89 cb                	mov    %ecx,%ebx
  800e43:	89 cf                	mov    %ecx,%edi
  800e45:	89 ce                	mov    %ecx,%esi
  800e47:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800e49:	8b 1c 24             	mov    (%esp),%ebx
  800e4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e50:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e54:	89 ec                	mov    %ebp,%esp
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	89 1c 24             	mov    %ebx,(%esp)
  800e61:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e65:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	89 d3                	mov    %edx,%ebx
  800e77:	89 d7                	mov    %edx,%edi
  800e79:	89 d6                	mov    %edx,%esi
  800e7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800e7d:	8b 1c 24             	mov    (%esp),%ebx
  800e80:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e84:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_yield>:

void
sys_yield(void)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 0c             	sub    $0xc,%esp
  800e92:	89 1c 24             	mov    %ebx,(%esp)
  800e95:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e99:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea7:	89 d1                	mov    %edx,%ecx
  800ea9:	89 d3                	mov    %edx,%ebx
  800eab:	89 d7                	mov    %edx,%edi
  800ead:	89 d6                	mov    %edx,%esi
  800eaf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  800eb1:	8b 1c 24             	mov    (%esp),%ebx
  800eb4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ebc:	89 ec                	mov    %ebp,%esp
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	89 1c 24             	mov    %ebx,(%esp)
  800ec9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ecd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	be 00 00 00 00       	mov    $0x0,%esi
  800ed6:	b8 04 00 00 00       	mov    $0x4,%eax
  800edb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 f7                	mov    %esi,%edi
  800ee6:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  800ee8:	8b 1c 24             	mov    (%esp),%ebx
  800eeb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eef:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ef3:	89 ec                	mov    %ebp,%esp
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 0c             	sub    $0xc,%esp
  800efd:	89 1c 24             	mov    %ebx,(%esp)
  800f00:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f04:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f08:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0d:	8b 75 18             	mov    0x18(%ebp),%esi
  800f10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f1e:	8b 1c 24             	mov    (%esp),%ebx
  800f21:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f25:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f29:	89 ec                	mov    %ebp,%esp
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	89 1c 24             	mov    %ebx,(%esp)
  800f36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f43:	b8 06 00 00 00       	mov    $0x6,%eax
  800f48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4e:	89 df                	mov    %ebx,%edi
  800f50:	89 de                	mov    %ebx,%esi
  800f52:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800f54:	8b 1c 24             	mov    (%esp),%ebx
  800f57:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f5b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f5f:	89 ec                	mov    %ebp,%esp
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	89 1c 24             	mov    %ebx,(%esp)
  800f6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f70:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f79:	b8 08 00 00 00       	mov    $0x8,%eax
  800f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	89 df                	mov    %ebx,%edi
  800f86:	89 de                	mov    %ebx,%esi
  800f88:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800f8a:	8b 1c 24             	mov    (%esp),%ebx
  800f8d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f91:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f95:	89 ec                	mov    %ebp,%esp
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	89 1c 24             	mov    %ebx,(%esp)
  800fa2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800faf:	b8 09 00 00 00       	mov    $0x9,%eax
  800fb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fba:	89 df                	mov    %ebx,%edi
  800fbc:	89 de                	mov    %ebx,%esi
  800fbe:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc0:	8b 1c 24             	mov    (%esp),%ebx
  800fc3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fc7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fcb:	89 ec                	mov    %ebp,%esp
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	89 1c 24             	mov    %ebx,(%esp)
  800fd8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fdc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff0:	89 df                	mov    %ebx,%edi
  800ff2:	89 de                	mov    %ebx,%esi
  800ff4:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ff6:	8b 1c 24             	mov    (%esp),%ebx
  800ff9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ffd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801001:	89 ec                	mov    %ebp,%esp
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	89 1c 24             	mov    %ebx,(%esp)
  80100e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801012:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	be 00 00 00 00       	mov    $0x0,%esi
  80101b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801020:	8b 7d 14             	mov    0x14(%ebp),%edi
  801023:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  80102e:	8b 1c 24             	mov    (%esp),%ebx
  801031:	8b 74 24 04          	mov    0x4(%esp),%esi
  801035:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801039:	89 ec                	mov    %ebp,%esp
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	89 1c 24             	mov    %ebx,(%esp)
  801046:	89 74 24 04          	mov    %esi,0x4(%esp)
  80104a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801053:	b8 0d 00 00 00       	mov    $0xd,%eax
  801058:	8b 55 08             	mov    0x8(%ebp),%edx
  80105b:	89 cb                	mov    %ecx,%ebx
  80105d:	89 cf                	mov    %ecx,%edi
  80105f:	89 ce                	mov    %ecx,%esi
  801061:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  801063:	8b 1c 24             	mov    (%esp),%ebx
  801066:	8b 74 24 04          	mov    0x4(%esp),%esi
  80106a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80106e:	89 ec                	mov    %ebp,%esp
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    
	...

00801080 <__udivdi3>:
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	83 ec 10             	sub    $0x10,%esp
  801088:	8b 45 14             	mov    0x14(%ebp),%eax
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	8b 75 10             	mov    0x10(%ebp),%esi
  801091:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801094:	85 c0                	test   %eax,%eax
  801096:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801099:	75 35                	jne    8010d0 <__udivdi3+0x50>
  80109b:	39 fe                	cmp    %edi,%esi
  80109d:	77 61                	ja     801100 <__udivdi3+0x80>
  80109f:	85 f6                	test   %esi,%esi
  8010a1:	75 0b                	jne    8010ae <__udivdi3+0x2e>
  8010a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a8:	31 d2                	xor    %edx,%edx
  8010aa:	f7 f6                	div    %esi
  8010ac:	89 c6                	mov    %eax,%esi
  8010ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8010b1:	31 d2                	xor    %edx,%edx
  8010b3:	89 f8                	mov    %edi,%eax
  8010b5:	f7 f6                	div    %esi
  8010b7:	89 c7                	mov    %eax,%edi
  8010b9:	89 c8                	mov    %ecx,%eax
  8010bb:	f7 f6                	div    %esi
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	89 fa                	mov    %edi,%edx
  8010c1:	89 c8                	mov    %ecx,%eax
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    
  8010ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010d0:	39 f8                	cmp    %edi,%eax
  8010d2:	77 1c                	ja     8010f0 <__udivdi3+0x70>
  8010d4:	0f bd d0             	bsr    %eax,%edx
  8010d7:	83 f2 1f             	xor    $0x1f,%edx
  8010da:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010dd:	75 39                	jne    801118 <__udivdi3+0x98>
  8010df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8010e2:	0f 86 a0 00 00 00    	jbe    801188 <__udivdi3+0x108>
  8010e8:	39 f8                	cmp    %edi,%eax
  8010ea:	0f 82 98 00 00 00    	jb     801188 <__udivdi3+0x108>
  8010f0:	31 ff                	xor    %edi,%edi
  8010f2:	31 c9                	xor    %ecx,%ecx
  8010f4:	89 c8                	mov    %ecx,%eax
  8010f6:	89 fa                	mov    %edi,%edx
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    
  8010ff:	90                   	nop
  801100:	89 d1                	mov    %edx,%ecx
  801102:	89 fa                	mov    %edi,%edx
  801104:	89 c8                	mov    %ecx,%eax
  801106:	31 ff                	xor    %edi,%edi
  801108:	f7 f6                	div    %esi
  80110a:	89 c1                	mov    %eax,%ecx
  80110c:	89 fa                	mov    %edi,%edx
  80110e:	89 c8                	mov    %ecx,%eax
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    
  801117:	90                   	nop
  801118:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80111c:	89 f2                	mov    %esi,%edx
  80111e:	d3 e0                	shl    %cl,%eax
  801120:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801123:	b8 20 00 00 00       	mov    $0x20,%eax
  801128:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80112b:	89 c1                	mov    %eax,%ecx
  80112d:	d3 ea                	shr    %cl,%edx
  80112f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801133:	0b 55 ec             	or     -0x14(%ebp),%edx
  801136:	d3 e6                	shl    %cl,%esi
  801138:	89 c1                	mov    %eax,%ecx
  80113a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80113d:	89 fe                	mov    %edi,%esi
  80113f:	d3 ee                	shr    %cl,%esi
  801141:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801145:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114b:	d3 e7                	shl    %cl,%edi
  80114d:	89 c1                	mov    %eax,%ecx
  80114f:	d3 ea                	shr    %cl,%edx
  801151:	09 d7                	or     %edx,%edi
  801153:	89 f2                	mov    %esi,%edx
  801155:	89 f8                	mov    %edi,%eax
  801157:	f7 75 ec             	divl   -0x14(%ebp)
  80115a:	89 d6                	mov    %edx,%esi
  80115c:	89 c7                	mov    %eax,%edi
  80115e:	f7 65 e8             	mull   -0x18(%ebp)
  801161:	39 d6                	cmp    %edx,%esi
  801163:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801166:	72 30                	jb     801198 <__udivdi3+0x118>
  801168:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80116b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80116f:	d3 e2                	shl    %cl,%edx
  801171:	39 c2                	cmp    %eax,%edx
  801173:	73 05                	jae    80117a <__udivdi3+0xfa>
  801175:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801178:	74 1e                	je     801198 <__udivdi3+0x118>
  80117a:	89 f9                	mov    %edi,%ecx
  80117c:	31 ff                	xor    %edi,%edi
  80117e:	e9 71 ff ff ff       	jmp    8010f4 <__udivdi3+0x74>
  801183:	90                   	nop
  801184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801188:	31 ff                	xor    %edi,%edi
  80118a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80118f:	e9 60 ff ff ff       	jmp    8010f4 <__udivdi3+0x74>
  801194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801198:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80119b:	31 ff                	xor    %edi,%edi
  80119d:	89 c8                	mov    %ecx,%eax
  80119f:	89 fa                	mov    %edi,%edx
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    
	...

008011b0 <__umoddi3>:
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	57                   	push   %edi
  8011b4:	56                   	push   %esi
  8011b5:	83 ec 20             	sub    $0x20,%esp
  8011b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8011bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011c4:	85 d2                	test   %edx,%edx
  8011c6:	89 c8                	mov    %ecx,%eax
  8011c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011cb:	75 13                	jne    8011e0 <__umoddi3+0x30>
  8011cd:	39 f7                	cmp    %esi,%edi
  8011cf:	76 3f                	jbe    801210 <__umoddi3+0x60>
  8011d1:	89 f2                	mov    %esi,%edx
  8011d3:	f7 f7                	div    %edi
  8011d5:	89 d0                	mov    %edx,%eax
  8011d7:	31 d2                	xor    %edx,%edx
  8011d9:	83 c4 20             	add    $0x20,%esp
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    
  8011e0:	39 f2                	cmp    %esi,%edx
  8011e2:	77 4c                	ja     801230 <__umoddi3+0x80>
  8011e4:	0f bd ca             	bsr    %edx,%ecx
  8011e7:	83 f1 1f             	xor    $0x1f,%ecx
  8011ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8011ed:	75 51                	jne    801240 <__umoddi3+0x90>
  8011ef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8011f2:	0f 87 e0 00 00 00    	ja     8012d8 <__umoddi3+0x128>
  8011f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fb:	29 f8                	sub    %edi,%eax
  8011fd:	19 d6                	sbb    %edx,%esi
  8011ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801202:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801205:	89 f2                	mov    %esi,%edx
  801207:	83 c4 20             	add    $0x20,%esp
  80120a:	5e                   	pop    %esi
  80120b:	5f                   	pop    %edi
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    
  80120e:	66 90                	xchg   %ax,%ax
  801210:	85 ff                	test   %edi,%edi
  801212:	75 0b                	jne    80121f <__umoddi3+0x6f>
  801214:	b8 01 00 00 00       	mov    $0x1,%eax
  801219:	31 d2                	xor    %edx,%edx
  80121b:	f7 f7                	div    %edi
  80121d:	89 c7                	mov    %eax,%edi
  80121f:	89 f0                	mov    %esi,%eax
  801221:	31 d2                	xor    %edx,%edx
  801223:	f7 f7                	div    %edi
  801225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801228:	f7 f7                	div    %edi
  80122a:	eb a9                	jmp    8011d5 <__umoddi3+0x25>
  80122c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 c8                	mov    %ecx,%eax
  801232:	89 f2                	mov    %esi,%edx
  801234:	83 c4 20             	add    $0x20,%esp
  801237:	5e                   	pop    %esi
  801238:	5f                   	pop    %edi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    
  80123b:	90                   	nop
  80123c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801240:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801244:	d3 e2                	shl    %cl,%edx
  801246:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801249:	ba 20 00 00 00       	mov    $0x20,%edx
  80124e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801251:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801254:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801258:	89 fa                	mov    %edi,%edx
  80125a:	d3 ea                	shr    %cl,%edx
  80125c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801260:	0b 55 f4             	or     -0xc(%ebp),%edx
  801263:	d3 e7                	shl    %cl,%edi
  801265:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801269:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80126c:	89 f2                	mov    %esi,%edx
  80126e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801271:	89 c7                	mov    %eax,%edi
  801273:	d3 ea                	shr    %cl,%edx
  801275:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801279:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	d3 e6                	shl    %cl,%esi
  801280:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801284:	d3 ea                	shr    %cl,%edx
  801286:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80128a:	09 d6                	or     %edx,%esi
  80128c:	89 f0                	mov    %esi,%eax
  80128e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801291:	d3 e7                	shl    %cl,%edi
  801293:	89 f2                	mov    %esi,%edx
  801295:	f7 75 f4             	divl   -0xc(%ebp)
  801298:	89 d6                	mov    %edx,%esi
  80129a:	f7 65 e8             	mull   -0x18(%ebp)
  80129d:	39 d6                	cmp    %edx,%esi
  80129f:	72 2b                	jb     8012cc <__umoddi3+0x11c>
  8012a1:	39 c7                	cmp    %eax,%edi
  8012a3:	72 23                	jb     8012c8 <__umoddi3+0x118>
  8012a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012a9:	29 c7                	sub    %eax,%edi
  8012ab:	19 d6                	sbb    %edx,%esi
  8012ad:	89 f0                	mov    %esi,%eax
  8012af:	89 f2                	mov    %esi,%edx
  8012b1:	d3 ef                	shr    %cl,%edi
  8012b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012b7:	d3 e0                	shl    %cl,%eax
  8012b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012bd:	09 f8                	or     %edi,%eax
  8012bf:	d3 ea                	shr    %cl,%edx
  8012c1:	83 c4 20             	add    $0x20,%esp
  8012c4:	5e                   	pop    %esi
  8012c5:	5f                   	pop    %edi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    
  8012c8:	39 d6                	cmp    %edx,%esi
  8012ca:	75 d9                	jne    8012a5 <__umoddi3+0xf5>
  8012cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8012cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8012d2:	eb d1                	jmp    8012a5 <__umoddi3+0xf5>
  8012d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	39 f2                	cmp    %esi,%edx
  8012da:	0f 82 18 ff ff ff    	jb     8011f8 <__umoddi3+0x48>
  8012e0:	e9 1d ff ff ff       	jmp    801202 <__umoddi3+0x52>
