`include "e203_defines.v"


/* DMA REG table
	|   Address   |      Name        | R/W  | Description |
	| 0x1220_0000 | Source address   |  RW  | DMA source address (from DRAM)               |
	| 0x1220_0004 | Dest   address   |  RW  | DMA dest address   (to DRAM)                 |
	| 0x1220_0008 | DMA info message |  RW  | [15:0] => transfer size (base mvu data len+1)|
	|                                       | [16]   => transfer role (0: data, 1: weight) |
	| 0x1220_000C | DMA start signal |  RW  | [0]    => transfer start(1: START)  		   |
	| 0x1220_0010 | DMA status signal|  R   | [0]    => transfer status(0: IDLE 1: START)  |
 */
module mvu_dma_reg (
	input	wire						clk,
	input	wire						rst_n,

	output	wire [32-1:0]				dma_source_addr_o,
	output	wire [32-1:0]				dma_dest_addr_o,
	output	wire [16-1:0]				dma_transfer_size_o,
	output	wire 						dma_transfer_role_o,
	output	wire 						dma_start_o,
	input	wire [32-1:0]				dma_status_i,

	input	wire						i_icb_cmd_valid,
	output	wire						i_icb_cmd_ready,
	input	wire [`E203_ADDR_SIZE-1:0]	i_icb_cmd_addr, 
	input	wire						i_icb_cmd_read, 
	input	wire [`E203_XLEN-1:0]		i_icb_cmd_wdata,
	input	wire [`E203_XLEN/8-1:0]		i_icb_cmd_wmask,

	output	wire						i_icb_rsp_valid,
	input	wire						i_icb_rsp_ready,
	output	wire						i_icb_rsp_err,
	output	wire [`E203_XLEN-1:0]		i_icb_rsp_rdata

);

/* ------------------------ REG region ------------------------ */
wire [31:0]	source_address_nxt, source_address_r;
wire source_address_en;
sirv_gnrl_dfflr #(32)source_address_dfflr(source_address_en, source_address_nxt, source_address_r, clk, rst_n);

wire [31:0]	dest_address_nxt, dest_address_r;
wire dest_address_en;
sirv_gnrl_dfflr #(32)dest_address_dfflr(dest_address_en, dest_address_nxt, dest_address_r, clk, rst_n);

wire [31:0]	dma_transfer_info_nxt, dma_transfer_info_r;
wire dma_transfer_info_en;
sirv_gnrl_dfflr #(32)dma_transfer_info_dfflr(dma_transfer_info_en, dma_transfer_info_nxt, dma_transfer_info_r, clk, rst_n);

wire [31:0]	dma_transfer_start_nxt, dma_transfer_start_r;
wire dma_transfer_start_en;
sirv_gnrl_dfflr #(32)dma_transfer_start_dfflr(dma_transfer_start_en, dma_transfer_start_nxt, dma_transfer_start_r, clk, rst_n);

wire [31:0]	dma_status_nxt, dma_status_r;
wire dma_status_en;
sirv_gnrl_dfflr #(32)dma_status_dfflr(dma_status_en, dma_status_nxt, dma_status_r, clk, rst_n);

/* ------------------------ ICB miscellaneous ------------------------ */
wire icb_cmd_read_real = i_icb_cmd_valid & i_icb_cmd_read;
wire icb_cmd_write_real = i_icb_cmd_valid & ~i_icb_cmd_read;

assign i_icb_cmd_ready = i_icb_rsp_ready;
assign i_icb_rsp_valid = icb_cmd_read_real | icb_cmd_write_real;

assign i_icb_rsp_err = 1'b0;
/* ------------------------ ICB write logic ------------------------ */
assign source_address_en		= ((icb_cmd_write_real) && (i_icb_cmd_addr == 32'h1220_0000)) ? 1'b1 : 1'b0;
assign dest_address_en			= ((icb_cmd_write_real) && (i_icb_cmd_addr == 32'h1220_0004)) ? 1'b1 : 1'b0;
assign dma_transfer_info_en		= ((icb_cmd_write_real) && (i_icb_cmd_addr == 32'h1220_0008)) ? 1'b1 : 1'b0;
assign dma_transfer_start_en	= 1'b1;
assign dma_status_en			= 1'b1;

assign source_address_nxt		= i_icb_cmd_wdata;
assign dest_address_nxt			= i_icb_cmd_wdata;
assign dma_transfer_info_nxt	= i_icb_cmd_wdata;
assign dma_transfer_start_nxt	= ((icb_cmd_write_real) && (i_icb_cmd_addr == 32'h1220_000C)) ? i_icb_cmd_wdata[0] : 1'b0;
assign dma_status_nxt			= dma_status_i;
/* ------------------------ ICB read logic ------------------------ */
assign i_icb_rsp_rdata = ((icb_cmd_read_real) && (i_icb_cmd_addr == 32'h1220_0000)) ? source_address_r
						:((icb_cmd_read_real) && (i_icb_cmd_addr == 32'h1220_0004)) ? dest_address_r
						:((icb_cmd_read_real) && (i_icb_cmd_addr == 32'h1220_0008)) ? dma_transfer_info_r
						:((icb_cmd_read_real) && (i_icb_cmd_addr == 32'h1220_000C)) ? dma_transfer_start_r
						:((icb_cmd_read_real) && (i_icb_cmd_addr == 32'h1220_0010)) ? dma_status_r
						:32'd0;

/* ------------------------ SIGNAL out ------------------------ */
assign dma_source_addr_o = source_address_r;
assign dma_dest_addr_o = dest_address_r;
assign dma_transfer_size_o = dma_transfer_info_r[15:0];
assign dma_transfer_role_o = dma_transfer_info_r[16];
assign dma_start_o = dma_transfer_start_r[0];

endmodule