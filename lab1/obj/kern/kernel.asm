
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
f0100015:	0f 01 15 18 f0 10 00 	lgdtl  0x10f018

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

        # Set the stack pointer
	movl	$(bootstacktop),%esp
f0100033:	bc 00 f0 10 f0       	mov    $0xf010f000,%esp

	# now to C code
	call	i386_init
f0100038:	e8 fd 00 00 00       	call   f010013a <i386_init>

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
f0100054:	c7 04 24 20 17 10 f0 	movl   $0xf0101720,(%esp)
f010005b:	e8 6f 09 00 00       	call   f01009cf <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 2a 09 00 00       	call   f010099c <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 cb 17 10 f0 	movl   $0xf01017cb,(%esp)
f0100079:	e8 51 09 00 00       	call   f01009cf <cprintf>
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
f0100086:	83 3d 20 f3 10 f0 00 	cmpl   $0x0,0xf010f320
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 20 f3 10 f0       	mov    %eax,0xf010f320

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 3a 17 10 f0 	movl   $0xf010173a,(%esp)
f01000ac:	e8 1e 09 00 00       	call   f01009cf <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 d9 08 00 00       	call   f010099c <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 cb 17 10 f0 	movl   $0xf01017cb,(%esp)
f01000ca:	e8 00 09 00 00       	call   f01009cf <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 8b 07 00 00       	call   f0100866 <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	53                   	push   %ebx
f01000e1:	83 ec 14             	sub    $0x14,%esp
f01000e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000eb:	c7 04 24 52 17 10 f0 	movl   $0xf0101752,(%esp)
f01000f2:	e8 d8 08 00 00       	call   f01009cf <cprintf>
	if (x > 0)
f01000f7:	85 db                	test   %ebx,%ebx
f01000f9:	7e 0d                	jle    f0100108 <test_backtrace+0x2b>
		test_backtrace(x-1);
f01000fb:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01000fe:	89 04 24             	mov    %eax,(%esp)
f0100101:	e8 d7 ff ff ff       	call   f01000dd <test_backtrace>
f0100106:	eb 1c                	jmp    f0100124 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f0100108:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010010f:	00 
f0100110:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100117:	00 
f0100118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010011f:	e8 a4 05 00 00       	call   f01006c8 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100128:	c7 04 24 6e 17 10 f0 	movl   $0xf010176e,(%esp)
f010012f:	e8 9b 08 00 00       	call   f01009cf <cprintf>
}
f0100134:	83 c4 14             	add    $0x14,%esp
f0100137:	5b                   	pop    %ebx
f0100138:	5d                   	pop    %ebp
f0100139:	c3                   	ret    

f010013a <i386_init>:

void
i386_init(void)
{
f010013a:	55                   	push   %ebp
f010013b:	89 e5                	mov    %esp,%ebp
f010013d:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100140:	b8 80 f9 10 f0       	mov    $0xf010f980,%eax
f0100145:	2d 20 f3 10 f0       	sub    $0xf010f320,%eax
f010014a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010014e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100155:	00 
f0100156:	c7 04 24 20 f3 10 f0 	movl   $0xf010f320,(%esp)
f010015d:	e8 34 11 00 00       	call   f0101296 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100162:	e8 24 02 00 00       	call   f010038b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100167:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010016e:	00 
f010016f:	c7 04 24 89 17 10 f0 	movl   $0xf0101789,(%esp)
f0100176:	e8 54 08 00 00       	call   f01009cf <cprintf>




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010017b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100182:	e8 56 ff ff ff       	call   f01000dd <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100187:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010018e:	e8 d3 06 00 00       	call   f0100866 <monitor>
f0100193:	eb f2                	jmp    f0100187 <i386_init+0x4d>
	...

f01001a0 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001b0:	f6 c2 01             	test   $0x1,%dl
f01001b3:	74 09                	je     f01001be <serial_proc_data+0x1e>
f01001b5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001ba:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001bb:	0f b6 c0             	movzbl %al,%eax
}
f01001be:	5d                   	pop    %ebp
f01001bf:	c3                   	ret    

f01001c0 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp
f01001c3:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001c4:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01001c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ce:	89 da                	mov    %ebx,%edx
f01001d0:	ee                   	out    %al,(%dx)
f01001d1:	b2 fb                	mov    $0xfb,%dl
f01001d3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01001d8:	ee                   	out    %al,(%dx)
f01001d9:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01001de:	b8 0c 00 00 00       	mov    $0xc,%eax
f01001e3:	89 ca                	mov    %ecx,%edx
f01001e5:	ee                   	out    %al,(%dx)
f01001e6:	b2 f9                	mov    $0xf9,%dl
f01001e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ed:	ee                   	out    %al,(%dx)
f01001ee:	b2 fb                	mov    $0xfb,%dl
f01001f0:	b8 03 00 00 00       	mov    $0x3,%eax
f01001f5:	ee                   	out    %al,(%dx)
f01001f6:	b2 fc                	mov    $0xfc,%dl
f01001f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001fd:	ee                   	out    %al,(%dx)
f01001fe:	b2 f9                	mov    $0xf9,%dl
f0100200:	b8 01 00 00 00       	mov    $0x1,%eax
f0100205:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100206:	b2 fd                	mov    $0xfd,%dl
f0100208:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100209:	3c ff                	cmp    $0xff,%al
f010020b:	0f 95 c0             	setne  %al
f010020e:	0f b6 c0             	movzbl %al,%eax
f0100211:	a3 44 f3 10 f0       	mov    %eax,0xf010f344
f0100216:	89 da                	mov    %ebx,%edx
f0100218:	ec                   	in     (%dx),%al
f0100219:	89 ca                	mov    %ecx,%edx
f010021b:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010021c:	5b                   	pop    %ebx
f010021d:	5d                   	pop    %ebp
f010021e:	c3                   	ret    

f010021f <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010021f:	55                   	push   %ebp
f0100220:	89 e5                	mov    %esp,%ebp
f0100222:	83 ec 0c             	sub    $0xc,%esp
f0100225:	89 1c 24             	mov    %ebx,(%esp)
f0100228:	89 74 24 04          	mov    %esi,0x4(%esp)
f010022c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100230:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100235:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100238:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010023d:	0f b7 00             	movzwl (%eax),%eax
f0100240:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100244:	74 11                	je     f0100257 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100246:	c7 05 48 f3 10 f0 b4 	movl   $0x3b4,0xf010f348
f010024d:	03 00 00 
f0100250:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100255:	eb 16                	jmp    f010026d <cga_init+0x4e>
	} else {
		*cp = was;
f0100257:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010025e:	c7 05 48 f3 10 f0 d4 	movl   $0x3d4,0xf010f348
f0100265:	03 00 00 
f0100268:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010026d:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f0100273:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100275:	b8 0e 00 00 00       	mov    $0xe,%eax
f010027a:	89 ca                	mov    %ecx,%edx
f010027c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010027d:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100280:	89 ca                	mov    %ecx,%edx
f0100282:	ec                   	in     (%dx),%al
f0100283:	0f b6 f8             	movzbl %al,%edi
f0100286:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100289:	b8 0f 00 00 00       	mov    $0xf,%eax
f010028e:	89 da                	mov    %ebx,%edx
f0100290:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100291:	89 ca                	mov    %ecx,%edx
f0100293:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100294:	89 35 4c f3 10 f0    	mov    %esi,0xf010f34c
	crt_pos = pos;
f010029a:	0f b6 c8             	movzbl %al,%ecx
f010029d:	09 cf                	or     %ecx,%edi
f010029f:	66 89 3d 50 f3 10 f0 	mov    %di,0xf010f350
}
f01002a6:	8b 1c 24             	mov    (%esp),%ebx
f01002a9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01002ad:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01002b1:	89 ec                	mov    %ebp,%esp
f01002b3:	5d                   	pop    %ebp
f01002b4:	c3                   	ret    

f01002b5 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f01002b5:	55                   	push   %ebp
f01002b6:	89 e5                	mov    %esp,%ebp
}
f01002b8:	5d                   	pop    %ebp
f01002b9:	c3                   	ret    

f01002ba <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01002ba:	55                   	push   %ebp
f01002bb:	89 e5                	mov    %esp,%ebp
f01002bd:	57                   	push   %edi
f01002be:	56                   	push   %esi
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002c6:	bb 64 f5 10 f0       	mov    $0xf010f564,%ebx
f01002cb:	bf 60 f3 10 f0       	mov    $0xf010f360,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002d0:	eb 1b                	jmp    f01002ed <cons_intr+0x33>
		if (c == 0)
f01002d2:	85 c0                	test   %eax,%eax
f01002d4:	74 17                	je     f01002ed <cons_intr+0x33>
			continue;
		cons.buf[cons.wpos++] = c;
f01002d6:	8b 13                	mov    (%ebx),%edx
f01002d8:	88 04 3a             	mov    %al,(%edx,%edi,1)
f01002db:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002de:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01002e8:	0f 44 c2             	cmove  %edx,%eax
f01002eb:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002ed:	ff d6                	call   *%esi
f01002ef:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f2:	75 de                	jne    f01002d2 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002f4:	83 c4 0c             	add    $0xc,%esp
f01002f7:	5b                   	pop    %ebx
f01002f8:	5e                   	pop    %esi
f01002f9:	5f                   	pop    %edi
f01002fa:	5d                   	pop    %ebp
f01002fb:	c3                   	ret    

f01002fc <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01002fc:	55                   	push   %ebp
f01002fd:	89 e5                	mov    %esp,%ebp
f01002ff:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100302:	c7 04 24 b2 03 10 f0 	movl   $0xf01003b2,(%esp)
f0100309:	e8 ac ff ff ff       	call   f01002ba <cons_intr>
}
f010030e:	c9                   	leave  
f010030f:	c3                   	ret    

f0100310 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100310:	55                   	push   %ebp
f0100311:	89 e5                	mov    %esp,%ebp
f0100313:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100316:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f010031d:	74 0c                	je     f010032b <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f010031f:	c7 04 24 a0 01 10 f0 	movl   $0xf01001a0,(%esp)
f0100326:	e8 8f ff ff ff       	call   f01002ba <cons_intr>
}
f010032b:	c9                   	leave  
f010032c:	c3                   	ret    

f010032d <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010032d:	55                   	push   %ebp
f010032e:	89 e5                	mov    %esp,%ebp
f0100330:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100333:	e8 d8 ff ff ff       	call   f0100310 <serial_intr>
	kbd_intr();
f0100338:	e8 bf ff ff ff       	call   f01002fc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010033d:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
f0100343:	b8 00 00 00 00       	mov    $0x0,%eax
f0100348:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f010034e:	74 1e                	je     f010036e <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100350:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f0100357:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010035a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100360:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100365:	0f 44 d1             	cmove  %ecx,%edx
f0100368:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f010036e:	c9                   	leave  
f010036f:	c3                   	ret    

f0100370 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100370:	55                   	push   %ebp
f0100371:	89 e5                	mov    %esp,%ebp
f0100373:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100376:	e8 b2 ff ff ff       	call   f010032d <cons_getc>
f010037b:	85 c0                	test   %eax,%eax
f010037d:	74 f7                	je     f0100376 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010037f:	c9                   	leave  
f0100380:	c3                   	ret    

f0100381 <iscons>:

int
iscons(int fdnum)
{
f0100381:	55                   	push   %ebp
f0100382:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100384:	b8 01 00 00 00       	mov    $0x1,%eax
f0100389:	5d                   	pop    %ebp
f010038a:	c3                   	ret    

f010038b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010038b:	55                   	push   %ebp
f010038c:	89 e5                	mov    %esp,%ebp
f010038e:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100391:	e8 89 fe ff ff       	call   f010021f <cga_init>
	kbd_init();
	serial_init();
f0100396:	e8 25 fe ff ff       	call   f01001c0 <serial_init>

	if (!serial_exists)
f010039b:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f01003a2:	75 0c                	jne    f01003b0 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01003a4:	c7 04 24 a4 17 10 f0 	movl   $0xf01017a4,(%esp)
f01003ab:	e8 1f 06 00 00       	call   f01009cf <cprintf>
}
f01003b0:	c9                   	leave  
f01003b1:	c3                   	ret    

