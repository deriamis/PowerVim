if not vim.g.ai then
  return {}
end

return {
  recommended = true,
  -- copilot
  {
    "zbirenbaum/copilot.lua",
    priority = 20,
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      suggestion = {
        enabled = not vim.g.ai_cmp,
        auto_trigger = true,
        hide_during_completion = vim.g.ai_cmp,
        keymap = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  -- add ai_accept action
  {
    "zbirenbaum/copilot.lua",
    opts = function()
      PowerVim.cmp.actions.ai_accept = function()
        if require("copilot.suggestion").is_visible() then
          PowerVim.create_undo()
          require("copilot.suggestion").accept()
          return true
        end
      end
    end,
  },

  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(
        opts.sections.lualine_x,
        2,
        PowerVim.lualine.status(PowerVim.config.icons.kinds.Copilot, function()
          local clients = package.loaded["copilot"] and PowerVim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
          if #clients > 0 then
            local status = require("copilot.api").status.data.status
            return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
          end
        end)
      )
    end,
  },

  vim.g.ai_cmp
      and {
        -- copilot cmp source
        {
          "hrsh7th/nvim-cmp",
          optional = true,
          dependencies = { -- this will only be evaluated if nvim-cmp is enabled
            {
              "zbirenbaum/copilot-cmp",
              opts = {},
              config = function(_, opts)
                local copilot_cmp = require("copilot_cmp")
                copilot_cmp.setup(opts)
                -- attach cmp source whenever copilot attaches
                -- fixes lazy-loading issues with the copilot cmp source
                PowerVim.lsp.on_attach(function()
                  copilot_cmp._on_insert_enter({})
                end, "copilot")
              end,
              specs = {
                {
                  "hrsh7th/nvim-cmp",
                  optional = true,
                  ---@param opts cmp.ConfigSchema
                  opts = function(_, opts)
                    table.insert(opts.sources, 1, {
                      name = "copilot",
                      group_index = 1,
                      priority = 100,
                    })
                  end,
                },
              },
            },
          },
        },
        {
          "saghen/blink.cmp",
          optional = true,
          dependencies = { "giuxtaposition/blink-cmp-copilot" },
          opts = {
            sources = {
              default = { "copilot" },
              providers = {
                copilot = {
                  name = "copilot",
                  module = "blink-cmp-copilot",
                  kind = "Copilot",
                  score_offset = 100,
                  async = true,
                },
              },
            },
          },
        },
      }
    or nil,
}
