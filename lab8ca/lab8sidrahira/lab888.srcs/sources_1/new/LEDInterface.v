`timescale 1ns / 1ps
module LEDInterface(
    input clk,
    input rst,
    input LEDWrite,
    input [5:0] writeData,
    output reg [5:0] leds
);
initial begin
    leds = 6'b0;
end
always @(posedge clk) begin
    if (rst)
        leds <= 6'b0;
    else if (LEDWrite)
        leds <= writeData;
end
endmodule