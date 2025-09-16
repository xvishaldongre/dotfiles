#!/usr/bin/env bash

# Function to handle brand new session creation when triggered by Ctrl-N
create_new_session() {
    read -rp "Enter new session name: " new_session
    # Check if the input is not empty
    if [[ -n "$new_session" ]]; then
        echo "Creating new session '$new_session' in your home directory (~)..."
        zellij pipe --plugin https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm -- "--session $new_session --cwd $HOME --layout default"
    else
        echo "Session name cannot be empty. Aborting."
    fi
}

# --- Main Logic ---

# Run data collection in parallel and combine the streams for faster startup.
combined_list=$(
    cat <(
        zellij list-sessions | grep -v EXITED |
            awk '{printf("\033[34m\033[0m [S] %s\n", $1)}'
    ) <(
        # Only run zoxide if the command exists
        if command -v zoxide &>/dev/null; then
            zoxide query -l |
                awk -v home="$HOME" '{sub("^" home, "~"); printf("\033[33m\033[0m [P] %s\n", $0)}'
        fi
    )
)

# Pipe the combined list into fzf with custom key bindings and a header.
# $0 is a special variable that refers to the script's own filename, making it easy to reload.
selection=$(
    echo "$combined_list" |
        fzf --ansi --prompt=" Session |  Path > " \
            --expect=ctrl-n

)

# Process the user's selection from fzf
key=$(head -1 <<<"$selection")
value=$(tail -n +2 <<<"$selection")

if [[ -z "$value" ]]; then
    echo "No selection. Exiting."
    exit 0
fi

case "$key" in
ctrl-n)
    # User pressed Ctrl-N for a completely new session
    create_new_session
    ;;
*)
    # User selected an item from the list.
    case "$value" in
    *"[S] "*)
        # It's an existing session. Extract the name and switch.
        session_name=$(echo "$value" | sed 's/.*\[S\] //')
        zellij pipe --plugin https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm -- "--session $session_name --layout default"
        ;;
    *"[P] "*)
        # It's a zoxide path. Extract the path and create/switch.
        path=$(echo "$value" | sed 's/.*\[P\] //')
        # Restore ~ to full home directory path
        if [[ "$path" == "~"* ]]; then
            path="${HOME}${path:1}"
        fi
        session_name=$(basename "$path")
        zellij pipe --plugin https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm -- "--session $session_name --cwd \"$path\" --layout default"
        ;;
    esac
    ;;
esac
