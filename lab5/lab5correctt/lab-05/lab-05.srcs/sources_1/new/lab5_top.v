module lab5_top(
    input sys_clk,
    input rst_btn,
    input [15:0] sw_phys,
    output [15:0] led_phys,
    output [6:0] seg,
    output [3:0] an
);
    /* internal wires */
    wire rst_clean;
    wire [15:0] cnt_val;

    debouncer db_inst(
        .clk(sys_clk),
        .pbin(rst_btn),
        .pbout(rst_clean)
    );

    fsm_counter cnt_inst(
        .clk(sys_clk),
        .rst(rst_clean),
        .sw_val(sw_phys),
        .count_reg(cnt_val)
    );

    sevenseg_basys3 seg_inst(
        .sys_clk(sys_clk),
        .sys_rst(rst_clean),
        .val_in(cnt_val),
        .seg(seg),
        .an(an)
    );

    assign led_phys = cnt_val;
endmodule