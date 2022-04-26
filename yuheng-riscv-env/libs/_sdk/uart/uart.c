/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

#include "uart.h"

void uart_send(UART_Type *uart, uint8_t data)
{
    uart->sr = UART_SR_CLR_TXE;
    uart->txd = data;
}

void uart_send_wait(UART_Type *uart, uint8_t data)
{
    uart->txd = data;
    while ( !(uart->sr & UART_SR_FLAG_TXE) );
    uart->sr = UART_SR_CLR_TXE;
}

uint8_t uart_read(UART_Type *uart)
{
    uint8_t dummy;

    if (uart->sr & UART_SR_FLAG_RXNE)
    {
        dummy = uart->rxd;
        uart->sr = UART_SR_CLR_RXNE;
    } else {
        dummy = 0xFF; //0xFF is -1
    }
    
    return dummy;
}

uint8_t uart_read_wait(UART_Type *uart)
{
    uint8_t dummy;

    while ( !(uart->sr & UART_SR_FLAG_RXNE) );

    dummy = uart->rxd;
    uart->sr = UART_SR_CLR_RXNE;

    return dummy;
}