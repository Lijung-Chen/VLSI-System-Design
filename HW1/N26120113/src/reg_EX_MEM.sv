
module  reg_EX_MEM(
    clk,
    rst,
    mul_finish,
    ID_EX_funct3,
    ID_EX_MemRead,
    ID_EX_MemWrite,
    ID_EX_RegWrite,
    //ID_EX_CSR_ctrl,
    //ID_EX_inst_add1,
    ID_EX_MemtoReg,
    //ID_EX_PCtoReg,
    ALU_result,
    RS2_Data,
    //CSR,
    ID_EX_Rd,
    EX_MEM_funct3,
    EX_MEM_MemRead,
    EX_MEM_MemWrite,
    EX_MEM_RegWrite,
    //EX_MEM_CSR_ctrl,
    //EX_MEM_inst_add1,
    EX_MEM_MemtoReg,
    //EX_MEM_PCtoReg,
    EX_MEM_ALU_result,
    EX_MEM_Din1_complement,
    EX_MEM_RS2_Data,
    //EX_MEM_CSR,
    EX_MEM_Rd
);

input           clk, 
                rst, 
                mul_finish,
                ID_EX_MemRead,
                ID_EX_MemWrite,
                ID_EX_RegWrite,
                ID_EX_MemtoReg;
                //ID_EX_inst_add1;
//input   [1:0]   ID_EX_CSR_ctrl;
input   [2:0]   ID_EX_funct3;
input   [4:0]   ID_EX_Rd;
input   [31:0]  //ID_EX_PCtoReg,
                ALU_result,
                RS2_Data;
                //CSR;

output  reg     EX_MEM_MemRead,
                EX_MEM_MemWrite,
                EX_MEM_RegWrite,
                EX_MEM_MemtoReg;
                //EX_MEM_inst_add1;
//output  reg[1:0]EX_MEM_CSR_ctrl;
output  reg[2:0]EX_MEM_funct3;
output  reg[4:0]EX_MEM_Rd;
output  reg[31:0]//EX_MEM_PCtoReg,
                EX_MEM_ALU_result,
                EX_MEM_Din1_complement,
                EX_MEM_RS2_Data;
                //EX_MEM_CSR;

always@(posedge clk or posedge rst)
if(rst) begin
    EX_MEM_MemRead <= 1'b0;
    EX_MEM_MemWrite <= 1'd0;
    EX_MEM_RegWrite <= 1'b0;
    //EX_MEM_CSR_ctrl <= 2'd0;
    //EX_MEM_inst_add1 <= 1'b0;
    EX_MEM_MemtoReg <= 1'd0;
    EX_MEM_funct3 <= 3'd0;
    //EX_MEM_PCtoReg <= 32'd0;
    EX_MEM_ALU_result <= 32'd0;
    EX_MEM_Din1_complement <= 32'd0;
    EX_MEM_RS2_Data <= 32'd0;
    //EX_MEM_CSR <= 32'd0;
    EX_MEM_Rd <= 5'd0;
end
else begin
    EX_MEM_MemRead <= (mul_finish)? ID_EX_MemRead : EX_MEM_MemRead;
    EX_MEM_MemWrite <= (mul_finish)? ID_EX_MemWrite : EX_MEM_MemWrite;
    EX_MEM_RegWrite <= (mul_finish)? ID_EX_RegWrite : EX_MEM_RegWrite;
    EX_MEM_MemtoReg <= (mul_finish)? ID_EX_MemtoReg : EX_MEM_MemtoReg;
    EX_MEM_funct3 <= (mul_finish)? ID_EX_funct3 : EX_MEM_funct3;
    EX_MEM_ALU_result <= (mul_finish)? ALU_result : EX_MEM_ALU_result;
    EX_MEM_Din1_complement <= ALU_result;
    EX_MEM_RS2_Data <= (mul_finish)? RS2_Data : EX_MEM_RS2_Data;
    EX_MEM_Rd <= (mul_finish)? ID_EX_Rd : EX_MEM_Rd;
end

endmodule
