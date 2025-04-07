`include "./CPU/CPU.sv"
`include "../include/AXI_define.svh"
`include "../include/def.svh"
`include "L1C_inst.sv"
`include "L1C_data.sv"

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
logic	cacheable;
logic [1:0] wait_DM_cs, wait_DM_ns;
logic [`DATA_BITS-1:0] L1CI_INST_reg;
logic [`DATA_BITS-1:0] MEMReadInst;

//------------L1CI-------------
logic [`DATA_BITS-1:0] L1CI_ADDR;
// Mem to CPU wrapper
logic I_wait;
// CPU wrapper to core
logic [`DATA_BITS-1:0] L1CI_INST;
logic I_core_wait;
// CPU wrapper to Mem
logic I_req;
logic [`DATA_BITS-1:0] I_addr;
logic I_write;
logic [`DATA_BITS-1:0] I_in;
logic [`CACHE_TYPE_BITS-1:0] I_type;

//------------L1CD--------------
logic [3:0] L1CD_WEB;
logic [`DATA_BITS-1:0] L1CD_ADDR;
logic L1CD_req;
logic L1CD_write;
logic [`DATA_BITS-1:0] L1CD_WDATA;
logic [`CACHE_TYPE_BITS-1:0] D_core_type;
// Mem to CPU wrapper
logic D_wait;
// CPU wrapper to core
logic [`DATA_BITS-1:0] L1CD_DATA;
logic D_core_wait;
// CPU wrapper to Mem
logic D_req;
logic [`DATA_BITS-1:0] D_addr;
logic D_write;
logic [`DATA_BITS-1:0] D_WDATA;
logic [`CACHE_TYPE_BITS-1:0] D_type;


assign	cacheable = (ARADDR_M1[31:16] != 16'h1000);

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
	2'd2:	//write data
		M1_W_ns = (WREADY_M1)? 2'd3 : 2'd2;
	default:	//write response
		M1_W_ns = (BVALID_M1 & BREADY_M1)? 2'd0 : 2'd3;
endcase

assign  AWID_M1 = 4'd1;
assign  AWLEN_M1 = 4'd0;    //burst lengh = 1
assign  AWSIZE_M1 = `AXI_SIZE_WORD;   //burst size = 4 byte
assign  AWBURST_M1 = `AXI_BURST_INC;  //INCR type
assign  AWVALID_M1 = (M1_W_cs != 2'd0)? 1'b0 : D_write;  
assign  AWADDR_M1 = D_addr;  

//---------------------------M1 WRITE DATA------------------------------
assign  WVALID_M1 = (M1_W_cs == 2'd0 || M1_W_cs == 2'd3)? 1'b0 : D_write;


always@(posedge clk)
	if(rst)	WDATA_M1_reg <= 32'd0;
	else if(WVALID_M1) WDATA_M1_reg <= D_WDATA;
	else WDATA_M1_reg <= WDATA_M1_reg;

assign	WDATA_M1 = (M1_W_cs == 2'd2)? WDATA_M1_reg : D_WDATA;


always@(posedge clk)
	if(rst)	DM_WEB_reg <= 4'b0000;
	else if(WVALID_M1)	DM_WEB_reg <= {~L1CD_WEB[3],~L1CD_WEB[2],~L1CD_WEB[1],~L1CD_WEB[0]};
	else	DM_WEB_reg <= DM_WEB_reg;

always@(*)
case(M1_W_cs)
	2'd0:	WSTRB_M1 = 4'b0000;
	2'd1:	WSTRB_M1 = {~L1CD_WEB[3],~L1CD_WEB[2],~L1CD_WEB[1],~L1CD_WEB[0]};
	2'd2: 	WSTRB_M1 = DM_WEB_reg;
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
//assign  ARLEN_M0 = 4'd0;    //burst lengh = 1
assign  ARLEN_M0 = 4'd3;    //burst lengh = 4
assign  ARSIZE_M0 = `AXI_SIZE_WORD;   //burst size = 4 byte
assign  ARBURST_M0 = `AXI_BURST_INC;  //INCR type

assign	ARVALID_M0 = (M0_R_cs != 2'd1)? 1'b0 : I_req;
	
assign  ARADDR_M0 = I_addr;

//------------------------------M0 READ DATA-------------------------
assign  RREADY_M0 = 1'b1; 

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
//assign  ARLEN_M1 = 4'd0;    //burst lengh = 1
assign  ARLEN_M1 = (cacheable)? 4'd3 : 4'd0;    //burst lengh = 4
assign  ARSIZE_M1 = `AXI_SIZE_WORD;   //burst size = 4 byte
assign  ARBURST_M1 = `AXI_BURST_INC;  //INCR type

assign  ARVALID_M1 = (M1_R_cs)? 1'b0 : D_req;	

assign  ARADDR_M1 = D_addr;

//----------------------------M1 READ DATA---------------------------
assign  RREADY_M1 = D_req;


//===========================Core type to D Cache==============================
always_comb	begin
	case(L1CD_WEB)
		4'b0000:	D_core_type = `CACHE_WORD;
		4'b1100:	D_core_type = `CACHE_HWORD;
		4'b0011:	D_core_type = `CACHE_HWORD;
		4'b1110:	D_core_type = `CACHE_BYTE;
		4'b1101:	D_core_type = `CACHE_BYTE;
		4'b1011:	D_core_type = `CACHE_BYTE;
		4'b0111:	D_core_type = `CACHE_BYTE;
		default:	D_core_type = `CACHE_WORD;
	endcase
end

//===========================busy signal to Cache=======================
//IM is busy
assign	I_wait = (M0_R_cs == 2'd2 & ~RVALID_M0) | ARVALID_M0;

//DM is busy
assign	D_wait = //Store
				//(M1_W_cs == 2'd0 & D_write)
				 (M1_W_cs == 2'd0 & L1CD_write)
				| (M1_W_cs != 2'd0 & ~BVALID_M1)
				//Load
				| (~M1_R_cs & D_req)
				| (M1_R_cs & ~RVALID_M1);

//===========================instruction buffer===========================
always_ff@(posedge clk)
if(rst)	wait_DM_cs <= 2'd0;
else 	wait_DM_cs <= wait_DM_ns;

always_comb
case(wait_DM_cs)
	2'd0:	wait_DM_ns = (D_core_wait)? 2'd1 : 2'd0;
	default:	wait_DM_ns = (D_core_wait)? 2'd1 : 2'd0;
endcase

always_ff@(posedge clk)
if(rst)	L1CI_INST_reg <= 32'd0;
else if(wait_DM_cs == 2'd0)	L1CI_INST_reg <= L1CI_INST;
else	L1CI_INST_reg <=  L1CI_INST_reg;

assign	MEMReadInst = (wait_DM_cs == 2'd0 || wait_DM_cs == 2'd1 && ~D_core_wait)? L1CI_INST : L1CI_INST_reg;



CPU cpu(
	//INPUT
	.clk					( clk				),
	.rst					( rst				),
	.I_core_wait			( I_core_wait		),
	.D_core_wait			( D_core_wait 		),
	.SENSOR_CTRL_interrupt	(SENSOR_CTRL_interrupt),
	.WDT_interrupt			( WDT_interrupt		),
	//.MEMReadInst			( L1CI_INST			),
	.MEMReadInst			( MEMReadInst		),
	.MEMReadData			( L1CD_DATA			),
	//OUTPUT
	.inst_PC				( L1CI_ADDR			),
	.DM_A					( L1CD_ADDR			),
	.DM_WEB					( L1CD_WEB			),
	.DM_DI					( L1CD_WDATA		),
	.EX_MEM_MemWrite		( L1CD_write		),
	.EX_MEM_MemRead			( L1CD_req			)
);


L1C_inst	L1CI(
	//INPUT
	.clk		( clk 			),
	.rst		( rst 			),
	.core_addr	( L1CI_ADDR 	),
	.core_req	( 1'b1 			),
	.core_write	( 1'b0 			),
	.core_in	( 32'd0 		),
	.core_type	( `CACHE_WORD 	),
	.I_out		( RDATA_M0 		),
	.I_wait		( I_wait 		),
	//OUTPUT
	.core_out	( L1CI_INST 	),
	.core_wait	( I_core_wait	),
	.I_req		( I_req 		),
	.I_addr		( I_addr		),
	.I_write	( I_write 		),
	.I_in		( I_in			),
	.I_type		( I_type		)
);


L1C_data	L1CD(
	//INPUT
	.clk		( clk 			),
	.rst		( rst 			),
	.core_addr	( L1CD_ADDR 	),
	.core_req	( L1CD_req 		),
	.core_write	( L1CD_write 	),
	.core_in	( L1CD_WDATA 	),
	.core_type	( D_core_type 	),
	.D_out		( RDATA_M1 		),
	.D_wait		( D_wait		),
	//OUTPUT
	.core_out	( L1CD_DATA 	),
	.core_wait	( D_core_wait	),
	.D_req		( D_req 		),
	.D_addr		( D_addr 		),
	.D_write	( D_write 		),
	.D_in		( D_WDATA 		),
	.D_type		( D_type		)
);

endmodule

