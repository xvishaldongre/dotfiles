# ============================================================================
#  .zshrc — single-file zsh config
# ============================================================================
#  Symlinked to ~/.zshrc by stow (dotfiles/common/zshrc). Edit this file only.
#
#  HOW TO READ THIS FILE
#  Sections run top to bottom. Each one says WHY it exists and WHAT it costs.
#  Startup budget: ~40 ms warm. Anything added here must keep that number.
#
#  THREE ORDERING RULES — break them and things fail silently:
#    1. zstyle ':completion:*' and zstyle ':fzf-tab:*' must run BEFORE znap,
#       because znap defers compinit to the first prompt.
#    2. fast-syntax-highlighting must be the LAST plugin sourced, or it will
#       highlight the wrong region of the command line.
#   3. znap eval <tool> must run AFTER znap.zsh is sourced (it caches to
#       ~/.cache/zsh-snap/eval/*.zwc).
#
#  LAZY-LOAD POLICY
#  Source external files only when they exist AND are needed now. Defer
#  anything that is slow or network-bound to first use (see the kubectl
#  section). Never curl during startup.
#
#  PROFILING
#  Uncomment the zprof line, open a new shell, run `zprof | head -20`.
# ============================================================================

# zmodload zsh/zprof   # profiling: see header, comment back out when done

# ----------------------------------------------------------------------------
# 1. PATH + XDG
# ----------------------------------------------------------------------------
# typeset -U makes path/PATH/fpath/FPATH behave as unique arrays: prepending a
# duplicate is a no-op instead of a growing PATH. Order matters: first wins.
typeset -U path PATH fpath FPATH

# XDG defaults. Set before anything reads them (compcache uses these below).
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Homebrew (macOS). /etc/paths.d usually covers this, so skip the eval when
# brew is already visible. eval costs a subprocess (~10 ms) — pay it once.
if [[ -x /opt/homebrew/bin/brew ]] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# User bins. Checked with -d so a missing dir does not shadow a real command.
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/.krew/bin" ]]   && path=("$HOME/.krew/bin" $path)
[[ -d "$HOME/.opencode/bin" ]] && path=("$HOME/.opencode/bin" $path)

# ----------------------------------------------------------------------------
# 2. Environment variables
# ----------------------------------------------------------------------------
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_VERIFY_ATTESTATIONS=1
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
export EDITOR=nvim
export VISUAL=nvim

# ----------------------------------------------------------------------------
# 3. Shell options + ZLE
# ----------------------------------------------------------------------------
setopt interactivecomments          # allow trailing # comments in the CLI
zle_highlight=('paste:none')        # do not highlight pasted text (avoids
                                    # bracketed-paste artifacts in some terms)

# ----------------------------------------------------------------------------
# 4. History
# ----------------------------------------------------------------------------
# Atuin is the real searchable history; zsh history is only a fallback and a
# source for autosuggestions. Kept capped to avoid a large startup read.
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY     # write each command immediately (crash-safe)
setopt HIST_REDUCE_BLANKS     # collapse blank lines in recorded commands
setopt HIST_IGNORE_SPACE      # leading space = not recorded (for secrets)
setopt HIST_IGNORE_ALL_DUPS   # keep only the newest copy of a command
setopt HIST_SAVE_NO_DUPS      # do not write dupes to HISTFILE
setopt HIST_VERIFY            # expand !! into the buffer, do not run blindly
setopt SHARE_HISTORY          # sync across open shells

# ----------------------------------------------------------------------------
# 5. Completion cache + zstyles  (MUST run before znap — see rule 1)
# ----------------------------------------------------------------------------
# znap defers compinit to the first precmd and uses $XDG_CACHE_HOME/zsh/compdump.
# cache-path must be a *directory*. mkdir -p costs ~40 ms on macOS (fork+exec),
# so test with a builtin first.
[[ -d "$XDG_CACHE_HOME/zsh/compcache" ]] || mkdir -p "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# ----------------------------------------------------------------------------
# 6. Znap (plugin manager)
# ----------------------------------------------------------------------------
# Shallow clone on first run, then reused. znap handles compinit/fpath caching.
[[ -r ~/Repos/znap/znap.zsh ]] || git clone --depth 1 --quiet https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh

