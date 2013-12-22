
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80004d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800050:	8b 75 08             	mov    0x8(%ebp),%esi
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  800056:	e8 ed 00 00 00       	call   800148 <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	89 c2                	mov    %eax,%edx
  800062:	c1 e2 07             	shl    $0x7,%edx
  800065:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80006c:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 07                	jle    80007c <libmain+0x38>
		binaryname = argv[0];
  800075:	8b 03                	mov    (%ebx),%eax
  800077:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	89 34 24             	mov    %esi,(%esp)
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 0b 00 00 00       	call   800098 <exit>
}
  80008d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800090:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800093:	89 ec                	mov    %ebp,%esp
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 69 00 00 00       	call   800113 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	89 1c 24             	mov    %ebx,(%esp)
  8000b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c8:	89 c3                	mov    %eax,%ebx
  8000ca:	89 c7                	mov    %eax,%edi
  8000cc:	89 c6                	mov    %eax,%esi
  8000ce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  8000d0:	8b 1c 24             	mov    (%esp),%ebx
  8000d3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000d7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000db:	89 ec                	mov    %ebp,%esp
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 0c             	sub    $0xc,%esp
  8000e5:	89 1c 24             	mov    %ebx,(%esp)
  8000e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ec:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fa:	89 d1                	mov    %edx,%ecx
  8000fc:	89 d3                	mov    %edx,%ebx
  8000fe:	89 d7                	mov    %edx,%edi
  800100:	89 d6                	mov    %edx,%esi
  800102:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800104:	8b 1c 24             	mov    (%esp),%ebx
  800107:	8b 74 24 04          	mov    0x4(%esp),%esi
  80010b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800124:	b9 00 00 00 00       	mov    $0x0,%ecx
  800129:	b8 03 00 00 00       	mov    $0x3,%eax
  80012e:	8b 55 08             	mov    0x8(%ebp),%edx
  800131:	89 cb                	mov    %ecx,%ebx
  800133:	89 cf                	mov    %ecx,%edi
  800135:	89 ce                	mov    %ecx,%esi
  800137:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800139:	8b 1c 24             	mov    (%esp),%ebx
  80013c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800140:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800144:	89 ec                	mov    %ebp,%esp
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	89 74 24 04          	mov    %esi,0x4(%esp)
  800155:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  80016d:	8b 1c 24             	mov    (%esp),%ebx
  800170:	8b 74 24 04          	mov    0x4(%esp),%esi
  800174:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800178:	89 ec                	mov    %ebp,%esp
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_yield>:

void
sys_yield(void)
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
  800192:	b8 0b 00 00 00       	mov    $0xb,%eax
  800197:	89 d1                	mov    %edx,%ecx
  800199:	89 d3                	mov    %edx,%ebx
  80019b:	89 d7                	mov    %edx,%edi
  80019d:	89 d6                	mov    %edx,%esi
  80019f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  8001a1:	8b 1c 24             	mov    (%esp),%ebx
  8001a4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001a8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001ac:	89 ec                	mov    %ebp,%esp
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  8001c1:	be 00 00 00 00       	mov    $0x0,%esi
  8001c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8001cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	89 f7                	mov    %esi,%edi
  8001d6:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  8001d8:	8b 1c 24             	mov    (%esp),%ebx
  8001db:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001df:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001e3:	89 ec                	mov    %ebp,%esp
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	89 1c 24             	mov    %ebx,(%esp)
  8001f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fd:	8b 75 18             	mov    0x18(%ebp),%esi
  800200:	8b 7d 14             	mov    0x14(%ebp),%edi
  800203:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800209:	8b 55 08             	mov    0x8(%ebp),%edx
  80020c:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020e:	8b 1c 24             	mov    (%esp),%ebx
  800211:	8b 74 24 04          	mov    0x4(%esp),%esi
  800215:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800219:	89 ec                	mov    %ebp,%esp
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	89 1c 24             	mov    %ebx,(%esp)
  800226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80022a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 06 00 00 00       	mov    $0x6,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  800244:	8b 1c 24             	mov    (%esp),%ebx
  800247:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80024f:	89 ec                	mov    %ebp,%esp
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	89 1c 24             	mov    %ebx,(%esp)
  80025c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800260:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	b8 08 00 00 00       	mov    $0x8,%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  80027a:	8b 1c 24             	mov    (%esp),%ebx
  80027d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800281:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800285:	89 ec                	mov    %ebp,%esp
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	89 1c 24             	mov    %ebx,(%esp)
  800292:	89 74 24 04          	mov    %esi,0x4(%esp)
  800296:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029f:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002aa:	89 df                	mov    %ebx,%edi
  8002ac:	89 de                	mov    %ebx,%esi
  8002ae:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b0:	8b 1c 24             	mov    (%esp),%ebx
  8002b3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002b7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8002bb:	89 ec                	mov    %ebp,%esp
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	83 ec 0c             	sub    $0xc,%esp
  8002c5:	89 1c 24             	mov    %ebx,(%esp)
  8002c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002cc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	89 df                	mov    %ebx,%edi
  8002e2:	89 de                	mov    %ebx,%esi
  8002e4:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e6:	8b 1c 24             	mov    (%esp),%ebx
  8002e9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8002f1:	89 ec                	mov    %ebp,%esp
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	89 1c 24             	mov    %ebx,(%esp)
  8002fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800302:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	be 00 00 00 00       	mov    $0x0,%esi
  80030b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  80031e:	8b 1c 24             	mov    (%esp),%ebx
  800321:	8b 74 24 04          	mov    0x4(%esp),%esi
  800325:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800329:	89 ec                	mov    %ebp,%esp
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	89 1c 24             	mov    %ebx,(%esp)
  800336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80033a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800343:	b8 0d 00 00 00       	mov    $0xd,%eax
  800348:	8b 55 08             	mov    0x8(%ebp),%edx
  80034b:	89 cb                	mov    %ecx,%ebx
  80034d:	89 cf                	mov    %ecx,%edi
  80034f:	89 ce                	mov    %ecx,%esi
  800351:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  800353:	8b 1c 24             	mov    (%esp),%ebx
  800356:	8b 74 24 04          	mov    0x4(%esp),%esi
  80035a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80035e:	89 ec                	mov    %ebp,%esp
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    
