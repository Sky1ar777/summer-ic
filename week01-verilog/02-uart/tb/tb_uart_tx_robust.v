`timescale 1ns / 1ps
module tb_uart_tx_robust;

    // 小参数=快速仿真
    parameter CLK_FREQ   = 10;
    parameter BAUD_RATE  = 2;
    parameter BAUD_TICK  = CLK_FREQ / BAUD_RATE;
    parameter CLK_NS     = 100;

    reg clk, rst_n, tx_start;
    reg [7:0] data_in;
    wire tx, tx_busy;

    integer err_cnt, pass_cnt;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .clk(clk), .rst_n(rst_n), .data_in(data_in),
        .tx_start(tx_start), .tx(tx), .tx_busy(tx_busy)
    );

    initial clk = 0;
    always #(CLK_NS/2) clk = ~clk;

    // 发送
    task send; input [7:0] d;
        @(posedge clk); data_in = d; tx_start = 1;
        @(posedge clk); tx_start = 0;
    endtask

    // 接收验证 - 基于时间的采样
    task recv; input [7:0] expect;
        integer i; reg [7:0] got; got = 0;
        @(negedge tx); #1;  // 等起始位下降沿
        #(BAUD_TICK * CLK_NS);  // 跳过起始位
        for(i=0; i<8; i=i+1) begin
            #(BAUD_TICK * CLK_NS / 2); got[i] = tx;
            #(BAUD_TICK * CLK_NS / 2);
        end
        #(CLK_NS);
        if(got == expect) begin
            $display("  [PASS] 0x%h", expect); pass_cnt = pass_cnt + 1;
        end else begin
            $display("  [FAIL] expect 0x%h got 0x%h", expect, got);
            err_cnt = err_cnt + 1;
        end
    endtask

    // 测试1: 多种数据值
    task test_values;
        $display("===== 测试1: 数据值 =====");
        send(8'h55); recv(8'h55);
        send(8'h00); recv(8'h00);
        send(8'hFF); recv(8'hFF);
        send(8'hA5); recv(8'hA5);
        send(8'h5A); recv(8'h5A);
        send(8'h01); recv(8'h01);
        send(8'h80); recv(8'h80);
    endtask

    // 测试2: 连续发送
    task test_back2back;
        $display("===== 测试2: 连续发送 =====");
        send(8'h55); wait(!tx_busy);
        @(posedge clk);
        send(8'hAA); wait(!tx_busy);
        $display("  [PASS] 连续两帧完成");
    endtask

    // 测试3: 传输中复位
    task test_reset;
        $display("===== 测试3: 传输中复位 =====");
        send(8'h55);
        repeat(3) @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        if(tx === 1'b1 && tx_busy === 1'b0)
            $display("  [PASS] 复位正常");
        else
            $display("  [FAIL] tx=%b busy=%b", tx, tx_busy);
        rst_n = 1;
        repeat(5) @(posedge clk);
        send(8'h5A); recv(8'h5A);
    endtask

    initial begin
        err_cnt = 0; pass_cnt = 0;
        rst_n = 0; tx_start = 0; data_in = 0;
        #2000 rst_n = 1;
        #2000;
        test_values;
        test_back2back;
        test_reset;
        $display("\n===== 结果: PASS=%0d  FAIL=%0d =====", pass_cnt, err_cnt);
        $finish;
    end

endmodule
