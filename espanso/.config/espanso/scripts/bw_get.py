#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///
"""Retrieve a secret from Bitwarden CLI.

Checks for an active BW_SESSION env var first. If the vault is locked,
prompts for the master password via zenity (Linux) or PowerShell (Windows),
unlocks, retrieves the secret, and prints it to stdout.

Usage:
    uv run bw_get.py <item_name> [--field password|notes|username]
"""

import os
import platform
import subprocess
import sys


def get_bw_session() -> str | None:
    """Return a valid BW_SESSION, prompting to unlock if needed."""
    session = os.environ.get("BW_SESSION", "")

    if session:
        result = subprocess.run(
            ["bw", "unlock", "--check", "--session", session],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            return session

    # Vault is locked — prompt for master password
    password = _prompt_password()
    if not password:
        return None

    result = subprocess.run(
        ["bw", "unlock", "--raw"],
        input=password,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print("Failed to unlock vault", file=sys.stderr)
        return None

    return result.stdout.strip()


def _prompt_password() -> str | None:
    """Prompt for master password using a platform-native masked dialog."""
    system = platform.system()

    if system == "Linux":
        result = subprocess.run(
            ["zenity", "--password", "--title=Bitwarden Unlock"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            return result.stdout.strip()

    elif system == "Windows":
        ps_cmd = (
            "[System.Runtime.InteropServices.Marshal]::PtrToStringAuto("
            "[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR("
            '(Read-Host "Bitwarden Master Password" -AsSecureString)))'
        )
        result = subprocess.run(
            ["powershell", "-NoProfile", "-Command", ps_cmd],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            return result.stdout.strip()

    return None


def bw_get(item_name: str, field: str = "password", session: str = "") -> str | None:
    """Get a field from a Bitwarden item by name."""
    cmd = ["bw", "get", field, item_name]
    if session:
        cmd.extend(["--session", session])

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"bw get failed: {result.stderr}", file=sys.stderr)
        return None

    return result.stdout.strip()


def main() -> None:
    if len(sys.argv) < 2:
        print(
            "Usage: bw_get.py <item_name> [--field password|notes|username]",
            file=sys.stderr,
        )
        sys.exit(1)

    item_name = sys.argv[1]
    field = "password"
    if "--field" in sys.argv:
        idx = sys.argv.index("--field")
        if idx + 1 < len(sys.argv):
            field = sys.argv[idx + 1]

    session = get_bw_session()
    if not session:
        sys.exit(1)

    value = bw_get(item_name, field, session)
    if value:
        print(value)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
