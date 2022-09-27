module test();
 
   reg  clk = 1'b0;
   wire [7:0] PORTB;
   wire       oclk;
   wire       oclk2;
   wire       xtest;
   wire       tx1;
   wire       rx1;
   wire       rst;
   wire [1:0] state;

   
   
   
   initial begin
      $dumpfile("8051.vcd");
      $dumpvars(0, cpu);
      
      #5000 $finish;
   end
   
   always #1 begin
      clk = ~clk;
   end

   wire wclk;
   assign wclk = clk;
   
   top8051 cpu (wclk, PORTB, oclk, oclk2, xtest, tx1, state[1:0], rst);
   
endmodule

   