f01003b2 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003b2:	55                   	push   %ebp
f01003b3:	89 e5                	mov    %esp,%ebp
f01003b5:	53                   	push   %ebx
f01003b6:	83 ec 14             	sub    $0x14,%esp
f01003b9:	ba 64 00 00 00       	mov    $0x64,%edx
f01003be:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003bf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003c4:	a8 01                	test   $0x1,%al
f01003c6:	0f 84 dd 00 00 00    	je     f01004a9 <kbd_proc_data+0xf7>
f01003cc:	b2 60                	mov    $0x60,%dl
f01003ce:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003cf:	3c e0                	cmp    $0xe0,%al
f01003d1:	75 11                	jne    f01003e4 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01003d3:	83 0d 40 f3 10 f0 40 	orl    $0x40,0xf010f340
f01003da:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01003df:	e9 c5 00 00 00       	jmp    f01004a9 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f01003e4:	84 c0                	test   %al,%al
f01003e6:	79 35                	jns    f010041d <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003e8:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f01003ee:	89 c1                	mov    %eax,%ecx
f01003f0:	83 e1 7f             	and    $0x7f,%ecx
f01003f3:	f6 c2 40             	test   $0x40,%dl
f01003f6:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01003f9:	0f b6 c0             	movzbl %al,%eax
f01003fc:	0f b6 80 e0 17 10 f0 	movzbl -0xfefe820(%eax),%eax
f0100403:	83 c8 40             	or     $0x40,%eax
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	f7 d0                	not    %eax
f010040b:	21 c2                	and    %eax,%edx
f010040d:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
f0100413:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100418:	e9 8c 00 00 00       	jmp    f01004a9 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f010041d:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100423:	f6 c2 40             	test   $0x40,%dl
f0100426:	74 0c                	je     f0100434 <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100428:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010042b:	83 e2 bf             	and    $0xffffffbf,%edx
f010042e:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
	}

	shift |= shiftcode[data];
f0100434:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f0100437:	0f b6 90 e0 17 10 f0 	movzbl -0xfefe820(%eax),%edx
f010043e:	0b 15 40 f3 10 f0    	or     0xf010f340,%edx
f0100444:	0f b6 88 e0 18 10 f0 	movzbl -0xfefe720(%eax),%ecx
f010044b:	31 ca                	xor    %ecx,%edx
f010044d:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340

	c = charcode[shift & (CTL | SHIFT)][data];
f0100453:	89 d1                	mov    %edx,%ecx
f0100455:	83 e1 03             	and    $0x3,%ecx
f0100458:	8b 0c 8d e0 19 10 f0 	mov    -0xfefe620(,%ecx,4),%ecx
f010045f:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100463:	f6 c2 08             	test   $0x8,%dl
f0100466:	74 1b                	je     f0100483 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100468:	89 d9                	mov    %ebx,%ecx
f010046a:	8d 43 9f             	lea    -0x61(%ebx),%eax
f010046d:	83 f8 19             	cmp    $0x19,%eax
f0100470:	77 05                	ja     f0100477 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100472:	83 eb 20             	sub    $0x20,%ebx
f0100475:	eb 0c                	jmp    f0100483 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100477:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f010047a:	8d 43 20             	lea    0x20(%ebx),%eax
f010047d:	83 f9 19             	cmp    $0x19,%ecx
f0100480:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100483:	f7 d2                	not    %edx
f0100485:	f6 c2 06             	test   $0x6,%dl
f0100488:	75 1f                	jne    f01004a9 <kbd_proc_data+0xf7>
f010048a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100490:	75 17                	jne    f01004a9 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f0100492:	c7 04 24 c1 17 10 f0 	movl   $0xf01017c1,(%esp)
f0100499:	e8 31 05 00 00       	call   f01009cf <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010049e:	ba 92 00 00 00       	mov    $0x92,%edx
f01004a3:	b8 03 00 00 00       	mov    $0x3,%eax
f01004a8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004a9:	89 d8                	mov    %ebx,%eax
f01004ab:	83 c4 14             	add    $0x14,%esp
f01004ae:	5b                   	pop    %ebx
f01004af:	5d                   	pop    %ebp
f01004b0:	c3                   	ret    

f01004b1 <cga_putc>:



void
cga_putc(int c)
{
f01004b1:	55                   	push   %ebp
f01004b2:	89 e5                	mov    %esp,%ebp
f01004b4:	56                   	push   %esi
f01004b5:	53                   	push   %ebx
f01004b6:	83 ec 10             	sub    $0x10,%esp
f01004b9:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f01004bc:	89 c2                	mov    %eax,%edx
f01004be:	80 ce 07             	or     $0x7,%dh
f01004c1:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01004c6:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f01004c9:	0f b6 d0             	movzbl %al,%edx
f01004cc:	83 fa 09             	cmp    $0x9,%edx
f01004cf:	0f 84 88 00 00 00    	je     f010055d <cga_putc+0xac>
f01004d5:	83 fa 09             	cmp    $0x9,%edx
f01004d8:	7f 10                	jg     f01004ea <cga_putc+0x39>
f01004da:	83 fa 08             	cmp    $0x8,%edx
f01004dd:	0f 85 b8 00 00 00    	jne    f010059b <cga_putc+0xea>
f01004e3:	90                   	nop
f01004e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004e8:	eb 18                	jmp    f0100502 <cga_putc+0x51>
f01004ea:	83 fa 0a             	cmp    $0xa,%edx
f01004ed:	8d 76 00             	lea    0x0(%esi),%esi
f01004f0:	74 41                	je     f0100533 <cga_putc+0x82>
f01004f2:	83 fa 0d             	cmp    $0xd,%edx
f01004f5:	8d 76 00             	lea    0x0(%esi),%esi
f01004f8:	0f 85 9d 00 00 00    	jne    f010059b <cga_putc+0xea>
f01004fe:	66 90                	xchg   %ax,%ax
f0100500:	eb 39                	jmp    f010053b <cga_putc+0x8a>
	case '\b':
		if (crt_pos > 0) {
f0100502:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f0100509:	66 85 d2             	test   %dx,%dx
f010050c:	0f 84 f4 00 00 00    	je     f0100606 <cga_putc+0x155>
			crt_pos--;
f0100512:	83 ea 01             	sub    $0x1,%edx
f0100515:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010051c:	0f b7 d2             	movzwl %dx,%edx
f010051f:	b0 00                	mov    $0x0,%al
f0100521:	83 c8 20             	or     $0x20,%eax
f0100524:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f010052a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010052e:	e9 86 00 00 00       	jmp    f01005b9 <cga_putc+0x108>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100533:	66 83 05 50 f3 10 f0 	addw   $0x50,0xf010f350
f010053a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010053b:	0f b7 05 50 f3 10 f0 	movzwl 0xf010f350,%eax
f0100542:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100548:	c1 e8 10             	shr    $0x10,%eax
f010054b:	66 c1 e8 06          	shr    $0x6,%ax
f010054f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100552:	c1 e0 04             	shl    $0x4,%eax
f0100555:	66 a3 50 f3 10 f0    	mov    %ax,0xf010f350
		break;
f010055b:	eb 5c                	jmp    f01005b9 <cga_putc+0x108>
	case '\t':
		cons_putc(' ');
f010055d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100564:	e8 d4 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100569:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100570:	e8 c8 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100575:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010057c:	e8 bc 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100581:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100588:	e8 b0 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f010058d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100594:	e8 a4 00 00 00       	call   f010063d <cons_putc>
		break;
f0100599:	eb 1e                	jmp    f01005b9 <cga_putc+0x108>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010059b:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f01005a2:	0f b7 da             	movzwl %dx,%ebx
f01005a5:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f01005ab:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005af:	83 c2 01             	add    $0x1,%edx
f01005b2:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005b9:	66 81 3d 50 f3 10 f0 	cmpw   $0x7cf,0xf010f350
f01005c0:	cf 07 
f01005c2:	76 42                	jbe    f0100606 <cga_putc+0x155>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005c4:	a1 4c f3 10 f0       	mov    0xf010f34c,%eax
f01005c9:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005d0:	00 
f01005d1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005d7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005db:	89 04 24             	mov    %eax,(%esp)
f01005de:	e8 d7 0c 00 00       	call   f01012ba <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005e3:	8b 15 4c f3 10 f0    	mov    0xf010f34c,%edx
f01005e9:	b8 80 07 00 00       	mov    $0x780,%eax
f01005ee:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005f4:	83 c0 01             	add    $0x1,%eax
f01005f7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005fc:	75 f0                	jne    f01005ee <cga_putc+0x13d>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005fe:	66 83 2d 50 f3 10 f0 	subw   $0x50,0xf010f350
f0100605:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100606:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010060c:	89 cb                	mov    %ecx,%ebx
f010060e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100616:	0f b7 35 50 f3 10 f0 	movzwl 0xf010f350,%esi
f010061d:	83 c1 01             	add    $0x1,%ecx
f0100620:	89 f0                	mov    %esi,%eax
f0100622:	66 c1 e8 08          	shr    $0x8,%ax
f0100626:	89 ca                	mov    %ecx,%edx
f0100628:	ee                   	out    %al,(%dx)
f0100629:	b8 0f 00 00 00       	mov    $0xf,%eax
f010062e:	89 da                	mov    %ebx,%edx
f0100630:	ee                   	out    %al,(%dx)
f0100631:	89 f0                	mov    %esi,%eax
f0100633:	89 ca                	mov    %ecx,%edx
f0100635:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100636:	83 c4 10             	add    $0x10,%esp
f0100639:	5b                   	pop    %ebx
f010063a:	5e                   	pop    %esi
f010063b:	5d                   	pop    %ebp
f010063c:	c3                   	ret    

f010063d <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f010063d:	55                   	push   %ebp
f010063e:	89 e5                	mov    %esp,%ebp
f0100640:	57                   	push   %edi
f0100641:	56                   	push   %esi
f0100642:	53                   	push   %ebx
f0100643:	83 ec 1c             	sub    $0x1c,%esp
f0100646:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100649:	ba 79 03 00 00       	mov    $0x379,%edx
f010064e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010064f:	84 c0                	test   %al,%al
f0100651:	78 27                	js     f010067a <cons_putc+0x3d>
f0100653:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100658:	b9 84 00 00 00       	mov    $0x84,%ecx
f010065d:	be 79 03 00 00       	mov    $0x379,%esi
f0100662:	89 ca                	mov    %ecx,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	ec                   	in     (%dx),%al
f0100666:	ec                   	in     (%dx),%al
f0100667:	ec                   	in     (%dx),%al
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	84 c0                	test   %al,%al
f010066d:	78 0b                	js     f010067a <cons_putc+0x3d>
f010066f:	83 c3 01             	add    $0x1,%ebx
f0100672:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100678:	75 e8                	jne    f0100662 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010067a:	ba 78 03 00 00       	mov    $0x378,%edx
f010067f:	89 f8                	mov    %edi,%eax
f0100681:	ee                   	out    %al,(%dx)
f0100682:	b2 7a                	mov    $0x7a,%dl
f0100684:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100689:	ee                   	out    %al,(%dx)
f010068a:	b8 08 00 00 00       	mov    $0x8,%eax
f010068f:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f0100690:	89 3c 24             	mov    %edi,(%esp)
f0100693:	e8 19 fe ff ff       	call   f01004b1 <cga_putc>
}
f0100698:	83 c4 1c             	add    $0x1c,%esp
f010069b:	5b                   	pop    %ebx
f010069c:	5e                   	pop    %esi
f010069d:	5f                   	pop    %edi
f010069e:	5d                   	pop    %ebp
f010069f:	c3                   	ret    

f01006a0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
f01006a3:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a9:	89 04 24             	mov    %eax,(%esp)
f01006ac:	e8 8c ff ff ff       	call   f010063d <cons_putc>
}
f01006b1:	c9                   	leave  
f01006b2:	c3                   	ret    
	...

