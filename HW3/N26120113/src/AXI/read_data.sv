`include "../include/AXI_define.svh"

module read_data (
    input ACLK,
    input ARESETn,
    
    input [3:0] AR_arbiter,
    input [1:0] cs,

    input [`AXI_IDS_BITS-1:0]     RID_S0,
	input [`AXI_DATA_BITS-1:0]    RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,

    input [`AXI_IDS_BITS-1:0]     RID_S1,
    input [`AXI_DATA_BITS-1:0]    RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,

    input [`AXI_IDS_BITS-1:0]     RID_S2,
    input [`AXI_DATA_BITS-1:0]    RDATA_S2,
    input [1:0] RRESP_S2,
    input RLAST_S2,
    input RVALID_S2,

    input [`AXI_IDS_BITS-1:0]     RID_S3,
    input [`AXI_DATA_BITS-1:0]    RDATA_S3,
    input [1:0]                   RRESP_S3,
    input RLAST_S3,
    input RVALID_S3,

    input [`AXI_IDS_BITS-1:0]     RID_S4,
    input [`AXI_DATA_BITS-1:0]    RDATA_S4,
    input [1:0] RRESP_S4,
    input RLAST_S4,
    input RVALID_S4,

    input [`AXI_IDS_BITS-1:0]     RID_S5,
    input [`AXI_DATA_BITS-1:0]    RDATA_S5,
    input [1:0] RRESP_S5,
    input RLAST_S5,
    input RVALID_S5,

    input RREADY_M0,
    input RREADY_M1,

    output  logic   [`AXI_ID_BITS-1:0]      RID_M0,
    output  logic   [`AXI_DATA_BITS-1:0]    RDATA_M0,
	output  logic   [1:0] RRESP_M0,
	output  logic RLAST_M0,
	output  logic RVALID_M0,

    output  logic   [`AXI_ID_BITS-1:0]      RID_M1,
    output  logic   [`AXI_DATA_BITS-1:0]    RDATA_M1,
	output  logic   [1:0] RRESP_M1,
	output  logic RLAST_M1,
	output  logic RVALID_M1,

    output  logic RREADY_S0,
    output  logic RREADY_S1,
    output  logic RREADY_S2,
    output  logic RREADY_S3,
    output  logic RREADY_S4,
    output  logic RREADY_S5
);

logic [1:0] cs_r;
assign cs_r = cs;

logic [`AXI_IDS_BITS-1:0]  RID_reg;
logic [`AXI_DATA_BITS-1:0] RDATA_reg;
logic [1:0] RRESP_reg;
logic RLAST_reg;

always_ff @(posedge ACLK) 
begin
    if (~ARESETn) 
    begin
		RID_reg <= 8'd0;
		RDATA_reg <= 32'd0;
		RRESP_reg <= 2'd0;
		RLAST_reg <= 1'd0;
	end
    else 
    begin
        if (RVALID_S0 & cs_r == 2'd0) 
        begin
            RID_reg <= RID_S0;
            RDATA_reg <= RDATA_S0;
            RRESP_reg <= RRESP_S0;
            RLAST_reg <= RLAST_S0;
        end
        else if (RVALID_S1 & cs_r == 2'd0) 
        begin
            RID_reg <= RID_S1;
            RDATA_reg <= RDATA_S1;
            RRESP_reg <= RRESP_S1;
            RLAST_reg <= RLAST_S1;
        end
        else if (RVALID_S2 & cs_r == 2'd0) 
        begin
            RID_reg <= RID_S2;
            RDATA_reg <= RDATA_S2;
            RRESP_reg <= RRESP_S2;
            RLAST_reg <= RLAST_S2;
        end
        else if (RVALID_S3 & cs_r == 2'd0) 
        begin
            RID_reg <= RID_S3;
            RDATA_reg <= RDATA_S3;
            RRESP_reg <= RRESP_S3;
            RLAST_reg <= RLAST_S3;
        end
        else if (RVALID_S4 & cs_r == 2'd0) 
        begin
            RID_reg <= RID_S4;
            RDATA_reg <= RDATA_S4;
            RRESP_reg <= RRESP_S4;
            RLAST_reg <= RLAST_S4;
        end
        else if (RVALID_S5 & cs_r == 2'd0) 
        begin
            RID_reg <= RID_S5;
            RDATA_reg <= RDATA_S5;
            RRESP_reg <= RRESP_S5;
            RLAST_reg <= RLAST_S5;
        end
        else 
        begin
            RID_reg <= RID_reg;
            RDATA_reg <= RDATA_reg;
            RRESP_reg <= RRESP_reg;
            RLAST_reg <= RLAST_reg;
        end
    end
end

always_comb 
begin
    case (AR_arbiter)
        4'b0010: 
        begin
            if(RVALID_S0)
            begin 
                RID_M0   = RID_S0[3:0];
                RDATA_M0 = RDATA_S0;
                RRESP_M0 = RRESP_S0;
                RLAST_M0 = RLAST_S0;
            end
            else
            begin 
                RID_M0   = RID_reg[3:0];
                RDATA_M0 = RDATA_reg;
                RRESP_M0 = RRESP_reg;
                RLAST_M0 = RLAST_reg;
            end
        end
        4'b0100: 
        begin
            if(RVALID_S1)
            begin 
                RID_M0 = RID_S1[3:0];
                RDATA_M0 = RDATA_S1;
                RRESP_M0 = RRESP_S1;
                RLAST_M0 = RLAST_S1;
            end
            else
            begin 
                RID_M0 = RID_reg[3:0];
                RDATA_M0 = RDATA_reg;
                RRESP_M0 = RRESP_reg;
                RLAST_M0 = RLAST_reg;
            end
        end
        4'b0110: 
        begin
            if(RVALID_S2)
            begin 
                RID_M0   = RID_S2[3:0];
                RDATA_M0 = RDATA_S2;
                RRESP_M0 = RRESP_S2;
                RLAST_M0 = RLAST_S2;
            end
            else
            begin 
                RID_M0 = RID_reg[3:0];
                RDATA_M0 = RDATA_reg;
                RRESP_M0 = RRESP_reg;
                RLAST_M0 = RLAST_reg;
            end
        end
        4'b1000: 
        begin
            if(RVALID_S3)
            begin 
                RID_M0   = RID_S3[3:0];
                RDATA_M0 = RDATA_S3;
                RRESP_M0 = RRESP_S3;
                RLAST_M0 = RLAST_S3;
            end
            else
            begin 
                RID_M0 = RID_reg[3:0];
                RDATA_M0 = RDATA_reg;
                RRESP_M0 = RRESP_reg;
                RLAST_M0 = RLAST_reg;
            end
        end
        4'b1010: 
        begin
            if(RVALID_S4)
            begin 
                RID_M0   = RID_S4[3:0];
                RDATA_M0 = RDATA_S4;
                RRESP_M0 = RRESP_S4;
                RLAST_M0 = RLAST_S4;
            end
            else
            begin 
                RID_M0 = RID_reg[3:0];
                RDATA_M0 = RDATA_reg;
                RRESP_M0 = RRESP_reg;
                RLAST_M0 = RLAST_reg;
            end
        end
        4'b1100: 
        begin
            if(RVALID_S5)
            begin 
                RID_M0 = RID_S5[3:0];
                RDATA_M0 = RDATA_S5;
                RRESP_M0 = RRESP_S5;
                RLAST_M0 = RLAST_S5;
            end
            else
            begin 
                RID_M0 = RID_reg[3:0];
                RDATA_M0 = RDATA_reg;
                RRESP_M0 = RRESP_reg;
                RLAST_M0 = RLAST_reg;
            end
        end
        4'b1110: 
        begin
            if(RVALID_S0)
            begin 
                RID_M0   = RID_S0[3:0];
                RDATA_M0 = RDATA_S0;
                RRESP_M0 = RRESP_S0;
                RLAST_M0 = RLAST_S0;
            end
            else
            begin 
                RID_M0   = RID_reg[3:0];
                RDATA_M0 = RDATA_reg;
                RRESP_M0 = RRESP_reg;
                RLAST_M0 = RLAST_reg;
            end
        end
        default: 
        begin
            RID_M0   = 4'b0;
            RDATA_M0 = 32'b0;
            RRESP_M0 = `AXI_RESP_DECERR;
            RLAST_M0 = 1'b0;
        end
    endcase
end

always_comb 
begin
    case (AR_arbiter)
        4'b0011: 
        begin
            if(RVALID_S0)
            begin 
                RID_M1   = RID_S0[3:0];
                RDATA_M1 = RDATA_S0;
                RRESP_M1 = RRESP_S0;
                RLAST_M1 = RLAST_S0;
            end
            else
            begin 
                RID_M1   = RID_reg[3:0];
                RDATA_M1 = RDATA_reg;
                RRESP_M1 = RRESP_reg;
                RLAST_M1 = RLAST_reg;
            end
        end
        4'b0101: 
        begin
            if(RVALID_S1)
            begin 
                RID_M1   = RID_S1[3:0];
                RDATA_M1 = RDATA_S1;
                RRESP_M1 = RRESP_S1;
                RLAST_M1 = RLAST_S1;
            end
            else
            begin 
                RID_M1   = RID_reg[3:0];
                RDATA_M1 = RDATA_reg;
                RRESP_M1 = RRESP_reg;
                RLAST_M1 = RLAST_reg;
            end
        end
        4'b0111: 
        begin
            if(RVALID_S2)
            begin 
                RID_M1   = RID_S2[3:0];
                RDATA_M1 = RDATA_S2;
                RRESP_M1 = RRESP_S2;
                RLAST_M1 = RLAST_S2;
            end
            else
            begin 
                RID_M1   = RID_reg[3:0];
                RDATA_M1 = RDATA_reg;
                RRESP_M1 = RRESP_reg;
                RLAST_M1 = RLAST_reg;
            end
        end
        4'b1001: 
        begin
            if(RVALID_S3)
            begin 
                RID_M1   = RID_S3[3:0];
                RDATA_M1 = RDATA_S3;
                RRESP_M1 = RRESP_S3;
                RLAST_M1 = RLAST_S3;
            end
            else
            begin 
                RID_M1   = RID_reg[3:0];
                RDATA_M1 = RDATA_reg;
                RRESP_M1 = RRESP_reg;
                RLAST_M1 = RLAST_reg;
            end
        end
        4'b1011: 
        begin
            if(RVALID_S4)
            begin 
                RID_M1   = RID_S4[3:0];
                RDATA_M1 = RDATA_S4;
                RRESP_M1 = RRESP_S4;
                RLAST_M1 = RLAST_S4;
            end
            else
            begin 
                RID_M1   = RID_reg[3:0];
                RDATA_M1 = RDATA_reg;
                RRESP_M1 = RRESP_reg;
                RLAST_M1 = RLAST_reg;
            end
        end
        4'b1101: 
        begin
            if(RVALID_S5)
            begin 
                RID_M1   = RID_S5[3:0];
                RDATA_M1 = RDATA_S5;
                RRESP_M1 = RRESP_S5;
                RLAST_M1 = RLAST_S5;
            end
            else
            begin 
                RID_M1   = RID_reg[3:0];
                RDATA_M1 = RDATA_reg;
                RRESP_M1 = RRESP_reg;
                RLAST_M1 = RLAST_reg;
            end
        end
        default: 
        begin
            RID_M1   = `AXI_ID_BITS'b0;
            RDATA_M1 = `AXI_DATA_BITS'b0;
            RRESP_M1 = `AXI_RESP_DECERR;
            RLAST_M1 = 1'b0;
        end
    endcase
end

always_comb 
begin
    case (AR_arbiter)
        4'b0010: RVALID_M0 = RVALID_S0;
        4'b0100: RVALID_M0 = RVALID_S1;
        4'b0110: RVALID_M0 = RVALID_S2;
        4'b1000: RVALID_M0 = RVALID_S3;
        4'b1010: RVALID_M0 = RVALID_S4;
        4'b1100: RVALID_M0 = RVALID_S5;
        default: RVALID_M0 = 1'b0;
    endcase
end

always_comb 
begin
    case (AR_arbiter)
        4'b0011: RVALID_M1 = RVALID_S0;
        4'b0101: RVALID_M1 = RVALID_S1;
        4'b0111: RVALID_M1 = RVALID_S2;
        4'b1001: RVALID_M1 = RVALID_S3;
        4'b1011: RVALID_M1 = RVALID_S4;
        4'b1101: RVALID_M1 = RVALID_S5;
        default: RVALID_M1 = 1'b0;
    endcase
end

always_comb 
begin
    case (AR_arbiter)
    	4'b0010:
            RREADY_S0 = RREADY_M0;
        4'b1110:   
            RREADY_S0 = RREADY_M0;
        4'b0011:   
            RREADY_S0 = RREADY_M1;
        4'b1111:
            RREADY_S0 = RREADY_M1;
    	default:                    
            RREADY_S0 = 1'd0;
    endcase
end

always_comb 
begin
    case (AR_arbiter)
    	4'b0100:                
            RREADY_S1 = RREADY_M0;
    	4'b0101:                
            RREADY_S1 = RREADY_M1;
    	default:                    
            RREADY_S1 = 1'b0;
    endcase
end

always_comb 
begin
    case (AR_arbiter)
    	4'b0110:                
            RREADY_S2 = RREADY_M0;
    	4'b0111:                
            RREADY_S2 = RREADY_M1;
    	default:                    
            RREADY_S2 = 1'b0;
    endcase
end

always_comb 
begin
    case (AR_arbiter)
    	4'b1000:                
            RREADY_S3 = RREADY_M0;
    	4'b1001:                
            RREADY_S3 = RREADY_M1;
    	default:                    
            RREADY_S3 = 1'b0;
    endcase
end

always_comb 
begin
    case (AR_arbiter)
    	4'b1010:                
            RREADY_S4 = RREADY_M0;
    	4'b1011:                
            RREADY_S4 = RREADY_M1;
    	default:                    
            RREADY_S4 = 1'b0;
    endcase
end

always_comb 
begin
    case (AR_arbiter)
    	4'b1100:                
            RREADY_S5 = RREADY_M0;
    	4'b1101:                
            RREADY_S5 = RREADY_M1;
    	default:                    
            RREADY_S5 = 1'b0;
    endcase
end

endmodule
