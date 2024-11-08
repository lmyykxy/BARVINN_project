//
// MVU top level
//
// Notes:
// * For wlength_X and ilength_X parameters, the value to assign is actual_length - 1.
//
//
`timescale 1ns/1ps
`include "mvu_intf.sv"
/**** Module ****/
module mvutop import mvu_pkg::*; ( 
                                    MVU_EXT_INTERFACE mvu_ext,
                                    MVU_CFG_INTERFACE mvu_cfg
                                 );


genvar i;

// Local registers
logic[      NMVU-1 : 0] start_q;                                  // Delayed start signal
logic[           1 : 0] mul_mode_q        [NMVU-1 : 0];           // Config: multiply mode
logic[  BQMSBIDX-1 : 0] quant_msbidx_q    [NMVU-1 : 0];           // Quantizer: bit position index of the MSB
logic[   BCNTDWN-1 : 0] countdown_q       [NMVU-1 : 0];           // Config: number of clocks to countdown for given task
logic[     BPREC-1 : 0] wprecision_q      [NMVU-1 : 0];           // Config: weight precision
logic[     BPREC-1 : 0] iprecision_q      [NMVU-1 : 0];           // Config: input precision
logic[     BPREC-1 : 0] oprecision_q      [NMVU-1 : 0];           // Config: output precision
logic[   BBWADDR-1 : 0] wbaseaddr_q       [NMVU-1 : 0];           // Config: weight memory base address
logic[   BBDADDR-1 : 0] ibaseaddr_q       [NMVU-1 : 0];           // Config: data memory base address for input
logic[   BSBANKA-1 : 0] sbaseaddr_q       [NMVU-1 : 0];           // Config: scaler memory base address
logic[   BBBANKA-1 : 0] bbaseaddr_q       [NMVU-1 : 0];           // Config: bias memory base address
logic[   BBDADDR-1 : 0] obaseaddr_q       [NMVU-1 : 0];           // Config: data memory base address for output
logic[      NMVU-1 : 0] omvusel_q         [NMVU-1 : 0];           // Config: MVU selection bits for output
logic[   BWBANKA-1 : 0] wjump_q           [NMVU-1 : 0][NJUMPS-1 : 0];           // Config: weight jumps
logic[   BDBANKA-1 : 0] ijump_q           [NMVU-1 : 0][NJUMPS-1 : 0];           // Config: input jumps
logic[   BSBANKA-1 : 0] sjump_q           [NMVU-1 : 0][NJUMPS-1 : 0];           // Config: scaler jump
logic[   BBBANKA-1 : 0] bjump_q           [NMVU-1 : 0][NJUMPS-1 : 0];           // Config: bias jump
logic[   BDBANKA-1 : 0] ojump_q           [NMVU-1 : 0][NJUMPS-1 : 0];           // Config: output jump
logic[   BLENGTH-1 : 0] wlength_q         [NMVU-1 : 0][NJUMPS-1 : 1];           // Config: weight length
logic[   BLENGTH-1 : 0] ilength_q         [NMVU-1 : 0][NJUMPS-1 : 1];           // Config: input length
logic[   BLENGTH-1 : 0] slength_q         [NMVU-1 : 0][NJUMPS-1 : 1];           // Config: scaler length
logic[   BLENGTH-1 : 0] blength_q         [NMVU-1 : 0][NJUMPS-1 : 1];           // Config: bias length
logic[   BLENGTH-1 : 0] olength_q         [NMVU-1 : 0][NJUMPS-1 : 1];           // Config: output length
logic[  BSCALERB-1 : 0] scaler_b_q        [NMVU-1 : 0];                         // Config: multiplicative scaler (operand 'b')
logic                   usescaler_mem_q   [NMVU-1 : 0];                         // Config: use scalar mem if 1; otherwise use the scaler_b input for scaling
logic                   usebias_mem_q     [NMVU-1 : 0];                         // Config: use the bias memory if 1; if not, not bias is added in the scaler
logic[    NJUMPS-1 : 0] shacc_load_sel_q  [NMVU-1 : 0];                         // Config: select jump trigger for shift/accumultor load
logic[    NJUMPS-1 : 0] zigzag_step_sel_q [NMVU-1 : 0];                         // Config: select jump trigger for stepping the zig-zag address generator

