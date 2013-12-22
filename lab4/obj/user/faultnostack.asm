
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 7c 03 80 	movl   $0x80037c,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 89 02 00 00       	call   8002d7 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	//env = 0;

	env = envs + ENVX(sys_getenvid());
  80006e:	e8 ed 00 00 00       	call   800160 <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	89 c2                	mov    %eax,%edx
  80007a:	c1 e2 07             	shl    $0x7,%edx
  80007d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800084:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x38>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 69 00 00 00       	call   80012b <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	89 1c 24             	mov    %ebx,(%esp)
  8000cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e0:	89 c3                	mov    %eax,%ebx
  8000e2:	89 c7                	mov    %eax,%edi
  8000e4:	89 c6                	mov    %eax,%esi
  8000e6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  8000e8:	8b 1c 24             	mov    (%esp),%ebx
  8000eb:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000ef:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000f3:	89 ec                	mov    %ebp,%esp
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 0c             	sub    $0xc,%esp
  8000fd:	89 1c 24             	mov    %ebx,(%esp)
  800100:	89 74 24 04          	mov    %esi,0x4(%esp)
  800104:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800108:	ba 00 00 00 00       	mov    $0x0,%edx
  80010d:	b8 01 00 00 00       	mov    $0x1,%eax
  800112:	89 d1                	mov    %edx,%ecx
  800114:	89 d3                	mov    %edx,%ebx
  800116:	89 d7                	mov    %edx,%edi
  800118:	89 d6                	mov    %edx,%esi
  80011a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  80011c:	8b 1c 24             	mov    (%esp),%ebx
  80011f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800123:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800127:	89 ec                	mov    %ebp,%esp
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 0c             	sub    $0xc,%esp
  800131:	89 1c 24             	mov    %ebx,(%esp)
  800134:	89 74 24 04          	mov    %esi,0x4(%esp)
  800138:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800141:	b8 03 00 00 00       	mov    $0x3,%eax
  800146:	8b 55 08             	mov    0x8(%ebp),%edx
  800149:	89 cb                	mov    %ecx,%ebx
  80014b:	89 cf                	mov    %ecx,%edi
  80014d:	89 ce                	mov    %ecx,%esi
  80014f:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800151:	8b 1c 24             	mov    (%esp),%ebx
  800154:	8b 74 24 04          	mov    0x4(%esp),%esi
  800158:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80015c:	89 ec                	mov    %ebp,%esp
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	89 1c 24             	mov    %ebx,(%esp)
  800169:	89 74 24 04          	mov    %esi,0x4(%esp)
  80016d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800185:	8b 1c 24             	mov    (%esp),%ebx
  800188:	8b 74 24 04          	mov    0x4(%esp),%esi
  80018c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800190:	89 ec                	mov    %ebp,%esp
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    

00800194 <sys_yield>:

void
sys_yield(void)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	89 1c 24             	mov    %ebx,(%esp)
  80019d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001aa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001af:	89 d1                	mov    %edx,%ecx
  8001b1:	89 d3                	mov    %edx,%ebx
  8001b3:	89 d7                	mov    %edx,%edi
  8001b5:	89 d6                	mov    %edx,%esi
  8001b7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0);
}
  8001b9:	8b 1c 24             	mov    (%esp),%ebx
  8001bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001c0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001c4:	89 ec                	mov    %ebp,%esp
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    

008001c8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	89 1c 24             	mov    %ebx,(%esp)
  8001d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d9:	be 00 00 00 00       	mov    $0x0,%esi
  8001de:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 f7                	mov    %esi,%edi
  8001ee:	cd 30                	int    $0x30

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, envid, (uint32_t) va, perm, 0, 0);
}
  8001f0:	8b 1c 24             	mov    (%esp),%ebx
  8001f3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001f7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001fb:	89 ec                	mov    %ebp,%esp
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	89 1c 24             	mov    %ebx,(%esp)
  800208:	89 74 24 04          	mov    %esi,0x4(%esp)
  80020c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800210:	b8 05 00 00 00       	mov    $0x5,%eax
  800215:	8b 75 18             	mov    0x18(%ebp),%esi
  800218:	8b 7d 14             	mov    0x14(%ebp),%edi
  80021b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80021e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800221:	8b 55 08             	mov    0x8(%ebp),%edx
  800224:	cd 30                	int    $0x30

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800226:	8b 1c 24             	mov    (%esp),%ebx
  800229:	8b 74 24 04          	mov    0x4(%esp),%esi
  80022d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800231:	89 ec                	mov    %ebp,%esp
  800233:	5d                   	pop    %ebp
  800234:	c3                   	ret    

00800235 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	89 1c 24             	mov    %ebx,(%esp)
  80023e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800242:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024b:	b8 06 00 00 00       	mov    $0x6,%eax
  800250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800253:	8b 55 08             	mov    0x8(%ebp),%edx
  800256:	89 df                	mov    %ebx,%edi
  800258:	89 de                	mov    %ebx,%esi
  80025a:	cd 30                	int    $0x30

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, envid, (uint32_t) va, 0, 0, 0);
}
  80025c:	8b 1c 24             	mov    (%esp),%ebx
  80025f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800263:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800267:	89 ec                	mov    %ebp,%esp
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 0c             	sub    $0xc,%esp
  800271:	89 1c 24             	mov    %ebx,(%esp)
  800274:	89 74 24 04          	mov    %esi,0x4(%esp)
  800278:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 08 00 00 00       	mov    $0x8,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, envid, status, 0, 0, 0);
}
  800292:	8b 1c 24             	mov    (%esp),%ebx
  800295:	8b 74 24 04          	mov    0x4(%esp),%esi
  800299:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80029d:	89 ec                	mov    %ebp,%esp
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	89 1c 24             	mov    %ebx,(%esp)
  8002aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 09 00 00 00       	mov    $0x9,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c8:	8b 1c 24             	mov    (%esp),%ebx
  8002cb:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002cf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8002d3:	89 ec                	mov    %ebp,%esp
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	89 1c 24             	mov    %ebx,(%esp)
  8002e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	89 df                	mov    %ebx,%edi
  8002fa:	89 de                	mov    %ebx,%esi
  8002fc:	cd 30                	int    $0x30

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fe:	8b 1c 24             	mov    (%esp),%ebx
  800301:	8b 74 24 04          	mov    0x4(%esp),%esi
  800305:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800309:	89 ec                	mov    %ebp,%esp
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	89 1c 24             	mov    %ebx,(%esp)
  800316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80031a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031e:	be 00 00 00 00       	mov    $0x0,%esi
  800323:	b8 0c 00 00 00       	mov    $0xc,%eax
  800328:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800331:	8b 55 08             	mov    0x8(%ebp),%edx
  800334:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, envid, value, (uint32_t) srcva, perm, 0);
}
  800336:	8b 1c 24             	mov    (%esp),%ebx
  800339:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800341:	89 ec                	mov    %ebp,%esp
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 0c             	sub    $0xc,%esp
  80034b:	89 1c 24             	mov    %ebx,(%esp)
  80034e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800352:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800356:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800360:	8b 55 08             	mov    0x8(%ebp),%edx
  800363:	89 cb                	mov    %ecx,%ebx
  800365:	89 cf                	mov    %ecx,%edi
  800367:	89 ce                	mov    %ecx,%esi
  800369:	cd 30                	int    $0x30

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, (uint32_t) dstva, 0, 0, 0, 0);
}
  80036b:	8b 1c 24             	mov    (%esp),%ebx
  80036e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800372:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800376:	89 ec                	mov    %ebp,%esp
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    
	...

