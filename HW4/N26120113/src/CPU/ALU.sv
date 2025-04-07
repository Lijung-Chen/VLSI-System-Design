module ALU(
    PC,
    ALU_ctrl,
    Din1,
    //Din2,
    rs2,
    ID_EX_PCtoReg,
    CSRData_toRd,
    //Zero,
    Dout
);
input       [3:0]ALU_ctrl;
input       [31:0]Din1, rs2, ID_EX_PCtoReg, CSRData_toRd, PC;//, Din2
//output  Zero;
output  reg [31:0]Dout;

wire signed [63:0]mul;
reg signed  [63:0]din1, din2;
logic   [31:0]Din2;
 
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
    case(ALU_ctrl[1:0])
    2'd3:  begin
        din1 = $signed(Din1);
        din2 = $signed(Din2);
    end
    2'd0:  begin
        din1 = $signed(Din1);
        din2 = $signed({1'b0,Din2});
    end
    default:    begin
        din1 = $signed({1'b0,Din1});
        din2 = $signed({1'b0,Din2});
    end
    endcase
end

assign  mul = din1 * din2;

//assign  Din2 = (PC == 32'h10084)? 32'd0 : rs2;
assign  Din2 = rs2;

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
4'd14:  Dout = ID_EX_PCtoReg;
4'd15:  Dout = CSRData_toRd;
4'd10:  Dout = mul[31:0];
default:    Dout = mul[63:32];
endcase 
end

endmodule