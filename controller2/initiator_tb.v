`timescale 1us/1us
module test;
    reg[1:0] address;
    reg[31:0] dat;
    reg[3:0] BE;
    wire[3:0] C_BE;
    reg force_req, clk, gnt, rd_wr;
    wire frame, irdy, req;
    wire[31:0] d;
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);
        gnt = 1; force_req = 0; rd_wr = 1;
        clk = 0;
        #4
        force_req = 1;
        address = 2'b01;
        dat = 32'hBBBBDFBB;
        BE = 4'b1011;
        #2
        dat = 32'hAAAAAAAA;
        BE = 4'b0001;
        #2
        dat = 32'hBBBBDFBB;
        BE = 4'b0100;
        #2
        force_req = 0;
        address = 2'bzz;
        dat = 32'hZZZZZZZZ;
        BE = 4'bzzzz;
        #2
        gnt = 0;
        // #6
        // gnt = 1;
        // #2
        // gnt = 0;
        // #4
        // gnt = 1;
        // #4
        // gnt = 0;
        
        # 30 $finish;
    end

    always #1 clk = ~clk;

    Controller device( address,  BE,  force_req,  rd_wr, dat,
     clk,  d,  C_BE,  devsel,  frame,  irdy,  trdy,
     gnt,  req);

endmodule // 