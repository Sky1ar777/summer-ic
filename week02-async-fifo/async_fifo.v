module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input                         wclk   ,
    input                         wrst_n ,
    input                         winc   ,
    input      [DATA_WIDTH - 1:0] wdata  ,
    output                        wfull  ,

    input                         rclk   ,
    input                         rrst_n ,
    input                         rinc   ,
    output     [DATA_WIDTH - 1:0] rdata  ,
    output                        rempty
);
reg [ADDR_WIDTH:0] wptr,rptr;
wire [ADDR_WIDTH:0] wgray,rgray;
wire [ADDR_WIDTH:0] sync_wgray,sync_rgray;
wire [ADDR_WIDTH - 1:0] waddr,raddr;
assign waddr = wptr[ADDR_WIDTH - 1:0];
assign raddr = rptr[ADDR_WIDTH - 1:0];
fifo_mem #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) u_fifo_mem (
    .wclk(wclk),
    .waddr(waddr),
    .wdata(wdata),
    .we(winc),
    .rclk(rclk),
    .raddr(raddr),
    .rdata(rdata)
);
always @(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) begin
        wptr <= 1'b0;
    end
    else if(winc && !wfull) begin
        wptr <= wptr + 1'b1;
    end
end
always @(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) begin
        rptr <= 1'b0;
    end
    else if(rinc && !rempty) begin
        rptr <= rptr + 1'b1;
    end
end
sync2gray #(
    .WIDTH(ADDR_WIDTH + 1)
) w_sync2gray (
    .bin(wptr),
    .gray(wgray)
);
sync2gray #(
    .WIDTH(ADDR_WIDTH + 1)
) r_sync2gray (
    .bin(rptr),
    .gray(rgray)
);
sync_2ff #(
    .WIDTH(ADDR_WIDTH + 1)
) w_sync_2ff (
    .clk(rclk),
    .rst_n(rrst_n),
    .async_in(wgray),
    .sync_out(sync_wgray)
);
sync_2ff #(
    .WIDTH(ADDR_WIDTH + 1)
) r_sync_2ff (
    .clk(wclk),
    .rst_n(wrst_n),
    .async_in(rgray),
    .sync_out(sync_rgray)
);
assign rempty = (sync_wgray == rgray);
assign wfull = (sync_rgray == {~wgray[ADDR_WIDTH:ADDR_WIDTH-1], wgray[ADDR_WIDTH-2:0]});
endmodule
