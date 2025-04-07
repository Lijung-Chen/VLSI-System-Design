//=========================EX stage=========================


module  MUX_imm(
    ID_EX_ALUSrc,
    D2,
    ID_EX_imm32,
    Dout2
);

input   ID_EX_ALUSrc;
input   [31:0]D2, ID_EX_imm32;
output  [31:0]Dout2;

assign  Dout2 = (ID_EX_ALUSrc)? ID_EX_imm32 : D2;

endmodule
