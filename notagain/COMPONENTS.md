# Notagain - Component Documentation

## UI Components Overview

All reusable UI components live in `lib/widgets/` organized by feature area. Below is documentation for each component and how to use them.

### Shared Components (`lib/widgets/shared/`)

#### `CustomPrimaryButton`
**Purpose**: Primary action button with brand color (#1fbacb)
**Usage**: CTAs, main action buttons, confirmations

```dart
CustomPrimaryButton(
  label: 'Create Rule',
  onPressed: () { /* Handle create */ },
  isLoading: false,  // Optional loading state
)
```

#### `CustomSecondaryButton`
**Purpose**: Secondary action button, less emphasis than primary
**Usage**: Alternative actions, back buttons, secondary CTAs

```dart
CustomSecondaryButton(
  label: 'Cancel',
  onPressed: () { /* Handle cancel */ },
)
```

#### `CustomTertiaryButton`
**Purpose**: Minimal button, text-only with brand color
**Usage**: Inline actions, optional actions, links

```dart
CustomTertiaryButton(
  label: 'Learn More',
  onPressed: () { /* Handle learn more */ },
)
```

### App Bar

#### `NotagainAppBar`
**Purpose**: Custom app bar with theme support and consistent styling
**Features**: Title, back button, actions menu

```dart
NotagainAppBar(
  title: 'Create Blocking Rule',
  showBackButton: true,
  onBackPressed: () => Navigator.pop(context),
  actions: [
    IconButton(
      icon: Icon(Icons.help),
      onPressed: () { /* Show help */ },
    ),
  ],
)
```

### Feature-Specific Components

#### Home Components (`lib/widgets/home/`)

##### `ScreenTimeChart`
**Purpose**: Visualize daily/weekly screen time trends

```dart
ScreenTimeChart(
  data: usageProvider.weeklyData,
  period: 'week',  // 'day', 'week', 'month'
)
```

##### `AppUsageCard`
**Purpose**: Display individual app usage time

```dart
AppUsageCard(
  appName: 'Instagram',
  duration: Duration(hours: 2, minutes: 30),
  onTap: () { /* Open app details */ },
)
```

#### Start Components (`lib/widgets/start/`)

##### `RuleCard`
**Purpose**: Display a blocking rule with enable/disable toggle

```dart
RuleCard(
  rule: blockingRule,
  onEdit: () { /* Open edit screen */ },
  onDelete: () { /* Delete rule */ },
  onToggle: (isEnabled) { /* Toggle blocking */ },
)
```

##### `SchedulePicker`
**Purpose**: Pick time windows and days for blocking schedules

```dart
SchedulePicker(
  initialSchedule: existingSchedule,
  onScheduleSelected: (schedule) { /* Handle selection */ },
)
```

##### `AppSelector`
**Purpose**: Multi-select list of installed apps to block

```dart
AppSelector(
  selectedApps: selectedApps,
  onAppsSelected: (apps) { /* Update selection */ },
)
```

#### Profile Components (`lib/widgets/profile/`)

##### `ProfileHeader`
**Purpose**: Display user profile picture and name

```dart
ProfileHeader(
  user: currentUser,
  onEditProfile: () { /* Open edit */ },
)
```

##### `PreferenceToggle`
**Purpose**: Toggle setting preferences

```dart
PreferenceToggle(
  label: 'Dark Mode',
  value: isDarkMode,
  onChanged: (value) { /* Update setting */ },
)
```

#### Auth Components (`lib/widgets/auth/`)

##### `AuthForm`
**Purpose**: Email/password input fields for login/signup

```dart
AuthForm(
  mode: 'login',  // 'login' or 'signup'
  onSubmit: (email, password) { /* Handle auth */ },
)
```

##### `SocialAuthButton`
**Purpose**: Apple Sign-In and Google Sign-In buttons

```dart
SocialAuthButton(
  provider: 'apple',  // 'apple' or 'google'
  onPressed: () { /* Handle social login */ },
)
```

### Theme-Aware Components

All Forui components automatically adapt to light/dark mode through:
1. **AppTheme** configuration in `core/theme/app_theme.dart`
2. **ThemeProvider** for mode switching
3. **Consumer<ThemeProvider>** pattern for listening to changes

**Example**: Using Forui button with automatic theming
```dart
FButton.primary(
  label: 'Next',
  onPress: () { /* Handle action */ },
)
// Automatically uses primary color (#1fbacb) in light/dark modes
```

## Adding New Components

### Component Checklist
- [ ] Create file in `lib/widgets/[feature_area]/[component_name].dart`
- [ ] Add comprehensive inline documentation
- [ ] Make component theme-aware (respect light/dark modes)
- [ ] Add example usage in the component doc
- [ ] Create widget test in `test/widget/`
- [ ] Update this documentation

### Component Template
```dart
/// [ComponentName]
/// 
/// Purpose: Brief description of what this component does
/// 
/// Features:
/// - Feature 1
/// - Feature 2
/// 
/// Example:
/// ```dart
/// ComponentName(
///   property: value,
///   onAction: () { /* Handle */ },
/// )
/// ```

import 'package:flutter/material.dart';

class ComponentName extends StatelessWidget {
  final String property;
  final VoidCallback onAction;

  const ComponentName({
    super.key,
    required this.property,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Implementation
    );
  }
}
```

## Screen Documentation

### Home Screen (`screens/home/home_screen.dart`)
**Purpose**: Main dashboard showing screen time overview
**Key Widgets**: ScreenTimeChart, AppUsageCard, DailyStats (from `widgets/home/`)
**State Management**: UsageProvider (fetches usage data)
**Navigation**: Links to start and profile screens

### Login Screen (`screens/auth/login_screen.dart`)
**Purpose**: User email/password authentication
**Key Widgets**: AuthForm, SocialAuthButton (from `widgets/auth/`)
**State Management**: AuthProvider (handles login state)
**Navigation**: Onboarding or Home on success

### Rule Creation Screen (`screens/start/rule_creation_screen.dart`)
**Purpose**: Create new blocking rules
**Key Widgets**: AppSelector, SchedulePicker, RuleForm (from `widgets/start/`)
**State Management**: RulesProvider (saves rules)
**Navigation**: Back to rules list on save

### Profile Screen (`screens/profile/profile_screen.dart`)
**Purpose**: User profile and account settings
**Key Widgets**: ProfileHeader, PreferenceToggle (from `widgets/profile/`)
**State Management**: ProfileProvider (loads user data)
**Navigation**: Settings screen, logout

### Analytics Screen (`screens/profile/analytics_screen.dart`)
**Purpose**: Detailed usage reports and trends
**Key Widgets**: ScreenTimeChart (from `widgets/home/`), UsageBreakdown, TrendIndicators
**State Management**: AnalyticsProvider (loads analytics data)
**Navigation**: Accessible from Profile screen

## Styling & Theming Guidelines

### Colors
- **Primary**: Use `AppColors.primary` (#1fbacb) for CTAs and highlights
- **Text**: Use `AppColors.lightOnBackground` / `AppColors.darkOnBackground` based on mode
- **Borders**: Use `AppColors.lightBorder` / `AppColors.darkBorder`

### Typography
Use Material 3 text styles from `Theme.of(context).textTheme`:
- Headings: `.headlineSmall`, `.headlineMedium`, `.headlineLarge`
- Body: `.bodySmall`, `.bodyMedium`, `.bodyLarge`
- Labels: `.labelSmall`, `.labelMedium`, `.labelLarge`

### Spacing
- Use `SizedBox` for fixed spacing
- Common: 8, 12, 16, 24, 32 logical pixels
- Use padding/margin consistently

### Dark Mode Support
Wrap theme-dependent code in:
```dart
final isDarkMode = Theme.of(context).brightness == Brightness.dark;
final color = isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
```

Or use Consumer pattern:
```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {
    return MyWidget(isDarkMode: themeProvider.isDarkMode);
  },
)
```