f01006c0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006c3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006c6:	5d                   	pop    %ebp
f01006c7:	c3                   	ret    

f01006c8 <mon_backtrace>:
	return 0;
}

int  
mon_backtrace(int argc, char **argv, struct Trapframe *tf)  
{  
f01006c8:	55                   	push   %ebp
f01006c9:	89 e5                	mov    %esp,%ebp
f01006cb:	57                   	push   %edi
f01006cc:	56                   	push   %esi
f01006cd:	53                   	push   %ebx
f01006ce:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01006d1:	89 ef                	mov    %ebp,%edi
	uint32_t eip = eip;  
	uint32_t ebp = read_ebp();  
	cprintf("Stack backtrace:\n");
f01006d3:	c7 04 24 f0 19 10 f0 	movl   $0xf01019f0,(%esp)
f01006da:	e8 f0 02 00 00       	call   f01009cf <cprintf>
    
	uint32_t esp = ebp;  
	int j = 0;    
	while (ebp != 0) {  
f01006df:	85 ff                	test   %edi,%edi
f01006e1:	74 5e                	je     f0100741 <mon_backtrace+0x79>
f01006e3:	89 fe                	mov    %edi,%esi
            cprintf("ebp %08x eip %08x ", ebp, eip);  
f01006e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01006e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01006f0:	c7 04 24 02 1a 10 f0 	movl   $0xf0101a02,(%esp)
f01006f7:	e8 d3 02 00 00       	call   f01009cf <cprintf>
            ebp = *(uint32_t *)(esp);  
f01006fc:	8b 3f                	mov    (%edi),%edi
            esp += 4; // read the next address 
            eip = *(uint32_t *)(esp);  
f01006fe:	8b 46 04             	mov    0x4(%esi),%eax
f0100701:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            esp += 4;
            
            cprintf("args "); // disply 5 arguments 
f0100704:	c7 04 24 15 1a 10 f0 	movl   $0xf0101a15,(%esp)
f010070b:	e8 bf 02 00 00       	call   f01009cf <cprintf>
f0100710:	bb 00 00 00 00       	mov    $0x0,%ebx
            for (j = 0; j < 5; j++) {  
                cprintf("%08x ", *(uint32_t *)(esp));  
f0100715:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100719:	89 44 24 04          	mov    %eax,0x4(%esp)
f010071d:	c7 04 24 0f 1a 10 f0 	movl   $0xf0101a0f,(%esp)
f0100724:	e8 a6 02 00 00       	call   f01009cf <cprintf>
            esp += 4; // read the next address 
            eip = *(uint32_t *)(esp);  
            esp += 4;
            
            cprintf("args "); // disply 5 arguments 
            for (j = 0; j < 5; j++) {  
f0100729:	83 c3 01             	add    $0x1,%ebx
f010072c:	83 fb 05             	cmp    $0x5,%ebx
f010072f:	75 e4                	jne    f0100715 <mon_backtrace+0x4d>
                cprintf("%08x ", *(uint32_t *)(esp));  
                esp += 4;  
            }  
            cprintf("\n");  
f0100731:	c7 04 24 cb 17 10 f0 	movl   $0xf01017cb,(%esp)
f0100738:	e8 92 02 00 00       	call   f01009cf <cprintf>
	uint32_t ebp = read_ebp();  
	cprintf("Stack backtrace:\n");
    
	uint32_t esp = ebp;  
	int j = 0;    
	while (ebp != 0) {  
f010073d:	85 ff                	test   %edi,%edi
f010073f:	75 a2                	jne    f01006e3 <mon_backtrace+0x1b>
            }  
            cprintf("\n");  
            esp = ebp;  
	}
	return 0;
}
f0100741:	b8 00 00 00 00       	mov    $0x0,%eax
f0100746:	83 c4 2c             	add    $0x2c,%esp
f0100749:	5b                   	pop    %ebx
f010074a:	5e                   	pop    %esi
f010074b:	5f                   	pop    %edi
f010074c:	5d                   	pop    %ebp
f010074d:	c3                   	ret    

f010074e <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010074e:	55                   	push   %ebp
f010074f:	89 e5                	mov    %esp,%ebp
f0100751:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100754:	c7 04 24 1b 1a 10 f0 	movl   $0xf0101a1b,(%esp)
f010075b:	e8 6f 02 00 00       	call   f01009cf <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100760:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100767:	00 
f0100768:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010076f:	f0 
f0100770:	c7 04 24 b0 1a 10 f0 	movl   $0xf0101ab0,(%esp)
f0100777:	e8 53 02 00 00       	call   f01009cf <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010077c:	c7 44 24 08 15 17 10 	movl   $0x101715,0x8(%esp)
f0100783:	00 
f0100784:	c7 44 24 04 15 17 10 	movl   $0xf0101715,0x4(%esp)
f010078b:	f0 
f010078c:	c7 04 24 d4 1a 10 f0 	movl   $0xf0101ad4,(%esp)
f0100793:	e8 37 02 00 00       	call   f01009cf <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100798:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f010079f:	00 
f01007a0:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f01007a7:	f0 
f01007a8:	c7 04 24 f8 1a 10 f0 	movl   $0xf0101af8,(%esp)
f01007af:	e8 1b 02 00 00       	call   f01009cf <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007b4:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f01007bb:	00 
f01007bc:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f01007c3:	f0 
f01007c4:	c7 04 24 1c 1b 10 f0 	movl   $0xf0101b1c,(%esp)
f01007cb:	e8 ff 01 00 00       	call   f01009cf <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007d0:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f01007d5:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007da:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007e0:	85 c0                	test   %eax,%eax
f01007e2:	0f 48 c2             	cmovs  %edx,%eax
f01007e5:	c1 f8 0a             	sar    $0xa,%eax
f01007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ec:	c7 04 24 40 1b 10 f0 	movl   $0xf0101b40,(%esp)
f01007f3:	e8 d7 01 00 00       	call   f01009cf <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f01007f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fd:	c9                   	leave  
f01007fe:	c3                   	ret    

f01007ff <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007ff:	55                   	push   %ebp
f0100800:	89 e5                	mov    %esp,%ebp
f0100802:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100805:	a1 24 1c 10 f0       	mov    0xf0101c24,%eax
f010080a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010080e:	a1 20 1c 10 f0       	mov    0xf0101c20,%eax
f0100813:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100817:	c7 04 24 34 1a 10 f0 	movl   $0xf0101a34,(%esp)
f010081e:	e8 ac 01 00 00       	call   f01009cf <cprintf>
f0100823:	a1 30 1c 10 f0       	mov    0xf0101c30,%eax
f0100828:	89 44 24 08          	mov    %eax,0x8(%esp)
f010082c:	a1 2c 1c 10 f0       	mov    0xf0101c2c,%eax
f0100831:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100835:	c7 04 24 34 1a 10 f0 	movl   $0xf0101a34,(%esp)
f010083c:	e8 8e 01 00 00       	call   f01009cf <cprintf>
f0100841:	a1 3c 1c 10 f0       	mov    0xf0101c3c,%eax
f0100846:	89 44 24 08          	mov    %eax,0x8(%esp)
f010084a:	a1 38 1c 10 f0       	mov    0xf0101c38,%eax
f010084f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100853:	c7 04 24 34 1a 10 f0 	movl   $0xf0101a34,(%esp)
f010085a:	e8 70 01 00 00       	call   f01009cf <cprintf>
	return 0;
}
f010085f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100864:	c9                   	leave  
f0100865:	c3                   	ret    

f0100866 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100866:	55                   	push   %ebp
f0100867:	89 e5                	mov    %esp,%ebp
f0100869:	57                   	push   %edi
f010086a:	56                   	push   %esi
f010086b:	53                   	push   %ebx
f010086c:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010086f:	c7 04 24 6c 1b 10 f0 	movl   $0xf0101b6c,(%esp)
f0100876:	e8 54 01 00 00       	call   f01009cf <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010087b:	c7 04 24 90 1b 10 f0 	movl   $0xf0101b90,(%esp)
f0100882:	e8 48 01 00 00       	call   f01009cf <cprintf>


	while (1) {
		buf = readline("K> ");
f0100887:	c7 04 24 3d 1a 10 f0 	movl   $0xf0101a3d,(%esp)
f010088e:	e8 8d 07 00 00       	call   f0101020 <readline>
f0100893:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100895:	85 c0                	test   %eax,%eax
f0100897:	74 ee                	je     f0100887 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100899:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f01008a0:	be 00 00 00 00       	mov    $0x0,%esi
f01008a5:	eb 06                	jmp    f01008ad <monitor+0x47>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008a7:	c6 03 00             	movb   $0x0,(%ebx)
f01008aa:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008ad:	0f b6 03             	movzbl (%ebx),%eax
f01008b0:	84 c0                	test   %al,%al
f01008b2:	74 6a                	je     f010091e <monitor+0xb8>
f01008b4:	0f be c0             	movsbl %al,%eax
f01008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008bb:	c7 04 24 41 1a 10 f0 	movl   $0xf0101a41,(%esp)
f01008c2:	e8 77 09 00 00       	call   f010123e <strchr>
f01008c7:	85 c0                	test   %eax,%eax
f01008c9:	75 dc                	jne    f01008a7 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f01008cb:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008ce:	74 4e                	je     f010091e <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008d0:	83 fe 0f             	cmp    $0xf,%esi
f01008d3:	75 16                	jne    f01008eb <monitor+0x85>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008d5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008dc:	00 
f01008dd:	c7 04 24 46 1a 10 f0 	movl   $0xf0101a46,(%esp)
f01008e4:	e8 e6 00 00 00       	call   f01009cf <cprintf>
f01008e9:	eb 9c                	jmp    f0100887 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f01008eb:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008ef:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008f2:	0f b6 03             	movzbl (%ebx),%eax
f01008f5:	84 c0                	test   %al,%al
f01008f7:	75 0c                	jne    f0100905 <monitor+0x9f>
f01008f9:	eb b2                	jmp    f01008ad <monitor+0x47>
			buf++;
f01008fb:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008fe:	0f b6 03             	movzbl (%ebx),%eax
f0100901:	84 c0                	test   %al,%al
f0100903:	74 a8                	je     f01008ad <monitor+0x47>
f0100905:	0f be c0             	movsbl %al,%eax
f0100908:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090c:	c7 04 24 41 1a 10 f0 	movl   $0xf0101a41,(%esp)
f0100913:	e8 26 09 00 00       	call   f010123e <strchr>
f0100918:	85 c0                	test   %eax,%eax
f010091a:	74 df                	je     f01008fb <monitor+0x95>
f010091c:	eb 8f                	jmp    f01008ad <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f010091e:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100925:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100926:	85 f6                	test   %esi,%esi
f0100928:	0f 84 59 ff ff ff    	je     f0100887 <monitor+0x21>
f010092e:	bb 20 1c 10 f0       	mov    $0xf0101c20,%ebx
f0100933:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100938:	8b 03                	mov    (%ebx),%eax
f010093a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100941:	89 04 24             	mov    %eax,(%esp)
f0100944:	e8 80 08 00 00       	call   f01011c9 <strcmp>
f0100949:	85 c0                	test   %eax,%eax
f010094b:	75 23                	jne    f0100970 <monitor+0x10a>
			return commands[i].func(argc, argv, tf);
f010094d:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100950:	8b 45 08             	mov    0x8(%ebp),%eax
f0100953:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100957:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010095a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010095e:	89 34 24             	mov    %esi,(%esp)
f0100961:	ff 97 28 1c 10 f0    	call   *-0xfefe3d8(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100967:	85 c0                	test   %eax,%eax
f0100969:	78 28                	js     f0100993 <monitor+0x12d>
f010096b:	e9 17 ff ff ff       	jmp    f0100887 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100970:	83 c7 01             	add    $0x1,%edi
f0100973:	83 c3 0c             	add    $0xc,%ebx
f0100976:	83 ff 03             	cmp    $0x3,%edi
f0100979:	75 bd                	jne    f0100938 <monitor+0xd2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010097b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010097e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100982:	c7 04 24 63 1a 10 f0 	movl   $0xf0101a63,(%esp)
f0100989:	e8 41 00 00 00       	call   f01009cf <cprintf>
f010098e:	e9 f4 fe ff ff       	jmp    f0100887 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100993:	83 c4 5c             	add    $0x5c,%esp
f0100996:	5b                   	pop    %ebx
f0100997:	5e                   	pop    %esi
f0100998:	5f                   	pop    %edi
f0100999:	5d                   	pop    %ebp
f010099a:	c3                   	ret    
	...

f010099c <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f010099c:	55                   	push   %ebp
f010099d:	89 e5                	mov    %esp,%ebp
f010099f:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01009a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01009ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01009b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009be:	c7 04 24 e9 09 10 f0 	movl   $0xf01009e9,(%esp)
f01009c5:	e8 86 01 00 00       	call   f0100b50 <vprintfmt>
	return cnt;
}
f01009ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009cd:	c9                   	leave  
f01009ce:	c3                   	ret    

f01009cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009cf:	55                   	push   %ebp
f01009d0:	89 e5                	mov    %esp,%ebp
f01009d2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f01009d5:	8d 45 0c             	lea    0xc(%ebp),%eax
f01009d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01009df:	89 04 24             	mov    %eax,(%esp)
f01009e2:	e8 b5 ff ff ff       	call   f010099c <vcprintf>
	va_end(ap);

	return cnt;
}
f01009e7:	c9                   	leave  
f01009e8:	c3                   	ret    

