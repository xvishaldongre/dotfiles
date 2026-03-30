#!/bin/bash

notes_session="notes"
current_session=$(tmux display-message -p '#S')

if [[ "$current_session" == "$notes_session" ]]; then
    tmux switch-client -l
else
    if tmux has-session -t "$notes_session" 2>/dev/null; then
        tmux switch-client -t "$notes_session"
    else
        tmux new-session -d -s "$notes_session"
        tmux switch-client -t "$notes_session"
    fi
fi
