gcc -fcf-protection=full -o simple simple.c

xxd simple > s_origin.txt

1. elfedit

elfedit --disable-x86-feature shstk simple

xxd simple > s_noshstk.txt


  GNU_PROPERTY   0x0000000000000338 0x0000000000400338 0x0000000000400338
                 0x0000000000000020 0x0000000000000020  R      0x8

So GNU_PROPERTY range is 0x338 - 0x358,  and CET shstk ibt property is
in 0x350, seems 0x338 + 0x18(24) = 0x350

# readelf -l simple

Elf file type is EXEC (Executable file)
Entry point 0x401020
There are 13 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  PHDR           0x0000000000000040 0x0000000000400040 0x0000000000400040
                 0x00000000000002d8 0x00000000000002d8  R      0x8
  INTERP         0x0000000000000318 0x0000000000400318 0x0000000000400318
                 0x000000000000001c 0x000000000000001c  R      0x1
      [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
  LOAD           0x0000000000000000 0x0000000000400000 0x0000000000400000
                 0x0000000000000530 0x0000000000000530  R      0x1000
  LOAD           0x0000000000001000 0x0000000000401000 0x0000000000401000
                 0x00000000000001d5 0x00000000000001d5  R E    0x1000
  LOAD           0x0000000000002000 0x0000000000402000 0x0000000000402000
                 0x0000000000000108 0x0000000000000108  R      0x1000
  LOAD           0x0000000000002e40 0x0000000000403e40 0x0000000000403e40
                 0x00000000000001dc 0x00000000000001e0  RW     0x1000
  DYNAMIC        0x0000000000002e50 0x0000000000403e50 0x0000000000403e50
                 0x0000000000000190 0x0000000000000190  RW     0x8
  NOTE           0x0000000000000338 0x0000000000400338 0x0000000000400338
                 0x0000000000000020 0x0000000000000020  R      0x8
  NOTE           0x0000000000000358 0x0000000000400358 0x0000000000400358
                 0x0000000000000044 0x0000000000000044  R      0x4
  GNU_PROPERTY   0x0000000000000338 0x0000000000400338 0x0000000000400338
                 0x0000000000000020 0x0000000000000020  R      0x8
  GNU_EH_FRAME   0x0000000000002010 0x0000000000402010 0x0000000000402010
                 0x0000000000000034 0x0000000000000034  R      0x4
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
  GNU_RELRO      0x0000000000002e40 0x0000000000403e40 0x0000000000403e40
                 0x00000000000001c0 0x00000000000001c0  R      0x1

 Section to Segment mapping:
  Segment Sections...
   00     
   01     .interp 
   02     .interp .note.gnu.property .note.gnu.build-id .note.ABI-tag .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn 
   03     .init .text .fini 
   04     .rodata .eh_frame_hdr .eh_frame 
   05     .init_array .fini_array .dynamic .got .got.plt .data .bss 
   06     .dynamic 
   07     .note.gnu.property 
   08     .note.gnu.build-id .note.ABI-tag 
   09     .note.gnu.property 
   10     .eh_frame_hdr 
   11     
   12     .init_array .fini_array .dynamic .got 


# diff s_origin.txt s_noshstk.txt 
54c54
< 00000350: 0300 0000 0000 0000 0400 0000 1400 0000  ................
---
> 00000350: 0100 0000 0000 0000 0400 0000 1400 0000  ................


[root@xpf hello_git]# readelf -n  simple_origin  | head

Displaying notes found in: .note.gnu.property
  Owner                Data size        Description
  GNU                  0x00000010       NT_GNU_PROPERTY_TYPE_0
      Properties: x86 feature: IBT, SHSTK

Displaying notes found in: .note.gnu.build-id
  Owner                Data size        Description
  GNU                  0x00000014       NT_GNU_BUILD_ID (unique build ID bitstring)
    Build ID: 4041c37d01a2551b4910f86e90560c1647a8ac7f
[root@xpf hello_git]# readelf -n  simple_noshstk  | head

Displaying notes found in: .note.gnu.property
  Owner                Data size        Description
  GNU                  0x00000010       NT_GNU_PROPERTY_TYPE_0
      Properties: x86 feature: IBT

Displaying notes found in: .note.gnu.build-id
  Owner                Data size        Description
  GNU                  0x00000014       NT_GNU_BUILD_ID (unique build ID bitstring)
    Build ID: 4041c37d01a2551b4910f86e90560c1647a8ac7f



2. How to edit binary in vim with xxd tool
# gcc -fcf-protection=full -o simple simple.c
# readelf -n simple | head
Could see below line,  simple enabled IBT and SHSTK
"      Properties: x86 feature: IBT, SHSTK"
Next we will edit the binary to disable SHSTK.
xxd -p simple > s.txt

From point 1 we know the SHSTK and IBT location is 350 byte.
# diff s_origin.txt s_noshstk.txt 
54c54
< 00000350: 0300 0000 0000 0000 0400 0000 1400 0000  ................
---
> 00000350: 0100 0000 0000 0000 0400 0000 1400 0000  ................

"
00000340: 0500 0000 474e 5500 0200 00c0 0400 0000  ....GNU.........
00000350: 0300 0000 0000 0000 0400 0000 1400 0000  ................
"
So search "0400000003000000" and change it to "0400000001000000" and save.

# xxd -p -r s.txt s
# chmod 755 s
# readelf -n s | head
Could see below, there was no SHSTK in GNU properties as expected.
"      Properties: x86 feature: IBT"