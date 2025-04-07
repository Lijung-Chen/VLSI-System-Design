module  reg_IF_ID(
    clk,
    rst,
    IM_busy,
    Stall,
    IF_ID_Write,
    Flush,
    inst_in,
    //PC_in,
    PCAdd4_in,
    inst_out,
    //IF_ID_PC,
    IF_ID_PCAdd4
);

input       clk, rst, IF_ID_Write, Flush, IM_busy, Stall;
input       [31:0]inst_in, PCAdd4_in;

output  reg [31:0]inst_out, IF_ID_PCAdd4;

always@(posedge clk or posedge rst)
if(rst)begin
    inst_out <= 32'd0;
    //IF_ID_PC <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end
//else if(Flush)begin
//else if(Flush | IM_busy)begin
else if(Flush | (IM_busy & ~Stall))begin
    inst_out <= 32'd0;
    //IF_ID_PC <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end  
else begin
    inst_out <= (IF_ID_Write)? inst_in : inst_out;
    //inst_out <= inst_in;
    //inst_out <= (cs)? inst_in : inst_out;
    //IF_ID_PC <= (IF_ID_Write)? PC_in : IF_ID_PC;
    IF_ID_PCAdd4 <= (IF_ID_Write)? PCAdd4_in : IF_ID_PCAdd4;
end

endmodule



