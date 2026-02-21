# Server (Backend) — AI Agent Guidelines

> **Framework**: Python Flask
> **ORM**: SQLAlchemy · **Database**: SQLite
> **API Docs**: Flasgger (OpenAPI 3.0)

---

## 1. Purpose

This is the **REST API backend** for the Sorrento Holy Week Tracker project. It serves confraternity data, procession schedules, and GPS tracking positions to both the **mobile app** and the **tracker app**. It also provides a Swagger UI for API exploration and testing.

---

## 2. Architecture

The backend follows the **Application Factory** pattern (`create_app()`). It is lightweight and intentionally simple — no complex service layers or microservice decomposition.

### Key Design Decisions

- **Single-file routes** (`routes.py`) — all endpoints are in one Blueprint (`api_bp`).
- **Single-file models** (`models.py`) — all SQLAlchemy models live together.
- **Factory pattern** (`__init__.py`) — Flask app is created via `create_app()`, enabling test configuration overrides.
- **SQLite** — no external database server needed; the file `instance/holyweek.db` is created automatically.

---

## 3. Project Structure

```
server/
├── app/
│   ├── __init__.py        # Flask factory: create_app(), db, Swagger config, OpenAPI template
│   ├── models.py          # SQLAlchemy models: Confraternity, Procession, TrackingLog
│   └── routes.py          # API Blueprint: all endpoints with Flasgger docstrings
│
├── instance/              # Auto-created by Flask; contains holyweek.db (gitignored)
├── requirements.txt       # Python dependencies
├── run.py                 # Entry point: creates app and runs dev server on 0.0.0.0:5000
├── seed.py                # Populates database with 8 confraternities, processions, sample tracking data
└── test_tracking.py       # Integration test script for tracking endpoints
```

---

## 4. Database Schema

Three tables. See `docs/DATABASE.md` for the full schema.

### `confraternities`

| Column | Type | Description |
|--------|------|-------------|
| `id` | String (PK) | UUID |
| `name` | String | Official name |
| `color` | String | Hex color (`#000000`) |
| `municipality` | String | City (Sorrento, Meta, etc.) |
| `coat_of_arms` | String (nullable) | Path to image |
| `history` | Text (nullable) | Historical description |

### `processions`

| Column | Type | Description |
|--------|------|-------------|
| `id` | String (PK) | UUID |
| `confraternity_id` | String (FK) | → `confraternities.id` |
| `day` | String | "Giovedì Santo" / "Venerdì Santo" |
| `exit_time` | DateTime | Scheduled start |
| `expected_return_time` | DateTime (nullable) | Scheduled end |
| `is_live` | Boolean | Whether currently active |

### `tracking_logs`

| Column | Type | Description |
|--------|------|-------------|
| `id` | Integer (PK) | Auto-increment |
| `confraternity_id` | String (FK) | → `confraternities.id` |
| `procession_id` | String (FK, nullable) | → `processions.id` |
| `latitude` | Float | GPS latitude |
| `longitude` | Float | GPS longitude |
| `timestamp` | DateTime | Position time (UTC) |

**Index**: `(confraternity_id, timestamp DESC)` for efficient "latest position" queries.

### Relationships

```
Confraternity ──< Procession
Confraternity ──< TrackingLog
Procession    ──< TrackingLog
```

Each model has a `to_dict()` method for JSON serialization.

---

## 5. API Endpoints

All endpoints are prefixed with `/api` (Blueprint: `api_bp`).

### Health

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| `GET` | `/health` | None | Server status check |

Response: `{"status": "healthy", "timestamp": "..."}`

### Confraternities

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| `GET` | `/confraternities` | None | List all confraternities |
| `GET` | `/confraternities/<id>` | None | Get single confraternity |

### Processions

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| `GET` | `/processions` | None | List all with confraternity info (name, color, municipality) |
| `GET` | `/processions/live` | None | Active processions with latest tracking positions |

### Tracking (TrackingLog)

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| `POST` | `/tracking/log` | Capofila Secret | Log a GPS position |
| `GET` | `/tracking/live` | None | Latest position per confraternity |

---

## 6. Authentication

### POST `/tracking/log`

Requires a `secret` field in the JSON body:

```json
{
  "confraternity_id": "uuid-1",
  "lat": 40.6263,
  "lng": 14.3758,
  "secret": "capofila123"
}
```

The secret is validated against the constant `CAPOFILA_SECRET` in `routes.py`.

### API Key (Decorator)

