//+------------------------------------------------------------------+
//|                                                          ZCB.mq4 |
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
      int handle = FileOpen("ZCB.csv", FILE_CSV|FILE_READ|FILE_WRITE);

      for(int i = 0; i < Bars; i++)
      {
         double ZCBUpper = iCustom(Symbol(), NULL, "ZIGZAG_Channel_Breakout", 0, i);
         double ZCBLower = iCustom(Symbol(), NULL, "ZIGZAG_Channel_Breakout", 1, i);
         FileWrite(handle, ZCBLower, ZCBUpper);
      }
      
      FileClose(handle);

   
//----
   return(0);
  }
//+------------------------------------------------------------------+