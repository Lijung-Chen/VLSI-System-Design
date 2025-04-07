//faster DRAM
//new AXI
//new WDT(CDC)
//new CPU
//synthesize at CAVLAB
//new DRAM wrapper

`timescale 1ns / 10ps
`include "../include/AXI_define.svh"
`include "CPU_wrapper.sv"
`include "SRAM_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "ROM_wrapper.sv"
`include "SCtrl_wrapper.sv"
`include "WDT_wrapper.sv"
`include "./AXI/AXI.sv"


module top(
	input  logic           cpu_clk,
	input  logic           axi_clk,
	input  logic           rom_clk,
	input  logic           dram_clk,
	input  logic           sram_clk,
	input  logic           cpu_rst,
	input  logic           axi_rst,
	input  logic           rom_rst,
	input  logic           dram_rst,
	input  logic           sram_rst,
	input  logic           sensor_ready,
	input  logic [   31:0] sensor_out,
	output logic           sensor_en,
	input  logic [   31:0] ROM_out,
	input  logic [   31:0] DRAM_Q,
	output logic           ROM_read,
	output logic           ROM_enable,
	output logic [   11:0] ROM_address,
	output logic           DRAM_CSn,
	output logic [    3:0] DRAM_WEn,
	output logic           DRAM_RASn,
	output logic           DRAM_CASn,
	output logic [   10:0] DRAM_A,
	output logic [   31:0] DRAM_D,
	input  logic           DRAM_valid
);

logic sensor_ctrl_interrupt;
logic WDT_interrupt;

logic                           ARREADY_M0;
logic   [`AXI_ID_BITS-1:0]      ARID_M0;
logic   [`AXI_ADDR_BITS-1:0]    ARADDR_M0;
logic   [`AXI_LEN_BITS-1:0]     ARLEN_M0;
logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_M0;
logic   [1:0]                   ARBURST_M0;
logic                           ARVALID_M0;

logic   [`AXI_ID_BITS-1:0]      RID_M0;
logic   [`AXI_DATA_BITS-1:0]    RDATA_M0;
logic   [1:0]                   RRESP_M0;
logic                           RLAST_M0;
logic                           RVALID_M0;
logic                           RREADY_M0;

logic                           ARREADY_M1;
logic   [`AXI_ID_BITS-1:0]      ARID_M1;
logic   [`AXI_ADDR_BITS-1:0]    ARADDR_M1;
logic   [`AXI_LEN_BITS-1:0]     ARLEN_M1;
logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_M1;
logic   [1:0]                   ARBURST_M1;
logic                           ARVALID_M1;
logic   [`AXI_ID_BITS-1:0]      RID_M1;
logic   [`AXI_DATA_BITS-1:0]    RDATA_M1;
logic   [1:0]                   RRESP_M1;
logic                           RLAST_M1;
logic                           RVALID_M1;
logic                           RREADY_M1;

logic                           AWREADY_M1;
logic   [`AXI_ID_BITS-1:0]      AWID_M1;
logic   [`AXI_ADDR_BITS-1:0]    AWADDR_M1;
logic   [`AXI_LEN_BITS-1:0]     AWLEN_M1;
logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_M1;
logic   [1:0]                   AWBURST_M1;
logic                           AWVALID_M1;
logic                           WREADY_M1;
logic   [`AXI_DATA_BITS-1:0]    WDATA_M1;
logic   [`AXI_STRB_BITS-1:0]    WSTRB_M1;
logic                           WLAST_M1;
logic                           WVALID_M1;
logic   [`AXI_ID_BITS-1:0]      BID_M1;
logic   [1:0]                   BRESP_M1;
logic                           BVALID_M1;
logic                           BREADY_M1;

/* S0: ROM */
logic   [`AXI_IDS_BITS-1:0]     ARID_S0;
logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S0;
logic   [`AXI_LEN_BITS-1:0]     ARLEN_S0;
logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S0;
logic   [1:0]                   ARBURST_S0;
logic                           ARVALID_S0;
logic                           ARREADY_S0;
logic                           RREADY_S0;
logic   [`AXI_IDS_BITS-1:0]     RID_S0;
logic   [`AXI_DATA_BITS-1:0]    RDATA_S0;
logic   [1:0]                   RRESP_S0;
logic                           RLAST_S0;
logic                           RVALID_S0;

/* S1: IM */
logic   [`AXI_IDS_BITS-1:0]     ARID_S1;
logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S1;
logic   [`AXI_LEN_BITS-1:0]     ARLEN_S1;
logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S1;
logic   [1:0]                   ARBURST_S1;
logic                           ARVALID_S1;
logic                           ARREADY_S1;
logic                           RREADY_S1;
logic   [`AXI_IDS_BITS-1:0]     RID_S1;
logic   [`AXI_DATA_BITS-1:0]    RDATA_S1;
logic   [1:0]                   RRESP_S1;
logic                           RLAST_S1;
logic                           RVALID_S1;

logic   [`AXI_IDS_BITS-1:0]     AWID_S1;
logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S1;
logic   [`AXI_LEN_BITS-1:0]     AWLEN_S1;
logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S1;
logic   [1:0]                   AWBURST_S1;
logic                           AWVALID_S1;
logic                           AWREADY_S1;
logic   [`AXI_DATA_BITS-1:0]    WDATA_S1;
logic   [`AXI_STRB_BITS-1:0]    WSTRB_S1;
logic                           WLAST_S1;
logic                           WVALID_S1;
logic                           WREADY_S1;
logic                           BREADY_S1;
logic   [`AXI_IDS_BITS-1:0]     BID_S1;
logic   [1:0]                   BRESP_S1;
logic                           BVALID_S1;

