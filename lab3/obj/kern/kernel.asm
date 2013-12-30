
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 70 11 00 	lgdtl  0x117018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

        # Leave a few words on the stack for the user trap frame
	movl	$(bootstacktop-SIZEOF_STRUCT_TRAPFRAME),%esp
f0100033:	bc bc 6f 11 f0       	mov    $0xf0116fbc,%esp

	# now to C code
	call	i386_init
f0100038:	e8 a0 00 00 00       	call   f01000dd <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f0100046:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100049:	89 44 24 08          	mov    %eax,0x8(%esp)
f010004d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100050:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100054:	c7 04 24 60 42 10 f0 	movl   $0xf0104260,(%esp)
f010005b:	e8 af 28 00 00       	call   f010290f <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 6a 28 00 00       	call   f01028dc <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 06 4d 10 f0 	movl   $0xf0104d06,(%esp)
f0100079:	e8 91 28 00 00       	call   f010290f <cprintf>
	va_end(ap);
}
f010007e:	c9                   	leave  
f010007f:	c3                   	ret    

f0100080 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100080:	55                   	push   %ebp
f0100081:	89 e5                	mov    %esp,%ebp
f0100083:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f0100086:	83 3d 00 b2 15 f0 00 	cmpl   $0x0,0xf015b200
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 00 b2 15 f0       	mov    %eax,0xf015b200

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 7a 42 10 f0 	movl   $0xf010427a,(%esp)
f01000ac:	e8 5e 28 00 00       	call   f010290f <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 19 28 00 00       	call   f01028dc <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 06 4d 10 f0 	movl   $0xf0104d06,(%esp)
f01000ca:	e8 40 28 00 00       	call   f010290f <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 c5 06 00 00       	call   f01007a0 <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000e3:	b8 10 c1 15 f0       	mov    $0xf015c110,%eax
f01000e8:	2d fa b1 15 f0       	sub    $0xf015b1fa,%eax
f01000ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000f8:	00 
f01000f9:	c7 04 24 fa b1 15 f0 	movl   $0xf015b1fa,(%esp)
f0100100:	e8 c1 3c 00 00       	call   f0103dc6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100105:	e8 41 02 00 00       	call   f010034b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010010a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100111:	00 
f0100112:	c7 04 24 92 42 10 f0 	movl   $0xf0104292,(%esp)
f0100119:	e8 f1 27 00 00       	call   f010290f <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f010011e:	e8 f3 1d 00 00       	call   f0101f16 <i386_detect_memory>
	i386_vm_init();
f0100123:	e8 31 19 00 00       	call   f0101a59 <i386_vm_init>
	page_init();
f0100128:	e8 80 1e 00 00       	call   f0101fad <page_init>
	page_check();
f010012d:	8d 76 00             	lea    0x0(%esi),%esi
f0100130:	e8 12 0f 00 00       	call   f0101047 <page_check>

	// Lab 3 user environment initialization functions
	env_init();
f0100135:	e8 39 20 00 00       	call   f0102173 <env_init>
	idt_init();
f010013a:	e8 01 28 00 00       	call   f0102940 <idt_init>


	// Temporary test code specific to LAB 3
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE);
f010013f:	c7 44 24 04 9a 78 00 	movl   $0x789a,0x4(%esp)
f0100146:	00 
f0100147:	c7 04 24 27 76 12 f0 	movl   $0xf0127627,(%esp)
f010014e:	e8 24 25 00 00       	call   f0102677 <env_create>
	ENV_CREATE(user_hello);
#endif // TEST*

//	ENV_CREATE(user_divzero);
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100153:	a1 60 b4 15 f0       	mov    0xf015b460,%eax
f0100158:	89 04 24             	mov    %eax,(%esp)
f010015b:	e8 b4 20 00 00       	call   f0102214 <env_run>

f0100160 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100160:	55                   	push   %ebp
f0100161:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100163:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100168:	ec                   	in     (%dx),%al
f0100169:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010016b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100170:	f6 c2 01             	test   $0x1,%dl
f0100173:	74 09                	je     f010017e <serial_proc_data+0x1e>
f0100175:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017b:	0f b6 c0             	movzbl %al,%eax
}
f010017e:	5d                   	pop    %ebp
f010017f:	c3                   	ret    

f0100180 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp
f0100183:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100184:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100189:	b8 00 00 00 00       	mov    $0x0,%eax
f010018e:	89 da                	mov    %ebx,%edx
f0100190:	ee                   	out    %al,(%dx)
f0100191:	b2 fb                	mov    $0xfb,%dl
f0100193:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100198:	ee                   	out    %al,(%dx)
f0100199:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010019e:	b8 0c 00 00 00       	mov    $0xc,%eax
f01001a3:	89 ca                	mov    %ecx,%edx
f01001a5:	ee                   	out    %al,(%dx)
f01001a6:	b2 f9                	mov    $0xf9,%dl
f01001a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ad:	ee                   	out    %al,(%dx)
f01001ae:	b2 fb                	mov    $0xfb,%dl
f01001b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01001b5:	ee                   	out    %al,(%dx)
f01001b6:	b2 fc                	mov    $0xfc,%dl
f01001b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001bd:	ee                   	out    %al,(%dx)
f01001be:	b2 f9                	mov    $0xf9,%dl
f01001c0:	b8 01 00 00 00       	mov    $0x1,%eax
f01001c5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c6:	b2 fd                	mov    $0xfd,%dl
f01001c8:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01001c9:	3c ff                	cmp    $0xff,%al
f01001cb:	0f 95 c0             	setne  %al
f01001ce:	0f b6 c0             	movzbl %al,%eax
f01001d1:	a3 24 b2 15 f0       	mov    %eax,0xf015b224
f01001d6:	89 da                	mov    %ebx,%edx
f01001d8:	ec                   	in     (%dx),%al
f01001d9:	89 ca                	mov    %ecx,%edx
f01001db:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f01001dc:	5b                   	pop    %ebx
f01001dd:	5d                   	pop    %ebp
f01001de:	c3                   	ret    

f01001df <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	83 ec 0c             	sub    $0xc,%esp
f01001e5:	89 1c 24             	mov    %ebx,(%esp)
f01001e8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01001ec:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01001f0:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01001f5:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01001f8:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01001fd:	0f b7 00             	movzwl (%eax),%eax
f0100200:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100204:	74 11                	je     f0100217 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100206:	c7 05 28 b2 15 f0 b4 	movl   $0x3b4,0xf015b228
f010020d:	03 00 00 
f0100210:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100215:	eb 16                	jmp    f010022d <cga_init+0x4e>
	} else {
		*cp = was;
f0100217:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010021e:	c7 05 28 b2 15 f0 d4 	movl   $0x3d4,0xf015b228
f0100225:	03 00 00 
f0100228:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010022d:	8b 0d 28 b2 15 f0    	mov    0xf015b228,%ecx
f0100233:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100235:	b8 0e 00 00 00       	mov    $0xe,%eax
f010023a:	89 ca                	mov    %ecx,%edx
f010023c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010023d:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100240:	89 ca                	mov    %ecx,%edx
f0100242:	ec                   	in     (%dx),%al
f0100243:	0f b6 f8             	movzbl %al,%edi
f0100246:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100249:	b8 0f 00 00 00       	mov    $0xf,%eax
f010024e:	89 da                	mov    %ebx,%edx
f0100250:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100251:	89 ca                	mov    %ecx,%edx
f0100253:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100254:	89 35 2c b2 15 f0    	mov    %esi,0xf015b22c
	crt_pos = pos;
f010025a:	0f b6 c8             	movzbl %al,%ecx
f010025d:	09 cf                	or     %ecx,%edi
f010025f:	66 89 3d 30 b2 15 f0 	mov    %di,0xf015b230
}
f0100266:	8b 1c 24             	mov    (%esp),%ebx
f0100269:	8b 74 24 04          	mov    0x4(%esp),%esi
f010026d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0100271:	89 ec                	mov    %ebp,%esp
f0100273:	5d                   	pop    %ebp
f0100274:	c3                   	ret    

f0100275 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f0100275:	55                   	push   %ebp
f0100276:	89 e5                	mov    %esp,%ebp
}
f0100278:	5d                   	pop    %ebp
f0100279:	c3                   	ret    

f010027a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f010027a:	55                   	push   %ebp
f010027b:	89 e5                	mov    %esp,%ebp
f010027d:	57                   	push   %edi
f010027e:	56                   	push   %esi
f010027f:	53                   	push   %ebx
f0100280:	83 ec 0c             	sub    $0xc,%esp
f0100283:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100286:	bb 44 b4 15 f0       	mov    $0xf015b444,%ebx
f010028b:	bf 40 b2 15 f0       	mov    $0xf015b240,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100290:	eb 1b                	jmp    f01002ad <cons_intr+0x33>
		if (c == 0)
f0100292:	85 c0                	test   %eax,%eax
f0100294:	74 17                	je     f01002ad <cons_intr+0x33>
			continue;
		cons.buf[cons.wpos++] = c;
f0100296:	8b 13                	mov    (%ebx),%edx
f0100298:	88 04 3a             	mov    %al,(%edx,%edi,1)
f010029b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010029e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01002a8:	0f 44 c2             	cmove  %edx,%eax
f01002ab:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002ad:	ff d6                	call   *%esi
f01002af:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002b2:	75 de                	jne    f0100292 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002b4:	83 c4 0c             	add    $0xc,%esp
f01002b7:	5b                   	pop    %ebx
f01002b8:	5e                   	pop    %esi
f01002b9:	5f                   	pop    %edi
f01002ba:	5d                   	pop    %ebp
f01002bb:	c3                   	ret    

f01002bc <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp
f01002bf:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f01002c2:	c7 04 24 72 03 10 f0 	movl   $0xf0100372,(%esp)
f01002c9:	e8 ac ff ff ff       	call   f010027a <cons_intr>
}
f01002ce:	c9                   	leave  
f01002cf:	c3                   	ret    

f01002d0 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp
f01002d3:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f01002d6:	83 3d 24 b2 15 f0 00 	cmpl   $0x0,0xf015b224
f01002dd:	74 0c                	je     f01002eb <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f01002df:	c7 04 24 60 01 10 f0 	movl   $0xf0100160,(%esp)
f01002e6:	e8 8f ff ff ff       	call   f010027a <cons_intr>
}
f01002eb:	c9                   	leave  
f01002ec:	c3                   	ret    

f01002ed <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01002ed:	55                   	push   %ebp
f01002ee:	89 e5                	mov    %esp,%ebp
f01002f0:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01002f3:	e8 d8 ff ff ff       	call   f01002d0 <serial_intr>
	kbd_intr();
f01002f8:	e8 bf ff ff ff       	call   f01002bc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01002fd:	8b 15 40 b4 15 f0    	mov    0xf015b440,%edx
f0100303:	b8 00 00 00 00       	mov    $0x0,%eax
f0100308:	3b 15 44 b4 15 f0    	cmp    0xf015b444,%edx
f010030e:	74 1e                	je     f010032e <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100310:	0f b6 82 40 b2 15 f0 	movzbl -0xfea4dc0(%edx),%eax
f0100317:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010031a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100320:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100325:	0f 44 d1             	cmove  %ecx,%edx
f0100328:	89 15 40 b4 15 f0    	mov    %edx,0xf015b440
		return c;
	}
	return 0;
}
f010032e:	c9                   	leave  
f010032f:	c3                   	ret    

f0100330 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100330:	55                   	push   %ebp
f0100331:	89 e5                	mov    %esp,%ebp
f0100333:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100336:	e8 b2 ff ff ff       	call   f01002ed <cons_getc>
f010033b:	85 c0                	test   %eax,%eax
f010033d:	74 f7                	je     f0100336 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010033f:	c9                   	leave  
f0100340:	c3                   	ret    

f0100341 <iscons>:

int
iscons(int fdnum)
{
f0100341:	55                   	push   %ebp
f0100342:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100344:	b8 01 00 00 00       	mov    $0x1,%eax
f0100349:	5d                   	pop    %ebp
f010034a:	c3                   	ret    

f010034b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010034b:	55                   	push   %ebp
f010034c:	89 e5                	mov    %esp,%ebp
f010034e:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100351:	e8 89 fe ff ff       	call   f01001df <cga_init>
	kbd_init();
	serial_init();
f0100356:	e8 25 fe ff ff       	call   f0100180 <serial_init>

	if (!serial_exists)
f010035b:	83 3d 24 b2 15 f0 00 	cmpl   $0x0,0xf015b224
f0100362:	75 0c                	jne    f0100370 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f0100364:	c7 04 24 ad 42 10 f0 	movl   $0xf01042ad,(%esp)
f010036b:	e8 9f 25 00 00       	call   f010290f <cprintf>
}
f0100370:	c9                   	leave  
f0100371:	c3                   	ret    

f0100372 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100372:	55                   	push   %ebp
f0100373:	89 e5                	mov    %esp,%ebp
f0100375:	53                   	push   %ebx
f0100376:	83 ec 14             	sub    $0x14,%esp
f0100379:	ba 64 00 00 00       	mov    $0x64,%edx
f010037e:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010037f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100384:	a8 01                	test   $0x1,%al
f0100386:	0f 84 dd 00 00 00    	je     f0100469 <kbd_proc_data+0xf7>
f010038c:	b2 60                	mov    $0x60,%dl
f010038e:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010038f:	3c e0                	cmp    $0xe0,%al
f0100391:	75 11                	jne    f01003a4 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100393:	83 0d 20 b2 15 f0 40 	orl    $0x40,0xf015b220
f010039a:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010039f:	e9 c5 00 00 00       	jmp    f0100469 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f01003a4:	84 c0                	test   %al,%al
f01003a6:	79 35                	jns    f01003dd <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003a8:	8b 15 20 b2 15 f0    	mov    0xf015b220,%edx
f01003ae:	89 c1                	mov    %eax,%ecx
f01003b0:	83 e1 7f             	and    $0x7f,%ecx
f01003b3:	f6 c2 40             	test   $0x40,%dl
f01003b6:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01003b9:	0f b6 c0             	movzbl %al,%eax
f01003bc:	0f b6 80 e0 42 10 f0 	movzbl -0xfefbd20(%eax),%eax
f01003c3:	83 c8 40             	or     $0x40,%eax
f01003c6:	0f b6 c0             	movzbl %al,%eax
f01003c9:	f7 d0                	not    %eax
f01003cb:	21 c2                	and    %eax,%edx
f01003cd:	89 15 20 b2 15 f0    	mov    %edx,0xf015b220
f01003d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01003d8:	e9 8c 00 00 00       	jmp    f0100469 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f01003dd:	8b 15 20 b2 15 f0    	mov    0xf015b220,%edx
f01003e3:	f6 c2 40             	test   $0x40,%dl
f01003e6:	74 0c                	je     f01003f4 <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003e8:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01003eb:	83 e2 bf             	and    $0xffffffbf,%edx
f01003ee:	89 15 20 b2 15 f0    	mov    %edx,0xf015b220
	}

	shift |= shiftcode[data];
f01003f4:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01003f7:	0f b6 90 e0 42 10 f0 	movzbl -0xfefbd20(%eax),%edx
f01003fe:	0b 15 20 b2 15 f0    	or     0xf015b220,%edx
f0100404:	0f b6 88 e0 43 10 f0 	movzbl -0xfefbc20(%eax),%ecx
f010040b:	31 ca                	xor    %ecx,%edx
f010040d:	89 15 20 b2 15 f0    	mov    %edx,0xf015b220

	c = charcode[shift & (CTL | SHIFT)][data];
f0100413:	89 d1                	mov    %edx,%ecx
f0100415:	83 e1 03             	and    $0x3,%ecx
f0100418:	8b 0c 8d e0 44 10 f0 	mov    -0xfefbb20(,%ecx,4),%ecx
f010041f:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100423:	f6 c2 08             	test   $0x8,%dl
f0100426:	74 1b                	je     f0100443 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100428:	89 d9                	mov    %ebx,%ecx
f010042a:	8d 43 9f             	lea    -0x61(%ebx),%eax
f010042d:	83 f8 19             	cmp    $0x19,%eax
f0100430:	77 05                	ja     f0100437 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100432:	83 eb 20             	sub    $0x20,%ebx
f0100435:	eb 0c                	jmp    f0100443 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100437:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f010043a:	8d 43 20             	lea    0x20(%ebx),%eax
f010043d:	83 f9 19             	cmp    $0x19,%ecx
f0100440:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100443:	f7 d2                	not    %edx
f0100445:	f6 c2 06             	test   $0x6,%dl
f0100448:	75 1f                	jne    f0100469 <kbd_proc_data+0xf7>
f010044a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100450:	75 17                	jne    f0100469 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f0100452:	c7 04 24 ca 42 10 f0 	movl   $0xf01042ca,(%esp)
f0100459:	e8 b1 24 00 00       	call   f010290f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100463:	b8 03 00 00 00       	mov    $0x3,%eax
f0100468:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100469:	89 d8                	mov    %ebx,%eax
f010046b:	83 c4 14             	add    $0x14,%esp
f010046e:	5b                   	pop    %ebx
f010046f:	5d                   	pop    %ebp
f0100470:	c3                   	ret    

f0100471 <cga_putc>:



void
cga_putc(int c)
{
f0100471:	55                   	push   %ebp
f0100472:	89 e5                	mov    %esp,%ebp
f0100474:	56                   	push   %esi
f0100475:	53                   	push   %ebx
f0100476:	83 ec 10             	sub    $0x10,%esp
f0100479:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f010047c:	89 c2                	mov    %eax,%edx
f010047e:	80 ce 07             	or     $0x7,%dh
f0100481:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f0100486:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f0100489:	0f b6 d0             	movzbl %al,%edx
f010048c:	83 fa 09             	cmp    $0x9,%edx
f010048f:	0f 84 88 00 00 00    	je     f010051d <cga_putc+0xac>
f0100495:	83 fa 09             	cmp    $0x9,%edx
f0100498:	7f 10                	jg     f01004aa <cga_putc+0x39>
f010049a:	83 fa 08             	cmp    $0x8,%edx
f010049d:	0f 85 b8 00 00 00    	jne    f010055b <cga_putc+0xea>
f01004a3:	90                   	nop
f01004a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004a8:	eb 18                	jmp    f01004c2 <cga_putc+0x51>
f01004aa:	83 fa 0a             	cmp    $0xa,%edx
f01004ad:	8d 76 00             	lea    0x0(%esi),%esi
f01004b0:	74 41                	je     f01004f3 <cga_putc+0x82>
f01004b2:	83 fa 0d             	cmp    $0xd,%edx
f01004b5:	8d 76 00             	lea    0x0(%esi),%esi
f01004b8:	0f 85 9d 00 00 00    	jne    f010055b <cga_putc+0xea>
f01004be:	66 90                	xchg   %ax,%ax
f01004c0:	eb 39                	jmp    f01004fb <cga_putc+0x8a>
	case '\b':
		if (crt_pos > 0) {
f01004c2:	0f b7 15 30 b2 15 f0 	movzwl 0xf015b230,%edx
f01004c9:	66 85 d2             	test   %dx,%dx
f01004cc:	0f 84 f4 00 00 00    	je     f01005c6 <cga_putc+0x155>
			crt_pos--;
f01004d2:	83 ea 01             	sub    $0x1,%edx
f01004d5:	66 89 15 30 b2 15 f0 	mov    %dx,0xf015b230
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004dc:	0f b7 d2             	movzwl %dx,%edx
f01004df:	b0 00                	mov    $0x0,%al
f01004e1:	83 c8 20             	or     $0x20,%eax
f01004e4:	8b 0d 2c b2 15 f0    	mov    0xf015b22c,%ecx
f01004ea:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01004ee:	e9 86 00 00 00       	jmp    f0100579 <cga_putc+0x108>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004f3:	66 83 05 30 b2 15 f0 	addw   $0x50,0xf015b230
f01004fa:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004fb:	0f b7 05 30 b2 15 f0 	movzwl 0xf015b230,%eax
f0100502:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100508:	c1 e8 10             	shr    $0x10,%eax
f010050b:	66 c1 e8 06          	shr    $0x6,%ax
f010050f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100512:	c1 e0 04             	shl    $0x4,%eax
f0100515:	66 a3 30 b2 15 f0    	mov    %ax,0xf015b230
		break;
f010051b:	eb 5c                	jmp    f0100579 <cga_putc+0x108>
	case '\t':
		cons_putc(' ');
f010051d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100524:	e8 d4 00 00 00       	call   f01005fd <cons_putc>
		cons_putc(' ');
f0100529:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100530:	e8 c8 00 00 00       	call   f01005fd <cons_putc>
		cons_putc(' ');
f0100535:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010053c:	e8 bc 00 00 00       	call   f01005fd <cons_putc>
		cons_putc(' ');
f0100541:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100548:	e8 b0 00 00 00       	call   f01005fd <cons_putc>
		cons_putc(' ');
f010054d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100554:	e8 a4 00 00 00       	call   f01005fd <cons_putc>
		break;
f0100559:	eb 1e                	jmp    f0100579 <cga_putc+0x108>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010055b:	0f b7 15 30 b2 15 f0 	movzwl 0xf015b230,%edx
f0100562:	0f b7 da             	movzwl %dx,%ebx
f0100565:	8b 0d 2c b2 15 f0    	mov    0xf015b22c,%ecx
f010056b:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010056f:	83 c2 01             	add    $0x1,%edx
f0100572:	66 89 15 30 b2 15 f0 	mov    %dx,0xf015b230
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100579:	66 81 3d 30 b2 15 f0 	cmpw   $0x7cf,0xf015b230
f0100580:	cf 07 
f0100582:	76 42                	jbe    f01005c6 <cga_putc+0x155>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100584:	a1 2c b2 15 f0       	mov    0xf015b22c,%eax
f0100589:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100590:	00 
f0100591:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100597:	89 54 24 04          	mov    %edx,0x4(%esp)
f010059b:	89 04 24             	mov    %eax,(%esp)
f010059e:	e8 47 38 00 00       	call   f0103dea <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005a3:	8b 15 2c b2 15 f0    	mov    0xf015b22c,%edx
f01005a9:	b8 80 07 00 00       	mov    $0x780,%eax
f01005ae:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b4:	83 c0 01             	add    $0x1,%eax
f01005b7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005bc:	75 f0                	jne    f01005ae <cga_putc+0x13d>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005be:	66 83 2d 30 b2 15 f0 	subw   $0x50,0xf015b230
f01005c5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005c6:	8b 0d 28 b2 15 f0    	mov    0xf015b228,%ecx
f01005cc:	89 cb                	mov    %ecx,%ebx
f01005ce:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005d3:	89 ca                	mov    %ecx,%edx
f01005d5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005d6:	0f b7 35 30 b2 15 f0 	movzwl 0xf015b230,%esi
f01005dd:	83 c1 01             	add    $0x1,%ecx
f01005e0:	89 f0                	mov    %esi,%eax
f01005e2:	66 c1 e8 08          	shr    $0x8,%ax
f01005e6:	89 ca                	mov    %ecx,%edx
f01005e8:	ee                   	out    %al,(%dx)
f01005e9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005ee:	89 da                	mov    %ebx,%edx
f01005f0:	ee                   	out    %al,(%dx)
f01005f1:	89 f0                	mov    %esi,%eax
f01005f3:	89 ca                	mov    %ecx,%edx
f01005f5:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f01005f6:	83 c4 10             	add    $0x10,%esp
f01005f9:	5b                   	pop    %ebx
f01005fa:	5e                   	pop    %esi
f01005fb:	5d                   	pop    %ebp
f01005fc:	c3                   	ret    

f01005fd <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f01005fd:	55                   	push   %ebp
f01005fe:	89 e5                	mov    %esp,%ebp
f0100600:	57                   	push   %edi
f0100601:	56                   	push   %esi
f0100602:	53                   	push   %ebx
f0100603:	83 ec 1c             	sub    $0x1c,%esp
f0100606:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100609:	ba 79 03 00 00       	mov    $0x379,%edx
f010060e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010060f:	84 c0                	test   %al,%al
f0100611:	78 27                	js     f010063a <cons_putc+0x3d>
f0100613:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100618:	b9 84 00 00 00       	mov    $0x84,%ecx
f010061d:	be 79 03 00 00       	mov    $0x379,%esi
f0100622:	89 ca                	mov    %ecx,%edx
f0100624:	ec                   	in     (%dx),%al
f0100625:	ec                   	in     (%dx),%al
f0100626:	ec                   	in     (%dx),%al
f0100627:	ec                   	in     (%dx),%al
f0100628:	89 f2                	mov    %esi,%edx
f010062a:	ec                   	in     (%dx),%al
f010062b:	84 c0                	test   %al,%al
f010062d:	78 0b                	js     f010063a <cons_putc+0x3d>
f010062f:	83 c3 01             	add    $0x1,%ebx
f0100632:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100638:	75 e8                	jne    f0100622 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010063a:	ba 78 03 00 00       	mov    $0x378,%edx
f010063f:	89 f8                	mov    %edi,%eax
f0100641:	ee                   	out    %al,(%dx)
f0100642:	b2 7a                	mov    $0x7a,%dl
f0100644:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100649:	ee                   	out    %al,(%dx)
f010064a:	b8 08 00 00 00       	mov    $0x8,%eax
f010064f:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f0100650:	89 3c 24             	mov    %edi,(%esp)
f0100653:	e8 19 fe ff ff       	call   f0100471 <cga_putc>
}
f0100658:	83 c4 1c             	add    $0x1c,%esp
f010065b:	5b                   	pop    %ebx
f010065c:	5e                   	pop    %esi
f010065d:	5f                   	pop    %edi
f010065e:	5d                   	pop    %ebp
f010065f:	c3                   	ret    

f0100660 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100660:	55                   	push   %ebp
f0100661:	89 e5                	mov    %esp,%ebp
f0100663:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f0100666:	8b 45 08             	mov    0x8(%ebp),%eax
f0100669:	89 04 24             	mov    %eax,(%esp)
f010066c:	e8 8c ff ff ff       	call   f01005fd <cons_putc>
}
f0100671:	c9                   	leave  
f0100672:	c3                   	ret    
	...

f0100680 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100680:	55                   	push   %ebp
f0100681:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100683:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100686:	5d                   	pop    %ebp
f0100687:	c3                   	ret    

f0100688 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100688:	55                   	push   %ebp
f0100689:	89 e5                	mov    %esp,%ebp
f010068b:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010068e:	c7 04 24 f0 44 10 f0 	movl   $0xf01044f0,(%esp)
f0100695:	e8 75 22 00 00       	call   f010290f <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f010069a:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006a1:	00 
f01006a2:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006a9:	f0 
f01006aa:	c7 04 24 ac 45 10 f0 	movl   $0xf01045ac,(%esp)
f01006b1:	e8 59 22 00 00       	call   f010290f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b6:	c7 44 24 08 45 42 10 	movl   $0x104245,0x8(%esp)
f01006bd:	00 
f01006be:	c7 44 24 04 45 42 10 	movl   $0xf0104245,0x4(%esp)
f01006c5:	f0 
f01006c6:	c7 04 24 d0 45 10 f0 	movl   $0xf01045d0,(%esp)
f01006cd:	e8 3d 22 00 00       	call   f010290f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006d2:	c7 44 24 08 fa b1 15 	movl   $0x15b1fa,0x8(%esp)
f01006d9:	00 
f01006da:	c7 44 24 04 fa b1 15 	movl   $0xf015b1fa,0x4(%esp)
f01006e1:	f0 
f01006e2:	c7 04 24 f4 45 10 f0 	movl   $0xf01045f4,(%esp)
f01006e9:	e8 21 22 00 00       	call   f010290f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ee:	c7 44 24 08 10 c1 15 	movl   $0x15c110,0x8(%esp)
f01006f5:	00 
f01006f6:	c7 44 24 04 10 c1 15 	movl   $0xf015c110,0x4(%esp)
f01006fd:	f0 
f01006fe:	c7 04 24 18 46 10 f0 	movl   $0xf0104618,(%esp)
f0100705:	e8 05 22 00 00       	call   f010290f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010070a:	b8 0f c5 15 f0       	mov    $0xf015c50f,%eax
f010070f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100714:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010071a:	85 c0                	test   %eax,%eax
f010071c:	0f 48 c2             	cmovs  %edx,%eax
f010071f:	c1 f8 0a             	sar    $0xa,%eax
f0100722:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100726:	c7 04 24 3c 46 10 f0 	movl   $0xf010463c,(%esp)
f010072d:	e8 dd 21 00 00       	call   f010290f <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f0100732:	b8 00 00 00 00       	mov    $0x0,%eax
f0100737:	c9                   	leave  
f0100738:	c3                   	ret    

f0100739 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100739:	55                   	push   %ebp
f010073a:	89 e5                	mov    %esp,%ebp
f010073c:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010073f:	a1 44 47 10 f0       	mov    0xf0104744,%eax
f0100744:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100748:	a1 40 47 10 f0       	mov    0xf0104740,%eax
f010074d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100751:	c7 04 24 09 45 10 f0 	movl   $0xf0104509,(%esp)
f0100758:	e8 b2 21 00 00       	call   f010290f <cprintf>
f010075d:	a1 50 47 10 f0       	mov    0xf0104750,%eax
f0100762:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100766:	a1 4c 47 10 f0       	mov    0xf010474c,%eax
f010076b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010076f:	c7 04 24 09 45 10 f0 	movl   $0xf0104509,(%esp)
f0100776:	e8 94 21 00 00       	call   f010290f <cprintf>
f010077b:	a1 5c 47 10 f0       	mov    0xf010475c,%eax
f0100780:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100784:	a1 58 47 10 f0       	mov    0xf0104758,%eax
f0100789:	89 44 24 04          	mov    %eax,0x4(%esp)
f010078d:	c7 04 24 09 45 10 f0 	movl   $0xf0104509,(%esp)
f0100794:	e8 76 21 00 00       	call   f010290f <cprintf>
	return 0;
}
f0100799:	b8 00 00 00 00       	mov    $0x0,%eax
f010079e:	c9                   	leave  
f010079f:	c3                   	ret    

f01007a0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007a0:	55                   	push   %ebp
f01007a1:	89 e5                	mov    %esp,%ebp
f01007a3:	57                   	push   %edi
f01007a4:	56                   	push   %esi
f01007a5:	53                   	push   %ebx
f01007a6:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007a9:	c7 04 24 68 46 10 f0 	movl   $0xf0104668,(%esp)
f01007b0:	e8 5a 21 00 00       	call   f010290f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007b5:	c7 04 24 8c 46 10 f0 	movl   $0xf010468c,(%esp)
f01007bc:	e8 4e 21 00 00       	call   f010290f <cprintf>

	if (tf != NULL)
f01007c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007c5:	74 0b                	je     f01007d2 <monitor+0x32>
		print_trapframe(tf);
f01007c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ca:	89 04 24             	mov    %eax,(%esp)
f01007cd:	e8 a2 25 00 00       	call   f0102d74 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01007d2:	c7 04 24 12 45 10 f0 	movl   $0xf0104512,(%esp)
f01007d9:	e8 72 33 00 00       	call   f0103b50 <readline>
f01007de:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007e0:	85 c0                	test   %eax,%eax
f01007e2:	74 ee                	je     f01007d2 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007e4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f01007eb:	be 00 00 00 00       	mov    $0x0,%esi
f01007f0:	eb 06                	jmp    f01007f8 <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007f2:	c6 03 00             	movb   $0x0,(%ebx)
f01007f5:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007f8:	0f b6 03             	movzbl (%ebx),%eax
f01007fb:	84 c0                	test   %al,%al
f01007fd:	74 6c                	je     f010086b <monitor+0xcb>
f01007ff:	0f be c0             	movsbl %al,%eax
f0100802:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100806:	c7 04 24 16 45 10 f0 	movl   $0xf0104516,(%esp)
f010080d:	e8 5c 35 00 00       	call   f0103d6e <strchr>
f0100812:	85 c0                	test   %eax,%eax
f0100814:	75 dc                	jne    f01007f2 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100816:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100819:	74 50                	je     f010086b <monitor+0xcb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010081b:	83 fe 0f             	cmp    $0xf,%esi
f010081e:	66 90                	xchg   %ax,%ax
f0100820:	75 16                	jne    f0100838 <monitor+0x98>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100822:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100829:	00 
f010082a:	c7 04 24 1b 45 10 f0 	movl   $0xf010451b,(%esp)
f0100831:	e8 d9 20 00 00       	call   f010290f <cprintf>
f0100836:	eb 9a                	jmp    f01007d2 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100838:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010083c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010083f:	0f b6 03             	movzbl (%ebx),%eax
f0100842:	84 c0                	test   %al,%al
f0100844:	75 0c                	jne    f0100852 <monitor+0xb2>
f0100846:	eb b0                	jmp    f01007f8 <monitor+0x58>
			buf++;
f0100848:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010084b:	0f b6 03             	movzbl (%ebx),%eax
f010084e:	84 c0                	test   %al,%al
f0100850:	74 a6                	je     f01007f8 <monitor+0x58>
f0100852:	0f be c0             	movsbl %al,%eax
f0100855:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100859:	c7 04 24 16 45 10 f0 	movl   $0xf0104516,(%esp)
f0100860:	e8 09 35 00 00       	call   f0103d6e <strchr>
f0100865:	85 c0                	test   %eax,%eax
f0100867:	74 df                	je     f0100848 <monitor+0xa8>
f0100869:	eb 8d                	jmp    f01007f8 <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f010086b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100872:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100873:	85 f6                	test   %esi,%esi
f0100875:	0f 84 57 ff ff ff    	je     f01007d2 <monitor+0x32>
f010087b:	bb 40 47 10 f0       	mov    $0xf0104740,%ebx
f0100880:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100885:	8b 03                	mov    (%ebx),%eax
f0100887:	89 44 24 04          	mov    %eax,0x4(%esp)
f010088b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010088e:	89 04 24             	mov    %eax,(%esp)
f0100891:	e8 63 34 00 00       	call   f0103cf9 <strcmp>
f0100896:	85 c0                	test   %eax,%eax
f0100898:	75 23                	jne    f01008bd <monitor+0x11d>
			return commands[i].func(argc, argv, tf);
