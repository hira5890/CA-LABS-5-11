`timescale 1ns/1ps
module tb_lab5;

    /* inputs as regs */
    reg sys_clk;
    reg reset_btn;
    reg [15:0] sw_input;

    /* outputs as wires */
    wire [15:0] leds_out;

    /* instantiate DUT */
    lab5_top dut (
        .sys_clk(sys_clk),
        .rst_btn(reset_btn),
        .sw_phys(sw_input),
        .led_phys(leds_out)
    );

    /* 100 MHz clock - toggle every 5ns */
    always #5 sys_clk = ~sys_clk;

    initial begin
        sys_clk   = 1'b0;
        reset_btn = 1'b1;
        sw_input  = 16'd0;

        /* release reset after 20ns */
        #20 reset_btn = 1'b0;

        /* test 1: load value 10 */
        #10 sw_input = 16'd10;
        #150;

        /* test 2: reset mid-count */
        reset_btn = 1'b1;
        #10 reset_btn = 1'b0;

        /* test 3: load value 5 */
        #10 sw_input = 16'd5;
        #100;

        $finish;
    end

endmodule