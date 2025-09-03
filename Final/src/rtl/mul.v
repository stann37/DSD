module mult_pipe(
    inst_A,
    inst_B,
    stall,
    inst_CLK,
    rst_n,
    PRODUCT_inst
);
    input signed [31:0] inst_A;
    input signed [31:0] inst_B;     // multiplicand
    input stall;
    input inst_CLK;
    input rst_n;
    output [31:0] PRODUCT_inst;

    reg [31:0] pp_0;  
    reg [29:0] pp_2;  
    reg [27:0] pp_4;  
    reg [25:0] pp_6;
    reg [23:0] pp_8;
    reg [21:0] pp_10;
    reg [19:0] pp_12;
    reg [17:0] pp_14;  
    reg [15:0] pp_16; 
    reg [13:0] pp_18;
    reg [11:0] pp_20;
    reg [9 :0] pp_22; 
    reg [7 :0] pp_24; 
    reg [5 :0] pp_26; 
    reg [3 :0] pp_28;
    reg [1 :0] pp_30; 

    wire [1:0] booth_0  = inst_B[1:0];
    wire [2:0] booth_2  = inst_B[3:1];
    wire [2:0] booth_4  = inst_B[5:3];
    wire [2:0] booth_6  = inst_B[7:5];
    wire [2:0] booth_8  = inst_B[9:7];  
    wire [2:0] booth_10 = inst_B[11:9];
    wire [2:0] booth_12 = inst_B[13:11];
    wire [2:0] booth_14 = inst_B[15:13];
    wire [2:0] booth_16 = inst_B[17:15];
    wire [2:0] booth_18 = inst_B[19:17];
    wire [2:0] booth_20 = inst_B[21:19];
    wire [2:0] booth_22 = inst_B[23:21];
    wire [2:0] booth_24 = inst_B[25:23];
    wire [2:0] booth_26 = inst_B[27:25];
    wire [2:0] booth_28 = inst_B[29:27];
    wire [2:0] booth_30 = inst_B[31:29];

    reg [7:0]  second_stage_result;
    reg [23:0] second_stage_carry;
    reg [23:0] second_stage_sum;

    reg [31:0] third_stage_result;
    wire [23:0] csa_result;

    assign PRODUCT_inst = third_stage_result;

    // =========== stage 1 ==========
    // ***** group 1 *****
    wire    s1_g1_b2_s,  s1_g1_b2_c,  s1_g1_b3_s,  s1_g1_b3_c,  s1_g1_b4_s,  s1_g1_b4_c,  s1_g1_b5_s,  s1_g1_b5_c,  s1_g1_b6_s,  s1_g1_b6_c,
            s1_g1_b7_s,  s1_g1_b7_c,  s1_g1_b8_s,  s1_g1_b8_c,  s1_g1_b9_s,  s1_g1_b9_c,  s1_g1_b10_s, s1_g1_b10_c, s1_g1_b11_s, s1_g1_b11_c,
            s1_g1_b12_s, s1_g1_b12_c, s1_g1_b13_s, s1_g1_b13_c, s1_g1_b14_s, s1_g1_b14_c, s1_g1_b15_s, s1_g1_b15_c, s1_g1_b16_s, s1_g1_b16_c,
            s1_g1_b17_s, s1_g1_b17_c, s1_g1_b18_s, s1_g1_b18_c, s1_g1_b19_s, s1_g1_b19_c, s1_g1_b20_s, s1_g1_b20_c, s1_g1_b21_s, s1_g1_b21_c,
            s1_g1_b22_s, s1_g1_b22_c, s1_g1_b23_s, s1_g1_b23_c, s1_g1_b24_s, s1_g1_b24_c, s1_g1_b25_s, s1_g1_b25_c, s1_g1_b26_s, s1_g1_b26_c,
            s1_g1_b27_s, s1_g1_b27_c, s1_g1_b28_s, s1_g1_b28_c, s1_g1_b29_s, s1_g1_b29_c, s1_g1_b30_s, s1_g1_b30_c, s1_g1_b31_s, s1_g1_b31_c;
    half_adder s1_g1_b2  (pp_0[2],   pp_2[0],              s1_g1_b2_s,  s1_g1_b2_c);
    half_adder s1_g1_b3  (pp_0[3],   pp_2[1],              s1_g1_b3_s,  s1_g1_b3_c);
    full_adder s1_g1_b4  (pp_0[4],   pp_2[2],   pp_4[0],   s1_g1_b4_s,  s1_g1_b4_c);
    full_adder s1_g1_b5  (pp_0[5],   pp_2[3],   pp_4[1],   s1_g1_b5_s,  s1_g1_b5_c);
    full_adder s1_g1_b6  (pp_0[6],   pp_2[4],   pp_4[2],   s1_g1_b6_s,  s1_g1_b6_c);
    full_adder s1_g1_b7  (pp_0[7],   pp_2[5],   pp_4[3],   s1_g1_b7_s,  s1_g1_b7_c);
    full_adder s1_g1_b8  (pp_0[8],   pp_2[6],   pp_4[4],   s1_g1_b8_s,  s1_g1_b8_c);
    full_adder s1_g1_b9  (pp_0[9],   pp_2[7],   pp_4[5],   s1_g1_b9_s,  s1_g1_b9_c);
    full_adder s1_g1_b10 (pp_0[10],  pp_2[8],   pp_4[6],   s1_g1_b10_s, s1_g1_b10_c);
    full_adder s1_g1_b11 (pp_0[11],  pp_2[9],   pp_4[7],   s1_g1_b11_s, s1_g1_b11_c);
    full_adder s1_g1_b12 (pp_0[12],  pp_2[10],  pp_4[8],   s1_g1_b12_s, s1_g1_b12_c);
    full_adder s1_g1_b13 (pp_0[13],  pp_2[11],  pp_4[9],   s1_g1_b13_s, s1_g1_b13_c);
    full_adder s1_g1_b14 (pp_0[14],  pp_2[12],  pp_4[10],  s1_g1_b14_s, s1_g1_b14_c);
    full_adder s1_g1_b15 (pp_0[15],  pp_2[13],  pp_4[11],  s1_g1_b15_s, s1_g1_b15_c);
    full_adder s1_g1_b16 (pp_0[16],  pp_2[14],  pp_4[12],  s1_g1_b16_s, s1_g1_b16_c);
    full_adder s1_g1_b17 (pp_0[17],  pp_2[15],  pp_4[13],  s1_g1_b17_s, s1_g1_b17_c);
    full_adder s1_g1_b18 (pp_0[18],  pp_2[16],  pp_4[14],  s1_g1_b18_s, s1_g1_b18_c);
    full_adder s1_g1_b19 (pp_0[19],  pp_2[17],  pp_4[15],  s1_g1_b19_s, s1_g1_b19_c);
    full_adder s1_g1_b20 (pp_0[20],  pp_2[18],  pp_4[16],  s1_g1_b20_s, s1_g1_b20_c);
    full_adder s1_g1_b21 (pp_0[21],  pp_2[19],  pp_4[17],  s1_g1_b21_s, s1_g1_b21_c);
    full_adder s1_g1_b22 (pp_0[22],  pp_2[20],  pp_4[18],  s1_g1_b22_s, s1_g1_b22_c);
    full_adder s1_g1_b23 (pp_0[23],  pp_2[21],  pp_4[19],  s1_g1_b23_s, s1_g1_b23_c);
    full_adder s1_g1_b24 (pp_0[24],  pp_2[22],  pp_4[20],  s1_g1_b24_s, s1_g1_b24_c);
    full_adder s1_g1_b25 (pp_0[25],  pp_2[23],  pp_4[21],  s1_g1_b25_s, s1_g1_b25_c);
    full_adder s1_g1_b26 (pp_0[26],  pp_2[24],  pp_4[22],  s1_g1_b26_s, s1_g1_b26_c);
    full_adder s1_g1_b27 (pp_0[27],  pp_2[25],  pp_4[23],  s1_g1_b27_s, s1_g1_b27_c);
    full_adder s1_g1_b28 (pp_0[28],  pp_2[26],  pp_4[24],  s1_g1_b28_s, s1_g1_b28_c);
    full_adder s1_g1_b29 (pp_0[29],  pp_2[27],  pp_4[25],  s1_g1_b29_s, s1_g1_b29_c);
    full_adder s1_g1_b30 (pp_0[30],  pp_2[28],  pp_4[26],  s1_g1_b30_s, s1_g1_b30_c);
    full_adder s1_g1_b31 (pp_0[31],  pp_2[29],  pp_4[27],  s1_g1_b31_s, s1_g1_b31_c);
    // ***** group 2 *****
    wire    s1_g2_b8_s,  s1_g2_b8_c,  s1_g2_b9_s,  s1_g2_b9_c,  s1_g2_b10_s, s1_g2_b10_c, s1_g2_b11_s, s1_g2_b11_c,
            s1_g2_b12_s, s1_g2_b12_c, s1_g2_b13_s, s1_g2_b13_c, s1_g2_b14_s, s1_g2_b14_c, s1_g2_b15_s, s1_g2_b15_c, s1_g2_b16_s, s1_g2_b16_c,
            s1_g2_b17_s, s1_g2_b17_c, s1_g2_b18_s, s1_g2_b18_c, s1_g2_b19_s, s1_g2_b19_c, s1_g2_b20_s, s1_g2_b20_c, s1_g2_b21_s, s1_g2_b21_c,
            s1_g2_b22_s, s1_g2_b22_c, s1_g2_b23_s, s1_g2_b23_c, s1_g2_b24_s, s1_g2_b24_c, s1_g2_b25_s, s1_g2_b25_c, s1_g2_b26_s, s1_g2_b26_c,
            s1_g2_b27_s, s1_g2_b27_c, s1_g2_b28_s, s1_g2_b28_c, s1_g2_b29_s, s1_g2_b29_c, s1_g2_b30_s, s1_g2_b30_c, s1_g2_b31_s, s1_g2_b31_c;
    half_adder s1_g2_b8  (pp_6[2],   pp_8[0],               s1_g2_b8_s,  s1_g2_b8_c);
    half_adder s1_g2_b9  (pp_6[3],   pp_8[1],               s1_g2_b9_s,  s1_g2_b9_c);
    full_adder s1_g2_b10 (pp_6[4],   pp_8[2],   pp_10[0],   s1_g2_b10_s, s1_g2_b10_c);
    full_adder s1_g2_b11 (pp_6[5],   pp_8[3],   pp_10[1],   s1_g2_b11_s, s1_g2_b11_c);
    full_adder s1_g2_b12 (pp_6[6],   pp_8[4],   pp_10[2],   s1_g2_b12_s, s1_g2_b12_c);
    full_adder s1_g2_b13 (pp_6[7],   pp_8[5],   pp_10[3],   s1_g2_b13_s, s1_g2_b13_c);
    full_adder s1_g2_b14 (pp_6[8],   pp_8[6],   pp_10[4],   s1_g2_b14_s, s1_g2_b14_c);
    full_adder s1_g2_b15 (pp_6[9],   pp_8[7],   pp_10[5],   s1_g2_b15_s, s1_g2_b15_c);
    full_adder s1_g2_b16 (pp_6[10],  pp_8[8],   pp_10[6],   s1_g2_b16_s, s1_g2_b16_c);
    full_adder s1_g2_b17 (pp_6[11],  pp_8[9],   pp_10[7],   s1_g2_b17_s, s1_g2_b17_c);
    full_adder s1_g2_b18 (pp_6[12],  pp_8[10],  pp_10[8],   s1_g2_b18_s, s1_g2_b18_c);
    full_adder s1_g2_b19 (pp_6[13],  pp_8[11],  pp_10[9],   s1_g2_b19_s, s1_g2_b19_c);
    full_adder s1_g2_b20 (pp_6[14],  pp_8[12],  pp_10[10],  s1_g2_b20_s, s1_g2_b20_c);
    full_adder s1_g2_b21 (pp_6[15],  pp_8[13],  pp_10[11],  s1_g2_b21_s, s1_g2_b21_c);
    full_adder s1_g2_b22 (pp_6[16],  pp_8[14],  pp_10[12],  s1_g2_b22_s, s1_g2_b22_c);
    full_adder s1_g2_b23 (pp_6[17],  pp_8[15],  pp_10[13],  s1_g2_b23_s, s1_g2_b23_c);
    full_adder s1_g2_b24 (pp_6[18],  pp_8[16],  pp_10[14],  s1_g2_b24_s, s1_g2_b24_c);
    full_adder s1_g2_b25 (pp_6[19],  pp_8[17],  pp_10[15],  s1_g2_b25_s, s1_g2_b25_c);
    full_adder s1_g2_b26 (pp_6[20],  pp_8[18],  pp_10[16],  s1_g2_b26_s, s1_g2_b26_c);
    full_adder s1_g2_b27 (pp_6[21],  pp_8[19],  pp_10[17],  s1_g2_b27_s, s1_g2_b27_c);
    full_adder s1_g2_b28 (pp_6[22],  pp_8[20],  pp_10[18],  s1_g2_b28_s, s1_g2_b28_c);
    full_adder s1_g2_b29 (pp_6[23],  pp_8[21],  pp_10[19],  s1_g2_b29_s, s1_g2_b29_c);
    full_adder s1_g2_b30 (pp_6[24],  pp_8[22],  pp_10[20],  s1_g2_b30_s, s1_g2_b30_c);
    full_adder s1_g2_b31 (pp_6[25],  pp_8[23],  pp_10[21],  s1_g2_b31_s, s1_g2_b31_c);
    // ***** group 3 *****
    wire    s1_g3_b14_s, s1_g3_b14_c, s1_g3_b15_s, s1_g3_b15_c, s1_g3_b16_s, s1_g3_b16_c,
            s1_g3_b17_s, s1_g3_b17_c, s1_g3_b18_s, s1_g3_b18_c, s1_g3_b19_s, s1_g3_b19_c, s1_g3_b20_s, s1_g3_b20_c, s1_g3_b21_s, s1_g3_b21_c,
            s1_g3_b22_s, s1_g3_b22_c, s1_g3_b23_s, s1_g3_b23_c, s1_g3_b24_s, s1_g3_b24_c, s1_g3_b25_s, s1_g3_b25_c, s1_g3_b26_s, s1_g3_b26_c,
            s1_g3_b27_s, s1_g3_b27_c, s1_g3_b28_s, s1_g3_b28_c, s1_g3_b29_s, s1_g3_b29_c, s1_g3_b30_s, s1_g3_b30_c, s1_g3_b31_s, s1_g3_b31_c;
    half_adder s1_g3_b14 (pp_12[2],  pp_14[0],              s1_g3_b14_s, s1_g3_b14_c);
    half_adder s1_g3_b15 (pp_12[3],  pp_14[1],              s1_g3_b15_s, s1_g3_b15_c);
    full_adder s1_g3_b16 (pp_12[4],  pp_14[2],  pp_16[0],   s1_g3_b16_s, s1_g3_b16_c);
    full_adder s1_g3_b17 (pp_12[5],  pp_14[3],  pp_16[1],   s1_g3_b17_s, s1_g3_b17_c);
    full_adder s1_g3_b18 (pp_12[6],  pp_14[4],  pp_16[2],   s1_g3_b18_s, s1_g3_b18_c);
    full_adder s1_g3_b19 (pp_12[7],  pp_14[5],  pp_16[3],   s1_g3_b19_s, s1_g3_b19_c);
    full_adder s1_g3_b20 (pp_12[8],  pp_14[6],  pp_16[4],   s1_g3_b20_s, s1_g3_b20_c);
    full_adder s1_g3_b21 (pp_12[9],  pp_14[7],  pp_16[5],   s1_g3_b21_s, s1_g3_b21_c);
    full_adder s1_g3_b22 (pp_12[10], pp_14[8],  pp_16[6],   s1_g3_b22_s, s1_g3_b22_c);
    full_adder s1_g3_b23 (pp_12[11], pp_14[9],  pp_16[7],   s1_g3_b23_s, s1_g3_b23_c);
    full_adder s1_g3_b24 (pp_12[12], pp_14[10], pp_16[8],   s1_g3_b24_s, s1_g3_b24_c);
    full_adder s1_g3_b25 (pp_12[13], pp_14[11], pp_16[9],   s1_g3_b25_s, s1_g3_b25_c);
    full_adder s1_g3_b26 (pp_12[14], pp_14[12], pp_16[10],  s1_g3_b26_s, s1_g3_b26_c);
    full_adder s1_g3_b27 (pp_12[15], pp_14[13], pp_16[11],  s1_g3_b27_s, s1_g3_b27_c);
    full_adder s1_g3_b28 (pp_12[16], pp_14[14], pp_16[12],  s1_g3_b28_s, s1_g3_b28_c);
    full_adder s1_g3_b29 (pp_12[17], pp_14[15], pp_16[13],  s1_g3_b29_s, s1_g3_b29_c);
    full_adder s1_g3_b30 (pp_12[18], pp_14[16], pp_16[14],  s1_g3_b30_s, s1_g3_b30_c);
    full_adder s1_g3_b31 (pp_12[19], pp_14[17], pp_16[15],  s1_g3_b31_s, s1_g3_b31_c);
    // ***** group 4 *****
    wire    s1_g4_b20_s, s1_g4_b20_c, s1_g4_b21_s, s1_g4_b21_c,
            s1_g4_b22_s, s1_g4_b22_c, s1_g4_b23_s, s1_g4_b23_c, s1_g4_b24_s, s1_g4_b24_c, s1_g4_b25_s, s1_g4_b25_c, s1_g4_b26_s, s1_g4_b26_c,
            s1_g4_b27_s, s1_g4_b27_c, s1_g4_b28_s, s1_g4_b28_c, s1_g4_b29_s, s1_g4_b29_c, s1_g4_b30_s, s1_g4_b30_c, s1_g4_b31_s, s1_g4_b31_c;
    half_adder s1_g4_b20 (pp_18[2],  pp_20[0],              s1_g4_b20_s, s1_g4_b20_c);
    half_adder s1_g4_b21 (pp_18[3],  pp_20[1],              s1_g4_b21_s, s1_g4_b21_c);
    full_adder s1_g4_b22 (pp_18[4],  pp_20[2],  pp_22[0],   s1_g4_b22_s, s1_g4_b22_c);
    full_adder s1_g4_b23 (pp_18[5],  pp_20[3],  pp_22[1],   s1_g4_b23_s, s1_g4_b23_c);
    full_adder s1_g4_b24 (pp_18[6],  pp_20[4],  pp_22[2],   s1_g4_b24_s, s1_g4_b24_c);
    full_adder s1_g4_b25 (pp_18[7],  pp_20[5],  pp_22[3],   s1_g4_b25_s, s1_g4_b25_c);
    full_adder s1_g4_b26 (pp_18[8],  pp_20[6],  pp_22[4],   s1_g4_b26_s, s1_g4_b26_c);
    full_adder s1_g4_b27 (pp_18[9],  pp_20[7],  pp_22[5],   s1_g4_b27_s, s1_g4_b27_c);
    full_adder s1_g4_b28 (pp_18[10], pp_20[8],  pp_22[6],   s1_g4_b28_s, s1_g4_b28_c);
    full_adder s1_g4_b29 (pp_18[11], pp_20[9],  pp_22[7],   s1_g4_b29_s, s1_g4_b29_c);
    full_adder s1_g4_b30 (pp_18[12], pp_20[10], pp_22[8],   s1_g4_b30_s, s1_g4_b30_c);
    full_adder s1_g4_b31 (pp_18[13], pp_20[11], pp_22[9],   s1_g4_b31_s, s1_g4_b31_c);
    // ***** group 5 *****
    wire    s1_g5_b26_s, s1_g5_b26_c,
            s1_g5_b27_s, s1_g5_b27_c, s1_g5_b28_s, s1_g5_b28_c, s1_g5_b29_s, s1_g5_b29_c, s1_g5_b30_s, s1_g5_b30_c, s1_g5_b31_s, s1_g5_b31_c;
    half_adder s1_g5_b26 (pp_24[2],  pp_26[0],              s1_g5_b26_s, s1_g5_b26_c);
    half_adder s1_g5_b27 (pp_24[3],  pp_26[1],              s1_g5_b27_s, s1_g5_b27_c);
    full_adder s1_g5_b28 (pp_24[4],  pp_26[2],  pp_28[0],   s1_g5_b28_s, s1_g5_b28_c);
    full_adder s1_g5_b29 (pp_24[5],  pp_26[3],  pp_28[1],   s1_g5_b29_s, s1_g5_b29_c);
    full_adder s1_g5_b30 (pp_24[6],  pp_26[4],  pp_28[2],   s1_g5_b30_s, s1_g5_b30_c);
    full_adder s1_g5_b31 (pp_24[7],  pp_26[5],  pp_28[3],   s1_g5_b31_s, s1_g5_b31_c);
    // =========== stage 2 ==========
    // ***** group 1 *****
    wire    s2_g1_b3_s,  s2_g1_b3_c,  s2_g1_b4_s,  s2_g1_b4_c,  s2_g1_b5_s,  s2_g1_b5_c,  s2_g1_b6_s,  s2_g1_b6_c,
            s2_g1_b7_s,  s2_g1_b7_c,  s2_g1_b8_s,  s2_g1_b8_c,  s2_g1_b9_s,  s2_g1_b9_c,  s2_g1_b10_s, s2_g1_b10_c, s2_g1_b11_s, s2_g1_b11_c,
            s2_g1_b12_s, s2_g1_b12_c, s2_g1_b13_s, s2_g1_b13_c, s2_g1_b14_s, s2_g1_b14_c, s2_g1_b15_s, s2_g1_b15_c, s2_g1_b16_s, s2_g1_b16_c,
            s2_g1_b17_s, s2_g1_b17_c, s2_g1_b18_s, s2_g1_b18_c, s2_g1_b19_s, s2_g1_b19_c, s2_g1_b20_s, s2_g1_b20_c, s2_g1_b21_s, s2_g1_b21_c,
            s2_g1_b22_s, s2_g1_b22_c, s2_g1_b23_s, s2_g1_b23_c, s2_g1_b24_s, s2_g1_b24_c, s2_g1_b25_s, s2_g1_b25_c, s2_g1_b26_s, s2_g1_b26_c,
            s2_g1_b27_s, s2_g1_b27_c, s2_g1_b28_s, s2_g1_b28_c, s2_g1_b29_s, s2_g1_b29_c, s2_g1_b30_s, s2_g1_b30_c, s2_g1_b31_s, s2_g1_b31_c;
    half_adder s2_g1_b3  (s1_g1_b3_s,  s1_g1_b2_c,               s2_g1_b3_s,  s2_g1_b3_c);
    half_adder s2_g1_b4  (s1_g1_b4_s,  s1_g1_b3_c,               s2_g1_b4_s,  s2_g1_b4_c);
    half_adder s2_g1_b5  (s1_g1_b5_s,  s1_g1_b4_c,               s2_g1_b5_s,  s2_g1_b5_c);
    full_adder s2_g1_b6  (s1_g1_b6_s,  s1_g1_b5_c,  pp_6[0],     s2_g1_b6_s,  s2_g1_b6_c);
    full_adder s2_g1_b7  (s1_g1_b7_s,  s1_g1_b6_c,  pp_6[1],     s2_g1_b7_s,  s2_g1_b7_c);
    full_adder s2_g1_b8  (s1_g1_b8_s,  s1_g1_b7_c,  s1_g2_b8_s,  s2_g1_b8_s,  s2_g1_b8_c);
    full_adder s2_g1_b9  (s1_g1_b9_s,  s1_g1_b8_c,  s1_g2_b9_s,  s2_g1_b9_s,  s2_g1_b9_c);
    full_adder s2_g1_b10 (s1_g1_b10_s, s1_g1_b9_c,  s1_g2_b10_s, s2_g1_b10_s, s2_g1_b10_c);
    full_adder s2_g1_b11 (s1_g1_b11_s, s1_g1_b10_c, s1_g2_b11_s, s2_g1_b11_s, s2_g1_b11_c);
    full_adder s2_g1_b12 (s1_g1_b12_s, s1_g1_b11_c, s1_g2_b12_s, s2_g1_b12_s, s2_g1_b12_c);
    full_adder s2_g1_b13 (s1_g1_b13_s, s1_g1_b12_c, s1_g2_b13_s, s2_g1_b13_s, s2_g1_b13_c);
    full_adder s2_g1_b14 (s1_g1_b14_s, s1_g1_b13_c, s1_g2_b14_s, s2_g1_b14_s, s2_g1_b14_c);
    full_adder s2_g1_b15 (s1_g1_b15_s, s1_g1_b14_c, s1_g2_b15_s, s2_g1_b15_s, s2_g1_b15_c);
    full_adder s2_g1_b16 (s1_g1_b16_s, s1_g1_b15_c, s1_g2_b16_s, s2_g1_b16_s, s2_g1_b16_c);
    full_adder s2_g1_b17 (s1_g1_b17_s, s1_g1_b16_c, s1_g2_b17_s, s2_g1_b17_s, s2_g1_b17_c);
    full_adder s2_g1_b18 (s1_g1_b18_s, s1_g1_b17_c, s1_g2_b18_s, s2_g1_b18_s, s2_g1_b18_c);
    full_adder s2_g1_b19 (s1_g1_b19_s, s1_g1_b18_c, s1_g2_b19_s, s2_g1_b19_s, s2_g1_b19_c);
    full_adder s2_g1_b20 (s1_g1_b20_s, s1_g1_b19_c, s1_g2_b20_s, s2_g1_b20_s, s2_g1_b20_c);
    full_adder s2_g1_b21 (s1_g1_b21_s, s1_g1_b20_c, s1_g2_b21_s, s2_g1_b21_s, s2_g1_b21_c);
    full_adder s2_g1_b22 (s1_g1_b22_s, s1_g1_b21_c, s1_g2_b22_s, s2_g1_b22_s, s2_g1_b22_c);
    full_adder s2_g1_b23 (s1_g1_b23_s, s1_g1_b22_c, s1_g2_b23_s, s2_g1_b23_s, s2_g1_b23_c);
    full_adder s2_g1_b24 (s1_g1_b24_s, s1_g1_b23_c, s1_g2_b24_s, s2_g1_b24_s, s2_g1_b24_c);
    full_adder s2_g1_b25 (s1_g1_b25_s, s1_g1_b24_c, s1_g2_b25_s, s2_g1_b25_s, s2_g1_b25_c);
    full_adder s2_g1_b26 (s1_g1_b26_s, s1_g1_b25_c, s1_g2_b26_s, s2_g1_b26_s, s2_g1_b26_c);
    full_adder s2_g1_b27 (s1_g1_b27_s, s1_g1_b26_c, s1_g2_b27_s, s2_g1_b27_s, s2_g1_b27_c);
    full_adder s2_g1_b28 (s1_g1_b28_s, s1_g1_b27_c, s1_g2_b28_s, s2_g1_b28_s, s2_g1_b28_c);
    full_adder s2_g1_b29 (s1_g1_b29_s, s1_g1_b28_c, s1_g2_b29_s, s2_g1_b29_s, s2_g1_b29_c);
    full_adder s2_g1_b30 (s1_g1_b30_s, s1_g1_b29_c, s1_g2_b30_s, s2_g1_b30_s, s2_g1_b30_c);
    full_adder s2_g1_b31 (s1_g1_b31_s, s1_g1_b30_c, s1_g2_b31_s, s2_g1_b31_s, s2_g1_b31_c);
    // ***** group 2 *****    
    wire    s2_g2_b12_s, s2_g2_b12_c, s2_g2_b13_s, s2_g2_b13_c, s2_g2_b14_s, s2_g2_b14_c, s2_g2_b15_s, s2_g2_b15_c, s2_g2_b16_s, s2_g2_b16_c,
            s2_g2_b17_s, s2_g2_b17_c, s2_g2_b18_s, s2_g2_b18_c, s2_g2_b19_s, s2_g2_b19_c, s2_g2_b20_s, s2_g2_b20_c, s2_g2_b21_s, s2_g2_b21_c,
            s2_g2_b22_s, s2_g2_b22_c, s2_g2_b23_s, s2_g2_b23_c, s2_g2_b24_s, s2_g2_b24_c, s2_g2_b25_s, s2_g2_b25_c, s2_g2_b26_s, s2_g2_b26_c,
            s2_g2_b27_s, s2_g2_b27_c, s2_g2_b28_s, s2_g2_b28_c, s2_g2_b29_s, s2_g2_b29_c, s2_g2_b30_s, s2_g2_b30_c, s2_g2_b31_s, s2_g2_b31_c;
    half_adder s2_g2_b12 (s1_g2_b11_c, pp_12[0],                 s2_g2_b12_s, s2_g2_b12_c);
    half_adder s2_g2_b13 (s1_g2_b12_c, pp_12[1],                 s2_g2_b13_s, s2_g2_b13_c);
    half_adder s2_g2_b14 (s1_g2_b13_c, s1_g3_b14_s,              s2_g2_b14_s, s2_g2_b14_c);
    full_adder s2_g2_b15 (s1_g2_b14_c, s1_g3_b15_s, s1_g3_b14_c, s2_g2_b15_s, s2_g2_b15_c);
    full_adder s2_g2_b16 (s1_g2_b15_c, s1_g3_b16_s, s1_g3_b15_c, s2_g2_b16_s, s2_g2_b16_c);
    full_adder s2_g2_b17 (s1_g2_b16_c, s1_g3_b17_s, s1_g3_b16_c, s2_g2_b17_s, s2_g2_b17_c);
    full_adder s2_g2_b18 (s1_g2_b17_c, s1_g3_b18_s, s1_g3_b17_c, s2_g2_b18_s, s2_g2_b18_c);
    full_adder s2_g2_b19 (s1_g2_b18_c, s1_g3_b19_s, s1_g3_b18_c, s2_g2_b19_s, s2_g2_b19_c);
    full_adder s2_g2_b20 (s1_g2_b19_c, s1_g3_b20_s, s1_g3_b19_c, s2_g2_b20_s, s2_g2_b20_c);
    full_adder s2_g2_b21 (s1_g2_b20_c, s1_g3_b21_s, s1_g3_b20_c, s2_g2_b21_s, s2_g2_b21_c);
    full_adder s2_g2_b22 (s1_g2_b21_c, s1_g3_b22_s, s1_g3_b21_c, s2_g2_b22_s, s2_g2_b22_c);
    full_adder s2_g2_b23 (s1_g2_b22_c, s1_g3_b23_s, s1_g3_b22_c, s2_g2_b23_s, s2_g2_b23_c);
    full_adder s2_g2_b24 (s1_g2_b23_c, s1_g3_b24_s, s1_g3_b23_c, s2_g2_b24_s, s2_g2_b24_c);
    full_adder s2_g2_b25 (s1_g2_b24_c, s1_g3_b25_s, s1_g3_b24_c, s2_g2_b25_s, s2_g2_b25_c);
    full_adder s2_g2_b26 (s1_g2_b25_c, s1_g3_b26_s, s1_g3_b25_c, s2_g2_b26_s, s2_g2_b26_c);
    full_adder s2_g2_b27 (s1_g2_b26_c, s1_g3_b27_s, s1_g3_b26_c, s2_g2_b27_s, s2_g2_b27_c);
    full_adder s2_g2_b28 (s1_g2_b27_c, s1_g3_b28_s, s1_g3_b27_c, s2_g2_b28_s, s2_g2_b28_c);
    full_adder s2_g2_b29 (s1_g2_b28_c, s1_g3_b29_s, s1_g3_b28_c, s2_g2_b29_s, s2_g2_b29_c);
    full_adder s2_g2_b30 (s1_g2_b29_c, s1_g3_b30_s, s1_g3_b29_c, s2_g2_b30_s, s2_g2_b30_c);
    full_adder s2_g2_b31 (s1_g2_b30_c, s1_g3_b31_s, s1_g3_b30_c, s2_g2_b31_s, s2_g2_b31_c);
    // ***** group 3 *****
    wire    s2_g3_b21_s, s2_g3_b21_c,
            s2_g3_b22_s, s2_g3_b22_c, s2_g3_b23_s, s2_g3_b23_c, s2_g3_b24_s, s2_g3_b24_c, s2_g3_b25_s, s2_g3_b25_c, s2_g3_b26_s, s2_g3_b26_c,
            s2_g3_b27_s, s2_g3_b27_c, s2_g3_b28_s, s2_g3_b28_c, s2_g3_b29_s, s2_g3_b29_c, s2_g3_b30_s, s2_g3_b30_c, s2_g3_b31_s, s2_g3_b31_c;
    half_adder s2_g3_b21 (s1_g4_b21_s, s1_g4_b20_c,              s2_g3_b21_s, s2_g3_b21_c);
    half_adder s2_g3_b22 (s1_g4_b22_s, s1_g4_b21_c,              s2_g3_b22_s, s2_g3_b22_c);
    half_adder s2_g3_b23 (s1_g4_b23_s, s1_g4_b22_c,              s2_g3_b23_s, s2_g3_b23_c);
    full_adder s2_g3_b24 (s1_g4_b24_s, s1_g4_b23_c, pp_24[0],    s2_g3_b24_s, s2_g3_b24_c);
    full_adder s2_g3_b25 (s1_g4_b25_s, s1_g4_b24_c, pp_24[1],    s2_g3_b25_s, s2_g3_b25_c);
    full_adder s2_g3_b26 (s1_g4_b26_s, s1_g4_b25_c, s1_g5_b26_s, s2_g3_b26_s, s2_g3_b26_c);
    full_adder s2_g3_b27 (s1_g4_b27_s, s1_g4_b26_c, s1_g5_b27_s, s2_g3_b27_s, s2_g3_b27_c);
    full_adder s2_g3_b28 (s1_g4_b28_s, s1_g4_b27_c, s1_g5_b28_s, s2_g3_b28_s, s2_g3_b28_c);
    full_adder s2_g3_b29 (s1_g4_b29_s, s1_g4_b28_c, s1_g5_b29_s, s2_g3_b29_s, s2_g3_b29_c);
    full_adder s2_g3_b30 (s1_g4_b30_s, s1_g4_b29_c, s1_g5_b30_s, s2_g3_b30_s, s2_g3_b30_c);
    full_adder s2_g3_b31 (s1_g4_b31_s, s1_g4_b30_c, s1_g5_b31_s, s2_g3_b31_s, s2_g3_b31_c);
    // ***** group 4 *****    
    wire    s2_g4_b30_s, s2_g4_b30_c, s2_g4_b31_s, s2_g4_b31_c;
    half_adder s2_g4_b30 (s1_g5_b29_c, pp_30[0],                 s2_g4_b30_s, s2_g4_b30_c);
    half_adder s2_g4_b31 (s1_g5_b30_c, pp_30[1],                 s2_g4_b31_s, s2_g4_b31_c);
    // =========== stage 3 ==========
    // ***** group 1 *****
    wire    s3_g1_b4_s,  s3_g1_b4_c,  s3_g1_b5_s,  s3_g1_b5_c,  s3_g1_b6_s,  s3_g1_b6_c,
            s3_g1_b7_s,  s3_g1_b7_c,  s3_g1_b8_s,  s3_g1_b8_c,  s3_g1_b9_s,  s3_g1_b9_c,  s3_g1_b10_s, s3_g1_b10_c, s3_g1_b11_s, s3_g1_b11_c,
            s3_g1_b12_s, s3_g1_b12_c, s3_g1_b13_s, s3_g1_b13_c, s3_g1_b14_s, s3_g1_b14_c, s3_g1_b15_s, s3_g1_b15_c, s3_g1_b16_s, s3_g1_b16_c,
            s3_g1_b17_s, s3_g1_b17_c, s3_g1_b18_s, s3_g1_b18_c, s3_g1_b19_s, s3_g1_b19_c, s3_g1_b20_s, s3_g1_b20_c, s3_g1_b21_s, s3_g1_b21_c,
            s3_g1_b22_s, s3_g1_b22_c, s3_g1_b23_s, s3_g1_b23_c, s3_g1_b24_s, s3_g1_b24_c, s3_g1_b25_s, s3_g1_b25_c, s3_g1_b26_s, s3_g1_b26_c,
            s3_g1_b27_s, s3_g1_b27_c, s3_g1_b28_s, s3_g1_b28_c, s3_g1_b29_s, s3_g1_b29_c, s3_g1_b30_s, s3_g1_b30_c, s3_g1_b31_s, s3_g1_b31_c;
    half_adder s3_g1_b4  (s2_g1_b4_s,  s2_g1_b3_c,               s3_g1_b4_s,  s3_g1_b4_c);
    half_adder s3_g1_b5  (s2_g1_b5_s,  s2_g1_b4_c,               s3_g1_b5_s,  s3_g1_b5_c);
    half_adder s3_g1_b6  (s2_g1_b6_s,  s2_g1_b5_c,               s3_g1_b6_s,  s3_g1_b6_c);
    half_adder s3_g1_b7  (s2_g1_b7_s,  s2_g1_b6_c,               s3_g1_b7_s,  s3_g1_b7_c);
    half_adder s3_g1_b8  (s2_g1_b8_s,  s2_g1_b7_c,               s3_g1_b8_s,  s3_g1_b8_c);
    full_adder s3_g1_b9  (s2_g1_b9_s,  s2_g1_b8_c,  s1_g2_b8_c,  s3_g1_b9_s,  s3_g1_b9_c);
    full_adder s3_g1_b10 (s2_g1_b10_s, s2_g1_b9_c,  s1_g2_b9_c,  s3_g1_b10_s, s3_g1_b10_c);
    full_adder s3_g1_b11 (s2_g1_b11_s, s2_g1_b10_c, s1_g2_b10_c, s3_g1_b11_s, s3_g1_b11_c);
    full_adder s3_g1_b12 (s2_g1_b12_s, s2_g1_b11_c, s2_g2_b12_s, s3_g1_b12_s, s3_g1_b12_c);
    full_adder s3_g1_b13 (s2_g1_b13_s, s2_g1_b12_c, s2_g2_b13_s, s3_g1_b13_s, s3_g1_b13_c);
    full_adder s3_g1_b14 (s2_g1_b14_s, s2_g1_b13_c, s2_g2_b14_s, s3_g1_b14_s, s3_g1_b14_c);
    full_adder s3_g1_b15 (s2_g1_b15_s, s2_g1_b14_c, s2_g2_b15_s, s3_g1_b15_s, s3_g1_b15_c);
    full_adder s3_g1_b16 (s2_g1_b16_s, s2_g1_b15_c, s2_g2_b16_s, s3_g1_b16_s, s3_g1_b16_c);
    full_adder s3_g1_b17 (s2_g1_b17_s, s2_g1_b16_c, s2_g2_b17_s, s3_g1_b17_s, s3_g1_b17_c);
    full_adder s3_g1_b18 (s2_g1_b18_s, s2_g1_b17_c, s2_g2_b18_s, s3_g1_b18_s, s3_g1_b18_c);
    full_adder s3_g1_b19 (s2_g1_b19_s, s2_g1_b18_c, s2_g2_b19_s, s3_g1_b19_s, s3_g1_b19_c);
    full_adder s3_g1_b20 (s2_g1_b20_s, s2_g1_b19_c, s2_g2_b20_s, s3_g1_b20_s, s3_g1_b20_c);
    full_adder s3_g1_b21 (s2_g1_b21_s, s2_g1_b20_c, s2_g2_b21_s, s3_g1_b21_s, s3_g1_b21_c);
    full_adder s3_g1_b22 (s2_g1_b22_s, s2_g1_b21_c, s2_g2_b22_s, s3_g1_b22_s, s3_g1_b22_c);
    full_adder s3_g1_b23 (s2_g1_b23_s, s2_g1_b22_c, s2_g2_b23_s, s3_g1_b23_s, s3_g1_b23_c);
    full_adder s3_g1_b24 (s2_g1_b24_s, s2_g1_b23_c, s2_g2_b24_s, s3_g1_b24_s, s3_g1_b24_c);
    full_adder s3_g1_b25 (s2_g1_b25_s, s2_g1_b24_c, s2_g2_b25_s, s3_g1_b25_s, s3_g1_b25_c);
    full_adder s3_g1_b26 (s2_g1_b26_s, s2_g1_b25_c, s2_g2_b26_s, s3_g1_b26_s, s3_g1_b26_c);
    full_adder s3_g1_b27 (s2_g1_b27_s, s2_g1_b26_c, s2_g2_b27_s, s3_g1_b27_s, s3_g1_b27_c);
    full_adder s3_g1_b28 (s2_g1_b28_s, s2_g1_b27_c, s2_g2_b28_s, s3_g1_b28_s, s3_g1_b28_c);
    full_adder s3_g1_b29 (s2_g1_b29_s, s2_g1_b28_c, s2_g2_b29_s, s3_g1_b29_s, s3_g1_b29_c);
    full_adder s3_g1_b30 (s2_g1_b30_s, s2_g1_b29_c, s2_g2_b30_s, s3_g1_b30_s, s3_g1_b30_c);
    full_adder s3_g1_b31 (s2_g1_b31_s, s2_g1_b30_c, s2_g2_b31_s, s3_g1_b31_s, s3_g1_b31_c);
    // ***** group 2 *****
    wire    s3_g2_b18_s, s3_g2_b18_c, s3_g2_b19_s, s3_g2_b19_c, s3_g2_b20_s, s3_g2_b20_c, s3_g2_b21_s, s3_g2_b21_c,
            s3_g2_b22_s, s3_g2_b22_c, s3_g2_b23_s, s3_g2_b23_c, s3_g2_b24_s, s3_g2_b24_c, s3_g2_b25_s, s3_g2_b25_c, s3_g2_b26_s, s3_g2_b26_c,
            s3_g2_b27_s, s3_g2_b27_c, s3_g2_b28_s, s3_g2_b28_c, s3_g2_b29_s, s3_g2_b29_c, s3_g2_b30_s, s3_g2_b30_c, s3_g2_b31_s, s3_g2_b31_c;
    half_adder s3_g2_b18 (s2_g2_b17_c, pp_18[0],                 s3_g2_b18_s, s3_g2_b18_c);
    half_adder s3_g2_b19 (s2_g2_b18_c, pp_18[1],                 s3_g2_b19_s, s3_g2_b19_c);
    half_adder s3_g2_b20 (s2_g2_b19_c, s1_g4_b20_s,              s3_g2_b20_s, s3_g2_b20_c);
    half_adder s3_g2_b21 (s2_g2_b20_c, s2_g3_b21_s,              s3_g2_b21_s, s3_g2_b21_c);
    full_adder s3_g2_b22 (s2_g2_b21_c, s2_g3_b22_s, s2_g3_b21_c, s3_g2_b22_s, s3_g2_b22_c);
    full_adder s3_g2_b23 (s2_g2_b22_c, s2_g3_b23_s, s2_g3_b22_c, s3_g2_b23_s, s3_g2_b23_c);
    full_adder s3_g2_b24 (s2_g2_b23_c, s2_g3_b24_s, s2_g3_b23_c, s3_g2_b24_s, s3_g2_b24_c);
    full_adder s3_g2_b25 (s2_g2_b24_c, s2_g3_b25_s, s2_g3_b24_c, s3_g2_b25_s, s3_g2_b25_c);
    full_adder s3_g2_b26 (s2_g2_b25_c, s2_g3_b26_s, s2_g3_b25_c, s3_g2_b26_s, s3_g2_b26_c);
    full_adder s3_g2_b27 (s2_g2_b26_c, s2_g3_b27_s, s2_g3_b26_c, s3_g2_b27_s, s3_g2_b27_c);
    full_adder s3_g2_b28 (s2_g2_b27_c, s2_g3_b28_s, s2_g3_b27_c, s3_g2_b28_s, s3_g2_b28_c);
    full_adder s3_g2_b29 (s2_g2_b28_c, s2_g3_b29_s, s2_g3_b28_c, s3_g2_b29_s, s3_g2_b29_c);
    full_adder s3_g2_b30 (s2_g2_b29_c, s2_g3_b30_s, s2_g3_b29_c, s3_g2_b30_s, s3_g2_b30_c);
    full_adder s3_g2_b31 (s2_g2_b30_c, s2_g3_b31_s, s2_g3_b30_c, s3_g2_b31_s, s3_g2_b31_c);
    // ***** group 3 *****
    wire    s3_g3_b31_s, s3_g3_b31_c;
    half_adder s3_g3_b31 (s2_g4_b31_s, s2_g4_b30_c,              s3_g3_b31_s, s3_g3_b31_c);
    // =========== stage 4 ==========
    // ***** group 1 *****
    wire    s4_g1_b5_s,  s4_g1_b5_c,  s4_g1_b6_s,  s4_g1_b6_c,
            s4_g1_b7_s,  s4_g1_b7_c,  s4_g1_b8_s,  s4_g1_b8_c,  s4_g1_b9_s,  s4_g1_b9_c,  s4_g1_b10_s, s4_g1_b10_c, s4_g1_b11_s, s4_g1_b11_c,
            s4_g1_b12_s, s4_g1_b12_c, s4_g1_b13_s, s4_g1_b13_c, s4_g1_b14_s, s4_g1_b14_c, s4_g1_b15_s, s4_g1_b15_c, s4_g1_b16_s, s4_g1_b16_c,
            s4_g1_b17_s, s4_g1_b17_c, s4_g1_b18_s, s4_g1_b18_c, s4_g1_b19_s, s4_g1_b19_c, s4_g1_b20_s, s4_g1_b20_c, s4_g1_b21_s, s4_g1_b21_c,
            s4_g1_b22_s, s4_g1_b22_c, s4_g1_b23_s, s4_g1_b23_c, s4_g1_b24_s, s4_g1_b24_c, s4_g1_b25_s, s4_g1_b25_c, s4_g1_b26_s, s4_g1_b26_c,
            s4_g1_b27_s, s4_g1_b27_c, s4_g1_b28_s, s4_g1_b28_c, s4_g1_b29_s, s4_g1_b29_c, s4_g1_b30_s, s4_g1_b30_c, s4_g1_b31_s, s4_g1_b31_c;
    half_adder s4_g1_b5  (s3_g1_b5_s,  s3_g1_b4_c,               s4_g1_b5_s,  s4_g1_b5_c);
    half_adder s4_g1_b6  (s3_g1_b6_s,  s3_g1_b5_c,               s4_g1_b6_s,  s4_g1_b6_c);
    half_adder s4_g1_b7  (s3_g1_b7_s,  s3_g1_b6_c,               s4_g1_b7_s,  s4_g1_b7_c);
    half_adder s4_g1_b8  (s3_g1_b8_s,  s3_g1_b7_c,               s4_g1_b8_s,  s4_g1_b8_c);
    half_adder s4_g1_b9  (s3_g1_b9_s,  s3_g1_b8_c,               s4_g1_b9_s,  s4_g1_b9_c);
    half_adder s4_g1_b10 (s3_g1_b10_s, s3_g1_b9_c,               s4_g1_b10_s, s4_g1_b10_c);
    half_adder s4_g1_b11 (s3_g1_b11_s, s3_g1_b10_c,              s4_g1_b11_s, s4_g1_b11_c);
    half_adder s4_g1_b12 (s3_g1_b12_s, s3_g1_b11_c,              s4_g1_b12_s, s4_g1_b12_c);
    full_adder s4_g1_b13 (s3_g1_b13_s, s3_g1_b12_c, s2_g2_b12_c, s4_g1_b13_s, s4_g1_b13_c);
    full_adder s4_g1_b14 (s3_g1_b14_s, s3_g1_b13_c, s2_g2_b13_c, s4_g1_b14_s, s4_g1_b14_c);
    full_adder s4_g1_b15 (s3_g1_b15_s, s3_g1_b14_c, s2_g2_b14_c, s4_g1_b15_s, s4_g1_b15_c);
    full_adder s4_g1_b16 (s3_g1_b16_s, s3_g1_b15_c, s2_g2_b15_c, s4_g1_b16_s, s4_g1_b16_c);
    full_adder s4_g1_b17 (s3_g1_b17_s, s3_g1_b16_c, s2_g2_b16_c, s4_g1_b17_s, s4_g1_b17_c);
    full_adder s4_g1_b18 (s3_g1_b18_s, s3_g1_b17_c, s3_g2_b18_s, s4_g1_b18_s, s4_g1_b18_c);
    full_adder s4_g1_b19 (s3_g1_b19_s, s3_g1_b18_c, s3_g2_b19_s, s4_g1_b19_s, s4_g1_b19_c);
    full_adder s4_g1_b20 (s3_g1_b20_s, s3_g1_b19_c, s3_g2_b20_s, s4_g1_b20_s, s4_g1_b20_c);
    full_adder s4_g1_b21 (s3_g1_b21_s, s3_g1_b20_c, s3_g2_b21_s, s4_g1_b21_s, s4_g1_b21_c);
    full_adder s4_g1_b22 (s3_g1_b22_s, s3_g1_b21_c, s3_g2_b22_s, s4_g1_b22_s, s4_g1_b22_c);
    full_adder s4_g1_b23 (s3_g1_b23_s, s3_g1_b22_c, s3_g2_b23_s, s4_g1_b23_s, s4_g1_b23_c);
    full_adder s4_g1_b24 (s3_g1_b24_s, s3_g1_b23_c, s3_g2_b24_s, s4_g1_b24_s, s4_g1_b24_c);
    full_adder s4_g1_b25 (s3_g1_b25_s, s3_g1_b24_c, s3_g2_b25_s, s4_g1_b25_s, s4_g1_b25_c);
    full_adder s4_g1_b26 (s3_g1_b26_s, s3_g1_b25_c, s3_g2_b26_s, s4_g1_b26_s, s4_g1_b26_c);
    full_adder s4_g1_b27 (s3_g1_b27_s, s3_g1_b26_c, s3_g2_b27_s, s4_g1_b27_s, s4_g1_b27_c);
    full_adder s4_g1_b28 (s3_g1_b28_s, s3_g1_b27_c, s3_g2_b28_s, s4_g1_b28_s, s4_g1_b28_c);
    full_adder s4_g1_b29 (s3_g1_b29_s, s3_g1_b28_c, s3_g2_b29_s, s4_g1_b29_s, s4_g1_b29_c);
    full_adder s4_g1_b30 (s3_g1_b30_s, s3_g1_b29_c, s3_g2_b30_s, s4_g1_b30_s, s4_g1_b30_c);
    full_adder s4_g1_b31 (s3_g1_b31_s, s3_g1_b30_c, s3_g2_b31_s, s4_g1_b31_s, s4_g1_b31_c);
    // ***** group 2 *****    
    wire    s4_g2_b27_s, s4_g2_b27_c, s4_g2_b28_s, s4_g2_b28_c, s4_g2_b29_s, s4_g2_b29_c, s4_g2_b30_s, s4_g2_b30_c, s4_g2_b31_s, s4_g2_b31_c;
    half_adder s4_g2_b27 (s3_g2_b26_c, s1_g5_b26_c,              s4_g2_b27_s, s4_g2_b27_c);
    half_adder s4_g2_b28 (s3_g2_b27_c, s1_g5_b27_c,              s4_g2_b28_s, s4_g2_b28_c);
    half_adder s4_g2_b29 (s3_g2_b28_c, s1_g5_b28_c,              s4_g2_b29_s, s4_g2_b29_c);
    half_adder s4_g2_b30 (s3_g2_b29_c, s2_g4_b30_s,              s4_g2_b30_s, s4_g2_b30_c);
    half_adder s4_g2_b31 (s3_g2_b30_c, s3_g3_b31_s,              s4_g2_b31_s, s4_g2_b31_c);

    // =========== stage 5 ==========
    // ***** group 1 *****
    wire    s5_g1_b6_s,  s5_g1_b6_c,
            s5_g1_b7_s,  s5_g1_b7_c,  s5_g1_b8_s,  s5_g1_b8_c,  s5_g1_b9_s,  s5_g1_b9_c,  s5_g1_b10_s, s5_g1_b10_c, s5_g1_b11_s, s5_g1_b11_c,
            s5_g1_b12_s, s5_g1_b12_c, s5_g1_b13_s, s5_g1_b13_c, s5_g1_b14_s, s5_g1_b14_c, s5_g1_b15_s, s5_g1_b15_c, s5_g1_b16_s, s5_g1_b16_c,
            s5_g1_b17_s, s5_g1_b17_c, s5_g1_b18_s, s5_g1_b18_c, s5_g1_b19_s, s5_g1_b19_c, s5_g1_b20_s, s5_g1_b20_c, s5_g1_b21_s, s5_g1_b21_c,
            s5_g1_b22_s, s5_g1_b22_c, s5_g1_b23_s, s5_g1_b23_c, s5_g1_b24_s, s5_g1_b24_c, s5_g1_b25_s, s5_g1_b25_c, s5_g1_b26_s, s5_g1_b26_c,
            s5_g1_b27_s, s5_g1_b27_c, s5_g1_b28_s, s5_g1_b28_c, s5_g1_b29_s, s5_g1_b29_c, s5_g1_b30_s, s5_g1_b30_c, s5_g1_b31_s, s5_g1_b31_c;
    half_adder s5_g1_b6  (s4_g1_b6_s,  s4_g1_b5_c,               s5_g1_b6_s,  s5_g1_b6_c);
    half_adder s5_g1_b7  (s4_g1_b7_s,  s4_g1_b6_c,               s5_g1_b7_s,  s5_g1_b7_c);
    half_adder s5_g1_b8  (s4_g1_b8_s,  s4_g1_b7_c,               s5_g1_b8_s,  s5_g1_b8_c);
    half_adder s5_g1_b9  (s4_g1_b9_s,  s4_g1_b8_c,               s5_g1_b9_s,  s5_g1_b9_c);
    half_adder s5_g1_b10 (s4_g1_b10_s, s4_g1_b9_c,               s5_g1_b10_s, s5_g1_b10_c);
    half_adder s5_g1_b11 (s4_g1_b11_s, s4_g1_b10_c,              s5_g1_b11_s, s5_g1_b11_c);
    half_adder s5_g1_b12 (s4_g1_b12_s, s4_g1_b11_c,              s5_g1_b12_s, s5_g1_b12_c);
    half_adder s5_g1_b13 (s4_g1_b13_s, s4_g1_b12_c,              s5_g1_b13_s, s5_g1_b13_c);
    half_adder s5_g1_b14 (s4_g1_b14_s, s4_g1_b13_c,              s5_g1_b14_s, s5_g1_b14_c);
    half_adder s5_g1_b15 (s4_g1_b15_s, s4_g1_b14_c,              s5_g1_b15_s, s5_g1_b15_c);
    half_adder s5_g1_b16 (s4_g1_b16_s, s4_g1_b15_c,              s5_g1_b16_s, s5_g1_b16_c);
    half_adder s5_g1_b17 (s4_g1_b17_s, s4_g1_b16_c,              s5_g1_b17_s, s5_g1_b17_c);
    half_adder s5_g1_b18 (s4_g1_b18_s, s4_g1_b17_c,              s5_g1_b18_s, s5_g1_b18_c);
    full_adder s5_g1_b19 (s4_g1_b19_s, s4_g1_b18_c, s3_g2_b18_c, s5_g1_b19_s, s5_g1_b19_c);
    full_adder s5_g1_b20 (s4_g1_b20_s, s4_g1_b19_c, s3_g2_b19_c, s5_g1_b20_s, s5_g1_b20_c);
    full_adder s5_g1_b21 (s4_g1_b21_s, s4_g1_b20_c, s3_g2_b20_c, s5_g1_b21_s, s5_g1_b21_c);
    full_adder s5_g1_b22 (s4_g1_b22_s, s4_g1_b21_c, s3_g2_b21_c, s5_g1_b22_s, s5_g1_b22_c);
    full_adder s5_g1_b23 (s4_g1_b23_s, s4_g1_b22_c, s3_g2_b22_c, s5_g1_b23_s, s5_g1_b23_c);
    full_adder s5_g1_b24 (s4_g1_b24_s, s4_g1_b23_c, s3_g2_b23_c, s5_g1_b24_s, s5_g1_b24_c);
    full_adder s5_g1_b25 (s4_g1_b25_s, s4_g1_b24_c, s3_g2_b24_c, s5_g1_b25_s, s5_g1_b25_c);
    full_adder s5_g1_b26 (s4_g1_b26_s, s4_g1_b25_c, s3_g2_b25_c, s5_g1_b26_s, s5_g1_b26_c);
    full_adder s5_g1_b27 (s4_g1_b27_s, s4_g1_b26_c, s4_g2_b27_s, s5_g1_b27_s, s5_g1_b27_c);
    full_adder s5_g1_b28 (s4_g1_b28_s, s4_g1_b27_c, s4_g2_b28_s, s5_g1_b28_s, s5_g1_b28_c);
    full_adder s5_g1_b29 (s4_g1_b29_s, s4_g1_b28_c, s4_g2_b29_s, s5_g1_b29_s, s5_g1_b29_c);
    full_adder s5_g1_b30 (s4_g1_b30_s, s4_g1_b29_c, s4_g2_b30_s, s5_g1_b30_s, s5_g1_b30_c);
    full_adder s5_g1_b31 (s4_g1_b31_s, s4_g1_b30_c, s4_g2_b31_s, s5_g1_b31_s, s5_g1_b31_c);

    // =========== stage 6 ==========
    // ***** group 1 *****
    wire    s6_g1_b7_s,  s6_g1_b7_c,  s6_g1_b8_s,  s6_g1_b8_c,  s6_g1_b9_s,  s6_g1_b9_c,  s6_g1_b10_s, s6_g1_b10_c, s6_g1_b11_s, s6_g1_b11_c,
            s6_g1_b12_s, s6_g1_b12_c, s6_g1_b13_s, s6_g1_b13_c, s6_g1_b14_s, s6_g1_b14_c, s6_g1_b15_s, s6_g1_b15_c, s6_g1_b16_s, s6_g1_b16_c,
            s6_g1_b17_s, s6_g1_b17_c, s6_g1_b18_s, s6_g1_b18_c, s6_g1_b19_s, s6_g1_b19_c, s6_g1_b20_s, s6_g1_b20_c, s6_g1_b21_s, s6_g1_b21_c,
            s6_g1_b22_s, s6_g1_b22_c, s6_g1_b23_s, s6_g1_b23_c, s6_g1_b24_s, s6_g1_b24_c, s6_g1_b25_s, s6_g1_b25_c, s6_g1_b26_s, s6_g1_b26_c,
            s6_g1_b27_s, s6_g1_b27_c, s6_g1_b28_s, s6_g1_b28_c, s6_g1_b29_s, s6_g1_b29_c, s6_g1_b30_s, s6_g1_b30_c, s6_g1_b31_s, s6_g1_b31_c;
    half_adder s6_g1_b7  (s5_g1_b7_s,  s5_g1_b6_c,               s6_g1_b7_s,  s6_g1_b7_c);
    half_adder s6_g1_b8  (s5_g1_b8_s,  s5_g1_b7_c,               s6_g1_b8_s,  s6_g1_b8_c);
    half_adder s6_g1_b9  (s5_g1_b9_s,  s5_g1_b8_c,               s6_g1_b9_s,  s6_g1_b9_c);
    half_adder s6_g1_b10 (s5_g1_b10_s, s5_g1_b9_c,               s6_g1_b10_s, s6_g1_b10_c);
    half_adder s6_g1_b11 (s5_g1_b11_s, s5_g1_b10_c,              s6_g1_b11_s, s6_g1_b11_c);
    half_adder s6_g1_b12 (s5_g1_b12_s, s5_g1_b11_c,              s6_g1_b12_s, s6_g1_b12_c);
    half_adder s6_g1_b13 (s5_g1_b13_s, s5_g1_b12_c,              s6_g1_b13_s, s6_g1_b13_c);
    half_adder s6_g1_b14 (s5_g1_b14_s, s5_g1_b13_c,              s6_g1_b14_s, s6_g1_b14_c);
    half_adder s6_g1_b15 (s5_g1_b15_s, s5_g1_b14_c,              s6_g1_b15_s, s6_g1_b15_c);
    half_adder s6_g1_b16 (s5_g1_b16_s, s5_g1_b15_c,              s6_g1_b16_s, s6_g1_b16_c);
    half_adder s6_g1_b17 (s5_g1_b17_s, s5_g1_b16_c,              s6_g1_b17_s, s6_g1_b17_c);
    half_adder s6_g1_b18 (s5_g1_b18_s, s5_g1_b17_c,              s6_g1_b18_s, s6_g1_b18_c);
    half_adder s6_g1_b19 (s5_g1_b19_s, s5_g1_b18_c,              s6_g1_b19_s, s6_g1_b19_c);
    half_adder s6_g1_b20 (s5_g1_b20_s, s5_g1_b19_c,              s6_g1_b20_s, s6_g1_b20_c);
    half_adder s6_g1_b21 (s5_g1_b21_s, s5_g1_b20_c,              s6_g1_b21_s, s6_g1_b21_c);
    half_adder s6_g1_b22 (s5_g1_b22_s, s5_g1_b21_c,              s6_g1_b22_s, s6_g1_b22_c);
    half_adder s6_g1_b23 (s5_g1_b23_s, s5_g1_b22_c,              s6_g1_b23_s, s6_g1_b23_c);
    half_adder s6_g1_b24 (s5_g1_b24_s, s5_g1_b23_c,              s6_g1_b24_s, s6_g1_b24_c);
    half_adder s6_g1_b25 (s5_g1_b25_s, s5_g1_b24_c,              s6_g1_b25_s, s6_g1_b25_c);
    half_adder s6_g1_b26 (s5_g1_b26_s, s5_g1_b25_c,              s6_g1_b26_s, s6_g1_b26_c);
    half_adder s6_g1_b27 (s5_g1_b27_s, s5_g1_b26_c,              s6_g1_b27_s, s6_g1_b27_c);
    full_adder s6_g1_b28 (s5_g1_b28_s, s5_g1_b27_c, s4_g2_b27_c, s6_g1_b28_s, s6_g1_b28_c);
    full_adder s6_g1_b29 (s5_g1_b29_s, s5_g1_b28_c, s4_g2_b28_c, s6_g1_b29_s, s6_g1_b29_c);
    full_adder s6_g1_b30 (s5_g1_b30_s, s5_g1_b29_c, s4_g2_b29_c, s6_g1_b30_s, s6_g1_b30_c);
    full_adder s6_g1_b31 (s5_g1_b31_s, s5_g1_b30_c, s4_g2_b30_c, s6_g1_b31_s, s6_g1_b31_c);

    assign csa_result = second_stage_sum + second_stage_carry;



    always @ (posedge inst_CLK) begin
        if (~rst_n) begin
            third_stage_result <= 0;
        end
        else if (~stall) begin
            // ========== stage 1 ==========
            if (booth_0 == 0)                           pp_0 <= 0;
            else if (booth_0 == 1)                      pp_0 <= inst_A[31:0];
            else if (booth_0 == 2)                      pp_0 <= ~{inst_A[30:0], 1'b0} + 1;
            else                                        pp_0 <= ~inst_A[31:0] + 1;

            if (booth_2 == 0 || booth_2 == 7)           pp_2 <= 0;
            else if (booth_2 == 1 || booth_2 == 2)      pp_2 <= inst_A[29:0];
            else if (booth_2 == 5 || booth_2 == 6)      pp_2 <= ~inst_A[29:0] + 1;
            else if (booth_2 == 3)                      pp_2 <= {inst_A[28:0], 1'b0};
            else if (booth_2 == 4)                      pp_2 <= ~{inst_A[28:0], 1'b0} + 1;

            if (booth_4 == 0 || booth_4 == 7)           pp_4 <= 0;
            else if (booth_4 == 1 || booth_4 == 2)      pp_4 <= inst_A[27:0];
            else if (booth_4 == 5 || booth_4 == 6)      pp_4 <= ~inst_A[27:0] + 1;
            else if (booth_4 == 3)                      pp_4 <= {inst_A[26:0], 1'b0};
            else if (booth_4 == 4)                      pp_4 <= ~{inst_A[26:0], 1'b0} + 1;

            if (booth_6 == 0 || booth_6 == 7)           pp_6 <= 0;
            else if (booth_6 == 1 || booth_6 == 2)      pp_6 <= inst_A[25:0];
            else if (booth_6 == 5 || booth_6 == 6)      pp_6 <= ~inst_A[25:0] + 1;
            else if (booth_6 == 3)                      pp_6 <= {inst_A[24:0], 1'b0};
            else if (booth_6 == 4)                      pp_6 <= ~{inst_A[24:0], 1'b0} + 1;

            if (booth_8 == 0 || booth_8 == 7)           pp_8 <= 0;
            else if (booth_8 == 1 || booth_8 == 2)      pp_8 <= inst_A[23:0];
            else if (booth_8 == 5 || booth_8 == 6)      pp_8 <= ~inst_A[23:0] + 1;
            else if (booth_8 == 3)                      pp_8 <= {inst_A[22:0], 1'b0};
            else if (booth_8 == 4)                      pp_8 <= ~{inst_A[22:0], 1'b0} + 1;

            if (booth_10 == 0 || booth_10 == 7)         pp_10 <= 0;
            else if (booth_10 == 1 || booth_10 == 2)    pp_10 <= inst_A[21:0];
            else if (booth_10 == 5 || booth_10 == 6)    pp_10 <= ~inst_A[21:0] + 1;
            else if (booth_10 == 3)                     pp_10 <= {inst_A[20:0], 1'b0};
            else if (booth_10 == 4)                     pp_10 <= ~{inst_A[20:0], 1'b0} + 1;

            if (booth_12 == 0 || booth_12 == 7)         pp_12 <= 0;
            else if (booth_12 == 1 || booth_12 == 2)    pp_12 <= inst_A[19:0];
            else if (booth_12 == 5 || booth_12 == 6)    pp_12 <= ~inst_A[19:0] + 1;
            else if (booth_12 == 3)                     pp_12 <= {inst_A[18:0], 1'b0};
            else if (booth_12 == 4)                     pp_12 <= ~{inst_A[18:0], 1'b0} + 1;

            if (booth_14 == 0 || booth_14 == 7)         pp_14 <= 0;
            else if (booth_14 == 1 || booth_14 == 2)    pp_14 <= inst_A[17:0];
            else if (booth_14 == 5 || booth_14 == 6)    pp_14 <= ~inst_A[17:0] + 1;
            else if (booth_14 == 3)                     pp_14 <= {inst_A[16:0], 1'b0};
            else if (booth_14 == 4)                     pp_14 <= ~{inst_A[16:0], 1'b0} + 1;

            if (booth_16 == 0 || booth_16 == 7)         pp_16 <= 0;
            else if (booth_16 == 1 || booth_16 == 2)    pp_16 <= inst_A[15:0];
            else if (booth_16 == 5 || booth_16 == 6)    pp_16 <= ~inst_A[15:0] + 1;
            else if (booth_16 == 3)                     pp_16 <= {inst_A[14:0], 1'b0};
            else if (booth_16 == 4)                     pp_16 <= ~{inst_A[14:0], 1'b0} + 1;

            if (booth_18 == 0 || booth_18 == 7)         pp_18 <= 0;
            else if (booth_18 == 1 || booth_18 == 2)    pp_18 <= inst_A[13:0];
            else if (booth_18 == 5 || booth_18 == 6)    pp_18 <= ~inst_A[13:0] + 1;
            else if (booth_18 == 3)                     pp_18 <= {inst_A[12:0], 1'b0};
            else if (booth_18 == 4)                     pp_18 <= ~{inst_A[12:0], 1'b0} + 1;

            if (booth_20 == 0 || booth_20 == 7)         pp_20 <= 0;
            else if (booth_20 == 1 || booth_20 == 2)    pp_20 <= inst_A[11:0];
            else if (booth_20 == 5 || booth_20 == 6)    pp_20 <= ~inst_A[11:0] + 1;
            else if (booth_20 == 3)                     pp_20 <= {inst_A[10:0], 1'b0};
            else if (booth_20 == 4)                     pp_20 <= ~{inst_A[10:0], 1'b0} + 1;

            if (booth_22 == 0 || booth_22 == 7)         pp_22 <= 0;
            else if (booth_22 == 1 || booth_22 == 2)    pp_22 <= inst_A[9:0];
            else if (booth_22 == 5 || booth_22 == 6)    pp_22 <= ~inst_A[9:0] + 1;
            else if (booth_22 == 3)                     pp_22 <= {inst_A[8:0], 1'b0};
            else if (booth_22 == 4)                     pp_22 <= ~{inst_A[8:0], 1'b0} + 1;

            if (booth_24 == 0 || booth_24 == 7)         pp_24 <= 0;
            else if (booth_24 == 1 || booth_24 == 2)    pp_24 <= inst_A[7:0];
            else if (booth_24 == 5 || booth_24 == 6)    pp_24 <= ~inst_A[7:0] + 1;
            else if (booth_24 == 3)                     pp_24 <= {inst_A[6:0], 1'b0};
            else if (booth_24 == 4)                     pp_24 <= ~{inst_A[6:0], 1'b0} + 1;

            if (booth_26 == 0 || booth_26 == 7)         pp_26 <= 0;
            else if (booth_26 == 1 || booth_26 == 2)    pp_26 <= inst_A[5:0];
            else if (booth_26 == 5 || booth_26 == 6)    pp_26 <= ~inst_A[5:0] + 1;
            else if (booth_26 == 3)                     pp_26 <= {inst_A[4:0], 1'b0};
            else if (booth_26 == 4)                     pp_26 <= ~{inst_A[4:0], 1'b0} + 1;

            if (booth_28 == 0 || booth_28 == 7)         pp_28 <= 0;
            else if (booth_28 == 1 || booth_28 == 2)    pp_28 <= inst_A[3:0];
            else if (booth_28 == 5 || booth_28 == 6)    pp_28 <= ~inst_A[3:0] + 1;
            else if (booth_28 == 3)                     pp_28 <= {inst_A[2:0], 1'b0};
            else if (booth_28 == 4)                     pp_28 <= ~{inst_A[2:0], 1'b0} + 1;

            if (booth_30 == 0 || booth_30 == 7)         pp_30 <= 0;
            else if (booth_30 == 1 || booth_30 == 2)    pp_30 <= inst_A[1:0];
            else if (booth_30 == 5 || booth_30 == 6)    pp_30 <= ~inst_A[1:0] + 1;
            else if (booth_30 == 3)                     pp_30 <= {inst_A[0], 1'b0};
            else if (booth_30 == 4)                     pp_30 <= ~{inst_A[0], 1'b0} + 1;
            // ========== stage 2 ==========
            second_stage_result[1:0]    <= pp_0[1:0];
            second_stage_result[2]      <= s1_g1_b2_s;
            second_stage_result[3]      <= s2_g1_b3_s;
            second_stage_result[4]      <= s3_g1_b4_s;
            second_stage_result[5]      <= s4_g1_b5_s;
            second_stage_result[6]      <= s5_g1_b6_s;
            second_stage_result[7]      <= s6_g1_b7_s;
            second_stage_sum    <=  {
                                    s6_g1_b31_s, s6_g1_b30_s, s6_g1_b29_s, s6_g1_b28_s, s6_g1_b27_s, s6_g1_b26_s,
                                    s6_g1_b25_s, s6_g1_b24_s, s6_g1_b23_s, s6_g1_b22_s, s6_g1_b21_s, s6_g1_b20_s,
                                    s6_g1_b19_s, s6_g1_b18_s, s6_g1_b17_s, s6_g1_b16_s, s6_g1_b15_s, s6_g1_b14_s,
                                    s6_g1_b13_s, s6_g1_b12_s, s6_g1_b11_s, s6_g1_b10_s, s6_g1_b9_s,  s6_g1_b8_s 
                                    };
            second_stage_carry <=   {
                                    s6_g1_b30_c, s6_g1_b29_c, s6_g1_b28_c, s6_g1_b27_c, s6_g1_b26_c,
                                    s6_g1_b25_c, s6_g1_b24_c, s6_g1_b23_c, s6_g1_b22_c, s6_g1_b21_c, s6_g1_b20_c,
                                    s6_g1_b19_c, s6_g1_b18_c, s6_g1_b17_c, s6_g1_b16_c, s6_g1_b15_c, s6_g1_b14_c,
                                    s6_g1_b13_c, s6_g1_b12_c, s6_g1_b11_c, s6_g1_b10_c, s6_g1_b9_c,  s6_g1_b8_c, s6_g1_b7_c 
                                    };
            third_stage_result <= {csa_result, second_stage_result};
        end
    end


endmodule

module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    assign sum   = a ^ b;  // XOR for sum
    assign carry = a & b;  // AND for carry
endmodule

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;                       // XOR for sum
    assign cout = (a & b) | (b & cin) | (a & cin);   // Carry-out logic
endmodule