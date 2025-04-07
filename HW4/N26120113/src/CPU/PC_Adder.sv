module PC_Adder(
    input               clk,
    input               rst,
    input               I_core_wait,
    input               D_core_wait,
    input               Flush,
    input               JALR,
    input               U_AUIPC,
    input               WFI_mode,
    input               interrupt_taken,
    input               MRET,
    input   [31:0]      PC,
    input   [31:0]      mtvec_PC,
    input   [31:0]      mepc_PC,
    input   [31:0]      imm32,
    input   [31:0]      Data_rs1,
    output  logic [31:0]New_PC,
    output  logic [31:0]PC_branch,
    output  logic [31:0]PCAdd4
);

logic   [31:0]  choice;
logic           PC_stall;
logic   [31:0]  PC_branch_reg;
logic   [1:0]   cs ,ns;
logic   [1:0]   interrupt_cs, interrupt_ns;

/*
always_comb
if(rst) PC_stall = 1'b0;
else    PC_stall = I_core_wait | D_core_wait;
*/
assign  choice = (~JALR | U_AUIPC)? (PC - 32'd4) : Data_rs1;
assign  PC_branch = choice + imm32 ;
assign  PCAdd4 = PC+32'd4;

//-------------------branch taken----------------------
always_ff@(posedge clk)
if(rst) PC_branch_reg <= 32'd0;
else if(Flush & I_core_wait)    PC_branch_reg <= PC_branch;
else    PC_branch_reg <= PC_branch_reg;

always_ff@(posedge clk)
if(rst) cs <= 2'd0;
else    cs <= ns;

always_comb
case(cs)
    2'd0:   ns = (Flush & I_core_wait)? 2'd1 : 2'd0;
    2'd1:   ns = (I_core_wait)? 2'd1 : 2'd2;
    default:   ns = 2'd0;
endcase

//--------------------interrupt taken-----------------------
always_ff@(posedge clk)
if(rst) interrupt_cs <= 2'd0;
else    interrupt_cs <= interrupt_ns;

always_comb
case(interrupt_cs)
    2'd0:   interrupt_ns = (I_core_wait & interrupt_taken)? 2'd1 : 2'd0;
    2'd1:   interrupt_ns = (I_core_wait)? 2'd1 : 2'd2;
    default:    interrupt_ns = 2'd0;
endcase


always_comb
if(interrupt_taken) 
    New_PC = mtvec_PC;

else if(interrupt_cs == 2'd1)
    New_PC = PC;

else if(MRET)   
    New_PC = mepc_PC;

else if(Flush)  
    New_PC = PC_branch;   //**
    //New_PC = (I_core_wait)? PC : PC_branch;

else if(cs == 2'd1)
    New_PC = PC_branch_reg;

else if(I_core_wait | WFI_mode | D_core_wait)  //**
    New_PC = PC;

else    
    New_PC = PCAdd4;

endmodule