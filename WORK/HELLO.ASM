.model small
.stack 100h

.data
message db 'Hello world!', 0dh, 0ah, '$'

.code
start:
    mov ax, @data
    mov ds, ax

    lea dx, message
    mov ah, 09h
    int 21h

    mov ax, 4c00h
    int 21h

end start