/*///——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

    IndicatorTester.mq4 
  
    Visual Testing the Profitability of Indicators and Alerts
    
    Copyright © 2008, Sergey Kravchuk,  http://forextools.com.ua

/*///——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
#property copyright "Copyright © 2006-2008, Sergey Kravchuk. http://forextools.com.ua"
#property link      "http://forextools.com.ua"

#property indicator_chart_window
#property indicator_buffers 0

// parameters for displaying the elements of the chart
extern bool   ShowZZ          = true;           // should the ZZ be drawn?
extern bool   ShowMARKERS     = true;           // should the vertical marking lines be drawn?

//dates of drawing the chart
extern datetime DateStart     = D'1.01.1970';
extern datetime DateEnd       = D'31.12.2037';

//parameters of profit calculations
extern double LotForCalc      = 0.05;           // the amount of lots for profit calculations
extern int    Optimizm        = 0;              // -1 gives a pessimistic calculation; 0 gives the calculation on bar opening prices; +1 is optimistic

// parameters of MA indicator
extern int    MAPeriod        = 15;             // MA calculation period
extern int    MAMode          = 3;              // 0-MODE_SMA 1-MODE_EMA 2-MODE_SMMA 3-MODE_LWMA
extern int    MAPrice         = 6;              // 0-Close 1-Open 2-High 3-Low 4-(H+L)/2 5-(H+L+C)/3 6-(H+L+2*C)/4

// parameters of MACD indicator
extern double MACDOpenLevel   = 3;              
extern double MACDCloseLevel  = 2;
extern double MATrendPeriod   = 26;

// BUY lines colors
extern color  ColorProfitBuy  = Blue;           // line color for profitable BUY trades
extern color  ColorLossBuy    = Red;            // line color for losing BUY trades
extern color  ColorZeroBuy    = Gray;           // line color for BUY trades with zero profits

// SELL lines colors
extern color  ColorProfitSell = Blue;           // line color for profitable SELL trades
extern color  ColorLossSell   = Red;            // line color for losing SELL trades
extern color  ColorZeroSell   = Gray;           // line color for SELL trades with zero profits

// alert lines colors
extern color  ColorBuy        = CornflowerBlue; // line color for BUY alerts
extern color  ColorSell       = HotPink;        // line color for SELL alerts
extern color  ColorClose      = Gainsboro;      // line color for closing alerts

