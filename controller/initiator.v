module Initiator_Controller(
    input [1:0]devaddress, input [3:0] BE, /*output [31:0]data,*/ input force_req, input rd_wr, //force_req active high
    input clk, inout[31:0] AD, output[3:0] C_BE, input devsel, output reg frame, output reg irdy, input trdy,
    input gnt, output req);
reg[31:0] memory[0:7];

wire wframe, wirdy;
always @ (negedge clk) begin
    frame <= wframe;
    irdy <= wirdy;
    if (force_req) begin
        memory[7] <= devaddress;
    end
end

wire [2:0] state;
State_Machine sm (wframe, wirdy, trdy, devsel, state, clk);
parameter[2:0]
/* phases are four; 
1. idle : bus is free.
2. address : initiator waiting for a device to identify itself as the target.
3. data wait : bus is on hold as any of #RDY signals are deasserted (no transaction occurs).
4. data : transaction occurs.
5. final : final transaction occurs then bus waits for initiator to deassert IRDY.
*/
idle=0, address=1, data_wait=2, data=3, final=4;

/*************************** count number of required transactions by master ******************************/
/* wframe must not get asserted before force_req signal gets deasserted */
reg [1:0] counter;
always @ (posedge clk) begin
    if(force_req && state == idle) begin     
        counter <= counter + 1; 
    end
    if (state == data || state == final) begin
        counter <= counter - 1; 
    end
end

////////////////////////////////////* send request to arbiter *////////////////////////////////////////////////
reg bus_is_mine;    // indicate whether the bus is in this controller's command (active high)
assign req = ((~force_req & counter) && (~bus_is_mine)) ? 0 : 1; // MUST REVIEW
always @ (posedge clk) begin
    if (force_req) begin
        bus_is_mine <= 0; 
    end
    if (~gnt && state == idle && ~bus_is_mine) begin
        bus_is_mine <= 1; 
    end
    if (bus_is_mine && state == final) begin
        bus_is_mine <= 0; 
    end
end

////////////////////////////////////////////* set wframe *////////////////////////////////////////////////////
assign wframe = (bus_is_mine) ? ( (state == idle || counter > 1) ? 0 : 1) : 1'bz;

///////////////////////////////////////////* set AD with address *//////////////////////////////////////////
assign AD = (state == address) ? memory[7] : 32'hZZZZZZZZ;

////////////////////////////////////////////* set wirdy *////////////////////////////////////////////////////
assign wirdy = (state == data_wait || state == data) ? 0 : ( (state == final) ? 1 : 1'bz );

////////////////////////////////////////////* read data *////////////////////////////////////////////////////
 //for storing entry
reg[2:0] mp;            //memory pointer

always @ (posedge clk) begin
    if (state == data || state == final) begin
        memory[mp] <= AD;
        //mp++;   // illegal // unsynthesizable // accessing memory location mp while changing mp value
    end
    if (state == idle) begin
        mp <= 0; 
    end
end
always @ (negedge clk) begin    // increment memory pointer
    if (state == data || state == final) begin
        mp <= mp + 1; 
    end
end

endmodule 

