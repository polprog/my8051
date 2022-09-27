module my_rom(
	      input wire 	iclk,
	      input wire 	enable,
	      input wire [15:0] addr,
	      output reg [7:0] 	data
      );
   reg [7:0] 		      memory[255:0];

   initial begin
      $readmemh("test_code/uart_simple.ihx", memory);
   end

   always @(posedge iclk) begin
      //data <= addr[7:0];
      data <= memory[addr[7:0]];
      
   end
   
endmodule
