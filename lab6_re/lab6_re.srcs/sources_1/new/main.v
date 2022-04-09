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

module main(
input wire changeMode,
input wire rBtn,
input wire lBtn,
input wire dBtn,
input wire rst,
input wire LShift,
input wire clk,
input wire RhourShift,
input wire RminShift,
output wire [3:0]AN,
output wire [7:0]SSD,
output reg [15:0]led
);

wire clk1hz;
wire debRst,debChangeMode,debRBtn,debLBtn,debDBtn;
wire onePulseRst,onePulseChangeMode,onePulseRBtn,onePulseLBtn, onePulseDBtn;
reg [3:0]displayNumber;
reg [3:0]currentMode;
reg [3:0]nextMode;

wire [3:0] currentUnitSec;
wire [3:0] currentTenSec;
wire [3:0] currentUnitMin;
wire [3:0] currentTenMin;
wire [3:0] currentUnitHour;
wire [3:0] currentTenHour;
wire [3:0] currentUnitDay;
wire [3:0] currentTenDay;
wire [3:0] currentUnitMonth;
wire [3:0] currentTenMonth;
wire [3:0] currentUnitYear;
wire [3:0] currentTenYear;
wire [3:0] currentHundredYear;
wire [3:0] currentThousandYear;

wire [3:0] STUnitSec;
wire [3:0] STTenSec;
wire [3:0] STUnitMin;
wire [3:0] STTenMin;

wire [3:0] estALUnitMin;
wire [3:0] estALTenMin;
wire [3:0] estALUnitHour;
wire [3:0] estALTenHour;

wire [4:0] cur24Cnt;
wire [5:0] curDate;
wire [4:0] curMonth;
wire finishAL;
wire finishSW;

always @(*) begin
    led[15:12] = currentMode[3:0];  
    if(currentMode[3:0] == `SHINEAL || currentMode[3:0] == `ALARM)begin
        led[9:0] = 10'b11_1111_1111;
    end else begin
        led[9:0] = 0;
    end
end

//assign led[5:0] = curDate[5:0];
//assign led[10:6] = curMonth[4:0];

debounce RSTDEBOUNCE(.button(rst),.clk(clk),.res(debRst));
onePulse RSTOP(.clk(clk1hz),.pulse(debRst),.res(onePulseRst));

debounce RBDEBOUNCE(.button(rBtn),.clk(clk),.res(debRBtn));
onePulse RBOP(.clk(clk1hz),.pulse(debRBtn),.res(onePulseRBtn));

debounce LBDEBOUNCE(.button(lBtn),.clk(clk),.res(debLBtn));
onePulse LBOP(.clk(clk1hz),.pulse(debLBtn),.res(onePulseLBtn));

debounce DBDEBOUNCE(.button(dBtn),.clk(clk),.res(debDBtn));
onePulse DBOP(.clk(clk1hz),.pulse(debDBtn),.res(onePulseDBtn));

debounce CHANGEMODEDEBOUNCE(.button(changeMode),.clk(clk),.res(debChangeMode));
onePulse CHANGEMODEOP(.clk(clk1hz),.pulse(debChangeMode),.res(onePulseChangeMode));

watch WATCH(
.clk(clk1hz),
.rst(onePulseRst),
.currentUnitSec(currentUnitSec[3:0]),
.currentTenSec(currentTenSec[3:0]),
.currentUnitMin(currentUnitMin[3:0]),
.currentTenMin(currentTenMin[3:0]),
.currentUnitHour(currentUnitHour[3:0]),
.currentTenHour(currentTenHour[3:0]),
.currentUnitDay(currentUnitDay[3:0]),
.currentTenDay(currentTenDay[3:0]),
.currentUnitMonth(currentUnitMonth[3:0]),
.currentTenMonth(currentTenMonth[3:0]),
.currentUnitYear(currentUnitYear[3:0]),
.currentTenYear(currentTenYear[3:0]),
.currentHundredYear(currentHundredYear[3:0]),
.currentThousandYear(currentThousandYear[3:0]),
.cur24Cnt(cur24Cnt[4:0]),.curDate(curDate[5:0]),
.curMonth(curMonth[4:0]));
stopwatch StOpWaTcH(
.clk(clk1hz),
.rst(onePulseRst),
.mode(currentMode[3:0]),
.finishSW(finishSW),
.STUnitSec(STUnitSec[3:0]),
.STTenSec(STTenSec[3:0]),
.STUnitMin(STUnitMin[3:0]),
.STTenMin(STTenMin[3:0])
);

