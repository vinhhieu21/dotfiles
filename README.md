# dotfiles

Dev environment: fish (zsh fallback) + starship + ghostty + tmux + aerospace + karabiner + zed / nvim / ideavim + git + Claude Code / Codex / OpenCode.
Primary target is macOS; the shell/editor/git/AI-CLI parts also run on Windows (WSL2 or native, see below).

## macOS

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

## Windows

macOS-only pieces (aerospace, karabiner, ghostty, finicky, zsh) are skipped on Windows. Everything else works in one of two ways.

### WSL2 (full shell setup: fish + starship + tmux + nvim)

Inside the Ubuntu distro:

```sh
sudo apt install -y git curl build-essential
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"   # Homebrew on Linux
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
git clone git@github.com:vinhhieu21/dotfiles.git ~/dotfiles
grep '^brew ' ~/dotfiles/Brewfile | brew bundle --file=-   # formulae only; casks are macOS-only
~/dotfiles/install.sh
command -v fish | sudo tee -a /etc/shells && chsh -s "$(command -v fish)"
```

`fish/config.fish` detects the Linux Homebrew prefix (`/home/linuxbrew/.linuxbrew`) automatically. Skip `colima`; use Docker Desktop with WSL integration instead. Set the Windows Terminal profile to the Ubuntu distro and pick a Nerd Font (JetBrainsMono NF) for starship icons.

### Native Windows (git, nvim, zed, ideavim, starship, Claude Code, Codex)

PowerShell 7 (`winget install Microsoft.PowerShell`), with Developer Mode on (Settings > System > For developers) so symlinks work without admin:

```powershell
winget install Git.Git GitHub.cli Neovim.Neovim Starship.Starship jqlang.jq sharkdp.fd sharkdp.bat junegunn.fzf ajeetdsouza.zoxide eza-community.eza ZedIndustries.Zed JetBrains.Toolbox Anthropic.ClaudeCode OpenAI.Codex
git clone git@github.com:vinhhieu21/dotfiles.git $HOME\dotfiles

$D = "$HOME\dotfiles"
$links = @{
  "$HOME\.gitconfig"                   = "git\gitconfig"
  "$HOME\.config\git\ignore"           = "git\ignore"
  "$HOME\.config\starship.toml"        = "starship\starship.toml"
  "$env:LOCALAPPDATA\nvim"             = "nvim"
  "$env:APPDATA\Zed\settings.json"     = "zed\settings.json"
  "$env:APPDATA\Zed\keymap.json"       = "zed\keymap.json"
  "$env:APPDATA\GitHub CLI\config.yml" = "gh\config.yml"
  "$HOME\.ideavimrc"                   = "ideavim\ideavimrc"
  "$HOME\.cursorrules"                 = "cursor\cursorrules"
  "$HOME\.claude\CLAUDE.md"            = "claude\CLAUDE.md"
  "$HOME\.claude\settings.json"        = "claude\settings.json"
  "$HOME\.mcp.json"                    = "claude\mcp.json"
  "$HOME\.opencode.json"               = "opencode\opencode.json"
}
foreach ($dst in $links.Keys) {
  $src = Join-Path $D $links[$dst]
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  if ((Test-Path $dst) -and -not (Get-Item $dst).LinkType) { Move-Item $dst "$dst.bak" }
  New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
  "linked $dst"
}
# codex: copy once, never overwrite (codex rewrites its config at runtime)
New-Item -ItemType Directory -Force "$HOME\.codex" | Out-Null
Get-ChildItem "$D\codex\*.toml" | Where-Object { -not (Test-Path "$HOME\.codex\$($_.Name)") } | Copy-Item -Destination "$HOME\.codex"

# prompt + cd in PowerShell (equivalent of the fish init lines)
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Force $PROFILE | Out-Null }
Add-Content $PROFILE 'Invoke-Expression (&starship init powershell)'
Add-Content $PROFILE 'Invoke-Expression (& { (zoxide init powershell | Out-String) })'
```

Windows notes:

- `git/gitconfig` uses `gh auth git-credential` from `PATH`, so run `gh auth login` once. `core.fsmonitor` is supported by Git for Windows.
- Per-machine identity still goes in `$HOME\.gitconfig.local` (see `git/gitconfig.local.example`).
- The `claude-work`/`codex` keychain wrappers are fish-only; on Windows set `OPENROUTER_API_KEY` / `STITCH_API_KEY` as user environment variables instead.
- `nvim` (LazyVim) needs a C compiler for treesitter: `winget install zig.zig` (small) or `Microsoft.VisualStudio.2022.BuildTools`.

## Notes

- Fish caches `starship`/`zoxide`/`fzf` init output in `~/.cache/fish/`; caches auto-refresh when the binary is upgraded.
- Per-machine git identity goes in `~/.gitconfig.local` (see `git/gitconfig.local.example`); it is included last and overrides the shared config.
- No secrets are stored here. API keys are read from the macOS keychain by the fish `claude-work`/`codex`/`opencode2` wrappers (`security add-generic-password -a "$USER" -s openrouter_api_key -w '<key>'`), and the Codex Stitch MCP header comes from `$STITCH_API_KEY`.
- Fish uses vi key bindings (`fish/conf.d/fish_frozen_key_bindings.fish`); `fish_plugins` lists the fisher plugins that `install.sh` installs.