/* S2: DM */
logic   [`AXI_IDS_BITS-1:0]     ARID_S2;
logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S2;
logic   [`AXI_LEN_BITS-1:0]     ARLEN_S2;
logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S2;
logic   [1:0]                   ARBURST_S2;
logic                           ARVALID_S2;
logic                           ARREADY_S2;
logic                           RREADY_S2;
logic   [`AXI_IDS_BITS-1:0]     RID_S2;
logic   [`AXI_DATA_BITS-1:0]    RDATA_S2;
logic   [1:0]                   RRESP_S2;
logic                           RLAST_S2;
logic                           RVALID_S2;

logic   [`AXI_IDS_BITS-1:0]     AWID_S2;
logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S2;
logic   [`AXI_LEN_BITS-1:0]     AWLEN_S2;
logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S2;
logic   [1:0]                   AWBURST_S2;
logic                           AWVALID_S2;
logic                           AWREADY_S2;
logic   [`AXI_DATA_BITS-1:0]    WDATA_S2;
logic   [`AXI_STRB_BITS-1:0]    WSTRB_S2;
logic                           WLAST_S2;
logic                           WVALID_S2;
logic                           WREADY_S2;
logic                           BREADY_S2;
logic   [`AXI_IDS_BITS-1:0]     BID_S2;
logic   [1:0]                   BRESP_S2;
logic                           BVALID_S2;

/* sensor_ctrl */
logic   [`AXI_IDS_BITS-1:0]     ARID_S3;
logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S3;
logic   [`AXI_LEN_BITS-1:0]     ARLEN_S3;
logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S3;
logic   [1:0]                   ARBURST_S3;
logic                           ARVALID_S3;
logic                           ARREADY_S3;
logic                           RREADY_S3;
logic   [`AXI_IDS_BITS-1:0]     RID_S3;
logic   [`AXI_DATA_BITS-1:0]    RDATA_S3;
logic   [1:0]                   RRESP_S3;
logic                           RLAST_S3;
logic                           RVALID_S3;

logic   [`AXI_IDS_BITS-1:0]     AWID_S3;
logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S3;
logic   [`AXI_LEN_BITS-1:0]     AWLEN_S3;
logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S3;
logic   [1:0]                   AWBURST_S3;
logic                           AWVALID_S3;
logic                           AWREADY_S3;
logic   [`AXI_DATA_BITS-1:0]    WDATA_S3;
logic   [`AXI_STRB_BITS-1:0]    WSTRB_S3;
logic                           WLAST_S3;
logic                           WVALID_S3;
logic                           WREADY_S3;
logic                           BREADY_S3;
logic   [`AXI_IDS_BITS-1:0]     BID_S3;
logic   [1:0]                   BRESP_S3;
logic                           BVALID_S3;


