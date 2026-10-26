# syntax=docker/dockerfile:1

# ---------- Stage 1: build the React frontend ----------
FROM node:22-alpine AS frontend-build

WORKDIR /frontend

# Install dependencies first so this layer is cached when only source code changes
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci

# Copy the frontend source and build static files into /frontend/dist
COPY frontend/ ./
RUN npm run build


# ---------- Stage 2: run the FastAPI backend ----------
FROM python:3.12-slim AS runtime

# Configuration: no .pyc files, unbuffered logs, no pip cache, app version
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore \
    APP_VERSION=1.0.0

WORKDIR /app

# Install Python dependencies
COPY backend/requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the backend source code and the built frontend from stage 1
COPY backend/ ./
COPY --from=frontend-build /frontend/dist ./static

# Run as a non-root user for better security
RUN useradd --create-home --uid 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# Mark the container unhealthy if the API stops responding
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/health')" || exit 1

# Command run when the container starts
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
