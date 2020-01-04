# boot.o: boot.S 
# 	gcc -E boot.S -o boot.i
# 	as -o boot.o boot.i
# 	ld -e start -Ttext=0x7c00 -o boot.img --oformat=binary boot.o
# run:
# 	rm -rf *.i *.o
# 	qemu-system-i386 -s -drive format=raw,file=boot.img

# EMPTY 	:=	  
# SPACE 	:=	$(EMPTY) $(EMPTY)
# SLASH	:= 	/

# all:
# 	echo $(SLASH)

GCCPREFIX := $(shell if objdump -i 2>&1 | grep 'elf32-i386' >/dev/null 2>&1; \
			then echo 'then echo 'i386-elf-';'; \
			else echo "***" 1>&2; \
			echo "*** Error: Couldn't find an i386-elf version of GCC/binutils." 1>&2; \
			echo "*** Is the directory with i386-elf-gcc in your PATH?" 1>&2; \
			echo "*** If your i386-elf toolchain is installed with a command" 1>&2; \
			echo "*** prefix other than 'i386-elf-', set your GCCPREFIX" 1>&2; \
			echo "*** environment variable to that prefix and run 'make' again." 1>&2; \
			echo "*** To turn off this error, run 'gmake GCCPREFIX= ...'." 1>&2; \
			echo "***" 1>&2;\
			exit 1;\
			fi)

run:
	@echo $(GCCPREFIX)