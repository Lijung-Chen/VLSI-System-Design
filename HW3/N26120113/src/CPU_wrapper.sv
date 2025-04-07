`include "./CPU/CPU.sv"
`include "../include/AXI_define.svh"

module  CPU_wrapper(
    input 	clk,
    input 	rst,

	//interrupt signal
	input	SENSOR_CTRL_interrupt,
	input	WDT_interrupt,

    //SLAVE INTERFACE FOR MASTERS
	//M1 WRITE ADDRESS
	output logic [`AXI_ID_BITS-1:0] AWID_M1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output logic [1:0] AWBURST_M1,
	output logic AWVALID_M1,
	input AWREADY_M1,
	
	//M1 WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output logic WLAST_M1,
	output logic WVALID_M1,
	input WREADY_M1,
	
	//M1 WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M1,
	input [1:0] BRESP_M1,
	input BVALID_M1,
	output logic BREADY_M1,

	//M0 READ ADDRESS
	output logic [`AXI_ID_BITS-1:0] ARID_M0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	output logic [1:0] ARBURST_M0,
	output logic ARVALID_M0,
	input ARREADY_M0,
	
	//M0 READ DATA
	input [`AXI_ID_BITS-1:0] RID_M0,
	input [`AXI_DATA_BITS-1:0] RDATA_M0,
	input [1:0] RRESP_M0,
	input RLAST_M0,
	input RVALID_M0,
	output logic RREADY_M0,
	
	//M1 READ ADDRESS
	output logic [`AXI_ID_BITS-1:0] ARID_M1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output logic [1:0] ARBURST_M1,
	output logic ARVALID_M1,
	input ARREADY_M1,
	
	//M1 READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M1,
	input [`AXI_DATA_BITS-1:0] RDATA_M1,
	input [1:0] RRESP_M1,
	input RLAST_M1,
	input RVALID_M1,
	output logic RREADY_M1
);

logic    [31:0]inst_PC, DM_A, DM_DI, WDATA_M1_reg, ins_reg;
logic    DM_OE, IM_busy, DM_busy, M1_R_cs, M1_R_ns, ID_EX_MemWrite, EX_MEM_MemWrite, ID_EX_MemRead, EX_MEM_MemRead, M1_read, M1_write;
logic	[1:0]M1_W_cs, M1_W_ns, M0_R_cs, M0_R_ns;
logic    [3:0]DM_WEB, WSTRB, DM_WEB_reg;
logic	[3:0]W_transfer_count;

