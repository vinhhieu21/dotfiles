# Ghostty — Fonts & Themes to Try Later

Current setup (2026-07-06): **JetBrains Mono Medium 15px** + **Everforest Dark Hard / Light Med** (auto light/dark), solid background.

## How to switch

1. Edit `~/.config/ghostty/config` — change `theme =` or `font-family =` line.
2. Reload in Ghostty: `cmd+shift+,` (no restart needed).
3. Preview any theme interactively: `ghostty +list-themes` (arrow keys, live preview).
4. Backup of pre-optimization config: `config.bak`.

## Themes to try (all shipped with Ghostty — just change the name)

### Eye-comfort tier (soft contrast, no pure black/white)
| Theme | Character |
|---|---|
| `Everforest Dark Hard` | current — warm, green-tinted, designed for eye protection |
| `Gruvbox Material Dark` | same soft-contrast philosophy, warmer/browner |
| `Melange Dark` | paper-like, warm beige tones |
| `Flexoki Dark` | ink-on-paper inspired, calm; has `Flexoki Light` pair |
| `Selenized Dark` | Solarized successor, fixed its contrast problems |
| `Kanagawa Wave` | muted Japanese-ink palette, dusty blues |

### Popular / higher contrast (if soft feels washed out)
| Theme | Character |
|---|---|
| `Catppuccin Mocha` | soft pastels on dark, very popular |
| `Rose Pine` / `Rose Pine Moon` | muted mauve/pine, cozy |
| `Nord` | cool blue-grey, low contrast (maybe too low) |
| `TokyoNight Moon` | vibrant but not harsh |
| `Cursor Dark` | previous theme, near-black high contrast |

### Light pairs (for `theme = dark:X,light:Y` auto-switching)
`Everforest Light Med` (current) · `Gruvbox Material Light` · `Melange Light` · `Flexoki Light` · `Catppuccin Latte` · `Rose Pine Dawn` · `Selenized Light`

## Fonts

### Already installed — zero-effort swap
| Font | Character |
|---|---|
| `JetBrains Mono` | current — designed for reduced eye strain |
| `Maple Mono` | previous — rounded, cute; add back `font-feature = ss01` + `cv01` with it |
| `MesloLGS NF` | Menlo-based, powerline patched |
| `Menlo` / `Monaco` | macOS classics, no ligatures |

### Worth installing (eye-comfort focused)
| Font | Why | Install |
|---|---|---|
| Intel One Mono | designed with/for low-vision developers, very legible | `brew install --cask font-intel-one-mono` |
| Atkinson Hyperlegible Mono | Braille Institute design, maximum character distinction | `brew install --cask font-atkinson-hyperlegible-mono` |
| Iosevka | narrow — more code per line, many width/style variants | `brew install --cask font-iosevka` |
| Commit Mono | neutral, "anonymous" design, smart kerning | `brew install --cask font-commit-mono` |
| Monaspace (Neon/Argon) | GitHub's family, "texture healing" evens spacing | `brew install --cask font-monaspace` |

After `brew install`, font appears in `ghostty +list-fonts` immediately; set `font-family` and reload.

## Font settings worth experimenting with

```ini
# Roomier lines (if text feels cramped)
adjust-cell-height = 10%

# Lighter/heavier text
font-style = "Regular"   # vs current "Medium"

# Disable ligatures (some find != ligature glyphs harder to parse)
font-feature = -calt
```

## Line height cheat sheet (per editor)

Target ~1.5× font size **visually** — but editors use different units, so the right number differs:

| Editor | Setting | Semantics | Use |
|---|---|---|---|
| VS Code / Cursor / Windsurf | `editor.lineHeight` | × font size | `1.5–1.6` |
| JetBrains IDEs (IDEA, WebStorm…) | Editor → Font → Line height | × font's **built-in** metrics | `1.2–1.3` |
| Sublime Text | `line_padding_top`/`_bottom` | pixels per line | `2` + `2` at 15px |
| Neovide (GUI Neovim) | `linespace` | pixels | `3–4` |
| Emacs | `line-spacing` | int = px, float = fraction | `0.15–0.2` |
| Terminal editors (vim, helix, less) | — inherits Ghostty cell | `adjust-cell-height` | already tuned |
| Xcode | not exposed | font metrics only | roomy font compensates |

Key gotcha: JetBrains clan multiplies the font's *own* line metrics — JetBrains Mono already ships ~120% spacing, so IDEA `1.2` ≈ VS Code `1.5` visually. Same number ≠ same look.

Current state (2026-07-06): Ghostty native metrics · VS Code `1.6` ✓ · IDEA `1.57` (airy — drop to `1.2–1.3` to match others).

## Cross-app sync status (2026-07-06)

| App | Font | Theme | Auto light/dark |
|---|---|---|---|
| Ghostty | JetBrains Mono Medium 15 ✓ | Everforest Dark Hard / Light Med ✓ | ✓ |
| VS Code | JetBrains Mono 500 @ 15 ✓ | Everforest (sainnhe ext, hard/medium contrast) ✓ | ✓ |
| IntelliJ IDEA | pending — size 15 + Medium weight | pending — plugin `com.github.menwhorust.everforest` | tick "Sync with OS" |

IDEA steps: Settings → Plugins → Marketplace → "Everforest" (menwhorust) → restart →
Appearance: Everforest Dark + Sync with OS → Editor → Font: size 15, Typography Medium/Bold, line height 1.2.