/* S4: WDT */
logic   [`AXI_IDS_BITS-1:0]     ARID_S4;
logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S4;
logic   [`AXI_LEN_BITS-1:0]     ARLEN_S4;
logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S4;
logic   [1:0]                   ARBURST_S4;
logic                           ARVALID_S4;
logic                           ARREADY_S4;
logic                           RREADY_S4;
logic   [`AXI_IDS_BITS-1:0]     RID_S4;
logic   [`AXI_DATA_BITS-1:0]    RDATA_S4;
logic   [1:0]                   RRESP_S4;
logic                           RLAST_S4;
logic                           RVALID_S4;

logic   [`AXI_IDS_BITS-1:0]     AWID_S4;
logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S4;
logic   [`AXI_LEN_BITS-1:0]     AWLEN_S4;
logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S4;
logic   [1:0]                   AWBURST_S4;
logic                           AWVALID_S4;
logic                           AWREADY_S4;
logic   [`AXI_DATA_BITS-1:0]    WDATA_S4;
logic   [`AXI_STRB_BITS-1:0]    WSTRB_S4;
logic                           WLAST_S4;
logic                           WVALID_S4;
logic                           WREADY_S4;
logic                           BREADY_S4;
logic   [`AXI_IDS_BITS-1:0]     BID_S4;
logic   [1:0]                   BRESP_S4;
logic                           BVALID_S4;

/* S5: DRAM */
logic   [`AXI_IDS_BITS-1:0]     ARID_S5;
logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S5;
logic   [`AXI_LEN_BITS-1:0]     ARLEN_S5;
logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S5;
logic   [1:0]                   ARBURST_S5;
logic                           ARVALID_S5;
logic                           ARREADY_S5;
logic                           RREADY_S5;
logic   [`AXI_IDS_BITS-1:0]     RID_S5;
logic   [`AXI_DATA_BITS-1:0]    RDATA_S5;
logic   [1:0]                   RRESP_S5;
logic                           RLAST_S5;
logic                           RVALID_S5;

logic   [`AXI_IDS_BITS-1:0]     AWID_S5;
logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S5;
logic   [`AXI_LEN_BITS-1:0]     AWLEN_S5;
logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S5;
logic   [1:0]                   AWBURST_S5;
logic                           AWVALID_S5;
logic                           AWREADY_S5;
logic   [`AXI_DATA_BITS-1:0]    WDATA_S5;
logic   [`AXI_STRB_BITS-1:0]    WSTRB_S5;
logic                           WLAST_S5;
logic                           WVALID_S5;
logic                           WREADY_S5;
logic                           BREADY_S5;
logic   [`AXI_IDS_BITS-1:0]     BID_S5;
logic   [1:0]                   BRESP_S5;
logic                           BVALID_S5;


