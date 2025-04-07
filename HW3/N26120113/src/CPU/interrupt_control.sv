module  interrupt_control(
    input           clk,
    input           rst,
    input           Stall,
    input           IM_busy,
    input           DM_busy,
    input           WFI,
    input           MRET,
    input           MEIE,
    input           MTIE,
    input           SENSOR_CTRL_interrupt,
    input           WDT_interrupt,
    output  logic   interrupt_taken,
    output  logic   WFI_mode
);

parameter   normal_state = 2'b00;
parameter   handle_interrupt_state = 2'b01;
parameter   WFI_state = 2'b10;

logic   interrupt_external;
logic   interrupt_timer;
logic   interrupt_en;
logic   [1:0]cs ,ns;


assign  interrupt_external = (SENSOR_CTRL_interrupt && MEIE);
assign  interrupt_timer = (WDT_interrupt && MTIE);

//assign  interrupt_taken = (interrupt_external && interrupt_en) || interrupt_timer;
assign  interrupt_taken = (interrupt_external || interrupt_timer) && interrupt_en;

assign  WFI_mode = (cs == WFI_state);

always_ff@(posedge clk) begin
    if(rst) cs <= normal_state;
    else    cs <= ns;
end

always_comb begin
    case(cs)
        normal_state:   begin
            if(interrupt_external || interrupt_timer)   begin
                //ns = handle_interrupt_state;
                //interrupt_en = 1'b1;
                ns = (Stall)? normal_state : handle_interrupt_state;
                interrupt_en = (Stall)? 1'b0 : 1'b1;
            end
            else if(WFI)    begin
                ns = WFI_state;
                interrupt_en = 1'b1;
            end
            else    begin
                ns = normal_state;
                interrupt_en = 1'b1;
            end
        end
        handle_interrupt_state: begin
            if(MRET)    begin
                ns = normal_state;
                interrupt_en = 1'b0;
            end
            else    begin
                ns = handle_interrupt_state;
                interrupt_en = 1'b0;
            end
        end
        WFI_state:  begin
            if(interrupt_external || interrupt_timer)   begin
                ns = handle_interrupt_state;
                interrupt_en = 1'b1;
            end
            else begin
                ns = WFI_state;
                interrupt_en = 1'b1;
            end
        end
        default:    begin
            ns = normal_state;
            interrupt_en = 1'b1;
        end
    endcase
end

endmodule