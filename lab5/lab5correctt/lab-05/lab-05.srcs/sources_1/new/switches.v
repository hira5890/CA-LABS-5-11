`timescale 1ns / 1ps

module switches(
    input sys_clk,
    input sys_rst,
    input [31:0] wr_data,
    input wr_en,
    input rd_en,
    input [29:0] addr,
    output reg [31:0] rd_out = 0, // not used for reading
    output reg [15:0] led_out
);
endmodule