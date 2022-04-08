`timescale 1ns / 1ps
`define SHOWYEAR 4'b0000
`define SHOWDATE 4'b0001
`define SHOWHOURMIN 4'b0010
`define SHOWMINSEC 4'b0011
`define ALARM 4'b0100
`define STOP 4'b0101 

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
input wire rst,
input wire clk,
output wire [3:0]AN,
output wire [7:0]SSD,
output wire [15:0]led
);

wire clk1hz;
wire debRst,debChangeMode,debRBtn,debLBtn;
wire onePulseRst,onePulseChangeMode,onePulseRBtn,onePulseLBtn;
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

wire [4:0] cur24Cnt;
wire [5:0] curDate;
wire [4:0] curMonth;

assign led[15:12] = currentMode[3:0];
assign led[5:0] = curDate[5:0];
assign led[10:6] = curMonth[4:0];

debounce RSTDEBOUNCE(.button(rst),.clk(clk),.res(debRst));
onePulse RSTOP(.clk(clk1hz),.pulse(debRst),.res(onePulseRst));

debounce RBDEBOUNCE(.button(rBtn),.clk(clk),.res(debRBtn));
onePulse RBOP(.clk(clk1hz),.pulse(debRBtn),.res(onePulseRBtn));

debounce LBDEBOUNCE(.button(lBtn),.clk(clk),.res(debLBtn));
onePulse LBOP(.clk(clk1hz),.pulse(debLBtn),.res(onePulseLBtn));

debounce CHANGEMODEDEBOUNCE(.button(changeMode),.clk(clk),.res(debChangeMode));
onePulse CHANGEMODEOP(.clk(clk1hz),.pulse(debChangeMode),.res(onePulseChangeMode));

watch WATCH(.clk(clk1hz),.rst(onePulseRst),.currentUnitSec(currentUnitSec[3:0]),.currentTenSec(currentTenSec[3:0]),.currentUnitMin(currentUnitMin[3:0]),.currentTenMin(currentTenMin[3:0]),.currentUnitHour(currentUnitHour[3:0]),.currentTenHour(currentTenHour[3:0]),.currentUnitDay(currentUnitDay[3:0]),.currentTenDay(currentTenDay[3:0]),.currentUnitMonth(currentUnitMonth[3:0]),.currentTenMonth(currentTenMonth[3:0]),.currentUnitYear(currentUnitYear[3:0]),.currentTenYear(currentTenYear[3:0]),.currentHundredYear(currentHundredYear[3:0]),.currentThousandYear(currentThousandYear[3:0]),.cur24Cnt(cur24Cnt[4:0]),.curDate(curDate[5:0]),.curMonth(curMonth[4:0]));

clkDivider #(.divbit(19)) CLKDIVIDER(.clk(clk),.AN(AN[3:0]),.divclk(clk1hz));

wire [3:0] stuffAN; wire [3:0] stuffLed;
sevenSegment SEVENSEGMENT(.i(displayNumber[3:0]),.led(stuffLed[3:0]),.ssd(SSD[7:0]),.an(stuffAN[3:0]));
always @(*) begin
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
      default: begin
          if(AN[3:0]==4'b1110)begin
              displayNumber[3:0] = `SEVEN;
          end else begin
              if(AN[3:0]==4'b1101)begin
                  displayNumber[3:0] = `EIGHT;
              end else begin
                  if(AN[3:0]==4'b1011)begin
                      displayNumber[3:0] = `FOUR;
                  end else begin
                      displayNumber[3:0] = `FIVE;
                  end
              end
          end
      end
    endcase
end
always @(*) begin
    if(onePulseChangeMode==1)begin
        case (currentMode[3:0])
          `ALARM:begin
              nextMode[3:0] = `STOP;
          end 
          `STOP:begin
              nextMode[3:0] = `SHOWYEAR;
          end
          default: begin
              nextMode[3:0] = `STOP;
          end
        endcase
    end else begin
        if (onePulseLBtn==1)begin
            casex (currentMode[3:0])
                `SHOWYEAR:begin
                    nextMode[3:0] = `SHOWMINSEC;
                end 
                `SHOWDATE:begin
                    nextMode[3:0] = `SHOWYEAR;
                end
                `SHOWHOURMIN:begin
                    nextMode[3:0] = `SHOWDATE;
                end
                `SHOWMINSEC:begin
                    nextMode[3:0] = `SHOWHOURMIN;
                end
                default:begin
                    nextMode[3:0] = currentMode[3:0];
                end
            endcase
        end else begin
            if (onePulseRBtn==1) begin
                casex (currentMode[3:0])
                  `SHOWYEAR:begin
                      nextMode[3:0] = `SHOWDATE;
                  end 
                  `SHOWDATE:begin
                      nextMode[3:0] = `SHOWHOURMIN;
                  end
                  `SHOWHOURMIN:begin
                      nextMode[3:0] = `SHOWMINSEC;
                  end
                  `SHOWMINSEC:begin
                      nextMode[3:0] = `SHOWYEAR;
                  end
                  default:begin
                      nextMode[3:0] = currentMode[3:0];
                  end
                endcase
            end else begin
                nextMode[3:0] = currentMode[3:0];
            end
        end
    end
end

initial begin
    currentMode[3:0] = `SHOWYEAR;
end

always @(posedge clk1hz) begin
    currentMode[3:0] <= nextMode[1:0];
end

endmodule
