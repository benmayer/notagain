# Documentation Guide

Welcome to NotAgain documentation! This guide explains what's in `documentation/` and how to find what you need.

## Quick Navigation by Task

### I'm new to the project
1. Read this file (you're here!)
2. Read [architecture.md](architecture.md) - Understand the project structure (10 min)
3. Read [routing.md](routing.md) - Learn the navigation system (⚠️ **CRITICAL**, 15 min)
4. Read [development.md](development.md) - Common workflows

### I need to add a screen
1. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) → "Adding a New Screen"
2. [routing.md](routing.md) → Route configuration section
3. [architecture.md](architecture.md) → Screens section

### I need to build a UI component
1. [components.md](components.md) - Forui components and theming
2. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) → "Creating a Component"
3. [components.md](components.md) - Theme system details (see Theme section)

### I'm implementing authentication
1. [authentication.md](authentication.md) - Auth flows
2. [routing.md](routing.md) - Auth-specific navigation patterns
3. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) → "Adding a New Auth Method"

### Navigation is crashing or not working
⚠️ **STOP - READ THIS FIRST:** [routing.md](routing.md)
- "Common Mistakes & Fixes" section has solutions for most issues

### I need to understand state management
1. [state_management.md](state_management.md) - Provider pattern
2. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) → State management section
3. [architecture.md](architecture.md) → State Management section

### I need to add logging
1. [logging.md](logging.md) - How to use AppLogger
2. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) → "Adding Logging"

### I need database schema/model info
1. [database_schema.md](database_schema.md) - Tables and relationships
2. [architecture.md](architecture.md) → Models section

### I need to change the theme
1. [components.md](components.md) - Theme system (see Theme section)
2. [components.md](components.md) - Component styling

### I need to set up my environment
1. [SETUP_GUIDE.md](SETUP_GUIDE.md) - Environment variables and local setup

---

## All Documentation Files

### Core Guides (Read in This Order)

| File | Purpose | Time |
|------|---------|------|
| [architecture.md](architecture.md) | Project structure, core layers, entry points | 10 min |
| [routing.md](routing.md) | Navigation patterns, push/go/pop, iOS gestures | 15 min |
| [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) | Common workflows with code examples | 20 min |
| [state_management.md](state_management.md) | Provider pattern and reactive state | 15 min |
| [components.md](components.md) | Forui UI system and theming | 10 min |

### Reference (Look up as needed)

| File | Purpose | When to use |
|------|---------|-------------|
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Installation, environment configuration | First time setup |
| [authentication.md](authentication.md) | Authentication flows, user session | Implementing auth features |
| [database_schema.md](database_schema.md) | Tables, columns, relationships | Database queries, migrations |
| [components.md](components.md) | Forui theme system, color palette, typography | Customizing theme, styling |
| [logging.md](logging.md) | AppLogger usage and patterns | Adding debug logging |
| [routing.md](routing.md) | Navigation details and patterns | Deep dive into routing |

---

## Reading Order by Role

### New Developer (First Day)
```
1. architecture.md       (Understand structure - 10 min)
2. routing.md            (CRITICAL - prevent crashes - 15 min)
3. DEVELOPMENT_GUIDE.md  (Learn common tasks - 20 min)
4. components.md         (Build UI - 10 min)
5. state_management.md   (Manage state - 15 min)
```
**Total: ~1 hour**

### First Time Setup
```
1. SETUP_GUIDE.md        (Environment and installation)
2. architecture.md       (Project overview)
3. routing.md            (CRITICAL)
```

### Code Reviewer
```
1. routing.md            (Check navigation correctness)
2. components.md         (Check Forui-only rule)
3. state_management.md   (Check provider pattern)
```

### AI Agent
```
1. architecture.md
2. routing.md            (NEVER SKIP)
3. DEVELOPMENT_GUIDE.md
4. state_management.md
5. components.md
(Then use other guides as reference)
```

---

## Key Patterns to Know

### Navigation (⚠️ CRITICAL)
```dart
// Add to stack (for screen-to-screen navigation)
context.push('/next-screen');

// Replace route (for auth state changes)
context.go('/home');

// Remove from stack (for back buttons)
context.pop();
```
**See:** [routing.md](routing.md)

### State Management
```dart
// In provider
class MyProvider extends ChangeNotifier {
  Future<void> doSomething() async {
    // Change state
    notifyListeners();
  }
}

// In screen
final state = context.watch<MyProvider>();  // Reactive
final provider = context.read<MyProvider>(); // One-time
```
**See:** [state_management.md](state_management.md)

### UI Components
```dart
// Always use Forui (never Material)
FButton(onPress: () {}, child: const Text('Click'))
FTextFormField()
FCard()
FCheckbox()
```
**See:** [components.md](components.md)

### Logging
```dart
AppLogger.info('User logged in', tag: 'AuthProvider');
AppLogger.error('API failed', error: e, tag: 'SupabaseService');
```
**See:** [logging.md](logging.md)

---

## Documentation Structure

```
documentation/
├── GETTING_STARTED_GUIDE.md        ← You are here (navigation hub)
├── setup_guide.md                  ← Environment setup
├── architecture.md                 ← Project structure
├── routing.md                      ← Navigation (⚠️ CRITICAL)
├── development_guide.md            ← Common workflows
├── state_management.md             ← Provider pattern
├── components.md                   ← UI system & theme
├── auth_implementation.md          ← Auth flows
├── database_schema.md              ← Database tables
├── logging.md                      ← Logging
└── (planning docs: Todo.md, plan-*.md)
```

---

## Quick Facts

- **Framework**: Flutter 3.10.3+
- **Navigation**: GoRouter with iOS swipe-back support
- **State Management**: Provider pattern
- **UI**: Pure Forui theming (no Material)
- **Backend**: Supabase
- **Code Quality**: Zero warnings enforced

---

## Tips for Success

1. **Always read ROUTING.md first** - Navigation mistakes cause crashes
2. **Check COMPONENTS.md before adding UI** - Forui has everything you need
3. **Use DEVELOPMENT_GUIDE.md for workflows** - Contains code examples
4. **Reference docs for details** - AUTH_IMPLEMENTATION, DATABASE_SCHEMA, etc.
5. **Run `flutter analyze`** - Zero warnings required

---

## Still Lost?

1. Check your task in "Quick Navigation by Task" at the top
2. Look for the file in "All Documentation Files"
3. Check "Reading Order by Role" for your context
4. Ask in the project issues with details

Happy coding! 🚀
