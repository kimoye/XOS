#include "boot.h"

cga_addr = 0xb8000
cga_nber = 0x4000
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

cga_disp:
	cld
	call cga_clr
	movw $msg,%si
  	movb $0x7,%ah
	movl $cga_addr,%edx						
  	call cga_puts
  	jmp  c_call

# 打印字符串到屏幕
# 参数:
# %si: 待打印字符的起始地址
cga_puts:
  	lodsb
  	or 	 %al,%al
  	jz   cga_puts.1
  	movw %ax,%es:986(,%edx,1)						#986（偶数）意味这字符串显示的行数大约是正中间那行，我图吉利用这个数字
  	incl %edx
	incl %edx
  	jmp  cga_puts
cga_puts.1:
  	ret


#------------------Clear screen function----------------#
cga_clr:
	movl $cga_addr,%edi
	movw $0x0000,%ax
	movw $cga_nber,%cx
  	rep stosb
	ret

#------------------C语言入口----------------------------#
c_call:
	jmp .

#------------------指令无关域---------------------------#
msg:
.asciz	"Welcome to XOS: in protect mode!"

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
