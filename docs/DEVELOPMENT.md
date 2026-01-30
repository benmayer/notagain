# Development Workflows

This guide covers common development tasks and workflows in NotAgain.

## Before Starting

Ensure you've completed [Getting Started](./GETTING_STARTED.md):
- ✅ Flutter SDK installed
- ✅ Dependencies: `flutter pub get`
- ✅ `.env` configured with Supabase credentials
- ✅ App runs: `flutter run`

## Common Workflows

### Adding a New Screen

1. **Create the screen file:**
   ```bash
   touch lib/screens/[feature]/[screen_name]_screen.dart
   ```

2. **Use the screen template:**
   ```dart
   import 'package:flutter/material.dart';
   import 'package:forui/forui.dart';
   import 'package:go_router/go_router.dart';
   import '../../core/logging/app_logger.dart';

   class MyScreen extends StatefulWidget {
     const MyScreen({super.key});

     @override
     State<MyScreen> createState() => _MyScreenState();
   }

   class _MyScreenState extends State<MyScreen> {
     @override
     void initState() {
       super.initState();
       AppLogger.info('MyScreen initialized', tag: 'Navigation');
     }

     @override
     Widget build(BuildContext context) {
       return FScaffold(
         header: FHeader.nested(
           title: const Text('My Screen'),
           prefixes: [
             FHeaderAction.back(onPress: () => context.pop()),
           ],
         ),
         child: SafeArea(
           child: SingleChildScrollView(
             child: Column(
               children: [
                 // Your content here
               ],
             ),
           ),
         ),
       );
     }
   }
   ```

3. **Add route to `lib/routing/app_router.dart`:**
   ```dart
   GoRoute(
     path: '/my-screen',
     name: 'myScreen',
     pageBuilder: (BuildContext context, GoRouterState state) {
       return CupertinoPageWithGesture<void>(
         name: 'myScreen',
         child: const MyScreen(),
       );
     },
   ),
   ```

4. **Navigate from another screen:**
   ```dart
   // Screen-to-screen navigation (maintains history)
   context.push('/my-screen');
   
   // Or state change (clears stack)
   context.go('/my-screen');
   ```

5. **Key considerations:**
   - Use `FScaffold` + `FHeader` (not Material Scaffold/AppBar)
   - Use `CupertinoPageWithGesture` for nested screens (enables swipe-back)
   - Use `CupertinoPage` for root routes only
   - Log screen initialization for debugging: `AppLogger.info(..., tag: 'Navigation')`
   - Use `context.pop()` for back button (not `context.go()`)

**See also:** [Routing Guide](./guides/ROUTING.md)

### Creating a Reusable Component

1. **Create the component file:**
   ```bash
   touch lib/widgets/[feature]/[component_name].dart
   ```

