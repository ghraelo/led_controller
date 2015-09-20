module counter_ceil #(parameter n = 4) (
	input logic clk,
	input logic n_reset,
	input logic[n-1:0] ceiling,
	input logic rst,
	output logic done
	)

logic[n-1:0] count;

assign done = (count == ceiling) ? 1'b1 : 1'b0;

always_ff @(posedge clk or negedge n_reset)
begin
	if(!n_reset)
		count <= 0;
	else
		if(rst)
			count = 0;
		else
			if(count < count_ceil)
				count <= count+1;
			else
				count <= 0;
end

endmodule // counter_ceil