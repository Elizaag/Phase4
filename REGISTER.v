// Register module definition
module REGISTER (
    input iClk,              // Clock input
    input iRstN,             // Active low reset input
    input iWriteEn,          // Write enable input
    input [4:0] iRdAddr,     // 5 bit register address input
    input [4:0] iRs1Addr,    // 5 bit source register 1 address input
    input [4:0] iRs2Addr,    // 5 bit source register 2 address input
    input [31:0] iWriteData, // 32 bit data input to store in register
    output [31:0] oRs1Data,  // 32 bit source register 1 data output
    output [31:0] oRs2Data   // 32 bit source register 2 data output
);

//create 32 registers that are each 32 bits wide
reg [31:0] registers [31:0];

integer i;

    always @(posedge iClk or negedge iRstN) begin
        if (!iRstN) begin
            // Reset logic: Initialize registers to zero
            //loops for all 32 registers and sets all 32 bits in each to 0
            
	        for (i = 0; i < 32; i = i + 1)
	        begin
	            registers [i] <= 32'b0;
	        end
	        

        end else begin
            // Read / Write logic
            //checks if write enabler is set to 1 and the register address is not x0, which is always 0 and cannot be altered
            if (iWriteEn && iRdAddr != 0)
            begin
                //iRdAddr is 5 bits. that means it's a number that ranges from 0-31 which fits perfectly with the number of registers we have here
                registers [iRdAddr] <= iWriteData;
            end
        end
    end

assign oRs1Data = (iRs1Addr != 0) ? registers[iRs1Addr] : 32'b0;
assign oRs2Data = (iRs2Addr != 0) ? registers[iRs2Addr] : 32'b0;    

endmodule