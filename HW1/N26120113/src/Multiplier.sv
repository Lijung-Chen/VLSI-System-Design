module  Multiplier(
    clk,
    rst,
    mul_start,
    MULtype,
    Din1,
    Din2,
    EX_MEM_Din1_complement,
    Dout,
    mul_finish 
);

input         clk;
input         rst;
input         mul_start;
input   [1:0]  MULtype;
input  [31:0] Din1, Din2, EX_MEM_Din1_complement;
output         mul_finish;
output  reg[63:0] Dout;


reg           sign;
wire   [63:0]  nDout;
reg   [5:0]   count;
reg   [31:0]  Din1_add;
wire   [32:0]  nDout_left;

assign  mul_finish = (MULtype != 2'd0 && count == 6'd32) || (MULtype == 2'd0) ;

always@(posedge clk or posedge rst)
if(rst)begin
    Dout <= 64'd0;
    count <= 6'd0;
end
else if(mul_start)  begin
    Dout <= {32'd0,Din2};
    count <= 6'd0;
end
else begin
    Dout <= nDout;
    count <= count + 6'd1;
end

/*
always@(*)begin
    if(Dout[0])begin
        //if(MULtype == 2'd2) Din1_add = (count == 6'd31)? (~Din1+32'd1) : Din1;
        if(MULtype == 2'd2) Din1_add = (count == 6'd31)? EX_MEM_Din1_complement : Din1;
        else    Din1_add = Din1;
    end
    else    Din1_add = 32'd0;
end
*/

always@(*)begin
    if(Dout[0] && MULtype == 2'd2 && count == 6'd31)    Din1_add = EX_MEM_Din1_complement;
    else if(Dout[0])    Din1_add = Din1;
    else    Din1_add = 32'd0;
end

assign  nDout_left = {1'b0,Dout[63:32]} + {1'b0,Din1_add};

always@(*)begin
    if(MULtype == 2'd1) sign = (Dout[0])? nDout_left[32] : 1'b0;    //unsigned * unsigned
    else    //signed * signed / signed * unsigned
        if(Dout[63] ^ Din1_add[31]) sign = (Dout[0])? nDout_left[31] : Dout[63];    //different sign
        else sign = (Dout[0])? nDout_left[32] : Dout[63];   //same sign
end

assign  nDout = {sign,nDout_left[31:0],Dout[31:1]}; //shift right


endmodule