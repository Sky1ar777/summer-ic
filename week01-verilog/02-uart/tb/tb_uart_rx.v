`timescale 1ns / 1ps
module tb_uart_rx;

    parameter CLK_FREQ  = 40;
    parameter BAUD_RATE = 2;
    parameter BAUD_TICK = CLK_FREQ / BAUD_RATE;  // =20
    parameter CLK_NS    = 25;                     // 周期25ns

    reg clk, rst_n, rx;
    wire [7:0] data_out;
    wire rx_done;

    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .clk(clk), .rst_n(rst_n), .rx(rx),
        .data_out(data_out), .rx_done(rx_done)
    );

    initial clk = 0;
    always #(CLK_NS/2) clk = ~clk;

    // 每bit延迟 = BAUD_TICK * CLK_NS = 500ns
    // #1 错开采样边缘，避免竞争
    task tx_bit; input val;
    begin
        #1 rx = val;
        #(BAUD_TICK * CLK_NS - 1);
    end
    endtask

    task tx_frame; input [7:0] data;
        integer i;
    begin
        tx_bit(0);
        for(i=0; i<8; i=i+1)
            tx_bit(data[i]);
        tx_bit(1);
    end
    endtask

    task check; input [7:0] expect;
    begin
        #(CLK_NS);
        if(data_out == expect)
            $display("  [PASS] 0x%h", data_out);
        else
            $display("  [FAIL] expect 0x%h got 0x%h", expect, data_out);
    end
    endtask

    initial begin
        rx = 1; rst_n = 0;
        #300 rst_n = 1;
        #500;

        $display("===== 测试1: 0x55 =====");
        tx_frame(8'h55); @(posedge rx_done); check(8'h55);

        #500;
        $display("===== 测试2: 0xAA =====");
        tx_frame(8'hAA); @(posedge rx_done); check(8'hAA);

        #500;
        $display("===== 测试3: 0xFF =====");
        tx_frame(8'hFF); @(posedge rx_done); check(8'hFF);

        #500;
        $display("===== 测试4: 0x00 =====");
        tx_frame(8'h00); @(posedge rx_done); check(8'h00);

        #500;
        $display("===== 测试5: 0xA5 =====");
        tx_frame(8'hA5); @(posedge rx_done); check(8'hA5);

        #500 $finish;
    end

    initial begin
        $monitor("t=%0t  rx=%b  state=%b  baud=%d  bit=%d  data_out=0x%h  done=%b",
                  $time, rx, uut.state, uut.baud_cnt, uut.bit_cnt, data_out, rx_done);
    end

endmodule
