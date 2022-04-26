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

module pa_core_xreg (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire [`REG_BUS_WIDTH-1:0]    reg1_raddr_i,
    input  wire [`REG_BUS_WIDTH-1:0]    reg2_raddr_i,

    input  wire [`REG_BUS_WIDTH-1:0]    reg_waddr_i,
    input  wire                         reg_waddr_vld_i,

    input  wire [`DATA_BUS_WIDTH-1:0]   reg_wdata_i,

    output wire [`DATA_BUS_WIDTH-1:0]   reg1_rdata_o,
    output wire [`DATA_BUS_WIDTH-1:0]   reg2_rdata_o
);

reg  [`DATA_BUS_WIDTH-1:0]              _x0  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x1  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x2  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x3  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x4  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x5  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x6  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x7  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x8  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x9  = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x10 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x11 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x12 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x13 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x14 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x15 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x16 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x17 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x18 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x19 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x20 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x21 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x22 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x23 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x24 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x25 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x26 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x27 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x28 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x29 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x30 = `ZERO_WORD;
reg  [`DATA_BUS_WIDTH-1:0]              _x31 = `ZERO_WORD;

reg  [`DATA_BUS_WIDTH-1:0]              _rs1;
reg  [`DATA_BUS_WIDTH-1:0]              _rs2;

always @ (posedge clk_i) begin
    if (reg_waddr_vld_i) begin
    case (reg_waddr_i[4:0])
        5'h00 : _x0  <= `ZERO_WORD;
        5'h01 : _x1  <= reg_wdata_i;
        5'h02 : _x2  <= reg_wdata_i;
        5'h03 : _x3  <= reg_wdata_i;
        5'h04 : _x4  <= reg_wdata_i;
        5'h05 : _x5  <= reg_wdata_i;
        5'h06 : _x6  <= reg_wdata_i;
        5'h07 : _x7  <= reg_wdata_i;
        5'h08 : _x8  <= reg_wdata_i;
        5'h09 : _x9  <= reg_wdata_i;
        5'h0a : _x10 <= reg_wdata_i;
        5'h0b : _x11 <= reg_wdata_i;
        5'h0c : _x12 <= reg_wdata_i;
        5'h0d : _x13 <= reg_wdata_i;
        5'h0e : _x14 <= reg_wdata_i;
        5'h0f : _x15 <= reg_wdata_i;
        5'h10 : _x16 <= reg_wdata_i;
        5'h11 : _x17 <= reg_wdata_i;
        5'h12 : _x18 <= reg_wdata_i;
        5'h13 : _x19 <= reg_wdata_i;
        5'h14 : _x20 <= reg_wdata_i;
        5'h15 : _x21 <= reg_wdata_i;
        5'h16 : _x22 <= reg_wdata_i;
        5'h17 : _x23 <= reg_wdata_i;
        5'h18 : _x24 <= reg_wdata_i;
        5'h19 : _x25 <= reg_wdata_i;
        5'h1a : _x26 <= reg_wdata_i;
        5'h1b : _x27 <= reg_wdata_i;
        5'h1c : _x28 <= reg_wdata_i;
        5'h1d : _x29 <= reg_wdata_i;
        5'h1e : _x30 <= reg_wdata_i;
        5'h1f : _x31 <= reg_wdata_i;
    endcase
    end
end

always @ (*) begin
    if (reg_waddr_vld_i && (reg1_raddr_i == reg_waddr_i)) begin
        if (reg1_raddr_i == 5'h00) begin
            _rs1 = `ZERO_WORD;
        end
        else begin
            _rs1 = reg_wdata_i;
        end
    end
    else begin
    case (reg1_raddr_i[4:0])
        5'h00 : _rs1 = _x0;
        5'h01 : _rs1 = _x1;
        5'h02 : _rs1 = _x2;
        5'h03 : _rs1 = _x3;
        5'h04 : _rs1 = _x4;
        5'h05 : _rs1 = _x5;
        5'h06 : _rs1 = _x6;
        5'h07 : _rs1 = _x7;
        5'h08 : _rs1 = _x8;
        5'h09 : _rs1 = _x9;
        5'h0a : _rs1 = _x10;
        5'h0b : _rs1 = _x11;
        5'h0c : _rs1 = _x12;
        5'h0d : _rs1 = _x13;
        5'h0e : _rs1 = _x14;
        5'h0f : _rs1 = _x15;
        5'h10 : _rs1 = _x16;
        5'h11 : _rs1 = _x17;
        5'h12 : _rs1 = _x18;
        5'h13 : _rs1 = _x19;
        5'h14 : _rs1 = _x20;
        5'h15 : _rs1 = _x21;
        5'h16 : _rs1 = _x22;
        5'h17 : _rs1 = _x23;
        5'h18 : _rs1 = _x24;
        5'h19 : _rs1 = _x25;
        5'h1a : _rs1 = _x26;
        5'h1b : _rs1 = _x27;
        5'h1c : _rs1 = _x28;
        5'h1d : _rs1 = _x29;
        5'h1e : _rs1 = _x30;
        5'h1f : _rs1 = _x31;
    endcase
    end
end

always @ (*) begin
    if (reg_waddr_vld_i && (reg2_raddr_i == reg_waddr_i)) begin
        if (reg2_raddr_i == 5'h00) begin
            _rs2 = `ZERO_WORD;
        end
        else begin
            _rs2 = reg_wdata_i;
        end
    end
    else begin
    case (reg2_raddr_i[4:0])
        5'h00 : _rs2 = _x0;
        5'h01 : _rs2 = _x1;
        5'h02 : _rs2 = _x2;
        5'h03 : _rs2 = _x3;
        5'h04 : _rs2 = _x4;
        5'h05 : _rs2 = _x5;
        5'h06 : _rs2 = _x6;
        5'h07 : _rs2 = _x7;
        5'h08 : _rs2 = _x8;
        5'h09 : _rs2 = _x9;
        5'h0a : _rs2 = _x10;
        5'h0b : _rs2 = _x11;
        5'h0c : _rs2 = _x12;
        5'h0d : _rs2 = _x13;
        5'h0e : _rs2 = _x14;
        5'h0f : _rs2 = _x15;
        5'h10 : _rs2 = _x16;
        5'h11 : _rs2 = _x17;
        5'h12 : _rs2 = _x18;
        5'h13 : _rs2 = _x19;
        5'h14 : _rs2 = _x20;
        5'h15 : _rs2 = _x21;
        5'h16 : _rs2 = _x22;
        5'h17 : _rs2 = _x23;
        5'h18 : _rs2 = _x24;
        5'h19 : _rs2 = _x25;
        5'h1a : _rs2 = _x26;
        5'h1b : _rs2 = _x27;
        5'h1c : _rs2 = _x28;
        5'h1d : _rs2 = _x29;
        5'h1e : _rs2 = _x30;
        5'h1f : _rs2 = _x31;
    endcase
    end
end

assign reg1_rdata_o[`DATA_BUS_WIDTH-1:0] = _rs1[`DATA_BUS_WIDTH-1:0];
assign reg2_rdata_o[`DATA_BUS_WIDTH-1:0] = _rs2[`DATA_BUS_WIDTH-1:0];

endmodule