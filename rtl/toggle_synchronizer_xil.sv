module toggle_synchronizer_xil (
    input clka_i , // clk source
    input data_i , // must be pulse
    input srst_i ,
    input clkb_i , // clk destonation
    output data_o  // pulse synchron with clk destonation
);

    logic ff_a;
    (* ASYNC_REG="true" *) logic ff_b0 ;
    logic ff_b1,ff_b2;

    /*------------------------------------------------------------------------------
    --  clka clock domain
    ------------------------------------------------------------------------------*/
    always_ff @( posedge clka_i ) begin
        if ( srst_i ) begin
            ff_a <= 1'b0 ;
        end else begin
            ff_a <= ( data_i ) ? ( !ff_a ) : ( ff_a ) ;
        end
    end

    /*------------------------------------------------------------------------------
    --  clkb clock domain
    ------------------------------------------------------------------------------*/
    always_ff @( posedge clkb_i ) begin
        if ( srst_i ) begin
            ff_b0 <= 1'b0 ;
            ff_b1 <= 1'b0 ;
            ff_b2 <= 1'b0 ;
        end else begin
            ff_b0 <= ff_a  ;
            ff_b1 <= ff_b0 ;
            ff_b2 <= ff_b1 ;
        end
    end

    assign data_o = ff_b1 ^^ ff_b2 ;

endmodule