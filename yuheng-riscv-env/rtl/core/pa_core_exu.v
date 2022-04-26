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

module pa_core_exu (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire [2:0]                   inst_set_i, // indicate instruction set, [2:0], only support rv32imfd yet
    input  wire [`INST_FUNC_WIDTH-1:0]  inst_func_i,

    input  wire [`DATA_BUS_WIDTH-1:0]   pc_i,

    input  wire [`DATA_BUS_WIDTH-1:0]   reg1_rdata_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   reg2_rdata_i,

    input  wire [19:0]                  uimm_i, // immediate data, only 20-bits

    input  wire [`REG_BUS_WIDTH-1:0]    reg_waddr_i,
    input  wire                         reg_waddr_vld_i,

    input  wire                         int_req_i,

    input  wire [`DATA_BUS_WIDTH-1:0]   csr_rdata_i,

    output wire                         csr_waddr_vld_o,
    output wire [`DATA_BUS_WIDTH-1:0]   csr_wdata_o,

    output wire                         mem_en_o,

    output wire                         hold_flag_o,

    output wire                         jump_flag_o,
    output wire [`DATA_BUS_WIDTH-1:0]   jump_addr_o,

    output wire [`REG_BUS_WIDTH-1:0]    reg_waddr_o,
    output wire                         reg_waddr_vld_o,

    output wire [`DATA_BUS_WIDTH-1:0]   iresult_o,
    output wire                         iresult_vld_o
);

wire                                    inst_set_rvi;
wire                                    inst_set_rvm;

assign inst_set_rvi  = inst_set_i[0];
assign inst_set_rvm  = inst_set_i[1];

wire                                    subop_unsign;
wire                                    subop_sign;

wire                                    subop_immv;
wire                                    subop_regv;

wire                                    subop_eq;
wire                                    subop_ne;
wire                                    subop_lt;
wire                                    subop_gt;

assign subop_unsign =  inst_func_i[31];
assign subop_sign   = ~inst_func_i[31];

assign subop_immv   =  inst_func_i[30];
assign subop_regv   = ~inst_func_i[30];

assign subop_eq     =  inst_func_i[27];
assign subop_ne     =  inst_func_i[26];
assign subop_lt     =  inst_func_i[25];
assign subop_gt     =  inst_func_i[24];

wire                                    op_add;
wire                                    op_sub;
wire                                    op_sll;
wire                                    op_srl;
wire                                    op_sra;
wire                                    op_or;
wire                                    op_and;
wire                                    op_xor;
wire                                    op_slt;
wire                                    op_load;
wire                                    op_store;
wire                                    op_fence;
wire                                    op_b;
wire                                    op_jal;
wire                                    op_jalr;
wire                                    op_auipc;
wire                                    op_lui;
wire                                    op_ecall;
wire                                    op_ebrea;
wire                                    op_mret;
wire                                    op_wfi;
wire                                    op_csrrw;
wire                                    op_csrrs;
wire                                    op_csrrc;

wire                                    op_mul;
wire                                    op_div;
wire                                    op_rem;

assign op_add   = inst_set_rvi && inst_func_i[23];
assign op_sub   = inst_set_rvi && inst_func_i[22];
assign op_sll   = inst_set_rvi && inst_func_i[21];
assign op_srl   = inst_set_rvi && inst_func_i[20];
assign op_sra   = inst_set_rvi && inst_func_i[19];
assign op_or    = inst_set_rvi && inst_func_i[18];
assign op_and   = inst_set_rvi && inst_func_i[17];
assign op_xor   = inst_set_rvi && inst_func_i[16];
assign op_slt   = inst_set_rvi && inst_func_i[15];
assign op_load  = inst_set_rvi && inst_func_i[14];
assign op_store = inst_set_rvi && inst_func_i[13];
assign op_fence = inst_set_rvi && inst_func_i[12];
assign op_b     = inst_set_rvi && inst_func_i[11];
assign op_jal   = inst_set_rvi && inst_func_i[10];
assign op_jalr  = inst_set_rvi && inst_func_i[ 9];
assign op_auipc = inst_set_rvi && inst_func_i[ 8];
assign op_lui   = inst_set_rvi && inst_func_i[ 7];
assign op_ecall = inst_set_rvi && inst_func_i[ 6];
assign op_ebrea = inst_set_rvi && inst_func_i[ 5];
assign op_mret  = inst_set_rvi && inst_func_i[ 4];
assign op_wfi   = inst_set_rvi && inst_func_i[ 3];
assign op_csrrw = inst_set_rvi && inst_func_i[ 2];
assign op_csrrs = inst_set_rvi && inst_func_i[ 1];
assign op_csrrc = inst_set_rvi && inst_func_i[ 0];

assign op_mul   = inst_set_rvm && inst_func_i[23];
assign op_div   = inst_set_rvm && inst_func_i[22];
assign op_rem   = inst_set_rvm && inst_func_i[21];

wire [`DATA_BUS_WIDTH-1:0]              inst_addr;

assign inst_addr[`DATA_BUS_WIDTH-1:0] = pc_i[`DATA_BUS_WIDTH-1:0] + 32'hffff_fff8; //-8, back 2-inst

wire [`DATA_BUS_WIDTH-1:0]              op_uimm5_zero;

assign op_uimm5_zero = {{27{1'b0}}, uimm_i[4:0]};

wire [`DATA_BUS_WIDTH-1:0]              op_uimm12_zero;
wire [`DATA_BUS_WIDTH-1:0]              op_uimm12_sign;

assign op_uimm12_zero = {{20{1'b0}}, uimm_i[11:0]};
assign op_uimm12_sign = {{20{uimm_i[11]}}, uimm_i[11:0]};

wire [`DATA_BUS_WIDTH-1:0]              op1_data;
wire [`DATA_BUS_WIDTH-1:0]              op2_data;

wire [`DATA_BUS_WIDTH-1:0]              op1_data_1;
wire [`DATA_BUS_WIDTH-1:0]              op1_data_2;

assign op1_data_1 = {32{op_csrrw || op_csrrs || op_csrrc}}
                  & (subop_immv ? op_uimm5_zero
                                : reg1_rdata_i);

assign op1_data_2 = {32{~op_csrrw && ~op_csrrs && ~op_csrrc}}
                  & reg1_rdata_i;

assign op1_data = op1_data_1
                | op1_data_2;

wire [`DATA_BUS_WIDTH-1:0]              op2_data_1;
wire [`DATA_BUS_WIDTH-1:0]              op2_data_2;
wire [`DATA_BUS_WIDTH-1:0]              op2_data_3;

assign op2_data_1 = {32{op_slt || op_load || op_store}}
                  & (subop_immv ? op_uimm12_sign
                                : reg2_rdata_i);

assign op2_data_2 = {32{op_csrrw || op_csrrs || op_csrrc}}
                  & `ZERO_WORD;

assign op2_data_3 = {32{~op_slt && ~op_load && ~op_store && ~op_csrrw && ~op_csrrs && ~op_csrrc}}
                  & (subop_immv ? subop_unsign ? op_uimm12_zero
                                               : op_uimm12_sign
                                : reg2_rdata_i);

assign op2_data = op2_data_1
                | op2_data_2
                | op2_data_3;

wire [`DATA_BUS_WIDTH-1:0]              iresult_add;
wire [`DATA_BUS_WIDTH-1:0]              iresult_sub;
wire [`DATA_BUS_WIDTH-1:0]              iresult_sll;
wire [`DATA_BUS_WIDTH-1:0]              iresult_srl;
wire [`DATA_BUS_WIDTH-1:0]              iresult_sra;
wire [`DATA_BUS_WIDTH-1:0]              iresult_or;
wire [`DATA_BUS_WIDTH-1:0]              iresult_and;
wire [`DATA_BUS_WIDTH-1:0]              iresult_xor;
wire [`DATA_BUS_WIDTH-1:0]              iresult_slt;
wire [`DATA_BUS_WIDTH-1:0]              iresult_mem;
wire [`DATA_BUS_WIDTH-1:0]              iresult_jalx;
wire [`DATA_BUS_WIDTH-1:0]              iresult_auipc;
wire [`DATA_BUS_WIDTH-1:0]              iresult_lui;
wire [`DATA_BUS_WIDTH-1:0]              iresult_csrw;
wire [`DATA_BUS_WIDTH-1:0]              iresult_csrs;
wire [`DATA_BUS_WIDTH-1:0]              iresult_csrc;

wire [`DATA_BUS_WIDTH-1:0]              result_pc_bxx;
wire [`DATA_BUS_WIDTH-1:0]              result_pc_jalx;

assign iresult_add = op1_data + op2_data;

assign iresult_sub = op1_data + (~op2_data + 32'h1);

assign iresult_sll = op1_data << op2_data[4:0]; //mux circuit

assign iresult_srl = op1_data >> op2_data[4:0]; //mux circuit

assign iresult_sra =  iresult_srl
                   | ~(32'hffff_ffff >> op2_data[4:0]) & {32{op1_data[31]}};

assign iresult_or  = op1_data | op2_data;

assign iresult_and = op1_data & op2_data;

assign iresult_xor = op1_data ^ op2_data;

wire [`DATA_BUS_WIDTH:0]                iresult_subs;
wire [`DATA_BUS_WIDTH:0]                iresult_subu;

wire                                    iresult_subs_zero;
wire                                    iresult_subu_zero;

assign iresult_subs = {op1_data[31], op1_data[31:0]}
                    + (~{op2_data[31], op2_data[31:0]} + 33'h1);

assign iresult_subu = {1'b0, op1_data[31:0]}
                    + (~{1'b0, op2_data[31:0]} + 33'h1);

assign iresult_subs_zero = ~(|iresult_subs[32:0]);
assign iresult_subu_zero = ~(|iresult_subu[32:0]);

assign iresult_slt = subop_unsign ? ((iresult_subu[32] && !iresult_subu_zero) ? 32'h1 : 32'h0)
                                  : ((iresult_subs[32] && !iresult_subs_zero) ? 32'h1 : 32'h0);

assign iresult_mem = op1_data + op2_data;

wire                                    op1_eq_op2;
wire                                    op1_ne_op2;
wire                                    op1_lt_op2;
wire                                    op1_ge_op2;

assign op1_eq_op2 = subop_eq &&  iresult_subs_zero;
assign op1_ne_op2 = subop_ne && !iresult_subs_zero;
assign op1_lt_op2 = subop_lt &&  iresult_subs[32];
assign op1_ge_op2 = subop_gt && ~iresult_subs[32];

wire                                    op1_ltu_op2;
wire                                    op1_geu_op2;

assign op1_ltu_op2 = subop_lt &&  iresult_subu[32];
assign op1_geu_op2 = subop_gt && ~iresult_subu[32];

wire                                    bxx_valid;

assign bxx_valid = subop_sign   && (op1_eq_op2  || op1_ne_op2 || op1_lt_op2 || op1_ge_op2)
                || subop_unsign && (op1_ltu_op2 || op1_geu_op2);

assign result_pc_bxx  = inst_addr + {{19{uimm_i[11]}}, uimm_i[11:0],1'b0};

assign result_pc_jalx = {32{op_jalr}} & ((op1_data + {{20{uimm_i[11]}}, uimm_i[11:0]}) & 32'hffff_fffe)
                      | {32{op_jal }} & (inst_addr + {{11{uimm_i[11]}}, uimm_i[19:0], 1'b0});

assign iresult_jalx = inst_addr + 32'h4;

assign iresult_auipc = inst_addr + {uimm_i[19:0], 12'b0};

assign iresult_lui = {uimm_i[19:0], 12'b0};

assign iresult_csrw = op1_data;
assign iresult_csrs = csr_rdata_i |  op1_data;
assign iresult_csrc = csr_rdata_i & ~op1_data;

reg  [`DATA_BUS_WIDTH-1:0]              iresult_i_final;

