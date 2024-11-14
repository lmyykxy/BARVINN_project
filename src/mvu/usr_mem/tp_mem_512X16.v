`timescale 1ns/1ps
module tp_mem_512X16 (
	input	wire			clk,

	input	wire			rd_en,
	input	wire [8:0]		rd_addr,
	output	wire [15:0]		rd_word,

	input	wire			wr_en,
	input	wire [8:0]		wr_addr,
	input	wire [15:0]		wr_word
);

wire wr_ena = (wr_en && wr_addr[8:7] == 2'b00) ? 1'b1 : 1'b0;
wire wr_enb = (wr_en && wr_addr[8:7] == 2'b01) ? 1'b1 : 1'b0;
wire wr_enc = (wr_en && wr_addr[8:7] == 2'b10) ? 1'b1 : 1'b0;
wire wr_end = (wr_en && wr_addr[8:7] == 2'b11) ? 1'b1 : 1'b0;

wire rd_ena = (rd_en && rd_addr[8:7] == 2'b00) ? 1'b1 : 1'b0;
wire rd_enb = (rd_en && rd_addr[8:7] == 2'b01) ? 1'b1 : 1'b0;
wire rd_enc = (rd_en && rd_addr[8:7] == 2'b10) ? 1'b1 : 1'b0;
wire rd_end = (rd_en && rd_addr[8:7] == 2'b11) ? 1'b1 : 1'b0;

wire [6:0] rdin_addr = rd_addr[6:0];
wire [6:0] wrin_addr = wr_addr[6:0];

RAMTP128X16 ua(
	.CLKA		(clk),
	.AA			(rdin_addr),		// Read Address [6:0]
	.QA			(rd_word),		// Data Outputs	 [15:0]
	.CENA		(!rd_ena),		// Read Enables (Active Low)

	.CLKB		(clk),
	.AB			(wrin_addr),		// Write Address [6:0]
	.DB			(wr_word),		// DATA input	[15:0]
	.CENB		(!wr_ena),		// Write Enables (Active Low)
	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
	.RET1N		(1'b1)			// Retention Input (Active Low)
);
RAMTP128X16 ub(
	.CLKA		(clk),
	.AA			(rdin_addr),		// Read Address [6:0]
	.QA			(rd_word),		// Data Outputs	 [15:0]
	.CENA		(!rd_enb),		// Read Enables (Active Low)

	.CLKB		(clk),
	.AB			(wrin_addr),		// Write Address [6:0]
	.DB			(wr_word),		// DATA input	[15:0]
	.CENB		(!wr_enb),		// Write Enables (Active Low)
	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
	.RET1N		(1'b1)			// Retention Input (Active Low)
);
RAMTP128X16 uc(
	.CLKA		(clk),
	.AA			(rdin_addr),		// Read Address [6:0]
	.QA			(rd_word),		// Data Outputs	 [15:0]
	.CENA		(!rd_enc),		// Read Enables (Active Low)

	.CLKB		(clk),
	.AB			(wrin_addr),		// Write Address [6:0]
	.DB			(wr_word),		// DATA input	[15:0]
	.CENB		(!wr_enc),		// Write Enables (Active Low)
	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
	.RET1N		(1'b1)			// Retention Input (Active Low)
);
RAMTP128X16 ud(
	.CLKA		(clk),
	.AA			(rdin_addr),		// Read Address [6:0]
	.QA			(rd_word),		// Data Outputs	 [15:0]
	.CENA		(!rd_end),		// Read Enables (Active Low)

	.CLKB		(clk),
	.AB			(wrin_addr),		// Write Address [6:0]
	.DB			(wr_word),		// DATA input	[15:0]
	.CENB		(!wr_end),		// Write Enables (Active Low)
	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
	.RET1N		(1'b1)			// Retention Input (Active Low)
);

	
endmodule