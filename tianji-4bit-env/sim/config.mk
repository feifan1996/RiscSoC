#/*
# * Copyright {c} 2020-2021, SERI Development Team
# *
# * SPDX-License-Identifier: Apache-2.0
# *
# * Change Logs:
# * Date         Author          Notes
# * 2022-04-04   Lyons           first version
# */

VLOGCC          = D:/iverilog

VCS             = ${VLOGCC}/bin/iverilog.exe
SIM             = ${VLOGCC}/bin/vvp.exe
WAV             = ${VLOGCC}/gtkwave/bin/gtkwave.exe

RM              = rm -f
CP              = cp
MV              = mv

# for vcs tools
ALLDEFINE       = -DDUMP_VCD

TBFILES         = ${PROJPATH}/tb/core_tb.v
