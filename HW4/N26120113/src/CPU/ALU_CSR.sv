module ALU_CSR(
    //INPUT
    clk,
    rst,
    ID_EX_CSR_ctrl,
    ID_EX_inst_add1,
    ID_EX_CSR_RegWrite,
    ID_EX_CSR_addr,
    ID_EX_CSR_Data,
    rs1_data,
    uimm,
    //OUTPUT
    CSRData_toRd,
    CSR_ALUOut
);

input                   clk, rst, ID_EX_inst_add1, ID_EX_CSR_RegWrite; 
input           [3:0]   ID_EX_CSR_ctrl;
input           [11:0]  ID_EX_CSR_addr;
input           [31:0]  ID_EX_CSR_Data, rs1_data;
input           [4:0]   uimm;
output  logic   [31:0]  CSRData_toRd, CSR_ALUOut;

logic           [63:0]  cycle, instret;
logic           [31:0]  csr_data, uimm32;

assign  uimm32 = {27'd0,uimm};


always@(posedge clk)
if(rst)begin
    cycle <= 64'd0;
    instret <= 64'd0;
end
else begin
    cycle <= cycle + 1;
    instret <= instret + ID_EX_inst_add1;
end
/*
//forwarding
always_comb begin
    if(EX_MEM_CSR_RegWrite && EX_MEM_CSR_addr == ID_EX_CSR_addr)
        csr_data = EX_MEM_CSR_ALUOut;
    else
        csr_data = ID_EX_CSR_Data;
end
*/

assign  csr_data = ID_EX_CSR_Data;

//write back to CSR register file
always_comb begin
    case (ID_EX_CSR_ctrl)
        4'd0:   CSR_ALUOut = rs1_data;                  //CSRRW
        4'd1:   CSR_ALUOut = csr_data | rs1_data;       //CSRRS
        4'd2:   CSR_ALUOut = csr_data & (~rs1_data);    //CSRRC
        4'd3:   CSR_ALUOut = uimm32;                    //CSRRWI
        4'd4:   CSR_ALUOut = csr_data | uimm32;         //CSRRSI
        default:   CSR_ALUOut = csr_data & (~uimm32);   //CSRRCI
    endcase
end

//write back to rd register file
always_comb begin
    case (ID_EX_CSR_ctrl)
        4'd6:   CSRData_toRd = cycle[31:0];
        4'd7:   CSRData_toRd = instret[31:0];
        4'd8:   CSRData_toRd = cycle[63:32];
        4'd9:   CSRData_toRd = instret[63:32];
        default:    CSRData_toRd = csr_data;
    endcase
end
endmodule