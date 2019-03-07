module tictachex(SW, KEY, CLOCK_50, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B);   						//	VGA Blue[9:0]	);
	
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	output [9:0] LEDR;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire clk, enable, flip, resetn, draw, writeEn;
	wire [8:0] one_one, board_move;
	wire [23:0] message;
	wire [3:0] col_reg, row_reg;
	wire [7:0] x_coord, x;
	wire [6:0] y_coord, y;
	wire [2:0] player_colour, colour_out;

	
	assign clk = CLOCK_50;
	assign LEDR[9] = 1'b0;
	//used to be KEY2
	assign resetn = ~SW[9];
	
	// controls the state logic and sends signals to other modules.
	control c1(.clk(clk),
				  .resetn(resetn),
				  .go(~KEY[3]),
				  .row(KEY[1]),
				  .column(KEY[0]),
				  .enable(enable),
				  .board_move(board_move),
				  .message_status(message),
				  .column_reg(col_reg),
				  .row_reg(row_reg),
				  .flip(flip),
				  .draw(draw),
				  .player_colour(player_colour));

	// sends signals to the shift_registers, the draw_vga and the control based on the row and column selected.
	row_col_handler r1(.row(row_reg[1:0]),
						    .col(col_reg[1:0]),
							 .resetn(resetn),
							 .clk(clk),
							 .confirm(KEY[3]),
							 .flip(flip),
							 .shifter_val(one_one),
							 .board_move(board_move),
							 .x_coord(x_coord),
							 .y_coord(y_coord)
							 );
	
	// sends pixels and colour to the vga_adapter, based on signals from control.
	draw_vga v1(.clk(CLOCK_50), 
					  .resetn(resetn), 
					  .draw(draw),
					  .colour_in(player_colour),
					  .x_in(x_coord),
					  .y_in(y_coord),
					  .x_out(x), 
					  .y_out(y), 
					  .colour_out(colour_out),
					  .writeEn(writeEn));
	
	// used for writing to the VGA display.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour_out),
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
		defparam VGA.BACKGROUND_IMAGE = "finalbackground.mif";
						
	clockdivider d1(.clock(clk), .enable(enable));
	
	// shift_register displays the board state on LEDs.
	shift_register s1(.clock(clk),
							.resetn(resetn),
							.flip(flip),
							.one_one(one_one[8]),
							.enable(enable),
							.q(LEDR[8]));
	
	shift_register s2(.clock(clk),
							.resetn(resetn),
							.flip(flip),
							.one_one(one_one[7]),
							.enable(enable),
							.q(LEDR[7]));
	
	shift_register s3(.clock(clk),
							.resetn(resetn),
							.flip(flip),
							.one_one(one_one[6]),
							.enable(enable),
							.q(LEDR[6]));
	
	shift_register s4(.clock(clk),
							.resetn(resetn),
							.flip(flip),
							.one_one(one_one[5]),
							.enable(enable),
							.q(LEDR[5]));
	
	shift_register s5(.clock(clk),
							.resetn(resetn),
							.flip(flip),
							.one_one(one_one[4]),
							.enable(enable),
							.q(LEDR[4]));
							
	shift_register s6(.clock(clk),
							.resetn(resetn),
							.flip(flip),
							.one_one(one_one[3]),
							.enable(enable),
							.q(LEDR[3]));
	
	shift_register s7(.clock(clk),
							.resetn(resetn),
							.flip(SW[0]),
							.one_one(one_one[2]),
							.enable(enable),
							.q(LEDR[2]));
	
	shift_register s8(.clock(clk),
							.resetn(resetn),
							.flip(flip),
							.one_one(one_one[1]),
							.enable(enable),
							.q(LEDR[1]));
	
	shift_register s9(.clock(clk),
							.resetn(resetn),
							.flip(flip),
							.one_one(one_one[0]),
							.enable(enable),
							.q(LEDR[0]));

	
	//hexdisplay displays our messages to the players.
	hexdisplay h1(.X(message[23:20]), .HEX(HEX5));
	hexdisplay h2(.X(message[19:16]), .HEX(HEX4));
	hexdisplay h3(.X(message[15:12]), .HEX(HEX3));
	hexdisplay h4(.X(message[11:8]), .HEX(HEX2));
	hexdisplay h5(.X(message[7:4]), .HEX(HEX1));
	hexdisplay h6(.X(message[3:0]), .HEX(HEX0));
	
