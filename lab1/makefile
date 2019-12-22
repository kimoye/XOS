boot.o: boot.S 
	gcc -E boot.S -o boot.i
	as -o boot.o boot.i
	ld -e start -Ttext=0x7c00 -o boot.img --oformat=binary boot.o
run:
	rm -rf *.i *.o
	qemu-system-i386 -s -drive format=raw,file=boot.img