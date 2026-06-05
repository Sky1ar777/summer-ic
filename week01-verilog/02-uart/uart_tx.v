module uart_tx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input clk,
    input rst_n,
    input [7:0] data_in,
    input tx_start,

    output reg tx,
    output reg tx_busy
);
//状态机:空闲、发起始位、发bit0、发bit1、发bit2、发bit3、发bit4、发bit5、
//发bit6、发bit7、发停止位、回到空闲
//数据位：8bit，不需要状态，计数器就行
localparam IDLE  = 4'b0001,
           START = 4'b0010,
           DATA  = 4'b0100,
           STOP  = 4'b1000;
localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;
reg [8:0] baud_cnt;
reg [2:0] bit_cnt;
reg [3:0] current_state,next_state;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end
always @(*) begin
    case(current_state)
        IDLE:begin
            if(tx_start)
                next_state <= START;
            else
                next_state <= IDLE;
        end
        START:begin
             if(baud_cnt == BAUD_TICK - 1)
                next_state <= DATA;
            else
                next_state <= START;
        end
        DATA:begin
            if((baud_cnt == BAUD_TICK - 1) &&(bit_cnt == 3'd7))
                next_state <= STOP;
            else
                next_state <= DATA;
        end
        STOP:begin
            if(baud_cnt == BAUD_TICK - 1)
                next_state <= IDLE;
            else
                next_state <= STOP;
        end
    endcase
end
// tx_busy 时序输出
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tx_busy <= 1'b0;
    else
        tx_busy <= (current_state != IDLE);
end
// tx 组合逻辑输出
always @(*) begin
    case(current_state)
        IDLE:  tx = 1'b1;
        START: tx = 1'b0;
        DATA:  tx = data_in[bit_cnt];
        STOP:  tx = 1'b1;
        default: tx = 1'b1;
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        bit_cnt <= 1'b0;
    else if((baud_cnt == BAUD_TICK - 1) &&(current_state == DATA))
        bit_cnt <= bit_cnt + 1'b1;
    else if(current_state == START)
        bit_cnt <= 1'b0;
    else
        bit_cnt <= bit_cnt;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        baud_cnt <= 1'b0;
    else if (current_state == IDLE)
        baud_cnt <= 1'b0;
    else if(baud_cnt == BAUD_TICK - 1)
        baud_cnt <= 1'b0;
    else 
        baud_cnt <= baud_cnt + 1'b1;
end
endmodule 
