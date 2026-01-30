# Notagain - Architecture & Project Documentation

## Overview
Notagain is a screen time control app that helps users break unconscious usage patterns by blocking apps and websites. Built with Flutter, it features authentication, blocking rule management, analytics, and native platform integration for iOS/Android blocking functionality.

## Project Structure

```
notagain/
├── lib/
│   ├── main.dart                    # App entry point, theming, and FAnimatedTheme 
│   ├── main_layout.dart             # Shared layout with Scaffold, header, bottom nav
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart      # Color palette and constants (DEPRECATED - use Forui theme)
│   │   │   ├── theme_provider.dart  # Theme state management (Provider) with FThemeData
│   │   │   └── README.md            # Theming documentation
│   │   ├── constants/               # App-wide constants (API keys, timeouts, etc)
│   │   ├── logging/
│   │   │   └── app_logger.dart      # Structured logging with AppLogger.info/warning/error
│   │   └── utils/                   # Utility functions (formatters, validators, etc)
│   ├── routing/
│   │   └── app_router.dart          # GoRouter config with ShellRoute for main nav, auth-gated redirect logic, flattened onboarding routes
│   ├── screens/                     # Top-level screens organized by feature
│   │   ├── auth/
│   │   │   ├── welcome_screen.dart  # Entry point - Sign In or Get Started
│   │   │   ├── login_screen.dart    # Email/password sign in with social auth
│   │   │   └── signup_screen.dart   # Email/password registration
│   │   ├── onboarding/
│   │   │   ├── onboarding_step1_screen.dart # Step 1: Name input, saves to database
│   │   │   └── onboarding_step2_screen.dart # Step 2: Avatar upload (optional, skippable)
│   │   ├── home/
│   │   │   └── home_screen.dart     # Dashboard content, Entry for the user journey
│   │   ├── start/
│   │   │   └── start_screen.dart    # Blocking rules management content only
│   │   ├── profile/
│   │   │   ├── profile_screen.dart  # User profile display
│   │   │   └── README.md            # Profile feature documentation
│   │   └── settings/
│   │       ├── settings_screen.dart # User settings with FTileGroup sections, logout
│   │       └── settings_stubs.dart  # Settings sub-screens (Device, Help, FAQs, etc)
│   ├── widgets/                     # Reusable UI components
│   │   ├── auth/                    # Auth-specific widgets (form fields, buttons)
│   │   ├── home/                    # Home screen widgets (navigation, stats)
│   │   ├── profile/                 # Profile widgets
│   │   ├── settings/                # Settings widgets
│   │   └── start/                   # Start screen widgets
│   ├── models/                      # Data models and DTOs
│   │   ├── user.dart                # User model and AuthResponse
│   │   ├── blocking_rule.dart       # Blocking rule model
│   │   └── result.dart              # Generic Result<T> and AppError types for standardized responses
│   ├── providers/                   # State management (Provider pattern)
│   │   ├── auth_provider.dart       # Authentication state, returns Result<User>, fetches profile on login
│   │   ├── onboarding_provider.dart # Multi-step onboarding state with SharedPreferences persistence
│   │   ├── settings_provider.dart   # User settings and preferences
```
│   │   └── settings_provider.dart   # User preferences state
│   ├── services/                    # Backend and platform services
│   │   ├── supabase_service.dart    # Supabase integration (auth, CRUD, analytics), returns Result<T>
│   │   └── native_blocking_service.dart # iOS Screen Time API bridge
│   └── main.dart                    # App bootstrap with FAnimatedTheme + FToaster
```
│   │   ├── profile/
│   │   │   ├── profile_header.dart
│   │   │   └── preference_toggle.dart
│   │   └── shared/
│   │       ├── custom_button.dart
│   │       ├── app_bar.dart
│   │       └── ...other shared widgets
│   ├── providers/                   # All state management
│   │   ├── theme_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── usage_provider.dart
│   │   ├── rules_provider.dart
│   │   ├── profile_provider.dart
│   │   └── analytics_provider.dart
│   ├── models/                      # All data models
│   │   ├── user.dart
│   │   ├── app_usage.dart
│   │   ├── blocking_rule.dart
│   │   └── profile.dart
│   └── services/
│       ├── supabase_service.dart    # Backend integration (auth, rules, analytics)
│       └── native_blocking_service.dart  # iOS Screen Time API integration
├── android/
│   └── [Native code for Device Admin blocking (future expansion)]
├── ios/
│   └── [Native code for Screen Time API integration]
├── test/
│   ├── unit/                        # Authentication, business logic tests
│   ├── widget/                      # Component and screen tests
│   └── integration/                 # End-to-end app flow tests
├── pubspec.yaml                     # Dependencies and project metadata
└── README.md                        # This file
```

