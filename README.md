# Expense Tracker App

A production-ready Flutter application for personal finance management built using clean architecture principles, Provider state management, and SQLite local persistence.

This project demonstrates scalable Flutter application development with proper separation of concerns, optimized state handling, and maintainable database integration.

---

## Overview

The Expense Tracker App allows users to:

- Record daily expenses
- Categorize spending
- Analyze financial patterns
- View graphical statistics
- Persist data locally using SQLite
- Switch between light and dark themes

The application follows a modular architecture and is structured for long-term scalability and maintainability.

---

## Architecture

The application is built using a layered architecture approach:

- **Presentation Layer** → Screens & Widgets
- **State Layer** → Providers (ChangeNotifier)
- **Data Layer** → SQLite Database
- **Model Layer** → Entity definitions
- **Utility Layer** → Helpers and constants

State management is handled using the Provider package to ensure reactive UI updates with minimal rebuild cost.

---

## Tech Stack

| Technology | Purpose |
|------------|----------|
| Flutter | Cross-platform development |
| Provider (v6.1.1) | State management |
| SQLite (sqflite) | Local data persistence |
| SharedPreferences | Theme preference storage |
| fl_chart (v0.66.0) | Data visualization |
| intl | Date & currency formatting |
| uuid | Unique ID generation |

---

## Project Structure

```
lib/
│
├── models/
│   ├── category_model.dart
│   └── expense_model.dart
│
├── database/
│   └── database_helper.dart
│
├── providers/
│   ├── expense_provider.dart
│   └── theme_provider.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── add_expense_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
│
├── widgets/
│   ├── expense_card.dart
│   ├── category_chip.dart
│   └── custom_chart.dart
│
├── utils/
│   ├── constants.dart
│   └── helpers.dart
│
└── main.dart
```

The structure enforces separation of concerns and keeps business logic independent from UI components.

---

## Database Design

The app uses SQLite for persistent local storage.

### Categories Table

```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT,
  color INTEGER,
  icon TEXT
);
```

### Expenses Table

```sql
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  title TEXT,
  amount REAL,
  date TEXT,
  categoryId TEXT,
  notes TEXT,
  receiptUrl TEXT,
  FOREIGN KEY (categoryId) REFERENCES categories(id)
);
```

### Key Design Decisions

- UUID used for primary keys
- Date stored in ISO 8601 string format
- Foreign key constraint ensures relational integrity
- Default categories auto-inserted on first launch

---

## State Management

Provider is used for reactive state handling.

### ExpenseProvider Responsibilities

- Load initial data
- Add expenses
- Update expenses
- Delete expenses
- Filter by month
- Aggregate by category
- Notify UI using `notifyListeners()`

### ThemeProvider Responsibilities

- Toggle light/dark/system mode
- Persist theme preference using SharedPreferences
- Apply ThemeMode dynamically

---

## Core Features

### 1. Expense Management

- Create new expense entries
- Edit existing expenses
- Delete expenses with confirmation dialog
- Automatic UI refresh on data change

### 2. Categorization

- 8 pre-defined categories
- Color-coded visual indicators
- Icon-based category identification
- Category-based filtering & aggregation

### 3. Statistics & Visualization

- Pie chart distribution by category
- Weekly / Monthly / Yearly filtering
- Category-wise progress indicators
- Summary cards for total spending

### 4. Theme Support

- Light Mode
- Dark Mode
- System Default Mode
- Persistent theme selection

### 5. Data Persistence

- Offline-first architecture
- SQLite storage
- Data remains after app restart
- Local theme preference storage

---

## Data Flow

```
User Interaction
        ↓
Screen Widget
        ↓
Provider Method
        ↓
Database Operation (Async)
        ↓
notifyListeners()
        ↓
Consumer Widget Rebuild
```

This ensures unidirectional and predictable state updates.

---

## Performance Considerations

- ListView.builder for efficient rendering
- Lazy data loading
- Minimal widget rebuilds using Consumer
- Async database operations
- Optimized SQL queries

---

## Error Handling Strategy

- Form-level validation before submission
- Try-catch for database operations
- Confirmation dialogs for destructive actions
- Empty state handling for charts and lists

---

## Installation

### Clone Repository

```bash
git clone https://github.com/your-username/expense-tracker.git
```

### Navigate to Project

```bash
cd expense-tracker
```

### Install Dependencies

```bash
flutter pub get
```

### Run Application

```bash
flutter run
```

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  sqflite:
  path_provider:
  shared_preferences:
  fl_chart: ^0.66.0
  intl:
  uuid:
```

---

## Scalability & Extensibility

The architecture supports future expansion such as:

- Cloud sync (Firebase integration)
- Recurring expense automation
- Budget limits with alerts
- Multi-currency support
- Export to PDF / Excel
- Biometric authentication
- Notification reminders
- Financial analytics & AI insights

The modular structure allows new features without impacting existing functionality.

---

## Platform Support

- Android
- iOS
- Web (basic support)
- Desktop (experimental)

---

## Design Principles Followed

- Clean Architecture
- Separation of Concerns
- Reactive State Management
- Maintainable Code Structure
- Offline-First Approach
- Material Design 3 Compliance

---

## Why This Project Matters

This application demonstrates:

- Real-world Flutter architecture
- Proper database modeling
- State management best practices
- Professional UI implementation
- Scalable application design
- Clean and maintainable code organization

It is suitable for:

- Portfolio showcase
- Technical interviews
- Production-level starter template
- Learning advanced Flutter concepts

---

## License

This project is open-source and available under the MIT License.

---

## Author

Developed using Flutter with a focus on performance, scalability, and clean architecture.
