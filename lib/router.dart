import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/app_providers.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/add_entry_screen.dart';
import 'screens/car_profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/vehicles_screen.dart';

abstract class AppRoutes {
  static const splash      = '/';
  static const auth        = '/auth';
  static const vehicles    = '/vehicles';
  static const dashboard   = '/dashboard';
  static const history     = '/history';
  static const addEntry    = '/add-entry';
  static const addVehicle  = '/add-vehicle';
  static const editVehicle = '/edit-vehicle';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    redirect: (context, state) {
      if (authState.isLoading) return AppRoutes.splash;
      final isAuthenticated = authState.asData?.value != null;
      final loc = state.matchedLocation;
      if (!isAuthenticated && loc != AppRoutes.auth) return AppRoutes.auth;
      if (isAuthenticated &&
          (loc == AppRoutes.auth || loc == AppRoutes.splash)) {
        return AppRoutes.vehicles;
      }
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ── Shell with bottom nav ──────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.vehicles,
            pageBuilder: (_, state) =>
                NoTransitionPage(key: state.pageKey, child: const VehiclesScreen()),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (_, state) =>
                NoTransitionPage(key: state.pageKey, child: const DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.history,
            pageBuilder: (_, state) =>
                NoTransitionPage(key: state.pageKey, child: const HistoryScreen()),
          ),
        ],
      ),

      // ── Full screen routes ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.addEntry,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddEntryScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.addVehicle,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CarProfileScreen(isEditing: false),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.editVehicle,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CarProfileScreen(isEditing: true),
          transitionsBuilder: _slideTransition,
        ),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404',
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
            Text(state.error?.message ?? 'Page not found'),
            TextButton(
              onPressed: () => context.go(AppRoutes.vehicles),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ── Transitions ────────────────────────────────────────────────────────────────
Widget _fadeTransition(_, animation, __, child) =>
    FadeTransition(opacity: animation, child: child);

Widget _slideTransition(_, animation, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );

Widget _slideUpTransition(_, animation, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );

// ── Bottom Nav Shell ───────────────────────────────────────────────────────────
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (route: AppRoutes.vehicles,  label: 'Vehicles',  icon: Icons.garage_outlined,    activeIcon: Icons.garage),
    (route: AppRoutes.dashboard, label: 'Dashboard', icon: Icons.dashboard_outlined,  activeIcon: Icons.dashboard),
    (route: AppRoutes.history,   label: 'History',   icon: Icons.history_outlined,    activeIcon: Icons.history),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    int selectedIndex = 0;
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].route) { selectedIndex = i; break; }
    }

    final showFab = location == AppRoutes.dashboard || location == AppRoutes.history;

    return Scaffold(
      body: child,
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () => context.go(AppRoutes.addEntry),
              icon: const Icon(Icons.add),
              label: const Text('Log Service'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].route),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
