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

module pa_soc_xreg (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire [`REG_BUS_WIDTH-1:0]    rs1_addr,
    output wire [`DATA_BUS_WIDTH-1:0]   rs1_data,

    input  wire [`REG_BUS_WIDTH-1:0]    rs2_addr,
    output wire [`DATA_BUS_WIDTH-1:0]   rs2_data,

    input  wire [`REG_BUS_WIDTH-1:0]    rd_addr,
    input  wire [`DATA_BUS_WIDTH-1:0]   rd_data,
    input  wire                         rd_data_vld
);

reg  [`DATA_BUS_WIDTH-1:0]              _xreg[0:`REG_NUM-1];

initial begin
    for (integer idx=0; idx<32; idx=idx+1) begin
        _xreg[idx] = `ZERO_WORD;
    end
end

always @ (posedge clk_i) begin
    if (rst_n_i) begin
        if (rd_data_vld && (5'd0 != rd_addr)) begin
            _xreg[rd_addr] <= rd_data[`DATA_BUS_WIDTH-1:0];
        end
    end
end

reg  [`DATA_BUS_WIDTH-1:0]              _rs1;
reg  [`DATA_BUS_WIDTH-1:0]              _rs2;

always @ (*) begin
    if (5'd0 == rs1_addr) begin
        _rs1[`DATA_BUS_WIDTH-1:0] = `ZERO_WORD;
    end
    else begin
        _rs1[`DATA_BUS_WIDTH-1:0] = _xreg[rs1_addr];
    end
end

always @ (*) begin
    if (5'd0 == rs2_addr) begin
        _rs2[`DATA_BUS_WIDTH-1:0] = `ZERO_WORD;
    end
    else begin
        _rs2[`DATA_BUS_WIDTH-1:0] = _xreg[rs2_addr];
    end
end

assign rs1_data[`DATA_BUS_WIDTH-1:0] = _rs1[`DATA_BUS_WIDTH-1:0];
assign rs2_data[`DATA_BUS_WIDTH-1:0] = _rs2[`DATA_BUS_WIDTH-1:0];

endmodule