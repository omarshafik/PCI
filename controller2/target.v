module Target_Controller(
    input clk, inout[31:0] AD, input[3:0] C_BE, output devsel, output trdy, input[2:0] state, input fvalid
    );

parameter[3:0]
/* Command value for read = 1, write = 0 */
read = 1, write = 0;

parameter[2:0] idle=0, address=1, turnaround=2, data=3, finish=4;
parameter[31:0] devaddress = 1;
reg[31:0] add;
reg[31:0] memory;
reg[3:0] command;
always @ (posedge clk) begin
    if (state == address) begin
        add <= AD;
        command <= C_BE; 
    end
    if(state == data && command == write) begin
        if(C_BE[0]) begin
            memory[7:0] <= AD[7:0]; 
        end
        if(C_BE[1]) begin
            memory[15:8] <= AD[15:8];  
        end
        if(C_BE[2]) begin
            memory[23:16] <= AD[23:16];  
        end
        if(C_BE[3]) begin
            memory[31:24] <= AD[31:24];  
        end
    end
end

assign devsel = (state == data && add == devaddress) ? 0 : (state == finish || state == turnaround) ? 1 : 1'bz;
assign trdy = (state == data && add == devaddress) ? 0 : (state == finish || state == turnaround) ? 1 : 1'bz;
assign AD = (state == data && add == devaddress && command == read) ?  32'hAAAAAAAA: 32'hZZZZZZZZ;

endmodule   //target read module