always @ (*) begin
    iresult_i_final = `ZERO_WORD;
    case (inst_func_i[`INST_FUNC_WIDTH-1:0] & 32'h00_ffffff)
        `INST_FUNC_ADD   : iresult_i_final = iresult_add;
        `INST_FUNC_SUB   : iresult_i_final = iresult_sub;
        `INST_FUNC_SLL   : iresult_i_final = iresult_sll;
        `INST_FUNC_SRL   : iresult_i_final = iresult_srl;
        `INST_FUNC_SRA   : iresult_i_final = iresult_sra;
        `INST_FUNC_OR    : iresult_i_final = iresult_or;
        `INST_FUNC_AND   : iresult_i_final = iresult_and;
        `INST_FUNC_XOR   : iresult_i_final = iresult_xor;
        `INST_FUNC_SLT   : iresult_i_final = iresult_slt;

        `INST_FUNC_LOAD  : iresult_i_final = iresult_mem;
        `INST_FUNC_STORE : iresult_i_final = iresult_mem;

        `INST_FUNC_FENCE : iresult_i_final = `ZERO_WORD; // not support yet

        `INST_FUNC_B     : iresult_i_final = `ZERO_WORD;

        `INST_FUNC_JAL   : iresult_i_final = iresult_jalx;
        `INST_FUNC_JALR  : iresult_i_final = iresult_jalx;

        `INST_FUNC_AUIPC : iresult_i_final = iresult_auipc;
        `INST_FUNC_LUI   : iresult_i_final = iresult_lui;

        `INST_FUNC_WFI   : iresult_i_final = `ZERO_WORD; // not support yet

        `INST_FUNC_CSRRW : iresult_i_final = csr_rdata_i;
        `INST_FUNC_CSRRS : iresult_i_final = csr_rdata_i;
        `INST_FUNC_CSRRC : iresult_i_final = csr_rdata_i;
    endcase
