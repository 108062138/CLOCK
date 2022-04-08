`timescale 1ns / 1ps

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

`define JAN 5'b0_0001
`define FEB 5'b0_0010
`define MAR 5'b0_0011
`define APR 5'b0_0100 
`define MAY 5'b0_0101
`define JUN 5'b0_0110
`define JUL 5'b0_0111
`define AUG 5'b0_1000
`define SEP 5'b0_1001
`define OCT 5'b0_1010
`define NOV 5'b0_1011
`define DEC 5'b0_1100

`define TWENTYEIGHT 6'b01_1100
`define THIRTY      6'b01_1110
`define THRITYONE   6'b01_1111

module watch(
input wire clk,
input wire rst,
output reg [3:0] currentUnitSec,
output reg [3:0] currentTenSec,
output reg [3:0] currentUnitMin,
output reg [3:0] currentTenMin,
output reg [3:0] currentUnitHour,
output reg [3:0] currentTenHour,
output reg [3:0] currentUnitDay,
output reg [3:0] currentTenDay,
output reg [3:0] currentUnitMonth,
output reg [3:0] currentTenMonth,
output reg [3:0] currentUnitYear,
output reg [3:0] currentTenYear,
output reg [3:0] currentHundredYear,
output reg [3:0] currentThousandYear,
output reg [4:0] cur24Cnt,
output reg [5:0] curDate,
output reg [4:0] curMonth
); 
reg [3:0] nextUnitSec;
reg [3:0] nextTenSec;
reg [3:0] nextUnitMin;
reg [3:0] nextTenMin;
reg [3:0] nextUnitHour;
reg [3:0] nextTenHour;
reg [3:0] nextUnitDay;
reg [3:0] nextTenDay;
reg [3:0] nextUnitMonth;
reg [3:0] nextTenMonth;
reg [3:0] nextUnitYear;
reg [3:0] nextTenYear;
reg [3:0] nextHundredYear;
reg [3:0] nextThousandYear;

wire [3:0] tmpUnitSec;
wire [3:0] tmpTenSec;
wire [3:0] tmpUnitMin;
wire [3:0] tmpTenMin;
wire [3:0] tmpUnitHour;
wire [3:0] tmpTenHour;

wire [3:0] tmpUnitDay;
wire [3:0] tmpTenDay;
wire [3:0] tmpUnitMonth;
wire [3:0] tmpTenMonth;

wire [3:0] tmpUnitYear;
wire [3:0] tmpTenYear;
wire [3:0] tmpHundredYear;
wire [3:0] tmpThousandYear;

wire [15:0] stuffOverFlow;
wire [15:0] reachA;
reg [15:0] cin;

reg [4:0] next24Cnt;
reg [5:0] nextDate;
reg [4:0] nextMonth;
initial begin
    cur24Cnt[4:0] = 5'b1_0111;
    curDate[5:0] = 6'b01_1000;
    curMonth[4:0] = 5'b0_1011;
    /*HOUR:MIN:SEC
        12:34:56
    */
    currentUnitSec[3:0] = `SIX;
    currentTenSec[3:0] = `FIVE;
    currentUnitMin[3:0] = `FOUR;
    currentTenMin[3:0] = `FIVE;

    currentUnitHour[3:0] = `THREE;
    currentTenHour[3:0] = `TWO;
    /*MONTH/DAY
        10/12
    */
    currentUnitDay[3:0] = `SEVEN;
    currentTenDay[3:0] = `TWO;
    currentUnitMonth[3:0] = `NINE;
    currentTenMonth[3:0] = `ONE;
    /*YEAR
        1987
    */
    currentUnitYear[3:0] = `SEVEN;
    currentTenYear[3:0] = `EIGHT;
    currentHundredYear[3:0] = `NINE;
    currentThousandYear[3:0] = `ONE;
end

