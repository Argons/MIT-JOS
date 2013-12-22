
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
f0100015:	0f 01 15 18 90 11 00 	lgdtl  0x119018

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
f0100033:	bc bc 8f 11 f0       	mov    $0xf0118fbc,%esp

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
f0100054:	c7 04 24 60 4d 10 f0 	movl   $0xf0104d60,(%esp)
f010005b:	e8 b7 29 00 00       	call   f0102a17 <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 72 29 00 00       	call   f01029e4 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 e6 57 10 f0 	movl   $0xf01057e6,(%esp)
f0100079:	e8 99 29 00 00       	call   f0102a17 <cprintf>
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
f0100086:	83 3d c0 ac 1a f0 00 	cmpl   $0x0,0xf01aacc0
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 c0 ac 1a f0       	mov    %eax,0xf01aacc0

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 7a 4d 10 f0 	movl   $0xf0104d7a,(%esp)
f01000ac:	e8 66 29 00 00       	call   f0102a17 <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 21 29 00 00       	call   f01029e4 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 e6 57 10 f0 	movl   $0xf01057e6,(%esp)
f01000ca:	e8 48 29 00 00       	call   f0102a17 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 25 07 00 00       	call   f0100800 <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <i386_init>:
#include <kern/picirq.h>


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
f01000e3:	b8 d0 bb 1a f0       	mov    $0xf01abbd0,%eax
f01000e8:	2d b4 ac 1a f0       	sub    $0xf01aacb4,%eax
f01000ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000f8:	00 
f01000f9:	c7 04 24 b4 ac 1a f0 	movl   $0xf01aacb4,(%esp)
f0100100:	e8 d1 47 00 00       	call   f01048d6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100105:	e8 9d 03 00 00       	call   f01004a7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010010a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100111:	00 
f0100112:	c7 04 24 92 4d 10 f0 	movl   $0xf0104d92,(%esp)
f0100119:	e8 f9 28 00 00       	call   f0102a17 <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f010011e:	e8 7c 1f 00 00       	call   f010209f <i386_detect_memory>
	i386_vm_init();
f0100123:	e8 7e 1a 00 00       	call   f0101ba6 <i386_vm_init>
	page_init();
f0100128:	e8 12 0a 00 00       	call   f0100b3f <page_init>
	page_check();
f010012d:	8d 76 00             	lea    0x0(%esi),%esi
f0100130:	e8 5c 10 00 00       	call   f0101191 <page_check>

	// Lab 3 user environment initialization functions
	env_init();
f0100135:	e8 80 20 00 00       	call   f01021ba <env_init>
	idt_init();
f010013a:	e8 11 29 00 00       	call   f0102a50 <idt_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013f:	90                   	nop
f0100140:	e8 10 28 00 00       	call   f0102955 <pic_init>
	kclock_init();
f0100145:	e8 4a 27 00 00       	call   f0102894 <kclock_init>

	// Should always have an idle process as first one.  
	ENV_CREATE(user_idle);
f010014a:	c7 44 24 04 68 56 00 	movl   $0x5668,0x4(%esp)
f0100151:	00 
f0100152:	c7 04 24 64 93 11 f0 	movl   $0xf0119364,(%esp)
f0100159:	e8 c1 24 00 00       	call   f010261f <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE)
f010015e:	c7 44 24 04 0e 9b 00 	movl   $0x9b0e,0x4(%esp)
f0100165:	00 
f0100166:	c7 04 24 45 88 19 f0 	movl   $0xf0198845,(%esp)
f010016d:	e8 ad 24 00 00       	call   f010261f <env_create>

#endif // TEST*


	// Schedule and run the first user environment!
	sched_yield();
f0100172:	e8 29 34 00 00       	call   f01035a0 <sched_yield>
	...

f0100180 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100183:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100188:	ec                   	in     (%dx),%al
f0100189:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010018b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100190:	f6 c2 01             	test   $0x1,%dl
f0100193:	74 09                	je     f010019e <serial_proc_data+0x1e>
f0100195:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010019a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010019b:	0f b6 c0             	movzbl %al,%eax
}
f010019e:	5d                   	pop    %ebp
f010019f:	c3                   	ret    

f01001a0 <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp
f01001a3:	83 ec 0c             	sub    $0xc,%esp
f01001a6:	89 1c 24             	mov    %ebx,(%esp)
f01001a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01001ad:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01001b1:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01001b6:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01001b9:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01001be:	0f b7 00             	movzwl (%eax),%eax
f01001c1:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01001c5:	74 11                	je     f01001d8 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01001c7:	c7 05 e8 ac 1a f0 b4 	movl   $0x3b4,0xf01aace8
f01001ce:	03 00 00 
f01001d1:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01001d6:	eb 16                	jmp    f01001ee <cga_init+0x4e>
	} else {
		*cp = was;
f01001d8:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01001df:	c7 05 e8 ac 1a f0 d4 	movl   $0x3d4,0xf01aace8
f01001e6:	03 00 00 
f01001e9:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01001ee:	8b 0d e8 ac 1a f0    	mov    0xf01aace8,%ecx
f01001f4:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001f6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01001fb:	89 ca                	mov    %ecx,%edx
f01001fd:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01001fe:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100201:	89 ca                	mov    %ecx,%edx
f0100203:	ec                   	in     (%dx),%al
f0100204:	0f b6 f8             	movzbl %al,%edi
f0100207:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010020a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010020f:	89 da                	mov    %ebx,%edx
f0100211:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100212:	89 ca                	mov    %ecx,%edx
f0100214:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100215:	89 35 ec ac 1a f0    	mov    %esi,0xf01aacec
	crt_pos = pos;
f010021b:	0f b6 c8             	movzbl %al,%ecx
f010021e:	09 cf                	or     %ecx,%edi
f0100220:	66 89 3d f0 ac 1a f0 	mov    %di,0xf01aacf0
}
f0100227:	8b 1c 24             	mov    (%esp),%ebx
f010022a:	8b 74 24 04          	mov    0x4(%esp),%esi
f010022e:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0100232:	89 ec                	mov    %ebp,%esp
f0100234:	5d                   	pop    %ebp
f0100235:	c3                   	ret    

f0100236 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f0100236:	55                   	push   %ebp
f0100237:	89 e5                	mov    %esp,%ebp
f0100239:	57                   	push   %edi
f010023a:	56                   	push   %esi
f010023b:	53                   	push   %ebx
f010023c:	83 ec 0c             	sub    $0xc,%esp
f010023f:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100242:	bb 04 af 1a f0       	mov    $0xf01aaf04,%ebx
f0100247:	bf 00 ad 1a f0       	mov    $0xf01aad00,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010024c:	eb 1b                	jmp    f0100269 <cons_intr+0x33>
		if (c == 0)
f010024e:	85 c0                	test   %eax,%eax
f0100250:	74 17                	je     f0100269 <cons_intr+0x33>
			continue;
		cons.buf[cons.wpos++] = c;
f0100252:	8b 13                	mov    (%ebx),%edx
f0100254:	88 04 3a             	mov    %al,(%edx,%edi,1)
f0100257:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010025a:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010025f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100264:	0f 44 c2             	cmove  %edx,%eax
f0100267:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100269:	ff d6                	call   *%esi
f010026b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010026e:	75 de                	jne    f010024e <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100270:	83 c4 0c             	add    $0xc,%esp
f0100273:	5b                   	pop    %ebx
f0100274:	5e                   	pop    %esi
f0100275:	5f                   	pop    %edi
f0100276:	5d                   	pop    %ebp
f0100277:	c3                   	ret    

f0100278 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100278:	55                   	push   %ebp
f0100279:	89 e5                	mov    %esp,%ebp
f010027b:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f010027e:	c7 04 24 07 03 10 f0 	movl   $0xf0100307,(%esp)
f0100285:	e8 ac ff ff ff       	call   f0100236 <cons_intr>
}
f010028a:	c9                   	leave  
f010028b:	c3                   	ret    

f010028c <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010028c:	55                   	push   %ebp
f010028d:	89 e5                	mov    %esp,%ebp
f010028f:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100292:	83 3d e4 ac 1a f0 00 	cmpl   $0x0,0xf01aace4
f0100299:	74 0c                	je     f01002a7 <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f010029b:	c7 04 24 80 01 10 f0 	movl   $0xf0100180,(%esp)
f01002a2:	e8 8f ff ff ff       	call   f0100236 <cons_intr>
}
f01002a7:	c9                   	leave  
f01002a8:	c3                   	ret    

f01002a9 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01002a9:	55                   	push   %ebp
f01002aa:	89 e5                	mov    %esp,%ebp
f01002ac:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01002af:	e8 d8 ff ff ff       	call   f010028c <serial_intr>
	kbd_intr();
f01002b4:	e8 bf ff ff ff       	call   f0100278 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01002b9:	8b 15 00 af 1a f0    	mov    0xf01aaf00,%edx
f01002bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01002c4:	3b 15 04 af 1a f0    	cmp    0xf01aaf04,%edx
f01002ca:	74 1e                	je     f01002ea <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01002cc:	0f b6 82 00 ad 1a f0 	movzbl -0xfe55300(%edx),%eax
f01002d3:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01002d6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01002e1:	0f 44 d1             	cmove  %ecx,%edx
f01002e4:	89 15 00 af 1a f0    	mov    %edx,0xf01aaf00
		return c;
	}
	return 0;
}
f01002ea:	c9                   	leave  
f01002eb:	c3                   	ret    

f01002ec <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01002f2:	e8 b2 ff ff ff       	call   f01002a9 <cons_getc>
f01002f7:	85 c0                	test   %eax,%eax
f01002f9:	74 f7                	je     f01002f2 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01002fb:	c9                   	leave  
f01002fc:	c3                   	ret    

f01002fd <iscons>:

int
iscons(int fdnum)
{
f01002fd:	55                   	push   %ebp
f01002fe:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100300:	b8 01 00 00 00       	mov    $0x1,%eax
f0100305:	5d                   	pop    %ebp
f0100306:	c3                   	ret    

f0100307 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100307:	55                   	push   %ebp
f0100308:	89 e5                	mov    %esp,%ebp
f010030a:	53                   	push   %ebx
f010030b:	83 ec 14             	sub    $0x14,%esp
f010030e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100313:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100314:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100319:	a8 01                	test   $0x1,%al
f010031b:	0f 84 dd 00 00 00    	je     f01003fe <kbd_proc_data+0xf7>
f0100321:	b2 60                	mov    $0x60,%dl
f0100323:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100324:	3c e0                	cmp    $0xe0,%al
f0100326:	75 11                	jne    f0100339 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100328:	83 0d e0 ac 1a f0 40 	orl    $0x40,0xf01aace0
f010032f:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100334:	e9 c5 00 00 00       	jmp    f01003fe <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f0100339:	84 c0                	test   %al,%al
f010033b:	79 35                	jns    f0100372 <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010033d:	8b 15 e0 ac 1a f0    	mov    0xf01aace0,%edx
f0100343:	89 c1                	mov    %eax,%ecx
f0100345:	83 e1 7f             	and    $0x7f,%ecx
f0100348:	f6 c2 40             	test   $0x40,%dl
f010034b:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010034e:	0f b6 c0             	movzbl %al,%eax
f0100351:	0f b6 80 e0 4d 10 f0 	movzbl -0xfefb220(%eax),%eax
f0100358:	83 c8 40             	or     $0x40,%eax
f010035b:	0f b6 c0             	movzbl %al,%eax
f010035e:	f7 d0                	not    %eax
f0100360:	21 c2                	and    %eax,%edx
f0100362:	89 15 e0 ac 1a f0    	mov    %edx,0xf01aace0
f0100368:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010036d:	e9 8c 00 00 00       	jmp    f01003fe <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f0100372:	8b 15 e0 ac 1a f0    	mov    0xf01aace0,%edx
f0100378:	f6 c2 40             	test   $0x40,%dl
f010037b:	74 0c                	je     f0100389 <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010037d:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100380:	83 e2 bf             	and    $0xffffffbf,%edx
f0100383:	89 15 e0 ac 1a f0    	mov    %edx,0xf01aace0
	}

	shift |= shiftcode[data];
f0100389:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010038c:	0f b6 90 e0 4d 10 f0 	movzbl -0xfefb220(%eax),%edx
f0100393:	0b 15 e0 ac 1a f0    	or     0xf01aace0,%edx
f0100399:	0f b6 88 e0 4e 10 f0 	movzbl -0xfefb120(%eax),%ecx
f01003a0:	31 ca                	xor    %ecx,%edx
f01003a2:	89 15 e0 ac 1a f0    	mov    %edx,0xf01aace0

	c = charcode[shift & (CTL | SHIFT)][data];
f01003a8:	89 d1                	mov    %edx,%ecx
f01003aa:	83 e1 03             	and    $0x3,%ecx
f01003ad:	8b 0c 8d e0 4f 10 f0 	mov    -0xfefb020(,%ecx,4),%ecx
f01003b4:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01003b8:	f6 c2 08             	test   $0x8,%dl
f01003bb:	74 1b                	je     f01003d8 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01003bd:	89 d9                	mov    %ebx,%ecx
f01003bf:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01003c2:	83 f8 19             	cmp    $0x19,%eax
f01003c5:	77 05                	ja     f01003cc <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01003c7:	83 eb 20             	sub    $0x20,%ebx
f01003ca:	eb 0c                	jmp    f01003d8 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01003cc:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f01003cf:	8d 43 20             	lea    0x20(%ebx),%eax
f01003d2:	83 f9 19             	cmp    $0x19,%ecx
f01003d5:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003d8:	f7 d2                	not    %edx
f01003da:	f6 c2 06             	test   $0x6,%dl
f01003dd:	75 1f                	jne    f01003fe <kbd_proc_data+0xf7>
f01003df:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003e5:	75 17                	jne    f01003fe <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f01003e7:	c7 04 24 ad 4d 10 f0 	movl   $0xf0104dad,(%esp)
f01003ee:	e8 24 26 00 00       	call   f0102a17 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f3:	ba 92 00 00 00       	mov    $0x92,%edx
f01003f8:	b8 03 00 00 00       	mov    $0x3,%eax
f01003fd:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003fe:	89 d8                	mov    %ebx,%eax
f0100400:	83 c4 14             	add    $0x14,%esp
f0100403:	5b                   	pop    %ebx
f0100404:	5d                   	pop    %ebp
f0100405:	c3                   	ret    

f0100406 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f0100406:	55                   	push   %ebp
f0100407:	89 e5                	mov    %esp,%ebp
f0100409:	83 ec 18             	sub    $0x18,%esp
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f010040c:	e8 67 fe ff ff       	call   f0100278 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100411:	0f b7 05 58 93 11 f0 	movzwl 0xf0119358,%eax
f0100418:	25 fd ff 00 00       	and    $0xfffd,%eax
f010041d:	89 04 24             	mov    %eax,(%esp)
f0100420:	e8 bf 24 00 00       	call   f01028e4 <irq_setmask_8259A>
}
f0100425:	c9                   	leave  
f0100426:	c3                   	ret    

f0100427 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f0100427:	55                   	push   %ebp
f0100428:	89 e5                	mov    %esp,%ebp
f010042a:	56                   	push   %esi
f010042b:	53                   	push   %ebx
f010042c:	83 ec 10             	sub    $0x10,%esp
f010042f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100434:	b8 00 00 00 00       	mov    $0x0,%eax
f0100439:	89 da                	mov    %ebx,%edx
f010043b:	ee                   	out    %al,(%dx)
f010043c:	b2 fb                	mov    $0xfb,%dl
f010043e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100443:	ee                   	out    %al,(%dx)
f0100444:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100449:	b8 0c 00 00 00       	mov    $0xc,%eax
f010044e:	89 ca                	mov    %ecx,%edx
f0100450:	ee                   	out    %al,(%dx)
f0100451:	b2 f9                	mov    $0xf9,%dl
f0100453:	b8 00 00 00 00       	mov    $0x0,%eax
f0100458:	ee                   	out    %al,(%dx)
f0100459:	b2 fb                	mov    $0xfb,%dl
f010045b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100460:	ee                   	out    %al,(%dx)
f0100461:	b2 fc                	mov    $0xfc,%dl
f0100463:	b8 00 00 00 00       	mov    $0x0,%eax
f0100468:	ee                   	out    %al,(%dx)
f0100469:	b2 f9                	mov    $0xf9,%dl
f010046b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100470:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100471:	b2 fd                	mov    $0xfd,%dl
f0100473:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100474:	3c ff                	cmp    $0xff,%al
f0100476:	0f 95 c0             	setne  %al
f0100479:	0f b6 f0             	movzbl %al,%esi
f010047c:	89 35 e4 ac 1a f0    	mov    %esi,0xf01aace4
f0100482:	89 da                	mov    %ebx,%edx
f0100484:	ec                   	in     (%dx),%al
f0100485:	89 ca                	mov    %ecx,%edx
f0100487:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100488:	85 f6                	test   %esi,%esi
f010048a:	74 14                	je     f01004a0 <serial_init+0x79>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f010048c:	0f b7 05 58 93 11 f0 	movzwl 0xf0119358,%eax
f0100493:	25 ef ff 00 00       	and    $0xffef,%eax
f0100498:	89 04 24             	mov    %eax,(%esp)
f010049b:	e8 44 24 00 00       	call   f01028e4 <irq_setmask_8259A>
}
f01004a0:	83 c4 10             	add    $0x10,%esp
f01004a3:	5b                   	pop    %ebx
f01004a4:	5e                   	pop    %esi
f01004a5:	5d                   	pop    %ebp
f01004a6:	c3                   	ret    

f01004a7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004a7:	55                   	push   %ebp
f01004a8:	89 e5                	mov    %esp,%ebp
f01004aa:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f01004ad:	e8 ee fc ff ff       	call   f01001a0 <cga_init>
	kbd_init();
f01004b2:	e8 4f ff ff ff       	call   f0100406 <kbd_init>
	serial_init();
f01004b7:	e8 6b ff ff ff       	call   f0100427 <serial_init>

	if (!serial_exists)
f01004bc:	83 3d e4 ac 1a f0 00 	cmpl   $0x0,0xf01aace4
f01004c3:	75 0c                	jne    f01004d1 <cons_init+0x2a>
		cprintf("Serial port does not exist!\n");
f01004c5:	c7 04 24 b9 4d 10 f0 	movl   $0xf0104db9,(%esp)
f01004cc:	e8 46 25 00 00       	call   f0102a17 <cprintf>
}
f01004d1:	c9                   	leave  
f01004d2:	c3                   	ret    

f01004d3 <cga_putc>:



void
cga_putc(int c)
{
f01004d3:	55                   	push   %ebp
f01004d4:	89 e5                	mov    %esp,%ebp
f01004d6:	56                   	push   %esi
f01004d7:	53                   	push   %ebx
f01004d8:	83 ec 10             	sub    $0x10,%esp
f01004db:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f01004de:	89 c2                	mov    %eax,%edx
f01004e0:	80 ce 07             	or     $0x7,%dh
f01004e3:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01004e8:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f01004eb:	0f b6 d0             	movzbl %al,%edx
f01004ee:	83 fa 09             	cmp    $0x9,%edx
f01004f1:	0f 84 86 00 00 00    	je     f010057d <cga_putc+0xaa>
f01004f7:	83 fa 09             	cmp    $0x9,%edx
f01004fa:	7f 0e                	jg     f010050a <cga_putc+0x37>
f01004fc:	83 fa 08             	cmp    $0x8,%edx
f01004ff:	0f 85 b6 00 00 00    	jne    f01005bb <cga_putc+0xe8>
f0100505:	8d 76 00             	lea    0x0(%esi),%esi
f0100508:	eb 18                	jmp    f0100522 <cga_putc+0x4f>
f010050a:	83 fa 0a             	cmp    $0xa,%edx
f010050d:	8d 76 00             	lea    0x0(%esi),%esi
f0100510:	74 41                	je     f0100553 <cga_putc+0x80>
f0100512:	83 fa 0d             	cmp    $0xd,%edx
f0100515:	8d 76 00             	lea    0x0(%esi),%esi
f0100518:	0f 85 9d 00 00 00    	jne    f01005bb <cga_putc+0xe8>
f010051e:	66 90                	xchg   %ax,%ax
f0100520:	eb 39                	jmp    f010055b <cga_putc+0x88>
	case '\b':
		if (crt_pos > 0) {
f0100522:	0f b7 15 f0 ac 1a f0 	movzwl 0xf01aacf0,%edx
f0100529:	66 85 d2             	test   %dx,%dx
f010052c:	0f 84 f4 00 00 00    	je     f0100626 <cga_putc+0x153>
			crt_pos--;
f0100532:	83 ea 01             	sub    $0x1,%edx
f0100535:	66 89 15 f0 ac 1a f0 	mov    %dx,0xf01aacf0
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010053c:	0f b7 d2             	movzwl %dx,%edx
f010053f:	b0 00                	mov    $0x0,%al
f0100541:	83 c8 20             	or     $0x20,%eax
f0100544:	8b 0d ec ac 1a f0    	mov    0xf01aacec,%ecx
f010054a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010054e:	e9 86 00 00 00       	jmp    f01005d9 <cga_putc+0x106>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100553:	66 83 05 f0 ac 1a f0 	addw   $0x50,0xf01aacf0
f010055a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010055b:	0f b7 05 f0 ac 1a f0 	movzwl 0xf01aacf0,%eax
f0100562:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100568:	c1 e8 10             	shr    $0x10,%eax
f010056b:	66 c1 e8 06          	shr    $0x6,%ax
f010056f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100572:	c1 e0 04             	shl    $0x4,%eax
f0100575:	66 a3 f0 ac 1a f0    	mov    %ax,0xf01aacf0
		break;
f010057b:	eb 5c                	jmp    f01005d9 <cga_putc+0x106>
	case '\t':
		cons_putc(' ');
f010057d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100584:	e8 d4 00 00 00       	call   f010065d <cons_putc>
		cons_putc(' ');
f0100589:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100590:	e8 c8 00 00 00       	call   f010065d <cons_putc>
		cons_putc(' ');
f0100595:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010059c:	e8 bc 00 00 00       	call   f010065d <cons_putc>
		cons_putc(' ');
f01005a1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005a8:	e8 b0 00 00 00       	call   f010065d <cons_putc>
		cons_putc(' ');
f01005ad:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005b4:	e8 a4 00 00 00       	call   f010065d <cons_putc>
		break;
f01005b9:	eb 1e                	jmp    f01005d9 <cga_putc+0x106>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005bb:	0f b7 15 f0 ac 1a f0 	movzwl 0xf01aacf0,%edx
f01005c2:	0f b7 da             	movzwl %dx,%ebx
f01005c5:	8b 0d ec ac 1a f0    	mov    0xf01aacec,%ecx
f01005cb:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005cf:	83 c2 01             	add    $0x1,%edx
f01005d2:	66 89 15 f0 ac 1a f0 	mov    %dx,0xf01aacf0
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005d9:	66 81 3d f0 ac 1a f0 	cmpw   $0x7cf,0xf01aacf0
f01005e0:	cf 07 
f01005e2:	76 42                	jbe    f0100626 <cga_putc+0x153>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005e4:	a1 ec ac 1a f0       	mov    0xf01aacec,%eax
f01005e9:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005f0:	00 
f01005f1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005fb:	89 04 24             	mov    %eax,(%esp)
f01005fe:	e8 f7 42 00 00       	call   f01048fa <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100603:	8b 15 ec ac 1a f0    	mov    0xf01aacec,%edx
f0100609:	b8 80 07 00 00       	mov    $0x780,%eax
f010060e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100614:	83 c0 01             	add    $0x1,%eax
f0100617:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010061c:	75 f0                	jne    f010060e <cga_putc+0x13b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010061e:	66 83 2d f0 ac 1a f0 	subw   $0x50,0xf01aacf0
f0100625:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100626:	8b 0d e8 ac 1a f0    	mov    0xf01aace8,%ecx
f010062c:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010062e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100633:	89 ca                	mov    %ecx,%edx
f0100635:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100636:	0f b7 35 f0 ac 1a f0 	movzwl 0xf01aacf0,%esi
f010063d:	83 c1 01             	add    $0x1,%ecx
f0100640:	89 f0                	mov    %esi,%eax
f0100642:	66 c1 e8 08          	shr    $0x8,%ax
f0100646:	89 ca                	mov    %ecx,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	b8 0f 00 00 00       	mov    $0xf,%eax
f010064e:	89 da                	mov    %ebx,%edx
f0100650:	ee                   	out    %al,(%dx)
f0100651:	89 f0                	mov    %esi,%eax
f0100653:	89 ca                	mov    %ecx,%edx
f0100655:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100656:	83 c4 10             	add    $0x10,%esp
f0100659:	5b                   	pop    %ebx
f010065a:	5e                   	pop    %esi
f010065b:	5d                   	pop    %ebp
f010065c:	c3                   	ret    

f010065d <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f010065d:	55                   	push   %ebp
f010065e:	89 e5                	mov    %esp,%ebp
f0100660:	57                   	push   %edi
f0100661:	56                   	push   %esi
f0100662:	53                   	push   %ebx
f0100663:	83 ec 1c             	sub    $0x1c,%esp
f0100666:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100669:	ba 79 03 00 00       	mov    $0x379,%edx
f010066e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010066f:	84 c0                	test   %al,%al
f0100671:	78 27                	js     f010069a <cons_putc+0x3d>
f0100673:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100678:	b9 84 00 00 00       	mov    $0x84,%ecx
f010067d:	be 79 03 00 00       	mov    $0x379,%esi
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ec                   	in     (%dx),%al
f0100685:	ec                   	in     (%dx),%al
f0100686:	ec                   	in     (%dx),%al
f0100687:	ec                   	in     (%dx),%al
f0100688:	89 f2                	mov    %esi,%edx
f010068a:	ec                   	in     (%dx),%al
f010068b:	84 c0                	test   %al,%al
f010068d:	78 0b                	js     f010069a <cons_putc+0x3d>
f010068f:	83 c3 01             	add    $0x1,%ebx
f0100692:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100698:	75 e8                	jne    f0100682 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010069a:	ba 78 03 00 00       	mov    $0x378,%edx
f010069f:	89 f8                	mov    %edi,%eax
f01006a1:	ee                   	out    %al,(%dx)
f01006a2:	b2 7a                	mov    $0x7a,%dl
f01006a4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01006a9:	ee                   	out    %al,(%dx)
f01006aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01006af:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f01006b0:	89 3c 24             	mov    %edi,(%esp)
f01006b3:	e8 1b fe ff ff       	call   f01004d3 <cga_putc>
}
f01006b8:	83 c4 1c             	add    $0x1c,%esp
f01006bb:	5b                   	pop    %ebx
f01006bc:	5e                   	pop    %esi
f01006bd:	5f                   	pop    %edi
f01006be:	5d                   	pop    %ebp
f01006bf:	c3                   	ret    

f01006c0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
f01006c3:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006c9:	89 04 24             	mov    %eax,(%esp)
f01006cc:	e8 8c ff ff ff       	call   f010065d <cons_putc>
}
f01006d1:	c9                   	leave  
f01006d2:	c3                   	ret    
	...

f01006e0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006e0:	55                   	push   %ebp
f01006e1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006e3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006e6:	5d                   	pop    %ebp
f01006e7:	c3                   	ret    

f01006e8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006e8:	55                   	push   %ebp
f01006e9:	89 e5                	mov    %esp,%ebp
f01006eb:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006ee:	c7 04 24 f0 4f 10 f0 	movl   $0xf0104ff0,(%esp)
f01006f5:	e8 1d 23 00 00       	call   f0102a17 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01006fa:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100701:	00 
f0100702:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100709:	f0 
f010070a:	c7 04 24 b4 50 10 f0 	movl   $0xf01050b4,(%esp)
f0100711:	e8 01 23 00 00       	call   f0102a17 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100716:	c7 44 24 08 55 4d 10 	movl   $0x104d55,0x8(%esp)
f010071d:	00 
f010071e:	c7 44 24 04 55 4d 10 	movl   $0xf0104d55,0x4(%esp)
f0100725:	f0 
f0100726:	c7 04 24 d8 50 10 f0 	movl   $0xf01050d8,(%esp)
f010072d:	e8 e5 22 00 00       	call   f0102a17 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100732:	c7 44 24 08 b4 ac 1a 	movl   $0x1aacb4,0x8(%esp)
f0100739:	00 
f010073a:	c7 44 24 04 b4 ac 1a 	movl   $0xf01aacb4,0x4(%esp)
f0100741:	f0 
f0100742:	c7 04 24 fc 50 10 f0 	movl   $0xf01050fc,(%esp)
f0100749:	e8 c9 22 00 00       	call   f0102a17 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010074e:	c7 44 24 08 d0 bb 1a 	movl   $0x1abbd0,0x8(%esp)
f0100755:	00 
f0100756:	c7 44 24 04 d0 bb 1a 	movl   $0xf01abbd0,0x4(%esp)
f010075d:	f0 
f010075e:	c7 04 24 20 51 10 f0 	movl   $0xf0105120,(%esp)
f0100765:	e8 ad 22 00 00       	call   f0102a17 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010076a:	b8 cf bf 1a f0       	mov    $0xf01abfcf,%eax
f010076f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100774:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010077a:	85 c0                	test   %eax,%eax
f010077c:	0f 48 c2             	cmovs  %edx,%eax
f010077f:	c1 f8 0a             	sar    $0xa,%eax
f0100782:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100786:	c7 04 24 44 51 10 f0 	movl   $0xf0105144,(%esp)
f010078d:	e8 85 22 00 00       	call   f0102a17 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f0100792:	b8 00 00 00 00       	mov    $0x0,%eax
f0100797:	c9                   	leave  
f0100798:	c3                   	ret    

f0100799 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100799:	55                   	push   %ebp
f010079a:	89 e5                	mov    %esp,%ebp
f010079c:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079f:	a1 24 52 10 f0       	mov    0xf0105224,%eax
f01007a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007a8:	a1 20 52 10 f0       	mov    0xf0105220,%eax
f01007ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007b1:	c7 04 24 09 50 10 f0 	movl   $0xf0105009,(%esp)
f01007b8:	e8 5a 22 00 00       	call   f0102a17 <cprintf>
f01007bd:	a1 30 52 10 f0       	mov    0xf0105230,%eax
f01007c2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007c6:	a1 2c 52 10 f0       	mov    0xf010522c,%eax
f01007cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007cf:	c7 04 24 09 50 10 f0 	movl   $0xf0105009,(%esp)
f01007d6:	e8 3c 22 00 00       	call   f0102a17 <cprintf>
f01007db:	a1 3c 52 10 f0       	mov    0xf010523c,%eax
f01007e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007e4:	a1 38 52 10 f0       	mov    0xf0105238,%eax
f01007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ed:	c7 04 24 09 50 10 f0 	movl   $0xf0105009,(%esp)
f01007f4:	e8 1e 22 00 00       	call   f0102a17 <cprintf>
	return 0;
}
f01007f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fe:	c9                   	leave  
f01007ff:	c3                   	ret    

f0100800 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100800:	55                   	push   %ebp
f0100801:	89 e5                	mov    %esp,%ebp
f0100803:	57                   	push   %edi
f0100804:	56                   	push   %esi
f0100805:	53                   	push   %ebx
f0100806:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100809:	c7 04 24 70 51 10 f0 	movl   $0xf0105170,(%esp)
f0100810:	e8 02 22 00 00       	call   f0102a17 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100815:	c7 04 24 94 51 10 f0 	movl   $0xf0105194,(%esp)
f010081c:	e8 f6 21 00 00       	call   f0102a17 <cprintf>

	if (tf != NULL)
f0100821:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100825:	74 0b                	je     f0100832 <monitor+0x32>
		print_trapframe(tf);
f0100827:	8b 45 08             	mov    0x8(%ebp),%eax
f010082a:	89 04 24             	mov    %eax,(%esp)
f010082d:	e8 02 29 00 00       	call   f0103134 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100832:	c7 04 24 12 50 10 f0 	movl   $0xf0105012,(%esp)
f0100839:	e8 22 3e 00 00       	call   f0104660 <readline>
f010083e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100840:	85 c0                	test   %eax,%eax
f0100842:	74 ee                	je     f0100832 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100844:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010084b:	be 00 00 00 00       	mov    $0x0,%esi
f0100850:	eb 06                	jmp    f0100858 <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100852:	c6 03 00             	movb   $0x0,(%ebx)
f0100855:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100858:	0f b6 03             	movzbl (%ebx),%eax
f010085b:	84 c0                	test   %al,%al
f010085d:	74 6c                	je     f01008cb <monitor+0xcb>
f010085f:	0f be c0             	movsbl %al,%eax
f0100862:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100866:	c7 04 24 16 50 10 f0 	movl   $0xf0105016,(%esp)
f010086d:	e8 0c 40 00 00       	call   f010487e <strchr>
f0100872:	85 c0                	test   %eax,%eax
f0100874:	75 dc                	jne    f0100852 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100876:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100879:	74 50                	je     f01008cb <monitor+0xcb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010087b:	83 fe 0f             	cmp    $0xf,%esi
f010087e:	66 90                	xchg   %ax,%ax
f0100880:	75 16                	jne    f0100898 <monitor+0x98>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100882:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100889:	00 
f010088a:	c7 04 24 1b 50 10 f0 	movl   $0xf010501b,(%esp)
f0100891:	e8 81 21 00 00       	call   f0102a17 <cprintf>
f0100896:	eb 9a                	jmp    f0100832 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100898:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010089c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010089f:	0f b6 03             	movzbl (%ebx),%eax
f01008a2:	84 c0                	test   %al,%al
f01008a4:	75 0c                	jne    f01008b2 <monitor+0xb2>
f01008a6:	eb b0                	jmp    f0100858 <monitor+0x58>
			buf++;
f01008a8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ab:	0f b6 03             	movzbl (%ebx),%eax
f01008ae:	84 c0                	test   %al,%al
f01008b0:	74 a6                	je     f0100858 <monitor+0x58>
f01008b2:	0f be c0             	movsbl %al,%eax
f01008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b9:	c7 04 24 16 50 10 f0 	movl   $0xf0105016,(%esp)
f01008c0:	e8 b9 3f 00 00       	call   f010487e <strchr>
f01008c5:	85 c0                	test   %eax,%eax
f01008c7:	74 df                	je     f01008a8 <monitor+0xa8>
f01008c9:	eb 8d                	jmp    f0100858 <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f01008cb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008d2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008d3:	85 f6                	test   %esi,%esi
f01008d5:	0f 84 57 ff ff ff    	je     f0100832 <monitor+0x32>
f01008db:	bb 20 52 10 f0       	mov    $0xf0105220,%ebx
f01008e0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e5:	8b 03                	mov    (%ebx),%eax
f01008e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008eb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ee:	89 04 24             	mov    %eax,(%esp)
f01008f1:	e8 13 3f 00 00       	call   f0104809 <strcmp>
f01008f6:	85 c0                	test   %eax,%eax
f01008f8:	75 23                	jne    f010091d <monitor+0x11d>
			return commands[i].func(argc, argv, tf);
f01008fa:	6b ff 0c             	imul   $0xc,%edi,%edi
f01008fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0100900:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100904:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100907:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090b:	89 34 24             	mov    %esi,(%esp)
f010090e:	ff 97 28 52 10 f0    	call   *-0xfefadd8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100914:	85 c0                	test   %eax,%eax
f0100916:	78 28                	js     f0100940 <monitor+0x140>
f0100918:	e9 15 ff ff ff       	jmp    f0100832 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010091d:	83 c7 01             	add    $0x1,%edi
f0100920:	83 c3 0c             	add    $0xc,%ebx
f0100923:	83 ff 03             	cmp    $0x3,%edi
f0100926:	75 bd                	jne    f01008e5 <monitor+0xe5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100928:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010092b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010092f:	c7 04 24 38 50 10 f0 	movl   $0xf0105038,(%esp)
f0100936:	e8 dc 20 00 00       	call   f0102a17 <cprintf>
f010093b:	e9 f2 fe ff ff       	jmp    f0100832 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100940:	83 c4 5c             	add    $0x5c,%esp
f0100943:	5b                   	pop    %ebx
f0100944:	5e                   	pop    %esi
f0100945:	5f                   	pop    %edi
f0100946:	5d                   	pop    %ebp
f0100947:	c3                   	ret    

f0100948 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100948:	55                   	push   %ebp
f0100949:	89 e5                	mov    %esp,%ebp
f010094b:	57                   	push   %edi
f010094c:	56                   	push   %esi
f010094d:	53                   	push   %ebx
f010094e:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
	cprintf("Stack backtrace:\n");
f0100951:	c7 04 24 4e 50 10 f0 	movl   $0xf010504e,(%esp)
f0100958:	e8 ba 20 00 00       	call   f0102a17 <cprintf>

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010095d:	89 ee                	mov    %ebp,%esi
	struct Eipdebuginfo info;
        uint32_t ebp = read_ebp();
	uint32_t eip = *(uint32_t *)(ebp + 4);
f010095f:	8b 7e 04             	mov    0x4(%esi),%edi
        do{
		debuginfo_eip(eip, &info);
f0100962:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100965:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100969:	89 3c 24             	mov    %edi,(%esp)
f010096c:	e8 5d 34 00 00       	call   f0103dce <debuginfo_eip>
		int i;
		cprintf("%s:%d:",info.eip_file,info.eip_line);
f0100971:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100974:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100978:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010097b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010097f:	c7 04 24 60 50 10 f0 	movl   $0xf0105060,(%esp)
f0100986:	e8 8c 20 00 00       	call   f0102a17 <cprintf>
		for(i=0; i<info.eip_fn_namelen; i++)
f010098b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010098f:	7e 24                	jle    f01009b5 <mon_backtrace+0x6d>
f0100991:	bb 00 00 00 00       	mov    $0x0,%ebx
		 	cprintf("%c", info.eip_fn_name[i]);
f0100996:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100999:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f010099d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a1:	c7 04 24 67 50 10 f0 	movl   $0xf0105067,(%esp)
f01009a8:	e8 6a 20 00 00       	call   f0102a17 <cprintf>
	uint32_t eip = *(uint32_t *)(ebp + 4);
        do{
		debuginfo_eip(eip, &info);
		int i;
		cprintf("%s:%d:",info.eip_file,info.eip_line);
		for(i=0; i<info.eip_fn_namelen; i++)
f01009ad:	83 c3 01             	add    $0x1,%ebx
f01009b0:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01009b3:	7f e1                	jg     f0100996 <mon_backtrace+0x4e>
		 	cprintf("%c", info.eip_fn_name[i]);
		cprintf("+%x\n",eip-info.eip_fn_addr);
f01009b5:	89 f8                	mov    %edi,%eax
f01009b7:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01009ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009be:	c7 04 24 6a 50 10 f0 	movl   $0xf010506a,(%esp)
f01009c5:	e8 4d 20 00 00       	call   f0102a17 <cprintf>

                cprintf("    ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", 
f01009ca:	8b 46 18             	mov    0x18(%esi),%eax
f01009cd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01009d1:	8b 46 14             	mov    0x14(%esi),%eax
f01009d4:	89 44 24 18          	mov    %eax,0x18(%esp)
f01009d8:	8b 46 10             	mov    0x10(%esi),%eax
f01009db:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009df:	8b 46 0c             	mov    0xc(%esi),%eax
f01009e2:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009e6:	8b 46 08             	mov    0x8(%esi),%eax
f01009e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009ed:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009f1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009f5:	c7 04 24 bc 51 10 f0 	movl   $0xf01051bc,(%esp)
f01009fc:	e8 16 20 00 00       	call   f0102a17 <cprintf>
                ebp, eip,*(uint32_t *)(ebp + 8), 
                         *(uint32_t *)(ebp + 12), 
                         *(uint32_t *)(ebp + 16), 
                         *(uint32_t *)(ebp + 20), 
                         *(uint32_t *)(ebp + 24));
                ebp = *(uint32_t *) ebp;  // get caller
f0100a01:	8b 36                	mov    (%esi),%esi
		eip = *(uint32_t *)(ebp + 4);
f0100a03:	8b 7e 04             	mov    0x4(%esi),%edi
        }while(ebp != 0);
f0100a06:	85 f6                	test   %esi,%esi
f0100a08:	0f 85 54 ff ff ff    	jne    f0100962 <mon_backtrace+0x1a>
	return 0;
}
f0100a0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a13:	83 c4 4c             	add    $0x4c,%esp
f0100a16:	5b                   	pop    %ebx
f0100a17:	5e                   	pop    %esi
f0100a18:	5f                   	pop    %edi
f0100a19:	5d                   	pop    %ebp
f0100a1a:	c3                   	ret    
f0100a1b:	00 00                	add    %al,(%eax)
f0100a1d:	00 00                	add    %al,(%eax)
	...

f0100a20 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0100a20:	55                   	push   %ebp
f0100a21:	89 e5                	mov    %esp,%ebp
f0100a23:	83 ec 0c             	sub    $0xc,%esp
f0100a26:	89 1c 24             	mov    %ebx,(%esp)
f0100a29:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a2d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a31:	89 c3                	mov    %eax,%ebx
f0100a33:	89 d7                	mov    %edx,%edi
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
		boot_freemem = end;
f0100a35:	83 3d 14 af 1a f0 00 	cmpl   $0x0,0xf01aaf14

	// LAB 2: Your code here:

	//	Step 1: round boot_freemem up to be aligned properly
        boot_freemem = ROUNDUP( boot_freemem, align );
f0100a3c:	b8 d0 bb 1a f0       	mov    $0xf01abbd0,%eax
f0100a41:	0f 45 05 14 af 1a f0 	cmovne 0xf01aaf14,%eax
f0100a48:	8d 4c 02 ff          	lea    -0x1(%edx,%eax,1),%ecx
f0100a4c:	89 c8                	mov    %ecx,%eax
f0100a4e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a53:	f7 f7                	div    %edi
f0100a55:	89 c8                	mov    %ecx,%eax
f0100a57:	29 d0                	sub    %edx,%eax
	//	Step 2: save current value of boot_freemem as allocated chunk
        v = (void *)boot_freemem;
	//	Step 3: increase boot_freemem to record allocation
         
         //boot_freemem += ROUNDUP(n, align);
         boot_freemem += n;
f0100a59:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
f0100a5c:	89 1d 14 af 1a f0    	mov    %ebx,0xf01aaf14
 
	//	Step 4: return all
        return v;
}
f0100a62:	8b 1c 24             	mov    (%esp),%ebx
f0100a65:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100a69:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0100a6d:	89 ec                	mov    %ebp,%esp
f0100a6f:	5d                   	pop    %ebp
f0100a70:	c3                   	ret    

f0100a71 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100a71:	55                   	push   %ebp
f0100a72:	89 e5                	mov    %esp,%ebp
f0100a74:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
        LIST_INSERT_HEAD(&page_free_list, pp, pp_link); 
f0100a77:	8b 15 18 af 1a f0    	mov    0xf01aaf18,%edx
f0100a7d:	89 10                	mov    %edx,(%eax)
f0100a7f:	85 d2                	test   %edx,%edx
f0100a81:	74 09                	je     f0100a8c <page_free+0x1b>
f0100a83:	8b 15 18 af 1a f0    	mov    0xf01aaf18,%edx
f0100a89:	89 42 04             	mov    %eax,0x4(%edx)
f0100a8c:	a3 18 af 1a f0       	mov    %eax,0xf01aaf18
f0100a91:	c7 40 04 18 af 1a f0 	movl   $0xf01aaf18,0x4(%eax)
}
f0100a98:	5d                   	pop    %ebp
f0100a99:	c3                   	ret    

f0100a9a <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100a9a:	55                   	push   %ebp
f0100a9b:	89 e5                	mov    %esp,%ebp
f0100a9d:	83 ec 04             	sub    $0x4,%esp
f0100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100aa3:	0f b7 50 08          	movzwl 0x8(%eax),%edx
f0100aa7:	83 ea 01             	sub    $0x1,%edx
f0100aaa:	66 89 50 08          	mov    %dx,0x8(%eax)
f0100aae:	66 85 d2             	test   %dx,%dx
f0100ab1:	75 08                	jne    f0100abb <page_decref+0x21>
		page_free(pp);
f0100ab3:	89 04 24             	mov    %eax,(%esp)
f0100ab6:	e8 b6 ff ff ff       	call   f0100a71 <page_free>
}
f0100abb:	c9                   	leave  
f0100abc:	c3                   	ret    

f0100abd <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100abd:	55                   	push   %ebp
f0100abe:	89 e5                	mov    %esp,%ebp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100ac0:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0100ac5:	85 c0                	test   %eax,%eax
f0100ac7:	74 08                	je     f0100ad1 <tlb_invalidate+0x14>
f0100ac9:	8b 55 08             	mov    0x8(%ebp),%edx
f0100acc:	39 50 5c             	cmp    %edx,0x5c(%eax)
f0100acf:	75 06                	jne    f0100ad7 <tlb_invalidate+0x1a>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ad4:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100ad7:	5d                   	pop    %ebp
f0100ad8:	c3                   	ret    

f0100ad9 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ad9:	55                   	push   %ebp
f0100ada:	89 e5                	mov    %esp,%ebp
f0100adc:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100adf:	89 d1                	mov    %edx,%ecx
f0100ae1:	c1 e9 16             	shr    $0x16,%ecx
f0100ae4:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ae7:	a8 01                	test   $0x1,%al
f0100ae9:	74 4d                	je     f0100b38 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aeb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af0:	89 c1                	mov    %eax,%ecx
f0100af2:	c1 e9 0c             	shr    $0xc,%ecx
f0100af5:	3b 0d c0 bb 1a f0    	cmp    0xf01abbc0,%ecx
f0100afb:	72 20                	jb     f0100b1d <check_va2pa+0x44>
f0100afd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b01:	c7 44 24 08 44 52 10 	movl   $0xf0105244,0x8(%esp)
f0100b08:	f0 
f0100b09:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0100b10:	00 
f0100b11:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0100b18:	e8 63 f5 ff ff       	call   f0100080 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b1d:	c1 ea 0c             	shr    $0xc,%edx
f0100b20:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b26:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b2d:	a8 01                	test   $0x1,%al
f0100b2f:	74 07                	je     f0100b38 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b36:	eb 05                	jmp    f0100b3d <check_va2pa+0x64>
f0100b38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b3d:	c9                   	leave  
f0100b3e:	c3                   	ret    

f0100b3f <page_init>:
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc() or the related boot-time functions above.
//
void
page_init(void)
{
f0100b3f:	55                   	push   %ebp
f0100b40:	89 e5                	mov    %esp,%ebp
f0100b42:	53                   	push   %ebx
f0100b43:	83 ec 14             	sub    $0x14,%esp
	// However this is not truly the case.  What memory is free?
	//  1) Mark page 0 as in use.
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
     
        pages[0].pp_ref = 1;
f0100b46:	a1 cc bb 1a f0       	mov    0xf01abbcc,%eax
f0100b4b:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
f0100b51:	b8 0c 00 00 00       	mov    $0xc,%eax
	//  2) Mark the rest of base memory as free.
       
        int i;
        int iophysmem_idx = IOPHYSMEM / PGSIZE;
        for (i = 1; i < iophysmem_idx; i++) {
             pages[i].pp_ref = 0;
f0100b56:	8b 15 cc bb 1a f0    	mov    0xf01abbcc,%edx
f0100b5c:	66 c7 44 02 08 00 00 	movw   $0x0,0x8(%edx,%eax,1)
             //add page to head of list to build page_free_list
             LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100b63:	8b 15 18 af 1a f0    	mov    0xf01aaf18,%edx
f0100b69:	8b 0d cc bb 1a f0    	mov    0xf01abbcc,%ecx
f0100b6f:	89 14 01             	mov    %edx,(%ecx,%eax,1)
f0100b72:	85 d2                	test   %edx,%edx
f0100b74:	74 11                	je     f0100b87 <page_init+0x48>
f0100b76:	89 c1                	mov    %eax,%ecx
f0100b78:	03 0d cc bb 1a f0    	add    0xf01abbcc,%ecx
f0100b7e:	8b 15 18 af 1a f0    	mov    0xf01aaf18,%edx
f0100b84:	89 4a 04             	mov    %ecx,0x4(%edx)
f0100b87:	89 c2                	mov    %eax,%edx
f0100b89:	03 15 cc bb 1a f0    	add    0xf01abbcc,%edx
f0100b8f:	89 15 18 af 1a f0    	mov    %edx,0xf01aaf18
f0100b95:	c7 42 04 18 af 1a f0 	movl   $0xf01aaf18,0x4(%edx)
f0100b9c:	83 c0 0c             	add    $0xc,%eax

	//  2) Mark the rest of base memory as free.
       
        int i;
        int iophysmem_idx = IOPHYSMEM / PGSIZE;
        for (i = 1; i < iophysmem_idx; i++) {
f0100b9f:	3d 80 07 00 00       	cmp    $0x780,%eax
f0100ba4:	75 b0                	jne    f0100b56 <page_init+0x17>

	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM).
     
        int extphysmem_idx = EXTPHYSMEM / PGSIZE;
        for(i = iophysmem_idx; i < extphysmem_idx; i++) {
              pages[i].pp_ref = 1;
f0100ba6:	8b 15 cc bb 1a f0    	mov    0xf01abbcc,%edx
f0100bac:	66 c7 44 02 08 01 00 	movw   $0x1,0x8(%edx,%eax,1)
f0100bb3:	83 c0 0c             	add    $0xc,%eax
        }

	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM).
     
        int extphysmem_idx = EXTPHYSMEM / PGSIZE;
        for(i = iophysmem_idx; i < extphysmem_idx; i++) {
f0100bb6:	3d 00 0c 00 00       	cmp    $0xc00,%eax
f0100bbb:	75 e9                	jne    f0100ba6 <page_init+0x67>
	//  4) Then extended memory [EXTPHYSMEM, ...).
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
       int boot_freemem_idx = ROUNDUP( PADDR( boot_freemem ), PGSIZE) / PGSIZE;
f0100bbd:	a1 14 af 1a f0       	mov    0xf01aaf14,%eax
f0100bc2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100bc7:	77 20                	ja     f0100be9 <page_init+0xaa>
f0100bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bcd:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f0100bd4:	f0 
f0100bd5:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f0100bdc:	00 
f0100bdd:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0100be4:	e8 97 f4 ff ff       	call   f0100080 <_panic>
f0100be9:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0100bee:	c1 e8 0c             	shr    $0xc,%eax
       for(i = boot_freemem_idx; i < npage; i++) {
f0100bf1:	3b 05 c0 bb 1a f0    	cmp    0xf01abbc0,%eax
f0100bf7:	73 58                	jae    f0100c51 <page_init+0x112>
	//  4) Then extended memory [EXTPHYSMEM, ...).
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
       int boot_freemem_idx = ROUNDUP( PADDR( boot_freemem ), PGSIZE) / PGSIZE;
f0100bf9:	89 c2                	mov    %eax,%edx
       for(i = boot_freemem_idx; i < npage; i++) {
             pages[i].pp_ref = 0;
f0100bfb:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100bfe:	c1 e0 02             	shl    $0x2,%eax
f0100c01:	8b 0d cc bb 1a f0    	mov    0xf01abbcc,%ecx
f0100c07:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
             LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100c0e:	8b 0d 18 af 1a f0    	mov    0xf01aaf18,%ecx
f0100c14:	8b 1d cc bb 1a f0    	mov    0xf01abbcc,%ebx
f0100c1a:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
f0100c1d:	85 c9                	test   %ecx,%ecx
f0100c1f:	74 11                	je     f0100c32 <page_init+0xf3>
f0100c21:	89 c3                	mov    %eax,%ebx
f0100c23:	03 1d cc bb 1a f0    	add    0xf01abbcc,%ebx
f0100c29:	8b 0d 18 af 1a f0    	mov    0xf01aaf18,%ecx
f0100c2f:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100c32:	03 05 cc bb 1a f0    	add    0xf01abbcc,%eax
f0100c38:	a3 18 af 1a f0       	mov    %eax,0xf01aaf18
f0100c3d:	c7 40 04 18 af 1a f0 	movl   $0xf01aaf18,0x4(%eax)
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
       int boot_freemem_idx = ROUNDUP( PADDR( boot_freemem ), PGSIZE) / PGSIZE;
       for(i = boot_freemem_idx; i < npage; i++) {
f0100c44:	83 c2 01             	add    $0x1,%edx
f0100c47:	89 d0                	mov    %edx,%eax
f0100c49:	39 15 c0 bb 1a f0    	cmp    %edx,0xf01abbc0
f0100c4f:	77 aa                	ja     f0100bfb <page_init+0xbc>
             pages[i].pp_ref = 0;
             LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
       }
}
f0100c51:	83 c4 14             	add    $0x14,%esp
f0100c54:	5b                   	pop    %ebx
f0100c55:	5d                   	pop    %ebp
f0100c56:	c3                   	ret    

f0100c57 <boot_map_segment>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
//
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0100c57:	55                   	push   %ebp
f0100c58:	89 e5                	mov    %esp,%ebp
f0100c5a:	57                   	push   %edi
f0100c5b:	56                   	push   %esi
f0100c5c:	53                   	push   %ebx
f0100c5d:	83 ec 3c             	sub    $0x3c,%esp
f0100c60:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c63:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0100c66:	89 4d dc             	mov    %ecx,-0x24(%ebp)
	pte_t *pte;
        uintptr_t i;
        for(i = 0; i < size; i += PGSIZE)
f0100c69:	85 c9                	test   %ecx,%ecx
f0100c6b:	0f 84 e2 00 00 00    	je     f0100d53 <boot_map_segment+0xfc>
        {
        	pte = boot_pgdir_walk(pgdir, la+i, 1);
        	pgdir[PDX(la)] = (pgdir[PDX(la)]&0xFFFFF000)|perm|PTE_P;
f0100c71:	89 d0                	mov    %edx,%eax
f0100c73:	c1 e8 16             	shr    $0x16,%eax
f0100c76:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c79:	8d 34 82             	lea    (%edx,%eax,4),%esi
f0100c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c81:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c84:	83 c8 01             	or     $0x1,%eax
f0100c87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c8a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100c8d:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
//
static pte_t*
boot_pgdir_walk(pde_t *pgdir, uintptr_t la, int create)
{
	pte_t *pte;
	pte = (pte_t *)pgdir[PDX(la)];
f0100c90:	89 f8                	mov    %edi,%eax
f0100c92:	c1 e8 16             	shr    $0x16,%eax
f0100c95:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100c98:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0100c9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100c9e:	8b 00                	mov    (%eax),%eax
      	if(!pte)
f0100ca0:	85 c0                	test   %eax,%eax
f0100ca2:	75 47                	jne    f0100ceb <boot_map_segment+0x94>
      	{
          	if(!create)
              	return 0;
          	pte = (pte_t *)boot_alloc(PGSIZE, PGSIZE);
f0100ca4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0100ca9:	66 b8 00 10          	mov    $0x1000,%ax
f0100cad:	e8 6e fd ff ff       	call   f0100a20 <boot_alloc>
          	pgdir[PDX(la)] = PADDR(pte)|PTE_P|PTE_W;
f0100cb2:	89 c2                	mov    %eax,%edx
f0100cb4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100cb9:	77 20                	ja     f0100cdb <boot_map_segment+0x84>
f0100cbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cbf:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f0100cc6:	f0 
f0100cc7:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
f0100cce:	00 
f0100ccf:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0100cd6:	e8 a5 f3 ff ff       	call   f0100080 <_panic>
f0100cdb:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100ce1:	83 ca 03             	or     $0x3,%edx
f0100ce4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ce7:	89 11                	mov    %edx,(%ecx)
f0100ce9:	eb 37                	jmp    f0100d22 <boot_map_segment+0xcb>
      	}
      	else
         	pte = (pte_t *)KADDR(PTE_ADDR(pte));
f0100ceb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cf0:	89 c2                	mov    %eax,%edx
f0100cf2:	c1 ea 0c             	shr    $0xc,%edx
f0100cf5:	3b 15 c0 bb 1a f0    	cmp    0xf01abbc0,%edx
f0100cfb:	72 20                	jb     f0100d1d <boot_map_segment+0xc6>
f0100cfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d01:	c7 44 24 08 44 52 10 	movl   $0xf0105244,0x8(%esp)
f0100d08:	f0 
f0100d09:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
f0100d10:	00 
f0100d11:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0100d18:	e8 63 f3 ff ff       	call   f0100080 <_panic>
f0100d1d:	2d 00 00 00 10       	sub    $0x10000000,%eax
	pte_t *pte;
        uintptr_t i;
        for(i = 0; i < size; i += PGSIZE)
        {
        	pte = boot_pgdir_walk(pgdir, la+i, 1);
        	pgdir[PDX(la)] = (pgdir[PDX(la)]&0xFFFFF000)|perm|PTE_P;
f0100d22:	8b 16                	mov    (%esi),%edx
f0100d24:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100d2a:	0b 55 e4             	or     -0x1c(%ebp),%edx
f0100d2d:	89 16                	mov    %edx,(%esi)
        	pte[PTX(la+i)] = (pa+i)|perm|PTE_P;
f0100d2f:	c1 ef 0c             	shr    $0xc,%edi
f0100d32:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
f0100d38:	8b 55 08             	mov    0x8(%ebp),%edx
f0100d3b:	8d 14 13             	lea    (%ebx,%edx,1),%edx
f0100d3e:	0b 55 e4             	or     -0x1c(%ebp),%edx
f0100d41:	89 14 b8             	mov    %edx,(%eax,%edi,4)
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
	pte_t *pte;
        uintptr_t i;
        for(i = 0; i < size; i += PGSIZE)
f0100d44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100d4a:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100d4d:	0f 87 37 ff ff ff    	ja     f0100c8a <boot_map_segment+0x33>
        {
        	pte = boot_pgdir_walk(pgdir, la+i, 1);
        	pgdir[PDX(la)] = (pgdir[PDX(la)]&0xFFFFF000)|perm|PTE_P;
        	pte[PTX(la+i)] = (pa+i)|perm|PTE_P;
        }
}
f0100d53:	83 c4 3c             	add    $0x3c,%esp
f0100d56:	5b                   	pop    %ebx
f0100d57:	5e                   	pop    %esi
f0100d58:	5f                   	pop    %edi
f0100d59:	5d                   	pop    %ebp
f0100d5a:	c3                   	ret    

f0100d5b <page_alloc>:
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented 
int
page_alloc(struct Page **pp_store)
{
f0100d5b:	55                   	push   %ebp
f0100d5c:	89 e5                	mov    %esp,%ebp
f0100d5e:	83 ec 18             	sub    $0x18,%esp
f0100d61:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Fill this function in

       //check if there are no free pages
       if(LIST_EMPTY(&page_free_list))return -E_NO_MEM;
f0100d64:	8b 15 18 af 1a f0    	mov    0xf01aaf18,%edx
f0100d6a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100d6f:	85 d2                	test   %edx,%edx
f0100d71:	74 36                	je     f0100da9 <page_alloc+0x4e>
 
       //store ptr to page
       *pp_store = LIST_FIRST(&page_free_list);
f0100d73:	89 11                	mov    %edx,(%ecx)
       //remove page from list
       LIST_REMOVE(*pp_store, pp_link);
f0100d75:	8b 02                	mov    (%edx),%eax
f0100d77:	85 c0                	test   %eax,%eax
f0100d79:	74 06                	je     f0100d81 <page_alloc+0x26>
f0100d7b:	8b 52 04             	mov    0x4(%edx),%edx
f0100d7e:	89 50 04             	mov    %edx,0x4(%eax)
f0100d81:	8b 01                	mov    (%ecx),%eax
f0100d83:	8b 50 04             	mov    0x4(%eax),%edx
f0100d86:	8b 00                	mov    (%eax),%eax
f0100d88:	89 02                	mov    %eax,(%edx)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f0100d8a:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0100d91:	00 
f0100d92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d99:	00 
f0100d9a:	8b 01                	mov    (%ecx),%eax
f0100d9c:	89 04 24             	mov    %eax,(%esp)
f0100d9f:	e8 32 3b 00 00       	call   f01048d6 <memset>
f0100da4:	b8 00 00 00 00       	mov    $0x0,%eax
       //init the new page struct
       page_initpp(*pp_store);
       //told not to inc ref count, so don't
       //return success
       return 0;
}
f0100da9:	c9                   	leave  
f0100daa:	c3                   	ret    

f0100dab <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100dab:	55                   	push   %ebp
f0100dac:	89 e5                	mov    %esp,%ebp
f0100dae:	83 ec 28             	sub    $0x28,%esp
f0100db1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100db4:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
        struct Page* p;
        pte_t *pt;
        pgdir = (pde_t *)&pgdir[PDX(va)];
f0100db7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100dba:	89 f3                	mov    %esi,%ebx
f0100dbc:	c1 eb 16             	shr    $0x16,%ebx
f0100dbf:	c1 e3 02             	shl    $0x2,%ebx
f0100dc2:	03 5d 08             	add    0x8(%ebp),%ebx
        //whether the page table exist or not
        //it isn't exist~ 
        if((*pgdir& PTE_P)==0)
f0100dc5:	f6 03 01             	testb  $0x1,(%ebx)
f0100dc8:	0f 85 9f 00 00 00    	jne    f0100e6d <pgdir_walk+0xc2>
        {
             if(create==0)
f0100dce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100dd2:	0f 84 db 00 00 00    	je     f0100eb3 <pgdir_walk+0x108>
             { 
                 return NULL;
             }
            //allocate a page
             if(page_alloc(&p) < 0)
f0100dd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ddb:	89 04 24             	mov    %eax,(%esp)
f0100dde:	e8 78 ff ff ff       	call   f0100d5b <page_alloc>
f0100de3:	85 c0                	test   %eax,%eax
f0100de5:	0f 88 c8 00 00 00    	js     f0100eb3 <pgdir_walk+0x108>
             {
                 return NULL;
             }
             //p points to an entry in the pages table and set pp_ref to 1
            p->pp_ref = 1;
f0100deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100dee:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100df7:	2b 05 cc bb 1a f0    	sub    0xf01abbcc,%eax
f0100dfd:	c1 f8 02             	sar    $0x2,%eax
f0100e00:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100e06:	c1 e0 0c             	shl    $0xc,%eax
            //set the page clear
           memset(KADDR(page2pa(p)), 0, PGSIZE);
f0100e09:	89 c2                	mov    %eax,%edx
f0100e0b:	c1 ea 0c             	shr    $0xc,%edx
f0100e0e:	3b 15 c0 bb 1a f0    	cmp    0xf01abbc0,%edx
f0100e14:	72 20                	jb     f0100e36 <pgdir_walk+0x8b>
f0100e16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e1a:	c7 44 24 08 44 52 10 	movl   $0xf0105244,0x8(%esp)
f0100e21:	f0 
f0100e22:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
f0100e29:	00 
f0100e2a:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0100e31:	e8 4a f2 ff ff       	call   f0100080 <_panic>
f0100e36:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e3d:	00 
f0100e3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e45:	00 
f0100e46:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e4b:	89 04 24             	mov    %eax,(%esp)
f0100e4e:	e8 83 3a 00 00       	call   f01048d6 <memset>
           //make the page directory point to that page (contains pt)
           *pgdir = page2pa(p) | PTE_U |PTE_W | PTE_P;
f0100e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e56:	2b 05 cc bb 1a f0    	sub    0xf01abbcc,%eax
f0100e5c:	c1 f8 02             	sar    $0x2,%eax
f0100e5f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100e65:	c1 e0 0c             	shl    $0xc,%eax
f0100e68:	83 c8 07             	or     $0x7,%eax
f0100e6b:	89 03                	mov    %eax,(%ebx)
        }
        pt = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e6d:	8b 03                	mov    (%ebx),%eax
f0100e6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e74:	89 c2                	mov    %eax,%edx
f0100e76:	c1 ea 0c             	shr    $0xc,%edx
f0100e79:	3b 15 c0 bb 1a f0    	cmp    0xf01abbc0,%edx
f0100e7f:	72 20                	jb     f0100ea1 <pgdir_walk+0xf6>
f0100e81:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e85:	c7 44 24 08 44 52 10 	movl   $0xf0105244,0x8(%esp)
f0100e8c:	f0 
f0100e8d:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
f0100e94:	00 
f0100e95:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0100e9c:	e8 df f1 ff ff       	call   f0100080 <_panic>
        // Page table exists, return the VA of the page table entry
        return &pt[PTX(va)];
f0100ea1:	c1 ee 0a             	shr    $0xa,%esi
f0100ea4:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100eaa:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100eb1:	eb 05                	jmp    f0100eb8 <pgdir_walk+0x10d>
f0100eb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100eb8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100ebb:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100ebe:	89 ec                	mov    %ebp,%esp
f0100ec0:	5d                   	pop    %ebp
f0100ec1:	c3                   	ret    

f0100ec2 <user_mem_check>:
//
// Hint: The TA solution uses pgdir_walk.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0100ec2:	55                   	push   %ebp
f0100ec3:	89 e5                	mov    %esp,%ebp
f0100ec5:	57                   	push   %edi
f0100ec6:	56                   	push   %esi
f0100ec7:	53                   	push   %ebx
f0100ec8:	83 ec 2c             	sub    $0x2c,%esp
f0100ecb:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ece:	8b 55 14             	mov    0x14(%ebp),%edx
	// LAB 3: Your code here. 

        if (va > (void *)ULIM) {
f0100ed1:	81 7d 0c 00 00 80 ef 	cmpl   $0xef800000,0xc(%ebp)
f0100ed8:	76 12                	jbe    f0100eec <user_mem_check+0x2a>
                user_mem_check_addr = (uintptr_t)va;
f0100eda:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100edd:	a3 1c af 1a f0       	mov    %eax,0xf01aaf1c
f0100ee2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                return -E_FAULT;
f0100ee7:	e9 f5 00 00 00       	jmp    f0100fe1 <user_mem_check+0x11f>
        }
        uint32_t i;
        void * va_down = (void *)ROUNDDOWN(va, PGSIZE);
        size_t len_up = ROUNDUP(len, PGSIZE);
f0100eec:	8b 45 10             	mov    0x10(%ebp),%eax
f0100eef:	05 ff 0f 00 00       	add    $0xfff,%eax
        for (i = 0; i < len_up / PGSIZE; i++) {
f0100ef4:	c1 e8 0c             	shr    $0xc,%eax
f0100ef7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100efa:	85 c0                	test   %eax,%eax
f0100efc:	0f 84 da 00 00 00    	je     f0100fdc <user_mem_check+0x11a>
        if (va > (void *)ULIM) {
                user_mem_check_addr = (uintptr_t)va;
                return -E_FAULT;
        }
        uint32_t i;
        void * va_down = (void *)ROUNDDOWN(va, PGSIZE);
f0100f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0100f05:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100f0b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f0e:	89 c8                	mov    %ecx,%eax
        size_t len_up = ROUNDUP(len, PGSIZE);
        for (i = 0; i < len_up / PGSIZE; i++) {
                if (va_down + i * PGSIZE > (void *)ULIM) {
f0100f10:	81 f9 00 00 80 ef    	cmp    $0xef800000,%ecx
f0100f16:	76 2b                	jbe    f0100f43 <user_mem_check+0x81>
f0100f18:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f1d:	eb 11                	jmp    f0100f30 <user_mem_check+0x6e>
f0100f1f:	89 df                	mov    %ebx,%edi
f0100f21:	c1 e7 0c             	shl    $0xc,%edi
f0100f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f27:	01 f8                	add    %edi,%eax
f0100f29:	3d 00 00 80 ef       	cmp    $0xef800000,%eax
f0100f2e:	76 2b                	jbe    f0100f5b <user_mem_check+0x99>
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
f0100f30:	03 7d 0c             	add    0xc(%ebp),%edi
f0100f33:	89 3d 1c af 1a f0    	mov    %edi,0xf01aaf1c
f0100f39:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                        return -E_FAULT;
f0100f3e:	e9 9e 00 00 00       	jmp    f0100fe1 <user_mem_check+0x11f>
f0100f43:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f48:	bb 00 00 00 00       	mov    $0x0,%ebx
                if (!((*pte) & PTE_P)) {
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
                        return -E_FAULT;
                }
                // try to access with perm PTE_U but pte is kernel mode
                if (!(perm & PTE_U) && ((*pte) & PTE_U)) {
f0100f4d:	89 d1                	mov    %edx,%ecx
f0100f4f:	83 e1 04             	and    $0x4,%ecx
f0100f52:	89 4d dc             	mov    %ecx,-0x24(%ebp)
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
                        return -E_FAULT;
                }
                // try to access with perm PTE_W but pte is not writable
                if ((perm & PTE_W) && !((*pte) & PTE_W)) {
f0100f55:	83 e2 02             	and    $0x2,%edx
f0100f58:	89 55 d8             	mov    %edx,-0x28(%ebp)
        for (i = 0; i < len_up / PGSIZE; i++) {
                if (va_down + i * PGSIZE > (void *)ULIM) {
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
                        return -E_FAULT;
                }
                pte_t * pte = pgdir_walk(env->env_pgdir, va_down + i * PGSIZE, 0);
f0100f5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f62:	00 
f0100f63:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f67:	8b 46 5c             	mov    0x5c(%esi),%eax
f0100f6a:	89 04 24             	mov    %eax,(%esp)
f0100f6d:	e8 39 fe ff ff       	call   f0100dab <pgdir_walk>
                if (pte == NULL) {
f0100f72:	85 c0                	test   %eax,%eax
f0100f74:	75 10                	jne    f0100f86 <user_mem_check+0xc4>
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
f0100f76:	03 7d 0c             	add    0xc(%ebp),%edi
f0100f79:	89 3d 1c af 1a f0    	mov    %edi,0xf01aaf1c
f0100f7f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                        return -E_FAULT;
f0100f84:	eb 5b                	jmp    f0100fe1 <user_mem_check+0x11f>
                }
                if (!((*pte) & PTE_P)) {
f0100f86:	8b 00                	mov    (%eax),%eax
f0100f88:	a8 01                	test   $0x1,%al
f0100f8a:	75 10                	jne    f0100f9c <user_mem_check+0xda>
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
f0100f8c:	03 7d 0c             	add    0xc(%ebp),%edi
f0100f8f:	89 3d 1c af 1a f0    	mov    %edi,0xf01aaf1c
f0100f95:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                        return -E_FAULT;
f0100f9a:	eb 45                	jmp    f0100fe1 <user_mem_check+0x11f>
                }
                // try to access with perm PTE_U but pte is kernel mode
                if (!(perm & PTE_U) && ((*pte) & PTE_U)) {
f0100f9c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100fa0:	75 14                	jne    f0100fb6 <user_mem_check+0xf4>
f0100fa2:	a8 04                	test   $0x4,%al
f0100fa4:	74 10                	je     f0100fb6 <user_mem_check+0xf4>
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
f0100fa6:	03 7d 0c             	add    0xc(%ebp),%edi
f0100fa9:	89 3d 1c af 1a f0    	mov    %edi,0xf01aaf1c
f0100faf:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                        return -E_FAULT;
f0100fb4:	eb 2b                	jmp    f0100fe1 <user_mem_check+0x11f>
                }
                // try to access with perm PTE_W but pte is not writable
                if ((perm & PTE_W) && !((*pte) & PTE_W)) {
f0100fb6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fba:	74 14                	je     f0100fd0 <user_mem_check+0x10e>
f0100fbc:	a8 02                	test   $0x2,%al
f0100fbe:	75 10                	jne    f0100fd0 <user_mem_check+0x10e>
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
f0100fc0:	03 7d 0c             	add    0xc(%ebp),%edi
f0100fc3:	89 3d 1c af 1a f0    	mov    %edi,0xf01aaf1c
f0100fc9:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                        return -E_FAULT;
f0100fce:	eb 11                	jmp    f0100fe1 <user_mem_check+0x11f>
                return -E_FAULT;
        }
        uint32_t i;
        void * va_down = (void *)ROUNDDOWN(va, PGSIZE);
        size_t len_up = ROUNDUP(len, PGSIZE);
        for (i = 0; i < len_up / PGSIZE; i++) {
f0100fd0:	83 c3 01             	add    $0x1,%ebx
f0100fd3:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f0100fd6:	0f 87 43 ff ff ff    	ja     f0100f1f <user_mem_check+0x5d>
f0100fdc:	b8 00 00 00 00       	mov    $0x0,%eax
                        user_mem_check_addr = (uintptr_t)(va + i * PGSIZE);
                        return -E_FAULT;
                }
        }
	return 0;
}
f0100fe1:	83 c4 2c             	add    $0x2c,%esp
f0100fe4:	5b                   	pop    %ebx
f0100fe5:	5e                   	pop    %esi
f0100fe6:	5f                   	pop    %edi
f0100fe7:	5d                   	pop    %ebp
f0100fe8:	c3                   	ret    

f0100fe9 <user_mem_assert>:
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0100fe9:	55                   	push   %ebp
f0100fea:	89 e5                	mov    %esp,%ebp
f0100fec:	53                   	push   %ebx
f0100fed:	83 ec 14             	sub    $0x14,%esp
f0100ff0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0100ff3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff6:	83 c8 04             	or     $0x4,%eax
f0100ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ffd:	8b 45 10             	mov    0x10(%ebp),%eax
f0101000:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101004:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101007:	89 44 24 04          	mov    %eax,0x4(%esp)
f010100b:	89 1c 24             	mov    %ebx,(%esp)
f010100e:	e8 af fe ff ff       	call   f0100ec2 <user_mem_check>
f0101013:	85 c0                	test   %eax,%eax
f0101015:	79 29                	jns    f0101040 <user_mem_assert+0x57>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101017:	a1 1c af 1a f0       	mov    0xf01aaf1c,%eax
f010101c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101020:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0101025:	8b 40 4c             	mov    0x4c(%eax),%eax
f0101028:	89 44 24 04          	mov    %eax,0x4(%esp)
f010102c:	c7 04 24 8c 52 10 f0 	movl   $0xf010528c,(%esp)
f0101033:	e8 df 19 00 00       	call   f0102a17 <cprintf>
			"va %08x\n", curenv->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0101038:	89 1c 24             	mov    %ebx,(%esp)
f010103b:	e8 e6 13 00 00       	call   f0102426 <env_destroy>
	}
}
f0101040:	83 c4 14             	add    $0x14,%esp
f0101043:	5b                   	pop    %ebx
f0101044:	5d                   	pop    %ebp
f0101045:	c3                   	ret    

f0101046 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101046:	55                   	push   %ebp
f0101047:	89 e5                	mov    %esp,%ebp
f0101049:	53                   	push   %ebx
f010104a:	83 ec 14             	sub    $0x14,%esp
f010104d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101050:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101057:	00 
f0101058:	8b 45 0c             	mov    0xc(%ebp),%eax
f010105b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010105f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101062:	89 04 24             	mov    %eax,(%esp)
f0101065:	e8 41 fd ff ff       	call   f0100dab <pgdir_walk>
        if(NULL == pte)
f010106a:	ba 00 00 00 00       	mov    $0x0,%edx
f010106f:	85 c0                	test   %eax,%eax
f0101071:	74 3b                	je     f01010ae <page_lookup+0x68>
             return NULL;
 
        // If pte_store is not zero, then we store in it the address  of the pte for that page
       if(pte_store != NULL)
f0101073:	85 db                	test   %ebx,%ebx
f0101075:	74 02                	je     f0101079 <page_lookup+0x33>
           *pte_store = pte;
f0101077:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101079:	8b 00                	mov    (%eax),%eax
f010107b:	c1 e8 0c             	shr    $0xc,%eax
f010107e:	3b 05 c0 bb 1a f0    	cmp    0xf01abbc0,%eax
f0101084:	72 1c                	jb     f01010a2 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101086:	c7 44 24 08 c4 52 10 	movl   $0xf01052c4,0x8(%esp)
f010108d:	f0 
f010108e:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0101095:	00 
f0101096:	c7 04 24 d5 56 10 f0 	movl   $0xf01056d5,(%esp)
f010109d:	e8 de ef ff ff       	call   f0100080 <_panic>
	return &pages[PPN(pa)];
f01010a2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01010a5:	c1 e2 02             	shl    $0x2,%edx
f01010a8:	03 15 cc bb 1a f0    	add    0xf01abbcc,%edx
       return pa2page(*pte); 
}
f01010ae:	89 d0                	mov    %edx,%eax
f01010b0:	83 c4 14             	add    $0x14,%esp
f01010b3:	5b                   	pop    %ebx
f01010b4:	5d                   	pop    %ebp
f01010b5:	c3                   	ret    

f01010b6 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010b6:	55                   	push   %ebp
f01010b7:	89 e5                	mov    %esp,%ebp
f01010b9:	83 ec 28             	sub    $0x28,%esp
f01010bc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01010bf:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01010c2:	8b 75 08             	mov    0x8(%ebp),%esi
f01010c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
         pte_t *pte = NULL;
f01010c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
         struct Page *p;
 
         p = page_lookup(pgdir, va, &pte);
f01010cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010da:	89 34 24             	mov    %esi,(%esp)
f01010dd:	e8 64 ff ff ff       	call   f0101046 <page_lookup>
         if(NULL == p) return;
f01010e2:	85 c0                	test   %eax,%eax
f01010e4:	74 21                	je     f0101107 <page_remove+0x51>
         //The ref count on the physical page should decrement
         page_decref(p);
f01010e6:	89 04 24             	mov    %eax,(%esp)
f01010e9:	e8 ac f9 ff ff       	call   f0100a9a <page_decref>
         // Set the respective page table entry to 0
         if(pte != NULL)
f01010ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010f1:	85 c0                	test   %eax,%eax
f01010f3:	74 06                	je     f01010fb <page_remove+0x45>
               *pte = 0;
f01010f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
         //Set the TLB invalid
         tlb_invalidate(pgdir,  va);
f01010fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010ff:	89 34 24             	mov    %esi,(%esp)
f0101102:	e8 b6 f9 ff ff       	call   f0100abd <tlb_invalidate>
}
f0101107:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010110a:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010110d:	89 ec                	mov    %ebp,%esp
f010110f:	5d                   	pop    %ebp
f0101110:	c3                   	ret    

f0101111 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0101111:	55                   	push   %ebp
f0101112:	89 e5                	mov    %esp,%ebp
f0101114:	83 ec 28             	sub    $0x28,%esp
f0101117:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010111a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010111d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101120:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101123:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t *pte;
 
        pte = pgdir_walk(pgdir, va, 1);
f0101126:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010112d:	00 
f010112e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101132:	8b 45 08             	mov    0x8(%ebp),%eax
f0101135:	89 04 24             	mov    %eax,(%esp)
f0101138:	e8 6e fc ff ff       	call   f0100dab <pgdir_walk>
f010113d:	89 c3                	mov    %eax,%ebx
        if(NULL == pte)
f010113f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101144:	85 db                	test   %ebx,%ebx
f0101146:	74 3c                	je     f0101184 <page_insert+0x73>
            return -E_NO_MEM;
        // First increase the reference count so the page doesn't get
       // removed in the next step if we try to repeat a mapping
       pp->pp_ref++;
f0101148:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
       // If there is something mapped there, page remove it
       if( (*pte & PTE_P) != 0)
f010114d:	f6 03 01             	testb  $0x1,(%ebx)
f0101150:	74 0f                	je     f0101161 <page_insert+0x50>
             page_remove(pgdir, va);
f0101152:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101156:	8b 45 08             	mov    0x8(%ebp),%eax
f0101159:	89 04 24             	mov    %eax,(%esp)
f010115c:	e8 55 ff ff ff       	call   f01010b6 <page_remove>
 
       *pte = page2pa(pp) |PTE_P |perm;
f0101161:	8b 55 14             	mov    0x14(%ebp),%edx
f0101164:	83 ca 01             	or     $0x1,%edx
f0101167:	2b 35 cc bb 1a f0    	sub    0xf01abbcc,%esi
f010116d:	c1 fe 02             	sar    $0x2,%esi
f0101170:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0101176:	c1 e0 0c             	shl    $0xc,%eax
f0101179:	89 d6                	mov    %edx,%esi
f010117b:	09 c6                	or     %eax,%esi
f010117d:	89 33                	mov    %esi,(%ebx)
f010117f:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0101184:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101187:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010118a:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010118d:	89 ec                	mov    %ebp,%esp
f010118f:	5d                   	pop    %ebp
f0101190:	c3                   	ret    

f0101191 <page_check>:
	}
}

void
page_check(void)
{
f0101191:	55                   	push   %ebp
f0101192:	89 e5                	mov    %esp,%ebp
f0101194:	53                   	push   %ebx
f0101195:	83 ec 34             	sub    $0x34,%esp
	struct Page *pp, *pp0, *pp1, *pp2;
	struct Page_list fl;
	pte_t *ptep;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101198:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f010119f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f01011a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	assert(page_alloc(&pp0) == 0);
f01011ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01011b0:	89 04 24             	mov    %eax,(%esp)
f01011b3:	e8 a3 fb ff ff       	call   f0100d5b <page_alloc>
f01011b8:	85 c0                	test   %eax,%eax
f01011ba:	74 24                	je     f01011e0 <page_check+0x4f>
f01011bc:	c7 44 24 0c e3 56 10 	movl   $0xf01056e3,0xc(%esp)
f01011c3:	f0 
f01011c4:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01011cb:	f0 
f01011cc:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f01011d3:	00 
f01011d4:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01011db:	e8 a0 ee ff ff       	call   f0100080 <_panic>
	assert(page_alloc(&pp1) == 0);
f01011e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011e3:	89 04 24             	mov    %eax,(%esp)
f01011e6:	e8 70 fb ff ff       	call   f0100d5b <page_alloc>
f01011eb:	85 c0                	test   %eax,%eax
f01011ed:	74 24                	je     f0101213 <page_check+0x82>
f01011ef:	c7 44 24 0c 0e 57 10 	movl   $0xf010570e,0xc(%esp)
f01011f6:	f0 
f01011f7:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01011fe:	f0 
f01011ff:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0101206:	00 
f0101207:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f010120e:	e8 6d ee ff ff       	call   f0100080 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101213:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0101216:	89 04 24             	mov    %eax,(%esp)
f0101219:	e8 3d fb ff ff       	call   f0100d5b <page_alloc>
f010121e:	85 c0                	test   %eax,%eax
f0101220:	74 24                	je     f0101246 <page_check+0xb5>
f0101222:	c7 44 24 0c 24 57 10 	movl   $0xf0105724,0xc(%esp)
f0101229:	f0 
f010122a:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101231:	f0 
f0101232:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0101239:	00 
f010123a:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101241:	e8 3a ee ff ff       	call   f0100080 <_panic>

	assert(pp0);
f0101246:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101249:	85 d2                	test   %edx,%edx
f010124b:	75 24                	jne    f0101271 <page_check+0xe0>
f010124d:	c7 44 24 0c 48 57 10 	movl   $0xf0105748,0xc(%esp)
f0101254:	f0 
f0101255:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f010125c:	f0 
f010125d:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0101264:	00 
f0101265:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f010126c:	e8 0f ee ff ff       	call   f0100080 <_panic>
	assert(pp1 && pp1 != pp0);
f0101271:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101274:	85 c0                	test   %eax,%eax
f0101276:	74 04                	je     f010127c <page_check+0xeb>
f0101278:	39 c2                	cmp    %eax,%edx
f010127a:	75 24                	jne    f01012a0 <page_check+0x10f>
f010127c:	c7 44 24 0c 3a 57 10 	movl   $0xf010573a,0xc(%esp)
f0101283:	f0 
f0101284:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f010128b:	f0 
f010128c:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0101293:	00 
f0101294:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f010129b:	e8 e0 ed ff ff       	call   f0100080 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012a0:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01012a3:	85 c9                	test   %ecx,%ecx
f01012a5:	74 0b                	je     f01012b2 <page_check+0x121>
f01012a7:	39 c8                	cmp    %ecx,%eax
f01012a9:	74 07                	je     f01012b2 <page_check+0x121>
f01012ab:	39 ca                	cmp    %ecx,%edx
f01012ad:	8d 76 00             	lea    0x0(%esi),%esi
f01012b0:	75 24                	jne    f01012d6 <page_check+0x145>
f01012b2:	c7 44 24 0c e4 52 10 	movl   $0xf01052e4,0xc(%esp)
f01012b9:	f0 
f01012ba:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01012c1:	f0 
f01012c2:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f01012c9:	00 
f01012ca:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01012d1:	e8 aa ed ff ff       	call   f0100080 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01012d6:	8b 1d 18 af 1a f0    	mov    0xf01aaf18,%ebx
	LIST_INIT(&page_free_list);
f01012dc:	c7 05 18 af 1a f0 00 	movl   $0x0,0xf01aaf18
f01012e3:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01012e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012e9:	89 04 24             	mov    %eax,(%esp)
f01012ec:	e8 6a fa ff ff       	call   f0100d5b <page_alloc>
f01012f1:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01012f4:	74 24                	je     f010131a <page_check+0x189>
f01012f6:	c7 44 24 0c 4c 57 10 	movl   $0xf010574c,0xc(%esp)
f01012fd:	f0 
f01012fe:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101305:	f0 
f0101306:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f010130d:	00 
f010130e:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101315:	e8 66 ed ff ff       	call   f0100080 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f010131a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010131d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101321:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101328:	00 
f0101329:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f010132e:	89 04 24             	mov    %eax,(%esp)
f0101331:	e8 10 fd ff ff       	call   f0101046 <page_lookup>
f0101336:	85 c0                	test   %eax,%eax
f0101338:	74 24                	je     f010135e <page_check+0x1cd>
f010133a:	c7 44 24 0c 04 53 10 	movl   $0xf0105304,0xc(%esp)
f0101341:	f0 
f0101342:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101349:	f0 
f010134a:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0101351:	00 
f0101352:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101359:	e8 22 ed ff ff       	call   f0100080 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f010135e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101365:	00 
f0101366:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010136d:	00 
f010136e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101371:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101375:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f010137a:	89 04 24             	mov    %eax,(%esp)
f010137d:	e8 8f fd ff ff       	call   f0101111 <page_insert>
f0101382:	85 c0                	test   %eax,%eax
f0101384:	78 24                	js     f01013aa <page_check+0x219>
f0101386:	c7 44 24 0c 3c 53 10 	movl   $0xf010533c,0xc(%esp)
f010138d:	f0 
f010138e:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101395:	f0 
f0101396:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f010139d:	00 
f010139e:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01013a5:	e8 d6 ec ff ff       	call   f0100080 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01013aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01013ad:	89 04 24             	mov    %eax,(%esp)
f01013b0:	e8 bc f6 ff ff       	call   f0100a71 <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f01013b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01013bc:	00 
f01013bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013c4:	00 
f01013c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01013c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013cc:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01013d1:	89 04 24             	mov    %eax,(%esp)
f01013d4:	e8 38 fd ff ff       	call   f0101111 <page_insert>
f01013d9:	85 c0                	test   %eax,%eax
f01013db:	74 24                	je     f0101401 <page_check+0x270>
f01013dd:	c7 44 24 0c 68 53 10 	movl   $0xf0105368,0xc(%esp)
f01013e4:	f0 
f01013e5:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01013ec:	f0 
f01013ed:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f01013f4:	00 
f01013f5:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01013fc:	e8 7f ec ff ff       	call   f0100080 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0101401:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f0101406:	8b 08                	mov    (%eax),%ecx
f0101408:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010140e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101411:	2b 15 cc bb 1a f0    	sub    0xf01abbcc,%edx
f0101417:	c1 fa 02             	sar    $0x2,%edx
f010141a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0101420:	c1 e2 0c             	shl    $0xc,%edx
f0101423:	39 d1                	cmp    %edx,%ecx
f0101425:	74 24                	je     f010144b <page_check+0x2ba>
f0101427:	c7 44 24 0c 94 53 10 	movl   $0xf0105394,0xc(%esp)
f010142e:	f0 
f010142f:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101436:	f0 
f0101437:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f010143e:	00 
f010143f:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101446:	e8 35 ec ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f010144b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101450:	e8 84 f6 ff ff       	call   f0100ad9 <check_va2pa>
f0101455:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101458:	89 d1                	mov    %edx,%ecx
f010145a:	2b 0d cc bb 1a f0    	sub    0xf01abbcc,%ecx
f0101460:	c1 f9 02             	sar    $0x2,%ecx
f0101463:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0101469:	c1 e1 0c             	shl    $0xc,%ecx
f010146c:	39 c8                	cmp    %ecx,%eax
f010146e:	74 24                	je     f0101494 <page_check+0x303>
f0101470:	c7 44 24 0c bc 53 10 	movl   $0xf01053bc,0xc(%esp)
f0101477:	f0 
f0101478:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f010147f:	f0 
f0101480:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101487:	00 
f0101488:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f010148f:	e8 ec eb ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 1);
f0101494:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101499:	74 24                	je     f01014bf <page_check+0x32e>
f010149b:	c7 44 24 0c 69 57 10 	movl   $0xf0105769,0xc(%esp)
f01014a2:	f0 
f01014a3:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01014aa:	f0 
f01014ab:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f01014b2:	00 
f01014b3:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01014ba:	e8 c1 eb ff ff       	call   f0100080 <_panic>
	assert(pp0->pp_ref == 1);
f01014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01014c2:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f01014c7:	74 24                	je     f01014ed <page_check+0x35c>
f01014c9:	c7 44 24 0c 7a 57 10 	movl   $0xf010577a,0xc(%esp)
f01014d0:	f0 
f01014d1:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01014d8:	f0 
f01014d9:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f01014e0:	00 
f01014e1:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01014e8:	e8 93 eb ff ff       	call   f0100080 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f01014ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01014f4:	00 
f01014f5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014fc:	00 
f01014fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101500:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101504:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f0101509:	89 04 24             	mov    %eax,(%esp)
f010150c:	e8 00 fc ff ff       	call   f0101111 <page_insert>
f0101511:	85 c0                	test   %eax,%eax
f0101513:	74 24                	je     f0101539 <page_check+0x3a8>
f0101515:	c7 44 24 0c ec 53 10 	movl   $0xf01053ec,0xc(%esp)
f010151c:	f0 
f010151d:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101524:	f0 
f0101525:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f010152c:	00 
f010152d:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101534:	e8 47 eb ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101539:	ba 00 10 00 00       	mov    $0x1000,%edx
f010153e:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f0101543:	e8 91 f5 ff ff       	call   f0100ad9 <check_va2pa>
f0101548:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010154b:	89 d1                	mov    %edx,%ecx
f010154d:	2b 0d cc bb 1a f0    	sub    0xf01abbcc,%ecx
f0101553:	c1 f9 02             	sar    $0x2,%ecx
f0101556:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f010155c:	c1 e1 0c             	shl    $0xc,%ecx
f010155f:	39 c8                	cmp    %ecx,%eax
f0101561:	74 24                	je     f0101587 <page_check+0x3f6>
f0101563:	c7 44 24 0c 24 54 10 	movl   $0xf0105424,0xc(%esp)
f010156a:	f0 
f010156b:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101572:	f0 
f0101573:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f010157a:	00 
f010157b:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101582:	e8 f9 ea ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f0101587:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f010158c:	74 24                	je     f01015b2 <page_check+0x421>
f010158e:	c7 44 24 0c 8b 57 10 	movl   $0xf010578b,0xc(%esp)
f0101595:	f0 
f0101596:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f010159d:	f0 
f010159e:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f01015a5:	00 
f01015a6:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01015ad:	e8 ce ea ff ff       	call   f0100080 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01015b5:	89 04 24             	mov    %eax,(%esp)
f01015b8:	e8 9e f7 ff ff       	call   f0100d5b <page_alloc>
f01015bd:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01015c0:	74 24                	je     f01015e6 <page_check+0x455>
f01015c2:	c7 44 24 0c 4c 57 10 	movl   $0xf010574c,0xc(%esp)
f01015c9:	f0 
f01015ca:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01015d1:	f0 
f01015d2:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f01015d9:	00 
f01015da:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01015e1:	e8 9a ea ff ff       	call   f0100080 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f01015e6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01015ed:	00 
f01015ee:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015f5:	00 
f01015f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01015f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015fd:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f0101602:	89 04 24             	mov    %eax,(%esp)
f0101605:	e8 07 fb ff ff       	call   f0101111 <page_insert>
f010160a:	85 c0                	test   %eax,%eax
f010160c:	74 24                	je     f0101632 <page_check+0x4a1>
f010160e:	c7 44 24 0c ec 53 10 	movl   $0xf01053ec,0xc(%esp)
f0101615:	f0 
f0101616:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f010161d:	f0 
f010161e:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0101625:	00 
f0101626:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f010162d:	e8 4e ea ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101632:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101637:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f010163c:	e8 98 f4 ff ff       	call   f0100ad9 <check_va2pa>
f0101641:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101644:	89 d1                	mov    %edx,%ecx
f0101646:	2b 0d cc bb 1a f0    	sub    0xf01abbcc,%ecx
f010164c:	c1 f9 02             	sar    $0x2,%ecx
f010164f:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0101655:	c1 e1 0c             	shl    $0xc,%ecx
f0101658:	39 c8                	cmp    %ecx,%eax
f010165a:	74 24                	je     f0101680 <page_check+0x4ef>
f010165c:	c7 44 24 0c 24 54 10 	movl   $0xf0105424,0xc(%esp)
f0101663:	f0 
f0101664:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f010166b:	f0 
f010166c:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101673:	00 
f0101674:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f010167b:	e8 00 ea ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f0101680:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101685:	74 24                	je     f01016ab <page_check+0x51a>
f0101687:	c7 44 24 0c 8b 57 10 	movl   $0xf010578b,0xc(%esp)
f010168e:	f0 
f010168f:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101696:	f0 
f0101697:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f010169e:	00 
f010169f:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01016a6:	e8 d5 e9 ff ff       	call   f0100080 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f01016ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01016ae:	89 04 24             	mov    %eax,(%esp)
f01016b1:	e8 a5 f6 ff ff       	call   f0100d5b <page_alloc>
f01016b6:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01016b9:	74 24                	je     f01016df <page_check+0x54e>
f01016bb:	c7 44 24 0c 4c 57 10 	movl   $0xf010574c,0xc(%esp)
f01016c2:	f0 
f01016c3:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01016ca:	f0 
f01016cb:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f01016d2:	00 
f01016d3:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01016da:	e8 a1 e9 ff ff       	call   f0100080 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f01016df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01016e6:	00 
f01016e7:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01016ee:	00 
f01016ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01016f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016f6:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01016fb:	89 04 24             	mov    %eax,(%esp)
f01016fe:	e8 0e fa ff ff       	call   f0101111 <page_insert>
f0101703:	85 c0                	test   %eax,%eax
f0101705:	78 24                	js     f010172b <page_check+0x59a>
f0101707:	c7 44 24 0c 54 54 10 	movl   $0xf0105454,0xc(%esp)
f010170e:	f0 
f010170f:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101716:	f0 
f0101717:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f010171e:	00 
f010171f:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101726:	e8 55 e9 ff ff       	call   f0100080 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010172b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101732:	00 
f0101733:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010173a:	00 
f010173b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010173e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101742:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f0101747:	89 04 24             	mov    %eax,(%esp)
f010174a:	e8 c2 f9 ff ff       	call   f0101111 <page_insert>
f010174f:	85 c0                	test   %eax,%eax
f0101751:	74 24                	je     f0101777 <page_check+0x5e6>
f0101753:	c7 44 24 0c 88 54 10 	movl   $0xf0105488,0xc(%esp)
f010175a:	f0 
f010175b:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101762:	f0 
f0101763:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f010176a:	00 
f010176b:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101772:	e8 09 e9 ff ff       	call   f0100080 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0101777:	ba 00 00 00 00       	mov    $0x0,%edx
f010177c:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f0101781:	e8 53 f3 ff ff       	call   f0100ad9 <check_va2pa>
f0101786:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101789:	2b 15 cc bb 1a f0    	sub    0xf01abbcc,%edx
f010178f:	c1 fa 02             	sar    $0x2,%edx
f0101792:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0101798:	c1 e2 0c             	shl    $0xc,%edx
f010179b:	39 d0                	cmp    %edx,%eax
f010179d:	74 24                	je     f01017c3 <page_check+0x632>
f010179f:	c7 44 24 0c c0 54 10 	movl   $0xf01054c0,0xc(%esp)
f01017a6:	f0 
f01017a7:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01017ae:	f0 
f01017af:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f01017b6:	00 
f01017b7:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01017be:	e8 bd e8 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f01017c3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017c8:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01017cd:	e8 07 f3 ff ff       	call   f0100ad9 <check_va2pa>
f01017d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01017d5:	89 d1                	mov    %edx,%ecx
f01017d7:	2b 0d cc bb 1a f0    	sub    0xf01abbcc,%ecx
f01017dd:	c1 f9 02             	sar    $0x2,%ecx
f01017e0:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f01017e6:	c1 e1 0c             	shl    $0xc,%ecx
f01017e9:	39 c8                	cmp    %ecx,%eax
f01017eb:	74 24                	je     f0101811 <page_check+0x680>
f01017ed:	c7 44 24 0c ec 54 10 	movl   $0xf01054ec,0xc(%esp)
f01017f4:	f0 
f01017f5:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01017fc:	f0 
f01017fd:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101804:	00 
f0101805:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f010180c:	e8 6f e8 ff ff       	call   f0100080 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101811:	66 83 7a 08 02       	cmpw   $0x2,0x8(%edx)
f0101816:	74 24                	je     f010183c <page_check+0x6ab>
f0101818:	c7 44 24 0c 9c 57 10 	movl   $0xf010579c,0xc(%esp)
f010181f:	f0 
f0101820:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101827:	f0 
f0101828:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f010182f:	00 
f0101830:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101837:	e8 44 e8 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f010183c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010183f:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101844:	74 24                	je     f010186a <page_check+0x6d9>
f0101846:	c7 44 24 0c ad 57 10 	movl   $0xf01057ad,0xc(%esp)
f010184d:	f0 
f010184e:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101855:	f0 
f0101856:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f010185d:	00 
f010185e:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101865:	e8 16 e8 ff ff       	call   f0100080 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f010186a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010186d:	89 04 24             	mov    %eax,(%esp)
f0101870:	e8 e6 f4 ff ff       	call   f0100d5b <page_alloc>
f0101875:	85 c0                	test   %eax,%eax
f0101877:	75 08                	jne    f0101881 <page_check+0x6f0>
f0101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010187c:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f010187f:	74 24                	je     f01018a5 <page_check+0x714>
f0101881:	c7 44 24 0c 1c 55 10 	movl   $0xf010551c,0xc(%esp)
f0101888:	f0 
f0101889:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101890:	f0 
f0101891:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0101898:	00 
f0101899:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01018a0:	e8 db e7 ff ff       	call   f0100080 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f01018a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018ac:	00 
f01018ad:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01018b2:	89 04 24             	mov    %eax,(%esp)
f01018b5:	e8 fc f7 ff ff       	call   f01010b6 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f01018ba:	ba 00 00 00 00       	mov    $0x0,%edx
f01018bf:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01018c4:	e8 10 f2 ff ff       	call   f0100ad9 <check_va2pa>
f01018c9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01018cc:	74 24                	je     f01018f2 <page_check+0x761>
f01018ce:	c7 44 24 0c 40 55 10 	movl   $0xf0105540,0xc(%esp)
f01018d5:	f0 
f01018d6:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01018dd:	f0 
f01018de:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01018e5:	00 
f01018e6:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01018ed:	e8 8e e7 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f01018f2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018f7:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01018fc:	e8 d8 f1 ff ff       	call   f0100ad9 <check_va2pa>
f0101901:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101904:	89 d1                	mov    %edx,%ecx
f0101906:	2b 0d cc bb 1a f0    	sub    0xf01abbcc,%ecx
f010190c:	c1 f9 02             	sar    $0x2,%ecx
f010190f:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
f0101915:	c1 e1 0c             	shl    $0xc,%ecx
f0101918:	39 c8                	cmp    %ecx,%eax
f010191a:	74 24                	je     f0101940 <page_check+0x7af>
f010191c:	c7 44 24 0c ec 54 10 	movl   $0xf01054ec,0xc(%esp)
f0101923:	f0 
f0101924:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f010192b:	f0 
f010192c:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101933:	00 
f0101934:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f010193b:	e8 40 e7 ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 1);
f0101940:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101945:	74 24                	je     f010196b <page_check+0x7da>
f0101947:	c7 44 24 0c 69 57 10 	movl   $0xf0105769,0xc(%esp)
f010194e:	f0 
f010194f:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101956:	f0 
f0101957:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f010195e:	00 
f010195f:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101966:	e8 15 e7 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f010196b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010196e:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101973:	74 24                	je     f0101999 <page_check+0x808>
f0101975:	c7 44 24 0c ad 57 10 	movl   $0xf01057ad,0xc(%esp)
f010197c:	f0 
f010197d:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101984:	f0 
f0101985:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f010198c:	00 
f010198d:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101994:	e8 e7 e6 ff ff       	call   f0100080 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0101999:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01019a0:	00 
f01019a1:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01019a6:	89 04 24             	mov    %eax,(%esp)
f01019a9:	e8 08 f7 ff ff       	call   f01010b6 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f01019ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01019b3:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01019b8:	e8 1c f1 ff ff       	call   f0100ad9 <check_va2pa>
f01019bd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01019c0:	74 24                	je     f01019e6 <page_check+0x855>
f01019c2:	c7 44 24 0c 40 55 10 	movl   $0xf0105540,0xc(%esp)
f01019c9:	f0 
f01019ca:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f01019d1:	f0 
f01019d2:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f01019d9:	00 
f01019da:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f01019e1:	e8 9a e6 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f01019e6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019eb:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f01019f0:	e8 e4 f0 ff ff       	call   f0100ad9 <check_va2pa>
f01019f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01019f8:	74 24                	je     f0101a1e <page_check+0x88d>
f01019fa:	c7 44 24 0c 64 55 10 	movl   $0xf0105564,0xc(%esp)
f0101a01:	f0 
f0101a02:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101a09:	f0 
f0101a0a:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101a11:	00 
f0101a12:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101a19:	e8 62 e6 ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 0);
f0101a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101a21:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101a26:	74 24                	je     f0101a4c <page_check+0x8bb>
f0101a28:	c7 44 24 0c be 57 10 	movl   $0xf01057be,0xc(%esp)
f0101a2f:	f0 
f0101a30:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101a37:	f0 
f0101a38:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101a3f:	00 
f0101a40:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101a47:	e8 34 e6 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f0101a4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101a4f:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101a54:	74 24                	je     f0101a7a <page_check+0x8e9>
f0101a56:	c7 44 24 0c ad 57 10 	movl   $0xf01057ad,0xc(%esp)
f0101a5d:	f0 
f0101a5e:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101a65:	f0 
f0101a66:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101a6d:	00 
f0101a6e:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101a75:	e8 06 e6 ff ff       	call   f0100080 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f0101a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101a7d:	89 04 24             	mov    %eax,(%esp)
f0101a80:	e8 d6 f2 ff ff       	call   f0100d5b <page_alloc>
f0101a85:	85 c0                	test   %eax,%eax
f0101a87:	75 08                	jne    f0101a91 <page_check+0x900>
f0101a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101a8c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0101a8f:	74 24                	je     f0101ab5 <page_check+0x924>
f0101a91:	c7 44 24 0c 8c 55 10 	movl   $0xf010558c,0xc(%esp)
f0101a98:	f0 
f0101a99:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101aa0:	f0 
f0101aa1:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101aa8:	00 
f0101aa9:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101ab0:	e8 cb e5 ff ff       	call   f0100080 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101ab8:	89 04 24             	mov    %eax,(%esp)
f0101abb:	e8 9b f2 ff ff       	call   f0100d5b <page_alloc>
f0101ac0:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101ac3:	74 24                	je     f0101ae9 <page_check+0x958>
f0101ac5:	c7 44 24 0c 4c 57 10 	movl   $0xf010574c,0xc(%esp)
f0101acc:	f0 
f0101acd:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101ad4:	f0 
f0101ad5:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0101adc:	00 
f0101add:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101ae4:	e8 97 e5 ff ff       	call   f0100080 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0101ae9:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f0101aee:	8b 08                	mov    (%eax),%ecx
f0101af0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101af6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101af9:	2b 15 cc bb 1a f0    	sub    0xf01abbcc,%edx
f0101aff:	c1 fa 02             	sar    $0x2,%edx
f0101b02:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0101b08:	c1 e2 0c             	shl    $0xc,%edx
f0101b0b:	39 d1                	cmp    %edx,%ecx
f0101b0d:	74 24                	je     f0101b33 <page_check+0x9a2>
f0101b0f:	c7 44 24 0c 94 53 10 	movl   $0xf0105394,0xc(%esp)
f0101b16:	f0 
f0101b17:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101b1e:	f0 
f0101b1f:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101b26:	00 
f0101b27:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101b2e:	e8 4d e5 ff ff       	call   f0100080 <_panic>
	boot_pgdir[0] = 0;
f0101b33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0101b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101b3c:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101b41:	74 24                	je     f0101b67 <page_check+0x9d6>
f0101b43:	c7 44 24 0c 7a 57 10 	movl   $0xf010577a,0xc(%esp)
f0101b4a:	f0 
f0101b4b:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101b52:	f0 
f0101b53:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101b5a:	00 
f0101b5b:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101b62:	e8 19 e5 ff ff       	call   f0100080 <_panic>
	pp0->pp_ref = 0;
f0101b67:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0101b6d:	89 1d 18 af 1a f0    	mov    %ebx,0xf01aaf18

	// free the pages we took
	page_free(pp0);
f0101b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101b76:	89 04 24             	mov    %eax,(%esp)
f0101b79:	e8 f3 ee ff ff       	call   f0100a71 <page_free>
	page_free(pp1);
f0101b7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101b81:	89 04 24             	mov    %eax,(%esp)
f0101b84:	e8 e8 ee ff ff       	call   f0100a71 <page_free>
	page_free(pp2);
f0101b89:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101b8c:	89 04 24             	mov    %eax,(%esp)
f0101b8f:	e8 dd ee ff ff       	call   f0100a71 <page_free>

	cprintf("page_check() succeeded!\n");
f0101b94:	c7 04 24 cf 57 10 f0 	movl   $0xf01057cf,(%esp)
f0101b9b:	e8 77 0e 00 00       	call   f0102a17 <cprintf>
}
f0101ba0:	83 c4 34             	add    $0x34,%esp
f0101ba3:	5b                   	pop    %ebx
f0101ba4:	5d                   	pop    %ebp
f0101ba5:	c3                   	ret    

f0101ba6 <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0101ba6:	55                   	push   %ebp
f0101ba7:	89 e5                	mov    %esp,%ebp
f0101ba9:	83 ec 38             	sub    $0x38,%esp
f0101bac:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101baf:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101bb2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// Remove this line when you're ready to test this function.
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f0101bb5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bba:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101bbf:	e8 5c ee ff ff       	call   f0100a20 <boot_alloc>
f0101bc4:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f0101bc6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bcd:	00 
f0101bce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bd5:	00 
f0101bd6:	89 04 24             	mov    %eax,(%esp)
f0101bd9:	e8 f8 2c 00 00       	call   f01048d6 <memset>
	boot_pgdir = pgdir;
f0101bde:	89 1d c8 bb 1a f0    	mov    %ebx,0xf01abbc8
	boot_cr3 = PADDR(pgdir);
f0101be4:	89 d8                	mov    %ebx,%eax
f0101be6:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101bec:	77 20                	ja     f0101c0e <i386_vm_init+0x68>
f0101bee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101bf2:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f0101bf9:	f0 
f0101bfa:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0101c01:	00 
f0101c02:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101c09:	e8 72 e4 ff ff       	call   f0100080 <_panic>
f0101c0e:	05 00 00 00 10       	add    $0x10000000,%eax
f0101c13:	a3 c4 bb 1a f0       	mov    %eax,0xf01abbc4
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f0101c18:	89 c2                	mov    %eax,%edx
f0101c1a:	83 ca 03             	or     $0x3,%edx
f0101c1d:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f0101c23:	83 c8 05             	or     $0x5,%eax
f0101c26:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// pieces:
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed => faults
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_segment(pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0101c2c:	be 00 10 11 f0       	mov    $0xf0111000,%esi
f0101c31:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0101c37:	77 20                	ja     f0101c59 <i386_vm_init+0xb3>
f0101c39:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101c3d:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f0101c44:	f0 
f0101c45:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
f0101c4c:	00 
f0101c4d:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101c54:	e8 27 e4 ff ff       	call   f0100080 <_panic>
f0101c59:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0101c60:	00 
f0101c61:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0101c67:	89 04 24             	mov    %eax,(%esp)
f0101c6a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101c6f:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0101c74:	89 d8                	mov    %ebx,%eax
f0101c76:	e8 dc ef ff ff       	call   f0100c57 <boot_map_segment>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 

	boot_map_segment(pgdir, KERNBASE, 0x10000000UL, 0, PTE_W);
f0101c7b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0101c82:	00 
f0101c83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c8a:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101c8f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101c94:	89 d8                	mov    %ebx,%eax
f0101c96:	e8 bc ef ff ff       	call   f0100c57 <boot_map_segment>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here: 
	
	  n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f0101c9b:	6b 3d c0 bb 1a f0 0c 	imul   $0xc,0xf01abbc0,%edi
f0101ca2:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0101ca8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
          pages = (struct Page *)boot_alloc(n, PGSIZE);
f0101cae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cb3:	89 f8                	mov    %edi,%eax
f0101cb5:	e8 66 ed ff ff       	call   f0100a20 <boot_alloc>
f0101cba:	a3 cc bb 1a f0       	mov    %eax,0xf01abbcc
          memset(pages, 0, PGSIZE);
f0101cbf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cc6:	00 
f0101cc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101cce:	00 
f0101ccf:	89 04 24             	mov    %eax,(%esp)
f0101cd2:	e8 ff 2b 00 00       	call   f01048d6 <memset>
          boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U);
f0101cd7:	a1 cc bb 1a f0       	mov    0xf01abbcc,%eax
f0101cdc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101ce1:	77 20                	ja     f0101d03 <i386_vm_init+0x15d>
f0101ce3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ce7:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f0101cee:	f0 
f0101cef:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
f0101cf6:	00 
f0101cf7:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101cfe:	e8 7d e3 ff ff       	call   f0100080 <_panic>
f0101d03:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0101d0a:	00 
f0101d0b:	05 00 00 00 10       	add    $0x10000000,%eax
f0101d10:	89 04 24             	mov    %eax,(%esp)
f0101d13:	89 f9                	mov    %edi,%ecx
f0101d15:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101d1a:	89 d8                	mov    %ebx,%eax
f0101d1c:	e8 36 ef ff ff       	call   f0100c57 <boot_map_segment>
	//    - the image of envs mapped at UENVS  -- kernel R, user R
	
	// LAB 3: Your code here.   

          n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
          envs = boot_alloc(n, PGSIZE);
f0101d21:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d26:	b8 00 20 02 00       	mov    $0x22000,%eax
f0101d2b:	e8 f0 ec ff ff       	call   f0100a20 <boot_alloc>
f0101d30:	a3 20 af 1a f0       	mov    %eax,0xf01aaf20
          memset(envs, 0, PGSIZE);
f0101d35:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d3c:	00 
f0101d3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101d44:	00 
f0101d45:	89 04 24             	mov    %eax,(%esp)
f0101d48:	e8 89 2b 00 00       	call   f01048d6 <memset>
          boot_map_segment(pgdir, UENVS, n, PADDR(envs), PTE_U);
f0101d4d:	a1 20 af 1a f0       	mov    0xf01aaf20,%eax
f0101d52:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101d57:	77 20                	ja     f0101d79 <i386_vm_init+0x1d3>
f0101d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d5d:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f0101d64:	f0 
f0101d65:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
f0101d6c:	00 
f0101d6d:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101d74:	e8 07 e3 ff ff       	call   f0100080 <_panic>
f0101d79:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0101d80:	00 
f0101d81:	05 00 00 00 10       	add    $0x10000000,%eax
f0101d86:	89 04 24             	mov    %eax,(%esp)
f0101d89:	b9 00 20 02 00       	mov    $0x22000,%ecx
f0101d8e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0101d93:	89 d8                	mov    %ebx,%eax
f0101d95:	e8 bd ee ff ff       	call   f0100c57 <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f0101d9a:	a1 c8 bb 1a f0       	mov    0xf01abbc8,%eax
f0101d9f:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f0101da2:	6b 05 c0 bb 1a f0 0c 	imul   $0xc,0xf01abbc0,%eax
f0101da9:	05 ff 0f 00 00       	add    $0xfff,%eax
	for (i = 0; i < n; i += PGSIZE)
f0101dae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101db3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101db6:	0f 84 83 00 00 00    	je     f0101e3f <i386_vm_init+0x299>
f0101dbc:	bf 00 00 00 00       	mov    $0x0,%edi
f0101dc1:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0101dc4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101dc7:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f0101dcd:	89 d8                	mov    %ebx,%eax
f0101dcf:	e8 05 ed ff ff       	call   f0100ad9 <check_va2pa>
f0101dd4:	8b 15 cc bb 1a f0    	mov    0xf01abbcc,%edx
f0101dda:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101de0:	77 20                	ja     f0101e02 <i386_vm_init+0x25c>
f0101de2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101de6:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f0101ded:	f0 
f0101dee:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
f0101df5:	00 
f0101df6:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101dfd:	e8 7e e2 ff ff       	call   f0100080 <_panic>
f0101e02:	8d 94 17 00 00 00 10 	lea    0x10000000(%edi,%edx,1),%edx
f0101e09:	39 d0                	cmp    %edx,%eax
f0101e0b:	74 24                	je     f0101e31 <i386_vm_init+0x28b>
f0101e0d:	c7 44 24 0c b0 55 10 	movl   $0xf01055b0,0xc(%esp)
f0101e14:	f0 
f0101e15:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101e1c:	f0 
f0101e1d:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
f0101e24:	00 
f0101e25:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101e2c:	e8 4f e2 ff ff       	call   f0100080 <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101e31:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101e37:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
f0101e3a:	77 8b                	ja     f0101dc7 <i386_vm_init+0x221>
f0101e3c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101e3f:	bf 00 00 00 00       	mov    $0x0,%edi
f0101e44:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101e47:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101e4a:	8d 97 00 00 c0 ee    	lea    -0x11400000(%edi),%edx
f0101e50:	89 d8                	mov    %ebx,%eax
f0101e52:	e8 82 ec ff ff       	call   f0100ad9 <check_va2pa>
f0101e57:	8b 15 20 af 1a f0    	mov    0xf01aaf20,%edx
f0101e5d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101e63:	77 20                	ja     f0101e85 <i386_vm_init+0x2df>
f0101e65:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101e69:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f0101e70:	f0 
f0101e71:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0101e78:	00 
f0101e79:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101e80:	e8 fb e1 ff ff       	call   f0100080 <_panic>
f0101e85:	8d 94 17 00 00 00 10 	lea    0x10000000(%edi,%edx,1),%edx
f0101e8c:	39 d0                	cmp    %edx,%eax
f0101e8e:	74 24                	je     f0101eb4 <i386_vm_init+0x30e>
f0101e90:	c7 44 24 0c e4 55 10 	movl   $0xf01055e4,0xc(%esp)
f0101e97:	f0 
f0101e98:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101e9f:	f0 
f0101ea0:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0101ea7:	00 
f0101ea8:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101eaf:	e8 cc e1 ff ff       	call   f0100080 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101eb4:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101eba:	81 ff 00 20 02 00    	cmp    $0x22000,%edi
f0101ec0:	75 88                	jne    f0101e4a <i386_vm_init+0x2a4>
f0101ec2:	bf 00 00 00 00       	mov    $0x0,%edi
f0101ec7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101eca:	8d 97 00 00 00 f0    	lea    -0x10000000(%edi),%edx
f0101ed0:	89 d8                	mov    %ebx,%eax
f0101ed2:	e8 02 ec ff ff       	call   f0100ad9 <check_va2pa>
f0101ed7:	39 c7                	cmp    %eax,%edi
f0101ed9:	74 24                	je     f0101eff <i386_vm_init+0x359>
f0101edb:	c7 44 24 0c 18 56 10 	movl   $0xf0105618,0xc(%esp)
f0101ee2:	f0 
f0101ee3:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101eea:	f0 
f0101eeb:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f0101ef2:	00 
f0101ef3:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101efa:	e8 81 e1 ff ff       	call   f0100080 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
f0101eff:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101f05:	81 ff 00 00 00 10    	cmp    $0x10000000,%edi
f0101f0b:	75 bd                	jne    f0101eca <i386_vm_init+0x324>
f0101f0d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101f10:	bf 00 80 bf ef       	mov    $0xefbf8000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0101f15:	81 c6 00 80 40 20    	add    $0x20408000,%esi
f0101f1b:	89 fa                	mov    %edi,%edx
f0101f1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101f20:	e8 b4 eb ff ff       	call   f0100ad9 <check_va2pa>
f0101f25:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f0101f28:	39 d0                	cmp    %edx,%eax
f0101f2a:	74 24                	je     f0101f50 <i386_vm_init+0x3aa>
f0101f2c:	c7 44 24 0c 40 56 10 	movl   $0xf0105640,0xc(%esp)
f0101f33:	f0 
f0101f34:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101f3b:	f0 
f0101f3c:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0101f43:	00 
f0101f44:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101f4b:	e8 30 e1 ff ff       	call   f0100080 <_panic>
f0101f50:	81 c7 00 10 00 00    	add    $0x1000,%edi
	// check phys mem
	for (i = 0; KERNBASE + i != 0; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101f56:	81 ff 00 00 c0 ef    	cmp    $0xefc00000,%edi
f0101f5c:	75 bd                	jne    f0101f1b <i386_vm_init+0x375>
f0101f5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101f63:	8b 4d e0             	mov    -0x20(%ebp),%ecx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0101f66:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0101f6c:	83 fa 04             	cmp    $0x4,%edx
f0101f6f:	77 2a                	ja     f0101f9b <i386_vm_init+0x3f5>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i]);
f0101f71:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101f75:	75 7f                	jne    f0101ff6 <i386_vm_init+0x450>
f0101f77:	c7 44 24 0c e8 57 10 	movl   $0xf01057e8,0xc(%esp)
f0101f7e:	f0 
f0101f7f:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101f86:	f0 
f0101f87:	c7 44 24 04 7e 01 00 	movl   $0x17e,0x4(%esp)
f0101f8e:	00 
f0101f8f:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101f96:	e8 e5 e0 ff ff       	call   f0100080 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f0101f9b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0101fa0:	76 2a                	jbe    f0101fcc <i386_vm_init+0x426>
				assert(pgdir[i]);
f0101fa2:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101fa6:	75 4e                	jne    f0101ff6 <i386_vm_init+0x450>
f0101fa8:	c7 44 24 0c e8 57 10 	movl   $0xf01057e8,0xc(%esp)
f0101faf:	f0 
f0101fb0:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101fb7:	f0 
f0101fb8:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f0101fbf:	00 
f0101fc0:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101fc7:	e8 b4 e0 ff ff       	call   f0100080 <_panic>
			else
				assert(pgdir[i] == 0);
f0101fcc:	83 3c 81 00          	cmpl   $0x0,(%ecx,%eax,4)
f0101fd0:	74 24                	je     f0101ff6 <i386_vm_init+0x450>
f0101fd2:	c7 44 24 0c f1 57 10 	movl   $0xf01057f1,0xc(%esp)
f0101fd9:	f0 
f0101fda:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0101fe1:	f0 
f0101fe2:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
f0101fe9:	00 
f0101fea:	c7 04 24 c9 56 10 f0 	movl   $0xf01056c9,(%esp)
f0101ff1:	e8 8a e0 ff ff       	call   f0100080 <_panic>
	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f0101ff6:	83 c0 01             	add    $0x1,%eax
f0101ff9:	3d 00 04 00 00       	cmp    $0x400,%eax
f0101ffe:	0f 85 62 ff ff ff    	jne    f0101f66 <i386_vm_init+0x3c0>
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f0102004:	c7 04 24 88 56 10 f0 	movl   $0xf0105688,(%esp)
f010200b:	e8 07 0a 00 00       	call   f0102a17 <cprintf>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f0102010:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f0102016:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102018:	a1 c4 bb 1a f0       	mov    0xf01abbc4,%eax
f010201d:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102020:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f0102023:	0d 2f 00 05 80       	or     $0x8005002f,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102028:	83 e0 f3             	and    $0xfffffff3,%eax
f010202b:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f010202e:	0f 01 15 50 93 11 f0 	lgdtl  0xf0119350
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102035:	b8 23 00 00 00       	mov    $0x23,%eax
f010203a:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010203c:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010203e:	b0 10                	mov    $0x10,%al
f0102040:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102042:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102044:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f0102046:	ea 4d 20 10 f0 08 00 	ljmp   $0x8,$0xf010204d
	asm volatile("lldt %%ax" :: "a" (0));
f010204d:	b0 00                	mov    $0x0,%al
f010204f:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f0102052:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102058:	a1 c4 bb 1a f0       	mov    0xf01abbc4,%eax
f010205d:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}
f0102060:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0102063:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102066:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0102069:	89 ec                	mov    %ebp,%esp
f010206b:	5d                   	pop    %ebp
f010206c:	c3                   	ret    

f010206d <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f010206d:	55                   	push   %ebp
f010206e:	89 e5                	mov    %esp,%ebp
f0102070:	83 ec 18             	sub    $0x18,%esp
f0102073:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0102076:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0102079:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010207b:	89 04 24             	mov    %eax,(%esp)
f010207e:	e8 e9 07 00 00       	call   f010286c <mc146818_read>
f0102083:	89 c6                	mov    %eax,%esi
f0102085:	83 c3 01             	add    $0x1,%ebx
f0102088:	89 1c 24             	mov    %ebx,(%esp)
f010208b:	e8 dc 07 00 00       	call   f010286c <mc146818_read>
f0102090:	c1 e0 08             	shl    $0x8,%eax
f0102093:	09 f0                	or     %esi,%eax
}
f0102095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0102098:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010209b:	89 ec                	mov    %ebp,%esp
f010209d:	5d                   	pop    %ebp
f010209e:	c3                   	ret    

f010209f <i386_detect_memory>:

void
i386_detect_memory(void)
{
f010209f:	55                   	push   %ebp
f01020a0:	89 e5                	mov    %esp,%ebp
f01020a2:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f01020a5:	b8 15 00 00 00       	mov    $0x15,%eax
f01020aa:	e8 be ff ff ff       	call   f010206d <nvram_read>
f01020af:	c1 e0 0a             	shl    $0xa,%eax
f01020b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01020b7:	a3 0c af 1a f0       	mov    %eax,0xf01aaf0c
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f01020bc:	b8 17 00 00 00       	mov    $0x17,%eax
f01020c1:	e8 a7 ff ff ff       	call   f010206d <nvram_read>
f01020c6:	c1 e0 0a             	shl    $0xa,%eax
f01020c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01020ce:	a3 10 af 1a f0       	mov    %eax,0xf01aaf10

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f01020d3:	85 c0                	test   %eax,%eax
f01020d5:	74 0c                	je     f01020e3 <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f01020d7:	05 00 00 10 00       	add    $0x100000,%eax
f01020dc:	a3 08 af 1a f0       	mov    %eax,0xf01aaf08
f01020e1:	eb 0a                	jmp    f01020ed <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f01020e3:	a1 0c af 1a f0       	mov    0xf01aaf0c,%eax
f01020e8:	a3 08 af 1a f0       	mov    %eax,0xf01aaf08

	npage = maxpa / PGSIZE;
f01020ed:	a1 08 af 1a f0       	mov    0xf01aaf08,%eax
f01020f2:	89 c2                	mov    %eax,%edx
f01020f4:	c1 ea 0c             	shr    $0xc,%edx
f01020f7:	89 15 c0 bb 1a f0    	mov    %edx,0xf01abbc0

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f01020fd:	c1 e8 0a             	shr    $0xa,%eax
f0102100:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102104:	c7 04 24 a8 56 10 f0 	movl   $0xf01056a8,(%esp)
f010210b:	e8 07 09 00 00       	call   f0102a17 <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0102110:	a1 10 af 1a f0       	mov    0xf01aaf10,%eax
f0102115:	c1 e8 0a             	shr    $0xa,%eax
f0102118:	89 44 24 08          	mov    %eax,0x8(%esp)
f010211c:	a1 0c af 1a f0       	mov    0xf01aaf0c,%eax
f0102121:	c1 e8 0a             	shr    $0xa,%eax
f0102124:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102128:	c7 04 24 ff 57 10 f0 	movl   $0xf01057ff,(%esp)
f010212f:	e8 e3 08 00 00       	call   f0102a17 <cprintf>
}
f0102134:	c9                   	leave  
f0102135:	c3                   	ret    
	...

f0102140 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int    
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102140:	55                   	push   %ebp
f0102141:	89 e5                	mov    %esp,%ebp
f0102143:	53                   	push   %ebx
f0102144:	8b 45 08             	mov    0x8(%ebp),%eax
f0102147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010214a:	85 c0                	test   %eax,%eax
f010214c:	75 0e                	jne    f010215c <envid2env+0x1c>
		*env_store = curenv;
f010214e:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0102153:	89 01                	mov    %eax,(%ecx)
f0102155:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f010215a:	eb 5b                	jmp    f01021b7 <envid2env+0x77>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010215c:	89 c2                	mov    %eax,%edx
f010215e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102164:	89 d3                	mov    %edx,%ebx
f0102166:	c1 e3 07             	shl    $0x7,%ebx
f0102169:	8d 14 d3             	lea    (%ebx,%edx,8),%edx
f010216c:	03 15 20 af 1a f0    	add    0xf01aaf20,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102172:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102176:	74 05                	je     f010217d <envid2env+0x3d>
f0102178:	39 42 4c             	cmp    %eax,0x4c(%edx)
f010217b:	74 0d                	je     f010218a <envid2env+0x4a>
		*env_store = 0;
f010217d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0102183:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0102188:	eb 2d                	jmp    f01021b7 <envid2env+0x77>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010218a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010218e:	66 90                	xchg   %ax,%ax
f0102190:	74 1e                	je     f01021b0 <envid2env+0x70>
f0102192:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0102197:	39 c2                	cmp    %eax,%edx
f0102199:	74 15                	je     f01021b0 <envid2env+0x70>
f010219b:	8b 5a 50             	mov    0x50(%edx),%ebx
f010219e:	3b 58 4c             	cmp    0x4c(%eax),%ebx
f01021a1:	74 0d                	je     f01021b0 <envid2env+0x70>
		*env_store = 0;
f01021a3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f01021a9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f01021ae:	eb 07                	jmp    f01021b7 <envid2env+0x77>
	}

	*env_store = e;
f01021b0:	89 11                	mov    %edx,(%ecx)
f01021b2:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01021b7:	5b                   	pop    %ebx
f01021b8:	5d                   	pop    %ebp
f01021b9:	c3                   	ret    

f01021ba <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f01021ba:	55                   	push   %ebp
f01021bb:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
        
	//init the list
        LIST_INIT(&env_free_list);
f01021bd:	c7 05 28 af 1a f0 00 	movl   $0x0,0xf01aaf28
f01021c4:	00 00 00 
f01021c7:	b8 78 1f 02 00       	mov    $0x21f78,%eax
        // setup free environments
        int i;
        for( i = NENV - 1; i >= 0; i--) 
        {
             //set env as free
             envs[i].env_status = ENV_FREE;
f01021cc:	8b 15 20 af 1a f0    	mov    0xf01aaf20,%edx
f01021d2:	c7 44 02 54 00 00 00 	movl   $0x0,0x54(%edx,%eax,1)
f01021d9:	00 
             //set env_ids to 0
             envs[i].env_id = 0; 
f01021da:	8b 15 20 af 1a f0    	mov    0xf01aaf20,%edx
f01021e0:	c7 44 02 4c 00 00 00 	movl   $0x0,0x4c(%edx,%eax,1)
f01021e7:	00 
             //append head of list
             LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f01021e8:	8b 15 28 af 1a f0    	mov    0xf01aaf28,%edx
f01021ee:	8b 0d 20 af 1a f0    	mov    0xf01aaf20,%ecx
f01021f4:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
f01021f8:	85 d2                	test   %edx,%edx
f01021fa:	74 14                	je     f0102210 <env_init+0x56>
f01021fc:	89 c1                	mov    %eax,%ecx
f01021fe:	03 0d 20 af 1a f0    	add    0xf01aaf20,%ecx
f0102204:	83 c1 44             	add    $0x44,%ecx
f0102207:	8b 15 28 af 1a f0    	mov    0xf01aaf28,%edx
f010220d:	89 4a 48             	mov    %ecx,0x48(%edx)
f0102210:	89 c2                	mov    %eax,%edx
f0102212:	03 15 20 af 1a f0    	add    0xf01aaf20,%edx
f0102218:	89 15 28 af 1a f0    	mov    %edx,0xf01aaf28
f010221e:	c7 42 48 28 af 1a f0 	movl   $0xf01aaf28,0x48(%edx)
f0102225:	2d 88 00 00 00       	sub    $0x88,%eax
	//init the list
        LIST_INIT(&env_free_list);
	
        // setup free environments
        int i;
        for( i = NENV - 1; i >= 0; i--) 
f010222a:	3d 78 ff ff ff       	cmp    $0xffffff78,%eax
f010222f:	75 9b                	jne    f01021cc <env_init+0x12>
             //set env_ids to 0
             envs[i].env_id = 0; 
             //append head of list
             LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
        }
}
f0102231:	5d                   	pop    %ebp
f0102232:	c3                   	ret    

f0102233 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102233:	55                   	push   %ebp
f0102234:	89 e5                	mov    %esp,%ebp
f0102236:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102239:	8b 65 08             	mov    0x8(%ebp),%esp
f010223c:	61                   	popa   
f010223d:	07                   	pop    %es
f010223e:	1f                   	pop    %ds
f010223f:	83 c4 08             	add    $0x8,%esp
f0102242:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102243:	c7 44 24 08 1b 58 10 	movl   $0xf010581b,0x8(%esp)
f010224a:	f0 
f010224b:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f0102252:	00 
f0102253:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f010225a:	e8 21 de ff ff       	call   f0100080 <_panic>

f010225f <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f010225f:	55                   	push   %ebp
f0102260:	89 e5                	mov    %esp,%ebp
f0102262:	83 ec 18             	sub    $0x18,%esp
f0102265:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.

        // Step 1
        curenv = e;
f0102268:	a3 24 af 1a f0       	mov    %eax,0xf01aaf24
        curenv->env_runs++;
f010226d:	83 40 58 01          	addl   $0x1,0x58(%eax)
        lcr3(curenv->env_cr3);
f0102271:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0102276:	8b 50 60             	mov    0x60(%eax),%edx
f0102279:	0f 22 da             	mov    %edx,%cr3
       
	 //Step 2
        env_pop_tf(&curenv->env_tf);
f010227c:	89 04 24             	mov    %eax,(%esp)
f010227f:	e8 af ff ff ff       	call   f0102233 <env_pop_tf>

f0102284 <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0102284:	55                   	push   %ebp
f0102285:	89 e5                	mov    %esp,%ebp
f0102287:	57                   	push   %edi
f0102288:	56                   	push   %esi
f0102289:	53                   	push   %ebx
f010228a:	83 ec 2c             	sub    $0x2c,%esp
f010228d:	8b 7d 08             	mov    0x8(%ebp),%edi
	pte_t *pt;
	uint32_t pdeno, pteno;
	physaddr_t pa;

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102290:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0102293:	8b 15 24 af 1a f0    	mov    0xf01aaf24,%edx
f0102299:	b8 00 00 00 00       	mov    $0x0,%eax
f010229e:	85 d2                	test   %edx,%edx
f01022a0:	74 03                	je     f01022a5 <env_free+0x21>
f01022a2:	8b 42 4c             	mov    0x4c(%edx),%eax
f01022a5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01022a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022ad:	c7 04 24 32 58 10 f0 	movl   $0xf0105832,(%esp)
f01022b4:	e8 5e 07 00 00       	call   f0102a17 <cprintf>
f01022b9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01022c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01022c3:	c1 e0 02             	shl    $0x2,%eax
f01022c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01022c9:	8b 47 5c             	mov    0x5c(%edi),%eax
f01022cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01022cf:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01022d2:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01022d8:	0f 84 bb 00 00 00    	je     f0102399 <env_free+0x115>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01022de:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f01022e4:	89 f0                	mov    %esi,%eax
f01022e6:	c1 e8 0c             	shr    $0xc,%eax
f01022e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01022ec:	3b 05 c0 bb 1a f0    	cmp    0xf01abbc0,%eax
f01022f2:	72 20                	jb     f0102314 <env_free+0x90>
f01022f4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01022f8:	c7 44 24 08 44 52 10 	movl   $0xf0105244,0x8(%esp)
f01022ff:	f0 
f0102300:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0102307:	00 
f0102308:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f010230f:	e8 6c dd ff ff       	call   f0100080 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102314:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102317:	c1 e2 16             	shl    $0x16,%edx
f010231a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010231d:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0102322:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102329:	01 
f010232a:	74 17                	je     f0102343 <env_free+0xbf>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010232c:	89 d8                	mov    %ebx,%eax
f010232e:	c1 e0 0c             	shl    $0xc,%eax
f0102331:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102334:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102338:	8b 47 5c             	mov    0x5c(%edi),%eax
f010233b:	89 04 24             	mov    %eax,(%esp)
f010233e:	e8 73 ed ff ff       	call   f01010b6 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102343:	83 c3 01             	add    $0x1,%ebx
f0102346:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010234c:	75 d4                	jne    f0102322 <env_free+0x9e>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010234e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102351:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102354:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f010235b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010235e:	3b 05 c0 bb 1a f0    	cmp    0xf01abbc0,%eax
f0102364:	72 1c                	jb     f0102382 <env_free+0xfe>
		panic("pa2page called with invalid pa");
f0102366:	c7 44 24 08 c4 52 10 	movl   $0xf01052c4,0x8(%esp)
f010236d:	f0 
f010236e:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0102375:	00 
f0102376:	c7 04 24 d5 56 10 f0 	movl   $0xf01056d5,(%esp)
f010237d:	e8 fe dc ff ff       	call   f0100080 <_panic>
		page_decref(pa2page(pa));
f0102382:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102385:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102388:	c1 e0 02             	shl    $0x2,%eax
f010238b:	03 05 cc bb 1a f0    	add    0xf01abbcc,%eax
f0102391:	89 04 24             	mov    %eax,(%esp)
f0102394:	e8 01 e7 ff ff       	call   f0100a9a <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102399:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010239d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01023a4:	0f 85 16 ff ff ff    	jne    f01022c0 <env_free+0x3c>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f01023aa:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f01023ad:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f01023b4:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f01023bb:	c1 e8 0c             	shr    $0xc,%eax
f01023be:	3b 05 c0 bb 1a f0    	cmp    0xf01abbc0,%eax
f01023c4:	72 1c                	jb     f01023e2 <env_free+0x15e>
		panic("pa2page called with invalid pa");
f01023c6:	c7 44 24 08 c4 52 10 	movl   $0xf01052c4,0x8(%esp)
f01023cd:	f0 
f01023ce:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f01023d5:	00 
f01023d6:	c7 04 24 d5 56 10 f0 	movl   $0xf01056d5,(%esp)
f01023dd:	e8 9e dc ff ff       	call   f0100080 <_panic>
	page_decref(pa2page(pa));
f01023e2:	6b c0 0c             	imul   $0xc,%eax,%eax
f01023e5:	03 05 cc bb 1a f0    	add    0xf01abbcc,%eax
f01023eb:	89 04 24             	mov    %eax,(%esp)
f01023ee:	e8 a7 e6 ff ff       	call   f0100a9a <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01023f3:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f01023fa:	a1 28 af 1a f0       	mov    0xf01aaf28,%eax
f01023ff:	89 47 44             	mov    %eax,0x44(%edi)
f0102402:	85 c0                	test   %eax,%eax
f0102404:	74 0b                	je     f0102411 <env_free+0x18d>
f0102406:	8d 57 44             	lea    0x44(%edi),%edx
f0102409:	a1 28 af 1a f0       	mov    0xf01aaf28,%eax
f010240e:	89 50 48             	mov    %edx,0x48(%eax)
f0102411:	89 3d 28 af 1a f0    	mov    %edi,0xf01aaf28
f0102417:	c7 47 48 28 af 1a f0 	movl   $0xf01aaf28,0x48(%edi)
}
f010241e:	83 c4 2c             	add    $0x2c,%esp
f0102421:	5b                   	pop    %ebx
f0102422:	5e                   	pop    %esi
f0102423:	5f                   	pop    %edi
f0102424:	5d                   	pop    %ebp
f0102425:	c3                   	ret    

f0102426 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102426:	55                   	push   %ebp
f0102427:	89 e5                	mov    %esp,%ebp
f0102429:	53                   	push   %ebx
f010242a:	83 ec 14             	sub    $0x14,%esp
f010242d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	env_free(e);
f0102430:	89 1c 24             	mov    %ebx,(%esp)
f0102433:	e8 4c fe ff ff       	call   f0102284 <env_free>

	if (curenv == e) {
f0102438:	39 1d 24 af 1a f0    	cmp    %ebx,0xf01aaf24
f010243e:	75 0f                	jne    f010244f <env_destroy+0x29>
		curenv = NULL;
f0102440:	c7 05 24 af 1a f0 00 	movl   $0x0,0xf01aaf24
f0102447:	00 00 00 
		sched_yield();
f010244a:	e8 51 11 00 00       	call   f01035a0 <sched_yield>
	}
}
f010244f:	83 c4 14             	add    $0x14,%esp
f0102452:	5b                   	pop    %ebx
f0102453:	5d                   	pop    %ebp
f0102454:	c3                   	ret    

f0102455 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102455:	55                   	push   %ebp
f0102456:	89 e5                	mov    %esp,%ebp
f0102458:	53                   	push   %ebx
f0102459:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f010245c:	8b 1d 28 af 1a f0    	mov    0xf01aaf28,%ebx
f0102462:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102467:	85 db                	test   %ebx,%ebx
f0102469:	0f 84 aa 01 00 00    	je     f0102619 <env_alloc+0x1c4>
//
static int
env_setup_vm(struct Env *e)  
{
	int i, r;
	struct Page *p = NULL;
f010246f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f0102476:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102479:	89 04 24             	mov    %eax,(%esp)
f010247c:	e8 da e8 ff ff       	call   f0100d5b <page_alloc>
f0102481:	85 c0                	test   %eax,%eax
f0102483:	0f 88 90 01 00 00    	js     f0102619 <env_alloc+0x1c4>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102489:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010248c:	2b 05 cc bb 1a f0    	sub    0xf01abbcc,%eax
f0102492:	c1 f8 02             	sar    $0x2,%eax
f0102495:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010249b:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f010249e:	89 c2                	mov    %eax,%edx
f01024a0:	c1 ea 0c             	shr    $0xc,%edx
f01024a3:	3b 15 c0 bb 1a f0    	cmp    0xf01abbc0,%edx
f01024a9:	72 20                	jb     f01024cb <env_alloc+0x76>
f01024ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024af:	c7 44 24 08 44 52 10 	movl   $0xf0105244,0x8(%esp)
f01024b6:	f0 
f01024b7:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
f01024be:	00 
f01024bf:	c7 04 24 d5 56 10 f0 	movl   $0xf01056d5,(%esp)
f01024c6:	e8 b5 db ff ff       	call   f0100080 <_panic>
	//	mapped above UTOP -- but you do need to increment
	//	env_pgdir's pp_ref!

	// LAB 3: Your code here
        
        e->env_pgdir = page2kva (p);
f01024cb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024d0:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_cr3 = page2pa (p);
f01024d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01024d6:	2b 15 cc bb 1a f0    	sub    0xf01abbcc,%edx
f01024dc:	c1 fa 02             	sar    $0x2,%edx
f01024df:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01024e5:	c1 e2 0c             	shl    $0xc,%edx
f01024e8:	89 53 60             	mov    %edx,0x60(%ebx)
	memmove (e->env_pgdir, boot_pgdir, PGSIZE);
f01024eb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024f2:	00 
f01024f3:	8b 15 c8 bb 1a f0    	mov    0xf01abbc8,%edx
f01024f9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01024fd:	89 04 24             	mov    %eax,(%esp)
f0102500:	e8 1e 24 00 00       	call   f0104923 <memmove>
	memset (e->env_pgdir, 0, PDX(UTOP) * sizeof (pde_t));
f0102505:	c7 44 24 08 ec 0e 00 	movl   $0xeec,0x8(%esp)
f010250c:	00 
f010250d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102514:	00 
f0102515:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102518:	89 04 24             	mov    %eax,(%esp)
f010251b:	e8 b6 23 00 00       	call   f01048d6 <memset>
	p->pp_ref ++;
f0102520:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102523:	66 83 40 08 01       	addw   $0x1,0x8(%eax)

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0102528:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010252b:	8b 53 60             	mov    0x60(%ebx),%edx
f010252e:	83 ca 03             	or     $0x3,%edx
f0102531:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0102537:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010253a:	8b 53 60             	mov    0x60(%ebx),%edx
f010253d:	83 ca 05             	or     $0x5,%edx
f0102540:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102546:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0102549:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010254e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102553:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102558:	0f 4e c2             	cmovle %edx,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f010255b:	89 da                	mov    %ebx,%edx
f010255d:	2b 15 20 af 1a f0    	sub    0xf01aaf20,%edx
f0102563:	c1 fa 03             	sar    $0x3,%edx
f0102566:	69 d2 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%edx,%edx
f010256c:	09 d0                	or     %edx,%eax
f010256e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102571:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102574:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102577:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f010257e:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102585:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010258c:	00 
f010258d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102594:	00 
f0102595:	89 1c 24             	mov    %ebx,(%esp)
f0102598:	e8 39 23 00 00       	call   f01048d6 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f010259d:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01025a3:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01025a9:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01025af:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01025b6:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f01025bc:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01025c3:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01025ca:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// commit the allocation
	LIST_REMOVE(e, env_link);
f01025d1:	8b 43 44             	mov    0x44(%ebx),%eax
f01025d4:	85 c0                	test   %eax,%eax
f01025d6:	74 06                	je     f01025de <env_alloc+0x189>
f01025d8:	8b 53 48             	mov    0x48(%ebx),%edx
f01025db:	89 50 48             	mov    %edx,0x48(%eax)
f01025de:	8b 43 48             	mov    0x48(%ebx),%eax
f01025e1:	8b 53 44             	mov    0x44(%ebx),%edx
f01025e4:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f01025e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01025e9:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01025eb:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f01025ee:	8b 15 24 af 1a f0    	mov    0xf01aaf24,%edx
f01025f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01025f9:	85 d2                	test   %edx,%edx
f01025fb:	74 03                	je     f0102600 <env_alloc+0x1ab>
f01025fd:	8b 42 4c             	mov    0x4c(%edx),%eax
f0102600:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102604:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102608:	c7 04 24 48 58 10 f0 	movl   $0xf0105848,(%esp)
f010260f:	e8 03 04 00 00       	call   f0102a17 <cprintf>
f0102614:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0102619:	83 c4 24             	add    $0x24,%esp
f010261c:	5b                   	pop    %ebx
f010261d:	5d                   	pop    %ebp
f010261e:	c3                   	ret    

f010261f <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f010261f:	55                   	push   %ebp
f0102620:	89 e5                	mov    %esp,%ebp
f0102622:	57                   	push   %edi
f0102623:	56                   	push   %esi
f0102624:	53                   	push   %ebx
f0102625:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 3: Your code here.
        
        struct Env *env = NULL;
f0102628:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        int r;
        // Since we setup the envs linked list so that the first one is
        // envs[0], all we have to do is allocate an environment
        r = env_alloc(&env, 0);
f010262f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102636:	00 
f0102637:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010263a:	89 04 24             	mov    %eax,(%esp)
f010263d:	e8 13 fe ff ff       	call   f0102455 <env_alloc>
        if(r < 0)
f0102642:	85 c0                	test   %eax,%eax
f0102644:	79 20                	jns    f0102666 <env_create+0x47>
            panic("env_alloc: %e",r);
f0102646:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010264a:	c7 44 24 08 5d 58 10 	movl   $0xf010585d,0x8(%esp)
f0102651:	f0 
f0102652:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f0102659:	00 
f010265a:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f0102661:	e8 1a da ff ff       	call   f0100080 <_panic>
        load_icode(env, binary, size);
f0102666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
 
        struct Elf *elf = (struct Elf *)binary;
f0102669:	8b 45 08             	mov    0x8(%ebp),%eax
f010266c:	89 45 c4             	mov    %eax,-0x3c(%ebp)

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f010266f:	0f 20 da             	mov    %cr3,%edx
f0102672:	89 55 c0             	mov    %edx,-0x40(%ebp)
        uintptr_t i;
        struct Page *p;
        int r;
        pte_t* pte;
        uint32_t old_cr3 = rcr3();
        if(elf->e_magic != ELF_MAGIC)
f0102675:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010267b:	74 1c                	je     f0102699 <env_create+0x7a>
        panic("elf->e_magic erro\n");
f010267d:	c7 44 24 08 6b 58 10 	movl   $0xf010586b,0x8(%esp)
f0102684:	f0 
f0102685:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f010268c:	00 
f010268d:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f0102694:	e8 e7 d9 ff ff       	call   f0100080 <_panic>
        //program header
        ph = (struct Proghdr *)(binary + elf->e_phoff);
f0102699:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010269c:	8b 48 1c             	mov    0x1c(%eax),%ecx
        // one after last program header
        eph = ph + elf->e_phnum;
f010269f:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
        // load the cr3 to be able to use memmove
        lcr3(PADDR(e->env_pgdir));
f01026a3:	8b 47 5c             	mov    0x5c(%edi),%eax
f01026a6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026ab:	77 20                	ja     f01026cd <env_create+0xae>
f01026ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026b1:	c7 44 24 08 68 52 10 	movl   $0xf0105268,0x8(%esp)
f01026b8:	f0 
f01026b9:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
f01026c0:	00 
f01026c1:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f01026c8:	e8 b3 d9 ff ff       	call   f0100080 <_panic>
        pte_t* pte;
        uint32_t old_cr3 = rcr3();
        if(elf->e_magic != ELF_MAGIC)
        panic("elf->e_magic erro\n");
        //program header
        ph = (struct Proghdr *)(binary + elf->e_phoff);
f01026cd:	03 4d 08             	add    0x8(%ebp),%ecx
f01026d0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
        // one after last program header
        eph = ph + elf->e_phnum;
f01026d3:	0f b7 d2             	movzwl %dx,%edx
f01026d6:	c1 e2 05             	shl    $0x5,%edx
f01026d9:	01 ca                	add    %ecx,%edx
f01026db:	89 55 c8             	mov    %edx,-0x38(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01026de:	05 00 00 00 10       	add    $0x10000000,%eax
f01026e3:	0f 22 d8             	mov    %eax,%cr3
        // load the cr3 to be able to use memmove
        lcr3(PADDR(e->env_pgdir));
        // For each program header, load it into memory, zeroing as necessary
        for(; ph < eph; ph++)
f01026e6:	39 d1                	cmp    %edx,%ecx
f01026e8:	0f 83 19 01 00 00    	jae    f0102807 <env_create+0x1e8>
        struct Page *pp = NULL;
        int i;
        for(i=0; i < num_pages; i++) 
        {
            //alloc page
            if(page_alloc(&pp) < 0)
f01026ee:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01026f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
        // load the cr3 to be able to use memmove
        lcr3(PADDR(e->env_pgdir));
        // For each program header, load it into memory, zeroing as necessary
        for(; ph < eph; ph++)
        {
               if(ph->p_type == ELF_PROG_LOAD)
f01026f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01026f7:	83 3a 01             	cmpl   $0x1,(%edx)
f01026fa:	0f 85 f7 00 00 00    	jne    f01027f7 <env_create+0x1d8>
               {
                    // Allocate the memory requested
                    segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102700:	8b 42 08             	mov    0x8(%edx),%eax
segment_alloc(struct Env *e, void *va, size_t len) 
{
	// LAB 3: Your code here.
      
        //round va down to nearest page address
        void *va_start = va - PGOFF(va);
f0102703:	89 c3                	mov    %eax,%ebx
f0102705:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void *va_end = ROUNDUP(va + len, PGSIZE);
f010270b:	03 42 14             	add    0x14(%edx),%eax
f010270e:	05 ff 0f 00 00       	add    $0xfff,%eax
        //round len up to nearest page
        //len = ROUNDUP(len, PGSIZE);

        //alloc and insert number of pages needed
        //get num pages needed
        assert( 0 == (va_end - va_start) % PGSIZE);
f0102713:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102718:	29 d8                	sub    %ebx,%eax
        int num_pages = (va_end - va_start) / PGSIZE;
f010271a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0102720:	85 c0                	test   %eax,%eax
f0102722:	0f 48 c2             	cmovs  %edx,%eax
f0102725:	c1 f8 0c             	sar    $0xc,%eax
f0102728:	89 45 d0             	mov    %eax,-0x30(%ebp)
        //alloc and insert each page
        struct Page *pp = NULL;
f010272b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
        int i;
        for(i=0; i < num_pages; i++) 
f0102732:	85 c0                	test   %eax,%eax
f0102734:	7e 7c                	jle    f01027b2 <env_create+0x193>
f0102736:	be 00 00 00 00       	mov    $0x0,%esi
        {
            //alloc page
            if(page_alloc(&pp) < 0)
f010273b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010273e:	89 0c 24             	mov    %ecx,(%esp)
f0102741:	e8 15 e6 ff ff       	call   f0100d5b <page_alloc>
f0102746:	85 c0                	test   %eax,%eax
f0102748:	79 1c                	jns    f0102766 <env_create+0x147>
                 panic("segment_alloc: failed page alloc");
f010274a:	c7 44 24 08 a4 58 10 	movl   $0xf01058a4,0x8(%esp)
f0102751:	f0 
f0102752:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0102759:	00 
f010275a:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f0102761:	e8 1a d9 ff ff       	call   f0100080 <_panic>
            //insert page into env's pgdir at each pages's va addr
            void *va_addr = va_start + i*PGSIZE;
            if(page_insert(e->env_pgdir, pp, va_addr, PTE_U | PTE_W) < 0)
f0102766:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010276d:	00 
f010276e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102772:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102775:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102779:	8b 47 5c             	mov    0x5c(%edi),%eax
f010277c:	89 04 24             	mov    %eax,(%esp)
f010277f:	e8 8d e9 ff ff       	call   f0101111 <page_insert>
f0102784:	85 c0                	test   %eax,%eax
f0102786:	79 1c                	jns    f01027a4 <env_create+0x185>
            panic("segment_alloc: failed page insert");
f0102788:	c7 44 24 08 c8 58 10 	movl   $0xf01058c8,0x8(%esp)
f010278f:	f0 
f0102790:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
f0102797:	00 
f0102798:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f010279f:	e8 dc d8 ff ff       	call   f0100080 <_panic>
        assert( 0 == (va_end - va_start) % PGSIZE);
        int num_pages = (va_end - va_start) / PGSIZE;
        //alloc and insert each page
        struct Page *pp = NULL;
        int i;
        for(i=0; i < num_pages; i++) 
f01027a4:	83 c6 01             	add    $0x1,%esi
f01027a7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027ad:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f01027b0:	7f 89                	jg     f010273b <env_create+0x11c>
               if(ph->p_type == ELF_PROG_LOAD)
               {
                    // Allocate the memory requested
                    segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
                    // Copy data
                    memmove((void *)ph->p_va, (void *)binary + ph->p_offset, ph->p_filesz);
f01027b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01027b5:	8b 42 10             	mov    0x10(%edx),%eax
f01027b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01027bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01027bf:	03 42 04             	add    0x4(%edx),%eax
f01027c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027c6:	8b 42 08             	mov    0x8(%edx),%eax
f01027c9:	89 04 24             	mov    %eax,(%esp)
f01027cc:	e8 52 21 00 00       	call   f0104923 <memmove>
                    if(ph->p_memsz > ph->p_filesz)
f01027d1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01027d4:	8b 51 14             	mov    0x14(%ecx),%edx
f01027d7:	8b 41 10             	mov    0x10(%ecx),%eax
f01027da:	39 c2                	cmp    %eax,%edx
f01027dc:	76 19                	jbe    f01027f7 <env_create+0x1d8>
                    memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz -ph->p_filesz);
f01027de:	29 c2                	sub    %eax,%edx
f01027e0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01027e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01027eb:	00 
f01027ec:	03 41 08             	add    0x8(%ecx),%eax
f01027ef:	89 04 24             	mov    %eax,(%esp)
f01027f2:	e8 df 20 00 00       	call   f01048d6 <memset>
        // one after last program header
        eph = ph + elf->e_phnum;
        // load the cr3 to be able to use memmove
        lcr3(PADDR(e->env_pgdir));
        // For each program header, load it into memory, zeroing as necessary
        for(; ph < eph; ph++)
f01027f7:	83 45 d4 20          	addl   $0x20,-0x2c(%ebp)
f01027fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027fe:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0102801:	0f 87 ed fe ff ff    	ja     f01026f4 <env_create+0xd5>
               }
        }
 
        // Set up the environment's trapframe to point to the right location
        // Other values for the trap frame as assigned in env_alloc
        e->env_tf.tf_eip = elf->e_entry;
f0102807:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010280a:	8b 42 18             	mov    0x18(%edx),%eax
f010280d:	89 47 30             	mov    %eax,0x30(%edi)
 
        // Now map one page for the program's initial stack
        // at virtual address USTACKTOP - PGSIZE.
        // LAB 3: Your code here.
        
        r = page_alloc(&p);
f0102810:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0102813:	89 04 24             	mov    %eax,(%esp)
f0102816:	e8 40 e5 ff ff       	call   f0100d5b <page_alloc>
        if(r < 0)
f010281b:	85 c0                	test   %eax,%eax
f010281d:	79 1c                	jns    f010283b <env_create+0x21c>
            panic("Alloc page erro at load_icode\n");
f010281f:	c7 44 24 08 ec 58 10 	movl   $0xf01058ec,0x8(%esp)
f0102826:	f0 
f0102827:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
f010282e:	00 
f010282f:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f0102836:	e8 45 d8 ff ff       	call   f0100080 <_panic>
        page_insert(e->env_pgdir, p, (void *)USTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
f010283b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0102842:	00 
f0102843:	c7 44 24 08 00 d0 bf 	movl   $0xeebfd000,0x8(%esp)
f010284a:	ee 
f010284b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010284e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102852:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102855:	89 04 24             	mov    %eax,(%esp)
f0102858:	e8 b4 e8 ff ff       	call   f0101111 <page_insert>
f010285d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0102860:	0f 22 d9             	mov    %ecx,%cr3
        // envs[0], all we have to do is allocate an environment
        r = env_alloc(&env, 0);
        if(r < 0)
            panic("env_alloc: %e",r);
        load_icode(env, binary, size);
}
f0102863:	83 c4 4c             	add    $0x4c,%esp
f0102866:	5b                   	pop    %ebx
f0102867:	5e                   	pop    %esi
f0102868:	5f                   	pop    %edi
f0102869:	5d                   	pop    %ebp
f010286a:	c3                   	ret    
	...

f010286c <mc146818_read>:
#include <kern/picirq.h>


unsigned
mc146818_read(unsigned reg)
{
f010286c:	55                   	push   %ebp
f010286d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010286f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102874:	8b 45 08             	mov    0x8(%ebp),%eax
f0102877:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102878:	b2 71                	mov    $0x71,%dl
f010287a:	ec                   	in     (%dx),%al
f010287b:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f010287e:	5d                   	pop    %ebp
f010287f:	c3                   	ret    

f0102880 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102880:	55                   	push   %ebp
f0102881:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102883:	ba 70 00 00 00       	mov    $0x70,%edx
f0102888:	8b 45 08             	mov    0x8(%ebp),%eax
f010288b:	ee                   	out    %al,(%dx)
f010288c:	b2 71                	mov    $0x71,%dl
f010288e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102891:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102892:	5d                   	pop    %ebp
f0102893:	c3                   	ret    

f0102894 <kclock_init>:


void
kclock_init(void)
{
f0102894:	55                   	push   %ebp
f0102895:	89 e5                	mov    %esp,%ebp
f0102897:	83 ec 18             	sub    $0x18,%esp
f010289a:	ba 43 00 00 00       	mov    $0x43,%edx
f010289f:	b8 34 00 00 00       	mov    $0x34,%eax
f01028a4:	ee                   	out    %al,(%dx)
f01028a5:	b2 40                	mov    $0x40,%dl
f01028a7:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
f01028ac:	ee                   	out    %al,(%dx)
f01028ad:	b8 2e 00 00 00       	mov    $0x2e,%eax
f01028b2:	ee                   	out    %al,(%dx)
	/* initialize 8253 clock to interrupt 100 times/sec */
	outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
	outb(IO_TIMER1, TIMER_DIV(100) % 256);
	outb(IO_TIMER1, TIMER_DIV(100) / 256);
	cprintf("	Setup timer interrupts via 8259A\n");
f01028b3:	c7 04 24 0c 59 10 f0 	movl   $0xf010590c,(%esp)
f01028ba:	e8 58 01 00 00       	call   f0102a17 <cprintf>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<0));
f01028bf:	0f b7 05 58 93 11 f0 	movzwl 0xf0119358,%eax
f01028c6:	25 fe ff 00 00       	and    $0xfffe,%eax
f01028cb:	89 04 24             	mov    %eax,(%esp)
f01028ce:	e8 11 00 00 00       	call   f01028e4 <irq_setmask_8259A>
	cprintf("	unmasked timer interrupt\n");
f01028d3:	c7 04 24 2f 59 10 f0 	movl   $0xf010592f,(%esp)
f01028da:	e8 38 01 00 00       	call   f0102a17 <cprintf>
}
f01028df:	c9                   	leave  
f01028e0:	c3                   	ret    
f01028e1:	00 00                	add    %al,(%eax)
	...

f01028e4 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01028e4:	55                   	push   %ebp
f01028e5:	89 e5                	mov    %esp,%ebp
f01028e7:	56                   	push   %esi
f01028e8:	53                   	push   %ebx
f01028e9:	83 ec 10             	sub    $0x10,%esp
f01028ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01028ef:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01028f1:	66 a3 58 93 11 f0    	mov    %ax,0xf0119358
	if (!didinit)
f01028f7:	83 3d 2c af 1a f0 00 	cmpl   $0x0,0xf01aaf2c
f01028fe:	74 4e                	je     f010294e <irq_setmask_8259A+0x6a>
f0102900:	ba 21 00 00 00       	mov    $0x21,%edx
f0102905:	ee                   	out    %al,(%dx)
f0102906:	89 f0                	mov    %esi,%eax
f0102908:	66 c1 e8 08          	shr    $0x8,%ax
f010290c:	b2 a1                	mov    $0xa1,%dl
f010290e:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010290f:	c7 04 24 4a 59 10 f0 	movl   $0xf010594a,(%esp)
f0102916:	e8 fc 00 00 00       	call   f0102a17 <cprintf>
f010291b:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0102920:	0f b7 f6             	movzwl %si,%esi
f0102923:	f7 d6                	not    %esi
f0102925:	0f a3 de             	bt     %ebx,%esi
f0102928:	73 10                	jae    f010293a <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f010292a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010292e:	c7 04 24 94 5d 10 f0 	movl   $0xf0105d94,(%esp)
f0102935:	e8 dd 00 00 00       	call   f0102a17 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010293a:	83 c3 01             	add    $0x1,%ebx
f010293d:	83 fb 10             	cmp    $0x10,%ebx
f0102940:	75 e3                	jne    f0102925 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0102942:	c7 04 24 e6 57 10 f0 	movl   $0xf01057e6,(%esp)
f0102949:	e8 c9 00 00 00       	call   f0102a17 <cprintf>
}
f010294e:	83 c4 10             	add    $0x10,%esp
f0102951:	5b                   	pop    %ebx
f0102952:	5e                   	pop    %esi
f0102953:	5d                   	pop    %ebp
f0102954:	c3                   	ret    

f0102955 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0102955:	55                   	push   %ebp
f0102956:	89 e5                	mov    %esp,%ebp
f0102958:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010295b:	c7 05 2c af 1a f0 01 	movl   $0x1,0xf01aaf2c
f0102962:	00 00 00 
f0102965:	ba 21 00 00 00       	mov    $0x21,%edx
f010296a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010296f:	ee                   	out    %al,(%dx)
f0102970:	b2 a1                	mov    $0xa1,%dl
f0102972:	ee                   	out    %al,(%dx)
f0102973:	b2 20                	mov    $0x20,%dl
f0102975:	b8 11 00 00 00       	mov    $0x11,%eax
f010297a:	ee                   	out    %al,(%dx)
f010297b:	b2 21                	mov    $0x21,%dl
f010297d:	b8 20 00 00 00       	mov    $0x20,%eax
f0102982:	ee                   	out    %al,(%dx)
f0102983:	b8 04 00 00 00       	mov    $0x4,%eax
f0102988:	ee                   	out    %al,(%dx)
f0102989:	b8 03 00 00 00       	mov    $0x3,%eax
f010298e:	ee                   	out    %al,(%dx)
f010298f:	b2 a0                	mov    $0xa0,%dl
f0102991:	b8 11 00 00 00       	mov    $0x11,%eax
f0102996:	ee                   	out    %al,(%dx)
f0102997:	b2 a1                	mov    $0xa1,%dl
f0102999:	b8 28 00 00 00       	mov    $0x28,%eax
f010299e:	ee                   	out    %al,(%dx)
f010299f:	b8 02 00 00 00       	mov    $0x2,%eax
f01029a4:	ee                   	out    %al,(%dx)
f01029a5:	b8 01 00 00 00       	mov    $0x1,%eax
f01029aa:	ee                   	out    %al,(%dx)
f01029ab:	b2 20                	mov    $0x20,%dl
f01029ad:	b8 68 00 00 00       	mov    $0x68,%eax
f01029b2:	ee                   	out    %al,(%dx)
f01029b3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01029b8:	ee                   	out    %al,(%dx)
f01029b9:	b2 a0                	mov    $0xa0,%dl
f01029bb:	b8 68 00 00 00       	mov    $0x68,%eax
f01029c0:	ee                   	out    %al,(%dx)
f01029c1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01029c6:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01029c7:	0f b7 05 58 93 11 f0 	movzwl 0xf0119358,%eax
f01029ce:	66 83 f8 ff          	cmp    $0xffff,%ax
f01029d2:	74 0b                	je     f01029df <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f01029d4:	0f b7 c0             	movzwl %ax,%eax
f01029d7:	89 04 24             	mov    %eax,(%esp)
f01029da:	e8 05 ff ff ff       	call   f01028e4 <irq_setmask_8259A>
}
f01029df:	c9                   	leave  
f01029e0:	c3                   	ret    
f01029e1:	00 00                	add    %al,(%eax)
	...

f01029e4 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01029e4:	55                   	push   %ebp
f01029e5:	89 e5                	mov    %esp,%ebp
f01029e7:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01029ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01029f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01029fb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01029ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102a02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a06:	c7 04 24 31 2a 10 f0 	movl   $0xf0102a31,(%esp)
f0102a0d:	e8 7e 17 00 00       	call   f0104190 <vprintfmt>
	return cnt;
}
f0102a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a15:	c9                   	leave  
f0102a16:	c3                   	ret    

f0102a17 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102a17:	55                   	push   %ebp
f0102a18:	89 e5                	mov    %esp,%ebp
f0102a1a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0102a1d:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102a20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a24:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a27:	89 04 24             	mov    %eax,(%esp)
f0102a2a:	e8 b5 ff ff ff       	call   f01029e4 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102a2f:	c9                   	leave  
f0102a30:	c3                   	ret    

f0102a31 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102a31:	55                   	push   %ebp
f0102a32:	89 e5                	mov    %esp,%ebp
f0102a34:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102a37:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a3a:	89 04 24             	mov    %eax,(%esp)
f0102a3d:	e8 7e dc ff ff       	call   f01006c0 <cputchar>
	*cnt++;
}
f0102a42:	c9                   	leave  
f0102a43:	c3                   	ret    
	...

f0102a50 <idt_init>:
}


void
idt_init(void)
{
f0102a50:	55                   	push   %ebp
f0102a51:	89 e5                	mov    %esp,%ebp
	extern void inter_irq_12();
	extern void inter_irq_13();
	extern void inter_irq_14();
	extern void inter_irq_15();

	SETGATE(idt[T_DIVIDE], 1, GD_KT, trap_divide, 0);
f0102a53:	b8 6c 34 10 f0       	mov    $0xf010346c,%eax
f0102a58:	66 a3 40 af 1a f0    	mov    %ax,0xf01aaf40
f0102a5e:	66 c7 05 42 af 1a f0 	movw   $0x8,0xf01aaf42
f0102a65:	08 00 
f0102a67:	c6 05 44 af 1a f0 00 	movb   $0x0,0xf01aaf44
f0102a6e:	c6 05 45 af 1a f0 8f 	movb   $0x8f,0xf01aaf45
f0102a75:	c1 e8 10             	shr    $0x10,%eax
f0102a78:	66 a3 46 af 1a f0    	mov    %ax,0xf01aaf46
	SETGATE(idt[T_DEBUG], 0, GD_KT, trap_debug, 0);
f0102a7e:	b8 76 34 10 f0       	mov    $0xf0103476,%eax
f0102a83:	66 a3 48 af 1a f0    	mov    %ax,0xf01aaf48
f0102a89:	66 c7 05 4a af 1a f0 	movw   $0x8,0xf01aaf4a
f0102a90:	08 00 
f0102a92:	c6 05 4c af 1a f0 00 	movb   $0x0,0xf01aaf4c
f0102a99:	c6 05 4d af 1a f0 8e 	movb   $0x8e,0xf01aaf4d
f0102aa0:	c1 e8 10             	shr    $0x10,%eax
f0102aa3:	66 a3 4e af 1a f0    	mov    %ax,0xf01aaf4e
	SETGATE(idt[T_NMI], 0, GD_KT, trap_nmi, 0);
f0102aa9:	b8 80 34 10 f0       	mov    $0xf0103480,%eax
f0102aae:	66 a3 50 af 1a f0    	mov    %ax,0xf01aaf50
f0102ab4:	66 c7 05 52 af 1a f0 	movw   $0x8,0xf01aaf52
f0102abb:	08 00 
f0102abd:	c6 05 54 af 1a f0 00 	movb   $0x0,0xf01aaf54
f0102ac4:	c6 05 55 af 1a f0 8e 	movb   $0x8e,0xf01aaf55
f0102acb:	c1 e8 10             	shr    $0x10,%eax
f0102ace:	66 a3 56 af 1a f0    	mov    %ax,0xf01aaf56
	SETGATE(idt[T_BRKPT], 0, GD_KT, trap_brkpt, 3);
f0102ad4:	b8 8a 34 10 f0       	mov    $0xf010348a,%eax
f0102ad9:	66 a3 58 af 1a f0    	mov    %ax,0xf01aaf58
f0102adf:	66 c7 05 5a af 1a f0 	movw   $0x8,0xf01aaf5a
f0102ae6:	08 00 
f0102ae8:	c6 05 5c af 1a f0 00 	movb   $0x0,0xf01aaf5c
f0102aef:	c6 05 5d af 1a f0 ee 	movb   $0xee,0xf01aaf5d
f0102af6:	c1 e8 10             	shr    $0x10,%eax
f0102af9:	66 a3 5e af 1a f0    	mov    %ax,0xf01aaf5e
	SETGATE(idt[T_OFLOW], 0, GD_KT, trap_oflow, 0);
f0102aff:	b8 94 34 10 f0       	mov    $0xf0103494,%eax
f0102b04:	66 a3 60 af 1a f0    	mov    %ax,0xf01aaf60
f0102b0a:	66 c7 05 62 af 1a f0 	movw   $0x8,0xf01aaf62
f0102b11:	08 00 
f0102b13:	c6 05 64 af 1a f0 00 	movb   $0x0,0xf01aaf64
f0102b1a:	c6 05 65 af 1a f0 8e 	movb   $0x8e,0xf01aaf65
f0102b21:	c1 e8 10             	shr    $0x10,%eax
f0102b24:	66 a3 66 af 1a f0    	mov    %ax,0xf01aaf66
	SETGATE(idt[T_BOUND], 0, GD_KT, trap_bound, 0);
f0102b2a:	b8 9e 34 10 f0       	mov    $0xf010349e,%eax
f0102b2f:	66 a3 68 af 1a f0    	mov    %ax,0xf01aaf68
f0102b35:	66 c7 05 6a af 1a f0 	movw   $0x8,0xf01aaf6a
f0102b3c:	08 00 
f0102b3e:	c6 05 6c af 1a f0 00 	movb   $0x0,0xf01aaf6c
f0102b45:	c6 05 6d af 1a f0 8e 	movb   $0x8e,0xf01aaf6d
f0102b4c:	c1 e8 10             	shr    $0x10,%eax
f0102b4f:	66 a3 6e af 1a f0    	mov    %ax,0xf01aaf6e
	SETGATE(idt[T_ILLOP], 0, GD_KT, trap_illop, 0);
f0102b55:	b8 a8 34 10 f0       	mov    $0xf01034a8,%eax
f0102b5a:	66 a3 70 af 1a f0    	mov    %ax,0xf01aaf70
f0102b60:	66 c7 05 72 af 1a f0 	movw   $0x8,0xf01aaf72
f0102b67:	08 00 
f0102b69:	c6 05 74 af 1a f0 00 	movb   $0x0,0xf01aaf74
f0102b70:	c6 05 75 af 1a f0 8e 	movb   $0x8e,0xf01aaf75
f0102b77:	c1 e8 10             	shr    $0x10,%eax
f0102b7a:	66 a3 76 af 1a f0    	mov    %ax,0xf01aaf76
	SETGATE(idt[T_DEVICE], 0, GD_KT, trap_device, 0);
f0102b80:	b8 b2 34 10 f0       	mov    $0xf01034b2,%eax
f0102b85:	66 a3 78 af 1a f0    	mov    %ax,0xf01aaf78
f0102b8b:	66 c7 05 7a af 1a f0 	movw   $0x8,0xf01aaf7a
f0102b92:	08 00 
f0102b94:	c6 05 7c af 1a f0 00 	movb   $0x0,0xf01aaf7c
f0102b9b:	c6 05 7d af 1a f0 8e 	movb   $0x8e,0xf01aaf7d
f0102ba2:	c1 e8 10             	shr    $0x10,%eax
f0102ba5:	66 a3 7e af 1a f0    	mov    %ax,0xf01aaf7e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, trap_dblflt, 0);
f0102bab:	b8 bc 34 10 f0       	mov    $0xf01034bc,%eax
f0102bb0:	66 a3 80 af 1a f0    	mov    %ax,0xf01aaf80
f0102bb6:	66 c7 05 82 af 1a f0 	movw   $0x8,0xf01aaf82
f0102bbd:	08 00 
f0102bbf:	c6 05 84 af 1a f0 00 	movb   $0x0,0xf01aaf84
f0102bc6:	c6 05 85 af 1a f0 8e 	movb   $0x8e,0xf01aaf85
f0102bcd:	c1 e8 10             	shr    $0x10,%eax
f0102bd0:	66 a3 86 af 1a f0    	mov    %ax,0xf01aaf86
	SETGATE(idt[T_TSS], 0, GD_KT, trap_tss, 0);
f0102bd6:	b8 c4 34 10 f0       	mov    $0xf01034c4,%eax
f0102bdb:	66 a3 90 af 1a f0    	mov    %ax,0xf01aaf90
f0102be1:	66 c7 05 92 af 1a f0 	movw   $0x8,0xf01aaf92
f0102be8:	08 00 
f0102bea:	c6 05 94 af 1a f0 00 	movb   $0x0,0xf01aaf94
f0102bf1:	c6 05 95 af 1a f0 8e 	movb   $0x8e,0xf01aaf95
f0102bf8:	c1 e8 10             	shr    $0x10,%eax
f0102bfb:	66 a3 96 af 1a f0    	mov    %ax,0xf01aaf96
	SETGATE(idt[T_SEGNP], 0, GD_KT, trap_segnp, 0);
f0102c01:	b8 cc 34 10 f0       	mov    $0xf01034cc,%eax
f0102c06:	66 a3 98 af 1a f0    	mov    %ax,0xf01aaf98
f0102c0c:	66 c7 05 9a af 1a f0 	movw   $0x8,0xf01aaf9a
f0102c13:	08 00 
f0102c15:	c6 05 9c af 1a f0 00 	movb   $0x0,0xf01aaf9c
f0102c1c:	c6 05 9d af 1a f0 8e 	movb   $0x8e,0xf01aaf9d
f0102c23:	c1 e8 10             	shr    $0x10,%eax
f0102c26:	66 a3 9e af 1a f0    	mov    %ax,0xf01aaf9e
	SETGATE(idt[T_STACK], 0, GD_KT, trap_stack, 0);
f0102c2c:	b8 d4 34 10 f0       	mov    $0xf01034d4,%eax
f0102c31:	66 a3 a0 af 1a f0    	mov    %ax,0xf01aafa0
f0102c37:	66 c7 05 a2 af 1a f0 	movw   $0x8,0xf01aafa2
f0102c3e:	08 00 
f0102c40:	c6 05 a4 af 1a f0 00 	movb   $0x0,0xf01aafa4
f0102c47:	c6 05 a5 af 1a f0 8e 	movb   $0x8e,0xf01aafa5
f0102c4e:	c1 e8 10             	shr    $0x10,%eax
f0102c51:	66 a3 a6 af 1a f0    	mov    %ax,0xf01aafa6
	SETGATE(idt[T_GPFLT], 0, GD_KT, trap_gpflt, 0);
f0102c57:	b8 dc 34 10 f0       	mov    $0xf01034dc,%eax
f0102c5c:	66 a3 a8 af 1a f0    	mov    %ax,0xf01aafa8
f0102c62:	66 c7 05 aa af 1a f0 	movw   $0x8,0xf01aafaa
f0102c69:	08 00 
f0102c6b:	c6 05 ac af 1a f0 00 	movb   $0x0,0xf01aafac
f0102c72:	c6 05 ad af 1a f0 8e 	movb   $0x8e,0xf01aafad
f0102c79:	c1 e8 10             	shr    $0x10,%eax
f0102c7c:	66 a3 ae af 1a f0    	mov    %ax,0xf01aafae
	SETGATE(idt[T_PGFLT], 0, GD_KT, trap_pgflt, 0);
f0102c82:	b8 e4 34 10 f0       	mov    $0xf01034e4,%eax
f0102c87:	66 a3 b0 af 1a f0    	mov    %ax,0xf01aafb0
f0102c8d:	66 c7 05 b2 af 1a f0 	movw   $0x8,0xf01aafb2
f0102c94:	08 00 
f0102c96:	c6 05 b4 af 1a f0 00 	movb   $0x0,0xf01aafb4
f0102c9d:	c6 05 b5 af 1a f0 8e 	movb   $0x8e,0xf01aafb5
f0102ca4:	c1 e8 10             	shr    $0x10,%eax
f0102ca7:	66 a3 b6 af 1a f0    	mov    %ax,0xf01aafb6
	SETGATE(idt[T_FPERR], 0, GD_KT, trap_fperr, 0);
f0102cad:	b8 ec 34 10 f0       	mov    $0xf01034ec,%eax
f0102cb2:	66 a3 c0 af 1a f0    	mov    %ax,0xf01aafc0
f0102cb8:	66 c7 05 c2 af 1a f0 	movw   $0x8,0xf01aafc2
f0102cbf:	08 00 
f0102cc1:	c6 05 c4 af 1a f0 00 	movb   $0x0,0xf01aafc4
f0102cc8:	c6 05 c5 af 1a f0 8e 	movb   $0x8e,0xf01aafc5
f0102ccf:	c1 e8 10             	shr    $0x10,%eax
f0102cd2:	66 a3 c6 af 1a f0    	mov    %ax,0xf01aafc6
	SETGATE(idt[T_ALIGN], 0, GD_KT, trap_align, 0);
f0102cd8:	b8 f6 34 10 f0       	mov    $0xf01034f6,%eax
f0102cdd:	66 a3 c8 af 1a f0    	mov    %ax,0xf01aafc8
f0102ce3:	66 c7 05 ca af 1a f0 	movw   $0x8,0xf01aafca
f0102cea:	08 00 
f0102cec:	c6 05 cc af 1a f0 00 	movb   $0x0,0xf01aafcc
f0102cf3:	c6 05 cd af 1a f0 8e 	movb   $0x8e,0xf01aafcd
f0102cfa:	c1 e8 10             	shr    $0x10,%eax
f0102cfd:	66 a3 ce af 1a f0    	mov    %ax,0xf01aafce
	SETGATE(idt[T_MCHK], 0, GD_KT, trap_mchk, 0);
f0102d03:	b8 fe 34 10 f0       	mov    $0xf01034fe,%eax
f0102d08:	66 a3 d0 af 1a f0    	mov    %ax,0xf01aafd0
f0102d0e:	66 c7 05 d2 af 1a f0 	movw   $0x8,0xf01aafd2
f0102d15:	08 00 
f0102d17:	c6 05 d4 af 1a f0 00 	movb   $0x0,0xf01aafd4
f0102d1e:	c6 05 d5 af 1a f0 8e 	movb   $0x8e,0xf01aafd5
f0102d25:	c1 e8 10             	shr    $0x10,%eax
f0102d28:	66 a3 d6 af 1a f0    	mov    %ax,0xf01aafd6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, trap_simderr, 0);
f0102d2e:	b8 04 35 10 f0       	mov    $0xf0103504,%eax
f0102d33:	66 a3 d8 af 1a f0    	mov    %ax,0xf01aafd8
f0102d39:	66 c7 05 da af 1a f0 	movw   $0x8,0xf01aafda
f0102d40:	08 00 
f0102d42:	c6 05 dc af 1a f0 00 	movb   $0x0,0xf01aafdc
f0102d49:	c6 05 dd af 1a f0 8e 	movb   $0x8e,0xf01aafdd
f0102d50:	c1 e8 10             	shr    $0x10,%eax
f0102d53:	66 a3 de af 1a f0    	mov    %ax,0xf01aafde

	SETGATE(idt[T_SYSCALL], 0, GD_KT, trap_syscall, 3);
f0102d59:	b8 0a 35 10 f0       	mov    $0xf010350a,%eax
f0102d5e:	66 a3 c0 b0 1a f0    	mov    %ax,0xf01ab0c0
f0102d64:	66 c7 05 c2 b0 1a f0 	movw   $0x8,0xf01ab0c2
f0102d6b:	08 00 
f0102d6d:	c6 05 c4 b0 1a f0 00 	movb   $0x0,0xf01ab0c4
f0102d74:	c6 05 c5 b0 1a f0 ee 	movb   $0xee,0xf01ab0c5
f0102d7b:	c1 e8 10             	shr    $0x10,%eax
f0102d7e:	66 a3 c6 b0 1a f0    	mov    %ax,0xf01ab0c6

	SETGATE (idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, _timer, 0);
	
	SETGATE(idt[IRQ_OFFSET+0],0,GD_KT,inter_irq_0,0);
f0102d84:	b8 20 35 10 f0       	mov    $0xf0103520,%eax
f0102d89:	66 a3 40 b0 1a f0    	mov    %ax,0xf01ab040
f0102d8f:	66 c7 05 42 b0 1a f0 	movw   $0x8,0xf01ab042
f0102d96:	08 00 
f0102d98:	c6 05 44 b0 1a f0 00 	movb   $0x0,0xf01ab044
f0102d9f:	c6 05 45 b0 1a f0 8e 	movb   $0x8e,0xf01ab045
f0102da6:	c1 e8 10             	shr    $0x10,%eax
f0102da9:	66 a3 46 b0 1a f0    	mov    %ax,0xf01ab046
	SETGATE(idt[IRQ_OFFSET+1],0,GD_KT,inter_irq_1,0);
f0102daf:	b8 26 35 10 f0       	mov    $0xf0103526,%eax
f0102db4:	66 a3 48 b0 1a f0    	mov    %ax,0xf01ab048
f0102dba:	66 c7 05 4a b0 1a f0 	movw   $0x8,0xf01ab04a
f0102dc1:	08 00 
f0102dc3:	c6 05 4c b0 1a f0 00 	movb   $0x0,0xf01ab04c
f0102dca:	c6 05 4d b0 1a f0 8e 	movb   $0x8e,0xf01ab04d
f0102dd1:	c1 e8 10             	shr    $0x10,%eax
f0102dd4:	66 a3 4e b0 1a f0    	mov    %ax,0xf01ab04e
	SETGATE(idt[IRQ_OFFSET+2],0,GD_KT,inter_irq_2,0);
f0102dda:	b8 2c 35 10 f0       	mov    $0xf010352c,%eax
f0102ddf:	66 a3 50 b0 1a f0    	mov    %ax,0xf01ab050
f0102de5:	66 c7 05 52 b0 1a f0 	movw   $0x8,0xf01ab052
f0102dec:	08 00 
f0102dee:	c6 05 54 b0 1a f0 00 	movb   $0x0,0xf01ab054
f0102df5:	c6 05 55 b0 1a f0 8e 	movb   $0x8e,0xf01ab055
f0102dfc:	c1 e8 10             	shr    $0x10,%eax
f0102dff:	66 a3 56 b0 1a f0    	mov    %ax,0xf01ab056
	SETGATE(idt[IRQ_OFFSET+3],0,GD_KT,inter_irq_3,0);
f0102e05:	b8 32 35 10 f0       	mov    $0xf0103532,%eax
f0102e0a:	66 a3 58 b0 1a f0    	mov    %ax,0xf01ab058
f0102e10:	66 c7 05 5a b0 1a f0 	movw   $0x8,0xf01ab05a
f0102e17:	08 00 
f0102e19:	c6 05 5c b0 1a f0 00 	movb   $0x0,0xf01ab05c
f0102e20:	c6 05 5d b0 1a f0 8e 	movb   $0x8e,0xf01ab05d
f0102e27:	c1 e8 10             	shr    $0x10,%eax
f0102e2a:	66 a3 5e b0 1a f0    	mov    %ax,0xf01ab05e
	SETGATE(idt[IRQ_OFFSET+4],0,GD_KT,inter_irq_4,0);
f0102e30:	b8 38 35 10 f0       	mov    $0xf0103538,%eax
f0102e35:	66 a3 60 b0 1a f0    	mov    %ax,0xf01ab060
f0102e3b:	66 c7 05 62 b0 1a f0 	movw   $0x8,0xf01ab062
f0102e42:	08 00 
f0102e44:	c6 05 64 b0 1a f0 00 	movb   $0x0,0xf01ab064
f0102e4b:	c6 05 65 b0 1a f0 8e 	movb   $0x8e,0xf01ab065
f0102e52:	c1 e8 10             	shr    $0x10,%eax
f0102e55:	66 a3 66 b0 1a f0    	mov    %ax,0xf01ab066
	SETGATE(idt[IRQ_OFFSET+5],0,GD_KT,inter_irq_5,0);
f0102e5b:	b8 3e 35 10 f0       	mov    $0xf010353e,%eax
f0102e60:	66 a3 68 b0 1a f0    	mov    %ax,0xf01ab068
f0102e66:	66 c7 05 6a b0 1a f0 	movw   $0x8,0xf01ab06a
f0102e6d:	08 00 
f0102e6f:	c6 05 6c b0 1a f0 00 	movb   $0x0,0xf01ab06c
f0102e76:	c6 05 6d b0 1a f0 8e 	movb   $0x8e,0xf01ab06d
f0102e7d:	c1 e8 10             	shr    $0x10,%eax
f0102e80:	66 a3 6e b0 1a f0    	mov    %ax,0xf01ab06e
	SETGATE(idt[IRQ_OFFSET+6],0,GD_KT,inter_irq_6,0);
f0102e86:	b8 44 35 10 f0       	mov    $0xf0103544,%eax
f0102e8b:	66 a3 70 b0 1a f0    	mov    %ax,0xf01ab070
f0102e91:	66 c7 05 72 b0 1a f0 	movw   $0x8,0xf01ab072
f0102e98:	08 00 
f0102e9a:	c6 05 74 b0 1a f0 00 	movb   $0x0,0xf01ab074
f0102ea1:	c6 05 75 b0 1a f0 8e 	movb   $0x8e,0xf01ab075
f0102ea8:	c1 e8 10             	shr    $0x10,%eax
f0102eab:	66 a3 76 b0 1a f0    	mov    %ax,0xf01ab076
	SETGATE(idt[IRQ_OFFSET+7],0,GD_KT,inter_irq_7,0);
f0102eb1:	b8 4a 35 10 f0       	mov    $0xf010354a,%eax
f0102eb6:	66 a3 78 b0 1a f0    	mov    %ax,0xf01ab078
f0102ebc:	66 c7 05 7a b0 1a f0 	movw   $0x8,0xf01ab07a
f0102ec3:	08 00 
f0102ec5:	c6 05 7c b0 1a f0 00 	movb   $0x0,0xf01ab07c
f0102ecc:	c6 05 7d b0 1a f0 8e 	movb   $0x8e,0xf01ab07d
f0102ed3:	c1 e8 10             	shr    $0x10,%eax
f0102ed6:	66 a3 7e b0 1a f0    	mov    %ax,0xf01ab07e
	SETGATE(idt[IRQ_OFFSET+8],0,GD_KT,inter_irq_8,0);
f0102edc:	b8 50 35 10 f0       	mov    $0xf0103550,%eax
f0102ee1:	66 a3 80 b0 1a f0    	mov    %ax,0xf01ab080
f0102ee7:	66 c7 05 82 b0 1a f0 	movw   $0x8,0xf01ab082
f0102eee:	08 00 
f0102ef0:	c6 05 84 b0 1a f0 00 	movb   $0x0,0xf01ab084
f0102ef7:	c6 05 85 b0 1a f0 8e 	movb   $0x8e,0xf01ab085
f0102efe:	c1 e8 10             	shr    $0x10,%eax
f0102f01:	66 a3 86 b0 1a f0    	mov    %ax,0xf01ab086
	SETGATE(idt[IRQ_OFFSET+9],0,GD_KT,inter_irq_9,0);
f0102f07:	b8 56 35 10 f0       	mov    $0xf0103556,%eax
f0102f0c:	66 a3 88 b0 1a f0    	mov    %ax,0xf01ab088
f0102f12:	66 c7 05 8a b0 1a f0 	movw   $0x8,0xf01ab08a
f0102f19:	08 00 
f0102f1b:	c6 05 8c b0 1a f0 00 	movb   $0x0,0xf01ab08c
f0102f22:	c6 05 8d b0 1a f0 8e 	movb   $0x8e,0xf01ab08d
f0102f29:	c1 e8 10             	shr    $0x10,%eax
f0102f2c:	66 a3 8e b0 1a f0    	mov    %ax,0xf01ab08e
	SETGATE(idt[IRQ_OFFSET+10],0,GD_KT,inter_irq_10,0);
f0102f32:	b8 5c 35 10 f0       	mov    $0xf010355c,%eax
f0102f37:	66 a3 90 b0 1a f0    	mov    %ax,0xf01ab090
f0102f3d:	66 c7 05 92 b0 1a f0 	movw   $0x8,0xf01ab092
f0102f44:	08 00 
f0102f46:	c6 05 94 b0 1a f0 00 	movb   $0x0,0xf01ab094
f0102f4d:	c6 05 95 b0 1a f0 8e 	movb   $0x8e,0xf01ab095
f0102f54:	c1 e8 10             	shr    $0x10,%eax
f0102f57:	66 a3 96 b0 1a f0    	mov    %ax,0xf01ab096
	SETGATE(idt[IRQ_OFFSET+11],0,GD_KT,inter_irq_11,0);
f0102f5d:	b8 62 35 10 f0       	mov    $0xf0103562,%eax
f0102f62:	66 a3 98 b0 1a f0    	mov    %ax,0xf01ab098
f0102f68:	66 c7 05 9a b0 1a f0 	movw   $0x8,0xf01ab09a
f0102f6f:	08 00 
f0102f71:	c6 05 9c b0 1a f0 00 	movb   $0x0,0xf01ab09c
f0102f78:	c6 05 9d b0 1a f0 8e 	movb   $0x8e,0xf01ab09d
f0102f7f:	c1 e8 10             	shr    $0x10,%eax
f0102f82:	66 a3 9e b0 1a f0    	mov    %ax,0xf01ab09e
	SETGATE(idt[IRQ_OFFSET+12],0,GD_KT,inter_irq_12,0);
f0102f88:	b8 68 35 10 f0       	mov    $0xf0103568,%eax
f0102f8d:	66 a3 a0 b0 1a f0    	mov    %ax,0xf01ab0a0
f0102f93:	66 c7 05 a2 b0 1a f0 	movw   $0x8,0xf01ab0a2
f0102f9a:	08 00 
f0102f9c:	c6 05 a4 b0 1a f0 00 	movb   $0x0,0xf01ab0a4
f0102fa3:	c6 05 a5 b0 1a f0 8e 	movb   $0x8e,0xf01ab0a5
f0102faa:	c1 e8 10             	shr    $0x10,%eax
f0102fad:	66 a3 a6 b0 1a f0    	mov    %ax,0xf01ab0a6
	SETGATE(idt[IRQ_OFFSET+13],0,GD_KT,inter_irq_13,0);
f0102fb3:	b8 6e 35 10 f0       	mov    $0xf010356e,%eax
f0102fb8:	66 a3 a8 b0 1a f0    	mov    %ax,0xf01ab0a8
f0102fbe:	66 c7 05 aa b0 1a f0 	movw   $0x8,0xf01ab0aa
f0102fc5:	08 00 
f0102fc7:	c6 05 ac b0 1a f0 00 	movb   $0x0,0xf01ab0ac
f0102fce:	c6 05 ad b0 1a f0 8e 	movb   $0x8e,0xf01ab0ad
f0102fd5:	c1 e8 10             	shr    $0x10,%eax
f0102fd8:	66 a3 ae b0 1a f0    	mov    %ax,0xf01ab0ae
	SETGATE(idt[IRQ_OFFSET+14],0,GD_KT,inter_irq_14,0);
f0102fde:	b8 74 35 10 f0       	mov    $0xf0103574,%eax
f0102fe3:	66 a3 b0 b0 1a f0    	mov    %ax,0xf01ab0b0
f0102fe9:	66 c7 05 b2 b0 1a f0 	movw   $0x8,0xf01ab0b2
f0102ff0:	08 00 
f0102ff2:	c6 05 b4 b0 1a f0 00 	movb   $0x0,0xf01ab0b4
f0102ff9:	c6 05 b5 b0 1a f0 8e 	movb   $0x8e,0xf01ab0b5
f0103000:	c1 e8 10             	shr    $0x10,%eax
f0103003:	66 a3 b6 b0 1a f0    	mov    %ax,0xf01ab0b6
	SETGATE(idt[IRQ_OFFSET+15],0,GD_KT,inter_irq_15,0);
f0103009:	b8 7a 35 10 f0       	mov    $0xf010357a,%eax
f010300e:	66 a3 b8 b0 1a f0    	mov    %ax,0xf01ab0b8
f0103014:	66 c7 05 ba b0 1a f0 	movw   $0x8,0xf01ab0ba
f010301b:	08 00 
f010301d:	c6 05 bc b0 1a f0 00 	movb   $0x0,0xf01ab0bc
f0103024:	c6 05 bd b0 1a f0 8e 	movb   $0x8e,0xf01ab0bd
f010302b:	c1 e8 10             	shr    $0x10,%eax
f010302e:	66 a3 be b0 1a f0    	mov    %ax,0xf01ab0be

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103034:	c7 05 44 b7 1a f0 00 	movl   $0xefc00000,0xf01ab744
f010303b:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f010303e:	66 c7 05 48 b7 1a f0 	movw   $0x10,0xf01ab748
f0103045:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103047:	66 c7 05 48 93 11 f0 	movw   $0x68,0xf0119348
f010304e:	68 00 
f0103050:	b8 40 b7 1a f0       	mov    $0xf01ab740,%eax
f0103055:	66 a3 4a 93 11 f0    	mov    %ax,0xf011934a
f010305b:	89 c2                	mov    %eax,%edx
f010305d:	c1 ea 10             	shr    $0x10,%edx
f0103060:	88 15 4c 93 11 f0    	mov    %dl,0xf011934c
f0103066:	c6 05 4e 93 11 f0 40 	movb   $0x40,0xf011934e
f010306d:	c1 e8 18             	shr    $0x18,%eax
f0103070:	a2 4f 93 11 f0       	mov    %al,0xf011934f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0103075:	c6 05 4d 93 11 f0 89 	movb   $0x89,0xf011934d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010307c:	b8 28 00 00 00       	mov    $0x28,%eax
f0103081:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0103084:	0f 01 1d 5c 93 11 f0 	lidtl  0xf011935c
}
f010308b:	5d                   	pop    %ebp
f010308c:	c3                   	ret    

f010308d <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f010308d:	55                   	push   %ebp
f010308e:	89 e5                	mov    %esp,%ebp
f0103090:	53                   	push   %ebx
f0103091:	83 ec 14             	sub    $0x14,%esp
f0103094:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103097:	8b 03                	mov    (%ebx),%eax
f0103099:	89 44 24 04          	mov    %eax,0x4(%esp)
f010309d:	c7 04 24 5e 59 10 f0 	movl   $0xf010595e,(%esp)
f01030a4:	e8 6e f9 ff ff       	call   f0102a17 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01030a9:	8b 43 04             	mov    0x4(%ebx),%eax
f01030ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030b0:	c7 04 24 6d 59 10 f0 	movl   $0xf010596d,(%esp)
f01030b7:	e8 5b f9 ff ff       	call   f0102a17 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01030bc:	8b 43 08             	mov    0x8(%ebx),%eax
f01030bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030c3:	c7 04 24 7c 59 10 f0 	movl   $0xf010597c,(%esp)
f01030ca:	e8 48 f9 ff ff       	call   f0102a17 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01030cf:	8b 43 0c             	mov    0xc(%ebx),%eax
f01030d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030d6:	c7 04 24 8b 59 10 f0 	movl   $0xf010598b,(%esp)
f01030dd:	e8 35 f9 ff ff       	call   f0102a17 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01030e2:	8b 43 10             	mov    0x10(%ebx),%eax
f01030e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030e9:	c7 04 24 9a 59 10 f0 	movl   $0xf010599a,(%esp)
f01030f0:	e8 22 f9 ff ff       	call   f0102a17 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01030f5:	8b 43 14             	mov    0x14(%ebx),%eax
f01030f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030fc:	c7 04 24 a9 59 10 f0 	movl   $0xf01059a9,(%esp)
f0103103:	e8 0f f9 ff ff       	call   f0102a17 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103108:	8b 43 18             	mov    0x18(%ebx),%eax
f010310b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010310f:	c7 04 24 b8 59 10 f0 	movl   $0xf01059b8,(%esp)
f0103116:	e8 fc f8 ff ff       	call   f0102a17 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010311b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010311e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103122:	c7 04 24 c7 59 10 f0 	movl   $0xf01059c7,(%esp)
f0103129:	e8 e9 f8 ff ff       	call   f0102a17 <cprintf>
}
f010312e:	83 c4 14             	add    $0x14,%esp
f0103131:	5b                   	pop    %ebx
f0103132:	5d                   	pop    %ebp
f0103133:	c3                   	ret    

f0103134 <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f0103134:	55                   	push   %ebp
f0103135:	89 e5                	mov    %esp,%ebp
f0103137:	53                   	push   %ebx
f0103138:	83 ec 14             	sub    $0x14,%esp
f010313b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010313e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103142:	c7 04 24 d6 59 10 f0 	movl   $0xf01059d6,(%esp)
f0103149:	e8 c9 f8 ff ff       	call   f0102a17 <cprintf>
	print_regs(&tf->tf_regs);
f010314e:	89 1c 24             	mov    %ebx,(%esp)
f0103151:	e8 37 ff ff ff       	call   f010308d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103156:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010315a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010315e:	c7 04 24 e8 59 10 f0 	movl   $0xf01059e8,(%esp)
f0103165:	e8 ad f8 ff ff       	call   f0102a17 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010316a:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010316e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103172:	c7 04 24 fb 59 10 f0 	movl   $0xf01059fb,(%esp)
f0103179:	e8 99 f8 ff ff       	call   f0102a17 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010317e:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103181:	83 f8 13             	cmp    $0x13,%eax
f0103184:	77 09                	ja     f010318f <print_trapframe+0x5b>
		return excnames[trapno];
f0103186:	8b 14 85 80 5c 10 f0 	mov    -0xfefa380(,%eax,4),%edx
f010318d:	eb 1d                	jmp    f01031ac <print_trapframe+0x78>
	if (trapno == T_SYSCALL)
f010318f:	ba 0e 5a 10 f0       	mov    $0xf0105a0e,%edx
f0103194:	83 f8 30             	cmp    $0x30,%eax
f0103197:	74 13                	je     f01031ac <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103199:	8d 50 e0             	lea    -0x20(%eax),%edx
f010319c:	83 fa 10             	cmp    $0x10,%edx
f010319f:	ba 1a 5a 10 f0       	mov    $0xf0105a1a,%edx
f01031a4:	b9 29 5a 10 f0       	mov    $0xf0105a29,%ecx
f01031a9:	0f 42 d1             	cmovb  %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01031ac:	89 54 24 08          	mov    %edx,0x8(%esp)
f01031b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031b4:	c7 04 24 3c 5a 10 f0 	movl   $0xf0105a3c,(%esp)
f01031bb:	e8 57 f8 ff ff       	call   f0102a17 <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f01031c0:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01031c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031c7:	c7 04 24 4e 5a 10 f0 	movl   $0xf0105a4e,(%esp)
f01031ce:	e8 44 f8 ff ff       	call   f0102a17 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01031d3:	8b 43 30             	mov    0x30(%ebx),%eax
f01031d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031da:	c7 04 24 5d 5a 10 f0 	movl   $0xf0105a5d,(%esp)
f01031e1:	e8 31 f8 ff ff       	call   f0102a17 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01031e6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01031ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031ee:	c7 04 24 6c 5a 10 f0 	movl   $0xf0105a6c,(%esp)
f01031f5:	e8 1d f8 ff ff       	call   f0102a17 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01031fa:	8b 43 38             	mov    0x38(%ebx),%eax
f01031fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103201:	c7 04 24 7f 5a 10 f0 	movl   $0xf0105a7f,(%esp)
f0103208:	e8 0a f8 ff ff       	call   f0102a17 <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f010320d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103210:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103214:	c7 04 24 8e 5a 10 f0 	movl   $0xf0105a8e,(%esp)
f010321b:	e8 f7 f7 ff ff       	call   f0102a17 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103220:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103224:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103228:	c7 04 24 9d 5a 10 f0 	movl   $0xf0105a9d,(%esp)
f010322f:	e8 e3 f7 ff ff       	call   f0102a17 <cprintf>
}
f0103234:	83 c4 14             	add    $0x14,%esp
f0103237:	5b                   	pop    %ebx
f0103238:	5d                   	pop    %ebp
f0103239:	c3                   	ret    

f010323a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010323a:	55                   	push   %ebp
f010323b:	89 e5                	mov    %esp,%ebp
f010323d:	83 ec 38             	sub    $0x38,%esp
f0103240:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103243:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103246:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103249:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010324c:	0f 20 d0             	mov    %cr2,%eax
f010324f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.

	if ((tf->tf_cs & 0x3) == 0)
f0103252:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103256:	75 1c                	jne    f0103274 <page_fault_handler+0x3a>
		panic("page fault handler: in kernel mode\n");
f0103258:	c7 44 24 08 20 5c 10 	movl   $0xf0105c20,0x8(%esp)
f010325f:	f0 
f0103260:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
f0103267:	00 
f0103268:	c7 04 24 b0 5a 10 f0 	movl   $0xf0105ab0,(%esp)
f010326f:	e8 0c ce ff ff       	call   f0100080 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.   
	
	if (curenv->env_pgfault_upcall != NULL) 
f0103274:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103279:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010327d:	0f 84 8f 00 00 00    	je     f0103312 <page_fault_handler+0xd8>
	{
		struct UTrapframe *utf;

		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp < UXSTACKTOP)
f0103283:	8b 53 3c             	mov    0x3c(%ebx),%edx
f0103286:	8d 8a 00 10 40 11    	lea    0x11401000(%edx),%ecx
f010328c:	83 ea 38             	sub    $0x38,%edx
f010328f:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0103295:	b9 cc ff bf ee       	mov    $0xeebfffcc,%ecx
f010329a:	0f 42 ca             	cmovb  %edx,%ecx
f010329d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		      utf = (struct UTrapframe *)(tf->tf_esp - sizeof (struct UTrapframe) - 4);
		else
		      utf = (struct UTrapframe *)(UXSTACKTOP - sizeof (struct UTrapframe));
		user_mem_assert (curenv,(void*) utf,sizeof (struct UTrapframe),PTE_U|PTE_W);
f01032a0:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01032a7:	00 
f01032a8:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01032af:	00 
f01032b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01032b4:	89 04 24             	mov    %eax,(%esp)
f01032b7:	e8 2d dd ff ff       	call   f0100fe9 <user_mem_assert>
		
		utf->utf_esp = tf->tf_esp;
f01032bc:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01032bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01032c2:	89 46 30             	mov    %eax,0x30(%esi)
		utf->utf_eflags = tf->tf_eflags;
f01032c5:	8b 43 38             	mov    0x38(%ebx),%eax
f01032c8:	89 46 2c             	mov    %eax,0x2c(%esi)
		utf->utf_eip = tf->tf_eip;
f01032cb:	8b 43 30             	mov    0x30(%ebx),%eax
f01032ce:	89 46 28             	mov    %eax,0x28(%esi)
		utf->utf_regs = tf->tf_regs;
f01032d1:	89 f2                	mov    %esi,%edx
f01032d3:	83 c2 08             	add    $0x8,%edx
f01032d6:	b9 08 00 00 00       	mov    $0x8,%ecx
f01032db:	89 d7                	mov    %edx,%edi
f01032dd:	89 de                	mov    %ebx,%esi
f01032df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_err = tf->tf_err;
f01032e1:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01032e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032e7:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_fault_va =fault_va;
f01032ea:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01032ed:	89 32                	mov    %esi,(%edx)

		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f01032ef:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f01032f4:	8b 50 64             	mov    0x64(%eax),%edx
f01032f7:	89 50 30             	mov    %edx,0x30(%eax)
		curenv->env_tf.tf_esp = (uint32_t) utf;
f01032fa:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f01032ff:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103302:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run (curenv);
f0103305:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f010330a:	89 04 24             	mov    %eax,(%esp)
f010330d:	e8 4d ef ff ff       	call   f010225f <env_run>
	 }
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103312:	8b 53 30             	mov    0x30(%ebx),%edx
f0103315:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103319:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010331c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103320:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103323:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103327:	c7 04 24 44 5c 10 f0 	movl   $0xf0105c44,(%esp)
f010332e:	e8 e4 f6 ff ff       	call   f0102a17 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103333:	89 1c 24             	mov    %ebx,(%esp)
f0103336:	e8 f9 fd ff ff       	call   f0103134 <print_trapframe>
	env_destroy(curenv);
f010333b:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103340:	89 04 24             	mov    %eax,(%esp)
f0103343:	e8 de f0 ff ff       	call   f0102426 <env_destroy>
}
f0103348:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010334b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010334e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103351:	89 ec                	mov    %ebp,%esp
f0103353:	5d                   	pop    %ebp
f0103354:	c3                   	ret    

f0103355 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103355:	55                   	push   %ebp
f0103356:	89 e5                	mov    %esp,%ebp
f0103358:	57                   	push   %edi
f0103359:	56                   	push   %esi
f010335a:	83 ec 20             	sub    $0x20,%esp
f010335d:	8b 75 08             	mov    0x8(%ebp),%esi
	if ((tf->tf_cs & 3) == 3) {
f0103360:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103364:	83 e0 03             	and    $0x3,%eax
f0103367:	83 f8 03             	cmp    $0x3,%eax
f010336a:	75 3c                	jne    f01033a8 <trap+0x53>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f010336c:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103371:	85 c0                	test   %eax,%eax
f0103373:	75 24                	jne    f0103399 <trap+0x44>
f0103375:	c7 44 24 0c bc 5a 10 	movl   $0xf0105abc,0xc(%esp)
f010337c:	f0 
f010337d:	c7 44 24 08 f9 56 10 	movl   $0xf01056f9,0x8(%esp)
f0103384:	f0 
f0103385:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
f010338c:	00 
f010338d:	c7 04 24 b0 5a 10 f0 	movl   $0xf0105ab0,(%esp)
f0103394:	e8 e7 cc ff ff       	call   f0100080 <_panic>
		curenv->env_tf = *tf;
f0103399:	b9 11 00 00 00       	mov    $0x11,%ecx
f010339e:	89 c7                	mov    %eax,%edi
f01033a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01033a2:	8b 35 24 af 1a f0    	mov    0xf01aaf24,%esi
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
        if(tf->tf_trapno==T_PGFLT)   
f01033a8:	8b 46 28             	mov    0x28(%esi),%eax
f01033ab:	83 f8 0e             	cmp    $0xe,%eax
f01033ae:	75 0d                	jne    f01033bd <trap+0x68>
        {
		page_fault_handler(tf);
f01033b0:	89 34 24             	mov    %esi,(%esp)
f01033b3:	e8 82 fe ff ff       	call   f010323a <page_fault_handler>
f01033b8:	e9 90 00 00 00       	jmp    f010344d <trap+0xf8>
		return;
	}
        
        if(tf->tf_trapno == T_BRKPT)
f01033bd:	83 f8 03             	cmp    $0x3,%eax
f01033c0:	75 10                	jne    f01033d2 <trap+0x7d>
        {
		monitor(tf);
f01033c2:	89 34 24             	mov    %esi,(%esp)
f01033c5:	8d 76 00             	lea    0x0(%esi),%esi
f01033c8:	e8 33 d4 ff ff       	call   f0100800 <monitor>
f01033cd:	8d 76 00             	lea    0x0(%esi),%esi
f01033d0:	eb 7b                	jmp    f010344d <trap+0xf8>
		return;
	}

        if (tf -> tf_trapno ==T_SYSCALL) 
f01033d2:	83 f8 30             	cmp    $0x30,%eax
f01033d5:	75 32                	jne    f0103409 <trap+0xb4>
        {//cprintf("%d\n",tf->tf_regs.reg_eax);
	
tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,
f01033d7:	8b 46 04             	mov    0x4(%esi),%eax
f01033da:	89 44 24 14          	mov    %eax,0x14(%esp)
f01033de:	8b 06                	mov    (%esi),%eax
f01033e0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01033e4:	8b 46 10             	mov    0x10(%esi),%eax
f01033e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033eb:	8b 46 18             	mov    0x18(%esi),%eax
f01033ee:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033f2:	8b 46 14             	mov    0x14(%esi),%eax
f01033f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033f9:	8b 46 1c             	mov    0x1c(%esi),%eax
f01033fc:	89 04 24             	mov    %eax,(%esp)
f01033ff:	e8 4c 02 00 00       	call   f0103650 <syscall>
f0103404:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103407:	eb 44                	jmp    f010344d <trap+0xf8>

	
	// Handle clock and serial interrupts.
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0103409:	83 f8 20             	cmp    $0x20,%eax
f010340c:	75 07                	jne    f0103415 <trap+0xc0>
		sched_yield ();
f010340e:	66 90                	xchg   %ax,%ax
f0103410:	e8 8b 01 00 00       	call   f01035a0 <sched_yield>

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103415:	89 34 24             	mov    %esi,(%esp)
f0103418:	e8 17 fd ff ff       	call   f0103134 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010341d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103422:	75 1c                	jne    f0103440 <trap+0xeb>
		panic("unhandled trap in kernel");
f0103424:	c7 44 24 08 c3 5a 10 	movl   $0xf0105ac3,0x8(%esp)
f010342b:	f0 
f010342c:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f0103433:	00 
f0103434:	c7 04 24 b0 5a 10 f0 	movl   $0xf0105ab0,(%esp)
f010343b:	e8 40 cc ff ff       	call   f0100080 <_panic>
	else {
		env_destroy(curenv);
f0103440:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103445:	89 04 24             	mov    %eax,(%esp)
f0103448:	e8 d9 ef ff ff       	call   f0102426 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
f010344d:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103452:	85 c0                	test   %eax,%eax
f0103454:	74 0e                	je     f0103464 <trap+0x10f>
f0103456:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010345a:	75 08                	jne    f0103464 <trap+0x10f>
		env_run(curenv);
f010345c:	89 04 24             	mov    %eax,(%esp)
f010345f:	e8 fb ed ff ff       	call   f010225f <env_run>
	else
		sched_yield();
f0103464:	e8 37 01 00 00       	call   f01035a0 <sched_yield>
f0103469:	00 00                	add    %al,(%eax)
	...

f010346c <trap_divide>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	
         TRAPHANDLER_NOEC(trap_divide, T_DIVIDE)
f010346c:	6a 00                	push   $0x0
f010346e:	6a 00                	push   $0x0
f0103470:	e9 0b 01 00 00       	jmp    f0103580 <_alltraps>
f0103475:	90                   	nop

f0103476 <trap_debug>:
         TRAPHANDLER_NOEC(trap_debug, T_DEBUG)
f0103476:	6a 00                	push   $0x0
f0103478:	6a 01                	push   $0x1
f010347a:	e9 01 01 00 00       	jmp    f0103580 <_alltraps>
f010347f:	90                   	nop

f0103480 <trap_nmi>:
         TRAPHANDLER_NOEC(trap_nmi, T_NMI)
f0103480:	6a 00                	push   $0x0
f0103482:	6a 02                	push   $0x2
f0103484:	e9 f7 00 00 00       	jmp    f0103580 <_alltraps>
f0103489:	90                   	nop

f010348a <trap_brkpt>:
         TRAPHANDLER_NOEC(trap_brkpt, T_BRKPT)
f010348a:	6a 00                	push   $0x0
f010348c:	6a 03                	push   $0x3
f010348e:	e9 ed 00 00 00       	jmp    f0103580 <_alltraps>
f0103493:	90                   	nop

f0103494 <trap_oflow>:
         TRAPHANDLER_NOEC(trap_oflow, T_OFLOW)
f0103494:	6a 00                	push   $0x0
f0103496:	6a 04                	push   $0x4
f0103498:	e9 e3 00 00 00       	jmp    f0103580 <_alltraps>
f010349d:	90                   	nop

f010349e <trap_bound>:
         TRAPHANDLER_NOEC(trap_bound, T_BOUND)
f010349e:	6a 00                	push   $0x0
f01034a0:	6a 05                	push   $0x5
f01034a2:	e9 d9 00 00 00       	jmp    f0103580 <_alltraps>
f01034a7:	90                   	nop

f01034a8 <trap_illop>:
         TRAPHANDLER_NOEC(trap_illop, T_ILLOP)
f01034a8:	6a 00                	push   $0x0
f01034aa:	6a 06                	push   $0x6
f01034ac:	e9 cf 00 00 00       	jmp    f0103580 <_alltraps>
f01034b1:	90                   	nop

f01034b2 <trap_device>:
         TRAPHANDLER_NOEC(trap_device, T_DEVICE)
f01034b2:	6a 00                	push   $0x0
f01034b4:	6a 07                	push   $0x7
f01034b6:	e9 c5 00 00 00       	jmp    f0103580 <_alltraps>
f01034bb:	90                   	nop

f01034bc <trap_dblflt>:
         TRAPHANDLER(trap_dblflt, T_DBLFLT)
f01034bc:	6a 08                	push   $0x8
f01034be:	e9 bd 00 00 00       	jmp    f0103580 <_alltraps>
f01034c3:	90                   	nop

f01034c4 <trap_tss>:
         TRAPHANDLER(trap_tss, T_TSS)
f01034c4:	6a 0a                	push   $0xa
f01034c6:	e9 b5 00 00 00       	jmp    f0103580 <_alltraps>
f01034cb:	90                   	nop

f01034cc <trap_segnp>:
         TRAPHANDLER(trap_segnp, T_SEGNP)
f01034cc:	6a 0b                	push   $0xb
f01034ce:	e9 ad 00 00 00       	jmp    f0103580 <_alltraps>
f01034d3:	90                   	nop

f01034d4 <trap_stack>:
         TRAPHANDLER(trap_stack, T_STACK)
f01034d4:	6a 0c                	push   $0xc
f01034d6:	e9 a5 00 00 00       	jmp    f0103580 <_alltraps>
f01034db:	90                   	nop

f01034dc <trap_gpflt>:
         TRAPHANDLER(trap_gpflt, T_GPFLT)
f01034dc:	6a 0d                	push   $0xd
f01034de:	e9 9d 00 00 00       	jmp    f0103580 <_alltraps>
f01034e3:	90                   	nop

f01034e4 <trap_pgflt>:
         TRAPHANDLER(trap_pgflt, T_PGFLT)
f01034e4:	6a 0e                	push   $0xe
f01034e6:	e9 95 00 00 00       	jmp    f0103580 <_alltraps>
f01034eb:	90                   	nop

f01034ec <trap_fperr>:
         TRAPHANDLER_NOEC(trap_fperr, T_FPERR)
f01034ec:	6a 00                	push   $0x0
f01034ee:	6a 10                	push   $0x10
f01034f0:	e9 8b 00 00 00       	jmp    f0103580 <_alltraps>
f01034f5:	90                   	nop

f01034f6 <trap_align>:
         TRAPHANDLER(trap_align, T_ALIGN)
f01034f6:	6a 11                	push   $0x11
f01034f8:	e9 83 00 00 00       	jmp    f0103580 <_alltraps>
f01034fd:	90                   	nop

f01034fe <trap_mchk>:
         TRAPHANDLER_NOEC(trap_mchk, T_MCHK)
f01034fe:	6a 00                	push   $0x0
f0103500:	6a 12                	push   $0x12
f0103502:	eb 7c                	jmp    f0103580 <_alltraps>

f0103504 <trap_simderr>:
         TRAPHANDLER_NOEC(trap_simderr, T_SIMDERR)
f0103504:	6a 00                	push   $0x0
f0103506:	6a 13                	push   $0x13
f0103508:	eb 76                	jmp    f0103580 <_alltraps>

f010350a <trap_syscall>:

         TRAPHANDLER_NOEC(trap_syscall, T_SYSCALL)
f010350a:	6a 00                	push   $0x0
f010350c:	6a 30                	push   $0x30
f010350e:	eb 70                	jmp    f0103580 <_alltraps>

f0103510 <_default>:

         TRAPHANDLER_NOEC(_default, T_DEFAULT)
f0103510:	6a 00                	push   $0x0
f0103512:	68 f4 01 00 00       	push   $0x1f4
f0103517:	eb 67                	jmp    f0103580 <_alltraps>
f0103519:	90                   	nop

f010351a <_timer>:


	TRAPHANDLER_NOEC(_timer, IRQ_OFFSET + IRQ_TIMER);
f010351a:	6a 00                	push   $0x0
f010351c:	6a 20                	push   $0x20
f010351e:	eb 60                	jmp    f0103580 <_alltraps>

f0103520 <inter_irq_0>:

	TRAPHANDLER_NOEC(inter_irq_0,  IRQ_OFFSET+0);
f0103520:	6a 00                	push   $0x0
f0103522:	6a 20                	push   $0x20
f0103524:	eb 5a                	jmp    f0103580 <_alltraps>

f0103526 <inter_irq_1>:
	TRAPHANDLER_NOEC(inter_irq_1,  IRQ_OFFSET+1);
f0103526:	6a 00                	push   $0x0
f0103528:	6a 21                	push   $0x21
f010352a:	eb 54                	jmp    f0103580 <_alltraps>

f010352c <inter_irq_2>:
	TRAPHANDLER_NOEC(inter_irq_2,  IRQ_OFFSET+2);
f010352c:	6a 00                	push   $0x0
f010352e:	6a 22                	push   $0x22
f0103530:	eb 4e                	jmp    f0103580 <_alltraps>

f0103532 <inter_irq_3>:
	TRAPHANDLER_NOEC(inter_irq_3,  IRQ_OFFSET+3);
f0103532:	6a 00                	push   $0x0
f0103534:	6a 23                	push   $0x23
f0103536:	eb 48                	jmp    f0103580 <_alltraps>

f0103538 <inter_irq_4>:
	TRAPHANDLER_NOEC(inter_irq_4,  IRQ_OFFSET+4);
f0103538:	6a 00                	push   $0x0
f010353a:	6a 24                	push   $0x24
f010353c:	eb 42                	jmp    f0103580 <_alltraps>

f010353e <inter_irq_5>:
	TRAPHANDLER_NOEC(inter_irq_5,  IRQ_OFFSET+5);
f010353e:	6a 00                	push   $0x0
f0103540:	6a 25                	push   $0x25
f0103542:	eb 3c                	jmp    f0103580 <_alltraps>

f0103544 <inter_irq_6>:
	TRAPHANDLER_NOEC(inter_irq_6,  IRQ_OFFSET+6);
f0103544:	6a 00                	push   $0x0
f0103546:	6a 26                	push   $0x26
f0103548:	eb 36                	jmp    f0103580 <_alltraps>

f010354a <inter_irq_7>:
	TRAPHANDLER_NOEC(inter_irq_7,  IRQ_OFFSET+7);
f010354a:	6a 00                	push   $0x0
f010354c:	6a 27                	push   $0x27
f010354e:	eb 30                	jmp    f0103580 <_alltraps>

f0103550 <inter_irq_8>:
	TRAPHANDLER_NOEC(inter_irq_8,  IRQ_OFFSET+8);
f0103550:	6a 00                	push   $0x0
f0103552:	6a 28                	push   $0x28
f0103554:	eb 2a                	jmp    f0103580 <_alltraps>

f0103556 <inter_irq_9>:
	TRAPHANDLER_NOEC(inter_irq_9,  IRQ_OFFSET+9);
f0103556:	6a 00                	push   $0x0
f0103558:	6a 29                	push   $0x29
f010355a:	eb 24                	jmp    f0103580 <_alltraps>

f010355c <inter_irq_10>:
	TRAPHANDLER_NOEC(inter_irq_10, IRQ_OFFSET+10);
f010355c:	6a 00                	push   $0x0
f010355e:	6a 2a                	push   $0x2a
f0103560:	eb 1e                	jmp    f0103580 <_alltraps>

f0103562 <inter_irq_11>:
	TRAPHANDLER_NOEC(inter_irq_11, IRQ_OFFSET+11);
f0103562:	6a 00                	push   $0x0
f0103564:	6a 2b                	push   $0x2b
f0103566:	eb 18                	jmp    f0103580 <_alltraps>

f0103568 <inter_irq_12>:
	TRAPHANDLER_NOEC(inter_irq_12, IRQ_OFFSET+12);
f0103568:	6a 00                	push   $0x0
f010356a:	6a 2c                	push   $0x2c
f010356c:	eb 12                	jmp    f0103580 <_alltraps>

f010356e <inter_irq_13>:
	TRAPHANDLER_NOEC(inter_irq_13, IRQ_OFFSET+13);
f010356e:	6a 00                	push   $0x0
f0103570:	6a 2d                	push   $0x2d
f0103572:	eb 0c                	jmp    f0103580 <_alltraps>

f0103574 <inter_irq_14>:
	TRAPHANDLER_NOEC(inter_irq_14, IRQ_OFFSET+14);
f0103574:	6a 00                	push   $0x0
f0103576:	6a 2e                	push   $0x2e
f0103578:	eb 06                	jmp    f0103580 <_alltraps>

f010357a <inter_irq_15>:
	TRAPHANDLER_NOEC(inter_irq_15, IRQ_OFFSET+15);
f010357a:	6a 00                	push   $0x0
f010357c:	6a 2f                	push   $0x2f
f010357e:	eb 00                	jmp    f0103580 <_alltraps>

f0103580 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
     # Build trap frame.
     pushl %ds
f0103580:	1e                   	push   %ds
     pushl %es
f0103581:	06                   	push   %es
     pushal
f0103582:	60                   	pusha  
     
     # Set up data segments.
     movl $GD_KD, %eax
f0103583:	b8 10 00 00 00       	mov    $0x10,%eax
     movw %ax,%ds
f0103588:	8e d8                	mov    %eax,%ds
     movw %ax,%es
f010358a:	8e c0                	mov    %eax,%es
     
     # Call trap(tf), where tf=%esp
     pushl %esp
f010358c:	54                   	push   %esp
     call trap
f010358d:	e8 c3 fd ff ff       	call   f0103355 <trap>
     popl %esp
f0103592:	5c                   	pop    %esp
 
     # Cleanup pushes and ret
     popal
f0103593:	61                   	popa   
     popl %es
f0103594:	07                   	pop    %es
     popl %ds
f0103595:	1f                   	pop    %ds
     iret	
f0103596:	cf                   	iret   
	...

f01035a0 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01035a0:	55                   	push   %ebp
f01035a1:	89 e5                	mov    %esp,%ebp
f01035a3:	57                   	push   %edi
f01035a4:	56                   	push   %esi
f01035a5:	53                   	push   %ebx
f01035a6:	83 ec 1c             	sub    $0x1c,%esp

	// LAB 4: Your code here.

	 int i;  
         
	 struct Env *e = (curenv == NULL || curenv >= envs + NENV-1) ? envs+1 : curenv+1;
f01035a9:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f01035ae:	85 c0                	test   %eax,%eax
f01035b0:	74 10                	je     f01035c2 <sched_yield+0x22>
f01035b2:	8b 15 20 af 1a f0    	mov    0xf01aaf20,%edx
f01035b8:	81 c2 78 1f 02 00    	add    $0x21f78,%edx
f01035be:	39 d0                	cmp    %edx,%eax
f01035c0:	72 12                	jb     f01035d4 <sched_yield+0x34>
f01035c2:	a1 20 af 1a f0       	mov    0xf01aaf20,%eax
f01035c7:	05 88 00 00 00       	add    $0x88,%eax
     	 
	 for (i = 1; i < NENV; i++) {  
         	if (e->env_status == ENV_RUNNABLE)  
f01035cc:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01035d0:	75 18                	jne    f01035ea <sched_yield+0x4a>
f01035d2:	eb 0e                	jmp    f01035e2 <sched_yield+0x42>

	// LAB 4: Your code here.

	 int i;  
         
	 struct Env *e = (curenv == NULL || curenv >= envs + NENV-1) ? envs+1 : curenv+1;
f01035d4:	05 88 00 00 00       	add    $0x88,%eax
f01035d9:	eb f1                	jmp    f01035cc <sched_yield+0x2c>
     	 
	 for (i = 1; i < NENV; i++) {  
         	if (e->env_status == ENV_RUNNABLE)  
f01035db:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01035df:	90                   	nop
f01035e0:	75 1f                	jne    f0103601 <sched_yield+0x61>
            		env_run(e);  
f01035e2:	89 04 24             	mov    %eax,(%esp)
f01035e5:	e8 75 ec ff ff       	call   f010225f <env_run>
        	e = (e == envs+NENV-1) ? envs+1 : e+1;  
f01035ea:	8b 3d 20 af 1a f0    	mov    0xf01aaf20,%edi
f01035f0:	8d b7 78 1f 02 00    	lea    0x21f78(%edi),%esi
f01035f6:	8d 9f 88 00 00 00    	lea    0x88(%edi),%ebx
f01035fc:	ba 01 00 00 00       	mov    $0x1,%edx
f0103601:	8d 88 88 00 00 00    	lea    0x88(%eax),%ecx
f0103607:	39 c6                	cmp    %eax,%esi
f0103609:	89 d8                	mov    %ebx,%eax
f010360b:	0f 45 c1             	cmovne %ecx,%eax

	 int i;  
         
	 struct Env *e = (curenv == NULL || curenv >= envs + NENV-1) ? envs+1 : curenv+1;
     	 
	 for (i = 1; i < NENV; i++) {  
f010360e:	83 c2 01             	add    $0x1,%edx
f0103611:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103617:	75 c2                	jne    f01035db <sched_yield+0x3b>
        	e = (e == envs+NENV-1) ? envs+1 : e+1;  
    	 }  

	// Run the special idle environment when nothing else is runnable.//                   

	if (envs[0].env_status == ENV_RUNNABLE)
f0103619:	83 7f 54 01          	cmpl   $0x1,0x54(%edi)
f010361d:	75 08                	jne    f0103627 <sched_yield+0x87>
		env_run(&envs[0]);
f010361f:	89 3c 24             	mov    %edi,(%esp)
f0103622:	e8 38 ec ff ff       	call   f010225f <env_run>
	else {
		cprintf("Destroyed all environments - nothing more to do!\n");
f0103627:	c7 04 24 d0 5c 10 f0 	movl   $0xf0105cd0,(%esp)
f010362e:	e8 e4 f3 ff ff       	call   f0102a17 <cprintf>
		while (1)
			monitor(NULL);
f0103633:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010363a:	e8 c1 d1 ff ff       	call   f0100800 <monitor>
f010363f:	eb f2                	jmp    f0103633 <sched_yield+0x93>
	...

f0103650 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
uint32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103650:	55                   	push   %ebp
f0103651:	89 e5                	mov    %esp,%ebp
f0103653:	83 ec 48             	sub    $0x48,%esp
f0103656:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103659:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010365c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010365f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103662:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103665:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103668:	8b 45 1c             	mov    0x1c(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) 
f010366b:	83 fa 0d             	cmp    $0xd,%edx
f010366e:	0f 87 05 06 00 00    	ja     f0103c79 <syscall+0x629>
f0103674:	ff 24 95 3c 5d 10 f0 	jmp    *-0xfefa2c4(,%edx,4)
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.

	 user_mem_assert(curenv, s, len, PTE_U | PTE_P);
f010367b:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0103682:	00 
f0103683:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103687:	89 74 24 04          	mov    %esi,0x4(%esp)
f010368b:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103690:	89 04 24             	mov    %eax,(%esp)
f0103693:	e8 51 d9 ff ff       	call   f0100fe9 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103698:	89 74 24 08          	mov    %esi,0x8(%esp)
f010369c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01036a0:	c7 04 24 04 5d 10 f0 	movl   $0xf0105d04,(%esp)
f01036a7:	e8 6b f3 ff ff       	call   f0102a17 <cprintf>
f01036ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01036b1:	e9 c8 05 00 00       	jmp    f0103c7e <syscall+0x62e>
{
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f01036b6:	e8 ee cb ff ff       	call   f01002a9 <cons_getc>
f01036bb:	85 c0                	test   %eax,%eax
f01036bd:	8d 76 00             	lea    0x0(%esi),%esi
f01036c0:	74 f4                	je     f01036b6 <syscall+0x66>
f01036c2:	e9 b7 05 00 00       	jmp    f0103c7e <syscall+0x62e>
                  sys_cputs((const char *)a1, (size_t)a2);
                  return 0;
             case SYS_cgetc:
                  return sys_cgetc();
             case SYS_getenvid:
                  return sys_getenvid();
f01036c7:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f01036cc:	8b 40 4c             	mov    0x4c(%eax),%eax
f01036cf:	90                   	nop
f01036d0:	e9 a9 05 00 00       	jmp    f0103c7e <syscall+0x62e>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01036d5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01036dc:	00 
f01036dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01036e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036e4:	89 34 24             	mov    %esi,(%esp)
f01036e7:	e8 54 ea ff ff       	call   f0102140 <envid2env>
f01036ec:	85 c0                	test   %eax,%eax
f01036ee:	0f 88 8a 05 00 00    	js     f0103c7e <syscall+0x62e>
		return r;
	if (e == curenv)
f01036f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036f7:	8b 15 24 af 1a f0    	mov    0xf01aaf24,%edx
f01036fd:	39 d0                	cmp    %edx,%eax
f01036ff:	75 15                	jne    f0103716 <syscall+0xc6>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103701:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103704:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103708:	c7 04 24 09 5d 10 f0 	movl   $0xf0105d09,(%esp)
f010370f:	e8 03 f3 ff ff       	call   f0102a17 <cprintf>
f0103714:	eb 1a                	jmp    f0103730 <syscall+0xe0>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103716:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103719:	89 44 24 08          	mov    %eax,0x8(%esp)
f010371d:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103720:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103724:	c7 04 24 24 5d 10 f0 	movl   $0xf0105d24,(%esp)
f010372b:	e8 e7 f2 ff ff       	call   f0102a17 <cprintf>
	env_destroy(e);
f0103730:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103733:	89 04 24             	mov    %eax,(%esp)
f0103736:	e8 eb ec ff ff       	call   f0102426 <env_destroy>
f010373b:	b8 00 00 00 00       	mov    $0x0,%eax
             case SYS_cgetc:
                  return sys_cgetc();
             case SYS_getenvid:
                  return sys_getenvid();
			 case SYS_env_destroy:
				  return sys_env_destroy((envid_t)a1);
f0103740:	e9 39 05 00 00       	jmp    f0103c7e <syscall+0x62e>
// Deschedule current environment and pick a different one to run.
// The system call returns 0.
static void
sys_yield(void)
{
	sched_yield();
f0103745:	e8 56 fe ff ff       	call   f01035a0 <sched_yield>
	
	// LAB 4: Your code here.

	envid_t ret;  
    struct Env *e;  
    ret =  env_alloc(&e, curenv->env_id);  
f010374a:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f010374f:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103752:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103756:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0103759:	89 04 24             	mov    %eax,(%esp)
f010375c:	e8 f4 ec ff ff       	call   f0102455 <env_alloc>
	if (ret < 0)  
f0103761:	85 c0                	test   %eax,%eax
f0103763:	0f 88 15 05 00 00    	js     f0103c7e <syscall+0x62e>
        return ret; 
    e->env_status = ENV_NOT_RUNNABLE;
f0103769:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010376c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    e->env_tf = curenv->env_tf;  
f0103773:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103776:	8b 35 24 af 1a f0    	mov    0xf01aaf24,%esi
f010377c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103781:	89 c7                	mov    %eax,%edi
f0103783:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    e->env_tf.tf_regs.reg_eax = 0; 
f0103785:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103788:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    return e->env_id;  
f010378f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103792:	8b 40 4c             	mov    0x4c(%eax),%eax

			 case SYS_yield:
				  sys_yield();
				  return 0;
			 case SYS_exofork:
				  return sys_exofork();
f0103795:	e9 e4 04 00 00       	jmp    f0103c7e <syscall+0x62e>
	// check whether the current environment has permission to set
	// envid's status.
	
	// LAB 4: Your code here.
	struct Env *e;  
        if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)  
f010379a:	8d 47 ff             	lea    -0x1(%edi),%eax
f010379d:	83 f8 01             	cmp    $0x1,%eax
f01037a0:	76 0a                	jbe    f01037ac <syscall+0x15c>
f01037a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01037a7:	e9 d2 04 00 00       	jmp    f0103c7e <syscall+0x62e>
             return -E_INVAL;    
                                
	if (envid2env(envid, &e, 1) <0) 
f01037ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01037b3:	00 
f01037b4:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01037b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037bb:	89 34 24             	mov    %esi,(%esp)
f01037be:	e8 7d e9 ff ff       	call   f0102140 <envid2env>
f01037c3:	89 c2                	mov    %eax,%edx
f01037c5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01037ca:	85 d2                	test   %edx,%edx
f01037cc:	0f 88 ac 04 00 00    	js     f0103c7e <syscall+0x62e>
            return -E_BAD_ENV;  
        e->env_status = status;  
f01037d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01037d5:	89 78 54             	mov    %edi,0x54(%eax)
f01037d8:	b8 00 00 00 00       	mov    $0x0,%eax
				  return 0;
			 case SYS_exofork:
				  return sys_exofork();

			 case SYS_env_set_status:
				  return sys_env_set_status((envid_t) a1,(int) a2);
f01037dd:	e9 9c 04 00 00       	jmp    f0103c7e <syscall+0x62e>

	// LAB 4: Your code here.

       struct Env *e;  
       struct Page *page;  
       if ( (uint32_t)va >= UTOP || PGOFF(va) != 0 || (perm&5) != 5 || (perm & (~PTE_USER)) != 0 )  
f01037e2:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01037e8:	0f 87 ff 00 00 00    	ja     f01038ed <syscall+0x29d>
f01037ee:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f01037f4:	0f 85 f3 00 00 00    	jne    f01038ed <syscall+0x29d>
f01037fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01037fd:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0103802:	83 f8 05             	cmp    $0x5,%eax
f0103805:	0f 85 e2 00 00 00    	jne    f01038ed <syscall+0x29d>
           return -E_INVAL;  
       if (envid2env(envid, &e, 1) <0)   
f010380b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103812:	00 
f0103813:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0103816:	89 44 24 04          	mov    %eax,0x4(%esp)
f010381a:	89 34 24             	mov    %esi,(%esp)
f010381d:	e8 1e e9 ff ff       	call   f0102140 <envid2env>
f0103822:	89 c2                	mov    %eax,%edx
f0103824:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103829:	85 d2                	test   %edx,%edx
f010382b:	0f 88 4d 04 00 00    	js     f0103c7e <syscall+0x62e>
          return -E_BAD_ENV;  
       if (page_alloc(&page) <0)  
f0103831:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103834:	89 04 24             	mov    %eax,(%esp)
f0103837:	e8 1f d5 ff ff       	call   f0100d5b <page_alloc>
f010383c:	89 c2                	mov    %eax,%edx
f010383e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103843:	85 d2                	test   %edx,%edx
f0103845:	0f 88 33 04 00 00    	js     f0103c7e <syscall+0x62e>
           return -E_NO_MEM;  
       if (page_insert(e->env_pgdir, page, va, perm) <0)  
f010384b:	8b 45 14             	mov    0x14(%ebp),%eax
f010384e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103852:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103856:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103859:	89 44 24 04          	mov    %eax,0x4(%esp)
f010385d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103860:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103863:	89 04 24             	mov    %eax,(%esp)
f0103866:	e8 a6 d8 ff ff       	call   f0101111 <page_insert>
f010386b:	85 c0                	test   %eax,%eax
f010386d:	79 15                	jns    f0103884 <syscall+0x234>
       {  
           page_free(page);  
f010386f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103872:	89 04 24             	mov    %eax,(%esp)
f0103875:	e8 f7 d1 ff ff       	call   f0100a71 <page_free>
f010387a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010387f:	e9 fa 03 00 00       	jmp    f0103c7e <syscall+0x62e>
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0103884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103887:	2b 05 cc bb 1a f0    	sub    0xf01abbcc,%eax
f010388d:	c1 f8 02             	sar    $0x2,%eax
f0103890:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103896:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0103899:	89 c2                	mov    %eax,%edx
f010389b:	c1 ea 0c             	shr    $0xc,%edx
f010389e:	3b 15 c0 bb 1a f0    	cmp    0xf01abbc0,%edx
f01038a4:	72 20                	jb     f01038c6 <syscall+0x276>
f01038a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038aa:	c7 44 24 08 44 52 10 	movl   $0xf0105244,0x8(%esp)
f01038b1:	f0 
f01038b2:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
f01038b9:	00 
f01038ba:	c7 04 24 d5 56 10 f0 	movl   $0xf01056d5,(%esp)
f01038c1:	e8 ba c7 ff ff       	call   f0100080 <_panic>
           return -E_NO_MEM;  
       }  
       //fill the new page with 0  
       memset(page2kva(page), 0, PGSIZE);  
f01038c6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038cd:	00 
f01038ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038d5:	00 
f01038d6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038db:	89 04 24             	mov    %eax,(%esp)
f01038de:	e8 f3 0f 00 00       	call   f01048d6 <memset>
f01038e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e8:	e9 91 03 00 00       	jmp    f0103c7e <syscall+0x62e>
f01038ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

			 case SYS_env_set_status:
				  return sys_env_set_status((envid_t) a1,(int) a2);

			 case SYS_page_alloc:
				  return sys_page_alloc((envid_t) a1,(void*) a2,(int) a3);
f01038f2:	e9 87 03 00 00       	jmp    f0103c7e <syscall+0x62e>

			 case SYS_page_map:
				  return sys_page_map((envid_t) a1,(void*) a2,(envid_t) a3,(void*) a4,(int) a5);
f01038f7:	89 fb                	mov    %edi,%ebx
	//   parameters for correctness.  
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	if (srcva >= (void *)UTOP || ROUNDUP (srcva, PGSIZE) != srcva
f01038f9:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01038ff:	90                   	nop
f0103900:	0f 87 e4 00 00 00    	ja     f01039ea <syscall+0x39a>
f0103906:	8d 97 ff 0f 00 00    	lea    0xfff(%edi),%edx
f010390c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103912:	39 d7                	cmp    %edx,%edi
f0103914:	0f 85 d0 00 00 00    	jne    f01039ea <syscall+0x39a>

			 case SYS_page_alloc:
				  return sys_page_alloc((envid_t) a1,(void*) a2,(int) a3);

			 case SYS_page_map:
				  return sys_page_map((envid_t) a1,(void*) a2,(envid_t) a3,(void*) a4,(int) a5);
f010391a:	8b 55 18             	mov    0x18(%ebp),%edx
f010391d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	//   parameters for correctness.  
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	if (srcva >= (void *)UTOP || ROUNDUP (srcva, PGSIZE) != srcva
f0103920:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0103926:	0f 87 be 00 00 00    	ja     f01039ea <syscall+0x39a>
 	|| dstva >= (void *)UTOP || ROUNDUP (dstva, PGSIZE) != dstva)
f010392c:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
	//   parameters for correctness.  
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	if (srcva >= (void *)UTOP || ROUNDUP (srcva, PGSIZE) != srcva
f0103932:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103938:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010393b:	0f 85 a9 00 00 00    	jne    f01039ea <syscall+0x39a>
 	|| dstva >= (void *)UTOP || ROUNDUP (dstva, PGSIZE) != dstva)
 		return -E_INVAL;

	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f0103941:	89 c2                	mov    %eax,%edx
f0103943:	83 e2 05             	and    $0x5,%edx
f0103946:	83 fa 05             	cmp    $0x5,%edx
f0103949:	0f 85 9b 00 00 00    	jne    f01039ea <syscall+0x39a>

			 case SYS_page_alloc:
				  return sys_page_alloc((envid_t) a1,(void*) a2,(int) a3);

			 case SYS_page_map:
				  return sys_page_map((envid_t) a1,(void*) a2,(envid_t) a3,(void*) a4,(int) a5);
f010394f:	89 c7                	mov    %eax,%edi
 		return -E_INVAL;

	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
 		return -E_INVAL;
 	// PTE_USER = PTE_U | PTE_P | PTE_W | PTE_AVAIL
 	if ((perm & ~PTE_USER) > 0)
f0103951:	a9 f8 f1 ff ff       	test   $0xfffff1f8,%eax
f0103956:	0f 8f 8e 00 00 00    	jg     f01039ea <syscall+0x39a>
 		return -E_INVAL;

 	struct Env *srcenv;
	if (envid2env (srcenvid, &srcenv, 1) < 0)
f010395c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103963:	00 
f0103964:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103967:	89 44 24 04          	mov    %eax,0x4(%esp)
f010396b:	89 34 24             	mov    %esi,(%esp)
f010396e:	e8 cd e7 ff ff       	call   f0102140 <envid2env>
f0103973:	85 c0                	test   %eax,%eax
f0103975:	78 7d                	js     f01039f4 <syscall+0x3a4>
		return -E_BAD_ENV;

 	struct Env *dstenv;
 	if (envid2env (dstenvid, &dstenv, 1) < 0)
f0103977:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010397e:	00 
f010397f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0103982:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103986:	8b 45 14             	mov    0x14(%ebp),%eax
f0103989:	89 04 24             	mov    %eax,(%esp)
f010398c:	e8 af e7 ff ff       	call   f0102140 <envid2env>
f0103991:	85 c0                	test   %eax,%eax
f0103993:	78 5f                	js     f01039f4 <syscall+0x3a4>
 		return -E_BAD_ENV;

	 pte_t *pte;
	 struct Page *p = page_lookup (srcenv->env_pgdir, srcva, &pte);
f0103995:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103998:	89 44 24 08          	mov    %eax,0x8(%esp)
f010399c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01039a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039a3:	8b 40 5c             	mov    0x5c(%eax),%eax
f01039a6:	89 04 24             	mov    %eax,(%esp)
f01039a9:	e8 98 d6 ff ff       	call   f0101046 <page_lookup>
	 if (p == NULL || ((perm & PTE_W) > 0 && (*pte & PTE_W) == 0))
f01039ae:	85 c0                	test   %eax,%eax
f01039b0:	74 38                	je     f01039ea <syscall+0x39a>
f01039b2:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01039b8:	74 08                	je     f01039c2 <syscall+0x372>
f01039ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01039bd:	f6 02 02             	testb  $0x2,(%edx)
f01039c0:	74 28                	je     f01039ea <syscall+0x39a>
	 	return -E_INVAL;

	 if (page_insert (dstenv->env_pgdir, p, dstva, perm) < 0)
f01039c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01039c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039c9:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01039d4:	8b 40 5c             	mov    0x5c(%eax),%eax
f01039d7:	89 04 24             	mov    %eax,(%esp)
f01039da:	e8 32 d7 ff ff       	call   f0101111 <page_insert>
f01039df:	c1 f8 1f             	sar    $0x1f,%eax
f01039e2:	83 e0 fc             	and    $0xfffffffc,%eax
f01039e5:	e9 94 02 00 00       	jmp    f0103c7e <syscall+0x62e>
f01039ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01039ef:	e9 8a 02 00 00       	jmp    f0103c7e <syscall+0x62e>
f01039f4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax

			 case SYS_page_alloc:
				  return sys_page_alloc((envid_t) a1,(void*) a2,(int) a3);

			 case SYS_page_map:
				  return sys_page_map((envid_t) a1,(void*) a2,(envid_t) a3,(void*) a4,(int) a5);
f01039f9:	e9 80 02 00 00       	jmp    f0103c7e <syscall+0x62e>
{
	// Hint: This function is a wrapper around page_remove().
	
	// LAB 4: Your code here.
	 struct Env *e;  
         if (envid2env(envid, &e, 1) <0)  
f01039fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a05:	00 
f0103a06:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103a09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a0d:	89 34 24             	mov    %esi,(%esp)
f0103a10:	e8 2b e7 ff ff       	call   f0102140 <envid2env>
f0103a15:	89 c2                	mov    %eax,%edx
f0103a17:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a1c:	85 d2                	test   %edx,%edx
f0103a1e:	0f 88 5a 02 00 00    	js     f0103c7e <syscall+0x62e>
             return -E_BAD_ENV;  
         if ((uint32_t)va >= UTOP || PGOFF(va) != 0)  
f0103a24:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0103a2a:	77 24                	ja     f0103a50 <syscall+0x400>
f0103a2c:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0103a32:	75 1c                	jne    f0103a50 <syscall+0x400>
             return -E_INVAL;  
         page_remove(e->env_pgdir, va);  
f0103a34:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103a38:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a3b:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103a3e:	89 04 24             	mov    %eax,(%esp)
f0103a41:	e8 70 d6 ff ff       	call   f01010b6 <page_remove>
f0103a46:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a4b:	e9 2e 02 00 00       	jmp    f0103c7e <syscall+0x62e>
f0103a50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

			 case SYS_page_map:
				  return sys_page_map((envid_t) a1,(void*) a2,(envid_t) a3,(void*) a4,(int) a5);

			 case SYS_page_unmap:
				  return sys_page_unmap((envid_t) a1,(void*) a2);
f0103a55:	e9 24 02 00 00       	jmp    f0103c7e <syscall+0x62e>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	if (envid2env (envid, &e, 1) < 0)
f0103a5a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a61:	00 
f0103a62:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103a65:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a69:	89 34 24             	mov    %esi,(%esp)
f0103a6c:	e8 cf e6 ff ff       	call   f0102140 <envid2env>
f0103a71:	89 c2                	mov    %eax,%edx
f0103a73:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a78:	85 d2                	test   %edx,%edx
f0103a7a:	0f 88 fe 01 00 00    	js     f0103c7e <syscall+0x62e>
	    return -E_BAD_ENV;
	e->env_pgfault_upcall = func;
f0103a80:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a83:	89 78 64             	mov    %edi,0x64(%eax)
f0103a86:	b8 00 00 00 00       	mov    $0x0,%eax
			 case SYS_page_unmap:
				  return sys_page_unmap((envid_t) a1,(void*) a2);

			 
			 case SYS_env_set_pgfault_upcall:
				  return sys_env_set_pgfault_upcall((envid_t) a1,(void*) a2);
f0103a8b:	e9 ee 01 00 00       	jmp    f0103c7e <syscall+0x62e>

	//cprintf("sys_ipc_try_send is called\n");		
        struct Env *dstenv;
	int r;
	// target env does not exist
	if ((r = envid2env (envid, &dstenv, 0)) < 0)
f0103a90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103a97:	00 
f0103a98:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a9f:	89 34 24             	mov    %esi,(%esp)
f0103aa2:	e8 99 e6 ff ff       	call   f0102140 <envid2env>
f0103aa7:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f0103aac:	85 c0                	test   %eax,%eax
f0103aae:	0f 88 7b 01 00 00    	js     f0103c2f <syscall+0x5df>
		return -E_BAD_ENV;
	//cprintf("the target env exists\n");			//for debug
	// target env is not blocked or message has been sent

	//change by me
	if (dstenv->env_ipc_recving == 0||dstenv->env_ipc_from != 0 )
f0103ab4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ab7:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f0103abb:	0f 84 54 01 00 00    	je     f0103c15 <syscall+0x5c5>
f0103ac1:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f0103ac5:	0f 85 4a 01 00 00    	jne    f0103c15 <syscall+0x5c5>
			 default:
				  return -E_INVAL;

	   
			 case SYS_ipc_try_send:
				  return sys_ipc_try_send((envid_t) a1, a2, (void *)a3, (unsigned)a4);
f0103acb:	8b 45 14             	mov    0x14(%ebp),%eax
	//change by me
	if (dstenv->env_ipc_recving == 0||dstenv->env_ipc_from != 0 )
		return -E_IPC_NOT_RECV;
	//cprintf("the target env is willing to receive message\n");	//for debug
	// srcva < UTOP but not page aligned
	if (srcva < (void *) UTOP && ROUNDDOWN (srcva, PGSIZE) != srcva)
f0103ace:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0103ad3:	0f 87 9c 00 00 00    	ja     f0103b75 <syscall+0x525>
f0103ad9:	89 c2                	mov    %eax,%edx
f0103adb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103ae1:	39 d0                	cmp    %edx,%eax
f0103ae3:	0f 85 33 01 00 00    	jne    f0103c1c <syscall+0x5cc>
		return -E_INVAL;
	if (srcva < (void *) UTOP) {
		// check permission
		if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f0103ae9:	8b 55 18             	mov    0x18(%ebp),%edx
f0103aec:	83 e2 05             	and    $0x5,%edx
f0103aef:	83 fa 05             	cmp    $0x5,%edx
f0103af2:	0f 85 24 01 00 00    	jne    f0103c1c <syscall+0x5cc>
			return -E_INVAL;
		// PTE_USER = PTE_U | PTE_P | PTE_W | PTE_AVAIL
		if ((perm & ~PTE_USER) > 0)
f0103af8:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0103aff:	0f 85 17 01 00 00    	jne    f0103c1c <syscall+0x5cc>
	}
	//cprintf("the current env can send a message\n");	//for debug
	pte_t *pte;
	struct Page *p;
	// the page is not mapped in current env
	if (srcva < (void *) UTOP && (p = page_lookup (curenv->env_pgdir, srcva, &pte)) == NULL)
f0103b05:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103b08:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b10:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103b15:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103b18:	89 04 24             	mov    %eax,(%esp)
f0103b1b:	e8 26 d5 ff ff       	call   f0101046 <page_lookup>
f0103b20:	85 c0                	test   %eax,%eax
f0103b22:	0f 85 63 01 00 00    	jne    f0103c8b <syscall+0x63b>
f0103b28:	e9 ef 00 00 00       	jmp    f0103c1c <syscall+0x5cc>
		return -E_INVAL;
	if (srcva < (void *) UTOP && (*pte & PTE_W) == 0 && (perm & PTE_W) > 0)
f0103b2d:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0103b31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103b38:	0f 85 de 00 00 00    	jne    f0103c1c <syscall+0x5cc>
		return -E_INVAL;
	// will send a page
	if (srcva < (void *) UTOP && dstenv->env_ipc_dstva != 0) 
f0103b3e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b41:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0103b44:	85 c9                	test   %ecx,%ecx
f0103b46:	74 2d                	je     f0103b75 <syscall+0x525>
	{
		if (page_insert (dstenv->env_pgdir, p, dstenv->env_ipc_dstva, perm) < 0)
f0103b48:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0103b4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103b4f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103b53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b57:	8b 42 5c             	mov    0x5c(%edx),%eax
f0103b5a:	89 04 24             	mov    %eax,(%esp)
f0103b5d:	e8 af d5 ff ff       	call   f0101111 <page_insert>
f0103b62:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0103b67:	85 c0                	test   %eax,%eax
f0103b69:	0f 88 c0 00 00 00    	js     f0103c2f <syscall+0x5df>
			return -E_NO_MEM;
		dstenv->env_ipc_perm = perm;
f0103b6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b72:	89 58 78             	mov    %ebx,0x78(%eax)
	}
	dstenv->env_ipc_from = curenv->env_id;
f0103b75:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103b7a:	8b 50 4c             	mov    0x4c(%eax),%edx
f0103b7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b80:	89 50 74             	mov    %edx,0x74(%eax)
	dstenv->env_ipc_value = value;
f0103b83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b86:	89 78 70             	mov    %edi,0x70(%eax)
	dstenv->env_status = ENV_RUNNABLE;
f0103b89:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b8c:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
	dstenv->env_ipc_recving = 0;
f0103b93:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b96:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0103b9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ba0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)


	curenv->env_ipc_send_to=-1;
f0103ba7:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103bac:	c7 80 80 00 00 00 ff 	movl   $0xffffffff,0x80(%eax)
f0103bb3:	ff ff ff 
	curenv->env_ipc_send_succ++;
f0103bb6:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103bbb:	83 40 7c 01          	addl   $0x1,0x7c(%eax)
	dstenv->env_ipc_recv_min_send_succ=0xffffffff;
f0103bbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bc2:	c7 80 84 00 00 00 ff 	movl   $0xffffffff,0x84(%eax)
f0103bc9:	ff ff ff 
	struct 	Env *envptr;
	for(envptr=envs+1;envptr<envs+NENV;envptr++)
f0103bcc:	8b 15 20 af 1a f0    	mov    0xf01aaf20,%edx
f0103bd2:	8d 82 88 00 00 00    	lea    0x88(%edx),%eax
f0103bd8:	81 c2 00 20 02 00    	add    $0x22000,%edx
f0103bde:	39 d0                	cmp    %edx,%eax
f0103be0:	73 48                	jae    f0103c2a <syscall+0x5da>
		if(envptr->env_ipc_send_to==envid)
f0103be2:	3b b0 80 00 00 00    	cmp    0x80(%eax),%esi
f0103be8:	75 14                	jne    f0103bfe <syscall+0x5ae>
			if(envptr->env_ipc_send_succ<dstenv->env_ipc_recv_min_send_succ)
f0103bea:	8b 48 7c             	mov    0x7c(%eax),%ecx
f0103bed:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103bf0:	3b 8a 84 00 00 00    	cmp    0x84(%edx),%ecx
f0103bf6:	73 06                	jae    f0103bfe <syscall+0x5ae>
			dstenv->env_ipc_recv_min_send_succ=envptr->env_ipc_send_succ;
f0103bf8:	89 8a 84 00 00 00    	mov    %ecx,0x84(%edx)

	curenv->env_ipc_send_to=-1;
	curenv->env_ipc_send_succ++;
	dstenv->env_ipc_recv_min_send_succ=0xffffffff;
	struct 	Env *envptr;
	for(envptr=envs+1;envptr<envs+NENV;envptr++)
f0103bfe:	05 88 00 00 00       	add    $0x88,%eax
f0103c03:	8b 15 20 af 1a f0    	mov    0xf01aaf20,%edx
f0103c09:	81 c2 00 20 02 00    	add    $0x22000,%edx
f0103c0f:	39 d0                	cmp    %edx,%eax
f0103c11:	72 cf                	jb     f0103be2 <syscall+0x592>
f0103c13:	eb 15                	jmp    f0103c2a <syscall+0x5da>
f0103c15:	ba f9 ff ff ff       	mov    $0xfffffff9,%edx
f0103c1a:	eb 13                	jmp    f0103c2f <syscall+0x5df>
f0103c1c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0103c21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103c28:	eb 05                	jmp    f0103c2f <syscall+0x5df>
f0103c2a:	ba 00 00 00 00       	mov    $0x0,%edx
			 default:
				  return -E_INVAL;

	   
			 case SYS_ipc_try_send:
				  return sys_ipc_try_send((envid_t) a1, a2, (void *)a3, (unsigned)a4);
f0103c2f:	89 d0                	mov    %edx,%eax
f0103c31:	eb 4b                	jmp    f0103c7e <syscall+0x62e>
			 case SYS_ipc_recv:
				  return sys_ipc_recv((void *)a1);
f0103c33:	89 f0                	mov    %esi,%eax
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");

	 if (dstva < (void *) UTOP && ROUNDDOWN (dstva, PGSIZE) != dstva)
f0103c35:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0103c3b:	77 0a                	ja     f0103c47 <syscall+0x5f7>
f0103c3d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0103c43:	39 f0                	cmp    %esi,%eax
f0103c45:	75 32                	jne    f0103c79 <syscall+0x629>
                  return -E_INVAL;

        curenv->env_ipc_dstva = dstva;
f0103c47:	8b 15 24 af 1a f0    	mov    0xf01aaf24,%edx
f0103c4d:	89 42 6c             	mov    %eax,0x6c(%edx)
	curenv->env_ipc_recving = 1;
f0103c50:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103c55:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0103c5c:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103c61:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0103c68:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103c6d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	sched_yield ();
f0103c74:	e8 27 f9 ff ff       	call   f01035a0 <sched_yield>
f0103c79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			 case SYS_ipc_recv:
				  return sys_ipc_recv((void *)a1);
		}

	//panic("syscall not implemented");
}
f0103c7e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103c81:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103c84:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103c87:	89 ec                	mov    %ebp,%esp
f0103c89:	5d                   	pop    %ebp
f0103c8a:	c3                   	ret    
	pte_t *pte;
	struct Page *p;
	// the page is not mapped in current env
	if (srcva < (void *) UTOP && (p = page_lookup (curenv->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
	if (srcva < (void *) UTOP && (*pte & PTE_W) == 0 && (perm & PTE_W) > 0)
f0103c8b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103c8e:	f6 02 02             	testb  $0x2,(%edx)
f0103c91:	0f 85 a7 fe ff ff    	jne    f0103b3e <syscall+0x4ee>
f0103c97:	e9 91 fe ff ff       	jmp    f0103b2d <syscall+0x4dd>
f0103c9c:	00 00                	add    %al,(%eax)
	...

f0103ca0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103ca0:	55                   	push   %ebp
f0103ca1:	89 e5                	mov    %esp,%ebp
f0103ca3:	57                   	push   %edi
f0103ca4:	56                   	push   %esi
f0103ca5:	53                   	push   %ebx
f0103ca6:	83 ec 14             	sub    $0x14,%esp
f0103ca9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103cac:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103caf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103cb2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103cb5:	8b 1a                	mov    (%edx),%ebx
f0103cb7:	8b 01                	mov    (%ecx),%eax
f0103cb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0103cbc:	39 c3                	cmp    %eax,%ebx
f0103cbe:	0f 8f 9c 00 00 00    	jg     f0103d60 <stab_binsearch+0xc0>
f0103cc4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0103ccb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103cce:	01 d8                	add    %ebx,%eax
f0103cd0:	89 c7                	mov    %eax,%edi
f0103cd2:	c1 ef 1f             	shr    $0x1f,%edi
f0103cd5:	01 c7                	add    %eax,%edi
f0103cd7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103cd9:	39 df                	cmp    %ebx,%edi
f0103cdb:	7c 33                	jl     f0103d10 <stab_binsearch+0x70>
f0103cdd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103ce0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103ce3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103ce8:	39 f0                	cmp    %esi,%eax
f0103cea:	0f 84 bc 00 00 00    	je     f0103dac <stab_binsearch+0x10c>
f0103cf0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0103cf4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0103cf8:	89 f8                	mov    %edi,%eax
			m--;
f0103cfa:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103cfd:	39 d8                	cmp    %ebx,%eax
f0103cff:	7c 0f                	jl     f0103d10 <stab_binsearch+0x70>
f0103d01:	0f b6 0a             	movzbl (%edx),%ecx
f0103d04:	83 ea 0c             	sub    $0xc,%edx
f0103d07:	39 f1                	cmp    %esi,%ecx
f0103d09:	75 ef                	jne    f0103cfa <stab_binsearch+0x5a>
f0103d0b:	e9 9e 00 00 00       	jmp    f0103dae <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103d10:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103d13:	eb 3c                	jmp    f0103d51 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103d15:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103d18:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103d1a:	8d 5f 01             	lea    0x1(%edi),%ebx
f0103d1d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103d24:	eb 2b                	jmp    f0103d51 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0103d26:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103d29:	76 14                	jbe    f0103d3f <stab_binsearch+0x9f>
			*region_right = m - 1;
f0103d2b:	83 e8 01             	sub    $0x1,%eax
f0103d2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103d31:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103d34:	89 02                	mov    %eax,(%edx)
f0103d36:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103d3d:	eb 12                	jmp    f0103d51 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103d3f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103d42:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103d44:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103d48:	89 c3                	mov    %eax,%ebx
f0103d4a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103d51:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103d54:	0f 8d 71 ff ff ff    	jge    f0103ccb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103d5a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d5e:	75 0f                	jne    f0103d6f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103d60:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103d63:	8b 03                	mov    (%ebx),%eax
f0103d65:	83 e8 01             	sub    $0x1,%eax
f0103d68:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103d6b:	89 02                	mov    %eax,(%edx)
f0103d6d:	eb 57                	jmp    f0103dc6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d6f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103d72:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103d74:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103d77:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d79:	39 c1                	cmp    %eax,%ecx
f0103d7b:	7d 28                	jge    f0103da5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103d7d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103d80:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103d83:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103d88:	39 f2                	cmp    %esi,%edx
f0103d8a:	74 19                	je     f0103da5 <stab_binsearch+0x105>
f0103d8c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0103d90:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0103d94:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d97:	39 c1                	cmp    %eax,%ecx
f0103d99:	7d 0a                	jge    f0103da5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103d9b:	0f b6 1a             	movzbl (%edx),%ebx
f0103d9e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103da1:	39 f3                	cmp    %esi,%ebx
f0103da3:	75 ef                	jne    f0103d94 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0103da5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103da8:	89 02                	mov    %eax,(%edx)
f0103daa:	eb 1a                	jmp    f0103dc6 <stab_binsearch+0x126>
	}
}
f0103dac:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103dae:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103db1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103db4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103db8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103dbb:	0f 82 54 ff ff ff    	jb     f0103d15 <stab_binsearch+0x75>
f0103dc1:	e9 60 ff ff ff       	jmp    f0103d26 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103dc6:	83 c4 14             	add    $0x14,%esp
f0103dc9:	5b                   	pop    %ebx
f0103dca:	5e                   	pop    %esi
f0103dcb:	5f                   	pop    %edi
f0103dcc:	5d                   	pop    %ebp
f0103dcd:	c3                   	ret    

f0103dce <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103dce:	55                   	push   %ebp
f0103dcf:	89 e5                	mov    %esp,%ebp
f0103dd1:	83 ec 58             	sub    $0x58,%esp
f0103dd4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103dd7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103dda:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103ddd:	8b 75 08             	mov    0x8(%ebp),%esi
f0103de0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103de3:	c7 03 74 5d 10 f0    	movl   $0xf0105d74,(%ebx)
	info->eip_line = 0;
f0103de9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103df0:	c7 43 08 74 5d 10 f0 	movl   $0xf0105d74,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103df7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103dfe:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103e01:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103e08:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103e0e:	76 1c                	jbe    f0103e2c <debuginfo_eip+0x5e>
f0103e10:	bf f3 06 11 f0       	mov    $0xf01106f3,%edi
f0103e15:	c7 45 c4 0d d9 10 f0 	movl   $0xf010d90d,-0x3c(%ebp)
f0103e1c:	c7 45 bc 0c d9 10 f0 	movl   $0xf010d90c,-0x44(%ebp)
f0103e23:	c7 45 c0 d4 5f 10 f0 	movl   $0xf0105fd4,-0x40(%ebp)
f0103e2a:	eb 7c                	jmp    f0103ea8 <debuginfo_eip+0xda>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f0103e2c:	b8 00 00 20 00       	mov    $0x200000,%eax
f0103e31:	8b 10                	mov    (%eax),%edx
f0103e33:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stab_end = usd->stab_end;
f0103e36:	8b 48 04             	mov    0x4(%eax),%ecx
f0103e39:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr = usd->stabstr;
f0103e3c:	8b 50 08             	mov    0x8(%eax),%edx
f0103e3f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103e42:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
   			|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0103e45:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103e4c:	00 
f0103e4d:	89 c8                	mov    %ecx,%eax
f0103e4f:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0103e52:	c1 f8 02             	sar    $0x2,%eax
f0103e55:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103e5b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e5f:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103e62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103e66:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103e6b:	89 04 24             	mov    %eax,(%esp)
f0103e6e:	e8 4f d0 ff ff       	call   f0100ec2 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
f0103e73:	85 c0                	test   %eax,%eax
f0103e75:	0f 88 9b 01 00 00    	js     f0104016 <debuginfo_eip+0x248>
   			|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0103e7b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103e82:	00 
f0103e83:	89 f8                	mov    %edi,%eax
f0103e85:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f0103e88:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e8c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e93:	a1 24 af 1a f0       	mov    0xf01aaf24,%eax
f0103e98:	89 04 24             	mov    %eax,(%esp)
f0103e9b:	e8 22 d0 ff ff       	call   f0100ec2 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
f0103ea0:	85 c0                	test   %eax,%eax
f0103ea2:	0f 88 6e 01 00 00    	js     f0104016 <debuginfo_eip+0x248>
   			|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
		    return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103ea8:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0103eab:	0f 83 65 01 00 00    	jae    f0104016 <debuginfo_eip+0x248>
f0103eb1:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103eb5:	0f 85 5b 01 00 00    	jne    f0104016 <debuginfo_eip+0x248>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103ebb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103ec2:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103ec5:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0103ec8:	c1 f8 02             	sar    $0x2,%eax
f0103ecb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103ed1:	83 e8 01             	sub    $0x1,%eax
f0103ed4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103ed7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103eda:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103edd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103ee1:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103ee8:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103eeb:	e8 b0 fd ff ff       	call   f0103ca0 <stab_binsearch>
	if (lfile == 0)
f0103ef0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ef3:	85 c0                	test   %eax,%eax
f0103ef5:	0f 84 1b 01 00 00    	je     f0104016 <debuginfo_eip+0x248>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103efb:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103efe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f01:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103f04:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103f07:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103f0a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f0e:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103f15:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103f18:	e8 83 fd ff ff       	call   f0103ca0 <stab_binsearch>

	if (lfun <= rfun) {
f0103f1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103f20:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103f23:	7f 35                	jg     f0103f5a <debuginfo_eip+0x18c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103f25:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103f28:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103f2b:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103f2e:	89 fa                	mov    %edi,%edx
f0103f30:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0103f33:	39 d0                	cmp    %edx,%eax
f0103f35:	73 06                	jae    f0103f3d <debuginfo_eip+0x16f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103f37:	03 45 c4             	add    -0x3c(%ebp),%eax
f0103f3a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f40:	6b c2 0c             	imul   $0xc,%edx,%eax
f0103f43:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103f46:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f0103f4a:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103f4d:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103f4f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0103f52:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103f55:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103f58:	eb 0f                	jmp    f0103f69 <debuginfo_eip+0x19b>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103f5a:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103f5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103f60:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103f63:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f66:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103f69:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103f70:	00 
f0103f71:	8b 43 08             	mov    0x8(%ebx),%eax
f0103f74:	89 04 24             	mov    %eax,(%esp)
f0103f77:	e8 2f 09 00 00       	call   f01048ab <strfind>
f0103f7c:	2b 43 08             	sub    0x8(%ebx),%eax
f0103f7f:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103f82:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103f85:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103f88:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f8c:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103f93:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103f96:	e8 05 fd ff ff       	call   f0103ca0 <stab_binsearch>
        if(lline <= rline)
f0103f9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103f9e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103fa1:	7f 73                	jg     f0104016 <debuginfo_eip+0x248>
              info->eip_line = stabs[lline].n_desc;
f0103fa3:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103fa6:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103fa9:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f0103fae:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0103fb1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103fb4:	eb 06                	jmp    f0103fbc <debuginfo_eip+0x1ee>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103fb6:	83 ea 01             	sub    $0x1,%edx
f0103fb9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0103fbc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103fbf:	39 f2                	cmp    %esi,%edx
f0103fc1:	7c 24                	jl     f0103fe7 <debuginfo_eip+0x219>
	       && stabs[lline].n_type != N_SOL
f0103fc3:	6b c2 0c             	imul   $0xc,%edx,%eax
f0103fc6:	03 45 c0             	add    -0x40(%ebp),%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103fc9:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103fcd:	80 f9 84             	cmp    $0x84,%cl
f0103fd0:	74 5d                	je     f010402f <debuginfo_eip+0x261>
f0103fd2:	80 f9 64             	cmp    $0x64,%cl
f0103fd5:	75 df                	jne    f0103fb6 <debuginfo_eip+0x1e8>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103fd7:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103fdb:	74 d9                	je     f0103fb6 <debuginfo_eip+0x1e8>
f0103fdd:	8d 76 00             	lea    0x0(%esi),%esi
f0103fe0:	eb 4d                	jmp    f010402f <debuginfo_eip+0x261>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103fe2:	03 45 c4             	add    -0x3c(%ebp),%eax
f0103fe5:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	if (lfun < rfun)
f0103fe7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103fea:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103fed:	7d 2e                	jge    f010401d <debuginfo_eip+0x24f>
           for (lline = lfun + 1;lline < rfun && stabs[lline].n_type == N_PSYM;lline++)
f0103fef:	83 c0 01             	add    $0x1,%eax
f0103ff2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103ff5:	eb 08                	jmp    f0103fff <debuginfo_eip+0x231>
             info->eip_fn_narg++;
f0103ff7:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	if (lfun < rfun)
           for (lline = lfun + 1;lline < rfun && stabs[lline].n_type == N_PSYM;lline++)
f0103ffb:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f0103fff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104002:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104005:	7d 16                	jge    f010401d <debuginfo_eip+0x24f>
f0104007:	6b c0 0c             	imul   $0xc,%eax,%eax
f010400a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010400d:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f0104012:	74 e3                	je     f0103ff7 <debuginfo_eip+0x229>
f0104014:	eb 07                	jmp    f010401d <debuginfo_eip+0x24f>
f0104016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010401b:	eb 05                	jmp    f0104022 <debuginfo_eip+0x254>
f010401d:	b8 00 00 00 00       	mov    $0x0,%eax
             info->eip_fn_narg++;
	
	return 0;
}
f0104022:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104025:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104028:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010402b:	89 ec                	mov    %ebp,%esp
f010402d:	5d                   	pop    %ebp
f010402e:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010402f:	8b 00                	mov    (%eax),%eax
f0104031:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0104034:	39 f8                	cmp    %edi,%eax
f0104036:	72 aa                	jb     f0103fe2 <debuginfo_eip+0x214>
f0104038:	eb ad                	jmp    f0103fe7 <debuginfo_eip+0x219>
f010403a:	00 00                	add    %al,(%eax)
f010403c:	00 00                	add    %al,(%eax)
	...

f0104040 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104040:	55                   	push   %ebp
f0104041:	89 e5                	mov    %esp,%ebp
f0104043:	57                   	push   %edi
f0104044:	56                   	push   %esi
f0104045:	53                   	push   %ebx
f0104046:	83 ec 4c             	sub    $0x4c,%esp
f0104049:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010404c:	89 d6                	mov    %edx,%esi
f010404e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104051:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104054:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104057:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010405a:	8b 45 10             	mov    0x10(%ebp),%eax
f010405d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104060:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104063:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104066:	b9 00 00 00 00       	mov    $0x0,%ecx
f010406b:	39 d1                	cmp    %edx,%ecx
f010406d:	72 15                	jb     f0104084 <printnum+0x44>
f010406f:	77 07                	ja     f0104078 <printnum+0x38>
f0104071:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104074:	39 d0                	cmp    %edx,%eax
f0104076:	76 0c                	jbe    f0104084 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104078:	83 eb 01             	sub    $0x1,%ebx
f010407b:	85 db                	test   %ebx,%ebx
f010407d:	8d 76 00             	lea    0x0(%esi),%esi
f0104080:	7f 61                	jg     f01040e3 <printnum+0xa3>
f0104082:	eb 70                	jmp    f01040f4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104084:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0104088:	83 eb 01             	sub    $0x1,%ebx
f010408b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010408f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104093:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104097:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010409b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010409e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01040a1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01040a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01040a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01040af:	00 
f01040b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01040b3:	89 04 24             	mov    %eax,(%esp)
f01040b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01040b9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01040bd:	e8 2e 0a 00 00       	call   f0104af0 <__udivdi3>
f01040c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01040c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01040c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01040cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01040d0:	89 04 24             	mov    %eax,(%esp)
f01040d3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01040d7:	89 f2                	mov    %esi,%edx
f01040d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01040dc:	e8 5f ff ff ff       	call   f0104040 <printnum>
f01040e1:	eb 11                	jmp    f01040f4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01040e3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040e7:	89 3c 24             	mov    %edi,(%esp)
f01040ea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01040ed:	83 eb 01             	sub    $0x1,%ebx
f01040f0:	85 db                	test   %ebx,%ebx
f01040f2:	7f ef                	jg     f01040e3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01040f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040f8:	8b 74 24 04          	mov    0x4(%esp),%esi
f01040fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01040ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104103:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010410a:	00 
f010410b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010410e:	89 14 24             	mov    %edx,(%esp)
f0104111:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104114:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104118:	e8 03 0b 00 00       	call   f0104c20 <__umoddi3>
f010411d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104121:	0f be 80 7e 5d 10 f0 	movsbl -0xfefa282(%eax),%eax
f0104128:	89 04 24             	mov    %eax,(%esp)
f010412b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010412e:	83 c4 4c             	add    $0x4c,%esp
f0104131:	5b                   	pop    %ebx
f0104132:	5e                   	pop    %esi
f0104133:	5f                   	pop    %edi
f0104134:	5d                   	pop    %ebp
f0104135:	c3                   	ret    

f0104136 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104136:	55                   	push   %ebp
f0104137:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104139:	83 fa 01             	cmp    $0x1,%edx
f010413c:	7e 0f                	jle    f010414d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f010413e:	8b 10                	mov    (%eax),%edx
f0104140:	83 c2 08             	add    $0x8,%edx
f0104143:	89 10                	mov    %edx,(%eax)
f0104145:	8b 42 f8             	mov    -0x8(%edx),%eax
f0104148:	8b 52 fc             	mov    -0x4(%edx),%edx
f010414b:	eb 24                	jmp    f0104171 <getuint+0x3b>
	else if (lflag)
f010414d:	85 d2                	test   %edx,%edx
f010414f:	74 11                	je     f0104162 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0104151:	8b 10                	mov    (%eax),%edx
f0104153:	83 c2 04             	add    $0x4,%edx
f0104156:	89 10                	mov    %edx,(%eax)
f0104158:	8b 42 fc             	mov    -0x4(%edx),%eax
f010415b:	ba 00 00 00 00       	mov    $0x0,%edx
f0104160:	eb 0f                	jmp    f0104171 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0104162:	8b 10                	mov    (%eax),%edx
f0104164:	83 c2 04             	add    $0x4,%edx
f0104167:	89 10                	mov    %edx,(%eax)
f0104169:	8b 42 fc             	mov    -0x4(%edx),%eax
f010416c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104171:	5d                   	pop    %ebp
f0104172:	c3                   	ret    

f0104173 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104173:	55                   	push   %ebp
f0104174:	89 e5                	mov    %esp,%ebp
f0104176:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104179:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010417d:	8b 10                	mov    (%eax),%edx
f010417f:	3b 50 04             	cmp    0x4(%eax),%edx
f0104182:	73 0a                	jae    f010418e <sprintputch+0x1b>
		*b->buf++ = ch;
f0104184:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104187:	88 0a                	mov    %cl,(%edx)
f0104189:	83 c2 01             	add    $0x1,%edx
f010418c:	89 10                	mov    %edx,(%eax)
}
f010418e:	5d                   	pop    %ebp
f010418f:	c3                   	ret    

f0104190 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104190:	55                   	push   %ebp
f0104191:	89 e5                	mov    %esp,%ebp
f0104193:	57                   	push   %edi
f0104194:	56                   	push   %esi
f0104195:	53                   	push   %ebx
f0104196:	83 ec 5c             	sub    $0x5c,%esp
f0104199:	8b 7d 08             	mov    0x8(%ebp),%edi
f010419c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010419f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01041a2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01041a9:	eb 11                	jmp    f01041bc <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01041ab:	85 c0                	test   %eax,%eax
f01041ad:	0f 84 fd 03 00 00    	je     f01045b0 <vprintfmt+0x420>
				return;
			putch(ch, putdat);
f01041b3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01041b7:	89 04 24             	mov    %eax,(%esp)
f01041ba:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01041bc:	0f b6 03             	movzbl (%ebx),%eax
f01041bf:	83 c3 01             	add    $0x1,%ebx
f01041c2:	83 f8 25             	cmp    $0x25,%eax
f01041c5:	75 e4                	jne    f01041ab <vprintfmt+0x1b>
f01041c7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01041cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01041d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01041d9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01041e0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01041e5:	eb 06                	jmp    f01041ed <vprintfmt+0x5d>
f01041e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01041eb:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041ed:	0f b6 13             	movzbl (%ebx),%edx
f01041f0:	0f b6 c2             	movzbl %dl,%eax
f01041f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01041f6:	8d 43 01             	lea    0x1(%ebx),%eax
f01041f9:	83 ea 23             	sub    $0x23,%edx
f01041fc:	80 fa 55             	cmp    $0x55,%dl
f01041ff:	0f 87 8e 03 00 00    	ja     f0104593 <vprintfmt+0x403>
f0104205:	0f b6 d2             	movzbl %dl,%edx
f0104208:	ff 24 95 40 5e 10 f0 	jmp    *-0xfefa1c0(,%edx,4)
f010420f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104213:	eb d6                	jmp    f01041eb <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104215:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104218:	83 ea 30             	sub    $0x30,%edx
f010421b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
f010421e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0104221:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104224:	83 fb 09             	cmp    $0x9,%ebx
f0104227:	77 55                	ja     f010427e <vprintfmt+0xee>
f0104229:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010422c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010422f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0104232:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0104235:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0104239:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010423c:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010423f:	83 fb 09             	cmp    $0x9,%ebx
f0104242:	76 eb                	jbe    f010422f <vprintfmt+0x9f>
f0104244:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104247:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010424a:	eb 32                	jmp    f010427e <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010424c:	8b 55 14             	mov    0x14(%ebp),%edx
f010424f:	83 c2 04             	add    $0x4,%edx
f0104252:	89 55 14             	mov    %edx,0x14(%ebp)
f0104255:	8b 52 fc             	mov    -0x4(%edx),%edx
f0104258:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
f010425b:	eb 21                	jmp    f010427e <vprintfmt+0xee>

		case '.':
			if (width < 0)
f010425d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104261:	ba 00 00 00 00       	mov    $0x0,%edx
f0104266:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
f010426a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010426d:	e9 79 ff ff ff       	jmp    f01041eb <vprintfmt+0x5b>
f0104272:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0104279:	e9 6d ff ff ff       	jmp    f01041eb <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f010427e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104282:	0f 89 63 ff ff ff    	jns    f01041eb <vprintfmt+0x5b>
f0104288:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010428b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010428e:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104291:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104294:	e9 52 ff ff ff       	jmp    f01041eb <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104299:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f010429c:	e9 4a ff ff ff       	jmp    f01041eb <vprintfmt+0x5b>
f01042a1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01042a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01042a7:	83 c0 04             	add    $0x4,%eax
f01042aa:	89 45 14             	mov    %eax,0x14(%ebp)
f01042ad:	89 74 24 04          	mov    %esi,0x4(%esp)
f01042b1:	8b 40 fc             	mov    -0x4(%eax),%eax
f01042b4:	89 04 24             	mov    %eax,(%esp)
f01042b7:	ff d7                	call   *%edi
f01042b9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f01042bc:	e9 fb fe ff ff       	jmp    f01041bc <vprintfmt+0x2c>
f01042c1:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01042c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01042c7:	83 c0 04             	add    $0x4,%eax
f01042ca:	89 45 14             	mov    %eax,0x14(%ebp)
f01042cd:	8b 40 fc             	mov    -0x4(%eax),%eax
f01042d0:	89 c2                	mov    %eax,%edx
f01042d2:	c1 fa 1f             	sar    $0x1f,%edx
f01042d5:	31 d0                	xor    %edx,%eax
f01042d7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f01042d9:	83 f8 08             	cmp    $0x8,%eax
f01042dc:	7f 0b                	jg     f01042e9 <vprintfmt+0x159>
f01042de:	8b 14 85 a0 5f 10 f0 	mov    -0xfefa060(,%eax,4),%edx
f01042e5:	85 d2                	test   %edx,%edx
f01042e7:	75 20                	jne    f0104309 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
f01042e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042ed:	c7 44 24 08 8f 5d 10 	movl   $0xf0105d8f,0x8(%esp)
f01042f4:	f0 
f01042f5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01042f9:	89 3c 24             	mov    %edi,(%esp)
f01042fc:	e8 37 03 00 00       	call   f0104638 <printfmt>
f0104301:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0104304:	e9 b3 fe ff ff       	jmp    f01041bc <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0104309:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010430d:	c7 44 24 08 0b 57 10 	movl   $0xf010570b,0x8(%esp)
f0104314:	f0 
f0104315:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104319:	89 3c 24             	mov    %edi,(%esp)
f010431c:	e8 17 03 00 00       	call   f0104638 <printfmt>
f0104321:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104324:	e9 93 fe ff ff       	jmp    f01041bc <vprintfmt+0x2c>
f0104329:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010432c:	89 c3                	mov    %eax,%ebx
f010432e:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104331:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104334:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104337:	8b 45 14             	mov    0x14(%ebp),%eax
f010433a:	83 c0 04             	add    $0x4,%eax
f010433d:	89 45 14             	mov    %eax,0x14(%ebp)
f0104340:	8b 40 fc             	mov    -0x4(%eax),%eax
f0104343:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104346:	85 c0                	test   %eax,%eax
f0104348:	b8 98 5d 10 f0       	mov    $0xf0105d98,%eax
f010434d:	0f 45 45 e0          	cmovne -0x20(%ebp),%eax
f0104351:	89 45 e0             	mov    %eax,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0104354:	85 c9                	test   %ecx,%ecx
f0104356:	7e 06                	jle    f010435e <vprintfmt+0x1ce>
f0104358:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010435c:	75 13                	jne    f0104371 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010435e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104361:	0f be 02             	movsbl (%edx),%eax
f0104364:	85 c0                	test   %eax,%eax
f0104366:	0f 85 99 00 00 00    	jne    f0104405 <vprintfmt+0x275>
f010436c:	e9 86 00 00 00       	jmp    f01043f7 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104371:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104375:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104378:	89 0c 24             	mov    %ecx,(%esp)
f010437b:	e8 cb 03 00 00       	call   f010474b <strnlen>
f0104380:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104383:	29 c2                	sub    %eax,%edx
f0104385:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104388:	85 d2                	test   %edx,%edx
f010438a:	7e d2                	jle    f010435e <vprintfmt+0x1ce>
					putch(padc, putdat);
f010438c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0104390:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104393:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0104396:	89 d3                	mov    %edx,%ebx
f0104398:	89 74 24 04          	mov    %esi,0x4(%esp)
f010439c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010439f:	89 04 24             	mov    %eax,(%esp)
f01043a2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01043a4:	83 eb 01             	sub    $0x1,%ebx
f01043a7:	85 db                	test   %ebx,%ebx
f01043a9:	7f ed                	jg     f0104398 <vprintfmt+0x208>
f01043ab:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01043ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01043b5:	eb a7                	jmp    f010435e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01043b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01043bb:	74 18                	je     f01043d5 <vprintfmt+0x245>
f01043bd:	8d 50 e0             	lea    -0x20(%eax),%edx
f01043c0:	83 fa 5e             	cmp    $0x5e,%edx
f01043c3:	76 10                	jbe    f01043d5 <vprintfmt+0x245>
					putch('?', putdat);
f01043c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01043c9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01043d0:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01043d3:	eb 0a                	jmp    f01043df <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
f01043d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01043d9:	89 04 24             	mov    %eax,(%esp)
f01043dc:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01043df:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01043e3:	0f be 03             	movsbl (%ebx),%eax
f01043e6:	85 c0                	test   %eax,%eax
f01043e8:	74 05                	je     f01043ef <vprintfmt+0x25f>
f01043ea:	83 c3 01             	add    $0x1,%ebx
f01043ed:	eb 29                	jmp    f0104418 <vprintfmt+0x288>
f01043ef:	89 fe                	mov    %edi,%esi
f01043f1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01043f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01043f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01043fb:	7f 2e                	jg     f010442b <vprintfmt+0x29b>
f01043fd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104400:	e9 b7 fd ff ff       	jmp    f01041bc <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104405:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104408:	83 c2 01             	add    $0x1,%edx
f010440b:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010440e:	89 f7                	mov    %esi,%edi
f0104410:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104413:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0104416:	89 d3                	mov    %edx,%ebx
f0104418:	85 f6                	test   %esi,%esi
f010441a:	78 9b                	js     f01043b7 <vprintfmt+0x227>
f010441c:	83 ee 01             	sub    $0x1,%esi
f010441f:	79 96                	jns    f01043b7 <vprintfmt+0x227>
f0104421:	89 fe                	mov    %edi,%esi
f0104423:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104426:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104429:	eb cc                	jmp    f01043f7 <vprintfmt+0x267>
f010442b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010442e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104431:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104435:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010443c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010443e:	83 eb 01             	sub    $0x1,%ebx
f0104441:	85 db                	test   %ebx,%ebx
f0104443:	7f ec                	jg     f0104431 <vprintfmt+0x2a1>
f0104445:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0104448:	e9 6f fd ff ff       	jmp    f01041bc <vprintfmt+0x2c>
f010444d:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104450:	83 f9 01             	cmp    $0x1,%ecx
f0104453:	7e 17                	jle    f010446c <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
f0104455:	8b 45 14             	mov    0x14(%ebp),%eax
f0104458:	83 c0 08             	add    $0x8,%eax
f010445b:	89 45 14             	mov    %eax,0x14(%ebp)
f010445e:	8b 50 f8             	mov    -0x8(%eax),%edx
f0104461:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0104464:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0104467:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010446a:	eb 34                	jmp    f01044a0 <vprintfmt+0x310>
	else if (lflag)
f010446c:	85 c9                	test   %ecx,%ecx
f010446e:	74 19                	je     f0104489 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
f0104470:	8b 45 14             	mov    0x14(%ebp),%eax
f0104473:	83 c0 04             	add    $0x4,%eax
f0104476:	89 45 14             	mov    %eax,0x14(%ebp)
f0104479:	8b 40 fc             	mov    -0x4(%eax),%eax
f010447c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010447f:	89 c1                	mov    %eax,%ecx
f0104481:	c1 f9 1f             	sar    $0x1f,%ecx
f0104484:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104487:	eb 17                	jmp    f01044a0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
f0104489:	8b 45 14             	mov    0x14(%ebp),%eax
f010448c:	83 c0 04             	add    $0x4,%eax
f010448f:	89 45 14             	mov    %eax,0x14(%ebp)
f0104492:	8b 40 fc             	mov    -0x4(%eax),%eax
f0104495:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104498:	89 c2                	mov    %eax,%edx
f010449a:	c1 fa 1f             	sar    $0x1f,%edx
f010449d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01044a0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01044a3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01044a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01044ab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01044af:	0f 89 9c 00 00 00    	jns    f0104551 <vprintfmt+0x3c1>
				putch('-', putdat);
f01044b5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01044b9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01044c0:	ff d7                	call   *%edi
				num = -(long long) num;
f01044c2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01044c5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01044c8:	f7 d9                	neg    %ecx
f01044ca:	83 d3 00             	adc    $0x0,%ebx
f01044cd:	f7 db                	neg    %ebx
f01044cf:	b8 0a 00 00 00       	mov    $0xa,%eax
f01044d4:	eb 7b                	jmp    f0104551 <vprintfmt+0x3c1>
f01044d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01044d9:	89 ca                	mov    %ecx,%edx
f01044db:	8d 45 14             	lea    0x14(%ebp),%eax
f01044de:	e8 53 fc ff ff       	call   f0104136 <getuint>
f01044e3:	89 c1                	mov    %eax,%ecx
f01044e5:	89 d3                	mov    %edx,%ebx
f01044e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f01044ec:	eb 63                	jmp    f0104551 <vprintfmt+0x3c1>
f01044ee:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01044f1:	89 ca                	mov    %ecx,%edx
f01044f3:	8d 45 14             	lea    0x14(%ebp),%eax
f01044f6:	e8 3b fc ff ff       	call   f0104136 <getuint>
f01044fb:	89 c1                	mov    %eax,%ecx
f01044fd:	89 d3                	mov    %edx,%ebx
f01044ff:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
f0104504:	eb 4b                	jmp    f0104551 <vprintfmt+0x3c1>
f0104506:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0104509:	89 74 24 04          	mov    %esi,0x4(%esp)
f010450d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104514:	ff d7                	call   *%edi
			putch('x', putdat);
f0104516:	89 74 24 04          	mov    %esi,0x4(%esp)
f010451a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104521:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104523:	8b 45 14             	mov    0x14(%ebp),%eax
f0104526:	83 c0 04             	add    $0x4,%eax
f0104529:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010452c:	8b 48 fc             	mov    -0x4(%eax),%ecx
f010452f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104534:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104539:	eb 16                	jmp    f0104551 <vprintfmt+0x3c1>
f010453b:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010453e:	89 ca                	mov    %ecx,%edx
f0104540:	8d 45 14             	lea    0x14(%ebp),%eax
f0104543:	e8 ee fb ff ff       	call   f0104136 <getuint>
f0104548:	89 c1                	mov    %eax,%ecx
f010454a:	89 d3                	mov    %edx,%ebx
f010454c:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104551:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0104555:	89 54 24 10          	mov    %edx,0x10(%esp)
f0104559:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010455c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104560:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104564:	89 0c 24             	mov    %ecx,(%esp)
f0104567:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010456b:	89 f2                	mov    %esi,%edx
f010456d:	89 f8                	mov    %edi,%eax
f010456f:	e8 cc fa ff ff       	call   f0104040 <printnum>
f0104574:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0104577:	e9 40 fc ff ff       	jmp    f01041bc <vprintfmt+0x2c>
f010457c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010457f:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104582:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104586:	89 14 24             	mov    %edx,(%esp)
f0104589:	ff d7                	call   *%edi
f010458b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f010458e:	e9 29 fc ff ff       	jmp    f01041bc <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104593:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104597:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010459e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01045a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01045a3:	80 38 25             	cmpb   $0x25,(%eax)
f01045a6:	0f 84 10 fc ff ff    	je     f01041bc <vprintfmt+0x2c>
f01045ac:	89 c3                	mov    %eax,%ebx
f01045ae:	eb f0                	jmp    f01045a0 <vprintfmt+0x410>
				/* do nothing */;
			break;
		}
	}
}
f01045b0:	83 c4 5c             	add    $0x5c,%esp
f01045b3:	5b                   	pop    %ebx
f01045b4:	5e                   	pop    %esi
f01045b5:	5f                   	pop    %edi
f01045b6:	5d                   	pop    %ebp
f01045b7:	c3                   	ret    

f01045b8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01045b8:	55                   	push   %ebp
f01045b9:	89 e5                	mov    %esp,%ebp
f01045bb:	83 ec 28             	sub    $0x28,%esp
f01045be:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01045c4:	85 c0                	test   %eax,%eax
f01045c6:	74 04                	je     f01045cc <vsnprintf+0x14>
f01045c8:	85 d2                	test   %edx,%edx
f01045ca:	7f 07                	jg     f01045d3 <vsnprintf+0x1b>
f01045cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01045d1:	eb 3b                	jmp    f010460e <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f01045d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01045d6:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f01045da:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01045dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01045e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01045e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045eb:	8b 45 10             	mov    0x10(%ebp),%eax
f01045ee:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01045f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f9:	c7 04 24 73 41 10 f0 	movl   $0xf0104173,(%esp)
f0104600:	e8 8b fb ff ff       	call   f0104190 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104605:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104608:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010460b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f010460e:	c9                   	leave  
f010460f:	c3                   	ret    

f0104610 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104610:	55                   	push   %ebp
f0104611:	89 e5                	mov    %esp,%ebp
f0104613:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0104616:	8d 45 14             	lea    0x14(%ebp),%eax
f0104619:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010461d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104620:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104624:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104627:	89 44 24 04          	mov    %eax,0x4(%esp)
f010462b:	8b 45 08             	mov    0x8(%ebp),%eax
f010462e:	89 04 24             	mov    %eax,(%esp)
f0104631:	e8 82 ff ff ff       	call   f01045b8 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104636:	c9                   	leave  
f0104637:	c3                   	ret    

f0104638 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104638:	55                   	push   %ebp
f0104639:	89 e5                	mov    %esp,%ebp
f010463b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f010463e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104641:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104645:	8b 45 10             	mov    0x10(%ebp),%eax
f0104648:	89 44 24 08          	mov    %eax,0x8(%esp)
f010464c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010464f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104653:	8b 45 08             	mov    0x8(%ebp),%eax
f0104656:	89 04 24             	mov    %eax,(%esp)
f0104659:	e8 32 fb ff ff       	call   f0104190 <vprintfmt>
	va_end(ap);
}
f010465e:	c9                   	leave  
f010465f:	c3                   	ret    

f0104660 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104660:	55                   	push   %ebp
f0104661:	89 e5                	mov    %esp,%ebp
f0104663:	57                   	push   %edi
f0104664:	56                   	push   %esi
f0104665:	53                   	push   %ebx
f0104666:	83 ec 1c             	sub    $0x1c,%esp
f0104669:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010466c:	85 c0                	test   %eax,%eax
f010466e:	74 10                	je     f0104680 <readline+0x20>
		cprintf("%s", prompt);
f0104670:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104674:	c7 04 24 0b 57 10 f0 	movl   $0xf010570b,(%esp)
f010467b:	e8 97 e3 ff ff       	call   f0102a17 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104687:	e8 71 bc ff ff       	call   f01002fd <iscons>
f010468c:	89 c7                	mov    %eax,%edi
f010468e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0104693:	e8 54 bc ff ff       	call   f01002ec <getchar>
f0104698:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010469a:	85 c0                	test   %eax,%eax
f010469c:	79 17                	jns    f01046b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010469e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046a2:	c7 04 24 c4 5f 10 f0 	movl   $0xf0105fc4,(%esp)
f01046a9:	e8 69 e3 ff ff       	call   f0102a17 <cprintf>
f01046ae:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f01046b3:	eb 65                	jmp    f010471a <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01046b5:	83 f8 1f             	cmp    $0x1f,%eax
f01046b8:	7e 1f                	jle    f01046d9 <readline+0x79>
f01046ba:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01046c0:	7f 17                	jg     f01046d9 <readline+0x79>
			if (echoing)
f01046c2:	85 ff                	test   %edi,%edi
f01046c4:	74 08                	je     f01046ce <readline+0x6e>
				cputchar(c);
f01046c6:	89 04 24             	mov    %eax,(%esp)
f01046c9:	e8 f2 bf ff ff       	call   f01006c0 <cputchar>
			buf[i++] = c;
f01046ce:	88 9e c0 b7 1a f0    	mov    %bl,-0xfe54840(%esi)
f01046d4:	83 c6 01             	add    $0x1,%esi
f01046d7:	eb ba                	jmp    f0104693 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f01046d9:	83 fb 08             	cmp    $0x8,%ebx
f01046dc:	75 15                	jne    f01046f3 <readline+0x93>
f01046de:	85 f6                	test   %esi,%esi
f01046e0:	7e 11                	jle    f01046f3 <readline+0x93>
			if (echoing)
f01046e2:	85 ff                	test   %edi,%edi
f01046e4:	74 08                	je     f01046ee <readline+0x8e>
				cputchar(c);
f01046e6:	89 1c 24             	mov    %ebx,(%esp)
f01046e9:	e8 d2 bf ff ff       	call   f01006c0 <cputchar>
			i--;
f01046ee:	83 ee 01             	sub    $0x1,%esi
f01046f1:	eb a0                	jmp    f0104693 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01046f3:	83 fb 0a             	cmp    $0xa,%ebx
f01046f6:	74 0a                	je     f0104702 <readline+0xa2>
f01046f8:	83 fb 0d             	cmp    $0xd,%ebx
f01046fb:	90                   	nop
f01046fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104700:	75 91                	jne    f0104693 <readline+0x33>
			if (echoing)
f0104702:	85 ff                	test   %edi,%edi
f0104704:	74 08                	je     f010470e <readline+0xae>
				cputchar(c);
f0104706:	89 1c 24             	mov    %ebx,(%esp)
f0104709:	e8 b2 bf ff ff       	call   f01006c0 <cputchar>
			buf[i] = 0;
f010470e:	c6 86 c0 b7 1a f0 00 	movb   $0x0,-0xfe54840(%esi)
f0104715:	b8 c0 b7 1a f0       	mov    $0xf01ab7c0,%eax
			return buf;
		}
	}
}
f010471a:	83 c4 1c             	add    $0x1c,%esp
f010471d:	5b                   	pop    %ebx
f010471e:	5e                   	pop    %esi
f010471f:	5f                   	pop    %edi
f0104720:	5d                   	pop    %ebp
f0104721:	c3                   	ret    
	...

f0104730 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0104730:	55                   	push   %ebp
f0104731:	89 e5                	mov    %esp,%ebp
f0104733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104736:	b8 00 00 00 00       	mov    $0x0,%eax
f010473b:	80 3a 00             	cmpb   $0x0,(%edx)
f010473e:	74 09                	je     f0104749 <strlen+0x19>
		n++;
f0104740:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104743:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104747:	75 f7                	jne    f0104740 <strlen+0x10>
		n++;
	return n;
}
f0104749:	5d                   	pop    %ebp
f010474a:	c3                   	ret    

f010474b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010474b:	55                   	push   %ebp
f010474c:	89 e5                	mov    %esp,%ebp
f010474e:	53                   	push   %ebx
f010474f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104755:	85 c9                	test   %ecx,%ecx
f0104757:	74 19                	je     f0104772 <strnlen+0x27>
f0104759:	80 3b 00             	cmpb   $0x0,(%ebx)
f010475c:	74 14                	je     f0104772 <strnlen+0x27>
f010475e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104763:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104766:	39 c8                	cmp    %ecx,%eax
f0104768:	74 0d                	je     f0104777 <strnlen+0x2c>
f010476a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010476e:	75 f3                	jne    f0104763 <strnlen+0x18>
f0104770:	eb 05                	jmp    f0104777 <strnlen+0x2c>
f0104772:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104777:	5b                   	pop    %ebx
f0104778:	5d                   	pop    %ebp
f0104779:	c3                   	ret    

f010477a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010477a:	55                   	push   %ebp
f010477b:	89 e5                	mov    %esp,%ebp
f010477d:	53                   	push   %ebx
f010477e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104781:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104784:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104789:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010478d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104790:	83 c2 01             	add    $0x1,%edx
f0104793:	84 c9                	test   %cl,%cl
f0104795:	75 f2                	jne    f0104789 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104797:	5b                   	pop    %ebx
f0104798:	5d                   	pop    %ebp
f0104799:	c3                   	ret    

f010479a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010479a:	55                   	push   %ebp
f010479b:	89 e5                	mov    %esp,%ebp
f010479d:	56                   	push   %esi
f010479e:	53                   	push   %ebx
f010479f:	8b 45 08             	mov    0x8(%ebp),%eax
f01047a2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01047a5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01047a8:	85 f6                	test   %esi,%esi
f01047aa:	74 18                	je     f01047c4 <strncpy+0x2a>
f01047ac:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01047b1:	0f b6 1a             	movzbl (%edx),%ebx
f01047b4:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01047b7:	80 3a 01             	cmpb   $0x1,(%edx)
f01047ba:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01047bd:	83 c1 01             	add    $0x1,%ecx
f01047c0:	39 ce                	cmp    %ecx,%esi
f01047c2:	77 ed                	ja     f01047b1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01047c4:	5b                   	pop    %ebx
f01047c5:	5e                   	pop    %esi
f01047c6:	5d                   	pop    %ebp
f01047c7:	c3                   	ret    

f01047c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01047c8:	55                   	push   %ebp
f01047c9:	89 e5                	mov    %esp,%ebp
f01047cb:	56                   	push   %esi
f01047cc:	53                   	push   %ebx
f01047cd:	8b 75 08             	mov    0x8(%ebp),%esi
f01047d0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01047d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01047d6:	89 f0                	mov    %esi,%eax
f01047d8:	85 c9                	test   %ecx,%ecx
f01047da:	74 27                	je     f0104803 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f01047dc:	83 e9 01             	sub    $0x1,%ecx
f01047df:	74 1d                	je     f01047fe <strlcpy+0x36>
f01047e1:	0f b6 1a             	movzbl (%edx),%ebx
f01047e4:	84 db                	test   %bl,%bl
f01047e6:	74 16                	je     f01047fe <strlcpy+0x36>
			*dst++ = *src++;
f01047e8:	88 18                	mov    %bl,(%eax)
f01047ea:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01047ed:	83 e9 01             	sub    $0x1,%ecx
f01047f0:	74 0e                	je     f0104800 <strlcpy+0x38>
			*dst++ = *src++;
f01047f2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01047f5:	0f b6 1a             	movzbl (%edx),%ebx
f01047f8:	84 db                	test   %bl,%bl
f01047fa:	75 ec                	jne    f01047e8 <strlcpy+0x20>
f01047fc:	eb 02                	jmp    f0104800 <strlcpy+0x38>
f01047fe:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104800:	c6 00 00             	movb   $0x0,(%eax)
f0104803:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0104805:	5b                   	pop    %ebx
f0104806:	5e                   	pop    %esi
f0104807:	5d                   	pop    %ebp
f0104808:	c3                   	ret    

f0104809 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104809:	55                   	push   %ebp
f010480a:	89 e5                	mov    %esp,%ebp
f010480c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010480f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104812:	0f b6 01             	movzbl (%ecx),%eax
f0104815:	84 c0                	test   %al,%al
f0104817:	74 15                	je     f010482e <strcmp+0x25>
f0104819:	3a 02                	cmp    (%edx),%al
f010481b:	75 11                	jne    f010482e <strcmp+0x25>
		p++, q++;
f010481d:	83 c1 01             	add    $0x1,%ecx
f0104820:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104823:	0f b6 01             	movzbl (%ecx),%eax
f0104826:	84 c0                	test   %al,%al
f0104828:	74 04                	je     f010482e <strcmp+0x25>
f010482a:	3a 02                	cmp    (%edx),%al
f010482c:	74 ef                	je     f010481d <strcmp+0x14>
f010482e:	0f b6 c0             	movzbl %al,%eax
f0104831:	0f b6 12             	movzbl (%edx),%edx
f0104834:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104836:	5d                   	pop    %ebp
f0104837:	c3                   	ret    

f0104838 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104838:	55                   	push   %ebp
f0104839:	89 e5                	mov    %esp,%ebp
f010483b:	53                   	push   %ebx
f010483c:	8b 55 08             	mov    0x8(%ebp),%edx
f010483f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104842:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0104845:	85 c0                	test   %eax,%eax
f0104847:	74 23                	je     f010486c <strncmp+0x34>
f0104849:	0f b6 1a             	movzbl (%edx),%ebx
f010484c:	84 db                	test   %bl,%bl
f010484e:	74 24                	je     f0104874 <strncmp+0x3c>
f0104850:	3a 19                	cmp    (%ecx),%bl
f0104852:	75 20                	jne    f0104874 <strncmp+0x3c>
f0104854:	83 e8 01             	sub    $0x1,%eax
f0104857:	74 13                	je     f010486c <strncmp+0x34>
		n--, p++, q++;
f0104859:	83 c2 01             	add    $0x1,%edx
f010485c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010485f:	0f b6 1a             	movzbl (%edx),%ebx
f0104862:	84 db                	test   %bl,%bl
f0104864:	74 0e                	je     f0104874 <strncmp+0x3c>
f0104866:	3a 19                	cmp    (%ecx),%bl
f0104868:	74 ea                	je     f0104854 <strncmp+0x1c>
f010486a:	eb 08                	jmp    f0104874 <strncmp+0x3c>
f010486c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104871:	5b                   	pop    %ebx
f0104872:	5d                   	pop    %ebp
f0104873:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104874:	0f b6 02             	movzbl (%edx),%eax
f0104877:	0f b6 11             	movzbl (%ecx),%edx
f010487a:	29 d0                	sub    %edx,%eax
f010487c:	eb f3                	jmp    f0104871 <strncmp+0x39>

f010487e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010487e:	55                   	push   %ebp
f010487f:	89 e5                	mov    %esp,%ebp
f0104881:	8b 45 08             	mov    0x8(%ebp),%eax
f0104884:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104888:	0f b6 10             	movzbl (%eax),%edx
f010488b:	84 d2                	test   %dl,%dl
f010488d:	74 15                	je     f01048a4 <strchr+0x26>
		if (*s == c)
f010488f:	38 ca                	cmp    %cl,%dl
f0104891:	75 07                	jne    f010489a <strchr+0x1c>
f0104893:	eb 14                	jmp    f01048a9 <strchr+0x2b>
f0104895:	38 ca                	cmp    %cl,%dl
f0104897:	90                   	nop
f0104898:	74 0f                	je     f01048a9 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010489a:	83 c0 01             	add    $0x1,%eax
f010489d:	0f b6 10             	movzbl (%eax),%edx
f01048a0:	84 d2                	test   %dl,%dl
f01048a2:	75 f1                	jne    f0104895 <strchr+0x17>
f01048a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f01048a9:	5d                   	pop    %ebp
f01048aa:	c3                   	ret    

f01048ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01048ab:	55                   	push   %ebp
f01048ac:	89 e5                	mov    %esp,%ebp
f01048ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01048b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01048b5:	0f b6 10             	movzbl (%eax),%edx
f01048b8:	84 d2                	test   %dl,%dl
f01048ba:	74 18                	je     f01048d4 <strfind+0x29>
		if (*s == c)
f01048bc:	38 ca                	cmp    %cl,%dl
f01048be:	75 0a                	jne    f01048ca <strfind+0x1f>
f01048c0:	eb 12                	jmp    f01048d4 <strfind+0x29>
f01048c2:	38 ca                	cmp    %cl,%dl
f01048c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01048c8:	74 0a                	je     f01048d4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01048ca:	83 c0 01             	add    $0x1,%eax
f01048cd:	0f b6 10             	movzbl (%eax),%edx
f01048d0:	84 d2                	test   %dl,%dl
f01048d2:	75 ee                	jne    f01048c2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01048d4:	5d                   	pop    %ebp
f01048d5:	c3                   	ret    

f01048d6 <memset>:


void *
memset(void *v, int c, size_t n)
{
f01048d6:	55                   	push   %ebp
f01048d7:	89 e5                	mov    %esp,%ebp
f01048d9:	53                   	push   %ebx
f01048da:	8b 45 08             	mov    0x8(%ebp),%eax
f01048dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01048e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01048e3:	89 da                	mov    %ebx,%edx
f01048e5:	83 ea 01             	sub    $0x1,%edx
f01048e8:	78 0d                	js     f01048f7 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f01048ea:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f01048ec:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f01048ee:	88 0a                	mov    %cl,(%edx)
f01048f0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01048f3:	39 da                	cmp    %ebx,%edx
f01048f5:	75 f7                	jne    f01048ee <memset+0x18>
		*p++ = c;

	return v;
}
f01048f7:	5b                   	pop    %ebx
f01048f8:	5d                   	pop    %ebp
f01048f9:	c3                   	ret    

f01048fa <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f01048fa:	55                   	push   %ebp
f01048fb:	89 e5                	mov    %esp,%ebp
f01048fd:	56                   	push   %esi
f01048fe:	53                   	push   %ebx
f01048ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0104902:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104905:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0104908:	85 db                	test   %ebx,%ebx
f010490a:	74 13                	je     f010491f <memcpy+0x25>
f010490c:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f0104911:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0104915:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104918:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f010491b:	39 da                	cmp    %ebx,%edx
f010491d:	75 f2                	jne    f0104911 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f010491f:	5b                   	pop    %ebx
f0104920:	5e                   	pop    %esi
f0104921:	5d                   	pop    %ebp
f0104922:	c3                   	ret    

f0104923 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104923:	55                   	push   %ebp
f0104924:	89 e5                	mov    %esp,%ebp
f0104926:	57                   	push   %edi
f0104927:	56                   	push   %esi
f0104928:	53                   	push   %ebx
f0104929:	8b 45 08             	mov    0x8(%ebp),%eax
f010492c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010492f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f0104932:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f0104934:	39 c6                	cmp    %eax,%esi
f0104936:	72 0b                	jb     f0104943 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f0104938:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f010493d:	85 db                	test   %ebx,%ebx
f010493f:	75 2e                	jne    f010496f <memmove+0x4c>
f0104941:	eb 3a                	jmp    f010497d <memmove+0x5a>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104943:	01 df                	add    %ebx,%edi
f0104945:	39 f8                	cmp    %edi,%eax
f0104947:	73 ef                	jae    f0104938 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f0104949:	85 db                	test   %ebx,%ebx
f010494b:	90                   	nop
f010494c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104950:	74 2b                	je     f010497d <memmove+0x5a>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0104952:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f0104955:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f010495a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f010495f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f0104963:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0104966:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0104969:	85 c9                	test   %ecx,%ecx
f010496b:	75 ed                	jne    f010495a <memmove+0x37>
f010496d:	eb 0e                	jmp    f010497d <memmove+0x5a>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f010496f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0104973:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104976:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0104979:	39 d3                	cmp    %edx,%ebx
f010497b:	75 f2                	jne    f010496f <memmove+0x4c>
			*d++ = *s++;

	return dst;
}
f010497d:	5b                   	pop    %ebx
f010497e:	5e                   	pop    %esi
f010497f:	5f                   	pop    %edi
f0104980:	5d                   	pop    %ebp
f0104981:	c3                   	ret    

f0104982 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104982:	55                   	push   %ebp
f0104983:	89 e5                	mov    %esp,%ebp
f0104985:	57                   	push   %edi
f0104986:	56                   	push   %esi
f0104987:	53                   	push   %ebx
f0104988:	8b 75 08             	mov    0x8(%ebp),%esi
f010498b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010498e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104991:	85 c9                	test   %ecx,%ecx
f0104993:	74 36                	je     f01049cb <memcmp+0x49>
		if (*s1 != *s2)
f0104995:	0f b6 06             	movzbl (%esi),%eax
f0104998:	0f b6 1f             	movzbl (%edi),%ebx
f010499b:	38 d8                	cmp    %bl,%al
f010499d:	74 20                	je     f01049bf <memcmp+0x3d>
f010499f:	eb 14                	jmp    f01049b5 <memcmp+0x33>
f01049a1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f01049a6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f01049ab:	83 c2 01             	add    $0x1,%edx
f01049ae:	83 e9 01             	sub    $0x1,%ecx
f01049b1:	38 d8                	cmp    %bl,%al
f01049b3:	74 12                	je     f01049c7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f01049b5:	0f b6 c0             	movzbl %al,%eax
f01049b8:	0f b6 db             	movzbl %bl,%ebx
f01049bb:	29 d8                	sub    %ebx,%eax
f01049bd:	eb 11                	jmp    f01049d0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01049bf:	83 e9 01             	sub    $0x1,%ecx
f01049c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01049c7:	85 c9                	test   %ecx,%ecx
f01049c9:	75 d6                	jne    f01049a1 <memcmp+0x1f>
f01049cb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f01049d0:	5b                   	pop    %ebx
f01049d1:	5e                   	pop    %esi
f01049d2:	5f                   	pop    %edi
f01049d3:	5d                   	pop    %ebp
f01049d4:	c3                   	ret    

f01049d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01049d5:	55                   	push   %ebp
f01049d6:	89 e5                	mov    %esp,%ebp
f01049d8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01049db:	89 c2                	mov    %eax,%edx
f01049dd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01049e0:	39 d0                	cmp    %edx,%eax
f01049e2:	73 15                	jae    f01049f9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01049e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01049e8:	38 08                	cmp    %cl,(%eax)
f01049ea:	75 06                	jne    f01049f2 <memfind+0x1d>
f01049ec:	eb 0b                	jmp    f01049f9 <memfind+0x24>
f01049ee:	38 08                	cmp    %cl,(%eax)
f01049f0:	74 07                	je     f01049f9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01049f2:	83 c0 01             	add    $0x1,%eax
f01049f5:	39 c2                	cmp    %eax,%edx
f01049f7:	77 f5                	ja     f01049ee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01049f9:	5d                   	pop    %ebp
f01049fa:	c3                   	ret    

f01049fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01049fb:	55                   	push   %ebp
f01049fc:	89 e5                	mov    %esp,%ebp
f01049fe:	57                   	push   %edi
f01049ff:	56                   	push   %esi
f0104a00:	53                   	push   %ebx
f0104a01:	83 ec 04             	sub    $0x4,%esp
f0104a04:	8b 55 08             	mov    0x8(%ebp),%edx
f0104a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104a0a:	0f b6 02             	movzbl (%edx),%eax
f0104a0d:	3c 20                	cmp    $0x20,%al
f0104a0f:	74 04                	je     f0104a15 <strtol+0x1a>
f0104a11:	3c 09                	cmp    $0x9,%al
f0104a13:	75 0e                	jne    f0104a23 <strtol+0x28>
		s++;
f0104a15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104a18:	0f b6 02             	movzbl (%edx),%eax
f0104a1b:	3c 20                	cmp    $0x20,%al
f0104a1d:	74 f6                	je     f0104a15 <strtol+0x1a>
f0104a1f:	3c 09                	cmp    $0x9,%al
f0104a21:	74 f2                	je     f0104a15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104a23:	3c 2b                	cmp    $0x2b,%al
f0104a25:	75 0c                	jne    f0104a33 <strtol+0x38>
		s++;
f0104a27:	83 c2 01             	add    $0x1,%edx
f0104a2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104a31:	eb 15                	jmp    f0104a48 <strtol+0x4d>
	else if (*s == '-')
f0104a33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104a3a:	3c 2d                	cmp    $0x2d,%al
f0104a3c:	75 0a                	jne    f0104a48 <strtol+0x4d>
		s++, neg = 1;
f0104a3e:	83 c2 01             	add    $0x1,%edx
f0104a41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a48:	85 db                	test   %ebx,%ebx
f0104a4a:	0f 94 c0             	sete   %al
f0104a4d:	74 05                	je     f0104a54 <strtol+0x59>
f0104a4f:	83 fb 10             	cmp    $0x10,%ebx
f0104a52:	75 18                	jne    f0104a6c <strtol+0x71>
f0104a54:	80 3a 30             	cmpb   $0x30,(%edx)
f0104a57:	75 13                	jne    f0104a6c <strtol+0x71>
f0104a59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104a5d:	8d 76 00             	lea    0x0(%esi),%esi
f0104a60:	75 0a                	jne    f0104a6c <strtol+0x71>
		s += 2, base = 16;
f0104a62:	83 c2 02             	add    $0x2,%edx
f0104a65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104a6a:	eb 15                	jmp    f0104a81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104a6c:	84 c0                	test   %al,%al
f0104a6e:	66 90                	xchg   %ax,%ax
f0104a70:	74 0f                	je     f0104a81 <strtol+0x86>
f0104a72:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104a77:	80 3a 30             	cmpb   $0x30,(%edx)
f0104a7a:	75 05                	jne    f0104a81 <strtol+0x86>
		s++, base = 8;
f0104a7c:	83 c2 01             	add    $0x1,%edx
f0104a7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104a81:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104a88:	0f b6 0a             	movzbl (%edx),%ecx
f0104a8b:	89 cf                	mov    %ecx,%edi
f0104a8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104a90:	80 fb 09             	cmp    $0x9,%bl
f0104a93:	77 08                	ja     f0104a9d <strtol+0xa2>
			dig = *s - '0';
f0104a95:	0f be c9             	movsbl %cl,%ecx
f0104a98:	83 e9 30             	sub    $0x30,%ecx
f0104a9b:	eb 1e                	jmp    f0104abb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0104a9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0104aa0:	80 fb 19             	cmp    $0x19,%bl
f0104aa3:	77 08                	ja     f0104aad <strtol+0xb2>
			dig = *s - 'a' + 10;
f0104aa5:	0f be c9             	movsbl %cl,%ecx
f0104aa8:	83 e9 57             	sub    $0x57,%ecx
f0104aab:	eb 0e                	jmp    f0104abb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0104aad:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0104ab0:	80 fb 19             	cmp    $0x19,%bl
f0104ab3:	77 15                	ja     f0104aca <strtol+0xcf>
			dig = *s - 'A' + 10;
f0104ab5:	0f be c9             	movsbl %cl,%ecx
f0104ab8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104abb:	39 f1                	cmp    %esi,%ecx
f0104abd:	7d 0b                	jge    f0104aca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0104abf:	83 c2 01             	add    $0x1,%edx
f0104ac2:	0f af c6             	imul   %esi,%eax
f0104ac5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0104ac8:	eb be                	jmp    f0104a88 <strtol+0x8d>
f0104aca:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0104acc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104ad0:	74 05                	je     f0104ad7 <strtol+0xdc>
		*endptr = (char *) s;
f0104ad2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ad5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104ad7:	89 ca                	mov    %ecx,%edx
f0104ad9:	f7 da                	neg    %edx
f0104adb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104adf:	0f 45 c2             	cmovne %edx,%eax
}
f0104ae2:	83 c4 04             	add    $0x4,%esp
f0104ae5:	5b                   	pop    %ebx
f0104ae6:	5e                   	pop    %esi
f0104ae7:	5f                   	pop    %edi
f0104ae8:	5d                   	pop    %ebp
f0104ae9:	c3                   	ret    
f0104aea:	00 00                	add    %al,(%eax)
f0104aec:	00 00                	add    %al,(%eax)
	...

f0104af0 <__udivdi3>:
f0104af0:	55                   	push   %ebp
f0104af1:	89 e5                	mov    %esp,%ebp
f0104af3:	57                   	push   %edi
f0104af4:	56                   	push   %esi
f0104af5:	83 ec 10             	sub    $0x10,%esp
f0104af8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104afb:	8b 55 08             	mov    0x8(%ebp),%edx
f0104afe:	8b 75 10             	mov    0x10(%ebp),%esi
f0104b01:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104b04:	85 c0                	test   %eax,%eax
f0104b06:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0104b09:	75 35                	jne    f0104b40 <__udivdi3+0x50>
f0104b0b:	39 fe                	cmp    %edi,%esi
f0104b0d:	77 61                	ja     f0104b70 <__udivdi3+0x80>
f0104b0f:	85 f6                	test   %esi,%esi
f0104b11:	75 0b                	jne    f0104b1e <__udivdi3+0x2e>
f0104b13:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b18:	31 d2                	xor    %edx,%edx
f0104b1a:	f7 f6                	div    %esi
f0104b1c:	89 c6                	mov    %eax,%esi
f0104b1e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104b21:	31 d2                	xor    %edx,%edx
f0104b23:	89 f8                	mov    %edi,%eax
f0104b25:	f7 f6                	div    %esi
f0104b27:	89 c7                	mov    %eax,%edi
f0104b29:	89 c8                	mov    %ecx,%eax
f0104b2b:	f7 f6                	div    %esi
f0104b2d:	89 c1                	mov    %eax,%ecx
f0104b2f:	89 fa                	mov    %edi,%edx
f0104b31:	89 c8                	mov    %ecx,%eax
f0104b33:	83 c4 10             	add    $0x10,%esp
f0104b36:	5e                   	pop    %esi
f0104b37:	5f                   	pop    %edi
f0104b38:	5d                   	pop    %ebp
f0104b39:	c3                   	ret    
f0104b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104b40:	39 f8                	cmp    %edi,%eax
f0104b42:	77 1c                	ja     f0104b60 <__udivdi3+0x70>
f0104b44:	0f bd d0             	bsr    %eax,%edx
f0104b47:	83 f2 1f             	xor    $0x1f,%edx
f0104b4a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0104b4d:	75 39                	jne    f0104b88 <__udivdi3+0x98>
f0104b4f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104b52:	0f 86 a0 00 00 00    	jbe    f0104bf8 <__udivdi3+0x108>
f0104b58:	39 f8                	cmp    %edi,%eax
f0104b5a:	0f 82 98 00 00 00    	jb     f0104bf8 <__udivdi3+0x108>
f0104b60:	31 ff                	xor    %edi,%edi
f0104b62:	31 c9                	xor    %ecx,%ecx
f0104b64:	89 c8                	mov    %ecx,%eax
f0104b66:	89 fa                	mov    %edi,%edx
f0104b68:	83 c4 10             	add    $0x10,%esp
f0104b6b:	5e                   	pop    %esi
f0104b6c:	5f                   	pop    %edi
f0104b6d:	5d                   	pop    %ebp
f0104b6e:	c3                   	ret    
f0104b6f:	90                   	nop
f0104b70:	89 d1                	mov    %edx,%ecx
f0104b72:	89 fa                	mov    %edi,%edx
f0104b74:	89 c8                	mov    %ecx,%eax
f0104b76:	31 ff                	xor    %edi,%edi
f0104b78:	f7 f6                	div    %esi
f0104b7a:	89 c1                	mov    %eax,%ecx
f0104b7c:	89 fa                	mov    %edi,%edx
f0104b7e:	89 c8                	mov    %ecx,%eax
f0104b80:	83 c4 10             	add    $0x10,%esp
f0104b83:	5e                   	pop    %esi
f0104b84:	5f                   	pop    %edi
f0104b85:	5d                   	pop    %ebp
f0104b86:	c3                   	ret    
f0104b87:	90                   	nop
f0104b88:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104b8c:	89 f2                	mov    %esi,%edx
f0104b8e:	d3 e0                	shl    %cl,%eax
f0104b90:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b93:	b8 20 00 00 00       	mov    $0x20,%eax
f0104b98:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0104b9b:	89 c1                	mov    %eax,%ecx
f0104b9d:	d3 ea                	shr    %cl,%edx
f0104b9f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104ba3:	0b 55 ec             	or     -0x14(%ebp),%edx
f0104ba6:	d3 e6                	shl    %cl,%esi
f0104ba8:	89 c1                	mov    %eax,%ecx
f0104baa:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0104bad:	89 fe                	mov    %edi,%esi
f0104baf:	d3 ee                	shr    %cl,%esi
f0104bb1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104bb5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0104bb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104bbb:	d3 e7                	shl    %cl,%edi
f0104bbd:	89 c1                	mov    %eax,%ecx
f0104bbf:	d3 ea                	shr    %cl,%edx
f0104bc1:	09 d7                	or     %edx,%edi
f0104bc3:	89 f2                	mov    %esi,%edx
f0104bc5:	89 f8                	mov    %edi,%eax
f0104bc7:	f7 75 ec             	divl   -0x14(%ebp)
f0104bca:	89 d6                	mov    %edx,%esi
f0104bcc:	89 c7                	mov    %eax,%edi
f0104bce:	f7 65 e8             	mull   -0x18(%ebp)
f0104bd1:	39 d6                	cmp    %edx,%esi
f0104bd3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0104bd6:	72 30                	jb     f0104c08 <__udivdi3+0x118>
f0104bd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104bdb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104bdf:	d3 e2                	shl    %cl,%edx
f0104be1:	39 c2                	cmp    %eax,%edx
f0104be3:	73 05                	jae    f0104bea <__udivdi3+0xfa>
f0104be5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0104be8:	74 1e                	je     f0104c08 <__udivdi3+0x118>
f0104bea:	89 f9                	mov    %edi,%ecx
f0104bec:	31 ff                	xor    %edi,%edi
f0104bee:	e9 71 ff ff ff       	jmp    f0104b64 <__udivdi3+0x74>
f0104bf3:	90                   	nop
f0104bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104bf8:	31 ff                	xor    %edi,%edi
f0104bfa:	b9 01 00 00 00       	mov    $0x1,%ecx
f0104bff:	e9 60 ff ff ff       	jmp    f0104b64 <__udivdi3+0x74>
f0104c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104c08:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0104c0b:	31 ff                	xor    %edi,%edi
f0104c0d:	89 c8                	mov    %ecx,%eax
f0104c0f:	89 fa                	mov    %edi,%edx
f0104c11:	83 c4 10             	add    $0x10,%esp
f0104c14:	5e                   	pop    %esi
f0104c15:	5f                   	pop    %edi
f0104c16:	5d                   	pop    %ebp
f0104c17:	c3                   	ret    
	...

f0104c20 <__umoddi3>:
f0104c20:	55                   	push   %ebp
f0104c21:	89 e5                	mov    %esp,%ebp
f0104c23:	57                   	push   %edi
f0104c24:	56                   	push   %esi
f0104c25:	83 ec 20             	sub    $0x20,%esp
f0104c28:	8b 55 14             	mov    0x14(%ebp),%edx
f0104c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104c2e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104c31:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c34:	85 d2                	test   %edx,%edx
f0104c36:	89 c8                	mov    %ecx,%eax
f0104c38:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104c3b:	75 13                	jne    f0104c50 <__umoddi3+0x30>
f0104c3d:	39 f7                	cmp    %esi,%edi
f0104c3f:	76 3f                	jbe    f0104c80 <__umoddi3+0x60>
f0104c41:	89 f2                	mov    %esi,%edx
f0104c43:	f7 f7                	div    %edi
f0104c45:	89 d0                	mov    %edx,%eax
f0104c47:	31 d2                	xor    %edx,%edx
f0104c49:	83 c4 20             	add    $0x20,%esp
f0104c4c:	5e                   	pop    %esi
f0104c4d:	5f                   	pop    %edi
f0104c4e:	5d                   	pop    %ebp
f0104c4f:	c3                   	ret    
f0104c50:	39 f2                	cmp    %esi,%edx
f0104c52:	77 4c                	ja     f0104ca0 <__umoddi3+0x80>
f0104c54:	0f bd ca             	bsr    %edx,%ecx
f0104c57:	83 f1 1f             	xor    $0x1f,%ecx
f0104c5a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104c5d:	75 51                	jne    f0104cb0 <__umoddi3+0x90>
f0104c5f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0104c62:	0f 87 e0 00 00 00    	ja     f0104d48 <__umoddi3+0x128>
f0104c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c6b:	29 f8                	sub    %edi,%eax
f0104c6d:	19 d6                	sbb    %edx,%esi
f0104c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c75:	89 f2                	mov    %esi,%edx
f0104c77:	83 c4 20             	add    $0x20,%esp
f0104c7a:	5e                   	pop    %esi
f0104c7b:	5f                   	pop    %edi
f0104c7c:	5d                   	pop    %ebp
f0104c7d:	c3                   	ret    
f0104c7e:	66 90                	xchg   %ax,%ax
f0104c80:	85 ff                	test   %edi,%edi
f0104c82:	75 0b                	jne    f0104c8f <__umoddi3+0x6f>
f0104c84:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c89:	31 d2                	xor    %edx,%edx
f0104c8b:	f7 f7                	div    %edi
f0104c8d:	89 c7                	mov    %eax,%edi
f0104c8f:	89 f0                	mov    %esi,%eax
f0104c91:	31 d2                	xor    %edx,%edx
f0104c93:	f7 f7                	div    %edi
f0104c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c98:	f7 f7                	div    %edi
f0104c9a:	eb a9                	jmp    f0104c45 <__umoddi3+0x25>
f0104c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104ca0:	89 c8                	mov    %ecx,%eax
f0104ca2:	89 f2                	mov    %esi,%edx
f0104ca4:	83 c4 20             	add    $0x20,%esp
f0104ca7:	5e                   	pop    %esi
f0104ca8:	5f                   	pop    %edi
f0104ca9:	5d                   	pop    %ebp
f0104caa:	c3                   	ret    
f0104cab:	90                   	nop
f0104cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104cb0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104cb4:	d3 e2                	shl    %cl,%edx
f0104cb6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0104cb9:	ba 20 00 00 00       	mov    $0x20,%edx
f0104cbe:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0104cc1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0104cc4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104cc8:	89 fa                	mov    %edi,%edx
f0104cca:	d3 ea                	shr    %cl,%edx
f0104ccc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104cd0:	0b 55 f4             	or     -0xc(%ebp),%edx
f0104cd3:	d3 e7                	shl    %cl,%edi
f0104cd5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104cd9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0104cdc:	89 f2                	mov    %esi,%edx
f0104cde:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0104ce1:	89 c7                	mov    %eax,%edi
f0104ce3:	d3 ea                	shr    %cl,%edx
f0104ce5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104ce9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104cec:	89 c2                	mov    %eax,%edx
f0104cee:	d3 e6                	shl    %cl,%esi
f0104cf0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104cf4:	d3 ea                	shr    %cl,%edx
f0104cf6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104cfa:	09 d6                	or     %edx,%esi
f0104cfc:	89 f0                	mov    %esi,%eax
f0104cfe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d01:	d3 e7                	shl    %cl,%edi
f0104d03:	89 f2                	mov    %esi,%edx
f0104d05:	f7 75 f4             	divl   -0xc(%ebp)
f0104d08:	89 d6                	mov    %edx,%esi
f0104d0a:	f7 65 e8             	mull   -0x18(%ebp)
f0104d0d:	39 d6                	cmp    %edx,%esi
f0104d0f:	72 2b                	jb     f0104d3c <__umoddi3+0x11c>
f0104d11:	39 c7                	cmp    %eax,%edi
f0104d13:	72 23                	jb     f0104d38 <__umoddi3+0x118>
f0104d15:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104d19:	29 c7                	sub    %eax,%edi
f0104d1b:	19 d6                	sbb    %edx,%esi
f0104d1d:	89 f0                	mov    %esi,%eax
f0104d1f:	89 f2                	mov    %esi,%edx
f0104d21:	d3 ef                	shr    %cl,%edi
f0104d23:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104d27:	d3 e0                	shl    %cl,%eax
f0104d29:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104d2d:	09 f8                	or     %edi,%eax
f0104d2f:	d3 ea                	shr    %cl,%edx
f0104d31:	83 c4 20             	add    $0x20,%esp
f0104d34:	5e                   	pop    %esi
f0104d35:	5f                   	pop    %edi
f0104d36:	5d                   	pop    %ebp
f0104d37:	c3                   	ret    
f0104d38:	39 d6                	cmp    %edx,%esi
f0104d3a:	75 d9                	jne    f0104d15 <__umoddi3+0xf5>
f0104d3c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0104d3f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0104d42:	eb d1                	jmp    f0104d15 <__umoddi3+0xf5>
f0104d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d48:	39 f2                	cmp    %esi,%edx
f0104d4a:	0f 82 18 ff ff ff    	jb     f0104c68 <__umoddi3+0x48>
f0104d50:	e9 1d ff ff ff       	jmp    f0104c72 <__umoddi3+0x52>