f010089a:	6b ff 0c             	imul   $0xc,%edi,%edi
f010089d:	8b 45 08             	mov    0x8(%ebp),%eax
f01008a0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008a4:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ab:	89 34 24             	mov    %esi,(%esp)
f01008ae:	ff 97 48 47 10 f0    	call   *-0xfefb8b8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008b4:	85 c0                	test   %eax,%eax
f01008b6:	78 28                	js     f01008e0 <monitor+0x140>
f01008b8:	e9 15 ff ff ff       	jmp    f01007d2 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008bd:	83 c7 01             	add    $0x1,%edi
f01008c0:	83 c3 0c             	add    $0xc,%ebx
f01008c3:	83 ff 03             	cmp    $0x3,%edi
f01008c6:	75 bd                	jne    f0100885 <monitor+0xe5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008c8:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008cf:	c7 04 24 38 45 10 f0 	movl   $0xf0104538,(%esp)
f01008d6:	e8 34 20 00 00       	call   f010290f <cprintf>
f01008db:	e9 f2 fe ff ff       	jmp    f01007d2 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008e0:	83 c4 5c             	add    $0x5c,%esp
f01008e3:	5b                   	pop    %ebx
f01008e4:	5e                   	pop    %esi
f01008e5:	5f                   	pop    %edi
f01008e6:	5d                   	pop    %ebp
f01008e7:	c3                   	ret    

f01008e8 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008e8:	55                   	push   %ebp
f01008e9:	89 e5                	mov    %esp,%ebp
f01008eb:	57                   	push   %edi
f01008ec:	56                   	push   %esi
f01008ed:	53                   	push   %ebx
f01008ee:	81 ec bc 00 00 00    	sub    $0xbc,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008f4:	89 ee                	mov    %ebp,%esi
	unsigned int i;
	uint32_t k;
	struct Eipdebuginfo info;
	char buffer[80];
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f01008f6:	c7 04 24 4e 45 10 f0 	movl   $0xf010454e,(%esp)
f01008fd:	e8 0d 20 00 00       	call   f010290f <cprintf>
	while(ebp != 0){
f0100902:	85 f6                	test   %esi,%esi
f0100904:	0f 84 f3 00 00 00    	je     f01009fd <mon_backtrace+0x115>
	         args[i] = *((unsigned int*) (ebp + 8 + 4*i));
	         cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
	         ebp, eip, args[0], args[1], args[2], args[3], args[4]);
		 debuginfo_eip(eip, &info); //闇�瑕佸仛鐨勫伐浣滃湪杩欎釜琚皟鍑芥暟鍐呴儴
		 for(i=0; i<info.eip_fn_namelen && i<79; i++)
		            buffer[i] = info.eip_fn_name[i];
f010090a:	8d 9d 6c ff ff ff    	lea    -0x94(%ebp),%ebx
f0100910:	89 9d 60 ff ff ff    	mov    %ebx,-0xa0(%ebp)
	struct Eipdebuginfo info;
	char buffer[80];
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while(ebp != 0){
		eip = *((unsigned int*)(ebp + 4));
f0100916:	8b 46 04             	mov    0x4(%esi),%eax
f0100919:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
f010091f:	b8 00 00 00 00       	mov    $0x0,%eax
	         for(i=0; i<5; i++)
	         args[i] = *((unsigned int*) (ebp + 8 + 4*i));
f0100924:	8b 54 86 08          	mov    0x8(%esi,%eax,4),%edx
f0100928:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
	char buffer[80];
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while(ebp != 0){
		eip = *((unsigned int*)(ebp + 4));
	         for(i=0; i<5; i++)
f010092c:	83 c0 01             	add    $0x1,%eax
f010092f:	83 f8 05             	cmp    $0x5,%eax
f0100932:	75 f0                	jne    f0100924 <mon_backtrace+0x3c>
	         args[i] = *((unsigned int*) (ebp + 8 + 4*i));
	         cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f0100934:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100937:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010093b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010093e:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100942:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100945:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100949:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010094c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100950:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100953:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100957:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
f010095d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100961:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100965:	c7 04 24 b4 46 10 f0 	movl   $0xf01046b4,(%esp)
f010096c:	e8 9e 1f 00 00       	call   f010290f <cprintf>
	         ebp, eip, args[0], args[1], args[2], args[3], args[4]);
		 debuginfo_eip(eip, &info); //闇�瑕佸仛鐨勫伐浣滃湪杩欎釜琚皟鍑芥暟鍐呴儴
f0100971:	8d 45 bc             	lea    -0x44(%ebp),%eax
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
f010097e:	89 14 24             	mov    %edx,(%esp)
f0100981:	e8 58 29 00 00       	call   f01032de <debuginfo_eip>
		 for(i=0; i<info.eip_fn_namelen && i<79; i++)
f0100986:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100989:	85 c9                	test   %ecx,%ecx
f010098b:	75 07                	jne    f0100994 <mon_backtrace+0xac>
f010098d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100992:	eb 1b                	jmp    f01009af <mon_backtrace+0xc7>
		            buffer[i] = info.eip_fn_name[i];
f0100994:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100997:	b8 00 00 00 00       	mov    $0x0,%eax
f010099c:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f01009a0:	88 14 03             	mov    %dl,(%ebx,%eax,1)
	         for(i=0; i<5; i++)
	         args[i] = *((unsigned int*) (ebp + 8 + 4*i));
	         cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
	         ebp, eip, args[0], args[1], args[2], args[3], args[4]);
		 debuginfo_eip(eip, &info); //闇�瑕佸仛鐨勫伐浣滃湪杩欎釜琚皟鍑芥暟鍐呴儴
		 for(i=0; i<info.eip_fn_namelen && i<79; i++)
f01009a3:	83 c0 01             	add    $0x1,%eax
f01009a6:	39 c8                	cmp    %ecx,%eax
f01009a8:	73 05                	jae    f01009af <mon_backtrace+0xc7>
f01009aa:	83 f8 4e             	cmp    $0x4e,%eax
f01009ad:	76 ed                	jbe    f010099c <mon_backtrace+0xb4>
		            buffer[i] = info.eip_fn_name[i];
	         buffer[i] = '\0';
f01009af:	c6 84 05 6c ff ff ff 	movb   $0x0,-0x94(%ebp,%eax,1)
f01009b6:	00 
		k=(uint32_t)eip-(uint32_t)info.eip_fn_addr;
f01009b7:	8b 45 cc             	mov    -0x34(%ebp),%eax
		if(buffer[0]!='<')
f01009ba:	80 bd 6c ff ff ff 3c 	cmpb   $0x3c,-0x94(%ebp)
f01009c1:	74 30                	je     f01009f3 <mon_backtrace+0x10b>
       	         	cprintf("%s :%d: %s+%x\n", info.eip_file,info.eip_line,buffer,k);
f01009c3:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
f01009c9:	29 c2                	sub    %eax,%edx
f01009cb:	89 54 24 10          	mov    %edx,0x10(%esp)
f01009cf:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
f01009d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009d9:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01009dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009e0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01009e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009e7:	c7 04 24 60 45 10 f0 	movl   $0xf0104560,(%esp)
f01009ee:	e8 1c 1f 00 00       	call   f010290f <cprintf>
	         ebp = *((unsigned int *)ebp);
f01009f3:	8b 36                	mov    (%esi),%esi
	uint32_t k;
	struct Eipdebuginfo info;
	char buffer[80];
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while(ebp != 0){
f01009f5:	85 f6                	test   %esi,%esi
f01009f7:	0f 85 19 ff ff ff    	jne    f0100916 <mon_backtrace+0x2e>
		if(buffer[0]!='<')
       	         	cprintf("%s :%d: %s+%x\n", info.eip_file,info.eip_line,buffer,k);
	         ebp = *((unsigned int *)ebp);
	   }
	return 0;
}
f01009fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a02:	81 c4 bc 00 00 00    	add    $0xbc,%esp
f0100a08:	5b                   	pop    %ebx
f0100a09:	5e                   	pop    %esi
f0100a0a:	5f                   	pop    %edi
f0100a0b:	5d                   	pop    %ebp
f0100a0c:	c3                   	ret    
f0100a0d:	00 00                	add    %al,(%eax)
	...

f0100a10 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0100a10:	55                   	push   %ebp
f0100a11:	89 e5                	mov    %esp,%ebp
f0100a13:	83 ec 0c             	sub    $0xc,%esp
f0100a16:	89 1c 24             	mov    %ebx,(%esp)
f0100a19:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a1d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a21:	89 c3                	mov    %eax,%ebx
f0100a23:	89 d7                	mov    %edx,%edi
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
		boot_freemem = end;
f0100a25:	83 3d 54 b4 15 f0 00 	cmpl   $0x0,0xf015b454
	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	//	Step 2: save current value of boot_freemem as allocated chunk
	//	Step 3: increase boot_freemem to record allocation
	//	Step 4: return allocated chunk
        boot_freemem = ROUNDUP(boot_freemem,align);
f0100a2c:	b8 10 c1 15 f0       	mov    $0xf015c110,%eax
f0100a31:	0f 45 05 54 b4 15 f0 	cmovne 0xf015b454,%eax
f0100a38:	8d 4c 02 ff          	lea    -0x1(%edx,%eax,1),%ecx
f0100a3c:	89 c8                	mov    %ecx,%eax
f0100a3e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a43:	f7 f7                	div    %edi
f0100a45:	89 c8                	mov    %ecx,%eax
f0100a47:	29 d0                	sub    %edx,%eax
        v=boot_freemem;
		boot_freemem+=n;
f0100a49:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
f0100a4c:	89 1d 54 b4 15 f0    	mov    %ebx,0xf015b454
		return v;
}
f0100a52:	8b 1c 24             	mov    (%esp),%ebx
f0100a55:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100a59:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0100a5d:	89 ec                	mov    %ebp,%esp
f0100a5f:	5d                   	pop    %ebp
f0100a60:	c3                   	ret    

f0100a61 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100a61:	55                   	push   %ebp
f0100a62:	89 e5                	mov    %esp,%ebp
f0100a64:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	LIST_INSERT_HEAD (&page_free_list, pp, pp_link);
f0100a67:	8b 15 58 b4 15 f0    	mov    0xf015b458,%edx
f0100a6d:	89 10                	mov    %edx,(%eax)
f0100a6f:	85 d2                	test   %edx,%edx
f0100a71:	74 09                	je     f0100a7c <page_free+0x1b>
f0100a73:	8b 15 58 b4 15 f0    	mov    0xf015b458,%edx
f0100a79:	89 42 04             	mov    %eax,0x4(%edx)
f0100a7c:	a3 58 b4 15 f0       	mov    %eax,0xf015b458
f0100a81:	c7 40 04 58 b4 15 f0 	movl   $0xf015b458,0x4(%eax)
}
f0100a88:	5d                   	pop    %ebp
f0100a89:	c3                   	ret    

f0100a8a <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100a8a:	55                   	push   %ebp
f0100a8b:	89 e5                	mov    %esp,%ebp
f0100a8d:	83 ec 04             	sub    $0x4,%esp
f0100a90:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100a93:	0f b7 50 08          	movzwl 0x8(%eax),%edx
f0100a97:	83 ea 01             	sub    $0x1,%edx
f0100a9a:	66 89 50 08          	mov    %dx,0x8(%eax)
f0100a9e:	66 85 d2             	test   %dx,%dx
f0100aa1:	75 08                	jne    f0100aab <page_decref+0x21>
		page_free(pp);
f0100aa3:	89 04 24             	mov    %eax,(%esp)
f0100aa6:	e8 b6 ff ff ff       	call   f0100a61 <page_free>
}
f0100aab:	c9                   	leave  
f0100aac:	c3                   	ret    

f0100aad <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100aad:	55                   	push   %ebp
f0100aae:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ab3:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100ab6:	5d                   	pop    %ebp
f0100ab7:	c3                   	ret    

f0100ab8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ab8:	55                   	push   %ebp
f0100ab9:	89 e5                	mov    %esp,%ebp
f0100abb:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100abe:	89 d1                	mov    %edx,%ecx
f0100ac0:	c1 e9 16             	shr    $0x16,%ecx
f0100ac3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ac6:	a8 01                	test   $0x1,%al
f0100ac8:	74 4d                	je     f0100b17 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100acf:	89 c1                	mov    %eax,%ecx
f0100ad1:	c1 e9 0c             	shr    $0xc,%ecx
f0100ad4:	3b 0d 00 c1 15 f0    	cmp    0xf015c100,%ecx
f0100ada:	72 20                	jb     f0100afc <check_va2pa+0x44>
f0100adc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ae0:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f0100ae7:	f0 
f0100ae8:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f0100aef:	00 
f0100af0:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0100af7:	e8 84 f5 ff ff       	call   f0100080 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100afc:	c1 ea 0c             	shr    $0xc,%edx
f0100aff:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b05:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b0c:	a8 01                	test   $0x1,%al
f0100b0e:	74 07                	je     f0100b17 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b15:	eb 05                	jmp    f0100b1c <check_va2pa+0x64>
f0100b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b1c:	c9                   	leave  
f0100b1d:	c3                   	ret    

f0100b1e <page2kva>:
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f0100b1e:	55                   	push   %ebp
f0100b1f:	89 e5                	mov    %esp,%ebp
f0100b21:	83 ec 18             	sub    $0x18,%esp
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100b24:	2b 05 0c c1 15 f0    	sub    0xf015c10c,%eax
f0100b2a:	c1 f8 02             	sar    $0x2,%eax
f0100b2d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b33:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0100b36:	89 c2                	mov    %eax,%edx
f0100b38:	c1 ea 0c             	shr    $0xc,%edx
f0100b3b:	3b 15 00 c1 15 f0    	cmp    0xf015c100,%edx
f0100b41:	72 20                	jb     f0100b63 <page2kva+0x45>
f0100b43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b47:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f0100b4e:	f0 
f0100b4f:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
f0100b56:	00 
f0100b57:	c7 04 24 f5 4b 10 f0 	movl   $0xf0104bf5,(%esp)
f0100b5e:	e8 1d f5 ff ff       	call   f0100080 <_panic>
f0100b63:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0100b68:	c9                   	leave  
f0100b69:	c3                   	ret    

f0100b6a <boot_map_segment>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
//
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0100b6a:	55                   	push   %ebp
f0100b6b:	89 e5                	mov    %esp,%ebp
f0100b6d:	57                   	push   %edi
f0100b6e:	56                   	push   %esi
f0100b6f:	53                   	push   %ebx
f0100b70:	83 ec 2c             	sub    $0x2c,%esp
f0100b73:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b76:	89 d3                	mov    %edx,%ebx
	int i;

	for ( i = 0; i < size/PGSIZE; i ++ ) {
f0100b78:	c1 e9 0c             	shr    $0xc,%ecx
f0100b7b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100b7e:	85 c9                	test   %ecx,%ecx
f0100b80:	0f 84 e5 00 00 00    	je     f0100c6b <boot_map_segment+0x101>
		pte_t *pte=boot_pgdir_walk(pgdir,la+i*PGSIZE,1);
		pgdir[PDX(la)]=(pgdir[PDX(la)] & 0xFFFFF000) | perm | PTE_P;
f0100b86:	89 d0                	mov    %edx,%eax
f0100b88:	c1 e8 16             	shr    $0x16,%eax
f0100b8b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b8e:	8d 34 82             	lea    (%edx,%eax,4),%esi
f0100b91:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b96:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b99:	83 c8 01             	or     $0x1,%eax
f0100b9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// on failure.)
//
static pte_t*
boot_pgdir_walk(pde_t *pgdir, uintptr_t la, int create)
{
	pte_t *pte=(pte_t*)pgdir[PDX(la)];
f0100b9f:	89 d8                	mov    %ebx,%eax
f0100ba1:	c1 e8 16             	shr    $0x16,%eax
f0100ba4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100ba7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0100baa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100bad:	8b 00                	mov    (%eax),%eax

	if (pte == 0 ) {
f0100baf:	85 c0                	test   %eax,%eax
f0100bb1:	75 47                	jne    f0100bfa <boot_map_segment+0x90>
		if (create == 0 ) return 0;
		pte=(pte_t*)boot_alloc(PGSIZE,PGSIZE);
f0100bb3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0100bb8:	66 b8 00 10          	mov    $0x1000,%ax
f0100bbc:	e8 4f fe ff ff       	call   f0100a10 <boot_alloc>

		pgdir[PDX(la)]=PADDR(pte) | PTE_P | PTE_W;
f0100bc1:	89 c2                	mov    %eax,%edx
f0100bc3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100bc8:	77 20                	ja     f0100bea <boot_map_segment+0x80>
f0100bca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bce:	c7 44 24 08 88 47 10 	movl   $0xf0104788,0x8(%esp)
f0100bd5:	f0 
f0100bd6:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
f0100bdd:	00 
f0100bde:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0100be5:	e8 96 f4 ff ff       	call   f0100080 <_panic>
f0100bea:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100bf0:	83 ca 03             	or     $0x3,%edx
f0100bf3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100bf6:	89 11                	mov    %edx,(%ecx)
f0100bf8:	eb 37                	jmp    f0100c31 <boot_map_segment+0xc7>
	}
	else 
		pte=(pte_t *)KADDR(PTE_ADDR(pte));
f0100bfa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bff:	89 c2                	mov    %eax,%edx
f0100c01:	c1 ea 0c             	shr    $0xc,%edx
f0100c04:	3b 15 00 c1 15 f0    	cmp    0xf015c100,%edx
f0100c0a:	72 20                	jb     f0100c2c <boot_map_segment+0xc2>
f0100c0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c10:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f0100c17:	f0 
f0100c18:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f0100c1f:	00 
f0100c20:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0100c27:	e8 54 f4 ff ff       	call   f0100080 <_panic>
f0100c2c:	2d 00 00 00 10       	sub    $0x10000000,%eax
{
	int i;

	for ( i = 0; i < size/PGSIZE; i ++ ) {
		pte_t *pte=boot_pgdir_walk(pgdir,la+i*PGSIZE,1);
		pgdir[PDX(la)]=(pgdir[PDX(la)] & 0xFFFFF000) | perm | PTE_P;
f0100c31:	8b 16                	mov    (%esi),%edx
f0100c33:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c39:	0b 55 e4             	or     -0x1c(%ebp),%edx
f0100c3c:	89 16                	mov    %edx,(%esi)
		pte[PTX(la+i*PGSIZE)]=(pa+i*PGSIZE) | perm | PTE_P;
f0100c3e:	89 da                	mov    %ebx,%edx
f0100c40:	c1 ea 0c             	shr    $0xc,%edx
f0100c43:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c49:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100c4c:	0b 4d 08             	or     0x8(%ebp),%ecx
f0100c4f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
	int i;

	for ( i = 0; i < size/PGSIZE; i ++ ) {
f0100c52:	83 c7 01             	add    $0x1,%edi
f0100c55:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100c5b:	81 45 08 00 10 00 00 	addl   $0x1000,0x8(%ebp)
f0100c62:	3b 7d dc             	cmp    -0x24(%ebp),%edi
f0100c65:	0f 82 34 ff ff ff    	jb     f0100b9f <boot_map_segment+0x35>
		pte_t *pte=boot_pgdir_walk(pgdir,la+i*PGSIZE,1);
		pgdir[PDX(la)]=(pgdir[PDX(la)] & 0xFFFFF000) | perm | PTE_P;
		pte[PTX(la+i*PGSIZE)]=(pa+i*PGSIZE) | perm | PTE_P;
	}
}
f0100c6b:	83 c4 2c             	add    $0x2c,%esp
f0100c6e:	5b                   	pop    %ebx
f0100c6f:	5e                   	pop    %esi
f0100c70:	5f                   	pop    %edi
f0100c71:	5d                   	pop    %ebp
f0100c72:	c3                   	ret    

f0100c73 <page_alloc>:
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented 
int
page_alloc(struct Page **pp_store)
{
f0100c73:	55                   	push   %ebp
f0100c74:	89 e5                	mov    %esp,%ebp
f0100c76:	53                   	push   %ebx
f0100c77:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct Page *p=LIST_FIRST (&page_free_list);
f0100c7a:	8b 1d 58 b4 15 f0    	mov    0xf015b458,%ebx
	if(p!=NULL){
f0100c80:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100c85:	85 db                	test   %ebx,%ebx
f0100c87:	74 35                	je     f0100cbe <page_alloc+0x4b>
		LIST_REMOVE(p,pp_link);
f0100c89:	8b 03                	mov    (%ebx),%eax
f0100c8b:	85 c0                	test   %eax,%eax
f0100c8d:	74 06                	je     f0100c95 <page_alloc+0x22>
f0100c8f:	8b 53 04             	mov    0x4(%ebx),%edx
f0100c92:	89 50 04             	mov    %edx,0x4(%eax)
f0100c95:	8b 43 04             	mov    0x4(%ebx),%eax
f0100c98:	8b 13                	mov    (%ebx),%edx
f0100c9a:	89 10                	mov    %edx,(%eax)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f0100c9c:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0100ca3:	00 
f0100ca4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100cab:	00 
f0100cac:	89 1c 24             	mov    %ebx,(%esp)
f0100caf:	e8 12 31 00 00       	call   f0103dc6 <memset>
	// Fill this function in
	struct Page *p=LIST_FIRST (&page_free_list);
	if(p!=NULL){
		LIST_REMOVE(p,pp_link);
		page_initpp(p);
		*pp_store = p;
f0100cb4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cb7:	89 18                	mov    %ebx,(%eax)
f0100cb9:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	return -E_NO_MEM;
}
f0100cbe:	83 c4 14             	add    $0x14,%esp
f0100cc1:	5b                   	pop    %ebx
f0100cc2:	5d                   	pop    %ebp
f0100cc3:	c3                   	ret    

f0100cc4 <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100cc4:	55                   	push   %ebp
f0100cc5:	89 e5                	mov    %esp,%ebp
f0100cc7:	83 ec 28             	sub    $0x28,%esp
f0100cca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100ccd:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
	pde_t *pt = pgdir + PDX(va);
f0100cd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100cd3:	89 de                	mov    %ebx,%esi
f0100cd5:	c1 ee 16             	shr    $0x16,%esi
f0100cd8:	c1 e6 02             	shl    $0x2,%esi
f0100cdb:	03 75 08             	add    0x8(%ebp),%esi
	void *pt_kva;

	if (*pt & PTE_P) 
f0100cde:	8b 06                	mov    (%esi),%eax
f0100ce0:	a8 01                	test   $0x1,%al
f0100ce2:	74 47                	je     f0100d2b <pgdir_walk+0x67>
	{
		 pt_kva = (void*) KADDR (PTE_ADDR (*pt));
f0100ce4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ce9:	89 c2                	mov    %eax,%edx
f0100ceb:	c1 ea 0c             	shr    $0xc,%edx
f0100cee:	3b 15 00 c1 15 f0    	cmp    0xf015c100,%edx
f0100cf4:	72 20                	jb     f0100d16 <pgdir_walk+0x52>
f0100cf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cfa:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f0100d01:	f0 
f0100d02:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
f0100d09:	00 
f0100d0a:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0100d11:	e8 6a f3 ff ff       	call   f0100080 <_panic>
		 return (pte_t*) pt_kva + PTX (va);
f0100d16:	c1 eb 0a             	shr    $0xa,%ebx
f0100d19:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100d1f:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100d26:	e9 ca 00 00 00       	jmp    f0100df5 <pgdir_walk+0x131>
	}
        struct Page *newpt;

	if (create == 1 && page_alloc (&newpt) == 0) {
f0100d2b:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0100d2f:	0f 85 bb 00 00 00    	jne    f0100df0 <pgdir_walk+0x12c>
f0100d35:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100d38:	89 04 24             	mov    %eax,(%esp)
f0100d3b:	e8 33 ff ff ff       	call   f0100c73 <page_alloc>
f0100d40:	85 c0                	test   %eax,%eax
f0100d42:	0f 85 a8 00 00 00    	jne    f0100df0 <pgdir_walk+0x12c>

	         memset (page2kva (newpt), 0, PGSIZE);
f0100d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d4b:	e8 ce fd ff ff       	call   f0100b1e <page2kva>
f0100d50:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100d57:	00 
f0100d58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d5f:	00 
f0100d60:	89 04 24             	mov    %eax,(%esp)
f0100d63:	e8 5e 30 00 00       	call   f0103dc6 <memset>
	         newpt -> pp_ref = 1;
f0100d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d6b:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
		 *pt = PADDR (page2kva (newpt))|PTE_U|PTE_W|PTE_P;
f0100d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d74:	e8 a5 fd ff ff       	call   f0100b1e <page2kva>
f0100d79:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d7e:	77 20                	ja     f0100da0 <pgdir_walk+0xdc>
f0100d80:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d84:	c7 44 24 08 88 47 10 	movl   $0xf0104788,0x8(%esp)
f0100d8b:	f0 
f0100d8c:	c7 44 24 04 66 02 00 	movl   $0x266,0x4(%esp)
f0100d93:	00 
f0100d94:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0100d9b:	e8 e0 f2 ff ff       	call   f0100080 <_panic>
f0100da0:	05 00 00 00 10       	add    $0x10000000,%eax
f0100da5:	83 c8 07             	or     $0x7,%eax
f0100da8:	89 06                	mov    %eax,(%esi)
		 pt_kva = (void*) KADDR (PTE_ADDR (*pt));	
f0100daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100daf:	89 c2                	mov    %eax,%edx
f0100db1:	c1 ea 0c             	shr    $0xc,%edx
f0100db4:	3b 15 00 c1 15 f0    	cmp    0xf015c100,%edx
f0100dba:	72 20                	jb     f0100ddc <pgdir_walk+0x118>
f0100dbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dc0:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f0100dc7:	f0 
f0100dc8:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
f0100dcf:	00 
f0100dd0:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0100dd7:	e8 a4 f2 ff ff       	call   f0100080 <_panic>
		 return (pte_t*) pt_kva + PTX (va);	
f0100ddc:	89 da                	mov    %ebx,%edx
f0100dde:	c1 ea 0a             	shr    $0xa,%edx
f0100de1:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100de7:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0100dee:	eb 05                	jmp    f0100df5 <pgdir_walk+0x131>
f0100df0:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return NULL;
}
f0100df5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100df8:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100dfb:	89 ec                	mov    %ebp,%esp
f0100dfd:	5d                   	pop    %ebp
f0100dfe:	c3                   	ret    

f0100dff <user_mem_check>:
//
// Hint: The TA solution uses pgdir_walk.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0100dff:	55                   	push   %ebp
f0100e00:	89 e5                	mov    %esp,%ebp
f0100e02:	57                   	push   %edi
f0100e03:	56                   	push   %esi
f0100e04:	53                   	push   %ebx
f0100e05:	83 ec 2c             	sub    $0x2c,%esp
f0100e08:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t lva = (uintptr_t) va;
f0100e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
	uintptr_t rva = (uintptr_t) va + len - 1;
f0100e0e:	89 c2                	mov    %eax,%edx
f0100e10:	03 55 10             	add    0x10(%ebp),%edx
f0100e13:	83 ea 01             	sub    $0x1,%edx
f0100e16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	perm = perm|PTE_U|PTE_P;
f0100e19:	8b 7d 14             	mov    0x14(%ebp),%edi
f0100e1c:	83 cf 05             	or     $0x5,%edi
	pte_t *pte;
	uintptr_t idx_va;

	 for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
f0100e1f:	39 d0                	cmp    %edx,%eax
f0100e21:	77 61                	ja     f0100e84 <user_mem_check+0x85>
		 	 if (idx_va >= ULIM) {
				 user_mem_check_addr = idx_va;
				 return -E_FAULT;
f0100e23:	89 c3                	mov    %eax,%ebx
	perm = perm|PTE_U|PTE_P;
	pte_t *pte;
	uintptr_t idx_va;

	 for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
		 	 if (idx_va >= ULIM) {
f0100e25:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0100e2a:	76 17                	jbe    f0100e43 <user_mem_check+0x44>
f0100e2c:	eb 08                	jmp    f0100e36 <user_mem_check+0x37>
f0100e2e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100e34:	76 0d                	jbe    f0100e43 <user_mem_check+0x44>
				 user_mem_check_addr = idx_va;
f0100e36:	89 1d 5c b4 15 f0    	mov    %ebx,0xf015b45c
f0100e3c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
				 return -E_FAULT;
f0100e41:	eb 46                	jmp    f0100e89 <user_mem_check+0x8a>
			 }
			 pte = pgdir_walk (env->env_pgdir, (void*)idx_va, 0);
f0100e43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100e4a:	00 
f0100e4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e4f:	8b 46 5c             	mov    0x5c(%esi),%eax
f0100e52:	89 04 24             	mov    %eax,(%esp)
f0100e55:	e8 6a fe ff ff       	call   f0100cc4 <pgdir_walk>
			if (pte == NULL || (*pte & perm) != perm) {
f0100e5a:	85 c0                	test   %eax,%eax
f0100e5c:	74 08                	je     f0100e66 <user_mem_check+0x67>
f0100e5e:	8b 00                	mov    (%eax),%eax
f0100e60:	21 f8                	and    %edi,%eax
f0100e62:	39 c7                	cmp    %eax,%edi
f0100e64:	74 0d                	je     f0100e73 <user_mem_check+0x74>
				user_mem_check_addr = idx_va;
f0100e66:	89 1d 5c b4 15 f0    	mov    %ebx,0xf015b45c
f0100e6c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
				return -E_FAULT;
f0100e71:	eb 16                	jmp    f0100e89 <user_mem_check+0x8a>
			}
			idx_va = ROUNDDOWN (idx_va, PGSIZE);
f0100e73:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t rva = (uintptr_t) va + len - 1;
	perm = perm|PTE_U|PTE_P;
	pte_t *pte;
	uintptr_t idx_va;

	 for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
f0100e79:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100e7f:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0100e82:	73 aa                	jae    f0100e2e <user_mem_check+0x2f>
f0100e84:	b8 00 00 00 00       	mov    $0x0,%eax
				return -E_FAULT;
			}
			idx_va = ROUNDDOWN (idx_va, PGSIZE);
	 }
	 	return 0;
}
f0100e89:	83 c4 2c             	add    $0x2c,%esp
f0100e8c:	5b                   	pop    %ebx
f0100e8d:	5e                   	pop    %esi
f0100e8e:	5f                   	pop    %edi
f0100e8f:	5d                   	pop    %ebp
f0100e90:	c3                   	ret    

f0100e91 <user_mem_assert>:
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0100e91:	55                   	push   %ebp
f0100e92:	89 e5                	mov    %esp,%ebp
f0100e94:	53                   	push   %ebx
f0100e95:	83 ec 14             	sub    $0x14,%esp
f0100e98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0100e9b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e9e:	83 c8 04             	or     $0x4,%eax
f0100ea1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ea5:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ea8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100eac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100eb3:	89 1c 24             	mov    %ebx,(%esp)
f0100eb6:	e8 44 ff ff ff       	call   f0100dff <user_mem_check>
f0100ebb:	85 c0                	test   %eax,%eax
f0100ebd:	79 29                	jns    f0100ee8 <user_mem_assert+0x57>
		cprintf("[%08x] user_mem_check assertion failure for "
f0100ebf:	a1 5c b4 15 f0       	mov    0xf015b45c,%eax
f0100ec4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ec8:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0100ecd:	8b 40 4c             	mov    0x4c(%eax),%eax
f0100ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ed4:	c7 04 24 ac 47 10 f0 	movl   $0xf01047ac,(%esp)
f0100edb:	e8 2f 1a 00 00       	call   f010290f <cprintf>
			"va %08x\n", curenv->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0100ee0:	89 1c 24             	mov    %ebx,(%esp)
f0100ee3:	e8 f3 14 00 00       	call   f01023db <env_destroy>
	}
}
f0100ee8:	83 c4 14             	add    $0x14,%esp
f0100eeb:	5b                   	pop    %ebx
f0100eec:	5d                   	pop    %ebp
f0100eed:	c3                   	ret    

f0100eee <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100eee:	55                   	push   %ebp
f0100eef:	89 e5                	mov    %esp,%ebp
f0100ef1:	53                   	push   %ebx
f0100ef2:	83 ec 14             	sub    $0x14,%esp
f0100ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk (pgdir, va, 0);
f0100ef8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100eff:	00 
f0100f00:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f07:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f0a:	89 04 24             	mov    %eax,(%esp)
f0100f0d:	e8 b2 fd ff ff       	call   f0100cc4 <pgdir_walk>

	if (pte_store != 0) {
f0100f12:	85 db                	test   %ebx,%ebx
f0100f14:	74 02                	je     f0100f18 <page_lookup+0x2a>
		 *pte_store = pte;
f0100f16:	89 03                	mov    %eax,(%ebx)
	}
	if (pte != NULL && (*pte & PTE_P)) {
f0100f18:	85 c0                	test   %eax,%eax
f0100f1a:	74 3b                	je     f0100f57 <page_lookup+0x69>
f0100f1c:	8b 00                	mov    (%eax),%eax
f0100f1e:	a8 01                	test   $0x1,%al
f0100f20:	74 35                	je     f0100f57 <page_lookup+0x69>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100f22:	c1 e8 0c             	shr    $0xc,%eax
f0100f25:	3b 05 00 c1 15 f0    	cmp    0xf015c100,%eax
f0100f2b:	72 1c                	jb     f0100f49 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0100f2d:	c7 44 24 08 e4 47 10 	movl   $0xf01047e4,0x8(%esp)
f0100f34:	f0 
f0100f35:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100f3c:	00 
f0100f3d:	c7 04 24 f5 4b 10 f0 	movl   $0xf0104bf5,(%esp)
f0100f44:	e8 37 f1 ff ff       	call   f0100080 <_panic>
	return &pages[PPN(pa)];
f0100f49:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100f4c:	c1 e0 02             	shl    $0x2,%eax
f0100f4f:	03 05 0c c1 15 f0    	add    0xf015c10c,%eax
		  return pa2page (PTE_ADDR (*pte));
f0100f55:	eb 05                	jmp    f0100f5c <page_lookup+0x6e>
f0100f57:	b8 00 00 00 00       	mov    $0x0,%eax
        }
	return NULL;
}
f0100f5c:	83 c4 14             	add    $0x14,%esp
f0100f5f:	5b                   	pop    %ebx
f0100f60:	5d                   	pop    %ebp
f0100f61:	c3                   	ret    

f0100f62 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f62:	55                   	push   %ebp
f0100f63:	89 e5                	mov    %esp,%ebp
f0100f65:	83 ec 28             	sub    $0x28,%esp
f0100f68:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100f6b:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100f6e:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;
	struct Page *physpage = page_lookup (pgdir, va, &pte);
f0100f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f77:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f7f:	89 34 24             	mov    %esi,(%esp)
f0100f82:	e8 67 ff ff ff       	call   f0100eee <page_lookup>

 	if (physpage != NULL) {
f0100f87:	85 c0                	test   %eax,%eax
f0100f89:	74 1d                	je     f0100fa8 <page_remove+0x46>
	  	page_decref (physpage);
f0100f8b:	89 04 24             	mov    %eax,(%esp)
f0100f8e:	e8 f7 fa ff ff       	call   f0100a8a <page_decref>
	   	*pte = 0;
f0100f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	    	tlb_invalidate (pgdir, va);
f0100f9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fa0:	89 34 24             	mov    %esi,(%esp)
f0100fa3:	e8 05 fb ff ff       	call   f0100aad <tlb_invalidate>
	}
}
f0100fa8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100fab:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100fae:	89 ec                	mov    %ebp,%esp
f0100fb0:	5d                   	pop    %ebp
f0100fb1:	c3                   	ret    

