# syntax=docker/dockerfile:1

# =============================================================================
# Base Stage - Common setup for all environments
# =============================================================================
FROM ghcr.io/astral-sh/uv:0.9.21-python3.14-trixie AS base

# Install system dependencies (minimal for TUI app)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (same UID as host for file permissions)
RUN groupadd -r appuser -g 1000 && \
    useradd -r -u 1000 -g appuser -m -s /bin/bash appuser

# Set working directory and ownership
WORKDIR /app
RUN chown appuser:appuser /app

# Switch to non-root user
USER appuser

# Set environment variables for UV and Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

# =============================================================================
# Development Stage - Full tooling, interactive development
# =============================================================================
FROM base AS development

# Copy dependency files and package metadata
COPY --chown=appuser:appuser pyproject.toml uv.lock README.md ./

# Copy source package structure (needed for editable install)
COPY --chown=appuser:appuser src/ ./src/

# Install all dependencies including dev
RUN uv sync --frozen --all-groups

# Copy remaining application files
COPY --chown=appuser:appuser . .

# Default command - shell for interactive development
CMD ["bash"]

# =============================================================================
# Builder Stage - Production dependency installation
# =============================================================================
FROM base AS builder

COPY --chown=appuser:appuser pyproject.toml uv.lock ./

# Install production dependencies only
RUN uv sync --frozen --no-dev

# =============================================================================
# Production Stage - Minimal runtime (for distribution)
# =============================================================================
FROM python:3.14-slim AS production

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r appuser -g 1000 && \
    useradd -r -u 1000 -g appuser -m -s /bin/bash appuser

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

COPY --from=builder --chown=appuser:appuser /app/.venv /app/.venv
COPY --chown=appuser:appuser . .

USER appuser

# Default entrypoint - launch TUI
ENTRYPOINT ["dashtam"]
