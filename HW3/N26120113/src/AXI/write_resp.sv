`include "../include/AXI_define.svh"

module write_resp (
    input ACLK,
    input ARESETn,

    input [3:0] AW_arbiter,
    input BREADY_M1,

    input [`AXI_IDS_BITS-1:0] BID_S1,
    input [1:0] BRESP_S1,
    input BVALID_S1,

    input [`AXI_IDS_BITS-1:0] BID_S2,
    input [1:0] BRESP_S2,
    input BVALID_S2,

    input [`AXI_IDS_BITS-1:0] BID_S3,
    input [1:0] BRESP_S3,
    input BVALID_S3,

    input [`AXI_IDS_BITS-1:0] BID_S4,
    input [1:0] BRESP_S4,
    input BVALID_S4,

    input [`AXI_IDS_BITS-1:0] BID_S5,
    input [1:0] BRESP_S5,
    input BVALID_S5,

    output  logic [`AXI_ID_BITS-1:0]  BID_M1,
    output  logic [1:0] BRESP_M1,
    output  logic BVALID_M1,

    output  logic BREADY_S1,
    output  logic BREADY_S2,
    output  logic BREADY_S3,
    output  logic BREADY_S4,
    output  logic BREADY_S5
);

logic [`AXI_ID_BITS-1:0]  BID_Reg;
logic [1:0] BRESP_Reg;

always_ff @ (posedge ACLK) 
begin
    if (~ARESETn) 
    begin
		BID_Reg     <= `AXI_ID_BITS'b0;
        BRESP_Reg   <= 2'b0;
    end
    else 
    begin
        if (BVALID_S1) 
        begin
            BID_Reg     <= BID_S1[3:0];
            BRESP_Reg   <= BRESP_S1;
        end
        else if (BVALID_S2) 
        begin
            BID_Reg     <= BID_S2[3:0];
            BRESP_Reg   <= BRESP_S2;
        end
        else if (BVALID_S3) 
        begin
            BID_Reg     <= BID_S3[3:0];
            BRESP_Reg   <= BRESP_S3;
        end
        else if (BVALID_S4) 
        begin
            BID_Reg     <= BID_S4[3:0];
            BRESP_Reg   <= BRESP_S4;
        end
        else if (BVALID_S5) 
        begin
            BID_Reg     <= BID_S5[3:0];
            BRESP_Reg   <= BRESP_S5;
        end
        else 
        begin
            BID_Reg     <= BID_Reg;
            BRESP_Reg   <= BRESP_Reg;
        end
    end
end

always_comb 
begin
    case (AW_arbiter)
    	4'b0101: 
        begin
    		BVALID_M1   = BVALID_S1;
    		BID_M1      = (BVALID_S1) ? BID_S1[3:0] : BID_Reg;
    		BRESP_M1    = (BVALID_S1) ? BRESP_S1    : BRESP_Reg;
    	end
    	4'b0111: 
        begin
    		BVALID_M1   = BVALID_S2;
    		BID_M1      = (BVALID_S2) ? BID_S2[3:0] : BID_Reg;
    		BRESP_M1    = (BVALID_S2) ? BRESP_S2    : BRESP_Reg;
    	end
    	4'b1001: 
        begin
    		BVALID_M1   = BVALID_S3;
    		BID_M1      = (BVALID_S3) ? BID_S3[3:0] : BID_Reg;
    		BRESP_M1    = (BVALID_S3) ? BRESP_S3    : BRESP_Reg;
    	end
    	4'b1011: 
        begin
    		BVALID_M1   = BVALID_S4;
    		BID_M1      = (BVALID_S4) ? BID_S4[3:0] : BID_Reg;
    		BRESP_M1    = (BVALID_S4) ? BRESP_S4    : BRESP_Reg;
    	end
        4'b1101: 
        begin
    		BVALID_M1   = BVALID_S5;
    		BID_M1      = (BVALID_S5) ? BID_S5[3:0] : BID_Reg;
    		BRESP_M1    = (BVALID_S5) ? BRESP_S5    : BRESP_Reg;
    	end
    	default: 
        begin
    		BVALID_M1   = 1'b0;
    		BID_M1      = `AXI_ID_BITS'b0;
    		BRESP_M1    = `AXI_RESP_DECERR;
    	end
    endcase
end

always_comb 
begin
    case (AW_arbiter)
        4'b0101: BREADY_S1 = BREADY_M1;
        default: BREADY_S1 = 1'b0;
    endcase
end

always_comb 
begin
    case (AW_arbiter)
        4'b0111: BREADY_S2 = BREADY_M1;
        default: BREADY_S2 = 1'b0;
    endcase
end

always_comb 
begin
    case (AW_arbiter)
        4'b1001: BREADY_S3 = BREADY_M1;
        default: BREADY_S3 = 1'b0;
    endcase
end

always_comb 
begin
    case (AW_arbiter)
        4'b1011: BREADY_S4 = BREADY_M1;
        default: BREADY_S4 = 1'b0;
    endcase
end

always_comb 
begin
    case (AW_arbiter)
        4'b1101: BREADY_S5 = BREADY_M1;
        default: BREADY_S5 = 1'b0;
    endcase
end

endmodule
