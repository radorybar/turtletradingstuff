//+------------------------------------------------------------------+
//|                                              _MAX_Stops_v1.1.mq4 |
//|                                                 Copyright © 2009 |
//|                                       Written by Massimo Gentili |
//|                                          whitehawk71@hotmail.com |                                      
//|                         Freely inspired from ATR Stops by Agorad |  
//+------------------------------------------------------------------+
#property copyright "Copyright Massimo Gentili © 2009 "

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue           // Support indication -> UP direction
#property indicator_color2 Yellow         // Resist. indication -> DW direction


//---- input parameters
int    LastBarTime;                       
int    BarCount;                          
int    LastDir;                           
int    Delta=3;


extern double OverBoost = 0.0;
extern double Kv=0.25;
extern double Kz=0.15;


double Buffer.Up[];
double Buffer.Dw[];
double smin[];
double smax[];
double trend[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   // Var init
   LastDir = 0;   // Last direction trend 1
   BarCount = 0;
   string short_name;

//---- indicator line

   SetIndexStyle(0,DRAW_ARROW, EMPTY, 2);
   SetIndexArrow(0,159);
   SetIndexStyle(1,DRAW_ARROW, EMPTY, 2);
   SetIndexArrow(1,159);

   
   IndicatorBuffers(5);
   SetIndexBuffer(0,Buffer.Up);
   SetIndexBuffer(1,Buffer.Dw);
   SetIndexBuffer(2,smin);
   SetIndexBuffer(3,smax);
   SetIndexBuffer(4,trend);

//---- name for DataWindow and indicator subwindow label
   short_name="Max_Stops("+Delta+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Support");
   SetIndexLabel(1,"Resistance");
//----
   SetIndexDrawBegin(0,Delta);
   SetIndexDrawBegin(1,Delta);
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| _Max_Stops_v1.1                                                  |
//+------------------------------------------------------------------+
int start()
  {
   
   if ( LastBarTime != Time[0] ) 
   {
      LastBarTime = Time[0];
      BarCount += 1;
   } // else return(0);


   int shift,limit, counted_bars=IndicatorCounted();
   
   if ( counted_bars > 0 )  limit=Bars-counted_bars;
   if ( counted_bars < 0 )  return(0);
   if ( counted_bars ==0 )  limit=Bars-Delta-1; 
     
	for(shift=limit;shift>=0;shift--) 
   {	
     // initialize vectors
        smin[shift] = -999999; smax[shift] = 999999;
     
     // for each element shift I scan for Delta prev number of elements and 
     for (int i = Delta-1;i>=0;i--)
     {
      double body = MathAbs(High[shift]-Low[shift])*Kz;
      smin[shift] = MathMax( smin[shift], Low[shift+i]-Kv/100+body);
      smax[shift] = MathMin( smax[shift], High[shift+i]+Kv/100-body);
     }
	
     // I assume trend equal prev trend direction but ...
     trend[shift]=trend[shift+1];
     if ( Close[shift] > smax[shift+1] ) trend[shift] =  1;
	  if ( Close[shift] < smin[shift+1] ) trend[shift] = -1;


	
  	  if ( trend[shift] >0 ) 
	  {
       if( smin[shift]<smin[shift+1] ) smin[shift]=smin[shift+1];
	    smin[shift] = smin[shift] + OverBoost / 1000;
	    Buffer.Up[shift]=smin[shift];
	    Buffer.Dw[shift] = EMPTY_VALUE;
       if (LastDir != 1) 
       { 
         LastDir = 1;	  
         BarCount = 1;
       }
	  }
	  
	  if ( trend[shift] <0 ) 
	  {
       if( smax[shift]>smax[shift+1] ) smax[shift]=smax[shift+1];
	    smax[shift] = smax[shift] - OverBoost / 1000;
	    Buffer.Up[shift]=EMPTY_VALUE;
	    Buffer.Dw[shift] = smax[shift];
       if (LastDir != 2) 
       { 
         LastDir = 2;	  
         BarCount = 1;
       } 
     }
	
	}
	return(0);	
 }

