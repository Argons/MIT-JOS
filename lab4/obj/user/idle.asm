
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 10 80 00 6a 	movl   $0x80036a,0x801000
  800041:	03 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 3b 01 00 00       	call   800184 <sys_yield>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800049:	cc                   	int3   
  80004a:	eb f8                	jmp    800044 <umain+0x10>

0080004c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800055:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  80005e:	e8 ed 00 00 00       	call   800150 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	89 c2                	mov    %eax,%edx
  80006a:	c1 e2 07             	shl    $0x7,%edx
  80006d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800074:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x38>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 69 00 00 00       	call   80011b <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 0c             	sub    $0xc,%esp
  8000ba:	89 1c 24             	mov    %ebx,(%esp)
  8000bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d0:	89 c3                	mov    %eax,%ebx
  8000d2:	89 c7                	mov    %eax,%edi
  8000d4:	89 c6                	mov    %eax,%esi
  8000d6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  8000d8:	8b 1c 24             	mov    (%esp),%ebx
  8000db:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000df:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	89 1c 24             	mov    %ebx,(%esp)
  8000f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 01 00 00 00       	mov    $0x1,%eax
  800102:	89 d1                	mov    %edx,%ecx
  800104:	89 d3                	mov    %edx,%ebx
  800106:	89 d7                	mov    %edx,%edi
  800108:	89 d6                	mov    %edx,%esi
  80010a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  80010c:	8b 1c 24             	mov    (%esp),%ebx
  80010f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800113:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800117:	89 ec                	mov    %ebp,%esp
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	89 1c 24             	mov    %ebx,(%esp)
  800124:	89 74 24 04          	mov    %esi,0x4(%esp)
  800128:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800131:	b8 03 00 00 00       	mov    $0x3,%eax
  800136:	8b 55 08             	mov    0x8(%ebp),%edx
  800139:	89 cb                	mov    %ecx,%ebx
  80013b:	89 cf                	mov    %ecx,%edi
  80013d:	89 ce                	mov    %ecx,%esi
  80013f:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800141:	8b 1c 24             	mov    (%esp),%ebx
  800144:	8b 74 24 04          	mov    0x4(%esp),%esi
  800148:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80014c:	89 ec                	mov    %ebp,%esp
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	89 1c 24             	mov    %ebx,(%esp)
  800159:	89 74 24 04          	mov    %esi,0x4(%esp)
  80015d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 02 00 00 00       	mov    $0x2,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800175:	8b 1c 24             	mov    (%esp),%ebx
  800178:	8b 74 24 04          	mov    0x4(%esp),%esi
  80017c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800180:	89 ec                	mov    %ebp,%esp
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_yield>:

void
sys_yield(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	89 1c 24             	mov    %ebx,(%esp)
  80018d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800191:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800195:	ba 00 00 00 00       	mov    $0x0,%edx
  80019a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80019f:	89 d1                	mov    %edx,%ecx
  8001a1:	89 d3                	mov    %edx,%ebx
  8001a3:	89 d7                	mov    %edx,%edi
  8001a5:	89 d6                	mov    %edx,%esi
  8001a7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  8001a9:	8b 1c 24             	mov    (%esp),%ebx
  8001ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001b0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001b4:	89 ec                	mov    %ebp,%esp
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	89 1c 24             	mov    %ebx,(%esp)
  8001c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c9:	be 00 00 00 00       	mov    $0x0,%esi
  8001ce:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dc:	89 f7                	mov    %esi,%edi
  8001de:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  8001e0:	8b 1c 24             	mov    (%esp),%ebx
  8001e3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001e7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001eb:	89 ec                	mov    %ebp,%esp
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	89 1c 24             	mov    %ebx,(%esp)
  8001f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800200:	b8 05 00 00 00       	mov    $0x5,%eax
  800205:	8b 75 18             	mov    0x18(%ebp),%esi
  800208:	8b 7d 14             	mov    0x14(%ebp),%edi
  80020b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800211:	8b 55 08             	mov    0x8(%ebp),%edx
  800214:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800216:	8b 1c 24             	mov    (%esp),%ebx
  800219:	8b 74 24 04          	mov    0x4(%esp),%esi
  80021d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800221:	89 ec                	mov    %ebp,%esp
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 0c             	sub    $0xc,%esp
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800232:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 06 00 00 00       	mov    $0x6,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  80024c:	8b 1c 24             	mov    (%esp),%ebx
  80024f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800253:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800257:	89 ec                	mov    %ebp,%esp
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	89 1c 24             	mov    %ebx,(%esp)
  800264:	89 74 24 04          	mov    %esi,0x4(%esp)
  800268:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 08 00 00 00       	mov    $0x8,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800282:	8b 1c 24             	mov    (%esp),%ebx
  800285:	8b 74 24 04          	mov    0x4(%esp),%esi
  800289:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80028d:	89 ec                	mov    %ebp,%esp
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	89 1c 24             	mov    %ebx,(%esp)
  80029a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80029e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a7:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	89 df                	mov    %ebx,%edi
  8002b4:	89 de                	mov    %ebx,%esi
  8002b6:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b8:	8b 1c 24             	mov    (%esp),%ebx
  8002bb:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002bf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8002c3:	89 ec                	mov    %ebp,%esp
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	83 ec 0c             	sub    $0xc,%esp
  8002cd:	89 1c 24             	mov    %ebx,(%esp)
  8002d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	89 df                	mov    %ebx,%edi
  8002ea:	89 de                	mov    %ebx,%esi
  8002ec:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ee:	8b 1c 24             	mov    (%esp),%ebx
  8002f1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002f5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8002f9:	89 ec                	mov    %ebp,%esp
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	89 1c 24             	mov    %ebx,(%esp)
  800306:	89 74 24 04          	mov    %esi,0x4(%esp)
  80030a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	be 00 00 00 00       	mov    $0x0,%esi
  800313:	b8 0c 00 00 00       	mov    $0xc,%eax
  800318:	8b 7d 14             	mov    0x14(%ebp),%edi
  80031b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800326:	8b 1c 24             	mov    (%esp),%ebx
  800329:	8b 74 24 04          	mov    0x4(%esp),%esi
  80032d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800331:	89 ec                	mov    %ebp,%esp
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	89 1c 24             	mov    %ebx,(%esp)
  80033e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800342:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800346:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800350:	8b 55 08             	mov    0x8(%ebp),%edx
  800353:	89 cb                	mov    %ecx,%ebx
  800355:	89 cf                	mov    %ecx,%edi
  800357:	89 ce                	mov    %ecx,%esi
  800359:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  80035b:	8b 1c 24             	mov    (%esp),%ebx
  80035e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800362:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800366:	89 ec                	mov    %ebp,%esp
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    
