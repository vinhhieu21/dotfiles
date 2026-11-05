# dotfiles

Dev environment: fish (zsh fallback) + starship + ghostty + rex + tmux + aerospace + karabiner + nvim / ideavim + git + Claude Code / Codex / OpenCode.
Primary target is macOS; the shell/editor/git/AI-CLI parts also run on Windows (native or WSL2, see below).

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
| `rex/`       | `~/.config/rex/init.lua` (keybindings; appearance lives in Rex Settings) |
| `bat/`      | `~/.config/bat/themes` (Tokyo Night `.tmTheme`; `install.sh` runs `bat cache --build`) |
| `tmux/`      | `~/.config/tmux/tmux.conf`                                             |
| `herdr/`     | `~/.config/herdr/config.toml` (copied once, not symlinked)             |
| `aerospace/` | `~/.config/aerospace/aerospace.toml`                                   |
| `karabiner/` | `~/.config/karabiner/{karabiner.json,assets/}`                         |
| `finicky/`   | `~/.finicky.js`                                                        |
| `git/`       | `~/.gitconfig`, `~/.config/git/ignore`                                 |
| `gh/`        | `~/.config/gh/config.yml`                                              |
| `nvim/`      | `~/.config/nvim` (LazyVim)                                             |
| `ideavim/`   | `~/.ideavimrc`                                                         |
| `cursor/`    | `~/.cursorrules`                                                       |
| `claude/`    | `~/.claude/{CLAUDE.md,statusline-command.sh,agents,skills,hooks,workflows,mods}`, `~/.mcp.json`; `settings.json` is copied once, not symlinked (Claude Code rewrites it) |
| `opencode/`  | `~/.opencode.json`                                                     |
| `codex/`     | `~/.codex/*.toml` (copied once, not symlinked - codex rewrites its config at runtime) |

## Windows

macOS-only pieces (aerospace, karabiner, ghostty, rex, finicky) are skipped on Windows.
`wezterm/`, `ahk/` and `glazewm/` are their Windows counterparts for Ghostty, Karabiner and AeroSpace.
Pick native Windows or WSL2; both can live on one machine.

### Native Windows (PowerShell, git, nvim, starship, Claude Code, Codex)

1. Turn on Developer Mode (Settings > System > For developers) so symlinks work without admin.
2. In any terminal, install the prerequisites:

   ```powershell
   winget install --id Microsoft.PowerShell --exact
   winget install --id Git.Git --exact
   ```

3. Open a new **PowerShell 7** terminal (`pwsh`) and run:

   ```powershell
   git clone https://github.com/vinhhieu21/dotfiles.git $HOME\dotfiles
   & $HOME\dotfiles\install.ps1
   ```

4. Open a new terminal, then finish by hand:

   ```powershell
   gh auth login
   ```

`install.ps1` is safe to re-run.
It installs the tools with winget and symlinks the configs below.
Use `-SkipPackages` to only link configs.
Use `-WithBuildTools` to also install the Visual Studio C++ build tools (several GB), which `nvim-treesitter` needs to compile parsers.

| dir           | target                                                        |
|---------------|---------------------------------------------------------------|
| `powershell/` | `$PROFILE.CurrentUserAllHosts`                                |
| `starship/`   | `~\.config\starship.toml`                                      |
| `bat/`        | `%APPDATA%\bat\themes`                                         |
| `wezterm/`    | `~\.wezterm.lua`                                               |
| `glazewm/`    | `~\.glzr\glazewm\config.yaml` (AeroSpace's `alt-*` becomes `lwin+*`; Win+L is reserved, so focus-right is Win+;) |
| `ahk/`        | `~\Documents\MacKeys\mac-keys.ahk` (Left Alt = Cmd, Win = Option, Caps Lock tap = Escape) |
| `git/`        | `~\.gitconfig`, `~\.config\git\ignore`                         |
| `gh/`         | `%APPDATA%\GitHub CLI\config.yml`                              |
| `nvim/`       | `%LOCALAPPDATA%\nvim`                                           |
| `cursor/`     | `~\.cursorrules`                                               |
| `claude/`     | `~\.claude\{CLAUDE.md,agents,skills,hooks,workflows,mods}`, `~\.mcp.json` |
| `opencode/`   | `~\.opencode.json`                                             |

Seeded once and never overwritten, because the tools rewrite them: `~\.claude\settings.json`, `~\.codex\*.toml`.

Windows notes:

- In Windows Terminal, make PowerShell 7 the default profile and set its font to `JetBrainsMono NF`, or starship icons render as boxes.
- `git/gitconfig` uses `gh auth git-credential` from `PATH`, so `gh auth login` is required before pushing.
- Per-machine identity goes in `~\.gitconfig.local` (see `git/gitconfig.local.example`).
- The `claude-work`/`codex-work` wrappers are fish-only.
  On Windows, set `OPENROUTER_API_KEY` and `STITCH_API_KEY` as user environment variables instead.
- The shared Claude settings leave out machine-specific hooks and auto-mode context, which belong to each machine.
  Rex and herdr add their own hooks when set up.

### WSL2 (full shell setup: fish + starship + tmux + nvim)

Inside the Ubuntu distro:

```sh
sudo apt install -y git curl build-essential
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"   # Homebrew on Linux
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
git clone https://github.com/vinhhieu21/dotfiles.git ~/dotfiles
grep '^brew ' ~/dotfiles/Brewfile | brew bundle --file=-   # formulae only; casks are macOS-only
~/dotfiles/install.sh
command -v fish | sudo tee -a /etc/shells && chsh -s "$(command -v fish)"
```

`install.sh` skips the macOS-only apps, and `fish/config.fish` detects the Linux Homebrew prefix (`/home/linuxbrew/.linuxbrew`).
The fish wrappers read `OPENROUTER_API_KEY` from the environment when there is no macOS keychain.
Skip `colima`; use Docker Desktop with WSL integration instead.
Set the Windows Terminal profile to the Ubuntu distro and pick a Nerd Font (`JetBrainsMono NF`) for starship icons.

## Notes

- Fish caches `starship`/`zoxide`/`fzf` init output in `~/.cache/fish/`; caches auto-refresh when the binary is upgraded.
- Per-machine git identity goes in `~/.gitconfig.local` (see `git/gitconfig.local.example`); it is included last and overrides the shared config.
- No secrets are stored here. API keys are read from the macOS keychain by the fish `claude-work`/`codex-work`/`opencode2` wrappers (`security add-generic-password -a "$USER" -s openrouter_api_key -w '<key>'`), and the Codex Stitch MCP header comes from `$STITCH_API_KEY`.
- Fish uses vi key bindings (`fish/conf.d/fish_frozen_key_bindings.fish`); `fish_plugins` lists the fisher plugins that `install.sh` installs.
