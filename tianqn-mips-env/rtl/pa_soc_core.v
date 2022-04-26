`timescale 1ns / 1ps
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

module pa_soc_core (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    output wire                         txd
);

// 19:12 2022/1/17 start

// ## Start ##

wire                                    jump_to_flag;
wire [`DATA_BUS_WIDTH-1:0]              jump_to_pc;

// Step-1: IF

reg  [`DATA_BUS_WIDTH-1:0]              pc;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        pc[`DATA_BUS_WIDTH-1:0] <= 32'hffff_fffc;
    end
    else if (jump_to_flag) begin
        pc[`DATA_BUS_WIDTH-1:0] <= jump_to_pc[`DATA_BUS_WIDTH-1:0];
    end
    else begin
        pc[`DATA_BUS_WIDTH-1:0] <= pc[`DATA_BUS_WIDTH-1:0] + 32'h4;
    end
end

wire [`ADDR_BUS_WIDTH-1:0]              inst_addr;
wire [`DATA_BUS_WIDTH-1:0]              inst_data;

assign inst_addr[`DATA_BUS_WIDTH-1:0] = pc[`DATA_BUS_WIDTH-1:0];

pa_soc_itcm u_pa_soc_itcm (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .inst_addr_i                        (inst_addr),
    .inst_data_o                        (inst_data),

    .unalign_expt_o                     ()
);

// Step-2: ID

wire [5:0]                              id_decd_opcode;
wire [5:0]                              id_decd_funct6;

wire [`REG_BUS_WIDTH-1:0]               id_decd_rs;
wire [`REG_BUS_WIDTH-1:0]               id_decd_rt;
wire [`REG_BUS_WIDTH-1:0]               id_decd_rd;

wire [4:0]                              id_decd_imm5;

wire [15:0]                             id_decd_imm16;
wire [15:0]                             id_decd_off16;

wire [25:0]                             id_decd_imm26;

assign id_decd_opcode[5:0] = inst_data[31:26];
assign id_decd_funct6[5:0] = inst_data[5:0];

assign id_decd_rs[`REG_BUS_WIDTH-1:0] = inst_data[25:21]; //rs
assign id_decd_rt[`REG_BUS_WIDTH-1:0] = inst_data[20:16]; //rt
assign id_decd_rd[`REG_BUS_WIDTH-1:0] = inst_data[15:11]; //rd

assign id_decd_imm5[4:0] = inst_data[10:6]; //sa

assign id_decd_imm16[15:0] = inst_data[15:0]; //imm
assign id_decd_off16[15:0] = inst_data[15:0]; //offset

assign id_decd_imm26[25:0] = inst_data[25:0]; //intrs_index

wire                                    decd_strict;

assign decd_strict = 1'b1;

wire                                    opcode1_is_all0;

wire                                    rs_is_all0;
wire                                    rt_is_all0;
wire                                    rd_is_all0;
wire                                    sa_is_all0;

