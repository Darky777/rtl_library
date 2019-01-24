module irq_gen #(
    parameter STATUS_W = 32 ,
    parameter INIT_VALUE = 1'b0
    )
    (
    input clk_i ,
    input srst_i ,

    // config
    input [1:0] irq_mode_i ,
    input [15:0] length_i ,
    // wraccess
    input clear_irq_i ,
    // status vector must be pulse signal
    input [STATUS_W - 1:0] mask_i ,
    input [STATUS_W - 1:0] status_i ,
    // generated irq
    output logic irq_o
);

    typedef enum logic [1:0] { FIXED_P = 0 ,STROBE_N = 1,FIXED_N = 2,STROBE_P = 3 } irq_mode_t;

    irq_mode_t irq_mode ;
    assign irq_mode = irq_mode_t'(irq_mode_i) ;
    logic [15:0] counter_irq ;

    always_ff @( posedge clk_i ) begin : proc_external_done_irq
        if ( srst_i ) begin
            counter_irq <= '0;
            external_done_irq_o <= INIT_VALUE;
        end if( clear_irq_i ) begin
            case ( irq_mode )
                FIXED_N : irq_o  <= 1'b1;
                FIXED_P : irq_o  <= 1'b0;
                STROBE_N : irq_o <= 1'b1;
                STROBE_P : irq_o <= 1'b0;
                default : irq_o  <= 1'b0;
            endcase
        end else begin
            case ( irq_mode )
                FIXED_N : begin
                    if( |( status_i & mask_i ) )
                        irq_o <= 1'b0;
                    else if ( clear_irq_i )
                        irq_o <= 1'b1;
                end
                FIXED_P : begin
                    if( |( status_i & mask_i )  )
                        irq_o <= 1'b1;
                    else if ( clear_irq_i )
                        irq_o <= 1'b0;
                end
                STROBE_N : begin
                    if( |( status_i & mask_i )  ) begin
                        irq_o <= 1'b0;
                        counter_irq  <= length_i;
                    end else begin
                        irq_o <= counter_irq > 0 ? 1'b0 : 1'b1;
                        if ( counter_irq > 0 ) begin
                            counter_irq <= counter_irq - 1'b1;
                        end
                    end
                end
                STROBE_P : begin
                    if( |( status_i & mask_i )  ) begin
                        irq_o <= 1'b1;
                        counter_irq  <= length_i;
                    end else begin
                        irq_o <= counter_irq > 0 ? 1'b1 : 1'b0;
                        if ( counter_irq > 0 ) begin
                            counter_irq <= counter_irq - 1'b1;
                        end
                    end
                end
                default : irq_o <= 1'b1;
            endcase
        end
    end

endmodule