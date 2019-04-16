`include "common_pkg.svh"
module fifo_single_clock import common_pkg::*; #(
    parameter DEPTH = 32,
    parameter DW   = 32 ,
    parameter SHOW_AHEAD = "OFF"  // "OFF" "ON"

) (
    input clk_i   ,
    input srst_i   ,

    // input fifo
    input valid_i ,
    input [DW - 1:0] data_i ,

    // output fifo
    output valid_o ,
    output logic [DW - 1:0] data_o ,
    input  req_i ,

    // status fifo
    output logic overflow_o ,
    output logic underflow_o ,
    output logic full_o ,
    output logic empty_o ,
    output [clogb2_f(DEPTH) - 1: 0] count_o
);
    /*------------------------------------------------------------------------------
    --  Internal vareables
    ------------------------------------------------------------------------------*/
    logic [clogb2_f(DEPTH) - 1: 0] addr_wr ;
    logic [clogb2_f(DEPTH) - 1: 0] addr_rd ;
    logic [clogb2_f(DEPTH) - 1: 0] count ;
    logic empty,full,overflow,underflow ;
    logic [DW-1:0] mem [DEPTH];
    logic valid ;

    /*------------------------------------------------------------------------------
    --  Functional
    ------------------------------------------------------------------------------*/
    always_ff @(posedge clk_i) begin : proc_addr_wr
        if ( srst_i ) begin
            addr_wr <= '0 ;
        end else if ( valid_i ) begin
            addr_wr <= addr_wr + 1'b1 ;
        end
    end

    always_ff @(posedge clk_i) begin : proc_addr_rd
        if ( srst_i ) begin
            addr_rd <= '0 ;
        end else if ( req_i ) begin
            addr_rd <= addr_rd + 1'b1 ;
        end
    end

    always_ff @(posedge clk_i) begin : proc_mem
        if( valid_i ) begin
            mem[addr_wr] <= data_i ;
        end
    end

    generate
        if( SHOW_AHEAD == "ON") begin
            assign data_o = mem[addr_rd];
            assign valid  = req_i && !empty ;
        end else if ( SHOW_AHEAD == "OFF" ) begin

            always_ff @( posedge clk_i ) begin
                if ( srst_i ) begin
                    data_o <= '0;
                end else if ( req_i ) begin
                    data_o <= mem[addr_rd];
                end
            end

            always_ff @( posedge clk_i ) begin : proc_
                if( srst_i ) begin
                   valid <= 1'b0;
                end else begin
                   valid <= req_i && !empty && !underflow && !overflow;
                end
            end

        end
    endgenerate

    always_ff @( posedge clk_i ) begin : proc_full
        if( srst_i ) begin
            full <= 0;
        end else begin
            if( full ) begin
                if ( req_i ) begin
                    full <= ( valid_i ) ? ( 1'b1 ) : ( 1'b0 ) ;
                end
            end else begin
                if ( valid_i ) begin
                    full <= ( req_i ) ? ( 1'b0 ) : ( addr_rd == ( addr_wr + 2'd2 ) ) ;
                end
            end
        end
    end

    always_ff @( posedge clk_i ) begin : proc_empty
        if ( srst_i ) begin
            empty <= 0;
        end else begin
            // all cases
            unique if ( !valid_i && !req_i ) begin
                empty <= ( addr_wr - addr_rd ) == '0 ;
            end else if ( valid_i && !req_i ) begin
                empty <= 1'b0 ;
            end else if ( !valid_i && req_i ) begin
                empty <= ( addr_wr - ( addr_rd + 1'b1 ) ) == '0 ;
            end else if ( valid_i && req_i ) begin
                empty <= ( addr_wr - addr_rd ) == '0 ;
            end
        end
    end

    // -- overflow functional ---------------------------
    always_ff @( posedge clk_i ) begin
        if( srst_i ) begin
            overflow <= 1'b0;
        end if ( valid_i && full && !overflow )begin
            unique if( req_i ) begin
                overflow <= 1'b0;
            end else if( !req_i ) begin
                overflow <= 1'b1;
            end
        end
    end

    // -- undeflow functional ---------------------------
    always_ff @(posedge clk_i) begin : proc_underflow
        if( srst_i ) begin
            underflow <= 1'b0;
        end else if ( req_i && empty && !underflow ) begin
            underflow <= 1'b1 ;
        end
    end

    // -- counter functional ---------------------------
    always_ff @( posedge clk_i ) begin : proc_count
        if ( srst_i ) begin
            count <= '0;
        end else begin
            unique if ( !valid_i && !req_i ) begin
                count <= addr_wr - addr_rd ;
            end else if ( valid_i && !req_i ) begin
                count <= addr_wr - addr_rd + 1'b1 ;
            end else if ( !valid_i && req_i ) begin
                count <= addr_wr - addr_rd - 1'b1 ;
            end else if ( valid_i && req_i ) begin
                count <= addr_wr - addr_rd  ;
            end
        end
    end
    /*------------------------------------------------------------------------------
    --  Output status
    ------------------------------------------------------------------------------*/
    assign empty_o = empty ;
    assign overflow_o = overflow ;
    assign count_o = count ;
    assign underflow_o = underflow ;
    assign full_o = full ;
    assign valid_o = valid ;

endmodule
