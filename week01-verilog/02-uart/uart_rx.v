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

    localparam IDLE = 2'b00,
               WAIT = 2'b01,   // 等待起始位结束
               RCV  = 2'b10,   // 接收数据
               STOP = 2'b11;

    reg [1:0] state;
    reg [8:0] baud_cnt;
    reg [2:0] bit_cnt;

    // rx同步+边沿检测（2-flop）
    reg rx_ff1, rx_ff2, rx_ff3;
    wire rx_falling;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rx_ff1 <= 1'b1;
            rx_ff2 <= 1'b1;
            rx_ff3 <= 1'b1;
        end
        else begin
            rx_ff1 <= rx;
            rx_ff2 <= rx_ff1;
            rx_ff3 <= rx_ff2;
        end
    end
    assign rx_falling = ~rx_ff2 & rx_ff3;   // 检测下降沿

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state    <= IDLE;
            baud_cnt <= 0;
            bit_cnt  <= 0;
            data_out <= 8'b0;
            rx_done  <= 1'b0;
        end
        else begin
            rx_done <= 1'b0;

            case(state)
                IDLE: begin
                    baud_cnt <= 0;
                    bit_cnt  <= 0;
                    if(rx_falling)
                        state <= WAIT;
                end

                // 等BAUD_TICK个时钟（起始位结束）
                WAIT: begin
                    if(baud_cnt == BAUD_TICK - 1) begin
                        state    <= RCV;
                        baud_cnt <= 0;
                        bit_cnt  <= 0;
                    end
                    else
                        baud_cnt <= baud_cnt + 1'b1;
                end

                // 每BAUD_TICK个时钟读一个bit（在bit末尾采样）
                RCV: begin
                    if(baud_cnt == BAUD_TICK - 1) begin
                        data_out[bit_cnt] <= rx_ff2;
                        baud_cnt <= 0;
                        if(bit_cnt == 3'd7)
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1'b1;
                    end
                    else
                        baud_cnt <= baud_cnt + 1'b1;
                end

                // 等停止位结束
                STOP: begin
                    if(baud_cnt == BAUD_TICK - 1) begin
                        state    <= IDLE;
                        rx_done  <= 1'b1;
                        baud_cnt <= 0;
                    end
                    else
                        baud_cnt <= baud_cnt + 1'b1;
                end
            endcase
        end
    end

endmodule
