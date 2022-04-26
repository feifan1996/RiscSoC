`timescale 1ns / 1ps
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

module pa_chip_top (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire                         rxd,
    output wire                         txd
);

wire [`ADDR_BUS_WIDTH-1:0]              m0_addr;
wire [`DATA_BUS_WIDTH-1:0]              m0_rdata;

wire [`ADDR_BUS_WIDTH-1:0]              m1_addr;
wire                                    m1_rd;
wire                                    m1_we;
wire [2:0]                              m1_size;
wire [`DATA_BUS_WIDTH-1:0]              m1_wdata;
wire [`DATA_BUS_WIDTH-1:0]              m1_rdata;

wire                                    s0_rd;
wire                                    s0_we;
wire [`DATA_BUS_WIDTH-1:0]              s0_data;

wire                                    s1_rd;
wire                                    s1_we;
wire [`DATA_BUS_WIDTH-1:0]              s1_data;

wire                                    s2_rd;
wire                                    s2_we;
wire [`DATA_BUS_WIDTH-1:0]              s2_data;

wire                                    s3_rd;
wire                                    s3_we;
wire [`DATA_BUS_WIDTH-1:0]              s3_data;

wire                                    s4_rd;
wire                                    s4_we;
wire [`DATA_BUS_WIDTH-1:0]              s4_data;

wire                                    s5_rd;
wire                                    s5_we;
wire [`DATA_BUS_WIDTH-1:0]              s5_data;

wire                                    s6_rd;
wire                                    s6_we;
wire [`DATA_BUS_WIDTH-1:0]              s6_data;


wire                                    clk_50m;
wire                                    rst_n;

assign clk_50m = clk_i;
assign rst_n = rst_n_i;

wire                                    irq_flag;

pa_core_top u_pa_core_top (
    .clk_i                              (clk_50m),
    .rst_n_i                            (rst_n),

    .irq_i                              (irq_flag),

    .ibus_addr_o                        (m0_addr),
    .ibus_data_i                        (m0_rdata),

    .dbus_addr_o                        (m1_addr),
    .dbus_rd_o                          (m1_rd),
    .dbus_we_o                          (m1_we),
    .dbus_size_o                        (m1_size),
    .dbus_data_o                        (m1_wdata),
    .dbus_data_i                        (m1_rdata)
);

pa_soc_rbm u_pa_soc_rbm1 (
    .m_addr_i                           (m1_addr),
    .m_data_o                           (m1_rdata),
    .m_we_i                             (m1_we),
    .m_rd_i                             (m1_rd),

//  0x0000_0000 ~ 0x0fff_ffff
    .s0_data_i                          (s0_data),
    .s0_we_o                            (s0_we),
    .s0_rd_o                            (s0_rd),

//  0x1000_0000 ~ 0x1fff_ffff
    .s1_data_i                          (s1_data),
    .s1_we_o                            (s1_we),
    .s1_rd_o                            (s1_rd),

//  0x2000_0000 ~ 0x2fff_ffff
    .s2_data_i                          (s2_data),
    .s2_we_o                            (s2_we),
    .s2_rd_o                            (s2_rd),

//  0x3000_0000 ~ 0x3fff_ffff
    .s3_data_i                          (s3_data),
    .s3_we_o                            (s3_we),
    .s3_rd_o                            (s3_rd),

//  0x4000_0000 ~ 0x4fff_ffff
    .s4_data_i                          (s4_data),
    .s4_we_o                            (s4_we),
    .s4_rd_o                            (s4_rd),

//  0x5000_0000 ~ 0x5fff_ffff
    .s5_data_i                          (s5_data),
    .s5_we_o                            (s5_we),
    .s5_rd_o                            (s5_rd),

//  0x6000_0000 ~ 0x6fff_ffff
    .s6_data_i                          (s6_data),
    .s6_we_o                            (s6_we),
    .s6_rd_o                            (s6_rd)
);

pa_perips_tcm u_pa_perips_rom (
    .clk_i                              (clk_50m),
    .rst_n_i                            (rst_n),

    .addr1_i                            (m1_addr),
    .rd1_i                              (s0_rd),
    .we1_i                              (s0_we),
    .size1_i                            (m1_size),
    .data1_i                            (m1_wdata),
    .data1_o                            (s0_data),

    .addr2_i                            (m0_addr),
    .rd2_i                              (1'b1),
    .data2_o                            (m0_rdata)
);

pa_perips_tcm u_pa_perips_ram (
    .clk_i                              (clk_50m),
    .rst_n_i                            (rst_n),

    .addr1_i                            (m1_addr),
    .rd1_i                              (s1_rd),
    .we1_i                              (s1_we),
    .size1_i                            (m1_size),
    .data1_i                            (m1_wdata),
    .data1_o                            (s1_data),

    .addr2_i                            (32'b0),
    .rd2_i                              (1'b0),
    .data2_o                            ()
);

pa_perips_timer u_pa_perips_timer1 (
    .clk_i                              (clk_50m),
    .rst_n_i                            (rst_n),

    .addr_i                             (m1_addr[7:0]),
    .data_rd_i                          (s2_rd),
    .data_we_i                          (s2_we),
    .data_i                             (m1_wdata),
    .data_o                             (s2_data),

    .irq_o                              (irq_flag)
);

pa_perips_uart u_pa_perips_uart1 (
    .clk_i                              (clk_50m),
    .rst_n_i                            (rst_n),

    .addr_i                             (m1_addr[7:0]),
    .data_rd_i                          (s3_rd),
    .data_we_i                          (s3_we),
    .data_i                             (m1_wdata),
    .data_o                             (s3_data),

    .pad_rxd                            (rxd),
    .pad_txd                            (txd)
);

wire                                    PAD_A2;
wire                                    PAD_A3;

pa_perips_uart u_pa_perips_uart2 (
    .clk_i                              (clk_50m),
    .rst_n_i                            (rst_n),

    .addr_i                             (m1_addr[7:0]),
    .data_rd_i                          (s4_rd),
    .data_we_i                          (s4_we),
    .data_i                             (m1_wdata),
    .data_o                             (s4_data),

    .pad_rxd                            (PAD_A2),
    .pad_txd                            (PAD_A3)
);

pa_perips_uart u_pa_perips_uart3 (
    .clk_i                              (clk_50m),
    .rst_n_i                            (rst_n),

    .addr_i                             (m1_addr[7:0]),
    .data_rd_i                          (s5_rd),
    .data_we_i                          (s5_we),
    .data_i                             (m1_wdata),
    .data_o                             (s5_data),

    .pad_rxd                            (PAD_A3),
    .pad_txd                            (PAD_A2)
);

assign s6_data[`DATA_BUS_WIDTH-1:0] = 32'b0;

endmodule