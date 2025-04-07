
module  reg_WB(
    clk,
    rst,
    mul_finish,
    MEM_WB_RegWrite,
    MEM_WB_Rd,
    WB_RegData_in,
    WB_RegWrite,
    WB_Rd,
    WB_RegData_out
);
input       clk, rst, mul_finish, MEM_WB_RegWrite;
input       [4:0]MEM_WB_Rd;
input       [31:0]WB_RegData_in;
output  reg WB_RegWrite;
output  reg [4:0]WB_Rd;
output  reg [31:0]WB_RegData_out;

always@(posedge clk or posedge rst)
if(rst) begin
    WB_RegWrite <= 1'b0;
    WB_Rd <= 5'd0;
    WB_RegData_out <= 32'd0;
end
else begin
    WB_RegWrite <= (mul_finish)? MEM_WB_RegWrite : WB_RegWrite;
    WB_Rd <= (mul_finish)? MEM_WB_Rd : WB_Rd;
    WB_RegData_out <= (mul_finish)? WB_RegData_in : WB_RegData_out;
end

endmodule
