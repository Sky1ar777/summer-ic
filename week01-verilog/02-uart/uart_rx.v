module uart_rx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        rx,

    output reg [7:0]   data_out,
    output reg         rx_done
);

    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT  = BAUD_TICK / 2;

    reg [8:0] cnt;
    reg [3:0] bits;     // {count, done} = 0-9, 10=done

    reg rx_ff1, rx_ff2;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rx_ff1 <= 1'b1;
            rx_ff2 <= 1'b1;
        end
        else begin
            rx_ff1 <= rx;
            rx_ff2 <= rx_ff1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt      <= 0;
            bits     <= 0;
            data_out <= 8'b0;
            rx_done  <= 1'b0;
        end
        else begin
            rx_done <= 1'b0;

            if(bits == 0) begin
                cnt <= 0;
                if(rx_ff2 == 1'b0)
                    bits <= 1;                   // START位开始
            end
            else if(bits <= 9) begin
                if(cnt == BAUD_TICK - 1) begin
                    cnt <= 0;
                    if(bits == 1) begin          // 抛弃START位
                        bits <= 2;
                    end
                    else if(bits == 2) begin     // bit0
                        data_out[0] <= rx_ff2; bits <= 3;
                    end
                    else if(bits == 3) begin     // bit1
                        data_out[1] <= rx_ff2; bits <= 4;
                    end
                    else if(bits == 4) begin     // bit2
                        data_out[2] <= rx_ff2; bits <= 5;
                    end
                    else if(bits == 5) begin     // bit3
                        data_out[3] <= rx_ff2; bits <= 6;
                    end
                    else if(bits == 6) begin     // bit4
                        data_out[4] <= rx_ff2; bits <= 7;
                    end
                    else if(bits == 7) begin     // bit5
                        data_out[5] <= rx_ff2; bits <= 8;
                    end
                    else if(bits == 8) begin     // bit6
                        data_out[6] <= rx_ff2; bits <= 9;
                    end
                    else if(bits == 9) begin     // bit7+停止位
                        data_out[7] <= rx_ff2;
                        bits <= 10;
                    end
                end
                else
                    cnt <= cnt + 1'b1;
            end
            else begin
                rx_done <= 1'b1;    // 通知外部
                bits    <= 0;
            end
        end
    end

endmodule
