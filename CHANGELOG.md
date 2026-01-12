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
- **Flask Server**:
  - App factory implementation.
  - SQLAlchemy models for Confraternities, Processions, and Tracking.
  - REST API blueprints with API Key protection.
- **Documentation**: Comprehensive `README.md` and `PRD.md`.
