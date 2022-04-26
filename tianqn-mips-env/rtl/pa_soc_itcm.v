/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2022-01-17     Lyons        first version
 */

`include "pa_soc_param.v"

module pa_soc_itcm (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire [`ADDR_BUS_WIDTH-1:0]   inst_addr_i,
    output wire [`DATA_BUS_WIDTH-1:0]   inst_data_o,

    output wire                         unalign_expt_o
);

reg  [7:0]                              _rom[0:`ROM_SIZE*1024-1];

wire [`ADDR_BUS_WIDTH-1:0]              index;

assign index[`ADDR_BUS_WIDTH-1:0] = {2'b0, inst_addr_i[31:2]};

reg  [`DATA_BUS_WIDTH-1:0]              _inst_data;

always @ (*) begin
    if (!rst_n_i) begin
        _inst_data[`DATA_BUS_WIDTH-1:0] = `ZERO_WORD;
    end
    else begin
        _inst_data[`DATA_BUS_WIDTH-1:0] = {_rom[index*4+0], _rom[index*4+1], _rom[index*4+2], _rom[index*4+3]};
    end
end

assign inst_data_o[`DATA_BUS_WIDTH-1:0] = _inst_data[`DATA_BUS_WIDTH-1:0];

assign unalign_expt_o = (|inst_addr_i[1:0]);

endmodule