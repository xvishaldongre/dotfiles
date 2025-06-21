#!/usr/bin/env bash

# Function to handle brand new session creation when triggered by Ctrl-N
create_new_session() {
    read -rp "Enter new session name: " new_session
    # Check if the input is not empty
    if [[ -n "$new_session" ]]; then
        echo "Creating new session '$new_session' in your home directory (~)..."
        # Use the zellij-switch plugin to create/switch to the new session
        zellij pipe --plugin https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm -- "--session $new_session --cwd $HOME --layout default"
    else
        echo "Session name cannot be empty. Aborting."
    fi
}

# --- Main Logic ---

# 1. Prepare the list of existing Zellij sessions.
existing_sessions=$(zellij list-sessions | grep -v EXITED |
    awk '{printf("\033[34m\033[0m [S] %s\n", $1)}')

# 2. Prepare the list of zoxide paths.
#    - Use `zoxide query -l` to get ONLY the path, not the score.
zoxide_paths=$(zoxide query -l |
    awk '{printf("\033[34m\033[0m [P] %s\n", $0)}')

# 3. Combine both lists into a single variable for fzf.
combined_list=$(printf "%s\n%s" "$existing_sessions" "$zoxide_paths")

# 4. Pipe the combined list into fzf with custom key bindings.
selection=$(echo "$combined_list" |
    fzf --ansi --prompt=" Session |  Path > " \
        --bind "ctrl-n:reload(echo 'NEW_SESSION')" \
        --expect=ctrl-n)

# 5. Process the user's selection from fzf
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
        echo "Switching to existing session: $session_name" >>~/test.txt
        zellij pipe --plugin https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm -- "--session $session_name --layout default"
        ;;
    *"[P] "*)
        # It's a zoxide path. Extract the path and create/switch.
        path=$(echo "$value" | sed 's/.*\[P\] //')
        session_name=$(basename "$path")
        echo "Creating/switching to session '$session_name' at path '$path'..." >>~/test.txt
        zellij pipe --plugin https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm -- "--session $session_name --cwd $path --layout default"
        ;;
    esac
    ;;
esac
