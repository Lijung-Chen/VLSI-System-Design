`include "../include/AXI_define.svh"
`include "WDT.sv"
`include "sync_handshake.sv"

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

enum logic [2:0] {IDLE, WRITE_ADDR, WRITE_DATA, WRITE_RESP, READ_ADDR, READ_DATA} state, next_state;

logic           WDEN, WDLIVE, WTO;
logic   [31:0]  WTOCNT_clk, WDEN_clk, WDLIVE_clk;
logic   [3:0]   counter, len_r;
logic           WDEN_wreq, WDLIVE_wreq, WTOCNT_wreq;
logic           WDEN_wreq_sync, WDLIVE_wreq_sync, WTOCNT_wreq_sync;
logic           WDEN_wready, WDLIVE_wready, WTOCNT_wready;
logic   [31:0]  WDEN_clk2, WDLIVE_clk2, WTOCNT;
logic           WREADY_WDEN, WREADY_WDLIVE, WREADY_WTOCNT;

assign WEB = (WVALID & WREADY & ({~WSTRB[3],~WSTRB[2],~WSTRB[1],~WSTRB[0]} == 4'b0))? 1'b1 : 1'b0;
assign BRESP = `AXI_RESP_OKAY;
assign RRESP = `AXI_RESP_OKAY;
assign RLAST = (RVALID) ? (counter==len_r) ? 1'd1 : 1'd0 : 1'd0;

assign WDT_interrupt = WTO;


WDT WDT(
    //INPUT
    .clk(clk),
    .rst(rst),
    .clk2(clk2),
    .rst2(rst2),
    //.WTOCNT_en(WTOCNT_en),
    .WDEN(WDEN),
    .WDLIVE(WDLIVE),
    .WTOCNT(WTOCNT),
    //OUTPUT
    .WTO(WTO)
);

//==============================CDC====================================//

assign  WDEN_wreq = (AWADDR == 32'h1001_0100 & WVALID & WREADY & ({~WSTRB[3],~WSTRB[2],~WSTRB[1],~WSTRB[0]}==4'd0));
assign  WDLIVE_wreq = (AWADDR == 32'h1001_0200 & WVALID & WREADY & ({~WSTRB[3],~WSTRB[2],~WSTRB[1],~WSTRB[0]}==4'd0));
assign  WTOCNT_wreq = (AWADDR == 32'h1001_0300 & WVALID & WREADY & ({~WSTRB[3],~WSTRB[2],~WSTRB[1],~WSTRB[0]}==4'd0));

always_ff @ (posedge clk) 
begin
    if (rst)    begin
        WDEN_wreq_sync <= 1'b0;
        WDEN_clk <= 32'd0;
    end
    else if (WDEN_wreq) begin
        //WDEN_clk <= (WDATA != 32'd0) ? 1'd1 : 1'd0;
        WDEN_wreq_sync <= 1'b1;
        WDEN_clk <= WDATA;
    end
    else    begin
        WDEN_wreq_sync <= 1'b0;
        WDEN_clk <= WDEN_clk;
    end
end

always_ff @ (posedge clk) 
begin
    if (rst)    begin
        WDLIVE_wreq_sync <= 1'b0;
        WDLIVE_clk <= 32'd0;
    end
    else if (WDLIVE_wreq)   begin
        WDLIVE_wreq_sync <= 1'b1;
        //WDLIVE_clk <= (WDATA != 32'b0) ? 1'd1 : 1'd0;
        WDLIVE_clk <= WDATA;
    end
    else    begin
        WDLIVE_wreq_sync <= 1'b0;
        WDLIVE_clk <= WDLIVE_clk;
    end
end

always_ff @ (posedge clk) 
begin
    if (rst)    begin
        WTOCNT_wreq_sync <= 1'b0;
        WTOCNT_clk <= 32'd0;
    end
    else if (WTOCNT_wreq)   begin
        WTOCNT_wreq_sync <= 1'b1;
        WTOCNT_clk <= WDATA;
    end
    else    begin
        WTOCNT_wreq_sync <= 1'b0;
        WTOCNT_clk <= WTOCNT_clk;
    end
end

always_ff @ (posedge clk) 
begin
    if (rst)    WREADY_WDEN <= 1'b0;
    else        WREADY_WDEN <= (state == WRITE_DATA) && WDEN_wready;
end

always_ff @ (posedge clk) 
begin
    if (rst)    WREADY_WDLIVE <= 1'b0;
    else        WREADY_WDLIVE <= (state == WRITE_DATA) && WDLIVE_wready;
end

always_ff @ (posedge clk) 
begin
    if (rst)    WREADY_WTOCNT <= 1'b0;
    else        WREADY_WTOCNT <= (state == WRITE_DATA) && WTOCNT_wready;
end



assign  WDEN = |WDEN_clk2;

sync_handshake  sync_WDEN(
    //INPUT
    .clk_w(clk),
    .rst_w(rst),
    .clk_r(clk2),
    .rst_r(rst2),
    .din(WDEN_clk),
    .w_req(WDEN_wreq_sync),
    //OUTPUT
    .w_ready(WDEN_wready),
    .dout(WDEN_clk2)
);

assign  WDLIVE = |WDLIVE_clk2;

sync_handshake  sync_WDLIVE(
    //INPUT
    .clk_w(clk),
    .rst_w(rst),
    .clk_r(clk2),
    .rst_r(rst2),
    .din(WDLIVE_clk),
    .w_req(WDLIVE_wreq_sync),
    //OUTPUT
    .w_ready(WDLIVE_wready),
    .dout(WDLIVE_clk2)
);

sync_handshake  sync_WTOCNT(
    //INPUT
    .clk_w(clk),
    .rst_w(rst),
    .clk_r(clk2),
    .rst_r(rst2),
    .din(WTOCNT_clk),
    .w_req(WTOCNT_wreq_sync),
    //OUTPUT
    .w_ready(WTOCNT_wready),
    .dout(WTOCNT)
);


//===============================wrapper interface=============================//

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

always_comb begin
    case(AWADDR)
        32'h1001_0100 : WREADY = WREADY_WDEN;
        32'h1001_0200 : WREADY = WREADY_WDLIVE;
        32'h1001_0300 : WREADY = WREADY_WTOCNT;
	    default       : WREADY = 1'b0;
    endcase
end

always_comb 
begin
  unique case (state)
  IDLE: 
  begin
      ARREADY = 1'd1;
      RVALID = 1'd0;
      AWREADY = 1'd1;
      //WREADY = 1'd0;
      BVALID = 1'd0;  
      RDATA = 32'd0; 
  end
  WRITE_ADDR: 
  begin
      ARREADY  = 1'd0;
      RVALID   = 1'd0;
      AWREADY  = 1'd1;
      //WREADY   = 1'd0;
      BVALID   = 1'd0;
      RDATA = 32'd0; 
  end
  WRITE_DATA: 
  begin
      ARREADY  = 1'd0;
      RVALID   = 1'd0;
      AWREADY  = 1'd0;
      //WREADY   = 1'd1;
      BVALID   = 1'd0;
      RDATA = 32'd0; 
  end
  WRITE_RESP: 
  begin
      ARREADY  = 1'd0;
      RVALID   = 1'd0;
      AWREADY  = 1'd0;
      //WREADY   = 1'd0;
      BVALID   = 1'd1; 
      RDATA = 32'd0; 
  end
  READ_ADDR: 
  begin
      ARREADY  = 1'd1;
      RVALID   = 1'd0;
      AWREADY  = 1'd0;
      //WREADY   = 1'd0;
      BVALID   = 1'd0;
      RDATA = 32'd0; 
  end
  READ_DATA: 
  begin
      ARREADY  = 1'd0;
      RVALID   = 1'd1;
      AWREADY  = 1'd0;
      //WREADY   = 1'd0;
      BVALID   = 1'd0;
      RDATA = 32'd0;
  end
  default: 
  begin
      ARREADY  = 1'd0;
      RVALID   = 1'd0;
      AWREADY  = 1'd0;
      //WREADY   = 1'd0;
      BVALID   = 1'd0;
      RDATA = 32'd0;
  end
  endcase
end

//------------------------write--------------------//

always_ff @(posedge clk)
begin 
    if(rst)
		len_r <= 4'd0;
	else if(ARVALID)
		len_r <= ARLEN;
	else
		len_r <= len_r;
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

always_ff @ (posedge clk) 
begin
    if (rst) 
        RID <= 8'd0;
    else if(ARVALID & ARREADY)
        RID <= ARID;
    else 
        RID <= RID;
end


endmodule