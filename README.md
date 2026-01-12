# Sorrento Holy Week Tracker (Incappucciati)

A mobile application and backend server to digitize the experience of the Holy Week processions in the Sorrento Peninsula.

## 🏛️ Project Structure

```
incappucciati/
├── mobile/          # Flutter mobile application
├── server/          # Python Flask backend
├── docs/            # Project documentation
├── PRD.md           # Product Requirements Document
└── README.md        # This file
```

## 🎯 Architecture Decisions

### Mobile App (Flutter)

The mobile application follows **Clean Architecture** principles with a layered "Onion Architecture":

| Layer | Purpose | Dependencies |
|-------|---------|--------------|
| **Presentation** | UI, Blocs/Cubits, Widgets | Domain |
| **Domain** | Entities, Use Cases, Repository Interfaces | None (pure Dart) |
| **Data** | Repository Implementations, Data Sources | Domain, External Packages |

#### Technology Stack

| Concern | Technology | Rationale |
|---------|------------|-----------|
| **State Management** | `flutter_bloc` | Predictable state, separation of concerns |
| **Networking** | `http` | Simple, no code generation required |
| **Dependency Injection** | Manual DI via `RepositoryProvider` | No complex setup, explicit dependencies |
| **Maps** | `flutter_map` | OpenStreetMap, no API key required |
| **Coordinates** | `latlong2` | Works with flutter_map |
| **Formatting** | `intl` | Date/time and currency formatting |
| **Equality** | `equatable` | Value equality for state objects |

> ⚠️ **Code Generation is strictly forbidden** - No `build_runner`, `json_serializable`, or `freezed`.

#### Feature Structure

Each feature follows the same structure:

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/    # Remote/Local data sources
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Domain models
│   └── repositories/   # Repository interfaces
└── presentation/
    ├── cubit/          # Cubit + State
    ├── pages/          # Full screen widgets
    └── widgets/        # Reusable UI components
```

### Backend Server (Python/Flask)

The backend uses a simple, scalable Flask structure:

| Component | Purpose |
|-----------|---------|
| **App Factory** | `app/__init__.py` - Application setup |
| **Models** | `app/models.py` - SQLAlchemy ORM models |
| **Routes** | `app/routes.py` - API endpoints |
| **Entry Point** | `run.py` - Development server |

#### Technology Stack

| Concern | Technology | Rationale |
|---------|------------|-----------|
| **Framework** | Flask | Lightweight, flexible |
| **ORM** | SQLAlchemy | Pythonic database access |
| **Database** | SQLite | Simple, easy backup/restore |
| **CORS** | Flask-CORS | Enable cross-origin requests |

## 🚀 Getting Started

### Mobile App

```bash
cd mobile

# Get dependencies
flutter pub get

# Run the app
flutter run

# Analyze code
flutter analyze
```

### Backend Server

```bash
cd server

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python run.py
```

## 🔌 API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/health` | Health check | No |
| GET | `/api/confraternities` | List all confraternities | No |
| GET | `/api/confraternities/<id>` | Get confraternity details | No |
| GET | `/api/processions/live` | Get live procession tracking | No |
| POST | `/api/tracking/update` | Update procession location | API Key |
| POST | `/api/tracking/stop/<id>` | Stop tracking a procession | API Key |

## 📁 Features

### 1. Home Dashboard
- List of confraternities with their identifying colors
- Live status indicator for active processions
- Navigation to detail views

### 2. Weather Section
- Geolocated forecasts for Sorrento Peninsula municipalities
- Focus on precipitation probability (crucial for procession exit)

### 3. Live Tracking
- Interactive OpenStreetMap
- Custom markers for each confraternity
- Real-time position updates via polling

## 🔐 Environment Variables

### Backend Server

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | SQLite database path | `sqlite:///holyweek.db` |
| `SECRET_KEY` | Flask secret key | `dev-secret-key` |
| `API_KEY` | API key for protected endpoints | `dev-api-key` |

### Mobile App

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENWEATHER_API_KEY` | OpenWeatherMap API key | (empty) |

Pass to Flutter: `flutter run --dart-define=OPENWEATHER_API_KEY=your_key`

## 📜 License

This project is for educational and community purposes.
