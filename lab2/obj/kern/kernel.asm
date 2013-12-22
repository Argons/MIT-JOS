
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
f0100015:	0f 01 15 18 40 11 00 	lgdtl  0x114018

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
f0100033:	bc 00 40 11 f0       	mov    $0xf0114000,%esp

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
f0100054:	c7 04 24 e0 32 10 f0 	movl   $0xf01032e0,(%esp)
f010005b:	e8 9b 21 00 00       	call   f01021fb <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 56 21 00 00       	call   f01021c8 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 7a 3c 10 f0 	movl   $0xf0103c7a,(%esp)
f0100079:	e8 7d 21 00 00       	call   f01021fb <cprintf>
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
f0100086:	83 3d 60 43 11 f0 00 	cmpl   $0x0,0xf0114360
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 60 43 11 f0       	mov    %eax,0xf0114360

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 fa 32 10 f0 	movl   $0xf01032fa,(%esp)
f01000ac:	e8 4a 21 00 00       	call   f01021fb <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 05 21 00 00       	call   f01021c8 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 7a 3c 10 f0 	movl   $0xf0103c7a,(%esp)
f01000ca:	e8 2c 21 00 00       	call   f01021fb <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 a1 06 00 00       	call   f010077c <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <i386_init>:
#include <kern/kclock.h>


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
f01000e3:	b8 f0 49 11 f0       	mov    $0xf01149f0,%eax
f01000e8:	2d 58 43 11 f0       	sub    $0xf0114358,%eax
f01000ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000f8:	00 
f01000f9:	c7 04 24 58 43 11 f0 	movl   $0xf0114358,(%esp)
f0100100:	e8 41 2d 00 00       	call   f0102e46 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100105:	e8 31 02 00 00       	call   f010033b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010010a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100111:	00 
f0100112:	c7 04 24 12 33 10 f0 	movl   $0xf0103312,(%esp)
f0100119:	e8 dd 20 00 00       	call   f01021fb <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f010011e:	e8 ea 1a 00 00       	call   f0101c0d <i386_detect_memory>
	i386_vm_init();
f0100123:	e8 02 17 00 00       	call   f010182a <i386_vm_init>
	page_init();
f0100128:	e8 77 1b 00 00       	call   f0101ca4 <page_init>
	page_check();
f010012d:	8d 76 00             	lea    0x0(%esi),%esi
f0100130:	e8 e3 0c 00 00       	call   f0100e18 <page_check>



	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010013c:	e8 3b 06 00 00       	call   f010077c <monitor>
f0100141:	eb f2                	jmp    f0100135 <i386_init+0x58>
	...

f0100150 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100153:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100158:	ec                   	in     (%dx),%al
f0100159:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100160:	f6 c2 01             	test   $0x1,%dl
f0100163:	74 09                	je     f010016e <serial_proc_data+0x1e>
f0100165:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010016a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010016b:	0f b6 c0             	movzbl %al,%eax
}
f010016e:	5d                   	pop    %ebp
f010016f:	c3                   	ret    

f0100170 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100174:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100179:	b8 00 00 00 00       	mov    $0x0,%eax
f010017e:	89 da                	mov    %ebx,%edx
f0100180:	ee                   	out    %al,(%dx)
f0100181:	b2 fb                	mov    $0xfb,%dl
f0100183:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100188:	ee                   	out    %al,(%dx)
f0100189:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010018e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100193:	89 ca                	mov    %ecx,%edx
f0100195:	ee                   	out    %al,(%dx)
f0100196:	b2 f9                	mov    $0xf9,%dl
f0100198:	b8 00 00 00 00       	mov    $0x0,%eax
f010019d:	ee                   	out    %al,(%dx)
f010019e:	b2 fb                	mov    $0xfb,%dl
f01001a0:	b8 03 00 00 00       	mov    $0x3,%eax
f01001a5:	ee                   	out    %al,(%dx)
f01001a6:	b2 fc                	mov    $0xfc,%dl
f01001a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ad:	ee                   	out    %al,(%dx)
f01001ae:	b2 f9                	mov    $0xf9,%dl
f01001b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01001b5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001b6:	b2 fd                	mov    $0xfd,%dl
f01001b8:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01001b9:	3c ff                	cmp    $0xff,%al
f01001bb:	0f 95 c0             	setne  %al
f01001be:	0f b6 c0             	movzbl %al,%eax
f01001c1:	a3 84 43 11 f0       	mov    %eax,0xf0114384
f01001c6:	89 da                	mov    %ebx,%edx
f01001c8:	ec                   	in     (%dx),%al
f01001c9:	89 ca                	mov    %ecx,%edx
f01001cb:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f01001cc:	5b                   	pop    %ebx
f01001cd:	5d                   	pop    %ebp
f01001ce:	c3                   	ret    

f01001cf <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f01001cf:	55                   	push   %ebp
f01001d0:	89 e5                	mov    %esp,%ebp
f01001d2:	83 ec 0c             	sub    $0xc,%esp
f01001d5:	89 1c 24             	mov    %ebx,(%esp)
f01001d8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01001dc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01001e0:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01001e5:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01001e8:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01001ed:	0f b7 00             	movzwl (%eax),%eax
f01001f0:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01001f4:	74 11                	je     f0100207 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01001f6:	c7 05 88 43 11 f0 b4 	movl   $0x3b4,0xf0114388
f01001fd:	03 00 00 
f0100200:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100205:	eb 16                	jmp    f010021d <cga_init+0x4e>
	} else {
		*cp = was;
f0100207:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010020e:	c7 05 88 43 11 f0 d4 	movl   $0x3d4,0xf0114388
f0100215:	03 00 00 
f0100218:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010021d:	8b 0d 88 43 11 f0    	mov    0xf0114388,%ecx
f0100223:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100225:	b8 0e 00 00 00       	mov    $0xe,%eax
f010022a:	89 ca                	mov    %ecx,%edx
f010022c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010022d:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100230:	89 ca                	mov    %ecx,%edx
f0100232:	ec                   	in     (%dx),%al
f0100233:	0f b6 f8             	movzbl %al,%edi
f0100236:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100239:	b8 0f 00 00 00       	mov    $0xf,%eax
f010023e:	89 da                	mov    %ebx,%edx
f0100240:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100241:	89 ca                	mov    %ecx,%edx
f0100243:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100244:	89 35 8c 43 11 f0    	mov    %esi,0xf011438c
	crt_pos = pos;
f010024a:	0f b6 c8             	movzbl %al,%ecx
f010024d:	09 cf                	or     %ecx,%edi
f010024f:	66 89 3d 90 43 11 f0 	mov    %di,0xf0114390
}
f0100256:	8b 1c 24             	mov    (%esp),%ebx
f0100259:	8b 74 24 04          	mov    0x4(%esp),%esi
f010025d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0100261:	89 ec                	mov    %ebp,%esp
f0100263:	5d                   	pop    %ebp
f0100264:	c3                   	ret    

f0100265 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f0100265:	55                   	push   %ebp
f0100266:	89 e5                	mov    %esp,%ebp
}
f0100268:	5d                   	pop    %ebp
f0100269:	c3                   	ret    

f010026a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp
f010026d:	57                   	push   %edi
f010026e:	56                   	push   %esi
f010026f:	53                   	push   %ebx
f0100270:	83 ec 0c             	sub    $0xc,%esp
f0100273:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100276:	bb a4 45 11 f0       	mov    $0xf01145a4,%ebx
f010027b:	bf a0 43 11 f0       	mov    $0xf01143a0,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100280:	eb 1b                	jmp    f010029d <cons_intr+0x33>
		if (c == 0)
f0100282:	85 c0                	test   %eax,%eax
f0100284:	74 17                	je     f010029d <cons_intr+0x33>
			continue;
		cons.buf[cons.wpos++] = c;
f0100286:	8b 13                	mov    (%ebx),%edx
f0100288:	88 04 3a             	mov    %al,(%edx,%edi,1)
f010028b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010028e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100293:	ba 00 00 00 00       	mov    $0x0,%edx
f0100298:	0f 44 c2             	cmove  %edx,%eax
f010029b:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010029d:	ff d6                	call   *%esi
f010029f:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a2:	75 de                	jne    f0100282 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002a4:	83 c4 0c             	add    $0xc,%esp
f01002a7:	5b                   	pop    %ebx
f01002a8:	5e                   	pop    %esi
f01002a9:	5f                   	pop    %edi
f01002aa:	5d                   	pop    %ebp
f01002ab:	c3                   	ret    

f01002ac <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01002ac:	55                   	push   %ebp
f01002ad:	89 e5                	mov    %esp,%ebp
f01002af:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f01002b2:	c7 04 24 62 03 10 f0 	movl   $0xf0100362,(%esp)
f01002b9:	e8 ac ff ff ff       	call   f010026a <cons_intr>
}
f01002be:	c9                   	leave  
f01002bf:	c3                   	ret    

f01002c0 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp
f01002c3:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f01002c6:	83 3d 84 43 11 f0 00 	cmpl   $0x0,0xf0114384
f01002cd:	74 0c                	je     f01002db <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f01002cf:	c7 04 24 50 01 10 f0 	movl   $0xf0100150,(%esp)
f01002d6:	e8 8f ff ff ff       	call   f010026a <cons_intr>
}
f01002db:	c9                   	leave  
f01002dc:	c3                   	ret    

f01002dd <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01002dd:	55                   	push   %ebp
f01002de:	89 e5                	mov    %esp,%ebp
f01002e0:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01002e3:	e8 d8 ff ff ff       	call   f01002c0 <serial_intr>
	kbd_intr();
f01002e8:	e8 bf ff ff ff       	call   f01002ac <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01002ed:	8b 15 a0 45 11 f0    	mov    0xf01145a0,%edx
f01002f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f8:	3b 15 a4 45 11 f0    	cmp    0xf01145a4,%edx
f01002fe:	74 1e                	je     f010031e <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100300:	0f b6 82 a0 43 11 f0 	movzbl -0xfeebc60(%edx),%eax
f0100307:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010030a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100310:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100315:	0f 44 d1             	cmove  %ecx,%edx
f0100318:	89 15 a0 45 11 f0    	mov    %edx,0xf01145a0
		return c;
	}
	return 0;
}
f010031e:	c9                   	leave  
f010031f:	c3                   	ret    

f0100320 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100320:	55                   	push   %ebp
f0100321:	89 e5                	mov    %esp,%ebp
f0100323:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100326:	e8 b2 ff ff ff       	call   f01002dd <cons_getc>
f010032b:	85 c0                	test   %eax,%eax
f010032d:	74 f7                	je     f0100326 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010032f:	c9                   	leave  
f0100330:	c3                   	ret    

f0100331 <iscons>:

int
iscons(int fdnum)
{
f0100331:	55                   	push   %ebp
f0100332:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100334:	b8 01 00 00 00       	mov    $0x1,%eax
f0100339:	5d                   	pop    %ebp
f010033a:	c3                   	ret    

f010033b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010033b:	55                   	push   %ebp
f010033c:	89 e5                	mov    %esp,%ebp
f010033e:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100341:	e8 89 fe ff ff       	call   f01001cf <cga_init>
	kbd_init();
	serial_init();
f0100346:	e8 25 fe ff ff       	call   f0100170 <serial_init>

	if (!serial_exists)
f010034b:	83 3d 84 43 11 f0 00 	cmpl   $0x0,0xf0114384
f0100352:	75 0c                	jne    f0100360 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f0100354:	c7 04 24 2d 33 10 f0 	movl   $0xf010332d,(%esp)
f010035b:	e8 9b 1e 00 00       	call   f01021fb <cprintf>
}
f0100360:	c9                   	leave  
f0100361:	c3                   	ret    

f0100362 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100362:	55                   	push   %ebp
f0100363:	89 e5                	mov    %esp,%ebp
f0100365:	53                   	push   %ebx
f0100366:	83 ec 14             	sub    $0x14,%esp
f0100369:	ba 64 00 00 00       	mov    $0x64,%edx
f010036e:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010036f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100374:	a8 01                	test   $0x1,%al
f0100376:	0f 84 dd 00 00 00    	je     f0100459 <kbd_proc_data+0xf7>
f010037c:	b2 60                	mov    $0x60,%dl
f010037e:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010037f:	3c e0                	cmp    $0xe0,%al
f0100381:	75 11                	jne    f0100394 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100383:	83 0d 80 43 11 f0 40 	orl    $0x40,0xf0114380
f010038a:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010038f:	e9 c5 00 00 00       	jmp    f0100459 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f0100394:	84 c0                	test   %al,%al
f0100396:	79 35                	jns    f01003cd <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100398:	8b 15 80 43 11 f0    	mov    0xf0114380,%edx
f010039e:	89 c1                	mov    %eax,%ecx
f01003a0:	83 e1 7f             	and    $0x7f,%ecx
f01003a3:	f6 c2 40             	test   $0x40,%dl
f01003a6:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01003a9:	0f b6 c0             	movzbl %al,%eax
f01003ac:	0f b6 80 60 33 10 f0 	movzbl -0xfefcca0(%eax),%eax
f01003b3:	83 c8 40             	or     $0x40,%eax
f01003b6:	0f b6 c0             	movzbl %al,%eax
f01003b9:	f7 d0                	not    %eax
f01003bb:	21 c2                	and    %eax,%edx
f01003bd:	89 15 80 43 11 f0    	mov    %edx,0xf0114380
f01003c3:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01003c8:	e9 8c 00 00 00       	jmp    f0100459 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f01003cd:	8b 15 80 43 11 f0    	mov    0xf0114380,%edx
f01003d3:	f6 c2 40             	test   $0x40,%dl
f01003d6:	74 0c                	je     f01003e4 <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003d8:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01003db:	83 e2 bf             	and    $0xffffffbf,%edx
f01003de:	89 15 80 43 11 f0    	mov    %edx,0xf0114380
	}

	shift |= shiftcode[data];
f01003e4:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01003e7:	0f b6 90 60 33 10 f0 	movzbl -0xfefcca0(%eax),%edx
f01003ee:	0b 15 80 43 11 f0    	or     0xf0114380,%edx
f01003f4:	0f b6 88 60 34 10 f0 	movzbl -0xfefcba0(%eax),%ecx
f01003fb:	31 ca                	xor    %ecx,%edx
f01003fd:	89 15 80 43 11 f0    	mov    %edx,0xf0114380

	c = charcode[shift & (CTL | SHIFT)][data];
f0100403:	89 d1                	mov    %edx,%ecx
f0100405:	83 e1 03             	and    $0x3,%ecx
f0100408:	8b 0c 8d 60 35 10 f0 	mov    -0xfefcaa0(,%ecx,4),%ecx
f010040f:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100413:	f6 c2 08             	test   $0x8,%dl
f0100416:	74 1b                	je     f0100433 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100418:	89 d9                	mov    %ebx,%ecx
f010041a:	8d 43 9f             	lea    -0x61(%ebx),%eax
f010041d:	83 f8 19             	cmp    $0x19,%eax
f0100420:	77 05                	ja     f0100427 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100422:	83 eb 20             	sub    $0x20,%ebx
f0100425:	eb 0c                	jmp    f0100433 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100427:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f010042a:	8d 43 20             	lea    0x20(%ebx),%eax
f010042d:	83 f9 19             	cmp    $0x19,%ecx
f0100430:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100433:	f7 d2                	not    %edx
f0100435:	f6 c2 06             	test   $0x6,%dl
f0100438:	75 1f                	jne    f0100459 <kbd_proc_data+0xf7>
f010043a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100440:	75 17                	jne    f0100459 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f0100442:	c7 04 24 4a 33 10 f0 	movl   $0xf010334a,(%esp)
f0100449:	e8 ad 1d 00 00       	call   f01021fb <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100453:	b8 03 00 00 00       	mov    $0x3,%eax
f0100458:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100459:	89 d8                	mov    %ebx,%eax
f010045b:	83 c4 14             	add    $0x14,%esp
f010045e:	5b                   	pop    %ebx
f010045f:	5d                   	pop    %ebp
f0100460:	c3                   	ret    

f0100461 <cga_putc>:



void
cga_putc(int c)
{
f0100461:	55                   	push   %ebp
f0100462:	89 e5                	mov    %esp,%ebp
f0100464:	56                   	push   %esi
f0100465:	53                   	push   %ebx
f0100466:	83 ec 10             	sub    $0x10,%esp
f0100469:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f010046c:	89 c2                	mov    %eax,%edx
f010046e:	80 ce 07             	or     $0x7,%dh
f0100471:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f0100476:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f0100479:	0f b6 d0             	movzbl %al,%edx
f010047c:	83 fa 09             	cmp    $0x9,%edx
f010047f:	0f 84 88 00 00 00    	je     f010050d <cga_putc+0xac>
f0100485:	83 fa 09             	cmp    $0x9,%edx
f0100488:	7f 10                	jg     f010049a <cga_putc+0x39>
f010048a:	83 fa 08             	cmp    $0x8,%edx
f010048d:	0f 85 b8 00 00 00    	jne    f010054b <cga_putc+0xea>
f0100493:	90                   	nop
f0100494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100498:	eb 18                	jmp    f01004b2 <cga_putc+0x51>
f010049a:	83 fa 0a             	cmp    $0xa,%edx
f010049d:	8d 76 00             	lea    0x0(%esi),%esi
f01004a0:	74 41                	je     f01004e3 <cga_putc+0x82>
f01004a2:	83 fa 0d             	cmp    $0xd,%edx
f01004a5:	8d 76 00             	lea    0x0(%esi),%esi
f01004a8:	0f 85 9d 00 00 00    	jne    f010054b <cga_putc+0xea>
f01004ae:	66 90                	xchg   %ax,%ax
f01004b0:	eb 39                	jmp    f01004eb <cga_putc+0x8a>
	case '\b':
		if (crt_pos > 0) {
f01004b2:	0f b7 15 90 43 11 f0 	movzwl 0xf0114390,%edx
f01004b9:	66 85 d2             	test   %dx,%dx
f01004bc:	0f 84 f4 00 00 00    	je     f01005b6 <cga_putc+0x155>
			crt_pos--;
f01004c2:	83 ea 01             	sub    $0x1,%edx
f01004c5:	66 89 15 90 43 11 f0 	mov    %dx,0xf0114390
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004cc:	0f b7 d2             	movzwl %dx,%edx
f01004cf:	b0 00                	mov    $0x0,%al
f01004d1:	83 c8 20             	or     $0x20,%eax
f01004d4:	8b 0d 8c 43 11 f0    	mov    0xf011438c,%ecx
f01004da:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01004de:	e9 86 00 00 00       	jmp    f0100569 <cga_putc+0x108>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e3:	66 83 05 90 43 11 f0 	addw   $0x50,0xf0114390
f01004ea:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004eb:	0f b7 05 90 43 11 f0 	movzwl 0xf0114390,%eax
f01004f2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f8:	c1 e8 10             	shr    $0x10,%eax
f01004fb:	66 c1 e8 06          	shr    $0x6,%ax
f01004ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100502:	c1 e0 04             	shl    $0x4,%eax
f0100505:	66 a3 90 43 11 f0    	mov    %ax,0xf0114390
		break;
f010050b:	eb 5c                	jmp    f0100569 <cga_putc+0x108>
	case '\t':
		cons_putc(' ');
f010050d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100514:	e8 d4 00 00 00       	call   f01005ed <cons_putc>
		cons_putc(' ');
f0100519:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100520:	e8 c8 00 00 00       	call   f01005ed <cons_putc>
		cons_putc(' ');
f0100525:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010052c:	e8 bc 00 00 00       	call   f01005ed <cons_putc>
		cons_putc(' ');
f0100531:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100538:	e8 b0 00 00 00       	call   f01005ed <cons_putc>
		cons_putc(' ');
f010053d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100544:	e8 a4 00 00 00       	call   f01005ed <cons_putc>
		break;
f0100549:	eb 1e                	jmp    f0100569 <cga_putc+0x108>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010054b:	0f b7 15 90 43 11 f0 	movzwl 0xf0114390,%edx
f0100552:	0f b7 da             	movzwl %dx,%ebx
f0100555:	8b 0d 8c 43 11 f0    	mov    0xf011438c,%ecx
f010055b:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010055f:	83 c2 01             	add    $0x1,%edx
f0100562:	66 89 15 90 43 11 f0 	mov    %dx,0xf0114390
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100569:	66 81 3d 90 43 11 f0 	cmpw   $0x7cf,0xf0114390
f0100570:	cf 07 
f0100572:	76 42                	jbe    f01005b6 <cga_putc+0x155>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100574:	a1 8c 43 11 f0       	mov    0xf011438c,%eax
f0100579:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100580:	00 
f0100581:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100587:	89 54 24 04          	mov    %edx,0x4(%esp)
f010058b:	89 04 24             	mov    %eax,(%esp)
f010058e:	e8 d7 28 00 00       	call   f0102e6a <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100593:	8b 15 8c 43 11 f0    	mov    0xf011438c,%edx
f0100599:	b8 80 07 00 00       	mov    $0x780,%eax
f010059e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a4:	83 c0 01             	add    $0x1,%eax
f01005a7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005ac:	75 f0                	jne    f010059e <cga_putc+0x13d>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005ae:	66 83 2d 90 43 11 f0 	subw   $0x50,0xf0114390
f01005b5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005b6:	8b 0d 88 43 11 f0    	mov    0xf0114388,%ecx
f01005bc:	89 cb                	mov    %ecx,%ebx
f01005be:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005c3:	89 ca                	mov    %ecx,%edx
f01005c5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005c6:	0f b7 35 90 43 11 f0 	movzwl 0xf0114390,%esi
f01005cd:	83 c1 01             	add    $0x1,%ecx
f01005d0:	89 f0                	mov    %esi,%eax
f01005d2:	66 c1 e8 08          	shr    $0x8,%ax
f01005d6:	89 ca                	mov    %ecx,%edx
f01005d8:	ee                   	out    %al,(%dx)
f01005d9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005de:	89 da                	mov    %ebx,%edx
f01005e0:	ee                   	out    %al,(%dx)
f01005e1:	89 f0                	mov    %esi,%eax
f01005e3:	89 ca                	mov    %ecx,%edx
f01005e5:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f01005e6:	83 c4 10             	add    $0x10,%esp
f01005e9:	5b                   	pop    %ebx
f01005ea:	5e                   	pop    %esi
f01005eb:	5d                   	pop    %ebp
f01005ec:	c3                   	ret    

f01005ed <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f01005ed:	55                   	push   %ebp
f01005ee:	89 e5                	mov    %esp,%ebp
f01005f0:	57                   	push   %edi
f01005f1:	56                   	push   %esi
f01005f2:	53                   	push   %ebx
f01005f3:	83 ec 1c             	sub    $0x1c,%esp
f01005f6:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f9:	ba 79 03 00 00       	mov    $0x379,%edx
f01005fe:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01005ff:	84 c0                	test   %al,%al
f0100601:	78 27                	js     f010062a <cons_putc+0x3d>
f0100603:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100608:	b9 84 00 00 00       	mov    $0x84,%ecx
f010060d:	be 79 03 00 00       	mov    $0x379,%esi
f0100612:	89 ca                	mov    %ecx,%edx
f0100614:	ec                   	in     (%dx),%al
f0100615:	ec                   	in     (%dx),%al
f0100616:	ec                   	in     (%dx),%al
f0100617:	ec                   	in     (%dx),%al
f0100618:	89 f2                	mov    %esi,%edx
f010061a:	ec                   	in     (%dx),%al
f010061b:	84 c0                	test   %al,%al
f010061d:	78 0b                	js     f010062a <cons_putc+0x3d>
f010061f:	83 c3 01             	add    $0x1,%ebx
f0100622:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100628:	75 e8                	jne    f0100612 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010062a:	ba 78 03 00 00       	mov    $0x378,%edx
f010062f:	89 f8                	mov    %edi,%eax
f0100631:	ee                   	out    %al,(%dx)
f0100632:	b2 7a                	mov    $0x7a,%dl
f0100634:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100639:	ee                   	out    %al,(%dx)
f010063a:	b8 08 00 00 00       	mov    $0x8,%eax
f010063f:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f0100640:	89 3c 24             	mov    %edi,(%esp)
f0100643:	e8 19 fe ff ff       	call   f0100461 <cga_putc>
}
f0100648:	83 c4 1c             	add    $0x1c,%esp
f010064b:	5b                   	pop    %ebx
f010064c:	5e                   	pop    %esi
f010064d:	5f                   	pop    %edi
f010064e:	5d                   	pop    %ebp
f010064f:	c3                   	ret    

f0100650 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
f0100653:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f0100656:	8b 45 08             	mov    0x8(%ebp),%eax
f0100659:	89 04 24             	mov    %eax,(%esp)
f010065c:	e8 8c ff ff ff       	call   f01005ed <cons_putc>
}
f0100661:	c9                   	leave  
f0100662:	c3                   	ret    
	...

