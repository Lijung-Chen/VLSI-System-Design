module  branch_comp(
    Branch,
    op2,
    funct3,
    Data_rs1,
    Data_rs2,
    branch_taken
);

input   Branch;
input   op2;
input   [2:0]funct3;
input   [31:0]Data_rs1, Data_rs2;  
output  reg branch_taken;

wire    [31:0]bit_xor, Din1, Din2;
wire    equal, comp_small, comp_small_sign;

assign  Din1 = Data_rs1;
assign  Din2 = Data_rs2;

assign  bit_xor = Din1 ^ Din2;
assign  equal = ~|bit_xor;

assign  comp_small = (Din1 < Din2);
assign  comp_small_sign = ($signed(Din1) < $signed(Din2));
/*

always @(*) begin
    if(~Branch) branch_taken = 0;
    else    begin
        if(op2) branch_taken = 1;   //JAL / JALR
        else //B-type
            case(funct3[2:1])
            2'b00:  branch_taken = funct3[0] ^ equal;  //beq / bne
            2'b10:  branch_taken = funct3[0] ^ ($signed(Din1) < $signed(Din2)); //blt / bge
            default:    branch_taken = funct3[0] ^ (Din1 < Din2); //bltu / bgeu
            endcase
    end
end
*/

/*
always @(*) begin
	case({Branch,op2})
	2'b11: branch_taken = 1;   //JAL / JALR
	2'b10: begin
		case(funct3[2:1])
		    2'b00:  branch_taken = funct3[0] ^ equal;  //beq / bne
		    2'b10:  branch_taken = funct3[0] ^ comp_small_sign; //blt / bge
		    default:    branch_taken = funct3[0] ^ comp_small; //bltu / bgeu
	      endcase
	end
	default: branch_taken = 0;
	endcase
end
*/

always @(*) begin
	case({Branch,op2,funct3[2:1]})
	4'b1100: branch_taken = 1;   //JAL / JALR
	4'b1101: branch_taken = 1;   //JAL / JALR
	4'b1110: branch_taken = 1;   //JAL / JALR
	4'b1111: branch_taken = 1;   //JAL / JALR
	4'b1000: branch_taken = funct3[0] ^ equal;  //beq / bne
	4'b1010: branch_taken = funct3[0] ^ comp_small_sign; //blt / bge
	4'b1011: branch_taken = funct3[0] ^ comp_small; //bltu / bgeu
	default: branch_taken = 0;
	endcase
end


endmodule
