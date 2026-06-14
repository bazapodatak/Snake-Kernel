# Snake Game Kernel

# A minimalistic snake game written entirely in x86 assembly running directly on bare metal (no operating system required)

# Features

       - Classic snake gameplay mechanics
       - Random apple generation
       - Keyboard input handling (Arrow keys)
       - Collision detection (walls & self)
       - Runs on bare metal (bootable)
       - Fits in 3535 bytes

# Technical Details

    - Architecture: x86 32 bit protected mode
    - Assembler: NASM
    - Memory layout: 0x100000 kernel 0xB8000 video memory
    - Video mode: Text mode 80x25
    - Input: Direct Port I/O 0x60 and 0x64
    - Timing: Busy wait loops

 # Snake Data Structure
 
The snake is stored as two parallel arrays of 32 bit integers for x and y coordinates
- Snake X array holds 400 horizontal positions
- Snake Y array holds 400 vertical positions
- Snake length variable tracks current size
- Movement shifts array elements from tail to head then updates head coordinates

# Game Loop
1. Execute busy wait delay loop for game speed
2. Read keyboard controller port 0x60 for input
3. Shift snake body segments backwards in arrays
4. Update head position based on direction variables
5. Check wall and self collisions
6. Check apple collision and increase length if eaten
7. Generate new apple coordinates using linear congruential generator
8. Write background spaces to VGA memory at 0xB8000
9. Write apple character to VGA memory with red color attribute
10. Write snake head and body characters to VGA memory with green color attribute

# Collision Detection
- Wall collision check if head x is less than 0 or greater than 79
- Wall collision check if head y is less than 0 or greater than 24
- Self collision iterate through all body segments comparing x and y with head coordinates
- Apple collision compare head x and y with apple x and y coordinates

# Building and Running

# Prerequisites
- NASM (Netwide Assembler)
- LD (GNU Linker binutils)
- GRUB and grub mkrescue (for ISO creation)
- xorriso and mtools (ISO filesystem tools)
- QEMU (for emulation)

# Build

nasm -f elf32 boot.asm -o boot.o
ld -m elf_i386 -T linker.ld -o kernel.elf boot.o
mkdir -p isodir/boot/grub
cp kernel.elf isodir/boot/kernel.elf
grub-mkrescue -o snake.iso isodir
