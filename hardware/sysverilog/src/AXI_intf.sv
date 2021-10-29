`ifndef __AXI_INTERFACE__
`define __AXI_INTERFACE__


`timescale 1ns / 1ps


interface AXI_intf
(
	clk			    ,
    ce              ,
    rst             ,
    // AXI Write Address Ports
    awaddr		    ,   // Write address
    awlen		    ,   // Write Burst Length
    awvalid		    ,   // Write address valid
    awready		    ,   // Wrire address is ready
    // AXI write data channel signals
    wdata		    ,   // Write data
    wlast		    ,   // Last write transaction   
    wvalid		    ,   // Write valid    
    wready		    ,   // Write data ready
    // AXI write response channel signals
    bresp		    ,   // Write response
    bvalid		    ,   // Write reponse valid
    bready		    ,   // Response ready 
    // AXI read address channel signals
    araddr		    ,   // Read address
    arlen		    ,   // Read Burst Length
    arvalid		    ,   // Read address valid     
    arready		    ,   // Read address ready
    // AXI read data channel signals
    rid_m           ,
    rdata		    ,   // Read data
    rresp		    ,   // Read response
    rlast_d		    ,   // Read last
    rvalid		    ,   // Read reponse valid
    rready		        // Read Response ready	   
);
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    //  Includes
    //-----------------------------------------------------------------------------------------------------------------------------------------------
	`include "axi_defs.svh"


	//-----------------------------------------------------------------------------------------------------------------------------------------------
	//	Interface Ports
	//-----------------------------------------------------------------------------------------------------------------------------------------------	
 	// AXI Write Address Ports   
    input  logic						    clk			    ;
    input  logic                            ce              ;
    input  logic                            rst             ;
    // AXI Write Address Ports 
 	output logic [ `AXI_ADDR_WTH - 1:0]  	awaddr		    ;	// Write address
 	output logic [  `AXI_LEN_WTH - 1:0]  	awlen		    ;	// Write Burst Length
	output logic  	                        awvalid		    ;	// Write address valid
    input  logic                            awready		    ;	// Wrire address is ready
	// AXI write data channel signals
	output logic [ `AXI_DATA_WTH - 1:0]  	wdata		    ;	// Write data
	output logic 	                        wlast		    ;	// Last write transaction   
	output logic 	                        wvalid		    ;	// Write valid  	
    input  logic 	                        wready		    ;	// Write data ready
	// AXI write response channel signals
	input  logic [ `AXI_RESP_WTH - 1:0]  	bresp		    ;	// Write response
	input  logic  	                        bvalid		    ;	// Write reponse valid
	output logic  	                        bready		    ;	// Response ready
	// AXI read address channel signals
	output logic [ `AXI_ADDR_WTH - 1:0]     araddr		    ;   // Read address
	output logic [  `AXI_LEN_WTH - 1:0]     arlen		    ;   // Read Burst Length
 	output logic                            arvalid		    ;   // Read address valid  
	input  logic                            arready		    ;   // Read address ready
	// AXI read data channel signals   
    input  logic [                 3:0]     rid_m           ;
    input  logic [ `AXI_DATA_WTH - 1:0]     rdata		    ;   // Read data
	input  logic [ `AXI_RESP_WTH - 1:0]     rresp		    ;   // Read response
	input  logic                            rlast_d		    ;   // Read last
	input  logic                            rvalid		    ;   // Read reponse valid
	output logic                            rready		    ;   // Read Response ready	


    
    clocking wrAddr @(posedge clk);
        output      awaddr          ;
        output      awlen           ;
		output	    awvalid			;        
        input       awready         ;
	endclocking: wrAddr
    

	clocking wrData @(posedge clk);
		input       wready          ;
        output      wvalid          ;
        output      wlast           ;
        output      wdata           ;
	endclocking: wrData
	
    
    clocking resp @(posedge clk);
        input       bresp           ;
		input       bvalid          ;        
        output      bready          ;
	endclocking: resp
    
    
    clocking rdAddr @(posedge clk);
        output      araddr          ;        
        output      arlen           ; 
        output      arvalid         ;
        input       arready         ;
    endclocking: rdAddr


	clocking rdData @(posedge clk);
        input       rdata           ;
        input       rresp           ;
        input       rlast_d         ;
		input       rvalid          ;
        inout       rready          ;
	endclocking: rdData


endinterface: AXI_intf


`endif