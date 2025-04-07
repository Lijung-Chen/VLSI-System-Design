//=========================EX stage=========================
module  MUX_forwarding(
    Forward1,
    Forward2,
    ID_EX_RS1_data,
    ID_EX_RS2_data,
    EX_MEM_ALU_result,
    WB_RegData,
    WB_RegData_out,
    D1,
    D2
);
input       [1:0]   Forward1, Forward2;
input       [31:0]  ID_EX_RS1_data,
                    ID_EX_RS2_data,
                    EX_MEM_ALU_result,
                    WB_RegData,
                    WB_RegData_out;
output  reg[31:0]   D1, D2;

always@(*)
case(Forward1)
2'b00:  D1 = ID_EX_RS1_data;
2'b01:  D1 = WB_RegData;
2'b11:  D1 = WB_RegData_out;
default:    D1 = EX_MEM_ALU_result;
endcase

always@(*)
case(Forward2)
2'b00:  D2 = ID_EX_RS2_data;
2'b01:  D2 = WB_RegData;
2'b11:  D2 = WB_RegData_out;
default:    D2 = EX_MEM_ALU_result;
endcase

endmodule