0080037c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80037c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80037d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800382:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800384:	83 c4 04             	add    $0x4,%esp
	// Hints:
	//   What registers are available for intermediate calculations?
	//
	// LAB 4: Your code here.
	
	movl	0x30(%esp), %eax
  800387:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl	$0x4, %eax
  80038b:	83 e8 04             	sub    $0x4,%eax
	movl	%eax, 0x30(%esp)
  80038e:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl	0x28(%esp), %ebx
  800392:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl	%ebx, (%eax)
  800396:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.
	// LAB 4: Your code here.

	addl	$0x8, %esp
  800398:	83 c4 08             	add    $0x8,%esp
	popal
  80039b:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.

	addl	$0x4, %esp
  80039c:	83 c4 04             	add    $0x4,%esp
	popfl
  80039f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	pop	%esp
  8003a0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003a1:	c3                   	ret    
	...

008003a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8003aa:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8003b1:	75 54                	jne    800407 <set_pgfault_handler+0x63>
		// First time through!
		
		// LAB 4: Your code here.

		if ((r = sys_page_alloc (0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8003b3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8003ba:	00 
  8003bb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8003c2:	ee 
  8003c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003ca:	e8 f9 fd ff ff       	call   8001c8 <sys_page_alloc>
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	79 20                	jns    8003f3 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8003d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d7:	c7 44 24 08 b7 11 80 	movl   $0x8011b7,0x8(%esp)
  8003de:	00 
  8003df:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8003e6:	00 
  8003e7:	c7 04 24 cf 11 80 00 	movl   $0x8011cf,(%esp)
  8003ee:	e8 21 00 00 00       	call   800414 <_panic>

		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8003f3:	c7 44 24 04 7c 03 80 	movl   $0x80037c,0x4(%esp)
  8003fa:	00 
  8003fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800402:	e8 d0 fe ff ff       	call   8002d7 <sys_env_set_pgfault_upcall>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    
  800411:	00 00                	add    %al,(%eax)
	...

00800414 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80041a:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80041f:	85 c0                	test   %eax,%eax
  800421:	74 10                	je     800433 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800423:	89 44 24 04          	mov    %eax,0x4(%esp)
  800427:	c7 04 24 dd 11 80 00 	movl   $0x8011dd,(%esp)
  80042e:	e8 a6 00 00 00       	call   8004d9 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800433:	8b 45 0c             	mov    0xc(%ebp),%eax
  800436:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800441:	a1 00 20 80 00       	mov    0x802000,%eax
  800446:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044a:	c7 04 24 e2 11 80 00 	movl   $0x8011e2,(%esp)
  800451:	e8 83 00 00 00       	call   8004d9 <cprintf>
	vcprintf(fmt, ap);
  800456:	8d 45 14             	lea    0x14(%ebp),%eax
  800459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045d:	8b 45 10             	mov    0x10(%ebp),%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	e8 10 00 00 00       	call   800478 <vcprintf>
	cprintf("\n");
  800468:	c7 04 24 fe 11 80 00 	movl   $0x8011fe,(%esp)
  80046f:	e8 65 00 00 00       	call   8004d9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800474:	cc                   	int3   
  800475:	eb fd                	jmp    800474 <_panic+0x60>
	...

00800478 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800481:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800488:	00 00 00 
	b.cnt = 0;
  80048b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800492:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800495:	8b 45 0c             	mov    0xc(%ebp),%eax
  800498:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049c:	8b 45 08             	mov    0x8(%ebp),%eax
  80049f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ad:	c7 04 24 f3 04 80 00 	movl   $0x8004f3,(%esp)
  8004b4:	e8 d7 01 00 00       	call   800690 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004b9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004c9:	89 04 24             	mov    %eax,(%esp)
  8004cc:	e8 f3 fb ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  8004d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8004df:	8d 45 0c             	lea    0xc(%ebp),%eax
  8004e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 87 ff ff ff       	call   800478 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004f1:	c9                   	leave  
  8004f2:	c3                   	ret    

008004f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	53                   	push   %ebx
  8004f7:	83 ec 14             	sub    $0x14,%esp
  8004fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004fd:	8b 03                	mov    (%ebx),%eax
  8004ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800502:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800506:	83 c0 01             	add    $0x1,%eax
  800509:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80050b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800510:	75 19                	jne    80052b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800512:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800519:	00 
  80051a:	8d 43 08             	lea    0x8(%ebx),%eax
  80051d:	89 04 24             	mov    %eax,(%esp)
  800520:	e8 9f fb ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  800525:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80052b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80052f:	83 c4 14             	add    $0x14,%esp
  800532:	5b                   	pop    %ebx
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    
	...

00800540 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	57                   	push   %edi
  800544:	56                   	push   %esi
  800545:	53                   	push   %ebx
  800546:	83 ec 4c             	sub    $0x4c,%esp
  800549:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054c:	89 d6                	mov    %edx,%esi
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	8b 55 0c             	mov    0xc(%ebp),%edx
  800557:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80055a:	8b 45 10             	mov    0x10(%ebp),%eax
  80055d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800560:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800563:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800566:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056b:	39 d1                	cmp    %edx,%ecx
  80056d:	72 15                	jb     800584 <printnum+0x44>
  80056f:	77 07                	ja     800578 <printnum+0x38>
  800571:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800574:	39 d0                	cmp    %edx,%eax
  800576:	76 0c                	jbe    800584 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800578:	83 eb 01             	sub    $0x1,%ebx
  80057b:	85 db                	test   %ebx,%ebx
  80057d:	8d 76 00             	lea    0x0(%esi),%esi
  800580:	7f 61                	jg     8005e3 <printnum+0xa3>
  800582:	eb 70                	jmp    8005f4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800584:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80058f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800593:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800597:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80059b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80059e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005a1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005af:	00 
  8005b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b3:	89 04 24             	mov    %eax,(%esp)
  8005b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005bd:	e8 5e 09 00 00       	call   800f20 <__udivdi3>
  8005c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d7:	89 f2                	mov    %esi,%edx
  8005d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005dc:	e8 5f ff ff ff       	call   800540 <printnum>
  8005e1:	eb 11                	jmp    8005f4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e7:	89 3c 24             	mov    %edi,(%esp)
  8005ea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005ed:	83 eb 01             	sub    $0x1,%ebx
  8005f0:	85 db                	test   %ebx,%ebx
  8005f2:	7f ef                	jg     8005e3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8005fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800603:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80060a:	00 
  80060b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060e:	89 14 24             	mov    %edx,(%esp)
  800611:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800614:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800618:	e8 33 0a 00 00       	call   801050 <__umoddi3>
  80061d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800621:	0f be 80 00 12 80 00 	movsbl 0x801200(%eax),%eax
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80062e:	83 c4 4c             	add    $0x4c,%esp
  800631:	5b                   	pop    %ebx
  800632:	5e                   	pop    %esi
  800633:	5f                   	pop    %edi
  800634:	5d                   	pop    %ebp
  800635:	c3                   	ret    

00800636 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800639:	83 fa 01             	cmp    $0x1,%edx
  80063c:	7e 0f                	jle    80064d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	83 c2 08             	add    $0x8,%edx
  800643:	89 10                	mov    %edx,(%eax)
  800645:	8b 42 f8             	mov    -0x8(%edx),%eax
  800648:	8b 52 fc             	mov    -0x4(%edx),%edx
  80064b:	eb 24                	jmp    800671 <getuint+0x3b>
	else if (lflag)
  80064d:	85 d2                	test   %edx,%edx
  80064f:	74 11                	je     800662 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800651:	8b 10                	mov    (%eax),%edx
  800653:	83 c2 04             	add    $0x4,%edx
  800656:	89 10                	mov    %edx,(%eax)
  800658:	8b 42 fc             	mov    -0x4(%edx),%eax
  80065b:	ba 00 00 00 00       	mov    $0x0,%edx
  800660:	eb 0f                	jmp    800671 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
  800662:	8b 10                	mov    (%eax),%edx
  800664:	83 c2 04             	add    $0x4,%edx
  800667:	89 10                	mov    %edx,(%eax)
  800669:	8b 42 fc             	mov    -0x4(%edx),%eax
  80066c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    

00800673 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800679:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	3b 50 04             	cmp    0x4(%eax),%edx
  800682:	73 0a                	jae    80068e <sprintputch+0x1b>
		*b->buf++ = ch;
  800684:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800687:	88 0a                	mov    %cl,(%edx)
  800689:	83 c2 01             	add    $0x1,%edx
  80068c:	89 10                	mov    %edx,(%eax)
}
  80068e:	5d                   	pop    %ebp
  80068f:	c3                   	ret    

00800690 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	57                   	push   %edi
  800694:	56                   	push   %esi
  800695:	53                   	push   %ebx
  800696:	83 ec 5c             	sub    $0x5c,%esp
  800699:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80069f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006a2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8006a9:	eb 11                	jmp    8006bc <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	0f 84 fd 03 00 00    	je     800ab0 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
  8006b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b7:	89 04 24             	mov    %eax,(%esp)
  8006ba:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006bc:	0f b6 03             	movzbl (%ebx),%eax
  8006bf:	83 c3 01             	add    $0x1,%ebx
  8006c2:	83 f8 25             	cmp    $0x25,%eax
  8006c5:	75 e4                	jne    8006ab <vprintfmt+0x1b>
  8006c7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006d9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e5:	eb 06                	jmp    8006ed <vprintfmt+0x5d>
  8006e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8006eb:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	0f b6 13             	movzbl (%ebx),%edx
  8006f0:	0f b6 c2             	movzbl %dl,%eax
  8006f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f6:	8d 43 01             	lea    0x1(%ebx),%eax
  8006f9:	83 ea 23             	sub    $0x23,%edx
  8006fc:	80 fa 55             	cmp    $0x55,%dl
  8006ff:	0f 87 8e 03 00 00    	ja     800a93 <vprintfmt+0x403>
  800705:	0f b6 d2             	movzbl %dl,%edx
  800708:	ff 24 95 c0 12 80 00 	jmp    *0x8012c0(,%edx,4)
  80070f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800713:	eb d6                	jmp    8006eb <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800715:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800718:	83 ea 30             	sub    $0x30,%edx
  80071b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  80071e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800721:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800724:	83 fb 09             	cmp    $0x9,%ebx
  800727:	77 55                	ja     80077e <vprintfmt+0xee>
  800729:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80072c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80072f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800732:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800735:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800739:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80073c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80073f:	83 fb 09             	cmp    $0x9,%ebx
  800742:	76 eb                	jbe    80072f <vprintfmt+0x9f>
  800744:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800747:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80074a:	eb 32                	jmp    80077e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80074c:	8b 55 14             	mov    0x14(%ebp),%edx
  80074f:	83 c2 04             	add    $0x4,%edx
  800752:	89 55 14             	mov    %edx,0x14(%ebp)
  800755:	8b 52 fc             	mov    -0x4(%edx),%edx
  800758:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80075b:	eb 21                	jmp    80077e <vprintfmt+0xee>

		case '.':
			if (width < 0)
  80075d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800761:	ba 00 00 00 00       	mov    $0x0,%edx
  800766:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  80076a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80076d:	e9 79 ff ff ff       	jmp    8006eb <vprintfmt+0x5b>
  800772:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800779:	e9 6d ff ff ff       	jmp    8006eb <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80077e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800782:	0f 89 63 ff ff ff    	jns    8006eb <vprintfmt+0x5b>
  800788:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80078b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80078e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800791:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800794:	e9 52 ff ff ff       	jmp    8006eb <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800799:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  80079c:	e9 4a ff ff ff       	jmp    8006eb <vprintfmt+0x5b>
  8007a1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	83 c0 04             	add    $0x4,%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b1:	8b 40 fc             	mov    -0x4(%eax),%eax
  8007b4:	89 04 24             	mov    %eax,(%esp)
  8007b7:	ff d7                	call   *%edi
  8007b9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  8007bc:	e9 fb fe ff ff       	jmp    8006bc <vprintfmt+0x2c>
  8007c1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	83 c0 04             	add    $0x4,%eax
  8007ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cd:	8b 40 fc             	mov    -0x4(%eax),%eax
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	c1 fa 1f             	sar    $0x1f,%edx
  8007d5:	31 d0                	xor    %edx,%eax
  8007d7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8007d9:	83 f8 08             	cmp    $0x8,%eax
  8007dc:	7f 0b                	jg     8007e9 <vprintfmt+0x159>
  8007de:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  8007e5:	85 d2                	test   %edx,%edx
  8007e7:	75 20                	jne    800809 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8007e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ed:	c7 44 24 08 11 12 80 	movl   $0x801211,0x8(%esp)
  8007f4:	00 
  8007f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f9:	89 3c 24             	mov    %edi,(%esp)
  8007fc:	e8 37 03 00 00       	call   800b38 <printfmt>
  800801:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800804:	e9 b3 fe ff ff       	jmp    8006bc <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800809:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80080d:	c7 44 24 08 1a 12 80 	movl   $0x80121a,0x8(%esp)
  800814:	00 
  800815:	89 74 24 04          	mov    %esi,0x4(%esp)
  800819:	89 3c 24             	mov    %edi,(%esp)
  80081c:	e8 17 03 00 00       	call   800b38 <printfmt>
  800821:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800824:	e9 93 fe ff ff       	jmp    8006bc <vprintfmt+0x2c>
  800829:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80082c:	89 c3                	mov    %eax,%ebx
  80082e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800831:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800834:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	83 c0 04             	add    $0x4,%eax
  80083d:	89 45 14             	mov    %eax,0x14(%ebp)
  800840:	8b 40 fc             	mov    -0x4(%eax),%eax
  800843:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800846:	85 c0                	test   %eax,%eax
  800848:	b8 1d 12 80 00       	mov    $0x80121d,%eax
  80084d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
  800851:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800854:	85 c9                	test   %ecx,%ecx
  800856:	7e 06                	jle    80085e <vprintfmt+0x1ce>
  800858:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80085c:	75 13                	jne    800871 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80085e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800861:	0f be 02             	movsbl (%edx),%eax
  800864:	85 c0                	test   %eax,%eax
  800866:	0f 85 99 00 00 00    	jne    800905 <vprintfmt+0x275>
  80086c:	e9 86 00 00 00       	jmp    8008f7 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800871:	89 54 24 04          	mov    %edx,0x4(%esp)
  800875:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800878:	89 0c 24             	mov    %ecx,(%esp)
  80087b:	e8 fb 02 00 00       	call   800b7b <strnlen>
  800880:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800883:	29 c2                	sub    %eax,%edx
  800885:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800888:	85 d2                	test   %edx,%edx
  80088a:	7e d2                	jle    80085e <vprintfmt+0x1ce>
					putch(padc, putdat);
  80088c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800890:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800893:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800896:	89 d3                	mov    %edx,%ebx
  800898:	89 74 24 04          	mov    %esi,0x4(%esp)
  80089c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80089f:	89 04 24             	mov    %eax,(%esp)
  8008a2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a4:	83 eb 01             	sub    $0x1,%ebx
  8008a7:	85 db                	test   %ebx,%ebx
  8008a9:	7f ed                	jg     800898 <vprintfmt+0x208>
  8008ab:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8008ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008b5:	eb a7                	jmp    80085e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008bb:	74 18                	je     8008d5 <vprintfmt+0x245>
  8008bd:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008c0:	83 fa 5e             	cmp    $0x5e,%edx
  8008c3:	76 10                	jbe    8008d5 <vprintfmt+0x245>
					putch('?', putdat);
  8008c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008d0:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008d3:	eb 0a                	jmp    8008df <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8008d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d9:	89 04 24             	mov    %eax,(%esp)
  8008dc:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008df:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008e3:	0f be 03             	movsbl (%ebx),%eax
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	74 05                	je     8008ef <vprintfmt+0x25f>
  8008ea:	83 c3 01             	add    $0x1,%ebx
  8008ed:	eb 29                	jmp    800918 <vprintfmt+0x288>
  8008ef:	89 fe                	mov    %edi,%esi
  8008f1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8008f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008fb:	7f 2e                	jg     80092b <vprintfmt+0x29b>
  8008fd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800900:	e9 b7 fd ff ff       	jmp    8006bc <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800905:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800908:	83 c2 01             	add    $0x1,%edx
  80090b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80090e:	89 f7                	mov    %esi,%edi
  800910:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800913:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800916:	89 d3                	mov    %edx,%ebx
  800918:	85 f6                	test   %esi,%esi
  80091a:	78 9b                	js     8008b7 <vprintfmt+0x227>
  80091c:	83 ee 01             	sub    $0x1,%esi
  80091f:	79 96                	jns    8008b7 <vprintfmt+0x227>
  800921:	89 fe                	mov    %edi,%esi
  800923:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800926:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800929:	eb cc                	jmp    8008f7 <vprintfmt+0x267>
  80092b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80092e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800931:	89 74 24 04          	mov    %esi,0x4(%esp)
  800935:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80093c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80093e:	83 eb 01             	sub    $0x1,%ebx
  800941:	85 db                	test   %ebx,%ebx
  800943:	7f ec                	jg     800931 <vprintfmt+0x2a1>
  800945:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800948:	e9 6f fd ff ff       	jmp    8006bc <vprintfmt+0x2c>
  80094d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800950:	83 f9 01             	cmp    $0x1,%ecx
  800953:	7e 17                	jle    80096c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	83 c0 08             	add    $0x8,%eax
  80095b:	89 45 14             	mov    %eax,0x14(%ebp)
  80095e:	8b 50 f8             	mov    -0x8(%eax),%edx
  800961:	8b 48 fc             	mov    -0x4(%eax),%ecx
  800964:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800967:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80096a:	eb 34                	jmp    8009a0 <vprintfmt+0x310>
	else if (lflag)
  80096c:	85 c9                	test   %ecx,%ecx
  80096e:	74 19                	je     800989 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
  800970:	8b 45 14             	mov    0x14(%ebp),%eax
  800973:	83 c0 04             	add    $0x4,%eax
  800976:	89 45 14             	mov    %eax,0x14(%ebp)
  800979:	8b 40 fc             	mov    -0x4(%eax),%eax
  80097c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097f:	89 c1                	mov    %eax,%ecx
  800981:	c1 f9 1f             	sar    $0x1f,%ecx
  800984:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800987:	eb 17                	jmp    8009a0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
  800989:	8b 45 14             	mov    0x14(%ebp),%eax
  80098c:	83 c0 04             	add    $0x4,%eax
  80098f:	89 45 14             	mov    %eax,0x14(%ebp)
  800992:	8b 40 fc             	mov    -0x4(%eax),%eax
  800995:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800998:	89 c2                	mov    %eax,%edx
  80099a:	c1 fa 1f             	sar    $0x1f,%edx
  80099d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8009a3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8009ab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009af:	0f 89 9c 00 00 00    	jns    800a51 <vprintfmt+0x3c1>
				putch('-', putdat);
  8009b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009c0:	ff d7                	call   *%edi
				num = -(long long) num;
  8009c2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8009c5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009c8:	f7 d9                	neg    %ecx
  8009ca:	83 d3 00             	adc    $0x0,%ebx
  8009cd:	f7 db                	neg    %ebx
  8009cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d4:	eb 7b                	jmp    800a51 <vprintfmt+0x3c1>
  8009d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d9:	89 ca                	mov    %ecx,%edx
  8009db:	8d 45 14             	lea    0x14(%ebp),%eax
  8009de:	e8 53 fc ff ff       	call   800636 <getuint>
  8009e3:	89 c1                	mov    %eax,%ecx
  8009e5:	89 d3                	mov    %edx,%ebx
  8009e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8009ec:	eb 63                	jmp    800a51 <vprintfmt+0x3c1>
  8009ee:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009f1:	89 ca                	mov    %ecx,%edx
  8009f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f6:	e8 3b fc ff ff       	call   800636 <getuint>
  8009fb:	89 c1                	mov    %eax,%ecx
  8009fd:	89 d3                	mov    %edx,%ebx
  8009ff:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800a04:	eb 4b                	jmp    800a51 <vprintfmt+0x3c1>
  800a06:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800a09:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a0d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a14:	ff d7                	call   *%edi
			putch('x', putdat);
  800a16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a1a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a21:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	83 c0 04             	add    $0x4,%eax
  800a29:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 48 fc             	mov    -0x4(%eax),%ecx
  800a2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a34:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a39:	eb 16                	jmp    800a51 <vprintfmt+0x3c1>
  800a3b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3e:	89 ca                	mov    %ecx,%edx
  800a40:	8d 45 14             	lea    0x14(%ebp),%eax
  800a43:	e8 ee fb ff ff       	call   800636 <getuint>
  800a48:	89 c1                	mov    %eax,%ecx
  800a4a:	89 d3                	mov    %edx,%ebx
  800a4c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a51:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800a55:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a60:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a64:	89 0c 24             	mov    %ecx,(%esp)
  800a67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6b:	89 f2                	mov    %esi,%edx
  800a6d:	89 f8                	mov    %edi,%eax
  800a6f:	e8 cc fa ff ff       	call   800540 <printnum>
  800a74:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800a77:	e9 40 fc ff ff       	jmp    8006bc <vprintfmt+0x2c>
  800a7c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800a7f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a82:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a86:	89 14 24             	mov    %edx,(%esp)
  800a89:	ff d7                	call   *%edi
  800a8b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
  800a8e:	e9 29 fc ff ff       	jmp    8006bc <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a93:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a97:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a9e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800aa3:	80 38 25             	cmpb   $0x25,(%eax)
  800aa6:	0f 84 10 fc ff ff    	je     8006bc <vprintfmt+0x2c>
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	eb f0                	jmp    800aa0 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
  800ab0:	83 c4 5c             	add    $0x5c,%esp
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5f                   	pop    %edi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	83 ec 28             	sub    $0x28,%esp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ac4:	85 c0                	test   %eax,%eax
  800ac6:	74 04                	je     800acc <vsnprintf+0x14>
  800ac8:	85 d2                	test   %edx,%edx
  800aca:	7f 07                	jg     800ad3 <vsnprintf+0x1b>
  800acc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad1:	eb 3b                	jmp    800b0e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad6:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ada:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800add:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aeb:	8b 45 10             	mov    0x10(%ebp),%eax
  800aee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af9:	c7 04 24 73 06 80 00 	movl   $0x800673,(%esp)
  800b00:	e8 8b fb ff ff       	call   800690 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b05:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b08:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b16:	8d 45 14             	lea    0x14(%ebp),%eax
  800b19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b20:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	89 04 24             	mov    %eax,(%esp)
  800b31:	e8 82 ff ff ff       	call   800ab8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b3e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b45:	8b 45 10             	mov    0x10(%ebp),%eax
  800b48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	89 04 24             	mov    %eax,(%esp)
  800b59:	e8 32 fb ff ff       	call   800690 <vprintfmt>
	va_end(ap);
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b6e:	74 09                	je     800b79 <strlen+0x19>
		n++;
  800b70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b77:	75 f7                	jne    800b70 <strlen+0x10>
		n++;
	return n;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	53                   	push   %ebx
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b85:	85 c9                	test   %ecx,%ecx
  800b87:	74 19                	je     800ba2 <strnlen+0x27>
  800b89:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b8c:	74 14                	je     800ba2 <strnlen+0x27>
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b93:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b96:	39 c8                	cmp    %ecx,%eax
  800b98:	74 0d                	je     800ba7 <strnlen+0x2c>
  800b9a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b9e:	75 f3                	jne    800b93 <strnlen+0x18>
  800ba0:	eb 05                	jmp    800ba7 <strnlen+0x2c>
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bbd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bc0:	83 c2 01             	add    $0x1,%edx
  800bc3:	84 c9                	test   %cl,%cl
  800bc5:	75 f2                	jne    800bb9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd8:	85 f6                	test   %esi,%esi
  800bda:	74 18                	je     800bf4 <strncpy+0x2a>
  800bdc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800be1:	0f b6 1a             	movzbl (%edx),%ebx
  800be4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be7:	80 3a 01             	cmpb   $0x1,(%edx)
  800bea:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bed:	83 c1 01             	add    $0x1,%ecx
  800bf0:	39 ce                	cmp    %ecx,%esi
  800bf2:	77 ed                	ja     800be1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	8b 75 08             	mov    0x8(%ebp),%esi
  800c00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c06:	89 f0                	mov    %esi,%eax
  800c08:	85 c9                	test   %ecx,%ecx
  800c0a:	74 27                	je     800c33 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c0c:	83 e9 01             	sub    $0x1,%ecx
  800c0f:	74 1d                	je     800c2e <strlcpy+0x36>
  800c11:	0f b6 1a             	movzbl (%edx),%ebx
  800c14:	84 db                	test   %bl,%bl
  800c16:	74 16                	je     800c2e <strlcpy+0x36>
			*dst++ = *src++;
  800c18:	88 18                	mov    %bl,(%eax)
  800c1a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c1d:	83 e9 01             	sub    $0x1,%ecx
  800c20:	74 0e                	je     800c30 <strlcpy+0x38>
			*dst++ = *src++;
  800c22:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c25:	0f b6 1a             	movzbl (%edx),%ebx
  800c28:	84 db                	test   %bl,%bl
  800c2a:	75 ec                	jne    800c18 <strlcpy+0x20>
  800c2c:	eb 02                	jmp    800c30 <strlcpy+0x38>
  800c2e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c30:	c6 00 00             	movb   $0x0,(%eax)
  800c33:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c42:	0f b6 01             	movzbl (%ecx),%eax
  800c45:	84 c0                	test   %al,%al
  800c47:	74 15                	je     800c5e <strcmp+0x25>
  800c49:	3a 02                	cmp    (%edx),%al
  800c4b:	75 11                	jne    800c5e <strcmp+0x25>
		p++, q++;
  800c4d:	83 c1 01             	add    $0x1,%ecx
  800c50:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c53:	0f b6 01             	movzbl (%ecx),%eax
  800c56:	84 c0                	test   %al,%al
  800c58:	74 04                	je     800c5e <strcmp+0x25>
  800c5a:	3a 02                	cmp    (%edx),%al
  800c5c:	74 ef                	je     800c4d <strcmp+0x14>
  800c5e:	0f b6 c0             	movzbl %al,%eax
  800c61:	0f b6 12             	movzbl (%edx),%edx
  800c64:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	53                   	push   %ebx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	74 23                	je     800c9c <strncmp+0x34>
  800c79:	0f b6 1a             	movzbl (%edx),%ebx
  800c7c:	84 db                	test   %bl,%bl
  800c7e:	74 24                	je     800ca4 <strncmp+0x3c>
  800c80:	3a 19                	cmp    (%ecx),%bl
  800c82:	75 20                	jne    800ca4 <strncmp+0x3c>
  800c84:	83 e8 01             	sub    $0x1,%eax
  800c87:	74 13                	je     800c9c <strncmp+0x34>
		n--, p++, q++;
  800c89:	83 c2 01             	add    $0x1,%edx
  800c8c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c8f:	0f b6 1a             	movzbl (%edx),%ebx
  800c92:	84 db                	test   %bl,%bl
  800c94:	74 0e                	je     800ca4 <strncmp+0x3c>
  800c96:	3a 19                	cmp    (%ecx),%bl
  800c98:	74 ea                	je     800c84 <strncmp+0x1c>
  800c9a:	eb 08                	jmp    800ca4 <strncmp+0x3c>
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca4:	0f b6 02             	movzbl (%edx),%eax
  800ca7:	0f b6 11             	movzbl (%ecx),%edx
  800caa:	29 d0                	sub    %edx,%eax
  800cac:	eb f3                	jmp    800ca1 <strncmp+0x39>

00800cae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb8:	0f b6 10             	movzbl (%eax),%edx
  800cbb:	84 d2                	test   %dl,%dl
  800cbd:	74 15                	je     800cd4 <strchr+0x26>
		if (*s == c)
  800cbf:	38 ca                	cmp    %cl,%dl
  800cc1:	75 07                	jne    800cca <strchr+0x1c>
  800cc3:	eb 14                	jmp    800cd9 <strchr+0x2b>
  800cc5:	38 ca                	cmp    %cl,%dl
  800cc7:	90                   	nop
  800cc8:	74 0f                	je     800cd9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cca:	83 c0 01             	add    $0x1,%eax
  800ccd:	0f b6 10             	movzbl (%eax),%edx
  800cd0:	84 d2                	test   %dl,%dl
  800cd2:	75 f1                	jne    800cc5 <strchr+0x17>
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce5:	0f b6 10             	movzbl (%eax),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	74 18                	je     800d04 <strfind+0x29>
		if (*s == c)
  800cec:	38 ca                	cmp    %cl,%dl
  800cee:	75 0a                	jne    800cfa <strfind+0x1f>
  800cf0:	eb 12                	jmp    800d04 <strfind+0x29>
  800cf2:	38 ca                	cmp    %cl,%dl
  800cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf8:	74 0a                	je     800d04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	0f b6 10             	movzbl (%eax),%edx
  800d00:	84 d2                	test   %dl,%dl
  800d02:	75 ee                	jne    800cf2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d13:	89 da                	mov    %ebx,%edx
  800d15:	83 ea 01             	sub    $0x1,%edx
  800d18:	78 0d                	js     800d27 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
  800d1a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800d1c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
  800d1e:	88 0a                	mov    %cl,(%edx)
  800d20:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d23:	39 da                	cmp    %ebx,%edx
  800d25:	75 f7                	jne    800d1e <memset+0x18>
		*p++ = c;

	return v;
}
  800d27:	5b                   	pop    %ebx
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800d38:	85 db                	test   %ebx,%ebx
  800d3a:	74 13                	je     800d4f <memcpy+0x25>
  800d3c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
  800d41:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d45:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d48:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800d4b:	39 da                	cmp    %ebx,%edx
  800d4d:	75 f2                	jne    800d41 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
  800d62:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
  800d64:	39 c6                	cmp    %eax,%esi
  800d66:	72 0b                	jb     800d73 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
  800d68:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
  800d6d:	85 db                	test   %ebx,%ebx
  800d6f:	75 2e                	jne    800d9f <memmove+0x4c>
  800d71:	eb 3a                	jmp    800dad <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d73:	01 df                	add    %ebx,%edi
  800d75:	39 f8                	cmp    %edi,%eax
  800d77:	73 ef                	jae    800d68 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
  800d79:	85 db                	test   %ebx,%ebx
  800d7b:	90                   	nop
  800d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d80:	74 2b                	je     800dad <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800d82:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
  800d8a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
  800d8f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
  800d93:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800d96:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
  800d99:	85 c9                	test   %ecx,%ecx
  800d9b:	75 ed                	jne    800d8a <memmove+0x37>
  800d9d:	eb 0e                	jmp    800dad <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800d9f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800da3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800da6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800da9:	39 d3                	cmp    %edx,%ebx
  800dab:	75 f2                	jne    800d9f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc1:	85 c9                	test   %ecx,%ecx
  800dc3:	74 36                	je     800dfb <memcmp+0x49>
		if (*s1 != *s2)
  800dc5:	0f b6 06             	movzbl (%esi),%eax
  800dc8:	0f b6 1f             	movzbl (%edi),%ebx
  800dcb:	38 d8                	cmp    %bl,%al
  800dcd:	74 20                	je     800def <memcmp+0x3d>
  800dcf:	eb 14                	jmp    800de5 <memcmp+0x33>
  800dd1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800dd6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ddb:	83 c2 01             	add    $0x1,%edx
  800dde:	83 e9 01             	sub    $0x1,%ecx
  800de1:	38 d8                	cmp    %bl,%al
  800de3:	74 12                	je     800df7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800de5:	0f b6 c0             	movzbl %al,%eax
  800de8:	0f b6 db             	movzbl %bl,%ebx
  800deb:	29 d8                	sub    %ebx,%eax
  800ded:	eb 11                	jmp    800e00 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800def:	83 e9 01             	sub    $0x1,%ecx
  800df2:	ba 00 00 00 00       	mov    $0x0,%edx
  800df7:	85 c9                	test   %ecx,%ecx
  800df9:	75 d6                	jne    800dd1 <memcmp+0x1f>
  800dfb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e0b:	89 c2                	mov    %eax,%edx
  800e0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e10:	39 d0                	cmp    %edx,%eax
  800e12:	73 15                	jae    800e29 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e18:	38 08                	cmp    %cl,(%eax)
  800e1a:	75 06                	jne    800e22 <memfind+0x1d>
  800e1c:	eb 0b                	jmp    800e29 <memfind+0x24>
  800e1e:	38 08                	cmp    %cl,(%eax)
  800e20:	74 07                	je     800e29 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e22:	83 c0 01             	add    $0x1,%eax
  800e25:	39 c2                	cmp    %eax,%edx
  800e27:	77 f5                	ja     800e1e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	83 ec 04             	sub    $0x4,%esp
  800e34:	8b 55 08             	mov    0x8(%ebp),%edx
  800e37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e3a:	0f b6 02             	movzbl (%edx),%eax
  800e3d:	3c 20                	cmp    $0x20,%al
  800e3f:	74 04                	je     800e45 <strtol+0x1a>
  800e41:	3c 09                	cmp    $0x9,%al
  800e43:	75 0e                	jne    800e53 <strtol+0x28>
		s++;
  800e45:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e48:	0f b6 02             	movzbl (%edx),%eax
  800e4b:	3c 20                	cmp    $0x20,%al
  800e4d:	74 f6                	je     800e45 <strtol+0x1a>
  800e4f:	3c 09                	cmp    $0x9,%al
  800e51:	74 f2                	je     800e45 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e53:	3c 2b                	cmp    $0x2b,%al
  800e55:	75 0c                	jne    800e63 <strtol+0x38>
		s++;
  800e57:	83 c2 01             	add    $0x1,%edx
  800e5a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e61:	eb 15                	jmp    800e78 <strtol+0x4d>
	else if (*s == '-')
  800e63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e6a:	3c 2d                	cmp    $0x2d,%al
  800e6c:	75 0a                	jne    800e78 <strtol+0x4d>
		s++, neg = 1;
  800e6e:	83 c2 01             	add    $0x1,%edx
  800e71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e78:	85 db                	test   %ebx,%ebx
  800e7a:	0f 94 c0             	sete   %al
  800e7d:	74 05                	je     800e84 <strtol+0x59>
  800e7f:	83 fb 10             	cmp    $0x10,%ebx
  800e82:	75 18                	jne    800e9c <strtol+0x71>
  800e84:	80 3a 30             	cmpb   $0x30,(%edx)
  800e87:	75 13                	jne    800e9c <strtol+0x71>
  800e89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e8d:	8d 76 00             	lea    0x0(%esi),%esi
  800e90:	75 0a                	jne    800e9c <strtol+0x71>
		s += 2, base = 16;
  800e92:	83 c2 02             	add    $0x2,%edx
  800e95:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e9a:	eb 15                	jmp    800eb1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e9c:	84 c0                	test   %al,%al
  800e9e:	66 90                	xchg   %ax,%ax
  800ea0:	74 0f                	je     800eb1 <strtol+0x86>
  800ea2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ea7:	80 3a 30             	cmpb   $0x30,(%edx)
  800eaa:	75 05                	jne    800eb1 <strtol+0x86>
		s++, base = 8;
  800eac:	83 c2 01             	add    $0x1,%edx
  800eaf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800eb8:	0f b6 0a             	movzbl (%edx),%ecx
  800ebb:	89 cf                	mov    %ecx,%edi
  800ebd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ec0:	80 fb 09             	cmp    $0x9,%bl
  800ec3:	77 08                	ja     800ecd <strtol+0xa2>
			dig = *s - '0';
  800ec5:	0f be c9             	movsbl %cl,%ecx
  800ec8:	83 e9 30             	sub    $0x30,%ecx
  800ecb:	eb 1e                	jmp    800eeb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ecd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ed0:	80 fb 19             	cmp    $0x19,%bl
  800ed3:	77 08                	ja     800edd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ed5:	0f be c9             	movsbl %cl,%ecx
  800ed8:	83 e9 57             	sub    $0x57,%ecx
  800edb:	eb 0e                	jmp    800eeb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800edd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ee0:	80 fb 19             	cmp    $0x19,%bl
  800ee3:	77 15                	ja     800efa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ee5:	0f be c9             	movsbl %cl,%ecx
  800ee8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800eeb:	39 f1                	cmp    %esi,%ecx
  800eed:	7d 0b                	jge    800efa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800eef:	83 c2 01             	add    $0x1,%edx
  800ef2:	0f af c6             	imul   %esi,%eax
  800ef5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ef8:	eb be                	jmp    800eb8 <strtol+0x8d>
  800efa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800efc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f00:	74 05                	je     800f07 <strtol+0xdc>
		*endptr = (char *) s;
  800f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f05:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f07:	89 ca                	mov    %ecx,%edx
  800f09:	f7 da                	neg    %edx
  800f0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f0f:	0f 45 c2             	cmovne %edx,%eax
}
  800f12:	83 c4 04             	add    $0x4,%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    
  800f1a:	00 00                	add    %al,(%eax)
  800f1c:	00 00                	add    %al,(%eax)
	...

