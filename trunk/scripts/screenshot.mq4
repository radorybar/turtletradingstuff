//+------------------------------------------------------------------+
//|                                                   screenshot.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   string FileName;
   int error = GetLastError();
   
   FileName = StringConcatenate(TimeToStr(TimeCurrent(), TIME_DATE), "_", TimeToStr(TimeCurrent(), TIME_SECONDS), ".gif");
   
   WindowScreenShot("subor.gif", 320, 240);
   
   Print(FileName);
   Print(StringConcatenate("Error number ", error, " occured!"), StringConcatenate(" Error number ", error, " occured! \nError description: ", error));
//----
   return(0);
  }
//+------------------------------------------------------------------+