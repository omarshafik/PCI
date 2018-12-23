module State_Machine(
    frame, irdy, trdy, devsel, state, clk, force_req, req, gnt, fcount, fend_count, freq_pending, ffinished, fvalid
);

input wire frame, irdy, trdy, devsel, clk, force_req, req, gnt;
output reg[2:0] state;
reg[2:0] next_state;

parameter[2:0] 
idle=0, address=1, data_wait=2, data=3, final_data=4, finish=5;

output reg fcount, fend_count, freq_pending, ffinished, fgnt, fvalid;

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

        data_wait: begin
            next_state = data;
        end

        data: begin
        if (frame) begin
            next_state = finish; 
        end
        if(!trdy && !irdy) begin
            fvalid = 1; 
        end else begin
            fvalid = 0; 
        end
        end

        finish: begin next_state = idle; end

        default: next_state = idle; //for initializing
    endcase
end

endmodule // State_Machine
