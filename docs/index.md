# Dashtam Terminal

Welcome to the **Dashtam Terminal** documentation — a Bloomberg-style Terminal User Interface (TUI) for the [Dashtam](https://github.com/faiyaz7283/Dashtam) financial data platform.

## Overview

Dashtam Terminal provides a sophisticated, full-screen terminal interface for accessing and managing your financial data through the Dashtam API. Built with [Textual](https://textual.textualize.io/), it offers:

- **Real-time Data** — WebSocket/SSE integration for live market updates
- **Multi-Panel Layout** — Bloomberg Terminal-inspired design
- **Keyboard-Driven** — Efficient navigation without leaving the terminal
- **CLI Companion** — Extractable CLI tool for scripting and automation

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Access to a running Dashtam API instance

### Installation

```bash
# Clone the repository
git clone https://github.com/faiyaz7283/dashtam-terminal.git
cd dashtam-terminal

# Start development environment
make dev-up

# Enter the container
make dev-shell

# Launch the TUI
dashtam

# Or use the CLI
dashtam-cli --help
```

## Architecture

Dashtam Terminal follows the same architectural principles as the Dashtam API:

- **Hexagonal Architecture** — Clean separation of concerns
- **Protocol-Based Design** — Structural typing for flexibility
- **Railway-Oriented Error Handling** — Explicit Result types
- **Domain-Driven Design** — Rich domain models

## Documentation Sections

- **Code Reference** — Auto-generated API documentation (see sidebar)

## Links

- [GitHub Repository](https://github.com/faiyaz7283/dashtam-terminal)
- [Dashtam API](https://github.com/faiyaz7283/Dashtam)
- [Issue Tracker](https://github.com/faiyaz7283/dashtam-terminal/issues)