f01009e9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009e9:	55                   	push   %ebp
f01009ea:	89 e5                	mov    %esp,%ebp
f01009ec:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01009ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01009f2:	89 04 24             	mov    %eax,(%esp)
f01009f5:	e8 a6 fc ff ff       	call   f01006a0 <cputchar>
	*cnt++;
}
f01009fa:	c9                   	leave  
f01009fb:	c3                   	ret    
f01009fc:	00 00                	add    %al,(%eax)
	...

f0100a00 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100a00:	55                   	push   %ebp
f0100a01:	89 e5                	mov    %esp,%ebp
f0100a03:	57                   	push   %edi
f0100a04:	56                   	push   %esi
f0100a05:	53                   	push   %ebx
f0100a06:	83 ec 4c             	sub    $0x4c,%esp
f0100a09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100a0c:	89 d6                	mov    %edx,%esi
f0100a0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a11:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100a14:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100a17:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a1a:	8b 45 10             	mov    0x10(%ebp),%eax
f0100a1d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100a20:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100a23:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100a26:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100a2b:	39 d1                	cmp    %edx,%ecx
f0100a2d:	72 15                	jb     f0100a44 <printnum+0x44>
f0100a2f:	77 07                	ja     f0100a38 <printnum+0x38>
f0100a31:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a34:	39 d0                	cmp    %edx,%eax
f0100a36:	76 0c                	jbe    f0100a44 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a38:	83 eb 01             	sub    $0x1,%ebx
f0100a3b:	85 db                	test   %ebx,%ebx
f0100a3d:	8d 76 00             	lea    0x0(%esi),%esi
f0100a40:	7f 61                	jg     f0100aa3 <printnum+0xa3>
f0100a42:	eb 70                	jmp    f0100ab4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100a44:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100a48:	83 eb 01             	sub    $0x1,%ebx
f0100a4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a4f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a53:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0100a57:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0100a5b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100a5e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100a61:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100a64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100a68:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a6f:	00 
f0100a70:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a73:	89 04 24             	mov    %eax,(%esp)
f0100a76:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100a79:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a7d:	e8 2e 0a 00 00       	call   f01014b0 <__udivdi3>
f0100a82:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100a85:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100a88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a8c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a90:	89 04 24             	mov    %eax,(%esp)
f0100a93:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a97:	89 f2                	mov    %esi,%edx
f0100a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a9c:	e8 5f ff ff ff       	call   f0100a00 <printnum>
f0100aa1:	eb 11                	jmp    f0100ab4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100aa3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100aa7:	89 3c 24             	mov    %edi,(%esp)
f0100aaa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100aad:	83 eb 01             	sub    $0x1,%ebx
f0100ab0:	85 db                	test   %ebx,%ebx
f0100ab2:	7f ef                	jg     f0100aa3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ab4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ab8:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100abc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100abf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ac3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100aca:	00 
f0100acb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100ace:	89 14 24             	mov    %edx,(%esp)
f0100ad1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ad4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100ad8:	e8 03 0b 00 00       	call   f01015e0 <__umoddi3>
f0100add:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ae1:	0f be 80 44 1c 10 f0 	movsbl -0xfefe3bc(%eax),%eax
f0100ae8:	89 04 24             	mov    %eax,(%esp)
f0100aeb:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100aee:	83 c4 4c             	add    $0x4c,%esp
f0100af1:	5b                   	pop    %ebx
f0100af2:	5e                   	pop    %esi
f0100af3:	5f                   	pop    %edi
f0100af4:	5d                   	pop    %ebp
f0100af5:	c3                   	ret    

f0100af6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100af6:	55                   	push   %ebp
f0100af7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100af9:	83 fa 01             	cmp    $0x1,%edx
f0100afc:	7e 0f                	jle    f0100b0d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f0100afe:	8b 10                	mov    (%eax),%edx
f0100b00:	83 c2 08             	add    $0x8,%edx
f0100b03:	89 10                	mov    %edx,(%eax)
f0100b05:	8b 42 f8             	mov    -0x8(%edx),%eax
f0100b08:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100b0b:	eb 24                	jmp    f0100b31 <getuint+0x3b>
	else if (lflag)
f0100b0d:	85 d2                	test   %edx,%edx
f0100b0f:	74 11                	je     f0100b22 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0100b11:	8b 10                	mov    (%eax),%edx
f0100b13:	83 c2 04             	add    $0x4,%edx
f0100b16:	89 10                	mov    %edx,(%eax)
f0100b18:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100b1b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100b20:	eb 0f                	jmp    f0100b31 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0100b22:	8b 10                	mov    (%eax),%edx
f0100b24:	83 c2 04             	add    $0x4,%edx
f0100b27:	89 10                	mov    %edx,(%eax)
f0100b29:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100b2c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100b31:	5d                   	pop    %ebp
f0100b32:	c3                   	ret    

f0100b33 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100b33:	55                   	push   %ebp
f0100b34:	89 e5                	mov    %esp,%ebp
f0100b36:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100b39:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100b3d:	8b 10                	mov    (%eax),%edx
f0100b3f:	3b 50 04             	cmp    0x4(%eax),%edx
f0100b42:	73 0a                	jae    f0100b4e <sprintputch+0x1b>
		*b->buf++ = ch;
f0100b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100b47:	88 0a                	mov    %cl,(%edx)
f0100b49:	83 c2 01             	add    $0x1,%edx
f0100b4c:	89 10                	mov    %edx,(%eax)
}
f0100b4e:	5d                   	pop    %ebp
f0100b4f:	c3                   	ret    

f0100b50 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100b50:	55                   	push   %ebp
f0100b51:	89 e5                	mov    %esp,%ebp
f0100b53:	57                   	push   %edi
f0100b54:	56                   	push   %esi
f0100b55:	53                   	push   %ebx
f0100b56:	83 ec 5c             	sub    $0x5c,%esp
f0100b59:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100b62:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0100b69:	eb 11                	jmp    f0100b7c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100b6b:	85 c0                	test   %eax,%eax
f0100b6d:	0f 84 fd 03 00 00    	je     f0100f70 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
f0100b73:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b77:	89 04 24             	mov    %eax,(%esp)
f0100b7a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100b7c:	0f b6 03             	movzbl (%ebx),%eax
f0100b7f:	83 c3 01             	add    $0x1,%ebx
f0100b82:	83 f8 25             	cmp    $0x25,%eax
f0100b85:	75 e4                	jne    f0100b6b <vprintfmt+0x1b>
f0100b87:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100b8b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100b92:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100b99:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100ba0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ba5:	eb 06                	jmp    f0100bad <vprintfmt+0x5d>
f0100ba7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100bab:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100bad:	0f b6 13             	movzbl (%ebx),%edx
f0100bb0:	0f b6 c2             	movzbl %dl,%eax
f0100bb3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100bb6:	8d 43 01             	lea    0x1(%ebx),%eax
f0100bb9:	83 ea 23             	sub    $0x23,%edx
f0100bbc:	80 fa 55             	cmp    $0x55,%dl
f0100bbf:	0f 87 8e 03 00 00    	ja     f0100f53 <vprintfmt+0x403>
f0100bc5:	0f b6 d2             	movzbl %dl,%edx
f0100bc8:	ff 24 95 d4 1c 10 f0 	jmp    *-0xfefe32c(,%edx,4)
f0100bcf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100bd3:	eb d6                	jmp    f0100bab <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100bd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100bd8:	83 ea 30             	sub    $0x30,%edx
f0100bdb:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
f0100bde:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100be1:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100be4:	83 fb 09             	cmp    $0x9,%ebx
f0100be7:	77 55                	ja     f0100c3e <vprintfmt+0xee>
f0100be9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100bef:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0100bf2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100bf5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0100bf9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100bfc:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100bff:	83 fb 09             	cmp    $0x9,%ebx
f0100c02:	76 eb                	jbe    f0100bef <vprintfmt+0x9f>
f0100c04:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100c07:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100c0a:	eb 32                	jmp    f0100c3e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100c0c:	8b 55 14             	mov    0x14(%ebp),%edx
f0100c0f:	83 c2 04             	add    $0x4,%edx
f0100c12:	89 55 14             	mov    %edx,0x14(%ebp)
f0100c15:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100c18:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
f0100c1b:	eb 21                	jmp    f0100c3e <vprintfmt+0xee>

		case '.':
			if (width < 0)
f0100c1d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100c21:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c26:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
f0100c2a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c2d:	e9 79 ff ff ff       	jmp    f0100bab <vprintfmt+0x5b>
f0100c32:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0100c39:	e9 6d ff ff ff       	jmp    f0100bab <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0100c3e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100c42:	0f 89 63 ff ff ff    	jns    f0100bab <vprintfmt+0x5b>
f0100c48:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100c4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c4e:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0100c51:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c54:	e9 52 ff ff ff       	jmp    f0100bab <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100c59:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0100c5c:	e9 4a ff ff ff       	jmp    f0100bab <vprintfmt+0x5b>
f0100c61:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100c64:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c67:	83 c0 04             	add    $0x4,%eax
f0100c6a:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c6d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c71:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c74:	89 04 24             	mov    %eax,(%esp)
f0100c77:	ff d7                	call   *%edi
f0100c79:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100c7c:	e9 fb fe ff ff       	jmp    f0100b7c <vprintfmt+0x2c>
f0100c81:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100c84:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c87:	83 c0 04             	add    $0x4,%eax
f0100c8a:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c8d:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c90:	89 c2                	mov    %eax,%edx
f0100c92:	c1 fa 1f             	sar    $0x1f,%edx
f0100c95:	31 d0                	xor    %edx,%eax
f0100c97:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c99:	83 f8 06             	cmp    $0x6,%eax
f0100c9c:	7f 0b                	jg     f0100ca9 <vprintfmt+0x159>
f0100c9e:	8b 14 85 2c 1e 10 f0 	mov    -0xfefe1d4(,%eax,4),%edx
f0100ca5:	85 d2                	test   %edx,%edx
f0100ca7:	75 20                	jne    f0100cc9 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
f0100ca9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cad:	c7 44 24 08 55 1c 10 	movl   $0xf0101c55,0x8(%esp)
f0100cb4:	f0 
f0100cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cb9:	89 3c 24             	mov    %edi,(%esp)
f0100cbc:	e8 37 03 00 00       	call   f0100ff8 <printfmt>
f0100cc1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100cc4:	e9 b3 fe ff ff       	jmp    f0100b7c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0100cc9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ccd:	c7 44 24 08 5e 1c 10 	movl   $0xf0101c5e,0x8(%esp)
f0100cd4:	f0 
f0100cd5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cd9:	89 3c 24             	mov    %edi,(%esp)
f0100cdc:	e8 17 03 00 00       	call   f0100ff8 <printfmt>
f0100ce1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100ce4:	e9 93 fe ff ff       	jmp    f0100b7c <vprintfmt+0x2c>
f0100ce9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cec:	89 c3                	mov    %eax,%ebx
f0100cee:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100cf1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100cf4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100cf7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cfa:	83 c0 04             	add    $0x4,%eax
f0100cfd:	89 45 14             	mov    %eax,0x14(%ebp)
f0100d00:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100d03:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d06:	85 c0                	test   %eax,%eax
f0100d08:	b8 61 1c 10 f0       	mov    $0xf0101c61,%eax
f0100d0d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
f0100d11:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0100d14:	85 c9                	test   %ecx,%ecx
f0100d16:	7e 06                	jle    f0100d1e <vprintfmt+0x1ce>
f0100d18:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100d1c:	75 13                	jne    f0100d31 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d21:	0f be 02             	movsbl (%edx),%eax
f0100d24:	85 c0                	test   %eax,%eax
f0100d26:	0f 85 99 00 00 00    	jne    f0100dc5 <vprintfmt+0x275>
f0100d2c:	e9 86 00 00 00       	jmp    f0100db7 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100d31:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d35:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d38:	89 0c 24             	mov    %ecx,(%esp)
f0100d3b:	e8 cb 03 00 00       	call   f010110b <strnlen>
f0100d40:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100d43:	29 c2                	sub    %eax,%edx
f0100d45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100d48:	85 d2                	test   %edx,%edx
f0100d4a:	7e d2                	jle    f0100d1e <vprintfmt+0x1ce>
					putch(padc, putdat);
