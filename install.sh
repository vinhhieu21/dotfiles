#!/bin/sh
# Symlink configs into place. Idempotent; existing non-symlink targets are moved to <file>.bak.
set -eu
DOT="$(cd "$(dirname "$0")" && pwd)"

link() { # link <repo-relative-src> <absolute-dst>
  src="$DOT/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  [ -e "$dst" ] && [ ! -L "$dst" ] && mv "$dst" "$dst.bak"
  ln -sfn "$src" "$dst"
  echo "linked $dst"
}

copy_if_missing() { # copy_if_missing <repo-relative-src> <absolute-dst>
  # For files the tool rewrites at runtime (codex config): seed once, never overwrite.
  src="$DOT/$1" dst="$2"
  [ -e "$dst" ] && return 0
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "copied $dst"
}

# shells
link fish/config.fish         "$HOME/.config/fish/config.fish"
link fish/fish_plugins        "$HOME/.config/fish/fish_plugins"
for f in "$DOT"/fish/conf.d/*.fish "$DOT"/fish/functions/*.fish "$DOT"/fish/completions/*.fish; do
  [ -f "$f" ] || continue
  link "${f#"$DOT"/}" "$HOME/.config/${f#"$DOT"/}"
done
link zsh/zprofile             "$HOME/.zprofile"
link zsh/zshrc                "$HOME/.zshrc"
link starship/starship.toml   "$HOME/.config/starship.toml"

# terminal / wm / input
link ghostty/config           "$HOME/.config/ghostty/config"
link tmux/tmux.conf           "$HOME/.config/tmux/tmux.conf"
link aerospace/aerospace.toml "$HOME/.config/aerospace/aerospace.toml"
link karabiner/karabiner.json "$HOME/.config/karabiner/karabiner.json"
for f in "$DOT"/karabiner/assets/complex_modifications/*.json; do
  [ -f "$f" ] || continue
  link "${f#"$DOT"/}" "$HOME/.config/${f#"$DOT"/}"
done
link finicky/finicky.js       "$HOME/.finicky.js"

# git
link git/gitconfig            "$HOME/.gitconfig"
link git/ignore               "$HOME/.config/git/ignore"
link gh/config.yml            "$HOME/.config/gh/config.yml"

# editors
link zed/settings.json        "$HOME/.config/zed/settings.json"
link zed/keymap.json          "$HOME/.config/zed/keymap.json"
link nvim                     "$HOME/.config/nvim"
link ideavim/ideavimrc        "$HOME/.ideavimrc"
link cursor/cursorrules       "$HOME/.cursorrules"

# AI CLIs
link claude/CLAUDE.md             "$HOME/.claude/CLAUDE.md"
link claude/settings.json         "$HOME/.claude/settings.json"
link claude/statusline-command.sh "$HOME/.claude/statusline-command.sh"
link claude/mcp.json              "$HOME/.mcp.json"
for f in "$DOT"/claude/hooks/*; do
  [ -f "$f" ] || continue
  link "${f#"$DOT"/}" "$HOME/.claude/hooks/$(basename "$f")"
done
link opencode/opencode.json   "$HOME/.opencode.json"
for f in "$DOT"/codex/*.toml; do
  copy_if_missing "${f#"$DOT"/}" "$HOME/.codex/$(basename "$f")"
done

# tmux theme (not on brew)
CATPPUCCIN="$HOME/.config/tmux/plugins/catppuccin/tmux"
[ -d "$CATPPUCCIN" ] || git clone --depth 1 https://github.com/catppuccin/tmux.git "$CATPPUCCIN"

# fish plugins (fisher reads fish_plugins)
command -v fish >/dev/null && fish -c 'type -q fisher; and fisher update' || true

command -v brew >/dev/null && [ -f "$DOT/Brewfile" ] && echo "run: brew bundle --file=$DOT/Brewfile"
