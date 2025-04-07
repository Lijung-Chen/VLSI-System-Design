//=========================MEM stage=========================
module  MUX_Storetype(
    EX_MEM_MemWrite,
    EX_MEM_funct3,
    EX_MEM_ALU_result,
    EX_MEM_RS2_Data,
    WEB,
    DI
);

input               EX_MEM_MemWrite;
input       [2:0]   EX_MEM_funct3;
input       [31:0]  EX_MEM_ALU_result, EX_MEM_RS2_Data;
output  reg [3:0]   WEB;
output  reg [31:0]  DI;


always@(*)  begin
    if(~EX_MEM_MemWrite)    begin
        WEB = 4'b1111;
        DI = EX_MEM_RS2_Data;
    end
    else
        case(EX_MEM_ALU_result[1:0])
        2'b00:  begin   //sw,sh,sb(addr is 4x)
            WEB[0] = 1'b0;
            WEB[1] = (~EX_MEM_funct3[0]) & (~EX_MEM_funct3[1]);
            WEB[2] = ~EX_MEM_funct3[1];
            WEB[3] = WEB[2];
            DI = EX_MEM_RS2_Data;
        end
        2'b10:  begin   //sh(addr is not 4x)
            WEB = 4'b0011;
            DI = {EX_MEM_RS2_Data[15:0],16'd0};
        end
        2'b11:    begin   //sb(addr is not 4x)
            WEB = 4'b0111;
            DI = {EX_MEM_RS2_Data[7:0],24'd0};
        end
        default:    begin
            if(EX_MEM_funct3==3'd0) begin   //sb
                WEB = 4'b1101;
                DI = {16'd0,EX_MEM_RS2_Data[7:0],8'd0};
            end
            else    begin   //sh
                WEB = 4'b1001;  
                DI = {8'd0,EX_MEM_RS2_Data[15:0],8'd0};
            end
        end
        endcase
end
endmodule