f0100fb2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0100fb2:	55                   	push   %ebp
f0100fb3:	89 e5                	mov    %esp,%ebp
f0100fb5:	83 ec 28             	sub    $0x28,%esp
f0100fb8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100fbb:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100fbe:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100fc1:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fc4:	8b 7d 10             	mov    0x10(%ebp),%edi
	*pte = page2pa (pp)|perm|PTE_P;
	pp -> pp_ref ++;
	return 0;*/
	pte_t *pte;

	pte = pgdir_walk(pgdir, va, 1);
f0100fc7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100fce:	00 
f0100fcf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fd3:	89 34 24             	mov    %esi,(%esp)
f0100fd6:	e8 e9 fc ff ff       	call   f0100cc4 <pgdir_walk>
f0100fdb:	89 c3                	mov    %eax,%ebx
	if (pte == NULL) {
f0100fdd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100fe2:	85 db                	test   %ebx,%ebx
f0100fe4:	74 54                	je     f010103a <page_insert+0x88>
		return -E_NO_MEM;
	}

	// Increase first to avoid the page is removed to the free list
	pp->pp_ref ++;
f0100fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fe9:	66 83 40 08 01       	addw   $0x1,0x8(%eax)

	if (((*pte) & PTE_P) != 0) {
f0100fee:	f6 03 01             	testb  $0x1,(%ebx)
f0100ff1:	74 0c                	je     f0100fff <page_insert+0x4d>
		page_remove(pgdir, va);
f0100ff3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ff7:	89 34 24             	mov    %esi,(%esp)
f0100ffa:	e8 63 ff ff ff       	call   f0100f62 <page_remove>
	}

	*pte = page2pa(pp) | perm | PTE_P;
f0100fff:	8b 55 14             	mov    0x14(%ebp),%edx
f0101002:	83 ca 01             	or     $0x1,%edx
f0101005:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101008:	2b 05 0c c1 15 f0    	sub    0xf015c10c,%eax
f010100e:	c1 f8 02             	sar    $0x2,%eax
f0101011:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101017:	c1 e0 0c             	shl    $0xc,%eax
f010101a:	09 d0                	or     %edx,%eax
f010101c:	89 03                	mov    %eax,(%ebx)
	pgdir[PDX(va)] |= perm;
f010101e:	89 f8                	mov    %edi,%eax
f0101020:	c1 e8 16             	shr    $0x16,%eax
f0101023:	8b 55 14             	mov    0x14(%ebp),%edx
f0101026:	09 14 86             	or     %edx,(%esi,%eax,4)
	tlb_invalidate(pgdir, va);
f0101029:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010102d:	89 34 24             	mov    %esi,(%esp)
f0101030:	e8 78 fa ff ff       	call   f0100aad <tlb_invalidate>
f0101035:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f010103a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010103d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101040:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101043:	89 ec                	mov    %ebp,%esp
f0101045:	5d                   	pop    %ebp
f0101046:	c3                   	ret    

f0101047 <page_check>:
	}
}

void
page_check(void)
{
f0101047:	55                   	push   %ebp
f0101048:	89 e5                	mov    %esp,%ebp
f010104a:	53                   	push   %ebx
f010104b:	83 ec 34             	sub    $0x34,%esp
	struct Page *pp, *pp0, *pp1, *pp2;
	struct Page_list fl;
	pte_t *ptep;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f010104e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0101055:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f010105c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101063:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101066:	89 04 24             	mov    %eax,(%esp)
f0101069:	e8 05 fc ff ff       	call   f0100c73 <page_alloc>
f010106e:	85 c0                	test   %eax,%eax
f0101070:	74 24                	je     f0101096 <page_check+0x4f>
f0101072:	c7 44 24 0c 03 4c 10 	movl   $0xf0104c03,0xc(%esp)
f0101079:	f0 
f010107a:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101081:	f0 
f0101082:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101089:	00 
f010108a:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101091:	e8 ea ef ff ff       	call   f0100080 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101096:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101099:	89 04 24             	mov    %eax,(%esp)
f010109c:	e8 d2 fb ff ff       	call   f0100c73 <page_alloc>
f01010a1:	85 c0                	test   %eax,%eax
f01010a3:	74 24                	je     f01010c9 <page_check+0x82>
f01010a5:	c7 44 24 0c 2e 4c 10 	movl   $0xf0104c2e,0xc(%esp)
f01010ac:	f0 
f01010ad:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01010b4:	f0 
f01010b5:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01010bc:	00 
f01010bd:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01010c4:	e8 b7 ef ff ff       	call   f0100080 <_panic>
	assert(page_alloc(&pp2) == 0);
f01010c9:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01010cc:	89 04 24             	mov    %eax,(%esp)
f01010cf:	e8 9f fb ff ff       	call   f0100c73 <page_alloc>
f01010d4:	85 c0                	test   %eax,%eax
f01010d6:	74 24                	je     f01010fc <page_check+0xb5>
f01010d8:	c7 44 24 0c 44 4c 10 	movl   $0xf0104c44,0xc(%esp)
f01010df:	f0 
f01010e0:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01010e7:	f0 
f01010e8:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f01010ef:	00 
f01010f0:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01010f7:	e8 84 ef ff ff       	call   f0100080 <_panic>

	assert(pp0);
f01010fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01010ff:	85 d2                	test   %edx,%edx
f0101101:	75 24                	jne    f0101127 <page_check+0xe0>
f0101103:	c7 44 24 0c 68 4c 10 	movl   $0xf0104c68,0xc(%esp)
f010110a:	f0 
f010110b:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101112:	f0 
f0101113:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f010111a:	00 
f010111b:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101122:	e8 59 ef ff ff       	call   f0100080 <_panic>
	assert(pp1 && pp1 != pp0);
f0101127:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010112a:	85 c0                	test   %eax,%eax
f010112c:	74 04                	je     f0101132 <page_check+0xeb>
f010112e:	39 c2                	cmp    %eax,%edx
f0101130:	75 24                	jne    f0101156 <page_check+0x10f>
f0101132:	c7 44 24 0c 5a 4c 10 	movl   $0xf0104c5a,0xc(%esp)
f0101139:	f0 
f010113a:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101141:	f0 
f0101142:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101149:	00 
f010114a:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101151:	e8 2a ef ff ff       	call   f0100080 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101156:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101159:	85 c9                	test   %ecx,%ecx
f010115b:	74 08                	je     f0101165 <page_check+0x11e>
f010115d:	39 c8                	cmp    %ecx,%eax
f010115f:	74 04                	je     f0101165 <page_check+0x11e>
f0101161:	39 ca                	cmp    %ecx,%edx
f0101163:	75 24                	jne    f0101189 <page_check+0x142>
f0101165:	c7 44 24 0c 04 48 10 	movl   $0xf0104804,0xc(%esp)
f010116c:	f0 
f010116d:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101174:	f0 
f0101175:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f010117c:	00 
f010117d:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101184:	e8 f7 ee ff ff       	call   f0100080 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101189:	8b 1d 58 b4 15 f0    	mov    0xf015b458,%ebx
	LIST_INIT(&page_free_list);
f010118f:	c7 05 58 b4 15 f0 00 	movl   $0x0,0xf015b458
f0101196:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101199:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010119c:	89 04 24             	mov    %eax,(%esp)
f010119f:	e8 cf fa ff ff       	call   f0100c73 <page_alloc>
f01011a4:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01011a7:	74 24                	je     f01011cd <page_check+0x186>
f01011a9:	c7 44 24 0c 6c 4c 10 	movl   $0xf0104c6c,0xc(%esp)
f01011b0:	f0 
f01011b1:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01011b8:	f0 
f01011b9:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f01011c0:	00 
f01011c1:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01011c8:	e8 b3 ee ff ff       	call   f0100080 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f01011cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01011d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011db:	00 
f01011dc:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01011e1:	89 04 24             	mov    %eax,(%esp)
f01011e4:	e8 05 fd ff ff       	call   f0100eee <page_lookup>
f01011e9:	85 c0                	test   %eax,%eax
f01011eb:	74 24                	je     f0101211 <page_check+0x1ca>
f01011ed:	c7 44 24 0c 24 48 10 	movl   $0xf0104824,0xc(%esp)
f01011f4:	f0 
f01011f5:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01011fc:	f0 
f01011fd:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101204:	00 
f0101205:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f010120c:	e8 6f ee ff ff       	call   f0100080 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0101211:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101218:	00 
f0101219:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101220:	00 
f0101221:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101224:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101228:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f010122d:	89 04 24             	mov    %eax,(%esp)
f0101230:	e8 7d fd ff ff       	call   f0100fb2 <page_insert>
f0101235:	85 c0                	test   %eax,%eax
f0101237:	78 24                	js     f010125d <page_check+0x216>
f0101239:	c7 44 24 0c 5c 48 10 	movl   $0xf010485c,0xc(%esp)
f0101240:	f0 
f0101241:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101248:	f0 
f0101249:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101250:	00 
f0101251:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101258:	e8 23 ee ff ff       	call   f0100080 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010125d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101260:	89 04 24             	mov    %eax,(%esp)
f0101263:	e8 f9 f7 ff ff       	call   f0100a61 <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f0101268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010126f:	00 
f0101270:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101277:	00 
f0101278:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010127b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010127f:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f0101284:	89 04 24             	mov    %eax,(%esp)
f0101287:	e8 26 fd ff ff       	call   f0100fb2 <page_insert>
f010128c:	85 c0                	test   %eax,%eax
f010128e:	74 24                	je     f01012b4 <page_check+0x26d>
f0101290:	c7 44 24 0c 88 48 10 	movl   $0xf0104888,0xc(%esp)
f0101297:	f0 
f0101298:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f010129f:	f0 
f01012a0:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f01012a7:	00 
f01012a8:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01012af:	e8 cc ed ff ff       	call   f0100080 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01012b4:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01012b9:	8b 08                	mov    (%eax),%ecx
f01012bb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01012c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01012c4:	2b 15 0c c1 15 f0    	sub    0xf015c10c,%edx
f01012ca:	c1 fa 02             	sar    $0x2,%edx
f01012cd:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01012d3:	c1 e2 0c             	shl    $0xc,%edx
f01012d6:	39 d1                	cmp    %edx,%ecx
f01012d8:	74 24                	je     f01012fe <page_check+0x2b7>
f01012da:	c7 44 24 0c b4 48 10 	movl   $0xf01048b4,0xc(%esp)
f01012e1:	f0 
f01012e2:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01012e9:	f0 
f01012ea:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f01012f1:	00 
f01012f2:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01012f9:	e8 82 ed ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f01012fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0101303:	e8 b0 f7 ff ff       	call   f0100ab8 <check_va2pa>
f0101308:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010130b:	89 d1                	mov    %edx,%ecx
f010130d:	2b 0d 0c c1 15 f0    	sub    0xf015c10c,%ecx
f0101313:	c1 f9 02             	sar    $0x2,%ecx
f0101316:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f010131c:	c1 e1 0c             	shl    $0xc,%ecx
f010131f:	39 c8                	cmp    %ecx,%eax
f0101321:	74 24                	je     f0101347 <page_check+0x300>
f0101323:	c7 44 24 0c dc 48 10 	movl   $0xf01048dc,0xc(%esp)
f010132a:	f0 
f010132b:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101332:	f0 
f0101333:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f010133a:	00 
f010133b:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101342:	e8 39 ed ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 1);
f0101347:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f010134c:	74 24                	je     f0101372 <page_check+0x32b>
f010134e:	c7 44 24 0c 89 4c 10 	movl   $0xf0104c89,0xc(%esp)
f0101355:	f0 
f0101356:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f010135d:	f0 
f010135e:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101365:	00 
f0101366:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f010136d:	e8 0e ed ff ff       	call   f0100080 <_panic>
	assert(pp0->pp_ref == 1);
f0101372:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101375:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f010137a:	74 24                	je     f01013a0 <page_check+0x359>
f010137c:	c7 44 24 0c 9a 4c 10 	movl   $0xf0104c9a,0xc(%esp)
f0101383:	f0 
f0101384:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f010138b:	f0 
f010138c:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101393:	00 
f0101394:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f010139b:	e8 e0 ec ff ff       	call   f0100080 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f01013a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01013a7:	00 
f01013a8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013af:	00 
f01013b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01013b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013b7:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01013bc:	89 04 24             	mov    %eax,(%esp)
f01013bf:	e8 ee fb ff ff       	call   f0100fb2 <page_insert>
f01013c4:	85 c0                	test   %eax,%eax
f01013c6:	74 24                	je     f01013ec <page_check+0x3a5>
f01013c8:	c7 44 24 0c 0c 49 10 	movl   $0xf010490c,0xc(%esp)
f01013cf:	f0 
f01013d0:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01013d7:	f0 
f01013d8:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f01013df:	00 
f01013e0:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01013e7:	e8 94 ec ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01013ec:	ba 00 10 00 00       	mov    $0x1000,%edx
f01013f1:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01013f6:	e8 bd f6 ff ff       	call   f0100ab8 <check_va2pa>
f01013fb:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01013fe:	89 d1                	mov    %edx,%ecx
f0101400:	2b 0d 0c c1 15 f0    	sub    0xf015c10c,%ecx
f0101406:	c1 f9 02             	sar    $0x2,%ecx
f0101409:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f010140f:	c1 e1 0c             	shl    $0xc,%ecx
f0101412:	39 c8                	cmp    %ecx,%eax
f0101414:	74 24                	je     f010143a <page_check+0x3f3>
f0101416:	c7 44 24 0c 44 49 10 	movl   $0xf0104944,0xc(%esp)
f010141d:	f0 
f010141e:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101425:	f0 
f0101426:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f010142d:	00 
f010142e:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101435:	e8 46 ec ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f010143a:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f010143f:	74 24                	je     f0101465 <page_check+0x41e>
f0101441:	c7 44 24 0c ab 4c 10 	movl   $0xf0104cab,0xc(%esp)
f0101448:	f0 
f0101449:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101450:	f0 
f0101451:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101458:	00 
f0101459:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101460:	e8 1b ec ff ff       	call   f0100080 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101465:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101468:	89 04 24             	mov    %eax,(%esp)
f010146b:	e8 03 f8 ff ff       	call   f0100c73 <page_alloc>
f0101470:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101473:	74 24                	je     f0101499 <page_check+0x452>
f0101475:	c7 44 24 0c 6c 4c 10 	movl   $0xf0104c6c,0xc(%esp)
f010147c:	f0 
f010147d:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101484:	f0 
f0101485:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f010148c:	00 
f010148d:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101494:	e8 e7 eb ff ff       	call   f0100080 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101499:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01014a0:	00 
f01014a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014a8:	00 
f01014a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01014ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014b0:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01014b5:	89 04 24             	mov    %eax,(%esp)
f01014b8:	e8 f5 fa ff ff       	call   f0100fb2 <page_insert>
f01014bd:	85 c0                	test   %eax,%eax
f01014bf:	74 24                	je     f01014e5 <page_check+0x49e>
f01014c1:	c7 44 24 0c 0c 49 10 	movl   $0xf010490c,0xc(%esp)
f01014c8:	f0 
f01014c9:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01014d0:	f0 
f01014d1:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f01014d8:	00 
f01014d9:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01014e0:	e8 9b eb ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01014e5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01014ea:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01014ef:	e8 c4 f5 ff ff       	call   f0100ab8 <check_va2pa>
f01014f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01014f7:	89 d1                	mov    %edx,%ecx
f01014f9:	2b 0d 0c c1 15 f0    	sub    0xf015c10c,%ecx
f01014ff:	c1 f9 02             	sar    $0x2,%ecx
f0101502:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0101508:	c1 e1 0c             	shl    $0xc,%ecx
f010150b:	39 c8                	cmp    %ecx,%eax
f010150d:	74 24                	je     f0101533 <page_check+0x4ec>
f010150f:	c7 44 24 0c 44 49 10 	movl   $0xf0104944,0xc(%esp)
f0101516:	f0 
f0101517:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f010151e:	f0 
f010151f:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101526:	00 
f0101527:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f010152e:	e8 4d eb ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f0101533:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101538:	74 24                	je     f010155e <page_check+0x517>
f010153a:	c7 44 24 0c ab 4c 10 	movl   $0xf0104cab,0xc(%esp)
f0101541:	f0 
f0101542:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101549:	f0 
f010154a:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101551:	00 
f0101552:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101559:	e8 22 eb ff ff       	call   f0100080 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f010155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101561:	89 04 24             	mov    %eax,(%esp)
f0101564:	e8 0a f7 ff ff       	call   f0100c73 <page_alloc>
f0101569:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010156c:	74 24                	je     f0101592 <page_check+0x54b>
f010156e:	c7 44 24 0c 6c 4c 10 	movl   $0xf0104c6c,0xc(%esp)
f0101575:	f0 
f0101576:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f010157d:	f0 
f010157e:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101585:	00 
f0101586:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f010158d:	e8 ee ea ff ff       	call   f0100080 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101592:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101599:	00 
f010159a:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01015a1:	00 
f01015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01015a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015a9:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01015ae:	89 04 24             	mov    %eax,(%esp)
f01015b1:	e8 fc f9 ff ff       	call   f0100fb2 <page_insert>
f01015b6:	85 c0                	test   %eax,%eax
f01015b8:	78 24                	js     f01015de <page_check+0x597>
f01015ba:	c7 44 24 0c 74 49 10 	movl   $0xf0104974,0xc(%esp)
f01015c1:	f0 
f01015c2:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01015c9:	f0 
f01015ca:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f01015d1:	00 
f01015d2:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01015d9:	e8 a2 ea ff ff       	call   f0100080 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01015de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01015e5:	00 
f01015e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015ed:	00 
f01015ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01015f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015f5:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01015fa:	89 04 24             	mov    %eax,(%esp)
f01015fd:	e8 b0 f9 ff ff       	call   f0100fb2 <page_insert>
f0101602:	85 c0                	test   %eax,%eax
f0101604:	74 24                	je     f010162a <page_check+0x5e3>
f0101606:	c7 44 24 0c a8 49 10 	movl   $0xf01049a8,0xc(%esp)
f010160d:	f0 
f010160e:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101615:	f0 
f0101616:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f010161d:	00 
f010161e:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101625:	e8 56 ea ff ff       	call   f0100080 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f010162a:	ba 00 00 00 00       	mov    $0x0,%edx
f010162f:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f0101634:	e8 7f f4 ff ff       	call   f0100ab8 <check_va2pa>
f0101639:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010163c:	2b 15 0c c1 15 f0    	sub    0xf015c10c,%edx
f0101642:	c1 fa 02             	sar    $0x2,%edx
f0101645:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010164b:	c1 e2 0c             	shl    $0xc,%edx
f010164e:	39 d0                	cmp    %edx,%eax
f0101650:	74 24                	je     f0101676 <page_check+0x62f>
f0101652:	c7 44 24 0c e0 49 10 	movl   $0xf01049e0,0xc(%esp)
f0101659:	f0 
f010165a:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101661:	f0 
f0101662:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101669:	00 
f010166a:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101671:	e8 0a ea ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101676:	ba 00 10 00 00       	mov    $0x1000,%edx
f010167b:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f0101680:	e8 33 f4 ff ff       	call   f0100ab8 <check_va2pa>
f0101685:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101688:	89 d1                	mov    %edx,%ecx
f010168a:	2b 0d 0c c1 15 f0    	sub    0xf015c10c,%ecx
f0101690:	c1 f9 02             	sar    $0x2,%ecx
f0101693:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0101699:	c1 e1 0c             	shl    $0xc,%ecx
f010169c:	39 c8                	cmp    %ecx,%eax
f010169e:	74 24                	je     f01016c4 <page_check+0x67d>
f01016a0:	c7 44 24 0c 0c 4a 10 	movl   $0xf0104a0c,0xc(%esp)
f01016a7:	f0 
f01016a8:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01016af:	f0 
f01016b0:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f01016b7:	00 
f01016b8:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01016bf:	e8 bc e9 ff ff       	call   f0100080 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01016c4:	66 83 7a 08 02       	cmpw   $0x2,0x8(%edx)
f01016c9:	74 24                	je     f01016ef <page_check+0x6a8>
f01016cb:	c7 44 24 0c bc 4c 10 	movl   $0xf0104cbc,0xc(%esp)
f01016d2:	f0 
f01016d3:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01016da:	f0 
f01016db:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f01016e2:	00 
f01016e3:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01016ea:	e8 91 e9 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f01016ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01016f2:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01016f7:	74 24                	je     f010171d <page_check+0x6d6>
f01016f9:	c7 44 24 0c cd 4c 10 	movl   $0xf0104ccd,0xc(%esp)
f0101700:	f0 
f0101701:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101708:	f0 
f0101709:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101710:	00 
f0101711:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101718:	e8 63 e9 ff ff       	call   f0100080 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f010171d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101720:	89 04 24             	mov    %eax,(%esp)
f0101723:	e8 4b f5 ff ff       	call   f0100c73 <page_alloc>
f0101728:	85 c0                	test   %eax,%eax
f010172a:	75 08                	jne    f0101734 <page_check+0x6ed>
f010172c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010172f:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101732:	74 24                	je     f0101758 <page_check+0x711>
f0101734:	c7 44 24 0c 3c 4a 10 	movl   $0xf0104a3c,0xc(%esp)
f010173b:	f0 
f010173c:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101743:	f0 
f0101744:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f010174b:	00 
f010174c:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101753:	e8 28 e9 ff ff       	call   f0100080 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0101758:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010175f:	00 
f0101760:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f0101765:	89 04 24             	mov    %eax,(%esp)
f0101768:	e8 f5 f7 ff ff       	call   f0100f62 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f010176d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101772:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f0101777:	e8 3c f3 ff ff       	call   f0100ab8 <check_va2pa>
f010177c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010177f:	74 24                	je     f01017a5 <page_check+0x75e>
f0101781:	c7 44 24 0c 60 4a 10 	movl   $0xf0104a60,0xc(%esp)
f0101788:	f0 
f0101789:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101790:	f0 
f0101791:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101798:	00 
f0101799:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01017a0:	e8 db e8 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f01017a5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017aa:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01017af:	e8 04 f3 ff ff       	call   f0100ab8 <check_va2pa>
f01017b4:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01017b7:	89 d1                	mov    %edx,%ecx
f01017b9:	2b 0d 0c c1 15 f0    	sub    0xf015c10c,%ecx
f01017bf:	c1 f9 02             	sar    $0x2,%ecx
f01017c2:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f01017c8:	c1 e1 0c             	shl    $0xc,%ecx
f01017cb:	39 c8                	cmp    %ecx,%eax
f01017cd:	74 24                	je     f01017f3 <page_check+0x7ac>
f01017cf:	c7 44 24 0c 0c 4a 10 	movl   $0xf0104a0c,0xc(%esp)
f01017d6:	f0 
f01017d7:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01017de:	f0 
f01017df:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f01017e6:	00 
f01017e7:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01017ee:	e8 8d e8 ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 1);
f01017f3:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f01017f8:	74 24                	je     f010181e <page_check+0x7d7>
f01017fa:	c7 44 24 0c 89 4c 10 	movl   $0xf0104c89,0xc(%esp)
f0101801:	f0 
f0101802:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101809:	f0 
f010180a:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101811:	00 
f0101812:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101819:	e8 62 e8 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f010181e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101821:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101826:	74 24                	je     f010184c <page_check+0x805>
f0101828:	c7 44 24 0c cd 4c 10 	movl   $0xf0104ccd,0xc(%esp)
f010182f:	f0 
f0101830:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101837:	f0 
f0101838:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f010183f:	00 
f0101840:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101847:	e8 34 e8 ff ff       	call   f0100080 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f010184c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101853:	00 
f0101854:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f0101859:	89 04 24             	mov    %eax,(%esp)
f010185c:	e8 01 f7 ff ff       	call   f0100f62 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101861:	ba 00 00 00 00       	mov    $0x0,%edx
f0101866:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f010186b:	e8 48 f2 ff ff       	call   f0100ab8 <check_va2pa>
f0101870:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101873:	74 24                	je     f0101899 <page_check+0x852>
f0101875:	c7 44 24 0c 60 4a 10 	movl   $0xf0104a60,0xc(%esp)
f010187c:	f0 
f010187d:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101884:	f0 
f0101885:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f010188c:	00 
f010188d:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101894:	e8 e7 e7 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f0101899:	ba 00 10 00 00       	mov    $0x1000,%edx
f010189e:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01018a3:	e8 10 f2 ff ff       	call   f0100ab8 <check_va2pa>
f01018a8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01018ab:	74 24                	je     f01018d1 <page_check+0x88a>
f01018ad:	c7 44 24 0c 84 4a 10 	movl   $0xf0104a84,0xc(%esp)
f01018b4:	f0 
f01018b5:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01018bc:	f0 
f01018bd:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f01018c4:	00 
f01018c5:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01018cc:	e8 af e7 ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 0);
f01018d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018d4:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01018d9:	74 24                	je     f01018ff <page_check+0x8b8>
f01018db:	c7 44 24 0c de 4c 10 	movl   $0xf0104cde,0xc(%esp)
f01018e2:	f0 
f01018e3:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01018ea:	f0 
f01018eb:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f01018f2:	00 
f01018f3:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01018fa:	e8 81 e7 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f01018ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101902:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101907:	74 24                	je     f010192d <page_check+0x8e6>
f0101909:	c7 44 24 0c cd 4c 10 	movl   $0xf0104ccd,0xc(%esp)
f0101910:	f0 
f0101911:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101918:	f0 
f0101919:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101920:	00 
f0101921:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101928:	e8 53 e7 ff ff       	call   f0100080 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f010192d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101930:	89 04 24             	mov    %eax,(%esp)
f0101933:	e8 3b f3 ff ff       	call   f0100c73 <page_alloc>
f0101938:	85 c0                	test   %eax,%eax
f010193a:	75 08                	jne    f0101944 <page_check+0x8fd>
f010193c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010193f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0101942:	74 24                	je     f0101968 <page_check+0x921>
f0101944:	c7 44 24 0c ac 4a 10 	movl   $0xf0104aac,0xc(%esp)
f010194b:	f0 
f010194c:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101953:	f0 
f0101954:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f010195b:	00 
f010195c:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101963:	e8 18 e7 ff ff       	call   f0100080 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101968:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010196b:	89 04 24             	mov    %eax,(%esp)
f010196e:	e8 00 f3 ff ff       	call   f0100c73 <page_alloc>
f0101973:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101976:	74 24                	je     f010199c <page_check+0x955>
f0101978:	c7 44 24 0c 6c 4c 10 	movl   $0xf0104c6c,0xc(%esp)
f010197f:	f0 
f0101980:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101987:	f0 
f0101988:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f010198f:	00 
f0101990:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101997:	e8 e4 e6 ff ff       	call   f0100080 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f010199c:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f01019a1:	8b 08                	mov    (%eax),%ecx
f01019a3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01019a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01019ac:	2b 15 0c c1 15 f0    	sub    0xf015c10c,%edx
f01019b2:	c1 fa 02             	sar    $0x2,%edx
f01019b5:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01019bb:	c1 e2 0c             	shl    $0xc,%edx
f01019be:	39 d1                	cmp    %edx,%ecx
f01019c0:	74 24                	je     f01019e6 <page_check+0x99f>
f01019c2:	c7 44 24 0c b4 48 10 	movl   $0xf01048b4,0xc(%esp)
f01019c9:	f0 
f01019ca:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f01019d1:	f0 
f01019d2:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01019d9:	00 
f01019da:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f01019e1:	e8 9a e6 ff ff       	call   f0100080 <_panic>
	boot_pgdir[0] = 0;
f01019e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01019ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01019ef:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f01019f4:	74 24                	je     f0101a1a <page_check+0x9d3>
f01019f6:	c7 44 24 0c 9a 4c 10 	movl   $0xf0104c9a,0xc(%esp)
f01019fd:	f0 
f01019fe:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101a05:	f0 
f0101a06:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101a0d:	00 
f0101a0e:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101a15:	e8 66 e6 ff ff       	call   f0100080 <_panic>
	pp0->pp_ref = 0;
f0101a1a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0101a20:	89 1d 58 b4 15 f0    	mov    %ebx,0xf015b458

	// free the pages we took
	page_free(pp0);
f0101a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101a29:	89 04 24             	mov    %eax,(%esp)
f0101a2c:	e8 30 f0 ff ff       	call   f0100a61 <page_free>
	page_free(pp1);
f0101a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101a34:	89 04 24             	mov    %eax,(%esp)
f0101a37:	e8 25 f0 ff ff       	call   f0100a61 <page_free>
	page_free(pp2);
f0101a3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101a3f:	89 04 24             	mov    %eax,(%esp)
f0101a42:	e8 1a f0 ff ff       	call   f0100a61 <page_free>

	cprintf("page_check() succeeded!\n");
f0101a47:	c7 04 24 ef 4c 10 f0 	movl   $0xf0104cef,(%esp)
f0101a4e:	e8 bc 0e 00 00       	call   f010290f <cprintf>
}
f0101a53:	83 c4 34             	add    $0x34,%esp
f0101a56:	5b                   	pop    %ebx
f0101a57:	5d                   	pop    %ebp
f0101a58:	c3                   	ret    

f0101a59 <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0101a59:	55                   	push   %ebp
f0101a5a:	89 e5                	mov    %esp,%ebp
f0101a5c:	83 ec 38             	sub    $0x38,%esp
f0101a5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101a62:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101a65:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// Remove this line when you're ready to test this function.
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f0101a68:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a6d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101a72:	e8 99 ef ff ff       	call   f0100a10 <boot_alloc>
f0101a77:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f0101a79:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a80:	00 
f0101a81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101a88:	00 
f0101a89:	89 04 24             	mov    %eax,(%esp)
f0101a8c:	e8 35 23 00 00       	call   f0103dc6 <memset>
	boot_pgdir = pgdir;
f0101a91:	89 1d 08 c1 15 f0    	mov    %ebx,0xf015c108
	boot_cr3 = PADDR(pgdir);
