`timescale 1ns/1ps
module tp_mem_512X4096 (
	input	wire			clk,

	input	wire			rd_en,
	input	wire [8:0]		rd_addr,
	output	wire [4095:0]	rd_word,

	input	wire			wr_en,
	input	wire [8:0]		wr_addr,
	input	wire [4095:0]	wr_word
);

	wire [15:0] rd_word_segments [255:0];
	wire [15:0] wr_word_segments [255:0];

	genvar i;
	generate
		for (i = 0; i < 256; i = i + 1) begin : split_data
			assign rd_word[16*i +: 16] = rd_word_segments[i];
			assign wr_word_segments[i] = wr_word[16*i +: 16];
		end
	endgenerate

	generate
		for (i = 0; i < 256; i = i + 1) begin : mem_instances
			tp_mem_512X16 umem (
				.clk		(clk),
				.rd_en		(rd_en),
				.rd_addr	(rd_addr),
				.rd_word	(rd_word_segments[i]),
				.wr_en		(wr_en),
				.wr_addr	(wr_addr),
				.wr_word	(wr_word_segments[i])
			);
		end
	endgenerate
endmodule
