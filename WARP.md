# Dashtam Terminal — Project Rules and Context

**Purpose**: Project-specific rules for the Dashtam Terminal TUI application.

**Global Standards**: See `~/dashtam/WARP.md` for shared patterns (Python, Git, Docker, Testing).

**Design Document**: `~/references/CLI/dashtam-terminal-design.md`

---

## 1. Project Overview

**Dashtam Terminal** is a Bloomberg-style TUI for the Dashtam financial data platform.

**Core Features**:

- Full-screen terminal interface (Textual)
- Real-time data via WebSocket/SSE
- Extractable CLI companion (Typer)
- Keyboard-driven navigation

**Technology Stack**:

- **TUI Framework**: Textual 7.3+
- **CLI Framework**: Typer 0.21+
- **HTTP Client**: HTTPX (async) with httpx-sse, httpx-ws
- **Package Manager**: UV (NOT pip)
- **Python**: 3.14+

---

## 2. Architecture

### Layer Structure (Simplified Hexagonal)

```text
src/dashtam_terminal/
├── core/                 # Shared kernel
│   ├── config.py         # Settings, environment
│   ├── result.py         # Result[T, E] types
│   └── errors.py         # Error hierarchy
├── domain/               # Business logic (pure Python)
│   ├── models/           # Data models
│   ├── protocols/        # Interfaces
│   └── types.py          # Annotated types
├── infrastructure/       # External integrations
│   └── api/              # Dashtam API client (HTTPX)
└── presentation/         # User interface
    ├── tui/              # Textual screens and widgets
    │   ├── screens/      # Full-screen views
    │   ├── widgets/      # Reusable components
    │   └── app.py        # Main Textual app
    └── cli/              # Typer commands
        └── app.py        # CLI entry point
```

### Entry Points

```toml
[project.scripts]
dashtam = "dashtam_terminal.main:run_tui"        # TUI (default)
dashtam-cli = "dashtam_terminal.presentation.cli.app:app"  # CLI
```

---

## 3. API Client Patterns

### Async-First

