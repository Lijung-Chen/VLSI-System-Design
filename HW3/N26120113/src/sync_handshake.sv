`include "sync_pulse.sv"

module  sync_handshake(
    input                   clk_w,
    input                   rst_w,
    input                   clk_r,
    input                   rst_r,
    input           [31:0]  din,
    input                   w_req,
    output  logic           w_ready,
    output  logic   [31:0]  dout
);

logic   [31:0]  data_clkw, data_clkr;
logic   r_req;
logic   w_ack;

assign  dout = data_clkr;

always_ff@(posedge clk_w)
if(rst_w)   data_clkw <= 32'd0;
else        data_clkw <= (w_req)? din : data_clkw;

always_ff@(posedge clk_r)
if(rst_r)   data_clkr <= 32'd0;
else        data_clkr <= (r_req)? data_clkw : data_clkr;

always_ff@(posedge clk_w)
if(rst_w)       w_ready <= 1'b1;
else if(w_ack)  w_ready <= 1'b1;
else if(w_req)  w_ready <= 1'b0;
else            w_ready <= w_ready;

sync_pulse  SNCP_W2R(
    //INPUT
    .aclk(clk_w),
    .arst(rst_w),
    .bclk(clk_r),
    .brst(rst_r),
    .din(w_req),
    //OUTPUT
    .dout(r_req)
);

sync_pulse  SNCP_R2W(
    //INPUT
    .aclk(clk_r),
    .arst(rst_r),
    .bclk(clk_w),
    .brst(rst_w),
    .din(r_req),
    //OUTPUT
    .dout(w_ack)
);

endmodule