## Key Features

### 1. **Authentication** (`screens/auth/`)

**Flow**:
```
Welcome (/) 
  ├─ "Get Started" → Sign Up (/signup)
  └─ "Sign In" → Login (/login)
     └─ Back button → Welcome
```

**Screens**:
- **WelcomeScreen**: Entry point with app logo, tagline, and two CTA buttons
- **LoginScreen**: Email/password auth + Apple/Google Sign-In with Forui toasts
- **SignupScreen**: Registration with name, email, password confirmation, terms agreement, Forui toasts

**Features**:
- Email/password registration and login
- Social authentication (Apple Sign-In, Google Sign-In)
- Session management with Supabase Auth
- Secure token storage
- FHeader.nested() for consistent navigation
- Bottom-aligned navigation links between auth screens
- Pure Forui theming (no Material components)
- **Error Handling**: Uses standardized `Result<User>` type with Forui toast notifications
  - Toasts positioned at bottom center with minimum width (300px)
  - Icons: `FIcons.triangleAlert` with theme-aware colors
  - Auto-dismiss after 4 seconds

**Components**: WelcomeScreen, LoginScreen, SignupScreen, AuthProvider, SupabaseService

### 2. **Onboarding** (`features/onboarding`)
- Welcome and app introduction
- Permission request flows:
  - **iOS**: Screen Time API access
  - **Android**: Device Admin, Usage Stats, VPN (if applicable)
- Permission denial handling with clear guidance
- Onboarding completion tracking

**Components**: PermissionRequestScreen, WelcomeScreen, OnboardingProvider, NativePermissionService

### 3. **Home Dashboard** (`features/home`)
- Today's screen time summary
- Top used apps list
- Daily/weekly/monthly usage trends
- Quick access to create blocking rules
- Bottom navigation hub

**Components**: HomeScreen, ScreenTimeChart, AppUsageCard, DailyStats

### 4. **Blocking Rules** (`screens/start`)
- Create/edit/delete blocking rules
- Select apps to block
- Configure schedule (specific times, days)
- Set break intervals and pause periods
- Enable/disable rules without deleting
- View active blocking rules

**Components**: RuleCreationScreen, RuleEditScreen, SchedulePicker, RuleCard, RuleForm

### 5. **Profile & Analytics** (`screens/profile`)
- User profile information
- Detailed usage analytics:
  - Daily/weekly/monthly breakdowns
  - Most used applications
  - Screen time trends over time
- Account settings
- Blocking rules overview
- App preferences (notifications, theme)
- Logout functionality

**Components**: ProfileScreen, SettingsScreen, AnalyticsReportScreen, UsageChart, PreferenceToggle

## Routing System (`lib/routing/app_router.dart`)

**GoRouter Configuration**:
- **Initial route**: `/` (Welcome screen for unauthenticated users)
- **Auth-gated redirect logic**:
  - Unauthenticated → Allow `/`, `/login`, `/signup`; redirect other routes to `/`
  - Authenticated → Redirect auth screens to `/home`; allow all other routes
- **ShellRoute for Main Navigation**: `/home`, `/start`, `/profile` wrapped in `ShellRoute` with `MainLayout`
  - Uses `NoTransitionPage` for instant tab switching (no page transition animations)
  - Maintains tab state when switching between Home, Start, Profile
  - Deep linking supported: `/home`, `/start`, `/profile` are separate routes

**Route Structure**:
```
/                          # Welcome (unauthenticated entry point)
/login                     # Sign In screen
/signup                    # Sign Up screen

ShellRoute (MainLayout)    # Main app scaffold with header + bottom nav
├─ /home                   # Home dashboard (NoTransitionPage)
├─ /start                  # Blocking rules (NoTransitionPage)
└─ /profile                # User profile (NoTransitionPage)

/settings                  # Settings (protected, outside main nav)
├─ /settings/device-settings
├─ /settings/help-support
├─ /settings/faqs
├─ /settings/feedback
├─ /settings/terms-of-service
└─ /settings/privacy-policy

/onboarding               # Post-auth permissions (future)
```

