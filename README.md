# 💸 Expense Tracker

A personal expense tracking mobile app built with Flutter for the take-home assignment.

---

## 📱 Screenshots

| Home (empty) | Home (with data) | Add Expense |
|---|---|---|
| Empty state with CTA | Expense list + summary | Form with category grid |

---

## 🏗️ Architecture

I chose **MVVM with a Repository pattern**, which cleanly separates concerns into four layers:

```
UI (Screens/Widgets)
      ↕
ViewModel  (ExpenseViewModel — state + business logic)
      ↕
Repository  (ExpenseRepository — abstracts the data source)
      ↕
Database  (DatabaseHelper — raw SQLite access via sqflite)
```

### Why this structure?

- **ViewModel is testable in isolation** — the `ExpenseRepository` interface allows swapping in a `FakeExpenseRepository` for unit tests without touching SQLite or the UI.
- **Repository pattern** decouples the ViewModel from the SQLite implementation. If I were to switch to Isar, Drift, or a remote API, only `LocalExpenseRepository` changes.
- **Provider** was chosen over Riverpod/Bloc intentionally — it's the simplest fit for a single-ViewModel app and keeps the dependency tree obvious.

---

## 🗂️ Project Structure

```
lib/
├── main.dart                    # App entry + Provider setup
├── models/
│   └── expense.dart             # Expense entity + ExpenseCategory enum
├── data/
│   └── database_helper.dart     # SQLite singleton (sqflite)
├── repositories/
│   └── expense_repository.dart  # Abstract interface + LocalExpenseRepository
├── viewmodels/
│   └── expense_viewmodel.dart   # State management, business logic
├── screens/
│   ├── expense_list_screen.dart # Screen 1 — list + summary
│   └── add_expense_screen.dart  # Screen 2 — add / edit form
├── widgets/
│   ├── expense_card.dart        # Swipe-to-delete expense row
│   ├── empty_state_widget.dart  # Empty state UI
│   └── summary_header.dart     # Total + category filter chips
└── theme/
    └── app_theme.dart           # Centralised Material 3 theme
```

---

## ✅ Features Implemented

### Core (Required)
- [x] Add expense (title, amount, date)
- [x] View expense list
- [x] 2 screens (list + add/edit)
- [x] Local persistence via SQLite (survives restarts)
- [x] Empty state with call-to-action
- [x] Loading state while fetching from DB
- [x] Error state with retry button

### Enhancements
- [x] **Edit expense** — tap any expense to edit it
- [x] **Delete expense** — swipe left or delete from edit screen
- [x] **Expense categories** (Food, Transport, Entertainment, Shopping, Health, Utilities, Other)
- [x] **Category filter chips** — filter list by category
- [x] **Total summary card** — shows total spend and count at a glance
- [x] **Input validation** — title required, amount > 0, date required
- [x] **Unit tests** — ViewModel and Model layers tested with a fake repository

---

## 🧪 Running Tests

```bash
flutter test
```

Tests cover:
- `Expense.toMap()` / `Expense.fromMap()` round-trip
- `copyWith` partial updates
- Unknown category fallback
- ViewModel: load, add, update, delete, filter, computed totals

All tests use `FakeExpenseRepository` — no real database involved.

---

## 🚀 Getting Started

**Requirements:** Flutter 3.x, Dart 3.x

```bash
# Clone and install dependencies
flutter pub get

# Run on a connected device or simulator
flutter run

# Run tests
flutter test
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management (ChangeNotifier) |
| `sqflite` | ^2.3.0 | SQLite persistence |
| `path` | ^1.8.3 | DB file path resolution |
| `intl` | ^0.18.1 | Currency and date formatting |
| `uuid` | ^4.2.1 | Unique IDs for expenses |

All dependencies are stable, well-maintained pub.dev packages.

---

## 🤔 Trade-offs & Decisions

| Decision | Rationale |
|---|---|
| **Provider over Riverpod** | Simpler for a single-ViewModel app; easier to reason about for reviewers |
| **sqflite over Hive/Isar** | Relational, queryable, no code-gen step needed |
| **Abstract `ExpenseRepository`** | Enables testing without mocking framework; shows scalability thinking |
| **`ViewState` enum** | Explicit idle/loading/error states prevent UI inconsistencies |
| **No generated code** | Kept setup simple; a production app might use Freezed + Drift |

---

## 🔮 What I'd Add Next

- Search / text filtering
- Monthly grouping in the list (section headers)
- Bar chart for category breakdown (fl_chart)
- Recurring expenses
- Export to CSV
- Dark mode (theme already uses Material 3, would be straightforward)
- Widget tests for screens using `flutter_test`

---

## 💡 Notes

- I used AI tooling for boilerplate scaffolding and can explain every line.
- The architecture is intentionally extensible — the Repository interface means adding a remote backend is a one-class change.
