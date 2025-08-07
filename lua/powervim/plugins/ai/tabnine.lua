if not vim.g.powervim.ai.enable and vim.tbl_contains(vim.g.powervim.ai.integrations, "tabnine") then
  return {}
end

return {
  -- Tabnine cmp source
  {
    "tzachar/cmp-tabnine",
    priority = 20,
    build = PowerVim.is_win() and "pwsh -noni .\\install.ps1" or "./install.sh",
    opts = {
      max_lines = 1000,
      max_num_results = 3,
      sort = true,
    },
    config = function(_, opts)
      require("cmp_tabnine.config"):setup(opts)
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "tzachar/cmp-tabnine" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "cmp_tabnine",
        group_index = 1,
        priority = 100,
      })

      opts.formatting.format = PowerVim.inject.args(opts.formatting.format, function(entry, item)
        -- Hide percentage in the menu
        if entry.source.name == "cmp_tabnine" then
          item.menu = ""
        end
      end)
    end,
  },

  vim.g.powervim.cmp.ai and {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "tzachar/cmp-tabnine", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "cmp_tabnine" },
        providers = {
          cmp_tabnine = {
            kind = "TabNine",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  } or nil,

  -- Show TabNine status in lualine
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local icon = PowerVim.config.icons.kinds.TabNine
      table.insert(opts.sections.lualine_x, 2, PowerVim.lualine.cmp_source("cmp_tabnine", icon))
    end,
  },
}
