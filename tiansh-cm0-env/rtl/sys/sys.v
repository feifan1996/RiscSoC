/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date         Author          Notes
 * 2022-03-27   Lyons           first version
 */

module sys #(
    parameter IMAGE             = ""
)(
    input   wire                XTAL,
    input   wire                NRST,

    input   wire                TEST,

    input   wire                TRSTn,
    input   wire                TCK,
    input   wire                TDI,
    input   wire                TMS,
    output  wire                TDO,

    inout   wire [15:0]         GPIO,

    output  wire [17:0]         EMIADDR,
    inout   wire [15:0]         EMIDATA,
    output  wire                EMIWEn,
    output  wire                EMIOEn,
    output  wire                EMICEn,
    output  wire                EMILBn,
    output  wire                EMIUBn,

    input   wire                RXD0,
    output  wire                TXD0,

    input   wire                RXD1,
    output  wire                TXD1
);

`define MEM_AW                  20

wire                            sys_poresetn;
wire                            sys_dbgresetn;

wire                            sys_dbgpwrdown;
wire                            sys_syspwrdown;

wire                            sys_lockup;
wire [25:0]                     sys_stcalib;
wire                            sys_stclken;

reg                             sys_pmuhresetreq;
reg                             sys_pmudbgresetreq;

wire                            sys_sysresetreq;

wire                            sys_gatehclk;

wire                            sys_sleeping;
wire                            sys_sleepdeep;
wire                            sys_wakeup;
wire                            sys_sleepholdreqn;
wire                            sys_sleepholdackn;
wire                            sys_wicenreq;
wire                            sys_wicenack;
wire                            sys_cdbgpwrupreq;
wire                            sys_cdbgpwrupack;

wire                            sys_apbactive;

wire                            sys_fclk;
wire                            sys_sclk;
wire                            sys_dclk;

wire                            sys_hclk;
wire                            sys_hresetn;

wire [31:0]                     sys_haddr_cm0;
wire [ 2:0]                     sys_hburst_cm0;
wire                            sys_hmastlock_cm0;
wire [ 3:0]                     sys_hprot_cm0;
wire [ 2:0]                     sys_hsize_cm0;
wire [ 1:0]                     sys_htrans_cm0;
wire [31:0]                     sys_hwdata_cm0;
wire                            sys_hwrite_cm0;
wire [31:0]                     sys_hrdata_cm0;
wire                            sys_hready_cm0;
wire                            sys_hresp_cm0;

wire [31:0]                     sys_hrdata_rom;
wire [31:0]                     sys_hrdata_ram;
wire [31:0]                     sys_hrdata_gpio;
wire [31:0]                     sys_hrdata_apb;

wire                            sys_hsel_rom;
wire                            sys_hsel_ram;
wire                            sys_hsel_gpio;
wire                            sys_hsel_apb;
wire                            sys_hsel_def_slv;

wire                            sys_hready_rom;
wire                            sys_hready_ram;
wire                            sys_hready_gpio;
wire                            sys_hready_apb;
wire                            sys_hready_def_slv;

wire                            sys_pclk;
wire                            sys_presetn;
wire                            sys_pclkg;
wire                            sys_pclken;

wire [31:0]                     sys_intirq_cm0;
wire                            sys_intnmi_cm0;

wire [31:0]                     sys_gpioout;
wire [31:0]                     sys_gpioin;
wire [31:0]                     sys_gpioen;
wire                            sys_gpioint;

wire [31:0]                     apbsubsys_interrupt;
wire                            watchdog_interrupt;

wire                            watchdog_reset;

assign sys_intnmi_cm0 = watchdog_interrupt;
assign sys_intirq_cm0[31:0] = {sys_gpioint, apbsubsys_interrupt[30:0]};

// cortex m0
CORTEXM0INTEGRATION u_cm0 (
    // CLOCK SIGNAL
    .FCLK                       (sys_fclk),
    .SCLK                       (sys_sclk),
    .HCLK                       (sys_hclk),
    .DCLK                       (sys_dclk),

    // RESET SIGNAL
    .PORESETn                   (sys_poresetn),
    .DBGRESETn                  (sys_dbgresetn),
    .HRESETn                    (sys_hresetn),

    // AHB-LITE MASTER PORT
    .HADDR                      (sys_haddr_cm0),
    .HBURST                     (sys_hburst_cm0),
    .HMASTLOCK                  (sys_hmastlock_cm0),
    .HPROT                      (sys_hprot_cm0),
    .HSIZE                      (sys_hsize_cm0),
    .HTRANS                     (sys_htrans_cm0),
    .HWDATA                     (sys_hwdata_cm0),
    .HWRITE                     (sys_hwrite_cm0),
    .HRDATA                     (sys_hrdata_cm0),
    .HREADY                     (sys_hready_cm0),
    .HRESP                      (sys_hresp_cm0),
    .HMASTER                    (sys_hmastlock_cm0),

    // CODE SEQUENTIALITY AND SPECULATION
    .CODENSEQ                   (),
    .CODEHINTDE                 (),
    .SPECHTRANS                 (),

    // DEBUG
    .SWCLKTCK                   (TCK),
    .nTRST                      (TRSTn),
    .SWDITMS                    (TMS),
    .TDI                        (TDI),
    .SWDO                       (),
    .SWDOEN                     (),
    .TDO                        (TDO),
    .nTDOEN                     (),
    .DBGRESTART                 (1'b0),
    .DBGRESTARTED               (),
    .EDBGRQ                     (1'b0),
    .HALTED                     (),

    // MISC
    .NMI                        (sys_intnmi_cm0),
    .IRQ                        (sys_intirq_cm0),
    .TXEV                       (),
    .RXEV                       (1'b0),
    .LOCKUP                     (sys_lockup),
    .SYSRESETREQ                (sys_sysresetreq),
    .STCALIB                    (sys_stcalib),
    .STCLKEN                    (sys_stclken),
    .IRQLATENCY                 (8'b0),
    .ECOREVNUM                  (28'b0),

    // POWER MANAGEMENT
    .GATEHCLK                   (sys_gatehclk),
    .SLEEPING                   (sys_sleeping),
    .SLEEPDEEP                  (sys_sleepdeep),
    .WAKEUP                     (sys_wakeup),
    .WICSENSE                   (),
    .SLEEPHOLDREQn              (sys_sleepholdreqn),
    .SLEEPHOLDACKn              (sys_sleepholdackn),
    .WICENREQ                   (sys_wicenreq),
    .WICENACK                   (sys_wicenack),
    .CDBGPWRUPREQ               (sys_cdbgpwrupreq),
    .CDBGPWRUPACK               (sys_cdbgpwrupack),

    // SCAN IO
    .SE                         (1'b0),
    .RSTBYPASS                  (TEST)
);

// map 0x0000_0000~0x000f_ffff to rom
assign sys_hsel_rom     =  (sys_haddr_cm0[31:20] == 12'h000);

// map 0x2000_0000~0x200f_ffff to ram
assign sys_hsel_ram     =  (sys_haddr_cm0[31:20] == 12'h200);

// map 0x4000_0000~0x4000_07ff to gpio
assign sys_hsel_gpio    =  (sys_haddr_cm0[31:12] == 20'h40000);

// map 0x5000_0000~0x5000_ffff to apb
//     0x----_0000~0x----_0fff to timer0
//     0x----_0000~1x----_1fff to timer1
//     0x----_0000~3x----_3fff to uart0
//     0x----_0000~4x----_4fff to uart1
//     0x----_0000~8x----_8fff to watchdog
assign sys_hsel_apb     =  (sys_haddr_cm0[31:16] == 16'h5000);

// map other address to default slave  
assign sys_hsel_def_slv = !(sys_hsel_rom || sys_hsel_ram || sys_hsel_gpio || sys_hsel_apb);

// ahb interconnect
cmsdk_ahb_slave_mux u_ahb_mux (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .HREADY                     (sys_hready_cm0),

    .HSEL0                      (sys_hsel_rom),
    .HREADYOUT0                 (sys_hready_rom),
    .HRESP0                     (sys_hresp_rom),
    .HRDATA0                    (sys_hrdata_rom[31:0]),

    .HSEL1                      (sys_hsel_ram),
    .HREADYOUT1                 (sys_hready_ram),
    .HRESP1                     (sys_hresp_ram),
    .HRDATA1                    (sys_hrdata_ram[31:0]),

    .HSEL2                      (sys_hsel_gpio),
    .HREADYOUT2                 (sys_hready_gpio),
    .HRESP2                     (sys_hresp_gpio),
    .HRDATA2                    (sys_hrdata_gpio[31:0]),

    .HSEL3                      (sys_hsel_apb),
    .HREADYOUT3                 (sys_hready_apb),
    .HRESP3                     (sys_hresp_apb),
    .HRDATA3                    (sys_hrdata_apb[31:0]),

    .HSEL4                      (sys_hsel_def_slv),
    .HREADYOUT4                 (sys_hready_def_slv),
    .HRESP4                     (sys_hresp_def_slv),
    .HRDATA4                    (32'b0),

    .HREADYOUT                  (sys_hready_cm0),
    .HRESP                      (sys_hresp_cm0),
    .HRDATA                     (sys_hrdata_cm0[31:0])
);

// ahb rom 
cmsdk_ahb_rom #(
    .AW                         (`MEM_AW),
    .filename                   (IMAGE)
) u_ahb_rom (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .HSEL                       (sys_hsel_rom),
    .HADDR                      (sys_haddr_cm0[`MEM_AW-1:0]),
    .HTRANS                     (sys_htrans_cm0[1:0]),
    .HSIZE                      (sys_hsize_cm0[2:0]),
    .HWRITE                     (sys_hwrite_cm0),
    .HWDATA                     (sys_hwdata_cm0[31:0]),
    .HREADY                     (sys_hready_cm0),

    .HREADYOUT                  (sys_hready_rom),
    .HRDATA                     (sys_hrdata_rom[31:0]),
    .HRESP                      (sys_hresp_rom)
);

// ahb ram 
cmsdk_ahb_ram #(
    .AW                         (`MEM_AW)
) u_ahb_ram (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .HSEL                       (sys_hsel_ram),
    .HADDR                      (sys_haddr_cm0[`MEM_AW-1:0]),
    .HTRANS                     (sys_htrans_cm0[1:0]),
    .HSIZE                      (sys_hsize_cm0[2:0]),
    .HWRITE                     (sys_hwrite_cm0),
    .HWDATA                     (sys_hwdata_cm0[31:0]),
    .HREADY                     (sys_hready_cm0),

    .HREADYOUT                  (sys_hready_ram),
    .HRDATA                     (sys_hrdata_ram[31:0]),
    .HRESP                      (sys_hresp_ram)
);

// ahb gpio
cmsdk_ahb_gpio u_ahb_gpio (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .FCLK                       (sys_fclk),

    .HSEL                       (sys_hsel_gpio),
    .HREADY                     (sys_hready_cm0),
    .HTRANS                     (sys_htrans_cm0[1:0]),
    .HSIZE                      (sys_hsize_cm0[2:0]),
    .HWRITE                     (sys_hwrite_cm0),
    .HADDR                      (sys_haddr_cm0[11:0]),
    .HWDATA                     (sys_hwdata_cm0[31:0]),

    .ECOREVNUM                  (4'h1),

    .PORTIN                     (sys_gpioin[15:0]),

    .HREADYOUT                  (sys_hready_gpio),
    .HRESP                      (sys_hresp_gpio),
    .HRDATA                     (sys_hrdata_gpio[31:0]),

    .PORTOUT                    (sys_gpioout[15:0]),
    .PORTEN                     (sys_gpioen[15:0]),
    .PORTFUNC                   (),

    .GPIOINT                    (),
    .COMBINT                    (gpio_interrupt)
);

// ahb apb subsys
cmsdk_apb_subsystem u_ahb_apb (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .HSEL                       (sys_hsel_apb),
    .HADDR                      (sys_haddr_cm0[15:0]),
    .HTRANS                     (sys_htrans_cm0[1:0]),
    .HWRITE                     (sys_hwrite_cm0),
    .HSIZE                      (sys_hsize_cm0[2:0]),
    .HPROT                      (sys_hprot_cm0),
    .HREADY                     (sys_hready_cm0),
    .HWDATA                     (sys_hwdata_cm0[31:0]),

    .HREADYOUT                  (sys_hready_apb),
    .HRESP                      (sys_hresp_apb),
    .HRDATA                     (sys_hrdata_apb[31:0]),

    .PCLK                       (sys_pclk),
    .PCLKG                      (sys_pclkg),
    .PCLKEN                     (sys_pclken),
    .PRESETn                    (sys_presetn),

    .APBACTIVE                  (sys_apbactive),

    .uart0_rxd                  (RXD0),
    .uart0_txd                  (TXD0),
    .uart0_txen                 (),

    .uart1_rxd                  (RXD1),
    .uart1_txd                  (TXD1),
    .uart1_txen                 (),

    .timer0_extin               (1'b0),
    .timer1_extin               (1'b0),

    .apbsubsys_interrupt        (apbsubsys_interrupt),
    .watchdog_interrupt         (watchdog_interrupt),
    .watchdog_reset             (watchdog_reset)
);

// ahb default slave
cmsdk_ahb_default_slave u_ahb_def_slv (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .HSEL                       (sys_hsel_def_slv),
    .HTRANS                     (sys_htrans_cm0[1:0]),
    .HREADY                     (sys_hready_cm0),

    .HREADYOUT                  (sys_hready_def_slv),
    .HRESP                      (sys_hresp_def_slv)
);

// system pmu
reg  [31:0]                     count_r;

always @ (posedge XTAL or negedge NRST) begin
    if (!NRST) begin
        count_r[31:0] <= 32'b0;
    end
    else if (count_r[31:0] <= 32'd40) begin
        count_r[31:0] <= count_r[31:0] + 32'd1;
    end
end

assign sys_hclk = (count_r > 32'd27) ? sys_fclk : 1'b0;
assign sys_sclk = (count_r > 32'd27) ? sys_fclk : 1'b0;
assign sys_dclk = 1'b0;

assign sys_pmuhresetreq   = 1'b0;
assign sys_pmudbgresetreq = (count_r > 32'd25) ? 1'b1 : 1'b0;
assign sys_dbgpwrdown     = 1'b1;
assign sys_syspwrdown     = 1'b0;
assign sys_sleepholdreqn  = 1'b1;
assign sys_cdbgpwrupack   = 1'b0; 
assign sys_wicenreq       = (count_r > 32'd23) ? 1'b1 : 1'b0;

// system rst_ctl
cmsdk_mcu_clkctrl u_clkrst (
    .XTAL1                      (XTAL),
    .NRST                       (NRST),

    .APBACTIVE                  (sys_apbactive),
    .SLEEPING                   (sys_sleeping),
    .SLEEPDEEP                  (sys_sleepdeep),
    .SYSRESETREQ                (sys_pmuhresetreq | sys_sysresetreq | watchdog_reset),
    .DBGRESETREQ                (sys_pmudbgresetreq),
    .LOCKUP                     (sys_lockup),
    .LOCKUPRESET                (1'b0),

    .CGBYPASS                   (TEST),
    .RSTBYPASS                  (TEST),

    .FCLK                       (sys_fclk),
    .PCLK                       (sys_pclk),
    .PCLKG                      (sys_pclkg),
    .PCLKEN                     (sys_pclken),
    .PORESETn                   (sys_poresetn),
    .DBGRESETn                  (sys_dbgresetn),
    .HRESETn                    (sys_hresetn),
    .PRESETn                    (sys_presetn)
);

// system stclk gen
cmsdk_mcu_stclkctrl u_stclken (
    .FCLK                       (sys_fclk),
    .SYSRESETn                  (sys_hresetn),

    .STCLKEN                    (sys_stclken),
    .STCALIB                    (sys_stcalib)
);

assign GPIO[15:0] = sys_gpioout[15:0];

// assign GPIO[15:0] = sys_gpioen ? sys_gpioout[15:0] : {16{1'bz}};
// assign sys_gpioin[15:0] = GPIO[15:0];

// --------------------------------------------------
// THE FOLLOWING SIGNALS ARE NOT SUPPORTED!
// --------------------------------------------------

// DEBUG PORT INTERFACE
assign TDO = 1'b0;

// EXTENDED MEMORY INTERFACE
assign EMIADDR[17:0] = 18'b0;
assign EMIDATA[15:0] = 16'bz;
assign EMIWEn = 1'b1;
assign EMIOEn = 1'b1;
assign EMICEn = 1'b1;
assign EMILBn = 1'b1;
assign EMIUBn = 1'b1;

endmodule