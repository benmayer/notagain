/// App Router Configuration
/// 
/// Defines all routes and navigation for the app using go_router.
/// Routes are protected by authentication state.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../main_layout.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/start/start_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/settings_stubs.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;

      // If not authenticated, allow access to welcome, login, signup screens
      if (!isAuthenticated && (state.matchedLocation == '/' || state.matchedLocation == '/login' || state.matchedLocation == '/signup')) {
        return null;
      }

      // If not authenticated and trying to access protected routes, redirect to welcome
      if (!isAuthenticated) {
        return '/';
      }

      // If authenticated and trying to access auth routes, redirect to home
      if (isAuthenticated && (state.matchedLocation == '/' || state.matchedLocation == '/login' || state.matchedLocation == '/signup')) {
        return '/home';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignupScreen();
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(
            currentRoute: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
          ),
          GoRoute(
            path: '/start',
            name: 'start',
            builder: (BuildContext context, GoRouterState state) {
              return const StartScreen();
            },
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
        routes: [
          GoRoute(
            path: 'device-settings',
            name: 'device-settings',
            builder: (BuildContext context, GoRouterState state) {
              return const DeviceSettingsScreen();
            },
          ),
          GoRoute(
            path: 'help-support',
            name: 'help-support',
            builder: (BuildContext context, GoRouterState state) {
              return const HelpSupportScreen();
            },
          ),
          GoRoute(
            path: 'faqs',
            name: 'faqs',
            builder: (BuildContext context, GoRouterState state) {
              return const FAQsScreen();
            },
          ),
          GoRoute(
            path: 'feedback',
            name: 'feedback',
            builder: (BuildContext context, GoRouterState state) {
              return const FeedbackScreen();
            },
          ),
          GoRoute(
            path: 'terms-of-service',
            name: 'terms-of-service',
            builder: (BuildContext context, GoRouterState state) {
              return const TermsOfServiceScreen();
            },
          ),
          GoRoute(
            path: 'privacy-policy',
            name: 'privacy-policy',
            builder: (BuildContext context, GoRouterState state) {
              return const PrivacyPolicyScreen();
            },
          ),
        ],
      ),
    ],
  );
}
