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
         FileWrite(handle, iCustom(Symbol(), NULL, "051.005_ZIGZAG_Channel_Breakout", 0, i), iCustom(Symbol(), NULL, "051.005_ZIGZAG_Channel_Breakout", 1, i), iCustom(Symbol(), NULL, "051.005_ZIGZAG_Channel_Breakout", 2, i), iCustom(Symbol(), NULL, "051.005_ZIGZAG_Channel_Breakout", 3, i), iCustom(Symbol(), NULL, "051.005_ZIGZAG_Channel_Breakout", 4, i));
      }
      
      FileClose(handle);

   
//----
   return(0);
  }
//+------------------------------------------------------------------+