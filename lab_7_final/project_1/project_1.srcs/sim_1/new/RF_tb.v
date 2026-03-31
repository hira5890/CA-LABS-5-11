`timescale 1ns / 1ps

module register_file_tb;

reg clk;
reg rst;
reg WriteEnable;
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;
reg [31:0] WriteData;

wire [31:0] ReadData1;
wire [31:0] ReadData2;
wire [31:0] RdData;   // added to match module

// Instantiate DUT
RegisterFile uut (
    .clk(clk),
    .rst(rst),
    .RegWrite(WriteEnable),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .WriteData(WriteData),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .RdData(RdData)
);

// Clock generation (10ns period)
always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;
    WriteEnable = 0;
    rs1 = 0;
    rs2 = 0;
    rd  = 0;
    WriteData = 0;

    // -----------------------------
    // Test v: Reset behavior
    // -----------------------------
    #10;
    rst = 0;

    // -----------------------------
    // Test i: Write x5 = 0xDEADBEEF
    // -----------------------------
    rd = 5;
    WriteData = 32'hDEADBEEF;
    WriteEnable = 1;

    @(posedge clk);
    WriteEnable = 0;

    rs1 = 5;
    #1;

    // -----------------------------
    // Test ii: Attempt write to x0
    // -----------------------------
    @(posedge clk);
    WriteEnable = 1;
    rd = 0;
    WriteData = 32'hFFFFFFFF;

    @(posedge clk);
    WriteEnable = 0;

    rs1 = 0;
    #1;

    // -----------------------------
    // Test iii: Simultaneous reads
    // -----------------------------
    @(posedge clk);
    WriteEnable = 1;
    rd = 10;
    WriteData = 32'hAAAA5555;

    @(posedge clk);
    WriteEnable = 0;

    rs1 = 5;
    rs2 = 10;
    #1;

    // -----------------------------
    // Test iv: Overwrite register
    // -----------------------------
    @(posedge clk);
    WriteEnable = 1;
    rd = 5;
    WriteData = 32'h12345678;

    @(posedge clk);
    WriteEnable = 0;

    rs1 = 5;
    #1;

    // -----------------------------
    // Test v (again): Reset clears registers
    // -----------------------------
    @(posedge clk);
    rst = 0;

    rs1 = 5;
    #1;

    #20;
    rst = 1;

    #10;
    $finish;

end

endmodule
