# Mindorigin Portfolio — Business Requirements Document

**Product:** Mini Investment Portfolio Dashboard with Live WebSocket Data  
**Package:** `com.example.mindorigin`  
**Sources:** Senior Flutter Developer assignment, `.stitch/DESIGN.md`, `.cursor` invariants  
**Architecture:** Feature First + Cubit + imperative `AppRouter`

---

## 1. Vision

Build a single-screen dashboard that keeps state correct while live prices change underneath the user. Ticks must not reset search, sort, scroll, or an in-progress target-alert draft. Only the ticker cell whose price changed may rebuild.

- **App name:** Mindorigin Portfolio
- **Audience:** assignment reviewers and a retail Indian-market user scanning NSE holdings
- **Backend:** none (mock book + Finnhub / simulated feed)
- **Launch:** dashboard is the app. Auth and onboarding are out of product scope.

---

## 2. In scope

- Header: app name, today’s date, live ticker strip, real connection chip, light/dark toggle
- Flavors **dev / qa / prod** that change WebSocket URL, feed type, and reconnect knobs
- Summary cards: invested, current value, P/L (₹ and %), today’s change — computed, never stored
- Filter chips that change which holdings are listed
- Holdings list/table with search, sort, live ticks, selective rebuilds
- 7–10 day performance chart (`fl_chart`) with `1d` `3d` `5d` `7d` `10d` chips and tooltip
- Inline target-price alert (snapshot-and-diff)
- WebSocket resilience: exponential backoff, visible reconnect, snapshot-then-resubscribe
- Phone + tablet via `LayoutBuilder` (tablet ≥ 840)
- README, DevTools rebuild proof, reconnect evidence, Firebase App Distribution notes

## 3. Out of scope

- Buy / Sell / Chart / Stop-loss action tiles from the Stitch HTML
- Real brokerage, orders, or a server for alerts
- Auth, onboarding, session
- Hive, a second HTTP client, a second state-management or routing library
- Committing secrets or a real `FINNHUB_TOKEN`

---

## 4. Functional requirements

### FR-1 Header

- Title exactly **Mindorigin Portfolio**
- Today’s date
- Ticker strip: symbol, last price, change % (yield green up, risk crimson down)
- Connection chip text exactly `Live`, `Reconnecting…`, or `Offline`
- Theme toggle persisted through `StorageService`
- Reuse `AppTopBar`; hide back button on the root dashboard

### FR-2 Summary

- Cards: Total Invested, Current Value, Profit/Loss, Today’s Change
- Indian grouping (`₹14,85,200`)
- Filters: All, Invested (large book), Profit, Loss, Today’s movers
- Metrics derived at read time from holdings + ticks

### FR-3 Holdings

- Columns: Company, Ticker, Quantity, Avg Buy, Current Price (Live), P/L
- Mobile cards; tablet table / split pane
- Search, pinned sort, preserved scroll
- Per-ticker `context.select` + `RepaintBoundary` + `ValueKey(ticker)`

### FR-4 Chart

- Area chart of portfolio value, last 7–10 days
- Chips drive the window; tooltip shows date + value
- Chart cubit does not emit on live ticks

### FR-5 Target alert

- Editable field in the expanded row
- Snapshot on open; save only if the draft differs
- Ticks must not overwrite the draft
- In-memory persistence on `HoldingsRepositoryImpl`

### FR-6 Resilience

- Backoff 1s → 2s → 4s → 8s → 16s, cap 30s, plus jitter
- On reconnect: refetch snapshot, then resubscribe
- Dev: Kill socket action
- Dev/QA simulated feeds still drop and restore

### FR-7 Responsiveness

- Phone stack; tablet ≥ 840 split (summary/chart left, holdings right)
- Existing `ScreenUtilWrapper` 360×690 — do not add a second `ScreenUtilInit`

---

## 5. Derived math (never cached on a cubit)

- invested = qty × avgBuy
- currentValue = qty × livePrice (fallback avgBuy if no tick)
- unrealizedPl = currentValue − invested
- plPercent = invested == 0 ? 0 : pl / invested
- todayChange = qty × (livePrice − previousClose)

---

## 6. Flavors

| Flavor | Feed | Notes |
| ------ | ---- | ----- |
| dev | simulated | Kill socket, rebuild counters, short backoff |
| qa | simulated | Different `WS_URL` and backoff, random drop/restore |
| prod | Finnhub | `wss://ws.finnhub.io`, token via `--dart-define=FINNHUB_TOKEN` |

Same mock Indian book in every flavor. UI stays ₹ / NSE names. Prod maps symbols for Finnhub and falls back to a documented US map if NSE subscribe fails.

---

## 7. Architecture

```text
presentation → domain ← data
```

Features: `portfolio` (book, math, summary, table, alerts, chart) and `market` (feed, ticks, connection).

Cubits: `LivePricesCubit`, `ConnectionCubit`, `HoldingsCubit`, `HoldingsUiCubit`, `TargetAlertEditCubit`, `ThemeCubit`, `ChartCubit`.

---

## 8. Seed book

- RELIANCE — 100 @ ₹1,561.90
- TCS — 40 @ ₹2,660.00
- HDFCBANK — 120 @ ₹1,408.90
- INFY — 80 @ ₹1,319.35
- ZOMATO — 200 @ ₹288.40 (loss row)

---

## 9. Success criteria

- Connection chip reflects real feed state with exact copy
- Summary numbers match a hand calculation from holdings + ticks
- A tick on ticker A does not rebuild ticker B
- Search / sort / scroll / alert draft survive ticks
- Reconnect refetches a snapshot (never silent resume)
- `flutter analyze` and `flutter test` are green
