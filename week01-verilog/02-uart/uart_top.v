module uart_top #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input        clk     ,
    input        rst_n   ,
    input  [7:0] data_in ,
    input        start   ,
    input        rx      ,
    output [7:0] data_out,
    output       tx      ,
    output       done
);
wire tx_busy;
uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) uut_uart_tx (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .tx_start(start),
    .tx(tx),
    .tx_busy(tx_busy)
);
uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) uut_uart_rx (
    .clk(clk),
    .rst_n(rst_n),
    .rx(rx),
    .data_out(data_out),
    .rx_done(done)
);
endmodule 
