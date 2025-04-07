module  PC(
    clk,
    rst,
    PC_Write,
    PC_in,
    PC_out
);

input       clk, rst, PC_Write;
input       [31:0]PC_in;
output  reg [31:0]PC_out;

always@(posedge clk or posedge rst)
if(rst)
    //PC_out <= 32'd0;
    PC_out <= 32'hffff_fffc;
else
    PC_out <= (PC_Write)? PC_in : PC_out;

endmodule