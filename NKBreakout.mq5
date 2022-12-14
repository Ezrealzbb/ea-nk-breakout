//+------------------------------------------------------------------+
//|                                                   NKBreakout.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Generic/HashMap.h>

#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00";

input int      candleCount = 10;
input int      candlePointRange = 400;

//--- 用于交易的全局变量
CTrade ExtTrade;
//--- 上一条bar的开始时间
datetime lastbar_timeopen;
// 保存区间识别上下文
struct RangeObserver {
   int rangId; // 操作id
   int buyStopOrderId; // 上方突破挂单的 orderId
   int buyPositionId; // 上方突破成功后成交的 positionId
   int sellStopOrderId; // 下方突破挂单的 orderId
   int sellPositionId; // 下方突破成功后成交的 positionId
   int rangeDirection; // 最终识别的区间方向 默认为 0，向上为 1，向下 为 -1
   int virtualOrderCount; // 虚拟开单的数量，当超过后挂真实的订单
}

CHashMap<int/* rangId */, RangeObserver> RangeMaps;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---

//---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
    if (isNewBar()) {
        onNewBar();
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void onNewBar()
{
   
    
}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
//---

}
// 识别区间
int detectRange() {
   MqlRates bars[];
   if (CopyRates(Symbol(), Period(), 0, candleCount, rates) == -1) {
        return 0;
   }
   
   // 取所有 K 线的 (O + H + L + C) / 4 为基准线
   double 
   
   for (int i = 0; i < bars.Size(); i++) {
      if (bars[i] > candlePointRange)
   }
   
   
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//--- 一些常见的工具函数
//+------------------------------------------------------------------+
//|  当新柱形图出现时返回'true'                                         |
//+------------------------------------------------------------------+
bool isNewBar(const bool print_log = true)
{
    static datetime bartime = 0; //存储当前柱形图的开盘时间
//--- 获得零柱的开盘时间
    datetime currbar_time = iTime(_Symbol, _Period, 0);
//--- 如果开盘时间更改，则新柱形图出现
    if(bartime != currbar_time) {
        bartime = currbar_time;
        lastbar_timeopen = bartime;
        //--- 在日志中显示新柱形图开盘时间的数据
        if(print_log && !(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER))) {
            //--- 显示新柱形图开盘时间的信息
            PrintFormat("%s: new bar on %s %s opened at %s", __FUNCTION__, _Symbol,
                        StringSubstr(EnumToString(_Period), 7),
                        TimeToString(TimeCurrent(), TIME_SECONDS));
            //--- 获取关于最后报价的数据
            MqlTick last_tick;
            if(!SymbolInfoTick(Symbol(), last_tick))
                Print("SymbolInfoTick() failed, error = ", GetLastError());
            //--- 显示最后报价的时间，精确至毫秒
            PrintFormat("Last tick was at %s.%03d",
                        TimeToString(last_tick.time, TIME_SECONDS), last_tick.time_msc % 1000);
        }
        //--- 我们有一个新柱形图
        return (true);
    }
//--- 没有新柱形图
    return (false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendOpenOrder(ENUM_ORDER_TYPE signal)
{
// 需要检测当前是否已经有同方向的头寸，如果已经有了，则不需要重新开单
    int total = PositionsTotal();
    for (int i = total - 1; i >= 0; --i) {
        // 获取当前的订单
        //--- 持仓参数
        ulong positionTicket = PositionGetTicket(i);
        string positionSymbol = PositionGetString(POSITION_SYMBOL);
        int positionMagic = PositionGetInteger(POSITION_MAGIC);
        int positionType = PositionGetInteger(POSITION_TYPE);

        if(positionMagic != EXPERT_MAGIC || positionSymbol != Symbol()) {
            continue;
        }

        // 已经存在做多的单，就不需要创建新的订单了
        if (positionType == POSITION_TYPE_BUY && signal == ORDER_TYPE_BUY) {
            return;
        }

        if (positionType == POSITION_TYPE_SELL && signal == ORDER_TYPE_SELL) {
            return;
        }
    }

    openOrder(signal);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool openOrder(ENUM_ORDER_TYPE signal)
{
    int spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    double price = SymbolInfoDouble(_Symbol, signal == ORDER_TYPE_SELL ? SYMBOL_BID : SYMBOL_ASK);
    double symbolPoint = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    double spreadValue = getSymbolSpreadValue();
    double slValue = symbolPoint * slPoint + spreadValue;
    double tpValue = symbolPoint * tpPoint + spreadValue;

    double slPrice = signal == ORDER_TYPE_SELL ? price + slValue : price - slValue;
    double tpPrice = signal == ORDER_TYPE_SELL ? price - tpValue : price + tpValue;
    PrintFormat("%s: openOrder direction %d price %f tp %f sl %f spread %d", __FUNCTION__, signal, price, tpPrice, slPrice, spread);
    return ExtTrade.PositionOpen(Symbol(), signal, preLots,
                                 price,
                                 slPrice, tpPrice);
}

bool openPendingStopOrder(ENUM_ORDER_TYPE orderType, double targetPrice, double lots) {
   
    return ExtTrade.Positio(Symbol(), signal, lots,
                                 targetPrice,
                                 slPrice, tpPrice);
}

double getSlAndTpPrice(ENUM_ORDER_TYPE orderType, double &slPrice, double &tpPrice) {
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSymbolSpreadValue()
{
    int spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    double symbolPoint = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
    return spread * symbolPoint;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSymbolCurrentPrice(int direacton)
{
    double spreadValue = getSymbolSpreadValue();
    double price = SymbolInfoDouble(_Symbol, direacton < 0 ? SYMBOL_BID : SYMBOL_ASK);
    return direacton < 0 ? price + spreadValue : price - spreadValue;
}
//+------------------------------------------------------------------+
bool isUpBar(MqlRates& bar)
{
    return bar.close - bar.open >= 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isDownBar(MqlRates& bar)
{
    return bar.close - bar.open < 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getBarEntityHeight(MqlRates& bar)
{
    return MathAbs(bar.close - bar.open);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getBarTopLineHeight(MqlRates& bar)
{
    return isUpBar(bar) ? MathAbs(bar.high - bar.open) : MathAbs(bar.low - bar.close);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getBarBottomLineHeight(MqlRates& bar)
{
    return isUpBar(bar) ? MathAbs(bar.low - bar.close) : MathAbs(bar.high - bar.open);
}
//+------------------------------------------------------------------+
static int autoCreateRangeId = 1;
int generateNewRangeId() {
   return autoCreateRangeId++;
}