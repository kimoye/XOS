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



.p2align 2
gdt:
	
