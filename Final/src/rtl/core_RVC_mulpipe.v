module RISCV_Pipeline(
    input               clk, rst_n,

    output              ICACHE_ren, ICACHE_wen,
    output  reg [29:0]  ICACHE_addr,
    output      [31:0]  ICACHE_wdata,
    input               ICACHE_stall,
    input       [31:0]  ICACHE_rdata,

    output              DCACHE_ren, DCACHE_wen,
    output      [29:0]  DCACHE_addr,
    output      [31:0]  DCACHE_wdata,
    input               DCACHE_stall,
    input       [31:0]  DCACHE_rdata,

    output  reg [31:0]  PC
);
// ==== Wire and reg declarations =====================
    reg RST_N;

    reg [1:0] IF_state, nxt_IF_state;
    localparam IF_state_IDLE = 2'b00;
    localparam IF_state_BUF = 2'b01;
    localparam IF_state_JB = 2'b10;
    reg add2or4;
    reg [15:0] inst_buffer;
    reg [15:0] RVC_inst;
    reg [31:0] inst;
    wire [31:0] decomp_RVC_inst;
    reg [29:0] nxt_ICACHE_addr;
    // 0: PC + 2, reading RVC now
    // 1: PC + 4, reading RV32I now

    reg [31:0] nxt_PC;
    // wire [31:0] PC_add2or4;
    wire [31:0] PC_add2;
    wire [31:0] PC_add4;

    wire ALUSrc, Branch, Jalr, Jal, MemWrite, MemRead, MemtoReg, RegWrite;
    wire Mul;
    wire [1:0] ALUOp;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] rs1_data_b, rs2_data_b;
    wire [31:0] imm;
    wire [4:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [6:0] func7;
    wire [2:0] func3;
    wire Branch_met;
    wire equal;
    wire [31:0] JB_addr;
    wire [1:0] ForwardA_b, ForwardB_b;

    wire [1:0] ForwardA, ForwardB;

    wire [31:0] alu_a, alu_b, alu_result;
    wire [3:0] alu_ctrl;

    wire [31:0] reg_wdata;
    wire [31:0] mul_output;

    wire cache_stall;
    wire hazard_stall;

// ==== Pipeline registers ===========================
    
    reg [31:0] IFID_PC, IFID_PC_add2or4;
    reg [31:0] IFID_inst;

    reg [31:0] IDEX_PC_add2or4;
    reg [31:0] IDEX_rs1_data, IDEX_rs2_data;
    reg [31:0] IDEX_imm;
    reg [2:0] IDEX_func3;
    reg IDEX_func7_5;
    reg [4:0] IDEX_rs1;
    reg [4:0] IDEX_rs2;
    reg [4:0] IDEX_rd;

    // result = ALU result or PC_add2or4 to write back to register file
    reg [31:0] EXMEM_result;
    reg [31:0] EXMEM_rs2_data;
    reg [4:0] EXMEM_rd;

    reg [31:0] MEMWB_dmem_rdata;
    reg [31:0] MEMWB_result;
    reg [4:0] MEMWB_rd;

// ==== Control signals ==============================

    reg IDEX_Jal;
    reg IDEX_Jalr;
    reg IDEX_ALUSrc;
    reg [1:0] IDEX_ALUOp;
    reg IDEX_MemRead;
    reg IDEX_MemWrite;
    reg IDEX_MemtoReg;
    reg IDEX_RegWrite;
    reg IDEX_Mul;

    reg EXMEM_MemRead;
    reg EXMEM_MemWrite;
    reg EXMEM_MemtoReg;
    reg EXMEM_RegWrite;
    reg EXMEM_Mul;

    reg MEMWB_MemtoReg;
    reg MEMWB_RegWrite;
    reg MEMWB_Mul;
    
// ==== Cache IOs ====================================
    
    assign cache_stall = ICACHE_stall || DCACHE_stall;
    assign ICACHE_ren = RST_N;
    assign ICACHE_wen = 0;
    assign ICACHE_wdata = 0;
    assign DCACHE_ren = EXMEM_MemRead;
    assign DCACHE_wen = EXMEM_MemWrite;
    assign DCACHE_addr = EXMEM_result[31:2];
    assign DCACHE_wdata = {EXMEM_rs2_data[7:0], EXMEM_rs2_data[15:8], EXMEM_rs2_data[23:16], EXMEM_rs2_data[31:24]};

// ==== IF ============================================

    // assign PC_add2or4 = PC + (add2or4 ? 4 : 2);
    assign PC_add2 = PC + 2;
    assign PC_add4 = PC + 4;

    always @(posedge clk) begin
        RST_N <= rst_n;
        if (!RST_N) begin
            PC <= 0;
            IFID_PC <= 0;
            IFID_PC_add2or4 <= 0;
            IFID_inst <= 32'b000000000000_00000_000_00000_0010011;  // nop
            IF_state <= IF_state_IDLE;
            inst_buffer <= 0;
            ICACHE_addr <= 0;
        end
        else if (!(cache_stall || hazard_stall)) begin // no stall
            inst_buffer <= {ICACHE_rdata[7:0], ICACHE_rdata[15:8]};
            if (Jal || Jalr || Branch_met) begin // IF.Flush, default branch not taken -> flush taken inst.
                PC <= nxt_PC;
                IFID_inst <= 32'b000000000000_00000_000_00000_0010011;  // nop
                IF_state <= nxt_PC[1] ? IF_state_JB : IF_state_IDLE;
                ICACHE_addr <= nxt_PC[31:2];
            end
            else begin
                PC <= nxt_PC;
                IFID_PC <= PC;
                IFID_PC_add2or4 <= (add2or4 ? PC_add4 : PC_add2);
                IFID_inst <= inst;
                IF_state <= nxt_IF_state;
                ICACHE_addr <= nxt_ICACHE_addr;
            end
        end
    end

    // next state logic
    always @(*) begin
        nxt_IF_state = IF_state;
        add2or4 = 1; // default RV32I
        RVC_inst = {ICACHE_rdata[23:16], ICACHE_rdata[31:24]};
        nxt_ICACHE_addr = ICACHE_addr + 1;
        case (IF_state)
            IF_state_IDLE: begin
                if (ICACHE_rdata[25:24] != 2'b11) begin // RVC
                    nxt_IF_state = IF_state_BUF;
                    add2or4 = 0;
                    RVC_inst = {ICACHE_rdata[23:16], ICACHE_rdata[31:24]};
                end
            end
            IF_state_BUF: begin
                if (inst_buffer[1:0] != 2'b11) begin // RVC
                    nxt_IF_state = IF_state_IDLE;
                    add2or4 = 0;
                    RVC_inst = inst_buffer;
                    nxt_ICACHE_addr = ICACHE_addr;
                end
            end
            IF_state_JB: begin
                if (ICACHE_rdata[9:8] != 2'b11) begin // RVC
                    nxt_IF_state = IF_state_IDLE;
                    add2or4 = 0;
                    RVC_inst = {ICACHE_rdata[7:0], ICACHE_rdata[15:8]};
                end
                else begin  // RV32I
                    nxt_IF_state = IF_state_BUF;
                end
            end
        endcase
    end

    // output logic
    always @(*) begin
        inst = {ICACHE_rdata[7:0], ICACHE_rdata[15:8], ICACHE_rdata[23:16], ICACHE_rdata[31:24]};
        nxt_PC = (Jal || Jalr || Branch_met) ? JB_addr : (add2or4 ? PC_add4 : PC_add2);
        case (IF_state)
            IF_state_IDLE: begin
                if (ICACHE_rdata[25:24] != 2'b11) begin // RVC
                    inst = decomp_RVC_inst;
                end
                else begin // RV32I
                    inst = {ICACHE_rdata[7:0], ICACHE_rdata[15:8], ICACHE_rdata[23:16], ICACHE_rdata[31:24]};
                end
            end
            IF_state_BUF: begin
                if (inst_buffer[1:0] != 2'b11) begin // RVC
                    inst = decomp_RVC_inst;
                end
                else begin  // RV32I
                    inst = {ICACHE_rdata[23:16], ICACHE_rdata[31:24], inst_buffer};
                end
            end
            IF_state_JB: begin
                if (ICACHE_rdata[9:8] != 2'b11) begin // RVC
                    inst = decomp_RVC_inst;
                end
                else begin  // RV32I
                    inst = 32'b000000000000_00000_000_00000_0010011;  // nop
                    nxt_PC = PC;
                end
            end
        endcase
    end
// ==== ID ============================================

    assign {func7, rs2, rs1, func3, rd, opcode} = IFID_inst[31:2];
    assign Mul = IFID_inst[25] && (opcode == 5'b01100);
    // assign rs1_data_b = (ForwardA_b == 2'b00) ? rs1_data : EXMEM_result;
    // assign rs2_data_b = (ForwardB_b == 2'b00) ? rs2_data : EXMEM_result;
    assign rs1_data_b = (ForwardA_b == 2'b00) ? rs1_data : (ForwardA_b == 2'b10) ? EXMEM_result : reg_wdata;
    assign rs2_data_b = (ForwardB_b == 2'b00) ? rs2_data : (ForwardB_b == 2'b10) ? EXMEM_result : reg_wdata;
    
    assign equal = (rs1_data_b == rs2_data_b);
    assign Branch_met = Branch && (equal ^ func3[0]);
    assign JB_addr = $signed(imm) + (Jalr ? $signed(rs1_data_b) : $signed(IFID_PC));

    mult_pipe mult(.inst_A(rs1_data_b), .inst_B(rs2_data_b), .stall(cache_stall), .inst_CLK(clk), .rst_n(RST_N), .PRODUCT_inst(mul_output));

    RVC_decomp RVC_decomp(.RVC_inst(RVC_inst), .inst(decomp_RVC_inst));
    control control(.opcode(opcode), .ALUSrc(ALUSrc), .ALUOp(ALUOp), .Branch(Branch), .Jalr(Jalr), .Jal(Jal), .MemWrite(MemWrite), .MemRead(MemRead), .MemtoReg(MemtoReg), .RegWrite(RegWrite));
    register_file register_file(.clk(clk), .rst_n(RST_N), .RegWrite(MEMWB_RegWrite), .rs1(rs1), .rs2(rs2), .rd(MEMWB_rd), .rs1_data(rs1_data), .rs2_data(rs2_data), .write_data(reg_wdata));
    imm_gen imm_gen(.inst(IFID_inst), .imm(imm));

    always @(posedge clk) begin
        if (!RST_N) begin
            IDEX_PC_add2or4 <= 0;
            IDEX_rs1_data <= 0;
            IDEX_rs2_data <= 0;
            IDEX_imm <= 0;
            IDEX_func3 <= 0;
            IDEX_func7_5 <= 0;
            IDEX_rs1 <= 0;
            IDEX_rs2 <= 0;
            IDEX_rd <= 0;
            IDEX_Jal <= 0;
            IDEX_Jalr <= 0;
            IDEX_ALUSrc <= 0;
            IDEX_ALUOp <= 0;
            IDEX_MemRead <= 0;
            IDEX_MemWrite <= 0;
            IDEX_MemtoReg <= 0;
            IDEX_RegWrite <= 0;
            IDEX_Mul <= 0;
        end
        else if (!cache_stall) begin
            if (hazard_stall) begin // insert nop
                IDEX_MemRead <= 0;
                IDEX_MemWrite <= 0;
                IDEX_RegWrite <= 0;
            end
            else begin
                IDEX_MemRead <= MemRead;
                IDEX_MemWrite <= MemWrite;
                IDEX_RegWrite <= RegWrite;
            end
            IDEX_PC_add2or4 <= IFID_PC_add2or4;
            // change here for different forwarding
            IDEX_rs1_data <= rs1_data_b;
            IDEX_rs2_data <= rs2_data_b;
            IDEX_imm <= imm;
            IDEX_func3 <= func3;
            IDEX_func7_5 <= func7[5];
            IDEX_rs1 <= rs1;
            IDEX_rs2 <= rs2;
            IDEX_rd <= rd;
            IDEX_Jal <= Jal;
            IDEX_Jalr <= Jalr;
            IDEX_ALUSrc <= ALUSrc;
            IDEX_ALUOp <= ALUOp;
            // IDEX_MemRead <= MemRead;
            // IDEX_MemWrite <= MemWrite;
            IDEX_MemtoReg <= MemtoReg;
            // IDEX_RegWrite <= RegWrite;
            IDEX_Mul <= Mul;
        end

    end

    hazard_dectv3 hazard_dectv3 (.rs1(rs1), .rs2(rs2), .Branch(Branch), .Jal(Jal), .Jalr(Jalr), .Mul(Mul), .IDEX_rd(IDEX_rd), .IDEX_MemRead(IDEX_MemRead), .IDEX_RegWrite(IDEX_RegWrite), .IDEX_Mul(IDEX_Mul), .EXMEM_rd(EXMEM_rd), .EXMEM_MemRead(EXMEM_MemRead), .EXMEM_Mul(EXMEM_Mul), .hazard_stall(hazard_stall));
    forwarding_unit_b forwarding_unit_b(.rs1(rs1), .rs2(rs2), .EXMEM_rd(EXMEM_rd), .MEMWB_rd(MEMWB_rd), .EXMEM_RegWrite(EXMEM_RegWrite), .MEMWB_RegWrite(MEMWB_RegWrite), .ForwardA_b(ForwardA_b), .ForwardB_b(ForwardB_b));
// ==== EX ============================================

    assign alu_a = (ForwardA == 2'b00) ? IDEX_rs1_data : (ForwardA == 2'b10) ? EXMEM_result : reg_wdata;
    assign alu_b = IDEX_ALUSrc ? IDEX_imm : (ForwardB == 2'b00) ? IDEX_rs2_data : (ForwardB == 2'b10) ? EXMEM_result : reg_wdata;

    always @(posedge clk) begin
        if (!RST_N) begin
            EXMEM_MemRead <= 0;
            EXMEM_MemWrite <= 0;
            EXMEM_MemtoReg <= 0;
            EXMEM_RegWrite <= 0;
            EXMEM_result <= 0;
            EXMEM_rs2_data <= 0;
            EXMEM_rd <= 0;
            EXMEM_Mul <= 0;
        end
        else if (!cache_stall) begin
            EXMEM_MemRead <= IDEX_MemRead;
            EXMEM_MemWrite <= IDEX_MemWrite;
            EXMEM_MemtoReg <= IDEX_MemtoReg;
            EXMEM_RegWrite <= IDEX_RegWrite;
            EXMEM_result <= (IDEX_Jal || IDEX_Jalr) ? IDEX_PC_add2or4 : alu_result;
            EXMEM_rs2_data <= (ForwardB == 2'b00) ? IDEX_rs2_data : (ForwardB == 2'b10) ? EXMEM_result : reg_wdata;
            EXMEM_rd <= IDEX_rd;
            EXMEM_Mul <= IDEX_Mul;
        end
    end

    alu alu(.a(alu_a), .b(alu_b), .alu_ctrl(alu_ctrl), .result(alu_result), .zero());
    alu_control alu_control(.ALUOp(IDEX_ALUOp), .func7_5(IDEX_func7_5), .func3(IDEX_func3), .alu_ctrl(alu_ctrl));
    forwarding_unit forwarding_unit(.IDEX_rs1(IDEX_rs1), .IDEX_rs2(IDEX_rs2), .EXMEM_rd(EXMEM_rd), .MEMWB_rd(MEMWB_rd), .EXMEM_RegWrite(EXMEM_RegWrite), .MEMWB_RegWrite(MEMWB_RegWrite), .ForwardA(ForwardA), .ForwardB(ForwardB));
// ==== MEM ===========================================

    always @(posedge clk) begin
        if (!RST_N) begin
            MEMWB_dmem_rdata <= 0;
            MEMWB_result <= 0;
            MEMWB_MemtoReg <= 0;
            MEMWB_RegWrite <= 0;
            MEMWB_rd <= 0;
            MEMWB_Mul <= 0;
        end
        else if (!cache_stall) begin
            MEMWB_dmem_rdata <= {DCACHE_rdata[7:0], DCACHE_rdata[15:8], DCACHE_rdata[23:16], DCACHE_rdata[31:24]};
            // MEMWB_dmem_rdata <= DCACHE_rdata;
            MEMWB_result <= EXMEM_result;
            MEMWB_MemtoReg <= EXMEM_MemtoReg;
            MEMWB_RegWrite <= EXMEM_RegWrite;
            MEMWB_rd <= EXMEM_rd;
            MEMWB_Mul <= EXMEM_Mul;
        end
    end

// ==== WB ============================================

    assign reg_wdata = MEMWB_Mul ? mul_output : (MEMWB_MemtoReg ? MEMWB_dmem_rdata : MEMWB_result);

endmodule

