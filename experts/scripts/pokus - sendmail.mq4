//+------------------------------------------------------------------+
//|                                             pokus - sendmail.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include <gMail.mqh>

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   gSendMail ("", "radorybar@gmail.com" , "pokus send mail" , "" , "" , "");
   //SendMail("BUY LIMIT - Support reversal", "BUY LIMIT - Support reversal");
//----
   return(0);
  }
//+------------------------------------------------------------------+