f0101a97:	89 d8                	mov    %ebx,%eax
f0101a99:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101a9f:	77 20                	ja     f0101ac1 <i386_vm_init+0x68>
f0101aa1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101aa5:	c7 44 24 08 88 47 10 	movl   $0xf0104788,0x8(%esp)
f0101aac:	f0 
f0101aad:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f0101ab4:	00 
f0101ab5:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101abc:	e8 bf e5 ff ff       	call   f0100080 <_panic>
f0101ac1:	05 00 00 00 10       	add    $0x10000000,%eax
f0101ac6:	a3 04 c1 15 f0       	mov    %eax,0xf015c104
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f0101acb:	89 c2                	mov    %eax,%edx
f0101acd:	83 ca 03             	or     $0x3,%edx
f0101ad0:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f0101ad6:	83 c8 05             	or     $0x5,%eax
f0101ad9:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// pieces:
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed => faults
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_segment(pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f0101adf:	be 00 f0 10 f0       	mov    $0xf010f000,%esi
f0101ae4:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0101aea:	77 20                	ja     f0101b0c <i386_vm_init+0xb3>
f0101aec:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101af0:	c7 44 24 08 88 47 10 	movl   $0xf0104788,0x8(%esp)
f0101af7:	f0 
f0101af8:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
f0101aff:	00 
f0101b00:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101b07:	e8 74 e5 ff ff       	call   f0100080 <_panic>
f0101b0c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0101b13:	00 
f0101b14:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0101b1a:	89 04 24             	mov    %eax,(%esp)
f0101b1d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101b22:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0101b27:	89 d8                	mov    %ebx,%eax
f0101b29:	e8 3c f0 ff ff       	call   f0100b6a <boot_map_segment>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
        boot_map_segment(pgdir,KERNBASE,0xFFFFFFFF - KERNBASE + 1, 0, PTE_W);
f0101b2e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0101b35:	00 
f0101b36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b3d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101b42:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101b47:	89 d8                	mov    %ebx,%eax
f0101b49:	e8 1c f0 ff ff       	call   f0100b6a <boot_map_segment>
	// (ie. perm = PTE_U | PTE_P)
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here: 
	size_t spages = ROUNDUP(npage * sizeof(struct Page),PGSIZE);
f0101b4e:	6b 3d 00 c1 15 f0 0c 	imul   $0xc,0xf015c100,%edi
f0101b55:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0101b5b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	pages = (struct Page*)boot_alloc(spages,PGSIZE);
f0101b61:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b66:	89 f8                	mov    %edi,%eax
f0101b68:	e8 a3 ee ff ff       	call   f0100a10 <boot_alloc>
f0101b6d:	a3 0c c1 15 f0       	mov    %eax,0xf015c10c
	physaddr_t ppages = PADDR(pages);
f0101b72:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b77:	77 20                	ja     f0101b99 <i386_vm_init+0x140>
f0101b79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b7d:	c7 44 24 08 88 47 10 	movl   $0xf0104788,0x8(%esp)
f0101b84:	f0 
f0101b85:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
f0101b8c:	00 
f0101b8d:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101b94:	e8 e7 e4 ff ff       	call   f0100080 <_panic>
	boot_map_segment(pgdir, UPAGES, spages, ppages, PTE_U);
f0101b99:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0101ba0:	00 
f0101ba1:	05 00 00 00 10       	add    $0x10000000,%eax
f0101ba6:	89 04 24             	mov    %eax,(%esp)
f0101ba9:	89 f9                	mov    %edi,%ecx
f0101bab:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101bb0:	89 d8                	mov    %ebx,%eax
f0101bb2:	e8 b3 ef ff ff       	call   f0100b6a <boot_map_segment>
	// LAB 3: Your code here.
/*	int k = NENV * sizeof(struct Env);
	envs = (struct Env *)boot_alloc(k, PGSIZE);
	k = ROUNDUP(k, PGSIZE);
	boot_map_segment(pgdir, UENVS, k, PADDR(envs), PTE_U | PTE_P);*/
	envs = boot_alloc (NENV * sizeof (struct Env), PGSIZE);
f0101bb7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bbc:	b8 00 90 01 00       	mov    $0x19000,%eax
f0101bc1:	e8 4a ee ff ff       	call   f0100a10 <boot_alloc>
f0101bc6:	a3 60 b4 15 f0       	mov    %eax,0xf015b460
	boot_map_segment ( pgdir,UENVS,ROUNDUP (NENV * sizeof (struct Env), PGSIZE),PADDR ((uintptr_t) envs),PTE_U);
f0101bcb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101bd0:	77 20                	ja     f0101bf2 <i386_vm_init+0x199>
f0101bd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101bd6:	c7 44 24 08 88 47 10 	movl   $0xf0104788,0x8(%esp)
f0101bdd:	f0 
f0101bde:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f0101be5:	00 
f0101be6:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101bed:	e8 8e e4 ff ff       	call   f0100080 <_panic>
f0101bf2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0101bf9:	00 
f0101bfa:	05 00 00 00 10       	add    $0x10000000,%eax
f0101bff:	89 04 24             	mov    %eax,(%esp)
f0101c02:	b9 00 90 01 00       	mov    $0x19000,%ecx
f0101c07:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101c0c:	89 d8                	mov    %ebx,%eax
f0101c0e:	e8 57 ef ff ff       	call   f0100b6a <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f0101c13:	a1 08 c1 15 f0       	mov    0xf015c108,%eax
f0101c18:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f0101c1b:	6b 05 00 c1 15 f0 0c 	imul   $0xc,0xf015c100,%eax
f0101c22:	05 ff 0f 00 00       	add    $0xfff,%eax
	for (i = 0; i < n; i += PGSIZE)
f0101c27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101c2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101c2f:	0f 84 83 00 00 00    	je     f0101cb8 <i386_vm_init+0x25f>
f0101c35:	bf 00 00 00 00       	mov    $0x0,%edi
f0101c3a:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0101c3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101c40:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f0101c46:	89 d8                	mov    %ebx,%eax
f0101c48:	e8 6b ee ff ff       	call   f0100ab8 <check_va2pa>
f0101c4d:	8b 15 0c c1 15 f0    	mov    0xf015c10c,%edx
f0101c53:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101c59:	77 20                	ja     f0101c7b <i386_vm_init+0x222>
f0101c5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101c5f:	c7 44 24 08 88 47 10 	movl   $0xf0104788,0x8(%esp)
f0101c66:	f0 
f0101c67:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
f0101c6e:	00 
f0101c6f:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101c76:	e8 05 e4 ff ff       	call   f0100080 <_panic>
f0101c7b:	8d 94 17 00 00 00 10 	lea    0x10000000(%edi,%edx,1),%edx
f0101c82:	39 d0                	cmp    %edx,%eax
f0101c84:	74 24                	je     f0101caa <i386_vm_init+0x251>
f0101c86:	c7 44 24 0c d0 4a 10 	movl   $0xf0104ad0,0xc(%esp)
f0101c8d:	f0 
f0101c8e:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101c95:	f0 
f0101c96:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
f0101c9d:	00 
f0101c9e:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101ca5:	e8 d6 e3 ff ff       	call   f0100080 <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101caa:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101cb0:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
f0101cb3:	77 8b                	ja     f0101c40 <i386_vm_init+0x1e7>
f0101cb5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101cb8:	bf 00 00 00 00       	mov    $0x0,%edi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101cbd:	8d 97 00 00 c0 ee    	lea    -0x11400000(%edi),%edx
f0101cc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101cc6:	e8 ed ed ff ff       	call   f0100ab8 <check_va2pa>
f0101ccb:	8b 15 60 b4 15 f0    	mov    0xf015b460,%edx
f0101cd1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101cd7:	77 20                	ja     f0101cf9 <i386_vm_init+0x2a0>
f0101cd9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101cdd:	c7 44 24 08 88 47 10 	movl   $0xf0104788,0x8(%esp)
f0101ce4:	f0 
f0101ce5:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f0101cec:	00 
f0101ced:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101cf4:	e8 87 e3 ff ff       	call   f0100080 <_panic>
f0101cf9:	8d 94 17 00 00 00 10 	lea    0x10000000(%edi,%edx,1),%edx
f0101d00:	39 d0                	cmp    %edx,%eax
f0101d02:	74 24                	je     f0101d28 <i386_vm_init+0x2cf>
f0101d04:	c7 44 24 0c 04 4b 10 	movl   $0xf0104b04,0xc(%esp)
f0101d0b:	f0 
f0101d0c:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101d13:	f0 
f0101d14:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f0101d1b:	00 
f0101d1c:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101d23:	e8 58 e3 ff ff       	call   f0100080 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101d28:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101d2e:	81 ff 00 90 01 00    	cmp    $0x19000,%edi
f0101d34:	75 87                	jne    f0101cbd <i386_vm_init+0x264>
f0101d36:	bf 00 00 00 00       	mov    $0x0,%edi
f0101d3b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101d3e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101d41:	8d 97 00 00 00 f0    	lea    -0x10000000(%edi),%edx
f0101d47:	89 d8                	mov    %ebx,%eax
f0101d49:	e8 6a ed ff ff       	call   f0100ab8 <check_va2pa>
f0101d4e:	39 c7                	cmp    %eax,%edi
f0101d50:	74 24                	je     f0101d76 <i386_vm_init+0x31d>
f0101d52:	c7 44 24 0c 38 4b 10 	movl   $0xf0104b38,0xc(%esp)
f0101d59:	f0 
f0101d5a:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101d61:	f0 
f0101d62:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
f0101d69:	00 
f0101d6a:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101d71:	e8 0a e3 ff ff       	call   f0100080 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
f0101d76:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101d7c:	81 ff 00 00 00 10    	cmp    $0x10000000,%edi
f0101d82:	75 bd                	jne    f0101d41 <i386_vm_init+0x2e8>
f0101d84:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101d87:	bf 00 80 bf ef       	mov    $0xefbf8000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0101d8c:	81 c6 00 80 40 20    	add    $0x20408000,%esi
f0101d92:	89 fa                	mov    %edi,%edx
f0101d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101d97:	e8 1c ed ff ff       	call   f0100ab8 <check_va2pa>
f0101d9c:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f0101d9f:	39 d0                	cmp    %edx,%eax
f0101da1:	74 24                	je     f0101dc7 <i386_vm_init+0x36e>
f0101da3:	c7 44 24 0c 60 4b 10 	movl   $0xf0104b60,0xc(%esp)
f0101daa:	f0 
f0101dab:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101db2:	f0 
f0101db3:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
f0101dba:	00 
f0101dbb:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101dc2:	e8 b9 e2 ff ff       	call   f0100080 <_panic>
f0101dc7:	81 c7 00 10 00 00    	add    $0x1000,%edi
	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101dcd:	81 ff 00 00 c0 ef    	cmp    $0xefc00000,%edi
f0101dd3:	75 bd                	jne    f0101d92 <i386_vm_init+0x339>
f0101dd5:	b8 00 00 00 00       	mov    $0x0,%eax
f0101dda:	8b 4d e0             	mov    -0x20(%ebp),%ecx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0101ddd:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0101de3:	83 fa 04             	cmp    $0x4,%edx
f0101de6:	77 2a                	ja     f0101e12 <i386_vm_init+0x3b9>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i]);
f0101de8:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101dec:	75 7f                	jne    f0101e6d <i386_vm_init+0x414>
f0101dee:	c7 44 24 0c 08 4d 10 	movl   $0xf0104d08,0xc(%esp)
f0101df5:	f0 
f0101df6:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101dfd:	f0 
f0101dfe:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0101e05:	00 
f0101e06:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101e0d:	e8 6e e2 ff ff       	call   f0100080 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f0101e12:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0101e17:	76 2a                	jbe    f0101e43 <i386_vm_init+0x3ea>
				assert(pgdir[i]);
f0101e19:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101e1d:	75 4e                	jne    f0101e6d <i386_vm_init+0x414>
f0101e1f:	c7 44 24 0c 08 4d 10 	movl   $0xf0104d08,0xc(%esp)
f0101e26:	f0 
f0101e27:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101e2e:	f0 
f0101e2f:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
f0101e36:	00 
f0101e37:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101e3e:	e8 3d e2 ff ff       	call   f0100080 <_panic>
			else
				assert(pgdir[i] == 0);
f0101e43:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101e47:	74 24                	je     f0101e6d <i386_vm_init+0x414>
f0101e49:	c7 44 24 0c 11 4d 10 	movl   $0xf0104d11,0xc(%esp)
f0101e50:	f0 
f0101e51:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0101e58:	f0 
f0101e59:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0101e60:	00 
f0101e61:	c7 04 24 e9 4b 10 f0 	movl   $0xf0104be9,(%esp)
f0101e68:	e8 13 e2 ff ff       	call   f0100080 <_panic>
	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f0101e6d:	83 c0 01             	add    $0x1,%eax
f0101e70:	3d 00 04 00 00       	cmp    $0x400,%eax
f0101e75:	0f 85 62 ff ff ff    	jne    f0101ddd <i386_vm_init+0x384>
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f0101e7b:	c7 04 24 a8 4b 10 f0 	movl   $0xf0104ba8,(%esp)
f0101e82:	e8 88 0a 00 00       	call   f010290f <cprintf>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f0101e87:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f0101e8d:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101e8f:	a1 04 c1 15 f0       	mov    0xf015c104,%eax
f0101e94:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0101e97:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f0101e9a:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0101e9f:	83 e0 f3             	and    $0xfffffff3,%eax
f0101ea2:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0101ea5:	0f 01 15 50 73 11 f0 	lgdtl  0xf0117350
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0101eac:	b8 23 00 00 00       	mov    $0x23,%eax
f0101eb1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0101eb3:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0101eb5:	b0 10                	mov    $0x10,%al
f0101eb7:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0101eb9:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0101ebb:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f0101ebd:	ea c4 1e 10 f0 08 00 	ljmp   $0x8,$0xf0101ec4
	asm volatile("lldt %%ax" :: "a" (0));
f0101ec4:	b0 00                	mov    $0x0,%al
f0101ec6:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f0101ec9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101ecf:	a1 04 c1 15 f0       	mov    0xf015c104,%eax
f0101ed4:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}
f0101ed7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101eda:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101edd:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101ee0:	89 ec                	mov    %ebp,%esp
f0101ee2:	5d                   	pop    %ebp
f0101ee3:	c3                   	ret    

f0101ee4 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0101ee4:	55                   	push   %ebp
f0101ee5:	89 e5                	mov    %esp,%ebp
f0101ee7:	83 ec 18             	sub    $0x18,%esp
f0101eea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101eed:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101ef0:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101ef2:	89 04 24             	mov    %eax,(%esp)
f0101ef5:	e8 ba 09 00 00       	call   f01028b4 <mc146818_read>
f0101efa:	89 c6                	mov    %eax,%esi
f0101efc:	83 c3 01             	add    $0x1,%ebx
f0101eff:	89 1c 24             	mov    %ebx,(%esp)
f0101f02:	e8 ad 09 00 00       	call   f01028b4 <mc146818_read>
f0101f07:	c1 e0 08             	shl    $0x8,%eax
f0101f0a:	09 f0                	or     %esi,%eax
}
f0101f0c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101f0f:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101f12:	89 ec                	mov    %ebp,%esp
f0101f14:	5d                   	pop    %ebp
f0101f15:	c3                   	ret    

f0101f16 <i386_detect_memory>:

void
i386_detect_memory(void)
{
f0101f16:	55                   	push   %ebp
f0101f17:	89 e5                	mov    %esp,%ebp
f0101f19:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0101f1c:	b8 15 00 00 00       	mov    $0x15,%eax
f0101f21:	e8 be ff ff ff       	call   f0101ee4 <nvram_read>
f0101f26:	c1 e0 0a             	shl    $0xa,%eax
f0101f29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101f2e:	a3 4c b4 15 f0       	mov    %eax,0xf015b44c
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0101f33:	b8 17 00 00 00       	mov    $0x17,%eax
f0101f38:	e8 a7 ff ff ff       	call   f0101ee4 <nvram_read>
f0101f3d:	c1 e0 0a             	shl    $0xa,%eax
f0101f40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101f45:	a3 50 b4 15 f0       	mov    %eax,0xf015b450

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0101f4a:	85 c0                	test   %eax,%eax
f0101f4c:	74 0c                	je     f0101f5a <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0101f4e:	05 00 00 10 00       	add    $0x100000,%eax
f0101f53:	a3 48 b4 15 f0       	mov    %eax,0xf015b448
f0101f58:	eb 0a                	jmp    f0101f64 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0101f5a:	a1 4c b4 15 f0       	mov    0xf015b44c,%eax
f0101f5f:	a3 48 b4 15 f0       	mov    %eax,0xf015b448

	npage = maxpa / PGSIZE;
f0101f64:	a1 48 b4 15 f0       	mov    0xf015b448,%eax
f0101f69:	89 c2                	mov    %eax,%edx
f0101f6b:	c1 ea 0c             	shr    $0xc,%edx
f0101f6e:	89 15 00 c1 15 f0    	mov    %edx,0xf015c100

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0101f74:	c1 e8 0a             	shr    $0xa,%eax
f0101f77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f7b:	c7 04 24 c8 4b 10 f0 	movl   $0xf0104bc8,(%esp)
f0101f82:	e8 88 09 00 00       	call   f010290f <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0101f87:	a1 50 b4 15 f0       	mov    0xf015b450,%eax
f0101f8c:	c1 e8 0a             	shr    $0xa,%eax
f0101f8f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101f93:	a1 4c b4 15 f0       	mov    0xf015b44c,%eax
f0101f98:	c1 e8 0a             	shr    $0xa,%eax
f0101f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f9f:	c7 04 24 1f 4d 10 f0 	movl   $0xf0104d1f,(%esp)
f0101fa6:	e8 64 09 00 00       	call   f010290f <cprintf>
}
f0101fab:	c9                   	leave  
f0101fac:	c3                   	ret    

f0101fad <page_init>:
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc() or the related boot-time functions above.
//
void
page_init(void)
{
f0101fad:	55                   	push   %ebp
f0101fae:	89 e5                	mov    %esp,%ebp
f0101fb0:	56                   	push   %esi
f0101fb1:	53                   	push   %ebx
f0101fb2:	83 ec 10             	sub    $0x10,%esp
	for (i=ROUNDUP(PADDR(boot_freemem), PGSIZE)/PGSIZE; i<npage; i++) {
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}*/
	int i;
	LIST_INIT(&page_free_list);
f0101fb5:	c7 05 58 b4 15 f0 00 	movl   $0x0,0xf015b458
f0101fbc:	00 00 00 

	for (i = 0; i < npage; i ++ ) {
f0101fbf:	83 3d 00 c1 15 f0 00 	cmpl   $0x0,0xf015c100
f0101fc6:	74 66                	je     f010202e <page_init+0x81>
f0101fc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0101fcd:	ba 00 00 00 00       	mov    $0x0,%edx
		pages[i].pp_ref=0;
f0101fd2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101fd5:	c1 e0 02             	shl    $0x2,%eax
f0101fd8:	8b 0d 0c c1 15 f0    	mov    0xf015c10c,%ecx
f0101fde:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
		LIST_INSERT_HEAD(&page_free_list,&pages[i],pp_link);
f0101fe5:	8b 0d 58 b4 15 f0    	mov    0xf015b458,%ecx
f0101feb:	8b 1d 0c c1 15 f0    	mov    0xf015c10c,%ebx
f0101ff1:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
f0101ff4:	85 c9                	test   %ecx,%ecx
f0101ff6:	74 11                	je     f0102009 <page_init+0x5c>
f0101ff8:	89 c3                	mov    %eax,%ebx
f0101ffa:	03 1d 0c c1 15 f0    	add    0xf015c10c,%ebx
f0102000:	8b 0d 58 b4 15 f0    	mov    0xf015b458,%ecx
f0102006:	89 59 04             	mov    %ebx,0x4(%ecx)
f0102009:	03 05 0c c1 15 f0    	add    0xf015c10c,%eax
f010200f:	a3 58 b4 15 f0       	mov    %eax,0xf015b458
f0102014:	c7 40 04 58 b4 15 f0 	movl   $0xf015b458,0x4(%eax)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}*/
	int i;
	LIST_INIT(&page_free_list);

	for (i = 0; i < npage; i ++ ) {
f010201b:	83 c2 01             	add    $0x1,%edx
f010201e:	89 d0                	mov    %edx,%eax
f0102020:	8b 0d 00 c1 15 f0    	mov    0xf015c100,%ecx
f0102026:	39 d1                	cmp    %edx,%ecx
f0102028:	77 a8                	ja     f0101fd2 <page_init+0x25>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010202a:	85 c9                	test   %ecx,%ecx
f010202c:	75 1c                	jne    f010204a <page_init+0x9d>
		panic("pa2page called with invalid pa");
f010202e:	c7 44 24 08 e4 47 10 	movl   $0xf01047e4,0x8(%esp)
f0102035:	f0 
f0102036:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f010203d:	00 
f010203e:	c7 04 24 f5 4b 10 f0 	movl   $0xf0104bf5,(%esp)
f0102045:	e8 36 e0 ff ff       	call   f0100080 <_panic>
	return &pages[PPN(pa)];
f010204a:	a1 0c c1 15 f0       	mov    0xf015c10c,%eax
		pages[i].pp_ref=0;
		LIST_INSERT_HEAD(&page_free_list,&pages[i],pp_link);
	}
	struct Page *pp;
	pp=pa2page(0);
	LIST_REMOVE(pp,pp_link);
f010204f:	8b 10                	mov    (%eax),%edx
f0102051:	85 d2                	test   %edx,%edx
f0102053:	74 06                	je     f010205b <page_init+0xae>
f0102055:	8b 48 04             	mov    0x4(%eax),%ecx
f0102058:	89 4a 04             	mov    %ecx,0x4(%edx)
f010205b:	8b 50 04             	mov    0x4(%eax),%edx
f010205e:	8b 08                	mov    (%eax),%ecx
f0102060:	89 0a                	mov    %ecx,(%edx)
	pp->pp_ref++;
f0102062:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	physaddr_t pa;

	for (pa = IOPHYSMEM; pa < (physaddr_t)(boot_freemem-KERNBASE); pa += PGSIZE) {
f0102067:	8b 1d 54 b4 15 f0    	mov    0xf015b454,%ebx
f010206d:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0102073:	81 fb 00 00 0a 00    	cmp    $0xa0000,%ebx
f0102079:	76 6f                	jbe    f01020ea <page_init+0x13d>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010207b:	81 3d 00 c1 15 f0 a0 	cmpl   $0xa0,0xf015c100
f0102082:	00 00 00 
f0102085:	77 2b                	ja     f01020b2 <page_init+0x105>
f0102087:	eb 0d                	jmp    f0102096 <page_init+0xe9>
f0102089:	89 d0                	mov    %edx,%eax
f010208b:	c1 e8 0c             	shr    $0xc,%eax
f010208e:	3b 05 00 c1 15 f0    	cmp    0xf015c100,%eax
f0102094:	72 26                	jb     f01020bc <page_init+0x10f>
		panic("pa2page called with invalid pa");
f0102096:	c7 44 24 08 e4 47 10 	movl   $0xf01047e4,0x8(%esp)
f010209d:	f0 
f010209e:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f01020a5:	00 
f01020a6:	c7 04 24 f5 4b 10 f0 	movl   $0xf0104bf5,(%esp)
f01020ad:	e8 ce df ff ff       	call   f0100080 <_panic>
f01020b2:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01020b7:	ba 00 00 0a 00       	mov    $0xa0000,%edx
	return &pages[PPN(pa)];
f01020bc:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01020bf:	c1 e0 02             	shl    $0x2,%eax
f01020c2:	03 05 0c c1 15 f0    	add    0xf015c10c,%eax
		pp=pa2page(pa);
		LIST_REMOVE(pp,pp_link);
f01020c8:	8b 08                	mov    (%eax),%ecx
f01020ca:	85 c9                	test   %ecx,%ecx
f01020cc:	74 06                	je     f01020d4 <page_init+0x127>
f01020ce:	8b 70 04             	mov    0x4(%eax),%esi
f01020d1:	89 71 04             	mov    %esi,0x4(%ecx)
f01020d4:	8b 48 04             	mov    0x4(%eax),%ecx
f01020d7:	8b 30                	mov    (%eax),%esi
f01020d9:	89 31                	mov    %esi,(%ecx)
		pp->pp_ref++;
f01020db:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	pp=pa2page(0);
	LIST_REMOVE(pp,pp_link);
	pp->pp_ref++;
	physaddr_t pa;

	for (pa = IOPHYSMEM; pa < (physaddr_t)(boot_freemem-KERNBASE); pa += PGSIZE) {
f01020e0:	81 c2 00 10 00 00    	add    $0x1000,%edx
f01020e6:	39 da                	cmp    %ebx,%edx
f01020e8:	72 9f                	jb     f0102089 <page_init+0xdc>
		pp=pa2page(pa);
		LIST_REMOVE(pp,pp_link);
		pp->pp_ref++;
	}
}
f01020ea:	83 c4 10             	add    $0x10,%esp
f01020ed:	5b                   	pop    %ebx
f01020ee:	5e                   	pop    %esi
f01020ef:	5d                   	pop    %ebp
f01020f0:	c3                   	ret    
	...

f0102100 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102100:	55                   	push   %ebp
f0102101:	89 e5                	mov    %esp,%ebp
f0102103:	53                   	push   %ebx
f0102104:	8b 45 08             	mov    0x8(%ebp),%eax
f0102107:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010210a:	85 c0                	test   %eax,%eax
f010210c:	75 0e                	jne    f010211c <envid2env+0x1c>
		*env_store = curenv;
f010210e:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0102113:	89 01                	mov    %eax,(%ecx)
f0102115:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f010211a:	eb 54                	jmp    f0102170 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010211c:	89 c2                	mov    %eax,%edx
f010211e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102124:	6b d2 64             	imul   $0x64,%edx,%edx
f0102127:	03 15 60 b4 15 f0    	add    0xf015b460,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010212d:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102131:	74 05                	je     f0102138 <envid2env+0x38>
f0102133:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0102136:	74 0d                	je     f0102145 <envid2env+0x45>
		*env_store = 0;
f0102138:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f010213e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0102143:	eb 2b                	jmp    f0102170 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102145:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102149:	74 1e                	je     f0102169 <envid2env+0x69>
f010214b:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0102150:	39 c2                	cmp    %eax,%edx
f0102152:	74 15                	je     f0102169 <envid2env+0x69>
f0102154:	8b 5a 50             	mov    0x50(%edx),%ebx
f0102157:	3b 58 4c             	cmp    0x4c(%eax),%ebx
f010215a:	74 0d                	je     f0102169 <envid2env+0x69>
		*env_store = 0;
f010215c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0102162:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0102167:	eb 07                	jmp    f0102170 <envid2env+0x70>
	}

	*env_store = e;
f0102169:	89 11                	mov    %edx,(%ecx)
f010216b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0102170:	5b                   	pop    %ebx
f0102171:	5d                   	pop    %ebp
f0102172:	c3                   	ret    

f0102173 <env_init>:
// returns envs[0].
////////////////////////////////////////////////////////////////////////////////////////

void
env_init(void)
{
f0102173:	55                   	push   %ebp
f0102174:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
	LIST_INIT(&env_free_list);
f0102176:	c7 05 68 b4 15 f0 00 	movl   $0x0,0xf015b468
f010217d:	00 00 00 
f0102180:	b8 9c 8f 01 00       	mov    $0x18f9c,%eax
	int i = NENV;
	while(i--)
	{
		envs[i].env_id = 0;
f0102185:	8b 15 60 b4 15 f0    	mov    0xf015b460,%edx
f010218b:	c7 44 02 4c 00 00 00 	movl   $0x0,0x4c(%edx,%eax,1)
f0102192:	00 
		envs[i].env_status = ENV_FREE;
f0102193:	8b 15 60 b4 15 f0    	mov    0xf015b460,%edx
f0102199:	c7 44 02 54 00 00 00 	movl   $0x0,0x54(%edx,%eax,1)
f01021a0:	00 
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);	
f01021a1:	8b 15 68 b4 15 f0    	mov    0xf015b468,%edx
f01021a7:	8b 0d 60 b4 15 f0    	mov    0xf015b460,%ecx
f01021ad:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
f01021b1:	85 d2                	test   %edx,%edx
f01021b3:	74 14                	je     f01021c9 <env_init+0x56>
f01021b5:	89 c1                	mov    %eax,%ecx
f01021b7:	03 0d 60 b4 15 f0    	add    0xf015b460,%ecx
f01021bd:	83 c1 44             	add    $0x44,%ecx
f01021c0:	8b 15 68 b4 15 f0    	mov    0xf015b468,%edx
f01021c6:	89 4a 48             	mov    %ecx,0x48(%edx)
f01021c9:	89 c2                	mov    %eax,%edx
f01021cb:	03 15 60 b4 15 f0    	add    0xf015b460,%edx
f01021d1:	89 15 68 b4 15 f0    	mov    %edx,0xf015b468
f01021d7:	c7 42 48 68 b4 15 f0 	movl   $0xf015b468,0x48(%edx)
f01021de:	83 e8 64             	sub    $0x64,%eax
env_init(void)
{
	// LAB 3: Your code here.
	LIST_INIT(&env_free_list);
	int i = NENV;
	while(i--)
f01021e1:	83 f8 9c             	cmp    $0xffffff9c,%eax
f01021e4:	75 9f                	jne    f0102185 <env_init+0x12>
		envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);	
	}
	return;
}
f01021e6:	5d                   	pop    %ebp
f01021e7:	c3                   	ret    

f01021e8 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01021e8:	55                   	push   %ebp
f01021e9:	89 e5                	mov    %esp,%ebp
f01021eb:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01021ee:	8b 65 08             	mov    0x8(%ebp),%esp
f01021f1:	61                   	popa   
f01021f2:	07                   	pop    %es
f01021f3:	1f                   	pop    %ds
f01021f4:	83 c4 08             	add    $0x8,%esp
f01021f7:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01021f8:	c7 44 24 08 3b 4d 10 	movl   $0xf0104d3b,0x8(%esp)
f01021ff:	f0 
f0102200:	c7 44 24 04 ce 01 00 	movl   $0x1ce,0x4(%esp)
f0102207:	00 
f0102208:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f010220f:	e8 6c de ff ff       	call   f0100080 <_panic>

f0102214 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0102214:	55                   	push   %ebp
f0102215:	89 e5                	mov    %esp,%ebp
f0102217:	83 ec 18             	sub    $0x18,%esp
f010221a:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.
	curenv = e;
f010221d:	a3 64 b4 15 f0       	mov    %eax,0xf015b464
	curenv->env_runs++;
f0102222:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(curenv->env_cr3);
f0102226:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f010222b:	8b 50 60             	mov    0x60(%eax),%edx
f010222e:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&(curenv -> env_tf));
f0102231:	89 04 24             	mov    %eax,(%esp)
f0102234:	e8 af ff ff ff       	call   f01021e8 <env_pop_tf>

f0102239 <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0102239:	55                   	push   %ebp
f010223a:	89 e5                	mov    %esp,%ebp
f010223c:	57                   	push   %edi
f010223d:	56                   	push   %esi
f010223e:	53                   	push   %ebx
f010223f:	83 ec 2c             	sub    $0x2c,%esp
f0102242:	8b 7d 08             	mov    0x8(%ebp),%edi
	pte_t *pt;
	uint32_t pdeno, pteno;
	physaddr_t pa;

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102245:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0102248:	8b 15 64 b4 15 f0    	mov    0xf015b464,%edx
f010224e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102253:	85 d2                	test   %edx,%edx
f0102255:	74 03                	je     f010225a <env_free+0x21>
f0102257:	8b 42 4c             	mov    0x4c(%edx),%eax
f010225a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010225e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102262:	c7 04 24 52 4d 10 f0 	movl   $0xf0104d52,(%esp)
f0102269:	e8 a1 06 00 00       	call   f010290f <cprintf>
f010226e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102275:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102278:	c1 e0 02             	shl    $0x2,%eax
f010227b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010227e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102281:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102284:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0102287:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010228d:	0f 84 bb 00 00 00    	je     f010234e <env_free+0x115>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102293:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0102299:	89 f0                	mov    %esi,%eax
f010229b:	c1 e8 0c             	shr    $0xc,%eax
f010229e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01022a1:	3b 05 00 c1 15 f0    	cmp    0xf015c100,%eax
f01022a7:	72 20                	jb     f01022c9 <env_free+0x90>
f01022a9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01022ad:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f01022b4:	f0 
f01022b5:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f01022bc:	00 
f01022bd:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f01022c4:	e8 b7 dd ff ff       	call   f0100080 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01022c9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01022cc:	c1 e2 16             	shl    $0x16,%edx
f01022cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01022d2:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f01022d7:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01022de:	01 
f01022df:	74 17                	je     f01022f8 <env_free+0xbf>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01022e1:	89 d8                	mov    %ebx,%eax
f01022e3:	c1 e0 0c             	shl    $0xc,%eax
f01022e6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01022e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022ed:	8b 47 5c             	mov    0x5c(%edi),%eax
f01022f0:	89 04 24             	mov    %eax,(%esp)
f01022f3:	e8 6a ec ff ff       	call   f0100f62 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01022f8:	83 c3 01             	add    $0x1,%ebx
f01022fb:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102301:	75 d4                	jne    f01022d7 <env_free+0x9e>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102303:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102306:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102309:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102310:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102313:	3b 05 00 c1 15 f0    	cmp    0xf015c100,%eax
f0102319:	72 1c                	jb     f0102337 <env_free+0xfe>
		panic("pa2page called with invalid pa");
f010231b:	c7 44 24 08 e4 47 10 	movl   $0xf01047e4,0x8(%esp)
f0102322:	f0 
f0102323:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f010232a:	00 
f010232b:	c7 04 24 f5 4b 10 f0 	movl   $0xf0104bf5,(%esp)
f0102332:	e8 49 dd ff ff       	call   f0100080 <_panic>
		page_decref(pa2page(pa));
f0102337:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010233a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010233d:	c1 e0 02             	shl    $0x2,%eax
f0102340:	03 05 0c c1 15 f0    	add    0xf015c10c,%eax
f0102346:	89 04 24             	mov    %eax,(%esp)
f0102349:	e8 3c e7 ff ff       	call   f0100a8a <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010234e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102352:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102359:	0f 85 16 ff ff ff    	jne    f0102275 <env_free+0x3c>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f010235f:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0102362:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0102369:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102370:	c1 e8 0c             	shr    $0xc,%eax
f0102373:	3b 05 00 c1 15 f0    	cmp    0xf015c100,%eax
f0102379:	72 1c                	jb     f0102397 <env_free+0x15e>
		panic("pa2page called with invalid pa");
f010237b:	c7 44 24 08 e4 47 10 	movl   $0xf01047e4,0x8(%esp)
f0102382:	f0 
f0102383:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f010238a:	00 
f010238b:	c7 04 24 f5 4b 10 f0 	movl   $0xf0104bf5,(%esp)
f0102392:	e8 e9 dc ff ff       	call   f0100080 <_panic>
	page_decref(pa2page(pa));
f0102397:	6b c0 0c             	imul   $0xc,%eax,%eax
f010239a:	03 05 0c c1 15 f0    	add    0xf015c10c,%eax
f01023a0:	89 04 24             	mov    %eax,(%esp)
f01023a3:	e8 e2 e6 ff ff       	call   f0100a8a <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01023a8:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f01023af:	a1 68 b4 15 f0       	mov    0xf015b468,%eax
f01023b4:	89 47 44             	mov    %eax,0x44(%edi)
f01023b7:	85 c0                	test   %eax,%eax
f01023b9:	74 0b                	je     f01023c6 <env_free+0x18d>
f01023bb:	8d 57 44             	lea    0x44(%edi),%edx
f01023be:	a1 68 b4 15 f0       	mov    0xf015b468,%eax
f01023c3:	89 50 48             	mov    %edx,0x48(%eax)
f01023c6:	89 3d 68 b4 15 f0    	mov    %edi,0xf015b468
f01023cc:	c7 47 48 68 b4 15 f0 	movl   $0xf015b468,0x48(%edi)
}
f01023d3:	83 c4 2c             	add    $0x2c,%esp
f01023d6:	5b                   	pop    %ebx
f01023d7:	5e                   	pop    %esi
f01023d8:	5f                   	pop    %edi
f01023d9:	5d                   	pop    %ebp
f01023da:	c3                   	ret    

f01023db <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f01023db:	55                   	push   %ebp
f01023dc:	89 e5                	mov    %esp,%ebp
f01023de:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01023e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01023e4:	89 04 24             	mov    %eax,(%esp)
f01023e7:	e8 4d fe ff ff       	call   f0102239 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01023ec:	c7 04 24 b8 4d 10 f0 	movl   $0xf0104db8,(%esp)
f01023f3:	e8 17 05 00 00       	call   f010290f <cprintf>
	while (1)
		monitor(NULL);
f01023f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023ff:	e8 9c e3 ff ff       	call   f01007a0 <monitor>
f0102404:	eb f2                	jmp    f01023f8 <env_destroy+0x1d>

f0102406 <segment_alloc>:

