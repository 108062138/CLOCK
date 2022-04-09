`timescale 1ns / 1ps

`define NORMAL      4'b0000
`define SHOWYEAR    4'b0001
`define SHOWDATE    4'b0010
`define SHOWHOURMIN 4'b0011
`define SHOWMINSEC  4'b0100
`define ALARM       4'b0101
`define SETAL       4'b0110
`define READYAL     4'b0111
`define PROCESSAL   4'b1000
`define SHINEAL     4'b1001
`define STOPWATCH   4'b1010
`define COUNTSW     4'b1011
`define LAPSW       4'b1100
`define STOPSW      4'b1101
`define ENDSW       4'b1110

`define ZERO  4'b0000
`define ONE   4'b0001
`define TWO   4'b0010
`define THREE 4'b0011
`define FOUR  4'b0100
`define FIVE  4'b0101
`define SIX   4'b0110
`define SEVEN 4'b0111
`define EIGHT 4'b1000
`define NINE  4'b1001
`define TEN   4'b1010

module stopwatch(
input wire clk,
input wire rst,
input wire [3:0] mode,
output reg finishSW,
output reg [3:0] STUnitSec,
output reg [3:0] STTenSec,
output reg [3:0] STUnitMin,
output reg [3:0] STTenMin
);

reg [3:0] curAccUnitSec;
reg [3:0] curAccTenSec;
reg [3:0] curAccUnitMin;
reg [3:0] curAccTenMin;

wire [3:0] tmpAccUnitSec;
wire [3:0] tmpAccTenSec;
wire [3:0] tmpAccUnitMin;
wire [3:0] tmpAccTenMin;

reg [3:0] nextAccUnitSec;
reg [3:0] nextAccTenSec;
reg [3:0] nextAccUnitMin;
reg [3:0] nextAccTenMin;

reg [3:0] remUnitSec;
reg [3:0] remTenSec;
reg [3:0] remUnitMin;
reg [3:0] remTenMin;

reg [3:0] nextRemUnitSec;
reg [3:0] nextRemTenSec;
reg [3:0] nextRemUnitMin;
reg [3:0] nextRemTenMin;

wire [15:0] reachA;
wire [15:0] stuffOverFlow;
reg [15:0] cin;

always @(*) begin
    if(mode[3:0] == `LAPSW)begin
        STUnitSec[3:0] = remUnitSec[3:0];
        STTenSec[3:0] = remTenSec[3:0];
        STUnitMin[3:0] = remUnitMin[3:0];
        STTenMin[3:0] = remTenMin[3:0];
    end else begin
        STUnitSec[3:0] = curAccUnitSec[3:0];
        STTenSec[3:0] = curAccTenSec[3:0];
        STUnitMin[3:0] = curAccUnitMin[3:0];
        STTenMin[3:0] = curAccTenMin[3:0]; 
    end
end

always @(*) begin
    if(mode[3:0] == `LAPSW)begin
        nextRemUnitSec[3:0] = remUnitSec[3:0];
        nextRemTenSec[3:0]  = remTenSec[3:0];
        nextRemUnitMin[3:0] = remUnitMin[3:0];
        nextRemTenMin[3:0]  = remTenMin[3:0];
    end else begin
        nextRemUnitSec[3:0] = curAccUnitSec[3:0];
        nextRemTenSec[3:0] =  curAccTenSec[3:0];
        nextRemUnitMin[3:0] = curAccUnitMin[3:0];
        nextRemTenMin[3:0] =  curAccTenMin[3:0];
    end
end

ALU4bit ALUACCUNITSEC(
.a(curAccUnitSec[3:0]),
.b(`ONE),
.operator(`ADD),
.base(`TENBASE),
.s(tmpAccUnitSec[3:0]),
.overflow(stuffOverFlow[0]),
.reachA(reachA[0]));

