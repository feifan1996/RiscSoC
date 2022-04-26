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
    int sum;
    int mul;
    int div;

    sum = 0;
    for (int i = 1; i <= 100; i++) {
        sum += i;
    }
    xprintf("add:  1+2+..+100 = %5d, expect: %5d\n", sum,  5050);

    sum = 0;
    for (int i = 1; i <= 100; i++) {
        sum -= i;
    }
    xprintf("sub: -1-2-..-100 = %5d, expect: %5d\n", sum, -5050);

    mul = 1;
    for (int i = 1; i <= 8; i++) {
        mul *= i;
    }
    xprintf("mul:  1*2*..*8   = %5d, expect: %5d\n", mul,  40320);

    div = 19960627;
    for (int i = 1; i <= 8; i++) {
        div /= i;
    }
    xprintf("div:  %d, expect: %d\n", div, 495);

    simulation(0x4);
    return sum;
}