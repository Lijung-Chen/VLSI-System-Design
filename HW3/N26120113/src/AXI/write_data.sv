`include "../include/AXI_define.svh"

module write_data (
    input ACLK,
    input ARESETn,

    input [3:0] AW_arbiter,

    input [`AXI_DATA_BITS-1:0]    WDATA_M1,
	input [`AXI_STRB_BITS-1:0]    WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
    output  logic WREADY_M1,

    input WREADY_S1,
    input WREADY_S2,
    input WREADY_S3,
    input WREADY_S4,
    input WREADY_S5,

    output  logic   [`AXI_DATA_BITS-1:0]    WDATA_S1,
	output  logic   [`AXI_STRB_BITS-1:0]    WSTRB_S1,
	output  logic WLAST_S1,
	output  logic WVALID_S1,

    output  logic   [`AXI_DATA_BITS-1:0]    WDATA_S2,
	output  logic   [`AXI_STRB_BITS-1:0]    WSTRB_S2,
	output  logic WLAST_S2,
	output  logic WVALID_S2,

    output  logic   [`AXI_DATA_BITS-1:0]    WDATA_S3,
	output  logic   [`AXI_STRB_BITS-1:0]    WSTRB_S3,
	output  logic WLAST_S3,
	output  logic WVALID_S3,

    output  logic   [`AXI_DATA_BITS-1:0]    WDATA_S4,
	output  logic   [`AXI_STRB_BITS-1:0]    WSTRB_S4,
	output  logic WLAST_S4,
	output  logic WVALID_S4,

    output  logic   [`AXI_DATA_BITS-1:0]    WDATA_S5,
	output  logic   [`AXI_STRB_BITS-1:0]    WSTRB_S5,
	output  logic WLAST_S5,
	output  logic WVALID_S5
);

logic [31:0] WDATA_Reg;
logic [3:0] WSTRB_Reg;
logic WLAST_Reg;

always_ff @(posedge ACLK) 
begin
	if (~ARESETn) 
    begin
	    WDATA_Reg <= 32'b0;
        WSTRB_Reg <= 4'b0;
        WLAST_Reg <= 1'b0;
	end
	else 
    begin
        if (WVALID_M1) 
        begin
            WDATA_Reg <= WDATA_M1;
            WSTRB_Reg <= WSTRB_M1;
            WLAST_Reg <= WLAST_M1;
        end
        else 
        begin
            WDATA_Reg <= WDATA_Reg;
            WSTRB_Reg <= WSTRB_Reg;
            WLAST_Reg <= WLAST_Reg;
        end
    end
end

always_comb begin
    case (AW_arbiter)
    	4'b0101: 
        begin
    		WVALID_S1   = WVALID_M1;
    		WDATA_S1    = (WVALID_M1) ? WDATA_M1 : WDATA_Reg;
    		WSTRB_S1    = (WVALID_M1) ? WSTRB_M1 : WSTRB_Reg;
    		WLAST_S1    = (WVALID_M1) ? WLAST_M1 : WLAST_Reg;
    	end
    	default: 
        begin
    		WVALID_S1   = 1'b0;
    		WDATA_S1    = 32'b0;
    		WSTRB_S1    = 4'b0;
    		WLAST_S1    = 1'b0;
    	end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
    	4'b0111: 
        begin
    		WVALID_S2   = WVALID_M1;
    		WDATA_S2    = (WVALID_M1) ? WDATA_M1 : WDATA_Reg;
    		WSTRB_S2    = (WVALID_M1) ? WSTRB_M1 : WSTRB_Reg;
    		WLAST_S2    = (WVALID_M1) ? WLAST_M1 : WLAST_Reg;
    	end
    	default: 
        begin
    		WVALID_S2   = 1'b0;
    		WDATA_S2    = 32'b0;
    		WSTRB_S2    = 4'b0;
    		WLAST_S2    = 1'b0;
    	end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
    	4'b1001: 
        begin
    		WVALID_S3   = WVALID_M1;
    		WDATA_S3    = (WVALID_M1) ? WDATA_M1 : WDATA_Reg;
    		WSTRB_S3    = (WVALID_M1) ? WSTRB_M1 : WSTRB_Reg;
    		WLAST_S3    = (WVALID_M1) ? WLAST_M1 : WLAST_Reg;
    	end
    	default: 
        begin
    		WVALID_S3   = 1'b0;
    		WDATA_S3    = 32'b0;
    		WSTRB_S3    = 4'b0;
    		WLAST_S3    = 1'b0;
    	end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
    	4'b1011: 
        begin
    		WVALID_S4   = WVALID_M1;
    		WDATA_S4    = (WVALID_M1) ? WDATA_M1 : WDATA_Reg;
    		WSTRB_S4    = (WVALID_M1) ? WSTRB_M1 : WSTRB_Reg;
    		WLAST_S4    = (WVALID_M1) ? WLAST_M1 : WLAST_Reg;
    	end
    	default: 
        begin
    		WVALID_S4   = 1'b0;
    		WDATA_S4    = 32'b0;
    		WSTRB_S4    = 4'b0;
    		WLAST_S4    = 1'b0;
    	end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
    	4'b1101: 
        begin
    		WVALID_S5   = WVALID_M1;
    		WDATA_S5    = (WVALID_M1) ? WDATA_M1 : WDATA_Reg;
    		WSTRB_S5    = (WVALID_M1) ? WSTRB_M1 : WSTRB_Reg;
    		WLAST_S5    = (WVALID_M1) ? WLAST_M1 : WLAST_Reg;
    	end
    	default: 
        begin
    		WVALID_S5   = 1'b0;
    		WDATA_S5    = 32'b0;
    		WSTRB_S5    = 4'b0;
    		WLAST_S5    = 1'b0;
    	end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
    	4'b0101: 
			WREADY_M1 = WREADY_S1;
    	4'b0111: 
			WREADY_M1 = WREADY_S2;
    	4'b1001: 
			WREADY_M1 = WREADY_S3;
    	4'b1011: 
			WREADY_M1 = WREADY_S4;
		4'b1101: 
			WREADY_M1 = WREADY_S5;
    	default: 
			WREADY_M1 = 1'b0;
    endcase
end

endmodule
