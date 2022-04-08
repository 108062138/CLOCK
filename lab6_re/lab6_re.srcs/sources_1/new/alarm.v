`timescale 1ns / 1ps

module alarm(
input wire clk,
input wire rst,
input wire OK,
input wire plusHr,
input wire plusMin,
output reg [3:0] curBorUnitMin,
output reg [3:0] curBorTenMin,
output reg [3:0] curBorUnitHour,
output reg [3:0] curBorTenHour
);



endmodule
