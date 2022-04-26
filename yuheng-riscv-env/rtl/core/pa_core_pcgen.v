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

module pa_core_pcgen (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire                         reset_flag_i,

    input  wire                         hold_flag_i,

    input  wire                         jump_flag_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   jump_addr_i,

    output wire [`DATA_BUS_WIDTH-1:0]   pc_o
);

reg  [`DATA_BUS_WIDTH-1:0]              _pc;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin // hardware power-on reset
        _pc[`DATA_BUS_WIDTH-1:0] <= `RESET_PC_ADDR;
    end
    else if (reset_flag_i) begin // software reset
        _pc[`DATA_BUS_WIDTH-1:0] <= `RESET_PC_ADDR;
    end
    else if (jump_flag_i) begin // jump instruction
        _pc[`DATA_BUS_WIDTH-1:0] <= jump_addr_i[`DATA_BUS_WIDTH-1:0];
    end
    else if (hold_flag_i) begin // cpu stall & hold
        _pc[`DATA_BUS_WIDTH-1:0] <= _pc[`DATA_BUS_WIDTH-1:0];
    end
    else begin // only support 32-bits instruction
        _pc[`DATA_BUS_WIDTH-1:0] <= _pc[`DATA_BUS_WIDTH-1:0] + 32'h4;
    end
end

assign pc_o[`DATA_BUS_WIDTH-1:0] = _pc[`DATA_BUS_WIDTH-1:0];

endmodule