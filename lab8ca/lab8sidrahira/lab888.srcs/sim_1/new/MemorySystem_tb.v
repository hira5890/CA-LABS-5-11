`timescale 1ns/1ps
module MemorySystem_tb;

reg clk;
reg rst;
reg [15:0] switches;
wire [5:0] leds;

addressDecoderTop DUT(
    clk,
    rst,
    switches,
    leds
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
    rst = 0;
    switches = 16'b0;
    
    // reset first
    #10
    rst = 1;
    #10
    rst = 0;
    
    // ========================
    // TEST 1: Write to LEDs
    // SW8=1 (LED device)
    // SW7=1 (writeEnable)
    // SW0,SW1,SW2 = data
    // ========================
    #10
    switches = 16'b0000001000000111;
    //               SW8=1  SW0,SW1,SW2=1
    #10
    switches[7] = 1; // writeEnable
    #10
    switches[7] = 0; // turn off write
    #10
    $display("TEST 1 - LED Write: leds = %b (expected 000111)", leds);
    
    // ========================
    // TEST 2: Read Switches
    // SW9=1 (Switch device)
    // SW6=1 (readEnable)
    // SW0,SW2,SW4 = data
    // ========================
    #10
    rst = 1; #10 rst = 0; // reset
    #10
    switches = 16'b0000001000010101;
    //               SW9=1  SW4,SW2,SW0=1
    #10
    switches[6] = 1; // readEnable
    #10
    $display("TEST 2 - Switch Read: leds = %b (expected 010101)", leds);
    switches[6] = 0;
    
    // ========================
    // TEST 3: Write to Memory
    // SW9=0, SW8=0 (Memory device)
    // SW7=1 (writeEnable)
    // SW0,SW1,SW2 = data = 000111
    // ========================
    #10
    rst = 1; #10 rst = 0; // reset
    #10
    switches = 16'b0000000000000111;
    //           all 0  SW0,SW1,SW2=1
    #10
    switches[7] = 1; // writeEnable
    #10
    switches[7] = 0; // turn off write
    $display("TEST 3 - Memory Write: nothing on leds = %b (expected 000000)", leds);
    
    // ========================
    // TEST 4: Read from Memory
    // Change switches data
    // SW6=1 (readEnable)
    // Should show original value!
    // ========================
    #10
    switches[2:0] = 3'b000; // change data
    #10
    switches[6] = 1; // readEnable
    #10
    $display("TEST 4 - Memory Read: leds = %b (expected 000111)", leds);
    switches[6] = 0;
    
    #20
    $stop;
end

endmodule


