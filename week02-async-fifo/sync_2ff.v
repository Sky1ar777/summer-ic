module sync_2ff #(
    parameter WIDTH = 1
)(
    input                  clk     ,
    input                  rst_n   ,
    input  [WIDTH - 1 : 0] async_in,
    output [WIDTH - 1 : 0] sync_out
);
reg [WIDTH - 1 : 0] sync_1,sync_2;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sync_1 <= {WIDTH{1'b0}};
        sync_2 <= {WIDTH{1'b0}};
    end 
    else begin
        sync_1 <= async_in;
        sync_2 <= sync_1;
    end
end
assign sync_out = sync_2;
endmodule
