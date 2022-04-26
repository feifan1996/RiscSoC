/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-11-08     Lyons        first version
 */

#include "systick.h"

uint64_t get_cycle_value(void)
{
    uint64_t cycle;

    cycle  = read_csr(cycle);
    cycle += (uint64_t)(read_csr(cycleh)) << 32;

    return cycle;
}

uint32_t get_cyclel_value(void)
{
    return read_csr(cycle);
}

void delay_us(uint32_t us)
{
    uint64_t start;
    uint64_t end;

    if (0 == us) {
        return;
    }

    start = get_cycle_value();
    end = start + (us * CPU_FREQ_MHZ);

    while (get_cycle_value() < end);
}

void delay_ms(uint32_t ms)
{
    if (0 == ms) {
        return;
    }

    while (ms) {
        delay_us(1000);
    }
}