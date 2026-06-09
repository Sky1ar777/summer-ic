`timescale 1ns / 1ps
module tb_pulse_sync;

    reg clkA, clkB, rst_n;
    reg pulseA;
    wire pulseB;

    pulse_sync uut (
        .clkA(clkA),
        .clkB(clkB),
        .rst_n(rst_n),
        .pulseA(pulseA),
        .pulseB(pulseB)
    );

    // clkA: 快时钟 (周期20ns = 50MHz)
    initial clkA = 0;
    always #10 clkA = ~clkA;

    // clkB: 慢时钟 (周期100ns = 10MHz)
    initial clkB = 0;
    always #50 clkB = ~clkB;

    // -- 监控 --
    initial begin
        $monitor("t=%0t  clkA=%b  pulseA=%b  toggle=%b  sync_1=%b  sync_2=%b  sync_3=%b  pulseB=%b",
                  $time, clkA, pulseA, uut.toggle, uut.sync_1, uut.sync_2, uut.sync_3, pulseB);
    end

    initial begin
        rst_n = 0; pulseA = 0;
        #200
        rst_n = 1;         // 释放复位
        #50

        // 第1个脉冲
        @(posedge clkA);
        pulseA = 1;
        @(posedge clkA);
        pulseA = 0;

        #500

        // 第2个脉冲
        @(posedge clkA);
        pulseA = 1;
        @(posedge clkA);
        pulseA = 0;

        #500

        // 第3个脉冲
        @(posedge clkA);
        pulseA = 1;
        @(posedge clkA);
        pulseA = 0;

        #500
        $finish;
    end

endmodule
