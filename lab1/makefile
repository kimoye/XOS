boot.o: boot.s
	as -o boot.o boot.s
	ld -e start -Ttext=0x7c00 --oformat=binary -o boot.img  boot.o  
##objdump -d -m i8086 boot.o  16bit-objdump