# Dashtam Terminal — Project Rules and Context

**Purpose**: Terminal-specific rules and architecture. For shared rules, see `~/dashtam/WARP.md`.

**⚠️ IMPORTANT**: See `~/dashtam/WARP.md` for WARP.md structure rules. Do NOT duplicate Global rules here.

---

## Global Rules Reference

**See `~/dashtam/WARP.md` for complete definitions of these universal rules:**

- **Rule 1**: Repository Structure (meta repo, submodules)
- **Rule 2**: Development Philosophy (clean architecture, type safety, latest stable)
- **Rule 3**: Modern Python Patterns (Protocol over ABC, type hints, Result types)
- **Rule 4**: Docker Containerization (Makefile commands, code quality)
- **Rule 5**: Git Workflow (branches, conventional commits, releases)
- **Rule 6**: Code Quality Standards (Ruff, mypy, docstrings)
- **Rule 7**: Testing Philosophy (coverage targets, test types)
- **Rule 8**: Environment Configuration (.env files, idempotent setup)
- **Rule 9**: Documentation Standards (markdown linting, MkDocs)
- **Rule 10**: AI Agent Instructions (mandatory pre-development process)
- **Rule 11**: GitHub Project (unified platform tracking)
- **Rule 12**: GitHub Issues Workflow (issue lifecycle, labels, milestones)

---

## Terminal-Specific Rules

### 1. Technology Stack

**TUI Framework**: Textual (latest stable)
**CLI Framework**: Typer (latest stable)
**API Client**: httpx (latest stable) with async
**Package Manager**: UV (latest stable)
**Build Backend**: uv_build
**Entry Points**: CLI (`dashtam`) and TUI (`dashtam-tui`)
**Testing**: pytest with Textual Pilot
**CI/CD**: GitHub Actions

**Version Policy**: Always use latest stable versions. Check `pyproject.toml` for current versions.

### 2. Architecture: Simplified Hexagonal

**Layer Structure**:

```
src/dashtam_terminal/
├── domain/             # Business logic (API models, validation)
│   ├── models/         # Pydantic models from API
│   └── protocols/      # Interface definitions
├── application/        # Use cases
│   ├── api_client/     # API communication layer
│   └── commands/       # Business operations
├── adapters/           # External integrations
│   └── api/            # HTTP client implementations
├── ui/                 # User interfaces
│   ├── tui/            # Textual screens/widgets
│   └── cli/            # Typer commands
└── config.py           # Configuration management
```

**Dependency Rule**:
- ✅ UI depends on Application (calls commands)
- ✅ Application depends on Domain (uses models, protocols)
- ✅ Adapters implement Domain protocols
- ❌ Domain NEVER depends on UI or Adapters

### 3. Entry Points

**Two entry points** (defined in `pyproject.toml`):

```toml
[project.scripts]
dashtam = "dashtam_terminal.ui.cli.main:app"
dashtam-tui = "dashtam_terminal.ui.tui.main:run"
```

**Usage**:

```bash
dashtam --help           # CLI interface
dashtam login            # CLI login command
dashtam-tui              # Launch TUI
```

### 4. API Client Patterns

**Async-First**:

```python
import httpx
from dashtam_terminal.config import settings

async with httpx.AsyncClient(
    base_url=settings.api_url,
    headers={"Authorization": f"Bearer {token}"}
) as client:
    response = await client.get("/api/v1/accounts")
```

**Real-Time Events (SSE)**:

```python
async def stream_events():
    async with httpx.AsyncClient() as client:
        async with client.stream("GET", f"{api_url}/api/v1/events") as response:
            async for line in response.aiter_lines():
                if line.startswith("data: "):
                    data = json.loads(line[6:])
                    yield data
```

**Authentication Flow**:
1. User provides credentials
2. Call `POST /sessions` (API endpoint)
3. Store access token securely
4. Refresh token before expiration

### 5. TUI Patterns (Textual)

**Screen Management**:

```python
from textual.app import App
from textual.screen import Screen

class DashboardScreen(Screen):
    def compose(self):
        yield Header()
        yield AccountsTable()
        yield Footer()

class TerminalApp(App):
    def on_mount(self):
        self.push_screen(DashboardScreen())
```

**Keybindings**:

