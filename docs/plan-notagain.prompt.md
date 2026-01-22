# Notagain - Flutter App Project Plan

## Overview
Build a screen time control app that blocks other apps and websites, enabling users to take control of their screen time and break unconscious usage patterns.

## Brand & Design Guidelines
- **App Name**: Notagain
- **Primary Brand Color**: #1fbacb
- **Palette**: Black and white with light and dark mode support
- **UI Framework**: Forui components (https://forui.dev/)

## Feature Set

### 1. Authentication
- Account creation with email, Apple, and Google
- Login functionality
- Authentication provider: Supabase Auth

### 2. Onboarding
- Quick setup flow
- Permission requests for all required access
- Must handle: Device Admin (Android), Screen Time access (iOS), Notification permissions, Usage Stats, VPN permissions (if applicable)
- Permission denial fallback UX

### 3. Main Screens (Accessible via Bottom Navigation)
- **Home**: Dashboard with screen time overview
- **New**: Create/manage blocking rules
- **You**: Profile, reports, and settings
- *Current state: Black placeholder screens to be refined later*

## Essential Requirements for Production

### Technical Architecture
1. **State Management**: Provider or Riverpod for auth state, user preferences, blocking rules
2. **Local Data Persistence**: SQLite for offline access to blocked app lists
3. **Backend Services**: 
   - Supabase Postgres for user data, blocking rules, analytics
   - Database schema for app usage tracking, blocked attempts

### Native Implementation (Critical for Core Feature)
- **Blocking Mechanism**: Device Admin API (Android) + Screen Time APIs (iOS)
  - Android: Device Admin to disable app launch
  - iOS: Screen Time restrictions for app blocking
  - Platform channels required for native bridging
  - Supports scheduled blocks and long-term enforcement
  - Can iterate to more tamper-resistant approach (VPN) in future versions

### Analytics & Reporting
- Design schema for tracking:
  - App usage time per application
  - Blocked attempt logs
  - Daily/weekly/monthly reports
- Display insights on "You" screen

### Testing Strategy
- Unit tests for authentication flow
- Widget tests for Forui UI components
- Integration tests with test Supabase project
- Platform-specific native code testing

### Deployment & Distribution
- Firebase App Distribution (Android testing)
- TestFlight (iOS testing)
- Google Play Store (Android production)
- Apple App Store (iOS production)
- CI/CD pipeline setup

### Theming System
- Light/dark mode toggle
- Apply #1fbacb as primary brand color across Forui components
- Extend Forui theme for consistency
- Black/white accent colors

## Project Structure
```
notagain/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/
│   │   ├── constants/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── new_block/
│   │   └── profile/
│   ├── services/
│   │   ├── supabase_service.dart
│   │   └── native_blocking_service.dart
│   └── widgets/
├── android/
│   └── [Native code for blocking functionality]
├── ios/
│   └── [Native code for blocking functionality]
├── pubspec.yaml
└── test/
```

## Dependencies (Preliminary)
- `forui` - UI components
- `supabase_flutter` - Supabase client SDK
- `provider` or `riverpod` - State management
- `sqflite` - Local SQLite database
- `shared_preferences` - User preferences
- `permission_handler` - Permission management
- `device_apps` - List installed apps (Android/iOS)
- `usage_stats` - Track app usage (Android)
- Platform channels for native blocking implementation

## Decision Points to Resolve
1. **Blocking Mechanism**: Native APIs vs VPN approach?
2. **MVP Timeline**: Launch core auth/UI first or blocking functionality first?
3. **Android Support Level**: Android 8.0+? 10.0+?
4. **iOS Support Level**: iOS 13.0+? 14.0+?
5. **Offline-First Strategy**: How much functionality works without internet?
