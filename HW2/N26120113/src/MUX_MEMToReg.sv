//=========================WB stage=========================

module  MUX_MEMToReg(
    MEM_WB_funct3,
    MEM_WB_MemtoReg,
    MEMReadData,
    MEM_WB_ALU_result,
    WB_RegData
);

input               MEM_WB_MemtoReg;
input       [2:0]   MEM_WB_funct3;
input       [31:0]  MEMReadData, MEM_WB_ALU_result;
output  reg [31:0]  WB_RegData;

wire    sign_b, sign_h;

assign  sign_b = MEMReadData[7];
assign  sign_h = MEMReadData[15];

always@(*)
case(MEM_WB_funct3 | {MEM_WB_MemtoReg,MEM_WB_MemtoReg,MEM_WB_MemtoReg})
3'b111: WB_RegData = MEM_WB_ALU_result;
//LB
3'b000: WB_RegData = {sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b,
                    sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, MEMReadData[7:0]};
//LH
3'b001: WB_RegData = {sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h,
                    sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, MEMReadData[15:0]};
//LW
3'b010: WB_RegData = MEMReadData;
//LBU
3'b100: WB_RegData = {24'd0,MEMReadData[7:0]};
//LHU
default:WB_RegData = {16'd0,MEMReadData[15:0]};
endcase

//assign  WB_RegData = (MEM_WB_MemtoReg)? LoadData : MEM_WB_ALU_result;


endmodule
