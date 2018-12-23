module Target_Controller(
    input clk, inout[31:0] AD, input[3:0] C_BE, output devsel, output trdy, input[2:0] state, input fvalid
    );

parameter[2:0] idle=0, address=1, data_wait=2, data=3, finish=5;
parameter[31:0] devaddress = 1;
reg[31:0] add;
reg[31:0] memory[7:0];
always @ (posedge clk) begin
    if (state == address) begin
        add <= AD; 
    end
end

assign devsel = (state == data && add == devaddress) ? 0 : (state == finish) ? 1 : 1'bz;
assign trdy = (state == data && add == devaddress) ? 0 : (state == finish) ? 1 : 1'bz;
assign AD = (state == data && add == devaddress) ?  32'hAAAAAAAA: 32'hZZZZZZZZ;

endmodule   //target read module