;=============================================================
;  sum.asm    作业题目3：求和 (DOS / MASM-TASM 风格)
;  基本要求：1+2+...+100 = 5050，打印到屏幕
;  进阶1：结果分别存于 寄存器 / 数据段 / 堆栈
;  进阶2：21H 中断输入 1~100 任意 n，输出十进制结果
;  编译：masm sum.asm;  link sum.obj;  sum.exe
;=============================================================
.model small
.stack 100h

.data
    msgMenu  db 0dh,0ah,'==== Sum Program ====',0dh,0ah
             db '1: Sum 1..100   (keep in REGISTER)',0dh,0ah
             db '2: Sum 1..100   (keep in DATA SEGMENT)',0dh,0ah
             db '3: Sum 1..100   (keep in STACK)',0dh,0ah
             db '4: Input n(1-100), Sum 1..n',0dh,0ah
             db '0: Exit',0dh,0ah
             db 'Choose: $'
    msgSum   db 0dh,0ah,'Sum = $'
    msgIn    db 0dh,0ah,'Please input n (1-100): $'
    msgErr   db 0dh,0ah,'Input error! (must be 1~100)$'
    msgReg   db 0dh,0ah,'AX(reg) = $'
    msgMem   db 0dh,0ah,'result(data seg) = $'
    msgStk   db 0dh,0ah,'pop from stack = $'
    crlf     db 0dh,0ah,'$'
    result   dw 0              ; 数据段：存放累加和
    n        dw 0              ; 数据段：存放输入的 n
    cnt      db 0              ; 输入位数计数

.code
start:
    mov ax, @data
    mov ds, ax

;====================== 主菜单 ======================
menu:
    lea dx, msgMenu
    mov ah, 09h
    int 21h

    mov ah, 01h                ; 01H：带回显读一个字符 -> al
    int 21h

    cmp al, '1'
    je  sum_reg
    cmp al, '2'
    je  sum_mem
    cmp al, '3'
    je  sum_stk
    cmp al, '4'
    je  sum_input
    cmp al, '0'
    jne menu
    jmp near ptr quit

;=========== 1) 累加和保存在【寄存器】 ===========
sum_reg:
    mov ax, 0                  ; ax 作累加器
    mov cx, 100
r_loop:
    add ax, cx                 ; ax = ax + cx  (100+99+...+1)
    loop r_loop
    push ax                    ; DOS 09H 会改写 AH，先保存求和结果
    lea dx, msgSum
    mov ah, 09h
    int 21h
    pop ax
    call print_dec             ; 打印 ax 中的十进制
    jmp menu

;=========== 2) 累加和保存在【数据段】 ===========
sum_mem:
    mov result, 0              ; 内存变量清零
    mov cx, 100
m_loop:
    mov ax, result
    add ax, cx
    mov result, ax             ; 结果写回数据段
    loop m_loop
    lea dx, msgSum
    mov ah, 09h
    int 21h
    mov ax, result
    call print_dec
    lea dx, msgMem
    mov ah, 09h
    int 21h
    mov ax, result
    call print_hex             ; 顺便看一下 5050 = 13BAH
    jmp menu

;=========== 3) 累加和保存在【堆栈】 ===========
sum_stk:
    mov ax, 0
    mov cx, 100
s_loop:
    add ax, cx
    loop s_loop
    push ax                    ; 结果压栈保存
    lea dx, msgSum
    mov ah, 09h
    int 21h
    pop ax
    push ax                    ; 保留一份结果供后面再次从栈中取出
    call print_dec
    lea dx, msgStk
    mov ah, 09h
    int 21h
    pop ax                     ; 从栈里弹出结果再打印一次
    call print_dec
    jmp menu

;=== 4) 21H 中断输入 n(1~100)，求 1..n 并十进制输出 ===
sum_input:
    lea dx, msgIn
    mov ah, 09h
    int 21h
    call read_dec              ; 读入十进制 -> bx，非法 CF=1
    jc  bad_input
    cmp bx, 1
    jb  bad_input
    cmp bx, 100
    ja  bad_input
    mov n, bx                  ; 保存到数据段

    mov ax, 0
    mov cx, n
i_loop:
    add ax, cx
    loop i_loop                ; ax = 1+2+...+n

    push ax                    ; DOS 09H 会改写 AH，先保存求和结果
    lea dx, msgSum
    mov ah, 09h
    int 21h
    pop ax
    call print_dec
    jmp menu

bad_input:
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
; 子程序：读十进制数(回车结束) -> bx，超出 0~999 或非法 CF=1
;-----------------------------------------------------
read_dec proc
    mov bx, 0
    mov cnt, 0
rd_in:
    mov ah, 01h
    int 21h
    cmp al, 0dh                ; 回车结束
    je  rd_ok
    inc cnt
    cmp cnt, 3                 ; 最多 3 位
    ja  rd_bad
    cmp al, '0'
    jb  rd_bad
    cmp al, '9'
    ja  rd_bad
    sub al, 30h
    mov ah, 0
    xchg bx, ax                ; bx=新数字, ax=原值
    mov dx, 10
    mul dx                     ; ax = 原值 * 10
    add bx, ax
    jmp rd_in
rd_ok:
    clc
    ret
rd_bad:
    stc
    ret
read_dec endp

;-----------------------------------------------------
; 子程序：十进制打印 ax（无符号）
;-----------------------------------------------------
print_dec proc
    mov bx, 10
    mov cx, 0
pd_loop:
    mov dx, 0
    div bx                     ; dx:ax / 10 -> 商 ax，余 dx
    push dx
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
; 子程序：十六进制打印 ax（4 位）——观察数据表示用
;-----------------------------------------------------
print_hex proc
    mov bx, ax
    mov cx, 4
ph_loop:
    rol bx, 1
    rol bx, 1
    rol bx, 1
    rol bx, 1
    mov ax, bx
    and al, 0fh
    call put_nib
    loop ph_loop
    mov dl, 'H'
    mov ah, 02h
    int 21h
    ret
print_hex endp

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
