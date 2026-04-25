import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/services/services_screen.dart';
import '../../features/services/add_service_screen.dart';
import '../../features/staff/staff_screen.dart';
import '../../features/staff/add_staff_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../widgets/main_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

const _authRoutes = ['/login', '/signup', '/forgot-password'];

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final path = state.uri.path;
    final isAuthRoute = _authRoutes.contains(path);

    if (!isLoggedIn && !isAuthRoute) return '/login';

    if (isLoggedIn && isAuthRoute) {
      // Check if profile completion needed
      try {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthNeedsProfileCompletion) {
          return null; // Let the barber app handle differently
        }
      } catch (_) {}
      return '/dashboard';
    }

    return null;
  },
  routes: [
    // ── Auth Routes ──
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(
        appTitle: 'Barber Portal',
        onLogin: () => GoRouter.of(context).go('/dashboard'),
        onSignUp: () => GoRouter.of(context).go('/signup'),
        onForgotPassword: () => GoRouter.of(context).go('/forgot-password'),
      ),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(
        userRole: 'barber',
        onSignUp: () => GoRouter.of(context).go('/dashboard'),
        onLogin: () => GoRouter.of(context).go('/login'),
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgotPasswordScreen(
        onBack: () => GoRouter.of(context).go('/login'),
      ),
    ),

    // ── Main App (Shell) ──
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/schedule',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ScheduleScreen()),
        ),
        GoRoute(
          path: '/services',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ServicesScreen()),
        ),
        GoRoute(
          path: '/staff',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StaffScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),

    GoRoute(
      path: '/staff/add',
      builder: (context, state) => const AddStaffScreen(),
    ),
    GoRoute(
      path: '/services/add',
      builder: (context, state) => const AddServiceScreen(),
    ),
    GoRoute(
      path: '/services/edit/:id',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is ServiceModel) return AddServiceScreen(service: extra);
        return const ServicesScreen();
      },
    ),
    GoRoute(
      path: '/staff/edit/:id',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is BarberModel) return AddStaffScreen(barber: extra);
        return const StaffScreen();
      },
    ),
  ],
);
