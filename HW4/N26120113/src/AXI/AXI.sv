//================================================
// Auther:      Chang Wan-Yun (Claire)
// Filename:    AXI.sv
// Description: Top module of AXI
// Version:     1.0 
//================================================
`include "../include/AXI_define.svh"
`include "./AXI/write_arbiter.sv"
`include "./AXI/write_addr.sv"
`include "./AXI/write_data.sv"
`include "./AXI/write_resp.sv"
`include "./AXI/read_arbiter.sv"
`include "./AXI/read_addr.sv"
`include "./AXI/read_data.sv"
`include "./AXI/fifo_6.sv"
`include "./AXI/fifo_10.sv"
`include "./AXI/fifo37_m.sv"
`include "./AXI/fifo37_s.sv"
`include "./AXI/fifo_43.sv"
`include "./AXI/fifo_39.sv"
`include "./AXI/fifo_49.sv"
`include "./AXI/fifo_45.sv"
`include "./AXI/DFF.sv"

module AXI(
	input logic                       CPU_CLK_i,      
	input logic                       AXI_CLK_i,        
	input logic                       ROM_CLK_i,      
	input logic                       DRAM_CLK_i,
	input logic                       SRAM_CLK_i,
	input logic                       CPU_RST_i,      
	input logic                       AXI_RST_i,        
	input logic                       ROM_RST_i,      
	input logic                       DRAM_RST_i,
	input logic                       SRAM_RST_i,                  
	//MASTER INTERFACE
	// M0
	// READ
	input  logic [`AXI_ID_BITS-1:0]   ARID_M0_i,
	input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M0_i,
	input  logic [`AXI_LEN_BITS-1:0]  ARLEN_M0_i,
	input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0_i,
	input  logic [1:0]                ARBURST_M0_i,
	input  logic                      ARVALID_M0_i,
	output logic                      ARREADY_M0_o,
	output logic [`AXI_ID_BITS-1:0]   RID_M0_o,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0_o,
	output logic [1:0]                RRESP_M0_o,
	output logic                      RLAST_M0_o,
	output logic                      RVALID_M0_o,
	input  logic                      RREADY_M0_i,
	// M1
	// WRITE
	input  logic[`AXI_ID_BITS-1:0]    AWID_M1_i,
	input  logic[`AXI_ADDR_BITS-1:0]  AWADDR_M1_i,
	input  logic[`AXI_LEN_BITS-1:0]   AWLEN_M1_i,
	input  logic[`AXI_SIZE_BITS-1:0]  AWSIZE_M1_i,
	input  logic[1:0]                 AWBURST_M1_i,
	input  logic                      AWVALID_M1_i,
	output logic                      AWREADY_M1_o,
	input  logic [`AXI_DATA_BITS-1:0] WDATA_M1_i,
	input  logic [`AXI_STRB_BITS-1:0] WSTRB_M1_i,
	input  logic                      WLAST_M1_i,
	input  logic                      WVALID_M1_i,
	output logic                      WREADY_M1_o,
	output logic [`AXI_ID_BITS-1:0]   BID_M1_o,
	output logic [1:0]                BRESP_M1_o,
	output logic                      BVALID_M1_o,
	input  logic                      BREADY_M1_i,
	// READ
	input  logic [`AXI_ID_BITS-1:0]   ARID_M1_i,
	input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M1_i,
	input  logic [`AXI_LEN_BITS-1:0]  ARLEN_M1_i,
	input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1_i,
	input  logic [1:0]                ARBURST_M1_i,
	input  logic                      ARVALID_M1_i,
	output logic                      ARREADY_M1_o,
	output logic [`AXI_ID_BITS-1:0]   RID_M1_o,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1_o,
	output logic [1:0]                RRESP_M1_o,
	output logic                      RLAST_M1_o,
	output logic                      RVALID_M1_o,
	input  logic                      RREADY_M1_i,
	//SLAVE INTERFACE
	// S0
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S0_o,
	output logic[`AXI_ADDR_BITS-1:0]  ARADDR_S0_o,
	output logic[`AXI_LEN_BITS-1:0]   ARLEN_S0_o,
	output logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S0_o,
	output logic[1:0]                 ARBURST_S0_o,
	output logic                      ARVALID_S0_o,
	input  logic                      ARREADY_S0_i,
	input  logic[`AXI_IDS_BITS-1:0]   RID_S0_i,
	input  logic[`AXI_DATA_BITS-1:0]  RDATA_S0_i,
	input  logic[1:0]                 RRESP_S0_i,
	input  logic                      RLAST_S0_i,
	input  logic                      RVALID_S0_i,
	output logic                      RREADY_S0_o,
	// S1
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S1_o,
	output logic[`AXI_ADDR_BITS-1:0]  AWADDR_S1_o,
	output logic[`AXI_LEN_BITS-1:0]   AWLEN_S1_o,
	output logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S1_o,
	output logic[1:0]                 AWBURST_S1_o,
	output logic                      AWVALID_S1_o,
	input  logic                      AWREADY_S1_i,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1_o,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1_o,
	output logic                      WLAST_S1_o,
	output logic                      WVALID_S1_o,
	input  logic                      WREADY_S1_i,
	input  logic[`AXI_IDS_BITS-1:0]   BID_S1_i,
	input  logic[1:0]                 BRESP_S1_i,
	input  logic                      BVALID_S1_i,
	output logic                      BREADY_S1_o,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S1_o,
	output logic[`AXI_ADDR_BITS-1:0]  ARADDR_S1_o,
	output logic[`AXI_LEN_BITS-1:0]   ARLEN_S1_o,
	output logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S1_o,
	output logic[1:0]                 ARBURST_S1_o,
	output logic                      ARVALID_S1_o,
	input  logic                      ARREADY_S1_i,
	input  logic[`AXI_IDS_BITS-1:0]   RID_S1_i,
	input  logic[`AXI_DATA_BITS-1:0]  RDATA_S1_i,
	input  logic[1:0]                 RRESP_S1_i,
	input  logic                      RLAST_S1_i,
	input  logic                      RVALID_S1_i,
	output logic                      RREADY_S1_o,
	// S2
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S2_o,
	output logic[`AXI_ADDR_BITS-1:0]  AWADDR_S2_o,
	output logic[`AXI_LEN_BITS-1:0]   AWLEN_S2_o,
	output logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S2_o,
	output logic[1:0]                 AWBURST_S2_o,
	output logic                      AWVALID_S2_o,
	input  logic                      AWREADY_S2_i,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2_o,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2_o,
	output logic                      WLAST_S2_o,
	output logic                      WVALID_S2_o,
	input  logic                      WREADY_S2_i,
	input  logic [`AXI_IDS_BITS-1:0]  BID_S2_i,
	input  logic [1:0]                BRESP_S2_i,
	input  logic                      BVALID_S2_i,
	output logic                      BREADY_S2_o,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S2_o,
	output logic[`AXI_ADDR_BITS-1:0]  ARADDR_S2_o,
	output logic[`AXI_LEN_BITS-1:0]   ARLEN_S2_o,
	output logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S2_o,
	output logic [1:0]                ARBURST_S2_o,
	output logic                      ARVALID_S2_o,
	input  logic                      ARREADY_S2_i,
	input  logic[`AXI_IDS_BITS-1:0]   RID_S2_i,
	input  logic[`AXI_DATA_BITS-1:0]  RDATA_S2_i,
	input  logic[1:0]                 RRESP_S2_i,
	input  logic                      RLAST_S2_i,
	input  logic                      RVALID_S2_i,
	output logic                      RREADY_S2_o,
	// S3
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S3_o,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3_o,
	output logic [`AXI_LEN_BITS-1:0]  AWLEN_S3_o,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3_o,
	output logic [1:0]                AWBURST_S3_o,
	output logic                      AWVALID_S3_o,
	input  logic                      AWREADY_S3_i,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S3_o,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3_o,
	output logic                      WLAST_S3_o,
	output logic                      WVALID_S3_o,
	input  logic                      WREADY_S3_i,
	input  logic [`AXI_IDS_BITS-1:0]  BID_S3_i,
	input  logic [1:0]                BRESP_S3_i,
	input  logic                      BVALID_S3_i,
	output logic                      BREADY_S3_o,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S3_o,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3_o,
	output logic [`AXI_LEN_BITS-1:0]  ARLEN_S3_o,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3_o,
	output logic [1:0]                ARBURST_S3_o,
	output logic                      ARVALID_S3_o,
	input  logic                      ARREADY_S3_i,
	input  logic [`AXI_IDS_BITS-1:0]  RID_S3_i,
	input  logic [`AXI_DATA_BITS-1:0] RDATA_S3_i,
	input  logic [1:0]                RRESP_S3_i,
	input  logic                      RLAST_S3_i,
	input  logic                      RVALID_S3_i,
	output logic                      RREADY_S3_o,
	// S4
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S4_o,
	output logic[`AXI_ADDR_BITS-1:0]  AWADDR_S4_o,
	output logic[`AXI_LEN_BITS-1:0]   AWLEN_S4_o,
	output logic[`AXI_SIZE_BITS-1:0]  AWSIZE_S4_o,
	output logic[1:0]                 AWBURST_S4_o,
	output logic                      AWVALID_S4_o,
	input  logic                      AWREADY_S4_i,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4_o,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4_o,
	output logic                      WLAST_S4_o,
	output logic                      WVALID_S4_o,
	input  logic                      WREADY_S4_i,
	input  logic[`AXI_IDS_BITS-1:0]   BID_S4_i,
	input  logic[1:0]                 BRESP_S4_i,
	input  logic                      BVALID_S4_i,
	output logic                      BREADY_S4_o,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S4_o,
	output logic[`AXI_ADDR_BITS-1:0]  ARADDR_S4_o,
	output logic[`AXI_LEN_BITS-1:0]   ARLEN_S4_o,
	output logic[`AXI_SIZE_BITS-1:0]  ARSIZE_S4_o,
	output logic[1:0]                 ARBURST_S4_o,
	output logic                      ARVALID_S4_o,
	input  logic                      ARREADY_S4_i,
	input  logic[`AXI_IDS_BITS-1:0]   RID_S4_i,
	input  logic[`AXI_DATA_BITS-1:0]  RDATA_S4_i,
	input  logic[1:0]                 RRESP_S4_i,
	input  logic                      RLAST_S4_i,
	input  logic                      RVALID_S4_i,
	output logic                      RREADY_S4_o,
	// S5
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S5_o,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5_o,
	output logic [`AXI_LEN_BITS-1:0]  AWLEN_S5_o,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5_o,
	output logic [1:0]                AWBURST_S5_o,
	output logic                      AWVALID_S5_o,
	input  logic                      AWREADY_S5_i,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S5_o,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5_o,
	output logic                      WLAST_S5_o,
	output logic                      WVALID_S5_o,
	input  logic                      WREADY_S5_i,
	input  logic [`AXI_IDS_BITS-1:0]  BID_S5_i,
	input logic [1:0]                 BRESP_S5_i,
	input logic                       BVALID_S5_i,
	output logic                      BREADY_S5_o,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S5_o,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5_o,
	output logic [`AXI_LEN_BITS-1:0]  ARLEN_S5_o,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5_o,
	output logic [1:0]                ARBURST_S5_o,
	output logic                      ARVALID_S5_o,
	input  logic                      ARREADY_S5_i,
	input  logic [`AXI_IDS_BITS-1:0]  RID_S5_i,
	input  logic [`AXI_DATA_BITS-1:0] RDATA_S5_i,
	input  logic [1:0]                RRESP_S5_i,
	input  logic                      RLAST_S5_i,
	input  logic                      RVALID_S5_i,
	output logic                      RREADY_S5_o
);
	

// ROM (S0)     0x0000_0000 ~ 0x0000_1FFF
// IM (S1)      0x0001_0000 ~ 0x0001_FFFF
// DM (S2)      0x0002_0000 ~ 0x0002_FFFF
// Sctrl (S3)   0x1000_0000 ~ 0x1000_03FF
// WDT (S4)     0x1001_0000 ~ 0x1001_03FF
// DRAM (S5)    0x2000_0000 ~ 0x201F_FFFF

logic [`AXI_ID_BITS-1:0] ARID_M0;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M0;
logic [`AXI_LEN_BITS-1:0] ARLEN_M0;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0;
logic [1:0] ARBURST_M0;
logic ARVALID_M0;
logic ARREADY_M0;
logic [`AXI_ID_BITS-1:0]   	RID_M0;
logic [`AXI_DATA_BITS-1:0] 	RDATA_M0;
logic [1:0] RRESP_M0;
logic RLAST_M0;
logic RVALID_M0;
logic RREADY_M0;

// M1 (memory)
logic [`AXI_ID_BITS-1:0] AWID_M1;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M1;
logic [`AXI_LEN_BITS-1:0] AWLEN_M1;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1;
logic [1:0] AWBURST_M1;
logic AWVALID_M1;
logic AWREADY_M1;
logic [`AXI_DATA_BITS-1:0] WDATA_M1;
logic [`AXI_STRB_BITS-1:0] WSTRB_M1;
logic WLAST_M1;
logic WVALID_M1;
logic WREADY_M1;
logic [`AXI_ID_BITS-1:0] BID_M1;
logic [1:0] BRESP_M1;
logic BVALID_M1;
logic BREADY_M1;

