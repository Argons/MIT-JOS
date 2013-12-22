
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 66 00 00 00       	call   8000b4 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
//	env = &envs[ENVX(sys_getenvid())];
        env = envs + ENVX(sys_getenvid ());
  800062:	e8 e9 00 00 00       	call   800150 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	6b c0 64             	imul   $0x64,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 10 80 00       	mov    %eax,0x801004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x34>
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
