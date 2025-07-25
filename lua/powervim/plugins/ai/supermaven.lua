if not vim.g.ai then
  return {}
end

return {
  {
    "supermaven-inc/supermaven-nvim",
    priority = 20,
    event = "InsertEnter",
    cmd = {
      "SupermavenUseFree",
      "SupermavenUsePro",
    },
    opts = {
      keymaps = {
        accept_suggestion = nil, -- handled by nvim-cmp / blink.cmp
      },
      disable_inline_completion = vim.g.ai_cmp,
      ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
    },
  },

  -- add ai_accept action
  {
    "supermaven-inc/supermaven-nvim",
    priority = 20,
    opts = function()
      require("supermaven-nvim.completion_preview").suggestion_group = "SupermavenSuggestion"
      PowerVim.cmp.actions.ai_accept = function()
        local suggestion = require("supermaven-nvim.completion_preview")
        if suggestion.has_suggestion() then
          PowerVim.create_undo()
          vim.schedule(function()
            suggestion.on_accept_suggestion()
          end)
          return true
        end
      end
    end,
  },

  -- cmp integration
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "supermaven-nvim" },
    opts = function(_, opts)
      if vim.g.ai_cmp then
        table.insert(opts.sources, 1, {
          name = "supermaven",
          group_index = 1,
          priority = 100,
        })
      end
    end,
  },

  vim.g.ai_cmp and {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "supermaven-nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "supermaven" },
        providers = {
          supermaven = {
            kind = "Supermaven",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  } or nil,

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, PowerVim.lualine.cmp_source("supermaven"))
    end,
  },

  {
    "folke/noice.nvim",
    optional = true,
    opts = function(_, opts)
      vim.list_extend(opts.routes, {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "Starting Supermaven" },
              { find = "Supermaven Free Tier" },
            },
          },
          skip = true,
        },
      })
    end,
  },
}
