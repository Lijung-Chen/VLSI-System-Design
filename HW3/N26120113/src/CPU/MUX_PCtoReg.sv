//=========================ID stage=========================
module MUX_PCtoReg(
    U_AUIPC,
    U_LUI,
    PC,
    //IF_ID_PC,
    IF_ID_PCAdd4,
    imm32,
    PC_branch,
    PCtoReg
);
input       U_AUIPC, U_LUI;
input       [31:0]IF_ID_PCAdd4, imm32, PC_branch, PC;
output  reg [31:0]PCtoReg;

always@(*)
if(U_AUIPC)    PCtoReg = PC_branch;
else if(U_LUI)  PCtoReg = imm32;
//else    PCtoReg = IF_ID_PCAdd4;
else      PCtoReg = PC;

endmodule
