;=============================================================
; MUL9.ASM - Homework 4: multiplication and procedure calls
; Build: MASM MUL9.ASM;  LINK MUL9.OBJ;  MUL9
;=============================================================
.model small
.stack 100h

.data
    title_msg db 'The 9mul9 table:', 0dh, 0ah, '$'

.code
start:
    mov ax, @data
    mov ds, ax

    lea dx, title_msg
    mov ah, 09h
    int 21h

    call print_table          ; CALL pushes the return address

    mov ax, 4c00h
    int 21h

;-------------------------------------------------------------
; print_table
; Prints rows 9 down to 1.  Each row prints 1 through row.
; BL = current row, CL = current column.
; All registers used by this procedure are preserved.
;-------------------------------------------------------------
print_table proc near
    push ax
    push bx
    push cx
    push dx

    mov bl, 9

row_loop:
    mov cl, 1

column_loop:
    xor ax, ax
    mov al, bl
    mul cl                    ; AX = AL * CL (unsigned byte MUL)
    push ax                   ; save product while printing expression

    mov dl, bl
    add dl, '0'
    call print_char

    mov dl, '*'
    call print_char

    mov dl, cl
    add dl, '0'
    call print_char

    mov dl, '='
    call print_char

    pop ax
    call print_dec            ; print product in AX

    mov dl, ' '
    call print_char
    mov dl, ' '
    call print_char

    inc cl
    cmp cl, bl
    jbe column_loop

    call print_crlf
    dec bl
    jnz row_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret                       ; RET pops return address into IP
print_table endp

;-------------------------------------------------------------
; print_dec: print unsigned AX in decimal.
; Preserves AX, BX, CX and DX for its caller.
;-------------------------------------------------------------
print_dec proc near
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx

divide_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne divide_loop

digit_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop digit_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_dec endp

;-------------------------------------------------------------
; print_char: print the character in DL.  Preserves AX.
;-------------------------------------------------------------
print_char proc near
    push ax
    mov ah, 02h
    int 21h
    pop ax
    ret
print_char endp

;-------------------------------------------------------------
; print_crlf: start a new line.  Preserves AX and DX.
;-------------------------------------------------------------
print_crlf proc near
    push ax
    push dx

    mov dl, 0dh
    mov ah, 02h
    int 21h
    mov dl, 0ah
    mov ah, 02h
    int 21h

    pop dx
    pop ax
    ret
print_crlf endp

end start
