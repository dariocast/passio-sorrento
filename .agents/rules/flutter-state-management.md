---
trigger: always_on
---

---
description: Standards for flutter_bloc state management and error handling patterns.
globs: lib/**/presentation/**/*.dart, lib/**/domain/**/*.dart
---

# State Management & Error Handling

## 1. flutter_bloc Implementation
- **Bloc vs Cubit**: Use Bloc for complex, event-driven logic; use Cubit for simple state transitions.
- **Immutability**: States must be immutable. Use Dart `sealed class` with manual `copyWith` methods.
- **States**: Use sealed union types for standard states: `initial`, `loading`, `loaded`, and `error`.
- **UI Logic**: Use `BlocBuilder` for UI updates and `BlocListener` for side effects (navigation, snackbars).
- **Separation**: Keep business logic out of the UI; the UI only adds events and reads state.

## 2. State Definition Pattern

Use Dart 3 `sealed class` for type-safe state unions. Implement `copyWith` manually on states that hold mutable data.

```dart
sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Confraternity> confraternities;
  const HomeLoaded({required this.confraternities});

  HomeLoaded copyWith({List<Confraternity>? confraternities}) {
    return HomeLoaded(
      confraternities: confraternities ?? this.confraternities,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
}
```

## 3. Error Handling

- **Data Layer**: Use `try-catch` to capture exceptions from HTTP calls, platform APIs, and local storage. Convert them into domain-level error states or `Failure` strings.
- **Presentation Layer**: Do NOT use `try-catch`. The Cubit/Bloc handles errors by emitting an error state.
- **Error State**: Include a human-readable `message` and optionally a `canRetry` flag.

### Cubit Example

```dart
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit({required HomeRepository repository})
    : _repository = repository,
      super(const HomeInitial());

  Future<void> loadConfraternities() async {
    emit(const HomeLoading());
    try {
      final data = await _repository.getConfraternities();
      emit(HomeLoaded(confraternities: data));
    } catch (e) {
      emit(HomeError(message: 'Failed to load: $e'));
    }
  }
}
```

## 4. ⚠️ No Code Generation

**Do NOT add** `freezed`, `freezed_annotation`, `json_serializable`, or `build_runner`.
All states, events, models, and serialization are written **manually**.

## 5. Testing

* Use `bloc_test` for testing Cubits and Blocs.
* Mock dependencies (Repositories/Services) using `mocktail` or `mockito` and pass them via constructors in the `setUp` method.