/* Local Wires */

// MVU Weight memory controll
logic[NMVU*BWBANKA-1 : 0] rdw_addr;

// MVU Data memory control
logic[        NMVU-1 : 0] rdd_en;
logic[        NMVU-1 : 0] rdd_grnt;
logic[NMVU*BDBANKA-1 : 0] rdd_addr;
logic[        NMVU-1 : 0] wrd_en;
logic[        NMVU-1 : 0] wrd_grnt;
logic[NMVU*BDBANKA-1 : 0] wrd_addr;

// MVU Scaler and Bias memory control
logic[        NMVU-1 : 0] rds_en;                        // Scaler memory: read enable
logic[NMVU*BSBANKA-1 : 0] rds_addr;                      // Scaler memory: read address
logic[     BSBANKA-1 : 0] rds_addr_offset [NMVU-1 : 0];  // Scaler memory: read address offset from scaler mem AGU
logic[        NMVU-1 : 0] rdb_en;                        // Bias memory: read enable
logic[NMVU*BBBANKA-1 : 0] rdb_addr;                      // Bias memory: read address
logic[     BBBANKA-1 : 0] rdb_addr_offset [NMVU-1 : 0];  // Bias memory: read address offset from bias mem AGU

// Interconnect
logic                     ic_clr_int;
logic[   NMVU*NMVU-1 : 0] ic_send_to;
logic[        NMVU-1 : 0] ic_send_en;
logic[NMVU*BDBANKA-1 : 0] ic_send_addr;
logic[NMVU*BDBANKW-1 : 0] ic_send_word;
logic[        NMVU-1 : 0] ic_recv_en;
logic[   NMVU*NMVU-1 : 0] ic_recv_from;
logic[NMVU*BDBANKA-1 : 0] ic_recv_addr;
logic[NMVU*BDBANKW-1 : 0] ic_recv_word;
logic[NMVU*BDBANKW-1 : 0] rdi_word;
logic[        NMVU-1 : 0] wri_en;
logic[NMVU*BDBANKW-1 : 0] wri_word;

logic[        NMVU-1 : 0] rdi_en;
logic[        NMVU-1 : 0] rdi_grnt;
logic[NMVU*BDBANKA-1 : 0] rdi_addr;
logic[        NMVU-1 : 0] wri_grnt;
logic[NMVU*BDBANKA-1 : 0] wri_addr;

logic[NMVU*BDBANKW-1 : 0] mvu_word_out;

// Scaler
logic[        NMVU-1 : 0] scaler_clr;            // Scaler: clear/reset

// Quantizer
logic[        NMVU-1 : 0] quant_start;           // Quantizer: signal to start quantizing
logic[        NMVU-1 : 0] quant_stall;           // Quantizer: stall
logic[      NMVU*N-1 : 0] quantarray_out;        // Quantizer: output
logic[  BPREC*NMVU-1 : 0] quant_bwout;           // Quantizer: output bitwidth
logic[        NMVU-1 : 0] quant_load;            // Quantizer: load base address
logic[        NMVU-1 : 0] quant_step;            // Quantizer: step the quantizer
logic[        NMVU-1 : 0] quant_ctrl_clr;        // Quantizer: clear/reset controller
logic[        NMVU-1 : 0] quant_clr_int;         // Quantizer: internal clear control

// Output data write back to memory
// TODO: DO SOMETHING USEFUL WITH THESE SIGNALS
logic[        NMVU-1 : 0] outstep;
logic[        NMVU-1 : 0] outload;

