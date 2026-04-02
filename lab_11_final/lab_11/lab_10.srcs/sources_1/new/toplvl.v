// =============================================================================
// Module      : TopLevelProcessor
// Description : Single-cycle RISC-V processor top-level.
//               Instantiates and wires together:
//                 - ProgramCounter
//                 - pcAdder        (PC + 4)
//                 - InstructionMemory (assumed external / ROM, modelled here)
//                 - immGen
//                 - MainControl
//                 - register_file
//                 - mux2           (ALU src-B select)
//                 - ALUControl
//                 - RISCVALU
//                 - branchAdder    (PC + imm)
//                 - mux2           (PC next select)
//                 - AddressDecoder (memory-mapped I/O)
//                 - DataMemory
//                 - mux2           (write-back select)
//
// Data memory is 256 x 32-bit (1 KB), word-addressed via address[9:2].
//
// Instruction memory: uses external instructionMemory module (byte-addressed,
// little-endian, 256 bytes). PC connects directly as byte address.
// =============================================================================

`timescale 1ns / 1ps




// -----------------------------------------------------------------------------
// TopLevelProcessor
// -----------------------------------------------------------------------------
module TopLevelProcessor (
    input  wire        clk,
    input  wire        reset,

    // ---- Memory-mapped I/O ports (connect to board peripherals) ------------
    input  wire [5:0]  switch_in,   // Switch read data from outside
    output wire [5:0]  led_out,     // LED write data to outside
    output wire        led_write_en // Pulse high when LED register is written
);

    // =========================================================================
    // Internal wire declarations
    // =========================================================================

    // --- PC & fetch ----------------------------------------------------------
    wire [31:0] PC;
    wire [31:0] PC_Plus4;
    wire [31:0] PC_Next;
    wire [31:0] instruction;

    // --- Instruction fields --------------------------------------------------
    wire [6:0]  opcode  = instruction[6:0];
    wire [4:0]  rd      = instruction[11:7];
    wire [2:0]  funct3  = instruction[14:12];
    wire [4:0]  rs1     = instruction[19:15];
    wire [4:0]  rs2     = instruction[24:20];
    wire [6:0]  funct7  = instruction[31:25];

    // --- Control signals -----------------------------------------------------
    wire        RegWrite;
    wire [1:0]  ALUOp;
    wire        MemRead;
    wire        MemWrite;
    wire        ALUSrc;
    wire        MemtoReg;
    wire        Branch;

    // --- Register file -------------------------------------------------------
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] WriteBackData;   // data written to rd

    // --- Immediate generator -------------------------------------------------
    wire [31:0] Imm;

    // --- ALU -----------------------------------------------------------------
    wire [31:0] ALU_SrcB;        // mux output: reg vs imm
    wire [3:0]  ALUCtrl;
    wire [31:0] ALUResult;
    wire        Zero;

    // --- Branch --------------------------------------------------------------
    wire [31:0] Branch_Target;
    wire        PCSrc;           // 1 = take branch

    // --- Memory-mapped address decode ----------------------------------------
    wire        DataMemWrite_en;
    wire        DataMemRead_en;
    wire        LEDWrite_en;
    wire        SwitchReadEnable;

    // --- Data memory ---------------------------------------------------------
    wire [31:0] MemReadData;       // 32-bit read from DataMemory
    wire [31:0] MemOrSwitchData;   // DataMem or switch_in depending on address

    // =========================================================================
    // Module instantiations
    // =========================================================================

    // --- 1. Program Counter --------------------------------------------------
    ProgramCounter u_PC (
        .clk     (clk),
        .reset   (reset),
        .PC_Next (PC_Next),
        .PC      (PC)
    );

    // --- 2. PC + 4 adder -----------------------------------------------------
    pcAdder u_pcAdder (
        .PC       (PC),
        .PC_Plus4 (PC_Plus4)
    );

    // --- 3. Instruction Memory -----------------------------------------------
    instructionMemory u_iMem (
        .instAddress (PC),
        .instruction (instruction)
    );

    // --- 4. Immediate Generator ----------------------------------------------
    immGen u_immGen (
        .inst    (instruction),
        .imm_out (Imm)
    );

    // --- 5. Main Control Unit ------------------------------------------------
    MainControl u_MainCtrl (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );

    // --- 6. Register File ----------------------------------------------------
    register_file u_regFile (
        .clk        (clk),
        .rst        (reset),
        .WriteEnable(RegWrite),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .WriteData  (WriteBackData),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );

    // --- 7. ALU Source-B Mux (register vs immediate) ------------------------
    mux2 u_aluSrcMux (
        .A   (ReadData2),   // sel=0: register rs2
        .B   (Imm),         // sel=1: sign-extended immediate
        .sel (ALUSrc),
        .Y   (ALU_SrcB)
    );

    // --- 8. ALU Control Unit -------------------------------------------------
    ALUControl u_ALUCtrl (
        .opcode     (opcode),
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUCtrl)
    );

    // --- 9. ALU --------------------------------------------------------------
    RISCVALU u_ALU (
        .ALUctl (ALUCtrl),
        .A      (ReadData1),
        .B      (ALU_SrcB),
        .ALUout (ALUResult),
        .Zero   (Zero)
    );

    // --- 10. Branch Target Adder --------------------------------------------
    branchAdder u_branchAdder (
        .PC            (PC),
        .Imm           (Imm),
        .Branch_Target (Branch_Target)
    );

    // --- 11. PC Source Mux (sequential vs branch) ---------------------------
    assign PCSrc = Branch & Zero;   // BEQ: branch taken when rs1 == rs2

    mux2 u_pcSrcMux (
        .A   (PC_Plus4),       // sel=0: sequential execution
        .B   (Branch_Target),  // sel=1: taken branch
        .sel (PCSrc),
        .Y   (PC_Next)
    );

    // --- 12. Address Decoder (memory-mapped I/O) ----------------------------
    AddressDecoder u_addrDec (
        .address         (ALUResult),
        .readEnable      (MemRead),
        .writeEnable     (MemWrite),
        .DataMemWrite    (DataMemWrite_en),
        .DataMemRead     (DataMemRead_en),
        .LEDWrite        (LEDWrite_en),
        .SwitchReadEnable(SwitchReadEnable)
    );

    // --- 13. Data Memory ----------------------------------------------------
    DataMemory u_dataMem (
        .clk        (clk),
        .MemWrite   (DataMemWrite_en),
        .MemRead    (DataMemRead_en),
        .address    (ALUResult),        // full 32-bit byte address; word index = [9:2]
        .write_data (ReadData2),        // full 32-bit rs2 data
        .read_data  (MemReadData)
    );

    // --- 14. Switch read mux -----------------------------------------------
    // When SwitchReadEnable is high (LW from address 0x200), feed switch_in
    // onto the read-data bus instead of DataMemory output.
    // This is what actually connects switch_in into the live datapath so
    // Vivado cannot optimize it away.
    assign MemOrSwitchData = SwitchReadEnable ? {26'b0, switch_in} : MemReadData;

    // --- 15. Write-Back Mux (ALU result vs memory/switch data) -------------
    mux2 u_wbMux (
        .A   (ALUResult),        // sel=0: ALU result
        .B   (MemOrSwitchData),  // sel=1: data from memory or switches
        .sel (MemtoReg),
        .Y   (WriteBackData)
    );

    // =========================================================================
    // Board I/O connections
    // =========================================================================

    // LEDs: latch rs2[5:0] into LED register when LEDWrite is asserted
    reg [5:0] led_reg;
    always @(posedge clk) begin
        if (reset)
            led_reg <= 6'b0;
        else if (LEDWrite_en)
            led_reg <= ReadData2[5:0];
    end
    assign led_out      = led_reg;
    assign led_write_en = LEDWrite_en;

endmodule