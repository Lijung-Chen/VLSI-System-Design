module ALU(
    ALU_ctrl,
    Din1,
    Din2,
    ID_EX_PCtoReg,
    CSR_Data,
    mul_out,
    Dout
);
input       [3:0]ALU_ctrl;
input       [31:0]Din1, Din2, ID_EX_PCtoReg, CSR_Data;
input       [63:0]mul_out;
//output  Zero;
output  reg [31:0]Dout;

reg     [63:0]mul;
 
/*
always@(*)begin
    case(ALU_ctrl[1:0])
    2'd3:  mul = $signed(Din1) * $signed(Din2);
    2'd0:  mul = $signed(Din1) * $signed({1'b0,Din2});
    default:    mul = Din1 * Din2;
    endcase
end
*/
always@(*)begin
case(ALU_ctrl)
4'd0:   Dout = Din1 + Din2;
4'd1:   Dout = Din1 - Din2;
4'd2:   Dout = Din1 & Din2;
4'd3:   Dout = Din1 | Din2;
4'd4:   Dout = Din1 ^ Din2;
4'd5:   Dout = ($signed(Din1) < $signed(Din2));
4'd6:   Dout = (Din1 < Din2); //sltu
4'd7:   Dout = Din1 << Din2[4:0];   //sll
4'd8:   Dout = Din1 >> Din2[4:0];   //srl
4'd9:   Dout = $signed(Din1) >>> Din2[4:0];  //sra
4'd12:  Dout = ~Din1 + 32'd1;
4'd14:  Dout = ID_EX_PCtoReg;
4'd15:  Dout = CSR_Data;
4'd10:  Dout = mul_out[31:0];
default:    Dout = mul_out[63:32];
endcase 
end

endmodule