#!/usr/bin/env python3
"""Copilot hook handler: notifies you via terminal-notifier when Copilot
needs input or permission.

Reads the hook event JSON from stdin, sends a notification, and exits with
code 0 so Copilot continues normally.

Requires terminal-notifier:  brew install terminal-notifier
"""
from __future__ import annotations

import json
import subprocess
import sys
from typing import Any

from events import Notification, HookEventBase, build_event
from payloads import RawPayload


# Ghostty's macOS bundle identifier — clicking a notification focuses it.
GHOSTTY_BUNDLE_ID: str = "com.mitchellh.ghostty"
# Group id so new notifications replace old ones instead of stacking up.
NOTIFICATION_GROUP: str = "copilot"


def read_raw() -> RawPayload:
    """Read and parse the raw JSON payload from stdin (may be empty)."""
    raw: str = sys.stdin.read().strip()
    if not raw:
        return {}
    try:
        parsed: Any = json.loads(raw)
    except json.JSONDecodeError:
        return {"_raw": raw}
    # Guard against non-object JSON (e.g. a bare string or list).
    return parsed if isinstance(parsed, dict) else {"_raw": raw}


def notify(notification: Notification) -> None:
    """Send a notification via terminal-notifier (best-effort)."""
    command: list[str] = [
        "terminal-notifier",
        "-title", notification.title,
        "-message", notification.message,
        "-sound", notification.sound,
        "-group", NOTIFICATION_GROUP,
        "-activate", GHOSTTY_BUNDLE_ID,
    ]
    try:
        subprocess.run(command, check=False)
    except FileNotFoundError:
        # terminal-notifier not installed; log to stderr so it's not silent.
        print(f"[notify] {notification.title}: {notification.message}", file=sys.stderr)


def main() -> None:
    raw: RawPayload = read_raw()
    event_name: str = str(raw.get("hook_event_name", "unknown"))

    event: HookEventBase = build_event(event_name, raw)
    if event.should_notify():
        notify(event.to_notification())

    # Exit 0 = continue normally. Non-zero would block the operation.
    sys.exit(0)


if __name__ == "__main__":
    main()
