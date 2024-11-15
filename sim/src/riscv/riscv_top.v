`include "e203_defines.v"

module riscv_top();



initial begin
	$fsdbDumpfile("riscv_top.fsdb");
	$fsdbDumpvars(0, riscv_top, "+mda");
end
  reg  clk;
  reg  lfextclk;
  reg  rst_n;

  wire hfclk = clk;

  //////////////////////////////////////////////////////////////
  // mvu interface
  wire [32-1:0] mvu_apb_paddr;
  wire          mvu_apb_pwrite;
  wire          mvu_apb_pselx;
  wire          mvu_apb_penable;
  wire [32-1:0] mvu_apb_pwdata;
  wire [32-1:0] mvu_apb_prdata;

  wire 	[8-1:0]	mvu_irq;
  reg 	[8-1:0]	mvu_shacc_clr;

  reg 	[8-1:0]			wrw_en;
  reg 	[72-1:0]		wrw_addr;
  reg 	[32768-1:0]		wrw_word;

  reg 	[8-1:0]			rdc_en;
  wire 	[8-1:0]			rdc_grnt;
  reg 	[120-1:0]		rdc_addr;
  wire 	[512-1:0]		rdc_word;
  
  reg 	[8-1:0]			wrc_en;
  wire 	[8-1:0]			wrc_grnt;
  reg 	[15-1:0]		wrc_addr;
  reg 	[64-1:0]		wrc_word;

  reg 	[8-1:0]			wrs_en;
  reg 	[6-1:0]			wrs_addr;
  reg 	[1024-1:0]		wrs_word;
  
  reg 	[8-1:0]			wrb_en;
  reg 	[6-1:0]			wrb_addr;
  reg 	[1024-1:0]		wrb_word;

  //////////////////////////////////////////////////////////////
  wire                         dma_icb_cmd_valid;
  wire                         dma_icb_cmd_ready;
  wire  [`E203_ADDR_SIZE-1:0]  dma_icb_cmd_addr; 
  wire                         dma_icb_cmd_read; 
  wire  [`E203_XLEN-1:0]       dma_icb_cmd_wdata;
  wire  [`E203_XLEN/8-1:0]     dma_icb_cmd_wmask;

  wire                         dma_icb_rsp_valid;
  wire                         dma_icb_rsp_ready;
  wire                         dma_icb_rsp_err;
  wire[`E203_XLEN-1:0]         dma_icb_rsp_rdata;

  wire						   dma_irq;

  wire [31:0]					rom_sim_addr;
  wire [31:0]					rom_sim_data;
  wire							rom_sim_valid;
  wire							rom_sim_ready;
  //////////////////////////////////////////////////////////////

  `define CPU_TOP u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.u_e203_cpu_top
  `define EXU `CPU_TOP.u_e203_cpu.u_e203_core.u_e203_exu
  `define ITCM `CPU_TOP.u_e203_srams.u_e203_itcm_ram.u_e203_itcm_gnrl_ram.u_sirv_sim_ram

  `define PC_WRITE_TOHOST       `E203_PC_SIZE'h80000086
  `define PC_EXT_IRQ_BEFOR_MRET `E203_PC_SIZE'h800000a6
  `define PC_SFT_IRQ_BEFOR_MRET `E203_PC_SIZE'h800000be
  `define PC_TMR_IRQ_BEFOR_MRET `E203_PC_SIZE'h800000d6
  `define PC_AFTER_SETMTVEC     `E203_PC_SIZE'h8000015C

  wire [`E203_XLEN-1:0] x3 = `EXU.u_e203_exu_regfile.rf_r[3];
  wire [`E203_PC_SIZE-1:0] pc = `EXU.u_e203_exu_commit.alu_cmt_i_pc;
  wire [`E203_PC_SIZE-1:0] pc_vld = `EXU.u_e203_exu_commit.alu_cmt_i_valid;

  reg [31:0] pc_write_to_host_cnt;
  reg [31:0] pc_write_to_host_cycle;
  reg [31:0] valid_ir_cycle;
  reg [31:0] cycle_count;
  reg pc_write_to_host_flag;

  always @(posedge hfclk or negedge rst_n)
  begin 
    if(rst_n == 1'b0) begin
        pc_write_to_host_cnt <= 32'b0;
        pc_write_to_host_flag <= 1'b0;
        pc_write_to_host_cycle <= 32'b0;
    end
    else if (pc_vld & (pc == `PC_WRITE_TOHOST)) begin
        pc_write_to_host_cnt <= pc_write_to_host_cnt + 1'b1;
        pc_write_to_host_flag <= 1'b1;
        if (pc_write_to_host_flag == 1'b0) begin
            pc_write_to_host_cycle <= cycle_count;
        end
    end
  end

  always @(posedge hfclk or negedge rst_n)
  begin 
    if(rst_n == 1'b0) begin
        cycle_count <= 32'b0;
    end
    else begin
        cycle_count <= cycle_count + 1'b1;
    end
  end

  wire i_valid = `EXU.i_valid;
  wire i_ready = `EXU.i_ready;

  always @(posedge hfclk or negedge rst_n)
  begin 
    if(rst_n == 1'b0) begin
        valid_ir_cycle <= 32'b0;
    end
    else if(i_valid & i_ready & (pc_write_to_host_flag == 1'b0)) begin
        valid_ir_cycle <= valid_ir_cycle + 1'b1;
    end
  end


  // Randomly force the external interrupt
  `define EXT_IRQ u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.plic_ext_irq
  `define SFT_IRQ u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.clint_sft_irq
  `define TMR_IRQ u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.clint_tmr_irq

  `define U_CPU u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.u_e203_cpu_top.u_e203_cpu
  `define ITCM_BUS_ERR `U_CPU.u_e203_itcm_ctrl.sram_icb_rsp_err
  `define ITCM_BUS_READ `U_CPU.u_e203_itcm_ctrl.sram_icb_rsp_read
  `define STATUS_MIE   `U_CPU.u_e203_core.u_e203_exu.u_e203_exu_commit.u_e203_exu_excp.status_mie_r

  wire stop_assert_irq = (pc_write_to_host_cnt > 32);

  reg tb_itcm_bus_err;

  reg tb_ext_irq;
  reg tb_tmr_irq;
  reg tb_sft_irq;
  initial begin
    tb_ext_irq = 1'b0;
    tb_tmr_irq = 1'b0;
    tb_sft_irq = 1'b0;
  end

`ifdef ENABLE_TB_FORCE
  initial begin
    tb_itcm_bus_err = 1'b0;
    #100
    @(pc == `PC_AFTER_SETMTVEC ) // Wait the program goes out the reset_vector program
    forever begin
      repeat ($urandom_range(1, 20)) @(posedge clk) tb_itcm_bus_err = 1'b0; // Wait random times
      repeat ($urandom_range(1, 200)) @(posedge clk) tb_itcm_bus_err = 1'b1; // Wait random times
      if(stop_assert_irq) begin
          break;
      end
    end
  end


  initial begin
    force `EXT_IRQ = tb_ext_irq;
    force `SFT_IRQ = tb_sft_irq;
    force `TMR_IRQ = tb_tmr_irq;
       // We force the bus-error only when:
       //   It is in common code, not in exception code, by checking MIE bit
       //   It is in read operation, not write, otherwise the test cannot recover
    force `ITCM_BUS_ERR = tb_itcm_bus_err
                        & `STATUS_MIE 
                        & `ITCM_BUS_READ
                        ;
  end


  initial begin
    #100
    @(pc == `PC_AFTER_SETMTVEC ) // Wait the program goes out the reset_vector program
    forever begin
      repeat ($urandom_range(1, 1000)) @(posedge clk) tb_ext_irq = 1'b0; // Wait random times
      tb_ext_irq = 1'b1; // assert the irq
      @((pc == `PC_EXT_IRQ_BEFOR_MRET)) // Wait the program run into the IRQ handler by check PC values
      tb_ext_irq = 1'b0;
      if(stop_assert_irq) begin
          break;
      end
    end
  end

  initial begin
    #100
    @(pc == `PC_AFTER_SETMTVEC ) // Wait the program goes out the reset_vector program
    forever begin
      repeat ($urandom_range(1, 1000)) @(posedge clk) tb_sft_irq = 1'b0; // Wait random times
      tb_sft_irq = 1'b1; // assert the irq
      @((pc == `PC_SFT_IRQ_BEFOR_MRET)) // Wait the program run into the IRQ handler by check PC values
      tb_sft_irq = 1'b0;
      if(stop_assert_irq) begin
          break;
      end
    end
  end

  initial begin
    #100
    @(pc == `PC_AFTER_SETMTVEC ) // Wait the program goes out the reset_vector program
    forever begin
      repeat ($urandom_range(1, 1000)) @(posedge clk) tb_tmr_irq = 1'b0; // Wait random times
      tb_tmr_irq = 1'b1; // assert the irq
      @((pc == `PC_TMR_IRQ_BEFOR_MRET)) // Wait the program run into the IRQ handler by check PC values
      tb_tmr_irq = 1'b0;
      if(stop_assert_irq) begin
          break;
      end
    end
  end
`endif

  reg[8*300:1] testcase;
  integer dumpwave;

  initial begin
    $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");  
    if($value$plusargs("TESTCASE=%s",testcase))begin
      $display("TESTCASE=%s",testcase);
    end

    pc_write_to_host_flag <=0;
    clk   <=0;
    lfextclk   <=0;
    rst_n <=0;
    #120 rst_n <=1;

    @(pc_write_to_host_cnt == 32'd8) #10 rst_n <=1;
`ifdef ENABLE_TB_FORCE
    @((~tb_tmr_irq) & (~tb_sft_irq) & (~tb_ext_irq)) #10 rst_n <=1;// Wait the interrupt to complete
`endif

        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~ Test Result Summary ~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~TESTCASE: %s ~~~~~~~~~~~~~", testcase);
        $display("~~~~~~~~~~~~~~Total cycle_count value: %d ~~~~~~~~~~~~~", cycle_count);
        $display("~~~~~~~~~~The valid Instruction Count: %d ~~~~~~~~~~~~~", valid_ir_cycle);
        $display("~~~~~The test ending reached at cycle: %d ~~~~~~~~~~~~~", pc_write_to_host_cycle);
        $display("~~~~~~~~~~~~~~~The final x3 Reg value: %d ~~~~~~~~~~~~~", x3);
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    if (x3 == 1) begin
        $display("~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    else begin
        $display("~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    #10
     $finish;
  end

  initial begin
    #40000000
        $display("Time Out !!!");
     $finish;
  end
 /////////////////////////////////////////////////////
 // mvu init
  initial begin
    #10
	wrw_en = 1'b0;
	wrw_addr = 72'b0;
	wrw_word = 32768'b0;
	mvu_shacc_clr = 8'b0;
	#100
	@(posedge clk);
	wrw_en = 1'b1;
	wrw_addr = 72'd0;
	wrw_word = 32768'b0011011100010100011101100001010101110110111111110111110010001010010100101110000100000111111101011101010101011110011000100110100011011101010001001011101111110011101001010001000010101011111010011000101010000111011001100011001010111011111101101011000000100010000101101001110111011100101111100000001111100000000000001110110011000011100011111110101110000001111100011000100010110110110011011110100011110001001010101010100011010000001101011111111110001101001100011010111111010001110101011100011001011100110001111010010111101110101001001010010011110010101001100010110000000001100011101100000011001110100000100110001110101101110101010110101001110111100101111100001000100010100110001111011000100001111000011110100000011110001110101101000010101001001011000101011111001111011001001100101011101101011111110011101111111111010010101001001101011001110001010011011001111110110001011011011100101100001001111101101100111111001101100010100100000010100010000001101101100101000100101100111110000110010101100110010010100000000110001001000110101000011000000110001111110111101011111101100010010000101111001101000011000111001011101101010001010100011001101110101011100011101010000100011000111011111000010111101110110100011001110000111001000000111000110000101101111011000101101100010101000000101101100101000101010010111001101011101111000111101001011101111101011010010100011011110110111001001100010100010010011001011011111100111011111110001000011010101100110000001000100001000100101011001011001101111111111100001001111111110000100011100101101001101010100001010100111110010011110011110101111001011111100101011001010011011000010010001111111111111111011000110011001010000001111110101110111001000110000111011100100011000110000111110110111001100000111011011111010100011001000000001000111011001101101100111000010100000111111000001011000010101111110000100010000010001010110101001010111100101100011001010111000000100110101001111101000010101110010000001011000101001001101100100101011000101110010010100011001111110100111000110101000010010010110000100010100010111000110011001000001010001010010111101111100001010011010110001011011101000001100100011001100101001001111110111101110111110010100010011101000111111011010001101100010111101011111010110101000101011001010101011111111000010000110100100110101100111101010011111011010001111101100000100010001011110110110010111111001001110010101001110001000111001011010100100100101011011100111100000100110001000100101111011000100001110110010101001101100110110011101110100011101100011101000101100111001010101111101101110110011001101011000001110000010000010101011010010000010101110001101001101101111110000001111111111011110000110111101000000011000011010101111011011101001111000100010100010111001110111100010000111000100000111111101000011110101101010100010011010010110111101101010100010000101100101111011110110001010000010011001000001111100110100100010010110100101110011110011101110100111010000111000010001101001011000000101011111110110101001011100001100011001111011010111001010010010001011100011110110010011100111000100100000101010001001110011100011101000010100001111110101001111101101001100111001110110011010000111010001101000000011111100110101010111001000010010000011000000110000011110011110011100000001111100101110100010000001010101010101001100000100010101100110010001001001000100101100110001101000110101011101110001000010011101110101100110010100101110000000011000000111111001110000001011011010000101000110100101111010000000100111111011010101100011111011010100001010000110101101100011111101100001000000111111101100000011011101011111100101100101111111010100110001010100001100110101001010001001111011010011111000000111100101101011100000110101111111101010000101110001100111111101111111001001011111100110110111100100000100111010011101110101110111101100110011110101110001001111111000110101000001111100101101100100011011110101111111100011111001111101110001111010011000001001100101100000010010101001100010010111110110110011011001001001001010010011011100010101110101100100010100000110110000001101010000111011111011101110011000011011000001111000001000001100001101000100000011011000100100111000010110101000110;
	
	@(posedge clk);
	wrw_en = 1'b1;
	wrw_addr = 72'd1;
	wrw_word = 32768'b0111100111010001000011010010111110111100101111001101000000100100110100001110101010111100111101011011000100110001100101001100011000111101011111000010011110000000001011111110110111010111111010001101110100010010111010110000000111011110000000000010101100100010110001000100000011010010000010010111101111010011001101110010000001111010000001110010110111110001101101011010100101011010101111100011001100111101101010001100111011111111100110001101110111111110000011100000001001111101101011010000000011000001011001111001101001110011010100000001010101101110101000101100010110111011101110111110010011110001001011001000001110000001111001110100111000110101101111001110011000110010111101101011000000110001110111111010101110000000111100001101100101101110100000111010001101111110000100111001011000100101101110101001001110111000011011110111110001111110011100100011011000110111100000101010101011011101011110100001110101000011001110101101000111011000101101001010101100001101011100001010000100111110110001010000111010011010001111011000010111101000010000100011111101011010000010011000011101110011111100111111011111000010101111001011010100110100010100101100001001110010011011001000000111001100110110000000001010001110001111101110110000001110001110011011100000111100001011010111101111101110111111011111001001100001001011100111001101000001100010101000011111010111000101110001100010001010110010101110010111010101110010111101110100110010001011001101111111100111101111000110101100111001110111100011101111000001010001010100001010101000101010000100101110011110111001101101111000100011100101000101010110100111111000011111011101011100011011010110010111100110111110000110001010010100000111010110000000111011111110110010101110011111101110100111000000011010111101110100110010100110011110110010001101000100101010101000110101110110100010110000011000101010111110001111110111011110001010111101001001011010010000111000111101110011000110111101000110011100000111100111100001100111110110100000011111011100111000100000110110110000100100010011000001110111001110101010010000100100110100010100000000000110101010100000100101011101001111100111001010001110110110111110111000110111110100000100011100000011101001010000110111110011000001001100111100110000010010111110010001111111110001010110010111001010111000000000100100100011011100010000001010110110111101111101111111010001001000001001110001011011000001110010001001010011100001011110011010000001110001111010011011101001100010010010111111010010010011101100010011011101100010001111011111000101111101011001010110100001110011100111110010000111000111101100101100101001111111011011101101101000010110101101110010110110100110100011010000101010010110100011000001100001111010100001000110110000011111111010101011011111010011110101101011101000010010111011000010011010100101011100111001011101100110011001000010001001000111111111100110100100101111111000111010001000001100111000010110110111110101101000000010010010100100011000011100100000110100000101100001011111010001111110010010001110011001100011101000110100000011011000010110100000101111001011011001101101000011001110011111101011001110111011100011000010101110000110100011110100100000011000000001100001101111011001010110100001000101111000010011001011101010100111110100011001001000100011111001011101101110100101110000101011010000111100100101100001100010010010010010111011001100001110000100000101101100001011010001110101010101100000100011001010010110100011100110110101100010110110011000100011110000101000101110111001010000110101011010100011010001111101100000100110100001000001111100100010001110111010011111010001100010000000111110100111010001001101000110111100111011100010100011110001011101011100111110111101111101000101100000101100011110100001010011011010000000100111010010000100100101101101000000010010011101101101101111010000101101011110101100110001100110110100111110011101110011100111010100101111101000000010011110000110101111001101000010011010010100001100110110101010010111000111101001110010000011100111100100110101001101101000000010000000000011111000100001001011111000101100110011011100110101001100000110101101001111111110100110100110110100110111000110000011;

	@(posedge clk);
	wrw_en = 1'b0;
	wrw_addr = 72'b0;
	wrw_word = 32768'b0;


  end

  always
  begin 
     #2 clk <= ~clk;
  end

  always
  begin 
     #33 lfextclk <= ~lfextclk;
  end


  integer i;

    reg [7:0] itcm_mem [0:(`E203_ITCM_RAM_DP*8)-1];
    initial begin
      $readmemh({testcase, ".verilog"}, itcm_mem);

      for (i=0;i<(`E203_ITCM_RAM_DP);i=i+1) begin
          `ITCM.mem_r[i][00+7:00] = itcm_mem[i*8+0];
          `ITCM.mem_r[i][08+7:08] = itcm_mem[i*8+1];
          `ITCM.mem_r[i][16+7:16] = itcm_mem[i*8+2];
          `ITCM.mem_r[i][24+7:24] = itcm_mem[i*8+3];
          `ITCM.mem_r[i][32+7:32] = itcm_mem[i*8+4];
          `ITCM.mem_r[i][40+7:40] = itcm_mem[i*8+5];
          `ITCM.mem_r[i][48+7:48] = itcm_mem[i*8+6];
          `ITCM.mem_r[i][56+7:56] = itcm_mem[i*8+7];
      end

        $display("ITCM 0x00: %h", `ITCM.mem_r[8'h00]);
        $display("ITCM 0x01: %h", `ITCM.mem_r[8'h01]);
        $display("ITCM 0x02: %h", `ITCM.mem_r[8'h02]);
        $display("ITCM 0x03: %h", `ITCM.mem_r[8'h03]);
        $display("ITCM 0x04: %h", `ITCM.mem_r[8'h04]);
        $display("ITCM 0x05: %h", `ITCM.mem_r[8'h05]);
        $display("ITCM 0x06: %h", `ITCM.mem_r[8'h06]);
        $display("ITCM 0x07: %h", `ITCM.mem_r[8'h07]);
        $display("ITCM 0x16: %h", `ITCM.mem_r[8'h16]);
        $display("ITCM 0x20: %h", `ITCM.mem_r[8'h20]);

    end 



  wire jtag_TDI = 1'b0;
  wire jtag_TDO;
  wire jtag_TCK = 1'b0;
  wire jtag_TMS = 1'b0;
  wire jtag_TRST = 1'b0;

  wire jtag_DRV_TDO = 1'b0;

e203_soc_top u_e203_soc_top(
   
   .hfextclk(hfclk),
   .hfxoscen(),

   .lfextclk(lfextclk),
   .lfxoscen(),

   .io_pads_jtag_TCK_i_ival (jtag_TCK),
   .io_pads_jtag_TMS_i_ival (jtag_TMS),
   .io_pads_jtag_TDI_i_ival (jtag_TDI),
   .io_pads_jtag_TDO_o_oval (jtag_TDO),
   .io_pads_jtag_TDO_o_oe (),

   .io_pads_gpioA_i_ival(32'b0),
   .io_pads_gpioA_o_oval(),
   .io_pads_gpioA_o_oe  (),

   .io_pads_gpioB_i_ival(32'b0),
   .io_pads_gpioB_o_oval(),
   .io_pads_gpioB_o_oe  (),

   .io_pads_qspi0_sck_o_oval (),
   .io_pads_qspi0_cs_0_o_oval(),
   .io_pads_qspi0_dq_0_i_ival(1'b1),
   .io_pads_qspi0_dq_0_o_oval(),
   .io_pads_qspi0_dq_0_o_oe  (),
   .io_pads_qspi0_dq_1_i_ival(1'b1),
   .io_pads_qspi0_dq_1_o_oval(),
   .io_pads_qspi0_dq_1_o_oe  (),
   .io_pads_qspi0_dq_2_i_ival(1'b1),
   .io_pads_qspi0_dq_2_o_oval(),
   .io_pads_qspi0_dq_2_o_oe  (),
   .io_pads_qspi0_dq_3_i_ival(1'b1),
   .io_pads_qspi0_dq_3_o_oval(),
   .io_pads_qspi0_dq_3_o_oe  (),

   .io_pads_aon_erst_n_i_ival (rst_n),//This is the real reset, active low
   .io_pads_aon_pmu_dwakeup_n_i_ival (1'b1),

   .io_pads_aon_pmu_vddpaden_o_oval (),
   .io_pads_aon_pmu_padrst_o_oval    (),

   .io_pads_bootrom_n_i_ival       (1'b0),// In Simulation we boot from ROM
   .io_pads_dbgmode0_n_i_ival       (1'b1),
   .io_pads_dbgmode1_n_i_ival       (1'b1),
   .io_pads_dbgmode2_n_i_ival       (1'b1) ,

   .mvu_apb_paddr       (mvu_apb_paddr  ),
   .mvu_apb_pwrite      (mvu_apb_pwrite ),
   .mvu_apb_pselx       (mvu_apb_pselx  ),
   .mvu_apb_penable     (mvu_apb_penable), 
   .mvu_apb_pwdata      (mvu_apb_pwdata ),
   .mvu_apb_prdata      (mvu_apb_prdata ),

   .mvu_irq				(mvu_irq[0]),

   .dma_icb_cmd_valid        (dma_icb_cmd_valid),
   .dma_icb_cmd_ready        (dma_icb_cmd_ready),
   .dma_icb_cmd_addr         (dma_icb_cmd_addr ),
   .dma_icb_cmd_read         (dma_icb_cmd_read ),
   .dma_icb_cmd_wdata        (dma_icb_cmd_wdata),
   .dma_icb_cmd_wmask        (dma_icb_cmd_wmask),
   
   .dma_icb_rsp_valid        (dma_icb_rsp_valid),
   .dma_icb_rsp_ready        (dma_icb_rsp_ready),
   .dma_icb_rsp_err          (dma_icb_rsp_err  ),
   .dma_icb_rsp_rdata        (dma_icb_rsp_rdata),

   .dma_irq					 (dma_irq)

);

/*
// apb test module
sirv_apb_slv_test mvu_apb_test(
  .apb_paddr				(mvu_apb_paddr  ),
  .apb_pwrite				(mvu_apb_pwrite ),
  .apb_pselx				(mvu_apb_pselx  ),
  .apb_penable				(mvu_apb_penable),
  .apb_pwdata				(mvu_apb_pwdata ),
  .apb_prdata				(mvu_apb_prdata ),

  .clk						(clk),
  .rst_n					(rst_n)
);
*/

mvu_u_wrapper u_mvu_top(
	.clk			(clk),
	.rst_n			(rst_n),

	.paddr			(mvu_apb_paddr  ),
	.psel			(mvu_apb_pselx  ),
	.penable		(mvu_apb_penable),
	.pwrite			(mvu_apb_pwrite ),
	.pwdata			(mvu_apb_pwdata ),

	.prdata			(mvu_apb_prdata ),

	.wrw_en			(wrw_en		),
	.wrw_addr		(wrw_addr	),
	.wrw_word		(wrw_word	),

	.rdc_en			(rdc_en		),
	.rdc_grnt		(rdc_grnt	),
	.rdc_addr		(rdc_addr	),
	.rdc_word		(rdc_word	),

	.wrc_en			(wrc_en		),
	.wrc_grnt		(wrc_grnt	),
	.wrc_addr		(wrc_addr	),
	.wrc_word		(wrc_word	),

	.wrs_en			(wrs_en		),
	.wrs_addr		(wrs_addr	),
	.wrs_word		(wrs_word	),

	.wrb_en			(wrb_en		),
	.wrb_addr		(wrb_addr	),
	.wrb_word		(wrb_word	),

	.mvu_shacc_clr	(mvu_shacc_clr),
	.mvu_irq		(mvu_irq)
);

mvu_dma_top u_mvu_dma_top(
	.clk						(clk),
	.rst_n						(rst_n),

	.source_address				(rom_sim_addr),
	.source_data				(rom_sim_data),
	.source_valid				(rom_sim_valid),
	.source_ready				(rom_sim_ready),

	.dest_data_address			(wrc_addr),
	.dest_data_data				(wrc_word),
	.dest_data_valid			(wrc_en[0]),
	.dest_data_ready			(wrc_grnt[0]),

	.dest_weight_address		(),
	.dest_weight_data			(),
	.dest_weight_valid			(),
	.dest_weight_ready			(1'b1),

	.i_icb_cmd_valid			(dma_icb_cmd_valid),
	.i_icb_cmd_ready			(dma_icb_cmd_ready),
	.i_icb_cmd_addr				(dma_icb_cmd_addr), 
	.i_icb_cmd_read				(dma_icb_cmd_read), 
	.i_icb_cmd_wdata			(dma_icb_cmd_wdata),
	.i_icb_cmd_wmask			(dma_icb_cmd_wmask),

	.i_icb_rsp_valid			(dma_icb_rsp_valid),
	.i_icb_rsp_ready			(dma_icb_rsp_ready),
	.i_icb_rsp_err				(dma_icb_rsp_err),
	.i_icb_rsp_rdata			(dma_icb_rsp_rdata),

	.dma_irq					(dma_irq)
);

rom_sim u_rom_sim(
    .source_address				(rom_sim_addr[7:0]),   		// 输入地址，假设8位地址
    .source_data				(rom_sim_data),     		// 输出数据，假设16位数据宽度
    .source_valid				(rom_sim_valid),           // 输入数据请求信号
    .source_ready				(rom_sim_ready)            // 输出数据准备信号
);

endmodule


