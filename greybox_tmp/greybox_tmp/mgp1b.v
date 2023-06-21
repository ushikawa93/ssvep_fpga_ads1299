//ALTSQRT CBX_SINGLE_OUTPUT_FILE="ON" PIPELINE=8 Q_PORT_WIDTH=64 R_PORT_WIDTH=65 WIDTH=128 aclr clk ena q radical remainder
//VERSION_BEGIN 17.1 cbx_mgl 2017:10:25:18:08:29:SJ cbx_stratixii 2017:10:25:18:06:53:SJ cbx_util_mgl 2017:10:25:18:06:53:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2017  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details.



//synthesis_resources = ALTSQRT 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgp1b
	( 
	aclr,
	clk,
	ena,
	q,
	radical,
	remainder) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clk;
	input   ena;
	output   [63:0]  q;
	input   [127:0]  radical;
	output   [64:0]  remainder;

	wire  [63:0]   wire_mgl_prim1_q;
	wire  [64:0]   wire_mgl_prim1_remainder;

	ALTSQRT   mgl_prim1
	( 
	.aclr(aclr),
	.clk(clk),
	.ena(ena),
	.q(wire_mgl_prim1_q),
	.radical(radical),
	.remainder(wire_mgl_prim1_remainder));
	defparam
		mgl_prim1.pipeline = 8,
		mgl_prim1.q_port_width = 64,
		mgl_prim1.r_port_width = 65,
		mgl_prim1.width = 128;
	assign
		q = wire_mgl_prim1_q,
		remainder = wire_mgl_prim1_remainder;
endmodule //mgp1b
//VALID FILE
