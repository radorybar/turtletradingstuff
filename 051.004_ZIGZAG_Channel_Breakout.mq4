#include <001_CommonFunctions.mqh>
#include <002_OrderHandlingFunctions.mqh>
#include <003_MoneyManagementFunctions.mqh>

#property copyright "slacktrader"
#property link      "slacktrader"
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// main variables                                                         
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
int   _ALL_STRATEGIES                  = 1;
int   _ACTIVE_STRATEGIES[]             = {1};

// 1 - PERIOD_M1
// 2 - PERIOD_M5
// 3 - PERIOD_M15
// 4 - PERIOD_M30
// 5 - PERIOD_H1
// 6 - PERIOD_H4
// 7 - PERIOD_D1
// 8 - PERIOD_W1
// 9 - PERIOD_MN1

// _STRATEGY_TIMEFRAME_CHOICE
extern string  poznamka1 = "0 - vyber timeframe podla dropdown menu - premenna _STRATEGY_TIMEFRAME sa ignoruje";
extern string  poznamka2 = "1 - vyber timeframe podla kodu timeframe 1 - 9";
extern int     _STRATEGY_TIMEFRAME_CHOICE    = 0;
extern int     _STRATEGY_TIMEFRAME           = 0;

extern int     _OPEN_SIGNAL_COMBINATION      = 1;
extern int     _CLOSE_SIGNAL_COMBINATION     = 1;
extern int     _STOPLOSS_COMBINATION         = 1;  //3
extern int     _TRAILING_STOPLOSS_COMBINATION= 1;  //3

extern int     _TRADING_HOURS                = 12;
/*
string poznamka1 = "0 - vyber timeframe podla dropdown menu - premenna _STRATEGY_TIMEFRAME sa ignoruje";
string poznamka2 = "1 - vyber timeframe podla kodu timeframe 1 - 9";
int   _STRATEGY_TIMEFRAME_CHOICE    = 0;
int   _STRATEGY_TIMEFRAME           = 1;
*/

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// MM Modul                                                         
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// Signal Modul                                                     
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
#define     _OPEN_LONG                    1
#define     _OPEN_SHORT                   2
#define     _CLOSE_LONG                   3
#define     _CLOSE_SHORT                  4
#define     _GET_LONG_STOPLOSS_PRICE      5
#define     _GET_SHORT_STOPLOSS_PRICE     6
#define     _GET_LONG_TAKEPROFIT_PRICE    7
#define     _GET_SHORT_TAKEPROFIT_PRICE   8
#define     _GET_LOTS                     9
#define     _GET_TRAILED_STOPLOSS_PRICE   10
#define     _GET_TRAILED_TAKEPROFIT_PRICE 11
#define     _GET_TRADED_TIMEFRAME         12
#define     _OPEN_PENDING_BUY_STOP        13
#define     _OPEN_PENDING_SELL_STOP       14
#define     _OPEN_PENDING_BUY_LIMIT       15
#define     _OPEN_PENDING_SELL_LIMIT      16
#define     _GET_PENDING_BUY_STOP_PRICE   17
#define     _GET_PENDING_SELL_STOP_PRICE  18
#define     _GET_PENDING_ORDER_EXPIRATION 19
#define     _GET_STRATEGY_NUMBER          20
#define     _GET_STRATEGY_MAGICNUMBER     21
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
static datetime LastBarTraded = 0;
static int Tick = 0;
double LastAsk = 0;
double LastBid = 0;
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
int init()
{
   return(0);
}
int deinit()
{
/*
      int handle = FileOpen("ticks.csv", FILE_CSV|FILE_READ|FILE_WRITE);

      for(int i = 0; i < ArraySize(TickAsk); i++)
      {
         FileWrite(handle, TickAsk[i], TickBid[i]);
      }
      
      FileClose(handle);
*/
   return(0);
}

int start()
{
   double            Stoploss          = 0;
   double            TakeProfit        = 0;
   int               OrderTickets[];
   int               i, j, k;

   Tick++;
   
   ArrayResize(OrderTickets, 0);
   
   if(LastBarTraded())
      return(0);
   
//Get all openned orders and their magicnumber   
   for(i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS);
      ArrayResize(OrderTickets, ArraySize(OrderTickets) + 1);
      OrderTickets[ArraySize(OrderTickets) - 1] = OrderTicket();
   }

