# 作业题目 4：乘法指令和过程调用

## 1. 作业要求

1. 输出九九乘法表。
2. 至少实现一次过程调用，正确使用 `CALL` 和 `RET`。
3. 过程需要使用主调程序的寄存器时，应保存并恢复寄存器。
4. 复习双重循环。
5. 用 C 语言实现，查看反汇编并添加注释。

汇编源程序：[MUL9.ASM](../../WORK/MUL9.ASM)

C 源程序：[mul9.c](../../WORK/MultiplyTableC/mul9.c)

## 2. 程序结构

主程序完成数据段初始化和标题输出，然后调用：

```asm
call print_table
```

`CALL` 会先把下一条指令的地址压入栈，再跳转到 `print_table`。过程末尾的 `RET` 从栈顶取回这个地址并送入 `IP`，程序由此回到 `CALL` 后面继续执行。

```text
主程序
  └─ CALL print_table
       ├─ 双重循环
       ├─ CALL print_char
       ├─ CALL print_dec
       └─ RET
```

## 3. 寄存器保存和恢复

`print_table` 会使用 `AX、BX、CX、DX`，因此入口处保存：

```asm
push ax
push bx
push cx
push dx
```

返回前必须按相反顺序恢复：

```asm
pop dx
pop cx
pop bx
pop ax
ret
```

这里的顺序不允许写乱。栈是“后进先出”，先压入的 `AX` 必须最后弹出。`print_dec`、`print_char` 和 `print_crlf` 也分别保护了自己会改变的寄存器。

## 4. 双重循环与 MUL 指令

- `BL` 保存外层行号，从 9 递减到 1。
- `CL` 保存内层列号，从 1 递增到当前行号。
- `MUL CL` 是 8 位无符号乘法，隐含被乘数为 `AL`，结果放入 `AX`。

```asm
xor ax, ax
mov al, bl
mul cl              ; AX = AL × CL
```

例如 `BL=9、CL=8` 时，执行后 `AX=72`。由于结果可能是两位十进制数，程序调用 `print_dec` 完成十进制转换和输出，而不能简单地加 `'0'`。

## 5. 编译和运行

在 DOSBox 中执行：

```dos
mount d d:\8086
d:
path d:\masm
cd work
masm mul9.asm;
link mul9.obj;
mul9
```

修改源代码后必须重新执行汇编和链接，旧的 EXE 不会自动更新。

## 6. DEBUG 观察过程调用

```dos
debug mul9.exe
u
r
t
p
q
```

- 在 `CALL` 前用 `r` 记下 `SP`。
- 用 `t` 执行 `CALL`，可观察到 `SP` 减 2，因为返回地址被压栈。
- 进入过程后继续用 `t`，可以观察各条 `PUSH` 对 `SP` 的影响。
- 遇到不想逐条进入的子程序可用 `p` 整体执行。
- 执行到 `RET` 后，`IP` 回到 `CALL` 的下一条指令。

## 7. C 语言版本与反汇编

C 程序同样使用两层 `for` 循环，并把打印乘法表封装为 `print_table()`，由 `main()` 调用。用 Visual Studio 选择 `Debug | Win32`，在 `print_table();` 处设置断点，然后打开“调试 → 窗口 → 反汇编”。

关闭优化后，关键 x86 结构可概括为：

```asm
call _print_table       ; main 调用过程
mov  row, 9
cmp  row, 1
jl   table_end          ; 外层条件 row >= 1
mov  column, 1
cmp  column, row
jg   row_end            ; 内层条件 column <= row
imul eax, column        ; row * column
call _printf
add  column, 1
jmp  column_test
sub  row, 1
jmp  row_test
ret                     ; 返回 main
```

- C 编译器常用 `IMUL`，而手写 8086 程序按题目使用 `MUL`。
- `CMP` 配合 `JL/JG` 实现两层循环条件。
- `CALL _printf` 对应格式化输出。
- 这是 Visual Studio 生成的现代 32 位 x86 汇编，不等同于 16 位 8086，但过程调用和条件跳转的基本思想相同。

## 8. 预期结果

```text
The 9mul9 table:
9*1=9  9*2=18  ...  9*9=81
8*1=8  8*2=16  ...  8*8=64
...
1*1=1
```

完整实测输出见 [`results/mul9.txt`](../../results/mul9.txt) 和 [`results/mul9-c.txt`](../../results/mul9-c.txt)。
