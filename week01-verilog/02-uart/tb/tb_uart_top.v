`timescale 1ns / 1ps
module tb_uart_top;

    parameter CLK_FREQ  = 40;
    parameter BAUD_RATE = 2;          // BAUD_TICK=20
    parameter BAUD_TICK = CLK_FREQ / BAUD_RATE;
    parameter CLK_NS    = 25;         // 周期25ns

    reg clk, rst_n, start;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire done, tx, rx;        // rx 改成 wire（被assign驱动）
    integer pass_cnt, err_cnt;

    uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .clk(clk), .rst_n(rst_n),
        .data_in(data_in), .start(start),
        .rx(rx), .tx(tx),
        .data_out(data_out), .done(done)
    );

    initial clk = 0;
    always #(CLK_NS/2) clk = ~clk;

    // 回环：1ns延迟打破clock沿的竞争条件
    assign #1 rx = tx;

    // 发送一帧
    task send; input [7:0] d;
    begin
        @(posedge clk);
        data_in = d;
        start = 1;
        @(posedge clk);
        start = 0;
    end
    endtask

    // 验证
    task check;
        input [7:0] n;
        reg [7:0] got;
        integer i;
    begin
        got = 0;
        // 等 done 信号
        @(posedge done);
        #(CLK_NS);
        got = data_out;
        if(got == n) begin
            $display("  [PASS] 0x%h -> 0x%h", n, got);
            pass_cnt = pass_cnt + 1;
        end
        else begin
            $display("  [FAIL] 0x%h -> 0x%h", n, got);
            err_cnt = err_cnt + 1;
        end
    end
    endtask

    initial begin
        pass_cnt = 0; err_cnt = 0;
        rst_n = 0; start = 0; data_in = 0;
        #300 rst_n = 1;
        #500;

        $display("===== UART 回环测试 =====");
        $display("CLK_FREQ=%0d  BAUD_RATE=%0d  BAUD_TICK=%0d", CLK_FREQ, BAUD_RATE, BAUD_TICK);
        $display("发送 0x55 ..."); $fflush();
        send(8'h55); check(8'h55);
        $display("发送 0xAA ..."); $fflush();
        send(8'hAA); check(8'hAA);
        $display("发送 0xFF ..."); $fflush();
        send(8'hFF); check(8'hFF);
        $display("发送 0x00 ..."); $fflush();
        send(8'h00); check(8'h00);
        $display("发送 0xA5 ..."); $fflush();
        send(8'hA5); check(8'hA5);

        $display("\n===== PASS=%0d  FAIL=%0d =====", pass_cnt, err_cnt);
        #100000;
        $display("===== 超时 PASS=%0d  FAIL=%0d =====", pass_cnt, err_cnt);
        $finish;
    end

endmodule
