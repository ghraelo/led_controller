module counter_ceil_testbench

logic clk;
logic n_reset;
logic[4:0] ceiling;
logic rst;
logic done;


counter_ceil #(.n(5)) CC (.*);

//clk
initial
begin
	clk = 1'b0;
	forever #10 clk = ~clk;
end

n_reset = 1'b0;
ceiling = 5'b10;
rst = 1'b0;
#20;
n_reset = 1'b1;
#250
rst = 1'b1;
#20;
rst  =1'b0;

endmodule // counter_ceil_testbench