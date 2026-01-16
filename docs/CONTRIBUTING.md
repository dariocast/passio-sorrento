# Contributing Guide

## Development Setup

### Prerequisites
- **Flutter SDK**: 3.x+
- **Python**: 3.10+
- **Git**

### Quick Start

```bash
# Mobile
cd mobile && flutter pub get && flutter run

# Server
cd server && python -m venv venv && source venv/bin/activate
pip install -r requirements.txt && python seed.py && python run.py
```

---

## Project Rules

### ⚠️ No Code Generation
Do not add `build_runner`, `freezed`, or `json_serializable`. All serialization is manual.

### Clean Architecture
Respect layer boundaries:
- **Presentation** → depends on **Domain**
- **Data** → depends on **Domain**
- **Domain** → no external dependencies

### Git Commits
Use conventional commits:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation
- `refactor:` Code refactoring

---

## Adding a New Feature

1. **Domain**: Create entities in `lib/features/<feature>/domain/entities`
2. **Domain**: Define repository interface in `domain/repositories`
3. **Data**: Implement repository in `data/repositories`
4. **Data**: Add data source in `data/datasources`
5. **Presentation**: Create Cubit in `presentation/cubit`
6. **Presentation**: Create Page in `presentation/pages`
7. **DI**: Inject repository in `main.dart`
8. **Router**: Add route and Args class in `app_router.dart`

---

## API Development

### Adding a New Endpoint

1. Add route in `app/routes.py`
2. Include OpenAPI docstring (Flasgger format)
3. Update `docs/API_REFERENCE.md`
4. Test via Swagger UI at `/docs`

---

## Useful Commands

```bash
# Analyze Flutter code
flutter analyze

# Run Flask with auto-reload
python run.py  # Debug mode enabled

# Re-seed database
rm instance/holyweek.db && python seed.py
```
