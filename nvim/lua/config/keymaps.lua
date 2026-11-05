-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- JetBrains parity: these mirror ~/dotfiles/ideavim/ideavimrc so one set of keys works in
-- IntelliJ and Neovim. Only keys that differ from LazyVim's defaults are listed here.
-- Keys that must beat LSP buffer-local maps live in lua/plugins/jetbrains.lua.

local map = vim.keymap.set

-- stylua: ignore start

-- escape
map("i", "jk",    "<Esc>", { desc = "Escape" })
map("i", "<C-j>", "<Esc>", { desc = "Escape" })

-- search
-- Cmd+Shift+F (Find in Files); Ghostty forwards it as <D-F>, see ghostty/config
map("n", "<D-F>", function() LazyVim.pick("live_grep")() end, { desc = "Find in Files" })
map("n", "<leader>sw", function() Snacks.picker.lsp_references() end, { desc = "Find Usages" })
map("n", "<leader>sc", function()
  Snacks.picker.lsp_workspace_symbols({ filter = { default = { "Class", "Interface", "Struct", "Enum", "Module" } } })
end, { desc = "Goto Class" })
map("n", "<leader>sb", function() Snacks.picker.jumps() end, { desc = "Recent Locations" })

-- files
map("n", "<leader>fR", function() Snacks.picker.projects() end,             { desc = "Recent Projects" })
map("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end,          { desc = "File Structure" })
map("n", "<leader>fp", function() print(vim.fn.expand("%:p")) end,          { desc = "Show File Path" })
map("n", "<leader>fP", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied " .. path)
end, { desc = "Copy Absolute Path" })
map("n", "<leader>fh", function() Snacks.picker.undo() end,                 { desc = "Local History" })
map("n", "<leader>fm", function() Snacks.picker.marks() end,                { desc = "Bookmarks" })

-- buffers (= editor tabs)
map("n", "<leader>bb", function() Snacks.picker.recent() end,               { desc = "Recent Files" })
map("n", "<leader>ba", function() Snacks.bufdelete.all() end,               { desc = "Close All Buffers" })
map("n", "<leader>bn", "<cmd>bnext<cr>",                                    { desc = "Next Buffer" })
map("n", "<leader>bN", "<cmd>bprevious<cr>",                                { desc = "Prev Buffer" })
for i = 1, 9 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>",    { desc = "Go to Buffer " .. i })
end

-- windows
map("n", "<leader>wp", "<C-w>p", { desc = "Last Window" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close Other Windows" })

-- navigation
map("n", "ga", function() Snacks.picker.commands() end, { desc = "Goto Action" })
map("n", "]g", function() vim.diagnostic.jump({ count = 1, float = true }) end,  { desc = "Next Error" })
map("n", "[g", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev Error" })
map("n", "]c", function()
  if vim.wo.diff then return vim.cmd.normal({ "]c", bang = true }) end
  require("gitsigns").nav_hunk("next")
end, { desc = "Next Change" })
map("n", "[c", function()
  if vim.wo.diff then return vim.cmd.normal({ "[c", bang = true }) end
  require("gitsigns").nav_hunk("prev")
end, { desc = "Prev Change" })

-- code (non-LSP buffers; LSP buffers get the same keys from plugins/jetbrains.lua)
map("n", "<leader>cc", "gcc", { remap = true, desc = "Comment Line" })
map("x", "<leader>cc", "gc",  { remap = true, desc = "Comment Selection" })
map("n", "<leader>cI", function() Snacks.picker.diagnostics() end, { desc = "Inspect Code" })

-- ui and tools
map("n", "<leader>tt", function() Snacks.terminal() end,                                      { desc = "Terminal" })
map("n", "<leader>tT", function() Snacks.terminal(nil, { cwd = vim.fn.expand("%:p:h") }) end, { desc = "Terminal (File Dir)" })
map("n", "<leader>to", function() Snacks.picker.todo_comments() end,                          { desc = "TODO" })
map("n", "<leader>mm", function() Snacks.picker.commands() end,                               { desc = "Main Menu" })

-- folds (IntelliJ zc/zo act on all regions)
map("n", "zc", "zM", { desc = "Collapse All" })
map("n", "zo", "zR", { desc = "Expand All" })

-- clipboard
map("n", "<leader>yA", "<cmd>%y+<cr>", { desc = "Yank All to Clipboard" })

-- stylua: ignore end
