`include "../include/AXI_define.svh"

module write_addr (
    input ACLK,
    input ARESETn,

    input [3:0]    AW_arbiter,
    input cs_w,

    input [`AXI_ID_BITS-1:0]      AWID_M1,
	input [`AXI_ADDR_BITS-1:0]    AWADDR_M1,
	input [`AXI_LEN_BITS-1:0]     AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0]    AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output  logic AWREADY_M1,

    input AWREADY_S1,
    input AWREADY_S2,
    input AWREADY_S3,
    input AWREADY_S4,
    input AWREADY_S5,

    output  logic   [`AXI_IDS_BITS-1:0]     AWID_S1,
	output  logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S1,
	output  logic   [`AXI_LEN_BITS-1:0]     AWLEN_S1,
	output  logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S1,
	output  logic   [1:0] AWBURST_S1,
	output  logic AWVALID_S1,

    output  logic   [`AXI_IDS_BITS-1:0]     AWID_S2,
	output  logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S2,
	output  logic   [`AXI_LEN_BITS-1:0]     AWLEN_S2,
	output  logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S2,
	output  logic   [1:0] AWBURST_S2,
	output  logic AWVALID_S2,

    output  logic   [`AXI_IDS_BITS-1:0]     AWID_S3,
	output  logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S3,
	output  logic   [`AXI_LEN_BITS-1:0]     AWLEN_S3,
	output  logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S3,
	output  logic   [1:0] AWBURST_S3,
	output  logic AWVALID_S3,

    output  logic   [`AXI_IDS_BITS-1:0]     AWID_S4,
	output  logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S4,
	output  logic   [`AXI_LEN_BITS-1:0]     AWLEN_S4,
	output  logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S4,
	output  logic   [1:0] AWBURST_S4,
	output  logic AWVALID_S4,

	output  logic   [`AXI_IDS_BITS-1:0]     AWID_S5,
	output  logic   [`AXI_ADDR_BITS-1:0]    AWADDR_S5,
	output  logic   [`AXI_LEN_BITS-1:0]     AWLEN_S5,
	output  logic   [`AXI_SIZE_BITS-1:0]    AWSIZE_S5,
	output  logic   [1:0] AWBURST_S5,
	output  logic AWVALID_S5
);

logic cs_w_w;
assign cs_w_w = cs_w;

