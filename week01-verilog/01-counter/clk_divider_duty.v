module clk_divider_duty #(
    parameter DIV_NUM = 10,
    parameter HIGH_TIME = 3
)
(
    input      clk_in ,
    input      rst_n  ,
    output reg clk_out
);
reg [24:0] cnt;
always @(posedge clk_in or negedge rst_n) begin
    if(!rst_n)
        cnt <= 1'b0;
    else if (cnt == DIV_NUM - 1)
        cnt <= 1'b0;
    else
       cnt <= cnt + 1'b1;
end
always @(posedge clk_in or negedge rst_n) begin
    if(!rst_n)
        clk_out <= 1'b0;
    else if (cnt < HIGH_TIME)
        clk_out <= 1'b1;
    else if(cnt >= HIGH_TIME)
        clk_out <= 1'b0;
    else
        clk_out <= clk_out;
end
endmodule
