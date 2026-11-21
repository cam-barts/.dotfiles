#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///
r"""Fetch short URLs from Kutt (tldr.cam) and print them for Espanso choice.

Retrieves the API key from Bitwarden, hits the Kutt API, and outputs
each link as "label\nshort_url" pairs for Espanso's form list or choice.

Output format (one per line):
    short_url | target_domain | description
"""

import json
import subprocess
import sys
from pathlib import Path
from urllib.error import URLError
from urllib.parse import urlparse
from urllib.request import Request, urlopen

KUTT_PUBLIC = "https://tldr.cam"
BW_ITEM_NAME = "Kutt API Key"

SCRIPTS_DIR = Path(__file__).parent


def get_api_key() -> str | None:
    """Get the Kutt API key from Bitwarden via bw_get.py."""
    result = subprocess.run(
        ["uv", "run", str(SCRIPTS_DIR / "bw_get.py"), BW_ITEM_NAME, "--field", "notes"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode == 0 and result.stdout.strip():
        return result.stdout.strip()
    return None


def fetch_links(api_key: str) -> list[dict]:
    """Fetch all links from the Kutt API."""
    kutt_url = KUTT_PUBLIC

    all_links = []
    skip = 0
    limit = 50

    while True:
        url = f"{kutt_url}/api/v2/links?limit={limit}&skip={skip}"
        # KUTT_PUBLIC is a fixed https:// URL, so no file:/custom schemes reach urlopen.
        req = Request(url, headers={"X-API-KEY": api_key})  # noqa: S310

        try:
            with urlopen(req) as resp:  # noqa: S310
                data = json.loads(resp.read().decode())
        except URLError as e:
            print(f"API request failed: {e}", file=sys.stderr)
            break

        links = data.get("data", [])
        if not links:
            break

        all_links.extend(links)
        skip += limit

        if len(links) < limit:
            break

    return all_links


def format_link(link: dict) -> str:
    """Format a single link for display."""
    short = link.get("link", "")
    target = link.get("target", "")
    description = link.get("description", "")

    # Extract domain from target for readability
    try:
        domain = urlparse(target).netloc
    except ValueError:
        domain = target[:40]

    label_parts = [short]
    if description:
        label_parts.append(description)
    elif domain:
        label_parts.append(domain)

    return " | ".join(label_parts)


def main() -> None:
    """Print every Kutt short link, sorted, one per line."""
    api_key = get_api_key()
    if not api_key:
        print("Could not retrieve Kutt API key from Bitwarden", file=sys.stderr)
        sys.exit(1)

    links = fetch_links(api_key)
    if not links:
        print("No links found", file=sys.stderr)
        sys.exit(1)

    for link in sorted(links, key=lambda lk: lk.get("link", "")):
        print(format_link(link))


if __name__ == "__main__":
    main()
