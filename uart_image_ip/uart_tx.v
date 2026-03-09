module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output reg        tx_pin,
    output reg        tx_busy
);
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [1:0]  state;
    reg [15:0] timer;
    reg [2:0]  bit_idx;
    reg [7:0]  data_reg;

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_pin <= 1;
            tx_busy <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_pin <= 1;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx_busy  <= 1;
                        timer    <= 0;
                        state    <= START;
                    end else tx_busy <= 0;
                end
                START: begin
                    tx_pin <= 0; // Start bit
                    if (timer == BIT_PERIOD - 1) begin
                        timer <= 0;
                        bit_idx <= 0;
                        state <= DATA;
                    end else timer <= timer + 1;
                end
                DATA: begin
                    tx_pin <= data_reg[bit_idx];
                    if (timer == BIT_PERIOD - 1) begin
                        timer <= 0;
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1;
                    end else timer <= timer + 1;
                end
                STOP: begin
                    tx_pin <= 1; // Stop bit
                    if (timer == BIT_PERIOD - 1) begin
                        state <= IDLE;
                    end else timer <= timer + 1;
                end
            endcase
        end
    end
endmodule
