#!/usr/bin/env bash

# --- Config ---
PLUGIN_URL="https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm"
PROMPT=" Session |  Path > "
CACHE_FILE="$HOME/.cache/zellij-session-refresh.log"

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

build_zoxide_cache() {
    zoxide query -l | parallel -k --no-notice --jobs $(nproc) '
        path="{}"
        display_path="$path"
        [[ "$path" == "$HOME"* ]] && display_path="~${path#$HOME}"

        if [ -d "$path/.git" ] || [ -f "$path/.git" ] || git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$path" rev-parse --short HEAD 2>/dev/null)
            printf "\033[33m\033[0m [P] %s \033[1;36m %s\033[0m\n" "$display_path" "$branch"
        else
            printf "\033[33m\033[0m [P] %s\n" "$display_path"
        fi
    '
}

build_combined_list() {
    {
        # Live Zellij sessions
        zellij list-sessions 2>/dev/null | grep -v EXITED | awk '{print "\033[34m\033[0m [S] " $1}'

        # Cached zoxide + git info
        if [[ -f "$CACHE_FILE" ]]; then
            cat "$CACHE_FILE"
        fi
    }
}

parse_selection() {
    local line="$1"
    case "$line" in
    *"[S] "*)
        echo session "$(echo "$line" | sed 's/.*\[S\] //')"
        ;;
    *"[P] "*)
        local path
        path="$(echo "$line" | sed 's/.*\[P\] //')"
        [[ "$path" == "~"* ]] && path="${HOME}${path:1}"
        echo path "$path"
        ;;
    esac
}

switch_session_or_path() {
    local type="$1"
    local value="$2"
    case "$type" in
    session)
        zellij pipe --plugin "$PLUGIN_URL" -- "--session $value --layout default"
        ;;
    path)
        local session_name
        session_name=$(basename "$value")
        zellij pipe --plugin "$PLUGIN_URL" -- "--session $session_name --cwd $value --layout default"
        ;;
    esac
}

# --- Ensure Cache Exists ---
if [[ ! -f "$CACHE_FILE" ]]; then
    echo "Cache not found. Building cache..."
    mkdir -p "$(dirname "$CACHE_FILE")"
    build_zoxide_cache >"$CACHE_FILE" 2>&1
fi

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

# --- Background Cache Update ---
nohup bash -c "
  sleep 2
  $(declare -f build_zoxide_cache)
  build_zoxide_cache > \"$CACHE_FILE\" 2>&1
" >/dev/null 2>&1 &
