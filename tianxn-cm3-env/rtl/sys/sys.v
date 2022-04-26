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

wire [31:0]                     sys_haddr_cm3i;
wire [ 2:0]                     sys_hburst_cm3i;
wire [ 3:0]                     sys_hprot_cm3i;
wire [ 2:0]                     sys_hsize_cm3i;
wire [ 1:0]                     sys_htrans_cm3i;
wire [31:0]                     sys_hrdata_cm3i;
wire                            sys_hready_cm3i;
wire                            sys_hresp_cm3i;

wire [31:0]                     sys_haddr_cm3d;
wire [ 2:0]                     sys_hburst_cm3d;
wire [ 3:0]                     sys_hprot_cm3d;
wire [ 2:0]                     sys_hsize_cm3d;
wire [ 1:0]                     sys_htrans_cm3d;
wire [31:0]                     sys_hwdata_cm3d;
wire                            sys_hwrite_cm3d;
wire [31:0]                     sys_hrdata_cm3d;
wire                            sys_hready_cm3d;
wire                            sys_hresp_cm3d;

wire [31:0]                     sys_haddr_cm3s;
wire [ 2:0]                     sys_hburst_cm3s;
wire [ 3:0]                     sys_hprot_cm3s;
wire [ 2:0]                     sys_hsize_cm3s;
wire [ 1:0]                     sys_htrans_cm3s;
wire [31:0]                     sys_hwdata_cm3s;
wire                            sys_hwrite_cm3s;
wire [31:0]                     sys_hrdata_cm3s;
wire                            sys_hready_cm3s;
wire                            sys_hreadyout_cm3s;
wire                            sys_hresp_cm3s;

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

wire [239:0]                    sys_intirq_cm3;
wire                            sys_intnmi_cm3;

wire [31:0]                     sys_gpioout;
wire [31:0]                     sys_gpioin;
wire [31:0]                     sys_gpioen;
wire                            sys_gpioint;

wire [31:0]                     apbsubsys_interrupt;
wire                            watchdog_interrupt;

wire                            watchdog_reset;

