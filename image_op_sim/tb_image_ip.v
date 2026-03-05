`timescale 1ns / 1ps
`include "image_ip.v"
module tb_image_processor();

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [1:0] op_select;

    // Outputs
    wire done;

    // Instantiate the Unit Under Test (UUT)
    image_processor uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .op_select(op_select),
        .done(done)
    );

    // Clock Generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    // File writing task
    integer file_ptr;
    integer idx;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        start = 0;
        // 00: Invert, 01: Brighten, 10: Threshold
    
        op_select = 2'b10; // Let's test Thresholding (10)

        // Reset Sequence
        #20 rst_n = 1;
        #20 start = 1;
        #10 start = 0; // Pulse start

        // Wait for the 'done' signal
        wait(done == 1);
        
        // Brief delay to ensure last write is visible in simulation
        #20;

        // Save result_ram to a text file
        file_ptr = $fopen("processed_output.txt", "w");
        if (file_ptr == 0) begin
            $display("Error: Could not open file for writing.");
            $finish;
        end

        $display("Saving result_ram to processed_output.txt...");
        for (idx = 0; idx < 1024; idx = idx + 1) begin
            // Accessing the internal memory of the UUT
            $fdisplay(file_ptr, "%h", uut.result_ram[idx]);
        end
        
        $fclose(file_ptr);
        $display("Done! Simulation finished.");
        $finish;
    end

    // Monitor progress in the console
    initial begin
        $monitor("Time: %0t | State: %b | Index: %0d | Done: %b", $time, uut.state, uut.i, done);
    end

endmodule