# ----------------------------------------------------------------------------
# 7. Aliases
# ----------------------------------------------------------------------------
# Aliases cannot be lazy: zsh expands them at parse time, so they must exist
# before the first prompt. These three files are small; -r avoids a failed
# source on machines that lack them.
for _file in \
  ~/.config/aliases/aliases \
  ~/.config/aliases/git_worktree.sh \
  ~/.config/private_aliases.sh
do
  [[ -r "$_file" ]] && source "$_file"
done
unset _file

# ----------------------------------------------------------------------------
# 8. Kubernetes helpers (LAZY — network + ~2000 aliases)
# ----------------------------------------------------------------------------
# kubectl_aliases curls and generates ~2000 aliases. Loading it eagerly costs
# seconds, so each kube command is a stub that loads once on first use, then
# re-dispatches through eval so the freshly defined aliases expand correctly.
# ${(@q)@} keeps every argument a separate, safely quoted word; a plain "$@"
# inside the eval string would join them into one argument.
_kube_lazy_load() {
  [[ -n "$_KUBE_LAZY_LOADED" ]] && return 0
  _KUBE_LAZY_LOADED=1
  unfunction k kubectl kc kn kei ksd ksdf kdr kdy ky kgrep ff xpc xp xd xs xsv xi xc 2>/dev/null
  [[ -r ~/.config/aliases/kubectl_aliases ]] && source ~/.config/aliases/kubectl_aliases
}
for _k in k kubectl kc kn kei ksd ksdf kdr kdy ky kgrep ff xpc xp xd xs xsv xi xc; do
  eval "${_k}() { _kube_lazy_load; eval \"${_k} \${(@q)@}\"; }"
done
unset _k

# ----------------------------------------------------------------------------
# 9. Plugins  (order matters — see rules 1 and 2)
# ----------------------------------------------------------------------------
# zsh-completions is fpath-only: no code to source. A direct fpath prepend is
# free, while `znap source` would pay clone/status checks (~40 ms).
if [[ -d ~/Repos/zsh-users/zsh-completions/src ]]; then
  fpath=(~/Repos/zsh-users/zsh-completions/src $fpath)
else
  znap source zsh-users/zsh-completions
fi

znap source Aloxaf/fzf-tab

# Autosuggestions: async and capped, so typing stays responsive on long lines.
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
znap source zsh-users/zsh-autosuggestions

# MUST be last: highlights the command line as you type.
znap source zdharma-continuum/fast-syntax-highlighting

# ----------------------------------------------------------------------------
# 10. fzf
# ----------------------------------------------------------------------------
# Prefer the Homebrew install (versioned, no clone). Fall back to znap only if
# the brew files are missing.
if [[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
else
  znap source junegunn/fzf shell/{completion,key-bindings}.zsh
fi

# fd makes fzf instant on large trees; only set these when fd exists.
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ----------------------------------------------------------------------------
# 11. Tool init  (AFTER znap — see rule 3)
# ----------------------------------------------------------------------------
# znap eval writes the output to ~/.cache/zsh-snap/eval/*.zwc and replays the
# compiled file on later shells, so the cost is paid once per tool version.
znap eval starship 'starship init zsh --print-full-init'
znap eval zoxide   'zoxide init zsh'
znap eval atuin    'atuin init zsh --disable-up-arrow'

# mise: shims only. `mise activate zsh` installs a hook-env subprocess on every
# prompt and every cd (~200 ms per shell). Shims resolve the version per
# directory with no hook, at the cost of one PATH entry.
# If you need `mise shell` or per-directory env vars (JAVA_HOME, ...), switch to:
#   znap eval mise 'mise activate zsh'
[[ -d "$HOME/.local/share/mise/shims" ]] && path=("$HOME/.local/share/mise/shims" $path)

# No `znap prompt`: it costs ~27 ms and does nothing when starship is the
# prompt. Do not call compinit here either; znap defers it on purpose.

# ----------------------------------------------------------------------------
# 12. Integrations  (each guarded, nothing runs when absent)
# ----------------------------------------------------------------------------
# OpenKnowledge CLI. Block is managed by `ok`; delete it to opt out.
[ -f "$HOME/.ok/env.sh" ] && . "$HOME/.ok/env.sh"

