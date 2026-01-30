# State Management Guide

NotAgain uses **Provider pattern** for reactive state management. This guide covers how to work with state in the app.

## Overview

State in NotAgain is managed through `ChangeNotifier` providers in `lib/providers/`:
- **AuthProvider** - Authentication and user session
- **OnboardingProvider** - Multi-step onboarding flow
- **ThemeProvider** - Light/dark mode preference
- **SettingsProvider** - User settings and preferences

## Core Concepts

### ChangeNotifier Pattern

```dart
import 'package:flutter/foundation.dart';

class MyProvider extends ChangeNotifier {
  String _data = '';
  
  String get data => _data;
  
  void updateData(String newData) {
    _data = newData;
    notifyListeners();  // Notify all listeners of change
  }
}
```

**Key points:**
- Extend `ChangeNotifier`
- Expose state via getters
- Call `notifyListeners()` when state changes
- Listeners (widgets) are notified and can rebuild

### Registration

All providers are registered in `lib/main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => OnboardingProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ],
  child: const MyApp(),
)
```

**Why in main.dart?**
- Providers available throughout the entire app
- Single instance shared by all screens
- Persists state across navigation

## Using Providers in Widgets

### Watch Pattern (Reactive)

Use `context.watch<Provider>()` when you need **reactive updates**:

```dart
// Widget rebuilds whenever provider data changes
final user = context.watch<AuthProvider>().user;
final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

// Use the data in build
Text('Hello, ${user?.email}'),
```

**When to use:**
- Displaying state that changes frequently
- Showing loading spinners
- Conditional rendering based on state

### Read Pattern (One-time)

Use `context.read<Provider>()` when you need **one-time access**:

```dart
// Doesn't rebuild when provider changes
final authProvider = context.read<AuthProvider>();

// Trigger action
onPress: () async {
  final result = await authProvider.login(email, password);
  if (result.isSuccess) {
    context.go('/home');
  }
}
```

**When to use:**
- Calling methods on providers
- Event handlers (button taps)
- Navigation logic

