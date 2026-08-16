# Passio Sorrento — Settimana Santa in Penisola Sorrentina

A complete digital ecosystem (public mobile app, procession GPS tracker app, backend API, and landing page) to experience Holy Week processions in the Sorrento Peninsula.

## 🏛️ Project Structure

```
passio-sorrento/
├── landing/         # Modern landing page (HTML5, Vanilla CSS, JS)
├── mobile/          # Flutter public mobile application (iOS & Android)
├── tracker_app/     # Flutter procession GPS tracker app (Android foreground service)
├── server/          # Python Flask backend (REST API, Swagger, Admin UI)
├── docs/            # Project documentation (Architecture, API Reference, Database)
├── CHANGELOG.md
└── README.md
```

## ✨ Features

### 📱 Mobile App
| Feature | Description |
|---------|-------------|
| **Home Dashboard** | Confraternity list with colors, live status indicators |
| **Confraternity Detail** | History, municipality (clickable → weather) |
| **Live Tracking** | Interactive map with colored markers, auto-zoom, labels on tap |
| **Weather** | Municipality tabs, precipitation focus |

### 🖥️ Backend API
| Endpoint | Purpose |
|----------|---------|
| `GET /confraternities` | List all confraternities |
| `GET /processions` | List all processions |
| `GET /tracking/live` | Latest positions with colors |
| `POST /tracking/log` | Log GPS position (capofila) |

**Swagger UI**: `http://localhost:5000/docs`

---

## 🎯 Architecture

### Mobile (Flutter)
- **Clean Architecture** with Domain/Data/Presentation layers
- **State Management**: flutter_bloc (Cubits)
- **Maps**: flutter_map (OpenStreetMap)
- **Caching**: SharedPreferences for offline resilience

### Backend (Flask)
- **ORM**: SQLAlchemy with SQLite
- **API Docs**: Flasgger (OpenAPI 3.0)
- **Models**: Confraternity, Procession, TrackingLog

> ⚠️ **No code generation** - All serialization is manual.

---

## 🚀 Quick Start

### Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

### Backend Server
```bash
cd server
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python seed.py  # Creates database with sample data
python run.py   # Starts server at http://localhost:5000
```

---

## 🔌 API Quick Reference

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/api/confraternities` | None |
| GET | `/api/confraternities/<id>` | None |
| GET | `/api/processions` | None |
| GET | `/api/processions/live` | None |
| GET | `/api/tracking/live` | None |
| POST | `/api/tracking/log` | Capofila Secret |

See [docs/API_REFERENCE.md](docs/API_REFERENCE.md) for full details.

---

## 🔐 Environment Variables

### Backend
| Variable | Default |
|----------|---------|
| `API_KEY` | `dev-api-key` |
| `CAPOFILA_SECRET` | `capofila123` |

### Mobile
| Variable | Usage |
|----------|-------|
| `OPENWEATHER_API_KEY` | `flutter run --dart-define=OPENWEATHER_API_KEY=xxx` |

---

## 📚 Documentation

- [Architecture](docs/ARCHITECTURE.md) - System design and layers
- [API Reference](docs/API_REFERENCE.md) - Endpoint documentation
- [Database Schema](docs/DATABASE.md) - Table structures
- [Contributing](docs/CONTRIBUTING.md) - Development guide

---

## 📜 License

Educational and community purposes.
