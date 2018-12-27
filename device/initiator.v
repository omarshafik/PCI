module Initiator_Controller(
    input [1:0]devaddress, input[3:0] BE, input force_req, input rd_wr, input[31:0] write_data,
    input clk, inout[31:0] AD, output[3:0] C_BE, output frame, output irdy,
    output req,
    input[2:0] state, input fcount, input fend_count, input ffinished, input fvalid, input bus_is_mine,
    input fburst    // extra input for burst transactions (active high)
    );

/*
  **When in burst mode the intiator continues in data phases until either maximum failed transfers 
    or fburst signalis deasserted.
  **In Normal mode the intiator completes one data transfer and continues to the next transaction.
*/

reg[3:0] command[0:3];
wire[3:0] comm;
assign comm = command[0];
/*
    when force_req signal is asserted, at every positive edge a corresponding target-address and command is saved
    in internal memory  
*/
always @ (posedge clk) begin
    if (fcount) begin
        memory[9 - counter] <= devaddress;
        command[counter] <= rd_wr;
    end
end

parameter[2:0]    
idle=0, address=3'b001, turnaround=3'b010, data=3'b011, finish=3'b100;  //states are declared in State_Machine module

/*************************** count number of required transactions by master ******************************/
            /* frame shall not get asserted before force_req signal gets deasserted */

reg[2:0] failed_counter;        //count the cycles at which the target hasn't responded ** max limit 5 cycles
reg [1:0] counter, max;         //counts and saves the number of required transactions
always @ (negedge clk) begin
    if(fcount) begin     
        counter <= counter + 1; 
        max <= counter + 1;
        failed_counter <= 0;
    end
    if (state == finish && (!fburst || failed_counter > 4) && bus_is_mine) begin
        counter <= counter - 1; 
        failed_counter <= 0;
    end
    if ((state == data || state == turnaround) && !fvalid && fburst) begin
        failed_counter <= failed_counter + 1;
    end
    if (state == data && fvalid) begin
        failed_counter <= 0;
    end
end
always @ (posedge force_req) begin
    counter <= 0;
    max <= 0;  
    mp <= 0;
end

////////////////////////////////////* send request to arbiter *////////////////////////////////////////////////
assign req = (fend_count === 1 && 
                ((counter && 
                (!bus_is_mine || (bus_is_mine && state == idle) || (bus_is_mine && fburst && failed_counter < 4))
                || counter > 1))) ? 0 : 1; // MUST REVIEW

////////////////////////////////////////////* set frame *////////////////////////////////////////////////////
assign frame = (bus_is_mine === 1 && state != finish && counter) ?
 ( (state == address || ( (state == data || state == turnaround ) && (fburst && (failed_counter < 4) ) ) ) ? 0 : 1) : 1'bz;  //multi transactions 

///////////////////////////////////////////* set AD with address *//////////////////////////////////////////
assign AD = (state == address && bus_is_mine === 1) ? memory[9 - max + counter] : (bus_is_mine && command[max-counter] === 0 && state === data) ? write_data : 32'hZZZZZZZZ;
assign C_BE = (state == address && bus_is_mine === 1) ? command[max - counter] : ( (state === data && bus_is_mine) ? BE : 4'bzzzz );

////////////////////////////////////////////* set irdy *////////////////////////////////////////////////////
assign irdy = (bus_is_mine === 1 && (state == turnaround || state == data)) ? 0 : ( (bus_is_mine === 1 && (state == finish || state == address) ) ? 1 : 1'bz );

////////////////////////////////////////////* read data *////////////////////////////////////////////////////
                            /* read data is saved in this internal memory */

reg[2:0] mp;            //memory pointer
reg[31:0] memory[9:0];  //multi transaction 
wire[31:0] mem1, mem2, mem3, mem4, mem9, mem10;
assign mem1 = memory[0];
assign mem2 = memory[1];
assign mem3 = memory[2];
assign mem4 = memory[3];
assign mem9 = memory[8];
assign mem10 = memory[9];

always @ (posedge clk) begin
    if (bus_is_mine && (state == data && fvalid) && command[max-counter] == 1) begin
        memory[mp] <= AD;
    end
    if (state == idle && counter == 0) begin
        mp <= 0; 
    end
    if (fcount) begin
        memory[9-mp] <= devaddress; 
    end

end
always @ (negedge clk) begin    // increment memory pointer
    if (bus_is_mine && (state == data && fvalid) && mp < 8 && command[max-counter] == 1) begin
        mp <= mp + 1; 
    end
    if (fcount) begin
        mp <= mp + 1; 
    end
    if (state == address) begin
        mp <= 0; 
    end
end

endmodule   //master read & write module