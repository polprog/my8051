module top8051(
	  input wire 	    iclk,
	  output wire [7:0] PORTA,
	  //output wire [7:0] PORTB,
	  output reg 	    oclk,
	  output reg 	    oclk2,
	  output reg 	    xtest,
	  output reg 	    TX1,
	  output reg [1:0]  state,
	  output reg 	    rst
	       
);
   integer i = 0; //counter for init loops

   reg 	   clk;

   //program memory
   reg [7:0]  progmem[255:0];

   
   wire    rom_en;
   wire [15:0] rom_addr;
   reg [7:0]   rom_byte;
   reg 	       rom_vld;

   wire        ram_rd_en_data;
   wire        ram_rd_en_sfr;
   wire        ram_rd_en_xdata;
   wire [15:0] ram_rd_addr;

   reg [7:0]   ram_rd_byte;

   wire        ram_wr_en_data;
   wire        ram_wr_en_sfr;
   wire        ram_wr_en_xdata;
   wire [15:0] ram_wr_addr;
   wire [7:0]  ram_wr_byte;

   wire [7:0]  rom_data;

  
   reg [3:0] 		    reset_count;

   reg [7:0] 		    pabuf;
   
   
   //Clock divider 
   `ifndef TEST_ICARUS
   clkdiv #(.DIV(100000)) system_clock(iclk, clk);
   /* Internal reset, start CPU after 16 cycles on boot */
   always @(posedge clk) begin
      if(reset_count < 4'b1111) begin
	 rst <= 1;
	 reset_count <= reset_count + 1;
      end else begin
	 rst <= 0;
      end
   end
   assign oclk = iclk;
   assign oclk2 = clk;
   assign xtest = ram_wr_en_sfr;
   //assign PORTA = rom_byte;
   assign PORTA = pabuf;
   //assign PORTA = rom_addr[7:0];
   
   
   `else
   always @ (iclk) begin
      clk = iclk;
   end
   `endif
   
   /*
   */
   //Populate program memory from hex file
   initial begin
      //WARNING: This is not for reading ihex files
      $readmemh("test_code/knightrider.mem", progmem);
   end
   
   
   //CPU ROM LUT
   //my_rom testrom (clk, rom_en, rom_addr, rom_data);

   //sfr(90) porta
   simpleport #(.SFR_ADDRESS(8'h90)) port1 (ram_wr_en_sfr, ram_wr_addr[7:0], ram_wr_byte[7:0], pabuf);

   //sfr(91) uart
   //   simpleuart #(.SFR_ADDRESS(8'h91)) uart1 (rst, clk, ram_wr_en_sfr, ram_wr_addr[7:0], ram_wr_byte[7:0], /* TODO: rest of signals */ TX1, /*RX1*/ state);
   
   
   //CPU core
   r8051 u_cpu (
       		.clk                  (    clk              ),
		.rst                  (    rst              ),
		.cpu_en               (    1'b1             ),
		.cpu_restart          (    1'b0             ),
      
		.rom_en               (    rom_en           ),
		.rom_addr             (    rom_addr         ),
		.rom_byte             (    rom_byte         ),
		//.rom_vld              (    rom_vld          ),
		.rom_vld              (    1'b1          ),
		.ram_rd_en_data       (    ram_rd_en_data   ),
		.ram_rd_en_sfr        (    ram_rd_en_sfr    ),
		.ram_rd_en_xdata      (    ram_rd_en_xdata  ),
		.ram_rd_addr          (    ram_rd_addr      ),
		.ram_rd_byte          (    ram_rd_byte      ),
		.ram_rd_vld           (    1'b1             ),
      
		.ram_wr_en_data       (    ram_wr_en_data   ),
		.ram_wr_en_sfr        (    ram_wr_en_sfr    ),
		.ram_wr_en_xdata      (    ram_wr_en_xdata  ),
		.ram_wr_addr          (    ram_wr_addr      ),
		.ram_wr_byte          (    ram_wr_byte      )

		);


   
   //Loading bytes from rom
   always @ ( posedge clk ) begin
     if ( rom_en ) begin
       rom_byte <= progmem[rom_addr];
	//rom_byte <= 8'h55;
	
     end   //ROM data valid signal
      rom_vld <=  rom_en;
   end

   //DATA RAM setup, 127 bytes
   reg [7:0] data [127:0];
   reg [7:0] data_rd_byte;
   //DATA RAM init with 0xCC
   initial begin
      for(i = 0; i < 127; i = i + 1) begin
	 data[i] = 8'hCC;
      end
   end
   
   //DATA RAM data read logic
   always @ ( posedge clk )
     if ( ram_rd_en_data ) begin
       data_rd_byte <=  data[ram_rd_addr[6:0]];
     end
   //DATA RAM data write logic
   always @ ( posedge clk )
     if ( ram_wr_en_data ) begin
       data[ram_wr_addr[6:0]] <=  ram_wr_byte;
     end

   //XDATA setup
   reg [7:0] xdata [127:0];
   reg [7:0] xdata_rd_byte;
   //XDATA init with 0xBB
   initial begin
      for(i = 0; i < 127; i = i + 1) begin
	 xdata[i] = 8'hBB;
      end
   end
   
   always @ ( posedge clk ) begin
     //XDATA read
      if ( ram_rd_en_xdata ) begin
	xdata_rd_byte <=  xdata[ram_rd_addr[6:0]];
      end
      //XDATA write
      if ( ram_wr_en_xdata ) begin
	xdata[ram_wr_addr[6:0]] <=  ram_wr_byte;
      end
   end
  
   
   //SFR handling logic, SFR is any address with addr[7] == 1
   reg [7:0] sfr_rd_byte;
   reg [7:0] sfr_wr_byte;

   //SFR r/w handling. SFR F0 (register B) handled insire r8051
   always @ ( posedge clk ) begin
      if ( ram_rd_en_sfr ) 
	begin
           $display("SFR read: sfr(%2h) == %2h",ram_rd_addr[7:0], ram_rd_byte[7:0]);
	   sfr_rd_byte <= 8'h55; //hardcode all SFR reads to 55
	end
      if ( ram_wr_en_sfr) begin
	 $display("SFR write: %2h -> sfr(%2h)",
		  ram_wr_byte[7:0], ram_wr_addr[7:0]
		  );
      end
   end
      
   
   //Read muxing between data, xdata and SFR based on CPU signals
   reg [1:0] read_flag; //10 = SFR; 01 = XDATA; 00 = DATA
   
   always @ ( posedge clk )
     if ( ram_rd_en_sfr )
       read_flag <= 2'b10;
     else if ( ram_rd_en_xdata )
       read_flag <= 2'b01;	
     else if ( ram_rd_en_data )
       read_flag <= 2'b00;
     else;
   
   always @*
     if ( read_flag[1] )
       ram_rd_byte = sfr_rd_byte;
     else if ( read_flag[0] )
       ram_rd_byte = xdata_rd_byte;
     else
       ram_rd_byte = data_rd_byte;
   
endmodule

module clkdiv #(parameter DIV = 24'd5000)(
    input wire iclk,
    output wire oclk
    );
	 
	reg [24:0] count = 24'b0;
	reg oclk_internal = 1;
	//on this board we have a 50MHz clock
	
	always @(posedge iclk) begin
		count <= count + 24'b1;
		if(count == DIV) begin
			count <= 24'b0;
			oclk_internal <= ~oclk_internal;
		end
	end
	assign oclk = oclk_internal;
endmodule
