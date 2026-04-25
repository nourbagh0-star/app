import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/home/home_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/pages/profile_completion_screen.dart';
import '../../features/profile/pages/edit_profile_screen.dart';
import '../../features/profile/pages/payment_methods_screen.dart';
import '../../features/profile/pages/notifications_settings_screen.dart';
import '../../features/profile/pages/favorites_screen.dart';
import '../../features/profile/pages/privacy_security_screen.dart';
import '../../features/profile/pages/help_support_screen.dart';
import '../../features/shop_profile/shop_profile_screen.dart';
import '../../features/barber_profile/barber_profile_screen.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/reschedule/reschedule_screen.dart';
import '../widgets/main_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

const _authRoutes = ['/login', '/signup', '/forgot-password'];
const _profileCompleteRoute = '/profile/complete';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isLoggedIn = firebaseUser != null;
    final path = state.uri.path;
    final isAuthRoute = _authRoutes.contains(path);

    // Not logged in → force to login
    if (!isLoggedIn && !isAuthRoute && path != _profileCompleteRoute) {
      return '/login';
    }

    // Logged in but on an auth route → resolve by role
    if (isLoggedIn && isAuthRoute) {
      try {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthNeedsProfileCompletion) {
          return _profileCompleteRoute;
        }
        if (authState is AuthBarber) {
          // Barber logged into customer app — still allow home
          return '/home';
        }
      } catch (_) {}
      return '/home';
    }

    // Profile completion required
    if (isLoggedIn) {
      try {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthNeedsProfileCompletion &&
            path != _profileCompleteRoute) {
          return _profileCompleteRoute;
        }
      } catch (_) {}
    }

    return null;
  },
  routes: [
    // ── Auth Routes ──
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(
        appTitle: 'Premium Barber',
        onLogin: () => GoRouter.of(context).go('/home'),
        onSignUp: () => GoRouter.of(context).go('/signup'),
        onForgotPassword: () => GoRouter.of(context).go('/forgot-password'),
      ),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(
        userRole: 'customer',
        onSignUp: () => GoRouter.of(context).go('/home'),
        onLogin: () => GoRouter.of(context).go('/login'),
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgotPasswordScreen(
        onBack: () => GoRouter.of(context).go('/login'),
      ),
    ),

    // ── Profile Completion ──
    GoRoute(
      path: _profileCompleteRoute,
      builder: (context, state) => const ProfileCompletionScreen(),
    ),

    // ── Profile Sub-Pages ──
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/payment',
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: '/profile/notifications',
      builder: (context, state) => const NotificationsSettingsScreen(),
    ),
    GoRoute(
      path: '/profile/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/profile/privacy',
      builder: (context, state) => const PrivacySecurityScreen(),
    ),
    GoRoute(
      path: '/profile/help',
      builder: (context, state) => const HelpSupportScreen(),
    ),

    // ── Main App (Shell) ──
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HistoryScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),

    // ── Shop & Booking ──
    GoRoute(
      path: '/shop/:id',
      builder: (context, state) {
        final shop = state.extra as ShopModel?;
        return ShopProfileScreen(
          shopId: state.pathParameters['id'] ?? '',
          shopModel: shop,
        );
      },
    ),
    GoRoute(
      path: '/barber/:shopId/:barberId',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;
        final shop = extras?['shop'] as ShopModel?;
        final barber = extras?['barber'] as BarberModel?;
        if (shop == null || barber == null) {
          return const Scaffold(body: Center(child: Text('Error: Missing data')));
        }
        return BarberProfileScreen(shop: shop, barber: barber);
      },
    ),
    GoRoute(
      path: '/booking/:id',
      builder: (context, state) {
        final shop = state.extra as ShopModel?;
        return BookingScreen(
          shopId: state.pathParameters['id'] ?? '',
          shopModel: shop,
        );
      },
    ),
    GoRoute(
      path: '/reschedule/:id',
      builder: (context, state) =>
          RescheduleScreen(appointmentId: state.pathParameters['id'] ?? ''),
    ),
  ],
);
