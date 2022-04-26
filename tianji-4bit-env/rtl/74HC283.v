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

module M74HC283 (
    input  [3:0]                A,
    input  [3:0]                B,
    input                       Ci,
           
    output [3:0]                S,
    output                      Co
);

// you can implement by using basic logic here
assign {Co, S[3:0]} = A[3:0] + B[3:0] + {3'b0, Ci};

endmodule