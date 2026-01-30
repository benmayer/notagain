import 'package:flutter/cupertino.dart';
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
import '../screens/onboarding/onboarding_step1_screen.dart';
import '../screens/onboarding/onboarding_step2_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/settings_stubs.dart';
import 'cupertino_page_route.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    observers: [_NavigationLogger()],
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final user = authProvider.user;
      final onboardingCompleted = user?.onboardingCompleted ?? false;

      // Not authenticated - allow access to auth screens
      if (!isAuthenticated) {
        if (state.matchedLocation == '/' || 
            state.matchedLocation == '/login' || 
            state.matchedLocation == '/signup') {
          return null; // Allow access
        }
        return '/'; // Redirect to welcome
      }

      // Authenticated but onboarding not complete
      if (isAuthenticated && !onboardingCompleted) {
        // Allow access to onboarding screens
        if (state.matchedLocation == '/onboarding' || 
            state.matchedLocation == '/onboarding/step2') {
          return null;
        }
        // Redirect all other routes to onboarding
        return '/onboarding';
      }

      // Authenticated and onboarded - redirect from auth screens to home
      if (isAuthenticated && onboardingCompleted) {
        if (state.matchedLocation == '/' || 
            state.matchedLocation == '/login' || 
            state.matchedLocation == '/signup') {
          return '/home';
        }
        // Don't allow access to onboarding screens if already completed
        if (state.matchedLocation == '/onboarding' || 
            state.matchedLocation == '/onboarding/step2') {
          return '/home';
        }
      }

      return null; // Allow access
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'welcome',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CupertinoPage<void>(
            name: 'welcome',
            child: const WelcomeScreen(),
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CupertinoPageWithGesture<void>(
            name: 'login',
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CupertinoPageWithGesture<void>(
            name: 'signup',
            child: const SignupScreen(),
          );
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
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage(child: HomeScreen());
            },
          ),
          GoRoute(
            path: '/start',
            name: 'start',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage(child: StartScreen());
            },
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage(child: ProfileScreen());
            },
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CupertinoPageWithGesture<void>(
            name: 'onboarding',
            child: const OnboardingStep1Screen(),
          );
        },
      ),
      GoRoute(
        path: '/onboarding/step2',
        name: 'onboarding-step2',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CupertinoPageWithGesture<void>(
            name: 'onboarding-step2',
            child: const OnboardingStep2Screen(),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CupertinoPageWithGesture<void>(
            name: 'settings',
            child: const SettingsScreen(),
          );
        },
        routes: [
          GoRoute(
            path: 'device-settings',
            name: 'device-settings',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CupertinoPageWithGesture<void>(
                name: 'device-settings',
                child: const DeviceSettingsScreen(),
              );
            },
          ),
          GoRoute(
            path: 'help-support',
            name: 'help-support',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CupertinoPageWithGesture<void>(
                name: 'help-support',
                child: const HelpSupportScreen(),
              );
            },
          ),
          GoRoute(
            path: 'faqs',
            name: 'faqs',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CupertinoPageWithGesture<void>(
                name: 'faqs',
                child: const FAQsScreen(),
              );
            },
          ),
          GoRoute(
            path: 'feedback',
            name: 'feedback',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CupertinoPageWithGesture<void>(
                name: 'feedback',
                child: const FeedbackScreen(),
              );
            },
          ),
          GoRoute(
            path: 'terms-of-service',
            name: 'terms-of-service',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CupertinoPageWithGesture<void>(
                name: 'terms-of-service',
                child: const TermsOfServiceScreen(),
              );
            },
          ),
          GoRoute(
            path: 'privacy-policy',
            name: 'privacy-policy',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CupertinoPageWithGesture<void>(
                name: 'privacy-policy',
                child: const PrivacyPolicyScreen(),
              );
            },
          ),
        ],
      ),
    ],
  );
}

/// Navigation logger for debugging route transitions
class _NavigationLogger extends NavigatorObserver {}

