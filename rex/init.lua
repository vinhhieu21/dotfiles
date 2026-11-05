-- Rex config. Only non-default bindings; Rex defaults follow Ghostty's cmd shortcuts.
-- Apply: `rex config reload`. Inspect: `rex config check`, `rex keymap`.
-- Docs: https://www.superlogical.com/rex/docs/customize/config

-- Line editing: Cmd+Delete kills to end of line (readline C-k)
rex.bind("cmd+delete", "pane.send_key", { key = "ctrl+k" })

-- Neovim: forward JetBrains-style Cmd+Shift+F as CSI-u (super+shift = mod 10), seen as <D-F>.
-- See nvim/lua/config/keymaps.lua
rex.bind("cmd+shift+f", function()
  rex.block.call("com.superlogical.terminal", "write", { data = "\27[102;10u" })
  return true
end)
