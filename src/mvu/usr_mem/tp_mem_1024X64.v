`timescale 1ns/1ps
module tp_mem_1024X64 (
	input	wire			clk,

	input	wire			rd_en,
	input	wire [9:0]		rd_addr,
	output	wire [63:0]		rd_word,

	input	wire			wr_en,
	input	wire [9:0]		wr_addr,
	input	wire [63:0]		wr_word
);


wire [15:0] wr_worda = wr_word[15: 0];
wire [15:0] wr_wordb = wr_word[31:16];
wire [15:0] wr_wordc = wr_word[47:32];
wire [15:0] wr_wordd = wr_word[63:48];

wire [15:0] rd_worda,rd_wordb,rd_wordc,rd_wordd;
assign rd_word = {wr_wordd,wr_wordc,wr_wordb,wr_worda};


RAMTP1024X16 ua(
	.CLKA		(clk),
	.AA			(rd_addr),		// Read Address [9:0]
	.QA			(rd_worda),		// Data Outputs	 [15:0]
	.CENA		(!rd_en),		// Read Enables (Active Low)

	.CLKB		(clk),
	.AB			(wr_addr),		// Write Address [9:0]
	.DB			(wr_worda),		// DATA input	[15:0]
	.CENB		(!wr_en),		// Write Enables (Active Low)
	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
	.RET1N		(1'b1)			// Retention Input (Active Low)
);
RAMTP1024X16 ub(
	.CLKA		(clk),
	.AA			(rd_addr),		// Read Address [9:0]
	.QA			(rd_wordb),		// Data Outputs	 [15:0]
	.CENA		(!rd_en),		// Read Enables (Active Low)

	.CLKB		(clk),
	.AB			(wr_addr),		// Write Address [9:0]
	.DB			(wr_wordb),		// DATA input	[15:0]
	.CENB		(!wr_en),		// Write Enables (Active Low)
	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
	.RET1N		(1'b1)			// Retention Input (Active Low)
);
RAMTP1024X16 uc(
	.CLKA		(clk),
	.AA			(rd_addr),		// Read Address [9:0]
	.QA			(rd_wordc),		// Data Outputs	 [15:0]
	.CENA		(!rd_en),		// Read Enables (Active Low)

	.CLKB		(clk),
	.AB			(wr_addr),		// Write Address [9:0]
	.DB			(wr_wordc),		// DATA input	[15:0]
	.CENB		(!wr_en),		// Write Enables (Active Low)
	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
	.RET1N		(1'b1)			// Retention Input (Active Low)
);
RAMTP1024X16 ud(
	.CLKA		(clk),
	.AA			(rd_addr),		// Read Address [9:0]
	.QA			(rd_wordd),		// Data Outputs	 [15:0]
	.CENA		(!rd_en),		// Read Enables (Active Low)

	.CLKB		(clk),
	.AB			(wr_addr),		// Write Address [9:0]
	.DB			(wr_wordd),		// DATA input	[15:0]
	.CENB		(!wr_en),		// Write Enables (Active Low)
	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
	.RET1N		(1'b1)			// Retention Input (Active Low)
);



// RAMTP1024X16(
// 	.CLKA		(clk),
// 	.AA			(),				// Read Address [9:0]
// 	.QA			(),				// Data Outputs	 [15:0]
// 	.CENA		(),				// Read Enables (Active Low)

// 	.CLKB		(clk),
// 	.AB			(),				// Write Address [9:0]
// 	.DB			(),				// DATA input	[15:0]
// 	.CENB		(),				// Write Enables (Active Low)
// 	.WENB		({16{1'd0}}),	// Write Enable [15:0] (Active Low)

// 	.EMAA		({3{1'd0}}),	// Read Extra Margin Adjustment [2:0]
// 	.EMAB		({3{1'd0}}),	// Write Extra Margin Adjustment [2:0]
// 	.COLLDISN	(1'b1),			// Disable internal collision detect (Active Low)
// 	.RET1N		(1'b1),			// Retention Input (Active Low)
// )
	
endmodule