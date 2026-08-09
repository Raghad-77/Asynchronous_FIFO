module async_fifo#(
    parameter DEPTH=128,
    parameter DATA_WIDTH=8,
    parameter ADDR_WIDTH = $clog2(DEPTH)
    )(
    input w_clk,r_clk,
    input w_rst,r_rst,
    input w_en,r_en,
    input  [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire EF,FF
);
localparam PTR_WIDTH = ADDR_WIDTH + 1;

wire [ADDR_WIDTH-1:0] w_addr, r_addr;
wire [PTR_WIDTH-1:0] sync_rd_ptr, sync_wr_ptr;
wire [PTR_WIDTH-1:0] gray_rd_ptr, gray_wr_ptr;

wire w_en_valid = w_en & ~FF;

fifo_mem #(DEPTH,DATA_WIDTH,ADDR_WIDTH)mem(w_clk,r_clk,w_rst,w_en_valid,
r_en,w_addr,r_addr,data_in,data_out);

write_fifo #(DEPTH,ADDR_WIDTH)w(w_clk,w_rst,w_en,sync_rd_ptr,w_addr,gray_wr_ptr,FF);

read_fifo #(DEPTH,ADDR_WIDTH)r(r_clk,r_rst,r_en,sync_wr_ptr,r_addr,gray_rd_ptr,EF);

synchronizer #(PTR_WIDTH)synch1(r_clk,r_rst,gray_wr_ptr,sync_wr_ptr);

synchronizer #(PTR_WIDTH)synch2(w_clk,w_rst,gray_rd_ptr,sync_rd_ptr);


endmodule