// Other wires
logic[        NMVU-1 : 0] inagu_clr;
logic[        NMVU-1 : 0] controller_clr;    // Controller clear/reset
logic[        NMVU-1 : 0] step;              // Step if 1, stall if 0
logic[        NMVU-1 : 0] run;               // Running if 1
logic[        NMVU-1 : 0] d_msb;             // Input data address on MSB
logic[        NMVU-1 : 0] w_msb;             // Weight data address on MSB
logic[        NMVU-1 : 0] neg_acc;           // Negate the input to the accumulators
logic[        NMVU-1 : 0] neg_acc_dly;       // Negation control delayed
logic[        NMVU-1 : 0] shacc_load;        // Accumulator load control
logic[        NMVU-1 : 0] shacc_sh;          // Accumulator shift control
logic[        NMVU-1 : 0] shacc_acc;         // Accumulator accumulate control
logic[        NMVU-1 : 0] shacc_clr_int;     // Accumulator clear internal control
logic[        NMVU-1 : 0] shacc_load_start;  // Accumulator load from start of job
logic[        NMVU-1 : 0] agu_sh_out;        // Input AGU shift accumulator
logic[        NMVU-1 : 0] agu_shacc_done;    // AGU accumulator done indicator
logic[        NMVU-1 : 0] run_acc;           // Run signal for the accumulator/shifters
logic[        NMVU-1 : 0] shacc_done;        // Accumulator done control
logic[        NMVU-1 : 0] maxpool_done;      // Max pool done control
logic[        NMVU-1 : 0] outagu_clr;        // Clear the output AGU
logic[        NMVU-1 : 0] outagu_load;       // Load the output AGU base address
logic[      NJUMPS-1 : 0] wagu_on_j[NMVU-1 : 0];      // Indicates when a weight address jump X
logic[        NMVU-1 : 0] scaleragu_step;    // Steps the scaler memory AGU
logic[        NMVU-1 : 0] biasagu_step;      // Steps the bias memory AGU
logic[        NMVU-1 : 0] scaleragu_clr;     // Clears the state of the Scaler memory AGU
logic[        NMVU-1 : 0] biasagu_clr;       // Clears the state of the bias memory AGU
logic[        NMVU-1 : 0] scaleragu_clr_dly; // Clears the state of the Scaler memory AGU
logic[        NMVU-1 : 0] biasagu_clr_dly;   // Clears the state of the bias memory AGU


/*
* Wiring 
*/

/*
* Interconnect
*/

interconn #(
    .N(NMVU),
    .W(BDBANKW),
    .BADDR(BDBANKA)
) ic (
    .clk(mvu_ext.clk),
    .clr(ic_clr_int),
    .send_to(ic_send_to),
    .send_en(ic_send_en),
    .send_addr(ic_send_addr),
    .send_word(ic_send_word),
    .recv_from(ic_recv_from),
    .recv_en(ic_recv_en),
    .recv_addr(ic_recv_addr),
    .recv_word(ic_recv_word)
);

// Interconnect wires
generate for(i=0; i < NMVU; i = i+1) begin:GENic
    assign ic_send_to[i*NMVU +: NMVU] = omvusel_q[i];
    assign ic_send_en[i] = (| omvusel_q[i]) & !omvusel_q[i][i] & outstep[i];
end endgenerate

assign ic_send_word = mvu_word_out;
assign ic_send_addr = wrd_addr;
assign wri_word     = ic_recv_word;
assign wri_en       = ic_recv_en;
assign wri_addr     = ic_recv_addr;

// TODO: FIGURE OUT WHERE TO WIRE OTHER INTERCONNECT DATA ACCESS SIGNAL
assign rdi_en           = 0;
//assign rdi_grnt         = 0;
assign rdi_addr         = 0;
//assign wri_grnt         = 0;

assign rdd_en           = run;                              // MVU reads when running

generate for(i=0; i < NMVU; i = i+1) begin:GENrds
    assign rds_en[i] = run[i] & usescaler_mem_q[i];            // No need to read from scaler mem if not using
    assign rdb_en[i] = run[i] & usebias_mem_q[i];              // No need to read from bias mem if not using
end endgenerate

