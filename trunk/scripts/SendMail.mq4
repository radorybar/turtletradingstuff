
//+------------------------------------------------------------------+
//|                                                     SendMail.mq4 |
//|                                                       Codersguru |
//|                                         http://www.forex-tsd.com |
//+------------------------------------------------------------------+
#property copyright "Codersguru"
#property link      "http://www.forex-tsd.com"

#include <gMail.mqh>

int start()
  {
  
   string Profile = "default";
   string To = "radorybar@gmail.com";
   string Subject = "This is a demo email has been sent from MetaTrader, Please ignore it!";
   string Body = "This is the body of the message!\r\nPlease check the attachment\r\nRegards,\r\nForex-tsd";
   string Attachmet = "";
   string Attachmet_Title = "";
   
//   if(ScreenShot("ss.gif",640,480))
   bool reuslt = gSendMail(Profile,To,Subject,Body,Attachmet,Attachmet_Title);
   return(0);
  }

