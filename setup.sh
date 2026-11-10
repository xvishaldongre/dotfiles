#!/usr/bin/env bash
# ============================================================================
#  setup.sh — link the dotfiles onto this machine
# ============================================================================
#  Safe to re-run. Fails loudly instead of printing "Done!" after an abort.
#
#  Uses GNU stow when available. When stow is missing it falls back to plain
#  symlinks, which produce the same result for this repo's layout:
#
#    common/*  -> ~/.config/<name>   (nvim, tmux, mise, starship, ...)
#    zshrc     -> ~/.zshrc, ~/.aliases
#    macos/*   -> ~/.config/<name>   (Darwin only)
#    linux/*   -> ~/.config/<name>   (Linux only)
#
#  Options:
#    ADOPT=1       let stow take existing ~/.config files into the repo.
#                  Never applied to ~/.zshrc or ~/.aliases.
#    FORCE_LINK=1  use the symlink fallback even when stow is installed.
# ============================================================================
set -euo pipefail

OS_TYPE=$(uname)
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BACKUP_DIR=~/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)

echo "Setting up dotfiles for $OS_TYPE from $DOTFILES_DIR"

# ---------------------------------------------------------------------------
# Which linker do we use?
# ---------------------------------------------------------------------------
if [[ -z ${FORCE_LINK:-} ]] && command -v stow >/dev/null 2>&1; then
  LINKER=stow
else
  LINKER=link
  [[ -z ${FORCE_LINK:-} ]] && \
    echo "note: stow not found; falling back to plain symlinks"
fi
echo "linker: $LINKER"

mkdir -p ~/.config

# ---------------------------------------------------------------------------
# Symlink fallback
# ---------------------------------------------------------------------------
# Stow merges a package tree into the target, one symlink per entry:
#
#   common/nvim        -> ~/.config/nvim/init.lua, ~/.config/nvim/lua, ...
#   common/zshrc/.zshrc -> ~/.zshrc
#
# merge_link recreates that: walk the source entries, symlink each into the
# matching destination path. Real directories are descended into so unrelated
# files in ~/.config survive. Real files in the way move to $BACKUP_DIR.
# Existing correct links are left alone, so re-running is idempotent.
#
# $1 = source dir, $2 = destination dir
merge_link() {
  local src=$1 dest=$2 entry name
  [[ -d $src ]] || return 0
  mkdir -p "$dest"
  for entry in "$src"/* "$src"/.[!.]*; do
    [[ -e $entry ]] || continue          # unmatched glob
    name=$(basename "$entry")

    if [[ -L $dest/$name ]]; then
      [[ $(readlink "$dest/$name") == "$entry" ]] && continue
      rm -f "$dest/$name"
    elif [[ -d $dest/$name ]]; then
      # Real directory in the way: descend, as stow does.
      merge_link "$entry" "$dest/$name"
      continue
    elif [[ -e $dest/$name ]]; then
      mkdir -p "$BACKUP_DIR"
      echo "  backing up $dest/$name -> $BACKUP_DIR/"
      mv "$dest/$name" "$BACKUP_DIR"/
    fi

    ln -s "$entry" "$dest/$name"
  done
}

# ---------------------------------------------------------------------------
# 1. Shell files (~/.zshrc, ~/.aliases)
# ---------------------------------------------------------------------------
# These live in $HOME, not ~/.config, so they are handled separately.
#
# Deliberately no --adopt here: --adopt would overwrite the repo's .zshrc with
# whatever ~/.zshrc happened to exist on the machine.
cd "$DOTFILES_DIR/common"
if [[ -e ~/.zshrc && ! -L ~/.zshrc ]] || [[ -e ~/.aliases && ! -L ~/.aliases ]]; then
  echo "existing ~/.zshrc or ~/.aliases found; moving them to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  [[ -e ~/.zshrc && ! -L ~/.zshrc ]]     && mv ~/.zshrc "$BACKUP_DIR"/
  [[ -e ~/.aliases && ! -L ~/.aliases ]] && mv ~/.aliases "$BACKUP_DIR"/
fi

if [[ $LINKER == stow ]]; then
  stow -t ~ zshrc
else
  merge_link "$DOTFILES_DIR/common/zshrc" ~
fi

# ---------------------------------------------------------------------------
# 2. Config packages (~/.config/*)
# ---------------------------------------------------------------------------
# With stow: `stow .` over the whole directory on purpose. Listing packages
# explicitly (stow atuin mise nvim ...) makes stow compare them against each
# other and report a false "stowed to a different package" conflict whenever
# two packages share a filename (atuin/config.toml vs mise/config.toml).
#
# .stow-local-ignore keeps zshrc out of ~/.config; the fallback skips it too.
#
# --adopt is opt-in (ADOPT=1): it takes an existing ~/.config file into the
# repo, overwriting the tracked file. Only use it when you mean to.
cd "$DOTFILES_DIR/common"
if [[ $LINKER == stow ]]; then
  stow . -t ~/.config ${ADOPT:+--adopt}
else
  for pkg in "$DOTFILES_DIR"/common/*/; do
    pkg=${pkg%/}
    name=$(basename "$pkg")
    [[ $name == zshrc ]] && continue
    echo "  linking $name"
    # A package dir maps to ~/.config/<name>/, contents linked inside it.
    merge_link "$pkg" ~/.config/"$name"
  done
fi

# ---------------------------------------------------------------------------
# 3. zsh plugins
# ---------------------------------------------------------------------------
# .zshrc sources these directly; it no longer uses a plugin manager, so
# nothing clones them at startup. Clone any that are missing, once.
# Set SKIP_PLUGINS=1 to skip (offline machine).
PLUGIN_DIR=${ZSH_PLUGIN_DIR:-$HOME/Repos}
PLUGINS=(
  zsh-users/zsh-completions
  zsh-users/zsh-autosuggestions
  Aloxaf/fzf-tab
  zdharma-continuum/fast-syntax-highlighting
)

if [[ -n ${SKIP_PLUGINS:-} ]]; then
  echo "skipping zsh plugins (SKIP_PLUGINS=1)"
elif ! command -v git >/dev/null 2>&1; then
  echo "note: git not found; skipping zsh plugins"
else
  for repo in "${PLUGINS[@]}"; do
    dest=$PLUGIN_DIR/$repo
    if [[ -d $dest ]]; then
      continue
    fi
    echo "  cloning $repo"
    if ! git clone --depth 1 --quiet "https://github.com/$repo.git" "$dest" 2>/dev/null; then
      echo "  warning: could not clone $repo; .zshrc will report it" >&2
    fi
  done
fi

# ---------------------------------------------------------------------------
# 4. OS-specific packages
# ---------------------------------------------------------------------------
case "$OS_TYPE" in
  Darwin) os_dir=macos ;;
  Linux)  os_dir=linux ;;
  *)      os_dir= ;;
esac

if [[ -n $os_dir && -d $DOTFILES_DIR/$os_dir ]]; then
  echo "Applying $os_dir configs..."
  cd "$DOTFILES_DIR/$os_dir"
  if [[ $LINKER == stow ]]; then
    stow . -t ~/.config ${ADOPT:+--adopt}
  else
    for pkg in "$DOTFILES_DIR"/"$os_dir"/*/; do
      pkg=${pkg%/}
      name=$(basename "$pkg")
      echo "  linking $name"
      merge_link "$pkg" ~/.config/"$name"
    done
  fi
fi

if [[ -d $BACKUP_DIR ]]; then
  echo "Backups saved to $BACKUP_DIR"
fi

echo "Done."
