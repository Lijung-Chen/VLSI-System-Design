`include "../include/AXI_define.svh"
`include "sensor_ctrl.sv"

module SCtrl_wrapper(
    input clk,
    input rst,
    input sensor_ready,
    input   [31:0]  sensor_out,
    output  logic   sensor_en,
    output  logic   sensor_ctrl_interrupt,

    input   [`AXI_IDS_BITS - 1:0]           AWID,
    input   [`AXI_ADDR_BITS - 1:0]          AWADDR,
    input   [`AXI_LEN_BITS - 1:0]           AWLEN,
    input   [`AXI_SIZE_BITS - 1:0]          AWSIZE,
    input   [1:0] AWBURST,
    input   AWVALID,
    output  logic AWREADY,

    input   [`AXI_DATA_BITS - 1:0]          WDATA,
    input   [`AXI_STRB_BITS - 1:0]          WSTRB,
    input   WLAST,
    input   WVALID,
    output  logic   WREADY,

    input                                   BREADY,
    output  logic   [`AXI_IDS_BITS - 1:0]   BID,
    output  logic   [1:0]                   BRESP,
    output  logic   BVALID,

    input   [`AXI_IDS_BITS - 1:0]           ARID,
    input   [`AXI_ADDR_BITS - 1:0]          ARADDR,
    input   [`AXI_LEN_BITS - 1:0]           ARLEN,
    input   [`AXI_SIZE_BITS - 1:0]          ARSIZE,
    input   [1:0]   ARBURST,
    input   ARVALID,
    output  logic   ARREADY,

    input                                   RREADY,
    output  logic   [`AXI_IDS_BITS - 1:0]   RID,
    output  logic   [`AXI_DATA_BITS - 1:0]  RDATA,
    output  logic   [1:0]   RRESP,
    output  logic   RLAST,
    output  logic   RVALID
);

enum logic [2:0] {IDLE, WRITE_ADDR, WRITE_DATA, WRITE_RESP, READ_ADDR, READ_DATA} state, next_state;

logic sctrl_interrupt;
logic [31:0] sctrl_out;
logic sctrl_en, sensor_en_reg;
logic sctrl_clear;
logic [5:0] sctrl_addr;
logic WEB;
logic [1:0] counter;
logic [3:0] len_r;
logic [31:0] araddr_reg;

assign WEB = (WVALID & WREADY & ({~WSTRB[3],~WSTRB[2],~WSTRB[1],~WSTRB[0]}==4'd0))? 1'd1 : 1'd0;
assign BRESP = `AXI_RESP_OKAY;
assign RRESP = `AXI_RESP_OKAY;
assign RLAST = (RVALID) ? (counter==len_r) ? 1'd1 : 1'd0 : 1'd0;
//assign sensor_ctrl_interrupt = (rst) ? 1'd0 : sctrl_interrupt;
assign sensor_ctrl_interrupt = sctrl_interrupt;

//--------------------Write sensor_ctrl-----------------//
sensor_ctrl sensor_ctrl(
    .clk(clk),
    .rst(rst),
    .sctrl_en(sctrl_en),
    .sctrl_clear(sctrl_clear),
    .sctrl_addr(sctrl_addr),
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    .sctrl_interrupt(sctrl_interrupt),
    .sctrl_out(sctrl_out),
    .sensor_en(sensor_en_reg)
);

//--------------------state-----------------//
always @(posedge clk) 
begin 
  if (rst) 
  begin
        state <= IDLE;
  end
  else 
  begin
        state <= next_state;
  end
end

always_comb 
begin
  unique case (state)
    IDLE: 
    begin
        if(AWVALID & AWREADY)
            next_state = WRITE_DATA;
        else if (ARVALID & ARREADY) 
            next_state = READ_DATA;
        else if(AWVALID)
            next_state = WRITE_ADDR;
        else if (ARVALID) 
            next_state = READ_ADDR;
        else
            next_state = IDLE;
    end
    WRITE_ADDR: 
    begin
        if(AWVALID && AWREADY)
            next_state = WRITE_DATA;
        else
            next_state = WRITE_ADDR;
    end
    WRITE_DATA: 
    begin
        if(WVALID & WREADY & WLAST)
            next_state = WRITE_RESP;
        else
            next_state = WRITE_DATA;
    end
    WRITE_RESP: 
    begin
        if(BVALID & BREADY)
        begin
            if(AWVALID & AWREADY)
                next_state = WRITE_DATA;
            else if (ARVALID & ARREADY) 
                next_state = READ_DATA;
            else if(AWVALID)
                next_state = WRITE_ADDR;
            else if (ARVALID) 
                next_state = READ_ADDR;
            else
                next_state = IDLE;
        end
        else
            next_state = WRITE_RESP;
    end
    READ_ADDR: 
    begin
        if(ARVALID & ARREADY)
            next_state = READ_DATA;
        else
            next_state = READ_ADDR;
    end
    READ_DATA: 
    begin
        if(RVALID & RREADY)
        begin
            if(AWVALID & AWREADY)
                next_state = WRITE_DATA;
            else if (ARVALID & ARREADY) 
                next_state = READ_DATA;
            else if(AWVALID)
                next_state = WRITE_ADDR;
            else if (ARVALID) 
                next_state = READ_ADDR;
            else
                next_state = IDLE;
        end
        else
        next_state = READ_DATA;
    end
    default: 
    begin
        next_state = IDLE;
    end
  endcase   
end

always_comb 
begin
  unique case (state)
  IDLE: 
  begin
      ARREADY = 1'b1;
      RVALID = 1'b0;
      AWREADY = 1'b1;
      WREADY = 1'b0;
      BVALID = 1'b0;  
      RDATA = 32'd0; 
  end
  WRITE_ADDR: 
  begin
      ARREADY  = 1'b0;
      RVALID   = 1'b0;
      AWREADY  = 1'b1;
      WREADY   = 1'b0;
      BVALID   = 1'b0;
      RDATA = 32'd0; 
  end
  WRITE_DATA: 
  begin
      ARREADY  = 1'b0;
      RVALID   = 1'b0;
      AWREADY  = 1'b0;
      WREADY   = 1'b1;
      BVALID   = 1'b0;
      RDATA = 32'd0; 
  end
  WRITE_RESP: 
  begin
      ARREADY  = 1'b0;
      RVALID   = 1'b0;
      AWREADY  = 1'b0;
      WREADY   = 1'b0;
      BVALID   = 1'b1; 
      RDATA = 32'd0; 
  end
  READ_ADDR: 
  begin
      ARREADY  = 1'b1;
      RVALID   = 1'b0;
      AWREADY  = 1'b0;
      WREADY   = 1'b0;
      BVALID   = 1'b0;
      RDATA = 32'd0; 
  end
  READ_DATA: 
  begin
      ARREADY  = 1'b0;
      RVALID   = 1'b1;
      AWREADY  = 1'b0;
      WREADY   = 1'b0;
      BVALID   = 1'b0;
      RDATA = sctrl_out;
  end
  default: 
  begin
      ARREADY  = 1'b0;
      RVALID   = 1'b0;
      AWREADY  = 1'b0;
      WREADY   = 1'b0;
      BVALID   = 1'b0;
      RDATA = 32'd0;
  end
  endcase
end

//--------------------Read-----------------//
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
        counter <= 4'd0;
end

always_ff @ (posedge clk) 
begin
    if (rst) 
        BID <= 8'd0;
    else if(AWVALID & AWREADY)
        BID <= AWID;
    else
        BID <= BID;
end

always_ff @ (posedge clk) 
begin
    if (rst) 
        RID <= 8'd0;
    else if(ARVALID & ARREADY)
        RID <= ARID;
    else 
        RID <= RID;
end

always_ff @(posedge clk)
begin 
    if(rst)
        araddr_reg <= 32'd0;
	else if(ARVALID & ARREADY)
        araddr_reg <= ARADDR;
	else
        araddr_reg <= araddr_reg;
end

always_comb 
begin
    if(state == READ_ADDR)
        sctrl_addr = ARADDR[7:2];
    else if(state == READ_DATA & RVALID & RREADY)
        sctrl_addr = araddr_reg[7:2];
    else if(state == READ_DATA)
        sctrl_addr = araddr_reg[7:2];
    else
        sctrl_addr = 6'd0;
end

always_ff @(posedge clk)
begin 
    if(rst)
        sensor_en <= 1'b0;
	else
        sensor_en <= sensor_en_reg;
end

// Address: 0x1000_0100(stcrl_en)
always_ff @(posedge clk) 
begin
    if(rst)
        sctrl_en <= 1'd0;
    else if(AWADDR == 32'h1000_0100 & WEB)
        sctrl_en <= (WDATA != 32'd0) ? 1'd1 : 1'd0;
    else 
        sctrl_en <= sctrl_en;
end

// Address: 0x1000_0200(stcrl_clear)
always_ff @(posedge clk) 
begin
    if(rst)
        sctrl_clear <= 1'd0;
    else if(AWADDR == 32'h1000_0200 & WEB & WVALID & WREADY)
        sctrl_clear <= (WDATA != 32'd0) ? 1'd1 : 1'd0;
    else
        sctrl_clear <= sctrl_clear;
end

endmodule
