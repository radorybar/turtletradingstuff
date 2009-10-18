//+------------------------------------------------------------------+
//|                                      Renko v1 Expert Advisor.mq4 |
//|                              Copyright © 2008, TradingSytemForex |
//|                                http://www.tradingsystemforex.com |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2008, TradingSytemForex"
#property link "http://www.tradingsystemforex.com"

#define EAName "Renko v1 Expert Advisor"

extern string separator1="---------------- Entry Settings";
extern int PeriodATR=10;
extern double Katr=1.00;
extern string separator2="---------------- Money Management";
extern double Lots=0.1; //lots
extern bool RiskManagement=false; //money management
extern double RiskPercent=10; //risk in percentage
extern bool Martingale=false; //martingale
extern double Multiplier=1.5; //multiplier
extern double MinProfit=0; //minimum profit to apply the martingale
extern bool UseBasketOptions=false; //use basket loss/profit
extern int BasketProfit=1000; // if equity reaches this level, close trades
extern int BasketLoss=9999; // if equity reaches this negative level, close trades
extern string separator3="---------------- Order Management";
extern int StopLoss=0; //stop loss
extern int TakeProfit=0; //take profit
extern int TrailingStop=0; //trailing stop
extern int TrailingStep=1; //margin allowe to the price before to enable the ts
extern int BreakEven=0; //breakeven
extern bool AddPositions=false; //positions cumulated
extern int MaxOrders=100; //maximum number of orders
extern bool UseHiddenSL=false; //use hidden sl
extern int HiddenSL=5; //stop loss under 15 pîps
extern bool UseHiddenTP=false; //use hidden tp
extern int HiddenTP=10; //take profit under 10 pîps
extern int Magic=0; // magic number
extern int Slippage=3; // how many pips of slippage can you tolorate
extern string separator4="---------------- Filters";
extern bool MAFilter=false; //moving average filter
extern int MAPeriod=20; //ma filter period
extern int MAMethod=1; //ma filter method
extern int MAPrice=0; //ma filter price
extern bool TradeOnSunday=true; //time filter on sunday
extern bool MondayToThursdayTimeFilter=false; //time filter the week
extern int MondayToThursdayStartHour=8; //start hour time filter the week
extern int MondayToThursdayEndHour=17; //end hour time filter the week
extern bool FridayTimeFilter=false; //time filter on friday
extern int FridayStartHour=8; //start hour time filter on friday
extern int FridayEndHour=14; //end hour time filter on friday
extern string separator5="---------------- Extras";
extern bool ReverseTheSystem=false; //sell/buy instead of buy/sell

int Slip=3;int err=0;int TK;static int TL=0;double Balance=0.0;double maxEquity;double minEquity;double CECount;double CEProc;double CEBuy;double CESell;

//start function
int start(){int j=0,limit=1;double BV=0,SV=0;BV=0;SV=0;if(CntO(OP_BUY,Magic)>0)TL=1;if(CntO(OP_SELL,Magic)>0)TL=-1;
for(int i=1;i<=limit;i++){

if ((TradeOnSunday==false&&DayOfWeek()==0)||(MondayToThursdayTimeFilter&&DayOfWeek()>=1&&DayOfWeek()<=4&&!(Hour()>=MondayToThursdayStartHour&&Hour()<=MondayToThursdayEndHour))||
(FridayTimeFilter&&DayOfWeek()==5&&!(Hour()>=FridayStartHour&&Hour()<=FridayEndHour))){CloseEverything();return(0);}

//Basket profit or loss
double CurrentProfit=0;double CurrentBasket=0;CurrentBasket=AccountEquity()-AccountBalance();
if(UseBasketOptions&&CurrentBasket>maxEquity)maxEquity=CurrentBasket;if(UseBasketOptions&&CurrentBasket<minEquity) minEquity=CurrentBasket;
if(UseBasketOptions&&CurrentBasket>=BasketProfit||CurrentBasket<=(BasketLoss*(-1))){CloseEverything();CECount++;}

//ma filter
double MAF=iMA(Symbol(),0,MAPeriod,0,MAMethod,MAPrice,i);string MAFIB="false";string MAFIS="false";
if((MAFilter==false)||(MAFilter&&Bid>MAF))MAFIB="true";if((MAFilter==false)||(MAFilter&&Ask<MAF))MAFIS="true";

//main signal
double REN1=iCustom(Symbol(),0,"Renko_v1",PeriodATR,Katr,0,i+1);
double REN2=iCustom(Symbol(),0,"Renko_v1",PeriodATR,Katr,0,i);
string SBUY="false";string SSEL="false";
if(REN2>REN1)SBUY="true";if(REN2<REN1)SSEL="true";

//entry conditions
if(MAFIB=="true"&&SBUY=="true"){if(ReverseTheSystem)SV=1;else BV=1;break;}
if(MAFIS=="true"&&SSEL=="true"){if(ReverseTheSystem)BV=1;else SV=1;break;}}

//risk management
bool MM=RiskManagement;
if(MM){if(RiskPercent<0.1||RiskPercent>100){Comment("Invalid Risk Value.");return(0);}
else{Lots=MathFloor((AccountFreeMargin()*AccountLeverage()*RiskPercent*Point*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*
MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);}}
if(MM==false){Lots=Lots;}

//martingale
if(Balance!=0.0&&Martingale==True){if(Balance>AccountBalance())Lots=Multiplier*Lots;else if((Balance+MinProfit)<AccountBalance())Lots=Lots/Multiplier;
else if((Balance+MinProfit)>=AccountBalance()&&Balance<=AccountBalance())Lots=Lots;}Balance=AccountBalance();if(Lots<0.01)Lots=0.01;if(Lots>100)Lots=100;

//positions initialization
int cnt=0,OP=0,OS=0,OB=0,CS=0,CB=0;OP=0;for(cnt=0;cnt<OrdersTotal();cnt++){OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if((OrderType()==OP_SELL||OrderType()==OP_BUY)&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0))OP=OP+1;}
if(OP>=1){OS=0; OB=0;}OB=0;OS=0;CB=0;CS=0;int SL=StopLoss;int TP=TakeProfit;

//entry conditions verification
if(SV>0){OS=1;OB=0;}if(BV>0){OB=1;OS=0;}

//conditions to close position
if((SV>0)||(UseHiddenSL&&(OrderOpenPrice()-Bid)/Point>=HiddenSL)||(UseHiddenTP&&(Ask-OrderOpenPrice())/Point>=HiddenTP)){if(ReverseTheSystem)CS=1;else CB=1;}
if((BV>0)||(UseHiddenSL&&(Ask-OrderOpenPrice())/Point>=HiddenSL)||(UseHiddenTP&&(OrderOpenPrice()-Bid)/Point>=HiddenTP)){if(ReverseTheSystem)CB=1;else CS=1;}
for(cnt=0;cnt<OrdersTotal();cnt++){OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if(OrderType()==OP_BUY&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){if(CB==1){OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Red);return(0);}}
if(OrderType()==OP_SELL&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){if(CS==1){OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);return(0);}}}
double SLI=0,TPI=0;int TK=0;

