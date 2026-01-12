# Contributing Guide

## Development Setup

### 1. Prerequisites
- **Flutter SDK**: 3.x+
- **Python**: 3.10+
- **Git**

### 2. General Rules
- **No Code Generation**: Do not add `build_runner`, `freezed`, or `json_serializable`. All serialization and DI must be done manually.
- **Clean Architecture**: Respect the boundaries between presentation, domain, and data layers.
- **Git Commits**: Use conventional commits (feat:, fix:, docs:, refactor:).

### 3. Mobile Development
```bash
cd mobile
flutter pub get
flutter run
```

### 4. Server Development
```bash
cd server
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python run.py
```

## Adding a New Feature

1. Create the entities in `lib/features/<feature>/domain/entities`.
2. Define the repository interface in `lib/features/<feature>/domain/repositories`.
3. Implement the repository in `lib/features/<feature>/data/repositories`.
4. Inject the repository in `main.dart`.
5. Create the UI and Cubit in `lib/features/<feature>/presentation`.