AXI AXI( 
	.CPU_CLK_i(cpu_clk),      
	.AXI_CLK_i(axi_clk),        
	.ROM_CLK_i(rom_clk),      
	.DRAM_CLK_i(dram_clk),
	.SRAM_CLK_i(sram_clk),
	.CPU_RST_i(cpu_rst),      
	.AXI_RST_i(axi_rst),        
	.ROM_RST_i(rom_rst),      
	.DRAM_RST_i(dram_rst),
	.SRAM_RST_i(sram_rst),

	.ARID_M0_i(ARID_M0),
	.ARADDR_M0_i(ARADDR_M0),
	.ARLEN_M0_i(ARLEN_M0),
	.ARSIZE_M0_i(ARSIZE_M0),
	.ARBURST_M0_i(ARBURST_M0),
	.ARVALID_M0_i(ARVALID_M0),
	.ARREADY_M0_o(ARREADY_M0),
	.RID_M0_o(RID_M0),
	.RDATA_M0_o(RDATA_M0),
	.RRESP_M0_o(RRESP_M0),
	.RLAST_M0_o(RLAST_M0),
	.RVALID_M0_o(RVALID_M0),
	.RREADY_M0_i(RREADY_M0),

	.AWID_M1_i(AWID_M1),
	.AWADDR_M1_i(AWADDR_M1),
	.AWLEN_M1_i(AWLEN_M1),
	.AWSIZE_M1_i(AWSIZE_M1),
	.AWBURST_M1_i(AWBURST_M1),
	.AWVALID_M1_i(AWVALID_M1),
	.AWREADY_M1_o(AWREADY_M1),
	.WDATA_M1_i(WDATA_M1),
	.WSTRB_M1_i(WSTRB_M1),
	.WLAST_M1_i(WLAST_M1),
	.WVALID_M1_i(WVALID_M1),
	.WREADY_M1_o(WREADY_M1),
	.BID_M1_o(BID_M1),
	.BRESP_M1_o(BRESP_M1),
	.BVALID_M1_o(BVALID_M1),
	.BREADY_M1_i(BREADY_M1),

	.ARID_M1_i(ARID_M1),
	.ARADDR_M1_i(ARADDR_M1),
	.ARLEN_M1_i(ARLEN_M1),
	.ARSIZE_M1_i(ARSIZE_M1),
	.ARBURST_M1_i(ARBURST_M1),
	.ARVALID_M1_i(ARVALID_M1),
	.ARREADY_M1_o(ARREADY_M1),
	.RID_M1_o(RID_M1),
	.RDATA_M1_o(RDATA_M1),
	.RRESP_M1_o(RRESP_M1),
	.RLAST_M1_o(RLAST_M1),
	.RVALID_M1_o(RVALID_M1),
	.RREADY_M1_i(RREADY_M1),

	.ARID_S0_o(ARID_S0),
	.ARADDR_S0_o(ARADDR_S0),
	.ARLEN_S0_o(ARLEN_S0),
	.ARSIZE_S0_o(ARSIZE_S0),
	.ARBURST_S0_o(ARBURST_S0),
	.ARVALID_S0_o(ARVALID_S0),
	.ARREADY_S0_i(ARREADY_S0),
	.RID_S0_i(RID_S0),
	.RDATA_S0_i(RDATA_S0),
	.RRESP_S0_i(RRESP_S0),
	.RLAST_S0_i(RLAST_S0),
	.RVALID_S0_i(RVALID_S0),
	.RREADY_S0_o(RREADY_S0),

	.AWID_S1_o(AWID_S1),
	.AWADDR_S1_o(AWADDR_S1),
	.AWLEN_S1_o(AWLEN_S1),
	.AWSIZE_S1_o(AWSIZE_S1),
	.AWBURST_S1_o(AWBURST_S1),
	.AWVALID_S1_o(AWVALID_S1),
	.AWREADY_S1_i(AWREADY_S1),
	.WDATA_S1_o(WDATA_S1),
	.WSTRB_S1_o(WSTRB_S1),
	.WLAST_S1_o(WLAST_S1),
	.WVALID_S1_o(WVALID_S1),
	.WREADY_S1_i(WREADY_S1),
	.BID_S1_i(BID_S1),
	.BRESP_S1_i(BRESP_S1),
	.BVALID_S1_i(BVALID_S1),
	.BREADY_S1_o(BREADY_S1),

	.ARID_S1_o(ARID_S1),
	.ARADDR_S1_o(ARADDR_S1),
	.ARLEN_S1_o(ARLEN_S1),
	.ARSIZE_S1_o(ARSIZE_S1),
	.ARBURST_S1_o(ARBURST_S1),
	.ARVALID_S1_o(ARVALID_S1),
	.ARREADY_S1_i(ARREADY_S1),
	.RID_S1_i(RID_S1),
	.RDATA_S1_i(RDATA_S1),
	.RRESP_S1_i(RRESP_S1),
	.RLAST_S1_i(RLAST_S1),
    .RVALID_S1_i(RVALID_S1),
	.RREADY_S1_o(RREADY_S1),

	.AWID_S2_o(AWID_S2),
	.AWADDR_S2_o(AWADDR_S2),
	.AWLEN_S2_o(AWLEN_S2),
	.AWSIZE_S2_o(AWSIZE_S2),
	.AWBURST_S2_o(AWBURST_S2),
	.AWVALID_S2_o(AWVALID_S2),
	.AWREADY_S2_i(AWREADY_S2),
	.WDATA_S2_o(WDATA_S2),
	.WSTRB_S2_o(WSTRB_S2),
	.WLAST_S2_o(WLAST_S2),
	.WVALID_S2_o(WVALID_S2),
	.WREADY_S2_i(WREADY_S2),
	.BID_S2_i(BID_S2),
	.BRESP_S2_i(BRESP_S2),
	.BVALID_S2_i(BVALID_S2),
	.BREADY_S2_o(BREADY_S2),

	.ARID_S2_o(ARID_S2),
	.ARADDR_S2_o(ARADDR_S2),
	.ARLEN_S2_o(ARLEN_S2),
	.ARSIZE_S2_o(ARSIZE_S2),
	.ARBURST_S2_o(ARBURST_S2),
	.ARVALID_S2_o(ARVALID_S2),
	.ARREADY_S2_i(ARREADY_S2),
	.RID_S2_i(RID_S2),
	.RDATA_S2_i(RDATA_S2),
	.RRESP_S2_i(RRESP_S2),
	.RLAST_S2_i(RLAST_S2),
	.RVALID_S2_i(RVALID_S2),
	.RREADY_S2_o(RREADY_S2),

	.AWID_S3_o(AWID_S3),
	.AWADDR_S3_o(AWADDR_S3),
	.AWLEN_S3_o(AWLEN_S3),
	.AWSIZE_S3_o(AWSIZE_S3),
	.AWBURST_S3_o(AWBURST_S3),
	.AWVALID_S3_o(AWVALID_S3),
	.AWREADY_S3_i(AWREADY_S3),
	.WDATA_S3_o(WDATA_S3),
	.WSTRB_S3_o(WSTRB_S3),
	.WLAST_S3_o(WLAST_S3),
	.WVALID_S3_o(WVALID_S3),
	.WREADY_S3_i(WREADY_S3),
	.BID_S3_i(BID_S3),
	.BRESP_S3_i(BRESP_S3),
	.BVALID_S3_i(BVALID_S3),
	.BREADY_S3_o(BREADY_S3),

	.ARID_S3_o(ARID_S3),
	.ARADDR_S3_o(ARADDR_S3),
	.ARLEN_S3_o(ARLEN_S3),
	.ARSIZE_S3_o(ARSIZE_S3),
	.ARBURST_S3_o(ARBURST_S3),
	.ARVALID_S3_o(ARVALID_S3),
	.ARREADY_S3_i(ARREADY_S3),
	.RID_S3_i(RID_S3),
	.RDATA_S3_i(RDATA_S3),
	.RRESP_S3_i(RRESP_S3),
	.RLAST_S3_i(RLAST_S3),
	.RVALID_S3_i(RVALID_S3),
	.RREADY_S3_o(RREADY_S3),

	.AWID_S4_o(AWID_S4),
	.AWADDR_S4_o(AWADDR_S4),
	.AWLEN_S4_o(AWLEN_S4),
	.AWSIZE_S4_o(AWSIZE_S4),
	.AWBURST_S4_o(AWBURST_S4),
	.AWVALID_S4_o(AWVALID_S4),
	.AWREADY_S4_i(AWREADY_S4),
	.WDATA_S4_o(WDATA_S4),
	.WSTRB_S4_o(WSTRB_S4),
	.WLAST_S4_o(WLAST_S4),
	.WVALID_S4_o(WVALID_S4),
	.WREADY_S4_i(WREADY_S4),
	.BID_S4_i(BID_S4),
	.BRESP_S4_i(BRESP_S4),
	.BVALID_S4_i(BVALID_S4),
	.BREADY_S4_o(BREADY_S4),

	.ARID_S4_o(ARID_S4),
	.ARADDR_S4_o(ARADDR_S4),
	.ARLEN_S4_o(ARLEN_S4),
	.ARSIZE_S4_o(ARSIZE_S4),
	.ARBURST_S4_o(ARBURST_S4),
	.ARVALID_S4_o(ARVALID_S4),
	.ARREADY_S4_i(ARREADY_S4),
	.RID_S4_i(RID_S4),
	.RDATA_S4_i(RDATA_S4),
	.RRESP_S4_i(RRESP_S4),
	.RLAST_S4_i(RLAST_S4),
	.RVALID_S4_i(RVALID_S4),
	.RREADY_S4_o(RREADY_S4),

	.AWID_S5_o(AWID_S5),
	.AWADDR_S5_o(AWADDR_S5),
	.AWLEN_S5_o(AWLEN_S5),
	.AWSIZE_S5_o(AWSIZE_S5),
	.AWBURST_S5_o(AWBURST_S5),
	.AWVALID_S5_o(AWVALID_S5),
	.AWREADY_S5_i(AWREADY_S5),
	.WDATA_S5_o(WDATA_S5),
	.WSTRB_S5_o(WSTRB_S5),
	.WLAST_S5_o(WLAST_S5),
	.WVALID_S5_o(WVALID_S5),
	.WREADY_S5_i(WREADY_S5),
	.BID_S5_i(BID_S5),
	.BRESP_S5_i(BRESP_S5),
	.BVALID_S5_i(BVALID_S5),
	.BREADY_S5_o(BREADY_S5),
 
	.ARID_S5_o(ARID_S5),
	.ARADDR_S5_o(ARADDR_S5),
	.ARLEN_S5_o(ARLEN_S5),
	.ARSIZE_S5_o(ARSIZE_S5),
	.ARBURST_S5_o(ARBURST_S5),
	.ARVALID_S5_o(ARVALID_S5),
	.ARREADY_S5_i(ARREADY_S5),
	.RID_S5_i(RID_S5),
	.RDATA_S5_i(RDATA_S5),
	.RRESP_S5_i(RRESP_S5),
	.RLAST_S5_i(RLAST_S5),
	.RVALID_S5_i(RVALID_S5),
	.RREADY_S5_o(RREADY_S5)
);

