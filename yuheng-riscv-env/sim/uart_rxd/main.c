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
    uint32_t data, dummy;

    data = 0x52;

    uart_send_wait(UART2, data);
    dummy = uart_read_wait(UART3);

    xprintf("tx: %02x, rx: %02x\n", data, dummy);

    simulation(0x4);
    return 0;
}