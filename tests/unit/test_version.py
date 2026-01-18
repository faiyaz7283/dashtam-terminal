"""Unit tests for version and basic imports."""

from dashtam_terminal import __version__


def test_version_exists() -> None:
    """Test that version string is defined."""
    assert __version__ is not None
    assert isinstance(__version__, str)


def test_version_format() -> None:
    """Test that version follows semver format."""
    parts = __version__.split(".")
    assert len(parts) >= 2
    # Major and minor should be numeric
    assert parts[0].isdigit()
    assert parts[1].isdigit()