//iterate all strategies and choose only active ones
   for(i = 1; i <= _ALL_STRATEGIES; i++)
   {
//iterate all active strategies and aply strategy on order if magicnumbers are equal
      for(j = 0; j < ArraySize(_ACTIVE_STRATEGIES); j++)
      {
         if(Strategy(i, _GET_STRATEGY_NUMBER) != _ACTIVE_STRATEGIES[j])
            continue;

         for(k = 0; k < ArraySize(OrderTickets); k++)
         {
            OrderSelect(OrderTickets[k], SELECT_BY_TICKET);
         
            if(OrderMagicNumber() != Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER))
               continue;
         
            Stoploss = Strategy(_ACTIVE_STRATEGIES[j], _GET_TRAILED_STOPLOSS_PRICE);
            TakeProfit = Strategy(_ACTIVE_STRATEGIES[j], _GET_TRAILED_TAKEPROFIT_PRICE);

            if(Stoploss != 0 || TakeProfit != 0)
               ModifyAllPositions(OrderMagicNumber(), Stoploss, TakeProfit);

            if(OrderType() == OP_BUY)
               if(Strategy(_ACTIVE_STRATEGIES[j], _CLOSE_LONG) == 1)
                  CloseAllLongPositions(OrderMagicNumber());
            if(OrderType() == OP_SELL)
               if(Strategy(_ACTIVE_STRATEGIES[j], _CLOSE_SHORT) == 1)
                  CloseAllShortPositions(OrderMagicNumber());
         }
      }
   }
      
   if(!TradeAllowed(2))
      return(0);

