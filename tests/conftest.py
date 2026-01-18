"""Pytest configuration and fixtures for Dashtam Terminal tests."""

import pytest


@pytest.fixture
def app_name() -> str:
    """Return the application name."""
    return "dashtam-terminal"
