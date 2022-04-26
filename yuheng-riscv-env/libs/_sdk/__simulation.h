/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

#ifndef __SIMULATION_H__
#define __SIMULATION_H__

#include "uart.h"

#define DEBUG_UART          UART1

#define simulation(data)    \
do { \
    uart_send_wait(DEBUG_UART, 0x1b); \
    uart_send_wait(DEBUG_UART, data); \
} while (0);

#endif //#ifndef __SIMULATION_H__