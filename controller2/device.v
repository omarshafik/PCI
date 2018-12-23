module Controller(
    input [1:0]devaddress, input [3:0] BE, input force_req, input rd_wr, //force_req active high
    input clk, inout[31:0] AD, inout[3:0] C_BE, inout devsel, inout frame, inout irdy, inout trdy,
    input gnt, output req
);

wire[2:0] state;

State_Machine sm(
    frame, irdy, trdy, devsel, state, clk, force_req, req, gnt, fcount, fend_count, freq_pending, ffinished, fvalid
);

Initiator_Controller ic(
    devaddress, BE, force_req, rd_wr, clk, AD, C_BE, frame, irdy, req, 
    state, fcount, fend_count, freq_pending, ffinished, fvalid
);

Target_Controller tc(
    clk, AD, C_BE, devsel, trdy, state, fvalid
);


endmodule
