`timescale 1ns / 1ps
module switches(
    input clk,
    input rst,
    input readEnable,         // optional, only update output when high
    input [3:0] physicalSW,   // 4 physical FPGA switches
   
    output reg [3:0] ALUctl   // output to ALU
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUctl <= 4'b0000;
        end else if (readEnable) begin
            ALUctl <= physicalSW; // map switches to ALU control
        end
    end

endmodule