// TODO: WIRE THESE UP TO SOMETHING USEFUL
assign outload          = 0;
assign quant_stall      = 0;
assign step             = {NMVU{1'b1}};                      // No stalls for now

// Accumulator signals
assign run_acc          = run;                              // No stalls for now
assign shacc_load       = shacc_done | shacc_load_start;    // Load accumulator with current output of MVP's

// Clear signals (just connect to global reset for now)
assign ic_clr_int       = !mvu_ext.rst_n | mvu_ext.ic_clr;
assign controller_clr   = {NMVU{!mvu_ext.rst_n}};
assign inagu_clr        = {NMVU{!mvu_ext.rst_n}} | start_q;
assign outagu_clr       = {NMVU{!mvu_ext.rst_n}};
assign shacc_clr_int    = {NMVU{!mvu_ext.rst_n}} | mvu_ext.shacc_clr;       // Clear the accumulator
assign scaleragu_clr    = {NMVU{!mvu_ext.rst_n}} | scaleragu_clr_dly;
assign biasagu_clr      = {NMVU{!mvu_ext.rst_n}} | biasagu_clr_dly;
assign scaler_clr       = {NMVU{!mvu_ext.rst_n}};
assign quant_clr_int    = {NMVU{!mvu_ext.rst_n}} | mvu_cfg.quant_clr;

// Quantizer and output control signals
assign quant_start      = maxpool_done;
assign outstep          = quant_step;
assign quant_ctrl_clr   = {NMVU{!mvu_ext.rst_n}} | mvu_cfg.quant_clr;

// MVU Data Memory control
generate for(i = 0; i < NMVU; i = i + 1) begin: wrd_en_array
    assign wrd_en[i] = outstep[i] & omvusel_q[i][i];
end endgenerate


// Delayed start signal to sync with the parameter buffer registers
always @(posedge mvu_ext.clk) begin
    if (~mvu_ext.rst_n) begin
        start_q <= 0;
    end else begin
        start_q <= mvu_ext.start;
    end
end

// Clock in the input parameters when the start signal is asserted
generate for(i = 0; i < NMVU; i = i + 1) begin: parambuf_array
    always @(posedge mvu_ext.clk) begin
        if (~mvu_ext.rst_n) begin
            mul_mode_q[i]       <= 0;
            quant_msbidx_q[i]   <= 0;
            countdown_q[i]      <= 0;
            wprecision_q[i]     <= 0;
            iprecision_q[i]     <= 0;
            oprecision_q[i]     <= 0;
            wbaseaddr_q[i]      <= 0;
            ibaseaddr_q[i]      <= 0;
            sbaseaddr_q[i]      <= 0;
            bbaseaddr_q[i]      <= 0;
            obaseaddr_q[i]      <= 0;
            omvusel_q[i]        <= 0;
            scaler_b_q[i]       <= 0;
            usescaler_mem_q[i]  <= 0;
            usebias_mem_q[i]    <= 0;
            shacc_load_sel_q[i] <= 5'b00100;                // For 5 jumps, select the j2 by default
            zigzag_step_sel_q[i] <= 5'b00001;               // For 5 jumps, select the j0 by default

            // Initialize the jump parameters
            for (int j = 0; j < NJUMPS; j++) begin
                wjump_q[i][j] <= 0;
                ijump_q[i][j] <= 0;
                sjump_q[i][j] <= 0;
                bjump_q[i][j] <= 0;
                ojump_q[i][j] <= 0;
            end

            // Intialize the length parameters
            for (int j = 1; j < NJUMPS; j++) begin
                wlength_q[i][j] <= 0;
                ilength_q[i][j] <= 0;
                slength_q[i][j] <= 0;
                blength_q[i][j] <= 0;
                olength_q[i][j] <= 0;
            end

        end else begin
            if (mvu_ext.start[i]) begin
                mul_mode_q[i]           <= mvu_cfg.mul_mode       [i];
                quant_msbidx_q[i]       <= mvu_cfg.quant_msbidx   [i];
                countdown_q[i]          <= mvu_cfg.countdown      [i];
                wprecision_q[i]         <= mvu_cfg.wprecision     [i];
                iprecision_q[i]         <= mvu_cfg.iprecision     [i];
                oprecision_q[i]         <= mvu_cfg.oprecision     [i];
                wbaseaddr_q[i]          <= mvu_cfg.wbaseaddr      [i];
                ibaseaddr_q[i]          <= mvu_cfg.ibaseaddr      [i];
                sbaseaddr_q[i]          <= mvu_cfg.sbaseaddr      [i];
                bbaseaddr_q[i]          <= mvu_cfg.bbaseaddr      [i];
                obaseaddr_q[i]          <= mvu_cfg.obaseaddr      [i];
                omvusel_q[i]            <= mvu_cfg.omvusel        [i];
                scaler_b_q[i]           <= mvu_cfg.scaler_b       [i];
                usescaler_mem_q[i]      <= mvu_cfg.usescaler_mem  [i];
                usebias_mem_q[i]        <= mvu_cfg.usebias_mem    [i];
                shacc_load_sel_q[i]     <= mvu_cfg.shacc_load_sel [i];
                zigzag_step_sel_q[i]    <= mvu_cfg.zigzag_step_sel[i];

                // Assign the jump parameters
                for (int j = 0; j < NJUMPS; j++) begin
                    wjump_q[i][j] <= mvu_cfg.wjump[i][j];
                    ijump_q[i][j] <= mvu_cfg.ijump[i][j];
                    sjump_q[i][j] <= mvu_cfg.sjump[i][j];
                    bjump_q[i][j] <= mvu_cfg.bjump[i][j];
                    ojump_q[i][j] <= mvu_cfg.ojump[i][j];
                end

                // Assign the length parameters
                for (int j = 1; j < NJUMPS; j++) begin
                    wlength_q[i][j] <= mvu_cfg.wlength[i][j];
                    ilength_q[i][j] <= mvu_cfg.ilength[i][j];
                    slength_q[i][j] <= mvu_cfg.slength[i][j];
                    blength_q[i][j] <= mvu_cfg.blength[i][j];
                    olength_q[i][j] <= mvu_cfg.olength[i][j];
                end
            end
        end
    end
end endgenerate


// Controllers
generate for(i = 0; i < NMVU; i = i + 1) begin: controllerarray
    controller #(
        .BCNTDWN    (BCNTDWN)
    ) controller_unit (
        .clk        (mvu_ext.clk),
        .clr        (controller_clr[i]),
        .start      (start_q[i]),
        .countdown  (countdown_q[i]),
        .step       (step[i]),
        .run        (run[i]),
        .done       (mvu_ext.done[i]),
        .irq        (mvu_ext.irq[i])
    );
end endgenerate


// Address generation modules for input and weight memory
generate for(i = 0; i < NMVU; i = i + 1) begin: inaguarray
    inagu #(
        .BPREC      (BPREC),
        .BDBANKA    (BDBANKA),
        .BWBANKA    (BWBANKA),
        .BWLENGTH   (BLENGTH)
    ) inagu_unit (
        .clk        (mvu_ext.clk),
        .clr        (inagu_clr[i]),
        .en         (run[i]),
        .iprecision (iprecision_q[i]),
        .ijump      (ijump_q[i]),
        .ilength    (ilength_q[i]),
        .ibaseaddr  (ibaseaddr_q[i]),
        .wprecision (wprecision_q[i]),
        .wjump      (wjump_q[i]),
        .wlength    (wlength_q[i]),
        .wbaseaddr  (wbaseaddr_q[i]),
        .zigzag_step_sel(zigzag_step_sel_q[i]),
        .iaddr_out  (rdd_addr[i*BDBANKA +: BDBANKA]),
        .waddr_out  (rdw_addr[i*BWBANKA +: BWBANKA]),
        .imsb       (d_msb[i]),
        .wmsb       (w_msb[i]),
        .sh_out     (agu_sh_out[i]),
        .wagu_on_j  (wagu_on_j[i])
    );
