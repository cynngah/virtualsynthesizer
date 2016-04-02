module topkeyboard(CLOCK_50, LEDR, PS2_CLK, PS2_DATA);
  
  output LEDR[9:0];
  wire reset;
  assign reset = KEY[0];
  
  wire read;
  wire scan_ready;
  wire [7:0] scan_code;
  
  controlread c( 
    .clock(clock), 
    .reset(reset), 
    .scan_ready(scan_ready), 
    .read(read)
  );
  
  keyboard k(
    .keyboard_clk(PS2_CLK), 
    .keyboard_data(PS2_DAT), 
    .clock50(CLOCK_50), 
    .reset(reset), 
    .read(read), 
    .scan_ready(scan_ready), 
    .scan_code(scan_code)
  );

  always @(scan_code) begin 
    if (scan_code == 8'h1C) begin 
      LEDR[9:0] = 10'b1;
    end   
  end 
endmodule 

module controlread(clock, reset, scan_ready, read);
  input clock, reset, scan_ready;
  output read;

  always @(posedge clock)
    if (!reset) begin 
      read = 1'b0;
    end 
  begin 
    if (scan_ready) begin 
      read = 1'b1;
    end 
    else begin 
      read = 1'b0;
    end 
  end 
endmodule
