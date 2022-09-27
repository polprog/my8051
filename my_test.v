module tb(
	  output wire [7:0] PORTA,
	  output wire [7:0] PORTB
);
   integer i = 0; //counter for init loops

   reg     clk = 1'b0;

   reg     rst = 1'b1;

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

   reg 	       port1_latch;
   reg [7:0]   port1_data;
   

   my_rom testrom (rom_en, rom_addr, rom_data);

   //sfr(80) porta
   simpleport #(.SFR_ADDRESS(8'h80)) port1 (ram_wr_en_sfr, ram_wr_addr[7:0], ram_wr_byte, PORTA);
   //sfr(90) portb
   simpleport #(.SFR_ADDRESS(8'h90)) port2 (ram_wr_en_sfr, ram_wr_addr[7:0], ram_wr_byte, PORTB);
   
   
   r8051 u_cpu (
		.clk                  (    clk              ),
		.rst                  (    rst              ),
		.cpu_en               (    1'b1             ),
		.cpu_restart          (    1'b0             ),
      
		.rom_en               (    rom_en           ),
		.rom_addr             (    rom_addr         ),
		.rom_byte             (    rom_byte         ),
		.rom_vld              (    rom_vld          ),
      
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

   //Clock generation
   always  #1 clk <= !clk;

   //Simulation setup
   initial begin
      $dumpfile("8051.vcd");
      $dumpvars(0, u_cpu);
      $dumpvars(0, testrom);
      $dumpvars(0, port1);
      $dumpvars(0, port2);
      
      
      
      #1 rst <= 1'b0;
      
      #1000 $finish;

   end

   
   //Loading bytes from rom
   always @ ( posedge clk )
     if ( rom_en )
       rom_byte <=  rom_data;
     else;
   //ROM data valid signal
   always @ ( posedge clk )
     rom_vld <=  rom_en;


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
	 //PORTa at sfr(CC)
	 if( ram_wr_byte[7:0] == 8'hCC ) begin
	    port1_data <= ram_wr_byte;
	    port1_latch <= 1;
	    #1 port1_latch <= 0;
	    
	 end
	 
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
