module bin2gray#(parameter PTR_WIDTH = 8)(
    input [PTR_WIDTH-1:0]bin,
    output [PTR_WIDTH-1:0]gray
);
assign gray=bin^(bin >> 1);
endmodule