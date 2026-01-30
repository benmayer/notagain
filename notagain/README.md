# NotAgain

A **production-ready Flutter template** for screen time management apps that block distracting apps and websites.

## 🎯 Quick Start

### Prerequisites
- **Flutter SDK** 3.10.3+
- **Dart SDK** (included)
- **Xcode 15+** (for iOS)

### Setup (2 minutes)

```bash
# 1. Clone and install
git clone https://github.com/benmayer/NotAgain.git
cd NotAgain/notagain
flutter pub get

# 2. Configure credentials
cp .env.example .env
# Edit .env with your Supabase API keys (see docs/GETTING_STARTED.md)

# 3. Run
flutter run
```

## 📚 Documentation

**Start here:** [`docs/index.md`](../docs/index.md) - Complete documentation index

### Quick Navigation

- **[Getting Started](../docs/GETTING_STARTED.md)** - Setup, environment configuration
- **[Development Workflows](../docs/DEVELOPMENT.md)** - Common tasks (add screen, create component, etc.)
- **[Architecture](../docs/ARCHITECTURE.md)** - Project structure and design
- **[Routing Guide](../docs/guides/ROUTING.md)** - Navigation patterns, iOS swipe-back ⚠️ **CRITICAL**
- **[Components Guide](../docs/guides/COMPONENTS.md)** - UI components, pure Forui theming
- **[State Management](../docs/guides/STATE_MANAGEMENT.md)** - Provider pattern
- **[Logging](../docs/guides/LOGGING.md)** - Structured logging

### Reference
- **[Database Schema](../docs/reference/DATABASE_SCHEMA.md)** - Table structures
- **[Authentication](../docs/reference/AUTH_IMPLEMENTATION.md)** - Auth flows
- **[Forui Theming](../docs/reference/FORUI_MIGRATION.md)** - Theme system

## ✨ Key Features

### Authentication
- ✅ Email/password signup and login
- ✅ Apple Sign-In & Google Sign-In
- ✅ Session persistence
- ✅ OAuth error handling

### Navigation
- ✅ Stack-based navigation with iOS swipe-back gestures
- ✅ Auth guards (unauthenticated users see only auth screens)
- ✅ Onboarding guards (incomplete users blocked from main app)
- ✅ Proper push/go/pop semantics to prevent crashes

### State Management
- ✅ Provider pattern for reactive state
- ✅ Structured error handling with Result<T>
- ✅ AuthProvider, OnboardingProvider, ThemeProvider
- ✅ Data persistence via SharedPreferences

### UI & Theming
- ✅ Pure Forui theming (no Material styling)
- ✅ Light/dark mode with FAnimatedTheme
- ✅ FScaffold, FButton, FTextFormField, 40+ Forui components
- ✅ Consistent design system throughout

### Logging & Debugging
- ✅ Structured logging with AppLogger
- ✅ Screen lifecycle logging for navigation debugging
- ✅ Production-ready (zero code warnings)
- ✅ Easy to extend to file/external service logging

## 🏗️ Architecture

```
lib/
├── main.dart              # App entry with FAnimatedTheme + FToaster
├── core/                  # Shared utilities
│   ├── constants/         # App constants (padding, colors, etc.)
│   ├── logging/           # Structured logging
│   ├── theme/             # Theme configuration
│   └── utils/             # Helpers
├── models/                # Data models (User, Result<T>, etc.)
├── providers/             # State management (Provider pattern)
├── routing/               # Navigation with auth/onboarding guards
├── screens/               # Screens organized by feature
│   ├── auth/              # Login, signup, welcome
│   ├── onboarding/        # Multi-step onboarding
│   ├── home/              # Dashboard
│   ├── start/             # Blocking rules
│   ├── profile/           # User profile
│   └── settings/          # Settings
├── services/              # Backend integration
│   ├── supabase_service.dart
│   └── native_blocking_service.dart
└── widgets/               # Reusable UI components
```

**Details:** See [`ARCHITECTURE.md`](../docs/ARCHITECTURE.md)

## 🚀 Development

### Common Tasks

```bash
# Format code
flutter format lib/

# Analyze for warnings (must be zero issues)
flutter analyze

# Run tests
flutter test

# Hot reload (while app running)
# Press 'r' in terminal

# View logs
flutter logs
```

### Adding a Screen

See [Development Workflows](../docs/DEVELOPMENT.md) → "Adding a New Screen"

### Creating a Component

See [Components Guide](../docs/guides/COMPONENTS.md)

## ⚠️ Critical: Navigation Patterns

**This is the most important pattern to understand:**

```dart
// ✅ Screen progression (maintains history for swipe-back)
context.push('/next-screen');

// ✅ Auth state change (clears stack)
context.go('/home');

// ✅ Back button (always pop, never go)
context.pop();
```

**Why it matters:** Incorrect navigation methods cause crashes ("You have popped the last page off of the stack").

**Full guide:** [Routing Guide](../docs/guides/ROUTING.md)

## 📦 Dependencies

- **flutter** (3.10.3+)
- **go_router** (17.0.1) - Navigation
- **provider** (6.1.0) - State management
- **supabase_flutter** (2.6.3) - Backend
- **forui** (0.14.0) - UI components
- **logger** (2.4.0) - Structured logging
- **flutter_dotenv** (5.2.0) - Environment variables

## 🔐 Security

- **Credentials:** Use `.env` file (excluded from git)
- **Never commit:** API keys, access tokens, secrets
- **Environment variables:** Loaded at runtime via `flutter_dotenv`

```bash
# ✅ Commit
.env.example

# ❌ Never commit
.env
```

## 📋 Project Status

✅ **Production-Ready Template**
- Zero code warnings
- Comprehensive documentation
- Tested auth flows (email, Apple, Google)
- iOS swipe-back gesture support
- Structured logging
- Best practices throughout

**Next:** Testing infrastructure and expanded features

## 🤝 Contributing

1. Run `flutter analyze` - must be zero issues
2. Run `flutter format` - format code
3. Run `flutter test` - all tests pass
4. Update documentation if adding features
5. Create PR with clear description

See `.github/CONTRIBUTING.md` for full checklist

## 📖 Learning Resources

- **Flutter Docs:** https://flutter.dev/
- **Dart Docs:** https://dart.dev/
- **Supabase Docs:** https://supabase.com/docs/
- **Forui Docs:** https://forui.dev/
- **GoRouter Docs:** https://pub.dev/packages/go_router

## 📄 License

MIT License - See LICENSE file for details

---

**Ready to code?**
→ Start with [Getting Started](../docs/GETTING_STARTED.md)
→ Then read [Development Workflows](../docs/DEVELOPMENT.md)
→ Always review [Routing Guide](../docs/guides/ROUTING.md) before touching navigation code
