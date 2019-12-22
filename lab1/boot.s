#include "boot.h"

vga_addr = 0xb8000
vga_nber = 0x4000
PROT_MODE_CSEG = 0x8
PROT_MODE_DSEG = 0x10

.global start
start:
	.code16
	cli						#关中断，网上学的
	cld						#清楚方向标志，网上学的
	
	#清零段寄存器
	xorw	%ax,%ax
	movw	%ax,%ds
	movw	%ax,%es
	movw	%ax,%ss
	xorw	%sp,%sp

#打开A20
seta20.1:
	inb		$0x64,%al		#等待端口不忙
	testb	$0x2, %al 		#如果al第2位为0就不执行跳转
	jnz		seta20.1
	movb	$0xd1,%al		#0xd1 --> port 0x64
	outb 	%al, $0x64
seta20.2:
	inb 	$0x64,%al
	testb	$0x2, %al
	jnz		seta20.2
	movb	$0xdf,%al
	outb	%al,$0x60
	
	lgdt	gdtdsec			#load gdt

	movl	%cr0, %eax
	orl 	$0x1, %eax 		#打开保护模式
	movl	%eax, %cr0

	ljmp 	$PROT_MODE_CSEG, $protcseg

.code32
protcseg:
	movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS:Flag Segment
    movw %ax, %gs                                   # -> GS:
    movw %ax, %ss                                   # -> SS: Stack Segment

    #设置栈指针， 进入C语言. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    movl $start, %esp

disp:
  movl $msg, %edi
  call puts
  jmp  c_boot

# 打印字符串到屏幕
# 参数:
# %edi: 待打印字符的起始地址
puts:
  call clear
  xorl %ecx, %ecx
puts.0:
  movb (%edi,%ecx), %dl
  test %dl, %dl
  jz   puts.1
  movb $0xf, %dh
  movw %dx, (%ebx,%ecx,2)
  incl %ecx
  jmp  puts.0
puts.1:
  ret

# Clear screen.
clear:
  xorl %ecx, %ecx
  movl $0xb8000, %ebx
clear.0:
  movl $0x0f200f20, (%ebx,%ecx,4)
  incl %ecx
  cmpl $1000, %ecx
  jl   clear.0
  ret
c_boot:
	jmp .
#------------------指令无关域---------------------------#
msg:
.asciz	"Welcome to XOS(protect mode)!"

.p2align 2
gdt:
	SEG_NULL
	SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)
	SEG_ASM(STA_W, 0x0, 0xffffffff)

gdtdsec:
	.word .-gdt-1
	.long gdt

.org 510
.byte 0x55
.byte 0xaa
