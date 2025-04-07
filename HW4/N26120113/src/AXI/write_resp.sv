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


always_comb 
begin
    case (AW_arbiter)
    	4'b0101: 
        begin
    		BVALID_M1   = BVALID_S1;
    		BID_M1      = BID_S1[3:0];
    		BRESP_M1    = BRESP_S1;
    	end
    	4'b0111: 
        begin
    		BVALID_M1   = BVALID_S2;
    		BID_M1      = BID_S2[3:0];
    		BRESP_M1    = BRESP_S2;
    	end
    	4'b1001: 
        begin
    		BVALID_M1   = BVALID_S3;
    		BID_M1      = BID_S3[3:0];
    		BRESP_M1    = BRESP_S3;
    	end
    	4'b1011: 
        begin
    		BVALID_M1   = BVALID_S4;
    		BID_M1      = BID_S4[3:0];
    		BRESP_M1    = BRESP_S4;
    	end
        4'b1101: 
        begin
    		BVALID_M1   = BVALID_S5;
    		BID_M1      = BID_S5[3:0];
    		BRESP_M1    = BRESP_S5;
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
