marioparty-binutils-2.7
=======================

This is a modified build of `binutils` 2.7.

- Ported back `.incbin` support.
- Ported back register names support.

## Building

```
./configure --target=mips-mips-elf --prefix=/opt/cross --host=i386-pc-linux --build=i386-pc-linux --disable-werror

make
```