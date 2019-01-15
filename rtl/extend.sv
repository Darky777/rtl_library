module extend #(
    parameter DI = 12 , 
    parameter DO = 16
)(
    input [DI-1:0] data_i ,
    output [DO-1:0] data_o
);

    localparam EXTEND = DO - DI ;

    assign data_o = { {EXTEND{1'b0}} , data_i } ;
    
endmodule