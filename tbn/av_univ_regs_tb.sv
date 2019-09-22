`timescale 1ns/1ps
module av_univ_regs_tb ;
    parameter  DW            = 32 ;
    parameter  AW            = 16 ;
    parameter  REGS_NUM      = 16 ;
    parameter  bit [REGS_NUM-1:0][DW-1:0] REGS_INIT     =
    '{
        0: 32'hdaaddabb,
        1: 32'h91838491,
        2: 32'h23232323,
        15: 32'h1020292,
        default:32'hdeadbeaf
    };


    bit clk_i;
    bit reset_n_i;
    bit [AW-1:0] avms_address;
    bit [DW/8-1:0] avms_byteenable;
    bit avms_read;
    logic [DW-1:0] avms_readdata;
    bit    avms_write;
    bit   [DW-1:0] avms_writedata;
    logic [REGS_NUM-1:0] word_valid_wr_o;
    logic [REGS_NUM-1:0][DW-1:0] mst_word_o;
    bit   [REGS_NUM-1:0][DW-1:0] slv_word_i;
    bit [DW-1:0] data_read;

    av_univ_regs #(
        .DW           (DW       ),
        .AW           (AW       ),
        .REGS_NUM     (REGS_NUM ),
        .REGS_INIT    (REGS_INIT)
    ) i_av_univ_regs (
        .clk_i          (clk_i          ),
        .reset_n_i      (reset_n_i      ),
        //
        .avms_address   (avms_address   ),
        .avms_byteenable(avms_byteenable),
        .avms_read      (avms_read      ),
        .avms_readdata  (avms_readdata  ),
        .avms_write     (avms_write     ),
        .avms_writedata (avms_writedata ),
        //
        .word_valid_wr_o(word_valid_wr_o),
        .mst_word_o     (mst_word_o     ),
        .slv_word_i     (mst_word_o     )
    );


    always #5 clk_i = !clk_i;

    task wait_clocks(int i );
        repeat (i) @(posedge clk_i) #1;
    endtask : wait_clocks

    task write_data(input bit [AW-1:0] addr , input bit [DW-1:0] data_to_write  ,input bit [DW/8-1:0] byteenable);
        avms_address = addr;
        avms_byteenable = byteenable;
        avms_write = 1;
        avms_writedata = data_to_write;
        wait_clocks(1);
        avms_address = '0;
        avms_byteenable = '0;
        avms_write = '0;
        avms_writedata = '0;
        wait_clocks(1);
    endtask : write_data

    task read_data(input bit [AW-1:0] addr  ,input bit [DW/8-1:0] byteenable);
        avms_address = addr;
        avms_byteenable = byteenable;
        avms_read = 1;
        wait_clocks(1);
        avms_address = '0;
        avms_byteenable = '0;
        avms_read = '0;
        data_read = avms_readdata;
        wait_clocks(1);
        $display("addr 0x%0x data_read 0x%0x byteenable 0x%0x",addr,data_read,byteenable);
    endtask : read_data
    initial begin
        reset_n_i = 0;
        wait_clocks(20);
        reset_n_i = 1;
        wait_clocks(20);

        write_data(.addr(0),.data_to_write(32'habcd4526),.byteenable(4'hF));
        wait_clocks(20);

        write_data(.addr(1),.data_to_write(32'h12342574),.byteenable(4'h3));
        wait_clocks(20);

        write_data(.addr(2),.data_to_write(32'h3456aabb),.byteenable(4'h8));
        wait_clocks(20);

        write_data(.addr(3),.data_to_write(32'h5678beaf),.byteenable(4'h7));
        wait_clocks(20);

        for (int i = 0; i < REGS_NUM; i++) begin
            read_data(i,$urandom_range(15,1));
            wait_clocks(20);
        end

        $stop;
    end
endmodule