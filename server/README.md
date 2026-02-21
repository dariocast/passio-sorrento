# Holyweek Tracker API — Server

> REST API backend for the Sorrento Holy Week Tracker.  
> Built with **Python Flask**, **SQLAlchemy**, and **SQLite**.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start (Docker)](#quick-start-docker)
- [Manual Setup (Development)](#manual-setup-development)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [Docker Architecture](#docker-architecture)
- [Deployment Guide](#deployment-guide)
- [Maintenance & Operations](#maintenance--operations)
- [Troubleshooting](#troubleshooting)

---

## Overview

The server provides a REST API that serves:

| Resource          | Description                                                    |
| ----------------- | -------------------------------------------------------------- |
| **Confraternities** | Static data about the Sorrento Peninsula confraternities       |
| **Processions**     | Holy Week procession schedules and live status                 |
| **Tracking**        | Real-time GPS position logging and retrieval for processions   |

**Tech Stack**: Flask · SQLAlchemy · SQLite · Gunicorn · Flasgger (Swagger UI)

---

## Prerequisites

### Docker Deployment (recommended)

- [Docker Engine](https://docs.docker.com/engine/install/) ≥ 24.0
- [Docker Compose](https://docs.docker.com/compose/install/) ≥ 2.20 (included with Docker Desktop)

### Manual / Development

- Python 3.10+
- pip

---

## Quick Start (Docker)

### 1. Clone and navigate

```bash
git clone <repo-url>
cd incappucciati/server
```

### 2. Create an environment file

```bash
cp .env.example .env
# Edit .env with your production secrets
```

Or set variables inline:

```bash
export SECRET_KEY="your-flask-secret"
export API_KEY="your-api-key"
export CAPOFILA_SECRET="your-tracking-secret"
```

### 3. Build and start

```bash
# First run — build image and seed the database
SEED_DB=true docker compose up -d --build

# Subsequent runs — no seeding needed
docker compose up -d
```

### 4. Verify

```bash
# Check container health
docker compose ps

# Check API health endpoint
curl http://localhost:5000/api/health

# Open Swagger UI in browser
open http://localhost:5000/docs
```

### 5. Stop

```bash
docker compose down          # Stop containers (data persists)
docker compose down -v       # Stop AND delete database volume
```

---

## Manual Setup (Development)

```bash
cd server

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate        # macOS / Linux
# venv\Scripts\activate         # Windows

# Install dependencies
pip install -r requirements.txt

# Seed the database
python seed.py

# Run development server (with hot-reload)
python run.py
```

The dev server starts at `http://localhost:5000` with debug mode enabled.

---

## Configuration

All configuration is via **environment variables**. When using Docker Compose, set them in a `.env` file or pass them directly.

| Variable             | Default                     | Description                              |
| -------------------- | --------------------------- | ---------------------------------------- |
| `SECRET_KEY`         | `dev-secret-key`            | Flask session secret key                 |
| `DATABASE_URL`       | `sqlite:///holyweek.db`     | SQLAlchemy connection string             |
| `API_KEY`            | `dev-api-key`               | API key for `X-API-Key` header auth      |
| `CAPOFILA_SECRET`    | `capofila123`               | Secret for `POST /tracking/log` auth     |
| `SEED_DB`            | `false`                     | Set to `true` to seed data on container start |
| `GUNICORN_WORKERS`   | `2`                         | Number of Gunicorn worker processes      |
| `GUNICORN_TIMEOUT`   | `120`                       | Gunicorn worker timeout (seconds)        |
| `GUNICORN_BIND`      | `0.0.0.0:5000`              | Gunicorn bind address                    |
| `HOST_PORT`          | `5000`                      | Host port mapped to the container        |

### `.env.example`

```env
SECRET_KEY=change-me-in-production
API_KEY=change-me-in-production
CAPOFILA_SECRET=change-me-in-production
SEED_DB=false
HOST_PORT=5000
GUNICORN_WORKERS=2
```

> ⚠️ **Never commit `.env` files to version control.** The `.gitignore` already excludes them.

---

## API Reference

### Base URL

```
http://<host>:5000/api
```

### Endpoints

| Method | Endpoint                       | Auth              | Description                          |
| ------ | ------------------------------ | ----------------- | ------------------------------------ |
| `GET`  | `/api/health`                  | —                 | Server health check                  |
| `GET`  | `/api/confraternities`         | —                 | List all confraternities             |
| `GET`  | `/api/confraternities/<id>`    | —                 | Get a single confraternity           |
| `GET`  | `/api/processions`             | —                 | List all processions                 |
| `GET`  | `/api/processions/live`        | —                 | Get currently active processions     |
| `POST` | `/api/tracking/log`            | `secret` in body  | Log a GPS position                   |
| `GET`  | `/api/tracking/live`           | —                 | Latest position per confraternity    |

### Interactive Documentation

Swagger UI is available at **`/docs`** when the server is running.

For the full API specification, see [`docs/API_REFERENCE.md`](../docs/API_REFERENCE.md).

---

## Docker Architecture

### File Structure

```
server/
├── Dockerfile           # Multi-concern image: deps → app → entrypoint
├── docker-compose.yml   # Service definition, volumes, env vars
├── .dockerignore        # Files excluded from build context
├── entrypoint.sh        # Init script: DB setup → optional seed → Gunicorn
├── requirements.txt     # Python dependencies (including gunicorn)
├── run.py               # Flask app entry point
├── seed.py              # Database seeder
└── app/
    ├── __init__.py      # Flask factory, extensions, Swagger config
    ├── models.py        # SQLAlchemy models
    └── routes.py        # API Blueprint with all endpoints
```

### Image Details

| Aspect              | Choice                                             |
| ------------------- | -------------------------------------------------- |
| **Base image**       | `python:3.12-slim`                                |
| **WSGI server**      | Gunicorn (production-grade, multi-worker)          |
| **User**             | Non-root (`appuser`, UID 1000)                    |
| **Health check**     | `curl` against `/api/health` every 30s            |
| **Data persistence** | Named Docker volume for `instance/` (SQLite DB)   |

### Entrypoint Flow

```
entrypoint.sh
  ├─ 1. Initialize database tables (create_app)
  ├─ 2. If SEED_DB=true → run seed.py
  └─ 3. Start Gunicorn with configured workers
```

---

## Deployment Guide

### Remote Server Deployment

#### 1. Prepare the server

```bash
# Install Docker Engine (Ubuntu example)
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin

# Ensure the Docker service is running
sudo systemctl enable --now docker

# Add your user to the docker group (optional, avoids sudo)
sudo usermod -aG docker $USER
```

#### 2. Transfer the project

```bash
# Option A: Git clone
ssh your-server "git clone <repo-url> ~/incappucciati"

# Option B: rsync only the server directory
rsync -avz --exclude='venv' --exclude='instance' --exclude='__pycache__' \
    ./server/ your-server:~/incappucciati/server/
```

#### 3. Configure environment

```bash
ssh your-server
cd ~/incappucciati/server

# Create production .env
cat > .env << 'EOF'
SECRET_KEY=<generate-a-strong-random-key>
API_KEY=<generate-a-strong-random-key>
CAPOFILA_SECRET=<generate-a-strong-random-key>
SEED_DB=true
HOST_PORT=5000
GUNICORN_WORKERS=4
EOF
```

> 💡 Generate secure keys with: `python3 -c "import secrets; print(secrets.token_urlsafe(32))"`

#### 4. Build and deploy

```bash
# Build and start (first time with seeding)
docker compose up -d --build

# Verify
docker compose ps
docker compose logs -f api
curl http://localhost:5000/api/health
```

#### 5. Disable seeding for subsequent restarts

```bash
# Update .env
sed -i 's/SEED_DB=true/SEED_DB=false/' .env

# Restart to apply
docker compose up -d
```

### Reverse Proxy (Nginx)

For production, place Nginx in front of the API for TLS termination and static file serving:

```nginx
server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    ssl_certificate     /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name api.yourdomain.com;
    return 301 https://$host$request_uri;
}
```

### Firewall Rules

```bash
# Allow only HTTP/HTTPS traffic (if using Nginx as reverse proxy)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Or allow direct access to the API port
sudo ufw allow 5000/tcp
```

---

## Maintenance & Operations

### View Logs

```bash
docker compose logs -f api           # Follow live logs
docker compose logs --tail=100 api   # Last 100 lines
```

### Re-seed the Database

```bash
# Stop, remove volume, and restart with seeding
docker compose down -v
SEED_DB=true docker compose up -d
```

### Update the Application

```bash
# Pull latest code
git pull origin main

# Rebuild and restart (zero-downtime is not guaranteed with SQLite)
docker compose up -d --build
```

### Backup the Database

```bash
# Copy the SQLite file from the named volume
docker compose cp api:/app/instance/holyweek.db ./backup_$(date +%Y%m%d).db
```

### Restore a Backup

```bash
# Stop the container, copy the backup in, and restart
docker compose down
docker compose cp ./backup_20260401.db api:/app/instance/holyweek.db
docker compose up -d
```

### Run Tests

```bash
# With the container running
python test_tracking.py

# Or from inside the container
docker compose exec api python test_tracking.py
```

---

## Troubleshooting

### Container won't start

```bash
# Check logs for errors
docker compose logs api

# Common causes:
#   - Port 5000 already in use → change HOST_PORT in .env
#   - Permission issues → ensure instance/ is writable
```

### Database is empty

```bash
# Re-run with seeding enabled
docker compose down
SEED_DB=true docker compose up -d
```

### Health check failing

```bash
# Inspect the health check status
docker inspect --format='{{.State.Health}}' holyweek-api

# Test manually
docker compose exec api curl http://localhost:5000/api/health
```

### Permission denied on entrypoint.sh

```bash
# Fix file permissions (on host, before building)
chmod +x entrypoint.sh
docker compose up -d --build
```

---

## License

MIT — see the root [LICENSE](../LICENSE) file for details.
