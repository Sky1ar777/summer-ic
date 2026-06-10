module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input                         wclk ,
    input      [ADDR_WIDTH - 1:0] waddr,
    input      [DATA_WIDTH - 1:0] wdata,
    input                         we   ,
    
    input                         rclk ,
    input      [ADDR_WIDTH - 1:0] raddr,
    output reg [DATA_WIDTH - 1:0] rdata
);
reg [DATA_WIDTH - 1:0] mem [0:(1 << ADDR_WIDTH) - 1];
always @(posedge wclk) begin
    if(we)
        mem[waddr] <= wdata;
end
always @(posedge rclk) begin
    rdata <= mem[raddr];
end
endmodule 