end endgenerate

// Scaler and Bias memory address generation units
generate for(i = 0; i < NMVU; i = i+1) begin: scalerbiasaguarray

    agu #(
        .BWADDR     (BSBANKA),
        .BWLENGTH   (BLENGTH)
    ) scaleragu_unit (
        .clk        (mvu_ext.clk),
        .clr        (scaleragu_clr[i]),
        .step       (scaleragu_step[i]),
        .l          (slength_q[i]),
        .j          (sjump_q[i]),            // TODO: come up with better numbering scheme
        .addr_out   (rds_addr_offset[i]),
        .z_out      (),
        .on_j       ()
    );

    agu #(
        .BWADDR     (BBBANKA),
        .BWLENGTH   (BLENGTH)
    ) biasagu_unit (
        .clk        (mvu_ext.clk),
        .clr        (scaleragu_clr[i]),
        .step       (scaleragu_step[i]),
        .l          (blength_q[i]),
        .j          (bjump_q[i]),            // TODO: come up with better numbering scheme
        .addr_out   (rdb_addr_offset[i]),
        .z_out      (),
        .on_j       ()
    );

    assign rds_addr[i*BSBANKA +: BSBANKA] = sbaseaddr_q[i] + rds_addr_offset[i];
    assign rdb_addr[i*BBBANKA +: BBBANKA] = bbaseaddr_q[i] + rdb_addr_offset[i];

