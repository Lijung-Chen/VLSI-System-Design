module fifo37_s(
    input rclk, 
    input rrst,
    input [36:0] wdata,
    input winc, 
    input wclk, 
    input wrst,
    input rinc, 
    output logic [36:0] rdata,
    output logic wfull,
    output logic rempty
);

   // Depth = 1
logic [36:0] datamemory;

// ptr bits = clog2(Depth) = 1
logic wen;
logic rptr;
logic wptr;
logic rptr_wq2;
logic wptr_rq2;

assign wfull  = (wptr != rptr_wq2);
assign rempty = (rptr == wptr_rq2);
assign wen    = (winc & ~wfull);
assign rdata = (!rempty) ? datamemory : 37'd0;

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
        datamemory  <= 37'd0;
        wptr <= 1'b0;
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
        rptr  <= 1'b0;
    else if (rinc && !rempty)
        rptr  <= ~rptr;
    else
        rptr  <= rptr;
end

endmodule