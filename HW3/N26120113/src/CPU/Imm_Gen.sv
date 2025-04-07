module Imm_Gen(
    inst,
    imm32
);

input   [31:0]inst;
output  reg[31:0]imm32;

wire    sign;

assign  sign = inst[31];

always @(*) begin
    
if(inst[3]&inst[2]&inst[1]&inst[0])  //J-type
    imm32 = {sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,
            sign,sign,inst[19:12],inst[20],inst[30:21],1'b0};

else if(inst[2]&inst[1]&inst[0])   
    if(inst[6:4] == 3'd6)   //JALR
        imm32 = {sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,
                sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,inst[31:20]};
    else    //U-type
        imm32 = {inst[31:12],12'd0};

else
    case(inst[6:4])
    3'd2:   //S-type
        imm32 = {sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,
                sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,inst[31:25],inst[11:7]};
    3'd6:   //B-type
        imm32 = {sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,
                sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,inst[7],inst[30:25],inst[11:8],1'b0};
    default:    //LW / I-type / CSR
        imm32 = {sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,
                sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,inst[31:20]};
    endcase
end

endmodule