assign opcode1_is_all0 = (6'b000000 == id_decd_opcode[5:0]);

assign rs_is_all0 = (5'b00000 == id_decd_rs[4:0]);
assign rt_is_all0 = (5'b00000 == id_decd_rt[4:0]);
assign rd_is_all0 = (5'b00000 == id_decd_rd[4:0]);
assign sa_is_all0 = (5'b00000 == id_decd_imm5[4:0]);

wire                                    inst_add; // =addu in this design
wire                                    inst_addi; // =addiu in this design
wire                                    inst_sub; // =subu in this design
wire                                    inst_lw;
wire                                    inst_sw;
wire                                    inst_beq;
wire                                    inst_bne;
wire                                    inst_j;
wire                                    inst_jal;
wire                                    inst_jr;
wire                                    inst_jalr;
wire                                    inst_sll; // all0 will decoded to sll
wire                                    inst_srl;
wire                                    inst_sra;
wire                                    inst_and;
wire                                    inst_andi;
wire                                    inst_or;
wire                                    inst_ori;
wire                                    inst_xor;
wire                                    inst_xori;
wire                                    inst_nor;
wire                                    inst_lui;

assign inst_add  = opcode1_is_all0 && (5'b10000 == id_decd_funct6[5:1])
                && (  decd_strict && sa_is_all0
                  || !decd_strict );
assign inst_addi = (5'b00100 == id_decd_opcode[5:1]);

assign inst_sub  = opcode1_is_all0 && (5'b10001 == id_decd_funct6[5:1])
                && (  decd_strict && sa_is_all0
                  || !decd_strict );

assign inst_lw   = (6'b100011 == id_decd_opcode[5:0]);
assign inst_sw   = (6'b101011 == id_decd_opcode[5:0]);

assign inst_beq  = (6'b000100 == id_decd_opcode[5:0]);
assign inst_bne  = (6'b000101 == id_decd_opcode[5:0]);

assign inst_j    = (6'b000010 == id_decd_opcode[5:0]);
assign inst_jal  = (6'b000011 == id_decd_opcode[5:0]);
assign inst_jr   = opcode1_is_all0 && (6'b001000 == id_decd_funct6[5:0])
                && (  decd_strict && rt_is_all0 && rd_is_all0 && sa_is_all0
                  || !decd_strict );
assign inst_jalr = opcode1_is_all0 && (6'b001001 == id_decd_funct6[5:0])
                && (  decd_strict && rt_is_all0 && sa_is_all0
                  || !decd_strict );

assign inst_sll  = opcode1_is_all0 && (6'b000000 == id_decd_funct6[5:0])
                && (  decd_strict && rs_is_all0
                  || !decd_strict );
assign inst_srl  = opcode1_is_all0 && (6'b000010 == id_decd_funct6[5:0])
                && (  decd_strict && rs_is_all0
                  || !decd_strict );
assign inst_sra  = opcode1_is_all0 && (6'b000011 == id_decd_funct6[5:0])
                && (  decd_strict && rs_is_all0
                  || !decd_strict );

assign inst_and  = opcode1_is_all0 && (6'b100100 == id_decd_funct6[5:0])
                && (  decd_strict && sa_is_all0
                  || !decd_strict );
assign inst_andi = (6'b001100 == id_decd_opcode[5:0]);
assign inst_or   = opcode1_is_all0 && (6'b100101 == id_decd_funct6[5:0])
                && (  decd_strict && sa_is_all0
                  || !decd_strict );
assign inst_ori  = (6'b001101 == id_decd_opcode[5:0]);
assign inst_xor  = opcode1_is_all0 && (6'b100110 == id_decd_funct6[5:0])
                && (  decd_strict && sa_is_all0
                  || !decd_strict );
assign inst_xori = (6'b001110 == id_decd_opcode[5:0]);
assign inst_nor  = opcode1_is_all0 && (6'b100111 == id_decd_funct6[5:0])
                && (  decd_strict && sa_is_all0
                  || !decd_strict );

assign inst_lui  = (6'b001111 == id_decd_opcode[5:0])
                && (  decd_strict && rs_is_all0
                  || !decd_strict );

wire                                    illegal_inst;

// this is only for simulation, simple stacking is fun.
assign illegal_inst = !( inst_add || inst_addi
                      || inst_sub
                      || inst_lw  || inst_sw
                      || inst_beq || inst_bne
                      || inst_j   || inst_jal  || inst_jr  || inst_jalr
                      || inst_sll || inst_srl  || inst_sra
                      || inst_and || inst_andi
                      || inst_or  || inst_ori
                      || inst_xor || inst_xori
                      || inst_nor
                      || inst_lui );

wire                                    id_decd_imm5_vld;
wire                                    id_decd_imm16s_vld;
wire                                    id_decd_imm16z_vld;
wire                                    id_decd_imm16_vld;
wire                                    id_decd_imm26_vld;
wire                                    id_decd_imm_vld;

assign id_decd_imm5_vld   = ( inst_sll
                           || inst_srl
                           || inst_sra );

assign id_decd_imm16s_vld = ( inst_addi || inst_lw  || inst_sw
                           || inst_beq  || inst_bne );

assign id_decd_imm16z_vld = ( inst_andi || inst_ori || inst_xori
                           || inst_lui );

assign id_decd_imm16_vld  = ( id_decd_imm16s_vld
                           || id_decd_imm16z_vld );

assign id_decd_imm26_vld  = ( inst_j
                           || inst_jal );

assign id_decd_imm_vld    = ( id_decd_imm5_vld
                           || id_decd_imm16_vld
                           || id_decd_imm26_vld );

wire [`DATA_BUS_WIDTH-1:0]              imm5_data;
wire [`DATA_BUS_WIDTH-1:0]              imm16s_data;
wire [`DATA_BUS_WIDTH-1:0]              imm16z_data;
wire [`DATA_BUS_WIDTH-1:0]              imm16_data;
wire [`DATA_BUS_WIDTH-1:0]              imm26_data;
wire [`DATA_BUS_WIDTH-1:0]              imm_data;

assign imm5_data[`DATA_BUS_WIDTH-1:0]   = {27'b0, id_decd_imm5[4:0]};

assign imm16s_data[`DATA_BUS_WIDTH-1:0] = (inst_addi || inst_lw || inst_sw) ? {{16{id_decd_imm16[15]}}, id_decd_imm16[15:0]      }
                                                                            : {{14{id_decd_imm16[15]}}, id_decd_imm16[15:0], 2'b0};

assign imm16z_data[`DATA_BUS_WIDTH-1:0] = (inst_lui) ? {id_decd_imm16[15:0], 16'b0}
                                                     : {16'b0, id_decd_imm16[15:0]};

assign imm16_data[`DATA_BUS_WIDTH-1:0]  = {{`DATA_BUS_WIDTH}{id_decd_imm16s_vld}} & imm16s_data[`DATA_BUS_WIDTH-1:0]
                                        | {{`DATA_BUS_WIDTH}{id_decd_imm16z_vld}} & imm16z_data[`DATA_BUS_WIDTH-1:0];

assign imm26_data[`DATA_BUS_WIDTH-1:0]  = {4'b0, id_decd_imm26[25:0], 2'b0};

assign imm_data[`DATA_BUS_WIDTH-1:0]    = {{`DATA_BUS_WIDTH}{id_decd_imm5_vld }} & imm5_data [`DATA_BUS_WIDTH-1:0]
                                        | {{`DATA_BUS_WIDTH}{id_decd_imm16_vld}} & imm16_data[`DATA_BUS_WIDTH-1:0]
                                        | {{`DATA_BUS_WIDTH}{id_decd_imm26_vld}} & imm26_data[`DATA_BUS_WIDTH-1:0];

wire                                    id_decd_rs_vld;
wire                                    id_decd_rts_vld;
wire                                    id_decd_rtd_vld;
wire                                    id_decd_rd_vld;

assign id_decd_rs_vld  = ( inst_add || inst_addi
                        || inst_sub
                        || inst_lw  || inst_sw
                        || inst_beq || inst_bne
                        || inst_jr  || inst_jalr
                        || inst_and || inst_andi
                        || inst_or  || inst_ori
                        || inst_xor || inst_xori
                        || inst_nor );
assign id_decd_rts_vld = ( inst_add
                        || inst_sub
                        || inst_sw
                        || inst_beq || inst_bne
                        || inst_sll || inst_srl || inst_sra
                        || inst_and
                        || inst_or
                        || inst_xor
                        || inst_nor );
assign id_decd_rtd_vld = ( inst_addi
                        || inst_lw
                        || inst_andi
                        || inst_ori
                        || inst_xori
                        || inst_lui );
assign id_decd_rd_vld  = ( inst_add
                        || inst_sub
                        || inst_jal || inst_jalr
                        || inst_sll || inst_srl || inst_sra
                        || inst_and
                        || inst_or
                        || inst_xor
                        || inst_nor
                        || inst_lui );

wire [`REG_BUS_WIDTH-1:0]               reg_rs1_addr;
wire [`REG_BUS_WIDTH-1:0]               reg_rs2_addr;
wire [`REG_BUS_WIDTH-1:0]               reg_rd_addr;

assign reg_rs1_addr[`REG_BUS_WIDTH-1:0] = {{`REG_BUS_WIDTH}{id_decd_rs_vld }} & id_decd_rs[`REG_BUS_WIDTH-1:0];
assign reg_rs2_addr[`REG_BUS_WIDTH-1:0] = {{`REG_BUS_WIDTH}{id_decd_rts_vld}} & id_decd_rt[`REG_BUS_WIDTH-1:0];
assign reg_rd_addr [`REG_BUS_WIDTH-1:0] = {{`REG_BUS_WIDTH}{id_decd_rtd_vld}} & id_decd_rt[`REG_BUS_WIDTH-1:0]
                                        | {{`REG_BUS_WIDTH}{id_decd_rd_vld }} & id_decd_rd[`REG_BUS_WIDTH-1:0]
                                        | {{`REG_BUS_WIDTH}{inst_jal       }} & 5'd31;

wire [`DATA_BUS_WIDTH-1:0]              reg_rs1_data;
wire [`DATA_BUS_WIDTH-1:0]              reg_rs2_data;

wire [`DATA_BUS_WIDTH-1:0]              reg_rd_data;
wire                                    reg_rd_data_vld;

pa_soc_xreg u_pa_soc_xreg (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .rs1_addr                           (reg_rs1_addr),
    .rs1_data                           (reg_rs1_data),

    .rs2_addr                           (reg_rs2_addr),
    .rs2_data                           (reg_rs2_data),

    .rd_addr                            (reg_rd_addr),
    .rd_data                            (reg_rd_data),
    .rd_data_vld                        (reg_rd_data_vld)
);

// Step-3: EX

wire [`DATA_BUS_WIDTH-1:0]              current_pc;

assign current_pc[`DATA_BUS_WIDTH-1:0] = pc[`DATA_BUS_WIDTH-1:0]
                                       + 32'h4;

wire [`DATA_BUS_WIDTH-1:0]              op1_data;
wire [`DATA_BUS_WIDTH-1:0]              op2_data;

assign op1_data[`DATA_BUS_WIDTH-1:0] = reg_rs1_data[`DATA_BUS_WIDTH-1:0];
assign op2_data[`DATA_BUS_WIDTH-1:0] = id_decd_imm_vld ? imm_data[`DATA_BUS_WIDTH-1:0]
                                                       : reg_rs2_data[`DATA_BUS_WIDTH-1:0];

wire [`DATA_BUS_WIDTH-1:0]              inst_add_result;
wire [`DATA_BUS_WIDTH:0]                inst_sub_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_lw_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_sw_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_cmp_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_jal_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_sll_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_srl_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_sra_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_and_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_or_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_xor_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_nor_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_lui_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_bxx_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_jxx_result;
wire [`DATA_BUS_WIDTH-1:0]              inst_jrx_result;

assign inst_add_result[`DATA_BUS_WIDTH-1:0] = op1_data[`DATA_BUS_WIDTH-1:0]
                                            + op2_data[`DATA_BUS_WIDTH-1:0];

assign inst_sub_result[`DATA_BUS_WIDTH:0]   = {op1_data[`DATA_BUS_WIDTH-1], op1_data[`DATA_BUS_WIDTH-1:0]}
                                            - {op2_data[`DATA_BUS_WIDTH-1], op2_data[`DATA_BUS_WIDTH-1:0]};

assign inst_sw_result[`DATA_BUS_WIDTH-1:0]  = reg_rs2_data[`DATA_BUS_WIDTH-1:0];

// only support beq and bne
assign inst_cmp_result[`DATA_BUS_WIDTH-1:0] = reg_rs1_data ^ reg_rs2_data;

assign inst_jal_result[`DATA_BUS_WIDTH-1:0] = current_pc[`DATA_BUS_WIDTH-1:0]
                                            + 32'h4;

// left shift can convert to right shift without any cost
assign inst_sll_result[`DATA_BUS_WIDTH-1:0] = reg_rs2_data << imm_data[4:0];
assign inst_srl_result[`DATA_BUS_WIDTH-1:0] = reg_rs2_data >> imm_data[4:0];

assign inst_sra_result[`DATA_BUS_WIDTH-1:0] = $signed(reg_rs2_data) >>> imm_data[4:0];

assign inst_and_result[`DATA_BUS_WIDTH-1:0] =  op1_data & op2_data;
assign inst_or_result [`DATA_BUS_WIDTH-1:0] =  op1_data | op2_data;
assign inst_xor_result[`DATA_BUS_WIDTH-1:0] =  op1_data ^ op2_data;

assign inst_nor_result[`DATA_BUS_WIDTH-1:0] = ~inst_or_result;

assign inst_lui_result[`DATA_BUS_WIDTH-1:0] = imm_data[`DATA_BUS_WIDTH-1:0];

assign inst_bxx_result[`DATA_BUS_WIDTH-1:0] = current_pc[`DATA_BUS_WIDTH-1:0]
                                            + imm_data[`DATA_BUS_WIDTH-1:0];

assign inst_jxx_result[`DATA_BUS_WIDTH-1:0] = {{`DATA_BUS_WIDTH}{inst_j  || inst_jal }} & {current_pc[31:28], imm_data[27:0] };
assign inst_jrx_result[`DATA_BUS_WIDTH-1:0] = {{`DATA_BUS_WIDTH}{inst_jr || inst_jalr}} & {reg_rs1_data[`DATA_BUS_WIDTH-1:0]};

wire [`DATA_BUS_WIDTH-1:0]              ex_result;
wire [`DATA_BUS_WIDTH-1:0]              ex_pc_result;
wire [`DATA_BUS_WIDTH-1:0]              ex_mem_result;

assign ex_result[`DATA_BUS_WIDTH-1:0]     = {{`DATA_BUS_WIDTH}{inst_add || inst_addi}} & inst_add_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_sub             }} & inst_sub_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_lw              }} & inst_lw_result [`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_jal || inst_jalr}} & inst_jal_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_sll             }} & inst_sll_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_srl             }} & inst_srl_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_sra             }} & inst_sra_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_and || inst_andi}} & inst_and_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_or  || inst_ori }} & inst_or_result [`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_xor || inst_xori}} & inst_xor_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_nor             }} & inst_nor_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_lui             }} & inst_lui_result[`DATA_BUS_WIDTH-1:0];

assign ex_pc_result[`DATA_BUS_WIDTH-1:0]  = {{`DATA_BUS_WIDTH}{inst_beq || inst_bne }} & inst_bxx_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_j   || inst_jal }} & inst_jxx_result[`DATA_BUS_WIDTH-1:0]
                                          | {{`DATA_BUS_WIDTH}{inst_jr  || inst_jalr}} & inst_jrx_result[`DATA_BUS_WIDTH-1:0];

assign ex_mem_result[`DATA_BUS_WIDTH-1:0] = {{`DATA_BUS_WIDTH}{inst_lw  || inst_sw  }} & inst_add_result[`DATA_BUS_WIDTH-1:0];

assign reg_rd_data[`DATA_BUS_WIDTH-1:0] = ex_result[`DATA_BUS_WIDTH-1:0];
assign reg_rd_data_vld = (id_decd_rtd_vld || id_decd_rd_vld);

wire                                    ex_jump_vld;

wire                                    ex_cmp_unequal;

assign ex_cmp_unequal = (|inst_cmp_result[`DATA_BUS_WIDTH-1:0]);

assign ex_jump_vld = (inst_j)
                  || (inst_jr)
                  || (inst_jal)
                  || (inst_jalr)
                  || (inst_beq && !ex_cmp_unequal)
                  || (inst_bne &&  ex_cmp_unequal);

assign jump_to_flag = ex_jump_vld;
assign jump_to_pc[`DATA_BUS_WIDTH-1:0] = {{`DATA_BUS_WIDTH}{ex_jump_vld}} & ex_pc_result[`DATA_BUS_WIDTH-1:0];

pa_soc_uart u_pa_soc_uart (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .addr_i                             (ex_mem_result[7:0]),
    .data_we_i                          (inst_sw),
    .data_rd_i                          (inst_lw),
    .data_i                             (inst_sw_result),
    .data_o                             (inst_lw_result),

    .pad_txd                            (txd)
);

// ## Finish ##

// 22:05 2022/1/17 case close

endmodule