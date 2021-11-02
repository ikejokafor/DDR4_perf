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


interface Sys_intf
(
	clk
);
    input logic         clk;
endinterface: Sys_intf


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
  logic                             c0_ddr4_data_msmatch_err;
  logic                             c0_ddr4_write_err;
  logic                             c0_ddr4_read_err;
  logic                             c0_ddr4_test_cmptd;
  logic                             c0_ddr4_write_cmptd;
  logic                             c0_ddr4_read_cmptd;
  logic                             c0_ddr4_cmptd_one_wr_rd;

  // Slave Interface Write Address Ports
  logic [3:0]      c0_ddr4_s_axi_awid;
  logic [31:0]    c0_ddr4_s_axi_awaddr;
  logic [7:0]                       c0_ddr4_s_axi_awlen;
  logic [2:0]                       c0_ddr4_s_axi_awsize;
  logic [1:0]                       c0_ddr4_s_axi_awburst;
  logic [3:0]                       c0_ddr4_s_axi_awcache;
  logic [2:0]                       c0_ddr4_s_axi_awprot;
  logic                             c0_ddr4_s_axi_awvalid;
  logic                             c0_ddr4_s_axi_awready;
   // Slave Interface Write Data Ports
  logic [511:0]    c0_ddr4_s_axi_wdata;
  logic [63:0]  c0_ddr4_s_axi_wstrb;
  logic                             c0_ddr4_s_axi_wlast;
  logic                             c0_ddr4_s_axi_wvalid;
  logic                             c0_ddr4_s_axi_wready;
   // Slave Interface Write Response Ports
  logic                             c0_ddr4_s_axi_bready;
  logic [3:0]      c0_ddr4_s_axi_bid;
  logic [1:0]                       c0_ddr4_s_axi_bresp;
  logic                             c0_ddr4_s_axi_bvalid;
   // Slave Interface Read Address Ports
  logic [3:0]      c0_ddr4_s_axi_arid;
  logic [31:0]    c0_ddr4_s_axi_araddr;
  logic [7:0]                       c0_ddr4_s_axi_arlen;
  logic [2:0]                       c0_ddr4_s_axi_arsize;
  logic [1:0]                       c0_ddr4_s_axi_arburst;
  logic [3:0]                       c0_ddr4_s_axi_arcache;
  logic                             c0_ddr4_s_axi_arvalid;
  logic                             c0_ddr4_s_axi_arready;
   // Slave Interface Read Data Ports
  logic                             c0_ddr4_s_axi_rready;
  logic [3:0]      c0_ddr4_s_axi_rid;
  logic [511:0]    c0_ddr4_s_axi_rdata;
  logic [1:0]                       c0_ddr4_s_axi_rresp;
  logic                             c0_ddr4_s_axi_rlast;
  logic                             c0_ddr4_s_axi_rvalid;

  logic                             c0_ddr4_cmp_data_valid;
  logic [511:0]    c0_ddr4_cmp_data;     // Compare data
  logic [511:0]    c0_ddr4_rdata_cmp;      // Read data

  logic                             c0_ddr4_dbg_wr_sts_vld;
  logic [DBG_WR_STS_WIDTH-1:0]      c0_ddr4_dbg_wr_sts;
  logic                             c0_ddr4_dbg_rd_sts_vld;
  logic [DBG_RD_STS_WIDTH-1:0]      c0_ddr4_dbg_rd_sts;
  assign c0_data_compare_error = c0_ddr4_data_msmatch_err | c0_ddr4_write_err | c0_ddr4_read_err;

  // Debug Bus
  logic [511:0]                         dbg_bus;    


logic c0_ddr4_reset_n_int;
  assign c0_ddr4_reset_n = c0_ddr4_reset_n_int;
  
  virtual AXI_intf axi_intf[0:4];

