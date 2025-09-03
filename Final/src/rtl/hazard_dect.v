module hazard_dectv2(
    input IDEX_MemRead, EXMEM_MemRead, IDEX_RegWrite,
    input Branch, Jal, Jalr,
    input [4:0] rs1, rs2, IDEX_rd, EXMEM_rd,
    output reg hazard_stall
);
    always @(*) begin
        hazard_stall = 0;
        if ((IDEX_MemRead && ((IDEX_rd == rs1) || (IDEX_rd == rs2)) && (IDEX_rd != 0)) ||
            (EXMEM_MemRead && ((EXMEM_rd == rs1) || (EXMEM_rd == rs2)) && (EXMEM_rd != 0) && (Branch || Jal || Jalr)) ||
            (((IDEX_rd == rs1) || (IDEX_rd == rs2)) && (IDEX_rd != 0) && IDEX_RegWrite && (Branch || Jal || Jalr))) hazard_stall = 1;
        // dependant / lw
        // JB / nop / lw
        // JB / dependant
    end
endmodule

module hazard_dectv3(
    input [4:0] rs1, rs2,
    input Branch, Jal, Jalr,
    input Mul,

    input [4:0] IDEX_rd,
    input IDEX_MemRead, IDEX_RegWrite, IDEX_Mul,

    input [4:0] EXMEM_rd,
    input EXMEM_MemRead, EXMEM_Mul,

    output reg hazard_stall
);
    // WBR: this stage will write back to register
    wire IDEX_WBR, EXMEM_WBR;
    wire JB;

    assign IDEX_WBR = ((IDEX_rd == rs1) || (IDEX_rd == rs2)) && (IDEX_rd != 0);
    assign EXMEM_WBR = ((EXMEM_rd == rs1) || (EXMEM_rd == rs2)) && (EXMEM_rd != 0);
    assign JB = Branch || Jal || Jalr;

    always @(*) begin
        hazard_stall = 0;
        if ((IDEX_WBR && (IDEX_MemRead || IDEX_Mul)) ||
            (EXMEM_WBR && (JB || Mul) && (EXMEM_MemRead || EXMEM_Mul)) ||
            (IDEX_WBR && (JB || Mul) && IDEX_RegWrite)) hazard_stall = 1;
    end
endmodule

module hazard_dectv4(
    input [4:0] rs1, rs2,
    input Branch, Jal, Jalr,
    input Mul,

    input [4:0] IDEX_rd,
    input IDEX_MemRead, IDEX_RegWrite, IDEX_Mul,

    input [4:0] EXMEM_rd,
    input EXMEM_MemRead, EXMEM_Mul,

    output reg hazard_stall
);
    // WBR: this stage will write back to register
    wire IDEX_WBR, EXMEM_WBR;
    wire JB;

    assign IDEX_WBR = ((IDEX_rd == rs1) || (IDEX_rd == rs2)) && (IDEX_rd != 0);
    assign EXMEM_WBR = ((EXMEM_rd == rs1) || (EXMEM_rd == rs2)) && (EXMEM_rd != 0);
    assign JB = Branch || Jal || Jalr;

    always @(*) begin
        hazard_stall = 0;
        if ((IDEX_WBR && IDEX_MemRead) ||
            (EXMEM_WBR && JB && EXMEM_MemRead) ||
            ((IDEX_WBR && JB && IDEX_RegWrite) && !IDEX_Mul)) hazard_stall = 1;
    end
endmodule