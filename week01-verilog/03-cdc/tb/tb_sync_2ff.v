`timescale 1ns / 1ps
module tb_sync_2ff;
parameter WIDTH = 8;
reg clk;
reg rst_n;
reg [WIDTH - 1:0] async_in;
wire [WIDTH - 1:0] sync_out;
sync_2ff #(
    .WIDTH(WIDTH)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .async_in(async_in),
    .sync_out(sync_out)
);
initial clk = 0;
always #5 clk = ~clk;
initial begin
    rst_n = 0;
    #100
    rst_n = 1;
    #50
    async_in = 8'b01010101;
    #100
    $finish;
end
initial begin
    $monitor("t=%0t  async_in=%b  sync_1=%b  sync_2=%b  sync_out=%b", 
              $time, async_in, uut.sync_1, uut.sync_2, sync_out);
end
endmodule