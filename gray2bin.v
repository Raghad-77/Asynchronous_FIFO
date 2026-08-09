module gray2bin#(parameter PTR_WIDTH = 8)(
    input [PTR_WIDTH-1:0] gray,
    output reg [PTR_WIDTH-1:0] bin
);

integer i;
always @(*)
begin
    bin[PTR_WIDTH-1] = gray[PTR_WIDTH-1];
    for(i = PTR_WIDTH-2; i >= 0; i = i - 1)
        bin[i] = bin[i+1] ^ gray[i];
end
endmodule