f0100d4c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0100d50:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100d53:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100d56:	89 d3                	mov    %edx,%ebx
f0100d58:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d5f:	89 04 24             	mov    %eax,(%esp)
f0100d62:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100d64:	83 eb 01             	sub    $0x1,%ebx
f0100d67:	85 db                	test   %ebx,%ebx
f0100d69:	7f ed                	jg     f0100d58 <vprintfmt+0x208>
f0100d6b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d6e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d75:	eb a7                	jmp    f0100d1e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d77:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100d7b:	74 18                	je     f0100d95 <vprintfmt+0x245>
f0100d7d:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d80:	83 fa 5e             	cmp    $0x5e,%edx
f0100d83:	76 10                	jbe    f0100d95 <vprintfmt+0x245>
					putch('?', putdat);
f0100d85:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d89:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100d90:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d93:	eb 0a                	jmp    f0100d9f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0100d95:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d99:	89 04 24             	mov    %eax,(%esp)
f0100d9c:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d9f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100da3:	0f be 03             	movsbl (%ebx),%eax
f0100da6:	85 c0                	test   %eax,%eax
f0100da8:	74 05                	je     f0100daf <vprintfmt+0x25f>
f0100daa:	83 c3 01             	add    $0x1,%ebx
f0100dad:	eb 29                	jmp    f0100dd8 <vprintfmt+0x288>
f0100daf:	89 fe                	mov    %edi,%esi
f0100db1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100db4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100db7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100dbb:	7f 2e                	jg     f0100deb <vprintfmt+0x29b>
f0100dbd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100dc0:	e9 b7 fd ff ff       	jmp    f0100b7c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100dc5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100dc8:	83 c2 01             	add    $0x1,%edx
f0100dcb:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100dce:	89 f7                	mov    %esi,%edi
f0100dd0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100dd3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100dd6:	89 d3                	mov    %edx,%ebx
f0100dd8:	85 f6                	test   %esi,%esi
f0100dda:	78 9b                	js     f0100d77 <vprintfmt+0x227>
f0100ddc:	83 ee 01             	sub    $0x1,%esi
f0100ddf:	79 96                	jns    f0100d77 <vprintfmt+0x227>
f0100de1:	89 fe                	mov    %edi,%esi
f0100de3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100de6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100de9:	eb cc                	jmp    f0100db7 <vprintfmt+0x267>
f0100deb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0100dee:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100df1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100df5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100dfc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100dfe:	83 eb 01             	sub    $0x1,%ebx
f0100e01:	85 db                	test   %ebx,%ebx
f0100e03:	7f ec                	jg     f0100df1 <vprintfmt+0x2a1>
f0100e05:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100e08:	e9 6f fd ff ff       	jmp    f0100b7c <vprintfmt+0x2c>
f0100e0d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100e10:	83 f9 01             	cmp    $0x1,%ecx
f0100e13:	7e 17                	jle    f0100e2c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
f0100e15:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e18:	83 c0 08             	add    $0x8,%eax
f0100e1b:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e1e:	8b 50 f8             	mov    -0x8(%eax),%edx
f0100e21:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100e24:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0100e27:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e2a:	eb 34                	jmp    f0100e60 <vprintfmt+0x310>
	else if (lflag)
f0100e2c:	85 c9                	test   %ecx,%ecx
f0100e2e:	74 19                	je     f0100e49 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
f0100e30:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e33:	83 c0 04             	add    $0x4,%eax
f0100e36:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e39:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e3c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e3f:	89 c1                	mov    %eax,%ecx
f0100e41:	c1 f9 1f             	sar    $0x1f,%ecx
f0100e44:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e47:	eb 17                	jmp    f0100e60 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
f0100e49:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e4c:	83 c0 04             	add    $0x4,%eax
f0100e4f:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e52:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e55:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e58:	89 c2                	mov    %eax,%edx
f0100e5a:	c1 fa 1f             	sar    $0x1f,%edx
f0100e5d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100e60:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e63:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e66:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100e6b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100e6f:	0f 89 9c 00 00 00    	jns    f0100f11 <vprintfmt+0x3c1>
				putch('-', putdat);
f0100e75:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e79:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100e80:	ff d7                	call   *%edi
				num = -(long long) num;
f0100e82:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e85:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e88:	f7 d9                	neg    %ecx
f0100e8a:	83 d3 00             	adc    $0x0,%ebx
f0100e8d:	f7 db                	neg    %ebx
f0100e8f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100e94:	eb 7b                	jmp    f0100f11 <vprintfmt+0x3c1>
f0100e96:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100e99:	89 ca                	mov    %ecx,%edx
f0100e9b:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e9e:	e8 53 fc ff ff       	call   f0100af6 <getuint>
f0100ea3:	89 c1                	mov    %eax,%ecx
f0100ea5:	89 d3                	mov    %edx,%ebx
f0100ea7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0100eac:	eb 63                	jmp    f0100f11 <vprintfmt+0x3c1>
f0100eae:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0100eb1:	89 ca                	mov    %ecx,%edx
f0100eb3:	8d 45 14             	lea    0x14(%ebp),%eax
f0100eb6:	e8 3b fc ff ff       	call   f0100af6 <getuint>
f0100ebb:	89 c1                	mov    %eax,%ecx
f0100ebd:	89 d3                	mov    %edx,%ebx
f0100ebf:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;//进制的标志位
			goto number;
f0100ec4:	eb 4b                	jmp    f0100f11 <vprintfmt+0x3c1>
f0100ec6:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0100ec9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ecd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100ed4:	ff d7                	call   *%edi
			putch('x', putdat);
f0100ed6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100eda:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100ee1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100ee3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ee6:	83 c0 04             	add    $0x4,%eax
f0100ee9:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100eec:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100eef:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ef4:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0100ef9:	eb 16                	jmp    f0100f11 <vprintfmt+0x3c1>
f0100efb:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100efe:	89 ca                	mov    %ecx,%edx
f0100f00:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f03:	e8 ee fb ff ff       	call   f0100af6 <getuint>
f0100f08:	89 c1                	mov    %eax,%ecx
f0100f0a:	89 d3                	mov    %edx,%ebx
f0100f0c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100f11:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0100f15:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100f19:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f20:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f24:	89 0c 24             	mov    %ecx,(%esp)
f0100f27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f2b:	89 f2                	mov    %esi,%edx
f0100f2d:	89 f8                	mov    %edi,%eax
f0100f2f:	e8 cc fa ff ff       	call   f0100a00 <printnum>
f0100f34:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100f37:	e9 40 fc ff ff       	jmp    f0100b7c <vprintfmt+0x2c>
f0100f3c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f3f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100f42:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f46:	89 14 24             	mov    %edx,(%esp)
f0100f49:	ff d7                	call   *%edi
f0100f4b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100f4e:	e9 29 fc ff ff       	jmp    f0100b7c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100f53:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f57:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100f5e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100f60:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100f63:	80 38 25             	cmpb   $0x25,(%eax)
f0100f66:	0f 84 10 fc ff ff    	je     f0100b7c <vprintfmt+0x2c>
f0100f6c:	89 c3                	mov    %eax,%ebx
f0100f6e:	eb f0                	jmp    f0100f60 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
f0100f70:	83 c4 5c             	add    $0x5c,%esp
f0100f73:	5b                   	pop    %ebx
f0100f74:	5e                   	pop    %esi
f0100f75:	5f                   	pop    %edi
f0100f76:	5d                   	pop    %ebp
f0100f77:	c3                   	ret    

f0100f78 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100f78:	55                   	push   %ebp
f0100f79:	89 e5                	mov    %esp,%ebp
f0100f7b:	83 ec 28             	sub    $0x28,%esp
f0100f7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f81:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0100f84:	85 c0                	test   %eax,%eax
f0100f86:	74 04                	je     f0100f8c <vsnprintf+0x14>
f0100f88:	85 d2                	test   %edx,%edx
f0100f8a:	7f 07                	jg     f0100f93 <vsnprintf+0x1b>
f0100f8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100f91:	eb 3b                	jmp    f0100fce <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100f93:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100f96:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0100f9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100fa4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fab:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fae:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fb2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100fb5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fb9:	c7 04 24 33 0b 10 f0 	movl   $0xf0100b33,(%esp)
f0100fc0:	e8 8b fb ff ff       	call   f0100b50 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100fc8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100fce:	c9                   	leave  
f0100fcf:	c3                   	ret    

f0100fd0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100fd0:	55                   	push   %ebp
f0100fd1:	89 e5                	mov    %esp,%ebp
f0100fd3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100fd6:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fdd:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fe0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100feb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fee:	89 04 24             	mov    %eax,(%esp)
f0100ff1:	e8 82 ff ff ff       	call   f0100f78 <vsnprintf>
	va_end(ap);

	return rc;
}
f0100ff6:	c9                   	leave  
f0100ff7:	c3                   	ret    

f0100ff8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100ff8:	55                   	push   %ebp
f0100ff9:	89 e5                	mov    %esp,%ebp
f0100ffb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100ffe:	8d 45 14             	lea    0x14(%ebp),%eax
f0101001:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101005:	8b 45 10             	mov    0x10(%ebp),%eax
f0101008:	89 44 24 08          	mov    %eax,0x8(%esp)
f010100c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101013:	8b 45 08             	mov    0x8(%ebp),%eax
f0101016:	89 04 24             	mov    %eax,(%esp)
f0101019:	e8 32 fb ff ff       	call   f0100b50 <vprintfmt>
	va_end(ap);
}
f010101e:	c9                   	leave  
f010101f:	c3                   	ret    

f0101020 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101020:	55                   	push   %ebp
f0101021:	89 e5                	mov    %esp,%ebp
f0101023:	57                   	push   %edi
f0101024:	56                   	push   %esi
f0101025:	53                   	push   %ebx
f0101026:	83 ec 1c             	sub    $0x1c,%esp
f0101029:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010102c:	85 c0                	test   %eax,%eax
f010102e:	74 10                	je     f0101040 <readline+0x20>
		cprintf("%s", prompt);
f0101030:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101034:	c7 04 24 5e 1c 10 f0 	movl   $0xf0101c5e,(%esp)
f010103b:	e8 8f f9 ff ff       	call   f01009cf <cprintf>

	i = 0;
	echoing = iscons(0);
