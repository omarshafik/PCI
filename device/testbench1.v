`timescale 1us/1us
module test;

    parameter A = 2'b01, B= 2'b00;
    reg[1:0] addressA; reg[1:0] addressB;
    reg[31:0] datA; reg[31:0] datB;
    reg[3:0] BE_A; reg[3:0] BE_B;
    wire[3:0] C_BE;
    reg force_reqA, force_reqB, clk, gntA, gntB, rd_wrA, rd_wrB, burstA, burstB, rframe, reset_add;
    inout frame, irdy, reqA, reqB;
    wire[31:0] d;
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);
        rframe = 1'bz;
        gntA = 1; gntB = 1; force_reqA = 0; force_reqB = 0; rd_wrA = 0; rd_wrB = 0;
        burstA = 0; burstB = 0; reset_add = 1; addressA = A; addressB = B;
        clk = 0;
        #1
        reset_add = 0;
        force_reqA = 1;
        addressA = B;
        rd_wrA = 0;
        #2
        force_reqA = 0;
        gntA = 0;
        burstA = 1;
        datA = 32'hAAAAAAAA;
        BE_A = 4'b1011;
        #8
        burstA = 0;
        
        force_reqB = 1;
        addressB = A;
        gntB = 0;
        rd_wrB = 0;
        #2
        force_reqB = 0;
        burstB = 1;
        datB = 32'hBBBBBBBB;
        BE_B = 4'b1111;
        #8
        burstB = 0;
        
        
        # 40 $finish;
    end

    always #1 clk = ~clk;

    Controller deviceA( addressA,  BE_A,  force_reqA,  rd_wrA, datA, burstA,
     clk,  d,  C_BE,  devsel,  frame,  irdy,  trdy,
     gntA,  reqA,
     reset_add
     );
     Controller deviceB( addressB,  BE_B,  force_reqB,  rd_wrB, datB, burstB,
     clk,  d,  C_BE,  devsel,  frame,  irdy,  trdy,
     gntB,  reqB,
     reset_add
     );

endmodule // 