//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
double sBuy[],sCloseBuy[],sSell[],sCloseSell[]; // arrays for alerts
int sBuyCnt,sSellCnt,sBuyCloseCnt,sSellCloseCnt;// alerts counters 
int i,DisplayBars;
//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// service codes
#define MrakerPrefix "IT_"
#define OP_CLOSE_BUY  444
#define OP_CLOSE_SELL 555
//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
int init()   { ClearMarkers(); return(0); }
int deinit() { ClearMarkers(); return(0); }
//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
int start() 
{ 
  double Profit=0,P1,P2; int CntProfit=0,CntLoose=0,i1,i2;

  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // delete all marks, in case the indicator is going to be redrawn
  ClearMarkers(); 
  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // prepare alerts counters
  sBuyCnt=0; sSellCnt=0; sBuyCloseCnt=0; sSellCloseCnt=0; 
  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // allocate some memory for alerts arrays and zeroize their values
  DisplayBars=Bars; // the amount of bars to be displayed
  ArrayResize(sBuy,DisplayBars);  ArrayInitialize(sBuy,0);
  ArrayResize(sSell,DisplayBars); ArrayInitialize(sSell,0);
  ArrayResize(sCloseBuy,DisplayBars);  ArrayInitialize(sCloseBuy,0);
  ArrayResize(sCloseSell,DisplayBars); ArrayInitialize(sCloseSell,0);
  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // find the first point and save its location and price
  for(i1=Bars-1;i1>=0;i1--) { P1=iCustom(NULL,0,"ZigZag",0,i1); if(P1!=0) break; }
  // process the ZigZag points
  for(i2=i1-1;i2>=0;i2--) 
  {
    // find the next point and save its location and price
    for(i2=i2;i2>=0;i2--) { P2=iCustom(NULL,0,"ZigZag",0,i2); if(P2!=0) break; }
    
    if(i2<0) break; // place the last point on the current price 

    // the opening conditions are at the same time the conditions of closing an opposite order
    if(P1>P2) { sSell[i1]=1; sBuy[i2]=1; sCloseSell[i2]=1; }
    if(P1<P2) { sBuy[i1]=1; sSell[i2]=1; sCloseBuy[i2]=1; }

    P1=P2; i1=i2; // save the bar in which the point has been found
  }

/* 
  // MACD
  // fill out the alerts arrays with the values, and count them
  for(i=DisplayBars;i>=0;i--) 
  {
    double MacdCurrent, MacdPrevious, SignalCurrent;
    double SignalPrevious, MaCurrent, MaPrevious;
  
    // to simplify the coding and speed up access
    // data are put into internal variables
    MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i+0);
    MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
    SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i+0);
    SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i+1);
    MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,i+0);
    MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,i+1);
    
    // check for long position (BUY) possibility
    if(MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious &&
       MathAbs(MacdCurrent)>(MACDOpenLevel*Point)) { sBuy[i]=1; }
       
    // check for short position (SELL) possibility
    if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
       MathAbs(MacdCurrent)>(MACDOpenLevel*Point))  { sSell[i]=1;  }
       
    if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious &&
       MathAbs(MacdCurrent)>(MACDCloseLevel*Point)) { sCloseBuy[i]=1; }

    if(MacdCurrent<0 && MacdCurrent>SignalCurrent &&  MacdPrevious<SignalPrevious && 
       MathAbs(MacdCurrent)>(MACDCloseLevel*Point)) { sCloseSell[i]=1;  }
  } 
 */      
/*
  // FANTASIES  
  // fill out the alerts arrays with the values, and count them
  for(i=DisplayBars;i>=0;i--) 
  {
    double m1=iMA(NULL,0,MAPeriod,0,MAMode,MAPrice,i+1);
    double m2=iMA(NULL,0,MAPeriod,0,MAMode,MAPrice,i+2);
    
    // the opening conditions are at the same time the conditions of closing an opposite order
    if(m2<=m1 && MathAbs(m1-m2)>0.2*Point) { sBuy[i]=1; sCloseSell[i]=1; sBuyCnt++; sSellCloseCnt++; }
    if(m2>=m1 && MathAbs(m1-m2)>0.2*Point) { sSell[i]=1; sCloseBuy[i]=1; sSellCnt++; sBuyCloseCnt++; }
  }
*/  
 
	//———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // delete the repeated alerts having saved only the very first ones located to the left on the chart
  for(i=0;i<DisplayBars;i++) 
  {
    if(sBuy[i]==sBuy[i+1]) sBuy[i]=0;
    if(sSell[i]==sSell[i+1]) sSell[i]=0;
    if(sCloseBuy[i]==sCloseBuy[i+1]) sCloseBuy[i]=0;
    if(sCloseSell[i]==sCloseSell[i+1]) sCloseSell[i]=0;
  }
  // delete the alerts outside the specified range of dates
  for(i=0;i<DisplayBars;i++) 
  {
    if(Time[i]<DateStart || DateEnd<Time[i]) { sBuy[i]=0; sSell[i]=0; sCloseBuy[i]=0; sCloseSell[i]=0; }
  }
  // add forcible closing marginal positions
  if(DateEnd<=Time[0]) { i=iBarShift(Symbol(),Period(),DateEnd); sBuy[i]=0; sSell[i]=0; sCloseBuy[i]=1; sCloseSell[i]=1; }
  if(DateEnd >Time[0]) { sCloseBuy[0]=1; sCloseSell[0]=1; }
  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // count the amount of alerts
  for(i=0;i<DisplayBars;i++) 
  {
    if(sBuy [i]!=0) sBuyCnt++;  if(sCloseBuy [i]!=0) sBuyCloseCnt++;
    if(sSell[i]!=0) sSellCnt++; if(sCloseSell[i]!=0) sSellCloseCnt++;
  }
  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // place the marks, draw a ZZ and calculate the profits
  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // process BUY trades
  for(i=DisplayBars-1;i>=0;i--) // go and collect the points
  {
    // find the next OPEN point and save its location and price
    for(i1=i;i1>=0;i1--) if(sBuy[i1]!=0) break; 

    // find the next CLOSE  point of a BUY trade and save its location and price
    for(i2=i1-1;i2>=0;i2--) if(sCloseBuy[i2]!=0) break;
    if(i2<0) i2=0; // for the last unclosed position, calculate the CLOSE on the current price
    i=i2; // new bar to continue searching for OPEN points

    // define the prices for drawing according to the parameter of optimism, Optimizm
    if(Optimizm<0)  { P1=High[i1]; P2=Low[i2];  } 
    if(Optimizm==0) { P1=Open[i1]; P2=Open[i2]; } 
    if(Optimizm>0)  { P1=Low[i1];  P2=High[i2]; } 
    
    P1/=Point; P2/=Point; // express prices in points
    
    // find the profit and fill out the corresponding buffer
    if(i1>=0) 
    { 
      Profit=Profit+P2-P1; // collect the summed profit
      if(P2-P1>=0) CntProfit++; else CntLoose++; // count the number of orders
      DrawLine(i1,i2,OP_BUY,Optimizm); // draw the order line
      PlaceMarker(i1,OP_BUY); 
      PlaceMarker(i2,OP_CLOSE_BUY); 
    }
  }
  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // process the SELL trades
  for(i=DisplayBars-1;i>=0;i--) // go and collect the points
  {
    // find the next OPEN point and save its location and price
    for(i1=i;i1>=0;i1--) if(sSell[i1]!=0) break; 

    // find the next CLOSE  point of a SELL trade and save its location and price
    for(i2=i1-1;i2>=0;i2--) if(sCloseSell[i2]!=0) break;
    if(i2<0) i2=0; // for the last unclosed position, calculate the CLOSE on the current price
    i=i2; // new bar to continue searching for OPEN points

    // define the prices for drawing according to the parameter of optimism, Optimizm
    if(Optimizm<0)  { P1=Low[i1];  P2=High[i2]; } 
    if(Optimizm==0) { P1=Open[i1]; P2=Open[i2]; } 
    if(Optimizm>0)  { P1=High[i1]; P2=Low[i2];  } 
    
    P1/=Point; P2/=Point; // express prices in points
    
    // if there are both points available, find the profit and fill out the corresponding buffer
    if(i1>=0) 
    { 
      Profit=Profit+P1-P2; // collect the summed profit
      if(P1-P2>=0) CntProfit++; else CntLoose++; // count the number of orders
      DrawLine(i1,i2,OP_SELL,Optimizm); // draw the order line
      PlaceMarker(i1,OP_SELL); 
      PlaceMarker(i2,OP_CLOSE_SELL);
    }
  }
  //———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
  // calculating the totals for commenting  
  int Cnt=CntProfit+CntLoose; // total number of operations
  // coefficient to transfer points into the deposit currency
  double ToCurrency = MarketInfo(Symbol(),MODE_TICKVALUE)*LotForCalc;    
  string msg="Period: "+TimeToStr(MathMax(DateStart,Time[Bars-1]))+" - "+TimeToStr(MathMin(DateEnd,Time[0]))+"\n\n";
  
  msg=msg+
  sBuyCnt+" BUY trades and "+sBuyCloseCnt+" their closings\n"+
  sSellCnt+" SELL trades and "+sSellCloseCnt+" their closings\n\n";
  
  // total time in days
  int TotalDays = (MathMin(DateEnd,Time[0])-MathMax(DateStart,Time[Bars-1]))/60/60/24; //translate seconds into days
  if(TotalDays<=0) TotalDays=1; // to avoid zero divide for shorter days
  
  if(Cnt==0) msg=msg+("No operations");
  else msg=msg+
  (
    DoubleToStr(Profit,0)+" point on "+Cnt+" operations for "+TotalDays+" days\n"+
    DoubleToStr(Profit/Cnt,1)+" point for operation ("+
    DoubleToStr(Profit/TotalDays,1)+" within a day)\n\n"+
    "When trading with "+DoubleToStr(LotForCalc,2)+" obtain in "+AccountCurrency()+":\n"+
    DoubleToStr(Profit*ToCurrency,0)+" totally, by "+
    DoubleToStr(Profit/Cnt*ToCurrency,1)+" per trade ("+
    DoubleToStr(Profit/TotalDays*ToCurrency,1)+" within one day)\n\n"+
    CntProfit+" profitable ("+DoubleToStr(((CntProfit)*1.0/Cnt*1.0)*100.0,1)+"%)\n"+
    CntLoose+" losing ("+DoubleToStr(((CntLoose)*1.0/Cnt*1.0)*100.0,1)+"%)"
  );
  Comment(msg);
  
}
//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————



