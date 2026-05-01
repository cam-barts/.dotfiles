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


def extract_title(filepath: Path) -> str:
    """Extract title from frontmatter or use filename."""
    try:
        with open(filepath, encoding="utf-8") as f:
            lines = f.readlines()
    except Exception:
        return filepath.stem

    in_frontmatter = False
    for line in lines:
        stripped = line.strip()
        if stripped == "---":
            if not in_frontmatter:
                in_frontmatter = True
                continue
            break
        if in_frontmatter and stripped.startswith("title:"):
            title = stripped[6:].strip().strip('"').strip("'")
            if title:
                return title

    # Fall back to first H1 heading
    for line in lines:
        if line.startswith("# "):
            return line[2:].strip()

    return filepath.stem


def extract_permalink(filepath: Path) -> str:
    """Extract permalink from frontmatter or derive from path."""
    try:
        with open(filepath, encoding="utf-8") as f:
            lines = f.readlines()
    except Exception:
        return ""

    in_frontmatter = False
    for line in lines:
        stripped = line.strip()
        if stripped == "---":
            if not in_frontmatter:
                in_frontmatter = True
                continue
            break
        if in_frontmatter and stripped.startswith("permalink:"):
            return stripped[10:].strip().strip('"').strip("'")

    return ""


def main() -> None:
    repo = find_quartz_repo()
    if not repo:
        print("Quartz repo not found", file=sys.stderr)
        sys.exit(1)

    content_dir = repo / "content"
    pages = []

    for md_file in sorted(content_dir.rglob("*.md")):
        # Skip hidden/meta directories
        rel = md_file.relative_to(content_dir)
        if any(part.startswith(".") or part.startswith("_") for part in rel.parts):
            continue
        if rel.parts and rel.parts[0] in ("templates", "private", "static", "tags"):
            continue

        title = extract_title(md_file)
        permalink = extract_permalink(md_file)

        url_path = permalink if permalink else f"/{rel.with_suffix('')}"
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