CPU_wrapper cpu(    
	.clk(cpu_clk),
    .rst(cpu_rst),
	.SENSOR_CTRL_interrupt(sensor_ctrl_interrupt),
	.WDT_interrupt(WDT_interrupt),

	.AWID_M1(AWID_M1), 
	.AWADDR_M1(AWADDR_M1),
	.AWLEN_M1(AWLEN_M1), 
	.AWSIZE_M1(AWSIZE_M1), 
	.AWBURST_M1(AWBURST_M1),
	.AWVALID_M1(AWVALID_M1),
	.AWREADY_M1(AWREADY_M1),
	.WDATA_M1(WDATA_M1), 
	.WSTRB_M1(WSTRB_M1), 
	.WLAST_M1(WLAST_M1), 
	.WVALID_M1(WVALID_M1),  
	.WREADY_M1(WREADY_M1),
	.BID_M1(BID_M1),
	.BRESP_M1(BRESP_M1),
	.BVALID_M1(BVALID_M1),
	.BREADY_M1(BREADY_M1),

	.ARID_M0(ARID_M0),
	.ARADDR_M0(ARADDR_M0),
	.ARLEN_M0(ARLEN_M0),
	.ARSIZE_M0(ARSIZE_M0),
	.ARBURST_M0(ARBURST_M0),
	.ARVALID_M0(ARVALID_M0),
	.ARREADY_M0(ARREADY_M0),
	.RID_M0(RID_M0),
	.RDATA_M0(RDATA_M0),
	.RRESP_M0(RRESP_M0),
	.RLAST_M0(RLAST_M0),
	.RVALID_M0(RVALID_M0),
	.RREADY_M0(RREADY_M0),

	.ARID_M1(ARID_M1),
	.ARADDR_M1(ARADDR_M1), 
	.ARLEN_M1(ARLEN_M1),
	.ARSIZE_M1(ARSIZE_M1), 
	.ARBURST_M1(ARBURST_M1),
	.ARVALID_M1(ARVALID_M1), 
	.ARREADY_M1(ARREADY_M1),
	.RID_M1(RID_M1),
	.RDATA_M1(RDATA_M1),
	.RRESP_M1(RRESP_M1),
	.RLAST_M1(RLAST_M1),
	.RVALID_M1(RVALID_M1),
	.RREADY_M1(RREADY_M1) 
);

