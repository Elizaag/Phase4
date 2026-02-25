module TOP (
    input iClk,
    input iRstN
);

    // PC wires
    wire [31:0] pc_cur;
    wire [31:0] pc_next;

    // Instruction 
    wire [31:0] instr;

    // Decoder outputs
    wire [6:0]  opcode;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;

    // Control signals
    wire oLui, oPcSrc, oMemRd, oMemWr;
    wire oMemtoReg, oAluSrc1, oAluSrc2;
    wire oRegWrite, oBranch, oJump;
    wire oAluOp;

    // Register wires
    wire [31:0] rs1Data, rs2Data;
    wire [31:0] regWriteData;

    // ALU wires
    wire [3:0] aluCtrl;
    wire [31:0] aluInA, aluInB, aluOut;
    wire aluZero;

    // Data memory
    wire [31:0] memReadData;

    wire [31:0] wb_mux0_out;
    wire [31:0] wb_final;

 
    // PC REGISTER
    PC_REG pc0 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iNext(pc_next),
        .oPC(pc_cur)
    );


    // INSTRUCTION MEMORY
    INSTRUCTION_MEMORY imem (
        .iRdAddr(pc_cur),
        .oInstr(instr)
    );


    // DECODER
    DECODER dec0 (
        .iInstr(instr),
        .oOpcode(opcode),
        .oRd(rd),
        .oFunct3(funct3),
        .oRs1(rs1),
        .oRs2(rs2),
        .oFunct7(funct7),
        .oImm(imm)
    );

    // CONTROL
    CONTROL ctrl0 (
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

    // REGISTER FILE
    REGISTER reg0 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iWriteEn(oRegWrite),
        .iReadEnS1(1'b1),
        .iReadEnS2(1'b1),
        .iRdAddr(rd),
        .iRs1Addr(rs1),
        .iRs2Addr(rs2),
        .iWriteData(wb_final),
        .oRs1Data(rs1Data),
        .oRs2Data(rs2Data)
    );

    // ALU CONTROL
    ALU_CONTROL alucontrol0 (
        .iAluOp({2'b00, oAluOp}),
        .iFunct3(funct3),
        .iFunct7(funct7),
        .oAluCtrl(aluCtrl)
    );

    // ALU INPUT MUXES
    MUX_2_1 #(.WIDTH(32)) muxA (
        .iData0(rs1Data),
        .iData1(pc_cur),
        .iSel(oAluSrc1),
        .oData(aluInA)
    );

    MUX_2_1 #(.WIDTH(32)) muxB (
        .iData0(rs2Data),
        .iData1(imm),
        .iSel(oAluSrc2),
        .oData(aluInB)
    );

    // ALU
    ALU alu0 (
        .iDataA(aluInA),
        .iDataB(aluInB),
        .iAluCtrl(aluCtrl),
        .oData(aluOut),
        .oZero(aluZero)
    );

    // DATA MEMORY
    DATA_MEMORY dmem0 (
        .iAddress(aluOut),
        .iWriteData(rs2Data),
        .iFunct3(funct3),
        .iMemWrite(oMemWr),
        .iMemRead(oMemRd),
        .oReadData(memReadData)
    );

    // WRITEBACK MUXES
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

    // BRANCH JUMP UNIT
    BRANCH_JUMP bj0 (
        .iBranch(oBranch),
        .iJump(oJump),
        .iZero(aluZero),
        .iOffset(imm),
        .iPc(pc_cur),
        .iRs1(rs1Data),
        .iPcSrc(oPcSrc),
        .oPc(pc_next)
    );

endmodule


// PC REGISTER (keeps TOP structural)
module PC_REG (
    input iClk,
    input iRstN,
    input [31:0] iNext,
    output reg [31:0] oPC
);
    always @(posedge iClk or negedge iRstN) begin
        if (!iRstN)
            oPC <= 32'd0;
        else
            oPC <= iNext;
    end
endmodule