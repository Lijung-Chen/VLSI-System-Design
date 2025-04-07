`include "../include/AXI_define.svh"

module ROM_wrapper( 
    input clk,
    input rst,
    //----------Read Address--------//
    input   [`AXI_IDS_BITS-1:0]     ARID,
    input   [`AXI_ADDR_BITS-1:0]    ARADDR,
    input   [`AXI_LEN_BITS-1:0]     ARLEN,
    input   [`AXI_SIZE_BITS-1:0]    ARSIZE,
    input   [1:0] ARBURST,
    input ARVALID,
    output  logic ARREADY,
    //----------Read Data--------//
    input RREADY,
    output  logic   [`AXI_IDS_BITS-1:0]  RID,
    output  logic   [`AXI_DATA_BITS-1:0] RDATA,
    output  logic   [1:0] RRESP,
    output  logic RLAST,
    output  logic RVALID,
    //----------Output of ROM--------//
    input   [31:0] ROM_out,
    output  logic ROM_enable,
    output  logic ROM_read,
    output  logic [11:0] ROM_address
);

enum logic [1:0] {IDLE, READ_ADDR, READ_DATA} state, next_state;
logic [1:0] counter;
logic [3:0] len_r;
logic [1:0] R_cs, R_ns;


// assign  ARREADY = (state == READ_ADDR) ? 1'b1 : 1'b0;
assign  RDATA   = (RVALID & RREADY) ? ROM_out : 32'd0;
assign  RRESP   = `AXI_RESP_OKAY;

assign  ROM_read = 1'd1;
assign  ROM_enable = 1'd1;

always@(posedge clk)
begin
  if(rst) 
    ARREADY <= 1'b1;
  else if(RVALID & RLAST & RREADY)	
    ARREADY <= 1'b1;
  else if(ARVALID & ARREADY) 
    ARREADY <= 1'b0; 
  else  
    ARREADY <= ARREADY;
end

//for sythesize
always_ff @(posedge clk) 
begin
    if(rst)
        ROM_address <= 12'd0;
    else if(ARVALID & ARREADY)
        ROM_address <= ARADDR[13:2];
    else if(RVALID & RREADY)
        ROM_address <= ROM_address + 12'd1; //??
    else
        ROM_address <= ROM_address;
end


always_ff @(posedge clk) 
begin
    if(rst) R_cs <= 2'd0;
    else    R_cs <= R_ns;
end

always_comb
case(R_cs)
2'd0:   //wait read address
  R_ns = (ARVALID & ARREADY)? 2'd1 : 2'd0;
2'd1:   //reading out data
  R_ns = (RLAST)? 2'd0 :2'd2;
default:  //wait for master ready to accept data
  R_ns = (RREADY)? ((RLAST)? 2'd0 : 2'd1) : 2'd2;
endcase

always_ff @ (posedge clk) 
begin
	if (rst) 
    RVALID <= 1'd0;
	else 
  begin
    //if (R_cs == 2'd1) 
    if (R_cs == 2'd1 || (R_cs == 2'd2 && ~RREADY)) 
      RVALID <= 1'd1;
    else if (RVALID & RREADY)
      RVALID <= 1'd0;
		else 
			RVALID <= RVALID;     
	end
end


always_ff @(posedge clk)
begin 
    if(rst)
		len_r <= 4'd0;
	else if(ARVALID)
		len_r <= ARLEN;
	else
		len_r <= len_r;
end

always_ff @(posedge clk)
begin 
  if(rst)
    counter <= 4'd0;
	else if(RREADY & RVALID)
  begin
    if(counter==len_r)
        counter <= 4'd0;
    else
        counter <= counter + 4'd1;
  end
	else 
    //counter <= 4'd0;
    counter <= counter;
end

always_comb
begin
    if(RVALID)
    begin 
        if(counter==len_r)
			RLAST = 1'd1;
		else
			RLAST = 1'd0;
    end
    else
        RLAST = 1'd0;
end

always_ff @ (posedge clk) 
begin
    if (rst) 
        RID <= 8'd0;
    else 
        RID <= (ARVALID & ARREADY) ? ARID : RID;
end

endmodule