f0100670 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100670:	55                   	push   %ebp
f0100671:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100673:	b8 00 00 00 00       	mov    $0x0,%eax
f0100678:	5d                   	pop    %ebp
f0100679:	c3                   	ret    

f010067a <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f010067a:	55                   	push   %ebp
f010067b:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010067d:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100680:	5d                   	pop    %ebp
f0100681:	c3                   	ret    

f0100682 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100682:	55                   	push   %ebp
f0100683:	89 e5                	mov    %esp,%ebp
f0100685:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100688:	c7 04 24 70 35 10 f0 	movl   $0xf0103570,(%esp)
f010068f:	e8 67 1b 00 00       	call   f01021fb <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100694:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010069b:	00 
f010069c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006a3:	f0 
f01006a4:	c7 04 24 fc 35 10 f0 	movl   $0xf01035fc,(%esp)
f01006ab:	e8 4b 1b 00 00       	call   f01021fb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b0:	c7 44 24 08 c5 32 10 	movl   $0x1032c5,0x8(%esp)
f01006b7:	00 
f01006b8:	c7 44 24 04 c5 32 10 	movl   $0xf01032c5,0x4(%esp)
f01006bf:	f0 
f01006c0:	c7 04 24 20 36 10 f0 	movl   $0xf0103620,(%esp)
f01006c7:	e8 2f 1b 00 00       	call   f01021fb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006cc:	c7 44 24 08 58 43 11 	movl   $0x114358,0x8(%esp)
f01006d3:	00 
f01006d4:	c7 44 24 04 58 43 11 	movl   $0xf0114358,0x4(%esp)
f01006db:	f0 
f01006dc:	c7 04 24 44 36 10 f0 	movl   $0xf0103644,(%esp)
f01006e3:	e8 13 1b 00 00       	call   f01021fb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e8:	c7 44 24 08 f0 49 11 	movl   $0x1149f0,0x8(%esp)
f01006ef:	00 
f01006f0:	c7 44 24 04 f0 49 11 	movl   $0xf01149f0,0x4(%esp)
f01006f7:	f0 
f01006f8:	c7 04 24 68 36 10 f0 	movl   $0xf0103668,(%esp)
f01006ff:	e8 f7 1a 00 00       	call   f01021fb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100704:	b8 ef 4d 11 f0       	mov    $0xf0114def,%eax
f0100709:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010070e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100714:	85 c0                	test   %eax,%eax
f0100716:	0f 48 c2             	cmovs  %edx,%eax
f0100719:	c1 f8 0a             	sar    $0xa,%eax
f010071c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100720:	c7 04 24 8c 36 10 f0 	movl   $0xf010368c,(%esp)
f0100727:	e8 cf 1a 00 00       	call   f01021fb <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010072c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100731:	c9                   	leave  
f0100732:	c3                   	ret    

f0100733 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100739:	a1 30 37 10 f0       	mov    0xf0103730,%eax
f010073e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100742:	a1 2c 37 10 f0       	mov    0xf010372c,%eax
f0100747:	89 44 24 04          	mov    %eax,0x4(%esp)
f010074b:	c7 04 24 89 35 10 f0 	movl   $0xf0103589,(%esp)
f0100752:	e8 a4 1a 00 00       	call   f01021fb <cprintf>
f0100757:	a1 3c 37 10 f0       	mov    0xf010373c,%eax
f010075c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100760:	a1 38 37 10 f0       	mov    0xf0103738,%eax
f0100765:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100769:	c7 04 24 89 35 10 f0 	movl   $0xf0103589,(%esp)
f0100770:	e8 86 1a 00 00       	call   f01021fb <cprintf>
	return 0;
}
f0100775:	b8 00 00 00 00       	mov    $0x0,%eax
f010077a:	c9                   	leave  
f010077b:	c3                   	ret    

f010077c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010077c:	55                   	push   %ebp
f010077d:	89 e5                	mov    %esp,%ebp
f010077f:	57                   	push   %edi
f0100780:	56                   	push   %esi
f0100781:	53                   	push   %ebx
f0100782:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100785:	c7 04 24 b8 36 10 f0 	movl   $0xf01036b8,(%esp)
f010078c:	e8 6a 1a 00 00       	call   f01021fb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100791:	c7 04 24 dc 36 10 f0 	movl   $0xf01036dc,(%esp)
f0100798:	e8 5e 1a 00 00       	call   f01021fb <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010079d:	bf 2c 37 10 f0       	mov    $0xf010372c,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f01007a2:	c7 04 24 92 35 10 f0 	movl   $0xf0103592,(%esp)
f01007a9:	e8 22 24 00 00       	call   f0102bd0 <readline>
f01007ae:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007b0:	85 c0                	test   %eax,%eax
f01007b2:	74 ee                	je     f01007a2 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007b4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f01007bb:	be 00 00 00 00       	mov    $0x0,%esi
f01007c0:	eb 06                	jmp    f01007c8 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007c2:	c6 03 00             	movb   $0x0,(%ebx)
f01007c5:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007c8:	0f b6 03             	movzbl (%ebx),%eax
f01007cb:	84 c0                	test   %al,%al
f01007cd:	74 6c                	je     f010083b <monitor+0xbf>
f01007cf:	0f be c0             	movsbl %al,%eax
f01007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007d6:	c7 04 24 96 35 10 f0 	movl   $0xf0103596,(%esp)
f01007dd:	e8 0c 26 00 00       	call   f0102dee <strchr>
f01007e2:	85 c0                	test   %eax,%eax
f01007e4:	75 dc                	jne    f01007c2 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01007e6:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007e9:	74 50                	je     f010083b <monitor+0xbf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007eb:	83 fe 0f             	cmp    $0xf,%esi
f01007ee:	66 90                	xchg   %ax,%ax
f01007f0:	75 16                	jne    f0100808 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007f2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007f9:	00 
f01007fa:	c7 04 24 9b 35 10 f0 	movl   $0xf010359b,(%esp)
f0100801:	e8 f5 19 00 00       	call   f01021fb <cprintf>
f0100806:	eb 9a                	jmp    f01007a2 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f0100808:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010080c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010080f:	0f b6 03             	movzbl (%ebx),%eax
f0100812:	84 c0                	test   %al,%al
f0100814:	75 0c                	jne    f0100822 <monitor+0xa6>
f0100816:	eb b0                	jmp    f01007c8 <monitor+0x4c>
			buf++;
f0100818:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010081b:	0f b6 03             	movzbl (%ebx),%eax
f010081e:	84 c0                	test   %al,%al
f0100820:	74 a6                	je     f01007c8 <monitor+0x4c>
f0100822:	0f be c0             	movsbl %al,%eax
f0100825:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100829:	c7 04 24 96 35 10 f0 	movl   $0xf0103596,(%esp)
f0100830:	e8 b9 25 00 00       	call   f0102dee <strchr>
f0100835:	85 c0                	test   %eax,%eax
f0100837:	74 df                	je     f0100818 <monitor+0x9c>
f0100839:	eb 8d                	jmp    f01007c8 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f010083b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100842:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100843:	85 f6                	test   %esi,%esi
f0100845:	0f 84 57 ff ff ff    	je     f01007a2 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010084b:	8b 07                	mov    (%edi),%eax
f010084d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100851:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100854:	89 04 24             	mov    %eax,(%esp)
f0100857:	e8 1d 25 00 00       	call   f0102d79 <strcmp>
f010085c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100861:	85 c0                	test   %eax,%eax
f0100863:	74 1d                	je     f0100882 <monitor+0x106>
f0100865:	a1 38 37 10 f0       	mov    0xf0103738,%eax
f010086a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010086e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100871:	89 04 24             	mov    %eax,(%esp)
f0100874:	e8 00 25 00 00       	call   f0102d79 <strcmp>
f0100879:	85 c0                	test   %eax,%eax
f010087b:	75 28                	jne    f01008a5 <monitor+0x129>
f010087d:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f0100882:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100885:	8b 45 08             	mov    0x8(%ebp),%eax
f0100888:	89 44 24 08          	mov    %eax,0x8(%esp)
f010088c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010088f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100893:	89 34 24             	mov    %esi,(%esp)
f0100896:	ff 92 34 37 10 f0    	call   *-0xfefc8cc(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010089c:	85 c0                	test   %eax,%eax
f010089e:	78 1d                	js     f01008bd <monitor+0x141>
f01008a0:	e9 fd fe ff ff       	jmp    f01007a2 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008a5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ac:	c7 04 24 b8 35 10 f0 	movl   $0xf01035b8,(%esp)
f01008b3:	e8 43 19 00 00       	call   f01021fb <cprintf>
f01008b8:	e9 e5 fe ff ff       	jmp    f01007a2 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008bd:	83 c4 5c             	add    $0x5c,%esp
f01008c0:	5b                   	pop    %ebx
f01008c1:	5e                   	pop    %esi
f01008c2:	5f                   	pop    %edi
f01008c3:	5d                   	pop    %ebp
f01008c4:	c3                   	ret    
	...

f01008d0 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f01008d0:	55                   	push   %ebp
f01008d1:	89 e5                	mov    %esp,%ebp
f01008d3:	83 ec 0c             	sub    $0xc,%esp
f01008d6:	89 1c 24             	mov    %ebx,(%esp)
f01008d9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01008dd:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01008e1:	89 c3                	mov    %eax,%ebx
f01008e3:	89 d7                	mov    %edx,%edi
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
		boot_freemem = end;
f01008e5:	83 3d b4 45 11 f0 00 	cmpl   $0x0,0xf01145b4
	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	//	Step 2: save current value of boot_freemem as allocated chunk
	//	Step 3: increase boot_freemem to record allocation
	//	Step 4: return allocated chunk
        boot_freemem = ROUNDUP(boot_freemem,align);
f01008ec:	b8 f0 49 11 f0       	mov    $0xf01149f0,%eax
f01008f1:	0f 45 05 b4 45 11 f0 	cmovne 0xf01145b4,%eax
f01008f8:	8d 4c 02 ff          	lea    -0x1(%edx,%eax,1),%ecx
f01008fc:	89 c8                	mov    %ecx,%eax
f01008fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0100903:	f7 f7                	div    %edi
f0100905:	89 c8                	mov    %ecx,%eax
f0100907:	29 d0                	sub    %edx,%eax
        v=boot_freemem;
		boot_freemem+=n;
f0100909:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
f010090c:	89 1d b4 45 11 f0    	mov    %ebx,0xf01145b4
		return v;
}
f0100912:	8b 1c 24             	mov    (%esp),%ebx
f0100915:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100919:	8b 7c 24 08          	mov    0x8(%esp),%edi
f010091d:	89 ec                	mov    %ebp,%esp
f010091f:	5d                   	pop    %ebp
f0100920:	c3                   	ret    

f0100921 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100921:	55                   	push   %ebp
f0100922:	89 e5                	mov    %esp,%ebp
f0100924:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	LIST_INSERT_HEAD (&page_free_list, pp, pp_link);
f0100927:	8b 15 b8 45 11 f0    	mov    0xf01145b8,%edx
f010092d:	89 10                	mov    %edx,(%eax)
f010092f:	85 d2                	test   %edx,%edx
f0100931:	74 09                	je     f010093c <page_free+0x1b>
f0100933:	8b 15 b8 45 11 f0    	mov    0xf01145b8,%edx
f0100939:	89 42 04             	mov    %eax,0x4(%edx)
f010093c:	a3 b8 45 11 f0       	mov    %eax,0xf01145b8
f0100941:	c7 40 04 b8 45 11 f0 	movl   $0xf01145b8,0x4(%eax)
}
f0100948:	5d                   	pop    %ebp
f0100949:	c3                   	ret    

f010094a <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f010094a:	55                   	push   %ebp
f010094b:	89 e5                	mov    %esp,%ebp
f010094d:	83 ec 04             	sub    $0x4,%esp
f0100950:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100953:	0f b7 50 08          	movzwl 0x8(%eax),%edx
f0100957:	83 ea 01             	sub    $0x1,%edx
f010095a:	66 89 50 08          	mov    %dx,0x8(%eax)
f010095e:	66 85 d2             	test   %dx,%dx
f0100961:	75 08                	jne    f010096b <page_decref+0x21>
		page_free(pp);
f0100963:	89 04 24             	mov    %eax,(%esp)
f0100966:	e8 b6 ff ff ff       	call   f0100921 <page_free>
}
f010096b:	c9                   	leave  
f010096c:	c3                   	ret    

f010096d <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010096d:	55                   	push   %ebp
f010096e:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100970:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100973:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100976:	5d                   	pop    %ebp
f0100977:	c3                   	ret    

f0100978 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100978:	55                   	push   %ebp
f0100979:	89 e5                	mov    %esp,%ebp
f010097b:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f010097e:	89 d1                	mov    %edx,%ecx
f0100980:	c1 e9 16             	shr    $0x16,%ecx
f0100983:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100986:	a8 01                	test   $0x1,%al
f0100988:	74 4d                	je     f01009d7 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010098a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010098f:	89 c1                	mov    %eax,%ecx
f0100991:	c1 e9 0c             	shr    $0xc,%ecx
f0100994:	3b 0d e0 49 11 f0    	cmp    0xf01149e0,%ecx
f010099a:	72 20                	jb     f01009bc <check_va2pa+0x44>
f010099c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009a0:	c7 44 24 08 44 37 10 	movl   $0xf0103744,0x8(%esp)
f01009a7:	f0 
f01009a8:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f01009af:	00 
f01009b0:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01009b7:	e8 c4 f6 ff ff       	call   f0100080 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f01009bc:	c1 ea 0c             	shr    $0xc,%edx
f01009bf:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009c5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009cc:	a8 01                	test   $0x1,%al
f01009ce:	74 07                	je     f01009d7 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009d5:	eb 05                	jmp    f01009dc <check_va2pa+0x64>
f01009d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01009dc:	c9                   	leave  
f01009dd:	c3                   	ret    

f01009de <page2kva>:
	return &pages[PPN(pa)];
}