## Core Systems

### Theming System (`core/theme/`) & Layout Separation

**Pure Forui Implementation**:
- **FThemes**: Built-in Forui theme families (slate, zinc, amber, emerald, rose)
  - Each family has `.light` and `.dark` variants
  - Automatic light/dark mode switching
- **ThemeProvider**: State management for light/dark mode switching
  - Uses `FThemeData` getter to provide current theme
  - Persists user preference with SharedPreferences
  - Notifies app of theme changes via `notifyListeners()`
- **App Root**: `FAnimatedTheme` wrapper for smooth theme transitions
  - `FToaster` for toast notifications

**Layout Separation** (`lib/main_layout.dart`):
- **MainLayout**: Extracted Scaffold, FHeader, and FBottomNavigationBar logic
- Located in `lib/` root directory (not nested in screens)
- Used by ShellRoute to wrap `/home`, `/start`, `/profile` routes
- Manages tab state and navigation between main app sections
- Single header builder that adapts based on current route
- Eliminates duplication and improves maintainability

**Key Principles**:
- ✅ **ONLY Forui components** - No Material components for styling
- ✅ **Theme-aware colors**: All text/icons use `context.theme.colors`
- ✅ **Theme-aware typography**: All text uses `context.theme.typography`
- ✅ **Forui icons**: Use `FIcons` (not Material `Icons`)
- ✅ **No custom theming**: Rely on built-in Forui theme system
- ✅ **Clean separation**: Screens contain only content, layout is centralized

**Usage Pattern**:
```dart
// Colors
Text('Hello', style: context.theme.typography.lg.copyWith(
  color: context.theme.colors.foreground
))

// Dividers & spacing
FDivider(color: context.theme.colors.border)

// Icons
Icon(FIcons.settings, color: context.theme.colors.mutedForeground)
```

### State Management (Provider)
- **ThemeProvider**: Manages light/dark mode
- **AuthProvider**: Handles authentication state and user session
- **RulesProvider**: CRUD operations for blocking rules
- **UsageProvider**: Fetches and caches app usage data
- **AnalyticsProvider**: Loads analytics reports and trends

All providers are located in `lib/providers/` for easy access and maintenance.

### Service Layer

#### SupabaseService (`services/supabase_service.dart`)
Centralized backend integration for:
- User authentication (email, Apple, Google)
- User profile management
- Blocking rules CRUD
- App usage tracking
- Blocked attempt logging
- Analytics queries

**Database Schema** (to be set up in Supabase):
```
users (id, email, created_at, updated_at)
profiles (id, user_id, full_name, avatar_url)
blocking_rules (id, user_id, app_name/url, schedule, enabled, created_at)
app_usage (id, user_id, app_name, duration, date)
blocked_attempts (id, user_id, rule_id, blocked_at)
```

#### NativeBlockingService (`services/native_blocking_service.dart`)
iOS-specific blocking functionality using platform channels:
- **iOS**: Screen Time API integration for app restrictions
- Uses managed app configuration and restrictions

**Methods**:
- `requestScreenTimeAccess()` - Request iOS Screen Time permission
- `blockApp(appBundleId, schedule)` - Enable blocking for an app
- `unblockApp(appBundleId)` - Disable blocking
- `getBlockedApps()` - List currently blocked apps

## Dependencies

### UI & Design
- **forui** (v0.16.1): Modern Forui component library with theming
- **flutter**: Core framework

### Backend & Data
- **supabase_flutter** (v2.0.0): Backend services (auth, database, realtime)
- **sqflite** (v2.3.0): Local SQLite database for offline data

### State Management & Storage
- **provider** (v6.4.0): Reactive state management
- **shared_preferences** (v2.2.2): Persistent user preferences

### Permissions & Device Access
- **permission_handler** (v11.4.4): Runtime permission management
- **device_apps** (v2.4.0): List installed apps

### Navigation
- **go_router** (v14.1.0): Declarative routing and deep linking

## Development Workflow

