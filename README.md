# 8086 汇编课程作业

本仓库整理了课程目前涉及的 8086/DOS 汇编作业、对应 C 程序、运行结果及调试说明。汇编程序使用 **MASM 5.0 + DOSBox 0.74**；C 程序使用 Visual Studio 的 **Win32/x86 Debug** 配置。

## 作业目录

| 次序 | 内容 | 程序 | 详细说明 |
| --- | --- | --- | --- |
| 第一次作业 | Hello World、汇编/链接、DEBUG 反汇编 | `WORK/HELLO.ASM` | [查看说明](assignments/01-hello-world/README.md) |
| 作业题目 2 | 每行 13 个字符打印小写 ASCII 表 | `WORK/ASCII.ASM`、`WORK/ASCIIJ.ASM`、C 版本 | [查看说明](assignments/02-ascii-table/README.md) |
| 课堂练习 | 十六进制与十进制互相转换 | `WORK/exchange.asm` | [查看说明](assignments/class-number-conversion/README.md) |
| 作业题目 3 | 求和、不同位置存储结果、用户输入、C 反汇编 | `WORK/sum.asm`、`WORK/SumC/sum.c` | [查看说明](assignments/03-sum/README.md) |

实际运行记录保存在 [`results`](results/)；所有汇编源程序均已重新汇编、链接并运行验证。

## 汇编程序的统一执行步骤

DOSBox 中执行：

```dos
mount d d:\8086
d:
path d:\masm
cd work
masm 文件名.asm;
link 文件名.obj;
文件名
```

末尾的分号用于接受 MASM/LINK 的默认选项，避免逐项询问。修改 `.ASM` 后不会自动更新程序，必须重新执行“汇编 → 链接 → 运行”。

## 常用查看和调试

```dos
debug hello.exe
u                 ; 反汇编当前位置
u 0 30            ; 反汇编指定范围
r                 ; 查看寄存器
t                 ; 单步执行一条指令
p                 ; 执行一条指令，遇到中断/调用时整体越过
d ds:0            ; 查看内存
q                 ; 退出 DEBUG
```

## 已验证结果

- `HELLO.ASM`：输出 `Hello world!`
- `ASCII.ASM`：用 `LOOP` 输出 `a` 到 `z`，每行 13 个字符
- `ASCIIJ.ASM`：用 `DEC` + `JNZ` 得到相同结果
- `exchange.asm`：通过 `FF ↔ 255` 和 `FFFF ↔ 65535` 测试
- `sum.asm`：寄存器、数据段、栈和用户输入四条路径均得到 `5050`；十六进制为 `13BAH`
- 两个 C 程序均以 Win32/x86 方式生成并运行，反汇编摘录见对应作业说明

> 注意：Visual Studio 生成的是现代 **32 位 x86** 汇编，不是 8086 指令；它适合观察 C 的循环、比较、跳转和函数调用如何被翻译。

