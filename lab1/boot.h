#ifndef _BOOT_H
#define _BOOT_H

#define SEG_NULL                            \
    .word 0, 0;                             \
    .byte 0, 0, 0, 0

#define SEG_ASM(type,base,lim)              \
    .word (((lim) >> 12)& 0xffff), ((base) & 0xffff);   \
    .byte