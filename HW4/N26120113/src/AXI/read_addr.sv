`include "../include/AXI_define.svh"

module read_addr
(
    input ACLK,
    input ARESETn,

    input [3:0] AR_arbiter,
    input [1:0] cs,

    input [`AXI_ID_BITS-1:0] ARID_M0,
    input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    input [`AXI_LEN_BITS-1:0] ARLEN_M0,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    input [1:0] ARBURST_M0,
    input ARVALID_M0,
    output  logic ARREADY_M0,

    input [`AXI_ID_BITS-1:0] ARID_M1,
    input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    input [`AXI_LEN_BITS-1:0] ARLEN_M1,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    input [1:0] ARBURST_M1,
    input ARVALID_M1,
    output  logic ARREADY_M1,

    input ARREADY_S0,
    input ARREADY_S1,
    input ARREADY_S2,
    input ARREADY_S3,
    input ARREADY_S4,
    input ARREADY_S5,

    output  logic   [`AXI_IDS_BITS-1:0]     ARID_S0,
    output  logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S0,
    output  logic   [`AXI_LEN_BITS-1:0]     ARLEN_S0,
    output  logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S0,
    output  logic   [1:0]                   ARBURST_S0,
    output  logic                           ARVALID_S0,

    output  logic   [`AXI_IDS_BITS-1:0]     ARID_S1,
    output  logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S1,
    output  logic   [`AXI_LEN_BITS-1:0]     ARLEN_S1,
    output  logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S1,
    output  logic   [1:0]                   ARBURST_S1,
    output  logic                           ARVALID_S1,

    output  logic   [`AXI_IDS_BITS-1:0]     ARID_S2,
    output  logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S2,
    output  logic   [`AXI_LEN_BITS-1:0]     ARLEN_S2,
    output  logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S2,
    output  logic   [1:0]                   ARBURST_S2,
    output  logic                           ARVALID_S2,

    output  logic   [`AXI_IDS_BITS-1:0]     ARID_S3,
    output  logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S3,
    output  logic   [`AXI_LEN_BITS-1:0]     ARLEN_S3,
    output  logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S3,
    output  logic   [1:0]                   ARBURST_S3,
    output  logic                           ARVALID_S3,

    output  logic   [`AXI_IDS_BITS-1:0]     ARID_S4,
    output  logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S4,
    output  logic   [`AXI_LEN_BITS-1:0]     ARLEN_S4,
    output  logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S4,
    output  logic   [1:0]                   ARBURST_S4,
    output  logic                           ARVALID_S4,

    output  logic   [`AXI_IDS_BITS-1:0]     ARID_S5,
    output  logic   [`AXI_ADDR_BITS-1:0]    ARADDR_S5,
    output  logic   [`AXI_LEN_BITS-1:0]     ARLEN_S5,
    output  logic   [`AXI_SIZE_BITS-1:0]    ARSIZE_S5,
    output  logic   [1:0]                   ARBURST_S5,
    output  logic                           ARVALID_S5
);

logic [1:0] cs_r;
assign cs_r = cs;

always_comb 
begin
	case (AR_arbiter)
        4'b0010: 
            ARREADY_M0 = ARREADY_S0;
        4'b0100: 
            ARREADY_M0 = ARREADY_S1;
        4'b0110:               
            ARREADY_M0 = ARREADY_S2;
        4'b1000:                
            ARREADY_M0 = ARREADY_S3;
        4'b1010:                
            ARREADY_M0 = ARREADY_S4;
        4'b1100:                
            ARREADY_M0 = ARREADY_S5;
		default:                    
            ARREADY_M0 = 1'b0;
	endcase
end

always_comb 
begin
	case (AR_arbiter)
        4'b0011:                
            ARREADY_M1 = ARREADY_S0;
        4'b0101:                
            ARREADY_M1 = ARREADY_S1;
        4'b0111:                
            ARREADY_M1 = ARREADY_S2;
        4'b1001:                
            ARREADY_M1 = ARREADY_S3;
        4'b1011:                
            ARREADY_M1 = ARREADY_S4;
        4'b1101:                
            ARREADY_M1 = ARREADY_S5;
		default:                    
            ARREADY_M1 = 1'b0;
	endcase
end

// ROM
always_comb 
begin
	case (AR_arbiter)
        4'b0010:                
            ARVALID_S0 = ARVALID_M0;
        4'b0011:                
            ARVALID_S0 = ARVALID_M1;
        default:                    
            ARVALID_S0 = 1'b0;
	endcase
end

// IM
always_comb 
begin
	case (AR_arbiter)
        4'b0100:                
            ARVALID_S1 = ARVALID_M0;
        4'b0101:                
            ARVALID_S1 = ARVALID_M1;
        default:                    
            ARVALID_S1 = 1'b0;
	endcase
end

// DM
always_comb 
begin
	case (AR_arbiter)
        4'b0110:                
            ARVALID_S2 = ARVALID_M0;
        4'b0111:                
            ARVALID_S2 = ARVALID_M1;
        default:                   
             ARVALID_S2 = 1'b0;
	endcase
end

// SCTRL
always_comb 
begin
	case (AR_arbiter)
        4'b1000:                
            ARVALID_S3 = ARVALID_M0;
        4'b1001:                
            ARVALID_S3 = ARVALID_M1;
        default:                    
            ARVALID_S3 = 1'b0;
	endcase
end

// WDT
always_comb 
begin
	case (AR_arbiter)
        4'b1010:                
            ARVALID_S4 = ARVALID_M0;
        4'b1011:                
            ARVALID_S4 = ARVALID_M1;
        default:                    
            ARVALID_S4 = 1'b0;
	endcase
end

// DRAM
always_comb 
begin
	case (AR_arbiter)
        4'b1100:                
            ARVALID_S5 = ARVALID_M0;
        4'b1101:                
            ARVALID_S5 = ARVALID_M1;
        default:                    
            ARVALID_S5 = 1'b0;
	endcase
end

// ROM
always_comb 
begin
    case (AR_arbiter)
        4'b0010: 
        begin
			ARID_S0 = {4'b0, ARID_M0};
			ARADDR_S0 = ARADDR_M0;
			ARLEN_S0 = ARLEN_M0;
			ARSIZE_S0 = ARSIZE_M0;
			ARBURST_S0 = ARBURST_M0;
        end
        4'b0011: 
        begin
			ARID_S0 = {4'b1, ARID_M1};
			ARADDR_S0 = ARADDR_M1;
			ARLEN_S0 = ARLEN_M1;
			ARSIZE_S0 = ARSIZE_M1;
			ARBURST_S0 = ARBURST_M1;
		end
        default: 
        begin
			ARID_S0 = 4'b0;
			ARADDR_S0 = 32'b0;
			ARLEN_S0 = 4'b0;
			ARSIZE_S0 = 3'b0;
			ARBURST_S0 = 2'b0;
        end
    endcase
end

// IM
always_comb 
begin
    case (AR_arbiter)
        4'b0100: 
        begin
			ARID_S1 = {4'b0, ARID_M0};
			ARADDR_S1 = ARADDR_M0;
			ARLEN_S1 = ARLEN_M0;
			ARSIZE_S1 = ARSIZE_M0;
			ARBURST_S1 = ARBURST_M0;
		end
		4'b0101: 
        begin
			ARID_S1 = {4'b1, ARID_M1};
			ARADDR_S1 = ARADDR_M1;
			ARLEN_S1 = ARLEN_M1;
			ARSIZE_S1 =ARSIZE_M1;
			ARBURST_S1 = ARBURST_M1;
		end
        default: 
        begin
			ARID_S1 = 4'b0;
			ARADDR_S1 = 32'b0;
			ARLEN_S1 = 4'b0;
			ARSIZE_S1 = 3'b0;
			ARBURST_S1 = 2'b0;
		end
    endcase
end

// DM
always_comb 
begin
    case (AR_arbiter)
        4'b0110: 
        begin
			ARID_S2 = {4'b0, ARID_M0};
			ARADDR_S2 = ARADDR_M0;
			ARLEN_S2 = ARLEN_M0;
			ARSIZE_S2 = ARSIZE_M0;
			ARBURST_S2 = ARBURST_M0;
		end
		4'b0111: 
        begin
			ARID_S2 = {4'b1, ARID_M1};
			ARADDR_S2 = ARADDR_M1;
			ARLEN_S2 = ARLEN_M1;
			ARSIZE_S2 = ARSIZE_M1;
			ARBURST_S2 = ARBURST_M1;
		end
        default: 
        begin
			ARID_S2 = 4'b0;
			ARADDR_S2 = 32'b0;
			ARLEN_S2 = 4'b0;
			ARSIZE_S2 = 3'b0;
			ARBURST_S2 = 2'b0;
		end
    endcase
end

// SCTRL
always_comb 
begin
    case (AR_arbiter)
        4'b1000: 
        begin
			ARID_S3 = {4'b0, ARID_M0};
			ARADDR_S3 = ARADDR_M0;
			ARLEN_S3 = ARLEN_M0;
			ARSIZE_S3 = ARSIZE_M0;
			ARBURST_S3 = ARBURST_M0;
		end
		4'b1001: 
        begin
			ARID_S3 = {4'b1, ARID_M1};
			ARADDR_S3 = ARADDR_M1;
			ARLEN_S3 = ARLEN_M1;
			ARSIZE_S3 = ARSIZE_M1;
			ARBURST_S3 = ARBURST_M1;
		end
        default: 
        begin
			ARID_S3 = 4'b0;
			ARADDR_S3 = 32'b0;
			ARLEN_S3 = 4'b0;
			ARSIZE_S3 = 3'b0;
			ARBURST_S3 = 2'b0;
		end
    endcase
end

// WDT
always_comb 
begin
    case (AR_arbiter)
        4'b1010: 
        begin
			ARID_S4 = {4'b0, ARID_M0};
			ARADDR_S4 = ARADDR_M0;
			ARLEN_S4 = ARLEN_M0;
			ARSIZE_S4 = ARSIZE_M0;
			ARBURST_S4 = ARBURST_M0;
		end
		4'b1011: 
        begin
			ARID_S4 = {4'b1, ARID_M1};
			ARADDR_S4 = ARADDR_M1;
			ARLEN_S4 = ARLEN_M1;
			ARSIZE_S4 = ARSIZE_M1;
			ARBURST_S4 = ARBURST_M1;
		end
        default: 
        begin
			ARID_S4 = 4'b0;
			ARADDR_S4 = 32'b0;
			ARLEN_S4 = 4'b0;
			ARSIZE_S4 = 3'b0;
			ARBURST_S4 = 2'b0;
		end
    endcase
end

// DRAM
always_comb 
begin
    case (AR_arbiter)
        4'b1100: 
        begin
			ARID_S5 = {4'b0, ARID_M0};
			ARADDR_S5 = ARADDR_M0;
			ARLEN_S5 = ARLEN_M0;
			ARSIZE_S5 = ARSIZE_M0;
			ARBURST_S5 = ARBURST_M0;
		end
		4'b1101: 
        begin
			ARID_S5 = {4'b1, ARID_M1};
			ARADDR_S5 = ARADDR_M1;
			ARLEN_S5 = ARLEN_M1;
			ARSIZE_S5 = ARSIZE_M1;
			ARBURST_S5 = ARBURST_M1;
		end
        default: 
        begin
			ARID_S5     = 4'b0;
			ARADDR_S5   = 32'b0;
			ARLEN_S5    = 4'b0;
			ARSIZE_S5   = 3'b0;
			ARBURST_S5  = 2'b0;
		end
    endcase
end

endmodule
