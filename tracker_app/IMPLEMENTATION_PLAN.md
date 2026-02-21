# Tracker App — Implementation Plan (Option A)

> **Obiettivo**: Rendere il tracker_app production-ready per l'uso durante le processioni reali.

---

## Step 1: Allineamento Dipendenze ✅
- [x] `flutter_bloc` ^8.1.0 → ^9.1.1
- [x] `http` ^1.2.0 → ^1.6.0
- [x] Aggiunto `bloc_test: ^10.0.0` e `mocktail: ^1.0.4` per testing

## Step 2: Rafforzamento Architettura ✅
- [x] Creato `domain/repositories/tracking_repository.dart` (abstract)
- [x] Creato `data/repositories/tracking_repository_impl.dart` (implementazione)
- [x] Rinominato `LogPositionResult` in ApiClient → `ApiLogResult` (separazione domain/data)
- [x] Refactored `TrackingCubit` per dipendere da `TrackingRepository` (abstract)
- [x] Introdotto `repositoryFactory` pattern per gestione URL dinamica
- [x] Aggiornato `main.dart` per wiring via constructor injection

## Step 3: Offline Queue ✅
- [x] Creato `data/services/offline_queue_service.dart`
- [x] Buffer posizioni in SharedPreferences quando offline
- [x] Sync automatico quando la connessione ritorna (flush in `_onPositionUpdate`)
- [x] Aggiornato `TrackingCubit` per gestire la coda
- [x] Aggiunto `queuedCount` a `TrackingActive` state
- [x] UI mostra conteggio posizioni in coda con colore arancione

## Step 4: Foreground Service + Background Tracking ⬜
- [ ] Aggiungere `flutter_background_service` al pubspec.yaml
- [ ] Implementare foreground notification persistente (Android)
- [ ] Garantire tracking GPS quando l'app è in background
- [ ] Aggiornare AndroidManifest.xml con permessi necessari

## Step 5: Battery Awareness ⬜
- [ ] Aggiungere `battery_plus` al pubspec.yaml
- [ ] Ridurre GPS accuracy quando batteria < 20%
- [ ] Mostrare stato batteria nella UI

## Step 6: Testing ✅
- [x] `tracking_cubit_test.dart` con mock services (11 test)
  - [x] initialize: success, partial failure, full failure
  - [x] startTracking: validation, permission granted, permission denied
  - [x] stopTracking: state transition
  - [x] updateConfig: persistence verification
- [x] `offline_queue_service_test.dart` (serialization roundtrip)

---

## Riepilogo File Creati/Modificati

### Nuovi File
- `lib/domain/repositories/tracking_repository.dart` — Abstract repository interface
- `lib/data/repositories/tracking_repository_impl.dart` — HTTP implementation
- `lib/data/services/offline_queue_service.dart` — Offline position buffer
- `test/presentation/cubit/tracking_cubit_test.dart` — Cubit test suite
- `test/data/services/offline_queue_service_test.dart` — Queue serialization tests

### File Modificati
- `pubspec.yaml` — Version bumps + testing deps
- `lib/data/api/api_client.dart` — Renamed LogPositionResult to ApiLogResult
- `lib/presentation/cubit/tracking_cubit.dart` — Major refactor (repository abstraction + offline queue)
- `lib/presentation/cubit/tracking_state.dart` — Added queuedCount field
- `lib/presentation/pages/home_page.dart` — Added queue display in active view
- `lib/main.dart` — Updated DI wiring

---

*Creato: 2026-02-21 | Ultimo aggiornamento: 2026-02-21*
