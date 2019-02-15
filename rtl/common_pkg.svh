package common_pkg;

    function automatic integer clogb2_f( input [31:0] value );
       integer i;
       begin
          clogb2_f = 32;
          for (i=31; i>0; i=i-1) begin
              if (2**i >= value) begin
                  clogb2_f = i;
             end
          end
       end
    endfunction

endpackage