module Controller(
    input [1:0]devaddress, input [3:0] BE, input force_req, input rd_wr, input[31:0]  write_data, input burst,
    input clk, inout[31:0] AD, inout[3:0] C_BE, inout devsel, inout frame, inout irdy, inout trdy,
    input gnt, output req,
    input reset_address //active high
);

wire[2:0] state;
reg[1:0] tar_add;
always @ (reset_address) begin
    if (reset_address) begin
        tar_add <= devaddress;
    end
end

State_Machine sm(
    frame, irdy, trdy, devsel, state, clk, force_req, burst, req, gnt, C_BE[0], fcount, fend_count, ffinished, fvalid, fburst, bus_is_mine
);

Initiator_Controller ic(
    devaddress, BE, force_req, rd_wr, write_data, clk, AD, C_BE, frame, irdy, req, 
    state, fcount, fend_count, ffinished, fvalid, bus_is_mine, fburst
);

Target_Controller tc(
    clk, AD, C_BE, devsel, trdy, state, fvalid, tar_add, frame
);


endmodule
