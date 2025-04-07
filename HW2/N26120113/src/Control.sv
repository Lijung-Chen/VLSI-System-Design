module Control(
    op,
    funct3,     //for load /S-type
    inst27,
    inst21,
    branch_taken,   //B-type=0/1, JAL/JALR=1
    Branch,
    Btype,
    Stall,
    JALR,
    JAL,
    U_AUIPC,
    U_LUI,
    MemRead,
    MemWrite,
    MemtoReg,
    ALUOp,
    ALUSrc,
    RegWrite,
    Flush,
    NOP,
    CSR_ctrl,   //for CSR
    CSR_inst,
    PCtoReg_ctrl
);
input   [6:0]op;
input   [2:0]funct3;
input   branch_taken, inst27, inst21, Stall;
output  Branch,
        Btype,
        JALR,
        JAL,
        U_AUIPC,
        U_LUI,
        MemRead,
        MemWrite,
        MemtoReg,
        ALUSrc,
        RegWrite,
        Flush,
        NOP,
        CSR_inst,
        PCtoReg_ctrl;
output  [1:0]ALUOp,
            //MemtoReg,  
            CSR_ctrl;
//output  [3:0]MemWrite;


//PC forwarding
assign  PCtoReg_ctrl = JALR | JAL | U_AUIPC | U_LUI;

//Btype
assign  Btype = (op==7'b1100011);


//NOP op=7'd0
assign  NOP = ~|op;

//U_AUIPC op=0010111
assign U_AUIPC = (op==7'b0010111);

//U_LUI
assign  U_LUI = (op==7'b0110111);

//B-type op=1100011 / JAL op=1101111 / JALR op=1100111
assign  Branch = op[6] & op[5] & (~op[4]);

//JALR op=1100111
assign  JALR = (~op[4]) & (~op[3]) & op[2];

//JAL op = 1101111
assign  JAL = op[3] & op[2] & op[1] & op[0];

//LW op=0000011
assign  MemRead = ~(op[6] | op[5] | op[4]);

//S-type
/*
assign  MemWrite[0] = (~op[6]) & op[5] & (~op[4]);
assign  MemWrite[1] = (~op[6]) & op[5] & (~op[4]) & (funct3[0] | funct3[1]);
assign  MemWrite[2] = (~op[6]) & op[5] & (~op[4]) & funct3[1];
assign  MemWrite[3] = MemWrite[2];
*/
/*
assign  MemWrite[0] = op[6] | (~op[5]) | op[4];
assign  MemWrite[1] = op[6] | (~op[5]) | op[4] | ((~funct3[0]) & (~funct3[1]));
assign  MemWrite[2] = op[6] | (~op[5]) | op[4] | (~funct3[1]);
assign  MemWrite[3] = MemWrite[2];
*/
assign  MemWrite = (~op[6]) & op[5] & (~op[4]);

//I-type op=0000011/0010011 / S-type op=0100011
assign  ALUSrc = (~op[6]) & (~(op[5] & op[4]));

//not(S-type op=0100011 / B-type op=1100011)
assign  RegWrite = (~op[5]) | op[4] | op[3] | op[2];

//B-type op=1100011
//assign  ALUOp[0] = op[6] & op[5];
assign  ALUOp[0] = op[4] & (~op[5]);    //I-type
//R-type op=0110011 / I-type op=0010011
//assign  ALUOp[1] = op[4];
assign  ALUOp[1] = op[4] & op[5];   //R-type


//LW op=0000011
assign  MemtoReg = (op!=7'b0000011);

//B-type op=1100011 / JAL op=1101111 / JALR op=1100111
assign  Flush = Branch & branch_taken & (~Stall);

//CSR
assign  CSR_ctrl = {inst27,inst21};
assign  CSR_inst = op[6] & op[5] & op[4];


endmodule