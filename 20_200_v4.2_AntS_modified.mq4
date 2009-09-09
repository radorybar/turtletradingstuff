//+--------------------------------------------------------------------+
//|                                            20/200 expert v3.mq4    |
//|                                                    1H   EUR/USD    |
//|                                                    Smirnov Pavel   |
//|                                                 www.autoforex.ru   |
//| The original EA by Pavel Smirnoy, modified, with a quite proper    |
//| optimization and additional function of the automated lot size.    |
//| And lot increasing to cover losses. After modification the EA      |
//| behaviour is not bad. But is still nonproductive. One can earn     |
//| more trading mamnually. tested in reality. Works like in the       |
//| tester. Recommended for a deposit from $10000. With lower          |
//| deposite profit is too small. Only for EUR/USD on 1H chart!!!!     |
//|                                                               AntS |
//+--------------------------------------------------------------------+

#property copyright "Smirnov Pavel"
#property link      "www.autoforex.ru"

 int TakeProfit_L = 39; // Take Profit in points
 int StopLoss_L = 147;  // Stop Loss in points
 int TakeProfit_S = 32; // Take Profit in points
 int StopLoss_S = 267;  // Stop Loss in points
 int TradeTime=18;      // Stop Loss in points
 int t1=6;              
 int t2=2;                
 int delta_L=6;         
 int delta_S=21;         

extern double lot = 0.1;      // Lot size

 int Orders=1;          // maximal number of positions opened at a time
 int MaxOpenTime=504;

extern int _MM = 0;  // Mathemat

int ticket,total,cnt;
bool cantrade=true;
double closeprice;
double tmp;

double LotSize() 
{
   double size;
   switch( _MM )
   {
      case 0:  size = 0.1;  
               break;
      case 1:  size = 0.1 * AccountBalance() / 1000; 
               break;
      case 2:  size = 0.1 * MathSqrt( AccountBalance() / 1000 ); 
               //size = 1. * MathSqrt( AccountBalance() / 10000 ); 
               break;
      default: size = 0.1;  break;
   }  
   if( size < 0.1 )          // is there wnough money to open 0.1 lot?
      if( ( AccountFreeMarginCheck( Symbol(), OP_BUY,  0.1 ) < 10. ) || 
          ( AccountFreeMarginCheck( Symbol(), OP_SELL, 0.1 ) < 10. ) || 
          ( GetLastError() == 134 ) )
                  lot = 0.0; // no, not enough
      else        lot = 0.1; // enough, open 0.1
   else           lot = NormalizeDouble( size, 2 ); 
   
   return( lot ); 
}


int OpenLong(double volume=0.1)
// The function opens a long position with lot size=volume 
{
  int slippage=10;
  string comment="20/200 expert v2 (Long)";
  color arrow_color=Red;
  int magic=0;

  
  ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,slippage,Ask-StopLoss_L*Point,
                      Ask+TakeProfit_L*Point,comment,magic,0,arrow_color);
 

  //LotSize();
//  }
 
  if(ticket>0)
  {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
    {
      return(0);
    }
    else
      {
        Print("OpenLong(),OrderSelect() - returned an error : ",GetLastError()); 
        return(-1);
      }   
  }
  else 
  {
    Print("Error opening Buy order : ",GetLastError()); 
    return(-1);
  }
}
  
int OpenShort(double volume=0.1)
// The function opens a short position with lot size=volume
{
  int slippage=10;
  string comment="20/200 expert v2 (Short)";
  color arrow_color=Red;
  int magic=0;  

  ticket=OrderSend(Symbol(),OP_SELL,volume,Bid,slippage,Bid+StopLoss_S*Point,
                      Bid-TakeProfit_S*Point,comment,magic,0,arrow_color);

  //LotSize(); // Mathemat
//  }

  if(ticket>0)
  {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      {
        return(0);
      }
    else
      {
        Print("OpenShort(),OrderSelect() - returned an error : ",GetLastError()); 
        return(-1);
      }    
  }
  else 
  {
    Print("Error opening Sell order : ",GetLastError()); 
    return(-1);
  }
}

int init()
{
//  LotSize();
  return(0);
}

int deinit()
{   
  return(0);
}

int start()
{
  if((TimeHour(TimeCurrent())>TradeTime)) cantrade=true;  
  // check if there are open positions ...
  total=OrdersTotal();
  lot = LotSize();
  if(total<Orders)
  {
    // ... if no open orders, go further
    // check if it's time for trade
    if((TimeHour(TimeCurrent())==TradeTime)&&(cantrade))
    {
      // ... if it is
      if (((Open[t1]-Open[t2])>delta_S*Point)) //If the price diminished by delta
      {
        //condition is fulfilled, enter a short position:
        // check if there is free money for opening a short position
        if(AccountFreeMarginCheck(Symbol(),OP_SELL,lot)<=0 || GetLastError()==134)
        {
          Print("Not enough money");
          return(0);
        }
        OpenShort(lot); // Mathemat
        
        cantrade=false; //prohibit repeated trade until the next bar
        return(0);
      }
      if (((Open[t2]-Open[t1])>delta_L*Point)) //if the price increased by delta
      {
        // condition is fulfilled, enter a long position
        // ïcheck if there is free money
        if(AccountFreeMarginCheck(Symbol(),OP_BUY,lot)<=0 || GetLastError()==134)
        {
          Print("Not enough money");
          return(0);
        }
        OpenLong(lot);  // Mathemat
        
        cantrade=false;
        return(0);
      }
    }
  }
// block of a trade validity time checking, if MaxOpenTime=0, do not check.
   if(MaxOpenTime>0)
   {
      for(cnt=0;cnt<total;cnt++)
      {
         if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
         {
            tmp = (TimeCurrent()-OrderOpenTime())/3600.0;
               if (((NormalizeDouble(tmp,8)-MaxOpenTime)>=0))
               {     
                  RefreshRates();
                  if (OrderType()==OP_BUY)
                     closeprice=Bid;
                  else  
                     closeprice=Ask;          
                  if (OrderClose(OrderTicket(),OrderLots(),closeprice,10,Green))
                  {
                  Print("Forced closing of the trade - ¹",OrderTicket());
                     OrderPrint();
                  }
                  else 
                     Print("OrderClose() in block of a trade validity time checking returned error - ",GetLastError());        
                  } 
               }
               else 
                  Print("OrderSelect() in block of a trade validity time checking returned error - ",GetLastError());
         } 
      }     
      return(0);
   }

