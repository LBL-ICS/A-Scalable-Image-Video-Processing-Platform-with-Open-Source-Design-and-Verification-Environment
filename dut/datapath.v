//-------------------------------------------------------------------------------------------------------------------------------------
//--------- A Scalable Image/Video Processing Platfrom (OV7670-Nexys4-vga) ------------------------------------------------------------
//--------- Author: Xiaokun Yang                   ------------------------------------------------------------------------------------
//--------- Description: top module integrated with I2C Master, Image Capture, and VGA master        ----------------------------------
//----------Version: 1.0, Date: 12/28/2018         ------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps
module datapath                 (input         clk_100        , 
                                 input         cap_pclk       ,        //a clock from campera, around 20MHz
                                 input         reg_conf_rst   ,
                                 input         vga_rst        ,
                                 output        ov7670_xclk    ,        //25MHz output from ov7670 controller to camera
                                 output        ov7670_rst     ,
                                 
                                 output        reg_conf_finish,
                                 output        sioc           ,
                                 inout         siod           , 
                                 output        pwdn           ,    //initilize to 0
                           
                                 input         cap_vsync      ,
                                 input         cap_href       ,
                                 input  [7:0]  cap_d          , 

                                 output [3:0]  vga_red        , 
                                 output [3:0]  vga_green      , 
                                 output [3:0]  vga_blue       , 
                                 output        vga_hsync      , 
                                 output        vga_vsync       
                                                              );

parameter  DATASIZE = 12;		// Memory data word width
parameter  ADDRSIZE = 16;		// Number of memory address bits
localparam DEPTH = 1<<ADDRSIZE;		// DEPTH = 2 ^ ADDRSIZE

///////////////////////
// clkg: from vivardo
///////////////////////

`ifdef SIMULATION
reg ov7670_clk50;
reg vga_clk25   ;

always @(posedge clk_100 or posedge reg_conf_rst) begin
  if(reg_conf_rst) begin
    ov7670_clk50 <= 1'b0;
  end else begin
    ov7670_clk50 <= ~ov7670_clk50;
  end
end

always @(posedge ov7670_clk50 or posedge vga_rst) begin
  if(vga_rst) begin
    vga_clk25 <= 1'b0;
  end else begin
    vga_clk25 <= ~vga_clk25;
  end
end

`elsif 
wire ov7670_clk50;
wire vga_clk25   ;
clk_wiz_0  clk_wiz_0_clk_wiz
  (
  // Clock out ports  
  .ov7670_clk50(ov7670_clk50),
  .vga_clk25(vga_clk25),
 // Clock in ports
  .clk_100(clk_100)
  );
`endif
/////////////////////////
//// capture
/////////////////////////
wire  [16:0] cap_addr       ;
wire  [11:0] cap_dout       ;
wire         cap_we         ;


///////////////////////
// vga
///////////////////////
reg      [11:0]    vga_data        ; 
wire     [11:0]    vga_data0       ; 
wire     [11:0]    vga_data1       ; 
wire     [11:0]    vga_data2       ; 
wire     [11:0]    vga_data3       ; 
wire     [16:0]    vga_addr0       ; 
wire     [16:0]    vga_addr1       ; 
wire     [16:0]    vga_addr2       ; 
wire     [16:0]    vga_addr3       ; 
wire     [3:0 ]    region          ;

always @(vga_rst, vga_data0, vga_data1, vga_data2, vga_data3, region) begin
  if (vga_rst) begin
    vga_data = 17'h0;
  end else begin
    case (region)
      4'b0001: vga_data = vga_data0;
      4'b0010: vga_data = vga_data1;
      4'b0100: vga_data = vga_data2;
      4'b1000: vga_data = vga_data3;
      default: vga_data = 12'h0;
    endcase
  end
end

///////////////////////
// ov7670_controller
///////////////////////



ov7670_controller u_ov7670_controller         (.ov7670_clk50    (ov7670_clk50   )     , 
                                               .reg_conf_rst    (reg_conf_rst   )     ,
                                               .reg_conf_finish (reg_conf_finish)     , 
                                               .sioc            (sioc           )     , 
                                               .siod            (siod           )     , 
                                               .ov7670_rst      (ov7670_rst     )     ,    ////1'b1, output from ov7670 controller to camera
                                               .pwdn            (pwdn           )     ,    //initilize to 0
                                               .ov7670_xclk     (ov7670_xclk    )     );

image_capture           u_image_capture         (.pclk         (cap_pclk ) ,
                                                 .vsync        (cap_vsync) ,
                                                 .href         (cap_href ) ,
                                                 .d            (cap_d    ) ,
                                                 .addr         (cap_addr ) ,
                                                 .dout         (cap_dout ) ,
                                                 .we           (cap_we   ) );

vga                       u_vga               (.vga_clk25     (vga_clk25    )    ,
                                               .vga_rst       (vga_rst      )    ,
	                                             .vga_data      (vga_data     )    ,
	                                             .vga_red       (vga_red      )    ,
	                                             .vga_green     (vga_green    )    , 
                                               .vga_blue      (vga_blue     )    ,
                                               .vga_hsync     (vga_hsync    )    ,
                                               .vga_vsync     (vga_vsync    )    ,
                                               .vga_addr0     (vga_addr0    )    ,
                                               .vga_addr1     (vga_addr1    )    ,
                                               .vga_addr2     (vga_addr2    )    ,
                                               .vga_addr3     (vga_addr3    )    ,
                                               .region        (region       ))   ;


`ifdef SIMULATION
ram_320x240            u0_ram_320x240            (.clk_a  (cap_pclk    ) ,	
                                                 .clk_b  (vga_clk25   ) ,
                                                 .wdata  (cap_dout    ) ,
                                                 .raddr  (vga_addr0   ) ,
                                                 .waddr  (cap_addr    ) ,
                                                 .wr     (cap_we      ) ,
                                                 .rdata  (vga_data0   ) );

