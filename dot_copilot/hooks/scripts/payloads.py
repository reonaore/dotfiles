"""Typed payload definitions for Copilot hook events.

Each payload class corresponds to a specific hook event and knows how to
parse itself from the raw JSON dict received on stdin.
"""
from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
from typing import Any

# The raw JSON object as decoded from stdin, before parsing into a payload.
RawPayload = dict[str, Any]


@dataclass(frozen=True)
class Payload(ABC):
    """Base class for all typed event payloads.

    Subclasses declare their own fields and how to build themselves from the
    raw JSON dict via :meth:`from_raw`.
    """

    #: The original raw dict, kept for debugging / forward-compatibility.
    raw: RawPayload

    @classmethod
    @abstractmethod
    def from_raw(cls, raw: RawPayload) -> "Payload":
        """Parse a typed payload from the raw JSON dict."""
        raise NotImplementedError

    @staticmethod
    def _tool_name(raw: RawPayload) -> str:
        """Best-effort extraction of a tool name from raw JSON."""
        name: Any = raw.get("toolName") or raw.get("tool_name") or raw.get("tool")
        return str(name) if name else "a tool"


@dataclass(frozen=True)
class PermissionRequestPayload(Payload):
    """Payload for a permissionRequest event."""

    tool_name: str

    @classmethod
    def from_raw(cls, raw: RawPayload) -> "PermissionRequestPayload":
        return cls(raw=raw, tool_name=cls._tool_name(raw))


@dataclass(frozen=True)
class NotificationPayload(Payload):
    """Payload for a notification event."""

    message: str
    notification_type: str

    @classmethod
    def from_raw(cls, raw: RawPayload) -> "NotificationPayload":
        message: str = str(raw.get("message") or "Copilot has a notification for you.")
        notification_type: str = str(
            raw.get("notification_type") or raw.get("notificationType") or "unknown"
        )
        return cls(raw=raw, message=message, notification_type=notification_type)


@dataclass(frozen=True)
class PreToolUsePayload(Payload):
    """Payload for a preToolUse event."""

    tool_name: str

    @classmethod
    def from_raw(cls, raw: RawPayload) -> "PreToolUsePayload":
        return cls(raw=raw, tool_name=cls._tool_name(raw))


@dataclass(frozen=True)
class UnknownPayload(Payload):
    """Fallback payload for events we don't explicitly handle."""

    @classmethod
    def from_raw(cls, raw: RawPayload) -> "UnknownPayload":
        return cls(raw=raw)


class SessionEndReason(str, Enum):
    """Why a Copilot session ended."""

    COMPLETE = "complete"
    ERROR = "error"
    ABORT = "abort"
    TIMEOUT = "timeout"
    USER_EXIT = "user_exit"
    UNKNOWN = "unknown"  # fallback for unexpected values

    @classmethod
    def from_value(cls, value: str) -> "SessionEndReason":
        """Map a raw string to a reason, or UNKNOWN if unrecognized."""
        try:
            return cls(value)
        except ValueError:
            return cls.UNKNOWN


@dataclass(frozen=True)
class SessionEndPayload(Payload):
    """Payload for a sessionEnd event."""

    reason: SessionEndReason

    @classmethod
    def from_raw(cls, raw: RawPayload) -> "SessionEndPayload":
        reason: SessionEndReason = SessionEndReason.from_value(str(raw.get("reason", "")))
        return cls(raw=raw, reason=reason)


@dataclass(frozen=True)
class StopPayload(Payload):
    """Payload for an agentStop / Stop event."""

    transcript_path: str
    stop_reason: str

    @classmethod
    def from_raw(cls, raw: RawPayload) -> "StopPayload":
        transcript_path: str = str(
            raw.get("transcriptPath") or raw.get("transcript_path") or ""
        )
        stop_reason: str = str(
            raw.get("stopReason") or raw.get("stop_reason") or "end_turn"
        )
        return cls(raw=raw, transcript_path=transcript_path, stop_reason=stop_reason)
