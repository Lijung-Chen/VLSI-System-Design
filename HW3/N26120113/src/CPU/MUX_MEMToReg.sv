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

assign  sign_b = (MEM_WB_ALU_result[1:0]==2'b00) ? MEMReadData[7] : (MEM_WB_ALU_result[1:0]==2'b01) ? MEMReadData[15] : (MEM_WB_ALU_result[1:0]==2'b10) ? MEMReadData[23] : MEMReadData[31];
assign  sign_h = (MEM_WB_ALU_result[1]) ? MEMReadData[31] : MEMReadData[15];


always@(*)
begin 
    if(MEM_WB_MemtoReg)
    begin 
        WB_RegData = MEM_WB_ALU_result;
    end
    else
    begin 
        case(MEM_WB_funct3)
            //LB
            3'b000: 
            case(MEM_WB_ALU_result[1:0])
                2'd0:   WB_RegData = {sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b,
                                    sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, MEMReadData[7:0]};
                2'd1:   WB_RegData = {sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b,
                                    sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, MEMReadData[15:8]};
                2'd2:   WB_RegData = {sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b,
                                    sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, MEMReadData[23:16]};
                2'd3:   WB_RegData = {sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b,
                                    sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, sign_b, MEMReadData[31:24]};
            endcase
            //LH
            3'b001: 
            if(MEM_WB_ALU_result[1])
                WB_RegData = {sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h,
                            sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, MEMReadData[31:16]};
            else    
                WB_RegData = {sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h,
                            sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, sign_h, MEMReadData[15:0]};
            //LW
            3'b010: WB_RegData = MEMReadData;
            //LBU
            3'b100: 
            case(MEM_WB_ALU_result[1:0])
                2'd0:   WB_RegData = {24'd0,MEMReadData[7:0]};
                2'd1:   WB_RegData = {24'd0,MEMReadData[15:8]};
                2'd2:   WB_RegData = {24'd0,MEMReadData[23:16]};
                2'd3:   WB_RegData = {24'd0,MEMReadData[31:24]};
            endcase
            //LHU
            default:
            if(MEM_WB_ALU_result[1])
                WB_RegData = {16'd0,MEMReadData[31:16]};
            else
                WB_RegData = {16'd0,MEMReadData[15:0]};
        endcase
    end
end


endmodule