alarm ALARM(
.clk(clk1hz),
.rst(onePulseRst),
.plusHour(onePulseLBtn),
.plusMin(onePulseRBtn),
.operMin(RminShift),
.operHour(RhourShift),
.mode(currentMode[3:0]),
.curUnitMin(currentUnitMin[3:0]),
.curTenMin(currentTenMin[3:0]),
.curUnitHour(currentUnitHour[3:0]),
.curTenHour(currentTenHour[3:0]),
.finish(finishAL),
.estUnitMin(estALUnitMin[3:0]),
.estTenMin(estALTenMin[3:0]),
.estUnitHour(estALUnitHour[3:0]),
.estTenHour(estALTenHour[3:0])
);

clkDivider #(.divbit(21)) CLKDIVIDER(.clk(clk),.AN(AN[3:0]),.divclk(clk1hz));

wire [3:0] stuffAN; wire [3:0] stuffLed;
sevenSegment SEVENSEGMENT(.i(displayNumber[3:0]),.led(stuffLed[3:0]),.ssd(SSD[7:0]),.an(stuffAN[3:0]));
always @(*) begin//decide what should be projected onto the 4 bit seven segement displayer
    case (currentMode[3:0])
      `SHOWYEAR:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = currentUnitYear[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = currentTenYear[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = currentHundredYear[3:0];
                  end else begin
                      displayNumber[3:0] = currentThousandYear[3:0];
                  end
              end
          end
      end
      `SHOWDATE:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = currentUnitDay[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = currentTenDay[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = currentUnitMonth[3:0];
                  end else begin
                      displayNumber[3:0] = currentTenMonth[3:0];
                  end
              end
          end
      end
      `SHOWHOURMIN:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = currentUnitMin[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = currentTenMin[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = currentUnitHour[3:0];
                  end else begin
                      displayNumber[3:0] = currentTenHour[3:0];
                  end
              end
          end
      end
      `NORMAL:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = currentUnitMin[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = currentTenMin[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = currentUnitHour[3:0];
                  end else begin
                      displayNumber[3:0] = currentTenHour[3:0];
                  end
              end
          end
      end
      `SHOWMINSEC:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = currentUnitSec[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = currentTenSec[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = currentUnitMin[3:0];
                  end else begin
                      displayNumber[3:0] = currentTenMin[3:0];
                  end
              end
          end
      end 
      `ALARM:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = estALUnitMin[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = estALTenMin[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = estALUnitHour[3:0];
                  end else begin
                      displayNumber[3:0] = estALTenHour[3:0];
                  end
              end
          end
      end
      `SETAL:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = estALUnitMin[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = estALTenMin[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = estALUnitHour[3:0];
                  end else begin
                      displayNumber[3:0] = estALTenHour[3:0];
                  end
              end
          end
      end
      `READYAL:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = estALUnitMin[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = estALTenMin[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = estALUnitHour[3:0];
                  end else begin
                      displayNumber[3:0] = estALTenHour[3:0];
                  end
              end
          end
      end
      `PROCESSAL:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = estALUnitMin[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = estALTenMin[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = estALUnitHour[3:0];
                  end else begin
                      displayNumber[3:0] = estALTenHour[3:0];
                  end
              end
          end
      end
      `SHINEAL:begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = estALUnitMin[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = estALTenMin[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = estALUnitHour[3:0];
                  end else begin
                      displayNumber[3:0] = estALTenHour[3:0];
                  end
              end
          end
      end
      default: begin
          //this approach will be applied later
          //if(currentMode[3:0]==`ALARM || currentMode[3:0] == `SETAL || currentMode[3:0] == `READYAL || currentMode[3:0] == `PROCESSAL || currentMode[3:0] == `SHINEAL)begin
          //  
          //end else begin
          //  
          //end
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = STUnitSec[3:0];
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = STTenSec[3:0];
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = STUnitMin[3:0];
                  end else begin
                      displayNumber[3:0] = STTenMin[3:0];
                  end
              end
          end
      end
    endcase
end
always @(*) begin
    if(onePulseRst)begin
        nextMode[3:0] = `NORMAL;
    end else begin
        if(onePulseChangeMode)begin
            case (currentMode[3:0])
                `NORMAL:begin
                    nextMode[3:0] = `ALARM;
                end
                `SHOWYEAR:begin
                    nextMode[3:0] = `ALARM;
                end 
                `SHOWDATE:begin
                    nextMode[3:0] = `ALARM;
                end
                `SHOWHOURMIN:begin
                    nextMode[3:0] = `ALARM;
                end
                `SHOWMINSEC:begin
                    nextMode[3:0] = `ALARM;
                end
                `ALARM:begin
                    nextMode[3:0] = `STOPWATCH;
                end
                `SETAL:begin
                    nextMode[3:0] = `STOPWATCH;
                end
                `READYAL:begin
                    nextMode[3:0] = `STOPWATCH;
                end
                `PROCESSAL:begin
                    nextMode[3:0] = `STOPWATCH;
                end
                `SHINEAL:begin
                    nextMode[3:0] = `STOPWATCH;
                end

                default: begin
                    nextMode[3:0] = `NORMAL;
                end
            endcase
        end else begin
            if(onePulseLBtn)begin
                case (currentMode[3:0])
                    `NORMAL     :begin
                        nextMode[3:0] = `SHOWMINSEC;
                    end 
                    `SHOWYEAR   :begin
                        nextMode[3:0] = `NORMAL;
                    end 
                    `SHOWDATE   :begin
                        nextMode[3:0] = `SHOWYEAR;
                    end 
                    `SHOWHOURMIN:begin
                        nextMode[3:0] = `SHOWDATE;
                    end 
                    `SHOWMINSEC :begin
                        nextMode[3:0] = `SHOWHOURMIN;
                    end 
                    `COUNTSW:begin
                        nextMode[3:0] = `LAPSW;
                    end   
                    `LAPSW      :begin
                        nextMode[3:0] = `COUNTSW;
                    end 
                    default: begin
                        nextMode[3:0] = currentMode[3:0];
                    end
                endcase
            end else begin
                if(onePulseRBtn)begin
                    case (currentMode[3:0])
                        `NORMAL     :begin
                            nextMode[3:0] = `SHOWYEAR;
                        end
                        `SHOWYEAR   :begin
                            nextMode[3:0] = `SHOWDATE;
                        end
                        `SHOWDATE   :begin
                            nextMode[3:0] = `SHOWHOURMIN;
                        end
                        `SHOWHOURMIN:begin
                            nextMode[3:0] = `SHOWMINSEC;
                        end
                        `SHOWMINSEC :begin
                            nextMode[3:0] = `NORMAL;
                        end
                        `ALARM      :begin
                            nextMode[3:0] = `SETAL;
                        end
                        `READYAL    :begin
                            if(LShift==0)begin
                                nextMode[3:0] = `PROCESSAL;
                            end else begin
                                nextMode[3:0] = currentMode[3:0];
                            end
                        end
                        `STOPWATCH  :begin
                            nextMode[3:0] = `COUNTSW;
                        end
                        `ENDSW      :begin
                            nextMode[3:0] = `STOPWATCH;
                        end
                        default:begin
                            nextMode[3:0] = currentMode[3:0];
                        end
                    endcase                   
                end else begin
                    if(onePulseDBtn)begin
                        case (currentMode[3:0])
                            `SETAL      :begin
                                nextMode[3:0] = `READYAL;
                            end
                            `READYAL    :begin
                                nextMode[3:0] = `SETAL;
                            end
                            `COUNTSW    :begin
                                nextMode[3:0] = `STOPSW;
                            end
                            `LAPSW      :begin
                                nextMode[3:0] = `STOPSW;
                            end
                            `STOPSW     :begin
                                nextMode[3:0] = `COUNTSW;
                            end
                            default: begin
                                nextMode[3:0] = currentMode[3:0];
                            end
                        endcase                        
                    end else begin
                        case (currentMode[3:0])
                            `PROCESSAL:begin
                                if(LShift==1 || finishAL==1)begin
                                    nextMode[3:0] = `SHINEAL;
                                end else begin
                                    nextMode[3:0] = currentMode[3:0];
                                end
                            end 
                            `SHINEAL:begin
                                if(LShift==0)begin
                                    nextMode[3:0] = `ALARM;
                                end else begin
                                    nextMode[3:0] = currentMode[3:0];
                                end
                            end
                            `COUNTSW:begin
                                if(finishSW==1)begin
                                    nextMode[3:0] = `ENDSW;
                                end else begin
                                    nextMode[3:0] = currentMode[3:0];
                                end
                            end
                            default: begin
                                nextMode[3:0] = currentMode[3:0];
                            end
                        endcase
                    end
                end
            end
        end
    end
end

initial begin
    currentMode[3:0] = `NORMAL;
end

always @(posedge clk1hz) begin
    currentMode[3:0] <= nextMode[3:0];
end

endmodule
