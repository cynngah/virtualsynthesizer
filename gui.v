module gui(SW, KEY, CLOCK_50, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);
	
  input [9:0] SW;
  input CLOCK_50;  
  input [3:0] KEY;

  output VGA_CLK;
  output VGA_HS;
  output VGA_VS;
  output VGA_BLANK_N;
  output VGA_SYNC_N;
  output [9:0] VGA_R;
  output [9:0] VGA_G;
  output [9:0] VGA_B;

	
  wire [2:0] colour;
  wire [7:0] x;
  wire [6:0] y;
  wire plot;
  wire redraw;
  wire [14:0] clock_count; 
  wire [3:0] pressed_keys;
  
  wire reset;
  
  assign reset = KEY[0];
 
  vga_adapter VGA(
    .resetn(reset), 
    .clock(CLOCK_50), 
    .colour(colour), 
    .x(x), 
    .y(y), 
    .plot(plot), 
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
 

   
  controlgui g(
    .clock(CLOCK_50), 
    .reset(reset), 
    .plot(plot), 
    .redraw(redraw), 
    .clock_count(clock_count), 
	.pressed_keys(pressed_keys)
  ); 

  datapathgui d(
    .clock(CLOCK_50), 
    .reset(reset), 
    .redraw(redraw), 
	.pressed_keys(pressed_keys),
    .colour(colour), 
    .x(x), 
    .y(y), 
    .clock_count(clock_count)
 ); 
endmodule


module controlgui(clock, reset, plot, redraw, clock_count, pressed_keys);
  
  input clock, reset;
  output reg plot, redraw;
  output reg [14:0] clock_count;
  output reg [3:0] pressed_keys;

  reg [2:0] current_state, next_state;

  localparam REDRAW = 3'b000,
			 STATIONARY = 3'b001, 
			 KEY_ONE_PRESSED = 3'b010, 
			 KEY_TWO_PRESSED = 3'b011, 
			 KEY_THREE_PRESSED = 3'b100, 
			 KEY_FOUR_PRESSED = 3'b101; 
             
  always @(posedge clock) begin
    if (!reset) begin 
     current_state <= REDRAW;
     clock_count <= 15'b000000000000000;
    end 
    else begin 
      current_state <= next_state;
      if (current_state == REDRAW) begin 
        clock_count <= clock_count + 1'b1;
      end 
    end 
  end   
  
  always @(*) 
  begin: state_table
  /*
    case (current_state)
      REDRAW: next_state = clock_count == 15'b111100010100001 ? STATIONARY : REDRAW;
      default: next_state = REDRAW;
    endcase
  */
	if (pressed_keys[3:0] > 4'b0000) begin 
		if (pressed_keys[0]) begin 
			next_state = KEY_ONE_PRESSED;
		end 
		else if (pressed_keys[1]) begin 
			next_state = KEY_TWO_PRESSED;
		end 
		else if (pressed_keys[2]) begin 
			next_state = KEY_THREE_PRESSED;
		end 
		else if (pressed_keys[3]) begin 
			next_state = KEY_FOUR_PRESSED;
		end
	end
	else begin 
		if (!(clock_count == 15'b111100010100001)) begin 
			next_state = REDRAW;
		end
		else begin 
			next_state = STATIONARY;
		end
	end
	
  end 
  //datapath control signals 
  always @(*)
  begin: signals 
    plot = 1'b0;
	pressed_keys = 4'b0000;
    case (current_state)
      REDRAW: begin 
        plot = 1'b1;
        redraw = 1'b1;
      end 
	  KEY_ONE_PRESSED: begin 
		plot = 1'b1;
		pressed_keys = 4'b0001;
	  end
	  KEY_TWO_PRESSED: begin 
		plot = 1'b1;
		pressed_keys = 4'b0010;
	  end 
	  KEY_THREE_PRESSED: begin 
		plot = 1'b1;
		pressed_keys = 4'b0100;
	  end
	  KEY_FOUR_PRESSED: begin 
		plot = 1'b1;
		pressed_keys = 4'b1000;
	  end 
    endcase
  end 
endmodule

module datapathgui(clock, reset, redraw, pressed_keys, colour, x, y, clock_count);
  input clock, reset, redraw;
  input [14:0] clock_count;
  input [3:0] pressed_keys;

  output reg [2:0] colour;
  output reg [7:0] x;
  output reg [6:0] y;

  reg [7:0] temp_x;
  reg [6:0] temp_y;

  always @(posedge clock) begin 
    if (!reset) begin
      x <= 8'b0;
      y <= 8'b0;
      colour <= 3'b0;
      temp_x <= 8'b0;
      temp_y <= 7'b0;
    end 
    else if (redraw) begin 
	   if (clock_count[7:0] == 8'b00100111 || clock_count[7:0] == 8'b01001111 || clock_count[7:0] == 8'b01110111 ) begin 
		  colour <= 3'b000;
	   end
	   else begin 
		  colour <= 3'b111;
	   end 
      if (!(clock_count[7:0] > 8'b10100000)) begin 
		x <= temp_x + clock_count[7:0];
	  end 
      if (!(clock_count[14:8] > 7'b1111000)) begin
		y <= temp_y + clock_count[14:8];
	  end 
    end 
	else if (pressed_keys > 4'b0000) begin 
		
	end
  end 
endmodule
