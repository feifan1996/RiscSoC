OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
    rom (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
    ram (rwx) : ORIGIN = 0x10000000, LENGTH = 32K
}

SECTIONS
{
    .init           :
    {
        KEEP (*(SORT_NONE(.init)))
    } >rom

    .text           :
    {
        . = ALIGN(4);
        __fsymtab_start = .;
        KEEP(*(FSymTab))
        __fsymtab_end = .;

        . = ALIGN(4);
        __vsymtab_start = .;
        KEEP(*(VSymTab))
        __vsymtab_end = .;

        . = ALIGN(4);
        *(.text.unlikely .text.unlikely.*)
        *(.text.startup .text.startup.*)
        *(.text .text.*)
        *(.gnu.linkonce.t.*)
    } >rom

    .data          :
    {
        __data_lma = LOADADDR(.data);
        __data_start = .;

        . = ALIGN(4);
        __rt_init_start = .;
        KEEP(*(SORT(.rti_fn*)))
        __rt_init_end = .;

        *(.rdata)
        *(.rodata .rodata.*)
        *(.gnu.linkonce.r.*)
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        *(.sdata .sdata.*)
        *(.sdata*)
        *(.gnu.linkonce.s.*)

        . = ALIGN(4);
        __data_end = .;
    } >ram AT>rom

    .bss            :
    {
        __bss_start = .;

        *(.sbss .sbss.*)
        *(.gnu.linkonce.sb.*)
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)

        . = ALIGN(4);
        __bss_end = .;
        __end = .;
    } >ram

    .stack ORIGIN(ram) + LENGTH(ram):
    {
        __stack_top = .;
    } >ram
}
