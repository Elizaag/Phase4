/* verilator lint_off DECLFILENAME */
/* verilator lint_off MULTITOP */
/* verilator lint_off UNOPTFLAT */

module ALU (
    input [31:0] iDataA,
    input [31:0] iDataB,
    input [3:0]  iAluCtrl,
    output [31:0] oData,
    output oZero
);

    localparam ADD = 4'b0000;
    localparam SUB = 4'b0101;
    localparam SLL = 4'b0001;
    localparam SRL = 4'b1001;
    localparam SRA = 4'b1101;
    localparam SLT = 4'b0010;
    localparam SLTU = 4'b0011;
    localparam XOR = 4'b0100;
    localparam OR = 4'b0110;
    localparam AND = 4'b0111;
    localparam BEQ = 4'b1000;
    localparam BNE = 4'b1100;
    localparam BLT = 4'b1010;
    localparam BGE = 4'b1110;
    localparam BLTU = 4'b1011;
    localparam BGEU = 4'b1111;

    wire [31:0] add_result;
    wire add_cout_unused;
    wire sub_cout_unused;
    wire cmp_eq_unused;
    wire cmp_gt_unused;

    adder_32bit ADD_AB (
        .a(iDataA),
        .b(iDataB),
        .cin(1'b0),
        .sum(add_result),
        .cout(add_cout_unused)
    );

    wire [31:0] b_neg;
    wire [31:0] sub_result;

    twos_complement_32bit TWOS_B (
        .a(iDataB),
        .neg_a(b_neg)
    );

    adder_32bit SUB_AB (
        .a(iDataA),
        .b(b_neg),
        .cin(1'b0),
        .sum(sub_result),
        .cout(sub_cout_unused)
    );

    wire [31:0] sll_result;

    barrel_shifter_32bit SHIFTER (
        .a(iDataA),
        .shamt(iDataB[4:0]),
        .op(2'b00),             
        .y(sll_result)
    );

    wire [31:0] srl_result;
    wire [31:0] sra_result;

    barrel_shifter_32bit SHIFTER_SRL (
        .a(iDataA),
        .shamt(iDataB[4:0]),
        .op(2'b01),          
        .y(srl_result)
    );

    barrel_shifter_32bit SHIFTER_SRA (
        .a(iDataA),
        .shamt(iDataB[4:0]),
        .op(2'b10),          
        .y(sra_result)
    );

    wire cmp_lt;

    comparator_32bit CMP (
        .a(iDataA),
        .b(iDataB),
        .lt(cmp_lt),
        .eq(cmp_eq_unused),
        .gt(cmp_gt_unused)
    );

    wire [31:0] xor_result;

    XOR32 XOR_BLOCK (
        .a(iDataA),
        .b(iDataB),
        .y(xor_result)
    );

    wire [31:0] or_result;

    OR32 OR_BLOCK (
        .a(iDataA),
        .b(iDataB),
        .y(or_result)
    );

    wire [31:0] and_result;

    AND32 AND_BLOCK (
        .a(iDataA),
        .b(iDataB),
        .y(and_result)
    );

    reg [31:0] result;

    always @(*) begin
    	case (iAluCtrl)

        	ADD:  result = add_result;

        	SUB:  result = sub_result;

        	SLL:  result = sll_result;

        	SRL:  result = srl_result;

        	SRA:  result = sra_result;

        	SLT: begin
    			if (iDataA[31] != iDataB[31])
        			result = {31'b0, iDataA[31]};
    			else
        			result = {31'b0, sub_result[31]};
			end

        	SLTU: result = {31'b0, cmp_lt};

        	XOR:  result = xor_result;

        	OR:   result = or_result;

        	AND:  result = and_result;

        	BEQ:  result = sub_result;
        	BNE:  result = sub_result;
        	BLT:  result = sub_result;
        	BGE:  result = sub_result;
            BLTU: result = sub_result;
            BGEU: result = sub_result;

        	default: result = 32'b0;

    	endcase
    end

    assign oData = result;

    //assign oZero = (result == 32'b0);
    reg zero_flag;

    always @(*) begin
        case (iAluCtrl)
            BEQ:    zero_flag = (iDataA == iDataB);
            BNE:    zero_flag = (iDataA != iDataB);
            BLT:    zero_flag = ($signed(iDataA) <  $signed(iDataB));
            BGE:    zero_flag = ($signed(iDataA) >= $signed(iDataB));
            BLTU:   zero_flag = ($unsigned(iDataA) <  $unsigned(iDataB));
            BGEU:   zero_flag = ($unsigned(iDataA) >= $unsigned(iDataB));
            default: zero_flag = (result == 32'b0);
        endcase
    end

    assign oZero = zero_flag;

endmodule

module twos_complement_32bit (
    input  wire [31:0] a,
    output wire [31:0] neg_a
);
    wire [31:0] not_a;
    wire        unused_cout;

    NOT32 NOT_BLOCK (
        .a(a),
        .y(not_a)
    );

    adder_32bit ADD_ONE (
        .a(not_a),
        .b(32'b0),
        .cin(1'b1),
        .sum(neg_a),
        .cout(unused_cout)
    );

endmodule

module NOT32 (
    input  wire [31:0] a,
    output wire [31:0] y
);
    NOT n0  (.x(a[0]),  .y(y[0]));
    NOT n1  (.x(a[1]),  .y(y[1]));
    NOT n2  (.x(a[2]),  .y(y[2]));
    NOT n3  (.x(a[3]),  .y(y[3]));
    NOT n4  (.x(a[4]),  .y(y[4]));
    NOT n5  (.x(a[5]),  .y(y[5]));
    NOT n6  (.x(a[6]),  .y(y[6]));
    NOT n7  (.x(a[7]),  .y(y[7]));
    NOT n8  (.x(a[8]),  .y(y[8]));
    NOT n9  (.x(a[9]),  .y(y[9]));
    NOT n10 (.x(a[10]), .y(y[10]));
    NOT n11 (.x(a[11]), .y(y[11]));
    NOT n12 (.x(a[12]), .y(y[12]));
    NOT n13 (.x(a[13]), .y(y[13]));
    NOT n14 (.x(a[14]), .y(y[14]));
    NOT n15 (.x(a[15]), .y(y[15]));
    NOT n16 (.x(a[16]), .y(y[16]));
    NOT n17 (.x(a[17]), .y(y[17]));
    NOT n18 (.x(a[18]), .y(y[18]));
    NOT n19 (.x(a[19]), .y(y[19]));
    NOT n20 (.x(a[20]), .y(y[20]));
    NOT n21 (.x(a[21]), .y(y[21]));
    NOT n22 (.x(a[22]), .y(y[22]));
    NOT n23 (.x(a[23]), .y(y[23]));
    NOT n24 (.x(a[24]), .y(y[24]));
    NOT n25 (.x(a[25]), .y(y[25]));
    NOT n26 (.x(a[26]), .y(y[26]));
    NOT n27 (.x(a[27]), .y(y[27]));
    NOT n28 (.x(a[28]), .y(y[28]));
    NOT n29 (.x(a[29]), .y(y[29]));
    NOT n30 (.x(a[30]), .y(y[30]));
    NOT n31 (.x(a[31]), .y(y[31]));
endmodule

module NOT (
    input  wire x,
    output reg  y
);
    // CHANGE HERE
    always @(x) begin
        if (x == 1'b0)
            y = 1'b1;
        else
            y = 1'b0;
    end
endmodule

module AND2 (
    input wire a,
    input wire b,
    output wire y
);
    assign y = a & b;
endmodule

module AND3 (
    input wire a,
    input wire b,
    input wire c,
    output wire y
);
    assign y = a & b & c;
endmodule

module AND32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);
    AND2 a0  (.a(a[0]),  .b(b[0]),  .y(y[0]));
    AND2 a1  (.a(a[1]),  .b(b[1]),  .y(y[1]));
    AND2 a2  (.a(a[2]),  .b(b[2]),  .y(y[2]));
    AND2 a3  (.a(a[3]),  .b(b[3]),  .y(y[3]));
    AND2 a4  (.a(a[4]),  .b(b[4]),  .y(y[4]));
    AND2 a5  (.a(a[5]),  .b(b[5]),  .y(y[5]));
    AND2 a6  (.a(a[6]),  .b(b[6]),  .y(y[6]));
    AND2 a7  (.a(a[7]),  .b(b[7]),  .y(y[7]));
    AND2 a8  (.a(a[8]),  .b(b[8]),  .y(y[8]));
    AND2 a9  (.a(a[9]),  .b(b[9]),  .y(y[9]));
    AND2 a10 (.a(a[10]), .b(b[10]), .y(y[10]));
    AND2 a11 (.a(a[11]), .b(b[11]), .y(y[11]));
    AND2 a12 (.a(a[12]), .b(b[12]), .y(y[12]));
    AND2 a13 (.a(a[13]), .b(b[13]), .y(y[13]));
    AND2 a14 (.a(a[14]), .b(b[14]), .y(y[14]));
    AND2 a15 (.a(a[15]), .b(b[15]), .y(y[15]));
    AND2 a16 (.a(a[16]), .b(b[16]), .y(y[16]));
    AND2 a17 (.a(a[17]), .b(b[17]), .y(y[17]));
    AND2 a18 (.a(a[18]), .b(b[18]), .y(y[18]));
    AND2 a19 (.a(a[19]), .b(b[19]), .y(y[19]));
    AND2 a20 (.a(a[20]), .b(b[20]), .y(y[20]));
    AND2 a21 (.a(a[21]), .b(b[21]), .y(y[21]));
    AND2 a22 (.a(a[22]), .b(b[22]), .y(y[22]));
    AND2 a23 (.a(a[23]), .b(b[23]), .y(y[23]));
    AND2 a24 (.a(a[24]), .b(b[24]), .y(y[24]));
    AND2 a25 (.a(a[25]), .b(b[25]), .y(y[25]));
    AND2 a26 (.a(a[26]), .b(b[26]), .y(y[26]));
    AND2 a27 (.a(a[27]), .b(b[27]), .y(y[27]));
    AND2 a28 (.a(a[28]), .b(b[28]), .y(y[28]));
    AND2 a29 (.a(a[29]), .b(b[29]), .y(y[29]));
    AND2 a30 (.a(a[30]), .b(b[30]), .y(y[30]));
    AND2 a31 (.a(a[31]), .b(b[31]), .y(y[31]));
endmodule


module OR2 (
    input wire a,
    input wire b,
    output wire y
);
    assign y = a | b;
endmodule

module OR32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);
    OR2 o0  (.a(a[0]),  .b(b[0]),  .y(y[0]));
    OR2 o1  (.a(a[1]),  .b(b[1]),  .y(y[1]));
    OR2 o2  (.a(a[2]),  .b(b[2]),  .y(y[2]));
    OR2 o3  (.a(a[3]),  .b(b[3]),  .y(y[3]));
    OR2 o4  (.a(a[4]),  .b(b[4]),  .y(y[4]));
    OR2 o5  (.a(a[5]),  .b(b[5]),  .y(y[5]));
    OR2 o6  (.a(a[6]),  .b(b[6]),  .y(y[6]));
    OR2 o7  (.a(a[7]),  .b(b[7]),  .y(y[7]));
    OR2 o8  (.a(a[8]),  .b(b[8]),  .y(y[8]));
    OR2 o9  (.a(a[9]),  .b(b[9]),  .y(y[9]));
    OR2 o10 (.a(a[10]), .b(b[10]), .y(y[10]));
    OR2 o11 (.a(a[11]), .b(b[11]), .y(y[11]));
    OR2 o12 (.a(a[12]), .b(b[12]), .y(y[12]));
    OR2 o13 (.a(a[13]), .b(b[13]), .y(y[13]));
    OR2 o14 (.a(a[14]), .b(b[14]), .y(y[14]));
    OR2 o15 (.a(a[15]), .b(b[15]), .y(y[15]));
    OR2 o16 (.a(a[16]), .b(b[16]), .y(y[16]));
    OR2 o17 (.a(a[17]), .b(b[17]), .y(y[17]));
    OR2 o18 (.a(a[18]), .b(b[18]), .y(y[18]));
    OR2 o19 (.a(a[19]), .b(b[19]), .y(y[19]));
    OR2 o20 (.a(a[20]), .b(b[20]), .y(y[20]));
    OR2 o21 (.a(a[21]), .b(b[21]), .y(y[21]));
    OR2 o22 (.a(a[22]), .b(b[22]), .y(y[22]));
    OR2 o23 (.a(a[23]), .b(b[23]), .y(y[23]));
    OR2 o24 (.a(a[24]), .b(b[24]), .y(y[24]));
    OR2 o25 (.a(a[25]), .b(b[25]), .y(y[25]));
    OR2 o26 (.a(a[26]), .b(b[26]), .y(y[26]));
    OR2 o27 (.a(a[27]), .b(b[27]), .y(y[27]));
    OR2 o28 (.a(a[28]), .b(b[28]), .y(y[28]));
    OR2 o29 (.a(a[29]), .b(b[29]), .y(y[29]));
    OR2 o30 (.a(a[30]), .b(b[30]), .y(y[30]));
    OR2 o31 (.a(a[31]), .b(b[31]), .y(y[31]));
endmodule

module NOR2 (
    input wire a,
    input wire b,
    output wire y
);
    wire or_out;

    OR2 u1 (
        .a(a),
        .b(b),
        .y(or_out)
    );

    NOT u2 (
        .x(or_out),
        .y(y)
    );
endmodule

module XOR2 (
    input  wire a,
    input  wire b,
    output wire y
);
    wire not_a;
    wire not_b;
    wire a_and_not_b;
    wire not_a_and_b;

    NOT n1 (
        .x(a),
        .y(not_a)
    );

    NOT n2 (
        .x(b),
        .y(not_b)
    );

    AND2 a1 (
        .a(a),
        .b(not_b),
        .y(a_and_not_b)
    );

    AND2 a2 (
        .a(not_a),
        .b(b),
        .y(not_a_and_b)
    );

    OR2 o1 (
        .a(a_and_not_b),
        .b(not_a_and_b),
        .y(y)
    );

endmodule


module XOR32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);
    XOR2 x0  (.a(a[0]),  .b(b[0]),  .y(y[0]));
    XOR2 x1  (.a(a[1]),  .b(b[1]),  .y(y[1]));
    XOR2 x2  (.a(a[2]),  .b(b[2]),  .y(y[2]));
    XOR2 x3  (.a(a[3]),  .b(b[3]),  .y(y[3]));
    XOR2 x4  (.a(a[4]),  .b(b[4]),  .y(y[4]));
    XOR2 x5  (.a(a[5]),  .b(b[5]),  .y(y[5]));
    XOR2 x6  (.a(a[6]),  .b(b[6]),  .y(y[6]));
    XOR2 x7  (.a(a[7]),  .b(b[7]),  .y(y[7]));
    XOR2 x8  (.a(a[8]),  .b(b[8]),  .y(y[8]));
    XOR2 x9  (.a(a[9]),  .b(b[9]),  .y(y[9]));
    XOR2 x10 (.a(a[10]), .b(b[10]), .y(y[10]));
    XOR2 x11 (.a(a[11]), .b(b[11]), .y(y[11]));
    XOR2 x12 (.a(a[12]), .b(b[12]), .y(y[12]));
    XOR2 x13 (.a(a[13]), .b(b[13]), .y(y[13]));
    XOR2 x14 (.a(a[14]), .b(b[14]), .y(y[14]));
    XOR2 x15 (.a(a[15]), .b(b[15]), .y(y[15]));
    XOR2 x16 (.a(a[16]), .b(b[16]), .y(y[16]));
    XOR2 x17 (.a(a[17]), .b(b[17]), .y(y[17]));
    XOR2 x18 (.a(a[18]), .b(b[18]), .y(y[18]));
    XOR2 x19 (.a(a[19]), .b(b[19]), .y(y[19]));
    XOR2 x20 (.a(a[20]), .b(b[20]), .y(y[20]));
    XOR2 x21 (.a(a[21]), .b(b[21]), .y(y[21]));
    XOR2 x22 (.a(a[22]), .b(b[22]), .y(y[22]));
    XOR2 x23 (.a(a[23]), .b(b[23]), .y(y[23]));
    XOR2 x24 (.a(a[24]), .b(b[24]), .y(y[24]));
    XOR2 x25 (.a(a[25]), .b(b[25]), .y(y[25]));
    XOR2 x26 (.a(a[26]), .b(b[26]), .y(y[26]));
    XOR2 x27 (.a(a[27]), .b(b[27]), .y(y[27]));
    XOR2 x28 (.a(a[28]), .b(b[28]), .y(y[28]));
    XOR2 x29 (.a(a[29]), .b(b[29]), .y(y[29]));
    XOR2 x30 (.a(a[30]), .b(b[30]), .y(y[30]));
    XOR2 x31 (.a(a[31]), .b(b[31]), .y(y[31]));
endmodule

module full_adder_1bit (
    input wire a,
    input wire b,
    input wire cin,
    output wire s,
    output wire cout
);
    wire a_xor_b;
    wire a_and_b;
    wire abcin_xor_and;

    XOR2 u1 (
        .a(a),
        .b(b),
        .y(a_xor_b)
    );

    XOR2 u2 (
        .a(a_xor_b),
        .b(cin),
        .y(s)
    );

    AND2 u3 (
        .a(a),
        .b(b),
        .y(a_and_b)
    );

    AND2 u4 (
        .a(a_xor_b),
        .b(cin),
        .y(abcin_xor_and)
    );

    OR2 u5 (
        .a(a_and_b),
        .b(abcin_xor_and),
        .y(cout)
    );
endmodule

module adder_32bit(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        cin,
    output wire [31:0] sum,
    output wire        cout
);

    wire [32:0] c;
    assign c[0] = cin;

    full_adder_1bit fa0  (.a(a[0]),  .b(b[0]),  .cin(c[0]),  .s(sum[0]),  .cout(c[1]));
    full_adder_1bit fa1  (.a(a[1]),  .b(b[1]),  .cin(c[1]),  .s(sum[1]),  .cout(c[2]));
    full_adder_1bit fa2  (.a(a[2]),  .b(b[2]),  .cin(c[2]),  .s(sum[2]),  .cout(c[3]));
    full_adder_1bit fa3  (.a(a[3]),  .b(b[3]),  .cin(c[3]),  .s(sum[3]),  .cout(c[4]));
    full_adder_1bit fa4  (.a(a[4]),  .b(b[4]),  .cin(c[4]),  .s(sum[4]),  .cout(c[5]));
    full_adder_1bit fa5  (.a(a[5]),  .b(b[5]),  .cin(c[5]),  .s(sum[5]),  .cout(c[6]));
    full_adder_1bit fa6  (.a(a[6]),  .b(b[6]),  .cin(c[6]),  .s(sum[6]),  .cout(c[7]));
    full_adder_1bit fa7  (.a(a[7]),  .b(b[7]),  .cin(c[7]),  .s(sum[7]),  .cout(c[8]));
    full_adder_1bit fa8  (.a(a[8]),  .b(b[8]),  .cin(c[8]),  .s(sum[8]),  .cout(c[9]));
    full_adder_1bit fa9  (.a(a[9]),  .b(b[9]),  .cin(c[9]),  .s(sum[9]),  .cout(c[10]));
    full_adder_1bit fa10 (.a(a[10]), .b(b[10]), .cin(c[10]), .s(sum[10]), .cout(c[11]));
    full_adder_1bit fa11 (.a(a[11]), .b(b[11]), .cin(c[11]), .s(sum[11]), .cout(c[12]));
    full_adder_1bit fa12 (.a(a[12]), .b(b[12]), .cin(c[12]), .s(sum[12]), .cout(c[13]));
    full_adder_1bit fa13 (.a(a[13]), .b(b[13]), .cin(c[13]), .s(sum[13]), .cout(c[14]));
    full_adder_1bit fa14 (.a(a[14]), .b(b[14]), .cin(c[14]), .s(sum[14]), .cout(c[15]));
    full_adder_1bit fa15 (.a(a[15]), .b(b[15]), .cin(c[15]), .s(sum[15]), .cout(c[16]));
    full_adder_1bit fa16 (.a(a[16]), .b(b[16]), .cin(c[16]), .s(sum[16]), .cout(c[17]));
    full_adder_1bit fa17 (.a(a[17]), .b(b[17]), .cin(c[17]), .s(sum[17]), .cout(c[18]));
    full_adder_1bit fa18 (.a(a[18]), .b(b[18]), .cin(c[18]), .s(sum[18]), .cout(c[19]));
    full_adder_1bit fa19 (.a(a[19]), .b(b[19]), .cin(c[19]), .s(sum[19]), .cout(c[20]));
    full_adder_1bit fa20 (.a(a[20]), .b(b[20]), .cin(c[20]), .s(sum[20]), .cout(c[21]));
    full_adder_1bit fa21 (.a(a[21]), .b(b[21]), .cin(c[21]), .s(sum[21]), .cout(c[22]));
    full_adder_1bit fa22 (.a(a[22]), .b(b[22]), .cin(c[22]), .s(sum[22]), .cout(c[23]));
    full_adder_1bit fa23 (.a(a[23]), .b(b[23]), .cin(c[23]), .s(sum[23]), .cout(c[24]));
    full_adder_1bit fa24 (.a(a[24]), .b(b[24]), .cin(c[24]), .s(sum[24]), .cout(c[25]));
    full_adder_1bit fa25 (.a(a[25]), .b(b[25]), .cin(c[25]), .s(sum[25]), .cout(c[26]));
    full_adder_1bit fa26 (.a(a[26]), .b(b[26]), .cin(c[26]), .s(sum[26]), .cout(c[27]));
    full_adder_1bit fa27 (.a(a[27]), .b(b[27]), .cin(c[27]), .s(sum[27]), .cout(c[28]));
    full_adder_1bit fa28 (.a(a[28]), .b(b[28]), .cin(c[28]), .s(sum[28]), .cout(c[29]));
    full_adder_1bit fa29 (.a(a[29]), .b(b[29]), .cin(c[29]), .s(sum[29]), .cout(c[30]));
    full_adder_1bit fa30 (.a(a[30]), .b(b[30]), .cin(c[30]), .s(sum[30]), .cout(c[31]));
    full_adder_1bit fa31 (.a(a[31]), .b(b[31]), .cin(c[31]), .s(sum[31]), .cout(c[32]));

    assign cout = c[32];

endmodule

module barrel_shifter_32bit (
    input wire [31:0] a,
    input wire [4:0] shamt,
    input wire [1:0] op,
    output reg [31:0] y
);
    
    function [31:0] shift_left;
        input [31:0] a_in;
        input [4:0] shamt_in;
        reg [31:0] tmp;
        begin
            tmp = a_in;
            if (shamt_in[0]) tmp = {tmp[30:0], 1'b0};
            if (shamt_in[1]) tmp = {tmp[29:0], 2'b00};
            if (shamt_in[2]) tmp = {tmp[27:0], 4'b0000};
            if (shamt_in[3]) tmp = {tmp[23:0], 8'b00000000};
            if (shamt_in[4]) tmp = {tmp[15:0], 16'b0000000000000000};
            shift_left = tmp;
        end
    endfunction

    function [31:0] shift_right_logical;
        input [31:0] a_in2;
        input [4:0] shamt_in2;
        reg [31:0] tmp;
        begin
            tmp = a_in2;
            if (shamt_in2[0]) tmp = {1'b0, tmp[31:1]};
            if (shamt_in2[1]) tmp = {2'b00, tmp[31:2]};
            if (shamt_in2[2]) tmp = {4'b0000, tmp[31:4]};
            if (shamt_in2[3]) tmp = {8'b00000000, tmp[31:8]};
            if (shamt_in2[4]) tmp = {16'b0000000000000000, tmp[31:16]};
            shift_right_logical = tmp;
        end
    endfunction

    function [31:0] shift_right_arith;
        input [31:0] a_in3;
        input [4:0] shamt_in3;
        reg [31:0] tmp;
        reg msb;
        begin
            tmp = a_in3;
            msb = a_in3[31];
            if (shamt_in3[0]) tmp = {msb, tmp[31:1]};
            if (shamt_in3[1]) tmp = {{2{msb}}, tmp[31:2]};
            if (shamt_in3[2]) tmp = {{4{msb}}, tmp[31:4]};
            if (shamt_in3[3]) tmp = {{8{msb}}, tmp[31:8]};
            if (shamt_in3[4]) tmp = {{16{msb}}, tmp[31:16]};
            shift_right_arith = tmp;
        end
    endfunction

    always @(*) begin
        case (op)
            2'b00: y = shift_left(a, shamt);          
            2'b01: y = shift_right_logical(a, shamt); 
            2'b10: y = shift_right_arith(a, shamt);
            default: y = 32'b0;
        endcase
    end

endmodule

module comparator_1bit (
    input wire a,
    input wire b,
    output wire lt,
    output wire eq
);
    wire not_a;
    wire not_b;

    NOT u1 (
        .x(a),
        .y(not_a)
    );

    NOT u2 (
        .x(b),
        .y(not_b)
    );


    AND2 u3 (
        .a(not_a),
        .b(b),
        .y(lt)
    );


    wire a_and_b;
    wire nota_and_notb;

    AND2 u4 (
        .a(a),
        .b(b),
        .y(a_and_b)
    );

    AND2 u5 (
        .a(not_a),
        .b(not_b),
        .y(nota_and_notb)
    );

    OR2 u6 (
        .a(a_and_b),
        .b(nota_and_notb),
        .y(eq)
    );

endmodule
module comparator_32bit (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire        lt, 
    output wire        eq, 
    output wire        gt 
);
    wire [31:0] bit_lt;
    wire [31:0] bit_eq;

    comparator_1bit c31 (.a(a[31]), .b(b[31]), .lt(bit_lt[31]), .eq(bit_eq[31]));
    comparator_1bit c30 (.a(a[30]), .b(b[30]), .lt(bit_lt[30]), .eq(bit_eq[30]));
    comparator_1bit c29 (.a(a[29]), .b(b[29]), .lt(bit_lt[29]), .eq(bit_eq[29]));
    comparator_1bit c28 (.a(a[28]), .b(b[28]), .lt(bit_lt[28]), .eq(bit_eq[28]));
    comparator_1bit c27 (.a(a[27]), .b(b[27]), .lt(bit_lt[27]), .eq(bit_eq[27]));
    comparator_1bit c26 (.a(a[26]), .b(b[26]), .lt(bit_lt[26]), .eq(bit_eq[26]));
    comparator_1bit c25 (.a(a[25]), .b(b[25]), .lt(bit_lt[25]), .eq(bit_eq[25]));
    comparator_1bit c24 (.a(a[24]), .b(b[24]), .lt(bit_lt[24]), .eq(bit_eq[24]));
    comparator_1bit c23 (.a(a[23]), .b(b[23]), .lt(bit_lt[23]), .eq(bit_eq[23]));
    comparator_1bit c22 (.a(a[22]), .b(b[22]), .lt(bit_lt[22]), .eq(bit_eq[22]));
    comparator_1bit c21 (.a(a[21]), .b(b[21]), .lt(bit_lt[21]), .eq(bit_eq[21]));
    comparator_1bit c20 (.a(a[20]), .b(b[20]), .lt(bit_lt[20]), .eq(bit_eq[20]));
    comparator_1bit c19 (.a(a[19]), .b(b[19]), .lt(bit_lt[19]), .eq(bit_eq[19]));
    comparator_1bit c18 (.a(a[18]), .b(b[18]), .lt(bit_lt[18]), .eq(bit_eq[18]));
    comparator_1bit c17 (.a(a[17]), .b(b[17]), .lt(bit_lt[17]), .eq(bit_eq[17]));
    comparator_1bit c16 (.a(a[16]), .b(b[16]), .lt(bit_lt[16]), .eq(bit_eq[16]));
    comparator_1bit c15 (.a(a[15]), .b(b[15]), .lt(bit_lt[15]), .eq(bit_eq[15]));
    comparator_1bit c14 (.a(a[14]), .b(b[14]), .lt(bit_lt[14]), .eq(bit_eq[14]));
    comparator_1bit c13 (.a(a[13]), .b(b[13]), .lt(bit_lt[13]), .eq(bit_eq[13]));
    comparator_1bit c12 (.a(a[12]), .b(b[12]), .lt(bit_lt[12]), .eq(bit_eq[12]));
    comparator_1bit c11 (.a(a[11]), .b(b[11]), .lt(bit_lt[11]), .eq(bit_eq[11]));
    comparator_1bit c10 (.a(a[10]), .b(b[10]), .lt(bit_lt[10]), .eq(bit_eq[10]));
    comparator_1bit c9  (.a(a[9]),  .b(b[9]),  .lt(bit_lt[9]),  .eq(bit_eq[9]));
    comparator_1bit c8  (.a(a[8]),  .b(b[8]),  .lt(bit_lt[8]),  .eq(bit_eq[8]));
    comparator_1bit c7  (.a(a[7]),  .b(b[7]),  .lt(bit_lt[7]),  .eq(bit_eq[7]));
    comparator_1bit c6  (.a(a[6]),  .b(b[6]),  .lt(bit_lt[6]),  .eq(bit_eq[6]));
    comparator_1bit c5  (.a(a[5]),  .b(b[5]),  .lt(bit_lt[5]),  .eq(bit_eq[5]));
    comparator_1bit c4  (.a(a[4]),  .b(b[4]),  .lt(bit_lt[4]),  .eq(bit_eq[4]));
    comparator_1bit c3  (.a(a[3]),  .b(b[3]),  .lt(bit_lt[3]),  .eq(bit_eq[3]));
    comparator_1bit c2  (.a(a[2]),  .b(b[2]),  .lt(bit_lt[2]),  .eq(bit_eq[2]));
    comparator_1bit c1  (.a(a[1]),  .b(b[1]),  .lt(bit_lt[1]),  .eq(bit_eq[1]));
    comparator_1bit c0  (.a(a[0]),  .b(b[0]),  .lt(bit_lt[0]),  .eq(bit_eq[0]));

    assign eq =
        bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] &
        bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] &
        bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] &
        bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] &
        bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] &
        bit_eq[11] & bit_eq[10] & bit_eq[9]  & bit_eq[8]  &
        bit_eq[7]  & bit_eq[6]  & bit_eq[5]  & bit_eq[4]  &
        bit_eq[3]  & bit_eq[2]  & bit_eq[1]  & bit_eq[0];

    assign lt =
        bit_lt[31] |
        (bit_eq[31] & bit_lt[30]) |
        (bit_eq[31] & bit_eq[30] & bit_lt[29]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_lt[28]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_lt[27]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_lt[26]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_lt[25]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_lt[24]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_lt[23]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_lt[22]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_lt[21]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_lt[20]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_lt[19]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_lt[18]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_lt[17]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_lt[16]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_lt[15]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_lt[14]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_lt[13]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_lt[12]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_lt[11]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_lt[10]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_lt[9]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_lt[8]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_eq[8] & bit_lt[7]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_eq[8] & bit_eq[7] & bit_lt[6]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_eq[8] & bit_eq[7] & bit_eq[6] & bit_lt[5]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_eq[8] & bit_eq[7] & bit_eq[6] & bit_eq[5] & bit_lt[4]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_eq[8] & bit_eq[7] & bit_eq[6] & bit_eq[5] & bit_eq[4] & bit_lt[3]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_eq[8] & bit_eq[7] & bit_eq[6] & bit_eq[5] & bit_eq[4] & bit_eq[3] & bit_lt[2]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_eq[8] & bit_eq[7] & bit_eq[6] & bit_eq[5] & bit_eq[4] & bit_eq[3] & bit_eq[2] & bit_lt[1]) |
        (bit_eq[31] & bit_eq[30] & bit_eq[29] & bit_eq[28] & bit_eq[27] & bit_eq[26] & bit_eq[25] & bit_eq[24] & bit_eq[23] & bit_eq[22] & bit_eq[21] & bit_eq[20] & bit_eq[19] & bit_eq[18] & bit_eq[17] & bit_eq[16] & bit_eq[15] & bit_eq[14] & bit_eq[13] & bit_eq[12] & bit_eq[11] & bit_eq[10] & bit_eq[9] & bit_eq[8] & bit_eq[7] & bit_eq[6] & bit_eq[5] & bit_eq[4] & bit_eq[3] & bit_eq[2] & bit_eq[1] & bit_lt[0]);

    wire not_lt;
    wire not_eq;

    NOT n1 (
        .x(lt),
        .y(not_lt)
    );

    NOT n2 (
        .x(eq),
        .y(not_eq)
    );

    AND2 a1 (
        .a(not_lt),
        .b(not_eq),
        .y(gt)
    );

endmodule

/* verilator lint_on UNOPTFLAT */