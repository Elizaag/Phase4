module BRANCH_JUMP (
    input iBranch,
    input iJump,
    input iZero,
    input [31:0] iOffset,
    input [31:0] iPc,
    input [31:0] iRs1,
    input iPcSrc,
    output reg [31:0] oPc // this was not reg before
);

//Working through my own logic and research 
//assign iPc = iRs1 + iPcSrc; 
  
//assign oPc = iOffset + iPc;
/************************************************************/
//Branches are relative addresses (target PC + offset)

//assign iBranch = oPc + iOffset;

//Jump uses absolute addresses - Target address = RS1 + 32 Bit offset

//assign iJump = iRs1 + iOffset; 


    always @(*) begin

        if (iJump) begin

            if (iPcSrc)
                //JALR: rs1 + offset  | JAL: PC + offset
                //oPc = iRs1 + iOffset;
                oPc = (iRs1 + iOffset) & 32'hFFFFFFFE;
            else
                oPc = iPc + iOffset; //JAL
        end 

        else if (iBranch && iZero) begin
            //ALU branch, PC and offset 
            oPc = iPc + iOffset;
        end

        else begin
            oPc = iPc + 32'd4;
        end

    end

endmodule