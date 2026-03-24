// =============================================================================
// Module      : MainControl
// Description : RISC-V main control unit.  Decodes the 7-bit instruction
//               opcode and asserts the appropriate datapath control signals
//               for the five instruction classes supported:
//
//               Opcode        Class          Signals driven
//               ?????????????????????????????????????????????????????????????
//               0110011       R-type         RegWrite, ALUOp=10, ALUSrc=0
//               0010011       I-type (ALU)   RegWrite, ALUOp=10, ALUSrc=1
//               0000011       Load           RegWrite, MemRead, ALUSrc=1,
//                                            MemtoReg, ALUOp=00
//               0100011       Store          MemWrite, ALUSrc=1, ALUOp=00
//               1100011       Branch (BEQ)   Branch, ALUOp=01
//
// Outputs default to 0 for any unsupported opcode.
// =============================================================================

`timescale 1ns / 1ps

module MainControl (
    input  [6:0] opcode,        // 7-bit opcode field from the instruction

    // --- Datapath control outputs -------------------------------------------
    output reg        RegWrite, // 1 ? write result back to register file
    output reg [1:0]  ALUOp,    // ALU operation selector for ALUControl unit
    output reg        MemRead,  // 1 ? enable data-memory read
    output reg        MemWrite, // 1 ? enable data-memory write
    output reg        ALUSrc,   // 0 ? ALU src B = register; 1 ? immediate
    output reg        MemtoReg, // 0 ? WB data = ALU result; 1 ? memory data
    output reg        Branch    // 1 ? this is a branch instruction
);

    // -------------------------------------------------------------------------
    // Combinational decode block
    // All outputs are set to safe defaults at the top of every evaluation
    // so that partial case matches never leave outputs undefined.
    // -------------------------------------------------------------------------
    always @(*) begin

        // --- Safe / idle defaults --------------------------------------------
        RegWrite = 1'b0;
        ALUOp    = 2'b00;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;

        case (opcode)

            // -----------------------------------------------------------------
            // R-type instructions: ADD, SUB, SLL, SRL, AND, OR, XOR
            //   funct3 / funct7 further decoded inside ALUControl
            // -----------------------------------------------------------------
            7'b0110011: begin
                RegWrite = 1'b1;    // Result written to rd
                ALUOp    = 2'b10;   // ALUControl will use funct3/funct7
                ALUSrc   = 1'b0;    // Second ALU operand from register file
                MemtoReg = 1'b0;    // Write-back from ALU, not memory
            end

            // -----------------------------------------------------------------
            // I-type ALU instructions: ADDI (and other immediate ALU ops)
            //   Immediate is sign-extended and fed to ALU src B
            // -----------------------------------------------------------------
            7'b0010011: begin
                RegWrite = 1'b1;    // Result written to rd
                ALUOp    = 2'b10;   // ALUControl will use funct3
                ALUSrc   = 1'b1;    // Second ALU operand from sign-ext imm
                MemtoReg = 1'b0;    // Write-back from ALU, not memory
            end

            // -----------------------------------------------------------------
            // Load instructions: LW, LH, LB
            //   ALU computes base + offset; result used as memory address
            // -----------------------------------------------------------------
            7'b0000011: begin
                RegWrite = 1'b1;    // Loaded value written to rd
                ALUOp    = 2'b00;   // ADD for effective-address calculation
                MemRead  = 1'b1;    // Enable data-memory read
                ALUSrc   = 1'b1;    // Offset immediate to ALU src B
                MemtoReg = 1'b1;    // Write-back from memory, not ALU
            end

            // -----------------------------------------------------------------
            // Store instructions: SW, SH, SB
            //   ALU computes base + offset; rs2 written to that address
            // -----------------------------------------------------------------
            7'b0100011: begin
                RegWrite = 1'b0;    // No register write for stores
                ALUOp    = 2'b00;   // ADD for effective-address calculation
                MemWrite = 1'b1;    // Enable data-memory write
                ALUSrc   = 1'b1;    // Offset immediate to ALU src B
            end

            // -----------------------------------------------------------------
            // Branch instructions: BEQ
            //   ALU subtracts rs1 - rs2; zero flag used to decide branch
            // -----------------------------------------------------------------
            7'b1100011: begin
                RegWrite = 1'b0;    // No register write for branches
                ALUOp    = 2'b01;   // ALUControl will output SUB (0110)
                Branch   = 1'b1;    // Signal the PC mux to consider branching
                ALUSrc   = 1'b0;    // Second ALU operand from register file
            end

            // -----------------------------------------------------------------
            // Default: unsupported opcode - all outputs remain at safe defaults
            // -----------------------------------------------------------------
            default: begin
                /* No action needed; defaults set above are already safe */
            end

        endcase
    end

endmodule