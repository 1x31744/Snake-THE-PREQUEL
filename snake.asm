;! for interrupts: http://employees.oneonta.edu/higgindm/assembly/DOS_AND_ROM_BIOS_INTS.htm

start:
    mov ax, 0900h
    mov ds, ax

    ; set up head of snake
    mov byte [snake_x], 10
    mov byte [snake_y], 5
    mov byte [snake_x + 1], 10
    mov byte [snake_y + 1], 4
    mov byte [snake_body_count], 2

.main_loop:
    call refresh_screen
    jmp .main_loop

get_random_number:
    mov ah, 00h
    int 1Ah

    ;move time to ax in order to perfom division
    mov ax, dx

    ;bx will contain max number
    ;horizontal = 78
    ;vertical = 23
    xor dx, dx
    div bx

    add dl, 1
    ret

game_logic:
; Drain the buffer to get the most recent key
.read_keys:
    mov ah, 01h        ; Check if key available
    int 16h
    jz .no_keys        ; No key in buffer? skip

    ; Get key from buffer
    mov ah, 00h
    int 16h            ; AL = ASCII char

    ; store last key seen
    mov byte [latest_key], al
    jmp .read_keys     ; keep draining

.no_keys:
    mov al, [latest_key]
    cmp al, 'w'
    je .go_up
    cmp al, 's'
    je .go_down
    cmp al, 'a'
    je .go_left
    cmp al, 'd'
    je .go_right

.go_up:
    cmp byte [snake_vertical_direction], 1
    je .finish_input
    mov byte [snake_vertical_direction], -1
    mov byte [snake_horizontal_direction], 0
    jmp .finish_input

.go_down:
    cmp byte [snake_vertical_direction], -1
    je .finish_input
    mov byte [snake_vertical_direction], 1
    mov byte [snake_horizontal_direction], 0
    jmp .finish_input

.go_left:
    cmp byte [snake_horizontal_direction], 1
    je .finish_input
    mov byte [snake_horizontal_direction], -1
    mov byte [snake_vertical_direction], 0
    jmp .finish_input

.go_right:
    cmp byte [snake_horizontal_direction], -1
    je .finish_input
    mov byte [snake_horizontal_direction], 1
    mov byte [snake_vertical_direction], 0

.finish_input:
    mov si, 0

.snake_loop:
    jmp .head_logic
    cmp si, 0
    jne .body_logic
.head_logic
    mov al, [snake_horizontal_direction]
    mov ah, [snake_vertical_direction]
    add byte [snake_x + si], al
    add byte [snake_y + si], ah

    mov bl, [snake_x]
    mov bh, [snake_y]

    mov byte [snake_head_x], bl
    mov byte [snake_head_y], bh
    mov byte [previous_snake_part_x], bl
    mov byte [previous_snake_part_y], bh

    jmp .draw_logic

.body_logic
    ; store current part's coords in temp
    mov al, [snake_x + si]
    mov ah, [snake_y + si]

    ; move previous part into current
    mov bl, [previous_snake_part_x]
    mov bh, [previous_snake_part_y]
    mov byte [snake_x + si], bl
    mov byte [snake_y + si], bh

    ; now update previous to the old value of this segment
    mov byte [previous_snake_part_x], al
    mov byte [previous_snake_part_y], ah


.draw_logic

    ;draw snake
    mov ah, 02h
    mov dl, [snake_x + si]
    mov dh, [snake_y + si]
    mov bh, 0
    int 10h

    mov ah, 09h
    mov al, '#'
    mov bh, 0
    mov bl, 0x07 ; white on black
    mov cx, 1
    int 10h

    inc si

    xor cx, cx
    mov cl, [snake_body_count]
    cmp si, cx
    jb .snake_loop

    ret

refresh_screen:
    call clear_screen

    call draw_horizontal_borders

    call draw_vertical_borders

    call game_logic

    ;time delay

    mov ah, 86h
    mov cx, 0x0011      ; high 16 bits of 0x000186A0    ;set cursor to top left
    mov dx, 0x86A0      ; low 16 bits
    int 15h

    ;set cursor to top left
    mov ah, 02h
    mov bh, 0
    mov dl, 0
    mov dh, 0
    int 10h

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
snake_body_count db 3

snake_vertical_direction db 0
snake_horizontal_direction db 1

previous_snake_part_x db 0
previous_snake_part_y db 0

snake_head_x db 0
snake_head_y db 0

latest_key db 0

;game logic
times 2048-($-$$) db 0