end endgenerate

// Output address generators
generate for(i = 0; i < NMVU; i = i+1) begin:outaguarray
    outagu #(
            .BDBANKA    (BDBANKA)
        ) outaguunit
        (
            .clk        (mvu_ext.clk                            ),
            .clr        (outagu_clr[i]                      ),
            .step       (outstep[i]                         ),
            .load       (outagu_load[i]                     ),
            .baseaddr   (mvu_cfg.obaseaddr[i]),
            .addrout    (wrd_addr[i*BDBANKA  +: BDBANKA]    )
        );
end endgenerate

// Quantizer Controllers
generate for(i = 0; i < NMVU; i = i+1) begin: quantser_ctrlarray
    assign quant_bwout[i*BPREC +: BQBOUT] = mvu_cfg.oprecision[i];
    quantser_ctrl #(
        .BWOUT      (BSCALERP)
    ) quantser_ctrl_unit (
        .clk        (mvu_ext.clk),
        .clr        (quant_ctrl_clr[i]),
        .bwout      (quant_bwout[i*BPREC +: BQBOUT]),
        .start      (quant_start[i]),
        .stall      (quant_stall[i]),
        .load       (quant_load[i]),
        .step       (quant_step[i])
    );
end endgenerate

// Negate the input to the accumulators when one or both data/weights are signed and is on an MSB
assign neg_acc = (mvu_cfg.d_signed & d_msb) ^ (mvu_cfg.w_signed & w_msb);

// Trigger when the shacc should load
generate for(i = 0; i < NMVU; i = i+1) begin: triggers
    assign agu_shacc_done[i] = run[i] && (wagu_on_j[i] & shacc_load_sel_q[i]);
end endgenerate


// Insert delay for accumulator shifter signals to account for number of VVP pipeline stages
generate for(i=0; i < NMVU; i = i+1) begin: ctrl_delayarray

    // TODO: connect the step signals on these shift regs
    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 1)
    ) shacc_load_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (start_q[i]),
        .out    (shacc_load_start[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 0)
    ) neg_acc_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (neg_acc[i]),
        .out    (neg_acc_dly[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 0)
    ) shacc_sh_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (agu_sh_out[i]),
        .out    (shacc_sh[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 1)
    ) shacc_acc_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (run_acc[i]),
        .out    (shacc_acc[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 1)      // TODO: find a better way to re-time this
    ) acc_done_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (agu_shacc_done[i]),
        .out    (shacc_done[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY)      // TODO: find a better way to re-time this
    ) scaleragu_step_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (agu_shacc_done[i]),
        .out    (scaleragu_step[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY)      // TODO: find a better way to re-time this
    ) scaleragu_clr_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (start_q[i]),
        .out    (scaleragu_clr_dly[i])
    );

    shiftreg #(
        .N      (SCALERLATENCY+MAXPOOLSTAGES)
    ) maxpool_done_delayarrayunit (
        .clk    (mvu_ext.clk),
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (shacc_done[i]),
        .out    (maxpool_done[i])
    );

    shiftreg #(
        .N      (VVPSTAGES+MEMRDLATENCY+SCALERLATENCY+MAXPOOLSTAGES + 1)
    ) outagu_load_delayarrayunit (
        .clk    (mvu_ext.clk),
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (start_q[i]),
        .out    (outagu_load[i])
    );

end endgenerate


