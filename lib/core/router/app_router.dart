import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/pos/fnb/screens/pos_screen.dart';
import '../../features/pos/pos_coming_soon_screen.dart';
import '../../features/pos/pos_mode_selector.dart';
import '../../features/pos/retail/screens/grocery_pos_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/cashier/screens/cashier_dashboard_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/readiness/screens/improvements_lab_screen.dart';

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

      final isAdmin = isAdminRole(auth.user?.role);

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
        path: '/pos/retail',
        builder: (context, state) => const GroceryPosScreen(),
      ),
      GoRoute(
        path: '/pos/coming-soon',
        builder: (context, state) =>
            PosComingSoonScreen(mode: state.extra as PosBusinessMode),
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
      GoRoute(
        path: '/improvements',
        builder: (context, state) => const ImprovementsLabScreen(),
      ),
    ],
  );
});
