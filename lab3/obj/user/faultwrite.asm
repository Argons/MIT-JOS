
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
//	env = &envs[ENVX(sys_getenvid())];
        env = envs + ENVX(sys_getenvid ());
  800056:	e8 e9 00 00 00       	call   800144 <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	6b c0 64             	imul   $0x64,%eax,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 10 80 00       	mov    %eax,0x801004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x34>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800078:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007c:	89 34 24             	mov    %esi,(%esp)
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
}
  800089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80008c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008f:	89 ec                	mov    %ebp,%esp
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 69 00 00 00       	call   80010f <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	89 c3                	mov    %eax,%ebx
  8000c6:	89 c7                	mov    %eax,%edi
  8000c8:	89 c6                	mov    %eax,%esi
  8000ca:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, (uint32_t) s, len, 0, 0, 0);
}
  8000cc:	8b 1c 24             	mov    (%esp),%ebx
  8000cf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000d3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000d7:	89 ec                	mov    %ebp,%esp
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	89 1c 24             	mov    %ebx,(%esp)
  8000e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000e8:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	89 d1                	mov    %edx,%ecx
  8000f8:	89 d3                	mov    %edx,%ebx
  8000fa:	89 d7                	mov    %edx,%edi
  8000fc:	89 d6                	mov    %edx,%esi
  8000fe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
}
  800100:	8b 1c 24             	mov    (%esp),%ebx
  800103:	8b 74 24 04          	mov    0x4(%esp),%esi
  800107:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	89 1c 24             	mov    %ebx,(%esp)
  800118:	89 74 24 04          	mov    %esi,0x4(%esp)
  80011c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800120:	b9 00 00 00 00       	mov    $0x0,%ecx
  800125:	b8 03 00 00 00       	mov    $0x3,%eax
  80012a:	8b 55 08             	mov    0x8(%ebp),%edx
  80012d:	89 cb                	mov    %ecx,%ebx
  80012f:	89 cf                	mov    %ecx,%edi
  800131:	89 ce                	mov    %ecx,%esi
  800133:	cd 30                	int    $0x30

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
}
  800135:	8b 1c 24             	mov    (%esp),%ebx
  800138:	8b 74 24 04          	mov    0x4(%esp),%esi
  80013c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800140:	89 ec                	mov    %ebp,%esp
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	89 1c 24             	mov    %ebx,(%esp)
  80014d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800151:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
}
  800169:	8b 1c 24             	mov    (%esp),%ebx
  80016c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800170:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800174:	89 ec                	mov    %ebp,%esp
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    
