// DECODER module definition
module DECODER (
    input [31:0] iInstr, // 32 bit instruction input

    output [6:0] oOpcode, // 7 bit opcode output (all types)
    output [4:0] oRd,     // 5 bit destination register output (R, I, U, J)
    output [2:0] oFunct3, // 3 bit function output (R, I, S, B)
    output [4:0] oRs1,    // 5 bit source register (R, I, S, B)
    output [4:0] oRs2,    // 5 bit source register (R, S, B)
    output [6:0] oFunct7, // 7 bit function output (R)
    output reg [31:0] oImm // 32 bit immediate output (I, S, B, U, J)
);

    // Basic bitfield extraction 
    assign oOpcode = iInstr[6:0];    // The first 7 bits [cite: 46, 47]
    assign oRd     = iInstr[11:7];   // The destination register [cite: 46, 47]
    assign oFunct3 = iInstr[14:12];  // Small code for math type [cite: 46, 47]
    assign oRs1    = iInstr[19:15];  // The first source register [cite: 46, 47]
    assign oRs2    = iInstr[24:20];  // The second source register [cite: 46, 47]
    assign oFunct7 = iInstr[31:25];  // Extra code for R-type math [cite: 46, 47]

    // Immediate generation based on Opcode [cite: 55]
    always @(*) begin
        case (oOpcode)
            // I-type  [cite: 36]
            7'b0010011,
	    7'b0000011,
	    7'b1100111:
	    begin
                oImm = {{20{iInstr[31]}}, iInstr[31:20]};
            end

            // S-type [cite: 47]
            7'b0100011: begin
                oImm = {{20{iInstr[31]}}, iInstr[31:25], iInstr[11:7]};
            end

            // B-type resorting the scrambled bits into the correct order  [cite: 49, 53]
            7'b1100011: begin
                oImm = {{19{iInstr[31]}}, iInstr[31], iInstr[7], iInstr[30:25], iInstr[11:8], 1'b0};
            end

            // U-type [cite: 47, 51]
            7'b0110111, 7'b0010111: begin
                oImm = {iInstr[31:12], 12'b0};
            end

            // J-type resorting the scrambled bits into the correct order  [cite: 47, 51]
	    7'b1101111: begin
                oImm = {{11{iInstr[31]}}, iInstr[31], iInstr[19:12], iInstr[20], iInstr[30:21], 1'b0};
            end

            // Default for R-type or unknown opcodes [cite: 12]
            default: begin
                oImm = 32'b0;
            end
        endcase
    end

endmodule
