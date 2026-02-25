module MUX_2_1 #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] iData0,
    input [WIDTH-1:0] iData1,
    input iSel,
    output reg [WIDTH-1:0] oData
);

    always @(*) begin //originally had always @(iData0 or iData1 or iSel)
        if (iSel) 
            oData = iData1;
        else
            oData = iData0;
    end

endmodule