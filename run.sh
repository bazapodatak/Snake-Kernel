#!/bin/bash
nasm -f elf32 boot.asm -o boot.o
ld -m elf_i386 -T linker.ld -o kernel.elf boot.o
mkdir -p isodir/boot/grub
cp kernel.elf isodir/boot/kernel.elf
cat > isodir/boot/grub/grub.cfg << 'GRUBEOF'
set timeout=0
set default=0
menuentry "Snake OS" {
    multiboot /boot/kernel.elf
    boot
}
GRUBEOF
grub-mkrescue -o snake.iso isodir 2>/dev/null
qemu-system-i386 -cdrom snake.iso
