module Instruction_Decode(
//INPUT
    inst,
    Stall,
    DM_busy,
    IM_busy,
    branch_taken,   //B-type=0/1, JAL/JALR=1
//OUTPUT
    Branch,
    Btype,
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
    CSR_RegWrite,
    CSR_ctrl,   //for CSR
    CSR_inst,
    MRET,
    WFI,
    PCtoReg_ctrl
);
input   [31:0]  inst;
input           branch_taken, Stall, DM_busy, IM_busy;
output          Branch,
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
                CSR_RegWrite,
                CSR_inst,
                MRET,
                WFI,
                PCtoReg_ctrl;
output          [1:0]   ALUOp;
output  logic   [3:0]   CSR_ctrl;

logic   [6:0]   op;
logic   [2:0]   funct3;
logic   [4:0]   rs1;

assign  op = inst[6:0];
assign  funct3 = inst[14:12];   //for load /S-type
assign  rs1 = inst[19:15];


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
assign  MemWrite = (~op[6]) & op[5] & (~op[4]);

//I-type op=0000011/0010011 / S-type op=0100011
assign  ALUSrc = (~op[6]) & (~(op[5] & op[4]));

//not(S-type op=0100011 / B-type op=1100011)
assign  RegWrite = ((~op[5]) | op[4] | op[3] | op[2]) & (~MRET) & (~WFI);

//R-type op=0110011 / I-type op=0010011
assign  ALUOp[0] = op[4] & (~op[5]);    //I-type
assign  ALUOp[1] = op[4] & op[5];   //R-type

//LW op=0000011
assign  MemtoReg = (op!=7'b0000011);

//B-type op=1100011 / JAL op=1101111 / JALR op=1100111
//assign  Flush = Branch & branch_taken & (~Stall);
assign  Flush = Branch & branch_taken & (~Stall & ~DM_busy);

//CSR
//assign  CSR_ctrl = {inst27,inst21};
assign  CSR_inst = op[6] & op[5] & op[4];
assign  CSR_RegWrite = CSR_inst & (rs1 != 5'd0 || funct3 == 3'b001 || funct3 == 3'b101);
assign  MRET = CSR_inst & (inst[31:20] == 12'b0011_0000_0010);
assign  WFI = CSR_inst & (inst[31:20] == 12'b0001_0000_0101);
always_comb begin
    if(CSR_RegWrite)begin
        case(funct3)
            3'b001: CSR_ctrl = 4'd0;    //CSRRW
            3'b010: CSR_ctrl = 4'd1;    //CSRRS
            3'b011: CSR_ctrl = 4'd2;    //CSRRC
            3'b101: CSR_ctrl = 4'd3;    //CSRRWI
            3'b110: CSR_ctrl = 4'd4;    //CSRRSI
            default:    CSR_ctrl = 4'd5;    //CSRRCI
        endcase
    end
    else    begin
        case({inst[27],inst[21]})
            2'b00:  CSR_ctrl = 4'd6;    //RDCYCLE
            2'b01:  CSR_ctrl = 4'd7;    //RDINSTRET
            2'b10:  CSR_ctrl = 4'd8;    //RDCYCLEH
            default:    CSR_ctrl = 4'd9;    //RDINSTRETH
        endcase
    end
end


endmodule