module Target_Controller(
    input clk, inout[31:0] AD, input[3:0] C_BE, output devsel, output trdy, input[2:0] state, input fvalid, input[1:0] tar_address, input frame
    );

parameter[3:0]
/* Command value for read = 1, write = 0 */
read = 1, write = 0;

parameter[2:0] idle=0, address=1, turnaround=2, data=3, finish=4;
reg[31:0] add;
reg[31:0] memory[0:9];
reg[3:0] mp;
wire[31:0] mem1; assign mem1 = memory[0];
wire[31:0] mem2; assign mem2 = memory[1];    
wire[31:0] mem3; assign mem3 = memory[2];
wire[31:0] mem4; assign mem4 = memory[3];
reg[3:0] command;
always @ (posedge clk) begin
    if (!frame && state == idle) begin
        add <= AD;
        command <= C_BE; 
        mp <= 0;
    end
    if(state == data && fvalid && add === tar_address) begin
        if(C_BE[0]) begin
            memory[mp][7:0] <= AD[7:0]; 
        end
        if(C_BE[1]) begin
            memory[mp][15:8] <= AD[15:8];  
        end
        if(C_BE[2]) begin
            memory[mp][23:16] <= AD[23:16];  
        end
        if(C_BE[3]) begin
            memory[mp][31:24] <= AD[31:24];  
        end
    end
    if(state == finish) begin
        add <= 32'hZZZZZZZZ;
    end
end
always @ (negedge clk) begin
    if (state == data && command == write && fvalid && add === tar_address) begin
        mp <= mp + 1; 
    end
end

assign devsel = (state == data && add === tar_address) ? 0 : ((state == finish || state == turnaround || !frame) && add === tar_address) ? 1 : 1'bz;
assign trdy = (state == data && add === tar_address) ? 0 : ((state == finish || state == turnaround || !frame) && add === tar_address) ? 1 : 1'bz;
assign AD = (state == data && add === tar_address && command == read) ?  memory[mp]: 32'hZZZZZZZZ;

endmodule   //target read module