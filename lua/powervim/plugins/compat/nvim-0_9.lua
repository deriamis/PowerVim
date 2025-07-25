if vim.fn.has("nvim-0.10.0") == 0 then
  return {}
end

-- Compatibility with Neovim 0.9
return {
  -- Use LuaSnip instead of native snippets
  { "garymjr/nvim-snippets", enabled = false },
  { import = "lazyvim.plugins.coding.luasnip" },

  -- Use nvim-cmp instead of blink.cmp
  { import = "lazyvim.plugins.coding.nvim-cmp" },

  -- Use mini.comment instead of ts-comments
  { "folke/ts-comments.nvim", enabled = false },
  { import = "lazyvim.plugins.coding.mini-comment" },

  -- Use neodev-types with lazydev
  { "folke/neodev.nvim", config = function() end },
  {
    "folke/lazydev.nvim",
    opts = function(_, opts)
      opts.library = opts.library or {}
      table.insert(opts.library, { "neodev.nvim/types/stable" })
    end,
    config = function(_, opts)
      -- force lazydev to load on Neovim 0.9
      require("lazydev.config").have_0_10 = true
      require("lazydev").setup(opts)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {},
  },

  -- dummy import to save core imports
  {
    import = "foobar",
    enabled = function()
      PowerVim.plugin.save_core()
      return false
    end,
  },
}
