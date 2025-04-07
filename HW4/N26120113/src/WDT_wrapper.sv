`include "../include/AXI_define.svh"
`include "WDT.sv"

module WDT_wrapper (
    input   clk,
    input   rst,
    input   clk2,
    input   rst2,
    output  logic   WDT_interrupt,
    
    input [`AXI_IDS_BITS-1:0] ARID,
    input [`AXI_ADDR_BITS-1:0] ARADDR,
    input [`AXI_LEN_BITS-1:0] ARLEN,
    input [`AXI_SIZE_BITS-1:0] ARSIZE,
    input [1:0] ARBURST,
    input ARVALID,
    output  logic   ARREADY,
    
    input RREADY,
    output  logic   [`AXI_IDS_BITS-1:0] RID,
    output  logic   [`AXI_DATA_BITS-1:0] RDATA,
    output  logic   [1:0] RRESP,
    output  logic   RLAST, 
    output  logic   RVALID,
    
    input [`AXI_IDS_BITS-1:0] AWID,
    input [`AXI_ADDR_BITS-1:0] AWADDR,
    input [`AXI_LEN_BITS-1:0] AWLEN,
    input [`AXI_SIZE_BITS-1:0] AWSIZE,
    input [1:0] AWBURST,
    input AWVALID,
    output  logic   AWREADY,
    
    input [`AXI_DATA_BITS-1:0] WDATA,
    input [`AXI_STRB_BITS-1:0] WSTRB,
    input WLAST,
    input WVALID,
    output  logic   WREADY,

    input BREADY,
    output  logic   [`AXI_IDS_BITS-1:0] BID,
    output  logic   [1:0] BRESP,
    output  logic   BVALID
);

logic WTOCNT_en, WDEN, WDLIVE, WTO;
logic [31:0] WTOCNT, addr_reg;
logic [3:0] counter, len_r;

assign AWREADY = 1'b1;
assign WREADY = 1'b1;
assign BID = AWID;
assign WEB = (WVALID & WREADY & (WSTRB == 4'b1111))? 1'b1 : 1'b0;
assign BRESP = `AXI_RESP_OKAY;

assign ARREADY  = 1'b1;
assign RID      = ARID;
assign RRESP    = `AXI_RESP_OKAY;
assign WDT_interrupt = WTO;

WDT WDT(
    .clk(clk),
    .rst(rst),
    .clk2(clk2),
    .rst2(rst2),
    .WDEN(WDEN),
    .WDLIVE(WDLIVE),
    .WTOCNT(WTOCNT),
    .WTO(WTO)
);

//------------------------write--------------------//
always_ff @(posedge clk)
begin 
    if(rst)
        BVALID <= 1'd0;
    else if(WVALID & WREADY & WLAST)
        BVALID <= 1'd1;
    else if(BVALID & BREADY)
        BVALID <= 1'd0;
    else 
        BVALID <= BVALID;
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
        addr_reg <= 32'd0;
	else if(AWVALID & AWREADY)
        addr_reg <= AWADDR;
    else if(BVALID & BREADY)
        addr_reg <= 32'd0;
	else
        addr_reg <= addr_reg;
end

//------------------------read--------------------//
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
        counter <= 4'd0;
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

always_ff @(posedge clk)
begin 
    if(rst)
        RVALID <= 1'd0;
    else if(ARVALID & ARREADY)
        RVALID <= 1'd1;
    else if(RVALID & RREADY & RLAST)
        RVALID <= 1'd0;
    else 
        RVALID <= RVALID;
end

//------------------------WDT--------------------//
logic [31:0] addr;
assign addr = (AWVALID & AWREADY) ? AWADDR : addr_reg;

always_ff @ (posedge clk) 
begin
    if (rst)
        WDEN <= 1'd0;
    else if (addr == 32'h1001_0100 & WEB)
        WDEN <= (WDATA != 32'd0) ? 1'd1 : 1'd0;
    else
        WDEN <= WDEN;
end

always_ff @ (posedge clk) 
begin
    if (rst)
        WDLIVE <= 1'd0;
    else if (addr == 32'h1001_0200 & WEB)
        WDLIVE <= (WDATA != 32'b0) ? 1'd1 : 1'd0;
    else
        WDLIVE <= WDLIVE;
end

always_ff @ (posedge clk) 
begin
    if (rst)
        WTOCNT <= 32'd0;
    else if (addr == 32'h1001_0300 & WEB)
        WTOCNT <= WDATA;
    else
        WTOCNT <= WTOCNT;
end

endmodule