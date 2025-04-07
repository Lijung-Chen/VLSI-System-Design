//stalling pipeline
module  Hazard_detection(
    Branch,
    Btype,
    JALR,
    ID_EX_MemRead,
    ID_EX_Rd,
    EX_MEM_MemRead,
    EX_MEM_Rd,
    ID_EX_RegWrite,
    IF_ID_RS1,
    IF_ID_RS2,
    IF_ID_Write,
    PC_Write,
    Stall
);

input       Branch, Btype, JALR, ID_EX_MemRead, EX_MEM_MemRead, ID_EX_RegWrite;
input       [4:0]ID_EX_Rd, EX_MEM_Rd, IF_ID_RS1, IF_ID_RS2;
output  reg IF_ID_Write, PC_Write, Stall;

always@(*)begin
    if(ID_EX_MemRead && (ID_EX_Rd == IF_ID_RS1 || ID_EX_Rd == IF_ID_RS2)) begin //lw+R
        IF_ID_Write = 1'b0;
        PC_Write = 1'b0;
        Stall = 1'b1;
    end
    //else if(Branch && EX_MEM_MemRead && (EX_MEM_Rd == IF_ID_RS1 || EX_MEM_Rd == IF_ID_RS2)) begin   //lw+B
    else if(Btype && EX_MEM_MemRead && (EX_MEM_Rd == IF_ID_RS1 || EX_MEM_Rd == IF_ID_RS2)) begin   //lw+B
        IF_ID_Write = 1'b0;
        PC_Write = 1'b0;
        Stall = 1'b1;
    end
    //else if(Branch && ID_EX_RegWrite && (ID_EX_Rd == IF_ID_RS1 || ID_EX_Rd == IF_ID_RS2)) begin   //R+B
    else if(Btype && ID_EX_RegWrite && (ID_EX_Rd == IF_ID_RS1 || ID_EX_Rd == IF_ID_RS2)) begin   //R+B
        IF_ID_Write = 1'b0;
        PC_Write = 1'b0;
        Stall = 1'b1;
    end
    else if(JALR && ID_EX_RegWrite && (ID_EX_Rd == IF_ID_RS1)) begin   //R+B
        IF_ID_Write = 1'b0;
        PC_Write = 1'b0;
        Stall = 1'b1;
    end
    else begin
        IF_ID_Write = 1'b1;
        PC_Write = 1'b1;
        Stall = 1'b0;
    end
end

endmodule