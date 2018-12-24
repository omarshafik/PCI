module Initiator_Controller(
    input [1:0]devaddress, input [3:0] BE, input force_req, input rd_wr, input[31:0] write_data,
    input clk, inout[31:0] AD, output[3:0] C_BE, output frame, output irdy,
    output req,
    input[2:0] state, input fcount, input fend_count, input ffinished, input fvalid
    );

reg[3:0] command;
reg[3:0] byte_enable[7:0];
always @ (posedge clk) begin
    if (force_req) begin
        memory[7] <= devaddress;
        command <= rd_wr;
        memory[counter] <= write_data;
        byte_enable[counter] <= BE;
    end
end

parameter[2:0]
idle=0, address=1, turnaround=2, data=3, finish=4;

/*************************** count number of required transactions by master ******************************/
/* frame must not get asserted before force_req signal gets deasserted */
reg [1:0] counter;
always @ (negedge clk) begin
    if(fcount) begin     
        counter = counter + 1; 
    end
    if (state == data && fvalid && bus_is_mine) begin
        counter = counter - 1; 
    end
end
always @ (posedge force_req) begin
    counter <= 0;
end

////////////////////////////////////* send request to arbiter *////////////////////////////////////////////////
reg bus_is_mine;    // indicate whether the bus is in this controller's command (active high)
assign req = (fend_count && (counter > 1 || ((!bus_is_mine || state == finish) && counter))) ? 0 : 1; // MUST REVIEW
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
assign frame = (bus_is_mine && state != finish) ? ( (state == address || counter > 1) ? 0 : 1) : 1'bz;  //multi transactions 

///////////////////////////////////////////* set AD with address *//////////////////////////////////////////
assign AD = (state == address && bus_is_mine) ? memory[7] : (command == 0 && state == data) ? memory[mp] : 32'hZZZZZZZZ;
assign C_BE = (state == address && bus_is_mine) ? command : (state == data) ? byte_enable[mp] : 4'bzzzz;

////////////////////////////////////////////* set irdy *////////////////////////////////////////////////////
assign irdy = (bus_is_mine && (state == turnaround || state == data)) ? 0 : ( (bus_is_mine && state == finish) ? 1 : 1'bz );

////////////////////////////////////////////* read data *////////////////////////////////////////////////////
reg[2:0] mp;            //memory pointer
reg[31:0] memory[9:0];  //multi transaction 
wire[31:0] mem1, mem2, mem3, mem4;
assign mem1 = memory[0];
assign mem2 = memory[1];
assign mem3 = memory[2];
assign mem4 = memory[3];

always @ (posedge clk) begin
    if (bus_is_mine && (state == data && fvalid) && command == 1) begin
        memory[mp] <= AD;
    end
    if (state == idle && counter == 0) begin
        mp <= 0; 
    end
end
always @ (negedge clk) begin    // increment memory pointer
    if (bus_is_mine && (state == data && fvalid)) begin
        mp <= mp + 1; 
    end
end

endmodule   //master read module