/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2022-01-26     Lyons        first version
 */

`include "pa_soc_param.v"

module M74HC153 (
    input  [3:0]                IN1,
    input  [3:0]                IN2,

    input                       ENn,
    input  [1:0]                SEL,

    output [1:0]                OUT
);

wire [1:0]                      tmp;

assign tmp[0] = (2'd0 == SEL[1:0]) & IN1[0]
              | (2'd1 == SEL[1:0]) & IN1[1]
              | (2'd2 == SEL[1:0]) & IN1[2]
              | (2'd3 == SEL[1:0]) & IN1[3];

assign tmp[1] = (2'd0 == SEL[1:0]) & IN2[0]
              | (2'd1 == SEL[1:0]) & IN2[1]
              | (2'd2 == SEL[1:0]) & IN2[2]
              | (2'd3 == SEL[1:0]) & IN2[3];

assign OUT[1:0] = ENn ? 2'b0 : tmp[1:0];

endmodule