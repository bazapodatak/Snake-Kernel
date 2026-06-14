MBALIGN  equ 1 << 0
MEMINFO  equ 1 << 1
FLAGS    equ MBALIGN | MEMINFO
MAGIC    equ 0x1BADB002
CHECKSUM equ -(MAGIC + FLAGS)

section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

section .bss
align 16
stack_bottom:
    resb 16384
stack_top:

section .data
snake_x:    times 400 dd 0
snake_y:    times 400 dd 0
snake_len:  dd 3
dir_x:      dd 1
dir_y:      dd 0
fruit_x:    dd 40
fruit_y:    dd 12
score:      dd 0
frame_count:dd 0
SPEED       equ 12000000
game_over_str: db "GAME OVER - SPACE TO RESTART", 0

section .text
global _start

_start:
    mov esp, stack_top
    mov dword [snake_x], 10
    mov dword [snake_y], 12
    mov dword [snake_x+4], 9
    mov dword [snake_y+4], 12
    mov dword [snake_x+8], 8
    mov dword [snake_y+8], 12
    call clear_screen

.game_loop:
    mov ecx, SPEED
.delay:
    loop .delay

    in al, 0x64
    test al, 1
    jz .handle_input
    in al, 0x60

    cmp al, 0x48
    jne .not_up
    cmp dword [dir_y], 1
    je .handle_input
    mov dword [dir_x], 0
    mov dword [dir_y], -1
    jmp .handle_input
.not_up:
    cmp al, 0x50
    jne .not_down
    cmp dword [dir_y], -1
    je .handle_input
    mov dword [dir_x], 0
    mov dword [dir_y], 1
    jmp .handle_input
.not_down:
    cmp al, 0x4B
    jne .not_left
    cmp dword [dir_x], 1
    je .handle_input
    mov dword [dir_x], -1
    mov dword [dir_y], 0
    jmp .handle_input
.not_left:
    cmp al, 0x4D
    jne .handle_input
    cmp dword [dir_x], -1
    je .handle_input
    mov dword [dir_x], 1
    mov dword [dir_y], 0

.handle_input:
    mov ecx, [snake_len]
    dec ecx
.shift_loop:
    mov eax, [snake_x + ecx*4 - 4]
    mov [snake_x + ecx*4], eax
    mov eax, [snake_y + ecx*4 - 4]
    mov [snake_y + ecx*4], eax
    loop .shift_loop

    mov eax, [dir_x]
    add [snake_x], eax
    mov eax, [dir_y]
    add [snake_y], eax

    mov eax, [snake_x]
    cmp eax, 0
    jl .game_over
    cmp eax, 80
    jge .game_over
    mov eax, [snake_y]
    cmp eax, 0
    jl .game_over
    cmp eax, 25
    jge .game_over

    mov ecx, 1
.self_col_loop:
    cmp ecx, [snake_len]
    jge .self_col_done
    mov eax, [snake_x]
    cmp eax, [snake_x + ecx*4]
    jne .self_col_next
    mov eax, [snake_y]
    cmp eax, [snake_y + ecx*4]
    je .game_over
.self_col_next:
    inc ecx
    jmp .self_col_loop

.self_col_done:
    mov eax, [snake_x]
    cmp eax, [fruit_x]
    jne .draw
    mov eax, [snake_y]
    cmp eax, [fruit_y]
    jne .draw

    inc dword [snake_len]
    add dword [score], 10
    
    mov eax, [frame_count]
    imul eax, eax, 214013
    add eax, 2531011
    mov [frame_count], eax
    shr eax, 16
    and eax, 127
    cmp eax, 80
    jge .gen_y
    mov [fruit_x], eax
.gen_y:
    mov eax, [frame_count]
    imul eax, eax, 214013
    add eax, 2531011
    mov [frame_count], eax
    shr eax, 16
    and eax, 31
    cmp eax, 25
    jge .draw
    mov [fruit_y], eax

.draw:
    call clear_screen

    mov eax, [fruit_y]
    mov ebx, 80
    mul ebx
    add eax, [fruit_x]
    mov edx, 0xB8000
    lea edx, [edx + eax*2]
    mov word [edx], 0x0C40

    mov ecx, 0
.draw_snake:
    cmp ecx, [snake_len]
    jge .draw_done
    
    mov eax, [snake_y + ecx*4]
    mov ebx, 80
    mul ebx
    add eax, [snake_x + ecx*4]
    mov edx, 0xB8000
    lea edx, [edx + eax*2]
    
    cmp ecx, 0
    jne .draw_body
    mov word [edx], 0x0A23
    jmp .draw_next
.draw_body:
    mov word [edx], 0x0A4F

.draw_next:
    inc ecx
    jmp .draw_snake

.draw_done:
    jmp .game_loop

.game_over:
    mov ecx, 0
    mov edx, 0xB8000
    add edx, (12 * 80 * 2) + (25 * 2)
    mov esi, game_over_str
.print_go:
    lodsb
    cmp al, 0
    je .wait_restart
    mov ah, 0x0C
    mov [edx], ax
    add edx, 2
    jmp .print_go

.wait_restart:
    in al, 0x64
    test al, 1
    jz .wait_restart
    in al, 0x60
    cmp al, 0x39
    jne .wait_restart

    mov dword [snake_len], 3
    mov dword [dir_x], 1
    mov dword [dir_y], 0
    mov dword [snake_x], 10
    mov dword [snake_y], 12
    mov dword [snake_x+4], 9
    mov dword [snake_y+4], 12
    mov dword [snake_x+8], 8
    mov dword [snake_y+8], 12
    mov dword [fruit_x], 40
    mov dword [fruit_y], 12
    mov dword [score], 0
    call clear_screen
    jmp .game_loop

clear_screen:
    mov ecx, 80 * 25
    mov edx, 0xB8000
    mov ax, 0x0720
.clear_loop:
    mov [edx], ax
    add edx, 2
    loop .clear_loop
    ret
