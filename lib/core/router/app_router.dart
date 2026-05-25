import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/pos/screens/pos_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/cashier/screens/cashier_dashboard_screen.dart';
import '../../features/orders/screens/orders_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      if (loc == '/') return null; // let splash handle it

      if (!auth.isAuthenticated) {
        return loc == '/login' ? null : '/login';
      }

      final isAdmin = auth.user?.role == 'admin';

      // Redirect away from login if already authenticated
      if (loc == '/login') return isAdmin ? '/admin' : '/cashier';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosScreen(),
      ),
      GoRoute(
        path: '/cashier',
        builder: (context, state) => const CashierDashboardScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
