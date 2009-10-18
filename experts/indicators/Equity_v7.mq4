//+------------------------------------------------------------------+
//|                                                    Equity_v7.mq4 |
//|                                         Copyright © 2008, Xupypr |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Xupypr"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 OrangeRed
#property indicator_color2 DodgerBlue
#property indicator_color3 SlateGray
#property indicator_color4 ForestGreen
#property indicator_width1 2
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1

extern string Only_Magics="";     // Учитывать ордера только с указанными магическими номерами (через любой разделитель)
extern string Only_Symbols="";    // Учитывать только указанные инструменты (через любой разделитель)
extern bool   Only_Current=false; // Учитывать только текущий инструмент
extern bool   Zero_Balance=false; // Учитывать только торговые ордера исключая пополнение/снятие средств
extern bool   Show_Balance=true; // Отображать баланс
extern bool   Show_Equity=true;  // Отображать средства
extern bool   Show_Margin=false; // Отображать залог (только в режиме реального времени)
extern bool   Show_Free=false;   // Отображать свободные средства (только в режиме реального времени)
extern bool   Show_Info=false;   // Отображать дополнительную информацию

double Balance[],Equity[],Margin[],Free[];
double balance,startbalance,maxprofit,drawdown,maxpeak,rf;
int ANumber,Window;
string Shortname;
datetime CurBar;

int    ticket[];     // номер тикета
int    openbar[];    // номер бара открытия
int    closebar[];   // номер бара закрытия
int    type[];       // тип операции
double lots[];       // количество лотов
string symbol[];     // инструмент
double openprice[];  // цена открытия
double closeprice[]; // цена закрытия
double commission[]; // комиссия
double swap[];       // накопленный своп
double curswap[];    // текущий своп
double dayswap[];    // дневной своп
double profit[];     // чистая прибыль
double magic[];      // магический номер