logic	[`AXI_DATA_BITS-1:0] RDATA_m1;
logic	RLAST_m1;
logic	RVALID_m1;


//=====================SLAVE INTERFACE FOR MASTERS=======================
//--------------------------M1 WRITE ADDRESS-------------------------
always@(posedge clk)
	if(rst)	M1_W_cs <= 2'd0;
	else	M1_W_cs <= M1_W_ns;

always@(*)
case(M1_W_cs)
	2'd0: //write addr
		if(AWVALID_M1)	M1_W_ns = (AWREADY_M1)? 2'd1 : 2'd0;
		else	M1_W_ns = 2'd0;
	2'd1:	//write data
		M1_W_ns = (WVALID_M1)? ((WREADY_M1)? 2'd3 : 2'd2) : 2'd1;
	2'd2:	M1_W_ns = (WREADY_M1)? 2'd3 : 2'd2;
	default:	//write response
		M1_W_ns = (BVALID_M1 & BREADY_M1)? 2'd0 : 2'd3;
endcase

assign  AWID_M1 = 4'd1;
assign  AWLEN_M1 = 4'd0;    //burst lengh = 1
assign  AWSIZE_M1 = `AXI_SIZE_WORD;   //burst size = 4 byte
assign  AWBURST_M1 = `AXI_BURST_INC;  //INCR type
assign  AWVALID_M1 = (M1_W_cs != 2'd0)? 1'b0 : EX_MEM_MemWrite;	
assign  AWADDR_M1 = DM_A;   

//---------------------------M1 WRITE DATA------------------------------
assign  WVALID_M1 = (M1_W_cs == 2'd0 || M1_W_cs == 2'd3)? 1'b0 : EX_MEM_MemWrite;


always@(posedge clk)
	if(rst)	WDATA_M1_reg <= 32'd0;
	else if(WVALID_M1) WDATA_M1_reg <= DM_DI;
	else WDATA_M1_reg <= WDATA_M1_reg;

assign	WDATA_M1 = (M1_W_cs == 2'd2)? WDATA_M1_reg : DM_DI;


always@(posedge clk)
	if(rst)	DM_WEB_reg <= 4'b0000;
	else if(WVALID_M1)	DM_WEB_reg <= {~DM_WEB[3],~DM_WEB[2],~DM_WEB[1],~DM_WEB[0]};
	else	DM_WEB_reg <= DM_WEB_reg;

always@(*)
case(M1_W_cs)
	2'd0:	WSTRB_M1 = 4'b0000;
	2'd1:	WSTRB_M1 = {~DM_WEB[3],~DM_WEB[2],~DM_WEB[1],~DM_WEB[0]};
	2'd2: WSTRB_M1 = DM_WEB_reg;
	default: WSTRB_M1 = 4'b0000;

endcase


always@(posedge clk)
  if(rst) W_transfer_count <= 4'd0;
  else if(AWVALID_M1 & AWREADY_M1) W_transfer_count <= 4'd0;
  else if(WVALID_M1 & WREADY_M1)  W_transfer_count <= W_transfer_count + 1;
  else  W_transfer_count <= W_transfer_count;


assign  WLAST_M1 = WVALID_M1 & (W_transfer_count == AWLEN_M1);	

//---------------------------M1 WRITE RESPONSE----------------------------
always@(posedge clk)
	if(rst)	BREADY_M1 <= 1'b0;
	else if(AWVALID_M1 & AWREADY_M1)	BREADY_M1 <= 1'b1;
	else if(BVALID_M1 & BREADY_M1)	BREADY_M1 <= 1'b0;
	else	BREADY_M1 <= BREADY_M1;

//---------------------------M0 READ ADDRESS------------------------------
always@(posedge clk)
	if(rst)	M0_R_cs <= 2'd0;
	else	M0_R_cs <= M0_R_ns;

always@(*)
case(M0_R_cs)
2'd0:	M0_R_ns = 2'd1;
2'd1:	M0_R_ns = (ARVALID_M0 & ARREADY_M0)? 2'd2 : 2'd1;
default:	M0_R_ns = (RLAST_M0 & RREADY_M0 & RVALID_M0)? 2'd1 : 2'd2;
endcase

assign  ARID_M0 = 4'd0;
assign  ARLEN_M0 = 4'd0;    //burst lengh = 1
assign  ARSIZE_M0 = `AXI_SIZE_WORD;   //burst size = 4 byte
assign  ARBURST_M0 = `AXI_BURST_INC;  //INCR type
//assign	ARVALID_M0 = (M0_R_cs != 2'd1)? 1'b0 : 1'b1;	///////
assign	ARVALID_M0 = (M0_R_cs != 2'd1 || DM_busy)? 1'b0 : 1'b1;
	
assign  ARADDR_M0 = inst_PC;

//------------------------------M0 READ DATA-------------------------
assign  RREADY_M0 = 1'b1; ///////
//assign  RREADY_M0 = ~DM_busy  || (~M1_R_cs & EX_MEM_MemRead);

//-----------------------------M1 READ ADDRESS-----------------------
always@(posedge clk)
	if(rst)	M1_R_cs <= 1'd0;
	else	M1_R_cs <= M1_R_ns;
always@(*)
case(M1_R_cs)
1'd0:	M1_R_ns = (ARVALID_M1 & ARREADY_M1)? 1'd1 : 1'd0;
default:	M1_R_ns = (RLAST_M1 & RREADY_M1 & RVALID_M1)? 1'd0 :1'd1;
endcase

assign  ARID_M1 = 4'd1;
assign  ARLEN_M1 = 4'd0;    //burst lengh = 1
assign  ARSIZE_M1 = `AXI_SIZE_WORD;   //burst size = 4 byte
assign  ARBURST_M1 = `AXI_BURST_INC;  //INCR type

assign  ARVALID_M1 = (M1_R_cs)? 1'b0 : EX_MEM_MemRead;	

assign  ARADDR_M1 = DM_A;

//----------------------------M1 READ DATA---------------------------
assign  RREADY_M1 = EX_MEM_MemRead; 


//===========================Stall signal to CPU==============================

/*
//****
assign	DM_busy =	//Store 
						AWVALID_M1
					|| (AWVALID_M1 == 1 && AWREADY_M1 == 0)
					|| (M1_W_cs != 2'd0 & ~BVALID_M1)
					//Load
					|| ARVALID_M1
					|| (ARVALID_M1 == 1 && ARREADY_M1 == 0)
					|| (M1_R_cs & ~RVALID_M1);
*/
assign	DM_busy =	//Store 
					//	AWVALID_M1
					//|| (M1_W_cs == 2'd0 & EX_MEM_MemWrite & ~AWREADY_M1)
					   (M1_W_cs == 2'd0 & EX_MEM_MemWrite)
					|| (M1_W_cs != 2'd0 & ~BVALID_M1)
					//Load
					//|| ARVALID_M1
					//|| (~M1_R_cs & EX_MEM_MemRead & ~ARREADY_M1)
					|| (~M1_R_cs & EX_MEM_MemRead)
					|| (M1_R_cs & ~RVALID_M1);


always@(posedge clk)
if(rst)	IM_busy <= 1'b1;
else if( M0_R_cs == 2'd2 || (ARVALID_M0 && ~ARREADY_M0))	IM_busy <= 1'b1;
else	IM_busy <= 1'b0;

logic	ID_flush;
assign	ID_flush = IM_busy & ~RVALID_M0;



CPU cpu(//INPUT
		.clk(clk),
        .rst(rst),
		.ID_flush(ID_flush),
		.IM_busy(IM_busy),
		.DM_busy(DM_busy),
		.RVALID_M0(RVALID_M0),
		.SENSOR_CTRL_interrupt(SENSOR_CTRL_interrupt),
		.WDT_interrupt(WDT_interrupt),
        .MEMReadInst(RDATA_M0),
        .MEMReadData(RDATA_M1),
		//OUTPUT
        .inst_PC(inst_PC),
        .DM_A(DM_A),
        .DM_WEB(DM_WEB),
        .DM_DI(DM_DI),
		.ID_EX_MemWrite(ID_EX_MemWrite),
		.EX_MEM_MemWrite(EX_MEM_MemWrite),
		.ID_EX_MemRead(ID_EX_MemRead),
		.EX_MEM_MemRead(EX_MEM_MemRead)
);

endmodule

