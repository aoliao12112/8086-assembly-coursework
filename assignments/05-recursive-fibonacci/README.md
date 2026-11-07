# 作业题目 5：递归调用——Fibonacci 数列

## 一、作业要求

斐波那契数列满足：

```text
F(n) = F(n-1) + F(n-2)
F(0) = 0，F(1) = 1
```

本次作业要求：

1. 从键盘输入 `n`，其中 `1≤n≤100`。
2. 输出前 `n` 个斐波那契数，即 `F(0)` 到 `F(n-1)`。
3. 使用递归实现。
4. 过程使用寄存器，并正确保存与恢复。
5. 初始化足够的栈空间，分析 Stack Overflow 风险。
6. 用 DEBUG 单步观察递归调用和返回时的栈变化。
7. 编写 C 版本并查看、注释反汇编。

相关文件：

- [8086 汇编源程序 FIBREC.ASM](../../WORK/FIBREC.ASM)
- [C 源程序 fibonacci.c](../../WORK/FibonacciC/fibonacci.c)
- [汇编版测试记录](../../results/fibonacci-recursive.txt)
- [C 版测试记录](../../results/fibonacci-c.txt)

## 二、设计选择

### 1. 为什么不能只用 AX

`AX` 是 16 位寄存器，无符号最大值为 `65535`，而：

```text
F(24) = 46368
F(25) = 75025
```

从 `F(25)` 开始就会发生 16 位溢出。题目要求最多输出前 100 项，因此不能让结果自然回绕后仍宣称程序正确。

程序把一个大整数表示为 6 个小端排列的字，每个字保存 `0..9999`：

```asm
LIMBS equ 6
BASE  equ 10000

fib_a    dw LIMBS dup(0)
fib_b    dw 1, 5 dup(0)
fib_next dw LIMBS dup(0)
```

6 个“万进制”数位可以表示 24 位十进制数，足以容纳 21 位的 `F(99)`。例如：

```text
F(99) = 218922995834555169026
高位显示：2 | 1892 | 2995 | 8345 | 5516 | 9026
内存顺序：9026, 5516, 8345, 2995, 1892, 2
```

### 2. 为什么没有直接使用低效的双分支递归

直接照公式计算：

```text
fib(n) = fib(n-1) + fib(n-2)
```

会反复计算相同子问题，运行时间呈指数增长，`n=100` 在 DOS 环境中基本不可执行。本程序采用线性递归：每一层输出当前项、计算下一项，然后递归处理剩余项。

```text
print_sequence(remaining):
    输出 fib_a
    如果 remaining > 1：
        (fib_a, fib_b) = (fib_b, fib_a + fib_b)
        print_sequence(remaining - 1)
```

它仍然真实使用递归调用，递归深度为 `n`，但时间复杂度为 `O(n)`。

## 三、汇编程序关键部分

### 1. 递归过程

```asm
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
    call print_sequence       ; 递归调用

sequence_return:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_sequence endp
```

进入过程后保存所有会使用的通用寄存器，退出时以相反顺序恢复。栈是后进先出结构，`PUSH` 和 `POP` 顺序不能随意交换。

### 2. 大整数加法

`advance_fibonacci` 从最低的万进制数位开始执行：

```text
当前位 = fib_a[i] + fib_b[i] + carry
若当前位 ≥ 10000：当前位 -= 10000，carry = 1
```

完成 6 个数位后，再执行：

```text
fib_a = fib_b
fib_b = fib_next
```

### 3. 十进制输出

输出时先寻找最高非零数位。最高数位按普通十进制输出，其余数位必须补足 4 位，否则数值会被错误拼接。例如数位 `2, 3` 应显示成 `20003`，而不是 `23`。

## 四、栈空间分析

程序使用：

```asm
.stack 1000h
```

即分配 `4096` 字节栈空间。

每层 `print_sequence` 在递归期间保留：

| 内容 | 字节数 |
| --- | ---: |
| `CALL` 压入的返回地址 | 2 |
| 保存 `AX、BX、CX、DX、SI、DI` | 12 |
| 每层固定占用 | 14 |

100 层递归的固定占用为：

```text
100 × 14 = 1400 字节
```

输出大整数时的临时调用和数字压栈不到 100 字节，因此保守估计总占用小于 1500 字节，明显小于 4096 字节，不会发生栈溢出。

如果初始 `SP=1000H`，只考虑递归固定帧，第 100 层附近约为：

```text
1000H - 100 × 0EH = 0A88H
```

仍有充足空间。若删掉寄存器恢复或让 `PUSH/POP` 数量不匹配，即使空间足够，也会因返回地址被破坏而崩溃。

## 五、编译和运行

在 DOSBox 中执行：

```dos
mount d d:\8086
d:
path d:\masm
cd work
masm fibrec.asm;
link fibrec.obj;
fibrec
```

