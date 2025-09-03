`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module register_file_tb;
    // port declaration for design-under-test
    reg Clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW;
    wire [7:0] busX, busY;
    
    // instantiate the design-under-test
    register_file rf(
        .Clk   (Clk),
        .WEN   (WEN),
        .RW    (RW),
        .busW  (busW),
        .RX    (RX),
        .RY    (RY),
        .busX  (busX),
        .busY  (busY)
    );

    // Clock generation
    initial begin
        Clk = 1'b0;
        forever #(`HCYCLE) Clk = ~Clk;
    end
    
    // Test pattern generation
    initial begin
        // Initial values
        WEN = 1'b0;
        RW  = 3'd0;
        RX  = 3'd0;
        RY  = 3'd0;
        busW = 8'd0;
        
        // Setup waveform dumping
        $fsdbDumpfile("register_file.fsdb");
        $fsdbDumpvars;
        
        // Display header for readability in console output
        $display("========================================");
        $display("Register File Testbench Starting");
        $display("========================================");
        
        // Wait for a few cycles after reset
        #(`CYCLE*2);
        
        // Test Case 1: Write to registers 1-7 and verify they store data
        $display("Test Case 1: Basic Write and Read Operations");
        
        // Write values to registers 1-7
        write_register(3'd1, 8'hA1);
        write_register(3'd2, 8'hB2);
        write_register(3'd3, 8'hC3);
        write_register(3'd4, 8'hD4);
        write_register(3'd5, 8'hE5);
        write_register(3'd6, 8'hF6);
        write_register(3'd7, 8'h77);
        
        // Read and verify each register individually
        verify_register(3'd1, 8'hA1, "R1 after write");
        verify_register(3'd2, 8'hB2, "R2 after write");
        verify_register(3'd3, 8'hC3, "R3 after write");
        verify_register(3'd4, 8'hD4, "R4 after write");
        verify_register(3'd5, 8'hE5, "R5 after write");
        verify_register(3'd6, 8'hF6, "R6 after write");
        verify_register(3'd7, 8'h77, "R7 after write");
        
        // Test Case 2: Verify that R0 always reads as zero
        $display("\nTest Case 2: Verify R0 is always zero");
        
        // Try to write to R0 (should be ignored)
        write_register(3'd0, 8'hFF);
        
        // Check that R0 still reads as zero
        verify_register(3'd0, 8'h00, "R0 after attempted write");
        
        // Test Case 3: Simultaneous read from two different registers
        $display("\nTest Case 3: Simultaneous read from two registers");
        
        // Read registers 3 and 5 simultaneously
        RX = 3'd3;
        RY = 3'd5;
        #(`CYCLE);
        
        if (busX === 8'hC3 && busY === 8'hE5)
            $display("PASS: Simultaneous read successful - busX = 0x%h, busY = 0x%h", busX, busY);
        else
            $display("FAIL: Simultaneous read failed - busX = 0x%h (expected 0xC3), busY = 0x%h (expected 0xE5)", 
                     busX, busY);
        
        // Test Case 4: Write with WEN disabled
        $display("\nTest Case 4: Write with WEN disabled");
        
        // Attempt to write to R2 with WEN disabled
        WEN = 1'b0;
        RW = 3'd2;
        busW = 8'h55;
        #(`CYCLE);
        
        // Check that R2 is unchanged
        verify_register(3'd2, 8'hB2, "R2 after write attempt with WEN=0");
        
        // Test Case 5: Overwrite existing register value
        $display("\nTest Case 5: Overwrite existing register value");
        
        // Write a new value to R7
        write_register(3'd7, 8'h99);
        
        // Verify that R7 has been updated
        verify_register(3'd7, 8'h99, "R7 after overwrite");
        
        // Test Case 6: Read-during-write behavior
        $display("\nTest Case 6: Read-during-write behavior");
        
        // Setup write to R4
        WEN = 1'b1;
        RW = 3'd4;
        busW = 8'h42;
        
        // Also try to read R4 in the same cycle
        RX = 3'd4;
        
        // Clock edge
        #(`CYCLE);
        
        // Check what the read returned
        $display("Read-during-write returned 0x%h", busX);
        
        // Finish
        $display("\n========================================");
        $display("Register File Testbench Complete");
        $display("========================================");
        #(`CYCLE*2) $finish;
    end
    
    // Task for writing a value to a register
    task write_register;
        input [2:0] reg_num;
        input [7:0] data;
        begin
            @(negedge Clk); // Prepare inputs before the clock edge
            WEN = 1'b1;
            RW = reg_num;
            busW = data;
            @(posedge Clk); // Wait for rising clock edge
            #1; // Small delay after clock edge
            WEN = 1'b0;
        end
    endtask
    
    // Task for verifying a register value
    task verify_register;
        input [2:0] reg_num;
        input [7:0] expected;
        input [64*8:1] test_name;
        begin
            @(negedge Clk); // Setup read at stable time
            WEN = 1'b0;
            RX = reg_num;
            #(`HCYCLE); // Allow some time for read to propagate
            
            if (busX === expected)
                $display("PASS: %s - R%d = 0x%h", test_name, reg_num, busX);
            else
                $display("FAIL: %s - R%d = 0x%h (expected 0x%h)", test_name, reg_num, busX, expected);
        end
    endtask

endmodule