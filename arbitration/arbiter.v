module arbiter(
    req, grant
);

input[3:0] req;
output reg[3:0] grant;

always @(posedge clk) begin
    if (~req[0]) begin
        grant <= 4'b1110;
    end else if(~req[1]) begin
        grant <= 4'b1101;
    end else if(~req[2]) begin
        grant <= 4'b1011;
    end else if(~req[3]) begin
        grant <= 4'b0111;
    end else begin
        grant <= 4'b1111;
    end
end

endmodule // arbiter