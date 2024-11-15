`timescale 1ns / 1ps

module e203_int_gen (
    input	wire	sys_clk,
    input	wire	sys_rst_n,

    input	wire	pulse_start,
    output 	wire	int_pulse
);

parameter CLK_FREQ = 125; // clock frequency, 125mHz => 125
parameter TIME_DELAY = 1;  // int signal high time in us

reg [6:0]	cnt_100m;
reg [9:0]	cnt_us;  //maxinum in 1024 us
reg			state;
reg 		int_pulse_r;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        cnt_100m  <= 7'h0;
        cnt_us    <= 10'd0;
        int_pulse_r <= 1'b0;
        state     <= 1'b0;
    end else begin
        case (state)
            1'b0: begin
                if (pulse_start) begin
                    cnt_100m  <= 7'h0;
                    cnt_us    <= 10'd0;
                    int_pulse_r <= 1'b0;
                    state     <= 1'b1;
                end else begin
                    cnt_100m  <= 7'h0;
                    cnt_us    <= 10'd0;
                    int_pulse_r <= 1'b0;
                    state     <= 1'b0;
                end
            end
            1'b1: begin
                int_pulse_r <= 1'b1;
                if (cnt_100m == CLK_FREQ) begin
                    if (cnt_us == TIME_DELAY - 1) begin
                        cnt_100m <= 7'h0;
                        cnt_us   <= 10'd0;
                        state    <= 1'b0;
                    end else begin
                        cnt_100m <= 7'h0;
                        cnt_us   <= cnt_us + 10'd1;
                    end
                end else begin
                    cnt_100m <= cnt_100m + 1;
                end
            end
            default: begin
                state <= 1'b0;
            end
        endcase
    end
end

assign int_pulse = int_pulse_r;

endmodule