assign sys_intnmi_cm3 = watchdog_interrupt;
assign sys_intirq_cm3[239:0] = {208'b0, sys_gpioint, apbsubsys_interrupt[30:0]};

// cortex m3
CORTEXM3INTEGRATIONDS u_cm3 (
    // CONFIG
    .ISOLATEn                   (1'b1),
    .RETAINn                    (1'b1),

    .DBGEN                      (1'b1),
    .NIDEN                      (1'b1),

    .BIGEND                     (1'b0), // 1, support BIGEND
    .MPUDISABLE                 (1'b1), // 1, disable MPU
    .DNOTITRANS                 (1'b1), // 1, merge I-CODE and D-CODE
    .FIXMASTERTYPE              (1'b0), // 1, override HMASTER for AHB-AP accesses

    // CLOCK SIGNAL
    .FCLK                       (sys_fclk),
    .HCLK                       (sys_hclk),

    // RESET SIGNAL
    .PORESETn                   (sys_poresetn),

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

    .JTAGNSW                    (),
    .SWV                        (),

    .TSVALUEB                   (48'b0), // only for trace timestamp
    .TRACECLKIN                 (sys_pclk),
    .TRACECLK                   (),
    .TRACEDATA                  (),

    .AUXFAULT                   (32'b0),
    .IFLUSH                     (1'b0),

    // MISC
    .INTNMI                     (sys_intnmi_cm3),
    .INTISR                     (sys_intirq_cm3),
    .TXEV                       (),
    .RXEV                       (1'b0),
    .LOCKUP                     (sys_lockup),
    .SYSRESETREQ                (sys_sysresetreq),

    // SYSTICK
    .STCLK                      (sys_sclk),
    .STCALIB                    (sys_stcalib),

    // POWER MANAGEMENT
    .GATEHCLK                   (sys_gatehclk),
    .SLEEPING                   (sys_sleeping),
    .SLEEPDEEP                  (sys_sleepdeep),
    .WAKEUP                     (sys_wakeup),
    .SLEEPHOLDREQn              (sys_sleepholdreqn),
    .SLEEPHOLDACKn              (sys_sleepholdackn),
    .WICENREQ                   (sys_wicenreq),
    .WICENACK                   (sys_wicenack),
    .CDBGPWRUPREQ               (sys_cdbgpwrupreq),
    .CDBGPWRUPACK               (sys_cdbgpwrupack),

    // SCAN IO
    .SE                         (1'b0),
    .RSTBYPASS                  (TEST),
    .CGBYPASS                   (TEST),

    .SYSRESETn                  (sys_hresetn),

    .HADDRI                     (sys_haddr_cm3i),
    .HBURSTI                    (sys_hburst_cm3i),
    .HPROTI                     (sys_hprot_cm3i),
    .HSIZEI                     (sys_hsize_cm3i),
    .HTRANSI                    (sys_htrans_cm3i),
    .HRDATAI                    (sys_hrdata_cm3i),
    .HREADYI                    (sys_hready_cm3i),
    .HRESPI                     ({1'b0, sys_hresp_cm3i}),

    .HADDRD                     (sys_haddr_cm3d),
    .HBURSTD                    (sys_hburst_cm3d),
    .HPROTD                     (sys_hprot_cm3d),
    .HSIZED                     (sys_hsize_cm3d),
    .HTRANSD                    (sys_htrans_cm3d),
    .HWDATAD                    (sys_hwdata_cm3d),
    .HWRITED                    (sys_hwrite_cm3d),
    .HRDATAD                    (sys_hrdata_cm3d),
    .HREADYD                    (sys_hready_cm3d),
    .HRESPD                     ({1'b0, sys_hresp_cm3d}),
    .HMASTERD                   (),

    .HADDRS                     (sys_haddr_cm3s),
    .HBURSTS                    (sys_hburst_cm3s),
    .HPROTS                     (sys_hprot_cm3s),
    .HSIZES                     (sys_hsize_cm3s),
    .HTRANSS                    (sys_htrans_cm3s),
    .HWDATAS                    (sys_hwdata_cm3s),
    .HWRITES                    (sys_hwrite_cm3s),
    .HRDATAS                    (sys_hrdata_cm3s),
    .HREADYS                    (sys_hready_cm3s),
    .HRESPS                     ({1'b0, sys_hresp_cm3s}),
    .HMASTERS                   (),

    // STATUS
    .ETMINTNUM                  (),
    .ETMINTSTAT                 (),
    .BRCHSTAT                   (),
    .CURRPRI                    (),
    .TRCENA                     (),

    .MEMATTRI                   (),
    .MEMATTRD                   (),
    .MEMATTRS                   (),

    .EXREQD                     (),
    .EXRESPD                    (1'b0),
    .EXREQS                     (),
    .EXRESPS                    (1'b0),

    // NO USED
    .HTMDHADDR                  (),
    .HTMDHTRANS                 (),
    .HTMDHSIZE                  (),
    .HTMDHBURST                 (),
    .HTMDHPROT                  (),
    .HTMDHWDATA                 (),
    .HTMDHWRITE                 (),
    .HTMDHRDATA                 (),
    .HTMDHREADY                 (),
    .HTMDHRESP                  ()
);

// map 0x0000_0000~0x000f_ffff to rom
// only access by I-CODE and D-CODE

// map 0x2000_0000~0x200f_ffff to ram
assign sys_hsel_ram     =  (sys_haddr_cm3s[31:20] == 12'h200);

// map 0x4000_0000~0x4000_07ff to gpio
assign sys_hsel_gpio    =  (sys_haddr_cm3s[31:12] == 20'h40000);

// map 0x5000_0000~0x5000_ffff to apb
//     0x----_0000~0x----_0fff to timer0
//     0x----_0000~1x----_1fff to timer1
//     0x----_0000~3x----_3fff to uart0
//     0x----_0000~4x----_4fff to uart1
//     0x----_0000~8x----_8fff to watchdog
assign sys_hsel_apb     =  (sys_haddr_cm3s[31:16] == 16'h5000);

// map other address to default slave  
assign sys_hsel_def_slv = !(sys_hsel_ram || sys_hsel_gpio || sys_hsel_apb);

wire [31:0]                     sys_haddr_cm3id;
wire [ 2:0]                     sys_hsize_cm3id;
wire [ 1:0]                     sys_htrans_cm3id;
wire [31:0]                     sys_hwdata_cm3id;
wire                            sys_hwrite_cm3id;
wire                            sys_hready_cm3id;

// ahb interconnect
cmsdk_ahb_master_mux u_ahb_mux_m (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .HSELS0                     (1'b1),
    .HADDRS0                    (sys_haddr_cm3i[31:0]),
    .HTRANSS0                   (sys_htrans_cm3i[1:0]),
    .HSIZES0                    (sys_hsize_cm3i[2:0]),
    .HWRITES0                   (1'b0),
    .HREADYS0                   (1'b1),
    .HPROTS0                    (sys_hprot_cm3i[3:0]),
    .HBURSTS0                   (sys_hburst_cm3i[2:0]),
    .HMASTLOCKS0                (1'b0),
    .HWDATAS0                   (32'b0),

    .HREADYOUTS0                (sys_hready_cm3i),
    .HRESPS0                    (sys_hresp_cm3i),
    .HRDATAS0                   (sys_hrdata_cm3i[31:0]),

    .HSELS1                     (1'b1),
    .HADDRS1                    (sys_haddr_cm3d[31:0]),
    .HTRANSS1                   (sys_htrans_cm3d[1:0]),
    .HSIZES1                    (sys_hsize_cm3d[2:0]),
    .HWRITES1                   (sys_hwrite_cm3d),
    .HREADYS1                   (1'b1),
    .HPROTS1                    (sys_hprot_cm3d[3:0]),
    .HBURSTS1                   (sys_hburst_cm3d[2:0]),
    .HMASTLOCKS1                (1'b0),
    .HWDATAS1                   (sys_hwdata_cm3d[31:0]),

    .HREADYOUTS1                (sys_hready_cm3d),
    .HRESPS1                    (sys_hresp_cm3d),
    .HRDATAS1                   (sys_hrdata_cm3d[31:0]),

    .HSELM                      (sys_hsel_rom),
    .HADDRM                     (sys_haddr_cm3id[31:0]),
    .HTRANSM                    (sys_htrans_cm3id[1:0]),
    .HSIZEM                     (sys_hsize_cm3id[2:0]),
    .HWRITEM                    (sys_hwrite_cm3id),
    .HREADYM                    (sys_hready_cm3id),
    .HPROTM                     (),
    .HBURSTM                    (),
    .HMASTLOCKM                 (),
    .HWDATAM                    (sys_hwdata_cm3id[31:0]),

    .HREADYOUTM                 (sys_hready_rom),
    .HRESPM                     (sys_hresp_rom),
    .HRDATAM                    (sys_hrdata_rom[31:0]),

    .HMASTERM                   ()
);

// ahb interconnect
cmsdk_ahb_slave_mux u_ahb_mux_s (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .HREADY                     (sys_hready_cm3s),

    .HSEL0                      (sys_hsel_ram),
    .HREADYOUT0                 (sys_hready_ram),
    .HRESP0                     (sys_hresp_ram),
    .HRDATA0                    (sys_hrdata_ram[31:0]),

    .HSEL1                      (sys_hsel_gpio),
    .HREADYOUT1                 (sys_hready_gpio),
    .HRESP1                     (sys_hresp_gpio),
    .HRDATA1                    (sys_hrdata_gpio[31:0]),

    .HSEL2                      (sys_hsel_apb),
    .HREADYOUT2                 (sys_hready_apb),
    .HRESP2                     (sys_hresp_apb),
    .HRDATA2                    (sys_hrdata_apb[31:0]),

    .HSEL3                      (sys_hsel_def_slv),
    .HREADYOUT3                 (sys_hready_def_slv),
    .HRESP3                     (sys_hresp_def_slv),
    .HRDATA3                    (32'b0),

    .HREADYOUT                  (sys_hready_cm3s),
    .HRESP                      (sys_hresp_cm3s),
    .HRDATA                     (sys_hrdata_cm3s[31:0])
);

// ahb rom 
cmsdk_ahb_rom #(
    .AW                         (`MEM_AW),
    .filename                   (IMAGE)
) u_ahb_rom (
    .HCLK                       (sys_hclk),
    .HRESETn                    (sys_hresetn),

    .HSEL                       (sys_hsel_rom),
    .HADDR                      (sys_haddr_cm3id[`MEM_AW-1:0]),
    .HTRANS                     (sys_htrans_cm3id[1:0]),
    .HSIZE                      (sys_hsize_cm3id[2:0]),
    .HWRITE                     (sys_hwrite_cm3id),
    .HWDATA                     (sys_hwdata_cm3id[31:0]),
    .HREADY                     (sys_hready_cm3id),

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
    .HADDR                      (sys_haddr_cm3s[`MEM_AW-1:0]),
    .HTRANS                     (sys_htrans_cm3s[1:0]),
    .HSIZE                      (sys_hsize_cm3s[2:0]),
    .HWRITE                     (sys_hwrite_cm3s),
    .HWDATA                     (sys_hwdata_cm3s[31:0]),
    .HREADY                     (sys_hready_cm3s),

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
    .HREADY                     (sys_hready_cm3s),
    .HTRANS                     (sys_htrans_cm3s[1:0]),
    .HSIZE                      (sys_hsize_cm3s[2:0]),
    .HWRITE                     (sys_hwrite_cm3s),
    .HADDR                      (sys_haddr_cm3s[11:0]),
    .HWDATA                     (sys_hwdata_cm3s[31:0]),

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
    .HADDR                      (sys_haddr_cm3s[15:0]),
    .HTRANS                     (sys_htrans_cm3s[1:0]),
    .HWRITE                     (sys_hwrite_cm3s),
    .HSIZE                      (sys_hsize_cm3s[2:0]),
    .HPROT                      (sys_hprot_cm3s),
    .HREADY                     (sys_hready_cm3s),
    .HWDATA                     (sys_hwdata_cm3s[31:0]),

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
    .HTRANS                     (sys_htrans_cm3s[1:0]),
    .HREADY                     (sys_hready_cm3s),

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