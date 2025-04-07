module CSR(
    clk,
    rst,
    //EX_MEM_CSR_ctrl,
    //EX_MEM_inst_add1,
    ID_EX_CSR_ctrl,
    ID_EX_inst_add1,
    CSR_Data
);

input       clk, rst, ID_EX_inst_add1; //, EX_MEM_inst_add1
input       [1:0]ID_EX_CSR_ctrl;//EX_MEM_CSR_ctrl
output  reg[31:0]CSR_Data;

reg         [63:0]cycle, instret;


always@(posedge clk or posedge rst)
if(rst)begin
    cycle <= 64'd0;
    instret <= 64'd0;
end
else begin
    cycle <= cycle + 1;
    //instret <= instret + EX_MEM_inst_add1;
    instret <= instret + ID_EX_inst_add1;
end

always@(*)begin
    //case (EX_MEM_CSR_ctrl)
    case (ID_EX_CSR_ctrl)
        2'd0:   CSR_Data = cycle[31:0];
        2'd1:   CSR_Data = instret[31:0];
        2'd2:   CSR_Data = cycle[63:32];
        default:    CSR_Data = instret[63:32];
    endcase
end
endmodule