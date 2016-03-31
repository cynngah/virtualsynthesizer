`timescale 1ns / 1ns
module recorder(clock, reset, go, mode, keys);
  input clock;
  input reset;
  input go;
  input [3:0] keys 

  output [1:0] mode;

  wire recording;
  wire playing_back;
  
  controlrecorder cr(
    .clock(clock), 
    .go(go),
    .reset(reset), 
    .recording(recording), 
    .playing_back(playing_back), 
    .mode(mode[1:0])
  );

endmodule 

module controlrecorder(clock, reset, recording, playing_back, mode, go);
  input clock, reset, go;

  output [1:0] mode
  output recording, playing_back;

  reg [1:0] current_state, next_state;
  reg [4:0] ram_cell;
  
  localparam STATIONARY = 2'b00,
             RECORDING  = 2'b01, 
             PLAYING    = 2'b10;
  
  parameter NUM_RAM_CELLS = 5'b11101;
  always @(posedge clock) begin 
    if (!reset) begin 
      current_state <= STATIONARY; 
      mode <= 2'b0;
      ram_cell <= 5'b0;
    end 
    else begin 
      current_state <= next_state;
      if (current_state == RECORDING || current_state == PLAYING) begin
        /*
        * Only if clock count is 50,000,000 OR a key is entered
        */
        ram_cell <= ram_cell + 1'b1; //Not the right place to put this
      end 
    end 
  end

  always @(*)
  begin: state_table
    case (current_state)
      STATIONARY: next_state = go == 1'b0 ? ALMOST_RECORDING : STATIONARY;
      ALMOST_RECORDING: next_state = go == 1'b1 ? RECORDING : ALMOST_RECORDING;
      RECORDING: next_state = ram_cell == NUM_RAM_CELLS ? READY_FOR_PLAYBACK : RECORDING;
      READY_FOR_PLAYBACK: next_state = go == 1'b0 ? ALMOST_PLAYING_BACK : READY_FOR_PLAYBACK;
      ALMOST_PLAYING_BACK: next_state = go == 1'b1 ? PLAYBACK : ALMOST_PLAYING_BACK;
      PLAYBACK: next_state = ram_cell == NUM_RAM_CELLS ? STATIONARY : PLAYBACK;
    endcase
  end

  always @(*) 
  begin: signals 
    mode = 2'b0;
    recording = 1'b0;    
    playing_back = 1'b0;
    case (current_state)
      RECORDING: begin 
        recording = 1'b1;
        mode = 2'b01;
      end 
      PLAYING_BACK: begin 
        mode = 2'b10;
        playing_back = 1'b1;
      end 
    endcase
  end

endmodule
