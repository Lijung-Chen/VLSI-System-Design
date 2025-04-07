module  Forwarding_ID(
    EX_MEM_RegWrite,
    EX_MEM_Rd,
    MEM_WB_RegWrite,
    MEM_WB_Rd,
    IF_ID_RS1,
    IF_ID_RS2,
    RS1_Data,
    RS2_Data,
    EX_MEM_ALU_result,
    WB_RegData,
    Data_rs1,
    Data_rs2
);
input           EX_MEM_RegWrite, MEM_WB_RegWrite;
input   [4:0]   EX_MEM_Rd, MEM_WB_Rd, IF_ID_RS1, IF_ID_RS2;
input   [31:0]  RS1_Data,
                RS2_Data,
                EX_MEM_ALU_result,
                WB_RegData;
output  reg[31:0]Data_rs1,
                Data_rs2;

reg [1:0]   Forward1, Forward2;

always@(*) begin
    if(EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == IF_ID_RS1) //lw+R (<= 2 clk)??
        Forward1 = 2'b01;
    else if(MEM_WB_RegWrite && MEM_WB_Rd != 0 && MEM_WB_Rd == IF_ID_RS1)    //R+R / R+S / lw+R (3 clk)
        Forward1 = 2'b11;
    else
        Forward1 = 2'b00;
end

always@(*) begin
    case(Forward1)
    2'b00:  Data_rs1 = RS1_Data;
    2'b01:  Data_rs1 = EX_MEM_ALU_result;
    default:    Data_rs1 = WB_RegData;
    endcase
end

always@(*) begin
    if(EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == IF_ID_RS2) //lw+R (2 clk)??
        Forward2 = 2'b01;
    else if(MEM_WB_RegWrite && MEM_WB_Rd != 0 && MEM_WB_Rd == IF_ID_RS2)    //R+R / R+S / lw+R (3 clk)
        Forward2 = 2'b11;
    else
        Forward2 = 2'b00;
end

always@(*) begin
    case(Forward2)
    2'b00:  Data_rs2 = RS2_Data;    //ID
    2'b01:  Data_rs2 = EX_MEM_ALU_result;   //MEM
    default:    Data_rs2 = WB_RegData;  //WB
    endcase
end

endmodule

/*
module  Forwarding_ID(
    ID_EX_RegWrite,
    ID_EX_Rd,
    EX_MEM_RegWrite,
    EX_MEM_Rd,
    MEM_WB_RegWrite,
    MEM_WB_Rd,
    IF_ID_RS1,
    IF_ID_RS2,
    RS1_Data,
    RS2_Data,
    EX_MEM_ALU_result,
    ALU_result,
    WB_RegData,
    Data_rs1,
    Data_rs2
);
input           ID_EX_RegWrite, EX_MEM_RegWrite, MEM_WB_RegWrite;
input   [4:0]   ID_EX_Rd, EX_MEM_Rd, MEM_WB_Rd, IF_ID_RS1, IF_ID_RS2;
input   [31:0]  RS1_Data,
                RS2_Data,
                EX_MEM_ALU_result,
                ALU_result,
                WB_RegData;
output  reg[31:0]Data_rs1,
                Data_rs2;

reg [1:0]   Forward1, Forward2;

always@(*) begin
    if(ID_EX_RegWrite && ID_EX_Rd != 0 && ID_EX_Rd == IF_ID_RS1)  //R+J (<= 2 clk)
        Forward1 = 2'b10;
    else if(EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == IF_ID_RS1) //lw+R (<= 2 clk)??
        Forward1 = 2'b01;
    else if(MEM_WB_RegWrite && MEM_WB_Rd != 0 && MEM_WB_Rd == IF_ID_RS1)    //R+R / R+S / lw+R (3 clk)
        Forward1 = 2'b11;
    else
        Forward1 = 2'b00;
end

always@(*) begin
    case(Forward1)
    2'b00:  Data_rs1 = RS1_Data;
    2'b01:  Data_rs1 = EX_MEM_ALU_result;
    2'b10:  Data_rs1 = ALU_result;
    default:    Data_rs1 = WB_RegData;
    endcase
end

always@(*) begin
    if(ID_EX_RegWrite && ID_EX_Rd != 0 && ID_EX_Rd == IF_ID_RS2)  //R+J,B (1 clk)
        Forward2 = 2'b10;
    else if(EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == IF_ID_RS2) //lw+R (2 clk)??
        Forward2 = 2'b01;
    else if(MEM_WB_RegWrite && MEM_WB_Rd != 0 && MEM_WB_Rd == IF_ID_RS2)    //R+R / R+S / lw+R (3 clk)
        Forward2 = 2'b11;
    else
        Forward2 = 2'b00;
end

always@(*) begin
    case(Forward2)
    2'b00:  Data_rs2 = RS2_Data;    //ID
    2'b01:  Data_rs2 = EX_MEM_ALU_result;   //MEM
    2'b10:  Data_rs2 = ALU_result;  //EX
    default:    Data_rs2 = WB_RegData;  //WB
    endcase
end

endmodule
*/