//////////////////////////////////////////////////////////////////////////////////////
// 从地址 va 开始分配 len 字节的空间
static void
segment_alloc(struct Env *e, void *va, size_t len)
{
f0102406:	55                   	push   %ebp
f0102407:	89 e5                	mov    %esp,%ebp
f0102409:	57                   	push   %edi
f010240a:	56                   	push   %esi
f010240b:	53                   	push   %ebx
f010240c:	83 ec 2c             	sub    $0x2c,%esp
f010240f:	89 c6                	mov    %eax,%esi
	// (But only if you need it for load_icode.)
	//
	// Hint: It is easier to use segment_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round len up.
	void* end = ROUNDUP((char*)va + len, PGSIZE);
f0102411:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
	va = ROUNDDOWN(va, PGSIZE);
	if (va == NULL) 
f0102418:	89 d3                	mov    %edx,%ebx
f010241a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102420:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102425:	0f 44 d8             	cmove  %eax,%ebx
		va += PGSIZE;
	len = (char*)end - (char*)va;
f0102428:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	struct Page *pp;
	for (; len > 0; len -= PGSIZE, va += PGSIZE) 
f010242e:	29 df                	sub    %ebx,%edi
f0102430:	0f 84 84 00 00 00    	je     f01024ba <segment_alloc+0xb4>
	{
		int r;
        if ((r = page_alloc(&pp)) < 0) 
f0102436:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102439:	89 04 24             	mov    %eax,(%esp)
f010243c:	e8 32 e8 ff ff       	call   f0100c73 <page_alloc>
f0102441:	85 c0                	test   %eax,%eax
f0102443:	79 20                	jns    f0102465 <segment_alloc+0x5f>
        	panic("segment_alloc: %e", r);
f0102445:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102449:	c7 44 24 08 68 4d 10 	movl   $0xf0104d68,0x8(%esp)
f0102450:	f0 
f0102451:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f0102458:	00 
f0102459:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f0102460:	e8 1b dc ff ff       	call   f0100080 <_panic>
        if ((r = page_insert(e->env_pgdir, pp, va, PTE_W | PTE_U)) < 0) 
f0102465:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010246c:	00 
f010246d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102471:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102474:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102478:	8b 46 5c             	mov    0x5c(%esi),%eax
f010247b:	89 04 24             	mov    %eax,(%esp)
f010247e:	e8 2f eb ff ff       	call   f0100fb2 <page_insert>
f0102483:	85 c0                	test   %eax,%eax
f0102485:	79 20                	jns    f01024a7 <segment_alloc+0xa1>
        	panic("segment_alloc: %e", r);
f0102487:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010248b:	c7 44 24 08 68 4d 10 	movl   $0xf0104d68,0x8(%esp)
f0102492:	f0 
f0102493:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
f010249a:	00 
f010249b:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f01024a2:	e8 d9 db ff ff       	call   f0100080 <_panic>
	va = ROUNDDOWN(va, PGSIZE);
	if (va == NULL) 
		va += PGSIZE;
	len = (char*)end - (char*)va;
	struct Page *pp;
	for (; len > 0; len -= PGSIZE, va += PGSIZE) 
f01024a7:	81 ef 00 10 00 00    	sub    $0x1000,%edi
f01024ad:	74 0b                	je     f01024ba <segment_alloc+0xb4>
f01024af:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01024b5:	e9 7c ff ff ff       	jmp    f0102436 <segment_alloc+0x30>
        if ((r = page_alloc(&pp)) < 0) 
        	panic("segment_alloc: %e", r);
        if ((r = page_insert(e->env_pgdir, pp, va, PTE_W | PTE_U)) < 0) 
        	panic("segment_alloc: %e", r);
	}
}
f01024ba:	83 c4 2c             	add    $0x2c,%esp
f01024bd:	5b                   	pop    %ebx
f01024be:	5e                   	pop    %esi
f01024bf:	5f                   	pop    %edi
f01024c0:	5d                   	pop    %ebp
f01024c1:	c3                   	ret    

f01024c2 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01024c2:	55                   	push   %ebp
f01024c3:	89 e5                	mov    %esp,%ebp
f01024c5:	53                   	push   %ebx
f01024c6:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f01024c9:	8b 1d 68 b4 15 f0    	mov    0xf015b468,%ebx
f01024cf:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01024d4:	85 db                	test   %ebx,%ebx
f01024d6:	0f 84 95 01 00 00    	je     f0102671 <env_alloc+0x1af>
// 映射到新环境的页目录,以便新环境可以通过某些形式访问内核。
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f01024dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f01024e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01024e6:	89 04 24             	mov    %eax,(%esp)
f01024e9:	e8 85 e7 ff ff       	call   f0100c73 <page_alloc>
f01024ee:	85 c0                	test   %eax,%eax
f01024f0:	0f 88 7b 01 00 00    	js     f0102671 <env_alloc+0x1af>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01024f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01024f9:	2b 05 0c c1 15 f0    	sub    0xf015c10c,%eax
f01024ff:	c1 f8 02             	sar    $0x2,%eax
f0102502:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102508:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f010250b:	89 c2                	mov    %eax,%edx
f010250d:	c1 ea 0c             	shr    $0xc,%edx
f0102510:	3b 15 00 c1 15 f0    	cmp    0xf015c100,%edx
f0102516:	72 20                	jb     f0102538 <env_alloc+0x76>
f0102518:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010251c:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f0102523:	f0 
f0102524:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
f010252b:	00 
f010252c:	c7 04 24 f5 4b 10 f0 	movl   $0xf0104bf5,(%esp)
f0102533:	e8 48 db ff ff       	call   f0100080 <_panic>
	//	mapped above UTOP -- but you do need to increment
	//	env_pgdir's pp_ref!

	// LAB 3: Your code here.
	
	e->env_pgdir = page2kva (p);
f0102538:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010253d:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_cr3 = page2pa (p);
f0102540:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102543:	2b 15 0c c1 15 f0    	sub    0xf015c10c,%edx
f0102549:	c1 fa 02             	sar    $0x2,%edx
f010254c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102552:	c1 e2 0c             	shl    $0xc,%edx
f0102555:	89 53 60             	mov    %edx,0x60(%ebx)

	memmove (e->env_pgdir, boot_pgdir, PGSIZE);
f0102558:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010255f:	00 
f0102560:	8b 15 08 c1 15 f0    	mov    0xf015c108,%edx
f0102566:	89 54 24 04          	mov    %edx,0x4(%esp)
f010256a:	89 04 24             	mov    %eax,(%esp)
f010256d:	e8 a1 18 00 00       	call   f0103e13 <memmove>
 	memset (e->env_pgdir, 0, PDX(UTOP) * sizeof (pde_t));
f0102572:	c7 44 24 08 ec 0e 00 	movl   $0xeec,0x8(%esp)
f0102579:	00 
f010257a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102581:	00 
f0102582:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102585:	89 04 24             	mov    %eax,(%esp)
f0102588:	e8 39 18 00 00       	call   f0103dc6 <memset>
	p->pp_ref ++;
f010258d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102590:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	//unsigned int offset = UTOP / (4*1024*1024);
	//memmove(e->env_pgdir + offset, boot_pgdir + offset, (NPDENTRIES-PDX(UTOP))* sizeof(pde_t));

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0102595:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102598:	8b 53 60             	mov    0x60(%ebx),%edx
f010259b:	83 ca 03             	or     $0x3,%edx
f010259e:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f01025a4:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01025a7:	8b 53 60             	mov    0x60(%ebx),%edx
f01025aa:	83 ca 05             	or     $0x5,%edx
f01025ad:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01025b3:	8b 43 4c             	mov    0x4c(%ebx),%eax
f01025b6:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01025bb:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01025c0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025c5:	0f 4e c2             	cmovle %edx,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01025c8:	89 da                	mov    %ebx,%edx
f01025ca:	2b 15 60 b4 15 f0    	sub    0xf015b460,%edx
f01025d0:	c1 fa 02             	sar    $0x2,%edx
f01025d3:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f01025d9:	09 d0                	or     %edx,%eax
f01025db:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01025de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01025e1:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01025e4:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f01025eb:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01025f2:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01025f9:	00 
f01025fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102601:	00 
f0102602:	89 1c 24             	mov    %ebx,(%esp)
f0102605:	e8 bc 17 00 00       	call   f0103dc6 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f010260a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102610:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102616:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010261c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102623:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0102629:	8b 43 44             	mov    0x44(%ebx),%eax
f010262c:	85 c0                	test   %eax,%eax
f010262e:	74 06                	je     f0102636 <env_alloc+0x174>
f0102630:	8b 53 48             	mov    0x48(%ebx),%edx
f0102633:	89 50 48             	mov    %edx,0x48(%eax)
f0102636:	8b 43 48             	mov    0x48(%ebx),%eax
f0102639:	8b 53 44             	mov    0x44(%ebx),%edx
f010263c:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f010263e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102641:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102643:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0102646:	8b 15 64 b4 15 f0    	mov    0xf015b464,%edx
f010264c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102651:	85 d2                	test   %edx,%edx
f0102653:	74 03                	je     f0102658 <env_alloc+0x196>
f0102655:	8b 42 4c             	mov    0x4c(%edx),%eax
f0102658:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010265c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102660:	c7 04 24 7a 4d 10 f0 	movl   $0xf0104d7a,(%esp)
f0102667:	e8 a3 02 00 00       	call   f010290f <cprintf>
f010266c:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0102671:	83 c4 24             	add    $0x24,%esp
f0102674:	5b                   	pop    %ebx
f0102675:	5d                   	pop    %ebp
f0102676:	c3                   	ret    

f0102677 <env_create>:
// 从空闲链表拿出一个新的 env,然后初始化。
// 把应用程序放到指定的虚拟内存上去。

void
env_create(uint8_t *binary, size_t size)
{
f0102677:	55                   	push   %ebp
f0102678:	89 e5                	mov    %esp,%ebp
f010267a:	57                   	push   %edi
f010267b:	56                   	push   %esi
f010267c:	53                   	push   %ebx
f010267d:	83 ec 7c             	sub    $0x7c,%esp
	// LAB 3: Your code here.
	struct Env *env;
	env_alloc(&env, 0);
f0102680:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102687:	00 
f0102688:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010268b:	89 04 24             	mov    %eax,(%esp)
f010268e:	e8 2f fe ff ff       	call   f01024c2 <env_alloc>
	load_icode(env, binary, size);
f0102693:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102696:	89 45 b8             	mov    %eax,-0x48(%ebp)
	// Hint:
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)
	// LAB 3: Your code here.
  struct Elf *elf = (struct Elf *)binary;
f0102699:	8b 55 08             	mov    0x8(%ebp),%edx
f010269c:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  struct Proghdr *ph, *eph;
  int i,j;
  struct Page *p;
  pte_t* pte;

  if(elf->e_magic != ELF_MAGIC)
f010269f:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f01026a5:	74 1c                	je     f01026c3 <env_create+0x4c>
  panic("elf->e_magic erro\n");
f01026a7:	c7 44 24 08 8f 4d 10 	movl   $0xf0104d8f,0x8(%esp)
f01026ae:	f0 
f01026af:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f01026b6:	00 
f01026b7:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f01026be:	e8 bd d9 ff ff       	call   f0100080 <_panic>
  // program header
  ph = (struct Proghdr *)(binary + elf->e_phoff);
f01026c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01026c6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f01026c9:	03 59 1c             	add    0x1c(%ecx),%ebx
f01026cc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  // one after last program header
  eph = ph + elf->e_phnum;
