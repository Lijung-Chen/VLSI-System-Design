module  reg_ID_EX(
    clk,
    rst,
    mul_finish,
    funct3,
    funct7_3,
    ALUSrc,
    ALUOp,
    MULtype,
    mul_start,
    MemRead,
    MemWrite,
    RegWrite,
    MemtoReg,
    CSR_inst,
    CSR_ctrl,
    inst_add1,
    PCtoReg_ctrl,
    IF_ID_Rd,
    IF_ID_RS1,
    IF_ID_RS2,
    RS1_data,
    RS2_data,
    imm32,
    PCtoReg,
    ID_EX_PCtoReg,
    ID_EX_ALUSrc,
    ID_EX_funct7_3,
    ID_EX_MemRead,
    ID_EX_MemWrite,
    ID_EX_RegWrite, 
    ID_EX_ALUOp,
    ID_EX_MemtoReg,  
    ID_EX_csr,
    ID_EX_CSR_ctrl,
    ID_EX_inst_add1,
    ID_EX_PCtoReg_ctrl,
    ID_EX_funct3,
    ID_EX_Rd,
    ID_EX_RS1,
    ID_EX_RS2,
    ID_EX_RS1_data,
    ID_EX_RS2_data,
    ID_EX_imm32,
    ID_EX_MULtype,
    ID_EX_mul_start
);

input           clk,
                rst,
                mul_finish,
                ALUSrc,
                mul_start,
                MemRead,
                MemWrite,
                RegWrite,
                MemtoReg,
                CSR_inst,
                inst_add1,
                PCtoReg_ctrl;
input   [1:0]   ALUOp, 
                CSR_ctrl,
                MULtype;
input   [2:0]   funct3;
input   [4:0]   funct7_3,
                IF_ID_Rd,
                IF_ID_RS1,
                IF_ID_RS2;
input   [31:0]  RS1_data,
                RS2_data,
                imm32,
                PCtoReg;

output  reg     ID_EX_ALUSrc,
                ID_EX_mul_start,
                ID_EX_MemRead,
                ID_EX_MemWrite,
                ID_EX_RegWrite,
                ID_EX_MemtoReg,
                ID_EX_csr,
                ID_EX_inst_add1,
                ID_EX_PCtoReg_ctrl; 
output  reg[1:0]ID_EX_ALUOp,
                ID_EX_CSR_ctrl,
                ID_EX_MULtype;  
output  reg[2:0]ID_EX_funct3;
output  reg[4:0]ID_EX_funct7_3,
                ID_EX_Rd,
                ID_EX_RS1,
                ID_EX_RS2;
output  reg[31:0]ID_EX_RS1_data,
                ID_EX_RS2_data,
                ID_EX_imm32,
                ID_EX_PCtoReg;


always@(posedge clk or posedge rst)
if(rst) begin
    ID_EX_ALUSrc <= 1'b0;
    ID_EX_mul_start <= 1'b0;
    ID_EX_MULtype <= 2'd0;
    ID_EX_funct7_3 <= 5'd0;
    ID_EX_MemRead <= 1'b0;
    ID_EX_MemWrite <= 1'd0;
    ID_EX_RegWrite <= 1'b0;
    ID_EX_ALUOp <= 2'd0;
    ID_EX_MemtoReg <= 1'd0;
    ID_EX_csr <= 1'b0;
    ID_EX_CSR_ctrl <= 2'd0;
    ID_EX_inst_add1 <= 1'b0;
    ID_EX_PCtoReg_ctrl <= 1'b0;
    ID_EX_funct3 <= 3'd0;
    ID_EX_Rd <= 5'd0;
    ID_EX_RS1 <= 5'd0;
    ID_EX_RS2 <= 5'd0;
    ID_EX_RS1_data <= 32'd0;
    ID_EX_RS2_data <= 32'd0;
    ID_EX_imm32 <= 32'd0;
    ID_EX_PCtoReg <= 32'd0;
end
else begin
    ID_EX_ALUSrc <= (mul_finish)? ALUSrc : ID_EX_ALUSrc;
    ID_EX_mul_start <= (mul_finish)? mul_start : 1'b0;
    ID_EX_MULtype <= (mul_finish)? MULtype : ID_EX_MULtype;
    ID_EX_funct7_3 <= (mul_finish)? funct7_3 : ID_EX_funct7_3;
    ID_EX_MemRead <= (mul_finish)? MemRead : ID_EX_MemRead;
    ID_EX_MemWrite <= (mul_finish)? MemWrite : ID_EX_MemWrite;
    ID_EX_RegWrite <= (mul_finish)? RegWrite : ID_EX_RegWrite;
    ID_EX_ALUOp <= (mul_finish)? ALUOp : ID_EX_ALUOp;
    ID_EX_MemtoReg <= (mul_finish)? MemtoReg : ID_EX_MemtoReg;
    ID_EX_csr <= (mul_finish)? CSR_inst : ID_EX_csr;
    ID_EX_CSR_ctrl <= (mul_finish)? CSR_ctrl : ID_EX_CSR_ctrl;
    //ID_EX_inst_add1 <= (mul_finish)? inst_add1 : ID_EX_inst_add1;
    ID_EX_inst_add1 <= (mul_finish)? inst_add1 : 1'b0;
    ID_EX_PCtoReg_ctrl <= (mul_finish)? PCtoReg_ctrl : ID_EX_PCtoReg_ctrl;
    ID_EX_funct3 <= (mul_finish)? funct3 : ID_EX_funct3;
    ID_EX_Rd <= (mul_finish)? IF_ID_Rd : ID_EX_Rd;
    ID_EX_RS1 <= (mul_finish)? IF_ID_RS1 : ID_EX_RS1;
    ID_EX_RS2 <= (mul_finish)? IF_ID_RS2 : ID_EX_RS2;
    ID_EX_RS1_data <= (mul_finish)? RS1_data : ID_EX_RS1_data;
    ID_EX_RS2_data <= (mul_finish)? RS2_data : ID_EX_RS2_data;
    ID_EX_imm32 <= (mul_finish)? imm32 : ID_EX_imm32;
    ID_EX_PCtoReg <= (mul_finish)? PCtoReg : ID_EX_PCtoReg;
end

endmodule
