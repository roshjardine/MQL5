//+------------------------------------------------------------------+
//|                                         PositionByEquityRisk.mq5 |
//|                                                     Rosh Jardine |
//|                                          https://roshjardine.com |
//+------------------------------------------------------------------+
#property copyright "Rosh Jardine"
#property link      "https://roshjardine.com"
#property version   "1.00"

input double pSLmultiplier = 1.5;
input double pTP1multiplier = 1.5;
input double pRisk = 50;
bool buyonce = false;
#include <Trade\Trade.mqh>
 CTrade              Trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    if (!buyonce)
    {
        Buy();
        buyonce = true;
    }
   
    return;
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+


void Buy()
{

   double Equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double atPrice = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);   
   long   accleverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
   double ContractSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);  
   double SymbolMinLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double SymbolMaxLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double SymbolPoint  = SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double onelotaskvalue  = (ContractSize * 1 * atPrice)/accleverage;
   double minlotaskvalue  = onelotaskvalue*SymbolMinLot;
   double perpointaskvalue = NormalizeDouble((SymbolPoint/Equity)*ContractSize,_Digits);

   
   
   double StopLossDistance = atPrice - iLow(_Symbol,_Period,1);

   double StopLevelPrice = NormalizeDouble(atPrice - pSLmultiplier * StopLossDistance, _Digits);
   
   double TakeProfit1 = NormalizeDouble(atPrice + StopLossDistance * pTP1multiplier, _Digits);
   
   double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);

   double valueToRisk = pRisk / double(100) * Equity;
   double StopLevelValue = NormalizeDouble(StopLevelPrice/SymbolPoint*perpointaskvalue,2);
   if (StopLevelValue>valueToRisk)
   {
    Print("not enough money to cover stop loss, please increase risk exposure");
    return;
   }
   double EquityToTradeOnRisk = valueToRisk-StopLevelValue;
   double tickCount = StopLossDistance  / tickSize;

   double Lots = NormalizeDouble(EquityToTradeOnRisk / onelotaskvalue, 2);
   if (Lots<SymbolMinLot)
   {
    Lots = SymbolMinLot;
   }
   
   if (Lots==SymbolMinLot)
   {
    if (valueToRisk<minlotaskvalue)
    {
        Print("not enough money to buy minimum lot, please increase risk exposure");
        return;
    }
   }

   Print(" ---- BUY ---- ");
   Print("Equity = ", Equity);
   Print("Buy at price = ", atPrice);
   Print("Min lot price = ",DoubleToString(minlotaskvalue,2));
   Print("Stop Loss Distance = ", StopLossDistance);
   Print("Stop Loss price = ", StopLevelPrice);
   Print("Stop Loss value = ", DoubleToString(StopLevelValue,2));
   Print("Equity after stop loss = ",DoubleToString(EquityToTradeOnRisk,2));
   Print("Contract Size = ",DoubleToString(ContractSize,2));
   Print("Take Profit price = ", TakeProfit1);
   Print("Tick Size = ", tickSize);
   Print("Tick Value = ", tickSize);
   Print("Risk = ", pRisk);
   Print("Equity Risk = ", valueToRisk);
   Print("Tick Count = ", tickCount);
   Print("_Digits = ", _Digits);
   Print("_Points = ", _Point);
   Print("Lots = ", Lots);
   
   Trade.Buy(Lots,_Symbol, atPrice, StopLevelPrice, TakeProfit1, "");

}