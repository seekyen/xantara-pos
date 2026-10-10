import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/cloud_sync_controller.dart';
import '../../../shared/providers/sync_provider.dart';

/// Mirrors the backend's singleton StoreSettings record (GET/PATCH
/// `/api/v1/settings/`) — the same record the admin web dashboard's Settings
/// page reads and writes, via the existing "Connect Xantara Cloud" session
/// (see [CloudSyncController]). Per-device preferences (theme, sound effects,
/// PIN, etc. in settings_provider.dart) stay local and are not part of this.
class StoreSettingsState {
  const StoreSettingsState({
    this.loading = true,
    this.connected = false,
    this.error,
    this.storeName = '',
    this.address = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.currency = 'PHP',
    this.currencySymbol = '₱',
    this.vatRate = '12.00',
    this.vatInclusive = false,
    this.showVatReceipt = true,
    this.receiptHeader = '',
    this.receiptFooter = '',
    this.printAuto = true,
    this.emailReceipt = false,
    this.lowStockThreshold = 10,
    this.payCash = true,
    this.payCard = true,
    this.payGcash = true,
    this.payMaya = true,
  });

  final bool loading;
  /// Whether a Xantara Cloud admin session is connected — shared store
  /// settings can only be read/written once this is true.
  final bool connected;
  final String? error;
  final String storeName;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String currency;
  final String currencySymbol;
  final String vatRate;
  final bool vatInclusive;
  final bool showVatReceipt;
  final String receiptHeader;
  final String receiptFooter;
  final bool printAuto;
  final bool emailReceipt;
  final int lowStockThreshold;
  final bool payCash;
  final bool payCard;
  final bool payGcash;
  final bool payMaya;

  factory StoreSettingsState.fromJson(Map<String, dynamic> json) =>
      StoreSettingsState(
        loading: false,
        connected: true,
        storeName: json['store_name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        contactEmail: json['contact_email'] as String? ?? '',
        contactPhone: json['contact_phone'] as String? ?? '',
        currency: json['currency'] as String? ?? 'PHP',
        currencySymbol: json['currency_symbol'] as String? ?? '₱',
        vatRate: json['vat_rate']?.toString() ?? '12.00',
        vatInclusive: json['vat_inclusive'] as bool? ?? false,
        showVatReceipt: json['show_vat_receipt'] as bool? ?? true,
        receiptHeader: json['receipt_header'] as String? ?? '',
        receiptFooter: json['receipt_footer'] as String? ?? '',
        printAuto: json['print_auto'] as bool? ?? true,
        emailReceipt: json['email_receipt'] as bool? ?? false,
        lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt() ?? 10,
        payCash: json['pay_cash'] as bool? ?? true,
        payCard: json['pay_card'] as bool? ?? true,
        payGcash: json['pay_gcash'] as bool? ?? true,
        payMaya: json['pay_maya'] as bool? ?? true,
      );

  StoreSettingsState copyWith({
    bool? loading,
    bool? connected,
    String? error,
  }) =>
      StoreSettingsState(
        loading: loading ?? this.loading,
        connected: connected ?? this.connected,
        error: error,
        storeName: storeName,
        address: address,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        currency: currency,
        currencySymbol: currencySymbol,
        vatRate: vatRate,
        vatInclusive: vatInclusive,
        showVatReceipt: showVatReceipt,
        receiptHeader: receiptHeader,
        receiptFooter: receiptFooter,
        printAuto: printAuto,
        emailReceipt: emailReceipt,
        lowStockThreshold: lowStockThreshold,
        payCash: payCash,
        payCard: payCard,
        payGcash: payGcash,
        payMaya: payMaya,
      );
}

class StoreSettingsController extends StateNotifier<StoreSettingsState> {
  StoreSettingsController(this._cloud) : super(const StoreSettingsState()) {
    load();
  }

  final CloudSyncController _cloud;

  Future<void> load() async {
    if (!await _cloud.isConfigured) {
      state = state.copyWith(loading: false, connected: false);
      return;
    }
    state = state.copyWith(loading: true, connected: true, error: null);
    try {
      final data = await _cloud.settingsRequest();
      if (data is Map) {
        state = StoreSettingsState.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (error) {
      state = state.copyWith(
          loading: false, connected: true, error: error.toString());
    }
  }

  /// PATCHes the given fields (backend field names, e.g. `store_name`) and
  /// applies the server's response as the new state. Throws on failure so
  /// callers (edit dialogs) can show an inline error without losing the
  /// user's in-progress edit.
  Future<void> updateFields(Map<String, dynamic> patch) async {
    final data = await _cloud.settingsRequest(method: 'PATCH', data: patch);
    if (data is Map) {
      state = StoreSettingsState.fromJson(Map<String, dynamic>.from(data));
    }
  }

  Future<void> updateStoreName(String value) =>
      updateFields({'store_name': value});

  Future<void> updateReceiptHeader(String value) =>
      updateFields({'receipt_header': value});

  Future<void> updateCurrency(String value) =>
      updateFields({'currency': value});
}

final storeSettingsProvider =
    StateNotifierProvider<StoreSettingsController, StoreSettingsState>(
  (ref) => StoreSettingsController(ref.watch(cloudSyncControllerProvider)),
);
