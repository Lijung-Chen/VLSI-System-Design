`include "../include/AXI_define.svh"

module DRAM_wrapper(
    input clk,
    input rst,
    input [`AXI_IDS_BITS-1:0] ARID,
    input [`AXI_ADDR_BITS-1:0] ARADDR,
    input [`AXI_LEN_BITS-1:0] ARLEN,
    input [`AXI_SIZE_BITS-1:0] ARSIZE,
    input [1:0] ARBURST,
    input ARVALID,
    output  logic ARREADY,
    
    input RREADY,
    output  logic   [`AXI_IDS_BITS-1:0] RID,
    output  logic   [`AXI_DATA_BITS-1:0] RDATA,
    output  logic   [1:0] RRESP,
    output  logic   RLAST,
    output  logic   RVALID,
    
    input   [`AXI_IDS_BITS-1:0] AWID,
    input   [`AXI_ADDR_BITS-1:0] AWADDR,
    input   [`AXI_LEN_BITS-1:0] AWLEN,
    input   [`AXI_SIZE_BITS-1:0] AWSIZE,
    input   [1:0] AWBURST,
    input   AWVALID,
    output  logic  AWREADY,
    
    input   [`AXI_DATA_BITS-1:0] WDATA,
    input   [`AXI_STRB_BITS-1:0] WSTRB,
    input   WLAST,
    input   WVALID,
    output  logic  WREADY,
    
    input   BREADY,
    output  logic   [`AXI_IDS_BITS-1:0]  BID,
    output  logic   [1:0]   BRESP,
    output  logic   BVALID,
    
    input   [31:0]  DRAM_Q,
    input   DRAM_valid,
    output  logic   DRAM_CSn,
    output  logic   [3:0]  DRAM_WEn,
    output  logic   DRAM_RASn,
    output  logic   DRAM_CASn,
    output  logic   [10:0] DRAM_A,
    output  logic   [31:0] DRAM_D
);

enum logic [2:0] {IDLE, ACT, READ, WRITE, PRE, BVAL} cs, ns;
logic write, row_hit, row_hit_reg, row_miss;
logic [2:0] counter;
logic [31:0] preaddr;
logic [11:0] row_addr;
logic [3:0] len_r, len_w, counter_r, counter_w;
assign row_hit = (AWVALID & AWREADY) ? (AWADDR[22:12] == row_addr) ? 1'd1 : 1'd0 : (ARVALID && ARREADY) ? (ARADDR[22:12] == row_addr) ? 1'd1 : 1'd0 : 1'd0;
assign row_miss = (AWVALID & AWREADY) ? (AWADDR[22:12] != row_addr) ? 1'd1 : 1'd0 : (ARVALID && ARREADY) ? (ARADDR[22:12] != row_addr) ? 1'd1 : 1'd0 : 1'd0;

always_ff @(posedge clk)
begin 
    if(rst)
        cs <= IDLE;
	else
        cs <= ns;
end

