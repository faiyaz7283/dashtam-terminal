.PHONY: help docker-build docker-up docker-down docker-shell docker-run docker-cli \
        docker-verify docker-sync install sync lint format test test-cov type-check verify clean

# Default target
help:
	@echo "Dashtam Terminal - Development Commands"
	@echo ""
	@echo "Docker Commands (run from host):"
	@echo "  make docker-build    - Build development Docker image"
	@echo "  make docker-up       - Start container (detached)"
	@echo "  make docker-down     - Stop container"
	@echo "  make docker-shell    - Shell into running container"
	@echo "  make docker-run      - Run TUI (interactive)"
	@echo "  make docker-cli      - Run CLI command (CMD=\"...\")"
	@echo "  make docker-verify   - Run verification inside container"
	@echo "  make docker-sync     - Sync dependencies inside container"
	@echo ""
	@echo "Container Commands (run inside container):"
	@echo "  make install         - Install all dependencies"
	@echo "  make sync            - Sync dependencies with lock file"
	@echo "  make format          - Format code (ruff format)"
	@echo "  make lint            - Run linter (ruff check)"
	@echo "  make type-check      - Run type checker (mypy)"
	@echo "  make test            - Run tests"
	@echo "  make test-cov        - Run tests with coverage report"
	@echo "  make verify          - Run full verification"
	@echo "  make clean           - Remove build artifacts"

# =============================================================================
# Docker Commands (run from host machine)
# =============================================================================

# Build development image
docker-build:
	docker compose -f compose/docker-compose.dev.yml build

# Start container (detached)
docker-up:
	docker compose -f compose/docker-compose.dev.yml up -d

# Stop container
docker-down:
	docker compose -f compose/docker-compose.dev.yml down

# Shell into running container
docker-shell:
	docker compose -f compose/docker-compose.dev.yml exec app bash

# Run TUI (interactive)
docker-run:
	docker compose -f compose/docker-compose.dev.yml run --rm app dashtam

# Run CLI command
docker-cli:
	docker compose -f compose/docker-compose.dev.yml run --rm app dashtam-cli $(CMD)

# Run verification inside container
docker-verify:
	docker compose -f compose/docker-compose.dev.yml exec app make verify

# Sync dependencies (after adding new packages)
docker-sync:
	docker compose -f compose/docker-compose.dev.yml exec app uv sync --all-groups

# =============================================================================
# Container Commands (run inside Docker container)
# =============================================================================

# Install dependencies
install:
	uv sync --all-groups

# Sync with lock file
sync:
	uv sync

# Linting
lint:
	uv run ruff check src tests

# Format code
format:
	uv run ruff format src tests
	uv run ruff check --fix src tests

# Run tests
test:
	uv run pytest

# Run tests with coverage
test-cov:
	uv run pytest --cov=dashtam_terminal --cov-report=term-missing --cov-report=html

# Type checking
type-check:
	uv run mypy src

# Run full verification (sequential, fails fast)
verify:
	@echo "\n=== Formatting ==="
	uv run ruff format src tests
	@echo "\n=== Linting ==="
	uv run ruff check src tests
	@echo "\n=== Type Checking ==="
	uv run mypy src
	@echo "\n=== Running Tests ==="
	uv run pytest
	@echo "\n✅ All checks passed!"

# TUI development (with hot reload)
dev:
	uv run textual run --dev src/dashtam_terminal/main.py

# Run TUI
run:
	uv run dashtam

# Run CLI
cli:
	uv run dashtam-cli

# Clean build artifacts
clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf .ruff_cache/
	rm -rf htmlcov/
	rm -rf .coverage
	find . -type d -name __pycache__ -exec rm -rf {} +