ram_320x240            u1_ram_320x240            (.clk_a  (cap_pclk    ) ,	
                                                 .clk_b  (vga_clk25   ) ,
                                                 .wdata  (cap_dout    ) ,
                                                 .raddr  (vga_addr1   ) ,
                                                 .waddr  (cap_addr    ) ,
                                                 .wr     (cap_we      ) ,
                                                 .rdata  (vga_data1   ) );
ram_320x240            u2_ram_320x240            (.clk_a  (cap_pclk    ) ,	
                                                 .clk_b  (vga_clk25   ) ,
                                                 .wdata  (cap_dout    ) ,
                                                 .raddr  (vga_addr2   ) ,
                                                 .waddr  (cap_addr    ) ,
                                                 .wr     (cap_we      ) ,
                                                 .rdata  (vga_data2   ) );

ram_320x240            u3_ram_320x240            (.clk_a  (cap_pclk    ) ,	
                                                 .clk_b  (vga_clk25   ) ,
                                                 .wdata  (cap_dout    ) ,
                                                 .raddr  (vga_addr3   ) ,
                                                 .waddr  (cap_addr    ) ,
                                                 .wr     (cap_we      ) ,
                                                 .rdata  (vga_data3   ) );
`elsif

blk_mem_gen_0 u_blk_mem_gen_0 (
    .clka  (cap_pclk),   //20MHz
    .wea   (cap_we  ), 
    .addra (cap_addr), 
    .dina  (cap_dout), 

    .clkb  (vga_clk25),
    .addrb (vga_addr0 ),
    .doutb (vga_data0 ) 
   );

blk_mem_gen_1 u_blk_mem_gen_1 (
    .clka  (cap_pclk),   //20MHz
    .wea   (cap_we  ), 
    .addra (cap_addr), 
    .dina  (cap_dout), 

    .clkb  (vga_clk25),
    .addrb (vga_addr1 ),
    .doutb (vga_data1 ) 
   );

blk_mem_gen_2 u_blk_mem_gen_2 (
    .clka  (cap_pclk),   //20MHz
    .wea   (cap_we  ), 
    .addra (cap_addr), 
    .dina  (cap_dout), 

    .clkb  (vga_clk25),
    .addrb (vga_addr2 ),
    .doutb (vga_data2 ) 
   );

blk_mem_gen_3 u_blk_mem_gen_3 (
    .clka  (cap_pclk),   //20MHz
    .wea   (cap_we  ), 
    .addra (cap_addr), 
    .dina  (cap_dout), 

    .clkb  (vga_clk25),
    .addrb (vga_addr3 ),
    .doutb (vga_data3 ) 
   );
`endif

endmodule
