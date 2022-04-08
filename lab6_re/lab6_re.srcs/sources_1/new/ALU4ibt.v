`define TENBASE 3'b000
`define SIXTYBASE 3'b001 
`define TWENTYBASE 3'b010
`define ADD 1'b0
`define MINUS 1'b1

module ALU4bit(
input [3:0] a,
input [3:0] b,
input operator,
input [2:0] base,
output [3:0] s,
output overflow,
output reg reachA
);
wire [4:0] C;
FullAdder FA0(.x(a[0]), .y(operator ^ b[0]),.cin( operator), .A(s[0]) ,.cout(C[1]));
FullAdder FA1(.x(a[1]), .y(operator ^ b[1]),.cin(     C[1]), .A(s[1]) ,.cout(C[2]));
FullAdder FA2(.x(a[2]), .y(operator ^ b[2]),.cin(     C[2]), .A(s[2]) ,.cout(C[3]));
FullAdder FA3(.x(a[3]), .y(operator ^ b[3]),.cin(     C[3]), .A(s[3]) ,.cout(C[4]));
assign overflow = C[4] ^ C[3];
initial begin
    reachA = 1'b0;
end
always @(*) begin
    case (base[2:0])
        `TENBASE:begin
            if (s[3:0]>=4'b1010) begin//meet 10 then upgrade
                reachA = 1'b1;
            end else begin
                reachA = 1'b0;
            end
        end
        `SIXTYBASE:begin
            if (s[3:0]>=4'b0110) begin//meet 6 then upgrade
                reachA = 1'b1;
            end else begin
                reachA = 1'b0;
            end
        end
        default: begin
            if (s[3:0]>=4'b0110) begin//meet 6 then upgrade
                reachA = 1'b1;
            end else begin
                reachA = 1'b0;
            end 
        end
    endcase
end
endmodule

module FullAdder (
input wire x,
input wire y,
input wire cin,
output wire A,
output wire cout
);

wire p,r,s;
assign p = x ^ y;
assign r = cin & p;
assign s = x & y;
assign cout = r | s;
assign A = cin ^ p;
endmodule