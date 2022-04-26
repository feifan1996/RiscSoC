/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date         Author          Notes
 * 2022-03-27   Lyons           first version
 */

#include "soc.h"
#include "xprintf.h"

// Overload this function for xprintf
void _xputc(char c)
{
    GPIO->DR = (1 << 7) | (c & 0x007f);
    GPIO->DR = (0 << 7) | (c & 0x007f);
}

int main(void)
{
    _simulation(0x1);

    xprintf("Hello, world!\n");

    xprintf("board: %s\n", "cortex-m3");
    xprintf("build: %s\n", __DATE__);
    xprintf("       %s\n", __TIME__);

    _simulation(0x3);
    return 0;
}
