module Register_File(
    clk,
    rst,
    WB_RegWrite,
    Read_reg1,
    Read_reg2,
    WB_Write_reg,
    WB_Write_data,
    Read_data1,
    Read_data2
);
input   clk, rst;
input   WB_RegWrite;
input   [4:0] Read_reg1, Read_reg2, WB_Write_reg;
input   [31:0] WB_Write_data;
output  [31:0] Read_data1, Read_data2;

reg     [31:0] register [0:31];
//integer i;
reg     [5:0]   i;

always@(posedge clk or posedge rst)
if(rst) begin
    for(i=6'd0; i<6'd32; i=i+6'd1)
        register[i] <= 32'd0;
end
else
    register[WB_Write_reg] <= (WB_RegWrite && WB_Write_reg != 5'd0)? WB_Write_data : register[WB_Write_reg];


assign Read_data1 = register[Read_reg1];
assign Read_data2 = register[Read_reg2];

endmodule