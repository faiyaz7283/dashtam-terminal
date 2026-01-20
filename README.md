# Dashtam Terminal

> Bloomberg-style TUI for the Dashtam financial data platform

[![Documentation](https://img.shields.io/badge/docs-mkdocs-blue)](https://faiyaz7283.github.io/dashtam-terminal/)
[![Test Suite](https://github.com/faiyaz7283/dashtam-terminal/workflows/Test%20Suite/badge.svg)](https://github.com/faiyaz7283/dashtam-terminal/actions)
[![codecov](https://codecov.io/gh/faiyaz7283/dashtam-terminal/branch/development/graph/badge.svg)](https://codecov.io/gh/faiyaz7283/dashtam-terminal)
[![Python 3.14](https://img.shields.io/badge/python-3.14-blue.svg)](https://www.python.org/downloads/)
[![Textual](https://img.shields.io/badge/Textual-7.3+-green.svg)](https://textual.textualize.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A sophisticated terminal user interface (TUI) for the Dashtam financial data platform. Inspired by Bloomberg Terminal, it provides a rich, real-time interface for managing financial accounts, viewing transactions, monitoring holdings, and connecting to financial providers.

## Features

- **Full-screen TUI** — Beautiful terminal interface powered by Textual
- **Real-time updates** — Live data via WebSocket/SSE connections
- **Hybrid CLI** — Traditional command-line interface for scripting
- **Multi-profile** — Support for dev, staging, and production environments
- **Cross-platform** — Runs on macOS, Linux, Windows, and via SSH

## Requirements

- Docker & Docker Compose
- Access to Dashtam API (via `dashtam.local`)

## Quick Start

```bash
# Build and start development container
make docker-build
make docker-up

# Enter container shell
make docker-shell

# Inside container: initialize project (first time only)
uv init --package --name dashtam-terminal
uv add textual typer httpx httpx-ws httpx-sse questionary
uv add --dev pytest pytest-asyncio pytest-cov respx ruff mypy pre-commit textual-dev

# Run the TUI
make run
```

## Development

All development happens inside Docker containers:

```bash
# From host machine
make docker-shell     # Enter container
make docker-verify    # Run all checks
make docker-sync      # Sync dependencies

# Inside container
make verify           # Format, lint, type-check, test
make dev              # Run TUI with hot reload
make cli              # Run CLI
```

## Architecture

- **Hexagonal Architecture** — Domain at center, adapters at edges
- **Protocol-Based** — Structural typing with Python Protocols
- **CQRS** — Command/Query separation
- **Event-Driven** — Reactive UI with API event subscriptions

See the [design document](../references/CLI/dashtam-terminal-design.md) for full architecture details.

## License

MIT
