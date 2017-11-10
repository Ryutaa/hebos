ipl: ipl.asm Makefile
	nasm -o ipl.bin ipl.asm

iplimg: ipl.bin hebos.img Makefile
	dd if=./ipl.bin of=hebos.img bs=512 count=1 conv=notrunc

sysimg: hebos.sys hebos.img Makefile
	dd if=./hebos.sys of=hebos.img bs=1 count=512 conv=notrunc seek=0x4200

sys: asmhead.asm Makefile
	nasm -o hebos.sys asmhead.asm

.PHONY: empty
empty:
	dd if=/dev/zero of=hebos.img bs=1024 count=1440
