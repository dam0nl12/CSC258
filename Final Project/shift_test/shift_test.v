module shift_test(SW, KEY, CLOCK_50, HEX0, HEX1, LEDR);
	input[3:0] KEY;
	input[9:0] SW;
	input CLOCK_50;
	output[8:0] LEDR;
	output [6:0] HEX0, HEX1;
	wire[3:0] row_out, col_out;
	wire clk, enable;
	wire [8:0] one_one;
	
	
	assign clk = CLOCK_50;
	
	
	index_tester i1(.row(KEY[1]),
					    .col(KEY[0]),
						 .confirm(KEY[3]),
						 .resetn(KEY[2]),
						 .clk(clk),
						 .row_out(row_out),
						 .col_out(col_out),
						 .shifter_val(one_one));
	
	hexdisplay h1(.X(col_out), .HEX(HEX0));
	hexdisplay h2(.X(row_out), .HEX(HEX1));
	
	clockdivider c1(.clock(clk), .enable(enable));
	
	shift_register s1(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[8]),
							.enable(enable),
							.q(LEDR[8]));
	
	shift_register s2(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[7]),
							.enable(enable),
							.q(LEDR[7]));
	
	shift_register s3(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[6]),
							.enable(enable),
							.q(LEDR[6]));
	
	shift_register s4(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[5]),
							.enable(enable),
							.q(LEDR[5]));
	
	shift_register s5(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[4]),
							.enable(enable),
							.q(LEDR[4]));
							
	shift_register s6(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[3]),
							.enable(enable),
							.q(LEDR[3]));
	
	shift_register s7(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[2]),
							.enable(enable),
							.q(LEDR[2]));
	
	shift_register s8(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[1]),
							.enable(enable),
							.q(LEDR[1]));
	
	shift_register s9(.clock(clk),
							.resetn(KEY[2]),
							.flip(SW[0]),
							.one_one(one_one[0]),
							.enable(enable),
							.q(LEDR[0]));
	
endmodule

module index_tester(row, col, confirm, resetn, clk, flip, row_out, col_out, shifter_val);
	input row, col, confirm, resetn, clk, flip;
	output reg [3:0] row_out, col_out;
	output reg [8:0] shifter_val;
	reg [3:0] row_col, index;
	
	initial
	begin
		row_out = 4'd1;
		col_out = 4'd1;
		shifter_val = 9'd0;
	end
	
	// this makes the numbers solid...key_test does not.
	always @(negedge row)
	begin
		if (row == 1'b0) begin
			if (row_out == 4'd3)
				row_out <= 4'd1;
			else
				row_out <= row_out + 4'd1;
			col_out <= col_out;
		end
	end
	
	always @(negedge col)
	begin	
		if (col == 1'b0) begin
			if (col_out == 4'd3)
				col_out <= 4'd1;
			else
				col_out <= col_out + 4'd1;
			row_out <= row_out;
		end		
	end
	
	
	always @(posedge clk)
	begin: get_index
		if (resetn == 1'b0) begin
			shifter_val = 9'd0;
		end else if (confirm == 1'b0) begin
			row_col = {row_out[1:0], col_out[1:0]};
			case (row_col)
				4'b0101: shifter_val = {1'b1, shifter_val[7:0]};
				4'b0110: shifter_val = {shifter_val[8], 1'b1, shifter_val[6:0]};
				4'b0111: shifter_val = {shifter_val[8:7], 1'b1, shifter_val[5:0]};
				4'b1001: shifter_val = {shifter_val[8:6], 1'b1, shifter_val[4:0]};
				4'b1010: shifter_val = {shifter_val[8:5], 1'b1, shifter_val[3:0]};
				4'b1011: shifter_val = {shifter_val[8:4], 1'b1, shifter_val[2:0]};
				4'b1101: shifter_val = {shifter_val[8:3], 1'b1, shifter_val[1:0]};
				4'b1110: shifter_val = {shifter_val[8:2], 1'b1, shifter_val[0]};
				4'b1111: shifter_val = {shifter_val[8:1], 1'b1};
			default: shifter_val = 9'd0;
			endcase
		end //else 
			//shifter_val = shifter_val;
		//assign shifter_out = shifter_val;
	end	
endmodule

module shift_register(clock, resetn, flip, one_one, enable, q);
	input clock, resetn, enable, flip, one_one;
	// include a flip input and a 11 input???
	output reg q;
	//output [1:0] curr_state;
	reg [1:0] curr_state;
	
	initial
	begin
		q <= 1'b0;
		curr_state = 2'b01;
	end
	
	//always @(posedge flip)
	//begin
	 //	if (flip == 1'b1) begin
	//		curr_state <= ~(curr_state);
	//	end
		//q <= curr_state[1];
	//end

	always @(posedge clock)
	begin
		if (resetn == 1'b0) begin
			curr_state <= 2'b01;
			q <= curr_state[1];
		end else if (flip == 1'b1) begin
			if (curr_state != 2'b01) 
				curr_state <= ~curr_state;
				q <= curr_state[1];
		end else if (one_one == 1'b1) begin
			curr_state <= 2'b11;
			q <= curr_state[1];
		end else if (enable == 1'b1) begin
			curr_state <= {curr_state[0], curr_state[1]};
			q <= curr_state[1];
		end
		
	end
endmodule


module clockdivider(clock, enable);
	
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
