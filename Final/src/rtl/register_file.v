module register_file(
    input           clk,
    input           rst_n,
    input           RegWrite, // write enable if high
    input   [4:0]   rs1,
    input   [4:0]   rs2,
    input   [4:0]   rd,
    output  [31:0]  rs1_data,
    output  [31:0]  rs2_data,
    input   [31:0]  write_data
);
    reg     [31:0]  mem [0:31];
    integer i;

    // write befor read!!
    //assign rs1_data = (RegWrite && (rd != 0) && rd == rs1) ? write_data : (rs1 == 5'b0) ? 32'b0 : mem[rs1];
    //assign rs2_data = (RegWrite && (rd != 0) && rd == rs2) ? write_data : (rs2 == 5'b0) ? 32'b0 : mem[rs2];
    assign rs1_data = (rs1 == 5'b0) ? 32'b0 : mem[rs1];
    assign rs2_data = (rs2 == 5'b0) ? 32'b0 : mem[rs2];

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                mem[i] <= 0;
        end
        else if (RegWrite && (rd != 0)) mem[rd] <= write_data;
        
    end
endmodule