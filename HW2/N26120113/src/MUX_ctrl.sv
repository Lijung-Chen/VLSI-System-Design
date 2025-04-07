//=========================ID stage=========================
module MUX_ctrl(
    Stall,
    NOP,
    ALUSrc,
    ALUOp,
    MemRead,
    MemWrite,
    RegWrite,
    MemtoReg,
    CSR_ctrl,
    CSR_inst,
    ALUSrc_toReg,
    ALUOp_toReg,
    MemRead_toReg,
    MemWrite_toReg,
    RegWrite_toReg,
    MemtoReg_toReg,
    CSR_inst_toReg,
    CSR_ctrl_toReg,
    inst_add1_toReg
);
input       Stall,
            NOP,
            MemRead,
            MemWrite,
            ALUSrc,
            RegWrite,
            MemtoReg,
            CSR_inst;
input   [1:0]ALUOp,
            CSR_ctrl;
//input   [3:0]MemWrite;

output      MemRead_toReg,
            MemWrite_toReg,
            ALUSrc_toReg,
            RegWrite_toReg,
            MemtoReg_toReg,
            CSR_inst_toReg,
            inst_add1_toReg;
output  [1:0]ALUOp_toReg,
            CSR_ctrl_toReg;
//output  [3:0]MemWrite_toReg;

wire    SetZero;

assign  SetZero = Stall | NOP;

assign  MemRead_toReg = (SetZero)? 1'b0 : MemRead;
assign  ALUSrc_toReg  = (SetZero)? 1'b0 : ALUSrc;
assign  RegWrite_toReg  = (SetZero)? 1'b0 : RegWrite;
assign  inst_add1_toReg  = (SetZero)? 1'b0 : 1'b1;
assign  ALUOp_toReg  = (SetZero)? 2'd0 : ALUOp;
assign  MemtoReg_toReg  = (SetZero)? 1'd0 : MemtoReg;
assign  CSR_inst_toReg = (SetZero)? 1'b0 : CSR_inst;
assign  CSR_ctrl_toReg  = (SetZero)? 2'd0 : CSR_ctrl;
assign  MemWrite_toReg  = (SetZero)? 1'b0 : MemWrite;

endmodule








