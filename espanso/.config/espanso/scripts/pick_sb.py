#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///
"""List SilverBullet pages via zk and print them for Espanso choice.

Output format (one per line):
    Page Title
"""

import os
import subprocess
import sys


def main() -> None:
    # Ensure zk can find the notebook
    env = os.environ.copy()
    env.setdefault("ZK_NOTEBOOK_DIR", os.path.expanduser("~/silverbullet"))

    # Add ~/.local/bin to PATH for zk
    local_bin = os.path.expanduser("~/.local/bin")
    env["PATH"] = f"{local_bin}:{env.get('PATH', '')}"

    result = subprocess.run(
        [
            "zk",
            "list",
            "--quiet",
            "--format",
            "{{filename-stem}}",
            "--sort",
            "modified-",
            "--limit",
            "100",
        ],
        capture_output=True,
        text=True,
        env=env,
    )

    if result.returncode != 0:
        print(f"zk list failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    lines = [
        line.strip() for line in result.stdout.strip().splitlines() if line.strip()
    ]
    if not lines:
        print("No pages found", file=sys.stderr)
        sys.exit(1)

    for line in lines:
        print(line)


if __name__ == "__main__":
    main()
