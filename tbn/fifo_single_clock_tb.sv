
`timescale 1ns / 1ps
module fifo_single_clock_tb;
    parameter real FREQ  = 300.0            ; // MHZ
    parameter real CYCLE = 1.0 * 1000.0/FREQ;
    parameter int unsigned DEPTH = 32 ;
    parameter int unsigned DW = 32 ;

    /*------------------------------------------------------------------------------
    --   Signals declaration
    ------------------------------------------------------------------------------*/
    bit clk_i;
    bit srst_i;
    bit valid_i;
    bit [DW-1:0] data_i;
    logic valid_o;
    logic [DW-1:0] data_o;
    bit req_i;
    logic overflow_o;
    logic underflow_o;
    logic full_o;
    logic empty_o;
    logic [$clog2(DEPTH)-1:0] count_o;

    /*------------------------------------------------------------------------------
    --  DUT
    ------------------------------------------------------------------------------*/

    fifo_single_clock #(.DEPTH(DEPTH), .DW(DW)) i_fifo_single_clock (
        .clk_i      (clk_i      ),
        .srst_i     (srst_i     ),

        .valid_i    (valid_i    ),
        .data_i     (data_i     ),

        .valid_o    (valid_o    ),
        .data_o     (data_o     ),
        .req_i      (req_i      ),

        .overflow_o (overflow_o ),
        .underflow_o(underflow_o),
        .full_o     (full_o     ),
        .empty_o    (empty_o    ),
        .count_o    (count_o    )
    );


    /*------------------------------------------------------------------------------
    --  TASKS
    ------------------------------------------------------------------------------*/
    task automatic cycles(input int number, ref bit clk,input real time_cycle);
        repeat (number) @(posedge clk) #(time_cycle/10.0);
    endtask : cycles


    /*------------------------------------------------------------------------------
    --   Behavior
    ------------------------------------------------------------------------------*/
    always #(CYCLE/2.0) clk_i = !clk_i  ;

    initial begin
        srst_i = 1;
        cycles(5,clk_i,CYCLE);
        srst_i = 0;
        cycles(5,clk_i,CYCLE);

        /*------------------------------------------------------------------------------
        --  testing overflow
        ------------------------------------------------------------------------------*/
        repeat ( 30 ) begin
            valid_i = 1;
            cycles(1,clk_i,CYCLE);
        end
        valid_i = 0;

        repeat ( 20 ) begin
            req_i = 1 ;
            cycles(1,clk_i,CYCLE);
        end
        req_i = 0;

        repeat ( 30 ) begin
            valid_i = 1;
            cycles(1,clk_i,CYCLE);
        end

        cycles(100,clk_i,CYCLE);

        /*------------------------------------------------------------------------------
        --  Testing underflow
        ------------------------------------------------------------------------------*/
        valid_i = 0;
        srst_i = 1;
        cycles(5,clk_i,CYCLE);
        srst_i = 0;
        cycles(5,clk_i,CYCLE);

        repeat ( 30 ) begin
            valid_i = 1;
            cycles(1,clk_i,CYCLE);
        end
        valid_i = 0;

        repeat ( 40 ) begin
            req_i = 1 ;
            cycles(1,clk_i,CYCLE);
        end
        req_i = 0;

        $stop ;
    end
endmodule