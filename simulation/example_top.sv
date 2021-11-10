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


`define AXI_INTF    sim_tb_top.u_example_top
`define TOP         sim_tb_top.u_example_top


typedef struct {
    time id;
    string fn;
    int op;
    real ts;
    int dma_ref;
    time addr;
    time len;
    int minIdx;
} axi_trans_t;


function string get_time();
    int file_pointer;
    //Stores time and date to file sys_time
    void'($system("date > ./sys_time"));
    //Open the file sys_time with read access
    file_pointer = $fopen("./sys_time", "r");
    //assin the value from file to variable
    void'($fgets(get_time, file_pointer));
    //close the file
    $fclose(file_pointer);
    void'($system("rm ./sys_time"));
endfunction: get_time


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


  localparam  APP_ADDR_WIDTH = 29;
  localparam  MEM_ADDR_ORDER = "ROW_COLUMN_BANK";
  localparam DBG_WR_STS_WIDTH      = 32;
  localparam DBG_RD_STS_WIDTH      = 32;
  localparam ECC                   = "ON";
  localparam C_PERIOD_83MHz = 12; 




    //-----------------------------------------------------------------------------------------------------------------------------------------------
    // Local Variables
    //-----------------------------------------------------------------------------------------------------------------------------------------------

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
  logic [0:3]           trans_in_prog;


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
  logic [3:0]      c0_ddr4_s_axi_awid;
  logic [31:0]    c0_ddr4_s_axi_awaddr;
  logic [7:0]                       c0_ddr4_s_axi_awlen;
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
  logic                             c0_ddr4_s_axi_arvalid;
  logic                             c0_ddr4_s_axi_arready;
   // Slave Interface Read Data Ports
  logic                             c0_ddr4_s_axi_rready;
  logic [3:0]      c0_ddr4_s_axi_rid;
  logic [511:0]    c0_ddr4_s_axi_rdata;
  logic [1:0]                       c0_ddr4_s_axi_rresp;
  logic                             c0_ddr4_s_axi_rlast;
  logic                             c0_ddr4_s_axi_rvalid;

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
  .c0_ddr4_s_axi_awsize                (3'b110),
  .c0_ddr4_s_axi_awburst               (2'b01),
  .c0_ddr4_s_axi_awlock                (1'b0),
  .c0_ddr4_s_axi_awcache               (4'b0),
  .c0_ddr4_s_axi_awprot                (3'b0),
  .c0_ddr4_s_axi_awqos                 (4'b0),
  .c0_ddr4_s_axi_awvalid               (c0_ddr4_s_axi_awvalid),
  .c0_ddr4_s_axi_awready               (c0_ddr4_s_axi_awready),
  // Slave Interface Write Data Ports
  .c0_ddr4_s_axi_wdata                 (c0_ddr4_s_axi_wdata),
  .c0_ddr4_s_axi_wstrb                 (64'hFFFFFFFFFFFFFFFF),
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
  .c0_ddr4_s_axi_arsize                (3'b110),
  .c0_ddr4_s_axi_arburst               (2'b01),
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


   
    
    

    logic [3:0] axi_rready;
    assign c0_ddr4_s_axi_rready = axi_rready[0] | axi_rready[1] | axi_rready[2] | axi_rready[3];
    
    assign ce = sys_rdy;   
    always@(posedge c0_sys_clk_p or sys_rst) begin
        if(sys_rst) begin
            sys_rdy <= 0;
        end else if(c0_init_calib_complete && c0_ddr4_reset_n) begin
            sys_rdy <= 1;
        end
    end


    initial begin
        resetIntf();
        axi_drvr();
        while(|trans_in_prog) begin
            @(posedge c0_ddr4_clk);
        end
        $stop;
    end
endmodule


task resetIntf();
    `AXI_INTF.c0_ddr4_s_axi_arvalid = 0;
    `AXI_INTF.c0_ddr4_s_axi_arid    = 0;
    `AXI_INTF.c0_ddr4_s_axi_araddr  = 0;
    `AXI_INTF.c0_ddr4_s_axi_arlen   = 0;
    `AXI_INTF.axi_rready[0]         = 0;
    `AXI_INTF.axi_rready[1]         = 0; 
    `AXI_INTF.axi_rready[2]         = 0; 
    `AXI_INTF.axi_rready[3]         = 0;     
    `AXI_INTF.c0_ddr4_s_axi_awvalid = 0;
    `AXI_INTF.c0_ddr4_s_axi_awid    = 0;
    `AXI_INTF.c0_ddr4_s_axi_awaddr  = 0;
    `AXI_INTF.c0_ddr4_s_axi_awlen   = 0; 
    `AXI_INTF.c0_ddr4_s_axi_wlast   = 0;
    `AXI_INTF.c0_ddr4_s_axi_bready  = 0;
    `AXI_INTF.c0_ddr4_s_axi_wvalid  = 0;    
endtask: resetIntf


function axi_trans_t findMin(int idx0, axi_trans_t axi_trans_0, int idx1, axi_trans_t axi_trans_1);
    axi_trans_t axi_trans;
    if(axi_trans_0.ts <= axi_trans_1.ts) begin
        axi_trans.id        = axi_trans_0.id;
        axi_trans.fn        = axi_trans_0.fn;
        axi_trans.op        = axi_trans_0.op;
        axi_trans.dma_ref   = axi_trans_0.dma_ref;
        axi_trans.ts        = axi_trans_0.ts;
        axi_trans.addr      = axi_trans_0.addr;
        axi_trans.len       = axi_trans_0.len;
        axi_trans.minIdx    = idx0;
    end else begin
        axi_trans.id        = axi_trans_1.id;
        axi_trans.fn        = axi_trans_1.fn;
        axi_trans.op        = axi_trans_1.op;
        axi_trans.dma_ref   = axi_trans_1.dma_ref;       
        axi_trans.ts        = axi_trans_1.ts;
        axi_trans.addr      = axi_trans_1.addr;
        axi_trans.len       = axi_trans_1.len;
        axi_trans.minIdx    = idx1;
    end
    return axi_trans;
endfunction: findMin


function automatic axi_trans_t getTrans(ref integer fd_im, ref integer fd_pm, ref integer fd_rm, ref integer fd_om, ref axi_trans_t axi_trans[0:3]);
    axi_trans_t axi_trans_ret0, axi_trans_ret1, axi_trans_ret2;    
    if(fd_im != -1 && axi_trans[0].id == -1) begin
        $fscanf(fd_im, "%d,%d,%d,%d,%d\n", axi_trans[0].id, axi_trans[0].ts, axi_trans[0].op, axi_trans[0].addr, axi_trans[0].len);
        axi_trans[0].dma_ref    = 0; 
        axi_trans[0].fn         = "./memTrace_0_im.txt";
    end
    if(fd_pm != -1 && axi_trans[1].id == -1) begin
        $fscanf(fd_pm, "%d,%d,%d,%d,%d\n", axi_trans[1].id, axi_trans[1].ts, axi_trans[1].op, axi_trans[1].addr, axi_trans[1].len);
        axi_trans[1].dma_ref    = 1; 
        axi_trans[1].fn         = "./memTrace_0_pm.txt.txt";
    end
    if(fd_rm != -1 && axi_trans[2].id == -1) begin
        $fscanf(fd_rm, "%d,%d,%d,%d,%d\n", axi_trans[2].id, axi_trans[2].ts, axi_trans[2].op, axi_trans[2].addr, axi_trans[2].len);
        axi_trans[2].dma_ref    = 2;
        axi_trans[2].fn         = "./memTrace_0_rm.txt";
    end
    if(fd_om != -1 && axi_trans[3].id == -1) begin
        $fscanf(fd_om, "%d,%d,%d,%d,%d\n", axi_trans[3].id, axi_trans[3].ts, axi_trans[3].op, axi_trans[3].addr, axi_trans[3].len);
        axi_trans[3].dma_ref    = 3;
        axi_trans[3].fn         = "./memTrace_0_om.txt";
    end
    axi_trans_ret0 = findMin(0, axi_trans[0], 1, axi_trans[1]);
    axi_trans_ret1 = findMin(2, axi_trans[2], 3, axi_trans[3]);
    axi_trans_ret2 = findMin(axi_trans_ret0.minIdx, axi_trans_ret0, axi_trans_ret1.minIdx, axi_trans_ret1);
    null_axi_trans(axi_trans[axi_trans_ret2.minIdx]);
    return axi_trans_ret2;
endfunction: getTrans


function automatic void postLoop(ref integer fd_im, ref integer fd_pm, ref integer fd_rm, ref integer fd_om);
    if($feof(fd_im)) begin
        $fclose(fd_im); 
        fd_im = -1;
    end
    if($feof(fd_pm)) begin
        $fclose(fd_pm); 
        fd_pm = -1;
    end
    if($feof(fd_rm)) begin 
        $fclose(fd_rm); 
        fd_rm = -1;
    end
    if($feof(fd_om)) begin 
        $fclose(fd_om); 
        fd_om = -1;
    end
endfunction: postLoop


task axi_drvr();
    integer fd, fd_im, fd_pm, fd_rm, fd_om;
    shortreal trans_no;
    shortreal trans_tot;  
    shortreal onehnrd;
    real three1000;
    int prog_factor;
    int perct;
    real t_ofst;
    real time_delta;
    string cur_time;
    // ./memTrace_0_im.txt 48336
    // ./memTrace_0_om.txt 246657
    // ./memTrace_0_pm.txt 1444361
    // ./memTrace_0_rm.txt 197828
    axi_trans_t axi_trans_arr[0:3];
    axi_trans_t axi_trans;
    //---------------------------------------------------------------------------------------------
    fd_im = -1; fd_pm = -1; fd_rm = -1; fd_om = -1;
    fd_im = $fopen("./memTrace_0_im.txt", "r"); fd_pm = $fopen("./memTrace_0_pm.txt", "r");
    fd_rm = $fopen("./memTrace_0_rm.txt", "r"); fd_om = $fopen("./memTrace_0_om.txt", "r");
    trans_no = 0;
    trans_tot = 14937182;
    prog_factor = 10;
    onehnrd = 100.0;
    three1000 = 3000.0;
    
    null_axi_trans(axi_trans_arr[0]); null_axi_trans(axi_trans_arr[1]);
    null_axi_trans(axi_trans_arr[2]); null_axi_trans(axi_trans_arr[3]);
    `TOP.trans_in_prog = 0;

    forever begin
        @(posedge `TOP.c0_ddr4_clk);
        if(!sim_tb_top.u_example_top.sys_rst && sim_tb_top.u_example_top.ce) begin
            break;
        end
    end
    t_ofst = real'($time);
    
    fd = $fopen("./start.txt", "w");
    cur_time = get_time();
    $fdisplay(fd, "%s\n", cur_time);
    $fclose(fd);
    fd = $fopen("./progress.txt", "w");
    $fclose(fd);
    while(fd_im != -1 && fd_pm != -1 && fd_rm != -1 && fd_om != -1) begin
        @(posedge `TOP.c0_ddr4_clk);
        axi_trans = getTrans(fd_im, fd_pm, fd_rm, fd_om, axi_trans_arr);
        time_delta = axi_trans.ts - $floor((real'($time) - t_ofst) / three1000);
        repeat(time_delta) @(posedge `TOP.c0_ddr4_clk);        
        if(axi_trans.op == 0) begin // READ
            axi_schd_rd(axi_trans);
        end else begin // WRITE
            axi_schd_wr(axi_trans);
        end
        postLoop(fd_im, fd_pm, fd_rm, fd_om);
        perct = $floor((trans_no / trans_tot) * onehnrd);
        if(perct >= prog_factor && perct > 0) begin
            prog_factor = prog_factor + 10;
            $display("finished %d / %d transactions", trans_no, trans_tot);
            fd = $fopen("./progress.txt", "a");
            cur_time = get_time();
            $fdisplay(fd, "finished %d / %d transactions at %s\n", trans_no, trans_tot, cur_time);
            $fclose(fd);
        end
        trans_no = trans_no + 1;
    end
    fd = $fopen("./end.txt", "w");
    cur_time = get_time();
    $fdisplay(fd, "%s\n", cur_time);
    $fclose(fd);
endtask: axi_drvr


function automatic void null_axi_trans(ref axi_trans_t axi_trans);
    axi_trans.id = -1;
    axi_trans.fn = "";
    axi_trans.dma_ref = -1;
    axi_trans.op = "";
    axi_trans.ts = -1;
    axi_trans.addr = -1;
    axi_trans.len = -1;
endfunction: null_axi_trans


task axi_schd_rd(axi_trans_t axi_trans);
    forever begin
        @(posedge `AXI_INTF.c0_ddr4_clk);
        if(`AXI_INTF.c0_ddr4_s_axi_arready && !`TOP.trans_in_prog[axi_trans.dma_ref]) begin
            break;
        end
    end
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.c0_ddr4_s_axi_arvalid = 1;
    `AXI_INTF.c0_ddr4_s_axi_arid    = axi_trans.dma_ref;
    `AXI_INTF.c0_ddr4_s_axi_araddr  = axi_trans.addr;
    `AXI_INTF.c0_ddr4_s_axi_arlen   = axi_trans.len; 
    $display("[AXI_READ STARTED]: %s Transaction No. %d", axi_trans.fn, axi_trans.id);
    $display("\taddress: %d", axi_trans.addr);
    $display("\tlength:  %d", axi_trans.len);
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.c0_ddr4_s_axi_arvalid = 0;    
    `AXI_INTF.c0_ddr4_s_axi_arid    = 0;
    `AXI_INTF.c0_ddr4_s_axi_araddr  = 0;
    `AXI_INTF.c0_ddr4_s_axi_arlen   = 0;    
    fork
        axi_wait_rd_cmpl(axi_trans);
    join_none    
endtask: axi_schd_rd


task axi_schd_wr(axi_trans_t axi_trans);
    forever begin
        @(posedge `AXI_INTF.c0_ddr4_clk);
        if(`AXI_INTF.c0_ddr4_s_axi_awready && !`TOP.trans_in_prog[axi_trans.dma_ref]) begin
            break;
        end
    end
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.c0_ddr4_s_axi_awid    = 0;
    `AXI_INTF.c0_ddr4_s_axi_awvalid = 1;
    `AXI_INTF.c0_ddr4_s_axi_awaddr  = axi_trans.addr;
    `AXI_INTF.c0_ddr4_s_axi_awlen   = axi_trans.len; 
    $display("[AXI WRITE STARTED]: %s Transaction No. %d", axi_trans.fn, axi_trans.id);
    $display("\taddress: %d", axi_trans.addr);
    $display("\tlength: %d", axi_trans.len); 
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.c0_ddr4_s_axi_awvalid = 0;
    `AXI_INTF.c0_ddr4_s_axi_awaddr  = 0;
    `AXI_INTF.c0_ddr4_s_axi_awlen   = 0;       
    fork
        axi_wait_wr_cmpl(axi_trans);
    join_none
endtask: axi_schd_wr


task axi_wait_rd_cmpl(axi_trans_t axi_trans);
    int i;
    i = 0;
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.axi_rready[axi_trans.dma_ref]  = 1;  
    `TOP.trans_in_prog[axi_trans.dma_ref] = 1;
    while(i <= axi_trans.len)  begin
        @(posedge `AXI_INTF.c0_ddr4_clk); 
        if(`AXI_INTF.c0_ddr4_s_axi_rvalid && `AXI_INTF.c0_ddr4_s_axi_rid == axi_trans.dma_ref) begin
            i = i + 1;
        end
    end
    forever begin
        @(posedge `AXI_INTF.c0_ddr4_clk);
        if(`AXI_INTF.c0_ddr4_s_axi_rlast && `AXI_INTF.c0_ddr4_s_axi_rid == axi_trans.dma_ref) begin
            $display("[AXI READ FINISHED]: %s Transaction No. %d", axi_trans.fn, axi_trans.id);
            break;
        end
    end
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.axi_rready[axi_trans.dma_ref]  = 0; 
    `TOP.trans_in_prog[axi_trans.dma_ref] = 0;
endtask: axi_wait_rd_cmpl


task axi_wait_wr_cmpl(axi_trans_t axi_trans);
    int i;
    //---------------------------------------------------------------------------------------------
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.c0_ddr4_s_axi_wvalid = 1;  
    `TOP.trans_in_prog[axi_trans.dma_ref] = 1;
    i = 0;
    while(i <= axi_trans.len)  begin
        @(posedge `AXI_INTF.c0_ddr4_clk);
        if(i == axi_trans.len) begin
            `AXI_INTF.c0_ddr4_s_axi_wlast = 1;
        end
        if(`AXI_INTF.c0_ddr4_s_axi_wvalid && `AXI_INTF.c0_ddr4_s_axi_wready) begin
            i = i + 1;
        end
    end
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.c0_ddr4_s_axi_wlast  = 0;    
    `AXI_INTF.c0_ddr4_s_axi_wvalid = 0;
    @(posedge `AXI_INTF.c0_ddr4_clk);
    `AXI_INTF.c0_ddr4_s_axi_bready = 1;
    forever begin
        @(posedge `AXI_INTF.c0_ddr4_clk);   
        if(`AXI_INTF.c0_ddr4_s_axi_bvalid) begin
            $display("[AXI WRITE FINISHED]: %s Transaction No. %d", axi_trans.fn, axi_trans.id);
            break;
        end
    end
    `AXI_INTF.c0_ddr4_s_axi_bready = 0;
    `TOP.trans_in_prog[axi_trans.dma_ref] = 0;
endtask: axi_wait_wr_cmpl