f0101040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101047:	e8 35 f3 ff ff       	call   f0100381 <iscons>
f010104c:	89 c7                	mov    %eax,%edi
f010104e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101053:	e8 18 f3 ff ff       	call   f0100370 <getchar>
f0101058:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010105a:	85 c0                	test   %eax,%eax
f010105c:	79 17                	jns    f0101075 <readline+0x55>
			cprintf("read error: %e\n", c);
f010105e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101062:	c7 04 24 48 1e 10 f0 	movl   $0xf0101e48,(%esp)
f0101069:	e8 61 f9 ff ff       	call   f01009cf <cprintf>
f010106e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101073:	eb 65                	jmp    f01010da <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101075:	83 f8 1f             	cmp    $0x1f,%eax
f0101078:	7e 1f                	jle    f0101099 <readline+0x79>
f010107a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101080:	7f 17                	jg     f0101099 <readline+0x79>
			if (echoing)
f0101082:	85 ff                	test   %edi,%edi
f0101084:	74 08                	je     f010108e <readline+0x6e>
				cputchar(c);
f0101086:	89 04 24             	mov    %eax,(%esp)
f0101089:	e8 12 f6 ff ff       	call   f01006a0 <cputchar>
			buf[i++] = c;
f010108e:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0101094:	83 c6 01             	add    $0x1,%esi
f0101097:	eb ba                	jmp    f0101053 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101099:	83 fb 08             	cmp    $0x8,%ebx
f010109c:	75 15                	jne    f01010b3 <readline+0x93>
f010109e:	85 f6                	test   %esi,%esi
f01010a0:	7e 11                	jle    f01010b3 <readline+0x93>
			if (echoing)
f01010a2:	85 ff                	test   %edi,%edi
f01010a4:	74 08                	je     f01010ae <readline+0x8e>
				cputchar(c);
f01010a6:	89 1c 24             	mov    %ebx,(%esp)
f01010a9:	e8 f2 f5 ff ff       	call   f01006a0 <cputchar>
			i--;
f01010ae:	83 ee 01             	sub    $0x1,%esi
f01010b1:	eb a0                	jmp    f0101053 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01010b3:	83 fb 0a             	cmp    $0xa,%ebx
f01010b6:	74 0a                	je     f01010c2 <readline+0xa2>
f01010b8:	83 fb 0d             	cmp    $0xd,%ebx
f01010bb:	90                   	nop
f01010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01010c0:	75 91                	jne    f0101053 <readline+0x33>
			if (echoing)
f01010c2:	85 ff                	test   %edi,%edi
f01010c4:	74 08                	je     f01010ce <readline+0xae>
				cputchar(c);
f01010c6:	89 1c 24             	mov    %ebx,(%esp)
f01010c9:	e8 d2 f5 ff ff       	call   f01006a0 <cputchar>
			buf[i] = 0;
f01010ce:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
f01010d5:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
			return buf;
		}
	}
}
f01010da:	83 c4 1c             	add    $0x1c,%esp
f01010dd:	5b                   	pop    %ebx
f01010de:	5e                   	pop    %esi
f01010df:	5f                   	pop    %edi
f01010e0:	5d                   	pop    %ebp
f01010e1:	c3                   	ret    
	...

f01010f0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01010f0:	55                   	push   %ebp
f01010f1:	89 e5                	mov    %esp,%ebp
f01010f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01010f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010fb:	80 3a 00             	cmpb   $0x0,(%edx)
f01010fe:	74 09                	je     f0101109 <strlen+0x19>
		n++;
f0101100:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101103:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101107:	75 f7                	jne    f0101100 <strlen+0x10>
		n++;
	return n;
}
f0101109:	5d                   	pop    %ebp
f010110a:	c3                   	ret    

f010110b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010110b:	55                   	push   %ebp
f010110c:	89 e5                	mov    %esp,%ebp
f010110e:	53                   	push   %ebx
f010110f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101115:	85 c9                	test   %ecx,%ecx
f0101117:	74 19                	je     f0101132 <strnlen+0x27>
f0101119:	80 3b 00             	cmpb   $0x0,(%ebx)
f010111c:	74 14                	je     f0101132 <strnlen+0x27>
f010111e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101123:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101126:	39 c8                	cmp    %ecx,%eax
f0101128:	74 0d                	je     f0101137 <strnlen+0x2c>
f010112a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010112e:	75 f3                	jne    f0101123 <strnlen+0x18>
f0101130:	eb 05                	jmp    f0101137 <strnlen+0x2c>
f0101132:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101137:	5b                   	pop    %ebx
f0101138:	5d                   	pop    %ebp
f0101139:	c3                   	ret    

f010113a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010113a:	55                   	push   %ebp
f010113b:	89 e5                	mov    %esp,%ebp
f010113d:	53                   	push   %ebx
f010113e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101141:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101144:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101149:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010114d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101150:	83 c2 01             	add    $0x1,%edx
f0101153:	84 c9                	test   %cl,%cl
f0101155:	75 f2                	jne    f0101149 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101157:	5b                   	pop    %ebx
f0101158:	5d                   	pop    %ebp
f0101159:	c3                   	ret    

f010115a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010115a:	55                   	push   %ebp
f010115b:	89 e5                	mov    %esp,%ebp
f010115d:	56                   	push   %esi
f010115e:	53                   	push   %ebx
f010115f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101162:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101165:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101168:	85 f6                	test   %esi,%esi
f010116a:	74 18                	je     f0101184 <strncpy+0x2a>
f010116c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101171:	0f b6 1a             	movzbl (%edx),%ebx
f0101174:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101177:	80 3a 01             	cmpb   $0x1,(%edx)
f010117a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010117d:	83 c1 01             	add    $0x1,%ecx
f0101180:	39 ce                	cmp    %ecx,%esi
f0101182:	77 ed                	ja     f0101171 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101184:	5b                   	pop    %ebx
f0101185:	5e                   	pop    %esi
f0101186:	5d                   	pop    %ebp
f0101187:	c3                   	ret    

f0101188 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101188:	55                   	push   %ebp
f0101189:	89 e5                	mov    %esp,%ebp
f010118b:	56                   	push   %esi
f010118c:	53                   	push   %ebx
f010118d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101190:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101193:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101196:	89 f0                	mov    %esi,%eax
f0101198:	85 c9                	test   %ecx,%ecx
f010119a:	74 27                	je     f01011c3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f010119c:	83 e9 01             	sub    $0x1,%ecx
f010119f:	74 1d                	je     f01011be <strlcpy+0x36>
f01011a1:	0f b6 1a             	movzbl (%edx),%ebx
f01011a4:	84 db                	test   %bl,%bl
f01011a6:	74 16                	je     f01011be <strlcpy+0x36>
			*dst++ = *src++;
f01011a8:	88 18                	mov    %bl,(%eax)
f01011aa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01011ad:	83 e9 01             	sub    $0x1,%ecx
f01011b0:	74 0e                	je     f01011c0 <strlcpy+0x38>
			*dst++ = *src++;
f01011b2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01011b5:	0f b6 1a             	movzbl (%edx),%ebx
f01011b8:	84 db                	test   %bl,%bl
f01011ba:	75 ec                	jne    f01011a8 <strlcpy+0x20>
f01011bc:	eb 02                	jmp    f01011c0 <strlcpy+0x38>
f01011be:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01011c0:	c6 00 00             	movb   $0x0,(%eax)
f01011c3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01011c5:	5b                   	pop    %ebx
f01011c6:	5e                   	pop    %esi
f01011c7:	5d                   	pop    %ebp
f01011c8:	c3                   	ret    

f01011c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01011c9:	55                   	push   %ebp
f01011ca:	89 e5                	mov    %esp,%ebp
f01011cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01011d2:	0f b6 01             	movzbl (%ecx),%eax
f01011d5:	84 c0                	test   %al,%al
f01011d7:	74 15                	je     f01011ee <strcmp+0x25>
f01011d9:	3a 02                	cmp    (%edx),%al
f01011db:	75 11                	jne    f01011ee <strcmp+0x25>
		p++, q++;
f01011dd:	83 c1 01             	add    $0x1,%ecx
f01011e0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01011e3:	0f b6 01             	movzbl (%ecx),%eax
f01011e6:	84 c0                	test   %al,%al
f01011e8:	74 04                	je     f01011ee <strcmp+0x25>
f01011ea:	3a 02                	cmp    (%edx),%al
f01011ec:	74 ef                	je     f01011dd <strcmp+0x14>
f01011ee:	0f b6 c0             	movzbl %al,%eax
f01011f1:	0f b6 12             	movzbl (%edx),%edx
f01011f4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01011f6:	5d                   	pop    %ebp
f01011f7:	c3                   	ret    

f01011f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01011f8:	55                   	push   %ebp
f01011f9:	89 e5                	mov    %esp,%ebp
f01011fb:	53                   	push   %ebx
f01011fc:	8b 55 08             	mov    0x8(%ebp),%edx
f01011ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101202:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0101205:	85 c0                	test   %eax,%eax
f0101207:	74 23                	je     f010122c <strncmp+0x34>
f0101209:	0f b6 1a             	movzbl (%edx),%ebx
f010120c:	84 db                	test   %bl,%bl
f010120e:	74 24                	je     f0101234 <strncmp+0x3c>
f0101210:	3a 19                	cmp    (%ecx),%bl
f0101212:	75 20                	jne    f0101234 <strncmp+0x3c>
f0101214:	83 e8 01             	sub    $0x1,%eax
f0101217:	74 13                	je     f010122c <strncmp+0x34>
		n--, p++, q++;
f0101219:	83 c2 01             	add    $0x1,%edx
f010121c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010121f:	0f b6 1a             	movzbl (%edx),%ebx
f0101222:	84 db                	test   %bl,%bl
f0101224:	74 0e                	je     f0101234 <strncmp+0x3c>
f0101226:	3a 19                	cmp    (%ecx),%bl
f0101228:	74 ea                	je     f0101214 <strncmp+0x1c>
f010122a:	eb 08                	jmp    f0101234 <strncmp+0x3c>
f010122c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101231:	5b                   	pop    %ebx
f0101232:	5d                   	pop    %ebp
f0101233:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101234:	0f b6 02             	movzbl (%edx),%eax
f0101237:	0f b6 11             	movzbl (%ecx),%edx
f010123a:	29 d0                	sub    %edx,%eax
f010123c:	eb f3                	jmp    f0101231 <strncmp+0x39>

f010123e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010123e:	55                   	push   %ebp
f010123f:	89 e5                	mov    %esp,%ebp
f0101241:	8b 45 08             	mov    0x8(%ebp),%eax
f0101244:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101248:	0f b6 10             	movzbl (%eax),%edx
f010124b:	84 d2                	test   %dl,%dl
f010124d:	74 15                	je     f0101264 <strchr+0x26>
		if (*s == c)
f010124f:	38 ca                	cmp    %cl,%dl
f0101251:	75 07                	jne    f010125a <strchr+0x1c>
f0101253:	eb 14                	jmp    f0101269 <strchr+0x2b>
f0101255:	38 ca                	cmp    %cl,%dl
f0101257:	90                   	nop
f0101258:	74 0f                	je     f0101269 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010125a:	83 c0 01             	add    $0x1,%eax
f010125d:	0f b6 10             	movzbl (%eax),%edx
f0101260:	84 d2                	test   %dl,%dl
f0101262:	75 f1                	jne    f0101255 <strchr+0x17>
f0101264:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101269:	5d                   	pop    %ebp
f010126a:	c3                   	ret    

f010126b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010126b:	55                   	push   %ebp
f010126c:	89 e5                	mov    %esp,%ebp
f010126e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101271:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101275:	0f b6 10             	movzbl (%eax),%edx
f0101278:	84 d2                	test   %dl,%dl
f010127a:	74 18                	je     f0101294 <strfind+0x29>
		if (*s == c)