static inline void*
page2kva(struct Page *pp)
{
f01009de:	55                   	push   %ebp
f01009df:	89 e5                	mov    %esp,%ebp
f01009e1:	83 ec 18             	sub    $0x18,%esp
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01009e4:	2b 05 ec 49 11 f0    	sub    0xf01149ec,%eax
f01009ea:	c1 f8 02             	sar    $0x2,%eax
f01009ed:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01009f3:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01009f6:	89 c2                	mov    %eax,%edx
f01009f8:	c1 ea 0c             	shr    $0xc,%edx
f01009fb:	3b 15 e0 49 11 f0    	cmp    0xf01149e0,%edx
f0100a01:	72 20                	jb     f0100a23 <page2kva+0x45>
f0100a03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a07:	c7 44 24 08 44 37 10 	movl   $0xf0103744,0x8(%esp)
f0100a0e:	f0 
f0100a0f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0100a16:	00 
f0100a17:	c7 04 24 69 3b 10 f0 	movl   $0xf0103b69,(%esp)
f0100a1e:	e8 5d f6 ff ff       	call   f0100080 <_panic>
f0100a23:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0100a28:	c9                   	leave  
f0100a29:	c3                   	ret    

f0100a2a <boot_map_segment>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
//
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0100a2a:	55                   	push   %ebp
f0100a2b:	89 e5                	mov    %esp,%ebp
f0100a2d:	57                   	push   %edi
f0100a2e:	56                   	push   %esi
f0100a2f:	53                   	push   %ebx
f0100a30:	83 ec 2c             	sub    $0x2c,%esp
f0100a33:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100a36:	89 d3                	mov    %edx,%ebx
	int i;

	for ( i = 0; i < size/PGSIZE; i ++ ) {
f0100a38:	c1 e9 0c             	shr    $0xc,%ecx
f0100a3b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100a3e:	85 c9                	test   %ecx,%ecx
f0100a40:	0f 84 e5 00 00 00    	je     f0100b2b <boot_map_segment+0x101>
		pte_t *pte=boot_pgdir_walk(pgdir,la+i*PGSIZE,1);
		pgdir[PDX(la)]=(pgdir[PDX(la)] & 0xFFFFF000) | perm | PTE_P;
f0100a46:	89 d0                	mov    %edx,%eax
f0100a48:	c1 e8 16             	shr    $0x16,%eax
f0100a4b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a4e:	8d 34 82             	lea    (%edx,%eax,4),%esi
f0100a51:	bf 00 00 00 00       	mov    $0x0,%edi
f0100a56:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a59:	83 c8 01             	or     $0x1,%eax
f0100a5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// on failure.)
//
static pte_t*
boot_pgdir_walk(pde_t *pgdir, uintptr_t la, int create)
{
	pte_t *pte=(pte_t*)pgdir[PDX(la)];
f0100a5f:	89 d8                	mov    %ebx,%eax
f0100a61:	c1 e8 16             	shr    $0x16,%eax
f0100a64:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100a67:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0100a6a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100a6d:	8b 00                	mov    (%eax),%eax

	if (pte == 0 ) {
f0100a6f:	85 c0                	test   %eax,%eax
f0100a71:	75 47                	jne    f0100aba <boot_map_segment+0x90>
		if (create == 0 ) return 0;
		pte=(pte_t*)boot_alloc(PGSIZE,PGSIZE);
f0100a73:	ba 00 10 00 00       	mov    $0x1000,%edx
f0100a78:	66 b8 00 10          	mov    $0x1000,%ax
f0100a7c:	e8 4f fe ff ff       	call   f01008d0 <boot_alloc>

		pgdir[PDX(la)]=PADDR(pte) | PTE_P | PTE_W;
f0100a81:	89 c2                	mov    %eax,%edx
f0100a83:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100a88:	77 20                	ja     f0100aaa <boot_map_segment+0x80>
f0100a8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a8e:	c7 44 24 08 68 37 10 	movl   $0xf0103768,0x8(%esp)
f0100a95:	f0 
f0100a96:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
f0100a9d:	00 
f0100a9e:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100aa5:	e8 d6 f5 ff ff       	call   f0100080 <_panic>
f0100aaa:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100ab0:	83 ca 03             	or     $0x3,%edx
f0100ab3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ab6:	89 11                	mov    %edx,(%ecx)
f0100ab8:	eb 37                	jmp    f0100af1 <boot_map_segment+0xc7>
	}
	else 
		pte=(pte_t *)KADDR(PTE_ADDR(pte));
f0100aba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100abf:	89 c2                	mov    %eax,%edx
f0100ac1:	c1 ea 0c             	shr    $0xc,%edx
f0100ac4:	3b 15 e0 49 11 f0    	cmp    0xf01149e0,%edx
f0100aca:	72 20                	jb     f0100aec <boot_map_segment+0xc2>
f0100acc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ad0:	c7 44 24 08 44 37 10 	movl   $0xf0103744,0x8(%esp)
f0100ad7:	f0 
f0100ad8:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
f0100adf:	00 
f0100ae0:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100ae7:	e8 94 f5 ff ff       	call   f0100080 <_panic>
f0100aec:	2d 00 00 00 10       	sub    $0x10000000,%eax
{
	int i;

	for ( i = 0; i < size/PGSIZE; i ++ ) {
		pte_t *pte=boot_pgdir_walk(pgdir,la+i*PGSIZE,1);
		pgdir[PDX(la)]=(pgdir[PDX(la)] & 0xFFFFF000) | perm | PTE_P;
f0100af1:	8b 16                	mov    (%esi),%edx
f0100af3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100af9:	0b 55 e4             	or     -0x1c(%ebp),%edx
f0100afc:	89 16                	mov    %edx,(%esi)
		pte[PTX(la+i*PGSIZE)]=(pa+i*PGSIZE) | perm | PTE_P;
f0100afe:	89 da                	mov    %ebx,%edx
f0100b00:	c1 ea 0c             	shr    $0xc,%edx
f0100b03:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b09:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100b0c:	0b 4d 08             	or     0x8(%ebp),%ecx
f0100b0f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
	int i;

	for ( i = 0; i < size/PGSIZE; i ++ ) {
f0100b12:	83 c7 01             	add    $0x1,%edi
f0100b15:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b1b:	81 45 08 00 10 00 00 	addl   $0x1000,0x8(%ebp)
f0100b22:	3b 7d dc             	cmp    -0x24(%ebp),%edi
f0100b25:	0f 82 34 ff ff ff    	jb     f0100a5f <boot_map_segment+0x35>
		pte_t *pte=boot_pgdir_walk(pgdir,la+i*PGSIZE,1);
		pgdir[PDX(la)]=(pgdir[PDX(la)] & 0xFFFFF000) | perm | PTE_P;
		pte[PTX(la+i*PGSIZE)]=(pa+i*PGSIZE) | perm | PTE_P;
	}
}
f0100b2b:	83 c4 2c             	add    $0x2c,%esp
f0100b2e:	5b                   	pop    %ebx
f0100b2f:	5e                   	pop    %esi
f0100b30:	5f                   	pop    %edi
f0100b31:	5d                   	pop    %ebp
f0100b32:	c3                   	ret    

f0100b33 <page_alloc>:
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented 
int
page_alloc(struct Page **pp_store)
{
f0100b33:	55                   	push   %ebp
f0100b34:	89 e5                	mov    %esp,%ebp
f0100b36:	53                   	push   %ebx
f0100b37:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct Page *p=LIST_FIRST (&page_free_list);
f0100b3a:	8b 1d b8 45 11 f0    	mov    0xf01145b8,%ebx
	if(p!=NULL){
f0100b40:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100b45:	85 db                	test   %ebx,%ebx
f0100b47:	74 35                	je     f0100b7e <page_alloc+0x4b>
		LIST_REMOVE(p,pp_link);
f0100b49:	8b 03                	mov    (%ebx),%eax
f0100b4b:	85 c0                	test   %eax,%eax
f0100b4d:	74 06                	je     f0100b55 <page_alloc+0x22>
f0100b4f:	8b 53 04             	mov    0x4(%ebx),%edx
f0100b52:	89 50 04             	mov    %edx,0x4(%eax)
f0100b55:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b58:	8b 13                	mov    (%ebx),%edx
f0100b5a:	89 10                	mov    %edx,(%eax)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f0100b5c:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0100b63:	00 
f0100b64:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b6b:	00 
f0100b6c:	89 1c 24             	mov    %ebx,(%esp)
f0100b6f:	e8 d2 22 00 00       	call   f0102e46 <memset>
	// Fill this function in
	struct Page *p=LIST_FIRST (&page_free_list);
	if(p!=NULL){
		LIST_REMOVE(p,pp_link);
		page_initpp(p);
		*pp_store = p;
f0100b74:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b77:	89 18                	mov    %ebx,(%eax)
f0100b79:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	return -E_NO_MEM;
}
f0100b7e:	83 c4 14             	add    $0x14,%esp
f0100b81:	5b                   	pop    %ebx
f0100b82:	5d                   	pop    %ebp
f0100b83:	c3                   	ret    

f0100b84 <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100b84:	55                   	push   %ebp
f0100b85:	89 e5                	mov    %esp,%ebp
f0100b87:	83 ec 28             	sub    $0x28,%esp
f0100b8a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100b8d:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
	pde_t *pt = pgdir + PDX(va);
f0100b90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100b93:	89 de                	mov    %ebx,%esi
f0100b95:	c1 ee 16             	shr    $0x16,%esi
f0100b98:	c1 e6 02             	shl    $0x2,%esi
f0100b9b:	03 75 08             	add    0x8(%ebp),%esi
	void *pt_kva;

	if (*pt & PTE_P) 
f0100b9e:	8b 06                	mov    (%esi),%eax
f0100ba0:	a8 01                	test   $0x1,%al
f0100ba2:	74 47                	je     f0100beb <pgdir_walk+0x67>
	{
		 pt_kva = (void*) KADDR (PTE_ADDR (*pt));
f0100ba4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ba9:	89 c2                	mov    %eax,%edx
f0100bab:	c1 ea 0c             	shr    $0xc,%edx
f0100bae:	3b 15 e0 49 11 f0    	cmp    0xf01149e0,%edx
f0100bb4:	72 20                	jb     f0100bd6 <pgdir_walk+0x52>
f0100bb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bba:	c7 44 24 08 44 37 10 	movl   $0xf0103744,0x8(%esp)
f0100bc1:	f0 
f0100bc2:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
f0100bc9:	00 
f0100bca:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100bd1:	e8 aa f4 ff ff       	call   f0100080 <_panic>
		 return (pte_t*) pt_kva + PTX (va);
f0100bd6:	c1 eb 0a             	shr    $0xa,%ebx
f0100bd9:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100bdf:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100be6:	e9 ca 00 00 00       	jmp    f0100cb5 <pgdir_walk+0x131>
	}
        struct Page *newpt;

	if (create == 1 && page_alloc (&newpt) == 0) {
f0100beb:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0100bef:	0f 85 bb 00 00 00    	jne    f0100cb0 <pgdir_walk+0x12c>
f0100bf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100bf8:	89 04 24             	mov    %eax,(%esp)
f0100bfb:	e8 33 ff ff ff       	call   f0100b33 <page_alloc>
f0100c00:	85 c0                	test   %eax,%eax
f0100c02:	0f 85 a8 00 00 00    	jne    f0100cb0 <pgdir_walk+0x12c>

	         memset (page2kva (newpt), 0, PGSIZE);
f0100c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c0b:	e8 ce fd ff ff       	call   f01009de <page2kva>
f0100c10:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100c17:	00 
f0100c18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c1f:	00 
f0100c20:	89 04 24             	mov    %eax,(%esp)
f0100c23:	e8 1e 22 00 00       	call   f0102e46 <memset>
	         newpt -> pp_ref = 1;
f0100c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c2b:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
		 *pt = PADDR (page2kva (newpt))|PTE_U|PTE_W|PTE_P;
f0100c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c34:	e8 a5 fd ff ff       	call   f01009de <page2kva>
f0100c39:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100c3e:	77 20                	ja     f0100c60 <pgdir_walk+0xdc>
f0100c40:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c44:	c7 44 24 08 68 37 10 	movl   $0xf0103768,0x8(%esp)
f0100c4b:	f0 
f0100c4c:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
f0100c53:	00 
f0100c54:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100c5b:	e8 20 f4 ff ff       	call   f0100080 <_panic>
f0100c60:	05 00 00 00 10       	add    $0x10000000,%eax
f0100c65:	83 c8 07             	or     $0x7,%eax
f0100c68:	89 06                	mov    %eax,(%esi)
		 pt_kva = (void*) KADDR (PTE_ADDR (*pt));	
f0100c6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c6f:	89 c2                	mov    %eax,%edx
f0100c71:	c1 ea 0c             	shr    $0xc,%edx
f0100c74:	3b 15 e0 49 11 f0    	cmp    0xf01149e0,%edx
f0100c7a:	72 20                	jb     f0100c9c <pgdir_walk+0x118>
f0100c7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c80:	c7 44 24 08 44 37 10 	movl   $0xf0103744,0x8(%esp)
f0100c87:	f0 
f0100c88:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
f0100c8f:	00 
f0100c90:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100c97:	e8 e4 f3 ff ff       	call   f0100080 <_panic>
		 return (pte_t*) pt_kva + PTX (va);	
f0100c9c:	89 da                	mov    %ebx,%edx
f0100c9e:	c1 ea 0a             	shr    $0xa,%edx
f0100ca1:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100ca7:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0100cae:	eb 05                	jmp    f0100cb5 <pgdir_walk+0x131>
f0100cb0:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return NULL;
}
f0100cb5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100cb8:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100cbb:	89 ec                	mov    %ebp,%esp
f0100cbd:	5d                   	pop    %ebp
f0100cbe:	c3                   	ret    

f0100cbf <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100cbf:	55                   	push   %ebp
f0100cc0:	89 e5                	mov    %esp,%ebp
f0100cc2:	53                   	push   %ebx
f0100cc3:	83 ec 14             	sub    $0x14,%esp
f0100cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk (pgdir, va, 0);
f0100cc9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100cd0:	00 
f0100cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cd8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cdb:	89 04 24             	mov    %eax,(%esp)
f0100cde:	e8 a1 fe ff ff       	call   f0100b84 <pgdir_walk>

	if (pte_store != 0) {
f0100ce3:	85 db                	test   %ebx,%ebx
f0100ce5:	74 02                	je     f0100ce9 <page_lookup+0x2a>
		 *pte_store = pte;
f0100ce7:	89 03                	mov    %eax,(%ebx)
	}
	if (pte != NULL && (*pte & PTE_P)) {
f0100ce9:	85 c0                	test   %eax,%eax
f0100ceb:	74 3b                	je     f0100d28 <page_lookup+0x69>
f0100ced:	8b 00                	mov    (%eax),%eax
f0100cef:	a8 01                	test   $0x1,%al
f0100cf1:	74 35                	je     f0100d28 <page_lookup+0x69>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100cf3:	c1 e8 0c             	shr    $0xc,%eax
f0100cf6:	3b 05 e0 49 11 f0    	cmp    0xf01149e0,%eax
f0100cfc:	72 1c                	jb     f0100d1a <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0100cfe:	c7 44 24 08 8c 37 10 	movl   $0xf010378c,0x8(%esp)
f0100d05:	f0 
f0100d06:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0100d0d:	00 
f0100d0e:	c7 04 24 69 3b 10 f0 	movl   $0xf0103b69,(%esp)
f0100d15:	e8 66 f3 ff ff       	call   f0100080 <_panic>
	return &pages[PPN(pa)];
f0100d1a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100d1d:	c1 e0 02             	shl    $0x2,%eax
f0100d20:	03 05 ec 49 11 f0    	add    0xf01149ec,%eax
		  return pa2page (PTE_ADDR (*pte));
f0100d26:	eb 05                	jmp    f0100d2d <page_lookup+0x6e>
f0100d28:	b8 00 00 00 00       	mov    $0x0,%eax
        }
	return NULL;
}
f0100d2d:	83 c4 14             	add    $0x14,%esp
f0100d30:	5b                   	pop    %ebx
f0100d31:	5d                   	pop    %ebp
f0100d32:	c3                   	ret    

f0100d33 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100d33:	55                   	push   %ebp
f0100d34:	89 e5                	mov    %esp,%ebp
f0100d36:	83 ec 28             	sub    $0x28,%esp
f0100d39:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100d3c:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100d3f:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
		pte_t *pte;
	struct Page *physpage = page_lookup (pgdir, va, &pte);
f0100d45:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100d48:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d50:	89 34 24             	mov    %esi,(%esp)
f0100d53:	e8 67 ff ff ff       	call   f0100cbf <page_lookup>

 	if (physpage != NULL) {
f0100d58:	85 c0                	test   %eax,%eax
f0100d5a:	74 1d                	je     f0100d79 <page_remove+0x46>
	  	page_decref (physpage);
f0100d5c:	89 04 24             	mov    %eax,(%esp)
f0100d5f:	e8 e6 fb ff ff       	call   f010094a <page_decref>
	   	*pte = 0;
f0100d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	    	tlb_invalidate (pgdir, va);
f0100d6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d71:	89 34 24             	mov    %esi,(%esp)
f0100d74:	e8 f4 fb ff ff       	call   f010096d <tlb_invalidate>
	}
}
f0100d79:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100d7c:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100d7f:	89 ec                	mov    %ebp,%esp
f0100d81:	5d                   	pop    %ebp
f0100d82:	c3                   	ret    

f0100d83 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0100d83:	55                   	push   %ebp
f0100d84:	89 e5                	mov    %esp,%ebp
f0100d86:	83 ec 28             	sub    $0x28,%esp
f0100d89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100d8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100d8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100d92:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d95:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte;

	pte = pgdir_walk(pgdir, va, 1);
f0100d98:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100d9f:	00 
f0100da0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100da4:	89 34 24             	mov    %esi,(%esp)
f0100da7:	e8 d8 fd ff ff       	call   f0100b84 <pgdir_walk>
f0100dac:	89 c3                	mov    %eax,%ebx
	if (pte == NULL) {
f0100dae:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100db3:	85 db                	test   %ebx,%ebx
f0100db5:	74 54                	je     f0100e0b <page_insert+0x88>
		return -E_NO_MEM;
	}

	// Increase first to avoid the page is removed to the free list
	pp->pp_ref ++;
f0100db7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dba:	66 83 40 08 01       	addw   $0x1,0x8(%eax)

	if (((*pte) & PTE_P) != 0) {
f0100dbf:	f6 03 01             	testb  $0x1,(%ebx)
f0100dc2:	74 0c                	je     f0100dd0 <page_insert+0x4d>
		page_remove(pgdir, va);
f0100dc4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100dc8:	89 34 24             	mov    %esi,(%esp)
f0100dcb:	e8 63 ff ff ff       	call   f0100d33 <page_remove>
	}

	*pte = page2pa(pp) | perm | PTE_P;
f0100dd0:	8b 55 14             	mov    0x14(%ebp),%edx
f0100dd3:	83 ca 01             	or     $0x1,%edx
f0100dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dd9:	2b 05 ec 49 11 f0    	sub    0xf01149ec,%eax
f0100ddf:	c1 f8 02             	sar    $0x2,%eax
f0100de2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100de8:	c1 e0 0c             	shl    $0xc,%eax
f0100deb:	09 d0                	or     %edx,%eax
f0100ded:	89 03                	mov    %eax,(%ebx)
	pgdir[PDX(va)] |= perm;
f0100def:	89 f8                	mov    %edi,%eax
f0100df1:	c1 e8 16             	shr    $0x16,%eax
f0100df4:	8b 55 14             	mov    0x14(%ebp),%edx
f0100df7:	09 14 86             	or     %edx,(%esi,%eax,4)
	tlb_invalidate(pgdir, va);
f0100dfa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100dfe:	89 34 24             	mov    %esi,(%esp)
f0100e01:	e8 67 fb ff ff       	call   f010096d <tlb_invalidate>
f0100e06:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0100e0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100e0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100e11:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100e14:	89 ec                	mov    %ebp,%esp
f0100e16:	5d                   	pop    %ebp
f0100e17:	c3                   	ret    

f0100e18 <page_check>:
	invlpg(va);
}

void
page_check(void)
{
f0100e18:	55                   	push   %ebp
f0100e19:	89 e5                	mov    %esp,%ebp
f0100e1b:	53                   	push   %ebx
f0100e1c:	83 ec 34             	sub    $0x34,%esp
	struct Page *pp, *pp0, *pp1, *pp2;
	struct Page_list fl;
	pte_t *ptep;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0100e1f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0100e26:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0100e2d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	assert(page_alloc(&pp0) == 0);
f0100e34:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0100e37:	89 04 24             	mov    %eax,(%esp)
f0100e3a:	e8 f4 fc ff ff       	call   f0100b33 <page_alloc>
f0100e3f:	85 c0                	test   %eax,%eax
f0100e41:	74 24                	je     f0100e67 <page_check+0x4f>
f0100e43:	c7 44 24 0c 77 3b 10 	movl   $0xf0103b77,0xc(%esp)
f0100e4a:	f0 
f0100e4b:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0100e52:	f0 
f0100e53:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
f0100e5a:	00 
f0100e5b:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100e62:	e8 19 f2 ff ff       	call   f0100080 <_panic>
	assert(page_alloc(&pp1) == 0);
f0100e67:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100e6a:	89 04 24             	mov    %eax,(%esp)
f0100e6d:	e8 c1 fc ff ff       	call   f0100b33 <page_alloc>
f0100e72:	85 c0                	test   %eax,%eax
f0100e74:	74 24                	je     f0100e9a <page_check+0x82>
f0100e76:	c7 44 24 0c a2 3b 10 	movl   $0xf0103ba2,0xc(%esp)
f0100e7d:	f0 
f0100e7e:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0100e85:	f0 
f0100e86:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0100e8d:	00 
f0100e8e:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100e95:	e8 e6 f1 ff ff       	call   f0100080 <_panic>
	assert(page_alloc(&pp2) == 0);
f0100e9a:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0100e9d:	89 04 24             	mov    %eax,(%esp)
f0100ea0:	e8 8e fc ff ff       	call   f0100b33 <page_alloc>
f0100ea5:	85 c0                	test   %eax,%eax
f0100ea7:	74 24                	je     f0100ecd <page_check+0xb5>
f0100ea9:	c7 44 24 0c b8 3b 10 	movl   $0xf0103bb8,0xc(%esp)
f0100eb0:	f0 
f0100eb1:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0100eb8:	f0 
f0100eb9:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0100ec0:	00 
f0100ec1:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100ec8:	e8 b3 f1 ff ff       	call   f0100080 <_panic>

	assert(pp0);
f0100ecd:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100ed0:	85 d2                	test   %edx,%edx
f0100ed2:	75 24                	jne    f0100ef8 <page_check+0xe0>
f0100ed4:	c7 44 24 0c dc 3b 10 	movl   $0xf0103bdc,0xc(%esp)
f0100edb:	f0 
f0100edc:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0100ee3:	f0 
f0100ee4:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0100eeb:	00 
f0100eec:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100ef3:	e8 88 f1 ff ff       	call   f0100080 <_panic>
	assert(pp1 && pp1 != pp0);
f0100ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100efb:	85 c0                	test   %eax,%eax
f0100efd:	74 04                	je     f0100f03 <page_check+0xeb>
f0100eff:	39 c2                	cmp    %eax,%edx
f0100f01:	75 24                	jne    f0100f27 <page_check+0x10f>
f0100f03:	c7 44 24 0c ce 3b 10 	movl   $0xf0103bce,0xc(%esp)
f0100f0a:	f0 
f0100f0b:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0100f12:	f0 
f0100f13:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0100f1a:	00 
f0100f1b:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100f22:	e8 59 f1 ff ff       	call   f0100080 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0100f27:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100f2a:	85 c9                	test   %ecx,%ecx
f0100f2c:	74 08                	je     f0100f36 <page_check+0x11e>
f0100f2e:	39 c8                	cmp    %ecx,%eax
f0100f30:	74 04                	je     f0100f36 <page_check+0x11e>
f0100f32:	39 ca                	cmp    %ecx,%edx
f0100f34:	75 24                	jne    f0100f5a <page_check+0x142>
f0100f36:	c7 44 24 0c ac 37 10 	movl   $0xf01037ac,0xc(%esp)
f0100f3d:	f0 
f0100f3e:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0100f45:	f0 
f0100f46:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0100f4d:	00 
f0100f4e:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100f55:	e8 26 f1 ff ff       	call   f0100080 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0100f5a:	8b 1d b8 45 11 f0    	mov    0xf01145b8,%ebx
	LIST_INIT(&page_free_list);
f0100f60:	c7 05 b8 45 11 f0 00 	movl   $0x0,0xf01145b8
f0100f67:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0100f6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f6d:	89 04 24             	mov    %eax,(%esp)
f0100f70:	e8 be fb ff ff       	call   f0100b33 <page_alloc>
f0100f75:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0100f78:	74 24                	je     f0100f9e <page_check+0x186>
f0100f7a:	c7 44 24 0c e0 3b 10 	movl   $0xf0103be0,0xc(%esp)
f0100f81:	f0 
f0100f82:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0100f89:	f0 
f0100f8a:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0100f91:	00 
f0100f92:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100f99:	e8 e2 f0 ff ff       	call   f0100080 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f0100f9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100fa1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fa5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fac:	00 
f0100fad:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0100fb2:	89 04 24             	mov    %eax,(%esp)
f0100fb5:	e8 05 fd ff ff       	call   f0100cbf <page_lookup>
f0100fba:	85 c0                	test   %eax,%eax
f0100fbc:	74 24                	je     f0100fe2 <page_check+0x1ca>
f0100fbe:	c7 44 24 0c cc 37 10 	movl   $0xf01037cc,0xc(%esp)
f0100fc5:	f0 
f0100fc6:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0100fcd:	f0 
f0100fce:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f0100fd5:	00 
f0100fd6:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0100fdd:	e8 9e f0 ff ff       	call   f0100080 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0100fe2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100fe9:	00 
f0100fea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ff1:	00 
f0100ff2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ff9:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0100ffe:	89 04 24             	mov    %eax,(%esp)
f0101001:	e8 7d fd ff ff       	call   f0100d83 <page_insert>
f0101006:	85 c0                	test   %eax,%eax
f0101008:	78 24                	js     f010102e <page_check+0x216>
f010100a:	c7 44 24 0c 04 38 10 	movl   $0xf0103804,0xc(%esp)
f0101011:	f0 
f0101012:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101019:	f0 
f010101a:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f0101021:	00 
f0101022:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101029:	e8 52 f0 ff ff       	call   f0100080 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010102e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101031:	89 04 24             	mov    %eax,(%esp)
f0101034:	e8 e8 f8 ff ff       	call   f0100921 <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f0101039:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101040:	00 
f0101041:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101048:	00 
f0101049:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010104c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101050:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101055:	89 04 24             	mov    %eax,(%esp)
f0101058:	e8 26 fd ff ff       	call   f0100d83 <page_insert>
f010105d:	85 c0                	test   %eax,%eax
f010105f:	74 24                	je     f0101085 <page_check+0x26d>
f0101061:	c7 44 24 0c 30 38 10 	movl   $0xf0103830,0xc(%esp)
f0101068:	f0 
f0101069:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101070:	f0 
f0101071:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f0101078:	00 
f0101079:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101080:	e8 fb ef ff ff       	call   f0100080 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0101085:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f010108a:	8b 08                	mov    (%eax),%ecx
f010108c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101092:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101095:	2b 15 ec 49 11 f0    	sub    0xf01149ec,%edx
f010109b:	c1 fa 02             	sar    $0x2,%edx
f010109e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01010a4:	c1 e2 0c             	shl    $0xc,%edx
f01010a7:	39 d1                	cmp    %edx,%ecx
f01010a9:	74 24                	je     f01010cf <page_check+0x2b7>
f01010ab:	c7 44 24 0c 5c 38 10 	movl   $0xf010385c,0xc(%esp)
f01010b2:	f0 
f01010b3:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01010ba:	f0 
f01010bb:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f01010c2:	00 
f01010c3:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01010ca:	e8 b1 ef ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f01010cf:	ba 00 00 00 00       	mov    $0x0,%edx
f01010d4:	e8 9f f8 ff ff       	call   f0100978 <check_va2pa>
f01010d9:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01010dc:	89 d1                	mov    %edx,%ecx
f01010de:	2b 0d ec 49 11 f0    	sub    0xf01149ec,%ecx
f01010e4:	c1 f9 02             	sar    $0x2,%ecx
f01010e7:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f01010ed:	c1 e1 0c             	shl    $0xc,%ecx
f01010f0:	39 c8                	cmp    %ecx,%eax
f01010f2:	74 24                	je     f0101118 <page_check+0x300>
f01010f4:	c7 44 24 0c 84 38 10 	movl   $0xf0103884,0xc(%esp)
f01010fb:	f0 
f01010fc:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101103:	f0 
f0101104:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f010110b:	00 
f010110c:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101113:	e8 68 ef ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 1);
f0101118:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f010111d:	74 24                	je     f0101143 <page_check+0x32b>
f010111f:	c7 44 24 0c fd 3b 10 	movl   $0xf0103bfd,0xc(%esp)
f0101126:	f0 
f0101127:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f010112e:	f0 
f010112f:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f0101136:	00 
f0101137:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f010113e:	e8 3d ef ff ff       	call   f0100080 <_panic>
	assert(pp0->pp_ref == 1);
f0101143:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101146:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f010114b:	74 24                	je     f0101171 <page_check+0x359>
f010114d:	c7 44 24 0c 0e 3c 10 	movl   $0xf0103c0e,0xc(%esp)
f0101154:	f0 
f0101155:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f010115c:	f0 
f010115d:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f0101164:	00 
f0101165:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f010116c:	e8 0f ef ff ff       	call   f0100080 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101171:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101178:	00 
f0101179:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101180:	00 
f0101181:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101184:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101188:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f010118d:	89 04 24             	mov    %eax,(%esp)
f0101190:	e8 ee fb ff ff       	call   f0100d83 <page_insert>
f0101195:	85 c0                	test   %eax,%eax
f0101197:	74 24                	je     f01011bd <page_check+0x3a5>
f0101199:	c7 44 24 0c b4 38 10 	movl   $0xf01038b4,0xc(%esp)
f01011a0:	f0 
f01011a1:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01011a8:	f0 
f01011a9:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
f01011b0:	00 
f01011b1:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01011b8:	e8 c3 ee ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01011bd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01011c2:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f01011c7:	e8 ac f7 ff ff       	call   f0100978 <check_va2pa>
f01011cc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01011cf:	89 d1                	mov    %edx,%ecx
f01011d1:	2b 0d ec 49 11 f0    	sub    0xf01149ec,%ecx
f01011d7:	c1 f9 02             	sar    $0x2,%ecx
f01011da:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f01011e0:	c1 e1 0c             	shl    $0xc,%ecx
f01011e3:	39 c8                	cmp    %ecx,%eax
f01011e5:	74 24                	je     f010120b <page_check+0x3f3>
f01011e7:	c7 44 24 0c ec 38 10 	movl   $0xf01038ec,0xc(%esp)
f01011ee:	f0 
f01011ef:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01011f6:	f0 
f01011f7:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f01011fe:	00 
f01011ff:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101206:	e8 75 ee ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f010120b:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101210:	74 24                	je     f0101236 <page_check+0x41e>
f0101212:	c7 44 24 0c 1f 3c 10 	movl   $0xf0103c1f,0xc(%esp)
f0101219:	f0 
f010121a:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101221:	f0 
f0101222:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
f0101229:	00 
f010122a:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101231:	e8 4a ee ff ff       	call   f0100080 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101236:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101239:	89 04 24             	mov    %eax,(%esp)
f010123c:	e8 f2 f8 ff ff       	call   f0100b33 <page_alloc>
f0101241:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101244:	74 24                	je     f010126a <page_check+0x452>
f0101246:	c7 44 24 0c e0 3b 10 	movl   $0xf0103be0,0xc(%esp)
f010124d:	f0 
f010124e:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101255:	f0 
f0101256:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
f010125d:	00 
f010125e:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101265:	e8 16 ee ff ff       	call   f0100080 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f010126a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101271:	00 
f0101272:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101279:	00 
f010127a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010127d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101281:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101286:	89 04 24             	mov    %eax,(%esp)
f0101289:	e8 f5 fa ff ff       	call   f0100d83 <page_insert>
f010128e:	85 c0                	test   %eax,%eax
f0101290:	74 24                	je     f01012b6 <page_check+0x49e>
f0101292:	c7 44 24 0c b4 38 10 	movl   $0xf01038b4,0xc(%esp)
f0101299:	f0 
f010129a:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01012a1:	f0 
f01012a2:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f01012a9:	00 
f01012aa:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01012b1:	e8 ca ed ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01012b6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01012bb:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f01012c0:	e8 b3 f6 ff ff       	call   f0100978 <check_va2pa>
f01012c5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01012c8:	89 d1                	mov    %edx,%ecx
f01012ca:	2b 0d ec 49 11 f0    	sub    0xf01149ec,%ecx
f01012d0:	c1 f9 02             	sar    $0x2,%ecx
f01012d3:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f01012d9:	c1 e1 0c             	shl    $0xc,%ecx
f01012dc:	39 c8                	cmp    %ecx,%eax
f01012de:	74 24                	je     f0101304 <page_check+0x4ec>
f01012e0:	c7 44 24 0c ec 38 10 	movl   $0xf01038ec,0xc(%esp)
f01012e7:	f0 
f01012e8:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01012ef:	f0 
f01012f0:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f01012f7:	00 
f01012f8:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01012ff:	e8 7c ed ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f0101304:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101309:	74 24                	je     f010132f <page_check+0x517>
f010130b:	c7 44 24 0c 1f 3c 10 	movl   $0xf0103c1f,0xc(%esp)
f0101312:	f0 
f0101313:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f010131a:	f0 
f010131b:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f0101322:	00 
f0101323:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f010132a:	e8 51 ed ff ff       	call   f0100080 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f010132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101332:	89 04 24             	mov    %eax,(%esp)
f0101335:	e8 f9 f7 ff ff       	call   f0100b33 <page_alloc>
f010133a:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010133d:	74 24                	je     f0101363 <page_check+0x54b>
f010133f:	c7 44 24 0c e0 3b 10 	movl   $0xf0103be0,0xc(%esp)
f0101346:	f0 
f0101347:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f010134e:	f0 
f010134f:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f0101356:	00 
f0101357:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f010135e:	e8 1d ed ff ff       	call   f0100080 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101363:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010136a:	00 
f010136b:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101372:	00 
f0101373:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101376:	89 44 24 04          	mov    %eax,0x4(%esp)
f010137a:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f010137f:	89 04 24             	mov    %eax,(%esp)
f0101382:	e8 fc f9 ff ff       	call   f0100d83 <page_insert>
f0101387:	85 c0                	test   %eax,%eax
f0101389:	78 24                	js     f01013af <page_check+0x597>
f010138b:	c7 44 24 0c 1c 39 10 	movl   $0xf010391c,0xc(%esp)
f0101392:	f0 
f0101393:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f010139a:	f0 
f010139b:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f01013a2:	00 
f01013a3:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01013aa:	e8 d1 ec ff ff       	call   f0100080 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01013af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01013b6:	00 
f01013b7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013be:	00 
f01013bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013c6:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f01013cb:	89 04 24             	mov    %eax,(%esp)
f01013ce:	e8 b0 f9 ff ff       	call   f0100d83 <page_insert>
f01013d3:	85 c0                	test   %eax,%eax
f01013d5:	74 24                	je     f01013fb <page_check+0x5e3>
f01013d7:	c7 44 24 0c 50 39 10 	movl   $0xf0103950,0xc(%esp)
f01013de:	f0 
f01013df:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01013e6:	f0 
f01013e7:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f01013ee:	00 
f01013ef:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01013f6:	e8 85 ec ff ff       	call   f0100080 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f01013fb:	ba 00 00 00 00       	mov    $0x0,%edx
f0101400:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101405:	e8 6e f5 ff ff       	call   f0100978 <check_va2pa>
f010140a:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010140d:	2b 15 ec 49 11 f0    	sub    0xf01149ec,%edx
f0101413:	c1 fa 02             	sar    $0x2,%edx
f0101416:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010141c:	c1 e2 0c             	shl    $0xc,%edx
f010141f:	39 d0                	cmp    %edx,%eax
f0101421:	74 24                	je     f0101447 <page_check+0x62f>
f0101423:	c7 44 24 0c 88 39 10 	movl   $0xf0103988,0xc(%esp)
f010142a:	f0 
f010142b:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101432:	f0 
f0101433:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f010143a:	00 
f010143b:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101442:	e8 39 ec ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101447:	ba 00 10 00 00       	mov    $0x1000,%edx
f010144c:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101451:	e8 22 f5 ff ff       	call   f0100978 <check_va2pa>
f0101456:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101459:	89 d1                	mov    %edx,%ecx
f010145b:	2b 0d ec 49 11 f0    	sub    0xf01149ec,%ecx
f0101461:	c1 f9 02             	sar    $0x2,%ecx
f0101464:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f010146a:	c1 e1 0c             	shl    $0xc,%ecx
f010146d:	39 c8                	cmp    %ecx,%eax
f010146f:	74 24                	je     f0101495 <page_check+0x67d>
f0101471:	c7 44 24 0c b4 39 10 	movl   $0xf01039b4,0xc(%esp)
f0101478:	f0 
f0101479:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101480:	f0 
f0101481:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
f0101488:	00 
f0101489:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101490:	e8 eb eb ff ff       	call   f0100080 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101495:	66 83 7a 08 02       	cmpw   $0x2,0x8(%edx)
f010149a:	74 24                	je     f01014c0 <page_check+0x6a8>
f010149c:	c7 44 24 0c 30 3c 10 	movl   $0xf0103c30,0xc(%esp)
f01014a3:	f0 
f01014a4:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01014ab:	f0 
f01014ac:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f01014b3:	00 
f01014b4:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01014bb:	e8 c0 eb ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f01014c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01014c3:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01014c8:	74 24                	je     f01014ee <page_check+0x6d6>
f01014ca:	c7 44 24 0c 41 3c 10 	movl   $0xf0103c41,0xc(%esp)
f01014d1:	f0 
f01014d2:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01014d9:	f0 
f01014da:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f01014e1:	00 
f01014e2:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01014e9:	e8 92 eb ff ff       	call   f0100080 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f01014ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01014f1:	89 04 24             	mov    %eax,(%esp)
f01014f4:	e8 3a f6 ff ff       	call   f0100b33 <page_alloc>
f01014f9:	85 c0                	test   %eax,%eax
f01014fb:	75 08                	jne    f0101505 <page_check+0x6ed>
f01014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101500:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101503:	74 24                	je     f0101529 <page_check+0x711>
f0101505:	c7 44 24 0c e4 39 10 	movl   $0xf01039e4,0xc(%esp)
f010150c:	f0 
f010150d:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101514:	f0 
f0101515:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f010151c:	00 
f010151d:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101524:	e8 57 eb ff ff       	call   f0100080 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0101529:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101530:	00 
f0101531:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101536:	89 04 24             	mov    %eax,(%esp)
f0101539:	e8 f5 f7 ff ff       	call   f0100d33 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f010153e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101543:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101548:	e8 2b f4 ff ff       	call   f0100978 <check_va2pa>
f010154d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101550:	74 24                	je     f0101576 <page_check+0x75e>
f0101552:	c7 44 24 0c 08 3a 10 	movl   $0xf0103a08,0xc(%esp)
f0101559:	f0 
f010155a:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101561:	f0 
f0101562:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101569:	00 
f010156a:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101571:	e8 0a eb ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101576:	ba 00 10 00 00       	mov    $0x1000,%edx
f010157b:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101580:	e8 f3 f3 ff ff       	call   f0100978 <check_va2pa>
f0101585:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101588:	89 d1                	mov    %edx,%ecx
f010158a:	2b 0d ec 49 11 f0    	sub    0xf01149ec,%ecx
f0101590:	c1 f9 02             	sar    $0x2,%ecx
f0101593:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0101599:	c1 e1 0c             	shl    $0xc,%ecx
f010159c:	39 c8                	cmp    %ecx,%eax
f010159e:	74 24                	je     f01015c4 <page_check+0x7ac>
f01015a0:	c7 44 24 0c b4 39 10 	movl   $0xf01039b4,0xc(%esp)
f01015a7:	f0 
f01015a8:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01015af:	f0 
f01015b0:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f01015b7:	00 
f01015b8:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01015bf:	e8 bc ea ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 1);
f01015c4:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f01015c9:	74 24                	je     f01015ef <page_check+0x7d7>
f01015cb:	c7 44 24 0c fd 3b 10 	movl   $0xf0103bfd,0xc(%esp)
f01015d2:	f0 
f01015d3:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01015da:	f0 
f01015db:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f01015e2:	00 
f01015e3:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01015ea:	e8 91 ea ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f01015ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01015f2:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01015f7:	74 24                	je     f010161d <page_check+0x805>
f01015f9:	c7 44 24 0c 41 3c 10 	movl   $0xf0103c41,0xc(%esp)
f0101600:	f0 
f0101601:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101608:	f0 
f0101609:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f0101610:	00 
f0101611:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101618:	e8 63 ea ff ff       	call   f0100080 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f010161d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101624:	00 
f0101625:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f010162a:	89 04 24             	mov    %eax,(%esp)
f010162d:	e8 01 f7 ff ff       	call   f0100d33 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101632:	ba 00 00 00 00       	mov    $0x0,%edx
f0101637:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f010163c:	e8 37 f3 ff ff       	call   f0100978 <check_va2pa>
f0101641:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101644:	74 24                	je     f010166a <page_check+0x852>
f0101646:	c7 44 24 0c 08 3a 10 	movl   $0xf0103a08,0xc(%esp)
f010164d:	f0 
f010164e:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101655:	f0 
f0101656:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f010165d:	00 
f010165e:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101665:	e8 16 ea ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f010166a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010166f:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101674:	e8 ff f2 ff ff       	call   f0100978 <check_va2pa>
f0101679:	83 f8 ff             	cmp    $0xffffffff,%eax
f010167c:	74 24                	je     f01016a2 <page_check+0x88a>
f010167e:	c7 44 24 0c 2c 3a 10 	movl   $0xf0103a2c,0xc(%esp)
f0101685:	f0 
f0101686:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f010168d:	f0 
f010168e:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f0101695:	00 
f0101696:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f010169d:	e8 de e9 ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 0);
f01016a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01016a5:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01016aa:	74 24                	je     f01016d0 <page_check+0x8b8>
f01016ac:	c7 44 24 0c 52 3c 10 	movl   $0xf0103c52,0xc(%esp)
f01016b3:	f0 
f01016b4:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01016bb:	f0 
f01016bc:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f01016c3:	00 
f01016c4:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01016cb:	e8 b0 e9 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f01016d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01016d3:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01016d8:	74 24                	je     f01016fe <page_check+0x8e6>
f01016da:	c7 44 24 0c 41 3c 10 	movl   $0xf0103c41,0xc(%esp)
f01016e1:	f0 
f01016e2:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01016e9:	f0 
f01016ea:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f01016f1:	00 
f01016f2:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01016f9:	e8 82 e9 ff ff       	call   f0100080 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f01016fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101701:	89 04 24             	mov    %eax,(%esp)
f0101704:	e8 2a f4 ff ff       	call   f0100b33 <page_alloc>
f0101709:	85 c0                	test   %eax,%eax
f010170b:	75 08                	jne    f0101715 <page_check+0x8fd>
f010170d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101710:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0101713:	74 24                	je     f0101739 <page_check+0x921>
f0101715:	c7 44 24 0c 54 3a 10 	movl   $0xf0103a54,0xc(%esp)
f010171c:	f0 
f010171d:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101724:	f0 
f0101725:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f010172c:	00 
f010172d:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101734:	e8 47 e9 ff ff       	call   f0100080 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101739:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010173c:	89 04 24             	mov    %eax,(%esp)
f010173f:	e8 ef f3 ff ff       	call   f0100b33 <page_alloc>
f0101744:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101747:	74 24                	je     f010176d <page_check+0x955>
f0101749:	c7 44 24 0c e0 3b 10 	movl   $0xf0103be0,0xc(%esp)
f0101750:	f0 
f0101751:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101758:	f0 
f0101759:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0101760:	00 
f0101761:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101768:	e8 13 e9 ff ff       	call   f0100080 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f010176d:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f0101772:	8b 08                	mov    (%eax),%ecx
f0101774:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010177a:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010177d:	2b 15 ec 49 11 f0    	sub    0xf01149ec,%edx
f0101783:	c1 fa 02             	sar    $0x2,%edx
f0101786:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010178c:	c1 e2 0c             	shl    $0xc,%edx
f010178f:	39 d1                	cmp    %edx,%ecx
f0101791:	74 24                	je     f01017b7 <page_check+0x99f>
f0101793:	c7 44 24 0c 5c 38 10 	movl   $0xf010385c,0xc(%esp)
f010179a:	f0 
f010179b:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01017a2:	f0 
f01017a3:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f01017aa:	00 
f01017ab:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01017b2:	e8 c9 e8 ff ff       	call   f0100080 <_panic>
	boot_pgdir[0] = 0;
f01017b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01017bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017c0:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f01017c5:	74 24                	je     f01017eb <page_check+0x9d3>
f01017c7:	c7 44 24 0c 0e 3c 10 	movl   $0xf0103c0e,0xc(%esp)
f01017ce:	f0 
f01017cf:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f01017d6:	f0 
f01017d7:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f01017de:	00 
f01017df:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01017e6:	e8 95 e8 ff ff       	call   f0100080 <_panic>
	pp0->pp_ref = 0;
f01017eb:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f01017f1:	89 1d b8 45 11 f0    	mov    %ebx,0xf01145b8

	// free the pages we took
	page_free(pp0);
f01017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017fa:	89 04 24             	mov    %eax,(%esp)
f01017fd:	e8 1f f1 ff ff       	call   f0100921 <page_free>
	page_free(pp1);
f0101802:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101805:	89 04 24             	mov    %eax,(%esp)
f0101808:	e8 14 f1 ff ff       	call   f0100921 <page_free>
	page_free(pp2);
f010180d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101810:	89 04 24             	mov    %eax,(%esp)
f0101813:	e8 09 f1 ff ff       	call   f0100921 <page_free>

	cprintf("page_check() succeeded!\n");
f0101818:	c7 04 24 63 3c 10 f0 	movl   $0xf0103c63,(%esp)
f010181f:	e8 d7 09 00 00       	call   f01021fb <cprintf>
}
f0101824:	83 c4 34             	add    $0x34,%esp
f0101827:	5b                   	pop    %ebx
f0101828:	5d                   	pop    %ebp
f0101829:	c3                   	ret    

