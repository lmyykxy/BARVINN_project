`timescale 1ns/1ps
module tp_mem_64X2048 (
	input	wire			clk,

	input	wire			rd_en,
	input	wire [5:0]		rd_addr,
	output	wire [2047:0]	rd_word,

	input	wire			wr_en,
	input	wire [5:0]		wr_addr,
	input	wire [2047:0]	wr_word
);

wire [1023:0] wr_worda = wr_word[1023:   0];
wire [1023:0] wr_wordb = wr_word[2047:1024];

wire [1023:0] rd_worda,rd_wordb;
assign rd_word = {wr_wordb,wr_worda};


tp_mem_64X1024 ua(
	.clk					(clk),

	.rd_en					(rd_en),
	.rd_addr				(rd_addr),
	.rd_word				(rd_worda),

	.wr_en					(wr_en),
	.wr_addr				(wr_addr),
	.wr_word				(wr_worda)
);

tp_mem_64X1024 ub(
	.clk					(clk),

	.rd_en					(rd_en),
	.rd_addr				(rd_addr),
	.rd_word				(rd_wordb),

	.wr_en					(wr_en),
	.wr_addr				(wr_addr),
	.wr_word				(wr_wordb)
);

endmodule
