//+------------------------------------------------------------------+
//|                                     DumpOrderHistoryIntoFile.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include <DumpOrderHistoryIntoFile.mqh>

extern int period = PERIOD_M5;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   DumpAllOrders(period);
//----
   return(0);
  }
//+------------------------------------------------------------------+