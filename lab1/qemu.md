# XOS：X Operate System
## Qemu的使用

![Lisence](https://img.shields.io/badge/License-GPL-green)
![Author0](https://img.shields.io/badge/Author-kimoye-red)
![Author1](https://img.shields.io/badge/Author-Lynn-red)
![Author2](https://img.shields.io/badge/Author-MAX-red)
## qemu和gdb初步教程
## 引导
计算机启动之后， BIOS (Basic Input Output System) 会对设备进行简单的自检。确认一切正常后，就开始引导启动操作系统软件了。

BIOS 会在硬盘（或软盘）的首个柱面、首个磁头、首个扇区的 512 个字节去寻找引导代码。 BIOS 并不能辨别这 512 个字节究竟是数据还是可执行机器码，它只会去检查 512 个字节的最后两个字节是不是 0xaa55 ，并以此辨别当前设备是否可引导。因此，留给我们可编程的一共只有 510 个字节，我们需要确保编译出来的机器码小于等于 510 个字节。

万事俱备，着手写一个最简单的程序，为之后的引导程序打下基础：

```java
.code16

jmp .

.org 510

.word 0xaa55
 
```

> 第一行 .code16 表示生成 16 位的机器码，这条指令在寻址的时候有用，此处可以略去。

> GAS 中 . 指代当前的位置计数器 (location counter) ，指代汇编中的当前位置。

> 之后的 .org 是 GAS 的一个伪指令，这一句会将位置计数器设置为 510 。

> 最后的 .word 是 GAS 的一个伪指令，指的是位置寄存器之后的一个 word 值为 0xaa55 。

##编译与链接
```java
as -o boot.o boot.s
ld -e 0 -Ttext=0x7c00 -o boot.img --oformat=binary boot.o
```
生成引导块。

其中 as 命令中 -o 指输出文件名，剩下的都是输入的汇编文件名。

ld 命令中 -e (--entry) 指明程序入口，这里是偏移 0 。 -o (--output) 指明输出文件名， --oformat 指明输出格式，默认为 elf64-x86-64 ，此处生成纯二进制机器码文件 。 -Ttext 是指定 text 段的位置，如果有需要重定位的则需要这一条，这里其实可以略去，此处其值为 BIOS 加载我们引导程序的位置，也就是 0x7c00 。

然后就可以使用 qemu 欢快地运行啦！

使用命令
```java

qemu-system-i386 boot.img
```
就可以直接模拟运行我们的引导， boot.img 会被作为硬盘载入，默认为 raw 二进制格式。

如果嫌警告烦人的话，可以显式指定为 raw boot sector ： qemu-system-i386 -drive format=raw,file=boot.img

如果成功引导的话，在尝试从 Hard Disk 读取引导之后就什么都不会输出，因为我们写了一段死循环在里面。如果失败的话， QEmu 模拟的 BIOS 会继续尝试从 Floppy 、 DVD/CD 、 ROM 、 Network 引导，不过当然，都会失败。

至此，我们的第一个什么都不干的引导就完成了。

##调试
乘现在我们的引导程序还简单，我们来试试看用 GDB 调试我们的引导。

第一步，我们需要使 QEmu 可以和 GDB 交互，我们让 QEmu 在运行的时候监听一个 TCP 端口即可， QEmu 提供了一个简易的运行选项 -s 来帮我们监听端口 1234 。当然我们也可以自己指定协议和端口，甚至支持本地 unix socket 和管道。关于自定义端口的方法详见手册，本文简单起见，直接使用 -s 选项运行。

使用如下命令启动 QEmu ：
```java

qemu-system-i386 -s -drive format=raw,file=boot.img
```
启动 GDB 并连接上 1234 端口：
```java
target remote :1234
```
如果看到 Qemu 窗口出现了 QEMU [PAUSED] 字样，则说明连接成功， GDB 中应该出现了我们写在 boot.s 中的汇编指令（虽说有点区别），这里开始就可以在 GDB 里和调试普通程序一般调试引导了。

按理来说 GDB 的输出是：
```

0x00007c00 in ?? ()=> 0x00007c00:
eb fe jmp 0x7c00
```

可以看到，这时候我们的引导程序被加载到了 0x7c00 的位置，并且不停在 jmp 回当前位置。

但是实际上，我们是在程序运行期间暴力 attach 上去的。在引导程序变得复杂之后，想要调试引导程序不可能在 QEmu 一通乱跑之后才 attach，为此我们需要在启动 QEmu 之后立刻停止运行，等待指令。为此， QEmu 提供了运行选项 -S 。

使用 -S 启动 QEmu 的命令：
```
qemu-system-i386 -S -s -drive format=raw,file=boot.img
```
运行 GDB ，在 0x7c00 地址下断点（当然你也可以不下断点，跟着流程一步一步走下去看看 BIOS 自检的过程）：
```

target remote :1234
break *0x7c00
continue
```
这样就可以从头开始调试了， GDB 的其它调试指令请自行查阅相关资料。
```

Hello, World!
```
准备完毕！既然我们让第一个 boot 跑起来了，第一件事情当然是：
```

Hello, World!
```

于是问题来了，在 POSIX 系统下我们用内核提供的系统调用 write 可以向 STDOUT 输出一串字符，可是在这个什么都没有的机器上，我们该怎么告诉屏幕：”我要打印一串字符啦“？

这时候就需要 BIOS 来帮忙了。 试想， BIOS 在启动的时候帮我们初始化检查了所有的设备，它应当知道各个设备都是些什么东西，如果知道怎么使用这些设备自然就更好了。

中断
CPU 使用硬件异常来和外部设备进行交互，这里的异常和高级语言程序设计中的异常大不相同。硬件异常分为中断、陷阱等。中断可以由软件使用 int 指令主动产生，称其为软中断。在（无论什么原因）产生中断之后， CPU 会从中断向量表 (Interrupt vector) 中取出中段号对应的值，也就是中断处理函数 (Interrupt handler 或 Interrupt service routine, 即 ISR) 的地址，并通过中断处理函数处理中断。事实上，x86 中进行系统调用就是由软件产生软中断，把控制权交给由内核指定的 ISR 处理。

利用 BIOS 写屏
BIOS 控制了中断向量表中的第 0x10 号位置来提供写屏的操作，我们想在实模式下写屏，可以手动唤起一个 0x10 中断利用 BIOS 提供的服务。不过在此之前，我们要准备好需要交给 BIOS 的参数，将其放置于寄存器 ax 中。

当寄存器 ax 的高位 (ah) 为 0xe 的时候， BIOS 会帮我们通知显示屏进行一次打印，打印的字符为寄存器 ax 的低位 (al) 。

汇编如下（考虑到篇幅，此处只输出一部分）：
```java

.code16

movb $0xe, %ah
movb $'H', %al
int $0x10
movb $'e', %al
int $0x10
movb $'l', %al
int $0x10
movb $'l', %al
int $0x10
movb $'o', %al
int $0x10
movb $'!', %al
int $0x10

jmp .
.org 510
.word 0xaa55
```
这样，屏幕上就应该有一行 Hello! 了。