module Initiator_Controller(
    input [1:0]devaddress, input [3:0] BE, /*output [31:0]data,*/ input force_req, input rd_wr, //force_req active high
    input clk, inout[31:0] AD, output[3:0] C_BE, input devsel, output frame, output irdy, input trdy,
    input gnt, output req);




// wire frame, irdy;
always @ (negedge clk) begin
    // frame <= frame;
    // irdy <= irdy;
    if (force_req) begin
        memory[7] <= devaddress;
    end
end

wire [2:0] state;
State_Machine sm (frame, irdy, trdy, devsel, state, clk, force_req, req, gnt, fcount, fend_count, freq_pending, ffinished);
parameter[2:0]
idle=0, address=1, data_wait=2, data=3, final_data=4, finish=5;

/*************************** count number of required transactions by master ******************************/
/* frame must not get asserted before force_req signal gets deasserted */
reg [1:0] counter;
always @ (negedge clk) begin
    if(fcount) begin     
        counter = counter + 1; 
    end
    if (state == data) begin
        counter = counter - 1; 
    end
end
always @ (posedge force_req) begin
    counter <= 0;
end

////////////////////////////////////* send request to arbiter *////////////////////////////////////////////////
reg bus_is_mine;    // indicate whether the bus is in this controller's command (active high)
assign req = ((fend_count && counter) && (~bus_is_mine)) ? 0 : 1; // MUST REVIEW
always @ (*) begin
    if (fcount) begin
        bus_is_mine = 0; 
    end
    if (state == address) begin
        bus_is_mine = 1; 
    end
    if (bus_is_mine && ffinished) begin
        bus_is_mine = 0; 
    end
end

////////////////////////////////////////////* set frame *////////////////////////////////////////////////////
assign frame = (bus_is_mine && state != finish) ? ( (state == address || counter > 1) ? 0 : 1) : 1'bz;

///////////////////////////////////////////* set AD with address *//////////////////////////////////////////
assign AD = (state == address && bus_is_mine) ? memory[7] : 32'hZZZZZZZZ;

////////////////////////////////////////////* set irdy *////////////////////////////////////////////////////
assign irdy = (bus_is_mine && (state == data_wait || state == data)) ? 0 : ( (bus_is_mine && state == finish) ? 1 : 1'bz );

////////////////////////////////////////////* read data *////////////////////////////////////////////////////
 //for storing entry
reg[2:0] mp;            //memory pointer
reg[31:0] memory[7:0];
wire[31:0] mem1, mem2, mem3, mem4;
assign mem1 = memory[0];
assign mem2 = memory[1];
assign mem3 = memory[2];
assign mem4 = memory[3];

always @ (posedge clk) begin
    if (bus_is_mine && (state == data)) begin
        memory[mp] <= AD;
        //mp++;   // illegal // unsynthesizable // accessing memory location mp while changing mp value
    end
    if (state == idle) begin
        mp <= 0; 
    end
end
always @ (negedge clk) begin    // increment memory pointer
    if (bus_is_mine && (state == data)) begin
        mp <= mp + 1; 
    end
end

endmodule 

