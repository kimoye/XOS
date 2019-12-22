#include <boot.h>

vga_addr = 0xb800
vga_nber = 0x4000
PROT_NODE_CSEG = 0x8
PROT_NODE_DSEG = 0x10
4GB		 = 0xffffffff

.global start
start:
	.code16
	cli					#关中断，网上学的
	cld					#清楚方向标志，网上学的
	
	#清零段寄存器
	xorw	%ax,%ax
	movw	%ax,%ds
	movw	%ax,%es
	movw	%ax,%ss
	xorw	%sp,%sp
	call 	vga_clr

vga_clr:				#clear vga
	movw 	$vga_addr,%bx
	movw 	%bx,%es
	xorw 	%di,%di
	movw 	$0x0000,%ax
	movw	$vga_nber,%cx
	rep 	stosb
	ret
#打开A20
seta20.1:
	inb		$0x64,%al	#等待端口不忙
	testb	$0x2, %al 	#如果al第2位为0就不执行跳转
	jnz		seta20.1
	movb	$0xd1,%al	#0xd1 --> port 0x64
	outb 	%al, $0x64
seta20.2:
	inb 	$0x64,%al
	testb	$0x2, %al
	jnz		seta20.2
	movb	$0xdf,%al
	outb	%al,$0x60
	#load gdt
	lgdt	gdtdsec
	movl	%cr0, %eax
	orl 	$0x1, %eax 	#打开保护模式
	movl	%eax, %cr0

	ljmp 	$PROT_NODE_CSEG, $protcseg

.code32	
	movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    movl $start, %esp

boot_info:				#printf info of boot
	movw 	$msg,%si
	movb 	$0x7,%ah
	movw	$vga_addr,%bx
	movw	%bx,%es
	movl 	$985,%edx	
vga_prf:				#printf
	lodsb
	or 		%al,%al
	jz 		c_boot
	movw	%ax,%es:0(,%edx,2)
	incl	%edx
	jmp		vga_prf
	
c_boot:
	call bootmain
spin:
	jmp spin
msg:
.asciz	"Welcome to XOS(protect mode)!"

.p2align 2
gdt:
	SEG_NULL
	SEG_ASM(STA_X|STA_R, 0x0, 4GB)
	SRG_ASM(STA_W, 0x0, 4GB)

gdtdsec:
	.word 0x0017
	.long gdt

.org 510
.word 0x55aa
