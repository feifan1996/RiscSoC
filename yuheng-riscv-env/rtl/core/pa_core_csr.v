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

module pa_core_csr (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    output wire [`DATA_BUS_WIDTH-1:0]   csr_mtvec_o,
    output wire [`DATA_BUS_WIDTH-1:0]   csr_mepc_o,
    output wire [`DATA_BUS_WIDTH-1:0]   csr_mstatus_o,

    input  wire [`CSR_BUS_WIDTH-1:0]    csr_raddr_i,

    input  wire [`CSR_BUS_WIDTH-1:0]    csr_waddr_i,
    input  wire                         csr_waddr_vld_i,

    input  wire [`DATA_BUS_WIDTH-1:0]   csr_wdata_i,

    output wire [`DATA_BUS_WIDTH-1:0]   csr_rdata_o
);

reg  [`DATA_BUS_WIDTH-1:0]              _mtvec;     // Machine Trap Vector
reg  [`DATA_BUS_WIDTH-1:0]              _mepc;      // Machine Exception PC
reg  [`DATA_BUS_WIDTH-1:0]              _mcause;    // Machine Exception Cause
reg  [`DATA_BUS_WIDTH-1:0]              _mie;       // Machine Interrupt Enable
reg  [`DATA_BUS_WIDTH-1:0]              _mip;       // Machine Interrupt Pending
reg  [`DATA_BUS_WIDTH-1:0]              _mtval;     // Machine Trap Value
reg  [`DATA_BUS_WIDTH-1:0]              _mscratch;  // Machine Scratch
reg  [`DATA_BUS_WIDTH-1:0]              _mstatus;   // Machine Status
reg  [63:0]                             _cycle;     // Machine Cycle

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        _cycle <= 64'h0;
    end
    else begin
        _cycle <= _cycle + 64'h1;
    end
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        _mtvec    <= 32'h0;
        _mepc     <= 32'h0;
        _mcause   <= 32'h0;
        _mie      <= 32'h0;
        _mip      <= 32'h0;
        _mtval    <= 32'h0;
        _mscratch <= 32'h0;
        _mstatus  <= 32'h0000_0060; // MPP=11
    end
    else if (csr_waddr_vld_i) begin
    case (csr_waddr_i[11:0])
        `CSR_MTVEC    : _mtvec    <= csr_wdata_i;
        `CSR_MEPC     : _mepc     <= csr_wdata_i;
        `CSR_MCAUSE   : _mcause   <= csr_wdata_i;
        `CSR_MIE      : _mie      <= csr_wdata_i;
        `CSR_MIP      : _mip      <= csr_wdata_i;
        `CSR_MTVAL    : _mtval    <= csr_wdata_i;
        `CSR_MSCRATCH : _mscratch <= csr_wdata_i;
        `CSR_MSTATUS  : _mstatus  <= csr_wdata_i;
    endcase
    end
end

reg  [`DATA_BUS_WIDTH-1:0]              _csr;

always @ (*) begin
    _csr = `ZERO_WORD;
    case (csr_raddr_i[11:0])
        `CSR_MTVEC    : _csr = _mtvec;
        `CSR_MEPC     : _csr = _mepc;
        `CSR_MCAUSE   : _csr = _mcause;
        `CSR_MIE      : _csr = _mie;
        `CSR_MIP      : _csr = _mip;
        `CSR_MTVAL    : _csr = _mtval;
        `CSR_MSCRATCH : _csr = _mscratch;
        `CSR_MSTATUS  : _csr = _mstatus;
        `CSR_CYCLEH   : _csr = _cycle[63:32];
        `CSR_CYCLE    : _csr = _cycle[31: 0];
    endcase
end

assign csr_mtvec_o[`DATA_BUS_WIDTH-1:0]   = _mtvec[`DATA_BUS_WIDTH-1:0];
assign csr_mepc_o[`DATA_BUS_WIDTH-1:0]    = _mepc[`DATA_BUS_WIDTH-1:0];
assign csr_mstatus_o[`DATA_BUS_WIDTH-1:0] = _mstatus[`DATA_BUS_WIDTH-1:0];

assign csr_rdata_o[`DATA_BUS_WIDTH-1:0] = _csr[`DATA_BUS_WIDTH-1:0];

endmodule