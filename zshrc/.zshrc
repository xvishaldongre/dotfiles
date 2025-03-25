# Download Znap if it's not installed
[[ -r ~/Repos/znap/znap.zsh ]] || git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh  # Start Znap

# Environment Variables
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_VERIFY_ATTESTATIONS=1
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim

# Bash style comments
setopt interactivecomments

# History options
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate lines
setopt SHARE_HISTORY      # Share history between sessions

zle_highlight=('paste:none')

# Source local alias files
source ~/.config/aliases/aliases
source ~/.config/aliases/kubectl_aliases
source ~/.config/private_aliases.sh

# Load plugins (ensures they are cached and updated via Znap)
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-autosuggestions
znap source zdharma-continuum/fast-syntax-highlighting
# znap source droctothorpe/kubecolor

# Load multiple Oh My Zsh plugins in one command
znap source ohmyzsh/ohmyzsh plugins/{brew,aliases,colored-man-pages}
znap source junegunn/fzf shell/{completion,key-bindings}.zsh

znap source Aloxaf/fzf-tab
# znap source marlonrichert/zcolor

# Initialize tools efficiently
znap eval starship 'starship init zsh --print-full-init'
znap eval zoxide 'zoxide init zsh'
znap eval atuin 'atuin init zsh --disable-up-arrow'

# Optimize prompt loading
znap prompt