//open position
if((AddP()&&AddPositions&&OP<=MaxOrders)||(OP==0&&!AddPositions)){
if(OS==1){if(TP==0)TPI=0;else TPI=Bid-TP*Point;if(SL==0)SLI=0;else SLI=Bid+SL*Point;
TK=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,SLI,TPI,EAName,Magic,0,Red);OS=0;return(0);}	
if(OB==1){if(TP==0)TPI=0;else TPI=Ask+TP*Point;if(SL==0)SLI=0;else SLI=Ask-SL*Point;
TK=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,SLI,TPI,EAName,Magic,0,Lime);OB=0;return(0);}}
for(j=0;j<OrdersTotal();j++){if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)){if(OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){TrP();}}}return(0);}

//number of orders
int CntO(int Type,int Magic){int _CntO;_CntO=0;
for(int j=0;j<OrdersTotal();j++){OrderSelect(j,SELECT_BY_POS,MODE_TRADES);if(OrderSymbol()==Symbol()){
if((OrderType()==Type&&(OrderMagicNumber()==Magic)||Magic==0))_CntO++;}}return(_CntO);}

//close all orders
int CloseEverything(){double myAsk;double myBid;int myTkt;double myLot;int myTyp;int i;bool result = false;
for(i=OrdersTotal();i>=0;i--){OrderSelect(i,SELECT_BY_POS);myAsk=MarketInfo(OrderSymbol(),MODE_ASK);            
myBid=MarketInfo(OrderSymbol(),MODE_BID);myTkt=OrderTicket();myLot=OrderLots();myTyp=OrderType();
switch(myTyp){case OP_BUY:result=OrderClose(myTkt,myLot,myBid,Slippage,Red);CEBuy++;break;
case OP_SELL:result=OrderClose(myTkt,myLot,myAsk,Slippage,Red);CESell++;break;
case OP_BUYLIMIT:case OP_BUYSTOP:case OP_SELLLIMIT:case OP_SELLSTOP:result=OrderDelete(OrderTicket());}
if(result == false){Alert("Order",myTkt,"failed to close. Error:",GetLastError());
Print("Order",myTkt,"failed to close. Error:",GetLastError());Sleep(3000);}Sleep(1000);CEProc++;}}

//trailing stop and breakeven
void TrP(){int BE=BreakEven;int TS=TrailingStop;double pb,pa,pp;pp=MarketInfo(OrderSymbol(),MODE_POINT);if(OrderType()==OP_BUY){pb=MarketInfo(OrderSymbol(),MODE_BID);if(BE>0){
if((pb-OrderOpenPrice())>BE*pp){if((OrderStopLoss()-OrderOpenPrice())<0){ModSL(OrderOpenPrice()+0*pp);}}}if(TS>0){if((pb-OrderOpenPrice())>TS*pp){
if(OrderStopLoss()<pb-(TS+TrailingStep-1)*pp){ModSL(pb-TS*pp);return;}}}}if(OrderType()==OP_SELL){pa=MarketInfo(OrderSymbol(),MODE_ASK);
if(BE>0){if((OrderOpenPrice()-pa)>BE*pp){if((OrderOpenPrice()-OrderStopLoss())<0){ModSL(OrderOpenPrice()-0*pp);}}}if(TS>0){if(OrderOpenPrice()-pa>TS*pp){
if(OrderStopLoss()>pa+(TS+TrailingStep-1)*pp||OrderStopLoss()==0){ModSL(pa+TS*pp);return;}}}}}

//stop loss modification function
void ModSL(double ldSL){bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,CLR_NONE);}

//add positions function
bool AddP(){int _num=0; int _ot=0;
for (int j=0;j<OrdersTotal();j++){if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol()&&OrderType()<3&&((OrderMagicNumber()==Magic)||Magic==0)){	
_num++;if(OrderOpenTime()>_ot) _ot=OrderOpenTime();}}if(_num==0) return(true);if(_num>0 && ((Time[0]-_ot))>0) return(true);else return(false);

//not enough money message to continue the martingale
if(TK<0){if (GetLastError()==134){err=1;Print("NOT ENOGUGHT MONEY!!");}return (-1);}}