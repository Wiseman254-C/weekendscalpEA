//+------------------------------------------------------------------+
//|                  weekendscalp.mq5 - BTCUSD Weekend Scalper       |
//+------------------------------------------------------------------+
#property copyright "2025"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//--- inputs
input double   RiskPercent     = 1.0;     // Risk % per trade (1% for small accounts)
input int      MagicNumber     = 987654;
input int      MaxSpread_Pips  = 5000;    // BTC spread filter (~50 USD)
input int      Slippage        = 30;
input double   TP_Multiplier   = 2.0;     // TP as ATR multiple (1:2 RR)
input double   SL_Multiplier   = 1.0;     // SL as ATR multiple
input double   Breakeven_Multi = 0.5;     // Move SL to BE after 50% of TP

double PointValue;
int emaFastHandle, emaSlowHandle, rsiHandle, atrHandle, bandsHandle;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   PointValue = SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   emaFastHandle = iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_EMA,PRICE_CLOSE);
   emaSlowHandle = iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_EMA,PRICE_CLOSE);
   rsiHandle     = iRSI(_Symbol,PERIOD_CURRENT,14,PRICE_CLOSE);
   atrHandle     = iATR(_Symbol,PERIOD_CURRENT,20);
   bandsHandle   = iBands(_Symbol,PERIOD_CURRENT,20,0,2.0,PRICE_CLOSE);

   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(Slippage);

   Print("weekendscalp EA loaded successfully on ",_Symbol);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Main tick                                                        |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Bars(_Symbol,PERIOD_CURRENT)<200) return;

   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double spread = (ask-bid)/PointValue;
   if(spread > MaxSpread_Pips) return;

   double emaFastBuf[1];
   if(CopyBuffer(emaFastHandle,0,0,1,emaFastBuf) != 1) return;
   double emaFast = emaFastBuf[0];

   double emaSlowBuf[1];
   if(CopyBuffer(emaSlowHandle,0,0,1,emaSlowBuf) != 1) return;
   double emaSlow = emaSlowBuf[0];

   double rsiBuf[1];
   if(CopyBuffer(rsiHandle,0,0,1,rsiBuf) != 1) return;
   double rsi = rsiBuf[0];

   double atrBuf[1];
   if(CopyBuffer(atrHandle,0,0,1,atrBuf) != 1) return;
   double atr = atrBuf[0];

   double bbLowBuf[1];
   if(CopyBuffer(bandsHandle,2,0,1,bbLowBuf) != 1) return;
   double bbLow = bbLowBuf[0];

   double bbUpBuf[1];
   if(CopyBuffer(bandsHandle,1,0,1,bbUpBuf) != 1) return;
   double bbUp = bbUpBuf[0];

   double closeBuf[1];
   if(CopyClose(_Symbol,PERIOD_CURRENT,0,1,closeBuf) != 1) return;
   double close = closeBuf[0];

   //--- check if we already have a position
   bool hasPos = false;
   ulong posTicket = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      posTicket = PositionGetTicket(i);
      if(posTicket > 0 && PositionGetString(POSITION_SYMBOL)==_Symbol && PositionGetInteger(POSITION_MAGIC)==MagicNumber)
        { hasPos=true; break; }
     }
   if(hasPos) { ManageBreakeven(posTicket); return; }

   double sl = atr * SL_Multiplier;
   double tp = atr * TP_Multiplier;
   double lot = CalculateLot(sl);

   //--- BUY
   if(emaFast > emaSlow && rsi < 30 && close <= bbLow)
     {
      Print(">>> BUY SIGNAL <<<");
      trade.Buy(lot,_Symbol,ask,ask-sl,ask+tp,"Weekend Buy");
     }

   //--- SELL
   if(emaFast < emaSlow && rsi > 70 && close >= bbUp)
     {
      Print(">>> SELL SIGNAL <<<");
      trade.Sell(lot,_Symbol,bid,bid+sl,bid-tp,"Weekend Sell");
     }
  }

//+------------------------------------------------------------------+
//| Breakeven                                                        |
//+------------------------------------------------------------------+
void ManageBreakeven(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket)) return;

   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double sl        = PositionGetDouble(POSITION_SL);
   double tp        = PositionGetDouble(POSITION_TP);

   if(tp==0) return;
   double distance  = MathAbs(tp - openPrice) * Breakeven_Multi;

   double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
     {
      if(Bid - openPrice >= distance && (sl < openPrice || sl==0))
         trade.PositionModify(ticket, openPrice, tp);
     }
   else
     {
      if(openPrice - Ask >= distance && (sl > openPrice || sl==0))
         trade.PositionModify(ticket, openPrice, tp);
     }
  }

//+------------------------------------------------------------------+
//| Lot size                                                         |
//+------------------------------------------------------------------+
double CalculateLot(double slDistance)
  {
   if(slDistance<=0) return(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));

   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent/100.0;
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lot = riskMoney / (slDistance/PointValue * tickValue);

   double minlot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double lotstep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   lot = MathFloor(lot/lotstep)*lotstep;
   lot = MathMax(lot,minlot);
   return(NormalizeDouble(lot,2));
  }

//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(emaFastHandle);
   IndicatorRelease(emaSlowHandle);
   IndicatorRelease(rsiHandle);
   IndicatorRelease(atrHandle);
   IndicatorRelease(bandsHandle);
  }