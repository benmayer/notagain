# NotAgain

A Flutter app for screen time management that blocks distracting apps and websites.

## Getting Started

### Prerequisites
- Flutter SDK (^3.10.3)
- Dart SDK (included with Flutter)
- Xcode 15+ (for iOS development)

### Local Development Setup

1. **Clone the repository and install dependencies:**
```bash
flutter pub get
```

2. **Configure environment variables:**
   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Open `.env` and add your Supabase credentials:
     ```
     SUPABASE_URL=https://your-project-id.supabase.co
     SUPABASE_KEY=your_supabase_anon_key_here
     ```
   - Get your credentials from your [Supabase project dashboard](https://app.supabase.com)

3. **Run the app:**
```bash
flutter run
```

### Environment Variables
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_KEY`: Your Supabase anonymous key (publishable)

**Important:** Never commit `.env` to version control. The `.gitignore` file already excludes it.

## Project Structure

See [ARCHITECTURE.md](../ARCHITECTURE.md) for detailed architecture documentation.

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## For help

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
