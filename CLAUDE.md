# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on device/emulator
flutter run

# Analyze for errors and warnings
flutter analyze --no-fatal-infos

# Build APK (release)
flutter build apk --release

# Code generation (Drift, Riverpod, Freezed, JSON)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs
```

There are no tests currently in this project.

## Architecture

**Xantara POS** — a Flutter offline-first point-of-sale app. Dart SDK `>=3.3.0`.

### State management
Riverpod (`flutter_riverpod: ^2.6.1`) using `StateNotifierProvider` and `StateProvider` throughout. No generated providers (`@riverpod`) — all providers are defined manually. Providers are watched in `ConsumerWidget` / `ConsumerStatefulWidget`.

### Navigation
GoRouter (`go_router: ^14.6.2`) with a single `appRouterProvider` in `lib/core/router/app_router.dart`. The router uses a `redirect` callback that gates all routes behind auth, and sends users to `/admin` (admin role) or `/cashier` (cashier role) after login.

**Route map:**
| Path | Screen | Who sees it |
|------|--------|-------------|
| `/` | SplashScreen | All |
| `/login` | LoginScreen | Unauthenticated |
| `/admin` | AdminDashboardScreen | Admin |
| `/analytics` | AnalyticsScreen | Admin |
| `/inventory` | InventoryScreen | Admin |
| `/cashier` | CashierDashboardScreen | Cashier |
| `/pos` | PosScreen | Both |
| `/orders` | OrdersScreen | Both |
| `/settings` | SettingsScreen | Both |

### Role-based UX
- **Admin** lands on `/admin` → has bottom tab bar (Dashboard / Analytics / Inventory) → can open `/pos`
- **Cashier** lands on `/cashier` → clock in/out shift → can open `/pos`
- Both roles share the same POS and Orders screens

### Checkout flow
`PosScreen` opens `CheckoutScreen` via `showModalBottomSheet`. `CheckoutScreen` is a two-page flow within a single `DraggableScrollableSheet`:
1. **Cart page** — items, promo code (`DISC200` = ₱200 off), VAT (12%), summary
2. **Payment page** — Credit/Debit Card (default), Cash (tendered amount + change), GCash/Maya (QR)

`PaymentMethod` enum: `card`, `cash`, `qrph`. Void/remove actions require supervisor PIN (`voidPermissionCode = '1234'` in `orders_provider.dart`).

### Key providers
| Provider | File | Purpose |
|----------|------|---------|
| `authProvider` | `features/auth/providers/auth_provider.dart` | Current user + login/logout. Static users only (no backend yet) |
| `cartProvider` | `features/pos/providers/cart_provider.dart` | In-memory cart items |
| `ordersProvider` | `features/orders/providers/orders_provider.dart` | Session-scoped order history + void |
| `productsProvider` | `features/pos/providers/pos_provider.dart` | Product catalogue + stock |
| `shiftProvider` | `features/cashier/providers/shift_provider.dart` | Clock-in/out state |
| `shiftOrdersProvider` | same file | Orders placed after current clock-in |
| `syncProvider` | `shared/providers/sync_provider.dart` | Sync status (synced / syncing / offline) |
| `connectivityProvider` | `core/network/connectivity.dart` | `StreamProvider<bool>` from connectivity_plus |
| `themeModeProvider` | `features/settings/providers/settings_provider.dart` | Light/dark/system theme |
| `biometricEnabledProvider` | `shared/providers/biometric_provider.dart` | Biometric login toggle (shared_preferences) |

### Design tokens
All UI constants live in `lib/core/constants/`:
- `AppColors` — brand, status, neutral scale, dark theme, white overlays, payment brand colors
- `AppSizes` — 8pt spacing grid (`xs/sm/md/lg/xl/xxl`), border radii, button height
- `AppShadows` — `sm`, `md`, `lg` shadow lists
- `AppTextStyles` — `heroNumber`, `statNumber`, `body`, `caption`

Always use these instead of hardcoded values. `AppColors.gray50` is the standard screen background.

### Data persistence
`lib/local/` contains a Drift database schema (`database.dart`) and DAOs for orders, products, and config — but the database file is currently empty (1 line). All runtime state is in-memory Riverpod providers. The `dio` client and `api_client.dart` are scaffolded but not wired to any live backend.

### Admin dashboard stats
The admin dashboard computes Net Sales / Orders / Avg Order from `ordersProvider` (filters `isVoided`). The analytics screen (`/analytics`) uses private derived providers defined at the top of `analytics_screen.dart` — `_netSalesProvider`, `_transactionCountProvider`, `_topProductsProvider`, `_paymentBreakdownProvider`.

### Biometric login
`BiometricService` in `shared/services/biometric_service.dart` uses `local_auth`. Credentials are stored in `shared_preferences`. On Android, `FlutterFragmentActivity` is required in `MainActivity.kt`.
