"""Dashtam Terminal - Entry point module.

This module provides the main entry points for the application:
- run_tui(): Launch the Textual TUI application
- The CLI app is in presentation/cli/app.py
"""

from rich.console import Console

console = Console()


def run_tui() -> None:
    """Launch the Textual TUI application.

    This is the default entry point when running `dashtam` command.
    """
    console.print("[yellow]TUI not implemented yet.[/yellow]")
    console.print("Run [bold]dashtam-cli --help[/bold] for CLI commands.")


if __name__ == "__main__":
    run_tui()
