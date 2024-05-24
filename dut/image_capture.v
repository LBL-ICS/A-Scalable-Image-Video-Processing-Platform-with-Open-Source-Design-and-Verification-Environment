//-------------------------------------------------------------------------------------------------------------------------------------
//--------- A Scalable Image/Video Processing Platfrom (OV7670-Nexys4-vga) ------------------------------------------------------------
//--------- Author: Xiaokun Yang                   ------------------------------------------------------------------------------------
//--------- Description: Image Captture Module     ------------------------------------------------------------------------------------
//----------Version: 1.0, Date: 12/28/2018         ------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps

module image_capture         (input             pclk       ,
                              input             vsync      ,
                              input             href       ,
                              input      [7:0]  d          ,
                              output reg [16:0] addr       ,
                              output reg [11:0] dout       ,
                              output reg        we         );
                              
reg [15:0] d_latch      ;
reg [1:0]  wr_hold      ;

//reg [11:0] dout        ;
//reg        we          ;
//reg [18:0] addr = 19'b0;

//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//    
always@ (posedge pclk) begin
  if(vsync) begin
      we           <= 1'b0;
      wr_hold      <= 2'b0;
  end else begin
      we           <= wr_hold[1];
      wr_hold      <= {wr_hold[0], (href && !wr_hold[0])};
  end
end
        
always@ (posedge pclk) begin
  if(vsync) begin
      dout         <= 12'h0;	  
      d_latch      <= 16'h0;
      addr         <= 17'h0;
  end else begin
      dout    <= {d_latch[15:12],d_latch[10:7],d_latch[4:1]};
      d_latch <= {d_latch [7:0], d};
      if(we) begin
        addr <= addr + 17'h1;
      end
  end
end
endmodule
