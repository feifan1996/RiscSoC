#/*
# * Copyright {c} 2020-2021, SERI Development Team
# *
# * SPDX-License-Identifier: Apache-2.0
# *
# * Change Logs:
# * Date         Author          Notes
# * 2022-04-04   Lyons           first version
# */

ARMGCC          = C:/Compiler/arm/v5_4_1/2016q2
VLOGCC          = D:/iverilog

CC              = ${ARMGCC}/bin/arm-none-eabi-gcc.exe
OBJDUMP         = ${ARMGCC}/bin/arm-none-eabi-objdump.exe
OBJCOPY         = ${ARMGCC}/bin/arm-none-eabi-objcopy.exe

VCS             = ${VLOGCC}/bin/iverilog.exe
SIM             = ${VLOGCC}/bin/vvp.exe
WAV             = ${VLOGCC}/gtkwave/bin/gtkwave.exe

RM              = rm -f
CP              = cp
MV              = mv

# for vcs tools
ALLDEFINE       = -DDUMP_VCD

TBFILES         = ${PROJPATH}/tb/tb.v

# for c/asm tools
LIBGCC          = ${ARMGCC}/lib/gcc/arm-none-eabi/5.4.1/armv6-m
LIBC            = ${ARMGCC}/arm-none-eabi/lib/armv6-m

CFLAGS          = -mthumb -march=armv6-m -mcpu=cortex-m0 -mlittle-endian
CFLAGS         += -g -O0

LDFLAGS         = -Wl,-Map,${TARGET}.map,-warn-common \
                  -T${PROJPATH}/libs/link.lds

LDLIBS          = -L ${LIBGCC} -L ${LIBC} -lm -lc -lgcc

INCFILES        = -I${PROJPATH}/libs \
                  -I${PROJPATH}/libs/_sdk \
                  -I${PROJPATH}/libs/_utilities

ASMFILES        = ${PROJPATH}/libs/_startup/startup_gcc.S

CFILES          = ${PROJPATH}/libs/_utilities/xprintf.c
