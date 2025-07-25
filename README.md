![banner](https://github.com/user-attachments/assets/20316412-aeff-4918-a465-e49f65368b6e)

# 💸 Cashnetic

Cashnetic is a modern, modular finance management app built with Flutter. It empowers users to track expenses, manage accounts, analyze spending, and customize their experience with advanced settings and beautiful UI. The app is designed for scalability, maintainability, and a delightful user experience.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%5E3.22.2-blue" />
  <img src="https://img.shields.io/badge/Dart-%5E3.8.1-blue" />
  <img src="https://img.shields.io/badge/auto_route-%5E10.1.0%2B1-green" />
  <img src="https://img.shields.io/badge/Material%203-Ready-%2300BFAE" />
  <img src="https://img.shields.io/badge/Localization-EN%7CRU%7CDE-%234CAF50" />
</p>

---

## 🚀 Overview

**Cashnetic** is a feature-rich personal finance app with a focus on:

- **Modular architecture**: Each feature (PIN, accounts, transactions, analytics, settings, etc.) is isolated for easy scaling and testing.
- **State management**: Powered by BLoC for predictable, testable business logic.
- **Dependency injection**: GetIt for clean, decoupled code.
- **Advanced navigation**: AutoRoute for strongly-typed, nested, and tabbed navigation.
- **Persistent storage**: SharedPreferences and flutter_secure_storage for user data and settings.
- **Localization**: English, Russian, and German with ARB files and intl.
- **Material 3 UI**: Dynamic theming, color picker, and adaptive design.
- **Custom charts**: Visualize your finances with beautiful bar and pie charts.
- **Security**: PIN code and biometric support.
- **Performance**: Heavy analytics run in isolates for a smooth UI.

---

## ✨ Features

- 📊 Track and visualize expenses and income
- 🏦 Manage multiple accounts and balances
- 📂 Organize transactions by categories
- 🔄 Tabbed navigation with persistent state
- 🧭 Advanced routing with AutoRoute
- 🔒 PIN code and biometric protection
- 🎨 Dynamic theming with preset color picker
- 🌐 Multi-language support (EN, RU, DE)
- ⚙️ Settings: theme, color, language, haptic feedback strength
- 🖼️ Custom charts (bar, pie) for analytics
- 🧪 Mock repositories for testing
- 🪄 Blur effect on multitasking
- 🤏 Haptic feedback with configurable strength
- 🧩 Modular, testable architecture

---

## 🧱 Architecture

The app follows a **feature-first modular architecture**:

- `lib/presentation/features/` — Each feature (accounts, analysis, pin, settings, etc.) contains its own BLoC, repository, services, widgets, and screens.
- `lib/data/` — Data layer: repositories, models, mappers, API, database.
- `lib/domain/` — Domain layer: entities, value objects, enums, forms, failures.
- `lib/utils/` — Utilities for analytics, color, formatting, etc.
- `lib/l10n/` — Localization (ARB files for EN, RU, DE).
- `lib/generated/` — Generated files (localization, routes).
- `lib/router/` — Navigation (AutoRoute).
- `lib/di/` — Dependency injection (GetIt).
- `lib/core/` — Core services (e.g., app lifecycle).

---

## 🔧 Dependencies

```yaml
# Main
flutter_bloc: ^8.x
get_it: ^7.x
auto_route: ^10.1.0+1
shared_preferences: ^2.5.3
flutter_secure_storage: ^9.x
intl: ^0.20.2
freezed_annotation: ^3.0.0
json_annotation: ^4.9.0
fl_chart: ^1.0.0
google_nav_bar: ^5.0.7
flutter_colorpicker: ^1.0.3
pinput: ^3.0.1

# Dev
freezed: ^3.0.6
json_serializable: ^6.9.5
build_runner: ^2.4.15
auto_route_generator: ^10.2.3
```

---

## 📂 Data Layer

- **Repositories**: Abstract and concrete implementations for accounts, transactions, categories, analytics, PIN, settings, etc.
- **Models**: Immutable data classes (freezed, json_serializable).
- **Mappers**: Transform API/database data to domain models.
- **Mock repositories**: For development and testing.

---

## 📊 Analytics & Charts

- **Bar and pie charts**: Visualize spending and income by category, period, and account.
- **Dynamic color palette**: Charts and chips adapt to the selected theme color.
- **Performance**: Heavy analytics run in isolates (see `lib/utils/analysis_compute.dart`).

---

## 🌍 Localization

- **Languages**: English, Russian, German
- **ARB files**: Located in `lib/l10n/`
- **Generated localization**: `lib/generated/`
- **Easy language switching** in settings

---

## 🛡️ Security

- **PIN code**: Secure app access with PIN (BLoC, repository, secure storage)
- **Biometric**: Optional biometric unlock (if supported)

---

## 🎨 UI & UX

- **Material 3**: Modern, adaptive design
- **Dynamic theming**: Preset color picker, theme reset
- **Blur effect**: App is blurred when multitasking
- **Haptic feedback**: Configurable strength for key actions
- **Consistent, unified UI**: Transaction add/edit screens, chips, headers, and period selectors adapt to theme

---

## 🚦 Quick Start

```sh
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## ❤️ Built with Flutter
