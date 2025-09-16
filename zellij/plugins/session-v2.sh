#!/usr/bin/env bash

# --- Config ---
PLUGIN_URL="https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm"
PROMPT=" Session |  Path > "

# --- Functions ---

create_new_session() {
    read -rp "Enter new session name: " new_session
    if [[ -n "$new_session" ]]; then
        echo "Creating new session '$new_session' in your home directory (~)..."
        zellij pipe --plugin "$PLUGIN_URL" -- "--session $new_session --cwd $HOME --layout default"
    else
        echo "Session name cannot be empty. Aborting."
    fi
}

build_combined_list() {
    {
        zellij list-sessions 2>/dev/null | grep -v EXITED | awk '{print "\033[34m\033[0m [S] " $1}'
        zoxide query -l | awk -v home="$HOME" '{
            sub("^" home, "~")
            print "\033[33m\033[0m [P] " $0
        }'
    }
}
parse_selection() {
    local line="$1"
    case "$line" in
    *"[S] "*)
        echo session "$(echo "$line" | sed 's/.*\[S\] //')"
        ;;
    *"[P] "*)
        local path="$(echo "$line" | sed 's/.*\[P\] //')"
        [[ "$path" == "~"* ]] && path="${HOME}${path:1}"
        echo path "$path"
        ;;
    esac
}

switch_session_or_path() {
    local type="$1"
    local value="$2"
    local session_name

    case "$type" in
    session)
        session_name="$value"
        ;;
    path)
        session_name=$(basename "$value")
        ;;
    esac

    # Trim session name if longer than 36 characters
    if [ "${#session_name}" -gt 36 ]; then
        session_name="${session_name:0:34}.."
    fi

    case "$type" in
    session)
        zellij pipe --plugin "$PLUGIN_URL" -- "--session $session_name --layout default"
        ;;
    path)
        zellij pipe --plugin "$PLUGIN_URL" -- "--session $session_name --cwd $value --layout default"
        ;;
    esac
}

# --- Main ---

selection=$(build_combined_list | fzf --ansi --prompt="$PROMPT" --expect=ctrl-n)

key=$(head -n1 <<<"$selection")
value=$(tail -n +2 <<<"$selection")

[[ -z "$value" ]] && {
    echo "No selection. Exiting."
    exit 0
}

case "$key" in
ctrl-n) create_new_session ;;
*)
    read -r type value <<<"$(parse_selection "$value")"
    switch_session_or_path "$type" "$value"
    ;;
esac