f010182a <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f010182a:	55                   	push   %ebp
f010182b:	89 e5                	mov    %esp,%ebp
f010182d:	83 ec 38             	sub    $0x38,%esp
f0101830:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101833:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101836:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// Remove this line when you're ready to test this function.
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f0101839:	ba 00 10 00 00       	mov    $0x1000,%edx
f010183e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101843:	e8 88 f0 ff ff       	call   f01008d0 <boot_alloc>
f0101848:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f010184a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101851:	00 
f0101852:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101859:	00 
f010185a:	89 04 24             	mov    %eax,(%esp)
f010185d:	e8 e4 15 00 00       	call   f0102e46 <memset>
	boot_pgdir = pgdir;
f0101862:	89 1d e8 49 11 f0    	mov    %ebx,0xf01149e8
	boot_cr3 = PADDR(pgdir);
f0101868:	89 d8                	mov    %ebx,%eax
f010186a:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101870:	77 20                	ja     f0101892 <i386_vm_init+0x68>
f0101872:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101876:	c7 44 24 08 68 37 10 	movl   $0xf0103768,0x8(%esp)
f010187d:	f0 
f010187e:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f0101885:	00 
f0101886:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f010188d:	e8 ee e7 ff ff       	call   f0100080 <_panic>
f0101892:	05 00 00 00 10       	add    $0x10000000,%eax
f0101897:	a3 e4 49 11 f0       	mov    %eax,0xf01149e4
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f010189c:	89 c2                	mov    %eax,%edx
f010189e:	83 ca 03             	or     $0x3,%edx
f01018a1:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f01018a7:	83 c8 05             	or     $0x5,%eax
f01018aa:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// pieces:
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed => faults
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_segment(pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f01018b0:	be 00 c0 10 f0       	mov    $0xf010c000,%esi
f01018b5:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01018bb:	77 20                	ja     f01018dd <i386_vm_init+0xb3>
f01018bd:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01018c1:	c7 44 24 08 68 37 10 	movl   $0xf0103768,0x8(%esp)
f01018c8:	f0 
f01018c9:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f01018d0:	00 
f01018d1:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01018d8:	e8 a3 e7 ff ff       	call   f0100080 <_panic>
f01018dd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01018e4:	00 
f01018e5:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01018eb:	89 04 24             	mov    %eax,(%esp)
f01018ee:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01018f3:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01018f8:	89 d8                	mov    %ebx,%eax
f01018fa:	e8 2b f1 ff ff       	call   f0100a2a <boot_map_segment>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
        boot_map_segment(pgdir,KERNBASE,0xFFFFFFFF - KERNBASE + 1, 0, PTE_W);
f01018ff:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0101906:	00 
f0101907:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010190e:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101913:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101918:	89 d8                	mov    %ebx,%eax
f010191a:	e8 0b f1 ff ff       	call   f0100a2a <boot_map_segment>
	// (ie. perm = PTE_U | PTE_P)
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here: 
	size_t spages = ROUNDUP(npage * sizeof(struct Page),PGSIZE);
f010191f:	6b 3d e0 49 11 f0 0c 	imul   $0xc,0xf01149e0,%edi
f0101926:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f010192c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	pages = (struct Page*)boot_alloc(spages,PGSIZE);
f0101932:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101937:	89 f8                	mov    %edi,%eax
f0101939:	e8 92 ef ff ff       	call   f01008d0 <boot_alloc>
f010193e:	a3 ec 49 11 f0       	mov    %eax,0xf01149ec
	physaddr_t ppages = PADDR(pages);
f0101943:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101948:	77 20                	ja     f010196a <i386_vm_init+0x140>
f010194a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010194e:	c7 44 24 08 68 37 10 	movl   $0xf0103768,0x8(%esp)
f0101955:	f0 
f0101956:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
f010195d:	00 
f010195e:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101965:	e8 16 e7 ff ff       	call   f0100080 <_panic>
	boot_map_segment(pgdir, UPAGES, spages, ppages, PTE_U);
f010196a:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0101971:	00 
f0101972:	05 00 00 00 10       	add    $0x10000000,%eax
f0101977:	89 04 24             	mov    %eax,(%esp)
f010197a:	89 f9                	mov    %edi,%ecx
f010197c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101981:	89 d8                	mov    %ebx,%eax
f0101983:	e8 a2 f0 ff ff       	call   f0100a2a <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f0101988:	a1 e8 49 11 f0       	mov    0xf01149e8,%eax
f010198d:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f0101990:	6b 05 e0 49 11 f0 0c 	imul   $0xc,0xf01149e0,%eax
f0101997:	05 ff 0f 00 00       	add    $0xfff,%eax
	for (i = 0; i < n; i += PGSIZE)
f010199c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01019a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01019a4:	0f 84 83 00 00 00    	je     f0101a2d <i386_vm_init+0x203>
f01019aa:	bf 00 00 00 00       	mov    $0x0,%edi
f01019af:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01019b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01019b5:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f01019bb:	89 d8                	mov    %ebx,%eax
f01019bd:	e8 b6 ef ff ff       	call   f0100978 <check_va2pa>
f01019c2:	8b 15 ec 49 11 f0    	mov    0xf01149ec,%edx
f01019c8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01019ce:	77 20                	ja     f01019f0 <i386_vm_init+0x1c6>
f01019d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01019d4:	c7 44 24 08 68 37 10 	movl   $0xf0103768,0x8(%esp)
f01019db:	f0 
f01019dc:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f01019e3:	00 
f01019e4:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f01019eb:	e8 90 e6 ff ff       	call   f0100080 <_panic>
f01019f0:	8d 94 17 00 00 00 10 	lea    0x10000000(%edi,%edx,1),%edx
f01019f7:	39 d0                	cmp    %edx,%eax
f01019f9:	74 24                	je     f0101a1f <i386_vm_init+0x1f5>
f01019fb:	c7 44 24 0c 78 3a 10 	movl   $0xf0103a78,0xc(%esp)
f0101a02:	f0 
f0101a03:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101a0a:	f0 
f0101a0b:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f0101a12:	00 
f0101a13:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101a1a:	e8 61 e6 ff ff       	call   f0100080 <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101a1f:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101a25:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
f0101a28:	77 8b                	ja     f01019b5 <i386_vm_init+0x18b>
f0101a2a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101a2d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101a32:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101a35:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	

	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101a38:	8d 97 00 00 00 f0    	lea    -0x10000000(%edi),%edx
f0101a3e:	89 d8                	mov    %ebx,%eax
f0101a40:	e8 33 ef ff ff       	call   f0100978 <check_va2pa>
f0101a45:	39 c7                	cmp    %eax,%edi
f0101a47:	74 24                	je     f0101a6d <i386_vm_init+0x243>
f0101a49:	c7 44 24 0c ac 3a 10 	movl   $0xf0103aac,0xc(%esp)
f0101a50:	f0 
f0101a51:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101a58:	f0 
f0101a59:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f0101a60:	00 
f0101a61:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101a68:	e8 13 e6 ff ff       	call   f0100080 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	

	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
f0101a6d:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101a73:	81 ff 00 00 00 10    	cmp    $0x10000000,%edi
f0101a79:	75 bd                	jne    f0101a38 <i386_vm_init+0x20e>
f0101a7b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101a7e:	bf 00 80 bf ef       	mov    $0xefbf8000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0101a83:	81 c6 00 80 40 20    	add    $0x20408000,%esi
f0101a89:	89 fa                	mov    %edi,%edx
f0101a8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101a8e:	e8 e5 ee ff ff       	call   f0100978 <check_va2pa>
f0101a93:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f0101a96:	39 d0                	cmp    %edx,%eax
f0101a98:	74 24                	je     f0101abe <i386_vm_init+0x294>
f0101a9a:	c7 44 24 0c d4 3a 10 	movl   $0xf0103ad4,0xc(%esp)
f0101aa1:	f0 
f0101aa2:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101aa9:	f0 
f0101aaa:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
f0101ab1:	00 
f0101ab2:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101ab9:	e8 c2 e5 ff ff       	call   f0100080 <_panic>
f0101abe:	81 c7 00 10 00 00    	add    $0x1000,%edi
	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101ac4:	81 ff 00 00 c0 ef    	cmp    $0xefc00000,%edi
f0101aca:	75 bd                	jne    f0101a89 <i386_vm_init+0x25f>
f0101acc:	b8 00 00 00 00       	mov    $0x0,%eax
f0101ad1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0101ad4:	8d 90 44 fc ff ff    	lea    -0x3bc(%eax),%edx
f0101ada:	83 fa 03             	cmp    $0x3,%edx
f0101add:	77 2a                	ja     f0101b09 <i386_vm_init+0x2df>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i]);
f0101adf:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101ae3:	75 7f                	jne    f0101b64 <i386_vm_init+0x33a>
f0101ae5:	c7 44 24 0c 7c 3c 10 	movl   $0xf0103c7c,0xc(%esp)
f0101aec:	f0 
f0101aed:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101af4:	f0 
f0101af5:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
f0101afc:	00 
f0101afd:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101b04:	e8 77 e5 ff ff       	call   f0100080 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f0101b09:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0101b0e:	76 2a                	jbe    f0101b3a <i386_vm_init+0x310>
				assert(pgdir[i]);
f0101b10:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101b14:	75 4e                	jne    f0101b64 <i386_vm_init+0x33a>
f0101b16:	c7 44 24 0c 7c 3c 10 	movl   $0xf0103c7c,0xc(%esp)
f0101b1d:	f0 
f0101b1e:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101b25:	f0 
f0101b26:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f0101b2d:	00 
f0101b2e:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101b35:	e8 46 e5 ff ff       	call   f0100080 <_panic>
			else
				assert(pgdir[i] == 0);
f0101b3a:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101b3e:	74 24                	je     f0101b64 <i386_vm_init+0x33a>
f0101b40:	c7 44 24 0c 85 3c 10 	movl   $0xf0103c85,0xc(%esp)
f0101b47:	f0 
f0101b48:	c7 44 24 08 8d 3b 10 	movl   $0xf0103b8d,0x8(%esp)
f0101b4f:	f0 
f0101b50:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f0101b57:	00 
f0101b58:	c7 04 24 5d 3b 10 f0 	movl   $0xf0103b5d,(%esp)
f0101b5f:	e8 1c e5 ff ff       	call   f0100080 <_panic>
	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f0101b64:	83 c0 01             	add    $0x1,%eax
f0101b67:	3d 00 04 00 00       	cmp    $0x400,%eax
f0101b6c:	0f 85 62 ff ff ff    	jne    f0101ad4 <i386_vm_init+0x2aa>
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f0101b72:	c7 04 24 1c 3b 10 f0 	movl   $0xf0103b1c,(%esp)
f0101b79:	e8 7d 06 00 00       	call   f01021fb <cprintf>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f0101b7e:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f0101b84:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101b86:	a1 e4 49 11 f0       	mov    0xf01149e4,%eax
f0101b8b:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0101b8e:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f0101b91:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0101b96:	83 e0 f3             	and    $0xfffffff3,%eax
f0101b99:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0101b9c:	0f 01 15 50 43 11 f0 	lgdtl  0xf0114350
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0101ba3:	b8 23 00 00 00       	mov    $0x23,%eax
f0101ba8:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0101baa:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0101bac:	b0 10                	mov    $0x10,%al
f0101bae:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0101bb0:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0101bb2:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f0101bb4:	ea bb 1b 10 f0 08 00 	ljmp   $0x8,$0xf0101bbb
	asm volatile("lldt %%ax" :: "a" (0));
f0101bbb:	b0 00                	mov    $0x0,%al
f0101bbd:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f0101bc0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101bc6:	a1 e4 49 11 f0       	mov    0xf01149e4,%eax
f0101bcb:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}
f0101bce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101bd1:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101bd4:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101bd7:	89 ec                	mov    %ebp,%esp
f0101bd9:	5d                   	pop    %ebp
f0101bda:	c3                   	ret    

f0101bdb <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0101bdb:	55                   	push   %ebp
f0101bdc:	89 e5                	mov    %esp,%ebp
f0101bde:	83 ec 18             	sub    $0x18,%esp
f0101be1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101be4:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101be7:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101be9:	89 04 24             	mov    %eax,(%esp)
f0101bec:	e8 af 05 00 00       	call   f01021a0 <mc146818_read>
f0101bf1:	89 c6                	mov    %eax,%esi
f0101bf3:	83 c3 01             	add    $0x1,%ebx
f0101bf6:	89 1c 24             	mov    %ebx,(%esp)
f0101bf9:	e8 a2 05 00 00       	call   f01021a0 <mc146818_read>
f0101bfe:	c1 e0 08             	shl    $0x8,%eax
f0101c01:	09 f0                	or     %esi,%eax
}
f0101c03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101c06:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101c09:	89 ec                	mov    %ebp,%esp
f0101c0b:	5d                   	pop    %ebp
f0101c0c:	c3                   	ret    

