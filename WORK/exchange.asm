;=============================================================
;  exchange.asm   进制转换程序 (DOS / MASM-TASM 风格)
;  基本要求：输入 1~2 位十六进制数 -> 输出对应十进制数
;  追加要求：十进制 -> 十六进制
;  编译：masm exchange.asm;  link exchange.obj;  exchange.exe
;=============================================================
.model small
.stack 100h

.data
    msgMenu   db 0dh,0ah,'---- Number Exchange ----',0dh,0ah
              db '1: Hex -> Dec',0dh,0ah
              db '2: Dec -> Hex',0dh,0ah
              db '0: Exit',0dh,0ah
              db 'Choose: $'
    msgHexIn  db 0dh,0ah,'Please input a Hex number: $'
    msgDecIn  db 0dh,0ah,'Please input a Dec number: $'
    msgDecOut db 0dh,0ah,'The Dec number: $'
    msgHexOut db 0dh,0ah,'The Hex number: $'
    msgErr    db 0dh,0ah,'Input error! $'
    crlf      db 0dh,0ah,'$'
    cnt       db 0              ; 已输入字符个数

.code
start:
    mov ax, @data
    mov ds, ax

;====================== 主菜单 ======================
menu:
    lea dx, msgMenu
    mov ah, 09h
    int 21h

    mov ah, 01h                 ; 读一个选择字符（带回显）
    int 21h

    cmp al, '1'
    je  hex2dec
    cmp al, '2'
    je  dec2hex
    cmp al, '0'
    jne menu
    jmp near ptr quit

;=============== 1) 十六进制 -> 十进制 ===============
hex2dec:
    lea dx, msgHexIn
    mov ah, 09h
    int 21h

    mov bx, 0                   ; bx = 累加结果
    mov cnt, 0

h2d_in:
    mov ah, 01h                 ; 逐字符输入，回车结束
    int 21h
    cmp al, 0dh
    je  h2d_done

    inc cnt
    cmp cnt, 4                  ; 最多 4 位（0~FFFFH）
    ja  error

    call hex_val                ; al: 字符 -> 数值，非法则 CF=1
    jc  error

    mov ah, 0
    xchg bx, ax                 ; bx=新数字, ax=原累加值
    mov cl, 4
    shl ax, cl                  ; ax = 原值 * 16
    add bx, ax                  ; bx = 原值*16 + 新数字
    jmp h2d_in

h2d_done:
    lea dx, msgDecOut
    mov ah, 09h
    int 21h
    mov ax, bx
    call print_dec              ; 打印十进制
    jmp menu

;=============== 2) 十进制 -> 十六进制 ===============
dec2hex:
    lea dx, msgDecIn
    mov ah, 09h
    int 21h

    mov bx, 0                   ; bx = 累加结果
    mov cnt, 0

d2h_in:
    mov ah, 01h
    int 21h
    cmp al, 0dh
    je  d2h_done

    inc cnt
    cmp cnt, 5                  ; 最多 5 位（0~65535）
    ja  error
    cmp al, '0'
    jb  error
    cmp al, '9'
    ja  error

    sub al, 30h
    mov ah, 0
    xchg bx, ax                 ; bx=新数字, ax=原累加值
    mov cx, 10
    mul cx                      ; ax = 原值 * 10
    add bx, ax                  ; bx = 原值*10 + 新数字
    jmp d2h_in

d2h_done:
    lea dx, msgHexOut
    mov ah, 09h
    int 21h
    mov ax, bx
    call print_hex              ; 打印十六进制
    jmp menu

error:
    lea dx, msgErr
    mov ah, 09h
    int 21h
    jmp menu

quit:
    lea dx, crlf
    mov ah, 09h
    int 21h
    mov ax, 4c00h
    int 21h

;-----------------------------------------------------
; 子程序：hex 字符 -> 数值 (al 进出)，非法字符 CF=1
;-----------------------------------------------------
hex_val proc
    cmp al, '0'
    jb  hv_bad
    cmp al, '9'
    jbe hv_digit                ; '0'~'9'
    cmp al, 'A'
    jb  hv_lower
    cmp al, 'F'
    jbe hv_upper                ; 'A'~'F'
hv_lower:
    cmp al, 'a'
    jb  hv_bad
    cmp al, 'f'
    ja  hv_bad
    sub al, 57h                 ; 'a' -> 0Ah
    clc
    ret
hv_upper:
    sub al, 37h                 ; 'A' -> 0Ah
    clc
    ret
hv_digit:
    sub al, 30h
    clc
    ret
hv_bad:
    stc
    ret
hex_val endp

;-----------------------------------------------------
; 子程序：以十进制打印 ax 中的无符号数
;-----------------------------------------------------
print_dec proc
    mov bx, 10
    mov cx, 0
pd_loop:
    mov dx, 0
    div bx                      ; dx:ax / 10 -> 商ax 余dx
    push dx                     ; 余数入栈
    inc cx
    cmp ax, 0
    jne pd_loop
pd_out:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop pd_out
    ret
print_dec endp

;-----------------------------------------------------
; 子程序：以十六进制（4 位）打印 ax 中的数
;-----------------------------------------------------
print_hex proc
    mov bx, ax                  ; bx 保存待输出的 16 位数
    mov cx, 4                   ; 共输出 4 个十六进制位
ph_loop:
    rol bx, 1
    rol bx, 1
    rol bx, 1
    rol bx, 1                   ; 每次把下一个高位半字节转到低 4 位
    mov ax, bx
    and al, 0fh
    call put_nib
    loop ph_loop
    ret
print_hex endp

;-----------------------------------------------------
; 子程序：打印 al 中的 1 位十六进制数
;-----------------------------------------------------
put_nib proc
    cmp al, 9
    ja  pn_letter
    add al, 30h
    jmp pn_show
pn_letter:
    add al, 37h
pn_show:
    mov dl, al
    mov ah, 02h
    int 21h
    ret
put_nib endp

end start
