# Profiling (uncomment to profile startup: then run `zprof`)
# zmodload zsh/zprof

# --- PATH (deduplicated, order matters) ---
typeset -U path PATH fpath FPATH
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Homebrew (macOS). Only eval once; brew is already on PATH via /etc/paths.d in most cases.
if [[ -x /opt/homebrew/bin/brew ]] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
path=("$HOME/.local/bin" "$HOME/.krew/bin" "$HOME/.antigravity/antigravity/bin" $path)

# --- Env ---
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_VERIFY_ATTESTATIONS=1
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
export EDITOR=nvim
export VISUAL=nvim
# opencode (portable; was hardcoded to /home/... linux path)
[[ -d "$HOME/.opencode/bin" ]] && path=("$HOME/.opencode/bin" $path)
export PATH

# --- Options ---
setopt interactivecomments

# History: Atuin is the source of truth, keep zsh history small for speed.
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY HIST_REDUCE_BLANKS HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_VERIFY SHARE_HISTORY

# ZLE
zle_highlight=('paste:none')

# --- Completion caching (must be set BEFORE znap loads) ---
# znap defers real compinit to first precmd and uses $XDG_CACHE_HOME/zsh/compdump.
# cache-path must be a *directory*. Guarded mkdir: bare `mkdir -p` costs ~40ms
# on macOS (fork+exec), the test below is a builtin and ~free when dir exists.
[[ -d "$XDG_CACHE_HOME/zsh/compcache" ]] || mkdir -p "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
# fzf-tab tuning
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# --- Znap bootstrap (quiet, shallow) ---
[[ -r ~/Repos/znap/znap.zsh ]] || git clone --depth 1 --quiet https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh

# --- Fast local aliases (tiny, safe to load immediately) ---
for file in \
  ~/.config/aliases/aliases \
  ~/.config/aliases/git_worktree.sh \
  ~/.config/private_aliases.sh
do
  [[ -f "$file" ]] && source "$file"
done

# --- Slow kube helpers: LAZY-LOAD (was curl+source on every shell) ---
# ~/.config/aliases/kubectl_aliases does network curls and sources ~2000
# generated aliases. Only load on first k8s command. Re-dispatched via
# eval so aliases defined by that file expand correctly.
_kube_lazy_load() {
  # Idempotent: only source once, keep this function for other wrappers.
  [[ -n "$_KUBE_LAZY_LOADED" ]] && return 0
  _KUBE_LAZY_LOADED=1
  unfunction k kubectl kc kn kei ksd ksdf kdr kdy ky kgrep ff xpc xp xd xs xsv xi xc 2>/dev/null
  [[ -f ~/.config/aliases/kubectl_aliases ]] && source ~/.config/aliases/kubectl_aliases
}
for _k in k kubectl kc kn kei ksd ksdf kdr kdy ky kgrep ff xpc xp xd xs xsv xi xc; do
  eval "${_k}() { _kube_lazy_load; eval \"${_k} \\\"\$@\\\"\"; }"
done
unset _k

# --- Plugins (order matters) ---
# zsh-completions is fpath-only (no code to source). Loading it via
# `znap source` costs ~40ms of clone/status checks; a direct fpath prepend
# is free and znap's deferred compinit picks it up on first prompt.
if [[ -d ~/Repos/zsh-users/zsh-completions/src ]]; then
  fpath=(~/Repos/zsh-users/zsh-completions/src $fpath)
else
  znap source zsh-users/zsh-completions
fi
znap source Aloxaf/fzf-tab
# Autosuggestion tuning for speed (async, small buffer)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
znap source zsh-users/zsh-autosuggestions
# Must be last: highlights the command line
znap source zdharma-continuum/fast-syntax-highlighting

# --- FZF: prefer Homebrew (no git clone, already versioned) ---
if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
else
  znap source junegunn/fzf shell/{completion,key-bindings}.zsh
fi
# Use fd (already installed) for speed; fall back gracefully
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# --- Tools (znap eval = cached to ~/.cache/zsh-snap/eval/*.zwc) ---
znap eval starship 'starship init zsh --print-full-init'
znap eval zoxide 'zoxide init zsh'
znap eval atuin 'atuin init zsh --disable-up-arrow'
# mise: shims-only (was `mise activate zsh` = ~200ms hook-env subprocess on
# every new shell + a hook on every cd/prompt). Shims resolve versions per
# directory with no hook. Full activate output was 5.5KB + hook; shims is 1 PATH entry.
# If you need `mise shell` / per-dir env vars (JAVA_HOME etc), switch back to:
#   znap eval mise 'mise activate zsh'
path=("$HOME/.local/share/mise/shims" $path)

# NOTE: no `znap prompt` — it cost ~27ms and does nothing with starship.
# znap's compinit is deferred to first precmd by design; don't call compinit here.
