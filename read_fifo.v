module read_fifo#(parameter DEPTH=128, parameter ADDR_WIDTH = $clog2(DEPTH))(
    input r_clk,    
    input r_rstn,  //active low reset 
    input r_inc,   // read control signal 
    input  [ADDR_WIDTH:0]sync_wr_ptr,     // synced gray coded write pointer         
    output wire [ADDR_WIDTH-1:0]rd_addr,   // generated binary read address
    output reg [ADDR_WIDTH:0]gray_rd_ptr, 
    output wire EF
);

localparam PTR_WIDTH  = ADDR_WIDTH + 1;
reg  [PTR_WIDTH-1:0] rd_ptr;
wire [PTR_WIDTH-1:0] gray_rd_next;
wire [PTR_WIDTH-1:0] sync_wr_bin_ptr;

always @(posedge r_clk or negedge r_rstn)
 begin
  if(!r_rstn)
    rd_ptr <= 0 ;
 else if (!EF && r_inc)
    rd_ptr <= rd_ptr + 1 ;
 end
 
bin2gray #(PTR_WIDTH)gray(rd_ptr,gray_rd_next);
gray2bin #(PTR_WIDTH)bin(sync_wr_ptr,sync_wr_bin_ptr);

assign rd_addr = rd_ptr[ADDR_WIDTH-1:0] ; // generation of read address

// converting binary read pointer to gray coded
always @(posedge r_clk or negedge r_rstn)
begin
 if(!r_rstn)
    gray_rd_ptr <= 0 ;
 else 
   gray_rd_ptr <= gray_rd_next;
 end

assign EF = (sync_wr_bin_ptr == rd_ptr) ;

endmodule
