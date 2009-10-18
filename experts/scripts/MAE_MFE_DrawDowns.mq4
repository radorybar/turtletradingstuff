//+------------------------------------------------------------------+
//|                                            MAE_MFE_DrawDowns.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"

// вставлено из скрипта SummaryReport
#define OP_BALANCE 6
#define OP_CREDIT  7
#define StatParameters 8
// вставлено из скрипта SummaryReport
#property show_inputs
extern int MaxTimeMissed=15;   // максимально допустимая дыра в загруженной истории в минутах
//+------------------------------------------------------------------+
//| заполняет массивы MAE в валюте депозита                          |
//+------------------------------------------------------------------+
bool SetMAEAndMFE(double & MFE_Array[],double & MAE_Array[],int TicketsArray[])   
   {
   bool res=false;
//----
   int bar,PeriodNumber,i,limit=ArraySize(TicketsArray);
   ArrayResize(MAE_Array,limit);
   ArrayResize(MFE_Array,limit);
   int openShift,closeShift;
   int type,znak,spread,K_spread;
   double symPoint;
   double MFE_points,MAE_points;
   double currProfit,currLoss,closePriceProfit,closePriceLoss;
   double buy,sell,OPrice,PointCost;
   double deltaPricePoints;
//----
   //Print("Зашли 1");

   for (i=0;i<limit;i++)
      {
      //Print("Зашли2");

      if (OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
         {
         openShift=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
         closeShift=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
         //Print("Истории для расчета MFE по ордеру #",TicketsArray[i]," есть ",openShift-closeShift," минутных баров, а время в минутах ",DoubleToStr((OrderCloseTime()-OrderOpenTime())/60.0,0));
         //if (openShift==-1 || closeShift==-1) Print("Не хватает истории для расчета MFE по ордеру #",TicketsArray[i]);
         type=OrderType();
         OPrice=OrderOpenPrice();
         if (type==OP_BUY) 
            {
            znak=1;
            K_spread=0;
            buy=1;
            sell=0;
            } 
         else 
            {
            znak=-1;
            K_spread=1;
            buy=0;
            sell=1;
            }
         spread=MarketInfo(OrderSymbol(),MODE_SPREAD);
         symPoint=MarketInfo(OrderSymbol(),MODE_POINT);
         //Print("spread=",spread,"   symPoint=",symPoint);
         //if (openShift-closeShift>0)
         MFE_points=-10000;
         MAE_points=-10000;
         deltaPricePoints=(OrderOpenPrice()-OrderClosePrice())/symPoint;
         if (deltaPricePoints==0) 
            {
            //Print("Будет деление на ноль в функции SetMAEAndMFE, прибыль в пунктах равна нулю");
            PointCost=MarketInfo(OrderSymbol(),MODE_POINT)*MarketInfo(OrderSymbol(),MODE_LOTSIZE);
            string first   =StringSubstr(OrderSymbol(),0,3);         // первый символ,    например EUR
            string second  =StringSubstr(OrderSymbol(),3,3);         // второй символ,    например USD
            string currency=AccountCurrency();                // валюта депозита,  например USD
            if (second==currency) PointCost=PointCost*OrderLots();
            else
               {
               string crossCurrency=StringConcatenate(second,currency);
               int barCross=iBarShift(crossCurrency,PERIOD_M1,OrderOpenTime());
               double CrossRate=iOpen(crossCurrency,PERIOD_M1,barCross);
               PointCost=PointCost*OrderLots()*CrossRate;
               }
            }
         else PointCost=MathAbs((OrderProfit())/deltaPricePoints);
         //else PointCost=MathAbs((OrderProfit()+OrderSwap())/deltaPricePoints);
         //Print("Ордер №",TicketsArray[i]," открыт по цене ",OPrice);
         for (bar=openShift;bar>=closeShift;bar--)
            {
            //currProfit=(OrderOpenPrice()-Low[bar])*znak-K_spread*spread*symPoint;
            currProfit=(iHigh(OrderSymbol(),PERIOD_M1,bar)-OPrice)*buy-(iLow(OrderSymbol(),PERIOD_M1,bar)+spread*symPoint-OPrice)*sell;
            currLoss=(iLow(OrderSymbol(),PERIOD_M1,bar)-OPrice)*buy-(iHigh(OrderSymbol(),PERIOD_M1,bar)+spread*symPoint-OPrice)*sell;
            if (iHigh(OrderSymbol(),PERIOD_M1,bar)==0) Print("2% Для  ордера #",TicketsArray[i],"  по символу ",OrderSymbol()," openShift=",openShift," closeShift=",closeShift,"  проблема с доступом к iHigh(OrderSymbol(),PERIOD_M1,bar) по времени ",TimeToStr(iTime(OrderSymbol(),PERIOD_M1,bar)));
            if (iLow(OrderSymbol(),PERIOD_M1,bar)==0) Print("2%Для  ордера #",TicketsArray[i],"  по символу ",OrderSymbol()," openShift=",openShift," closeShift=",closeShift,"  проблема с доступом к iLow(OrderSymbol(),PERIOD_M1,bar) по времени ",TimeToStr(iTime(OrderSymbol(),PERIOD_M1,bar)));

            //Print("currProfit=",currProfit,"   currLoss=",currLoss,"   OPrice=",OPrice);
            //if (currProfit>0 && currProfit/symPoint>MFE_points) 
            if (currProfit/symPoint>MFE_points) 
               {
               MFE_points=currProfit/symPoint;
               //Print("currProfit=",currProfit/symPoint);
               }
            //if (currLoss<0 && -currLoss/symPoint>MAE_points) 
            if ( -currLoss/symPoint>MAE_points) 
               {
               MAE_points=-currLoss/symPoint;
               //Print("currLoss=",currLoss/symPoint);
               }
            }
         MFE_Array[i]=MFE_points*PointCost; 
         MAE_Array[i]=-MAE_points*PointCost;

         if (MathAbs(MFE_Array[i])>10000) Print(OrderSymbol()," #",TicketsArray[i],"; MFE_Array[i]=",MFE_Array[i],"  MFE_points=",MFE_points,"  PointCost=",PointCost,"  symPoint=",symPoint,"  OrderProfit()=",OrderProfit(),"  deltaPrice=",deltaPricePoints);
         if (MathAbs(MAE_Array[i])>10000) Print(OrderSymbol()," #",TicketsArray[i],"; MFA_Array[i]=",MAE_Array[i],"  MAE_points=",MAE_points,"  PointCost=",PointCost,"  symPoint=",symPoint,"  OrderProfit()=",OrderProfit(),"  deltaPrice=",deltaPricePoints);

         //Print("#",TicketsArray[i],";",MFE_Array[i],";",MAE_Array[i]);
         }

      else
         {
         Alert("Не удалось выбрать ордер #",TicketsArray[i]);
         }   
      }

//----
   return(res);   
   }   
//+------------------------------------------------------------------+
//|  заполняет значениями прибылей и убытков                         |
//+------------------------------------------------------------------+
void    FillOrderProfits(double & ProfitsArray[],double & NormalizedProfitsArray[],double & SwapArray[],int TicketsArray[])
   {
   int total=ArraySize(TicketsArray);
   ArrayResize(ProfitsArray,total);
   ArrayResize(SwapArray,total);
   ArrayResize(NormalizedProfitsArray,total);
//----
   for (int i=0;i<total;i++)
      {
      if (OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
         {
         ProfitsArray[i]=OrderProfit()+OrderSwap()-OrderCommission();
         SwapArray[i]=OrderSwap();
         if (OrderLots()!=0) NormalizedProfitsArray[i]=0.1*ProfitsArray[i]/OrderLots();
         else Alert("Обнаружен ордер с нулевым значением лота #",TicketsArray[i]);
         }
      else
         {
         Alert("Не удалось выбрать ордер #",TicketsArray[i]);
         }   
      }
//----
   return;   
   }

//+------------------------------------------------------------------+
//| возвращает отсортированный по времени  закрытия массив тикетов   |
//+------------------------------------------------------------------+
int LoadSortedTickets(int & Tickets[])
   {
   int i,counter;
   int TicketAndTime[][2];
//----
   if (ArraySize(Tickets)==0) return;
   ArrayResize(TicketAndTime,OrdersHistoryTotal());

   for (i=0;i<OrdersHistoryTotal();i++) 
      {
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         {
            if (OrderType()<=OP_SELL) 
               {
               TicketAndTime[counter][0]=OrderCloseTime();
               TicketAndTime[counter][1]=OrderTicket();
               counter++;
               }
         }
      }
   ArrayResize(TicketAndTime,counter);
   ArrayResize(Tickets,counter);
   ArraySort(TicketAndTime);
   for (i=0;i<counter;i++) 
      {
      Tickets[i]=TicketAndTime[i][1];
      }
   int err=GetLastError();

//----
   return(counter);
   }
//+------------------------------------------------------------------+
//| возвращает true, если символ с именем symbolName уже есть        |
//+------------------------------------------------------------------+
bool AddSymbol(string & SimbolListArray[],string symbolName)
   {
   bool res=false;
   int size=ArraySize(SimbolListArray);
//----
   //Print("Добавляем символ ",symbolName);
   ArrayResize(SimbolListArray,size+1);
   if (ArraySize(SimbolListArray)==size+1)
      {
      SimbolListArray[size]=StringTrimLeft(StringTrimRight(symbolName));
      res=true;
      }
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//| возвращает true, если символ с именем symbolName уже есть        |
//+------------------------------------------------------------------+
bool SymbolFoundInArray(string SimbolListArray[],string symbolName)
   {
   bool res=false;
   int pos;
//----
   for (int i=0;i<ArraySize(SimbolListArray);i++)
      {
      pos=StringFind(SimbolListArray[i],StringTrimLeft(StringTrimRight(symbolName)));
      if (pos!=-1 && pos==0) 
         {
         if (StringLen(SimbolListArray[i])!=StringLen(StringTrimLeft(StringTrimRight(symbolName)))) 
            {
            //Print("Поиск нового символа в массиве дал сюрприз");
            //Print("первый=|",SimbolListArray[i],"| второй=|",symbolName,"|");
            }
         res=true;
         break;
         }
      }
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//| подсчитывает число открытых и отмененных ордеров                 |
//+------------------------------------------------------------------+
bool GetNumberOfOrders(int & Closed,int & Cancelled, string & SymbolsArray[])
   {
   bool res=false;
   //Print("Ордеров в истории ",OrdersHistoryTotal());
//----
   for (int i=OrdersHistoryTotal()-1;i>=0;i--) 
      {
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         {
         if (OrderType()==OP_BALANCE) continue;
            if (!SymbolFoundInArray(SymbolsArray,OrderSymbol())) 
               AddSymbol(SymbolsArray,OrderSymbol());
         if (OrderType()>OP_SELL) Cancelled++;
         else Closed++; 
         }
      }
   if (Cancelled+Closed>0) res=true;   
//----
   return(res);
   }
//+------------------------------------------------------------------+
//| возвращает индекс, на которой искомая строка FindName            |
//+------------------------------------------------------------------+
int IndexOfName(string & StringArray[],string FindName)
   {
   int res=-1000;
//----
   int total=ArraySize(StringArray);
   for (int i=0;i<total;i++)
      if (StringArray[i]==FindName)
         {
         res=i;
         break;
         }
//----
   return(res);
   }
//+------------------------------------------------------------------+
//| проверим минутную историю на наличие дырок                       |
//+------------------------------------------------------------------+
bool    CheckHistoryOnClosedOrders(int & ClosedTicketsArray[],string & SymbolsForClosedOrders[])
   {
   bool res=true;
   int errors[100][3];  // в первый элемент пишем индекс символа, во второй - тикет ордера, в третий - дату/время ошибки 
   int errCounter;      // счетчик ошибок
   int openBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
   int closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
   int TimeInterval[][2];// первый элемент - начальная дата пропуска, второй элемент - конечная дата пропуска
   int indexSymbol;
   datetime timeClose;
//----
   int i,number_orders=ArraySize(ClosedTicketsArray),number_symbols=ArraySize(SymbolsForClosedOrders);
   ArrayResize(TimeInterval,number_symbols);
   for (i=0;i<number_symbols;i++) TimeInterval[i][0]=TimeCurrent();

   for (i=0;i<number_orders;i++)
      {
      if (OrderSelect(ClosedTicketsArray[i],SELECT_BY_TICKET))
         {
         openBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
         if (OrderCloseTime()!=0) closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
         else closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,TimeCurrent());
         indexSymbol=IndexOfName(SymbolsForClosedOrders,OrderSymbol());
         if (MathAbs(iTime(OrderSymbol(),PERIOD_M1,openBar_M1)-OrderOpenTime())/60>MaxTimeMissed)
            {
            errors[errCounter][0]=indexSymbol;
            errors[errCounter][1]=ClosedTicketsArray[i];
            errors[errCounter][2]=OrderOpenTime();
            res=false;
            if (OrderOpenTime()<TimeInterval[indexSymbol][0]) TimeInterval[indexSymbol][0]=OrderOpenTime();
            if (OrderOpenTime()>TimeInterval[indexSymbol][1]) TimeInterval[indexSymbol][1]=OrderOpenTime();
            //Print("Ошибка при поиске бара открытия на символе ",OrderSymbol()," M1 для ордера #",ClosedTicketsArray[i],"=>",TimeToStr(OrderOpenTime()));
            errCounter++;
            }
         if (OrderCloseTime()!=0) timeClose=OrderCloseTime();
         else timeClose=TimeCurrent();
         if (MathAbs(iTime(OrderSymbol(),PERIOD_M1,closeBar_M1)-timeClose)/60>MaxTimeMissed)
            {
            errors[errCounter][0]=indexSymbol;
            errors[errCounter][1]=ClosedTicketsArray[i];
            errors[errCounter][2]=OrderCloseTime();
            res=false;
            if (OrderCloseTime()<TimeInterval[indexSymbol][0]) TimeInterval[indexSymbol][0]=timeClose;
            if (OrderCloseTime()>TimeInterval[indexSymbol][1]) TimeInterval[indexSymbol][1]=timeClose;
            Print("Ошибка при поиске бара закрытия на символе ",OrderSymbol()," M1 для ордера #",ClosedTicketsArray[i],"=>",TimeToStr(timeClose));
            errCounter++;
            }
         }
      } 

   if (!res) 
      {
      Alert("При проверке счета обнаружено ошибок пропуска минутных баров в доступной истории - ",errCounter, "! Подробности смотри в закладке Журнал");
      for (i=0;i<number_symbols;i++)
         {
         if (TimeInterval[i][0]*TimeInterval[i][1]!=0) Print("Не достает истории на ",SymbolsForClosedOrders[i]," на интервале:",TimeToStr(TimeInterval[i][0]),"-",TimeToStr(TimeInterval[i][1]));
         }      
      }
//----
   return(res);
   }
//+------------------------------------------------------------------+
//| вычислим все просадки                                            |
//+------------------------------------------------------------------+
bool CalculateDD(int & ClosedTicketsArray[],string & SymbolsArray[] ,double & minEquity,double & MoneyDD,
   double & MoneyDDPer,double & RelativeDD,double & RelativeDD$)
   {
   bool res=false;
//----
  int AllOpenedOrdersTickets[];           // массив заркытых ордеров из истории + текущие незакрытые ордера
  int ConveyerArray[][2];                 // первывй элемент - время, второй элемент - тикет

   int i,k,marketOrders;
   for (i=0;i<OrdersTotal();i++)
      {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
         if (OrderType()==OP_BUY || OrderType()==OP_SELL) marketOrders++;
         }
      }
   //Print("marketOrders=",marketOrders,",  ордеров в истории=",ArraySize(ClosedTicketsArray));
   if (ArraySize(ClosedTicketsArray)+marketOrders==0) 
      {
      Print("Нет ордеров для обработки");
      }
   ArrayResize(AllOpenedOrdersTickets,ArraySize(ClosedTicketsArray)+marketOrders);
   
   i=0;
   if (ArraySize(ClosedTicketsArray)>0) for (i=0;i<ArraySize(ClosedTicketsArray);i++) AllOpenedOrdersTickets[i]=ClosedTicketsArray[i];
   //Print("AllOpenedOrdersTickets=",ArraySize(AllOpenedOrdersTickets));
   if (marketOrders>0)
      {
      while (k<marketOrders) 
         {
         if (OrderSelect(k,SELECT_BY_POS,MODE_TRADES))
            {
            if (OrderType()==OP_BUY || OrderType()==OP_SELL) 
               {
               AllOpenedOrdersTickets[i]=OrderTicket();
               //Print("i=",i,"   k=",k,"  ticket=",OrderTicket());
               if (!SymbolFoundInArray(SymbolsArray,OrderSymbol()))    AddSymbol(SymbolsArray,OrderSymbol()); 
               i++;
               }
            else Alert("Неудачная попытка выбрать ордер!!!");               
            }
         k++;
         }
      }
   if (!CheckHistoryOnClosedOrders(AllOpenedOrdersTickets,SymbolsArray))   return(false);
   ArrayResize(ConveyerArray,ArraySize(AllOpenedOrdersTickets)*2);
   //Print("Размер конвейера=",ArrayRange(ConveyerArray,0));
   for (i=0;i<ArrayRange(AllOpenedOrdersTickets,0);i++)
      {
      //Print("i=",i,"   ticket=",AllOpenedOrdersTickets[i]);
      if (OrderSelect(AllOpenedOrdersTickets[i],SELECT_BY_TICKET))
         {
         //Print("i=",i,"   ticket=",AllOpenedOrdersTickets[i]," OrderOpenTime=",TimeToStr(OrderOpenTime())," OrderCloseTime=",TimeToStr(OrderCloseTime()));
         ConveyerArray[2*i][0]=OrderOpenTime();
         ConveyerArray[2*i][1]=AllOpenedOrdersTickets[i];
         if (OrderCloseTime()!=0) ConveyerArray[2*i+1][0]=OrderCloseTime();
         else ConveyerArray[2*i+1][0]=TimeCurrent()+200;
         ConveyerArray[2*i+1][1]=-AllOpenedOrdersTickets[i];
         }
      else Alert("Ошибка выбора ордера при расчете просадок!!!");
      }
   ArraySort(ConveyerArray);      // отсортируем конвейер по времени событий: открытие-закрытие ордера
   //for (i=0;i<ArrayRange(ConveyerArray,0);i++) Print(TimeToStr(ConveyerArray[i][0])," - ", ConveyerArray[i][1]);
   
   int ticket=OrderSelect(ConveyerArray[0][1],SELECT_BY_TICKET);
   string SymbolName=OrderSymbol();
   int max=ArrayRange(ConveyerArray,0);

   datetime startTrade=TimeRoundeMinute(ConveyerArray[0][0]);
   datetime stopTrade=TimeRoundeMinute(ConveyerArray[max-1][0]);
   if (stopTrade>TimeCurrent()) stopTrade=TimeCurrent();

   double balance=10000;         // начальное значение депозита равно 10 000
   double minimalEquity=balance; // начальное значение депозита равно 10 000
   double lastPeak=balance;      // последний максимум эквити
   double lastMin=balance;       // последний минимум эквити
   double equity;                // текущий эквити
   double MaxProfit,MinProfit,FixedProfit;
   double currDD, lastmaxDD,currPercentDD,lastPercentDD;
   int curr_pos;
   int stack[];
   datetime curr_minute;
   equity=balance;
   int FileHandle;
//   Print("Начальная дата ",TimeToStr(startTrade,TIME_DATE|TIME_SECONDS),
//      ", конечная дата ",TimeToStr(stopTrade,TIME_DATE|TIME_SECONDS));
   FileHandle=FileOpen(AccountNumber()+"_equity_2.csv",FILE_CSV|FILE_WRITE);
   FileWrite(FileHandle,"Date","BALANCE","EQUITY");
   FileWrite(FileHandle,TimeToStr(startTrade-1),balance,equity);
   for (curr_minute=startTrade;curr_minute<=stopTrade;curr_minute=curr_minute+60)
      {
      SetStack(stack,ConveyerArray,curr_minute,curr_pos);
      CheckAllProfits(stack,MaxProfit,MinProfit,curr_minute);
      equity=balance+(MaxProfit+MinProfit)/2;
//      Print("balance=",balance);
      if (equity>lastPeak) 
         {
         lastPeak=equity;
         lastMin=equity;
         }
      if (equity<lastMin) 
         {
         lastMin=equity;
         currDD=lastPeak-lastMin;
         if (currDD>lastmaxDD) 
            {
            lastmaxDD=currDD;
            MoneyDDPer=(lastmaxDD)/lastPeak*100;
            MoneyDD=lastmaxDD;
            }
         currPercentDD=currDD/lastPeak*100;
         if (currPercentDD>lastPercentDD)
            {
            lastPercentDD=currPercentDD;
            RelativeDD=lastPercentDD;
            RelativeDD$=currDD;
            }   
         }

      if (lastMin<minimalEquity) 
         {
         minimalEquity=lastMin;
         }
         
      CloseTickets(stack,curr_minute,FixedProfit);
      balance=balance+FixedProfit;
      FileWrite(FileHandle,TimeToStr(curr_minute),balance,equity);
      }
   FileClose(FileHandle);   
   minEquity=minimalEquity;

//----
   return(res);   
   }
//+------------------------------------------------------------------+
//| просуммируем  профиты по открытым тикетам                        |
//+------------------------------------------------------------------+
bool   CheckAllProfits(int stackTickets[],double & maxProfit, double & minProfit,datetime this_minute)
   {
   bool res=false;
   maxProfit=0;
   minProfit=0;
   double thisOrderMaxProfit,thisOrderMinProfit;
//----
   int i,type,pos;
   for (i=0;i<ArraySize(stackTickets);i++)
      {
      if (GetProfit(stackTickets[i],thisOrderMaxProfit,thisOrderMinProfit,this_minute))
         {
         //Print("Посчитали профит для ордера#",stackTickets[i]," в ",TimeToStr(this_minute));
         //Print("thisOrderMaxProfit=",thisOrderMaxProfit,"   thisOrderMinProfit=",thisOrderMinProfit);
         maxProfit+=thisOrderMaxProfit;
         minProfit+=thisOrderMinProfit;
         }
      else Print("Не удалось определить текущую прибыль для ордера#",stackTickets[i]);         
      }
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//| возвращает минимальный максимальный профит для оредера           |
//+------------------------------------------------------------------+
bool GetProfit(int ticket,double & maxProf,double & minProf,datetime at_minute)
   {
   bool res=true;
//----
   string symbol,crossPair,firstCurrency,secondCurrency,baseCurrency=AccountCurrency();
   int bar,type,maxPoint,minPoint,err;
   double openPrice,maxPrice,minPrice,spread,point,pointCost,lots,price;
   datetime foundedTime;
   minProf=0;
   maxProf=0;
   //Print("Получим значение прибыли для ордера#",ticket);
   if (ticket<0) return(res);
   if (OrderSelect(ticket,SELECT_BY_TICKET))
      {
      symbol=OrderSymbol();
      firstCurrency=StringSubstr(OrderSymbol(),0,3);
      secondCurrency=StringSubstr(OrderSymbol(),3,3);
      //Print("base=",baseCurrency,"   firstCurrency=",firstCurrency,"   secondCurrency=",secondCurrency);
      type=OrderType();
      openPrice=OrderOpenPrice();
      bar=iBarShift(symbol,PERIOD_M1,at_minute);
      foundedTime=iTime(symbol,PERIOD_M1,bar);
      spread=MarketInfo(symbol,MODE_SPREAD);
      point=MarketInfo(symbol,MODE_POINT);
      lots=OrderLots();
      if (firstCurrency==baseCurrency)
         {
         price=(iHigh(symbol,PERIOD_M1,bar)+iLow(symbol,PERIOD_M1,bar))/2;
         //Print("price=",price);
         pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)/price;
         }
      if (secondCurrency==baseCurrency)
         {
         pointCost=point*MarketInfo(symbol,MODE_LOTSIZE);
         }
      if (firstCurrency!=baseCurrency && secondCurrency!=baseCurrency)
         {
         //Print("Кросс ",symbol);
         if (MarketInfo(secondCurrency+baseCurrency,MODE_BID)>0) 
            {
            crossPair=StringConcatenate(secondCurrency,baseCurrency);
            price=(iHigh(crossPair,PERIOD_M1,bar)+iLow(crossPair,PERIOD_M1,bar))/2;
            pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)*price;
            }
         if (MarketInfo(baseCurrency+secondCurrency,MODE_BID)>0) 
            {
            crossPair=StringConcatenate(baseCurrency,secondCurrency);
            price=(iHigh(crossPair,PERIOD_M1,bar)+iLow(crossPair,PERIOD_M1,bar))/2;
            //Print(crossPair,"=",price,"   ",TimeToStr(foundedTime));
            pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)/price;
            }

         err=GetLastError();
         //Print("Ошибка доступа к цене ",crossPair," M1 в ",TimeToStr(at_minute));
         }   
      //Print("Стоимость пункта  для ордера#",ticket," составляет ",pointCost);
         
      if (foundedTime!=TimeRoundeMinute(at_minute)) 
         {
         //Print("Ошибка рассогласования времени на ",symbol," M1 в ",TimeToStr(at_minute));
         //Print("        foundedTime=",TimeToStr(foundedTime));
         }
      if (type==OP_BUY)
         {
         maxProf=(iHigh(symbol,PERIOD_M1,bar)-openPrice)/point;
         minProf=(iLow(symbol,PERIOD_M1,bar)-openPrice)/point;
         }
      if (type==OP_SELL)
         {
         maxProf=(openPrice-iHigh(symbol,PERIOD_M1,bar))/point+spread;
         minProf=(openPrice-iLow(symbol,PERIOD_M1,bar))/point+spread;
         }
      maxProf=maxProf*lots*pointCost;
      minProf=minProf*lots*pointCost;
      //Print("maxProf=",maxProf,"   minProf=",minProf," at ",TimeToStr(at_minute));
      }
   else
      {
      res=false;
      Print("Не удалось выбрать ордер#",ticket," в ",TimeToStr(at_minute),". Функция GetProfit()");
      }     
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//| закроем нужные и вернем результат от закрытых ордеров            |
//+------------------------------------------------------------------+
bool CloseTickets(int & stackTickets[],datetime this_minute,double & fixedProfit)
   {
   bool res=false;
//----
   int i,type,pos,toCloseTickets[];
   int closedCounter;
   fixedProfit=0;
   for (i=0;i<ArraySize(stackTickets);i++)
      {
      if (OrderSelect(stackTickets[i],SELECT_BY_TICKET))
         {
         if (TimeRoundeMinute(OrderCloseTime())==TimeRoundeMinute(this_minute) && stackTickets[i]>=0) 
            {
            fixedProfit=fixedProfit+OrderProfit()+OrderSwap()-OrderCommission();
            AddTicketToClose(toCloseTickets,stackTickets[i]);
            //Print("Удаляем из стека ордер#",stackTickets[i]," в ",TimeToStr(this_minute));
            closedCounter++;
            }
         }
      }
   if (closedCounter>0)
      {
      res=true;
      for (i=0;i<closedCounter;i++)
         {
         if (!DeleteTicketFromStack(stackTickets,toCloseTickets[i])) Print("Ошибка удаления ордера#",toCloseTickets[i]);
         if (!DeleteTicketFromStack(stackTickets,-toCloseTickets[i])) Print("Ошибка удаления ордера#",-toCloseTickets[i]);
         }
      GetLastError();
      ArrayResize(toCloseTickets,0);
      if (GetLastError()>0) Print("Ошибка при задании нулевого размера массива");
      }      
//----
   return(res);
   }

//+------------------------------------------------------------------+
//| удаляет из стека закрытые ордера                                 |
//+------------------------------------------------------------------+
bool  DeleteTicketFromStack(int & OpenedTicketsArray[],int сloseвTicket)
   {
   bool res=false;
//----
   int i,pos,size=ArraySize(OpenedTicketsArray);
   for (i=0;i<size;i++)
      {
      if (OpenedTicketsArray[i]==сloseвTicket)
         {
         pos=i;
         break;
         }
      }
   GetLastError();      
   OpenedTicketsArray[pos]=OpenedTicketsArray[size-1];
   ArrayResize(OpenedTicketsArray,size-1);   // выбросили последний эелемент
   if (GetLastError()==0) res=true;
//----
   return(res);
   }
   
//+------------------------------------------------------------------+
//|  добавим  TicketNumber в массив Array                            |
//+------------------------------------------------------------------+
bool  AddTicketToClose(int & Array[],int TicketNumber)
   {
   bool res=false;
//----
   GetLastError();
   int size=ArraySize(Array);
   ArrayResize(Array,size+1);
   Array[size]=TicketNumber;
   if (GetLastError()==0) res=true;

//----
   return(res);
   }
//+------------------------------------------------------------------+
//|  проведем операции со стеком тикетов открытых ордеров            |
//+------------------------------------------------------------------+
void SetStack(int & stackArray[],int Conveyer[][],datetime this_minute,int & conveyer_pos)
   {
//----
   int i,list=ArrayRange(Conveyer,0);

   while ((TimeRoundeMinute(this_minute)==TimeRoundeMinute(Conveyer[conveyer_pos][0])))
      {
      AddTicketToStack(stackArray,Conveyer[conveyer_pos][1]); 
      //Print("Добавили в стек ордер#",Conveyer[conveyer_pos][1]," в ",TimeToStr(this_minute));
      conveyer_pos++;
      }
//----
   return;
   }

//+------------------------------------------------------------------+
//| добавим тикеты вновь открытых ордеров                             |
//+------------------------------------------------------------------+
bool AddTicketToStack(int & stackArray[],int ticket) 
   {
   bool res=false;
//----
   GetLastError();
   int size=ArraySize(stackArray);
   ArrayResize(stackArray,size+1);
   stackArray[size]=ticket;
   if (GetLastError()==0) res=true;
//----
   return(res);   
   }
//+------------------------------------------------------------------+
//|  округление даты с точностью до минуты                           |
//+------------------------------------------------------------------+
datetime TimeRoundeMinute(datetime input)
   {
   datetime res;
//----
   res=StrToTime(TimeToStr(input,TIME_DATE|TIME_MINUTES));
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//|  запишем таблицу пофитов и соответствующих MAE и MFE             |
//+------------------------------------------------------------------+
bool WriteMAE_MFE(double MFE_Array[],double MAE_Array[],int TicketsArray[],string FileName)
   {
   bool res=true;
   int i,FH,total=ArraySize(TicketsArray);
   string Line;
//----
   if (total==0) return(false);
   Print("Количество строк в таблице MAE_MFE равно ",total);
   FH=FileOpen(FileName,FILE_READ|FILE_WRITE|FILE_CSV); 
   if (FH>0)
      {
      FileWrite(FH,"Ticket #","MFE","P&L","MAE","P&L");

      for (i=0;i<total;i++) 
         if (OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
            {
            FileSeek(FH,0,SEEK_END);
            FileWrite(FH,OrderTicket(),MFE_Array[i],OrderProfit(),MAE_Array[i],OrderProfit());
            }
      FileClose(FH);
      }
   else res=false;
//----
   return(res);
   }
   
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
  int ClosedOrders, CancelledOrders;      // количество открытых и отмененных ордеров
  int ClosedTickets[],CancelledTickets[]; // масивы, содержащие тикеты закрытых и отмененных ордеров
  int AllOpenedOrdersTickets[];           // массив заркытых ордеров из истории + текущие незакрытые ордера
  string Symbols[];                       // массив, в котором хранятся имена символов, по которым были сделки
  double Swaps[];                         // собственно, свопы
  double Profits[],NormalizedProfits[];   // массивы, хранящие изначальные профиты и нормализованные к 0.1 лоту
  double MFE[];                           // массив, содержащий данные о максимальной потенциальной прибыли для каждого ордера
  double MAE[];                           // массив, содержащий данные о максимальной просадке для каждого ордера
  double AccountDetails[][9]; 
  double MinimalEquity;                   // минимальное историческое значение Эквити
  double MoneyDrawDown;                   // максимальная денежная просадка
  double MoneyDrawDownInPercent;          // процентное выражение для максимальной денежной просадки
  double RelativeDrawDown;                // максимальная процентная просадка
  double RelativeDrawDownInMoney;         // денежное выражение максимальной процентной просадки

//----
   
   if (!GetNumberOfOrders(ClosedOrders, CancelledOrders,Symbols))
      {
      Print("Ордера в истории не найдены, обработка прекращена");
      }

   ArrayResize(ClosedTickets,ClosedOrders);
   ArrayResize(CancelledTickets,CancelledOrders);
   ArrayResize(AccountDetails,ClosedOrders);
   ArrayResize(Swaps ,ClosedOrders);
  
   LoadSortedTickets(ClosedTickets);
   FillOrderProfits(Profits,NormalizedProfits,Swaps,ClosedTickets);
      
   if (CheckHistoryOnClosedOrders(ClosedTickets,Symbols))   // проверим на наличие дыр в истории
      {
      SetMAEAndMFE(MFE,MAE,ClosedTickets);                  // и если дыр нет - заполним MAE и MFE
      WriteMAE_MFE(MFE,MAE,ClosedTickets,"MAE_MFE_reports\\"+AccountNumber()+"_MAE_MFE.csv");
      }
   else return;
   
   CalculateDD(ClosedTickets,Symbols,MinimalEquity,MoneyDrawDown,MoneyDrawDownInPercent,RelativeDrawDown,RelativeDrawDownInMoney);
   Print("AbsDD=",10000-MinimalEquity," MoneyDrawDown=",MoneyDrawDown,"  MoneyDrawDownInPercent=",MoneyDrawDownInPercent,
      "  RelativeDrawDown=",RelativeDrawDown," RelativeDrawDownInMoney=",RelativeDrawDownInMoney);
//----
   return(0);
  }
//+------------------------------------------------------------------+