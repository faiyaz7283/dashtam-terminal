.PHONY: help setup dev-up dev-down dev-logs dev-shell dev-restart dev-status dev-build dev-rebuild \
        test lint format type-check verify clean check status-all ps

# ==============================================================================
# VARIABLES
# ==============================================================================

MARKDOWN_LINT_IMAGE := node:24-alpine
MARKDOWN_LINT_CMD := npx markdownlint-cli2

# ==============================================================================
# HELP
# ==============================================================================

.DEFAULT_GOAL := help

help:
	@echo "🎯 Dashtam Terminal - TUI for Dashtam Financial Platform"
	@echo ""
	@echo "📋 Quick Start:"
	@echo "  1. Start Traefik:     cd ~/docker-services/traefik && make up"
	@echo "  2. Start dev:         make dev-up"
	@echo "  3. Run TUI:           make dev-shell, then: dashtam"
	@echo ""
	@echo "🚀 Development:"
	@echo "  make dev-up          - Start development environment"
	@echo "  make dev-down        - Stop development environment"
	@echo "  make dev-logs        - View development logs (follow)"
	@echo "  make dev-shell       - Shell into app container"
	@echo "  make dev-restart     - Restart development environment"
	@echo "  make dev-build       - Build development containers"
	@echo "  make dev-rebuild     - Rebuild containers (no cache)"
	@echo "  make dev-status      - Show service status"
	@echo ""
	@echo "🖥️  Running (inside container):"
	@echo "  dashtam              - Launch TUI application"
	@echo "  dashtam-cli          - Run CLI commands"
	@echo "  dashtam-cli --help   - Show CLI help"
	@echo ""
	@echo "✨ Code Quality:"
	@echo "  make lint            - Run linters (ruff)"
	@echo "  make format          - Format code (ruff)"
	@echo "  make type-check      - Type check with mypy"
	@echo "  make test            - Run tests"
	@echo "  make verify          - 🔥 FULL verification (format, lint, type-check, test)"
	@echo ""
	@echo "🔧 Utilities:"
	@echo "  make setup           - First-time setup (idempotent)"
	@echo "  make check           - Verify Traefik is running"
	@echo "  make status-all      - Show all environment status"
	@echo "  make ps              - Show all Dashtam Terminal containers"
	@echo "  make clean           - Stop and clean environment"

# ==============================================================================
# SETUP
# ==============================================================================

setup:
	@echo "🚀 Dashtam Terminal First-Time Setup"
	@echo ""
	@echo "📝 Step 1: Creating env/.env.dev from template..."
	@if [ -f env/.env.dev ]; then \
		echo "  ℹ️  env/.env.dev already exists - skipping"; \
	else \
		cp env/.env.example env/.env.dev; \
		echo "  ✅ Created env/.env.dev"; \
	fi
	@echo ""
	@echo "🔍 Step 2: Checking Traefik..."
	@$(MAKE) _check-traefik-verbose || true
	@echo ""
	@echo "✅ Setup complete!"
	@echo ""
	@echo "📝 Next steps:"
	@echo "  1. Start Traefik (if not running):"
	@echo "     cd ~/docker-services/traefik && make up"
	@echo ""
	@echo "  2. Start development environment:"
	@echo "     make dev-up"

# ==============================================================================
# DEVELOPMENT ENVIRONMENT
# ==============================================================================

dev-up: _check-traefik _ensure-env-dev
	@echo "🚀 Starting DEVELOPMENT environment..."
	@docker compose -f compose/docker-compose.dev.yml up -d --remove-orphans
	@echo ""
	@echo "📦 Syncing dependencies..."
	@docker compose -f compose/docker-compose.dev.yml exec -T app uv sync --all-groups > /dev/null 2>&1 || docker compose -f compose/docker-compose.dev.yml exec app uv sync --all-groups
	@echo ""
	@echo "✅ Development environment started!"
	@echo ""
	@echo "🖥️  Usage:"
	@echo "   Shell:    make dev-shell"
	@echo "   TUI:      dashtam (inside shell)"
	@echo "   CLI:      dashtam-cli --help (inside shell)"
	@echo ""
	@echo "📋 Commands:"
	@echo "   Logs:     make dev-logs"
	@echo "   Restart:  make dev-restart"
	@echo "   Stop:     make dev-down"

dev-down:
	@echo "🛑 Stopping DEVELOPMENT environment..."
	@docker compose -f compose/docker-compose.dev.yml down
	@echo "✅ Development stopped"

