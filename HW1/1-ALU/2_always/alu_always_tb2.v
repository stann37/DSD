//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

module alu_always_tb;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;
    
    alu_always alu_always(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

    initial begin
        $fsdbDumpfile("alu_always.fsdb");
        $fsdbDumpvars;
    end

    initial begin
        // Initialize
        ctrl = 4'b0000;
        x    = 8'd0;
        y    = 8'd0;
        
        //------------------------------------------------------------------------
        // Sum of 8-bit signed numbers
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b0000;
        x = 8'b0111_1101;
        y = 8'b0000_0111;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1000_0100) $display( "PASS --- sum test 1" );
        else $display( "FAIL --- sum test 1" );
        
        #(`HCYCLE);
        x = 8'b0010_1011;
        y = 8'b1010_0111; 

        #(`HCYCLE);
        if(carry == 1'b1 && out == 8'b1101_0010) $display( "PASS --- sum test 2" );
        else $display( "FAIL --- sum test 2" );

        #(`HCYCLE);
        x = 8'b1001_0110;
        y = 8'b0010_1101; 

        #(`HCYCLE);
        if(carry == 1'b1 && out == 8'b1100_0011) $display( "PASS --- sum test 3" );
        else $display( "FAIL --- sum test 3" );

        //------------------------------------------------------------------------
        // Sub of 8-bit signed numbers
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b0001;
        x = 8'b1010_1100;
        y = 8'b0001_0111;

        #(`HCYCLE);
        if(carry == 1'b1 && out == 8'b1001_0101) $display( "PASS --- sub test 1" );
        else $display( "FAIL --- sub test 1" );

        #(`HCYCLE);
        x = 8'b0011_0011;
        y = 8'b0001_0100;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0001_1111) $display( "PASS --- sub test 2" );
        else $display( "FAIL --- sub test 2" );

        #(`HCYCLE);
        x = 8'b0001_1000;
        y = 8'b1011_0110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0110_0010) $display( "PASS --- sub test 3" );
        else $display( "FAIL --- sub test 3" );

        //------------------------------------------------------------------------
        // Bitwise and
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b0010;
        x = 8'b1010_1101;
        y = 8'b0101_1010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_1000) $display( "PASS --- and test 1" );
        else $display( "FAIL --- and test 1" );

        #(`HCYCLE);
        x = 8'b1111_0100;
        y = 8'b1010_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1010_0100) $display( "PASS --- and test 2" );
        else $display( "FAIL --- and test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;
        y = 8'b1110_0010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0010_0010) $display( "PASS --- and test 3" );
        else $display( "FAIL --- and test 3" );

        //------------------------------------------------------------------------
        // Bitwise or
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b0011;
        x = 8'b1010_1101;
        y = 8'b0101_1010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1111_1111) $display( "PASS --- or test 1" );
        else $display( "FAIL --- or test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;
        y = 8'b1010_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1010_1110) $display( "PASS --- or test 2" );
        else $display( "FAIL --- or test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;
        y = 8'b0010_0010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0011_1110) $display( "PASS --- or test 3" );
        else $display( "FAIL --- or test 3" );

        //------------------------------------------------------------------------
        // Bitwise not
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b0100;
        x = 8'b1010_1101;
        y = 8'b0000_0000;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0101_0010) $display( "PASS --- not test 1" );
        else $display( "FAIL --- not test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0111_1011) $display( "PASS --- not test 2" );
        else $display( "FAIL --- not test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1100_0001) $display( "PASS --- not test 3" );
        else $display( "FAIL --- not test 3" );

        //------------------------------------------------------------------------
        // Bitwise xor 
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b0101;
        x = 8'b1010_1101;
        y = 8'b0101_1010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1111_0111) $display( "PASS --- xor test 1" );
        else $display( "FAIL --- xor test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;
        y = 8'b1010_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0010_1010) $display( "PASS --- xor test 2" );
        else $display( "FAIL --- xor test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;
        y = 8'b0010_0010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0001_1100) $display( "PASS --- xor test 3" );
        else $display( "FAIL --- xor test 3" );

        //------------------------------------------------------------------------
        // Bitwise nor
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b0110;
        x = 8'b1010_1101;
        y = 8'b0101_1010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_0000) $display( "PASS --- nor test 1" );
        else $display( "FAIL --- nor test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;
        y = 8'b1010_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0101_0001) $display( "PASS --- nor test 2" );
        else $display( "FAIL --- nor test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;
        y = 8'b0010_0010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1100_0001) $display( "PASS --- nor test 3" );
        else $display( "FAIL --- nor test 3" );

        //------------------------------------------------------------------------
        // Shift left logical
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b0111;
        x = 8'b1010_1101;
        y = 8'b0101_1010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0100_0000) $display( "PASS --- shift left logical test 1" );
        else $display( "FAIL --- shift left logical test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;
        y = 8'b1010_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1110_0000) $display( "PASS --- shift left logical test 2" );
        else $display( "FAIL --- shift left logical test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;
        y = 8'b0010_0010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1000_0000) $display( "PASS --- shift left logical test 3" );
        else $display( "FAIL --- shift left logical test 3" );

        //------------------------------------------------------------------------
        // Shift right logical
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b1000;
        x = 8'b1010_1001;
        y = 8'b0101_1010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0010_1101) $display( "PASS --- shift right logical test 1" );
        else $display( "FAIL --- shift right logical test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;
        y = 8'b1010_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_1010) $display( "PASS --- shift right logical test 2" );
        else $display( "FAIL --- shift right logical test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;
        y = 8'b0010_0010;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_0000) $display( "PASS --- shift right logical test 3" );
        else $display( "FAIL --- shift right logical test 3" );

        //------------------------------------------------------------------------
        // Shift right arithmetic
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b1001;
        x = 8'b1010_1001;
        y = 8'b0000_0000;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1101_0100) $display( "PASS --- shift right arithmetic test 1" );
        else $display( "FAIL --- shift right arithmetic test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1100_0010) $display( "PASS --- shift right arithmetic test 2" );
        else $display( "FAIL --- shift right arithmetic test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0001_1111) $display( "PASS --- shift right arithmetic test 3" );
        else $display( "FAIL --- shift right arithmetic test 3" );

        //------------------------------------------------------------------------
        // Rotate left
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b1010;
        x = 8'b1010_1001;
        y = 8'b0000_0000;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0101_0011) $display( "PASS --- rotate left test 1" );
        else $display( "FAIL --- rotate left test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_1001) $display( "PASS --- rotate left test 2" );
        else $display( "FAIL --- rotate left test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0111_1100) $display( "PASS --- rotate left test 3" );
        else $display( "FAIL --- rotate left test 3" );

        //------------------------------------------------------------------------
        // Rotate right
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b1011;
        x = 8'b1010_1001;
        y = 8'b0000_0000;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b1101_0100) $display( "PASS --- rotate right test 1" );
        else $display( "FAIL --- rotate right test 1" );

        #(`HCYCLE);
        x = 8'b1000_0100;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0100_0010) $display( "PASS --- rotate right test 2" );
        else $display( "FAIL --- rotate right test 2" );

        #(`HCYCLE);
        x = 8'b0011_1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0001_1111) $display( "PASS --- rotate right test 3" );
        else $display( "FAIL --- rotate right test 3" );

        //------------------------------------------------------------------------
        // equal
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b1100;
        x = 8'b1010_1001;
        y = 8'b0000_0000;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_0000) $display( "PASS --- equal test 1" );
        else $display( "FAIL --- equal test 1" );

        #(`HCYCLE);
        x = 8'b1010_1001;
        y = 8'b1010_1001;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_0001) $display( "PASS --- equal test 2" );
        else $display( "FAIL --- equal test 2" );

        //------------------------------------------------------------------------
        // nop
        //------------------------------------------------------------------------
        #(`CYCLE);
        ctrl = 4'b1101;
        x = 8'b1010_1001;
        y = 8'b0000_0000;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_0000) $display( "PASS ---  nop test 1");
        else $display( "FAIL --- nop test 1" );

        #(`HCYCLE);
        ctrl = 4'b1110;

        #(`HCYCLE);
        if(carry == 1'b0 && out == 8'b0000_0000) $display( "PASS ---  nop test 2");
        else $display( "FAIL --- nop test 2" );

        // finish tb
        #(`CYCLE) $finish;
    end

endmodule
