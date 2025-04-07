module sync_pulse(
    input   aclk,
    input   arst,
    input   bclk,
    input   brst,
    input   din,
    output  dout
);

logic   d_tog, d_tog_reg;
logic   syn_d_tog_tmp;
logic   syn_d_tog;
logic   reg_syn_d_tog_tmp;

always_ff@(posedge aclk)
    if(arst)    d_tog <= 1'b0;
    else        d_tog <= (din)? ~d_tog : d_tog;

// always_ff@(posedge aclk)
//     if(arst)    d_tog_reg <= 1'b0;
//     else        d_tog_reg <= (d_tog != d_tog_reg) ? 1'd1 : 1'd0;

always_ff@(posedge bclk)    
begin
    if(brst)    
    begin
        syn_d_tog_tmp <= 1'b0;
        syn_d_tog <= 1'b0;
        reg_syn_d_tog_tmp <= 1'b0;
    end
    else    
    begin
        syn_d_tog_tmp <= d_tog;
        syn_d_tog <= syn_d_tog_tmp;
        reg_syn_d_tog_tmp <= syn_d_tog;
    end
end

assign  dout = (syn_d_tog != reg_syn_d_tog_tmp);

endmodule