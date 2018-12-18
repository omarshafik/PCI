module Initiator_Controller(
    input address[1:0], input BE[3:0], output data[31:0], input force_req, input rd_wr,
    input clk, inout AD[31:0], output C_BE[3:0], input devsel, output frame, output irdy, input trdy
);

reg frame, irdy;

wire [2:0] state;
Read_State_Machine sm (frame, irdy, trdy, devsel, state, clk);

parameter[2:0]
/* phases are four; 
1. idle : bus is free.
2. address : initiator waiting for a device to identify itself as the target.
3. data wait : bus is on hold as any of #RDY signals are deasserted (no transaction occurs).
4. data : transaction occurs.
5. final : final transaction occurs then bus waits for initiator to deassert IRDY.
*/
idle=0, address=1, data_wait=2, data=3, final=4;

// reg []

// always @ (posedge clk) begin
//     if(force_req) begin
//         frame <= 1; 
//     end
// end

endmodule 
