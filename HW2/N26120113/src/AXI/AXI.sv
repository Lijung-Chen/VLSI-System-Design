//================================================
// Auther:      Chen Zhi-Yu (Willy)           
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`include "../include/AXI_define.svh"

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
	
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
	
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1
	
);

logic	[1:0]M1_W_access_S, M0_R_access_S, M1_R_access_S;
logic	M0M1_R_access_S0, M0M1_R_access_S1;
logic	[1:0]M0_R_cs, M1_R_cs, M0_R_ns, M1_R_ns, M1_W_cs, M1_W_ns;
logic	M1_read_S0, M1_read_S1, M0_read_S0, M0_read_S1;


//------------------------------Write handshake-----------------------------
always@(*)
if(~ARESETn)	M1_W_access_S = 2'd2;
else if(AWADDR_M1 <= 32'h0000_ffff && AWADDR_M1 >= 32'd0 && AWVALID_M1 == 1'b1)	M1_W_access_S = 2'd0;	//write accesss  slave0
else if(AWADDR_M1 <= 32'h0001_ffff && AWADDR_M1 >= 32'h0001_0000 && AWVALID_M1 == 1'b1)	M1_W_access_S = 2'd1;	//write accesss  slave1
else if(AWADDR_M1 >= 32'h0002_0000 && AWVALID_M1 == 1'b1)	M1_W_access_S = 2'd2;	//write default slave
else	M1_W_access_S = 2'd3;	//not write accesss any slave

always@(posedge ACLK or negedge ARESETn)
if(~ARESETn)	M1_W_cs <= 2'd0;
else	M1_W_cs <= M1_W_ns;

always@(*)
case(M1_W_cs)
	2'd0:	//wait write address
		if(M1_W_access_S == 2'd0 && AWREADY_S0 == 1'b1)	M1_W_ns = 2'd1;
		else if(M1_W_access_S == 2'd1 && AWREADY_S1 == 1'b1)	M1_W_ns = 2'd2;
		else	M1_W_ns = 2'd0;
	2'd1:	//write data to S0
		if(BVALID_S0 == 1'b1 && BREADY_M1 == 1'b1)	M1_W_ns = 2'd0;
		else	M1_W_ns = 2'd1;
	default:	//write data to S1
		if(BVALID_S1 == 1'b1 && BREADY_M1 == 1'b1)	M1_W_ns = 2'd0;
		else	M1_W_ns = 2'd2;
endcase

//------------------------------Read handshake---------------------------------
always@(*)
if(~ARESETn)	M1_R_access_S = 2'd3;
else if(ARADDR_M1 <= 32'h0000_ffff && ARADDR_M1 >= 32'd0 && ARVALID_M1 == 1'b1)	M1_R_access_S = 2'd0;	//read access slave0
else if(ARADDR_M1 <= 32'h0001_ffff && ARADDR_M1 >= 32'h0001_0000 && ARVALID_M1 == 1'b1)	M1_R_access_S = 2'd1;	//read access slave1
else if(ARADDR_M1 >= 32'h0002_0000 && ARVALID_M1 == 1'b1)	M1_R_access_S = 2'd2;	//read access default slave
else M1_R_access_S = 2'd3;	//not read any slave

always@(*)
if(~ARESETn)	M0_R_access_S = 2'd3;
else if(ARADDR_M0 <= 32'h0000_ffff && ARADDR_M0 >= 32'd0 && ARVALID_M0 == 1'b1)	M0_R_access_S = 2'd0;
else if(ARADDR_M0 <= 32'h0001_ffff && ARADDR_M0 >= 32'h0001_0000 && ARVALID_M0 == 1'b1)	M0_R_access_S = 2'd1;
else if(ARADDR_M0 >= 32'h0002_0000 && ARVALID_M0 == 1'b1)	M0_R_access_S = 2'd2;
else M0_R_access_S = 2'd3;


always@(*)
if(M1_R_access_S == 2'd0 && M0_R_access_S == 2'd0)	begin
	M0M1_R_access_S0 = 1'b1;
	M0M1_R_access_S1 = 1'b0;
end
else if(M1_R_access_S == 2'd1 && M0_R_access_S == 2'd1)	begin
	M0M1_R_access_S0 = 1'b0;
	M0M1_R_access_S1 = 1'b1;
end
else	begin
	M0M1_R_access_S0 = 1'b0;
	M0M1_R_access_S1 = 1'b0;
end

always@(posedge ACLK or negedge ARESETn)
if(~ARESETn)	begin
	M0_R_cs <= 2'd0;
	M1_R_cs <= 2'd0;
end
else begin
	M0_R_cs <= M0_R_ns;
	M1_R_cs <= M1_R_ns;
end

always@(*)
case (M0_R_cs)
	2'd0: //wait read address
		if(M0M1_R_access_S0 == 1'b1 || M0M1_R_access_S1 == 1'b1)	M0_R_ns = 2'd0;
		else if(M0_R_access_S == 2'd1)	M0_R_ns = (M1_R_cs != 2'd2)? 2'd2 : 2'd0;
		else if(M0_R_access_S == 2'd0) 	M0_R_ns = (M1_R_cs != 2'd1)? 2'd1 : 2'd0;
		else	M0_R_ns = 2'd0;
	2'd1:	//read data0
		M0_R_ns = (RVALID_S0 & RREADY_M0 & RLAST_S0)? 2'd0 : 2'd1;
	default:	//read data1
		M0_R_ns = (RVALID_S1 & RREADY_M0 & RLAST_S1)? 2'd0 : 2'd2;
endcase

always@(*)
case (M1_R_cs)
	2'd0: //wait read address
		if(M1_R_access_S == 2'd0)	M1_R_ns = (M0_R_cs != 2'd1)? 2'd1 : 2'd0;
		else if(M1_R_access_S == 2'd1)	M1_R_ns = (M0_R_cs != 2'd2)? 2'd2 : 2'd0;
		else	M1_R_ns = 2'd0;
	2'd1:	//read data0
		M1_R_ns = (RVALID_S0 & RREADY_M1 & RLAST_S0)? 2'd0 : 2'd1;
	default:	//read data1
		M1_R_ns = (RVALID_S1 & RREADY_M1 & RLAST_S1)? 2'd0 : 2'd2;
endcase

//===============SLAVE INTERFACE FOR MASTERS=====================
//Write?
always@(*)
if(M1_W_access_S == 2'd0)	AWREADY_M1 = AWREADY_S0;
else if(M1_W_access_S == 2'd1)	AWREADY_M1 = AWREADY_S1;
else	AWREADY_M1 = 1'b0;

always @(*) begin
case(M1_W_cs)
	2'd0:begin
		WREADY_M1 = (M1_W_access_S == 2'd0)? WREADY_S0 : ((M1_W_access_S == 2'd1) ? WREADY_S1 : 1'b0);

		BID_M1 = (M1_W_access_S == 2'd0)? BID_S0 : BID_S1;
		BRESP_M1 = (M1_W_access_S == 2'd0)? BRESP_S0 : ((M1_W_access_S == 2'd1) ? BRESP_S1 : `AXI_RESP_DECERR);
		BVALID_M1 = 1'b0;
	end
	2'd1:begin
		WREADY_M1 = WREADY_S0;

		BID_M1 = BID_S0;
		BRESP_M1 = BRESP_S0;
		BVALID_M1 = BVALID_S0;
	end
	default:begin
		WREADY_M1 = WREADY_S1;

		BID_M1 = BID_S1;
		BRESP_M1 = BRESP_S1;
		BVALID_M1 = BVALID_S1;
	end
