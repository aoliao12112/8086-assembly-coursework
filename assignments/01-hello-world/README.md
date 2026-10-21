# 第一次作业：Hello World

## 1. 作业要求

1. 传统方式：源代码 → 汇编 → 链接；用 DEBUG 的 `u` 命令查看机器码与汇编指令的关系；提交源代码和 EXE。
2. 另一种方式：用 DEBUG 的 `e` 命令直接把代码和数据写入内存并执行；提交操作文档。

## 2. 传统方式

源程序：[HELLO.ASM](../../WORK/HELLO.ASM)

```dos
masm hello.asm;
link hello.obj;
hello
```

运行结果：

```text
Hello world!
```

程序的核心逻辑是先把数据段地址送入 `DS`，再调用 DOS `INT 21H/AH=09H` 输出以 `$` 结束的字符串，最后用 `INT 21H/AH=4CH` 返回 DOS。

## 3. 用 DEBUG 查看机器码

```dos
debug hello.exe
u
r
t
q
```

本次实际生成的关键字节如下：

| 偏移 | 机器码 | 汇编指令 | 作用 |
| --- | --- | --- | --- |
| `0000` | `B8 ....` | `mov ax,@data` | 把数据段地址装入 AX（链接后补全地址） |
| `0003` | `8E D8` | `mov ds,ax` | 初始化 DS |
| `0005` | `8D 16 ....` | `lea dx,message` | DX 指向字符串 |
| `0009` | `B4 09` | `mov ah,09h` | 选择 DOS 字符串输出功能 |
| `000B` | `CD 21` | `int 21h` | 调用 DOS |
| `000D` | `B8 00 4C` | `mov ax,4c00h` | AH=4CH，AL=返回码 0 |
| `0010` | `CD 21` | `int 21h` | 结束程序 |

8086 采用小端序，因此 `4C00H` 在机器码中按低字节在前保存为 `00 4C`。

## 4. 用 DEBUG 直接写内存

下面的操作不需要 `.ASM` 文件：数据写到 `0200H`，程序写到 `0100H`。

```dos
debug
-e 0200 48 65 6C 6C 6F 20 77 6F 72 6C 64 21 0D 0A 24
-e 0100 0E 1F BA 00 02 B4 09 CD 21 B8 00 4C CD 21
-d 0200 020E
-u 0100 010D
-g=0100
```

代码字节对应关系：

```text
0E          push cs
1F          pop  ds          ; 令 DS=CS
BA 00 02    mov  dx,0200h    ; 指向字符串
B4 09       mov  ah,09h
CD 21       int  21h
B8 00 4C    mov  ax,4c00h
CD 21       int  21h
```

提交前应保留 `HELLO.ASM` 和重新生成的 `HELLO.EXE`，并把 DEBUG 输入、反汇编和运行结果截图放进实验文档。