ALU4bit ALUUNITSEC(.a(currentUnitSec[3:0]),.b(`ONE),.operator(`ADD),.base(`TENBASE),.s(tmpUnitSec[3:0]),.overflow(stuffOverFlow[0]),.reachA(reachA[0]));
always @(*) begin
    if(rst)begin
        cin[0] = 0;
        nextUnitSec[3:0] = `SIX;
    end else begin
        if(tmpUnitSec[3:0] >= `TEN)begin
            cin[0] = 1;
            nextUnitSec[3:0] = `ZERO;
        end else begin
            cin[0] = 0;
            nextUnitSec[3:0] = tmpUnitSec[3:0];
        end
    end
end

ALU4bit ALUTENSEC(.a(currentTenSec[3:0]),.b(cin[0]),.operator(`ADD),.base(`SIXTYBASE),.s(tmpTenSec[3:0]),.overflow(stuffOverFlow[1]),.reachA(reachA[1]));

always @(*) begin
    if(rst)begin
        cin[1] = 0;
        nextTenSec[3:0] = `FIVE;
    end else begin
        if(tmpTenSec[3:0] >= `SIX)begin
            cin[1] = 1;
            nextTenSec[3:0] = `ZERO;
        end else begin
            cin[1] = 0;
            nextTenSec[3:0] = tmpTenSec[3:0];    
        end
    end
end
ALU4bit ALUUNITMIN(.a(currentUnitMin[3:0]),.b(cin[1]),.operator(`ADD),.base(`TENBASE),.s(tmpUnitMin[3:0]),.overflow(stuffOverFlow[2]),.reachA(reachA[2]));

always @(*) begin
    if(rst)begin
        cin[2] = 0;
        nextUnitMin[3:0] = `FOUR;
    end else  begin
        if(tmpUnitMin[3:0] >= `TEN)begin
            cin[2] = 1;
            nextUnitMin[3:0] = `ZERO;
        end else begin
            cin[2] = 0;
            nextUnitMin[3:0] = tmpUnitMin[3:0];
        end
    end
end

ALU4bit ALUTENMIN(.a(currentTenMin[3:0]),.b(cin[2]),.operator(`ADD),.base(`SIXTYBASE),.s(tmpTenMin[3:0]),.overflow(stuffOverFlow[3]),.reachA(reachA[3]));
always @(*) begin
    if(rst)begin
        cin[3] = 0;
        nextTenMin[3:0] = `THREE;
    end else begin
        if(tmpTenMin[3:0]>= `SIX)begin
            cin[3] = 1;
            nextTenMin[3:0] = `ZERO;
        end else begin
            cin[3] = 0;
            nextTenMin[3:0] = tmpTenMin[3:0];
        end
    end 
end

ALU4bit ALUUNITHOUR(.a(currentUnitHour[3:0]),.b(cin[3]),.operator(`ADD),.base(`TENBASE),.s(tmpUnitHour[3:0]),.overflow(stuffOverFlow[4]),.reachA(reachA[4]));

always @(*) begin
    if(rst)begin
        cin[4] = 0;
        nextUnitHour[3:0] = `THREE;
    end else begin
        if(tmpUnitHour[3:0]>= `TEN)begin
            cin[4] = 1;
            nextUnitHour[3:0] = `ZERO;
        end else begin
            if(cur24Cnt[4:0] >= 5'b1_1000)begin
                cin[4] = 0;
                nextUnitHour[3:0] = `ZERO;
            end else begin
                cin[4] = 0;
                nextUnitHour[3:0] = tmpUnitHour[3:0]; 
            end
        end
    end
end

ALU4bit ALUTENHOUR(.a(currentTenHour[3:0]),.b(cin[4]),.operator(`ADD),.base(`TWENTYBASE),.s(tmpTenHour[3:0]),.overflow(stuffOverFlow[5]),.reachA(reachA[5]));

always @(*) begin
    if(rst)begin
        //cin[5] =0;
        nextTenHour[3:0] = `TWO;
    end else begin
        if(cur24Cnt[4:0] >= 5'b1_1000)begin
            //cin[5] = 1;
            nextTenHour[3:0] = `ZERO;
        end else begin
            //cin[5] = 0;//added
            nextTenHour[3:0] = tmpTenHour[3:0];
        end
    end
end

always @(*) begin
    if(rst)begin
        cin[5] = 0;
        next24Cnt[4:0] = 5'b1_0111;
    end else begin
        if(cur24Cnt[4:0] >= 5'b1_1000)begin
            cin[5] = 1;
            next24Cnt[4:0] = 5'b0_0000;
        end else begin
            if(cin[3]==1)begin
                cin[5] = 0;
                next24Cnt[4:0] = cur24Cnt[4:0] + 1;
            end else begin
                cin[5] = 0;
                next24Cnt[4:0] = cur24Cnt[4:0];
            end
        end
    end
end

ALU4bit ALUUNITDAY(.a(currentUnitDay[3:0]),.b(cin[5]),.operator(`ADD),.base(`TENBASE),.s(tmpUnitDay[3:0]),.overflow(stuffOverFlow[6]),.reachA(reachA[6]));

always @(*) begin//change this part
    if(rst)begin
        cin[6] = 0;
        nextUnitDay[3:0] = `SEVEN;
    end else begin
        if(curMonth[4:0] == `JAN || curMonth[4:0] == `MAR || curMonth[4:0] == `MAY || curMonth[4:0] == `JUL || curMonth[4:0] == `AUG || curMonth[4:0] == `OCT || curMonth[4:0] == `DEC)begin
            if(curDate[5:0]> `THRITYONE)begin
                cin[6] = 0;
                nextUnitDay[3:0] = `ONE;
            end else begin
                if(tmpUnitDay[3:0] >= `TEN)begin
                    cin[6] = 1;
                    nextUnitDay[3:0] = `ZERO;
                end else begin
                    cin[6] = 0;
                    nextUnitDay[3:0] = tmpUnitDay[3:0]; 
                end
            end
        end else begin
            if(curMonth[4:0] == `APR || curMonth[4:0] == `JUN || curMonth[4:0] == `NOV)begin
                if(curDate[5:0] > `THIRTY)begin
                    cin[6] = 0;
                    nextUnitDay[3:0] = `ONE;
                end else begin
                    if(tmpUnitDay[3:0] >= `TEN)begin
                        cin[6] = 1;
                        nextUnitDay[3:0] = `ZERO;
                    end else begin
                        cin[6] = 0;
                        nextUnitDay[3:0] = tmpUnitDay[3:0]; 
                    end
                end
            end else begin
                if(curDate[5:0] > `TWENTYEIGHT)begin
                    cin[6] = 0;
                    nextUnitDay[3:0] = `ONE;
                end else begin
                    if(tmpUnitDay[3:0] >= `TEN)begin
                        cin[6] = 1;
                        nextUnitDay[3:0] = `ZERO;
                    end else begin
                        cin[6] = 0;
                        nextUnitDay[3:0] = tmpUnitDay[3:0]; 
                    end
                end
            end
        end
    end 
end

ALU4bit ALUTENDAY(
.a(currentTenDay[3:0]),.b(cin[6]),.operator(`ADD),.base(`TENBASE),.s(tmpTenDay[3:0]),.overflow(stuffOverFlow[7]),.reachA(reachA[7]));

always @(*) begin//change this part
    if(rst)begin
        nextTenDay[3:0] = `TWO;
    end else begin
        //if(curDate[5:0] >= 5'b1_1100)begin
        //    nextTenDay[3:0] = `ZERO;
        //end else begin
        //    nextTenDay[3:0] = tmpTenDay[3:0];
        //end
        if(curMonth[4:0] == `JAN || curMonth[4:0] == `MAR || curMonth[4:0] == `MAY || curMonth[4:0] == `JUL || curMonth[4:0] == `AUG || curMonth[4:0] == `OCT || curMonth[4:0] == `DEC)begin
            if(curDate[5:0] > `THRITYONE)begin
                nextTenDay[3:0] = `ZERO;
            end else begin
                nextTenDay[3:0] = tmpTenDay[3:0];
            end
        end else begin
            if(curMonth[4:0] == `APR || curMonth[4:0] == `JUN || curMonth[4:0] == `NOV)begin
                if(curDate[5:0] > `THIRTY)begin
                    nextTenDay[3:0] = `ZERO;
                end else begin
                    nextTenDay[3:0] = tmpTenDay[3:0];
                end
            end else begin
                if(curDate[5:0] > `TWENTYEIGHT)begin
                    nextTenDay[3:0] = `ZERO;
                end else begin
                    nextTenDay[3:0] = tmpTenDay[3:0];
                end
            end
        end
    end
end

always @(*) begin//change this part
    if(rst)begin
        cin[7] = 0;
        nextDate[5:0] = 6'b01_1011; 
    end else begin
        if(curMonth[4:0] == `JAN || curMonth[4:0] == `MAR || curMonth[4:0] == `MAY || curMonth[4:0] == `JUL || curMonth[4:0] == `AUG || curMonth[4:0] == `OCT || curMonth[4:0] == `DEC)begin
            if(curDate[5:0] > `THRITYONE)begin
                cin[7]  = 1;
                nextDate[5:0] = 1; 
            end else begin
                cin[7] = 0; 
                if(cin[5]==1)begin
                    nextDate[5:0] = curDate[5:0] + 1;
                end else begin
                    nextDate[5:0] = curDate[5:0];
                end
            end
        end else begin
            if(curMonth[4:0] == `APR || curMonth[4:0] == `JUN || curMonth[4:0] == `NOV)begin
                if(curDate[5:0] > `THIRTY)begin
                    cin[7] = 1;
                    nextDate[5:0] = 1;
                end else begin
                    cin[7] = 0;
                    if(cin[5]==1)begin
                        nextDate[5:0] = curDate[5:0] + 1;
                    end else begin
                        nextDate[5:0] = curDate[5:0];
                    end
                end
            end else begin
                if(curDate[5:0] > `TWENTYEIGHT)begin
                    cin[7] = 1;
                    nextDate[5:0] = 1;
                end else begin
                    cin[7] = 0;
                    if(cin[5]==1)begin
                        nextDate[5:0] = curDate[5:0] + 1;
                    end else begin
                        nextDate[5:0] = curDate[5:0];
                    end
                end
            end
        end
    end
end

ALU4bit ALUUNITMONTH(.a(currentUnitMonth[3:0]),.b(cin[7]),.operator(`ADD),.base(`TENBASE),.s(tmpUnitMonth[3:0]),.overflow(stuffOverFlow[8]),.reachA(reachA[8]));

always @(*) begin//change this part
    if(rst)begin
        cin[8] = 0;
        nextUnitMonth[3:0] = `ONE;
    end else begin
        if(curMonth[4:0]>5'b0_1100)begin
            cin[8] = 0;
            nextUnitMonth[3:0] = `ONE;
        end else begin
            if(tmpUnitMonth[3:0] >=`TEN)begin
                cin[8] = 1;
                nextUnitMonth[3:0] = `ZERO;
            end else begin
                cin[8] = 0;
                nextUnitMonth[3:0] = tmpUnitMonth[3:0];
            end
        end
    end
end

ALU4bit ALUTENMONTH(
.a(currentTenMonth[3:0]),
.b(cin[8]),
.operator(`ADD),
.base(`TENBASE),
.s(tmpTenMonth[3:0]),
.overflow(stuffOverFlow[9]),
.reachA(reachA[9])
);

always @(*) begin
    if(rst)begin
        cin[9] = 0;
        nextMonth[4:0] = 5'b0_1011;
    end else begin
        if(curMonth[4:0]>5'b0_1100)begin
            cin[9] = 1;
            nextMonth[4:0] = 5'b0_0001;
        end else begin
            if(cin[7] == 1)begin
                cin[9] = 0;
                nextMonth[4:0] = curMonth[4:0] + 1;
            end else begin
                cin[9] = 0;
                nextMonth[4:0] = curMonth[4:0];
            end
        end
    end
end

always @(*) begin
    if(rst)begin
        nextTenMonth[3:0] = `ONE;
    end else begin
        if(curMonth[4:0] > 5'b0_1100)begin
            nextTenMonth[3:0] = `ZERO;
        end else begin
            nextTenMonth[3:0] = tmpTenMonth[3:0];
        end
    end
end

ALU4bit ALUUNITYEAR(.a(currentUnitYear[3:0]),.b(cin[9]),.operator(`ADD),.base(`TENBASE),.s(tmpUnitYear[3:0]),.overflow(stuffOverFlow[10]),.reachA(reachA[10]));

always @(*) begin
    if(rst)begin
        cin[10] = 0;
        nextUnitYear[3:0] = `NINE;
    end else begin
        if(tmpUnitYear[3:0] >= `TEN)begin
            cin[10] = 1;
            nextUnitYear[3:0] = `ZERO;
        end else begin
            cin[10] = 0;
            nextUnitYear[3:0] = tmpUnitYear[3:0];
        end
    end
end

ALU4bit ALUTNEYEAR(.a(currentTenYear[3:0]),.b(cin[10]),.operator(`ADD),.base(`TENBASE),.s(tmpTenYear[3:0]),.overflow(stuffOverFlow[11]),.reachA(reachA[11]));

always @(*) begin
    if(rst)begin
        cin[11] = 0;
        nextTenYear[3:0] = `NINE;
    end else begin
        if(tmpTenYear[3:0] >= `TEN)begin
            cin[11] = 1;
            nextTenYear[3:0] = `ZERO;
        end else begin
            cin[11] = 0;
            nextTenYear[3:0] = tmpTenYear[3:0];
        end
    end
end

ALU4bit ALUHUNDREDYEAR(.a(currentHundredYear[3:0]),.b(cin[11]),.operator(`ADD),.base(`TENBASE),.s(tmpHundredYear[3:0]),.overflow(stuffOverFlow[12]),.reachA(reachA[12]));

always @(*) begin
    if(rst)begin
        cin[12] = 0;
        nextHundredYear[3:0] = `NINE;
    end else begin
        if(tmpHundredYear[3:0] >= `TEN)begin
            cin[12] = 1;
            nextHundredYear[3:0] = `ZERO;
        end else begin
            cin[12] = 0;
            nextHundredYear[3:0] = tmpHundredYear[3:0];
        end
    end
end

ALU4bit ALUTHOUSNADYEAER(.a(currentThousandYear[3:0]),.b(cin[12]),.operator(`ADD),.base(`TENBASE),.s(tmpThousandYear[3:0]),.overflow(stuffOverFlow[13]),.reachA(reachA[13]));

always @(*) begin
    if(rst)begin
        cin[13] = 0;
        nextThousandYear[3:0] = `ONE;
    end else begin
        if(tmpThousandYear[3:0] >= `TEN)begin
            cin[13] = 1;
            nextThousandYear[3:0] = `ZERO;
        end else begin
            cin[13] = 0;
            nextThousandYear[3:0] = tmpThousandYear[3:0];
        end
    end
end

always @(posedge clk) begin
    cur24Cnt[4:0] <= next24Cnt[4:0];
    curDate[5:0] <= nextDate[5:0];
    curMonth[4:0] <= nextMonth[4:0];

    currentUnitSec[3:0] <= nextUnitSec[3:0];
    currentTenSec[3:0] <= nextTenSec[3:0];
    currentUnitMin[3:0] <= nextUnitMin[3:0];
    currentTenMin[3:0] <= nextTenMin[3:0];
    currentUnitHour[3:0] <= nextUnitHour[3:0];
    currentTenHour[3:0] <= nextTenHour[3:0];
    currentUnitDay[3:0] <= nextUnitDay[3:0];
    currentTenDay[3:0] <= nextTenDay[3:0];
    currentUnitMonth[3:0] <= nextUnitMonth[3:0];
    currentTenMonth[3:0] <= nextTenMonth[3:0];
    currentUnitYear[3:0] <= nextUnitYear[3:0];
    currentTenYear[3:0] <= nextTenYear[3:0];
    currentHundredYear[3:0] <= nextHundredYear[3:0];
    currentThousandYear[3:0] <= nextThousandYear[3:0];
end
endmodule
