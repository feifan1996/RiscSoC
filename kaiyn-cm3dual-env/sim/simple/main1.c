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

uint32_t *startup = (uint32_t*)0x2000c000;

int main(void)
{
    for (int i=0; i<100; i++) {
        (void)startup;
    }    

    while (0x0 == *(startup));
    xprintf("<== core1 start\n");

    xprintf("Hello, world!\n");
    xprintf("board: %s\n", "cortex-m3 core 1");

    _simulation(0x3);
    return 0;
}
