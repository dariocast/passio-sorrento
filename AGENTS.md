# AI Coding Agents Guidelines & Protocols

This document serves as the "Constitution" for all AI agents working on the "Incappucciati" project.

## 1. Repository Structure
The project is a monorepo clearly divided as follows:

```text
/
├── mobile/                 # Flutter Public App (iOS + Android)
│   ├── lib/
│   │   ├── core/           # Shared components, utils, errors, theme, router
│   │   ├── features/       # Feature-based folders (home, weather, tracking, settings)
│   │   │   ├── [feature]/
│   │   │       ├── data/
│   │   │       ├── domain/
│   │   │       └── presentation/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── tracker_app/            # Flutter Tracker App (Android only, internal tool)
│   ├── lib/
│   │   ├── data/           # API client, services (location, config)
│   │   ├── domain/         # Entities (Confraternity, TrackingConfig)
│   │   ├── presentation/   # Cubit, pages
│   │   └── main.dart
│   └── pubspec.yaml
│
├── server/                 # Python Backend
│   ├── app/
│   │   ├── __init__.py     # Flask factory, Swagger config
│   │   ├── models.py       # SQLAlchemy models
│   │   └── routes.py       # API Blueprint with all endpoints
│   ├── requirements.txt
│   ├── seed.py
│   └── run.py
│
├── docs/                   # Documentation (Architecture, API Reference, Database, Contributing)
└── PLAN.md                 # UI Refactoring Plan (mobile app)

```

## 2. Mobile & Tracker Rules (Flutter)

* **State Management:** Mandatory use of `flutter_bloc`. Every complex feature must have its own Bloc/Cubit.
* **Dependency Injection:** Pure **constructor injection** via `RepositoryProvider` and `BlocProvider` from `flutter_bloc`. **Do NOT use** `GetIt`, `injectable`, or any service locator pattern.
* **Architecture:** Strictly respect Data/Domain/Presentation separation. DTOs (Data Transfer Objects) reside in the Data Layer, Entities in the Domain.
* **No Code Generation:** Do NOT use `freezed`, `json_serializable`, or `build_runner`. All serialization and state classes are manual.
* **Null Safety:** Strictly Sound Null Safe code.
* **Linter:** Follow standard `flutter_lints` rules.

## 3. Backend Rules (Python/Flask)

* **Type Hinting:** Always use Python type hints (e.g., `def get_pos() -> Position:`).
* **Response Format:** All API responses must be standardized JSON: `{"data": ..., "error": null}`.
* **Database:** Use SQLAlchemy as ORM. Do not write raw SQL unless strictly necessary.
* **Spec:** Always generate/update the OpenAPI schema if endpoints are modified.

## 4. Parallel Workflow

Agents will work on specific tasks.

* **Backend Agent:** Handles `server/`. Exposes APIs on `http://localhost:5000`.
* **Mobile Agent:** Handles `mobile/`. Mocks data if the backend is unreachable, using a `DataSource` interface.
* **Tracker Agent:** Handles `tracker_app/`. Connects to the same backend to push GPS tracking data.

## 5. Code Conventions

* **Commits:** Use Conventional Commits (e.g., `feat: added weather implementation`, `fix: map padding`).
* **Comments:** Write docstrings for public classes and methods. Comment complex logic ("Why, not What").

## 6. Reference Tech Stack

* **Flutter:** 3.x+
* **Python:** 3.10+
* **Map:** `flutter_map` + `latlong2`
* **Http:** `http` (Flutter), `flask` (Python)