//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// deleting all objects from our chart
void ClearMarkers() 
{ 
  for(int i=0;i<ObjectsTotal();i++) 
  if(StringFind(ObjectName(i),MrakerPrefix)==0) { ObjectDelete(ObjectName(i)); i--; } 
}
//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// placing a vertical line - marks of the operation of the op_type type
void PlaceMarker(int i, int op_type)
{
  if(!ShowMARKERS) return; // displaying markers disabled

  color MarkerColor; string MarkName; 

  // __ for the CLOSE line to be drawn below the OPEN line at sorting 
  if(op_type==OP_CLOSE_SELL) { MarkerColor=ColorClose; MarkName=MrakerPrefix+"__SELL_"+i; }
  if(op_type==OP_CLOSE_BUY)  { MarkerColor=ColorClose; MarkName=MrakerPrefix+"__BUY_"+i;  }  
  if(op_type==OP_SELL)       { MarkerColor=ColorSell;  MarkName=MrakerPrefix+"_SELL_"+i;  }
  if(op_type==OP_BUY)        { MarkerColor=ColorBuy;   MarkName=MrakerPrefix+"_BUY_"+i;   }

  ObjectCreate(MarkName,OBJ_VLINE,0,Time[i],0); 
  ObjectSet(MarkName,OBJPROP_WIDTH,1); 
  if(op_type==OP_CLOSE_BUY || op_type==OP_CLOSE_SELL) ObjectSet(MarkName,OBJPROP_STYLE,STYLE_SOLID); 
  else ObjectSet(MarkName,OBJPROP_STYLE,STYLE_DOT);
  ObjectSet(MarkName,OBJPROP_BACK,True);  

  ObjectSet(MarkName,OBJPROP_COLOR,MarkerColor);
}
//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// placing a line on the chart for the operation of the op_type type at the prices of parameter Optimizm
void DrawLine(int i1,int i2, int op_type, int Optimizm)
{
  if(!ShowZZ) return; // ZZ displaying disabled
  
  color CurColor;
  string MarkName=MrakerPrefix+"_"+i1+"_"+i2;
  double P1,P2;
  
  // define prices for drawing, according to parameter Optimizm
  if(Optimizm<0 && op_type==OP_BUY)  { P1=High[i1]; P2=Low[i2];  } 
  if(Optimizm<0 && op_type==OP_SELL) { P1=Low[i1];  P2=High[i2]; } 
  if(Optimizm==0)                    { P1=Open[i1]; P2=Open[i2]; } 
  if(Optimizm>0 && op_type==OP_BUY)  { P1=Low[i1];  P2=High[i2]; } 
  if(Optimizm>0 && op_type==OP_SELL) { P1=High[i1]; P2=Low[i2];  } 

  ObjectCreate(MarkName,OBJ_TREND,0,Time[i1],P1,Time[i2],P2);
  
  ObjectSet(MarkName,OBJPROP_RAY,False); // draw segments, not lines
  ObjectSet(MarkName,OBJPROP_BACK,False);
  ObjectSet(MarkName,OBJPROP_STYLE,STYLE_SOLID);
  ObjectSet(MarkName,OBJPROP_WIDTH,2);

  // set line color depending on the profitability of the trade
  if(op_type==OP_BUY) 
  { 
    if(P1 <P2) CurColor = ColorProfitBuy;
    if(P1==P2) CurColor = ColorZeroBuy;
    if(P1 >P2) CurColor = ColorLossBuy;
  }
  if(op_type==OP_SELL) 
  { 
    if(P1 >P2) CurColor = ColorProfitSell;
    if(P1==P2) CurColor = ColorZeroSell;
    if(P1 <P2) CurColor = ColorLossSell;
  }
  ObjectSet(MarkName,OBJPROP_COLOR,CurColor);
}
//—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

