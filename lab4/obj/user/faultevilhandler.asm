
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 8e 01 00 00       	call   8001e4 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 89 02 00 00       	call   8002f3 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  80008a:	e8 ed 00 00 00       	call   80017c <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	89 c2                	mov    %eax,%edx
  800096:	c1 e2 07             	shl    $0x7,%edx
  800099:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000a0:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a5:	85 f6                	test   %esi,%esi
  8000a7:	7e 07                	jle    8000b0 <libmain+0x38>
		binaryname = argv[0];
  8000a9:	8b 03                	mov    (%ebx),%eax
  8000ab:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  8000b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b4:	89 34 24             	mov    %esi,(%esp)
  8000b7:	e8 78 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bc:	e8 0b 00 00 00       	call   8000cc <exit>
}
  8000c1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c7:	89 ec                	mov    %ebp,%esp
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d9:	e8 69 00 00 00       	call   800147 <sys_env_destroy>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	89 1c 24             	mov    %ebx,(%esp)
  8000e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ed:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	89 c3                	mov    %eax,%ebx
  8000fe:	89 c7                	mov    %eax,%edi
  800100:	89 c6                	mov    %eax,%esi
  800102:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  800104:	8b 1c 24             	mov    (%esp),%ebx
  800107:	8b 74 24 04          	mov    0x4(%esp),%esi
  80010b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_cgetc>:

