# NotAgain Documentation Index

Welcome to NotAgain! This documentation is organized to help you quickly understand the project and continue development.

## Quick Start

**New to the project?** Start here:
1. [Getting Started](./GETTING_STARTED.md) - Setup, environment configuration, running the app
2. [Architecture Overview](./ARCHITECTURE.md) - Project structure and high-level design
3. [Development Workflows](./DEVELOPMENT.md) - Common tasks and development patterns

## Guides

Learn how to work with specific systems:

- **[Routing Guide](./guides/ROUTING.md)** - Navigation patterns, push vs go vs pop, iOS swipe-back gestures
- **[Components Guide](./guides/COMPONENTS.md)** - UI components, Forui theming, creating new components
- **[Logging Guide](./guides/LOGGING.md)** - Structured logging with AppLogger
- **[State Management](./guides/STATE_MANAGEMENT.md)** - Provider pattern, auth flow, data persistence

## Reference

Detailed technical information:

- **[Database Schema](./reference/DATABASE_SCHEMA.md)** - Table structures, relationships, types
- **[Forui Theme System](./reference/FORUI_MIGRATION.md)** - Pure Forui theming, color system, typography
- **[Authentication Flow](./reference/AUTH_IMPLEMENTATION.md)** - Email, OAuth, session management

## Key Systems

### Authentication (`lib/providers/auth_provider.dart`)
- Email/password signup and login
- Apple Sign-In and Google Sign-In
- Session persistence with Supabase Auth
- Profile data enrichment on login

### Routing (`lib/routing/app_router.dart`)
- Stack-based navigation with iOS swipe-back gesture support
- Auth guards: unauthenticated users see only auth screens
- Onboarding guards: incomplete onboarding users blocked from main app
- Proper push/go/pop semantics to prevent stack corruption

### State Management (`lib/providers/`)
- Provider pattern for reactive state
- AuthProvider for authentication state
- OnboardingProvider for multi-step onboarding flow
- ThemeProvider for light/dark mode switching

### UI Components (`lib/widgets/`)
- Pure Forui theming - no Material components
- FScaffold, FButton, FTextFormField, FCard, and 40+ components
- Automatic light/dark mode support via context.theme

## For AI Agents

**If you're an AI agent continuing development:**

1. Read [Architecture Overview](./ARCHITECTURE.md) for project structure
2. Check [Routing Guide](./guides/ROUTING.md) for navigation patterns - **critical for preventing stack crashes**
3. Review `.github/instructions/Agent Instructions.md` in the project root for detailed coding patterns
4. Refer to [Components Guide](./guides/COMPONENTS.md) for Forui-first UI development
5. Check code style: `dart analyze`, `dart format`

**Common Tasks:**
- Adding a new screen? Start with [Development Workflows](./DEVELOPMENT.md) → "Add a New Screen"
- Fixing navigation issues? See [Routing Guide](./guides/ROUTING.md) → "Common Mistakes"
- Need logging? See [Logging Guide](./guides/LOGGING.md)
- Creating UI components? See [Components Guide](./guides/COMPONENTS.md)

## Project Status

✅ **Production-Ready Template**
- Secure credential management
- OAuth error handling
- Forui-first UI components
- Stack-based navigation with iOS support
- Structured logging system
- Comprehensive documentation
- Zero code warnings

**Next Phase:** Testing infrastructure and expanded documentation

## Quick Links

- **Supabase Dashboard:** https://app.supabase.com
- **Forui Documentation:** https://forui.dev/
- **GoRouter Documentation:** https://pub.dev/packages/go_router
- **Flutter Documentation:** https://flutter.dev/

## Contributing

See `.github/CONTRIBUTING.md` for PR requirements, code style, and checklist.

---

**Last Updated:** January 30, 2026  
**Documentation Version:** 1.0
