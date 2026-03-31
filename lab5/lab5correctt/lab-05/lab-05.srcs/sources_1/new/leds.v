`timescale 1ns / 1ps

module leds(
    input sys_clk,
    input sys_rst,
    input [15:0] btn_in,
    input [31:0] wr_data,
    input wr_en,
    input rd_en,
    input [29:0] addr,
    input [15:0] sw_in,
    output reg [31:0] rd_out
);
    /* on reset clear output, otherwise pass switches through */
    always @(posedge sys_clk or posedge sys_rst) begin
        if (sys_rst)
            rd_out <= 32'd0;
        else
            rd_out <= {16'h0000, sw_in};
    end
endmodule