int
sys_cgetc(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	89 1c 24             	mov    %ebx,(%esp)
  80011c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800120:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800124:	ba 00 00 00 00       	mov    $0x0,%edx
  800129:	b8 01 00 00 00       	mov    $0x1,%eax
  80012e:	89 d1                	mov    %edx,%ecx
  800130:	89 d3                	mov    %edx,%ebx
  800132:	89 d7                	mov    %edx,%edi
  800134:	89 d6                	mov    %edx,%esi
  800136:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800138:	8b 1c 24             	mov    (%esp),%ebx
  80013b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80013f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	89 1c 24             	mov    %ebx,(%esp)
  800150:	89 74 24 04          	mov    %esi,0x4(%esp)
  800154:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800158:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015d:	b8 03 00 00 00       	mov    $0x3,%eax
  800162:	8b 55 08             	mov    0x8(%ebp),%edx
  800165:	89 cb                	mov    %ecx,%ebx
  800167:	89 cf                	mov    %ecx,%edi
  800169:	89 ce                	mov    %ecx,%esi
  80016b:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  80016d:	8b 1c 24             	mov    (%esp),%ebx
  800170:	8b 74 24 04          	mov    0x4(%esp),%esi
  800174:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800178:	89 ec                	mov    %ebp,%esp
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	89 1c 24             	mov    %ebx,(%esp)
  800185:	89 74 24 04          	mov    %esi,0x4(%esp)
  800189:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018d:	ba 00 00 00 00       	mov    $0x0,%edx
  800192:	b8 02 00 00 00       	mov    $0x2,%eax
  800197:	89 d1                	mov    %edx,%ecx
  800199:	89 d3                	mov    %edx,%ebx
  80019b:	89 d7                	mov    %edx,%edi
  80019d:	89 d6                	mov    %edx,%esi
  80019f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  8001a1:	8b 1c 24             	mov    (%esp),%ebx
  8001a4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001a8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001ac:	89 ec                	mov    %ebp,%esp
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <sys_yield>:

void
sys_yield(void)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	89 1c 24             	mov    %ebx,(%esp)
  8001b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001bd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001cb:	89 d1                	mov    %edx,%ecx
  8001cd:	89 d3                	mov    %edx,%ebx
  8001cf:	89 d7                	mov    %edx,%edi
  8001d1:	89 d6                	mov    %edx,%esi
  8001d3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  8001d5:	8b 1c 24             	mov    (%esp),%ebx
  8001d8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001dc:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001e0:	89 ec                	mov    %ebp,%esp
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	89 1c 24             	mov    %ebx,(%esp)
  8001ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f5:	be 00 00 00 00       	mov    $0x0,%esi
  8001fa:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 f7                	mov    %esi,%edi
  80020a:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  80020c:	8b 1c 24             	mov    (%esp),%ebx
  80020f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800213:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800217:	89 ec                	mov    %ebp,%esp
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	89 1c 24             	mov    %ebx,(%esp)
  800224:	89 74 24 04          	mov    %esi,0x4(%esp)
  800228:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022c:	b8 05 00 00 00       	mov    $0x5,%eax
  800231:	8b 75 18             	mov    0x18(%ebp),%esi
  800234:	8b 7d 14             	mov    0x14(%ebp),%edi
  800237:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800242:	8b 1c 24             	mov    (%esp),%ebx
  800245:	8b 74 24 04          	mov    0x4(%esp),%esi
  800249:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80024d:	89 ec                	mov    %ebp,%esp
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	89 1c 24             	mov    %ebx,(%esp)
  80025a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80025e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800262:	bb 00 00 00 00       	mov    $0x0,%ebx
  800267:	b8 06 00 00 00       	mov    $0x6,%eax
  80026c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026f:	8b 55 08             	mov    0x8(%ebp),%edx
  800272:	89 df                	mov    %ebx,%edi
  800274:	89 de                	mov    %ebx,%esi
  800276:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800278:	8b 1c 24             	mov    (%esp),%ebx
  80027b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80027f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800283:	89 ec                	mov    %ebp,%esp
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	89 1c 24             	mov    %ebx,(%esp)
  800290:	89 74 24 04          	mov    %esi,0x4(%esp)
  800294:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 08 00 00 00       	mov    $0x8,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  8002ae:	8b 1c 24             	mov    (%esp),%ebx
  8002b1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002b5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8002b9:	89 ec                	mov    %ebp,%esp
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 0c             	sub    $0xc,%esp
  8002c3:	89 1c 24             	mov    %ebx,(%esp)
  8002c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ca:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	89 df                	mov    %ebx,%edi
  8002e0:	89 de                	mov    %ebx,%esi
  8002e2:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  8002e4:	8b 1c 24             	mov    (%esp),%ebx
  8002e7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002eb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8002ef:	89 ec                	mov    %ebp,%esp
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 0c             	sub    $0xc,%esp
  8002f9:	89 1c 24             	mov    %ebx,(%esp)
  8002fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800300:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800304:	bb 00 00 00 00       	mov    $0x0,%ebx
  800309:	b8 0a 00 00 00       	mov    $0xa,%eax
  80030e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800311:	8b 55 08             	mov    0x8(%ebp),%edx
  800314:	89 df                	mov    %ebx,%edi
  800316:	89 de                	mov    %ebx,%esi
  800318:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  80031a:	8b 1c 24             	mov    (%esp),%ebx
  80031d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800321:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800325:	89 ec                	mov    %ebp,%esp
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	89 1c 24             	mov    %ebx,(%esp)
  800332:	89 74 24 04          	mov    %esi,0x4(%esp)
  800336:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	be 00 00 00 00       	mov    $0x0,%esi
  80033f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800344:	8b 7d 14             	mov    0x14(%ebp),%edi
  800347:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034d:	8b 55 08             	mov    0x8(%ebp),%edx
  800350:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800352:	8b 1c 24             	mov    (%esp),%ebx
  800355:	8b 74 24 04          	mov    0x4(%esp),%esi
  800359:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80035d:	89 ec                	mov    %ebp,%esp
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	89 1c 24             	mov    %ebx,(%esp)
  80036a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80036e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800372:	b9 00 00 00 00       	mov    $0x0,%ecx
  800377:	b8 0d 00 00 00       	mov    $0xd,%eax
  80037c:	8b 55 08             	mov    0x8(%ebp),%edx
  80037f:	89 cb                	mov    %ecx,%ebx
  800381:	89 cf                	mov    %ecx,%edi
  800383:	89 ce                	mov    %ecx,%esi
  800385:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800387:	8b 1c 24             	mov    (%esp),%ebx
  80038a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80038e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800392:	89 ec                	mov    %ebp,%esp
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    
