module synchronizer#(parameter WIDTH=8)(
    input clk,rstn,
    input [WIDTH-1:0] in,
    output  reg [WIDTH-1:0]gray_ptr_out
);
reg [WIDTH-1:0] sync_ff1;

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        sync_ff1 <= 0;
        gray_ptr_out <= 0;
    end
    else
    begin
        sync_ff1     <= in;
        gray_ptr_out <= sync_ff1;
    end
end

endmodule