//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_data.sv
// Description: L1 Cache for data
// Version:     0.1
//================================================
`include "../include/def.svh"
`include "tag_array_wrapper.sv"
`include "data_array_wrapper.sv"

module L1C_data(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,   //for read
  input core_write, //for write
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] D_out,
  input D_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // CPU wrapper to Mem
  output logic D_req,
  output logic [`DATA_BITS-1:0] D_addr,
  output D_write,
  output [`DATA_BITS-1:0] D_in,
  output [`CACHE_TYPE_BITS-1:0] D_type
);

  logic [`CACHE_INDEX_BITS-1:0] index;    //block address to tag/data array
  logic [`CACHE_DATA_BITS-1:0]  DA_out;   //read data from data array
  logic [`CACHE_DATA_BITS-1:0]  DA_in;    //write data to data array
  logic [`CACHE_WRITE_BITS-1:0] DA_write; //write enable to data array
  logic                         DA_read;  //read enable to data array
  logic [`CACHE_TAG_BITS-1:0]   TA_out;   //read data from tag array
  logic [`CACHE_TAG_BITS-1:0]   TA_in;    //write data to tag array
  logic                         TA_write; //write enable to tag array
  logic                         TA_read;  //read enable to tag array
  logic [`CACHE_LINES-1:0]      valid;    //valid bit of each cache block

  logic cacheable;
  logic miss_read;
  logic hit_write;
  logic [`DATA_BITS-1:0]  core_addr_reg;
  logic [1:0] offset;
  logic [1:0] read_mem_count;
  logic [2:0] access_mem_state, n_access_mem_state;
  logic ReadMem_finish;
  logic [3:0] WSTRB;
  logic [1:0] write_bias;
  logic [`CACHE_TAG_BITS-1:0] TA_core;


  assign  TA_core = core_addr_reg[31:10];

  assign cacheable = (core_addr[31:16] != 16'h1000); 
 
  //assign  miss_read = core_req && (~valid[index] || TA_out != TA_core) && cacheable;

  always_comb
  if(core_req && cacheable)
    if(valid[index])  miss_read = (access_mem_state == 3'd0)? 1'b1 : (TA_out != TA_core);
    else  miss_read = 1'b1;
  else  miss_read = 1'b0;

  //assign  hit_write = core_write && valid[index] && (TA_out == TA_core) && cacheable;
  assign  hit_write = (access_mem_state == 2'd0)? 1'b0 : (core_write && valid[index] && (TA_out == TA_core) && cacheable);
  
  
  always_ff@(posedge clk)
  if(rst) core_addr_reg <= 32'd0;
  else    core_addr_reg <= (D_wait & ~core_write)? core_addr_reg : core_addr;
  
  //========================== CPU wrapper to Core ===============================
  assign  offset = core_addr_reg[3:2];

  always_comb
  if(access_mem_state == 2'd3)
    core_out = D_out;
  else
    case(offset)
      2'd0: core_out = DA_out[31:0];
      2'd1: core_out = DA_out[63:32];
      2'd2: core_out = DA_out[95:64];
      2'd3: core_out = DA_out[127:96];
    endcase
    

  //assign  core_wait = miss_read | D_wait; 
  assign  core_wait = miss_read | D_wait | (~cacheable & core_req & access_mem_state == 3'd0); 



  //========================== CPU wrapper to Mem ===============================
  always_ff@(posedge clk)
  if(rst) read_mem_count <= 2'd0;
  else if(~D_req) read_mem_count <=2'd0;
  else  read_mem_count <= (D_req & ~D_wait)? (read_mem_count + 2'd1) : read_mem_count;
  
  //assign  ReadMem_finish = (read_mem_count == 2'd3 & D_req & ~D_wait);

  always_ff@(posedge clk)
  if(rst) ReadMem_finish <= 1'b0;
  else if(read_mem_count == 2'd3 & D_req & ~D_wait) ReadMem_finish <= 1'b1;
  else  ReadMem_finish <= 1'b0;

  always_ff@(posedge clk)
  if(rst) access_mem_state <= 3'd0;
  else    access_mem_state <= n_access_mem_state;

  always_comb
  case(access_mem_state)
    3'd0: begin
      if(~cacheable & core_req) n_access_mem_state = 3'd3;
      else if(core_req)  n_access_mem_state = 3'd4;
      else if(core_write) n_access_mem_state = 3'd2;
      else  n_access_mem_state = 3'd0;
    end
    3'd1: begin   //read data from mem when read miss
      if(ReadMem_finish)  n_access_mem_state = 3'd0;
      //if(read_mem_count == 2'd3 & D_req & ~D_wait)  n_access_mem_state = 2'd0;
      else n_access_mem_state = 3'd1;
    end
    3'd2:  begin  //write data to mem
      if(~D_wait) n_access_mem_state = 3'd0;
      else  n_access_mem_state = 3'd2;
    end
    3'd3: begin   //read data from mem directly when uncacheable
      if(~D_wait) n_access_mem_state = 3'd0;
      else  n_access_mem_state = 3'd3;
    end
    default:  begin //TA_out is ready
      if(miss_read)  n_access_mem_state = 3'd1;
      else  n_access_mem_state = 3'd0;
    end
  endcase

  assign  D_req = (access_mem_state == 3'd1 & ~ReadMem_finish) || (access_mem_state == 3'd3);

  //assign  D_addr = (core_write | ~cacheable)? core_addr : {core_addr[31:4],4'd0};   //**
  assign  D_addr = (core_write | (~cacheable & core_req))? core_addr_reg : {core_addr_reg[31:4],4'd0};

  assign  D_write = (access_mem_state == 3'd2 & core_write);
  //assign  D_write = core_write;
  
  assign  D_in = core_in;

  assign  D_type = core_type;

  //========================== Signal to Cache ===============================
  assign  index = (D_wait & ~core_write)? core_addr_reg[9:4] : core_addr[9:4];


  always_ff@(posedge clk)
  if(rst) 
    DA_in <= 128'd0;
  else if(hit_write) 
    case(offset)
      2'd0: DA_in <= {DA_out[127:32],core_in};
      2'd1: DA_in <= {DA_out[127:64],core_in,DA_out[31:0]};
      2'd2: DA_in <= {DA_out[127:96],core_in,DA_out[63:0]};
      2'd3: DA_in <= {core_in,DA_out[95:0]};
    endcase
  else    
    DA_in <= (~D_wait)? {D_out,DA_in[127:32]} : DA_in;

  assign  write_bias = core_addr[1:0];
  always_comb
  case(core_type)
    `CACHE_WORD:  WSTRB = 4'b0000;
    `CACHE_HWORD: 
      case(write_bias)
        2'd0: WSTRB = 4'b1100;
        2'd1: WSTRB = 4'b1111;
        2'd2: WSTRB = 4'b0011;
        2'd3: WSTRB = 4'b1111;
      endcase
    `CACHE_BYTE:  
      case(write_bias)
        2'd0: WSTRB = 4'b1110;
        2'd1: WSTRB = 4'b1101;
        2'd2: WSTRB = 4'b1011;
        2'd3: WSTRB = 4'b0111;
      endcase
    default:  WSTRB = 4'b1111;
  endcase

  always_ff@(posedge clk)
  if(rst)
    DA_write <= 16'hffff;
  else if(hit_write & D_wait)
    case(offset)
      2'd0: DA_write <= {12'hfff,WSTRB};
      2'd1: DA_write <= {8'hff,WSTRB,4'hf};
      2'd2: DA_write <= {4'hf,WSTRB,8'hff};
      2'd3: DA_write <= {WSTRB,12'hfff};
    endcase
  else if(miss_read)
    //DA_write <= (ReadMem_finish)? 16'h0000 : 16'hffff;
    DA_write <= (read_mem_count == 2'd3 & D_req & ~D_wait)? 16'h0000 : 16'hffff;
  else
    DA_write <= 16'hffff;
  
  assign  DA_read = 1'b1;

  assign  TA_in = core_addr[31:10];

  always_ff@(posedge clk)
  if(rst) TA_write <= 1'b1;
  //else if(ReadMem_finish & miss_read) TA_write <= 1'b0;
  else if(read_mem_count == 2'd3 & D_req & ~D_wait & miss_read) TA_write <= 1'b0;
  else  TA_write <= 1'b1;

  assign  TA_read = 1'b1;

  always_ff@(posedge clk)
  if(rst) valid <= 16'd0;
  else    valid[index] <= (ReadMem_finish & miss_read)? 1'b1 : valid[index];



  
  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),
    .OE(DA_read),
    .CS(1'b1)
  );
   
  tag_array_wrapper  TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in),
    .CK(clk),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );

endmodule

