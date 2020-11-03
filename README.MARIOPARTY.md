marioparty-binutils-2.7
=======================

This is a modified build of `binutils` 2.7.

- Ported back `.incbin` support.
- Ported back register names support.

This is based on efforts in [binutils-papermario](https://github.com/ethteck/binutils-papermario).

## Building

```
./configure --target=mips-mips-elf --prefix=/opt/cross --host=i386-pc-linux --build=i386-pc-linux --disable-werror

make
```
