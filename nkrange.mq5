//+------------------------------------------------------------------+
//|                                                      nkrange.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot rangeTop
#property indicator_label1  "rangeTop"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMidnightBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot rangeBottom
#property indicator_label2  "rangeBottom"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumOrchid
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int      candleCount = 10;
input int   rangePoint = 600;
//--- indicator buffers
double         rangeTopBuffer[];
double         rangeBottomBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0, rangeTopBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, rangeBottomBuffer, INDICATOR_DATA);

//---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
    if (rates_total < candleCount) return (0);

    for (int i = prev_calculated; i < rates_total; i++) {
        // 计算每一根 K 线的均值
        double avgPrice[];
        int j = 0;
        for (; j < candleCount; j++) {
            avgPrice[j] = (open[j] + high[j] + low[j] + close[j]) / 4;
        }

        // 计算 avgPrice 的均值
        j = 0;
        double centerPrice = 0;
        for (; j < candleCount; j++) {
            centerPrice += avgPrice[j];
        }
        centerPrice /= avgPrice.Size();
        
        double symbolPoint = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
        double rangeHalfSize = rangePoint * symbolPoint / 2;

        rangeTopBuffer[i] = centerPrice + rangeHalfSize;
        rangeBottomBuffer[i] = centerPrice + rangeHalfSize;
    }



//--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+
