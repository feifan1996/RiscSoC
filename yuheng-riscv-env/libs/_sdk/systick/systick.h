/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-11-08     Lyons        first version
 */

#ifndef __SYSTICK_H__
#define __SYSTICK_H__

#include "__def.h"

uint64_t get_cycle_value(void);
uint32_t get_cyclel_value(void);

void delay_us();
void delay_ms();

#endif //#ifndef __SYSTICK_H__