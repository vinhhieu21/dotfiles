-- JetBrains parity, part 2: keys LazyVim sets buffer-locally (LSP / treesitter),
-- so they can only be overridden here, not in config/keymaps.lua.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          -- stylua: ignore
          keys = {
            { "<leader>ss", function() Snacks.picker.smart() end, desc = "Search Everywhere" },
            { "gD", vim.lsp.buf.type_definition, desc = "Goto Type Declaration", has = "typeDefinition" },
            { "gi", vim.lsp.buf.implementation, desc = "Goto Implementation", has = "implementation" },
            { "go", function() vim.lsp.buf.typehierarchy("supertypes") end, desc = "Goto Super", has = "prepareTypeHierarchy" },
            { "gs", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Goto Symbol", has = "workspace/symbol" },
            { "]u", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Usage", has = "documentHighlight" },
            { "[u", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Usage", has = "documentHighlight" },
            { "<leader>cc", "gcc", remap = true, desc = "Comment Line" },
            { "<leader>cc", "gc", mode = "x", remap = true, desc = "Comment Selection" },
            { "<leader>ci", function() LazyVim.lsp.action["source.organizeImports"]() end, desc = "Optimize Imports", has = "codeAction" },
            { "<leader>cR", function() vim.lsp.buf.code_action({ context = { only = { "refactor" } } }) end, desc = "Refactor This", has = "codeAction" },
          },
        },
      },
    },
  },

  -- IntelliJ: [c ]c = changes (handled in keymaps.lua), [m ]m = methods
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      local keys = opts.move.keys
      keys.goto_next_start["]c"], keys.goto_previous_start["[c"] = nil, nil
      keys.goto_next_start["]m"] = "@function.outer"
      keys.goto_previous_start["[m"] = "@function.outer"
    end,
  },
}