```python
class DashboardScreen(Screen):
    BINDINGS = [
        ("q", "quit", "Quit"),
        ("r", "refresh", "Refresh"),
        ("a", "show_accounts", "Accounts"),
    ]
    
    def action_refresh(self):
        # Refresh data logic
        ...
```

**Widget Communication**:

```python
# Post message
self.post_message(AccountSelected(account_id=123))

# In parent screen
def on_account_selected(self, event: AccountSelected):
    self.push_screen(AccountDetailScreen(account_id=event.account_id))
```

### 6. CLI Patterns (Typer)

**Command Structure**:

```python
import typer

app = typer.Typer()

@app.command()
def login(
    email: str = typer.Option(..., prompt=True),
    password: str = typer.Option(..., prompt=True, hide_input=True),
):
    """Authenticate with Dashtam API."""
    # Login logic
    ...

@app.command()
def accounts():
    """List all accounts."""
    # Fetch and display accounts
    ...
```

**Shared Code with TUI**:

Both TUI and CLI use the same:
- API client (`application/api_client/`)
- Business logic (`application/commands/`)
- Domain models (`domain/models/`)

**Only UI layer differs** (TUI uses Textual, CLI uses Typer output).

### 7. Development Commands

**Environment**:

```bash
make dev-up        # Start terminal dev environment
make dev-down      # Stop environment
make dev-shell     # Shell into terminal container
```

**Inside container**:

```bash
uv run dashtam --help      # Test CLI
uv run dashtam-tui         # Test TUI
```

**Code quality**:

```bash
make lint          # Run ruff
make format        # Format code
make type-check    # Run mypy
make test          # Run tests
make verify        # Full verification
```

### 8. Testing Strategy

**TUI Testing** (Textual Pilot):

```python
from textual.pilot import Pilot

async def test_dashboard_screen():
    app = TerminalApp()
    async with app.run_test() as pilot:
        await pilot.press("a")  # Press 'a' key
        assert pilot.app.screen.id == "accounts"
```

**CLI Testing**:

```python
from typer.testing import CliRunner

def test_login_command():
    runner = CliRunner()
    result = runner.invoke(app, ["login"], input="user@example.com\npassword\n")
    assert result.exit_code == 0
    assert "Login successful" in result.output
```

**API Client Testing**:

```python
import respx
import httpx

@respx.mock
async def test_fetch_accounts():
    respx.get(f"{api_url}/api/v1/accounts").mock(
        return_value=httpx.Response(200, json=[...])
    )
    accounts = await api_client.get_accounts()
    assert len(accounts) > 0
```

### 9. Configuration

**Environment Variables**:

```
DASHTAM_API_URL=https://dashtam.local/api/v1
DASHTAM_API_TOKEN=<access-token>
DASHTAM_LOG_LEVEL=INFO
```

**Settings Class**:

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    api_url: str
    api_token: str | None = None
    log_level: str = "INFO"

    model_config = {
        "env_prefix": "DASHTAM_",
        "env_file": ".env",
    }

settings = Settings()
```

### 10. Package Structure (Nested src-layout)

**Why nested `src/dashtam_terminal/` instead of flat `src/`?**

**Reason**: Terminal is a **CLI application** installed via `uv pip install -e .` or distributed as a package. The `uv_build` backend requires the nested layout for proper entry point resolution.

**Structure**:

```
dashtam-terminal/
├── src/
│   └── dashtam_terminal/       # Package name
│       ├── __init__.py
│       ├── domain/
│       ├── application/
│       ├── adapters/
│       └── ui/
├── tests/
├── pyproject.toml
└── README.md
```

**Imports**:

```python
from dashtam_terminal.domain.models import Account
from dashtam_terminal.application.api_client import ApiClient
```

**Entry Points**:

```toml
[project.scripts]
dashtam = "dashtam_terminal.ui.cli.main:app"
dashtam-tui = "dashtam_terminal.ui.tui.main:run"
```

**Consequences**:
- Terminal uses `src/dashtam_terminal/` structure
- API uses flat `src/` structure
- This is intentional — different packaging requirements
- Imports use `from dashtam_terminal import ...`

**Alternatives Considered**:
- `hatchling` backend: More flexible but adds complexity
- Remove entry points: Poor UX
- Flat src with uv_build config: Limited support, fragile

---

**Last Updated**: 2026-01-21