### Inside Build vs Event Handlers

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ Use watch in build for reactive updates
    final isLoading = context.watch<AuthProvider>().isLoading;
    
    return Column(
      children: [
        if (isLoading) const FCircularProgress(),
        
        FButton(
          onPress: () async {
            // ✅ Use read in event handler
            final authProvider = context.read<AuthProvider>();
            final result = await authProvider.login(email, password);
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
```

## Built-in Providers

### AuthProvider

Manages authentication state and user session.

```dart
class AuthProvider extends ChangeNotifier {
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Login with email/password
  Future<Result<User>> login({required String email, required String password})
  
  // Signup with email/password
  Future<Result<User>> signup({
    required String email,
    required String password,
    String? fullName,
  })
  
  // OAuth Sign-In
  Future<Result<User>> signInWithApple()
  Future<Result<User>> signInWithGoogle()
  
  // Logout
  Future<void> logout()
  
  // Restore session (auto-called on app start)
  Future<void> restoreSession()
}
```

**Usage:**

```dart
// In widget
final authProvider = context.read<AuthProvider>();

// Login
final result = await authProvider.login(
  email: 'user@example.com',
  password: 'password123',
);

if (result.isSuccess) {
  final user = result.data;
  context.go('/home');  // or push('/onboarding')
} else {
  // Show error
  showFToast(...);
}
```

### OnboardingProvider

Manages multi-step onboarding flow.

```dart
class OnboardingProvider extends ChangeNotifier {
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> nextStep()      // Advance to next step
  Future<void> previousStep()  // Go back to previous step
  Future<void> completeOnboarding()  // Mark onboarding as complete
}
```

**Usage:**

```dart
// In onboarding screen
final onboarding = context.read<OnboardingProvider>();

// Advance to next step
onPress: () async {
  await onboarding.nextStep();
  context.push('/onboarding/step2');
}

// Complete onboarding
onPress: () async {
  await onboarding.completeOnboarding();
  context.go('/home');
}
```

### ThemeProvider

Manages light/dark mode preference.

```dart
class ThemeProvider extends ChangeNotifier {
  bool get isDarkMode => _isDarkMode;
  FThemeData get currentTheme => _currentTheme;
  
  Future<void> setDarkMode(bool isDark)  // Set mode explicitly
  Future<void> toggleTheme()             // Toggle between modes
}
```

**Usage:**

```dart
// In widget - display current mode
final isDark = context.watch<ThemeProvider>().isDarkMode;

// Toggle dark mode
onPress: () {
  context.read<ThemeProvider>().toggleTheme();
},
```

### SettingsProvider

Manages user settings and preferences.

```dart
class SettingsProvider extends ChangeNotifier {
  bool get notificationsEnabled => _notificationsEnabled;
  String get theme => _theme;
  
  Future<void> setNotificationsEnabled(bool enabled)
  Future<void> setTheme(String theme)
}
```

## Creating a New Provider

### Step 1: Create the Provider File

```dart
// lib/providers/my_feature_provider.dart
import 'package:flutter/foundation.dart';
import '../models/my_model.dart';
import '../services/my_service.dart';

class MyFeatureProvider extends ChangeNotifier {
  final MyService _service = MyService();
  
  MyModel? _data;
  bool _isLoading = false;
  String? _error;
  
  MyModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _data = await _service.fetchData();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Step 2: Register in main.dart

```dart
MultiProvider(
  providers: [
    // ... existing providers
    ChangeNotifierProvider(create: (_) => MyFeatureProvider()),
  ],
  child: const MyApp(),
)
```

### Step 3: Use in Widgets

```dart
// Watch for data changes
final data = context.watch<MyFeatureProvider>().data;
final isLoading = context.watch<MyFeatureProvider>().isLoading;

// Call methods
onPress: () {
  context.read<MyFeatureProvider>().loadData();
}
```

## Error Handling Pattern

Use `Result<T>` for structured error responses:

```dart
class Result<T> {
  final T? data;
  final AppError? error;
  final bool isSuccess;
  
  // Success: Result.success(data)
  // Failure: Result.failure(error)
}

// In provider
Future<Result<User>> login({required String email, required String password}) async {
  try {
    final user = await _service.login(email, password);
    return Result.success(user);
  } catch (e) {
    return Result.failure(AppError(message: e.toString()));
  }
}

// In widget
final result = await provider.login(email, password);
if (result.isSuccess) {
  // Use result.data
} else {
  // Show result.error?.message
}
```

## Performance Tips

### Avoid Rebuilds

Use `context.read()` instead of `context.watch()` when you don't need reactivity:

```dart
// ❌ WRONG - rebuilds entire widget whenever auth changes
final isLoading = context.watch<AuthProvider>().isLoading;

// ✅ CORRECT - only rebuild if you're displaying loading state
if (context.watch<AuthProvider>().isLoading) {
  return const LoadingWidget();
}
```

### Scope Providers

Keep provider scope as specific as possible:

```dart
// ❌ WRONG - entire app rebuilds when theme changes
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
)

// ✅ CORRECT - only theme-dependent widgets rebuild
Consumer<ThemeProvider>(
  builder: (context, theme, child) {
    return Container(
      color: theme.currentTheme.colors.background,
      child: child,
    );
  },
  child: const MyWidget(),
)
```

### Memoize Complex Computations

Cache expensive operations:

```dart
class DataProvider extends ChangeNotifier {
  List<User> _users = [];
  List<User>? _filtered;
  String _searchQuery = '';
  
  List<User> get filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    
    // Only recompute if search query changed
    if (_filtered == null) {
      _filtered = _users
        .where((u) => u.name.contains(_searchQuery))
        .toList();
    }
    return _filtered!;
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    _filtered = null;  // Invalidate cache
    notifyListeners();
  }
}
```

## Testing Providers

```dart
void main() {
  test('AuthProvider.login sets user on success', () async {
    final provider = AuthProvider();
    
    final result = await provider.login(
      email: 'test@example.com',
      password: 'password',
    );
    
    expect(result.isSuccess, true);
    expect(provider.user, isNotNull);
    expect(provider.user?.email, 'test@example.com');
  });
}
```

## Best Practices

✅ **DO:**
- Call `notifyListeners()` after every state change
- Use `context.watch()` in build methods
- Use `context.read()` in event handlers
- Keep providers focused on one domain
- Use `Result<T>` for error handling
- Log important state changes with `AppLogger`
- Handle async operations with try/catch

❌ **DON'T:**
- Access state directly (`provider._data` - use getters)
- Update state without calling `notifyListeners()`
- Mix `watch()` and `read()` inconsistently
- Create too many small providers
- Ignore errors from async operations
- Forget to handle loading states

---

**Next:** [Routing Guide](./ROUTING.md) for navigation patterns.