f01026cf:	0f b7 41 2c          	movzwl 0x2c(%ecx),%eax
f01026d3:	c1 e0 05             	shl    $0x5,%eax
f01026d6:	01 d8                	add    %ebx,%eax
f01026d8:	89 45 bc             	mov    %eax,-0x44(%ebp)
  // For each program header, load it into memory, zeroing as necessary
  for(; ph < eph; ph++) {
f01026db:	39 c3                	cmp    %eax,%ebx
f01026dd:	0f 83 aa 01 00 00    	jae    f010288d <env_create+0x216>
      offset = ph->p_va - (int)origin_va;
      page_num = ROUNDUP(ph->p_filesz + offset, PGSIZE) / PGSIZE;
      copyed_byte = 0;
      filesz = ph->p_filesz;
      for (j = 0; j < page_num; j++) {
        va = (uint8_t *)(KADDR(PTE_ADDR(pte[PTX(origin_va)])) + offset);
f01026e3:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  ph = (struct Proghdr *)(binary + elf->e_phoff);
  // one after last program header
  eph = ph + elf->e_phnum;
  // For each program header, load it into memory, zeroing as necessary
  for(; ph < eph; ph++) {
    if (ph->p_type == ELF_PROG_LOAD) {
f01026ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01026ed:	83 3f 01             	cmpl   $0x1,(%edi)
f01026f0:	0f 85 87 01 00 00    	jne    f010287d <env_create+0x206>
    // map segment
      segment_alloc(e, (uintptr_t *)(ph->p_va), ph->p_memsz);
f01026f6:	8b 4f 14             	mov    0x14(%edi),%ecx
f01026f9:	8b 57 08             	mov    0x8(%edi),%edx
f01026fc:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01026ff:	e8 02 fd ff ff       	call   f0102406 <segment_alloc>
      pte =(pte_t*)KADDR(PTE_ADDR(e->env_pgdir[PDX(ph->p_va)]));
f0102704:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102707:	89 ca                	mov    %ecx,%edx
f0102709:	c1 ea 16             	shr    $0x16,%edx
f010270c:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f010270f:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102712:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0102715:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010271b:	8b 35 00 c1 15 f0    	mov    0xf015c100,%esi
f0102721:	89 d0                	mov    %edx,%eax
f0102723:	c1 e8 0c             	shr    $0xc,%eax
f0102726:	39 f0                	cmp    %esi,%eax
f0102728:	72 20                	jb     f010274a <env_create+0xd3>
f010272a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010272e:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f0102735:	f0 
f0102736:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f010273d:	00 
f010273e:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f0102745:	e8 36 d9 ff ff       	call   f0100080 <_panic>
      origin_va = (uint8_t*)ROUNDDOWN(ph->p_va, PGSIZE);
f010274a:	89 cf                	mov    %ecx,%edi
f010274c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102752:	89 7d cc             	mov    %edi,-0x34(%ebp)
      offset = ph->p_va - (int)origin_va;
f0102755:	29 f9                	sub    %edi,%ecx
      page_num = ROUNDUP(ph->p_filesz + offset, PGSIZE) / PGSIZE;
f0102757:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010275a:	8b 58 10             	mov    0x10(%eax),%ebx
f010275d:	8d 84 19 ff 0f 00 00 	lea    0xfff(%ecx,%ebx,1),%eax
f0102764:	c1 e8 0c             	shr    $0xc,%eax
f0102767:	89 45 c8             	mov    %eax,-0x38(%ebp)
      copyed_byte = 0;
      filesz = ph->p_filesz;
      for (j = 0; j < page_num; j++) {
f010276a:	bf 00 00 00 00       	mov    $0x0,%edi
f010276f:	85 c0                	test   %eax,%eax
f0102771:	0f 8e e2 00 00 00    	jle    f0102859 <env_create+0x1e2>
  // For each program header, load it into memory, zeroing as necessary
  for(; ph < eph; ph++) {
    if (ph->p_type == ELF_PROG_LOAD) {
    // map segment
      segment_alloc(e, (uintptr_t *)(ph->p_va), ph->p_memsz);
      pte =(pte_t*)KADDR(PTE_ADDR(e->env_pgdir[PDX(ph->p_va)]));
f0102777:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010277d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
      offset = ph->p_va - (int)origin_va;
      page_num = ROUNDUP(ph->p_filesz + offset, PGSIZE) / PGSIZE;
      copyed_byte = 0;
      filesz = ph->p_filesz;
      for (j = 0; j < page_num; j++) {
        va = (uint8_t *)(KADDR(PTE_ADDR(pte[PTX(origin_va)])) + offset);
f0102780:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102783:	c1 e8 0c             	shr    $0xc,%eax
f0102786:	25 ff 03 00 00       	and    $0x3ff,%eax
f010278b:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010278e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102794:	89 d0                	mov    %edx,%eax
f0102796:	c1 e8 0c             	shr    $0xc,%eax
f0102799:	39 c6                	cmp    %eax,%esi
f010279b:	77 59                	ja     f01027f6 <env_create+0x17f>
f010279d:	eb 37                	jmp    f01027d6 <env_create+0x15f>
f010279f:	89 f0                	mov    %esi,%eax
f01027a1:	c1 e0 0c             	shl    $0xc,%eax
f01027a4:	03 45 cc             	add    -0x34(%ebp),%eax
f01027a7:	c1 e8 0c             	shr    $0xc,%eax
f01027aa:	25 ff 03 00 00       	and    $0x3ff,%eax
f01027af:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01027b2:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f01027b5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01027bb:	89 55 94             	mov    %edx,-0x6c(%ebp)
f01027be:	89 d0                	mov    %edx,%eax
f01027c0:	c1 e8 0c             	shr    $0xc,%eax
f01027c3:	3b 05 00 c1 15 f0    	cmp    0xf015c100,%eax
f01027c9:	73 08                	jae    f01027d3 <env_create+0x15c>
f01027cb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01027ce:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01027d1:	eb 32                	jmp    f0102805 <env_create+0x18e>
f01027d3:	8b 55 94             	mov    -0x6c(%ebp),%edx
f01027d6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01027da:	c7 44 24 08 64 47 10 	movl   $0xf0104764,0x8(%esp)
f01027e1:	f0 
f01027e2:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
f01027e9:	00 
f01027ea:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f01027f1:	e8 8a d8 ff ff       	call   f0100080 <_panic>
    if (ph->p_type == ELF_PROG_LOAD) {
    // map segment
      segment_alloc(e, (uintptr_t *)(ph->p_va), ph->p_memsz);
      pte =(pte_t*)KADDR(PTE_ADDR(e->env_pgdir[PDX(ph->p_va)]));
      origin_va = (uint8_t*)ROUNDDOWN(ph->p_va, PGSIZE);
      offset = ph->p_va - (int)origin_va;
f01027f6:	89 c8                	mov    %ecx,%eax
      page_num = ROUNDUP(ph->p_filesz + offset, PGSIZE) / PGSIZE;
      copyed_byte = 0;
      filesz = ph->p_filesz;
f01027f8:	be 00 00 00 00       	mov    $0x0,%esi
f01027fd:	bf 00 00 00 00       	mov    $0x0,%edi
      for (j = 0; j < page_num; j++) {
        va = (uint8_t *)(KADDR(PTE_ADDR(pte[PTX(origin_va)])) + offset);
        origin_va += PGSIZE;
				if ((filesz + offset) > PGSIZE) {
          filesz -= PGSIZE - offset;
          byte_num = PGSIZE - offset;
f0102802:	89 55 94             	mov    %edx,-0x6c(%ebp)
      copyed_byte = 0;
      filesz = ph->p_filesz;
      for (j = 0; j < page_num; j++) {
        va = (uint8_t *)(KADDR(PTE_ADDR(pte[PTX(origin_va)])) + offset);
        origin_va += PGSIZE;
				if ((filesz + offset) > PGSIZE) {
f0102805:	8d 0c 03             	lea    (%ebx,%eax,1),%ecx
f0102808:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010280b:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0102811:	7e 10                	jle    f0102823 <env_create+0x1ac>
          filesz -= PGSIZE - offset;
f0102813:	81 e9 00 10 00 00    	sub    $0x1000,%ecx
f0102819:	89 4d d0             	mov    %ecx,-0x30(%ebp)
          byte_num = PGSIZE - offset;
f010281c:	bb 00 10 00 00       	mov    $0x1000,%ebx
f0102821:	29 c3                	sub    %eax,%ebx
        else {
          byte_num = filesz;
        }

        offset = 0;
        memcpy(va, binary + ph->p_offset + copyed_byte, byte_num);
f0102823:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102827:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010282a:	8b 4a 04             	mov    0x4(%edx),%ecx
f010282d:	01 f9                	add    %edi,%ecx
f010282f:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0102832:	03 4d 08             	add    0x8(%ebp),%ecx
f0102835:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0102839:	8b 55 94             	mov    -0x6c(%ebp),%edx
f010283c:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0102843:	89 04 24             	mov    %eax,(%esp)
f0102846:	e8 9f 15 00 00       	call   f0103dea <memcpy>
        copyed_byte += byte_num;
f010284b:	01 df                	add    %ebx,%edi
      origin_va = (uint8_t*)ROUNDDOWN(ph->p_va, PGSIZE);
      offset = ph->p_va - (int)origin_va;
      page_num = ROUNDUP(ph->p_filesz + offset, PGSIZE) / PGSIZE;
      copyed_byte = 0;
      filesz = ph->p_filesz;
      for (j = 0; j < page_num; j++) {
f010284d:	83 c6 01             	add    $0x1,%esi
f0102850:	39 75 c8             	cmp    %esi,-0x38(%ebp)
f0102853:	0f 8f 46 ff ff ff    	jg     f010279f <env_create+0x128>
        offset = 0;
        memcpy(va, binary + ph->p_offset + copyed_byte, byte_num);
        copyed_byte += byte_num;
      }
      
      if (copyed_byte != ph->p_filesz)
f0102859:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010285c:	3b 79 10             	cmp    0x10(%ecx),%edi
f010285f:	74 1c                	je     f010287d <env_create+0x206>
        panic("Load_icode failed\n");
f0102861:	c7 44 24 08 a2 4d 10 	movl   $0xf0104da2,0x8(%esp)
f0102868:	f0 
f0102869:	c7 44 24 04 59 01 00 	movl   $0x159,0x4(%esp)
f0102870:	00 
f0102871:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f0102878:	e8 03 d8 ff ff       	call   f0100080 <_panic>
  // program header
  ph = (struct Proghdr *)(binary + elf->e_phoff);
  // one after last program header
  eph = ph + elf->e_phnum;
  // For each program header, load it into memory, zeroing as necessary
  for(; ph < eph; ph++) {
f010287d:	83 45 d4 20          	addl   $0x20,-0x2c(%ebp)
f0102881:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102884:	39 5d bc             	cmp    %ebx,-0x44(%ebp)
f0102887:	0f 87 5d fe ff ff    	ja     f01026ea <env_create+0x73>
        panic("Load_icode failed\n");
    }
  }
  // Set up the environment's trapframe to point to the right location
  // Other values for the trap frame as assigned in env_alloc
  e->env_tf.tf_eip = elf->e_entry;
f010288d:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0102890:	8b 47 18             	mov    0x18(%edi),%eax
f0102893:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0102896:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
  // at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
  segment_alloc(e, (uintptr_t*)(USTACKTOP - PGSIZE), PGSIZE);
f0102899:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010289e:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01028a3:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01028a6:	e8 5b fb ff ff       	call   f0102406 <segment_alloc>
	// LAB 3: Your code here.
	struct Env *env;
	env_alloc(&env, 0);
	load_icode(env, binary, size);
	return;
}
f01028ab:	83 c4 7c             	add    $0x7c,%esp
f01028ae:	5b                   	pop    %ebx
f01028af:	5e                   	pop    %esi
f01028b0:	5f                   	pop    %edi
f01028b1:	5d                   	pop    %ebp
f01028b2:	c3                   	ret    
	...

f01028b4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01028b4:	55                   	push   %ebp
f01028b5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01028b7:	ba 70 00 00 00       	mov    $0x70,%edx
f01028bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01028bf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01028c0:	b2 71                	mov    $0x71,%dl
f01028c2:	ec                   	in     (%dx),%al
f01028c3:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01028c6:	5d                   	pop    %ebp
f01028c7:	c3                   	ret    

f01028c8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01028c8:	55                   	push   %ebp
f01028c9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01028cb:	ba 70 00 00 00       	mov    $0x70,%edx
f01028d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01028d3:	ee                   	out    %al,(%dx)
f01028d4:	b2 71                	mov    $0x71,%dl
f01028d6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028d9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01028da:	5d                   	pop    %ebp
f01028db:	c3                   	ret    

f01028dc <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01028dc:	55                   	push   %ebp
f01028dd:	89 e5                	mov    %esp,%ebp
f01028df:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01028e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01028e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01028f3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01028f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01028fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01028fe:	c7 04 24 29 29 10 f0 	movl   $0xf0102929,(%esp)
f0102905:	e8 76 0d 00 00       	call   f0103680 <vprintfmt>
	return cnt;
}
f010290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010290d:	c9                   	leave  
f010290e:	c3                   	ret    

f010290f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010290f:	55                   	push   %ebp
f0102910:	89 e5                	mov    %esp,%ebp
f0102912:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0102915:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102918:	89 44 24 04          	mov    %eax,0x4(%esp)
f010291c:	8b 45 08             	mov    0x8(%ebp),%eax
f010291f:	89 04 24             	mov    %eax,(%esp)
f0102922:	e8 b5 ff ff ff       	call   f01028dc <vcprintf>
	va_end(ap);

	return cnt;
}
f0102927:	c9                   	leave  
f0102928:	c3                   	ret    

f0102929 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102929:	55                   	push   %ebp
f010292a:	89 e5                	mov    %esp,%ebp
f010292c:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010292f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102932:	89 04 24             	mov    %eax,(%esp)
f0102935:	e8 26 dd ff ff       	call   f0100660 <cputchar>
	*cnt++;
}
f010293a:	c9                   	leave  
f010293b:	c3                   	ret    
f010293c:	00 00                	add    %al,(%eax)
	...

f0102940 <idt_init>:
}


void
idt_init(void)
{
f0102940:	55                   	push   %ebp
f0102941:	89 e5                	mov    %esp,%ebp
	extern void routine_align ();
	extern void routine_mchk ();
	extern void routine_simderr ();
	extern void routine_syscall();

	SETGATE (idt[T_DIVIDE], 0, GD_KT, routine_divide, 0);
f0102943:	b8 34 30 10 f0       	mov    $0xf0103034,%eax
f0102948:	66 a3 80 b4 15 f0    	mov    %ax,0xf015b480
f010294e:	66 c7 05 82 b4 15 f0 	movw   $0x8,0xf015b482
f0102955:	08 00 
f0102957:	c6 05 84 b4 15 f0 00 	movb   $0x0,0xf015b484
f010295e:	c6 05 85 b4 15 f0 8e 	movb   $0x8e,0xf015b485
f0102965:	c1 e8 10             	shr    $0x10,%eax
f0102968:	66 a3 86 b4 15 f0    	mov    %ax,0xf015b486
    SETGATE (idt[T_DEBUG],  0, GD_KT, routine_debug,  0);
f010296e:	b8 3a 30 10 f0       	mov    $0xf010303a,%eax
f0102973:	66 a3 88 b4 15 f0    	mov    %ax,0xf015b488
f0102979:	66 c7 05 8a b4 15 f0 	movw   $0x8,0xf015b48a
f0102980:	08 00 
f0102982:	c6 05 8c b4 15 f0 00 	movb   $0x0,0xf015b48c
f0102989:	c6 05 8d b4 15 f0 8e 	movb   $0x8e,0xf015b48d
f0102990:	c1 e8 10             	shr    $0x10,%eax
f0102993:	66 a3 8e b4 15 f0    	mov    %ax,0xf015b48e
    SETGATE (idt[T_NMI],    0, GD_KT, routine_nmi,    0);
f0102999:	b8 40 30 10 f0       	mov    $0xf0103040,%eax
f010299e:	66 a3 90 b4 15 f0    	mov    %ax,0xf015b490
f01029a4:	66 c7 05 92 b4 15 f0 	movw   $0x8,0xf015b492
f01029ab:	08 00 
f01029ad:	c6 05 94 b4 15 f0 00 	movb   $0x0,0xf015b494
f01029b4:	c6 05 95 b4 15 f0 8e 	movb   $0x8e,0xf015b495
f01029bb:	c1 e8 10             	shr    $0x10,%eax
f01029be:	66 a3 96 b4 15 f0    	mov    %ax,0xf015b496
    
    // break point needs no kernel mode privilege
	SETGATE (idt[T_BRKPT], 0, GD_KT, routine_brkpt, 3);
f01029c4:	b8 46 30 10 f0       	mov    $0xf0103046,%eax
f01029c9:	66 a3 98 b4 15 f0    	mov    %ax,0xf015b498
f01029cf:	66 c7 05 9a b4 15 f0 	movw   $0x8,0xf015b49a
f01029d6:	08 00 
f01029d8:	c6 05 9c b4 15 f0 00 	movb   $0x0,0xf015b49c
f01029df:	c6 05 9d b4 15 f0 ee 	movb   $0xee,0xf015b49d
f01029e6:	c1 e8 10             	shr    $0x10,%eax
f01029e9:	66 a3 9e b4 15 f0    	mov    %ax,0xf015b49e

	SETGATE (idt[T_OFLOW], 0, GD_KT, routine_oflow, 0);
f01029ef:	b8 4c 30 10 f0       	mov    $0xf010304c,%eax
f01029f4:	66 a3 a0 b4 15 f0    	mov    %ax,0xf015b4a0
f01029fa:	66 c7 05 a2 b4 15 f0 	movw   $0x8,0xf015b4a2
f0102a01:	08 00 
f0102a03:	c6 05 a4 b4 15 f0 00 	movb   $0x0,0xf015b4a4
f0102a0a:	c6 05 a5 b4 15 f0 8e 	movb   $0x8e,0xf015b4a5
f0102a11:	c1 e8 10             	shr    $0x10,%eax
f0102a14:	66 a3 a6 b4 15 f0    	mov    %ax,0xf015b4a6
	SETGATE (idt[T_BOUND], 0, GD_KT, routine_bound, 0);
f0102a1a:	b8 52 30 10 f0       	mov    $0xf0103052,%eax
f0102a1f:	66 a3 a8 b4 15 f0    	mov    %ax,0xf015b4a8
f0102a25:	66 c7 05 aa b4 15 f0 	movw   $0x8,0xf015b4aa
f0102a2c:	08 00 
f0102a2e:	c6 05 ac b4 15 f0 00 	movb   $0x0,0xf015b4ac
f0102a35:	c6 05 ad b4 15 f0 8e 	movb   $0x8e,0xf015b4ad
f0102a3c:	c1 e8 10             	shr    $0x10,%eax
f0102a3f:	66 a3 ae b4 15 f0    	mov    %ax,0xf015b4ae
	SETGATE (idt[T_ILLOP], 0, GD_KT, routine_illop, 0);
f0102a45:	b8 58 30 10 f0       	mov    $0xf0103058,%eax
f0102a4a:	66 a3 b0 b4 15 f0    	mov    %ax,0xf015b4b0
f0102a50:	66 c7 05 b2 b4 15 f0 	movw   $0x8,0xf015b4b2
f0102a57:	08 00 
f0102a59:	c6 05 b4 b4 15 f0 00 	movb   $0x0,0xf015b4b4
f0102a60:	c6 05 b5 b4 15 f0 8e 	movb   $0x8e,0xf015b4b5
f0102a67:	c1 e8 10             	shr    $0x10,%eax
f0102a6a:	66 a3 b6 b4 15 f0    	mov    %ax,0xf015b4b6
	SETGATE (idt[T_DEVICE], 0, GD_KT, routine_device, 0);
f0102a70:	b8 5e 30 10 f0       	mov    $0xf010305e,%eax
f0102a75:	66 a3 b8 b4 15 f0    	mov    %ax,0xf015b4b8
f0102a7b:	66 c7 05 ba b4 15 f0 	movw   $0x8,0xf015b4ba
f0102a82:	08 00 
f0102a84:	c6 05 bc b4 15 f0 00 	movb   $0x0,0xf015b4bc
f0102a8b:	c6 05 bd b4 15 f0 8e 	movb   $0x8e,0xf015b4bd
f0102a92:	c1 e8 10             	shr    $0x10,%eax
f0102a95:	66 a3 be b4 15 f0    	mov    %ax,0xf015b4be
	SETGATE (idt[T_DBLFLT], 0, GD_KT, routine_dblflt, 0);
f0102a9b:	b8 64 30 10 f0       	mov    $0xf0103064,%eax
f0102aa0:	66 a3 c0 b4 15 f0    	mov    %ax,0xf015b4c0
f0102aa6:	66 c7 05 c2 b4 15 f0 	movw   $0x8,0xf015b4c2
f0102aad:	08 00 
f0102aaf:	c6 05 c4 b4 15 f0 00 	movb   $0x0,0xf015b4c4
f0102ab6:	c6 05 c5 b4 15 f0 8e 	movb   $0x8e,0xf015b4c5
f0102abd:	c1 e8 10             	shr    $0x10,%eax
f0102ac0:	66 a3 c6 b4 15 f0    	mov    %ax,0xf015b4c6
	SETGATE (idt[T_TSS], 0, GD_KT, routine_tss, 0);
f0102ac6:	b8 68 30 10 f0       	mov    $0xf0103068,%eax
f0102acb:	66 a3 d0 b4 15 f0    	mov    %ax,0xf015b4d0
f0102ad1:	66 c7 05 d2 b4 15 f0 	movw   $0x8,0xf015b4d2
f0102ad8:	08 00 
f0102ada:	c6 05 d4 b4 15 f0 00 	movb   $0x0,0xf015b4d4
f0102ae1:	c6 05 d5 b4 15 f0 8e 	movb   $0x8e,0xf015b4d5
f0102ae8:	c1 e8 10             	shr    $0x10,%eax
f0102aeb:	66 a3 d6 b4 15 f0    	mov    %ax,0xf015b4d6
	SETGATE (idt[T_SEGNP], 0, GD_KT, routine_segnp, 0);
f0102af1:	b8 6c 30 10 f0       	mov    $0xf010306c,%eax
f0102af6:	66 a3 d8 b4 15 f0    	mov    %ax,0xf015b4d8
f0102afc:	66 c7 05 da b4 15 f0 	movw   $0x8,0xf015b4da
f0102b03:	08 00 
f0102b05:	c6 05 dc b4 15 f0 00 	movb   $0x0,0xf015b4dc
f0102b0c:	c6 05 dd b4 15 f0 8e 	movb   $0x8e,0xf015b4dd
f0102b13:	c1 e8 10             	shr    $0x10,%eax
f0102b16:	66 a3 de b4 15 f0    	mov    %ax,0xf015b4de
	SETGATE (idt[T_STACK], 0, GD_KT, routine_stack, 0);
f0102b1c:	b8 70 30 10 f0       	mov    $0xf0103070,%eax
f0102b21:	66 a3 e0 b4 15 f0    	mov    %ax,0xf015b4e0
f0102b27:	66 c7 05 e2 b4 15 f0 	movw   $0x8,0xf015b4e2
f0102b2e:	08 00 
f0102b30:	c6 05 e4 b4 15 f0 00 	movb   $0x0,0xf015b4e4
f0102b37:	c6 05 e5 b4 15 f0 8e 	movb   $0x8e,0xf015b4e5
f0102b3e:	c1 e8 10             	shr    $0x10,%eax
f0102b41:	66 a3 e6 b4 15 f0    	mov    %ax,0xf015b4e6
	SETGATE (idt[T_GPFLT], 0, GD_KT, routine_gpflt, 0);
f0102b47:	b8 74 30 10 f0       	mov    $0xf0103074,%eax
f0102b4c:	66 a3 e8 b4 15 f0    	mov    %ax,0xf015b4e8
f0102b52:	66 c7 05 ea b4 15 f0 	movw   $0x8,0xf015b4ea
f0102b59:	08 00 
f0102b5b:	c6 05 ec b4 15 f0 00 	movb   $0x0,0xf015b4ec
f0102b62:	c6 05 ed b4 15 f0 8e 	movb   $0x8e,0xf015b4ed
f0102b69:	c1 e8 10             	shr    $0x10,%eax
f0102b6c:	66 a3 ee b4 15 f0    	mov    %ax,0xf015b4ee
	SETGATE (idt[T_PGFLT], 0, GD_KT, routine_pgflt, 0);
f0102b72:	b8 78 30 10 f0       	mov    $0xf0103078,%eax
f0102b77:	66 a3 f0 b4 15 f0    	mov    %ax,0xf015b4f0
f0102b7d:	66 c7 05 f2 b4 15 f0 	movw   $0x8,0xf015b4f2
f0102b84:	08 00 
f0102b86:	c6 05 f4 b4 15 f0 00 	movb   $0x0,0xf015b4f4
f0102b8d:	c6 05 f5 b4 15 f0 8e 	movb   $0x8e,0xf015b4f5
f0102b94:	c1 e8 10             	shr    $0x10,%eax
f0102b97:	66 a3 f6 b4 15 f0    	mov    %ax,0xf015b4f6
	SETGATE (idt[T_FPERR], 0, GD_KT, routine_fperr, 0);
f0102b9d:	b8 7c 30 10 f0       	mov    $0xf010307c,%eax
f0102ba2:	66 a3 00 b5 15 f0    	mov    %ax,0xf015b500
f0102ba8:	66 c7 05 02 b5 15 f0 	movw   $0x8,0xf015b502
f0102baf:	08 00 
f0102bb1:	c6 05 04 b5 15 f0 00 	movb   $0x0,0xf015b504
f0102bb8:	c6 05 05 b5 15 f0 8e 	movb   $0x8e,0xf015b505
f0102bbf:	c1 e8 10             	shr    $0x10,%eax
f0102bc2:	66 a3 06 b5 15 f0    	mov    %ax,0xf015b506
	SETGATE (idt[T_ALIGN], 0, GD_KT, routine_align, 0);
f0102bc8:	b8 82 30 10 f0       	mov    $0xf0103082,%eax
f0102bcd:	66 a3 08 b5 15 f0    	mov    %ax,0xf015b508
f0102bd3:	66 c7 05 0a b5 15 f0 	movw   $0x8,0xf015b50a
f0102bda:	08 00 
f0102bdc:	c6 05 0c b5 15 f0 00 	movb   $0x0,0xf015b50c
f0102be3:	c6 05 0d b5 15 f0 8e 	movb   $0x8e,0xf015b50d
f0102bea:	c1 e8 10             	shr    $0x10,%eax
f0102bed:	66 a3 0e b5 15 f0    	mov    %ax,0xf015b50e
	SETGATE (idt[T_MCHK], 0, GD_KT, routine_mchk, 0);
f0102bf3:	b8 86 30 10 f0       	mov    $0xf0103086,%eax
f0102bf8:	66 a3 10 b5 15 f0    	mov    %ax,0xf015b510
f0102bfe:	66 c7 05 12 b5 15 f0 	movw   $0x8,0xf015b512
f0102c05:	08 00 
f0102c07:	c6 05 14 b5 15 f0 00 	movb   $0x0,0xf015b514
f0102c0e:	c6 05 15 b5 15 f0 8e 	movb   $0x8e,0xf015b515
f0102c15:	c1 e8 10             	shr    $0x10,%eax
f0102c18:	66 a3 16 b5 15 f0    	mov    %ax,0xf015b516
	SETGATE (idt[T_SIMDERR], 0, GD_KT, routine_simderr, 0);
f0102c1e:	b8 8c 30 10 f0       	mov    $0xf010308c,%eax
f0102c23:	66 a3 18 b5 15 f0    	mov    %ax,0xf015b518
f0102c29:	66 c7 05 1a b5 15 f0 	movw   $0x8,0xf015b51a
f0102c30:	08 00 
f0102c32:	c6 05 1c b5 15 f0 00 	movb   $0x0,0xf015b51c
f0102c39:	c6 05 1d b5 15 f0 8e 	movb   $0x8e,0xf015b51d
f0102c40:	c1 e8 10             	shr    $0x10,%eax
f0102c43:	66 a3 1e b5 15 f0    	mov    %ax,0xf015b51e

	extern void routine_system_call();
	SETGATE(idt[T_SYSCALL], 0, GD_KT, routine_system_call, 3);
f0102c49:	b8 92 30 10 f0       	mov    $0xf0103092,%eax
f0102c4e:	66 a3 00 b6 15 f0    	mov    %ax,0xf015b600
f0102c54:	66 c7 05 02 b6 15 f0 	movw   $0x8,0xf015b602
f0102c5b:	08 00 
f0102c5d:	c6 05 04 b6 15 f0 00 	movb   $0x0,0xf015b604
f0102c64:	c6 05 05 b6 15 f0 ee 	movb   $0xee,0xf015b605
f0102c6b:	c1 e8 10             	shr    $0x10,%eax
f0102c6e:	66 a3 06 b6 15 f0    	mov    %ax,0xf015b606

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102c74:	c7 05 84 bc 15 f0 00 	movl   $0xefc00000,0xf015bc84
f0102c7b:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0102c7e:	66 c7 05 88 bc 15 f0 	movw   $0x10,0xf015bc88
f0102c85:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102c87:	66 c7 05 48 73 11 f0 	movw   $0x68,0xf0117348
f0102c8e:	68 00 
f0102c90:	b8 80 bc 15 f0       	mov    $0xf015bc80,%eax
f0102c95:	66 a3 4a 73 11 f0    	mov    %ax,0xf011734a
f0102c9b:	89 c2                	mov    %eax,%edx
f0102c9d:	c1 ea 10             	shr    $0x10,%edx
f0102ca0:	88 15 4c 73 11 f0    	mov    %dl,0xf011734c
f0102ca6:	c6 05 4e 73 11 f0 40 	movb   $0x40,0xf011734e
f0102cad:	c1 e8 18             	shr    $0x18,%eax
f0102cb0:	a2 4f 73 11 f0       	mov    %al,0xf011734f
					   sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0102cb5:	c6 05 4d 73 11 f0 89 	movb   $0x89,0xf011734d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0102cbc:	b8 28 00 00 00       	mov    $0x28,%eax
f0102cc1:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0102cc4:	0f 01 1d 58 73 11 f0 	lidtl  0xf0117358
}
f0102ccb:	5d                   	pop    %ebp
f0102ccc:	c3                   	ret    

f0102ccd <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0102ccd:	55                   	push   %ebp
f0102cce:	89 e5                	mov    %esp,%ebp
f0102cd0:	53                   	push   %ebx
f0102cd1:	83 ec 14             	sub    $0x14,%esp
f0102cd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0102cd7:	8b 03                	mov    (%ebx),%eax
f0102cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102cdd:	c7 04 24 ee 4d 10 f0 	movl   $0xf0104dee,(%esp)
f0102ce4:	e8 26 fc ff ff       	call   f010290f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0102ce9:	8b 43 04             	mov    0x4(%ebx),%eax
f0102cec:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102cf0:	c7 04 24 fd 4d 10 f0 	movl   $0xf0104dfd,(%esp)
f0102cf7:	e8 13 fc ff ff       	call   f010290f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0102cfc:	8b 43 08             	mov    0x8(%ebx),%eax
f0102cff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d03:	c7 04 24 0c 4e 10 f0 	movl   $0xf0104e0c,(%esp)
f0102d0a:	e8 00 fc ff ff       	call   f010290f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0102d0f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0102d12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d16:	c7 04 24 1b 4e 10 f0 	movl   $0xf0104e1b,(%esp)
f0102d1d:	e8 ed fb ff ff       	call   f010290f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0102d22:	8b 43 10             	mov    0x10(%ebx),%eax
f0102d25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d29:	c7 04 24 2a 4e 10 f0 	movl   $0xf0104e2a,(%esp)
f0102d30:	e8 da fb ff ff       	call   f010290f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0102d35:	8b 43 14             	mov    0x14(%ebx),%eax
f0102d38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d3c:	c7 04 24 39 4e 10 f0 	movl   $0xf0104e39,(%esp)
f0102d43:	e8 c7 fb ff ff       	call   f010290f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0102d48:	8b 43 18             	mov    0x18(%ebx),%eax
f0102d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d4f:	c7 04 24 48 4e 10 f0 	movl   $0xf0104e48,(%esp)
f0102d56:	e8 b4 fb ff ff       	call   f010290f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0102d5b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0102d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d62:	c7 04 24 57 4e 10 f0 	movl   $0xf0104e57,(%esp)
f0102d69:	e8 a1 fb ff ff       	call   f010290f <cprintf>
}
f0102d6e:	83 c4 14             	add    $0x14,%esp
f0102d71:	5b                   	pop    %ebx
f0102d72:	5d                   	pop    %ebp
f0102d73:	c3                   	ret    

f0102d74 <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f0102d74:	55                   	push   %ebp
f0102d75:	89 e5                	mov    %esp,%ebp
f0102d77:	53                   	push   %ebx
f0102d78:	83 ec 14             	sub    $0x14,%esp
f0102d7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0102d7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d82:	c7 04 24 48 4f 10 f0 	movl   $0xf0104f48,(%esp)
f0102d89:	e8 81 fb ff ff       	call   f010290f <cprintf>
	print_regs(&tf->tf_regs);
f0102d8e:	89 1c 24             	mov    %ebx,(%esp)
f0102d91:	e8 37 ff ff ff       	call   f0102ccd <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0102d96:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0102d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d9e:	c7 04 24 66 4e 10 f0 	movl   $0xf0104e66,(%esp)
f0102da5:	e8 65 fb ff ff       	call   f010290f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0102daa:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0102dae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102db2:	c7 04 24 79 4e 10 f0 	movl   $0xf0104e79,(%esp)
f0102db9:	e8 51 fb ff ff       	call   f010290f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102dbe:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0102dc1:	83 f8 13             	cmp    $0x13,%eax
f0102dc4:	77 09                	ja     f0102dcf <print_trapframe+0x5b>
		return excnames[trapno];
f0102dc6:	8b 14 85 60 51 10 f0 	mov    -0xfefaea0(,%eax,4),%edx
f0102dcd:	eb 10                	jmp    f0102ddf <print_trapframe+0x6b>
	if (trapno == T_SYSCALL)
f0102dcf:	83 f8 30             	cmp    $0x30,%eax
f0102dd2:	ba 8c 4e 10 f0       	mov    $0xf0104e8c,%edx
f0102dd7:	b9 9b 4e 10 f0       	mov    $0xf0104e9b,%ecx
f0102ddc:	0f 44 d1             	cmove  %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102ddf:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102de3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102de7:	c7 04 24 a7 4e 10 f0 	movl   $0xf0104ea7,(%esp)
f0102dee:	e8 1c fb ff ff       	call   f010290f <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f0102df3:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0102df6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dfa:	c7 04 24 b9 4e 10 f0 	movl   $0xf0104eb9,(%esp)
f0102e01:	e8 09 fb ff ff       	call   f010290f <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0102e06:	8b 43 30             	mov    0x30(%ebx),%eax
f0102e09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e0d:	c7 04 24 c8 4e 10 f0 	movl   $0xf0104ec8,(%esp)
f0102e14:	e8 f6 fa ff ff       	call   f010290f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0102e19:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0102e1d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e21:	c7 04 24 d7 4e 10 f0 	movl   $0xf0104ed7,(%esp)
f0102e28:	e8 e2 fa ff ff       	call   f010290f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0102e2d:	8b 43 38             	mov    0x38(%ebx),%eax
f0102e30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e34:	c7 04 24 ea 4e 10 f0 	movl   $0xf0104eea,(%esp)
f0102e3b:	e8 cf fa ff ff       	call   f010290f <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0102e40:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0102e43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e47:	c7 04 24 f9 4e 10 f0 	movl   $0xf0104ef9,(%esp)
f0102e4e:	e8 bc fa ff ff       	call   f010290f <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0102e53:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0102e57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e5b:	c7 04 24 08 4f 10 f0 	movl   $0xf0104f08,(%esp)
f0102e62:	e8 a8 fa ff ff       	call   f010290f <cprintf>
}
f0102e67:	83 c4 14             	add    $0x14,%esp
f0102e6a:	5b                   	pop    %ebx
f0102e6b:	5d                   	pop    %ebp
f0102e6c:	c3                   	ret    

f0102e6d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0102e6d:	55                   	push   %ebp
f0102e6e:	89 e5                	mov    %esp,%ebp
f0102e70:	53                   	push   %ebx
f0102e71:	83 ec 14             	sub    $0x14,%esp
f0102e74:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0102e77:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0102e7a:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0102e7e:	75 1c                	jne    f0102e9c <page_fault_handler+0x2f>
		panic ("kernel-mode page faults");
f0102e80:	c7 44 24 08 1b 4f 10 	movl   $0xf0104f1b,0x8(%esp)
f0102e87:	f0 
f0102e88:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
f0102e8f:	00 
f0102e90:	c7 04 24 33 4f 10 f0 	movl   $0xf0104f33,(%esp)
f0102e97:	e8 e4 d1 ff ff       	call   f0100080 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0102e9c:	8b 53 30             	mov    0x30(%ebx),%edx
f0102e9f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ea3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ea7:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0102eac:	8b 40 4c             	mov    0x4c(%eax),%eax
f0102eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102eb3:	c7 04 24 bc 50 10 f0 	movl   $0xf01050bc,(%esp)
f0102eba:	e8 50 fa ff ff       	call   f010290f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0102ebf:	89 1c 24             	mov    %ebx,(%esp)
f0102ec2:	e8 ad fe ff ff       	call   f0102d74 <print_trapframe>
	env_destroy(curenv);
f0102ec7:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0102ecc:	89 04 24             	mov    %eax,(%esp)
f0102ecf:	e8 07 f5 ff ff       	call   f01023db <env_destroy>
}
f0102ed4:	83 c4 14             	add    $0x14,%esp
f0102ed7:	5b                   	pop    %ebx
f0102ed8:	5d                   	pop    %ebp
f0102ed9:	c3                   	ret    

f0102eda <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0102eda:	55                   	push   %ebp
f0102edb:	89 e5                	mov    %esp,%ebp
f0102edd:	57                   	push   %edi
f0102ede:	56                   	push   %esi
f0102edf:	83 ec 20             	sub    $0x20,%esp
f0102ee2:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("Incoming TRAP frame at %p\n", tf);
f0102ee5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ee9:	c7 04 24 3f 4f 10 f0 	movl   $0xf0104f3f,(%esp)
f0102ef0:	e8 1a fa ff ff       	call   f010290f <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0102ef5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0102ef9:	83 e0 03             	and    $0x3,%eax
f0102efc:	83 f8 03             	cmp    $0x3,%eax
f0102eff:	75 3c                	jne    f0102f3d <trap+0x63>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0102f01:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0102f06:	85 c0                	test   %eax,%eax
f0102f08:	75 24                	jne    f0102f2e <trap+0x54>
f0102f0a:	c7 44 24 0c 5a 4f 10 	movl   $0xf0104f5a,0xc(%esp)
f0102f11:	f0 
f0102f12:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0102f19:	f0 
f0102f1a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f0102f21:	00 
f0102f22:	c7 04 24 33 4f 10 f0 	movl   $0xf0104f33,(%esp)
f0102f29:	e8 52 d1 ff ff       	call   f0100080 <_panic>
		curenv->env_tf = *tf;
f0102f2e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0102f33:	89 c7                	mov    %eax,%edi
f0102f35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0102f37:	8b 35 64 b4 15 f0    	mov    0xf015b464,%esi
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT)
f0102f3d:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0102f41:	75 08                	jne    f0102f4b <trap+0x71>
		page_fault_handler (tf);
f0102f43:	89 34 24             	mov    %esi,(%esp)
f0102f46:	e8 22 ff ff ff       	call   f0102e6d <page_fault_handler>
	if (tf->tf_trapno == T_BRKPT)
f0102f4b:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f0102f4f:	75 08                	jne    f0102f59 <trap+0x7f>
		monitor (tf);
f0102f51:	89 34 24             	mov    %esi,(%esp)
f0102f54:	e8 47 d8 ff ff       	call   f01007a0 <monitor>
	if (tf->tf_trapno == T_DEBUG)
f0102f59:	83 7e 28 01          	cmpl   $0x1,0x28(%esi)
f0102f5d:	75 08                	jne    f0102f67 <trap+0x8d>
		monitor (tf);
f0102f5f:	89 34 24             	mov    %esi,(%esp)
f0102f62:	e8 39 d8 ff ff       	call   f01007a0 <monitor>
	int r;
	if (tf->tf_trapno == T_SYSCALL) {
f0102f67:	83 7e 28 30          	cmpl   $0x30,0x28(%esi)
f0102f6b:	75 52                	jne    f0102fbf <trap+0xe5>
		r = syscall (tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,
f0102f6d:	8b 46 04             	mov    0x4(%esi),%eax
f0102f70:	89 44 24 14          	mov    %eax,0x14(%esp)
f0102f74:	8b 06                	mov    (%esi),%eax
f0102f76:	89 44 24 10          	mov    %eax,0x10(%esp)
f0102f7a:	8b 46 10             	mov    0x10(%esi),%eax
f0102f7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f81:	8b 46 18             	mov    0x18(%esi),%eax
f0102f84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f88:	8b 46 14             	mov    0x14(%esi),%eax
f0102f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f8f:	8b 46 1c             	mov    0x1c(%esi),%eax
f0102f92:	89 04 24             	mov    %eax,(%esp)
f0102f95:	e8 26 01 00 00       	call   f01030c0 <syscall>
			     tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,
			     tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
		if (r < 0)
f0102f9a:	85 c0                	test   %eax,%eax
f0102f9c:	79 1c                	jns    f0102fba <trap+0xe0>
			 panic ("trap_dispatch: The System Call number is invalid");
f0102f9e:	c7 44 24 08 e0 50 10 	movl   $0xf01050e0,0x8(%esp)
f0102fa5:	f0 
f0102fa6:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
f0102fad:	00 
f0102fae:	c7 04 24 33 4f 10 f0 	movl   $0xf0104f33,(%esp)
f0102fb5:	e8 c6 d0 ff ff       	call   f0100080 <_panic>

		tf->tf_regs.reg_eax = r;
f0102fba:	89 46 1c             	mov    %eax,0x1c(%esi)
f0102fbd:	eb 38                	jmp    f0102ff7 <trap+0x11d>

		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0102fbf:	89 34 24             	mov    %esi,(%esp)
f0102fc2:	e8 ad fd ff ff       	call   f0102d74 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0102fc7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0102fcc:	75 1c                	jne    f0102fea <trap+0x110>
		panic("unhandled trap in kernel");
f0102fce:	c7 44 24 08 61 4f 10 	movl   $0xf0104f61,0x8(%esp)
f0102fd5:	f0 
f0102fd6:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
f0102fdd:	00 
f0102fde:	c7 04 24 33 4f 10 f0 	movl   $0xf0104f33,(%esp)
f0102fe5:	e8 96 d0 ff ff       	call   f0100080 <_panic>
	else {
		env_destroy(curenv);
f0102fea:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0102fef:	89 04 24             	mov    %eax,(%esp)
f0102ff2:	e8 e4 f3 ff ff       	call   f01023db <env_destroy>
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f0102ff7:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0102ffc:	85 c0                	test   %eax,%eax
f0102ffe:	74 06                	je     f0103006 <trap+0x12c>
f0103000:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103004:	74 24                	je     f010302a <trap+0x150>
f0103006:	c7 44 24 0c 14 51 10 	movl   $0xf0105114,0xc(%esp)
f010300d:	f0 
f010300e:	c7 44 24 08 19 4c 10 	movl   $0xf0104c19,0x8(%esp)
f0103015:	f0 
f0103016:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f010301d:	00 
f010301e:	c7 04 24 33 4f 10 f0 	movl   $0xf0104f33,(%esp)
f0103025:	e8 56 d0 ff ff       	call   f0100080 <_panic>
        env_run(curenv);
f010302a:	89 04 24             	mov    %eax,(%esp)
f010302d:	e8 e2 f1 ff ff       	call   f0102214 <env_run>
	...

f0103034 <routine_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	
	TRAPHANDLER_NOEC(routine_divide, T_DIVIDE)
f0103034:	6a 00                	push   $0x0
f0103036:	6a 00                	push   $0x0
f0103038:	eb 5e                	jmp    f0103098 <_alltraps>

f010303a <routine_debug>:
	TRAPHANDLER_NOEC(routine_debug, T_DEBUG)
f010303a:	6a 00                	push   $0x0
f010303c:	6a 01                	push   $0x1
f010303e:	eb 58                	jmp    f0103098 <_alltraps>

f0103040 <routine_nmi>:
	TRAPHANDLER_NOEC(routine_nmi, T_NMI)
f0103040:	6a 00                	push   $0x0
f0103042:	6a 02                	push   $0x2
f0103044:	eb 52                	jmp    f0103098 <_alltraps>

f0103046 <routine_brkpt>:
	TRAPHANDLER_NOEC(routine_brkpt, T_BRKPT)
f0103046:	6a 00                	push   $0x0
f0103048:	6a 03                	push   $0x3
f010304a:	eb 4c                	jmp    f0103098 <_alltraps>

f010304c <routine_oflow>:
	TRAPHANDLER_NOEC(routine_oflow, T_OFLOW)
f010304c:	6a 00                	push   $0x0
f010304e:	6a 04                	push   $0x4
f0103050:	eb 46                	jmp    f0103098 <_alltraps>

f0103052 <routine_bound>:
	TRAPHANDLER_NOEC(routine_bound, T_BOUND)
f0103052:	6a 00                	push   $0x0
f0103054:	6a 05                	push   $0x5
f0103056:	eb 40                	jmp    f0103098 <_alltraps>

f0103058 <routine_illop>:
	TRAPHANDLER_NOEC(routine_illop, T_ILLOP)
f0103058:	6a 00                	push   $0x0
f010305a:	6a 06                	push   $0x6
f010305c:	eb 3a                	jmp    f0103098 <_alltraps>

f010305e <routine_device>:
	TRAPHANDLER_NOEC(routine_device, T_DEVICE)
f010305e:	6a 00                	push   $0x0
f0103060:	6a 07                	push   $0x7
f0103062:	eb 34                	jmp    f0103098 <_alltraps>

f0103064 <routine_dblflt>:
	TRAPHANDLER(routine_dblflt, T_DBLFLT)
f0103064:	6a 08                	push   $0x8
f0103066:	eb 30                	jmp    f0103098 <_alltraps>

f0103068 <routine_tss>:
	TRAPHANDLER(routine_tss, T_TSS)
f0103068:	6a 0a                	push   $0xa
f010306a:	eb 2c                	jmp    f0103098 <_alltraps>

f010306c <routine_segnp>:
	TRAPHANDLER(routine_segnp, T_SEGNP)
f010306c:	6a 0b                	push   $0xb
f010306e:	eb 28                	jmp    f0103098 <_alltraps>

f0103070 <routine_stack>:
	TRAPHANDLER(routine_stack, T_STACK)
f0103070:	6a 0c                	push   $0xc
f0103072:	eb 24                	jmp    f0103098 <_alltraps>

f0103074 <routine_gpflt>:
	TRAPHANDLER(routine_gpflt, T_GPFLT)
f0103074:	6a 0d                	push   $0xd
f0103076:	eb 20                	jmp    f0103098 <_alltraps>

f0103078 <routine_pgflt>:
	TRAPHANDLER(routine_pgflt, T_PGFLT)
f0103078:	6a 0e                	push   $0xe
f010307a:	eb 1c                	jmp    f0103098 <_alltraps>

f010307c <routine_fperr>:
	TRAPHANDLER_NOEC(routine_fperr, T_FPERR)
f010307c:	6a 00                	push   $0x0
f010307e:	6a 10                	push   $0x10
f0103080:	eb 16                	jmp    f0103098 <_alltraps>

f0103082 <routine_align>:
	TRAPHANDLER(routine_align, T_ALIGN)
f0103082:	6a 11                	push   $0x11
f0103084:	eb 12                	jmp    f0103098 <_alltraps>

f0103086 <routine_mchk>:
	TRAPHANDLER_NOEC(routine_mchk, T_MCHK)
f0103086:	6a 00                	push   $0x0
f0103088:	6a 12                	push   $0x12
f010308a:	eb 0c                	jmp    f0103098 <_alltraps>

f010308c <routine_simderr>:
	TRAPHANDLER_NOEC(routine_simderr, T_SIMDERR)
f010308c:	6a 00                	push   $0x0
f010308e:	6a 13                	push   $0x13
f0103090:	eb 06                	jmp    f0103098 <_alltraps>

f0103092 <routine_system_call>:

	TRAPHANDLER_NOEC(routine_system_call, T_SYSCALL)
f0103092:	6a 00                	push   $0x0
f0103094:	6a 30                	push   $0x30
f0103096:	eb 00                	jmp    f0103098 <_alltraps>

f0103098 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
     _alltraps:
	pushl %ds;
f0103098:	1e                   	push   %ds
	pushl %es
f0103099:	06                   	push   %es
	pushal
f010309a:	60                   	pusha  
	movl $GD_KD, %eax
f010309b:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax,%ds
f01030a0:	8e d8                	mov    %eax,%ds
	movw %ax,%es
f01030a2:	8e c0                	mov    %eax,%es
	pushl %esp
f01030a4:	54                   	push   %esp
	call trap
f01030a5:	e8 30 fe ff ff       	call   f0102eda <trap>
	popl %esp
f01030aa:	5c                   	pop    %esp
	popal
f01030ab:	61                   	popa   
	popl %es
f01030ac:	07                   	pop    %es
	popl %ds
f01030ad:	1f                   	pop    %ds
	addl $8, %esp
f01030ae:	83 c4 08             	add    $0x8,%esp
	iret
f01030b1:	cf                   	iret   
	...

f01030c0 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
uint32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01030c0:	55                   	push   %ebp
f01030c1:	89 e5                	mov    %esp,%ebp
f01030c3:	56                   	push   %esi
f01030c4:	53                   	push   %ebx
f01030c5:	83 ec 20             	sub    $0x20,%esp
f01030c8:	8b 55 08             	mov    0x8(%ebp),%edx
f01030cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01030ce:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t r = 0;
	switch (syscallno) {
f01030d1:	83 fa 01             	cmp    $0x1,%edx
f01030d4:	74 54                	je     f010312a <syscall+0x6a>
f01030d6:	83 fa 01             	cmp    $0x1,%edx
f01030d9:	72 17                	jb     f01030f2 <syscall+0x32>
f01030db:	83 fa 02             	cmp    $0x2,%edx
f01030de:	74 55                	je     f0103135 <syscall+0x75>
f01030e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01030e5:	83 fa 03             	cmp    $0x3,%edx
f01030e8:	0f 85 b8 00 00 00    	jne    f01031a6 <syscall+0xe6>
f01030ee:	66 90                	xchg   %ax,%ax
f01030f0:	eb 4d                	jmp    f010313f <syscall+0x7f>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert (curenv, s, len, 0);
f01030f2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01030f9:	00 
f01030fa:	89 74 24 08          	mov    %esi,0x8(%esp)
f01030fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103102:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f0103107:	89 04 24             	mov    %eax,(%esp)
f010310a:	e8 82 dd ff ff       	call   f0100e91 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010310f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103113:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103117:	c7 04 24 b0 51 10 f0 	movl   $0xf01051b0,(%esp)
f010311e:	e8 ec f7 ff ff       	call   f010290f <cprintf>
f0103123:	b8 00 00 00 00       	mov    $0x0,%eax
f0103128:	eb 7c                	jmp    f01031a6 <syscall+0xe6>
{
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f010312a:	e8 be d1 ff ff       	call   f01002ed <cons_getc>
f010312f:	85 c0                	test   %eax,%eax
f0103131:	74 f7                	je     f010312a <syscall+0x6a>
f0103133:	eb 71                	jmp    f01031a6 <syscall+0xe6>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103135:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f010313a:	8b 40 4c             	mov    0x4c(%eax),%eax
		case SYS_cputs:
			sys_cputs ((const char*) a1, (size_t)a2); break;
		case SYS_cgetc:
			r = sys_cgetc (); break;
		case SYS_getenvid:
			r = sys_getenvid (); break;
f010313d:	eb 67                	jmp    f01031a6 <syscall+0xe6>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010313f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103146:	00 
f0103147:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010314a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010314e:	89 1c 24             	mov    %ebx,(%esp)
f0103151:	e8 aa ef ff ff       	call   f0102100 <envid2env>
f0103156:	85 c0                	test   %eax,%eax
f0103158:	78 4c                	js     f01031a6 <syscall+0xe6>
		return r;
	if (e == curenv)
f010315a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010315d:	8b 15 64 b4 15 f0    	mov    0xf015b464,%edx
f0103163:	39 d0                	cmp    %edx,%eax
f0103165:	75 15                	jne    f010317c <syscall+0xbc>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103167:	8b 40 4c             	mov    0x4c(%eax),%eax
f010316a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010316e:	c7 04 24 b5 51 10 f0 	movl   $0xf01051b5,(%esp)
f0103175:	e8 95 f7 ff ff       	call   f010290f <cprintf>
f010317a:	eb 1a                	jmp    f0103196 <syscall+0xd6>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010317c:	8b 40 4c             	mov    0x4c(%eax),%eax
f010317f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103183:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103186:	89 44 24 04          	mov    %eax,0x4(%esp)
f010318a:	c7 04 24 d0 51 10 f0 	movl   $0xf01051d0,(%esp)
f0103191:	e8 79 f7 ff ff       	call   f010290f <cprintf>
	env_destroy(e);
f0103196:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103199:	89 04 24             	mov    %eax,(%esp)
f010319c:	e8 3a f2 ff ff       	call   f01023db <env_destroy>
f01031a1:	b8 00 00 00 00       	mov    $0x0,%eax
			 r = sys_env_destroy ((envid_t) a1); break;
			  default:
			  r = -E_INVAL;
		 }
	 return r;
}
f01031a6:	83 c4 20             	add    $0x20,%esp
f01031a9:	5b                   	pop    %ebx
f01031aa:	5e                   	pop    %esi
f01031ab:	5d                   	pop    %ebp
f01031ac:	c3                   	ret    
f01031ad:	00 00                	add    %al,(%eax)
	...

f01031b0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01031b0:	55                   	push   %ebp
f01031b1:	89 e5                	mov    %esp,%ebp
f01031b3:	57                   	push   %edi
f01031b4:	56                   	push   %esi
f01031b5:	53                   	push   %ebx
f01031b6:	83 ec 14             	sub    $0x14,%esp
f01031b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01031bc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01031bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01031c2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01031c5:	8b 1a                	mov    (%edx),%ebx
f01031c7:	8b 01                	mov    (%ecx),%eax
f01031c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f01031cc:	39 c3                	cmp    %eax,%ebx
f01031ce:	0f 8f 9c 00 00 00    	jg     f0103270 <stab_binsearch+0xc0>
f01031d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01031db:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01031de:	01 d8                	add    %ebx,%eax
f01031e0:	89 c7                	mov    %eax,%edi
f01031e2:	c1 ef 1f             	shr    $0x1f,%edi
f01031e5:	01 c7                	add    %eax,%edi
f01031e7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01031e9:	39 df                	cmp    %ebx,%edi
f01031eb:	7c 33                	jl     f0103220 <stab_binsearch+0x70>
f01031ed:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01031f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01031f3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01031f8:	39 f0                	cmp    %esi,%eax
f01031fa:	0f 84 bc 00 00 00    	je     f01032bc <stab_binsearch+0x10c>
f0103200:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0103204:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0103208:	89 f8                	mov    %edi,%eax
			m--;
f010320a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010320d:	39 d8                	cmp    %ebx,%eax
f010320f:	7c 0f                	jl     f0103220 <stab_binsearch+0x70>
f0103211:	0f b6 0a             	movzbl (%edx),%ecx
f0103214:	83 ea 0c             	sub    $0xc,%edx
f0103217:	39 f1                	cmp    %esi,%ecx
f0103219:	75 ef                	jne    f010320a <stab_binsearch+0x5a>
f010321b:	e9 9e 00 00 00       	jmp    f01032be <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103220:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103223:	eb 3c                	jmp    f0103261 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103225:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103228:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010322a:	8d 5f 01             	lea    0x1(%edi),%ebx
f010322d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103234:	eb 2b                	jmp    f0103261 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0103236:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103239:	76 14                	jbe    f010324f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010323b:	83 e8 01             	sub    $0x1,%eax
f010323e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103241:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103244:	89 02                	mov    %eax,(%edx)
f0103246:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010324d:	eb 12                	jmp    f0103261 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010324f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103252:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103254:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103258:	89 c3                	mov    %eax,%ebx
f010325a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103261:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103264:	0f 8d 71 ff ff ff    	jge    f01031db <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010326a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010326e:	75 0f                	jne    f010327f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103270:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103273:	8b 03                	mov    (%ebx),%eax
f0103275:	83 e8 01             	sub    $0x1,%eax
f0103278:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010327b:	89 02                	mov    %eax,(%edx)
f010327d:	eb 57                	jmp    f01032d6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010327f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103282:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103284:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103287:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103289:	39 c1                	cmp    %eax,%ecx
f010328b:	7d 28                	jge    f01032b5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010328d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103290:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103293:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103298:	39 f2                	cmp    %esi,%edx
f010329a:	74 19                	je     f01032b5 <stab_binsearch+0x105>
f010329c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01032a0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f01032a4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032a7:	39 c1                	cmp    %eax,%ecx
f01032a9:	7d 0a                	jge    f01032b5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01032ab:	0f b6 1a             	movzbl (%edx),%ebx
f01032ae:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032b1:	39 f3                	cmp    %esi,%ebx
f01032b3:	75 ef                	jne    f01032a4 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f01032b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01032b8:	89 02                	mov    %eax,(%edx)
f01032ba:	eb 1a                	jmp    f01032d6 <stab_binsearch+0x126>
	}
}
f01032bc:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01032be:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01032c1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01032c4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01032c8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01032cb:	0f 82 54 ff ff ff    	jb     f0103225 <stab_binsearch+0x75>
f01032d1:	e9 60 ff ff ff       	jmp    f0103236 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01032d6:	83 c4 14             	add    $0x14,%esp
f01032d9:	5b                   	pop    %ebx
f01032da:	5e                   	pop    %esi
f01032db:	5f                   	pop    %edi
f01032dc:	5d                   	pop    %ebp
f01032dd:	c3                   	ret    

f01032de <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01032de:	55                   	push   %ebp
f01032df:	89 e5                	mov    %esp,%ebp
f01032e1:	83 ec 48             	sub    $0x48,%esp
f01032e4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01032e7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01032ea:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01032ed:	8b 75 08             	mov    0x8(%ebp),%esi
f01032f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01032f3:	c7 03 e8 51 10 f0    	movl   $0xf01051e8,(%ebx)
	info->eip_line = 0;
f01032f9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103300:	c7 43 08 e8 51 10 f0 	movl   $0xf01051e8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103307:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010330e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103311:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103318:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010331e:	76 1f                	jbe    f010333f <debuginfo_eip+0x61>
f0103320:	bf c1 e9 10 f0       	mov    $0xf010e9c1,%edi
f0103325:	c7 45 d4 69 be 10 f0 	movl   $0xf010be69,-0x2c(%ebp)
f010332c:	c7 45 cc 68 be 10 f0 	movl   $0xf010be68,-0x34(%ebp)
f0103333:	c7 45 d0 00 54 10 f0 	movl   $0xf0105400,-0x30(%ebp)
f010333a:	e9 aa 00 00 00       	jmp    f01033e9 <debuginfo_eip+0x10b>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, usd, sizeof (struct UserStabData), PTE_U) < 0)
f010333f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103346:	00 
f0103347:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010334e:	00 
f010334f:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0103356:	00 
f0103357:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f010335c:	89 04 24             	mov    %eax,(%esp)
f010335f:	e8 9b da ff ff       	call   f0100dff <user_mem_check>
f0103364:	85 c0                	test   %eax,%eax
f0103366:	0f 88 a9 01 00 00    	js     f0103515 <debuginfo_eip+0x237>
			return -1;
		
		stabs = usd->stabs;
f010336c:	b8 00 00 20 00       	mov    $0x200000,%eax
f0103371:	8b 10                	mov    (%eax),%edx
f0103373:	89 55 d0             	mov    %edx,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103376:	8b 50 04             	mov    0x4(%eax),%edx
f0103379:	89 55 cc             	mov    %edx,-0x34(%ebp)
		stabstr = usd->stabstr;
f010337c:	8b 50 08             	mov    0x8(%eax),%edx
f010337f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103382:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0103385:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010338c:	00 
f010338d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103390:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103393:	c1 f8 02             	sar    $0x2,%eax
f0103396:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010339c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01033a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033a7:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f01033ac:	89 04 24             	mov    %eax,(%esp)
f01033af:	e8 4b da ff ff       	call   f0100dff <user_mem_check>
f01033b4:	85 c0                	test   %eax,%eax
f01033b6:	0f 88 59 01 00 00    	js     f0103515 <debuginfo_eip+0x237>
f01033bc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01033c3:	00 
f01033c4:	89 f8                	mov    %edi,%eax
f01033c6:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f01033c9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01033d0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01033d4:	a1 64 b4 15 f0       	mov    0xf015b464,%eax
f01033d9:	89 04 24             	mov    %eax,(%esp)
f01033dc:	e8 1e da ff ff       	call   f0100dff <user_mem_check>
f01033e1:	85 c0                	test   %eax,%eax
f01033e3:	0f 88 2c 01 00 00    	js     f0103515 <debuginfo_eip+0x237>
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01033e9:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f01033ec:	0f 83 23 01 00 00    	jae    f0103515 <debuginfo_eip+0x237>
f01033f2:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01033f6:	0f 85 19 01 00 00    	jne    f0103515 <debuginfo_eip+0x237>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01033fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103403:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103406:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103409:	c1 f8 02             	sar    $0x2,%eax
f010340c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103412:	83 e8 01             	sub    $0x1,%eax
f0103415:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103418:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010341b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010341e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103422:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103429:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010342c:	e8 7f fd ff ff       	call   f01031b0 <stab_binsearch>
	if (lfile == 0)
f0103431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103434:	85 c0                	test   %eax,%eax
f0103436:	0f 84 d9 00 00 00    	je     f0103515 <debuginfo_eip+0x237>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010343c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010343f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103442:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103445:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103448:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010344b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010344f:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103456:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103459:	e8 52 fd ff ff       	call   f01031b0 <stab_binsearch>

	if (lfun <= rfun) {
f010345e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103461:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103464:	7f 2a                	jg     f0103490 <debuginfo_eip+0x1b2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103466:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103469:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010346c:	8b 04 10             	mov    (%eax,%edx,1),%eax
f010346f:	89 fa                	mov    %edi,%edx
f0103471:	2b 55 d4             	sub    -0x2c(%ebp),%edx
f0103474:	39 d0                	cmp    %edx,%eax
f0103476:	73 06                	jae    f010347e <debuginfo_eip+0x1a0>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103478:	03 45 d4             	add    -0x2c(%ebp),%eax
f010347b:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010347e:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103481:	6b c6 0c             	imul   $0xc,%esi,%eax
f0103484:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103487:	8b 44 10 08          	mov    0x8(%eax,%edx,1),%eax
f010348b:	89 43 10             	mov    %eax,0x10(%ebx)
f010348e:	eb 06                	jmp    f0103496 <debuginfo_eip+0x1b8>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103490:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103493:	8b 75 e4             	mov    -0x1c(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103496:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010349d:	00 
f010349e:	8b 43 08             	mov    0x8(%ebx),%eax
f01034a1:	89 04 24             	mov    %eax,(%esp)
f01034a4:	e8 f2 08 00 00       	call   f0103d9b <strfind>
f01034a9:	2b 43 08             	sub    0x8(%ebx),%eax
f01034ac:	89 43 0c             	mov    %eax,0xc(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01034af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01034b5:	39 c6                	cmp    %eax,%esi
f01034b7:	7c 63                	jl     f010351c <debuginfo_eip+0x23e>
	       && stabs[lline].n_type != N_SOL
f01034b9:	6b ce 0c             	imul   $0xc,%esi,%ecx
f01034bc:	03 4d d0             	add    -0x30(%ebp),%ecx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01034bf:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01034c3:	80 fa 84             	cmp    $0x84,%dl
f01034c6:	74 31                	je     f01034f9 <debuginfo_eip+0x21b>
f01034c8:	8d 46 ff             	lea    -0x1(%esi),%eax
f01034cb:	6b c0 0c             	imul   $0xc,%eax,%eax
f01034ce:	03 45 d0             	add    -0x30(%ebp),%eax
f01034d1:	eb 16                	jmp    f01034e9 <debuginfo_eip+0x20b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01034d3:	83 ee 01             	sub    $0x1,%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01034d6:	3b 75 cc             	cmp    -0x34(%ebp),%esi
f01034d9:	7c 41                	jl     f010351c <debuginfo_eip+0x23e>
f01034db:	89 c1                	mov    %eax,%ecx
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01034dd:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01034e1:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01034e4:	80 fa 84             	cmp    $0x84,%dl
f01034e7:	74 10                	je     f01034f9 <debuginfo_eip+0x21b>
f01034e9:	80 fa 64             	cmp    $0x64,%dl
f01034ec:	75 e5                	jne    f01034d3 <debuginfo_eip+0x1f5>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01034ee:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f01034f2:	74 df                	je     f01034d3 <debuginfo_eip+0x1f5>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01034f4:	3b 75 cc             	cmp    -0x34(%ebp),%esi
f01034f7:	7c 23                	jl     f010351c <debuginfo_eip+0x23e>
f01034f9:	6b f6 0c             	imul   $0xc,%esi,%esi
f01034fc:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01034ff:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0103502:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0103505:	39 f8                	cmp    %edi,%eax
f0103507:	73 13                	jae    f010351c <debuginfo_eip+0x23e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103509:	03 45 d4             	add    -0x2c(%ebp),%eax
f010350c:	89 03                	mov    %eax,(%ebx)
f010350e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103513:	eb 0c                	jmp    f0103521 <debuginfo_eip+0x243>
f0103515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010351a:	eb 05                	jmp    f0103521 <debuginfo_eip+0x243>
f010351c:	b8 00 00 00 00       	mov    $0x0,%eax
	//if(lfun<rfun)
	//	for(lline=lfun+1;lline<rfun&&stabs[lline].n_type==N_PSYM;lline++)
	//	info->eip_fn_narg++;
	
	return 0;
}
f0103521:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103524:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103527:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010352a:	89 ec                	mov    %ebp,%esp
f010352c:	5d                   	pop    %ebp
f010352d:	c3                   	ret    
	...

f0103530 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103530:	55                   	push   %ebp
f0103531:	89 e5                	mov    %esp,%ebp
f0103533:	57                   	push   %edi
f0103534:	56                   	push   %esi
f0103535:	53                   	push   %ebx
f0103536:	83 ec 4c             	sub    $0x4c,%esp
f0103539:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010353c:	89 d6                	mov    %edx,%esi
f010353e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103541:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103544:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103547:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010354a:	8b 45 10             	mov    0x10(%ebp),%eax
f010354d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103550:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103553:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103556:	b9 00 00 00 00       	mov    $0x0,%ecx
f010355b:	39 d1                	cmp    %edx,%ecx
f010355d:	72 15                	jb     f0103574 <printnum+0x44>
f010355f:	77 07                	ja     f0103568 <printnum+0x38>
f0103561:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103564:	39 d0                	cmp    %edx,%eax
f0103566:	76 0c                	jbe    f0103574 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103568:	83 eb 01             	sub    $0x1,%ebx
f010356b:	85 db                	test   %ebx,%ebx
f010356d:	8d 76 00             	lea    0x0(%esi),%esi
f0103570:	7f 61                	jg     f01035d3 <printnum+0xa3>
f0103572:	eb 70                	jmp    f01035e4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103574:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0103578:	83 eb 01             	sub    $0x1,%ebx
f010357b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010357f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103583:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103587:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010358b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010358e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0103591:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103594:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103598:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010359f:	00 
f01035a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035a3:	89 04 24             	mov    %eax,(%esp)
f01035a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035a9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01035ad:	e8 2e 0a 00 00       	call   f0103fe0 <__udivdi3>
f01035b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01035b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01035bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01035c0:	89 04 24             	mov    %eax,(%esp)
f01035c3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01035c7:	89 f2                	mov    %esi,%edx
f01035c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035cc:	e8 5f ff ff ff       	call   f0103530 <printnum>
f01035d1:	eb 11                	jmp    f01035e4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01035d3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035d7:	89 3c 24             	mov    %edi,(%esp)
f01035da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01035dd:	83 eb 01             	sub    $0x1,%ebx
f01035e0:	85 db                	test   %ebx,%ebx
f01035e2:	7f ef                	jg     f01035d3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01035e4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035e8:	8b 74 24 04          	mov    0x4(%esp),%esi
f01035ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01035ef:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01035fa:	00 
f01035fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01035fe:	89 14 24             	mov    %edx,(%esp)
f0103601:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103604:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103608:	e8 03 0b 00 00       	call   f0104110 <__umoddi3>
f010360d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103611:	0f be 80 f2 51 10 f0 	movsbl -0xfefae0e(%eax),%eax
f0103618:	89 04 24             	mov    %eax,(%esp)
f010361b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010361e:	83 c4 4c             	add    $0x4c,%esp
f0103621:	5b                   	pop    %ebx
f0103622:	5e                   	pop    %esi
f0103623:	5f                   	pop    %edi
f0103624:	5d                   	pop    %ebp
f0103625:	c3                   	ret    

f0103626 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103626:	55                   	push   %ebp
f0103627:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103629:	83 fa 01             	cmp    $0x1,%edx
f010362c:	7e 0f                	jle    f010363d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f010362e:	8b 10                	mov    (%eax),%edx
f0103630:	83 c2 08             	add    $0x8,%edx
f0103633:	89 10                	mov    %edx,(%eax)
f0103635:	8b 42 f8             	mov    -0x8(%edx),%eax
f0103638:	8b 52 fc             	mov    -0x4(%edx),%edx
f010363b:	eb 24                	jmp    f0103661 <getuint+0x3b>
	else if (lflag)
f010363d:	85 d2                	test   %edx,%edx
f010363f:	74 11                	je     f0103652 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0103641:	8b 10                	mov    (%eax),%edx
f0103643:	83 c2 04             	add    $0x4,%edx
f0103646:	89 10                	mov    %edx,(%eax)
f0103648:	8b 42 fc             	mov    -0x4(%edx),%eax
f010364b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103650:	eb 0f                	jmp    f0103661 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0103652:	8b 10                	mov    (%eax),%edx
f0103654:	83 c2 04             	add    $0x4,%edx
f0103657:	89 10                	mov    %edx,(%eax)
f0103659:	8b 42 fc             	mov    -0x4(%edx),%eax
f010365c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103661:	5d                   	pop    %ebp
f0103662:	c3                   	ret    

f0103663 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103663:	55                   	push   %ebp
f0103664:	89 e5                	mov    %esp,%ebp
f0103666:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103669:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010366d:	8b 10                	mov    (%eax),%edx
f010366f:	3b 50 04             	cmp    0x4(%eax),%edx
f0103672:	73 0a                	jae    f010367e <sprintputch+0x1b>
		*b->buf++ = ch;
f0103674:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103677:	88 0a                	mov    %cl,(%edx)
f0103679:	83 c2 01             	add    $0x1,%edx
f010367c:	89 10                	mov    %edx,(%eax)
}
f010367e:	5d                   	pop    %ebp
f010367f:	c3                   	ret    

f0103680 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103680:	55                   	push   %ebp
f0103681:	89 e5                	mov    %esp,%ebp
f0103683:	57                   	push   %edi
f0103684:	56                   	push   %esi
f0103685:	53                   	push   %ebx
f0103686:	83 ec 5c             	sub    $0x5c,%esp
f0103689:	8b 7d 08             	mov    0x8(%ebp),%edi
f010368c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010368f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103692:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0103699:	eb 11                	jmp    f01036ac <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010369b:	85 c0                	test   %eax,%eax
f010369d:	0f 84 fd 03 00 00    	je     f0103aa0 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
f01036a3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036a7:	89 04 24             	mov    %eax,(%esp)
f01036aa:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01036ac:	0f b6 03             	movzbl (%ebx),%eax
f01036af:	83 c3 01             	add    $0x1,%ebx
f01036b2:	83 f8 25             	cmp    $0x25,%eax
f01036b5:	75 e4                	jne    f010369b <vprintfmt+0x1b>
f01036b7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01036bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01036c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01036c9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01036d0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01036d5:	eb 06                	jmp    f01036dd <vprintfmt+0x5d>
f01036d7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01036db:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036dd:	0f b6 13             	movzbl (%ebx),%edx
f01036e0:	0f b6 c2             	movzbl %dl,%eax
f01036e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01036e6:	8d 43 01             	lea    0x1(%ebx),%eax
f01036e9:	83 ea 23             	sub    $0x23,%edx
f01036ec:	80 fa 55             	cmp    $0x55,%dl
f01036ef:	0f 87 8e 03 00 00    	ja     f0103a83 <vprintfmt+0x403>
f01036f5:	0f b6 d2             	movzbl %dl,%edx
f01036f8:	ff 24 95 7c 52 10 f0 	jmp    *-0xfefad84(,%edx,4)
f01036ff:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103703:	eb d6                	jmp    f01036db <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103705:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103708:	83 ea 30             	sub    $0x30,%edx
f010370b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
f010370e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0103711:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0103714:	83 fb 09             	cmp    $0x9,%ebx
f0103717:	77 55                	ja     f010376e <vprintfmt+0xee>
f0103719:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010371c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010371f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0103722:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0103725:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0103729:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010372c:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010372f:	83 fb 09             	cmp    $0x9,%ebx
f0103732:	76 eb                	jbe    f010371f <vprintfmt+0x9f>
f0103734:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0103737:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010373a:	eb 32                	jmp    f010376e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010373c:	8b 55 14             	mov    0x14(%ebp),%edx
f010373f:	83 c2 04             	add    $0x4,%edx
f0103742:	89 55 14             	mov    %edx,0x14(%ebp)
f0103745:	8b 52 fc             	mov    -0x4(%edx),%edx
f0103748:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
f010374b:	eb 21                	jmp    f010376e <vprintfmt+0xee>

		case '.':
			if (width < 0)
f010374d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103751:	ba 00 00 00 00       	mov    $0x0,%edx
f0103756:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
f010375a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010375d:	e9 79 ff ff ff       	jmp    f01036db <vprintfmt+0x5b>
f0103762:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0103769:	e9 6d ff ff ff       	jmp    f01036db <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f010376e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103772:	0f 89 63 ff ff ff    	jns    f01036db <vprintfmt+0x5b>
f0103778:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010377b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010377e:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103781:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103784:	e9 52 ff ff ff       	jmp    f01036db <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103789:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f010378c:	e9 4a ff ff ff       	jmp    f01036db <vprintfmt+0x5b>
f0103791:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103794:	8b 45 14             	mov    0x14(%ebp),%eax
f0103797:	83 c0 04             	add    $0x4,%eax
f010379a:	89 45 14             	mov    %eax,0x14(%ebp)
f010379d:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037a1:	8b 40 fc             	mov    -0x4(%eax),%eax
f01037a4:	89 04 24             	mov    %eax,(%esp)
f01037a7:	ff d7                	call   *%edi
f01037a9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f01037ac:	e9 fb fe ff ff       	jmp    f01036ac <vprintfmt+0x2c>
f01037b1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01037b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01037b7:	83 c0 04             	add    $0x4,%eax
f01037ba:	89 45 14             	mov    %eax,0x14(%ebp)
f01037bd:	8b 40 fc             	mov    -0x4(%eax),%eax
f01037c0:	89 c2                	mov    %eax,%edx
f01037c2:	c1 fa 1f             	sar    $0x1f,%edx
f01037c5:	31 d0                	xor    %edx,%eax
f01037c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f01037c9:	83 f8 06             	cmp    $0x6,%eax
f01037cc:	7f 0b                	jg     f01037d9 <vprintfmt+0x159>
f01037ce:	8b 14 85 d4 53 10 f0 	mov    -0xfefac2c(,%eax,4),%edx
f01037d5:	85 d2                	test   %edx,%edx
f01037d7:	75 20                	jne    f01037f9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
f01037d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037dd:	c7 44 24 08 03 52 10 	movl   $0xf0105203,0x8(%esp)
f01037e4:	f0 
f01037e5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037e9:	89 3c 24             	mov    %edi,(%esp)
f01037ec:	e8 37 03 00 00       	call   f0103b28 <printfmt>
f01037f1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f01037f4:	e9 b3 fe ff ff       	jmp    f01036ac <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f01037f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01037fd:	c7 44 24 08 2b 4c 10 	movl   $0xf0104c2b,0x8(%esp)
f0103804:	f0 
f0103805:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103809:	89 3c 24             	mov    %edi,(%esp)
f010380c:	e8 17 03 00 00       	call   f0103b28 <printfmt>
f0103811:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0103814:	e9 93 fe ff ff       	jmp    f01036ac <vprintfmt+0x2c>
f0103819:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010381c:	89 c3                	mov    %eax,%ebx
f010381e:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103821:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103824:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103827:	8b 45 14             	mov    0x14(%ebp),%eax
f010382a:	83 c0 04             	add    $0x4,%eax
f010382d:	89 45 14             	mov    %eax,0x14(%ebp)
f0103830:	8b 40 fc             	mov    -0x4(%eax),%eax
f0103833:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103836:	85 c0                	test   %eax,%eax
f0103838:	b8 0c 52 10 f0       	mov    $0xf010520c,%eax
f010383d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
f0103841:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0103844:	85 c9                	test   %ecx,%ecx
f0103846:	7e 06                	jle    f010384e <vprintfmt+0x1ce>
f0103848:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010384c:	75 13                	jne    f0103861 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010384e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103851:	0f be 02             	movsbl (%edx),%eax
f0103854:	85 c0                	test   %eax,%eax
f0103856:	0f 85 99 00 00 00    	jne    f01038f5 <vprintfmt+0x275>
f010385c:	e9 86 00 00 00       	jmp    f01038e7 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103861:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103865:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103868:	89 0c 24             	mov    %ecx,(%esp)
f010386b:	e8 cb 03 00 00       	call   f0103c3b <strnlen>
f0103870:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103873:	29 c2                	sub    %eax,%edx
f0103875:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103878:	85 d2                	test   %edx,%edx
f010387a:	7e d2                	jle    f010384e <vprintfmt+0x1ce>
					putch(padc, putdat);
f010387c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0103880:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103883:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0103886:	89 d3                	mov    %edx,%ebx
f0103888:	89 74 24 04          	mov    %esi,0x4(%esp)
f010388c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010388f:	89 04 24             	mov    %eax,(%esp)
f0103892:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103894:	83 eb 01             	sub    $0x1,%ebx
f0103897:	85 db                	test   %ebx,%ebx
f0103899:	7f ed                	jg     f0103888 <vprintfmt+0x208>
f010389b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010389e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01038a5:	eb a7                	jmp    f010384e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01038a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01038ab:	74 18                	je     f01038c5 <vprintfmt+0x245>
f01038ad:	8d 50 e0             	lea    -0x20(%eax),%edx
f01038b0:	83 fa 5e             	cmp    $0x5e,%edx
f01038b3:	76 10                	jbe    f01038c5 <vprintfmt+0x245>
					putch('?', putdat);
f01038b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038b9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01038c0:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01038c3:	eb 0a                	jmp    f01038cf <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
f01038c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038c9:	89 04 24             	mov    %eax,(%esp)
f01038cc:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01038cf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01038d3:	0f be 03             	movsbl (%ebx),%eax
f01038d6:	85 c0                	test   %eax,%eax
f01038d8:	74 05                	je     f01038df <vprintfmt+0x25f>
f01038da:	83 c3 01             	add    $0x1,%ebx
f01038dd:	eb 29                	jmp    f0103908 <vprintfmt+0x288>
f01038df:	89 fe                	mov    %edi,%esi
f01038e1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01038e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01038e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01038eb:	7f 2e                	jg     f010391b <vprintfmt+0x29b>
f01038ed:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f01038f0:	e9 b7 fd ff ff       	jmp    f01036ac <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01038f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01038f8:	83 c2 01             	add    $0x1,%edx
f01038fb:	89 7d e0             	mov    %edi,-0x20(%ebp)
f01038fe:	89 f7                	mov    %esi,%edi
f0103900:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103903:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0103906:	89 d3                	mov    %edx,%ebx
f0103908:	85 f6                	test   %esi,%esi
f010390a:	78 9b                	js     f01038a7 <vprintfmt+0x227>
f010390c:	83 ee 01             	sub    $0x1,%esi
f010390f:	79 96                	jns    f01038a7 <vprintfmt+0x227>
f0103911:	89 fe                	mov    %edi,%esi
f0103913:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103916:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103919:	eb cc                	jmp    f01038e7 <vprintfmt+0x267>
f010391b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010391e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103921:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103925:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010392c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010392e:	83 eb 01             	sub    $0x1,%ebx
f0103931:	85 db                	test   %ebx,%ebx
f0103933:	7f ec                	jg     f0103921 <vprintfmt+0x2a1>
f0103935:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0103938:	e9 6f fd ff ff       	jmp    f01036ac <vprintfmt+0x2c>
f010393d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103940:	83 f9 01             	cmp    $0x1,%ecx
f0103943:	7e 17                	jle    f010395c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
f0103945:	8b 45 14             	mov    0x14(%ebp),%eax
f0103948:	83 c0 08             	add    $0x8,%eax
f010394b:	89 45 14             	mov    %eax,0x14(%ebp)
f010394e:	8b 50 f8             	mov    -0x8(%eax),%edx
f0103951:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0103954:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103957:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010395a:	eb 34                	jmp    f0103990 <vprintfmt+0x310>
	else if (lflag)
f010395c:	85 c9                	test   %ecx,%ecx
f010395e:	74 19                	je     f0103979 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
f0103960:	8b 45 14             	mov    0x14(%ebp),%eax
f0103963:	83 c0 04             	add    $0x4,%eax
f0103966:	89 45 14             	mov    %eax,0x14(%ebp)
f0103969:	8b 40 fc             	mov    -0x4(%eax),%eax
f010396c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010396f:	89 c1                	mov    %eax,%ecx
f0103971:	c1 f9 1f             	sar    $0x1f,%ecx
f0103974:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103977:	eb 17                	jmp    f0103990 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
f0103979:	8b 45 14             	mov    0x14(%ebp),%eax
f010397c:	83 c0 04             	add    $0x4,%eax
f010397f:	89 45 14             	mov    %eax,0x14(%ebp)
f0103982:	8b 40 fc             	mov    -0x4(%eax),%eax
f0103985:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103988:	89 c2                	mov    %eax,%edx
f010398a:	c1 fa 1f             	sar    $0x1f,%edx
f010398d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103990:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103993:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103996:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010399b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010399f:	0f 89 9c 00 00 00    	jns    f0103a41 <vprintfmt+0x3c1>
				putch('-', putdat);
f01039a5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01039a9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01039b0:	ff d7                	call   *%edi
				num = -(long long) num;
f01039b2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01039b5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01039b8:	f7 d9                	neg    %ecx
f01039ba:	83 d3 00             	adc    $0x0,%ebx
f01039bd:	f7 db                	neg    %ebx
f01039bf:	b8 0a 00 00 00       	mov    $0xa,%eax
f01039c4:	eb 7b                	jmp    f0103a41 <vprintfmt+0x3c1>
f01039c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01039c9:	89 ca                	mov    %ecx,%edx
f01039cb:	8d 45 14             	lea    0x14(%ebp),%eax
f01039ce:	e8 53 fc ff ff       	call   f0103626 <getuint>
f01039d3:	89 c1                	mov    %eax,%ecx
f01039d5:	89 d3                	mov    %edx,%ebx
f01039d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f01039dc:	eb 63                	jmp    f0103a41 <vprintfmt+0x3c1>
f01039de:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01039e1:	89 ca                	mov    %ecx,%edx
f01039e3:	8d 45 14             	lea    0x14(%ebp),%eax
f01039e6:	e8 3b fc ff ff       	call   f0103626 <getuint>
f01039eb:	89 c1                	mov    %eax,%ecx
f01039ed:	89 d3                	mov    %edx,%ebx
f01039ef:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
f01039f4:	eb 4b                	jmp    f0103a41 <vprintfmt+0x3c1>
f01039f6:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f01039f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01039fd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103a04:	ff d7                	call   *%edi
			putch('x', putdat);
f0103a06:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a0a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103a11:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103a13:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a16:	83 c0 04             	add    $0x4,%eax
f0103a19:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103a1c:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0103a1f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103a24:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103a29:	eb 16                	jmp    f0103a41 <vprintfmt+0x3c1>
f0103a2b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103a2e:	89 ca                	mov    %ecx,%edx
f0103a30:	8d 45 14             	lea    0x14(%ebp),%eax
f0103a33:	e8 ee fb ff ff       	call   f0103626 <getuint>
f0103a38:	89 c1                	mov    %eax,%ecx
f0103a3a:	89 d3                	mov    %edx,%ebx
f0103a3c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103a41:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0103a45:	89 54 24 10          	mov    %edx,0x10(%esp)
f0103a49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103a4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103a50:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a54:	89 0c 24             	mov    %ecx,(%esp)
f0103a57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103a5b:	89 f2                	mov    %esi,%edx
f0103a5d:	89 f8                	mov    %edi,%eax
f0103a5f:	e8 cc fa ff ff       	call   f0103530 <printnum>
f0103a64:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0103a67:	e9 40 fc ff ff       	jmp    f01036ac <vprintfmt+0x2c>
f0103a6c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103a6f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103a72:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a76:	89 14 24             	mov    %edx,(%esp)
f0103a79:	ff d7                	call   *%edi
f0103a7b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0103a7e:	e9 29 fc ff ff       	jmp    f01036ac <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103a83:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a87:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103a8e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103a90:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103a93:	80 38 25             	cmpb   $0x25,(%eax)
f0103a96:	0f 84 10 fc ff ff    	je     f01036ac <vprintfmt+0x2c>
f0103a9c:	89 c3                	mov    %eax,%ebx
f0103a9e:	eb f0                	jmp    f0103a90 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
f0103aa0:	83 c4 5c             	add    $0x5c,%esp
f0103aa3:	5b                   	pop    %ebx
f0103aa4:	5e                   	pop    %esi
f0103aa5:	5f                   	pop    %edi
f0103aa6:	5d                   	pop    %ebp
f0103aa7:	c3                   	ret    

f0103aa8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103aa8:	55                   	push   %ebp
f0103aa9:	89 e5                	mov    %esp,%ebp
f0103aab:	83 ec 28             	sub    $0x28,%esp
f0103aae:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0103ab4:	85 c0                	test   %eax,%eax
f0103ab6:	74 04                	je     f0103abc <vsnprintf+0x14>
f0103ab8:	85 d2                	test   %edx,%edx
f0103aba:	7f 07                	jg     f0103ac3 <vsnprintf+0x1b>
f0103abc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103ac1:	eb 3b                	jmp    f0103afe <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103ac3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ac6:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0103aca:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103acd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103ad4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ad7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103adb:	8b 45 10             	mov    0x10(%ebp),%eax
f0103ade:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ae2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ae9:	c7 04 24 63 36 10 f0 	movl   $0xf0103663,(%esp)
f0103af0:	e8 8b fb ff ff       	call   f0103680 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103af8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0103afe:	c9                   	leave  
f0103aff:	c3                   	ret    

f0103b00 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103b00:	55                   	push   %ebp
f0103b01:	89 e5                	mov    %esp,%ebp
f0103b03:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0103b06:	8d 45 14             	lea    0x14(%ebp),%eax
f0103b09:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b0d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b10:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b14:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b1e:	89 04 24             	mov    %eax,(%esp)
f0103b21:	e8 82 ff ff ff       	call   f0103aa8 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103b26:	c9                   	leave  
f0103b27:	c3                   	ret    

f0103b28 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103b28:	55                   	push   %ebp
f0103b29:	89 e5                	mov    %esp,%ebp
f0103b2b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0103b2e:	8d 45 14             	lea    0x14(%ebp),%eax
f0103b31:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b35:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b38:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b43:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b46:	89 04 24             	mov    %eax,(%esp)
f0103b49:	e8 32 fb ff ff       	call   f0103680 <vprintfmt>
	va_end(ap);
}
f0103b4e:	c9                   	leave  
f0103b4f:	c3                   	ret    

f0103b50 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103b50:	55                   	push   %ebp
f0103b51:	89 e5                	mov    %esp,%ebp
f0103b53:	57                   	push   %edi
f0103b54:	56                   	push   %esi
f0103b55:	53                   	push   %ebx
f0103b56:	83 ec 1c             	sub    $0x1c,%esp
f0103b59:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103b5c:	85 c0                	test   %eax,%eax
f0103b5e:	74 10                	je     f0103b70 <readline+0x20>
		cprintf("%s", prompt);
f0103b60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b64:	c7 04 24 2b 4c 10 f0 	movl   $0xf0104c2b,(%esp)
f0103b6b:	e8 9f ed ff ff       	call   f010290f <cprintf>

	i = 0;
	echoing = iscons(0);
f0103b70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b77:	e8 c5 c7 ff ff       	call   f0100341 <iscons>
f0103b7c:	89 c7                	mov    %eax,%edi
f0103b7e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0103b83:	e8 a8 c7 ff ff       	call   f0100330 <getchar>
f0103b88:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103b8a:	85 c0                	test   %eax,%eax
f0103b8c:	79 17                	jns    f0103ba5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b92:	c7 04 24 f0 53 10 f0 	movl   $0xf01053f0,(%esp)
f0103b99:	e8 71 ed ff ff       	call   f010290f <cprintf>
f0103b9e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0103ba3:	eb 65                	jmp    f0103c0a <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103ba5:	83 f8 1f             	cmp    $0x1f,%eax
f0103ba8:	7e 1f                	jle    f0103bc9 <readline+0x79>
f0103baa:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103bb0:	7f 17                	jg     f0103bc9 <readline+0x79>
			if (echoing)
f0103bb2:	85 ff                	test   %edi,%edi
f0103bb4:	74 08                	je     f0103bbe <readline+0x6e>
				cputchar(c);
f0103bb6:	89 04 24             	mov    %eax,(%esp)
f0103bb9:	e8 a2 ca ff ff       	call   f0100660 <cputchar>
			buf[i++] = c;
f0103bbe:	88 9e 00 bd 15 f0    	mov    %bl,-0xfea4300(%esi)
f0103bc4:	83 c6 01             	add    $0x1,%esi
f0103bc7:	eb ba                	jmp    f0103b83 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0103bc9:	83 fb 08             	cmp    $0x8,%ebx
f0103bcc:	75 15                	jne    f0103be3 <readline+0x93>
f0103bce:	85 f6                	test   %esi,%esi
f0103bd0:	7e 11                	jle    f0103be3 <readline+0x93>
			if (echoing)
f0103bd2:	85 ff                	test   %edi,%edi
f0103bd4:	74 08                	je     f0103bde <readline+0x8e>
				cputchar(c);
f0103bd6:	89 1c 24             	mov    %ebx,(%esp)
f0103bd9:	e8 82 ca ff ff       	call   f0100660 <cputchar>
			i--;
f0103bde:	83 ee 01             	sub    $0x1,%esi
f0103be1:	eb a0                	jmp    f0103b83 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103be3:	83 fb 0a             	cmp    $0xa,%ebx
f0103be6:	74 0a                	je     f0103bf2 <readline+0xa2>
f0103be8:	83 fb 0d             	cmp    $0xd,%ebx
f0103beb:	90                   	nop
f0103bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103bf0:	75 91                	jne    f0103b83 <readline+0x33>
			if (echoing)
f0103bf2:	85 ff                	test   %edi,%edi
f0103bf4:	74 08                	je     f0103bfe <readline+0xae>
				cputchar(c);
f0103bf6:	89 1c 24             	mov    %ebx,(%esp)
f0103bf9:	e8 62 ca ff ff       	call   f0100660 <cputchar>
			buf[i] = 0;
f0103bfe:	c6 86 00 bd 15 f0 00 	movb   $0x0,-0xfea4300(%esi)
f0103c05:	b8 00 bd 15 f0       	mov    $0xf015bd00,%eax
			return buf;
		}
	}
}
f0103c0a:	83 c4 1c             	add    $0x1c,%esp
f0103c0d:	5b                   	pop    %ebx
f0103c0e:	5e                   	pop    %esi
f0103c0f:	5f                   	pop    %edi
f0103c10:	5d                   	pop    %ebp
f0103c11:	c3                   	ret    
	...

