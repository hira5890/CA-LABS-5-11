`timescale 1ns / 1ps
module SwitchInterface(
    input SwitchReadEnable,
    input [5:0] switches,
    output reg [5:0] readData
);
always @(*) begin
    if (SwitchReadEnable)
        readData = switches;
    else
        readData = 6'b0;
end
endmodule