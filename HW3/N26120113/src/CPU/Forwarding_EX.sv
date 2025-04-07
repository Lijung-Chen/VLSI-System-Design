module  Forwarding_EX(
     EX_MEM_RegWrite,
     EX_MEM_Rd,
     MEM_WB_RegWrite,
     MEM_WB_Rd,
     WB_RegWrite,
     WB_Rd,
     ID_EX_RS1,
     ID_EX_RS2,
     Forward1,
     Forward2
);

input       EX_MEM_RegWrite, MEM_WB_RegWrite, WB_RegWrite;
input       [4:0]EX_MEM_Rd, MEM_WB_Rd, WB_Rd, ID_EX_RS1, ID_EX_RS2;
output  reg [1:0]Forward1, Forward2;

always@(*)begin
    if(EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == ID_EX_RS1)  //R+R / R+S (<= 2 clk)
        Forward1 = 2'b10;
    else if(MEM_WB_RegWrite && MEM_WB_Rd != 0 && MEM_WB_Rd == ID_EX_RS1) //lw+R (<= 2 clk)
        Forward1 = 2'b01;
    else if(WB_RegWrite && WB_Rd != 0 && WB_Rd == ID_EX_RS1)    //R+R / R+S / lw+R (3 clk)
        Forward1 = 2'b11;
    else
        Forward1 = 2'b00;
end

always@(*)begin
    if(EX_MEM_RegWrite && EX_MEM_Rd != 0 && EX_MEM_Rd == ID_EX_RS2)  //R+R / R+S
        Forward2 = 2'b10;
    else if(MEM_WB_RegWrite && MEM_WB_Rd != 0 && MEM_WB_Rd == ID_EX_RS2) //lw+R
        Forward2 = 2'b01;
    else if(WB_RegWrite && WB_Rd != 0 && WB_Rd == ID_EX_RS2)
        Forward2 = 2'b11;
    else
        Forward2 = 2'b00;
end
endmodule