2. **Use Forui components (CRITICAL):**
   - Check [forui.dev](https://forui.dev/) FIRST
   - Use `FButton`, `FTextFormField`, `FCard`, etc.
   - Never use Material or Cupertino wrappers

3. **Example component:**
   ```dart
   import 'package:flutter/material.dart';
   import 'package:forui/forui.dart';

   /// ProfileCard - Display user profile information
   class ProfileCard extends StatelessWidget {
     final String name;
     final String email;
     final VoidCallback onEdit;

     const ProfileCard({
       required this.name,
       required this.email,
       required this.onEdit,
       super.key,
     });

     @override
     Widget build(BuildContext context) {
       return FCard(
         child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
             children: [
               Text(name, style: context.theme.typography.lg),
               SizedBox(height: 8),
               Text(email, style: context.theme.typography.sm),
               SizedBox(height: 16),
               FButton(
                 onPress: onEdit,
                 child: const Text('Edit Profile'),
               ),
             ],
           ),
         ),
       );
     }
   }
   ```

4. **Key considerations:**
   - Use `context.theme.colors` for colors
   - Use `context.theme.typography` for text styles
   - Document with docstring and usage example
   - Keep components small and single-purpose
   - Use `const` where possible for performance

**See also:** [Components Guide](./guides/COMPONENTS.md)

### Adding Authentication

Authentication is already implemented. To understand the flow:

1. **Review auth files:**
   - `lib/providers/auth_provider.dart` - State management
   - `lib/services/supabase_service.dart` - Backend integration
   - `lib/screens/auth/` - UI screens

2. **Common tasks:**
   ```dart
   // Login
   final result = await authProvider.login(email, password);
   if (result.isSuccess) {
     context.go('/home');
   }

   // Signup
   final result = await authProvider.signup(email, password, fullName);
   if (result.isSuccess) {
     context.push('/onboarding');
   }

   // Logout
   await authProvider.logout();
   context.go('/');
   ```

**See also:** [AUTH_IMPLEMENTATION.md](./reference/AUTH_IMPLEMENTATION.md)

### Managing State with Provider

NotAgain uses Provider pattern for reactive state management.

1. **Create a provider:**
   ```dart
   import 'package:flutter/foundation.dart';
   import '../models/user.dart';

   class UserProvider extends ChangeNotifier {
     User? _user;
     bool _isLoading = false;

     User? get user => _user;
     bool get isLoading => _isLoading;

     Future<void> updateUser(User newUser) async {
       _isLoading = true;
       notifyListeners();

       try {
         _user = newUser;
         // Save to backend
       } finally {
         _isLoading = false;
         notifyListeners();
       }
     }
   }
   ```

2. **Register in `lib/main.dart`:**
   ```dart
   MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => AuthProvider()),
       ChangeNotifierProvider(create: (_) => UserProvider()),
     ],
     child: const MyApp(),
   )
   ```

3. **Use in widgets:**
   ```dart
   // Watch for changes (rebuilds when state changes)
   final user = context.watch<UserProvider>().user;

   // Read once (no rebuild)
   final provider = context.read<UserProvider>();
   ```

**See also:** [State Management Guide](./guides/STATE_MANAGEMENT.md)

### Using Logging

Use `AppLogger` instead of `debugPrint()`:

```dart
import '../../core/logging/app_logger.dart';

// Info level
AppLogger.info('User logged in', tag: 'AuthProvider');

// Warning level
AppLogger.warning('Profile fetch slow', tag: 'ProfileProvider');

// Error level
AppLogger.error('Login failed: ${e.message}', tag: 'AuthProvider', error: e);
```

**Key benefits:**
- Structured logging with log levels
- Easier to filter in production
- Screen lifecycle tracking for debugging
- Tag-based categorization

**See also:** [Logging Guide](./guides/LOGGING.md)

### Testing Navigation

Critical for preventing navigation crashes:

1. **Test push navigation:**
   ```dart
   // Tap button to navigate
   await tester.tap(find.byText('Next'));
   await tester.pumpAndSettle();
   
   // Verify new screen appears
   expect(find.byType(NextScreen), findsOneWidget);
   ```

2. **Test back button:**
   ```dart
   // Tap back button
   await tester.tap(find.byIcon(Icons.arrow_back));
   await tester.pumpAndSettle();
   
   // Verify previous screen appears
   expect(find.byType(PreviousScreen), findsOneWidget);
   ```

3. **Manual testing on device:**
   - ✅ Tap screen transition button
   - ✅ Tap back button
   - ✅ Swipe from left edge (iOS)
   - ✅ Verify smooth navigation

**Common issue:** Stack corruption ("popped last page") - see [Routing Guide](./guides/ROUTING.md)

### Code Quality Checks

Before committing:

```bash
# Format code
flutter format lib/

# Analyze for warnings
flutter analyze

# Run tests
flutter test

# Check for unused code
flutter pub outdated
```

**All must pass:** `flutter analyze` should show **"No issues found!"**

## Project Patterns

### Result<T> Pattern

All backend operations return `Result<T>`:

```dart
final result = await authProvider.login(email, password);

if (result.isSuccess) {
  // Access data
  final user = result.data;
  print('Logged in as: ${user?.email}');
} else {
  // Handle error
  print('Error: ${result.error?.message}');
}
```

### Navigation Pattern

**Screen progression:** Use `push()` → maintains stack for swipe-back
**State change:** Use `go()` → clears stack

```dart
// Navigation within a flow
context.push('/next-screen');      // Can swipe back

// Auth state change
context.go('/home');               // Can't swipe back to login

// Back button
context.pop();                     // Always pop, never go()
```

### Error Handling

Consistent error handling with Forui toasts:

```dart
if (result.isSuccess) {
  // Handle success
} else {
  showFToast(
    context: context,
    alignment: FToastAlignment.bottomCenter,
    icon: Icon(FIcons.triangleAlert, color: context.theme.colors.destructive),
    title: const Text('Operation Failed'),
    description: Text(result.error?.message ?? 'Unknown error'),
  );
}
```

## Debugging Tips

### Enable Verbose Logging

```bash
flutter run -v
```

Shows detailed logs from Flutter, Dart, and the app.

### Check App Logs

```bash
flutter logs
```

Streams app logs in real-time (includes `AppLogger` output).

### Break Points and Debugger

```bash
flutter run --debug
# In VS Code: F5 to set breakpoints
```

### Hot Reload for Quick Iteration

```bash
# While app is running
r          # Hot reload (keeps state)
R          # Hot restart (resets state)
q          # Quit
```

### Test on Physical Device

```bash
flutter run -d [device_id]
```

More realistic testing (actual swipe gestures, performance).

## File Organization

When adding files:
- **Screens:** `lib/screens/[feature]/[screen_name]_screen.dart`
- **Widgets:** `lib/widgets/[feature]/[component_name].dart`
- **Providers:** `lib/providers/[domain]_provider.dart`
- **Models:** `lib/models/[model_name].dart`
- **Services:** `lib/services/[service_name].dart`
- **Tests:** `test/[type]/[unit]/[test_name]_test.dart`

## Next Steps

- **Learn routing patterns:** [Routing Guide](./guides/ROUTING.md)
- **Build UI components:** [Components Guide](./guides/COMPONENTS.md)
- **Understand architecture:** [ARCHITECTURE.md](./ARCHITECTURE.md)

---

**Stuck?** Check the guides or create an issue on GitHub.
