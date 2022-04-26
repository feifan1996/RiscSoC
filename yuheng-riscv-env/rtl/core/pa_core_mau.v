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

module pa_core_mau (
    input  wire [5:0]                   inst_func_i, // indicate instruction func, [stall, 31,29:28,14:13], only 6-bits

    input  wire [1:0]                   mem_addr_i, // memory byte address, width 2-bits

    input  wire [`DATA_BUS_WIDTH-1:0]   mem_data_i,
    input  wire                         mem_data_vld_i,

    output wire [`DATA_BUS_WIDTH-1:0]   mem_data_o,
    output wire                         mem_data_vld_o,

    input  wire [`DATA_BUS_WIDTH-1:0]   rbm_data_i,

    output wire [`DATA_BUS_WIDTH-1:0]   rbm_data_o,
    output wire [2:0]                   rbm_size_o,
    output wire                         rbm_we_o,
    output wire                         rbm_rd_o
);

wire                                    subop_sta1;
wire                                    subop_sta2;

wire                                    subop_sign;

wire                                    subop_byte;
wire                                    subop_half;
wire                                    subop_word;

assign subop_sta1 = ~inst_func_i[5];
assign subop_sta2 =  inst_func_i[5];
assign subop_sign = ~inst_func_i[4]; // to inst_func_i[31]

assign subop_byte = (inst_func_i[3:2] == 2'b01); // to inst_func_i[29:28]
assign subop_half = (inst_func_i[3:2] == 2'b10); // to inst_func_i[29:28]
assign subop_word = (inst_func_i[3:2] == 2'b00); // to inst_func_i[29:28]

wire                                    op_load;
wire                                    op_store;

assign op_load  = inst_func_i[1]; // to inst_func_i[14]
assign op_store = inst_func_i[0]; // to inst_func_i[13]

wire [`DATA_BUS_WIDTH-1:0]              mem_data;

assign mem_data = {32{subop_sta2 && op_load }} & rbm_data_i
                | {32{subop_sta1 && op_store}} & mem_data_i;

wire [`DATA_BUS_WIDTH-1:0]              mem_data_b0;
wire [`DATA_BUS_WIDTH-1:0]              mem_data_b1;
wire [`DATA_BUS_WIDTH-1:0]              mem_data_b2;
wire [`DATA_BUS_WIDTH-1:0]              mem_data_b3;

wire [`DATA_BUS_WIDTH-1:0]              mem_data_h0;
wire [`DATA_BUS_WIDTH-1:0]              mem_data_h1;

wire [`DATA_BUS_WIDTH-1:0]              mem_data_b;
wire [`DATA_BUS_WIDTH-1:0]              mem_data_h;
wire [`DATA_BUS_WIDTH-1:0]              mem_data_w;

assign mem_data_b0 = op_load ? {24'b0|{24{subop_sign && mem_data[ 7]}}, mem_data[ 7: 0]}
                             : {mem_data[31:0]};
assign mem_data_b1 = op_load ? {24'b0|{24{subop_sign && mem_data[15]}}, mem_data[15: 8]}
                             : {mem_data[23:0], 8'b0 };
assign mem_data_b2 = op_load ? {24'b0|{24{subop_sign && mem_data[23]}}, mem_data[23:16]}
                             : {mem_data[15:0], 16'b0};
assign mem_data_b3 = op_load ? {24'b0|{24{subop_sign && mem_data[31]}}, mem_data[31:24]}
                             : {mem_data[ 7:0], 24'b0};

assign mem_data_b  = {32{mem_addr_i[1:0] == 2'b00}} & mem_data_b0
                   | {32{mem_addr_i[1:0] == 2'b01}} & mem_data_b1
                   | {32{mem_addr_i[1:0] == 2'b10}} & mem_data_b2
                   | {32{mem_addr_i[1:0] == 2'b11}} & mem_data_b3;

assign mem_data_h0 = op_load ? {16'b0|{16{subop_sign && mem_data[15]}}, mem_data[15: 0]}
                             : {mem_data[31:0]};
assign mem_data_h1 = op_load ? {16'b0|{16{subop_sign && mem_data[31]}}, mem_data[31:16]}
                             : {mem_data[15:0], 16'b0};

assign mem_data_h  = {32{mem_addr_i[1] == 1'b0}} & mem_data_h0
                   | {32{mem_addr_i[1] == 1'b1}} & mem_data_h1;

assign mem_data_w  = {mem_data[31:0]};

wire [`DATA_BUS_WIDTH-1:0]              mem_wdata;

assign mem_wdata = {32{subop_byte}} & mem_data_b
                 | {32{subop_half}} & mem_data_h
                 | {32{subop_word}} & mem_data_w;

// to exec unit, process data
assign mem_data_o[`DATA_BUS_WIDTH-1:0] = {32{subop_sta2 && op_load }} & mem_wdata[`DATA_BUS_WIDTH-1:0];
assign mem_data_vld_o = subop_sta2 && op_load;

// to bus, store data
assign rbm_size_o = {subop_word, subop_half, subop_byte};

assign rbm_data_o[`DATA_BUS_WIDTH-1:0] = {32{subop_sta1 && op_store}} & mem_wdata[`DATA_BUS_WIDTH-1:0];
assign rbm_we_o = subop_sta1 && op_store;
assign rbm_rd_o = subop_sta1 && op_load;

endmodule