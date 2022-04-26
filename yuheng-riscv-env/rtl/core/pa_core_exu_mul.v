/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date             Author      Notes
 * 2021-10-29       Lyons       first version
 * 2022-04-04       Lyons       v2.0
 */

`include "pa_chip_param.v"

module pa_core_exu_mul (
    input  wire [`DATA_BUS_WIDTH-1:0]   data1_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   data2_i,

    input  wire                         sign_i,

    output wire [63:0]                  data_o
);

wire [47:0]                             iresult_final_high;
wire [47:0]                             iresult_final_low;

// you should using multi ip here.

assign iresult_final_high[47:0] = data1_i[31:0] * {16'b0, data2_i[31:16]};
assign iresult_final_low [47:0] = data1_i[31:0] * {16'b0, data2_i[15: 0]};

wire [63:0]                             iresult_final;

assign iresult_final[63:0] = {iresult_final_high[47:0], 16'b0}
                           + {16'b0,  iresult_final_low[47:0]};

assign data_o[63:0] = sign_i ? (~iresult_final[63:0] + 63'b1)
                             : ( iresult_final[63:0]);

endmodule