//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************


    clock_gen #(
        .C_PERIOD(C_PERIOD_83MHz)
    )
    i0_clock_gen(
        .clk_out(clk_FAS)
    );
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



    axi_interconnect 
    i0_axi_interconnect (
        .INTERCONNECT_ACLK      ( c0_ddr4_clk                                        ),  
        .INTERCONNECT_ARESETN   ( c0_ddr4_aresetn                                    ),  
        .S00_AXI_ARESET_OUT_N   (                                                    ),  
        .S00_AXI_ACLK           ( clk_FAS                                            ),  
        .S00_AXI_AWID           ( 1'b0                                               ),
        .S00_AXI_AWADDR         ( axi_awaddr[(0 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),
        .S00_AXI_AWLEN          ( axi_awlen[(0 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),
        .S00_AXI_AWSIZE         ( 3'b110                                             ),  
        .S00_AXI_AWBURST        ( 2'b01                                              ),  
        .S00_AXI_AWLOCK         ( 1'b0                                               ),  
        .S00_AXI_AWCACHE        ( 4'b0                                               ),  
        .S00_AXI_AWPROT         ( 3'b0                                               ),  
        .S00_AXI_AWQOS          ( 4'b0                                               ),  
        .S00_AXI_AWVALID        ( axi_awvalid[0]                                     ),
        .S00_AXI_AWREADY        ( axi_awready[0]                                     ),
        .S00_AXI_WDATA          ( axi_wdata[(0 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),
        .S00_AXI_WSTRB          ( 64'hFFFFFFFFFFFFFFFF                               ),  
        .S00_AXI_WLAST          ( axi_wlast[0]                                       ),  
        .S00_AXI_WVALID         ( axi_wvalid[0]                                      ),  
        .S00_AXI_WREADY         ( axi_wready[0]                                      ),  
        .S00_AXI_BID            ( axi_bid[(0 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),  
        .S00_AXI_BRESP          ( axi_bresp[(0 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S00_AXI_BVALID         ( axi_bvalid[0]                                      ),  
        .S00_AXI_BREADY         ( axi_bready[0]                                      ),  
        .S00_AXI_ARID           ( 1'b1                                               ),
        .S00_AXI_ARADDR         ( axi_araddr[(0 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),  
        .S00_AXI_ARLEN          ( axi_arlen[(0 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),  
        .S00_AXI_ARSIZE         ( 3'b110                                             ),  
        .S00_AXI_ARBURST        ( 2'b01                                              ),  
        .S00_AXI_ARLOCK         ( 1'b0                                               ),  
        .S00_AXI_ARCACHE        ( 4'b0                                               ),  
        .S00_AXI_ARPROT         ( 3'b0                                               ),  
        .S00_AXI_ARQOS          ( 4'b0                                               ),  
        .S00_AXI_ARVALID        ( axi_arvalid[0]                                     ),  
        .S00_AXI_ARREADY        ( axi_arready[0]                                     ),  
        .S00_AXI_RID            ( axi_rid[(0 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),
        .S00_AXI_RDATA          ( axi_rdata[(0 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),  
        .S00_AXI_RRESP          ( axi_rresp[(0 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S00_AXI_RLAST          ( axi_rlast[0]                                       ),  
        .S00_AXI_RVALID         ( axi_rvalid[0]                                      ),  
        .S00_AXI_RREADY         ( axi_rready[0]                                      ), 
        // BEGIN ----------------------------------------------------------------------------------------------------------------------------------------
        .S01_AXI_ARESET_OUT_N   (                                                    ),  
        .S01_AXI_ACLK           ( clk_FAS                                            ),  
        .S01_AXI_AWID           ( 1'b0                                               ),
        .S01_AXI_AWADDR         ( axi_awaddr[(1 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),
        .S01_AXI_AWLEN          ( axi_awlen[(1 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),
        .S01_AXI_AWSIZE         ( 3'b110                                             ),  
        .S01_AXI_AWBURST        ( 2'b01                                              ),  
        .S01_AXI_AWLOCK         ( 1'b0                                               ),  
        .S01_AXI_AWCACHE        ( 4'b0                                               ),  
        .S01_AXI_AWPROT         ( 3'b0                                               ),  
        .S01_AXI_AWQOS          ( 4'b0                                               ),  
        .S01_AXI_AWVALID        ( axi_awvalid[1]                                     ),
        .S01_AXI_AWREADY        ( axi_awready[1]                                     ),
        .S01_AXI_WDATA          ( axi_wdata[(1 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),
        .S01_AXI_WSTRB          ( 64'hFFFFFFFFFFFFFFFF                               ),  
        .S01_AXI_WLAST          ( axi_wlast[1]                                       ),  
        .S01_AXI_WVALID         ( axi_wvalid[1]                                      ),  
        .S01_AXI_WREADY         ( axi_wready[1]                                      ),  
        .S01_AXI_BID            ( axi_bid[(1 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),  
        .S01_AXI_BRESP          ( axi_bresp[(1 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S01_AXI_BVALID         ( axi_bvalid[1]                                      ),  
        .S01_AXI_BREADY         ( axi_bready[1]                                      ),  
        .S01_AXI_ARID           ( 1'b1                                               ),         
        .S01_AXI_ARADDR         ( axi_araddr[(1 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),  
        .S01_AXI_ARLEN          ( axi_arlen[(1 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),  
        .S01_AXI_ARSIZE         ( 3'b110                                             ),  
        .S01_AXI_ARBURST        ( 2'b01                                              ),  
        .S01_AXI_ARLOCK         ( 1'b0                                               ),  
        .S01_AXI_ARCACHE        ( 4'b0                                               ),  
        .S01_AXI_ARPROT         ( 3'b0                                               ),  
        .S01_AXI_ARQOS          ( 4'b0                                               ),  
        .S01_AXI_ARVALID        ( axi_arvalid[1]                                     ),  
        .S01_AXI_ARREADY        ( axi_arready[1]                                     ),  
        .S01_AXI_RID            ( axi_rid[(1 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ), 
        .S01_AXI_RDATA          ( axi_rdata[(1 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),  
        .S01_AXI_RRESP          ( axi_rresp[(1 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S01_AXI_RLAST          ( axi_rlast[1]                                       ),  
        .S01_AXI_RVALID         ( axi_rvalid[1]                                      ),  
        .S01_AXI_RREADY         ( axi_rready[1]                                      ),      
        // BEGIN ----------------------------------------------------------------------------------------------------------------------------------------
        .S02_AXI_ARESET_OUT_N   (                                                    ),  
        .S02_AXI_ACLK           ( clk_FAS                                            ),  
        .S02_AXI_AWID           ( 1'b0                                               ),
        .S02_AXI_AWADDR         ( axi_awaddr[(2 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),
        .S02_AXI_AWLEN          ( axi_awlen[(2 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),
        .S02_AXI_AWSIZE         ( 3'b110                                             ),  
        .S02_AXI_AWBURST        ( 2'b01                                              ),  
        .S02_AXI_AWLOCK         ( 1'b0                                               ),  
        .S02_AXI_AWCACHE        ( 4'b0                                               ),  
        .S02_AXI_AWPROT         ( 3'b0                                               ),  
        .S02_AXI_AWQOS          ( 4'b0                                               ),  
        .S02_AXI_AWVALID        ( axi_awvalid[2]                                     ),
        .S02_AXI_AWREADY        ( axi_awready[2]                                     ),
        .S02_AXI_WDATA          ( axi_wdata[(2 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),
        .S02_AXI_WSTRB          ( 64'hFFFFFFFFFFFFFFFF                               ),  
        .S02_AXI_WLAST          ( axi_wlast[2]                                       ),  
        .S02_AXI_WVALID         ( axi_wvalid[2]                                      ),  
        .S02_AXI_WREADY         ( axi_wready[2]                                      ),  
        .S02_AXI_BID            ( axi_bid[(2 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),  
        .S02_AXI_BRESP          ( axi_bresp[(2 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S02_AXI_BVALID         ( axi_bvalid[2]                                      ),  
        .S02_AXI_BREADY         ( axi_bready[2]                                      ),  
        .S02_AXI_ARID           ( 1'b1                                               ), 
        .S02_AXI_ARADDR         ( axi_araddr[(2 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),  
        .S02_AXI_ARLEN          ( axi_arlen[(2 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),  
        .S02_AXI_ARSIZE         ( 3'b110                                             ),  
        .S02_AXI_ARBURST        ( 2'b01                                              ),  
        .S02_AXI_ARLOCK         ( 1'b0                                               ),  
        .S02_AXI_ARCACHE        ( 4'b0                                               ),  
        .S02_AXI_ARPROT         ( 3'b0                                               ),  
        .S02_AXI_ARQOS          ( 4'b0                                               ),  
        .S02_AXI_ARVALID        ( axi_arvalid[2]                                     ),  
        .S02_AXI_ARREADY        ( axi_arready[2]                                     ),  
        .S02_AXI_RID            ( axi_rid[(2 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),        
        .S02_AXI_RDATA          ( axi_rdata[(2 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),  
        .S02_AXI_RRESP          ( axi_rresp[(2 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S02_AXI_RLAST          ( axi_rlast[2]                                       ),  
        .S02_AXI_RVALID         ( axi_rvalid[2]                                      ),  
        .S02_AXI_RREADY         ( axi_rready[2]                                      ),
        // BEGIN ----------------------------------------------------------------------------------------------------------------------------------------
        .S03_AXI_ARESET_OUT_N   (                                                    ),  
        .S03_AXI_ACLK           ( clk_FAS                                            ),  
        .S03_AXI_AWID           ( 1'b0                                               ),
        .S03_AXI_AWADDR         ( axi_awaddr[(3 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),
        .S03_AXI_AWLEN          ( axi_awlen[(3 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),
        .S03_AXI_AWSIZE         ( 3'b110                                             ),  
        .S03_AXI_AWBURST        ( 2'b01                                              ),  
        .S03_AXI_AWLOCK         ( 1'b0                                               ),  
        .S03_AXI_AWCACHE        ( 4'b0                                               ),  
        .S03_AXI_AWPROT         ( 3'b0                                               ),  
        .S03_AXI_AWQOS          ( 4'b0                                               ),  
        .S03_AXI_AWVALID        ( axi_awvalid[3]                                     ),
        .S03_AXI_AWREADY        ( axi_awready[3]                                     ),
        .S03_AXI_WDATA          ( axi_wdata[(3 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),
        .S03_AXI_WSTRB          ( 64'hFFFFFFFFFFFFFFFF                               ),  
        .S03_AXI_WLAST          ( axi_wlast[3]                                       ),  
        .S03_AXI_WVALID         ( axi_wvalid[3]                                      ),  
        .S03_AXI_WREADY         ( axi_wready[3]                                      ),  
        .S03_AXI_BID            ( axi_bid[(3 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),  
        .S03_AXI_BRESP          ( axi_bresp[(3 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S03_AXI_BVALID         ( axi_bvalid[3]                                      ),  
        .S03_AXI_BREADY         ( axi_bready[3]                                      ),  
        .S03_AXI_ARID           ( 1'b1                                               ),       
        .S03_AXI_ARADDR         ( axi_araddr[(3 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),  
        .S03_AXI_ARLEN          ( axi_arlen[(3 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),  
        .S03_AXI_ARSIZE         ( 3'b110                                             ),  
        .S03_AXI_ARBURST        ( 2'b01                                              ),  
        .S03_AXI_ARLOCK         ( 1'b0                                               ),  
        .S03_AXI_ARCACHE        ( 4'b0                                               ),  
        .S03_AXI_ARPROT         ( 3'b0                                               ),  
        .S03_AXI_ARQOS          ( 4'b0                                               ),  
        .S03_AXI_ARVALID        ( axi_arvalid[3]                                     ),  
        .S03_AXI_ARREADY        ( axi_arready[3]                                     ),  
        .S03_AXI_RID            ( axi_rid[(3 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),        
        .S03_AXI_RDATA          ( axi_rdata[(3 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),  
        .S03_AXI_RRESP          ( axi_rresp[(3 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S03_AXI_RLAST          ( axi_rlast[3]                                       ),  
        .S03_AXI_RVALID         ( axi_rvalid[3]                                      ),  
        .S03_AXI_RREADY         ( axi_rready[3]                                      ),    
        // BEGIN ----------------------------------------------------------------------------------------------------------------------------------------
        .S04_AXI_ARESET_OUT_N   (                                                    ),  
        .S04_AXI_ACLK           ( clk_FAS                                            ),  
        .S04_AXI_AWID           ( 1'b0                                               ),
        .S04_AXI_AWADDR         ( axi_awaddr[(4 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),
        .S04_AXI_AWLEN          ( axi_awlen[(4 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),
        .S04_AXI_AWSIZE         ( 3'b110                                             ),  
        .S04_AXI_AWBURST        ( 2'b01                                              ),  
        .S04_AXI_AWLOCK         ( 1'b0                                               ),  
        .S04_AXI_AWCACHE        ( 4'b0                                               ),  
        .S04_AXI_AWPROT         ( 3'b0                                               ),  
        .S04_AXI_AWQOS          ( 4'b0                                               ),  
        .S04_AXI_AWVALID        ( axi_awvalid[4]                                     ),  
        .S04_AXI_AWREADY        ( axi_awready[4]                                     ),  
        .S04_AXI_WDATA          ( axi_wdata[(4 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),  
        .S04_AXI_WSTRB          ( 64'hFFFFFFFFFFFFFFFF                               ),  
        .S04_AXI_WLAST          ( axi_wlast[4]                                       ),  
        .S04_AXI_WVALID         ( axi_wvalid[4]                                      ),  
        .S04_AXI_WREADY         ( axi_wready[4]                                      ),  
        .S04_AXI_BID            ( axi_bid[(4 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),  
        .S04_AXI_BRESP          ( axi_bresp[(4 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),  
        .S04_AXI_BVALID         ( axi_bvalid[4]                                      ),  
        .S04_AXI_BREADY         ( axi_bready[4]                                      ),  
        .S04_AXI_ARID           ( 1'b1                                               ),         
        .S04_AXI_ARADDR         ( axi_araddr[(4 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]   ),  
        .S04_AXI_ARLEN          ( axi_arlen[(4 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]      ),  
        .S04_AXI_ARSIZE         ( 3'b110                                             ),  
        .S04_AXI_ARBURST        ( 2'b01                                              ),  
        .S04_AXI_ARLOCK         ( 1'b0                                               ),  
        .S04_AXI_ARCACHE        ( 4'b0                                               ),  
        .S04_AXI_ARPROT         ( 3'b0                                               ),  
        .S04_AXI_ARQOS          ( 4'b0                                               ),  
        .S04_AXI_ARVALID        ( axi_arvalid[4]                                     ),
        .S04_AXI_ARREADY        ( axi_arready[4]                                     ),
        .S04_AXI_RID            ( axi_rid[(4 * `AXI_ID_WTH) +: `AXI_ID_WTH]          ),        
        .S04_AXI_RDATA          ( axi_rdata[(4 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]    ),
        .S04_AXI_RRESP          ( axi_rresp[(4 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]    ),
        .S04_AXI_RLAST          ( axi_rlast[4]                                       ),
        .S04_AXI_RVALID         ( axi_rvalid[4]                                      ),
        .S04_AXI_RREADY         ( axi_rready[4]                                      ),
        // BEGIN ----------------------------------------------------------------------------------------------------------------------------------------
        .M00_AXI_ARESET_OUT_N   (                                                    ),
        .M00_AXI_ACLK           ( c0_ddr4_clk                                        ),        
        .M00_AXI_AWID           ( c0_ddr4_s_axi_awid                                 ),     
        .M00_AXI_AWADDR         ( c0_ddr4_s_axi_awaddr                               ),      
        .M00_AXI_AWLEN          ( c0_ddr4_s_axi_awlen                                ),      
        .M00_AXI_AWSIZE         ( c0_ddr4_s_axi_awsize                               ),      
        .M00_AXI_AWBURST        ( c0_ddr4_s_axi_awburst                              ),      
        .M00_AXI_AWLOCK         (                                                    ),      
        .M00_AXI_AWCACHE        (                                                    ),      
        .M00_AXI_AWPROT         (                                                    ),      
        .M00_AXI_AWQOS          (                                                    ),      
        .M00_AXI_AWVALID        ( c0_ddr4_s_axi_awvalid                              ),      
        .M00_AXI_AWREADY        ( c0_ddr4_s_axi_awready                              ),      
        .M00_AXI_WDATA          ( c0_ddr4_s_axi_wdata                                ),      
        .M00_AXI_WSTRB          ( c0_ddr4_s_axi_wstrb                                ),      
        .M00_AXI_WLAST          ( c0_ddr4_s_axi_wlast                                ),      
        .M00_AXI_WVALID         ( c0_ddr4_s_axi_wvalid                               ),      
        .M00_AXI_WREADY         ( c0_ddr4_s_axi_wready                               ),      
        .M00_AXI_BID            ( c0_ddr4_s_axi_bid                                  ),      
        .M00_AXI_BRESP          ( c0_ddr4_s_axi_bresp                                ),      
        .M00_AXI_BVALID         ( c0_ddr4_s_axi_bvalid                               ),      
        .M00_AXI_BREADY         ( c0_ddr4_s_axi_bready                               ),      
        .M00_AXI_ARID           ( c0_ddr4_s_axi_arid                                 ),      
        .M00_AXI_ARADDR         ( c0_ddr4_s_axi_araddr                               ),      
        .M00_AXI_ARLEN          ( c0_ddr4_s_axi_arlen                                ),      
        .M00_AXI_ARSIZE         ( c0_ddr4_s_axi_arsize                               ),      
        .M00_AXI_ARBURST        ( c0_ddr4_s_axi_arburst                              ),      
        .M00_AXI_ARLOCK         (                                                    ),
        .M00_AXI_ARCACHE        (                                                    ),
        .M00_AXI_ARPROT         (                                                    ),
        .M00_AXI_ARQOS          (                                                    ),
        .M00_AXI_ARVALID        ( c0_ddr4_s_axi_arvalid                              ),
        .M00_AXI_ARREADY        ( c0_ddr4_s_axi_arready                              ),
        .M00_AXI_RID            ( c0_ddr4_s_axi_rid                                  ),
        .M00_AXI_RDATA          ( c0_ddr4_s_axi_rdata                                ),
        .M00_AXI_RRESP          ( c0_ddr4_s_axi_rresp                                ),
        .M00_AXI_RLAST          ( c0_ddr4_s_axi_rlast                                ),
        .M00_AXI_RVALID         ( c0_ddr4_s_axi_rvalid                               ),
        .M00_AXI_RREADY         ( c0_ddr4_s_axi_rready                               ) 
    );

    /*
    Sys_intf sys_intf (
        .clk        ( clk_FAS               )
    );
    
    
    logic [4:0]                                   rlast_d         ;
    
    
    genvar g0; generate for(g0 = 0; g0 < 5; g0 = g0 + 1) begin: AXI_INTF
        SRL_bit #(
            .C_CLOCK_CYCLES ( 1 )
        )
        i0_SRL_bit (
            .clk        ( clk_FAS           ),
            .ce         ( 1'b1              ),
            .rst        ( sys_rst           ),
            .data_in    ( axi_rlast[g0]      ),
            .data_out   ( rlast_d[g0]       )
        );
    
        AXI_intf
        i0_axi_intf (
            .clk			( clk_FAS                                               ),
            .ce             ( ce                                                    ),
            .rst            ( sys_rst                                               ),
            // AXI Write Address Ports 
            .awaddr		    ( axi_awaddr[(g0 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]      ),	// Write address
            .awlen		    ( axi_awlen[(g0 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]         ),	// Write Burst Length
            .awvalid		( axi_awvalid[g0]                                        ),	// Write address valid
            .awready		( axi_awready[g0]                                        ),	// Wrire address is ready
            // AXI write data channel signals
            .wdata		    ( axi_wdata[(g0 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]       ),	// Write data
            .wlast		    ( axi_wlast[g0]                                          ),	// Last write transaction   
            .wvalid		    ( axi_wvalid[g0]                                         ),	// Write valid  	
            .wready		    ( axi_wready[g0]                                         ),	// Write data ready
            // AXI write response channel signals
            .bresp		    ( axi_bresp[(g0 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]       ),	// Write response
            .bvalid		    ( axi_bvalid[g0]                                         ),	// Write reponse valid
            .bready		    ( axi_bready[g0]                                         ),  // Response ready
            // AXI read address channel signals
            .araddr		    ( axi_araddr[(g0 * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH]      ),  // Read address
            .arlen		    ( axi_arlen[(g0 * `AXI_LEN_WTH) +: `AXI_LEN_WTH]         ),  // Read Burst Length
            .arvalid		( axi_arvalid[g0]                                        ),  // Read address valid  
            .arready		( axi_arready[g0]                                        ),  // Read address ready
            // AXI read data channel signals   
            // .rid_m          ( c0_ddr4_s_axi_rid                                      ),  // Read ID        
            .rdata		    ( axi_rdata[(g0 * `AXI_DATA_WTH) +: `AXI_DATA_WTH]       ),  // Read data
            .rresp		    ( axi_rresp[(g0 * `AXI_RESP_WTH) +: `AXI_RESP_WTH]       ),  // Read response
            .rlast_d	    ( rlast_d[g0]                                            ),  // Read last
            .rvalid		    ( axi_rvalid[g0]                                         ),  // Read reponse valid
            .rready		    ( axi_rready[g0]                                         )   // Read Response ready      
        );
        
        assign axi_intf[g0] = example_top.AXI_INTF[g0].i0_axi_intf;
        
    end endgenerate
    */


    integer idx = 0;
    initial begin
        // resetIntf(axi_intf);
        // fork
        //     axi_drvr(0, "./memTrace_0_im.txt", axi_intf[0], 48336, sys_intf);
        //     // axi_drvr(1, "./memTrace_0_om.txt", axi_intf[1], 261187, sys_intf);
        //     // axi_drvr(2, "./memTrace_0_pm.txt", axi_intf[2], 1444361, sys_intf);
        //     // axi_drvr(3, "./memTrace_0_pv.txt", axi_intf[3], , sys_intf);
        //     // axi_drvr(4, "./memTrace_0_rm.txt", axi_intf[4], 197828, sys_intf);
        // join_none
        $timeformat(-12, 2, " ps", 20);
        // c0_ddr4_s_axi_arid = 0;
        // c0_ddr4_s_axi_araddr = 0;
        // c0_ddr4_s_axi_arlen = 0;
        // c0_ddr4_s_axi_arvalid = 0;
        // c0_ddr4_s_axi_arburst = 0;
        // c0_ddr4_s_axi_arsize = 0;
        // c0_ddr4_s_axi_rready = 0;
        // c0_ddr4_s_axi_awvalid = 0;
        // c0_ddr4_s_axi_awaddr = 0;
        // c0_ddr4_s_axi_awid = 0;
        // c0_ddr4_s_axi_awburst = 0;
        // c0_ddr4_s_axi_awsize = 0;
        // c0_ddr4_s_axi_awlen = 0;
        // c0_ddr4_s_axi_wvalid = 0;
        // c0_ddr4_s_axi_wstrb = 0;
        // c0_ddr4_s_axi_wdata = 0;
        // c0_ddr4_s_axi_bready = 0;
        // c0_ddr4_s_axi_wlast = 0;
        // forever begin
        //     @(posedge c0_sys_clk_p);
        //     if(c0_init_calib_complete == 1 && c0_ddr4_reset_n == 1) begin
        //         break;
        //     end
        // end
        // forever begin
        //     @(posedge c0_ddr4_clk);
        //     if(c0_ddr4_s_axi_arready == 1) begin
        //         break;
        //     end
        // end
        // @(posedge c0_ddr4_clk);
        // c0_ddr4_s_axi_arid = 0;
        // c0_ddr4_s_axi_araddr = 3072;
        // c0_ddr4_s_axi_arlen = 300;
        // c0_ddr4_s_axi_arvalid = 1;
        // c0_ddr4_s_axi_arburst = 1;
        // c0_ddr4_s_axi_arsize = 6;
        // c0_ddr4_s_axi_rready = 1;
        // @(posedge c0_ddr4_clk);
        // c0_ddr4_s_axi_araddr = 0;
        // c0_ddr4_s_axi_arlen = 0;
        // c0_ddr4_s_axi_arvalid = 0;
        // c0_ddr4_s_axi_arburst = 0;
        // c0_ddr4_s_axi_arsize = 0;
        
        

        axi_araddr[(idx * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH] = 0;
        axi_arlen[(idx * `AXI_LEN_WTH) +: `AXI_LEN_WTH] = 0;
        axi_arvalid[idx] = 0;
        axi_rready[idx] = 0;
        axi_awvalid[idx] = 0;
        axi_awaddr[(idx * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH] = 0;
        axi_awlen[(idx * `AXI_LEN_WTH) +: `AXI_LEN_WTH] = 0;
        axi_wvalid[idx] = 0;
        axi_wstrb = 0;
        axi_wdata = 0;
        axi_bready[idx] = 0;
        axi_wlast[idx] = 0;
        forever begin
            @(posedge c0_sys_clk_p);
            if(c0_init_calib_complete == 1 && c0_ddr4_reset_n == 1) begin
                break;
            end
        end
        forever begin
            @(posedge c0_ddr4_clk);
            if(c0_ddr4_s_axi_arready == 1) begin
                break;
            end
        end
        @(posedge c0_ddr4_clk);
        axi_araddr[(idx * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH] = 3072;
        axi_arlen[(idx * `AXI_LEN_WTH) +: `AXI_LEN_WTH] = 10;
        axi_arvalid[idx] = 1;
        axi_rready[idx] = 1;
        @(posedge c0_ddr4_clk);
        axi_araddr[(idx * `AXI_ADDR_WTH) +: `AXI_ADDR_WTH] = 0;
        axi_arlen[(idx * `AXI_LEN_WTH) +: `AXI_LEN_WTH] = 0;
        axi_arvalid[idx] = 0;
    end
    
    
    assign ce = sys_rdy;   
    always@(posedge c0_sys_clk_p or sys_rst) begin
        if(sys_rst) begin
            sys_rdy <= 0;
        end else if(c0_init_calib_complete && c0_ddr4_reset_n) begin
            sys_rdy <= 1;
        end
    end
endmodule


/*
task resetIntf(virtual AXI_intf axi_intf[0:4]);
    int i;
    //---------------------------------------------------------------------------------------------    
    for(i = 0; i < 5; i = i + 1) begin
        axi_intf[i].rdAddr.arvalid <= 0;
        axi_intf[i].rdAddr.araddr  <= 0;
        axi_intf[i].rdAddr.arlen   <= 0; 
        axi_intf[i].rdData.rready  <= 0;
    end
    for(i = 0; i < 5; i = i + 1) begin
        axi_intf[i].wrAddr.awvalid <= 0;
        axi_intf[i].wrAddr.awaddr  <= 0;
        axi_intf[i].wrAddr.awlen   <= 0; 
        axi_intf[i].wrData.wvalid  <= 0;
        axi_intf[i].wrData.wlast   <= 0;
        axi_intf[i].resp.bready    <= 0;
    end
endtask: resetIntf


task axi_drvr(int id, string fn, virtual AXI_intf axi_intf, shortreal trans_tot, virtual Sys_intf sys_intf);
    integer fd;
    shortreal trans_no;
    int time_delta;
    int op;
    time addr;
    shortreal onehnrd;
    int len;
    int prog_factor;
    int perct;
    //---------------------------------------------------------------------------------------------
    fd = $fopen(fn, "r");
    prog_factor = 10;
    onehnrd = 100.0;
    forever begin
        @(axi_intf.clk);
        if(!axi_intf.rst && axi_intf.ce) begin
            break;
        end
    end
    while(!$feof(fd)) begin
        $fscanf(fd, "%d,%d,%d,%d,%d\n", trans_no, time_delta, op, addr, len);
        time_delta = 0;
        repeat(time_delta) @(sys_intf.clk);
        if(op == 0) begin
            axi_rd(id, fn, trans_no, addr, len, axi_intf);
        end else begin // WRITE
            axi_wr(id, fn, trans_no, addr, len, axi_intf);
        end       
        perct = $floor((trans_no / trans_tot) * onehnrd);
        if(perct >= prog_factor && perct > 0) begin
            prog_factor = prog_factor + 10;
            $display("finished %d / %d transactions", trans_no, trans_tot);
        end
    end
    $fclose(fd);
endtask: axi_drvr


task axi_rd(int id, string fn, int trans_no, logic[31:0] addr, logic[7:0] len, virtual AXI_intf axi_intf);
    forever begin
        @(axi_intf.clk);
        if(axi_intf.rdAddr.arready) begin
            break;
        end
    end
    @(axi_intf.clk);
    axi_intf.rdAddr.arvalid <= 1;
    axi_intf.rdAddr.araddr  <= addr;
    axi_intf.rdAddr.arlen   <= len; 
    axi_intf.rdData.rready  <= 1;
    @(axi_intf.clk);
    $display("[AXI_READ STARTED]: %s Transaction No. %d", fn, trans_no);
    $display("\taddress: %d", addr);
    $display("\tlength:  %d", len);
    axi_intf.rdAddr.arvalid <= 0;
    axi_intf.rdAddr.araddr  <= 0;
    axi_intf.rdAddr.arlen   <= 0;
    forever begin
        @(axi_intf.clk);
        if(axi_intf.rlast_d && axi_intf.rid_m == id) begin
            $display("[AXI READ FINISHED]: %s Transaction No. %d", fn, trans_no);
            break;
        end
    end
    @(axi_intf.clk);
    axi_intf.rdData.rready  <= 0;
endtask: axi_rd


task axi_wr(int id, string fn, int trans_no, logic[31:0] addr, logic[7:0] len, virtual AXI_intf axi_intf); 
    int i;
    forever begin
        @(axi_intf.clk);
        if(axi_intf.wrAddr.awready) begin
            break;
        end
    end
    i = 0;
    @(axi_intf.clk);
    axi_intf.wrAddr.awvalid <= 1;
    axi_intf.wrAddr.awaddr  <= addr;
    axi_intf.wrAddr.awlen   <= len; 
    axi_intf.wrData.wvalid  <= 1;
    axi_intf.resp.bready    <= 1;
    @(axi_intf.clk);
    $display("[AXI WRITE STARTED]: %s Transaction No. %d", fn, trans_no);
    $display("\taddress: %d", addr);
    $display("\tlength: %d", len);
    axi_intf.wrAddr.awvalid <= 0;
    axi_intf.wrAddr.awaddr  <= 0;
    axi_intf.wrAddr.awlen   <= 0;
    forever begin
        @(axi_intf.clk);
        if(i == (len - 1)) begin
            axi_intf.wrData.wlast <= 1;
        end
        if(axi_intf.resp.bvalid) begin
            $display("[AXI WRITE FINISHED]: %s Transaction No. %d", fn, trans_no);
            break;
        end
        i = i + 1;
    end
    @(axi_intf.clk);
    axi_intf.wrData.wlast   <= 0;
    axi_intf.resp.bready    <= 0;
    axi_intf.wrData.wvalid  <= 0;
endtask: axi_wr
*/