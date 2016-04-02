module sound (switches, clock50, clock2_50, key, fpga_i2c_sclk, fpga_i2c_sdat, aud_xck, 
	      aud_daclrck, aud_adclrck, aud_bclk, aud_adcdat, aud_dacdat);

	input clock50, clock2_50;
        input [3:0] switches;
	input [0:0] key;

	// I2C Audio/Video config interface
	output fpga_i2c_sclk;
	inout fpga_i2c_sdat;
	// Audio CODEC
	output aud_xck;
	input aud_daclrck, aud_adclrck, aud_bclk;
	input aud_adcdat;
	output aud_dacdat;
	
	// Local wires.
	wire read_ready, write_ready, write, read;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~key[0];
 //       wire [7:0] counter;

        //frequency wires
        wire [3:0] frequency;

        control cg(
          .clock(clock50), 
          .reset(reset), 
          .switches(switches),
          .write_ready(write_ready), 
          .write(write), 
          .writedata_left(writedata_left), 
          .writedata_right(writedata_right)
//          .frequency(frequency), 
  //        .counter(counter)
        );

/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		clock2_50,
		reset,

		// outputs
		aud_xck
	);

	audio_and_video_config cfg(
		// Inputs
		clock50,
		reset,

		// Bidirectionals
		fpga_i2c_sdat,
		fpga_i2c_sclk
	);

	audio_codec codec(
		// Inputs
		clock50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		aud_adcdat,

		// Bidirectionals
		aud_bclk,
		aud_adclrck,
		aud_daclrck,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		aud_dacdat
	);
endmodule

module control(clock, reset, write_ready, write, frequency, 
               writedata_left, writedata_right);
  input clock, reset, write_ready;
  input [3:0] switches;
  output reg write;
  output reg [23:0] writedata_left, writedata_right;
//  output reg [3:0] frequency;
  reg [7:0] counter;

//  reg [2:0] current_state, next_state;
  
/*
  localparam NO_SOUND = 3'b000, 
             FREQ_ONE = 3'b001, 
             FREQ_TWO = 3'b010, 
             FREQ_THREE = 3'b011,
             FREQ_FOUR = 3'b100;
*/

  always @(posedge clock) begin 
    if (!reset) begin 
 //     current_state <= NO_SOUND;
      counter <= 8'b0;
    end 
    else begin 
  //    current_state <= next_state;
      if (write_ready) begin 
        write <= 1'b1;
        counter[7:0]  <= counter[7:0] + 1'b1;
        if (switches == 4'b0000) begin 
          writedata_left[23] <= counter[0];
          writedata_right[23] <= counter[0];
        end 
        else if (switches == 4'b0001) begin 
          writedata_left[23] <= counter[4];
          writedata_right[23] <= counter[4];
        end 
        else if (switches == 4'b0010) begin 
          writedata_left[23] <= counter[5];
          writedata_right[23] <= counter[5];
        end 
        else if (switches == 4'b0100) begin 
          writedata_left[23] <= counter[6];
          writedata_right[23] <= counter[6];
        end 
        else if (switches == 4'b1000) begin 
          writedata_left[23] <= counter[7];
          writedata_right[23] <= counter[7];
        end 
      end 
    end 
  end 

/*
  always @(*) 
  begin: state_table
    case(current_state) 
      NO_SOUND: 
*/         
endmodule