All API calls are async (matches Dashtam API's async nature):

```python
class DashtamClient:
    async def get_accounts(self) -> Result[list[Account], APIError]:
        response = await self._client.get("/api/v1/accounts")
        if response.is_error:
            return Failure(error=APIError.from_response(response))
        return Success(value=[Account(**a) for a in response.json()])
```

### Real-Time Events (SSE)

```python
async def stream_events(self) -> AsyncIterator[Event]:
    async with httpx_sse.aconnect_sse(
        self._client, "GET", "/api/v1/events/stream"
    ) as event_source:
        async for sse in event_source.aiter_sse():
            yield Event.from_sse(sse)
```

---

## 4. TUI Patterns (Textual)

### Screen Management

```python
from textual.app import App, ComposeResult
from textual.screen import Screen

class DashboardScreen(Screen):
    """Main dashboard with account overview."""
    
    def compose(self) -> ComposeResult:
        yield Header()
        yield AccountsPanel()
        yield Footer()
    
    async def on_mount(self) -> None:
        """Load data when screen mounts."""
        await self.refresh_accounts()
```

### Keybindings

```python
BINDINGS = [
    ("q", "quit", "Quit"),
    ("r", "refresh", "Refresh"),
    ("a", "accounts", "Accounts"),
    ("t", "transactions", "Transactions"),
    ("/", "search", "Search"),
]
```

### Widget Communication

Use Textual's message system for widget-to-widget communication:

```python
class AccountSelected(Message):
    """Posted when user selects an account."""
    def __init__(self, account_id: UUID) -> None:
        self.account_id = account_id
        super().__init__()

# In parent screen
def on_account_selected(self, event: AccountSelected) -> None:
    self.query_one(TransactionsPanel).load(event.account_id)
```

---

## 5. CLI Patterns (Typer)

### Command Structure

```python
import typer

app = typer.Typer(help="Command-line interface for Dashtam API.")

@app.command()
def whoami() -> None:
    """Show the currently authenticated user."""
    ...

@app.command()
def accounts(
    format: str = typer.Option("table", help="Output format: table, json"),
) -> None:
    """List all accounts."""
    ...
```

### Shared Code with TUI

CLI and TUI share:
- `infrastructure/api/` — Same API client
- `domain/models/` — Same data models
- `core/` — Same config, errors, result types

Only `presentation/` layer differs.

---

## 6. Development Commands

```bash
# Environment
make dev-up          # Start dev environment
make dev-down        # Stop
make dev-shell       # Shell into container
make dev-logs        # View logs

# Inside container
dashtam              # Launch TUI
dashtam-cli --help   # CLI help
dashtam-cli accounts # List accounts

# Code quality
make lint            # Ruff linter
make format          # Ruff formatter
make type-check      # Mypy
make test            # Pytest
make verify          # All checks
```

---

## 7. Testing Strategy

### TUI Testing

Use Textual's test harness:

```python
from textual.testing import AppTest

async def test_dashboard_loads():
    app = AppTest(DashtamApp)
    async with app.run_test() as pilot:
        await pilot.press("a")  # Navigate to accounts
        assert app.query_one(AccountsScreen)
```

### CLI Testing

Use Typer's CliRunner:

```python
from typer.testing import CliRunner
from dashtam_terminal.presentation.cli.app import app

runner = CliRunner()

def test_whoami():
    result = runner.invoke(app, ["whoami"])
    assert result.exit_code == 0
```

### API Client Testing

Use respx for mocking HTTPX:

```python
import respx

@respx.mock
async def test_get_accounts():
    respx.get("/api/v1/accounts").respond(json=[...])
    result = await client.get_accounts()
    assert isinstance(result, Success)
```

---

## 8. Configuration

### Environment Variables

```bash
# env/.env.example
APP_NAME=dashtam-terminal
APP_ENV=development
DASHTAM_API_BASE_URL=https://dashtam.local
```

### Settings Class

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "dashtam-terminal"
    app_env: str = "development"
    dashtam_api_base_url: str = "https://dashtam.local"
    
    model_config = SettingsConfigDict(env_file="env/.env.dev")
```

---

## 9. Current Status

**Version**: 0.1.0 (Initial setup)

**Implemented**:
- [x] Project structure
- [x] Docker development environment
- [x] Entry points (dashtam, dashtam-cli)
- [x] GitHub Actions CI
- [x] MkDocs documentation

**Next Steps**:
- [ ] Core result types and errors
- [ ] API client infrastructure
- [ ] Authentication flow
- [ ] Basic TUI screens

---

## 10. Git Workflow

### Branch Structure

- `main` — Production-ready code (protected)
- `development` — Integration branch (protected)
- `feature/*` — New features (from development)
- `fix/*` — Bug fixes (from development)

### Release Checklist

1. [ ] Verify all milestone issues are closed (or moved to next milestone)
2. [ ] Update version in `pyproject.toml`
3. [ ] Run `uv lock` (inside dev container)
4. [ ] Update `CHANGELOG.md` with release notes (reference closed issues)
5. [ ] Commit, push, create PR to `development`
6. [ ] Wait for CI, merge PR to `development`
7. [ ] Create PR from `development` → `main`
8. [ ] Merge PR to `main`
9. [ ] Tag release: `git tag -a vX.Y.Z -m "message"`
10. [ ] Push tag: `git push origin vX.Y.Z`
11. [ ] Create GitHub Release: `gh release create vX.Y.Z --title "..." --notes "..."`
12. [ ] **SYNC BACK**: Merge `main` into `development`
13. [ ] Close the milestone on GitHub (if all issues complete)

### GitHub Issues Integration

**All feature development is tracked via GitHub Issues**. See `~/dashtam/WARP.md` Section 10 for the full workflow.

**Quick Reference**:

- **Branch naming**: `feature/issue-{N}-{slug}`
- **Commit format**: `type(scope): description (#N)`
- **PR body**: Include `Closes #N` for auto-linking and auto-close
- **Labels**: `status:in-progress`, `terminal`, feature labels

---

**Last Updated**: 2026-01-18