always @(*) begin
    if(rst)begin
        cin[0] = 0;
        nextAccUnitSec[3:0] = `ZERO;
    end else begin
        case (mode[3:0])
            `STOPWATCH:begin
                cin[0] = 0;
                nextAccUnitSec[3:0] = `ZERO;
            end
            `ENDSW:begin
                cin[0] = 0;
                nextAccUnitSec[3:0] = `ZERO;
            end
            `COUNTSW:begin
                if(tmpAccUnitSec[3:0] >= `TEN)begin
                    cin[0] = 1;
                    nextAccUnitSec[3:0] = `ZERO;
                end else begin
                    cin[0] = 0;
                    nextAccUnitSec[3:0] = tmpAccUnitSec[3:0];
                end
            end
            `LAPSW:begin
                if(tmpAccUnitSec[3:0] >= `TEN)begin
                    cin[0] = 1;
                    nextAccUnitSec[3:0] = `ZERO;
                end else begin
                    cin[0] = 0;
                    nextAccUnitSec[3:0] = tmpAccUnitSec[3:0];
                end
            end
            `STOPSW:begin
                cin[0] = 0;
                nextAccUnitSec[3:0] = curAccUnitSec[3:0];
            end
            default: begin
                cin[0] = 0;
                nextAccUnitSec[3:0] = `ZERO;
            end
        endcase     
    end
end

ALU4bit ALUACCTENSEC(
.a(curAccTenSec[3:0]),
.b(cin[0]),
.operator(`ADD),
.base(`TENBASE),
.s(tmpAccTenSec[3:0]),
.overflow(stuffOverFlow[1]),
.reachA(reachA[1]));

always @(*) begin
    if(rst)begin
        cin[1] = 0;
        nextAccTenSec[3:0] = `ZERO;
    end else begin
        case (mode[3:0])
            `STOPWATCH:begin
                cin[1] = 0;
                nextAccTenSec[3:0] = `ZERO;
            end
            `ENDSW:begin
                cin[1] = 0;
                nextAccTenSec[3:0] = `ZERO;
            end
            `COUNTSW:begin
                if(tmpAccTenSec[3:0] >= `SIX)begin
                    cin[1] = 1;
                    nextAccTenSec[3:0] = `ZERO;
                end else begin
                    cin[1] = 0;
                    nextAccTenSec[3:0] = tmpAccTenSec[3:0];
                end
            end
            `LAPSW:begin
                if(tmpAccTenSec[3:0] >= `SIX)begin
                    cin[1] = 1;
                    nextAccTenSec[3:0] = `ZERO;
                end else begin
                    cin[1] = 0;
                    nextAccTenSec[3:0] = tmpAccTenSec[3:0];
                end
            end
            `STOPSW:begin
                cin[1] = 0;
                nextAccTenSec[3:0] = curAccTenSec[3:0];
            end
            default: begin
                cin[1] = 0;
                nextAccTenSec[3:0] = `ZERO;
            end
        endcase     
    end
end

ALU4bit ALUACCUNITMIN(
.a(curAccUnitMin[3:0]),
.b(cin[1]),
.operator(`ADD),
.base(`TENBASE),
.s(tmpAccUnitMin[3:0]),
.overflow(stuffOverFlow[2]),
.reachA(reachA[2]));

always @(*) begin
    if(rst)begin
        cin[2] = 0;
        nextAccUnitMin[3:0] = `ZERO;
    end else begin
        case (mode[3:0])
            `STOPWATCH:begin
                cin[2] = 0;
                nextAccUnitMin[3:0] = `ZERO;
            end
            `ENDSW:begin
                cin[2] = 0;
                nextAccUnitMin[3:0] = `ZERO;
            end
            `COUNTSW:begin
                if(tmpAccUnitMin[3:0] >= `TEN)begin
                    cin[2] = 1;
                    nextAccUnitMin[3:0] = `ZERO;
                end else begin
                    cin[2] = 0;
                    nextAccUnitMin[3:0] = tmpAccUnitMin[3:0];
                end
            end
            `LAPSW:begin
                if(tmpAccUnitMin[3:0] >= `TEN)begin
                    cin[2] = 1;
                    nextAccUnitMin[3:0] = `ZERO;
                end else begin
                    cin[2] = 0;
                    nextAccUnitMin[3:0] = tmpAccUnitMin[3:0];
                end
            end
            `STOPSW:begin
                cin[2] = 0;
                nextAccUnitMin[3:0] = curAccUnitMin[3:0];
            end
            default: begin
                cin[2] = 0;
                nextAccUnitMin[3:0] = `ZERO;
            end
        endcase     
    end
end

ALU4bit ALUACCTENMIN(
.a(curAccTenMin[3:0]),
.b(cin[2]),
.operator(`ADD),
.base(`TENBASE),
.s(tmpAccTenMin[3:0]),
.overflow(stuffOverFlow[3]),
.reachA(reachA[3]));

always @(*) begin
    if(rst)begin
        finishSW = 0;
        nextAccTenMin[3:0] = `ZERO;
    end else begin
        case (mode[3:0])
            `STOPWATCH:begin
                finishSW = 0;
                nextAccTenMin[3:0] = `ZERO;
            end
            `ENDSW:begin
                finishSW = 0;
                nextAccTenMin[3:0] = `ZERO;
            end
            `COUNTSW:begin
                if(tmpAccTenMin[3:0] >= `SIX)begin
                    finishSW = 1;//
                    nextAccTenMin[3:0] = `ZERO;
                end else begin
                    finishSW = 0;
                    nextAccTenMin[3:0] = tmpAccTenMin[3:0];
                end
            end
            `LAPSW:begin
                if(tmpAccTenMin[3:0] >= `SIX)begin
                    finishSW = 1;//
                    nextAccTenMin[3:0] = `ZERO;
                end else begin
                    finishSW = 0;
                    nextAccTenMin[3:0] = tmpAccTenMin[3:0];
                end
            end
            `STOPSW:begin
                finishSW = 0;
                nextAccTenMin[3:0] = curAccTenMin[3:0];
            end
            default: begin
                finishSW = 0;
                nextAccTenMin[3:0] = `ZERO;
            end
        endcase     
    end
end

always @(posedge clk) begin
    curAccUnitSec[3:0] <= nextAccUnitSec[3:0];
    curAccTenSec[3:0]  <= nextAccTenSec[3:0];
    curAccUnitMin[3:0] <= nextAccUnitMin[3:0];
    curAccTenMin[3:0]  <= nextAccTenMin[3:0];

    remUnitSec[3:0] <= nextRemUnitSec[3:0];
    remTenSec[3:0]  <= nextRemTenSec[3:0];
    remUnitMin[3:0] <= nextRemUnitMin[3:0];
    remTenMin[3:0]  <= nextRemTenMin[3:0];
end

endmodule 
