`include "e203_defines.v"

module mvu_dma_core (
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

	input	wire [32-1:0]				dma_source_addr_i,
	input	wire [32-1:0]				dma_dest_addr_i,
	input	wire [16-1:0]				dma_transfer_size_i,
	input	wire						dma_transfer_role_i,
	input	wire						dma_transfer_start_i,
	output	wire [32-1:0]				dma_status_o,

	output	wire						dma_irq

);
localparam MVU_IDLE 			= 3'b000;
localparam MVU_TRANSFER_READ 	= 3'b010;
localparam MVU_TRANSFER_WRITE 	= 3'b100;

wire [2:0]	dma_fsm_nxt, dma_fsm_r;
sirv_gnrl_dfflr #(3)dma_fsm_dfflr(1'b1, dma_fsm_nxt, dma_fsm_r, clk, rst_n);

wire read_enough, write_enough, write_one_cycle;
assign dma_fsm_nxt = (dma_fsm_r == MVU_IDLE && dma_transfer_start_i == 1'b1) ? MVU_TRANSFER_READ
					:(dma_fsm_r == MVU_TRANSFER_READ && read_enough) ? MVU_TRANSFER_WRITE
					:(dma_fsm_r == MVU_TRANSFER_WRITE && write_enough)? MVU_IDLE
					:(dma_fsm_r == MVU_TRANSFER_WRITE && write_one_cycle)? MVU_TRANSFER_READ
					: dma_fsm_r;

/* ------------------------ DMA READ ------------------------ */
wire [8:0]	read_source_cnt_nxt, read_source_cnt_r;
sirv_gnrl_dfflr #(9)read_source_cnt_dfflr(1'b1, read_source_cnt_nxt, read_source_cnt_r, clk, rst_n);
assign read_source_cnt_nxt = (dma_fsm_r == MVU_TRANSFER_READ && source_valid && source_ready) ? read_source_cnt_r + 1'b1
							:(dma_fsm_r == MVU_TRANSFER_READ) ? read_source_cnt_r
							: 9'd0;
assign read_enough = (dma_fsm_r == MVU_TRANSFER_READ && dma_transfer_role_i == 1'b1 && read_source_cnt_r == 9'd127) ? 1'b1
					:(dma_fsm_r == MVU_TRANSFER_READ && dma_transfer_role_i == 1'b0 && read_source_cnt_r == 9'd1) ? 1'b1
					:1'b0;

assign source_valid = (dma_fsm_r == MVU_TRANSFER_READ) ? 1'd1 : 1'd0;

wire [8:0]	read_source_p_nxt, read_source_p_r;
sirv_gnrl_dfflr #(9)read_source_p_dfflr(1'b1, read_source_p_nxt, read_source_p_r, clk, rst_n);
assign read_source_p_nxt = (dma_fsm_r == MVU_TRANSFER_READ && source_valid && source_ready) ? read_source_p_r + 32'b1
						  :(dma_fsm_r == MVU_TRANSFER_READ || dma_fsm_r == MVU_TRANSFER_WRITE) ? read_source_p_r
						  :(dma_fsm_r == MVU_IDLE) ? dma_source_addr_i
						  : 32'b0;

assign source_address = read_source_p_r;

wire [4096-1:0]	data_nxt, data_r;
sirv_gnrl_dfflr #(4096)data_dfflr(1'b1, data_nxt, data_r, clk, rst_n);
assign data_nxt = (dma_fsm_r == MVU_TRANSFER_READ && source_valid && source_ready) ? {data_r[4095-32:0],source_data}
				 :(dma_fsm_r == MVU_TRANSFER_READ) ? data_r
				 :4096'd0;

/* ------------------------ DMA WRITE ------------------------ */
wire [16-1:0]	write_source_cnt_nxt, write_source_cnt_r;
sirv_gnrl_dfflr #(16)write_source_cnt_dfflr(1'b1, write_source_cnt_nxt, write_source_cnt_r, clk, rst_n);
assign write_source_cnt_nxt = (dma_fsm_r == MVU_TRANSFER_WRITE && ((dest_data_valid && dest_data_ready) || (dest_weight_valid && dest_weight_ready))) ? write_source_cnt_r + 1'b1
							:(dma_fsm_r == MVU_TRANSFER_READ || dma_fsm_r == MVU_TRANSFER_WRITE) ? write_source_cnt_r
							: 9'd0;
assign write_enough = (dma_fsm_r == MVU_TRANSFER_WRITE && write_source_cnt_r == dma_transfer_size_i) ? 1'b1 : 1'b0;
assign write_one_cycle = (dma_fsm_r == MVU_TRANSFER_WRITE &&((dest_data_valid && dest_data_ready) || (dest_weight_valid && dest_weight_ready))) ? 1'b1 : 1'b0;

assign dest_data_valid = (dma_fsm_r == MVU_TRANSFER_WRITE && dma_transfer_role_i == 1'b0) ? 1'd1 : 1'd0;
assign dest_weight_valid = (dma_fsm_r == MVU_TRANSFER_WRITE && dma_transfer_role_i == 1'b1) ? 1'd1 : 1'd0;

wire [8:0]	write_dest_p_nxt, write_dest_p_r;
sirv_gnrl_dfflr #(9)write_dest_p_dfflr(1'b1, write_dest_p_nxt, write_dest_p_r, clk, rst_n);
assign write_dest_p_nxt = (dma_fsm_r == MVU_TRANSFER_WRITE && ((dest_data_valid && dest_data_ready) || (dest_weight_valid && dest_weight_ready))) ? write_dest_p_r + 32'b1
						  :(dma_fsm_r == MVU_TRANSFER_READ || dma_fsm_r == MVU_TRANSFER_WRITE) ? write_dest_p_r
						  :(dma_fsm_r == MVU_IDLE) ? dma_dest_addr_i
						  : 32'b0;
assign dest_data_address = write_dest_p_r;
assign dest_weight_address = write_dest_p_r;

assign dest_data_data = data_r[63:0];
assign dest_weight_data = data_r;

/* ------------------------ millc ------------------------ */
assign dma_status_o = (dma_fsm_r == MVU_IDLE) ? 1'b0 : 1'b1;


e203_int_gen u_dma_int_gen(
	.sys_clk			(clk),
	.sys_rst_n			(rst_n),
	
	.pulse_start		(write_enough),
	.int_pulse			(dma_irq)
);
endmodule