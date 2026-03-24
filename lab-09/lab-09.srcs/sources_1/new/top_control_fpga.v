// =============================================================================
// Module      : top_control_fpga
// Description : Top-level FPGA test harness for verifying MainControl and
//               ALUControl modules.  Three successive button presses load
//               opcode (sw[6:0]), funct3 (sw[2:0]), and funct7 (sw[6:0])
//               from the slide switches; control signals are then shown on
//               the LEDs.
//
// LED mapping (15 ? 0)
//   [15:12]  ALU Control output  (4 bits)
//   [11]     ALUOp[1]
//   [10]     ALUOp[0]
//   [9]      Branch
//   [8]      MemtoReg
//   [7]      MemWrite
//   [6]      MemRead
//   [5]      ALUSrc
//   [4]      RegWrite
//   [3:2]    unused (tied 0)
//   [1:0]    FSM state
// =============================================================================

`timescale 1ns / 1ps

module top_control_fpga (
    input        clk,          // System clock
    input        rst,          // Active-high synchronous reset
    input        btnC,         // Centre button - advances FSM on each press
    input  [15:0] sw,          // Slide switches (only lower bits used)
    output [15:0] led          // LED outputs (see mapping above)
);

    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------

    // FSM state register - 4 states: load opcode ? funct3 ? funct7 ? observe
    reg [1:0] input_load_state;

    // Instruction-field registers loaded from switches
    reg [6:0] opcode_reg;       // Loaded in state 0
    reg [2:0] funct3_reg;       // Loaded in state 1
    reg [6:0] funct7_reg;       // Loaded in state 2

    // Switch interface read-data bus (32-bit, lower 7/3 bits used)
    wire [31:0] switch_data_out;

    // MainControl output signals
    wire        ctrl_RegWrite;
    wire [1:0]  ctrl_ALUOp;
    wire        ctrl_MemRead;
    wire        ctrl_MemWrite;
    wire        ctrl_ALUSrc;
    wire        ctrl_MemtoReg;
    wire        ctrl_Branch;

    // ALUControl output
    wire [3:0]  alu_ctrl_out;

    // Button edge-detection
    reg  btn_prev;              // Previous-cycle value of btnC
    wire btn_single_pulse;      // Single-cycle high pulse on rising edge of btnC

    // Rising-edge detector: pulse goes high for exactly one clock cycle
    assign btn_single_pulse = btnC & ~btn_prev;

    // -------------------------------------------------------------------------
    // Switch interface instantiation
    // Reads the physical slide-switch state into a 32-bit data word.
    // Write path is disabled (writeEnable = 0); read path is always enabled.
    // -------------------------------------------------------------------------
    switches sw_if (
        .clk         (clk),
        .rst         (rst),
        .writeData   (32'b0),      // Not writing - tied to zero
        .writeEnable (1'b0),       // Write disabled
        .readEnable  (1'b1),       // Read always enabled
        .memAddress  (30'b0),      // Address not used for switch reads
        .sw          (sw),
        .readData    (switch_data_out),
        .leds        ()            // LED output from switch module (unused here)
    );

    // -------------------------------------------------------------------------
    // Button edge-detection flip-flop
    // Samples btnC every clock so we can detect the rising edge.
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            btn_prev <= 1'b0;
        else
            btn_prev <= btnC;
    end

    // -------------------------------------------------------------------------
    // Input-loading FSM
    // State 00 ? capture opcode  (sw[6:0])
    // State 01 ? capture funct3  (sw[2:0])
    // State 10 ? capture funct7  (sw[6:0])
    // State 11 ? hold / observe outputs (no more captures)
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            input_load_state <= 2'b00;
            opcode_reg       <= 7'b0;
            funct3_reg       <= 3'b0;
            funct7_reg       <= 7'b0;
        end
        else if (btn_single_pulse) begin
            case (input_load_state)

                // --- State 0: Capture opcode from switches [6:0] -------------
                2'b00: begin
                    opcode_reg       <= switch_data_out[6:0];
                    input_load_state <= 2'b01;
                end

                // --- State 1: Capture funct3 from switches [2:0] -------------
                2'b01: begin
                    funct3_reg       <= switch_data_out[2:0];
                    input_load_state <= 2'b10;
                end

                // --- State 2: Capture funct7 from switches [6:0] -------------
                2'b10: begin
                    funct7_reg       <= switch_data_out[6:0];
                    input_load_state <= 2'b11;
                end

                // --- State 3: Observe outputs - remain here indefinitely -----
                2'b11: begin
                    input_load_state <= 2'b11;  // Self-loop; outputs stable
                end

            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Main Control unit instantiation
    // Decodes the opcode to produce datapath control signals.
    // -------------------------------------------------------------------------
    MainControl mc (
        .opcode   (opcode_reg),
        .RegWrite (ctrl_RegWrite),
        .ALUOp    (ctrl_ALUOp),
        .MemRead  (ctrl_MemRead),
        .MemWrite (ctrl_MemWrite),
        .ALUSrc   (ctrl_ALUSrc),
        .MemtoReg (ctrl_MemtoReg),
        .Branch   (ctrl_Branch)
    );

    // -------------------------------------------------------------------------
    // ALU Control unit instantiation
    // Combines ALUOp, funct3, funct7 (and opcode for SUB disambiguation)
    // to produce the 4-bit ALU operation code.
    // -------------------------------------------------------------------------
    ALUControl alu_ctrl (
        .opcode     (opcode_reg),
        .ALUOp      (ctrl_ALUOp),
        .funct3     (funct3_reg),
        .funct7     (funct7_reg),
        .ALUControl (alu_ctrl_out)
    );

    // -------------------------------------------------------------------------
    // LED output assignments
    // -------------------------------------------------------------------------
    assign led[15:12] = alu_ctrl_out;   // 4-bit ALU control code
    assign led[11]    = ctrl_ALUOp[1];  // ALUOp MSB
    assign led[10]    = ctrl_ALUOp[0];  // ALUOp LSB
    assign led[9]     = ctrl_Branch;    // Branch control
    assign led[8]     = ctrl_MemtoReg;  // Memory-to-register mux select
    assign led[7]     = ctrl_MemWrite;  // Memory write enable
    assign led[6]     = ctrl_MemRead;   // Memory read enable
    assign led[5]     = ctrl_ALUSrc;    // ALU source mux (0 = reg, 1 = imm)
    assign led[4]     = ctrl_RegWrite;  // Register file write enable
    assign led[3:2]   = 2'b00;          // Reserved / unused
    assign led[1:0]   = input_load_state; // Current FSM state for debug

endmodule