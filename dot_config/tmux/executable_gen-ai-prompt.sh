#!/usr/bin/env zsh

TARGET_PANE="$1"
CMD_PATH="$2"

if [ -z "${TMUX:-}" ]; then
    echo "Error: This script must be run inside a tmux session." >&2
    exit 1
fi

TMPFILE="$(mktemp -t prompt)"
trap 'rm -f "$TMPFILE"' EXIT

tmux popup -E -w 80% -h 70% -T "Prompt" "cd $CMD_PATH && $SHELL -i -c 'nvim +\"set ft=markdown\" \"$TMPFILE\"'"

if [ -s "$TMPFILE" ]; then
    CONTENT="$(cat "$TMPFILE")"

    tmux set-buffer -b claude_prompt -- "$CONTENT"
    tmux paste-buffer -b claude_prompt -t "$TARGET_PANE"
else
    tmux display-message "popup is empty, skip pasting"
fi

exit 0
