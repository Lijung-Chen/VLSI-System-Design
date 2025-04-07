`include "./CPU/PC.sv"
`include "./CPU/PC_Adder.sv"
`include "./CPU/ALU.sv"
`include "./CPU/ALU_control.sv"
`include "./CPU/Instruction_Decode.sv"
`include "./CPU/branch_comp.sv"
`include "./CPU/ALU_CSR.sv"
`include "./CPU/Forwarding_ID.sv"
`include "./CPU/Forwarding_EX.sv"
`include "./CPU/Hazard_detection.sv"
`include "./CPU/Imm_Gen.sv"
`include "./CPU/MUX_ID.sv"
`include "./CPU/MUX_PCtoReg.sv"
`include "./CPU/MUX_forwarding.sv"
`include "./CPU/MUX_imm.sv"
`include "./CPU/MUX_Storetype.sv"
`include "./CPU/MUX_MEMToReg.sv"
`include "./CPU/reg_IF_ID.sv"
`include "./CPU/reg_ID_EX.sv"
`include "./CPU/reg_EX_MEM.sv"
`include "./CPU/reg_MEM_WB.sv"
`include "./CPU/reg_WB.sv"
`include "./CPU/Register_File.sv"
`include "./CPU/CSR_regfile.sv"
`include "./CPU/interrupt_control.sv"

module CPU (
    // Clock and Reset Signal
    input                   clk,
    input                   rst,
    input                   ID_flush,
    // Instruction Memory is busy, CPU need to Stall
    input                   IM_busy, 
    // Data Memory is busy, CPU need to Stall       
    input                   DM_busy, 
    input                   RVALID_M0,
    // Sensor Control Interrupt
    input                   SENSOR_CTRL_interrupt, 
    // WDT Interrupt  
    input                   WDT_interrupt,
    // Output Instructions from Instruction Memory    
    input           [31:0]  MEMReadInst,  
    // Output Data From Data Memory  
    input           [31:0]  MEMReadData,
    // Input Address to Instruction Memory    
    output  logic   [31:0]  inst_PC, 
    // Input Address to Data Memory       
    output  logic   [31:0]  DM_A,   
    // Write enable of Data Memory        
    output  logic   [3:0]   DM_WEB,   
    // Input Data to Data Memory      
    output  logic   [31:0]  DM_DI, 
    // Read and Write requests of CPU to Memory                   
    output  logic   ID_EX_MemWrite, 
    output  logic   EX_MEM_MemWrite,
    output  logic   ID_EX_MemRead,
    output  logic   EX_MEM_MemRead
);

logic    [31:0]  PC, IF_ID_inst, IF_ID_PCAdd4, New_PC, ReadInst, RS1_Data, RS2_Data, imm32, PC_branch, 
                PCAdd4, PCtoReg, ID_EX_PCtoReg, ID_EX_RS1_data, ID_EX_RS2_data, ID_EX_imm32, D1, D2, Dout2, 
                ALU_result, Dout, EX_MEM_ALU_result, EX_MEM_RS2_Data, CSR_Data, CSR_ALUOut, WB_CSR_Data, 
                CSRData_toRd, ID_EX_CSR_Data, MEM_WB_ALU_result, MEM_WB_MEMReadData, WB_RegData, WB_RegData_out, 
                Data_rs1, Data_rs2, mtvec_PC, mepc_PC;

logic    flush, JALR, Branch, branch_taken, U_AUIPC, U_LUI, Stall, NOP, PCtoReg_ctrl, IF_ID_Write, PC_Write, MemRead, ALUSrc,
        RegWrite, ALUSrc_toReg, MemRead_toReg, RegWrite_toReg, inst_add1_toReg, ID_EX_ALUSrc, ID_EX_RegWrite,
        ID_EX_inst_add1, ID_EX_PCtoReg_ctrl, EX_MEM_RegWrite, MEM_WB_MemRead, MEM_WB_RegWrite, 
        WB_RegWrite, CSR_inst, ID_EX_csr, MemtoReg, MemtoReg_toReg, CSR_inst_toReg, ID_EX_MemtoReg, EX_MEM_MemtoReg, MEM_WB_MemtoReg, MemWrite, 
        MemWrite_toReg, Btype, JAL, DM_OE, CSR_RegWrite, MRET, WFI, CSR_RegWrite_toReg, ID_EX_CSR_RegWrite,
        MEIE, MTIE, interrupt_taken, WFI_mode;
logic   [3:0]   ALU_ctrl, CSR_ctrl, CSR_ctrl_toReg, ID_EX_CSR_ctrl;
logic   [2:0]   ID_EX_funct3, EX_MEM_funct3, MEM_WB_funct3;
logic   [1:0]   ALUOp, ALUOp_toReg, ID_EX_ALUOp, Forward1, Forward2;
logic   [4:0]   ID_EX_funct7_3, ID_EX_Rd, ID_EX_RS1, ID_EX_RS2, EX_MEM_Rd, MEM_WB_Rd, WB_Rd;

logic   [11:0]  ID_EX_CSR_addr;

logic          cs;
/*
logic   SENSOR_CTRL_interrupt, WDT_interrupt;

assign  SENSOR_CTRL_interrupt = 1'b0;
assign  WDT_interrupt = 1'b0;
*/

//assign  DM_A = ALU_result;
assign  DM_A = EX_MEM_ALU_result;   //****

//==========================IF==============================

PC  pc( .clk(clk),
        .rst(rst),
        .PC_Write(PC_Write),
        .PC_in(New_PC),
        .PC_out(PC)
);

reg_IF_ID   reg1(.clk(clk),
                .rst(rst),
                .ID_flush(ID_flush),
                .DM_busy(DM_busy),
                .IM_busy(IM_busy),
                .RVALID_M0(RVALID_M0),
                .interrupt_taken(interrupt_taken),
                .Stall(Stall),
                .IF_ID_Write(IF_ID_Write),
                .Flush(flush),
                .inst_in(MEMReadInst),
                .PCAdd4_in(PCAdd4),
                .inst_out(IF_ID_inst),
                .IF_ID_PCAdd4(IF_ID_PCAdd4)
);

always@(posedge clk)
if(rst) cs <= 1'b0;
else if(~cs & New_PC==32'd0) cs <= 1'b0;
else    cs <= 1'b1;

always_comb begin
    if(Stall)           inst_PC = PC;
    //else if(interrupt_taken)    inst_PC = mtvec_PC;
    //else if(MRET)   inst_PC = mepc_PC;
    else                inst_PC = New_PC;
end

assign  ReadInst = (cs)? IF_ID_inst : 32'd0;

/*
always@(posedge clk)
if(rst) cs <= 2'd0;
else if(cs == 2'd0 & New_PC==32'd0) cs <= 2'd0;
else    if(DM_busy) cs <= 2'd2;
else    cs <= 2'd1;

always_comb begin
    if(Stall)           inst_PC = PC;
    //else if(interrupt_taken)    inst_PC = mtvec_PC;
    //else if(MRET)   inst_PC = mepc_PC;
    else if(cs == 2'd2) inst_PC = PC;
    else                inst_PC = New_PC;
end

assign  ReadInst = (cs == 2'd0)? 32'd0 : IF_ID_inst;
*/
//==========================ID==============================
interrupt_control   interrupt_ctrl( //INPUT
                                    .clk(clk),
                                    .rst(rst),
                                    .Stall(Stall),
                                    .IM_busy(IM_busy),
                                    .DM_busy(DM_busy),
                                    .WFI(WFI),
                                    .MRET(MRET),
                                    .MEIE(MEIE),
                                    .MTIE(MTIE),
                                    .SENSOR_CTRL_interrupt(SENSOR_CTRL_interrupt),
                                    .WDT_interrupt(WDT_interrupt),
                                    //OUTPUT
                                    .interrupt_taken(interrupt_taken),
                                    .WFI_mode(WFI_mode)
);

CSR_regfile     csr_regfile(//INPUT
                            .clk(clk),
                            .rst(rst),
                            .CSR_RegWrite(ID_EX_CSR_RegWrite),
                            .WB_CSR_addr(ID_EX_CSR_addr), 
                            .WB_CSR_Data(CSR_ALUOut),
                            .Read_CSR_addr(ReadInst[31:20]),
                            .interrupt_taken(interrupt_taken),
                            .SENSOR_CTRL_interrupt(SENSOR_CTRL_interrupt),
                            .WDT_interrupt(WDT_interrupt),
                            .MRET(MRET),
                            .WFI_mode(WFI_mode),
                            .PC(PC),
                            //OUTPUT
                            .Read_CSR_Data(CSR_Data),
                            .MEIE(MEIE),
                            .MTIE(MTIE),
                            .mtvec_PC(mtvec_PC),
                            .mepc_PC(mepc_PC)
);

PC_Adder    pc_adder(.clk(clk),
                    .rst(rst),
                    .IM_busy(IM_busy),
                    .DM_busy(DM_busy),
                    .Flush(flush),
                    .JALR(JALR),
                    .U_AUIPC(U_AUIPC),
                    .WFI_mode(WFI_mode),
                    //.IF_ID_PC(IF_ID_PC),
                    .PC(PC),
                    .imm32(imm32),
                    .Data_rs1(Data_rs1),
                    .New_PC(New_PC),
                    .PC_branch(PC_branch),
                    .PCAdd4(PCAdd4),
                    .mtvec_PC(mtvec_PC),
                    .mepc_PC(mepc_PC),
                    .interrupt_taken(interrupt_taken),
                    .MRET(MRET)
);

MUX_PCtoReg mux_pctoreg(.U_AUIPC(U_AUIPC),
                        .U_LUI(U_LUI),
                        .PC(PC),
                        .IF_ID_PCAdd4(IF_ID_PCAdd4),
                        .imm32(imm32),
                        .PC_branch(PC_branch),
                        .PCtoReg(PCtoReg)
);

Instruction_Decode Inst_Dec(//INPUT
                            .inst(ReadInst),
                            .DM_busy(DM_busy),
                            .IM_busy(IM_busy),
                            .Stall(Stall),
                            .branch_taken(branch_taken),   //B-type=0/1, JAL/JALR=1
                            //OUTPUT
                            .Branch(Branch),
                            .Btype(Btype),
                            .JALR(JALR),
                            .JAL(JAL),
                            .U_AUIPC(U_AUIPC),
                            .U_LUI(U_LUI),
                            .MemRead(MemRead),
                            .MemWrite(MemWrite),
                            .MemtoReg(MemtoReg),
                            .ALUOp(ALUOp),
                            .ALUSrc(ALUSrc),
                            .RegWrite(RegWrite),
                            .Flush(flush),
                            .NOP(NOP),
                            .CSR_RegWrite(CSR_RegWrite),
                            .CSR_ctrl(CSR_ctrl),   //for CSR
                            .CSR_inst(CSR_inst),
                            .MRET(MRET),
                            .WFI(WFI),
                            .PCtoReg_ctrl(PCtoReg_ctrl)
);
MUX_ID    mux_ID(.Stall(Stall),
                .NOP(NOP),
                .ALUSrc(ALUSrc),
                .ALUOp(ALUOp),
                .MemRead(MemRead),
                .MemWrite(MemWrite),
                .RegWrite(RegWrite),
                .MemtoReg(MemtoReg),
                .CSR_RegWrite(CSR_RegWrite),
                .CSR_ctrl(CSR_ctrl),
                .CSR_inst(CSR_inst),
                .ALUSrc_toReg(ALUSrc_toReg),
                .ALUOp_toReg(ALUOp_toReg),
                .MemRead_toReg(MemRead_toReg),
                .MemWrite_toReg(MemWrite_toReg),
                .RegWrite_toReg(RegWrite_toReg),
                .MemtoReg_toReg(MemtoReg_toReg),
                .CSR_RegWrite_toReg(CSR_RegWrite_toReg),
                .CSR_inst_toReg(CSR_inst_toReg),
                .CSR_ctrl_toReg(CSR_ctrl_toReg),
                .inst_add1_toReg(inst_add1_toReg)
);

Register_File   reg_file(.clk(clk),
                        .rst(rst),
                        .WB_RegWrite(MEM_WB_RegWrite),
                        .Read_reg1(ReadInst[19:15]),
                        .Read_reg2(ReadInst[24:20]),
                        .WB_Write_reg(MEM_WB_Rd),
                        .WB_Write_data(WB_RegData),
                        .Read_data1(RS1_Data),
                        .Read_data2(RS2_Data)
);

Forwarding_ID   forwarding_ID(  .EX_MEM_RegWrite(EX_MEM_RegWrite),
                                .EX_MEM_Rd(EX_MEM_Rd),
                                .MEM_WB_RegWrite(MEM_WB_RegWrite),
                                .MEM_WB_Rd(MEM_WB_Rd),
                                .IF_ID_RS1(ReadInst[19:15]),
                                .IF_ID_RS2(ReadInst[24:20]),
                                .RS1_Data(RS1_Data),
                                .RS2_Data(RS2_Data),
                                .EX_MEM_ALU_result(EX_MEM_ALU_result),
                                .WB_RegData(WB_RegData),
                                .Data_rs1(Data_rs1),
                                .Data_rs2(Data_rs2)
);

branch_comp branch_comp(.Branch(Branch),
                        .op2(ReadInst[2]),
                        .funct3(ReadInst[14:12]),
                        .Data_rs1(Data_rs1),
                        .Data_rs2(Data_rs2),
                        //.Din1(RS1_Data),
                        //.Din2(RS2_Data),
                        .branch_taken(branch_taken)
);

Imm_Gen imm_gen(.inst(ReadInst),
                .imm32(imm32)
);

Hazard_detection    Hazard_detection(.Branch(Branch),
                                    .Btype(Btype),
                                    .JALR(JALR),
                                    .ID_EX_MemRead(ID_EX_MemRead),
                                    .ID_EX_Rd(ID_EX_Rd),
                                    .EX_MEM_MemRead(EX_MEM_MemRead),
                                    .EX_MEM_Rd(EX_MEM_Rd),
                                    .ID_EX_RegWrite(ID_EX_RegWrite),
                                    .IF_ID_RS1(ReadInst[19:15]),
                                    .IF_ID_RS2(ReadInst[24:20]),
                                    .IF_ID_Write(IF_ID_Write),
                                    .PC_Write(PC_Write),
                                    .Stall(Stall)
);

reg_ID_EX   reg2(.clk(clk),
                .rst(rst),
                .IM_busy(IM_busy),
                .DM_busy(DM_busy),
                .funct3(ReadInst[14:12]),
                .funct7_3({ReadInst[30],ReadInst[25],ReadInst[14:12]}),
                .ALUSrc(ALUSrc_toReg),
                .ALUOp(ALUOp_toReg),
                .MemRead(MemRead_toReg),
                .MemWrite(MemWrite_toReg),
                .RegWrite(RegWrite_toReg),
                .MemtoReg(MemtoReg_toReg),
                .CSR_RegWrite(CSR_RegWrite_toReg),
                .CSR_inst(CSR_inst_toReg),
                .CSR_ctrl(CSR_ctrl_toReg),
                .inst_add1(inst_add1_toReg),
                .IF_ID_CSR_addr(ReadInst[31:20]),
                .CSR_Data(CSR_Data),
                .PCtoReg_ctrl(PCtoReg_ctrl),
                .IF_ID_Rd(ReadInst[11:7]),
                .IF_ID_RS1(ReadInst[19:15]),
                .IF_ID_RS2(ReadInst[24:20]),
                .RS1_data(RS1_Data),
                .RS2_data(RS2_Data),
                .imm32(imm32),
                .PCtoReg(PCtoReg),
                .ID_EX_PCtoReg(ID_EX_PCtoReg),
                .ID_EX_ALUSrc(ID_EX_ALUSrc),
                .ID_EX_funct7_3(ID_EX_funct7_3),
                .ID_EX_MemRead(ID_EX_MemRead),
                .ID_EX_MemWrite(ID_EX_MemWrite),
                .ID_EX_RegWrite(ID_EX_RegWrite), 
                .ID_EX_ALUOp(ID_EX_ALUOp),
                .ID_EX_MemtoReg(ID_EX_MemtoReg),  
                .ID_EX_CSR_RegWrite(ID_EX_CSR_RegWrite),
                .ID_EX_csr(ID_EX_csr),
                .ID_EX_CSR_ctrl(ID_EX_CSR_ctrl),
                .ID_EX_inst_add1(ID_EX_inst_add1),
                .ID_EX_CSR_addr(ID_EX_CSR_addr),
                .ID_EX_CSR_Data(ID_EX_CSR_Data),
                .ID_EX_PCtoReg_ctrl(ID_EX_PCtoReg_ctrl),
                .ID_EX_funct3(ID_EX_funct3),
                .ID_EX_Rd(ID_EX_Rd),
                .ID_EX_RS1(ID_EX_RS1),
                .ID_EX_RS2(ID_EX_RS2),
                .ID_EX_RS1_data(ID_EX_RS1_data),
                .ID_EX_RS2_data(ID_EX_RS2_data),
                .ID_EX_imm32(ID_EX_imm32)
);


//==========================EX==============================

ALU alu(.PC(inst_PC),
        .ALU_ctrl(ALU_ctrl),
        .Din1(D1),
        //.Din2(Dout2),
        .rs2(Dout2),
        .ID_EX_PCtoReg(ID_EX_PCtoReg),
        .CSRData_toRd(CSRData_toRd),
        .Dout(ALU_result)
        //.Dout(Dout)
);


ALU_control alu_ctrl(.ALUOp(ID_EX_ALUOp),
                    .ID_EX_PCtoReg_ctrl(ID_EX_PCtoReg_ctrl),
                    .ID_EX_csr(ID_EX_csr),
                    .funct7_3(ID_EX_funct7_3),
                    .ALU_ctrl(ALU_ctrl)
);

ALU_CSR     alu_csr(.clk(clk),
                    .rst(rst),
                    .ID_EX_CSR_ctrl(ID_EX_CSR_ctrl),
                    .ID_EX_inst_add1(ID_EX_inst_add1),
                    .ID_EX_CSR_RegWrite(ID_EX_CSR_RegWrite),
                    .ID_EX_CSR_addr(ID_EX_CSR_addr),
                    //.EX_MEM_CSR_RegWrite(EX_MEM_CSR_RegWrite),
                    //.EX_MEM_CSR_addr(EX_MEM_CSR_addr),
                    //.EX_MEM_CSR_ALUOut(WB_CSR_Data),
                    .ID_EX_CSR_Data(ID_EX_CSR_Data),
                    .rs1_data(D1),
                    .uimm(ID_EX_RS1),
                    .CSRData_toRd(CSRData_toRd),
                    .CSR_ALUOut(CSR_ALUOut)
);

Forwarding_EX  forwarding_EX(.EX_MEM_RegWrite(EX_MEM_RegWrite),
                        .EX_MEM_Rd(EX_MEM_Rd),
                        .MEM_WB_RegWrite(MEM_WB_RegWrite),
                        .MEM_WB_Rd(MEM_WB_Rd),
                        .WB_RegWrite(WB_RegWrite),
                        .WB_Rd(WB_Rd),
                        .ID_EX_RS1(ID_EX_RS1),
                        .ID_EX_RS2(ID_EX_RS2),
                        .Forward1(Forward1),
                        .Forward2(Forward2)
);

MUX_forwarding  mux_forwarding(.Forward1(Forward1),
                                .Forward2(Forward2),
                                .ID_EX_RS1_data(ID_EX_RS1_data),
                                .ID_EX_RS2_data(ID_EX_RS2_data),
                                .EX_MEM_ALU_result(EX_MEM_ALU_result),
                                .WB_RegData(WB_RegData),
                                /*.Read_data1(RS1_Data),
                                .Read_data2(RS2_Data),*/
                                .WB_RegData_out(WB_RegData_out),
                                .D1(D1),
                                .D2(D2)
);

MUX_imm mux_imm(.ID_EX_ALUSrc(ID_EX_ALUSrc),
                .D2(D2),
                .ID_EX_imm32(ID_EX_imm32),
                .Dout2(Dout2)
);

reg_EX_MEM  reg3(.clk(clk),
                .rst(rst),
                .IM_busy(IM_busy),
                .DM_busy(DM_busy),
                .ID_EX_funct3(ID_EX_funct3),
                .ID_EX_MemRead(ID_EX_MemRead),
                .ID_EX_MemWrite(ID_EX_MemWrite),
                .ID_EX_RegWrite(ID_EX_RegWrite),
                .ID_EX_MemtoReg(ID_EX_MemtoReg),
                //.ID_EX_CSR_RegWrite(ID_EX_CSR_RegWrite),
                //.ID_EX_CSR_addr(ID_EX_CSR_addr),
                //.CSR_ALUOut(CSR_ALUOut),
                .ALU_result(ALU_result),
                .RS2_Data(D2),
                .ID_EX_Rd(ID_EX_Rd),
                .EX_MEM_funct3(EX_MEM_funct3),
                .EX_MEM_MemRead(EX_MEM_MemRead), 
                .EX_MEM_MemWrite(EX_MEM_MemWrite),              
                .EX_MEM_RegWrite(EX_MEM_RegWrite),
                .EX_MEM_MemtoReg(EX_MEM_MemtoReg),
                //.EX_MEM_CSR_RegWrite(EX_MEM_CSR_RegWrite),
                //.EX_MEM_CSR_addr(EX_MEM_CSR_addr),
                //.EX_MEM_CSR_ALUOut(WB_CSR_Data),
                .EX_MEM_ALU_result(EX_MEM_ALU_result),
                .EX_MEM_RS2_Data(EX_MEM_RS2_Data),
                .EX_MEM_Rd(EX_MEM_Rd)
);

//==========================MEM==============================
/*
MUX_Storetype   mux_storetype(  .EX_MEM_MemWrite(ID_EX_MemWrite),
                                .EX_MEM_funct3(ID_EX_funct3),
                                .EX_MEM_ALU_result(ALU_result),
                                .EX_MEM_RS2_Data(D2),
                                .WEB(DM_WEB),
                                .DI(DM_DI)
);
*/
MUX_Storetype   mux_storetype(  .EX_MEM_MemWrite(EX_MEM_MemWrite),
                                .EX_MEM_funct3(EX_MEM_funct3),
                                .EX_MEM_ALU_result(EX_MEM_ALU_result),
                                .EX_MEM_RS2_Data(EX_MEM_RS2_Data),
                                .WEB(DM_WEB),
                                .DI(DM_DI)
);

reg_MEM_WB  reg4(.clk(clk),
                .rst(rst),
                .IM_busy(IM_busy),
                .DM_busy(DM_busy),
                .EX_MEM_funct3(EX_MEM_funct3),
                .EX_MEM_RegWrite(EX_MEM_RegWrite),
                .EX_MEM_MemtoReg(EX_MEM_MemtoReg),
                .EX_MEM_Rd(EX_MEM_Rd),
                .EX_MEM_ALU_result(EX_MEM_ALU_result),
                .MEMReadData(MEMReadData),
                .MEM_WB_funct3(MEM_WB_funct3),
                .MEM_WB_RegWrite(MEM_WB_RegWrite),
                .MEM_WB_MemtoReg(MEM_WB_MemtoReg),
                .MEM_WB_Rd(MEM_WB_Rd),
                .MEM_WB_ALU_result(MEM_WB_ALU_result),
                .MEM_WB_MEMReadData(MEM_WB_MEMReadData)
);

//==========================WB==============================
MUX_MEMToReg    mux_memtoreg(.MEM_WB_funct3(MEM_WB_funct3),
                            .MEM_WB_MemtoReg(MEM_WB_MemtoReg),
                            .MEMReadData(MEM_WB_MEMReadData),
                            .MEM_WB_ALU_result(MEM_WB_ALU_result),
                            .WB_RegData(WB_RegData)
);

reg_WB  reg5(   .clk(clk),
                .rst(rst),
                .IM_busy(IM_busy),
                .DM_busy(DM_busy),
                .MEM_WB_RegWrite(MEM_WB_RegWrite),
                .MEM_WB_Rd(MEM_WB_Rd),
                .WB_RegData_in(WB_RegData),
                .WB_RegWrite(WB_RegWrite),
                .WB_Rd(WB_Rd),
                .WB_RegData_out(WB_RegData_out)
);

endmodule
