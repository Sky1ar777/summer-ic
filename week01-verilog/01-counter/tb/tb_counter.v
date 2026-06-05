`timescale 1ns / 1ps
module tb_counter;
parameter CNT_WIDTH = 8;
reg clk;
reg rst_n;
reg en;
wire [CNT_WIDTH - 1 : 0]cnt;
counter uut (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .cnt(cnt)
);
initial clk = 0;
always #5 clk = ~clk;
initial begin
    rst_n = 0;
    #100 
    rst_n = 1;
    #100
    en = 1;
    #200
    en = 0;
    #200
    en = 1;
    #500
    $finish;
end
initial begin
    $monitor("time=%0t   rst_n=%b   en=%b   cnt=%d",$time,rst_n,en,cnt);
end
endmodule