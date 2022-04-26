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

#include "systick.h"
#include "xprintf.h"

int main()
{
    uint32_t start;
    uint32_t end;

    start = get_cyclel_value();
    delay_us(1000);
    end = get_cyclel_value();

    xprintf("start: %ld\n", start/CPU_FREQ_MHZ);
    xprintf("end:   %ld\n", end/CPU_FREQ_MHZ);

    simulation(0x4);
    return 0;
}