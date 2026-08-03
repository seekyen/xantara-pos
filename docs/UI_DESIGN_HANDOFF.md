# Xantara POS — Design Handoff Summary

This is a snapshot of the app for a design-focused review. It covers what
the product is, what's built today (backend + UI), the current visual
system, and where the UI has known rough edges worth a modern redesign pass.

## What the product is

**Xantara POS** is an offline-first Point-of-Sale app for Philippine retail,
built in Flutter. It targets small-to-mid retailers who need:
- BIR-compliant invoicing (sequential official receipts, VAT breakdown, void
  trail) that works with zero internet connectivity
- Two staff roles: **Admin/Owner** (dashboard, analytics, inventory,
  multi-branch) and **Cashier** (clock in/out, point-of-sale, orders)
- Optional Premium cloud sync for an owner to monitor multiple branches
  remotely (not yet connected to a live backend)
- Cash payments today; GCash/Maya/bank/card are designed for but not yet
  live (no payment gateway is configured)
- Receipt printing and cash-drawer support (currently simulated — no
  physical driver is wired up yet)

Runs on Windows/macOS/Linux desktop and Android/iOS. A secondary
**customer-facing display** window exists for dual-screen checkout setups
(desktop only, via `desktop_multi_window`).

## Tech stack

- Flutter, Dart ≥3.3, Material 3 (`useMaterial3: true`)
- State: Riverpod (`StateNotifierProvider`/`StateProvider`, all hand-written)
- Navigation: GoRouter, single router with an auth-gated `redirect`
- Local data: Drift (SQLite) — just wired up this session; previously the UI
  ran on SharedPreferences-backed in-memory state
- Fonts: Google Fonts — **DM Sans** for UI text, **DM Mono** for invoice/
  transaction numbers (via `google_fonts` package)

## Current design system (`lib/core/constants/`, `lib/core/theme/`)

**Color palette** — one brand blue, semantic status colors, a 6-step gray
scale:
| Role | Hex |
|---|---|
| Primary | `#1A5FD6` (light `#E8F0FE`, dark `#0D3D99`) |
| Success | `#1A9E5C` |
| Warning | `#D68910` |
| Error | `#C0392B` |
| Gray scale | `#F7F8FA` → `#F0F1F5` → `#E1E4EC` → `#9CA3B2` → `#5B6380` → `#1E2235` |
| GCash brand | `#007DFC` |

Dark theme exists (`scaffoldBackgroundColor: #111827`, surfaces `#1F2937`/
`#374151`) and is switchable (light/dark/system) plus a **customizable
Material 3 color seed** — but only the brand blue has been designed against;
dark-mode has not had a dedicated design pass.

**Spacing** — strict 8pt grid: `xs=4, sm=8, md=12, lg=16, xl=24, xxl=32`.
**Radii**: input 8, card 12–14, button 10, pill 20, bottom-sheet top 32.
**Shadows**: 3 tiers (sm/md/lg), all very soft/low-opacity — a flat,
"Notion-ish" card aesthetic rather than heavy elevation.
**Buttons**: full-width by default, 48px height, 0 elevation, solid fills.
**Type**: no real type scale defined beyond 4 ad hoc styles
(`heroNumber` 32/700, `statNumber` 20/700, `body` 13/400, `caption` 11/400)
— most screens hardcode font sizes/weights inline rather than pulling from
a shared scale. This is one of the biggest opportunities for a design pass.

## Screen inventory

| Route | Screen | Notes |
|---|---|---|
| `/` | Splash | 3s branded splash, animated logo |
| `/login` | Login | Email/password, biometric quick sign-in, now shows a "training accounts" credential hint box |
| `/admin` | Admin dashboard | Net sales / orders / avg order stats, bottom tab bar (Dashboard / Analytics / Inventory) |
| `/analytics` | Analytics | Derived stats: top products, payment breakdown |
| `/inventory` | Inventory | Product grid, add/edit dialog, stock +/- controls |
| `/cashier` | Cashier dashboard | Clock in/out shift |
| `/pos` | POS (has desktop + tablet layout variants) | Product grid + cart panel, category filter |
| `/orders` | Order history | Card list, void flow |
| `/settings` | Settings | Theme, biometric toggle, profile |
| `/improvements` | "Improvements Lab" | A dev/status page with toggles simulating offline/premium/payment state — candidate to retire or turn into a real system-status panel (see below) |

