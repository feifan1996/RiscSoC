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

module pa_core_rtu (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire [`REG_BUS_WIDTH-1:0]    reg1_raddr_i,
    input  wire [`REG_BUS_WIDTH-1:0]    reg2_raddr_i,

    input  wire [`REG_BUS_WIDTH-1:0]    reg_waddr_i,
    input  wire                         reg_waddr_vld_i,

    input  wire [`DATA_BUS_WIDTH-1:0]   reg_wdata_i,

    output wire [`DATA_BUS_WIDTH-1:0]   reg1_rdata_o,
    output wire [`DATA_BUS_WIDTH-1:0]   reg2_rdata_o,

    output wire [`DATA_BUS_WIDTH-1:0]   csr_mtvec_o,
    output wire [`DATA_BUS_WIDTH-1:0]   csr_mepc_o,
    output wire [`DATA_BUS_WIDTH-1:0]   csr_mstatus_o,

    input  wire [`CSR_BUS_WIDTH-1:0]    csr_raddr_i,

    input  wire [`CSR_BUS_WIDTH-1:0]    csr_waddr_i,
    input  wire                         csr_waddr_vld_i,

    input  wire [`DATA_BUS_WIDTH-1:0]   csr_wdata_i,

    output wire [`DATA_BUS_WIDTH-1:0]   csr_rdata_o
);

pa_core_csr u_pa_core_csr (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .csr_mtvec_o                        (csr_mtvec_o),
    .csr_mepc_o                         (csr_mepc_o),
    .csr_mstatus_o                      (csr_mstatus_o),

    .csr_raddr_i                        (csr_raddr_i),

    .csr_waddr_i                        (csr_waddr_i),
    .csr_waddr_vld_i                    (csr_waddr_vld_i),

    .csr_wdata_i                        (csr_wdata_i),

    .csr_rdata_o                        (csr_rdata_o)
);

pa_core_xreg u_pa_core_xreg (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .reg1_raddr_i                       (reg1_raddr_i),
    .reg2_raddr_i                       (reg2_raddr_i),

    .reg_waddr_i                        (reg_waddr_i),
    .reg_waddr_vld_i                    (reg_waddr_vld_i),

    .reg_wdata_i                        (reg_wdata_i),

    .reg1_rdata_o                       (reg1_rdata_o),
    .reg2_rdata_o                       (reg2_rdata_o)
);

endmodule