module Initiator_Controller(
    input address[1:0], input BE[3:0], output data[31:0], input force_req, input rd_wr,
    input clk, inout AD[31:0], output C_BE[3:0], input devsel, output frame, output irdy, input trdy,
    input gnt, output req;
);

reg[31:0] memory[7:0];  //for storing entry
reg[2:0] mp;            //memmory pointer

wire [2:0] state;
State_Machine sm (frame, irdy, trdy, devsel, state, clk);
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
/* frame must not get asserted before force_req signal gets deasserted */
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
assign req = ( ((~force_req & counter) && (gnt && state != idle)) ? 0 : 1; // MUST REVIEW

////////////////////////////////////////////* set frame *////////////////////////////////////////////////////
assign frame = (~gnt && state == idle) ?  0 : ( (counter == 1 && state != idle) ? 1 : 1'bz );

///////////////////////////////////////////* set AD with address *//////////////////////////////////////////
assign AD = (state == address) ? memory[7] : 32'hZZZZZZZZ;

////////////////////////////////////////////* set irdy *////////////////////////////////////////////////////
assign irdy = (state == data_wait || state == data) ? 0 : ( (state == final) ? 1 : 1'bz );

////////////////////////////////////////////* read data *////////////////////////////////////////////////////
always @ (posedge clk) begin
    if (state == data || state == final) begin
        memory[mp] <= AD;
        mp++; 
    end
    if (state == idle) begin
        mp <= 0; 
    end
end

endmodule 
