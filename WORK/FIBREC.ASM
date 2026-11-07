;====================================================================
; FIBREC.ASM - Homework 5: recursive Fibonacci sequence
; Input : n (1..100)
; Output: F(0) through F(n-1), exactly (no 16-bit overflow)
; Build : MASM FIBREC.ASM;  LINK FIBREC.OBJ;  FIBREC
;====================================================================
.model small
.stack 1000h

LIMBS equ 6
BASE  equ 10000

.data
    prompt       db 'Input n (1-100): $'
    sequence_msg db 0dh, 0ah, 'Fibonacci sequence:', 0dh, 0ah, '$'
    error_msg    db 0dh, 0ah, 'Input error: n must be 1..100.', 0dh, 0ah, '$'
    newline      db 0dh, 0ah, '$'
    digit_count  db 0

    ; A big integer is six little-endian words in base 10000.
    ; Six limbs hold up to 24 decimal digits; F(99) has 21 digits.
    fib_a        dw LIMBS dup(0)
    fib_b        dw 1, 5 dup(0)
    fib_next     dw LIMBS dup(0)

.code
start:
    mov ax, @data
    mov ds, ax

    lea dx, prompt
    mov ah, 09h
    int 21h

    call read_n                 ; BX = n, CF = 1 if invalid
    jc invalid_input
    cmp bx, 1
    jb invalid_input
    cmp bx, 100
    ja invalid_input

    lea dx, sequence_msg
    mov ah, 09h
    int 21h

    mov cx, bx                  ; recursion count
    call print_sequence

    lea dx, newline
    mov ah, 09h
    int 21h
    jmp program_exit

invalid_input:
    lea dx, error_msg
    mov ah, 09h
    int 21h

program_exit:
    mov ax, 4c00h
    int 21h

;--------------------------------------------------------------------
; print_sequence (recursive)
; Input : CX = number of terms still to print (1..100)
; State : fib_a = current term, fib_b = next term
; Saves : every general-purpose register used by the procedure
;
; Each active recursion level keeps:
;   return address 2 bytes + six saved registers 12 bytes = 14 bytes.
;--------------------------------------------------------------------
print_sequence proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    call print_big_a
    mov dl, ' '
    call print_char

    dec cx
    jz sequence_return

    call advance_fibonacci
    call print_sequence          ; recursive call with CX - 1

sequence_return:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_sequence endp

;--------------------------------------------------------------------
; advance_fibonacci
; fib_next = fib_a + fib_b, fib_a = fib_b, fib_b = fib_next
; Addition is performed limb by limb in base 10000.
;--------------------------------------------------------------------
advance_fibonacci proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    xor si, si
    mov cx, LIMBS
    xor dx, dx                  ; DX is carry: 0 or 1

add_limb:
    mov ax, fib_a[si]
    add ax, fib_b[si]
    add ax, dx
    xor dx, dx
    cmp ax, BASE
    jb limb_ready
    sub ax, BASE
    mov dx, 1

limb_ready:
    mov fib_next[si], ax
    add si, 2
    loop add_limb

    xor si, si
    mov cx, LIMBS

copy_limb:
    mov ax, fib_b[si]
    mov fib_a[si], ax
    mov ax, fib_next[si]
    mov fib_b[si], ax
    add si, 2
    loop copy_limb

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
advance_fibonacci endp

;--------------------------------------------------------------------
; print_big_a
; Prints fib_a as decimal.  The highest limb has no leading zeroes;
; every lower base-10000 limb is printed as exactly four digits.
;--------------------------------------------------------------------
print_big_a proc near
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, 10                  ; offset of limb 5

find_high_limb:
    mov ax, fib_a[si]
    cmp ax, 0
    jne high_limb_found
    cmp si, 0
    je print_big_zero
    sub si, 2
    jmp find_high_limb

print_big_zero:
    mov dl, '0'
    call print_char
    jmp print_big_done

high_limb_found:
    call print_word

print_lower_limbs:
    cmp si, 0
    je print_big_done
    sub si, 2
    mov ax, fib_a[si]
    call print_four_digits
    jmp print_lower_limbs

print_big_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_big_a endp

;--------------------------------------------------------------------
; print_word: print unsigned AX without unnecessary leading zeroes.
;--------------------------------------------------------------------
print_word proc near
    push ax
    push bx
    push cx
    push dx

    cmp ax, 0
    jne word_convert
    mov dl, '0'
    call print_char
    jmp word_done

word_convert:
    mov bx, 10
    xor cx, cx

word_divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne word_divide

word_output:
    pop dx
    add dl, '0'
    call print_char
    loop word_output

word_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_word endp

;--------------------------------------------------------------------
; print_four_digits: print AX as exactly four decimal digits.
;--------------------------------------------------------------------
print_four_digits proc near
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    mov cx, 4

four_divide:
    xor dx, dx
    div bx
    push dx
    loop four_divide

    mov cx, 4

four_output:
    pop dx
    add dl, '0'
    call print_char
    loop four_output

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_four_digits endp

;--------------------------------------------------------------------
; print_char: print DL through DOS INT 21H/AH=02H.  Preserves AX.
;--------------------------------------------------------------------
print_char proc near
    push ax
    mov ah, 02h
    int 21h
    pop ax
    ret
print_char endp

;--------------------------------------------------------------------
; read_n: read 1-3 decimal digits until Enter.
; Output: BX = value, CF = 0 if syntax is valid; CF = 1 otherwise.
;--------------------------------------------------------------------
read_n proc near
    push ax
    push cx
    push dx

    xor bx, bx
    mov digit_count, 0

read_key:
    mov ah, 01h
    int 21h
    cmp al, 0dh
    je read_finished
    cmp al, 0ah                  ; also accept LF from redirected test files
    je read_finished

    inc digit_count
    cmp digit_count, 3
    ja read_invalid
    cmp al, '0'
    jb read_invalid
    cmp al, '9'
    ja read_invalid

    sub al, '0'
    mov ah, 0
    push ax                     ; save new digit
    mov ax, bx
    mov dx, 10
    mul dx                      ; old value * 10
    mov bx, ax
    pop ax
    add bx, ax
    jmp read_key

read_finished:
    cmp digit_count, 0
    je read_invalid
    clc
    jmp read_return

read_invalid:
    stc

read_return:
    pop dx
    pop cx
    pop ax
    ret
read_n endp

end start
