#!/bin/bash
# =============================================================================
# Entrypoint script for Holyweek Tracker API container.
#
# Handles:
#   1. Database initialization (create tables if they don't exist)
#   2. Optional seeding via SEED_DB=true environment variable
#   3. Starting the Gunicorn WSGI server
# =============================================================================

set -e

echo "🚀 Starting Holyweek Tracker API..."

# ---------------------------------------------------------------------------
# 1. Database Initialization
# ---------------------------------------------------------------------------
echo "📦 Initializing database tables..."
python -c "from app import create_app; create_app()"

# ---------------------------------------------------------------------------
# 2. Optional Seeding
# ---------------------------------------------------------------------------
if [ "${SEED_DB}" = "true" ]; then
    echo "🌱 Seeding database with initial data..."
    python seed.py
fi

# ---------------------------------------------------------------------------
# 3. Start Gunicorn
# ---------------------------------------------------------------------------
WORKERS=${GUNICORN_WORKERS:-2}
BIND=${GUNICORN_BIND:-0.0.0.0:5000}
TIMEOUT=${GUNICORN_TIMEOUT:-120}

echo "🌐 Starting Gunicorn (workers=${WORKERS}, bind=${BIND})..."
exec gunicorn \
    --bind "${BIND}" \
    --workers "${WORKERS}" \
    --timeout "${TIMEOUT}" \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    "run:app"