//iterate all strategies and choose only active ones
   for(i = 1; i <= _ALL_STRATEGIES; i++)
   {
      bool OrderExists = false;
//iterate all active strategies and aply strategy on order if magicnumbers are equal

      for(j = 0; j < ArraySize(_ACTIVE_STRATEGIES); j++)
      {
         if(Strategy(i, _GET_STRATEGY_NUMBER) != _ACTIVE_STRATEGIES[j])
            continue;

//if order for this strategy already exists - do not chech this strategy for open         
         for(k = 0; k < OrdersTotal(); k++)
         {
            OrderSelect(k, SELECT_BY_POS);
            if(OrderMagicNumber() == Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER))
            {
               OrderExists = true;
               break;
            }
         }
         
         if(!OrderExists)
         {
            if(Strategy(_ACTIVE_STRATEGIES[j], _OPEN_LONG) == 1)
               OpenPosition(false, Strategy(_ACTIVE_STRATEGIES[j], _GET_LOTS), Strategy(_ACTIVE_STRATEGIES[j], _GET_LONG_STOPLOSS_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_LONG_TAKEPROFIT_PRICE), 3, Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER));
            if(Strategy(_ACTIVE_STRATEGIES[j], _OPEN_SHORT) == 1)
               OpenPosition(true, Strategy(_ACTIVE_STRATEGIES[j], _GET_LOTS), Strategy(_ACTIVE_STRATEGIES[j], _GET_SHORT_STOPLOSS_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_SHORT_TAKEPROFIT_PRICE), 3, Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER));

            if(Strategy(_ACTIVE_STRATEGIES[j], _OPEN_PENDING_BUY_STOP) == 1)
               OpenPendingPosition(false, Strategy(_ACTIVE_STRATEGIES[j], _GET_LOTS), Strategy(_ACTIVE_STRATEGIES[j], _GET_PENDING_BUY_STOP_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_LONG_STOPLOSS_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_LONG_TAKEPROFIT_PRICE), 3, Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER), Strategy(_ACTIVE_STRATEGIES[j], _GET_PENDING_ORDER_EXPIRATION));
            if(Strategy(_ACTIVE_STRATEGIES[j], _OPEN_PENDING_SELL_STOP) == 1)
               OpenPendingPosition(true, Strategy(_ACTIVE_STRATEGIES[j], _GET_LOTS), Strategy(_ACTIVE_STRATEGIES[j], _GET_PENDING_SELL_STOP_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_SHORT_STOPLOSS_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_SHORT_TAKEPROFIT_PRICE), 3, Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER), Strategy(_ACTIVE_STRATEGIES[j], _GET_PENDING_ORDER_EXPIRATION));
         }

      }
   }

   LastAsk = Ask;
   LastBid = Bid;

   return(0);
}
//------------------------------------------------------------------
// Last bar already traded
//------------------------------------------------------------------
bool LastBarTraded()
{
//Trade only once on each bar
   if(LastBarTraded == Time[0])
      return(true);
   else
      return(false);
}
//------------------------------------------------------------------
// First tick of a traded timeframe bar
//------------------------------------------------------------------
bool OpenNewBar(int _TIMEFRAME)
{
   if(iVolume(Symbol(), _TIMEFRAME, 0) > 1)
      return(false);
   else
      return(true);
}
//------------------------------------------------------------------
// TradeAllowed function return true if trading is possible         
//------------------------------------------------------------------
bool TradeAllowed(int MAXORDERS)
{
//Trade only once on each bar
   if(!IsTradeAllowed()) 
      return(false);
   if(OrdersTotal() >= MAXORDERS)
      return(false);
   return(true);
}
//------------------------------------------------------------------
int getStrategyTimeframeByNumber(int _PERIOD)
{
// 1 - PERIOD_M1
// 2 - PERIOD_M5
// 3 - PERIOD_M15
// 4 - PERIOD_M30
// 5 - PERIOD_H1
// 6 - PERIOD_H4
// 7 - PERIOD_D1
// 8 - PERIOD_W1
// 9 - PERIOD_MN1
   if(_STRATEGY_TIMEFRAME_CHOICE == 0)
      return(Period());
   else
      switch(_PERIOD)
      {
         case 1:
            return (PERIOD_M1);
         case 2:
            return (PERIOD_M5);
         case 3:
            return (PERIOD_M15);
         case 4:
            return (PERIOD_M30);
         case 5:
            return (PERIOD_H1);
         case 6:
            return (PERIOD_H4);
         case 7:
            return (PERIOD_D1);
         case 8:
            return (PERIOD_W1);
         case 9:
            return (PERIOD_MN1);
      }
}
/*
bool isTradingHour(int _TRADING_HOURS[])
{
   for(int x = 0; x < ArraySize(_TRADING_HOURS); x++)
      if(_TRADING_HOURS[x] == Hour())
         return(true);
   
   return(false);
}
*/
//------------------------------------------------------------------
bool isTradingHour(int _TRADING_HOURS)
{
   if(_TRADING_HOURS == Hour())
      return(true);
   
   return(false);
}
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//Signal modul
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//
double Strategy(int _STRATEGY, int _COMMAND)
{
   if(_STRATEGY == Strategy_001(_GET_STRATEGY_NUMBER))
      return(Strategy_001(_COMMAND));

   return(0);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_001(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 1;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;
//   int      _TRADING_HOURS[]  = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};
//   int      _TRADING_HOURS[]  = {3,7,};

   string   _SYMBOL              = Symbol();
   int      _TIMEFRAME           = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);

   int      _BREAKOUTTHRESSHOLD  = 0;
   int      _MAXRISK             = 20;   
   
   static int TickCounted = 0;
   static datetime TodayStart;
   static datetime LastZIGZAGTradedTime = D'1970.01.01 00:00';
      
   static double  ZCBLower;
   static double  ZCBUpper;
   static double  ZIGZAGChannelUp;
   static double  ZIGZAGChannelLow;
   static double  ZIGZAG;
   static double UpperFractal1;
   static double LowerFractal1;
   static int UpperFractalTime1;
   static int LowerFractalTime1;
   static double UpperZIGZAG1;
   static double LowerZIGZAG1;
   static datetime UpperZIGZAG1Time;
   static datetime LowerZIGZAG1Time;
   static double UpperFractal2;
   static double LowerFractal2;
   static int UpperFractalTime2;
   static int LowerFractalTime2;
   static double UpperZIGZAG2;
   static double LowerZIGZAG2;
   static double LongStop;
   static double ShortStop;
   
   double   result         = 0;
   
   int      i;

   _TRADING_HOURS  = Hour();

//Put here all time consuming expressions, which can be shared inside a tick between different commands
//This will be counted once for each tick
//Do not forget to setup variables evaluated here as a static, to remember last state, if not counted twice for a tick
   if(TickCounted != Tick)
   {
      
      ZCBUpper = iCustom(_SYMBOL, _TIMEFRAME, "051.002_ZIGZAG_Channel_Breakout", 0, 0);
      ZCBLower = iCustom(_SYMBOL, _TIMEFRAME, "051.002_ZIGZAG_Channel_Breakout", 1, 0);
      ZIGZAGChannelUp = iCustom(_SYMBOL, _TIMEFRAME, "051.006_ZIGZAG_Channel_Breakout", 3, 1);
      ZIGZAGChannelLow = iCustom(_SYMBOL, _TIMEFRAME, "051.006_ZIGZAG_Channel_Breakout", 4, 1);
      ZIGZAG = iCustom(_SYMBOL, _TIMEFRAME, "051.001_ZIGZAG_Channel_Breakout", 2, 0);
      UpperFractal1 = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
      LowerFractal1 = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
      UpperFractalTime1 = iBarShift(_SYMBOL, _TIMEFRAME, getLastFractalTime(_SYMBOL, _TIMEFRAME, true));
      LowerFractalTime1 = iBarShift(_SYMBOL, _TIMEFRAME, getLastFractalTime(_SYMBOL, _TIMEFRAME, false));
//      UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
//      LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
      UpperZIGZAG1Time = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, true);
      LowerZIGZAG1Time = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, false);
      UpperFractal2 = getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true);
      LowerFractal2 = getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false);
      UpperFractalTime2 = iBarShift(_SYMBOL, _TIMEFRAME, getPreviousFractalTime(_SYMBOL, _TIMEFRAME, true));
      LowerFractalTime2 = iBarShift(_SYMBOL, _TIMEFRAME, getPreviousFractalTime(_SYMBOL, _TIMEFRAME, false));
