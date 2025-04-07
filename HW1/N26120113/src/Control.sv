module Control(
    op,
    funct3,     //for load /S-type
    funct7_0,
    inst27,
    inst21,
    branch_taken,   //B-type=0/1, JAL/JALR=1
    Branch,
    Stall,
    JALR,
    JAL,
    U_AUIPC,
    U_LUI,
    MULtype,
    mul_start,
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
input   funct7_0, branch_taken, inst27, inst21, Stall;
output  Branch,
        JALR,
        JAL,
        U_AUIPC,
        U_LUI,
        mul_start,
        MemRead,
        MemWrite,
        MemtoReg,
        ALUSrc,
        RegWrite,
        Flush,
        NOP,
        CSR_inst,
        PCtoReg_ctrl;
output  [1:0]MULtype,
            ALUOp,
            //MemtoReg,  
            CSR_ctrl;
//output  [3:0]MemWrite;

reg     [1:0]MULtype;

always@(*)begin
    if(op==7'b0110011)
    case({funct7_0,funct3[1:0]})
    3'b100: MULtype = 2'd1; //MUL(unsigned * unsigned)
    3'b101: MULtype = 2'd2; //MULH(signed * signed)
    3'b110: MULtype = 2'd3; //MULHSU(signed * unsigned)
    3'b111: MULtype = 2'd1; //MULHU(unsigned * unsigned)
    default:    MULtype = 2'd0; //Not multiplication
    endcase
    else    MULtype = 2'd0; //Not multiplication
end

assign  mul_start = (MULtype != 2'd0);
//PC forwarding
assign  PCtoReg_ctrl = JALR | JAL | U_AUIPC | U_LUI;


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