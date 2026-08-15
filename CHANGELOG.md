# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.4.0] - 2026-08-15

### Added
- **Tracker App (Background Tracking & UI/UX)**:
  - Persistent foreground service with sticky notification via `ForegroundNotificationConfig` and `enableWakeLock`
  - Manifest permissions: `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `POST_NOTIFICATIONS`, `WAKE_LOCK`
  - Interactive "Test Connessione" button with real-time feedback
  - Live GPS accuracy indicator (±X m) and background tracking banner
  - Confirmation dialog before stopping active procession tracking
- **Server (Path History & Metrics)**:
  - `GET /api/tracking/history/<confraternity_id>` endpoint for polyline trail rendering
  - `GET /api/stats` endpoint for system health & metrics
- **Mobile App (Map & Search Enhancements)**:
  - Dynamic `PolylineLayer` historical trail rendering on map with confraternity accent colors
  - Map style switcher (OpenStreetMap, Carto Light, Carto Dark)
  - Interactive `_FilterSheet` with municipality filter chips & search
  - Live search bar and municipality quick filter chips on `HomePage`
  - Cache management & App Info cards on `SettingsPage`

## [0.3.1] - 2026-08-15
- Snapshot before UI/UX & background tracking enhancements

## [0.3.0] - 2026-01-17

### Added
- **UX Enhancements**:
  - Municipality click → Weather page at correct tab
  - Marker labels appear on tap showing confraternity name
  - Map auto-zooms to fit all visible markers
  - Full gesture support (pan, zoom, pinch)
- **WeatherPage**: Converted to StatefulWidget with TabController for initial tab support
- **TrackingPage**: Converted to StatefulWidget with MapController for auto-zoom and improved marker interaction

### Changed
- `WeatherPageArgs` added for navigation with initial municipality
- `TrackingPageArgs` expanded for confraternity filtering
- Marker height increased to accommodate labels

## [0.2.0] - 2026-01-16

### Added
- **Tracking Navigation Modes**:
  - From HomePage: show all active processions
  - From ConfraternityDetailPage: filter to selected confraternity only
- **Colored Markers**: Map pins now use confraternity colors (#000000, #800080, etc.)
- **TrackingData Entity**: Added `color` and `name` fields

### Changed
- **Database Schema Refactoring**:
  - Deleted `Tracking` model (single position per procession)
  - Renamed `ProcessionLog` → `TrackingLog`
  - Added optional `procession_id` foreign key to `TrackingLog`
- **API Endpoints**:
  - Removed deprecated `/tracking/update` and `/tracking/stop`
  - Updated `/processions/live` to query `TrackingLog`
  - `/tracking/live` now includes `confraternity_name` and `confraternity_color`

### Breaking Changes
- Old `tracking` table no longer exists
- Client apps must use `/tracking/live` instead of `/tracking/update`

## [0.1.1] - 2026-01-16

### Added
- **OpenAPI/Swagger Documentation**: All endpoints documented with Flasgger
- **Swagger UI**: Available at `http://localhost:5000/docs`
- **Sample Tracking Data**: 33 GPS positions along Sorrento streets
- **Enriched API Responses**: `/tracking/live` includes confraternity name and color
- **New Endpoint**: `GET /api/processions` for listing all processions
- **Local Caching**: Confraternities cached with SharedPreferences
- **Italian Error Messages**: User-friendly error feedback

## [0.1.0] - 2026-01-12

### Added
- **Project Infrastructure**: Monorepo structure with `mobile/`, `server/`, `docs/`
- **Flutter Mobile App**:
  - Clean Architecture implementation
  - BLoC state management
  - Manual Dependency Injection
  - OpenStreetMap integration with flutter_map
  - Features: Home, Weather, Tracking, Confraternity Detail
- **Flask Backend**:
  - App factory with SQLAlchemy
  - Models: Confraternity, Procession, TrackingLog
  - REST API with API Key protection
  - Seed script with 8 real Sorrento confraternities
- **Documentation**: README, ARCHITECTURE, API_REFERENCE, DATABASE, CONTRIBUTING
