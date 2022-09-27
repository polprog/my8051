module simpleuart 
  #(
    parameter SFR_ADDRESS=8'h90,
    parameter BAUD_DIVISOR=8'h02
    ) (
       input wire 	rst,
       input wire 	iclk,
       input wire 	ram_wr_en_sfr,
       input wire [7:0] ram_wr_addr,
       input wire [7:0] ram_wr_byte,
       //		  input        ram_rd_en_sfr,
       //		  input        ram_rd_addr,
       //		  output [7:0] ram_rd_byte,
       output reg 	tx,
       //output reg 	test_baud, 
       //input wire 	rx,
       output reg [1:0] state	
       );
   
   parameter STATE_IDLE = 2'b00;
   parameter STATE_START = 2'b01;
   parameter STATE_BITS  = 2'b10;
   parameter STATE_STOP  = 2'b11;
   

   reg [3:0] 		bit_counter = 4'b0;
   //reg [1:0] 		state = 2'b00; // = STATE_IDLE;
   
   reg [9:0] 		data;
   reg [7:0] 		datain;

 
   // Baudrate generator
   reg 			baud_clk = 0;
   reg [7:0] 		baud_counter = 8'b0;

   
   
   always @ (posedge iclk) begin
      if (rst == 1) begin
	 state <= STATE_IDLE;
	 data <= 10'b0;
	 
      end else if (ram_wr_en_sfr == 1 && state == STATE_IDLE ) begin
	 //Write byte to fifo
         data <= {1'b0, ram_wr_byte, 1'b1};
	 state <= STATE_BITS;
	 bit_counter <= 0;
	 
      end
      // Baudrate generator and state machine
      if(baud_counter < BAUD_DIVISOR) begin			     
	 baud_counter <= baud_counter + 1 ;	 
	 //on each baudrate generator tick we advance the FSM
      end else begin
	 baud_counter <= 8'b0;
	 case (state)
	   STATE_IDLE: begin 
	      tx <= 1'b1;
	      	      
	   end
	   STATE_BITS: begin  
	      //tx <= !tx; //TEST
	      tx <= data[9];
	      data <= {data[8:0], 1'b0};
	      bit_counter <= bit_counter + 1;
	      if(bit_counter == 9) begin state <= STATE_STOP; end
	      
	   end
	   STATE_STOP: begin
	      tx <= 1'b1;
	      state <= STATE_IDLE;
	      bit_counter <= 0;	      
	   end
	 endcase // case (state)
      end			    
   end // always @ (posedge iclk)
  
   
   
 
endmodule // simpleuart
