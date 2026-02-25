module ALU_CONTROL (
    input [2:0] iAluOp,
    input [2:0] iFunct3,
    input [6:0] iFunct7,
    output [3:0] oAluCtrl
);

    // ALU operation
    localparam ADD = 4'b0000;
    localparam SUB = 4'b1000;
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

    always @(*) begin
        case (iAluOp)
            3'b000: oAluCtrl = ADD; //for LW, SW, ADDI
            3'b001: begin //branches
                case (iFunct3)
                    3'b000: oAluCtrl = SUB; //BEQ
                    3'b001: oAluCtrl = BNE; //BNE
                    3'b100: oAluCtrl = BLT; //BLT
                    3'b101: oAluCtrl = BGE; //BGE
                    default: oAluCtrl = ADD; //default fallback
                endcase
            end
            3'b010: begin //R-type instructions
                case (iFunct3)
                    3'b000: oAluCtrl = (iFunct7[5] ? SUB : ADD); //ADD / SUB
                    3'b001: oAluCtrl = SLL; //SLL
                    3'b010: oAluCtrl = SLT; //SLT
                    3'b011: oAluCtrl = SLTU; //SLTU
                    3'b100: oAluCtrl = XOR; //XOR
                    3'b101: oAluCtrl = (iFunct7[5] ? SRA : SRL); //SRL / SRA
                    3'b110: oAluCtrl = OR; //OR
                    3'b111: oAluCtrl = AND; //AND
                    default: oAluCtrl = ADD;
                endcase
            end
            default: oAluCtrl = ADD;
        endcase
    end

endmodule