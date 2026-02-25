module INSTRUCTION_MEMORY (
    input  [31:0] iRdAddr,
    output [31:0] oInstr
);

    // Simple ROM for instructions (word addressed)
    reg [31:0] imem [0:255];

    assign oInstr = imem[iRdAddr[31:2]];

endmodule