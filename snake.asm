;setup
start:
    mov ax, 07C0h
    mov ds, ax

    jmp setup_game

;constants


;variables

;game logic

;bootsector padding
times 510-($-$$) db 0 ; pads the rest of the bootloader with 510 bytes, aiming for a 512 byte bootloader
dw 0xAA55 ; specifies the end of the bootloader, recognised by bios