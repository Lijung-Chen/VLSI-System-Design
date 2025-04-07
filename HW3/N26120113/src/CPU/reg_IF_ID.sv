module  reg_IF_ID(
    clk,
    rst,
    ID_flush,
    DM_busy,
    IM_busy,
    RVALID_M0,
    interrupt_taken,
    Stall,
    IF_ID_Write,
    Flush,
    inst_in,
    PCAdd4_in,
    inst_out,
    IF_ID_PCAdd4
);

input       clk, rst, IF_ID_Write, Flush, IM_busy, Stall, DM_busy, interrupt_taken, ID_flush, RVALID_M0;
input       [31:0]inst_in, PCAdd4_in;

output  reg [31:0]inst_out, IF_ID_PCAdd4;

always@(posedge clk)
if(rst)begin
    inst_out <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end

//else if(DM_busy)
else if(DM_busy & ~RVALID_M0)
begin
    inst_out <= inst_out;
    IF_ID_PCAdd4 <= IF_ID_PCAdd4;
end

else if(interrupt_taken)
begin
    inst_out <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end  

//else if((Flush | (IM_busy & ~Stall )) & ~DM_busy)
//else if((Flush | (IM_busy & ~Stall )))
else if((Flush | (ID_flush & ~Stall )))
begin
    inst_out <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end 

else begin
    inst_out <= (IF_ID_Write)? inst_in : inst_out;
    IF_ID_PCAdd4 <= (IF_ID_Write)? PCAdd4_in : IF_ID_PCAdd4;
end

endmodule



