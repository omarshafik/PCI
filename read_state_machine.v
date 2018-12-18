module Read_State_Machine(
    frame, irdy, trdy, devsel, state, clk
);

input wire frame, irdy, trdy, devsel, clk;
output reg[2:0] state;
reg[2:0] next_state;

parameter[2:0] 
/* phases are four; 
1. idle : bus is free.
2. address : initiator waiting for a device to identify itself as the target.
3. data wait : bus is on hold as any of #RDY signals are deasserted (no transaction occurs).
4. data : transaction occurs.
5. final : final transaction occurs then bus waits for initiator to deassert IRDY.
*/
idle=0, address=1, data_wait=2, data=3, final=4;

always @(posedge clk) begin
    state <= next_state;
end

always @(*) begin
    case (state)

        idle: if (~frame) begin
            next_state = address;
        end

        address: if (~devsel) begin
            next_state = data_wait;
        end

        data_wait: if (~(idry & trdy)) begin
            next_state = data;
        end

        data: if (frame & ~irdy & ~trdy) begin
            next_state = final;
        end
        if (irdy | trdy) begin
            next_state = data_wait; 
        end
        final: if (irdy) begin
            next_state = idle;
        end

        default: next_state = idle; //for initializing
    endcase
end

endmodule // State_Machine