/*   Cores... */
generate for(i=0;i<NMVU;i=i+1) begin:mvuarray
    mvu #(
            .N              (N),
            .NDBANK         (NDBANK)
        ) mvuunit
        (
            .clk            (mvu_ext.clk                            ),
            .run            (run[i]                                 ),
            .mul_mode       (mul_mode_q[i]                          ),
            .neg_acc        (neg_acc_dly[i]                         ),
            .shacc_clr      (shacc_clr_int[i]                       ),
            .shacc_load     (shacc_load[i]                          ),
            .shacc_acc      (shacc_acc[i]                           ),
            .shacc_sh       (shacc_sh[i]                            ),
            .scaler_clr     (scaler_clr[i]                          ),
            .scaler_b       (scaler_b_q[i]                          ),
            .usescaler_mem  (usescaler_mem_q[i]                     ),
            .usebias_mem    (usebias_mem_q[i]                       ),
            .max_en         (mvu_cfg.max_en[i]                      ),
            .max_clr        (mvu_cfg.max_clr[i]                     ),
            .max_pool       (mvu_cfg.max_pool[i]                    ),
            .quant_clr      (quant_clr_int[i]                       ),
            .quant_msbidx   (quant_msbidx_q[i]                      ),
            .quant_load     (quant_load[i]                          ),
            .quant_step     (quant_step[i]                          ),
            .rdw_addr       (rdw_addr[i*BWBANKA +: BWBANKA]         ),
            .wrw_addr       (mvu_ext.wrw_addr[i*BWBANKA +: BWBANKA] ),
            .wrw_word       (mvu_ext.wrw_word[i*BWBANKW +: BWBANKW] ),
            .wrw_en         (mvu_ext.wrw_en[i]                      ),
            .rdd_en         (rdd_en[i]                              ),
            .rdd_grnt       (rdd_grnt[i]                            ),
            .rdd_addr       (rdd_addr[i*BDBANKA +: BDBANKA]         ),
            .wrd_en         (wrd_en[i]                              ),
            .wrd_grnt       (wrd_grnt[i]                            ),
            .wrd_addr       (wrd_addr[i*BDBANKA +: BDBANKA]         ),
            .rdi_en         (rdi_en[i]                              ),
            .rdi_grnt       (rdi_grnt[i]                            ),
            .rdi_addr       (rdi_addr[i*BDBANKA +: BDBANKA]         ),
            .rdi_word       (rdi_word[i*BDBANKW +: BDBANKW]         ),
            .wri_en         (wri_en[i]                              ),
            .wri_grnt       (wri_grnt[i]                            ),
            .wri_addr       (wri_addr[i*BDBANKA +: BDBANKA]         ),
            .wri_word       (wri_word[i*BDBANKW +: BDBANKW]         ),
            .rdc_en         (mvu_ext.rdc_en[i]                      ),
            .rdc_grnt       (mvu_ext.rdc_grnt[i]                    ),
            .rdc_addr       (mvu_ext.rdc_addr[i*BDBANKA +: BDBANKA] ),
            .rdc_word       (mvu_ext.rdc_word[i*BDBANKW +: BDBANKW] ),
            .wrc_en         (mvu_ext.wrc_en[i]                      ),
            .wrc_grnt       (mvu_ext.wrc_grnt[i]                    ),
            .wrc_addr       (mvu_ext.wrc_addr[BDBANKA-1: 0]         ),
            .wrc_word       (mvu_ext.wrc_word[BDBANKW-1 : 0]        ),
            .mvu_word_out   (mvu_word_out[i*BDBANKW +: BDBANKW]     ),
            .rds_en         (rds_en[i]                              ),
            .rds_addr       (rds_addr[i*BSBANKA +: BSBANKA]         ),
            .wrs_en         (mvu_ext.wrs_en[i]                      ),
            .wrs_addr       (mvu_ext.wrs_addr                       ),
            .wrs_word       (mvu_ext.wrs_word                       ),
            .rdb_en         (rdb_en[i]                              ),
            .rdb_addr       (rdb_addr[i*BBBANKA +: BBBANKA]         ),
            .wrb_en         (mvu_ext.wrb_en[i]                      ),
            .wrb_addr       (mvu_ext.wrb_addr                       ),
            .wrb_word       (mvu_ext.wrb_word                       )
        );
end endgenerate


/* Module end */
endmodule