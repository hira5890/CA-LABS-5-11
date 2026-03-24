// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Fri Mar 13 10:20:22 2026
// Host        : DESKTOP-KLI62TT running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               C:/Users/DELL/Downloads/lab888/lab888.sim/sim_1/impl/timing/xsim/MemorySystem_tb_time_impl.v
// Design      : addressDecoderTop
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

module AddressDecoder
   (E,
    D,
    writeEnable_IBUF);
  output [0:0]E;
  input [1:0]D;
  input writeEnable_IBUF;

  wire [1:0]D;
  wire [0:0]E;
  wire writeEnable_IBUF;

  LUT3 #(
    .INIT(8'h40)) 
    LEDWrite
       (.I0(D[1]),
        .I1(D[0]),
        .I2(writeEnable_IBUF),
        .O(E));
endmodule

module LEDInterface
   (Q,
    E,
    D,
    clk_IBUF_BUFG);
  output [9:0]Q;
  input [0:0]E;
  input [9:0]D;
  input clk_IBUF_BUFG;

  wire [9:0]D;
  wire [0:0]E;
  wire [9:0]Q;
  wire clk_IBUF_BUFG;

  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[0]),
        .Q(Q[0]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[1]),
        .Q(Q[1]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[2]),
        .Q(Q[2]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[3]),
        .Q(Q[3]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[4]),
        .Q(Q[4]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[5]),
        .Q(Q[5]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[6]),
        .Q(Q[6]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[7]),
        .Q(Q[7]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[8] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[8]),
        .Q(Q[8]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \leds_reg[9] 
       (.C(clk_IBUF_BUFG),
        .CE(E),
        .D(D[9]),
        .Q(Q[9]),
        .R(1'b0));
endmodule

(* ECO_CHECKSUM = "c94b58d" *) 
(* NotValidForBitStream *)
module addressDecoderTop
   (clk,
    rst,
    address,
    readEnable,
    writeEnable,
    switches,
    leds);
  input clk;
  input rst;
  input [9:0]address;
  input readEnable;
  input writeEnable;
  input [15:0]switches;
  output [15:0]leds;

  wire LEDWrite;
  wire [9:0]address;
  wire [9:0]address_IBUF;
  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire [15:0]leds;
  wire [9:0]leds_OBUF;
  wire writeEnable;
  wire writeEnable_IBUF;

initial begin
 $sdf_annotate("MemorySystem_tb_time_impl.sdf",,,,"tool_control");
end
  IBUF \address_IBUF[0]_inst 
       (.I(address[0]),
        .O(address_IBUF[0]));
  IBUF \address_IBUF[1]_inst 
       (.I(address[1]),
        .O(address_IBUF[1]));
  IBUF \address_IBUF[2]_inst 
       (.I(address[2]),
        .O(address_IBUF[2]));
  IBUF \address_IBUF[3]_inst 
       (.I(address[3]),
        .O(address_IBUF[3]));
  IBUF \address_IBUF[4]_inst 
       (.I(address[4]),
        .O(address_IBUF[4]));
  IBUF \address_IBUF[5]_inst 
       (.I(address[5]),
        .O(address_IBUF[5]));
  IBUF \address_IBUF[6]_inst 
       (.I(address[6]),
        .O(address_IBUF[6]));
  IBUF \address_IBUF[7]_inst 
       (.I(address[7]),
        .O(address_IBUF[7]));
  IBUF \address_IBUF[8]_inst 
       (.I(address[8]),
        .O(address_IBUF[8]));
  IBUF \address_IBUF[9]_inst 
       (.I(address[9]),
        .O(address_IBUF[9]));
  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  AddressDecoder decoder
       (.D(address_IBUF[9:8]),
        .E(LEDWrite),
        .writeEnable_IBUF(writeEnable_IBUF));
  LEDInterface led
       (.D(address_IBUF),
        .E(LEDWrite),
        .Q(leds_OBUF),
        .clk_IBUF_BUFG(clk_IBUF_BUFG));
  OBUF \leds_OBUF[0]_inst 
       (.I(leds_OBUF[0]),
        .O(leds[0]));
  OBUF \leds_OBUF[10]_inst 
       (.I(1'b0),
        .O(leds[10]));
  OBUF \leds_OBUF[11]_inst 
       (.I(1'b0),
        .O(leds[11]));
  OBUF \leds_OBUF[12]_inst 
       (.I(1'b0),
        .O(leds[12]));
  OBUF \leds_OBUF[13]_inst 
       (.I(1'b0),
        .O(leds[13]));
  OBUF \leds_OBUF[14]_inst 
       (.I(1'b0),
        .O(leds[14]));
  OBUF \leds_OBUF[15]_inst 
       (.I(1'b0),
        .O(leds[15]));
  OBUF \leds_OBUF[1]_inst 
       (.I(leds_OBUF[1]),
        .O(leds[1]));
  OBUF \leds_OBUF[2]_inst 
       (.I(leds_OBUF[2]),
        .O(leds[2]));
  OBUF \leds_OBUF[3]_inst 
       (.I(leds_OBUF[3]),
        .O(leds[3]));
  OBUF \leds_OBUF[4]_inst 
       (.I(leds_OBUF[4]),
        .O(leds[4]));
  OBUF \leds_OBUF[5]_inst 
       (.I(leds_OBUF[5]),
        .O(leds[5]));
  OBUF \leds_OBUF[6]_inst 
       (.I(leds_OBUF[6]),
        .O(leds[6]));
  OBUF \leds_OBUF[7]_inst 
       (.I(leds_OBUF[7]),
        .O(leds[7]));
  OBUF \leds_OBUF[8]_inst 
       (.I(leds_OBUF[8]),
        .O(leds[8]));
  OBUF \leds_OBUF[9]_inst 
       (.I(leds_OBUF[9]),
        .O(leds[9]));
  IBUF writeEnable_IBUF_inst
       (.I(writeEnable),
        .O(writeEnable_IBUF));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
