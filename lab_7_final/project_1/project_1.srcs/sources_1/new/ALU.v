`timescale 1ns / 1ps

// =======================================================
// Arithmetic Logic Unit
// Performs logical and arithmetic operations
// =======================================================

module ALU(

    input  [3:0] ALUctl,
    input  [31:0] A,
    input  [31:0] B,

    output reg [31:0] ALUout,
    output Zero
);

assign Zero = (ALUout == 0);

// ALU operation selection
always @(*) begin

    case (ALUctl)

        4'b0000: ALUout <= A & B;             // AND
        4'b0001: ALUout <= A | B;             // OR
        4'b0010: ALUout <= A + B;             // ADD
        4'b0110: ALUout <= A - B;             // SUBTRACT
        4'b0111: ALUout <= (A < B) ? 1 : 0;   // SLT
        4'b1100: ALUout <= ~(A | B);          // NOR

        4'b1000: ALUout <= A << B[4:0];       // SLL
        4'b1001: ALUout <= A >> B[4:0];       // SRL

        4'b1010: ALUout <= A ^ B;             // XOR

        default: ALUout <= 32'b0;

    endcase

end

endmodule