### Adding a New Feature
1. Create a new folder under `features/[feature_name]/`
2. Create sub-folders: `screens/`, `widgets/`, `providers/`, `models/`, `services/`
3. Add a `README.md` explaining the feature
4. Implement screens, state management, and models
5. Wire up to navigation and test

### Adding a Reusable Widget
1. Create the widget in `lib/widgets/`
2. Document with comments explaining usage
3. Test with widget tests in `test/widget/`

### Theme Customization
- Colors: Update `core/theme/app_colors.dart`
- Themes: Update `core/theme/app_theme.dart`
- Forui theming: Extend `AppTheme.forLightTheme()` or `forDarkTheme()`

## Design Principles

1. **Feature Isolation**: Each feature is self-contained with its own state, models, and services
2. **Single Responsibility**: Services, providers, and widgets have focused purposes
3. **Provider Pattern**: Use Provider for state management across features
4. **Reusability**: Common UI components go in `lib/widgets/`
5. **Type Safety**: Strong typing for models and DTO objects
6. **Documentation**: Every file includes inline documentation

## Error Handling & Result Types (`lib/models/result.dart`)

**Standardized Result Pattern**:
- **Result<T>**: Generic wrapper for async operation outcomes
  - `isSuccess` getter: true when error is null and data is not null
  - `isFailure` getter: opposite of isSuccess
  - Factory constructors: `Result.success(data)` and `Result.failure(error)`

**AppError Type**:
- **message**: User-friendly error description
- **exception**: Original exception object (for debugging)
- **code**: HTTP status code (if applicable)
- **errorCode**: Supabase error code string
- Factory: `AppError.fromException()` for converting exceptions to AppError

**Service Integration**:
- `SupabaseService` methods return `Result<T>` instead of raw values
- Proper error parsing from Supabase `AuthException`
- All auth errors wrapped with structured context (message, code, etc)

**Provider Integration**:
- Providers consume `Result<T>` from services
- Update `isLoading` and `error` state fields
- Expose results to UI for error handling

**UI Presentation**:
- Auth screens use Forui `showFToast()` to display errors
- Toast shows `result.error?.message` as subtitle
- Consistent error UX across authentication flows

### iOS (Primary Platform)
- Build: `flutter build ios`
- Archive: Use Xcode for archiving
- TestFlight: Upload via App Store Connect
- App Store: Submit for review

### Android (Future Expansion)
- Build: `flutter build appbundle`
- Play Console: Upload AAB file
- Testing: Firebase App Distribution for beta testing

## Native Integration

### iOS Screen Time Integration
**Location**: `ios/Runner/NativeBlockingService.swift`
- Implement Screen Time API calls
- Handle managed open restrictions
- Request and check Screen Time permissions

## Testing Strategy

### Unit Tests (`test/unit/`)
- Authentication flow
- Rule CRUD operations
- Analytics calculations
- Validators and formatters

### Widget Tests (`test/widget/`)
- Forui component rendering
- Theme application
- Navigation behavior
- User interactions

### Integration Tests (`test/integration/`)
- Complete auth flow
- Create rule → enable blocking
- Analytics loading and display
- Theme persistence

## Environment Setup

### Prerequisites
- Flutter SDK (latest stable)
- Xcode 15+ (for iOS)
- CocoaPods (for iOS dependencies)
- Supabase project (for backend)

### Initial Setup
1. `flutter pub get` - Install dependencies
2. Configure Supabase URL and key in constants
3. Set up native code in `ios/` folder
4. Run on device: `flutter run -d [device_id]`

## Future Enhancements

1. **Break Intervals**: Forced break timers with notification reminders
2. **Family Controls**: Parent-child app control (iOS)
3. **Usage Insights**: ML-driven insights and recommendations
4. **Cloud Sync**: Multi-device rule synchronization
5. **Offline First**: Enhanced offline functionality with local database
6. **Android Support**: Extend to Android platform with Device Admin implementation

## Troubleshooting

### Common Issues
- **Permission Denied**: Ensure app has requested and received necessary permissions
- **Blocking Not Working**: Verify native code is properly signed and installed
- **Theme Not Updating**: Check ThemeProvider is properly initialized
- **Data Sync Issues**: Verify Supabase connection and authentication

## Contributing
- Follow the existing folder structure
- Write inline documentation
- Run tests before committing
- Keep features isolated and modular
