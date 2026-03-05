module image_processor (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [1:0]  op_select,   // 00: Invert, 01: Brighten, 10: Threshold
    output reg         done
);

    // Internal Memory (Output RAM)
    // 64x64 pixels = 4096 bytes. Packed 4 per word = 1024 words.
    (* ram_style = "block" *) reg [31:0] result_ram [0:1023];
    (* ram_style = "block" *) reg [31:0] image_ram [0:1023];
    // Buffers to avoid indexing errors
    reg [31:0] data_buffer;
    reg [7:0]  p0, p1, p2, p3;     // Individual input pixels
    reg [7:0]  r0, r1, r2, r3;     // Individual result pixels

    // State Machine
    localparam IDLE    = 2'b00;
    localparam FETCH   = 2'b01; // Request data from ROM
    localparam WRITE   = 2'b10; // Process and store in RAM
    localparam FINISH  = 2'b11;

    reg [1:0] state;
    reg [12:0] i;

    initial begin
        // Loads the hex values from your file into the array
        $readmemh("image_data.mem", image_ram);
    end

    always @(posedge clk ) begin
        if (!rst_n) begin
            state    <= IDLE;
            done     <= 0;
            i <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        i <= 0;
                        state    <= FETCH;
                    end
                end

                FETCH: begin
                    // One cycle delay for ROM to output valid data
                    state <= WRITE;
                end

                WRITE: begin
                    // 1. Buffer the ROM data (solves the indexing error)
                    data_buffer = image_ram[i];
                    
                    // 2. Unpack bits from the buffer
                    p0 = data_buffer[31:24];
                    p1 = data_buffer[23:16];
                    p2 = data_buffer[15:8];
                    p3 = data_buffer[7:0];

                    // 3. Image Operations (Combinational logic within the state)
                    // Pixel 0
                    case (op_select)
                        2'b00: r0 = ~p0;                                 // Invert
                        2'b01: r0 = (p0 > 235) ? 8'hFF : (p0 + 8'd30);   // Brightness +20
                        2'b10: r0 = (p0 > 8'd128) ? 8'hFF : 8'h00;       // Threshold
                        default: r0 = p0;
                    endcase
                    
                    // (Apply same logic to r1, r2, r3)
                    case (op_select)
                        2'b00: r1 = ~p1;
                        2'b01: r1 = (p1 > 235) ? 8'hFF : (p1 + 8'd30);
                        2'b10: r1 = (p1 > 8'd128) ? 8'hFF : 8'h00;
                        default: r1 = p1;
                    endcase

                    case (op_select)
                        2'b00: r2 = ~p2;
                        2'b01: r2 = (p2 > 235) ? 8'hFF : (p2 + 8'd30);
                        2'b10: r2 = (p2 > 8'd128) ? 8'hFF : 8'h00;
                        default: r2 = p2;
                    endcase

                    case (op_select)
                        2'b00: r3 = ~p3;
                        2'b01: r3 = (p3 > 235) ? 8'hFF : (p3 + 8'd30);
                        2'b10: r3 = (p3 > 8'd128) ? 8'hFF : 8'h00;
                        default: r3 = p3;
                    endcase

                    // 4. Save packed result into the RAM array
                    result_ram[i] <= {r0, r1, r2, r3};

                    // 5. Address / Loop Control
                    if (i == 1023) begin
                        state <= FINISH;
                    end else begin
                        i <= i + 1;
                        state    <= FETCH;
                    end
                end

                FINISH: begin
                    done  <= 1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule