/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

#include "__def.h"
#include "xprintf.h"

extern void timer1_handler(void);

void trap_handler(uint32_t irqno, uint32_t epc)
{
    if (0x80000003 == irqno)
    {
        timer1_handler();
    } else {
        xprintf("irqno: %08x\n", irqno);
        xprintf("break: %08x\n", epc);
    }
}