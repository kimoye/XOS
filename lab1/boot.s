##gas汇编教材：https://www.ibm.com/developerworks/cn/linux/l-gas-nasm.html

vga_sec = 0Xb800		            ##  这两个地址在看过清华教材后即可明白，如果有疑问可以参考os book
clear = 4000                        ##  见上

.code16                             ##  .code16 表示生成 16 位的机器码，这条指令在寻址的时候有用，此处可以略去。
cli                                 ##  禁止中断
mov %cs,%ax							# 习惯操作，重置段寄存器
mov %ax,%ds         				# 习惯操作，重置段寄存器
mov 0x4000, %ax						# the physical address loaded by the bootloader
mov %ax, %ss				
xor %sp,%sp							# 清除屏幕
call _boot          				# 调用_boot
ret                 				# 调用完返回
_boot:
	cld					# 清除标志寄存器
	mov $vga_sec,%bx
	mov %bx,%es
	xor %di,%di
	mov $0000,%ax
	mov $clear,%cx		# 清屏
	rep stosb

	mov $msg,%si		# 字符串的首地址传入到si寄存器
	mov $0x7,%ah		# 颜色设定
	mov $vga_sec,%bx
	mov %bx,%es
	mov $986,%edx		# 
	call _disp			# 输出字符
	ret
_disp:
	lodsb
	or %al,%al			# 检查是否完全打印完字符串
	jz _endprint
	mov %ax,%es:0(,%edx,2)
	incl %edx
	jmp _disp
	ret
_endprint:
	hlt




jmp .   ##此行可删除                              ##  . 指代当前的位置计数器 (location counter) ，指代汇编中的当前位置。

msg:
.asciz  "Welcome to XOS"              ##  定义字符串，通过二进制编辑器会发现其对于的ASCII码：想明白我为什么要说在个很重要

.org    510                           ##  .org 是 GAS 的一个伪指令，这一句会将位置计数器设置为 510 。
.word   0xaa55                        ##  .word 是 GAS 的一个伪指令，指的是位置寄存器之后的一个 word 值为 0xaa55 。