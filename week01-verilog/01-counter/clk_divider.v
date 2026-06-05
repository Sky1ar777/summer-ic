module clk_divider #(
    parameter DIV_NUM = 50_000_000
)
(
    input  clk_in ,
    input  rst_n  ,
    output clk_out
);
reg [24:0] cnt;
reg clk_p,clk_n;
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
        clk_p <= 1'b0;
    else if (cnt == (DIV_NUM - 1) / 2)
        clk_p <= 1'b1;
    else if(cnt == DIV_NUM - 1)
        clk_p <= 1'b0;
    else
        clk_p <= clk_p;
end
always @(negedge clk_in or negedge rst_n) begin
    if(!rst_n)
        clk_n <= 1'b0;
    else if (cnt == (DIV_NUM - 1) / 2)
        clk_n <= 1'b1;
    else if(cnt == DIV_NUM - 1)
        clk_n <= 1'b0;
    else
        clk_n <= clk_n;
end
assign clk_out = (DIV_NUM % 2 == 1) ? (clk_p | clk_n) : clk_p;
endmodule
