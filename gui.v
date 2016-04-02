`timescale 1ns / 1ns
module gui(clock, reset, keys, mode, colour, x, y, plot); 
  input clock;
  input reset; 
  input [3:0] keys;
//  input [1:0] mode;

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
 //   .mode(mode),
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

  reg [2:0] current_state, next_state; 

  localparam REDRAW = 3'b000,
             STATIONARY = 3'b001, 
             KEY_ONE_PRESSED = 3'b010, 
             KEY_TWO_PRESSED = 3'b011, 
             KEY_THREE_PRESSED = 3'b100, 
             KEY_FOUR_PRESSED = 3'b101; 
  /*
  * Can be reset for testing purposes 
  */
  parameter PIXEL_COUNT = 15'b111100010100001;

  always @(posedge clock) begin
    if (!reset) begin 
     current_state <= REDRAW;
    end 
    else begin 
      current_state <= next_state;
      if (current_state != STATIONARY) begin 
        clock_count <= clock_count + 1'b1;
      end 
      else begin 
        clock_count <= 15'b0;
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
        else if (keys[1] == 1'b1) begin 
          next_state = KEY_TWO_PRESSED;
        end 
        else if (keys[2] == 1'b1) begin 
          next_state = KEY_THREE_PRESSED;
        end 
        else if (keys[3] == 1'b1) begin 
          next_state = KEY_FOUR_PRESSED;
        end 
        else begin 
          next_state = REDRAW;
        end 
      end
      KEY_ONE_PRESSED: next_state = clock_count == PIXEL_COUNT ? STATIONARY : KEY_ONE_PRESSED;
      KEY_TWO_PRESSED: 
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
      KEY_ONE_PRESSED: begin 
        plot = 1'b1;
        redraw = 1'b1;
        keys_pressed = 4'b0001;
      end
      KEY_TWO_PRESSED: begin 
        plot = 1'b1; 
        redraw = 1'b1;
        keys_pressed = 4'b0010;
      end 
      KEY_THREE_PRESSED: begin 
        plot = 1'b1; 
        redraw = 1'b1;
        keys_pressed = 4'b0100;
      end 
      KEY_FOUR_PRESSED: begin 
        plot = 1'b1;
        redraw = 1'b1;
        keys_pressed = 4'b1000;
      end 
    endcase
  end 
endmodule

module datapathgui(clock, reset, redraw, keys_pressed, colour, mode, x, y, clock_count);
  input clock, reset, redraw;
  input [1:0] mode;
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
             BLUE = 3'b001, 
             RED = 3'b100; 

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
//      if (clock_count[1:0] < 3'b100 & clock_count[9:8] < 3'b100 & mode[1:0] > 1'b0) begin 
//        if (mode[1:0] == 2'b01) begin 
//          colour <= RED; //RECORDING 
 //       end 
  //      else begin 
   //       colour <= GREEN; //PLAYBACK
//        end 
 //     end 
      if (clock_count[7:0] == FIRST_DIVIDER || clock_count[7:0] == SECOND_DIVIDER || clock_count[7:0] == THIRD_DIVIDER) begin 
        colour <= BLACK;
      end
      else begin 
        if (keys_pressed == 4'b0001 & clock_count[7:0] < FIRST_DIVIDER) begin // First key 
          colour <= BLUE;
        end 
        else if (keys_pressed == 4'b0010 & clock_count[7:0] > FIRST_DIVIDER & clock_count[7:0] < SECOND_DIVIDER) begin // Second key
          colour <= BLUE;
        end 
        else if (keys_pressed == 4'b0100 & clock_count[7:0] > SECOND_DIVIDER & clock_count[7:0] < THIRD_DIVIDER) begin // Third key
          colour <= BLUE;
        end 
        else if (keys_pressed == 4'b1000 & clock_count[7:0] > THIRD_DIVIDER ) begin // Fourth key
          colour <= BLUE;
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
