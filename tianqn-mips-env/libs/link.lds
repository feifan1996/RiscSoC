OUTPUT_ARCH( "mips" )
ENTRY(_start)

MEMORY
{
    rom (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
    ram (rwx) : ORIGIN = 0x10000000, LENGTH = 4K
}

SECTIONS
{
    .text           :
    {
        . = ALIGN(4);
        *(.text)

        . = ALIGN(4);
        *(.MIPS*)
        *(.reginfo)
        *(.gnu*)
    } >rom

    .data          :
    {
        __data_lma = LOADADDR(.data);
        __data_start = .;

        . = ALIGN(4);
        *(.data)

        . = ALIGN(4);
        __data_end = .;
    } >ram AT>rom

    .bss            :
    {
        __bss_start = .;

        *(.bss)
        *(COMMON)

        . = ALIGN(4);
        __bss_end = .;
        __end = .;
    } >ram
}
