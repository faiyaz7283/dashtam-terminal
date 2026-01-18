"""Dashtam CLI - Command-line interface for Dashtam API.

This module provides the Typer CLI application.
"""

import typer
from rich.console import Console

from dashtam_terminal import __version__

app = typer.Typer(
    name="dashtam-cli",
    help="Command-line interface for Dashtam API.",
    no_args_is_help=True,
    rich_markup_mode="rich",
)

console = Console()


@app.callback()
def main(
    version: bool = typer.Option(
        False,
        "--version",
        "-v",
        help="Show version and exit.",
        is_eager=True,
    ),
) -> None:
    """Dashtam CLI - Manage financial data from the command line."""
    if version:
        console.print(f"dashtam-cli version {__version__}")
        raise typer.Exit()


@app.command()
def whoami() -> None:
    """Show the currently authenticated user."""
    console.print("[yellow]Not implemented yet.[/yellow]")


if __name__ == "__main__":
    app()