f010127c:	38 ca                	cmp    %cl,%dl
f010127e:	75 0a                	jne    f010128a <strfind+0x1f>
f0101280:	eb 12                	jmp    f0101294 <strfind+0x29>
f0101282:	38 ca                	cmp    %cl,%dl
f0101284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101288:	74 0a                	je     f0101294 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010128a:	83 c0 01             	add    $0x1,%eax
f010128d:	0f b6 10             	movzbl (%eax),%edx
f0101290:	84 d2                	test   %dl,%dl
f0101292:	75 ee                	jne    f0101282 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101294:	5d                   	pop    %ebp
f0101295:	c3                   	ret    

f0101296 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101296:	55                   	push   %ebp
f0101297:	89 e5                	mov    %esp,%ebp
f0101299:	53                   	push   %ebx
f010129a:	8b 45 08             	mov    0x8(%ebp),%eax
f010129d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01012a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01012a3:	89 da                	mov    %ebx,%edx
f01012a5:	83 ea 01             	sub    $0x1,%edx
f01012a8:	78 0d                	js     f01012b7 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f01012aa:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f01012ac:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f01012ae:	88 0a                	mov    %cl,(%edx)
f01012b0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01012b3:	39 da                	cmp    %ebx,%edx
f01012b5:	75 f7                	jne    f01012ae <memset+0x18>
		*p++ = c;

	return v;
}
f01012b7:	5b                   	pop    %ebx
f01012b8:	5d                   	pop    %ebp
f01012b9:	c3                   	ret    

f01012ba <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f01012ba:	55                   	push   %ebp
f01012bb:	89 e5                	mov    %esp,%ebp
f01012bd:	56                   	push   %esi
f01012be:	53                   	push   %ebx
f01012bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01012c2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f01012c8:	85 db                	test   %ebx,%ebx
f01012ca:	74 13                	je     f01012df <memcpy+0x25>
f01012cc:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f01012d1:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01012d5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012d8:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f01012db:	39 da                	cmp    %ebx,%edx
f01012dd:	75 f2                	jne    f01012d1 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f01012df:	5b                   	pop    %ebx
f01012e0:	5e                   	pop    %esi
f01012e1:	5d                   	pop    %ebp
f01012e2:	c3                   	ret    

f01012e3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01012e3:	55                   	push   %ebp
f01012e4:	89 e5                	mov    %esp,%ebp
f01012e6:	57                   	push   %edi
f01012e7:	56                   	push   %esi
f01012e8:	53                   	push   %ebx
f01012e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ec:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f01012f2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f01012f4:	39 c6                	cmp    %eax,%esi
f01012f6:	72 0b                	jb     f0101303 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f01012f8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f01012fd:	85 db                	test   %ebx,%ebx
f01012ff:	75 2e                	jne    f010132f <memmove+0x4c>
f0101301:	eb 3a                	jmp    f010133d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101303:	01 df                	add    %ebx,%edi
f0101305:	39 f8                	cmp    %edi,%eax
f0101307:	73 ef                	jae    f01012f8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f0101309:	85 db                	test   %ebx,%ebx
f010130b:	90                   	nop
f010130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101310:	74 2b                	je     f010133d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0101312:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f0101315:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f010131a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f010131f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f0101323:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0101326:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0101329:	85 c9                	test   %ecx,%ecx
f010132b:	75 ed                	jne    f010131a <memmove+0x37>
f010132d:	eb 0e                	jmp    f010133d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f010132f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101333:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101336:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101339:	39 d3                	cmp    %edx,%ebx
f010133b:	75 f2                	jne    f010132f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
f010133d:	5b                   	pop    %ebx
f010133e:	5e                   	pop    %esi
f010133f:	5f                   	pop    %edi
f0101340:	5d                   	pop    %ebp
f0101341:	c3                   	ret    

f0101342 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101342:	55                   	push   %ebp
f0101343:	89 e5                	mov    %esp,%ebp
f0101345:	57                   	push   %edi
f0101346:	56                   	push   %esi
f0101347:	53                   	push   %ebx
f0101348:	8b 75 08             	mov    0x8(%ebp),%esi
f010134b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010134e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101351:	85 c9                	test   %ecx,%ecx
f0101353:	74 36                	je     f010138b <memcmp+0x49>
		if (*s1 != *s2)
f0101355:	0f b6 06             	movzbl (%esi),%eax
f0101358:	0f b6 1f             	movzbl (%edi),%ebx
f010135b:	38 d8                	cmp    %bl,%al
f010135d:	74 20                	je     f010137f <memcmp+0x3d>
f010135f:	eb 14                	jmp    f0101375 <memcmp+0x33>
f0101361:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101366:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010136b:	83 c2 01             	add    $0x1,%edx
f010136e:	83 e9 01             	sub    $0x1,%ecx
f0101371:	38 d8                	cmp    %bl,%al
f0101373:	74 12                	je     f0101387 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101375:	0f b6 c0             	movzbl %al,%eax
f0101378:	0f b6 db             	movzbl %bl,%ebx
f010137b:	29 d8                	sub    %ebx,%eax
f010137d:	eb 11                	jmp    f0101390 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010137f:	83 e9 01             	sub    $0x1,%ecx
f0101382:	ba 00 00 00 00       	mov    $0x0,%edx
f0101387:	85 c9                	test   %ecx,%ecx
f0101389:	75 d6                	jne    f0101361 <memcmp+0x1f>
f010138b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101390:	5b                   	pop    %ebx
f0101391:	5e                   	pop    %esi
f0101392:	5f                   	pop    %edi
f0101393:	5d                   	pop    %ebp
f0101394:	c3                   	ret    

f0101395 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101395:	55                   	push   %ebp
f0101396:	89 e5                	mov    %esp,%ebp
f0101398:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010139b:	89 c2                	mov    %eax,%edx
f010139d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01013a0:	39 d0                	cmp    %edx,%eax
f01013a2:	73 15                	jae    f01013b9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01013a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01013a8:	38 08                	cmp    %cl,(%eax)
f01013aa:	75 06                	jne    f01013b2 <memfind+0x1d>
f01013ac:	eb 0b                	jmp    f01013b9 <memfind+0x24>
f01013ae:	38 08                	cmp    %cl,(%eax)
f01013b0:	74 07                	je     f01013b9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01013b2:	83 c0 01             	add    $0x1,%eax
f01013b5:	39 c2                	cmp    %eax,%edx
f01013b7:	77 f5                	ja     f01013ae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01013b9:	5d                   	pop    %ebp
f01013ba:	c3                   	ret    

f01013bb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01013bb:	55                   	push   %ebp
f01013bc:	89 e5                	mov    %esp,%ebp
f01013be:	57                   	push   %edi
f01013bf:	56                   	push   %esi
f01013c0:	53                   	push   %ebx
f01013c1:	83 ec 04             	sub    $0x4,%esp
f01013c4:	8b 55 08             	mov    0x8(%ebp),%edx
f01013c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01013ca:	0f b6 02             	movzbl (%edx),%eax
f01013cd:	3c 20                	cmp    $0x20,%al
f01013cf:	74 04                	je     f01013d5 <strtol+0x1a>
f01013d1:	3c 09                	cmp    $0x9,%al
f01013d3:	75 0e                	jne    f01013e3 <strtol+0x28>
		s++;
f01013d5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01013d8:	0f b6 02             	movzbl (%edx),%eax
f01013db:	3c 20                	cmp    $0x20,%al
f01013dd:	74 f6                	je     f01013d5 <strtol+0x1a>
f01013df:	3c 09                	cmp    $0x9,%al
f01013e1:	74 f2                	je     f01013d5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01013e3:	3c 2b                	cmp    $0x2b,%al
f01013e5:	75 0c                	jne    f01013f3 <strtol+0x38>
		s++;
f01013e7:	83 c2 01             	add    $0x1,%edx
f01013ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01013f1:	eb 15                	jmp    f0101408 <strtol+0x4d>
	else if (*s == '-')
f01013f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01013fa:	3c 2d                	cmp    $0x2d,%al
f01013fc:	75 0a                	jne    f0101408 <strtol+0x4d>
		s++, neg = 1;
f01013fe:	83 c2 01             	add    $0x1,%edx
f0101401:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101408:	85 db                	test   %ebx,%ebx
f010140a:	0f 94 c0             	sete   %al
f010140d:	74 05                	je     f0101414 <strtol+0x59>
f010140f:	83 fb 10             	cmp    $0x10,%ebx
f0101412:	75 18                	jne    f010142c <strtol+0x71>
f0101414:	80 3a 30             	cmpb   $0x30,(%edx)
f0101417:	75 13                	jne    f010142c <strtol+0x71>
f0101419:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010141d:	8d 76 00             	lea    0x0(%esi),%esi
f0101420:	75 0a                	jne    f010142c <strtol+0x71>
		s += 2, base = 16;
f0101422:	83 c2 02             	add    $0x2,%edx
f0101425:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010142a:	eb 15                	jmp    f0101441 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010142c:	84 c0                	test   %al,%al
f010142e:	66 90                	xchg   %ax,%ax
f0101430:	74 0f                	je     f0101441 <strtol+0x86>
f0101432:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101437:	80 3a 30             	cmpb   $0x30,(%edx)
f010143a:	75 05                	jne    f0101441 <strtol+0x86>
		s++, base = 8;
f010143c:	83 c2 01             	add    $0x1,%edx
f010143f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101441:	b8 00 00 00 00       	mov    $0x0,%eax
f0101446:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101448:	0f b6 0a             	movzbl (%edx),%ecx
f010144b:	89 cf                	mov    %ecx,%edi
f010144d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101450:	80 fb 09             	cmp    $0x9,%bl
f0101453:	77 08                	ja     f010145d <strtol+0xa2>
			dig = *s - '0';
f0101455:	0f be c9             	movsbl %cl,%ecx
f0101458:	83 e9 30             	sub    $0x30,%ecx
f010145b:	eb 1e                	jmp    f010147b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010145d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101460:	80 fb 19             	cmp    $0x19,%bl
f0101463:	77 08                	ja     f010146d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101465:	0f be c9             	movsbl %cl,%ecx
f0101468:	83 e9 57             	sub    $0x57,%ecx
f010146b:	eb 0e                	jmp    f010147b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010146d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101470:	80 fb 19             	cmp    $0x19,%bl
f0101473:	77 15                	ja     f010148a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101475:	0f be c9             	movsbl %cl,%ecx
f0101478:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010147b:	39 f1                	cmp    %esi,%ecx
f010147d:	7d 0b                	jge    f010148a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010147f:	83 c2 01             	add    $0x1,%edx
f0101482:	0f af c6             	imul   %esi,%eax
f0101485:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101488:	eb be                	jmp    f0101448 <strtol+0x8d>
f010148a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010148c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101490:	74 05                	je     f0101497 <strtol+0xdc>
		*endptr = (char *) s;
f0101492:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101495:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101497:	89 ca                	mov    %ecx,%edx
f0101499:	f7 da                	neg    %edx
f010149b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010149f:	0f 45 c2             	cmovne %edx,%eax
}
f01014a2:	83 c4 04             	add    $0x4,%esp
f01014a5:	5b                   	pop    %ebx
f01014a6:	5e                   	pop    %esi
f01014a7:	5f                   	pop    %edi
f01014a8:	5d                   	pop    %ebp
f01014a9:	c3                   	ret    
f01014aa:	00 00                	add    %al,(%eax)
f01014ac:	00 00                	add    %al,(%eax)
	...

