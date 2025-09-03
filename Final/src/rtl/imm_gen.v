module imm_gen(
    input       [31:0]  inst,
    output  reg [31:0]  imm
);
    wire    [31:0]  J_imm, S_imm, I_imm, B_imm;
    wire    [4:0]   opcode;

    assign opcode = inst[6:2];
    assign J_imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
    assign I_imm = {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
    assign B_imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    assign S_imm = {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};

    always @(*) begin
      case (opcode)
        5'b11011: imm = J_imm;
        5'b11000: imm = B_imm;
        5'b01000: imm = S_imm;
        default: imm = I_imm;
      endcase
    end
    
endmodule