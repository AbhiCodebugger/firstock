# Design system — mindorigin

Consult this file before changing UI. Source spec: [`.stitch/DESIGN.md`](.stitch/DESIGN.md). If Stitch and this file disagree, follow **this file** — the shipped app uses tablet breakpoint **840**, connection copy `Live` / `Reconnecting…` / `Offline`, and Material 3 `ColorScheme` + `AppColorsExtension`.

---

## Theme overview

- **Atmosphere:** Institutional, dark-first Indian-market terminal. Deep navy canvas, stacked slate surfaces, razor-thin borders. Decorative chrome stays out of the way so live ticks, P/L, and the trajectory chart read as a trading desk — not a consumer wallet.
- **Material 3:** Chrome lives in `lib/src/theme/theme.dart` (`buildLightTheme` / `buildDarkTheme`).
- **Dark mode:** `ThemeCubit` defaults to **dark** and persists the user toggle. Light inversion is supported. Use semantic roles — do not branch on `Brightness` for basic surfaces.
- Do **not** hardcode hex in widgets. Add a token on `StitchColors` / `AppColorsExtension` / `ColorScheme` first.

Import tokens from `package:mindorigin/src/theme/theme_constants.dart`.

---

## Color system

Definitions: `lib/src/theme/color_schemes.dart`. Access: `context.colors` (Material `ColorScheme`) and `context.appColors` (`AppColorsExtension`).

| Role | Dark | Light |
| ---- | ---- | ----- |
| Canvas / surface | `#051424` navy | `#F8FAFC` |
| Yield / primary | `#4EDEA3` (`#10B981` container, on-yield `#003824`) | `#059669` |
| Loss / risk | `#F43F5E` (soft secondary `#FFB2B7`) | `#E11D48` |
| Market blue / tertiary | `#7BD0FF` | `#0369A1` |
| On-surface | `#D4E4FA` | `#0F172A` |
| On-surface variant | `#BBCABF` | `#475569` |
| Outline | `#86948A` | `#94A3B8` |

Dark surface ladder (lowest → highest): `#010F1F` → `#0D1C2D` → `#122131` → `#1C2B3C` → `#273647`.

Light cards sit on white / `#F1F5F9`. Deeper gain and loss keep contrast in light mode.

- Gains, live pulse, selected chips, chart stroke → `context.appColors.yield` / `ColorScheme.primary`
- Losses, offline, negative deltas → `context.appColors.loss`
- Alert badges, scrubbers, informational accents → tertiary / market blue
- Secondary copy → `onSurfaceVariant`
- Borders → `outline` / `outlineVariant` — not label color
- `buildTextTheme` paints `ColorScheme.onSurface` so Google Fonts do not keep light-theme ink in dark mode

---

## Typography

File: `lib/src/theme/text_theme.dart`. Access: `context.textTheme`.

- **Plus Jakarta Sans** — titles and section headlines. Tight tracking, weights 600–700.
- **Inter** — body, chips, every rupee or percent.
- Tabular figures (`tnum`) on LTP, P/L, invested, and percentages via `tabularFigures(...)`.
- Metric card labels: 11–12px, uppercase, wide tracking (`labelSmall` / `labelMedium`).
- Money: Indian grouping (`14,85,200`) through `formatInr` / `formatIndianNumber` in `lib/src/core/money/inr_format.dart`. Prefix `₹`. Signed P/L uses yield / loss color.

Do not let Google Fonts default ink leak into dark mode. Always go through `buildTextTheme(onSurface: …)` / `withOnSurfaceInk`.

---

## Spacing, borders, motion

| Token class | Purpose |
|-------------|---------|
| `AppSpacing` | Padding and gaps (`xxs` … `xxxl`, plus `pagePadding`, `itemGap`, `cardPadding`). Values go through ScreenUtil `.r`. |
| `AppBorders` | Radii. Cards / drawers: `AppBorders.md` (12). Buttons / compact chrome: `AppBorders.sm` (8). Pills: `AppBorders.full`. Prefer these over `BorderRadius.circular(n)`. |
| Surfaces | Prefer the surface ladder over drop shadows. Depth is 1px edges (`outline` / `outlineVariant`), not elevation. |
| `AppDurations` | `priceFlash` is **320ms** (assignment window 260–400ms), plus existing motion tokens. |
| `AppCurves` | Standard curves. |

