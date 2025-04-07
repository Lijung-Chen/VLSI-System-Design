
module  reg_EX_MEM(
    clk,
    rst,
    DM_busy,
    ID_EX_funct3,
    ID_EX_MemRead,
    ID_EX_MemWrite,
    ID_EX_RegWrite,
    ID_EX_MemtoReg,
    ALU_result,
    RS2_Data,
    ID_EX_Rd,
    EX_MEM_funct3,
    EX_MEM_MemRead,
    EX_MEM_MemWrite,
    EX_MEM_RegWrite,
    EX_MEM_MemtoReg,
    EX_MEM_ALU_result,
    EX_MEM_RS2_Data,
    EX_MEM_Rd
);

input           clk, 
                rst, 
                DM_busy,
                ID_EX_MemRead,
                ID_EX_MemWrite,
                ID_EX_RegWrite,
                ID_EX_MemtoReg;
input   [2:0]   ID_EX_funct3;
input   [4:0]   ID_EX_Rd;
input   [31:0]  ALU_result, RS2_Data;

output  reg     EX_MEM_MemRead,
                EX_MEM_MemWrite,
                EX_MEM_RegWrite,
                EX_MEM_MemtoReg;
output  reg[2:0]EX_MEM_funct3;
output  reg[4:0]EX_MEM_Rd;
output  reg[31:0]EX_MEM_ALU_result, EX_MEM_RS2_Data;

always@(posedge clk or posedge rst)
if(rst) begin
    EX_MEM_MemRead <= 1'b0;
    EX_MEM_MemWrite <= 1'b0;
    EX_MEM_RegWrite <= 1'b0;
    EX_MEM_MemtoReg <= 1'd0;
    EX_MEM_funct3 <= 3'd0;
    EX_MEM_ALU_result <= 32'd0;
    EX_MEM_RS2_Data <= 32'd0;
    EX_MEM_Rd <= 5'd0;
end

else if(DM_busy)begin
    EX_MEM_MemRead <= EX_MEM_MemRead;
    EX_MEM_MemWrite <= EX_MEM_MemWrite;
    EX_MEM_RegWrite <= EX_MEM_RegWrite;
    EX_MEM_MemtoReg <= EX_MEM_MemtoReg;
    EX_MEM_funct3 <= EX_MEM_funct3;
    EX_MEM_ALU_result <= EX_MEM_ALU_result;
    EX_MEM_RS2_Data <= EX_MEM_RS2_Data;
    EX_MEM_Rd <= EX_MEM_Rd;
end

else begin
    EX_MEM_MemRead <= ID_EX_MemRead;
    EX_MEM_MemWrite <= ID_EX_MemWrite;
    EX_MEM_RegWrite <= ID_EX_RegWrite;
    EX_MEM_MemtoReg <= ID_EX_MemtoReg;
    EX_MEM_funct3 <= ID_EX_funct3;
    EX_MEM_ALU_result <= ALU_result;
    EX_MEM_RS2_Data <= RS2_Data;
    EX_MEM_Rd <= ID_EX_Rd;
end

endmodule