**Checkout** is a modal `DraggableScrollableSheet` over POS, two pages
(Cart → Payment) rather than a routed screen. **Customer display** is a
separate always-on-top window (idle/order/payment screens) for a
second monitor facing the customer.

## Interaction patterns worth knowing about

- **Supervisor authorization**: void/clear-cart/remove-item actions now open
  a modal asking for a supervisor's real email+password (just replaced a
  shared 4-digit PIN dialog). This is a plain `AlertDialog` with two text
  fields today — a good candidate for a more purpose-built, POS-appropriate
  interaction (e.g. large numeric PIN pad for touch devices, or a slide-in
  panel instead of a centered dialog).
- **Training/compliance banners**: the receipt preview shows a yellow
  "TRAINING / NOT AN OFFICIAL BIR INVOICE" banner, and disabled payment
  tiles show "Requires a configured payment gateway" — these are functional
  but visually an afterthought (plain colored `Container` + text), not a
  designed banner/badge component.
- **Receipt preview**: a dialog styled like a physical paper receipt
  (dashed dividers, monospace invoice number) — this is the closest thing
  to a distinctive visual moment in the app today and could be leaned into.
- **Disabled states**: non-cash payment methods are shown at 50% opacity
  rather than a more intentional disabled treatment.

## What's real vs. simulated right now

Just-completed work connected a fully-tested backend (BIR invoicing, audit
trail, staff auth, multi-branch inventory, hardware job queue) to the
running app. For a design conversation, the useful takeaway is:
- **Real**: login, product catalog, checkout → invoice issuance, stock
  deduction, order history, void (with supervisor auth), cash payment.
- **Simulated / not yet live**: GCash/Maya/bank/card payments, physical
  receipt printer & cash drawer (jobs are queued and "completed" in
  software only), Premium cloud sync, supplier low-stock alerts,
  multi-branch stock transfer UI (backend exists, no screen yet).

## Where a modern design pass would help most

1. **Type scale** — replace the ad hoc inline font sizes with a real,
   named scale (display/title/body/label × sizes), applied consistently.
2. **Component library** — buttons/badges/status-pills/empty-states are
   mostly re-implemented per screen (`_Section`, `_Check`, `_Notice` in one
   file, similar-but-different versions elsewhere). A shared component set
   would tighten consistency and cut duplication.
3. **POS ergonomics** — this is a cashier tool used all day on a touchscreen
   or with a barcode scanner: touch target sizing, numeric entry (cash
   tendered, stock adjust), and a real PIN-pad for supervisor auth deserve
   POS-specific patterns, not generic form fields.
4. **Dark mode** — exists structurally but wasn't designed against; needs a
   real pass if it's meant to be shipped.
5. **Status/compliance messaging** — training banners, "gateway not
   configured" notices, and the Improvements Lab status page are all
   functional-but-flat; these are a chance for a distinctive "system health"
   visual language (the app has real audit-trail/hardware-queue/sync-status
   data to show now, not just fake toggles).
6. **Dashboard data viz** — Admin/Analytics screens are stat-card + list
   heavy; there's an opportunity for real charts now that the numbers are
   backed by real transactions.
7. **Empty/loading states** — worth an explicit inventory; some exist
   (`shared/widgets/empty_state.dart`), consistency across screens is
   unverified.
8. **Responsive layering** — POS already has desktop/tablet screen variants;
   worth confirming the design system scales cleanly rather than being two
   hand-tuned layouts.

## Branding assets

App name "Xantara POS", logo at `assets/images/xantara-logo.png` (falls
back to a generic icon if missing in several places — worth checking it's
present/high-res). No documented brand guidelines beyond the color/spacing
tokens above.