dev-logs:
	@docker compose -f compose/docker-compose.dev.yml logs -f

dev-shell:
	@docker compose -f compose/docker-compose.dev.yml exec app /bin/bash

dev-restart: dev-down dev-up

dev-status:
	@echo "📊 Development Status:"
	@docker compose -f compose/docker-compose.dev.yml ps

dev-build: _check-traefik _ensure-env-dev
	@echo "🔨 Building DEVELOPMENT containers..."
	@docker compose -f compose/docker-compose.dev.yml build
	@echo "✅ Development containers built"

dev-rebuild: _check-traefik _ensure-env-dev
	@echo "🔨 Rebuilding DEVELOPMENT containers (no cache)..."
	@docker compose -f compose/docker-compose.dev.yml build --no-cache
	@echo "📦 Restarting with fresh dependencies..."
	@docker compose -f compose/docker-compose.dev.yml down
	@docker compose -f compose/docker-compose.dev.yml up -d --remove-orphans
	@echo "📦 Syncing dependencies..."
	@docker compose -f compose/docker-compose.dev.yml exec -T app uv sync --all-groups > /dev/null 2>&1 || docker compose -f compose/docker-compose.dev.yml exec app uv sync --all-groups
	@echo "✅ Development containers rebuilt"

# ==============================================================================
# CODE QUALITY
# ==============================================================================

lint: _ensure-dev-running
	@echo "🔍 Running linters..."
	@docker compose -f compose/docker-compose.dev.yml exec app uv run ruff check src/ tests/

format: _ensure-dev-running
	@echo "✨ Formatting code..."
	@docker compose -f compose/docker-compose.dev.yml exec app uv run ruff format src/ tests/
	@docker compose -f compose/docker-compose.dev.yml exec app uv run ruff check --fix src/ tests/

type-check: _ensure-dev-running
	@echo "🔍 Running type checks with mypy..."
	@docker compose -f compose/docker-compose.dev.yml exec -w /app app uv run mypy src tests

test: _ensure-dev-running
	@echo "🧪 Running tests..."
	@docker compose -f compose/docker-compose.dev.yml exec -T app uv run pytest tests/ -v --cov=src --cov-report=term-missing

# ==============================================================================
# COMPREHENSIVE VERIFICATION
# ==============================================================================

