
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $28,%ax; movw %ax,%ds");
  800037:	66 b8 1c 00          	mov    $0x1c,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800049:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
//	env = &envs[ENVX(sys_getenvid())];
        env = envs + ENVX(sys_getenvid ());
  800052:	e8 e9 00 00 00       	call   800140 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 64             	imul   $0x64,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 10 80 00       	mov    %eax,0x801004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x34>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800074:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800078:	89 34 24             	mov    %esi,(%esp)
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
}
  800085:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800088:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008b:	89 ec                	mov    %ebp,%esp
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 69 00 00 00       	call   80010b <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 0c             	sub    $0xc,%esp
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	89 c6                	mov    %eax,%esi
  8000c6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  8000c8:	8b 1c 24             	mov    (%esp),%ebx
  8000cb:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000cf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000d3:	89 ec                	mov    %ebp,%esp
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	89 1c 24             	mov    %ebx,(%esp)
  8000e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000e4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  8000fc:	8b 1c 24             	mov    (%esp),%ebx
  8000ff:	8b 74 24 04          	mov    0x4(%esp),%esi
  800103:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800107:	89 ec                	mov    %ebp,%esp
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	89 1c 24             	mov    %ebx,(%esp)
  800114:	89 74 24 04          	mov    %esi,0x4(%esp)
  800118:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	b8 03 00 00 00       	mov    $0x3,%eax
  800126:	8b 55 08             	mov    0x8(%ebp),%edx
  800129:	89 cb                	mov    %ecx,%ebx
  80012b:	89 cf                	mov    %ecx,%edi
  80012d:	89 ce                	mov    %ecx,%esi
  80012f:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800131:	8b 1c 24             	mov    (%esp),%ebx
  800134:	8b 74 24 04          	mov    0x4(%esp),%esi
  800138:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80013c:	89 ec                	mov    %ebp,%esp
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 0c             	sub    $0xc,%esp
  800146:	89 1c 24             	mov    %ebx,(%esp)
  800149:	89 74 24 04          	mov    %esi,0x4(%esp)
  80014d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800165:	8b 1c 24             	mov    (%esp),%ebx
  800168:	8b 74 24 04          	mov    0x4(%esp),%esi
  80016c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    
