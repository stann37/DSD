module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
input        Clk, WEN;
input  [2:0] RW, RX, RY;
input  [7:0] busW;
output reg [7:0] busX, busY;
    
//  8-bit    8 words
reg [7:0] mem [7:0];

always @(*) begin
    busX = mem[RX];
    busY = mem[RY];
end

always @(posedge Clk) begin
    if (WEN && RW != 3'b0) begin
        mem[RW] <= busW;
    end
    
    mem[0] <= 8'b0;
end

endmodule