verify: _ensure-dev-running
	@echo "🔍 ====================================="
	@echo "🔍 COMPREHENSIVE VERIFICATION (fail-fast)"
	@echo "🔍 ====================================="
	@echo ""
	@echo "📋 Running 7 verification steps:"
	@echo "   1. Format (auto-fix)"
	@echo "   2. Lint"
	@echo "   3. Type check"
	@echo "   4. Tests"
	@echo "   5. Markdown linting - docs/"
	@echo "   6. Markdown linting - root files"
	@echo "   7. Documentation build"
	@echo ""
	@echo "⚠️  Fail-fast: Stops on first failure"
	@echo ""
	@echo "✨ Step 1/7: Formatting (auto-fix)..."; \
	docker compose -f compose/docker-compose.dev.yml exec -T app uv run ruff format src/ tests/ || { echo "❌ Format command failed"; exit 1; }; \
	docker compose -f compose/docker-compose.dev.yml exec -T app uv run ruff check --fix src/ tests/ || { echo "❌ Format check --fix failed"; exit 1; }; \
	echo "✅ Formatting completed"; \
	echo ""; \
	echo "🔍 Step 2/7: Linting..."; \
	docker compose -f compose/docker-compose.dev.yml exec -T app uv run ruff check src/ tests/ || { echo "❌ Lint failed - manual fixes required"; exit 1; }; \
	echo "✅ Lint passed"; \
	echo ""; \
	echo "🔍 Step 3/7: Type checking..."; \
	docker compose -f compose/docker-compose.dev.yml exec -T -w /app app uv run mypy src tests || { echo "❌ Type check failed - manual fixes required"; exit 1; }; \
	echo "✅ Type check passed"; \
	echo ""; \
	echo "🧪 Step 4/7: Running tests with coverage..."; \
	docker compose -f compose/docker-compose.dev.yml exec -T app uv run pytest tests/ -v --cov=src --cov-report=term-missing --cov-report=html || { echo "❌ Tests failed - manual fixes required"; exit 1; }; \
	echo "✅ Tests passed"; \
	echo ""; \
	echo "📝 Step 5/7: Linting docs/ markdown files..."; \
	docker run --rm -v $(PWD):/workspace:ro -w /workspace $(MARKDOWN_LINT_IMAGE) sh -c "$(MARKDOWN_LINT_CMD) 'docs/**/*.md' || exit 1" || { echo "❌ docs/ markdown linting failed - manual fixes required"; exit 1; }; \
	echo "✅ docs/ markdown linting passed"; \
	echo ""; \
	echo "📝 Step 6/7: Linting root markdown files..."; \
	docker run --rm -v $(PWD):/workspace:ro -w /workspace $(MARKDOWN_LINT_IMAGE) sh -c "$(MARKDOWN_LINT_CMD) 'README.md' 'CHANGELOG.md' 'WARP.md' || exit 1" || { echo "❌ Root markdown linting failed - manual fixes required"; exit 1; }; \
	echo "✅ Root markdown linting passed"; \
	echo ""; \
	echo "📚 Step 7/7: Building documentation (strict mode)..."; \
	docker compose -f compose/docker-compose.dev.yml exec -T app uv sync --all-groups > /dev/null 2>&1; \
	docker compose -f compose/docker-compose.dev.yml exec -T app uv run mkdocs build --strict 2>&1 | tee /tmp/mkdocs-build.log || true; \
	if grep -E "WARNING" /tmp/mkdocs-build.log | grep -v "griffe:" | grep -v "mkdocs_autorefs:" | grep -q .; then \
		echo "❌ Documentation warnings found (broken links, missing pages, etc.)"; \
		grep -E "WARNING" /tmp/mkdocs-build.log | grep -v "griffe:" | grep -v "mkdocs_autorefs:"; \
		exit 1; \
	fi; \
	if ! docker compose -f compose/docker-compose.dev.yml exec -T app test -d site; then \
		echo "❌ Documentation build failed - site/ directory not created"; \
		exit 1; \
	fi; \
	echo "✅ Documentation built successfully (griffe warnings ignored)"; \
	echo ""; \
	echo "🎉 ====================================="; \
	echo "🎉 ALL VERIFICATION CHECKS PASSED!"; \
	echo "🎉 ====================================="; \
	echo ""; \
	echo "📦 Ready for:"; \
	echo "   - Version bump"; \
	echo "   - CHANGELOG update"; \
	echo "   - Commit & PR"; \
	echo "   - Release tagging"

# ==============================================================================
# UTILITIES
# ==============================================================================

check:
	@echo "🔍 Checking setup..."
	@echo ""
	@echo "Docker:"
	@docker --version
	@docker compose version
	@echo ""
	@echo "Traefik:"
	@$(MAKE) _check-traefik-verbose
	@echo ""
	@echo "✅ All checks passed!"

status-all:
	@echo "=============== Development ==============="
	@docker compose -f compose/docker-compose.dev.yml ps 2>/dev/null || echo "Not running"
	@echo ""
	@echo "================ Traefik =================="
	@docker ps --filter "name=traefik" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "Not running"

ps:
	@echo "📊 Dashtam Terminal Containers:"
	@docker ps -a --filter "name=dashtam-terminal" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

clean:
	@echo "🧹 Cleaning development environment..."
	@docker compose -f compose/docker-compose.dev.yml down -v --remove-orphans 2>/dev/null || true
	@echo "✅ Cleanup complete"

# ==============================================================================
# INTERNAL HELPERS
# ==============================================================================

# Check if Traefik is running
_check-traefik:
	@docker ps | grep -q traefik || { \
		echo "❌ Traefik not running!"; \
		echo ""; \
		echo "Start Traefik:"; \
		echo "  cd ~/docker-services/traefik && make up"; \
		echo ""; \
		exit 1; \
	}

# Check Traefik with verbose output
_check-traefik-verbose:
	@if docker ps | grep -q traefik; then \
		echo "✅ Traefik is running"; \
		docker ps --filter "name=traefik" --format "   {{.Names}}: {{.Status}}"; \
	else \
		echo "❌ Traefik not running"; \
		echo "   Start: cd ~/docker-services/traefik && make up"; \
	fi

# Ensure .env.dev exists (idempotent copy from example)
_ensure-env-dev:
	@if [ ! -f env/.env.dev ]; then \
		echo "📋 Creating env/.env.dev from example..."; \
		cp env/.env.example env/.env.dev; \
		echo "✅ Created env/.env.dev"; \
	fi

# Ensure dev container is running
_ensure-dev-running:
	@docker compose -f compose/docker-compose.dev.yml ps -q app > /dev/null 2>&1 || $(MAKE) dev-up
