# Neovim Configuration

Fast, streamlined [LazyVim](https://lazyvim.github.io/) setup styled with Tokyo Night to match Ghostty, Fish, and Bat.

## Structure

```
nvim/
├── init.lua                # Entry point
├── lazy-lock.json          # Pinned plugin lockfile
├── stylua.toml             # Lua formatting settings
└── lua/
    ├── config/
    │   ├── autocmds.lua    # User autocommands
    │   ├── keymaps.lua     # JetBrains/IdeaVim-parity keymaps (mirror of ideavim/ideavimrc)
    │   ├── lazy.lua        # Lazy.nvim bootstrap & performance tweaks
    │   └── options.lua     # Editor options & optimizations
    └── plugins/
        ├── colorscheme.lua # Tokyo Night theme & theme overrides
        └── jetbrains.lua   # JetBrains-parity keys that override LSP/treesitter buffer maps
```

## Optimizations

- **Tokyo Night Night**: Native LazyVim theme, matching Ghostty and terminal palette with zero overhead.
- **Lazy Loading**: Plugins load on demand; startup time is ~25-30ms.
- **RTP Pruned**: Disabled unused legacy runtime plugins (`netrwPlugin`, `rplugin`, `gzip`, `tarPlugin`, `zipPlugin`, `tutor`, `tohtml`).
- **Disk I/O**: Disabled swapfiles (`swapfile = false`) in favor of persistent undo.
- **Background Checks**: Disabled automatic startup update checks to prevent network latency and git lock contention.
