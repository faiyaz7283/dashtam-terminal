# Changelog

All notable changes to dashtam-terminal will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-01-18

### Added

- **Initial Release** - Foundation for Dashtam Terminal TUI application

- **Project Structure**
  - Nested src-layout (`src/dashtam_terminal/`) for installable package
  - Entry points: `dashtam` (TUI), `dashtam-cli` (CLI companion)
  - Hexagonal architecture with presentation/domain/infrastructure layers

- **Core Infrastructure**
  - Textual 7.3+ for TUI framework
  - Typer 0.21+ for CLI framework
  - HTTPX with SSE/WebSocket extensions for async API client
  - Pydantic Settings for configuration

- **Development Infrastructure**
  - Docker Compose development environment
  - Docker Compose CI environment
  - Makefile with development workflow targets
  - GitHub Actions CI/CD pipeline
  - MkDocs Material documentation site

- **Code Quality**
  - Ruff for linting and formatting
  - Mypy for type checking
  - pytest with coverage reporting
  - Markdown linting

### Technical Notes

- **Python**: 3.14+
- **Key Dependencies**: textual, typer, httpx, httpx-sse, httpx-ws
- **Package Manager**: UV (not pip)
