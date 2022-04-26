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

module pa_core_idu (
    input  wire [`DATA_BUS_WIDTH-1:0]   inst_data_i,

    output wire [`INST_SET_WIDTH-1:0]   inst_set_o,
    output wire [`INST_TYPE_WIDTH-1:0]  inst_type_o,
    output wire [`INST_FUNC_WIDTH-1:0]  inst_func_o,

    output wire [`REG_BUS_WIDTH-1:0]    reg1_raddr_o,
    output wire [`REG_BUS_WIDTH-1:0]    reg2_raddr_o,

    output wire [`REG_BUS_WIDTH-1:0]    reg_waddr_o,
    output wire                         reg_waddr_vld_o,

    output wire [`DATA_BUS_WIDTH-1:0]   uimm_o,
    output wire [`CSR_BUS_WIDTH-1:0]    csr_o
);

wire [4:0]                              inst_rs3;
wire [6:0]                              inst_func7;
wire [4:0]                              inst_rs2;
wire [4:0]                              inst_rs1;
wire [2:0]                              inst_rm;
wire [2:0]                              inst_func3;
wire [4:0]                              inst_rd;
wire [6:0]                              inst_opcode;

assign inst_rs3[4:0]    = inst_data_i[31:27];
assign inst_func7[6:0]  = inst_data_i[31:25];
assign inst_rs2[4:0]    = inst_data_i[24:20];
assign inst_rs1[4:0]    = inst_data_i[19:15];
assign inst_rm[2:0]     = inst_data_i[14:12];
assign inst_func3[2:0]  = inst_data_i[14:12];
assign inst_rd[4:0]     = inst_data_i[11: 7];
assign inst_opcode[6:0] = inst_data_i[ 6: 0];

wire [4:0]                              inst_uimm5;

assign inst_uimm5[4:0] = inst_data_i[19:15];

wire [11:0]                             inst_uimm12_b_type;
wire [11:0]                             inst_uimm12_i_type;
wire [11:0]                             inst_uimm12_s_type;

assign inst_uimm12_b_type[11:0] = {inst_data_i[31],
                                   inst_data_i[7],
                                   inst_data_i[30:25],
                                   inst_data_i[11: 8]};

assign inst_uimm12_i_type[11:0] = {inst_data_i[31:20]};

assign inst_uimm12_s_type[11:0] = {inst_data_i[31:25],
                                   inst_data_i[11: 7]};

wire [19:0]                             inst_uimm20_j_type;
wire [19:0]                             inst_uimm20_u_type;

assign inst_uimm20_j_type[19:0] = {inst_data_i[31],
                                   inst_data_i[19:12],
                                   inst_data_i[20],
                                   inst_data_i[30:21]};

assign inst_uimm20_u_type[19:0] = {inst_data_i[31:12]};

wire                                    inst_rs2_all0;
wire                                    inst_rs1_all0;
wire                                    inst_func3_all0;
wire                                    inst_rd_all0;

assign inst_rs2_all0   = ~(|inst_rs2[4:0]);
assign inst_rs1_all0   = ~(|inst_rs1[4:0]);
assign inst_func3_all0 = ~(|inst_func3[2:0]);
assign inst_rd_all0    = ~(|inst_rd[4:0]);

wire                                    inst_is_ecall;
wire                                    inst_is_ebreak;
wire                                    inst_is_mret;
wire                                    inst_is_wfi;
wire                                    inst_is_csrrx;
wire                                    inst_is_csrri;

assign inst_is_ecall  = (inst_data_i[31:20] == 12'h000) && inst_rs1_all0 && inst_func3_all0 && inst_rd_all0;
assign inst_is_ebreak = (inst_data_i[31:20] == 12'h001) && inst_rs1_all0 && inst_func3_all0 && inst_rd_all0;
assign inst_is_mret   = (inst_data_i[31:20] == 12'h302) && inst_rs1_all0 && inst_func3_all0 && inst_rd_all0;
assign inst_is_wfi    = (inst_data_i[31:20] == 12'h105) && inst_rs1_all0 && inst_func3_all0;
assign inst_is_csrrx  = (~inst_func3[2]) && (~inst_func3_all0);
assign inst_is_csrri  = ( inst_func3[2]) && (~inst_func3_all0);

reg  [`INST_SET_WIDTH-1:0]              inst_set;
reg  [`INST_TYPE_WIDTH-1:0]             inst_type;

always @ (*) begin
case (inst_opcode[6:0])
    7'b0000011 ,       // lb/lh/lw/lbu/lhu
    7'b1100111 ,       // jalr
    7'b0010011 : begin // addi/slli/slti/sltiu/xori/srli/srai/ori/andi
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_RV32I;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_I;
    end

    7'b0010111 ,       // auipc
    7'b0110111 : begin // lui
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_RV32I;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_U;
    end

    7'b0100011 : begin // sb/sh/sw
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_RV32I;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_S;
    end

    7'b0110011 : begin // add/sub/sll/slt/sltu/xor/srl/sra/or/and
                       // mul/mulh/mulhsu/mulhu/div/divu/rem/remu
        inst_set[`INST_SET_WIDTH-1:0]   = inst_func7[0] ? `INST_SET_RV32M
                                                        : `INST_SET_RV32I;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_R;
    end

    7'b1010011 : begin // fxx
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_RV32FD;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_R;
    end

    7'b1000011 ,       // fmadd
    7'b1000111 ,       // fmsub
    7'b1001111 ,       // fnmadd
    7'b1001011 : begin // fnmsub
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_RV32FD;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_R;
    end

    7'b1100011 : begin // beq/bne/blt/bge/bltu/bgeu
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_RV32I;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_B;
    end

    7'b1101111 : begin // jal
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_RV32I;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_J;
    end

    7'b1110011 : begin // ecall/ebreak/mret/wfi/csrrw/csrrs/csrrc/csrrwi/csrrsi/csrrci
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_RV32I;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_CSR;
    end

    default    : begin
        inst_set[`INST_SET_WIDTH-1:0]   = `INST_SET_NULL;
        inst_type[`INST_TYPE_WIDTH-1:0] = `INST_TYPE_NULL;
    end
endcase
end

reg  [`DATA_BUS_WIDTH-1:0]              uimm;
reg  [`CSR_BUS_WIDTH-1:0]               csr;

always @ (*) begin
case (inst_type[6:0])
    `INST_TYPE_R : begin
        uimm = `ZERO_WORD;
        csr  = `CSR_NULL;
    end
    `INST_TYPE_I : begin
        uimm = {20'b0, inst_uimm12_i_type[11:0]};
        csr  = `CSR_NULL;
    end
    `INST_TYPE_S : begin
        uimm = {20'b0, inst_uimm12_s_type[11:0]};
        csr  = `CSR_NULL;
    end
    `INST_TYPE_B : begin
        uimm = {20'b0, inst_uimm12_b_type[11:0]};
        csr  = `CSR_NULL;
    end
    `INST_TYPE_U : begin
        uimm = {12'b0, inst_uimm20_u_type[19:0]};
        csr  = `CSR_NULL;
    end
    `INST_TYPE_J : begin
        uimm = {12'b0, inst_uimm20_j_type[19:0]};
        csr  = `CSR_NULL;
    end
    `INST_TYPE_CSR : begin
        uimm = inst_is_csrri ? {27'b0, inst_uimm5[4:0]} : `ZERO_WORD;
        csr  = {inst_func7[6:0], inst_rs2[4:0]};
    end
    default : begin
        uimm = `ZERO_WORD;
        csr  = `CSR_NULL;
    end
endcase
end

wire [`DATA_BUS_WIDTH-1:0]              inst_uimm;

assign inst_uimm[`DATA_BUS_WIDTH-1:0] = uimm[`DATA_BUS_WIDTH-1:0];

reg  [`INST_FUNC_WIDTH-1:0]             inst_func;

always @ (*) begin
    inst_func = `INST_FUNC_NULL;
    case (inst_opcode[6:0])
        7'b0000011 : begin
        case (inst_func3[2:0])
            `INST_LB  : inst_func = `INST_FUNC_LOAD | `INST_FUNC_SUFFIX_IMM | `INST_FUNC_SUFFIX_BYTE;
            `INST_LH  : inst_func = `INST_FUNC_LOAD | `INST_FUNC_SUFFIX_IMM | `INST_FUNC_SUFFIX_HALF;
            `INST_LW  : inst_func = `INST_FUNC_LOAD | `INST_FUNC_SUFFIX_IMM;
            `INST_LBU : inst_func = `INST_FUNC_LOAD | `INST_FUNC_SUFFIX_IMM | `INST_FUNC_SUFFIX_BYTE | `INST_FUNC_SUFFIX_UNSIGN;
            `INST_LHU : inst_func = `INST_FUNC_LOAD | `INST_FUNC_SUFFIX_IMM | `INST_FUNC_SUFFIX_HALF | `INST_FUNC_SUFFIX_UNSIGN;
        endcase
        end

        7'b0010011 : begin
        case (inst_func3[2:0])
            `INST_ADD  : inst_func = `INST_FUNC_ADD | `INST_FUNC_SUFFIX_IMM;
            `INST_SLL  : inst_func = `INST_FUNC_SLL | `INST_FUNC_SUFFIX_IMM;
            `INST_SLT  : inst_func = `INST_FUNC_SLT | `INST_FUNC_SUFFIX_IMM;
            `INST_SLTU : inst_func = `INST_FUNC_SLT | `INST_FUNC_SUFFIX_IMM | `INST_FUNC_SUFFIX_UNSIGN;
            `INST_XOR  : inst_func = `INST_FUNC_XOR | `INST_FUNC_SUFFIX_IMM;
            `INST_SRL  : inst_func = (inst_func7[5] ? `INST_FUNC_SRA : `INST_FUNC_SRL) | `INST_FUNC_SUFFIX_IMM;
            `INST_OR   : inst_func = `INST_FUNC_OR  | `INST_FUNC_SUFFIX_IMM;
            `INST_AND  : inst_func = `INST_FUNC_AND | `INST_FUNC_SUFFIX_IMM;
        endcase
        end

        7'b0010111 : begin
            inst_func = `INST_FUNC_AUIPC;
        end

        7'b0100011 : begin
        case (inst_func3[2:0])
            `INST_SB : inst_func = `INST_FUNC_STORE | `INST_FUNC_SUFFIX_IMM | `INST_FUNC_SUFFIX_BYTE;
            `INST_SH : inst_func = `INST_FUNC_STORE | `INST_FUNC_SUFFIX_IMM | `INST_FUNC_SUFFIX_HALF;
            `INST_SW : inst_func = `INST_FUNC_STORE | `INST_FUNC_SUFFIX_IMM;
        endcase
        end

        7'b0110011 : begin
        if (inst_func7[0]) begin
            case (inst_func3[2:0])
                `INST_MUL    : inst_func = `INST_FUNC_MUL;
                `INST_MULH   : inst_func = `INST_FUNC_MUL | `INST_FUNC_SUFFIX_HIGH;
                `INST_MULHSU : inst_func = `INST_FUNC_MUL | `INST_FUNC_SUFFIX_U2 | `INST_FUNC_SUFFIX_HIGH;
                `INST_MULHU  : inst_func = `INST_FUNC_MUL | `INST_FUNC_SUFFIX_U1 | `INST_FUNC_SUFFIX_U2 | `INST_FUNC_SUFFIX_HIGH;
                `INST_DIV    : inst_func = `INST_FUNC_DIV;
                `INST_DIVU   : inst_func = `INST_FUNC_DIV | `INST_FUNC_SUFFIX_U1 | `INST_FUNC_SUFFIX_U2;
                `INST_REM    : inst_func = `INST_FUNC_REM;
                `INST_REMU   : inst_func = `INST_FUNC_REM | `INST_FUNC_SUFFIX_U1 | `INST_FUNC_SUFFIX_U2;
            endcase
        end
        else begin
            case (inst_func3[2:0])
                `INST_ADD    : inst_func = (inst_func7[5] ? `INST_FUNC_SUB : `INST_FUNC_ADD);
                `INST_SLL    : inst_func = `INST_FUNC_SLL;
                `INST_SLT    : inst_func = `INST_FUNC_SLT;
                `INST_SLTU   : inst_func = `INST_FUNC_SLT | `INST_FUNC_SUFFIX_UNSIGN;
                `INST_XOR    : inst_func = `INST_FUNC_XOR;
                `INST_SRL    : inst_func = (inst_func7[5] ? `INST_FUNC_SRA : `INST_FUNC_SRL);
                `INST_OR     : inst_func = `INST_FUNC_OR;
                `INST_AND    : inst_func = `INST_FUNC_AND;
            endcase
        end
        end

        7'b0110111 : begin
            inst_func = `INST_FUNC_LUI | `INST_FUNC_SUFFIX_IMM;
        end

        7'b1010011 : begin
        inst_func[13] = inst_func7[0];
        case (inst_func7[6:2])
            `INST_FADD   : inst_func[12:0] = `INST_FUNC_FADD;
            `INST_FSUB   : inst_func[12:0] = `INST_FUNC_FSUB;
            `INST_FMUL   : inst_func[12:0] = `INST_FUNC_FMUL;
            `INST_FDIV   : inst_func[12:0] = `INST_FUNC_FDIV;
            `INST_FSQRT  : inst_func[12:0] = `INST_FUNC_FSQRT;
            `INST_FSEL   : inst_func[12:0] = inst_func3[0] ? `INST_FUNC_FMAX
                                                           : `INST_FUNC_FMIN;
            `INST_FCMP   : inst_func[12:0] = inst_func3[0] ? `INST_FUNC_FLT
                                           : inst_func3[1] ? `INST_FUNC_FEQ
                                                           : `INST_FUNC_FLE;
            `INST_FSGNJ  : inst_func[12:0] = inst_func3[0] ? `INST_FUNC_FSGNJN
                                           : inst_func3[1] ? `INST_FUNC_FSGNJX
                                                           : `INST_FUNC_FSGNJ;
            `INST_FMVWX  : inst_func[12:0] = `INST_FUNC_FMVWX;
            `INST_FMVXW  : inst_func[12:0] = inst_func3[0] ? `INST_FUNC_FCLASS
                                                           : `INST_FUNC_FMVXW;
            `INST_FCVTFI : inst_func[12:0] = `INST_FUNC_FCVTIF;
            `INST_FCVTIF : inst_func[12:0] = `INST_FUNC_FCVTFI;
            `INST_FCVTSD : inst_func[12:0] = inst_func7[0] ? `INST_FUNC_FCVTDS
                                                           : `INST_FUNC_FCVTSD;
        endcase
        end

        7'b1100011 : begin
        case (inst_func3[2:0])
            `INST_BEQ  : inst_func = `INST_FUNC_B | `INST_FUNC_SUFFIX_EQ;
            `INST_BNE  : inst_func = `INST_FUNC_B | `INST_FUNC_SUFFIX_NE;
            `INST_BLT  : inst_func = `INST_FUNC_B | `INST_FUNC_SUFFIX_LT;
            `INST_BGE  : inst_func = `INST_FUNC_B | `INST_FUNC_SUFFIX_GT | `INST_FUNC_SUFFIX_EQ;
            `INST_BLTU : inst_func = `INST_FUNC_B | `INST_FUNC_SUFFIX_LT | `INST_FUNC_SUFFIX_UNSIGN;
            `INST_BGEU : inst_func = `INST_FUNC_B | `INST_FUNC_SUFFIX_GT | `INST_FUNC_SUFFIX_EQ | `INST_FUNC_SUFFIX_UNSIGN;
        endcase
        end

        7'b1101111 : begin
            inst_func = `INST_FUNC_JAL;
        end

        7'b1100111 : begin
            inst_func = `INST_FUNC_JALR;
        end

        7'b1110011 : begin
        case (inst_func3[2:0])
            `INST_ECALL  : begin
            case ({inst_is_ecall, inst_is_ebreak, inst_is_mret, inst_is_wfi})
                4'b1000  : inst_func = `INST_FUNC_ECALL;
                4'b0100  : inst_func = `INST_FUNC_EBREAK;
                4'b0010  : inst_func = `INST_FUNC_MRET;
                4'b0001  : inst_func = `INST_FUNC_WFI;
                default  : inst_func = `INST_FUNC_NULL;
            endcase
            end

            `INST_CSRRW  : inst_func = `INST_FUNC_CSRRW;
            `INST_CSRRS  : inst_func = `INST_FUNC_CSRRS;
            `INST_CSRRC  : inst_func = `INST_FUNC_CSRRC;
            `INST_CSRRWI : inst_func = `INST_FUNC_CSRRW | `INST_FUNC_SUFFIX_IMM;
            `INST_CSRRSI : inst_func = `INST_FUNC_CSRRS | `INST_FUNC_SUFFIX_IMM;
            `INST_CSRRCI : inst_func = `INST_FUNC_CSRRC | `INST_FUNC_SUFFIX_IMM;
        endcase
        end
    endcase
end

reg                                     reg_raddr1_vld;
reg                                     reg_raddr2_vld;
reg                                     reg_waddr_vld;
reg                                     imm_vld;
reg                                     csr_vld;

always @ (*) begin
case (inst_type[6:0])
    `INST_TYPE_R : begin
        reg_raddr1_vld = `VALID;
        reg_raddr2_vld = `VALID;
        case (inst_set[`INST_SET_WIDTH-1:0])
            `INST_SET_RV32I ,
            `INST_SET_RV32M : begin
                reg_waddr_vld = `VALID;
            end
            `INST_SET_RV32FD : begin
                reg_waddr_vld = `INVALID;
            end
            default : begin
                reg_waddr_vld = `INVALID;
            end
        endcase
        imm_vld        = `INVALID;
        csr_vld        = `INVALID;
    end
    `INST_TYPE_I : begin
        reg_raddr1_vld = `VALID;
        reg_raddr2_vld = `INVALID;
        reg_waddr_vld  = `VALID;
        imm_vld        = `VALID;
        csr_vld        = `INVALID;
    end
    `INST_TYPE_S : begin
        reg_raddr1_vld = `VALID;
        reg_raddr2_vld = `VALID;
        reg_waddr_vld  = `INVALID;
        imm_vld        = `VALID;
        csr_vld        = `INVALID;
    end
    `INST_TYPE_B : begin
        reg_raddr1_vld = `VALID;
        reg_raddr2_vld = `VALID;
        reg_waddr_vld  = `INVALID;
        imm_vld        = `VALID;
        csr_vld        = `INVALID;
    end
    `INST_TYPE_U : begin
        reg_raddr1_vld = `INVALID;
        reg_raddr2_vld = `INVALID;
        reg_waddr_vld  = `VALID;
        imm_vld        = `VALID;
        csr_vld        = `INVALID;
    end
    `INST_TYPE_J : begin
        reg_raddr1_vld = `INVALID;
        reg_raddr2_vld = `INVALID;
        reg_waddr_vld  = `VALID;
        imm_vld        = `VALID;
        csr_vld        = `INVALID;
    end
    `INST_TYPE_CSR : begin
        reg_raddr1_vld =  inst_is_csrrx ? `VALID : `INVALID;
        reg_raddr2_vld = `INVALID;
        reg_waddr_vld  = `VALID;
        imm_vld        =  inst_is_csrri ? `VALID : `INVALID;
        csr_vld        = `VALID;
    end
    default : begin
        reg_raddr1_vld = `INVALID;
        reg_raddr2_vld = `INVALID;
        reg_waddr_vld  = `INVALID;
        imm_vld        = `INVALID;
        csr_vld        = `INVALID;
    end
endcase
end

wire                                    idu_en;

assign idu_en = `VALID;

assign inst_set_o[`INST_SET_WIDTH-1:0]   = {{`INST_SET_WIDTH }{idu_en}} & inst_set[`INST_SET_WIDTH-1:0];
assign inst_type_o[`INST_TYPE_WIDTH-1:0] = {{`INST_TYPE_WIDTH}{idu_en}} & inst_type[`INST_TYPE_WIDTH-1:0];
assign inst_func_o[`INST_FUNC_WIDTH-1:0] = {{`INST_FUNC_WIDTH}{idu_en}} & inst_func[`INST_FUNC_WIDTH-1:0];

assign reg1_raddr_o[`REG_BUS_WIDTH-1:0]  = {{`REG_BUS_WIDTH}{reg_raddr1_vld}} & inst_rs1[`REG_BUS_WIDTH-1:0];
assign reg2_raddr_o[`REG_BUS_WIDTH-1:0]  = {{`REG_BUS_WIDTH}{reg_raddr2_vld}} & inst_rs2[`REG_BUS_WIDTH-1:0];

assign reg_waddr_o[`REG_BUS_WIDTH-1:0]   = {{`REG_BUS_WIDTH}{reg_waddr_vld}}  & inst_rd[`REG_BUS_WIDTH-1:0];
assign reg_waddr_vld_o  = reg_waddr_vld;

assign uimm_o[`DATA_BUS_WIDTH-1:0] = {{`DATA_BUS_WIDTH}{imm_vld}} & inst_uimm[`DATA_BUS_WIDTH-1:0];
assign csr_o[`CSR_BUS_WIDTH-1:0]   = {{`CSR_BUS_WIDTH }{csr_vld}} & csr[`CSR_BUS_WIDTH-1:0];

endmodule