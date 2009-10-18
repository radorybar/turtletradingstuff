//+------------------------------------------------------------------+
//|                                                  CLEAR_CHART.mq4 |
//|                                            Aleksandr Pak, Almaty |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+
#property show_inputs
/*
If all fields inactive - are hidden by all
If one field = is set even hidden only this type
For example:
*/
extern string  show_on_Partial_name  = "";

extern bool    Vertical_line           = false;
extern bool    Horisontal_line         = false;
extern bool    Trend_line              = false;
extern bool    Trendbyangle_line       = false;
extern bool    Regression_chanel       = false;
extern bool    _chanel                 = false;
extern bool    StdDev_chanel           = false;
extern bool    Gann_line               = false;
extern bool    GannFan                 = false;
extern bool    GannGrid                = false;
extern bool    FIBO                    = false;
extern bool    FIBO_times              = false;
extern bool    FIBO_fan                = false;
extern bool    FIBO_arc                = false;
extern bool    Expansion               = false;
extern bool    FIBO_channel            = false;
extern bool    Restangle               = false;
extern bool    Triangle                = false;
extern bool    Ellipse                 = false;
extern bool    PitchFork               = false;
extern bool    Cycles                  = false;
extern bool    Text                    = false;
extern bool    Arrow                   = false;
extern bool    Label                   = false;

bool u[24];
int init()
{
	u[0]=Vertical_line;
	u[1]=Horisontal_line;
	u[2]=Trend_line;
	u[3]=Trendbyangle_line;
	
	u[4]=Regression_chanel;
	u[5]=_chanel;
	u[6]=StdDev_chanel;
	u[7]=Gann_line;
	
	u[8]=GannFan;
	u[9]=GannGrid;
	u[10]=FIBO;
	u[11]=FIBO_times;
	
	u[12]=FIBO_fan;
	u[13]=FIBO_arc;
	u[14]=Expansion;
	u[15]=FIBO_channel;
	
	u[16]=Restangle;
	u[17]=Triangle;
	u[18]=Ellipse;
	u[19]=PitchFork;
	
	u[20]=Cycles;
	u[21]=Text;
	u[22]=Arrow;
	u[23]=Label; 
}

int start()
{
//----
	string s; 
	int j, k, _type;
	k = ObjectsTotal();
	bool w1 = false;
	for(j = 0; j < 24; j++)
		if(u[j])
			w1 = true;
	if(!w1&&StringLen(show_on_Partial_name) == 0)
		for(int i = k-1; i >= 0; i--) //удаляем все//delte ALL
		{
			s = ObjectName(i);
//			ObjectDelete(s);
         ObjectSet(s, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
		}
		else
		{
			if(StringLen(show_on_Partial_name) != 0) 
				for(i = k-1;i >= 0; i--)//удаляем партию//delete partial 
				{
					s = ObjectName(i);
					if(StringFind(s,show_on_Partial_name,0) >= 0)
//						ObjectDelete(s);
                  ObjectSet(s, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
				}
	
			if(w1)//если хоть один
				for(i = k-1;i >= 0; i--)//удаление по типу//delete by type
				{
					s = ObjectName(i);
					_type = ObjectType(s);
					if(_type >= 0&&_type <= 23)
					{
						for(j = 0; j<24; j++)
						if(u[_type]) 
//						   ObjectDelete(s);
                     ObjectSet(s, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
					}
				}
		}//else
	return(0);
}