always_ff @(posedge clk)
begin 
    if(rst)
        counter_w <= IDLE;
    else if(row_hit & (counter_w < 4'd2))
        counter_w <= counter_w + 1'd1;
    else if(row_miss)
        counter_w <= 4'd0;
	else
        counter_w <= counter_w;
end

always_ff @(posedge clk)
begin 
    if(rst)
        row_hit_reg <= 1'd0;
    else if(row_hit)
        row_hit_reg <= 1'd1;
    else if(cs == IDLE)
        row_hit_reg <= 1'd0;
	else
        row_hit_reg <= row_hit_reg;
end

always_ff @(posedge clk)
begin 
    if(rst)
        row_addr <= 11'd0;
    else if(cs == ACT)
        row_addr <= preaddr[22:12];
	else
        row_addr <= row_addr;
end

always_ff @(posedge clk)
begin 
    if(rst)
    begin 
        preaddr <= 32'd0;
        write <= 1'd0;
    end
    else if(cs == IDLE)
    begin 
        preaddr <= (write || (AWVALID & AWREADY)) ? AWADDR : ARADDR;
        write <= (AWVALID & AWREADY) ? 1'd1 : 1'd0;
    end
	else
    begin 
        preaddr <= preaddr;
        write <= write;
    end
end

always_ff @(posedge clk)
begin 
    if(rst)
		len_r <= 4'd0;
	else if(ARVALID)
		len_r <= ARLEN;
	else
		len_r <= len_r;
end

always_ff @(posedge clk) 
begin
    if(rst) 
        counter <= 3'd0;
    else 
    begin
        if((cs != IDLE) && (cs != BVAL)) 
            counter <= (counter == 3'd4)? 3'd0 : counter + 3'd1;
        else
            counter <= 3'd0;
    end
end

always_comb 
begin
	case (cs)
        IDLE: 
		begin 
            if((AWVALID && AWREADY) & (row_hit || row_hit_reg))
                ns = WRITE;
            else if((ARVALID && ARREADY) & (row_hit || row_hit_reg))
                ns = READ;
			else if((AWVALID && AWREADY) || (ARVALID && ARREADY))
                ns = ACT;
            else
                ns = IDLE;
		end
		ACT: 
		begin 
            if(counter == 3'd4)
                ns = (write) ? WRITE : READ;
            else 
                ns = ACT;
		end
		READ:
		begin 
            if(row_hit_reg & counter == 3'd4)
                ns = BVAL;
            else if(counter == 3'd4)
                ns = PRE;
            else
                ns = READ;
		end
		WRITE:
		begin 
            if(row_hit_reg & counter == 3'd4)
                ns = BVAL;
            else if(counter == 3'd4)
                ns = PRE;
            else
                ns = WRITE;
		end
		PRE: 
		begin  
            if(counter == 3'd4)
                ns = IDLE;
            else
                ns = PRE;
		end
		default:
        begin 
            if(RVALID & RREADY)
                ns = IDLE;
            else if(BVALID & BREADY)
                ns = IDLE;
            else
                ns = BVAL;
        end
	endcase
end

/*
always_comb  
begin 
    case(cs)
        IDLE:
        begin
            ARREADY     = 1'd1;
            RID         = ARID;
            RDATA       = 32'd0;
            RRESP       = `AXI_RESP_OKAY;
            RLAST       = 1'd0;
            RVALID      = 1'd0;

            AWREADY     = 1'd1;
            WREADY      = 1'd0;
            BID         = AWID; 
            BRESP       = `AXI_RESP_OKAY;
            BVALID      = 1'd0;

            DRAM_CSn    = 1'd0;
            DRAM_RASn   = 1'd1;
            DRAM_CASn   = 1'd1;
            DRAM_A      = 11'd0;
            DRAM_D      = 32'd0;
        end  
        ACT:
        begin
            ARREADY     = 1'd1;
            RID         = ARID;
            RDATA       = 32'd0;
            RRESP       = `AXI_RESP_OKAY;
            RLAST       = 1'd0;
            RVALID      = 1'd0;

            AWREADY     = 1'd1;
            WREADY      = 1'd0;
            BID         = AWID; 
            BRESP       = `AXI_RESP_OKAY;
            BVALID      = 1'd0;

            DRAM_CSn    = 1'd0;
            DRAM_RASn   = (counter == 3'd0)? 1'd0 : 1'd1;
            DRAM_CASn   = 1'd1;
            DRAM_A      = (write) ? preaddr[22:12] : preaddr[22:12];
            DRAM_D      = 32'd0;
        end
        READ:
        begin 
            ARREADY     = 1'd1;
            RID         = ARID;
            RDATA       = DRAM_Q;
            RRESP       = `AXI_RESP_OKAY;
            RLAST       = 1'd1;
            RVALID      = DRAM_valid;

            AWREADY     = 1'd1;
            WREADY      = 1'd0;
            BID         = AWID; 
            BRESP       = `AXI_RESP_OKAY;
            BVALID      = 1'd0;

            DRAM_CSn    = 1'd0;
            DRAM_RASn   = 1'd1;
            DRAM_CASn   = (counter == 3'd0) ? 1'd0 : 1'd1;
            DRAM_A      = (len_r != 4'd0) ? {1'b0, preaddr[11:4], counter_r} : {1'b0, preaddr[11:2]};
            DRAM_D      = 32'd0;
        end
        WRITE:
        begin 
            ARREADY     = 1'b1;
            RID         = ARID;
            RDATA       = 32'd0;
            RRESP       = `AXI_RESP_OKAY;
            RLAST       = 1'b0;
            RVALID      = 1'd0;

            AWREADY     = 1'b1;
            WREADY      = (counter == 3'd0) ? 1'd1 : 1'd0;
            BID         = AWID; 
            BRESP       = `AXI_RESP_OKAY;
            BVALID      = 1'b0;

            DRAM_CSn    = 1'b0;
            DRAM_RASn   = 1'b1;
            DRAM_CASn   = (counter == 3'd0) ? 1'd0 : 1'd1;
            DRAM_A      = {1'b0, preaddr[11:2]};
            DRAM_D      = WDATA;
        end
        PRE:
        begin
            ARREADY     = 1'b1;
            RID         = ARID;
            RDATA       = DRAM_Q;
            RRESP       = `AXI_RESP_OKAY;
            RLAST       = (DRAM_valid) ? 1'd1 : 1'd0;
            RVALID      = DRAM_valid;

            AWREADY     = 1'b1;
            WREADY      = 1'b0;
            BID         = AWID; 
            BRESP       = `AXI_RESP_OKAY;
            BVALID      = (counter == 3'd0) ? 1'd1 : 1'd0;

            DRAM_CSn    = 1'b0;
            DRAM_RASn   = (counter == 3'd0) ? 1'd0 : 1'd1;
            DRAM_CASn   = 1'b1;
            DRAM_A      = (write) ? preaddr[22:12] : preaddr[22:12];
            DRAM_D      = WDATA;
        end
        default:
        begin
            ARREADY     = 1'd1;
            RID         = ARID;
            RDATA       = DRAM_Q;
            RRESP       = `AXI_RESP_OKAY;
            RLAST       = 1'd1;
            RVALID      = DRAM_valid;

            AWREADY     = 1'd1;
            WREADY      = 1'd0;
            BID         = AWID; 
            BRESP       = `AXI_RESP_OKAY;
            BVALID      = 1'd1;

            DRAM_CSn    = 1'd0;
            DRAM_RASn   = 1'd1;
            DRAM_CASn   = 1'd1;
            DRAM_A      = 11'd0;
            DRAM_D      = 32'd0;
        end 
    endcase
end
*/
always_ff @(posedge clk)
begin 
    if(rst) begin
        ARREADY     <= 1'd1;
        RID         <= ARID;
        RDATA       <= 32'd0;
        RRESP       <= `AXI_RESP_OKAY;
        RLAST       <= 1'd0;
        RVALID      <= 1'd0;

        AWREADY     <= 1'd1;
        WREADY      <= 1'd0;
        BID         <= AWID; 
        BRESP       <= `AXI_RESP_OKAY;
        BVALID      <= 1'd0;

        DRAM_CSn    <= 1'd0;
        DRAM_RASn   <= 1'd1;
        DRAM_CASn   <= 1'd1;
        DRAM_A      <= 11'd0;
        DRAM_D      <= 32'd0;
    end
    else
    case(cs)
        IDLE:
        begin
            ARREADY     <= 1'd1;
            RID         <= ARID;
            RDATA       <= 32'd0;
            RRESP       <= `AXI_RESP_OKAY;
            RLAST       <= 1'd0;
            RVALID      <= 1'd0;

            AWREADY     <= 1'd1;
            WREADY      <= 1'd0;
            BID         <= AWID; 
            BRESP       <= `AXI_RESP_OKAY;
            BVALID      <= 1'd0;

            DRAM_CSn    <= 1'd0;
            DRAM_RASn   <= 1'd1;
            DRAM_CASn   <= 1'd1;
            DRAM_A      <= 11'd0;
            DRAM_D      <= 32'd0;
        end  
        ACT:
        begin
            ARREADY     <= 1'd1;
            RID         <= ARID;
            RDATA       <= 32'd0;
            RRESP       <= `AXI_RESP_OKAY;
            RLAST       <= 1'd0;
            RVALID      <= 1'd0;

            AWREADY     <= 1'd1;
            WREADY      <= 1'd0;
            BID         <= AWID; 
            BRESP       <= `AXI_RESP_OKAY;
            BVALID      <= 1'd0;

            DRAM_CSn    <= 1'd0;
            DRAM_RASn   <= (counter == 3'd0)? 1'd0 : 1'd1;
            DRAM_CASn   <= 1'd1;
            DRAM_A      <= preaddr[22:12];
            DRAM_D      <= 32'd0;
        end
        READ:
        begin 
            ARREADY     <= 1'd1;
            RID         <= ARID;
            RDATA       <= DRAM_Q;
            RRESP       <= `AXI_RESP_OKAY;
            RLAST       <= 1'd1;
            RVALID      <= DRAM_valid;

            AWREADY     <= 1'd1;
            WREADY      <= 1'd0;
            BID         <= AWID; 
            BRESP       <= `AXI_RESP_OKAY;
            BVALID      <= 1'd0;

            DRAM_CSn    <= 1'd0;
            DRAM_RASn   <= 1'd1;
            DRAM_CASn   <= (counter == 3'd0) ? 1'd0 : 1'd1;
            DRAM_A      <= (len_r != 4'd0) ? {1'b0, preaddr[11:4], counter[1:0]} : {1'b0, preaddr[11:2]};
            DRAM_D      <= 32'd0;
        end
        WRITE:
        begin 
            ARREADY     <= 1'b1;
            RID         <= ARID;
            RDATA       <= 32'd0;
            RRESP       <= `AXI_RESP_OKAY;
            RLAST       <= 1'b0;
            RVALID      <= 1'd0;

            AWREADY     <= 1'b1;
            WREADY      <= (counter == 3'd0) ? 1'd1 : 1'd0;
            BID         <= AWID; 
            BRESP       <= `AXI_RESP_OKAY;
            BVALID      <= 1'b0;

            DRAM_CSn    <= 1'b0;
            DRAM_RASn   <= 1'b1;
            DRAM_CASn   <= (counter == 3'd0) ? 1'd0 : 1'd1;
            DRAM_A      <= {1'b0, preaddr[11:2]};
            DRAM_D      <= WDATA;
        end
        PRE:
        begin
            ARREADY     <= 1'b1;
            RID         <= ARID;
            RDATA       <= DRAM_Q;
            RRESP       <= `AXI_RESP_OKAY;
            RLAST       <= (DRAM_valid) ? 1'd1 : 1'd0;
            RVALID      <= DRAM_valid;

            AWREADY     <= 1'b1;
            WREADY      <= 1'b0;
            BID         <= AWID; 
            BRESP       <= `AXI_RESP_OKAY;
            BVALID      <= (counter == 3'd0) ? 1'd1 : 1'd0;

            DRAM_CSn    <= 1'b0;
            DRAM_RASn   <= (counter == 3'd0) ? 1'd0 : 1'd1;
            DRAM_CASn   <= 1'b1;
            DRAM_A      <= preaddr[22:12];
            DRAM_D      <= WDATA;
        end
        default:
        begin
            ARREADY     <= 1'd1;
            RID         <= ARID;
            RDATA       <= DRAM_Q;
            RRESP       <= `AXI_RESP_OKAY;
            RLAST       <= 1'd1;
            RVALID      <= DRAM_valid;

            AWREADY     <= 1'd1;
            WREADY      <= 1'd0;
            BID         <= AWID; 
            BRESP       <= `AXI_RESP_OKAY;
            BVALID      <= 1'd1;

            DRAM_CSn    <= 1'd0;
            DRAM_RASn   <= 1'd1;
            DRAM_CASn   <= 1'd1;
            DRAM_A      <= 11'd0;
            DRAM_D      <= 32'd0;
        end 
    endcase
end


always_comb 
begin 
    if(WREADY & WVALID)
    begin 
        DRAM_WEn = {~WSTRB[3],~WSTRB[2],~WSTRB[1],~WSTRB[0]};
    end
    else if (cs==PRE & ~DRAM_RASn) 
    begin
        DRAM_WEn = 4'b0;
    end
    else if (cs == WRITE & ~DRAM_CASn) 
    begin
        DRAM_WEn = 4'b0;
    end
    else begin
        DRAM_WEn = 4'b1111;
    end
end

endmodule