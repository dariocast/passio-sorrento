# =============================================================================
# Holyweek Tracker API — Dockerfile
# Python Flask application with Gunicorn WSGI server
# =============================================================================

# ---------------------------------------------------------------------------
# Stage: Runtime
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS runtime

# Prevent Python from writing .pyc files and enable unbuffered stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies required by some Python packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid appuser --shell /bin/bash --create-home appuser

# Set working directory
WORKDIR /app

# Install Python dependencies first (better layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY app/ ./app/
COPY run.py .
COPY seed.py .
COPY entrypoint.sh .

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Create the instance directory for SQLite and set ownership
RUN mkdir -p /app/instance \
    && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 5000

# Health check against the API health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

# Use the entrypoint script to handle initialization
ENTRYPOINT ["./entrypoint.sh"]