//      UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
//      LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);

      LongStop = LowerFractal2 + LowerFractalTime1*(LowerFractal1 - LowerFractal2)/(LowerFractalTime2 - LowerFractalTime1);
      ShortStop = UpperFractal2 - UpperFractalTime1*(UpperFractal2 - UpperFractal1)/(UpperFractalTime2 - UpperFractalTime1);
            
      TickCounted = Tick;
   }
   
   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;
         
         if(!isTradingHour(_TRADING_HOURS))
            break;

//         if(LastZIGZAGTradedTime <  LowerZIGZAG1Time)
//         if(Bid < ZIGZAGChannelUp)
         if(Ask > ZCBUpper)
         if(LastAsk < ZCBUpper)
         if(ZCBUpper > 0.0)
            result = 1;
         
         if(result == 1)
            LastZIGZAGTradedTime =  LowerZIGZAG1Time;
                         
         break;
      }
      case _OPEN_SHORT:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         if(!isTradingHour(_TRADING_HOURS))
            break;
            
//         if(LastZIGZAGTradedTime <  UpperZIGZAG1Time)
//         if(Ask > ZIGZAGChannelLow)
         if(Bid < ZCBLower)
         if(LastBid > ZCBLower)
         if(ZCBLower > 0.0)
            result = 1;

         if(result == 1)
            LastZIGZAGTradedTime =  UpperZIGZAG1Time;

         break;
      }
      case _CLOSE_LONG:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;
         
//         if(Bid > ZIGZAGChannelUp)
//         if(ZIGZAGChannelUp > 0.0)
//           result = 1;
                        
//         if(Bid < ZIGZAGChannelLow)
//         if(ZIGZAGChannelLow > 0.0)
//           result = 1;

         if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
            result = 1;

         break;
      }
      case _CLOSE_SHORT:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;
            
//         if(Ask < ZIGZAGChannelLow)
//         if(ZIGZAGChannelLow > 0.0)
//           result = 1;
                        
//         if(Ask > ZIGZAGChannelUp)
//         if(ZIGZAGChannelUp > 0.0)
//           result = 1;

         if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
            result = 1;

         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

//         result = Low[1];
         result = LowerFractal1;
//         result = LowerZIGZAG1;
         
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

//         result = High[1];
         result = UpperFractal1;
//         result = UpperZIGZAG1;

         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;
         
         double breakeven = 0;
               
         OrderSelect(0, SELECT_BY_POS);
         if(OrderMagicNumber() != _MAGICNUMBER)
            break;
            if(OrderProfit() > 0)
         {
            if(OrderType() == OP_BUY)
            {
               result = iLow(_SYMBOL, _TIMEFRAME, 1);
//               result = LowerZIGZAG1;
//               result = LowerFractal1;
      
               if(result <= OrderStopLoss())
                  result = OrderStopLoss();
            }
            else
            {
               result = iHigh(_SYMBOL, _TIMEFRAME, 1);
//               result = UpperZIGZAG1;
//               result = UpperFractal1;
      
               if(result >= OrderStopLoss())
                  result = OrderStopLoss();
            }
         }
         
         break;

      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;

         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
//Debug if action
/*
      if(result == 1)
      if(_COMMAND == _OPEN_LONG || _COMMAND == _OPEN_SHORT || _COMMAND == _CLOSE_LONG || _COMMAND == _CLOSE_SHORT)
      {
         Print(TimeToStr( Time[0], TIME_DATE|TIME_MINUTES) , " COMMAND: ", _COMMAND);
         Print("ZCBUpper: ", ZCBUpper, ";", "ZCBLower: ", ZCBLower, ";", "ZIGZAG: ", ZIGZAG);
      }
*/
   return(result);
}