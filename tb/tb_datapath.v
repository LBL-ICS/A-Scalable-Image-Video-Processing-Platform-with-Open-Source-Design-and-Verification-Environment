//-------------------------------------------------------------------------------------------------------------------------------------
//--------- A Scalable Image/Video Processing Platfrom (OV7670-Nexys4-vga) ------------------------------------------------------------
//--------- Author: Xiaokun Yang                   ------------------------------------------------------------------------------------
//--------- Description: testbench with one frame of image input and comparison -------------------------------------------------------
//----------Version: 1.0, Date: 12/28/2018         ------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
//
`timescale 1ns / 1ps

module tb_datapath ;

reg [3:0]  golden_red_mem[320*240-1:0];
reg [3:0]  golden_grn_mem[320*240-1:0];
reg [3:0]  golden_blu_mem[320*240-1:0];
reg [11:0] golden_rgb_mem[320*240-1:0];
reg [7:0]  input_mem[640*240-1:0];

initial begin
   $readmemh("../testdata/RGB565_Input.txt",input_mem);
   $readmemh("../testdata/RGB444_Golden.txt",golden_rgb_mem);
   $readmemh("../testdata/Rg.txt",golden_red_mem);
   $readmemh("../testdata/Gg.txt",golden_grn_mem);
   $readmemh("../testdata/Bg.txt",golden_blu_mem);
end

reg        clk_100        ;
reg        cap_pclk       ;        //a clock from campera, around 20MHz
reg        reg_conf_rst   ;
reg        vga_rst        ;
wire       ov7670_xclk    ;        //25MHz output from ov7670 controller to camera
wire       ov7670_rst     ;

wire       reg_conf_finish;
wire       sioc           ;
wire       siod           ; 
wire       pwdn           ;    //initilize to 0

reg         cap_vsync     ;
reg         cap_href      ;
wire [7:0]  cap_d         ; 

wire [3:0]  vga_red       ; 
wire [3:0]  vga_green     ; 
wire [3:0]  vga_blue      ; 
wire        vga_hsync     ; 
wire        vga_vsync     ; 

reg [3:0] golden_red    ; 
reg [3:0] golden_grn    ; 
reg [3:0] golden_blu    ; 

datapath u_datapath   (.clk_100         (clk_100         ) , 
                       .cap_pclk        (cap_pclk        ) ,        //a clock from campera, around 20MHz
                       .reg_conf_rst    (reg_conf_rst    ) ,
                       .vga_rst         (vga_rst         ) ,
                       .ov7670_xclk     (ov7670_xclk     ) ,        //25MHz output from ov7670 controller to camera
                       .ov7670_rst      (ov7670_rst      ) ,
                                                         
                       .reg_conf_finish (reg_conf_finish ) ,
                       .sioc            (sioc            ) ,
                       .siod            (siod            ) , 
                       .pwdn            (pwdn            ) ,    //initilize to 0
                                                         
                       .cap_vsync       (cap_vsync       ) ,
                       .cap_href        (cap_href        ) ,
                       .cap_d           (cap_d           ) , 
                                                         
                       .vga_red         (vga_red         ) , 
                       .vga_green       (vga_green       ) , 
                      .vga_blue        (vga_blue        ) , 
                       .vga_hsync       (vga_hsync       ) , 
                       .vga_vsync       (vga_vsync       )  
                                                         );


                     
/***************************************
//  BFM : Cock and Reset Generation  
****************************************/
initial begin // Clock generation
  clk_100 = 1'b0;
  forever begin
    #5;
    clk_100 = ~clk_100;
  end
end

initial begin // Clock generation
  cap_pclk = 1'b0;
  forever begin
    #25;
    cap_pclk = ~cap_pclk;
  end
end

initial begin
  reg_conf_rst = 1'b1;
  #100;
  reg_conf_rst = 1'b0;
end

initial begin
  vga_rst = 1'b1;
  #100;
  vga_rst = 1'b0;
end

/*******************************
//  BFM : Capture Model 
*******************************/
wire [9:0] nxt_hcnt ;
wire [9:0] nxt_vcnt;
reg  [9:0] hcnt   ;
reg  [9:0] vcnt   ;
assign nxt_hcnt    = cap_href ? hcnt+10'd1 : 
             (~cap_href & (hcnt==10'd640)) ? 10'd0 : hcnt;
assign nxt_vcnt    = (u_datapath.cap_we&(hcnt==10'd639)) ? vcnt+10'd1  : vcnt;


always@(posedge cap_pclk)begin
  if(cap_vsync) begin
    hcnt <= 10'd0;    
  end else begin
    hcnt <= nxt_hcnt;
  end
end

always@(posedge cap_pclk)begin
  if(cap_vsync)begin
    vcnt <= 10'd0;
  end else begin
    vcnt <= nxt_vcnt;
  end 	  
end

initial begin
  force u_datapath.u_vga.vga_red=4'h0;
  force u_datapath.u_vga.vga_green=4'h0;
  force u_datapath.u_vga.vga_blue=4'h0;
  force golden_red    = 8'h0; 
  force golden_grn    = 8'h0; 
  force golden_blu    = 8'h0; 
  repeat (2) @(negedge cap_vsync); 
  release u_datapath.u_vga.vga_red;
  release u_datapath.u_vga.vga_green;
  release u_datapath.u_vga.vga_blue;
  release golden_red    ; 
  release golden_grn    ; 
  release golden_blu    ; 
end

initial begin
  cap_vsync = 1'b0;
  wait (reg_conf_finish);
  cap_vsync = 1'b1;
  #200;
  cap_vsync = 1'b0;
  wait (hcnt==10'd640 & vcnt==10'd240)
  repeat (2) @ (posedge cap_pclk);
  cap_vsync = 1'b1;
  #200; #1;
  cap_vsync = 1'b0;
  wait (hcnt==10'd640 & vcnt==10'd240)
  repeat (2) @ (posedge cap_pclk);
  cap_vsync = 1'b1;
  #200; #1;
  cap_vsync = 1'b0;
end

always@(posedge cap_pclk)begin
  if(cap_vsync | vcnt==10'd240 | hcnt==10'd639) begin
    cap_href <= 1'b0;
  end else begin
    cap_href <= 1'b1;
  end
end

integer i=0;
assign cap_d = (i>153599) ? 8'h0 : input_mem[i]; //320x240x2-1=153599
always@(posedge cap_pclk or posedge cap_vsync)begin
  if(cap_vsync) begin
    i <= 0;
  end else if (cap_href) begin
    i <= i+1;
  end
end

/*******************************
//  Scoreboard  
*******************************/
initial begin
  $display("---------------------------------------");
  $display("Start checking I2C Reg Configuration!");
  $display("---------------------------------------");
  wait (reg_conf_finish);
  repeat (28) @(posedge sioc);
  $display("---------------------------------------");
  $display("Finish checking I2C Reg Configuration!");
  $display("---------------------------------------");

  @(negedge cap_vsync); 
  $display("---------------------------------------");
  $display("Start checking CAP & VGA RGB output!");
  $display("---------------------------------------");
  repeat(653000) @(posedge cap_pclk); 
  $display("---------------------------------------");
  $display("Finish checking CAP & VGA RGB output!");
  $display("---------------------------------------");
  //$stop;
end

/*******************************
//  Scoreboard : I2C Interface
*******************************/
reg  [9:0] icnt   ;

always@(negedge sioc or posedge reg_conf_rst)begin
  if(icnt==27 | reg_conf_rst) begin
    icnt <= 10'd0;    
  end else begin
    icnt <= icnt+1;
  end
end

reg  [23:0] rcv_cmd ; 
wire cmd1_flg = icnt>=1 & icnt<=8;
wire cmd2_flg = icnt>=10 & icnt<=17;
wire cmd3_flg = icnt>=19 & icnt<=26;
always@(posedge sioc or posedge reg_conf_rst)begin
  if(reg_conf_rst) begin
    rcv_cmd <= 24'h0; 
  end else if (cmd1_flg | cmd2_flg | cmd3_flg) begin
    rcv_cmd <= {rcv_cmd, siod}; 
  end 
end

reg [23:0] golden_cmd;
always@(posedge sioc)begin
  if(reg_conf_rst) begin
    golden_cmd <= 24'h421280;    
  end else if (icnt==27) begin
    golden_cmd <= {8'h42, u_datapath.u_ov7670_controller.u_reg.command};    
  end
end

always@(posedge sioc)begin
  if(icnt==27) begin
    if (rcv_cmd==golden_cmd) begin
`ifdef DEBUG_I2C
      $display("Received command at %d ns is corect! Exp: %h; Rcv: %h", $time, golden_cmd, rcv_cmd);
