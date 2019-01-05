`timescale 1us/1us
module test;

parameter A = 2'b00, B= 2'b01, C= 2'b10;
reg[1:0] addressA; reg[1:0] addressB; reg[1:0] addressC;
reg[31:0] datA; reg[31:0] datB; reg[31:0] datC;
reg[3:0] BE_A; reg[3:0] BE_B; reg[3:0] BE_C;
wire[3:0] C_BE;
wire[3:0] gnt;
assign gntA = gnt[1]; assign gntB = gnt[2]; assign gntC = gnt[3];
wire[3:0] req;
assign req = {reqC, reqB, reqA, 1'b1};
wire frame, irdy, reqA, reqB, reqC;
reg force_reqA, force_reqB, force_reqC, clk, rd_wrA, rd_wrB, rd_wrC, burstA, burstB, burstC, rframe, reset_add;
wire[31:0] d;
initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);
    rframe = 1'bz;
    force_reqA = 0; force_reqB = 0; force_reqC = 0; rd_wrA = 0; rd_wrB = 0;
    burstA = 0; burstB = 0; burstC = 0; reset_add = 1; addressA = A; addressB = B; addressC = C;
    clk = 0;
    #1
    reset_add = 0;
    force_reqA = 1;
    addressA = B;
    rd_wrA = 0;
    #2
    force_reqA = 0;
    burstA = 1;
    datA = 32'hAAAAAAAA;
    BE_A = 4'b1111;
    #12
    burstA = 0;
    
    force_reqB = 1;
    addressB = 3;
    rd_wrB = 0;
    #2
    force_reqB = 0;
    burstB = 1;
    datB = 32'hBBBBBBBB;
    BE_B = 4'b1111;

    force_reqC = 1;
    #2
    force_reqA = 1;
    addressA = C;
    BE_C = 4'b1111;
    addressC = A;
    rd_wrA = 0;
    rd_wrC = 1;
    #2
    force_reqA = 0;
    force_reqC = 0;    
    datC = 32'hCCCCCCCC;
    addressC = B;
    
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

Controller deviceC( addressC,  BE_C,  force_reqC,  rd_wrC, datC, burstC,
    clk,  d,  C_BE,  devsel,  frame,  irdy,  trdy,
    gntC,  reqC,
    reset_add
    );

arbiter arbit(gnt, req, clk);


endmodule // 