00800f20 <__udivdi3>:
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	83 ec 10             	sub    $0x10,%esp
  800f28:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f31:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f34:	85 c0                	test   %eax,%eax
  800f36:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f39:	75 35                	jne    800f70 <__udivdi3+0x50>
  800f3b:	39 fe                	cmp    %edi,%esi
  800f3d:	77 61                	ja     800fa0 <__udivdi3+0x80>
  800f3f:	85 f6                	test   %esi,%esi
  800f41:	75 0b                	jne    800f4e <__udivdi3+0x2e>
  800f43:	b8 01 00 00 00       	mov    $0x1,%eax
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	f7 f6                	div    %esi
  800f4c:	89 c6                	mov    %eax,%esi
  800f4e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800f51:	31 d2                	xor    %edx,%edx
  800f53:	89 f8                	mov    %edi,%eax
  800f55:	f7 f6                	div    %esi
  800f57:	89 c7                	mov    %eax,%edi
  800f59:	89 c8                	mov    %ecx,%eax
  800f5b:	f7 f6                	div    %esi
  800f5d:	89 c1                	mov    %eax,%ecx
  800f5f:	89 fa                	mov    %edi,%edx
  800f61:	89 c8                	mov    %ecx,%eax
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    
  800f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f70:	39 f8                	cmp    %edi,%eax
  800f72:	77 1c                	ja     800f90 <__udivdi3+0x70>
  800f74:	0f bd d0             	bsr    %eax,%edx
  800f77:	83 f2 1f             	xor    $0x1f,%edx
  800f7a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f7d:	75 39                	jne    800fb8 <__udivdi3+0x98>
  800f7f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800f82:	0f 86 a0 00 00 00    	jbe    801028 <__udivdi3+0x108>
  800f88:	39 f8                	cmp    %edi,%eax
  800f8a:	0f 82 98 00 00 00    	jb     801028 <__udivdi3+0x108>
  800f90:	31 ff                	xor    %edi,%edi
  800f92:	31 c9                	xor    %ecx,%ecx
  800f94:	89 c8                	mov    %ecx,%eax
  800f96:	89 fa                	mov    %edi,%edx
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    
  800f9f:	90                   	nop
  800fa0:	89 d1                	mov    %edx,%ecx
  800fa2:	89 fa                	mov    %edi,%edx
  800fa4:	89 c8                	mov    %ecx,%eax
  800fa6:	31 ff                	xor    %edi,%edi
  800fa8:	f7 f6                	div    %esi
  800faa:	89 c1                	mov    %eax,%ecx
  800fac:	89 fa                	mov    %edi,%edx
  800fae:	89 c8                	mov    %ecx,%eax
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    
  800fb7:	90                   	nop
  800fb8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fbc:	89 f2                	mov    %esi,%edx
  800fbe:	d3 e0                	shl    %cl,%eax
  800fc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fc3:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fcb:	89 c1                	mov    %eax,%ecx
  800fcd:	d3 ea                	shr    %cl,%edx
  800fcf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fd3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800fd6:	d3 e6                	shl    %cl,%esi
  800fd8:	89 c1                	mov    %eax,%ecx
  800fda:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800fdd:	89 fe                	mov    %edi,%esi
  800fdf:	d3 ee                	shr    %cl,%esi
  800fe1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fe5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fe8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800feb:	d3 e7                	shl    %cl,%edi
  800fed:	89 c1                	mov    %eax,%ecx
  800fef:	d3 ea                	shr    %cl,%edx
  800ff1:	09 d7                	or     %edx,%edi
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	89 f8                	mov    %edi,%eax
  800ff7:	f7 75 ec             	divl   -0x14(%ebp)
  800ffa:	89 d6                	mov    %edx,%esi
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	f7 65 e8             	mull   -0x18(%ebp)
  801001:	39 d6                	cmp    %edx,%esi
  801003:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801006:	72 30                	jb     801038 <__udivdi3+0x118>
  801008:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80100b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80100f:	d3 e2                	shl    %cl,%edx
  801011:	39 c2                	cmp    %eax,%edx
  801013:	73 05                	jae    80101a <__udivdi3+0xfa>
  801015:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801018:	74 1e                	je     801038 <__udivdi3+0x118>
  80101a:	89 f9                	mov    %edi,%ecx
  80101c:	31 ff                	xor    %edi,%edi
  80101e:	e9 71 ff ff ff       	jmp    800f94 <__udivdi3+0x74>
  801023:	90                   	nop
  801024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801028:	31 ff                	xor    %edi,%edi
  80102a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80102f:	e9 60 ff ff ff       	jmp    800f94 <__udivdi3+0x74>
  801034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801038:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80103b:	31 ff                	xor    %edi,%edi
  80103d:	89 c8                	mov    %ecx,%eax
  80103f:	89 fa                	mov    %edi,%edx
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    
	...

