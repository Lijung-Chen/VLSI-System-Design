//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "def.svh"
//`include "data_array_wrapper.sv"
//`include "tag_array_wrapper.sv"

module L1C_inst(
input                                 clk,
input                                 rst,
// Core to CPU wrapper
input         [`DATA_BITS-1:0]        core_addr,
input                                 core_req,
input                                 core_write,
input         [`DATA_BITS-1:0]        core_in,
input         [`CACHE_TYPE_BITS-1:0]  core_type,
// Mem to CPU wrapper
input         [`DATA_BITS-1:0]        I_out,
input                                 I_wait,
// CPU wrapper to core
output  logic [`DATA_BITS-1:0]        core_out,
output  logic                         core_wait,
// CPU wrapper to Mem
output  logic                         I_req,
output  logic [`DATA_BITS-1:0]        I_addr,
output                                I_write,
output        [`DATA_BITS-1:0]        I_in,
output        [`CACHE_TYPE_BITS-1:0]  I_type
);

logic [`CACHE_INDEX_BITS-1:0] index;    //block address to tag/data array
logic [`CACHE_INDEX_BITS-1:0] TA_DA_index;
logic [`CACHE_DATA_BITS-1:0]  DA_out;   //read data from data array
logic [`CACHE_DATA_BITS-1:0]  DA_in;    //write data to data array
logic [`CACHE_WRITE_BITS-1:0] DA_write; //write enable to data array
logic                         DA_read;  //read enable to data array
logic [`CACHE_TAG_BITS-1:0]   TA_out;   //read data from tag array
logic [`CACHE_TAG_BITS-1:0]   TA_in;    //write data to tag array
logic                         TA_write; //write enable to tag array
logic                         TA_read;  //read enable to tag array
logic [`CACHE_LINES-1:0]      valid;    //valid bit of each cache block

logic hit;
logic miss;
logic [95:0] DA_in_reg;
logic [95:0] DA_in_reg_i;
logic [`DATA_BITS-1:0] n_core_out;
logic [1:0] read_mem_count;
logic ReadMem_finish;
logic [1:0] offset;  
logic [`DATA_BITS-1:0] core_addr_reg;
logic [`CACHE_TAG_BITS-1:0] TA_core;
logic first_wait;

//--------------------other signal-----------------------//
assign ReadMem_finish = (read_mem_count==2'd3)&(~I_wait)&I_req;

always_ff @( posedge clk or posedge rst ) begin
  if(rst)
    first_wait <= 1'd0;
  else if(~first_wait & I_wait)
    first_wait <= 1'd1;
  else
    first_wait <= first_wait;
end

always_ff @( posedge clk or posedge rst ) begin
  if(rst)
    core_addr_reg <= 32'd0;
  else
    core_addr_reg <= (core_wait) ? core_addr_reg : core_addr;
end

always_ff @( posedge clk or posedge rst ) begin
  if(rst)
    valid <= 64'd0;
  else
    valid[index] <= (ReadMem_finish) ? 1'b1 : valid[index];
end

always_ff @( posedge clk or posedge rst ) begin
  if(rst)
    read_mem_count <= 2'd0;
  else if(~first_wait)
    read_mem_count <= 2'd0;
  else
    read_mem_count <= (ReadMem_finish) ? 2'd0 : (~I_wait & I_req) ? read_mem_count + 2'd1 : read_mem_count;
end

//--------------------hit/miss-----------------------//
assign hit  = core_req && valid[index] && (TA_out == TA_core);
assign miss = ~hit;
assign core_wait = ~hit;

//--------------------I signal-----------------------//

assign I_req   = (miss) ? core_req : 1'b0;
assign I_addr  = {core_addr_reg[31:4],4'd0};
assign I_write = core_write;
assign I_in    = core_in;
assign I_type  = core_type;

//--------------------DA-----------------------//
assign TA_DA_index  = (core_wait) ? core_addr_reg[9:4] : core_addr[9:4];
assign DA_in_reg_i = (~I_wait) ? {I_out, DA_in_reg[95:32]} : DA_in_reg;
assign DA_in = {I_out, DA_in_reg};
assign DA_read = 1'b1;
assign DA_write = (ReadMem_finish) ? 16'h0000 : 16'hffff;

always_ff @( posedge clk or posedge rst ) begin
  if(rst)
    DA_in_reg <= 96'd0;
  else
    DA_in_reg <= DA_in_reg_i;
end

always_comb begin
  case(offset)
    2'b00 : core_out = DA_out[ 31: 0];
    2'b01 : core_out = DA_out[ 63:32];
    2'b10 : core_out = DA_out[ 95:64];
    2'b11 : core_out = DA_out[127:96];
  endcase
end

data_array_wrapper  DA(
  .A    ( TA_DA_index ),
  .DO   ( DA_out      ),
  .DI   ( DA_in       ),
  .CK   ( clk         ),
  .WEB  ( DA_write    ),
  .OE   ( DA_read     ),
  .CS   ( 1'b1        )
);
   
//--------------------TA-----------------------//
assign TA_core = core_addr_reg[31:10];
assign TA_in  = core_addr_reg[31:10];
assign offset = core_addr_reg[3:2];
assign index  = core_addr_reg[9:4];
assign TA_write = (ReadMem_finish) ? 1'b0 : 1'b1;
assign TA_read = 1'b1;

tag_array_wrapper   TA(
  .A    ( TA_DA_index ),
  .DO   ( TA_out      ),
  .DI   ( TA_in       ),
  .CK   ( clk         ),
  .WEB  ( TA_write    ),
  .OE   ( TA_read     ),
  .CS   ( 1'b1        )
);

endmodule

