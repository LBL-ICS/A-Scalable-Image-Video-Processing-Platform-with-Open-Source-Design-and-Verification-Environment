/*******************************
// Functions: one ports, one clock, synchronous RAM
// Designer:  xkyang
// Dates:     2013/01/13
*******************************/

module ram_320x240(	
                   clk_a  ,
                   clk_b  ,
		               //rst_n  ,
                   wdata  ,
                   raddr  ,
                   waddr  ,
                   wr     ,
                   //rd     ,
                   rdata 
                  );

/*******************************
// define parameter
*******************************/
parameter  DATASIZE = 12;		// Memory data word width
parameter  ADDRSIZE = 17;		// Number of memory address bits
localparam DEPTH = 1<<ADDRSIZE;		// DEPTH = 2 ^ ADDRSIZE

/*******************************
// ports declaration
*******************************/
input                 clk_a   ;
input                 clk_b   ;
//input                 rst_n   ;
input  [DATASIZE-1:0] wdata   ;
input  [ADDRSIZE-1:0] waddr   ;
input                 wr      ;

//input		              rd      ;
input  [ADDRSIZE-1:0] raddr   ;
output [DATASIZE-1:0] rdata   ; 

wire   [DATASIZE-1:0] rdata; 
reg    [DATASIZE-1:0] mem [0:DEPTH-1];

/*******************************
// code 
*******************************/
always @(posedge clk_a) begin
    if(wr) begin
        mem[waddr] <= wdata;
    end
end

assign  rdata  = mem[raddr];
//always @(posedge clk_b or negedge rst_n) begin
//    if(!rst_n)begin
//        rdata  <= 12'h0 ; 
//    end else if(rd) begin
//        rdata  <= mem[raddr]; 
//    end
//end

endmodule
