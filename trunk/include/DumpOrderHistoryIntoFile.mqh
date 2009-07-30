//+------------------------------------------------------------------+
//|                                     DumpOrderHistoryIntoFile.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2005

//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);

// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import

//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex4"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
int DumpAllOrders(int period)
{
   DumpOpenOrders(period);
   DumpHistoryOrders(period);
   return(0);
}

int DumpOpenOrders(int period)
{
   for(int i = OrdersTotal(); i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS))
         DumpOrderHistoryIntoFile(OrderTicket(), period);
   }
   return(0);
}

int DumpHistoryOrders(int period)
{
   for(int i = OrdersHistoryTotal(); i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         DumpOrderHistoryIntoFile(OrderTicket(), period);
   }
   return(0);
}

int DumpOrderHistoryIntoFile(int ticket, int period)
{
   bool buysell;
   string FileName;
   
   OrderSelect(ticket, SELECT_BY_TICKET);
   if(OrderType() != OP_SELL && OrderType() != OP_BUY)
      return(1);
   
   if(OrderType() == OP_BUY)
      buysell = true;
   else
      buysell = false;
   
   if(OrderCloseTime() != 0)
      FileName = StringConcatenate(ticket, "_", OrderSymbol(), "_History.txt");
   else
      FileName = StringConcatenate(ticket, "_", OrderSymbol(), "_Open.txt");
   
   int handle=FileOpen(FileName,FILE_WRITE|FILE_CSV,"\t");
   if(handle<0) return(0);

//   FileWrite(handle,"#","Open Time","Type","Lots","Symbol","Price","Stop/Loss","Take Profit","Close Time","Close Price","Profit","Comment");
//   FileWrite(handle,OrderTicket(),TimeToStr(OrderOpenTime(),TIME_DATE|TIME_MINUTES),OrderType(),OrderLots(),OrderSymbol(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),TimeToStr(OrderCloseTime(),TIME_DATE|TIME_MINUTES),OrderClosePrice(),OrderProfit(),OrderComment());
   
   int shift = iBarShift(OrderSymbol(), period, OrderOpenTime());
   
//   FileWrite(handle,"");
   FileWrite(handle,"TIME", "Order profit OPEN","Order profit HIGH","Order profit LOW","Order profit CLOSE","OPEN","HIGH","LOW","CLOSE");

   for(int i=shift;i>=0;i--)
   {
      int sellcorrection = 1;
      if(!buysell)
         sellcorrection = -1;
         
      double open = iOpen(OrderSymbol(), period, i);
      double high = iHigh(OrderSymbol(), period, i);
      double low = iLow(OrderSymbol(), period, i);
      double close = iClose(OrderSymbol(), period, i);
      double profit_open = sellcorrection*(open - OrderOpenPrice());
      double profit_high = sellcorrection*(high - OrderOpenPrice());
      double profit_low = sellcorrection*(low - OrderOpenPrice());
      double profit_close = sellcorrection*(close - OrderOpenPrice());

      FileWrite(handle, TimeToStr(iTime(OrderSymbol(), period, i), TIME_DATE|TIME_MINUTES),profit_open,profit_high,profit_low,profit_close,open,high,low,close);
   }
   
   FileClose(handle);
   
   return(0);
}