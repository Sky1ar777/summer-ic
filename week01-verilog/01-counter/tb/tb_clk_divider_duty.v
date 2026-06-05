`timescale 1ns / 1ps
module tb_clk_divider_duty;
parameter DIV_NUM = 10;
parameter HIGH_TIME = 3;
reg clk_in;
reg rst_n;
wire clk_out;
clk_divider_duty #(
    .DIV_NUM(DIV_NUM),
    .HIGH_TIME(HIGH_TIME)
) uut (
    .clk_in(clk_in),
    .rst_n(rst_n),
    .clk_out(clk_out)
);
initial clk_in = 0;
always #5 clk_in = ~ clk_in;
initial begin
    rst_n = 0;
    #100 
    rst_n = 1;
    #500
    $finish;
end
initial begin
    $monitor("time=%0t  clk_in=%b  clk_out=%b  cnt=%d", $time, clk_in, clk_out, uut.cnt);
end
endmodule