endmodule


// Control sets signals according to states.
module control(
    input clk,
    input resetn,
    input go,
	 input row,
	 input column,
	 input enable,
	 input [8:0] board_move,
	 output reg [23:0] message_status,
	 output reg [3:0] column_reg, row_reg,
	 output reg flip,
	 output reg draw,
	 output reg [2:0] player_colour
    );
	 
	 reg [2:0] current_state, next_state; 
    reg [8:0] p1_board, p2_board, curr_board;
	 reg correct, finish, win, full, player_select;
	 
	 initial
	 begin
		column_reg <= 4'd1;
		row_reg <= 4'd1;
		
		// set player_select to 0 (P1)
		player_select <= 1'b0;
		p1_board <= 9'd0;
		p2_board <= 9'd0;
		win <= 1'b0;
		full <= 1'b0;
		finish <= 1'b0;
		correct <= 1'b0;
		current_state <= LOAD_MOVE;
		flip <= 1'b0;
	end
	
	// handles the column button.		
	always@(negedge column, negedge resetn)
	begin
		if (!resetn)
			column_reg <= 4'd1;
		else if (!column) begin
			if (column_reg == 4'd3)
				column_reg <= 4'd1;
			else
				column_reg <= column_reg + 4'd1;
		end
	end
	
	// handles the row button.
	always@(negedge row, negedge resetn)
	begin
		if (!resetn)
			row_reg <= 4'd1;
		else if (!row) begin
		 if (row_reg == 4'd3)
				row_reg <= 4'd1;
			else
				row_reg <= row_reg + 4'd1;
		end
	end
    
    localparam  LOAD_MOVE          = 3'd0,
                LOAD_MOVE_WAIT     = 3'd1,
					 ASSESS_MOVE		  = 3'd2,
                INCORRECT_MOVE     = 3'd3,
                CORRECT_MOVE       = 3'd4,
					 FLIP_PLAYER        = 3'd5,
                END_GAME           = 3'd6;
                
    localparam P1 = 8'b10010001,
					P2 = 8'b10010010,
					bad = 12'b101110101101;
					
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                LOAD_MOVE: next_state = go ? LOAD_MOVE_WAIT : LOAD_MOVE; // Loop in current state until go is pushed
                LOAD_MOVE_WAIT: next_state = go ? LOAD_MOVE_WAIT : ASSESS_MOVE; // Loop in current state until go signal goes low
                ASSESS_MOVE: next_state = correct ? CORRECT_MOVE : INCORRECT_MOVE; // Move to incorrect/correct move depending on if move is legal
                INCORRECT_MOVE: next_state = LOAD_MOVE; // Go back load_move if incorrect move was attempted.
                CORRECT_MOVE: next_state = finish ? END_GAME : FLIP_PLAYER; // If game is over, go to end_game if not go back to load_move
                FLIP_PLAYER : next_state = LOAD_MOVE;
					 END_GAME: next_state = END_GAME; // Loop in current state until game is reset.
            default:     next_state = LOAD_MOVE;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(negedge clk)
    begin: enable_signals
        // By default make all our signals 0
		  flip = 1'b0;
		  //flip = player_select;
		  if (!resetn) begin
				p1_board = 9'd0;
				p2_board = 9'd0;
				curr_board = 9'd0;
				player_select = 1'b0;
				win = 1'b0;
				full = 1'b0;
				finish = 1'b0;
				correct = 1'b0;
				draw = 1'b0;
		  end else begin
				case (current_state)
					LOAD_MOVE: begin
						if (player_select == 1'b0) begin
							curr_board <= p1_board;
							message_status[23:16] <= P1;
							player_colour <= 3'b100;
						end else if (player_select == 1'b1) begin
							curr_board <= p2_board;
							message_status [23:16] <= P2;
							player_colour <= 3'b001;
						end
						//flip = 1'b0;
						draw = 1'b0;
						message_status[15:8] <= 8'b11111111;
						message_status[7:0] <= {row_reg, column_reg}; 
						end
					ASSESS_MOVE: begin
						// assign correct to be the AND of p1_board NAND move_board and p2_board NAND move_board.
						correct = (((~(p1_board & board_move)) & (~(p2_board & board_move))) == 9'b111111111);
						end
					INCORRECT_MOVE: begin
						message_status[23:12] = 12'b111111111111;
						message_status[11:0] = bad;
						end
					CORRECT_MOVE: begin
						curr_board = curr_board | board_move;
						draw = 1'b1;
						// save the curr_board	
						if (player_select == 1'b0) begin
							p1_board <= curr_board;
							full = ((curr_board | p2_board) == 9'b111111111);
						end else begin
							p2_board <= curr_board;
							full = ((p1_board | curr_board) == 9'b111111111);
						end
						// check the winning condition of the curr_board, or a full board by ORing the 2 player boards.
						win = ((curr_board[0] & curr_board[1] & curr_board[2]) |
								  (curr_board[3] & curr_board[4] & curr_board[5]) |
								  (curr_board[6] & curr_board[7] & curr_board[8]) |
								  (curr_board[0] & curr_board[3] & curr_board[6]) |
								  (curr_board[1] & curr_board[4] & curr_board[7]) |
								  (curr_board[2] & curr_board[5] & curr_board[8]) |
								  (curr_board[0] & curr_board[4] & curr_board[8]) |
								  (curr_board[6] & curr_board[4] & curr_board[2]));
						finish = win | full;
						end
					FLIP_PLAYER: begin
						player_select = ~player_select;
						flip = 1'b1;
						end
					END_GAME: begin 
						if (win) // Write "SUPEr"
							message_status[23:0] = 24'b111101011100100111100110;
						else if (full) // Write "bOO"
							message_status[23:0] = 24'b111111111111101100000000;
					end
					//default: // don't need default 
			endcase
		end // enable_signals
    end
	 
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn) begin
				current_state <= LOAD_MOVE;
		  // slow down the transition between INCORRECT or CORRECT MOVES. (Correct_move is for drawing).	
       end else if ((current_state == INCORRECT_MOVE) || (current_state == CORRECT_MOVE)) begin
				if (enable == 1'b1)
					current_state <= next_state;
		 end else	
            current_state <= next_state;
    end // state_FFS
endmodule

module row_col_handler(row, col, resetn, clk, confirm, flip, shifter_val, board_move, x_coord, y_coord);
	input [1:0] row, col;
	input resetn, clk, confirm, flip;
	output reg [8:0] shifter_val, board_move;
	// VGA starting coordinates for squares.
	output reg [7:0] x_coord;
	output reg [6:0] y_coord;
	reg [3:0] row_col;
	
	initial
	begin
		shifter_val = 9'd0;
		board_move = 9'd0;
	end
	
	always @(negedge resetn, posedge clk)
	begin: get_index
		if (resetn == 1'b0) begin
			shifter_val = 9'd0;			
			board_move = 9'd0;
			row_col = 4'd0;
			x_coord = 8'd0;
			y_coord = 7'd0;
		//end else if (flip == 1'b1) begin
			//shifter_val <= ~shifter_val;
			//board_move = 9'd0;
		end else if (confirm == 1'b0) begin
			row_col <= {row, col};
			case (row_col)
				// assign the shifter lights, board_move and starting coordinates for squares.
				4'b0101: begin 
							shifter_val = {1'b1, shifter_val[7:0]}; board_move = 9'b100000000;
							x_coord = 8'd24; y_coord = 7'd4;
							end
				4'b0110: begin
							shifter_val = {shifter_val[8], 1'b1, shifter_val[6:0]}; board_move = 9'b010000000;
							x_coord = 8'd65; y_coord = 7'd4;
							end
				4'b0111: begin
							shifter_val = {shifter_val[8:7], 1'b1, shifter_val[5:0]}; board_move = 9'b001000000;
							x_coord = 8'd104; y_coord = 7'd4;
							end
				4'b1001: begin
							shifter_val = {shifter_val[8:6], 1'b1, shifter_val[4:0]}; board_move = 9'b000100000;
							x_coord = 8'd24; y_coord = 7'd44;
							end
				4'b1010: begin
							shifter_val = {shifter_val[8:5], 1'b1, shifter_val[3:0]}; board_move = 9'b000010000;
							x_coord = 8'd65; y_coord = 7'd44;
							end
				4'b1011: begin 
							shifter_val = {shifter_val[8:4], 1'b1, shifter_val[2:0]}; board_move = 9'b000001000;
							x_coord = 8'd104; y_coord = 7'd44;
							end
				4'b1101: begin
							shifter_val = {shifter_val[8:3], 1'b1, shifter_val[1:0]}; board_move = 9'b000000100;
							x_coord = 8'd24; y_coord = 7'd84;
							end
				4'b1110: begin
							shifter_val = {shifter_val[8:2], 1'b1, shifter_val[0]}; board_move = 9'b000000010;
							x_coord = 8'd65;  y_coord = 7'd84;
							end
				4'b1111: begin
							shifter_val = {shifter_val[8:1], 1'b1}; board_move = 9'b000000001;
							x_coord = 8'd104;  y_coord = 7'd84;
							end
			default: begin 
						shifter_val = 9'd0; 
						board_move = 9'd0;
						end
		endcase
		end
	end
endmodule

// controls the blinking LEDs
module shift_register(clock, resetn, flip, one_one, enable, q);
	input clock, resetn, enable, flip, one_one;
	output reg q;
	reg [1:0] curr_state;
	
	initial
	begin
		q <= 1'b0;
		curr_state = 2'b01;
	end
	
	always @ (negedge clock)
	begin
		if (resetn == 1'b0) begin
			curr_state <= 2'b01;
			q <= curr_state[1];		
		end else if (one_one == 1'b1) begin
				//if (flip == 1'b1) begin 
				//	curr_state = ~(curr_state);
					//q <= curr_state[1];
				//end else begin
				//	curr_state = 2'b11;
					//q <= curr_state[1];
				//end
				//q <= curr_state[1];
			// never really got flip to work.	
			if (flip == 1'b1) begin
				if (curr_state == 2'b00) begin
					curr_state <= 2'b11;
					q <= curr_state[1];
				end else begin
					curr_state <= 2'b00;
					q <= curr_state[1];
				end
			end else
				curr_state <= 2'b11;
				q <= curr_state[1];
		end else if (enable == 1'b1) begin
			curr_state <= {curr_state[0], curr_state[1]};
			q <= curr_state[1];
		end
		
	end
endmodule


module clockdivider(clock, enable);
	// divide the clock for certain state transitions, and blinking LEDs.
	input clock;
	output enable;
	reg enable;
	reg [27:0] counter;
	
	initial
	begin
		counter <= 28'd0;
	end
	always @(posedge clock)
	begin
		if (counter == 28'd49999999)
			counter <= 28'd0;
		else
			counter <= counter + 28'd1;	
		enable <= (counter == 28'd49999999);
	end
endmodule



module hexdisplay(X, HEX);
	// new hex decoder which includes letters like P and U and r.
	input [3:0] X;
	output [6:0] HEX;

	assign HEX[0] = X[3] & X[1] & X[0] |
						 X[3] & X[2] & X[0] |
						 X[2] & ~X[1] & ~X[0] |
						 ~X[3] & X[2] & ~X[0] |
						 ~X[3] & ~X[2] & ~X[1] & X[0];
	
	assign HEX[1] = ~X[3] & X[2] & ~X[1] & X[0] |
						 X[3] & X[1] & X[0] |
						 X[2] & X[1] & ~X[0];
	
	assign HEX[2] = ~X[3] & X[1] & ~X[0] |
						 X[3] & X[2] & X[1] |
						 X[3] & ~X[2] & ~X[1] & X[0];
	
	assign HEX[3] = ~X[3] & ~X[2] & ~X[1] & X[0] |
						 ~X[3] & X[2] & X[1] & ~X[0] |
						 X[3] & X[2] & X[1] & X[0] |
						 X[3] & ~X[2] & ~X[1] & X[0] |
						 X[3] & ~X[2] & X[1] & ~X[0];
	
	assign HEX[4] = ~X[3] & X[0] |
						  ~X[3] & X[2] & ~X[1] |
						  X[2] & X[1] & X[0];
			
	assign HEX[5] = ~X[3] & ~X[2] & X[0] |
						 X[3] & X[2] & X[0] |
						 ~X[3] & X[1] & ~X[0];
	
	assign HEX[6] = ~X[3] & ~X[2] & ~X[1] |
						 X[3] & X[2] & ~X[1] & ~X[0] |
						 X[3] & X[2] & X[1] & X[0];
endmodule


module draw_vga(clk, resetn, draw, colour_in, x_in, y_in, x_out, y_out, colour_out, writeEn);
	// contains the logic to draw a board or a coloured square depending on the inputs.
	input clk, resetn, draw;
	input [2:0] colour_in;
	input [7:0] x_in;
	input [6:0] y_in;
	output reg [7:0] x_out; 
	output reg [6:0] y_out;
	output reg[2:0] colour_out;
	output reg writeEn;
	
	reg enable;
	reg [7:0] x_square, x_grid;
	reg [6:0] y_square, y_grid;
	initial
	begin
		enable = 1'b0;
		x_square = 8'd0;
		y_square = 7'd0;
		x_grid = 8'd0;
		y_grid = 7'd0;
		colour_out = 3'b111;
	end
	
	always @(posedge clk)
	begin
		// check the balance of the initial board when we do the VGA at the lab.
		if (!resetn) begin
			writeEn = 1'b1;
			// redraw the tic tac toe board.
			if ((x_out < 8'd20) || (x_out > 8'd137)) begin
				colour_out <= 3'b111;
			end else if ((y_out > 7'd37) && (y_out < 7'd40)) begin
				colour_out <= 3'b000;
			end else if ((y_out > 7'd77) && (y_out < 7'd80)) begin
				colour_out <= 3'b000;
			end else if ((x_out > 8'd57) && (x_out < 8'd60)) begin
				colour_out <= 3'b000;
			end else if ((x_out > 8'd97) && (x_out < 8'd100)) begin
				colour_out <= 3'b000;
			end else begin
				colour_out <= 3'b111;
			end
			// draw a square if draw signal is high in the player's colour.
		end else if (draw == 1'b1) begin
			colour_out <= colour_in;
			writeEn = 1'b1;
		end else
			writeEn = 1'b0;
	end
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			// counter that covers the whole 160 X 120 screen to redraw an empty board.
			if (x_grid == 8'd159) begin
				x_grid <= 8'd0;
				enable = 1'b1;
			end else begin 
				x_grid <= x_grid + 1'b1;
				enable = 1'b0;
			end
			x_out <= x_grid;
		end else begin
			// draw a smaller square, adding those pixels to the coordinates provided.
			if (x_square == 8'd29) begin
				x_square <= 8'd1;
				enable = 1'b1;
			end else begin
				x_square <= x_square + 1'b1;
				enable = 1'b0;
			end
			x_out <= x_in + x_square;
		end
	end
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			// covers the whole screen.
			if (enable == 1'b1) begin
				if (y_grid == 7'd119) begin
					y_grid <= 7'd0;
				end else begin 
					y_grid <= y_grid + 1'b1;
				end
			end
			y_out <= y_grid;
		end else begin
			// draw a smaller square.
			if (enable == 1'b1) begin
				if (y_square == 7'd29) begin
					y_square <= 7'd1;
				end else begin
					y_square <= y_square + 1'b1;
				end
			end
			y_out <= y_in + y_square;
		end
	end
		
endmodule		


    
