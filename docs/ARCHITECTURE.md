# Architecture Documentation

## Overview

The Sorrento Holy Week Tracker (Incappucciati) follows a **Monorepo** structure, separating the mobile client and the backend server.

## Mobile Architecture (Flutter)

The mobile application is built using **Clean Architecture** (also known as Onion Architecture). This ensures that core business logic is isolated from external concerns like UI, frameworks, and APIs.

### Layers

#### 1. Domain Layer (Deepest)
- **Entities**: Pure Dart classes representing business objects (e.g., `Confraternity`, `Procession`).
- **Repositories (Interfaces)**: Abstract definitions of data operations.
- **Use Cases**: Specific business logic units (e.g., `GetLiveLocation`).

#### 2. Data Layer
- **Repositories (Implementations)**: Concrete implementations of the Domain repositories. They coordinate data from various sources.
- **Data Sources**: Low-level classes that talk to APIs (Remote) or Local Databases.

#### 3. Presentation Layer (Shallowest)
- **State Management**: Uses `flutter_bloc` (specifically Cubits).
- **Pages**: Full-screen widgets.
- **Widgets**: Reusable components.

### Dependency Injection (DI)
We use **Manual Dependency Injection** via the `RepositoryProvider` and `BlocProvider` from the `flutter_bloc` package. 
- Repositories are injected at the top level in `main.dart`.
- Cubits are injected at the page level.

---

## Backend Architecture (Flask)

The backend is a lightweight REST API built with Flask.

### Components
- **App Factory**: `create_app()` initializes the Flask instance and extensions.
- **Blueprints**: Used to group related routes (e.g., `/api`).
- **Models**: SQLAlchemy ORM classes for database abstraction.
- **Routes**: Handle HTTP requests and implement business logic.

---

## Data Flow (Example: Tracking)

1. **UI**: `MapWidget` triggers `TrackingCubit`.
2. **Cubit**: Calls `TrackingRepository.watchLiveTrackingData()`.
3. **Repository**: Initiates a polling timer.
4. **Data Source**: Every 10 seconds, makes an HTTP GET request to `/api/processions/live`.
5. **Flowback**: Data moves from Source -> Repository -> Cubit -> UI (State Update).
