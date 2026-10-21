# 作业题目 2：按要求打印 ASCII 表

## 1. 要求

输出小写字母 `a` 到 `z`，每行 13 个字符：

```text
a b c d e f g h i j k l m
n o p q r s t u v w x y z
```

## 2. 用 LOOP 指令实现

源程序：[ASCII.ASM](../../WORK/ASCII.ASM)

`LOOP 标号` 的行为等价于“先将 `CX` 减 1，如果 `CX != 0` 就跳转”。双重循环都使用 `CX`，所以外层计数值必须先保存：

```asm
mov cx, 2           ; 两行
outer:
    push cx         ; 保存外层 CX
    mov cx, 13      ; 每行 13 个字符
inner:
    ; 输出字符
    loop inner
    pop cx          ; 恢复外层 CX
    loop outer
```

若不执行 `push cx` / `pop cx`，内层循环会覆盖外层计数器，双重循环无法按预期工作。

## 3. 用条件跳转实现

源程序：[ASCIIJ.ASM](../../WORK/ASCIIJ.ASM)

```asm
dec cx
jnz inner
```

`DEC CX` 会更新零标志 `ZF`；当结果不为 0 时，`JNZ` 跳回循环开头。这里仍然需要为双重循环保存和恢复外层 `CX`。

## 4. 用 C 语言实现并看反汇编

源程序：[ascii.c](../../WORK/AsciiTableC/AsciiTableC/ascii.c)

核心 C 代码是两层 `for` 循环。用 Visual Studio 打开项目，选择 `Debug | Win32`，在循环处设断点，启动调试后选择“调试 → 窗口 → 反汇编”。实际 x86 Debug 代码的关键结构如下：

```asm
mov  DWORD PTR row, 0
cmp  DWORD PTR row, 2
jge  outer_end
mov  DWORD PTR col, 0
cmp  DWORD PTR col, 13
jge  inner_end
movsx edx, BYTE PTR ch
push edx
call _putchar
add  esp, 4
add  al, 1
mov  BYTE PTR ch, al
```

- `cmp` 配合 `jge` 实现 `row < 2` 和 `col < 13` 的判断。
- `push` 传递 `putchar` 的参数，`call` 调用函数，`add esp,4` 清理参数。
- `add al,1` 对应 C 中的 `++ch`。
- 这是 32 位 x86 编译结果，所以出现 `EAX/EDX/ESP`；不能把它当成纯 8086 程序。

## 5. 编译运行

```dos
masm ascii.asm;
link ascii.obj;
ascii

masm asciij.asm;
link asciij.obj;
asciij
```

两种汇编写法和 C 程序均已验证，输出完全一致。
