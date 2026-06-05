module counter #(
    parameter CNT_WIDTH = 8
)(
    input                          clk  ,
    input                          rst_n,
    input                          en   ,
    output reg [CNT_WIDTH - 1 : 0] cnt
);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
       cnt <= {CNT_WIDTH{1'b0}};
    else if(en) begin
        if(cnt == {CNT_WIDTH{1'b1}})
            cnt <=  {CNT_WIDTH{1'b0}};
        else
            cnt <= cnt + 1'b1;
    end
end
endmodule 
