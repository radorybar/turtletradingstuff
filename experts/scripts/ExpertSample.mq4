//+------------------------------------------------------------------+
//|                                                 ExpertSample.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#import "ExpertSample.dll"
   string ExecuteScalar(string strSQL);
#import

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   Print(ExecuteScalar("select count(*) from OrdersHistory"));
//----
   return(0);
  }
//+------------------------------------------------------------------+