logic [`AXI_IDS_BITS-1:0]  AWID_Reg;
logic [`AXI_ADDR_BITS-1:0] AWADDR_Reg;
logic [`AXI_LEN_BITS-1:0]  AWLEN_Reg;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_Reg;
logic [1:0]                AWBURST_Reg;

always_ff @(posedge ACLK) 
begin
    if (~ARESETn) 
    begin
	    AWID_Reg    <= 8'b0;
        AWADDR_Reg  <= 32'b0;
        AWLEN_Reg   <= 4'b0;
        AWSIZE_Reg  <= 3'b0;
        AWBURST_Reg <= 2'b0;
    end
    else 
    begin
        if (AWVALID_M1 && (~cs_w_w)) 
        begin
            AWID_Reg    <= {4'b1, AWID_M1};
            AWADDR_Reg  <= AWADDR_M1;
            AWLEN_Reg   <= AWLEN_M1;
            AWSIZE_Reg  <= AWSIZE_M1;
            AWBURST_Reg <= AWBURST_M1;
        end
        else 
        begin
            AWID_Reg    <= AWID_Reg;
            AWADDR_Reg  <= AWADDR_Reg;
            AWLEN_Reg   <= AWLEN_Reg;
            AWSIZE_Reg  <= AWSIZE_Reg;
            AWBURST_Reg <= AWBURST_Reg;
        end
    end
end

always_comb 
begin
	case (AW_arbiter)
		4'b0101: 
			AWREADY_M1 = AWREADY_S1;
        4'b0111: 
			AWREADY_M1 = AWREADY_S2;
		4'b1001: 
			AWREADY_M1 = AWREADY_S3;
		4'b1011: 
			AWREADY_M1 = AWREADY_S4;
		4'b1101: 
			AWREADY_M1 = AWREADY_S5;
		default: 
			AWREADY_M1 = 1'b0;
	endcase
end

always_comb 
begin
    case (AW_arbiter)
		4'b0101: 
        begin
			AWVALID_S1 = AWVALID_M1;
			AWID_S1     = (~cs_w_w) ? {4'b1, AWID_M1} : AWID_Reg;
			AWADDR_S1   = (~cs_w_w) ? AWADDR_M1       : AWADDR_Reg;
			AWLEN_S1    = (~cs_w_w) ? AWLEN_M1        : AWLEN_Reg;
			AWSIZE_S1   = (~cs_w_w) ? AWSIZE_M1       : AWSIZE_Reg;
			AWBURST_S1  = (~cs_w_w) ? AWBURST_M1      : AWBURST_Reg;
		end
        default: 
        begin
			AWVALID_S1  = 1'b0;
			AWID_S1     = 8'b0;
			AWADDR_S1   = 32'b0;
			AWLEN_S1    = 4'b0;
			AWSIZE_S1   = 3'b0;
			AWBURST_S1  = 2'b0;
		end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
		4'b0111: 
        begin
			AWVALID_S2  = AWVALID_M1;
			AWID_S2     = (~cs_w_w) ? {4'b1, AWID_M1} : AWID_Reg;
			AWADDR_S2   = (~cs_w_w) ? AWADDR_M1       : AWADDR_Reg;
			AWLEN_S2    = (~cs_w_w) ? AWLEN_M1        : AWLEN_Reg;
			AWSIZE_S2   = (~cs_w_w) ? AWSIZE_M1       : AWSIZE_Reg;
			AWBURST_S2  = (~cs_w_w) ? AWBURST_M1      : AWBURST_Reg;
		end
        default: 
        begin
			AWVALID_S2  = 1'b0;
			AWID_S2     = 8'b0;
			AWADDR_S2   = 32'b0;
			AWLEN_S2    = 4'b0;
			AWSIZE_S2   = 3'b0;
			AWBURST_S2  = 2'b0;
		end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
		4'b1001: 
        begin
			AWVALID_S3  = AWVALID_M1;
			AWID_S3     = (~cs_w_w) ? {4'b1, AWID_M1} : AWID_Reg;
			AWADDR_S3   = (~cs_w_w) ? AWADDR_M1       : AWADDR_Reg;
			AWLEN_S3    = (~cs_w_w) ? AWLEN_M1        : AWLEN_Reg;
			AWSIZE_S3   = (~cs_w_w) ? AWSIZE_M1       : AWSIZE_Reg;
			AWBURST_S3  = (~cs_w_w) ? AWBURST_M1      : AWBURST_Reg;
		end
        default: 
        begin
			AWVALID_S3  = 1'b0;
			AWID_S3     = 8'b0;
			AWADDR_S3   = 32'b0;
			AWLEN_S3    = 4'b0;
			AWSIZE_S3   = 3'b0;
			AWBURST_S3  = 2'b0;
		end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
		4'b1011: 
        begin
			AWVALID_S4  = AWVALID_M1;
			AWID_S4     = (~cs_w_w) ? {4'b1, AWID_M1} : AWID_Reg;
			AWADDR_S4   = (~cs_w_w) ? AWADDR_M1       : AWADDR_Reg;
			AWLEN_S4    = (~cs_w_w) ? AWLEN_M1        : AWLEN_Reg;
			AWSIZE_S4   = (~cs_w_w) ? AWSIZE_M1       : AWSIZE_Reg;
			AWBURST_S4  = (~cs_w_w) ? AWBURST_M1      : AWBURST_Reg;
		end
        default: 
        begin
			AWVALID_S4  = 1'b0;
			AWID_S4     = 8'b0;
			AWADDR_S4   = 32'b0;
			AWLEN_S4    = 4'b0;
			AWSIZE_S4   = 3'b0;
			AWBURST_S4  = 2'b0;
		end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
		4'b1101: 
        begin
			AWVALID_S5  = AWVALID_M1;
			AWID_S5     = (~cs_w_w) ? {4'b1, AWID_M1} : AWID_Reg;
			AWADDR_S5   = (~cs_w_w) ? AWADDR_M1       : AWADDR_Reg;
			AWLEN_S5    = (~cs_w_w) ? AWLEN_M1        : AWLEN_Reg;
			AWSIZE_S5   = (~cs_w_w) ? AWSIZE_M1       : AWSIZE_Reg;
			AWBURST_S5  = (~cs_w_w) ? AWBURST_M1      : AWBURST_Reg;
		end
        default: 
        begin
			AWVALID_S5  = 1'b0;
			AWID_S5     = 8'b0;
			AWADDR_S5   = 32'b0;
			AWLEN_S5    = 4'b0;
			AWSIZE_S5   = 3'b0;
			AWBURST_S5  = 2'b0;
		end
    endcase
end

endmodule