f01014b0 <__udivdi3>:
f01014b0:	55                   	push   %ebp
f01014b1:	89 e5                	mov    %esp,%ebp
f01014b3:	57                   	push   %edi
f01014b4:	56                   	push   %esi
f01014b5:	83 ec 10             	sub    $0x10,%esp
f01014b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01014bb:	8b 55 08             	mov    0x8(%ebp),%edx
f01014be:	8b 75 10             	mov    0x10(%ebp),%esi
f01014c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01014c4:	85 c0                	test   %eax,%eax
f01014c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01014c9:	75 35                	jne    f0101500 <__udivdi3+0x50>
f01014cb:	39 fe                	cmp    %edi,%esi
f01014cd:	77 61                	ja     f0101530 <__udivdi3+0x80>
f01014cf:	85 f6                	test   %esi,%esi
f01014d1:	75 0b                	jne    f01014de <__udivdi3+0x2e>
f01014d3:	b8 01 00 00 00       	mov    $0x1,%eax
f01014d8:	31 d2                	xor    %edx,%edx
f01014da:	f7 f6                	div    %esi
f01014dc:	89 c6                	mov    %eax,%esi
f01014de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01014e1:	31 d2                	xor    %edx,%edx
f01014e3:	89 f8                	mov    %edi,%eax
f01014e5:	f7 f6                	div    %esi
f01014e7:	89 c7                	mov    %eax,%edi
f01014e9:	89 c8                	mov    %ecx,%eax
f01014eb:	f7 f6                	div    %esi
f01014ed:	89 c1                	mov    %eax,%ecx
f01014ef:	89 fa                	mov    %edi,%edx
f01014f1:	89 c8                	mov    %ecx,%eax
f01014f3:	83 c4 10             	add    $0x10,%esp
f01014f6:	5e                   	pop    %esi
f01014f7:	5f                   	pop    %edi
f01014f8:	5d                   	pop    %ebp
f01014f9:	c3                   	ret    
f01014fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101500:	39 f8                	cmp    %edi,%eax
f0101502:	77 1c                	ja     f0101520 <__udivdi3+0x70>
f0101504:	0f bd d0             	bsr    %eax,%edx
f0101507:	83 f2 1f             	xor    $0x1f,%edx
f010150a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010150d:	75 39                	jne    f0101548 <__udivdi3+0x98>
f010150f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0101512:	0f 86 a0 00 00 00    	jbe    f01015b8 <__udivdi3+0x108>
f0101518:	39 f8                	cmp    %edi,%eax
f010151a:	0f 82 98 00 00 00    	jb     f01015b8 <__udivdi3+0x108>
f0101520:	31 ff                	xor    %edi,%edi
f0101522:	31 c9                	xor    %ecx,%ecx
f0101524:	89 c8                	mov    %ecx,%eax
f0101526:	89 fa                	mov    %edi,%edx
f0101528:	83 c4 10             	add    $0x10,%esp
f010152b:	5e                   	pop    %esi
f010152c:	5f                   	pop    %edi
f010152d:	5d                   	pop    %ebp
f010152e:	c3                   	ret    
f010152f:	90                   	nop
f0101530:	89 d1                	mov    %edx,%ecx
f0101532:	89 fa                	mov    %edi,%edx
f0101534:	89 c8                	mov    %ecx,%eax
f0101536:	31 ff                	xor    %edi,%edi
f0101538:	f7 f6                	div    %esi
f010153a:	89 c1                	mov    %eax,%ecx
f010153c:	89 fa                	mov    %edi,%edx
f010153e:	89 c8                	mov    %ecx,%eax
f0101540:	83 c4 10             	add    $0x10,%esp
f0101543:	5e                   	pop    %esi
f0101544:	5f                   	pop    %edi
f0101545:	5d                   	pop    %ebp
f0101546:	c3                   	ret    
f0101547:	90                   	nop
f0101548:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010154c:	89 f2                	mov    %esi,%edx
f010154e:	d3 e0                	shl    %cl,%eax
f0101550:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101553:	b8 20 00 00 00       	mov    $0x20,%eax
f0101558:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010155b:	89 c1                	mov    %eax,%ecx
f010155d:	d3 ea                	shr    %cl,%edx
f010155f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101563:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101566:	d3 e6                	shl    %cl,%esi
f0101568:	89 c1                	mov    %eax,%ecx
f010156a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010156d:	89 fe                	mov    %edi,%esi
f010156f:	d3 ee                	shr    %cl,%esi
f0101571:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101575:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101578:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010157b:	d3 e7                	shl    %cl,%edi
f010157d:	89 c1                	mov    %eax,%ecx
f010157f:	d3 ea                	shr    %cl,%edx
f0101581:	09 d7                	or     %edx,%edi
f0101583:	89 f2                	mov    %esi,%edx
f0101585:	89 f8                	mov    %edi,%eax
f0101587:	f7 75 ec             	divl   -0x14(%ebp)
f010158a:	89 d6                	mov    %edx,%esi
f010158c:	89 c7                	mov    %eax,%edi
f010158e:	f7 65 e8             	mull   -0x18(%ebp)
f0101591:	39 d6                	cmp    %edx,%esi
f0101593:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101596:	72 30                	jb     f01015c8 <__udivdi3+0x118>
f0101598:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010159b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010159f:	d3 e2                	shl    %cl,%edx
f01015a1:	39 c2                	cmp    %eax,%edx
f01015a3:	73 05                	jae    f01015aa <__udivdi3+0xfa>
f01015a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f01015a8:	74 1e                	je     f01015c8 <__udivdi3+0x118>
f01015aa:	89 f9                	mov    %edi,%ecx
f01015ac:	31 ff                	xor    %edi,%edi
f01015ae:	e9 71 ff ff ff       	jmp    f0101524 <__udivdi3+0x74>
f01015b3:	90                   	nop
f01015b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01015b8:	31 ff                	xor    %edi,%edi
f01015ba:	b9 01 00 00 00       	mov    $0x1,%ecx
f01015bf:	e9 60 ff ff ff       	jmp    f0101524 <__udivdi3+0x74>
f01015c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01015c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f01015cb:	31 ff                	xor    %edi,%edi
f01015cd:	89 c8                	mov    %ecx,%eax
f01015cf:	89 fa                	mov    %edi,%edx
f01015d1:	83 c4 10             	add    $0x10,%esp
f01015d4:	5e                   	pop    %esi
f01015d5:	5f                   	pop    %edi
f01015d6:	5d                   	pop    %ebp
f01015d7:	c3                   	ret    
	...

f01015e0 <__umoddi3>:
f01015e0:	55                   	push   %ebp
f01015e1:	89 e5                	mov    %esp,%ebp
f01015e3:	57                   	push   %edi
f01015e4:	56                   	push   %esi
f01015e5:	83 ec 20             	sub    $0x20,%esp
f01015e8:	8b 55 14             	mov    0x14(%ebp),%edx
f01015eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015ee:	8b 7d 10             	mov    0x10(%ebp),%edi
f01015f1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015f4:	85 d2                	test   %edx,%edx
f01015f6:	89 c8                	mov    %ecx,%eax
f01015f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01015fb:	75 13                	jne    f0101610 <__umoddi3+0x30>
f01015fd:	39 f7                	cmp    %esi,%edi
f01015ff:	76 3f                	jbe    f0101640 <__umoddi3+0x60>
f0101601:	89 f2                	mov    %esi,%edx
f0101603:	f7 f7                	div    %edi
f0101605:	89 d0                	mov    %edx,%eax
f0101607:	31 d2                	xor    %edx,%edx
f0101609:	83 c4 20             	add    $0x20,%esp
f010160c:	5e                   	pop    %esi
f010160d:	5f                   	pop    %edi
f010160e:	5d                   	pop    %ebp
f010160f:	c3                   	ret    
f0101610:	39 f2                	cmp    %esi,%edx
f0101612:	77 4c                	ja     f0101660 <__umoddi3+0x80>
f0101614:	0f bd ca             	bsr    %edx,%ecx
f0101617:	83 f1 1f             	xor    $0x1f,%ecx
f010161a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010161d:	75 51                	jne    f0101670 <__umoddi3+0x90>
f010161f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101622:	0f 87 e0 00 00 00    	ja     f0101708 <__umoddi3+0x128>
f0101628:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010162b:	29 f8                	sub    %edi,%eax
f010162d:	19 d6                	sbb    %edx,%esi
f010162f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101632:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101635:	89 f2                	mov    %esi,%edx
f0101637:	83 c4 20             	add    $0x20,%esp
f010163a:	5e                   	pop    %esi
f010163b:	5f                   	pop    %edi
f010163c:	5d                   	pop    %ebp
f010163d:	c3                   	ret    
f010163e:	66 90                	xchg   %ax,%ax
f0101640:	85 ff                	test   %edi,%edi
f0101642:	75 0b                	jne    f010164f <__umoddi3+0x6f>
f0101644:	b8 01 00 00 00       	mov    $0x1,%eax
f0101649:	31 d2                	xor    %edx,%edx
f010164b:	f7 f7                	div    %edi
f010164d:	89 c7                	mov    %eax,%edi
f010164f:	89 f0                	mov    %esi,%eax
f0101651:	31 d2                	xor    %edx,%edx
f0101653:	f7 f7                	div    %edi
f0101655:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101658:	f7 f7                	div    %edi
f010165a:	eb a9                	jmp    f0101605 <__umoddi3+0x25>
f010165c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101660:	89 c8                	mov    %ecx,%eax
f0101662:	89 f2                	mov    %esi,%edx
f0101664:	83 c4 20             	add    $0x20,%esp
f0101667:	5e                   	pop    %esi
f0101668:	5f                   	pop    %edi
f0101669:	5d                   	pop    %ebp
f010166a:	c3                   	ret    
f010166b:	90                   	nop
f010166c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101670:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101674:	d3 e2                	shl    %cl,%edx
f0101676:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101679:	ba 20 00 00 00       	mov    $0x20,%edx
f010167e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101681:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101684:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101688:	89 fa                	mov    %edi,%edx
f010168a:	d3 ea                	shr    %cl,%edx
f010168c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101690:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101693:	d3 e7                	shl    %cl,%edi
f0101695:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101699:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010169c:	89 f2                	mov    %esi,%edx
f010169e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f01016a1:	89 c7                	mov    %eax,%edi
f01016a3:	d3 ea                	shr    %cl,%edx
f01016a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01016a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01016ac:	89 c2                	mov    %eax,%edx
f01016ae:	d3 e6                	shl    %cl,%esi
f01016b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01016b4:	d3 ea                	shr    %cl,%edx
f01016b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01016ba:	09 d6                	or     %edx,%esi
f01016bc:	89 f0                	mov    %esi,%eax
f01016be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01016c1:	d3 e7                	shl    %cl,%edi
f01016c3:	89 f2                	mov    %esi,%edx
f01016c5:	f7 75 f4             	divl   -0xc(%ebp)
f01016c8:	89 d6                	mov    %edx,%esi
f01016ca:	f7 65 e8             	mull   -0x18(%ebp)
f01016cd:	39 d6                	cmp    %edx,%esi
f01016cf:	72 2b                	jb     f01016fc <__umoddi3+0x11c>
f01016d1:	39 c7                	cmp    %eax,%edi
f01016d3:	72 23                	jb     f01016f8 <__umoddi3+0x118>
f01016d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01016d9:	29 c7                	sub    %eax,%edi
f01016db:	19 d6                	sbb    %edx,%esi
f01016dd:	89 f0                	mov    %esi,%eax
f01016df:	89 f2                	mov    %esi,%edx
f01016e1:	d3 ef                	shr    %cl,%edi
f01016e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01016e7:	d3 e0                	shl    %cl,%eax
f01016e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01016ed:	09 f8                	or     %edi,%eax
f01016ef:	d3 ea                	shr    %cl,%edx
f01016f1:	83 c4 20             	add    $0x20,%esp
f01016f4:	5e                   	pop    %esi
f01016f5:	5f                   	pop    %edi
f01016f6:	5d                   	pop    %ebp
f01016f7:	c3                   	ret    
f01016f8:	39 d6                	cmp    %edx,%esi
f01016fa:	75 d9                	jne    f01016d5 <__umoddi3+0xf5>
f01016fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01016ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0101702:	eb d1                	jmp    f01016d5 <__umoddi3+0xf5>
f0101704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101708:	39 f2                	cmp    %esi,%edx
f010170a:	0f 82 18 ff ff ff    	jb     f0101628 <__umoddi3+0x48>
f0101710:	e9 1d ff ff ff       	jmp    f0101632 <__umoddi3+0x52>
