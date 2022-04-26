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

module pa_core_clint (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire                         inst_set_i,  // indicate instruction set, [0], only support rv32i yet
    input  wire [2:0]                   inst_func_i, // indicate instruction func, [6:4], only 3-bits

    input  wire [`DATA_BUS_WIDTH-1:0]   pc_i,

    input  wire [`DATA_BUS_WIDTH-1:0]   csr_mtvec_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   csr_mepc_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   csr_mstatus_i,

    input  wire                         irq_i,

    input  wire                         jump_flag_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   jump_addr_i,

    output wire [`CSR_BUS_WIDTH-1:0]    csr_waddr_o,
    output wire                         csr_waddr_vld_o,
    output wire [`DATA_BUS_WIDTH-1:0]   csr_wdata_o,

    output wire                         hold_flag_o,

    output wire                         int_req_o,
    output wire [`DATA_BUS_WIDTH-1:0]   int_addr_o
);

localparam S_CSR_IDLE                   = 5'd0;
localparam S_CSR_MEPC                   = 5'd1;
localparam S_CSR_MSTATUS                = 5'd2;
localparam S_CSR_MCAUSE                 = 5'd3;
localparam S_CSR_MRET                   = 5'd4;

localparam WR_CSR_IDLE                  = 5'd0;
localparam WR_CSR_MEPC                  = 5'd1;
localparam WR_CSR_MSTATUS               = 5'd2;
localparam WR_CSR_MCAUSE                = 5'd3;
localparam WR_CSR_MRET                  = 5'd4;

localparam INT_TYPE_NONE                = 2'b00;
localparam INT_TYPE_EXCRPTION           = 2'b01;
localparam INT_TYPE_INTERRUPT           = 2'b10;
localparam INT_TYPE_SOFTINT             = 2'b11;

wire                                    global_int_en;
wire                                    global_int_si;

assign global_int_en = csr_mstatus_i[3];  // MIE
assign global_int_si = csr_mstatus_i[31]; // SINT

wire                                    inst_set_rvi;

assign inst_set_rvi  = inst_set_i;

wire                                    op_ecall;
wire                                    op_ebreak;
wire                                    op_mret;

assign op_ecall  = inst_set_rvi && inst_func_i[2]; // to inst_func_i[6]
assign op_ebreak = inst_set_rvi && inst_func_i[1]; // to inst_func_i[5]
assign op_mret   = inst_set_rvi && inst_func_i[0]; // to inst_func_i[4]

reg  [1:0]                              irq;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        irq[1:0] <= 2'b00;
    end
    else begin
        irq[1:0] <= {irq[0], irq_i};
    end
end

wire                                    irq_vld;
wire                                    irq_vld_trig;

assign irq_vld_trig = ~irq[1] && irq[0];

reg                                     irq_vld_temp;

reg  [1:0]                              int_type;
reg  [4:0]                              int_state;

assign irq_vld = irq_vld_trig || irq_vld_temp;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        irq_vld_temp <= `INVALID;
    end
    else begin
        if (int_state != WR_CSR_IDLE) begin
            irq_vld_temp <= `INVALID;
        end
        else begin
            irq_vld_temp <= irq_vld;
        end
    end
end

always @ (*) begin
    if (!rst_n_i) begin
        int_type  <= INT_TYPE_NONE;
        int_state <= WR_CSR_IDLE;
    end
    else begin
        if (op_ecall || op_ebreak) begin
            int_type  <= INT_TYPE_EXCRPTION;
            int_state <= WR_CSR_MEPC;
        end
        else if (op_mret) begin
            int_type  <= INT_TYPE_EXCRPTION;
            int_state <= WR_CSR_MRET;
        end
        else if (global_int_en && irq_vld) begin
            int_type  <= INT_TYPE_INTERRUPT;
            int_state <= WR_CSR_MEPC;
        end
        else if (global_int_en && global_int_si) begin
            int_type  <= INT_TYPE_SOFTINT;
            int_state <= WR_CSR_MEPC;
        end
        else begin
            int_type  <= INT_TYPE_NONE;
            int_state <= WR_CSR_IDLE;
        end
    end
end

reg  [4:0]                              csr_state;

wire [`DATA_BUS_WIDTH-1:0]              inst_addr;
wire [`DATA_BUS_WIDTH-1:0]              jump_addr;

assign inst_addr[`DATA_BUS_WIDTH-1:0] = pc_i[`DATA_BUS_WIDTH-1:0] + 32'hffff_fff8; // -8, add 4 at handler
assign jump_addr[`DATA_BUS_WIDTH-1:0] = jump_addr_i[`DATA_BUS_WIDTH-1:0] + 32'hffff_fffc; // -4, add 4 at handler

wire [`DATA_BUS_WIDTH-1:0]              break_addr_soft;
wire [`DATA_BUS_WIDTH-1:0]              break_addr_ext;

assign break_addr_soft[`DATA_BUS_WIDTH-1:0]  = {32{int_type[0] & op_ecall}}  & (jump_flag_i ? jump_addr : inst_addr)
                                             | {32{int_type[0] & op_ebreak}} & (jump_flag_i ? jump_addr : inst_addr);

assign break_addr_ext[`DATA_BUS_WIDTH-1:0]   = {32{int_type[1]}} & (jump_flag_i ? jump_addr : inst_addr);

wire [`DATA_BUS_WIDTH-1:0]              break_cause_soft;
wire [`DATA_BUS_WIDTH-1:0]              break_cause_ext;

assign break_cause_soft[`DATA_BUS_WIDTH-1:0] = {32{int_type[0] & op_ecall }} & 32'd11
                                             | {32{int_type[0] & op_ebreak}} & 32'd3;

assign break_cause_ext[`DATA_BUS_WIDTH-1:0]  = {32{int_type[1] & ~int_type[0]}} & 32'h8000_0003
                                             | {32{int_type[1] &  int_type[0]}} & 32'h8000_0004;

reg  [`DATA_BUS_WIDTH-1:0]              break_addr;
reg  [`DATA_BUS_WIDTH-1:0]              break_cause;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        csr_state   <= S_CSR_IDLE;
        break_addr  <= 0;
        break_cause <= 0;
    end
    else begin
    case (csr_state)
        S_CSR_IDLE    : begin
        case (int_state)
            WR_CSR_MEPC : begin
                csr_state   <= S_CSR_MEPC;
                break_addr  <= (break_addr_soft  | break_addr_ext );
                break_cause <= (break_cause_soft | break_cause_ext);
            end
            WR_CSR_MRET : begin
                csr_state   <= S_CSR_MRET;
                break_cause <= 32'd0;
            end
        endcase
        end

        S_CSR_MEPC    : csr_state <= S_CSR_MSTATUS;
        S_CSR_MSTATUS : csr_state <= S_CSR_MCAUSE;
        S_CSR_MCAUSE  : csr_state <= S_CSR_IDLE;

        S_CSR_MRET    : csr_state <= S_CSR_IDLE;

        default : begin
            csr_state <= S_CSR_IDLE;
        end
    endcase
    end
end

reg  [`CSR_BUS_WIDTH-1:0]               csr_waddr;
reg                                     csr_waddr_vld;
reg  [`DATA_BUS_WIDTH-1:0]              csr_wdata;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        csr_waddr_vld <= `INVALID;
        csr_waddr     <= `ZERO_WORD;
        csr_wdata     <= `ZERO_WORD;
    end
    else begin
    case (csr_state)
        S_CSR_MEPC    : begin
            csr_waddr_vld <= `VALID;
            csr_waddr     <= {20'h0, `CSR_MEPC};
            csr_wdata     <= break_addr;
        end

        S_CSR_MSTATUS : begin
            csr_waddr_vld <= `VALID;
            csr_waddr     <= {20'h0, `CSR_MSTATUS};
            csr_wdata     <= {csr_mstatus_i[31:4], 1'b0, csr_mstatus_i[2:0]};
        end

        S_CSR_MCAUSE  : begin
            csr_waddr_vld <= `VALID;
            csr_waddr     <= {20'h0, `CSR_MCAUSE};
            csr_wdata     <= break_cause;
        end

        S_CSR_MRET    : begin
            csr_waddr_vld <= `VALID;
            csr_waddr     <= {20'h0, `CSR_MSTATUS};
            csr_wdata     <= {csr_mstatus_i[31:4], csr_mstatus_i[7], csr_mstatus_i[2:0]};
        end

        default : begin
            csr_waddr_vld <= `INVALID;
            csr_waddr     <= `ZERO_WORD;
            csr_wdata     <= `ZERO_WORD;
        end
    endcase
    end
end

wire [`DATA_BUS_WIDTH-1:0]              csr_mtvec;
wire [`DATA_BUS_WIDTH-1:0]              csr_mepc;

assign csr_mtvec[`DATA_BUS_WIDTH-1:0] = (break_cause == 32'h8000_0004) ? (csr_mtvec_i[`DATA_BUS_WIDTH-1:0] + 32'h0000_0004)
                                                                       :  csr_mtvec_i[`DATA_BUS_WIDTH-1:0];

assign csr_mepc[`DATA_BUS_WIDTH-1:0]  = csr_mepc_i[`DATA_BUS_WIDTH-1:0];

reg                                     int_req;
reg  [`DATA_BUS_WIDTH-1:0]              int_addr;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        int_req  <= `INVALID;
        int_addr <= `ZERO_WORD;
    end
    else begin
    case (csr_state)
        S_CSR_MCAUSE : begin
            int_req  <= `VALID;
            int_addr <= csr_mtvec;
        end
        S_CSR_MRET   : begin
            int_req  <= `VALID;
            int_addr <= csr_mepc;
        end
        default : begin
            int_req  <= `INVALID;
            int_addr <= `ZERO_WORD;
        end
    endcase
    end
end

assign csr_waddr_vld_o = csr_waddr_vld;

assign csr_waddr_o[`CSR_BUS_WIDTH-1:0]  = csr_waddr[`CSR_BUS_WIDTH-1:0];
assign csr_wdata_o[`DATA_BUS_WIDTH-1:0] = csr_wdata[`DATA_BUS_WIDTH-1:0];

assign hold_flag_o = (csr_state != S_CSR_IDLE) || csr_waddr_vld;

assign int_req_o = int_req;

assign int_addr_o[`DATA_BUS_WIDTH-1:0] = int_addr[`DATA_BUS_WIDTH-1:0];

endmodule