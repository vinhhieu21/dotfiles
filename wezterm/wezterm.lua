-- WezTerm: the Windows counterpart of ghostty/config (Ghostty has no Windows build).
-- install.ps1 links this to ~/.wezterm.lua. ahk/mac-keys.ahk turns Left Alt+key (Cmd) into the
-- Ctrl+Shift chords below, because plain Ctrl+C has to stay SIGINT inside a terminal.
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find('windows') ~= nil

------------------------------------------------------------------ appearance
-- Tokyo Night on a pure black background. starship, fzf and PSReadLine use ANSI slots, so this is
-- the single source of truth for their colors too.
config.color_scheme = 'tokyonight_night'
config.colors = { background = '#000000' }

config.font = wezterm.font_with_fallback {
  {
    family = 'JetBrainsMono Nerd Font',
    weight = 'Medium',
    harfbuzz_features = { 'calt=1', 'liga=1', 'zero=1' },
  },
  'Cascadia Code',
}
config.font_size = is_windows and 11.0 or 15.0
config.line_height = 1.1
config.underline_position = -2
config.underline_thickness = 1

-- Fully opaque: nothing behind the terminal shows through.
config.window_background_opacity = 1.0
config.window_decorations = 'RESIZE'
config.window_padding = { left = 18, right = 18, top = 16, bottom = 16 }
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

config.default_cursor_style = 'SteadyBlock'
config.audible_bell = 'Disabled'
config.scrollback_lines = 100000

------------------------------------------------------------------ tabs
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32

------------------------------------------------------------------ performance
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.max_fps = 120
config.animation_fps = 60

------------------------------------------------------------------ shell
if is_windows then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
  config.launch_menu = {
    { label = 'PowerShell 7', args = { 'pwsh.exe', '-NoLogo' } },
    { label = 'Windows PowerShell', args = { 'powershell.exe', '-NoLogo' } },
    { label = 'Git Bash', args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-i', '-l' } },
    { label = 'cmd', args = { 'cmd.exe' } },
  }
end

------------------------------------------------------------------ keys
local mod = is_windows and 'CTRL|SHIFT' or 'CMD'
local mod_down = is_windows and 'CTRL|SHIFT|ALT' or 'CMD|SHIFT'

config.keys = {
  -- WezTerm binds Alt+Enter to ToggleFullScreen by default. Left Alt is Cmd here, so Cmd+Enter
  -- would take the window out of GlazeWM's tiling. Send it to the shell / TUI instead.
  { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
  -- splits
  { key = 'd', mods = mod,      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = mod_down, action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = mod,      action = act.CloseCurrentPane { confirm = true } },
  { key = 't', mods = mod,      action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'z', mods = mod,      action = act.TogglePaneZoomState },

  -- pane navigation
  { key = 'LeftArrow',  mods = mod, action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = mod, action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = mod, action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = mod, action = act.ActivatePaneDirection 'Down' },

  -- font size + reset
  { key = '=', mods = mod, action = act.IncreaseFontSize },
  { key = '-', mods = mod, action = act.DecreaseFontSize },
  { key = '0', mods = mod, action = act.ResetFontSize },

  -- search / copy mode / palette
  { key = 'f', mods = mod, action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'x', mods = mod, action = act.ActivateCopyMode },
  { key = 'p', mods = mod, action = act.ActivateCommandPalette },

  -- clear scrollback
  { key = 'k', mods = mod, action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
  } },
}

-- Cmd+1..9 selects a tab. On Windows, Left Alt is Cmd and mac-keys.ahk leaves these keys alone.
local tab_mod = is_windows and 'ALT' or 'CMD'
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = tab_mod, action = act.ActivateTab(i - 1) })
end

return config
