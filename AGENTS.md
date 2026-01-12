# AI Coding Agents Guidelines & Protocols

This document serves as the "Constitution" for all AI agents working on the "Incappucciati" project.

## 1. Repository Structure
The project is a monorepo clearly divided as follows:

```text
/
├── mobile/                 # Flutter Project
│   ├── lib/
│   │   ├── core/           # Shared components, utils, errors, theme
│   │   ├── features/       # Feature-based folders (home, weather, tracking)
│   │   │   ├── [feature]/
│   │   │       ├── data/
│   │   │       ├── domain/
│   │   │       └── presentation/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── server/                 # Python Backend
│   ├── app/
│   │   ├── api/            # Routes & Blueprints
│   │   ├── core/           # Config, extensions
│   │   ├── models/         # SQLAlchemy models
│   │   └── services/       # Business Logic
│   ├── requirements.txt
│   └── run.py
│
├── docs/                   # Documentation (OpenAPI, etc.)
└── PRD.md

```

## 2. Mobile Rules (Flutter)

* **State Management:** Mandatory use of `flutter_bloc`. Every complex feature must have its own Bloc/Cubit.
* **Dependency Injection:** Use `get_it` and `injectable` to manage dependencies between layers.
* **Architecture:** Strictly respect Data/Domain/Presentation separation. DTOs (Data Transfer Objects) reside in the Data Layer, Entities in the Domain.
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

## 5. Code Conventions

* **Commits:** Use Conventional Commits (e.g., `feat: added weather implementation`, `fix: map padding`).
* **Comments:** Write docstrings for public classes and methods. Comment complex logic ("Why, not What").

## 6. Reference Tech Stack

* **Flutter:** 3.x+
* **Python:** 3.10+
* **Map:** `flutter_map` + `latlong2`
* **Http:** `dio` (Flutter), `flask` (Python)
