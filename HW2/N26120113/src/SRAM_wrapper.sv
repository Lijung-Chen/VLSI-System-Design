`include "../include/AXI_define.svh"

module SRAM_wrapper (
  input CK,
  input rst,

  //MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,
	
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY
);
wire  CS;
wire  OE;
wire  [3:0] WEB;
wire  [13:0] A;
wire  [31:0] DI;
wire  [31:0] DO;

logic [1:0]R_cs, R_ns;
logic A_select;
logic [31:0]ARADDR_reg, AWADDR_reg, AW, AR, DI_reg, RDATA_reg;
logic [3:0]WEB_reg;
logic	[3:0]R_transfer_count, ARLEN_reg;
logic [`AXI_IDS_BITS-1:0]BID_reg, RID_reg;


//========================MASTER INTERFACE FOR SLAVES======================
//WRITE ADDRESS(Can not write before data write successfully)

always@(posedge CK or posedge rst)
  if(rst) AWREADY <= 1'b1;
  //else if((BVALID & BREADY) | RLAST)  AWREADY <= 1'b1; //??
  else if((BVALID & BREADY) | (RVALID & RLAST & RREADY))  AWREADY <= 1'b1;
  else if((AWVALID & AWREADY) | (ARVALID & ARREADY)) AWREADY <= 1'b0; 
  else  AWREADY <= AWREADY;

//WRITE DATA
always@(posedge CK or posedge rst)
  if(rst) WREADY <= 1'b1;
  //else if(WLAST)  WREADY <= 1'b0;
  else if(WLAST & WREADY)  WREADY <= 1'b0;
  else if(BVALID & BREADY)  WREADY <= 1'b1;
  else  WREADY <= WREADY;

//assign  WREADY = (ARVALID & ARREADY)? 1'b0 : 1'b1;

//WRITE RESPONSE
always@(posedge CK or posedge rst)
  if(rst) BID_reg <= 8'd0;
  else if(AWVALID & AWREADY)  BID_reg <= AWID;
  else  BID_reg <= BID_reg;

assign  BID = (AWVALID & AWREADY)? AWID : BID_reg;


assign  BRESP = `AXI_RESP_OKAY;  

always@(posedge CK or posedge rst)
  if(rst) BVALID <= 1'b0;
  //else if(WLAST)  BVALID <= 1'b1;
  else if(WLAST & WREADY & WVALID)  BVALID <= 1'b1;
  else if(~BREADY & BVALID) BVALID <= 1'b1;
  else BVALID <= 1'b0;

//READ ADDRESS(Can not read before data write successfully)
always@(posedge CK or posedge rst)
  if(rst) ARREADY <= 1'b1;
  //else if((BVALID & BREADY) | RLAST)  ARREADY <= 1'b1;
  else if((BVALID & BREADY) | (RVALID & RLAST & RREADY))	ARREADY <= 1'b1;
  else if((AWVALID & AWREADY) | (ARVALID & ARREADY)) ARREADY <= 1'b0; 
  else  ARREADY <= ARREADY;

always@(posedge CK or posedge rst)
	if(rst) ARLEN_reg <= 4'd0;
	else if(ARVALID & ARREADY)	ARLEN_reg <= ARLEN;
	else	ARLEN_reg <= ARLEN_reg;

//READ DATA
//assign  RID = ARID;
always@(posedge CK or posedge rst)
  if(rst) RID_reg <= 8'd0;
  else if(ARVALID & ARREADY)  RID_reg <= ARID;
  else  RID_reg <= RID_reg;

assign  RID = (ARVALID & ARREADY)? ARID : RID_reg;

assign  RRESP = `AXI_RESP_OKAY;

always@(posedge CK or posedge rst)
  if(rst) R_transfer_count <= 4'd0;
  else if(ARVALID & ARREADY) R_transfer_count <= 4'd0;
  else if(RVALID & RREADY)  R_transfer_count <= R_transfer_count + 1;
  else  R_transfer_count <= R_transfer_count;

//assign  RLAST = RVALID & RREADY;
assign  RLAST = RVALID & (R_transfer_count == ARLEN_reg);

always@(posedge CK or posedge rst)
  if(rst) RVALID <= 1'b0;
  else if(ARVALID & ARREADY) RVALID <= 1'b1; 
  else if(RVALID & ~RREADY)	RVALID <= 1'b1;
  //else if(RVALID & ~RLAST)	RVALID <= 1'b1;
  else  RVALID <= 1'b0;

//assign  RDATA = DO;

always@(posedge CK or posedge rst)
if(rst) R_cs <= 1'd0;
else R_cs <= R_ns;

always@(*)
case(R_cs)
2'd0:
  R_ns = (ARVALID & ARREADY)? 2'd1 : 2'd0;
2'd1:
  R_ns = (RVALID)? ((RLAST)? 2'd0 :2'd2) : 2'd1;
default:
  R_ns = (RREADY)? ((RLAST)? 2'd0 : 2'd1) : 2'd2;
endcase

always@(posedge CK or posedge rst)
if(rst)	RDATA_reg <= 32'd0;
else if(R_cs == 2'd1 && RVALID == 1'b1)	RDATA_reg <= DO;
else RDATA_reg <= RDATA_reg;

assign  RDATA = (R_cs == 2'd1 && RVALID == 1'b1)? DO : RDATA_reg;
//============================END==============================
/*
always@(posedge CK or posedge rst)
  if(rst) A_select <= 2'd0;
  else if(AWVALID & AWREADY) A_select <= 1'b1;
  else if(WLAST)  A_select <= 1'b0;
  else  A_select <= A_select;
*/
  assign  A_select = WVALID & WREADY;


assign  AR = (ARVALID & ARREADY)? ARADDR : ARADDR_reg;
always@(posedge CK or posedge rst)
  if(rst) ARADDR_reg <= 32'd0;
  else ARADDR_reg <= AR;
/*
assign  AW = (AWVALID & AWREADY)? AWADDR : AWADDR_reg;
always@(posedge CK or posedge rst)
  if(rst) AWADDR_reg <= 32'd0;
  else AWADDR_reg <= AW;

assign  A = (A_select)? AW[15:2] : AR[15:2];
*/
always@(posedge CK or posedge rst)
  if(rst) AWADDR_reg <= 32'd0;
  else AWADDR_reg <= (AWVALID & AWREADY)? AWADDR : AWADDR_reg;

assign  A = (A_select)? AWADDR_reg[15:2] : AR[15:2];


assign  WEB = {~WSTRB[3],~WSTRB[2],~WSTRB[1],~WSTRB[0]};  
assign  DI = WDATA;

assign  OE = RVALID;
assign  CS = 1'b1;


  SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (CK    ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (CS    )
  );

endmodule
