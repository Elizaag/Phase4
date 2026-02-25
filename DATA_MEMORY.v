module DATA_MEMORY (
    input iClk,
    input iRstN,
    input [31:0] iAddress,
    input [31:0] iWriteData,
    input [2:0] iFunct3,
    input iMemWrite,
    input iMemRead,
    output [31:0] oReadData
);

    localparam B = 8;
    localparam K = 1024;
    
    reg [B-1:0] rDataMem [0:(K*4)-1]; // 4KB data memory, byte-addressable

    initial begin
        $readmemh("data.txt", rDataMem);
    end

    //write
    always @(posedge iClk) begin
        if (iMemWrite) begin
            case (iFunct3)
                3'b000: begin //SB (store byte)
                    rDataMem[iAddress] <= iWriteData[7:0];
                end

                3'b001: begin //SH (store halfword)
                    rDataMem[iAddress] <= iWriteData[7:0];
                    rDataMem[iAddress + 1] <= iWriteData[15:8];
                end

                3'b010: begin //SW (store word)
                    rDataMem[iAddress] <= iWriteData[7:0];
                    rDataMem[iAddress + 1] <= iWriteData[15:8];
                    rDataMem[iAddress + 2] <= iWriteData[23:16];
                    rDataMem[iAddress + 3] <= iWriteData[31:24];
                end

                default: begin
                    //do nothing
                end
            endcase
        end
    end

    //read
    always @(*) begin
        if (iMemRead) begin
            case (iFunct3)

                3'b000: begin //LB (load byte, sign-extend)
                    oReadData = {{24{rDataMem[iAddress][7]}}, rDataMem[iAddress]};
                end

                3'b001: begin //LH (load halfword, sign-extend)
                    oReadData = {{16{rDataMem[iAddress+1][7]}},
                                 rDataMem[iAddress+1],
                                 rDataMem[iAddress]};
                end

                3'b010: begin //LW (load word)
                    oReadData = {rDataMem[iAddress+3],
                                 rDataMem[iAddress+2],
                                 rDataMem[iAddress+1],
                                 rDataMem[iAddress]};
                end

                3'b100: begin //LBU (load byte, zero-extend)
                    oReadData = {24'b0, rDataMem[iAddress]};
                end

                3'b101: begin //LHU (load halfword, zero-extend)
                    oReadData = {16'b0,
                                 rDataMem[iAddress+1],
                                 rDataMem[iAddress]};
                end

                default: begin
                    oReadData = 32'b0;
                end

            endcase
        end
        else begin
            oReadData = 32'b0;
        end
    end

endmodule