"""Copilot hook event definitions.

Each event class pairs a Copilot event name with its typed payload and
notification logic. Add new events by subclassing HookEventBase and
registering the class in EVENT_REGISTRY.
"""
from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import ClassVar

from payloads import (
    NotificationPayload,
    PermissionRequestPayload,
    PreToolUsePayload,
    RawPayload,
    Payload,
    SessionEndPayload,
    SessionEndReason,
    StopPayload,
    UnknownPayload,
)


@dataclass(frozen=True)
class Notification:
    """A fully-described notification ready to be sent."""

    title: str
    message: str
    sound: str


class HookEventBase(ABC):
    """Base class for all Copilot hook events."""

    #: The Copilot event name this class handles (set by each subclass).
    event_name: ClassVar[str]
    #: The payload type this event parses raw JSON into.
    payload_type: ClassVar[type[Payload]]

    def __init__(self, payload: Payload) -> None:
        self.payload: Payload = payload

    @classmethod
    def from_raw(cls, raw: RawPayload) -> "HookEventBase":
        """Build the event, parsing raw JSON into its typed payload."""
        return cls(cls.payload_type.from_raw(raw))

    @abstractmethod
    def to_notification(self) -> Notification:
        """Build the notification for this event."""
        raise NotImplementedError

    def should_notify(self) -> bool:
        """Whether this event should emit a user notification."""
        return True


class PermissionRequestEvent(HookEventBase):
    """Fires before Copilot asks permission to run a tool."""

    event_name: ClassVar[str] = "permissionRequest"
    payload_type: ClassVar[type[Payload]] = PermissionRequestPayload

    def to_notification(self) -> Notification:
        assert isinstance(self.payload, PermissionRequestPayload)
        return Notification(
            title="Copilot",
            message=f"Needs permission to run: {self.payload.tool_name}",
            sound="Glass",
        )


class NotificationEvent(HookEventBase):
    """Fires asynchronously for general system notifications."""

    event_name: ClassVar[str] = "notification"
    payload_type: ClassVar[type[Payload]] = NotificationPayload

    def to_notification(self) -> Notification:
        assert isinstance(self.payload, NotificationPayload)
        return Notification(title="Copilot", message=self.payload.message, sound="Funk")


class PreToolUseEvent(HookEventBase):
    """Fires just before a tool is executed."""

    event_name: ClassVar[str] = "preToolUse"
    payload_type: ClassVar[type[Payload]] = PreToolUsePayload

    def to_notification(self) -> Notification:
        assert isinstance(self.payload, PreToolUsePayload)
        return Notification(
            title="Copilot",
            message=f"About to run: {self.payload.tool_name}",
            sound="Tink",
        )

    def should_notify(self) -> bool:
        assert isinstance(self.payload, PreToolUsePayload)
        return self.payload.tool_name in {"AskUserQuestion", "ask_user"}


class UnknownEvent(HookEventBase):
    """Fallback for any event we don't explicitly handle."""

    event_name: ClassVar[str] = "unknown"
    payload_type: ClassVar[type[Payload]] = UnknownPayload

    def __init__(self, payload: Payload, raw_name: str) -> None:
        super().__init__(payload)
        self.raw_name: str = raw_name

    def to_notification(self) -> Notification:
        return Notification(title="Copilot", message=f"Event: {self.raw_name}", sound="Funk")


class SessionEndEvent(HookEventBase):
    """Fires when a Copilot session ends, for any reason."""

    event_name: ClassVar[str] = "sessionEnd"
    payload_type: ClassVar[type[Payload]] = SessionEndPayload

    # Per-reason messages and sounds.
    _MESSAGES: ClassVar[dict[SessionEndReason, tuple[str, str]]] = {
        SessionEndReason.COMPLETE: ("Session complete", "Glass"),
        SessionEndReason.ERROR: ("Session ended with an error", "Basso"),
        SessionEndReason.ABORT: ("Session aborted", "Funk"),
        SessionEndReason.TIMEOUT: ("Session timed out", "Sosumi"),
        SessionEndReason.USER_EXIT: ("Session exited", "Pop"),
        SessionEndReason.UNKNOWN: ("Session ended", "Funk"),
    }

    def to_notification(self) -> Notification:
        assert isinstance(self.payload, SessionEndPayload)
        message, sound = self._MESSAGES[self.payload.reason]
        return Notification(title="Copilot", message=message, sound=sound)

    def should_notify(self) -> bool:
        assert isinstance(self.payload, SessionEndPayload)
        return self.payload.reason is not SessionEndReason.USER_EXIT


class StopEvent(HookEventBase):
    """Fires when the main agent finishes a turn (agentStop / Stop)."""

    event_name: ClassVar[str] = "agentStop"
    payload_type: ClassVar[type[Payload]] = StopPayload

    def to_notification(self) -> Notification:
        assert isinstance(self.payload, StopPayload)
        return Notification(
            title="Copilot",
            message="Agent finished a turn",
            sound="Glass",
        )


# Registry mapping event names to their handler classes. Add new events here.
EVENT_REGISTRY: dict[str, type[HookEventBase]] = {
    cls.event_name: cls
    for cls in (
        PermissionRequestEvent,
        NotificationEvent,
        PreToolUseEvent,
        SessionEndEvent,
        StopEvent,
    )
}
# PascalCase alias used by the VS Code-compatible hook_event_name format.
EVENT_REGISTRY["Stop"] = StopEvent


def build_event(event_name: str, raw: RawPayload) -> HookEventBase:
    """Instantiate the right event class for ``event_name``."""
    event_cls: type[HookEventBase] | None = EVENT_REGISTRY.get(event_name)
    if event_cls is None:
        event_cls = EVENT_REGISTRY.get(event_name[:1].lower() + event_name[1:])
    if event_cls is None:
        event_cls = EVENT_REGISTRY.get(event_name.lower())
    if event_cls is None:
        return UnknownEvent(UnknownPayload.from_raw(raw), raw_name=event_name)
    return event_cls.from_raw(raw)
