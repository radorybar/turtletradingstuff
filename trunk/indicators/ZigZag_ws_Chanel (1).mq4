//+------------------------------------------------------------------+
//|                                             Zigzag_ws_Chanel.mq4 |
//|          Copyright � 2008, Dolsergon & MetaQuotes Software Corp. |
//|                                      http://tradecoder.narod.ru/ |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2008, Dolsergon & MetaQuotes Software Corp."
#property link      "http://tradecoder.narod.ru/; http://www.metaquotes.net/"

/* HISTORY
fbj.1/05aug2009   1st poke at H,L lines by only setting L,R line values outside main loop just b4 start() exit.
                  2nd mode [I'd think] is not using or ingnoring BufChanel[High|Low][] altogether
                  cuz want ObjectCreate("..",OBJ_TREND,... using the obtained L,R line values.
                  NOTE:must extend right beyond R line val, ObjectSet("..",OBJPROP_RAY,true) should do it.
                  Why? if manually draw trendLine on chart and tick it's "Ray" attrib, it extends rightwards.
                  Cons: the rightwards is to infinity and beyond! but that is cosmetic fix at this stage, yes?
                  Search on: fbj.1/05aug2009 for all mods made. 
*/




#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_color2 Pink
#property indicator_color3 Pink
//---- indicator parameters
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
//---- indicator buffers
double ZigzagBuffer[];
double HighMapBuffer[];
double LowMapBuffer[];
double BufChanelHigh[];
double BufChanelLow[];
int level=3; // recounting's depth 
bool downloadhistory=false;


int giHleft = EMPTY, giHright = EMPTY;        //fbj.1/05aug2009
int giLleft = EMPTY, giLright = EMPTY;        //fbj.1/05aug2009


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(5);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ZigzagBuffer);
   SetIndexEmptyValue(0,0.0);
   
   SetIndexStyle(1, DRAW_SECTION);
   SetIndexBuffer(1,BufChanelHigh);
   SetIndexEmptyValue(1,0.0);

   SetIndexStyle(2, DRAW_SECTION);
   SetIndexBuffer(2,BufChanelLow);
   SetIndexEmptyValue(2,0.0);
   
   SetIndexBuffer(3,HighMapBuffer);
   SetIndexBuffer(4,LowMapBuffer);

//---- indicator short name
   IndicatorShortName("ZigZag_ws_Chanel("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
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
      ArrayInitialize(BufChanelHigh,0.0);
      ArrayInitialize(BufChanelLow,0.0);
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
         
         BufChanelHigh[i]=0.0;
         BufChanelLow[i]=0.0;
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
                  SetHighZZ(shift, lasthigh);
                  res=1;
                 }
               if (LowMapBuffer[shift]!=0)
                 {
                  lastlow=Low[shift];
                  lastlowpos=shift;
                  whatlookfor=1;
                  SetLowZZ(shift, lastlow);
                  res=1;
                 }
              }
             break;  
         case 1: // look for peak
            if (LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && HighMapBuffer[shift]==0.0)
              {
               SetLowZZ(lastlowpos, 0.0);
               lastlowpos=shift;
               lastlow=LowMapBuffer[shift];
               SetLowZZ(shift, lastlow);
               res=1;
              }
            if (HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
              {
               lasthigh=HighMapBuffer[shift];
               lasthighpos=shift;
               SetHighZZ(shift, lasthigh);
               whatlookfor=-1;
               res=1;
              }   
            break;               
         case -1: // look for lawn
            if (HighMapBuffer[shift]!=0.0 && HighMapBuffer[shift]>lasthigh && LowMapBuffer[shift]==0.0)
              {
               SetHighZZ(lasthighpos, 0.0);
               lasthighpos=shift;
               lasthigh=HighMapBuffer[shift];
               SetHighZZ(shift, lasthigh);
              }
            if (LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
              {
               lastlow=LowMapBuffer[shift];
               lastlowpos=shift;
               SetLowZZ(shift, lastlow);
               whatlookfor=1;
              }   
            break;               
         default: return; 
        }
     }

//++fbj.1/05aug2009
static bool sbDoPrint=true;
BufChanelHigh[giHleft] = High[giHleft];
BufChanelHigh[giHright] = High[giHright];
BufChanelLow[giLleft] = Low[giLleft];
BufChanelLow[giLright] = Low[giLright];
if(sbDoPrint)
{
  sbDoPrint=false;
  Print("LEFT/BufChanelHigh[",giHleft,"]=",dPrint(BufChanelHigh[giHleft])
       ,", RIGHT/BufChanelHigh[",giHright,"]=",dPrint(BufChanelHigh[giHright])
       ,", LEFT/BufChanelLow[",giLleft,"]=",dPrint(BufChanelLow[giLleft])
       ,", RIGHT/BufChanelLow[",giLright,"]=",dPrint(BufChanelLow[giLright]));
}
//--fbj.1/05aug2009

   return(0);
  }


string dPrint (double d){return(DoubleToStr(d,Digits));}  //finger saver!                              //fbj.1/05aug2009



//=================================================================================================
void SetLowZZ(int pShift, double pValue) {
	ZigzagBuffer[pShift]=pValue;
//	BufChanelLow[pShift]=pValue;                              //fbj.1/05aug2009
if(giLright!=EMPTY) giLleft = giLright;   //commented out above line. load L,R vals just b4 start() return(0)   //fbj.1/05aug2009
giLright = pShift;                                            //fbj.1/05aug2009
}
//=================================================================================================
void SetHighZZ(int pShift, double pValue) {
	ZigzagBuffer[pShift]=pValue;
//	BufChanelHigh[pShift]=pValue;                              //fbj.1/05aug2009
if(giHright!=EMPTY) giHleft = giHright;   //commented out above line. load L,R vals just b4 start() return(0)   //fbj.1/05aug2009
giHright = pShift;                                             //fbj.1/05aug2009
}



