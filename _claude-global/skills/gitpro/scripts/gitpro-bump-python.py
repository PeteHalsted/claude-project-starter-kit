#!/usr/bin/env python3
"""Bump version in pyproject.toml following semver."""

import re
import sys
from pathlib import Path


def bump_version(current: str, bump_type: str) -> str:
    """Bump version string according to semver."""
    match = re.match(r"^(\d+)\.(\d+)\.(\d+)", current)
    if not match:
        raise ValueError(f"Invalid version format: {current}")

    major, minor, patch = int(match.group(1)), int(match.group(2)), int(match.group(3))

    if bump_type == "major":
        return f"{major + 1}.0.0"
    elif bump_type == "minor":
        return f"{major}.{minor + 1}.0"
    elif bump_type == "patch":
        return f"{major}.{minor}.{patch + 1}"
    else:
        raise ValueError(f"Invalid bump type: {bump_type}")


def main():
    if len(sys.argv) != 2:
        print("Usage: gitpro-bump-python.py major|minor|patch", file=sys.stderr)
        sys.exit(1)

    bump_type = sys.argv[1]
    if bump_type not in ("major", "minor", "patch"):
        print(f"Invalid bump type: {bump_type}", file=sys.stderr)
        sys.exit(1)

    pyproject_path = Path("pyproject.toml")
    if not pyproject_path.exists():
        print("pyproject.toml not found", file=sys.stderr)
        sys.exit(1)

    content = pyproject_path.read_text()

    # Match version in [project] section
    pattern = r'(version\s*=\s*["\'])(\d+\.\d+\.\d+)(["\'])'
    match = re.search(pattern, content)

    if not match:
        print("Could not find version in pyproject.toml", file=sys.stderr)
        sys.exit(1)

    current_version = match.group(2)
    new_version = bump_version(current_version, bump_type)

    # Replace version
    new_content = re.sub(
        pattern,
        f'\\g<1>{new_version}\\g<3>',
        content,
        count=1
    )

    pyproject_path.write_text(new_content)

    # Also update __init__.py if it exists with __version__
    for init_path in Path(".").glob("*/__init__.py"):
        init_content = init_path.read_text()
        init_pattern = r'(__version__\s*=\s*["\'])(\d+\.\d+\.\d+)(["\'])'
        if re.search(init_pattern, init_content):
            new_init_content = re.sub(
                init_pattern,
                f'\\g<1>{new_version}\\g<3>',
                init_content,
                count=1
            )
            init_path.write_text(new_init_content)
            break  # Only update first match

    # Output new version (with v prefix for consistency with npm)
    print(f"v{new_version}")


if __name__ == "__main__":
    main()
