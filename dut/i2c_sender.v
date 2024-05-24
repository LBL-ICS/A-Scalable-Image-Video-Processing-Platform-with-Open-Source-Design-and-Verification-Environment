//-------------------------------------------------------------------------------------------------------------------------------------
//--------- A Scalable Image/Video Processing Platfrom (OV7670-Nexys4-vga) ------------------------------------------------------------
//--------- Author: Xiaokun Yang                   ------------------------------------------------------------------------------------
//--------- Description: I2C Controller            ------------------------------------------------------------------------------------
//----------Version: 1.0, Date: 12/28/2018         ------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps
module i2c_sender        ( input       ov7670_clk50       , 
                           input       reg_conf_rst       ,
                           input       i2c_send           , 
                           input [7:0] id                 ,
                           input [7:0] reg_addr           , 
                           input [7:0] reg_data           , 
                           inout       siod               , 
                           output reg  sioc               , 
                           output reg  token              ); 
                            
wire [7:0]  nxt_cnt ;
reg  [7:0]  cnt     ;
reg  [31:0] busy_sr ;
reg  [31:0] data_sr ;

//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
wire busy_flag = (busy_sr[11:10]==2'b10) | (busy_sr[20:19]==2'b10) | (busy_sr[29:28]==2'b10);
assign siod = busy_flag ? 1'bz : data_sr[31];

//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
always@(posedge ov7670_clk50 or posedge reg_conf_rst) begin
  if(reg_conf_rst) begin
    token   <= 1'b0        ;
    busy_sr <= 32'h0       ;
    data_sr <= 32'hffffffff;
  end else begin
    token <= 1'b0;
    //if(~busy_sr[31] & i2c_send ) begin
    if(~busy_sr[31] & i2c_send) begin
       data_sr <= {3'b100, id, 1'b0, reg_addr, 1'b0, reg_data, 1'b0, 2'b01};
       busy_sr <= {3'b111, 9'b111111111, 9'b111111111, 9'b111111111, 2'b11};
       token   <= 1'b1;
    end else if (&cnt) begin
       busy_sr <= {busy_sr[30:0],1'b0};
       data_sr <= {data_sr[30:0],1'b1};
    end
  end
end

assign nxt_cnt = busy_sr[31] ? cnt+8'h1 : cnt;
always@(posedge ov7670_clk50 or posedge reg_conf_rst) begin
  if(reg_conf_rst) begin
    cnt <= 8'h0   ;
  end else begin
    cnt <= nxt_cnt;
  end
end
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
wire [5:0] busy_sr_con = {busy_sr[31:29], busy_sr[2:0]};
always@(posedge ov7670_clk50 or posedge reg_conf_rst) begin
  if(~busy_sr[31] | reg_conf_rst) begin
    sioc <= 1'b1;
  end else begin
    case (busy_sr_con)
      //6'b111111: // start seq #1
      6'h3f: // start seq #1
        case (cnt[7:6])
          2'b00  : sioc <= 1'b1;
          2'b01  : sioc <= 1'b1;
          2'b10  : sioc <= 1'b1;
          default: sioc <= 1'b1;
        endcase
      //6'b111110: //start seq #2
      6'h3e: //start seq #2
        case (cnt[7:6])
          2'b00  : sioc <= 1'b1;
          2'b01  : sioc <= 1'b1;
          2'b10  : sioc <= 1'b1;
          default: sioc <= 1'b1;
        endcase
      //6'b111100: //start seq #3
      6'h3c: //start seq #3
        case (cnt[7:6])
          2'b00  : sioc <= 1'b0;
          2'b01  : sioc <= 1'b0;
          2'b10  : sioc <= 1'b0;
          default: sioc <= 1'b0;
        endcase
      //6'b110000: // end seq #1
      6'h30: // end seq #1
        case (cnt[7:6])
          2'b00  : sioc <= 1'b0;
          2'b01  : sioc <= 1'b1;
          2'b10  : sioc <= 1'b1;
          default: sioc <= 1'b1;
        endcase
      //6'b100000: // end seq #2
      6'h20: // end seq #2
        case (cnt[7:6])
          2'b00  : sioc <= 1'b1;
          2'b01  : sioc <= 1'b1;
          2'b10  : sioc <= 1'b1;
          default: sioc <= 1'b1;
        endcase
      //6'b000000: // Idle
      6'h00: // Idle
        case (cnt[7:6])
          2'b00  : sioc <= 1'b1;
          2'b01  : sioc <= 1'b1;
          2'b10  : sioc <= 1'b1;
          default: sioc <= 1'b1;
        endcase
      default: 
        case (cnt[7:6])
          2'b00  : sioc <= 1'b0;
          2'b01  : sioc <= 1'b1;
          2'b10  : sioc <= 1'b1;
          default: sioc <= 1'b0;
        endcase
    endcase   
  end
end 



endmodule
