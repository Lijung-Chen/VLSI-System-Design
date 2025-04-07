module PC_Adder(
    Flush,
    JALR,
    U_AUIPC,
    PC,
    imm32,
    Data_rs1,
    New_PC,
    PC_branch,
    PCAdd4
);

input   Flush, JALR, U_AUIPC;
input   [31:0]  PC, imm32, Data_rs1;    
output  [31:0]  New_PC, PC_branch, PCAdd4;

wire    [31:0]  choice, PC_branch, PCAdd4;

//assign  choice = (JALR)? RS1_Data : IF_ID_PC;
assign  choice = (~JALR | U_AUIPC)? (PC - 32'd4) : Data_rs1;
assign  PC_branch = choice + imm32;
assign  PCAdd4 = PC+32'd4;
assign  New_PC = (Flush)? PC_branch : PCAdd4;

endmodule