//+------------------------------------------------------------------+
//|                                                MACD Sample_1.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

extern double TakeProfit = 50;
extern double Lots = 0.1;

extern double MACDOpenLevel=3;
extern double MACDCloseLevel=2;
extern double MATrendPeriod=26;
//-------���������� ��� �����������-------
extern int FastEMA = 12;
extern int SlowEMA = 26;
extern int SignalSMA = 9;
extern int TrailingStop = 30;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern int SetHour   = 0;             //��� ������ ����������� 
extern int SetMinute = 1;             //������ ������ ����������� 
int    TestDay     = 3;                      //���������� ���� ��� ����������� 
int    TimeOut     = 4;                     //����� �������� ��������� ����������� � �������
string NameMTS     = "MACD Sample_1";        //��� ���������
string NameFileSet = "MACD Sample_1.set";             //��� Set ����� � �����������
string PuthTester  = "D:\Program Files\Forex Best Trade Station";//���� � �������
//--- ������������������ ����������
int    Gross_Profit   = 1;                   //���������� �� ������������ �������
int    Profit_Factor  = 2;                   //���������� �� ������������ ������������
int    Expected_Payoff= 3;                   //���������� �� ������������� �����������
//--����� ���������� ��� �����������
string Per1 = "FastEMA";
string Per2 = "SlowEMA";
string Per3 = "SignalSMA";
string Per4 = "";
bool StartTest=false;
datetime TimeStart;
//--- ����������� ���������� ����������������
#include <auto_optimization.mqh>

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int init(){
Comment(" ");
   //  Tester(TestDay,NameMTS,NameFileSet,PuthTester,TimeOut,Gross_Profit,Profit_Factor,Expected_Payoff,Per1,Per2,Per3,Per4);
return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double MacdCurrent, MacdPrevious, SignalCurrent;
   double SignalPrevious, MaCurrent, MaPrevious;
   int cnt, ticket, total;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   if(!IsTesting() && !IsOptimization()){                //��� ������������ � ����������� �� ���������
      if(TimeHour(TimeLocal())==SetHour){                //��������� �������� ���� � ������������� ��� �������
         if(!StartTest){                                 //������ �� ���������� �������
            if(TimeMinute(TimeLocal())>SetMinute-1){     //��������� ��������� ����� � ������������� ��� ������� �������
               if(TimeMinute(TimeLocal())<SetMinute+1){  //�������� ����� � ������ ���� �� �����-�� �������� ����� ��� ������ ����
                  TimeStart   =TimeLocal();
                  StartTest   =true;                     //���� ������� �������
                  Tester(TestDay,NameMTS,NameFileSet,PuthTester,TimeOut,Gross_Profit,Profit_Factor,Expected_Payoff,Per1,Per2,Per3,Per4);
   }}}}
   FastEMA     =GlobalVariableGet(Per1);
   SlowEMA     =GlobalVariableGet(Per2);
   SignalSMA   =GlobalVariableGet(Per3);
   TrailingStop=GlobalVariableGet(Per4);
   }
   if(StartTest){                                        //���� ���� ������� ������� ����������
       if(TimeLocal()-TimeStart > TimeOut*60){            //���� � ������� ������� ������ ������ �������������� ������� �������� ������������
       StartTest = false;                                //������� ����
   }}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    
    if(Bars<100)
     {
      Print("bars less than 100");
      return(0);  
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return(0);  // check TakeProfit
     }
   MacdCurrent=iMACD(NULL,0,FastEMA,SlowEMA,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,FastEMA,SlowEMA,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,1);
   MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);

   total=OrdersTotal();
   if(total<1) 
     {
      // no opened orders identified
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
        }
      // check for long position (BUY) possibility
      if(MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious &&
         MathAbs(MacdCurrent)>(MACDOpenLevel*Point) && MaCurrent>MaPrevious)
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError()); 
         return(0); 
        }
      // check for short position (SELL) possibility
      if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
         MacdCurrent>(MACDOpenLevel*Point) && MaCurrent<MaPrevious)
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELL order : ",GetLastError()); 
         return(0); 
        }
      return(0);
     }
   // it is important to enter the market correctly, 
   // but it is more important to exit it correctly...   
   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
            if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious &&
               MacdCurrent>(MACDCloseLevel*Point))
                {
                 OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
                 return(0); // exit
                }
            // check for trailing stop
            if(TrailingStop>0)  
              {                 
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                     return(0);
                    }
                 }
              }
           }
         else // go to short position
           {
            // should it be closed?
            if(MacdCurrent<0 && MacdCurrent>SignalCurrent &&
               MacdPrevious<SignalPrevious && MathAbs(MacdCurrent)>(MACDCloseLevel*Point))
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
               return(0); // exit
              }
            // check for trailing stop
            if(TrailingStop>0)  
              {                 
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                     return(0);
                    }
                 }
              }
           }
        }
     }
   return(0);
  }
// the end.