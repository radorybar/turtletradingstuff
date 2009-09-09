//+------------------------------------------------------------------+
//|                                                       Zigzag.mq4 |
//|                 Copyright © 2005-2007, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Black
#property indicator_color4 Blue
#property indicator_color5 Red
//---- indicator parameters
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;

extern int NTH.ZIGZAG = 1;
extern int INDICATOR_SYMBOL = 159;

//---- indicator buffers
double ZigzagBuffer[];
double HighMapBuffer[];
double LowMapBuffer[];
double HighMapBufferBreakout[];
double LowMapBufferBreakout[];
int level=3; // recounting's depth 
bool downloadhistory=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(5);
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);

   SetIndexStyle(3,DRAW_ARROW, EMPTY, 0);
   SetIndexArrow(3,INDICATOR_SYMBOL);

   SetIndexStyle(4,DRAW_ARROW, EMPTY, 0);
   SetIndexArrow(4,INDICATOR_SYMBOL);

//---- indicator buffers mapping
   SetIndexBuffer(0,ZigzagBuffer);
   SetIndexBuffer(1,HighMapBuffer);
   SetIndexBuffer(2,LowMapBuffer);
   SetIndexBuffer(3,HighMapBufferBreakout);
   SetIndexBuffer(4,LowMapBufferBreakout);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);

