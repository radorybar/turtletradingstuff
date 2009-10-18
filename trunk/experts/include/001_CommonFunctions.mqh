//------------------------------------------------------------------
int getHigherTimeframe(int Timeframe)
{
   switch(Timeframe)
   {
      case PERIOD_M1:
         return (PERIOD_M5);
      case PERIOD_M5:
         return (PERIOD_M15);
      case PERIOD_M15:
         return (PERIOD_M30);
      case PERIOD_M30:
         return (PERIOD_H1);
      case PERIOD_H1:
         return (PERIOD_H4);
      case PERIOD_H4:
         return (PERIOD_D1);
      case PERIOD_D1:
         return (PERIOD_W1);
      case PERIOD_W1:
         return (PERIOD_MN1);
   }
   
   return (Timeframe);
}
//------------------------------------------------------------------
int getLowerTimeframe(int Timeframe)
{
   switch(Timeframe)
   {
      case PERIOD_M1:
         return (PERIOD_M1);
      case PERIOD_M5:
         return (PERIOD_M1);
      case PERIOD_M15:
         return (PERIOD_M5);
      case PERIOD_M30:
         return (PERIOD_M15);
      case PERIOD_H1:
         return (PERIOD_M30);
      case PERIOD_H4:
         return (PERIOD_H1);
      case PERIOD_D1:
         return (PERIOD_H4);
      case PERIOD_W1:
         return (PERIOD_D1);
      case PERIOD_MN1:
         return (PERIOD_W1);
   }
   
   return (Timeframe);
}
//------------------------------------------------------------------------------------
// FRACTALS
//------------------------------------------------------------------------------------
bool isFractal(bool UpperLower, int bar)
{
//   iFractals
//   return (getNthFractalTime(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Last fractal value
//------------------------------------------------------------------------------------
datetime getLastFractalTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthFractalTime(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Previous fractal value
//------------------------------------------------------------------------------------
datetime getPreviousFractalTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthFractalTime(_SYMBOL, _TIMEFRAME, UpperLower, 2));
}
//------------------------------------------------------------------------------------
// Last fractal value
//------------------------------------------------------------------------------------
double getLastFractalValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthFractalValue(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Previous fractal value
//------------------------------------------------------------------------------------
double getPreviousFractalValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthFractalValue(_SYMBOL, _TIMEFRAME, UpperLower, 2));
}
//------------------------------------------------------------------------------------
// NthFractal fractal value
//------------------------------------------------------------------------------------
double getNthFractalValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower, int Nth)
{
   double   result      = 0;
   int      i           = 0;
   int      NthFractal  = Nth;     // NthFractal - put here number of fractal into history you want to get a value for
      
   if(UpperLower)
   {
      while(i < 1000 && NthFractal > 0)
      {
         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, i);
         
         i++;
         if(result > 0)
         {
            NthFractal--;
            continue;
         }
      }
   }
   else
   {
      while(i < 1000 && NthFractal > 0)
      {
         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, i);

         i++;
         if(result > 0)
         {
            NthFractal--;
            continue;
         }
      }
   }
   
   return (result);
}
//------------------------------------------------------------------------------------
// NthFractal fractal time
//------------------------------------------------------------------------------------
datetime getNthFractalTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower, int Nth)
{
   datetime result      = 0;
   int      i           = 0;
   int      NthFractal  = Nth;     // NthFractal - put here number of fractal into history you want to get a value for
      
   if(UpperLower)
   {
      while(i < 1000 && NthFractal > 0)
      {
         i++;
         if(iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, i) > 0)
         {
            NthFractal--;
            continue;
         }
      }
      
      return(iTime(_SYMBOL, _TIMEFRAME, i));
   }
   else
   {
      while(i < 1000 && NthFractal > 0)
      {
         i++;
         if(iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, i) > 0)
         {
            NthFractal--;
            continue;
         }
      }

      return(iTime(_SYMBOL, _TIMEFRAME, i));
   }
   
   return (result);
}
//------------------------------------------------------------------------------------
// ZIGZAG
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
// Last ZIGZAG time
//------------------------------------------------------------------------------------
datetime getLastZIGZAGTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthZIGZAGTime(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Previous ZIGZAG time
//------------------------------------------------------------------------------------
datetime getPreviousZIGZAGTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthZIGZAGTime(_SYMBOL, _TIMEFRAME, UpperLower, 2));
}
//------------------------------------------------------------------------------------
// Last ZIGZAG value
//------------------------------------------------------------------------------------
double getLastZIGZAGValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthZIGZAGValue(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Previous ZIGZAG value
//------------------------------------------------------------------------------------
double getPreviousZIGZAGValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthZIGZAGValue(_SYMBOL, _TIMEFRAME, UpperLower, 2));
}
//------------------------------------------------------------------------------------
// Nth ZIGZAG value
//------------------------------------------------------------------------------------
double getNthZIGZAGValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower, int Nth)
{
   double   result      = 0;
   int      i           = 0;
   int      NthZIGZAG   = 2*Nth + 1;
   double   ZIGZAG1     = 0;
   double   ZIGZAG2     = 0;
   
   while(i < 1000 && NthZIGZAG > 0)
   {
      result = iCustom(_SYMBOL, _TIMEFRAME, "ZigZag", 12, 5, 3, 0, i);
                 
      i++;

      if(result > 0)
      {
         ZIGZAG1 = ZIGZAG2;
         ZIGZAG2 = result;
         NthZIGZAG--;
         continue;
      }
   }
   
   if(UpperLower)
   {
      if(ZIGZAG1 > ZIGZAG2)
         result = ZIGZAG1;
      else
         result = ZIGZAG2;
   }
   else
   {
      if(ZIGZAG1 > ZIGZAG2)
         result = ZIGZAG2;
      else
         result = ZIGZAG1;
   }
   
   return (result);
}
//------------------------------------------------------------------------------------
// Nth ZIGZAG time
//------------------------------------------------------------------------------------
datetime getNthZIGZAGTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower, int Nth)
{
   double   result      = 0;
   int      i           = 0;
   int      NthZIGZAG   = 2*Nth + 1;
   double   ZIGZAG1     = 0;
   double   ZIGZAG2     = 0;
   int      ZIGZAG1Time = 0;
   int      ZIGZAG2Time = 0;
   
   while(i < 1000 && NthZIGZAG > 0)
   {
      result = iCustom(_SYMBOL, _TIMEFRAME, "ZigZag", 12, 5, 3, 0, i);
      
      i++;

      if(result > 0)
      {
         ZIGZAG1 = ZIGZAG2;
         ZIGZAG2 = result;
         ZIGZAG1Time = ZIGZAG2Time;
         ZIGZAG2Time = i - 1;
         NthZIGZAG--;
         continue;
      }
   }
   
   if(UpperLower)
   {
      if(ZIGZAG1 > ZIGZAG2)
         result = ZIGZAG1Time;
      else
         result = ZIGZAG2Time;
   }
   else
   {
      if(ZIGZAG1 > ZIGZAG2)
         result = ZIGZAG2Time;
      else
         result = ZIGZAG1Time;
   }
   
   return(iTime(_SYMBOL, _TIMEFRAME, result));
}
//------------------------------------------------------------------

