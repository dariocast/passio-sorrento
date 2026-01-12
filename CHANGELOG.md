# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Project Infrastructure**: Initial monorepo structure with `mobile/`, `server/`, and `docs/`.
- **Flutter Mobile App**: 
  - Clean Architecture implementation (`core`, `features`).
  - Bloc state management with `flutter_bloc`.
  - Manual Dependency Injection via `RepositoryProvider`.
  - OpenStreetMap integration with `flutter_map`.
  - Initial feature scaffolds: `home`, `weather`, `tracking`.
  - **Home Feature - Data Layer**:
    - `ConfraternityModel` with JSON serialization matching API reference.
    - `MockHomeRepository` for offline development with hardcoded Sorrento confraternities.
    - `HomeRepositoryHttp` with platform-aware base URL (Android: `10.0.2.2`, iOS: `localhost`).
    - Custom exception classes for robust error handling.
- **Flask Server**:
  - App factory implementation.
  - SQLAlchemy models for Confraternities, Processions, and Tracking.
  - REST API blueprints with API Key protection.
  - **Seed Script** (`seed.py`): Populates database with 8 real Sorrento confraternities data.
  - **ProcessionLog Model**: Historical GPS position logging for capofila device.
  - **Tracking Endpoints**:
    - `POST /api/tracking/log` - Log GPS positions with capofila secret auth.
    - `GET /api/tracking/live` - Fetch latest position per confraternity.
  - **Test Script** (`test_tracking.py`): Comprehensive API endpoint verification.
- **Documentation**: 
  - Comprehensive `README.md` and `PRD.md`.
  - Detailed architecture breakdown in `docs/ARCHITECTURE.md`.
  - API Reference guide in `docs/API_REFERENCE.md`.
  - Database schema documentation in `docs/DATABASE.md`.
  - Developer contribution guide in `docs/CONTRIBUTING.md`.

## [0.1.0] - 2026-01-12

### Added
- Initial project bootstrap with monorepo structure.
- Backend: Confraternities API, Tracking API, seed data.
- Mobile: Clean Architecture scaffold with home, weather, tracking features.
- Documentation: Full API reference, architecture, and database schemas.
