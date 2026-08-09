`timescale 1ns/1ps
module tb;

parameter DATA_WIDTH = 8;
parameter DEPTH      = 128;
parameter BURST      = 120;  // > 120 burst size, so FIFO never fills
parameter ADDR_WIDTH = 3;

reg w_clk, r_clk;
reg rst;    
reg w_en, r_en;
reg  [DATA_WIDTH-1:0]data_in;
wire [DATA_WIDTH-1:0]data_out;
wire FF, EF;

integer pass_count, fail_count;
integer i;
reg [DATA_WIDTH-1:0] mem_model [0:BURST-1];

async_fifo #(
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH)
) dut (
    .w_clk(w_clk),
    .r_clk(r_clk),
    .w_rst(rst),
    .r_rst(rst),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .EF (EF),
    .FF(FF)
);

// 60 MHz write clock
initial w_clk = 0;
always #8.333 w_clk = ~w_clk;

// 10 MHz read clock
initial r_clk = 0;
always #50 r_clk = ~r_clk;

task check(input [DATA_WIDTH-1:0] expected, input [DATA_WIDTH-1:0] actual);
    begin
        $display("data_out=%0d  EF=%b  FF=%b",data_out, EF, FF);
        if (expected === actual)
            pass_count=pass_count+1;
        else
            fail_count=fail_count + 1;
    end
endtask

initial begin
    pass_count=0;
    fail_count=0;

    w_en=0;
    r_en=0;
    data_in=0;
    rst=0;

    #20 rst=1;
    //test case 1: read while empty 
    @(posedge r_clk);
    #1 r_en = 1;
    @(posedge r_clk);
    #1;
    $display("testing to read while empty");
    check(1'b1, EF);   // expect empty flag still set, read had no effect
    r_en = 0;
    //write

    @(posedge w_clk);
    for (i = 0; i < BURST; i = i + 1) begin
        #1;
        if (!FF) begin
            data_in    = i;
            mem_model[i] = i;
            w_en       = 1;
        end
        @(posedge w_clk);
    end
    #1 w_en = 0;

    // fill remaining slots to reach FULL
    @(posedge w_clk);
    for (i = 0; i < (DEPTH - BURST); i = i + 1) begin
        #1;
        if (!FF) begin
            data_in = 8'hFF;
            w_en    = 1;
        end
        @(posedge w_clk);
    end
    #1 w_en = 0;

     //test case 2: write while full 
    @(posedge w_clk);
    #1;
    data_in = 8'hAA;
    w_en    = 1;
    @(posedge w_clk);
    #1;
    $display("testing to write while full");
    check(1'b1, FF);   // expect full flag still set, write had no effect
    w_en = 0;

    repeat (5) @(posedge r_clk);

    // read
    @(posedge r_clk);
    for (i = 0; i < BURST; i = i + 1) begin
        #1;
        if (!EF)
            r_en = 1;
        @(posedge r_clk);
        #1;
        $display("testing read-back of written data at index %0d", i);
        check(mem_model[i], data_out);
    end
    #1 r_en = 0;

     // test case 3: read and write simultaneously
    @(posedge w_clk);
    data_in = 8'h55;
    w_en = 1;
    r_en= 1;
    repeat (200) @(posedge w_clk);  
    w_en = 0;
    r_en = 0;
    #1;
    $display("testing simultaneous read and write, expecting FIFO to fill since writes outpace reads");
    check(1'b1, FF);

    $display("PASS = %0d  FAIL = %0d", pass_count, fail_count);
    $stop;
end

endmodule