//`include "D_tog.sv"
//`include "DFF_32bit.sv"

module WDT(
    input 			clk,
    input 			rst,
    input 			clk2,
    input 			rst2,
    //input WTOCNT_en,
    input 			WDEN,
    input 			WDLIVE,
    input 	[31:0]	WTOCNT,
    output	logic	WTO
);

enum logic [1:0] {IDLE, START, RESTART} state, next_state;
logic WDEN_reg, WDLIVE_reg;
logic [31:0] WTOCNT_reg;
logic [31:0] counter;
logic WTO_buffer, WTO_reg;

always_ff @ (posedge clk2) 
begin
    if (rst2)   
        WDEN_reg <= 1'b0;
    else 
        WDEN_reg <= WDEN;
end

always_ff @ (posedge clk2) 
begin
    if (rst2)   
        WDLIVE_reg <= 1'b0;
    else 
        WDLIVE_reg <= WDLIVE;
end

always_ff @ (posedge clk2) 
begin
    if (rst2)   
        WTOCNT_reg <= 32'd0;
    else 
        WTOCNT_reg <= WTOCNT;
end

always_ff @ (posedge clk2) 
begin
    if (rst2)
        counter <= 32'd0;
    else if (~WDEN_reg)
        counter <= 32'd0;
    else if (WDLIVE_reg)
        counter <= 32'd0;
    else if (WDEN_reg)
        counter <= counter + 32'd1;
end

/*
always_comb 
begin
	case (state)
		IDLE:
		begin 
			if(WDEN) 
				next_state = START;
			else
				next_state = IDLE;
		end
		START:
		begin 
			if(WDLIVE || ~WDEN) 
				next_state = RESTART;
			else
				next_state = START;
		end
		default: 
		begin                
			next_state = (WDEN) ? START : IDLE;
		end
	endcase
end

always @(posedge clk2)
begin
	if(rst2)
		counter <= 32'd0;
	else
	case (state)
		IDLE:
			counter <= 32'd0;
		START:
			counter <= counter + 32'd1;
		default:              
            counter <= 32'd0;
	endcase
end

always @(posedge clk2)
begin
	if(rst2)
		state <= IDLE;
	else
		state <= next_state;
end*/

always @(posedge clk2)
begin
	if(rst2)
		WTO_buffer <= 1'd0;
	//else if(counter == WTOCNT_reg & (counter != 31'd0))
	else if((counter == WTOCNT_reg) & WDEN_reg)
		WTO_buffer <= 1'd1;
    else 
		WTO_buffer <= 1'd0;
end

always @(posedge clk)
begin
	if(rst)
		WTO_reg <= 1'd0;
    else 
		WTO_reg <= WTO_buffer;
end

always @(posedge clk)
begin
	if(rst)
		WTO <= 1'd0;
    else 
		WTO <= WTO_reg;
end

endmodule
