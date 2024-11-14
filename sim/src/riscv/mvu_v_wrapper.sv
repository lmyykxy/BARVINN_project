
module mvu_u_wrapper (
	input	wire				clk,
	input	wire				rst_n,

	input	wire [32-1:0]		paddr,
	input	wire 				psel,
	input	wire 				penable,
	input	wire 				pwrite,
	input	wire [32-1:0]		pwdata,

	output	wire [32-1:0]		prdata,

	input	wire [8-1:0]		wrw_en,
	input	wire [72-1:0]		wrw_addr,
	input	wire [32768-1:0]	wrw_word,

	input	wire [8-1:0]		rdc_en,
	output	wire [8-1:0]		rdc_grnt,
	input	wire [120-1:0]		rdc_addr,
	output	wire [512-1:0]		rdc_word,

	input	wire [8-1:0]		wrc_en,
	output	wire [8-1:0]		wrc_grnt,
	input	wire [15-1:0]		wrc_addr,
	input	wire [64-1:0]		wrc_word,

	input	wire [8-1:0]		wrs_en,
	input	wire [6-1:0]		wrs_addr,
	input	wire [1024-1:0]		wrs_word,

	input	wire [8-1:0]		wrb_en,
	input	wire [6-1:0]		wrb_addr,
	input	wire [1024-1:0]		wrb_word,

	input	wire [8-1:0]		mvu_shacc_clr,
	// mvu interrupt signal
	output	wire [8-1:0]		mvu_irq
);
import mvu_pkg::*;import apb_pkg::*;

APB mvu_apb_if();
MVU_EXT_INTERFACE mvu_ext_if(clk);

mvutop_wrapper mvu_sv(
    mvu_ext_if.mvu_ext,
    mvu_apb_if.Slave
);

wire [2:0]		pprot;
wire [4-1:0]	pstrb;
wire 			pready;
wire 			pslverr;

assign mvu_apb_if.paddr 	= {20'b0,paddr[15:4]};
assign mvu_apb_if.psel 		= psel;
assign mvu_apb_if.penable 	= penable;
assign mvu_apb_if.pwrite 	= pwrite;
assign mvu_apb_if.pwdata 	= pwdata;
assign mvu_apb_if.pprot 	= 3'b0;
assign mvu_apb_if.pstrb 	= 4'b1111;

assign prdata				= mvu_apb_if.prdata;


assign mvu_ext_if.wrw_addr = wrw_addr;
assign mvu_ext_if.wrw_word = wrw_word;
assign mvu_ext_if.wrw_en = wrw_en;

assign mvu_ext_if.rdc_en = rdc_en;
assign rdc_grnt = mvu_ext_if.rdc_grnt;
assign mvu_ext_if.rdc_addr = rdc_addr;
assign rdc_word = mvu_ext_if.rdc_word;

assign mvu_ext_if.wrc_en = wrc_en;
assign wrc_grnt = mvu_ext_if.wrc_grnt;
assign mvu_ext_if.wrc_addr = wrc_addr;
assign mvu_ext_if.wrc_word = wrc_word;

assign mvu_ext_if.wrs_en = wrs_en;
assign mvu_ext_if.wrs_addr = wrs_addr;
assign mvu_ext_if.wrs_word = wrs_word;

assign mvu_ext_if.wrb_en = wrb_en;
assign mvu_ext_if.wrb_addr = wrb_addr;
assign mvu_ext_if.wrb_word = wrb_word;

assign mvu_ext_if.rst_n		= rst_n;
assign mvu_irq = mvu_ext_if.irq;
assign mvu_ext_if.shacc_clr = mvu_shacc_clr;

endmodule