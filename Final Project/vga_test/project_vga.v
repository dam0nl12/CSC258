// Part 2 skeleton

module project_vga
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	wire reset_n;
	assign reset_n = KEY[2];
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	//added colour assignment.
	//assign colour = 3'b111;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	//reg [7:0] temp;
	//assign x[7:4] = 4'd0;
	//assign y[6:4] = 3'd0;
	//assign writeEn = 1'b1;
	
	test_thing t1(.clk(CLOCK_50), .resetn(reset_n), .x_out(x), .y_out(y), .colour(colour), .writeEn(writeEn));
	//control co(.resetn(resetn), .clk(CLOCK_50), .confirm(~KEY[3]), .x(SW[7:4]), .y(SW[3:0]), .x_out(x), .y_out(y));
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	
	//added colour assignment.
	
	//assign x = 8'd1;
	//assign y = 8'd1;
	//assign writeEN = ~KEY[1];
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
endmodule


module test_thing(clk, resetn, x_out, y_out, colour, writeEn);
	
	input clk, resetn;
	output reg [7:0] x_out; 
	output reg [6:0] y_out;
	output reg[2:0] colour;
	output reg writeEn;
	
	reg enable;
	reg [7:0] x_square, x_grid;
	reg [6:0] y_square, y_grid;
	initial
	begin
		enable = 1'b0;
		x_square = 8'd104;
		y_square = 7'd84;
		x_grid = 8'd0;
		y_grid = 7'd0;
		colour = 3'b111;
	end
	
	always @(posedge clk)
	begin
		// check the balance of the initial board when we do the VGA at the lab.
		if (!resetn) begin
			writeEn = 1'b1;
			if ((x_out < 8'd20) || (x_out > 8'd137)) begin
				colour = 3'b111;
			end else if ((y_out > 7'd37) && (y_out < 7'd40)) begin
				colour = 3'b000;
			end else if ((y_out > 7'd77) && (y_out < 7'd80)) begin
				colour = 3'b000;
			end else if ((x_out > 8'd57) && (x_out < 8'd60)) begin
				colour = 3'b000;
			end else if ((x_out > 8'd97) && (x_out < 8'd100)) begin
				colour = 3'b000;
			end else begin
				colour = 3'b111;
			end
		end else begin
			colour = 3'b100;
			writeEn = 1'b1;
		end
	end
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			if (x_grid == 8'd159) begin
				x_grid <= 8'd0;
				enable = 1'b1;
			end else begin 
				x_grid <= x_grid + 1'b1;
				enable = 1'b0;
			end
			x_out <= x_grid;
		end else begin
			if (x_square == 8'd133) begin
				x_square <= 8'd104;
				enable = 1'b1;
			end else begin
				x_square <= x_square + 1'b1;
				enable = 1'b0;
			end
			x_out <= x_square;
		end
	end
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			if (enable == 1'b1) begin
				if (y_grid == 7'd119) begin
					y_grid <= 7'd0;
				end else begin 
					y_grid <= y_grid + 1'b1;
				end
			end
			y_out <= y_grid;
		end else begin
			if (enable == 1'b1) begin
				if (y_square == 7'd114) begin
					y_square <= 7'd84;
				end else begin
					y_square <= y_square + 1'b1;
				end
			end
			y_out <= y_square;
		end
	end
		
endmodule		

module control(resetn, clk, confirm, x, y, x_out, y_out);
	input resetn, clk, confirm;
	input [3:0] x, y;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	reg [1:0] current_state, next_state;
	reg [7:0] x_reg;
	reg [6:0] y_reg;
	reg [7:0] x_temp;
	reg [6:0] y_temp;
	reg enable;
	
	localparam   LOAD_MOVE          = 2'd0,
                LOAD_MOVE_WAIT     = 2'd1,
					 DRAW 				  = 2'd2;
	initial
	begin
		current_state = LOAD_MOVE;
	end
	
	always@(*)
    begin: state_table 
            case (current_state)
                LOAD_MOVE: next_state = confirm ? LOAD_MOVE_WAIT : LOAD_MOVE; // Loop in current state until go is pushed
					 LOAD_MOVE_WAIT : next_state = confirm ? DRAW : LOAD_MOVE_WAIT;
					 DRAW: next_state = confirm? LOAD_MOVE: DRAW;
				endcase
	end
	
	always @(negedge clk)
	begin
		case (current_state)
			LOAD_MOVE: begin
							x_reg <= {4'b0000, x}; y_reg <= {3'b000, y};
							x_temp <= 8'd0; y_temp <= 7'd0;
							enable <= 1'b0;
							end
			DRAW: begin
				if (x_temp == 8'd30) begin
					x_temp <= 8'd0;
					enable <= 1'b1;
				end else begin
					x_temp <= x_temp + 1'b1;
				end
				if (enable == 1'b1) begin
					if (y_temp == 8'd30) begin
						y_temp <= 8'd0;
					end else begin
						y_temp <= y_temp + 1'b1;
					end
				end
				x_out = x_temp + x_reg;
				y_out = y_temp + y_reg;
			   end
			endcase
	end
	always @(posedge clk)
	begin
		if (!resetn)
			current_state <= LOAD_MOVE;
		else
			current_state <= next_state;
	end
	
endmodule
								
    
	 // Instansiate datapath
	// datapath d0(...);

    // Instansiate FSM control
    // control c0(...);
    
