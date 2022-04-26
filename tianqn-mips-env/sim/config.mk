#/*
# * Copyright {c} 2020-2021, SERI Development Team
# *
# * SPDX-License-Identifier: Apache-2.0
# *
# * Change Logs:
# * Date         Author          Notes
# * 2022-04-04   Lyons           first version
# */

ARMGCC          = C:/Compiler/mips
VLOGCC          = D:/iverilog

CC              = ${ARMGCC}/bin/mips-img-elf-gcc.exe
OBJDUMP         = ${ARMGCC}/bin/mips-img-elf-objdump.exe
OBJCOPY         = ${ARMGCC}/bin/mips-img-elf-objcopy.exe

VCS             = ${VLOGCC}/bin/iverilog.exe
SIM             = ${VLOGCC}/bin/vvp.exe
WAV             = ${VLOGCC}/gtkwave/bin/gtkwave.exe

RM              = rm -f
CP              = cp
MV              = mv

# for vcs tools
ALLDEFINE       = -DDUMP_VCD

TBFILES         = ${PROJPATH}/tb/core_uart_monitor_tb.v \
                  ${PROJPATH}/tb/core_tb.v

# for c/asm tools
LIBGCC          = 
LIBC            = 

CFLAGS          = 
LDFLAGS         = -Wl,-Map,${TARGET}.map,-warn-common \
                  -T${PROJPATH}/libs/link.lds -nostartfiles

LDLIBS          = 

INCFILES        = 

ASMFILES        = 

CFILES          = 
