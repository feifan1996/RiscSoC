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

module M74HC540 (
    input  [7:0]                A,
    input  [1:0]                OEn,

    output [7:0]                Y
);

assign Y[7:0] = (2'b00 == OEn[1:0]) ? ~A[7:0]
                                    : 8'bzzzz_zzzz;

endmodule