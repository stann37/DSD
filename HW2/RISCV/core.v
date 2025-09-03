// Your SingleCycle RISC-V code

module core(clk,
            rst_n,
            // for mem_D
            mem_wen_D,
            mem_addr_D,
            mem_wdata_D,
            mem_rdata_D,
            // for mem_I
            mem_addr_I,
            mem_rdata_I
    );

    input         clk, rst_n ;
    // for mem_D
    output        mem_wen_D  ;  // mem_wen_D is high, core writes data to D-mem; else, core reads data from D-mem
    output [31:0] mem_addr_D ;  // the specific address to fetch/store data 
    output [31:0] mem_wdata_D;  // data writing to D-mem 
    input  [31:0] mem_rdata_D;  // data reading from D-mem
    // for mem_I
    output [31:0] mem_addr_I ;  // the fetching address of next instruction
    input  [31:0] mem_rdata_I;  // instruction reading from I-mem
    
    wire [31:0] mem_rdata_Ib;
    wire [31:0] mem_rdata_Db;

    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [2:0] func3;
    wire [6:0] func7;

    wire Jalr;
    wire Jal;
    wire Branch;
    wire MemtoReg;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;

    wire [31:0] write_data_reg;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    reg [31:0] imm;
    wire [31:0] imm_J;
    wire [31:0] imm_B;
    wire [31:0] imm_I;
    wire [31:0] imm_S;

    wire [31:0] ALU_b;
    wire zero;
    reg [31:0] ALU_result;
    reg [3:0] alu_ctrl;

    reg [31:0] PC;
    wire [31:0] PC_add4;
    reg [31:0] next_PC;

    reg [31:0] mem [0:31];
    integer i;

    assign mem_rdata_Ib = {mem_rdata_I[7:0], mem_rdata_I[15:8], mem_rdata_I[23:16], mem_rdata_I[31:24]};
    assign mem_wdata_D = {rs2_data[7:0], rs2_data[15:8], rs2_data[23:16], rs2_data[31:24]};
    assign mem_rdata_Db = {mem_rdata_D[7:0], mem_rdata_D[15:8], mem_rdata_D[23:16], mem_rdata_D[31:24]};
    assign mem_wen_D = MemWrite;
    assign mem_addr_D = ALU_result;

    assign {func7, rs2, rs1, func3, rd, opcode} = mem_rdata_Ib;

    assign imm_J = {{12{mem_rdata_Ib[31]}}, mem_rdata_Ib[19:12], mem_rdata_Ib[20], mem_rdata_Ib[30:25], mem_rdata_Ib[24:21], 1'b0};  // JAL
    assign imm_I = {{21{mem_rdata_Ib[31]}}, mem_rdata_Ib[30:25], mem_rdata_Ib[24:21], mem_rdata_Ib[20]};   // JALR, LW
    assign imm_B = {{20{mem_rdata_Ib[31]}}, mem_rdata_Ib[7], mem_rdata_Ib[30:25], mem_rdata_Ib[11:8], 1'b0}; // BEQ
    assign imm_S = {{21{mem_rdata_Ib[31]}}, mem_rdata_Ib[30:25], mem_rdata_Ib[11:8], mem_rdata_Ib[7]};   //SW

    always @(*) begin
        case (opcode[6:2]) // synopsys parallel_case full_case
            5'b11011: imm = imm_J;  // JAL
            5'b11001: imm = imm_I;   // JALR
            5'b11000: imm = imm_B; // BEQ
            5'b00000: imm = imm_I; // LW
            5'b01000: imm = imm_S;   //SW
        endcase
    end

    assign Jalr = opcode[2] && (~opcode[3]);
    assign Jal = opcode[3];
    assign Branch = (~opcode[2]) && opcode[6];
    assign MemtoReg = ~opcode[5];
    assign MemWrite = (~opcode[4]) && (opcode[5]) && (~opcode[6]);
    assign ALUSrc = opcode[2] || ((~opcode[4]) && (~opcode[6]));
    assign RegWrite = opcode[2] || opcode[4] || (~opcode[5]);

    always @(*) begin
        case (opcode[6:2])
            5'b11000: alu_ctrl = 4'b0110;   // SUB (BEQ)
            5'b01100: begin // R-type
                case (func3) // synopsys parallel_case full_case
                    3'b000: alu_ctrl = func7[5] ? 4'b0110 : 4'b0010;   // SUB : ADD
                    3'b111: alu_ctrl = 4'b0000; // AND
                    3'b110: alu_ctrl = 4'b0001; // OR
                    3'b010: alu_ctrl = 4'b1000; // SLT
                endcase
            end
            default: alu_ctrl = 4'b0010; // SW, LW, JALR, JAL (ADD)
        endcase
    end

    assign rs1_data = (rs1 == 5'b0) ? 32'b0 : mem[rs1];
    assign rs2_data = (rs2 == 5'b0) ? 32'b0 : mem[rs2];
    
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                mem[i] <= 32'b0;
        end
        else if (RegWrite && (rd != 5'b0))
            mem[rd] <= write_data_reg;
    end

    always @(*) begin
        case (alu_ctrl) // synopsys parallel_case full_case
            4'b0000: ALU_result = rs1_data & ALU_b;
            4'b0001: ALU_result = rs1_data | ALU_b;
            4'b0010: ALU_result = $signed(rs1_data) + $signed(ALU_b);
            4'b0110: ALU_result = $signed(rs1_data) - $signed(ALU_b);
            4'b1000: ALU_result = ($signed(rs1_data) < $signed(ALU_b)) ? 32'b1 : 32'b0;
        endcase
    end
    assign zero = (ALU_result == 32'b0);

    assign ALU_b = ALUSrc ? imm : rs2_data;
    assign write_data_reg = (Jalr || Jal) ? PC_add4 :
                            MemtoReg ? mem_rdata_Db : ALU_result;
    
    always @(posedge clk) begin
    if (!rst_n)
        PC <= 32'b0;
    else
        PC <= next_PC;
    end

    assign mem_addr_I = PC;
    assign PC_add4 = PC + 4;
    
    always @(*) begin
        if (Jalr)
            next_PC = ALU_result;
        else if ((Branch && zero) || Jal)
            next_PC = $signed(PC) + $signed(imm);
        else
            next_PC = PC_add4;
    end

endmodule