//+----------------------------------------------------------------------------+
//|  Custom indicator initialization function                                  |
//+----------------------------------------------------------------------------+
int init()
{
 if (Only_Magics=="" && Only_Symbols=="" && !Only_Current) Shortname="Total";
 else
 {
  if (Only_Magics!="") Shortname=Only_Magics; else Shortname="0";
  if (Only_Symbols!="") Shortname=StringConcatenate(Shortname," ",Only_Symbols);
  else if (Only_Current) Shortname=StringConcatenate(Shortname," ",Symbol());
 }
 ANumber=AccountNumber();
 SetIndexBuffer(0,Balance);
 SetIndexLabel(0,Shortname+" Balance");
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(1,Equity);
 SetIndexLabel(1,Shortname+" Equity");
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(2,Margin);
 SetIndexLabel(2,Shortname+" Margin");
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(3,Free);
 SetIndexLabel(3,Shortname+" Free");
 SetIndexStyle(3,DRAW_LINE);
 if (Show_Balance) Shortname=StringConcatenate(Shortname," Balance");
 if (Show_Equity)  Shortname=StringConcatenate(Shortname," Equity");
 if (Show_Margin)  Shortname=StringConcatenate(Shortname," Margin");
 if (Show_Free)    Shortname=StringConcatenate(Shortname," Free");
 IndicatorShortName(Shortname);
 IndicatorDigits(2);
 return(0);
}
//+----------------------------------------------------------------------------+
//|  Custom indicator deinitialization function                                |
//+----------------------------------------------------------------------------+
int deinit()
{
 ObjectsDeleteAll(Window);
 return(0);
}
//+----------------------------------------------------------------------------+
//|  Custom indicator iteration function                                       |
//+----------------------------------------------------------------------------+
int start()
{
 string name,text;
 static string symbols="";
 double profitloss,spread,lotsize;
 int bar,i,j,start,total,historytotal,opentotal;
 //int tick=GetTickCount();

 Window=WindowFind(Shortname);
 if (ANumber!=AccountNumber())
 {
  ArrayInitialize(Balance,EMPTY_VALUE);
  ArrayInitialize(Equity,EMPTY_VALUE);
  ArrayInitialize(Margin,EMPTY_VALUE);
  ArrayInitialize(Free,EMPTY_VALUE);
  ObjectsDeleteAll(Window);
  ANumber=AccountNumber();
  symbols="";
  CurBar=0;
 }
 if (!IsConnected())
 {
  Print("Связь с сервером отсутствует или прервана");
  return(0);
 }
 if (!OrderSelect(0,SELECT_BY_POS,MODE_HISTORY)) return(0);
 if (Time[0]!=CurBar)
 {
  CurBar=Time[0];
  if (Period()>PERIOD_D1)
  {
   Alert("Период не может быть больше D1"); 
   return(0);
  }
  historytotal=OrdersHistoryTotal();
  opentotal=OrdersTotal();
  total=historytotal+opentotal;
  ArrayResize(ticket,total);
  for (i=0;i<historytotal;i++) if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
  {
   if (Select()) ticket[i]=OrderTicket();
   else
   {
    ticket[i]=EMPTY_VALUE;
    total--;
   }
  }
  if (opentotal>0)
  {
   for (i=0;i<opentotal;i++) if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   {
    if (Select()) ticket[historytotal+i]=OrderTicket();
    else
    {
     ticket[historytotal+i]=EMPTY_VALUE;
     total--;
    }
   }
  }
  ArraySort(ticket);
  ArrayResize(ticket,total);
  ArrayResize(openbar,total);
  ArrayResize(closebar,total);
  ArrayResize(type,total);
  ArrayResize(lots,total);
  ArrayResize(symbol,total);
  ArrayResize(openprice,total);
  ArrayResize(closeprice,total);
  ArrayResize(commission,total);
  ArrayResize(swap,total);
  ArrayResize(curswap,total);
  ArrayResize(dayswap,total);
  ArrayResize(profit,total);
  ArrayResize(magic,total);
  for (i=0;i<total;i++) if (OrderSelect(ticket[i],SELECT_BY_TICKET)) ReadDeals(i);
  if (type[0]<6)
  {
   Alert("История сделок загружена не полностью");
   return(0);
  }
  start=0;
  balance=0.0;
  startbalance=0.0;
  maxprofit=0.0;
  drawdown=0.0;
  maxpeak=0.0;
  for (i=openbar[0];i>=0;i--)
  {
   profitloss=0.0;
   for (j=start;j<total;j++)
   {
    if (openbar[j]<i) continue;
    if (closebar[start]>i) start++;
    if (closebar[j]==i && closeprice[j]!=0) balance+=swap[j]+commission[j]+profit[j];
    else if (openbar[j]>=i && closebar[j]<=i)
    {
     if (type[j]>5)
     {
      balance+=profit[j];
      startbalance+=profit[j];
      name=StringConcatenate("Time: ",TimeToStr(Time[i]));
      if (ObjectFind(name)==-1) ObjectCreate(name,OBJ_VLINE,Window,Time[i],0);
      ObjectSetText(name,StringConcatenate(symbol[j],": ",DoubleToStr(profit[j],2)));
      ObjectSet(name,OBJPROP_TIME1,Time[i]);
      ObjectSet(name,OBJPROP_COLOR,OrangeRed);
      ObjectSet(name,OBJPROP_WIDTH,2);
      continue;
     }
     if (MarketInfo(symbol[j],MODE_POINT)==0)
     {
      if (StringFind(symbols,symbol[j])==-1)
      {
       Alert("В обзоре рынка не хватает "+symbol[j]);
       symbols=StringConcatenate(symbols," ",symbol[j]);
      }
      continue;
     }
     bar=iBarShift(symbol[j],0,Time[i]);
     if (TimeDayOfWeek(iTime(symbol[j],0,bar))!=TimeDayOfWeek(iTime(symbol[j],0,bar+1)) && openbar[j]!=bar)
     {
      switch (MarketInfo(symbol[j],MODE_PROFITCALCMODE))
      {
       case 0:
       {
        if (TimeDayOfWeek(iTime(symbol[j],0,bar))==4) curswap[j]+=3*dayswap[j];
        else curswap[j]+=dayswap[j];
       } break;
       case 1:
       {
        if (TimeDayOfWeek(iTime(symbol[j],0,bar))==1) curswap[j]+=3*dayswap[j];
        else curswap[j]+=dayswap[j];
       }
      }
     }
     lotsize=LotSize(symbol[j],Time[i]);
     if (type[j]==OP_BUY) profitloss+=commission[j]+curswap[j]+(iClose(symbol[j],0,bar)-openprice[j])*lots[j]*lotsize;
     else
     {
      spread=MarketInfo(symbol[j],MODE_POINT)*MarketInfo(symbol[j],MODE_SPREAD);
      profitloss+=commission[j]+curswap[j]+(openprice[j]-iClose(symbol[j],0,bar)-spread)*lots[j]*lotsize;
     }
    }
   }
   if (Show_Balance) Balance[i]=NormalizeDouble(balance,2);
   if (Show_Equity)  Equity[i]=NormalizeDouble(balance+profitloss,2);
   if (Show_Info)    Information(i,balance+profitloss);
  }
  ArrayResize(ticket,opentotal);
  if (opentotal>0)
  {
   for (i=0;i<opentotal;i++) if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) ticket[i]=OrderTicket();
  }
 }
 else
 {
  if (Only_Magics=="" && Only_Symbols=="" && !Only_Current && !Zero_Balance)
  {
   if (Show_Balance) Balance[0]=AccountBalance();
   if (Show_Equity)  Equity[0]=AccountEquity();
   if (Show_Margin)  Margin[0]=AccountMargin();
   if (Show_Free)    Free[0]=AccountFreeMargin();
   if (Show_Info)    Information(0,AccountEquity());
  }
  else
  {
   opentotal=ArraySize(ticket);
   if (opentotal>0)
   {
    for (i=0;i<opentotal;i++)
    {
     if (!OrderSelect(ticket[i],SELECT_BY_TICKET)) continue;
     if (OrderCloseTime()==0) continue;
     else if (Select()) balance+=OrderCommission()+OrderSwap()+OrderProfit();
    }
   }
   profitloss=0.0;
   opentotal=OrdersTotal();
   if (opentotal>0)
   {
    for (i=0;i<opentotal;i++)
    {
     if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
     if (Select()) profitloss+=OrderCommission()+OrderSwap()+OrderProfit();
    }
   }
   if (Show_Balance) Balance[0]=NormalizeDouble(balance,2);
   if (Show_Equity)  Equity[0]=NormalizeDouble(balance+profitloss,2);
   if (Show_Info)    Information(0,balance+profitloss);
   ArrayResize(ticket,opentotal);
   if (opentotal>0)
   {
    for (i=0;i<opentotal;i++) if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) ticket[i]=OrderTicket();
   }
  }
 }
 if (Show_Info)
 {
  name="maximal_drawdown";
  if (ObjectFind(name)==-1) ObjectCreate(name,OBJ_LABEL,Window,0,0);
  text=StringConcatenate("Maximal Drawdown: ",DoubleToStr(drawdown,2));
  text=StringConcatenate(text," (",DoubleToStr(100*drawdown/maxpeak,2),"%)");
  ObjectSetText(name,text);
  ObjectSet(name,OBJPROP_XDISTANCE,10);
  ObjectSet(name,OBJPROP_YDISTANCE,10);
  ObjectSet(name,OBJPROP_CORNER,1);
  ObjectSet(name,OBJPROP_COLOR,Silver);
  name="recovery_factor";
  if (ObjectFind(name)==-1) ObjectCreate(name,OBJ_LABEL,Window,0,0);
  text=StringConcatenate("Recovery Factor: ",DoubleToStr(rf,2));
  ObjectSetText(name,text);
  ObjectSet(name,OBJPROP_XDISTANCE,10);
  ObjectSet(name,OBJPROP_YDISTANCE,30);
  ObjectSet(name,OBJPROP_CORNER,1);
  ObjectSet(name,OBJPROP_COLOR,Silver);
 }
 //Print("Calculating - ",GetTickCount()-tick," ms");
 return(0);
}
//+----------------------------------------------------------------------------+
//|  Чтение сделок                                                             |
//+----------------------------------------------------------------------------+
void ReadDeals(int n)
{
 openbar[n]=iBarShift(NULL,0,OrderOpenTime());
 type[n]=OrderType();
 lots[n]=OrderLots();
 if (OrderType()>5) symbol[n]=OrderComment();
 else symbol[n]=OrderSymbol();
 openprice[n]=OrderOpenPrice();
 if (OrderCloseTime()!=0)
 {
  closebar[n]=iBarShift(NULL,0,OrderCloseTime());
  closeprice[n]=OrderClosePrice();
 }
 else
 {
  closebar[n]=0;
  closeprice[n]=0.0;
 }
 commission[n]=OrderCommission();
 swap[n]=OrderSwap();
 profit[n]=OrderProfit();
 if (OrderType()>5 && Zero_Balance) profit[n]=0.0;
 curswap[n]=0.0;
 int swapdays=0;
 for (int b=openbar[n]-1;b>=closebar[n];b--)
 {
  if (TimeDayOfWeek(iTime(NULL,0,b))!=TimeDayOfWeek(iTime(NULL,0,b+1)))
  {
   switch (MarketInfo(symbol[n],MODE_PROFITCALCMODE))
   {
    case 0:
    {
     if (TimeDayOfWeek(iTime(NULL,0,b))==4) swapdays+=3;
     else swapdays++;
    } break;
    case 1:
    {
     if (TimeDayOfWeek(iTime(NULL,0,b))==1) swapdays+=3;
     else swapdays++;
    }
   }
  }
 }
 if (swapdays>0) dayswap[n]=swap[n]/swapdays; else dayswap[n]=0;
 magic[n]=OrderMagicNumber();
}
//+----------------------------------------------------------------------------+
//|  Расчёт максимальной просадки                                             |
//+----------------------------------------------------------------------------+
void Information(int bar, double equity)
{
 if (maxprofit<equity) maxprofit=equity;
 if (drawdown<(maxprofit-equity))
 {
  drawdown=maxprofit-equity;
  maxpeak=maxprofit;
 } 
 if (drawdown>0 && bar==0) rf=(equity-startbalance)/drawdown;
}
//+----------------------------------------------------------------------------+
//|  Определение размера контракта                                             |
//+----------------------------------------------------------------------------+
double LotSize(string symbol, datetime tbar)
{
 double size;
 string BQ,currency=AccountCurrency();
 switch (MarketInfo(symbol,MODE_PROFITCALCMODE))
 {
  case 0:
  {
   int sbar=iBarShift(symbol,0,tbar);
   size=MarketInfo(symbol,MODE_LOTSIZE);
   if (StringSubstr(symbol,3,3)=="USD") break;
   if (StringSubstr(symbol,0,3)=="USD") size=size/iClose(symbol,0,sbar);
   else
   {
    BQ=StringSubstr(symbol,0,3)+"USD";
    if (iClose(BQ,0,0)==0) BQ="USD"+StringSubstr(symbol,0,3);
    if (iClose(BQ,0,0)==0) break;
    int BQbar=iBarShift(BQ,0,tbar);
    if (StringSubstr(BQ,0,3)=="USD") size=size/iClose(BQ,0,BQbar)/iClose(symbol,0,sbar);
    else size=size*iClose(BQ,0,BQbar)/iClose(symbol,0,sbar);
   }
  } break;
  case 1: size=MarketInfo(symbol,MODE_LOTSIZE); break;
  case 2: size=MarketInfo(symbol,MODE_TICKVALUE)/MarketInfo(symbol,MODE_TICKSIZE);
 }
 if (currency!="USD")
 {
  BQ=currency+"USD";
  if (iClose(BQ,0,0)==0)
  {
   BQ="USD"+currency;
   size*=iClose(BQ,0,iBarShift(BQ,0,tbar));
  }
  else size/=iClose(BQ,0,iBarShift(BQ,0,tbar));
 }
 return(size);
}
//+----------------------------------------------------------------------------+
//|  Выбор ордера по критериям                                                 |
//+----------------------------------------------------------------------------+
bool Select()
{
 if (OrderType()>5) return(true);
 if (OrderType()>1) return(false);
 if (Only_Magics!="")
 {
  if (StringFind(Only_Magics,DoubleToStr(OrderMagicNumber(),0))==-1) return(false);
 }
 if (Only_Symbols!="")
 {
  if (StringFind(Only_Symbols,OrderSymbol())==-1) return(false);
 }
 else if (Only_Current && OrderSymbol()!=Symbol()) return(false);
 return(true);
}
//+----------------------------------------------------------------------------+