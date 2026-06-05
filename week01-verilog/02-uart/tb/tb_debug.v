`timescale 1ns / 1ps
module tb_uart_tx;

    parameter CLK_FREQ   = 10;      // 10
    parameter BAUD_RATE  = 2;       // 每bit 5时钟 = 50ns
    // ↑用最小参数，跑得快且容易看

    reg clk;
    reg rst_n;
    reg [7:0] data_in;
    reg tx_start;
    wire tx, tx_busy;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .clk(clk), .rst_n(rst_n), .data_in(data_in),
        .tx_start(tx_start), .tx(tx), .tx_busy(tx_busy)
    );

    initial clk = 0;
    always #5 clk = ~clk;  // 周期=10ns

    initial begin
        rst_n = 0; tx_start = 0; data_in = 0;
        #20  rst_n = 1;
        #20  data_in = 8'b01010101;  // 0x55
             tx_start = 1;
        #10  tx_start = 0;
        #600 $finish;
    end

    // 逐变化打印，时长精确到ns
    initial begin
        $monitor("t=%0dns  state=%b  tx=%b  baud=%d  bit=%d",
                 $time, uut.current_state, tx, uut.baud_cnt, uut.bit_cnt);
    end

endmodule
