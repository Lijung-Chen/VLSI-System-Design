module  reg_ID_EX(
    clk,
    rst,
    DM_busy,
    funct3,
    funct7_3,
    ALUSrc,
    ALUOp,
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
    ID_EX_imm32
);

input           clk,
                rst,
                DM_busy,
                ALUSrc,
                MemRead,
                MemWrite,
                RegWrite,
                MemtoReg,
                CSR_inst,
                inst_add1,
                PCtoReg_ctrl;
input   [1:0]   ALUOp, 
                CSR_ctrl;
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
                ID_EX_MemRead,
                ID_EX_MemWrite,
                ID_EX_RegWrite,
                ID_EX_MemtoReg,
                ID_EX_csr,
                ID_EX_inst_add1,
                ID_EX_PCtoReg_ctrl; 
output  reg[1:0]ID_EX_ALUOp,
                ID_EX_CSR_ctrl;  
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
    ID_EX_ALUSrc <= (DM_busy)? ID_EX_ALUSrc : ALUSrc;
    ID_EX_funct7_3 <= (DM_busy)? ID_EX_funct7_3 : funct7_3;
    ID_EX_MemRead <= (DM_busy)? ID_EX_MemRead : MemRead;
    ID_EX_MemWrite <= (DM_busy)? ID_EX_MemWrite : MemWrite;
    ID_EX_RegWrite <= (DM_busy)? ID_EX_RegWrite : RegWrite;
    ID_EX_ALUOp <= (DM_busy)? ID_EX_ALUOp : ALUOp;
    ID_EX_MemtoReg <= (DM_busy)? ID_EX_MemtoReg : MemtoReg;
    ID_EX_csr <= (DM_busy)? ID_EX_csr : CSR_inst;
    ID_EX_CSR_ctrl <= (DM_busy)? ID_EX_CSR_ctrl : CSR_ctrl;
    ID_EX_inst_add1 <= (DM_busy)? 1'b0 : inst_add1;
    ID_EX_PCtoReg_ctrl <= (DM_busy)? ID_EX_PCtoReg_ctrl : PCtoReg_ctrl;
    ID_EX_funct3 <= (DM_busy)? ID_EX_funct3 : funct3;
    ID_EX_Rd <= (DM_busy)? ID_EX_Rd : IF_ID_Rd;
    ID_EX_RS1 <= (DM_busy)? ID_EX_RS1 : IF_ID_RS1;
    ID_EX_RS2 <= (DM_busy)? ID_EX_RS2 : IF_ID_RS2;
    ID_EX_RS1_data <= (DM_busy)? ID_EX_RS1_data : RS1_data;
    ID_EX_RS2_data <= (DM_busy)? ID_EX_RS2_data : RS2_data;
    ID_EX_imm32 <= (DM_busy)? ID_EX_imm32 : imm32;
    ID_EX_PCtoReg <= (DM_busy)? ID_EX_PCtoReg : PCtoReg;
end

endmodule
