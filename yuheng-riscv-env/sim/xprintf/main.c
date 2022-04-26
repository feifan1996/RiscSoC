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

int main()
{
    xprintf("%d\n", 1234);
    xprintf("%6d,%3d%%\n", -200, 5);
    xprintf("%-6u\n", 100);
    xprintf("%ld\n", 12345678L);
    xprintf("%04x\n", 0xA3);
    xprintf("%08LX\n", 0x123ABC);
    xprintf("%016b\n", 0x550F);
    xprintf("%s\n", "String");
    xprintf("%-4s\n", "abc");
    xprintf("%4s\n", "abc");
    xprintf("%c\n", 'a');

    simulation(0x4);
    return 0;
}