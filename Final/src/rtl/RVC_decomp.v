module RVC_decomp(
    input [15:0] RVC_inst,
    output reg [31:0] inst
);

    // Extract fields from RVC instruction
    wire [1:0] opcode = RVC_inst[1:0];
    wire [2:0] funct3 = RVC_inst[15:13];
    wire [1:0] funct2 = RVC_inst[11:10];
    wire [5:0] funct6 = RVC_inst[15:10];
    
    // Register mappings for compressed registers (x8-x15)
    wire [4:0] rd_prime = {2'b01, RVC_inst[4:2]};    // rd' = x8 + RVC_inst[4:2]
    wire [4:0] rs1_prime = {2'b01, RVC_inst[9:7]};   // rs1' = x8 + RVC_inst[9:7]
    wire [4:0] rs2_prime = {2'b01, RVC_inst[4:2]};   // rs2' = x8 + RVC_inst[4:2]
    
    // Full register fields
    wire [4:0] rd_full = RVC_inst[11:7];
    wire [4:0] rs1_full = RVC_inst[11:7];
    wire [4:0] rs2_full = RVC_inst[6:2];
    
    // Immediate extraction and sign extension
    wire [11:0] c_addi_imm = {{6{RVC_inst[12]}}, RVC_inst[12], RVC_inst[6:2]};
    wire [11:0] c_andi_imm = {{6{RVC_inst[12]}}, RVC_inst[12], RVC_inst[6:2]};
    
    // Load/Store immediate (zero-extended and scaled by 4)
    wire [11:0] c_lw_imm = {5'b0, RVC_inst[5], RVC_inst[12:10], RVC_inst[6], 2'b00};
    wire [11:0] c_sw_imm = {5'b0, RVC_inst[5], RVC_inst[12:10], RVC_inst[6], 2'b00};
    
    // Branch immediate (sign-extended)
    wire [12:0] c_branch_imm = {{4{RVC_inst[12]}}, RVC_inst[12], RVC_inst[6:5], RVC_inst[2], RVC_inst[11:10], RVC_inst[4:3], 1'b0};
    
    // Jump immediate (sign-extended)
    wire [20:0] c_j_imm = {{9{RVC_inst[12]}}, RVC_inst[12], RVC_inst[8], RVC_inst[10:9], RVC_inst[6], RVC_inst[7], RVC_inst[2], RVC_inst[11], RVC_inst[5:3], 1'b0};
    
    // Shift amount
    wire [5:0] shamt = {RVC_inst[12], RVC_inst[6:2]};

    always @(*) begin
        case (opcode)
            2'b00: begin // Quadrant 0
                case (funct3)
                    3'b010: begin // C.LW
                        // lw rd', offset[6:2](rs1')
                        inst = {c_lw_imm, rs1_prime, 3'b010, rd_prime, 7'b0000011};
                    end
                    3'b110: begin // C.SW
                        // sw rs2', offset[6:2](rs1')
                        inst = {c_sw_imm[11:5], rs2_prime, rs1_prime, 3'b010, c_sw_imm[4:0], 7'b0100011};
                    end
                    default: begin
                        inst = 32'h00000013; // NOP (addi x0, x0, 0)
                    end
                endcase
            end
            
            2'b01: begin // Quadrant 1
                case (funct3)
                    3'b000: begin // C.ADDI or C.NOP
                        if (rd_full == 5'b0 && c_addi_imm == 12'b0) begin
                            // C.NOP: addi x0, x0, 0
                            inst = 32'h00000013;
                        end else begin
                            // C.ADDI: addi rd, rd, nzimm[5:0]
                            inst = {c_addi_imm, rd_full, 3'b000, rd_full, 7'b0010011};
                        end
                    end
                    3'b001: begin // C.JAL
                        // jal x1, offset[11:1]
                        inst = {c_j_imm[20], c_j_imm[10:1], c_j_imm[11], c_j_imm[19:12], 5'b00001, 7'b1101111};
                    end
                    3'b010: begin // C.LI (actually implemented as ADDI)
                        // addi rd, x0, imm[5:0]
                        inst = {c_addi_imm, 5'b00000, 3'b000, rd_full, 7'b0010011};
                    end
                    3'b100: begin // C.SRLI, C.SRAI, C.ANDI, C.SUB, C.XOR, C.OR, C.AND
                        case (funct2)
                            2'b00: begin // C.SRLI
                                // srli rd', rd', shamt[5:0]
                                inst = {6'b000000, shamt, rs1_prime, 3'b101, rs1_prime, 7'b0010011};
                            end
                            2'b01: begin // C.SRAI
                                // srai rd', rd', shamt[5:0]
                                inst = {6'b010000, shamt, rs1_prime, 3'b101, rs1_prime, 7'b0010011};
                            end
                            2'b10: begin // C.ANDI
                                // andi rd', rd', imm[5:0]
                                inst = {c_andi_imm, rs1_prime, 3'b111, rs1_prime, 7'b0010011};
                            end
                            2'b11: begin // C.SUB, C.XOR, C.OR, C.AND
                                case ({RVC_inst[12], RVC_inst[6:5]})
                                    3'b000: begin // C.SUB
                                        // sub rd', rd', rs2'
                                        inst = {7'b0100000, rs2_prime, rs1_prime, 3'b000, rs1_prime, 7'b0110011};
                                    end
                                    3'b001: begin // C.XOR
                                        // xor rd', rd', rs2'
                                        inst = {7'b0000000, rs2_prime, rs1_prime, 3'b100, rs1_prime, 7'b0110011};
                                    end
                                    3'b010: begin // C.OR
                                        // or rd', rd', rs2'
                                        inst = {7'b0000000, rs2_prime, rs1_prime, 3'b110, rs1_prime, 7'b0110011};
                                    end
                                    3'b011: begin // C.AND
                                        // and rd', rd', rs2'
                                        inst = {7'b0000000, rs2_prime, rs1_prime, 3'b111, rs1_prime, 7'b0110011};
                                    end
                                    default: begin
                                        inst = 32'h00000013; // NOP
                                    end
                                endcase
                            end
                        endcase
                    end
                    3'b101: begin // C.J
                        // jal x0, offset[11:1]
                        inst = {c_j_imm[20], c_j_imm[10:1], c_j_imm[11], c_j_imm[19:12], 5'b00000, 7'b1101111};
                    end
                    3'b110: begin // C.BEQZ
                        // beq rs1', x0, offset[8:1]
                        inst = {c_branch_imm[12], c_branch_imm[10:5], 5'b00000, rs1_prime, 3'b000, c_branch_imm[4:1], c_branch_imm[11], 7'b1100011};
                    end
                    3'b111: begin // C.BNEZ
                        // bne rs1', x0, offset[8:1]
                        inst = {c_branch_imm[12], c_branch_imm[10:5], 5'b00000, rs1_prime, 3'b001, c_branch_imm[4:1], c_branch_imm[11], 7'b1100011};
                    end
                    default: begin
                        inst = 32'h00000013; // NOP
                    end
                endcase
            end
            
            2'b10: begin // Quadrant 2
                case (funct3)
                    3'b000: begin // C.SLLI
                        // slli rd, rd, shamt[5:0]
                        inst = {6'b000000, shamt, rd_full, 3'b001, rd_full, 7'b0010011};
                    end
                    3'b100: begin // C.JR, C.JALR, C.MV, C.ADD
                        if (RVC_inst[12] == 1'b0) begin
                            if (rs2_full == 5'b0) begin // C.JR
                                // jalr x0, rs1, 0
                                inst = {12'b0, rs1_full, 3'b000, 5'b00000, 7'b1100111};
                            end else begin // C.MV
                                // add rd, x0, rs2
                                inst = {7'b0000000, rs2_full, 5'b00000, 3'b000, rd_full, 7'b0110011};
                            end
                        end else begin
                            if (rs2_full == 5'b0) begin // C.JALR
                                // jalr x1, rs1, 0
                                inst = {12'b0, rs1_full, 3'b000, 5'b00001, 7'b1100111};
                            end else begin // C.ADD
                                // add rd, rd, rs2
                                inst = {7'b0000000, rs2_full, rd_full, 3'b000, rd_full, 7'b0110011};
                            end
                        end
                    end
                    default: begin
                        inst = 32'h00000013; // NOP
                    end
                endcase
            end
            
            default: begin
                inst = 32'h00000013; // NOP (invalid compressed instruction)
            end
        endcase
    end

endmodule