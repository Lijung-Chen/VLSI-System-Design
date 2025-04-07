module  PC(
    clk,
    rst,
    PC_Write,
    I_core_wait,
    D_core_wait,
    MRET,
    WFI,
    interrupt_taken,
    PC_in,
    PC_out
);

input       clk, rst, PC_Write, I_core_wait, D_core_wait, MRET, WFI, interrupt_taken;
input       [31:0]PC_in;
output  reg [31:0]PC_out;

always@(posedge clk)
if(rst)
    //PC_out <= 32'd0;
    PC_out <= 32'hffff_fffc;

else if(WFI)
    PC_out <= PC_out;

//else if(I_core_wait | D_core_wait)
//else if((I_core_wait | D_core_wait) & ~MRET)
else if((I_core_wait | D_core_wait) & ~MRET & ~interrupt_taken)
    PC_out <= PC_out;

else
    PC_out <= (PC_Write)? PC_in : PC_out;

endmodule