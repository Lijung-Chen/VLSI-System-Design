module  CSR_regfile(
    //INPUT
    input                   clk,
    input                   rst,
    input                   CSR_RegWrite,
    input           [11:0]  WB_CSR_addr,
    input           [31:0]  WB_CSR_Data,
    input           [11:0]  Read_CSR_addr,
    input                   interrupt_taken,
    input                   SENSOR_CTRL_interrupt,
    input                   WDT_interrupt,
    input                   MRET,
    input                   WFI_mode,
    //input           [31:0]  inst_PC,
    input           [31:0]  PC,
    //OUTPUT
    output  logic   [31:0]  Read_CSR_Data,
    output  logic           MEIE,
    output  logic           MTIE,
    output  logic   [31:0]  mtvec_PC,
    output  logic   [31:0]  mepc_PC
);

parameter   mstatus   = 12'h300;
parameter   mie       = 12'h304;
parameter   mtvec     = 12'h305;
parameter   mepc      = 12'h341;
parameter   mip       = 12'h344;

logic   [31:0]  register    [0:4];

/*********************************************************************/
/* Register 0:  Machine status register(mstatus)                     */
/* Register 1:  Machine interrupt-enable register(mie)               */
/* Register 2:  Machine Trap-Vector Base-Address register(mtvec)     */
/* Register 3:  Machine exception program counter(mepc)              */
/* Register 4:  Machine interrupt pending register(mip)              */
/*********************************************************************/

assign  MEIE = register[1][11];
assign  MTIE = register[1][7];
assign  mtvec_PC = {register[2][31:2], 2'b00};
assign  mepc_PC = register[3];

//Read
always_comb begin
    case(Read_CSR_addr)
    mstatus:    Read_CSR_Data = register[0];
    mie:        Read_CSR_Data = register[1];
    mtvec:      Read_CSR_Data = register[2];
    mepc:       Read_CSR_Data = register[3];
    mip:        Read_CSR_Data = register[4];
    default:    Read_CSR_Data = 32'd0;
    endcase
end

//Write
always_ff@(posedge clk)  begin
    if(rst) begin
        register[0] <= 32'd0;
        register[1] <= 32'd0;
        register[2] <= 32'h0001_0000;    //mtvec is hardwire to 0x0001_0000: The address where the trap is set.
        register[3] <= 32'd0;
        register[4] <= 32'd0;
    end
    else if(CSR_RegWrite)   begin
        case(WB_CSR_addr)
        mstatus:    register[0] <= {19'd0, WB_CSR_Data[12:11], 3'd0, WB_CSR_Data[7], 3'd0, WB_CSR_Data[3], 3'd0};
        //mie:        register[1] <= {20'd0, WB_CSR_Data[11], 11'd0};
        mie:        register[1] <= {20'd0, WB_CSR_Data[11], 3'd0, WB_CSR_Data[7], 7'd0};
        mepc:       register[3] <= {WB_CSR_Data[31:2],2'd0};
        default:    begin
            register[0] <= register[0];
            register[1] <= register[1];
            register[2] <= register[2];
            register[3] <= register[3];
            register[4] <= register[4];
        end
        endcase
    end
    else if(interrupt_taken)  begin
        //mstatus
        register[0] <= {19'd0, 2'b11, 3'd0, register[0][3], 3'd0, 1'b0, 3'd0};
        //mepc
        //register[3] <= (WFI_mode)? (inst_PC+32'd4) : inst_PC;
        //register[3] <= (WFI_mode)? PC : (PC-32'd4);
        register[3] <= PC;
        //mip
        register[4] <= {20'd0, SENSOR_CTRL_interrupt, 3'd0, WDT_interrupt, 7'd0};
    end
    else if(MRET) begin 
        //mstatus
        register[0] <= {19'd0, 2'b11, 3'd0, 1'b1, 3'd0, register[0][7], 3'd0};
        //mip
        register[4] <= 32'd0;
    end
    else    begin
        register[0] <= register[0];
        register[1] <= register[1];
        register[2] <= register[2];
        register[3] <= register[3];
        //register[4] <= register[4];
        register[4] <= {20'd0, SENSOR_CTRL_interrupt, 3'd0, WDT_interrupt, 7'd0};
    end
end



endmodule