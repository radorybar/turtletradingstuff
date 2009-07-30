
//+------------------------------------------------------------------+
//This indicator calculates probability of trend change both
//in time and in value.
//This indicator bases on swing points from ZigZag indicator
//It calcluates percentile of current move value to N previous 
//moves ranges. Where N is given in parameter PerPeriod.
//It bases on my ZigZag indicator mmSwingZZ however it easily can be 
//adapted to other zigzag Indicators
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, scalony. Marek Marciniak"
#property indicator_separate_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int PerPeriod=55;
extern int LimitDraw=10000;
extern double MinMove=1;
extern int SeparateUpsDowns = 1;


double ZZ[];
double Periods[];
double Ranges[];
double TimePerc[];
double RangePerc[];
double tmptimearray[];
double tmprangearray[];

int FRACUP   =1;
int FRACNONE =0;
int FRACDOWN =-1;
int MAXINT=0x7FFFFFF;
int MININT=-0x7FFFFFF;
int DEBUG=0;
int DEBUGLIM=100;

int init()
  {
//---- indicators
//----
   IndicatorBuffers(8);
   SetIndexBuffer(0,TimePerc);
   SetIndexBuffer(1,RangePerc);
   SetIndexBuffer(2,Periods);
   SetIndexBuffer(3,ZZ);
   SetIndexBuffer(4,Ranges);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   
   SetLevelValue(0,25);
   SetLevelValue(1,50);
   SetLevelValue(2,75);
   SetLevelValue(3,87.5);
   SetLevelValue(4,100);


   ArrayResize(tmptimearray,PerPeriod);
   ArrayResize(tmprangearray,PerPeriod);
   
   SetIndexLabel(0, "TimePerc");
   SetIndexLabel(1, "RangePerc");
   
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,j,k,f,limit;
   int counted_bars=IndicatorCounted();
   double TC,TP,VC,VP,diff,mindiff;
   int Empty=20000000;
   int firstZZ,mindiffpos,watchdog;
   int tp;

//   double percentylL, percentylH;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if (limit>LimitDraw)
     limit = LimitDraw;


   firstZZ = -1;
   for(i=0; i<limit+1500; i++){
     ZZ[i]=iCustom(NULL,0,"mmSwingZZ",MinMove,0,i);
     if(ZZ[i]!=0 && i==0){
       ZZ[i]=0;
     }
     if(ZZ[i]!= 0 && firstZZ == -1) {
       firstZZ = i;
     }  
   }
   
   
   //Calculate ranges and length of moves
   TP=firstZZ;
   VP=ZZ[firstZZ];
   k=0;

   for(i=0;i<limit+1500;i++){
     Ranges[i] = EMPTY_VALUE;
     Periods[i] = EMPTY_VALUE;
   }

   
   for(i=firstZZ+1;i<limit+1500;i++){
     if(ZZ[i]!=0){
       TC = i;
       VC = ZZ[i];
       tp = TP;
       if(SeparateUpsDowns==1)
         Periods[tp] = TC-TP;
       else  
         Periods[tp] = MathAbs(TC-TP);
       Ranges [tp] = MathAbs(VC-VP);
       TP=TC;
       VP=VC;
     }   
   }     
   
   //Calculate current indicator value and compare to percentile table to estimate percentile value
   for(i=0;i<limit;i++){
     k=0;
     TP=EMPTY_VALUE;
     watchdog=5000;
     
     for(j=0;k<PerPeriod;j++){
       if(Periods[i+j] != EMPTY_VALUE){
         tmptimearray[k]  = Periods[i+j];
         tmprangearray[k] = Ranges[i+j];
         k++;
         if(TP==EMPTY_VALUE)
           TP=i+j;
         if(watchdog==0){
           Print("Watchdog hit!!!");
           return(-1);
         }  
         watchdog--;
       }  
     }
     ArraySort(tmptimearray);
     ArraySort(tmprangearray);
     tp = TP;
     VP = ZZ[tp];
     TC = i;
     if(High[i]>VP)
       VC=High[i];
     else
       VC=Low[i];  
       
     //find closest percentile in time domain
     mindiff = MAXINT;
     for(j=0;j<PerPeriod;j++){
       diff = MathAbs((TP - TC) - tmptimearray[j] );

       if(diff<mindiff){
         mindiffpos = j;
         mindiff = diff;
       }
     }
     TimePerc[i] = 100.0*mindiffpos/(PerPeriod-1.0);
     //find closest percentile in range domain
     mindiff = MAXINT;
     for(j=0;j<PerPeriod;j++){
       diff = MathAbs(MathAbs(VP - VC) - tmprangearray[j] );
       if(diff<mindiff){
         mindiffpos = j;
         mindiff = diff;
       }
     }
     RangePerc[i] = 100.0*mindiffpos/(PerPeriod-1.0);
   }

   return(0);
  }

