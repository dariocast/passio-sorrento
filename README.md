# Sorrento Holy Week Tracker (Incappucciati)

A mobile application and backend server to digitize the Holy Week processions experience in the Sorrento Peninsula.

## 🏛️ Project Structure

```
incappucciati/
├── mobile/          # Flutter mobile application
├── server/          # Python Flask backend
├── docs/            # Project documentation
│   ├── ARCHITECTURE.md
│   ├── API_REFERENCE.md
│   ├── DATABASE.md
│   └── CONTRIBUTING.md
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
