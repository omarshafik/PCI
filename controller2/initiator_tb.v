`timescale 1us/1us
module test;
    reg[1:0] address;
    wire[31:0] dat;
    reg[3:0] BE;
    wire[3:0] C_BE;
    reg force_req, clk, gnt, rd_wr;
    wire frame, irdy, req;
    wire[31:0] d;
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);
        gnt = 1; force_req = 0;
        clk = 0;
        #4
        force_req = 1;
        address = 2'b01;
        #6
        force_req = 0;
        address = 2'bzz;
        #2
        gnt = 0;
        #2
        gnt = 1;
        
        # 30 $finish;
    end

    always #1 clk = ~clk;

    Controller device( address,  BE,  force_req,  rd_wr, //force_req active high
     clk,  d,  C_BE,  devsel,  frame,  irdy,  trdy,
     gnt,  req);

endmodule // 