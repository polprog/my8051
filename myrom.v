module my_rom(
	      input wire enable,
	      input wire[15:0] addr,
	      output reg[7:0] data
      );
   always @* begin
      case (addr)
	16'h0000: data = 8'h00; //nop
	16'h0001: data = 8'h00; //
	16'h0002: data = 8'h00; //
	16'h0003: data = 8'h00; //
	16'h0004: data = 8'h00; //
	16'h0005: data = 8'h00; //
	16'h0006: data = 8'hF5; //mov 91, A
	16'h0007: data = 8'h91; //----^^
	16'h0008: data = 8'h04; // inc a
 	16'h0009: data = 8'h00; // ljmp
	16'h000A: data = 8'h00; 
	16'h000B: data = 8'h00; // nop
	16'h000C: data = 8'h00; // nop
	16'h000D: data = 8'h00; // nop
	16'h000E: data = 8'h00; // imm16 1/2
	16'h000F: data = 8'h00; // imm16 2/2
	default: data = 8'h00;
	16'h00FD: data = 8'h02;
	16'h00FE: data = 8'h00;
	16'h00FF: data = 8'h00;
	
      endcase // case (addr)      
   end // always @ *


endmodule // my_rom


// TEST CODE: mov 90, A; inc A, noppad until 0dh; ljmp 0000;
//  f5 90 04 02
//  00 00 00 00
//  00 00 00 00 
//  00 02 00 00
