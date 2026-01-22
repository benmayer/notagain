# Notagain - Component Documentation

## ⚠️ CRITICAL: Pure Forui Theming Architecture

**NotAgain uses PURE Forui theming only—NO Material theming.**

- Theme source: `FThemes.slate.light` / `FThemes.slate.dark` (Forui's built-in themes)
- Theme switching: `ThemeProvider` manages state and persists preference via SharedPreferences
- App wrapper: `FAnimatedTheme` + `FToaster` at root (lib/main.dart)
- All UI styling: Forui components only (buttons, inputs, scaffolds, etc.)
- Material `MaterialApp` exists ONLY for GoRouter routing infrastructure—UI inside is 100% Forui
- No Material theming (ThemeData, AppBar, Scaffold, etc.) for UI styling

**Why Pure Forui?**
1. ✅ Consistent design system enforcement
2. ✅ Single source of truth for themes
3. ✅ Simplified maintenance and style updates
4. ✅ Forui's minimalist design intentional and tested

---

## UI Components Overview

All reusable UI components live in `lib/widgets/` organized by feature area. Below is documentation for each component and how to use them.

### ⚠️ CRITICAL: Forui-First Component Rule

**All UI components MUST use Forui components as the primary choice.** Material components are strictly forbidden.

**Before creating ANY widget or adding ANY component:**
1. ✅ Check [forui.dev](https://forui.dev/) Themes and Controls documentation
2. ✅ Use the Forui equivalent if available (FButton, FTextField, FScaffold, etc.)
3. ❌ NEVER use Material, Cupertino, or custom widgets
4. ❌ If Forui doesn't have it, research alternative Forui patterns before asking

**Forui Component Checklist - CRITICAL: Check forui.dev FIRST**
- Buttons: `FButton` (primary, secondary, destructive, outline, ghost styles)
- Inputs: `FTextFormField`, `FCheckbox`, `FRadio`, `FSwitch`, `FSelect`, `FMultiSelect`
- Cards & Containers: `FCard`, `FAccordion`, `FTabs`
- Navigation: `FHeader`, `FHeaderAction`, `FBottomNavigationBar`, `FBreadcrumb`, `FSidebar`
- Scaffolds: `FScaffold` (with `header`, `footer`, `child` props)
- Overlays: `FDialog`, `FPopover`, `FToaster`
- Progress: `FCircularProgress`, `FLinearProgress`
- Utility: `FAvatar`, `FBadge`, `FDivider`, `FIcons` (icon set)

### Shared Components (`lib/widgets/shared/`)

> ⚠️ **Before adding custom button/form components**: Check if Forui has an equivalent. Use `FButton`, `FTextFormField`, `FCheckbox` instead of creating wrappers around Material components.

#### `CustomPrimaryButton` ⚠️ DEPRECATED
**Status**: Deprecated - Use `FButton(style: FButtonStyle.primary())` instead
**Purpose**: Primary action button with brand color (#1fbacb)
**Usage**: CTAs, main action buttons, confirmations

```dart
// ❌ OLD (Don't use)
CustomPrimaryButton(
  label: 'Create Rule',
  onPressed: () { /* Handle create */ },
  isLoading: false,
)

// ✅ NEW (Use Forui)
FButton(
  onPress: () { /* Handle create */ },
  style: FButtonStyle.primary(),
  prefix: isLoading ? const FCircularProgress() : null,
  child: const Text('Create Rule'),
)
```

#### `CustomSecondaryButton` ⚠️ DEPRECATED
**Status**: Deprecated - Use `FButton(style: FButtonStyle.secondary())` instead
**Purpose**: Secondary action button, less emphasis than primary
**Usage**: Alternative actions, back buttons, secondary CTAs

```dart
// ✅ Use Forui instead
FButton(
  onPress: () { /* Handle cancel */ },
  style: FButtonStyle.secondary(),
  child: const Text('Cancel'),
)
```

#### `CustomTertiaryButton` ⚠️ DEPRECATED
**Status**: Deprecated - Use `FButton(style: FButtonStyle.outline())` instead
**Purpose**: Minimal button, text-only with brand color
**Usage**: Inline actions, optional actions, links

```dart
// ✅ Use Forui instead
FButton(
  onPress: () { /* Handle learn more */ },
  style: FButtonStyle.outline(),
  child: const Text('Learn More'),
)
```

### App Bar

#### App Bar (Now using `FScaffold` with `FHeader`)
**Status**: Material AppBar deprecated - Use `FScaffold` with `FHeader` instead
**Purpose**: Consistent top bar with theme support
**Features**: Title, back button, actions menu

```dart
// ❌ OLD (Don't use Material AppBar)
Scaffold(
  appBar: AppBar(
    title: Text('My Screen'),
    actions: [IconButton(...)],
  ),
  body: child,
)

// ✅ NEW (Use FScaffold with FHeader)
FScaffold(
  header: FHeader(
    title: const Text('My Screen'),
    suffixes: [
      FHeaderAction(
        icon: const Icon(Icons.help),
        onPress: () { /* Handle action */ },
      ),
    ],
  ),
  child: child,
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
1. **FAnimatedTheme** wrapping the app at root (`lib/main.dart`)
2. **FThemes.slate** (light/dark) as the source of truth in `ThemeProvider`
3. **ThemeProvider** for mode switching (manages shared preferences persistence)
4. Automatic theming - no need to manually check brightness in Forui components

**Key Advantage**: When using Forui components, your UI automatically inherits Forui's slate theme colors and respects light/dark mode changes without additional code.

**Example**: Using Forui button with automatic theming
```dart
// ✅ Automatically uses Forui slate theme in light/dark modes
FButton(
  style: FButtonStyle.primary(),
  onPress: () { /* Handle action */ },
  child: const Text('Next'),
)

// ✅ Access theme colors anywhere in widget tree
final bgColor = context.theme.colors.background;
final fgColor = context.theme.colors.foreground;
```

**DO NOT** create custom Material button wrappers. Use Forui directly.

## Adding New Components

### Component Checklist
- [ ] **CRITICAL**: Check [forui.dev](https://forui.dev/) Themes and Controls documentation FIRST - use Forui component if available
- [ ] Create file in `lib/widgets/[feature_area]/[component_name].dart`
- [ ] Use ONLY Forui components - Material/Cupertino are forbidden
- [ ] Add comprehensive inline documentation with Forui usage examples
- [ ] Make component theme-aware through Forui's automatic theming (access via `context.theme`)
- [ ] Add example usage in the component doc showing Forui components
- [ ] Create widget test in `test/widget/`
- [ ] Update COMPONENTS.md documentation

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
/// 
/// Note: Uses Forui components for consistent theming and design system enforcement.

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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
    // ✅ Use Forui components (e.g., FButton, FCard, FTextField)
    return FCard(
      child: FButton(
        onPress: onAction,
        child: Text(property),
      ),
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

### Colors (Forui Slate Theme)
- Use `context.theme.colors` to access Forui's slate theme colors
- Primary actions: `context.theme.colors.primary` (blue from slate theme)
- Text: `context.theme.colors.foreground` (light/dark aware)
- Backgrounds: `context.theme.colors.background`, `context.theme.colors.surface`
- Borders: `context.theme.colors.border`
- Destructive: `context.theme.colors.destructive` (for errors, delete actions)

```dart
// ✅ Use Forui theme colors
FButton(
  style: (style) => style.copyWith(
    backgroundColor: context.theme.colors.primary,
  ),
  onPress: () {},
  child: const Text('Action'),
)
```

### Typography (Forui Typography)
- Access via `context.theme.typography`
- Sizes: `xs`, `sm`, `base`, `lg`, `xl`, `xxl`
- All text rendering automatically inherits Forui's configured font family and sizing

```dart
// ✅ Use Forui typography
Text(
  'Heading',
  style: context.theme.typography.lg,
)
```

### Spacing
- Use `SizedBox` with Forui spacing values
- Common: 4, 8, 12, 16, 24, 32 logical pixels
- Use padding/margin consistently via `Padding`, `Margin` (Forui utilities)

### Dark Mode Support
No manual dark mode checks needed—Forui handles it automatically:

```dart
// ✅ Colors automatically adapt to theme
Container(
  color: context.theme.colors.background,
  child: Text('Auto-themed', style: context.theme.typography.base),
)

// ❌ DON'T manually check brightness
final isDarkMode = Theme.of(context).brightness == Brightness.dark;
```

### Theme Switching
```dart
// Toggle dark mode
context.read<ThemeProvider>().toggleTheme();

// or Set explicitly
context.read<ThemeProvider>().setDarkMode(true);
```
  },
)
```
