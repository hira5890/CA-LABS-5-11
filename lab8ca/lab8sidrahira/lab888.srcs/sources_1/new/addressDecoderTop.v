`timescale 1ns / 1ps
module addressDecoderTop(
    input clk,
    input rst,
    input [15:0] switches,
    output [5:0] leds
);

wire [9:0] address;
assign address = {switches[9], switches[8], 8'd10};

wire writeEnable = switches[7];
wire readEnable  = switches[6];

wire DataMemWrite, DataMemRead;
wire LEDWrite, SwitchReadEnable;
wire [5:0] memReadData;
wire [5:0] switchReadData;
wire [5:0] ledData;
wire [5:0] readData;

AddressDecoder decoder(
    address,
    readEnable,
    writeEnable,
    DataMemWrite,
    DataMemRead,
    LEDWrite,
    SwitchReadEnable
);

DataMemory memory(
    clk,
    DataMemWrite,
    DataMemRead,
    address[7:0],
    switches[5:0],
    memReadData
);

LEDInterface led(
    clk,
    rst,
    LEDWrite,
    switches[5:0],
    ledData
);

SwitchInterface sw(
    SwitchReadEnable,
    switches[5:0],
    switchReadData
);

assign readData = (address[9:8] == 2'b00) ? memReadData :
                  (address[9:8] == 2'b10) ? switchReadData :
                  6'b0;

assign leds = (address[9:8] == 2'b01) ? ledData : readData;

endmodule