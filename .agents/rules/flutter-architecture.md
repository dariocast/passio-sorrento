---
trigger: always_on
---

---
description: Standards for Flutter Clean Architecture and Feature-First project structure.
globs: lib/**/*.dart
---

# Flutter Architecture & Organization

You are an expert Flutter developer specializing in Clean Architecture with Feature-First organization.

## 1. Feature-First Structure
Organize code by features rather than technical layers. Each feature is a self-contained module.

- **lib/core/**: Shared code (errors, network utilities, common widgets, theme, router).
- **lib/features/[feature_name]/**:
    - **data/**: Data sources (Remote/Local), Models (DTOs), and Repository implementations.
    - **domain/**: Entities (Business objects) and Repository interfaces (abstract classes).
    - **presentation/**: Cubits/Blocs, Pages, and Feature-specific widgets.

For very small apps with a single feature (e.g. tracker_app), the feature-first folder structure can be flattened to `lib/data/`, `lib/domain/`, `lib/presentation/`.

## 2. Dependency Rule & Constructor Injection
- **Dependencies always point inward**: Data → Domain ← Presentation.
- **Pure Constructor Injection**: Do NOT use GetIt, injectable, or any service locator pattern.
- All dependencies must be passed through class constructors.
- Dependencies should be defined as `final` and required.
- Use abstract classes/interfaces for repositories to ensure the Domain layer remains independent of implementation details.
- Wire all dependencies in `main.dart` using `RepositoryProvider` and `BlocProvider` from `flutter_bloc`.

## 3. Layer Responsibilities
- **Domain**: Strictly business logic. No Flutter imports. Contains Entities and abstract Repository interfaces.
- **Data**: Responsible for fetching and converting raw data (JSON) into Models, then mapping them to Domain Entities. Implements Domain Repository interfaces. Handles HTTP calls, caching, and platform APIs.
- **Presentation**: UI and State Management only. Cubits/Blocs call Repository methods and emit states. No direct calls to DataSources.

### Use Cases (Optional)
Use Cases are **optional**. For simple CRUD operations, Cubits may call Repositories directly. Introduce a Use Case class only when business logic is complex enough to warrant extraction (e.g., orchestrating multiple repositories, applying business rules).

## 4. ⚠️ No Code Generation
**Do NOT add** `build_runner`, `freezed`, `json_serializable`, or any codegen package.
All serialization (JSON ↔ Entity) is **manual** via `fromJson()` / `toJson()` / `fromMap()` factory constructors and methods.

## 5. Coding Standards
- Use `const` constructors for widgets whenever possible.
- Keep functions under 30 lines.
- Follow SOLID principles, specifically Dependency Inversion.
- Sound Null Safety — avoid the `!` operator unless absolutely necessary and documented.
- Follow standard `flutter_lints` rules.