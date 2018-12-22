module test;
    reg[1:0] address;
    wire[31:0] dat;
    reg[3:0] BE;
    wire[3:0] C_BE;
    reg force_req, clk, devsel, trdy, gnt, rd_wr;
    wire frame, irdy, req;
    reg[31:0] AD;
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);
        trdy = 1; devsel = 1; gnt = 1; force_req = 0; AD = 32'hZZZZZZZZ;
        clk = 0;
        #5
        force_req = 1;
        address = 2'b01;
        #1
        force_req = 0;
        address = 2'bzz;

        # 1 $finish;
    end

    always #1 clk = ~clk;

    Initiator_Controller device( address,  BE,  dat,  force_req,  rd_wr, //force_req active high
     clk,  AD,  C_BE,  devsel,  frame,  irdy,  trdy,
     gnt,  req);

endmodule // 