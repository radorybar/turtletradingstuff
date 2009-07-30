//+------------------------------------------------------------------+
//This is onother ZigZac indicator
//ZigZac is calculated by price move
//Moves that are grater then given MinMove treshold are considered as Swing points
//Smaller retracement are ignored
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, scalony. Marek Marciniak"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_buffers 1
#property indicator_color1 Blue

#define UP      1
#define DOWN   -1
extern double MinMove=1;  //percentage of instrument value change to be considered as swing point


double SwingZZ[];
double MinMax[];   //1 maximum, -1 minimum
int Extremes;      //number of extremes

int init()
  {
//---- indicators
//----
   IndicatorBuffers(2);
   SetIndexBuffer(0,SwingZZ);
   SetIndexBuffer(1,MinMax);
   
   
   Extremes = 0;
   
   SetIndexEmptyValue(0,0);
   for(int i=0;i<Bars;i++){
     SwingZZ[i]=0;
     MinMax[i]=0;
   }  
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexLabel(0,"mmSwingZZ("+DoubleToStr(MinMove,1)+"%)");
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
   int i,limit,dir;
   int counted_bars=IndicatorCounted();
   int ExtremePos;
   double ZZExtreme, Curr;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- 10 last counted bar will be recounted
   if(counted_bars>10) 
     counted_bars = counted_bars-10;
   limit=Bars-counted_bars;

   //searches form last extrem and find where it is maximum or minimum
   if(Extremes==0) {
     ZZExtreme=High[limit];
     dir = UP;
     ExtremePos=limit;
   } else {
     for(i=limit+1; SwingZZ[i]!=0; i++)
       if (i>Bars) return(-1);
     ExtremePos=i;
     ZZExtreme = SwingZZ[i];
     dir = -MinMax[i];
   }
   for(i=limit; i>0; i--){
     if(dir==UP) 
       Curr = Low[i];
     else         
       Curr = High[i];
     //if current value greater then last extreme point then new extreme point is found
     if(dir==UP)
       if(High[i]>ZZExtreme){
         ZZExtreme = High[i];
         ExtremePos=i;       
       }  
     if(dir==DOWN)
       if(Low[i]<ZZExtreme){
         ZZExtreme = Low[i];
         ExtremePos=i;       
       }  
     //check retracement value if it is greater than gibern treshold in exteranal parametre
     //then mark extereme as swing point
     if((ZZExtreme-Curr)*dir > ZZExtreme*MinMove/100){
       SwingZZ[ExtremePos] = ZZExtreme;
       MinMax[ExtremePos] = dir;
       dir = -dir;
         
     }  
   }  
   

   return(0);
  }

