`timescale 1ns / 1ns
module gui(clock, reset, keys, colour, x, y, plot); 
	
  input clock;
  input reset; 
  input [3:0] keys;

  output [2:0] colour;
  output [7:0] x;
  output [6:0] y;
  output plot;

  wire redraw;
  wire [3:0] keys_pressed;
  wire [14:0] clock_count; 
  
  controlgui g(
    .clock(clock), 
    .reset(reset), 
    .plot(plot), 
    .keys(keys), 
    .redraw(redraw), 
    .clock_count(clock_count), 
    .keys_pressed(keys_pressed) 
  ); 

  datapathgui d(
    .clock(clock), 
    .reset(reset), 
    .redraw(redraw), 
    .keys_pressed(keys_pressed), 
    .clock_count(clock_count), 
    .colour(colour),
    .x(x), 
    .y(y) 
 ); 
endmodule

module controlgui(clock, reset, keys, plot, redraw, clock_count, keys_pressed);
  input clock, reset;
  input [3:0] keys;

  //Remove unnecessary regs
  output reg [3:0] keys_pressed; 
  output reg plot, redraw; 
  output reg [14:0] clock_count; 

  reg [2:0] current_state, next_state; //Does this? Yes

  localparam REDRAW = 3'b000,
             STATIONARY = 3'b001, 
             KEY_ONE_PRESSED = 3'b010; 
  /*
  * Can be reset for testing purposes 
  */
  parameter PIXEL_COUNT = 15'b111100010100001;

  always @(posedge clock) begin
    if (!reset) begin 
     current_state <= REDRAW;
     clock_count <= 15'b000000000000000;
     keys_pressed <= 4'b0;
    end 
    else begin 
      current_state <= next_state;
      if (current_state != STATIONARY) begin 
        clock_count <= clock_count + 1'b1;
      end 
    end 
  end   
  
  always @(*) 
  begin: state_table
    case (current_state)
      REDRAW: next_state = clock_count == PIXEL_COUNT ? STATIONARY : REDRAW;
      STATIONARY: begin 
        if (keys[0] == 1'b1) begin 
          next_state = KEY_ONE_PRESSED;
        end
        else begin 
          next_state = REDRAW;
        end 
      end
      KEY_ONE_PRESSED: next_state = clock_count == PIXEL_COUNT ? STATIONARY : KEY_ONE_PRESSED;
      default: next_state = REDRAW;
    endcase
  end 

  //datapath control signals 
  always @(*)
  begin: signals 
    plot = 1'b0;
    keys_pressed = 4'b0;
    case (current_state)
      REDRAW: begin 
        plot = 1'b1;
        redraw = 1'b1;
      end 
      STATIONARY: begin 
        clock_count = 15'b0;
      end 
      KEY_ONE_PRESSED: begin 
        plot = 1'b1;
        redraw = 1'b1;
        keys_pressed = 4'b0001;
      end
    endcase
  end 
endmodule

module datapathgui(clock, reset, redraw, keys_pressed, colour, x, y, clock_count);
  input clock, reset, redraw;
  input [14:0] clock_count;
  input [3:0] keys_pressed;

  //Remove unnecessary regs
  output reg [2:0] colour;
  output reg [7:0] x;
  output reg [6:0] y;

  /*
  * Don't need these
  */
  reg [7:0] temp_x;
  reg [6:0] temp_y;

  localparam WHITE = 3'b111, 
             BLACK = 3'b000, 
             RED   = 3'b100; 

  parameter FIRST_DIVIDER = 8'b00100111; 
  parameter SECOND_DIVIDER = 8'b01001111;
  parameter THIRD_DIVIDER = 8'b01110111;

  parameter MAX_X = 8'b10100000;
  parameter MAX_Y = 7'b1111000;
  always @(posedge clock) begin 
    if (!reset) begin
      x <= 8'b0;
      y <= 8'b0;
      colour <= 3'b0;
      temp_x <= 8'b0;
      temp_y <= 7'b0;
    end 
    else if (redraw) begin 
      if (clock_count[7:0] == FIRST_DIVIDER || clock_count[7:0] == SECOND_DIVIDER || clock_count[7:0] == THIRD_DIVIDER) begin 
        colour <= BLACK;
      end
      else begin 
        if (keys_pressed == 4'b001 & clock_count[7:0] < FIRST_DIVIDER) begin 
          colour <= RED;
        end 
        else begin 
          colour <= WHITE;
        end 
      end 

      if (!(clock_count[7:0] > MAX_X)) begin 
 	 x <= temp_x + clock_count[7:0];
      end 
      if (!(clock_count[14:8] > MAX_Y)) begin
 	 y <= temp_y + clock_count[14:8];
      end 
    end 
  end
endmodule