示例：

```text
Input n (1-100): 10
Fibonacci sequence:
0 1 1 2 3 5 8 13 21 34
```

## 六、DEBUG 单步调试方法

```dos
debug fibrec.exe
u
r
t
p
d ss:sp
q
```

建议按下面步骤观察：

1. 用 `u` 找到调用 `print_sequence` 的 `CALL`。
2. 用 `r` 记录调用前的 `SS、SP、CS、IP`。
3. 用 `t` 执行 `CALL`，可以看到 `SP` 减 2，栈顶保存返回地址。
4. 继续单步执行六条 `PUSH`，每执行一次，`SP` 再减 2。
5. 用 `d ss:sp` 查看栈顶保存的寄存器和返回地址。
6. 到递归 `CALL print_sequence` 时再次记录 `SP`，相邻递归层相差 `0EH`，即 14 字节。
7. 执行到恢复区，观察六条 `POP` 使 `SP` 逐步增加。
8. 执行 `RET` 后，`IP` 回到递归 `CALL` 后的指令，`SP` 再增加 2。

调试时输入较小的 `n=3` 最合适。不要一开始就对 `n=100` 逐条执行，否则要跟踪大量指令，既低效又容易看乱。

## 七、实际调试记录

| 测试 | 预期 | 实际结果 |
| --- | --- | --- |
| `n=1` | 只输出 `0` | 通过 |
| `n=10` | 输出 `0 1 1 2 3 5 8 13 21 34` | 通过 |
| `n=100` | 精确输出 100 项 | 通过，末项为 `218922995834555169026` |
| `n=0` | 拒绝输入 | 通过 |
| MASM 5.0 | 无警告、无严重错误 | `0 Warning Errors / 0 Severe Errors` |

自动化测试时曾出现一个问题：键盘回车通常是 `0DH`，而重定向测试文件只有 `0AH`，最初被程序当成非法字符。修正后的读取过程同时接受 CR 和 LF：

```asm
cmp al, 0dh
je  read_finished
cmp al, 0ah
je  read_finished
```

这不影响正常键盘输入，同时提高了程序对输入来源的兼容性。

## 八、C 语言实现和实际反汇编

C 版本使用相同的 6 数位大整数结构，并在 `print_sequence` 中递归调用自身。使用 Visual Studio 的 `Debug | Win32`、关闭优化后，实际生成的关键 x86 反汇编为：

```asm
_print_sequence PROC
    push ebp
    mov  ebp, esp
    cmp  DWORD PTR _remaining$[ebp], 0
    jne  SHORT $LN2@print_sequ
    jmp  SHORT $LN3@print_sequ

$LN2@print_sequ:
    push OFFSET _fib_a
    call _print_big
    add  esp, 4
    push 32
    call _putchar
    add  esp, 4

    cmp  DWORD PTR _remaining$[ebp], 1
    jbe  SHORT $LN3@print_sequ
    call _advance_fibonacci
    mov  eax, DWORD PTR _remaining$[ebp]
    sub  eax, 1
    push eax
    call _print_sequence
    add  esp, 4

$LN3@print_sequ:
    pop  ebp
    ret  0
_print_sequence ENDP
```

注释说明：

- `push ebp / mov ebp,esp` 建立当前函数的栈帧。
- 参数 `remaining` 位于 `[EBP+8]`，清单中以 `_remaining$[ebp]` 表示。
- `cmp` 和 `jne/jbe` 分别实现递归出口与 `remaining > 1` 判断。
- `push eax` 把 `remaining-1` 作为下一次递归的参数。
- `call _print_sequence` 是实际的自调用。
- `add esp,4` 由调用者清理一个 4 字节参数。
- `pop ebp / ret` 撤销栈帧并返回上一层。
- 这是 32 位 x86 编译结果，不是 16 位 8086，但栈帧、参数和返回地址的原理一致。

## 九、学习心得

本次作业让我真正理解了递归不仅是“函数调用自己”，更重要的是每一层调用都必须保存独立的返回地址和现场。汇编语言不会自动替我保护寄存器，`PUSH/POP` 少一条、顺序错误或者递归出口写错，都会直接破坏栈。

通过计算栈帧大小，我认识到“会不会 Stack Overflow”不能凭感觉判断，而应该根据每层固定占用、最大递归深度和临时调用开销进行估算。对于本程序，100 层递归并不可怕，因为每层只有 14 字节，4 KB 栈足够使用。

另一个重要收获是数据范围必须在写代码前分析。题目允许 `n=100`，如果仍用 16 位寄存器保存斐波那契数，程序虽然能运行，却会悄悄输出错误结果。使用多字大整数比简单的 16 位实现复杂，但能够让输入范围和输出结果真正符合题目要求。
