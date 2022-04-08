`timescale 1ns / 1ps

module onePulse(
input wire clk,
input wire pulse,
output wire res
);
reg s;
reg sbar;

assign res = sbar & s;

initial begin
    sbar = 1'b1;
    s = 1'b0;
end
always @(*) begin
    s = pulse;
end
always @(posedge clk) begin
    sbar <= !pulse;
end

endmodule