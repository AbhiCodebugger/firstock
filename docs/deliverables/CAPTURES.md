# Assignment captures

Record these locally before submission. Do not commit secrets.

## DevTools rebuilds (Requirement 3)

1. `flutter run -t lib/main_dev.dart`
2. Open Flutter DevTools → **Track Widget Rebuilds**
3. Watch the holdings list while ticks arrive
4. Only `HoldingPriceCell` / `TickerChip` for the changed symbol should flash
5. Save a screenshot as `docs/deliverables/devtools-rebuilds.png`

## Disconnect / reconnect

1. On **dev**, tap **Kill socket**
2. Confirm chip text is exactly `Reconnecting…`, then `Live`
3. Search text, sort, and scroll position must stay put
4. Save a screen recording as `docs/deliverables/reconnect.gif`

## Chart tooltip

Hover or drag the performance chart. Capture the date + value tooltip as `docs/deliverables/chart-tooltip.png`.

## Firebase App Distribution

```bash
flutter build apk -t lib/main_prod.dart --dart-define=FINNHUB_TOKEN=...
```

Upload the APK in Firebase App Distribution. Keep `google-services.json` out of git if it contains a real project secret.
