`timescale 1ns / 1ps

// =======================================================
// TOP MODULE
// Connects FSM + Register File + ALU + Seven Segment
// Functionality unchanged - only internal names improved
// =======================================================

module RF_ALU_TOP(
    input clk,
    input rst,
    input [15:0] sw,
    output [15:0] LED,
    output [3:0] an,
    output [6:0] seg
);

    // -------- Control signals from FSM --------
    wire [3:0] alu_ctrl_sig;
    wire reg_write_sig;
    wire [1:0] alu_src_sel;

    wire [4:0] reg_rs1_addr;
    wire [4:0] reg_rs2_addr;
    wire [4:0] reg_rd_addr;

    wire [31:0] const_input_data;

    wire [3:0] fsm_state_signal;
    wire display_read_mode;

    // -------- Data signals --------
    wire [31:0] alu_result_bus;
    wire zero_flag_signal;

    wire [31:0] rf_read_data1;
    wire [31:0] rf_read_data2;
    wire [31:0] rf_rd_display_data;

    // Value written into register file
    wire [31:0] rf_write_data;
    assign rf_write_data = (alu_src_sel == 1) ? const_input_data : alu_result_bus;

    // Data sent to LEDs and 7-seg
    wire [31:0] display_data_bus;
    assign display_data_bus = display_read_mode ? rf_rd_display_data : alu_result_bus;

    // -------- LED mapping --------
    assign LED[15:12] = fsm_state_signal;
    assign LED[11]    = zero_flag_signal;
    assign LED[10:0]  = display_data_bus[10:0];

    // ================= FSM =================
    FSM fsm_inst(
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .Zero(zero_flag_signal),

        .ALUctl(alu_ctrl_sig),
        .RegWrite(reg_write_sig),

        .rs1(reg_rs1_addr),
        .rs2(reg_rs2_addr),
        .rd(reg_rd_addr),

        .ALUSrc(alu_src_sel),
        .ConstData(const_input_data),

        .state_out(fsm_state_signal),
        .read_mode(display_read_mode)
    );

    // ================= Register File =================
    RegisterFile rf_inst(
        .clk(clk),
        .rst(rst),
        .RegWrite(reg_write_sig),

        .rs1(reg_rs1_addr),
        .rs2(reg_rs2_addr),
        .rd(reg_rd_addr),

        .WriteData(rf_write_data),

        .ReadData1(rf_read_data1),
        .ReadData2(rf_read_data2),
        .RdData(rf_rd_display_data)
    );

    // ================= ALU =================
    ALU alu_inst(
        .ALUctl(alu_ctrl_sig),
        .A(rf_read_data1),
        .B(rf_read_data2),

        .ALUout(alu_result_bus),
        .Zero(zero_flag_signal)
    );

    // ================= 7-Segment =================
    sevenseg_basys3 sseg_inst(
        .clk(clk),
        .rst(rst),

        .value(display_data_bus[15:0]),
        .seg(seg),
        .an(an)
    );

endmodule