# dotfiles

macOS dev environment: fish (zsh fallback) + starship + ghostty + tmux + aerospace + karabiner + zed / nvim / ideavim + git + Claude Code / Codex / OpenCode.

```sh
git clone git@github.com:vinhhieu21/dotfiles.git ~/dotfiles
~/dotfiles/install.sh            # symlinks configs into ~/.config and ~
brew bundle --file=~/dotfiles/Brewfile
```

| dir          | target                                                                 |
|--------------|------------------------------------------------------------------------|
| `fish/`      | `~/.config/fish/{config.fish,fish_plugins,conf.d,functions,completions}` |
| `zsh/`       | `~/.zprofile`, `~/.zshrc`                                              |
| `starship/`  | `~/.config/starship.toml`                                              |
| `ghostty/`   | `~/.config/ghostty/config`                                             |
| `tmux/`      | `~/.config/tmux/tmux.conf`                                             |
| `aerospace/` | `~/.config/aerospace/aerospace.toml`                                   |
| `karabiner/` | `~/.config/karabiner/{karabiner.json,assets/}`                         |
| `finicky/`   | `~/.finicky.js`                                                        |
| `git/`       | `~/.gitconfig`, `~/.config/git/ignore`                                 |
| `gh/`        | `~/.config/gh/config.yml`                                              |
| `zed/`       | `~/.config/zed/{settings.json,keymap.json}`                            |
| `nvim/`      | `~/.config/nvim` (LazyVim)                                             |
| `ideavim/`   | `~/.ideavimrc`                                                         |
| `cursor/`    | `~/.cursorrules`                                                       |
| `claude/`    | `~/.claude/{CLAUDE.md,settings.json,statusline-command.sh,hooks/}`, `~/.mcp.json` |
| `opencode/`  | `~/.opencode.json`                                                     |
| `codex/`     | `~/.codex/*.toml` (copied once, not symlinked — codex rewrites its config at runtime) |

## Notes

- Fish caches `starship`/`zoxide`/`fzf` init output in `~/.cache/fish/`; caches auto-refresh when the binary is upgraded.
- Per-machine git identity goes in `~/.gitconfig.local` (see `git/gitconfig.local.example`); it is included last and overrides the shared config.
- No secrets are stored here. API keys are read from the macOS keychain by the fish `claude-work`/`codex`/`opencode2` wrappers (`security add-generic-password -a "$USER" -s openrouter_api_key -w '<key>'`), and the Codex Stitch MCP header comes from `$STITCH_API_KEY`.
- Fish uses vi key bindings (`fish/conf.d/fish_frozen_key_bindings.fish`); `fish_plugins` lists the fisher plugins that `install.sh` installs.
