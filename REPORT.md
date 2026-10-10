# Xantara POS Report

10 October 2026, BIR preparation: [pre-assessment package](docs/BIR_PRE_ASSESSMENT_PACKAGE_2026-10-10.md) prepared for preliminary classification and requirements confirmation. It freezes the proposed F&B/Grocery scope, maps fiscal outputs, lists available and missing evidence, documents security/reporting boundaries, and asks 15 specific questions about accreditation/PTU, credit notes, X/Z, journal, eSales/EIS, retention and hardware. It is not a formal filing or approval claim.

10 October 2026, acceptance preparation: [device and printer acceptance pack](docs/DEVICE_ACCEPTANCE_PACK.md) prepared for the current F&B and Grocery/Retail scope. It defines 12 target-device scenarios, controlled test data, evidence naming/hashes, invoice/credit-note/cash/report reconciliation, printer disconnect/paper-out/restart/retry tests, stop conditions and final sign-off. The interactive PDF starts with every physical outcome unchecked. No device or printer acceptance is claimed by preparing the pack.

10 October 2026, credit-note update: [linked cash returns](docs/CREDIT_NOTES.md) now preserve originals, allocate a separate CN series, restore selected stock and record one cash refund atomically. Copies, journal and X/Z reconcile on the return date. Scope: original terminal, opened drawer, cash, no loyalty-linked invoice. Schema 13; full Flutter suite 170 passed, final seven return tests passed, analysis clean, release build passed; matching backend 22 sync tests passed. Physical/device acceptance and production deployment remain pending. The interactive work checklist now includes this batch and the preceding Senior/PWD work; the older user-test report remains historical.

10 October 2026, later update: [Senior/PWD workflow](docs/STATUTORY_DISCOUNTS.md) implemented for scoped F&B and Grocery/Retail purchases. Owner-configured product eligibility, beneficiary evidence, separate VAT relief, weekly BNPC safeguards, saved receipt/journal evidence, X/Z breakdowns and an authorized supporting CSV. Schema 12 preserves existing fiscal documents. Full suite **163 passed**; final checkout regression **9 passed** after the Grocery selector refinement. Final lib/test analysis clean; release preview build passed with the existing Cupertino-font warning. Benefits remain disabled until owner configuration. Representative/group/bulk, fuel-specific, medicine and promotion-comparison workflows, physical/browser/cloud acceptance and official sign-off remain pending. Restaurant remains deferred.

10 October 2026: [next pending controls completed](docs/PENDING_CONTROLS_2026-10-10.md): shared commercial-discount allocation and demo-promo guard, report identifiers/wording, saved-sale hardware failure protection and an isolated recovery rehearsal. Full suite: 150 passed. Restaurant development is deferred by request. Statutory/official-output and physical/operational acceptance remain open.

Latest status (9 October 2026): [business profiles](docs/BUSINESS_PROFILES.md) and [verified invoice buyer/receipt changes](docs/INVOICE_BUYER_FIELDS.md). Full suite: 145 tests passed; analysis and release build passed. The updated test-report PDF has 13 pages and the Work Checklist has 4 pages with 36 interactive boxes. The [7 October gap review](docs/INSPECTION_REVIEW_2026-10-07.md) remains the dated baseline for unresolved inspection work. The general project description below is historical and is not an inspection-readiness certification.

## Project Function

Xantara POS is a Flutter point-of-sale application designed for offline-first use. It supports two user roles:
- **Admin**: access dashboard, analytics, inventory, and POS
- **Cashier**: access cashier dashboard, clock in/out shifts, and POS

The app uses Riverpod for state management, GoRouter for navigation, and Drift for local database support. It includes features such as in-memory product/catalog management, order history, checkout with payment options, and a desktop-friendly window manager setup.

## Main Entry Points

- `lib/main.dart`: application entry point. Initializes desktop window options on Windows/macOS/Linux and launches the app.
- `lib/app.dart`: root `PosApp` widget. Configures theme, router, and Riverpod provider scope.
- `lib/core/router/app_router.dart`: app routes and auth-based redirect logic.
- `lib/features/*`: feature modules for auth, cashier, admin, inventory, orders, pos, settings, analytics, and splash.

## How to Load the Project

1. Open `C:\Users\USER\OneDrive\Documents\BluecodeRepo\Xantara-POS` in VS Code or Android Studio.
2. Let the editor detect Flutter and Dart.
3. Run `flutter pub get` in the terminal or use the IDE command palette.

## How to Edit the Project

- Use VS Code or Android Studio to edit Dart files in `lib/`.
- Common edit locations:
  - `lib/main.dart` for app startup behavior.
  - `lib/app.dart` for theme/router configuration.
  - `lib/core/router/app_router.dart` for route definitions.
  - `lib/features/auth/providers/auth_provider.dart` for login/auth logic.
  - `lib/features/pos/providers/cart_provider.dart` for cart behavior.
  - `lib/features/orders/providers/orders_provider.dart` for order history.
  - `lib/features/settings/providers/settings_provider.dart` for theme settings.

## How to Run the Project

1. Open a terminal inside the project root.
2. Fetch dependencies:

```bash
flutter pub get
```

3. Run on a connected device or desktop platform:

```bash
flutter run
```

4. For desktop on Windows:

```bash
flutter run -d windows
```

5. For Android or iOS, select the device/emulator in your IDE or pass `-d android` / `-d ios`.

## How to Test the Project

The repo currently includes a basic widget smoke test.

1. Run all tests:

```bash
flutter test
```

2. Run the widget test file specifically:

```bash
flutter test test/widget_test.dart
```

## Useful Commands

- Analyze code:

```bash
flutter analyze --no-fatal-infos
```

- Build the app for release:

```bash
flutter build apk --release
```

- Run code generation when working with generated files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Notes

- The app is currently scaffolded as a Flutter POS app with local state and no live backend integration.
- `lib/local/database.dart` exists but the local Drift DB is not fully implemented.
- The sample test only verifies the app widget can build without errors.
