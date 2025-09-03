module forwarding_unit(
    input [4:0] IDEX_rs1, IDEX_rs2, EXMEM_rd, MEMWB_rd,
    input EXMEM_RegWrite, MEMWB_RegWrite,
    output reg [1:0] ForwardA, ForwardB
);
    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;
        // EX hazard
        if (EXMEM_RegWrite && (EXMEM_rd != 0) && (EXMEM_rd == IDEX_rs1)) ForwardA = 2'b10;
        else if (MEMWB_RegWrite && (MEMWB_rd != 0) && (MEMWB_rd == IDEX_rs1)) ForwardA = 2'b01;

        if (EXMEM_RegWrite && (EXMEM_rd != 0) && (EXMEM_rd == IDEX_rs2)) ForwardB = 2'b10;
        else if (MEMWB_RegWrite && (MEMWB_rd != 0) && (MEMWB_rd == IDEX_rs2)) ForwardB = 2'b01;
        // MEM hazard
        // if (MEMWB_RegWrite && (MEMWB_rd != 0) && !(EXMEM_RegWrite && (EXMEM_rd != 0) && (EXMEM_rd != IDEX_rs1)) && MEMWB_rd == IDEX_rs1) ForwardA = 2'b01;
        // if (MEMWB_RegWrite && (MEMWB_rd != 0) && !(EXMEM_RegWrite && (EXMEM_rd != 0) && (EXMEM_rd != IDEX_rs2)) && MEMWB_rd == IDEX_rs2) ForwardA = 2'b01;
    end
endmodule

module forwarding_unit_b(
    input [4:0] rs1, rs2, EXMEM_rd, MEMWB_rd,
    input EXMEM_RegWrite, MEMWB_RegWrite,
    output reg [1:0] ForwardA_b, ForwardB_b
);
    always @(*) begin
        ForwardA_b = 2'b00;
        ForwardB_b = 2'b00;
        
        if (EXMEM_RegWrite && (EXMEM_rd != 0) && (EXMEM_rd == rs1)) ForwardA_b = 2'b10;
        else if (MEMWB_RegWrite && (MEMWB_rd != 0) && (MEMWB_rd == rs1)) ForwardA_b = 2'b01;
        // already write before read, no need to forward from this stage

        if (EXMEM_RegWrite && (EXMEM_rd != 0) && (EXMEM_rd == rs2)) ForwardB_b = 2'b10;
        else if (MEMWB_RegWrite && (MEMWB_rd != 0) && (MEMWB_rd == rs2)) ForwardB_b = 2'b01;
    end
endmodule