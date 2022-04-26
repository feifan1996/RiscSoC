#/*
# * Copyright {c} 2020-2021, SERI Development Team
# *
# * SPDX-License-Identifier: Apache-2.0
# *
# * Change Logs:
# * Date         Author          Notes
# * 2022-03-27   Lyons           first version
# */

TARGET          = riscv

Q               = @

PROJPATH        = ../..
WORKPATH        = .

include ../config.mk

CFILES         += ${WORKPATH}/init.c \
                  ${WORKPATH}/interrupt.c \
                  ${WORKPATH}/main.c

include ../build.mk
