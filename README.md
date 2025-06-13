![banner](https://github.com/user-attachments/assets/20316412-aeff-4918-a465-e49f65368b6e)

# 💸 Cashnetic

Cashnetic is a financial mobile app built with Flutter that helps users track expenses, income, account balances, and manage financial articles. The application is designed with modular architecture, reactive state management, and code generation to ensure scalability and maintainability.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%5E3.22.2-blue" />
  <img src="https://img.shields.io/badge/Dart-%5E3.8.1-blue" />
  <img src="https://img.shields.io/badge/auto_route-%5E10.1.0%2B1-green" />
  <img src="https://img.shields.io/badge/Flutter%20Dev-Ready-%23FFB300" />
</p>

---

## ✨ Features

- 📊 Track and visualize expenses and income
- 🏦 Manage account balances and currency
- 📂 Organize financial articles (categories)
- 🔄 Tabbed navigation with persistent state
- 🧭 Advanced routing with `auto_route`
- ⚙️ Settings and customization
- 🧪 Mock repositories for data handling
- 🖼️ Custom charts using `fl_chart`

---

## 🧱 Architecture

The app uses a **feature-first modular architecture**:


### 📁 Key Concepts

- **Routing**: `auto_route` for strongly-typed nested and tabbed navigation
- **State Management**: `provider` + `view_models` for scoped state
- **Serialization**: `freezed` + `json_serializable` for robust immutable models
- **Charting**: `fl_chart` to render custom visual data
- **Storage**: `shared_preferences` for persisting user settings
- **Navigation Bar**: `google_nav_bar` for modern tab UI

---

## 🔧 Dependencies

```yaml
dependencies:
  provider: ^6.1.5
  intl: ^0.20.2
  shared_preferences: ^2.5.3
  json_annotation: ^4.9.0
  freezed_annotation: ^3.0.0
  fl_chart: ^1.0.0
  google_nav_bar: ^5.0.7
  auto_route: ^10.1.0+1

dev_dependencies:
  freezed: ^3.0.6
  json_serializable: ^6.9.5
  build_runner: ^2.4.15
  auto_route_generator: ^10.2.3
```


## 📂 Data Layer

The `lib/data/` directory contains mock implementations and models for data access and transformation:

- **`mock_transactions_repository.dart`** – simulates transaction data for development and testing.
- **`analysis_compute.dart`** (located in `lib/utils/`) – processes and transforms transaction data into structures suitable for visualization, such as bar chart models.

All domain models are defined in `lib/models/`, and are generated using:

- `freezed` – for immutable data classes with union support
- `json_serializable` – for automatic JSON serialization/deserialization

## 📊 Chart Analytics

The app visualizes spending data using bar and pie charts via the [`fl_chart`](https://pub.dev/packages/fl_chart) package.

- **`ExpensesScreen`** and **`IncomeScreen`** aggregate and display daily financial activity using bar charts.
- **`AnalysisScreen`** showcases a pie chart distribution of expenses per category.

Chart sections are color-coded using a consistent palette defined in the `AnalysisViewModel`. Category-to-icon and category-to-color mappings are handled via the utility file `category_utils.dart`.

## 🧵 Isolates & Performance

To ensure the UI remains responsive during data-intensive operations, we use Dart's `compute()` function — a built-in way to offload heavy work to a separate isolate.

The isolate is used in:

**📁 lib/utils/analysis_compute.dart**

This file contains the `computeAnalysisIsolate` function, which receives a list of transactions and generates summarized data for analytics, such as category percentages and total amounts.


Built with ❤️ using Flutter
