module synth_top(KEY, CLOCK_50, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, PS2_CLK, PS2_DAT);

  input CLOCK_50;  
  input [3:0] KEY;
  input PS2_CLK;
  input PS2_DAT;

  output VGA_CLK;
  output VGA_HS;
  output VGA_VS;
  output VGA_BLANK_N;
  output VGA_SYNC_N;
  output [9:0] VGA_R;
  output [9:0] VGA_G;
  output [9:0] VGA_B;

  wire reset;
  assign reset = KEY[0];

  wire [2:0] colour;
  wire [7:0] x;
  wire [6:0] y;
  wire plot;
  wire [3:0] keyboard_data;

  vga_adapter VGA(
    .resetn(reset), 
    .clock(CLOCK_50), 
    .colour(colour), //Yet to be assigned 
    .x(x), //Yet to be assigned 
    .y(y), //Yet to be assigned 
    .plot(plot), //Yet to be assigned
    .VGA_CLK(VGA_CLK), 
    .VGA_HS(VGA_HS), 
    .VGA_VS(VGA_VS),
    .VGA_BLANK(VGA_BLANK_N), 
    .VGA_SYNC(VGA_SYNC_N), 
    .VGA_R(VGA_R), 
    .VGA_G(VGA_G), 
    .VGA_B(VGA_B)
  );
  defparam VGA.RESOLUTION = "160x120";
  defparam VGA.MONOCHROME = "FALSE";
  defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;

  gui g(
    .clock(CLOCK_50), 
    .reset(reset), 
    .keys(keyboard_data[3:0]), 
    .colour(colour), 
    .x(x), 
    .y(y), 
    .plot(plot)
  );

  keyboard k(
    .clock(PS2_CLK), 
    .char(PS2_DAT), 
    .keyboard_data(keyboard_data) 
  );
endmodule