f0101c0d <i386_detect_memory>:

void
i386_detect_memory(void)
{
f0101c0d:	55                   	push   %ebp
f0101c0e:	89 e5                	mov    %esp,%ebp
f0101c10:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0101c13:	b8 15 00 00 00       	mov    $0x15,%eax
f0101c18:	e8 be ff ff ff       	call   f0101bdb <nvram_read>
f0101c1d:	c1 e0 0a             	shl    $0xa,%eax
f0101c20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101c25:	a3 ac 45 11 f0       	mov    %eax,0xf01145ac
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0101c2a:	b8 17 00 00 00       	mov    $0x17,%eax
f0101c2f:	e8 a7 ff ff ff       	call   f0101bdb <nvram_read>
f0101c34:	c1 e0 0a             	shl    $0xa,%eax
f0101c37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101c3c:	a3 b0 45 11 f0       	mov    %eax,0xf01145b0

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0101c41:	85 c0                	test   %eax,%eax
f0101c43:	74 0c                	je     f0101c51 <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0101c45:	05 00 00 10 00       	add    $0x100000,%eax
f0101c4a:	a3 a8 45 11 f0       	mov    %eax,0xf01145a8
f0101c4f:	eb 0a                	jmp    f0101c5b <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0101c51:	a1 ac 45 11 f0       	mov    0xf01145ac,%eax
f0101c56:	a3 a8 45 11 f0       	mov    %eax,0xf01145a8

	npage = maxpa / PGSIZE;
f0101c5b:	a1 a8 45 11 f0       	mov    0xf01145a8,%eax
f0101c60:	89 c2                	mov    %eax,%edx
f0101c62:	c1 ea 0c             	shr    $0xc,%edx
f0101c65:	89 15 e0 49 11 f0    	mov    %edx,0xf01149e0

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0101c6b:	c1 e8 0a             	shr    $0xa,%eax
f0101c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c72:	c7 04 24 3c 3b 10 f0 	movl   $0xf0103b3c,(%esp)
f0101c79:	e8 7d 05 00 00       	call   f01021fb <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0101c7e:	a1 b0 45 11 f0       	mov    0xf01145b0,%eax
f0101c83:	c1 e8 0a             	shr    $0xa,%eax
f0101c86:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c8a:	a1 ac 45 11 f0       	mov    0xf01145ac,%eax
f0101c8f:	c1 e8 0a             	shr    $0xa,%eax
f0101c92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c96:	c7 04 24 93 3c 10 f0 	movl   $0xf0103c93,(%esp)
f0101c9d:	e8 59 05 00 00       	call   f01021fb <cprintf>
}
f0101ca2:	c9                   	leave  
f0101ca3:	c3                   	ret    

f0101ca4 <page_init>:
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc() or the related boot-time functions above.
//
void
page_init(void)
{
f0101ca4:	55                   	push   %ebp
f0101ca5:	89 e5                	mov    %esp,%ebp
f0101ca7:	56                   	push   %esi
f0101ca8:	53                   	push   %ebx
f0101ca9:	83 ec 10             	sub    $0x10,%esp
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f0101cac:	c7 05 b8 45 11 f0 00 	movl   $0x0,0xf01145b8
f0101cb3:	00 00 00 

	for (i = 0; i < npage; i ++ ) {
f0101cb6:	83 3d e0 49 11 f0 00 	cmpl   $0x0,0xf01149e0
f0101cbd:	74 66                	je     f0101d25 <page_init+0x81>
f0101cbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0101cc4:	ba 00 00 00 00       	mov    $0x0,%edx
		pages[i].pp_ref=0;
f0101cc9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101ccc:	c1 e0 02             	shl    $0x2,%eax
f0101ccf:	8b 0d ec 49 11 f0    	mov    0xf01149ec,%ecx
f0101cd5:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
		LIST_INSERT_HEAD(&page_free_list,&pages[i],pp_link);
f0101cdc:	8b 0d b8 45 11 f0    	mov    0xf01145b8,%ecx
f0101ce2:	8b 1d ec 49 11 f0    	mov    0xf01149ec,%ebx
f0101ce8:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
f0101ceb:	85 c9                	test   %ecx,%ecx
f0101ced:	74 11                	je     f0101d00 <page_init+0x5c>
f0101cef:	89 c3                	mov    %eax,%ebx
f0101cf1:	03 1d ec 49 11 f0    	add    0xf01149ec,%ebx
f0101cf7:	8b 0d b8 45 11 f0    	mov    0xf01145b8,%ecx
f0101cfd:	89 59 04             	mov    %ebx,0x4(%ecx)
f0101d00:	03 05 ec 49 11 f0    	add    0xf01149ec,%eax
f0101d06:	a3 b8 45 11 f0       	mov    %eax,0xf01145b8
f0101d0b:	c7 40 04 b8 45 11 f0 	movl   $0xf01145b8,0x4(%eax)
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);

	for (i = 0; i < npage; i ++ ) {
f0101d12:	83 c2 01             	add    $0x1,%edx
f0101d15:	89 d0                	mov    %edx,%eax
f0101d17:	8b 0d e0 49 11 f0    	mov    0xf01149e0,%ecx
f0101d1d:	39 d1                	cmp    %edx,%ecx
f0101d1f:	77 a8                	ja     f0101cc9 <page_init+0x25>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101d21:	85 c9                	test   %ecx,%ecx
f0101d23:	75 1c                	jne    f0101d41 <page_init+0x9d>
		panic("pa2page called with invalid pa");
f0101d25:	c7 44 24 08 8c 37 10 	movl   $0xf010378c,0x8(%esp)
f0101d2c:	f0 
f0101d2d:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0101d34:	00 
f0101d35:	c7 04 24 69 3b 10 f0 	movl   $0xf0103b69,(%esp)
f0101d3c:	e8 3f e3 ff ff       	call   f0100080 <_panic>
	return &pages[PPN(pa)];
f0101d41:	a1 ec 49 11 f0       	mov    0xf01149ec,%eax
		pages[i].pp_ref=0;
		LIST_INSERT_HEAD(&page_free_list,&pages[i],pp_link);
	}
	struct Page *pp;
	pp=pa2page(0);
	LIST_REMOVE(pp,pp_link);
f0101d46:	8b 10                	mov    (%eax),%edx
f0101d48:	85 d2                	test   %edx,%edx
f0101d4a:	74 06                	je     f0101d52 <page_init+0xae>
f0101d4c:	8b 48 04             	mov    0x4(%eax),%ecx
f0101d4f:	89 4a 04             	mov    %ecx,0x4(%edx)
f0101d52:	8b 50 04             	mov    0x4(%eax),%edx
f0101d55:	8b 08                	mov    (%eax),%ecx
f0101d57:	89 0a                	mov    %ecx,(%edx)
	pp->pp_ref++;
f0101d59:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	physaddr_t pa;

	for (pa = IOPHYSMEM; pa < (physaddr_t)(boot_freemem-KERNBASE); pa += PGSIZE) {
f0101d5e:	8b 1d b4 45 11 f0    	mov    0xf01145b4,%ebx
f0101d64:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0101d6a:	81 fb 00 00 0a 00    	cmp    $0xa0000,%ebx
f0101d70:	76 6f                	jbe    f0101de1 <page_init+0x13d>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101d72:	81 3d e0 49 11 f0 a0 	cmpl   $0xa0,0xf01149e0
f0101d79:	00 00 00 
f0101d7c:	77 2b                	ja     f0101da9 <page_init+0x105>
f0101d7e:	eb 0d                	jmp    f0101d8d <page_init+0xe9>
f0101d80:	89 d0                	mov    %edx,%eax
f0101d82:	c1 e8 0c             	shr    $0xc,%eax
f0101d85:	3b 05 e0 49 11 f0    	cmp    0xf01149e0,%eax
f0101d8b:	72 26                	jb     f0101db3 <page_init+0x10f>
		panic("pa2page called with invalid pa");
f0101d8d:	c7 44 24 08 8c 37 10 	movl   $0xf010378c,0x8(%esp)
f0101d94:	f0 
f0101d95:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0101d9c:	00 
f0101d9d:	c7 04 24 69 3b 10 f0 	movl   $0xf0103b69,(%esp)
f0101da4:	e8 d7 e2 ff ff       	call   f0100080 <_panic>
f0101da9:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0101dae:	ba 00 00 0a 00       	mov    $0xa0000,%edx
	return &pages[PPN(pa)];
f0101db3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101db6:	c1 e0 02             	shl    $0x2,%eax
f0101db9:	03 05 ec 49 11 f0    	add    0xf01149ec,%eax
		pp=pa2page(pa);
		LIST_REMOVE(pp,pp_link);
f0101dbf:	8b 08                	mov    (%eax),%ecx
f0101dc1:	85 c9                	test   %ecx,%ecx
f0101dc3:	74 06                	je     f0101dcb <page_init+0x127>
f0101dc5:	8b 70 04             	mov    0x4(%eax),%esi
f0101dc8:	89 71 04             	mov    %esi,0x4(%ecx)
f0101dcb:	8b 48 04             	mov    0x4(%eax),%ecx
f0101dce:	8b 30                	mov    (%eax),%esi
f0101dd0:	89 31                	mov    %esi,(%ecx)
		pp->pp_ref++;
f0101dd2:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
	pp=pa2page(0);
	LIST_REMOVE(pp,pp_link);
	pp->pp_ref++;
	physaddr_t pa;

	for (pa = IOPHYSMEM; pa < (physaddr_t)(boot_freemem-KERNBASE); pa += PGSIZE) {
f0101dd7:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0101ddd:	39 da                	cmp    %ebx,%edx
f0101ddf:	72 9f                	jb     f0101d80 <page_init+0xdc>
		pp=pa2page(pa);
		LIST_REMOVE(pp,pp_link);
		pp->pp_ref++;
	}
}
f0101de1:	83 c4 10             	add    $0x10,%esp
f0101de4:	5b                   	pop    %ebx
f0101de5:	5e                   	pop    %esi
f0101de6:	5d                   	pop    %ebp
f0101de7:	c3                   	ret    
	...

f0101df0 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0101df0:	55                   	push   %ebp
f0101df1:	89 e5                	mov    %esp,%ebp
f0101df3:	53                   	push   %ebx
f0101df4:	8b 45 08             	mov    0x8(%ebp),%eax
f0101df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0101dfa:	85 c0                	test   %eax,%eax
f0101dfc:	75 0e                	jne    f0101e0c <envid2env+0x1c>
		*env_store = curenv;
f0101dfe:	a1 c0 45 11 f0       	mov    0xf01145c0,%eax
f0101e03:	89 01                	mov    %eax,(%ecx)
f0101e05:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0101e0a:	eb 54                	jmp    f0101e60 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0101e0c:	89 c2                	mov    %eax,%edx
f0101e0e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101e14:	6b d2 64             	imul   $0x64,%edx,%edx
f0101e17:	03 15 bc 45 11 f0    	add    0xf01145bc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0101e1d:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0101e21:	74 05                	je     f0101e28 <envid2env+0x38>
f0101e23:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0101e26:	74 0d                	je     f0101e35 <envid2env+0x45>
		*env_store = 0;
f0101e28:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0101e2e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0101e33:	eb 2b                	jmp    f0101e60 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0101e35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101e39:	74 1e                	je     f0101e59 <envid2env+0x69>
f0101e3b:	a1 c0 45 11 f0       	mov    0xf01145c0,%eax
f0101e40:	39 c2                	cmp    %eax,%edx
f0101e42:	74 15                	je     f0101e59 <envid2env+0x69>
f0101e44:	8b 5a 50             	mov    0x50(%edx),%ebx
f0101e47:	3b 58 4c             	cmp    0x4c(%eax),%ebx
f0101e4a:	74 0d                	je     f0101e59 <envid2env+0x69>
		*env_store = 0;
f0101e4c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0101e52:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0101e57:	eb 07                	jmp    f0101e60 <envid2env+0x70>
	}

	*env_store = e;
f0101e59:	89 11                	mov    %edx,(%ecx)
f0101e5b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0101e60:	5b                   	pop    %ebx
f0101e61:	5d                   	pop    %ebp
f0101e62:	c3                   	ret    

f0101e63 <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f0101e63:	55                   	push   %ebp
f0101e64:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0101e66:	5d                   	pop    %ebp
f0101e67:	c3                   	ret    

f0101e68 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size)
{
f0101e68:	55                   	push   %ebp
f0101e69:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0101e6b:	5d                   	pop    %ebp
f0101e6c:	c3                   	ret    

f0101e6d <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0101e6d:	55                   	push   %ebp
f0101e6e:	89 e5                	mov    %esp,%ebp
f0101e70:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.

        panic("env_run not yet implemented");
f0101e73:	c7 44 24 08 af 3c 10 	movl   $0xf0103caf,0x8(%esp)
f0101e7a:	f0 
f0101e7b:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f0101e82:	00 
f0101e83:	c7 04 24 cb 3c 10 f0 	movl   $0xf0103ccb,(%esp)
f0101e8a:	e8 f1 e1 ff ff       	call   f0100080 <_panic>

f0101e8f <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0101e8f:	55                   	push   %ebp
f0101e90:	89 e5                	mov    %esp,%ebp
f0101e92:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0101e95:	8b 65 08             	mov    0x8(%ebp),%esp
f0101e98:	61                   	popa   
f0101e99:	07                   	pop    %es
f0101e9a:	1f                   	pop    %ds
f0101e9b:	83 c4 08             	add    $0x8,%esp
f0101e9e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0101e9f:	c7 44 24 08 d6 3c 10 	movl   $0xf0103cd6,0x8(%esp)
f0101ea6:	f0 
f0101ea7:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
f0101eae:	00 
f0101eaf:	c7 04 24 cb 3c 10 f0 	movl   $0xf0103ccb,(%esp)
f0101eb6:	e8 c5 e1 ff ff       	call   f0100080 <_panic>

f0101ebb <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0101ebb:	55                   	push   %ebp
f0101ebc:	89 e5                	mov    %esp,%ebp
f0101ebe:	57                   	push   %edi
f0101ebf:	56                   	push   %esi
f0101ec0:	53                   	push   %ebx
f0101ec1:	83 ec 2c             	sub    $0x2c,%esp
f0101ec4:	8b 7d 08             	mov    0x8(%ebp),%edi
	pte_t *pt;
	uint32_t pdeno, pteno;
	physaddr_t pa;

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0101ec7:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0101eca:	8b 15 c0 45 11 f0    	mov    0xf01145c0,%edx
f0101ed0:	b8 00 00 00 00       	mov    $0x0,%eax
f0101ed5:	85 d2                	test   %edx,%edx
f0101ed7:	74 03                	je     f0101edc <env_free+0x21>
f0101ed9:	8b 42 4c             	mov    0x4c(%edx),%eax
f0101edc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ee4:	c7 04 24 e2 3c 10 f0 	movl   $0xf0103ce2,(%esp)
f0101eeb:	e8 0b 03 00 00       	call   f01021fb <cprintf>
f0101ef0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101ef7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101efa:	c1 e0 02             	shl    $0x2,%eax
f0101efd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0101f00:	8b 47 5c             	mov    0x5c(%edi),%eax
f0101f03:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101f06:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0101f09:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0101f0f:	0f 84 bb 00 00 00    	je     f0101fd0 <env_free+0x115>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0101f15:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0101f1b:	89 f0                	mov    %esi,%eax
f0101f1d:	c1 e8 0c             	shr    $0xc,%eax
f0101f20:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101f23:	3b 05 e0 49 11 f0    	cmp    0xf01149e0,%eax
f0101f29:	72 20                	jb     f0101f4b <env_free+0x90>
f0101f2b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101f2f:	c7 44 24 08 44 37 10 	movl   $0xf0103744,0x8(%esp)
f0101f36:	f0 
f0101f37:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
f0101f3e:	00 
f0101f3f:	c7 04 24 cb 3c 10 f0 	movl   $0xf0103ccb,(%esp)
f0101f46:	e8 35 e1 ff ff       	call   f0100080 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0101f4b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101f4e:	c1 e2 16             	shl    $0x16,%edx
f0101f51:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101f54:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0101f59:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0101f60:	01 
f0101f61:	74 17                	je     f0101f7a <env_free+0xbf>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0101f63:	89 d8                	mov    %ebx,%eax
f0101f65:	c1 e0 0c             	shl    $0xc,%eax
f0101f68:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0101f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f6f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0101f72:	89 04 24             	mov    %eax,(%esp)
f0101f75:	e8 b9 ed ff ff       	call   f0100d33 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0101f7a:	83 c3 01             	add    $0x1,%ebx
f0101f7d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0101f83:	75 d4                	jne    f0101f59 <env_free+0x9e>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0101f85:	8b 47 5c             	mov    0x5c(%edi),%eax
f0101f88:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101f8b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101f92:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101f95:	3b 05 e0 49 11 f0    	cmp    0xf01149e0,%eax
f0101f9b:	72 1c                	jb     f0101fb9 <env_free+0xfe>
		panic("pa2page called with invalid pa");
f0101f9d:	c7 44 24 08 8c 37 10 	movl   $0xf010378c,0x8(%esp)
f0101fa4:	f0 
f0101fa5:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0101fac:	00 
f0101fad:	c7 04 24 69 3b 10 f0 	movl   $0xf0103b69,(%esp)
f0101fb4:	e8 c7 e0 ff ff       	call   f0100080 <_panic>
		page_decref(pa2page(pa));
f0101fb9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101fbc:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101fbf:	c1 e0 02             	shl    $0x2,%eax
f0101fc2:	03 05 ec 49 11 f0    	add    0xf01149ec,%eax
f0101fc8:	89 04 24             	mov    %eax,(%esp)
f0101fcb:	e8 7a e9 ff ff       	call   f010094a <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0101fd0:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0101fd4:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0101fdb:	0f 85 16 ff ff ff    	jne    f0101ef7 <env_free+0x3c>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0101fe1:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0101fe4:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0101feb:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101ff2:	c1 e8 0c             	shr    $0xc,%eax
f0101ff5:	3b 05 e0 49 11 f0    	cmp    0xf01149e0,%eax
f0101ffb:	72 1c                	jb     f0102019 <env_free+0x15e>
		panic("pa2page called with invalid pa");
f0101ffd:	c7 44 24 08 8c 37 10 	movl   $0xf010378c,0x8(%esp)
f0102004:	f0 
f0102005:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f010200c:	00 
f010200d:	c7 04 24 69 3b 10 f0 	movl   $0xf0103b69,(%esp)
f0102014:	e8 67 e0 ff ff       	call   f0100080 <_panic>
	page_decref(pa2page(pa));
f0102019:	6b c0 0c             	imul   $0xc,%eax,%eax
f010201c:	03 05 ec 49 11 f0    	add    0xf01149ec,%eax
f0102022:	89 04 24             	mov    %eax,(%esp)
f0102025:	e8 20 e9 ff ff       	call   f010094a <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010202a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0102031:	a1 c4 45 11 f0       	mov    0xf01145c4,%eax
f0102036:	89 47 44             	mov    %eax,0x44(%edi)
f0102039:	85 c0                	test   %eax,%eax
f010203b:	74 0b                	je     f0102048 <env_free+0x18d>
f010203d:	8d 57 44             	lea    0x44(%edi),%edx
f0102040:	a1 c4 45 11 f0       	mov    0xf01145c4,%eax
f0102045:	89 50 48             	mov    %edx,0x48(%eax)
f0102048:	89 3d c4 45 11 f0    	mov    %edi,0xf01145c4
f010204e:	c7 47 48 c4 45 11 f0 	movl   $0xf01145c4,0x48(%edi)
}
f0102055:	83 c4 2c             	add    $0x2c,%esp
f0102058:	5b                   	pop    %ebx
f0102059:	5e                   	pop    %esi
f010205a:	5f                   	pop    %edi
f010205b:	5d                   	pop    %ebp
f010205c:	c3                   	ret    

f010205d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f010205d:	55                   	push   %ebp
f010205e:	89 e5                	mov    %esp,%ebp
f0102060:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0102063:	8b 45 08             	mov    0x8(%ebp),%eax
f0102066:	89 04 24             	mov    %eax,(%esp)
f0102069:	e8 4d fe ff ff       	call   f0101ebb <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010206e:	c7 04 24 10 3d 10 f0 	movl   $0xf0103d10,(%esp)
f0102075:	e8 81 01 00 00       	call   f01021fb <cprintf>
	while (1)
		monitor(NULL);
f010207a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102081:	e8 f6 e6 ff ff       	call   f010077c <monitor>
f0102086:	eb f2                	jmp    f010207a <env_destroy+0x1d>

f0102088 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102088:	55                   	push   %ebp
f0102089:	89 e5                	mov    %esp,%ebp
f010208b:	53                   	push   %ebx
f010208c:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f010208f:	8b 1d c4 45 11 f0    	mov    0xf01145c4,%ebx
f0102095:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010209a:	85 db                	test   %ebx,%ebx
f010209c:	0f 84 f6 00 00 00    	je     f0102198 <env_alloc+0x110>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f01020a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f01020a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01020ac:	89 04 24             	mov    %eax,(%esp)
f01020af:	e8 7f ea ff ff       	call   f0100b33 <page_alloc>
f01020b4:	85 c0                	test   %eax,%eax
f01020b6:	0f 88 dc 00 00 00    	js     f0102198 <env_alloc+0x110>

	// LAB 3: Your code here.

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f01020bc:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01020bf:	8b 53 60             	mov    0x60(%ebx),%edx
f01020c2:	83 ca 03             	or     $0x3,%edx
f01020c5:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f01020cb:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01020ce:	8b 53 60             	mov    0x60(%ebx),%edx
f01020d1:	83 ca 05             	or     $0x5,%edx
f01020d4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01020da:	8b 43 4c             	mov    0x4c(%ebx),%eax
f01020dd:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01020e2:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01020e7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ec:	0f 4e c2             	cmovle %edx,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01020ef:	89 da                	mov    %ebx,%edx
f01020f1:	2b 15 bc 45 11 f0    	sub    0xf01145bc,%edx
f01020f7:	c1 fa 02             	sar    $0x2,%edx
f01020fa:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0102100:	09 d0                	or     %edx,%eax
f0102102:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102105:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102108:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010210b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102112:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102119:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102120:	00 
f0102121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102128:	00 
f0102129:	89 1c 24             	mov    %ebx,(%esp)
f010212c:	e8 15 0d 00 00       	call   f0102e46 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0102131:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102137:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010213d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102143:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010214a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0102150:	8b 43 44             	mov    0x44(%ebx),%eax
f0102153:	85 c0                	test   %eax,%eax
f0102155:	74 06                	je     f010215d <env_alloc+0xd5>
f0102157:	8b 53 48             	mov    0x48(%ebx),%edx
f010215a:	89 50 48             	mov    %edx,0x48(%eax)
f010215d:	8b 43 48             	mov    0x48(%ebx),%eax
f0102160:	8b 53 44             	mov    0x44(%ebx),%edx
f0102163:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f0102165:	8b 45 08             	mov    0x8(%ebp),%eax
f0102168:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010216a:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f010216d:	8b 15 c0 45 11 f0    	mov    0xf01145c0,%edx
f0102173:	b8 00 00 00 00       	mov    $0x0,%eax
f0102178:	85 d2                	test   %edx,%edx
f010217a:	74 03                	je     f010217f <env_alloc+0xf7>
f010217c:	8b 42 4c             	mov    0x4c(%edx),%eax
f010217f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102183:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102187:	c7 04 24 f8 3c 10 f0 	movl   $0xf0103cf8,(%esp)
f010218e:	e8 68 00 00 00       	call   f01021fb <cprintf>
f0102193:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0102198:	83 c4 24             	add    $0x24,%esp
f010219b:	5b                   	pop    %ebx
f010219c:	5d                   	pop    %ebp
f010219d:	c3                   	ret    
	...

f01021a0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01021a0:	55                   	push   %ebp
f01021a1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01021a3:	ba 70 00 00 00       	mov    $0x70,%edx
f01021a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01021ab:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01021ac:	b2 71                	mov    $0x71,%dl
f01021ae:	ec                   	in     (%dx),%al
f01021af:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01021b2:	5d                   	pop    %ebp
f01021b3:	c3                   	ret    

