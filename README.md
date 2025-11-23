# weekendscalpEA
WeekendScalpEA is a fast MT5 scalping bot designed for weekend price gaps and micro-moves. It opens trades on momentum signals, targets quick profits, limits losses, and is ideal for small accounts. Demo test recommended; high-risk, educational purposes only.
# WeekendScalpEA — Fast MT5 Scalping Bot

**WeekendScalpEA** is a lightweight Expert Advisor (EA) designed for **fast scalping on weekend gaps and micro-volatility**. It targets small quick profits, closes losing trades promptly, and is ideal for small accounts.

---

## Features
- Detects sharp momentum candles and weekend gaps  
- Opens BUY/SELL trades instantly on signals  
- Designed for **M1–M5 timeframes**  
- Automatic lot sizing for small accounts  
- Spread and slippage protection  
- Clean and easy-to-read code for modification  

---

## Installation
1. Open **MetaTrader 5**  
2. Open **MetaEditor** (`F4`)  
3. Create a new EA or open an existing file  
4. Paste the `WeekendScalpEA.mq5` code  
5. Save and **Compile** (`F7`)  
6. Open MT5 → **Navigator → Expert Advisors**  
7. Drag `WeekendScalpEA` onto the chart  

---

## Usage
- Attach the EA to **M1 or M5 charts**  
- Recommended for **demo accounts** before live trading  
- Adjust input parameters according to your risk tolerance:  
  - `FixedLot` – manual lot size  
  - `UseRisk` – enable automatic lot sizing based on account balance  
  - `SL_pips` & `TP_pips` – stop loss and take profit  
  - `TrailingStart` & `TrailingStep` – trailing stop settings  
  - `MaxSpread` – maximum spread to allow trades  

---

## Input Parameters
| Parameter          | Description |
|-------------------|-------------|
| FastEMA            | Fast EMA period for trend detection |
| SlowEMA            | Slow EMA period for trend detection |
| RSIperiod          | RSI period for overbought/oversold detection |
| RSIoversold        | RSI threshold for oversold condition |
| RSIoverbought      | RSI threshold for overbought condition |
| FixedLot           | Fixed lot size if `UseRisk` = false |
| UseRisk            | Enable automatic lot sizing based on account balance |
| RiskPercent        | Percent of balance to risk per trade |
| SL_pips            | Stop loss in pips |
| TP_pips            | Take profit in pips |
| TrailingStart      | Pips profit before trailing stop activates |
| TrailingStep       | Trailing stop step in pips |
| MaxSpread          | Maximum spread allowed for trading |
| MagicNumber        | Unique identifier for trades |
| MaxTrades          | Maximum simultaneous trades |
| TradingStartHour   | Start of trading hours (24h format) |
| TradingEndHour     | End of trading hours (24h format) |
| SignalTF           | Timeframe for indicator signals |

---

## Important Notes
- **Not guaranteed profitable**; use on demo accounts first  
- High-risk trading, especially during weekend gaps  
- Optimized for **weekend volatility** but can be adapted for any timeframe  
- Modify parameters to suit your broker and trading style  

---

## Disclaimer
Trading Forex involves significant risk.  
**WeekendScalpEA** is provided for **educational purposes only**. Use at your own risk.

---

## License
MIT License – you can use, modify, or share this code freely.
