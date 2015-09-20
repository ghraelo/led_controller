module ws2812_driver(
	input logic clk,
	input logic n_reset,
	input logic[7:0] r, 
	input logic[7:0] g, 
	input logic[7:0] b, 
	input logic send_data, 
	output logic ready,
	output logic one_wire;
	)

//state machine
typedef enum{start, whichbit, wait_count, n_increment} state_type;
state_type present_state,next_state;

logic[4:0] index,next_index; //indexer for data

logic[23:0] data; //data to send 
assign data = {r,g,b}; //concat red, green, blue

//counter
logic count_rst, count_end;
logic[9:0] count_ceil;
counter_ceil #(.n(10)) CC (.clk(clk),.n_reset(n_reset) ), .ceiling(count_ceil),.rst(count_rst),.done(count_end));

always_ff @(posedge clk or negedge n_reset)
begin
	if(~n_reset) 
		present_state <= start;
		index <= 5'b0;
	else
		present_state <= next_state;
		index <= next_index;
end

always_comb
begin
	//defaults
	ready = 1'b0;
	count_ceil = 10'b0;
	count_rst = 1'b0;
	one_wire = 1'b0;
	case(present_state)
		start:
			begin
				ready = 1'b1;
				next_state = (send_data == 1'b1) ? whichbit : start;
			end

		whichbit:
			begin
				if(data[index] == 1)
				begin
					count_ceil = 10'd14;
					count_rst = 1'b1;
					next_state = wait_hi_hi;
				end
				else
				begin
					count_ceil = 10'd7;
					count_start = 1'b1;
					next_state = wait_lo_hi;
				end
			end

		wait_hi_hi:
			begin
				one_wire = 1'b1;
				next_state = (count_end == 1) ? hi_set : wait_hi_hi;
			end

		hi_set:
			count_ceil = 10'd16;
			count_rst = 1'b1;
			next_state = wait_hi_lo;

		wait_hi_lo:
			begin
				one_wire = 1'b0;
				next_state = (count_end == 1) ? n_increment : wait_hi_lo;
			end

		wait_lo_hi:
			begin
				one_wire = 1'b1;
				next_state = (count_end == 1) ? lo_set : wait_lo_hi;
			end

		lo_set:
			count_ceil = 10'd12;
			count_rst = 1'b1;
			next_state = wait_lo_lo;

		wait_lo_lo:
			begin
				one_wire = 1'b0;
				next_state = (count_end == 1) ? n_increment : wait_lo_lo;
			end

		n_increment:
			begin
				if(index == 5'd23)
					next_index = 5'b0;
				else
					next_index = index + 1;
				next_state = start;
			end

	endcase
end

endmodule // ws2812_driver