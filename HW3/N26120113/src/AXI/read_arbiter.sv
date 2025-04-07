`include "../include/AXI_define.svh"

module read_arbiter (
    input ACLK,
    input ARESETn,

    input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    input ARVALID_M0,
    input ARREADY_M0,
    input RVALID_M0,
    input RREADY_M0,
    input [`AXI_LEN_BITS-1:0] ARLEN_M0,

    input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    input ARVALID_M1,
    input ARREADY_M1,
    input RREADY_M1,
    input RVALID_M1,
    input [`AXI_LEN_BITS-1:0] ARLEN_M1,

    input RLAST_M0,
    input RLAST_M1,
    
    output logic [3:0] AR_arbiter,
    output logic [1:0] cs    
);


// ROM   0x0000_0000 ~ 0x0000_1FFF (001)
// IM    0x0001_0000 ~ 0x0001_FFFF (010)
// DM    0x0002_0000 ~ 0x0002_FFFF (011)
// Sctrl 0x1000_0000 ~ 0x1000_03FF (100)
// WDT   0x1001_0000 ~ 0x1001_03FF (101)
// DRAM  0x2000_0000 ~ 0x201F_FFFF (110)
// NO                              (111)

enum logic [1:0] {IDLE, M0, M1} cs_ar, ns_ar;
assign cs = cs_ar;
logic [31:0] addr_reg;

always @(posedge ACLK)
begin
	if(~ARESETn)
        cs_ar <= IDLE;
	else
        cs_ar <= ns_ar;
end

always_comb 
begin
	case (cs_ar)
		IDLE: 
		begin 
			if(ARVALID_M1)
                ns_ar = M1;
            else if(ARVALID_M0)
                ns_ar = M0;
            else
                ns_ar = IDLE;
		end
		M0:
		begin 
			if(RVALID_M0 & RREADY_M0 & RLAST_M0)
                ns_ar = IDLE;
            else
                ns_ar = M0;
		end
		M1:
		begin 
			if(RVALID_M1 & RREADY_M1 & RLAST_M1)
                ns_ar = IDLE;
            else
                ns_ar = M1;
		end
		default:
            ns_ar = IDLE;
	endcase
end

always @(posedge ACLK)
begin
	if(~ARESETn)
        addr_reg <= 32'd0;
	else if(ARVALID_M1 & cs_ar == IDLE)
        addr_reg <= ARADDR_M1;
	else if(ARVALID_M0 & cs_ar == IDLE)
        addr_reg <= ARADDR_M0;
    else
        addr_reg <= addr_reg;
end

always_comb 
begin
    case (cs_ar)
        IDLE: 
        begin
            if (ARVALID_M1) 
            begin
                if (ARADDR_M1[31:16] == 16'h0000) // ROM
                    AR_arbiter = 4'b0011;
                else if (ARADDR_M1[31:16] == 16'h0001) // IM
                    AR_arbiter = 4'b0101;
                else if (ARADDR_M1[31:16] == 16'h0002) // DM
                    AR_arbiter = 4'b0111;
                else if (ARADDR_M1[31:16] == 16'h1000) // Sctrl
                    AR_arbiter = 4'b1001;
                else if (ARADDR_M1[31:16] == 16'h1001) // WDT
                    AR_arbiter = 4'b1011;
                else if (ARADDR_M1[31:24] == 8'h20) // DRAM
                    AR_arbiter = 4'b1101;
                else
                    AR_arbiter = 4'b1111;
            end
            else if (ARVALID_M0) 
            begin
                if (ARADDR_M0[31:16] == 16'h0000) // ROM
                    AR_arbiter = 4'b0010;
                else if (ARADDR_M0[31:16] == 16'h0001) // IM
                    AR_arbiter = 4'b0100;
                else if (ARADDR_M0[31:16] == 16'h0002) // DM
                    AR_arbiter = 4'b0110;
                else if (ARADDR_M0[31:16] == 16'h1000)// Sctrl
                    AR_arbiter = 4'b1000;
                else if (ARADDR_M0[31:16] == 16'h1001) // WDT
                    AR_arbiter = 4'b1010;
                else if (ARADDR_M0[31:24] == 8'h20) // DRAM
                    AR_arbiter = 4'b1100;
                else
                    AR_arbiter = 4'b1110;
            end
            else
                AR_arbiter = 4'b0000;
        end
        M0: 
        begin
            if (addr_reg[31:16] == 16'h0000) // ROM
                AR_arbiter = 4'b0010;
            else if (addr_reg[31:16] == 16'h0001) // IM
                AR_arbiter = 4'b0100;
            else if (addr_reg[31:16] == 16'h0002) // DM
                AR_arbiter = 4'b0110;
            else if (addr_reg[31:16] == 16'h1000)// Sctrl
                AR_arbiter = 4'b1000;
            else if (addr_reg[31:16] == 16'h1001) // WDT
                AR_arbiter = 4'b1010;
            else if (addr_reg[31:24] == 8'h20) // DRAM
                AR_arbiter = 4'b1100;
            else
                AR_arbiter = 4'b1110;
        end
        M1: 
        begin
            if (addr_reg[31:16] == 16'h0000) // ROM
                AR_arbiter = 4'b0011;
            else if (addr_reg[31:16] == 16'h0001) // IM
                AR_arbiter = 4'b0101;
            else if (addr_reg[31:16] == 16'h0002) // DM
                AR_arbiter = 4'b0111;
            else if (addr_reg[31:16] == 16'h1000) // Sctrl
                AR_arbiter = 4'b1001;
            else if (addr_reg[31:16] == 16'h1001) // WDT
                AR_arbiter = 4'b1011;
            else if (addr_reg[31:24] == 8'h20) // DRAM
                AR_arbiter = 4'b1101;
            else
                AR_arbiter = 4'b1111;
        end
        default: 
            AR_arbiter = 4'b0000;
    endcase
end

endmodule
