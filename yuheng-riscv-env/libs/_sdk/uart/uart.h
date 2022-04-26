/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

#ifndef __UART_H__
#define __UART_H__

#include "__def.h"

typedef struct
{
    __IO uint32_t           cr;
    __IO uint32_t           sr;
    __I  uint32_t           baud;
    __I  uint32_t           rxd;
    __IO uint32_t           txd;
} UART_Type;

#define UART_BASE           (0x30000000)

#define UART1               ((UART_Type*)(UART_BASE))
#define UART2               ((UART_Type*)(UART_BASE + 0x10000000))
#define UART3               ((UART_Type*)(UART_BASE + 0x20000000))

// [0]: tx enbale
// [1]: rx enbale
#define UART_CR_TX_EN       (uint32_t)(1 << 0)
#define UART_CR_RX_EN       (uint32_t)(1 << 1)

// [0]: tx flag
// [1]: rx flag
#define UART_SR_FLAG_TXE    (uint32_t)(1 << 0)
#define UART_SR_FLAG_RXNE   (uint32_t)(1 << 1)

#define UART_SR_CLR_TXE     (uint32_t)(1 << 0) //write "1" clear
#define UART_SR_CLR_RXNE    (uint32_t)(1 << 1)

void uart_send(UART_Type *uart, uint8_t data);
void uart_send_wait(UART_Type *uart, uint8_t data);

uint8_t uart_read(UART_Type *uart);
uint8_t uart_read_wait(UART_Type *uart);

#endif //#ifndef __UART_H__