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

module pa_core_top (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire                         irq_i,

    output wire [`ADDR_BUS_WIDTH-1:0]   ibus_addr_o,
    input  wire [`DATA_BUS_WIDTH-1:0]   ibus_data_i,

    output wire [`ADDR_BUS_WIDTH-1:0]   dbus_addr_o,
    output                              dbus_rd_o,
    output                              dbus_we_o,
    output wire [2:0]                   dbus_size_o,
    output wire [`DATA_BUS_WIDTH-1:0]   dbus_data_o,
    input  wire [`DATA_BUS_WIDTH-1:0]   dbus_data_i
);

wire                                    hold_flag;

wire                                    jump_flag;
wire [`ADDR_BUS_WIDTH-1:0]              jump_addr;

reg                                     hold_stall_flag;
reg                                     jump_stall_flag;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        hold_stall_flag <= 1'b0;
        jump_stall_flag <= 1'b0;
    end
    else begin
        hold_stall_flag <= hold_flag;
        jump_stall_flag <= jump_flag;
    end
end

wire [`ADDR_BUS_WIDTH-1:0]              inst_addr;
wire [`DATA_BUS_WIDTH-1:0]              inst_data;

pa_core_pcgen u_pa_core_pcgen (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .reset_flag_i                       (`INVALID),

    .hold_flag_i                        (hold_flag),

    .jump_flag_i                        (jump_flag),
    .jump_addr_i                        (jump_addr),

    .pc_o                               (inst_addr)
);

assign ibus_addr_o[`ADDR_BUS_WIDTH-1:0] = inst_addr[`ADDR_BUS_WIDTH-1:0];
assign inst_data[`DATA_BUS_WIDTH-1:0] = ibus_data_i[`DATA_BUS_WIDTH-1:0];

pa_core_ifu u_pa_core_ifu (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i)
);

reg  [`DATA_BUS_WIDTH-1:0]              idu_inst_data_t;

always @ (posedge clk_i) begin
    if (hold_stall_flag) begin
        idu_inst_data_t[`DATA_BUS_WIDTH-1:0] <= idu_inst_data_t[`DATA_BUS_WIDTH-1:0];
    end
    else begin
        idu_inst_data_t[`DATA_BUS_WIDTH-1:0] <= inst_data[`DATA_BUS_WIDTH-1:0];
    end
end

wire [`DATA_BUS_WIDTH-1:0]              idu_inst_data;

assign idu_inst_data[`DATA_BUS_WIDTH-1:0] = hold_stall_flag ? idu_inst_data_t[`DATA_BUS_WIDTH-1:0]
                                                            : inst_data[`DATA_BUS_WIDTH-1:0];

wire [`INST_SET_WIDTH-1:0]              inst_set;
wire [`INST_TYPE_WIDTH-1:0]             inst_type;
wire [`INST_FUNC_WIDTH-1:0]             inst_func;

wire [`REG_BUS_WIDTH-1:0]               reg1_raddr;
wire [`REG_BUS_WIDTH-1:0]               reg2_raddr;

wire [`REG_BUS_WIDTH-1:0]               reg_waddr;
wire                                    reg_waddr_vld;

wire [`DATA_BUS_WIDTH-1:0]              uimm_data;

wire [`CSR_BUS_WIDTH-1:0]               csr_addr;

pa_core_idu u_pa_core_idu (
    .inst_data_i                        (idu_inst_data),

    .inst_set_o                         (inst_set),
    .inst_type_o                        (inst_type),
    .inst_func_o                        (inst_func),

    .reg1_raddr_o                       (reg1_raddr),
    .reg2_raddr_o                       (reg2_raddr),

    .reg_waddr_o                        (reg_waddr),
    .reg_waddr_vld_o                    (reg_waddr_vld),

    .uimm_o                             (uimm_data),
    .csr_o                              (csr_addr)
);

wire [`REG_BUS_WIDTH-1:0]               idu_reg1_raddr;
wire [`REG_BUS_WIDTH-1:0]               idu_reg2_raddr;

assign idu_reg1_raddr[`REG_BUS_WIDTH-1:0] = reg1_raddr[`REG_BUS_WIDTH-1:0];
assign idu_reg2_raddr[`REG_BUS_WIDTH-1:0] = reg2_raddr[`REG_BUS_WIDTH-1:0];

wire [`DATA_BUS_WIDTH-1:0]              idu_reg1_rdata;
wire [`DATA_BUS_WIDTH-1:0]              idu_reg2_rdata;

reg  [`INST_SET_WIDTH-1:0]              exu_inst_set;
reg  [`INST_FUNC_WIDTH-1:0]             exu_inst_func;

reg  [`REG_BUS_WIDTH-1:0]               exu_reg_waddr;
reg                                     exu_reg_waddr_vld;

reg  [`DATA_BUS_WIDTH-1:0]              exu_reg1_rdata;
reg  [`DATA_BUS_WIDTH-1:0]              exu_reg2_rdata;

reg  [`DATA_BUS_WIDTH-1:0]              exu_uimm_data;
reg  [`CSR_BUS_WIDTH-1:0]               exu_csr_addr;

wire                                    flush_flag;

assign flush_flag = (jump_flag || jump_stall_flag)
                 || (hold_flag);

always @ (posedge clk_i or negedge rst_n_i) begin
    if ((!rst_n_i) || flush_flag) begin
        exu_inst_set[`INST_SET_WIDTH-1:0]   <= 0;
        exu_inst_func[`INST_FUNC_WIDTH-1:0] <= 0;

        exu_reg1_rdata[`DATA_BUS_WIDTH-1:0] <= 0;
        exu_reg2_rdata[`DATA_BUS_WIDTH-1:0] <= 0;

        exu_reg_waddr[`REG_BUS_WIDTH-1:0]   <= 0;
        exu_reg_waddr_vld                   <= 0;

        exu_csr_addr[`CSR_BUS_WIDTH-1:0]    <= 0;

        exu_uimm_data[`DATA_BUS_WIDTH-1:0]  <= 0;
    end
    else begin
        exu_inst_set[`INST_SET_WIDTH-1:0]   <= inst_set[`INST_SET_WIDTH-1:0];
        exu_inst_func[`INST_FUNC_WIDTH-1:0] <= inst_func[`INST_FUNC_WIDTH-1:0];

        exu_reg1_rdata[`DATA_BUS_WIDTH-1:0] <= idu_reg1_rdata[`DATA_BUS_WIDTH-1:0];
        exu_reg2_rdata[`DATA_BUS_WIDTH-1:0] <= idu_reg2_rdata[`DATA_BUS_WIDTH-1:0];

        exu_reg_waddr[`REG_BUS_WIDTH-1:0]   <= reg_waddr[`REG_BUS_WIDTH-1:0];
        exu_reg_waddr_vld                   <= reg_waddr_vld;

        exu_csr_addr[`CSR_BUS_WIDTH-1:0]    <= csr_addr[`CSR_BUS_WIDTH-1:0];

        exu_uimm_data[`DATA_BUS_WIDTH-1:0]  <= uimm_data[`DATA_BUS_WIDTH-1:0];
    end
end

wire [`DATA_BUS_WIDTH-1:0]              iresult;
wire                                    iresult_vld;

wire [`DATA_BUS_WIDTH-1:0]              exu_csr_rdata;

wire [`CSR_BUS_WIDTH-1:0]               exu_csr_waddr;
wire                                    exu_csr_waddr_vld;
wire [`DATA_BUS_WIDTH-1:0]              exu_csr_wdata;

wire                                    mem_en_flag;

wire                                    exu_hold_flag;

wire [`REG_BUS_WIDTH-1:0]               reg_waddr_wb;
wire                                    reg_waddr_wb_vld;

wire                                    int_req;

wire                                    exu_jump_flag;
wire [`ADDR_BUS_WIDTH-1:0]              exu_jump_addr;

pa_core_exu u_pa_core_exu (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .inst_set_i                         (exu_inst_set[2:0]),
    .inst_func_i                        (exu_inst_func),

    .pc_i                               (inst_addr),

    .reg1_rdata_i                       (exu_reg1_rdata),
    .reg2_rdata_i                       (exu_reg2_rdata),

    .uimm_i                             (exu_uimm_data[19:0]),

    .reg_waddr_i                        (exu_reg_waddr),
    .reg_waddr_vld_i                    (exu_reg_waddr_vld),

    .int_req_i                          (int_req),

    .csr_rdata_i                        (exu_csr_rdata),

    .csr_waddr_vld_o                    (exu_csr_waddr_vld),
    .csr_wdata_o                        (exu_csr_wdata),

    .mem_en_o                           (mem_en_flag),

    .hold_flag_o                        (exu_hold_flag),

    .jump_flag_o                        (exu_jump_flag),
    .jump_addr_o                        (exu_jump_addr),

    .reg_waddr_o                        (reg_waddr_wb),
    .reg_waddr_vld_o                    (reg_waddr_wb_vld),

    .iresult_o                          (iresult),
    .iresult_vld_o                      (iresult_vld)
);

wire [`DATA_BUS_WIDTH-1:0]              csr_mtvec_data;
wire [`DATA_BUS_WIDTH-1:0]              csr_mepc_data;
wire [`DATA_BUS_WIDTH-1:0]              csr_mstatus_data;

wire [`CSR_BUS_WIDTH-1:0]               int_csr_waddr;
wire                                    int_csr_waddr_vld;
wire [`DATA_BUS_WIDTH-1:0]              int_csr_wdata;

wire                                    int_hold_flag;

wire [`ADDR_BUS_WIDTH-1:0]              int_jump_addr;

pa_core_clint u_pa_core_clint (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .inst_set_i                         (exu_inst_set[0]),
    .inst_func_i                        (exu_inst_func[6:4]),

    .pc_i                               (inst_addr),

    .csr_mtvec_i                        (csr_mtvec_data),
    .csr_mepc_i                         (csr_mepc_data),
    .csr_mstatus_i                      (csr_mstatus_data),

    .irq_i                              (irq_i),

    .jump_flag_i                        (exu_jump_flag),
    .jump_addr_i                        (exu_jump_addr),

    .csr_waddr_o                        (int_csr_waddr),
    .csr_waddr_vld_o                    (int_csr_waddr_vld),
    .csr_wdata_o                        (int_csr_wdata),

    .hold_flag_o                        (int_hold_flag),

    .int_req_o                          (int_req),
    .int_addr_o                         (int_jump_addr)
);

assign hold_flag = exu_hold_flag
                || int_hold_flag;

assign jump_flag = exu_jump_flag
                || int_req;

assign jump_addr = int_req ? int_jump_addr
                           : exu_jump_addr;

wire [`CSR_BUS_WIDTH-1:0]               csr_waddr;
wire                                    csr_waddr_vld;
wire [`DATA_BUS_WIDTH-1:0]              csr_wdata;

assign csr_waddr[`CSR_BUS_WIDTH-1:0] = exu_csr_addr[`CSR_BUS_WIDTH-1:0]
                                     | int_csr_waddr[`CSR_BUS_WIDTH-1:0];

assign csr_waddr_vld = exu_csr_waddr_vld
                     | int_csr_waddr_vld;

assign csr_wdata[`DATA_BUS_WIDTH-1:0] = exu_csr_wdata[`DATA_BUS_WIDTH-1:0]
                                      | int_csr_wdata[`DATA_BUS_WIDTH-1:0];

wire [`ADDR_BUS_WIDTH-1:0]              mem_addr;
wire [`DATA_BUS_WIDTH-1:0]              mem_data;
wire [2:0]                              mem_size;
wire                                    mem_we;
wire                                    mem_rd;

wire [`DATA_BUS_WIDTH-1:0]              mem_wdata;
wire                                    mem_wdata_vld;

wire [`DATA_BUS_WIDTH-1:0]              mem_rdata;
wire                                    mem_rdata_vld;

reg  [`DATA_BUS_WIDTH-1:0]              iresult_t;

always @ (posedge clk_i) begin
    iresult_t[`DATA_BUS_WIDTH-1:0] <= iresult[`DATA_BUS_WIDTH-1:0];
end

assign mem_addr[`ADDR_BUS_WIDTH-1:0]  = hold_stall_flag ? iresult_t[`DATA_BUS_WIDTH-1:0]
                                                        : iresult[`DATA_BUS_WIDTH-1:0]; // from exu, memory address

assign mem_wdata[`DATA_BUS_WIDTH-1:0] = exu_reg2_rdata[`DATA_BUS_WIDTH-1:0];
assign mem_wdata_vld = mem_en_flag && iresult_vld;

wire [5:0]                              mau_inst_func;

assign mau_inst_func[5:0] = {1'b0, exu_inst_func[31], exu_inst_func[29:28], exu_inst_func[14:13]};

reg  [5:0]                              mau_inst_func_t;

always @ (posedge clk_i) begin
    mau_inst_func_t[5:0] <= {1'b1, mau_inst_func[4:0]};
end

pa_core_mau u_pa_core_mau (
    .inst_func_i                        (hold_stall_flag ? mau_inst_func_t : mau_inst_func),

    .mem_addr_i                         (mem_addr[1:0]), // only input low 2-bits for data size sel

    .mem_data_i                         (mem_wdata),
    .mem_data_vld_i                     (mem_wdata_vld),

    .mem_data_o                         (mem_rdata),
    .mem_data_vld_o                     (mem_rdata_vld),

    .rbm_data_i                         (dbus_data_i),

    .rbm_data_o                         (mem_data),
    .rbm_size_o                         (mem_size),
    .rbm_we_o                           (mem_we),
    .rbm_rd_o                           (mem_rd)
);

reg                                     mem_en_flag_t;

always @ (posedge clk_i) begin
    mem_en_flag_t <= mem_en_flag;
end

// if not fetch, address fixed to zero default
assign dbus_addr_o[`ADDR_BUS_WIDTH-1:0] = {32{mem_en_flag || mem_en_flag_t}} & mem_addr[`ADDR_BUS_WIDTH-1:0];
assign dbus_data_o[`DATA_BUS_WIDTH-1:0] = {32{mem_en_flag || mem_en_flag_t}} & mem_data[`DATA_BUS_WIDTH-1:0];
assign dbus_size_o[2:0] = {3{mem_en_flag || mem_en_flag_t}} & mem_size[2:0];
assign dbus_rd_o = (mem_en_flag || mem_en_flag_t) & mem_rd;
assign dbus_we_o = (mem_en_flag || mem_en_flag_t) & mem_we;

reg  [`REG_BUS_WIDTH-1:0]               mau_reg_addr;
reg                                     mau_reg_addr_vld;

wire [`DATA_BUS_WIDTH-1:0]              mau_mem_data;
wire                                    mau_mem_data_vld;

assign mau_mem_data[`DATA_BUS_WIDTH-1:0] = mem_rdata[`DATA_BUS_WIDTH-1:0];
assign mau_mem_data_vld = mem_rdata_vld;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        mau_reg_addr[`REG_BUS_WIDTH-1:0]  <= 0;
        mau_reg_addr_vld                  <= 0;
    end
    else begin
        mau_reg_addr[`REG_BUS_WIDTH-1:0]  <= reg_waddr_wb[`REG_BUS_WIDTH-1:0];
        mau_reg_addr_vld                  <= reg_waddr_wb_vld;
    end
end

wire [`REG_BUS_WIDTH-1:0]               rtu_reg_waddr;
wire                                    rtu_reg_waddr_vld;

wire [`DATA_BUS_WIDTH-1:0]              rtu_reg_wdata;

wire [`CSR_BUS_WIDTH-1:0]               rtu_csr_waddr;
wire                                    rtu_csr_waddr_vld;

wire [`DATA_BUS_WIDTH-1:0]              rtu_csr_wdata;

assign rtu_reg_waddr[`REG_BUS_WIDTH-1:0]   = mau_mem_data_vld ? mau_reg_addr[`REG_BUS_WIDTH-1:0]
                                                              : reg_waddr_wb[`REG_BUS_WIDTH-1:0];
assign rtu_reg_waddr_vld                   = mau_mem_data_vld ? mau_reg_addr_vld
                                                              : reg_waddr_wb_vld & (~exu_hold_flag);

assign rtu_reg_wdata[`DATA_BUS_WIDTH-1:0]  = mau_mem_data_vld ? mau_mem_data[`DATA_BUS_WIDTH-1:0] // from memory, data
                                                              : iresult[`DATA_BUS_WIDTH-1:0]; // from exu, data

assign rtu_csr_waddr[`CSR_BUS_WIDTH-1:0]   = csr_waddr[`CSR_BUS_WIDTH-1:0];
assign rtu_csr_waddr_vld                   = csr_waddr_vld;

assign rtu_csr_wdata[`DATA_BUS_WIDTH-1:0]  = csr_wdata[`DATA_BUS_WIDTH-1:0];

pa_core_rtu u_pa_core_rtu (
    .clk_i                              (clk_i),
    .rst_n_i                            (rst_n_i),

    .reg1_raddr_i                       (idu_reg1_raddr),
    .reg2_raddr_i                       (idu_reg2_raddr),

    .reg_waddr_i                        (rtu_reg_waddr),
    .reg_waddr_vld_i                    (rtu_reg_waddr_vld),

    .reg_wdata_i                        (rtu_reg_wdata),

    .reg1_rdata_o                       (idu_reg1_rdata),
    .reg2_rdata_o                       (idu_reg2_rdata),

    .csr_mtvec_o                        (csr_mtvec_data),
    .csr_mepc_o                         (csr_mepc_data),
    .csr_mstatus_o                      (csr_mstatus_data),

    .csr_raddr_i                        (exu_csr_addr),

    .csr_waddr_i                        (rtu_csr_waddr),
    .csr_waddr_vld_i                    (rtu_csr_waddr_vld),

    .csr_wdata_i                        (rtu_csr_wdata),

    .csr_rdata_o                        (exu_csr_rdata)
);

endmodule