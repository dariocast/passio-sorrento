# Mobile App — AI Agent Guidelines

> **Package name**: `holyweek`
> **Framework**: Flutter 3.x+ · Dart SDK ^3.9.2

---

## 1. Purpose

This is the public-facing Flutter mobile application for the **Sorrento Holy Week Tracker (Incappucciati)** project. It allows users to browse confraternities, watch live GPS-tracked processions on a map, and check weather conditions across the Sorrento Peninsula municipalities.

---

## 2. Architecture

The app follows **Clean Architecture** with **Feature-First** organization. Every feature is a self-contained module.

### Layer Diagram

```
┌───────────────────────────────────────────┐
│          Presentation Layer               │
│    (Pages, Widgets, Cubits/BLoC)          │
├───────────────────────────────────────────┤
│            Domain Layer                   │
│    (Entities, Repository Interfaces)      │
├───────────────────────────────────────────┤
│             Data Layer                    │
│    (Implementations, Data Sources, DTOs)  │
└───────────────────────────────────────────┘
```

### Dependency Rule (CRITICAL)

- **Dependencies always point inward**: `Data` → `Domain` ← `Presentation`.
- The **Domain layer has ZERO external dependencies** — no Flutter imports, no packages, just pure Dart.
- The `Data` layer implements the abstract repository interfaces defined in `Domain`.
- The `Presentation` layer reads state from `Cubits` and never calls `DataSources` directly.

---

## 3. Project Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── components/       # Shared widgets (AppCard, LiveBadge, SkeletonLoader, etc.)
│   │   ├── constants/        # App-wide constants
│   │   ├── failures/         # Failure classes & error messages
│   │   ├── navigation/       # AppShell (bottom nav bar)
│   │   ├── router/           # AppRouter (go_router), route names, typed Args classes
│   │   ├── theme/            # AppTheme, AppColors, AppTextTheme
│   │   ├── usecases/         # Base UseCase interface
│   │   └── utils/            # Color, responsive utilities
│   │
│   ├── features/
│   │   ├── home/
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # HomeLocalDataSource, HomeRemoteDataSource
│   │   │   │   ├── models/        # ConfraternityModel (DTO)
│   │   │   │   └── repositories/  # HomeRepositoryHttp, HomeRepositoryCached, MockHomeRepository
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # Confraternity, Procession
│   │   │   │   └── repositories/  # HomeRepository (abstract)
│   │   │   └── presentation/
│   │   │       ├── cubit/         # HomeCubit, HomeState
│   │   │       └── pages/         # HomePage, ConfraternityDetailPage
│   │   │
│   │   ├── tracking/
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # TrackingRemoteDataSource
│   │   │   │   └── repositories/  # TrackingRepositoryImpl
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # TrackingData
│   │   │   │   └── repositories/  # TrackingRepository (abstract)
│   │   │   └── presentation/
│   │   │       ├── cubit/         # TrackingCubit, TrackingState
│   │   │       └── pages/         # TrackingPage
│   │   │
│   │   ├── weather/
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # WeatherRemoteDataSource (OpenWeatherMap)
│   │   │   │   └── repositories/  # WeatherRepositoryImpl
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # Weather
│   │   │   │   └── repositories/  # WeatherRepository (abstract)
│   │   │   └── presentation/
│   │   │       ├── cubit/         # WeatherCubit, WeatherState
│   │   │       └── pages/         # WeatherPage (municipality tabs)
│   │   │
│   │   └── settings/
│   │       └── presentation/
│   │           ├── cubit/         # SettingsCubit, SettingsState
│   │           └── pages/         # SettingsPage
│   │
│   └── main.dart                  # Entry point, DI wiring
│
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 4. Dependency Injection

**Pure Constructor Injection — NO service locators (no GetIt).**

All wiring happens in `main.dart` → `HolyweekApp.build()`:

1. Create a shared `http.Client`.
2. Instantiate **DataSources** (remote & local).
3. Instantiate **Repository implementations**, injecting DataSources.
4. Provide repositories via `MultiRepositoryProvider` (from `flutter_bloc`).
5. Cubits are created at **page level** with scoped lifecycle via `BlocProvider`.

### Wiring Pattern

```dart
// In main.dart build():
final httpClient = http.Client();
final homeRemoteDataSource = HomeRemoteDataSource(client: httpClient);
final homeLocalDataSource = HomeLocalDataSource();
final homeRepository = HomeRepositoryCached(
  remoteRepository: HomeRepositoryHttp(client: httpClient),
  localDataSource: homeLocalDataSource,
);

// Provide at root level
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<HomeRepository>.value(value: homeRepository),
    // ... tracking, weather repositories
  ],
  child: /* MaterialApp.router */,
);
```

---

## 5. State Management

- **Library**: `flutter_bloc` (Cubits for all features).
- **State Pattern**: Sealed classes — `initial`, `loading`, `loaded`, `error`.
- **UI**: `BlocBuilder` for rendering, `BlocListener` for side effects.
- **Business logic stays OUT of the UI** — the UI only adds events / calls cubit methods and reads state.

---

## 6. Navigation & Routing

- **Library**: `go_router`.
- **Structure**: `core/router/app_router.dart`.
- **Shell route** wraps the bottom navigation tabs: Home (`/`), Weather (`/weather`), Tracking (`/tracking`), Settings (`/settings`).
- **Detail routes** (e.g., `/confraternity/:id`) open outside the shell as full-screen pages with slide transitions.
- **Typed Args classes**: `ConfraternityDetailArgs`, `TrackingPageArgs`, `WeatherPageArgs`.
- **Navigation extension**: `BuildContext.goToConfraternity()`, `goToWeather()`, `goToTracking()`.

