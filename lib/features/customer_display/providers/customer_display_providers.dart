import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../customer_display_state.dart';

// CUSTOMER_DISPLAY — singleton state accessible from both cashier and customer windows.
// Each window has its own ProviderScope instance; state is synchronised via
// CustomerDisplayBridge method channels.
final customerDisplayStateProvider =
    ChangeNotifierProvider<CustomerDisplayState>(
  (ref) => CustomerDisplayState(),
);

// Stores the window ID returned by DesktopMultiWindow.createWindow so the
// bridge knows which window to send messages to.
final customerDisplayWindowIdProvider = StateProvider<int?>((ref) => null);
