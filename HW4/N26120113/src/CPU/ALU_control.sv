module ALU_control(
    ALUOp,
    ID_EX_PCtoReg_ctrl,
    ID_EX_csr,
    funct7_3,
    ALU_ctrl
);
input           ID_EX_PCtoReg_ctrl, ID_EX_csr;
input       [1:0]ALUOp;
input       [4:0]funct7_3;
output  reg[3:0]ALU_ctrl;

always @(*) begin
    if(ID_EX_PCtoReg_ctrl)  ALU_ctrl = 4'd14;
    else if(ID_EX_csr)  ALU_ctrl = 4'd15;
    else if(ALUOp==2'd0)    ALU_ctrl = 4'd0;    //add
    else begin
        case(funct7_3[2:0]) //funct3
        //3'd0:   ALU_ctrl = (ALUOp[0])? 4'd0 : ((funct7_3[4])? 4'd1 : ((funct7_3[3])? 4'd10 : 4'd0));  //I:add ; R:sub / mul / add 
        3'd0:   ALU_ctrl = (ALUOp[0] | (~funct7_3[4] & ~funct7_3[3]))? 4'd0 : ((funct7_3[3])? 4'd10 : 4'd1);
        3'd1:   ALU_ctrl = (ALUOp[0] | ~funct7_3[3])? 4'd7 : 4'd11;    //mulh / sll
        3'd2:   ALU_ctrl = (ALUOp[0] | ~funct7_3[3])? 4'd5 : 4'd12;    //mulhsu / slt
        3'd3:   ALU_ctrl = (ALUOp[0] | ~funct7_3[3])? 4'd6 : 4'd13;    //mulhu / sltu
        3'd4:   ALU_ctrl = 4'd4;    //xor
        3'd5:   ALU_ctrl = (funct7_3[4])? 4'd9 : 4'd8;  //sra / srl
        3'd6:   ALU_ctrl = 4'd3;    //or
        3'd7:   ALU_ctrl = 4'd2;    //and
        endcase
    end
    /*
case(ALUOp)
2'd0:   //LW / S-type
    ALU_ctrl = 4'd0;    //add
//2'd1:   //B-type

default:   //R-type / I-type
begin
    case(funct7_3[2:0]) //funct3
    //3'd0:   ALU_ctrl = (ALUOp[0])? 4'd0 : ((funct7_3[4])? 4'd1 : ((funct7_3[3])? 4'd10 : 4'd0));  //I:add ; R:sub / mul / add 
    3'd0:   ALU_ctrl = (ALUOp[0] | (~funct7_3[4] & ~funct7_3[3]))? 4'd0 : ((funct7_3[3])? 4'd10 : 4'd1);
    3'd1:   ALU_ctrl = (ALUOp[0] | ~funct7_3[3])? 4'd7 : 4'd11;    //mulh / sll
    3'd2:   ALU_ctrl = (ALUOp[0] | ~funct7_3[3])? 4'd5 : 4'd12;    //mulhsu / slt
    3'd3:   ALU_ctrl = (ALUOp[0] | ~funct7_3[3])? 4'd6 : 4'd13;    //mulhu / sltu
    3'd4:   ALU_ctrl = 4'd4;    //xor
    3'd5:   ALU_ctrl = (funct7_3[4])? 4'd9 : 4'd8;  //sra / srl
    3'd6:   ALU_ctrl = 4'd3;    //or
    3'd7:   ALU_ctrl = 4'd2;    //and
    endcase
end
endcase
*/
end

endmodule