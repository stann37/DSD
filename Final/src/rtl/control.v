module control(
    input        [4:0]  opcode, // take opcode[6:2]
    output  reg         ALUSrc,
    output  reg  [1:0]  ALUOp,
    output  reg         Branch,
    output  reg         Jalr,
    output  reg         Jal,
    output  reg         MemWrite,
    output  reg         MemRead,
    output  reg         MemtoReg,
    output  reg         RegWrite
);

    always @(*) begin
        ALUSrc = 0;
        ALUOp = 0;
        Branch = 0;
        Jalr = 0;
        Jal = 0;
        MemWrite = 0;
        MemRead = 0;
        MemtoReg = 0;
        RegWrite = 0;
        
        case (opcode)
        
            5'b11011: begin     // Jal
                ALUOp = 2'b10;
                Jal = 1;
                RegWrite = 1;
            end
            5'b11001: begin     // Jalr
                ALUOp = 2'b10;
                Jalr = 1;
                RegWrite = 1;
            end
            5'b11000: begin     // Branch
                ALUOp = 2'b01;
                Branch = 1;
            end
            5'b00000: begin     // lw
                ALUSrc = 1;
                ALUOp = 2'b10;
                MemRead = 1;
                MemtoReg = 1;
                RegWrite = 1;
            end
            5'b01000: begin     // sw
                ALUSrc = 1;
                ALUOp = 2'b10;
                MemWrite = 1;
            end
            5'b00100: begin     // I-type
                ALUSrc = 1;
                ALUOp = 2'b11;
                RegWrite = 1;
            end
            5'b01100: begin     // R-type
                ALUOp = 2'b00;
                RegWrite = 1;
            end
        endcase
    end
endmodule

module alu_control(
    input           [1:0]   ALUOp,
    input                   func7_5,
    input           [2:0]   func3,
    output  reg     [3:0]   alu_ctrl
);
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
        alu_ctrl = ALU_ADD;
        case (ALUOp)
            2'b01: begin    // Branch
                alu_ctrl = ALU_SUB;
            end
            2'b11: begin    // I-type
                case (func3)
                    3'b010: alu_ctrl = ALU_SLT;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b111: alu_ctrl = ALU_AND;
                    3'b001: alu_ctrl = ALU_SLL;
                    3'b101: alu_ctrl = func7_5 ? ALU_SRA : ALU_SRL;
                    default: alu_ctrl = ALU_ADD;
                endcase
            end
            2'b00: begin    // R-type
                case (func3)
                    3'b000: alu_ctrl = func7_5 ? ALU_SUB : ALU_ADD;
                    3'b010: alu_ctrl = ALU_SLT;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b111: alu_ctrl = ALU_AND;
                    default: alu_ctrl = ALU_ADD;
                endcase
            end
        endcase
    end

endmodule