end

reg                                     iresult_i_vld;

always @ (*) begin
    iresult_i_vld = `INVALID;
    case (inst_func_i[`INST_FUNC_WIDTH-1:0] & 32'h00_ffffff)
        `INST_FUNC_ADD   : iresult_i_vld = `VALID;
        `INST_FUNC_SUB   : iresult_i_vld = `VALID;
        `INST_FUNC_SLL   : iresult_i_vld = `VALID;
        `INST_FUNC_SRL   : iresult_i_vld = `VALID;
        `INST_FUNC_SRA   : iresult_i_vld = `VALID;
        `INST_FUNC_OR    : iresult_i_vld = `VALID;
        `INST_FUNC_AND   : iresult_i_vld = `VALID;
        `INST_FUNC_XOR   : iresult_i_vld = `VALID;
        `INST_FUNC_SLT   : iresult_i_vld = `VALID;

        `INST_FUNC_LOAD  : iresult_i_vld = `VALID;
        `INST_FUNC_STORE : iresult_i_vld = `VALID;

        `INST_FUNC_FENCE : iresult_i_vld = `INVALID; // not support yet

        `INST_FUNC_B     : iresult_i_vld = `VALID;

        `INST_FUNC_JAL   : iresult_i_vld = `VALID;
        `INST_FUNC_JALR  : iresult_i_vld = `VALID;

        `INST_FUNC_AUIPC : iresult_i_vld = `VALID;
        `INST_FUNC_LUI   : iresult_i_vld = `VALID;

        `INST_FUNC_WFI   : iresult_i_vld = `INVALID; //not support yet

        `INST_FUNC_CSRRW : iresult_i_vld = `VALID;
        `INST_FUNC_CSRRS : iresult_i_vld = `VALID;
        `INST_FUNC_CSRRC : iresult_i_vld = `VALID;
    endcase