`endif
    end else begin
`ifdef DEBUG_I2C
      $display("Received command at %d ns is WRONG! Exp: %h; Rcv: %h", $time, golden_cmd, rcv_cmd);
`endif
    repeat (100) @(posedge sioc);
    $stop;
    end
  end
end

/*******************************
//  Scoreboard : CAP Interface
*******************************/
wire [11:0] golden_rgb;
assign golden_rgb    = golden_rgb_mem[u_datapath.u_image_capture.addr]; 

initial begin
  repeat (2) @(negedge cap_vsync); //start checking at the second frame of image
  forever begin
    @(negedge cap_pclk); 
    if (u_datapath.u_image_capture.we) begin 
      if (u_datapath.u_image_capture.dout == golden_rgb) begin
`ifdef DEBUG_CAP 
      $display("Capture pixel at %d ns is corect! Exp: rgb - %h; Rcv: rgb - %h", $time, golden_rgb, u_datapath.u_image_capture.dout);
`endif 
      end else begin
`ifdef DEBUG_CAP
      $display("Capture pixel at %d ns is WRONG! Exp: rgb - %h; Rcv: rgb - %h", $time, golden_rgb, u_datapath.u_image_capture.dout);
`endif 
      repeat (100) @(negedge cap_pclk);
      $stop;
      end
    end
  end
end

/*******************************
//  Scoreboard : VGA Interface
*******************************/
always @(vga_rst, u_datapath.u_vga.vga_addr0) begin
  if(vga_rst) begin
    golden_red    = 4'h0; 
    golden_grn    = 4'h0; 
    golden_blu    = 4'h0; 
  end else begin
    golden_red    = golden_red_mem[u_datapath.u_vga.vga_addr0]; 
    golden_grn    = golden_grn_mem[u_datapath.u_vga.vga_addr0]; 
    golden_blu    = golden_blu_mem[u_datapath.u_vga.vga_addr0]; 
  end
end

wire check_vga = u_datapath.u_vga.region[0] & (u_datapath.u_vga.hcnt>=0) & (u_datapath.u_vga.hcnt<=319);
initial begin
  repeat (2) @(negedge cap_vsync); //start checking at the second frame of image
  //repeat (10*76800) begin
  forever begin
    @(negedge u_datapath.vga_clk25); 
    if (check_vga) begin 
      if ((vga_red==golden_red) & (vga_green==golden_grn) & (vga_blue==golden_blu)) begin
`ifdef DEBUG_VGA
      $display("%h VGA pixel at %d ns is corect! Exp: red - %h, green - %h, blue - %h; Rcv: red - %h, green - %h, blue - %h", u_datapath.u_vga.vga_addr0, $time, golden_red, golden_grn, golden_blu, vga_red, vga_green, vga_blue);
`endif 
      end else begin
`ifdef DEBUG_VGA
      $display("%h VGA pixel at %d ns is WRONG! Exp: red - %h, green - %h, blue - %h; Rcv: red - %h, green - %h, blue - %h", u_datapath.u_vga.vga_addr0, $time, golden_red, golden_grn, golden_blu, vga_red, vga_green, vga_blue);
`endif 
      repeat (100) @(negedge u_datapath.vga_clk25);
      $stop;
      end
    end
  end
end
endmodule
  