A `@require_api_key` decorator exists in `routes.py` for protecting endpoints via the `X-API-Key` header. Currently only applied to specific endpoints as needed.

Default API key: `dev-api-key` (from env `API_KEY`).

---

## 7. Response Format Conventions

### Tracking Endpoints

```json
{
  "data": [ ... ],
  "error": null
}
```

### Confraternity / Procession Endpoints

Return arrays or objects directly (no wrapping).

### Error Responses

```json
{"error": "Confraternity not found"}
```

or

```json
{"data": null, "error": "Unauthorized - invalid secret"}
```

---

## 8. Swagger / OpenAPI

- **Swagger UI**: `http://localhost:5000/docs`
- **OpenAPI JSON**: `http://localhost:5000/apispec.json`

### Configuration

The Swagger config and OpenAPI template are defined in `app/__init__.py`:
- `swagger_config`: Route and UI settings.
- `swagger_template`: Full OpenAPI 3.0 template with schema definitions for `Confraternity`, `Procession`, `TrackingPosition`.

### Docstrings

Every route function includes a **Flasgger-format YAML docstring** that auto-generates the Swagger spec. When adding or modifying endpoints, you **MUST** update the docstring.

---

## 9. Seed Data

`seed.py` populates the database with:

- **8 confraternities** from real Sorrento Peninsula towns (Sorrento, Meta, Piano di Sorrento, Sant'Agnello, Vico Equense, Massa Lubrense).
- **8 processions** (Giovedì Santo / Venerdì Santo) linked to confraternities.
- **~30 sample tracking positions** along real GPS routes for demo/testing.

### Re-seeding

```bash
rm instance/holyweek.db && python seed.py
```

---

## 10. Technology Stack

| Concern | Package/Version |
|---------|----------------|
| Framework | `flask` ≥2.3.0 |
| ORM | `sqlalchemy` ≥2.0.0 |
| Flask-SQLAlchemy | ≥3.1.0 |
| CORS | `flask-cors` ≥4.0.0 |
| API Docs | `flasgger` ≥0.9.7 |
| HTTP Client | `requests` ≥2.31.0 |
| Database | SQLite (via SQLAlchemy) |
| Python | 3.10+ |

---

## 11. Strict Rules

### Type Hints

**Always** use Python type hints:

```python
def get_confraternity(confraternity_id: str) -> dict:
```

### SQLAlchemy ORM

Use SQLAlchemy for all database operations. **Do NOT write raw SQL** unless strictly necessary and documented.

### OpenAPI Docstrings

If you add or modify an endpoint, you **MUST** include/update the Flasgger YAML docstring for auto-generated Swagger docs.

### Response Standardization

- Tracking endpoints: `{"data": ..., "error": null}`
- Error responses: include meaningful `"error"` message with appropriate HTTP status code.

### Documentation Sync

When modifying endpoints, update `docs/API_REFERENCE.md` to match.

### Git Commits

Use **Conventional Commits**: `feat:`, `fix:`, `docs:`, `refactor:`.

---

## 12. Adding a New Endpoint

Follow this checklist:

1. **Model** (if new entity needed)
   - Add SQLAlchemy model class in `app/models.py`
   - Add `to_dict()` method
   - Add relationship if applicable

2. **Route**
   - Add route function in `app/routes.py`
   - Include full Flasgger YAML docstring
   - Use `@api_bp.route(...)` decorator
   - Apply `@require_api_key` if write operation

3. **OpenAPI Schema**
   - Add schema definition to `swagger_template["components"]["schemas"]` in `app/__init__.py` if new entity

4. **Seed Data** (if applicable)
   - Add seed data function in `seed.py`

5. **Documentation**
   - Update `docs/API_REFERENCE.md`

6. **Test**
   - Test via Swagger UI at `/docs`
   - (Optional) Add test case in `test_tracking.py`

---

## 13. Useful Commands

```bash
# Setup virtual environment
python -m venv venv && source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Seed database (creates instance/holyweek.db)
python seed.py

# Run dev server (debug mode, auto-reload, 0.0.0.0:5000)
python run.py

# Re-seed from scratch
rm instance/holyweek.db && python seed.py

# Run tracking API tests (server must be running)
python test_tracking.py
```

---

## 14. Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `DATABASE_URL` | `sqlite:///holyweek.db` | SQLAlchemy connection string |
| `SECRET_KEY` | `dev-secret-key` | Flask secret key |
| `API_KEY` | `dev-api-key` | API key for `X-API-Key` header auth |
| `CAPOFILA_SECRET` | `capofila123` | Secret for `POST /tracking/log` |