//---- indicator short name
   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars = IndicatorCounted();
   int limit,counterZ,whatlookfor;
   int shift,back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   if (counted_bars==0 && downloadhistory) // history was downloaded
     {
      ArrayInitialize(ZigzagBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
     }
   if (counted_bars==0) 
     {
      limit=Bars-ExtDepth;
      downloadhistory=true;
     }
   if (counted_bars>0) 
     {
      while (counterZ<level && i<100)
        {
         res=ZigzagBuffer[i];
         if (res!=0) counterZ++;
         i++;
        }
      i--;
      limit=i;
      if (LowMapBuffer[i]!=0) 
        {
         curlow=LowMapBuffer[i];
         whatlookfor=1;
        }
      else
        {
         curhigh=HighMapBuffer[i];
         whatlookfor=-1;
        }
      for (i=limit-1;i>=0;i--)  
        {
         ZigzagBuffer[i]=0.0;  
         LowMapBuffer[i]=0.0;
         HighMapBuffer[i]=0.0;
        }
     }
      
   for(shift=limit; shift>=0; shift--)
     {
      val=Low[iLowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=LowMapBuffer[shift+back];
               if((res!=0)&&(res>val)) LowMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      if (Low[shift]==val) LowMapBuffer[shift]=val; else LowMapBuffer[shift]=0.0;
      //--- high
      val=High[iHighest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=HighMapBuffer[shift+back];
               if((res!=0)&&(res<val)) HighMapBuffer[shift+back]=0.0; 
              } 
           }
        }
      if (High[shift]==val) HighMapBuffer[shift]=val; else HighMapBuffer[shift]=0.0;
     }

   // final cutting 
   if (whatlookfor==0)
     {
      lastlow=0;
      lasthigh=0;  
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
   for (shift=limit;shift>=0;shift--)
     {
      res=0.0;
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if (lastlow==0 && lasthigh==0)
              {
               if (HighMapBuffer[shift]!=0)
                 {
                  lasthigh=High[shift];
                  lasthighpos=shift;
                  whatlookfor=-1;
                  ZigzagBuffer[shift]=lasthigh;
                  res=1;
                 }
               if (LowMapBuffer[shift]!=0)
                 {
                  lastlow=Low[shift];
                  lastlowpos=shift;
                  whatlookfor=1;
                  ZigzagBuffer[shift]=lastlow;
                  res=1;
                 }
              }
             break;  
         case 1: // look for peak
            if (LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && HighMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=shift;
               lastlow=LowMapBuffer[shift];
               ZigzagBuffer[shift]=lastlow;
               res=1;
              }
            if (HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
              {
               lasthigh=HighMapBuffer[shift];
               lasthighpos=shift;
               ZigzagBuffer[shift]=lasthigh;
               whatlookfor=-1;
               res=1;
              }   
            break;               
         case -1: // look for lawn
            if (HighMapBuffer[shift]!=0.0 && HighMapBuffer[shift]>lasthigh && LowMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=shift;
               lasthigh=HighMapBuffer[shift];
               ZigzagBuffer[shift]=lasthigh;
              }
            if (LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
              {
               lastlow=LowMapBuffer[shift];
               lastlowpos=shift;
               ZigzagBuffer[shift]=lastlow;
               whatlookfor=1;
              }   
            break;               
         default: return; 
        }
     }

//array of ZIGZAG points in form: Value,position, where 
//zigzaghigh[0][0] ... first high ZIGZAG value backwards
//zigzaghigh[0][1] ... first high ZIGZAG position backwards
//zigzaghigh[0][2] ... increase/decrease coefficient
   double zigzaghigh[4][3] = {0,1000,0,  0,1000,0,  0,1000,0,  0,1000,0}, zigzaglow[4][3] = {0,1000,0,  0,1000,0,  0,1000,0,  0,1000,0};

   for (shift=1000;shift>=0;shift--)
   {
      if (LowMapBuffer[shift] > 0.0 && ZigzagBuffer[shift] > 0.0)
//      if (LowMapBuffer[shift] > 0.0)
      {
         int lastlowposition = zigzaglow[0][1];
         if (ZigzagBuffer[lastlowposition] > 0.0)
         {
            zigzaglow[3][0] = zigzaglow[2][0];
            zigzaglow[3][1] = zigzaglow[2][1];
            zigzaglow[2][0] = zigzaglow[1][0];
            zigzaglow[2][1] = zigzaglow[1][1];
            zigzaglow[1][0] = zigzaglow[0][0];
            zigzaglow[1][1] = zigzaglow[0][1];
         }
         zigzaglow[0][0] = LowMapBuffer[shift];
         zigzaglow[0][1] = shift;
      }
      
      if (HighMapBuffer[shift]>0.0 && ZigzagBuffer[shift] > 0.0)
//      if (HighMapBuffer[shift]>0.0)
      {
         int lasthighposition = zigzaghigh[0][1];
         if (ZigzagBuffer[lasthighposition] > 0.0)
         {
               zigzaghigh[3][0] = zigzaghigh[2][0];
               zigzaghigh[3][1] = zigzaghigh[2][1];
               zigzaghigh[2][0] = zigzaghigh[1][0];
               zigzaghigh[2][1] = zigzaghigh[1][1];
               zigzaghigh[1][0] = zigzaghigh[0][0];
               zigzaghigh[1][1] = zigzaghigh[0][1];
         }
         zigzaghigh[0][0] = HighMapBuffer[shift];
         zigzaghigh[0][1] = shift;
      }
      
      if(zigzaglow[3][0]>0 && zigzaghigh[3][0]>0)
      {
         zigzaglow[1][2] = (zigzaglow[0][0] - zigzaglow[1][0])/(zigzaglow[1][1] - zigzaglow[0][1]);
         zigzaglow[2][2] = (zigzaglow[0][0] - zigzaglow[2][0])/(zigzaglow[2][1] - zigzaglow[0][1]);
         zigzaglow[3][2] = (zigzaglow[0][0] - zigzaglow[3][0])/(zigzaglow[3][1] - zigzaglow[0][1]);
         zigzaghigh[1][2] = (zigzaghigh[0][0] - zigzaghigh[1][0])/(zigzaghigh[1][1] - zigzaghigh[0][1]);
         zigzaghigh[2][2] = (zigzaghigh[0][0] - zigzaghigh[2][0])/(zigzaghigh[2][1] - zigzaghigh[0][1]);
         zigzaghigh[3][2] = (zigzaghigh[0][0] - zigzaghigh[3][0])/(zigzaghigh[3][1] - zigzaghigh[0][1]);

         LowMapBufferBreakout[shift] = zigzaglow[NTH.ZIGZAG][0] + zigzaglow[NTH.ZIGZAG][2]*(zigzaglow[NTH.ZIGZAG][1] - shift);      
         HighMapBufferBreakout[shift] = zigzaghigh[NTH.ZIGZAG][0] + zigzaghigh[NTH.ZIGZAG][2]*(zigzaghigh[NTH.ZIGZAG][1] - shift);
      }
            
/*
      if(Low[shift] > lastlowzigzag + lastincrease*(lastlowposition - shift))
         LowMapBufferBreakout[shift] = lastlowzigzag + lastincrease*(lastlowposition - shift);      
      else
         LowMapBufferBreakout[shift] = 0;
      if(High[shift] < lasthighzigzag - lastdecrease*(lasthighposition - shift))
         HighMapBufferBreakout[shift] = lasthighzigzag - lastdecrease*(lasthighposition - shift);            
      else
         HighMapBufferBreakout[shift] = 0;
*/
/*
      if(Low[shift] < lastlowzigzag + lastincrease*(lastlowposition - shift))
         LowMapBufferBreakout[shift] = lastlowzigzag + lastincrease*(lastlowposition - shift);      
      else
         LowMapBufferBreakout[shift] = 0;
      if(High[shift] > lasthighzigzag - lastdecrease*(lasthighposition - shift))
         HighMapBufferBreakout[shift] = lasthighzigzag - lastdecrease*(lasthighposition - shift);            
      else
         HighMapBufferBreakout[shift] = 0;
*/

         
/*
      Print(previouslowzigzag);
      Print(lastincrease);
      Print(previouslowposition);
      Print(previoushighzigzag);
      Print(lastdecrease);
      Print(previoushighposition);
      Print(shift);
*/
   }
   
   return(0);
  }
//+------------------------------------------------------------------+