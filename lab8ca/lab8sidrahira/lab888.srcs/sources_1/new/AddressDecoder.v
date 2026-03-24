`timescale 1ns / 1ps
module AddressDecoder(
    input [31:0] address,
    input readEnable,
    input writeEnable,

    output reg DataMemWrite,
    output reg DataMemRead,
    output reg LEDWrite,
    output reg SwitchReadEnable
);

always @(*)
begin

    DataMemWrite = 0;
    DataMemRead = 0;
    LEDWrite = 0;
    SwitchReadEnable = 0;

    case(address[9:8])

        2'b00:
        begin
            DataMemWrite = writeEnable;
            DataMemRead  = readEnable;
        end

        2'b01:
        begin
            LEDWrite = writeEnable;
        end

        2'b10:
        begin
            SwitchReadEnable = readEnable;
        end

    endcase

end

endmodule