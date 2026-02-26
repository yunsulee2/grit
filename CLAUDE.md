# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**grit** is a Flutter application (Dart SDK ^3.11.0) targeting a fitness group-buying platform. Currently at the default template stage. Targets all platforms: Android, iOS, Web, macOS, Linux, Windows.

## Common Commands

```bash
# Run the app
flutter run

# Run on a specific device
flutter run -d chrome        # Web
flutter run -d macos          # macOS
flutter run -d ios            # iOS simulator

# Analyze code (linting)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Get dependencies
flutter pub get

# Build
flutter build apk             # Android
flutter build ios              # iOS
flutter build web              # Web
flutter build macos            # macOS
```

## Architecture

- **Entry point**: `lib/main.dart` — contains `MyApp` (root MaterialApp) and `MyHomePage` (stateful home widget)
- **Tests**: `test/` directory, using `flutter_test` package
- **Linting**: `analysis_options.yaml` uses `package:flutter_lints/flutter.yaml`
- **Design docs**: `docs/` contains the PRD (`피트니스_공동구매_플랫폼_UI_PRD.docx`)

## Conventions

- Uses Material Design (`uses-material-design: true`)
- Private package (`publish_to: 'none'`)
- Theme uses `ColorScheme.fromSeed` pattern
- State management: currently using `setState` (vanilla Flutter)
