module  reg_IF_ID(
    input               clk,
    input               rst,
    input               I_core_wait,
    input               D_core_wait,
    //input               ID_flush,
    //input               DM_busy,
    //input               IM_busy,
    //input               RVALID_M0,
    input               WFI,
    input               WFI_mode,
    input               interrupt_taken,
    input               MRET,
    input               Stall,
    input               IF_ID_Write,
    input               Flush,
    input   [31:0]      inst_in,
    input   [31:0]      PCAdd4_in,
    output  logic[31:0] inst_out,
    output  logic[31:0] IF_ID_PCAdd4
);

logic   ID_flush;
logic   I_core_wait_reg;

always_ff@(posedge clk)
if(rst) I_core_wait_reg <= 1'b0;
else    I_core_wait_reg <= I_core_wait;

always_ff@(posedge clk)
if(rst) ID_flush <= 1'b0;
else if(Flush & I_core_wait) ID_flush <= 1'b1;
else if(ID_flush & ~I_core_wait)    ID_flush <= 1'b0;
else    ID_flush <= ID_flush;

always_ff@(posedge clk)
if(rst)begin
    inst_out <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end

//else if(DM_busy & ~RVALID_M0)
else if(D_core_wait)  begin
    inst_out <= inst_out;
    IF_ID_PCAdd4 <= IF_ID_PCAdd4;
end

else if(MRET)   begin
    inst_out <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end  

//else if(interrupt_taken)    begin
else if(interrupt_taken | WFI | WFI_mode)    begin
    inst_out <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end  

else if(ID_flush | Flush | (I_core_wait & ~Stall )) begin     //**
//else if(ID_flush | Flush | (I_core_wait_reg & ~Stall )) begin
    inst_out <= 32'd0;
    IF_ID_PCAdd4 <= 32'd0;
end 

else begin
    inst_out <= (IF_ID_Write)? inst_in : inst_out;
    IF_ID_PCAdd4 <= (IF_ID_Write)? PCAdd4_in : IF_ID_PCAdd4;
end

endmodule



