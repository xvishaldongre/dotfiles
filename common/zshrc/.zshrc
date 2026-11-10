# ============================================================================
#  .zshrc — minimal, portable zsh config
# ============================================================================
#  Symlinked to ~/.zshrc by stow (dotfiles/common/zshrc). Edit this file only.
#
#  DESIGN RULE
#  Every optional thing is guarded. A machine without brew, git, znap,
#  starship, zoxide, atuin, fzf or kubecolor still gets a working shell.
#  Missing tools are reported once per shell (see _need) so nothing fails
#  silently. Set ZSH_QUIET=1 to suppress the summary.
#
#  ORDERING RULES — break these and things fail silently:
#    1. zstyle ':completion:*' must run BEFORE znap (it defers compinit).
#    2. fast-syntax-highlighting must be last, or it highlights wrongly.
#
#  Aliases live in ~/.aliases (sourced at the bottom).
# ============================================================================

# ----------------------------------------------------------------------------
# 1. PATH + XDG
# ----------------------------------------------------------------------------
# typeset -U makes path a unique array: prepending a duplicate is a no-op.
# Order matters: first wins.
typeset -U path PATH

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Homebrew (macOS). Skip when brew is absent or already on PATH.
if [[ -x /opt/homebrew/bin/brew ]] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# User bins. -d test so a missing dir cannot shadow a real command.
[[ -d $HOME/.local/bin ]]              && path=($HOME/.local/bin $path)
[[ -d $HOME/.krew/bin ]]               && path=($HOME/.krew/bin $path)
[[ -d $HOME/.local/share/mise/shims ]] && path=($HOME/.local/share/mise/shims $path)

export EDITOR=nvim
export VISUAL=nvim

# Starship looks in ~/.config/starship.toml by default, but the dotfiles put it
# one level deeper (~/.config/starship/starship.toml). Without this line
# starship silently falls back to its built-in prompt.
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# ----------------------------------------------------------------------------
# 1b. Missing-tool warnings
# ----------------------------------------------------------------------------
# Every optional tool registers its absence here. One summary line is printed
# at the end of startup, so a bare machine says what to install instead of
# silently dropping features. Set ZSH_QUIET=1 to suppress.
typeset -ga _zsh_missing
_need() {
  # $1 = command name, $2 = optional hint (package name / install note)
  (( $+commands[$1] )) && return 0
  _zsh_missing+=("$1${2:+ ($2)}")
  return 1
}

_zsh_warn_summary() {
  (( ${#_zsh_missing} )) || return 0
  [[ -n ${ZSH_QUIET:-} ]] && return 0
  print -u2 "zsh: missing optional tools: ${(j:, :)_zsh_missing}"
  print -u2 "zsh: set ZSH_QUIET=1 to hide this, or install them"
  return 0
}

# ----------------------------------------------------------------------------
# 2. Shell options
# ----------------------------------------------------------------------------
setopt interactivecomments      # allow trailing # comments on the CLI
zle_highlight=('paste:none')    # do not highlight pasted text

# ----------------------------------------------------------------------------
# 3. History
# ----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY       # write each command immediately (crash-safe)
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE        # leading space = not recorded
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

# ----------------------------------------------------------------------------
# 4. Completion zstyles  (MUST run before znap — see rule 1)
# ----------------------------------------------------------------------------
# cache-path must be a directory. Test with a builtin before forking mkdir.
[[ -d $XDG_CACHE_HOME/zsh/compcache ]] || mkdir -p $XDG_CACHE_HOME/zsh/compcache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/compcache
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# ----------------------------------------------------------------------------
# 5. Plugins (znap) — optional, never fatal
# ----------------------------------------------------------------------------
# znap clones on first use. Guard on git and silence stderr so an offline
# machine does not print git noise at every startup.
_zsh_plugins_ok=0
if (( $+commands[git] )); then
  [[ -r ~/Repos/znap/znap.zsh ]] || \
    git clone --depth 1 --quiet \
        https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap 2>/dev/null
  if [[ -r ~/Repos/znap/znap.zsh ]]; then
    source ~/Repos/znap/znap.zsh
    _zsh_plugins_ok=1
  else
    _zsh_missing+=("znap (clone failed, no network?)")
  fi
else
  _zsh_missing+=("git (needed for znap plugins)")
fi

# _plugin: no-op when znap is missing; silent when a clone fails.
_plugin() {
  (( _zsh_plugins_ok )) || return 0
  znap source "$@" 2>/dev/null
}

# zsh-completions is fpath-only: a free direct prepend beats znap source.
if [[ -d ~/Repos/zsh-users/zsh-completions/src ]]; then
  fpath=(~/Repos/zsh-users/zsh-completions/src $fpath)
else
  _plugin zsh-users/zsh-completions
fi

(( $+commands[fzf] )) && _plugin Aloxaf/fzf-tab || _need fzf

export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
_plugin zsh-users/zsh-autosuggestions

# MUST be last of the plugin block (rule 2).
_plugin zdharma-continuum/fast-syntax-highlighting
# If znap never loaded, no compinit ran. Do it ourselves so completion works.
if (( ! _zsh_plugins_ok )); then
  autoload -Uz compinit && compinit -C -d $XDG_CACHE_HOME/zsh/compdump 2>/dev/null
fi

# ----------------------------------------------------------------------------
# 6. Tool init — each no-ops silently when the tool is absent
# ----------------------------------------------------------------------------
# Do NOT use `znap eval` here: it writes an empty cache file when a command is
# missing, returns 0, and every later shell replays that emptiness silently.
# _tool: skip if absent, write temp-then-rename, regenerate when binary is newer.
_tool() {
  (( $+commands[$1] )) || return 0
  local file=$XDG_CACHE_HOME/zsh/tool/$1.zsh
  if [[ ! -r $file || $file -ot $commands[$1] ]]; then
    mkdir -p ${file:h}
    if eval "$2" >| $file.tmp 2>/dev/null; then
      mv -f $file.tmp $file
    else
      rm -f $file.tmp
      _zsh_missing+=("$1 (init failed)")
      return 0
    fi
  fi
  source $file 2>/dev/null
}

_need starship || true
_need zoxide   || true
_need atuin    || true
_need kubecolor || true

_tool starship 'starship init zsh --print-full-init'
_tool zoxide   'zoxide init zsh'
_tool atuin    'atuin init zsh --disable-up-arrow'

# ----------------------------------------------------------------------------
# 7. fzf
# ----------------------------------------------------------------------------
if [[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
elif (( $+commands[fzf] )); then
  # Non-brew install: use fzf's own shell integration if it shipped one.
  for _f in /usr/share/fzf/{completion,key-bindings}.zsh \
            /usr/share/doc/fzf/examples/{completion,key-bindings}.zsh; do
    [[ -r $_f ]] && source $_f
  done
  unset _f
fi
# fd makes fzf instant on large trees; only set these when fd exists.
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ----------------------------------------------------------------------------
# 8. Machine-local overrides
# ----------------------------------------------------------------------------
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# ----------------------------------------------------------------------------
# 9. Aliases
# ----------------------------------------------------------------------------
[[ -r ~/.aliases ]] && source ~/.aliases

# ----------------------------------------------------------------------------
# 10. Startup summary — name what is missing, then clear the list
# ----------------------------------------------------------------------------
_zsh_warn_summary
unset _zsh_missing

