`timescale 1ns/1ps
module tp_mem_64X1024 (
	input	wire			clk,

	input	wire			rd_en,
	input	wire [5:0]		rd_addr,
	output	wire [1023:0]	rd_word,
	
	input	wire			wr_en,
	input	wire [5:0]		wr_addr,
	input	wire [1023:0]	wr_word
);

	// Intermediate wires to hold each 16-bit segment of read and write data
	wire [15:0] rd_word_segments [63:0];
	wire [15:0] wr_word_segments [63:0];

	// Split the 1024-bit data into 64 segments of 16 bits each
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : split_data
			assign rd_word[16*i +: 16] = rd_word_segments[i];
			assign wr_word_segments[i] = wr_word[16*i +: 16];
		end
	endgenerate

	// Instantiate 64 RAMTP128X16 modules for each 16-bit segment
	generate
		for (i = 0; i < 64; i = i + 1) begin : ram_instances
			RAMTP128X16 umem (
				.CLKA		(clk),
				.AA			({1'b0,rd_addr}),		// Read Address [6:0]
				.QA			(rd_word_segments[i]),	// Data Output [15:0]
				.CENA		(!rd_en),				// Read Enable (Active Low)
				.CLKB		(clk),
				.AB			({1'b0,wr_addr}),		// Write Address [6:0]
				.DB			(wr_word_segments[i]),	// Data Input [15:0]
				.CENB		(!wr_en),				// Write Enable (Active Low)
				.WENB		(16'b0),				// Write Enable [15:0] (Active Low)
				.EMAA		(3'b0),					// Read Extra Margin Adjustment
				.EMAB		(3'b0),					// Write Extra Margin Adjustment
				.COLLDISN	(1'b1),					// Disable internal collision detect (Active Low)
				.RET1N		(1'b1)					// Retention Input (Active Low)
			);
		end
	endgenerate

endmodule
