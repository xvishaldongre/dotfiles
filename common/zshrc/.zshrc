# Environment Variables
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_VERIFY_ATTESTATIONS=1
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
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

# Znap Bootstrap
[[ -r ~/Repos/znap/znap.zsh ]] || git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh

# Completion system
## Cache completions for faster startup
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/completion"

# Source local aliases
for file in \
  ~/.config/aliases/aliases \
  ~/.config/aliases/kubectl_aliases \
  ~/.config/aliases/git_worktree.sh \
  ~/.config/private_aliases.sh 
do
  [[ -f "$file" ]] && source "$file"
done

# Znap Plugins
znap source zsh-users/zsh-completions        # Completion functions
znap source zsh-users/zsh-autosuggestions    # Autosuggestions
znap source zdharma-continuum/fast-syntax-highlighting
# znap source jeffreytse/zsh-vi-mode
# znap source droctothorpe/kubecolor
# znap source marlonrichert/zcolor

# Optional Oh My Zsh plugins
# znap source ohmyzsh/ohmyzsh plugins/{brew,aliases,colored-man-pages}

# FZF + Tab Completion
znap source junegunn/fzf shell/{completion,key-bindings}.zsh
znap source Aloxaf/fzf-tab

# Initialize Tools
znap eval starship 'starship init zsh --print-full-init'
znap eval zoxide 'zoxide init zsh'
znap eval atuin 'atuin init zsh --disable-up-arrow'
znap eval mise 'mise activate zsh'

# Prompt optimization
znap prompt

