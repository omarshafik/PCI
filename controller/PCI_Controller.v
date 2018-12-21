`timescale 1us / 1ps

module Device_Controller(clk,reset,frame,AD,C_BE,irdy,trdy,DevSel,req,gnt,
force_request,ADTC,CB,Device_Address);
input clk,reset,gnt,force_request;
input [31:0] ADTC,Device_Address;
input [3:0] CB;
inout frame,irdy,trdy,DevSel;
output reg req;
inout [31:0] AD;
inout [3:0] C_BE;
reg frm,irdyB,trdyB,ds;
reg [3:0] CMD,BE;
reg [31:0] ADB;
reg [1:0] role;
reg [2:0] state,previous_state,counter,DPh;
reg [31:0] memory [0:7];  //for storing entry
reg [2:0] mp;             //memmory pointer

parameter [1:0]
	target=2'b00,
	initiator=2'b01,
	idle=2'b11;

parameter[2:0] 
	bus_granted=3'b000,
	device_select=3'b001,
	RDY=3'b010,
	Check=3'b011,
	transaction=3'b100;

assign frame = frm;
assign irdy = irdyB;
assign trdy = trdyB;
assign DevSel = ds;
assign AD = ADB;
assign C_BE = (irdyB)? CMD:BE;

always @(force_request,reset)
begin
	if(!force_request) begin
		req <= 1'b0;	
	end
	if(reset) begin
		counter <= 3'b000;
		role <= idle;
	end
end

always @(posedge clk)
begin
	if(force_request)
	begin     
       counter <= counter + 1; 
   end
	if(!gnt && frame && irdy && (previous_state == transaction || role == idle)) begin
		role <= initiator;
		state <= bus_granted;
	end
	else if(AD == Device_Address && !frame && irdy) begin
		role <= target;
		state <= device_select;
	end
	else if(previous_state == bus_granted || previous_state == device_select) begin
		state <= RDY;
		DPh <= CMD[3:1];
	end
	else if(CMD[0]==1'b0 && previous_state == RDY) begin
		state <= Check;
	end
	else if(!irdy && !trdy) begin
		ADB <= AD;
		BE <= C_BE;
		if(previous_state == Check || previous_state == RDY) begin
			state <= transaction;
			mp <= 3'b000;
		end
		else if(DPh!=3'b000) begin
			DPh <= DPh - 1;
		end
	end
	else if(frame && irdy && previous_state == transaction) begin
		role <= idle;
	end
end

always @(negedge clk)
begin
		if(role == initiator)
		begin
			case(state)
				bus_granted: begin
					frm <= 1'b0;
					ADB <= ADTC;
					CMD <= CB;
				end
				RDY: begin
					irdyB <= 1'b0;
					BE <= CB;
					if(CMD[0]==1'b0) begin
						ADB <= 8'hzzzzzzzz;
					end
					else if(CMD[0]==1'b1) begin
						ADB <= ADTC;
						if(DPh==3'b000) begin
							frm <= 1'b1;
						end
					end
				end
				Check: begin
					if(DPh==3'b000) begin
						frm <= 1'b1;
					end
				end
				transaction: begin
					if(DPh==3'b001) begin
						frm <= 1'b1;
					end
					else if(DPh==3'b000) begin
						irdyB <= 1'b1;
						ADB <= 8'hzzzzzzzz;
						CMD <= 4'bzzzz;
					end
					if(CMD[0]==1'b0) begin
						memory[mp] <= ADB;
						mp <= mp + 1;
					end
				end
			endcase
		end
		else if(role == target)
		begin
			case(state)
				device_select: begin
					ds <= 1'b0;
					if(CMD[0]==1'b1) begin
						trdyB <= 1'b0;
					end
				end
				RDY: begin
					if(CMD[0]==1'b0) begin
						ADB <= ADTC;
						trdyB <= 1'b0;
					end
					else if(CMD[0]==1'b1) begin
						ADB <= 8'hzzzzzzzz;
					end
				end
				transaction: begin
					if(DPh==3'b000) begin
						trdyB <= 1'b1;
						ds <= 1'b1;
						ADB <= 8'hzzzzzzzz;
					end
					if(CMD[0]==1'b1) begin
						if(BE[0]==1'b1) begin
							memory[mp][7:0] <= ADB[7:0];
						end
						if(BE[1]==1'b1) begin
							memory[mp][15:8] <= ADB[15:8];
						end
						if(BE[2]==1'b1) begin
							memory[mp][23:16] <= ADB[23:16];
						end
						if(BE[3]==1'b1) begin
							memory[mp][31:24] <= ADB[31:24];
						end
						mp <= mp + 1;
					end
				end
			endcase
		end
		previous_state <= state;
end

endmodule
