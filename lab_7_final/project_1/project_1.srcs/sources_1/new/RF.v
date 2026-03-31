`timescale 1ns / 1ps

// =======================================================
// 32x32 Register File
// x0 always reads as zero
// =======================================================

module RegisterFile (
    input clk,
    input rst,
    input RegWrite,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] WriteData,
    output [31:0] ReadData1,
    output [31:0] ReadData2,
    output [31:0] RdData
);

    // Register storage array
    reg [31:0] register_bank [31:0];

    integer index;

    // Reset registers or perform write
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            for (index = 0; index < 32; index = index + 1)
                register_bank[index] <= 32'b0;
        end

        else if (RegWrite && (rd != 5'd0)) begin
            register_bank[rd] <= WriteData; //use non blocking statemetns as said by RA
        end

    end
    // Read ports
    assign ReadData1 = (rs1 == 5'd0) ? 32'b0 : register_bank[rs1]; //assignments
    assign ReadData2 = (rs2 == 5'd0) ? 32'b0 : register_bank[rs2];
    
    assign RdData    = (rd  == 5'd0) ? 32'b0 : register_bank[rd];

endmodule