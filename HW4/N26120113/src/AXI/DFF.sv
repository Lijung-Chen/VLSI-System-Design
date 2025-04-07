module DFF
(
    input  logic  clk,
    input  logic  rst,
    input  logic  din,
    output logic  dout
);

logic d;

always_ff @(posedge clk) 
begin
    if (rst)
        d <= 1'b0;
    else
        d <= din;
end

//Dout is DFF2
always_ff @(posedge clk) 
begin
    if (rst)
        dout <= 1'b0;
    else
        dout <= d;
end

endmodule