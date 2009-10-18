//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//
//Extended MACD:
//0 - MACD Main Histogram
//1 - MACD Signal line
//2 - MACD Derivation - MACD Diff line - Difference(MACD[i+1],MACD[i])
//3 - Signal MACD Diff - Difference(MACD[i],Signa[i])
//4 - MACD vs. MACD Diff DIff - Difference(MACD[i], Difference(MACD[i+1],MACD[i]))
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 6

#property  indicator_color1  Silver
#property  indicator_width1  5

#property  indicator_color2  Red

#property  indicator_color3  Blue
#property  indicator_width3  2

#property  indicator_color4  Green
#property  indicator_width4  2

#property  indicator_color5  Yellow
#property  indicator_width5  2

#property  indicator_color6  Orange
#property  indicator_width6  2

//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
extern int MacdDiffMultiply=1;
extern int _DIFFPERIOD = 10;
extern int SignalMacdDiffMultiply=1;
extern int MacdDiffDiffMultiply=1;
extern int DBMultiply=10;
//---- indicator buffers
double     MacdBuffer[];
double     SignalBuffer[];
double     MacdDiffBuffer[];
double     SignalMacdDiffBuffer[];
double     MacdDiffDiffBuffer[];
double     DDBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
//   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexBuffer(2,MacdDiffBuffer);
   SetIndexBuffer(3,SignalMacdDiffBuffer);
   SetIndexBuffer(4,MacdDiffDiffBuffer);
   SetIndexBuffer(5,DDBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"MACDDiff");
   SetIndexLabel(3,"SignalDiff");
   SetIndexLabel(4,"MacdDiffDiff");
   SetIndexLabel(5,"DiffDiff");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
   for(int i=0; i<limit; i++)
      MacdBuffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
//---- Macd Diff line counted in the 3rd buffer
   for(i=0; i<limit; i++)
      MacdDiffBuffer[i] = MacdDiffMultiply * (MacdBuffer[i] - MacdBuffer[i+1]);

//---- Signal Diff line counted in the 4th buffer
   for(i=0; i<limit; i++)
//      SignalMacdDiffBuffer[i] = SignalMacdDiffMultiply * (MacdBuffer[i] - SignalBuffer[i]);
      SignalMacdDiffBuffer[i] = iMAOnArray(MacdDiffBuffer, Bars, _DIFFPERIOD, 0, MODE_SMA, i);
//---- Macd Diff Diff line counted in the 5th buffer
   for(i=0; i<limit; i++)
//      MacdDiffDiffBuffer[i] = MacdDiffDiffMultiply * (MathAbs(MacdBuffer[i]) - MathAbs(MacdDiffBuffer[i])) * MacdBuffer[i] / MathAbs(MacdBuffer[i]);
      MacdDiffDiffBuffer[i] = iOsMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- Diff Diff line counted in the 6th buffer
//   for(i=0; i<limit; i++)
//      DDBuffer[i] = (MacdDiffBuffer[i] - MacdDiffBuffer[i+1]);
//      DDBuffer[i] = DBMultiply*(SignalMacdDiffBuffer[i] - SignalMacdDiffBuffer[i+1]);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+