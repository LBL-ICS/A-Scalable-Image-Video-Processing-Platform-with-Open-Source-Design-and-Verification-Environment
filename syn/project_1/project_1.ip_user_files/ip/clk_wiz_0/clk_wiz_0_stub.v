// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Mon Nov 26 14:17:38 2018
// Host        : D111-D45876 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub c:/Zynq_Book/ip_repo/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(vga_clk25, ov7670_clk50, clk_100)
/* synthesis syn_black_box black_box_pad_pin="vga_clk25,ov7670_clk50,clk_100" */;
  output vga_clk25;
  output ov7670_clk50;
  input clk_100;
endmodule
