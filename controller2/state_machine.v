module State_Machine(
    frame, irdy, trdy, devsel, state, clk, force_req, req, gnt, fcount, fend_count, freq_pending, ffinished
);

input wire frame, irdy, trdy, devsel, clk, force_req, req, gnt;
output reg[2:0] state;
reg[2:0] next_state;

parameter[2:0] 
idle=0, address=1, data_wait=2, data=3, final_data=4, finish=5;

output reg fcount, fend_count, freq_pending, ffinished, fgnt;

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
    if (!req && gnt) begin
        fgnt <= 0;
        freq_pending <= 1; 
    end
    if (req) begin
        freq_pending <= 0; 
    end
    if (state == address) begin
        freq_pending <= 0;
        ffinished <= 0; 
    end
    if (state == finish) begin
        ffinished <= 1; 
    end
    if (!gnt) begin
        fgnt <= 1; 
    end
end

always @(*) begin
    case (state)

        idle: if (fgnt) begin
            next_state = address;
        end

        address: if (!frame) begin
            next_state = data_wait; 
        end

        data_wait: if (!frame && !irdy && !trdy) begin
            next_state = data; 
        end
        else if (frame && !irdy && !trdy) begin
            next_state = finish; 
        end

        data: if (frame && !irdy && !trdy) begin
            next_state = finish; 
        end 
        else if (!frame && (irdy || trdy)) begin
            next_state = data_wait; 
        end

        // final_data: if (!irdy && !trdy) begin
        //     next_state = finish; 
        // end

        finish: next_state = idle;

        default: next_state = idle; //for initializing
    endcase
end

endmodule // State_Machine