//---------- S0: ROM ----------//
ROM_wrapper ROM_wrapper(
    .clk(rom_clk),
    .rst(rom_rst),
    // posedge
    .ARID(ARID_S0),
    .ARADDR(ARADDR_S0),
    .ARLEN(ARLEN_S0),
    .ARSIZE(ARSIZE_S0),
    .ARBURST(ARBURST_S0),
    .ARVALID(ARVALID_S0),
    .ARREADY(ARREADY_S0),

    .RREADY(RREADY_S0),
    .RID(RID_S0),
    .RDATA(RDATA_S0),
    .RRESP(RRESP_S0),
    .RLAST(RLAST_S0),
    .RVALID(RVALID_S0),

    .ROM_out(ROM_out),
    .ROM_enable(ROM_enable),
    .ROM_read(ROM_read),
    .ROM_address(ROM_address)
);

//---------- S1: IM ----------//
SRAM_wrapper IM1(
	.CK(sram_clk),
	.rst(sram_rst),

	.AWID(AWID_S1),
	.AWADDR(AWADDR_S1),
	.AWLEN(AWLEN_S1),
	.AWSIZE(AWSIZE_S1),
	.AWBURST(AWBURST_S1),
	.AWVALID(AWVALID_S1),
	.AWREADY(AWREADY_S1), 

	.WDATA(WDATA_S1),
	.WSTRB(WSTRB_S1),
	.WLAST(WLAST_S1),
	.WVALID(WVALID_S1),
	.WREADY(WREADY_S1),

	.BID(BID_S1),
	.BRESP(BRESP_S1), 
	.BVALID(BVALID_S1), 
	.BREADY(BREADY_S1),

	.ARID(ARID_S1),
	.ARADDR(ARADDR_S1),
	.ARLEN(ARLEN_S1),
	.ARSIZE(ARSIZE_S1),
	.ARBURST(ARBURST_S1),
	.ARVALID(ARVALID_S1),
	.ARREADY(ARREADY_S1), 

	.RID(RID_S1), 
	.RDATA(RDATA_S1),
	.RRESP(RRESP_S1),
	.RLAST(RLAST_S1),
	.RVALID(RVALID_S1), 
	.RREADY(RREADY_S1)
);

