//Memory read out data write in pipeline reg
//Multiplier is self defined

`include "./PC.sv"
`include "./PC_Adder.sv"
`include "./ALU.sv"
`include "./ALU_control.sv"
`include "./Control.sv"
`include "./branch_comp.sv"
`include "./CSR.sv"
`include "./Forwarding_ID.sv"
`include "./Forwarding_EX.sv"
`include "./Hazard_detection.sv"
`include "./Imm_Gen.sv"
`include "./MUX_ctrl.sv"
`include "./MUX_PCtoReg.sv"
`include "./MUX_forwarding.sv"
`include "./MUX_imm.sv"
`include "./MUX_Storetype.sv"
`include "./MUX_MEMToReg.sv"
`include "./reg_IF_ID.sv"
`include "./reg_ID_EX.sv"
`include "./reg_EX_MEM.sv"
`include "./reg_MEM_WB.sv"
`include "./reg_WB.sv"
`include "./Register_File.sv"
`include "./SRAM_wrapper.sv"
`include "./Multiplier.sv"

module top (
    clk,
    rst
);
input   clk, rst;

wire    [63:0]mul_out;

wire    [31:0]  PC, inst_PC, IF_ID_inst, IF_ID_PCAdd4, New_PC, MEMReadInst, ReadInst, RS1_Data, RS2_Data, imm32, PC_branch, 
                PCAdd4, PCtoReg, ID_EX_PCtoReg, ID_EX_RS1_data, ID_EX_RS2_data, ID_EX_imm32, D1, D2, Dout2, 
                ALU_result, Dout, EX_MEM_ALU_result, EX_MEM_RS2_Data, CSR_Data, 
                MEM_WB_ALU_result, LoadData, WB_RegData, WB_RegData_out, MEMReadData, MEM_WB_MEMReadData, Data_rs1, Data_rs2, DI, EX_MEM_Din1_complement;

wire    flush, JALR, Branch, branch_taken, U_AUIPC, U_LUI, Stall, NOP, PCtoReg_ctrl, IF_ID_Write, PC_Write, MemRead, ALUSrc,
        RegWrite, ALUSrc_toReg, MemRead_toReg, RegWrite_toReg, inst_add1_toReg, ID_EX_ALUSrc, ID_EX_MemRead, ID_EX_RegWrite,
        ID_EX_inst_add1, ID_EX_PCtoReg_ctrl, EX_MEM_MemRead, EX_MEM_RegWrite, MEM_WB_MemRead, MEM_WB_RegWrite, 
        WB_RegWrite, CSR_inst, ID_EX_csr, MemtoReg, MemtoReg_toReg, CSR_inst_toReg, ID_EX_MemtoReg, EX_MEM_MemtoReg, MEM_WB_MemtoReg, MemWrite, 
        MemWrite_toReg, ID_EX_MemWrite, EX_MEM_MemWrite, mul_start, mul_finish, ID_EX_mul_start;
wire    [3:0]   ALU_ctrl, WEB;
wire    [2:0]   ID_EX_funct3, EX_MEM_funct3, MEM_WB_funct3;
wire    [1:0]   ALUOp, CSR_ctrl, ALUOp_toReg, CSR_ctrl_toReg, ID_EX_ALUOp, ID_EX_CSR_ctrl,
                Forward1, Forward2, MULtype, ID_EX_MULtype;
wire    [4:0]   ID_EX_funct7_3, ID_EX_Rd, ID_EX_RS1, ID_EX_RS2, EX_MEM_Rd, MEM_WB_Rd, WB_Rd;

reg cs;

//==========================IF==============================

PC  pc( .clk(clk),
        .rst(rst),
        .PC_Write(PC_Write),
        .PC_in(New_PC),
        .PC_out(PC)
);

SRAM_wrapper    IM1(.CK(clk),
                    .CS(1'b1),
                    .OE(1'b1),
                    .WEB(4'b1111),
                    .A(inst_PC[15:2]),
                    .DI(32'd1),
                    .DO(MEMReadInst)
);

reg_IF_ID   reg1(.clk(clk),
                .rst(rst),
                .cs(cs),
                .IF_ID_Write(IF_ID_Write),
                .Flush(flush),
                .inst_in(MEMReadInst),
                .PCAdd4_in(PCAdd4),
                .inst_out(IF_ID_inst),
                .IF_ID_PCAdd4(IF_ID_PCAdd4)
);
always@(posedge clk or posedge rst)
if(rst) cs <= 1'b0;
else if(~cs & New_PC==32'd0) cs <= 1'b0;
else    cs <= 1'b1;

assign  inst_PC = (Stall)? PC : New_PC;
assign  ReadInst = (cs)? IF_ID_inst : 32'd0;
//==========================ID==============================
PC_Adder    pc_adder(.Flush(flush),
                    .JALR(JALR),
                    .U_AUIPC(U_AUIPC),
                    .PC(PC),
                    .imm32(imm32),
                    .Data_rs1(Data_rs1),
                    .New_PC(New_PC),
                    .PC_branch(PC_branch),
                    .PCAdd4(PCAdd4)
);

MUX_PCtoReg mux_pctoreg(.U_AUIPC(U_AUIPC),
                        .U_LUI(U_LUI),
                        .IF_ID_PCAdd4(IF_ID_PCAdd4),
                        .imm32(imm32),
                        .PC_branch(PC_branch),
                        .PCtoReg(PCtoReg)
);

Control ctrl(.op(ReadInst[6:0]),
            .funct3(ReadInst[14:12]),     //for load /S-type
            .funct7_0(ReadInst[25]),
            .inst27(ReadInst[27]),
            .inst21(ReadInst[21]),
            .branch_taken(branch_taken),   //B-type=0/1, JAL/JALR=1
            .Branch(Branch),
            .Stall(Stall),
            .JALR(JALR),
            .JAL(JAL),
            .U_AUIPC(U_AUIPC),
            .U_LUI(U_LUI),
            .MULtype(MULtype),
            .mul_start(mul_start),
            .MemRead(MemRead),
            .MemWrite(MemWrite),
            .MemtoReg(MemtoReg),
            .ALUOp(ALUOp),
            .ALUSrc(ALUSrc),
            .RegWrite(RegWrite),
            .Flush(flush),
            .NOP(NOP),
            .CSR_ctrl(CSR_ctrl),   //for CSR
            .CSR_inst(CSR_inst),
            .PCtoReg_ctrl(PCtoReg_ctrl)
);
MUX_ctrl    mux_ctrl(.Stall(Stall),
                    .NOP(NOP),
                    .ALUSrc(ALUSrc),
                    .ALUOp(ALUOp),
                    .MemRead(MemRead),
                    .MemWrite(MemWrite),
                    .RegWrite(RegWrite),
                    .MemtoReg(MemtoReg),
                    .CSR_ctrl(CSR_ctrl),
                    .CSR_inst(CSR_inst),
                    .ALUSrc_toReg(ALUSrc_toReg),
                    .ALUOp_toReg(ALUOp_toReg),
                    .MemRead_toReg(MemRead_toReg),
                    .MemWrite_toReg(MemWrite_toReg),
                    .RegWrite_toReg(RegWrite_toReg),
                    .MemtoReg_toReg(MemtoReg_toReg),
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
                                    .ID_EX_MemRead(ID_EX_MemRead),
                                    .ID_EX_Rd(ID_EX_Rd),
                                    .EX_MEM_MemRead(EX_MEM_MemRead),
                                    .EX_MEM_Rd(EX_MEM_Rd),
                                    .ID_EX_RegWrite(ID_EX_RegWrite),
                                    .IF_ID_RS1(ReadInst[19:15]),
                                    .IF_ID_RS2(ReadInst[24:20]),
                                    .ID_EX_MULtype(ID_EX_MULtype),
                                    .mul_finish(mul_finish),
                                    .IF_ID_Write(IF_ID_Write),
                                    .PC_Write(PC_Write),
                                    .Stall(Stall)
);

reg_ID_EX   reg2(.clk(clk),
                .rst(rst),
                .mul_finish(mul_finish),
                .funct3(ReadInst[14:12]),
                .funct7_3({ReadInst[30],ReadInst[25],ReadInst[14:12]}),
                .ALUSrc(ALUSrc_toReg),
                .ALUOp(ALUOp_toReg),
                .MULtype(MULtype),
                .mul_start(mul_start),
                .MemRead(MemRead_toReg),
                .MemWrite(MemWrite_toReg),
                .RegWrite(RegWrite_toReg),
                .MemtoReg(MemtoReg_toReg),
                .CSR_inst(CSR_inst_toReg),
                .CSR_ctrl(CSR_ctrl_toReg),
                .inst_add1(inst_add1_toReg),
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
                .ID_EX_csr(ID_EX_csr),
                .ID_EX_CSR_ctrl(ID_EX_CSR_ctrl),
                .ID_EX_inst_add1(ID_EX_inst_add1),
                .ID_EX_PCtoReg_ctrl(ID_EX_PCtoReg_ctrl),
                .ID_EX_funct3(ID_EX_funct3),
                .ID_EX_Rd(ID_EX_Rd),
                .ID_EX_RS1(ID_EX_RS1),
                .ID_EX_RS2(ID_EX_RS2),
                .ID_EX_RS1_data(ID_EX_RS1_data),
                .ID_EX_RS2_data(ID_EX_RS2_data),
                .ID_EX_imm32(ID_EX_imm32),
                .ID_EX_MULtype(ID_EX_MULtype),
                .ID_EX_mul_start(ID_EX_mul_start)
);


//==========================EX==============================
Multiplier  mul(.clk(clk),
                .rst(rst),
                .mul_start(ID_EX_mul_start),
                .MULtype(ID_EX_MULtype),
                .Din1(D1),
                .Din2(Dout2),
                .EX_MEM_Din1_complement(EX_MEM_Din1_complement),
                .Dout(mul_out),
                .mul_finish(mul_finish) 
);

ALU alu(.ALU_ctrl(ALU_ctrl),
        .Din1(D1),
        .Din2(Dout2),
        .ID_EX_PCtoReg(ID_EX_PCtoReg),
        .CSR_Data(CSR_Data),
        .mul_out(mul_out),
        .Dout(ALU_result)
        //.Dout(Dout)
);


ALU_control alu_ctrl(.ALUOp(ID_EX_ALUOp),
                    .ID_EX_PCtoReg_ctrl(ID_EX_PCtoReg_ctrl),
                    .ID_EX_csr(ID_EX_csr),
                    .ID_EX_MULtype(ID_EX_MULtype),
                    .mul_finish(mul_finish),
                    .funct7_3(ID_EX_funct7_3),
                    .ALU_ctrl(ALU_ctrl)
);

CSR     Csr(.clk(clk),
        .rst(rst),
        //.EX_MEM_CSR_ctrl(EX_MEM_CSR_ctrl),
        //.EX_MEM_inst_add1(EX_MEM_inst_add1),
        .ID_EX_CSR_ctrl(ID_EX_CSR_ctrl),
        .ID_EX_inst_add1(ID_EX_inst_add1),
        .CSR_Data(CSR_Data)
);

//assign  ALU_result = (ID_EX_PCtoReg_ctrl)? ID_EX_PCtoReg : ((ID_EX_csr)? CSR_Data : Dout);

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
                .mul_finish(mul_finish),
                .ID_EX_funct3(ID_EX_funct3),
                .ID_EX_MemRead(ID_EX_MemRead),
                .ID_EX_MemWrite(ID_EX_MemWrite),
                .ID_EX_RegWrite(ID_EX_RegWrite),
                .ID_EX_MemtoReg(ID_EX_MemtoReg),
                .ALU_result(ALU_result),
                .RS2_Data(D2),
                .ID_EX_Rd(ID_EX_Rd),
                .EX_MEM_funct3(EX_MEM_funct3),
                .EX_MEM_MemRead(EX_MEM_MemRead),
                .EX_MEM_MemWrite(EX_MEM_MemWrite),
                .EX_MEM_RegWrite(EX_MEM_RegWrite),
                .EX_MEM_MemtoReg(EX_MEM_MemtoReg),
                .EX_MEM_ALU_result(EX_MEM_ALU_result),
                .EX_MEM_Din1_complement(EX_MEM_Din1_complement),
                .EX_MEM_RS2_Data(EX_MEM_RS2_Data),
                .EX_MEM_Rd(EX_MEM_Rd)
);

//==========================MEM==============================
/*
MUX_Storetype   mux_storetype(  .EX_MEM_MemWrite(EX_MEM_MemWrite),
                                .EX_MEM_funct3(EX_MEM_funct3),
                                .EX_MEM_ALU_result(EX_MEM_ALU_result),
                                .EX_MEM_RS2_Data(EX_MEM_RS2_Data),
                                .WEB(WEB),
                                .DI(DI)
);
*/
MUX_Storetype   mux_storetype(  .EX_MEM_MemWrite(ID_EX_MemWrite),
                                .EX_MEM_funct3(ID_EX_funct3),
                                .EX_MEM_ALU_result(ALU_result),
                                .EX_MEM_RS2_Data(D2),
                                .WEB(WEB),
                                .DI(DI)
);

/*
SRAM_wrapper    DM1(.CK(clk),
                    .CS(1'b1),
                    //.OE(EX_MEM_MemRead),
                    .OE(MEM_WB_MemRead),
                    //.WEB(EX_MEM_MemWrite),
                    .WEB(WEB),
                    .A(EX_MEM_ALU_result[15:2]),
                    //.DI(EX_MEM_RS2_Data),
                    .DI(DI),
                    .DO(MEMReadData)
);
*/
SRAM_wrapper    DM1(.CK(clk),
                    .CS(1'b1),
                    .OE(EX_MEM_MemRead),
                    .WEB(WEB),
                    .A(ALU_result[15:2]),
                    .DI(DI),
                    .DO(MEMReadData)
);

reg_MEM_WB  reg4(.clk(clk),
                .rst(rst),
                .mul_finish(mul_finish),
                .EX_MEM_funct3(EX_MEM_funct3),
                .EX_MEM_MemRead(EX_MEM_MemRead),
                .EX_MEM_RegWrite(EX_MEM_RegWrite),
                .EX_MEM_MemtoReg(EX_MEM_MemtoReg),
                .EX_MEM_Rd(EX_MEM_Rd),
                .EX_MEM_ALU_result(EX_MEM_ALU_result),
                .MEMReadData(MEMReadData),
                .MEM_WB_funct3(MEM_WB_funct3),
                .MEM_WB_MemRead(MEM_WB_MemRead),
                .MEM_WB_RegWrite(MEM_WB_RegWrite),
                .MEM_WB_MemtoReg(MEM_WB_MemtoReg),
                .MEM_WB_Rd(MEM_WB_Rd),
                .MEM_WB_ALU_result(MEM_WB_ALU_result),
                .MEM_WB_MEMReadData(MEM_WB_MEMReadData)
);

//==========================WB==============================
MUX_MEMToReg    mux_memtoreg(.MEM_WB_funct3(MEM_WB_funct3),
                            .MEM_WB_MemtoReg(MEM_WB_MemtoReg),
                            //.MEMReadData(MEMReadData),
                            .MEMReadData(MEM_WB_MEMReadData),
                            .MEM_WB_ALU_result(MEM_WB_ALU_result),
                            .WB_RegData(WB_RegData)
);

reg_WB  reg5(   .clk(clk),
                .rst(rst),
                .mul_finish(mul_finish),
                .MEM_WB_RegWrite(MEM_WB_RegWrite),
                .MEM_WB_Rd(MEM_WB_Rd),
                .WB_RegData_in(WB_RegData),
                .WB_RegWrite(WB_RegWrite),
                .WB_Rd(WB_Rd),
                .WB_RegData_out(WB_RegData_out)
);

endmodule