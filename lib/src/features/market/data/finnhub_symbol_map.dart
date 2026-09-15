/// UI ticker → Finnhub subscribe symbol.
/// Free Finnhub plans 403 NSE / international symbols (`RELIANCE.NS`).
const Map<String, String> kFinnhubSymbols = {
  'RELIANCE': 'RELIANCE.NS',
  'TCS': 'TCS.NS',
  'HDFCBANK': 'HDFCBANK.NS',
  'INFY': 'INFY',
  'ZOMATO': 'ZOMATO.NS',
  'TATAMOTORS': 'TATAMOTORS.NS',
  'ITC': 'ITC.NS',
  'NIFTY 50': '^NSEI',
  'SENSEX': '^BSESN',
};

/// Documented US fallbacks when NSE subscribe/quote fails.
const Map<String, String> kFinnhubFallbackSymbols = {
  'RELIANCE': 'AAPL',
  'TCS': 'MSFT',
  'HDFCBANK': 'JPM',
  'INFY': 'INFY',
  'ZOMATO': 'UBER',
  'TATAMOTORS': 'TM',
  'ITC': 'PM',
  'NIFTY 50': 'SPY',
  'SENSEX': 'DIA',
};

String finnhubSymbolFor(String ticker, {required bool useFallback}) {
  if (useFallback) {
    return kFinnhubFallbackSymbols[ticker] ?? kFinnhubSymbols[ticker] ?? ticker;
  }
  return kFinnhubSymbols[ticker] ?? ticker;
}

String? uiTickerForFinnhub(String symbol, Map<String, String> used) {
  for (final entry in used.entries) {
    if (entry.value == symbol) {
      return entry.key;
    }
  }
  return null;
}
