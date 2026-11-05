-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- Performance & disk I/O
opt.swapfile = false -- Persistent undo is already enabled by LazyVim; swapfiles cause extra disk I/O and recovery prompts
opt.updatetime = 200 -- Faster completion and diagnostic popups
opt.timeoutlen = 300 -- Snappy keymaps

-- Ergonomics
opt.smoothscroll = true -- Smooth scroll on Neovim 0.10+

-- Disable unused legacy providers (Neovim/LazyVim is pure Lua)
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
