#/*
# * Copyright {c} 2020-2021, SERI Development Team
# *
# * SPDX-License-Identifier: Apache-2.0
# *
# * Change Logs:
# * Date         Author          Notes
# * 2022-04-04   Lyons           first version
# */

ARMGCC          = C:/Compiler/risc-v
VLOGCC          = D:/iverilog

CC              = ${ARMGCC}/bin/riscv-none-embed-gcc.exe
OBJDUMP         = ${ARMGCC}/bin/riscv-none-embed-objdump.exe
OBJCOPY         = ${ARMGCC}/bin/riscv-none-embed-objcopy.exe

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

CFLAGS          = -march=rv32im -mabi=ilp32 -mcmodel=medlow
CFLAGS         += -g -O0 -ffunction-sections -fdata-sections

LDFLAGS         = -Wl,-Map,${TARGET}.map,-warn-common \
                  -Wl,--gc-sections \
                  -Wl,--no-relax \
                  -T${PROJPATH}/libs/link.lds -nostartfiles

LDLIBS          = -lm -lc -lgcc

INCFILES        = -I${PROJPATH}/libs \
                  -I${PROJPATH}/libs/_sdk \
                  -I${PROJPATH}/libs/_sdk/systick \
                  -I${PROJPATH}/libs/_sdk/timer \
                  -I${PROJPATH}/libs/_sdk/uart \
                  -I${PROJPATH}/libs/_utilities

ASMFILES        = ${PROJPATH}/libs/_startup/start.S \
                  ${PROJPATH}/libs/_startup/trap.S

CFILES          = ${PROJPATH}/libs/_sdk/systick/*.c \
                  ${PROJPATH}/libs/_sdk/timer/*.c \
                  ${PROJPATH}/libs/_sdk/uart/*.c \
                  ${PROJPATH}/libs/_utilities/*.c