f0103c20 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0103c20:	55                   	push   %ebp
f0103c21:	89 e5                	mov    %esp,%ebp
f0103c23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103c26:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c2b:	80 3a 00             	cmpb   $0x0,(%edx)
f0103c2e:	74 09                	je     f0103c39 <strlen+0x19>
		n++;
f0103c30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103c33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103c37:	75 f7                	jne    f0103c30 <strlen+0x10>
		n++;
	return n;
}
f0103c39:	5d                   	pop    %ebp
f0103c3a:	c3                   	ret    

f0103c3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103c3b:	55                   	push   %ebp
f0103c3c:	89 e5                	mov    %esp,%ebp
f0103c3e:	53                   	push   %ebx
f0103c3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c45:	85 c9                	test   %ecx,%ecx
f0103c47:	74 19                	je     f0103c62 <strnlen+0x27>
f0103c49:	80 3b 00             	cmpb   $0x0,(%ebx)
f0103c4c:	74 14                	je     f0103c62 <strnlen+0x27>
f0103c4e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103c53:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c56:	39 c8                	cmp    %ecx,%eax
f0103c58:	74 0d                	je     f0103c67 <strnlen+0x2c>
f0103c5a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0103c5e:	75 f3                	jne    f0103c53 <strnlen+0x18>
f0103c60:	eb 05                	jmp    f0103c67 <strnlen+0x2c>
f0103c62:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103c67:	5b                   	pop    %ebx
f0103c68:	5d                   	pop    %ebp
f0103c69:	c3                   	ret    

