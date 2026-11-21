#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///
"""List blog pages from the local Quartz repo for Espanso choice.

Scans the content directory for .md files, extracts titles from
frontmatter or filenames, and prints them for Espanso's choice picker.

Output format (one per line):
    Title | /permalink-or-path
"""

import sys
from pathlib import Path


def find_quartz_repo() -> Path | None:
    """Find the Quartz blog repo. Check common locations."""
    candidates = [
        Path.home() / "git" / "home" / "quartz",
        Path.home() / "git" / "home" / "cam-barts.github.io",
        Path.home() / "quartz",
    ]
    for p in candidates:
        if (p / "content").is_dir():
            return p
    return None


def read_lines(filepath: Path) -> list[str] | None:
    """Return the file's lines, or None if it can't be read."""
    try:
        with filepath.open(encoding="utf-8") as f:
            return f.readlines()
    except (OSError, UnicodeDecodeError):
        return None


def frontmatter_value(lines: list[str], key: str) -> str:
    """Return the first non-empty ``key:`` value in the YAML frontmatter."""
    prefix = f"{key}:"
    in_frontmatter = False
    for line in lines:
        stripped = line.strip()
        if stripped == "---":
            if in_frontmatter:
                break
            in_frontmatter = True
            continue
        if in_frontmatter and stripped.startswith(prefix):
            value = stripped.removeprefix(prefix).strip().strip('"').strip("'")
            if value:
                return value
    return ""


def extract_title(filepath: Path) -> str:
    """Extract title from frontmatter, the first H1, or the filename."""
    lines = read_lines(filepath)
    if lines is None:
        return filepath.stem
    if title := frontmatter_value(lines, "title"):
        return title
    # Fall back to first H1 heading
    for line in lines:
        if line.startswith("# "):
            return line[2:].strip()
    return filepath.stem


def extract_permalink(filepath: Path) -> str:
    """Extract permalink from frontmatter, or "" if there isn't one."""
    lines = read_lines(filepath)
    return frontmatter_value(lines, "permalink") if lines else ""


def main() -> None:
    """Print every publishable page as "title → path"."""
    repo = find_quartz_repo()
    if not repo:
        print("Quartz repo not found", file=sys.stderr)
        sys.exit(1)

    content_dir = repo / "content"
    pages = []

    for md_file in sorted(content_dir.rglob("*.md")):
        # Skip hidden/meta directories
        rel = md_file.relative_to(content_dir)
        if any(part.startswith((".", "_")) for part in rel.parts):
            continue
        if rel.parts and rel.parts[0] in ("templates", "private", "static", "tags"):
            continue

        title = extract_title(md_file)
        permalink = extract_permalink(md_file)

        url_path = permalink or f"/{rel.with_suffix('')}"
        pages.append((title, url_path))

    if not pages:
        print("No blog pages found", file=sys.stderr)
        sys.exit(1)

    # Output "title → path" so it's readable in the picker,
    # but use → as separator since | conflicts with YAML/shell
    for title, url_path in pages:
        print(f"{title} → {url_path}")


if __name__ == "__main__":
    main()