logic [`AXI_ID_BITS-1:0] ARID_M1;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M1;
logic [`AXI_LEN_BITS-1:0] ARLEN_M1;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1;
logic [1:0] ARBURST_M1;
logic ARVALID_M1;
logic ARREADY_M1;
logic [`AXI_ID_BITS-1:0] RID_M1;
logic [`AXI_DATA_BITS-1:0] RDATA_M1;
logic [1:0] RRESP_M1;
logic RLAST_M1;
logic RVALID_M1;
logic RREADY_M1;

// S0(ROM) only read
logic [`AXI_IDS_BITS-1:0] ARID_S0;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S0;
logic [`AXI_LEN_BITS-1:0] ARLEN_S0;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0;
logic [1:0] ARBURST_S0;
logic ARVALID_S0;
logic ARREADY_S0;
logic [`AXI_IDS_BITS-1:0] RID_S0;
logic [`AXI_DATA_BITS-1:0] RDATA_S0;
logic [1:0] RRESP_S0;
logic RLAST_S0;
logic RVALID_S0;
logic RREADY_S0;

// S1(IM)
logic [`AXI_IDS_BITS-1:0] AWID_S1;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S1;
logic [`AXI_LEN_BITS-1:0] AWLEN_S1;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1;
logic [1:0] AWBURST_S1;
logic AWVALID_S1;
logic AWREADY_S1;
logic [`AXI_DATA_BITS-1:0] 	WDATA_S1;
logic [`AXI_STRB_BITS-1:0] 	WSTRB_S1;
logic WLAST_S1;
logic WVALID_S1;
logic WREADY_S1;
logic [`AXI_IDS_BITS-1:0] BID_S1;
logic [1:0] BRESP_S1;
logic BVALID_S1;
logic BREADY_S1;

logic [`AXI_IDS_BITS-1:0] ARID_S1;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S1;
logic [`AXI_LEN_BITS-1:0] ARLEN_S1;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1;
logic [1:0] ARBURST_S1;
logic ARVALID_S1;
logic ARREADY_S1;
logic [`AXI_IDS_BITS-1:0] RID_S1;
logic [`AXI_DATA_BITS-1:0] RDATA_S1;
logic [1:0] RRESP_S1;
logic RLAST_S1;
logic RVALID_S1;
logic RREADY_S1;

// S2(DM)
logic [`AXI_IDS_BITS-1:0]  AWID_S2;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S2;
logic [`AXI_LEN_BITS-1:0] AWLEN_S2;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2;
logic [1:0] AWBURST_S2;
logic AWVALID_S2;
logic AWREADY_S2;
logic [`AXI_DATA_BITS-1:0] WDATA_S2;
logic [`AXI_STRB_BITS-1:0] WSTRB_S2;
logic WLAST_S2;
logic WVALID_S2;
logic WREADY_S2;
logic [`AXI_IDS_BITS-1:0] BID_S2;
logic [1:0] BRESP_S2;
logic BVALID_S2;
logic BREADY_S2;

logic [`AXI_IDS_BITS-1:0]  ARID_S2;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S2;
logic [`AXI_LEN_BITS-1:0] ARLEN_S2;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2;
logic [1:0] ARBURST_S2;
logic ARVALID_S2;
logic ARREADY_S2;
logic [`AXI_IDS_BITS-1:0] RID_S2;
logic [`AXI_DATA_BITS-1:0] RDATA_S2;
logic [1:0] RRESP_S2;
logic RLAST_S2;
logic RVALID_S2;
logic RREADY_S2;

// S3(sensor_ctrl)
logic [`AXI_IDS_BITS-1:0]  AWID_S3;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S3;
logic [`AXI_LEN_BITS-1:0] AWLEN_S3;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3;
logic [1:0] AWBURST_S3;
logic AWVALID_S3;
logic AWREADY_S3;
logic [`AXI_DATA_BITS-1:0] WDATA_S3;
logic [`AXI_STRB_BITS-1:0] WSTRB_S3;
logic WLAST_S3;
logic WVALID_S3;
logic WREADY_S3;
logic [`AXI_IDS_BITS-1:0] BID_S3;
logic [1:0] BRESP_S3;
logic BVALID_S3;
logic BREADY_S3;

logic [`AXI_IDS_BITS-1:0]  ARID_S3;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S3;
logic [`AXI_LEN_BITS-1:0] ARLEN_S3;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3;
logic [1:0] ARBURST_S3;
logic ARVALID_S3;
logic ARREADY_S3;
logic [`AXI_IDS_BITS-1:0] RID_S3;
logic [`AXI_DATA_BITS-1:0] RDATA_S3;
logic [1:0] RRESP_S3;
logic RLAST_S3;
logic RVALID_S3;
logic RREADY_S3;

// S4(WDT)
logic [`AXI_IDS_BITS-1:0] AWID_S4;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S4;
logic [`AXI_LEN_BITS-1:0] AWLEN_S4;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4;
logic [1:0] AWBURST_S4;
logic AWVALID_S4;
logic AWREADY_S4;
logic [`AXI_DATA_BITS-1:0] WDATA_S4;
logic [`AXI_STRB_BITS-1:0] WSTRB_S4;
logic WLAST_S4;
logic WVALID_S4;
logic WREADY_S4;
logic [`AXI_IDS_BITS-1:0] BID_S4;
logic [1:0] BRESP_S4;
logic BVALID_S4;
logic BREADY_S4;

logic [`AXI_IDS_BITS-1:0]  ARID_S4;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S4;
logic [`AXI_LEN_BITS-1:0] ARLEN_S4;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4;
logic [1:0] ARBURST_S4;
logic ARVALID_S4;
logic ARREADY_S4;
logic [`AXI_IDS_BITS-1:0] RID_S4;
logic [`AXI_DATA_BITS-1:0] RDATA_S4;
logic [1:0] RRESP_S4;
logic RLAST_S4;
logic RVALID_S4;
logic RREADY_S4;

