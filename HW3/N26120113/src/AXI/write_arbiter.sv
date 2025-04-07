`include "../include/AXI_define.svh"

module write_arbiter (
    input ACLK,
    input ARESETn,
 
    input AWVALID_M1,
    input WVALID_M1,
    input BVALID_M1,
    input BREADY_M1,
    input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    
    output logic [3:0] AW_arbiter,
    output logic cs_w
);

enum logic {IDLE, M1} cs_aw, ns_aw;
assign cs_w = cs_aw;
logic [31:0] awaddr_reg;

always @(posedge ACLK)
begin
	if(~ARESETn)
        cs_aw <= IDLE;
	else
        cs_aw <= ns_aw;
end

always_comb 
begin
	case (cs_aw)
		IDLE: 
		begin 
			if(AWVALID_M1)
                ns_aw = M1;
            else
                ns_aw = IDLE;
		end
		M1:
		begin 
			if(BVALID_M1 && BREADY_M1)
                ns_aw = IDLE;
            else
                ns_aw = M1;
		end
		default:
            ns_aw = IDLE;
	endcase
end

always @(posedge ACLK)
begin
	if(~ARESETn)
        awaddr_reg <= 32'd0;
    else if(AWVALID_M1 & cs_aw == IDLE)
        awaddr_reg <= AWADDR_M1;
    else
        awaddr_reg <= awaddr_reg;
end

// ADDR:
// IM    0x0001_0000 ~ 0x0001_FFFF
// DM    0x0002_0000 ~ 0x0002_FFFF
// Sctrl 0x1000_0000 ~ 0x1000_03FF
// WDT   0x1001_0000 ~ 0x1001_03FF
// DRAM  0x2000_0000 ~ 0x201F_FFFF

always_comb begin
    case (cs_aw)
        IDLE:
        begin
            if (AWVALID_M1) 
            begin
                if (AWADDR_M1[31:16] == 16'h0001)
                    AW_arbiter = 4'b0101;
                else if (AWADDR_M1[31:16] == 16'h0002)
                    AW_arbiter = 4'b0111;
                else if (AWADDR_M1[31:16] == 16'h1000)
                    AW_arbiter = 4'b1001;
                else if (AWADDR_M1[31:24] == 8'h20)
                    AW_arbiter = 4'b1101;
                else if (AWADDR_M1[31:16] == 16'h1001)
                    AW_arbiter = 4'b1011;
                else
                    AW_arbiter = 4'b1111;
            end
            else
                AW_arbiter = 4'b0000;
        end
        M1: 
        begin
            if (awaddr_reg[31:16] == 16'h0001)
                AW_arbiter = 4'b0101;
            else if (awaddr_reg[31:16] == 16'h0002)
                AW_arbiter = 4'b0111;
            else if (awaddr_reg[31:16] == 16'h1000)
                AW_arbiter = 4'b1001;
            else if (awaddr_reg[31:24] == 8'h20)
                AW_arbiter = 4'b1101;
            else if (awaddr_reg[31:16] == 16'h1001)
                AW_arbiter = 4'b1011;
            else
                AW_arbiter = 4'b1111;
        end
        default: 
            AW_arbiter = 4'b0000;
    endcase
end
endmodule
