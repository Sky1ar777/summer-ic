module pulse_sync (
    input  clkA,
    input  clkB,
    input  rst_n,
    input  pulseA,
    output pulseB
);
    // ---- clkA域：脉冲→电平 ----
    reg toggle;
    always @(posedge clkA or negedge rst_n) begin
        if(!rst_n)
            toggle <= 1'b0;           // 复位到0
        else if(pulseA)
            toggle <= ~toggle;        // 来脉冲就翻转
    end

    // ---- clkB域：2-flop同步 + 边沿检测 ----
    reg sync_1, sync_2, sync_3;
    always @(posedge clkB or negedge rst_n) begin
        if(!rst_n) begin
            sync_1 <= 1'b0;
            sync_2 <= 1'b0;
            sync_3 <= 1'b0;
        end
        else begin
            sync_1 <= toggle;
            sync_2 <= sync_1;
            sync_3 <= sync_2;
        end
    end

    // 边沿检测：电平翻转 → 恢复出脉冲
    assign pulseB = sync_2 ^ sync_3;
endmodule
