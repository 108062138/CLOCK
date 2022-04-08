`timescale 1ns / 1ps

module debounce(
input wire button,
input wire clk,
output reg res
);

reg [2:0] currentState;
reg [2:0] nextState;

initial begin
    currentState[2:0] = 3'b000;
end

always @(posedge clk) begin
    currentState[2:0] <= nextState[2:0];
end

always @(*) begin
    if(currentState[2:0] == 3'b100)begin
        res = 1;
    end else begin
        res = 0;
    end
end

always @(*) begin
    case (currentState[2:0])
        3'b000: begin
            nextState[2:0] = (button)?3'b001:3'b000;
        end
        3'b001: begin
            nextState[2:0] = (button)?3'b010:3'b000;
        end
        3'b010: begin
            nextState[2:0] = (button)?3'b011:3'b000;
        end
        3'b011: begin
            nextState[2:0] = (button)?3'b100:3'b000;
        end
        default: begin
            //nextState[2:0] = 3'b000;
            nextState[2:0] = (button)?3'b100:3'b000;
        end
    endcase
end
endmodule