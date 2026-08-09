module fifo_mem #(
    parameter DEPTH=128,
    parameter DATA_WIDTH=8,
    parameter ADDR_WIDTH = $clog2(DEPTH)
    )(
    input w_clk,r_clk,rst,
    input w_en,r_en,
    input [ADDR_WIDTH-1:0] w_addr,
    input [ADDR_WIDTH-1:0] r_addr,
    input  [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
integer i;
always @(posedge w_clk or negedge rst) begin
    if(!rst) begin
        for(i=0;i<DEPTH;i=i+1) 
            mem[i]<= {DATA_WIDTH{1'b0}} ;
    end
    else begin
        if(w_en) 
            mem[w_addr]<= data_in; 
    end
end

always @(posedge r_clk) begin
    if(r_en)
        data_out <= mem[r_addr];
end
endmodule