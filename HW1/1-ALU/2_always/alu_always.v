//RT �Vlevel (event-driven) 
module alu_always(
    ctrl,
    x,
    y,
    carry,
    out 
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output reg   carry;
    output reg [7:0] out;
    
    reg [8:0] temp;

    always @(*) begin
        // Avoid latches
        carry = 1'b0;
        temp = 9'b0;

        case (ctrl)
            4'b0000: begin
                temp = $signed(x) + $signed(y);
                out = temp[7:0];
                carry = temp[8];
            end
            4'b0001: begin
                temp = $signed(x) - $signed(y);
                out = temp[7:0];
                carry = temp[8];
            end
            4'b0010: out = x & y;
            4'b0011: out = x | y;
            4'b0100: out = ~x;
            4'b0101: out = x ^ y;
            4'b0110: out = ~(x | y);
            4'b0111: out = y << x[2:0];
            4'b1000: out = y >> x[2:0];
            4'b1001: out = {x[7], x[7:1]};
            4'b1010: out = {x[6:0], x[7]};
            4'b1011: out = {x[0], x[7:1]};
            4'b1100: out = (x == y) ? 8'b1 : 8'b0;
            default: begin
                carry = 1'b0;
                out = 8'b0;
            end
        endcase
    end

endmodule
