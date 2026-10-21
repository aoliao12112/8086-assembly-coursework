# 8086 Assembly Coursework

8086/DOS assembly exercises built with MASM 5.0 and run in DOSBox 0.74, plus an equivalent Win32 C implementation built with Visual Studio.

## Programs

| Source | Purpose | Verified result |
| --- | --- | --- |
| `WORK/HELLO.ASM` | DOS Hello World | Prints `Hello world!` |
| `WORK/ASCII.ASM` | ASCII lowercase table using `LOOP` | Prints `a`-`z`, 13 characters per row |
| `WORK/ASCIIJ.ASM` | Same table using `DEC` + `JNZ` | Same output as `ASCII.ASM` |
| `WORK/exchange.asm` | Hex/decimal conversion | `FF -> 255`, `255 -> 00FF`, `FFFF -> 65535`, `65535 -> FFFF` |
| `WORK/sum.asm` | Sum `1..100` using register/data segment/stack; accepts custom `n` | All `1..100` branches and `n=100` produce `5050`; data result is `13BAH` |
| `WORK/AsciiTableC/AsciiTableC/ascii.c` | Equivalent C implementation | Prints the same two-row lowercase ASCII table |

Human-readable test captures are stored in [`results`](results/).

## MASM/DOSBox build

Expected local layout:

```text
D:\8086\
|-- MASM\      # local MASM 5.0 tools; ignored by Git
`-- WORK\      # source files
```

Start DOSBox and run:

```dos
mount d d:\8086
d:
path d:\masm
cd work
masm hello.asm;
link hello.obj;
hello
```

Replace `hello` with `ascii`, `asciij`, `exchange`, or `sum` as needed.

## Visual Studio C build

Open `WORK/AsciiTableC/AsciiTableC/AsciiTableC.vcxproj`, select `Debug | Win32`, then build and run. The source file has a `.c` extension, so Visual Studio compiles it as C.

## Verification

All programs were rebuilt and executed on 2026-10-21. MASM sources assembled with:

```text
0 Warning Errors
0 Severe Errors
```

Generated binaries, object files, listing files, the local MASM toolchain, and Visual Studio build directories are intentionally excluded from Git.

