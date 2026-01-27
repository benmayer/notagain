import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'core/logging/app_logger.dart';
import 'core/theme/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'routing/app_router.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger (before other setup)
  AppLogger.init();
  
  // Load environment variables from .env file
  await dotenv.load();
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_KEY'];
  
  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception(
      'Missing Supabase credentials. '
      'Please ensure SUPABASE_URL and SUPABASE_KEY are set in .env file. '
      'See .env.example for reference.'
    );
  }
  
  // Initialize Supabase
  final supabaseService = SupabaseService();
  await supabaseService.initialize(
    supabaseUrl: supabaseUrl,
    supabaseKey: supabaseKey,
  );
  
  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  // Initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.init();

  // Initialize settings provider
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => settingsProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: 'NotAgain',
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          builder: (_, child) => FAnimatedTheme(
            data: themeProvider.currentTheme,
            child: FToaster(child: child!),
          ),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
