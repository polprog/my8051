module testport (
		 input wire [7:0] in,
		 input wire 	  rst,
		 input wire 	  latch,
		 output reg [7:0] out);

   initial begin
      out <= 8'b0;
   end

   always @ (negedge rst) begin 
      out <= 8'b0;
   end
   
   always @ (posedge latch) begin
      out <= in;      
      $display("Testport: output %2h", out);
   end
endmodule

module simpleport #(parameter SFR_ADDRESS = 8'h80) (
	   input 	    ram_wr_en_sfr,
	   input [7:0] 	    ram_wr_addr,
	   input [7:0] 	    ram_wr_byte,
	   output reg [7:0] out
	   );
   
   initial begin
      out <= 8'b0;
   end

   always @ (posedge ram_wr_en_sfr ) begin
      if(ram_wr_addr == SFR_ADDRESS) begin
	 out <= ram_wr_byte;
	 $display("Testport2@%2h: write %2h", SFR_ADDRESS, out);
      end
      

   end
endmodule
   
	   