Stitch cards are 12px and buttons are 8px. Use `AppBorders.md` / `AppBorders.sm`. Do not invent a new radius in a widget.

Page margin is 16 (`AppSpacing.md` / `pagePadding`). List density is tight (`AppSpacing.sm` gaps). KPI cards use roomier 16.

---

## Responsive

- `ScreenUtilInit` is already in `ScreenUtilWrapper` (design size **360×690**). Do not add another.
- Phone + tablet via `LayoutBuilder`. Tablet ≥ **`kTabletBreakpoint` (840)** in `lib/src/core/layout/breakpoints.dart`.
- Stitch’s “≥ 600” is the mock. The shipped breakpoint is **840**. Do not change it to 600 without an explicit request.

**Phone:** stacked header → ticker tape → 2×2 summary cards → filter chips → trajectory chart → holdings **cards**.

**Tablet:** summary + filters + chart on the left; holdings **table** on the right.

Holdings must clear the system nav bar and sit above the keyboard. `DashboardPage` owns that inset.

---

## Screens and chrome

Single assignment screen: `DashboardPage` (`/`). Skeleton (`SkeletonWrapper`) until `HoldingsCubit` reports `loaded`. Ticks do not flip the skeleton.

### Header

App name, today’s date, connection chip, theme toggle. Dev also shows **Kill socket**. Reuse `AppTopBar` / `DashboardHeader` — do not invent a second app bar.

### Connection chip

Pulse dot + exact labels from `ConnectionLabels`: `Live`, `Reconnecting…`, `Offline`. Do not use Stitch’s “Online”. Color follows real `FeedConnectionStatus` (yield when live, warning when reconnecting, loss when offline).

### Ticker tape

Horizontal chips for watch tickers. Only the chip whose price changed rebuilds. Flash 260–400ms yield / loss tint on that chip.

### Summary cards

Four metrics: Total Invested, Current Value, Profit/Loss, Today's Change. Labels uppercase. Values tabular + Indian grouping. Yield / loss on signed numbers. Across-N-equities / INR copy from `assets/translations/en.json`.

### Filters

Horizontal `FilterChip`s: All, Invested, Profits (+), Losses (-), Today's change. Idle = container + muted text. Active = primary fill + on-primary. Height comes from the chips — do not force 40px.

### Chart

`PortfolioChart` (`fl_chart` area). Ranges 1d / 3d / 5d / 7d / 10d. Historical NAV ledger, not live ticks. Tooltip shows date + value. Stroke uses yield / primary.

### Holdings

- **Phone:** cards — 3-letter monogram, NSE badge, qty/avg subtitle, right-aligned live price + P/L.
- **Tablet:** table with the same data.
- Search does not reset on ticks. Sort is pinned. `ScrollController` stays on `HoldingsSection`.
- Expand a row for **Target Price Alert**: Stitch drawer chrome — pill “Active: ₹…” badge, filled rupee field (`surfaceContainer` / highest), compact Save. Save is snapshot-and-diff.

### Price flash

260–400ms (`AppDurations.priceFlash`) yield / loss tint on **only** the cell or chip that changed. Never flash the whole row or the summary grid because a tape extra ticked.

---

## Copy

English only, via `easy_localization`. Keys live in `assets/translations/en.json` (`dashboard.*`). After adding strings, regenerate `lib/src/core/i18n/locale_keys.g.dart`.

Connection copy (`ConnectionBanner` + chip):

- Chip: `Live` / `Reconnecting…` / `Offline`
- Banner: `Feed dropped. Reconnecting…` / `Feed is offline.`

---

## Component conventions

- Reusable chrome: `lib/src/shared/widgets/` (`AppTopBar`, `AppCard`, `AppTextField`, …).
- Feature widgets: `lib/src/features/<feature>/presentation/widgets/`.
- Default style parameters to theme values.
- Prefer `StatelessWidget`. Use `StatefulWidget` only for controllers (`ScrollController`, `TextEditingController`, flash animation).
- One public widget class per file.

### Dark / light checklist

- No raw `Colors.white` / `Colors.black` for surfaces
- No Google Fonts default ink in dark mode
- New screens verified in both `ThemeMode.dark` and `ThemeMode.light`
- Yield / loss still readable on both canvases
