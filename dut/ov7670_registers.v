//-------------------------------------------------------------------------------------------------------------------------------------
//--------- A Scalable Image/Video Processing Platfrom (OV7670-Nexys4-vga) ------------------------------------------------------------
//--------- Author: Xiaokun Yang                   ------------------------------------------------------------------------------------
//--------- Description: I2C register configuration, reference: C. Ababei,  et al., EIT2016, May 2016. --------------------------------
//----------Version: 1.0, Date: 12/28/2018         ------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps

module ov7670_registers        (input             ov7670_clk50    , 
                                input             reg_conf_rst    ,
                                input             token           , 
                                output reg [15:0] command         , 
                                output            reg_conf_finish);

wire [7:0] nxt_cnt ;
reg  [7:0] cnt     ;

assign reg_conf_finish = &command ? 1'b1 : 1'b0;

assign nxt_cnt = token ? cnt+8'h1 : cnt;
always@(posedge ov7670_clk50 or posedge reg_conf_rst) begin
  if (reg_conf_rst) begin
    cnt <= 8'h0;
  end else begin
    cnt <= nxt_cnt;
  end
end

always@(reg_conf_rst or cnt or token) begin
  if (reg_conf_rst) begin
    command <= 16'h0;
  end else begin
    case (cnt) 
      8'h00: command <= 16'h1280; // COM7   Reset
      8'h01: command <= 16'h1280; // COM7   Reset 
      8'h02: command <= 16'h1214; // COM7   Size & RGB output
      8'h03: command <= 16'h1100; // CLKRC  Prescaler - Fin/(1+1)
      8'h04: command <= 16'h0C00; // COM3   Lots of stuff, enable scaling, all others off
      8'h05: command <= 16'h3E00; // COM14  PCLK scaling off
      8'h06: command <= 16'h8C00; // RGB444 Set RGB format
      8'h07: command <= 16'h0400; // COM1   no CCIR601
      8'h08: command <= 16'h4010; // COM15  Full 0-255 output, RGB 565
      8'h09: command <= 16'h3A04; // TSLB   Set UV ordering,  do not auto-reset window
      8'h0A: command <= 16'h1438; // COM9  - AGC Celling
      8'h0B: command <= 16'h4Fb3; //x"4fb3"; -- MTX1  - colour conversion matrix
      8'h0C: command <= 16'h50b3; //x"50b3"; -- MTX2  - colour conversion matrix
      8'h0D: command <= 16'h5100; //x"5100"; -- MTX3  - colour conversion matrix
      8'h0E: command <= 16'h523d; //x"523d"; -- MTX4  - colour conversion matrix
      8'h0F: command <= 16'h53a7; //x"53a7"; -- MTX5  - colour conversion matrix
      8'h10: command <= 16'h54e4; //x"54e4"; -- MTX6  - colour conversion matrix
      8'h11: command <= 16'h589E; //x"589e"; -- MTXS  - Matrix sign and auto contrast
      8'h12: command <= 16'h3DC0; // COM13 - Turn on GAMMA and UV Auto adjust
      8'h13: command <= 16'h1100; // CLKRC  Prescaler - Fin/(1+1)
      8'h14: command <= 16'h1717; // HSTART HREF start (high 8 bits)
      8'h15: command <= 16'h1805; // HSTOP  HREF stop (high 8 bits)
      8'h16: command <= 16'h3280; // HREF   Edge offset and low 3 bits of HSTART and HSTOP
      8'h17: command <= 16'h1902; // VSTART VSYNC start (high 8 bits)
      8'h18: command <= 16'h1A7B; // VSTOP  VSYNC stop (high 8 bits) 
      8'h19: command <= 16'h030A; // VREF   VSYNC low two bits
      8'h1A: command <= 16'h0E61; // COM5(0x0E) 0x61
      8'h1B: command <= 16'h0F4B; // COM6(0x0F) 0x4B 
      8'h1C: command <= 16'h1602; //
      8'h1D: command <= 16'h1E37; // MVFP (0x1E) 0x07  -- FLIP AND MIRROR IMAGE 0x3x
      8'h1E: command <= 16'h2102;
      8'h1F: command <= 16'h2291;
      8'h20: command <= 16'h2907;
      8'h21: command <= 16'h330B;
      8'h22: command <= 16'h350B;
      8'h23: command <= 16'h371D;
      8'h24: command <= 16'h3871;
      8'h25: command <= 16'h392A;
      8'h26: command <= 16'h3C78; // COM12 (0x3C) 0x78
      8'h27: command <= 16'h4D40; //
      8'h28: command <= 16'h4E20;
      8'h29: command <= 16'h6900; // GFIX (0x69) 0x00
      8'h2A: command <= 16'h6b4a;
      8'h2B: command <= 16'h7410;
      8'h2C: command <= 16'h8D4F;
      8'h2D: command <= 16'h8E00;
      8'h2E: command <= 16'h8F00;
      8'h2F: command <= 16'h9000;
      8'h30: command <= 16'h9100;
      8'h31: command <= 16'h9600;
      8'h32: command <= 16'h9A00;
      8'h33: command <= 16'hB084;
      8'h34: command <= 16'hB10C;
      8'h35: command <= 16'hB20E;
      8'h36: command <= 16'hB382;
      8'h37: command <= 16'hB80A;
      default: command <= 16'hffff;
    endcase  
  end
end
endmodule
