`timescale 1ns / 1ps
module toggle_synchronizer_tb;
    parameter real FREQA  = 500.0 ; // MHZ
    parameter real FREQB  = 50.0 ; // MHZ

    parameter real CYCLEA = 1.0 * 1000.0/FREQA;
    parameter real CYCLEB = 1.0 * 1000.0/FREQB;


/*------------------------------------------------------------------------------
--   Signals declaration
------------------------------------------------------------------------------*/



    bit clka_i;
    bit data_i;
    bit clkb_i;
    logic data_o;
    bit arst_n_i = 1;

/*------------------------------------------------------------------------------
--  DUT
------------------------------------------------------------------------------*/

toggle_synchronizer_alt i_toggle_syncronizer (.clka_i(clka_i), .arst_n_i(arst_n_i),.data_i(data_i), .clkb_i(clkb_i), .data_o(data_o));


/*------------------------------------------------------------------------------
--  TASKS
------------------------------------------------------------------------------*/
task automatic cycles(input int number, ref bit clk,input real time_cycle);
    repeat (number) @(posedge clk) #(time_cycle/10.0);
endtask : cycles


/*------------------------------------------------------------------------------
--   Behavior
------------------------------------------------------------------------------*/
always #(CYCLEA/2.0) clka_i = !clka_i  ;
always #(CYCLEB/2.0) clkb_i = !clkb_i  ;


initial begin
    cycles(100,clka_i,CYCLEA);
    arst_n_i = 0 ;
    cycles(100,clka_i,CYCLEA);
    arst_n_i = 1 ;
    cycles(100,clka_i,CYCLEA);


    repeat (50) begin
        data_i = 1;
        cycles(1,clka_i,CYCLEA);
        data_i = 0;
        cycles(50,clka_i,CYCLEA);
    end

    $stop ;
end

endmodule