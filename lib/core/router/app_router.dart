import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/auth/providers/auth_provider.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/journey/screens/journey_screen.dart';
import '../../presentation/contacts/screens/trusted_contacts_screen.dart';
import '../../presentation/journey/screens/history_screen.dart';
import '../../presentation/web/screens/web_live_tracking_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isWebTracking = state.matchedLocation.startsWith('/track/');

      // Allow public web live tracking links without authentication
      if (isWebTracking) {
        return null;
      }

      final isAuthenticated = authState.value != null;

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const JourneyScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const TrustedContactsScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/track/:journeyId',
        builder: (context, state) {
          final journeyId = state.pathParameters['journeyId'] ?? '';
          return WebLiveTrackingScreen(journeyId: journeyId);
        },
      ),
    ],
  );
});
