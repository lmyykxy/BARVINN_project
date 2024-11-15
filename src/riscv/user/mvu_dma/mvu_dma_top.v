`include "e203_defines.v"

module mvu_dma_top (
	input	wire						clk,
	input	wire						rst_n,

	output	wire [32-1:0]				source_address,
	input	wire [32-1:0]				source_data,
	output	wire						source_valid,
	input	wire						source_ready,

	output	wire [15-1:0]				dest_data_address,
	output	wire [64-1:0]				dest_data_data,
	output	wire						dest_data_valid,
	input	wire						dest_data_ready,

	output	wire [9-1:0]				dest_weight_address,
	output	wire [4096-1:0]				dest_weight_data,
	output	wire						dest_weight_valid,
	input	wire						dest_weight_ready,

	input	wire						i_icb_cmd_valid,
	output	wire						i_icb_cmd_ready,
	input	wire [`E203_ADDR_SIZE-1:0]	i_icb_cmd_addr, 
	input	wire						i_icb_cmd_read, 
	input	wire [`E203_XLEN-1:0]		i_icb_cmd_wdata,
	input	wire [`E203_XLEN/8-1:0]		i_icb_cmd_wmask,

	output	wire						i_icb_rsp_valid,
	input	wire						i_icb_rsp_ready,
	output	wire						i_icb_rsp_err,
	output	wire [`E203_XLEN-1:0]		i_icb_rsp_rdata,

	output	wire						dma_irq
);
	
wire [32-1:0]		dma_source_addr;
wire [32-1:0]		dma_dest_addr;
wire [16-1:0]		dma_transfer_size;
wire [32-1:0]		dma_status;
wire				dma_start;
wire				dma_transfer_role;


mvu_dma_core u_mvu_dma_core(
	.clk									(clk),
	.rst_n									(rst_n),

	.source_address							(source_address),
	.source_data							(source_data),
	.source_valid							(source_valid),
	.source_ready							(source_ready),

	.dest_data_address						(dest_data_address),
	.dest_data_data							(dest_data_data),
	.dest_data_valid						(dest_data_valid),
	.dest_data_ready						(dest_data_ready),

	.dest_weight_address					(dest_weight_address),
	.dest_weight_data						(dest_weight_data),
	.dest_weight_valid						(dest_weight_valid),
	.dest_weight_ready						(dest_weight_ready),

	.dma_source_addr_i						(dma_source_addr),
	.dma_dest_addr_i						(dma_dest_addr),
	.dma_transfer_size_i					(dma_transfer_size),
	.dma_transfer_role_i					(dma_transfer_role),
	.dma_transfer_start_i					(dma_start),
	.dma_status_o							(dma_status),
	.dma_irq								(dma_irq)

);



mvu_dma_reg u_mvu_dma_reg(
	.clk									(clk					),
	.rst_n									(rst_n					),

	.dma_source_addr_o						(dma_source_addr		),
	.dma_dest_addr_o						(dma_dest_addr			),
	.dma_transfer_size_o					(dma_transfer_size		),
	.dma_transfer_role_o					(dma_transfer_role		),
	.dma_start_o							(dma_start				),
	.dma_status_i							(dma_status				),

	.i_icb_cmd_valid						(i_icb_cmd_valid		),
	.i_icb_cmd_ready						(i_icb_cmd_ready		),
	.i_icb_cmd_addr							(i_icb_cmd_addr			), 
	.i_icb_cmd_read							(i_icb_cmd_read			), 
	.i_icb_cmd_wdata						(i_icb_cmd_wdata		),
	.i_icb_cmd_wmask						(i_icb_cmd_wmask		),

	.i_icb_rsp_valid						(i_icb_rsp_valid		),
	.i_icb_rsp_ready						(i_icb_rsp_ready		),
	.i_icb_rsp_err							(i_icb_rsp_err			),
	.i_icb_rsp_rdata						(i_icb_rsp_rdata		)

);

endmodule