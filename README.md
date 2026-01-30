# DailyExpenseApp

This workspace contains a minimal Flutter app scaffolded to use Material 3 and a clean architecture folder layout.

What I added:

- `pubspec.yaml` — basic dependencies and flutter configuration.
- `lib/main.dart` — App entry, sets `useMaterial3: true` and a seeded color scheme.
- `lib/presentation/pages/home_page.dart` — simple HomePage scaffold (no counter example).
- `lib/presentation/widgets/expense_list.dart` — temporary UI showing sample expenses.
- `lib/domain/*` — entities, repository interface, and a simple use case.
- `lib/data/*` — model and a fake repository implementation returning mock data.

Clean architecture layout:

- lib/
	- core/ (not yet used, place for shared utilities)
	- data/
		- models/
		- repositories/
	- domain/
		- entities/
		- repositories/
		- usecases/
	- presentation/
		- pages/
		- widgets/

How to run

This requires Flutter installed (SDK + flutter tool).

1. From the workspace root, run:

```powershell
flutter pub get
flutter run
```

Notes and next steps

- The default counter example was removed and replaced by a small scaffold using Material 3.
- The repository currently contains in-memory/mock data. Next steps: wire DI, add persistence (sqflite/hive), and implement add/edit expense flows.