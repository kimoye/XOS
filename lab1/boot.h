#ifndef _BOOT_H
#define _BOOT_H

#define SEG_NULL                            \
    .word 0, 0;                             \
    .byte 0, 0, 0, 0

#define SEG_ASM(type,base,lim)              \
    .word (((lim) >> 12)& 0xffff), ((base) & 0xffff);   \
    .byte (((base) >> 16) & 0xff), (0x90 | (type)),     \
        (0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)

#define STA_X       0x08     // Executable segment
#define STA_E       0x04     // Expand down (non-executable segments)
#define STA_C       0x04     // Conforming code segment (executable only)
#define STA_W       0x02     // Writeable (non-executable segments)
#define STA_R       0x02     // Readable (executable segments)
#define STA_A       0x01     // Accessed

#endif