// S5(DRAM)
logic [`AXI_IDS_BITS-1:0] AWID_S5;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S5;
logic [`AXI_LEN_BITS-1:0] AWLEN_S5;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5;
logic [1:0] AWBURST_S5;
logic AWVALID_S5;
logic AWREADY_S5;
logic [`AXI_DATA_BITS-1:0] WDATA_S5;
logic [`AXI_STRB_BITS-1:0] WSTRB_S5;
logic WLAST_S5;
logic WVALID_S5;
logic WREADY_S5;
logic [`AXI_IDS_BITS-1:0] BID_S5;
logic [1:0] BRESP_S5;
logic BVALID_S5;
logic BREADY_S5;

logic [`AXI_IDS_BITS-1:0] ARID_S5;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S5;
logic [`AXI_LEN_BITS-1:0] ARLEN_S5;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5;
logic [1:0] ARBURST_S5;
logic ARVALID_S5;
logic ARREADY_S5;
logic [`AXI_IDS_BITS-1:0] RID_S5;
logic [`AXI_DATA_BITS-1:0] RDATA_S5;
logic [1:0] RRESP_S5;
logic RLAST_S5;
logic RVALID_S5;
logic RREADY_S5;

logic [44:0] AR_fifo_m0_i, AR_fifo_m0_o, AR_fifo_mi, AR_fifo_mo;
logic [44:0] AW_fifo_m1_i, AR_fifo_m1_i, AW_fifo_m1_o, AR_fifo_m1_o;
logic [48:0] AR_fifo_si, AR_fifo_so, AW_fifo_si, AW_fifo_so;
logic [48:0] AR_fifo_s0_i, AR_fifo_s0_o;
logic [48:0] AW_fifo_s1_i, AR_fifo_s1_i, AW_fifo_s1_o, AR_fifo_s1_o;
logic [48:0] AW_fifo_s2_i, AR_fifo_s2_i, AW_fifo_s2_o, AR_fifo_s2_o;
logic [48:0] AW_fifo_s3_i, AR_fifo_s3_i, AW_fifo_s3_o, AR_fifo_s3_o;
logic [48:0] AW_fifo_s4_i, AR_fifo_s4_i, AW_fifo_s4_o, AR_fifo_s4_o;
logic [48:0] AW_fifo_s5_i, AR_fifo_s5_i, AW_fifo_s5_o, AR_fifo_s5_o;

logic [38:0] R_fifo_mi, R_fifo_mo;
logic [38:0] R_fifo_m0_i, R_fifo_m0_o;
logic [38:0] R_fifo_m1_i, R_fifo_m1_o;
logic [42:0] R_fifo_si, R_fifo_so;
logic [42:0] R_fifo_s0_i, R_fifo_s0_o;
logic [42:0] R_fifo_s1_i, R_fifo_s1_o;
logic [42:0] R_fifo_s2_i, R_fifo_s2_o;
logic [42:0] R_fifo_s3_i, R_fifo_s3_o;
logic [42:0] R_fifo_s4_i, R_fifo_s4_o;
logic [42:0] R_fifo_s5_i, R_fifo_s5_o;

logic [36:0] W_fifo_m1_i, W_fifo_m1_o;
logic [36:0] W_fifo_si, W_fifo_so;
logic [36:0] W_fifo_s1_i, W_fifo_s1_o;
logic [36:0] W_fifo_s2_i, W_fifo_s2_o;
logic [36:0] W_fifo_s3_i, W_fifo_s3_o;
logic [36:0] W_fifo_s4_i, W_fifo_s4_o;
logic [36:0] W_fifo_s5_i, W_fifo_s5_o;

logic [5:0] B_fifo_m1_i, B_fifo_m1_o;
logic [9:0] B_fifo_si, B_fifo_so;
logic [9:0] B_fifo_s1_i, B_fifo_s1_o;
logic [9:0] B_fifo_s2_i, B_fifo_s2_o;
logic [9:0] B_fifo_s3_i, B_fifo_s3_o;
logic [9:0] B_fifo_s4_i, B_fifo_s4_o;
logic [9:0] B_fifo_s5_i, B_fifo_s5_o;
logic [3:0] AW_arbiter, AR_arbiter;
logic [1:0] cs;
logic cs_w;

write_arbiter write_arbiter(   
	.ACLK(AXI_CLK_i),
	.ARESETn(AXI_RST_i),

	.AWADDR_M1(AWADDR_M1),
	.AWVALID_M1(AWVALID_M1),
	.WVALID_M1(WVALID_M1),
	.BVALID_M1(BVALID_M1),
	.BREADY_M1(BREADY_M1),

	.AW_arbiter(AW_arbiter),
	.cs_w(cs_w)
);

read_arbiter read_arbiter(
	.ACLK(AXI_CLK_i),
	.ARESETn(AXI_RST_i),

	.ARADDR_M0(ARADDR_M0),
	.ARREADY_M0(ARREADY_M0),
	.ARVALID_M0(ARVALID_M0),
	.RVALID_M0(RVALID_M0),
	.RREADY_M0(RREADY_M0),
	.ARLEN_M0(ARLEN_M0),

	.ARADDR_M1(ARADDR_M1),
	.ARREADY_M1(ARREADY_M1),
	.ARVALID_M1(ARVALID_M1),
	.RVALID_M1(RVALID_M1),
	.RREADY_M1(RREADY_M1),
	.ARLEN_M1(ARLEN_M1),

	.RLAST_M0(RLAST_M0),
	.RLAST_M1(RLAST_M1),

	.AR_arbiter(AR_arbiter),
	.cs(cs)
);

//------------------------------------master----------------------------//
//---------------AW----------------//
logic wfull_AW_m, rempty_AW_m, winc_AW, rinc_AW;

assign AW_fifo_m1_i = {AWID_M1_i, AWADDR_M1_i, AWLEN_M1_i, AWSIZE_M1_i, AWBURST_M1_i};
assign AWID_M1 = AW_fifo_m1_o[44:41];
assign AWADDR_M1 = AW_fifo_m1_o[40:9];
assign AWLEN_M1 = AW_fifo_m1_o[8:5];
assign AWSIZE_M1 = AW_fifo_m1_o[4:2];
assign AWBURST_M1 = AW_fifo_m1_o[1:0];
assign winc_AW = (AWVALID_M1_i & (~wfull_AW_m)) ? 1'd1 : 1'd0;
assign rinc_AW = (~rempty_AW_m & AWREADY_M1) ? 1'd1 : 1'd0;
assign AWVALID_M1 = (~rempty_AW_m) ? 1'd1 : 1'd0;
assign AWREADY_M1_o = (~wfull_AW_m) ? 1'd1 : 1'd0;

fifo_45 fifo_45_AW(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(AW_fifo_m1_i),
    .winc(winc_AW), 
    .wclk(CPU_CLK_i), 
    .wrst(CPU_RST_i),
    .rinc(rinc_AW), 
    .rdata(AW_fifo_m1_o),
    .wfull(wfull_AW_m),
    .rempty(rempty_AW_m)
);

//---------------W----------------//
logic wfull_W_m, rempty_W_m, winc_W, rinc_W;

assign W_fifo_m1_i = {WDATA_M1_i, WSTRB_M1_i, WLAST_M1_i};
assign WDATA_M1 = W_fifo_m1_o[36:5];
assign WSTRB_M1 = W_fifo_m1_o[4:1];
assign WLAST_M1 = W_fifo_m1_o[0];
assign winc_W = (WVALID_M1_i & (~wfull_W_m)) ? 1'd1 : 1'd0;
assign rinc_W = (~rempty_W_m & WREADY_M1) ? 1'd1 : 1'd0;
assign WVALID_M1 = (~rempty_W_m & WREADY_M1) ? 1'd1 : 1'd0;
assign WREADY_M1_o = (~wfull_W_m) ? 1'd1 : 1'd0;

fifo37_m fifo_37_W_m(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(W_fifo_m1_i),
    .winc(winc_W), 
    .wclk(CPU_CLK_i), 
    .wrst(CPU_RST_i),
    .rinc(rinc_W), 
    .rdata(W_fifo_m1_o),
    .wfull(wfull_W_m),
    .rempty(rempty_W_m)
);

//---------------B----------------//
logic wfull_B_m, rempty_B_m, winc_B, rinc_B;

assign B_fifo_m1_i = {BID_M1, BRESP_M1};
assign BID_M1_o = B_fifo_m1_o[5:2];
assign BRESP_M1_o = B_fifo_m1_o[1:0];
assign winc_B = (BVALID_M1 & (~wfull_B_m)) ? 1'd1 : 1'd0;
assign rinc_B = (BREADY_M1_i & ~rempty_B_m) ? 1'd1 : 1'd0;
assign BVALID_M1_o = (BREADY_M1_i & ~rempty_B_m) ? 1'd1 : 1'd0;
assign BREADY_M1 = (~wfull_B_m) ? 1'd1 : 1'd0;

fifo_6 fifo_6_B(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(B_fifo_m1_i),
    .winc(winc_B), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_B), 
    .rdata(B_fifo_m1_o),
    .wfull(wfull_B_m),
    .rempty(rempty_B_m)
);

//---------------AR----------------//
logic wfull_AR_m0, rempty_AR_m0, winc_AR_m0, rinc_AR_m0;
assign AR_fifo_m0_i = {ARID_M0_i, ARADDR_M0_i, ARLEN_M0_i, ARSIZE_M0_i, ARBURST_M0_i};
assign ARID_M0 = AR_fifo_m0_o[44:41];
assign ARADDR_M0 = AR_fifo_m0_o[40:9];
assign ARLEN_M0 = AR_fifo_m0_o[8:5];
assign ARSIZE_M0 = AR_fifo_m0_o[4:2];
assign ARBURST_M0 = AR_fifo_m0_o[1:0];

assign winc_AR_m0 = (ARVALID_M0_i & (~wfull_AR_m0)) ? 1'd1 : 1'd0;
assign rinc_AR_m0 = (~rempty_AR_m0 & ARREADY_M0) ? 1'd1 : 1'd0;
assign ARVALID_M0 = ~rempty_AR_m0;
assign ARREADY_M0_o = (~wfull_AR_m0) ? 1'd1 : 1'd0;

fifo_45 fifo_45_AR_m0(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(AR_fifo_m0_i),
    .winc(winc_AR_m0), 
    .wclk(CPU_CLK_i), 
    .wrst(CPU_RST_i),
    .rinc(rinc_AR_m0), 
    .rdata(AR_fifo_m0_o),
    .wfull(wfull_AR_m0),
    .rempty(rempty_AR_m0)
);

logic wfull_AR_m1, rempty_AR_m1, winc_AR_m1, rinc_AR_m1;
assign AR_fifo_m1_i = {ARID_M1_i, ARADDR_M1_i, ARLEN_M1_i, ARSIZE_M1_i, ARBURST_M1_i};
assign ARID_M1 = AR_fifo_m1_o[44:41];
assign ARADDR_M1 = AR_fifo_m1_o[40:9];
assign ARLEN_M1 = AR_fifo_m1_o[8:5];
assign ARSIZE_M1 = AR_fifo_m1_o[4:2];
assign ARBURST_M1 = AR_fifo_m1_o[1:0];

assign winc_AR_m1 = (ARVALID_M1_i & (~wfull_AR_m1)) ? 1'd1 : 1'd0;
assign rinc_AR_m1 = (~rempty_AR_m1 & ARREADY_M1) ? 1'd1 : 1'd0;
assign ARVALID_M1 = ~rempty_AR_m1;
assign ARREADY_M1_o = (~wfull_AR_m1) ? 1'd1 : 1'd0;

fifo_45 fifo_45_AR_m1(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(AR_fifo_m1_i),
    .winc(winc_AR_m1), 
    .wclk(CPU_CLK_i), 
    .wrst(CPU_RST_i),
    .rinc(rinc_AR_m1), 
    .rdata(AR_fifo_m1_o),
    .wfull(wfull_AR_m1),
    .rempty(rempty_AR_m1)
);

//---------------R----------------//
logic wfull_R_m0, rempty_R_m0, winc_R_m0, rinc_R_m0;
assign R_fifo_m0_i = {RID_M0, RDATA_M0, RRESP_M0, RLAST_M0};
assign RID_M0_o = R_fifo_m0_o[38:35];
assign RDATA_M0_o = R_fifo_m0_o[34:3];
assign RRESP_M0_o = R_fifo_m0_o[2:1];
assign RLAST_M0_o = R_fifo_m0_o[0];

assign winc_R_m0 = (RVALID_M0 & (~wfull_R_m0)) ? 1'd1 : 1'd0;
assign rinc_R_m0 = (RREADY_M0_i & ~rempty_R_m0) ? 1'd1 : 1'd0;
assign RVALID_M0_o = (RREADY_M0_i & ~rempty_R_m0) ? 1'd1 : 1'd0;

fifo_39 fifo_39_R_m0(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(R_fifo_m0_i),
    .winc(winc_R_m0), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_R_m0),
    .rdata(R_fifo_m0_o),
    .wfull(wfull_R_m0),
    .rempty(rempty_R_m0)
);

logic wfull_R_m1, rempty_R_m1, winc_R_m1, rinc_R_m1;
assign R_fifo_m1_i = {RID_M1, RDATA_M1, RRESP_M1, RLAST_M1};
assign RID_M1_o = R_fifo_m1_o[38:35];
assign RDATA_M1_o = R_fifo_m1_o[34:3];
assign RRESP_M1_o = R_fifo_m1_o[2:1];
assign RLAST_M1_o = R_fifo_m1_o[0];

assign winc_R_m1 = (RVALID_M1 & (~wfull_R_m1)) ? 1'd1 : 1'd0;
assign rinc_R_m1 = (RREADY_M1_i & ~rempty_R_m1) ? 1'd1 : 1'd0;
assign RVALID_M1_o = (RREADY_M1_i & ~rempty_R_m1) ? 1'd1 : 1'd0;

fifo_39 fifo_39_R_m1(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(R_fifo_m1_i),
    .winc(winc_R_m1), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_R_m1), 
    .rdata(R_fifo_m1_o),
    .wfull(wfull_R_m1),
    .rempty(rempty_R_m1)
);

assign RREADY_M0 = (~wfull_R_m0) ? 1'd1 : 1'd0;
assign RREADY_M1 = (~wfull_R_m1) ? 1'd1 : 1'd0;

//------------------------------------slave(m2s)----------------------------//
//---------------AW----------------//
logic winc_AW_s1, rinc_AW_s1;
logic wfull_AW_s1, rempty_AW_s1;
assign winc_AW_s1 = (AWVALID_S1 & ~wfull_AW_s1) ? 1'd1 : 1'd0;
assign rinc_AW_s1 = (AWREADY_S1_i & ~rempty_AW_s1) ? 1'd1 : 1'd0;
assign AWVALID_S1_o = (AWREADY_S1_i & ~rempty_AW_s1) ? 1'd1 : 1'd0;
assign AW_fifo_s1_i = {AWID_S1, AWADDR_S1, AWLEN_S1, AWSIZE_S1, AWBURST_S1};
assign AWID_S1_o = AW_fifo_s1_o[48:41];
assign AWADDR_S1_o = AW_fifo_s1_o[40:9];
assign AWLEN_S1_o = AW_fifo_s1_o[8:5];
assign AWSIZE_S1_o = AW_fifo_s1_o[4:2];
assign AWBURST_S1_o = AW_fifo_s1_o[1:0];

fifo_49 fifo_49_AW_s1(
	.rclk(SRAM_CLK_i), 
    .rrst(SRAM_RST_i),
    .wdata(AW_fifo_s1_i),
    .winc(winc_AW_s1), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AW_s1),
    .rdata(AW_fifo_s1_o),
    .wfull(wfull_AW_s1),
    .rempty(rempty_AW_s1)
);

logic winc_AW_s2, rinc_AW_s2;
logic wfull_AW_s2, rempty_AW_s2;
assign winc_AW_s2 = (AWVALID_S2 & ~wfull_AW_s2) ? 1'd1 : 1'd0;
assign rinc_AW_s2 = (AWREADY_S2_i & ~rempty_AW_s2) ? 1'd1 : 1'd0;
assign AWVALID_S2_o = (AWREADY_S2_i & ~rempty_AW_s2) ? 1'd1 : 1'd0;
assign AW_fifo_s2_i = {AWID_S2, AWADDR_S2, AWLEN_S2, AWSIZE_S2, AWBURST_S2};
assign AWID_S2_o = AW_fifo_s2_o[48:41];
assign AWADDR_S2_o = AW_fifo_s2_o[40:9];
assign AWLEN_S2_o = AW_fifo_s2_o[8:5];
assign AWSIZE_S2_o = AW_fifo_s2_o[4:2];
assign AWBURST_S2_o = AW_fifo_s2_o[1:0];

fifo_49 fifo_49_AW_s2(
	.rclk(SRAM_CLK_i), 
    .rrst(SRAM_RST_i),
    .wdata(AW_fifo_s2_i),
    .winc(winc_AW_s2), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AW_s2), 
    .rdata(AW_fifo_s2_o),
    .wfull(wfull_AW_s2),
    .rempty(rempty_AW_s2)
);

logic winc_AW_s3, rinc_AW_s3;
logic wfull_AW_s3, rempty_AW_s3;
assign winc_AW_s3 = (AWVALID_S3 & ~wfull_AW_s3) ? 1'd1 : 1'd0;
assign rinc_AW_s3 = (AWREADY_S3_i & ~rempty_AW_s3) ? 1'd1 : 1'd0;
assign AWVALID_S3_o = (AWREADY_S3_i & ~rempty_AW_s3) ? 1'd1 : 1'd0;
assign AW_fifo_s3_i = {AWID_S3, AWADDR_S3, AWLEN_S3, AWSIZE_S3, AWBURST_S3};
assign AWID_S3_o = AW_fifo_s3_o[48:41];
assign AWADDR_S3_o = AW_fifo_s3_o[40:9];
assign AWLEN_S3_o = AW_fifo_s3_o[8:5];
assign AWSIZE_S3_o = AW_fifo_s3_o[4:2];
assign AWBURST_S3_o = AW_fifo_s3_o[1:0];

fifo_49 fifo_49_AW_s3(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(AW_fifo_s3_i),
    .winc(winc_AW_s3), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AW_s3), 
    .rdata(AW_fifo_s3_o),
    .wfull(wfull_AW_s3),
    .rempty(rempty_AW_s3)
);

logic winc_AW_s4, rinc_AW_s4;
logic wfull_AW_s4, rempty_AW_s4;
assign winc_AW_s4 = (AWVALID_S4 & ~wfull_AW_s4) ? 1'd1 : 1'd0;
assign rinc_AW_s4 = (AWREADY_S4_i & ~rempty_AW_s4) ? 1'd1 : 1'd0;
assign AWVALID_S4_o = (AWREADY_S4_i & ~rempty_AW_s4) ? 1'd1 : 1'd0;
assign AW_fifo_s4_i = {AWID_S4, AWADDR_S4, AWLEN_S4, AWSIZE_S4, AWBURST_S4};
assign AWID_S4_o = AW_fifo_s4_o[48:41];
assign AWADDR_S4_o = AW_fifo_s4_o[40:9];
assign AWLEN_S4_o = AW_fifo_s4_o[8:5];
assign AWSIZE_S4_o = AW_fifo_s4_o[4:2];
assign AWBURST_S4_o = AW_fifo_s4_o[1:0];

fifo_49 fifo_49_AW_s4(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(AW_fifo_s4_i),
    .winc(winc_AW_s4), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AW_s4), 
    .rdata(AW_fifo_s4_o),
    .wfull(wfull_AW_s4),
    .rempty(rempty_AW_s4)
);

logic winc_AW_s5, rinc_AW_s5;
logic wfull_AW_s5, rempty_AW_s5;
assign winc_AW_s5 = (AWVALID_S5 & ~wfull_AW_s5) ? 1'd1 : 1'd0;
assign rinc_AW_s5 = (AWREADY_S5_i & ~rempty_AW_s5) ? 1'd1 : 1'd0;
assign AWVALID_S5_o = (AWREADY_S5_i & ~rempty_AW_s5) ? 1'd1 : 1'd0;
assign AW_fifo_s5_i = {AWID_S5, AWADDR_S5, AWLEN_S5, AWSIZE_S5, AWBURST_S5};
assign AWID_S5_o = AW_fifo_s5_o[48:41];
assign AWADDR_S5_o = AW_fifo_s5_o[40:9];
assign AWLEN_S5_o = AW_fifo_s5_o[8:5];
assign AWSIZE_S5_o = AW_fifo_s5_o[4:2];
assign AWBURST_S5_o = AW_fifo_s5_o[1:0];

fifo_49 fifo_49_AW_s5(
	.rclk(DRAM_CLK_i), 
    .rrst(DRAM_RST_i),
    .wdata(AW_fifo_s5_i),
    .winc(winc_AW_s5), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AW_s5), 
    .rdata(AW_fifo_s5_o),
    .wfull(wfull_AW_s5),
    .rempty(rempty_AW_s5)
);

assign AWREADY_S1 = (~wfull_AW_s1) ? 1'd1 : 1'd0;
assign AWREADY_S2 = (~wfull_AW_s2) ? 1'd1 : 1'd0;
assign AWREADY_S3 = (~wfull_AW_s3) ? 1'd1 : 1'd0;
assign AWREADY_S4 = (~wfull_AW_s4) ? 1'd1 : 1'd0;
assign AWREADY_S5 = (~wfull_AW_s5) ? 1'd1 : 1'd0;

//---------------W----------------//
logic clk_fifo_AW, rst_fifo_AW;
logic wfull_W_s1, rempty_W_s1, winc_W_s1, rinc_W_s1;
assign winc_W_s1 = (WVALID_S1 & ~wfull_W_s1) ? 1'd1 : 1'd0;
assign rinc_W_s1 = (WREADY_S1_i & ~rempty_W_s1) ? 1'd1 : 1'd0;
assign WVALID_S1_o = (WREADY_S1_i & ~rempty_W_s1) ? 1'd1 : 1'd0;
assign W_fifo_s1_i = {WDATA_S1, WSTRB_S1, WLAST_S1};
assign WDATA_S1_o = W_fifo_s1_o[36:5];
assign WSTRB_S1_o = W_fifo_s1_o[4:1];
assign WLAST_S1_o = W_fifo_s1_o[0];

fifo37_s fifo_37_W_s1(
	.rclk(SRAM_CLK_i), 
    .rrst(SRAM_RST_i),
    .wdata(W_fifo_s1_i),
    .winc(winc_W_s1), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_W_s1), 
    .rdata(W_fifo_s1_o),
    .wfull(wfull_W_s1),
    .rempty(rempty_W_s1)
);

logic wfull_W_s2, rempty_W_s2, winc_W_s2, rinc_W_s2;
assign winc_W_s2 = (WVALID_S2 & ~wfull_W_s2) ? 1'd1 : 1'd0;
assign rinc_W_s2 = (WREADY_S2_i & ~rempty_W_s2) ? 1'd1 : 1'd0;
assign WVALID_S2_o = (WREADY_S2_i & ~rempty_W_s2) ? 1'd1 : 1'd0;
assign W_fifo_s2_i = {WDATA_S2, WSTRB_S2, WLAST_S2};
assign WDATA_S2_o = W_fifo_s2_o[36:5];
assign WSTRB_S2_o = W_fifo_s2_o[4:1];
assign WLAST_S2_o = W_fifo_s2_o[0];

fifo37_s fifo_37_W_s2(
	.rclk(SRAM_CLK_i), 
    .rrst(SRAM_RST_i),
    .wdata(W_fifo_s2_i),
    .winc(winc_W_s2), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_W_s2), 
    .rdata(W_fifo_s2_o),
    .wfull(wfull_W_s2),
    .rempty(rempty_W_s2)
);

logic wfull_W_s3, rempty_W_s3, winc_W_s3, rinc_W_s3;
assign winc_W_s3 = (WVALID_S3 & ~wfull_W_s3) ? 1'd1 : 1'd0;
assign rinc_W_s3 = (WREADY_S3_i & ~rempty_W_s3) ? 1'd1 : 1'd0;
assign WVALID_S3_o = (WREADY_S3_i & ~rempty_W_s3) ? 1'd1 : 1'd0;
assign W_fifo_s3_i = {WDATA_S3, WSTRB_S3, WLAST_S3};
assign WDATA_S3_o = W_fifo_s3_o[36:5];
assign WSTRB_S3_o = W_fifo_s3_o[4:1];
assign WLAST_S3_o = W_fifo_s3_o[0];

fifo37_s fifo_37_W_s3(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(W_fifo_s3_i),
    .winc(winc_W_s3), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_W_s3), 
    .rdata(W_fifo_s3_o),
    .wfull(wfull_W_s3),
    .rempty(rempty_W_s3)
);

logic wfull_W_s4, rempty_W_s4, winc_W_s4, rinc_W_s4;
assign winc_W_s4 = (WVALID_S4 & ~wfull_W_s4) ? 1'd1 : 1'd0;
assign rinc_W_s4 = (WREADY_S4_i & ~rempty_W_s4) ? 1'd1 : 1'd0;
assign WVALID_S4_o = (WREADY_S4_i & ~rempty_W_s4) ? 1'd1 : 1'd0;
assign W_fifo_s4_i = {WDATA_S4, WSTRB_S4, WLAST_S4};
assign WDATA_S4_o = W_fifo_s4_o[36:5];
assign WSTRB_S4_o = W_fifo_s4_o[4:1];
assign WLAST_S4_o = W_fifo_s4_o[0];

fifo37_s fifo_37_W_s4(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(W_fifo_s4_i),
    .winc(winc_W_s4), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_W_s4), 
    .rdata(W_fifo_s4_o),
    .wfull(wfull_W_s4),
    .rempty(rempty_W_s4)
);

logic wfull_W_s5, rempty_W_s5, winc_W_s5, rinc_W_s5;
assign winc_W_s5 = (WVALID_S5 & ~wfull_W_s5) ? 1'd1 : 1'd0;
assign rinc_W_s5 = (WREADY_S5_i & ~rempty_W_s5) ? 1'd1 : 1'd0;
assign WVALID_S5_o = (WREADY_S5_i & ~rempty_W_s5) ? 1'd1 : 1'd0;
assign W_fifo_s5_i = {WDATA_S5, WSTRB_S5, WLAST_S5};
assign WDATA_S5_o = W_fifo_s5_o[36:5];
assign WSTRB_S5_o = W_fifo_s5_o[4:1];
assign WLAST_S5_o = W_fifo_s5_o[0];

fifo37_s fifo_37_W_s5(
	.rclk(DRAM_CLK_i), 
    .rrst(DRAM_RST_i),
    .wdata(W_fifo_s5_i),
    .winc(winc_W_s5), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_W_s5), 
    .rdata(W_fifo_s5_o),
    .wfull(wfull_W_s5),
    .rempty(rempty_W_s5)
);

assign WREADY_S1 = (~wfull_W_s1) ? 1'd1 : 1'd0;
assign WREADY_S2 = (~wfull_W_s2) ? 1'd1 : 1'd0;
assign WREADY_S3 = (~wfull_W_s3) ? 1'd1 : 1'd0;
assign WREADY_S4 = (~wfull_W_s4) ? 1'd1 : 1'd0;
assign WREADY_S5 = (~wfull_W_s5) ? 1'd1 : 1'd0;

//---------------B----------------//
logic wfull_B_s1, rempty_B_s1, winc_B_s1, rinc_B_s1;
assign winc_B_s1 = (BVALID_S1_i & ~wfull_B_s1) ? 1'd1 : 1'd0;
assign rinc_B_s1 = (~rempty_B_s1 & BREADY_S1) ? 1'd1 : 1'd0;
assign BVALID_S1 = (~rempty_B_s1) ? 1'd1 : 1'd0;
assign B_fifo_s1_i = {BID_S1_i, BRESP_S1_i};
assign BID_S1 = B_fifo_s1_o[9:2];
assign BRESP_S1 = B_fifo_s1_o[1:0];

fifo_10 fifo_10_B1(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(B_fifo_s1_i),
    .winc(winc_B_s1), 
    .wclk(SRAM_CLK_i), 
    .wrst(SRAM_RST_i),
    .rinc(rinc_B_s1), 
    .rdata(B_fifo_s1_o),
    .wfull(wfull_B_s1),
    .rempty(rempty_B_s1)
);

logic wfull_B_s2, rempty_B_s2, winc_B_s2, rinc_B_s2;
assign winc_B_s2 = (BVALID_S2_i & ~wfull_B_s2) ? 1'd1 : 1'd0;
assign rinc_B_s2 = (~rempty_B_s2 & BREADY_S2) ? 1'd1 : 1'd0;
assign BVALID_S2 = (~rempty_B_s2) ? 1'd1 : 1'd0;
assign B_fifo_s2_i = {BID_S2_i, BRESP_S2_i};
assign BID_S2 = B_fifo_s2_o[9:2];
assign BRESP_S2 = B_fifo_s2_o[1:0];

fifo_10 fifo_10_B2(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(B_fifo_s2_i),
    .winc(winc_B_s2), 
    .wclk(SRAM_CLK_i), 
    .wrst(SRAM_RST_i),
    .rinc(rinc_B_s2), 
    .rdata(B_fifo_s2_o),
    .wfull(wfull_B_s2),
    .rempty(rempty_B_s2)
);

logic wfull_B_s3, rempty_B_s3, winc_B_s3, rinc_B_s3;
assign winc_B_s3 = (BVALID_S3_i & ~wfull_B_s3) ? 1'd1 : 1'd0;
assign rinc_B_s3 = (~rempty_B_s3 & BREADY_S3) ? 1'd1 : 1'd0;
assign BVALID_S3 = (~rempty_B_s3) ? 1'd1 : 1'd0;
assign B_fifo_s3_i = {BID_S3_i, BRESP_S3_i};
assign BID_S3 = B_fifo_s3_o[9:2];
assign BRESP_S3 = B_fifo_s3_o[1:0];

fifo_10 fifo_10_B3(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(B_fifo_s3_i),
    .winc(winc_B_s3), 
    .wclk(CPU_CLK_i), 
    .wrst(CPU_RST_i),
    .rinc(rinc_B_s3), 
    .rdata(B_fifo_s3_o),
    .wfull(wfull_B_s3),
    .rempty(rempty_B_s3)
);

logic wfull_B_s4, rempty_B_s4, winc_B_s4, rinc_B_s4;
assign winc_B_s4 = (BVALID_S4_i & ~wfull_B_s4) ? 1'd1 : 1'd0;
assign rinc_B_s4 = (~rempty_B_s4 & BREADY_S4) ? 1'd1 : 1'd0;
assign BVALID_S4 = (~rempty_B_s4) ? 1'd1 : 1'd0;
assign B_fifo_s4_i = {BID_S4_i, BRESP_S4_i};
assign BID_S4 = B_fifo_s4_o[9:2];
assign BRESP_S4 = B_fifo_s4_o[1:0];

fifo_10 fifo_10_B4(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(B_fifo_s4_i),
    .winc(winc_B_s4), 
    .wclk(CPU_CLK_i), 
    .wrst(CPU_RST_i),
    .rinc(rinc_B_s4), 
    .rdata(B_fifo_s4_o),
    .wfull(wfull_B_s4),
    .rempty(rempty_B_s4)
);

logic wfull_B_s5, rempty_B_s5, winc_B_s5, rinc_B_s5;

assign winc_B_s5 = (BVALID_S5_i & ~wfull_B_s5) ? 1'd1 : 1'd0;
assign rinc_B_s5 = (~rempty_B_s5 & BREADY_S5) ? 1'd1 : 1'd0;
assign BVALID_S5 = (~rempty_B_s5) ? 1'd1 : 1'd0;

assign B_fifo_s5_i = {BID_S5_i, BRESP_S5_i};
assign BID_S5 = B_fifo_s5_o[9:2];
assign BRESP_S5 = B_fifo_s5_o[1:0];

fifo_10 fifo_10_B5(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(B_fifo_s5_i),
    .winc(winc_B_s5), 
    .wclk(DRAM_CLK_i), 
    .wrst(DRAM_RST_i),
    .rinc(rinc_B_s5), 
    .rdata(B_fifo_s5_o),
    .wfull(wfull_B_s5),
    .rempty(rempty_B_s5)
);

assign BREADY_S1_o = (~wfull_B_s1) ? 1'd1 : 1'd0;
assign BREADY_S2_o = (~wfull_B_s2) ? 1'd1 : 1'd0;
assign BREADY_S3_o = (~wfull_B_s3) ? 1'd1 : 1'd0;
assign BREADY_S4_o = (~wfull_B_s4) ? 1'd1 : 1'd0;
assign BREADY_S5_o = (~wfull_B_s5) ? 1'd1 : 1'd0;

//---------------AR----------------//
logic wfull_AR_s0, rempty_AR_s0, winc_AR_s0, rinc_AR_s0;
assign winc_AR_s0 = (ARVALID_S0 & ~wfull_AR_s0) ? 1'd1 : 1'd0;
assign rinc_AR_s0 = (ARREADY_S0_i & ~rempty_AR_s0) ? 1'd1 : 1'd0;
assign ARVALID_S0_o = (ARREADY_S0_i & ~rempty_AR_s0) ? 1'd1 : 1'd0;
assign AR_fifo_s0_i = {ARID_S0, ARADDR_S0, ARLEN_S0, ARSIZE_S0, ARBURST_S0};
assign ARID_S0_o = AR_fifo_s0_o[48:41];
assign ARADDR_S0_o = AR_fifo_s0_o[40:9];
assign ARLEN_S0_o = AR_fifo_s0_o[8:5];
assign ARSIZE_S0_o = AR_fifo_s0_o[4:2];
assign ARBURST_S0_o = AR_fifo_s0_o[1:0];

fifo_49 fifo_49_AR_s0(
	.rclk(ROM_CLK_i), 
    .rrst(ROM_RST_i),
    .wdata(AR_fifo_s0_i),
    .winc(winc_AR_s0), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AR_s0), 
    .rdata(AR_fifo_s0_o),
    .wfull(wfull_AR_s0),
    .rempty(rempty_AR_s0)
);

logic wfull_AR_s1, rempty_AR_s1, winc_AR_s1, rinc_AR_s1;
assign winc_AR_s1 = (ARVALID_S1 & ~wfull_AR_s1) ? 1'd1 : 1'd0;
assign rinc_AR_s1 = (ARREADY_S1_i & ~rempty_AR_s1) ? 1'd1 : 1'd0;
assign ARVALID_S1_o = (ARREADY_S1_i & ~rempty_AR_s1) ? 1'd1 : 1'd0;
assign AR_fifo_s1_i = {ARID_S1, ARADDR_S1, ARLEN_S1, ARSIZE_S1, ARBURST_S1};
assign ARID_S1_o = AR_fifo_s1_o[48:41];
assign ARADDR_S1_o = AR_fifo_s1_o[40:9];
assign ARLEN_S1_o = AR_fifo_s1_o[8:5];
assign ARSIZE_S1_o = AR_fifo_s1_o[4:2];
assign ARBURST_S1_o = AR_fifo_s1_o[1:0];

fifo_49 fifo_49_AR_s1(
	.rclk(SRAM_CLK_i), 
    .rrst(SRAM_RST_i),
    .wdata(AR_fifo_s1_i),
    .winc(winc_AR_s1), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AR_s1), 
    .rdata(AR_fifo_s1_o),
    .wfull(wfull_AR_s1),
    .rempty(rempty_AR_s1)
);

logic wfull_AR_s2, rempty_AR_s2, winc_AR_s2, rinc_AR_s2;
assign winc_AR_s2 = (ARVALID_S2 & ~wfull_AR_s2) ? 1'd1 : 1'd0;
assign rinc_AR_s2 = (ARREADY_S2_i & ~rempty_AR_s2) ? 1'd1 : 1'd0;
assign ARVALID_S2_o = (ARREADY_S2_i & ~rempty_AR_s2) ? 1'd1 : 1'd0;
assign AR_fifo_s2_i = {ARID_S2, ARADDR_S2, ARLEN_S2, ARSIZE_S2, ARBURST_S2};
assign ARID_S2_o = AR_fifo_s2_o[48:41];
assign ARADDR_S2_o = AR_fifo_s2_o[40:9];
assign ARLEN_S2_o = AR_fifo_s2_o[8:5];
assign ARSIZE_S2_o = AR_fifo_s2_o[4:2];
assign ARBURST_S2_o = AR_fifo_s2_o[1:0];

fifo_49 fifo_49_AR_s2(
	.rclk(SRAM_CLK_i), 
    .rrst(SRAM_RST_i),
    .wdata(AR_fifo_s2_i),
    .winc(winc_AR_s2), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AR_s2),
    .rdata(AR_fifo_s2_o),
    .wfull(wfull_AR_s2),
    .rempty(rempty_AR_s2)
);

logic wfull_AR_s3, rempty_AR_s3, winc_AR_s3, rinc_AR_s3;
assign winc_AR_s3 = (ARVALID_S3 & ~wfull_AR_s3) ? 1'd1 : 1'd0;
assign rinc_AR_s3 = (ARREADY_S3_i & ~rempty_AR_s3) ? 1'd1 : 1'd0;
assign ARVALID_S3_o = (ARREADY_S3_i & ~rempty_AR_s3) ? 1'd1 : 1'd0;
assign AR_fifo_s3_i = {ARID_S3, ARADDR_S3, ARLEN_S3, ARSIZE_S3, ARBURST_S3};
assign ARID_S3_o = AR_fifo_s3_o[48:41];
assign ARADDR_S3_o = AR_fifo_s3_o[40:9];
assign ARLEN_S3_o = AR_fifo_s3_o[8:5];
assign ARSIZE_S3_o = AR_fifo_s3_o[4:2];
assign ARBURST_S3_o = AR_fifo_s3_o[1:0];

fifo_49 fifo_49_AR_s3(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(AR_fifo_s3_i),
    .winc(winc_AR_s3), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AR_s3),
    .rdata(AR_fifo_s3_o),
    .wfull(wfull_AR_s3),
    .rempty(rempty_AR_s3)
);

logic wfull_AR_s4, rempty_AR_s4, winc_AR_s4, rinc_AR_s4;
assign winc_AR_s4 = (ARVALID_S4 & ~wfull_AR_s4) ? 1'd1 : 1'd0;
assign rinc_AR_s4 = (ARREADY_S4_i & ~rempty_AR_s4) ? 1'd1 : 1'd0;
assign ARVALID_S4_o = (ARREADY_S4_i & ~rempty_AR_s4) ? 1'd1 : 1'd0;
assign AR_fifo_s4_i = {ARID_S4, ARADDR_S4, ARLEN_S4, ARSIZE_S4, ARBURST_S4};
assign ARID_S4_o = AR_fifo_s4_o[48:41];
assign ARADDR_S4_o = AR_fifo_s4_o[40:9];
assign ARLEN_S4_o = AR_fifo_s4_o[8:5];
assign ARSIZE_S4_o = AR_fifo_s4_o[4:2];
assign ARBURST_S4_o = AR_fifo_s4_o[1:0];

fifo_49 fifo_49_AR_s4(
	.rclk(CPU_CLK_i), 
    .rrst(CPU_RST_i),
    .wdata(AR_fifo_s4_i),
    .winc(winc_AR_s4), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AR_s4), 
    .rdata(AR_fifo_s4_o),
    .wfull(wfull_AR_s4),
    .rempty(rempty_AR_s4)
);

logic wfull_AR_s5, rempty_AR_s5, winc_AR_s5, rinc_AR_s5;
assign winc_AR_s5 = (ARVALID_S5 & ~wfull_AR_s5) ? 1'd1 : 1'd0;
assign rinc_AR_s5 = (ARREADY_S5_i & ~rempty_AR_s5) ? 1'd1 : 1'd0;
assign ARVALID_S5_o = (ARREADY_S5_i & ~rempty_AR_s5) ? 1'd1 : 1'd0;
assign AR_fifo_s5_i = {ARID_S5, ARADDR_S5, ARLEN_S5, ARSIZE_S5, ARBURST_S5};
assign ARID_S5_o = AR_fifo_s5_o[48:41];
assign ARADDR_S5_o = AR_fifo_s5_o[40:9];
assign ARLEN_S5_o = AR_fifo_s5_o[8:5];
assign ARSIZE_S5_o = AR_fifo_s5_o[4:2];
assign ARBURST_S5_o = AR_fifo_s5_o[1:0];

fifo_49 fifo_49_AR_s5(
	.rclk(DRAM_CLK_i), 
    .rrst(DRAM_RST_i),
    .wdata(AR_fifo_s5_i),
    .winc(winc_AR_s5), 
    .wclk(AXI_CLK_i), 
    .wrst(AXI_RST_i),
    .rinc(rinc_AR_s5), 
    .rdata(AR_fifo_s5_o),
    .wfull(wfull_AR_s5),
    .rempty(rempty_AR_s5)
);

assign ARREADY_S0 = (~wfull_AR_s0) ? 1'd1 : 1'd0;
assign ARREADY_S1 = (~wfull_AR_s1) ? 1'd1 : 1'd0;
assign ARREADY_S2 = (~wfull_AR_s2) ? 1'd1 : 1'd0;
assign ARREADY_S3 = (~wfull_AR_s3) ? 1'd1 : 1'd0;
assign ARREADY_S4 = (~wfull_AR_s4) ? 1'd1 : 1'd0;
assign ARREADY_S5 = (~wfull_AR_s5) ? 1'd1 : 1'd0;

//---------------R----------------//
logic wfull_R_s0, rempty_R_s0, winc_R_s0, rinc_R_s0;
assign winc_R_s0 = (RVALID_S0_i & ~wfull_R_s0) ? 1'd1 : 1'd0;
assign rinc_R_s0 = (~rempty_R_s0 & RREADY_S0) ? 1'd1 : 1'd0;
assign RVALID_S0 = (~rempty_R_s0) ? 1'd1 : 1'd0;
assign R_fifo_s0_i = {RID_S0_i, RDATA_S0_i, RRESP_S0_i, RLAST_S0_i};
assign RID_S0 = R_fifo_s0_o[42:35];
assign RDATA_S0 = R_fifo_s0_o[34:3];
assign RRESP_S0 = R_fifo_s0_o[2:1];
assign RLAST_S0 = R_fifo_s0_o[0];
fifo_43 fifo_43_R_s0(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(R_fifo_s0_i),
    .winc(winc_R_s0), 
    .wclk(ROM_CLK_i), 
    .wrst(ROM_RST_i),
    .rinc(rinc_R_s0), 
    .rdata(R_fifo_s0_o),
    .wfull(wfull_R_s0),
    .rempty(rempty_R_s0)
);

logic wfull_R_s1, rempty_R_s1, winc_R_s1, rinc_R_s1;
assign winc_R_s1 = (RVALID_S1_i & ~wfull_R_s1) ? 1'd1 : 1'd0;
assign rinc_R_s1 = (~rempty_R_s1 & RREADY_S1) ? 1'd1 : 1'd0;
assign RVALID_S1 = (~rempty_R_s1) ? 1'd1 : 1'd0;
assign R_fifo_s1_i = {RID_S1_i, RDATA_S1_i, RRESP_S1_i, RLAST_S1_i};
assign RID_S1 = R_fifo_s1_o[42:35];
assign RDATA_S1 = R_fifo_s1_o[34:3];
assign RRESP_S1 = R_fifo_s1_o[2:1];
assign RLAST_S1 = R_fifo_s1_o[0];
fifo_43 fifo_43_R_s1(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(R_fifo_s1_i),
    .winc(winc_R_s1), 
    .wclk(SRAM_CLK_i), 
    .wrst(SRAM_RST_i),
    .rinc(rinc_R_s1), 
    .rdata(R_fifo_s1_o),
    .wfull(wfull_R_s1),
    .rempty(rempty_R_s1)
);

logic wfull_R_s2, rempty_R_s2, winc_R_s2, rinc_R_s2;
assign winc_R_s2 = (RVALID_S2_i & ~wfull_R_s2) ? 1'd1 : 1'd0;
assign rinc_R_s2 = (~rempty_R_s2 & RREADY_S2) ? 1'd1 : 1'd0;
assign RVALID_S2 = (~rempty_R_s2) ? 1'd1 : 1'd0;
assign R_fifo_s2_i = {RID_S2_i, RDATA_S2_i, RRESP_S2_i, RLAST_S2_i};
assign RID_S2 = R_fifo_s2_o[42:35];
assign RDATA_S2 = R_fifo_s2_o[34:3];
assign RRESP_S2 = R_fifo_s2_o[2:1];
assign RLAST_S2 = R_fifo_s2_o[0];
fifo_43 fifo_43_R_s2(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(R_fifo_s2_i),
    .winc(winc_R_s2), 
    .wclk(SRAM_CLK_i), 
    .wrst(SRAM_RST_i),
    .rinc(rinc_R_s2),
    .rdata(R_fifo_s2_o),
    .wfull(wfull_R_s2),
    .rempty(rempty_R_s2)
);

logic wfull_R_s3, rempty_R_s3, winc_R_s3, rinc_R_s3;
assign winc_R_s3 = (RVALID_S3_i & ~wfull_R_s3) ? 1'd1 : 1'd0;
assign rinc_R_s3 = (~rempty_R_s3 & RREADY_S3) ? 1'd1 : 1'd0;
assign RVALID_S3 = (~rempty_R_s3) ? 1'd1 : 1'd0;
assign R_fifo_s3_i = {RID_S3_i, RDATA_S3_i, RRESP_S3_i, RLAST_S3_i};
assign RID_S3 = R_fifo_s3_o[42:35];
assign RDATA_S3 = R_fifo_s3_o[34:3];
assign RRESP_S3 = R_fifo_s3_o[2:1];
assign RLAST_S3 = R_fifo_s3_o[0];
fifo_43 fifo_43_R_s3(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(R_fifo_s3_i),
    .winc(winc_R_s3), 
    .wclk(CPU_CLK_i), 
    .wrst(CPU_RST_i),
    .rinc(rinc_R_s3), 
    .rdata(R_fifo_s3_o),
    .wfull(wfull_R_s3),
    .rempty(rempty_R_s3)
);

logic wfull_R_s4, rempty_R_s4, winc_R_s4, rinc_R_s4;
assign winc_R_s4 = (RVALID_S4_i & ~wfull_R_s4) ? 1'd1 : 1'd0;
assign rinc_R_s4 = (~rempty_R_s4 & RREADY_S4) ? 1'd1 : 1'd0;
assign RVALID_S4 = (~rempty_R_s4) ? 1'd1 : 1'd0;
assign R_fifo_s4_i = {RID_S4_i, RDATA_S4_i, RRESP_S4_i, RLAST_S4_i};
assign RID_S4 = R_fifo_s4_o[42:35];
assign RDATA_S4 = R_fifo_s4_o[34:3];
assign RRESP_S4 = R_fifo_s4_o[2:1];
assign RLAST_S4 = R_fifo_s4_o[0];
fifo_43 fifo_43_R_s4(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(R_fifo_s4_i),
    .winc(winc_R_s4), 
    .wclk(CPU_CLK_i), 
    .wrst(CPU_RST_i),
    .rinc(rinc_R_s4), 
    .rdata(R_fifo_s4_o),
    .wfull(wfull_R_s4),
    .rempty(rempty_R_s4)
);

logic wfull_R_s5, rempty_R_s5, winc_R_s5, rinc_R_s5;
assign winc_R_s5 = (RVALID_S5_i & ~wfull_R_s5) ? 1'd1 : 1'd0;
assign rinc_R_s5 = (~rempty_R_s5 & RREADY_S5) ? 1'd1 : 1'd0;
assign RVALID_S5 = (~rempty_R_s5) ? 1'd1 : 1'd0;
assign R_fifo_s5_i = {RID_S5_i, RDATA_S5_i, RRESP_S5_i, RLAST_S5_i};
assign RID_S5 = R_fifo_s5_o[42:35];
assign RDATA_S5 = R_fifo_s5_o[34:3];
assign RRESP_S5 = R_fifo_s5_o[2:1];
assign RLAST_S5 = R_fifo_s5_o[0];
fifo_43 fifo_43_R_s5(
	.rclk(AXI_CLK_i), 
    .rrst(AXI_RST_i),
    .wdata(R_fifo_s5_i),
    .winc(winc_R_s5), 
    .wclk(DRAM_CLK_i), 
    .wrst(DRAM_RST_i),
    .rinc(rinc_R_s5), 
    .rdata(R_fifo_s5_o),
    .wfull(wfull_R_s5),
    .rempty(rempty_R_s5)
);

assign RREADY_S0_o = (~wfull_R_s0) ? 1'd1 : 1'd0;
assign RREADY_S1_o = (~wfull_R_s1) ? 1'd1 : 1'd0;
assign RREADY_S2_o = (~wfull_R_s2) ? 1'd1 : 1'd0;
assign RREADY_S3_o = (~wfull_R_s3) ? 1'd1 : 1'd0;
assign RREADY_S4_o = (~wfull_R_s4) ? 1'd1 : 1'd0;
assign RREADY_S5_o = (~wfull_R_s5) ? 1'd1 : 1'd0;

write_addr write_addr(
	.ACLK(AXI_CLK_i),
	.ARESETn(AXI_RST_i),
	.AW_arbiter(AW_arbiter),
	.cs_w(cs_w),

	.AWID_M1(AWID_M1),
	.AWADDR_M1(AWADDR_M1),
	.AWLEN_M1(AWLEN_M1),
	.AWSIZE_M1(AWSIZE_M1),
	.AWBURST_M1(AWBURST_M1),
	.AWVALID_M1(AWVALID_M1),
	.AWREADY_M1(AWREADY_M1),
	
	.AWREADY_S1(AWREADY_S1),
	.AWREADY_S2(AWREADY_S2),
	.AWREADY_S3(AWREADY_S3),
	.AWREADY_S4(AWREADY_S4),
	.AWREADY_S5(AWREADY_S5),

	.AWID_S1(AWID_S1),
	.AWADDR_S1(AWADDR_S1),
	.AWLEN_S1(AWLEN_S1),
	.AWSIZE_S1(AWSIZE_S1),
	.AWBURST_S1(AWBURST_S1),
	.AWVALID_S1(AWVALID_S1),

	.AWID_S2(AWID_S2),
	.AWADDR_S2(AWADDR_S2),
	.AWLEN_S2(AWLEN_S2),
	.AWSIZE_S2(AWSIZE_S2),
	.AWBURST_S2(AWBURST_S2),
	.AWVALID_S2(AWVALID_S2),

	.AWID_S3(AWID_S3),
	.AWADDR_S3(AWADDR_S3),
	.AWLEN_S3(AWLEN_S3),
	.AWSIZE_S3(AWSIZE_S3),
	.AWBURST_S3(AWBURST_S3),
	.AWVALID_S3(AWVALID_S3),

	.AWID_S4(AWID_S4),
	.AWADDR_S4(AWADDR_S4),
	.AWLEN_S4(AWLEN_S4),
	.AWSIZE_S4(AWSIZE_S4),
	.AWBURST_S4(AWBURST_S4),
	.AWVALID_S4(AWVALID_S4),

	.AWID_S5(AWID_S5),
	.AWADDR_S5(AWADDR_S5),
	.AWLEN_S5(AWLEN_S5),
	.AWSIZE_S5(AWSIZE_S5),
	.AWBURST_S5(AWBURST_S5),
	.AWVALID_S5(AWVALID_S5)
);

write_data write_data(
	.ACLK(AXI_CLK_i),
	.ARESETn(AXI_RST_i),
	.AW_arbiter(AW_arbiter),
	
	.WDATA_M1(WDATA_M1),
	.WSTRB_M1(WSTRB_M1),
	.WLAST_M1(WLAST_M1),
	.WVALID_M1(WVALID_M1),
	.WREADY_M1(WREADY_M1),

	.WREADY_S1(WREADY_S1),
	.WREADY_S2(WREADY_S2),
	.WREADY_S3(WREADY_S3),
	.WREADY_S4(WREADY_S4),
	.WREADY_S5(WREADY_S5),

	.WDATA_S1(WDATA_S1),
	.WSTRB_S1(WSTRB_S1),
	.WLAST_S1(WLAST_S1),
	.WVALID_S1(WVALID_S1),

	.WDATA_S2(WDATA_S2),
	.WSTRB_S2(WSTRB_S2),
	.WLAST_S2(WLAST_S2),
	.WVALID_S2(WVALID_S2),

	.WDATA_S3(WDATA_S3),
	.WSTRB_S3(WSTRB_S3),
	.WLAST_S3(WLAST_S3),
	.WVALID_S3(WVALID_S3),

	.WDATA_S4(WDATA_S4),
	.WSTRB_S4(WSTRB_S4),
	.WLAST_S4(WLAST_S4),
	.WVALID_S4(WVALID_S4),

	.WDATA_S5(WDATA_S5),
	.WSTRB_S5(WSTRB_S5),
	.WLAST_S5(WLAST_S5),
	.WVALID_S5(WVALID_S5)
);

write_resp write_resp(
	.ACLK(AXI_CLK_i),
	.ARESETn(AXI_RST_i),
	.AW_arbiter(AW_arbiter),

	.BREADY_M1(BREADY_M1),
	.BID_M1(BID_M1),
	.BRESP_M1(BRESP_M1),
	.BVALID_M1(BVALID_M1),

	.BID_S1(BID_S1),
	.BRESP_S1(BRESP_S1),
	.BVALID_S1(BVALID_S1),

	.BID_S2(BID_S2),
	.BRESP_S2(BRESP_S2),
	.BVALID_S2(BVALID_S2),

	.BID_S3(BID_S3),
	.BRESP_S3(BRESP_S3),
	.BVALID_S3(BVALID_S3),

	.BID_S4(BID_S4),
	.BRESP_S4(BRESP_S4),
	.BVALID_S4(BVALID_S4),

	.BID_S5(BID_S5),
	.BRESP_S5(BRESP_S5),
	.BVALID_S5(BVALID_S5),

	.BREADY_S1(BREADY_S1),
	.BREADY_S2(BREADY_S2),
	.BREADY_S3(BREADY_S3),
	.BREADY_S4(BREADY_S4),
	.BREADY_S5(BREADY_S5)
);

read_addr read_addr(
	.ACLK(AXI_CLK_i),
	.ARESETn(AXI_RST_i),
	.AR_arbiter(AR_arbiter),
	.cs(cs),

	.ARID_M0(ARID_M0),
	.ARADDR_M0(ARADDR_M0),
	.ARLEN_M0(ARLEN_M0),
	.ARSIZE_M0(ARSIZE_M0),
	.ARBURST_M0(ARBURST_M0),
	.ARVALID_M0(ARVALID_M0),
	.ARREADY_M0(ARREADY_M0),

	.ARID_M1(ARID_M1),
	.ARADDR_M1(ARADDR_M1),
	.ARLEN_M1(ARLEN_M1),
	.ARSIZE_M1(ARSIZE_M1),
	.ARBURST_M1(ARBURST_M1),
	.ARVALID_M1(ARVALID_M1),
	.ARREADY_M1(ARREADY_M1),

	.ARREADY_S0(ARREADY_S0),
	.ARREADY_S1(ARREADY_S1),
	.ARREADY_S2(ARREADY_S2),
	.ARREADY_S3(ARREADY_S3),
	.ARREADY_S4(ARREADY_S4),
	.ARREADY_S5(ARREADY_S5),

	.ARID_S0(ARID_S0),
	.ARADDR_S0(ARADDR_S0),
	.ARLEN_S0(ARLEN_S0),
	.ARSIZE_S0(ARSIZE_S0),
	.ARBURST_S0(ARBURST_S0),
	.ARVALID_S0(ARVALID_S0),

	.ARID_S1(ARID_S1),
	.ARADDR_S1(ARADDR_S1),
	.ARLEN_S1(ARLEN_S1),
	.ARSIZE_S1(ARSIZE_S1),
	.ARBURST_S1(ARBURST_S1),
	.ARVALID_S1(ARVALID_S1),

	.ARID_S2(ARID_S2),
	.ARADDR_S2(ARADDR_S2),
	.ARLEN_S2(ARLEN_S2),
	.ARSIZE_S2(ARSIZE_S2),
	.ARBURST_S2(ARBURST_S2),
	.ARVALID_S2(ARVALID_S2),

	.ARID_S3(ARID_S3),
	.ARADDR_S3(ARADDR_S3),
	.ARLEN_S3(ARLEN_S3),
	.ARSIZE_S3(ARSIZE_S3),
	.ARBURST_S3(ARBURST_S3),
	.ARVALID_S3(ARVALID_S3),

	.ARID_S4(ARID_S4),
	.ARADDR_S4(ARADDR_S4),
	.ARLEN_S4(ARLEN_S4),
	.ARSIZE_S4(ARSIZE_S4),
	.ARBURST_S4(ARBURST_S4),
	.ARVALID_S4(ARVALID_S4),
 
	.ARID_S5(ARID_S5),
	.ARADDR_S5(ARADDR_S5),
	.ARLEN_S5(ARLEN_S5),
	.ARSIZE_S5(ARSIZE_S5),
	.ARBURST_S5(ARBURST_S5),
	.ARVALID_S5(ARVALID_S5)
);

read_data read_data(
	.ACLK(AXI_CLK_i),
	.ARESETn(AXI_RST_i),
	.AR_arbiter(AR_arbiter),
	.cs(cs),

	.RID_S0(RID_S0),
	.RDATA_S0(RDATA_S0),
	.RRESP_S0(RRESP_S0),
	.RLAST_S0(RLAST_S0),
	.RVALID_S0(RVALID_S0),

	.RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),

	.RID_S2(RID_S2),
	.RDATA_S2(RDATA_S2),
	.RRESP_S2(RRESP_S2),
	.RLAST_S2(RLAST_S2),
	.RVALID_S2(RVALID_S2),

	.RID_S3(RID_S3),
	.RDATA_S3(RDATA_S3),
	.RRESP_S3(RRESP_S3),
	.RLAST_S3(RLAST_S3),
	.RVALID_S3(RVALID_S3),

	.RID_S4(RID_S4),
	.RDATA_S4(RDATA_S4),
	.RRESP_S4(RRESP_S4),
	.RLAST_S4(RLAST_S4),
	.RVALID_S4(RVALID_S4),

	.RID_S5(RID_S5),
	.RDATA_S5(RDATA_S5),
	.RRESP_S5(RRESP_S5),
	.RLAST_S5(RLAST_S5),
	.RVALID_S5(RVALID_S5),

	.RID_M0(RID_M0),
	.RDATA_M0(RDATA_M0),
	.RRESP_M0(RRESP_M0),
	.RLAST_M0(RLAST_M0),
	.RVALID_M0(RVALID_M0),
	.RREADY_M0(RREADY_M0),

	.RID_M1(RID_M1),
	.RDATA_M1(RDATA_M1),
	.RRESP_M1(RRESP_M1),
	.RLAST_M1(RLAST_M1),
	.RVALID_M1(RVALID_M1),
	.RREADY_M1(RREADY_M1),

	.RREADY_S0(RREADY_S0),
	.RREADY_S1(RREADY_S1),
	.RREADY_S2(RREADY_S2),
	.RREADY_S3(RREADY_S3),
	.RREADY_S4(RREADY_S4),
	.RREADY_S5(RREADY_S5)
);

endmodule
