//+------------------------------------------------------------------+
//|                                              SuperWoodiesCCI.mq4 |
//|                                                           duckfu |
//|                                          http://www.dopeness.org |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      ""

//#include <ATC2008_2xMA_EURUSD15.mq4>

#define  MAGICMA           0

string   SYMBOL            = "EURUSD";
int      TIMEFRAME         = PERIOD_M15;
int      MAXORDERS         = 3;

//Expert Settings
double   LOTS              = 0.1;
double   MAXIMUMRISK       = 0.5;
int      SLIPPAGE          = 3;

//Slow
double   MA1MOVINGPERIOD   = 300;
double   MA1MOVINGSHIFT    = 0;
int      MA1MODE           = MODE_SMA;
int      MA1PRICE          = PRICE_CLOSE;

//Fast
double   MA2MOVINGPERIOD   = 6;
double   MA2MOVINGSHIFT    = 0;
int      MA2MODE           = MODE_SMA;
int      MA2PRICE          = PRICE_CLOSE;
extern int      MA2DIFF2ORDER     = 4;

double   STOPLOSS          = 60;
double   TRAILINGSTOP      = 60;
double   TAKEPROFIT        = 250;

//Globals
datetime LastBarTraded     = 0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
   
//----
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
   
//----
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void start()
{
   if(!TradeAllowed())
      return;
   OpenPosition(CheckForOpenPosition(), GetLots());
   CheckForClosePositions();   
   CheckForModifyPositions();
}
//+------------------------------------------------------------------+
//| TradeAllowed function return true if trading is possible         |
//+------------------------------------------------------------------+
bool TradeAllowed()
{
//Trade only once on each bar
   if(LastBarTraded == Time[0])
      return(false);
//Trade only for open price
//   if(Volume[0]>1)
//      return(false);
   if(!IsTradeAllowed()) 
      return(false);
   if(OrdersTotal() >= MAXORDERS)
      return(false);
   return(true);
}
//+------------------------------------------------------------------+
//| Get amount of lots to trade                                      |
//+------------------------------------------------------------------+
double GetLots()
{
   double lot;
   lot = NormalizeDouble(AccountFreeMargin() * MAXIMUMRISK / 1000.0, 1);
   if(lot < 0.1)
      lot = 0.1;
   else if(lot > 5)
      lot = 5;
   return(lot);
}
//+------------------------------------------------------------------+
//| Checks of open short, long or nothing (-1, 1, 0)                 |
//+------------------------------------------------------------------+
int CheckForOpenPosition()
{
   double         ma1,
                  ma2,
                  ma1Prev,
                  ma2Prev;
   int            result = 0;

//---- get Moving Averages 
   ma1=iMA(SYMBOL, TIMEFRAME, MA1MOVINGPERIOD, MA1MOVINGSHIFT, MA1MODE, MA1PRICE, 0);
   ma2=iMA(SYMBOL, TIMEFRAME, MA2MOVINGPERIOD, MA2MOVINGSHIFT, MA2MODE, MA2PRICE, 0);
   ma1Prev=iMA(SYMBOL, TIMEFRAME, MA1MOVINGPERIOD, MA1MOVINGSHIFT, PRICE_OPEN, MA1PRICE, 1);
   ma2Prev=iMA(SYMBOL, TIMEFRAME, MA2MOVINGPERIOD, MA2MOVINGSHIFT, PRICE_OPEN, MA2PRICE, 1);
//   ma1 = iCustom(SYMBOL, TIMEFRAME, "ATC2008_2xMA_EURUSD15_SLOW", 0, 0);
//   ma2 = iCustom(SYMBOL, TIMEFRAME, "ATC2008_2xMA_EURUSD15_FAST", 1, 0);

//---- sell conditions
   if(ma1Prev < ma2Prev && ma1 >= ma2 && MathAbs(ma2Prev - ma2) >= MA2DIFF2ORDER * Point)  
      result = -1;

//---- buy conditions
   else if(ma1Prev > ma2Prev && ma1 <= ma2 && MathAbs(ma2 - ma2Prev) >= MA2DIFF2ORDER * Point)
      result = 1;

//----
   return(result);
}
//+------------------------------------------------------------------------------------+
//| Opens position according to arguments (-1 short || 1 long, amount of Lots to trade |
//+------------------------------------------------------------------------------------+
void OpenPosition(int ShortLong, double Lots)
{
   if(ShortLong == -1)
      OrderSend(SYMBOL, OP_SELL, Lots, Bid, SLIPPAGE, Bid + STOPLOSS * Point, Bid - TAKEPROFIT * Point, "Short position", MAGICMA, 0, Red);
   else if(ShortLong == 1)
      OrderSend(SYMBOL, OP_BUY, Lots, Ask, SLIPPAGE, Ask - STOPLOSS * Point, Ask + TAKEPROFIT * Point, "Long position", MAGICMA, 0, Blue);
   if(ShortLong != 0)
      LastBarTraded = Time[0];
   return;
}
//+------------------------------------------------------------------------------------+
//| Closes position based on indicator state                                           |
//+------------------------------------------------------------------------------------+
void CheckForClosePositions()
{
   double         ma1,
                  ma2,
                  ma1Prev,
                  ma2Prev;
   int            i, j;

   int OrderTickets2Close[];
   ArrayResize(OrderTickets2Close, 0);

//---- get Moving Averages 
   ma1=iMA(SYMBOL, TIMEFRAME, MA1MOVINGPERIOD, MA1MOVINGSHIFT, MA1MODE, MA1PRICE, 0);
   ma2=iMA(SYMBOL, TIMEFRAME, MA2MOVINGPERIOD, MA2MOVINGSHIFT, MA2MODE, MA2PRICE, 0);
   ma1Prev=iMA(SYMBOL, TIMEFRAME, MA1MOVINGPERIOD, MA1MOVINGSHIFT, PRICE_OPEN, MA1PRICE, 1);
   ma2Prev=iMA(SYMBOL, TIMEFRAME, MA2MOVINGPERIOD, MA2MOVINGSHIFT, PRICE_OPEN, MA2PRICE, 1);

//Close all Long position   
   j = 0;
   if(ma1Prev < ma2Prev && ma1 >= ma2)
      for(i = 0; i < OrdersTotal(); i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderType() == OP_BUY)
         {
            ArrayResize(OrderTickets2Close, j + 1);
            OrderTickets2Close[i] = OrderTicket();
            j++;
         }
      }
   else if(ma1Prev > ma2Prev && ma1 <= ma2)
      for(i = 0; i < OrdersTotal(); i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderType() == OP_SELL)
         {
            ArrayResize(OrderTickets2Close, j + 1);
            OrderTickets2Close[i] = OrderTicket();
            j++;
         }
      }
   for(i = 0; i < ArraySize(OrderTickets2Close); i++)
   {
      OrderSelect(OrderTickets2Close[i], SELECT_BY_TICKET);
      if(OrderType() == OP_SELL)
         OrderClose(OrderTicket(), OrderLots(), Ask, 3, Orange);
      else if(OrderType() == OP_BUY)
         OrderClose(OrderTicket(), OrderLots(), Bid, 3, Orange);
   }

//----
   return;
}
//+------------------------------------------------------------------------------------+
//| Modify positions - Stoploss based on Trailing stop                                            |
//+------------------------------------------------------------------------------------+
void CheckForModifyPositions()
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         break;
      if(OrderMagicNumber() != MAGICMA || OrderSymbol() != SYMBOL)
         continue;

      if(OrderType() == OP_BUY)
      {
         if(TRAILINGSTOP > 0)
            if(Bid - OrderOpenPrice() > Point * TRAILINGSTOP)
              if(OrderStopLoss() < Bid-Point * TRAILINGSTOP)
                 OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point*TRAILINGSTOP, OrderTakeProfit(), 0, Blue);
      }
      else if(OrderType() == OP_SELL)
      {
         if(TRAILINGSTOP > 0)
            if(Ask + OrderOpenPrice() < Point * TRAILINGSTOP)
              if(OrderStopLoss()>Ask + Point * TRAILINGSTOP)
                 OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TRAILINGSTOP, OrderTakeProfit(), 0, Red);
      }
   }
}