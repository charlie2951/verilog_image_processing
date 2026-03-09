module image_processor (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [1:0]  op_select,

    output wire        uart_tx_pin,
    output reg         LED
);

    reg done;
    //--------------------------------
    // Image RAM
    //--------------------------------
    (* ram_style = "block" *) reg [31:0] image_ram [0:1023];

    //--------------------------------
    // Registers
    //--------------------------------
    reg [31:0] data_buffer;
    reg [9:0]  addr;
    reg [1:0]  byte_sel; // Fixed to 2 bits to match 0-3 range

    reg [7:0] p0_out, p1_out, p2_out, p3_out;
    reg [7:0] last_pixel_from_prev_word; // To bridge the gap between RAM words

    //--------------------------------
    // UART TX
    //--------------------------------
    reg [7:0] tx_data;
    reg       tx_start;
    wire      tx_busy;

    uart_tx TX (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_pin(uart_tx_pin),
        .tx_busy(tx_busy)
    );

    //--------------------------------
    // FSM States
    //--------------------------------
    localparam IDLE    = 3'd0;
    localparam FETCH   = 3'd1;
    localparam PROCESS = 3'd5;
    localparam SEND    = 3'd2;
    localparam WAIT    = 3'd4;
    localparam DONE    = 3'd3;

    reg [2:0] state;

    initial begin
        $readmemh("image_data.mem", image_ram);
    end

    //--------------------------------
    // Enhanced Pixel processing Function
    //--------------------------------
    function [7:0] process_pixel;
        input [7:0] p_curr;
        input [7:0] p_prev;
        input [1:0] op;
        
        reg [7:0] diff;
        
        begin
            case(op)
                2'b00: process_pixel = ~p_curr; // Invert
                2'b01: process_pixel = (p_curr > 8'd225) ? 8'hFF : p_curr + 8'd30; // Brighten
                2'b10: process_pixel = (p_curr > 8'd128) ? 8'hFF : 8'h00; // Threshold
                
                // CASE 11: Simple Horizontal Edge Detection
                2'b11: begin
                    diff = (p_curr > p_prev) ? (p_curr - p_prev) : (p_prev - p_curr);
                    process_pixel = (diff > 8'd20) ? 8'hFF : 8'h00; // Sensitivity threshold
                end
                default: process_pixel = p_curr;
            endcase
        end
    endfunction

    //--------------------------------
    // FSM logic
    //--------------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
            addr <= 0;
            byte_sel <= 0;
            tx_start <= 0;
            done <= 0;
            LED <= 0;
            last_pixel_from_prev_word <= 0;
        end else begin
            tx_start <= 0;

            case(state)
                IDLE: begin
                    done <= 0;
                    if(start) begin
                        addr <= 0;
                        state <= FETCH;
                    end
                end

                FETCH: begin
                    data_buffer <= image_ram[addr];
                    byte_sel <= 0;
                    state <= PROCESS;
                end

                PROCESS: begin
                    // Process pixels using the previous pixel for comparison
                    // For p0, we use the last pixel from the previous RAM word
                    p0_out <= process_pixel(data_buffer[31:24], last_pixel_from_prev_word, op_select);
                    p1_out <= process_pixel(data_buffer[23:16], data_buffer[31:24], op_select);
                    p2_out <= process_pixel(data_buffer[15:8],  data_buffer[23:16], op_select);
                    p3_out <= process_pixel(data_buffer[7:0],   data_buffer[15:8],  op_select);
                    
                    // Store the last pixel of this word for the next FETCH
                    last_pixel_from_prev_word <= data_buffer[7:0];
                    state <= SEND;
                end

                SEND: begin
                    if(!tx_busy) begin
                        case(byte_sel)
                            2'b00: tx_data <= p0_out;
                            2'b01: tx_data <= p1_out;
                            2'b10: tx_data <= p2_out;
                            2'b11: tx_data <= p3_out;
                        endcase
                        tx_start <= 1;
                        state <= WAIT;
                    end
                end

                WAIT: begin
                    if(!tx_busy) begin
                        if(byte_sel == 3) begin
                            byte_sel <= 0;
                            if(addr == 1023) state <= DONE;
                            else begin
                                addr <= addr + 1;
                                state <= FETCH;
                            end
                        end else begin
                            byte_sel <= byte_sel + 1;
                            state <= SEND;
                        end
                    end
                end

                DONE: begin
                    done <= 1;
                    LED <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