### Adding a New Route

1. Add path constant in `AppRoutes`.
2. Add name constant in `RouteNames`.
3. Create a typed `Args` class if arguments are needed.
4. Add `GoRoute` entry in the router tree.
5. (Optional) Add extension method on `BuildContext` for convenient navigation.

---

## 7. Features Summary

| Feature | Cubit | Key Behavior |
|---------|-------|--------------|
| **Home** | `HomeCubit` | Fetches confraternities, groups by municipality, local caching via `HomeRepositoryCached`, offline fallback |
| **Tracking** | `TrackingCubit` | Polls `GET /api/tracking/live` every 10s, renders colored markers on `flutter_map`, auto-zoom |
| **Weather** | `WeatherCubit` | Calls OpenWeatherMap API, municipality tabs, precipitation focus |
| **Settings** | `SettingsCubit` | Theme mode toggle via SharedPreferences |

---

## 8. Backend Integration

The mobile app connects to the Flask backend at `http://localhost:5000/api` (configurable).

### Consumed Endpoints

| Endpoint | Feature | Purpose |
|----------|---------|---------|
| `GET /api/confraternities` | Home | Fetch all confraternities |
| `GET /api/confraternities/<id>` | Home | Fetch single confraternity detail |
| `GET /api/processions` | Home | Fetch procession schedule |
| `GET /api/processions/live` | Tracking | Check which processions are active |
| `GET /api/tracking/live` | Tracking | Latest GPS positions per confraternity (with `confraternity_name`, `confraternity_color`) |

### Response Format

All tracking endpoints return: `{"data": ..., "error": null}`.
Confraternity/Procession endpoints return arrays or objects directly.

### Offline Resilience

- `HomeRepositoryCached` wraps `HomeRepositoryHttp` with a `HomeLocalDataSource` (SharedPreferences).
- First load: fetch from network → cache locally.
- Subsequent loads: serve from cache, refresh in background.

---

## 9. Technology Stack

| Concern | Package |
|---------|---------|
| Framework | Flutter 3.x |
| State Management | `flutter_bloc` ^9.1.1 |
| HTTP Client | `http` ^1.6.0 |
| Maps | `flutter_map` ^8.2.2 + `latlong2` ^0.9.1 |
| Routing | `go_router` ^14.0.0 |
| Caching | `shared_preferences` ^2.5.4 |
| Charts | `fl_chart` ^0.68.0 |
| Fonts | `google_fonts` ^6.2.1 |
| Loading UI | `shimmer` ^3.0.0 |
| Image Caching | `cached_network_image` ^3.4.0 |
| Date Formatting | `intl` ^0.20.2 |

---

## 10. Strict Rules

### ⚠️ No Code Generation

**Do NOT add** `build_runner`, `freezed`, `json_serializable`, or any codegen package.
All serialization (JSON ↔ Entity) is **manual** (`fromJson` / `toJson` / `fromMap`).

### ⚠️ No Service Locators

**Do NOT use** `GetIt`, `injectable`, or any service locator pattern.
All dependency injection is done through **constructors** and `RepositoryProvider` / `BlocProvider`.

### Clean Architecture Boundaries

- `Domain` layer: **no Flutter imports**, no `package:` dependencies beyond `dart:core`.
- `Data` layer: implements `Domain` interfaces, handles JSON parsing, HTTP calls, caching.
- `Presentation` layer: only calls Cubit/Bloc methods, never touches DataSources directly.

### Coding Standards

- Use `const` constructors for widgets whenever possible.
- Keep functions under **30 lines**.
- Follow **SOLID** principles (especially Dependency Inversion).
- Sound **Null Safety** — no `!` operator unless absolutely necessary and documented.
- Follow standard `flutter_lints` rules.

### Git Commits

Use **Conventional Commits**: `feat:`, `fix:`, `docs:`, `refactor:`, `style:`, `test:`.

---

## 11. Adding a New Feature

Follow this checklist in order:

1. **Domain Layer**
   - Create entity in `lib/features/<feature>/domain/entities/`
   - Define abstract repository in `lib/features/<feature>/domain/repositories/`

2. **Data Layer**
   - Create data source(s) in `lib/features/<feature>/data/datasources/`
   - (Optional) Create model/DTO in `lib/features/<feature>/data/models/`
   - Create repository implementation in `lib/features/<feature>/data/repositories/`

3. **Presentation Layer**
   - Create Cubit & State in `lib/features/<feature>/presentation/cubit/`
   - Create Page in `lib/features/<feature>/presentation/pages/`

4. **DI Wiring**
   - Instantiate data sources, repositories, and cubits in `main.dart`
   - Provide repository via `RepositoryProvider`

5. **Routing**
   - Add route path/name in `app_router.dart`
   - Create `Args` class if needed
   - Add `GoRoute` entry

---

## 12. Useful Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run with OpenWeatherMap API key
flutter run --dart-define=OPENWEATHER_API_KEY=your_key_here

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 13. Environment Variables

| Variable | How to Pass | Default |
|----------|-------------|---------|
| `OPENWEATHER_API_KEY` | `--dart-define=OPENWEATHER_API_KEY=xxx` | Hardcoded dev key in `main.dart` |
