//-------------------------------------------------------------------------------------------------------------------------------------
//--------- A Scalable Image/Video Processing Platfrom (OV7670-Nexys4-vga) ------------------------------------------------------------
//--------- Author: Xiaokun Yang                   ------------------------------------------------------------------------------------
//--------- Description: I2C Master integrated with reg configuration and I2C Controller ----------------------------------------------
//----------Version: 1.0, Date: 12/28/2018         ------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps
module ov7670_controller(input      ov7670_clk50         , 
                         input      reg_conf_rst         ,
                         output     reg_conf_finish      , 
                         output     sioc                 , 
                         inout      siod                 , 
                         output     ov7670_rst           ,    //for ov7670 reset
                         output     pwdn                 ,    //initilize to 0
                         output reg ov7670_xclk          );

wire        token          ;
wire [15:0] command        ; 

assign ov7670_rst = 1      ;
assign pwdn       = 0      ;

always@(posedge ov7670_clk50 or posedge reg_conf_rst) begin
  if(reg_conf_rst) begin
    ov7670_xclk <= 1'b0;
  end else begin
    ov7670_xclk <= ~ov7670_xclk;
  end
end

ov7670_registers         u_reg(.ov7670_clk50    (ov7670_clk50      ),
                               .reg_conf_rst    (reg_conf_rst    ),
                               .token           (token           ), 
                               .command         (command         ), 
                               .reg_conf_finish (reg_conf_finish ));

i2c_sender               u_i2c(.ov7670_clk50    (ov7670_clk50      ), 
                               .reg_conf_rst    (reg_conf_rst    ),
                               .i2c_send        (~reg_conf_finish), 
                               .id              (8'h42           ), 
                               .reg_addr        (command[15:8]   ), 
                               .reg_data        (command[7:0]    ),
                               .siod            (siod            ), 
                               .sioc            (sioc            ), 
                               .token           (token           ));
endmodule

