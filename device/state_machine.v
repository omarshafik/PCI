module State_Machine(
    frame, irdy, trdy, devsel, state, clk, force_req, burst, req, gnt, rd_wr, fcount, fend_count, ffinished, fvalid, fburst, bus_is_mine
);

/*
    This state machine is valid for both read and write transactions
    for read: rd_wr = 1
    for write: rd_wr = 0
*/

input wire frame, irdy, trdy, devsel, clk, force_req, burst, req, gnt, rd_wr;
output reg[2:0] state;
reg[2:0] next_state;

parameter[2:0] 
/*
There are five states:
1. idle: here the bus is free (with respect to the device)
2. address: the initiator has asserted the frame and put a valid address on AD lines
3. turnaround: in case of read transaction the target must wait for two cylces after the frame being asserted
    to put valid data on AD and hence assert trdy
4. data: here data tranfers may occur depending on irdy & trdy (fvalid flag)
5. finish: all required transfers have occured and turnaround cycle ouccurs 
*/
idle=0, address=1, turnaround=2, data=3, finish=4;

output reg          //flags that contributes in synchronization of bus lines
    fcount,         //indicates assertion of force_req signal
    fend_count,     //indicates deassertion of force_req signal
    ffinished,      //indicates finished transaction and free bus
    fvalid,         //indicates that a valid data transfer may occur next positive edge of clock **combinational
    fburst,
    bus_is_mine;
reg fgnt;           //indicates a granted bus ownership

always @(negedge clk) begin
    state <= next_state;      
    if (force_req) begin
        fend_count <= 0;
        fcount <= 1; 
    end
    if (!force_req && fcount) begin
        fcount <= 0;
        fend_count <= 1;
    end
    if (state == address) begin
        ffinished <= 0; 
    end
    if (state == finish) begin
        ffinished <= 1;
    end
    if (!gnt) begin
        fgnt <= 1; 
    end else begin
        fgnt <= 0; 
    end
    if (burst) begin
        fburst <= 1; 
    end else begin
        fburst <= 0; 
    end
end

always @(posedge clk) begin
    case (state)
        idle: begin
            fvalid = 1;
            bus_is_mine = 0 ;
            if (fgnt && !req) begin
                next_state = address;
                bus_is_mine = 1;
            end
            if (fgnt && !req && !frame) begin
                bus_is_mine = 0;
            end
            if (!frame && !bus_is_mine) begin
                if (rd_wr) begin
                    next_state = turnaround;               
                end
                else begin
                    next_state = data;
                end
            end
        end

        address: begin
            if (!frame) begin
                if (rd_wr) begin
                    next_state = turnaround;               
                end
                else begin
                    next_state = data;
                end
            end
            fvalid = 1;
        end

        turnaround: begin
            fvalid = 1;
            next_state = data;
        end

        data: begin
            if(fgnt === 0 && bus_is_mine) begin
                next_state = finish; 
            end
            if (frame) begin
                next_state = finish; 
            end
            if(trdy === 0 && irdy === 0 && devsel === 0) begin
                fvalid = 1; 
            end else begin
                fvalid = 0; 
            end
        end

        finish: begin 
            next_state = idle; 
        end

        default: next_state = idle; //for initializing
    endcase
end

endmodule // State_Machine
