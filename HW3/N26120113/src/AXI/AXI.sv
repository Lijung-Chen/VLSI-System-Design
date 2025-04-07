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

module AXI(
	input ACLK,
	input ARESETn,
	// M0 (only read)
	input [`AXI_ID_BITS-1:0]          	ARID_M0,
	input [`AXI_ADDR_BITS-1:0]        	ARADDR_M0,
	input [`AXI_LEN_BITS-1:0]         	ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0]        	ARSIZE_M0,
	input [1:0]                       	ARBURST_M0,
	input                             	ARVALID_M0,
	output logic                      	ARREADY_M0,
	output logic [`AXI_ID_BITS-1:0]   	RID_M0,
	output logic [`AXI_DATA_BITS-1:0] 	RDATA_M0,
	output logic [1:0]                	RRESP_M0,
	output logic                      	RLAST_M0,
	output logic                      	RVALID_M0,
	input                             	RREADY_M0,
	// M1 (memory)
	input [`AXI_ID_BITS-1:0] 			AWID_M1,
	input [`AXI_ADDR_BITS-1:0] 			AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] 			AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] 			AWSIZE_M1,
	input [1:0] 						AWBURST_M1,
	input 								AWVALID_M1,
	output 								AWREADY_M1,
	input [`AXI_DATA_BITS-1:0] 			WDATA_M1,
	input [`AXI_STRB_BITS-1:0] 			WSTRB_M1,
	input 								WLAST_M1,
	input 								WVALID_M1,
	output 								WREADY_M1,
	output [`AXI_ID_BITS-1:0] 			BID_M1,
	output [1:0] 						BRESP_M1,
	output 								BVALID_M1,
	input 								BREADY_M1,

	input [`AXI_ID_BITS-1:0]          	ARID_M1,
	input [`AXI_ADDR_BITS-1:0]        	ARADDR_M1,
	input [`AXI_LEN_BITS-1:0]         	ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0]        	ARSIZE_M1,
	input [1:0]                       	ARBURST_M1,
	input                             	ARVALID_M1,
	output logic                      	ARREADY_M1,
	output logic [`AXI_ID_BITS-1:0]   	RID_M1,
	output logic [`AXI_DATA_BITS-1:0] 	RDATA_M1,
	output logic [1:0]                	RRESP_M1,
	output logic                      	RLAST_M1,
	output logic                      	RVALID_M1,
	input                             	RREADY_M1,

	// S0(ROM) only read
	output logic [`AXI_IDS_BITS-1:0]  	ARID_S0,
	output [`AXI_ADDR_BITS-1:0]       	ARADDR_S0,
	output [`AXI_LEN_BITS-1:0]        	ARLEN_S0,
	output [`AXI_SIZE_BITS-1:0]       	ARSIZE_S0,
	output [1:0]                      	ARBURST_S0,
	output logic                      	ARVALID_S0,
	input                             	ARREADY_S0,
	input [`AXI_IDS_BITS-1:0]         	RID_S0,
	input [`AXI_DATA_BITS-1:0]        	RDATA_S0,
	input [1:0]                       	RRESP_S0,
	input                             	RLAST_S0,
	input                             	RVALID_S0,
	output logic                      	RREADY_S0,

	// S1(IM)
	output logic [`AXI_IDS_BITS-1:0]  	AWID_S1,
	output [`AXI_ADDR_BITS-1:0]       	AWADDR_S1,
	output [`AXI_LEN_BITS-1:0]        	AWLEN_S1,
	output [`AXI_SIZE_BITS-1:0]       	AWSIZE_S1,
	output [1:0]                      	AWBURST_S1,
	output logic                      	AWVALID_S1,
	input                             	AWREADY_S1,
	output logic [`AXI_DATA_BITS-1:0] 	WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] 	WSTRB_S1,
	output logic                      	WLAST_S1,
	output logic                      	WVALID_S1,
	input                             	WREADY_S1,
	input [`AXI_IDS_BITS-1:0]         	BID_S1,
	input [1:0]                       	BRESP_S1,
	input                             	BVALID_S1,
	output logic                      	BREADY_S1,
	
	output logic [`AXI_IDS_BITS-1:0]  	ARID_S1,
	output [`AXI_ADDR_BITS-1:0]       	ARADDR_S1,
	output [`AXI_LEN_BITS-1:0]        	ARLEN_S1,
	output [`AXI_SIZE_BITS-1:0]       	ARSIZE_S1,
	output [1:0]                      	ARBURST_S1,
	output logic                      	ARVALID_S1,
	input                             	ARREADY_S1,
	input [`AXI_IDS_BITS-1:0]         	RID_S1,
	input [`AXI_DATA_BITS-1:0]        	RDATA_S1,
	input [1:0]                       	RRESP_S1,
	input                             	RLAST_S1,
	input                             	RVALID_S1,
	output logic                      	RREADY_S1,

	// S2(DM)
	output logic [`AXI_IDS_BITS-1:0]  AWID_S2,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S2,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S2,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S2,
	output [1:0]                      AWBURST_S2,
	output logic                      AWVALID_S2,
	input                             AWREADY_S2,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic                      WLAST_S2,
	output logic                      WVALID_S2,
	input                             WREADY_S2,
	input [`AXI_IDS_BITS-1:0]         BID_S2,
	input [1:0]                       BRESP_S2,
	input                             BVALID_S2,
	output logic                      BREADY_S2,

	output logic [`AXI_IDS_BITS-1:0]  ARID_S2,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S2,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S2,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S2,
	output logic [1:0]                ARBURST_S2,
	output logic                      ARVALID_S2,
	input                             ARREADY_S2,
	input [`AXI_IDS_BITS-1:0]         RID_S2,
	input [`AXI_DATA_BITS-1:0]        RDATA_S2,
	input [1:0]                       RRESP_S2,
	input                             RLAST_S2,
	input                             RVALID_S2,
	output logic                      RREADY_S2,

	// S3(sensor_ctrl)
	output logic [`AXI_IDS_BITS-1:0]  AWID_S3,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S3,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S3,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S3,
	output [1:0]                      AWBURST_S3,
	output logic                      AWVALID_S3,
	input                             AWREADY_S3,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output logic                      WLAST_S3,
	output logic                      WVALID_S3,
	input                             WREADY_S3,
	input [`AXI_IDS_BITS-1:0]         BID_S3,
	input [1:0]                       BRESP_S3,
	input                             BVALID_S3,
	output  logic                     BREADY_S3,
	
	output logic [`AXI_IDS_BITS-1:0]  ARID_S3,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S3,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S3,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S3,
	output logic [1:0]                ARBURST_S3,
	output logic                      ARVALID_S3,
	input                             ARREADY_S3,
	input [`AXI_IDS_BITS-1:0]         RID_S3,
	input [`AXI_DATA_BITS-1:0]        RDATA_S3,
	input [1:0]                       RRESP_S3,
	input                             RLAST_S3,
	input                             RVALID_S3,
	output logic                      RREADY_S3,

	// S4(WDT)
	output logic [`AXI_IDS_BITS-1:0]  AWID_S4,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S4,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S4,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S4,
	output [1:0]                      AWBURST_S4,
	output logic                      AWVALID_S4,
	input                             AWREADY_S4,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic                      WLAST_S4,
	output logic                      WVALID_S4,
	input                             WREADY_S4,
	input [`AXI_IDS_BITS-1:0]         BID_S4,
	input [1:0]                       BRESP_S4,
	input                             BVALID_S4,
	output logic                      BREADY_S4,

	output logic [`AXI_IDS_BITS-1:0]  ARID_S4,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S4,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S4,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S4,
	output [1:0]                      ARBURST_S4,
	output logic                      ARVALID_S4,
	input                             ARREADY_S4,
	input [`AXI_IDS_BITS-1:0]         RID_S4,
	input [`AXI_DATA_BITS-1:0]        RDATA_S4,
	input [1:0]                       RRESP_S4,
	input                             RLAST_S4,
	input                             RVALID_S4,
	output logic                      RREADY_S4,

    // S5(DRAM)
	output logic [`AXI_IDS_BITS-1:0]  AWID_S5,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S5,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S5,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S5,
	output [1:0]                      AWBURST_S5,
	output logic                      AWVALID_S5,
	input                             AWREADY_S5,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output logic                      WLAST_S5,
	output logic                      WVALID_S5,
	input                             WREADY_S5,
	input [`AXI_IDS_BITS-1:0]         BID_S5,
	input [1:0]                       BRESP_S5,
	input                             BVALID_S5,
	output logic                      BREADY_S5,
	
	output logic [`AXI_IDS_BITS-1:0]  ARID_S5,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S5,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S5,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S5,
	output [1:0]                      ARBURST_S5,
	output logic                      ARVALID_S5,
	input                             ARREADY_S5,
	input [`AXI_IDS_BITS-1:0]         RID_S5,
	input [`AXI_DATA_BITS-1:0]        RDATA_S5,
	input [1:0]                       RRESP_S5,
	input                             RLAST_S5,
	input                             RVALID_S5,
	output logic                      RREADY_S5
);

// ROM (S0)     0x0000_0000 ~ 0x0000_1FFF
// IM (S1)      0x0001_0000 ~ 0x0001_FFFF
// DM (S2)      0x0002_0000 ~ 0x0002_FFFF
// Sctrl (S3)   0x1000_0000 ~ 0x1000_03FF
// WDT (S4)     0x1001_0000 ~ 0x1001_03FF
// DRAM (S5)    0x2000_0000 ~ 0x201F_FFFF

logic [3:0] AW_arbiter, AR_arbiter;
logic [1:0] cs;
logic cs_w;

write_arbiter write_arbiter(   
	.ACLK(ACLK),
	.ARESETn(ARESETn),

	.AWADDR_M1(AWADDR_M1),
	.AWVALID_M1(AWVALID_M1),
	.WVALID_M1(WVALID_M1),
	.BVALID_M1(BVALID_M1),
	.BREADY_M1(BREADY_M1),

	.AW_arbiter(AW_arbiter),
	.cs_w(cs_w)
);

write_addr write_addr(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
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
	.ACLK(ACLK),
	.ARESETn(ARESETn),
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
	.ACLK(ACLK),
	.ARESETn(ARESETn),
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

read_arbiter read_arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),

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

read_addr read_addr(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
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
	.ACLK(ACLK),
	.ARESETn(ARESETn),
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
