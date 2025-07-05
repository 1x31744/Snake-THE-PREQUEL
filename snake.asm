;! for interrupts: http://employees.oneonta.edu/higgindm/assembly/DOS_AND_ROM_BIOS_INTS.htm

start:
    mov ax, 07C0h
    mov ds, ax

    call refresh_screen

    jmp $

refresh_screen:
    call clear_screen

    call draw_top_border

    ret

draw_top_border:
    ;setting the cursor position

    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

    mov si, horizontal_border_string
    call print_string

print_string:
    lodsb
    cmp al, 0
    je done_printing
    mov ah, 0Eh
    int 10h
    jmp print_string
done_printing:
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
horizontal_border_string db 'Hello World!', 0
;variables

;game logic
times 2048-($-$$) db 0