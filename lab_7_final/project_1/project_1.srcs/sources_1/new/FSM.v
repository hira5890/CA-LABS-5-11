`timescale 1ns / 1ps

// =======================================================
// FSM Controller
// Controls loading registers, selecting ALU operations,
// reading registers, and writing results
// Functionality unchanged - only internal names improved
// =======================================================

module FSM(
    input              clk,
    input              rst,
    input      [15:0]  sw,
    input              Zero,

    output reg [3:0]   ALUctl,
    output reg         RegWrite,

    output reg [4:0]   rs1,
    output reg [4:0]   rs2,
    output reg [4:0]   rd,

    output reg [1:0]   ALUSrc,
    output reg [31:0]  ConstData,

    output     [3:0]   state_out,
    output reg         read_mode
);

    // Current FSM state
    reg [3:0] current_state;

    // Expose state to top module
    assign state_out = current_state;

    // Stored register addresses
    reg [4:0] saved_rs1_addr;
    reg [4:0] saved_rs2_addr;

    // FSM state definitions
    localparam ST_INIT      = 4'd0;
    localparam ST_LOAD_A    = 4'd1;
    localparam ST_LOAD_B    = 4'd2;
    localparam ST_OP_SELECT = 4'd3;
    localparam ST_READ      = 4'd4;
    localparam ST_WRITE     = 4'd5;


    // ===================================================
    // STATE TRANSITION LOGIC
    // ===================================================
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            current_state <= ST_INIT;
            saved_rs1_addr <= 5'd0;
            saved_rs2_addr <= 5'd0;
        end

        else begin

            case (current_state)

                // Wait until all switches are off
                ST_INIT: begin
                    if (sw == 16'b0)
                        current_state <= ST_LOAD_A;
                end

                // Load register A index
                ST_LOAD_A: begin
                    if (sw[4] && !sw[5]) begin
                        saved_rs1_addr <= sw[11:7];
                        current_state  <= ST_LOAD_B;
                    end
                end

                // Load register B index
                ST_LOAD_B: begin
                    if (sw[5] && !sw[4]) begin
                        saved_rs2_addr <= sw[11:7];
                        current_state  <= ST_OP_SELECT;
                    end
                end

                // Choose ALU operation
                ST_OP_SELECT: begin
                    if (sw[15])
                        current_state <= ST_WRITE;
                    else if (sw[14])
                        current_state <= ST_READ;
                end

                // Read register values
                ST_READ: begin
                    if (sw[15])
                        current_state <= ST_WRITE;
                    else if (!sw[14])
                        current_state <= ST_OP_SELECT;
                end

                // Write ALU result
                ST_WRITE: begin
                    if (!sw[15]) begin
                        if (sw[14])
                            current_state <= ST_READ;
                        else
                            current_state <= ST_OP_SELECT;
                    end
                end

                default:
                    current_state <= ST_INIT;

            endcase
        end
    end


    // ===================================================
    // OUTPUT CONTROL LOGIC
    // ===================================================
    always @(*) begin

        // Default signal values
        ALUctl    = 4'b0000;
        RegWrite  = 1'b0;

        rs1       = saved_rs1_addr;
        rs2       = saved_rs2_addr;

        rd        = 5'd0;

        ALUSrc    = 2'd0;
        ConstData = 32'd0;

        read_mode = 1'b0;

        case (current_state)

            // Write constant value 3
            ST_LOAD_A: begin
                if (sw[4] && !sw[5]) begin
                    RegWrite  = 1'b1;
                    rd        = sw[11:7];
                    ALUSrc    = 2'd1;
                    ConstData = 32'd3;
                end
            end

            // Write constant value 0
            ST_LOAD_B: begin
                if (sw[5] && !sw[4]) begin
                    RegWrite  = 1'b1;
                    rd        = sw[11:7];
                    ALUSrc    = 2'd1;
                    ConstData = 32'd0;
                end
            end

            // Select ALU operation
            ST_OP_SELECT: begin
                ALUctl = sw[3:0];
                rd     = sw[11:7];
            end

            // Read register value
            ST_READ: begin
                ALUctl    = sw[3:0];
                rd        = sw[11:7];
                read_mode = 1'b1;
            end

            // Write ALU result to register
            ST_WRITE: begin
                ALUctl    = sw[3:0];
                rd        = sw[11:7];

                RegWrite  = 1'b1;
                ALUSrc    = 2'd0;

                read_mode = 1'b1;
            end

            default: ;

        endcase
    end

endmodule