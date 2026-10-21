# 作业题目 3：求和

## 1. 要求与实现

源程序：[sum.asm](../../WORK/sum.asm)；C 版本：[sum.c](../../WORK/SumC/sum.c)

- 计算 `1+2+...+100`，输出 `5050`。
- 结果分别保存在寄存器、数据段、栈中并输出。
- 用户输入 `1..100` 中任意整数，输出 `1..n` 的和。
- 用 C 实现并查看、注释反汇编代码。

`5050 = 13BAH`，超过 8 位寄存器能表示的 `255`，所以必须使用 `AX/BX` 等 16 位寄存器或 16 位内存单元。

## 2. 汇编求和核心

```asm
xor ax, ax          ; AX 保存和
mov bx, 1           ; BX 保存当前加数
mov cx, 100         ; 循环 100 次
sum_loop:
    add ax, bx
    inc bx
    loop sum_loop
```

四种路径：

1. 寄存器：结果直接保留在 `AX`。
2. 数据段：把结果写入 `sum_result dw ?`，再读出输出。
3. 栈：`push ax` 保存，之后 `pop ax` 恢复。
4. 用户输入：用 DOS `INT 21H/AH=01H` 逐字符读取，转换成十进制数后求和。

一个容易出错的地方是：`mov ah,09h` 会改写 `AX` 的高字节。若求和结果还在 `AX` 中，输出提示字符串之前必须先 `push ax`，之后 `pop ax`，否则 `5050` 会被破坏。

## 3. C 版本及反汇编

C 函数：

```c
static unsigned int sum_to(unsigned int n)
{
    unsigned int total = 0;
    unsigned int i;
    for (i = 1; i <= n; ++i)
        total += i;
    return total;
}
```

以 Visual Studio Win32/x86、Debug、关闭优化的方式实际生成的关键反汇编如下：

```asm
mov  DWORD PTR total, 0
mov  DWORD PTR i, 1
loop_test:
cmp  eax, DWORD PTR n
ja   loop_end
mov  edx, DWORD PTR total
add  edx, DWORD PTR i
mov  DWORD PTR total, edx
mov  eax, DWORD PTR i
add  eax, 1
mov  DWORD PTR i, eax
jmp  loop_test
loop_end:
mov  eax, DWORD PTR total
```

- `cmp` + `ja` 对应无符号条件 `i <= n`。
- `add` 对应 `total += i` 和 `++i`。
- 返回值放在 `EAX`。
- 这里是现代 32 位 x86 汇编；汇编作业主体仍是 16 位 8086。

## 4. 编译与验证

```dos
masm sum.asm;
link sum.obj;
sum
```

| 测试项目 | 结果 |
| --- | --- |
| 寄存器保存 `1..100` | `5050` |
| 数据段保存 | `5050`，内存值 `13BAH` |
| 栈保存 | `5050` |
| 输入 `n=100` | `5050` |
| C 固定计算和输入 `100` | 均为 `5050` |