f01021b4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01021b4:	55                   	push   %ebp
f01021b5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01021b7:	ba 70 00 00 00       	mov    $0x70,%edx
f01021bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01021bf:	ee                   	out    %al,(%dx)
f01021c0:	b2 71                	mov    $0x71,%dl
f01021c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01021c5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01021c6:	5d                   	pop    %ebp
f01021c7:	c3                   	ret    

f01021c8 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01021c8:	55                   	push   %ebp
f01021c9:	89 e5                	mov    %esp,%ebp
f01021cb:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01021ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01021d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01021d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01021dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01021df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01021e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01021e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01021ea:	c7 04 24 15 22 10 f0 	movl   $0xf0102215,(%esp)
f01021f1:	e8 ea 04 00 00       	call   f01026e0 <vprintfmt>
	return cnt;
}
f01021f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01021f9:	c9                   	leave  
f01021fa:	c3                   	ret    

f01021fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01021fb:	55                   	push   %ebp
f01021fc:	89 e5                	mov    %esp,%ebp
f01021fe:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0102201:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102204:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102208:	8b 45 08             	mov    0x8(%ebp),%eax
f010220b:	89 04 24             	mov    %eax,(%esp)
f010220e:	e8 b5 ff ff ff       	call   f01021c8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102213:	c9                   	leave  
f0102214:	c3                   	ret    

f0102215 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102215:	55                   	push   %ebp
f0102216:	89 e5                	mov    %esp,%ebp
f0102218:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010221b:	8b 45 08             	mov    0x8(%ebp),%eax
f010221e:	89 04 24             	mov    %eax,(%esp)
f0102221:	e8 2a e4 ff ff       	call   f0100650 <cputchar>
	*cnt++;
}
f0102226:	c9                   	leave  
f0102227:	c3                   	ret    
	...

f0102230 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102230:	55                   	push   %ebp
f0102231:	89 e5                	mov    %esp,%ebp
f0102233:	57                   	push   %edi
f0102234:	56                   	push   %esi
f0102235:	53                   	push   %ebx
f0102236:	83 ec 14             	sub    $0x14,%esp
f0102239:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010223c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010223f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102242:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102245:	8b 1a                	mov    (%edx),%ebx
f0102247:	8b 01                	mov    (%ecx),%eax
f0102249:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010224c:	39 c3                	cmp    %eax,%ebx
f010224e:	0f 8f 9c 00 00 00    	jg     f01022f0 <stab_binsearch+0xc0>
f0102254:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f010225b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010225e:	01 d8                	add    %ebx,%eax
f0102260:	89 c7                	mov    %eax,%edi
f0102262:	c1 ef 1f             	shr    $0x1f,%edi
f0102265:	01 c7                	add    %eax,%edi
f0102267:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102269:	39 df                	cmp    %ebx,%edi
f010226b:	7c 33                	jl     f01022a0 <stab_binsearch+0x70>
f010226d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102270:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102273:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102278:	39 f0                	cmp    %esi,%eax
f010227a:	0f 84 bc 00 00 00    	je     f010233c <stab_binsearch+0x10c>
f0102280:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0102284:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0102288:	89 f8                	mov    %edi,%eax
			m--;
f010228a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010228d:	39 d8                	cmp    %ebx,%eax
f010228f:	7c 0f                	jl     f01022a0 <stab_binsearch+0x70>
f0102291:	0f b6 0a             	movzbl (%edx),%ecx
f0102294:	83 ea 0c             	sub    $0xc,%edx
f0102297:	39 f1                	cmp    %esi,%ecx
f0102299:	75 ef                	jne    f010228a <stab_binsearch+0x5a>
f010229b:	e9 9e 00 00 00       	jmp    f010233e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01022a0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01022a3:	eb 3c                	jmp    f01022e1 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01022a5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01022a8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f01022aa:	8d 5f 01             	lea    0x1(%edi),%ebx
f01022ad:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01022b4:	eb 2b                	jmp    f01022e1 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f01022b6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01022b9:	76 14                	jbe    f01022cf <stab_binsearch+0x9f>
			*region_right = m - 1;
f01022bb:	83 e8 01             	sub    $0x1,%eax
f01022be:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01022c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01022c4:	89 02                	mov    %eax,(%edx)
f01022c6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01022cd:	eb 12                	jmp    f01022e1 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01022cf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01022d2:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f01022d4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01022d8:	89 c3                	mov    %eax,%ebx
f01022da:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f01022e1:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01022e4:	0f 8d 71 ff ff ff    	jge    f010225b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01022ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01022ee:	75 0f                	jne    f01022ff <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01022f0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01022f3:	8b 03                	mov    (%ebx),%eax
f01022f5:	83 e8 01             	sub    $0x1,%eax
f01022f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01022fb:	89 02                	mov    %eax,(%edx)
f01022fd:	eb 57                	jmp    f0102356 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01022ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102302:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102304:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102307:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102309:	39 c1                	cmp    %eax,%ecx
f010230b:	7d 28                	jge    f0102335 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010230d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102310:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0102313:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0102318:	39 f2                	cmp    %esi,%edx
f010231a:	74 19                	je     f0102335 <stab_binsearch+0x105>
f010231c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0102320:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0102324:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102327:	39 c1                	cmp    %eax,%ecx
f0102329:	7d 0a                	jge    f0102335 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010232b:	0f b6 1a             	movzbl (%edx),%ebx
f010232e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102331:	39 f3                	cmp    %esi,%ebx
f0102333:	75 ef                	jne    f0102324 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0102335:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102338:	89 02                	mov    %eax,(%edx)
f010233a:	eb 1a                	jmp    f0102356 <stab_binsearch+0x126>
	}
}
f010233c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010233e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102341:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102344:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102348:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010234b:	0f 82 54 ff ff ff    	jb     f01022a5 <stab_binsearch+0x75>
f0102351:	e9 60 ff ff ff       	jmp    f01022b6 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102356:	83 c4 14             	add    $0x14,%esp
f0102359:	5b                   	pop    %ebx
f010235a:	5e                   	pop    %esi
f010235b:	5f                   	pop    %edi
f010235c:	5d                   	pop    %ebp
f010235d:	c3                   	ret    

f010235e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010235e:	55                   	push   %ebp
f010235f:	89 e5                	mov    %esp,%ebp
f0102361:	83 ec 48             	sub    $0x48,%esp
f0102364:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0102367:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010236a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010236d:	8b 75 08             	mov    0x8(%ebp),%esi
f0102370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102373:	c7 03 48 3d 10 f0    	movl   $0xf0103d48,(%ebx)
	info->eip_line = 0;
f0102379:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102380:	c7 43 08 48 3d 10 f0 	movl   $0xf0103d48,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102387:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010238e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102391:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102398:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010239e:	76 12                	jbe    f01023b2 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01023a0:	b8 06 bc 10 f0       	mov    $0xf010bc06,%eax
f01023a5:	3d 5d 95 10 f0       	cmp    $0xf010955d,%eax
f01023aa:	0f 86 aa 01 00 00    	jbe    f010255a <debuginfo_eip+0x1fc>
f01023b0:	eb 1c                	jmp    f01023ce <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01023b2:	c7 44 24 08 52 3d 10 	movl   $0xf0103d52,0x8(%esp)
f01023b9:	f0 
f01023ba:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
f01023c1:	00 
f01023c2:	c7 04 24 5f 3d 10 f0 	movl   $0xf0103d5f,(%esp)
f01023c9:	e8 b2 dc ff ff       	call   f0100080 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01023ce:	80 3d 05 bc 10 f0 00 	cmpb   $0x0,0xf010bc05
f01023d5:	0f 85 7f 01 00 00    	jne    f010255a <debuginfo_eip+0x1fc>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01023db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01023e2:	b8 5c 95 10 f0       	mov    $0xf010955c,%eax
f01023e7:	2d 7c 3f 10 f0       	sub    $0xf0103f7c,%eax
f01023ec:	c1 f8 02             	sar    $0x2,%eax
f01023ef:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01023f5:	83 e8 01             	sub    $0x1,%eax
f01023f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01023fb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01023fe:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102401:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102405:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010240c:	b8 7c 3f 10 f0       	mov    $0xf0103f7c,%eax
f0102411:	e8 1a fe ff ff       	call   f0102230 <stab_binsearch>
	if (lfile == 0)
f0102416:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102419:	85 c0                	test   %eax,%eax
f010241b:	0f 84 39 01 00 00    	je     f010255a <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102421:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102424:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102427:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010242a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010242d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102430:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102434:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010243b:	b8 7c 3f 10 f0       	mov    $0xf0103f7c,%eax
f0102440:	e8 eb fd ff ff       	call   f0102230 <stab_binsearch>

	if (lfun <= rfun) {
f0102445:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102448:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010244b:	7f 3c                	jg     f0102489 <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010244d:	6b c0 0c             	imul   $0xc,%eax,%eax
f0102450:	8b 80 7c 3f 10 f0    	mov    -0xfefc084(%eax),%eax
f0102456:	ba 06 bc 10 f0       	mov    $0xf010bc06,%edx
f010245b:	81 ea 5d 95 10 f0    	sub    $0xf010955d,%edx
f0102461:	39 d0                	cmp    %edx,%eax
f0102463:	73 08                	jae    f010246d <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102465:	05 5d 95 10 f0       	add    $0xf010955d,%eax
f010246a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010246d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102470:	6b d0 0c             	imul   $0xc,%eax,%edx
f0102473:	8b 92 84 3f 10 f0    	mov    -0xfefc07c(%edx),%edx
f0102479:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010247c:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010247e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102481:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102484:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102487:	eb 0f                	jmp    f0102498 <debuginfo_eip+0x13a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102489:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010248c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010248f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102492:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102495:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102498:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010249f:	00 
f01024a0:	8b 43 08             	mov    0x8(%ebx),%eax
f01024a3:	89 04 24             	mov    %eax,(%esp)
f01024a6:	e8 70 09 00 00       	call   f0102e1b <strfind>
f01024ab:	2b 43 08             	sub    0x8(%ebx),%eax
f01024ae:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	lline=lfun;
f01024b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01024b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	rline=rfun;
f01024b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01024ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f01024bd:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01024c0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01024c3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024c7:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01024ce:	b8 7c 3f 10 f0       	mov    $0xf0103f7c,%eax
f01024d3:	e8 58 fd ff ff       	call   f0102230 <stab_binsearch>
	if(lline<=rline)
f01024d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024db:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01024de:	7f 7a                	jg     f010255a <debuginfo_eip+0x1fc>
		info->eip_line=stabs[lline].n_desc;
f01024e0:	6b c0 0c             	imul   $0xc,%eax,%eax
f01024e3:	0f b7 80 82 3f 10 f0 	movzwl -0xfefc07e(%eax),%eax
f01024ea:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01024ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01024f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01024f3:	6b c2 0c             	imul   $0xc,%edx,%eax
f01024f6:	05 7c 3f 10 f0       	add    $0xf0103f7c,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01024fb:	eb 06                	jmp    f0102503 <debuginfo_eip+0x1a5>
f01024fd:	83 ea 01             	sub    $0x1,%edx
f0102500:	83 e8 0c             	sub    $0xc,%eax
f0102503:	39 d7                	cmp    %edx,%edi
f0102505:	7f 22                	jg     f0102529 <debuginfo_eip+0x1cb>
f0102507:	89 c6                	mov    %eax,%esi
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102509:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010250d:	80 f9 84             	cmp    $0x84,%cl
f0102510:	74 62                	je     f0102574 <debuginfo_eip+0x216>
f0102512:	80 f9 64             	cmp    $0x64,%cl
f0102515:	75 e6                	jne    f01024fd <debuginfo_eip+0x19f>
f0102517:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f010251b:	74 e0                	je     f01024fd <debuginfo_eip+0x19f>
f010251d:	8d 76 00             	lea    0x0(%esi),%esi
f0102520:	eb 52                	jmp    f0102574 <debuginfo_eip+0x216>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102522:	05 5d 95 10 f0       	add    $0xf010955d,%eax
f0102527:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	if(lfun<rfun)
f0102529:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010252c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010252f:	7d 31                	jge    f0102562 <debuginfo_eip+0x204>
		for(lline=lfun+1;lline<rfun&&stabs[lline].n_type==N_PSYM;lline++)
f0102531:	83 c0 01             	add    $0x1,%eax
f0102534:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102537:	ba 7c 3f 10 f0       	mov    $0xf0103f7c,%edx
f010253c:	eb 08                	jmp    f0102546 <debuginfo_eip+0x1e8>
		info->eip_fn_narg++;
f010253e:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	if(lfun<rfun)
		for(lline=lfun+1;lline<rfun&&stabs[lline].n_type==N_PSYM;lline++)
f0102542:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f0102546:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102549:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010254c:	7d 14                	jge    f0102562 <debuginfo_eip+0x204>
f010254e:	6b c0 0c             	imul   $0xc,%eax,%eax
f0102551:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f0102556:	74 e6                	je     f010253e <debuginfo_eip+0x1e0>
f0102558:	eb 08                	jmp    f0102562 <debuginfo_eip+0x204>
f010255a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010255f:	90                   	nop
f0102560:	eb 05                	jmp    f0102567 <debuginfo_eip+0x209>
f0102562:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_fn_narg++;
	return 0;
}
f0102567:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010256a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010256d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0102570:	89 ec                	mov    %ebp,%esp
f0102572:	5d                   	pop    %ebp
f0102573:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102574:	8b 06                	mov    (%esi),%eax
f0102576:	ba 06 bc 10 f0       	mov    $0xf010bc06,%edx
f010257b:	81 ea 5d 95 10 f0    	sub    $0xf010955d,%edx
f0102581:	39 d0                	cmp    %edx,%eax
f0102583:	72 9d                	jb     f0102522 <debuginfo_eip+0x1c4>
f0102585:	eb a2                	jmp    f0102529 <debuginfo_eip+0x1cb>
	...

f0102590 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102590:	55                   	push   %ebp
f0102591:	89 e5                	mov    %esp,%ebp
f0102593:	57                   	push   %edi
f0102594:	56                   	push   %esi
f0102595:	53                   	push   %ebx
f0102596:	83 ec 4c             	sub    $0x4c,%esp
f0102599:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010259c:	89 d6                	mov    %edx,%esi
f010259e:	8b 45 08             	mov    0x8(%ebp),%eax
f01025a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01025a4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01025a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01025aa:	8b 45 10             	mov    0x10(%ebp),%eax
f01025ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01025b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01025b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01025b6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01025bb:	39 d1                	cmp    %edx,%ecx
f01025bd:	72 15                	jb     f01025d4 <printnum+0x44>
f01025bf:	77 07                	ja     f01025c8 <printnum+0x38>
f01025c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01025c4:	39 d0                	cmp    %edx,%eax
f01025c6:	76 0c                	jbe    f01025d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01025c8:	83 eb 01             	sub    $0x1,%ebx
f01025cb:	85 db                	test   %ebx,%ebx
f01025cd:	8d 76 00             	lea    0x0(%esi),%esi
f01025d0:	7f 61                	jg     f0102633 <printnum+0xa3>
f01025d2:	eb 70                	jmp    f0102644 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01025d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01025d8:	83 eb 01             	sub    $0x1,%ebx
f01025db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01025df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01025e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01025e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f01025eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01025ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01025f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01025f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01025f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01025ff:	00 
f0102600:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102603:	89 04 24             	mov    %eax,(%esp)
f0102606:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102609:	89 54 24 04          	mov    %edx,0x4(%esp)
f010260d:	e8 4e 0a 00 00       	call   f0103060 <__udivdi3>
f0102612:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102615:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102618:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010261c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102620:	89 04 24             	mov    %eax,(%esp)
f0102623:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102627:	89 f2                	mov    %esi,%edx
f0102629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010262c:	e8 5f ff ff ff       	call   f0102590 <printnum>
f0102631:	eb 11                	jmp    f0102644 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102633:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102637:	89 3c 24             	mov    %edi,(%esp)
f010263a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010263d:	83 eb 01             	sub    $0x1,%ebx
f0102640:	85 db                	test   %ebx,%ebx
f0102642:	7f ef                	jg     f0102633 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102644:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102648:	8b 74 24 04          	mov    0x4(%esp),%esi
f010264c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010264f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102653:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010265a:	00 
f010265b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010265e:	89 14 24             	mov    %edx,(%esp)
f0102661:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102664:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0102668:	e8 23 0b 00 00       	call   f0103190 <__umoddi3>
f010266d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102671:	0f be 80 6d 3d 10 f0 	movsbl -0xfefc293(%eax),%eax
f0102678:	89 04 24             	mov    %eax,(%esp)
f010267b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010267e:	83 c4 4c             	add    $0x4c,%esp
f0102681:	5b                   	pop    %ebx
f0102682:	5e                   	pop    %esi
f0102683:	5f                   	pop    %edi
f0102684:	5d                   	pop    %ebp
f0102685:	c3                   	ret    

f0102686 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102686:	55                   	push   %ebp
f0102687:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102689:	83 fa 01             	cmp    $0x1,%edx
f010268c:	7e 0f                	jle    f010269d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f010268e:	8b 10                	mov    (%eax),%edx
f0102690:	83 c2 08             	add    $0x8,%edx
f0102693:	89 10                	mov    %edx,(%eax)
f0102695:	8b 42 f8             	mov    -0x8(%edx),%eax
f0102698:	8b 52 fc             	mov    -0x4(%edx),%edx
f010269b:	eb 24                	jmp    f01026c1 <getuint+0x3b>
	else if (lflag)
f010269d:	85 d2                	test   %edx,%edx
f010269f:	74 11                	je     f01026b2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f01026a1:	8b 10                	mov    (%eax),%edx
f01026a3:	83 c2 04             	add    $0x4,%edx
f01026a6:	89 10                	mov    %edx,(%eax)
f01026a8:	8b 42 fc             	mov    -0x4(%edx),%eax
f01026ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01026b0:	eb 0f                	jmp    f01026c1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f01026b2:	8b 10                	mov    (%eax),%edx
f01026b4:	83 c2 04             	add    $0x4,%edx
f01026b7:	89 10                	mov    %edx,(%eax)
f01026b9:	8b 42 fc             	mov    -0x4(%edx),%eax
f01026bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01026c1:	5d                   	pop    %ebp
f01026c2:	c3                   	ret    

f01026c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01026c3:	55                   	push   %ebp
f01026c4:	89 e5                	mov    %esp,%ebp
f01026c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01026c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01026cd:	8b 10                	mov    (%eax),%edx
f01026cf:	3b 50 04             	cmp    0x4(%eax),%edx
f01026d2:	73 0a                	jae    f01026de <sprintputch+0x1b>
		*b->buf++ = ch;
f01026d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01026d7:	88 0a                	mov    %cl,(%edx)
f01026d9:	83 c2 01             	add    $0x1,%edx
f01026dc:	89 10                	mov    %edx,(%eax)
}
f01026de:	5d                   	pop    %ebp
f01026df:	c3                   	ret    

f01026e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01026e0:	55                   	push   %ebp
f01026e1:	89 e5                	mov    %esp,%ebp
f01026e3:	57                   	push   %edi
f01026e4:	56                   	push   %esi
f01026e5:	53                   	push   %ebx
f01026e6:	83 ec 5c             	sub    $0x5c,%esp
f01026e9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01026ec:	8b 75 0c             	mov    0xc(%ebp),%esi
f01026ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01026f2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01026f9:	eb 11                	jmp    f010270c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01026fb:	85 c0                	test   %eax,%eax
f01026fd:	0f 84 1a 04 00 00    	je     f0102b1d <vprintfmt+0x43d>
				return;
			putch(ch, putdat);
f0102703:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102707:	89 04 24             	mov    %eax,(%esp)
f010270a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010270c:	0f b6 03             	movzbl (%ebx),%eax
f010270f:	83 c3 01             	add    $0x1,%ebx
f0102712:	83 f8 25             	cmp    $0x25,%eax
f0102715:	75 e4                	jne    f01026fb <vprintfmt+0x1b>
f0102717:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010271b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0102722:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0102729:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0102730:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102735:	eb 06                	jmp    f010273d <vprintfmt+0x5d>
f0102737:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f010273b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010273d:	0f b6 13             	movzbl (%ebx),%edx
f0102740:	0f b6 c2             	movzbl %dl,%eax
f0102743:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102746:	8d 43 01             	lea    0x1(%ebx),%eax
f0102749:	83 ea 23             	sub    $0x23,%edx
f010274c:	80 fa 55             	cmp    $0x55,%dl
f010274f:	0f 87 ab 03 00 00    	ja     f0102b00 <vprintfmt+0x420>
f0102755:	0f b6 d2             	movzbl %dl,%edx
f0102758:	ff 24 95 f8 3d 10 f0 	jmp    *-0xfefc208(,%edx,4)
f010275f:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0102763:	eb d6                	jmp    f010273b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102765:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102768:	83 ea 30             	sub    $0x30,%edx
f010276b:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f010276e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0102771:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0102774:	83 fb 09             	cmp    $0x9,%ebx
f0102777:	77 55                	ja     f01027ce <vprintfmt+0xee>
f0102779:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010277c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010277f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0102782:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0102785:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0102789:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010278c:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010278f:	83 fb 09             	cmp    $0x9,%ebx
f0102792:	76 eb                	jbe    f010277f <vprintfmt+0x9f>
f0102794:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102797:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010279a:	eb 32                	jmp    f01027ce <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010279c:	8b 55 14             	mov    0x14(%ebp),%edx
f010279f:	83 c2 04             	add    $0x4,%edx
f01027a2:	89 55 14             	mov    %edx,0x14(%ebp)
f01027a5:	8b 52 fc             	mov    -0x4(%edx),%edx
f01027a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f01027ab:	eb 21                	jmp    f01027ce <vprintfmt+0xee>

		case '.':
			if (width < 0)
f01027ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01027b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01027b6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
f01027ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01027bd:	e9 79 ff ff ff       	jmp    f010273b <vprintfmt+0x5b>
f01027c2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01027c9:	e9 6d ff ff ff       	jmp    f010273b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f01027ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01027d2:	0f 89 63 ff ff ff    	jns    f010273b <vprintfmt+0x5b>
f01027d8:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01027db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01027de:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01027e1:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01027e4:	e9 52 ff ff ff       	jmp    f010273b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01027e9:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f01027ec:	e9 4a ff ff ff       	jmp    f010273b <vprintfmt+0x5b>
f01027f1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01027f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01027f7:	83 c0 04             	add    $0x4,%eax
f01027fa:	89 45 14             	mov    %eax,0x14(%ebp)
f01027fd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102801:	8b 40 fc             	mov    -0x4(%eax),%eax
f0102804:	89 04 24             	mov    %eax,(%esp)
f0102807:	ff d7                	call   *%edi
f0102809:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f010280c:	e9 fb fe ff ff       	jmp    f010270c <vprintfmt+0x2c>
f0102811:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102814:	8b 45 14             	mov    0x14(%ebp),%eax
f0102817:	83 c0 04             	add    $0x4,%eax
f010281a:	89 45 14             	mov    %eax,0x14(%ebp)
f010281d:	8b 40 fc             	mov    -0x4(%eax),%eax
f0102820:	89 c2                	mov    %eax,%edx
f0102822:	c1 fa 1f             	sar    $0x1f,%edx
f0102825:	31 d0                	xor    %edx,%eax
f0102827:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0102829:	83 f8 06             	cmp    $0x6,%eax
f010282c:	7f 0b                	jg     f0102839 <vprintfmt+0x159>
f010282e:	8b 14 85 50 3f 10 f0 	mov    -0xfefc0b0(,%eax,4),%edx
f0102835:	85 d2                	test   %edx,%edx
f0102837:	75 20                	jne    f0102859 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
f0102839:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010283d:	c7 44 24 08 7e 3d 10 	movl   $0xf0103d7e,0x8(%esp)
f0102844:	f0 
f0102845:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102849:	89 3c 24             	mov    %edi,(%esp)
f010284c:	e8 54 03 00 00       	call   f0102ba5 <printfmt>
f0102851:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0102854:	e9 b3 fe ff ff       	jmp    f010270c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0102859:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010285d:	c7 44 24 08 9f 3b 10 	movl   $0xf0103b9f,0x8(%esp)
f0102864:	f0 
f0102865:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102869:	89 3c 24             	mov    %edi,(%esp)
f010286c:	e8 34 03 00 00       	call   f0102ba5 <printfmt>
f0102871:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102874:	e9 93 fe ff ff       	jmp    f010270c <vprintfmt+0x2c>
f0102879:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010287c:	89 c3                	mov    %eax,%ebx
f010287e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102881:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102884:	89 4d c0             	mov    %ecx,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102887:	8b 45 14             	mov    0x14(%ebp),%eax
f010288a:	83 c0 04             	add    $0x4,%eax
f010288d:	89 45 14             	mov    %eax,0x14(%ebp)
f0102890:	8b 40 fc             	mov    -0x4(%eax),%eax
f0102893:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102896:	85 c0                	test   %eax,%eax
f0102898:	b8 87 3d 10 f0       	mov    $0xf0103d87,%eax
f010289d:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
f01028a1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f01028a4:	85 c9                	test   %ecx,%ecx
f01028a6:	7e 06                	jle    f01028ae <vprintfmt+0x1ce>
f01028a8:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f01028ac:	75 13                	jne    f01028c1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01028ae:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01028b1:	0f be 02             	movsbl (%edx),%eax
f01028b4:	85 c0                	test   %eax,%eax
f01028b6:	0f 85 99 00 00 00    	jne    f0102955 <vprintfmt+0x275>
f01028bc:	e9 86 00 00 00       	jmp    f0102947 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01028c1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01028c5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01028c8:	89 0c 24             	mov    %ecx,(%esp)
f01028cb:	e8 eb 03 00 00       	call   f0102cbb <strnlen>
f01028d0:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01028d3:	29 c2                	sub    %eax,%edx
f01028d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01028d8:	85 d2                	test   %edx,%edx
f01028da:	7e d2                	jle    f01028ae <vprintfmt+0x1ce>
					putch(padc, putdat);
