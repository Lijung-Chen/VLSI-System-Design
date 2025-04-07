module fifo_39(
    input rclk, 
    input rrst,
    input [38:0] wdata,
    input winc, 
    input wclk, 
    input wrst,
    input rinc, 
    output logic [38:0] rdata,
    output logic wfull,
    output logic rempty
);

logic [38:0] datamemory;
logic wen;
logic rptr;
logic wptr;
logic rptr_wq2;
logic wptr_rq2;

assign wfull  = (wptr != rptr_wq2);
assign rempty = (rptr == wptr_rq2);
assign wen    = (winc & ~wfull);
assign rdata = (!rempty) ? datamemory : 39'd0;

DFF rq2_wptr (
    .clk     (rclk),
    .rst     (rrst),
    .din     (wptr),
    .dout    (wptr_rq2)
);

DFF wq2_rptr (
    .clk     (wclk),
    .rst     (wrst),
    .din     (rptr),
    .dout    (rptr_wq2)
);

// -------- write -------- //
always_ff @(posedge wclk) 
begin
    if (wrst) 
    begin
        datamemory  <= 39'd0;
        wptr <= 1'd0;
    end
    else if (wen) 
    begin
        datamemory  <= wdata;
        wptr <= ~wptr;
    end
end

// -------- read -------- //
always_ff @(posedge rclk) 
begin
    if (rrst)
        rptr  <= 1'd0;
    else if (rinc && !rempty)
        rptr  <= ~rptr;
    else
        rptr  <= rptr;
end

endmodule