//---------- S2: DM ----------//
SRAM_wrapper DM1(
	.CK(sram_clk),
	.rst(sram_rst),

	.AWID(AWID_S2),
	.AWADDR(AWADDR_S2),
	.AWLEN(AWLEN_S2),
	.AWSIZE(AWSIZE_S2),
	.AWBURST(AWBURST_S2),
	.AWVALID(AWVALID_S2),
	.AWREADY(AWREADY_S2),

	.WDATA(WDATA_S2),
	.WSTRB(WSTRB_S2),
	.WLAST(WLAST_S2),
	.WVALID(WVALID_S2),
	.WREADY(WREADY_S2),

	.BID(BID_S2),
	.BRESP(BRESP_S2),
	.BVALID(BVALID_S2),
	.BREADY(BREADY_S2),

	.ARID(ARID_S2),
	.ARADDR(ARADDR_S2),
	.ARLEN(ARLEN_S2),
	.ARSIZE(ARSIZE_S2),
	.ARBURST(ARBURST_S2),
	.ARVALID(ARVALID_S2),
	.ARREADY(ARREADY_S2),
	
	.RID(RID_S2),
	.RDATA(RDATA_S2),
	.RRESP(RRESP_S2), 
	.RLAST(RLAST_S2),
	.RVALID(RVALID_S2),
	.RREADY(RREADY_S2)
);

