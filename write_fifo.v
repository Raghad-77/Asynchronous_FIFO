module write_fifo #(parameter DEPTH=128, parameter ADDR_WIDTH = $clog2(DEPTH))(
   input w_clk,            
   input w_rstn,
   input w_inc, // write control signal 
   input [ADDR_WIDTH:0] sync_rd_ptr,        // synced gray coded read pointer         
   output [ADDR_WIDTH-1:0] w_addr,             // generated binary write address
   output reg [ADDR_WIDTH:0]gray_w_ptr,         // generated gray coded write address [registered]
   output wire FF
);

localparam PTR_WIDTH = ADDR_WIDTH + 1;
reg [PTR_WIDTH-1:0]  w_ptr;
wire [PTR_WIDTH-1:0]  gray_w_next;
wire [PTR_WIDTH-1:0] sync_rd_bin_ptr;

// increment binary pointer
always @(posedge w_clk or negedge w_rstn)
 begin
  if(!w_rstn)
    w_ptr <= 0 ;
 else if (!FF && w_inc)
    w_ptr <= w_ptr + 1 ;
 end

bin2gray #(PTR_WIDTH)gray(w_ptr,gray_w_next);
gray2bin #(PTR_WIDTH)bin(sync_rd_ptr,sync_rd_bin_ptr);

assign w_addr = w_ptr[ADDR_WIDTH-1:0]; // generation of write address

// converting binary write pointer to gray coded
always @(posedge w_clk or negedge w_rstn)
 begin
  if(!w_rstn)
    gray_w_ptr <= 0 ;
 else
   gray_w_ptr <= gray_w_next;
 end


//assign FF = (w_ptr=={sync_rd_bin_ptr[PTR_WIDTH-1],sync_rd_bin_ptr[PTR_WIDTH-2:0]});
assign FF = (w_ptr[PTR_WIDTH-1] != sync_rd_bin_ptr[PTR_WIDTH-1]) &&
            (w_ptr[PTR_WIDTH-2:0] == sync_rd_bin_ptr[PTR_WIDTH-2:0]);
endmodule

