
module mvu_u_wrapper (
	input	wire			clk,
	input	wire			rst_n,

	input	wire [32-1:0]	paddr,
	input	wire 			psel,
	input	wire 			penable,
	input	wire 			pwrite,
	input	wire [32-1:0]	pwdata,

	output	wire [32-1:0]	prdata,

	// mvu interrupt signal
	output	wire [8-1:0]	mvu_irq
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

assign mvu_apb_if.paddr 	= paddr;
assign mvu_apb_if.psel 		= psel;
assign mvu_apb_if.penable 	= penable;
assign mvu_apb_if.pwrite 	= pwrite;
assign mvu_apb_if.pwdata 	= pwdata;
assign mvu_apb_if.pprot 	= 3'b0;
assign mvu_apb_if.pstrb 	= 4'b1111;

assign prdata				= mvu_apb_if.prdata;

assign mvu_ext_if.rst_n		= rst_n;
assign mvu_irq = mvu_ext_if.irq;

endmodule