f0103c6a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103c6a:	55                   	push   %ebp
f0103c6b:	89 e5                	mov    %esp,%ebp
f0103c6d:	53                   	push   %ebx
f0103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c74:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103c79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103c7d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103c80:	83 c2 01             	add    $0x1,%edx
f0103c83:	84 c9                	test   %cl,%cl
f0103c85:	75 f2                	jne    f0103c79 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103c87:	5b                   	pop    %ebx
f0103c88:	5d                   	pop    %ebp
f0103c89:	c3                   	ret    

f0103c8a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103c8a:	55                   	push   %ebp
f0103c8b:	89 e5                	mov    %esp,%ebp
f0103c8d:	56                   	push   %esi
f0103c8e:	53                   	push   %ebx
f0103c8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c92:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c95:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103c98:	85 f6                	test   %esi,%esi
f0103c9a:	74 18                	je     f0103cb4 <strncpy+0x2a>
f0103c9c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103ca1:	0f b6 1a             	movzbl (%edx),%ebx
f0103ca4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103ca7:	80 3a 01             	cmpb   $0x1,(%edx)
f0103caa:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103cad:	83 c1 01             	add    $0x1,%ecx
f0103cb0:	39 ce                	cmp    %ecx,%esi
f0103cb2:	77 ed                	ja     f0103ca1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103cb4:	5b                   	pop    %ebx
f0103cb5:	5e                   	pop    %esi
f0103cb6:	5d                   	pop    %ebp
f0103cb7:	c3                   	ret    

f0103cb8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103cb8:	55                   	push   %ebp
f0103cb9:	89 e5                	mov    %esp,%ebp
f0103cbb:	56                   	push   %esi
f0103cbc:	53                   	push   %ebx
f0103cbd:	8b 75 08             	mov    0x8(%ebp),%esi
f0103cc0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103cc6:	89 f0                	mov    %esi,%eax
f0103cc8:	85 c9                	test   %ecx,%ecx
f0103cca:	74 27                	je     f0103cf3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0103ccc:	83 e9 01             	sub    $0x1,%ecx
f0103ccf:	74 1d                	je     f0103cee <strlcpy+0x36>
f0103cd1:	0f b6 1a             	movzbl (%edx),%ebx
f0103cd4:	84 db                	test   %bl,%bl
f0103cd6:	74 16                	je     f0103cee <strlcpy+0x36>
			*dst++ = *src++;
f0103cd8:	88 18                	mov    %bl,(%eax)
f0103cda:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103cdd:	83 e9 01             	sub    $0x1,%ecx
f0103ce0:	74 0e                	je     f0103cf0 <strlcpy+0x38>
			*dst++ = *src++;
f0103ce2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103ce5:	0f b6 1a             	movzbl (%edx),%ebx
f0103ce8:	84 db                	test   %bl,%bl
f0103cea:	75 ec                	jne    f0103cd8 <strlcpy+0x20>
f0103cec:	eb 02                	jmp    f0103cf0 <strlcpy+0x38>
f0103cee:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103cf0:	c6 00 00             	movb   $0x0,(%eax)
f0103cf3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0103cf5:	5b                   	pop    %ebx
f0103cf6:	5e                   	pop    %esi
f0103cf7:	5d                   	pop    %ebp
f0103cf8:	c3                   	ret    

f0103cf9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103cf9:	55                   	push   %ebp
f0103cfa:	89 e5                	mov    %esp,%ebp
f0103cfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103cff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103d02:	0f b6 01             	movzbl (%ecx),%eax
f0103d05:	84 c0                	test   %al,%al
f0103d07:	74 15                	je     f0103d1e <strcmp+0x25>
f0103d09:	3a 02                	cmp    (%edx),%al
f0103d0b:	75 11                	jne    f0103d1e <strcmp+0x25>
		p++, q++;
f0103d0d:	83 c1 01             	add    $0x1,%ecx
f0103d10:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103d13:	0f b6 01             	movzbl (%ecx),%eax
f0103d16:	84 c0                	test   %al,%al
f0103d18:	74 04                	je     f0103d1e <strcmp+0x25>
f0103d1a:	3a 02                	cmp    (%edx),%al
f0103d1c:	74 ef                	je     f0103d0d <strcmp+0x14>
f0103d1e:	0f b6 c0             	movzbl %al,%eax
f0103d21:	0f b6 12             	movzbl (%edx),%edx
f0103d24:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103d26:	5d                   	pop    %ebp
f0103d27:	c3                   	ret    

f0103d28 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103d28:	55                   	push   %ebp
f0103d29:	89 e5                	mov    %esp,%ebp
f0103d2b:	53                   	push   %ebx
f0103d2c:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103d32:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0103d35:	85 c0                	test   %eax,%eax
f0103d37:	74 23                	je     f0103d5c <strncmp+0x34>
f0103d39:	0f b6 1a             	movzbl (%edx),%ebx
f0103d3c:	84 db                	test   %bl,%bl
f0103d3e:	74 24                	je     f0103d64 <strncmp+0x3c>
f0103d40:	3a 19                	cmp    (%ecx),%bl
f0103d42:	75 20                	jne    f0103d64 <strncmp+0x3c>
f0103d44:	83 e8 01             	sub    $0x1,%eax
f0103d47:	74 13                	je     f0103d5c <strncmp+0x34>
		n--, p++, q++;
f0103d49:	83 c2 01             	add    $0x1,%edx
f0103d4c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103d4f:	0f b6 1a             	movzbl (%edx),%ebx
f0103d52:	84 db                	test   %bl,%bl
f0103d54:	74 0e                	je     f0103d64 <strncmp+0x3c>
f0103d56:	3a 19                	cmp    (%ecx),%bl
f0103d58:	74 ea                	je     f0103d44 <strncmp+0x1c>
f0103d5a:	eb 08                	jmp    f0103d64 <strncmp+0x3c>
f0103d5c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103d61:	5b                   	pop    %ebx
f0103d62:	5d                   	pop    %ebp
f0103d63:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103d64:	0f b6 02             	movzbl (%edx),%eax
f0103d67:	0f b6 11             	movzbl (%ecx),%edx
f0103d6a:	29 d0                	sub    %edx,%eax
f0103d6c:	eb f3                	jmp    f0103d61 <strncmp+0x39>

f0103d6e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103d6e:	55                   	push   %ebp
f0103d6f:	89 e5                	mov    %esp,%ebp
f0103d71:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d74:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d78:	0f b6 10             	movzbl (%eax),%edx
f0103d7b:	84 d2                	test   %dl,%dl
f0103d7d:	74 15                	je     f0103d94 <strchr+0x26>
		if (*s == c)
f0103d7f:	38 ca                	cmp    %cl,%dl
f0103d81:	75 07                	jne    f0103d8a <strchr+0x1c>
f0103d83:	eb 14                	jmp    f0103d99 <strchr+0x2b>
f0103d85:	38 ca                	cmp    %cl,%dl
f0103d87:	90                   	nop
f0103d88:	74 0f                	je     f0103d99 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103d8a:	83 c0 01             	add    $0x1,%eax
f0103d8d:	0f b6 10             	movzbl (%eax),%edx
f0103d90:	84 d2                	test   %dl,%dl
f0103d92:	75 f1                	jne    f0103d85 <strchr+0x17>
f0103d94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0103d99:	5d                   	pop    %ebp
f0103d9a:	c3                   	ret    

f0103d9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103d9b:	55                   	push   %ebp
f0103d9c:	89 e5                	mov    %esp,%ebp
f0103d9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103da1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103da5:	0f b6 10             	movzbl (%eax),%edx
f0103da8:	84 d2                	test   %dl,%dl
f0103daa:	74 18                	je     f0103dc4 <strfind+0x29>
		if (*s == c)
f0103dac:	38 ca                	cmp    %cl,%dl
f0103dae:	75 0a                	jne    f0103dba <strfind+0x1f>
f0103db0:	eb 12                	jmp    f0103dc4 <strfind+0x29>
f0103db2:	38 ca                	cmp    %cl,%dl
f0103db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103db8:	74 0a                	je     f0103dc4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103dba:	83 c0 01             	add    $0x1,%eax
f0103dbd:	0f b6 10             	movzbl (%eax),%edx
f0103dc0:	84 d2                	test   %dl,%dl
f0103dc2:	75 ee                	jne    f0103db2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0103dc4:	5d                   	pop    %ebp
f0103dc5:	c3                   	ret    

f0103dc6 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0103dc6:	55                   	push   %ebp
f0103dc7:	89 e5                	mov    %esp,%ebp
f0103dc9:	53                   	push   %ebx
f0103dca:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0103dd3:	89 da                	mov    %ebx,%edx
f0103dd5:	83 ea 01             	sub    $0x1,%edx
f0103dd8:	78 0d                	js     f0103de7 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f0103dda:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f0103ddc:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f0103dde:	88 0a                	mov    %cl,(%edx)
f0103de0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0103de3:	39 da                	cmp    %ebx,%edx
f0103de5:	75 f7                	jne    f0103dde <memset+0x18>
		*p++ = c;

	return v;
}
f0103de7:	5b                   	pop    %ebx
f0103de8:	5d                   	pop    %ebp
f0103de9:	c3                   	ret    

f0103dea <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103dea:	55                   	push   %ebp
f0103deb:	89 e5                	mov    %esp,%ebp
f0103ded:	56                   	push   %esi
f0103dee:	53                   	push   %ebx
f0103def:	8b 45 08             	mov    0x8(%ebp),%eax
f0103df2:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103df5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0103df8:	85 db                	test   %ebx,%ebx
f0103dfa:	74 13                	je     f0103e0f <memcpy+0x25>
f0103dfc:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f0103e01:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0103e05:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103e08:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0103e0b:	39 da                	cmp    %ebx,%edx
f0103e0d:	75 f2                	jne    f0103e01 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f0103e0f:	5b                   	pop    %ebx
f0103e10:	5e                   	pop    %esi
f0103e11:	5d                   	pop    %ebp
f0103e12:	c3                   	ret    

f0103e13 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103e13:	55                   	push   %ebp
f0103e14:	89 e5                	mov    %esp,%ebp
f0103e16:	57                   	push   %edi
f0103e17:	56                   	push   %esi
f0103e18:	53                   	push   %ebx
f0103e19:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e1c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f0103e22:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f0103e24:	39 c6                	cmp    %eax,%esi
f0103e26:	72 0b                	jb     f0103e33 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f0103e28:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f0103e2d:	85 db                	test   %ebx,%ebx
f0103e2f:	75 2e                	jne    f0103e5f <memmove+0x4c>
f0103e31:	eb 3a                	jmp    f0103e6d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103e33:	01 df                	add    %ebx,%edi
f0103e35:	39 f8                	cmp    %edi,%eax
f0103e37:	73 ef                	jae    f0103e28 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f0103e39:	85 db                	test   %ebx,%ebx
f0103e3b:	90                   	nop
f0103e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103e40:	74 2b                	je     f0103e6d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0103e42:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f0103e45:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f0103e4a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f0103e4f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f0103e53:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0103e56:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0103e59:	85 c9                	test   %ecx,%ecx
f0103e5b:	75 ed                	jne    f0103e4a <memmove+0x37>
f0103e5d:	eb 0e                	jmp    f0103e6d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0103e5f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0103e63:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103e66:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0103e69:	39 d3                	cmp    %edx,%ebx
f0103e6b:	75 f2                	jne    f0103e5f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
f0103e6d:	5b                   	pop    %ebx
f0103e6e:	5e                   	pop    %esi
f0103e6f:	5f                   	pop    %edi
f0103e70:	5d                   	pop    %ebp
f0103e71:	c3                   	ret    

f0103e72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103e72:	55                   	push   %ebp
f0103e73:	89 e5                	mov    %esp,%ebp
f0103e75:	57                   	push   %edi
f0103e76:	56                   	push   %esi
f0103e77:	53                   	push   %ebx
f0103e78:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103e7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103e81:	85 c9                	test   %ecx,%ecx
f0103e83:	74 36                	je     f0103ebb <memcmp+0x49>
		if (*s1 != *s2)
f0103e85:	0f b6 06             	movzbl (%esi),%eax
f0103e88:	0f b6 1f             	movzbl (%edi),%ebx
f0103e8b:	38 d8                	cmp    %bl,%al
f0103e8d:	74 20                	je     f0103eaf <memcmp+0x3d>
f0103e8f:	eb 14                	jmp    f0103ea5 <memcmp+0x33>
f0103e91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0103e96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0103e9b:	83 c2 01             	add    $0x1,%edx
f0103e9e:	83 e9 01             	sub    $0x1,%ecx
f0103ea1:	38 d8                	cmp    %bl,%al
f0103ea3:	74 12                	je     f0103eb7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0103ea5:	0f b6 c0             	movzbl %al,%eax
f0103ea8:	0f b6 db             	movzbl %bl,%ebx
f0103eab:	29 d8                	sub    %ebx,%eax
f0103ead:	eb 11                	jmp    f0103ec0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103eaf:	83 e9 01             	sub    $0x1,%ecx
f0103eb2:	ba 00 00 00 00       	mov    $0x0,%edx
f0103eb7:	85 c9                	test   %ecx,%ecx
f0103eb9:	75 d6                	jne    f0103e91 <memcmp+0x1f>
f0103ebb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0103ec0:	5b                   	pop    %ebx
f0103ec1:	5e                   	pop    %esi
f0103ec2:	5f                   	pop    %edi
f0103ec3:	5d                   	pop    %ebp
f0103ec4:	c3                   	ret    

f0103ec5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103ec5:	55                   	push   %ebp
f0103ec6:	89 e5                	mov    %esp,%ebp
f0103ec8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103ecb:	89 c2                	mov    %eax,%edx
f0103ecd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103ed0:	39 d0                	cmp    %edx,%eax
f0103ed2:	73 15                	jae    f0103ee9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103ed4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0103ed8:	38 08                	cmp    %cl,(%eax)
f0103eda:	75 06                	jne    f0103ee2 <memfind+0x1d>
f0103edc:	eb 0b                	jmp    f0103ee9 <memfind+0x24>
f0103ede:	38 08                	cmp    %cl,(%eax)
f0103ee0:	74 07                	je     f0103ee9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103ee2:	83 c0 01             	add    $0x1,%eax
f0103ee5:	39 c2                	cmp    %eax,%edx
f0103ee7:	77 f5                	ja     f0103ede <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103ee9:	5d                   	pop    %ebp
f0103eea:	c3                   	ret    

f0103eeb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103eeb:	55                   	push   %ebp
f0103eec:	89 e5                	mov    %esp,%ebp
f0103eee:	57                   	push   %edi
f0103eef:	56                   	push   %esi
f0103ef0:	53                   	push   %ebx
f0103ef1:	83 ec 04             	sub    $0x4,%esp
f0103ef4:	8b 55 08             	mov    0x8(%ebp),%edx
f0103ef7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103efa:	0f b6 02             	movzbl (%edx),%eax
f0103efd:	3c 20                	cmp    $0x20,%al
f0103eff:	74 04                	je     f0103f05 <strtol+0x1a>
f0103f01:	3c 09                	cmp    $0x9,%al
f0103f03:	75 0e                	jne    f0103f13 <strtol+0x28>
		s++;
f0103f05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103f08:	0f b6 02             	movzbl (%edx),%eax
f0103f0b:	3c 20                	cmp    $0x20,%al
f0103f0d:	74 f6                	je     f0103f05 <strtol+0x1a>
f0103f0f:	3c 09                	cmp    $0x9,%al
f0103f11:	74 f2                	je     f0103f05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103f13:	3c 2b                	cmp    $0x2b,%al
f0103f15:	75 0c                	jne    f0103f23 <strtol+0x38>
		s++;
f0103f17:	83 c2 01             	add    $0x1,%edx
f0103f1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0103f21:	eb 15                	jmp    f0103f38 <strtol+0x4d>
	else if (*s == '-')
f0103f23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0103f2a:	3c 2d                	cmp    $0x2d,%al
f0103f2c:	75 0a                	jne    f0103f38 <strtol+0x4d>
		s++, neg = 1;
f0103f2e:	83 c2 01             	add    $0x1,%edx
f0103f31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103f38:	85 db                	test   %ebx,%ebx
f0103f3a:	0f 94 c0             	sete   %al
f0103f3d:	74 05                	je     f0103f44 <strtol+0x59>
f0103f3f:	83 fb 10             	cmp    $0x10,%ebx
f0103f42:	75 18                	jne    f0103f5c <strtol+0x71>
f0103f44:	80 3a 30             	cmpb   $0x30,(%edx)
f0103f47:	75 13                	jne    f0103f5c <strtol+0x71>
f0103f49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103f4d:	8d 76 00             	lea    0x0(%esi),%esi
f0103f50:	75 0a                	jne    f0103f5c <strtol+0x71>
		s += 2, base = 16;
f0103f52:	83 c2 02             	add    $0x2,%edx
f0103f55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103f5a:	eb 15                	jmp    f0103f71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103f5c:	84 c0                	test   %al,%al
f0103f5e:	66 90                	xchg   %ax,%ax
f0103f60:	74 0f                	je     f0103f71 <strtol+0x86>
f0103f62:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0103f67:	80 3a 30             	cmpb   $0x30,(%edx)
f0103f6a:	75 05                	jne    f0103f71 <strtol+0x86>
		s++, base = 8;
f0103f6c:	83 c2 01             	add    $0x1,%edx
f0103f6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103f71:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103f78:	0f b6 0a             	movzbl (%edx),%ecx
f0103f7b:	89 cf                	mov    %ecx,%edi
f0103f7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103f80:	80 fb 09             	cmp    $0x9,%bl
f0103f83:	77 08                	ja     f0103f8d <strtol+0xa2>
			dig = *s - '0';
f0103f85:	0f be c9             	movsbl %cl,%ecx
f0103f88:	83 e9 30             	sub    $0x30,%ecx
f0103f8b:	eb 1e                	jmp    f0103fab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0103f8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0103f90:	80 fb 19             	cmp    $0x19,%bl
f0103f93:	77 08                	ja     f0103f9d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0103f95:	0f be c9             	movsbl %cl,%ecx
f0103f98:	83 e9 57             	sub    $0x57,%ecx
f0103f9b:	eb 0e                	jmp    f0103fab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0103f9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0103fa0:	80 fb 19             	cmp    $0x19,%bl
f0103fa3:	77 15                	ja     f0103fba <strtol+0xcf>
			dig = *s - 'A' + 10;
f0103fa5:	0f be c9             	movsbl %cl,%ecx
f0103fa8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103fab:	39 f1                	cmp    %esi,%ecx
f0103fad:	7d 0b                	jge    f0103fba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0103faf:	83 c2 01             	add    $0x1,%edx
f0103fb2:	0f af c6             	imul   %esi,%eax
f0103fb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0103fb8:	eb be                	jmp    f0103f78 <strtol+0x8d>
f0103fba:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0103fbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103fc0:	74 05                	je     f0103fc7 <strtol+0xdc>
		*endptr = (char *) s;
f0103fc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103fc5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103fc7:	89 ca                	mov    %ecx,%edx
f0103fc9:	f7 da                	neg    %edx
f0103fcb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0103fcf:	0f 45 c2             	cmovne %edx,%eax
}
f0103fd2:	83 c4 04             	add    $0x4,%esp
f0103fd5:	5b                   	pop    %ebx
f0103fd6:	5e                   	pop    %esi
f0103fd7:	5f                   	pop    %edi
f0103fd8:	5d                   	pop    %ebp
f0103fd9:	c3                   	ret    
f0103fda:	00 00                	add    %al,(%eax)
f0103fdc:	00 00                	add    %al,(%eax)
	...

f0103fe0 <__udivdi3>:
f0103fe0:	55                   	push   %ebp
f0103fe1:	89 e5                	mov    %esp,%ebp
f0103fe3:	57                   	push   %edi
f0103fe4:	56                   	push   %esi
f0103fe5:	83 ec 10             	sub    $0x10,%esp
f0103fe8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103feb:	8b 55 08             	mov    0x8(%ebp),%edx
f0103fee:	8b 75 10             	mov    0x10(%ebp),%esi
f0103ff1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103ff4:	85 c0                	test   %eax,%eax
f0103ff6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0103ff9:	75 35                	jne    f0104030 <__udivdi3+0x50>
f0103ffb:	39 fe                	cmp    %edi,%esi
f0103ffd:	77 61                	ja     f0104060 <__udivdi3+0x80>
f0103fff:	85 f6                	test   %esi,%esi
f0104001:	75 0b                	jne    f010400e <__udivdi3+0x2e>
f0104003:	b8 01 00 00 00       	mov    $0x1,%eax
f0104008:	31 d2                	xor    %edx,%edx
f010400a:	f7 f6                	div    %esi
f010400c:	89 c6                	mov    %eax,%esi
f010400e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104011:	31 d2                	xor    %edx,%edx
f0104013:	89 f8                	mov    %edi,%eax
f0104015:	f7 f6                	div    %esi
f0104017:	89 c7                	mov    %eax,%edi
f0104019:	89 c8                	mov    %ecx,%eax
f010401b:	f7 f6                	div    %esi
f010401d:	89 c1                	mov    %eax,%ecx
f010401f:	89 fa                	mov    %edi,%edx
f0104021:	89 c8                	mov    %ecx,%eax
f0104023:	83 c4 10             	add    $0x10,%esp
f0104026:	5e                   	pop    %esi
f0104027:	5f                   	pop    %edi
f0104028:	5d                   	pop    %ebp
f0104029:	c3                   	ret    
f010402a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104030:	39 f8                	cmp    %edi,%eax
f0104032:	77 1c                	ja     f0104050 <__udivdi3+0x70>
f0104034:	0f bd d0             	bsr    %eax,%edx
f0104037:	83 f2 1f             	xor    $0x1f,%edx
f010403a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010403d:	75 39                	jne    f0104078 <__udivdi3+0x98>
f010403f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104042:	0f 86 a0 00 00 00    	jbe    f01040e8 <__udivdi3+0x108>
f0104048:	39 f8                	cmp    %edi,%eax
f010404a:	0f 82 98 00 00 00    	jb     f01040e8 <__udivdi3+0x108>
f0104050:	31 ff                	xor    %edi,%edi
f0104052:	31 c9                	xor    %ecx,%ecx
f0104054:	89 c8                	mov    %ecx,%eax
f0104056:	89 fa                	mov    %edi,%edx
f0104058:	83 c4 10             	add    $0x10,%esp
f010405b:	5e                   	pop    %esi
f010405c:	5f                   	pop    %edi
f010405d:	5d                   	pop    %ebp
f010405e:	c3                   	ret    
f010405f:	90                   	nop
f0104060:	89 d1                	mov    %edx,%ecx
f0104062:	89 fa                	mov    %edi,%edx
f0104064:	89 c8                	mov    %ecx,%eax
f0104066:	31 ff                	xor    %edi,%edi
f0104068:	f7 f6                	div    %esi
f010406a:	89 c1                	mov    %eax,%ecx
f010406c:	89 fa                	mov    %edi,%edx
f010406e:	89 c8                	mov    %ecx,%eax
f0104070:	83 c4 10             	add    $0x10,%esp
f0104073:	5e                   	pop    %esi
f0104074:	5f                   	pop    %edi
f0104075:	5d                   	pop    %ebp
f0104076:	c3                   	ret    
f0104077:	90                   	nop
f0104078:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010407c:	89 f2                	mov    %esi,%edx
f010407e:	d3 e0                	shl    %cl,%eax
f0104080:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104083:	b8 20 00 00 00       	mov    $0x20,%eax
f0104088:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010408b:	89 c1                	mov    %eax,%ecx
f010408d:	d3 ea                	shr    %cl,%edx
f010408f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104093:	0b 55 ec             	or     -0x14(%ebp),%edx
f0104096:	d3 e6                	shl    %cl,%esi
f0104098:	89 c1                	mov    %eax,%ecx
f010409a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010409d:	89 fe                	mov    %edi,%esi
f010409f:	d3 ee                	shr    %cl,%esi
f01040a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01040a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01040a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01040ab:	d3 e7                	shl    %cl,%edi
f01040ad:	89 c1                	mov    %eax,%ecx
f01040af:	d3 ea                	shr    %cl,%edx
f01040b1:	09 d7                	or     %edx,%edi
f01040b3:	89 f2                	mov    %esi,%edx
f01040b5:	89 f8                	mov    %edi,%eax
f01040b7:	f7 75 ec             	divl   -0x14(%ebp)
f01040ba:	89 d6                	mov    %edx,%esi
f01040bc:	89 c7                	mov    %eax,%edi
f01040be:	f7 65 e8             	mull   -0x18(%ebp)
f01040c1:	39 d6                	cmp    %edx,%esi
f01040c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01040c6:	72 30                	jb     f01040f8 <__udivdi3+0x118>
f01040c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01040cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01040cf:	d3 e2                	shl    %cl,%edx
f01040d1:	39 c2                	cmp    %eax,%edx
f01040d3:	73 05                	jae    f01040da <__udivdi3+0xfa>
f01040d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f01040d8:	74 1e                	je     f01040f8 <__udivdi3+0x118>
f01040da:	89 f9                	mov    %edi,%ecx
f01040dc:	31 ff                	xor    %edi,%edi
f01040de:	e9 71 ff ff ff       	jmp    f0104054 <__udivdi3+0x74>
f01040e3:	90                   	nop
f01040e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01040e8:	31 ff                	xor    %edi,%edi
f01040ea:	b9 01 00 00 00       	mov    $0x1,%ecx
f01040ef:	e9 60 ff ff ff       	jmp    f0104054 <__udivdi3+0x74>
f01040f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01040f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f01040fb:	31 ff                	xor    %edi,%edi
f01040fd:	89 c8                	mov    %ecx,%eax
f01040ff:	89 fa                	mov    %edi,%edx
f0104101:	83 c4 10             	add    $0x10,%esp
f0104104:	5e                   	pop    %esi
f0104105:	5f                   	pop    %edi
f0104106:	5d                   	pop    %ebp
f0104107:	c3                   	ret    
	...

f0104110 <__umoddi3>:
f0104110:	55                   	push   %ebp
f0104111:	89 e5                	mov    %esp,%ebp
f0104113:	57                   	push   %edi
f0104114:	56                   	push   %esi
f0104115:	83 ec 20             	sub    $0x20,%esp
f0104118:	8b 55 14             	mov    0x14(%ebp),%edx
f010411b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010411e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104121:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104124:	85 d2                	test   %edx,%edx
f0104126:	89 c8                	mov    %ecx,%eax
f0104128:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010412b:	75 13                	jne    f0104140 <__umoddi3+0x30>
f010412d:	39 f7                	cmp    %esi,%edi
f010412f:	76 3f                	jbe    f0104170 <__umoddi3+0x60>
f0104131:	89 f2                	mov    %esi,%edx
f0104133:	f7 f7                	div    %edi
f0104135:	89 d0                	mov    %edx,%eax
f0104137:	31 d2                	xor    %edx,%edx
f0104139:	83 c4 20             	add    $0x20,%esp
f010413c:	5e                   	pop    %esi
f010413d:	5f                   	pop    %edi
f010413e:	5d                   	pop    %ebp
f010413f:	c3                   	ret    
f0104140:	39 f2                	cmp    %esi,%edx
f0104142:	77 4c                	ja     f0104190 <__umoddi3+0x80>
f0104144:	0f bd ca             	bsr    %edx,%ecx
f0104147:	83 f1 1f             	xor    $0x1f,%ecx
f010414a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010414d:	75 51                	jne    f01041a0 <__umoddi3+0x90>
f010414f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0104152:	0f 87 e0 00 00 00    	ja     f0104238 <__umoddi3+0x128>
f0104158:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010415b:	29 f8                	sub    %edi,%eax
f010415d:	19 d6                	sbb    %edx,%esi
f010415f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104162:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104165:	89 f2                	mov    %esi,%edx
f0104167:	83 c4 20             	add    $0x20,%esp
f010416a:	5e                   	pop    %esi
f010416b:	5f                   	pop    %edi
f010416c:	5d                   	pop    %ebp
f010416d:	c3                   	ret    
f010416e:	66 90                	xchg   %ax,%ax
f0104170:	85 ff                	test   %edi,%edi
f0104172:	75 0b                	jne    f010417f <__umoddi3+0x6f>
f0104174:	b8 01 00 00 00       	mov    $0x1,%eax
f0104179:	31 d2                	xor    %edx,%edx
f010417b:	f7 f7                	div    %edi
f010417d:	89 c7                	mov    %eax,%edi
f010417f:	89 f0                	mov    %esi,%eax
f0104181:	31 d2                	xor    %edx,%edx
f0104183:	f7 f7                	div    %edi
f0104185:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104188:	f7 f7                	div    %edi
f010418a:	eb a9                	jmp    f0104135 <__umoddi3+0x25>
f010418c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104190:	89 c8                	mov    %ecx,%eax
f0104192:	89 f2                	mov    %esi,%edx
f0104194:	83 c4 20             	add    $0x20,%esp
f0104197:	5e                   	pop    %esi
f0104198:	5f                   	pop    %edi
f0104199:	5d                   	pop    %ebp
f010419a:	c3                   	ret    
f010419b:	90                   	nop
f010419c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01041a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01041a4:	d3 e2                	shl    %cl,%edx
f01041a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01041a9:	ba 20 00 00 00       	mov    $0x20,%edx
f01041ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
f01041b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01041b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01041b8:	89 fa                	mov    %edi,%edx
f01041ba:	d3 ea                	shr    %cl,%edx
f01041bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01041c0:	0b 55 f4             	or     -0xc(%ebp),%edx
f01041c3:	d3 e7                	shl    %cl,%edi
f01041c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01041c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01041cc:	89 f2                	mov    %esi,%edx
f01041ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
f01041d1:	89 c7                	mov    %eax,%edi
f01041d3:	d3 ea                	shr    %cl,%edx
f01041d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01041d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01041dc:	89 c2                	mov    %eax,%edx
f01041de:	d3 e6                	shl    %cl,%esi
f01041e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01041e4:	d3 ea                	shr    %cl,%edx
f01041e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01041ea:	09 d6                	or     %edx,%esi
f01041ec:	89 f0                	mov    %esi,%eax
f01041ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01041f1:	d3 e7                	shl    %cl,%edi
f01041f3:	89 f2                	mov    %esi,%edx
f01041f5:	f7 75 f4             	divl   -0xc(%ebp)
f01041f8:	89 d6                	mov    %edx,%esi
f01041fa:	f7 65 e8             	mull   -0x18(%ebp)
f01041fd:	39 d6                	cmp    %edx,%esi
f01041ff:	72 2b                	jb     f010422c <__umoddi3+0x11c>
f0104201:	39 c7                	cmp    %eax,%edi
f0104203:	72 23                	jb     f0104228 <__umoddi3+0x118>
f0104205:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104209:	29 c7                	sub    %eax,%edi
f010420b:	19 d6                	sbb    %edx,%esi
f010420d:	89 f0                	mov    %esi,%eax
f010420f:	89 f2                	mov    %esi,%edx
f0104211:	d3 ef                	shr    %cl,%edi
f0104213:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104217:	d3 e0                	shl    %cl,%eax
f0104219:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010421d:	09 f8                	or     %edi,%eax
f010421f:	d3 ea                	shr    %cl,%edx
f0104221:	83 c4 20             	add    $0x20,%esp
f0104224:	5e                   	pop    %esi
f0104225:	5f                   	pop    %edi
f0104226:	5d                   	pop    %ebp
f0104227:	c3                   	ret    
f0104228:	39 d6                	cmp    %edx,%esi
f010422a:	75 d9                	jne    f0104205 <__umoddi3+0xf5>
f010422c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010422f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0104232:	eb d1                	jmp    f0104205 <__umoddi3+0xf5>
f0104234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104238:	39 f2                	cmp    %esi,%edx
f010423a:	0f 82 18 ff ff ff    	jb     f0104158 <__umoddi3+0x48>
f0104240:	e9 1d ff ff ff       	jmp    f0104162 <__umoddi3+0x52>
