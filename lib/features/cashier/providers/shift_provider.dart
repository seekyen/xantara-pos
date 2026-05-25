import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/providers/orders_provider.dart';

class ShiftState {
  final bool isClockedIn;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;

  const ShiftState({
    this.isClockedIn = false,
    this.clockInTime,
    this.clockOutTime,
  });

  Duration get duration {
    if (clockInTime == null) return Duration.zero;
    final end = clockOutTime ?? DateTime.now();
    return end.difference(clockInTime!);
  }

  String get formattedDuration {
    final d = duration;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m hrs';
  }
}

class ShiftNotifier extends StateNotifier<ShiftState> {
  ShiftNotifier() : super(const ShiftState());

  void clockIn() {
    state = ShiftState(isClockedIn: true, clockInTime: DateTime.now());
  }

  void clockOut() {
    state = ShiftState(
      isClockedIn: false,
      clockInTime: state.clockInTime,
      clockOutTime: DateTime.now(),
    );
  }

  void reset() => state = const ShiftState();
}

final shiftProvider = StateNotifierProvider<ShiftNotifier, ShiftState>(
  (ref) => ShiftNotifier(),
);

// Orders placed during the current shift (after clock-in)
final shiftOrdersProvider = Provider((ref) {
  final shift = ref.watch(shiftProvider);
  if (shift.clockInTime == null) return <OrderRecord>[];
  return ref.watch(ordersProvider).where((r) {
    return r.order.timestamp.isAfter(shift.clockInTime!);
  }).toList();
});

final shiftSalesProvider = Provider<double>((ref) {
  return ref.watch(shiftOrdersProvider).where((r) => !r.isVoided).fold(
        0.0,
        (sum, r) => sum + r.order.total,
      );
});
