

module  reg_MEM_WB(
    clk,
    rst,
    D_core_wait,
    //IM_busy,
    //DM_busy,
    EX_MEM_funct3,
    EX_MEM_RegWrite,
    EX_MEM_MemtoReg,
    EX_MEM_Rd,
    EX_MEM_ALU_result,
    MEMReadData,
    MEM_WB_funct3,
    MEM_WB_RegWrite,
    MEM_WB_MemtoReg,
    MEM_WB_Rd,
    MEM_WB_ALU_result,
    MEM_WB_MEMReadData
);
input           clk,
                rst,
                D_core_wait,
                //IM_busy,
                //DM_busy,
                EX_MEM_RegWrite,
                EX_MEM_MemtoReg;
input   [2:0]   EX_MEM_funct3;
input   [4:0]   EX_MEM_Rd;
input   [31:0]  EX_MEM_ALU_result,
                MEMReadData;


output  reg     MEM_WB_RegWrite,
                MEM_WB_MemtoReg; 
output  reg[2:0]MEM_WB_funct3;
output  reg[4:0]MEM_WB_Rd;
output  reg[31:0]MEM_WB_ALU_result,
                MEM_WB_MEMReadData;

always@(posedge clk)
if(rst) 
begin
    MEM_WB_RegWrite <= 1'b0;
    MEM_WB_MemtoReg <= 1'd0;
    MEM_WB_funct3 <= 3'd0;
    MEM_WB_Rd <= 5'd0;
    MEM_WB_ALU_result <= 32'd0;
    MEM_WB_MEMReadData <= 32'd0;
end
//else if(DM_busy)
else if(D_core_wait)
begin
    MEM_WB_RegWrite <= MEM_WB_RegWrite;
    MEM_WB_MemtoReg <= MEM_WB_MemtoReg;
    MEM_WB_funct3 <= MEM_WB_funct3;
    MEM_WB_Rd <= MEM_WB_Rd;
    MEM_WB_ALU_result <= MEM_WB_ALU_result;
    MEM_WB_MEMReadData <= MEM_WB_MEMReadData;
end
else 
begin
    MEM_WB_RegWrite <= EX_MEM_RegWrite;
    MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
    MEM_WB_funct3 <= EX_MEM_funct3;
    MEM_WB_Rd <= EX_MEM_Rd;
    MEM_WB_ALU_result <= EX_MEM_ALU_result;
    MEM_WB_MEMReadData <= MEMReadData;
end

endmodule
