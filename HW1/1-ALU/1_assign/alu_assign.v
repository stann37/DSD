//RTL (use continuous assignment)
module alu_assign(
    ctrl,
    x,
    y,
    carry,
    out  
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output       carry;
    output [7:0] out;

    wire [8:0] sum, sub;
    assign sum = $signed(x) + $signed(y);
    assign sub = $signed(x) - $signed(y);

    assign out = (ctrl == 4'b0000) ? sum[7:0] :
                 (ctrl == 4'b0001) ? sub[7:0] :
                 (ctrl == 4'b0010) ? x & y :
                 (ctrl == 4'b0011) ? x | y :
                 (ctrl == 4'b0100) ? ~x :
                 (ctrl == 4'b0101) ? x ^ y :
                 (ctrl == 4'b0110) ? ~(x | y) :
                 (ctrl == 4'b0111) ? y << x[2:0] :
                 (ctrl == 4'b1000) ? y >> x[2:0] :
                 (ctrl == 4'b1001) ? {x[7], x[7:1]} :
                 (ctrl == 4'b1010) ? {x[6:0], x[7]} :
                 (ctrl == 4'b1011) ? {x[0], x[7:1]} :
                 (ctrl == 4'b1100) ? ((x == y) ? 8'b1 : 8'b0) : 8'b0;

    assign carry = (ctrl == 4'b0000) ? sum[8] : 
                   (ctrl == 4'b0001) ? sub[8] : 1'b0;

endmodule