f01028dc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
f01028e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01028e3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f01028e6:	89 d3                	mov    %edx,%ebx
f01028e8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01028ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01028ef:	89 04 24             	mov    %eax,(%esp)
f01028f2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01028f4:	83 eb 01             	sub    $0x1,%ebx
f01028f7:	85 db                	test   %ebx,%ebx
f01028f9:	7f ed                	jg     f01028e8 <vprintfmt+0x208>
f01028fb:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01028fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102905:	eb a7                	jmp    f01028ae <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102907:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010290b:	74 18                	je     f0102925 <vprintfmt+0x245>
f010290d:	8d 50 e0             	lea    -0x20(%eax),%edx
f0102910:	83 fa 5e             	cmp    $0x5e,%edx
f0102913:	76 10                	jbe    f0102925 <vprintfmt+0x245>
					putch('?', putdat);
f0102915:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102919:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0102920:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102923:	eb 0a                	jmp    f010292f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0102925:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102929:	89 04 24             	mov    %eax,(%esp)
f010292c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010292f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0102933:	0f be 03             	movsbl (%ebx),%eax
f0102936:	85 c0                	test   %eax,%eax
f0102938:	74 05                	je     f010293f <vprintfmt+0x25f>
f010293a:	83 c3 01             	add    $0x1,%ebx
f010293d:	eb 29                	jmp    f0102968 <vprintfmt+0x288>
f010293f:	89 fe                	mov    %edi,%esi
f0102941:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102944:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102947:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010294b:	7f 2e                	jg     f010297b <vprintfmt+0x29b>
f010294d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102950:	e9 b7 fd ff ff       	jmp    f010270c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102955:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102958:	83 c2 01             	add    $0x1,%edx
f010295b:	89 7d dc             	mov    %edi,-0x24(%ebp)
f010295e:	89 f7                	mov    %esi,%edi
f0102960:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102963:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0102966:	89 d3                	mov    %edx,%ebx
f0102968:	85 f6                	test   %esi,%esi
f010296a:	78 9b                	js     f0102907 <vprintfmt+0x227>
f010296c:	83 ee 01             	sub    $0x1,%esi
f010296f:	79 96                	jns    f0102907 <vprintfmt+0x227>
f0102971:	89 fe                	mov    %edi,%esi
f0102973:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102976:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102979:	eb cc                	jmp    f0102947 <vprintfmt+0x267>
f010297b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010297e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102981:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102985:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010298c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010298e:	83 eb 01             	sub    $0x1,%ebx
f0102991:	85 db                	test   %ebx,%ebx
f0102993:	7f ec                	jg     f0102981 <vprintfmt+0x2a1>
f0102995:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102998:	e9 6f fd ff ff       	jmp    f010270c <vprintfmt+0x2c>
f010299d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01029a0:	83 f9 01             	cmp    $0x1,%ecx
f01029a3:	7e 17                	jle    f01029bc <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
f01029a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01029a8:	83 c0 08             	add    $0x8,%eax
f01029ab:	89 45 14             	mov    %eax,0x14(%ebp)
f01029ae:	8b 50 f8             	mov    -0x8(%eax),%edx
f01029b1:	8b 48 fc             	mov    -0x4(%eax),%ecx
f01029b4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01029b7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01029ba:	eb 34                	jmp    f01029f0 <vprintfmt+0x310>
	else if (lflag)
f01029bc:	85 c9                	test   %ecx,%ecx
f01029be:	74 19                	je     f01029d9 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
f01029c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01029c3:	83 c0 04             	add    $0x4,%eax
f01029c6:	89 45 14             	mov    %eax,0x14(%ebp)
f01029c9:	8b 40 fc             	mov    -0x4(%eax),%eax
f01029cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029cf:	89 c1                	mov    %eax,%ecx
f01029d1:	c1 f9 1f             	sar    $0x1f,%ecx
f01029d4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01029d7:	eb 17                	jmp    f01029f0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
f01029d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01029dc:	83 c0 04             	add    $0x4,%eax
f01029df:	89 45 14             	mov    %eax,0x14(%ebp)
f01029e2:	8b 40 fc             	mov    -0x4(%eax),%eax
f01029e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029e8:	89 c2                	mov    %eax,%edx
f01029ea:	c1 fa 1f             	sar    $0x1f,%edx
f01029ed:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01029f0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01029f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029f6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01029fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01029ff:	0f 89 b9 00 00 00    	jns    f0102abe <vprintfmt+0x3de>
				putch('-', putdat);
f0102a05:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a09:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0102a10:	ff d7                	call   *%edi
				num = -(long long) num;
f0102a12:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a18:	f7 d9                	neg    %ecx
f0102a1a:	83 d3 00             	adc    $0x0,%ebx
f0102a1d:	f7 db                	neg    %ebx
f0102a1f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102a24:	e9 95 00 00 00       	jmp    f0102abe <vprintfmt+0x3de>
f0102a29:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102a2c:	89 ca                	mov    %ecx,%edx
f0102a2e:	8d 45 14             	lea    0x14(%ebp),%eax
f0102a31:	e8 50 fc ff ff       	call   f0102686 <getuint>
f0102a36:	89 c1                	mov    %eax,%ecx
f0102a38:	89 d3                	mov    %edx,%ebx
f0102a3a:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0102a3f:	eb 7d                	jmp    f0102abe <vprintfmt+0x3de>
f0102a41:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0102a44:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a48:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0102a4f:	ff d7                	call   *%edi
			putch('X', putdat);
f0102a51:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a55:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0102a5c:	ff d7                	call   *%edi
			putch('X', putdat);
f0102a5e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a62:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0102a69:	ff d7                	call   *%edi
f0102a6b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0102a6e:	e9 99 fc ff ff       	jmp    f010270c <vprintfmt+0x2c>
f0102a73:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0102a76:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a7a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0102a81:	ff d7                	call   *%edi
			putch('x', putdat);
f0102a83:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a87:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0102a8e:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102a90:	8b 45 14             	mov    0x14(%ebp),%eax
f0102a93:	83 c0 04             	add    $0x4,%eax
f0102a96:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102a99:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0102a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102aa1:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102aa6:	eb 16                	jmp    f0102abe <vprintfmt+0x3de>
f0102aa8:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102aab:	89 ca                	mov    %ecx,%edx
f0102aad:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ab0:	e8 d1 fb ff ff       	call   f0102686 <getuint>
f0102ab5:	89 c1                	mov    %eax,%ecx
f0102ab7:	89 d3                	mov    %edx,%ebx
f0102ab9:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102abe:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0102ac2:	89 54 24 10          	mov    %edx,0x10(%esp)
f0102ac6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102ac9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102acd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ad1:	89 0c 24             	mov    %ecx,(%esp)
f0102ad4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ad8:	89 f2                	mov    %esi,%edx
f0102ada:	89 f8                	mov    %edi,%eax
f0102adc:	e8 af fa ff ff       	call   f0102590 <printnum>
f0102ae1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0102ae4:	e9 23 fc ff ff       	jmp    f010270c <vprintfmt+0x2c>
f0102ae9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102aec:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102aef:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102af3:	89 14 24             	mov    %edx,(%esp)
f0102af6:	ff d7                	call   *%edi
f0102af8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0102afb:	e9 0c fc ff ff       	jmp    f010270c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102b00:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b04:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0102b0b:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102b0d:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0102b10:	80 38 25             	cmpb   $0x25,(%eax)
f0102b13:	0f 84 f3 fb ff ff    	je     f010270c <vprintfmt+0x2c>
f0102b19:	89 c3                	mov    %eax,%ebx
f0102b1b:	eb f0                	jmp    f0102b0d <vprintfmt+0x42d>
				/* do nothing */;
			break;
		}
	}
}
f0102b1d:	83 c4 5c             	add    $0x5c,%esp
f0102b20:	5b                   	pop    %ebx
f0102b21:	5e                   	pop    %esi
f0102b22:	5f                   	pop    %edi
f0102b23:	5d                   	pop    %ebp
f0102b24:	c3                   	ret    

f0102b25 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102b25:	55                   	push   %ebp
f0102b26:	89 e5                	mov    %esp,%ebp
f0102b28:	83 ec 28             	sub    $0x28,%esp
f0102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0102b31:	85 c0                	test   %eax,%eax
f0102b33:	74 04                	je     f0102b39 <vsnprintf+0x14>
f0102b35:	85 d2                	test   %edx,%edx
f0102b37:	7f 07                	jg     f0102b40 <vsnprintf+0x1b>
f0102b39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0102b3e:	eb 3b                	jmp    f0102b7b <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102b40:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102b43:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0102b47:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102b51:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b54:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b58:	8b 45 10             	mov    0x10(%ebp),%eax
f0102b5b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102b5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102b62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b66:	c7 04 24 c3 26 10 f0 	movl   $0xf01026c3,(%esp)
f0102b6d:	e8 6e fb ff ff       	call   f01026e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b75:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0102b7b:	c9                   	leave  
f0102b7c:	c3                   	ret    

f0102b7d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102b7d:	55                   	push   %ebp
f0102b7e:	89 e5                	mov    %esp,%ebp
f0102b80:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0102b83:	8d 45 14             	lea    0x14(%ebp),%eax
f0102b86:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b8a:	8b 45 10             	mov    0x10(%ebp),%eax
f0102b8d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102b91:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b98:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b9b:	89 04 24             	mov    %eax,(%esp)
f0102b9e:	e8 82 ff ff ff       	call   f0102b25 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102ba3:	c9                   	leave  
f0102ba4:	c3                   	ret    

f0102ba5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102ba5:	55                   	push   %ebp
f0102ba6:	89 e5                	mov    %esp,%ebp
f0102ba8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0102bab:	8d 45 14             	lea    0x14(%ebp),%eax
f0102bae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bb2:	8b 45 10             	mov    0x10(%ebp),%eax
f0102bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102bc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bc3:	89 04 24             	mov    %eax,(%esp)
f0102bc6:	e8 15 fb ff ff       	call   f01026e0 <vprintfmt>
	va_end(ap);
}
f0102bcb:	c9                   	leave  
f0102bcc:	c3                   	ret    
f0102bcd:	00 00                	add    %al,(%eax)
	...

f0102bd0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102bd0:	55                   	push   %ebp
f0102bd1:	89 e5                	mov    %esp,%ebp
f0102bd3:	57                   	push   %edi
f0102bd4:	56                   	push   %esi
f0102bd5:	53                   	push   %ebx
f0102bd6:	83 ec 1c             	sub    $0x1c,%esp
f0102bd9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102bdc:	85 c0                	test   %eax,%eax
f0102bde:	74 10                	je     f0102bf0 <readline+0x20>
		cprintf("%s", prompt);
f0102be0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102be4:	c7 04 24 9f 3b 10 f0 	movl   $0xf0103b9f,(%esp)
f0102beb:	e8 0b f6 ff ff       	call   f01021fb <cprintf>

	i = 0;
	echoing = iscons(0);
f0102bf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bf7:	e8 35 d7 ff ff       	call   f0100331 <iscons>
f0102bfc:	89 c7                	mov    %eax,%edi
f0102bfe:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0102c03:	e8 18 d7 ff ff       	call   f0100320 <getchar>
f0102c08:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102c0a:	85 c0                	test   %eax,%eax
f0102c0c:	79 17                	jns    f0102c25 <readline+0x55>
			cprintf("read error: %e\n", c);
f0102c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c12:	c7 04 24 6c 3f 10 f0 	movl   $0xf0103f6c,(%esp)
f0102c19:	e8 dd f5 ff ff       	call   f01021fb <cprintf>
f0102c1e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0102c23:	eb 65                	jmp    f0102c8a <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102c25:	83 f8 1f             	cmp    $0x1f,%eax
f0102c28:	7e 1f                	jle    f0102c49 <readline+0x79>
f0102c2a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102c30:	7f 17                	jg     f0102c49 <readline+0x79>
			if (echoing)
f0102c32:	85 ff                	test   %edi,%edi
f0102c34:	74 08                	je     f0102c3e <readline+0x6e>
				cputchar(c);
f0102c36:	89 04 24             	mov    %eax,(%esp)
f0102c39:	e8 12 da ff ff       	call   f0100650 <cputchar>
			buf[i++] = c;
f0102c3e:	88 9e e0 45 11 f0    	mov    %bl,-0xfeeba20(%esi)
f0102c44:	83 c6 01             	add    $0x1,%esi
f0102c47:	eb ba                	jmp    f0102c03 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0102c49:	83 fb 08             	cmp    $0x8,%ebx
f0102c4c:	75 15                	jne    f0102c63 <readline+0x93>
f0102c4e:	85 f6                	test   %esi,%esi
f0102c50:	7e 11                	jle    f0102c63 <readline+0x93>
			if (echoing)
f0102c52:	85 ff                	test   %edi,%edi
f0102c54:	74 08                	je     f0102c5e <readline+0x8e>
				cputchar(c);
f0102c56:	89 1c 24             	mov    %ebx,(%esp)
f0102c59:	e8 f2 d9 ff ff       	call   f0100650 <cputchar>
			i--;
f0102c5e:	83 ee 01             	sub    $0x1,%esi
f0102c61:	eb a0                	jmp    f0102c03 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0102c63:	83 fb 0a             	cmp    $0xa,%ebx
f0102c66:	74 0a                	je     f0102c72 <readline+0xa2>
f0102c68:	83 fb 0d             	cmp    $0xd,%ebx
f0102c6b:	90                   	nop
f0102c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102c70:	75 91                	jne    f0102c03 <readline+0x33>
			if (echoing)
f0102c72:	85 ff                	test   %edi,%edi
f0102c74:	74 08                	je     f0102c7e <readline+0xae>
				cputchar(c);
f0102c76:	89 1c 24             	mov    %ebx,(%esp)
f0102c79:	e8 d2 d9 ff ff       	call   f0100650 <cputchar>
			buf[i] = 0;
f0102c7e:	c6 86 e0 45 11 f0 00 	movb   $0x0,-0xfeeba20(%esi)
f0102c85:	b8 e0 45 11 f0       	mov    $0xf01145e0,%eax
			return buf;
		}
	}
}
f0102c8a:	83 c4 1c             	add    $0x1c,%esp
f0102c8d:	5b                   	pop    %ebx
f0102c8e:	5e                   	pop    %esi
f0102c8f:	5f                   	pop    %edi
f0102c90:	5d                   	pop    %ebp
f0102c91:	c3                   	ret    
	...

f0102ca0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0102ca0:	55                   	push   %ebp
f0102ca1:	89 e5                	mov    %esp,%ebp
f0102ca3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0102ca6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cab:	80 3a 00             	cmpb   $0x0,(%edx)
f0102cae:	74 09                	je     f0102cb9 <strlen+0x19>
		n++;
f0102cb0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0102cb3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0102cb7:	75 f7                	jne    f0102cb0 <strlen+0x10>
		n++;
	return n;
}
f0102cb9:	5d                   	pop    %ebp
f0102cba:	c3                   	ret    

f0102cbb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0102cbb:	55                   	push   %ebp
f0102cbc:	89 e5                	mov    %esp,%ebp
f0102cbe:	53                   	push   %ebx
f0102cbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0102cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102cc5:	85 c9                	test   %ecx,%ecx
f0102cc7:	74 19                	je     f0102ce2 <strnlen+0x27>
f0102cc9:	80 3b 00             	cmpb   $0x0,(%ebx)
f0102ccc:	74 14                	je     f0102ce2 <strnlen+0x27>
f0102cce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0102cd3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102cd6:	39 c8                	cmp    %ecx,%eax
f0102cd8:	74 0d                	je     f0102ce7 <strnlen+0x2c>
f0102cda:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0102cde:	75 f3                	jne    f0102cd3 <strnlen+0x18>
f0102ce0:	eb 05                	jmp    f0102ce7 <strnlen+0x2c>
f0102ce2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0102ce7:	5b                   	pop    %ebx
f0102ce8:	5d                   	pop    %ebp
f0102ce9:	c3                   	ret    

f0102cea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0102cea:	55                   	push   %ebp
f0102ceb:	89 e5                	mov    %esp,%ebp
f0102ced:	53                   	push   %ebx
f0102cee:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cf1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102cf4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102cf9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0102cfd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102d00:	83 c2 01             	add    $0x1,%edx
f0102d03:	84 c9                	test   %cl,%cl
f0102d05:	75 f2                	jne    f0102cf9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0102d07:	5b                   	pop    %ebx
f0102d08:	5d                   	pop    %ebp
f0102d09:	c3                   	ret    

f0102d0a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0102d0a:	55                   	push   %ebp
f0102d0b:	89 e5                	mov    %esp,%ebp
f0102d0d:	56                   	push   %esi
f0102d0e:	53                   	push   %ebx
f0102d0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d12:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102d15:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102d18:	85 f6                	test   %esi,%esi
f0102d1a:	74 18                	je     f0102d34 <strncpy+0x2a>
f0102d1c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0102d21:	0f b6 1a             	movzbl (%edx),%ebx
f0102d24:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0102d27:	80 3a 01             	cmpb   $0x1,(%edx)
f0102d2a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102d2d:	83 c1 01             	add    $0x1,%ecx
f0102d30:	39 ce                	cmp    %ecx,%esi
f0102d32:	77 ed                	ja     f0102d21 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0102d34:	5b                   	pop    %ebx
f0102d35:	5e                   	pop    %esi
f0102d36:	5d                   	pop    %ebp
f0102d37:	c3                   	ret    

f0102d38 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0102d38:	55                   	push   %ebp
f0102d39:	89 e5                	mov    %esp,%ebp
f0102d3b:	56                   	push   %esi
f0102d3c:	53                   	push   %ebx
f0102d3d:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d40:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102d43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102d46:	89 f0                	mov    %esi,%eax
f0102d48:	85 c9                	test   %ecx,%ecx
f0102d4a:	74 27                	je     f0102d73 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0102d4c:	83 e9 01             	sub    $0x1,%ecx
f0102d4f:	74 1d                	je     f0102d6e <strlcpy+0x36>
f0102d51:	0f b6 1a             	movzbl (%edx),%ebx
f0102d54:	84 db                	test   %bl,%bl
f0102d56:	74 16                	je     f0102d6e <strlcpy+0x36>
			*dst++ = *src++;
f0102d58:	88 18                	mov    %bl,(%eax)
f0102d5a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0102d5d:	83 e9 01             	sub    $0x1,%ecx
f0102d60:	74 0e                	je     f0102d70 <strlcpy+0x38>
			*dst++ = *src++;
f0102d62:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0102d65:	0f b6 1a             	movzbl (%edx),%ebx
f0102d68:	84 db                	test   %bl,%bl
f0102d6a:	75 ec                	jne    f0102d58 <strlcpy+0x20>
f0102d6c:	eb 02                	jmp    f0102d70 <strlcpy+0x38>
f0102d6e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0102d70:	c6 00 00             	movb   $0x0,(%eax)
f0102d73:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0102d75:	5b                   	pop    %ebx
f0102d76:	5e                   	pop    %esi
f0102d77:	5d                   	pop    %ebp
f0102d78:	c3                   	ret    

f0102d79 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0102d79:	55                   	push   %ebp
f0102d7a:	89 e5                	mov    %esp,%ebp
f0102d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102d7f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0102d82:	0f b6 01             	movzbl (%ecx),%eax
f0102d85:	84 c0                	test   %al,%al
f0102d87:	74 15                	je     f0102d9e <strcmp+0x25>
f0102d89:	3a 02                	cmp    (%edx),%al
f0102d8b:	75 11                	jne    f0102d9e <strcmp+0x25>
		p++, q++;
f0102d8d:	83 c1 01             	add    $0x1,%ecx
f0102d90:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0102d93:	0f b6 01             	movzbl (%ecx),%eax
f0102d96:	84 c0                	test   %al,%al
f0102d98:	74 04                	je     f0102d9e <strcmp+0x25>
f0102d9a:	3a 02                	cmp    (%edx),%al
f0102d9c:	74 ef                	je     f0102d8d <strcmp+0x14>
f0102d9e:	0f b6 c0             	movzbl %al,%eax
f0102da1:	0f b6 12             	movzbl (%edx),%edx
f0102da4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102da6:	5d                   	pop    %ebp
f0102da7:	c3                   	ret    

f0102da8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102da8:	55                   	push   %ebp
f0102da9:	89 e5                	mov    %esp,%ebp
f0102dab:	53                   	push   %ebx
f0102dac:	8b 55 08             	mov    0x8(%ebp),%edx
f0102daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102db2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0102db5:	85 c0                	test   %eax,%eax
f0102db7:	74 23                	je     f0102ddc <strncmp+0x34>
f0102db9:	0f b6 1a             	movzbl (%edx),%ebx
f0102dbc:	84 db                	test   %bl,%bl
f0102dbe:	74 24                	je     f0102de4 <strncmp+0x3c>
f0102dc0:	3a 19                	cmp    (%ecx),%bl
f0102dc2:	75 20                	jne    f0102de4 <strncmp+0x3c>
f0102dc4:	83 e8 01             	sub    $0x1,%eax
f0102dc7:	74 13                	je     f0102ddc <strncmp+0x34>
		n--, p++, q++;
f0102dc9:	83 c2 01             	add    $0x1,%edx
f0102dcc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102dcf:	0f b6 1a             	movzbl (%edx),%ebx
f0102dd2:	84 db                	test   %bl,%bl
f0102dd4:	74 0e                	je     f0102de4 <strncmp+0x3c>
f0102dd6:	3a 19                	cmp    (%ecx),%bl
f0102dd8:	74 ea                	je     f0102dc4 <strncmp+0x1c>
f0102dda:	eb 08                	jmp    f0102de4 <strncmp+0x3c>
f0102ddc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102de1:	5b                   	pop    %ebx
f0102de2:	5d                   	pop    %ebp
f0102de3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102de4:	0f b6 02             	movzbl (%edx),%eax
f0102de7:	0f b6 11             	movzbl (%ecx),%edx
f0102dea:	29 d0                	sub    %edx,%eax
f0102dec:	eb f3                	jmp    f0102de1 <strncmp+0x39>

f0102dee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0102dee:	55                   	push   %ebp
f0102def:	89 e5                	mov    %esp,%ebp
f0102df1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102df8:	0f b6 10             	movzbl (%eax),%edx
f0102dfb:	84 d2                	test   %dl,%dl
f0102dfd:	74 15                	je     f0102e14 <strchr+0x26>
		if (*s == c)
f0102dff:	38 ca                	cmp    %cl,%dl
f0102e01:	75 07                	jne    f0102e0a <strchr+0x1c>
f0102e03:	eb 14                	jmp    f0102e19 <strchr+0x2b>
f0102e05:	38 ca                	cmp    %cl,%dl
f0102e07:	90                   	nop
f0102e08:	74 0f                	je     f0102e19 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0102e0a:	83 c0 01             	add    $0x1,%eax
f0102e0d:	0f b6 10             	movzbl (%eax),%edx
f0102e10:	84 d2                	test   %dl,%dl
f0102e12:	75 f1                	jne    f0102e05 <strchr+0x17>
f0102e14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0102e19:	5d                   	pop    %ebp
f0102e1a:	c3                   	ret    