endcase
end


//-------Read(IM)--------

always@(*)
case(M0_R_cs)
2'd0:begin
	//ARREADY_M0 = (M0M1_R_access_S0 == 1'b1 || M0M1_R_access_S1 == 1'b1)? 1'b0 : ((M0_R_access_S == 2'd1)? ARREADY_S1 : ARREADY_S0);
	ARREADY_M0 = (M0M1_R_access_S0 == 1'b1 || M0M1_R_access_S1 == 1'b1 || M0_R_access_S == 2'd2)? 1'b0 : ((M0_R_access_S == 2'd1)? ARREADY_S1 : ARREADY_S0);	
	RID_M0 = RID_S0;
	RDATA_M0 = RDATA_S0;
	RRESP_M0 = (M0_R_access_S == 2'd2)? `AXI_RESP_DECERR : `AXI_RESP_OKAY;
	RLAST_M0 = 1'b0 ;
	RVALID_M0 = 1'b0;
end
2'd1:begin
	ARREADY_M0 = ARREADY_S0;
	RID_M0 = RID_S0;
	RDATA_M0 = RDATA_S0;
	RRESP_M0 = RRESP_S0;
	RLAST_M0 = RLAST_S0;
	RVALID_M0 = RVALID_S0;
end
default:begin
	ARREADY_M0 = ARREADY_S1;
	RID_M0 = RID_S1;
	RDATA_M0 = RDATA_S1;
	RRESP_M0 = RRESP_S1;
	RLAST_M0 = RLAST_S1;
	RVALID_M0 = RVALID_S1;
end
endcase

//--------Read(DM)------------
always@(*)
case(M1_R_cs)
2'd0:begin
	ARREADY_M1 = (M1_R_access_S == 2'd0)? ARREADY_S0 : ((M1_R_access_S == 2'd1)? ARREADY_S1 : 1'b0);
	RID_M1 = RID_S0;
	RDATA_M1 = RDATA_S0;
	RRESP_M1 = (M1_R_access_S == 2'd2)? `AXI_RESP_DECERR : `AXI_RESP_OKAY;
	RLAST_M1 = 1'b0;
	RVALID_M1 = 1'b0;
end
2'd1:begin
	ARREADY_M1 = ARREADY_S0;
	RID_M1 = RID_S0;
	RDATA_M1 = RDATA_S0;
	RRESP_M1 = RRESP_S0;
	RLAST_M1 = RLAST_S0;
	RVALID_M1 = RVALID_S0;
end
default:begin
	ARREADY_M1 = ARREADY_S1;
	RID_M1 = RID_S1;
	RDATA_M1 = RDATA_S1;
	RRESP_M1 = RRESP_S1;
	RLAST_M1 = RLAST_S1;
	RVALID_M1 = RVALID_S1;
end
endcase

//================MASTER INTERFACE FOR SLAVES================
//Write(IM/S0)
always@(*)
case(M1_W_cs)
	2'd0:begin
		AWID_S0 = AWID_M1;
		AWADDR_S0 = AWADDR_M1;
		AWLEN_S0 = AWLEN_M1;
		AWSIZE_S0 = AWSIZE_M1;
		AWBURST_S0 = AWBURST_M1;
		AWVALID_S0 = (M1_W_access_S == 2'd0)? AWVALID_M1 : 1'b0;

		WDATA_S0 = WDATA_M1;
		WSTRB_S0 = (M1_W_access_S == 2'd0)? WSTRB_M1 : 4'b0000;
		WLAST_S0 = (M1_W_access_S == 2'd0)? WLAST_M1 : 1'b0;
		WVALID_S0 = (M1_W_access_S == 2'd0)? WVALID_M1 : 1'b0;

		BREADY_S0 = BREADY_M1;
	end
	2'd1:begin
		AWID_S0 = AWID_M1;
		AWADDR_S0 = AWADDR_M1;
		AWLEN_S0 = AWLEN_M1;
		AWSIZE_S0 = AWSIZE_M1;
		AWBURST_S0 = AWBURST_M1;
		AWVALID_S0 = AWVALID_M1;

		WDATA_S0 = WDATA_M1;
		WSTRB_S0 = WSTRB_M1;
		WLAST_S0 = WLAST_M1;
		WVALID_S0 = WVALID_M1;

		BREADY_S0 = BREADY_M1;
	end
	default:begin
		AWID_S0 = AWID_M1;
		AWADDR_S0 = AWADDR_M1;
		AWLEN_S0 = AWLEN_M1;
		AWSIZE_S0 = AWSIZE_M1;
		AWBURST_S0 = AWBURST_M1;
		AWVALID_S0 = 1'b0;

		WDATA_S0 = WDATA_M1;
		WSTRB_S0 = 4'b0000;
		WLAST_S0 = 1'b0;
		WVALID_S0 = 1'b0;

		BREADY_S0 = BREADY_M1;
	end
endcase


//Write(DM/S1)
always@(*)
case(M1_W_cs)
	2'd0:begin
		AWID_S1 = AWID_M1;
		AWADDR_S1 = AWADDR_M1;
		AWLEN_S1 = AWLEN_M1;
		AWSIZE_S1 = AWSIZE_M1;
		AWBURST_S1 = AWBURST_M1;
		AWVALID_S1 = (M1_W_access_S == 2'd1)? AWVALID_M1 : 1'b0;

		WDATA_S1 = WDATA_M1;
		WSTRB_S1 = (M1_W_access_S == 2'd1)? WSTRB_M1 : 4'b0000;
		WLAST_S1 = (M1_W_access_S == 2'd1)? WLAST_M1 : 1'b0;
		WVALID_S1 = (M1_W_access_S == 2'd1)? WVALID_M1 : 1'b0;

		BREADY_S1 = BREADY_M1;
	end
	2'd1:begin
		AWID_S1 = AWID_M1;
		AWADDR_S1 = AWADDR_M1;
		AWLEN_S1 = AWLEN_M1;
		AWSIZE_S1 = AWSIZE_M1;
		AWBURST_S1 = AWBURST_M1;
		AWVALID_S1 = 1'b0;

		WDATA_S1 = WDATA_M1;
		WSTRB_S1 = 4'b0000;
		WLAST_S1 = 1'b0;
		WVALID_S1 = 1'b0;

		BREADY_S1 = BREADY_M1;
	end
	default:begin
		AWID_S1 = AWID_M1;
		AWADDR_S1 = AWADDR_M1;
		AWLEN_S1 = AWLEN_M1;
		AWSIZE_S1 = AWSIZE_M1;
		AWBURST_S1 = AWBURST_M1;
		AWVALID_S1 = AWVALID_M1;

		WDATA_S1 = WDATA_M1;
		WSTRB_S1 = WSTRB_M1;
		WLAST_S1 = WLAST_M1;
		WVALID_S1 = WVALID_M1;

		BREADY_S1 = BREADY_M1;
	end
endcase


//Read(IM)


assign M1_read_S0 = (M1_R_cs == 2'd1) || (M1_R_cs == 2'd0 && M0_R_cs != 2'd1 && M1_R_access_S == 2'd0);
assign M0_read_S0 = (M0_R_cs == 2'd1) || (M0_R_cs == 2'd0 && M0M1_R_access_S0 == 1'b0 && M0_R_access_S == 2'd0 && M1_R_cs != 2'd1);


always@(*)
if(M1_read_S0)begin
	ARID_S0 = ARID_M1;
	ARADDR_S0 = ARADDR_M1;
	ARLEN_S0 = ARLEN_M1;
	ARSIZE_S0 = ARSIZE_M1;
	ARBURST_S0 = ARBURST_M1;
	ARVALID_S0 = ARVALID_M1;
	RREADY_S0 = RREADY_M1;
end
else if(M0_read_S0)begin
	ARID_S0 = ARID_M0;
	ARADDR_S0 = ARADDR_M0;
	ARLEN_S0 = ARLEN_M0;
	ARSIZE_S0 = ARSIZE_M0;
	ARBURST_S0 = ARBURST_M0;
	ARVALID_S0 = ARVALID_M0;
	RREADY_S0 = RREADY_M0;
end
else begin
	ARID_S0 = ARID_M0;
	ARADDR_S0 = ARADDR_M0;
	ARLEN_S0 = ARLEN_M0;
	ARSIZE_S0 = ARSIZE_M0;
	ARBURST_S0 = ARBURST_M0;
	ARVALID_S0 = 1'b0;
	RREADY_S0 = 1'b0;
end


//Read(DM)

assign M1_read_S1 = (M1_R_cs == 2'd2) || (M1_R_cs == 2'd0 && M0_R_cs != 2'd2 && M1_R_access_S == 2'd1);
assign M0_read_S1 = (M0_R_cs == 2'd2) || (M0_R_cs == 2'd0 && M0M1_R_access_S1 == 1'b0 && M0_R_access_S == 2'd1 && M1_R_cs != 2'd2);


always@(*)
if(M1_read_S1)	begin
	ARID_S1 = ARID_M1;
	ARADDR_S1 = ARADDR_M1;
	ARLEN_S1 = ARLEN_M1;
	ARSIZE_S1 = ARSIZE_M1;
	ARBURST_S1 = ARBURST_M1;
	ARVALID_S1 = ARVALID_M1;
	RREADY_S1 = RREADY_M1;
end
else if(M0_read_S1)	begin
	ARID_S1 = ARID_M0;
	ARADDR_S1 = ARADDR_M0;
	ARLEN_S1 = ARLEN_M0;
	ARSIZE_S1 = ARSIZE_M0;
	ARBURST_S1 = ARBURST_M0;
	ARVALID_S1 = ARVALID_M0;
	RREADY_S1 = RREADY_M0;
end
else	begin
	ARID_S1 = ARID_M0;
	ARADDR_S1 = ARADDR_M0;
	ARLEN_S1 = ARLEN_M0;
	ARSIZE_S1 = ARSIZE_M0;
	ARBURST_S1 = ARBURST_M0;
	ARVALID_S1 = 1'b0;
	RREADY_S1 = 1'b0;
end

endmodule
