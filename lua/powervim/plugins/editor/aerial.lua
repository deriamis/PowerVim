if not vim.g.powervim_symbol_browser == "aerial" then
  return {
    "stevearc/aerial.nvim",
    dependencies = {},
    enabled = false,
    optional = true,
    keys = {
      { "<leader>cs", false },
    },
  }
end

return {
  desc = "Aerial Symbol Browser",
  {
    "stevearc/aerial.nvim",
    priority = 100,
    event = "PowerFile",
    opts = function()
      local icons = vim.deepcopy(PowerVim.config.icons.kinds)

      -- HACK: fix lua's weird choice for `Package` for control
      -- structures like if/else/for/etc.
      icons.lua = { Package = icons.Control }

      ---@type table<string, string[]>|false
      local filter_kind = false
      if PowerVim.config.kind_filter then
        filter_kind = assert(vim.deepcopy(PowerVim.config.kind_filter))
        filter_kind._ = filter_kind.default
        filter_kind.default = nil
      end

      local opts = {
        attach_mode = "global",
        backends = { "lsp", "treesitter", "markdown", "man" },
        show_guides = true,
        layout = {
          resize_to_content = false,
          win_opts = {
            winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
            signcolumn = "yes",
            statuscolumn = " ",
          },
        },
        icons = icons,
        filter_kind = filter_kind,
        -- stylua: ignore
        guides = {
          mid_item   = "├╴",
          last_item  = "└╴",
          nested_top = "│ ",
          whitespace = "  ",
        },
      }
      return opts
    end,
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
    },
  },

  {
    "folke/trouble.nvim",
    optional = true,
    keys = {
      { "<leader>cs", false },
    },
  },

  -- Telescope integration
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function()
      PowerVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("aerial")
      end)
    end,
    keys = {
      {
        "<leader>ss",
        "<cmd>Telescope aerial<cr>",
        desc = "Goto Symbol (Aerial)",
      },
    },
  },

  -- edgy integration
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = "Aerial",
        ft = "aerial",
        pinned = true,
        open = "AerialOpen",
      })
    end,
  },

  -- lualine integration
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      if not vim.g.trouble_lualine then
        table.insert(opts.sections.lualine_c, {
          "aerial",
          sep = " ", -- separator between symbols
          sep_icon = "", -- separator between icon and symbol

          -- The number of symbols to render top-down. In order to render only 'N' last
          -- symbols, negative numbers may be supplied. For instance, 'depth = -1' can
          -- be used in order to render only current symbol.
          depth = 5,

          -- When 'dense' mode is on, icons are not rendered near their symbols. Only
          -- a single icon that represents the kind of current symbol is rendered at
          -- the beginning of status line.
          dense = false,

          -- The separator to be used to separate symbols in dense mode.
          dense_sep = ".",

          -- Color the symbol icons.
          colored = true,
        })
      end
    end,
  },
}
