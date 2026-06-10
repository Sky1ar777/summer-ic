`timescale 1ns / 1ps
module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter DEPTH = 1 << ADDR_WIDTH;  // 16

    reg  wclk, wrst_n, winc, rclk, rrst_n, rinc;
    reg  [DATA_WIDTH-1:0] wdata;
    wire [DATA_WIDTH-1:0] rdata;
    wire wfull, rempty;

    async_fifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) uut (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rdata(rdata), .rempty(rempty)
    );

    initial wclk = 0;
    always #5 wclk = ~wclk;

    initial rclk = 0;
    always #7 rclk = ~rclk;

    integer i, err;

    task write; input [7:0] d;
    begin
        @(posedge wclk); #1;
        wdata = d; winc = 1;
        @(posedge wclk); #1;
        winc = 0;
    end
    endtask

    task read;
    begin
        @(posedge rclk); #1;
        rinc = 1;
        @(posedge rclk); #1;
        rinc = 0;
    end
    endtask

    initial begin
        err = 0;
        {winc, rinc, wdata} = 0;
        wrst_n = 0; rrst_n = 0;
        #20 wrst_n = 1; rrst_n = 1;
        #20;

        // 写入 16 个数据
        $display("写入 %0d 个数据...", DEPTH);
        for(i=0; i<DEPTH; i=i+1) write(i);
        #20;
        $display("wfull=%b (应为1)", wfull);
        if(!wfull) begin $display("  [FAIL] 满标志错误"); err=1; end

        // 读出 16 个数据
        $display("读出 %0d 个数据...", DEPTH);
        for(i=0; i<DEPTH; i=i+1) begin
            read;
            #1;
            if(rdata !== i) begin
                $display("  [FAIL] 读到 0x%h, 期望 0x%h", rdata, i);
                err = 1;
            end
        end
        #20;
        $display("rempty=%b (应为1)", rempty);
        if(!rempty) begin $display("  [FAIL] 空标志错误"); err=1; end

        // 读写同时进行
        $display("同时读写...");
        fork
            for(i=0; i<8; i=i+1) write(i+16);
            for(i=0; i<8; i=i+1) read;
        join

        if(err) $display("\n★★ FAIL ★★");
        else    $display("\n★★ ALL PASS ★★");
        $finish;
    end

endmodule
