/******************************************************************************
// (c) Copyright 2013 - 2014 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
******************************************************************************/
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.0
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : DDR4_SDRAM
// Purpose          :
//                    Top-level  module. This module serves both as an example,
//                    and allows the user to synthesize a self-contained
//                    design, which they can be used to test their hardware.
//                    In addition to the memory controller,
//                    the module instantiates:
//                      1. Synthesizable testbench - used to model
//                      user's backend logic and generate different
//                      traffic patterns
//
// Reference        :
// Revision History :
//*****************************************************************************
`ifdef MODEL_TECH
    `define SIMULATION_MODE
`elsif INCA
    `define SIMULATION_MODE
`elsif VCS
    `define SIMULATION_MODE
`elsif XILINX_SIMULATOR
    `define SIMULATION_MODE
`elsif _VCP
    `define SIMULATION_MODE
`endif


typedef struct {
    int id;
    string fn;
    string op;
    longint ts;
    int dma_ref;
    logic [`AXI_ADDR_WTH:0] addr;
    logic [`AXI_LEN_WTH:0] len;
    int minIdx;
} axi_trans_t;


logic [0:3] trans_in_prog;



`timescale 1ps/1ps
module example_top #
  (
    parameter nCK_PER_CLK           = 4,   // This parameter is controllerwise
    parameter         APP_DATA_WIDTH          = 512, // This parameter is controllerwise
    parameter         APP_MASK_WIDTH          = 64,  // This parameter is controllerwise
    parameter C_AXI_ID_WIDTH                = 4,
                                              // Width of all master and slave ID signals.
                                              // # = >= 1.
    parameter C_AXI_ADDR_WIDTH              = 32,
                                              // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                              // M_AXI_ARADDR for all SI/MI slots.
                                              // # = 32.
    parameter C_AXI_DATA_WIDTH              = 512,
                                              // Width of WDATA and RDATA on SI slot.
                                              // Must be <= APP_DATA_WIDTH.
                                              // # = 32, 64, 128, 256.
    parameter C_AXI_NBURST_SUPPORT   = 0,

  `ifdef SIMULATION_MODE
    parameter SIMULATION            = "TRUE" 
  `else
    parameter SIMULATION            = "FALSE"
  `endif

  )
   (
    input                 sys_rst, //Common port for all controllers


    output                  c0_init_calib_complete,
    output                  c0_data_compare_error,
    input                   c0_sys_clk_p,
    input                   c0_sys_clk_n,
    output                  c0_ddr4_act_n,
    output [16:0]            c0_ddr4_adr,
    output [1:0]            c0_ddr4_ba,
    output [1:0]            c0_ddr4_bg,
    output [0:0]            c0_ddr4_cke,
    output [0:0]            c0_ddr4_odt,
    output [0:0]            c0_ddr4_cs_n,
    output [0:0]                 c0_ddr4_ck_t,
    output [0:0]                c0_ddr4_ck_c,
    output                  c0_ddr4_reset_n,
    inout  [8:0]            c0_ddr4_dm_dbi_n,
    inout  [71:0]            c0_ddr4_dq,
    inout  [8:0]            c0_ddr4_dqs_t,
    inout  [8:0]            c0_ddr4_dqs_c
    );

    //-----------------------------------------------------------------------------------------------------------------------------------------------
    //  Includes
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    `include "math.svh"
    `include "axi_defs.svh"


  localparam  APP_ADDR_WIDTH = 29;
  localparam  MEM_ADDR_ORDER = "ROW_COLUMN_BANK";
  localparam DBG_WR_STS_WIDTH      = 32;
  localparam DBG_RD_STS_WIDTH      = 32;
  localparam ECC                   = "ON";
  localparam C_PERIOD_83MHz = 12; 

    localparam C_NUM_TOTAL_CLIENTS      = 5;
    
    localparam C_AXI_ID_WTH             = C_NUM_TOTAL_CLIENTS * `AXI_ID_WTH;
    localparam C_AXI_ADDR_WTH           = C_NUM_TOTAL_CLIENTS * `AXI_ADDR_WTH;
    localparam C_AXI_LEN_WTH            = C_NUM_TOTAL_CLIENTS * `AXI_LEN_WTH;
    localparam C_AXI_DATA_WTH           = C_NUM_TOTAL_CLIENTS * `AXI_DATA_WTH;
    localparam C_AXI_RESP_WTH           = C_NUM_TOTAL_CLIENTS * `AXI_RESP_WTH;
    localparam C_AXI_BR_WTH             = C_NUM_TOTAL_CLIENTS * `AXI_BR_WTH;    
    localparam C_AXI_SZ_WTH             = C_NUM_TOTAL_CLIENTS * `AXI_SZ_WTH;
    localparam C_AXI_WSTRB_WTH          = C_NUM_TOTAL_CLIENTS * `AXI_WSTRB_WTH;
    



    //-----------------------------------------------------------------------------------------------------------------------------------------------
    // Local Variables
    //-----------------------------------------------------------------------------------------------------------------------------------------------
 	// AXI Write Address Ports   
    logic [C_NUM_TOTAL_CLIENTS - 1:0]    axi_awready		 ;	// Wrire address is ready
	logic [       C_AXI_ID_WTH - 1:0]  	 axi_awid		     ;	// Write ID
	logic [     C_AXI_ADDR_WTH - 1:0]  	 axi_awaddr		     ;	// Write address
	logic [      C_AXI_LEN_WTH - 1:0]  	 axi_awlen		     ;	// Write Burst Length
	logic [       C_AXI_SZ_WTH - 1:0]  	 axi_awsize		     ;	// Write Burst size
	logic [       C_AXI_BR_WTH - 1:0]  	 axi_awburst		 ;	// Write Burst type
	logic [C_NUM_TOTAL_CLIENTS - 1:0] 	 axi_awvalid		 ;	// Write address valid
	// AXI write data channel signals
	logic [C_NUM_TOTAL_CLIENTS - 1:0]	 axi_wready		     ;	// Write data ready
	logic [     C_AXI_DATA_WTH - 1:0]  	 axi_wdata		     ;	// Write data
	logic [    C_AXI_WSTRB_WTH - 1:0]  	 axi_wstrb		     ;	// Write strobes
	logic [C_NUM_TOTAL_CLIENTS - 1:0]	 axi_wlast		     ;	// Last write transaction   
	logic [C_NUM_TOTAL_CLIENTS - 1:0]	 axi_wvalid		     ;	// Write valid  
	// AXI write response channel signals
	logic [       C_AXI_ID_WTH - 1:0]  	 axi_bid			 ;	// Response ID
	logic [     C_AXI_RESP_WTH - 1:0]  	 axi_bresp		     ;	// Write response
	logic [C_NUM_TOTAL_CLIENTS - 1:0] 	 axi_bvalid		     ;	// Write reponse valid
	logic [C_NUM_TOTAL_CLIENTS - 1:0] 	 axi_bready		     ;	// Response ready
	// AXI read address channel signals
	logic [C_NUM_TOTAL_CLIENTS - 1:0]    axi_arready		 ;   // Read address ready
	logic [       C_AXI_ID_WTH - 1:0]    axi_arid		     ;	// Read ID
	logic [     C_AXI_ADDR_WTH - 1:0]    axi_araddr		     ;   // Read address
	logic [      C_AXI_LEN_WTH - 1:0]    axi_arlen		     ;   // Read Burst Length
	logic [       C_AXI_SZ_WTH - 1:0]    axi_arsize		     ;   // Read Burst size
	logic [       C_AXI_BR_WTH - 1:0]    axi_arburst		 ;   // Read Burst type
	logic [C_NUM_TOTAL_CLIENTS - 1:0]    axi_arvalid		 ;   // Read address valid 
	// AXI read data channel signals   
	logic [       C_AXI_ID_WTH - 1:0]    axi_rid			 ;   // Response ID
	logic [     C_AXI_DATA_WTH - 1:0]    axi_rdata		     ;   // Read data
	logic [     C_AXI_RESP_WTH - 1:0]    axi_rresp		     ;   // Read response
	logic [C_NUM_TOTAL_CLIENTS - 1:0]    axi_rlast		     ;   // Read last
	logic [C_NUM_TOTAL_CLIENTS - 1:0]    axi_rvalid		     ;   // Read reponse valid
	logic [C_NUM_TOTAL_CLIENTS - 1:0]    axi_rready		     ;   // Read Response ready

    logic                                ce                  ;
    logic                                sys_rdy             ;

  logic [APP_ADDR_WIDTH-1:0]            c0_ddr4_app_addr;
  logic [2:0]            c0_ddr4_app_cmd;
  logic                  c0_ddr4_app_en;
  logic [APP_DATA_WIDTH-1:0]            c0_ddr4_app_wdf_data;
  logic                  c0_ddr4_app_wdf_end;
  logic [APP_MASK_WIDTH-1:0]            c0_ddr4_app_wdf_mask;
  logic                  c0_ddr4_app_wdf_wren;
  logic [APP_DATA_WIDTH-1:0]            c0_ddr4_app_rd_data;
  logic                  c0_ddr4_app_rd_data_end;
  logic                  c0_ddr4_app_rd_data_valid;
  logic                  c0_ddr4_app_rdy;
  logic                  c0_ddr4_app_wdf_rdy;
  logic                  c0_ddr4_clk;
  logic                  c0_ddr4_rst;
  logic                  dbg_clk;
  logic                  c0_wr_rd_complete;


  reg                              c0_ddr4_aresetn;
  wire                             c0_ddr4_data_msmatch_err;
  wire                             c0_ddr4_write_err;
  wire                             c0_ddr4_read_err;
  wire                             c0_ddr4_test_cmptd;
  wire                             c0_ddr4_write_cmptd;
  wire                             c0_ddr4_read_cmptd;
  wire                             c0_ddr4_cmptd_one_wr_rd;
  wire                             c0_ddr4_tg_data_err_status_rdy;
  wire [1:0]                       c0_ddr4_tg_data_err_status;

  // Slave Interface Write Address Ports
  wire [3:0]      c0_ddr4_s_axi_awid;
  wire [31:0]    c0_ddr4_s_axi_awaddr;
  wire [7:0]                       c0_ddr4_s_axi_awlen;
  wire [2:0]                       c0_ddr4_s_axi_awsize;
  wire [1:0]                       c0_ddr4_s_axi_awburst;
  wire [3:0]                       c0_ddr4_s_axi_awcache;
  wire [2:0]                       c0_ddr4_s_axi_awprot;
  wire                             c0_ddr4_s_axi_awvalid;
  wire                             c0_ddr4_s_axi_awready;
   // Slave Interface Write Data Ports
  wire [511:0]    c0_ddr4_s_axi_wdata;
  wire [63:0]  c0_ddr4_s_axi_wstrb;
  wire                             c0_ddr4_s_axi_wlast;
  wire                             c0_ddr4_s_axi_wvalid;
  wire                             c0_ddr4_s_axi_wready;
   // Slave Interface Write Response Ports
  wire                             c0_ddr4_s_axi_bready;
  wire [3:0]      c0_ddr4_s_axi_bid;
  wire [1:0]                       c0_ddr4_s_axi_bresp;
  wire                             c0_ddr4_s_axi_bvalid;
   // Slave Interface Read Address Ports
  wire [3:0]      c0_ddr4_s_axi_arid;
  wire [31:0]    c0_ddr4_s_axi_araddr;
  wire [7:0]                       c0_ddr4_s_axi_arlen;
  wire [2:0]                       c0_ddr4_s_axi_arsize;
  wire [1:0]                       c0_ddr4_s_axi_arburst;
  wire [3:0]                       c0_ddr4_s_axi_arcache;
  wire                             c0_ddr4_s_axi_arvalid;
  wire                             c0_ddr4_s_axi_arready;
   // Slave Interface Read Data Ports
  wire                             c0_ddr4_s_axi_rready;
  wire [3:0]      c0_ddr4_s_axi_rid;
  wire [511:0]    c0_ddr4_s_axi_rdata;
  wire [1:0]                       c0_ddr4_s_axi_rresp;
  wire                             c0_ddr4_s_axi_rlast;
  wire                             c0_ddr4_s_axi_rvalid;

  wire                             c0_ddr4_cmp_data_valid;
  wire [511:0]    c0_ddr4_cmp_data;     // Compare data
  wire [511:0]    c0_ddr4_rdata_cmp;      // Read data

  wire                             c0_ddr4_dbg_wr_sts_vld;
  wire [DBG_WR_STS_WIDTH-1:0]      c0_ddr4_dbg_wr_sts;
  wire                             c0_ddr4_dbg_rd_sts_vld;
  wire [DBG_RD_STS_WIDTH-1:0]      c0_ddr4_dbg_rd_sts;
  assign c0_data_compare_error = c0_ddr4_data_msmatch_err | c0_ddr4_write_err | c0_ddr4_read_err;

  // Debug Bus
  logic [511:0]                         dbg_bus;    


logic c0_ddr4_reset_n_int;
logic clk_FAS;
  assign c0_ddr4_reset_n = c0_ddr4_reset_n_int;
  
  // virtual AXI_intf i_axi_intf[0:4];
  // virtual Sys_intf i_sys_intf;

//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************


    // clock_gen #(
    //     .C_PERIOD(C_PERIOD_83MHz)
    // )
    // i0_clock_gen(
    //     .clk_out(clk_FAS)
    // );
    // clk_conv1x1
    // clk_conv3x3
    
    

  // user design top is one instance for all controllers
ddr4 u_ddr4
  (
   .sys_rst           (sys_rst),

   .c0_sys_clk_p                   (c0_sys_clk_p),
   .c0_sys_clk_n                   (c0_sys_clk_n),
   .c0_init_calib_complete (c0_init_calib_complete),
   .c0_ddr4_act_n          (c0_ddr4_act_n),
   .c0_ddr4_adr            (c0_ddr4_adr),
   .c0_ddr4_ba             (c0_ddr4_ba),
   .c0_ddr4_bg             (c0_ddr4_bg),
   .c0_ddr4_cke            (c0_ddr4_cke),
   .c0_ddr4_odt            (c0_ddr4_odt),
   .c0_ddr4_cs_n           (c0_ddr4_cs_n),
   .c0_ddr4_ck_t           (c0_ddr4_ck_t),
   .c0_ddr4_ck_c           (c0_ddr4_ck_c),
   .c0_ddr4_reset_n        (c0_ddr4_reset_n_int),

   .c0_ddr4_dm_dbi_n       (c0_ddr4_dm_dbi_n),
   .c0_ddr4_dq             (c0_ddr4_dq),
   .c0_ddr4_dqs_c          (c0_ddr4_dqs_c),
   .c0_ddr4_dqs_t          (c0_ddr4_dqs_t),

   .c0_ddr4_ui_clk                (c0_ddr4_clk),
   .c0_ddr4_ui_clk_sync_rst       (c0_ddr4_rst),
   .dbg_clk                                    (dbg_clk),
     // AXI CTRL port
     .c0_ddr4_s_axi_ctrl_awvalid       (1'b0),
     .c0_ddr4_s_axi_ctrl_awready       (),
     .c0_ddr4_s_axi_ctrl_awaddr        (32'b0),
     // Slave Interface Write Data Ports
     .c0_ddr4_s_axi_ctrl_wvalid        (1'b0),
     .c0_ddr4_s_axi_ctrl_wready        (),
     .c0_ddr4_s_axi_ctrl_wdata         (32'b0),
     // Slave Interface Write Response Ports
     .c0_ddr4_s_axi_ctrl_bvalid        (),
     .c0_ddr4_s_axi_ctrl_bready        (1'b1),
     .c0_ddr4_s_axi_ctrl_bresp         (),
     // Slave Interface Read Address Ports
     .c0_ddr4_s_axi_ctrl_arvalid       (1'b0),
     .c0_ddr4_s_axi_ctrl_arready       (),
     .c0_ddr4_s_axi_ctrl_araddr        (32'b0),
     // Slave Interface Read Data Ports
     .c0_ddr4_s_axi_ctrl_rvalid        (),
     .c0_ddr4_s_axi_ctrl_rready        (1'b1),
     .c0_ddr4_s_axi_ctrl_rdata         (),
     .c0_ddr4_s_axi_ctrl_rresp         (),
     // Interrupt output
     .c0_ddr4_interrupt                (),
  // Slave Interface Write Address Ports
  .c0_ddr4_aresetn                     (c0_ddr4_aresetn),
  .c0_ddr4_s_axi_awid                  (c0_ddr4_s_axi_awid),
  .c0_ddr4_s_axi_awaddr                (c0_ddr4_s_axi_awaddr),
  .c0_ddr4_s_axi_awlen                 (c0_ddr4_s_axi_awlen),
  .c0_ddr4_s_axi_awsize                (c0_ddr4_s_axi_awsize),
  .c0_ddr4_s_axi_awburst               (c0_ddr4_s_axi_awburst),
  .c0_ddr4_s_axi_awlock                (1'b0),
  .c0_ddr4_s_axi_awcache               (4'b0),
  .c0_ddr4_s_axi_awprot                (3'b0),
  .c0_ddr4_s_axi_awqos                 (4'b0),
  .c0_ddr4_s_axi_awvalid               (c0_ddr4_s_axi_awvalid),
  .c0_ddr4_s_axi_awready               (c0_ddr4_s_axi_awready),
  // Slave Interface Write Data Ports
  .c0_ddr4_s_axi_wdata                 (c0_ddr4_s_axi_wdata),
  .c0_ddr4_s_axi_wstrb                 (c0_ddr4_s_axi_wstrb),
  .c0_ddr4_s_axi_wlast                 (c0_ddr4_s_axi_wlast),
  .c0_ddr4_s_axi_wvalid                (c0_ddr4_s_axi_wvalid),
  .c0_ddr4_s_axi_wready                (c0_ddr4_s_axi_wready),
  // Slave Interface Write Response Ports
  .c0_ddr4_s_axi_bid                   (c0_ddr4_s_axi_bid),
  .c0_ddr4_s_axi_bresp                 (c0_ddr4_s_axi_bresp),
  .c0_ddr4_s_axi_bvalid                (c0_ddr4_s_axi_bvalid),
  .c0_ddr4_s_axi_bready                (c0_ddr4_s_axi_bready),
  // Slave Interface Read Address Ports
  .c0_ddr4_s_axi_arid                  (c0_ddr4_s_axi_arid),
  .c0_ddr4_s_axi_araddr                (c0_ddr4_s_axi_araddr),
  .c0_ddr4_s_axi_arlen                 (c0_ddr4_s_axi_arlen),
  .c0_ddr4_s_axi_arsize                (c0_ddr4_s_axi_arsize),
  .c0_ddr4_s_axi_arburst               (c0_ddr4_s_axi_arburst),
  .c0_ddr4_s_axi_arlock                (1'b0),
  .c0_ddr4_s_axi_arcache               (4'b0),
  .c0_ddr4_s_axi_arprot                (3'b0),
  .c0_ddr4_s_axi_arqos                 (4'b0),
  .c0_ddr4_s_axi_arvalid               (c0_ddr4_s_axi_arvalid),
  .c0_ddr4_s_axi_arready               (c0_ddr4_s_axi_arready),
  // Slave Interface Read Data Ports
  .c0_ddr4_s_axi_rid                   (c0_ddr4_s_axi_rid),
  .c0_ddr4_s_axi_rdata                 (c0_ddr4_s_axi_rdata),
  .c0_ddr4_s_axi_rresp                 (c0_ddr4_s_axi_rresp),
  .c0_ddr4_s_axi_rlast                 (c0_ddr4_s_axi_rlast),
  .c0_ddr4_s_axi_rvalid                (c0_ddr4_s_axi_rvalid),
  .c0_ddr4_s_axi_rready                (c0_ddr4_s_axi_rready),
  
  // Debug Port
  .dbg_bus         (dbg_bus)                                             

  );
   always @(posedge c0_ddr4_clk) begin
     c0_ddr4_aresetn <= ~c0_ddr4_rst;
   end


   
    
    logic [4:0]                                   axi_rlast_d         ;
    
    
    genvar g0; for(g0 = 0; g0 < 5; g0 = g0 + 1) begin
        SRL_bit #(
            .C_CLOCK_CYCLES ( 1 )
        )
        iX_SRL_bit (
            .clk        ( c0_ddr4_clk           ),
            .ce         ( 1'b1              ),
            .rst        ( sys_rst           ),
            .data_in    ( axi_rlast[g0]      ),
            .data_out   ( axi_rlast_d[g0]       )
        );       
    end

    assign ce = sys_rdy;   
    always@(posedge c0_sys_clk_p or sys_rst) begin
        if(sys_rst) begin
            sys_rdy <= 0;
        end else if(c0_init_calib_complete && c0_ddr4_reset_n) begin
            sys_rdy <= 1;
        end
    end

    assign c0_ddr4_s_axi_rready = 1;    
    assign c0_ddr4_s_axi_bready = 1;
    assign c0_ddr4_s_axi_wvalid = 1;
    initial begin
        resetIntf();
        axi_drvr();
        while(|trans_in_prog) begin
            @(posedge c0_ddr4_s_clk);
        end
    end
    
    
 
endmodule


task resetIntf();
    sim_tb_top.u_example_top.c0_ddr4_s_axi_arvalid = 0;
    sim_tb_top.u_example_top.c0_ddr4_s_axi_araddr  = 0;
    sim_tb_top.u_example_top.c0_ddr4_s_axi_arlen   = 0; 
    sim_tb_top.u_example_top.c0_ddr4_s_axi_rready  = 0;
    sim_tb_top.u_example_top.c0_ddr4_s_axi_awvalid = 0;
    sim_tb_top.u_example_top.c0_ddr4_s_axi_awaddr  = 0;
    sim_tb_top.u_example_top.c0_ddr4_s_axi_awlen   = 0; 
    sim_tb_top.u_example_top.c0_ddr4_s_axi_wvalid  = 0;
    sim_tb_top.u_example_top.c0_ddr4_s_axi_wlast   = 0;
    sim_tb_top.u_example_top.c0_ddr4_s_axi_bready  = 0;
endtask: resetIntf


function axi_trans_t findMin(int idx0, axi_trans_t axi_trans_0, int idx1, axi_trans_t axi_trans_1);
    axi_trans_t axi_trans;
    if(axi_trans_0.ts <= axi_trans_1.ts) begin
        axi_trans.id        = axi_trans_0.id;
        axi_trans.fn        = axi_trans_0.fn;
        axi_trans.op        = axi_trans_0.op;
        axi_trans.dma_ref   = axi_trans_0.dma_ref;
        axi_trans.ts        = axi_trans_0.td;
        axi_trans.addr      = axi_trans_0.add;
        axi_trans.len       = axi_trans_0.len;
        axi_trans.minIdx    = id0;
    end else begin
        axi_trans.id        = axi_trans_1.id;
        axi_trans.fn        = axi_trans_1.fn;
        axi_trans.op        = axi_trans_1.op;
        axi_trans.dma_ref   = axi_trans_1.dma_ref;       
        axi_trans.ts        = axi_trans_1.td;
        axi_trans.addr      = axi_trans_1.add;
        axi_trans.len       = axi_trans_1.len;
        axi_trans.minIdx    = id0;
    end
    return axi_trans;
endfunction: findMax


function automatic getTrans(ref integer fd_im, ref integer fd_pm, ref integer fd_rm, ref integer fd_om, ref axi_trans_t axi_trans[0:4]);
    axi_trans_t axi_trans_ret0, axi_trans_ret1, axi_trans_ret2;
    if(!$feof(fd_im) && axi_trans[0].id == -1) begin
        $fscanf(fd_im, "%d,%d,%d,%d,%d\n", axi_trans[0].id, axi_trans[0].ts, axi_trans[0].op, axi_trans[0].addr, axi_trans[0].len);
    end
    if(!$feof(fd_pm) && axi_trans[1].id == -1) begin
        $fscanf(fd_pm, "%d,%d,%d,%d,%d\n", axi_trans[1].id, axi_trans[1].ts, axi_trans[1].op, axi_trans[1].addr, axi_trans[1].len);
    end
    if(!$feof(fd_rm) && axi_trans[2].id == -1) begin
        $fscanf(fd_rm, "%d,%d,%d,%d,%d\n", axi_trans[2].id, axi_trans[2].ts, axi_trans[2].op, axi_trans[2].addr, axi_trans[2].len);
    end
    if(!$feof(fd_om) && axi_trans[3].id == -1) begin
        $fscanf(fd_om, "%d,%d,%d,%d,%d\n", axi_trans[3].id, axi_trans[3].ts, axi_trans[3].op, axi_trans[3].addr, axi_trans[3].len);
    end
    axi_trans_ret0 = findMin(0, axi_trans[0], 1, axi_trans[1]);
    axi_trans_ret1 = findMin(2, axi_trans[2], 3, axi_trans[3]);
    axi_trans_ret2 = findMin(axi_trans_ret0.minIdx, axi_trans_ret0, axi_trans_ret1.minIdx, axi_trans_ret1);
    null_axi_trans(axi_trans[axi_trans_ret2.minIdx]);
    return axi_trans_ret2;
endfunction: getTrans


task axi_drvr();
    integer fd_im, fd_pm, fd_rm, fd_om;
    int time_delta;
    int op;
    time addr;
    shortreal onehnrd;
    int len;
    int prog_factor;
    int perct;
    longint t_ofst;
    longint time_delta;
    
    // 48336
    // 261187
    // 1444361
    // 197828
    axi_trans_t axi_trans[0:3];
    axi_trans_t axi_trans_sel;
    //---------------------------------------------------------------------------------------------
    t_ofst = $time;
    fd_im = -1; fd_pm = -1; fd_rm = -1; fd_om = -1;
    fd_im = $fopen(fn, "./memTrace_0_im.txt"); fd_pm = $fopen(fn, "./memTrace_0_pm.txt");
    fd_rm = $fopen(fn, "./memTrace_0_rm.txt"); fd_om = $fopen(fn, "./memTrace_0_om.txt");
    prog_factor = 10;
    onehnrd = 100.0;
    
    null_axi_trans(axi_trans[0]); null_axi_trans(axi_trans[1]);
    null_axi_trans(axi_trans[2]); null_axi_trans(axi_trans[3]);

    forever begin
        @(posedge clk);
        if(!sim_tb_top.u_example_top.sys_rst && sim_tb_top.u_example_top.ce) begin
            break;
        end
    end
    
    while(fd_im != -1 && fd_pm != -1 && fd_rm != -1 && fd_om != -1) begin 
        axi_trans_sel = getTrans(axi_trans);
        t_ofst
        time_delta = axi_trans.ts - ($time - t_ofst);
        time_delta = 0; // DEBUG
        repeat(time_delta) @(posedge clk);        
        if(axi_trans_sel.op == 0) begin // READ
            axi_schd_rd(axi_trans_sel);
        end else begin // WRITE
            axi_schd_wr(axi_trans_sel);
        end
        if($feof(fd_im)) $fclose(fd_im); fd_im = -1;
        if($feof(fd_pm)) $fclose(fd_pm); fd_pm = -1;
        if($feof(fd_rm)) $fclose(fd_rm); fd_rm = -1;
        if($feof(fd_om)) $fclose(fd_om); fd_om = -1;      
        perct = $floor((trans_no / trans_tot) * onehnrd);
        if(perct >= prog_factor && perct > 0) begin
            prog_factor = prog_factor + 10;
            $display("finished %d / %d transactions", trans_no, trans_tot);
        end
    end
endtask: axi_drvr


function automatic null_axi_trans(ref axi_trans_t axi_trans);
    axi_trans.id = -1;
    axi_trans.fn = "";
    axi_trans.dma_ref = -1;
    axi_trans.op = "";
    axi_trans.ts = -1;
    axi_trans.addr = -1;
    axi_trans.len = -1;
endfunction: null_axi_trans


task axi_schd_rd(axi_trans_t axi_trans);
    logic clk;
    logic axi_arready;    
    //---------------------------------------------------------------------------------------------
    assign clk = sim_tb_top.u_example_top.c0_ddr4_clk;
    assign axi_arready = sim_tb_top.u_example_top.c0_ddr4_s_axi_arready;    
    forever begin
        @(posedge clk);
        if(axi_arready == 1) begin
            break;
        end
    end
    @(posedge clk);
    axi_arvalid <= 1;
    axi_araddr  <= axi_trans.addr;
    axi_arlen   <= axi_trans.len; 
    $display("[AXI_READ STARTED]: %s Transaction No. %d", axi_trans.fn, axi_trans.trans_no);
    $display("\taddress: %d", axi_trans.addr);
    $display("\tlength:  %d", axi_trans.len);
    axi_arvalid <= 0;
    axi_araddr  <= 0;
    axi_arlen   <= 0;    
    fork
        axi_wait_rd_cmpl(id, fn);
    join_none    
endtask: axi_schd_rd


task axi_schd_wr(axi_trans_t axi_trans);
    logic clk;
    logic axi_awready;    
    //---------------------------------------------------------------------------------------------
    assign clk = sim_tb_top.u_example_top.c0_ddr4_clk;
    assign axi_awready = sim_tb_top.u_example_top.c0_ddr4_s_axi_awready;    
    forever begin
        @(posedge clk);
        if(axi_awready == 1) begin
            break;
        end
    end
    $display("[AXI WRITE STARTED]: %s Transaction No. %d", axi_trans.fn, axi_trans.trans_no);
    $display("\taddress: %d", axi_trans.addr);
    $display("\tlength: %d", axi_trans.len);    
    fork
        axi_wait_wr_cmpl(axi_trans);
    join_none
endtask: axi_schd_wr


task axi_wait_rd_cmpl(axi_trans_t axi_trans);
    logic clk;
    logic axi_rlast_d;
    logic axi_rid;
    //---------------------------------------------------------------------------------------------
    trans_in_prog[axi_trans.dma_ref] = 1;
    assign clk          = sim_tb_top.u_example_top.c0_ddr4_clk;
    assign axi_rlast_d  = sim_tb_top.u_example_top.axi_rlast_d;
    assign axi_rid      = sim_tb_top.u_example_top.c0_ddr4_s_axi_rid;
    forever begin
        @(posedge clk);
        if(axi_rlast_d && axi_trans.id == axi_rid) begin
            $display("[AXI READ FINISHED]: %s Transaction No. %d", fn, trans_no);
            break;
        end
    end
    trans_in_prog[axi_trans.dma_ref] = 0;
endtask: axi_wait_rd_cmpl


task axi_wait_wr_cmpl(axi_trans_t axi_trans);
    logic clk;
    logic axi_wlast;
    //---------------------------------------------------------------------------------------------
    trans_in_prog[axi_trans.dma_ref] = 1;
    assign clk          = sim_tb_top.u_example_top.c0_ddr4_clk;
    assign axi_wlast    = sim_tb_top.u_example_top.c0_ddr4_s_axi_wlast;
    assign axi_bvalid   = sim_tb_top.u_example_top.c0_ddr4_s_axi_bvalid;
    forever begin
        @(posedge clk); 
        if(i == (axi_trans.len - 1)) begin
            axi_wlast = 1;
        end
        i = i + 1;
    end
    axi_wlast = 0;
    forever begin
        @(posedge clk);   
        if(axi_bvalid) begin
            $display("[AXI WRITE FINISHED]: %s Transaction No. %d", axi_trans.fn, axi_trans.id);
            break;
        end
    end
    trans_in_prog[axi_trans.dma_ref] = 0;
endtask: axi_wait_wr_cmpl

