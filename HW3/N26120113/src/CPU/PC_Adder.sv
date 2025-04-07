module PC_Adder(
    clk,
    rst,
    IM_busy,
    DM_busy,
    Flush,
    JALR,
    U_AUIPC,
    WFI_mode,
    PC,
    mtvec_PC,
    mepc_PC,
    interrupt_taken,
    MRET,
    imm32,
    Data_rs1,
    New_PC,
    PC_branch,
    PCAdd4
);

input   clk, rst, IM_busy, DM_busy, Flush, JALR, U_AUIPC, interrupt_taken, MRET, WFI_mode;
input   [31:0]  PC, imm32, Data_rs1, mtvec_PC, mepc_PC;    
output  [31:0]  New_PC, PC_branch, PCAdd4;

logic   [31:0]  choice, PC_branch, PCAdd4;
logic           DM_busy_reg;

always@(posedge clk)
if(rst) DM_busy_reg <= 1'b0;
else    DM_busy_reg <= DM_busy;

assign  choice = (~JALR | U_AUIPC)? (PC - 32'd4) : Data_rs1;
assign  PC_branch = choice + imm32 ;
assign  PCAdd4 = PC+32'd4;

//assign  New_PC = (interrupt_taken) ? mtvec_PC : (MRET) ? mepc_PC : (Flush) ? PC_branch : ((IM_busy | DM_busy | WFI_mode)? PC : PCAdd4);
assign  New_PC = (interrupt_taken) ? mtvec_PC : (MRET) ? mepc_PC : (Flush) ? PC_branch : ((IM_busy | DM_busy_reg | WFI_mode)? PC : PCAdd4);


endmodule