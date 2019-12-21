boot1.o: boot.s
	as -o boot1.o boot.s
	ld -e 0 -Ttext=0x7c00 -o boot.bin --oformat=binaryobjdump boot.o