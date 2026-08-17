# Passio Sorrento — Mobile App (iOS & Android)

Applicazione pubblica ufficiale per consultare e vivere i riti della Settimana Santa nella Penisola Sorrentina.

## 📱 Funzionalità Principali

* **Mappa GPS Live**: Tracciamento in tempo reale dei cortei su mappa OpenStreetMap (`flutter_map` + `latlong2`).
* **Schede Confraternite**: Dettagli storici, stemmi ad alta risoluzione in caching (`cached_network_image`), colore del saio e orari ufficiali.
* **Meteo Live per Comune**: Integrazione diretta con Open-Meteo per monitorare pioggia e vento nei 6 comuni peninsulari.
* **Supporto Offline**: Memorizzazione locale dei programmi e degli itinerari via `shared_preferences`.

## 🏗️ Architettura

* **Pattern**: Clean Architecture con Feature-First organization (`core/`, `features/home/`, `features/tracking/`, `features/weather/`, `features/settings/`).
* **State Management**: `flutter_bloc` (Cubit per ogni modulo con sealed classes).
* **Dependency Injection**: Constructor injection tramite `RepositoryProvider` e `BlocProvider`.
* **Zero Code Generation**: Modelli e serializzazioni scritti a mano (`fromJson` / `toJson`).

## 🚀 Esecuzione in Locale

```bash
flutter pub get
flutter run
```

## 🧪 Test & Analisi

```bash
flutter analyze lib
flutter test
```
