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

module alarm(
input wire clk,
input wire rst,
input wire plusHour,
input wire plusMin,
input wire operMin,
input wire operHour,
input wire [3:0] mode,
input wire [3:0] curUnitMin,
input wire [3:0] curTenMin,
input wire [3:0] curUnitHour,
input wire [3:0] curTenHour,
output reg finish,
output reg [3:0] estUnitMin,
output reg [3:0] estTenMin,
output reg [3:0] estUnitHour,
output reg [3:0] estTenHour
);

reg [3:0] nextEstUnitMin;
reg [3:0] nextEstTenMin;
reg [3:0] nextEstUnitHour;
reg [3:0] nextEstTenHour;

wire [3:0] tmpEstUnitMin;
wire [3:0] tmpEstTenMin;
wire [3:0] tmpEstUnitHour;
wire [3:0] tmpEstTenHour;

wire [7:0] stuffOverFlow;
wire [7:0] reachA;
reg [7:0] cin;
always @(*) begin
    if(mode[3:0] == `PROCESSAL || mode[3:0] == `ALARM|| mode[3:0] == `SHINEAL)begin
        if(estUnitMin[3:0]==curUnitMin[3:0]&&estTenMin[3:0]==curTenMin[3:0]&&estUnitHour[3:0]==curUnitHour[3:0]&&estTenHour[3:0]==curTenHour[3:0])begin
            finish = 1;
        end else begin
            finish = 0;
        end
    end else begin
        finish = 0;
    end
end

ALU4bit ALUALUNITMIN(
.a(estUnitMin[3:0]),
.b(plusMin),
.operator(operMin),
.base(`TENBASE),
.s(tmpEstUnitMin[3:0]),
.overflow(stuffOverFlow[0]),
.reachA(reachA[0]));

always @(*) begin
    if(rst)begin
        cin[0] = 0;
        nextEstUnitMin[3:0] = `ZERO;
    end else begin
        if(mode== `SETAL)begin
            if(tmpEstUnitMin[3:0] >= `TEN)begin
                if(operMin==0)begin
                    cin[0] = 1;
                    nextEstUnitMin[3:0] = `ZERO;
                end else begin
                    cin[0] = 1;
                    nextEstUnitMin[3:0] = `NINE;
                end
            end else begin
                cin[0] = 0;
                nextEstUnitMin[3:0] = tmpEstUnitMin[3:0];
            end
        end else begin
            cin[0] = 0;
            nextEstUnitMin[3:0] = estUnitMin[3:0];
        end
    end
end

ALU4bit ALUALTENMIN(
.a(estTenMin[3:0]),
.b(cin[0]),
.operator(operMin),
.base(`TENBASE),
.s(tmpEstTenMin[3:0]),
.overflow(stuffOverFlow[1]),
.reachA(reachA[1]));

always @(*) begin
    if(rst)begin
        nextEstTenMin[3:0] = `ZERO;
    end else begin
        if(mode== `SETAL)begin
            if(tmpEstTenMin[3:0] >= `SIX)begin
                nextEstTenMin[3:0] = `ZERO;
            end else begin
                nextEstTenMin[3:0] = tmpEstTenMin[3:0];
            end
        end else begin
            nextEstTenMin[3:0] = estTenMin[3:0];
        end
    end
end

ALU4bit ALUALUNITHOUR(
.a(estUnitHour[3:0]),
.b(plusHour),
.operator(operHour),
.base(`TENBASE),
.s(tmpEstUnitHour[3:0]),
.overflow(stuffOverFlow[2]),
.reachA(reachA[2]));
reg [4:0] cur24Cnt;
reg [4:0] next24Cnt;
always @(*) begin
    if(rst)begin
        cin[1] = 0;
        next24Cnt[4:0] = 0;
        nextEstUnitHour[3:0] = `ZERO;
    end else begin
        if(cur24Cnt[4:0] >= 5'b1_1000)begin
            cin[1] = 0;
            next24Cnt[4:0] = 0;
            nextEstUnitHour[3:0] = `ZERO;
        end else begin
            if(mode== `SETAL)begin
                if(operHour==0)begin
                    next24Cnt[4:0] = cur24Cnt[4:0] + plusHour;
                end else begin
                    if(cur24Cnt[4:0] - 1 >= 5'b1_1000)begin
                        next24Cnt[4:0] = 5'b1_0111;
                    end else begin
                        next24Cnt[4:0] = cur24Cnt[4:0] - plusHour;
                    end
                end

                if(tmpEstUnitHour[3:0] >= `TEN)begin
                    if(operHour==0)begin
                       cin[1] = 1;
                        nextEstUnitHour[3:0] = `ZERO; 
                    end else begin
                        cin[1] = 1;
                        nextEstUnitHour[3:0] = `NINE;
                    end
                end else begin
                    cin[1] = 0;
                    nextEstUnitHour[3:0] = tmpEstUnitHour[3:0];
                end
            end else begin
                next24Cnt[4:0] = cur24Cnt[4:0];
                cin[1] = 0;
                nextEstUnitHour[3:0] = estUnitHour[3:0];
            end 
        end
    end
end

ALU4bit ALUALTENHOUR(
.a(estTenHour[3:0]),
.b(cin[1]),
.operator(operHour),
.base(`TENBASE),
.s(tmpEstTenHour[3:0]),
.overflow(stuffOverFlow[2]),
.reachA(reachA[2]));

always @(*) begin
    if(rst)begin
        nextEstTenHour[3:0] = `ZERO;
    end else begin
        if(cur24Cnt[4:0] >= 5'b1_1000)begin
            nextEstTenHour[3:0] = `ZERO;
        end else begin
            if(mode==`SETAL)begin
                if(tmpEstTenHour[3:0] >= `THREE)begin
                    nextEstTenHour[3:0] = `ZERO;
                end else begin
                    nextEstTenHour[3:0] = tmpEstTenHour[3:0];
                end
            end else begin
                nextEstTenHour[3:0] = estTenHour[3:0];
            end  
        end
    end
end

always @(posedge clk) begin
    cur24Cnt[4:0] <= next24Cnt[4:0];
    estUnitMin[3:0] <= nextEstUnitMin[3:0];
    estTenMin[3:0] <= nextEstTenMin[3:0];
    estUnitHour[3:0] <= nextEstUnitHour[3:0];
    estTenHour[3:0] <= nextEstTenHour[3:0];
end

endmodule
