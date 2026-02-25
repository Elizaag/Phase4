// oLui
// controls where register write data comes from for LUI instructions
// 1 = write upper immediate to the register
// 0 = write the ALU or memory result to the register
// ---------------------------------------------------
// oPcSrc
// selects the base address used to compute the next PC. used for JALR and some branch instructions
// 0 = use current PC
// 1 = use a register value (typically rs1)
// ---------------------------------------------------
// oMemRd
// enables reading from data memory. used for load instructions (LW, etc)
// 1 = read memory
// 0 = don't read memory
// ---------------------------------------------------
// oMemWr
// enables writing from data memory. used for store instructions (SW, etc)
// 1 = write to memory
// 0 = don't write to memory
// ---------------------------------------------------
// oAluOp
// tells the ALU Control Unit whether this instruction needs funct3 and/or funct7 to be decoded
// 0 = simple ALU behavior
// 1 = fully decoded ALU behavior
// ---------------------------------------------------
// oMemtoReg
// selects what gets written back to the register file. Used for loads (LW). Disabled for arithmetic instructions
// 0 = ALU result
// 1 = memory data
// ---------------------------------------------------
// oAluSrc1
// selects ALU operand 1 (used for PC-relative instructions like branches, jumps, AUIPC)
// 0 = rs1
// 1 = PC
// ---------------------------------------------------
// oAluSrc2
// selects ALU operand 2 (used for I-types, loads/stores, branch offset)
// 0 = rs2
// 1 = immediate value
// ---------------------------------------------------
// oRegWrite
// enables writing to the register file (used by arithmetic instr, loads, jumps)
// 1 = write result into destination register
// 0 = no register write
// ---------------------------------------------------
// oBranch
// enables conditional branching (used by BEQ, BLT, BLTU, etc)
// 1 = instruction is conditional branch
// 0 = instruction is not conditional branch
// ---------------------------------------------------
// oJump
// enables unconditional jumps
// 1 = instruction is unconditional jump
// 0 = instruction is not unconditional jump
// ---------------------------------------------------

module CONTROL (
    input [6:0] iOpcode,
    output oLui,
    output oPcSrc,
    output oMemRd,
    output oMemWr,
    output oAluOp,
    output oMemtoReg,
    output oAluSrc1,
    output oAluSrc2,
    output oRegWrite,
    output oBranch,
    output oJump
);

    // internal control registers
    reg rLui;
    reg rPcSrc;
    reg rMemRd;
    reg rMemWr;
    reg rAluOp;
    reg rMemtoReg;
    reg rAluSrc1;
    reg rAluSrc2;
    reg rRegWrite;
    reg rBranch;
    reg rJump;

    // drive outputs
    assign oLui = rLui;
    assign oPcSrc = rPcSrc;
    assign oMemRd = rMemRd;
    assign oMemWr = rMemWr;
    assign oAluOp = rAluOp;
    assign oMemtoReg = rMemtoReg;
    assign oAluSrc1 = rAluSrc1;
    assign oAluSrc2 = rAluSrc2;
    assign oRegWrite = rRegWrite;
    assign oBranch = rBranch;
    assign oJump = rJump;

    always @(*) begin
        // set all flags to 0 by default
        rLui = 0;
        rPcSrc = 0;
        rMemRd = 0;
        rMemWr = 0;
        rAluOp = 0;
        rMemtoReg = 0;
        rAluSrc1 = 0;
        rAluSrc2 = 0;
        rRegWrite = 0;
        rBranch = 0;
        rJump = 0;

        case(iOpcode)

            // r-type register arithmetic (ALU)
            7'b0110011: begin
                rAluOp = 1;
                rRegWrite = 1;
            end

            // i-type immediate arithmetic (ALU)
            7'b0010011: begin
                rAluOp = 1;
                rAluSrc2 = 1;
                rRegWrite = 1;
            end

            // load instructions
            7'b0000011: begin
                rMemRd = 1;
                rMemtoReg = 1;
                rAluSrc2 = 1;
                rRegWrite = 1;
            end

            // store instructions
            7'b0100011: begin
                rMemWr = 1;
                rAluSrc2 = 1;
            end

            // conditional branch instructions
            7'b1100011: begin
                rBranch = 1;
                rAluOp = 1;
            end

            // JAL
            7'b1101111: begin
                rJump = 1;
                rRegWrite = 1;
                rAluSrc1 = 1;
                rAluSrc2 = 1;
            end

            // JALR
            7'b1100111: begin
                rJump = 1;
                rPcSrc = 1;
                rAluSrc2 = 1;
                rRegWrite = 1;
            end

            // LUI
            7'b0110111: begin
                rLui = 1;
                rRegWrite = 1;
            end

            // AUIPC
            7'b0010111: begin
                rAluSrc1 = 1;
                rAluSrc2 = 1;
                rRegWrite = 1;
            end

            default: begin
                // Unsupported opcode
            end

        endcase

    end  

endmodule