00801050 <__umoddi3>:
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	83 ec 20             	sub    $0x20,%esp
  801058:	8b 55 14             	mov    0x14(%ebp),%edx
  80105b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801061:	8b 75 0c             	mov    0xc(%ebp),%esi
  801064:	85 d2                	test   %edx,%edx
  801066:	89 c8                	mov    %ecx,%eax
  801068:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80106b:	75 13                	jne    801080 <__umoddi3+0x30>
  80106d:	39 f7                	cmp    %esi,%edi
  80106f:	76 3f                	jbe    8010b0 <__umoddi3+0x60>
  801071:	89 f2                	mov    %esi,%edx
  801073:	f7 f7                	div    %edi
  801075:	89 d0                	mov    %edx,%eax
  801077:	31 d2                	xor    %edx,%edx
  801079:	83 c4 20             	add    $0x20,%esp
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    
  801080:	39 f2                	cmp    %esi,%edx
  801082:	77 4c                	ja     8010d0 <__umoddi3+0x80>
  801084:	0f bd ca             	bsr    %edx,%ecx
  801087:	83 f1 1f             	xor    $0x1f,%ecx
  80108a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80108d:	75 51                	jne    8010e0 <__umoddi3+0x90>
  80108f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801092:	0f 87 e0 00 00 00    	ja     801178 <__umoddi3+0x128>
  801098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109b:	29 f8                	sub    %edi,%eax
  80109d:	19 d6                	sbb    %edx,%esi
  80109f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a5:	89 f2                	mov    %esi,%edx
  8010a7:	83 c4 20             	add    $0x20,%esp
  8010aa:	5e                   	pop    %esi
  8010ab:	5f                   	pop    %edi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    
  8010ae:	66 90                	xchg   %ax,%ax
  8010b0:	85 ff                	test   %edi,%edi
  8010b2:	75 0b                	jne    8010bf <__umoddi3+0x6f>
  8010b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b9:	31 d2                	xor    %edx,%edx
  8010bb:	f7 f7                	div    %edi
  8010bd:	89 c7                	mov    %eax,%edi
  8010bf:	89 f0                	mov    %esi,%eax
  8010c1:	31 d2                	xor    %edx,%edx
  8010c3:	f7 f7                	div    %edi
  8010c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c8:	f7 f7                	div    %edi
  8010ca:	eb a9                	jmp    801075 <__umoddi3+0x25>
  8010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	89 c8                	mov    %ecx,%eax
  8010d2:	89 f2                	mov    %esi,%edx
  8010d4:	83 c4 20             	add    $0x20,%esp
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    
  8010db:	90                   	nop
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010e4:	d3 e2                	shl    %cl,%edx
  8010e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8010ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8010f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010f8:	89 fa                	mov    %edi,%edx
  8010fa:	d3 ea                	shr    %cl,%edx
  8010fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801100:	0b 55 f4             	or     -0xc(%ebp),%edx
  801103:	d3 e7                	shl    %cl,%edi
  801105:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801109:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80110c:	89 f2                	mov    %esi,%edx
  80110e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801111:	89 c7                	mov    %eax,%edi
  801113:	d3 ea                	shr    %cl,%edx
  801115:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801119:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80111c:	89 c2                	mov    %eax,%edx
  80111e:	d3 e6                	shl    %cl,%esi
  801120:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801124:	d3 ea                	shr    %cl,%edx
  801126:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80112a:	09 d6                	or     %edx,%esi
  80112c:	89 f0                	mov    %esi,%eax
  80112e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801131:	d3 e7                	shl    %cl,%edi
  801133:	89 f2                	mov    %esi,%edx
  801135:	f7 75 f4             	divl   -0xc(%ebp)
  801138:	89 d6                	mov    %edx,%esi
  80113a:	f7 65 e8             	mull   -0x18(%ebp)
  80113d:	39 d6                	cmp    %edx,%esi
  80113f:	72 2b                	jb     80116c <__umoddi3+0x11c>
  801141:	39 c7                	cmp    %eax,%edi
  801143:	72 23                	jb     801168 <__umoddi3+0x118>
  801145:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801149:	29 c7                	sub    %eax,%edi
  80114b:	19 d6                	sbb    %edx,%esi
  80114d:	89 f0                	mov    %esi,%eax
  80114f:	89 f2                	mov    %esi,%edx
  801151:	d3 ef                	shr    %cl,%edi
  801153:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801157:	d3 e0                	shl    %cl,%eax
  801159:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80115d:	09 f8                	or     %edi,%eax
  80115f:	d3 ea                	shr    %cl,%edx
  801161:	83 c4 20             	add    $0x20,%esp
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    
  801168:	39 d6                	cmp    %edx,%esi
  80116a:	75 d9                	jne    801145 <__umoddi3+0xf5>
  80116c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80116f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801172:	eb d1                	jmp    801145 <__umoddi3+0xf5>
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	39 f2                	cmp    %esi,%edx
  80117a:	0f 82 18 ff ff ff    	jb     801098 <__umoddi3+0x48>
  801180:	e9 1d ff ff ff       	jmp    8010a2 <__umoddi3+0x52>
