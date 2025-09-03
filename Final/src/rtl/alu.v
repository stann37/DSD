module alu(
    input           [31:0]  a,
    input           [31:0]  b,
    input           [3:0]   alu_ctrl,
    output  reg     [31:0]  result,
    output  zero
);

    // ALU operation codes
    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_SUB  = 4'b0110;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0111;
    localparam ALU_SRA  = 4'b1101;

    always @(*) begin
        case (alu_ctrl)
            ALU_AND:  result = a & b;
            ALU_OR:   result = a | b;
            ALU_ADD:  result = $signed(a) + $signed(b);
            ALU_SUB:  result = $signed(a) - $signed(b);
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            ALU_XOR:  result = a ^ b;
            ALU_SLL:  result = a << b[4:0];
            ALU_SRL:  result = a >> b[4:0];
            ALU_SRA:  result = $signed(a) >>> b[4:0];
            default:  result = 32'b0;
        endcase
    end

    assign zero = (result == 0);

endmodule