//----------S3: sensor ----------//
SCtrl_wrapper SCtrl_wrapper(
    .clk(cpu_clk),
    .rst(cpu_rst),
    // posedge
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    .sensor_en(sensor_en),
    .sensor_ctrl_interrupt(sensor_ctrl_interrupt),

    .ARID(ARID_S3),
    .ARADDR(ARADDR_S3),
    .ARLEN(ARLEN_S3),
    .ARSIZE(ARSIZE_S3),
    .ARBURST(ARBURST_S3),
    .ARVALID(ARVALID_S3),
    .ARREADY(ARREADY_S3),

    .RREADY(RREADY_S3),
    .RID(RID_S3),
    .RDATA(RDATA_S3),
    .RRESP(RRESP_S3),
    .RLAST(RLAST_S3),
    .RVALID(RVALID_S3),

    .AWID(AWID_S3),
    .AWADDR(AWADDR_S3),
    .AWLEN(AWLEN_S3),
    .AWSIZE(AWSIZE_S3),
    .AWBURST(AWBURST_S3),
    .AWVALID(AWVALID_S3),
    .AWREADY(AWREADY_S3),

    .WDATA(WDATA_S3),
    .WSTRB(WSTRB_S3),
    .WLAST(WLAST_S3),
    .WVALID(WVALID_S3),
    .WREADY(WREADY_S3),

    .BREADY(BREADY_S3),
    .BID(BID_S3),
    .BRESP(BRESP_S3),
    .BVALID(BVALID_S3)
);

//---------- S4: WDT ----------//
WDT_wrapper WDT_wrapper(
    .clk(cpu_clk),
    .rst(cpu_rst),
    .clk2(cpu_clk),
    .rst2(cpu_rst),
    //posedge
    .WDT_interrupt(WDT_interrupt),

    .ARID(ARID_S4),
    .ARADDR(ARADDR_S4),
    .ARLEN(ARLEN_S4),
    .ARSIZE(ARSIZE_S4),
    .ARBURST(ARBURST_S4),
    .ARVALID(ARVALID_S4),
    .ARREADY(ARREADY_S4),

    .RREADY(RREADY_S4),
    .RID(RID_S4),
    .RDATA(RDATA_S4),
    .RRESP(RRESP_S4),
    .RLAST(RLAST_S4),
    .RVALID(RVALID_S4),

    .AWID(AWID_S4),
    .AWADDR(AWADDR_S4),
    .AWLEN(AWLEN_S4),
    .AWSIZE(AWSIZE_S4),
    .AWBURST(AWBURST_S4),
    .AWVALID(AWVALID_S4),
    .AWREADY(AWREADY_S4),

    .WDATA(WDATA_S4),
    .WSTRB(WSTRB_S4),
    .WLAST(WLAST_S4),
    .WVALID(WVALID_S4),
    .WREADY(WREADY_S4),

    .BREADY(BREADY_S4),
    .BID(BID_S4),
    .BRESP(BRESP_S4),
    .BVALID(BVALID_S4)
);

//---------- S5: DRAM ----------//
DRAM_wrapper DRAM_wrapper(
    .clk(dram_clk),
    .rst(dram_rst),
    // posedge

    .ARID(ARID_S5),
    .ARADDR(ARADDR_S5),
    .ARLEN(ARLEN_S5),
    .ARSIZE(ARSIZE_S5),
    .ARBURST(ARBURST_S5),
    .ARVALID(ARVALID_S5),
    .ARREADY(ARREADY_S5),

    .RREADY(RREADY_S5),
    .RID(RID_S5),
    .RDATA(RDATA_S5),
    .RRESP(RRESP_S5),
    .RLAST(RLAST_S5),
    .RVALID(RVALID_S5),

    .AWID(AWID_S5),
    .AWADDR(AWADDR_S5),
    .AWLEN(AWLEN_S5),
    .AWSIZE(AWSIZE_S5),
    .AWBURST(AWBURST_S5),
    .AWVALID(AWVALID_S5),
    .AWREADY(AWREADY_S5),

    .WDATA(WDATA_S5),
    .WSTRB(WSTRB_S5),
    .WLAST(WLAST_S5),
    .WVALID(WVALID_S5),
    .WREADY(WREADY_S5),

    .BREADY(BREADY_S5),
    .BID(BID_S5),
    .BRESP(BRESP_S5),
    .BVALID(BVALID_S5),
 
    .DRAM_Q(DRAM_Q),
    .DRAM_valid(DRAM_valid),
    .DRAM_CSn(DRAM_CSn),
    .DRAM_WEn(DRAM_WEn),
    .DRAM_RASn(DRAM_RASn),
    .DRAM_CASn(DRAM_CASn),
    .DRAM_A(DRAM_A),
    .DRAM_D(DRAM_D)
);


endmodule


