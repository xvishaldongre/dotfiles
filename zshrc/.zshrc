# Path
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Users/vishal.dongre/.orbstack/bin"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# History 
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=1000000
HISTIGNORE="*/Applications/*"
setopt HIST_IGNORE_SPACE     # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS      # Don't save duplicate lines
setopt HIST_IGNORE_ALL_DUPS  # Remove all previous duplicates when re-entering a command
setopt HIST_FIND_NO_DUPS     # Don't show duplicates when searching history
setopt SHARE_HISTORY         # Share history between sessions

# Navigation
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit
complete -C '/opt/homebrew/bin/aws_completer' aws



# Startship
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# Atuin
eval "$(atuin init zsh --disable-up-arrow)" 

# Homebrew
export HOMEBREW_NO_AUTO_UPDATE=1 # Prevent homebrew update

# ZSH Plugins
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ ! -d ~/.config/fzf-tab ]] && git clone https://github.com/Aloxaf/fzf-tab ~/.config/fzf-tab && source ~/.config/fzf-tab/fzf-tab.plugin.zsh || source ~/.config/fzf-tab/fzf-tab.plugin.zsh

## Aliases
source ~/.config/aliases/.kubectl_aliases
source ~/.config/aliases/.aliases
source <(kubectl completion zsh)

# Nix
export NIX_SSL_CERT_FILE='/opt/homebrew/etc/ca-certificates/cert.pem'