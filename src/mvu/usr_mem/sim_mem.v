module RAMTP1024X16 (
	input	wire 		CLKA,
	input	wire [9:0]	AA,
	output	wire [15:0]	QA,
	input	wire		CENA,

	input	wire		CLKB,
	input	wire [9:0]	AB,
	input	wire [15:0]	DB,
	input	wire		CENB,
	input	wire [15:0]	WENB,

	input	wire [2:0]	EMAA,
	input	wire [2:0]	EMAB,
	input	wire 		COLLDISN,
	input	wire 		RET1N
);


    ram_simple2port #(
        .BDADDR (10),
        .BDWORD (16)        
    ) u_ram (
        .clk		(CLKA),
        .rd_en		(!CENA),
        .rd_addr	(AA),
        .rd_word	(QA),
        .wr_en		(!CENB),
        .wr_addr	(AB),
        .wr_word	(DB)
    );

endmodule

module RAMTP128X16 (
	input	wire 		CLKA,
	input	wire [6:0]	AA,
	output	wire [15:0]	QA,
	input	wire		CENA,

	input	wire		CLKB,
	input	wire [6:0]	AB,
	input	wire [15:0]	DB,
	input	wire		CENB,
	input	wire [15:0]	WENB,

	input	wire [2:0]	EMAA,
	input	wire [2:0]	EMAB,
	input	wire 		COLLDISN,
	input	wire 		RET1N
);


    ram_simple2port #(
        .BDADDR (7),
        .BDWORD (16)        
    ) u_ram (
        .clk		(CLKA),
        .rd_en		(!CENA),
        .rd_addr	(AA),
        .rd_word	(QA),
        .wr_en		(!CENB),
        .wr_addr	(AB),
        .wr_word	(DB)
    );

endmodule