end

wire                                    subop_unsign_u1;
wire                                    subop_unsign_u2;

wire                                    subop_high;
wire                                    subop_low;

assign subop_unsign_u1 =  inst_func_i[31] & inst_func_i[28];
assign subop_unsign_u2 =  inst_func_i[31] & inst_func_i[29];

assign subop_high =  inst_func_i[30];
assign subop_low  = ~inst_func_i[30];

wire [`DATA_BUS_WIDTH-1:0]              op1_mul_data;
wire [`DATA_BUS_WIDTH-1:0]              op2_mul_data;

assign op1_mul_data = (~subop_unsign_u1 & reg1_rdata_i[31]) ? (~reg1_rdata_i + 32'b1)
                                                            : ( reg1_rdata_i);

assign op2_mul_data = (~subop_unsign_u2 & reg2_rdata_i[31]) ? (~reg2_rdata_i + 32'b1)
                                                            : ( reg2_rdata_i);

wire                                    iresult_mul_sign;

assign iresult_mul_sign = (~subop_unsign_u1 & reg1_rdata_i[31])
                        ^ (~subop_unsign_u2 & reg2_rdata_i[31]);

wire [`DATA_BUS_WIDTH-1:0]              op1_div_data;
wire [`DATA_BUS_WIDTH-1:0]              op2_div_data;

assign op1_div_data = op1_mul_data;
assign op2_div_data = op2_mul_data;

wire                                    iresult_q_sign;
wire                                    iresult_r_sign;

assign iresult_q_sign = iresult_mul_sign;

assign iresult_r_sign = (~subop_unsign_u1 & reg1_rdata_i[31]);

wire [63:0]                             iresult_mul;

pa_core_exu_mul u_pa_core_exu_mul (
    .data1_i                            (op1_mul_data),
    .data2_i                            (op2_mul_data),

    .sign_i                             (iresult_mul_sign),

    .data_o                             (iresult_mul)
);

wire [`DATA_BUS_WIDTH-1:0]              iresult_div_rem;
wire                                    iresult_div_rem_vld;

wire                                    div_hold;

wire [`REG_BUS_WIDTH-1:0]               div_reg_waddr;

pa_core_exu_div u_pa_core_exu_div (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .data1_i                            (op1_div_data),
    .data2_i                            (op2_div_data),

    .reg_waddr_i                        (reg_waddr_i),

    .op_i                               (op_div),

    .q_sign_i                           (iresult_q_sign),
    .r_sign_i                           (iresult_r_sign),

    .div_start_i                        (op_div || op_rem),

    .hold_o                             (div_hold),

    .reg_waddr_o                        (div_reg_waddr),

    .data_o                             (iresult_div_rem),
    .data_vld_o                         (iresult_div_rem_vld)
);

reg  [`DATA_BUS_WIDTH-1:0]              iresult_m_final;

always @ (*) begin
    iresult_m_final = `ZERO_WORD;
    case (inst_func_i[`INST_FUNC_WIDTH-1:0] & 32'h00_ffffff)
        `INST_FUNC_MUL : iresult_m_final = {32{subop_high}} & iresult_mul[63:32]
                                         | {32{subop_low}}  & iresult_mul[31:0];
    endcase
end

reg                                     iresult_m_vld;

always @ (*) begin
    iresult_m_vld = `INVALID;
    case (inst_func_i[`INST_FUNC_WIDTH-1:0] & 32'h00_ffffff)
        `INST_FUNC_MUL : iresult_m_vld = `VALID;
        `INST_FUNC_DIV : iresult_m_vld = `VALID;
        `INST_FUNC_REM : iresult_m_vld = `VALID;
    endcase
end

assign csr_waddr_vld_o  = ~int_req_i
                       && (op_csrrw || op_csrrs || op_csrrc);

assign csr_wdata_o[`DATA_BUS_WIDTH-1:0] = {32{op_csrrw}} & iresult_csrw
                                        | {32{op_csrrs}} & iresult_csrs
                                        | {32{op_csrrc}} & iresult_csrc;

assign jump_addr_o = {32{op_b}}              & result_pc_bxx
                   | {32{op_jal || op_jalr}} & result_pc_jalx;

assign jump_flag_o = (op_b && bxx_valid)
                  || (op_jal || op_jalr);

assign mem_en_o = ~int_req_i
               && (op_load || op_store);

assign hold_flag_o = ~int_req_i
                  && ( (op_store || op_load)
                    || (div_hold || op_div || op_rem) );

assign reg_waddr_o[`REG_BUS_WIDTH-1:0] = iresult_div_rem_vld ? {{`REG_BUS_WIDTH}{1'b1           }} & div_reg_waddr[`REG_BUS_WIDTH-1:0]
                                                             : {{`REG_BUS_WIDTH}{reg_waddr_vld_i}} & reg_waddr_i[`REG_BUS_WIDTH-1:0];

assign reg_waddr_vld_o = iresult_div_rem_vld ? 1'b1
                                             : reg_waddr_vld_i;

assign iresult_o[`DATA_BUS_WIDTH-1:0] = {32{inst_set_rvi & iresult_i_vld}} & iresult_i_final[`DATA_BUS_WIDTH-1:0]
                                      | {32{inst_set_rvm & iresult_m_vld}} & iresult_m_final[`DATA_BUS_WIDTH-1:0]
                                      | {32{iresult_div_rem_vld}} & iresult_div_rem[`DATA_BUS_WIDTH-1:0];

assign iresult_vld_o = inst_set_rvi & iresult_i_vld
                     | inst_set_rvm & iresult_m_vld
                     | iresult_div_rem_vld;

endmodule