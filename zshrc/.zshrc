# Download Znap if it's not installed
[[ -r ~/Repos/znap/znap.zsh ]] || git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh  # Start Znap

# Environment Variables
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export EDITOR=nvim
export VISUAL=nvim
# Bash style comments
setopt interactivecomments

# History options
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_IGNORE_SPACE HIST_IGNORE_DUPS SHARE_HISTORY

# ZLE
zle_highlight=('paste:none')

# Completion styles
# zstyle ':completion::*:*:*:*:*' insecure 'yes'
# zstyle ':completion:*' use-cache on
# zstyle ':completion:*' cache-path "$HOME/.cache/zsh/completion"
# zstyle ':completion:*' format ''

# Source local alias files
source ~/.config/aliases/aliases
# source ~/.config/aliases/kubectl_aliases
# source ~/.config/private_aliases.sh
source ~/.config/aliases/git_worktree.sh
# source ~/.config/zshrc/bindkey.sh

# Load plugins (via Znap, cached & updated)
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-autosuggestions
znap source zdharma-continuum/fast-syntax-highlighting
# znap source jeffreytse/zsh-vi-mode
# znap source droctothorpe/kubecolor
# znap source marlonrichert/zcolor

# Oh My Zsh plugins (optional)
# znap source ohmyzsh/ohmyzsh plugins/{brew,aliases,colored-man-pages}

# FZF
znap source junegunn/fzf shell/{completion,key-bindings}.zsh
znap source Aloxaf/fzf-tab

# Initialize tools efficiently
znap eval starship 'starship init zsh --print-full-init'
znap eval zoxide 'zoxide init zsh'
znap eval atuin 'atuin init zsh --disable-up-arrow'
znap eval mise 'mise activate zsh'
# Optimize prompt loading
znap prompt
