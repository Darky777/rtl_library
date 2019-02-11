module toggle_synchronizer_alt (
    input clka_i , // clk source
    input data_i , // must be pulse
    input arst_n_i ,
    input clkb_i , // clk destonation
    output data_o  // pulse synchron with clk destonation
);

    logic ff_a;
    logic ff_b0,ff_b1,ff_b2;

    /*------------------------------------------------------------------------------
    --  clka clock domain
    ------------------------------------------------------------------------------*/
    always_ff @( posedge clka_i or negedge arst_n_i ) begin
        if ( !arst_n_i ) begin
            ff_a <= 1'b0 ;
        end else begin
            ff_a <= ( data_i ) ? ( !ff_a ) : ( ff_a ) ;
        end
    end

    /*------------------------------------------------------------------------------
    --  clkb clock domain
    ------------------------------------------------------------------------------*/
    always_ff @( posedge clkb_i or negedge arst_n_i ) begin
        if ( !arst_n_i ) begin
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