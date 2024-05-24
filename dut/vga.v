//-------------------------------------------------------------------------------------------------------------------------------------
//--------- A Scalable Image/Video Processing Platfrom (OV7670-Nexys4-vga) ------------------------------------------------------------
//--------- Author: Xiaokun Yang                   ------------------------------------------------------------------------------------
//--------- Description: VGA Master                ------------------------------------------------------------------------------------
//----------Version: 1.0, Date: 12/28/2018         ------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps
module vga (input                vga_clk25          ,
            input                vga_rst            ,
	          input      [11:0]    vga_data           ,
	          output reg [3:0]     vga_red            ,
	          output reg [3:0]     vga_green          , 
            output reg [3:0]     vga_blue           ,
            output               vga_hsync          ,
            output               vga_vsync          ,
            output reg [16:0]    vga_addr0          , 
            output reg [16:0]    vga_addr1          , 
            output reg [16:0]    vga_addr2          , 
            output reg [16:0]    vga_addr3          , 
            output     [3:0 ]    region             ); 
	
parameter H_PULSE_WIDTH        = 96          ;
parameter H_FRONT_PORCH        = 16          ;
parameter H_BACK_PORCH         = 48          ;
parameter H_SYNC_PULSE         = 800         ;
parameter H_DISPLAY_TIME       = 640         ;

parameter V_PULSE_WIDTH        = 2           ;
parameter V_FRONT_PORCH        = 10          ;
parameter V_BACK_PORCH         = 29          ;
parameter V_SYNC_PULSE         = 521         ;
parameter V_DISPLAY_TIME       = 480         ;
////////////////////////////////////////////////////////////////////
//                      SYNC_PULSE
//    |<-------------------------------------------------->| 
//     _____________________________________    ___________
//                                         |    |
//                                         ------ 
//       DISPLAY_TIME    FRONT_PORCH   PULSE_WIDTH  BACK_PORCH
////////////////////////////////////////////////////////////////////
wire [9:0]  nxt_hcnt       ;
wire [9:0]  nxt_vcnt       ;
reg  [9:0]  hcnt           ;
reg  [9:0]  vcnt           ;

/////////////////////////////////////////
//  hcnt and hsync desgin
/////////////////////////////////////////
assign nxt_hcnt = (hcnt==(H_SYNC_PULSE-1)) ? 10'h0 : hcnt+10'h1;
always @(posedge vga_clk25 or posedge vga_rst) begin
  if(vga_rst) begin
    hcnt <= 10'h0;
  end else begin
    hcnt <= nxt_hcnt;
  end	
end

assign vga_hsync = ~((hcnt>=H_DISPLAY_TIME+H_FRONT_PORCH) & (hcnt<H_DISPLAY_TIME+H_FRONT_PORCH+H_PULSE_WIDTH));

/////////////////////////////////////////
//  vcnt and vsync desgin
/////////////////////////////////////////
assign nxt_vcnt = (vcnt==V_SYNC_PULSE-1) & (hcnt==(H_SYNC_PULSE-1)) ? 10'h0 : 
                      (hcnt==(H_SYNC_PULSE-1)) ? vcnt+10'h1 : vcnt;

always @(posedge vga_clk25 or posedge vga_rst) begin
  if(vga_rst) begin
    vcnt <= 10'h0;
  end else begin
    vcnt <= nxt_vcnt;
  end	
end

assign vga_vsync = ~((vcnt>=V_DISPLAY_TIME+V_FRONT_PORCH) & (vcnt<V_DISPLAY_TIME+V_FRONT_PORCH+V_PULSE_WIDTH));  

/////////////////////////////////////////
// frame address and pixel design 
///////////////////////////////////////// 
wire [16:0]    nxt_vga_addr0         ; 
assign nxt_vga_addr0 = (vga_addr0==76800) ? 17'h0 : 
                                        region[0] ? (vga_addr0+17'h1) : vga_addr0 ;

wire [16:0]    nxt_vga_addr1         ; 
assign nxt_vga_addr1 = (vga_addr1==76800) ? 17'h0 : 
                                        region[1] ? (vga_addr1+17'h1) : vga_addr1 ;

wire [16:0]    nxt_vga_addr2         ; 
assign nxt_vga_addr2 = (vga_addr2==76800) ? 17'h0 : 
                                        region[2] ? (vga_addr2+17'h1) : vga_addr2 ;

wire [16:0]    nxt_vga_addr3         ; 
assign nxt_vga_addr3 = (vga_addr3==76800) ? 17'h0 : 
                                        region[3] ? (vga_addr3+17'h1) : vga_addr3 ;

always @(posedge vga_clk25 or posedge vga_rst)begin
  if(vga_rst) begin
    vga_addr0 <= 17'h0;
    vga_addr1 <= 17'h0;
    vga_addr2 <= 17'h0;
    vga_addr3 <= 17'h0;
  end else begin
    vga_addr0 <= nxt_vga_addr0;
    vga_addr1 <= nxt_vga_addr1;
    vga_addr2 <= nxt_vga_addr2;
    vga_addr3 <= nxt_vga_addr3;
  end
end

//wire blank   ;
assign region = (vcnt<240) & (hcnt<320) ? 4'b0001 : 
                         (vcnt<240) & (hcnt>=320) & (hcnt<640) ? 4'b0010 : 
                                   (vcnt>=240) & (vcnt<480) & (hcnt<320) ? 4'b0100 : 
                                             (vcnt>=240) & (vcnt<480) & (hcnt>=320) & (hcnt<640) ? 4'b1000 : 4'b0000;
//grayscale 
wire [3:0] grayscale ;
wire       binary    ;

wire [7:0] red_4;
wire [7:0] grn_2;
wire [7:0] blu_16;
assign red_4  = {vga_data[11:8],vga_data[11:8]}>>2 ;
assign grn_2  = {vga_data[7:4],vga_data[7:4]}  >>1 ;
assign blu_16 = {vga_data[3:0],vga_data[3:0]}  >>4;

assign  grayscale = red_4+grn_2+blu_16;

assign  binary = grayscale>4'h8;

always @(vga_rst, region, vga_data, grayscale, binary) begin
  if(vga_rst) begin
    vga_red   <= 4'h0         ;
    vga_green <= 4'h0         ;
    vga_blue  <= 4'h0         ;
  end else begin
    case (region) 
      4'b0001: begin
                 vga_red   <= vga_data[11:8] ;
                 vga_green <= vga_data[7:4]  ;
                 vga_blue  <= vga_data[3:0]  ;
               end
      4'b0010: begin
                 vga_red   <= grayscale      ;
                 vga_green <= grayscale      ;
                 vga_blue  <= grayscale      ;
               end
      4'b0100: begin
                 vga_red   <= grayscale      ;
                 vga_green <= grayscale      ;
                 vga_blue  <= grayscale      ;
               end
      4'b1000: begin
                 vga_red   <= {8{binary}}    ;
                 vga_green <= {8{binary}}    ;
                 vga_blue  <= {8{binary}}    ;
               end
      default: begin
                 vga_red   <= 4'h0 ;
                 vga_green <= 4'h0 ;
                 vga_blue  <= 4'h0 ;
               end
    endcase
  end
end

endmodule
