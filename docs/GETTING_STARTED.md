# Getting Started with NotAgain

This guide walks you through setting up NotAgain for local development.

## Prerequisites

- **Flutter SDK**: 3.10.3 or higher
  - Install: https://flutter.dev/docs/get-started/install
- **Dart SDK**: Included with Flutter
- **Xcode**: 15+ (for iOS development)
  - Install via App Store or `xcode-select --install`
- **Git**: For cloning the repository

**Verify your setup:**
```bash
flutter --version
dart --version
```

## Step 1: Clone and Install Dependencies

```bash
# Clone the repository
git clone https://github.com/benmayer/NotAgain.git
cd NotAgain/notagain

# Install Flutter dependencies
flutter pub get
```

## Step 2: Configure Environment Variables

The app uses environment variables for sensitive credentials (Supabase API keys).

```bash
# Copy the example env file
cp .env.example .env
```

Open `.env` and add your Supabase credentials:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_KEY=your_supabase_anon_key_here
```

### Getting Supabase Credentials

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Create a new project or select an existing one
3. Navigate to **Settings** → **API**
4. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public key** → `SUPABASE_KEY`

**⚠️ Security:**
- **Never commit `.env` to version control** - it's in `.gitignore`
- Keep your keys secret - treat them like passwords
- Rotate keys if accidentally exposed

## Step 3: Run the App

### On iOS Simulator

```bash
# List available devices
flutter devices

# Run on default device (usually iOS simulator)
flutter run

# Or run on specific device
flutter run -d "iPhone 15 Pro Max"
```

### On Physical iOS Device

1. Connect your iPhone via USB
2. Trust the computer on your device
3. Run the app:
   ```bash
   flutter run -d [device_id]
   ```

### On Android (if applicable)

```bash
flutter run -d emulator-5554
```

## Step 4: Verify Installation

When the app launches, you should see:
1. **Welcome Screen** - Entry point with "Sign In" and "Get Started" buttons
2. **Login/Signup** - Test auth flows
3. **Onboarding** - If signup succeeds, guides through 2-step onboarding
4. **Home Dashboard** - If already authenticated

**If you see errors:**
- Run `flutter clean && flutter pub get` to reset cache
- Check `.env` file is in `notagain/` directory (not `docs/`)
- Verify Supabase credentials are correct
- Run `flutter analyze` to check for code issues

## Common Development Tasks

### Run with Logging

```bash
flutter run -v
```

Shows detailed logs from Flutter, Dart, and the app.

### Format Code

```bash
flutter format lib/
```

Formats all code in `lib/` directory.

### Analyze Code

```bash
flutter analyze
```

Checks for warnings and issues (should show zero issues).

### Run Tests

```bash
flutter test
```

Runs all tests (unit, widget, integration).

### Hot Reload During Development

While the app is running:
- **Hot Reload**: Press `r` in terminal to reload code changes (keeps app state)
- **Hot Restart**: Press `R` to restart app completely (resets state)
- **Quit**: Press `q` to stop

## Project Structure

```
notagain/
├── lib/
│   ├── main.dart              # App entry point
│   ├── core/                  # Shared utilities
│   │   ├── constants/         # App constants
│   │   ├── logging/           # AppLogger
│   │   ├── theme/             # Theme configuration
│   │   └── utils/             # Helper functions
│   ├── models/                # Data models (User, etc.)
│   ├── providers/             # State management (Provider)
│   ├── routing/               # Navigation configuration
│   ├── screens/               # Screens organized by feature
│   │   ├── auth/              # Login, signup, welcome
│   │   ├── onboarding/        # Multi-step onboarding
│   │   ├── home/              # Main dashboard
│   │   ├── start/             # Blocking rules
│   │   ├── profile/           # User profile
│   │   └── settings/          # Settings
│   ├── services/              # Backend integration
│   │   ├── supabase_service.dart
│   │   └── native_blocking_service.dart
│   └── widgets/               # Reusable UI components
│
├── .env.example               # Example env file (commit to git)
├── .env                       # Your credentials (DON'T commit)
├── pubspec.yaml               # Dependencies
└── README.md                  # Quick reference
```

For detailed structure, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Next Steps

1. **Understand the architecture:** Read [ARCHITECTURE.md](./ARCHITECTURE.md)
2. **Learn navigation patterns:** Read [ROUTING.md](./guides/ROUTING.md)
3. **Explore code:** Start with `lib/main.dart` and `lib/screens/auth/welcome_screen.dart`
4. **Development workflows:** See [DEVELOPMENT.md](./DEVELOPMENT.md)

## Troubleshooting

### Issue: `flutter pub get` fails

```bash
# Clear cache and try again
flutter clean
flutter pub cache clean
flutter pub get
```

### Issue: Supabase connection fails

- Verify `.env` file is in the correct location (`notagain/` directory)
- Check credentials in Supabase dashboard
- Ensure Supabase project is active (not paused)
- Check internet connection

### Issue: iOS build fails

```bash
# Clean and rebuild
flutter clean
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get
flutter run
```

### Issue: Hot reload not working

```bash
# Restart the app
flutter run -v
# Press R to hot restart
```

### Issue: Navigation crashes with "popped last page"

This is a stack corruption issue. See [ROUTING.md](./guides/ROUTING.md) → "Common Mistakes".

## Getting Help

- **Flutter docs:** https://flutter.dev/
- **Dart docs:** https://dart.dev/
- **Supabase docs:** https://supabase.com/docs/
- **Forui docs:** https://forui.dev/
- **Project issues:** Check GitHub issues or create one

---

**Ready to code?** See [DEVELOPMENT.md](./DEVELOPMENT.md) for common workflows.
