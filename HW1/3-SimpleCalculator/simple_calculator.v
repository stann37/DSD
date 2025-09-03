`include "../1-ALU/1_assign/alu_assign.v"
`include "../2-RegisterFile/register_file.v"

module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

    // declaration of wire/reg
    wire [7:0] busX, MUX_out, ALU_out;

    // submodule instantiation
    register_file rf(
        .Clk(Clk),
        .WEN(WEN),
        .RW(RW),
        .RX(RX),
        .RY(RY),
        .busW(ALU_out),
        .busX(busX),
        .busY(busY)
    );

    alu_assign alu(
        .ctrl(Ctrl),
        .x(MUX_out),
        .y(busY),
        .carry(Carry),
        .out(ALU_out)
    );

    assign MUX_out = (Sel == 1'b0) ? DataIn : busX;

endmodule
