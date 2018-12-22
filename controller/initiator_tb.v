module test;
    reg[1:0] address;
    wire[31:0] dat;
    reg[3:0] BE;
    wire[3:0] C_BE;
    reg force_req, clk, devsel, trdy, gnt, rd_wr;
    wire frame, irdy, req;
    reg[31:0] AD;
    wire[31:0] d;
    assign d = AD;
    initial begin
        AD = 32'hZZZZZZZZ;
        $dumpfile("test.vcd");
        $dumpvars(0,test);
        trdy = 1; devsel = 1; gnt = 1; force_req = 0;
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
        #4
        trdy = 0;
        devsel = 0;
        AD = 32'hAAAAAAAA;
        #2
        AD = 32'hBBBBBBBB;

        # 10 $finish;
    end

    always #1 clk = ~clk;

    Initiator_Controller device( address,  BE,  force_req,  rd_wr, //force_req active high
     clk,  d,  C_BE,  devsel,  frame,  irdy,  trdy,
     gnt,  req);

endmodule // 