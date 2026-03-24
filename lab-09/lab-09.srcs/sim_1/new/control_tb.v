`timescale 1ns / 1ps

module control_tb;

    // =========================================================================
    // Stimulus registers
    // =========================================================================
    reg [6:0] opcode;   // 7-bit opcode field
    reg [2:0] funct3;   // 3-bit funct3 field
    reg [6:0] funct7;   // 7-bit funct7 field

    // =========================================================================
    // MainControl output wires
    // =========================================================================
    wire        RegWrite;
    wire [1:0]  ALUOp;
    wire        MemRead;
    wire        MemWrite;
    wire        ALUSrc;
    wire        MemtoReg;
    wire        Branch;

    // =========================================================================
    // ALUControl output wire
    // =========================================================================
    wire [3:0]  ALUControl;

    // =========================================================================
    // MainControl instantiation
    // =========================================================================
    MainControl mc (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );

    // =========================================================================
    // ALUControl instantiation
    // =========================================================================
    ALUControl alu_ctrl (
        .opcode     (opcode),
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    // =========================================================================
    // Stimulus: apply inputs and display outputs
    // =========================================================================
    initial begin
        $dumpfile("control_tb.vcd");
        $dumpvars(0, control_tb);

        $display("Instr | opcode  funct3 funct7 | RegWrite ALUOp MemRead MemWrite ALUSrc MemtoReg Branch ALUControl");
        $display("-------------------------------------------------------------------------------");

        // R-type instructions
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD   | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000; #10;
        $display("SUB   | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0110011; funct3 = 3'b001; funct7 = 7'b0000000; #10;
        $display("SLL   | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0110011; funct3 = 3'b101; funct7 = 7'b0000000; #10;
        $display("SRL   | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0110011; funct3 = 3'b111; funct7 = 7'b0000000; #10;
        $display("AND   | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0110011; funct3 = 3'b110; funct7 = 7'b0000000; #10;
        $display("OR    | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0110011; funct3 = 3'b100; funct7 = 7'b0000000; #10;
        $display("XOR   | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        // I-type
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADDI  | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        // LOAD
        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        $display("LW    | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0000011; funct3 = 3'b001; funct7 = 7'b0000000; #10;
        $display("LH    | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0000011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("LB    | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        // STORE
        opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        $display("SW    | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0100011; funct3 = 3'b001; funct7 = 7'b0000000; #10;
        $display("SH    | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        opcode = 7'b0100011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("SB    | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        // BRANCH
        opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("BEQ   | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        // UNKNOWN opcode (default case)
        opcode = 7'b1111111; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("UNK   | %b %b %b | %b %b %b %b %b %b %b %b", opcode, funct3, funct7, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch, ALUControl);

        $finish;
    end

endmodule