f0102e1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0102e1b:	55                   	push   %ebp
f0102e1c:	89 e5                	mov    %esp,%ebp
f0102e1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102e25:	0f b6 10             	movzbl (%eax),%edx
f0102e28:	84 d2                	test   %dl,%dl
f0102e2a:	74 18                	je     f0102e44 <strfind+0x29>
		if (*s == c)
f0102e2c:	38 ca                	cmp    %cl,%dl
f0102e2e:	75 0a                	jne    f0102e3a <strfind+0x1f>
f0102e30:	eb 12                	jmp    f0102e44 <strfind+0x29>
f0102e32:	38 ca                	cmp    %cl,%dl
f0102e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102e38:	74 0a                	je     f0102e44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0102e3a:	83 c0 01             	add    $0x1,%eax
f0102e3d:	0f b6 10             	movzbl (%eax),%edx
f0102e40:	84 d2                	test   %dl,%dl
f0102e42:	75 ee                	jne    f0102e32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0102e44:	5d                   	pop    %ebp
f0102e45:	c3                   	ret    

f0102e46 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0102e46:	55                   	push   %ebp
f0102e47:	89 e5                	mov    %esp,%ebp
f0102e49:	53                   	push   %ebx
f0102e4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0102e53:	89 da                	mov    %ebx,%edx
f0102e55:	83 ea 01             	sub    $0x1,%edx
f0102e58:	78 0d                	js     f0102e67 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f0102e5a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f0102e5c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f0102e5e:	88 0a                	mov    %cl,(%edx)
f0102e60:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0102e63:	39 da                	cmp    %ebx,%edx
f0102e65:	75 f7                	jne    f0102e5e <memset+0x18>
		*p++ = c;

	return v;
}
f0102e67:	5b                   	pop    %ebx
f0102e68:	5d                   	pop    %ebp
f0102e69:	c3                   	ret    

f0102e6a <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f0102e6a:	55                   	push   %ebp
f0102e6b:	89 e5                	mov    %esp,%ebp
f0102e6d:	56                   	push   %esi
f0102e6e:	53                   	push   %ebx
f0102e6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e72:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0102e78:	85 db                	test   %ebx,%ebx
f0102e7a:	74 13                	je     f0102e8f <memcpy+0x25>
f0102e7c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f0102e81:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0102e85:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102e88:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0102e8b:	39 da                	cmp    %ebx,%edx
f0102e8d:	75 f2                	jne    f0102e81 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f0102e8f:	5b                   	pop    %ebx
f0102e90:	5e                   	pop    %esi
f0102e91:	5d                   	pop    %ebp
f0102e92:	c3                   	ret    

f0102e93 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0102e93:	55                   	push   %ebp
f0102e94:	89 e5                	mov    %esp,%ebp
f0102e96:	57                   	push   %edi
f0102e97:	56                   	push   %esi
f0102e98:	53                   	push   %ebx
f0102e99:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e9c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102e9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f0102ea2:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f0102ea4:	39 c6                	cmp    %eax,%esi
f0102ea6:	72 0b                	jb     f0102eb3 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f0102ea8:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f0102ead:	85 db                	test   %ebx,%ebx
f0102eaf:	75 2e                	jne    f0102edf <memmove+0x4c>
f0102eb1:	eb 3a                	jmp    f0102eed <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0102eb3:	01 df                	add    %ebx,%edi
f0102eb5:	39 f8                	cmp    %edi,%eax
f0102eb7:	73 ef                	jae    f0102ea8 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f0102eb9:	85 db                	test   %ebx,%ebx
f0102ebb:	90                   	nop
f0102ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102ec0:	74 2b                	je     f0102eed <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0102ec2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f0102ec5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f0102eca:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f0102ecf:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f0102ed3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0102ed6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0102ed9:	85 c9                	test   %ecx,%ecx
f0102edb:	75 ed                	jne    f0102eca <memmove+0x37>
f0102edd:	eb 0e                	jmp    f0102eed <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0102edf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0102ee3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102ee6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0102ee9:	39 d3                	cmp    %edx,%ebx
f0102eeb:	75 f2                	jne    f0102edf <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
f0102eed:	5b                   	pop    %ebx
f0102eee:	5e                   	pop    %esi
f0102eef:	5f                   	pop    %edi
f0102ef0:	5d                   	pop    %ebp
f0102ef1:	c3                   	ret    

f0102ef2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0102ef2:	55                   	push   %ebp
f0102ef3:	89 e5                	mov    %esp,%ebp
f0102ef5:	57                   	push   %edi
f0102ef6:	56                   	push   %esi
f0102ef7:	53                   	push   %ebx
f0102ef8:	8b 75 08             	mov    0x8(%ebp),%esi
f0102efb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102efe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102f01:	85 c9                	test   %ecx,%ecx
f0102f03:	74 36                	je     f0102f3b <memcmp+0x49>
		if (*s1 != *s2)
f0102f05:	0f b6 06             	movzbl (%esi),%eax
f0102f08:	0f b6 1f             	movzbl (%edi),%ebx
f0102f0b:	38 d8                	cmp    %bl,%al
f0102f0d:	74 20                	je     f0102f2f <memcmp+0x3d>
f0102f0f:	eb 14                	jmp    f0102f25 <memcmp+0x33>
f0102f11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0102f16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0102f1b:	83 c2 01             	add    $0x1,%edx
f0102f1e:	83 e9 01             	sub    $0x1,%ecx
f0102f21:	38 d8                	cmp    %bl,%al
f0102f23:	74 12                	je     f0102f37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0102f25:	0f b6 c0             	movzbl %al,%eax
f0102f28:	0f b6 db             	movzbl %bl,%ebx
f0102f2b:	29 d8                	sub    %ebx,%eax
f0102f2d:	eb 11                	jmp    f0102f40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102f2f:	83 e9 01             	sub    $0x1,%ecx
f0102f32:	ba 00 00 00 00       	mov    $0x0,%edx
f0102f37:	85 c9                	test   %ecx,%ecx
f0102f39:	75 d6                	jne    f0102f11 <memcmp+0x1f>
f0102f3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0102f40:	5b                   	pop    %ebx
f0102f41:	5e                   	pop    %esi
f0102f42:	5f                   	pop    %edi
f0102f43:	5d                   	pop    %ebp
f0102f44:	c3                   	ret    

f0102f45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102f45:	55                   	push   %ebp
f0102f46:	89 e5                	mov    %esp,%ebp
f0102f48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0102f4b:	89 c2                	mov    %eax,%edx
f0102f4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0102f50:	39 d0                	cmp    %edx,%eax
f0102f52:	73 15                	jae    f0102f69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102f54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0102f58:	38 08                	cmp    %cl,(%eax)
f0102f5a:	75 06                	jne    f0102f62 <memfind+0x1d>
f0102f5c:	eb 0b                	jmp    f0102f69 <memfind+0x24>
f0102f5e:	38 08                	cmp    %cl,(%eax)
f0102f60:	74 07                	je     f0102f69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102f62:	83 c0 01             	add    $0x1,%eax
f0102f65:	39 c2                	cmp    %eax,%edx
f0102f67:	77 f5                	ja     f0102f5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102f69:	5d                   	pop    %ebp
f0102f6a:	c3                   	ret    

f0102f6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102f6b:	55                   	push   %ebp
f0102f6c:	89 e5                	mov    %esp,%ebp
f0102f6e:	57                   	push   %edi
f0102f6f:	56                   	push   %esi
f0102f70:	53                   	push   %ebx
f0102f71:	83 ec 04             	sub    $0x4,%esp
f0102f74:	8b 55 08             	mov    0x8(%ebp),%edx
f0102f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102f7a:	0f b6 02             	movzbl (%edx),%eax
f0102f7d:	3c 20                	cmp    $0x20,%al
f0102f7f:	74 04                	je     f0102f85 <strtol+0x1a>
f0102f81:	3c 09                	cmp    $0x9,%al
f0102f83:	75 0e                	jne    f0102f93 <strtol+0x28>
		s++;
f0102f85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102f88:	0f b6 02             	movzbl (%edx),%eax
f0102f8b:	3c 20                	cmp    $0x20,%al
f0102f8d:	74 f6                	je     f0102f85 <strtol+0x1a>
f0102f8f:	3c 09                	cmp    $0x9,%al
f0102f91:	74 f2                	je     f0102f85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102f93:	3c 2b                	cmp    $0x2b,%al
f0102f95:	75 0c                	jne    f0102fa3 <strtol+0x38>
		s++;
f0102f97:	83 c2 01             	add    $0x1,%edx
f0102f9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0102fa1:	eb 15                	jmp    f0102fb8 <strtol+0x4d>
	else if (*s == '-')
f0102fa3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0102faa:	3c 2d                	cmp    $0x2d,%al
f0102fac:	75 0a                	jne    f0102fb8 <strtol+0x4d>
		s++, neg = 1;
f0102fae:	83 c2 01             	add    $0x1,%edx
f0102fb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0102fb8:	85 db                	test   %ebx,%ebx
f0102fba:	0f 94 c0             	sete   %al
f0102fbd:	74 05                	je     f0102fc4 <strtol+0x59>
f0102fbf:	83 fb 10             	cmp    $0x10,%ebx
f0102fc2:	75 18                	jne    f0102fdc <strtol+0x71>
f0102fc4:	80 3a 30             	cmpb   $0x30,(%edx)
f0102fc7:	75 13                	jne    f0102fdc <strtol+0x71>
f0102fc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0102fcd:	8d 76 00             	lea    0x0(%esi),%esi
f0102fd0:	75 0a                	jne    f0102fdc <strtol+0x71>
		s += 2, base = 16;
f0102fd2:	83 c2 02             	add    $0x2,%edx
f0102fd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0102fda:	eb 15                	jmp    f0102ff1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102fdc:	84 c0                	test   %al,%al
f0102fde:	66 90                	xchg   %ax,%ax
f0102fe0:	74 0f                	je     f0102ff1 <strtol+0x86>
f0102fe2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0102fe7:	80 3a 30             	cmpb   $0x30,(%edx)
f0102fea:	75 05                	jne    f0102ff1 <strtol+0x86>
		s++, base = 8;
f0102fec:	83 c2 01             	add    $0x1,%edx
f0102fef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102ff1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ff6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102ff8:	0f b6 0a             	movzbl (%edx),%ecx
f0102ffb:	89 cf                	mov    %ecx,%edi
f0102ffd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103000:	80 fb 09             	cmp    $0x9,%bl
f0103003:	77 08                	ja     f010300d <strtol+0xa2>
			dig = *s - '0';
f0103005:	0f be c9             	movsbl %cl,%ecx
f0103008:	83 e9 30             	sub    $0x30,%ecx
f010300b:	eb 1e                	jmp    f010302b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010300d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0103010:	80 fb 19             	cmp    $0x19,%bl
f0103013:	77 08                	ja     f010301d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0103015:	0f be c9             	movsbl %cl,%ecx
f0103018:	83 e9 57             	sub    $0x57,%ecx
f010301b:	eb 0e                	jmp    f010302b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010301d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0103020:	80 fb 19             	cmp    $0x19,%bl
f0103023:	77 15                	ja     f010303a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0103025:	0f be c9             	movsbl %cl,%ecx
f0103028:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010302b:	39 f1                	cmp    %esi,%ecx
f010302d:	7d 0b                	jge    f010303a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010302f:	83 c2 01             	add    $0x1,%edx
f0103032:	0f af c6             	imul   %esi,%eax
f0103035:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0103038:	eb be                	jmp    f0102ff8 <strtol+0x8d>
f010303a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010303c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103040:	74 05                	je     f0103047 <strtol+0xdc>
		*endptr = (char *) s;
f0103042:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103045:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103047:	89 ca                	mov    %ecx,%edx
f0103049:	f7 da                	neg    %edx
f010304b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010304f:	0f 45 c2             	cmovne %edx,%eax
}
f0103052:	83 c4 04             	add    $0x4,%esp
f0103055:	5b                   	pop    %ebx
f0103056:	5e                   	pop    %esi
f0103057:	5f                   	pop    %edi
f0103058:	5d                   	pop    %ebp
f0103059:	c3                   	ret    
f010305a:	00 00                	add    %al,(%eax)
f010305c:	00 00                	add    %al,(%eax)
	...

f0103060 <__udivdi3>:
f0103060:	55                   	push   %ebp
f0103061:	89 e5                	mov    %esp,%ebp
f0103063:	57                   	push   %edi
f0103064:	56                   	push   %esi
f0103065:	83 ec 10             	sub    $0x10,%esp
f0103068:	8b 45 14             	mov    0x14(%ebp),%eax
f010306b:	8b 55 08             	mov    0x8(%ebp),%edx
f010306e:	8b 75 10             	mov    0x10(%ebp),%esi
f0103071:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103074:	85 c0                	test   %eax,%eax
f0103076:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0103079:	75 35                	jne    f01030b0 <__udivdi3+0x50>
f010307b:	39 fe                	cmp    %edi,%esi
f010307d:	77 61                	ja     f01030e0 <__udivdi3+0x80>
f010307f:	85 f6                	test   %esi,%esi
f0103081:	75 0b                	jne    f010308e <__udivdi3+0x2e>
f0103083:	b8 01 00 00 00       	mov    $0x1,%eax
f0103088:	31 d2                	xor    %edx,%edx
f010308a:	f7 f6                	div    %esi
f010308c:	89 c6                	mov    %eax,%esi
f010308e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103091:	31 d2                	xor    %edx,%edx
f0103093:	89 f8                	mov    %edi,%eax
f0103095:	f7 f6                	div    %esi
f0103097:	89 c7                	mov    %eax,%edi
f0103099:	89 c8                	mov    %ecx,%eax
f010309b:	f7 f6                	div    %esi
f010309d:	89 c1                	mov    %eax,%ecx
f010309f:	89 fa                	mov    %edi,%edx
f01030a1:	89 c8                	mov    %ecx,%eax
f01030a3:	83 c4 10             	add    $0x10,%esp
f01030a6:	5e                   	pop    %esi
f01030a7:	5f                   	pop    %edi
f01030a8:	5d                   	pop    %ebp
f01030a9:	c3                   	ret    
f01030aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01030b0:	39 f8                	cmp    %edi,%eax
f01030b2:	77 1c                	ja     f01030d0 <__udivdi3+0x70>
f01030b4:	0f bd d0             	bsr    %eax,%edx
f01030b7:	83 f2 1f             	xor    $0x1f,%edx
f01030ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01030bd:	75 39                	jne    f01030f8 <__udivdi3+0x98>
f01030bf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01030c2:	0f 86 a0 00 00 00    	jbe    f0103168 <__udivdi3+0x108>
f01030c8:	39 f8                	cmp    %edi,%eax
f01030ca:	0f 82 98 00 00 00    	jb     f0103168 <__udivdi3+0x108>
f01030d0:	31 ff                	xor    %edi,%edi
f01030d2:	31 c9                	xor    %ecx,%ecx
f01030d4:	89 c8                	mov    %ecx,%eax
f01030d6:	89 fa                	mov    %edi,%edx
f01030d8:	83 c4 10             	add    $0x10,%esp
f01030db:	5e                   	pop    %esi
f01030dc:	5f                   	pop    %edi
f01030dd:	5d                   	pop    %ebp
f01030de:	c3                   	ret    
f01030df:	90                   	nop
f01030e0:	89 d1                	mov    %edx,%ecx
f01030e2:	89 fa                	mov    %edi,%edx
f01030e4:	89 c8                	mov    %ecx,%eax
f01030e6:	31 ff                	xor    %edi,%edi
f01030e8:	f7 f6                	div    %esi
f01030ea:	89 c1                	mov    %eax,%ecx
f01030ec:	89 fa                	mov    %edi,%edx
f01030ee:	89 c8                	mov    %ecx,%eax
f01030f0:	83 c4 10             	add    $0x10,%esp
f01030f3:	5e                   	pop    %esi
f01030f4:	5f                   	pop    %edi
f01030f5:	5d                   	pop    %ebp
f01030f6:	c3                   	ret    
f01030f7:	90                   	nop
f01030f8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01030fc:	89 f2                	mov    %esi,%edx
f01030fe:	d3 e0                	shl    %cl,%eax
f0103100:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103103:	b8 20 00 00 00       	mov    $0x20,%eax
f0103108:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010310b:	89 c1                	mov    %eax,%ecx
f010310d:	d3 ea                	shr    %cl,%edx
f010310f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0103113:	0b 55 ec             	or     -0x14(%ebp),%edx
f0103116:	d3 e6                	shl    %cl,%esi
f0103118:	89 c1                	mov    %eax,%ecx
f010311a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010311d:	89 fe                	mov    %edi,%esi
f010311f:	d3 ee                	shr    %cl,%esi
f0103121:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0103125:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0103128:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010312b:	d3 e7                	shl    %cl,%edi
f010312d:	89 c1                	mov    %eax,%ecx
f010312f:	d3 ea                	shr    %cl,%edx
f0103131:	09 d7                	or     %edx,%edi
f0103133:	89 f2                	mov    %esi,%edx
f0103135:	89 f8                	mov    %edi,%eax
f0103137:	f7 75 ec             	divl   -0x14(%ebp)
f010313a:	89 d6                	mov    %edx,%esi
f010313c:	89 c7                	mov    %eax,%edi
f010313e:	f7 65 e8             	mull   -0x18(%ebp)
f0103141:	39 d6                	cmp    %edx,%esi
f0103143:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0103146:	72 30                	jb     f0103178 <__udivdi3+0x118>
f0103148:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010314b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010314f:	d3 e2                	shl    %cl,%edx
f0103151:	39 c2                	cmp    %eax,%edx
f0103153:	73 05                	jae    f010315a <__udivdi3+0xfa>
f0103155:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0103158:	74 1e                	je     f0103178 <__udivdi3+0x118>
f010315a:	89 f9                	mov    %edi,%ecx
f010315c:	31 ff                	xor    %edi,%edi
f010315e:	e9 71 ff ff ff       	jmp    f01030d4 <__udivdi3+0x74>
f0103163:	90                   	nop
f0103164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103168:	31 ff                	xor    %edi,%edi
f010316a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010316f:	e9 60 ff ff ff       	jmp    f01030d4 <__udivdi3+0x74>
f0103174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103178:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010317b:	31 ff                	xor    %edi,%edi
f010317d:	89 c8                	mov    %ecx,%eax
f010317f:	89 fa                	mov    %edi,%edx
f0103181:	83 c4 10             	add    $0x10,%esp
f0103184:	5e                   	pop    %esi
f0103185:	5f                   	pop    %edi
f0103186:	5d                   	pop    %ebp
f0103187:	c3                   	ret    
	...

f0103190 <__umoddi3>:
f0103190:	55                   	push   %ebp
f0103191:	89 e5                	mov    %esp,%ebp
f0103193:	57                   	push   %edi
f0103194:	56                   	push   %esi
f0103195:	83 ec 20             	sub    $0x20,%esp
f0103198:	8b 55 14             	mov    0x14(%ebp),%edx
f010319b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010319e:	8b 7d 10             	mov    0x10(%ebp),%edi
f01031a1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01031a4:	85 d2                	test   %edx,%edx
f01031a6:	89 c8                	mov    %ecx,%eax
f01031a8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01031ab:	75 13                	jne    f01031c0 <__umoddi3+0x30>
f01031ad:	39 f7                	cmp    %esi,%edi
f01031af:	76 3f                	jbe    f01031f0 <__umoddi3+0x60>
f01031b1:	89 f2                	mov    %esi,%edx
f01031b3:	f7 f7                	div    %edi
f01031b5:	89 d0                	mov    %edx,%eax
f01031b7:	31 d2                	xor    %edx,%edx
f01031b9:	83 c4 20             	add    $0x20,%esp
f01031bc:	5e                   	pop    %esi
f01031bd:	5f                   	pop    %edi
f01031be:	5d                   	pop    %ebp
f01031bf:	c3                   	ret    
f01031c0:	39 f2                	cmp    %esi,%edx
f01031c2:	77 4c                	ja     f0103210 <__umoddi3+0x80>
f01031c4:	0f bd ca             	bsr    %edx,%ecx
f01031c7:	83 f1 1f             	xor    $0x1f,%ecx
f01031ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01031cd:	75 51                	jne    f0103220 <__umoddi3+0x90>
f01031cf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01031d2:	0f 87 e0 00 00 00    	ja     f01032b8 <__umoddi3+0x128>
f01031d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01031db:	29 f8                	sub    %edi,%eax
f01031dd:	19 d6                	sbb    %edx,%esi
f01031df:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01031e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01031e5:	89 f2                	mov    %esi,%edx
f01031e7:	83 c4 20             	add    $0x20,%esp
f01031ea:	5e                   	pop    %esi
f01031eb:	5f                   	pop    %edi
f01031ec:	5d                   	pop    %ebp
f01031ed:	c3                   	ret    
f01031ee:	66 90                	xchg   %ax,%ax
f01031f0:	85 ff                	test   %edi,%edi
f01031f2:	75 0b                	jne    f01031ff <__umoddi3+0x6f>
f01031f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01031f9:	31 d2                	xor    %edx,%edx
f01031fb:	f7 f7                	div    %edi
f01031fd:	89 c7                	mov    %eax,%edi
f01031ff:	89 f0                	mov    %esi,%eax
f0103201:	31 d2                	xor    %edx,%edx
f0103203:	f7 f7                	div    %edi
f0103205:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103208:	f7 f7                	div    %edi
f010320a:	eb a9                	jmp    f01031b5 <__umoddi3+0x25>
f010320c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103210:	89 c8                	mov    %ecx,%eax
f0103212:	89 f2                	mov    %esi,%edx
f0103214:	83 c4 20             	add    $0x20,%esp
f0103217:	5e                   	pop    %esi
f0103218:	5f                   	pop    %edi
f0103219:	5d                   	pop    %ebp
f010321a:	c3                   	ret    
f010321b:	90                   	nop
f010321c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103220:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103224:	d3 e2                	shl    %cl,%edx
f0103226:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0103229:	ba 20 00 00 00       	mov    $0x20,%edx
f010322e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0103231:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0103234:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103238:	89 fa                	mov    %edi,%edx
f010323a:	d3 ea                	shr    %cl,%edx
f010323c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103240:	0b 55 f4             	or     -0xc(%ebp),%edx
f0103243:	d3 e7                	shl    %cl,%edi
f0103245:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103249:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010324c:	89 f2                	mov    %esi,%edx
f010324e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0103251:	89 c7                	mov    %eax,%edi
f0103253:	d3 ea                	shr    %cl,%edx
f0103255:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103259:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010325c:	89 c2                	mov    %eax,%edx
f010325e:	d3 e6                	shl    %cl,%esi
f0103260:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103264:	d3 ea                	shr    %cl,%edx
f0103266:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010326a:	09 d6                	or     %edx,%esi
f010326c:	89 f0                	mov    %esi,%eax
f010326e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103271:	d3 e7                	shl    %cl,%edi
f0103273:	89 f2                	mov    %esi,%edx
f0103275:	f7 75 f4             	divl   -0xc(%ebp)
f0103278:	89 d6                	mov    %edx,%esi
f010327a:	f7 65 e8             	mull   -0x18(%ebp)
f010327d:	39 d6                	cmp    %edx,%esi
f010327f:	72 2b                	jb     f01032ac <__umoddi3+0x11c>
f0103281:	39 c7                	cmp    %eax,%edi
f0103283:	72 23                	jb     f01032a8 <__umoddi3+0x118>
f0103285:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103289:	29 c7                	sub    %eax,%edi
f010328b:	19 d6                	sbb    %edx,%esi
f010328d:	89 f0                	mov    %esi,%eax
f010328f:	89 f2                	mov    %esi,%edx
f0103291:	d3 ef                	shr    %cl,%edi
f0103293:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103297:	d3 e0                	shl    %cl,%eax
f0103299:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010329d:	09 f8                	or     %edi,%eax
f010329f:	d3 ea                	shr    %cl,%edx
f01032a1:	83 c4 20             	add    $0x20,%esp
f01032a4:	5e                   	pop    %esi
f01032a5:	5f                   	pop    %edi
f01032a6:	5d                   	pop    %ebp
f01032a7:	c3                   	ret    
f01032a8:	39 d6                	cmp    %edx,%esi
f01032aa:	75 d9                	jne    f0103285 <__umoddi3+0xf5>
f01032ac:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01032af:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01032b2:	eb d1                	jmp    f0103285 <__umoddi3+0xf5>
f01032b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01032b8:	39 f2                	cmp    %esi,%edx
f01032ba:	0f 82 18 ff ff ff    	jb     f01031d8 <__umoddi3+0x48>
f01032c0:	e9 1d ff ff ff       	jmp    f01031e2 <__umoddi3+0x52>
