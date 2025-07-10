;! for interrupts: http://employees.oneonta.edu/higgindm/assembly/DOS_AND_ROM_BIOS_INTS.htm

start:
    mov ax, 0900h
    mov ds, ax

    call refresh_screen

    ; set up head of snake
    mov byte [snake_x], 10
    mov byte [snake_y], 5

    jmp $

game_logic:
    ;move snake based on direction
    mov cx, [snake_body_count]
    mov si, 0

    call .move_snake

    ret

.move_snake:
    ;draw snake
    mov ah, 02h
    mov dl, [snake_x + si]
    mov dh, [snake_y + si]
    mov bh, 0
    int 10h

    mov ah, 0Eh
    mov al, '#'
    int 10h

    ;move snake
    add byte [snake_x + si], snake_horizontal_direction
    add byte [snake_y + si], snake_vertical_direction

    ;time delay

    mov ah, 86h
    mov cx, 0x0001      ; high 16 bits of 0x000186A0
    mov dx, 0x86A0      ; low 16 bits
    int 15h

    inc si
    loop .move_snake

    ret

refresh_screen:
    call clear_screen

    call draw_horizontal_borders

    call draw_vertical_borders
    ;set cursor to top left
    mov ah, 02h
    mov bh, 0
    mov dl, 0
    mov dh, 0
    int 10h

    call game_logic

    ret

draw_horizontal_borders:
    ;setting the cursor position for top bar

    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

    mov si, horizontal_border_string
    call print_string

    ;setting the cursor position for bottom bar
    mov ah, 02h
    mov bh, 0
    mov dl, 0
    mov dh, 18h
    int 10h
    
    mov si, horizontal_border_string
    call print_string

    ret

draw_vertical_borders:
    mov cx, 23
    mov dh, 1
.vertical_loop
    ; draw left vertical bar
    mov ah, 02h
    mov bh, 0
    mov dl, 0             ; left column
    ;mov dh, dh            ; current row
    int 10h

    mov ah, 0Eh
    mov al, '|'           ; character to draw
    int 10h

    mov ah, 02h
    mov bh, 0
    mov dl, 79
    int 10h

    mov ah, 0Eh
    int 10h

    inc dh 
    loop .vertical_loop
    ret

    
print_string:
    mov ah, 0Eh ; bios number 0Eh, sets for teletype output function
print_char:
    lodsb ; loads byte at SI, into AL and increments SI

    cmp al, 0 ; 0 stored in al if at end of string
    je printing_finished

    int 10h ;bios interrupt 0x10, to print char stored in AL

    jmp print_char
printing_finished:
    ret

clear_screen:
    mov ah, 06h       ; Scroll up function
    mov al, 0         ; 0 = scroll entire window (clear screen)
    mov bh, 07h       ; Attribute for blank lines (white text on black background)
    mov cx, 0         ; upper-left corner (row=0, col=0)
    mov dx, 184Fh     ; lower-right corner (row=24, col=79)
    int 10h
    ret
    
;constants
horizontal_border_string db '+-----------------------------------------------------------------------------+', 0
MAX_SNAKE_SIZE equ 64

;variables
snake_x times MAX_SNAKE_SIZE db 0
snake_y times MAX_SNAKE_SIZE db 0
snake_body_count db 1

snake_vertical_direction db 0
snake_horizontal_direction db 1

;game logic
times 2048-($-$$) db 0