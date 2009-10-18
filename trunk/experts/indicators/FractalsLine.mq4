//+------------------------------------------------------------------+
//|                                                 FractalsLine.mq4 |
//|                               Copyright © 2006, Виктор Чеботарёв |
//|                                      http://www.chebotariov.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Виктор Чеботарёв"
#property link      "http://www.chebotariov.com/"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, ExtMapBuffer2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
//----
   int i=Bars-counted_bars-1;
   while(i >= 0)
     {
       double upfrac_val = iFractals(NULL, 0, MODE_UPPER, i + 1);
       double lofrac_val = iFractals(NULL, 0, MODE_LOWER, i + 1);
       if(upfrac_val > 0)
           GlobalVariableSet(Symbol() + Period() + "upfrac", upfrac_val);
       else 
           if(lofrac_val > 0)
               GlobalVariableSet(Symbol() + Period() + "lofrac", lofrac_val);
       ExtMapBuffer1[i] = GlobalVariableGet(Symbol() + Period() + "upfrac");
       ExtMapBuffer2[i] = GlobalVariableGet(Symbol() + Period() + "lofrac");
       i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+