// iverilog -o riscv_sim RISCV_TOP.v MUX_2_1.v ALU_CONTROL.v ALU.v REGISTER.v DATA_MEMORY.v INSTRUCTION_MEMORY.v DECODER.v CONTROL.v BRANCH_JUMP.v 

module RISCV_TOP (
    input iClk,
    input iRstN
);

    // =========================
    // Program Counter
    // =========================
    reg  [31:0] wPC;
    wire [31:0] wNextPC;
    wire [31:0] pc_plus4;

    assign pc_plus4 = wPC + 32'd4;

    always @(posedge iClk or negedge iRstN) begin
        if (!iRstN)
            wPC <= 32'd0;
        else
            wPC <= wNextPC;
    end

    // =========================
    // Instruction Fetch
    // =========================
    wire [31:0] wInstr;

    INSTRUCTION_MEMORY imem (
        .iRdAddr(wPC),
        .oInstr(wInstr)
    );

    // =========================
    // Decode
    // =========================
    wire [6:0]  opcode;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;

    DECODER decoder (
        .iInstr(wInstr),
        .oOpcode(opcode),
        .oRd(rd),
        .oFunct3(funct3),
        .oRs1(rs1),
        .oRs2(rs2),
        .oFunct7(funct7),
        .oImm(imm)
    );

    // =========================
    // Control
    // =========================
    wire        oLui, oPcSrc, oMemRd, oMemWr;
    wire        oMemtoReg, oAluSrc1, oAluSrc2;
    wire        oRegWrite, oBranch, oJump;
    wire [2:0]  oAluOp;

    CONTROL control (
        .iOpcode(opcode),
        .oLui(oLui),
        .oPcSrc(oPcSrc),
        .oMemRd(oMemRd),
        .oMemWr(oMemWr),
        .oAluOp(oAluOp),
        .oMemtoReg(oMemtoReg),
        .oAluSrc1(oAluSrc1),
        .oAluSrc2(oAluSrc2),
        .oRegWrite(oRegWrite),
        .oBranch(oBranch),
        .oJump(oJump)
    );

    // =========================
    // Register File
    // =========================
    wire [31:0] rs1Data, rs2Data;

    REGISTER register (
        .iClk(iClk),
        .iRstN(iRstN),
        .iWriteEn(oRegWrite),
        .iRdAddr(rd),
        .iRs1Addr(rs1),
        .iRs2Addr(rs2),
        .iWriteData(wb_to_reg),
        .oRs1Data(rs1Data),
        .oRs2Data(rs2Data)
    );

    // =========================
    // ALU Control
    // =========================
    wire [3:0] aluCtrl;

    ALU_CONTROL alu_control (
        .iAluOp(oAluOp),
        .iFunct3(funct3),
        .iFunct7(funct7),
        .oAluCtrl(aluCtrl)
    );

    // =========================
    // ALU Inputs
    // =========================
    wire [31:0] aluInA, aluInB;

    MUX_2_1 #(.WIDTH(32)) muxA (
        .iData0(rs1Data),
        .iData1(wPC),
        .iSel(oAluSrc1),
        .oData(aluInA)
    );

    MUX_2_1 #(.WIDTH(32)) muxB (
        .iData0(rs2Data),
        .iData1(imm),
        .iSel(oAluSrc2),
        .oData(aluInB)
    );

    // =========================
    // ALU
    // =========================
    wire [31:0] aluOut;
    wire        aluZero;

    ALU alu (
        .iDataA(aluInA),
        .iDataB(aluInB),
        .iAluCtrl(aluCtrl),
        .oData(aluOut),
        .oZero(aluZero)
    );

    // =========================
    // Data Memory
    // =========================
    wire [31:0] memReadData;

    DATA_MEMORY data_memory (
        .iClk(iClk),
        .iRstN(iRstN),
        .iAddress(aluOut),
        .iWriteData(rs2Data),
        .iFunct3(funct3),
        .iMemWrite(oMemWr),
        .iMemRead(oMemRd),
        .oReadData(memReadData)
    );

    // =========================
    // Writeback
    // =========================
    wire [31:0] wb_mux0_out;
    wire [31:0] wb_final;
    wire [31:0] wb_to_reg;

    MUX_2_1 #(.WIDTH(32)) muxWB0 (
        .iData0(aluOut),
        .iData1(memReadData),
        .iSel(oMemtoReg),
        .oData(wb_mux0_out)
    );

    MUX_2_1 #(.WIDTH(32)) muxWB1 (
        .iData0(wb_mux0_out),
        .iData1(imm),
        .iSel(oLui),
        .oData(wb_final)
    );

    // *** FIX: JAL / JALR write PC+4 ***
    MUX_2_1 #(.WIDTH(32)) muxWB_JUMP (
        .iData0(wb_final),
        .iData1(pc_plus4),
        .iSel(oJump),
        .oData(wb_to_reg)
    );

    // =========================
    // Branch / Jump
    // =========================
    BRANCH_JUMP branch_jump (
        .iBranch(oBranch),
        .iJump(oJump),
        .iZero(aluZero),
        .iOffset(imm),
        .iPc(wPC),
        .iRs1(rs1Data),
        .iPcSrc(oPcSrc),
        .oPc(wNextPC)
    );

endmodule