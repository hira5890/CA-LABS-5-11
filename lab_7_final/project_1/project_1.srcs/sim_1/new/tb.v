`timescale 1ns / 1ps

module RF_ALU_FSM_tb;

    // Clock & reset
    reg clk;
    reg rst;

    // FSM state tracking
    reg [3:0] current_state;

    // Register File signals
    reg rf_write_enable;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] rf_write_data;
    wire [31:0] rf_read_data1, rf_read_data2;

    // ALU signals
    reg [3:0] ALUctl;
    wire [31:0] ALUout;
    wire Zero;

    // Internal flag for BEQ test
    reg beq_flag;

    //----------------------------------------
    // Instantiate Register File
    //----------------------------------------
    RegisterFile RF(
        .clk(clk),
        .rst(rst),
        .RegWrite(rf_write_enable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(rf_write_data),
        .ReadData1(rf_read_data1),
        .ReadData2(rf_read_data2),
        .RdData() // unused
    );

    //----------------------------------------
    // Instantiate ALU
    //----------------------------------------
    ALU ALU_inst(
        .ALUctl(ALUctl),
        .A(rf_read_data1),
        .B(rf_read_data2),
        .ALUout(ALUout),
        .Zero(Zero)
    );

    //----------------------------------------
    // Clock generation
    //----------------------------------------
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

    //----------------------------------------
    // FSM states
    //----------------------------------------
    localparam IDLE        = 4'd0,
               WRITE_CONST = 4'd1,
               ALU_OPS     = 4'd2,
               BEQ_CHECK   = 4'd3,
               READ_AFTER  = 4'd4,
               DONE        = 4'd5;

    //----------------------------------------
    // Testbench FSM
    //----------------------------------------
    initial begin
        rst = 1;
        rf_write_enable = 0;
        rs1 = 0; rs2 = 0; rd = 0;
        rf_write_data = 0;
        ALUctl = 0;
        beq_flag = 0;

        #20;
        rst = 0;
        current_state = IDLE;

        //----------------------------------------
        // FSM sequence
        //----------------------------------------
        forever begin
            @(posedge clk);
            case(current_state)

                IDLE: begin
                    // move to write constants
                    current_state <= WRITE_CONST;
                end

                WRITE_CONST: begin
                    // Write known constants
                    rf_write_enable = 1;
                    rd = 5'd1; rf_write_data = 32'h10101010; @(posedge clk);
                    rd = 5'd2; rf_write_data = 32'h01010101; @(posedge clk);
                    rd = 5'd3; rf_write_data = 32'h00000005; @(posedge clk);
                    rf_write_enable = 0;
                    current_state <= ALU_OPS;
                end

                ALU_OPS: begin
                    // Perform ALU ops and write results to x4..x10
                    // ADD
                    rs1 = 5'd1; rs2 = 5'd2; ALUctl = 4'b0010; rd = 5'd4; @(posedge clk);
                    rf_write_enable = 1; rf_write_data = ALUout; @(posedge clk); rf_write_enable = 0;

                    // SUB
                    ALUctl = 4'b0110; rd = 5'd5; rf_write_enable = 1; rf_write_data = ALUout; @(posedge clk); rf_write_enable = 0;

                    // AND
                    ALUctl = 4'b0000; rd = 5'd6; rf_write_enable = 1; rf_write_data = ALUout; @(posedge clk); rf_write_enable = 0;

                    // OR
                    ALUctl = 4'b0001; rd = 5'd7; rf_write_enable = 1; rf_write_data = ALUout; @(posedge clk); rf_write_enable = 0;

                    // XOR
                    ALUctl = 4'b1010; rd = 5'd8; rf_write_enable = 1; rf_write_data = ALUout; @(posedge clk); rf_write_enable = 0;

                    // SLL
                    ALUctl = 4'b1000; rd = 5'd9; rf_write_enable = 1; rf_write_data = ALUout; @(posedge clk); rf_write_enable = 0;

                    // SRL
                    ALUctl = 4'b1001; rd = 5'd10; rf_write_enable = 1; rf_write_data = ALUout; @(posedge clk); rf_write_enable = 0;

                    current_state <= BEQ_CHECK;
                end

                BEQ_CHECK: begin
                    // Example BEQ: check if x3 == 0
                    rs1 = 5'd3; rs2 = 5'd3; ALUctl = 4'b0110; // SUB x3 - x3
                    @(posedge clk);
                    if(Zero) begin
                        rd = 5'd31; rf_write_enable = 1; rf_write_data = 32'h1; @(posedge clk); rf_write_enable = 0;
                        beq_flag = 1;
                    end
                    current_state <= READ_AFTER;
                end

                READ_AFTER: begin
                    // Test read-after-write
                    rd = 5'd11; rf_write_enable = 1; rf_write_data = 32'hA5A5A5A5; @(posedge clk);
                    rf_write_enable = 0;
                    rs1 = 5'd11; @(posedge clk); // read x11
                    current_state <= DONE;
                end

                DONE: begin
                    $display("Simulation finished.");
                    $stop;
                end

                default: current_state <= IDLE;
            endcase
        end
    end

    //----------------------------------------
    // Monitoring for waveforms
    //----------------------------------------
    initial begin
        $display("Time | State | ALUctl | ALUout | Zero | x1 | x2 | x3 | x4 | x31 | x11");
        $monitor("%0t | %b   | %b    | %h  | %b   | %h | %h | %h | %h | %h | %h",
            $time,
            current_state,
            ALUctl,
            ALUout,
            Zero,
            RF.register_bank[1],
            RF.register_bank[2],
            RF.register_bank[3],
            RF.register_bank[4],
            RF.register_bank[31],
            RF.register_bank[11]
        );
    end

endmodule